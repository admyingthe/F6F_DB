SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_UPDATE_COMPLETED_QTY_VAS]
	@job_ref_no NVARCHAR(20),
	@prd_code NVARCHAR(20)	
AS
BEGIN
	DECLARE @mll_no NVARCHAR(20) = (SELECT DISTINCT mll_no FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
	DECLARE @has_already_records BIT  = 0, @jobCreatedDate datetime

	SELECT @has_already_records = 1 FROM TBL_ADM_JOB_VENDOR WITH(NOLOCK) WHERE job_ref_no = @job_ref_no and prd_code = @prd_code
	select @jobCreatedDate = created_date from [TBL_TXN_WORK_ORDER] where job_ref_no = @job_ref_no

	IF (@has_already_records = 1)
	BEGIN
		CREATE TABLE #FINAL_SUM_VAS_ACTIVITY
		(
			id INT IDENTITY(1, 1),
			total_issued_qty INT,
			display_name NVARCHAR(MAX)
		)
		
		INSERT #FINAL_SUM_VAS_ACTIVITY
		(total_issued_qty, display_name)
		EXEC SPP_GET_COMPLETED_QTY_VAS @job_ref_no, @prd_code, @mll_no

		SELECT D.id as activity_id, A.display_name, total_issued_qty AS issued_qty, total_issued_qty AS normal_qty, B.Normal_Rate AS normal_rate, 0 AS ot_qty, B.OT_Rate AS ot_rate, C.id as vas_activity_rate_hdr_id, D.type as activity_type, FORMAT(C.Effective_Start_Date, 'dd/MM/yyyy ') AS date_from, FORMAT(C.Effective_End_Date, 'dd/MM/yyyy ') AS date_to
		INTO #NEW_COMPLETED_QTY
		FROM #FINAL_SUM_VAS_ACTIVITY A
		inner join [TBL_MST_ACTIVITY_LISTING] D WITH(NOLOCK) ON A.display_name = D.description
		inner join [TBL_MST_VAS_ACTIVITY_RATE_DTL] B WITH(NOLOCK) ON D.id = B.VAS_Activity_ID
		inner join [TBL_MST_VAS_ACTIVITY_RATE_HDR] C WITH(NOLOCK) ON B.VAS_Activity_Rate_HDR_ID = C.ID
		where @jobCreatedDate BETWEEN C.Effective_Start_Date AND C.Effective_End_Date and D.status = 1 and D.type = 'Standard'
		
		SELECT * INTO #TEMP FROM #NEW_COMPLETED_QTY A
		WHERE NOT EXISTS(SELECT * FROM TBL_ADM_JOB_VENDOR B WHERE A.activity_id = B.vas_activity_id AND A.issued_qty = B.issued_qty and B.job_ref_no = @job_ref_no and B.prd_code = @prd_code and B.activity_type = 'Standard')

		IF ((SELECT COUNT(activity_id) FROM #TEMP) > 0)
		BEGIN
			--UPDATE A
			--SET A.normal_qty = B.issued_qty, A.ot_qty = 0
			--FROM TBL_ADM_JOB_VENDOR A
			--INNER JOIN #TEMP B ON A.vas_activity_id = B.activity_id
			--WHERE (A.ot_qty - (A.issued_qty - B.normal_qty)) <= 0 AND A.job_ref_no = @job_ref_no AND A.prd_code = @prd_code

			--UPDATE A
			--SET A.ot_qty = (A.ot_qty - (A.issued_qty - A.normal_qty))
			--FROM TBL_ADM_JOB_VENDOR A
			--INNER JOIN #TEMP B ON A.vas_activity_id = B.activity_id
			--WHERE (A.ot_qty - (A.issued_qty - B.normal_qty)) > 0 AND A.job_ref_no = @job_ref_no AND A.prd_code = @prd_code

			UPDATE A
			SET A.issued_qty = B.issued_qty, A.normal_qty = B.issued_qty, A.ot_qty = 0
			FROM TBL_ADM_JOB_VENDOR A
			INNER JOIN #TEMP B ON A.vas_activity_id = B.activity_id AND A.job_ref_no = @job_ref_no AND A.prd_code = @prd_code
		END

		DROP TABLE #TEMP
		DROP TABLE #NEW_COMPLETED_QTY
		DROP TABLE #FINAL_SUM_VAS_ACTIVITY
	END	
END
GO
