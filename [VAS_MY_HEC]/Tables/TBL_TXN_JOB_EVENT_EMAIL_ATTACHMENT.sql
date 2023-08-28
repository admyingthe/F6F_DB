SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT](
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[system_running_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[guid] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uploaded_by] [int] NULL,
	[uploaded_date] [datetime] NULL,
	[file_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_data] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_extension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
