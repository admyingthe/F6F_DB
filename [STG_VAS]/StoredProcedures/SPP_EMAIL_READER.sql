/****** Object:  StoredProcedure [dbo].[SPP_EMAIL_READER]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_EMAIL_READER]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT id, email_addr, received_date, timezone, mail_subject, mail_content, comment, A.created_date, processing_status, country_db_name
	INTO #TEMP_EMAIL_READER
	FROM GLOBAL_EMAIL_READER.dbo.TBL_ADM_EMAIL_READER A WITH(NOLOCK), TBL_ADM_SETTING B
	WHERE app_code = 'VAS' AND processing_status = 'N' 
	AND id NOT IN (SELECT mail_id FROM TBL_ADM_EMAIL_READER WITH(NOLOCK))
	AND mail_subject LIKE '%' + email_country_hdr + '%'
	
	INSERT INTO TBL_ADM_EMAIL_READER
	(mail_id, email_addr, received_date, timezone, mail_subject, mail_content, comment, created_date, processing_status, db_name)
	SELECT * FROM #TEMP_EMAIL_READER

	UPDATE GLOBAL_EMAIL_READER.dbo.TBL_ADM_EMAIL_READER
	SET processing_status = 'Y',
		processing_date = GETDATE()
	WHERE id IN (SELECT id FROM #TEMP_EMAIL_READER)

	INSERT INTO TBL_ADM_EMAIL_READER_ATTACHMENT
	(mail_id, file_name, file_size, file_extension, attachment)
	SELECT mail_id, file_name, file_size, file_extension, CAST(N'' AS xml).value('xs:base64Binary(sql:column("attachment"))', 'varbinary(max)')
	FROM GLOBAL_EMAIL_READER.dbo.TBL_ADM_EMAIL_ATTACHMENT WITH(NOLOCK)
	WHERE mail_id IN (SELECT id FROM #TEMP_EMAIL_READER)

	DROP TABLE #TEMP_EMAIL_READER
END
GO
