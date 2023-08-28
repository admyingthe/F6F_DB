SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 26-04-2023
-- Description:	SIA / INV UPLOAD TEMPLATE
-- =============================================
CREATE PROCEDURE [dbo].[SPP_SIA_INV_UPLOAD_TEMPLATE] 
AS
BEGIN
	SET NOCOUNT ON;

    CREATE TABLE #DISPLAY_TEMP(
		[Type] VARCHAR(300),
		[VAS Order] VARCHAR(200),		
		[Ref Doc No] VARCHAR(200),
		[Arrival Date] VARCHAR(200),
		[Arrival Time] VARCHAR(200),
		[TO No] VARCHAR(200),
		[Product Code] VARCHAR(50),
		[Batch No.] VARCHAR(100),
		Quantity VARCHAR(200), 
	    Plant VARCHAR(100),
		[Client Code] VARCHAR(100),
		UOM NVARCHAR(300),
		[EXPIRY DATE] VARCHAR(200),
	)

	CREATE TABLE #COLUMN_NAME_TEMP(
		[type] VARCHAR(300),
		vas_order VARCHAR(200),		
		ref_doc_no VARCHAR(200),
		arrival_date VARCHAR(200),
		arrival_time VARCHAR(200),
		to_no VARCHAR(200),
		prd_code VARCHAR(50),
		batch_no VARCHAR(100),
		quantity VARCHAR(200), 
	    plant VARCHAR(100),
		[client_code] VARCHAR(100),
		uom NVARCHAR(300),
		[expiry_date] VARCHAR(200),
		creator_user_id VARCHAR(200),
		created_date VARCHAR(200),
		changed_user_id VARCHAR(200),
		changed_date VARCHAR(200),
	)

	SELECT [Type],		
		[Ref Doc No],
		[Arrival Date],
		[Arrival Time],
		[Product Code],
		[Batch No.],
		Quantity, 
	    Plant,
		[Client Code],
		UOM,
		[EXPIRY DATE] FROM #DISPLAY_TEMP

	SELECT A.COLUMN_NAME, ISNULL(B.COLUMN_NAME, '') AS 'DISPLAY_NAME', 'TEXT' AS DATA_TYPE, '' AS OPTIONS, 1 AS MANDATORY, ROW_NUMBER() OVER(ORDER BY A.ORDINAL_POSITION) AS SEQ
	INTO #COLUMN_DETAIL
	FROM tempdb.INFORMATION_SCHEMA.COLUMNS A WITH (NOLOCK)
	LEFT JOIN (SELECT COLUMN_NAME, ORDINAL_POSITION FROM tempdb.INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK) WHERE TABLE_NAME LIKE '%#DISPLAY_TEMP%') B ON A.ORDINAL_POSITION = B.ORDINAL_POSITION
	WHERE A.TABLE_NAME LIKE '%#COLUMN_NAME_TEMP%'

	ALTER TABLE #COLUMN_DETAIL ALTER COLUMN DATA_TYPE VARCHAR(3000)
	ALTER TABLE #COLUMN_DETAIL ALTER COLUMN OPTIONS VARCHAR(3000)

	UPDATE #COLUMN_DETAIL
	SET DATA_TYPE = 'DROPDOWN', OPTIONS = 'SIA,Invoice'
	WHERE COLUMN_NAME = 'Type'

	SELECT * FROM #COLUMN_DETAIL

END

GO
