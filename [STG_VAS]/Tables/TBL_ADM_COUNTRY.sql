/****** Object:  Table [dbo].[TBL_ADM_COUNTRY]    Script Date: 08-Aug-23 8:46:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_COUNTRY](
	[country_id] [int] IDENTITY(1,1) NOT NULL,
	[country_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[country_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[default_start_date_days] [int] NULL,
	[default_start_date_days_for_urgent] [int] NULL,
	[max_num_of_files] [int] NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [int] NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
