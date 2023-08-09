SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_ACTIVITY_LISTING](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[type] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('Additional'),
	[Activity] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [bit] NULL DEFAULT ((1))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
