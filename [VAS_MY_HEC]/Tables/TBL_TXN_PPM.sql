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
	[src_prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
