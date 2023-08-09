SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_PPM](
	[line_no] [int] NULL,
	[system_running_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[required_qty] [int] NULL,
	[sap_qty] [int] NULL,
	[issued_qty] [int] NULL,
	[remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[manual_ppm] [int] NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[vas_order] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[expirydate] [datetime] NULL,
	[batch_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whs_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ppm_by] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mfg_date] [datetime] NULL,
	[action_from_reopen] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reopened_from_VAS_event_running_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[returned_from_line_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[returned_from_job_ref_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
