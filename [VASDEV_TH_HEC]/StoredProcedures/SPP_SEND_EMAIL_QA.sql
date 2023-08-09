SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- EXEC SPP_SEND_EMAIL_QA 'MLL005307RD00006','0053'
-- =============================================
CREATE PROCEDURE [dbo].[SPP_SEND_EMAIL_QA]
	@MLL_No NVARCHAR(500)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @submitted_by_id INT

SELECT	@client_code = client_code, 
		@type_of_vas = type_of_vas, 
		@sub = sub, 
		@submitted_by_id = submitted_by 
FROM	TBL_MST_MLL_HDR WITH(NOLOCK) 
WHERE	mll_no = @mll_no

SELECT A.mll_no, A.prd_code, start_date, end_date,      
  json_value(vas_activities, '$[0].radio_val') as radio_val_1,       
  json_value(vas_activities, '$[1].radio_val') as radio_val_2,       
  json_value(vas_activities, '$[2].radio_val') as radio_val_3,      
  json_value(vas_activities, '$[3].radio_val') as radio_val_4,       
  json_value(vas_activities, '$[4].radio_val') as radio_val_5,       
  json_value(vas_activities, '$[5].radio_val') as radio_val_6,       
  json_value(vas_activities, '$[6].radio_val') as radio_val_7,       
  json_value(vas_activities, '$[7].radio_val') as radio_val_8,       
  json_value(vas_activities, '$[8].radio_val') as radio_val_9, 
  CAST(NULL as VARCHAR(10)) as radio_val      
  INTO #temp_vas_activities_current      
  FROM TBL_MST_MLL_DTL A WITH(NOLOCK)      
  INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no      
  WHERE --A.mll_no = @mll_no      
  B.client_code = @client_code AND B.type_of_vas = @type_of_vas AND B.sub = @sub      
  AND B.mll_status = 'Approved' AND end_date > GETDATE()   
      
  UPDATE #temp_vas_activities_current      
  SET radio_val = CASE WHEN (radio_val_1 IN ('Y','P')      
         OR radio_val_2 IN ('Y','P')      
         OR radio_val_3 IN ('Y','P')      
         OR radio_val_4 IN ('Y','P')      
         OR radio_val_5 IN ('Y','P')      
         OR radio_val_6 IN ('Y','P')      
         OR radio_val_7 IN ('Y','P')      
         OR radio_val_8 IN ('Y','P')      
         OR radio_val_9 IN ('Y','P')) 
		 THEN 'Y' ELSE 'N' END      
      
  UPDATE #temp_vas_activities_current      
  SET radio_val = 'N'    
  Where (radio_val_1 ='P' OR 
		radio_val_2 = 'P' OR 
		radio_val_3 = 'P' OR     
        radio_val_4 = 'P' OR 
		radio_val_5 = 'P' OR 
		radio_val_6 = 'P' OR 
		radio_val_7 = 'P' OR 
		radio_val_8 = 'P' OR 
		radio_val_9 = 'P')     
   AND (radio_val_1 = 'N' OR 
		radio_val_2 = 'N' OR 
		radio_val_3 = 'N' OR     
        radio_val_4 = 'N' OR 
		radio_val_5 = 'N' OR 
		radio_val_6 = 'N' OR 
		radio_val_7 = 'N' OR 
		radio_val_8 = 'N' OR 
		radio_val_9 = 'N')     
    
  UPDATE #temp_vas_activities_current      
  SET radio_val = 'Y'    
  Where ( radio_val_1 = 'P' OR 
		  radio_val_2 = 'P' OR 
		  radio_val_3 = 'P' OR     
          radio_val_4 = 'P' OR 
		  radio_val_5 = 'P' OR 
		  radio_val_6 = 'P' OR 
		  radio_val_7 = 'P' OR 
		  radio_val_8 = 'P' OR 
		  radio_val_9 = 'P')     
     AND (radio_val_1 = 'Y' OR 
		  radio_val_2 = 'Y' OR 
		  radio_val_3 = 'Y' OR     
		  radio_val_4 = 'Y' OR 
		  radio_val_5 = 'Y' OR 
		  radio_val_6 = 'Y' OR 
		  radio_val_7 = 'Y' OR 
		  radio_val_8 = 'Y' OR 
		  radio_val_9 ='Y')     

-- DECLARE @VAS_Insert CHAR(1),@VAS_Readdress CHAR(1),@VAS_Inject CHAR(1),@VAS_Others CHAR(1)
DECLARE @count_y int

SELECT	@count_y = count(0) 
FROM	#temp_vas_activities_current 
WHERE	mll_no = @mll_no and (radio_val_6  ='Y' OR radio_val_7  ='Y' OR radio_val_8  ='Y' OR radio_val_9  ='Y')

