SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_UPDATE_VENDOR_RECORDS]
@param NVARCHAR(MAX), @selectedVendorId INT, @selectedProdCode VARCHAR(50), @user_id INT
AS
BEGIN
SET NOCOUNT ON;

DECLARE @existedVendor BIT = 0, @selectedVendor NVARCHAR(MAX) = '', 
@currentDatetime datetime = GETDATE()

SELECT @selectedVendor = vendor_name FROM TBL_MST_VENDOR_LISTING WITH(NOLOCK) WHERE id = @selectedVendorId
		
IF (@selectedVendor = '' OR @selectedVendor IS NULL)
BEGIN
SELECT 0 AS OUTPUT; --- OUTPUT ---
RETURN;
END

SELECT * 
INTO #INPUT_RECORD
FROM OPENJSON(@param)
WITH (
job_ref_no NVARCHAR(20) '$.job_ref_no',
vas_activity_id NVARCHAR(MAX) '$.vas_activity',
issued_qty decimal(18,2) '$.issued_qty',
normal_qty decimal(18,2) '$.normal_qty',
ot_qty decimal(18,2) '$.ot_qty',
vas_activity_rate_hdr_id INT '$.vas_activity_rate_hdr_id',
vas_activity_type VARCHAR(20) '$.vas_activity_type'
)

