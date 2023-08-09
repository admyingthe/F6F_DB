SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE SPP_MST_MLL_PRD_RELATED_INFO
	@param NVARCHAR(2000)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @prd_code VARCHAR(50)
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))

	SELECT B.mll_no, B.client_code + ' - ' + C.client_name + ' [' + B.sub + ' - ' + D.sub_name + ']' as client, CONVERT(VARCHAR(10), start_date, 121) as start_date, CONVERT(VARCHAR(10), end_date, 121) as end_date, CAST(NULL as CHAR(5)) as gmp,
	json_value(vas_activities, '$[0].radio_val') as radio_val_1, 
	json_value(vas_activities, '$[1].radio_val') as radio_val_2, 
	json_value(vas_activities, '$[2].radio_val') as radio_val_3,
	json_value(vas_activities, '$[3].radio_val') as radio_val_4, 
	json_value(vas_activities, '$[4].radio_val') as radio_val_5, 
	json_value(vas_activities, '$[5].radio_val') as radio_val_6, 
	json_value(vas_activities, '$[6].radio_val') as radio_val_7, 
	json_value(vas_activities, '$[7].radio_val') as radio_val_8, 
	json_value(vas_activities, '$[8].radio_val') as radio_val_9
	INTO #PRDRELATED
	FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
	INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
	INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code
	INNER JOIN TBL_MST_CLIENT_SUB D WITH(NOLOCK) ON B.client_code = D.client_code AND B.sub = D.sub_code
	WHERE prd_code = @prd_code AND mll_status = 'Approved' AND GETDATE() BETWEEN start_date AND end_date

	UPDATE #PRDRELATED
	SET gmp = CASE WHEN (radio_val_1 IN ('Y')
						   OR radio_val_2 IN ('Y')
						   OR radio_val_3 IN ('Y')
						   OR radio_val_4 IN ('Y')
						   OR radio_val_5 IN ('Y')
						   OR radio_val_6 IN ('Y')
						   OR radio_val_7 IN ('Y')
						   OR radio_val_8 IN ('Y')
						   OR radio_val_9 IN ('Y')) THEN 'Yes' ELSE 'No' END

	SELECT * FROM #PRDRELATED

	DROP TABLE #PRDRELATED
END

GO
