CREATE OR ALTER TRIGGER [dbo].[TG_ServisDuyuruOlustur] on [dbo].[SERVISHAREKET] after INSERT,DELETE,UPDATE
as
BEGIN
    SET NOCOUNT ON;

	declare @InsertVar bit, @DeleteVar bit
	if exists(select 1 from Deleted) set @DeleteVar=1 else set @DeleteVar=0
	if exists(select 1 from Inserted) set @InsertVar=1 else set @InsertVar=0

	declare @CurID int, @CurSERVISID int, @CurREHBERID int, @CurEKLEYEN int
	declare @DuyuruID int, @CurKONUSU nvarchar(100), @CurBASLAMA datetime

	if @InsertVar=0 and @DeleteVar=1 begin
		if exists(select 1 from Deleted where EKLEYEN <> PERSONEL) begin
			declare DeleteCursor cursor for select ID,SERVISID,PERSONEL,EKLEYEN from Deleted where EKLEYEN <> PERSONEL
			open DeleteCursor
			fetch next from DeleteCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			while @@FETCH_STATUS = 0
			begin
				select @CurKONUSU=KONUSU,@CurBASLAMA=BASLAMATARIHI from SERVIS where ID=@CurSERVISID
				insert into DUYURU(GECERLILIKTARIHI,KONU,ONEM,KATEGORI,EKLEYEN,TUR,OLAYZAMANI,YER,YER_ID,SISTEM,YAZITURU)
				values(Getdate(),@CurKONUSU,0,84,@CurEKLEYEN,2,@CurBASLAMA,83,@CurID,1,0)
				set @DuyuruID = CONVERT(int, SCOPE_IDENTITY())

				if @CurEKLEYEN<>@CurREHBERID begin
					insert into DUYURUKULLANICI(DUYURUID,TUR,ALICIID)
					values(@DuyuruID,0,@CurREHBERID)
				end
				fetch next from DeleteCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			End
			close DeleteCursor
			deallocate DeleteCursor
		end
	end else if @InsertVar=1 and @DeleteVar=0 begin
		if exists(select 1 from Inserted where EKLEYEN <> PERSONEL) begin
			declare InsertCursor cursor for select ID,SERVISID,PERSONEL,EKLEYEN from Inserted where EKLEYEN <> PERSONEL
			open InsertCursor
			fetch next from InsertCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			while @@FETCH_STATUS = 0
			begin
				select @CurKONUSU=KONUSU,@CurBASLAMA=BASLAMATARIHI from SERVIS where ID=@CurSERVISID
				insert into DUYURU(GECERLILIKTARIHI,KONU,ONEM,KATEGORI,EKLEYEN,TUR,OLAYZAMANI,YER,YER_ID,SISTEM,YAZITURU)
				values(Getdate(),@CurKONUSU,0,83,@CurEKLEYEN,2,@CurBASLAMA,83,@CurID,1,0)
				set @DuyuruID = CONVERT(int, SCOPE_IDENTITY())

				if @CurEKLEYEN<>@CurREHBERID begin
					insert into DUYURUKULLANICI(DUYURUID,TUR,ALICIID)
					values(@DuyuruID,0,@CurREHBERID)
				end
				fetch next from InsertCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			End
			close InsertCursor
			deallocate InsertCursor
		end
	end else if @InsertVar=1 and @DeleteVar=1 begin
		if exists(select 1 from Deleted D inner join Inserted I on D.ID=I.ID where D.PERSONEL<>I.PERSONEL and isnull(I.DEGISTIREN,0)<>D.PERSONEL) begin
			declare DeleteCursor cursor for
				select D.ID,D.SERVISID,D.PERSONEL,D.EKLEYEN
				from Deleted D inner join Inserted I on D.ID=I.ID
				where D.PERSONEL<>I.PERSONEL and isnull(I.DEGISTIREN,0)<>D.PERSONEL
			open DeleteCursor
			fetch next from DeleteCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			while @@FETCH_STATUS = 0
			begin
				select @CurKONUSU=KONUSU,@CurBASLAMA=BASLAMATARIHI from SERVIS where ID=@CurSERVISID
				insert into DUYURU(GECERLILIKTARIHI,KONU,ONEM,KATEGORI,EKLEYEN,TUR,OLAYZAMANI,YER,YER_ID,SISTEM,YAZITURU)
				values(Getdate(),@CurKONUSU,0,84,@CurEKLEYEN,2,@CurBASLAMA,83,@CurID,1,0)
				set @DuyuruID = CONVERT(int, SCOPE_IDENTITY())

				if @CurEKLEYEN<>@CurREHBERID begin
					insert into DUYURUKULLANICI(DUYURUID,TUR,ALICIID)
					values(@DuyuruID,0,@CurREHBERID)
				end
				fetch next from DeleteCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			End
			close DeleteCursor
			deallocate DeleteCursor
		end

		if exists(select 1 from Deleted D inner join Inserted I on D.ID=I.ID where D.PERSONEL<>I.PERSONEL and isnull(I.DEGISTIREN,0)<>I.PERSONEL) begin
			declare InsertCursor cursor for
				select D.ID,D.SERVISID,D.PERSONEL,D.EKLEYEN
				from Deleted D inner join Inserted I on D.ID=I.ID
				where D.PERSONEL<>I.PERSONEL and isnull(I.DEGISTIREN,0)<>I.PERSONEL
			open InsertCursor
			fetch next from InsertCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			while @@FETCH_STATUS = 0
			begin
				select @CurKONUSU=KONUSU,@CurBASLAMA=BASLAMATARIHI from SERVIS where ID=@CurSERVISID
				insert into DUYURU(GECERLILIKTARIHI,KONU,ONEM,KATEGORI,EKLEYEN,TUR,OLAYZAMANI,YER,YER_ID,SISTEM,YAZITURU)
				values(Getdate(),@CurKONUSU,0,83,@CurEKLEYEN,2,@CurBASLAMA,83,@CurID,1,0)
				set @DuyuruID = CONVERT(int, SCOPE_IDENTITY())

				if @CurEKLEYEN<>@CurREHBERID begin
					insert into DUYURUKULLANICI(DUYURUID,TUR,ALICIID)
					values(@DuyuruID,0,@CurREHBERID)
				end
				fetch next from InsertCursor into @CurID, @CurSERVISID, @CurREHBERID, @CurEKLEYEN
			End
			close InsertCursor
			deallocate InsertCursor
		end
	end

	if @CurSERVISID is not null
	begin
		update SERVIS set
			BASLAMATARIHI=(select MIN(BASLAMA) from SERVISHAREKET where SERVISID=@CurSERVISID),
			BITISTARIHI=(select MAX(BITIS) from SERVISHAREKET where SERVISID=@CurSERVISID)
		where ID=@CurSERVISID
	end
end
GO

