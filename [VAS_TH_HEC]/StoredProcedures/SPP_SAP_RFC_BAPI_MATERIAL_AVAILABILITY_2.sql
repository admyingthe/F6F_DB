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
	@prd_code CHAR(18),
	@plant	NVARCHAR(200),
	@unit NVARCHAR(10),
	@stge_loc  VARCHAR(100),
	@ppm_by  NVARCHAR(100),
	@req_qty INT,
	@wh_code  NVARCHAR(100),
	@batch  NVARCHAR(100),
	@exp_date  NVARCHAR(100),
	@mfg_date  NVARCHAR(100),	
	@XML XML OUTPUT
AS

	DECLARE @xmlOut Nvarchar(MAX)
	DECLARE @RequestText as Nvarchar(MAX)


SET @RequestText='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:YLE_FM_GET_BATCH_INFO>
         <!--You may enter the following 3 items in any order-->
         <BATCH_INFO_IN>
            <!--Zero or more repetitions:-->
            <item>
               <!--Optional:-->
               <PPM_IND>' + @ppm_by + '</PPM_IND>
               <!--Optional:-->
               <WERKS>' + @plant + '</WERKS>
               <!--Optional:-->
               <LGORT>' + @stge_loc + '</LGORT>
               <!--Optional:-->
               <LGNUM>' + @wh_code + '</LGNUM>
               <!--Optional:-->
               <MATNR>000000000' + @prd_code + '</MATNR>
               <!--Optional:-->
               <REQ_QTY>' +Convert(varchar(100), @req_qty )+ '</REQ_QTY>
               <!--Optional:-->
               <MEINS>' + @unit + '</MEINS>
               <!--Optional:-->
               <CHARG>' + @batch + '</CHARG>
               <!--Optional:-->
               <VFDAT>' + @exp_date + '</VFDAT>
               <!--Optional:-->
               <HSDAT>' + @mfg_date + '</HSDAT>
            </item>
         </BATCH_INFO_IN>
         <BATCH_INFO_OUT>
            <!--Zero or more repetitions:-->
         </BATCH_INFO_OUT>
         <RETURN>
            <!--Zero or more repetitions:-->
         </RETURN>
      </urn:YLE_FM_GET_BATCH_INFO>
   </soapenv:Body>
</soapenv:Envelope>'

Print '-------------------------------RequestText START---------------------------------------------'
Print @RequestText
Print '-------------------------------RequestText END---------------------------------------------'

--    SET @RequestText=    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
--   <soapenv:Header/>
--   <soapenv:Body>
--      <urn:YLE_FM_GET_BATCH_INFO>
--         <!--You may enter the following 3 items in any order-->
--         <BATCH_INFO_IN>
--            <!--Zero or more repetitions:-->
--            <item>
--               <!--Optional:-->
--               <PPM_IND>NA</PPM_IND>
--               <!--Optional:-->
--               <WERKS>TH54</WERKS>
--               <!--Optional:-->
--               <LGORT>1010</LGORT>
--               <!--Optional:-->
--               <LGNUM>T50</LGNUM>
--               <!--Optional:-->
--               <MATNR>000000000400019150</MATNR>
--               <!--Optional:-->
--               <REQ_QTY>4</REQ_QTY>
--               <!--Optional:-->
--               <MEINS>PC</MEINS>
--               <!--Optional:-->
--               <CHARG></CHARG>
--               <!--Optional:-->
--               <VFDAT>0000-00-00</VFDAT>
--               <!--Optional:-->
--               <HSDAT>0000-00-00</HSDAT>
--            </item>
--         </BATCH_INFO_IN>
--         <BATCH_INFO_OUT>
--            <!--Zero or more repetitions:-->
--         </BATCH_INFO_OUT>
--         <RETURN>
--            <!--Zero or more repetitions:-->
--            <item>
--               <!--Optional:-->
--               <TYPE></TYPE>
--               <!--Optional:-->
--               <CODE></CODE>
--               <!--Optional:-->
--               <MESSAGE></MESSAGE>
--               <!--Optional:-->
--               <LOG_NO></LOG_NO>
--               <!--Optional:-->
--               <LOG_MSG_NO></LOG_MSG_NO>
--               <!--Optional:-->
--               <MESSAGE_V1></MESSAGE_V1>
--               <!--Optional:-->
--               <MESSAGE_V2></MESSAGE_V2>
--               <!--Optional:-->
--               <MESSAGE_V3></MESSAGE_V3>
--               <!--Optional:-->
--               <MESSAGE_V4></MESSAGE_V4>
--            </item>
--         </RETURN>
--      </urn:YLE_FM_GET_BATCH_INFO>
--   </soapenv:Body>
--</soapenv:Envelope>'


