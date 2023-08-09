SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve Configuration Value
-- Example Query: exec SPP_MST_CHECK_CONFIGURATION @obj=N'{"field":"40","module":"EVENT_IND"}'
-- ===========================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_CHECK_CONFIGURATION]
	@obj nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @field varchar(100), @module varchar(100)
	SET @field = (SELECT JSON_VALUE(@obj, '$.field'))
	SET @module = (SELECT JSON_VALUE(@obj, '$.module'))

	IF @module = 'EVENT_IND'
		SELECT sap_ind, req_stock_ind, email_ind, answer_ques_ind, internal_qa_ind FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE event_id = @field
END

GO
