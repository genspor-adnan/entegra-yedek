CREATE TABLE [REHBER] (
	[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL ,
	[FIRMA] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[ADSOYAD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[CINSIYET] [varchar] (5) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[UNVAN] [varchar] (15) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[GRUP] [varchar] (10) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[ANAFIRMA] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[OZEL] [varchar] (10) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[ISTEL] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[CEP] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[FAX] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[EVTEL] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[EMAIL] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[WEB] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[ADRES] [varchar] (70) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[ILCE] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[IL] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[PK] [varchar] (6) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[EVADRES] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[EVILCE] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[EVIL] [varchar] (20) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[EVPK] [varchar] (6) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[VERGIDAI] [varchar] (15) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[VERGINO] [varchar] (15) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[NOTLAR] [varchar] (255) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[OTOTAHGUN] [smallint] NULL ,
	[OTOTAHMIKTAR] [money] NULL ,
	[OTOTAHDOVTIPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[OTOTAHACIKLAMA] [varchar] (50) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[OTOTAHMASKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL ,
	[UYARIGUN] [smallint] NULL ,
	[TAHAKKUKESLEME] [smallint] NULL ,
	CONSTRAINT [PK_REHBER] PRIMARY KEY  CLUSTERED 
	(
		[KOD]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO


