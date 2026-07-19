if object_id('dbo.FATURA_USER','U') is null
begin
  create table dbo.FATURA_USER(
    ID int not null,
    EKLEYEN int null,
    EKLEMETARIHI datetime null constraint DF_FATURA_USER_EKLEMETARIHI default(getdate()),
    DEGISTIREN int null,
    DEGISTIRMETARIHI datetime null,
    IHRACAT nvarchar(max) null,
    constraint PK_FATURA_USER primary key clustered(ID),
    constraint FK_FATURA_USER_FATURA foreign key(ID) references dbo.FATURA(ID)
  );
end
