SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_SAP_RFC_YMM_FM_BAPI_STOCK_ENQUIRY]
	@prd_code_list NVARCHAR(MAX),
	@plant_list	NVARCHAR(MAX),
	@storage_loc_list NVARCHAR(MAX),
	@xml XML OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * INTO #PRD_LIST FROM SF_SPLIT(@prd_code_list, ',', '')
	SELECT * INTO #PLANT_LIST FROM SF_SPLIT(@plant_list, ',', '')
	SELECT * INTO #SLOC_LIST FROM SF_SPLIT(@storage_loc_list, ',', '')

	/** Product list string **/
	DECLARE @i INT = 1, @ttl_prd INT, @prd_sql NVARCHAR(MAX) = '', @prd_code VARCHAR(50)
	SET @ttl_prd = (SELECT COUNT(1) FROM #PRD_LIST)

	WHILE @i <= @ttl_prd
	BEGIN
		SELECT @prd_code = Data FROM #PRD_LIST WHERE ID = @i
		IF @prd_code <> ''
		BEGIN
			SET @prd_sql += '<item>
							<SIGN>I</SIGN>
							<OPTION>EQ</OPTION>
							<LOW>' + @prd_code + '</LOW>
							<HIGH></HIGH>
						 </item>'
		END
		SET @i = @i + 1
	END

	/** Plant list string **/
	DECLARE @j INT = 1, @ttl_plant INT, @plant_sql NVARCHAR(MAX) = '', @plant VARCHAR(50)
	SET @ttl_plant = (SELECT COUNT(1) FROM #PLANT_LIST)

	WHILE @j <= @ttl_plant
	BEGIN
		SELECT @plant = Data FROM #PLANT_LIST WHERE ID = @j
		IF @plant <> ''
		BEGIN
			SET @plant_sql += '<item>
							<SIGN>I</SIGN>
							<OPTION>EQ</OPTION>
							<LOW>' + @plant + '</LOW>
							<HIGH></HIGH>
						 </item>'
		END
		SET @j = @j + 1
	END

	/** Storage location list string **/
	DECLARE @k INT = 1, @ttl_sloc INT, @sloc_sql NVARCHAR(MAX) = '', @sloc VARCHAR(50)
	SET @ttl_sloc = (SELECT COUNT(1) FROM #SLOC_LIST)

	WHILE @k <= @ttl_sloc
	BEGIN
		SELECT @sloc = Data FROM #SLOC_LIST WHERE ID = @k
		IF @sloc <> ''
		BEGIN
			SET @sloc_sql += '<item>
							<SIGN>I</SIGN>
							<OPTION>EQ</OPTION>
							<LOW>' + @sloc + '</LOW>
							<HIGH></HIGH>
						 </item>'
		END
		SET @k = @k + 1
	END

	DROP TABLE #PRD_LIST
	DROP TABLE #PLANT_LIST
	DROP TABLE #SLOC_LIST

	DECLARE @xmlOut NVARCHAR(MAX), @RequestText NVARCHAR(MAX)

	SET @RequestText = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
		<soapenv:Header/>
		<soapenv:Body>
		<urn:YMM_FM_BAPI_STOCK_ENQUIRY>
		<T_DATA>
		<item>
               <WERKS></WERKS>
               <LGORT></LGORT>
               <LGOBE></LGOBE>
               <MATKL></MATKL>
               <MVGR4></MVGR4>
               <MATNR></MATNR>
               <MAKTX></MAKTX>
               <KBETR></KBETR>
               <KMEIN></KMEIN>
               <UMREZ></UMREZ>
               <ON_HAND></ON_HAND>
               <URESTRICT></URESTRICT>
               <SO_CONFIRM></SO_CONFIRM>
               <AVAI_STOCK></AVAI_STOCK>
               <TRANS_STOCK></TRANS_STOCK>
               <AMOUNT></AMOUNT>
               <BISMT></BISMT>
            </item>
         </T_DATA>
		 <T_LGORT>' + @sloc_sql + '</T_LGORT>
		 <T_MATNR>' + @prd_sql + '</T_MATNR>
		 <T_RETURN>
		 <item>
               <TYPE></TYPE>
               <CODE></CODE>
               <MESSAGE></MESSAGE>
               <LOG_NO></LOG_NO>
               <LOG_MSG_NO></LOG_MSG_NO>
               <MESSAGE_V1></MESSAGE_V1>
               <MESSAGE_V2></MESSAGE_V2>
               <MESSAGE_V3></MESSAGE_V3>
               <MESSAGE_V4></MESSAGE_V4>
            </item>
         </T_RETURN>
		 <T_WERKS>' + @plant_sql + '</T_WERKS>
		 </urn:YMM_FM_BAPI_STOCK_ENQUIRY>
	</soapenv:Body>
	</soapenv:Envelope>'

	EXEC SPP_SAP_HTTPRequest
	@URI = 'http://kuldb84c.dksh.com:8000/sap/bc/srt/rfc/sap/ymm_ws_0001/300/ymm_ws_0001/binding',
	@methodName = 'POST',
	@requestBody = @RequestText,
	@SoapAction = 'YMM_FM_BAPI_STOCK_ENQUIRY',
	@UserName = 'BSUSER2', @Password = 'BSUSER22',
	@responseText = @xmlOut OUT

	DECLARE @StrHdrToRemove VARCHAR(1000)
	SET @StrHdrToRemove = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:RFC_READ_TABLEResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">'
	SET @xmlOut = REPLACE(@xmlOut, @StrHdrToRemove, '')

	DECLARE @StrFooterToRemove VARCHAR(1000)
	SET @StrHdrToRemove = '</n0:RFC_READ_TABLEResponse></soap-env:Body></soap-env:Envelope>'
	SET @xmlOut = REPLACE(@xmlOut, @StrHdrToRemove, '')
	SET @xml = @xmlOut
END

GO
