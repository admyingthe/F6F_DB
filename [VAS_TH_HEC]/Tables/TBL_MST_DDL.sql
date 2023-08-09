SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_DDL](
	[ddl_code] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[delete_flag] [int] NULL
) ON [PRIMARY]

GO
