SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Create new MLL
-- Example Query: exec SPP_MST_MLL_CREATE @submit_obj=N'{"client_code":"0E32","type_vas":"RD","sub":"00","search_vas":"Search","add":"Add","save":"Save MLL Desc. &amp; Validity Period","copy":"Copy","export":"Export","submit":"Submit","approve":"Approve","reject":"Reject","ddl_mll_no":"MLL030300RD00001","validity_period":"2018-07-03 - 2018-12-31","status":"Approved by bsadmin on 2018-06-26","mll_no":"MLL0E3200RD00001","prd_code":"100654509","prd_desc":"AL-004 Burn Dressing Double Pack (L)","storage_cond":"Y0","reg_no":"test","remarks":"test","client_ref_no":"","revision_no":"","attachment":"","save_next":"Save and Next","save_close":"Save and Close","rejection_reason":"","rejection_save":"Save MLL Desc. &amp; Validity Period","copy_master_vas":"MLL009300RD00001","yes":"Yes","mll_desc":"Alcon MLL","department":"","vas_activities":[{"prd_code":"450000018","page_dtl_id":21,"radio_val":"Y"},{"prd_code":"450000013,450000019","page_dtl_id":23,"radio_val":"P"},{"prd_code":"","page_dtl_id":24,"radio_val":"P"},{"prd_code":"","page_dtl_id":25,"radio_val":"P"},{"prd_code":"","page_dtl_id":27,"radio_val":"P"},{"prd_code":"","page_dtl_id":28,"radio_val":"N"},{"prd_code":"","page_dtl_id":29,"radio_val":"N"},{"prd_code":"","page_dtl_id":30,"radio_val":"N"},{"prd_code":"","page_dtl_id":2093,"radio_val":"N"}],"mode":"New"}',@user_id=N'1'
-- Output : prd_code
-- =======================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_CREATE]
	@submit_obj	nvarchar(max),
	@user_id	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @mll_no VARCHAR(100), @mll_desc NVARCHAR(250), @prd_code VARCHAR(50), @storage_cond VARCHAR(50), @registration_no VARCHAR(50), @remarks NVARCHAR(MAX),
	@vas_activities NVARCHAR(MAX), @mode VARCHAR(50), @client_ref_no NVARCHAR(100), @revision_no NVARCHAR(100),@medical_device_usage  NVARCHAR(50),@bm_ifu  NVARCHAR(50), @qa_required int
	SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
	SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
	SET @type_of_vas = (SELECT JSON_VALUE(@submit_obj, '$.type_vas'))
	SET @sub = (SELECT JSON_VALUE(@submit_obj, '$.sub'))
	SET @mll_no = (SELECT JSON_VALUE(@submit_obj, '$.mll_no'))
    SET @prd_code = (SELECT JSON_VALUE(@submit_obj, '$.prd_code'))
	SET @storage_cond = (SELECT JSON_VALUE(@submit_obj, '$.storage_cond'))
	SET @registration_no = ISNULL((SELECT JSON_VALUE(@submit_obj, '$.reg_no')), '')
	SET @remarks = ISNULL((SELECT REPLACE(JSON_VALUE(@submit_obj, '$.remarks'), '&#39;', '''')), '')
	SET @vas_activities = (SELECT JSON_QUERY(@submit_obj, '$.vas_activities'))
	SET @mode = (SELECT JSON_VALUE(@submit_obj, '$.mode'))
	SET @client_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.client_ref_no'))
	SET @revision_no = ISNULL((SELECT JSON_VALUE(@submit_obj, '$.revision_no')), '')
	SET @medical_device_usage= ISNULL((SELECT JSON_VALUE(@submit_obj, '$.medical_device_usage')), '')
	SET @qa_required = ISNULL((SELECT JSON_VALUE(@submit_obj, '$.qa_required_view')), '')
	SET @bm_ifu= ISNULL((SELECT JSON_VALUE(@submit_obj, '$.bm_ifu')), '')
	EXEC REPLACE_SPECIAL_CHARACTER @remarks, @remarks OUTPUT

	--declare @dept_code varchar(10)
	--select @dept_code = department from VAS.dbo.TBL_ADM_USER where user_id = @user_id

	IF (@mode = 'New')
	BEGIN
		IF(SELECT COUNT(*) FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no) = 0
		BEGIN
			INSERT INTO TBL_MST_MLL_HDR
			(client_code, type_of_vas, sub, mll_no, mll_status, start_date, end_date, client_ref_no, revision_no, created_date, creator_user_id)--, created_user_dept_code
			VALUES
			--(@client_code, @type_of_vas, @sub, @mll_no, 'Draft', GETDATE(), DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, -1), @client_ref_no, @revision_no, GETDATE(), @user_id)
			(@client_code, @type_of_vas, @sub, @mll_no, 'Draft', DATEADD(day, 7, GETDATE()), DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, -1), @client_ref_no, @revision_no, GETDATE(), @user_id)--, @dept_code

			IF(SELECT COUNT(*) FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code) = 0
			BEGIN
				INSERT INTO TBL_MST_MLL_DTL
				(mll_no, prd_code, storage_cond, registration_no, remarks, vas_activities, qa_required,medical_device_usage,bm_ifu)
				VALUES
				(@mll_no, @prd_code, @storage_cond, @registration_no, @remarks, @vas_activities, @qa_required, @medical_device_usage,@bm_ifu)

				SELECT @prd_code as prd_code
			END
			ELSE
			BEGIN
				PRINT '1'
				SELECT '' as prd_code
			END
		END
		ELSE
		BEGIN
			PRINT '2'
			SELECT '' as prd_code
		END

		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		SELECT 'MLL', @mll_no, 'Created', @user_id, GETDATE()

	END
	ELSE IF(@mode = 'Add')
	BEGIN
		IF(SELECT COUNT(*) FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code) = 0
		BEGIN
			INSERT INTO TBL_MST_MLL_DTL
			(mll_no, prd_code, storage_cond, registration_no, remarks, vas_activities, qa_required,medical_device_usage,bm_ifu)
			VALUES
			(@mll_no, @prd_code, @storage_cond, @registration_no, @remarks, @vas_activities, @qa_required, @medical_device_usage,@bm_ifu)

			INSERT INTO TBL_ADM_AUDIT_TRAIL
			(module, key_code, action, action_by, action_date)
			SELECT 'MLL', @mll_no, 'Added new item ' + @prd_code, @user_id, GETDATE()

			SELECT @prd_code as prd_code
		END
		ELSE
			SELECT '' as prd_code
	END
	ELSE IF (@mode = 'Edit')
	BEGIN
		
		UPDATE TBL_MST_MLL_HDR
		SET client_ref_no = @client_ref_no,
			revision_no = @revision_no
		WHERE mll_no = @mll_no

		UPDATE TBL_MST_MLL_DTL
		SET storage_cond = @storage_cond,
			registration_no = @registration_no,
			remarks = @remarks,
			vas_activities = @vas_activities,
			qa_required = @qa_required,
			medical_device_usage=@medical_device_usage,
			bm_ifu=@bm_ifu
		WHERE mll_no = @mll_no AND prd_code = @prd_code

		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		SELECT 'MLL', @mll_no, 'Edited item ' + @prd_code, @user_id, GETDATE()

		SELECT @prd_code as prd_code
	END
END


GO
