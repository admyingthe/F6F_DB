SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TXN_WORK_ORDER](
	[work_ord_ref] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[job_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mll_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[inbound_doc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[requirement_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whs_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[picking_area] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[upl_point] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_unit_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dsto_unit_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dsto_section] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dsto_stg_bin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[item_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sloc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[expiry_date] [datetime] NULL,
	[stock_category] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ttl_qty_eaches] [int] NULL,
	[arrival_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[created_date] [datetime] NULL,
	[others] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[barcode_html] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[log_id] [int] NULL,
	[qa_required] [int] NULL,
	[origional_ttl_qty_eaches] [int] NULL,
	[manufacturing_date] [datetime] NULL,
	[special_stock_indicator] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[special_stock] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
