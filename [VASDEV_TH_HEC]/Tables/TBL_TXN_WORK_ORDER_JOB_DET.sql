SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_WORK_ORDER_JOB_DET](
	[work_ord_ref] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[work_ord_status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[urgent] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[commencement_date] [datetime] NULL,
	[completion_date] [datetime] NULL,
	[qty_of_goods] [int] NULL,
	[num_of_days_to_complete] [int] NULL,
	[barcode_html] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[current_event] [int] NULL,
	[log_id] [int] NULL,
	[cancellation_reason] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ques_a] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ques_b] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ques_c] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ques_d] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[changed_user_id] [int] NULL,
	[changed_date] [datetime] NULL,
	[before_deduct_on_hold] [int] NULL,
	[qi_type] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
