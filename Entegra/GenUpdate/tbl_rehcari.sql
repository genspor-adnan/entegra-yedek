CREATE TABLE [REHCARI] (
	[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL ,
	[SIRANO] [smallint] NOT NULL ,
	[TARIH] [datetime] NULL ,
	[ACIKLAMA] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[HESAPKODU] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[HESAPADI] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[BORC] [money] NULL ,
	[ALACAK] [money] NULL ,
	[DOVIZ] [money] NULL ,
	[KUR] [varchar] (5) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[KASA] [smallint] NULL ,
	[ONAY] [varchar] (1) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[KULLANICI] [varchar] (2) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[BAG] [int] NULL ,
	[VADE] [datetime] NULL ,
	[MASRAFKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[MASRAFAD] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	CONSTRAINT [PK_REHCARI] PRIMARY KEY  NONCLUSTERED 
	(
		[KOD],
		[SIRANO]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO


