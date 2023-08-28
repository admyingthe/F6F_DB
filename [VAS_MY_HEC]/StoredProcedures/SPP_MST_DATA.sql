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
	SELECT DISTINCT RTRIM(LTRIM(supplier_code)) FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER WITH(NOLOCK)
	UNION ALL
	SELECT DISTINCT RTRIM(LTRIM(supplier_code)) FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)
	WHERE NOT EXISTS (SELECT supplier_code FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER B WITH(NOLOCK) WHERE A.supplier_code = B.supplier_code)

	INSERT INTO TBL_MST_CLIENT(client_code, client_name, created_date)
	SELECT RTRIM(LTRIM(A.client_code)), B.PrdHierDesc, GETDATE()
	FROM #CLIENT A
	INNER JOIN SERVER111.MYDW.dbo.M_PrdHierarchy B WITH(NOLOCK) ON A.client_code = B.PrdHier
	WHERE EXISTS (SELECT PrdHier FROM SERVER111.MYDW.dbo.M_PrdHierarchy C WITH(NOLOCK) WHERE PrdLvl = 1 AND A.client_code = C.PrdHier)
	AND NOT EXISTS (SELECT client_code FROM TBL_MST_CLIENT D WITH(NOLOCK) WHERE A.client_code = D.client_code)

	DROP TABLE #CLIENT

	UPDATE A
	SET client_name = B.PrdHierDesc
	FROM TBL_MST_CLIENT A 
	INNER JOIN SERVER111.MYDW.dbo.M_PrdHierarchy B WITH(NOLOCK) ON A.client_code = B.PrdHier
	/**** TBL_MST_CLIENT *****/

	/**** TBL_MST_PRODUCT *****/
	UPDATE A
	SET prd_desc =  RTRIM(LTRIM(PrdName)),
		old_mat_code = RTRIM(LTRIM(OldMaterialCode)),
		base_uom = RTRIM(LTRIM(BaseUOM)),
		prd_type = RTRIM(LTRIM(PrdType)),
		tax_code = RTRIM(LTRIM(Taxcode)),
		tax_rate = RTRIM(LTRIM(Taxrate)),
		status = RTRIM(LTRIM(B.status)),
		temp = RTRIM(LTRIM(TempCode)),
		updated_date = getdate()
	FROM TBL_MST_PRODUCT A
	INNER JOIN SERVER111.MYDW.dbo.M_Product B ON A.prd_code = B.prdcode
	--WHERE A.prd_desc <> B.PrdName

	INSERT INTO TBL_MST_PRODUCT (prd_code, prd_desc, princode, old_mat_code, base_uom, prd_type, tax_code, tax_rate, status, temp, updated_date)
	SELECT DISTINCT RTRIM(LTRIM(PrdCode)), RTRIM(PrdName), RTRIM(LTRIM(PrinCode)), RTRIM(LTRIM(OldMaterialCode)), RTRIM(LTRIM(BaseUOM)), RTRIM(LTRIM(PrdType)), RTRIM(LTRIM(Taxcode)), RTRIM(LTRIM(Taxrate)), RTRIM(LTRIM(status)), RTRIM(LTRIM(TempCode)), getdate()
	FROM SERVER111.MYDW.dbo.M_Product A WITH(NOLOCK)
	WHERE --status <> 'X' AND 
	PrinCode <> '' 
	AND NOT EXISTS (SELECT prd_code FROM TBL_MST_PRODUCT B WITH(NOLOCK) WHERE A.PrdCode = B.prd_code)
	/**** TBL_MST_PRODUCT *****/

	/**** UPDATE MAL/ MDA REG NO. *****/
	UPDATE A
	SET A.REG_NO = LTRIM(RTRIM(REPLACE([CharacteristicValue], char(9), '')))	--replace TAB character
	FROM TBL_MST_PRODUCT A WITH(NOLOCK) INNER JOIN SERVER111.MYDW.[dbo].[M_MaterialClass] B WITH(NOLOCK) ON A.prd_code = B.prdcode
	WHERE LTRIM(RTRIM(B.INTERNALCHARACTERISTIC)) IN ('MDA No','Product Registration Number')
	/**** UPDATE MAL/ MDA REG NO. *****/

	/**** UPDATE STORAGE CONDITION *****/
	INSERT INTO TBL_MST_DDL
	(ddl_code, code, name, delete_flag)
	SELECT DISTINCT 'ddlStorageCond', tempCode, tempDesc, 0
	FROM SERVER111.MYDW.dbo.M_Product A
	WHERE NOT EXISTS(SELECT code FROM TBL_MST_DDL B WITH(NOLOCK) WHERE A.tempCode = B.code)
	AND tempCode <> ''
	/**** UPDATE STORAGE CONDITION *****/

	/**** UPDATE ON HOLD TIME FOR CLOSED MPO ****/
	UPDATE A
	SET before_deduct_on_hold = dbo.GetTotalWorkingMins(to_time, work_ord_status, A.changed_date)
	FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
	INNER JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) ON A.vas_order = E.vas_order AND A.prd_code = E.prd_code AND A.batch_no = E.batch_no
	WHERE work_ord_status IN ('C','CCL') AND ISNULL(before_deduct_on_hold, '') = ''
	/**** UPDATE ON HOLD TIME FOR CLOSED MPO ****/

END
GO
