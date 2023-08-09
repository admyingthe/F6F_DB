SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_JOB_EVENT_EMAIL_LOG](
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[system_running_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[guid] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email_addr] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cc_addr] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[subject] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[body] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sent_by] [int] NULL,
	[sent_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
