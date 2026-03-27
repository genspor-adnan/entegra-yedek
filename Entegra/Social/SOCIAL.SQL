CREATE TABLE [dbo].[SOCIAL_MEDIA] (
  [ID] int  IDENTITY(1,1) NOT NULL,
  [MetaIsletmeKodu] varchar(24) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_IsletmeKodu] varchar(32) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_APPID] varchar(32) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_AppSecret] varchar(48) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_AppClientToken] varchar(48) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_PageID] varchar(48) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_UserAccessToken] varchar(255) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [FB_PageAccessToken] varchar(255) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [InstagramIsletmeKodu] varchar(24) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL,
  [WhatsAppHesapKodu] varchar(255) COLLATE SQL_Latin1_General_CP1254_CI_AS  NULL
)  
ON [PRIMARY]
GO

ALTER TABLE [dbo].[SOCIAL_MEDIA] SET (LOCK_ESCALATION = TABLE)