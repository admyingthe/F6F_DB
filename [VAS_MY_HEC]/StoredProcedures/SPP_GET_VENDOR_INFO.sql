SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================      
-- Author:  LE TIEN DUNG
-- Create date: 2022-12-09
-- Description: Get Vendor in PPM
-- Example Query: EXEC SPP_GET_VENDOR_INFO @param=N'{"job_ref_no":"G2022/08/0004", "vendor_name":"TestABC", "prd_code":'100166390'}'
-- OUTPUT:
--- 1: dt: Issued Qty by each VAS Activity
--- 2: dtAudit: Table Audit for log tracing
-- ======================================================================== 

CREATE PROC [dbo].[SPP_GET_VENDOR_INFO]
@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @job_ref_no NVARCHAR(20) = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	DECLARE @vendor_id NVARCHAR(MAX) = (SELECT JSON_VALUE(@param, '$.vendor_id'))
	DECLARE @prd_code NVARCHAR(20) = (SELECT JSON_VALUE(@param, '$.prd_code'))
	DECLARE @mll_no NVARCHAR(20) = (SELECT DISTINCT mll_no FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

	DECLARE @has_already_records BIT  = 0, @jobCreatedDate datetime, @prd_code_records NVARCHAR(20) = @prd_code, @vendor_id_records NVARCHAR(20) = 'ALL'

	SELECT @has_already_records = 1, @vendor_id_records = vendor_id FROM TBL_ADM_JOB_VENDOR WITH(NOLOCK) WHERE job_ref_no = @job_ref_no and prd_code = @prd_code

	select @jobCreatedDate = created_date from [TBL_TXN_WORK_ORDER] where job_ref_no = @job_ref_no

	IF (@vendor_id_records = 'ALL')
	BEGIN
		SELECT @vendor_id_records = id FROM [TBL_MST_VENDOR_LISTING] WHERE vendor_code = @vendor_id_records
	END

	--if already got record saved in TBL_ADM_JOB_VENDOR, then just return list from TBL_ADM_JOB_VENDOR
	IF(@has_already_records = 1)
	BEGIN
		select B.id as activity_id, B.description as display_name, A.issued_qty, A.normal_qty, C.Normal_Rate AS normal_rate, A.ot_qty, C.OT_Rate as ot_rate, D.id as vas_activity_rate_hdr_id, A.activity_type, FORMAT(D.Effective_Start_Date, 'dd/MM/yyyy ') AS date_from, FORMAT(D.Effective_End_Date, 'dd/MM/yyyy ') AS date_to,@prd_code_records AS prd_code, @vendor_id_records AS vendor_id
		from [TBL_ADM_JOB_VENDOR] A WITH(NOLOCK)
		inner join [TBL_MST_ACTIVITY_LISTING] B WITH(NOLOCK) ON B.id = A.vas_activity_id
		inner join [TBL_MST_VAS_ACTIVITY_RATE_DTL] C WITH(NOLOCK) ON B.id = C.VAS_Activity_ID
		inner join [TBL_MST_VAS_ACTIVITY_RATE_HDR] D WITH(NOLOCK) ON C.VAS_Activity_Rate_HDR_ID = D.ID		
		where @jobCreatedDate BETWEEN D.Effective_Start_Date AND D.Effective_End_Date and B.status = 1
		AND A.job_ref_no = @job_ref_no and A.prd_code = @prd_code
		order by A.activity_type desc
	END
	ELSE
	--Get standard vas activities and issued qty from SAP and ppm
	BEGIN
		CREATE TABLE #FINAL_SUM_VAS_ACTIVITY
		(
			id INT IDENTITY(1, 1),
			total_issued_qty decimal(18,2),
			display_name NVARCHAR(MAX)
		)
		
		CREATE TABLE #VAS_ACTIVITIES
			(
				id INT IDENTITY(1, 1),
				activity NVARCHAR(MAX)
			)

		INSERT INTO #VAS_ACTIVITIES(activity)
		SELECT A.vas_activities
		FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
		INNER JOIN TBL_TXN_WORK_ORDER B ON A.mll_no = B.mll_no AND B.mll_no = A.mll_no
		WHERE B.job_ref_no = @job_ref_no 
		AND A.mll_no = @mll_no
		AND A.prd_code = @prd_code
		GROUP BY A.vas_activities

		DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES WITH(NOLOCK))
		DECLARE @i INT = 0
		DECLARE @json_activities NVARCHAR(MAX) = ''

		CREATE TABLE #DETAIL_ACTIVITIES
		(
			display_name NVARCHAR(250),
			prd_code VARCHAR(50),
			page_dtl_id INT,
			radio_val CHAR(1)
		)

		WHILE (@i <= @count)
		BEGIN
			SET @json_activities = (SELECT activity FROM #VAS_ACTIVITIES WHERE id = @i)

			--PRINT @json_activities-

			INSERT INTO #DETAIL_ACTIVITIES(prd_code, page_dtl_id, radio_val)
			SELECT * FROM OPENJSON ( @json_activities ) 
			WITH (
				prd_code	VARCHAR(50)	'$.prd_code',  
				page_dtl_id	INT			'$.page_dtl_id',  
				radio_val	CHAR(1)		'$.radio_val'
			)
			WHERE radio_val = 'Y'
			SET @i += 1
		END

		UPDATE A
		SET display_name = B.display_name
		FROM #DETAIL_ACTIVITIES A WITH(NOLOCK), VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)
		WHERE A.page_dtl_id = B.page_dtl_id AND B.country_code='TH'

		SELECT display_name,cs.value AS prd_code, page_dtl_id, CONVERT(int,0) total_issued_qty
		INTO #FINAL_VAS_ACTIVITY
		FROM #DETAIL_ACTIVITIES
		WITH(NOLOCK)
		CROSS APPLY STRING_SPLIT (prd_code, ',') cs
		GROUP BY display_name, cs.value, page_dtl_id

		--get issue qty from submitted SAP
		UPDATE A
		SET A.total_issued_qty = B.completed_qty
		FROM #FINAL_VAS_ACTIVITY A
		INNER JOIN [TBL_TXN_JOB_EVENT] B ON B.job_ref_no = @job_ref_no
		where running_no in (select top 1 running_no from [TBL_TXN_JOB_EVENT] where event_id IN ('80') and job_ref_no = @job_ref_no order by running_no desc)
		
		DECLARE @ttl_qty_eaches int = 0, @prd_count int = 1

		SELECT top 1 @ttl_qty_eaches = completed_qty FROM TBL_TXN_JOB_EVENT where job_ref_no = @job_ref_no order by running_no desc

		SELECT @prd_count = COUNT(distinct prd_code) FROM TBL_TXN_PPM where job_ref_no = @job_ref_no
		
		--add sum of ppm issued qty
		SELECT (@ttl_qty_eaches - ((B.required_qty - B.issued_qty)/@prd_count)) as issued_qty, B.prd_code
		INTO #PPM_QTY
		FROM #FINAL_VAS_ACTIVITY A
		INNER JOIN TBL_TXN_PPM B ON A.prd_code = B.prd_code AND B.job_ref_no = @job_ref_no
		
		--total sum of ppm and issue qty
		update A
		set total_issued_qty = issued_qty
		FROM #FINAL_VAS_ACTIVITY A 
		INNER JOIN #PPM_QTY B ON A.prd_code = B.prd_code
		
		DROP TABLE #PPM_QTY
		
		INSERT INTO #FINAL_SUM_VAS_ACTIVITY (total_issued_qty, display_name)
		SELECT convert(decimal(18,2), sum(total_issued_qty)) as total_issued_qty, display_name		
		FROM #FINAL_VAS_ACTIVITY
		GROUP BY display_name

		SELECT D.id as activity_id, A.display_name, total_issued_qty AS issued_qty, total_issued_qty AS normal_qty, B.Normal_Rate AS normal_rate, 0.00 AS ot_qty, B.OT_Rate AS ot_rate, C.id as vas_activity_rate_hdr_id, D.type as activity_type, FORMAT(C.Effective_Start_Date, 'dd/MM/yyyy ') AS date_from, FORMAT(C.Effective_End_Date, 'dd/MM/yyyy ') AS date_to, @prd_code_records AS prd_code, @vendor_id_records AS vendor_id
		FROM #FINAL_SUM_VAS_ACTIVITY A
		inner join [TBL_MST_ACTIVITY_LISTING] D WITH(NOLOCK) ON A.display_name = D.description
		inner join [TBL_MST_VAS_ACTIVITY_RATE_DTL] B WITH(NOLOCK) ON D.id = B.VAS_Activity_ID
		inner join [TBL_MST_VAS_ACTIVITY_RATE_HDR] C WITH(NOLOCK) ON B.VAS_Activity_Rate_HDR_ID = C.ID
		where @jobCreatedDate BETWEEN C.Effective_Start_Date AND C.Effective_End_Date and D.status = 1 and D.type = 'Standard'

		DROP TABLE #VAS_ACTIVITIES
		DROP TABLE #DETAIL_ACTIVITIES
		DROP TABLE #FINAL_VAS_ACTIVITY
		DROP TABLE #FINAL_SUM_VAS_ACTIVITY
	END
END
GO
