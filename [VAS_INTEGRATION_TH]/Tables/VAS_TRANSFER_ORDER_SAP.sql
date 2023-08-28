SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VAS_TRANSFER_ORDER_SAP](
	[country_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[process_ind] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_order] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whs_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[workorder_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[requirement_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qty] [float] NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plant] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sloc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[movement_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stock_category] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ord_ref_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[created_by] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lastupdate] [datetime] NULL,
	[resendcounter] [int] NULL,
	[order_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[order_sent_date] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_unit_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_section] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ssto_stg_bin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[to_confirm_ind] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qi_type] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[storage_type_destination] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bin_destination] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[expirydate] [datetime] NULL,
	[line_no] [int] NULL,
	[manufacturing_date] [datetime] NULL,
	[special_stock_indicator] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[special_stock] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[confirm_to_indicator] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
