SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_TMP_MASS_UPLOAD_MLL](
	[client_code] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[type_of_vas] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sub] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[validity_period] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prd_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[storage_cond] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reg_no] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_1] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_1_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_2] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_2_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_3] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_3_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_4] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_4_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_5] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_5_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_6] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_6_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_7] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_7_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_8] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_8_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_9] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_9_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_10] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_10_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_11] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_11_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_12] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_12_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_13] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vas_activities_13_radio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mll_desc] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[user_id] [int] NULL,
	[medical_device_usage] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bm_ifu] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ppm_by] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gmp_required] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
