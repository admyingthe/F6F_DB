SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_GET_VENDOR_SUBMIT_SAP]
	@job_ref_no VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @job_event_submited_sap int = 0

    select @job_event_submited_sap = 1 from [TBL_TXN_JOB_EVENT] where 
	running_no > (select TOP 1 running_no from [TBL_TXN_JOB_EVENT] B where
	B.event_id in ('80','40','45','50','90') and isnull(B.end_date,'') <> '' AND job_ref_no = @job_ref_no) AND job_ref_no = @job_ref_no

	SELECT @job_event_submited_sap AS OUTPUT
END

GO
