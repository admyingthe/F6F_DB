SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[XX_M_Product_Q00](
	[PrdCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[O_PrdCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName2] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrinCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Division] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DistChannel] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdHier] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OldMaterialCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BaseUOM] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrdType] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdGrp1] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdGrp2] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdGrp3] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdGrp4] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdGrp5] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UWT] [float] NULL,
	[UWTMeasure] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Car_Unit_Wt] [float] NULL,
	[FoodCat] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VOL] [float] NULL,
	[VOLMeasure] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BasicMat] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ABCInd] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CDate] [datetime] NULL,
	[PrdPrcGrp] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesOrg] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalesUOM] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Country] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IndStdDesc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UPN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Taxcode] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Taxrate] [int] NULL,
	[Temp] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TempDesc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
