SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Ying
-- Create date: 2023-04-18
-- Description: Create Group Work Order - Check VAS Activity (TH Requirements)
-- Example Query: exec SPP_MST_ASSIGNMENT_VAS_ACTIVITY_CHECK @mll_no_list=N'MLL020701RD00010,MLL016101RD00003',@prd_code_list=N'100277784,101122175'
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_MST_ASSIGNMENT_VAS_ACTIVITY_CHECK]
	@mll_no_list NVARCHAR(MAX),
	@prd_code_list NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @start_time DATETIME, @end_time DATETIME, @distinct_vas_activity_count int
	SET @start_time = GETDATE()
	--DECLARE @mll_no_list NVARCHAR(MAX) = N'MLL020701RD00010,MLL016101RD00003', @prd_code_list NVARCHAR(MAX) = N'100277784,101122175'

	SELECT * INTO #MLL_NO FROM SF_SPLIT(@mll_no_list, ',','''')
	SELECT * INTO #PRD_CODE FROM SF_SPLIT(@prd_code_list, ',','''')

	SELECT DISTINCT IDENTITY(INT,1,1) as row_num, A.ID, A.DATA AS mll_no, B.DATA AS prd_code, C.vas_activities
	INTO #TEMP_ASSIGNMENT_LIST
	FROM #MLL_NO A 
	INNER JOIN #PRD_CODE B ON A.ID = B.ID
	LEFT JOIN TBL_MST_MLL_DTL C ON A.Data = C.mll_no AND B.Data = C.prd_code

	SELECT mll_no, prd_code,
	json_value(vas_activities, '$[0].radio_val') as vas_act_1, json_value(vas_activities, '$[0].prd_code') as ppm_code_1,
	json_value(vas_activities, '$[1].radio_val') as vas_act_2, json_value(vas_activities, '$[1].prd_code') as ppm_code_2,
	json_value(vas_activities, '$[2].radio_val') as vas_act_3, json_value(vas_activities, '$[2].prd_code') as ppm_code_3,
	json_value(vas_activities, '$[3].radio_val') as vas_act_4, json_value(vas_activities, '$[3].prd_code') as ppm_code_4,
	json_value(vas_activities, '$[4].radio_val') as vas_act_5, json_value(vas_activities, '$[4].prd_code') as ppm_code_5,
	json_value(vas_activities, '$[5].radio_val') as vas_act_6, json_value(vas_activities, '$[5].prd_code') as ppm_code_6,
	json_value(vas_activities, '$[6].radio_val') as vas_act_7, json_value(vas_activities, '$[6].prd_code') as ppm_code_7,
	json_value(vas_activities, '$[7].radio_val') as vas_act_8, json_value(vas_activities, '$[7].prd_code') as ppm_code_8,
	json_value(vas_activities, '$[8].radio_val') as vas_act_9, json_value(vas_activities, '$[8].prd_code') as ppm_code_9,
	json_value(vas_activities, '$[9].radio_val') as vas_act_10, json_value(vas_activities, '$[9].prd_code') as ppm_code_10,
	json_value(vas_activities, '$[10].radio_val') as vas_act_11, json_value(vas_activities, '$[10].prd_code') as ppm_code_11,
	json_value(vas_activities, '$[11].radio_val') as vas_act_12, json_value(vas_activities, '$[11].prd_code') as ppm_code_12,
	json_value(vas_activities, '$[12].radio_val') as vas_act_13, json_value(vas_activities, '$[12].prd_code') as ppm_code_13
	INTO #TEMP_ASSIGNMENT_LIST_VAS_ACTIVITY
	FROM #TEMP_ASSIGNMENT_LIST

	--SELECT * FROM #TEMP_ASSIGNMENT_LIST_VAS_ACTIVITY

	-- UNPIVOT

	select * into #unpvt from (
	SELECT prd_code, VAS_activity_info, value  
	FROM   
	   (SELECT vas_act_1, ppm_code_1, vas_act_2, ppm_code_2, vas_act_3, ppm_code_3, vas_act_4, ppm_code_4, vas_act_5, ppm_code_5, vas_act_6, ppm_code_6, vas_act_7, ppm_code_7, vas_act_8, ppm_code_8, vas_act_9, ppm_code_9, vas_act_10, ppm_code_10, vas_act_11, ppm_code_11, vas_act_12, ppm_code_12, vas_act_13, ppm_code_13, prd_code
	   FROM #TEMP_ASSIGNMENT_LIST_VAS_ACTIVITY) p  
	UNPIVOT  
	   (value FOR VAS_activity_info IN   
		  (vas_act_1, ppm_code_1, vas_act_2, ppm_code_2, vas_act_3, ppm_code_3, vas_act_4, ppm_code_4, vas_act_5, ppm_code_5, vas_act_6, ppm_code_6, vas_act_7, ppm_code_7, vas_act_8, ppm_code_8, vas_act_9, ppm_code_9, vas_act_10, ppm_code_10, vas_act_11, ppm_code_11, vas_act_12, ppm_code_12, vas_act_13, ppm_code_13)  
	)AS unpvt
	) u
	--select * from #unpvt

	set @distinct_vas_activity_count = (select count(1) from (select VAS_activity_info from #unpvt group by VAS_activity_info having count(distinct value) > 1) t)

	-- UNPIVOT ENDS
	
	-- PIVOT

	--DECLARE @cols AS NVARCHAR(MAX), @query AS NVARCHAR(MAX)

	--select @cols = STUFF((SELECT ',' + QUOTENAME(prd_code) 
	--					from #TEMP_ASSIGNMENT_LIST_VAS_ACTIVITY
	--					group by prd_code, mll_no
	--					order by mll_no
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'NVARCHAR(MAX)') 
	--		,1,1,'')

	--set @query = N'select * into ##pvt from (
	--			SELECT ' + @cols + N' from 
	--			 (
	--				select prd_code, value, ''prd_code_'' + CAST(ROW_NUMBER() OVER (PARTITION BY prd_code ORDER BY (SELECT NULL)) AS VARCHAR(10)) AS col_name
	--				from #unpvt
	--			) x
	--			pivot 
	--			(
	--				max(value)
	--				for prd_code in (' + @cols + N')
	--			)AS #pvt
	--			) p '

	--exec sp_executesql @query;
	--select * from ##pvt

	-- PIVOT ENDS

	if (@distinct_vas_activity_count > 0)
	begin
		select 1 as invalid
	end
	else
	begin
		select 0 as invalid
	end

	DROP TABLE #MLL_NO
	DROP TABLE #PRD_CODE
	DROP TABLE #TEMP_ASSIGNMENT_LIST
	DROP TABLE #TEMP_ASSIGNMENT_LIST_VAS_ACTIVITY
	DROP TABLE #unpvt
	--DROP TABLE ##pvt

	SET @end_time = GETDATE()
	--SELECT DATEDIFF(millisecond, @start_time, @end_time) AS elapsed_ms
END


GO
