SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_SAP_RFC_READ_TABLE_KOTP902]
AS
BEGIN
	SET NOCOUNT ON;

	TRUNCATE TABLE VAS_INTEGRATION.dbo.VAS_CONDITIONS_COMPARISON

	SELECT A.mll_no, A.prd_code, start_date, end_date,
	json_value(vas_activities, '$[0].radio_val') as radio_val_1, 
	json_value(vas_activities, '$[1].radio_val') as radio_val_2, 
	json_value(vas_activities, '$[2].radio_val') as radio_val_3,
	json_value(vas_activities, '$[3].radio_val') as radio_val_4, 
	json_value(vas_activities, '$[4].radio_val') as radio_val_5, 
	json_value(vas_activities, '$[5].radio_val') as radio_val_6, 
	json_value(vas_activities, '$[6].radio_val') as radio_val_7, 
	json_value(vas_activities, '$[7].radio_val') as radio_val_8, 
	json_value(vas_activities, '$[8].radio_val') as radio_val_9, CAST(NULL as VARCHAR(10)) as radio_val
	INTO #temp_vas_activities
	FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
	INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
	WHERE A.mll_no IN 
	(SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Approved' AND GETDATE() BETWEEN start_date AND end_date)

	UPDATE #temp_vas_activities
	SET radio_val = CASE WHEN (radio_val_1 IN ('Y','P')
						   OR radio_val_2 IN ('Y','P')
						   OR radio_val_3 IN ('Y','P')
						   OR radio_val_4 IN ('Y','P')
						   OR radio_val_5 IN ('Y','P')
						   OR radio_val_6 IN ('Y','P')
						   OR radio_val_7 IN ('Y','P')
						   OR radio_val_8 IN ('Y','P')
						   OR radio_val_9 IN ('Y','P')) THEN 'Y' ELSE 'N' END

	CREATE TABLE #temp_vas 
	( 
	mll_no VARCHAR(50), 
	prd_code VARCHAR(50), 
	start_date VARCHAR(10), 
	end_date VARCHAR(10), 
	current_val VARCHAR(10))

	INSERT INTO #temp_vas(mll_no, prd_code, start_date, end_date, current_val)
	SELECT mll_no, prd_code, CONVERT(VARCHAR(10), start_date, 121), CONVERT(VARCHAR(10), end_date, 121), radio_val FROM #temp_vas_activities WHERE radio_val = 'Y'
 
	INSERT INTO VAS_INTEGRATION.dbo.VAS_CONDITIONS_COMPARISON
	(prd_code, start_date, end_date, created_date)
	SELECT prd_code, start_date, end_date, GETDATE() FROM #temp_vas WHERE current_val = 'Y'

	DROP TABLE #temp_vas	
	drop table #temp_vas_activities
	
	DECLARE @xmlOut VARCHAR(MAX), @RequestText NVARCHAR(MAX)
		SET @RequestText = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
		<soapenv:Header/>
		<soapenv:Body>
			<urn:RFC_READ_TABLE>
			 <DATA>
				<!--Zero or more repetitions:-->
				<item>
				   <WA></WA>
				</item>
			 </DATA>
			 <!--Optional:-->
			 <DELIMITER>;</DELIMITER>
			 <FIELDS>
			 <item>
				   <FIELDNAME>DATAB</FIELDNAME>
				   <OFFSET>000000</OFFSET>
				   <LENGTH>000001</LENGTH>
				   <TYPE>D</TYPE>
				   <FIELDTEXT></FIELDTEXT>
				</item>
				<item>
				   <FIELDNAME>MATNR</FIELDNAME>
				   <OFFSET>000002</OFFSET>
				   <LENGTH>000001</LENGTH>
				   <TYPE>C</TYPE>
				   <FIELDTEXT></FIELDTEXT>
				</item>
				<item>
				   <FIELDNAME>DATBI</FIELDNAME>
				   <OFFSET>000003</OFFSET>
				   <LENGTH>000001</LENGTH>
				   <TYPE></TYPE>
				   <FIELDTEXT></FIELDTEXT>
				</item>
			 </FIELDS>
			 <!--Optional:-->
			 <NO_DATA></NO_DATA>
			 <OPTIONS>
				<!--Zero or more repetitions:-->
				<item>
				   <TEXT></TEXT>
				</item>
			 </OPTIONS>
			 <QUERY_TABLE>KOTP902</QUERY_TABLE>
			 <!--Optional:-->
			 <ROWCOUNT>0</ROWCOUNT>
			 <!--Optional:-->
			 <ROWSKIPS>0</ROWSKIPS>
		  </urn:RFC_READ_TABLE>
		</soapenv:Body>
		</soapenv:Envelope>'

		EXEC SPP_SAP_HTTPRequest 
		@URI ='http://kuldb84s.dksh.com:8000/sap/bc/srt/rfc/sap/yfi_ws_0007/300/yfi_ws_0007/yfi_ws_0007', 
		@methodName = 'POST', 
		@requestBody = @RequestText,
		@SoapAction = 'RFC_READ_TABLE',
		@UserName ='THBTC01', @Password ='pokemon1',@responseText = @xmlOut out

		DECLARE @StrHdrToRemove VARCHAR(MAX)
		SET @StrHdrToRemove = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:RFC_READ_TABLEResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">'
		SET @xmlOut = REPLACE(@xmlOut,@StrHdrToRemove,'')

		DECLARE @StrFooterToRemove VARCHAR(max)
		SET @StrHdrToRemove = '</n0:RFC_READ_TABLEResponse></soap-env:Body></soap-env:Envelope>'
		SET @xmlOut = REPLACE(@xmlOut,@StrHdrToRemove,'')

		DECLARE @GETITEMS_XML_OUTPUT AS XML  
		SET @GETITEMS_XML_OUTPUT = @xmlOut

		SELECT Tbl.Col.value('WA[1]', 'nvarchar(max)') AS WA
		INTO #TEMP33
		FROM   @GETITEMS_XML_OUTPUT.nodes('//DATA/item') Tbl(Col)  
		WHERE Tbl.Col.value('WA[1]', 'nvarchar(max)') <> ''

		IF ((SELECT COUNT(*) FROM #TEMP33) > 0)
		BEGIN
			SELECT DISTINCT
			SUBSTRING(WA,19,9) AS prd_code,
			SUBSTRING(WA,1,8) AS start_date,
			SUBSTRING(WA,29,8) AS end_date
			INTO #TEMP11
			FROM #TEMP33

			UPDATE A
			SET error_ind = 'N'
			FROM VAS_INTEGRATION.dbo.VAS_CONDITIONS_COMPARISON A
			INNER JOIN #TEMP11 B ON A.prd_code = B.prd_code AND  CONVERT(VARCHAR(8), A.start_date, 112) = B.start_date AND  CONVERT(VARCHAR(8), A.end_date, 112) = B.end_date
		END

		UPDATE VAS_INTEGRATION.dbo.VAS_CONDITIONS_COMPARISON
		SET error_ind = 'Y'
		WHERE error_ind <> 'N' OR error_ind IS NULL
		
		IF (SELECT COUNT(*) FROM VAS_INTEGRATION.dbo.VAS_CONDITIONS_COMPARISON) > 0
		BEGIN
			SELECT  prd_code, CONVERT(VARCHAR(10), start_date, 121) as start_date, CONVERT(VARCHAR(10), end_date, 121) as end_date
			INTO ##temp_vas_22
			FROM VAS_INTEGRATION.dbo.VAS_CONDITIONS_COMPARISON
			WHERE error_ind = 'Y'

			DECLARE @file_name NVARCHAR(200), @sql NVARCHAR(4000)
			SET @file_name = 'D:\VAS\MY-HEC\VASTriggerComparisonResults_' + CONVERT(VARCHAR(10), GETDATE(), 121) + '.xls'
			SET @sql = 'bcp "SELECT ''Product Code'', ''Effective Start Date'', ''Effective End Date'' union all SELECT * FROM tempdb..##temp_vas_22" queryout ' + @file_name + ' -S 10.208.7.129 -U EPAdmin -P Dkshcssc00 -w -r \n'
			EXEC master..xp_cmdshell @sql

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'VASMail',
				@recipients = 'neelam.soni@itcinfotech.com',
				@blind_copy_recipients = 'neelam.soni@itcinfotech.com',
				@subject = '[VAS Testing] GMP / NON-GMP Comparison Results',
				@body = 'Testing - GMP/NON-GMP Comparison Results',
				@attach_query_result_as_file = 0,
				@body_format ='HTML',
				@importance = 'NORMAL',
				@file_attachments = @file_name;

			DROP TABLE ##temp_vas_22
		END
		 
		DROP TABLE #TEMP33
		DROP TABLE #TEMP11
END

GO
