SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_VENDOR_LISTING](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[vendor_code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vendor_name] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ship_to_code] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sold_to_code] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prayer_code] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[material_group] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
