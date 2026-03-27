unit UExceldenVeriAl;

interface

uses Windows, sysutils, Vcl.Forms, Variants, ShellApi, Dialogs, ComObj, Controls, FireDAC.Comp.Client, DB, dxmdaset, Classes, strutils,
     System.JSON;

procedure Excel2Demirbas;
procedure Excel2ProjeButce(ProjeId:Integer);
procedure Excel2BankaHareket(TabImport, TabHareket: TFDQuery);
procedure Excel2MasrafGelir(GELIRMI: Boolean);
procedure Excel2KrediPlan(KrediId:Integer;ALINISTARIHI: TDateTime);
procedure Excel2StokSayimm(TabSayTutanak, TabSayimKalemleri: TFDQuery; ExcelStokId :Integer);
procedure Excel2Stoklar;
procedure Excel2Recete;
procedure Excel2ReceteOperasyon;
procedure Excel2CekSenet(CekSenet, Tur:SmallInt);
procedure Excel2Cari(Potansiyel:Boolean);
procedure Excel2IK(Potansiyel:Boolean);
procedure Excel2Fatura;
function  Excel2PDKS:TDateTime;
procedure Excel2UTS_Urun;
procedure Excel2FaturaSatir(FatSatirID : Integer);

implementation

uses UTablo, PrjConst, FetaKurulusSiniflari, UBekletme, UGirisKutusuEx, FetaUtil;

var
    book:variant;
    excel,sheet:variant;
    Satir,  AktarSay, UyariSay,  HataSay:integer;
    f : TextFile;
    DosyaAdi : String;

function excelsonsatir(AColumn: Integer): Integer;
const
  xlUp = 3;
begin
    Result := excel.Range[Char(96 + AColumn) + IntToStr(65536)].end[xlUp].Rows.Row;
end;

function ExcelBaslat : Boolean;
begin
   tablo.OpenDialog1.Title := 'Excel Dosyasını Aç';
   tablo.OpenDialog1.Filter := 'Excel Dosyaları *.xls';
   DosyaAdi:='';
   if tablo.OpenDialog1.Execute then begin
      excel := CreateOleObject('Excel.Application');
      book:= Excel.WorkBooks.Open(tablo.OpenDialog1.FileName);
      AktarSay := 0; UyariSay:=0;  HataSay:=0;
      Application.CreateForm(TBekletmeDlg,BekletmeDlg);

      Screen.Cursor:= crHourGlass;
      sheet := book.worksheets[1];
      BekletmeDlg.Caption := ExceldenVerilerAktariliyor;
      BekletmeDlg.cxProgressBar1.Properties.Max:=excelsonsatir(1)+1;
      BekletmeDlg.Show;
      Result := True;
   end
   else
      Result := False;
end;

procedure ExcelBitir;
begin
     try
      excel.DisplayAlerts := False;
      excel.quit;
      excel := Unassigned;
      BekletmeDlg.Destroy;


      if DosyaAdi<>'' then begin
            Writeln(f, '');
            Writeln(f, 'Uyarı Sayısı : ' + IntToStr(UyariSay));
            Writeln(f, 'Hata Sayısı : ' + IntToStr(HataSay));
            if HataSay > 0 then
               Writeln(f, 'Aktarılamadı! Hataları düzeltip tekrar deneyin..')
            else
               Writeln(f, 'Aktarılan Sayısı : ' + IntToStr(AktarSay));
            CloseFile(f);
            ShellExecute(0 {Handle}, 'open',pchar(DosyaAdi),nil,nil,SW_SHOWNORMAL);
      end
      else if HataSay=0 then
            Application.Messagebox(PChar('Aktarılan Sayısı : ' + IntToStr(AktarSay)),Pchar(Uyari),MB_OK);
    finally
      Screen.Cursor:=crDefault;
      //Listele;
    end;
end;

function Iniden_Deger_Getir(Id :Integer; Bilgi : String):String;
begin
   Tablo.TablodanSorguAc(1,'Select DEGER from GENINI where BOLUM='+IntToStr(Id)+' and ANAHTAR='''+Bilgi+''' and DIL=-1');
   if Tablo.Query1.RecordCount > 0 then
      Result := Tablo.Query1.Fields[0].AsString
   else
      Result:='0';
end;

function IniEkle(Id :Integer; Bilgi : String):String;
begin
   if Bilgi='' then
      result := '0'
   else begin
      Result := Iniden_Deger_Getir(Id, Bilgi);
      if Result='0' then begin  //yoksa ekleyelim
         Tablo.TablodanSorguAc(1,'Select isnull(max(DEGER),0)+1 from GENINI where BOLUM='+IntToStr(Id)+' and DIL=-1');
         Result := Tablo.Query1.Fields[0].AsString;
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)values('+IntToStr(Id)+','''+Bilgi+''','+Result+',-1,0)',[],[]);
      end;
   end;
end;

function TablodanIdGetir(TabloAdi, AramaAlani, Ad:String; AlanAdi:String='ID') : Integer;
begin
   Tablo.TablodanSorguAc(1, 'select '+AlanAdi+' from '+TabloAdi+' where '+AramaAlani+' = '''+Ad+'''');
   if Tablo.Query1.RecordCount > 0 then
      result := Tablo.Query1.Fields[0].AsInteger
   else
      result := 0;
end;

function TarihGecerli(T:String): Boolean;
begin
   Result := DateTimeToStr(StrToDateTimeDef(T, StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1980')))<>'01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1980';
end;

function FiyatDuzenle(var Fyt:String; DecimalNokta:Boolean=True): String;
var nokta,virgul : smallint;
begin
   if Fyt='' then
      Result := '0.0'
   else begin
      Fyt := StringReplace(Fyt, CariDoviz, '', [rfReplaceAll]);
      nokta := pos('.',Fyt);
      virgul := pos(',',Fyt);
      //string olarak hem nokta hem virgüllü gelirse -2.407,27 TL  gibi
      if (nokta>0)and(virgul>0) then begin
         if nokta>virgul then
            Fyt := StringReplace(Fyt, ',', '', [rfReplaceAll])
         else
            Fyt := StringReplace(Fyt, '.', '', [rfReplaceAll]);
      end;

      if DecimalNokta then
         //db ye yazmak için  25,8 ise 25.8 olmalı
         Result := trim(StringReplace(Fyt,',', '.',[rfReplaceAll]))
      else begin
        //kontrolde 25.8 -> 25,8  geçerli olabilir    StrToFloat(FiyatDuzenle(xx, False)) olarak kullanılacaksa burası seçilmelidir
         Fyt := StringReplace(Fyt, ',', FormatSettings.Decimalseparator, [rfReplaceAll]);
         Result := trim(StringReplace(Fyt, '.', FormatSettings.Decimalseparator,[rfReplaceAll]));
      end
   end;
end;

function FiyatGecerli(var Fyt:String): Boolean;
begin
   Result := StrToFloatDef(FiyatDuzenle(Fyt, False), -99999)<>-99999;
end;

function VarYokGecerli(s:String; Gecerli:String='V'): String;
begin
   if pos(Gecerli, uppercase(s))>0 then
      Result := '1'
   else
      Result := '0'
end;

function DegerYoksa(S, Def:String): String;
begin
   if s <> '' then
      Result := s
   else
      Result := Def
end;
                        //  RehId, Tabno_Rehber, Notlar);
procedure YorumMedyaEkle(GorevId, Tur:Integer; Yorum:String);
begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO GOREVYORUM(GOREVID, TUR, YORUM, GIRISKAYNAK,EKLEYEN) values ('
                          + IntToStr(GorevId) + ','+IntToStr(Tur)+','''+Yorum+''',1,'+Kullanan+')', [], []);
end;


function HataDosyaOlustur(OnBilgi:SmallInt; Mesaj:String): String;
var s : string [20];
begin  //kontrolse text dosya oluşturalım ki içine test verilerini kaydedip ekranda gösterelim;
   if DosyaAdi = '' then begin  //kontrolse text dosya oluşturalım ki içine test verilerini kaydedip ekranda gösterelim;
      DosyaAdi := ExtractFilePath(Application.ExeName)+'Gentegre Demirbas Excel Aktarim Kontrolu '+FormatDateTime('YYYY-MM-DD HH-NN-SS', Tablo.GENINI.BugunTrhSaat) + '.txt';
      AssignFile(F, DosyaAdi);
      {$I-}
      Append(F);
      {$I+}
      if IOResult > 0 then
         Rewrite(f);
   end;
   if OnBilgi=2 then begin
      inc(HataSay);
      s:='Hata:';
   end else begin
      inc(UyariSay);
      s:='Uyarı:';
   end;
   Writeln(f, s+' Satır '+IntToStr(satir)+' '+Mesaj);
end;

procedure Excel2Demirbas;
var
    i,RehID, KategoriID:integer;

    procedure DemirbasEkle(Kontrol:Boolean;Kod,Ad,Marka,Model,Kategori,Serino,Lokasyon,GTarih,DTarih,GirisSekli,Tutar,PBirimi,Amortisman,Cari,ZTarih,ZSahibi,ServisSorumlu,ServisBlgi,
                   Kal_Tarihi, Kal_Bit_Tarihi,Kal_Sertifika,Kal_Firma,Masraf_Var,Amortisman_Var,Takip_Var,KalVar,Servis_Var, Notlar, RFID, Barkod:String);
    var DemID, TutID : Integer;
        MarkaId, ModelId, LokId,GirisId : String[20];


        function KontrolIslemi : Boolean;
        begin
          if Ad='' then HataDosyaOlustur(2,'Ad boş');
          if GTarih='' then HataDosyaOlustur(2,' Giriş Tarihi boş');
          if (GTarih<>'')and(not TarihGecerli(GTarih)) then HataDosyaOlustur(2,'Giriş Tarihi Hatalı');
          if DTarih='' then HataDosyaOlustur(2,' Devir Tarihi boş');
          if (DTarih<>'')and(not TarihGecerli(DTarih)) then HataDosyaOlustur(2,'Devir Tarihi Hatalı');

          if (Cari<>'')and(TablodanIdGetir('REHBER','FIRMA',Cari)=0) then HataDosyaOlustur(2,'Cari Eklenmemiş');
          if (ZSahibi<>'')and(TablodanIdGetir('REHBER','FIRMA',ZSahibi)=0) then HataDosyaOlustur(2,'Zimmet Sahibi Eklenmemiş');
          if (ZTarih<>'')and(not TarihGecerli(ZTarih)) then HataDosyaOlustur(2,'Zimmet Tarihi Hatalı');
          if (((ZTarih='')and(ZSahibi<>''))or((ZTarih<>'')and(ZSahibi=''))) then HataDosyaOlustur(2,'Zimmet Tarihi ve sahibi varsa birlikte dolu olmalı');

          if (ServisSorumlu<>'')and(TablodanIdGetir('REHBER','FIRMA',ServisSorumlu)=0) then HataDosyaOlustur(2,'Servis Sorumlusu İK ya Eklenmemiş');
          if (ServisBlgi<>'')and(TablodanIdGetir('REHBER','FIRMA',ServisBlgi)=0) then HataDosyaOlustur(2,'Servis Bilgilenecek İK ya Eklenmemiş');

          if (VarYokGecerli(Servis_Var)='1')and((ServisSorumlu='')or(ServisBlgi='')) then HataDosyaOlustur(2,'Servis Var işaretlenmiş, servis sorumlu/bilgi Eklenmemiş');

          if (Kal_Tarihi<>'')and(not TarihGecerli(Kal_Tarihi)) then HataDosyaOlustur(2,'Kalibrasyon Tarihi Hatalı');
          if (Kal_Bit_Tarihi<>'')and(not TarihGecerli(Kal_Bit_Tarihi)) then HataDosyaOlustur(2,'Kalibrasyon Bitiş Tarihi Hatalı');
          if (((Kal_Tarihi='')and(Kal_Bit_Tarihi<>''))or((Kal_Tarihi<>'')and(Kal_Bit_Tarihi=''))) then HataDosyaOlustur(2,'Kalibrasyon Tarihi ve bitiş tarihi varsa birlikte dolu olmalı');
          if (Kal_Firma<>'')and(TablodanIdGetir('REHBER','FIRMA',Kal_Firma)=0) then HataDosyaOlustur(2,'Kalibrasyon Firması Cariye Eklenmemiş');
        end;

        function EklemeIslemi : Boolean;
        begin      //Giriş türü
           //Stok
            if TablodanIdGetir('DEMIRBAS','DEMIRBASNO', Kod)>0 then //daha önce eklenmiş uyarı ver
               HataDosyaOlustur(1,Kod+' '+Ad+' '+'Daha önce eklenmiş')
            else
            begin //eklenmemiş ekleyelim
                inc(AktarSay);
                if pos('SAT', uppercase(GirisSekli))>0 then
                   GirisId:='12'
                else if pos('RAL', uppercase(GirisSekli))>0 then
                   GirisId:='13'
                else
                   GirisId:='11';

                DemID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS (DEMIRBASNO,DEMIRBASADI,MARKA,MODEL,SERINO, KATEGORIID, DURUM, MASRAF,AMORTISMAN,TAKIP,KALIBRASYON,'+
                'SERVIS, NOTLAR, RFID, BARKOD, TEKNIKSORUMLU, TEKNIKBILGI, EKLEYEN, EKLEMETARIHI, SUBEID)'+
                 ' values ('''+Kod+''','''+StringReplace(Ad,#39,#39#39,[rfReplaceAll,rfIgnoreCase])+''','+MarkaId+','+ModelId+','''+SeriNo+''','+IntToStr(KategoriID)+
                 ',0,'+VarYokGecerli(Masraf_Var)+','+VarYokGecerli(Amortisman_Var)+','+VarYokGecerli(Takip_Var)+','+VarYokGecerli(KalVar)+','+VarYokGecerli(Servis_Var)+','+
                 ''','+Notlar+''','''+ RFID+''','''+ Barkod+''','+IntToStr(TablodanIdGetir('REHBER','FIRMA',ServisSorumlu))+','+IntToStr(TablodanIdGetir('REHBER','FIRMA',ServisBlgi))+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+') select scope_identity()',[],[], True);


                TutID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS_TUTANAK (TIP, TARIH, VERENID, ALANID, LOKASYONID,EKLEYEN, EKLEMETARIHI, REHBERID, '+
                   'BELGETARIH,TUTAR,KUR) values('+GirisId+','''+FormatDateTime('yyyy-mm-dd',StrToDateTime(DTarih))+''',0,0,'+LokId+','+Kullanan+','+
                   ''''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(TablodanIdGetir('REHBER','FIRMA',Cari))+
                   ','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', StrToDateTime(GTarih))+''','+DegerYoksa(FiyatDuzenle(Tutar),'0.0')+','''+DegerYoksa(PBirimi, CariDoviz)+''') select scope_identity()',[],[],True);
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS_TUTANAK_DETAY (TUTANAKID, DEMIRBASID)values('+IntToStr(TutId)+','+IntToStr(DemId)+')',[],[]);

                //zimmet
                if ZSahibi<>'' then begin
                   TutID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS_TUTANAK (TIP, TARIH, VERENID, ALANID, LOKASYONID,EKLEYEN, EKLEMETARIHI, REHBERID) values('+
                      '21,'''+FormatDateTime('yyyy-mm-dd', StrToDateTime(ZTarih))+''',0,'+IntToStr(TablodanIdGetir('REHBER','FIRMA',ZSahibi))+','+LokId+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',0) select scope_identity()',[],[],True);
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS_TUTANAK_DETAY (TUTANAKID, DEMIRBASID)values('+IntToStr(TutId)+','+IntToStr(DemId)+')',[],[]);
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DEMIRBAS set DURUM=21, REHBERID='+IntToStr(TablodanIdGetir('REHBER','FIRMA',ZSahibi))+' where ID = '+IntToStr(DemId),[],[]);
                end;
                ////Kalibrasyon
                if Kal_Tarihi<>'' then begin
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KALIBRASYON (DEMIRBASID, TARIH, GECERLILIKTARIHI,SERTIFIKA, REHBERID, EKLEYEN)values('+
                      IntToStr(DemId)+','''+FormatDateTime('yyyy-mm-dd', StrToDateTime(Kal_Tarihi))+''','''+FormatDateTime('yyyy-mm-dd', StrToDateTime(Kal_Bit_Tarihi))+''','''+Kal_Sertifika+''','+IntToStr(TablodanIdGetir('REHBER','FIRMA',Kal_Firma))+','+Kullanan+')',[],[]);
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set KALIBRASYON=1 where ID=&id ', ['&id'], [DemId]);
                end;
            end;
        end;
    begin
      MarkaId := IniEkle(Ops_Demirbas_Marka, Marka);
      ModelId := IniEkle(StrToInt(IntToStr(Ops_Demirbas_Marka)+MarkaId), Model);
      //lokasyon bakalım
      Tablo.TablodanSorguAc(1, 'select ID from LOKASYON where REHBERID = -1 and ACIKLAMA='''+Lokasyon+'''');
      if Tablo.Query1.RecordCount > 0 then
         LokId := Tablo.Query1.Fields[0].AsString
      else begin
         Tablo.TablodanSorguAc(1, 'select isnull(max(ID),0)+1 from LOKASYON where REHBERID = -1');
         LokId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
                      ' insert into LOKASYON (KOD,ACIKLAMA,DURUM, REHBERID)values('''+'L'+Tablo.Query1.Fields[0].AsString+''','''+Lokasyon+''',1,-1)  select scope_identity()', [], []);
      end;

      //Kategori bakalım
      KategoriID := TablodanIdGetir('DEMIRBAS_KATEGORI','AD',Kategori);
      if KategoriID = 0 then begin
         Tablo.TablodanSorguAc(1, 'select isnull(max(ID),0)+1 from LOKASYON where REHBERID = -1');
         KategoriID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
                      ' insert into DEMIRBAS_KATEGORI (KOD,TMYSKOD,AD,EKLEYEN)values(''K'+Tablo.Query1.Fields[0].AsString+''',''K'+Tablo.Query1.Fields[0].AsString+''','''+Kategori+''','+Kullanan+')  select scope_identity()', [], [], True);
      end;

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then begin
             DemirbasEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])),
                          Trim(VarToStr(sheet.cells[satir,9])),Trim(VarToStr(sheet.cells[satir,10])),Trim(VarToStr(sheet.cells[satir,11])),Trim(VarToStr(sheet.cells[satir,12])),
                          Trim(VarToStr(sheet.cells[satir,13])),Trim(VarToStr(sheet.cells[satir,14])),Trim(VarToStr(sheet.cells[satir,15])),Trim(VarToStr(sheet.cells[satir,16])),
                          Trim(VarToStr(sheet.cells[satir,17])),Trim(VarToStr(sheet.cells[satir,18])),Trim(VarToStr(sheet.cells[satir,19])),Trim(VarToStr(sheet.cells[satir,20])),
                          Trim(VarToStr(sheet.cells[satir,21])),Trim(VarToStr(sheet.cells[satir,22])),Trim(VarToStr(sheet.cells[satir,23])),Trim(VarToStr(sheet.cells[satir,24])),
                          Trim(VarToStr(sheet.cells[satir,25])),Trim(VarToStr(sheet.cells[satir,26])),Trim(VarToStr(sheet.cells[satir,27])),Trim(VarToStr(sheet.cells[satir,28])),
                          Trim(VarToStr(sheet.cells[satir,29])),Trim(VarToStr(sheet.cells[satir,30])));
           end;
      end;
    end;

