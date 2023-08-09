SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_CLIENT](
	[client_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[client_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL
) ON [PRIMARY]

GO
