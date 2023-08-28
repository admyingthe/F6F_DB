SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve Work Order informations
-- Example Query: exec SPP_TXN_WORK_ORDER_DTL @param=N'{"job_ref_no":"2018/06/0015"}',@user_id=1
-- ==========================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_DTL]
	@param	NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @job_ref_no VARCHAR(50), @json_activities NVARCHAR(MAX)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))

	SELECT A.work_ord_ref, A.vas_order, A.prd_code, B.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, A.ttl_qty_eaches, 
	CONVERT(VARCHAR(23), A.arrival_date, 121) as arrival_date, A.inbound_doc as sub_con_no, A.client_code, C.client_name, A.to_no, CASE F.name WHEN 'Cancelled' THEN F.name + ' (' + cancellation_reason + ')' ELSE F.name END as work_ord_status, 
	A.mll_no, mll_desc, E.name as storage_cond, ISNULL(H.name,'NA') as medical_device_usage,ISNULL(I.name,'NA') as bm_ifu,D.remarks, vas_activities, job_ref_no, RTRIM(urgent) as urgent, 
	CONVERT(VARCHAR(10),commencement_date,121) as commencement_date, CONVERT(VARCHAR(10),completion_date,121) as completion_date, 
	qty_of_goods, num_of_days_to_complete, others, ISNULL(client_ref_no,'') as client_ref_no, ISNULL(revision_no, '') as revision_no
	INTO #WORK_ORDER
	FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
	INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code
	INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON A.client_code = C.client_code
	INNER JOIN TBL_MST_MLL_DTL D WITH(NOLOCK) ON A.mll_no = D.mll_no AND A.prd_code = D.prd_code
	LEFT JOIN TBL_MST_DDL E WITH(NOLOCK) ON D.storage_cond = E.code
	LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.work_ord_status = F.code
	LEFT JOIN TBL_MST_DDL H WITH(NOLOCK) ON D.medical_device_usage = H.code and H.ddl_code='ddlMedicalDeviceUsage'
	LEFT JOIN TBL_MST_DDL I WITH(NOLOCK) ON D.bm_ifu = I.code and I.ddl_code='ddlBMIFU'
	INNER JOIN TBL_MST_MLL_HDR G WITH(NOLOCK) ON A.mll_no = G.mll_no
	WHERE job_ref_no = @job_ref_no AND F.ddl_code = 'ddlWorkOrderStatus'

	SET @json_activities = (SELECT vas_activities FROM #WORK_ORDER)
	SELECT IDENTITY(INT, 1, 1) AS row_id, CAST(NULL AS NVARCHAR(250)) as display_name, * INTO #VAS_ACTIVITIES FROM OPENJSON ( @json_activities )  
	WITH (
		prd_code	VARCHAR(50)	'$.prd_code',  
		page_dtl_id	INT			'$.page_dtl_id',  
		radio_val	CHAR(1)		'$.radio_val'
	)
	WHERE radio_val = 'Y'

	UPDATE A
	SET display_name = B.display_name
	FROM #VAS_ACTIVITIES A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)
	WHERE A.page_dtl_id = B.page_dtl_id

	DECLARE @vas_html NVARCHAR(MAX) = ''
	DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES), @i INT = 1
	
	WHILE @i <= @count
	BEGIN
		SET @vas_html += (SELECT CAST(@i as VARCHAR(100)) + '. ' + prd_code + ' ' + CASE WHEN radio_val = '' THEN '' ELSE + '(' + radio_val  + ')' END + ' - ' + display_name FROM #VAS_ACTIVITIES WHERE row_id = @i)

		IF (@i != @count) SET @vas_html = @vas_html + '<br />'
		ELSE SET @vas_html = @vas_html + ' '
		SET @i = @i + 1
	END
	
	UPDATE #WORK_ORDER SET vas_activities = @vas_html

	SELECT * FROM #WORK_ORDER
	DROP TABLE #WORK_ORDER
	DROP TABLE #VAS_ACTIVITIES
END
GO
