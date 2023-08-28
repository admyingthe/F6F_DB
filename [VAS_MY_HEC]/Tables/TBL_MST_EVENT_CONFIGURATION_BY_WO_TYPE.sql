SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_EVENT_CONFIGURATION_BY_WO_TYPE](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WO_type_ID] [int] NULL,
	[event_ID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[event_display_name] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[precedence] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_deleted] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
