SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_AUDIT_TRAIL_DTL](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[audit_trail_id] [int] NOT NULL,
	[ref_table] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ref_id] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ref_column] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[original_value] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[changed_value] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
