SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_EVENT_CONFIGURATION_DTL](
	[post_event_id] [int] NULL,
	[to_display] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
