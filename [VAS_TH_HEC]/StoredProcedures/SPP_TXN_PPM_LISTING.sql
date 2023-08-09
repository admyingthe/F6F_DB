SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- ========================================================================    
-- Author:  Siow Shen Yee    
-- Create date: 2018-07-13    
-- Description: Retrieve PPM Listing    
-- Example Query: exec SPP_TXN_PPM_LISTING @param=N'{"job_ref_no":"V2022/08/0001","page_index":0,"page_size":20,"search_term":"","export_ind":0}', @user_id=N'8032'    
-- exec SPP_TXN_PPM_LISTING @param=N'{"job_ref_no":"V2022/09/0009","page_index":0,"page_size":20,"search_term":"","export_ind":0}', @user_id=N'10084'--8032
-- exec SPP_TXN_PPM_LISTING @param=N'{"job_ref_no":"G2022/09/00040","page_index":0,"page_size":20,"search_term":"","export_ind":0}', @user_id=N'10084'--

-- Output:    
-- 1) dtCount - Total rows    
-- 2) dt - Data    
-- 3) dtExportInd - Export indicator   
-- 4) dtJobRefNo - Job Ref No    
-- 5) dtExportColumnName - Export column display name    
-- ========================================================================    
 
--SELECT * FROM TBL_TXN_PPM  WHERE job_ref_no in ('V2022/09/0009') AND line_no=1--,'G2022/08/0001'
--Update TBL_TXN_PPM SET PPM_by='MANUFACTURING DATE' where job_ref_no in ('V2022/09/0004') AND line_no=1--
--DELETE FROM TBL_TXN_PPM WHERE job_ref_no in ('V2022/08/0017') AND  line_no=1

--DELETE FROM TBL_TXN_PPM  WHERE job_ref_no='G2022/09/0009'
    
