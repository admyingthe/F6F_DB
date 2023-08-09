SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xx_tbl_mst_mll_dtl](
	[mll_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[storage_cond] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[registration_no] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
