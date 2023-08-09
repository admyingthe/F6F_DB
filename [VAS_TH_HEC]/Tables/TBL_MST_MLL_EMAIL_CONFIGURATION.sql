SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_MLL_EMAIL_CONFIGURATION](
	[dept_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recipients] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[copy_recipients] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
