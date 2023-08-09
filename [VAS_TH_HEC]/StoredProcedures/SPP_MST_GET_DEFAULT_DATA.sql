SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT DISTINCT uom FROM TBL_TXN_WORK_ORDER WHERE job_ref_no  = 'G2022/07/0002'
--EXEC SPP_MST_GET_DEFAULT_DATA @param =N'{"job_ref_no":"G2022/08/0005","selected_event_id":"50"}'

CREATE PROCEDURE [dbo].[SPP_MST_GET_DEFAULT_DATA]    
 @param nvarchar(max)    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
 DECLARE @job_ref_no VARCHAR(50), @selected_event_id INT    
 SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))    
 SET @selected_event_id = (SELECT JSON_VALUE(@param, '$.selected_event_id'))    

 DECLARE @previous_running_no VARCHAR(50), @start_date VARCHAR(19)    
 SET @previous_running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)    

 IF @selected_event_id = '10' -- PPM start date get from MPO creation date    
  SET @start_date = (SELECT ISNULL(CONVERT(varchar(19), created_date, 121), '') FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)    
 ELSE -- Get start date = end date of previous event    
  SET @start_date = (SELECT ISNULL(CONVERT(varchar(19), end_date, 121),'') FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @previous_running_no)    



 DECLARE @qty_to_use INT, @issued_qty INT,@qa_required VARCHAR(10) ,@count_qa_Required INT
