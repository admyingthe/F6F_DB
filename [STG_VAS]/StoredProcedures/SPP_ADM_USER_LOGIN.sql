/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_LOGIN]    Script Date: 08-Aug-23 8:39:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [SPP_ADM_USER_LOGIN] 'bsadmin', 'YL/Q5oQ7uZeS+3quEBLjKQ=='    
    
CREATE PROCEDURE [dbo].[SPP_ADM_USER_LOGIN]    
 @USERNAME nvarchar(100) = '',    
 @PASSWORD nvarchar(100) = ''    
AS    
BEGIN    
 -- 0 = user not found    
 -- 1 = user found but disabled (inactive)    
 -- 2 = user found but not avaiable (deleted)    
 -- 3 = user max retry reached (admin to reset login_cnt to 0)    
    
 IF EXISTS (SELECT 1 FROM TBL_ADM_USER WITH(NOLOCK) WHERE login = @USERNAME and password = @PASSWORD)    
 BEGIN    
  UPDATE TBL_ADM_USER    
  SET login_date = GETDATE()    
  WHERE login = @USERNAME    
    
  SELECT TOP 1 1 as ind, A.user_id, A.login, B.country_id, B.country_code, B.country_name, C.principal_id, C.principal_code, C.principal_name, C.setting_id, user_name,     
  email, pwd_expiry, pwd_expiry_rmd,  login_date, ISNULL(pwd_changed_date, GETDATE()) as pwd_changed_date, A.status, first_login,     
  D.linked_server_ip, D.country_db_name, D.server_username, D.server_pwd, E.user_type_code, B.default_start_date_days, B.default_start_date_days_for_urgent, B.max_num_of_files,    
  F.accessright_id, G.accessright_name, department,wh_code    
  FROM TBL_ADM_USER A WITH(NOLOCK)    
  INNER JOIN TBL_ADM_COUNTRY B WITH(NOLOCK) ON A.country_id = B.country_id     
  INNER JOIN TBL_ADM_PRINCIPAL C WITH(NOLOCK) ON A.principal_id = C.principal_id    
  INNER JOIN TBL_ADM_SETTING D WITH(NOLOCK) ON C.setting_id = D.setting_id    
  LEFT JOIN TBL_ADM_USER_TYPE E WITH(NOLOCK) ON A.user_type_id = E.user_type_id    
  INNER JOIN TBL_ADM_USER_ACCESSRIGHT F WITH(NOLOCK) ON A.user_id = F.user_id    
  INNER JOIN TBL_ADM_ACCESSRIGHT G WITH(NOLOCK) ON F.accessright_id = G.accessright_id    
  WHERE B.status <> 'D' and C.status <> 'D' AND A.status <> 'D'     
  AND A.login = @USERNAME AND A.password = @PASSWORD    
    
 END    
 ELSE     
 BEGIN    
  DECLARE @login_cnt INT, @max_retry INT    
  SET @login_cnt = (SELECT ISNULL(login_cnt,0) FROM TBL_ADM_USER WITH(NOLOCK) WHERE login = @username)    
  SET @max_retry = (SELECT max_retry FROM TBL_ADM_USER WITH(NOLOCK) WHERE login = @username)    
    
  IF @login_cnt > @max_retry    
  BEGIN    
   SELECT 3 as ind    
  END    
  ELSE    
  BEGIN    
   UPDATE TBL_ADM_USER    
   SET login_cnt = @login_cnt + 1    
   WHERE login = @USERNAME    
    
   SELECT 0 AS ind    
  END    
      
 END    
END
GO
