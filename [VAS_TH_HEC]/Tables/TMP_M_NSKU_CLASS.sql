SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMP_M_NSKU_CLASS](
	[Prdcode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[internalCharacteristic] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CharacteristicCounter] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Indicator] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClassType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InternalCounter] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CharacteristicValue] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
