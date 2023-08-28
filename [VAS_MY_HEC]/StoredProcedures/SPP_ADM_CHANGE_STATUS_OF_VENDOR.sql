SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADM_CHANGE_STATUS_OF_VENDOR]  
@param NVARCHAR(MAX)  
, @user_id INT  
AS  
BEGIN  
 DECLARE @is_reactivated BIT, @lst_id_change_status NVARCHAR(MAX)  
 SET @is_reactivated = (SELECT JSON_VALUE(@param, '$.is_reactivated'))  
 SET @lst_id_change_status = (SELECT JSON_VALUE(@param, '$.lst_id_change_status'))  
  
 DECLARE @status_audit_param NVARCHAR(10) = ''  
 DECLARE @status_update_param NVARCHAR(10) = ''  
 IF @is_reactivated = 1  
 BEGIN  
  SET @status_audit_param = 'Reactive'  
  SET @status_update_param = 'Active'  
 END  
 ELSE  
 BEGIN  
  SET @status_audit_param = 'Deactive'  
  SET @status_update_param = 'Inactive'  
 END  
  
 CREATE TABLE #TEMP  
 (  
  row_no INT IDENTITY(1,1),  
  id INT NOT NULL,  
  key_code NVARCHAR(100),  
  [action] NVARCHAR(100)  
 )  
  
 DECLARE @sql NVARCHAR(MAX) = ' INSERT INTO #TEMP  
 (id, key_code, [action])  
 SELECT id, '''+ @status_audit_param + ' current items'', ''' + @status_audit_param +' - '' + vendor_code + '' - '' + vendor_name + '' - '' + ship_to_code + '' - '' + sold_to_code FROM [dbo].[TBL_MST_VENDOR_LISTING] WHERE id IN ' + @lst_id_change_status  
  
 DECLARE @sql2 NVARCHAR(MAX) = 'UPDATE [dbo].[TBL_MST_VENDOR_LISTING]   
 SET status = ''' + @status_update_param + '''  
 WHERE id IN ' + @lst_id_change_status  
  
 EXEC (@sql)  
 EXEC (@sql2)  
  
 DECLARE @total INT = (SELECT COUNT(*) FROM #TEMP)  
 DECLARE @i INT = 0  
  
 WHILE @i <= @total  
 BEGIN  
  DECLARE @current_key_code NVARCHAR(100) = ''  
  DECLARE @current_action NVARCHAR(100) = ''  
  
  SELECT @current_key_code = key_code, @current_action = [action] FROM #TEMP WHERE row_no = @i  
  
  IF @current_key_code <> '' AND @current_action <> ''  
  BEGIN  
   EXEC SPP_MST_VENDOR_MASTER_AUDIT_TRAIL @current_key_code, @current_action, @user_id  
  END  
  
  SET @i += 1  
 END  
  
 DROP TABLE #TEMP  
END  
GO
