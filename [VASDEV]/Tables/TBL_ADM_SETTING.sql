SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_ADM_SETTING](
	[setting_id] [int] IDENTITY(1,1) NOT NULL,
	[linked_server_ip] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[linked_server_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[country_db_name] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[server_username] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[server_pwd] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_date] [datetime] NULL,
	[changed_date] [datetime] NULL,
	[status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email_country_hdr] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
