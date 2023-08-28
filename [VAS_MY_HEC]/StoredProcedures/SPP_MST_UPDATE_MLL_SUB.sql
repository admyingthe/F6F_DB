SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Update MLL Sub
-- Example Query: exec SPP_MST_UPDATE_MLL_SUB @client_code_list=N'0091,0091',@sub_code_list=N'00,01',@sub_name_list=N'Default,Sub 01'
-- ===========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_UPDATE_MLL_SUB]
	@client_code_list nvarchar(max),
	@sub_code_list nvarchar(max),
	@sub_name_list nvarchar(max),
	@wh_code_list nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT * INTO #CLIENTCODE FROM SF_SPLIT(@client_code_list, ',','''')
	SELECT * INTO #SUBCODE FROM SF_SPLIT(@sub_code_list, ',','''')
	SELECT * INTO #SUBNAME FROM SF_SPLIT(@sub_name_list, ',','''')
	SELECT * INTO #WH_CODE FROM SF_SPLIT(@wh_code_list, ',','''')

	DECLARE @client_code varchar(50)
	SET @client_code = (SELECT TOP 1 Data FROM #CLIENTCODE)

	DELETE FROM TBL_MST_CLIENT_SUB WHERE client_code = @client_code

	INSERT INTO TBL_MST_CLIENT_SUB
	(client_code, sub_code, sub_name,wh_code)
	SELECT @client_code, T1.Data, T2.Data, T3.Data
	FROM #SUBCODE T1
	LEFT JOIN #SUBNAME T2 ON T1.Id = T2.Id
	LEFT JOIN #WH_CODE T3 ON T1.Id = T3.Id

	DROP TABLE #CLIENTCODE
	DROP TABLE #SUBCODE
	DROP TABLE #SUBNAME
	DROP TABLE #WH_CODE
END

GO
