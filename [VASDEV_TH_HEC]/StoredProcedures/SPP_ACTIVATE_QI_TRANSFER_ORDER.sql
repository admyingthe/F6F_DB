SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_ACTIVATE_QI_TRANSFER_ORDER] 
	-- Add the parameters for the stored procedure here
	@lst_qi_id_change_status varchar(max) = '',
	@user_id varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 CREATE TABLE #TEMP  
	 (  
	  row_no INT IDENTITY(1,1),  
	  id INT NOT NULL,  
	  qi_type NVARCHAR(50) 
	 )  

	DECLARE @sql NVARCHAR(MAX) = 'INSERT INTO #TEMP  
	(id,qi_type)  
	 SELECT id, qi_type FROM [dbo].[TBL_ADM_QI_TYPE] WHERE status = ''Active'''

	IF @lst_qi_id_change_status <> ''
	BEGIN
		select @sql = @sql + ' AND ID IN ' + @lst_qi_id_change_status  

		--UPDATE [VASDEV_INTEGRATION_TH].dbo.[VAS_TRANSFER_ORDER]
		--SET temp_logger = 'Y', temp_logger_released_date = GETDATE(), temp_logger_released_by = @user_id
		--WHERE
		--qi_type like @qi_type + '-%'  
		--and ISNULL(workorder_no,'') <> ''
		--and ISNULL(temp_logger,'') not in ('R','Y')
	END
	
	EXEC (@sql)

	UPDATE A
	SET temp_logger = 'Y', temp_logger_released_date = GETDATE(), temp_logger_released_by = @user_id
	FROM [VASDEV_INTEGRATION_TH].dbo.[VAS_TRANSFER_ORDER] A 
	INNER JOIN #temp B on A.qi_type like B.qi_type + '-%'
	WHERE
	ISNULL(workorder_no,'') <> ''
	and ISNULL(temp_logger,'') not in ('R','Y')
	and ISNULL(to_no,'') <> ''

	DROP TABLE #temp
END

GO