begin
  //ShowMessage(MGAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

procedure Excel2CekSenet(CekSenet, Tur:SmallInt);
var
    RehberID, CekID  : integer;
    DovizTutari : Currency;
    DovizKuru : String[20];

    procedure CekSenetEkle(Kontrol:Boolean;GTarih,Kod,  MakbuzNo,SeriNo, VTarih, Tutar, Kur, CariKod, CariAd,  KefilAd,KefilTel, KefilVKNO,  KefilAdres:String);
//    var CekID : Integer;
//        MarkaId, ModelId, LokId,GirisId : String[20];

        function KontrolIslemi : Boolean;
        begin
          if GTarih='' then HataDosyaOlustur(2,' Giriş Tarihi boş');
          if (GTarih<>'')and(not TarihGecerli(GTarih)) then HataDosyaOlustur(2,'Giriş Tarihi Hatalı');
          if VTarih='' then HataDosyaOlustur(2,' Devir Tarihi boş');
          if (VTarih<>'')and(not TarihGecerli(VTarih)) then HataDosyaOlustur(2,'Vade Tarihi Hatalı');
          if Kod='' then HataDosyaOlustur(2,' Kod boş');

          if (CariKod='')and(CariAd='') then HataDosyaOlustur(2,'Cari Eklenmemiş');
          if (CariKod<>'')and(TablodanIdGetir('REHBER','KOD',CariKod)=0) then HataDosyaOlustur(2,'Cari Eklenmemiş');
          if (CariAd<>'')and(TablodanIdGetir('REHBER','FIRMA',CariAd)=0) then HataDosyaOlustur(2,'Cari Eklenmemiş');
        end;

        function EklemeIslemi : Boolean;
        begin
            if CariKod<>'' then
               RehberId := TablodanIdGetir('REHBER','KOD',CariKod)
            else
               RehberId := TablodanIdGetir('REHBER','FIRMA',CariAd);

            if (SeriNo<>'')and(TablodanIdGetir('CEKLER','SERINO', SeriNo)>0) then //daha önce eklenmiş uyarı ver
               HataDosyaOlustur(1,SeriNo+' '+'Serino daha önce eklenmiş')
            else
            if (Kod<>'')and(TablodanIdGetir('CEKLER','KOD', Kod)>0) then //daha önce eklenmiş uyarı ver
               HataDosyaOlustur(1,SeriNo+' '+'Kod daha önce eklenmiş')
            else
            begin //eklenmemiş ekleyelim
                inc(AktarSay);

                CekID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKLER ([KOD],[REHBERID],[TUR],[DURUM],[TARIH],[MAKBUZNO],[VADE],[TUTAR],[KUR],'+
                  '[DOVIZ_TUTARI],[DOVIZ_KURU],[SERINO],[EKLEYEN],[EKSTREDEKULLAN],[GIRISKAYNAK],[CEKSENET],[KEFIL_AD],[KEFIL_VKNO],'+
                  '[KEFIL_TEL],[KEFIL_ADRES],[ANIMSAT], SUBEID) values ('''+Kod+''','+IntToStr(RehberId)+','+IntToStr(Tur)+',1,'''+FormatDateTime('yyyy-mm-dd',StrToDateTime(GTarih))+''','''+
                    MakbuzNo+''','''+FormatDateTime('yyyy-mm-dd',StrToDateTime(VTarih))+''','+FiyatDuzenle(Tutar)+','''+Kur+''','+FiyatDuzenle(Tutar)+','''+Kur+''','+
                    SeriNo+','+Kullanan+',0,'+IntToStr(Windows_Excelden)+','+IntToStr(CekSenet)+','''+KefilAd+''','''+KefilVKNO+''','''+KefilTel+''','''+KefilAdres+''',0,'+
                    IntToStr(SubeId)+') select scope_identity()',[],[], True);

                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET ([CEKSENETLERID],[TARIH],[BILGI],[ISLEM],[REHBERID],[EKLEYEN],[DURUM],'+
                  '[DOVIZ_TUTARI],[DOVIZ_KURU],[TUTAR],[KUR],[EKSTREDEKULLAN]) values('+IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd',StrToDateTime(GTarih))+
                  ''',''Yeni'','+IntToStr(Tur)+','+IntToStr(RehberId)+','+Kullanan+',1,'+FiyatDuzenle(Tutar)+','''+Kur+''','+FiyatDuzenle(Tutar)+','''+Kur+''',0)',[],[]);

            end;
        end;
    begin
      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then begin
             CekSenetEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])),
                          Trim(VarToStr(sheet.cells[satir,9])),Trim(VarToStr(sheet.cells[satir,10])),Trim(VarToStr(sheet.cells[satir,11])),Trim(VarToStr(sheet.cells[satir,12])),
                          Trim(VarToStr(sheet.cells[satir,13])));
           end;
      end;
    end;

begin
  //ShowMessage(MGAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;


