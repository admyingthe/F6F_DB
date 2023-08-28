SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VENDOR_MASTER_AUDIT_TRAIL]
	@key_code VARCHAR(100),
	@action VARCHAR (250),
	@user_id INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO TBL_ADM_AUDIT_TRAIL  
	(module, key_code, [action], action_by, action_date)  
	VALUES('VENDOR-LISTING', @key_code, @action, @user_id, GETDATE()) 
END

GO
