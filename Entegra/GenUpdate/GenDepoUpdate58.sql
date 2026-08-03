CREATE OR ALTER procedure [dbo].[sp_prg_Servis_Yeni](
    @RehberID int,
    @SubeID int,
    @Ekleyen int,
    @Konusu nvarchar(100),
    @Tarih datetime,
    @Notlar nvarchar(200)='',
    @Yeri int=0,
    @Yer_ID int=0
)
AS
begin
    SET NOCOUNT ON;

    declare @Kocanno nvarchar(20), @ServisSeri nvarchar(20), @Servisno bigint, @BaslDurumu int, @ServisID int, @SubeYazi nvarchar(2)

    select @Kocanno=KOCANNO,@ServisSeri=SERINO from KOCANAYARLARI where TUR=83 and SUBEID=@SubeID

    declare @BelgeSonuc Table (KOCANNO int, BELGESERI nvarchar(5), BELGENO nvarchar(20))
    INSERT INTO @BelgeSonuc exec [dbo].[sp_BelgeNoGetir] 83, @SubeID, 0

    select @Kocanno=KOCANNO, @ServisSeri=BELGESERI, @Servisno=BELGENO
    from @BelgeSonuc

    select @BaslDurumu = min(DEGER) from GENINI where BOLUM=-3007
    if len(abs(@SubeID))=2
        set @SubeYazi = convert(varchar(2),abs(@SubeID))
    if len(abs(@SubeID))=1
        set @SubeYazi = '0'+convert(varchar(1),abs(@SubeID))

    insert into SERVIS(BASLAMATARIHI,REHBERID,KOCANNO,SERVISSERI,SERVISNO,KONUSU,DURUM,SUBEID,EKLEYEN,KAPSAM,TARIH,ACKAPA,YERI,YERID,ACIL,ONEMLI,DISSERVIS,DEMIRBAS,FIYAT_LISTESI,DEPO,NOTLAR)
    values(@Tarih,@RehberID,@Kocanno,@ServisSeri,@Servisno,@Konusu,@BaslDurumu,@SubeID,@Ekleyen,1,@Tarih,0,@Yeri,@Yer_ID,0,0,0,0,
        isnull((select top 1 DEGER from GENINI where convert(varchar(20),BOLUM)='-77'+@SubeYazi+'05'),0),
        isnull((select top 1 DEGER from GENINI where BOLUM=-1006),0), @Notlar
    )

    set @ServisID = convert(int, scope_identity())

    insert into SERVISHAREKET(SERVISID,BASLAMA,PERSONEL,DURUM,ACILIS,KAPANIS,EKLEYEN)
    values(@ServisID,@Tarih,@Ekleyen,@BaslDurumu,1,0,@Ekleyen)

    select @ServisID
end
GO

