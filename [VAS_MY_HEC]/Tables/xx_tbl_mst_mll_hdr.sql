SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xx_tbl_mst_mll_hdr](
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type_of_vas] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sub] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mll_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mll_desc] [nvarchar](2500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mll_status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[client_ref_no] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[revision_no] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rejection_reason] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[digital_signature] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[creator_user_id] [int] NULL,
	[created_date] [datetime] NULL,
	[submitted_by] [int] NULL,
	[submitted_date] [datetime] NULL,
	[approved_by] [int] NULL,
	[approved_date] [datetime] NULL,
	[rejected_by] [int] NULL,
	[rejected_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
