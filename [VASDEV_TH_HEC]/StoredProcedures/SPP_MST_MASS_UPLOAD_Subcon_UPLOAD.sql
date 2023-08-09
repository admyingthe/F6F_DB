SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_MASS_UPLOAD_Subcon_UPLOAD]  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRY  
	  SELECT IDENTITY(INT, 1, 1) AS row_num, CAST(NULL as VARCHAR(50)) as subcon_no,  
	  CAST(NULL as VARCHAR(50)) as last_effective_subcon, CAST(0 as INT) as is_new_subcon, CAST(0 as INT) as qa_required, *   
	  INTO #TEMP_UPLOAD  
	  FROM TBL_TMP_MASS_UPLOAD_Subcon_VALIDATED WITH(NOLOCK)  
	  WHERE user_id = @user_id AND (error_msg = '' OR error_msg IS NULL)  
	  ORDER BY client_code, type_of_vas, sub  




	  SELECT Distinct IDENTITY(INT, 1, 1) AS row_num, cast(null as varchar(50)) as subcon_no, client_code, type_of_vas, sub  ,indicator
	  , CAST(NULL as varchar(50)) as last_effective_subcon,CAST(0 as INT) as is_new_subcon, CAST(1 as INT) as qa_required  
	  INTO #TEMP_Subcon_NO  
	  FROM #TEMP_UPLOAD  


	  --select * From #TEMP_Subcon_NO

	
  
		DECLARE @subcon_no_hdr as VARCHAR(50),  @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50) , 
		@subcon_no_new VARCHAR(50) ,		@last_five_digit_of_subcon_no varchar(5)






  /** Update if exists OR Generate New subcon No for each row **/  
  DECLARE @last_effective_subcon_no VARCHAR(50)  
   
  DECLARE @count_row INT, @i INT = 1, @action CHAR(1)
  SET @count_row = (SELECT COUNT(1) FROM #TEMP_Subcon_NO)  
  WHILE @i <= @count_row  
  BEGIN  
		SELECT @client_code = client_code, @type_of_vas = type_of_vas, @sub = sub FROM #TEMP_Subcon_NO WHERE row_num = @i 
   
		IF @i=1
		BEGIN

			IF (SELECT COUNT(1) FROM TBL_MST_Subcon_HDR WITH(NOLOCK) WHERE  client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub  ) = 0  
			BEGIN 
				DECLARE  @len INT = 5  
				set @subcon_no_hdr = (SELECT 'WI' + @client_code + @sub + Right('0' + cast(month(getdate()) as varchar), 2) + Cast(FORMAT(GETDATE(), 'yy') as varchar) + '00001')
		   END
		   ELSE
		   BEGIN
				SELECT Top 1  @subcon_no_hdr=subcon_no FROM TBL_MST_Subcon_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub ORDER BY created_date desc, subcon_no desc

				print (@subcon_no_hdr)

				SET @last_five_digit_of_subcon_no  = (select RIGHT(@subcon_no_hdr,4))
				set   @last_five_digit_of_subcon_no=@last_five_digit_of_subcon_no+1

				SET    @last_five_digit_of_subcon_no=Case when len(@last_five_digit_of_subcon_no)=1 then Right('0000' + cast(@last_five_digit_of_subcon_no as varchar), 5)ELSE
												Case when len(@last_five_digit_of_subcon_no)=2 then Right('000' + cast(@last_five_digit_of_subcon_no as varchar), 5) ELSE 
												Case when len(@last_five_digit_of_subcon_no)=3 then Right('00' + cast(@last_five_digit_of_subcon_no as varchar), 5) ELSE 
												Case when len(@last_five_digit_of_subcon_no)=4 then Right('0' + cast(@last_five_digit_of_subcon_no as varchar), 5) ELSE 
												@last_five_digit_of_subcon_no
												END END END END 
				SELECT @subcon_no_hdr='WI' + @client_code +  @sub + Right('0' + cast(month(getdate()) as varchar), 2) + Cast(FORMAT(GETDATE(), 'yy') as varchar) +  @last_five_digit_of_subcon_no

		   END

			set @subcon_no_new=@subcon_no_hdr
		END
		ELSE
		BEGIN
			
			SET  @last_five_digit_of_subcon_no  = (select RIGHT(@subcon_no_hdr,4))
			set   @last_five_digit_of_subcon_no=@last_five_digit_of_subcon_no+1

			SET    @last_five_digit_of_subcon_no=Case when len(@last_five_digit_of_subcon_no)=1 then Right('0000' + cast(@last_five_digit_of_subcon_no as varchar), 5)ELSE
											Case when len(@last_five_digit_of_subcon_no)=2 then Right('000' + cast(@last_five_digit_of_subcon_no as varchar), 5) ELSE 
											Case when len(@last_five_digit_of_subcon_no)=3 then Right('00' + cast(@last_five_digit_of_subcon_no as varchar), 5) ELSE 
											Case when len(@last_five_digit_of_subcon_no)=4 then Right('0' + cast(@last_five_digit_of_subcon_no as varchar), 5) ELSE 
											@last_five_digit_of_subcon_no
											END END END END 
			SELECT @subcon_no_new='WI' + @client_code +  @sub + Right('0' + cast(month(getdate()) as varchar), 2) + Cast(FORMAT(GETDATE(), 'yy') as varchar) +  @last_five_digit_of_subcon_no
			
			set @subcon_no_hdr=@subcon_no_new;
		END
  
		UPDATE #TEMP_Subcon_NO  
		SET subcon_no = @subcon_no_new  
		WHERE row_num = @i  
	   
  
   SET @i = @i + 1  
  END  
  
  UPDATE A  
  SET is_new_subcon = 1, qa_required = 1  
  FROM #TEMP_Subcon_NO A  
  WHERE NOT EXISTS(SELECT 1 FROM TBL_MST_Subcon_HDR B WITH(NOLOCK) WHERE A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub )  
    
  --SELECT * FROM #TEMP_Subcon_NO  
  
  UPDATE A  
  SET A.subcon_no = B.subcon_no, A.last_effective_subcon = B.last_effective_subcon, A.is_new_subcon = B.is_new_subcon , A.qa_required = B.qa_required   
  FROM #TEMP_UPLOAD A WITH(NOLOCK)  
  INNER JOIN #TEMP_Subcon_NO B WITH(NOLOCK) ON A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub  AND A.indicator=B.indicator
  /** Generate New Subcon No for each distinct client, type of vas and sub **/  
  
  --select * from #TEMP_UPLOAD --where subcon_no in ('WI032300042200001')
  
  /** Insert into Subcon_HDR and Subcon_DTL **/  
  --DELETE FROM TBL_MST_Subcon_HDR WHERE subcon_no IN (SELECT subcon_no FROM #TEMP_Subcon_NO)  
  --DELETE FROM TBL_MST_Subcon_DTL WHERE subcon_no IN (SELECT subcon_no FROM #TEMP_Subcon_NO)  
  
 

  INSERT INTO TBL_MST_Subcon_HDR  
  (subcon_no, client_code, type_of_vas, sub, subcon_status,  creator_user_id, created_date) --, created_user_dept_code 
  SELECT DISTINCT subcon_no, client_code, type_of_vas, sub, 'Active',  @user_id, GETDATE()--, @dept_code  
  FROM #TEMP_UPLOAD --WHERE subcon_no NOT IN (SELECT subcon_no FROM TBL_MST_Subcon_HDR WITH(NOLOCK))  
  

 

  update	#TEMP_UPLOAD
  set		qa_required = 1
  WHERE		vas_activities_1_radio = 'Y' or 
			vas_activities_2_radio  = 'Y' or 
			vas_activities_3_radio  = 'Y' or 
			vas_activities_4_radio = 'Y' or 
			vas_activities_5_radio = 'Y' or
			vas_activities_6_radio = 'Y' 

  INSERT INTO TBL_MST_Subcon_DTL  
  (subcon_no, prd_code,  registration_no, remarks, vas_activities, qa_required,expiry_date,subcon_status)  
  SELECT DISTINCT subcon_no, prd_code, reg_no, ISNULL(remarks,''), vas_activities, qa_required  ,
  case when LTRIM(RTRIM(expirydate))='' then NULL else expirydate end ,'Active'
  FROM #TEMP_UPLOAD A WITH(NOLOCK)   
  


  INSERT INTO TBL_ADM_AUDIT_TRAIL  
  (module, key_code, action, action_by, action_date)  
  SELECT DISTINCT 'Subcon', subcon_no, 'Mass uploaded', @user_id, GETDATE()  
  FROM #TEMP_UPLOAD  

  /** Insert into Subcon_HDR and Subcon_DTL **/  
  
  DECLARE @ttl_rows INT  
  SET @ttl_rows = (SELECT COUNT(1) FROM #TEMP_UPLOAD)  
                                                                                                              
  DROP TABLE #TEMP_Subcon_NO  
  DROP TABLE #TEMP_UPLOAD  
  
  SELECT @ttl_rows AS ttl_rows  
  
 END TRY  

 BEGIN CATCH  
  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage;   
 END CATCH  
END

GO
