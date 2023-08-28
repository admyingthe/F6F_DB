SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_EVENT_CONFIGURATION_HDR](
	[event_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[event_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[precedence] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[auto_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qty] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[default_qty] [int] NULL,
	[sap_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[req_stock_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[internal_qa_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[confirm_stock_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[show_attachment_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[answer_ques_ind] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_show_after_event] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[post_event_id] [int] NULL,
	[wo_type_id] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_deleted] [bit] NULL DEFAULT ((0))
) ON [PRIMARY]

GO
