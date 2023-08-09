SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		YING
-- Create date: 04-07-2023
-- Description:	CHECK WHETHER USER IS AN APPROVER OF VAS ACTIIVTY RATE
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_PENDING_CHECK] 
	@VAS_activity_rate_code varchar(100),
	@user_id varchar(100)
AS
BEGIN
	if exists (select 1 from TBL_MST_VAS_ACTIVITY_RATE_HDR where VAS_Activity_Rate_Code = @VAS_activity_rate_code and status in ('P'))
	begin
		select 1 as is_pending
	end
	else 
	begin
		select 0 as is_pending
	end
END

-- update TBL_MST_VAS_ACTIVITY_RATE_HDR set status = 'P' where VAS_Activity_Rate_Code = '020320230014'
GO