CREATE PROCEDURE [dbo].[SPP_TXN_PPM_LISTING]     
 @param NVARCHAR(MAX),    
 @user_id INT    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
 DECLARE @job_ref_no VARCHAR(50), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1)    
 SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))    
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))    
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))    
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))    
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))    
  
  
   ------------------------------------------------------------  
  
  -- Get user warehouse Code-------  
 DECLARE @w_code varchar(10)
 SET @w_code = (SELECT wh_code FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  --T50
 --select @wh_code
 ------------------------------------------------------------  
 	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date

 IF (SELECT COUNT(1) FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) = 0    
 BEGIN    

		 CREATE TABLE #PPMTEMP
		(
		row_num INT IDENTITY(1,1),
		mll_no VARCHAR(50),
		subcon_wi_no VARCHAR(50),
		prd_code NVARCHAR(2000) NULL,
		required_qty INT,
		batch_no  VARCHAR(150) NULL,
		vas_order VARCHAR(150) NULL,
		expiry_date VARCHAR(100) NULL,
		mfg_date VARCHAR(100) NULL,
		whs_no VARCHAR(10) NULL,
		plant VARCHAR(150) NULL
		)
 


	  DECLARE @json NVARCHAR(MAX), @prd_code VARCHAR(50), @mll_no VARCHAR(50), @required_qty INT ,@subcon_wi_no VARCHAR(50)   ,
	  @batch_no  VARCHAR(50),@vas_order  VARCHAR(50),@uom  VARCHAR(50),@expiry_date VARCHAR(100) ,@mfg_date VARCHAR(100) ,@whs_no VARCHAR(10),@ppm_by VARCHAR(50),@plant VARCHAR(50)
	  IF(LEFT(@job_ref_no,1) = 'S')  
	  BEGIN
		  INSERT INTO  #PPMTEMP 
		  SELECT '' mll_no,subcon_WI_no,  prd_code,  qty_of_goods + 5 required_qty ,batch_no,vas_order,expiry_date,whs_no,plant,NULL manufacturing_date FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no    
		--SELECT @subcon_wi_no = subcon_WI_no, @prd_code = prd_code, @required_qty = qty_of_goods + 5 INTO #PPMTEMP FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no    
			--SET @json = (SELECT vas_activities FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_wi_no AND prd_code = @prd_code)    
	  END
	 -- ELSE IF (LEFT(@job_ref_no,1) = 'V') 
	 -- BEGIN
  --			INSERT INTO  #PPMTEMP 
		--	SELECT  mll_no,'', prd_code, qty_of_goods  required_qty ,batch_no,vas_order,expiry_date,manufacturing_date,whs_no,plant
		--	FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK) 
		--	INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET D ON A.job_ref_no = D.job_ref_no    
		--	WHERE A.job_ref_no = @job_ref_no   AND A.whs_no=@wh_code

	 --END
	 --ELSE 
	 BEGIN
			INSERT INTO  #PPMTEMP 
			SELECT  mll_no,'', prd_code, ttl_qty_eaches required_qty ,batch_no,vas_order, expiry_date,manufacturing_date,whs_no,plant
			FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK) 
			INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET D ON A.job_ref_no = D.job_ref_no    
			WHERE A.job_ref_no = @job_ref_no      AND A.whs_no=@w_code
			--SELECT * FROM #PPMTEMP
		-- SET @json = (SELECT vas_activities FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code)    
	 END  
    
	CREATE TABLE #PPM_PRD
	(
		prd_list NVARCHAR(2000) NULL,
		batch_no  VARCHAR(150) NULL,
		vas_order VARCHAR(150) NULL,
		required_qty INT,
		expiry_date VARCHAR(100) NULL,
		mfg_date VARCHAR(100) NULL,
		whs_no VARCHAR(10) NULL,
		ppm_by VARCHAR(150) NULL,
		plant VARCHAR(150) NULL
	)
	
   DECLARE @count_row  INT=0, @j INT = 1
   SET @count_row=(select count(*) from #PPMTEMP )
   WHILE @j <= @count_row  
   BEGIN  
   
		SELECT @mll_no = mll_no,@subcon_wi_no = subcon_WI_no, @prd_code = prd_code, @required_qty = required_qty,@batch_no=batch_no, @vas_order=vas_order, @expiry_date=expiry_date ,@whs_no=whs_no,@plant=plant,@mfg_date=mfg_date FROM  #PPMTEMP  WHERE row_num=@j

	  IF(LEFT(@job_ref_no,1) = 'S')  
	  BEGIN
			SET @json = (SELECT vas_activities FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_wi_no AND prd_code = @prd_code) 
			INSERT INTO #PPM_PRD(prd_list,batch_no,vas_order,required_qty )
			SELECT *, @batch_no batch_no,@vas_order vas_order,@required_qty  required_qty FROM OPENJSON ( @json ) WITH ( prd_list VARCHAR(2000) '$.prd_code' ) WHERE prd_list <> '' 
	  END
	  ELSE
	  BEGIN
			SELECT @json =vas_activities,@ppm_by=ppm_by FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code 
			

			--SELECT *, CASE WHEN @ppm_by='Batch' THEN @batch_no ELSE '' END batch_no,
			--@vas_order vas_order,@required_qty  required_qty, CASE WHEN @ppm_by='ExpiryDate' THEN @expiry_date ELSE NULL END ,@whs_no whs_no,@ppm_by,@plant, CASE WHEN @ppm_by='MFG_Date' THEN @mfg_date ELSE NULL END  
			--FROM OPENJSON ( @json ) WITH ( prd_list VARCHAR(2000) '$.prd_code' ) WHERE prd_list <> '' 
			
			
			INSERT INTO #PPM_PRD(prd_list,batch_no,vas_order,required_qty,expiry_date,whs_no,ppm_by,plant,mfg_date )
			SELECT *, CASE WHEN @ppm_by='Batch' THEN @batch_no ELSE '' END batch_no,
			@vas_order vas_order,@required_qty  required_qty, CASE WHEN @ppm_by='ExpiryDate' THEN @expiry_date ELSE NULL END ,@whs_no whs_no,
			CASE WHEN @ppm_by='Batch' THEN 'BATCH' ELSE  CASE WHEN @ppm_by='ExpiryDate' THEN 'EXPIRY DATE' ELSE  CASE WHEN @ppm_by='MFG_Date' THEN 'MANUFACTURING DATE' ELSE  'NA'  END   END    END,
			@plant, CASE WHEN @ppm_by='MFG_Date' THEN @mfg_date ELSE NULL END  
			FROM OPENJSON ( @json ) WITH ( prd_list VARCHAR(2000) '$.prd_code' ) WHERE prd_list <> '' 

			

	  END
	 
      SET @j = @j + 1  
	END

	
	
  --SELECT * INTO #PPM_PRD FROM OPENJSON ( @json ) WITH ( prd_list VARCHAR(2000) '$.prd_code' ) WHERE prd_list <> ''    
    
  --SELECT DISTINCT IDENTITY(INT,1,1) as num, LTRIM(Split.a.value('.', 'VARCHAR(100)')) AS prd_code ,   batch_no,vas_order,required_qty
  ----INTO #TEMP_PPM_TXN    
  --FROM (SELECT CAST ('<M>' + REPLACE(prd_list, ',', '</M><M>') + '</M>' AS XML) AS prd_code      
  --FROM #PPM_PRD) AS A CROSS APPLY prd_code.nodes ('/M') AS Split(a);   
  
 
  IF (LEFT(@job_ref_no,1) = 'S')
  BEGIN
	  SELECT  IDENTITY(INT,1,1) as num, LTRIM(Split.a.value('.', 'VARCHAR(100)')) AS prd_code 
	  INTO #TEMP_PPM_TXN1    
	  FROM (SELECT CAST ('<M>' + REPLACE(prd_list, ',', '</M><M>') + '</M>' AS XML) AS prd_code      
	  FROM #PPM_PRD) AS A CROSS APPLY prd_code.nodes ('/M') AS Split(a);   



	  INSERT INTO TBL_TXN_PPM    
	  (line_no, job_ref_no, prd_code, required_qty, sap_qty, issued_qty, manual_ppm, created_date, creator_user_id)    
	  SELECT num, @job_ref_no, prd_code, @required_qty, 0, 0, 0, GETDATE(), @user_id 
	  FROM #TEMP_PPM_TXN1    

	   DROP TABLE #TEMP_PPM_TXN1  



  END
  ELSE
  BEGIN

   SELECT   LTRIM(Split.a.value('.', 'VARCHAR(100)')) AS prd_code,required_qty ,vas_order,batch_no,expiry_date,whs_no,ppm_by,plant,mfg_date
  INTO #TEMP_PPM    
  FROM (SELECT CAST ('<M>' + REPLACE(prd_list, ',', '</M><M>') + '</M>' AS XML) AS prd_code , required_qty, vas_order,batch_no ,expiry_date,whs_no,ppm_by,plant,mfg_date  
  FROM #PPM_PRD ) AS A CROSS APPLY prd_code.nodes ('/M') AS Split(a);   



		SELECT  IDENTITY(INT,1,1) as num, prd_code,required_qty,batch_no,expiry_date,whs_no,ppm_by,plant,mfg_date INTO #TEMP_PPM_TXN
		FROM
		(
			SELECT prd_code,sum(required_qty)required_qty,batch_no,expiry_date,whs_no,ppm_by,plant,mfg_date FROM #TEMP_PPM
			GROUP BY prd_code,batch_no,expiry_date,whs_no,ppm_by,plant,mfg_date
		)A



		
		--SELECT  IDENTITY(INT,1,1) as num, prd_code,required_qty,vas_order,batch_no,expiry_date INTO #TEMP_PPM_TXN_SAP
		--FROM
		--(
		--	SELECT prd_code,required_qty,vas_order,batch_no,expiry_date FROM #TEMP_PPM
		--)A

		
		  INSERT INTO TBL_TXN_PPM    
		  (line_no, job_ref_no, prd_code, required_qty, sap_qty, issued_qty, manual_ppm, created_date, creator_user_id,batch_no,expirydate,whs_no,ppm_by,plant,mfg_date)    
		  SELECT num, @job_ref_no, prd_code, required_qty, 0, 0, 0, @CurrentDateTime, @user_id ,batch_no,expiry_date,whs_no,ppm_by,plant,mfg_date
		  FROM #TEMP_PPM_TXN   
		
		 
		  --INSERT INTO TBL_TXN_PPM_SAP    
		  --(line_no, job_ref_no, prd_code, required_qty, sap_qty, issued_qty, manual_ppm, created_date, creator_user_id,vas_order,batch_no,expirydate)    
		  --SELECT num, @job_ref_no, prd_code, required_qty, 0, 0, 0, GETDATE(), @user_id ,vas_order,batch_no ,expirydate 
		  --FROM #TEMP_PPM_TXN_SAP  
		  --SELECT * FROM #TEMP_PPM
		  --SELECT * FROM #TEMP_PPM_TXN
		     DROP TABLE #TEMP_PPM
		 DROP TABLE #TEMP_PPM_TXN      
		 --DROP TABLE  #TEMP_PPM_TXN_SAP
  END


  
    

    
  DROP TABLE #PPM_PRD    
 
 END    
    
 CREATE TABLE #TEMP_DATA(    
  row_num INT IDENTITY(1,1),    
  prd_code VARCHAR(100),    
  prd_desc NVARCHAR(500),    
  plant VARCHAR(50),    
  sloc VARCHAR(50),    
  required_qty INT DEFAULT 0,    
  sap_qty DECIMAL(18,0) DEFAULT 0,    
  balance_qty INT DEFAULT 0,    
  issued_qty INT DEFAULT 0,    
  remarks NVARCHAR(2000),    
  sap_status CHAR(1),    
  sap_remarks NVARCHAR(2000),    
  system_running_no VARCHAR(10),    
  line_no INT,    
  manual_ppm INT,    
  event_accessright CHAR(1), -- Y: Editable; N: Not editable    
  batch_no VARCHAR(50),
  expirydate datetime NULL,
  mfg_date datetime NULL,
  whs_no VARCHAR(10),
  ppm_by VARCHAR(100),
  job_ref_no VARCHAR(100),
  valid_for_return INT
 )    
    

	DECLARE @current_event AS INTEGER
	 SELECT @current_event =current_event FROM TBL_TXN_WORK_ORDER_JOB_DET  WHERE job_ref_no = @job_ref_no

	 --SELECT * FROM TBL_TXN_PPM

 INSERT INTO #TEMP_DATA    
 (prd_code, prd_desc, plant, sloc, required_qty, sap_qty, issued_qty, remarks, system_running_no, line_no, manual_ppm, sap_status, sap_remarks, event_accessright,batch_no,expirydate,mfg_date,whs_no,ppm_by,job_ref_no)    
 SELECT RTRIM(Ltrim(A.prd_code)), B.prd_desc, A.plant, name  as sloc, required_qty, sap_qty, issued_qty, A.remarks, system_running_no, A.line_no, manual_ppm, 
 CASE WHEN C.confirm_to_indicator='' OR C.confirm_to_indicator is null then C.status   ELSE  C.confirm_to_indicator END,
 --CASE WHEN C.to_confirm_ind='' OR C.to_confirm_ind is null then C.status   ELSE  CASE WHEN CHARINDEX('Transfer order',C.to_confirm_ind)>0 THEN 'R' ELSE CASE WHEN Len(C.to_confirm_ind)=0 THEN  C.to_confirm_ind  ELSE  CASE WHEN C.Status='S' THEN C.Status  ELSE 'E' END END END END ,   
 ' TO NO. ' + ISNULL(C.to_no, '') + ' - ' + C.remarks  , 'Y' ,  
 --CASE WHEN ppm_by='BATCH' THEN A.batch_no ELSE NULL END,
 --CASE WHEN ppm_by='EXPIRY DATE' THEN A.expirydate ELSE NULL END,
 --CASE WHEN ppm_by='MANUFACTURING DATE' THEN A.mfg_date ELSE NULL END,
 A.batch_no,A.expirydate,A.mfg_date,
 A.whs_no,A.ppm_by,A.job_ref_no
 FROM TBL_TXN_PPM A WITH(NOLOCK)    
 INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code    
 INNER JOIN TBL_MST_DDL D WITH(NOLOCK) ON D.code=A.whs_no  AND D.ddl_code= 'ddlsloc'
 LEFT JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP C WITH(NOLOCK)   
 ON A.system_running_no = C.requirement_no AND A.prd_code = C.prd_code   AND C.country_code = 'TH' AND A.line_no=C.line_no --AND A.batch_no = C.batch_no   AND A.expirydate = C.expirydate
 WHERE job_ref_no = @job_ref_no    
 ORDER BY A.line_no    
    
  
  
    
SET @uom=''
 DECLARE @i INT = 1, @ttl_rows INT, @ppm_prd_code VARCHAR(100), @sloc VARCHAR(50),@expirydate VARCHAR(50), @GETITEMS_XML_OUTPUT AS XML  ,@sap_remark   NVARCHAR(500)
 --DECLARE @XML_TEMP TABLE (xml_text NVARCHAR(MAX))    
 SET @ttl_rows = (SELECT COUNT(1) FROM #TEMP_DATA)    
 WHILE @i <= @ttl_rows    
 BEGIN    
  SELECT @ppm_prd_code=prd_code, @ppm_by =ppm_by, @plant=plant, 
		 @whs_no=whs_no, @sloc=sloc, @required_qty=required_qty,
		 @batch_no=CASE WHEN ppm_by='BATCH' THEN batch_no ELSE '' END ,
		 @expirydate=CASE WHEN ppm_by='EXPIRY DATE' THEN CASE WHEN expirydate is NULL then '0000-00-00' ELSE  Convert(VARCHAR(10),expirydate,121) END ELSE '0000-00-00' END  ,
		 @mfg_date =CASE WHEN ppm_by='MANUFACTURING DATE' THEN CASE WHEN mfg_date is NULL then '0000-00-00' ELSE  Convert(VARCHAR(10),mfg_date,121) END ELSE '0000-00-00' END 
		
		 FROM #TEMP_DATA WITH(NOLOCK) WHERE row_num = @i 
    

	--	SELECT @prd_code,@ppm_by,@plant,@wh_code,@stge_loc,@req_qty,@batch,@exp_date,@mfg_date ,@uom
  
  SET @uom = (SELECT base_uom FROM TBL_MST_PRODUCT WITH(NOLOCK) WHERE prd_code = @ppm_prd_code)    
    
	--SELECT prd_code FROM #TEMP_DATA WITH(NOLOCK) WHERE row_num = @i

 EXEC SPP_SAP_RFC_BAPI_MATERIAL_AVAILABILITY_2 @prd_code = @ppm_prd_code, @plant = @plant, @unit = @uom , @stge_loc=@sloc,  @ppm_by=@ppm_by,@req_qty=@required_qty,@wh_code=@whs_no,@batch=@batch_no,@exp_date=@expirydate,@mfg_date=@mfg_date  ,    @XML = @GETITEMS_XML_OUTPUT OUTPUT    
  
    

	
	--SELECT @GETITEMS_XML_OUTPUT
	--(SELECT CAST(Tbl.Col.value('COM_QTY[1]', 'decimal(18,0)') AS INT) FROM @GETITEMS_XML_OUTPUT.nodes('//WMDVEX/item') Tbl(Col)) 


	DECLARE @batch_out varchar(50),@expiry_out varchar(50),@mfg_out varchar(50),@sap_qty INTEGER

	SET @batch_out =(SELECT CAST(Tbl.Col.value('CHARG[1]', 'VARCHAR(50)') AS VARCHAR(50)) FROM @GETITEMS_XML_OUTPUT.nodes('//BATCH_INFO_OUT/item[position()=1]') Tbl(Col))
	SET @expiry_out =(SELECT CAST(Tbl.Col.value('VFDAT[1]', 'VARCHAR(50)') AS VARCHAR(50)) FROM @GETITEMS_XML_OUTPUT.nodes('//BATCH_INFO_OUT/item[position()=1]') Tbl(Col))
	SET @mfg_out =(SELECT CAST(Tbl.Col.value('HSDAT[1]', 'VARCHAR(50)') AS VARCHAR(50)) FROM @GETITEMS_XML_OUTPUT.nodes('//BATCH_INFO_OUT/item[position()=1]') Tbl(Col))
	SET @sap_qty =(SELECT CAST(Tbl.Col.value('VERME[1]', 'decimal(18,0)') AS INTEGER) FROM @GETITEMS_XML_OUTPUT.nodes('//BATCH_INFO_OUT/item[position()=1]') Tbl(Col))

		SET @sap_remark =(SELECT CAST(Tbl.Col.value('MESSAGE[1]', 'NVARCHAR(50)') AS NVARCHAR(50)) FROM @GETITEMS_XML_OUTPUT.nodes('//RETURN/item[position()=1]') Tbl(Col))


  UPDATE #TEMP_DATA  
  SET sap_qty =@sap_qty,--(SELECT top 1 CAST(Tbl.Col.value('COM_QTY[1]', 'decimal(18,0)') AS INT) FROM @GETITEMS_XML_OUTPUT.nodes('//WMDVEX/item') Tbl(Col))    
  expirydate=CASE WHEN @expiry_out ='0000-00-00' THEN  NULL ELSE @expiry_out END, 
  mfg_date=CASE WHEN @mfg_out ='0000-00-00' THEN  NULL ELSE @mfg_out END, --@mfg_out,
  batch_no=@batch_out,
  sap_remarks=@sap_remark
  WHERE row_num = @i AND system_running_no IS NULL    

   
	
  SET @i = @i + 1    
 END    
   --SELECT * FROM TBL_TXN_PPM    WHERE job_ref_no=@job_ref_no


 /** Save SAP returned quantity into table (first time) **/    
 UPDATE A    
 SET sap_qty = B.sap_qty  ,
  expirydate=CASE WHEN A.expirydate is NULL THEN   CASE WHEN Convert(VARCHAR(10),B.expirydate,121)  ='0000-00-00' THEN   NULL   ELSE B.expirydate END   ELSE A.expirydate END,--CASE WHEN A.expirydate is NULL THEN  B.expirydate ELSE A.expirydate END,
  mfg_date=  CASE WHEN A.mfg_date is NULL THEN   CASE WHEN Convert(VARCHAR(10),B.mfg_date,121) ='0000-00-00' THEN   NULL   ELSE B.mfg_date END   ELSE A.mfg_date END,--CASE WHEN A.mfg_date is NULL THEN   B.mfg_date   ELSE A.mfg_date END ,
  batch_no=CASE WHEN A.batch_no is NULL OR A.batch_no='' THEN  B.batch_no ELSE A.batch_no END 
 FROM TBL_TXN_PPM A WITH(NOLOCK)    
 INNER JOIN #TEMP_DATA B WITH(NOLOCK) ON A.job_ref_no = @job_ref_no AND A.prd_code = B.prd_code AND A.line_no=B.line_no

 



    
 UPDATE #TEMP_DATA    
 SET sap_qty = 0    
 WHERE sap_qty IS NULL    
     print '1'
 UPDATE #TEMP_DATA    
 SET balance_qty = required_qty - issued_qty    
     print '2'
 /** Populate issued quantity **/    
 UPDATE #TEMP_DATA    
 SET issued_qty = CASE WHEN ISNULL(sap_qty,0) - required_qty >= 0 THEN required_qty ELSE ISNULL(sap_qty,0) END     
 WHERE issued_qty = 0    

 print '3'
 
 UPDATE A    
 SET issued_qty = B.issued_qty    
 FROM TBL_TXN_PPM A WITH(NOLOCK)    
 INNER JOIN #TEMP_DATA B WITH(NOLOCK) ON A.job_ref_no = @job_ref_no AND A.prd_code = B.prd_code  AND A.line_no=B.line_no  
 WHERE A.issued_qty = 0   
  print '4'
 /** Populate issued quantity **/    
    
 UPDATE A    
 SET event_accessright = 'N'    
 FROM #TEMP_DATA A    
 LEFT JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP B WITH(NOLOCK) ON A.system_running_no = B.requirement_no AND A.prd_code = B.prd_code    
 WHERE B.status = 'R'    
    
 DECLARE @ppm_status CHAR(10), @cntPPMEvent INT, @ppm_reopen_status INT
 SET @cntPPMEvent = (SELECT COUNT(1) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '10')    
 SET @ppm_reopen_status = (SELECT currently_reopened_PPM FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND running_no = (SELECT TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no ORDER BY running_no desc) AND event_id = 40)
 IF @ppm_reopen_status = 1 SET @ppm_status = 'Reopen' ELSE IF @cntPPMEvent > 0 SET @ppm_status = 'Closed' ELSE SET @ppm_status = 'Open'    

 IF @ppm_reopen_status = 1 
 BEGIN
	UPDATE T SET T.valid_for_return = CASE WHEN (
		(P.action_from_reopen = 'Add' OR P.action_from_reopen IS NULL) AND P.system_running_no IS NOT NULL AND S.status = 'R'
	) THEN 1 ELSE 0 END 
	FROM #TEMP_DATA T
	LEFT JOIN TBL_TXN_PPM P ON T.line_no = P.line_no AND T.job_ref_no = P.job_ref_no AND T.prd_code = P.prd_code
	LEFT JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP S WITH(NOLOCK) ON P.system_running_no = S.requirement_no AND P.prd_code = S.prd_code AND P.job_ref_no = S.workorder_no AND S.country_code = 'TH' AND P.line_no = S.line_no 
 END

    
 INSERT INTO TBL_ADM_AUDIT_TRAIL    
 (module, key_code, action , action_by, action_date)    
 VALUES('PPM-SEARCH', @job_ref_no, 'Created PPM', @user_id, @CurrentDateTime)    
     
 /** OUTPUT **/    
 IF @search_term <> ''    
  SELECT COUNT(1) as ttl_rows FROM #TEMP_DATA -- 1    
  WHERE ( prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END)    
 ELSE     
  SELECT COUNT(1) as ttl_rows FROM #TEMP_DATA -- 1    
    
 --SELECT * FROM #TEMP_DATA -- 2    

 SELECT row_num,prd_code,prd_desc,plant,sloc,required_qty,sap_qty,balance_qty,issued_qty,remarks,sap_status,sap_remarks,system_running_no,line_no,manual_ppm,event_accessright,
 batch_no,Convert(varchar(10),expirydate,121) expirydate,Convert(varchar(10),mfg_date,121) mfg_date ,whs_no,ppm_by,valid_for_return
 FROM #TEMP_DATA -- 2    

 WHERE ( prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END)    
 ORDER BY line_no asc    
 OFFSET @page_index * @page_size ROWS    
 FETCH NEXT @page_size ROWS ONLY    
    
 SELECT @export_ind as export_ind --3    

     DECLARE @JobFormat VARCHAR(25)=(SELECT  [format_code] FROM [TBL_REDRESSING_JOB_FORMAT])

 IF(LEFT(@job_ref_no,1) = 'V' OR LEFT(@job_ref_no,1) = 'G')  
 BEGIN  
   SELECT TOP 1 @job_ref_no as job_ref_no, CASE WHEN @JobFormat='JobFormat' THEN job_ref_no ELSE work_ord_ref  END work_ord_ref, @ppm_status as ppm_status,
   prd_code,vas_order, inbound_doc,to_no,batch_no
   FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4    
 END  
 ELSE IF(LEFT(@job_ref_no,1) = 'S')  
 BEGIN  
   SELECT @job_ref_no as job_ref_no, work_ord_ref as work_ord_ref, @ppm_status as ppm_status    
   FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4  
 END  
    
 SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --5    
 FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)    
 WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'PPM-SEARCH') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#TEMP_DATA'))    
    
 DROP TABLE #TEMP_DATA    
END
GO
