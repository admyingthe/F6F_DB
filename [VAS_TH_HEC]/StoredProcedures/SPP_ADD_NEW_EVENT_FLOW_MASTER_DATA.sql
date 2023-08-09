SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADD_NEW_EVENT_FLOW_MASTER_DATA]
	@event_id NVARCHAR(50),
	@event_name NVARCHAR(150),
	@precedence NVARCHAR(50)
AS
BEGIN
	INSERT INTO [dbo].[TBL_MST_EVENT_CONFIGURATION_HDR]
           ([event_id]
           ,[event_name]
		   ,[precedence])
    VALUES
           (@event_id, @event_name, @precedence)
END
GO
