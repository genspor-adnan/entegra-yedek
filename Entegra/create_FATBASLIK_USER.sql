if object_id('dbo.FATBASLIK_USER','U') is null
begin
  create table dbo.FATBASLIK_USER(
    ID int not null,
    SEVKBILGISI nvarchar(max) null,
    EKLEYEN int null,
    EKLEMETARIHI datetime null constraint DF_FATBASLIK_USER_EKLEMETARIHI default(getdate()),
    DEGISTIREN int null,
    DEGISTIRMETARIHI datetime null,
    constraint PK_FATBASLIK_USER primary key clustered(ID),
    constraint FK_FATBASLIK_USER_FATBASLIK foreign key(ID) references dbo.FATBASLIK(ID)
  );
end
