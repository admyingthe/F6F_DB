SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_WORK_ORDER_ACTION_LOG](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[job_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[current_running_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[on_hold_date] [datetime] NULL,
	[on_hold_reason] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[on_hold_remarks] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[on_hold_by] [int] NULL,
	[released_date] [datetime] NULL,
	[released_by] [int] NULL
) ON [PRIMARY]

GO
