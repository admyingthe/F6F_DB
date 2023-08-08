/****** Object:  Table [dbo].[TBL_ADM_SUBMODULE]    Script Date: 08-Aug-23 8:25:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_SUBMODULE](
	[submodule_id] [int] IDENTITY(1,1) NOT NULL,
	[submodule_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[parent_submodule_id] [int] NULL,
	[url] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[icon] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[module_id] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [int] NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[seq] [int] NULL
) ON [PRIMARY]

GO
