SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ivan
-- Create date: 2023-07-10
-- Description:	Get job event summary list
-- Example Query: exec [SPP_MST_ACTIVITY_REPORT_LISTING] '{"start_date":"2023-05-02","end_date":"2023-05-09","client_code":"0351","product_code":"","page_index":0,"page_size":20,"search_term":"","export_ind":0}'
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_JOB_EVENT_SUMMARY_LISTING]
	@param nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--DECLARE @param nvarchar(max) = '{"start_date":"2023-06-14","end_date":"2023-07-10","client_code":"","product_code":"","job_ref_no":"","page_index":0,"page_size":20,"search_term":"","export_ind":0}'

	SET NOCOUNT ON;
	declare @start_date varchar(20) = (SELECT JSON_VALUE(@param, '$.start_date'))
	declare @end_date varchar(20) = (SELECT JSON_VALUE(@param, '$.end_date'))
	declare @client_code varchar(20) = (SELECT JSON_VALUE(@param, '$.client_code'))
	declare @product_code varchar(20) = (SELECT JSON_VALUE(@param, '$.product_code'))
	declare @job_ref_no varchar(20) = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	declare @page_index int = (SELECT JSON_VALUE(@param, '$.page_index'))
	declare @page_size int = (SELECT JSON_VALUE(@param, '$.page_size'))
	declare @search_term nvarchar(max) = (SELECT JSON_VALUE(@param, '$.search_term'))
	declare @export_ind char(1) = (SELECT JSON_VALUE(@param, '$.export_ind'))

	if (@export_ind = 1)
	begin
		set @page_index = 0
		set @page_size = 99999
	end

	SELECT
	distinct A.running_no
	, CONVERT(VARCHAR(10),A.start_date, 121) as job_start_date, A.job_ref_no, B.supplier_code as client_code, B.supplier_name as client_name
	, C.prd_code
	, A.event_id
	, CONVERT(varchar(50),'') as event_name
	,ISNULL(C.status, '') as sap_status_code
	,CASE ISNULL(C.status,'') WHEN 'P' THEN 'Pending' WHEN 'S' THEN 'Submitted to SAP' WHEN 'R' THEN 'Success' WHEN 'E' THEN 'Error' ELSE '' END as sap_status
	,CASE WHEN ISNULL(C.remarks,'') = '' THEN ISNULL(C.to_no,'') ELSE ISNULL(C.remarks, '') END as sap_remarks
	,CONVERT(varchar(50),'') as ppm_prd_code
	--,CONVERT(varchar(50),'') as ppm_prd_desc
	INTO #working_table	
	from [VAS_MY_HEC].dbo.TBL_TXN_JOB_EVENT A
	INNER JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER B ON A.job_ref_no = B.workorder_no
	LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP C WITH(NOLOCK) ON A.running_no = C.requirement_no AND B.prd_code = C.prd_code
	where 
	(@client_code = '' or @client_code = 'All' or B.supplier_code = @client_code) 
	and (@product_code = '' or C.prd_code = @product_code) 
	and (@job_ref_no = '' or A.job_ref_no = @job_ref_no) 
	and CONVERT(VARCHAR(10),A.start_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121)
	AND A.running_no in (select top 1 J.running_no from TBL_TXN_JOB_EVENT J where A.job_ref_no = J.job_ref_no order by running_no desc)

	ALTER TABLE #working_table ADD id Int Identity(1, 1)
	
	DECLARE @working_ind int = 1, @event_id_temp varchar(10) = '', @job_ref_no_temp varchar(20) = ''

	WHILE (@working_ind < (SELECT COUNT(1) FROM #working_table))
	BEGIN
		SELECT @event_id_temp=event_id, @job_ref_no_temp = job_ref_no FROM #working_table WHERE id = @working_ind

		IF (@event_id_temp = '00')
		BEGIN
			--IF (SELECT COUNT(1) FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @job_ref_no_temp) = 0      
			--BEGIN      
			--	DECLARE @json NVARCHAR(MAX), @prd_code VARCHAR(50), @mll_no VARCHAR(50), @required_qty INT ,@subcon_wi_no VARCHAR(50)     
			--	IF(LEFT(@job_ref_no,1) = 'S')    
			--	BEGIN  
			--		SELECT @subcon_wi_no = subcon_WI_no, @prd_code = prd_code, @required_qty = qty_of_goods + 5 FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no      
			--		SET @json = (SELECT vas_activities FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_wi_no AND prd_code = @prd_code)      
			--	END  
			--	ELSE  
			--	BEGIN  
			--		SELECT @mll_no = mll_no, @prd_code = prd_code, @required_qty = qty_of_goods + 5 FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no      
			--		SET @json = (SELECT vas_activities FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code)      
			--	END    
      
			--	SELECT * INTO #PPM_PRD FROM OPENJSON ( @json ) WITH ( prd_list VARCHAR(2000) '$.prd_code' ) WHERE prd_list <> ''      
      
			--	SELECT DISTINCT IDENTITY(INT,1,1) as num, LTRIM(Split.a.value('.', 'VARCHAR(100)')) AS prd_code      
			--	INTO #TEMP_PPM_TXN      
			--	FROM (SELECT CAST ('<M>' + REPLACE(prd_list, ',', '</M><M>') + '</M>' AS XML) AS prd_code        
			--	FROM #PPM_PRD) AS A CROSS APPLY prd_code.nodes ('/M') AS Split(a);      
      
			--	INSERT INTO TBL_TXN_PPM      
			--	(line_no, job_ref_no, prd_code, required_qty, sap_qty, issued_qty, manual_ppm, created_date, creator_user_id)      
			--	SELECT num, @job_ref_no, prd_code, @required_qty, 0, 0, 0, GETDATE(), 8013       
			--	FROM #TEMP_PPM_TXN      
      
			--	DROP TABLE #PPM_PRD      
			--	DROP TABLE #TEMP_PPM_TXN
			--END 

			DECLARE @ppm_prd_code varchar(20) = '', @ppm_prd_desc varchar(100) = '', @sap_status varchar(10) = '', @sap_remarks varchar(100) = ''

			SELECT @sap_status = C.status, @sap_remarks = ' TO NO. ' + ISNULL(C.to_no, '') + ' - ' + C.remarks
			FROM TBL_TXN_PPM A WITH(NOLOCK)    
			INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code    
			LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP C WITH(NOLOCK)   
			ON A.system_running_no = C.requirement_no AND A.prd_code = C.prd_code AND C.country_code = 'MY'    
			WHERE job_ref_no = @job_ref_no_temp

			SELECT @job_ref_no_temp = A.job_ref_no, 
				@ppm_prd_code = STUFF((SELECT ', ' + D.prd_code
				FROM TBL_TXN_PPM AS D
				WHERE A.job_ref_no = D.job_ref_no
				ORDER BY D.prd_code
				FOR XML PATH('')), 1, 2, '')
			FROM TBL_TXN_PPM A
			INNER JOIN TBL_MST_PRODUCT B ON A.prd_code = B.prd_code    
			LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP C ON A.system_running_no = C.requirement_no AND A.prd_code = C.prd_code AND C.country_code = 'MY'    
			WHERE A.job_ref_no = @job_ref_no_temp
			group by A.job_ref_no

			UPDATE #working_table
			SET ppm_prd_code = @ppm_prd_code, sap_status_code = @sap_status, sap_remarks = @sap_remarks
			WHERE job_ref_no = @job_ref_no_temp
		END

		SET @working_ind += 1
	END
	
	UPDATE A
	SET A.event_name = B.event_name
	FROM #working_table A
	INNER JOIN [VAS_MY_HEC].dbo.TBL_MST_EVENT_CONFIGURATION_HDR B ON A.event_id = B.event_id

	If (SELECT COUNT(1) FROM #working_table WHERE LEFT(job_ref_no,1) = 'S') = 1
	BEGIN

		DECLARE @event_id varchar(2), @main_status varchar(2), @main_indicator varchar(2), @finalStatus varchar(2), @remarks varchar(MAX)

		UPDATE	D
		SET		D.sap_remarks = A.remarks,
				D.sap_status_code = case 
				when (A.status = 'P' and A.process_ind = 'S') then 'S'
				when (A.status = 'S' and A.process_ind = 'S') then 'R'
				when (A.status = 'E' and A.process_ind = 'S') then 'E'
				end
		FROM	VAS_INTEGRATION.dbo.VAS_SUBCON_INBOUND_ORDER A
				inner join
				VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP B
		ON		A.running_no = B.requirement_no
				inner join
				TBL_TXN_JOB_EVENT C
		ON		A.running_no = C.running_no
				inner join
				#working_table D
		ON		A.running_no = D.running_no
		WHERE	C.job_ref_no= @job_ref_no
	END

	UPDATE #working_table
		SET sap_status = CASE ISNULL(sap_status_code,'') WHEN 'P' THEN 'Pending' WHEN 'S' THEN 'Submitted to SAP' WHEN 'R' THEN 'Success' WHEN 'E' THEN 'Error' ELSE '' END

	SELECT COUNT(1) as ttl_rows FROM #working_table
	WHERE (
		job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
		prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
		client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR
		client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
		event_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_name END OR
		sap_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_status END OR
		running_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE running_no END
	)

	IF @export_ind <> 1
	BEGIN
		SELECT * FROM #working_table
		WHERE (
		job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
		prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
		client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR
		client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
		event_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_name END OR
		sap_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_status END OR
		running_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE running_no END
		)
		order by job_start_date desc
		OFFSET (@page_index * @page_size) ROWS FETCH NEXT (@page_size) ROWS ONLY
	END

	DROP TABLE #working_table

	select @export_ind as export_ind
END

GO
