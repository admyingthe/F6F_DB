SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_VENDOR_VERSION](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[indicator] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vendor_name] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activity] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[effective_date] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[normal_rate] [int] NULL,
	[ot_rate] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
