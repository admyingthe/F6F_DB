/****** Object:  Table [dbo].[TBL_MST_RANDOM_PWD]    Script Date: 08-Aug-23 8:46:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_RANDOM_PWD](
	[rand_pwd] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[encrypt_rand_pwd] [nvarchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[id] [bigint] NULL
) ON [PRIMARY]

GO
