SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Get stock from SAP
-- ================================

CREATE PROCEDURE [dbo].[SPP_SAP_RFC_BAPI_MATERIAL_AVAILABILITY_2]
	@prd_code NVARCHAR(200),
	@plant	NVARCHAR(200),
	@unit NVARCHAR(10),
	@XML XML OUTPUT
AS

	DECLARE @xmlOut Nvarchar(MAX)
	DECLARE @RequestText as Nvarchar(MAX)

	SET @RequestText='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
	<soapenv:Header/>
	<soapenv:Body>
      <urn:BAPI_MATERIAL_AVAILABILITY>
         <MATERIAL>' + '000000000' + LTRIM(@prd_code) +'</MATERIAL>
         <PLANT>' + @plant + '</PLANT>
         <UNIT>' + @unit + '</UNIT>
         <WMDVEX>
            <!--Zero or more repetitions:-->
            <item>
               <!--Optional:-->
               <BDCNT></BDCNT>
               <!--Optional:-->
               <REQ_DATE></REQ_DATE>
               <!--Optional:-->
               <REQ_QTY></REQ_QTY>
               <!--Optional:-->
               <COM_DATE></COM_DATE>
               <!--Optional:-->
               <COM_QTY></COM_QTY>
            </item>
         </WMDVEX>
         <WMDVSX>
            <!--Zero or more repetitions:-->
            <item>
               <!--Optional:-->
               <REQ_DATE></REQ_DATE>
               <!--Optional:-->
               <REQ_QTY></REQ_QTY>
               <!--Optional:-->
               <DELKZ></DELKZ>
               <!--Optional:-->
               <YLINE></YLINE>
            </item>
         </WMDVSX>
      </urn:BAPI_MATERIAL_AVAILABILITY>
   </soapenv:Body>
</soapenv:Envelope>'
EXEC SPP_SAP_HTTPRequest_2 -- SY : To avoid output-ing Error Message. To check for Error Message : EXEC SPP_SAP_HTTPRequest
	 
--Q00    -- previous on date 17/1/2023
--@URI ='http://mykulpidb01q.dksh.com:50000/XISOAPAdapter/MessageServlet?senderParty=P_B2B_TH_CG&senderService=BC_RTM_TH&receiverParty=&receiverService=&interface=SI_OB_S_SOAP_Messages&interfaceNamespace=http://dksh.com/thailand/RTM/Webservice',  

-- provide by Q00  by PI Ameer
@URI ='https://kulas02d.dksh.com:443/XISOAPAdapter/MessageServlet?channel=P_B2B_GLOBAL_VAS:BC_GLOBAL_VAS:CC_S_SOAP_SYNC',
--Q00 BAU
--@URI = 'https://kulas02d.dksh.com:443/XISOAPAdapter/MessageServlet?channel=P_B2B_TH_CG:BC_RTM_TH_BAU:CC_S_SOAP_SYNC_BAU',

--@URI ='http://kulwddb08p.dksh.com:8000/sap/bc/srt/rfc/sap/ymm_ws_0001/300/ymm_ws_0001/binding',
@methodName = 'POST', 
@requestBody = @RequestText,
@SoapAction = 'BAPI_MATERIAL_AVAILABILITY',
--@UserName ='KRBTC01', @Password ='pokemon1',@responseText = @xmlOut out
@UserName ='B2B', @Password ='dkshsap123',@responseText = @xmlOut out


DECLARE @StrHdrToRemove AS VARCHAR(1000)
SET @StrHdrToRemove = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:RFC_READ_TABLEResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">'

SET @xmlOut = REPLACE(@xmlOut,@StrHdrToRemove,'')

SET @StrHdrToRemove = '</n0:RFC_READ_TABLEResponse></soap-env:Body></soap-env:Envelope>'

SET @xmlOut = REPLACE(@xmlOut,@StrHdrToRemove,'')

SET @xml = @xmlOut
GO
