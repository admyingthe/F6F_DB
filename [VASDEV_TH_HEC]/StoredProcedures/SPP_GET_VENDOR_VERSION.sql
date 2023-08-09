SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================      
-- Author:  LE TIEN DUNG
-- Create date: 2022-12-13
-- Description: Get Vendor Version for dropdownlist
-- Example Query: exec SPP_GET_VENDOR_VERSION @param=N'{"job_ref_no":"G2022/08/0004"}'
-- OUTPUT:
--- 1: dt: Table of all Vendor version a long with its status
-- ======================================================================== 

CREATE PROC [dbo].[SPP_GET_VENDOR_VERSION]
@param NVARCHAR(MAX)
AS
BEGIN
	DECLARE @job_ref_no NVARCHAR(20) = (SELECT JSON_VALUE(@param, '$.job_ref_no'))

	--SELECT DISTINCT vendor_name, CAST(0 AS BIT) AS is_active
	--INTO #FINAL_TABLE
	--FROM TBL_ADM_VENDOR_VERSION

	--UPDATE #FINAL_TABLE
	--SET is_active = 1
	--WHERE vendor_name = (SELECT TOP 1 vendor_name FROM TBL_ADM_MANAGE_ACTIVE_VENDOR_VERSION
	--WHERE job_ref_no = @job_ref_no)

	--SELECT * FROM #FINAL_TABLE

	--DROP TABLE #FINAL_TABLE

	SELECT TOP 1 job_ref_no, vendor_id, prd_code 
	FROM TBL_ADM_MANAGE_ACTIVE_VENDOR_VERSION A
	WHERE job_ref_no = @job_ref_no
END
GO
