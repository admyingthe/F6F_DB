SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_CLIENT_SUB](
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sub_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sub_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[wh_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
