SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_PRODUCT](
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_desc] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[princode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[old_mat_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[base_uom] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tax_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tax_rate] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prdgrp4] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reg_no] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[temp] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updated_date] [datetime] NULL,
	[type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBL_MST_PRODUCT_type]  DEFAULT (N'SAP')
) ON [PRIMARY]

GO
