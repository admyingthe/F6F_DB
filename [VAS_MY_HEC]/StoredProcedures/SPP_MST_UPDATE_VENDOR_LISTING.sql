SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SPP_MST_UPDATE_VENDOR_LISTING]
	@id int,
	@vendor_code varchar(50),
	@vendor_name nvarchar(max),
	@ship_to_code nvarchar(max) = '',
	@sold_to_code nvarchar(max) = '',
	@prayer_code nvarchar(max) = '',
	@material_group nvarchar(max) = '',
	@user_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE [TBL_MST_VENDOR_LISTING] SET
	vendor_code = @vendor_code,
	vendor_name = @vendor_name,
	ship_to_code = @ship_to_code,
	sold_to_code = @sold_to_code,
	prayer_code = @prayer_code,
	material_group = @material_group,
	changed_user_id = @user_id,
	changed_date = getdate()
	WHERE ID = @id
END
GO
