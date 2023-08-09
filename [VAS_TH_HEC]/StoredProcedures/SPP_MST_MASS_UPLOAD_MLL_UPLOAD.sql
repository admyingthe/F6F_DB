SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_MASS_UPLOAD_MLL_UPLOAD]  
 @user_id INT
 --@param nvarchar(max)
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRY  


--Added to get Thailand Time along with date
DECLARE @CurrentDateTime AS DATETIME
SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
--Added to get Thailand Time along with date

--if the user confirms to upload duplicated QAS Number, will need to switch the flag is_duplicated_qas_no to 0
--declare @is_duplicated_qas_no as bit = (SELECT JSON_VALUE(@param, '$.is_duplicated_qas_no'))
--UPDATE TBL_TMP_MASS_UPLOAD_MLL_VALIDATE0D SET is_duplicated_qas_no = 0 WHERE user_id = @user_id

  SELECT IDENTITY(INT, 1, 1) AS row_num, CAST(NULL as VARCHAR(50)) as mll_no,  
  CAST(NULL as VARCHAR(50)) as last_effective_mll, CAST(0 as INT) as is_new_mll, CAST(0 as INT) as qa_required, *   
  INTO #TEMP_UPLOAD  
  FROM TBL_TMP_MASS_UPLOAD_MLL_VALIDATED WITH(NOLOCK)  
  WHERE user_id = @user_id AND (error_msg = '' OR error_msg IS NULL) --and is_duplicated_qas_no = 0
  ORDER BY client_code, type_of_vas, sub  
  
  SELECT DISTINCT IDENTITY(INT, 1, 1) AS row_num, cast(null as varchar(50)) as mll_no, client_code, type_of_vas, sub  
  , CAST(NULL as varchar(50)) as last_effective_mll,CAST(0 as INT) as is_new_mll, CAST(1 as INT) as qa_required  
  , mll_desc, qas_no_valid_code
  INTO #TEMP_MLL_NO  
  FROM #TEMP_UPLOAD  
  
  /** Update if exists OR Generate New MLL No for each row **/  
  DECLARE @last_effective_mll_no VARCHAR(50), @is_duplicated_qas_no varchar(20)
  CREATE TABLE #ASSIGNED_MLL_NO (ASSIGNED_MLL_NO VARCHAR(100), CLIENT_CODE VARCHAR(10), TYPE_OF_VAS VARCHAR(10), SUB VARCHAR(10), QAS_NO VARCHAR(MAX))
   
  DECLARE @count_row INT, @i INT = 1, @action CHAR(1), @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @qas_no nvarchar(max)  
  SET @count_row = (SELECT COUNT(1) FROM #TEMP_MLL_NO)  
  WHILE @i <= @count_row  
  BEGIN  
   SELECT @client_code = client_code, @type_of_vas = type_of_vas, @sub = sub, @qas_no = mll_desc, @is_duplicated_qas_no = qas_no_valid_code FROM #TEMP_MLL_NO WHERE row_num = @i  
   SET @last_effective_mll_no = (SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub AND LTRIM(RTRIM(mll_status)) = 'Approved' ORDER BY mll_no DESC)  
  
   UPDATE #TEMP_MLL_NO  
   SET last_effective_mll = @last_effective_mll_no  
   WHERE row_num = @i  
	
	-- MLL Number auto generate - no need to change the increment logic
	DECLARE @new_mll_no VARCHAR(50) = 1, @len INT = 5  
	SELECT TOP 1 @new_mll_no = CAST(CAST(RIGHT(mll_no, @len) AS INT) + 1 AS VARCHAR(50))  
	FROM (SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub) A ORDER BY CAST(RIGHT(mll_no, @len) AS INT) DESC  
	SET @new_mll_no = ISNULL( (SELECT TOP 1 LEFT(mll_no, 11) + REPLICATE('0', @len - LEN(@new_mll_no)) + @new_mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub), 'MLL' + @client_code + @sub + @type_of_vas + '00001') 
				
	-- if mll number is used
	IF EXISTS (select 1 from #ASSIGNED_MLL_NO where ASSIGNED_MLL_NO = @new_mll_no)
	BEGIN
		set @new_mll_no = left(@new_mll_no, 11) + right('00000' + convert(VARCHAR(5), cast(right(@new_mll_no, 5) as int) + 1), 5)
	END
	INSERT INTO #ASSIGNED_MLL_NO (ASSIGNED_MLL_NO, CLIENT_CODE, TYPE_OF_VAS, SUB, QAS_NO) VALUES (@new_mll_no, @client_code, @type_of_vas, @sub, @qas_no)

	IF (@is_duplicated_qas_no = 'D')
	BEGIN
		-- no draft
		IF (SELECT COUNT(1) FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Draft' AND client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub AND mll_desc = @qas_no) = 0  
		BEGIN
			UPDATE #TEMP_MLL_NO SET mll_no = @new_mll_no WHERE row_num = @i  
		END
		-- with draft
		ELSE 
		BEGIN
			-- update existing draft
			UPDATE A  
			SET mll_no = B.mll_no
			FROM #TEMP_MLL_NO A  
			INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub  
			WHERE B.mll_status = 'Draft'
		END
	END
	ELSE IF (@is_duplicated_qas_no = '')
	BEGIN
		-- if mll number is used (FOR MULITPLE QAS NUMBER UPLOADS IN BULK?)
		--IF EXISTS (select 1 from #ASSIGNED_MLL_NO where ASSIGNED_MLL_NO = @new_mll_no)
		--BEGIN
		--	set @new_mll_no = left(@new_mll_no, 11) + right('00000' + convert(VARCHAR(5), cast(right(@new_mll_no, 5) as int) + 1), 5)
		--END
		-- create new MLL
		UPDATE #TEMP_MLL_NO SET mll_no = @new_mll_no WHERE row_num = @i  
	END
	INSERT INTO #ASSIGNED_MLL_NO (ASSIGNED_MLL_NO, CLIENT_CODE, TYPE_OF_VAS, SUB, QAS_NO) VALUES ((select mll_no from #TEMP_MLL_NO where row_num = @i), @client_code, @type_of_vas, @sub, @qas_no)

	-- Based on QAS Number (End)
  
  -- original

   --IF (SELECT COUNT(1) FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Draft' AND client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub) = 0  
   --BEGIN  
   -- DECLARE @new_mll_no VARCHAR(50) = 1, @len INT = 5  
   -- SELECT TOP 1 @new_mll_no = CAST(CAST(RIGHT(mll_no, @len) AS INT) + 1 AS VARCHAR(50))  
   --          FROM (SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub) A ORDER BY CAST(RIGHT(mll_no, @len) AS INT) DESC  
   -- SET @new_mll_no = ISNULL( (SELECT TOP 1 LEFT(mll_no, 11) + REPLICATE('0', @len - LEN(@new_mll_no)) + @new_mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub), 'MLL' + @client_code + @sub + @type_of_vas + '00001')  
    
   -- UPDATE #TEMP_MLL_NO  
   -- SET mll_no = @new_mll_no  
   -- WHERE row_num = @i  
 

   --END  
   --ELSE  
   --BEGIN  
   -- UPDATE A  
   -- SET mll_no = B.mll_no  
   -- FROM #TEMP_MLL_NO A  
   -- INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub  
   -- WHERE B.mll_status = 'Draft'  
   --END   

   -- original (end)
  
   SET @i = @i + 1  
  END  
  
  UPDATE A  
  SET is_new_mll = 1, qa_required = 1  
  FROM #TEMP_MLL_NO A  
  WHERE NOT EXISTS(SELECT 1 FROM TBL_MST_MLL_HDR B WITH(NOLOCK) WHERE A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub AND A.mll_desc = B.mll_desc AND B.mll_status = 'Approved')  
    
  --SELECT * FROM #TEMP_MLL_NO  
  
  UPDATE A  
  SET A.mll_no = B.mll_no, A.last_effective_mll = B.last_effective_mll, A.is_new_mll = B.is_new_mll
  FROM #TEMP_UPLOAD A WITH(NOLOCK)  
  INNER JOIN #TEMP_MLL_NO B WITH(NOLOCK) ON A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub and A.mll_desc = B.mll_desc
  /** Generate New MLL No for each distinct client, type of vas and sub **/  
  
  UPDATE A  
  SET A.qa_required = B.qa_required  
  FROM #TEMP_UPLOAD A   
  INNER JOIN TBL_MST_MLL_DTL B WITH(NOLOCK) ON A.last_effective_mll = B.mll_no AND A.prd_code = B.prd_code AND A.storage_cond = B.storage_cond AND  A.medical_device_usage = B.medical_device_usage  
                                               AND A.bm_ifu = B.bm_ifu  
              AND A.reg_no = B.registration_no   
  AND ISNULL(A.remarks,'') = ISNULL(B.remarks,'') AND A.vas_activities = B.vas_activities  
  WHERE A.is_new_mll <> 1  
  
  /** Insert into MLL_HDR and MLL_DTL **/  
  DELETE FROM TBL_MST_MLL_HDR WHERE mll_no IN (SELECT mll_no FROM #TEMP_MLL_NO)  
  DELETE FROM TBL_MST_MLL_DTL WHERE mll_no IN (SELECT mll_no FROM #TEMP_MLL_NO)  
  
  --declare @dept_code varchar(10)
  --select @dept_code = department from VAS.dbo.TBL_ADM_USER where user_id = @user_id

  INSERT INTO TBL_MST_MLL_HDR  
  (mll_no, client_code, type_of_vas, sub, mll_desc, mll_status, start_date, end_date, creator_user_id, created_date) --, created_user_dept_code 
  SELECT DISTINCT mll_no, client_code, type_of_vas, sub, mll_desc, 'Draft', start_date, end_date, @user_id, @CurrentDateTime--, @dept_code  
  FROM #TEMP_UPLOAD --WHERE mll_no NOT IN (SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK))  

  --Update TBL_MST_MLL_DTL
  --SET qa_required = 1
  --Where mll_no in (Select mll_no from #TEMP_UPLOAD WHERE vas_activities_1_radio = 'Y' AND vas_activities_2_radio  = 'Y' AND vas_activities_3_radio  = 'Y' AND vas_activities_4_radio = 'Y' AND vas_activities_5_radio = 'Y')

  update	#TEMP_UPLOAD
  set		qa_required = 1
  WHERE		vas_activities_1_radio = 'Y' or 
			vas_activities_2_radio = 'Y' or 
			vas_activities_3_radio = 'Y' or 
			vas_activities_4_radio = 'Y' or 
			vas_activities_5_radio = 'Y' or 
			vas_activities_6_radio = 'Y' or 
			vas_activities_7_radio = 'Y' or 
			vas_activities_8_radio = 'Y' or 
			vas_activities_9_radio = 'Y' or
			vas_activities_10_radio = 'Y' or 
			vas_activities_11_radio = 'Y' or 
			vas_activities_12_radio = 'Y' or 
			vas_activities_13_radio = 'Y'


 update #TEMP_UPLOAD
 set	gmp_required = CASE WHEN Lower(ltrim(rtrim(gmp_required)))='yes' then 1 ELSE 0 END
	


  INSERT INTO TBL_MST_MLL_DTL  
  (mll_no, prd_code, storage_cond,medical_device_usage,bm_ifu, registration_no, remarks, vas_activities, qa_required,ppm_by,gmp_required)  
  SELECT DISTINCT mll_no, prd_code, storage_cond, ISNULL(medical_device_usage,'NA'),ISNULL(bm_ifu,'NA'),reg_no, ISNULL(remarks,''), vas_activities, qa_required ,ppm_by,gmp_required 
  FROM #TEMP_UPLOAD A WITH(NOLOCK)   
  --WHERE NOT EXISTS (SELECT 1 FROM TBL_MST_MLL_DTL B WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR C WITH(NOLOCK) ON B.mll_no = C.mll_no WHERE A.mll_no = B.mll_no AND A.prd_code = B.prd_code AND mll_status = 'Draft')  
  
  INSERT INTO TBL_ADM_AUDIT_TRAIL  
  (module, key_code, action, action_by, action_date)  
  SELECT DISTINCT 'MLL', mll_no, 'Mass uploaded', @user_id, @CurrentDateTime  
  FROM #TEMP_UPLOAD  
  /** Insert into MLL_HDR and MLL_DTL **/  
  
  DECLARE @ttl_rows INT  
  SET @ttl_rows = (SELECT COUNT(1) FROM #TEMP_UPLOAD)  
  
  DROP TABLE #ASSIGNED_MLL_NO
  DROP TABLE #TEMP_MLL_NO  
  DROP TABLE #TEMP_UPLOAD  -- update existing draft
  
  SELECT @ttl_rows AS ttl_rows  
  
 END TRY  
 BEGIN CATCH  
  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage;   
 END CATCH  
END
GO
