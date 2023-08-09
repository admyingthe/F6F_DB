SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_SUBCON_HDR](
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type_of_vas] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sub] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[subcon_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[subcon_desc] [nvarchar](2500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[subcon_status] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[rejected_date] [datetime] NULL,
	[subcon_change_remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sent_email_flag] [int] NULL,
	[process_flag] [int] NULL,
	[subcon_urgent] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
