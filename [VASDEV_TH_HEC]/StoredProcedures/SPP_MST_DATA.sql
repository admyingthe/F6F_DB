SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =================================================================
-- Author:		Siow Shen Yee
-- Created date: 2018-07-13
-- Description:	(Run by Job daily) Retrieve master data from staging 
-- Example Query:
-- =================================================================

CREATE PROCEDURE [dbo].[SPP_MST_DATA]
AS
BEGIN
	SET NOCOUNT ON;

	/**** TBL_MST_CLIENT *****/
	CREATE TABLE #CLIENT(client_code VARCHAR(50))

	INSERT INTO #CLIENT (client_code)
	SELECT DISTINCT RTRIM(LTRIM(supplier_code)) FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER WITH(NOLOCK)
	UNION ALL
	SELECT DISTINCT RTRIM(LTRIM(supplier_code)) FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)
	WHERE NOT EXISTS (SELECT supplier_code FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER B WITH(NOLOCK) WHERE A.supplier_code = B.supplier_code)

	--INSERT INTO TBL_MST_CLIENT(client_code, client_name, created_date)
	--SELECT RTRIM(LTRIM(A.client_code)), B.MatGrpDesc COLLATE SQL_Latin1_General_CP1_CI_AS, GETDATE()
	--FROM #CLIENT A
	--INNER JOIN SERVER1.TH_DW.dbo.M_MatGrp B WITH(NOLOCK) ON A.client_code = B.MatGrp COLLATE SQL_Latin1_General_CP1_CI_AS
	--WHERE EXISTS (SELECT MatGrp COLLATE SQL_Latin1_General_CP1_CI_AS FROM SERVER1.TH_DW.dbo.M_MatGrp C WITH(NOLOCK) WHERE  A.client_code = C.MatGrp COLLATE SQL_Latin1_General_CP1_CI_AS)
	--AND NOT EXISTS (SELECT client_code FROM TBL_MST_CLIENT D WITH(NOLOCK) WHERE A.client_code = D.client_code)

	DROP TABLE #CLIENT

	UPDATE A
	SET client_name = B.MatGrpDesc COLLATE SQL_Latin1_General_CP1_CI_AS
	FROM TBL_MST_CLIENT A 
	INNER JOIN SERVER1.TH_DW.dbo.M_MatGrp B WITH(NOLOCK) ON A.client_code = B.MatGrp COLLATE SQL_Latin1_General_CP1_CI_AS
	/**** TBL_MST_CLIENT *****/
	
	/**** TBL_MST_PRODUCT *****/
	UPDATE A
	SET prd_desc =  RTRIM(LTRIM(PrdName))COLLATE SQL_Latin1_General_CP1_CI_AS,
		old_mat_code = RTRIM(LTRIM(OldMaterialCode)) COLLATE SQL_Latin1_General_CP1_CI_AS,
		base_uom = RTRIM(LTRIM(BaseUOM))COLLATE SQL_Latin1_General_CP1_CI_AS,
		prd_type = RTRIM(LTRIM(PrdType))COLLATE SQL_Latin1_General_CP1_CI_AS,
		A.prdgrp4 = RTRIM(LTRIM(B.PrdGrp4))COLLATE SQL_Latin1_General_CP1_CI_AS,
		--tax_code = RTRIM(LTRIM(Taxcode)),
		--tax_rate = RTRIM(LTRIM(Taxrate)),
		status = RTRIM(LTRIM(B.status))COLLATE SQL_Latin1_General_CP1_CI_AS,
		temp = RTRIM(LTRIM(TempCond))COLLATE SQL_Latin1_General_CP1_CI_AS,
		updated_date = GETDATE()
	FROM TBL_MST_PRODUCT A
	INNER JOIN SERVER1.TH_DW.dbo.M_Product B ON A.prd_code = B.prdcode COLLATE SQL_Latin1_General_CP1_CI_AS
	--WHERE A.prd_desc <> B.PrdName

	INSERT INTO TBL_MST_PRODUCT (prd_code, prd_desc, princode, old_mat_code, base_uom, prd_type, prdgrp4, status, temp,updated_date)--tax_code, tax_rate,
	SELECT DISTINCT RTRIM(LTRIM(PrdCode)) COLLATE SQL_Latin1_General_CP1_CI_AS , RTRIM(PrdName) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(PrinCode)) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(OldMaterialCode)) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(BaseUOM)) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(PrdType)) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(PrdGrp4)) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(status)) COLLATE SQL_Latin1_General_CP1_CI_AS, RTRIM(LTRIM(TempCond)),GETDATE()--RTRIM(LTRIM(Taxcode)), RTRIM(LTRIM(Taxrate)),
	
	FROM SERVER1.TH_DW.dbo.M_Product A WITH(NOLOCK)
	WHERE --status <> 'X' AND 
	PrinCode <> ''  --AND PrdType NOT LIKE 'ZPK%'
	AND NOT EXISTS (SELECT prd_code FROM TBL_MST_PRODUCT B WITH(NOLOCK) WHERE A.PrdCode COLLATE SQL_Latin1_General_CP1_CI_AS = B.prd_code)
	/**** TBL_MST_PRODUCT *****/

	/**** TBL_MST_MATGRP *****/
	UPDATE A
	SET prdgrp4 = B.prdgrp4 COLLATE SQL_Latin1_General_CP1_CI_AS,
		prdgrpdesc4 = B.prdgrpdesc4 COLLATE SQL_Latin1_General_CP1_CI_AS
	FROM TBL_MST_MATGRP A
	INNER JOIN SERVER1.TH_DW.dbo.M_MatGrp4 B ON A.prdgrp4 = B.prdgrp4 COLLATE SQL_Latin1_General_CP1_CI_AS
	
	insert into TBL_MST_MATGRP (prdgrp4, prdgrpdesc4)
	select distinct A.prdgrp4, A.prdgrpdesc4 COLLATE SQL_Latin1_General_CP1_CI_AS 
	FROM SERVER1.TH_DW.dbo.M_MatGrp4 A WITH(NOLOCK)
	where NOT EXISTS (SELECT prdgrp4 FROM TBL_MST_MATGRP B WITH(NOLOCK) WHERE A.prdgrp4 = B.prdgrp4 COLLATE SQL_Latin1_General_CP1_CI_AS)


	/**** TBL_MST_MATGRP *****/

	/**** UPDATE MAL/ MDA REG NO. *****/ --Need to check
	--UPDATE A
	--SET A.REG_NO = LTRIM(RTRIM(REPLACE([CharacteristicValue], char(9), '')))	--replace TAB character
	--FROM TBL_MST_PRODUCT A WITH(NOLOCK) INNER JOIN SERVER111.MYDW.[dbo].[M_MaterialClass] B WITH(NOLOCK) ON A.prd_code = B.prdcode
	--WHERE LTRIM(RTRIM(B.INTERNALCHARACTERISTIC)) IN ('MDA No','Product Registration Number')
	/**** UPDATE MAL/ MDA REG NO. *****/






	/**** UPDATE STORAGE CONDITION *****/
	--INSERT INTO TBL_MST_DDL
	--(ddl_code, code, name, delete_flag)
	--SELECT DISTINCT 'ddlStorageCond', tempCode, tempDesc, 0
	--FROM SERVER111.MYDW.dbo.M_Product A
	--WHERE NOT EXISTS(SELECT code FROM TBL_MST_DDL B WITH(NOLOCK) WHERE A.tempCode = B.code)
	--AND tempCode <> ''
	/**** UPDATE STORAGE CONDITION *****/

	/**** UPDATE ON HOLD TIME FOR CLOSED MPO ****/

	UPDATE A
	SET before_deduct_on_hold =  dbo.GetTotalWorkingMins(to_time, work_ord_status, A.changed_date)
	FROM TBL_TXN_WORK_ORDER_JOB_DET A WITH(NOLOCK)
	INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) ON A.job_ref_no = E.workorder_no
	WHERE work_ord_status IN ('C','CCL') AND ISNULL(before_deduct_on_hold, '') = ''

	--UPDATE A
	--SET before_deduct_on_hold = dbo.GetTotalWorkingMins(to_time, work_ord_status, A.changed_date)
	--FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
	--INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) ON A.vas_order = E.vas_order AND A.prd_code = E.prd_code AND A.batch_no = E.batch_no 
	--WHERE work_ord_status IN ('C','CCL') AND ISNULL(before_deduct_on_hold, '') = ''
	/**** UPDATE ON HOLD TIME FOR CLOSED MPO ****/

END



GO
