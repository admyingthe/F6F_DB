SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_SAVE_EVENT_TO_MASTER_TABLE]
@event_id NVARCHAR(50),
@event_name NVARCHAR(250),
@precedence NVARCHAR(50)
AS
BEGIN
	INSERT INTO [dbo].[TBL_EVENT_FLOW_MASTER_DATA]
		([event_id], [event_name], [precedence])
	VALUES (@event_id, @event_name, @precedence)
END
GO
