SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		YING
-- Create date: 04-07-2023
-- Description:	CHECK WHETHER USER IS AN APPROVER OF VAS ACTIIVTY RATE
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_APPROVER_CHECK] 
	@client_code varchar(100),
	@user_id varchar(100)
AS
BEGIN
	if exists (select * from TBL_MST_RATE_APPROVER_CONFIGURATION where client_code = @client_code and approver_user_ID = @user_id)
	begin
		select 1 as is_approver
	end
	else 
	begin
		select 0 as is_approver
	end
END

GO
