SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve Work Order informations
-- Example Query: exec SPP_MST_GET_GROUP_PRD_LIST @param=N'{"job_ref_no":"G2022/09/00018","page":"JobEvent"}',@user_id=10084
-- ==========================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_GET_GROUP_PRD_LIST]
	@param	NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @job_ref_no VARCHAR(50),@page VARCHAR(50), @prd_code VARCHAR(50),@json_activities NVARCHAR(MAX)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	SET @page = (SELECT JSON_VALUE(@param, '$.page'))

	
	Select Count(prd_code)count FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
	WHERE A.job_ref_no = @job_ref_no 

	if @page='CreateWO'
	BEGIN
		SELECT *
		FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
		WHERE A.job_ref_no = @job_ref_no 
	END
	ELSE
	BEGIN
		IF (SELECT  count(*) FROM TBL_TXN_JOB_EVENT_DET A WITH(NOLOCK) 	WHERE A.job_ref_no = @job_ref_no )=0
		BEGIN

			SELECT prd_code,inbound_doc,''vas_order,batch_no, to_no,SUM(ttl_qty_eaches ) issued_qty,SUM(ttl_qty_eaches )  completed_qty,0 damaged_qty,uom,sloc,plant,whs_no,stock_category,special_stock_indicator,special_stock
			FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
			WHERE A.job_ref_no = @job_ref_no 
			GROUP BY prd_code,batch_no,uom,sloc,plant,whs_no,stock_category,special_stock_indicator,special_stock,inbound_doc,to_no--,vas_order
		END
		ELSE
		BEGIN	
		
			DECLARE @Previous_running_no VARCHAR(50)=(select TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no=@job_ref_no AND event_id=80 ORDER BY created_date DESC)

			SELECT prd_code,inbound_doc,'null'vas_order,batch_no,to_no,event_id,start_date,end_date, completed_qty issued_qty,completed_qty,0 damaged_qty,uom,sloc,plant,whs_no,stock_category,special_stock_indicator,special_stock
			FROM TBL_TXN_JOB_EVENT_DET A WITH(NOLOCK) 
			WHERE A.job_ref_no = @job_ref_no AND running_no=@Previous_running_no
		END
	END
END



GO
