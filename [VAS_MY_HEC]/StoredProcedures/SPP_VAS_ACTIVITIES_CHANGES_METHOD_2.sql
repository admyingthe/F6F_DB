SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_VAS_ACTIVITIES_CHANGES_METHOD_2]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT A.mll_no, A.prd_code, start_date, end_date,
	json_value(vas_activities, '$[0].radio_val') as radio_val_1, 
	json_value(vas_activities, '$[1].radio_val') as radio_val_2, 
	json_value(vas_activities, '$[2].radio_val') as radio_val_3,
	json_value(vas_activities, '$[3].radio_val') as radio_val_4, 
	json_value(vas_activities, '$[4].radio_val') as radio_val_5, 
	json_value(vas_activities, '$[5].radio_val') as radio_val_6, 
	json_value(vas_activities, '$[6].radio_val') as radio_val_7, 
	json_value(vas_activities, '$[7].radio_val') as radio_val_8, 
	json_value(vas_activities, '$[8].radio_val') as radio_val_9, CAST(NULL as VARCHAR(10)) as radio_val
	INTO #temp_vas_activities
	FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
	INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
	WHERE A.mll_no IN 
	(SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Approved'
	AND CONVERT(VARCHAR(10), GETDATE(), 121) BETWEEN CONVERT(VARCHAR(10), start_date, 121) AND CONVERT(VARCHAR(10), end_date, 121))
	AND prd_code IN (
	'100004625'
	)
	ORDER BY prd_code, mll_no

	UPDATE #temp_vas_activities
	SET radio_val = CASE WHEN (radio_val_1 IN ('Y')
						   OR radio_val_2 IN ('Y')
						   OR radio_val_3 IN ('Y')
						   OR radio_val_4 IN ('Y')
						   OR radio_val_5 IN ('Y')
						   OR radio_val_6 IN ('Y')
						   OR radio_val_7 IN ('Y')
						   OR radio_val_8 IN ('Y')
						   OR radio_val_9 IN ('Y')) THEN 'Y' ELSE 'N' END

	--SELECT * FROM #temp_vas_activities

	INSERT INTO VAS_INTEGRATION.dbo.VAS_CONDITIONS
	(prd_code, start_date, end_date, previous_val, current_val, created_date, process_ind)
	SELECT prd_code, CONVERT(VARCHAR(10), start_date, 121), CONVERT(VARCHAR(10), end_date, 121), 'N', 'Y', GETDATE(), 0 FROM #temp_vas_activities

	DROP TABLE #temp_vas_activities
END
GO
