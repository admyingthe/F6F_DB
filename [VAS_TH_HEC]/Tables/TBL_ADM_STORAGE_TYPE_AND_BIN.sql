SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN](
	[warehouse_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[storage_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bin_no] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('Active'),
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