--SELECT	@VAS_Insert = radio_val_6, @VAS_Readdress = radio_val_7, @VAS_Inject = radio_val_8, @VAS_Others = radio_val_9 
--FROM	#temp_vas_activities_current 
--WHERE	mll_no = @mll_no

--IF(@VAS_Insert  ='Y' OR @VAS_Readdress  ='Y' OR @VAS_Inject  ='Y' OR @VAS_Others  ='Y')
IF(@count_y > 0)
BEGIN

print '1'

DECLARE @strCMD VARCHAR(1000), @folder_path NVARCHAR(4000), @pdf_full_path NVARCHAR(4000)
DECLARE @recipients NVARCHAR(MAX), @copy_recipients  NVARCHAR(MAX)
DECLARE @EXCEL_FILE_NAME NVARCHAR(1000) = @MLL_No+'_'+convert(varchar, getdate(), 112)+'.csv'

SET @folder_path = N'D:\VAS\TH-HEC\MLL\'
SET @pdf_full_path = @folder_path + @mll_no + '.pdf'

declare @dept_code VARCHAR(50)
SET @dept_code = (SELECT department FROM VASDEV.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @submitted_by_id)

--SELECT TOP 1	@recipients = recipients,
--				@copy_recipients = copy_recipients 
--FROM			TBL_MST_QA_EMAIL_CONFIGURATION
--WHERE			client_code = @client_code and 
--				recipients IS NOT NULL

SELECT			@recipients = recipients, 
				@copy_recipients = copy_recipients 
FROM			TBL_MST_QA_EMAIL_CONFIGURATION WITH(NOLOCK) 
WHERE			dept_code = @dept_code AND 
				client_code = @client_code

DECLARE @sql VARCHAR(MAX) = '', @qry VARCHAR(MAX) = '', @add_qry VARCHAR(MAX)= ''
SELECT		ROW_NUMBER() OVER (ORDER BY input_name) as srno,
			display_name,
			input_name,
			A.page_dtl_id
INTO		#ACTIVITY_NAMES  
FROM		VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK) 
			INNER JOIN 
			VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) 
ON			A.page_dtl_id = B.page_dtl_id 
WHERE		principal_code = 'TH-HEC' AND 
			page_code = 'MLL-SEARCH' AND 
			input_name LIKE 'vas_activities_%'

DECLARE @count INT = (
						SELECT		COUNT(*) 
						FROM		#ACTIVITY_NAMES
					 )

DECLARE		@i INT = 0
DECLARE		@name varchar(50) = '',
			@page_id int = 0

WHILE		@i < @count
BEGIN

select		@name = display_name,
			@page_id = page_dtl_id
from		#ACTIVITY_NAMES where srno = @i + 1

SET			@sql +=' json_value(vas_activities, ''$['+ CAST(@i as VARCHAR(3)) +'].radio_val'') as ''' + @name + ''','

if			(@i > 4)
begin

SET			@add_qry += ' vas_activities like ''%{"prd_code":"","radio_val":"Y","page_dtl_id":'+ CAST(@page_id as VARCHAR(10)) +'}%'' or'

end

SET			@i = @i + 1

END

SET @sql = substring(@sql, 1, len(@sql)-1) 
SET @add_qry = substring(@add_qry, 1, len(@add_qry)-2)

DROP	TABLE #ACTIVITY_NAMES
declare @tab char(1) = CHAR(9)

SET @qry = 'set nocount on;SELECT distinct B.client_code , C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, E.name storage_condition,ISNULL(F.name,''NA'') medical_device_usage,ISNULL(G.name,''NA'') As BM_IFU,ISNULL(H.name,''NA'') As PPM_BY,CASE WHEN A.gmp_required=1 THEN ''YES'' ELSE ''NO'' END GMP_REQUIRED, remarks, ' + @sql + ' FROM TBL_MST_MLL_DTL A WITH(NOLOCK)  INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code   LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.medical_device_usage = F.code   LEFT JOIN TBL_MST_DDL G WITH(NOLOCK) ON A.bm_ifu = G.code    LEFT JOIN TBL_MST_DDL H WITH(NOLOCK) ON A.ppm_by = H.code WHERE B.mll_no ='''+@MLL_No+''' and ('+ @add_qry +')'
-- select @qry
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'VASMail',
@recipients = 'smita.thorat@itcinfotech.com',
--@copy_recipients = 'jackson.pais@itcinfotech.com',
--@recipients=@recipients,
@copy_recipients = @copy_recipients,
@subject='[VAS Testing] QA Notification for TH',
@body = 'This is a system auto generate message, please do not reply.',
@execute_query_database = 'VAS_TH_HEC',
@query_result_separator=@tab,
@query_result_no_padding = 1,
@query_result_width=32767,
@query = @qry,
@attach_query_result_as_file = 1,
@query_attachment_filename = @EXCEL_FILE_NAME,
@file_attachments = @pdf_full_path;
	
END
DROP TABLE #temp_vas_activities_current  

END

GO
