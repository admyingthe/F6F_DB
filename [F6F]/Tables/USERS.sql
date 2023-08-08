/****** Object:  Table [dbo].[USERS]    Script Date: 08-Aug-23 8:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USERS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Email] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CakeModeActivated] [bit] NOT NULL
) ON [PRIMARY]

GO
