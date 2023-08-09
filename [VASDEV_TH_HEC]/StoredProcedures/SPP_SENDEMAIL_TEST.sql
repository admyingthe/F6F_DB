SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC SPP_SEND_EMAIL_QA 'MLL005300RD00003','0053'
CREATE PROCEDURE [dbo].[SPP_SENDEMAIL_TEST]
AS
BEGIN

DECLARE @sql VARCHAR(MAX) = '', @qry VARCHAR(MAX) = '', @add_qry VARCHAR(MAX)= ''
declare @EXCEL_FILE_NAME varchar(100)

SET @qry = 'set nocount on;SELECT top 10 B.client_code , C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, E.name storage_condition,ISNULL(F.name,''NA'') medical_device_usage,ISNULL(G.name,''NA'') As BM_IFU, remarks FROM TBL_MST_MLL_DTL A WITH(NOLOCK)  INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code   LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.medical_device_usage = F.code   LEFT JOIN TBL_MST_DDL G WITH(NOLOCK) ON A.bm_ifu = G.code' 
  
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'VASMail',
  @recipients = 'jackson.pais@itcinfotech.com',  
  @copy_recipients = 'jackson.pais@itcinfotech.com', 
@execute_query_database = 'VAS_MY_HEC' ,
@query=@qry,
@query_attachment_filename = @EXCEL_FILE_NAME,
@subject='VAS Testing QA Notification',
@attach_query_result_as_file = 1,
@body = 'This is a system auto generate message, please do not reply.'
 
 print 'b'
 
END
GO
