SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_QI_TYPE](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[qi_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qi_desc] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