IF LEFT(@job_ref_no,1) = 'S' 
BEGIN
 	SET @qty_to_use = (SELECT top 1 CASE WHEN qty_of_goods <> 0 THEN qty_of_goods ELSE ttl_qty_eaches END FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
	
	SET @issued_qty=@qty_to_use

	SET @qa_required = (SELECT	TOP 1 D.qa_required 
					FROM	TBL_Subcon_TXN_WORK_ORDER A WITH(NOLOCK)    
							INNER JOIN 
							TBL_MST_PRODUCT B WITH(NOLOCK) 
					ON		A.prd_code = B.prd_code    
							INNER JOIN 
							TBL_MST_CLIENT C WITH(NOLOCK) 
					ON		A.client_code = C.client_code    
							INNER JOIN 
							TBL_MST_SUBCON_DTL D WITH(NOLOCK) 
					ON		A.subcon_wi_no = D.subcon_no AND A.prd_code = D.prd_code 
							LEFT JOIN 
							TBL_MST_DDL F WITH(NOLOCK) 
					ON		A.work_ord_status = F.code   
							INNER JOIN 
							TBL_MST_SUBCON_HDR G WITH(NOLOCK) 
					ON		A.subcon_wi_no = G.subcon_no   
							INNER JOIN 
							VAS_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER H WITH(NOLOCK) 
					ON		H.prd_code = A.prd_code AND H.batch_no = A.batch_no and H.SWI_No = A.subcon_WI_no and H.subcon_job_no = job_ref_no
					WHERE	job_ref_no = @job_ref_no AND F.ddl_code = 'ddlWorkOrderStatus')
END
ELSE IF LEFT(@job_ref_no,1) = 'G' 
BEGIN

	SET @qty_to_use = (SELECT SUM(ttl_qty_eaches)   FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

	
	SET @issued_qty =(select TOP 1   ISNULL(completed_qty,0) FROM TBL_TXN_JOB_EVENT WHERE job_ref_no=@job_ref_no AND event_id=80 ORDER BY created_date DESC)
	SET @issued_qty=(SELECT CASE WHEN @issued_qty IS NULL THEN @qty_to_use ELSE @issued_qty END )
	
	
	SET @count_qa_Required =(SELECT  Count(*) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND ISNULL(qa_required, 1)=1)
	SET @qa_required = 	(SELECT CASE WHEN @count_qa_Required>=1 THEN 1 ELSE 0 END)
END
ELSE 
BEGIN
	SET @qty_to_use = ( SELECT CASE WHEN B.qty_of_goods <> 0 THEN B.qty_of_goods ELSE A.ttl_qty_eaches END 
						FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
						INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET B ON A.job_ref_no = B.job_ref_no AND A.work_ord_ref = B.work_ord_ref WHERE A.job_ref_no = @job_ref_no  )

	SET @issued_qty =(select TOP 1   ISNULL(completed_qty,0) FROM TBL_TXN_JOB_EVENT WHERE job_ref_no=@job_ref_no AND event_id=80 ORDER BY created_date DESC)
	SET @issued_qty=(SELECT CASE WHEN @issued_qty IS NULL THEN @qty_to_use ELSE @issued_qty END )

	SET @qa_required = 	(SELECT DISTINCT ISNULL(qa_required, 1) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
END



 DECLARE @uom NVARCHAR(10)
  -- SET @uom = (SELECT top 1 uom FROM TBL_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)
 SELECT @uom = COALESCE(@uom+',' ,'') + uom FROM TBL_TXN_WORK_ORDER  WHERE job_ref_no = @job_ref_no GROUP BY uom


 ---Need to check if in use or not 
 --IF @selected_event_id = '10' -- PPM to add 5 if more than 100 and add 3 if less than 100    
 --BEGIN    
 -- --SELECT @start_date as start_date, CASE WHEN @qty_to_use >= 100 THEN @qty_to_use + 5 ELSE @qty_to_use + 3 END as issued_qty    
    
 -- DECLARE @mll_no VARCHAR(50), @prd_code VARCHAR(50), @json_activities NVARCHAR(MAX)    
 -- SET @mll_no = (SELECT DISTINCT mll_no FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)    
 -- SET @prd_code = (SELECT TOP 1 prd_code FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)    
    
 -- SET @json_activities = (SELECT vas_activities FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code)    
    
 -- SELECT IDENTITY(INT, 1, 1) AS row_id, CAST(NULL AS NVARCHAR(250)) as display_name, * INTO #VAS_ACTIVITIES FROM OPENJSON ( @json_activities )      
 -- WITH (    
 --  prd_code VARCHAR(50) '$.prd_code',      
 --  page_dtl_id INT   '$.page_dtl_id',      
 --  radio_val CHAR(1)  '$.radio_val'    
 -- )    
 -- WHERE radio_val <> 'N'    
    
 -- UPDATE A    
 -- SET display_name = B.display_name    
 -- FROM #VAS_ACTIVITIES A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)    
 -- WHERE A.page_dtl_id = B.page_dtl_id    
    
 -- DECLARE @vas_html NVARCHAR(MAX) = ''    
 -- DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES), @i INT = 1    
     
 -- WHILE @i <= @count    
 -- BEGIN    
 --  SET @vas_html += (SELECT CAST(@i as VARCHAR(100)) + '. ' + prd_code + ' ' + CASE WHEN radio_val = '' THEN '' ELSE + '(' + CASE WHEN radio_val = 'Y' THEN 'Yes' WHEN radio_val = 'N' THEN 'No' WHEN radio_val = 'P' THEN 'Preprinted' ELSE '' END  + ')' END + ' - ' + display_name FROM #VAS_ACTIVITIES WHERE row_id = @i)    
    
 --  IF (@i != @count) SET @vas_html = @vas_html + ', '    
 --  ELSE SET @vas_html = @vas_html + ' '    
 --  SET @i = @i + 1    
 -- END    
 -- SET @vas_html = (SELECT @vas_html + ', ' + others FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)    
 -- SELECT @start_date as start_date, @qty_to_use  + 5 as issued_qty, @vas_html as remarks, @uom as uom    
    
 -- DROP TABLE #VAS_ACTIVITIES    
 --END    
 --ELSE 
  ---Need to check if in use or not 


	 IF @selected_event_id = '30' -- Mock Sample : default to 1 
	 BEGIN
		DECLARE @station_no_val NVARCHAR(50)
		SET @station_no_val = (SELECT top 1 station_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no)

		SELECT @start_date as start_date, default_qty as issued_qty, @uom as uom, @station_no_val as station_no 
		FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) 
		WHERE event_id = @selected_event_id
	 END
	 ELSE IF @selected_event_id = '20'
	 BEGIN
		DECLARE @storage_type_val NVARCHAR(10)
		DECLARE @bin_no_val NVARCHAR(10)
		SET @storage_type_val = (SELECT top 1  storage_type FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND event_id =20)
		SET @bin_no_val = (SELECT top 1  bin_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND event_id =20)

		SELECT @start_date as start_date, @issued_qty as issued_qty, @qty_to_use as original_qty,  @qa_required as internal_qa_required, @uom as uom, @storage_type_val as storage_type, @bin_no_val as bin_no
	 END
	 ELSE
		SELECT @start_date as start_date, @issued_qty as issued_qty, @qty_to_use as original_qty, @issued_qty internal_qa_completed_qty ,@issued_qty qa_qty, @qa_required as internal_qa_required, @uom as uom   
END




GO
