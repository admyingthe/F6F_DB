SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 28-04-2023
-- Description:	SIA / INV UPLOAD VALIDATION
-- =============================================
CREATE PROCEDURE [dbo].[SPP_TXN_SIA_INV_UPLOAD_VALIDATE]
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY

	CREATE TABLE #SIA_INV_UPLOAD
	(
	row_num INT IDENTITY(1,1),
	[type] NVARCHAR(2000) NULL,
	vas_order NVARCHAR(2000) NULL,
	ref_doc_no NVARCHAR(2000) NULL,
	arrival_date NVARCHAR(MAX) NULL,
	arrival_time NVARCHAR(MAX) NULL,
	to_no NVARCHAR(2000) NULL,
	prd_code NVARCHAR(2000) NULL,
	batch_no NVARCHAR(2000) NULL,
	quantity NVARCHAR(2000) NULL,
	plant NVARCHAR(2000) NULL,
	client_code VARCHAR(100) NULL,
	uom NVARCHAR(2000) NULL,
	[expiry_date] NVARCHAR(MAX) NULL,
	is_valid_type VARCHAR(50) DEFAULT 'Invalid type. ',
	is_valid_ref_doc_no VARCHAR(50) DEFAULT 'Invalid ref doc no. ',
	is_valid_arrival_date VARCHAR(50) DEFAULT 'Invalid arrival date. ',
	is_valid_arrival_time VARCHAR(50) DEFAULT 'Invalid arrival time. ',
	is_valid_prd_code VARCHAR(50) DEFAULT 'Invalid product code. ',
	is_valid_batch_no VARCHAR(50) DEFAULT 'Invalid batch no. ',
	is_valid_quantity VARCHAR(50) DEFAULT 'Invalid quantity. ',
	is_valid_plant VARCHAR(50) DEFAULT 'Invalid plant. ',
	is_valid_client_code VARCHAR(50) DEFAULT 'Invalid client code. ',
	is_valid_uom VARCHAR(50) DEFAULT 'Invalid uom. ',
	is_valid_expiry_date VARCHAR(50) DEFAULT 'Invalid expiry date. ',
	is_duplicate VARCHAR(50) DEFAULT 'Duplicate record. ',
	error_msg VARCHAR(MAX) DEFAULT '',
	created_date DATETIME DEFAULT GETDATE()
	)

	INSERT INTO #SIA_INV_UPLOAD (type, vas_order, ref_doc_no, arrival_date, arrival_time, to_no, prd_code, batch_no, quantity, plant, client_code, uom, 
	expiry_date)
	SELECT type, vas_order, ref_doc_no, arrival_date, arrival_time, to_no, prd_code, batch_no, quantity, plant, client_code, uom, expiry_date
	FROM TBL_TMP_SIA_INV_UPLOAD
	WHERE creator_user_id = @user_id

	DELETE FROM TBL_TMP_SIA_INV_UPLOAD WHERE creator_user_id = @user_id

	UPDATE A
	SET is_valid_type = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE A.type IN ('SIA', 'Invoice')

	UPDATE A
	SET is_valid_ref_doc_no = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE A.ref_doc_no IS NOT NULL AND A.ref_doc_no <> ''

	UPDATE A
	SET is_valid_arrival_date = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE TRY_CAST(A.arrival_date AS DATE) IS NOT NULL

	UPDATE A
	SET is_valid_arrival_time = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE TRY_CAST(A.arrival_time AS TIME) IS NOT NULL

	UPDATE A
	SET is_valid_prd_code = 'Y'
	FROM #SIA_INV_UPLOAD A
	INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code

	UPDATE A
	SET is_valid_batch_no = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE A.batch_no IS NOT NULL AND A.batch_no <> ''

	UPDATE A
	SET is_valid_quantity = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE TRY_CAST(A.quantity AS INT) IS NOT NULL

	UPDATE A
	SET is_valid_plant = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE A.plant IS NOT NULL AND A.plant <> ''

	UPDATE A
	SET is_valid_client_code = 'Y'
	FROM #SIA_INV_UPLOAD A
	INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code

	UPDATE A
	SET is_valid_uom = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE A.uom IS NOT NULL AND A.uom <> ''

	UPDATE A
	SET is_valid_expiry_date = 'Y'
	FROM #SIA_INV_UPLOAD A
	WHERE TRY_CAST(A.expiry_date AS DATETIME) IS NOT NULL

	UPDATE A
	SET is_duplicate = 'N'
	FROM #SIA_INV_UPLOAD A
	WHERE (SELECT COUNT(0) FROM #SIA_INV_UPLOAD B WITH (NOLOCK)
		   WHERE B.row_num != A.row_num AND B.type = A.type AND B.ref_doc_no = A.ref_doc_no AND B.prd_code = A.prd_code AND B.batch_no = A.batch_no 
		   AND B.plant = A.plant AND B.client_code = A.client_code
		  ) 
		  +
		  (SELECT COUNT(0) FROM TBL_TXN_SIA_INV B WITH (NOLOCK)
		   WHERE B.type = A.type AND B.ref_doc_no = A.ref_doc_no AND B.prd_code = A.prd_code AND B.batch_no = A.batch_no 
		   AND B.plant = A.plant AND B.client_code = A.client_code
		  ) = 0

	UPDATE #SIA_INV_UPLOAD
	SET error_msg = CASE is_valid_type WHEN 'Y' THEN '' ELSE is_valid_type END + '' + 
					CASE is_valid_ref_doc_no WHEN 'Y' THEN '' ELSE is_valid_ref_doc_no END + '' + 
					CASE is_valid_arrival_date WHEN 'Y' THEN '' ELSE is_valid_arrival_date END + '' +
					CASE is_valid_arrival_time WHEN 'Y' THEN '' ELSE is_valid_arrival_time END + '' +
					CASE is_valid_prd_code WHEN 'Y' THEN '' ELSE is_valid_prd_code END + '' +
					CASE is_valid_batch_no WHEN 'Y' THEN '' ELSE is_valid_batch_no END + '' +
					CASE is_valid_quantity WHEN 'Y' THEN '' ELSE is_valid_quantity END + '' +
					CASE is_valid_plant WHEN 'Y' THEN '' ELSE is_valid_plant END + '' +
					CASE is_valid_client_code WHEN 'Y' THEN '' ELSE is_valid_client_code END + '' +
					CASE is_valid_uom WHEN 'Y' THEN '' ELSE is_valid_uom END + '' +
					CASE is_valid_expiry_date WHEN 'Y' THEN '' ELSE is_valid_expiry_date END + '' +
					CASE is_duplicate WHEN 'N' THEN '' ELSE is_duplicate END
	
	DELETE FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED WHERE creator_user_id = @user_id

	INSERT INTO TBL_TMP_SIA_INV_UPLOAD_VALIDATED (type, vas_order, ref_doc_no, arrival_date, arrival_time, to_no, prd_code, batch_no, quantity, plant, 
	client_code, uom, expiry_date, is_valid_type, is_valid_ref_doc_no, is_valid_arrival_date, is_valid_arrival_time, is_valid_prd_code, is_valid_batch_no, 
	is_valid_quantity, is_valid_plant, is_valid_client_code, is_valid_uom, is_valid_expiry_date, is_duplicate, error_msg, creator_user_id, created_date, changed_user_id, 
	changed_date) 
	SELECT type, vas_order, ref_doc_no, arrival_date, arrival_time, to_no, prd_code, batch_no, quantity, plant, 
	client_code, uom, expiry_date, is_valid_type, is_valid_ref_doc_no, is_valid_arrival_date, is_valid_arrival_time, is_valid_prd_code, is_valid_batch_no, 
	is_valid_quantity, is_valid_plant, is_valid_client_code, is_valid_uom, is_valid_expiry_date, is_duplicate, error_msg, @user_id, getdate(), @user_id, getdate()
	FROM #SIA_INV_UPLOAD

	DECLARE @duplicate_count int

	SELECT @duplicate_count = COUNT(*) 
	FROM #SIA_INV_UPLOAD A
	WHERE (SELECT COUNT(0) FROM #SIA_INV_UPLOAD B WITH (NOLOCK)
		   WHERE B.row_num != A.row_num AND B.type = A.type AND B.prd_code = A.prd_code AND B.batch_no = A.batch_no AND B.quantity = A.quantity
		   AND B.plant = A.plant AND B.client_code = A.client_code AND DATEDIFF(DAY, B.created_date, A.created_date) < 7
		  ) 
		  +
		  (SELECT COUNT(0) FROM TBL_TXN_SIA_INV B WITH (NOLOCK)
		   WHERE B.type = A.type AND B.prd_code = A.prd_code AND B.batch_no = A.batch_no AND B.quantity = A.quantity
		   AND B.plant = A.plant AND B.client_code = A.client_code AND DATEDIFF(DAY, B.created_date, A.created_date) < 7
		  ) > 0

	DROP TABLE #SIA_INV_UPLOAD

	IF @duplicate_count = 0
		SELECT 'OK' as result
	ELSE
		SELECT 'OK' as result, @duplicate_count AS 'duplicate_count'

	END TRY

	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH
END

GO
