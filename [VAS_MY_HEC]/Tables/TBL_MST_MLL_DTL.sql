SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_MLL_DTL](
	[mll_no] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[storage_cond] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[registration_no] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qa_required] [int] NULL CONSTRAINT [DF_TBL_MST_MLL_DTL_qa_required]  DEFAULT ((1)),
	[medical_device_usage] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bm_ifu] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