DECLARE @job_ref_no NVARCHAR(20) = (SELECT DISTINCT job_ref_no FROM #INPUT_RECORD WITH(NOLOCK))
DECLARE @already_has_records BIT = 0, @already_has_vendor BIT = 0
SELECT @already_has_records = 1 FROM TBL_ADM_JOB_VENDOR WITH(NOLOCK) WHERE job_ref_no = @job_ref_no and prd_code = @selectedProdCode
SELECT @already_has_vendor = 1 FROM TBL_ADM_JOB_VENDOR WITH(NOLOCK) WHERE job_ref_no = @job_ref_no and prd_code = @selectedProdCode and vendor_id = @selectedVendorId

IF @already_has_records = 0
BEGIN
INSERT INTO TBL_ADM_MANAGE_ACTIVE_VENDOR_VERSION(vendor_id, job_ref_no)
VALUES(@selectedVendorId, @job_ref_no)

INSERT INTO TBL_ADM_JOB_VENDOR(job_ref_no, prd_code, vendor_id, vas_activity_id, issued_qty, normal_qty, ot_qty, VAS_Activity_Rate_HDR_ID, activity_type, created_date)
SELECT job_ref_no, @selectedProdCode, @selectedVendorId ,vas_activity_id, issued_qty, normal_qty, ot_qty, vas_activity_rate_hdr_id, vas_activity_type, @currentDatetime FROM #INPUT_RECORD WITH(NOLOCK)

INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
VALUES('JOB-VENDOR', @job_ref_no + ',' + @selectedProdCode, 'Added VAS activities', @user_id, @currentDatetime)
END
ELSE
BEGIN
IF (@already_has_vendor = 0)
BEGIN
	UPDATE TBL_ADM_JOB_VENDOR SET vendor_id = @selectedVendorId WHERE job_ref_no = @job_ref_no and prd_code = @selectedProdCode
END
	
select A.job_ref_no, B.prd_code, B.vendor_id, A.vas_activity_id, A.issued_qty, A.normal_qty, A.ot_qty, B.issued_qty as issued_qty_old, B.normal_qty as normal_qty_old, B.ot_qty as ot_qty_old, A.vas_activity_type
into #ISSUED_QTY_DIFF
FROM #INPUT_RECORD A INNER JOIN TBL_ADM_JOB_VENDOR B ON A.job_ref_no = B.job_ref_no and B.prd_code = @selectedProdCode and B.vendor_id = @selectedVendorId and A.vas_activity_id = B.vas_activity_id and A.vas_activity_type = B.activity_type
WHERE A.issued_qty <> B.issued_qty

select A.job_ref_no, B.prd_code, B.vendor_id, A.vas_activity_id, A.issued_qty, A.normal_qty, A.ot_qty, B.issued_qty as issued_qty_old, B.normal_qty as normal_qty_old, B.ot_qty as ot_qty_old, A.vas_activity_type
into #NORMAL_QTY_DIFF
FROM #INPUT_RECORD A INNER JOIN TBL_ADM_JOB_VENDOR B ON A.job_ref_no = B.job_ref_no and B.prd_code = @selectedProdCode and B.vendor_id = @selectedVendorId and A.vas_activity_id = B.vas_activity_id and A.vas_activity_type = B.activity_type
WHERE A.normal_qty <> B.normal_qty

select A.job_ref_no, B.prd_code, B.vendor_id, A.vas_activity_id, A.issued_qty, A.normal_qty, A.ot_qty, B.issued_qty as issued_qty_old, B.normal_qty as normal_qty_old, B.ot_qty as ot_qty_old, A.vas_activity_type
into #OT_QTY_DIFF
FROM #INPUT_RECORD A INNER JOIN TBL_ADM_JOB_VENDOR B ON A.job_ref_no = B.job_ref_no and B.prd_code = @selectedProdCode and B.vendor_id = @selectedVendorId and A.vas_activity_id = B.vas_activity_id and A.vas_activity_type = B.activity_type
WHERE A.ot_qty <> B.ot_qty

select * 
into #VAS_ADDITIONAL_DIFF
FROM #INPUT_RECORD A
WHERE NOT EXISTS(SELECT * FROM TBL_ADM_JOB_VENDOR B WHERE A.job_ref_no = B.job_ref_no and B.prd_code = @selectedProdCode and B.vendor_id = @selectedVendorId and A.vas_activity_id = B.vas_activity_id and A.vas_activity_type = B.activity_type)

select * 
into #VAS_ADDITIONAL_DELETED
FROM TBL_ADM_JOB_VENDOR B
WHERE NOT EXISTS(SELECT * FROM #INPUT_RECORD A WHERE A.job_ref_no = B.job_ref_no and B.prd_code = @selectedProdCode and B.vendor_id = @selectedVendorId and A.vas_activity_id = B.vas_activity_id and A.vas_activity_type = B.activity_type)
and B.job_ref_no = @job_ref_no and B.prd_code = @selectedProdCode
	
UPDATE A SET A.issued_qty = B.issued_qty, A.normal_qty = B.normal_qty, A.ot_qty = B.ot_qty, changed_date = @currentDatetime
FROM TBL_ADM_JOB_VENDOR A INNER JOIN #ISSUED_QTY_DIFF B ON A.job_ref_no = B.job_ref_no and A.vendor_id = @selectedVendorId and A.prd_code = @selectedProdCode and A.vas_activity_id = B.vas_activity_id and B.vas_activity_type = A.activity_type

UPDATE A SET A.issued_qty = B.issued_qty, A.normal_qty = B.normal_qty, A.ot_qty = B.ot_qty, changed_date = @currentDatetime
FROM TBL_ADM_JOB_VENDOR A INNER JOIN #NORMAL_QTY_DIFF B ON A.job_ref_no = B.job_ref_no and A.vendor_id = @selectedVendorId and A.prd_code = @selectedProdCode and A.vas_activity_id = B.vas_activity_id and B.vas_activity_type = A.activity_type

UPDATE A SET A.issued_qty = B.issued_qty, A.normal_qty = B.normal_qty, A.ot_qty = B.ot_qty, changed_date = @currentDatetime
FROM TBL_ADM_JOB_VENDOR A INNER JOIN #OT_QTY_DIFF B ON A.job_ref_no = B.job_ref_no and A.vendor_id = @selectedVendorId and A.prd_code = @selectedProdCode and A.vas_activity_id = B.vas_activity_id and B.vas_activity_type = A.activity_type

INSERT TBL_ADM_JOB_VENDOR (job_ref_no, prd_code, vendor_id, vas_activity_id, issued_qty, normal_qty, ot_qty, VAS_Activity_Rate_HDR_ID, activity_type, created_date)
SELECT job_ref_no, @selectedProdCode, @selectedVendorId ,vas_activity_id, issued_qty, normal_qty, ot_qty, vas_activity_rate_hdr_id, vas_activity_type, @currentDatetime FROM #VAS_ADDITIONAL_DIFF WITH(NOLOCK)

DELETE TBL_ADM_JOB_VENDOR where id in (select id from #VAS_ADDITIONAL_DELETED)

--INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
--SELECT 'JOB-VENDOR',@job_ref_no + ',' + @selectedProdCode, B.description + ' issued qty has been changed from ' + CONVERT(VARCHAR(MAX), issued_qty_old) + ' to ' + CONVERT(VARCHAR(MAX), issued_qty) + '.', @user_id, @currentDatetime  FROM #ISSUED_QTY_DIFF A INNER JOIN TBL_MST_ACTIVITY_LISTING B ON A.vas_activity_id = B.id

INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
SELECT 'JOB-VENDOR',@job_ref_no + ',' + @selectedProdCode, B.description + ' normal qty has been changed from ' + CONVERT(VARCHAR(MAX),normal_qty_old) + ' to ' + CONVERT(VARCHAR(MAX),normal_qty) + '.', @user_id, @currentDatetime  FROM #NORMAL_QTY_DIFF A INNER JOIN TBL_MST_ACTIVITY_LISTING B ON A.vas_activity_id = B.id

INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
SELECT 'JOB-VENDOR',@job_ref_no + ',' + @selectedProdCode, B.description + ' ot qty has been changed from ' + CONVERT(VARCHAR(MAX),ot_qty_old) + ' to ' + CONVERT(VARCHAR(MAX),ot_qty) + '.', @user_id, @currentDatetime  FROM #OT_QTY_DIFF A INNER JOIN TBL_MST_ACTIVITY_LISTING B ON A.vas_activity_id = B.id

INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
SELECT 'JOB-VENDOR',@job_ref_no + ',' + @selectedProdCode, 'Add additional activity: ' + B.description + '.', @user_id, @currentDatetime  FROM #VAS_ADDITIONAL_DIFF A INNER JOIN TBL_MST_ACTIVITY_LISTING B ON A.vas_activity_id = B.id

INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
SELECT 'JOB-VENDOR',@job_ref_no + ',' + @selectedProdCode, 'Delete additional activity: ' + B.description + '.', @user_id, @currentDatetime  FROM #VAS_ADDITIONAL_DELETED A INNER JOIN TBL_MST_ACTIVITY_LISTING B ON A.vas_activity_id = B.id

DROP TABLE #ISSUED_QTY_DIFF, #NORMAL_QTY_DIFF, #OT_QTY_DIFF, #VAS_ADDITIONAL_DIFF, #VAS_ADDITIONAL_DELETED
END

IF (LEFT(@job_ref_no,1) = 'G')
BEGIN
DECLARE @system_running_no NVARCHAR(20) = '', @index_working int = 1, @current_prd_code VARCHAR(50) = ''
DECLARE @TBL_PRODUCT_CODE TABLE (Id int identity(1,1),prd_code VARCHAR(50))

SELECT TOP 1 @system_running_no = running_no FROM TBL_TXN_JOB_EVENT 
WHERE job_ref_no=@job_ref_no
AND event_id=80 
ORDER BY created_date DESC

INSERT INTO @TBL_PRODUCT_CODE (prd_code)
SELECT DISTINCT prd_code
FROM TBL_TXN_PPM A WITH(NOLOCK) 
WHERE A.job_ref_no = @job_ref_no 
--AND running_no=@system_running_no
AND prd_code <> @selectedProdCode

SELECT * INTO #additionalVAS FROM TBL_ADM_JOB_VENDOR where activity_type like 'Additional%' and job_ref_no = @job_ref_no and prd_code = @selectedProdCode

WHILE (@index_working <= (SELECT COUNT(prd_code) FROM @TBL_PRODUCT_CODE))
BEGIN
	DECLARE @TBL_NEW_VAS TABLE (activity_id int, display_name varchar(max), issued_qty decimal(18,2), normal_qty decimal(18,2), normal_rate decimal(18,2), ot_qty decimal(18,2), ot_rate decimal(18,2), vas_activity_rate_hdr_id int, activity_type varchar(max), date_from varchar(max), date_to varchar(max), prd_code varchar(50), vendor_id int)
	DECLARE @param_VAS VARCHAR(max) = '', @existsProductCode BIT = 0

	SELECT @current_prd_code = prd_code FROM @TBL_PRODUCT_CODE where id = @index_working

	SET @param_VAS = '{"job_ref_no":"'+ @job_ref_no + '", "vendor_name":"ALL", "prd_code":"' + @current_prd_code + '"}'

	INSERT INTO @TBL_NEW_VAS (activity_id, display_name, issued_qty, normal_qty, normal_rate, ot_qty, ot_rate, vas_activity_rate_hdr_id, activity_type, date_from, date_to, prd_code, vendor_id)
    EXEC [VAS_MY_HEC].dbo.[SPP_GET_VENDOR_INFO] @param = @param_VAS

	SELECT @existsProductCode = 1 FROM TBL_ADM_JOB_VENDOR WITH(NOLOCK) WHERE job_ref_no = @job_ref_no and prd_code = @current_prd_code

	UPDATE TBL_ADM_JOB_VENDOR SET vendor_id = @selectedVendorId WHERE job_ref_no = @job_ref_no and prd_code = @current_prd_code

	IF (@existsProductCode = 0)
	BEGIN
		INSERT TBL_ADM_JOB_VENDOR (job_ref_no, prd_code, vendor_id, vas_activity_id, issued_qty, normal_qty, ot_qty, VAS_Activity_Rate_HDR_ID, activity_type, created_date)
		SELECT @job_ref_no, @current_prd_code, @selectedVendorId ,activity_id, issued_qty, normal_qty, ot_qty, vas_activity_rate_hdr_id, activity_type, @currentDatetime FROM @TBL_NEW_VAS

		INSERT INTO TBL_ADM_AUDIT_TRAIL(module, key_code, action, action_by, action_date)
		VALUES('JOB-VENDOR', @job_ref_no + ',' + @current_prd_code, 'Added VAS activities', @user_id, @currentDatetime)
	END
	ELSE
	BEGIN
		DELETE A FROM TBL_ADM_JOB_VENDOR A WHERE job_ref_no = @job_ref_no and prd_code = @current_prd_code and activity_type like 'Additional%'
		and NOT EXISTS(SELECT * FROM #additionalVAS B WHERE A.vas_activity_id = B.vas_activity_id)
	END

	INSERT TBL_ADM_JOB_VENDOR (job_ref_no, prd_code, vendor_id, vas_activity_id, issued_qty, normal_qty, ot_qty, VAS_Activity_Rate_HDR_ID, activity_type, created_date)
	SELECT @job_ref_no, @current_prd_code, @selectedVendorId ,vas_activity_id, 0, 0, 0, vas_activity_rate_hdr_id, activity_type, @currentDatetime FROM #additionalVAS A
	WHERE NOT EXISTS(SELECT * FROM TBL_ADM_JOB_VENDOR B WHERE A.vas_activity_id = B.vas_activity_id and A.job_ref_no = B.job_ref_no and B.prd_code = @current_prd_code AND B.activity_type like 'Additional%')

	SET @index_working = @index_working + 1
END

DROP TABLE #additionalVAS
END

SELECT 1 AS OUTPUT; --- OUTPUT ---

DROP TABLE #INPUT_RECORD
END
GO
