SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_ADD_NEW_VENDOR_LISTING]
	@vendor_code VARCHAR(50),    
	@vendor_name NVARCHAR(max),
	@ship_to_code NVARCHAR(max) = '',
	@sold_to_code NVARCHAR(max) = '',
	@prayer_code NVARCHAR(max) = '',
	@material_group NVARCHAR(max) = '',
	@user_id int
AS
BEGIN
	DECLARE @total_row INT = 0    
	SET @total_row = (SELECT COUNT(*) FROM [dbo].[TBL_MST_VENDOR_LISTING] WHERE 
	vendor_code = @vendor_code AND vendor_name = @vendor_name AND ship_to_code = @ship_to_code AND sold_to_code = @sold_to_code AND prayer_code = @prayer_code)    
    
	IF @total_row = 0    
		BEGIN    
			INSERT INTO [dbo].[TBL_MST_VENDOR_LISTING]  
			(vendor_code,vendor_name,ship_to_code,sold_to_code,prayer_code,material_group,creator_user_id, created_date)  
			VALUES (@vendor_code, @vendor_name,@ship_to_code,@sold_to_code,@prayer_code,@material_group,@user_id,GETDATE())    
    
			SELECT id FROM [dbo].[TBL_MST_VENDOR_LISTING]     
			WHERE vendor_code = @vendor_code     
			AND vendor_name = @vendor_name  
			AND ship_to_code = @ship_to_code AND sold_to_code = @sold_to_code AND prayer_code = @prayer_code AND material_group = @material_group
		END    
	ELSE    
		BEGIN    
			SELECT -1    
		END
END

GO
