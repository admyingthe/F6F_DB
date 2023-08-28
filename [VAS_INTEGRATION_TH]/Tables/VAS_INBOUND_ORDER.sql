SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VAS_INBOUND_ORDER](
	[country_code] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[inbound_doc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order_date] [datetime] NULL,
	[whs_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supplier_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supplier_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[item_no] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_desc] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qty] [float] NULL,
	[expiry_date] [datetime] NULL,
	[stock_category] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[created_by] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[delete_flag] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qi_type] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[workorder_no] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[manufacturing_date] [datetime] NULL
) ON [PRIMARY]

GO
