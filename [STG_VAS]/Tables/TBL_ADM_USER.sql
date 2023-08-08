/****** Object:  Table [dbo].[TBL_ADM_USER]    Script Date: 08-Aug-23 8:39:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_USER](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[login] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[password] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[country_id] [int] NULL,
	[principal_id] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[user_type_id] [int] NULL,
	[user_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[email] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[first_login] [int] NULL CONSTRAINT [DF_TBL_ADM_USER_first_login]  DEFAULT ((0)),
	[pwd_expiry] [int] NULL,
	[pwd_expiry_rmd] [int] NULL,
	[login_expiry_flag] [int] NULL,
	[max_retry] [int] NULL,
	[login_date] [datetime] NULL,
	[login_cnt] [int] NULL,
	[pwd_changed_date] [datetime] NULL,
	[department] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[creator_user_id] [int] NULL,
	[changed_date] [datetime] NULL,
	[changed_user_id] [int] NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[wh_code] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
