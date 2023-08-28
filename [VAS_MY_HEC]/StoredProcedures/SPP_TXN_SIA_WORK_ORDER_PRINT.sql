SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve Work Order Listing
-- Example Query: exec SPP_TXN_WORK_ORDER_PRINT @param=N'{"job_ref_no":"2018/10/0013"}'
-- ====================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_SIA_WORK_ORDER_PRINT]
	@param nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @job_ref_no VARCHAR(50), @json_activities NVARCHAR(MAX)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))

	SELECT A.work_ord_ref, A.vas_order, A.prd_code, B.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, A.ttl_qty_eaches, 
	CONVERT(VARCHAR(23), A.arrival_date, 121) as arrival_date, A.inbound_doc as sub_con_no, A.client_code, C.client_name, A.to_no, F.name as work_ord_status, 
	A.mll_no, E.name as storage_cond, D.remarks, ISNULL(vas_activities, '') as vas_activities, job_ref_no, RTRIM(urgent) as urgent, 
	ISNULL(CONVERT(VARCHAR(10),commencement_date,121),'') as commencement_date, ISNULL(CONVERT(VARCHAR(10),completion_date,121),'') as completion_date, 
	qty_of_goods, ISNULL(num_of_days_to_complete, '') as num_of_days_to_complete, others, ISNULL(client_ref_no,'') as client_ref_no, ISNULL(revision_no, '') as revision_no, 
	CONVERT(VARCHAR(19), start_date, 121) as start_date, CONVERT(VARCHAR(19), end_date, 121) as end_date, A.creator_user_id, H.user_name as mpo_created_by, CONVERT(VARCHAR(19), A.created_date, 121) as mpo_created_date,
	CAST(NULL as NVARCHAR(200)) as vas_created_by, CAST(NULL as NVARCHAR(200)) as vas_created_date, CAST(NULL as NVARCHAR(200)) as mock_sample_created_by, CAST(NULL as NVARCHAR(200)) as mock_sample_created_date, ques_a, ques_b, ques_c, ques_d,
	CAST(NULL as NVARCHAR(200)) as qa_created_by, CAST(NULL as NVARCHAR(200)) as qa_created_date ,ISNULL(I.name,'NA') as medical_device_usage,ISNULL(J.name,'NA') as bm_ifu
	INTO #WORK_ORDER
	FROM TBL_SIA_TXN_WORK_ORDER A WITH(NOLOCK)
	INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code
	INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON A.client_code = C.client_code
	INNER JOIN TBL_MST_MLL_DTL D WITH(NOLOCK) ON A.mll_no = D.mll_no AND A.prd_code = D.prd_code
	LEFT JOIN TBL_MST_DDL E WITH(NOLOCK) ON D.storage_cond = E.code
	LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.work_ord_status = F.code
	INNER JOIN TBL_MST_MLL_HDR G WITH(NOLOCK) ON A.mll_no = G.mll_no
	INNER JOIN VAS.dbo.TBL_ADM_USER H WITH(NOLOCK) ON A.creator_user_id = H.user_id
	LEFT JOIN TBL_MST_DDL I WITH(NOLOCK) ON D.medical_device_usage = I.code and I.ddl_code='ddlMedicalDeviceUsage'
	LEFT JOIN TBL_MST_DDL J WITH(NOLOCK) ON D.bm_ifu = J.code and J.ddl_code='ddlBMIFU'
	WHERE job_ref_no = @job_ref_no AND F.ddl_code = 'ddlWorkOrderStatus'

	UPDATE #WORK_ORDER
	SET qa_created_by = B.user_name,
		qa_created_date = CONVERT(VARCHAR(10), A.created_date,121)
	FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id
	WHERE A.job_ref_no = @job_ref_no AND event_id IN ('50', '60')

	UPDATE #WORK_ORDER
	SET vas_created_by = B.user_name,
		vas_created_date = CONVERT(VARCHAR(10), A.created_date,121)
	FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id 
	WHERE A.job_ref_no = @job_ref_no AND event_id = '40'

	UPDATE #WORK_ORDER
	SET mock_sample_created_by = B.user_name,
		mock_sample_created_date = CONVERT(VARCHAR(10), A.created_date,121)
	FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id 
	WHERE A.job_ref_no = @job_ref_no AND event_id = '30'

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
	
	UPDATE #WORK_ORDER SET vas_activities = @vas_html + '<br />' + others

	DECLARE @section_a nvarchar(max), @section_b nvarchar(max), @section_c nvarchar(max), @section_d nvarchar(max), @my_hec_mpo_sop VARCHAR(50), @my_hec_mpo_form_control VARCHAR(50), @my_hec_mpo_form_control_date VARCHAR(50)
	--SELECT @section_a = '<div style="width:100%; height:20px"><h5>MASTER PACKAGING ORDER (MPO)</h5><img src="http://portal.dksh.com/vas_dev/images/logo_dksh.png" style="margin-top:5px; margin-right: 10px; height: 30px; position:absolute; top:0px; right:0px"/></div>'
	--			   + '<div style="width: 100%; height:20px;"><span style="font-size:12px;">SOP Ref: Relabelling, Redressing & Repackaging (RS 7)</span>'
	--			   + '<span style="font-size:12px; margin-top:10px; margin-right: 10px; height: 30px; position:absolute; top:30px; right:0px">' + mll_no + '(' + revision_no + ')' + '</span>'
	--			   + '<span style="font-size:12px; margin-top:10px; margin-right: 10px; height: 30px; position:absolute; top:50px; right:0px">Effective Date: ' + CONVERT(VARCHAR(10), start_date ,121) + '</span>'
	--			   + '</div><br /><br /><div style="width:100%; border:1px solid #EBEBEB; padding:5px">'
	--			   + '<span style="font-size: 14px">MPO Reference (Agency/Product/Batch/Expiry)</span> :<span style="font-size: 12px; font-weight:bold">' + work_ord_ref + '</span><br />'
	--			   + '<div style="width:95%; border: 1px solid lightgrey; padding:5px"><span style="font-size: 14px;font-weight:bold; text-decoration:underline;">Section A : Information</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(a) Agency </span> :<span style="font-size: 12px; font-weight:bold"> ' + client_name + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(b) Stock Code </span> :<span style="font-size: 12px; font-weight:bold"> ' + prd_code + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(c) Product Description (brief) </span> :<span style="font-size: 12px; font-weight:bold"> ' + prd_desc + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(d) Batch Reference </span> :<span style="font-size: 12px; font-weight:bold"> ' + batch_no + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(e) Expiry Date </span> :<span style="font-size: 12px; font-weight:bold"> ' + expiry_date + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(f) Total Quantity (in eaches) </span> :<span style="font-size: 12px; font-weight:bold"> ' + CAST(ttl_qty_eaches as varchar(100)) + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(g) Arrival Date </span> :<span style="font-size: 12px; font-weight:bold"> ' + arrival_date + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(h) GR/IR/Sub Con Number </span> :<span style="font-size: 12px; font-weight:bold"> ' + sub_con_no + '</span><hr />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">Name & Date of staff filling this section </span> :<span style="font-size: 12px; font-weight:bold"> ' + mpo_created_by + ', ' + mpo_created_date + '</span><br />'
	--FROM #WORK_ORDER

	--SELECT @section_b = '<div style="width:95%; border: 1px solid lightgrey; padding:5px"><span style="font-size: 14px;font-weight:bold; text-decoration:underline;">Section B : Job Authorization</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(a) Job Authorization Reference Number </span> :<svg id="barcode"></svg><br /><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(b) Date of commencement of production </span> :<span style="font-size: 12px; font-weight:bold"> ' + commencement_date + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(c) Date of completion of production </span> :<span style="font-size: 12px; font-weight:bold"> ' + completion_date + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(d) Quantities of goods for this production </span> :<span style="font-size: 12px; font-weight:bold"> ' + CAST(qty_of_goods as varchar(100)) + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(e) Number of days takes to complete </span> :<span style="font-size: 12px; font-weight:bold"> ' + CAST(num_of_days_to_complete as varchar(100)) + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">(f) Type of redressing activities </span> : <br />&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-size: 12px; font-weight:bold"><br /> ' + vas_activities + '</span><hr />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">Name & Date of staff filling this section </span> :<span style="font-size: 12px; font-weight:bold"> ' + ISNULL(vas_created_by,'') + ', ' + ISNULL(vas_created_date,'') + '</span><br />'
	--FROM #WORK_ORDER

	--SELECT @section_c = '<div style="width:95%; border: 1px solid lightgrey; padding:5px"><span style="font-size: 14px;font-weight:bold; text-decoration:underline;">Section C : Release Authorization Checklist</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:500px">(a) Section on packaging material requisition and reconciliation, line clearance and activity checklist attached</span>:<span style="font-size: 12px; font-weight:bold"> ' + CASE ques_a WHEN 'Y' THEN 'Yes' ELSE 'No' END + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:500px">(b) Sample of label, package insert, inkjet wording and other packaging materials attached </span> :<span style="font-size: 12px; font-weight:bold"> ' + CASE ques_b WHEN 'Y' THEN 'Yes' ELSE 'No' END + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:500px">(c) Copy of GR/IR or other relevant document reference attached </span> :<span style="font-size: 12px; font-weight:bold"> ' + CASE ques_c WHEN 'Y' THEN 'Yes' ELSE 'No' END + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:500px">(d) Temperature monitoring download released (if applicable) </span> :<span style="font-size: 12px; font-weight:bold"> ' + CASE ques_d WHEN 'Y' THEN 'Yes' ELSE 'No' END + '</span><hr />'
	--			   + '<span style="font-size:12px; display:inline-block; width:300px">Name & Date of staff filling this section </span> :<span style="font-size: 12px; font-weight:bold"> ' + ISNULL(mock_sample_created_by,'') + ', ' + ISNULL(mock_sample_created_date,'') + '</span><br />'
	--FROM #WORK_ORDER
	
	--SELECT @section_d = '<div style="width:95%; border: 1px solid lightgrey; padding:5px"><span style="font-size: 14px;font-weight:bold; text-decoration:underline;">Section D : Release Authorization</span><br /><div style="width:95%; padding:5px; border:1px solid grey">'
	--			   + '<span style="font-size:12px; display:inline-block; width:450px">(a) Checked and confirmed all documents and goods are in order and compliance </span> :<span style="font-size: 12px; font-weight:bold"></span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:450px"> Operation Executive/ Supervisor/ Manager </span> :<span style="font-size: 12px; font-weight:bold">' + ISNULL(vas_created_by,'') + ', ' + ISNULL(vas_created_date,'') + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:450px"> Approved for release by Quality Assurance Executive / Manager </span> :<span style="font-size: 12px; font-weight:bold">' + ISNULL(qa_created_by,'') + ', ' + ISNULL(qa_created_date,'') + '</span><br />'
	--			   + '<span style="font-size:12px; display:inline-block; width:450px"> Approved for release by Client / Supplier Quality Personnel (where applicable) </span> :<span style="font-size: 12px; font-weight:bold"></span><br /></div></div>'
	--			   + '</div>'
	--FROM #WORK_ORDER

	SET @my_hec_mpo_sop = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'MY_HEC_MPO_SOP')
	SET @my_hec_mpo_form_control = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'MY_HEC_MPO_FORM_CONTROL')
	SET @my_hec_mpo_form_control_date = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'MY_HEC_MPO_FORM_CONTROL_DATE')

	SELECT @section_a = '<div style="width:100%; height:20px"><h5>MASTER PACKAGING ORDER (MPO)</h5><img src="http://portal.dksh.com/vas_dev/images/logo_dksh.png" style="margin-top:5px; margin-right: 10px; height: 30px; position:absolute; top:0px; right:0px"/></div>'
					  + '<div style="width: 100%; height:20px; font-size:12px; font-family:arial">'
					  + '<span>SOP Ref: ' + @my_hec_mpo_sop + ' Relabelling, Redressing & Repackaging (RS 7)</span>'
					  --+ '<span style="margin-top:10px; margin-right: 10px; height: 30px; position:absolute; top:30px; right:0px">' + mll_no + '(' + revision_no + ')' + '</span>'
					  + '<span style="margin-top:8px; margin-right: 10px; height: 30px; position:absolute; top:30px; right:0px">' + @my_hec_mpo_form_control + '</span>'
					  + '<span style="margin-top:8px; margin-right: 10px; height: 30px; position:absolute; top:50px; right:0px">Effective Date: ' + @my_hec_mpo_form_control_date + '</span>'
					  + '</div><br/><br/>'
					  + '<span style="font-size: 14px; font-family:arial">MPO Reference (Agency/Product/Batch/Expiry) : </span>'
					  + '<span style="font-size: 14px; font-weight:bold; font-family:arial">' + work_ord_ref + '</span>'
					  + '<br/><br/>'
					  + '<table style="width: 100%;border:0.5pt solid lightgrey;border-collapse:collapse;"><tbody><tr><td>'
					  + '<table style="width: 100%;text-align:left; font-family:Arial; font-size:12px;padding:8px">'
					  + '<tr><th colspan="2" style="font-size:14px; text-decoration:underline">Section A : Information</th></tr>'
					  + '<tr><td colspan="2"></td></tr>'
					  + '<tr><td>(a) Agency</td><td>' + client_name + '</td></tr>'
					  + '<tr><td>(b) Stock Code</td><td>' + prd_code + '</td></tr>'
					  + '<tr><td>(c) Product Description (brief)</td><td>' + prd_desc + '</td></tr>'
					  + '<tr><td>(d) Batch Reference</td><td>' + batch_no + '</td></tr>'
					  + '<tr><td>(e) Expiry Date</td><td>' + expiry_date + '</td></tr>'
					  + '<tr><td>(f) Total Quantity (in eaches)</td><td>' + CAST(ttl_qty_eaches as varchar(100)) + '</td></tr>'
					  + '<tr><td>(g) Arrival Date</td><td>' + arrival_date + '</td></tr>'
					  + '<tr><td>(h) GR/IR/Sub Con Number</td><td>' + sub_con_no + '</td></tr>'
				 	  + '<tr><td>(i) Medical Device Usage</td><td>' + medical_device_usage + '</td></tr>'
					  + '<tr><td>(j) BM IFU</td><td>' + bm_ifu + '</td></tr>'
					  + '<tr><td colspan="2"><hr></td></tr>'
					  + '<tr><td>Name & Date of staff filling this section</td><td>' + mpo_created_by + ', ' + mpo_created_date + '</td></tr>'
					  + '</table>'
					  + '</td></tr></tbody></table><br/>'
	FROM #WORK_ORDER

	SELECT @section_b = '<table style="width: 100%;border:0.5pt solid lightgrey;border-collapse:collapse;"><tbody><tr><td>'
					  + '<table style="margin-top:6px; width: 100%; text-align:left; font-family:Arial; font-size:12px; padding:8px">'
					  + '<tr><th colspan="2" style="font-size:14px; text-decoration:underline">Section B : Job Authorization</th></tr>'
					  + '<tr><td colspan="2"></td></tr>'
					  + '<tr><td>(a) Job Authorization Reference Number</td><td><svg id="barcode"></svg></td></tr>'
					  + '<tr><td>(b) Date of commencement of production</td><td>' + commencement_date + '</td></tr>'
					  + '<tr><td>(c) Date of completion of production</td><td>' + completion_date + '</td></tr>'
					  + '<tr><td>(d) Quantities of goods for this production</td><td>' + CAST(qty_of_goods as varchar(100)) + '</td></tr>'
					  + '<tr><td>(e) Number of days takes to complete</td><td>' + CAST(num_of_days_to_complete as varchar(100)) + '</td></tr>'
					  + '<tr><td>(f) Type of redressing activities</td><td>' + vas_activities + '</td></tr>'
					  + '<tr><td colspan="2"><hr></td></tr>'
					  + '<tr><td>Name & Date of staff filling this section</td><td>' + ISNULL(vas_created_by,'') + ', ' + ISNULL(vas_created_date,'') + '</td></tr>'
					  + '</table>'
					  + '</td></tr></tbody></table><br/>'
	FROM #WORK_ORDER

	SELECT @section_c = '<table style="width: 100%;border:0.5pt solid lightgrey;border-collapse:collapse;"><tbody><tr><td>'
					  + '<table style="margin-top:6px; width: 100%; text-align:left; font-family:Arial; font-size:12px; padding:8px">'
					  + '<tr><th colspan="2" style="font-size:14px; text-decoration:underline">Section C : Release Authorization Checklist</th></tr>'
					  + '<tr><td colspan="2"></td></tr>'
					  + '<tr><td>(a) Section on packaging material requisition and reconciliation, line clearance and activity checklist attached</td><td>' + CASE ques_a WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '' END + '</td></tr>'
					  + '<tr><td>(b) Sample of label, package insert, inkjet wording and other packaging materials attached</td><td>' + CASE ques_b WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '' END + '</td></tr>'
					  + '<tr><td>(c) Copy of GR/IR or other relevant document reference attached</td><td>' + CASE ques_c WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '' END + '</td></tr>'
					  + '<tr><td>(d) Temperature monitoring download released(if applicable)</td><td>' + CASE ques_d WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '' END + '</td></tr>'
					  + '<tr><td colspan="2"><hr></td></tr>'
					  + '<tr><td>Name & Date of staff filling this section</td><td>' + ISNULL(mock_sample_created_by,'') + ', ' + ISNULL(mock_sample_created_date,'') + '</td></tr>'
					  + '</table>'
					  + '</td></tr></tbody></table><br/>'
	FROM #WORK_ORDER

	--SELECT @section_d = '<table style="margin-top:8px; width: 100%; border:0.5pt solid lightgrey; text-align:left; font-family:Arial; font-size:12px; padding:10px">'
	--				  + '<tr><th colspan="2" style="font-size:14px; text-decoration:underline">Section D : Release Authorization</th></tr>'
	--				  + '<tr><td colspan="2"></td></tr>'
	--				  + '<tr><td>(a) Checked and confirmed all documents and goods are in order and compliance</td><td></td></tr>'
	--				  + '<tr><td>Operation Executive/ Supervisor/ Manager</td><td>' + ISNULL(vas_created_by,'') + ', ' + ISNULL(vas_created_date,'') + '</td></tr>'
	--				  + '<tr><td>Approved for release by Quality Assurance / RRC Executive/ Manager</td><td>' + ISNULL(qa_created_by,'') + ', ' + ISNULL(qa_created_date,'') + '</td></tr>'
	--				  + '<tr><td>Approved for release by Client/ Supplier Quality Personnel (where applicable)</td><td></td></tr>'
	--				  + '</table>'
	--FROM #WORK_ORDER
	SELECT @section_d = '<table style="width: 100%;border:0.5pt solid lightgrey;border-collapse:collapse;"><tbody><tr><td>'
					+ '<table style="margin-top:4px; width: 100%; text-align:left; font-family:Arial; font-size:12px; padding:4px">'
					+ '<tr><th colspan="2" style="font-size:12px; text-decoration:underline">Section D : Release Authorization</th></tr>'
					+ '<tr><td colspan="2"></td></tr>'
					+ '<tr><td>(a) Checked and confirmed all documents and goods are in order and compliance by Operations Executive / Supervisor / Manager</td><td></td></tr>'
					+ '<tr><td>'
					+ '<div style="width:100%; padding-left:10px; padding-right:10px;">'
					+ '<table style="float:left; width:32%; height:100px; border:0.5pt solid lightgrey;border-collapse:collapse;margin-right:10px;"><tbody><tr><td>'
					+ '<div style="font-size:12px;">' 
					+ '<p style="margin-top:1px">(b) Approved by Operations Executive / Supervisor / Manager </p><p>' + ISNULL(vas_created_by,'') + ', ' + ISNULL(vas_created_date,'') + '</p>'
					+ '</div>'
					+ '</td></tr></tbody></table>'
					+ '<table style="float:left; width:32%; height:100px; border:0.5pt solid lightgrey;border-collapse:collapse;margin-right:10px;"><tbody><tr><td>'
					+ '<div style="font-size:12px;">'    
					+ '<p style="margin-top:1px">(c) Approved for release by Quality Assurance Executive / Manager / Assistant</p><p>' + ISNULL(qa_created_by,'') + ', ' + ISNULL(qa_created_date,'') + '</p>'
					+ '</div>'
					+ '</td></tr></tbody></table>'
					+ '<table style="float:left; width:32%; height:100px; border:0.5pt solid lightgrey;border-collapse:collapse"><tbody><tr><td>'
					+ '<div style="font-size:12px;">' 
					+ '<p style="margin-top:1px">(d) Approved for release by Client / Supplier Quality Personnel (where applicable)</p>'
					+ '</div>'
					+ '</td></tr></tbody></table>'
					+ '</div></td></tr></table>'
					+ '</td></tr></tbody></table>'
	FROM #WORK_ORDER

	SELECT ISNULL(@section_a,'') as section_a, ISNULL(@section_b,'') as section_b, ISNULL(@section_c,'') as section_c, ISNULL(@section_d,'') as section_d

	DROP TABLE #WORK_ORDER
	DROP TABLE #VAS_ACTIVITIES
END
GO
