unit UVersiyonGuncelle;
   //  genupdate.genyazilim.com/genupdate/guncelleme.aspx
   // 6  135
interface

const
  KomutNo  =  32958; // 17733;

var
  // SmallInt DEGIL: komut numaralari 32767'yi asti (32953...), SmallInt'e atarken
  //   deger sariyor (32857 -> -32679). Integer sart.
  VersBaslNo : Integer;

procedure VersiyonGuncelle;

implementation

uses UAnaForm,Classes, SysUtils, Utablo,GenUpdateWS,messages,Dialogs, StdCtrls,
      FetaKurulusSiniflari,StrUtils,PrjConst,UVeriMotor;

var
   komutlar : TStringList;
   GResult : ArrayOfGenUpdateWS_komutListe;

// Guncelleme olay logu ASLA guncellemeyi durdurmamali. Log INSERT'i patlarsa
//   (ornegin eski kurulumda kolon tipi dar) exception VersiyonGuncelle'yi koparir,
//   versiyon ilerlemez ve musteri her acilista AYNI yerde takilir kalir.
procedure GuncellemeLogla(ATur, ADurum: SmallInt; AVersiyon: Integer; const AAciklama: string);
begin
  try
    Tablo.OlaylarIslemleri(ATur, 10, 101, -1, ADurum, AVersiyon, AAciklama, 'null');
  except
    // log yazilamadi - guncelleme akisini bozma
  end;
end;

// OLAYLAR.BILGINO eski kurulumlarda smallint'tir (max 32767). Guncelleme komut
//   numaralari bu siniri astigi icin (32859...) log INSERT'i
//   "Arithmetic overflow error for data type smallint" verip guncellemeyi
//   KOPARIYORDU. Bunu duzelten komut (32864) zincirin ILERISINDE oldugu icin ona
//   hic ulasilamiyordu -> kilitlenme. Zincirden ONCE, kod tarafinda onariyoruz.
procedure OlaylarTablosuHazirla;
begin
  if AktifVeriMotor = vmPG then Exit;   // PG'de bu daralma yok
  try
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'if exists (select 1 from sys.columns c ' +
      '            join sys.types t on t.user_type_id = c.user_type_id ' +
      '           where c.object_id = object_id(''dbo.OLAYLAR'') ' +
      '             and c.name = ''BILGINO'' and t.name = ''smallint'') ' +
      '  alter table dbo.OLAYLAR alter column BILGINO int', [], []);
  except
    // onarilamadiysa da devam et: log artik try ile korunuyor
  end;
end;

procedure VersiyonGuncelle;
var
  i,j,yapilmayanKomut,AltSorguHataSay,ToplamHataSay:integer;
  LPgKomut, LMotorUygun: Boolean;
begin
  yapilmayanKomut   := 0;
  ToplamHataSay     := 0;
  OlaylarTablosuHazirla;
  Tablo.TablodanSorguAc(1,'select DEGER from GENINI where BOLUM='+IntToStr(Ops_GenelOpsiyon_VersiyonNo)+' ');

  GResult:=Guncelleme.guncelleme(1,Tablo.Query1.FieldByName('DEGER').AsInteger+1,KomutNo);

  for i := 0 to Length(GResult) - 1 do begin
    AltSorguHataSay := 0;
    // Komut hangi motora ait? ACIKLAMA'da '#pg'/'#PG' -> PG komutu; yoksa MSSQL/varsayilan komut.
    // Yalniz aktif motora uyan komut calistirilir; uyumsuz olan ATLANIR (versiyon no yine ilerler).
    LPgKomut := ContainsText(GResult[i].ACIKLAMA, '#pg');
    LMotorUygun := (LPgKomut = (AktifVeriMotor = vmPG));
    if LMotorUygun then begin
      // Komut calistirma da zinciri kirmasin: tek bir bozuk komut yuzunden kalan
      //   guncellemeler uygulanmadan kalmamali (hata sayilir, versiyon ilerler).
      try
         Tablo.GuncellemeSatiriCalistir(GResult[i].KOMUT,AltSorguHataSay);
      except
        on E: Exception do
        begin
          Inc(AltSorguHataSay);
          GuncellemeLogla(3, 0, GResult[i].VERSIYONNO, GResult[i].ACIKLAMA + ' [hata: ' + E.Message + ']');
        end;
      end;
      if AltSorguHataSay>0 then begin
        ToplamHataSay := ToplamHataSay+AltSorguHataSay;
        Inc(yapilmayanKomut);
        GuncellemeLogla(3,0,GResult[i].VERSIYONNO,GResult[i].ACIKLAMA);
      end else
        GuncellemeLogla(1,1,GResult[i].VERSIYONNO,GResult[i].ACIKLAMA);//TUR : 1-Bilgi, 2-Uyarı, 3-Hata
    end else
      // Motor uyumsuz komut atlandi (or. PG'de MSSQL komutu ya da MSSQL'de #pg komutu). Bilgi logla.
      GuncellemeLogla(1,1,GResult[i].VERSIYONNO,GResult[i].ACIKLAMA+' [atlandi: motor uyumsuz]');

    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:= 'UPDATE GENINI SET DEGER='+IntToStr(GResult[i].VERSIYONNO)+' where BOLUM= '+IntToStr(Ops_GenelOpsiyon_VersiyonNo);
    Tablo.Query2.ExecSQL;
  end;



  if ToplamHataSay>0 then
     ToplamGuncellemeHata:= ToplamHataSay;
  //    ShowMessage( IntToStr(yapilmayanKomut)+' adet güncellemeye ait '+IntToStr(ToplamHataSay)+' adet alt sorgu yapılamamıştır.'+#13+#10+'Güncellemeler sayfasından kontrol ediniz.');

end;


end.
