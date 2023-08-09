SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_USER_ACCESSRIGHT](
	[user_id] [int] NOT NULL,
	[accessright_id] [int] NOT NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [numeric](18, 0) NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [numeric](18, 0) NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
