CREATE TABLE [KASA] (
	[SIRANO] [int] IDENTITY (1, 1) NOT NULL ,
	[TARIH] [datetime] NOT NULL ,
	[CARIKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[CARIAD] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[ACIKLAMA] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[HESAPKODU] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[HESAPADI] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[GIREN] [money] NULL ,
	[CIKAN] [money] NULL ,
	[DOVIZ] [money] NULL ,
	[KASA] [smallint] NULL ,
	[ONAY] [varchar] (1) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[KULLANICI] [varchar] (2) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[MASRAFKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[MASRAFAD] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[VADE] [datetime] NULL ,
	[KUR] [varchar] (6) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[BAG] [int] NULL ,
	CONSTRAINT [PK_KASA] PRIMARY KEY  CLUSTERED 
	(
		[SIRANO]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO


