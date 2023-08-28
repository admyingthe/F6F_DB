SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_SAP_RFC_READ_TABLE_LIKP]
AS
BEGIN
	-- Check if DO deleted
	SET NOCOUNT ON;
	SET TEXTSIZE 2147483647;

	DECLARE @xmlOut VARCHAR(MAX), @RequestText NVARCHAR(MAX)

	SELECT DISTINCT IDENTITY(INT,1,1) as row_num, inbound_doc, CAST(NULL as CHAR(1)) as valid INTO #DO 
	FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER

	DECLARE @i INT, @count INT, @inbound_doc VARCHAR(50)
	SET @i = 1
	SET @count = (SELECT MAX(row_num) FROM #DO)

	WHILE @i <= @count
	BEGIN
		SET @inbound_doc = (SELECT inbound_doc FROM #DO WHERE row_num = @i)
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
				   <FIELDNAME>VBELN</FIELDNAME>
				   <OFFSET>000000</OFFSET>
				   <LENGTH>000010</LENGTH>
				   <TYPE>c</TYPE>
				   <FIELDTEXT>DELIVERY</FIELDTEXT>
				</item>
			 </FIELDS>
			 <!--Optional:-->
			 <NO_DATA></NO_DATA>
			 <OPTIONS>
				<!--Zero or more repetitions:-->
				<item>
				   <TEXT>VBELN EQ ''' + @inbound_doc + '''</TEXT>
				</item>
			 </OPTIONS>
			 <QUERY_TABLE>LIKP</QUERY_TABLE>
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
		SELECT @GETITEMS_XML_OUTPUT
		UPDATE #DO
		SET valid = 'Y'
		WHERE inbound_doc IN (
		SELECT Tbl.Col.value('WA[1]', 'nvarchar(max)') AS WA
		FROM   @GETITEMS_XML_OUTPUT.nodes('//DATA/item') Tbl(Col)  
		WHERE Tbl.Col.value('WA[1]', 'nvarchar(max)') <> '')

		SET @i = @i + 1
	END

	UPDATE A
	SET delete_flag = valid
	FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER A
	INNER JOIN #DO B ON A.inbound_doc = B.inbound_doc

	DROP TABLE #DO
END

GO
