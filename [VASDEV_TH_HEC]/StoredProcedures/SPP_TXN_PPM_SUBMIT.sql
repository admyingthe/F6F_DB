SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
-- ========================================================================      
-- Author:  Siow Shen Yee      
-- Create date: 2018-07-13      
-- Description: Submit/Re-submit PPM to SAP      
-- Example Query: exec SPP_TXN_PPM_SUBMIT @param=N'{"action":"Submit","job_ref_no":"G2022/07/0002","line_no":"1,2,3,4"}',@user_id=N'8032'      
-- ========================================================================      
      
CREATE PROCEDURE [dbo].[SPP_TXN_PPM_SUBMIT]      
	@param NVARCHAR(MAX),      
	@user_id INT      
AS      
BEGIN      
	SET NOCOUNT ON;      
       
	DECLARE @action VARCHAR(50), @running_no VARCHAR(50) = 1
	SET @action = (SELECT JSON_VALUE(@param, '$.action'))      
	DECLARE @JobFormat VARCHAR(25)=(SELECT  [format_code] FROM [TBL_REDRESSING_JOB_FORMAT])

	DECLARE @job_ref_no VARCHAR(50), @line_no NVARCHAR(2000)      
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))      
	  
	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date

	
	IF @action = 'ConfirmTO'      
	BEGIN  
	  
		SET @line_no = (SELECT JSON_VALUE(@param, '$.line_no'))      
		SELECT * INTO #LINE_NO1 FROM SF_SPLIT(@line_no,',','')      

		UPDATE VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP 
		SET to_confirm_ind ='P',confirm_to_indicator='P' WHERE workorder_no = @job_ref_no AND to_confirm_ind is null or to_confirm_ind='' AND process_ind='PPM' --AND line_no IN (SELECT DATA FROM #LINE_NO1)   --

	END
	ELSE
	IF @action = 'Submit'      
	BEGIN      
		    
		SET @line_no = (SELECT JSON_VALUE(@param, '$.line_no'))      
		SELECT * INTO #LINE_NO FROM SF_SPLIT(@line_no,',','')      
      
		DECLARE @len INT = 7      
		SELECT TOP 1 @running_no = ISNULL(CAST(CAST(RIGHT(system_running_no, @len) as INT) + 1 AS VARCHAR(50)),1)      
			FROM (SELECT system_running_no FROM TBL_TXN_PPM WITH(NOLOCK)) A ORDER BY CAST(RIGHT(system_running_no, @len) AS INT) DESC      
           
		SET @running_no = 'PPM' + REPLICATE('0', @len - LEN(@running_no)) + @running_no      
   
		UPDATE TBL_TXN_PPM      
		SET system_running_no = @running_no      
		WHERE job_ref_no = @job_ref_no AND line_no IN (SELECT DATA FROM #LINE_NO)      

		UPDATE TBL_TXN_PPM_SAP      
		SET system_running_no = @running_no      
		WHERE job_ref_no = @job_ref_no AND line_no IN (SELECT DATA FROM #LINE_NO)      


		IF(LEFT(@job_ref_no,1) ='S')    
		BEGIN    
			INSERT INTO VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP      
			(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty, prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, status, created_date, created_by, ssto_unit_no, ssto_section, ssto_stg_bin,line_no)      
			SELECT 'TH', 'PPM', vas_order, whs_no, work_ord_ref, @running_no, A.issued_qty, A.prd_code, C.base_uom, 'TH54', '1000', batch_no, CASE WHEN A.action_from_reopen = 'Return' THEN '922' ELSE '921' END, NULL, 'P', @CurrentDateTime, @user_id, dsto_unit_no, dsto_section, dsto_stg_bin ,A.line_no     
			FROM TBL_TXN_PPM A WITH(NOLOCK) 
			INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK)   ON A.job_ref_no = B.job_ref_no      
			INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code      
			WHERE A.job_ref_no = @job_ref_no AND line_no IN (SELECT DATA FROM #LINE_NO)      
			AND NOT EXISTS(SELECT 1 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP D WITH(NOLOCK) WHERE D.requirement_no = @running_no AND D.prd_code = A.prd_code)      
		END    
		ELSE    
		BEGIN   
			
			INSERT INTO VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP      
			(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty, prd_code, uom, plant, sloc, batch_no, expirydate , movement_type, stock_category, status, created_date, created_by, line_no,manufacturing_date)    --ssto_unit_no, ssto_section, ssto_stg_bin,  
			SELECT 'TH', 'PPM', NULL vas_order, A.whs_no, A.job_ref_no , @running_no, A.issued_qty, A.prd_code, C.base_uom, A.plant, D.name, A.batch_no, A.expirydate , CASE WHEN A.action_from_reopen = 'Return' THEN '922' ELSE '921' END, NULL, 'P', @CurrentDateTime, @user_id, A.line_no   ,A.mfg_date  --''dsto_unit_no,'' dsto_section, ''dsto_stg_bin,
			FROM TBL_TXN_PPM A WITH(NOLOCK)      
			--INNER JOIN (SELECT TOP 1 * FROM TBL_TXN_WORK_ORDER  WITH(NOLOCK)   WHERE job_ref_no = @job_ref_no) B ON A.job_ref_no = B.job_ref_no      
			INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code      
			INNER JOIN TBL_MST_DDL D WITH(NOLOCK) ON D.code=A.whs_no  AND D.ddl_code= 'ddlsloc'
			WHERE A.job_ref_no = @job_ref_no AND line_no IN (SELECT DATA FROM #LINE_NO)      
			AND NOT EXISTS(SELECT 1 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP D WITH(NOLOCK) WHERE D.requirement_no = @running_no AND D.prd_code = A.prd_code) 

			--INSERT INTO VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP      
			--(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty, prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, status, created_date, created_by, ssto_unit_no, ssto_section, ssto_stg_bin)      
			--SELECT 'TH', 'PPM', B.vas_order, whs_no, CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE work_ord_ref  END work_ord_ref , @running_no, A.issued_qty, A.prd_code, C.base_uom, 'TH54', '1000', B.batch_no, '921', NULL, 'P', GETDATE(), @user_id, dsto_unit_no, dsto_section, dsto_stg_bin      
			--FROM TBL_TXN_PPM_SAP A WITH(NOLOCK)      
			--INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no      
			--INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code      
			--WHERE A.job_ref_no = @job_ref_no AND line_no IN (SELECT DATA FROM #LINE_NO)      
			--AND NOT EXISTS(SELECT 1 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP D WITH(NOLOCK) WHERE D.requirement_no = @running_no AND D.prd_code = A.prd_code)     
		
		END    
		DROP TABLE #LINE_NO      
	END      
	ELSE IF @action = 'ReSubmit'      
	BEGIN      
		DECLARE @prd_code NVARCHAR(2000)      
		SET @running_no = (SELECT JSON_VALUE(@param, '$.running_no'))      
		SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))   
		SET @line_no = (SELECT JSON_VALUE(@param, '$.line_no'))      
		
		DECLARE @resendcounter INT      
		SET @resendcounter = (SELECT ISNULL(resendcounter,0) FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP WITH(NOLOCK) WHERE requirement_no = @running_no AND prd_code = @prd_code AND line_no=@line_no )      
		DECLARE @to_confirm_ind varchar(10)      
		SET @to_confirm_ind=(SELECT ISNULL(to_confirm_ind,'') FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP  WITH(NOLOCK) WHERE requirement_no = @running_no AND prd_code = @prd_code AND line_no=@line_no )   

		IF @to_confirm_ind=''
		BEGIN
			UPDATE VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP      
			SET status = 'P', 
			resendcounter = @resendcounter + 1      
			WHERE requirement_no = @running_no      
			AND prd_code = @prd_code      
			AND status = 'E'      
			AND country_code = 'TH'   AND line_no=@line_no   
		END
		ELSE
		BEGIN
			UPDATE VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP      
			SET  to_confirm_ind= 'P',
			resendcounter = @resendcounter + 1      
			WHERE requirement_no = @running_no      
			AND prd_code = @prd_code      
			AND  to_confirm_ind = 'E'     
			AND country_code = 'TH'   AND line_no=@line_no  
		END
	END      
      
	INSERT INTO TBL_ADM_AUDIT_TRAIL      
	(module, key_code, action , action_by, action_date)      
	VALUES('PPM-SEARCH', @job_ref_no, @action + ' PPM [' + @running_no + ']', @user_id, @CurrentDateTime)      
END
GO
