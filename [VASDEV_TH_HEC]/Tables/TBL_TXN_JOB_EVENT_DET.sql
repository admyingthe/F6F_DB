SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_JOB_EVENT_DET](
	[running_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[inbound_doc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[station_no] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sloc] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whs_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stock_category] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_unit_no] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_stg_bin] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[storage_type_destination] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bin_destination] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[special_stock_indicator] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[special_stock] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
