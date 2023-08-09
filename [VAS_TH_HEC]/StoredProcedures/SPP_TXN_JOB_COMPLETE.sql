SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Close Work Order
-- Example Query: exec SPP_TXN_JOB_COMPLETE @job_ref_no=N'G2022/09/00034', @user_id=N'1'
-- =====================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_JOB_COMPLETE]
	@job_ref_no VARCHAR(50),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @completed_qty INT, @mpo_qty INT
	DECLARE @vas_order VARCHAR(50), @ttl_in_integration INT, @ttl_completed_in_transaction INT
	DECLARE @num_of_days INT
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++    SUBCON      ++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	IF(LEFT(@job_ref_no,1) = 'S') --SUBCON
	BEGIN
		SET @completed_qty = (SELECT DISTINCT completed_qty + damaged_qty FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id IN ('80','85'))
		SET @mpo_qty = (SELECT CASE WHEN qty_of_goods = 0 THEN ttl_qty_eaches ELSE qty_of_goods END FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

		IF (@completed_qty <= @mpo_qty)
		BEGIN
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
		--SET @vas_order = (SELECT vas_order FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
			SET @ttl_in_integration = (SELECT COUNT(*) FROM VAS_INTEGRATION_TH.dbo.VAS_SUBCON_TRANSFER_ORDER WITH(NOLOCK) WHERE subcon_job_no = @job_ref_no)
			SET @ttl_completed_in_transaction = (SELECT COUNT(*) FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND work_ord_status = 'C')

			IF (@ttl_completed_in_transaction = @ttl_in_integration)
			BEGIN
				--DECLARE @running_no VARCHAR(50) = 1, @len INT = 8
				--SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))
				--							FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC
				--SET @running_no = 'TH' + REPLICATE('0', @len - LEN(@running_no)) + @running_no

				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
				(country_code, process_ind, requirement_no, vas_order, whs_no, status, created_date)
				SELECT DISTINCT 'TH', 'C', requirement_no, vas_order, whs_no, 'P', GETDATE()
				FROM TBL_SUBCON_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no 

				INSERT INTO TBL_ADM_AUDIT_TRAIL (module, key_code, action, action_by, action_date)
				VALUES('WORK-ORDER', @vas_order, 'VAS ORDER COMPLETED', '', GETDATE())
			END

			SELECT 'Y' as closed_ind
		END
		ELSE
			SELECT 'N' as closed_ind
	END
	ELSE
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++    INBOUND      ++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	BEGIN
		--SET @completed_qty = (SELECT DISTINCT completed_qty  FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no )--+ damaged_qty--AND event_id IN ('90')
		----SET @mpo_qty = (SELECT CASE WHEN qty_of_goods = 0 THEN ttl_qty_eaches ELSE qty_of_goods END FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

		--		 --CASE WHEN LEFT(@job_ref_no,1) = 'V' THEN    qty_of_goods ELSE sum(ttl_qty_eaches) END 

		--	SET @mpo_qty = (SELECT CASE WHEN   qty_of_goods= 0 THEN SUM(ttl_qty_eaches) ELSE qty_of_goods END 
		--					FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK) 
		--					INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET  B WITH(NOLOCK) ON A.job_ref_no=B.job_ref_no  WHERE B.job_ref_no = @job_ref_no 
		--					GROUP BY qty_of_goods )

		 --Added to get Thailand Time along with date
			 DECLARE @CurrentDateTime AS DATETIME
			 SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
			  --Added to get Thailand Time along with date


		--IF (@completed_qty <= @mpo_qty)
		--BEGIN
			SET @num_of_days = (SELECT SUM(DATEDIFF(day, start_date, end_date)) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
			

			


			UPDATE TBL_TXN_WORK_ORDER_JOB_DET
			SET work_ord_status = 'C',			
				changed_date = GETDATE(),
				changed_user_id = @user_id,
				current_event = NULL
			WHERE job_ref_no = @job_ref_no

			INSERT INTO TBL_ADM_AUDIT_TRAIL (module, key_code, action, action_by, action_date)
			VALUES('WORK-ORDER', @job_ref_no, 'Closed', @user_id, @CurrentDateTime)

			-- Submit 'C' to SAP after all product in the same TO is completed
			--SET @vas_order = (SELECT vas_order FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
			--SET @ttl_in_integration = (SELECT COUNT(*) FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE vas_order = @vas_order)
			--SET @ttl_completed_in_transaction = (SELECT COUNT(*) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE vas_order = @vas_order AND work_ord_status = 'C')

			--SET @vas_order = (SELECT DISTINCT vas_order FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
			SELECT  work_order_qty ,A.vas_order ,transfer_order_qty,A.whs_no INTO #TEMP_VAS_ORDER_DATA
			FROM
			(
				SELECT sum(ttl_qty_eaches) work_order_qty ,W.vas_order ,W.whs_no 
				FROM TBL_TXN_WORK_ORDER W   WITH(NOLOCK) 
				INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET  D WITH(NOLOCK) ON W.job_ref_no=D.job_ref_no  
				WHERE  D.work_ord_status = 'C' AND W.vas_order in (SELECT vas_order FROM TBL_TXN_WORK_ORDER  A WITH(NOLOCK) 
				INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET  B WITH(NOLOCK) ON A.job_ref_no=B.job_ref_no  WHERE A.job_ref_no = @job_ref_no  AND work_ord_status = 'C' )
				GROUP BY W.vas_order,W.whs_no
			)A
			INNER JOIN 
			(
				SELECT T.vas_order ,sum(qty)transfer_order_qty,T.whs_no 
				FROM  VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER T  
				WHERE T.vas_order in (SELECT vas_order FROM TBL_TXN_WORK_ORDER  A WITH(NOLOCK) 
				INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET  B WITH(NOLOCK) ON A.job_ref_no=B.job_ref_no WHERE A.job_ref_no = @job_ref_no  AND work_ord_status = 'C' )
				GROUP BY T.vas_order,T.whs_no
			)B ON A.vas_order=B.vas_order AND A.whs_no=B.whs_no

			

			IF ((SELECT count(*) FROM #TEMP_VAS_ORDER_DATA WHERE work_order_qty = transfer_order_qty)>0)
			BEGIN
				

				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
				(country_code, process_ind, requirement_no, vas_order, whs_no, status, created_date)
				SELECT DISTINCT 'TH', 'C', vas_order, vas_order, whs_no, 'P', @CurrentDateTime
				FROM #TEMP_VAS_ORDER_DATA WHERE work_order_qty = transfer_order_qty


				INSERT INTO TBL_ADM_AUDIT_TRAIL (module, key_code, action, action_by, action_date)
				SELECT DISTINCT 'WORK-ORDER', vas_order,'VAS ORDER COMPLETED', '', @CurrentDateTime
				FROM #TEMP_VAS_ORDER_DATA WHERE work_order_qty = transfer_order_qty
			END

			SELECT 'Y' as closed_ind
			DROP TABLE #TEMP_VAS_ORDER_DATA
		--END
		--ELSE
		--	SELECT 'N' as closed_ind
	END

END

GO
