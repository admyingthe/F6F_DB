SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_MST_VALIDATE_PRODUCT @param=N'{"client_code":"0091","prd_list":["abcd","asdjalsdj"]}'

--exec SPP_MST_VALIDATE_PRODUCT_SUBCON @param=N'{"parameter":"Validate","subcon_no":"WI005301042200012","client_code":"0053","sub":"01","prd_list":["130000018","130002910","130004610"]}'

--exec SPP_MST_VALIDATE_PRODUCT_SUBCON @param=N'{"parameter":"Upload","subcon_no":"All","client_code":"0053","sub":"01","prd_list":["130000018","130002910","130004610","130004610","130002164","210101837","130002161","210051623","130004610","130000005","130002164","130000004","130002164"]}'

--exec SPP_MST_VALIDATE_PRODUCT_SUBCON @param=N'{"subcon_no":"WI005301042200011","client_code":"0053","sub":"01","prd_list":["130000018","130002910","130004610","130002164","210101837","130002161","210051623","130000005","130000004",""],"parameter":"Validate"}'


--exec SPP_MST_VALIDATE_PRODUCT_SUBCON @param=N'{"subcon_no":"WI005301032200001","client_code":"0053","sub":"01","prd_list":["130002161","210051623","130004610"],"parameter":"Delete"}'


CREATE PROCEDURE [dbo].[SPP_MST_VALIDATE_PRODUCT_SUBCON]
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @subcon_no VARCHAR(50), @client_code VARCHAR(50), @sub VARCHAR(50), @parameter VARCHAR(50)
	SET @subcon_no = (SELECT JSON_VALUE(@param, '$.subcon_no'))
	SET @sub = (SELECT JSON_VALUE(@param, '$.sub'))
	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
	SET @parameter = (SELECT JSON_VALUE(@param, '$.parameter'))
	--SELECT value as prd_code, CAST(0 AS INT) as valid INTO #TEMP_PRD FROM OPENJSON(@param,'$.prd_list')


CREATE TABLE #TEMP_PRD  
 (  
  
  subcon_no VARCHAR(100),  
  prd_code VARCHAR(50),  
  valid Integer 
  
 )  

 INSERT  INTO #TEMP_PRD(subcon_no,prd_code,valid)
 SELECT distinct '', value as prd_code, CAST(0 AS INT) as valid  FROM OPENJSON(@param,'$.prd_list')

	
			CREATE TABLE #TEMP_PRD_Subcon  
			 (  
  
			  subcon_no VARCHAR(100),  
			  prd_code VARCHAR(50),  
			  valid Integer 
			  --,
			  -- status VARCHAR(50),  
				 --result VARCHAR(200)
			 ) 
			 CREATE TABLE #TEMP_SUBCON  
			 (  
				row_num Integer ,
			    subcon_no VARCHAR(100)
			 ) 
			  DECLARE @count_subcon INT = 0

			 If(@subcon_no='All')
				BEGIN
					
						SELECT IDENTITY(INT, 1, 1) AS row_num,subcon_no 
						INTO #TEMP_SUBCON_All
						FROM TBL_MST_SUBCON_HDR  
						WHERE client_code=@client_code AND sub=@sub   AND subcon_status='Active'

						SELECT @count_subcon=COUNT(subcon_no) FROM TBL_MST_SUBCON_HDR  WHERE client_code=@client_code AND sub=@sub   AND subcon_status='Active'

						INSERT INTO #TEMP_SUBCON
						SELECT * FROM #TEMP_SUBCON_All
						DROP TABLE #TEMP_SUBCON_All
				END
				ELSE
				BEGIN
						
						SELECT IDENTITY(INT, 1, 1) AS row_num,subcon_no 
						INTO #TEMP_SUBCON_ONE
						FROM TBL_MST_SUBCON_HDR  
						WHERE subcon_no=@subcon_no

						SET @count_subcon=1

						INSERT INTO #TEMP_SUBCON
						SELECT * FROM #TEMP_SUBCON_ONE
						DROP TABLE #TEMP_SUBCON_ONE
				END

				

				DECLARE @i INT = 1, @sql NVARCHAR(MAX) = ''  , @subcon_no_main VARCHAR(50)
			 
				 WHILE @i <= @count_subcon 
				 BEGIN  
				 SELECT @subcon_no_main =subcon_no FROM #TEMP_SUBCON WHERE row_num=@i

						UPDATE A 
						SET valid = 0
						FROM #TEMP_PRD A 

						UPDATE A
						SET valid = 1
						FROM #TEMP_PRD A 
						INNER JOIN TBL_MST_SUBCON_DTL B
						WITH(NOLOCK) ON A.prd_code = B.prd_code AND B.subcon_no = @subcon_no_main

				
					INSERT INTO #TEMP_PRD_Subcon 
					SELECT @subcon_no_main,prd_code,valid FROM #TEMP_PRD
					
				 SET @i = @i + 1  
				 END  
			
				DECLARE @count_success INTEGER=0,@count_fail INTEGER=0,@count_total INTEGER =0
				SELECT  @count_total =count( Distinct subcon_no) FROM #TEMP_PRD_Subcon
					
				SELECT  @count_success =count( Distinct subcon_no) FROM #TEMP_PRD_Subcon WHERE valid = 1 
						
						
				SELECT  @count_fail =count( Distinct subcon_no) FROM #TEMP_PRD_Subcon WHERE valid = 0 
				AND subcon_no NOT in (SELECT subcon_no  FROM #TEMP_PRD_Subcon WHERE valid = 1)


				if @parameter='Upload'
				BEGIN
					SELECT * FROM #TEMP_PRD_Subcon WHERE valid = 1
								
					--SELECT 'Attachment(s) for '''+ Convert (varchar(10), @count_success) +''' selected Subcon WI No has been uploaded successfully'
				END
				ELSE if @parameter='Delete'
				BEGIN
					SELECT * FROM #TEMP_PRD_Subcon WHERE valid = 0
								
					--SELECT 'Attachment(s) for '''+ Convert (varchar(10), @count_success) +''' selected Subcon WI No has been uploaded successfully'
				END
				ELSE
				BEGIN

						IF @count_total<>@count_success
						BEGIN
							SELECT ''''+ Convert (varchar(10), @count_success) +'''  selected Subcon WI No will upload the attachment(s) successfully.'''+Convert (varchar(10), @count_fail ) +''' selected Subcon WI No do/does not have matching Product Code maintained. Do you wish to proceed to upload for the successful record(s)?' AS 'Message'
						END
						ELSE
						SELECT 'NoData'AS 'Message'
					
				END

	
				DROP TABLE #TEMP_PRD
				DROP TABLE #TEMP_PRD_Subcon
				DROP TABLE #TEMP_SUBCON
END





GO