--print '---------------------------------Test XML START------------------------------------'

--SET @RequestText='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
--   <soapenv:Header/>
--   <soapenv:Body>
--      <urn:YLE_FM_GET_BATCH_INFO>
--         <!--You may enter the following 3 items in any order-->
--         <BATCH_INFO_IN>
--            <!--Zero or more repetitions:-->
--            <item>
--               <!--Optional:-->
--               <PPM_IND>MANUFACTURING DATE</PPM_IND>
--               <!--Optional:-->
--               <WERKS>TH54</WERKS>
--               <!--Optional:-->
--               <LGORT>1010</LGORT>
--               <!--Optional:-->
--               <LGNUM>T50</LGNUM>
--               <!--Optional:-->
--               <MATNR>000000000400019150</MATNR>
--               <!--Optional:-->
--               <REQ_QTY>88.000</REQ_QTY>
--               <!--Optional:-->
--               <MEINS>PC</MEINS>
--               <!--Optional:-->
--               <CHARG></CHARG>
--               <!--Optional:-->
--               <VFDAT></VFDAT>
--               <!--Optional:-->
--               <HSDAT>2022-08-01</HSDAT>
--            </item>
--         </BATCH_INFO_IN>
--         <BATCH_INFO_OUT>
--            <!--Zero or more repetitions:-->
--            <item>
--               <!--Optional:-->
--               <WERKS></WERKS>
--               <!--Optional:-->
--               <LGORT></LGORT>
--               <!--Optional:-->
--               <LGNUM></LGNUM>
--               <!--Optional:-->
--               <MATNR></MATNR>
--               <!--Optional:-->
--               <VERME></VERME>
--               <!--Optional:-->
--               <MEINS></MEINS>
--               <!--Optional:-->
--               <CHARG></CHARG>
--               <!--Optional:-->
--               <VFDAT></VFDAT>
--               <!--Optional:-->
--               <HSDAT></HSDAT>
--            </item>
--         </BATCH_INFO_OUT>
--         <RETURN>
--            <!--Zero or more repetitions:-->
--            <item>
--               <!--Optional:-->
--               <TYPE></TYPE>
--               <!--Optional:-->
--               <CODE></CODE>
--               <!--Optional:-->
--               <MESSAGE></MESSAGE>
--               <!--Optional:-->
--               <LOG_NO></LOG_NO>
--               <!--Optional:-->
--               <LOG_MSG_NO></LOG_MSG_NO>
--               <!--Optional:-->
--               <MESSAGE_V1></MESSAGE_V1>
--               <!--Optional:-->
--               <MESSAGE_V2></MESSAGE_V2>
--               <!--Optional:-->
--               <MESSAGE_V3></MESSAGE_V3>
--               <!--Optional:-->
--               <MESSAGE_V4></MESSAGE_V4>
--            </item>
--         </RETURN>
--      </urn:YLE_FM_GET_BATCH_INFO>
--   </soapenv:Body>
--</soapenv:Envelope>'



--print '---------------------------------Test XML END------------------------------------'








EXEC SPP_SAP_HTTPRequest_2 -- SY : To avoid output-ing Error Message. To check for Error Message : EXEC SPP_SAP_HTTPRequest
	 
--Q00  
@URI ='http://mykulpidb01q.dksh.com:50000/XISOAPAdapter/MessageServlet?senderParty=P_B2B_GLOBAL_VAS&senderService=BC_VAS_TH&receiverParty=&receiverService=&interface=SI_OB_S_TH_SOAP_Messages&interfaceNamespace=http://dksh.com/global/VAS/MAT_Availability',  

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

Print '------------------------------------------'
Print '------------------------------Output Start'
Print '------------------------------------------'
Print @xmlOut
Print '-------------------------------------'
Print '------------------------------Output End'
GO
