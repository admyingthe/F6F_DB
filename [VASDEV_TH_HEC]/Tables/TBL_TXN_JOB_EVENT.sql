SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_JOB_EVENT](
	[running_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[event_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[issued_qty] [int] NULL,
	[completed_qty] [int] NULL,
	[damaged_qty] [int] NULL,
	[remarks] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[parent_running_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[email_sent_count] [int] NULL,
	[on_hold_time] [int] NULL,
	[station_no] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[storage_type] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bin_no] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[currently_reopened_PPM] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