procedure Excel2MasrafGelir(GELIRMI: Boolean);
var
    i,RehID:integer;

  procedure MasrafGelirEkle(Kod,Ad,KDV,SubeId:String);
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into MASRAFGELIR(GELIRMI,KOD,AD,KDV,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID)'+
       ' values ('+BoolToStr(GELIRMI)+','''+Trim(Kod)+''','''+Trim(StringReplace(Ad,#39,#39#39,[rfReplaceAll,rfIgnoreCase]))+''','+kdv+',1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+SubeId+')',[],[]);
    end;
begin
  ShowMessage(MGAktarimkosullari);

   if ExcelBaslat then begin
      for satir := 2 to excelsonsatir(1)+1 do begin

        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;

           if VarToStr(sheet.cells[satir,2]) <> '' then begin
              MasrafGelirEkle(VarToStr(sheet.cells[satir,1]),VarToStr(sheet.cells[satir,2]),VarToStr(sheet.cells[satir,3]),VarToStr(sheet.cells[satir,4]));
           end;

      end;
      ExcelBitir;
  end;
end;

procedure Excel2ProjeButce(ProjeId:Integer);
var
    SatirNo : Variant;
    SatNo:Integer;
    procedure ProjeButceEkle(Kontrol:Boolean;Kod,Ad,Birim,Miktar,BFiyat,Tutar:String);
    var MasrafId : Integer;
        BirimId  : String[20];

        function KontrolIslemi : Boolean;
        begin
          if TablodanIdGetir('MASRAFGELIR','KOD', Kod)=0 then //daha önce eklenmiş uyarı ver
             HataDosyaOlustur(2,Kod+' '+Ad+' '+' Masraf tablosunda tanımlı değil.');
          if (Kod='')and(Ad<>'') then HataDosyaOlustur(2,'Ad dolu ama kod boş');
        end;

        function EklemeIslemi : Boolean;
        begin      //Giriş türü
           MasrafId := TablodanIdGetir('MASRAFGELIR','KOD', Kod);
           BirimId := IniEkle(Ops_StokKart_Anabirim, Birim);
           if (BFiyat='')and(Tutar<>'') then Begin //birim fiyat girilmeyip sadece tutar girilmişse
               Miktar := '1.0';
               BFiyat := Tutar;
           End;

           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PROJEBUTCE([PROJEID],[MASRAFID],[MIKTAR],[BIRIMI],[BIRIMFIYAT],[TUTAR],[KUR],[EKLEYEN])'+
                 ' values ('+IntToStr(ProjeId)+','+IntToStr(MasrafId)+','+FiyatDuzenle(Miktar)+','+BirimId+','+FiyatDuzenle(BFiyat)+','+FiyatDuzenle(Tutar)+','''+CariDoviz+''','+Kullanan+')',[],[]);
           inc(AktarSay);
        end;
    begin

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := SatNo to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if (VarToStr(sheet.cells[satir,1]) <> '')or(VarToStr(sheet.cells[satir,2]) <> '') then begin
             ProjeButceEkle(Kontrol, VarToStr(sheet.cells[satir,1]),VarToStr(sheet.cells[satir,2]),VarToStr(sheet.cells[satir,3]),VarToStr(sheet.cells[satir,4]),
                            VarToStr(sheet.cells[satir,5]),VarToStr(sheet.cells[satir,6]));
          end;
      end;
    end;

begin
  ShowMessage(PWButceAktarimkosullari);
   if ExcelBaslat then begin

      SatirNo := '2';
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGExcel_satiri_gir, @SatirNo)) <> mrOk then
         Abort;
      SatNo := StrToIntDef(VarToStr(SatirNo),2);
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

procedure Excel2Recete;
var
    SatirNo : Variant;
    SatNo, OncekiUrunId, ReceteId:Integer;
    procedure ReceteEkle(Kontrol:Boolean;UrunKod,UrunAd,SarfKod,SarfAd,Miktar,Birim:String);
    var UrunId, SarfId, UrunBirimId: Integer;
        SarfBirimId : String[20];

        function KontrolIslemi : Boolean;
        begin
          if (UrunKod='')or(SarfKod='') then HataDosyaOlustur(2,'Ürün Kodu ve Sarf Kodu dolu olmalı');
          if TablodanIdGetir('STOKLAR','KOD', UrunKod)=0 then //daha önce eklenmiş uyarı ver
             HataDosyaOlustur(2,UrunKod+' '+UrunAd+' '+' Stok tablosunda tanımlı değil.');
          SarfId := TablodanIdGetir('STOKLAR','KOD', SarfKod);
          if SarfId=0 then //daha önce eklenmiş uyarı ver
             HataDosyaOlustur(2,SarfKod+' '+SarfAd+' '+' Stok tablosunda tanımlı değil.')
          else begin
             if Iniden_Deger_Getir(Ops_StokKart_Anabirim, Birim)<>IntToStr(TablodanIdGetir('STOKLAR','ID', IntToStr(SarfId), 'ANABIRIM')) then
                HataDosyaOlustur(2,UrunKod+' '+UrunAd+' '+' Stok tablosunda anabirim tanımlı değil.');
          end;
        end;

        function EklemeIslemi : Boolean;
        begin      //Giriş türü
           UrunId := TablodanIdGetir('STOKLAR','KOD', UrunKod);
           SarfId := TablodanIdGetir('STOKLAR','KOD', SarfKod);
           SarfBirimId := Iniden_Deger_Getir(Ops_StokKart_Anabirim, Birim);

           if OncekiUrunId <> UrunId then begin
              ReceteId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into URETIMRECETE(KOD,AD,STOKID,TUR,EKLEYEN)values'+
                 '('''+UrunKod+''','''+UrunAd+''','+IntToStr(UrunId)+',2,'''+Kullanan+''') select SCOPE_IDENTITY()',[],[],True);
              OncekiUrunId := UrunId;
              UrunBirimId := TablodanIdGetir('STOKLAR','KOD', UrunKod, 'ANABIRIM');
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into URETIMRECETEDETAY(URETIMRECETEID,TUR,URUNID,ADET,BIRIM,MIKTAR,ADETHESAP,ANAURUN ,EKLEYEN)values'+
                 '('+IntToStr(ReceteId)+',1,'+IntToStr(UrunId)+',1.0,'+IntToStr(UrunBirimId)+',1.0,1.0,1,'''+Kullanan+''')',[],[]);
              inc(AktarSay);
           end;
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into URETIMRECETEDETAY(URETIMRECETEID,TUR,URUNID,ADET,BIRIM,MIKTAR,ADETHESAP,ANAURUN,EKLEYEN)values'+
                 '('+IntToStr(ReceteId)+',1,'+IntToStr(SarfId)+',-1*'+FiyatDuzenle(Miktar)+','+SarfBirimId+',-1*'+FiyatDuzenle(Miktar)+',-1*'+FiyatDuzenle(Miktar)+',0,'''+Kullanan+''')',[],[]);
        end;
    begin

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := SatNo to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if (VarToStr(sheet.cells[satir,1]) <> '')or(VarToStr(sheet.cells[satir,2]) <> '') then begin
             ReceteEkle(Kontrol, VarToStr(sheet.cells[satir,1]),VarToStr(sheet.cells[satir,2]),VarToStr(sheet.cells[satir,3]),VarToStr(sheet.cells[satir,4]),
                            VarToStr(sheet.cells[satir,5]),VarToStr(sheet.cells[satir,6]));
          end;
      end;
    end;

begin
  ShowMessage(PWReceteAktarimkosullari);
   if ExcelBaslat then begin

      SatirNo := '2';  OncekiUrunId:=0;
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGExcel_satiri_gir, @SatirNo)) <> mrOk then
         Abort;
      SatNo := StrToIntDef(VarToStr(SatirNo),2);
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;


procedure Excel2ReceteOperasyon;
var
    SatirNo : Variant;
    SatNo, OncekiUrunId, ReceteId:Integer;
    procedure ReceteOprEkle(Kontrol:Boolean;ReceteId,Konu,Sira:String);
    var UrunId, SarfId, UrunBirimId: Integer;
        SarfBirimId : String[20];

        function KontrolIslemi : Boolean;
        begin
          if (ReceteId='')or(Konu='')or(Sira='') then HataDosyaOlustur(2,'Reçete Id, konu ve sıra dolu olmalı');
          if TablodanIdGetir('URETIMRECETE ','ID', ReceteId)=0 then //daha önce eklenmiş uyarı ver
             HataDosyaOlustur(2,ReceteId+ ' Reçete tablosunda tanımlı değil.');
          {SarfId := TablodanIdGetir('STOKLAR','KOD', SarfKod);
          if SarfId=0 then //daha önce eklenmiş uyarı ver
             HataDosyaOlustur(2,SarfKod+' '+SarfAd+' '+' Stok tablosunda tanımlı değil.')
          else begin
             if Iniden_Deger_Getir(Ops_StokKart_Anabirim, Birim)<>IntToStr(TablodanIdGetir('STOKLAR','ID', IntToStr(SarfId), 'ANABIRIM')) then
                HataDosyaOlustur(2,UrunKod+' '+UrunAd+' '+' Stok tablosunda anabirim tanımlı değil.');
          end; }
        end;

        function EklemeIslemi : Boolean;
        begin      //Giriş türü
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into URETIMRECETEOPR(URETIMRECETEID,KONUSU,SIRA,EKLEYEN)values'+
                 '('+ReceteId+','''+Konu+''','+Sira+','+Kullanan+')',[],[]);
           inc(AktarSay);
        end;
    begin

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := SatNo to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if (VarToStr(sheet.cells[satir,1]) <> '')or(VarToStr(sheet.cells[satir,2]) <> '') then begin
             ReceteOprEkle(Kontrol, VarToStr(sheet.cells[satir,1]),VarToStr(sheet.cells[satir,2]),VarToStr(sheet.cells[satir,3]));
          end;
      end;
    end;

begin
  ShowMessage(PWReceteOprAktarimkosullari);
   if ExcelBaslat then begin
      AktarSay:=0;
      SatirNo := '2';  OncekiUrunId:=0;
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGExcel_satiri_gir, @SatirNo)) <> mrOk then
         Abort;
      SatNo := StrToIntDef(VarToStr(SatirNo),2);
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

procedure Excel2BankaHareket(TabImport, TabHareket: TFDQuery);
var
    SatNo,TarihSutNo,SaatSutNo,NoSutNo,IslemSutNo,AcikSutNo,TutarSutNo, BankaKodu, HesapId : Integer;
    BankaIBAN, BankaKur:String;
    bulundu : boolean;
    KolonList, FormatList : TStringList;
    procedure HareketEkle(Kontrol:Boolean;Tarih,Saat,No,Islem,Aciklama,Tutar:String);
    var MasrafId : Integer;
        BirimId  : String[20];

        function KontrolIslemi : Boolean;
        begin

        end;

        function EklemeIslemi : Boolean;
        var Alan, Bas, Bit, Esit:String[20];
            EklenenTarih : TDateTime;
        begin      //Giriş türü
           //apostrof varsa çıkaralım
           Islem := StringReplace(Islem,'''',' ',[rfReplaceAll]);
           Aciklama := StringReplace(Aciklama,'''',' ',[rfReplaceAll]);
           //tarihi bulalım
           Tarih := StringReplace(Tarih, '/', FormatSettings.DateSeparator, [rfReplaceAll]);
           Tarih := StringReplace(Tarih, '.', FormatSettings.DateSeparator, [rfReplaceAll]);
           if StrToDateTimeDef(Tarih, StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2000'))=
              StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2000') then exit;

           if Saat='' then
              Saat:='00:00'
           else if pos('0.', Saat)=1 then //excelde tarih formatlı tutuluyorsa
              saat := FormatDateTime('hh:nn', VarToDateTime(sheet.cells[satir,StrToInt(KolonList.Strings[1])]))
           else
              saat := copy(saat,1,2)+':'+copy(saat,4,2);
           EklenenTarih := StrToDateTimeDef(Tarih+' '+Saat, StrToDateTime(Tarih));
           //Önce bakalım daha önce eklenmiş mi?
           if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from BANKAIMPORTHAREKET where TARIH = '''+FormatDateTime('yyyy-mm-dd hh:nn', EklenenTarih)+''' '+
              ' and NO='''+No+''' and GELENISLEMTIPI='''+Islem+''' and ACIKLAMA like '''+Aciklama+'%'' ',[], []) = False then begin
               TabHareket.Append;
               TabHareket.FieldByName('BANKAIMPORTID').AsInteger := TabImport.FieldByName('ID').AsInteger;
               TabHareket.FieldByName('TARIH').AsDateTime := EklenenTarih;
               TabHareket.FieldByName('SEC').AsBoolean := True;
               TabHareket.FieldByName('No').AsString := No;
               TabHareket.FieldByName('GELENISLEMTIPI').AsString := Islem;
               TabHareket.FieldByName('DURUM').AsInteger := 0;
               TabHareket.FieldByName('PRGISLEMTIPI').AsInteger := 0;
               TabHareket.FieldByName('ACIKLAMA').AsString := Aciklama;
               TabHareket.FieldByName('EKLEME').AsInteger := 0;
               TabHareket.FieldByName('Tutar').AsString := FiyatDuzenle(Tutar, False);
               if BankaKur<>CariDoviz then begin //eğer döviz hesabı ise o günkü kur değerini de girelim
                  TabHareket.FieldByName('Kur').AsString := CariDoviz;
                  TabHareket.FieldByName('KURDEGERI').AsFloat := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', EklenenTarih), BankaKur, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
               end else
                  TabHareket.FieldByName('Kur').AsString := '';
               TabHareket.FieldByName('HESAPID').AsInteger:=0;
               TabHareket.FieldByName('MASRAFID').AsInteger:=0;
               TabHareket.FieldByName('PROJEID').AsInteger:=0;
               TabHareket.FieldByName('DEGISTIREN').AsString := Kullanan;
               TabHareket.FieldByName('DEGISTIRMETARIHI').AsDateTime := TabImport.FieldByName('EKLEMETARIHI').AsDateTime;
               TabHareket.Post;
               inc(AktarSay);
           end;
        end;
    begin

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;        // 123456789
    end;                     //  @ARADAN(3,2)

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
      function Formatla(S:string; I:Integer) : String;
      var bas,uzun:integer;
          f:string;
      begin
         s:=Trim(s);
         f:=trim(FormatList.Strings[I]);
         if f='' then
             result := s
         else begin
             if pos('@SOL', f)>0 then begin
                uzun:=StrToIntDef(copy(f, pos('(', f)+1,  pos(')', f)-pos('(', f)-1),0);
                result:=copy(s,1, uzun)
             end else if pos('@SA', f)>0 then begin
                uzun:=StrToIntDef(copy(f, pos('(', f)+1,  pos(')', f)-pos('(', f)-1),0);
                result:=RightStr(s, uzun);
             end else if pos('@ARA', f)>0 then begin
                bas:=StrToIntDef(copy(f, pos('(', f)+1,  pos(',', f)-pos('(', f)-1),0);
                uzun:=StrToIntDef(copy(f, pos(',', f)+1,  pos(')', f)-pos(',', f)-1),0);
                result:=copy(s, bas, uzun);
             end;
         end;
      end;
    begin
       DosyaAdi := '';
      for satir := SatNo to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if (VarToStr(sheet.cells[satir,1]) <> '')or(VarToStr(sheet.cells[satir,2]) <> '') then begin
             HareketEkle(Kontrol, Formatla(VarToStr(sheet.cells[satir,StrToInt(KolonList.Strings[0])]),0),Formatla(VarToStr(sheet.cells[satir,StrToInt(KolonList.Strings[1])]),1),
               Formatla(VarToStr(sheet.cells[satir,StrToInt(KolonList.Strings[2])]),2),Formatla(VarToStr(sheet.cells[satir,StrToInt(KolonList.Strings[3])]),3),
               Formatla(VarToStr(sheet.cells[satir,StrToInt(KolonList.Strings[4])]),4),Formatla(VarToStr(sheet.cells[satir,StrToInt(KolonList.Strings[5])]),5));
          end;

      end;
    end;
begin
  //ShowMessage(BankaHareketAktarimkosullari);
   Tablo.TablodanSorguAc(5,'select SATIR=HESAPID, SUTUN=DEGER_GECEN from BANKAKURAL where PRGISLEMTIPI=1010 and TUR=1 and isnull(HESAPID,0)>0 and isnull(DEGER_GECEN,'''')<>'''' ');
   if Tablo.Query5.RecordCount<1 then begin
      Showmessage(' Bankalara ait hiç bir kural bulunamadı.');
      exit;
   end;

   if ExcelBaslat then begin
      //ilk iş excelde IBAN bilgisine ulaşmak
      bulundu := False;
      while (not bulundu)and(not Tablo.Query5.eof) do begin
         BankaIBAN :=VarToStr(sheet.cells[Tablo.Query5.Fields[0].AsInteger, Tablo.Query5.Fields[1].AsInteger]);
         if pos('TR', BankaIBAN)=1 then
            bulundu := True
         else
            Tablo.Query5.next;
      end;
      if Bulundu then begin
         BankaIBAN := StringReplace(BankaIBAN,' ','',[rfReplaceAll]);
         Tablo.TablodanSorguAc(5,'select BH.ID AS ID, KUR, B.BANKAKODU,BANKAADI,SUBEKODU,SUBEADI,HESAPNO,HESAPADI,HESAPKODU from BANKAHESAPLAR BH '+
                                 'inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU '+
                                 'where replace(IBAN,'' '','''')='''+BankaIBAN+'''');
         if Tablo.Query5.RecordCount<1 then
            Showmessage(BankaIBAN+' IBAN no lu hesap bulunamadı.')
         else begin
            HesapId := Tablo.Query5.Fields[0].AsInteger;
            BankaKur := Tablo.Query5.Fields[1].AsString;
            BankaKodu := Tablo.Query5.Fields[2].AsInteger;
            Tablo.TablodanSorguAc(5,'select SATSUT=HESAPID from BANKAKURAL where PRGISLEMTIPI = 1030 and TUR=1 and BANKAKODU='+IntToStr(BankaKodu));
            SatNo := Tablo.Query5.Fields[0].AsInteger;
            KolonList := TStringList.Create;
            FormatList := TStringList.Create;

         Tablo.TablodanSorguAc(5,'select SATSUT=isnull(HESAPID,0), FORMAT=DEGER_GECEN from BANKAKURAL where PRGISLEMTIPI >= 1040 and TUR=1 and BANKAKODU='+IntToStr(BankaKodu));
         while not Tablo.Query5.eof do begin
            if Tablo.Query5.Fields[0].AsString='0' then
               KolonList.Add('33')//o sütun yoksa örneğin saat sütunu yoksa boş gelmesi için 33 üncü sütun atanır
            else
               KolonList.Add(Tablo.Query5.Fields[0].AsString); //tarihin hangi kolonda olduğu bilgisi Ör : 1
            FormatList.Add(Tablo.Query5.Fields[1].AsString);//tarihin formatı Ör @SOL(8) gibi
            Tablo.Query5.next;
         end;
         //AÇIKLAMA içinde geçen olanlara göre işlem tipi belirlenecek
         Tablo.TablodanSorguAc(8,'select PRGISLEMTIPI, [DEGER_EXCEL],[DEGER_GECEN] from BANKAKURAL '+
           ' where BANKAKODU='+IntToStr(BankaKodu)+' and TUR=2  ');//and KOLON=4

          //AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
         if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
            //burada önce BANKAIMPORT tablosuna bilgi atalım. hangi tarihte hangi bankadan excel alınmış
            TabImport.Append;
            TabImport.FieldByName('BANKAKODU').AsInteger := BankaKodu;
            TabImport.FieldByName('BANKAHESAPID').AsInteger := HesapId;
            TabImport.FieldByName('KUR').AsString := BankaKur;
            TabImport.FieldByName('GIRISKAYNAK').AsInteger := Windows_Excelden;
            TabImport.FieldByName('EKLEYEN').AsString := Kullanan;
            TabImport.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
            TabImport.Post;
            AktarmaIslemi(False);
            TabImport.Edit;
            TabImport.FieldByName('TOPLAMSAY').AsInteger := AktarSay;
            TabImport.FieldByName('KALANSAY').AsInteger := AktarSay;
            TabImport.Post;
         KolonList.Free;
         //FormatList.Free;
       end;
    end{bulundu}
    else
       Showmessage('Bu excel dosyasındaki banka ayarları bulunamadı.');
     ExcelBitir;
   end;
end;

procedure Excel2KrediPlan(KrediId:Integer;ALINISTARIHI: TDateTime);
var
   i,RehID:integer;
   procedure MasrafGelirEkle(TARIH,TAKSIT,ANAPARA,FAIZ,KKDF,BSMV,BAKIYE,KUR,ACIKLAMA:String);
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PLANKREDI (KREDIID,TARIH,TAKSIT,ANAPARA,FAIZ,KKDF,BSMV,BAKIYE,KUR,ACIKLAMA,ODENMIS,ANIMSAT,EKLEYEN,EKLEMETARIHI,'+
         'SUBEID, DEGISTI) values ('+IntToStr(KrediId)+','''+FormatDateTime('yyyy-mm-dd', StrToDateTimeDef(TARIH, ALINISTARIHI))+''','+
         StringReplace(TAKSIT,',','.',[])+','+StringReplace(ANAPARA,',','.',[])+','+StringReplace(FAIZ,',','.',[])+','+StringReplace(KKDF,',','.',[])+
         ','+StringReplace(BSMV,',','.',[])+','+StringReplace(BAKIYE,',','.',[])+','''+KUR+''','''+Trim(StringReplace(ACIKLAMA,'''','',[rfReplaceAll]))+''',0,0,'+Kullanan+',getdate(),'+IntToStr(SubeId)+',0)',[],[]);
    end;
begin
   ShowMessage(KrediAktarimkosullari);
   if ExcelBaslat then begin
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position :=  satir;
          BekletmeDlg.cxProgressBar1.Refresh;

           if VarToStr(sheet.cells[satir,2]) <> '' then
              MasrafGelirEkle(VarToStr(sheet.cells[satir,1]),VarToStr(sheet.cells[satir,2]),VarToStr(sheet.cells[satir,3]),VarToStr(sheet.cells[satir,4]),
                    VarToStr(sheet.cells[satir,5]),VarToStr(sheet.cells[satir,6]),VarToStr(sheet.cells[satir,7]),VarToStr(sheet.cells[satir,8]),VarToStr(sheet.cells[satir,9]));

      end;
      ExcelBitir;
    end;
end;


///SAYIM AKTARIM

procedure Excel2StokSayimm(TabSayTutanak, TabSayimKalemleri: TFDQuery; ExcelStokId :Integer);
var
    i,RehID:integer;

    procedure SayimEkle(Kontrol:Boolean;Kod,Ad,Birim,Adet,BFiyat:String);
    var DemID, TutID : Integer;
        MarkaId, ModelId, LokId,GirisId : String[20];

        function KontrolIslemi : Boolean;
        begin
          if Kod='' then HataDosyaOlustur(2,'Kod boş');
          if (Kod<>'')and(TablodanIdGetir('STOKLAR','KOD',Kod)=0) then HataDosyaOlustur(2,'Stok Eklenmemiş');
          if Birim='' then HataDosyaOlustur(2,' Birim boş');
          if Adet='' then HataDosyaOlustur(2,' Adet boş');
          if (BFiyat<>'')and(not FiyatGecerli(BFiyat))  then HataDosyaOlustur(2,'  Fiyat Hatalı');
        end;

        function EklemeIslemi : Boolean;
        begin
            inc(AktarSay);
            BFiyat := StringReplace(BFiyat, ',', FormatSettings.Decimalseparator, [rfReplaceAll]);
            BFiyat := StringReplace(BFiyat, '.', FormatSettings.Decimalseparator,[rfReplaceAll]);
            tabSayimKalemleri.Append;
            tabSayimKalemleri.FieldByName('STOKID').AsInteger := TablodanIdGetir('STOKLAR','KOD',Kod);//ExcelStokId;
            tabSayimKalemleri.FieldByName('KUR').AsString := CariDoviz;

            Tablo.TablodanSorguAc(2,'sp_StokSayim '''+FormatDateTime('yyyy-mm-dd hh:nn:ss',TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime)+''','+tabSayimKalemleri.FieldByName('STOKID').AsString+','+TabSayTutanak.FieldByName('SAYIMDEPO').AsString);
            //TabDetayGiris.FieldByName('SISTEMDEKIMIKTAR').Value := Tablo.Query2.FieldByName('KALAN').Value;

           // tablo.TablodanSorguAc(3,'Select KALAN from STOKDURUM WHERE STOKID ='+IntToStr(ExcelStokId)+' ');
            tabSayimKalemleri.FieldByName('SISTEMDEKIMIKTAR').Value := Tablo.Query2.FieldByName('KALAN').Value;
            tabSayimKalemleri.FieldByName('SAYIMMIKTAR').Value := StrToFloat(StringReplace(Adet, '', '', [rfReplaceAll]));
            tabSayimKalemleri.FieldByName('BIRIMFIYAT').AsCurrency := StrToCurr(BFiyat);
            tabSayimKalemleri.FieldByName('TUTAR').Value  :=StrToFloat(StringReplace(Adet, '', '', [rfReplaceAll]))*StrToCurr(BFiyat);
            tabSayimKalemleri.Post;
        end;
     begin
      //BirimID := IniEkle(Ops_StokKart_Anabirim, Birim);

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then
             SayimEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])));
      end;
    end;
begin
   ShowMessage(STAktarim_kosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;


///STOK AKTARIM

procedure Excel2Stoklar;
var
    i,RehID:integer;

    procedure StokEkle(Kontrol:Boolean;Kod,Ad,Kategori,Tipi,Barkod,Marka,Model,Grubu, Ozellik, AnaBirim,Birim2,Birim2Carpan,KDV,OTV_Katsayi, OTV_Yuzde,Izleme,KulSekli,
                Garanti, Web, OzelKod,Ekipman, Notlar, Fiyat, ParaBirimi, FiyatAdi, UrunNo : String);
    var StokID, FiyatID : Integer;
        MarkaId, ModelId, KategoriID,TipiID,GrubuID, OzellikID, AnaBirimID,Birim2ID,IzlemeID,FiyatAdiID, OTVSec : String[20];

        function KategoriEkle(Bilgi : String):String;
        begin
           if Bilgi='' then
              result := '0'
           else begin
              Tablo.TablodanSorguAc(1,'Select ID from KATEGORI where KOD='''+Bilgi+''' or AD='''+Bilgi+''' ');
              if Tablo.Query1.RecordCount > 0 then
                 Result := Tablo.Query1.Fields[0].AsString
              else begin
                 Tablo.TablodanSorguAc(1,'Select isnull(max(ID),0)+1 from KATEGORI ');
                 Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KATEGORI (KOD, AD)values(''K'+Tablo.Query1.Fields[0].AsString+''','''+Bilgi+''') select scope_identity()',[],[],True);
              end;
           end;
        end;

        function KontrolIslemi : Boolean;
        begin
          if Kod='' then HataDosyaOlustur(2,'Kod boş');
          if Ad='' then HataDosyaOlustur(2,'Ad boş');
          if AnaBirim='' then HataDosyaOlustur(2,'AnaBirim boş');
          if KDV='' then HataDosyaOlustur(2,'KDV boş');
          if (OTV_Katsayi<>'')and(OTV_Yuzde<>'') then HataDosyaOlustur(2,'Aynı anda hem ÖTV(KATSAYI),	ÖTV(YÜZDE) dolu olamaz');
          if (Fiyat<>'')and(not FiyatGecerli(Fiyat))  then HataDosyaOlustur(2,'  Fiyat Hatalı');
          //if (((Fiyat='')and(FiyatAdi<>''))or((Fiyat<>'')and(FiyatAdi='')))  then HataDosyaOlustur(2,'Varsa Fiyat ve Fiyat Adı Birlikte Dolu Olmalı');
        end;
        
        function EklemeIslemi : Boolean;
        begin
            //Stok
            if TablodanIdGetir('STOKLAR','KOD',Kod)>0 then //daha önce eklenmiş uyarı ver
               HataDosyaOlustur(1,Kod+' '+Ad+' '+'Daha önce eklenmiş')
            else
            begin //eklenmemiş ekleyelim
              if OTV_Katsayi<>'' then
                 OTVSec:='0'
              else
                 OTVSec:='1';
              OTV_Katsayi := DegerYoksa(OTV_Katsayi, OTV_Yuzde);


              inc(AktarSay);
              StokID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO STOKLAR (KOD,STOKADI,KATEGORI,TIPI,MARKA,MODEL,GRUBU,OZELLIK,OZELKOD '+
                           ',ANABIRIM, BIRIM2, BIRIM2MIKTAR, KDV, OTVYUZDE, OTVMIKTAR, IZLEME, KULLANIM, GARANTISURESI, EKIPMAN, INTERNET_SATIS,NOTLAR, DURUM,SUBEID,URUNNO) '+
                           'VALUES ('''+Kod+''','''+Ad+''','+KategoriID+','+TipiID+','+MarkaId+','+ModelId+','+GrubuID+','+OzellikID+','''+OzelKod+''','+
                            AnaBirimID+','+Birim2ID+','+DegerYoksa(Birim2Carpan,'1')+','+DegerYoksa(KDV,'18')+','+OTVSec+','+DegerYoksa(OTV_Katsayi,'0')+','+
                            IzlemeID+',0,'+ DegerYoksa(Garanti,'0')+','+VarYokGecerli(Ekipman)+','+VarYokGecerli(Web)+','''+Notlar+''',1,-1, '''+UrunNo+''')select SCOPE_IDENTITY() ',[],[],True);

              if Barkod<>'' then
                 VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKBARKOD(BARKOD,STOKID,BARKODTIPI,BARKODBIRIMI,VARSAYILAN,EKLEYEN)'+
                        'values('''+Barkod+''','+IntToStr(StokID)+',0,'+AnaBirimID+',1,'+Kullanan+')',[],[]);
              if Fiyat<>'' then
//                 Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKFIYAT(STOKID,FIYATADI,BIRIM,FIYAT,KUR,KDVDURUM,PAKETID,SATIS) values('+
//                   IntToStr(StokID)+','+ VarsayilanFiyat+','+AnaBirimID+','+FiyatGecerli(Fiyat)+','+DegerYoksa(ParaBirimi, CariDoviz)+',0,0,1',[],[]);
                 Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKFIYAT set FIYAT='+FiyatDuzenle(Fiyat)+',KUR='''+DegerYoksa(ParaBirimi, CariDoviz)+''' where STOKID='+IntToStr(StokID),[],[]);
            end;
        end;
     begin
      MarkaId := IniEkle(Ops_StokKart_Marka, Marka);
      ModelId := IniEkle(StrToInt(IntToStr(Ops_StokKart_Marka)+MarkaId), Model);
      KategoriID := KategoriEkle(Kategori);
      TipiID := IniEkle(Ops_StokKart_Tipi, Tipi);
      GrubuID := IniEkle(Ops_StokKart_Grubu, Grubu);
      OzellikID := IniEkle(Ops_StokKart_Ozellik, Ozellik);
      AnaBirimID := IniEkle(Ops_StokKart_Anabirim, Anabirim);
      Birim2ID := IniEkle(Ops_StokKart_Anabirim, Birim2);
      if Birim2ID = '0'  then Birim2ID := AnaBirimID;
      IzlemeID := IniEkle(Ops_StokKart_Izleme, Izleme);
      FiyatAdiID := IniEkle(Ops_FiyatListeAdi, FiyatAdi);

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then
             StokEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])),
                          Trim(VarToStr(sheet.cells[satir,9])),Trim(VarToStr(sheet.cells[satir,10])),Trim(VarToStr(sheet.cells[satir,11])),Trim(VarToStr(sheet.cells[satir,12])),
                          Trim(VarToStr(sheet.cells[satir,13])),Trim(VarToStr(sheet.cells[satir,14])),Trim(VarToStr(sheet.cells[satir,15])),Trim(VarToStr(sheet.cells[satir,16])),
                          Trim(VarToStr(sheet.cells[satir,17])),Trim(VarToStr(sheet.cells[satir,18])),Trim(VarToStr(sheet.cells[satir,19])),
                          Trim(VarToStr(sheet.cells[satir,20])),Trim(VarToStr(sheet.cells[satir,21])),Trim(VarToStr(sheet.cells[satir,22])),Trim(VarToStr(sheet.cells[satir,23])),
                          Trim(VarToStr(sheet.cells[satir,24])),Trim(VarToStr(sheet.cells[satir,25])),Trim(VarToStr(sheet.cells[satir,26])));//,Trim(VarToStr(sheet.cells[satir,23]))  );
      end;
    end;
begin
   ShowMessage(StokAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

///CARİ AKTARIM
procedure Excel2Cari(Potansiyel:Boolean);
var
    i,RehID:integer;

    procedure CariEkle(Kontrol:Boolean;Kod,Ad,Grup,IlkTemas,Sektor,Kategori,Sinif,Temsilci,Bolge,AltBolge,Ozelkod,Muhkodu,Peryot,
                       VergiDai,VergiNo,IsTel, Faks, CepTel,	Eposta, Web, Adres,PK, Ilce, Il, Ulke,PostaDgt,EPostaDgt,Vade,Notlar,FirmaUTSNo,FirmaResmiAd :String);
    var IletId : Integer;
        function KontrolIslemi : Boolean;
        begin
          if Kod='' then HataDosyaOlustur(2,'Kod boş');
          if Ad='' then HataDosyaOlustur(2,'Ad boş');
          if Iniden_Deger_Getir(Ops_CariKart_Grup, Grup)='0' then HataDosyaOlustur(2,' Grup Caride tanımlı değil..');
          if (Temsilci<>'')and(TablodanIdGetir('REHBER','FIRMA',Temsilci)=0) then HataDosyaOlustur(2,'Temsilci İK ya Eklenmemiş');
        end;

        function RehberBilgiEkleme(Yeri,YerId:Integer; Bilgi, Varsayilan:String): Boolean;
        begin
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO REHBERBILGI([YERI],[YER_ID],[SIRA],[ETIKET],[BILGI],EKLEYEN, '+
               ' SUBEID) SELECT YERI='+IntToStr(Yeri)+',YER_ID='+IntToStr(YerId)+',SIRA,ETIKET,BILGI='''+Bilgi+''', EKLEYEN='+Kullanan+
               ', SUBEID=' + IntToStr(SubeId)+ ' FROM REHBERAYAR RA inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO and RV.NO='+Varsayilan+' and RV.YERI=RA.YERI',[], []);
        end;

        function EklemeIslemi : Boolean;
        begin
              if TablodanIdGetir('REHBER','KOD', Kod)>0 then //daha önce eklenmiş uyarı ver
                 HataDosyaOlustur(1,Kod+' '+Ad+' '+'Daha önce eklenmiş')
              else begin //eklenmemiş ekleyelim
                      inc(AktarSay);
                      Grup:= Iniden_Deger_Getir(Ops_CariKart_Grup, Grup);
                      RehID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBER([KOD],[FIRMA],[GRUP],[KATEGORI],[SINIF]'+
                            ',[TEMAS],[SEKTOR],[TEMSILCI],[BOLGE],[ALTBOLGE],[PERYOT],POSTA,EPOSTA,[NOTLAR],[OZELKOD],[MUHKODU],[EKLEYEN],DURUM,[SUBEID],[GIRISKAYNAK])'+
                            'values('''+Kod+''','''+Ad+''','+Grup+','+Kategori+','+Sinif+','+IlkTemas+','+Sektor+','+IntToStr(TablodanIdGetir('REHBER','FIRMA',Temsilci))+','+Bolge+
                            ','+AltBolge+','+DegerYoksa(Peryot,'0')+','+VarYokGecerli(PostaDgt)+','+VarYokGecerli(EPostaDgt)+','''+Notlar+''','''+Ozelkod+''','''+Muhkodu+''','+Kullanan+',1,-1,1) select scope_identity()',[],[],True);
                      if Notlar <> '' then
                         YorumMedyaEkle(RehId, Tabno_Rehber, Notlar);

                      IletId := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
                          + IntToStr(RehID) + ',''Merkez'',1, 1,-1) select scope_identity()', [], [], True);

                      if VergiDai <> '' then RehberBilgiEkleme(2,RehId,VergiDai,'20');
                      if VergiNo <> '' then RehberBilgiEkleme(2,RehId,VergiNo,'22');
                      if Vade <> '' then RehberBilgiEkleme(2,RehId,Vade,'78');
                      if IsTel <> '' then RehberBilgiEkleme(1,IletId,   IsTel, '40');
                      if Faks <> '' then RehberBilgiEkleme(1,IletId,    Faks, '43');
                      if CepTel <> '' then RehberBilgiEkleme(1,IletId,  CepTel, '42');
                      if Eposta <> '' then RehberBilgiEkleme(1,IletId,  Eposta, '46');
                      if Web <> '' then RehberBilgiEkleme(1,IletId,Web, '48');
                      if Adres <> '' then RehberBilgiEkleme(1,IletId,Adres, '2');
                      if PK <> '' then RehberBilgiEkleme(1,IletId,PK , '4');
                      if Ilce <> '' then RehberBilgiEkleme(1,IletId,Ilce , '6');
                      if Il <> '' then RehberBilgiEkleme(1,IletId,Il , '8');
                      if Ulke <> '' then RehberBilgiEkleme(1,IletId,Ulke , '9');
                      if FirmaUTSNo <> '' then RehberBilgiEkleme(2,RehId, FirmaUTSNo , '140');
                      if FirmaResmiAd <> '' then RehberBilgiEkleme(2,RehId,FirmaResmiAd, '10');
              end;

        end;
     begin
       Kategori:= IniEkle(Ops_CariKart_Kategori, Kategori);
       Sinif:= IniEkle(Ops_CariKart_Sinif, Sinif);
       Sektor:= IniEkle(Ops_CariKart_Sektor, Sektor);
       IlkTemas:= IniEkle(Ops_CariKart_Temas, IlkTemas);
       Bolge:= IniEkle(Ops_CariKart_Bolge, Bolge);
       AltBolge:= IniEkle(StrToInt(IntToStr(Ops_CariKart_Bolge)+Bolge), AltBolge);

//      ModelId := IniEkle(StrToInt(IntToStr(Ops_Demirbas_Marka)+MarkaId), Model);

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then
             CariEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])),
                          Trim(VarToStr(sheet.cells[satir,9])),Trim(VarToStr(sheet.cells[satir,10])),Trim(VarToStr(sheet.cells[satir,11])),Trim(VarToStr(sheet.cells[satir,12])),
                          Trim(VarToStr(sheet.cells[satir,13])),Trim(VarToStr(sheet.cells[satir,14])),Trim(VarToStr(sheet.cells[satir,15])),Trim(VarToStr(sheet.cells[satir,16])),
                          Trim(VarToStr(sheet.cells[satir,17])),Trim(VarToStr(sheet.cells[satir,18])),Trim(VarToStr(sheet.cells[satir,19])),Trim(VarToStr(sheet.cells[satir,20])),
                          Trim(VarToStr(sheet.cells[satir,21])),Trim(VarToStr(sheet.cells[satir,22])),Trim(VarToStr(sheet.cells[satir,23])),Trim(VarToStr(sheet.cells[satir,24])),
                          Trim(VarToStr(sheet.cells[satir,25])),Trim(VarToStr(sheet.cells[satir,26])),Trim(VarToStr(sheet.cells[satir,27])),Trim(VarToStr(sheet.cells[satir,28])),
                          Trim(VarToStr(sheet.cells[satir,29])),Trim(VarToStr(sheet.cells[satir,30])),Trim(VarToStr(sheet.cells[satir,31])));//,Trim(VarToStr(sheet.cells[satir,29])));
      end;
    end;
begin
   ShowMessage(CariAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

///İK AKTARIM
procedure Excel2IK(Potansiyel:Boolean);
var
    i,RehID:integer;

    procedure IKEkle(Kontrol:Boolean;Kod,Ad,TCNo,Cinsiyet,DYeri,Uyrugu,DTarihi,OgrDurumu,Departman,Gorevi,GTarihi,IsTel, CepTel, EvTel,EPosta,Adres,Ilce, Il,	Sube, OzelKod, Notlar, Kull:String);
    var IletId : Integer;

        function Il_Ulke_ID_Getir(s:string) : string;
        begin
              Tablo.TablodanSorguAc(1,'select ILNO from ILLER where ILADI ='''+s+'''' );
              if Tablo.Query1.recordcount>0 then
                 Result := Tablo.Query1.Fields[0].AsString
              else
                 Result := '0';
        end;

        function Rol_ID_Getir : string;
        begin
              Tablo.TablodanSorguAc(1,'SELECT ID FROM ROLLER WHERE DEPARTMAN='+Iniden_Deger_Getir(Ops_Bizim_Departman,Departman)+' AND GOREVID=('+Iniden_Deger_Getir(Ops_Bizim_Gorev,Gorevi)+')' );
              if Tablo.Query1.recordcount>0 then
                 Result := Tablo.Query1.Fields[0].AsString
              else
                 Result := '0';
        end;

        function KontrolIslemi : Boolean;
        begin
          if Kod='' then HataDosyaOlustur(2,'Kod boş');
          if Ad='' then HataDosyaOlustur(2,'Ad boş');
          if TCNo='' then HataDosyaOlustur(2,'TC No boş');
          //if (Cinsiyet<>'')and(Iniden_Deger_Getir(Ops_IK_Cinsiyet, Cinsiyet)='0') then HataDosyaOlustur(2,' Cinsiyet İK da tanımlı değil..');
          if GTarihi='' then HataDosyaOlustur(2,'Giriş Tarihi boş');
          if (GTarihi<>'')and(not TarihGecerli(GTarihi)) then HataDosyaOlustur(2,'Giriş Tarihi Hatalı');
          if (DTarihi<>'')and(not TarihGecerli(DTarihi)) then HataDosyaOlustur(2,'Doğum Tarihi Hatalı');
          if Departman='' then HataDosyaOlustur(2,'Departman boş');
          if Gorevi='' then HataDosyaOlustur(2,'Görevi boş');
          if (OgrDurumu<>'')and(Iniden_Deger_Getir(Ops_IK_Ogrenim, OgrDurumu)='0')then HataDosyaOlustur(2,'Öğrenim Durumu İK da tanımlı değil..');
          if (Uyrugu<>'')and(Il_Ulke_ID_Getir(Uyrugu)='0') then HataDosyaOlustur(2,'Uyruğu İK da tanımlı değil..');
          if (DYeri<>'')and(Il_Ulke_ID_Getir(DYeri)='0')then HataDosyaOlustur(2,'Doğum Yeri İK da tanımlı değil..');
          if Rol_ID_Getir='0' then HataDosyaOlustur(2,'Departman ve Bölüm Hatalı');
          if (Sube<>'')and(TablodanIdGetir('REHBER','FIRMA',Sube)=0) then HataDosyaOlustur(2,'Şube tanımlı değil..');

{          Tablo.TablodanSorguAc(1,'Select DEGER from GENINI where BOLUM='+IntToStr(Ops_CariKart_Grup)+' and ANAHTAR='''+Grup+''' and DIL=-1');
          if Tablo.Query1.RecordCount < 1 then
             HataDosyaOlustur(2,' Grup Caride tanımlı değil..');
          if (Temsilci<>'')and(TablodanIdGetir('REHBER','FIRMA',Temsilci)=0) then HataDosyaOlustur(2,'Temsilci İK ya Eklenmemiş');  }
        end;

        function RehberBilgiEkleme(Yeri,YerId:Integer; Bilgi, Varsayilan:String): Boolean;
        begin
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO REHBERBILGI([YERI],[YER_ID],[SIRA],[ETIKET],[BILGI],EKLEYEN, '+
               ' SUBEID) SELECT YERI='+IntToStr(Yeri)+',YER_ID='+IntToStr(YerId)+',SIRA,ETIKET,BILGI='''+Bilgi+''', EKLEYEN='+Kullanan+
               ', SUBEID=' + IntToStr(SubeId)+ ' FROM REHBERAYAR RA inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO and RV.NO='+Varsayilan+' and RV.YERI=RA.YERI',[], []);
        end;

        function EklemeIslemi : Boolean;
        begin
              if TablodanIdGetir('REHBER','KOD', Kod)>0 then //daha önce eklenmiş uyarı ver
                 HataDosyaOlustur(1,Kod+' '+Ad+' '+'Daha önce eklenmiş')
              else begin //eklenmemiş ekleyelim
                      inc(AktarSay);
                      Cinsiyet := Iniden_Deger_Getir(Ops_IK_Cinsiyet, Cinsiyet);
                      OgrDurumu := Iniden_Deger_Getir(Ops_IK_Ogrenim, OgrDurumu);
                      Uyrugu := Il_Ulke_ID_Getir(Uyrugu);
                      DYeri := Il_Ulke_ID_Getir(DYeri);
                      Departman := Rol_ID_Getir;
                      Sube := IntToStr(TablodanIdGetir('REHBER','FIRMA',Sube));
                      if Sube='0' then Sube:='-1';

                      if DTarihi='' then
                         DTarihi := 'null'
                      else
                         DTarihi := ''''+FormatDateTime('yyyy-mm-dd',StrToDateTime(DTarihi))+'''';

                      RehID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBER([KOD],[FIRMA],[GRUP],[KATEGORI],[SINIF],STATU'+
                            ',DTARIH,[BOLGE],[ALTBOLGE],[NOTLAR],[OZELKOD],[EKLEYEN],DURUM,[SUBEID],[GIRISKAYNAK])'+
                            'values('''+Kod+''','''+Ad+''',335,'+OgrDurumu+','+Departman+','+Cinsiyet+','+DTarihi+','+DYeri+
                            ','+Uyrugu+','''+Notlar+''','''+Ozelkod+''','+Kullanan+',1,-1,8) select scope_identity()',[],[],True);
                      //İşe giriş tarihi
                      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [PERS_HAREKET] (REHBERID,TARIH,TUR,ACIKLAMA)values(&REHBERID,'''+FormatDateTime('yyyy-mm-dd', StrToDateTime(GTarihi))+''' ,&TUR,&ACIKLAMA)'
                        ,['&REHBERID','&TUR','&ACIKLAMA'], [RehId,1, copy(Sube+'/'+Departman+'/'+Gorevi,1,100)]);

                      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into KULLANICI (REHBERID,SIFRE,KOD,ROLID,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID,DIL) values '+
                         '(&Rehber_Id,''AA'',&Kod, &Rol_Id,'+VarYokGecerli(Kull)+',&Ekleyen, getdate(),'+inttostr(SubeID)+',-1)  ', ['&Rehber_Id','&Kod', '&Rol_Id','&Ekleyen'],
                        [RehId, IntToStr(RehId), Departman, StrToInt(Kullanan)]);

                      if Notlar <> '' then
                         YorumMedyaEkle(RehId, Tabno_IK, Notlar);

                      IletId := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('
                          + IntToStr(RehID) + ',''Merkez'',1, 1,-1) select scope_identity()', [], [], True);

                      if TCNo <> '' then// RehberBilgiEkleme(3,IletId,   TCNo, '50');
                         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [REHBERBILGI] (YERI,YER_ID,SIRA,ETIKET,BILGI)values(3,'+IntToStr(RehID)+',22,''T.C.Kmlik No'','''+TCNo +''')',[],[]);
                      if IsTel <> '' then RehberBilgiEkleme(1,IletId,   IsTel, '40');
                      if CepTel <> '' then RehberBilgiEkleme(1,IletId,  CepTel, '42');
                      if EvTel <> '' then RehberBilgiEkleme(1,IletId,  EvTel, '44');
                      if Eposta <> '' then RehberBilgiEkleme(1,IletId,  Eposta, '46');
                      if Adres <> '' then RehberBilgiEkleme(1,IletId,Adres, '2');
                      if Ilce <> '' then RehberBilgiEkleme(1,IletId,Ilce , '6');
                      if Il <> '' then RehberBilgiEkleme(1,IletId,Il , '8');
              end;

        end;
     begin

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then
             IKEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])),
                          Trim(VarToStr(sheet.cells[satir,9])),Trim(VarToStr(sheet.cells[satir,10])),Trim(VarToStr(sheet.cells[satir,11])),Trim(VarToStr(sheet.cells[satir,12])),
                          Trim(VarToStr(sheet.cells[satir,13])),Trim(VarToStr(sheet.cells[satir,14])),Trim(VarToStr(sheet.cells[satir,15])),Trim(VarToStr(sheet.cells[satir,16])),
                          Trim(VarToStr(sheet.cells[satir,17])),Trim(VarToStr(sheet.cells[satir,18])),Trim(VarToStr(sheet.cells[satir,19])),Trim(VarToStr(sheet.cells[satir,20])),
                          Trim(VarToStr(sheet.cells[satir,21])),Trim(VarToStr(sheet.cells[satir,22])));//,Trim(VarToStr(sheet.cells[satir,23])),Trim(VarToStr(sheet.cells[satir,24])),
      end;
    end;
begin
  //ShowMessage(MGAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

///FATURA AKTARIM

procedure Excel2Fatura;
var
    i, RehID, StokId, FatBasID, FatSatID, Fiyat, Satis : integer;
    OncekiFatno, Baslik,Birim, s, RapDoviz,RapDoviz2, TabloBaslik,OncekiTabloBaslik, TabloDetay, BasId,TurAd,OncekiTurAd: String;
    DOVIZKURDEGERI : Real;
    DemID, TutID, TurNo, OncekiTurNo,RehberId, DepoId, MasrafId, Tipi  : Integer;
    MarkaId, ModelId, LokId,GirisId : String[20];

    function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
    begin
      if Tablo.Query0.Locate('TUR', Bolum,[loPartialKey]) then
        result := Tablo.Query0.FieldByName(TLDoviz).AsExtended
      else
        result:=-99999;
    end;

    procedure TOPLAMLAR_UPDATE;
    begin
       if TurNo in [13,17] then //tahakkuksa detay satırı yok, update yok
          exit;
       if OncekiTurAd = 'SIPARIS' then //sipariş ise
          Tablo.TablodanSorguAc(0, 'EXEC SP_PRG_Siparis_DipToplami '+IntToStr(FatBasID))
       else
          Tablo.TablodanSorguAc(0, 'EXEC SP_PRG_FaturaDipToplami '+IntToStr(FatBasID));
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+OncekiTabloBaslik+' set '+OncekiTurAd+'_MATRAHI='+Float_ToStr(ToplamGetir(4,'DEGER'))+','+
       ' [KDV_TUTARI]='+Float_ToStr(ToplamGetir(15,'DEGER'))+','+OncekiTurAd+'_TUTARI='+Float_ToStr(ToplamGetir(20,'DEGER'))+','+
       '[DOVIZ_TUTARI]='+Float_ToStr(ToplamGetir(20,'DOVIZTUTARI'))+' where ID='+ IntToStr(FatBasID),[],[]);
    end;

    procedure FaturaEkle(Kontrol:Boolean;StokHizmet,Tur,FatTarih,FatNo,CariKod,Cari, Depo, Vade, Satici, StokKod,StokAd, Miktar, BFiyat,PBirimi, Isk,KDV,Toplam,
                         DovizBFiyat,DovizPBirimi,DovizToplam, DovizKuru, Aciklama,Personel, Sube,TeslimTarihiData,Pozno :String);

        function BelgeTuruBul(s:String): Integer;
        begin
           Tablo.TablodanSorguAc(1, 'Select TUR From ISLEMTURLERI where AD='''+s+''' ');
           if Tablo.Query1.Recordcount>0 then
              result := Tablo.Query1.Fields[0].AsInteger
           else
              result:=0;
           {if pos('ALIŞ FAT', uppercase(s))>0 then
              Result := 11
           else if pos('SATIŞ FAT', uppercase(s))>0 then
              Result := 15
           else if pos('ALIŞ İRS', uppercase(s))>0 then
              Result := 10
           else if pos('SATIŞ İRS', uppercase(s))>0 then
              Result := 14
           else if pos('ALIŞ FİŞ', uppercase(s))>0 then
              Result := 12
           else if pos('SATIŞ FİŞ', uppercase(s))>0 then
              Result := 16
           else if pos('ALIŞ TAH', uppercase(s))>0 then
              Result := 13
           else if pos('SATIŞ TAH', uppercase(s))>0 then
              Result := 17
           else if pos('VERİLEN SİP', uppercase(s))>0 then
              Result := 9
           else if pos('ALINAN SİP', uppercase(s))>0 then
              Result := 19
           else
              Result := 0  }
        end;

        function DepoGetir(GC : char; DID:Integer): String;
        begin
           case TurNo of
              10,11,12,13,9 : if GC='G' then Result := IntToStr(DID) else result := 'null';
              14,15,16,17,19 : if GC='Ç' then Result := IntToStr(DID) else result := 'null';
           end;
        end;

        function KontrolIslemi : Boolean;
        begin
          if BelgeTuruBul(Tur)=0 then HataDosyaOlustur(2,' Hatalı belge türü');
          if FatTarih='' then HataDosyaOlustur(2,' Fatura Tarihi boş');
          if (FatTarih<>'')and(not TarihGecerli(FatTarih)) then HataDosyaOlustur(2,'Fatura Tarihi Hatalı');
          if (TeslimTarihiData <>'')and(not TarihGecerli(TeslimTarihiData)) then HataDosyaOlustur(2,'Teslim Tarihi Hatalı');
          if FatNo='' then HataDosyaOlustur(2,' Fatura no boş');
          if CariKod='' then HataDosyaOlustur(2,' Cari Kod boş');
          if (CariKod<>'')and(TablodanIdGetir('REHBER','KOD',CariKod)=0) then HataDosyaOlustur(2,'Cari Kod Cari Listesine eklenmemiş Eklenmemiş');

          if (StokKod='')and(not(TurNo in [13,17])) then HataDosyaOlustur(2,'Stok Kod boş');
          if StokKod<>'' then begin
             if VarYokGecerli(StokHizmet)='1' then begin
                  if TablodanIdGetir('STOKLAR','KOD',StokKod)=0 then HataDosyaOlustur(2,'Stok Eklenmemiş')
               end
               else
                  if TablodanIdGetir('MASRAFGELIR','KOD',StokKod)=0 then HataDosyaOlustur(2,'Masraf/Gelir Eklenmemiş');
          end;
          if (Miktar='')and(not(TurNo in [13,17])) then HataDosyaOlustur(2,' Miktar boş');
          if (BFiyat<>'')and(not FiyatGecerli(BFiyat))  then HataDosyaOlustur(2,'  BirimFiyat Hatalı');
          if (KDV='')and(not(TurNo in [13,17])) then HataDosyaOlustur(2,' KDV boş');
          if (DovizBFiyat<>'')and(not FiyatGecerli(DovizBFiyat))  then HataDosyaOlustur(2,'  BirimFiyat Hatalı');
          if (Satici<>'')and(TablodanIdGetir('REHBER','FIRMA',Satici)=0) then HataDosyaOlustur(2,'Satici, İK ya eklenmemiş.');
          if (Personel<>'')and(TablodanIdGetir('REHBER','FIRMA',Personel)=0) then HataDosyaOlustur(2,'Personel, İK ya eklenmemiş.');
        end;

        procedure DovizdenTLye;
        begin//dolar ise
            if DovizKuru<>'' then
               DOVIZKURDEGERI := StrToFloat(DovizKuru)
            else
               DOVIZKURDEGERI := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', StrToDateTime(FatTarih)), DovizPBirimi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));

            BFiyat:= FloatToStr(StrToFloat(DovizBFiyat)*DOVIZKURDEGERI);
            if PBirimi='' then
               PBirimi := CariDoviz;
        end;

        function EklemeIslemi : Boolean;
        var TeslimTarihiBas : String[25];
            RehberIletId : integer;
        begin
            inc(AktarSay);
            if DovizPBirimi='' then
               DovizPBirimi:=CariDoviz;
            if TurNo in [9,19] then begin
               TabloBaslik := 'SIPARIS';
               TabloDetay := 'SIPARISDETAY';
               BasId := 'SIPARISID';
               TurAd :='SIPARIS';
               RapDoviz:='';
               RapDoviz2:='';
               TeslimTarihiBas := ',TESLIMTARIHI';
               //TeslimTarihiData :=',null';
            end else begin
               TabloBaslik := 'FATBASLIK';
               TabloDetay := 'FATURA';
               BasId := 'FATBASID';
               TurAd := 'FATURA';
               RapDoviz:='RAPORDOVIZ,EKSTREDEKULLAN,';
               RapDoviz2:=''''+DovizPBirimi+''',0,';
               TeslimTarihiBas := '';
               TeslimTarihiData :='';
            end;

            Sube := IntToStr(TablodanIdGetir('REHBER','FIRMA',Sube));
            RehberId := TablodanIdGetir('REHBER','KOD',CariKod);
            Satici := IntToStr(TablodanIdGetir('REHBER','FIRMA',Satici));
            Personel := IntToStr(TablodanIdGetir('REHBER','FIRMA',Personel));

            if VarYokGecerli(StokHizmet)='1' then begin
               StokId := TablodanIdGetir('STOKLAR','KOD',StokKod);
               MasrafId := 0;
               Tablo.TablodanSorguAc(1,' select ANABIRIM from STOKLAR where ID='+IntToStr(StokId));
               Birim := Tablo.Query1.Fields[0].AsString;
               Tipi:=1;
            end else begin
               StokId := TablodanIdGetir('MASRAFGELIR','KOD',StokKod);
               MasrafId := StokId;
               Birim := '51';
               Tipi := 0;
            end;

            if Sube='0' then Sube:='-1';
               Sube:='-1';
            if Turno in [10,11,12,13] then begin
               Fiyat :=VarsAlisFiyatID ;
               Satis:=0
            end else begin
               Fiyat := VarsSatisFiyatID;
               Satis:=1;
            end;
            if PozNo='' then
               Pozno:='null';
            DOVIZKURDEGERI:=1;
            if (BFiyat='')and(DovizBFiyat='') then begin//hiç fiyat girilmediyse fiyat listesinden g
               Tablo.TablodanSorguAc(1,' select * from [fn_UrunFiyati] ('+VarYokGecerli(StokHizmet)+','+IntToStr(StokId)+','+Birim+','+
                    IntToStr(RehberId)+','+IntToStr(Satis)+','+Sube+')');
               if Tablo.Query1.FieldByName('KUR').AsString<>CariDoviz then
                  DovizdenTLye
               else begin
                   BFiyat:=Tablo.Query1.FieldByName('BIRIMFIYAT').AsString;
                   PBirimi := Tablo.Query1.FieldByName('KUR').AsString;
               end;
            end
            else if DovizBFiyat<>'' then //dövizli fiyat varsa
                 DovizdenTLye;

            BFiyat := DegerYoksa(BFiyat, '0.0');
            PBirimi := DegerYoksa(PBirimi, CariDoviz);
            if DovizBFiyat='' then
               DovizBFiyat := BFiyat;
            if DovizPBirimi='' then
               DovizPBirimi := PBirimi;
            if Isk = '' then
               Isk := '0.0';

            Toplam      := FloatToStr((100.0-StrToFloat(Isk)) * StrToFloat(FiyatDuzenle(Miktar, False)) * StrToFloat(FiyatDuzenle(BFiyat, False)) / 100.0 );
            DovizToplam := FloatToStr((100.0-StrToFloat(Isk)) * StrToFloat(FiyatDuzenle(Miktar, False)) * StrToFloat(FiyatDuzenle(DovizBFiyat, False)) / 100.0 );

            if (FatNo<>OncekiFatno)or(TurNo<>OncekiTurNo)or(TurNo in [13,17]) then begin //Yeni fatura başlığı     //tahakuksa her satıra
               if OncekiFatno<>'' then
                  TOPLAMLAR_UPDATE;
               //Depo
               DepoId := TablodanIdGetir('DEPOLAR','DEPOADI', Depo);
               if DepoId = 0 then
                  DepoId := VarsDepo;
               //Fatura başlık bilgileri
               Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 ');
               TabloYenile(Tablo.tabCariBilgileri, [RehberId, Tablo.Query1.Fields[0].AsInteger]);
               Baslik := Tablo.tabCariBilgileri.FieldByName('FATURABASLIK').AsString;
               if Baslik = '' then begin // eğer ticari bilgiler kısmında başlık yoksa firma adını alsın
                  Tablo.TablodanSorguAc(2, 'select ID, FIRMA from REHBER where ID=' + IntToStr(RehberId));
                  Baslik := Tablo.Query2.FieldByName('FIRMA').AsString;
               end;
               //Fatura başlığı insert
               //if TurNo in [13,17] then //tahakkuksa detay satırı yok, toplamı burada direkt veriyoruz
               //   GenelToplam := Toplam
               DovizKuru := FloatToStr(DOVIZKURDEGERI);
               Tablo.TablodanSorguAc(1,'select ID  from REHBERILETISIM where VARSAYILAN = 1 and REHBERID='+IntToStr(RehberId));
               RehberIletId := Tablo.Query1.Fields[0].AsInteger;
               FatBasID:= Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO '+ TabloBaslik +
                      ' ([TUR],[TIPI],[REHBERID],TARIH,'+TurAd+'TARIH ,[KOCANNO],'+TurAd+'NO,[GIRISDEPO],[CIKISDEPO],[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[ACIK_KAPALI]'+
                      ' ,'+TurAd+'_MATRAHI,[KDV_TUTARI],'+TurAd+'_TUTARI,[KUR],'+RapDoviz+'[DOVIZ_TUTARI],[DOVIZ_CINSI],DOVIZKUR,[MASRAFID]'+
                      ' ,[ACIKLAMA],[SATICIKODU],[DURUM],OZELKOD,[EKLEYEN],[FIYAT_LISTESI],VADE,GIRISKAYNAK,SUBEID,REHBERILETID )values '+
                      ' ('+IntToStr(TurNo)+',1,'+IntToStr(RehberId)+','''+FormatDateTime('yyyy-mm-dd hh:nn', StrToDateTime(FatTarih))+''','''+FormatDateTime('yyyy-mm-dd hh:nn', StrToDateTime(FatTarih))+''',null,'''+
                      FatNo+''','+DepoGetir('G', DepoId)+','+DepoGetir('Ç', DepoId)+','''+Baslik+''','+
                      ''''+Tablo.TabCariBilgileri.FieldByName('ADRES').AsString+''','''+Tablo.TabCariBilgileri.FieldByName('ILCE').AsString+''','''+Tablo.TabCariBilgileri.FieldByName('IL').AsString+''','+
                      ''''+Tablo.TabCariBilgileri.FieldByName('VERGIDAI').AsString+''','''+Tablo.TabCariBilgileri.FieldByName('VERGINO').AsString+''',''Hariç'',0,'+
                      FiyatDuzenle(Toplam)+',0,'+FiyatDuzenle(Toplam)+','''+CariDoviz+''','+RapDoviz2+FiyatDuzenle(Toplam)+','+
                      ''''+CariDoviz+''','+FiyatDuzenle(DovizKuru)+','+IntToStr(MasrafId)+','''','+DegerYoksa(Satici,'null')+',1,null,'+Kullanan+','+IntToStr(Fiyat)+','+DegerYoksa(Vade,'0')+','+IntToStr(Windows_Excelden)+','+Sube+','+IntToStr(RehberIletId)+') SELECT SCOPE_IDENTITY() ', [], [], True);
               OncekiFatno := FatNo;
               OncekiTurNo := TurNo;
               OncekiTabloBaslik := TabloBaslik;
               OncekiTurAd := TurAd;
            end;

            //Fatura Satırı
            if not (TurNo in [13,17]) then //tahakkuksa detay satırı yok
               if TeslimTarihiData<>'' then
                  TeslimTarihiData := ','''+FormatDateTime('yyyy-mm-dd', StrToDateTime(TeslimTarihiData))+''''
               else
                  TeslimTarihiData := ',null';
               FatSatID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' INSERT INTO '+TabloDetay+' ('+BasId+',[REHBERID],[SEC],[TUR],[URUNID],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],[BIRIMFIYAT]'+
                    ' ,[TUTAR] ,[ISKONTO],[ISKONTO2],[KDV],[MASRAFID],[OZELKOD],[MUHKODU],[EKLEYEN],[KUR],[IZLEMEKODU],DOVIZKURDEGERI,DOVIZ_BIRIMFIYAT,[DOVIZ_TUTARI],[DOVIZ_KURU],'+
                    ' SATICIKODU,[IZLEME],[YERI],[YERID],GIRISKAYNAK,[SUBEID],POZNO'+TeslimTarihiBas+') values ('+IntToStr(FatBasID)+','+IntToStr(RehberId)+' ,0,'+IntToStr(Tipi)+','+IntToStr(StokId)+
                    ','''+Aciklama+''','+FiyatDuzenle(Miktar)+','+Birim+','+FiyatDuzenle(Miktar)+','+FiyatDuzenle(BFiyat)+','+FiyatDuzenle(Toplam)+','+FiyatDuzenle(Isk)+',0,'+DegerYoksa(KDV, IntToStr(KDVOrani))+
                    ',-1,null,null,'+Kullanan+','''+DegerYoksa(PBirimi, CariDoviz)+''',null,'+FiyatDuzenle(DovizKuru)+','+FiyatDuzenle(DovizBFiyat)+','+
                    FiyatDuzenle(DovizToplam)+','''+DegerYoksa(DovizPBirimi, CariDoviz)+''','+DegerYoksa(Personel,'null')+',null,null,null,'+IntToStr(Windows_Excelden)+','+Sube+','+PozNo+TeslimTarihiData+') SELECT SCOPE_IDENTITY() ', [], [], True);

        end;
     begin

      TurNo := BelgeTuruBul(Tur);
      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
       OncekiFatno:='';
       OncekiTurNo:=-1;
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then
             FaturaEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])),
                          Trim(VarToStr(sheet.cells[satir,9])),Trim(VarToStr(sheet.cells[satir,10])),Trim(VarToStr(sheet.cells[satir,11])),Trim(VarToStr(sheet.cells[satir,12])),
                          Trim(VarToStr(sheet.cells[satir,13])),Trim(VarToStr(sheet.cells[satir,14])),Trim(VarToStr(sheet.cells[satir,15])),Trim(VarToStr(sheet.cells[satir,16])),
                          Trim(VarToStr(sheet.cells[satir,17])),Trim(VarToStr(sheet.cells[satir,18])),Trim(VarToStr(sheet.cells[satir,19])),Trim(VarToStr(sheet.cells[satir,20])),
                          Trim(VarToStr(sheet.cells[satir,21])),Trim(VarToStr(sheet.cells[satir,22])),Trim(VarToStr(sheet.cells[satir,23])),Trim(VarToStr(sheet.cells[satir,24])),
                          Trim(VarToStr(sheet.cells[satir,25])),Trim(VarToStr(sheet.cells[satir,26])));
      end;
      if not Kontrol then //bitti son faturanın toplamları
         TOPLAMLAR_UPDATE;
    end;
begin
  //ShowMessage(MGAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;

function Excel2PDKS:TDateTime;
var
    i,RehberId,BaslaSat,TarihSat,TarihSut,AdSut,SoyadSut,GirSut,CikSut,AcikSut : integer;
    Tarih : String;

    procedure SatSutBilgisiAl;
        function InidenVeriAl(BolumNo:integer; Etiket:String):integer;
        var Deger : Variant;
        begin
          Result := Tablo.GENINI.ReadInteger(BolumNo, -1);
          if Result = -1 then begin
             if TGirisKutusuEx.BilgiAlEx(Etiket, TGirdiDenetimleri.Create.Edit(Etiket +':' , @Deger)) = mrOk then begin
                Result := StrToIntDef(VarToStr(Deger), -1);
                Tablo.GENINI.WriteInteger(BolumNo, Result);
             end else
                Abort;
          end;

        end;
    begin
        BaslaSat:=InidenVeriAl(PDKS_BaslaSat,'Başlama Satır No');
        TarihSat:=InidenVeriAl(PDKS_TarihSat,'Tarih Satır No');
        TarihSut:=InidenVeriAl(PDKS_TarihSut,'Tarih Sütun No');
        AdSut:=InidenVeriAl(PDKS_AdSut,'Ad Sütun No');
        SoyadSut:=InidenVeriAl(PDKS_SoyadSut,'Soyad Sütun No');
        GirSut:=InidenVeriAl(PDKS_GirSut,'Giriş Saati Sütun No');
        CikSut:=InidenVeriAl(PDKS_CikSut,'Çıkış Saati Sütun No');
        AcikSut:=InidenVeriAl(PDKS_AcikSut,'Açıklama Sütun No');
    end;

    procedure PDKSEkle(Kontrol:Boolean;Ad,Soyad,Giris,Cikis,Aciklama:String);
    var
        MarkaId, ModelId, LokId,GirisId, GirTarih, CikTarih, DurumId: String[20];

        function KontrolIslemi : Boolean;
        begin
          if Ad='' then HataDosyaOlustur(2,'Ad boş');
          if SoyAd='' then HataDosyaOlustur(2,'Soyad boş');

         if TablodanIdGetir('REHBER', 'GRUP=335 and FIRMA', Ad+' '+SoyAd)=0 then
             HataDosyaOlustur(2,'Bu Ad Soyad ile personel bulunmadı!');
        end;
        function EklemeIslemi : Boolean;
          function TarihBul(Trh:string; Sut:integer):string;
          begin
            if Trh = '' then begin
               if Sut=CikSut then //çıkış tarihi ise null olsun
                  Result := 'null'
               else
                  Result := ''''+FormatDateTime('yyyy-mm-dd hh:nn', StrToDateTime(Tarih))+''''
            end else if pos('0.', Trh)=1 then //excelde tarih formatlı tutuluyorsa
               Result := ''''+FormatDateTime('yyyy-mm-dd', StrToDateTime(Tarih))+' '+FormatDateTime('hh:nn', VarToDateTime(sheet.cells[satir, Sut]))+''''
            else if pos(':', Giris)>3 then  //  12.05.2018 09:55:23 gibidir o zaman direk tarihi alırız
               Result := ''''+FormatDateTime('yyyy-mm-dd hh:nn', StrToDateTime(Trh))+''''
            else
               Result := ''''+FormatDateTime('yyyy-mm-dd hh:nn', StrToDateTime(Tarih+' '+Trh))+'''';
          end;
        begin
            RehberId := TablodanIdGetir('REHBER', 'GRUP=335 and FIRMA', Ad+' '+SoyAd);
            GirTarih := TarihBul(Giris, GirSut);
            CikTarih := TarihBul(Cikis, CikSut);
            Aciklama := copy(Aciklama,1,40);//ilk 40 karakteri alalım
            Aciklama := StringReplace(VarToStr(Aciklama),'''','',[rfReplaceAll]);//kesme işareti varsa kaldıralım
            if Giris<>'' then //giriş saati varsi gelmiş demektir
               DurumId:='1'
            else begin
               DurumId := Iniden_Deger_Getir( Ops_CariKart_PDKSDurum, Aciklama);
               if DurumId = '0' then
                  DurumId := '2';
            end;
            Tablo.TablodanSorguAc(1 ,'SELECT ID FROM PERS_PDKS where REHBERID='+IntToStr(RehberId)+' and GIRIS='+GirTarih);
            if Tablo.Query1.RecordCount>0 then //varsa değişsin
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PERS_PDKS set GIRIS='+GirTarih+',CIKIS='+CikTarih+
                ',DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI=getDate(),DURUM='+DurumId+',ACIKLAMA='''+Aciklama+''' where ID='+Tablo.Query1.Fields[0].AsString,[],[])
            else
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PERS_PDKS (REHBERID,KARTNO,GIRIS,CIKIS,EKLEYEN,SUBEID,DURUM,ACIKLAMA,MUHAKTAR) values('+
                  IntToStr(RehberId)+',0,'+GirTarih+','+CikTarih+','+Kullanan+','+IntToStr(SubeId)+','+ DurumId +','''+Aciklama+''',0) ',[],[]);
            inc(AktarSay);
        end;
     begin
      //MarkaId := IniEkle(Ops_Demirbas_Marka, Marka);
      //ModelId := IniEkle(StrToInt(IntToStr(Ops_Demirbas_Marka)+MarkaId), Model);

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';

       Tarih := Trim(VarToStr(sheet.cells[TarihSat, TarihSut]));
       if Tarih='' then HataDosyaOlustur(2,' Giriş Tarihi boş');
       Tarih := copy(Tarih, 1, 10);

       for satir := BaslaSat to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir, AdSut]) <> '' then
             PDKSEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,AdSut])),Trim(VarToStr(sheet.cells[satir,SoyadSut])),
                      Trim(VarToStr(sheet.cells[satir,GirSut])),Trim(VarToStr(sheet.cells[satir,CikSut])),Trim(VarToStr(sheet.cells[satir,AcikSut])));
      end;
    end;
begin
  //ShowMessage(MGAktarimkosullari);
   SatSutBilgisiAl;
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
   Result := StrToDateTimeDef(Tarih, Tablo.GENINI.BugunTrh);
end;

procedure Excel2UTS_Urun;
var
    i,RehID:integer;

  procedure UTSEkle(KURUM_ADI,KURUM_UTS_NO,STOKKOD,URUNNO,SERINO,LOTNO,ADET,FIYAT,URT,SKT:String);
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into UTSENVANTER(KURUM_ADI,KURUM_UTS_NO,STOKKOD,URUNNO,SERINO,LOTNO,ADET,FIYAT,PARABIRIM,GELENURT,GELENSKT)'+
       ' values ('''+KURUM_ADI+''','''+KURUM_UTS_NO+''','''+STOKKOD+''','''+URUNNO+''','''+SERINO+''','''+LOTNO+''','+ADET+','+FiyatDuzenle(FIYAT)+','''+CariDoviz+''','''+
          FormatDateTime('yyyy-mm-dd', StrToDateTime(URT))+''','''+FormatDateTime('yyyy-mm-dd', StrToDateTime(SKT))+''')',[],[]);
       inc(AktarSay);
    end;
begin
  ShowMessage(UTSUrunAktarimkosullari);
  AktarSay := 0;
   if ExcelBaslat then begin
      for satir := 2 to excelsonsatir(1)+1 do begin

        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;

        if VarToStr(sheet.cells[satir,1]) <> '' then begin
           UTSEkle(VarToStr(sheet.cells[satir,1]),VarToStr(sheet.cells[satir,2]),VarToStr(sheet.cells[satir,3]),VarToStr(sheet.cells[satir,4]),VarToStr(sheet.cells[satir,5]),
                   VarToStr(sheet.cells[satir,6]),VarToStr(sheet.cells[satir,7]),VarToStr(sheet.cells[satir,8]),VarToStr(sheet.cells[satir,9]),VarToStr(sheet.cells[satir,10]));
        end;

      end;
      ExcelBitir;
  end;
end;

procedure Excel2FaturaSatir(FatSatirID : Integer);
var
    i,RehID:integer;

  procedure Kontrol_Ekle(Kontrol : boolean; STOKKOD,URUNNO,ACIKLAMA,ADET,SERINO,LOTNO,URT,SKT, BIRIMFIYAT:String);
    var  JSONObj : TJSONObject;
         ID, JSONString : string;                                         //  BIRIM

    function KontrolIslemi : Boolean;
        begin
          if (STOKKOD='')and(URUNNO='') then HataDosyaOlustur(2,'STOKKOD ve URUNNO en az biri dolu olmal�');
          if (STOKKOD<>'')and(TablodanIdGetir('STOKLAR','KOD',STOKKOD)=0) then HataDosyaOlustur(2,'Stok Eklenmemi�');
//          if (STOKKOD='')and(URUNNO<>'')and(TablodanIdGetir('STOKLAR','KOD',URUNNO)=0) then HataDosyaOlustur(2,'Stok Eklenmemi�');
          if (STOKKOD='')and(URUNNO<>'') then begin
              Tablo.TablodanSorguAc(1, 'select ID from STOKLAR where  URUNNO ='+ URUNNO);
              if Tablo.Query1.REcordCount < 1 then HataDosyaOlustur(2,'Stok Eklenmemi�')
              else if Tablo.Query1.REcordCount > 1 then HataDosyaOlustur(2,'Bu �r�nno dan birden fazla stok kart� var');
          end;

          if (SERINO='')and(LOTNO='') then HataDosyaOlustur(2,'SERINO ve LOTNO en az biri dolu olmal�');
          if ADET='' then HataDosyaOlustur(2,'ADET dolu olmal�');
          //if BIRIM='' then HataDosyaOlustur(2,'BIRIM dolu olmal�');
          if (URT='')and(SKT='') then HataDosyaOlustur(2,'URT ve SKT dolu olmal�');
          if (URT<>'')and(not TarihGecerli(URT)) then HataDosyaOlustur(2,'URT Tarihi Hatal�');
          if (SKT<>'')and(not TarihGecerli(SKT)) then HataDosyaOlustur(2,'SKT Tarihi Hatal�');
        end;

    function EklemeIslemi : Boolean;
    begin
        JSONObj := TJSONObject.Create;

     // JSON olu�tur

        if (STOKKOD<>'') then
            ID := IntToStr(TablodanIdGetir('STOKLAR','KOD',STOKKOD))
        else if (URUNNO<>'') then
            ID := IntToStr(TablodanIdGetir('STOKLAR','URUNNO',URUNNO));

        JSONObj.AddPair('ID', ID);
    //    JSONObj.AddPair('KOD', STOKKOD);
    //    JSONObj.AddPair('URUNNO', URUNNO);
        JSONObj.AddPair('ACIKLAMA', ACIKLAMA);
        JSONObj.AddPair('ADET', IntToStr(StrToIntDef(ADET,0)));
    //    JSONObj.AddPair('BIRIM', BIRIM);
        if BIRIMFIYAT='' then
           BIRIMFIYAT := '0.0'
        else
           BIRIMFIYAT := StringReplace(BIRIMFIYAT, ',', '.', [rfReplaceall]);
        JSONObj.AddPair('BIRIMFIYAT', BIRIMFIYAT);
        JSONObj.AddPair('SERINO', SERINO);
        JSONObj.AddPair('LOTNO', LOTNO);
        JSONObj.AddPair('URT', FormatDateTime('yyyy-mm-dd', StrToDateTimeDef(URT, TDateTime(32874))));
        JSONObj.AddPair('SKT', FormatDateTime('yyyy-mm-dd', StrToDateTimeDef(SKT, TDateTime(32874))));

        JSONString := JSONObj.ToJSON;

        // SP'yi �a��r
        //CallStoredProcedure(JSONString);
        Tablo.Query1.SQL.Text :=   //'EXEC  sp_Prog_Irs_Fat_Satir_Giris ' + IntToStr(FatSatirID)+','+ JSONString;
           ' DECLARE @SONUC_ID INT, @SONUC_MESAJ VARCHAR(5000);  '+

           ' EXEC dbo.sp_Prog_Irs_Fat_Satir_Ekleme '+
           '      @FATBASID = '+IntToStr(FatSatirID)+','+
           '      @jsonData = '''+JSONString+''','+
           '      @SONUC_ID = @SONUC_ID OUTPUT,      '+
           '      @SONUC_MESAJ = @SONUC_MESAJ OUTPUT '+

           ' SELECT @SONUC_ID AS SONUC_ID, @SONUC_MESAJ AS SONUC_MESAJ ';

        Tablo.Query1.Open;
        inc(AktarSay);
        JSONObj.Free;
    end;

    begin
    //  MarkaId := IniEkle(Ops_Demirbas_Marka, Marka);
    //  ModelId := IniEkle(StrToInt(IntToStr(Ops_Demirbas_Marka)+MarkaId), Model);

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    var STOKKOD,URUNNO,ACIKLAMA,ADET,BIRIM,SERINO,LOTNO,URT,SKT,BIRIMFIYAT : integer;
    begin
       DosyaAdi := '';
       for satir := 2 to excelsonsatir(1)+1 do begin

        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;
        STOKKOD :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'KOD', 3);
        URUNNO  :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'URUNNO',   4);
        ACIKLAMA:=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'ACIKLAMA',6);
        ADET    :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'ADET',    7);
        //BIRIM   :=  Tablo.GENINI.ReadInteger(Ops_Fatura_ExcelEslesme, 0, 'BIRIM',   7);
        BIRIMFIYAT :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme,-1, 'BIRIMFIYAT', 9);
        SERINO  :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'SERINO',  10);
        LOTNO   :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'LOTNO',   11);
        URT     :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'URT',     12);
        SKT     :=  Tablo.GENINI.DegerGetir(Ops_Fatura_ExcelEslesme, -1, 'SKT',     13);


        if (VarToStr(sheet.cells[satir,1]) <> '')and(VarToStr(sheet.cells[satir,2]) <> '') then begin
           Kontrol_Ekle(Kontrol, VarToStr(sheet.cells[satir,STOKKOD]),VarToStr(sheet.cells[satir,URUNNO]),
           VarToStr(sheet.cells[satir,ACIKLAMA]),
           VarToStr(sheet.cells[satir,ADET]),//VarToStr(sheet.cells[satir,BIRIM]),
           VarToStr(sheet.cells[satir,SERINO]),VarToStr(sheet.cells[satir,LOTNO]),
           VarToStr(sheet.cells[satir,URT]),VarToStr(sheet.cells[satir,SKT]),
           VarToStr(sheet.cells[satir,BIRIMFIYAT]));
        end;

       end;
    end;

//ANA PRG
begin
  //ShowMessage(UTSUrunAktarimkosullari);
   AktarSay := 0;
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaral�m
      if DosyaAdi='' then // dosya olu�mad�ysa hata yok demektir
         AktarmaIslemi(False);
      ExcelBitir;
  end;
end;

(*///�ABLON AKTARIM

procedure Excel2Mod�l;
var
    i,RehID:integer;

    procedure Mod�lEkle(Kontrol:Boolean;Kod,Ad,Marka,Model,Serino,Lokasyon,GTarih,GirisSekli,Cari,ZTarih,ZSahibi,ServisSorumlu,ServisBlgi:String);
    var DemID, TutID : Integer;
        MarkaId, ModelId, LokId,GirisId : String[20];


        function KontrolIslemi : Boolean;
        begin
          if Ad='' then HataDosyaOlustur(2,'Ad boş');
          if GTarih='' then HataDosyaOlustur(2,' Giriş Tarihi boş');
        end;
        function EklemeIslemi : Boolean;
        begin
            inc(AktarSay);
            //zimmet
            if ZSahibi<>'' then begin
               TutID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS_TUTANAK (TIP, TARIH, VERENID, ALANID, LOKASYONID,EKLEYEN, EKLEMETARIHI, REHBERID) values('+
                  '21,'''+FormatDateTime('yyyy-mm-dd', StrToDateTime(ZTarih))+''',0,'+IntToStr(TablodanIdGetir('REHBER','FIRMA',ZSahibi))+','+LokId+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',0) select scope_identity()',[],[],True);
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DEMIRBAS_TUTANAK_DETAY (TUTANAKID, DEMIRBASID)values('+IntToStr(TutId)+','+IntToStr(DemId)+')',[],[]);
            end;
        end;
     begin
      MarkaId := IniEkle(Ops_Demirbas_Marka, Marka);
      ModelId := IniEkle(StrToInt(IntToStr(Ops_Demirbas_Marka)+MarkaId), Model);

      if Kontrol then
         KontrolIslemi
      else
         EklemeIslemi;
    end;

    function AktarmaIslemi(Kontrol:Boolean) : Boolean;
    begin
       DosyaAdi := '';
      for satir := 2 to excelsonsatir(1)+1 do begin
          BekletmeDlg.cxProgressBar1.Position := satir;
          BekletmeDlg.cxProgressBar1.Refresh;

          if VarToStr(sheet.cells[satir,2]) <> '' then
             ModümEkle(Kontrol, Trim(VarToStr(sheet.cells[satir,1])),Trim(VarToStr(sheet.cells[satir,2])),Trim(VarToStr(sheet.cells[satir,3])),Trim(VarToStr(sheet.cells[satir,4])),
                          Trim(VarToStr(sheet.cells[satir,5])),Trim(VarToStr(sheet.cells[satir,6])),Trim(VarToStr(sheet.cells[satir,7])),Trim(VarToStr(sheet.cells[satir,8])));
      end;
    end;
begin
  //ShowMessage(MGAktarimkosullari);
   if ExcelBaslat then begin
      AktarmaIslemi(True); //kontrol edelim sorun yoksa aktaralım
      if DosyaAdi='' then // dosya oluşmadıysa hata yok demektir
         AktarmaIslemi(False);
     ExcelBitir;
   end;
end;
    *)

end.



