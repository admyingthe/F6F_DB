SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================      
-- Author:  LE TIEN DUNG
-- Create date: 2022-12-09
-- Description: Get Vendor in PPM
-- Example Query: EXEC SPP_GET_VENDOR_INFO @param=N'{"job_ref_no":"V2022/11/00004"}'
-- OUTPUT:
--- 1: dtData: Table Data for MPO
--- 2: dtSectionA: Data for the missing one in section A
--- 3: dt: UI code for section-b and section-c
-- ======================================================================== 

CREATE  PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_PRINT]
	@param nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @job_ref_no VARCHAR(50), @json_activities NVARCHAR(MAX)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))

	SELECT DISTINCT A.work_ord_ref, 
	A.job_ref_no, 
	concat(D.mll_desc, ' - ', D.revision_no) as qas_rev_no,
	CAST('' AS NVARCHAR(MAX)) AS work_ord_format,
	C.client_name, 
	H.user_name AS mpo_created_by ,
	--CONVERT(VARCHAR(19), A.created_date, 121) AS mpo_created_date,
	--ISNULL(CONVERT(VARCHAR(19),	K.commencement_date, 121),'') AS commencement_date, 
	--ISNULL(CONVERT(VARCHAR(19),K.completion_date, 121),'') AS completion_date,
	CASE
		WHEN A.created_date IS NULL THEN ''
		ELSE FORMAT (A.created_date, 'dd/MM/yyyy HH:mm:ss') 
	END AS mpo_created_date,
	CASE
		WHEN K.commencement_date IS NULL THEN ''
		ELSE FORMAT (K.commencement_date, 'dd/MM/yyyy HH:mm:ss') 
	END AS commencement_date,
	CASE
		WHEN K.completion_date IS NULL THEN ''
		ELSE FORMAT (K.completion_date, 'dd/MM/yyyy HH:mm:ss') 
	END AS completion_date,
	K.qty_of_goods,
	ISNULL(K.num_of_days_to_complete, '') AS num_of_days_to_complete,
	A.others, 
	CAST('' AS NVARCHAR(200)) AS mock_sample_created_by, 
	CAST('' AS NVARCHAR(200)) AS mock_sample_created_date,
	CAST('' AS NVARCHAR(200)) AS station_no,
	ISNULL(K.ques_a, '') AS ques_a,
	ISNULL(K.ques_b, '') AS ques_b,
	ISNULL(K.ques_c, '') AS ques_c,
	ISNULL(K.ques_d, '') AS ques_d,
	CAST(NULL AS NVARCHAR(200)) AS qa_created_by, 
	CAST(NULL AS NVARCHAR(200)) AS qa_created_date,
	CAST(NULL AS NVARCHAR(200)) AS vas_created_by, 
	CAST(NULL AS NVARCHAR(200)) AS vas_created_date,
	CAST('' AS NVARCHAR(MAX)) AS vas_activities
	--CAST('' AS NVARCHAR(MAX)) AS body_table_format
	INTO #WORK_ORDER
	FROM TBL_TXN_WORK_ORDER A WITH (NOLOCK)
	INNER JOIN TBL_MST_PRODUCT B WITH (NOLOCK) ON A.prd_code = B.prd_code
	INNER JOIN TBL_MST_CLIENT C WITH (NOLOCK) ON A.client_code = C.client_code
	INNER JOIN TBL_MST_MLL_HDR D WITH (NOLOCK) ON A.mll_no = D.mll_no
	INNER JOIN VAS.dbo.TBL_ADM_USER H WITH(NOLOCK) ON A.creator_user_id = H.user_id
	INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET K WITH (NOLOCK) ON A.job_ref_no = K.job_ref_no
	LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON K.work_ord_status = F.code
	WHERE A.job_ref_no = @job_ref_no AND F.ddl_code = 'ddlWorkOrderStatus'


	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
	Declare @running_no as varchar(50)
	SELECT TOP 1 @running_no = running_no FROM TBL_TXN_JOB_EVENT
	WHERE job_ref_no = @job_ref_no
	AND event_id = '80'
	ORDER BY created_date DESC

	SELECT job_ref_no, prd_code,sum(damaged_qty) AS damaged_qty,batch_no,inbound_doc,to_no
	INTO #Temp_damage_qty
	FROM TBL_TXN_JOB_EVENT_DET
	WHERE job_ref_no = @job_ref_no
	GROUP BY job_ref_no,prd_code,batch_no,inbound_doc,to_no

	SELECT IDENTITY(INT, 1, 1) AS row_num,
	A.prd_code AS prd_code,
	B.prd_desc AS prd_name,
	A.batch_no AS batch_no,
	CASE
		WHEN A.expiry_date IS NULL THEN ''
		ELSE FORMAT (A.expiry_date, 'dd/MM/yyyy HH:mm:ss') 
	END AS expiry_date,
	--ISNULL(CONVERT(VARCHAR(10),A.expiry_date, 121), '')  AS expiry_date,
	SUM(ISNULL(A.ttl_qty_eaches,0) )AS total_quantity,
	A.uom AS base_uom,
	CASE
		WHEN A.arrival_date IS NULL THEN ''
		ELSE FORMAT (A.arrival_date, 'dd/MM/yyyy HH:mm:ss') 
	END AS arrival_date,
	--ISNULL(CONVERT(VARCHAR(19),A.arrival_date, 121), '')  AS arrival_date,
	A.inbound_doc as sub_con_no,
	ISNULL(D.ppm_by,'NA') as ppm_by,
	CONVERT(NVARCHAR(10), ISNULL(J.damaged_qty,0)) AS damaged_qty,
	CONVERT(NVARCHAR(10), ISNULL(H.completed_qty,0)) AS completed_qty
	INTO #SECTIONA_TABLE_DETAIL
	FROM TBL_TXN_WORK_ORDER A WITH (NOLOCK)
	LEFT JOIN TBL_MST_PRODUCT B WITH (NOLOCK) ON A.prd_code = B.prd_code
	LEFT JOIN TBL_MST_MLL_DTL D WITH(NOLOCK) ON A.mll_no = D.mll_no AND A.prd_code = D.prd_code
	LEFT JOIN TBL_TXN_WORK_ORDER_JOB_DET K WITH (NOLOCK) ON A.job_ref_no = K.job_ref_no
	LEFT JOIN (SELECT * FROM TBL_TXN_JOB_EVENT_DET WITH (NOLOCK) WHERE running_no = @running_no) H  ON A.job_ref_no = H.job_ref_no  AND A.prd_code = H.prd_code   AND A.inbound_doc = H.inbound_doc   AND A.to_no = H.to_no
	LEFT JOIN #Temp_damage_qty J WITH (NOLOCK) ON A.job_ref_no = J.job_ref_no AND A.prd_code = J.prd_code  AND A.batch_no = J.batch_no AND A.inbound_doc = J.inbound_doc AND A.to_no = J.to_no
	WHERE A.job_ref_no =  @job_ref_no
	GROUP BY A.prd_code, B.prd_desc, A.batch_no, A.expiry_date, A.uom, A.arrival_date, A.inbound_doc, D.ppm_by, J.damaged_qty, H.completed_qty
	

	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------

	DECLARE @job_format_code NVARCHAR(50) = ''
	SET @job_format_code = (SELECT format_code FROM [dbo].[TBL_REDRESSING_JOB_FORMAT])

	UPDATE #WORK_ORDER
	SET work_ord_format = CASE 
	WHEN @job_format_code = 'ClientFormat' 
	THEN '<span>MPO Reference (Agency/Product/Batch/Expiry) : </span><span>'+ work_ord_ref +'</span>'
	--'<span style="font-size: 14px; font-family:arial">MPO Reference (Agency/Product/Batch/Expiry) : </span>'
	--	+ '<span style="font-size: 14px; font-weight:bold; font-family:arial">' + work_ord_ref + '</span>'
	WHEN @job_format_code = 'JobFormat'
	THEN 
	'<section id="mpo-reference">
		<table style="width:100%">
			<tr>
				<th style="text-align:left; padding: 15px; width:50%"><span>MPO Reference (Job Reference No) : </span><span>'+ job_ref_no +'</span></th>
				<th style="text-align:left; padding: 15px; width:50%"><span>QAS No : </span><span>'+ qas_rev_no +'</span></th>
			</tr>
		</table>
	</section>'
	--'<span style="font-size: 14px; font-family:arial">MPO Reference (Job Reference No) : </span>'
	--	+ '<span style="font-size: 14px; font-weight:bold; font-family:arial">' + job_ref_no + '</span>'
	ELSE ''
	END

	UPDATE #WORK_ORDER
	SET qa_created_by = B.user_name,
		qa_created_date = 
		CASE 
			WHEN A.created_date IS NULL THEN ''
			ELSE FORMAT (A.created_date, 'dd/MM/yyyy HH:mm:ss') 
		END
	--CONVERT(VARCHAR(10), A.created_date,121)
	FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id
	WHERE A.job_ref_no = @job_ref_no AND event_id IN ('50', '60')

	UPDATE #WORK_ORDER
	SET vas_created_by = B.user_name,
		vas_created_date = 
		CASE 
			WHEN A.created_date IS NULL THEN ''
			ELSE FORMAT (A.created_date, 'dd/MM/yyyy HH:mm:ss') 
		END
	--CONVERT(VARCHAR(10), A.created_date,121)
	FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id 
	WHERE A.job_ref_no = @job_ref_no AND event_id = '40'

	UPDATE #WORK_ORDER
	SET mock_sample_created_by = B.user_name,
		mock_sample_created_date = 
		CASE 
			WHEN A.created_date IS NULL THEN ''
			ELSE FORMAT (A.created_date, 'dd/MM/yyyy HH:mm:ss') 
		END
	--CONVERT(VARCHAR(10), A.created_date,121)
	FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id 
	WHERE A.job_ref_no = @job_ref_no AND event_id = '30'

	UPDATE #WORK_ORDER
	SET station_no = ISNULL(CONVERT(VARCHAR(10),(SELECT DISTINCT station_no FROM TBL_TXN_JOB_EVENT WITH (NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id='30')), '')
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------OLD Code to get VAS activities --------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--SET @json_activities = (SELECT TOP 1 D.vas_activities FROM TBL_TXN_WORK_ORDER A
	--		INNER JOIN TBL_MST_MLL_DTL D WITH(NOLOCK) ON A.mll_no = D.mll_no AND A.prd_code = D.prd_code
	--		WHERE A.job_ref_no = @job_ref_no)

	--SELECT IDENTITY(INT, 1, 1) AS row_id, CAST(NULL AS NVARCHAR(250)) as display_name, * INTO #VAS_ACTIVITIES FROM OPENJSON ( @json_activities )  
	--WITH (
	--	prd_code	VARCHAR(50)	'$.prd_code',  
	--	page_dtl_id	INT			'$.page_dtl_id',  
	--	radio_val	CHAR(1)		'$.radio_val'
	--)
	--WHERE radio_val = 'Y'

	--UPDATE A
	--SET display_name = B.display_name
	--FROM #VAS_ACTIVITIES A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)
	--WHERE A.page_dtl_id = B.page_dtl_id  AND B.country_code='TH'

	--DECLARE @vas_html NVARCHAR(MAX) = ''
	--DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES), @i INT = 1,@prd_code VARCHAR(50)
	
	--WHILE @i <= @count
	--BEGIN
	--	SET @vas_html += (SELECT CAST(@i as VARCHAR(100)) + '. ' + prd_code + ' ' + CASE WHEN radio_val = '' THEN '' ELSE + '(' + radio_val  + ')' END + ' - ' + display_name FROM #VAS_ACTIVITIES WHERE row_id = @i)

	--	IF (@i != @count) SET @vas_html = @vas_html + '<br />'
	--	ELSE SET @vas_html = @vas_html + ' '
	--	SET @i = @i + 1
	--END


	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------Current Code to get VAS activities --------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	

	

	SELECT  DISTINCT prd_code, IDENTITY(INT, 1, 1) AS row_id INTO #TEMPPRODUCT FROM TBL_TXN_WORK_ORDER  WHERE job_ref_no = @job_ref_no
--GROUP BY prd_code


	CREATE TABLE #VAS_ACTIVITIES(
	row_id INT identity,
	prd_code	VARCHAR(50)	,
	page_dtl_id	INT			,
	radio_val	CHAR(1)		,
	display_name VARCHAR(500)	
	)

	

	DECLARE @countproduct INT = (SELECT  COUNT( DISTINCT prd_code) FROM TBL_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no), @i INT = 1, @prd_code VARCHAR(50)
	
	WHILE @i <= @countproduct
	BEGIN
		SELECT @prd_code=prd_code FROM #TEMPPRODUCT WHERE row_id=@i

		SET @json_activities = (SELECT TOP 1 D.vas_activities FROM TBL_TXN_WORK_ORDER A
			INNER JOIN TBL_MST_MLL_DTL D WITH(NOLOCK) ON A.mll_no = D.mll_no AND A.prd_code = D.prd_code
			WHERE A.job_ref_no = @job_ref_no AND A.prd_code=@prd_code)

			--PRINT @json_activities

	SELECT IDENTITY(INT, 1, 1) AS row_id, CAST(NULL AS NVARCHAR(250)) as display_name, * INTO #TEMP_VAS_ACTIVITIES FROM OPENJSON ( @json_activities )  
	WITH (
		prd_code	VARCHAR(50)	'$.prd_code',  
		page_dtl_id	INT			'$.page_dtl_id',  
		radio_val	CHAR(1)		'$.radio_val'
	)
	WHERE radio_val = 'Y'

	

	INSERT INTO #VAS_ACTIVITIES(prd_code,page_dtl_id,radio_val)
	SELECT Distinct prd_code,page_dtl_id,radio_val FROM #TEMP_VAS_ACTIVITIES
	WHERE Convert(varchar(100), prd_code)+Convert(varchar(100), page_dtl_id)+radio_val not in (SELECT Convert(varchar(100), prd_code)+Convert(varchar(100), page_dtl_id)+radio_val FROM #VAS_ACTIVITIES)

	DROP TABLE #TEMP_VAS_ACTIVITIES


	SET @i = @i + 1
	END

	UPDATE A
	SET display_name = B.display_name
	FROM #VAS_ACTIVITIES A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)
	WHERE A.page_dtl_id = B.page_dtl_id  AND B.country_code='TH'

	DECLARE @vas_html NVARCHAR(MAX) = ''
	DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES)
	SET @i = 1
	WHILE @i <= @count
	BEGIN
		SET @vas_html += (SELECT CAST(@i as VARCHAR(100)) + '. ' + prd_code + ' ' + CASE WHEN radio_val = '' THEN '' ELSE + '(' + radio_val  + ')' END + ' - ' + display_name FROM #VAS_ACTIVITIES WHERE row_id = @i)

		IF (@i != @count) SET @vas_html = @vas_html + '<br />'
		ELSE SET @vas_html = @vas_html + ' '
		SET @i = @i + 1
	END
	DROP table #TEMPPRODUCT
	
		


		
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------Current Code to get VAS activities --------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------



	
	UPDATE #WORK_ORDER SET vas_activities = @vas_html + '<br />' + others

	--DECLARE @body_table_html NVARCHAR(MAX) = ''
	--DECLARE  @prd_name NVARCHAR(200), @batch_no NVARCHAR(20), @expiry_date NVARCHAR(50), @total_quantity NVARCHAR(10), @base_uom NVARCHAR(10), @arrival_date NVARCHAR(50), @sub_con_no NVARCHAR(50), @ppm_by NVARCHAR(10),
	--@damaged_qty NVARCHAR(10), @complete_qty NVARCHAR(10)
	--SET @prd_code =''
	--SET @i = 1
	--SELECT @count = COUNT(*) FROM #SECTIONA_TABLE_DETAIL

	--WHILE @i <= @count
	--BEGIN
	--	SELECT @prd_code = prd_code,
	--	@prd_name = prd_name,
	--	@batch_no = batch_no,
	--	@expiry_date = expiry_date,
	--	@total_quantity = total_quantity,
	--	@base_uom = base_uom,
	--	@arrival_date = arrival_date,
	--	@sub_con_no = sub_con_no,
	--	@ppm_by = ppm_by,
	--	@damaged_qty = damaged_qty,
	--	@complete_qty = completed_qty
	--	FROM #SECTIONA_TABLE_DETAIL
	--	WITH (NOLOCK)
	--	WHERE row_num = @i

	--	SET @body_table_html += '<tr>'
	--							+ '<td>' + CAST(@i AS NVARCHAR(10)) + '</td>'
	--							+ '<td>' + @prd_code +'</td>'
	--							+ '<td>' + @prd_name +'</td>'
	--							+ '<td>' + @batch_no +'</td>'
	--							+ '<td>' + @expiry_date +'</td>'
	--							+ '<td>' + @total_quantity +'</td>'
	--							+ '<td>' + @base_uom +'</td>'
	--							+ '<td>' + @arrival_date +'</td>'
	--							+ '<td>' + @sub_con_no +'</td>'
	--							+ '<td>' + @ppm_by +'</td>'
	--							+ '<td>' + @damaged_qty +'</td>'
	--							+ '<td>' + @complete_qty +'</td>'
	--							+ '</tr>'

	--	SET @i += 1
	--END

	--UPDATE #WORK_ORDER SET body_table_format = @body_table_html

	--DECLARE @section_a nvarchar(max), 
	DECLARE @section_b nvarchar(max), @section_c nvarchar(max), @section_d nvarchar(max), @my_hec_mpo_sop VARCHAR(50), @my_hec_mpo_form_control VARCHAR(50), @my_hec_mpo_form_control_date VARCHAR(50)

	SET @my_hec_mpo_sop = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_MPO_SOP')
	SET @my_hec_mpo_form_control = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_MPO_FORM_CONTROL')
	SET @my_hec_mpo_form_control_date = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_MPO_FORM_CONTROL_DATE')

	DECLARE @client_name NVARCHAR(50) = (SELECT client_name FROM #WORK_ORDER)
	DECLARE @station_no NVARCHAR(50) = (SELECT station_no FROM #WORK_ORDER)
	DECLARE @mpo_created_by_and_date NVARCHAR(50) = ( SELECT mpo_created_by + ', ' + ISNULL(mpo_created_date,'') FROM #WORK_ORDER)
	DECLARE @work_ord_format NVARCHAR(MAX) = (SELECT work_ord_format FROM #WORK_ORDER)

	--SELECT @section_a = work_ord_format
	--					+ '<br /><br />'
	--					+ '<section id="section-a">
	--					  <h4>Section A : Information</h4>
	--					  <div class="display-grid">
	--						<span>(a) Client</span>
	--						<span>'+ client_name +'</span>
	--					  </div>
	--					  <table class="table-data">
	--						<thead>
	--						  <tr>
	--							<td>No.</td>
	--							<td>Product Code</td>
	--							<td>Product Name</td>
	--							<td>Batch No.</td>
	--							<td>Expiry Date</td>
	--							<td>Total Quantity</td>
	--							<td>UOM</td>
	--							<td>Arrival Date</td>
	--							<td>GR/IR/Sub Con No</td>
	--							<td>PPM By</td>
	--							<td>Damaged Qty</td>
	--							<td>Completed Qty</td>
	--						  </tr>
	--						</thead>
	--						<tbody>' + body_table_format + '</tbody>
	--					  </table>
	--					  <div class="display-grid">
	--						<span>Station No.</span>
	--						<span>' + station_no + '</span>
	--					  </div>
	--					  <br />
	--					  <hr />
	--					  <div class="display-grid name-and-date-mpo">
	--						<span>Name & Date of staff filling this section</span>
	--						<span>' + mpo_created_by + ', ' + ISNULL(mpo_created_date,'') + '</span>
	--					  </div>
	--					</section><br/>'
	--FROM #WORK_ORDER

	SELECT @section_b = '<section id="section-b">
						  <h4>Section B : Job Authorization</h4>
						  <div class="display-grid" style="margin-top: -2rem; margin-bottom: -1rem">
							<span>(a) Job Authorization Reference Number</span>
							<span><svg id="barcode"></svg></span>
						  </div>
						  <br><br>
						  <div class="display-grid">
							<span>(b) Date of commencement of production</span>
							<span>'+ ISNULL(commencement_date,'') +'</span>
						  </div>
						  <div class="display-grid">
							<span>(c) Date of completion of production</span>
							<span>'+ ISNULL(completion_date,'') + '</span>
						  </div>
						  <div class="display-grid">
							<span>(d) Quantity of Redressing</span>
							<span>'+ ISNULL(CAST(qty_of_goods as varchar(100)), '') +'</span>
						  </div>
						  <div class="display-grid">
							<span>(e) Number of days takes to complete</span>
							<span>'+ ISNULL(CAST(num_of_days_to_complete as varchar(100)), '') +'</span>
						  </div>
						  <div class="display-grid">
							<span>(f) Type of redressing activities</span>
							<span>'+ vas_activities +'</span>
						  </div>
						  <br />
						  <hr />
						  <div class="display-grid name-and-date-mpo">
							<span>Name & Date of staff filling this section</span>
							<span>' + ISNULL(vas_created_by,'') + ', ' + ISNULL(vas_created_date,'') + '</span>
						  </div>
						</section><br/>'
	FROM #WORK_ORDER

	SELECT @section_c = '<section id="section-c">
						  <h4>Section C : Release Authorization Checklist</h4>
						  <p>Checklist for Line Clearance</p>
						  <div>
							<div><input type="checkbox" /> Line clearance</div>
							<div><input type="checkbox" /> Material sample</div>
							<div><input type="checkbox" /> QTY of PPM</div>
							<div><input type="checkbox" /> Line Leader inspection</div>
						  </div>
						  <br />
						  <hr />
						  <p>Name & Date of staff filling this section</p>
						</section>
						<br />'
	FROM #WORK_ORDER

	SELECT * FROM #SECTIONA_TABLE_DETAIL

	SELECT @work_ord_format AS work_ord_format, @client_name AS client_name,  @station_no AS station_no, @mpo_created_by_and_date As mpo_created_by_and_date

	
	SELECT 
	--ISNULL(@section_a,'') as section_a, 
	ISNULL(@section_b,'') as section_b, 
	ISNULL(@section_c,'') as section_c
	--, ISNULL(@section_d,'') as section_d
	

	DROP TABLE #WORK_ORDER
	DROP TABLE #VAS_ACTIVITIES
	DROP TABLE #SECTIONA_TABLE_DETAIL
END




/****** Object:  StoredProcedure [dbo].[SPP_TXN_WORK_ORDER_PPM_INFO_PRINT]    Script Date: 12/27/2022 5:52:51 PM ******/
SET ANSI_NULLS ON
GO
