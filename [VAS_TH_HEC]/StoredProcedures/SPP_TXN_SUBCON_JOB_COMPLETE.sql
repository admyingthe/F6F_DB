SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Close Work Order
-- Example Query: exec SPP_TXN_SUBCON_JOB_COMPLETE @job_ref_no=N'S2021/12/0002', @user_id=N'1'
-- =====================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_SUBCON_JOB_COMPLETE]
	@job_ref_no VARCHAR(50),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @completed_qty INT, @mpo_qty INT
	SET @completed_qty = (SELECT DISTINCT completed_qty + damaged_qty FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id IN ('80','85'))
	SET @mpo_qty = (SELECT CASE WHEN qty_of_goods = 0 THEN ttl_qty_eaches ELSE qty_of_goods END FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

	IF (@completed_qty <= @mpo_qty)
	BEGIN
		DECLARE @num_of_days INT
		SET @num_of_days = (SELECT SUM(DATEDIFF(day, start_date, end_date)) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

		UPDATE TBL_SUBCON_TXN_WORK_ORDER
		SET work_ord_status = 'C',			
			changed_date = GETDATE(),
			changed_user_id = @user_id,
			current_event = NULL
		WHERE job_ref_no = @job_ref_no

		INSERT INTO TBL_ADM_AUDIT_TRAIL (module, key_code, action, action_by, action_date)
		VALUES('WORK-ORDER', @job_ref_no, 'Closed', @user_id, GETDATE())

		-- Submit 'C' to SAP after all product in the same TO is completed
		DECLARE @vas_order VARCHAR(50), @ttl_in_integration INT, @ttl_completed_in_transaction INT
		--SET @vas_order = (SELECT vas_order FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
		SET @ttl_in_integration = (SELECT COUNT(*) FROM VAS_INTEGRATION.dbo.VAS_SUBCON_TRANSFER_ORDER WITH(NOLOCK) WHERE subcon_job_no = @job_ref_no)
		SET @ttl_completed_in_transaction = (SELECT COUNT(*) FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND work_ord_status = 'C')

		IF (@ttl_completed_in_transaction = @ttl_in_integration)
		BEGIN
			--DECLARE @running_no VARCHAR(50) = 1, @len INT = 8
			--SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))
			--							FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC
			--SET @running_no = 'MY' + REPLICATE('0', @len - LEN(@running_no)) + @running_no

			INSERT INTO VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP
			(country_code, process_ind, requirement_no, vas_order, whs_no, status, created_date)
			SELECT DISTINCT 'MY', 'C', requirement_no, vas_order, whs_no, 'P', GETDATE()
			FROM TBL_SUBCON_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no 

			INSERT INTO TBL_ADM_AUDIT_TRAIL (module, key_code, action, action_by, action_date)
			VALUES('WORK-ORDER', @vas_order, 'VAS ORDER COMPLETED', '', GETDATE())
		END

		SELECT 'Y' as closed_ind
	END
	ELSE
		SELECT 'N' as closed_ind
END

GO
