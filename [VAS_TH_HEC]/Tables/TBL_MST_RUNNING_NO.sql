SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MST_RUNNING_NO](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Module] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Running_No_Format] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Last_Running_No] [int] NOT NULL,
	[Start_No] [int] NOT NULL,
	[End_No] [int] NOT NULL,
	[Date_Format] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Prefix] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Is_Daily_Reset] [bit] NOT NULL,
	[Is_Month_Reset] [bit] NOT NULL,
	[Is_Yearly_Reset] [bit] NOT NULL,
	[Created_Date] [datetime] NULL,
	[Modified_Date] [datetime] NULL,
	[Created_By] [int] NULL,
	[Modified_By] [int] NULL
) ON [PRIMARY]

GO
