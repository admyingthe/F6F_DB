SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VAS_TRANSFER_ORDER_BKP](
	[country_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[inbound_doc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[workorder_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[requirement_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whs_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_unit_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dsto_unit_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[picking_area] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[upl_point] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supplier_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supplier_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_date] [datetime] NULL,
	[to_time] [datetime] NULL,
	[item_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sloc] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_desc] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qty] [float] NULL,
	[expiry_date] [datetime] NULL,
	[stock_category] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[created_by] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dsto_section] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dsto_stg_bin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[temp_logger] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[temp_logger_released_date] [datetime] NULL,
	[temp_logger_released_by] [int] NULL,
	[delete_flag] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qi_type] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
