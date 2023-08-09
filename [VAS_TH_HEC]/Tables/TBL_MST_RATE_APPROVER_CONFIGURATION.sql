SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_RATE_APPROVER_CONFIGURATION](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recipients] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[copy_recipients] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
