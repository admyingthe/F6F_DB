SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[X_MLL_HDR](
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[type_of_vas] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sub] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mll_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mll_desc] [nvarchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mll_status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[digital_signature] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[creator_user_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL CONSTRAINT [DF_X_MLL_HDR_created_date]  DEFAULT (getdate()),
	[submitted_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[submitted_date] [datetime] NULL,
	[approved_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[approved_date] [datetime] NULL
) ON [PRIMARY]

GO
