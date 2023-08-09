SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_PPM_INFO_PRINT]
@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @job_ref_no NVARCHAR(50) = ''
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	DECLARE @print_last_page BIT = 0

	CREATE TABLE #MATERIAL_RECONCILIATION_BODY
	(
		id INT IDENTITY(1,1),
		material_item NVARCHAR(200),
		manual_ppm BIT,
		issued_qty INT,
		batch NVARCHAR(20),
		[return] NVARCHAR(50), 
		
		job_ref_no NVARCHAR(50), 
		line_no INT, 
		prd_code NVARCHAR(50)
	)

	CREATE TABLE #MATERIAL_RECONCILIATION_FOOTER
	(
		creator NVARCHAR(MAX),
		created_date NVARCHAR(50)
	)

	CREATE TABLE #QUALITY_CONTROL
	(
		first_vas_date NVARCHAR(20),
		first_vas_time NVARCHAR(20),
		last_vas_date NVARCHAR(20),
		last_vas_time NVARCHAR(20)
	)

	INSERT INTO #MATERIAL_RECONCILIATION_BODY(material_item, manual_ppm, issued_qty, batch, [return], job_ref_no, line_no, prd_code)
	SELECT (B.prd_code + '-' + B.prd_desc), A.manual_ppm, A.issued_qty, A.batch_no, '', A.job_ref_no, A.line_no, A.prd_code FROM TBL_TXN_PPM A
	INNER JOIN TBL_MST_PRODUCT B ON A.prd_code = B.prd_code
	INNER JOIN [VASDEV_INTEGRATION_TH].[dbo].[VAS_TRANSFER_ORDER_SAP] C ON C.workorder_no = A.job_ref_no AND A.prd_code = C.prd_code AND A.system_running_no = C.requirement_no and A.batch_no = C.batch_no and A.line_no = C.line_no
	WHERE A.job_ref_no = @job_ref_no
	AND A.issued_qty <> 0
	AND (A.action_from_reopen IN ('Add') OR A.action_from_reopen is null)
	AND C.status = 'R'

	UPDATE D
	SET [return] = G.total_issued_qty
	FROM #MATERIAL_RECONCILIATION_BODY D
	INNER JOIN (
		SELECT 
			--system_running_no,
			P.returned_from_job_ref_no, 
			P.returned_from_line_no, 
			P.prd_code, 
			P.batch_no, 
			SUM(P.issued_qty) AS total_issued_qty
		FROM TBL_TXN_PPM P
		INNER JOIN [VASDEV_INTEGRATION_TH].[dbo].[VAS_TRANSFER_ORDER_SAP] E ON E.workorder_no = P.job_ref_no AND P.prd_code = E.prd_code and P.batch_no = E.batch_no and P.line_no = E.line_no
		WHERE P.action_from_reopen IN ('Return') AND E.status = 'R'
		GROUP BY --system_running_no, 
		P.returned_from_job_ref_no, P.returned_from_line_no, P.prd_code, P.batch_no
	) G ON D.job_ref_no = G.returned_from_job_ref_no 
		--AND G.system_running_no = E.requirement_no 
		AND D.line_no = G.returned_from_line_no 
		AND D.prd_code = G.prd_code 
		AND D.batch = G.batch_no

	INSERT INTO #MATERIAL_RECONCILIATION_FOOTER(creator, created_date)
	SELECT B.user_name, FORMAT (A.created_date, 'dd/MM/yyyy') FROM TBL_TXN_PPM A
	INNER JOIN VASDEV.dbo.TBL_ADM_USER B ON A.creator_user_id = B.user_id
	WHERE A.job_ref_no = @job_ref_no
	GROUP BY B.user_name, A.created_date

	DECLARE @total_qc_row INT = 0

	IF(LEFT(@job_ref_no, 1) = 'V')
	BEGIN
		SET @print_last_page = 1

		SELECT @total_qc_row = COUNT(event_id) FROM TBL_TXN_JOB_EVENT
		WHERE job_ref_no = @job_ref_no
		AND event_id = 40
		GROUP BY event_id

		IF @total_qc_row = 1
		BEGIN
			INSERT INTO #QUALITY_CONTROL(first_vas_date, first_vas_time, last_vas_date, last_vas_time)
			SELECT
				FORMAT ([start_date], 'dd/MM/yyyy') first_vas_date,
				FORMAT ([start_date], 'HH:mm:ss') first_vas_time,
				FORMAT ([end_date], 'dd/MM/yyyy') last_vas_date,
				FORMAT ([end_date], 'HH:mm:ss') last_vas_time
			FROM TBL_TXN_JOB_EVENT
			WHERE job_ref_no = @job_ref_no
			AND event_id = 40
		END
		ELSE IF @total_qc_row > 1
		BEGIN
			CREATE TABLE #QUALITY_CONTROL_TEMP
			(
				id INT IDENTITY(1, 1),
				[start_date] DATETIME,
				[end_date] DATETIME
			)

			INSERT INTO #QUALITY_CONTROL_TEMP([start_date], [end_date])
			SELECT [start_date], [end_date] FROM TBL_TXN_JOB_EVENT
			WHERE job_ref_no = @job_ref_no
			AND event_id = 40

			INSERT INTO #QUALITY_CONTROL(first_vas_date, first_vas_time)
			SELECT FORMAT ([start_date], 'dd/MM/yyyy') first_vas_date,
				FORMAT ([start_date], 'HH:mm:ss') first_vas_time
			FROM #QUALITY_CONTROL_TEMP
			WHERE id = 1

			UPDATE #QUALITY_CONTROL
			SET last_vas_date = FORMAT((SELECT [end_date] FROM #QUALITY_CONTROL_TEMP WHERE id = (SELECT MAX(id) FROM #QUALITY_CONTROL_TEMP)), 'dd/MM/yyyy'),
			last_vas_time = FORMAT((SELECT [end_date] FROM #QUALITY_CONTROL_TEMP WHERE id = (SELECT MAX(id) FROM #QUALITY_CONTROL_TEMP)), 'HH:mm:ss')

			DROP TABLE #QUALITY_CONTROL_TEMP
		END
	END
	
	SELECT id, material_item, manual_ppm, issued_qty, batch, [return] FROM #MATERIAL_RECONCILIATION_BODY -- 1 --

	SELECT * FROM #MATERIAL_RECONCILIATION_FOOTER -- 2 --

	SELECT @print_last_page AS print_last_page, -- 3 --
	(SELECT TOP 1 CONCAT(M.mll_desc, ' - ', M.revision_no) FROM TBL_TXN_JOB_EVENT J
		LEFT JOIN TBL_TXN_WORK_ORDER W WITH (NOLOCK) ON J.job_ref_no = W.job_ref_no
		LEFT JOIN TBL_MST_MLL_HDR M WITH (NOLOCK) ON W.mll_no = M.mll_no
		WHERE J.job_ref_no = @job_ref_no) AS qas_rev_no

	SELECT * FROM #QUALITY_CONTROL -- 4 --


	DROP TABLE #MATERIAL_RECONCILIATION_BODY
	DROP TABLE #MATERIAL_RECONCILIATION_FOOTER
	DROP TABLE #QUALITY_CONTROL
END
GO
