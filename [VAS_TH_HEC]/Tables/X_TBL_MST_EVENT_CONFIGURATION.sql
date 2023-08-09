SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[X_TBL_MST_EVENT_CONFIGURATION](
	[event_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[event_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[precedence] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qty] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sap_ind] [int] NULL,
	[req_stock_ind] [int] NULL,
	[email_ind] [int] NULL,
	[confirm_stock_ind] [int] NULL,
	[show_attachment_ind] [int] NULL
) ON [PRIMARY]

GO
