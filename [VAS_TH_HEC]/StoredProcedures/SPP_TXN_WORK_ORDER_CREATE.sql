SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================
-- Author:		Smita Thorat
-- Create date: 2022-07-15
-- Description: Create Work Order
-- Example Query:
-- ==============================
--EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0406","vas_order":"0000031666","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"FERRING/PICOPREP/T11273CA/2029-08-31","client_name":"FERRING","prd_code":"101127437","prd_desc":"PENTASA TAB ORAL 500MG BL 10X1PC","batch_no":"T14735C","expiry_date":"2029-08-31","ttl_qty_eaches":"10","mll_no":"MLL040600RD00001","others":"","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"60","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"20"},{"client_code":"0406","vas_order":"0000031666","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"FERRING/PICOPREP/T11273CA/2029-08-31","client_name":"FERRING","prd_code":"101127438","prd_desc":"PICOPREP PWD FOR ORAL SOL SAC 2X16.1G","batch_no":"T11273CA","expiry_date":"2029-08-31","ttl_qty_eaches":"50","mll_no":"MLL040600RD00001","others":"","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"60","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"100"}],"mode":"New"}',@user_id=N'8032'
 -- EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0143","vas_order":"0000031669","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS /PROCELL/95783/2022-11-30","client_name":"0143 ROCHE DIAGNOSTICS","prd_code":"100130949","prd_desc":"PROCELL ELECSYS 6X380ML","batch_no":"53599401","expiry_date":"2029-08-31","ttl_qty_eaches":"150","mll_no":"MLL014301RD00001","others":"t1","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"1230","num_of_days_to_complete":"2","update":"Update","origional_ttl_qty_eaches":"250","inbound_doc":"9162080920","to_no":"1114424920"},{"client_code":"0143","vas_order":"0000031670","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS /PROCELL/95783/2022-11-30","client_name":"ROCHE DIAGNOSTICS","prd_code":"100130949","prd_desc":"PROCELL ELECSYS 6X380ML","batch_no":"991012","expiry_date":"2024-02-29","ttl_qty_eaches":"250","mll_no":"MLL014301RD00001","others":"t2","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"1230","num_of_days_to_complete":"2","update":"Update","origional_ttl_qty_eaches":"500","inbound_doc":"9162080921","to_no":"1114424921"},{"client_code":"0143","vas_order":"0000031681","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS /PROCELL/95783/2022-11-30","client_name":"ROCHE DIAGNOSTICS","prd_code":"100130949","prd_desc":"PROCELL ELECSYS 6X380ML","batch_no":"SH728F","expiry_date":"2024-02-29","ttl_qty_eaches":"400","mll_no":"MLL014301RD00001","others":"t3","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"1230","num_of_days_to_complete":"2","update":"Update","origional_ttl_qty_eaches":"500","inbound_doc":"9162080934","to_no":"1114424934"},{"client_code":"0143","vas_order":"0000031681","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS /PROCELL/95783/2022-11-30","client_name":"ROCHE DIAGNOSTICS","prd_code":"100130949","prd_desc":"PROCELL ELECSYS 6X380ML","batch_no":"95783","expiry_date":"2022-11-30","ttl_qty_eaches":"100","mll_no":"MLL014301RD00001","others":"t4","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"1230","num_of_days_to_complete":"2","update":"Update","origional_ttl_qty_eaches":"250","inbound_doc":"9162080934","to_no":"1114424934"},{"client_code":"0143","vas_order":"0000031697","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS /PROCELL/95783/2022-11-30","client_name":"ROCHE DIAGNOSTICS","prd_code":"100130949","prd_desc":"PROCELL ELECSYS 6X380ML","batch_no":"MK37474","expiry_date":"2024-02-29","ttl_qty_eaches":"200","mll_no":"MLL014301RD00001","others":"t5","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"1230","num_of_days_to_complete":"2","update":"Update","origional_ttl_qty_eaches":"500","inbound_doc":"9162080950","to_no":"1114424950"},{"client_code":"0143","vas_order":"0000031697","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS /PROCELL/95783/2022-11-30","client_name":"ROCHE DIAGNOSTICS","prd_code":"100130949","prd_desc":"PROCELL ELECSYS 6X380ML","batch_no":"KL99239","expiry_date":"2022-11-30","ttl_qty_eaches":"130","mll_no":"MLL014301RD00001","others":"t6","urgent":1,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"1230","num_of_days_to_complete":"2","update":"Update","origional_ttl_qty_eaches":"250","inbound_doc":"9162080950","to_no":"1114424950"}],"mode":"New"}',@user_id=N'8032'

 --EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0406","vas_order":"0000031677","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"FERRING/2024-02-29","client_name":"FERRING","prd_code":"101127438","prd_desc":"PICOPREP PWD FOR ORAL SOL SAC 2X16.1G","batch_no":"Y627494","expiry_date":"2024-02-29","ttl_qty_eaches":"100","mll_no":"MLL040600RD00001","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"100","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"100","inbound_doc":"9162080930","to_no":"1114424930"}],"mode":"New"}',@user_id=N'8032'
  --EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0207","vas_order":"0000000044","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"RECKITT BENCKISER/2030-12-31","client_name":"RECKITT BENCKISER","prd_code":"100166390","prd_desc":"CARDIPRIN TAB 100MG 30","batch_no":"220207","expiry_date":"2030-12-31","ttl_qty_eaches":"80","to_no":"1114859936","mll_no":"MLL020700RD00012","manufacturing_date":"2022-08-01","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"130","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"80","inbound_doc":"9162099699"},{"client_code":"0207","vas_order":"0000000044","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"RECKITT BENCKISER/2030-12-31","client_name":"RECKITT BENCKISER","prd_code":"100277794","prd_desc":"OPTREX EYE LOTION 300ML ENG","batch_no":"220207-02","expiry_date":"2030-12-31","ttl_qty_eaches":"50","to_no":"1114859934","mll_no":"MLL020700RD00012","manufacturing_date":"2022-08-01","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"130","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"50","inbound_doc":"9162099699"}],"mode":"New"}',@user_id=N'8032'
  --10
  --EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0143","vas_order":"0000000053","vas_order_date":"2022-08-09","vas_order_time":"16:20:29","qi_type":"","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS/2029-05-31","client_name":"ROCHE DIAGNOSTICS","prd_code":"100408864","prd_desc":"ACCU CHEK SAFE-T-PRO UNO 200","batch_no":"220208","expiry_date":"2029-05-31","ttl_qty_eaches":"10","to_no":"1114860082","mll_no":"MLL014300RD00003","manufacturing_date":"2021-01-01","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"10","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"20","inbound_doc":"9162099739"}],"mode":"New"}',@user_id=N'8032'
  --3
  --EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0143","vas_order":"0000000053","vas_order_date":"2022-08-09","vas_order_time":"16:20:29","qi_type":"","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS/2029-05-31","client_name":"ROCHE DIAGNOSTICS","prd_code":"100408864","prd_desc":"ACCU CHEK SAFE-T-PRO UNO 200","batch_no":"220208","expiry_date":"2029-05-31","ttl_qty_eaches":"3","to_no":"1114860082","mll_no":"MLL014300RD00003","manufacturing_date":"2021-01-01","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"3","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"10","inbound_doc":"9162099739"}],"mode":"New"}',@user_id=N'8032'
  --4
  --EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0143","vas_order":"0000000053","vas_order_date":"2022-08-09","vas_order_time":"16:20:29","qi_type":"","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ROCHE DIAGNOSTICS/2029-05-31","client_name":"ROCHE DIAGNOSTICS","prd_code":"100408864","prd_desc":"ACCU CHEK SAFE-T-PRO UNO 200","batch_no":"220208","expiry_date":"2029-05-31","ttl_qty_eaches":"4","to_no":"1114860082","mll_no":"MLL014300RD00003","manufacturing_date":"2021-01-01","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"4","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"7","inbound_doc":"9162099739"}],"mode":"New"}',@user_id=N'8032'

   --EXEC [SPP_TXN_WORK_ORDER_CREATE]    @submit_obj=N'{"items":[{"client_code":"0303","vas_order":"0000000005","vas_order_date":"2022-09-06","vas_order_time":"15:08:10","qi_type":"","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ALCON/8065977758/20220830/2029-05-31","client_name":"ALCON","prd_code":"121042798","prd_desc":"8065977763 MONARCH III (D) CTG SGL U","batch_no":"20220830","expiry_date":"2028-10-31","ttl_qty_eaches":"20","to_no":"2026555741","mll_no":"MLL030302RD00001","manufacturing_date":"","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"50","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"100","inbound_doc":"9162099848"},{"client_code":"0303","vas_order":"0000000005","vas_order_date":"2022-09-06","vas_order_time":"15:08:10","qi_type":"","save":"Save","cancel":"Back","print":"Print","work_ord_ref":"ALCON/8065977758/20220830/2029-05-31","client_name":"ALCON","prd_code":"121042736","prd_desc":"8065977758 MONARCH II (B) CTG SGL U","batch_no":"20220830","expiry_date":"2029-05-31","ttl_qty_eaches":"30","to_no":"2026555741","mll_no":"MLL030302RD00001","manufacturing_date":"","others":"","urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"50","num_of_days_to_complete":"","update":"Update","origional_ttl_qty_eaches":"100","inbound_doc":"9162099848"}],"mode":"New"}',@user_id=N'10085'


CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_CREATE] 
	@submit_obj	nvarchar(max),
	@user_id	VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @work_ord_ref VARCHAR(50), @vas_order VARCHAR(50), @client_code VARCHAR(50), @prd_code VARCHAR(50), @batch_no VARCHAR(50),--  @to_no VARCHAR(50), 
	@item_no VARCHAR(50), @ttl_qty_eaches INT, @arrival_date VARCHAR(50), @mll_no VARCHAR(50), 
	@urgent VARCHAR(10), @commencement_date VARCHAR(50), @completion_date VARCHAR(50), @qty_of_goods INT, @num_of_days_to_complete INT, 
	@others NVARCHAR(250), @mode VARCHAR(50), @job_ref_no VARCHAR(50)

	--SET @work_ord_ref = (SELECT JSON_VALUE(@submit_obj, '$.work_ord_ref'))
	--SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
	--SET @vas_order = (SELECT JSON_VALUE(@submit_obj, '$.vas_order'))
	--SET @prd_code = (SELECT JSON_VALUE(@submit_obj, '$.prd_code'))
	--SET @batch_no = (SELECT JSON_VALUE(@submit_obj, '$.batch_no'))
	--SET @item_no = (SELECT JSON_VALUE(@submit_obj, '$.item_no'))
	--SET @arrival_date = (SELECT JSON_VALUE(@submit_obj, '$.arrival_date'))
	--SET @ttl_qty_eaches = (SELECT JSON_VALUE(@submit_obj, '$.ttl_qty_eaches'))
	--SET @mll_no = (SELECT JSON_VALUE(@submit_obj, '$.mll_no'))
	--SET @urgent = (SELECT JSON_VALUE(@submit_obj, '$.urgent'))
	--SET @commencement_date = (SELECT JSON_VALUE(@submit_obj, '$.commencement_date'))
	--SET @completion_date = (SELECT JSON_VALUE(@submit_obj, '$.completion_date'))
	--SET @qty_of_goods = (SELECT JSON_VALUE(@submit_obj, '$.qty_of_goods'))
	--SET @num_of_days_to_complete = (SELECT JSON_VALUE(@submit_obj, '$.num_of_days_to_complete'))
	--SET @others = (SELECT JSON_VALUE(@submit_obj, '$.others'))
	SET @mode = (SELECT JSON_VALUE(@submit_obj, '$.mode'))
	SET @job_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.job_ref_no'))

	

	SELECT * INTO #TempProductWODetails FROM OPENJSON(@submit_obj, N'$.items') WITH (
	work_ord_ref VARCHAR(50) '$.work_ord_ref',
	vas_order VARCHAR(50) '$.vas_order',
	to_no VARCHAR(50) '$.to_no',
	inbound_doc VARCHAR(50) '$.inbound_doc',
	client_code VARCHAR(50)  '$.client_code',
	prd_code VARCHAR(50) '$.prd_code' ,
	batch_no VARCHAR(50)  '$.batch_no', 
	item_no VARCHAR(50)  '$.item_no',
	ttl_qty_eaches INT  '$.ttl_qty_eaches',
	arrival_date VARCHAR(50)  '$.arrival_date',
	mll_no VARCHAR(50)  '$.mll_no', 
	urgent VARCHAR(10)  '$.urgent',
	commencement_date VARCHAR(50)  '$.commencement_date',
	completion_date VARCHAR(50)  '$.completion_date',
	vas_order_date VARCHAR(50)  '$.vas_order_date',
	vas_order_time VARCHAR(50)  '$.vas_order_time',
	qi_type VARCHAR(50)  '$.qi_type',
	manufacturing_date VARCHAR(50)  '$.manufacturing_date',
	qty_of_goods INT  '$.qty_of_goods',
	num_of_days_to_complete INT  '$.num_of_days_to_complete', 
	others NVARCHAR(250)  '$.others',
	origional_ttl_qty_eaches NVARCHAR(250)  '$.origional_ttl_qty_eaches',
	job_ref_no NVARCHAR(250)  '$.job_ref_no'
	)
	
	--select * FROM #TempProductWODetails


	IF @commencement_date = '' SET @commencement_date = NULL
	IF @completion_date = '' SET @completion_date = NULL

	EXEC REPLACE_SPECIAL_CHARACTER @others, @others OUTPUT

	DECLARE @qty_to_use INT
	IF (@qty_of_goods <> 0) SET @qty_to_use = @qty_of_goods
	ELSE SET @qty_to_use = @ttl_qty_eaches


	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date



	IF (@mode = 'New')
	BEGIN
	--print'111'
	DECLARE @CountGroup  INT=0
	select @CountGroup=count(prd_code) FROM #TempProductWODetails


	DECLARE @new_job_ref_no VARCHAR(50) = 1, @len INT = 4,@len1  INT = 5, @to_no VARCHAR(50), @inbound_doc VARCHAR(50)
	if @CountGroup>1
	BEGIN
	 --   SELECT TOP 1 @new_job_ref_no = CAST(CAST(RIGHT(job_ref_no, @len) as INT) + 1 AS VARCHAR(50))
		--							FROM (SELECT job_ref_no FROM TBL_TXN_WORK_ORDER WHERE job_ref_no like 'G%' AND SUBSTRING(job_ref_no, 2, @len) = CAST(YEAR(GETDATE()) as VARCHAR(50)) AND SUBSTRING(job_ref_no, 7, 2) = CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50))) A ORDER BY CAST(RIGHT(job_ref_no, @len) AS INT) DESC
		--SET @new_job_ref_no = (SELECT 'G' + CAST(YEAR(GETDATE()) as VARCHAR(50)) + '/' + CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50)) + '/' + REPLICATE('0', @len1 - LEN(@new_job_ref_no+1)) + @new_job_ref_no)
	

		    		SELECT  TOP 1 @new_job_ref_no =CASE WHEN LEN(job_ref_no)=13 THEN  CAST(CAST(RIGHT(job_ref_no, @len) as INT) + 1 AS VARCHAR(50))  ELSE CAST(CAST(RIGHT(job_ref_no, @len1) as INT) + 1 AS VARCHAR(50))  END	 
									FROM (SELECT job_ref_no FROM TBL_TXN_WORK_ORDER WHERE job_ref_no like 'G%' AND SUBSTRING(job_ref_no, 2, @len) = CAST(YEAR(GETDATE()) as VARCHAR(50)) AND SUBSTRING(job_ref_no, 7, 2) = CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50))) A ORDER BY CASE WHEN LEN(job_ref_no)=13 THEN  CAST(RIGHT(job_ref_no, @len) AS INT) ELSE CAST(RIGHT(job_ref_no, @len1) AS INT) END DESC
		SET @new_job_ref_no = (SELECT 'G' + CAST(YEAR(GETDATE()) as VARCHAR(50)) + '/' + CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50)) + '/' + REPLICATE('0', @len1 - LEN(@new_job_ref_no)) + @new_job_ref_no)


	END
	ELSE
	BEGIN
	--SELECT TOP 1 @new_job_ref_no = CAST(CAST(RIGHT(job_ref_no, @len1) as INT) + 1 AS VARCHAR(50))
	--								FROM (SELECT job_ref_no FROM TBL_TXN_WORK_ORDER WHERE job_ref_no like 'V%' AND SUBSTRING(job_ref_no, 2, @len) = CAST(YEAR(GETDATE()) as VARCHAR(50)) AND SUBSTRING(job_ref_no, 7, 2) = CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50))) A ORDER BY CAST(RIGHT(job_ref_no, @len) AS INT) DESC
	--	SET @new_job_ref_no = (SELECT 'V' + CAST(YEAR(GETDATE()) as VARCHAR(50)) + '/' + CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50)) + '/' + REPLICATE('0', @len1 - LEN(@new_job_ref_no)) + @new_job_ref_no)
		

		--SELECT  TOP 1 @new_job_ref_no =CASE WHEN LEN(job_ref_no)=13 THEN  CAST(CAST(RIGHT(job_ref_no, @len) as INT) + 1 AS VARCHAR(50))  ELSE CAST(CAST(RIGHT(job_ref_no, @len1) as INT) + 1 AS VARCHAR(50))  END	 
									--FROM (SELECT job_ref_no FROM TBL_TXN_WORK_ORDER WHERE job_ref_no like 'V%' AND SUBSTRING(job_ref_no, 2, @len) = CAST(YEAR(GETDATE()) as VARCHAR(50)) AND SUBSTRING(job_ref_no, 7, 2) = CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50))) A ORDER BY CASE WHEN LEN(job_ref_no)=13 THEN  CAST(RIGHT(job_ref_no, @len) AS INT) ELSE CAST(RIGHT(job_ref_no, @len1) AS INT) END DESC

		--SET @new_job_ref_no =   (SELECT 'V' + CAST(YEAR(GETDATE()) as VARCHAR(50)) + '/' + CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50)) + '/' + REPLICATE('0', @len1 - LEN(@new_job_ref_no)) + @new_job_ref_no)
		EXEC SPP_MST_GENERATE_RUNNING_NUMBER 'REDRESSING-JOB-REF-NO', @new_job_ref_no OUTPUT
	END
	   
		

		


		--SET @to_no = (SELECT TOP 1 to_no FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE vas_order = @vas_order AND prd_code = @prd_code AND batch_no = @batch_no ) -- AND item_no = @item_no)
		--SET @inbound_doc = (SELECT TOP 1 inbound_doc FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) 
		--WHERE vas_order = (SELECT top 1 vas_order FROM TBL_TXN_WORK_ORDER) 
		--AND prd_code = (SELECT top 1 prd_code FROM TBL_TXN_WORK_ORDER) AND batch_no = (SELECT top 1 batch_no FROM TBL_TXN_WORK_ORDER) ) --AND item_no = @item_no)


		DECLARE @countRec INT=0;
		--(SELECT COUNT(*) FROM TBL_TXN_WORK_ORDER I WITH(NOLOCK) 
		--INNER JOIN #TempProductWODetails T ON I.work_ord_ref = T.work_ord_ref AND I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no  AND I.inbound_doc = T.inbound_doc --AND to_no = T.to_no
		--where   @new_job_ref_no  like 'V%')
		IF @countRec = 0 
		BEGIN


			SELECT  count(1) countTransferRec, country_code,t1.inbound_doc,workorder_no,requirement_no,t1.vas_order,t1.to_no,whs_no,ssto_unit_no,dsto_unit_no,picking_area,upl_point,plant,supplier_code,supplier_name,
			to_date,to_time,sloc,t1.prd_code,t1.prd_desc,uom,t1.batch_no,SUM(qty) qty,expiry_date,stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,temp_logger_released_date,
			temp_logger_released_by,delete_flag,t2.qi_type,manufacturing_date,t1.special_stock_indicator,t1.special_stock  INTO #TRANSFERORDER
			FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER  t1  
			INNER JOIN (SELECT vas_order,prd_code,batch_no,inbound_doc,to_no,qi_type FROM #TempProductWODetails )t2 
			ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no  AND t1.inbound_doc = t2.inbound_doc AND t1.to_no = t2.to_no
			where t1.workorder_no='' or t1.workorder_no is null
			GROUP BY country_code,t1.inbound_doc,workorder_no,requirement_no,t1.vas_order,t1.to_no,whs_no,ssto_unit_no,dsto_unit_no,picking_area,upl_point,plant,supplier_code,supplier_name,
			to_date,to_time,sloc,t1.prd_code,t1.prd_desc,uom,t1.batch_no,expiry_date,stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,temp_logger_released_date,
			temp_logger_released_by,delete_flag,t2.qi_type ,workorder_no,manufacturing_date,t1.special_stock_indicator,t1.special_stock

			--SELECT * FROM #TRANSFERORDER


			SELECT  count(1) countTransferRec, country_code,t1.inbound_doc,t1.vas_order,vas_order_date,whs_no,plant,supplier_code,supplier_name,t1.prd_code,prd_desc,uom,
			t1.batch_no,sum(qty)qty,expiry_date,stock_category,created_date,created_by,delete_flag,qi_type,workorder_no,manufacturing_date
			INTO #INBOUNDORDER
			FROM VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER  t1  
			INNER JOIN (SELECT DISTINCT  vas_order,prd_code,batch_no,inbound_doc  FROM #TempProductWODetails )t2 
			ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no  AND t1.inbound_doc = t2.inbound_doc --AND t1.to_no = t2.to_no
			where t1.workorder_no='' or t1.workorder_no is null
			GROUP BY country_code,t1.inbound_doc,t1.vas_order,vas_order_date,whs_no,plant,supplier_code,supplier_name,t1.prd_code,prd_desc,uom,
			t1.batch_no,expiry_date,stock_category,created_date,created_by,delete_flag,qi_type,workorder_no,manufacturing_date


			--SELECT * FROM #INBOUNDORDER




		--Insert All Products in TBL_TXN_WORK_ORDER
			INSERT INTO TBL_TXN_WORK_ORDER	(work_ord_ref,  job_ref_no, mll_no, client_code, prd_code, inbound_doc,	requirement_no, vas_order, batch_no, to_no, whs_no,
			 picking_area, upl_point, plant, 	ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, sloc, uom, expiry_date, stock_category,ttl_qty_eaches,
			  arrival_date,   creator_user_id, created_date, others, origional_ttl_qty_eaches,manufacturing_date,special_stock_indicator,special_stock)

			SELECT DISTINCT T.work_ord_ref,  @new_job_ref_no, T.mll_no, T.client_code, T.prd_code, T.inbound_doc,requirement_no, T.vas_order, T.batch_no, T.to_no, whs_no,
			 picking_area, upl_point, plant,ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, sloc, uom,expiry_date, stock_category, T.ttl_qty_eaches,
			 CONVERT(VARCHAR(10), I.to_date, 121) +' '+Convert(varchar(10),CONVERT(TIME(0), I.to_time)) arrival_date,   @user_id, @CurrentDateTime, T.others, qty,T.manufacturing_date,special_stock_indicator,special_stock
			FROM #TRANSFERORDER I WITH(NOLOCK) 
			INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order       AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no  
						AND I.inbound_doc = T.inbound_doc  AND I.to_no = T.to_no  AND  Convert(varchar(10),CONVERT(TIME(0), I.to_time)) = T.vas_order_time 
			WHERE I.workorder_no  IS NULL or I.workorder_no=''


			--SELECT DISTINCT T.work_ord_ref, 'IP', @new_job_ref_no, T.mll_no, T.client_code, T.prd_code, T.inbound_doc,requirement_no, T.vas_order, T.batch_no, T.to_no, whs_no,
			-- picking_area, upl_point, plant,ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, sloc, uom,expiry_date, stock_category, T.ttl_qty_eaches,
			-- T.arrival_date,   @user_id, GETDATE(), T.others, qty
			--FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I WITH(NOLOCK) 
			--INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.inbound_doc = T.inbound_doc  AND I.to_no = T.to_no 
			--WHERE I.workorder_no=null or I.workorder_no=''

			
			DECLARE @qi_type AS VARCHAR(200)
			SET @qi_type =(SELECT top 1 ISNULL(qi_type,'') FROM #INBOUNDORDER)
			
--Insert quantity details in TBL_TXN_WORK_ORDER_JOB_DET 
--select * from TBL_TXN_WORK_ORDER_JOB_DET
			SET @qty_to_use =(Select  top 1 qty_of_goods FROM #TempProductWODetails  )

			INSERT INTO TBL_TXN_WORK_ORDER_JOB_DET(work_ord_ref,work_ord_status,job_ref_no,urgent,commencement_date,completion_date,qty_of_goods,num_of_days_to_complete,current_event,qi_type)
			SELECT TOP 1 T.work_ord_ref, 'IP', @new_job_ref_no, T.urgent, T.commencement_date, T.completion_date, @qty_to_use, T.num_of_days_to_complete, '00',@qi_type
			FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I WITH(NOLOCK) 
			INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no 
			WHERE I.workorder_no  IS NULL or I.workorder_no=''
			
	--Insert JOB EVENT details in TBL_TXN_JOB_EVENT 


				DECLARE @running_no VARCHAR(50) = 1, @length INT = 8
			SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @length) as INT) + 1 AS VARCHAR(50))
										FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT) A ORDER BY CAST(RIGHT(running_no, @length) AS INT) DESC
			SET @running_no = 'TH' + REPLICATE('0', @length - LEN(@running_no)) + @running_no

			

			INSERT INTO TBL_TXN_JOB_EVENT(running_no, job_ref_no, event_id, start_date, issued_qty, created_date, creator_user_id)
			VALUES(@running_no, @new_job_ref_no, '00', @CurrentDateTime, @qty_to_use, @CurrentDateTime, @user_id)


			INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
			SELECT 'WORK_ORDER', @job_ref_no, 'Created', @user_id, @CurrentDateTime


		   --  SET @ttl_qty_eaches =(	select sum(ttl_qty_eaches) FROM #TempProductWODetails)





	

			DECLARE @CountTransferOrder INTEGER =0
			DECLARE @qtyTransfer INTEGER =0
			
			

			IF ( SELECT count(*) FROM #TRANSFERORDER WHERE countTransferRec>1)>0
			BEGIN
			PRINT '#TRANSFERORDER GREATER'

			   --SELECT ROW_NUMBER() OVER(ORDER BY name ASC) AS Row#,* INTO TEMPTransferOrderWithMultiple FROM #TRANSFERORDER where countTransferRec>=2 

--++++++++++++++++++++++++++++++++++++++++++++++START BACKUP++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
			   INSERT INTO [VAS_INTEGRATION_TH].dbo.VAS_TRANSFER_ORDER_DUPLICATE(country_code,inbound_doc,workorder_no,requirement_no,vas_order,to_no,whs_no,ssto_unit_no,dsto_unit_no,
			   picking_area,upl_point,plant,supplier_code,supplier_name,to_date,to_time,item_no,sloc,prd_code,prd_desc,uom,batch_no,qty,expiry_date,stock_category,created_date,
			   created_by,dsto_section,dsto_stg_bin,temp_logger,temp_logger_released_date,temp_logger_released_by,delete_flag,qi_type,manufacturing_date,special_stock_indicator,special_stock)

			   SELECT I.country_code,I.inbound_doc,@new_job_ref_no workorder_no,I.requirement_no,I.vas_order,I.to_no,I.whs_no,I.ssto_unit_no,I.dsto_unit_no,
			   I.picking_area,I.upl_point,I.plant,I.supplier_code,I.supplier_name,I.to_date,I.to_time,I.item_no,I.sloc,I.prd_code,I.prd_desc,I.uom,I.batch_no,I.qty,I.expiry_date,I.stock_category,
			   I.created_date,I.created_by,I.dsto_section,I.dsto_stg_bin,I.temp_logger,I.temp_logger_released_date,I.temp_logger_released_by,I.delete_flag,I.qi_type,I.manufacturing_date,I.special_stock_indicator,I.special_stock
			   FROM [VAS_INTEGRATION_TH].dbo.VAS_TRANSFER_ORDER  I
			   INNER JOIN #TRANSFERORDER  T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no  AND I.inbound_doc = T.inbound_doc  AND I.to_no = T.to_no 
			   WHERE T.countTransferRec>1
--++++++++++++++++++++++++++++++++++++++++++++++END BACKUP++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++START DELETE / INSERT++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			   				 

				DELETE I
				FROM [VAS_INTEGRATION_TH].dbo.VAS_TRANSFER_ORDER I
				INNER JOIN #TRANSFERORDER  T
				ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no  AND I.inbound_doc = T.inbound_doc  AND I.to_no = T.to_no
				WHERE  T.countTransferRec>1

				INSERT INTO [VAS_INTEGRATION_TH].dbo.VAS_TRANSFER_ORDER(country_code,inbound_doc,workorder_no,requirement_no,vas_order,to_no,whs_no,ssto_unit_no,dsto_unit_no,
				picking_area,upl_point,plant,supplier_code,supplier_name,to_date,to_time,sloc,prd_code,prd_desc,uom,batch_no, qty,expiry_date,
				stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,temp_logger_released_date,	temp_logger_released_by,delete_flag,qi_type,manufacturing_date,special_stock_indicator,special_stock)
			   SELECT country_code,t1.inbound_doc,workorder_no,requirement_no,t1.vas_order,t1.to_no,whs_no,ssto_unit_no,dsto_unit_no,
			   picking_area,upl_point,plant,supplier_code,supplier_name,to_date,to_time,sloc,t1.prd_code,t1.prd_desc,uom,t1.batch_no, qty,expiry_date,
			   stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,temp_logger_released_date,temp_logger_released_by,delete_flag,qi_type ,manufacturing_date,special_stock_indicator,special_stock
			   FROM #TRANSFERORDER t1 WHERE t1.countTransferRec>1

--++++++++++++++++++++++++++++++++++++++++++++++END DELETE / INSERT++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

			    UPDATE t1
				SET    t1.workorder_no =@new_job_ref_no,
				t1.qty=  CASE WHEN ISNULL(t1.qty,0)-ISNULL(t2.qty,0)>0 THEN ISNULL(t2.qty,0) ELSE ISNULL(t1.qty,0) END
						--t1.qty= CASE WHEN ISNULL(t1.qty,0)-ISNULL(t2.ttl_qty_eaches,0)>0 THEN ISNULL(t2.ttl_qty_eaches,0) ELSE ISNULL(t1.qty,0) END
				FROM   VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER  t1
				INNER JOIN #TRANSFERORDER t3 ON t1.vas_order = t3.vas_order AND t1.prd_code = t3.prd_code AND t1.batch_no = t3.batch_no AND t1.inbound_doc = t3.inbound_doc  AND t1.to_no = t3.to_no
				--INNER JOIN #TempProductWODetails t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no 
				INNER JOIN ( SELECT vas_order,prd_code,batch_no,inbound_doc,SUM(ISNULL(ttl_qty_eaches,0) )  qty FROM #TempProductWODetails 
				GROUP BY vas_order,prd_code,batch_no,inbound_doc ) t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no  AND t1.inbound_doc = t2.inbound_doc 
				WHERE (t1.workorder_no='' or t1.workorder_no is null) AND t3.countTransferRec > 1


				--		SELECT I.country_code,I.inbound_doc,'' workorder_no,I.requirement_no,I.vas_order,I.to_no,I.whs_no,I.ssto_unit_no,I.dsto_unit_no,I.picking_area,I.upl_point,I.plant,I.supplier_code,I.supplier_name,
				--I.to_date,I.to_time,I.item_no,I.sloc,I.prd_code,I.prd_desc,I.uom,I.batch_no,ISNULL(T.qty,0)-ISNULL(I.qty,0) qty,I.expiry_date,I.stock_category,I.created_date,I.created_by,I.dsto_section,I.dsto_stg_bin,I.temp_logger,
				--I.temp_logger_released_date,I.temp_logger_released_by,I.delete_flag,I.qi_type ,I.manufacturing_date,I.special_stock_indicator,I.special_stock
				--from  VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I
				--INNER JOIN #TRANSFERORDER T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
				--where ISNULL(T.qty,0)>ISNULL(I.qty,0) and I.workorder_no=@new_job_ref_no   AND T.countTransferRec > 1

								

				Insert into VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER				
				SELECT country_code,I.inbound_doc,'' workorder_no,requirement_no,I.vas_order,I.to_no,whs_no,ssto_unit_no,dsto_unit_no,picking_area,upl_point,plant,supplier_code,supplier_name,
				to_date,to_time,I.item_no,sloc,I.prd_code,prd_desc,uom,I.batch_no,ISNULL(T.origional_ttl_qty_eaches,0)-ISNULL(T.ttl_qty_eaches,0) qty,expiry_date,stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,
				temp_logger_released_date,temp_logger_released_by,delete_flag,I.qi_type ,I.manufacturing_date,special_stock_indicator,special_stock, temp_logger_remark
				from  VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I
				INNER JOIN (SELECT vas_order,prd_code,batch_no,inbound_doc,to_no,countTransferRec FROM #TRANSFERORDER)  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
				where ISNULL(T.ttl_qty_eaches,0)<ISNULL(T.origional_ttl_qty_eaches,0) and I.workorder_no=@new_job_ref_no   AND t3.countTransferRec > 1



				--SELECT country_code,I.inbound_doc,'' workorder_no,requirement_no,I.vas_order,I.to_no,whs_no,ssto_unit_no,dsto_unit_no,picking_area,upl_point,plant,supplier_code,supplier_name,
				--to_date,to_time,I.item_no,sloc,I.prd_code,prd_desc,uom,I.batch_no,ISNULL(T.origional_ttl_qty_eaches,0)-ISNULL(T.ttl_qty_eaches,0) qty,expiry_date,stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,
				--temp_logger_released_date,temp_logger_released_by,delete_flag,I.qi_type ,I.manufacturing_date,special_stock_indicator,special_stock
				--from  VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I
				--INNER JOIN (SELECT vas_order,prd_code,batch_no,inbound_doc,to_no,countTransferRec FROM #TRANSFERORDER)  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				--INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
				--where ISNULL(T.ttl_qty_eaches,0)<ISNULL(T.origional_ttl_qty_eaches,0) and I.workorder_no=@new_job_ref_no   AND t3.countTransferRec > 1


				
				--		SELECT I.country_code,I.inbound_doc,'' workorder_no,I.requirement_no,I.vas_order,I.to_no,I.whs_no,I.ssto_unit_no,I.dsto_unit_no,I.picking_area,I.upl_point,I.plant,I.supplier_code,I.supplier_name,
				--I.to_date,I.to_time,I.item_no,I.sloc,I.prd_code,I.prd_desc,I.uom,I.batch_no,ISNULL(T.qty,0)-ISNULL(I.qty,0) qty,I.expiry_date,I.stock_category,I.created_date,I.created_by,I.dsto_section,I.dsto_stg_bin,I.temp_logger,
				--I.temp_logger_released_date,I.temp_logger_released_by,I.delete_flag,I.qi_type ,I.manufacturing_date,I.special_stock_indicator,I.special_stock
				--from  VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I
				--INNER JOIN #TRANSFERORDER T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
				--where ISNULL(T.qty,0)>ISNULL(I.qty,0) and I.workorder_no=@new_job_ref_no   AND T.countTransferRec > 1




			END


			IF ( SELECT count(*) FROM #INBOUNDORDER WHERE countTransferRec>1)>0
			BEGIN

--++++++++++++++++++++++++++++++++++++++++++++++START BACKUP++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			   INSERT INTO [VAS_INTEGRATION_TH].dbo.VAS_INBOUND_ORDER_DUPLICATE(country_code,inbound_doc,vas_order,vas_order_date,whs_no,plant,supplier_code,supplier_name,item_no,prd_code,prd_desc,
			   uom,batch_no,qty,expiry_date,stock_category,created_date,created_by,delete_flag,qi_type,workorder_no,manufacturing_date)
			   SELECT I.country_code,I.inbound_doc,I.vas_order,I.vas_order_date,I.whs_no,I.plant,I.supplier_code,I.supplier_name,I.item_no,I.prd_code,I.prd_desc,I.uom,
			   I.batch_no,I.qty,I.expiry_date,I.stock_category,I.created_date,I.created_by,I.delete_flag,I.qi_type,@new_job_ref_no workorder_no ,I.manufacturing_date
			   FROM [VAS_INTEGRATION_TH].dbo.VAS_INBOUND_ORDER I
			   INNER JOIN #INBOUNDORDER  T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no  AND I.inbound_doc = T.inbound_doc -- AND I.to_no = T.to_no 
			   WHERE T.countTransferRec>1

--++++++++++++++++++++++++++++++++++++++++++++++END BACKUP++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++START DELETE / INSERT++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

				DELETE I
				FROM [VAS_INTEGRATION_TH].dbo.VAS_INBOUND_ORDER I
				INNER JOIN #INBOUNDORDER  T
				 ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no  AND I.inbound_doc = T.inbound_doc
				WHERE  T.countTransferRec>1

				
				INSERT INTO [VAS_INTEGRATION_TH].dbo.VAS_INBOUND_ORDER(country_code,inbound_doc,vas_order,vas_order_date,whs_no,plant,supplier_code,supplier_name,item_no,prd_code,prd_desc,
			   uom,batch_no,qty,expiry_date,stock_category,created_date,created_by,delete_flag,qi_type,workorder_no,manufacturing_date)
			   SELECT country_code,inbound_doc,vas_order,vas_order_date,whs_no,plant,supplier_code,supplier_name,''item_no,prd_code,prd_desc,
			   uom,batch_no,qty,expiry_date,stock_category,created_date,created_by,delete_flag,qi_type,workorder_no,manufacturing_date FROM #INBOUNDORDER T WHERE T.countTransferRec>1
--++++++++++++++++++++++++++++++++++++++++++++++END DELETE / INSERT++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


				UPDATE t1
				SET    t1.workorder_no =@new_job_ref_no,
				t1.qty=  CASE WHEN ISNULL(t1.qty,0)-ISNULL(t2.qty,0)>0 THEN ISNULL(t2.qty,0) ELSE ISNULL(t1.qty,0) END
				FROM   VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER  t1 
				INNER JOIN #INBOUNDORDER t3 ON t1.vas_order = t3.vas_order AND t1.prd_code = t3.prd_code AND t1.batch_no = t3.batch_no
				--INNER JOIN #TempProductWODetails t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no 
				INNER JOIN ( SELECT vas_order,prd_code,batch_no,inbound_doc,SUM(ISNULL(ttl_qty_eaches,0) )  qty FROM #TempProductWODetails 
				GROUP BY vas_order,prd_code,batch_no,inbound_doc ) t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no  AND t1.inbound_doc = t2.inbound_doc 
				WHERE (t1.workorder_no='' or t1.workorder_no is null)  AND t3.countTransferRec > 1


				--UPDATE t1
				--SET    t1.workorder_no =@new_job_ref_no,
				--t1.qty= CASE WHEN ISNULL(t1.qty,0)-SUM(ISNULL(t2.qty,0))>0 THEN SUM(ISNULL(t2.qty,0)) ELSE ISNULL(t1.qty,0) END
				--FROM   VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER  t1 
				--INNER JOIN #INBOUNDORDER t3 ON t1.vas_order = t3.vas_order AND t1.prd_code = t3.prd_code AND t1.batch_no = t3.batch_no
				----INNER JOIN #TempProductWODetails t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no 
				--INNER JOIN ( SELECT vas_order,prd_code,batch_no,inbound_doc,SUM(ISNULL(ttl_qty_eaches,0) )  qty FROM #TempProductWODetails 
				--GROUP BY vas_order,prd_code,batch_no,inbound_doc ) t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no 
				--WHERE t1.workorder_no='' or t1.workorder_no is null  AND t3.countTransferRec > 1






				Insert into VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER
				SELECT  I.country_code,I.inbound_doc,I.vas_order,I.vas_order_date,I.whs_no,I.plant,I.supplier_code,I.supplier_name,I.item_no,I.prd_code,I.prd_desc,I.uom,
				I.batch_no,ISNULL(t3.qty,0)-ISNULL(I.qty,0)qty,I.expiry_date,	I.stock_category,I.created_date,I.created_by,I.delete_flag,I.qi_type,''workorder_no,I.manufacturing_date
 				from  VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER I
				INNER JOIN #INBOUNDORDER  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				where ISNULL(t3.qty,0)>ISNULL(I.qty,0) and I.workorder_no=@new_job_ref_no   AND t3.countTransferRec > 1



				--SELECT country_code,I.inbound_doc,I.vas_order,I.vas_order_date,whs_no,plant,supplier_code,supplier_name,I.item_no,I.prd_code,prd_desc,uom,
				--I.batch_no,ISNULL(T.origional_ttl_qty_eaches,0)-ISNULL(T.ttl_qty_eaches,0)qty,expiry_date,	stock_category,created_date,created_by,delete_flag,qi_type,''workorder_no,manufacturing_date
 				--	from  VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER I
				--INNER JOIN (SELECT vas_order,prd_code,batch_no,inbound_doc,countTransferRec FROM #INBOUNDORDER)  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				--INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
				--where ISNULL(T.ttl_qty_eaches,0)<ISNULL(T.origional_ttl_qty_eaches,0) and I.workorder_no=@new_job_ref_no   AND t3.countTransferRec > 1

			END

			--SELECT * FROM #TempProductWODetails
			--SELECT * FROM #TRANSFERORDER
			--SELECT * FROM #INBOUNDORDER

			IF ( SELECT count(*) FROM #TRANSFERORDER WHERE countTransferRec=1)>0
			BEGIN
			PRINT '#TRANSFERORDER lower'

			



				UPDATE t1
				SET		t1.workorder_no =@new_job_ref_no,
						t1.qty= CASE WHEN ISNULL(t2.origional_ttl_qty_eaches,0)-ISNULL(t2.ttl_qty_eaches,0)>0 THEN ISNULL(t2.ttl_qty_eaches,0) ELSE ISNULL(t2.origional_ttl_qty_eaches,0) END
				FROM   VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER  t1
				INNER JOIN #TRANSFERORDER t3 ON t1.vas_order = t3.vas_order AND t1.prd_code = t3.prd_code AND t1.batch_no = t3.batch_no AND t1.inbound_doc = t3.inbound_doc  AND t1.to_no = t3.to_no
				INNER JOIN #TempProductWODetails t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no   
				AND t1.inbound_doc = t3.inbound_doc  AND t1.to_no = t3.to_no AND    Convert(varchar(10),CONVERT(TIME(0), t1.to_time)) = t2.vas_order_time 
				WHERE (t1.workorder_no='' or t1.workorder_no is null) AND t3.countTransferRec = 1


				

				Insert into VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER
				SELECT country_code,I.inbound_doc,'' workorder_no,requirement_no,I.vas_order,I.to_no,whs_no,ssto_unit_no,dsto_unit_no,picking_area,upl_point,plant,supplier_code,supplier_name,
				to_date,to_time,I.item_no,sloc,I.prd_code,prd_desc,uom,I.batch_no,ISNULL(T.origional_ttl_qty_eaches,0)-ISNULL(T.ttl_qty_eaches,0) qty,expiry_date,stock_category,created_date,created_by,dsto_section,dsto_stg_bin,temp_logger,
				temp_logger_released_date,temp_logger_released_by,delete_flag,I.qi_type ,I.manufacturing_date,I.special_stock_indicator,I.special_stock, temp_logger_remark
				from  VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER I
				INNER JOIN (SELECT vas_order,prd_code,batch_no,inbound_doc,to_no,countTransferRec FROM #TRANSFERORDER)  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				AND I.inbound_doc =t3.inbound_doc  AND I.to_no = t3.to_no --AND    Convert(varchar(10),CONVERT(TIME(0), I.to_time)) = T.vas_order_time 
				INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
					AND I.inbound_doc = T.inbound_doc  AND I.to_no = T.to_no AND    Convert(varchar(10),CONVERT(TIME(0), I.to_time)) = T.vas_order_time 
				where ISNULL(T.ttl_qty_eaches,0)<ISNULL(T.origional_ttl_qty_eaches,0) and I.workorder_no=@new_job_ref_no   AND t3.countTransferRec = 1




			END
					
		


			IF ( SELECT count(*) FROM #INBOUNDORDER WHERE countTransferRec=1)>0
			BEGIN	

				--UPDATE t1
				--SET    t1.workorder_no =@new_job_ref_no,
				--t1.qty= CASE WHEN ISNULL(t1.qty,0)-ISNULL(t2.ttl_qty_eaches,0)>0 THEN ISNULL(t2.ttl_qty_eaches,0) ELSE ISNULL(t1.qty,0) END
				--FROM   VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER  t1 
				--INNER JOIN #INBOUNDORDER t3 ON t1.vas_order = t3.vas_order AND t1.prd_code = t3.prd_code AND t1.batch_no = t3.batch_no   AND t1.inbound_doc = t3.inbound_doc 
				--INNER JOIN #TempProductWODetails t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no  AND t1.inbound_doc = t2.inbound_doc 
				--WHERE t1.workorder_no='' or t1.workorder_no is null  AND t3.countTransferRec=1

				UPDATE t1
				SET    t1.workorder_no =@new_job_ref_no,
				t1.qty=  CASE WHEN ISNULL(t1.qty,0)-ISNULL(t2.qty,0)>0 THEN ISNULL(t2.qty,0) ELSE ISNULL(t1.qty,0) END
				FROM   VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER  t1 
				INNER JOIN #INBOUNDORDER t3 ON t1.vas_order = t3.vas_order AND t1.prd_code = t3.prd_code AND t1.batch_no = t3.batch_no  AND t1.inbound_doc = t3.inbound_doc 
				--INNER JOIN #TempProductWODetails t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no 
				INNER JOIN ( SELECT vas_order,prd_code,batch_no,inbound_doc,SUM(ISNULL(ttl_qty_eaches,0) )  qty FROM #TempProductWODetails 
				GROUP BY vas_order,prd_code,batch_no,inbound_doc ) t2 ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no  AND t1.inbound_doc = t2.inbound_doc 
				WHERE (t1.workorder_no='' or t1.workorder_no is null)  AND t3.countTransferRec=1


				Insert into VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER
				SELECT  I.country_code,I.inbound_doc,I.vas_order,I.vas_order_date,I.whs_no,I.plant,I.supplier_code,I.supplier_name,I.item_no,I.prd_code,I.prd_desc,I.uom,
				I.batch_no,ISNULL(t3.qty,0)-ISNULL(I.qty,0)qty,I.expiry_date,	I.stock_category,I.created_date,I.created_by,I.delete_flag,I.qi_type,''workorder_no,I.manufacturing_date
 				from  VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER I
				INNER JOIN #INBOUNDORDER  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				where ISNULL(t3.qty,0)>ISNULL(I.qty,0) and I.workorder_no=@new_job_ref_no   AND t3.countTransferRec = 1

				--Insert into VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER
				--SELECT country_code,I.inbound_doc,I.vas_order,I.vas_order_date,whs_no,plant,supplier_code,supplier_name,I.item_no,I.prd_code,prd_desc,uom,
				--I.batch_no,ISNULL(T.origional_ttl_qty_eaches,0)-ISNULL(T.ttl_qty_eaches,0)qty,expiry_date,	stock_category,created_date,created_by,delete_flag,qi_type,''workorder_no,manufacturing_date
 			--	from  VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER I
				--INNER JOIN (SELECT vas_order,prd_code,batch_no,inbound_doc FROM #INBOUNDORDER)  t3 ON I.vas_order = t3.vas_order AND I.prd_code = t3.prd_code AND I.batch_no = t3.batch_no
				--INNER JOIN #TempProductWODetails T ON I.vas_order = T.vas_order AND I.prd_code = T.prd_code AND I.batch_no = T.batch_no AND I.batch_no = T.batch_no 
				--where ISNULL(T.ttl_qty_eaches,0)<ISNULL(T.origional_ttl_qty_eaches,0) and I.workorder_no=@new_job_ref_no
			END

			SELECT @new_job_ref_no as job_ref_no
		END
		ELSE
		SELECT '' as job_ref_no



	END
	ELSE IF (@mode = 'Edit')
	BEGIN

	--SET @job_ref_no =(select top 1 job_ref_no from #TempProductWODetails)


		--UPDATE TBL_TXN_WORK_ORDER
		--SET others = @others,
		--	urgent = @urgent,
		--	commencement_date = @commencement_date,
		--	completion_date = @completion_date,
		--	qty_of_goods = @qty_of_goods,
		--	num_of_days_to_complete = @num_of_days_to_complete,
		--	changed_date = GETDATE(),
		--	changed_user_id = @user_id
		--WHERE job_ref_no = @job_ref_no

		
		UPDATE 
			t1
		SET 
			t1.others = t2.others
		FROM 
		TBL_TXN_WORK_ORDER  t1 
		INNER JOIN #TempProductWODetails t2 
		ON t1.vas_order = t2.vas_order AND t1.prd_code = t2.prd_code AND t1.batch_no = t2.batch_no 
		where t1.job_ref_no = @job_ref_no


		UPDATE 
			t1
		SET 
			t1.urgent = t2.urgent,
			t1.commencement_date = t2.commencement_date,
			t1.completion_date = t2.completion_date,
			t1.qty_of_goods = t2.qty_of_goods,
			t1.num_of_days_to_complete = t2.num_of_days_to_complete,
			t1.changed_date = @CurrentDateTime,
			t1.changed_user_id = @user_id
		FROM 
		TBL_TXN_WORK_ORDER_JOB_DET  t1 
		INNER JOIN #TempProductWODetails t2 
		ON t1.job_ref_no = @job_ref_no
		--where t1.job_ref_no = @job_ref_no

		
			   		 
        --VAS_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER

		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		SELECT 'WORK_ORDER', @job_ref_no, 'Updated', @user_id, @CurrentDateTime

		SELECT top 1 job_ref_no FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no
	END

	DROP TABLE #TempProductWODetails
	drop table #TRANSFERORDER
	drop table #INBOUNDORDER
END

GO
