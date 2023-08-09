SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_VAS_ACTIVITIES_CHANGES]  
AS  
BEGIN  
 SET NOCOUNT ON;  

  --Added 10 to 13 for CR -17 
 SELECT A.mll_no, A.prd_code, start_date, end_date,  
 json_value(vas_activities, '$[0].radio_val') as radio_val_1,   
 json_value(vas_activities, '$[1].radio_val') as radio_val_2,   
 json_value(vas_activities, '$[2].radio_val') as radio_val_3,  
 json_value(vas_activities, '$[3].radio_val') as radio_val_4,   
 json_value(vas_activities, '$[4].radio_val') as radio_val_5,   
 json_value(vas_activities, '$[5].radio_val') as radio_val_6,   
 json_value(vas_activities, '$[6].radio_val') as radio_val_7,   
 json_value(vas_activities, '$[7].radio_val') as radio_val_8,   
 json_value(vas_activities, '$[8].radio_val') as radio_val_9,
 json_value(vas_activities, '$[9].radio_val') as radio_val_10,   
 json_value(vas_activities, '$[10].radio_val') as radio_val_11,   
 json_value(vas_activities, '$[11].radio_val') as radio_val_12,       
 json_value(vas_activities, '$[12].radio_val') as radio_val_13, CAST(NULL as VARCHAR(10)) as radio_val  
 INTO #temp_vas_activities  
 FROM TBL_MST_MLL_DTL A WITH(NOLOCK)  
 INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no  
 WHERE A.mll_no IN --('MLL014003RD00001')  
 (SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Approved' AND (process_flag = 0 OR process_flag IS NULL)  
 --AND (CONVERT(VARCHAR(10), approved_date, 121) = CONVERT(VARCHAR(10), GETDATE(), 121) OR GETDATE() BETWEEN start_date AND end_date))  
   and (CONVERT(VARCHAR(10), end_date, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121)))

  --Added 10 to 13 for CR -17 
 UPDATE #temp_vas_activities  
 SET radio_val = CASE WHEN (radio_val_1 IN ('Y','P')  
         OR radio_val_2 IN ('Y','P')  
         OR radio_val_3 IN ('Y','P')  
         OR radio_val_4 IN ('Y','P')  
         OR radio_val_5 IN ('Y','P')  
         OR radio_val_6 IN ('Y','P')  
         OR radio_val_7 IN ('Y','P')  
         OR radio_val_8 IN ('Y','P')  
         OR radio_val_9 IN ('Y','P')
		 OR radio_val_10 IN ('Y','P')      
         OR radio_val_11 IN ('Y','P')      
         OR radio_val_12 IN ('Y','P')      
         OR radio_val_13 IN ('Y','P')) THEN 'Y' ELSE 'N' END  
  
 --SELECT * FROM #temp_vas_activities  
  
 CREATE TABLE #temp_vas   
 (row INT IDENTITY(1,1),   
 mll_no VARCHAR(50),   
 prd_code VARCHAR(50),   
 start_date VARCHAR(10),   
 end_date VARCHAR(10),   
 current_val VARCHAR(10),   
 supercedes_mll_no VARCHAR(50),   
 previous_val VARCHAR(10),  
 existing_in_tmp_ind VARCHAR(10))  
  
 INSERT INTO #temp_vas(mll_no, prd_code, start_date, end_date, current_val, existing_in_tmp_ind)  
 SELECT mll_no, prd_code, CONVERT(VARCHAR(10), start_date, 121), CONVERT(VARCHAR(10), end_date, 121), radio_val, 'N' FROM #temp_vas_activities  
  
 DROP TABLE #temp_vas_activities  
  
 -- Update supercedes MLL no --  
 SELECT DISTINCT IDENTITY (INT, 1, 1) AS row_num, mll_no, CAST(NULL as VARCHAR(50)) as supercedes_mll_no INTO #GET_SUPERCEDES_MLL FROM #temp_vas  
  
 DECLARE @i INT = 1, @selected_mll_no VARCHAR(50), @supercedes_mll_no VARCHAR(50)  
 WHILE @i <= (SELECT COUNT(1) FROM #GET_SUPERCEDES_MLL)  
 BEGIN  
  SET @selected_mll_no = (SELECT mll_no FROM #GET_SUPERCEDES_MLL WHERE row_num = @i)  
  SET @supercedes_mll_no = ISNULL((SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = ( SELECT substring(@selected_mll_no, 4, 4) ) AND type_of_vas = 'RD' AND sub = (select substring(@selected_mll_no, 8, 2)) AND mll_no < @selected_mll_no AND mll_status = 'Approved' ORDER BY mll_no DESC),'')  
  
  UPDATE #GET_SUPERCEDES_MLL  
  SET supercedes_mll_no = @supercedes_mll_no  
  WHERE row_num = @i  
  SET @i = @i + 1  
 END  
  
 UPDATE A  
 SET supercedes_mll_no = B.supercedes_mll_no  
 FROM #temp_vas A  
 INNER JOIN #GET_SUPERCEDES_MLL B ON A.mll_no = B.mll_no  
 -- Update supercedes MLL no --  
  
 UPDATE A  
 SET previous_val = 'N'  
 FROM #temp_vas A  
 WHERE current_val = 'Y'  
  
 -- Find if exist in TBL_TMP_MLL_VAS_ACTIVITIES --  
 UPDATE A  
 SET existing_in_tmp_ind = 'Y'  
 FROM #temp_vas A  
 WHERE EXISTS (SELECT 1 FROM TBL_TMP_MLL_VAS_ACTIVITIES B WHERE A.supercedes_mll_no = B.mll_no AND A.prd_code = B.prd_code)  
 -- Find if exist in TBL_TMP_MLL_VAS_ACTIVITIES --  
  
 -- Y -> Y   
 SELECT DISTINCT A.mll_no, A.prd_code, CONVERT(VARCHAR(10), A.start_date, 121) as start_date, CONVERT(VARCHAR(10), A.end_date, 121) as end_date, A.current_val INTO #TO_UPDATE_END_DATE_1  
 FROM TBL_TMP_MLL_VAS_ACTIVITIES A  
 INNER JOIN #temp_vas B ON A.mll_no = B.supercedes_mll_no AND A.prd_code = B.prd_code  
 WHERE B.current_val = 'Y' AND B.existing_in_tmp_ind = 'Y'  
  
 UPDATE A  
 SET end_date = CONVERT(VARCHAR(10), B.end_date, 121)  
 FROM #TO_UPDATE_END_DATE_1 A  
 INNER JOIN TBL_MST_MLL_HDR B ON A.mll_no = B.mll_no  
 -- Y -> Y   
  
 -- Y-> N  
 SELECT DISTINCT A.mll_no, B.prd_code, CONVERT(VARCHAR(10), A.start_date, 121) as start_date, CONVERT(VARCHAR(10), A.end_date, 121) as end_date, B.current_val INTO #TO_UPDATE_END_DATE_2  
 FROM TBL_MST_MLL_HDR A  
 INNER JOIN #temp_vas B ON A.mll_no = B.supercedes_mll_no  
 WHERE B.current_val = 'N' AND B.existing_in_tmp_ind = 'Y'  
 -- Y-> N  
  
 INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_CONDITIONS  
 (prd_code, start_date, end_date, previous_val, current_val, created_date, process_ind,country)  
 SELECT prd_code, start_date, end_date, previous_val, current_val, GETDATE(), 0,'TH' FROM #temp_vas WHERE current_val = 'Y' -- N -> Y  
 UNION ALL  
 SELECT prd_code, start_date, end_date, 'Y', current_val, GETDATE(), 0,'TH' FROM #TO_UPDATE_END_DATE_1 -- Y -> Y  
 UNION ALL  
 SELECT prd_code, start_date, end_date, 'Y', current_val, GETDATE(), 0,'TH' FROM #TO_UPDATE_END_DATE_2 -- Y -> N  
  
 INSERT INTO TBL_TMP_MLL_VAS_ACTIVITIES  
 SELECT mll_no, prd_code, start_date, end_date, current_val, GETDATE() FROM #temp_vas WHERE current_val = 'Y'  
  
 UPDATE TBL_MST_MLL_HDR  
 SET process_flag = 1  
 WHERE mll_no IN (SELECT mll_no FROM #GET_SUPERCEDES_MLL)  
  
 DELETE FROM TBL_TMP_MLL_VAS_ACTIVITIES WHERE mll_no IN (SELECT supercedes_mll_no FROM #GET_SUPERCEDES_MLL)  
  
 DROP TABLE #temp_vas  
 DROP TABLE #TO_UPDATE_END_DATE_1  
 DROP TABLE #TO_UPDATE_END_DATE_2  
  

END
GO
