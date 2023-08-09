SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_RUNNING_NO_BAK](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Module] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Digit_No] [int] NOT NULL,
	[Last_Running_No] [int] NOT NULL,
	[Start_No] [int] NOT NULL,
	[End_No] [int] NOT NULL,
	[Masking] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Prefix] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Created_Date] [datetime] NULL,
	[Modified_Date] [datetime] NULL,
	[Created_By] [int] NULL,
	[Modified_By] [int] NULL
) ON [PRIMARY]

GO
