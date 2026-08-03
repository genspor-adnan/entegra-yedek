unit UIsListesi;
interface

uses cxCalendar, cxDateUtils, sysutils,variants, cxTimeEdit,cxCheckBox, cxTextEdit,cxScheduler,
cxSchedulerStorage, cxSchedulerCustomControls, cxSchedulerCustomResourceView,
  cxSchedulerDayView, cxSchedulerDateNavigator, cxSchedulerHolidays, cxDBTL,
  cxSchedulerTimeGridView, cxSchedulerUtils, cxSchedulerWeekView, cxSchedulerTreeListBrowser,
  cxSchedulerYearView, cxSchedulerGanttView, System.Generics.Collections,
  dxSkinscxSchedulerPainter, cxSchedulerDBStorage, system.Classes , Menus, cxGridDBTableView,
FetaKurulusSiniflari,UTablo,UGenNotificationUtils, MMSystem, cxRichEdit, Data.DB, vcl.ComCtrls ;

const
  Masaustu = -27; Bugun=-24;  Onayla =-21;  BanaAtananlar=-18;  Atadiklarim=-15; Atanmamislar=-12;  Bayrakli = -9; ToplantiKlasor=-7; Servis=-6;DemirbasKlasor=-5; TumListe=-3;
var
  AtamaYapildi, YorumYapildi, OnaySistemiAktif : Boolean;
  EpostaAlicilar, EPostaAlicilarCC : TList<TEpostaAlici>;
  AktifMail,VarsayDurumYeni, VarsayDurumSonOnay, VarsayDurumSonRed, VarsayDurumSon : Smallint;
  AktifGorevId, AktifRehberId  : Integer;

function PlayWavFromResource(ResID: PChar): Boolean;
function Gorev_EPostaGonder(KonuTur, GorevId:Integer; FormAc:Boolean=False) : boolean;
function  YeniGorevEkle(TabGorevler : TDataSet; ListeId,ProjeId:Integer; YeniGorevEdit : TcxTextEdit; Key:Word;
          DateEdit1:TcxDateEdit; TimeEdit1:tcxTimeEdit;CheckBAYRAK:TcxCheckBox;CariId:integer=0;PersonelId:integer=0; GorevTuru:integer=0; Yer:integer=0; YerId:integer=0):Integer;
Function GorevUpdate(ID:Integer; Komut : String):Boolean;
Function ServisUpdate(ID:Integer; Komut : String):Boolean;
procedure Menu_Duzenle(Sender: TObject; TabGorevler:TDataSet; Scheduler:TcxScheduler=nil);
procedure UpdateveMail(AktifListe, ListeId, GorevId, Ekleyen:Integer; AcKapa,AltGorevVar : Boolean);
procedure Menu_Tamam(Sender: TObject; View1 : TcxGridDBTableView; Scheduler:TcxScheduler=nil; AktifListe:Smallint=0);
procedure Menu_Bayrak(Sender: TObject; View1 :TcxDBTreeList; Scheduler:TcxScheduler=nil);


implementation

uses UGorevDlg,UGorevListeDlg, UBinarySave, Vcl.Dialogs, UAnaForm, UVeriMotor;

function PlayWavFromResource(ResID: PChar): Boolean;
var buffer: array[0..2] of char;
    hFind, hRes: THandle;
    Song: PChar;
begin
    hFind := FindResource(HInstance, ResID, 'WAVE') ;
    if hFind <> 0 then begin
       hRes:=LoadResource(HInstance, hFind) ;
       if hRes <> 0 then begin
          Song:=LockResource(hRes) ;
          if Assigned(Song) then
             SndPlaySound(Song, snd_ASync or snd_Memory) ;
          UnlockResource(hRes) ;
       end;
    end;
    FreeResource(hFind) ;
   //başka ses varsa dursun
//   buffer[0] := #0;
//   PlaySound(Buffer, 0, SND_PURGE);
   //sonra bizimki çalsın
   //Result := PlaySound(PChar('#' + 'Blink'), HInstance, SND_RESOURCE or SND_ASYNC);
end;

Function GorevUpdate(ID:Integer; Komut : String):Boolean;
 begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update GOREVLER set '+Komut+' where ID='+IntToStr(ID),[],[]);
 end;

 Function ServisUpdate(ID:Integer; Komut : String):Boolean;
 begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SERVIS set '+Komut+' where ID='+IntToStr(ID),[],[]);
 end;

function Gorev_EPostaGonder(KonuTur, GorevId:Integer; FormAc:Boolean=False): Boolean;
var
   Konu, KimdenAdr, KimeAdr,BilgiAdr, AtacDosya, RaporAdi, SonucMesaj, DosyaAdi,s, Trh : string;
   gmail : dmailadresleri;
   Body : TStringStream;
   EkDosya:TList<string>;
   YorumEkleyen,RehId : integer;
   stream2: TStream;
   GlobalRichEdit: TcxRichEdit;

   function HTML_Dosya : String;
   var  dosyaadi : string;
   begin
        dosyaadi := GetEnvironmentVariable('Temp')+'\Temp0099.html';
        Body.SaveToFile(dosyaadi);
        result := dosyaadi;
   end;

   procedure MailAdresiSor;
   var i, AliciTur, Sahibi : integer;
       SahibiAd : String[50];
   begin
       //Default alıcılar
       KimeAdr:='';BilgiAdr:='';
       AliciTur := 12;
       Sahibi := StrToInt(Kullanan);
       SahibiAd := KullanAdi;
       if KonuTur=3 then begin //eğer yorum yapıldıysa ve yorum yapan görev sahibi değilse, görev sahibine direkt mail diğerleri cc olacak
          Tablo.TablodanSorguAc(8, 'select '+DbUst(1)+'EKLEYEN from GOREVLER where ID='+IntToStr(GorevId)+' order by ID desc '+DbSinir(1));
          if Kullanan <> Tablo.Query8.Fields[0].AsString then
             AliciTur := 11;
             Sahibi := Tablo.Query8.Fields[0].AsInteger;
             SahibiAd := Tablo.AciklamaGetir('REHBER', 'FIRMA', Sahibi);
       end;

       Tablo.TablodanSorguAc(7, 'select REHBERID, R.FIRMA,GK.EKLEYEN,GK.TUR from GOREVKULLANICI GK inner join REHBER R on R.ID=GK.REHBERID  where '+
             ' LISTGOREVID='+IntToStr(GorevId)+' and TUR between 11 and 12 '+
             ' union all select '+IntToStr(Sahibi)+','''+SahibiAd+''','+Kullanan+','+IntToStr(AliciTur) );
       while not Tablo.Query7.eof do begin
          if FormAc then begin
             if Tablo.Query7.FieldByName('TUR').AsInteger=11 then
                KimeAdr := KimeAdr + Tablo.MailAdresiBul(1, Tablo.Query7.Fields[0].AsInteger)+';'
             else
                BilgiAdr := BilgiAdr+ Tablo.MailAdresiBul(1, Tablo.Query7.Fields[0].AsInteger)+';'
          end else begin
 //            if ((AtamaYapildi)and(Tablo.Query7.Fields[2].AsString<>Tablo.Query7.Fields[0].AsString))or
 //               ((YorumYapildi)and(YorumEkleyen<>Tablo.Query7.Fields[0].AsInteger))then //işi ekleyen kendine görev verirse mailgitmesin
                TEpostaAlici.ListeyeYukle(Tablo.Query7.Fields[1].AsString+','+ Tablo.MailAdresiBul(1, Tablo.Query7.Fields[0].AsInteger), epostaalicilar);
          end;
          Tablo.Query7.Next;
       end;
       ///
       ///
       if FormAc then begin
           gmail:=Tablo.EMailBilgiGetir(0, KimeAdr,BilgiAdr);
           if gmail=nil then //cancel olduysa
              abort;
           for i:=0 to Length(gmail) -1 do begin
                if  (i=0) or (gmail[i].kime<>'')   then
                  TEpostaAlici.ListeyeYukle(''''','+ gmail[i].kime, epostaalicilar);
                if  (i=0) or (gmail[i].bilgi<>'') then
                  TEpostaAlici.ListeyeYukle(''''','+ gmail[i].bilgi, epostaalicilarCC);
           end;
       end;
   end;

   procedure DosyalarEkle;
   begin
      Tablo.TablodanSorguAc(5, 'select I.ID,AD from DOKUMAN D inner join IMAJ I on D.ID=I.YER_ID inner join GOREVYORUM GY on D.MODULID=GY.ID where '+
          ' GY.TUR =  '+IntToStr(TabNo_GOREVLER)+' AND GY.GOREVID='+IntToStr(GorevId));
      while not Tablo.Query5.eof do begin
          Tablo.TablodanSorguAc(6, ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma ' + Tablo.Query5.FieldByName('ID').AsString +
           ' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI=''' + copy(Tablo.Query5.FieldByName('AD').AsString, Pos('.', Tablo.Query5.FieldByName('AD').AsString) + 1, 10) + '''');
          s := KutuktenOku(Tablo.Query6, 'BELGE','1'+ Tablo.Query5.FieldByName('AD').AsString, false);
          EkDosya.Add(s);
          Tablo.Query5.next;
      end;
   end;
begin
   Result := False;
   //DUYURUYU AÇALIM
   //Tablo.TablodanSorguAc(8,TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).SQLEpostaMemo.Text+' G.ID='+IntToStr(GorevId));
    s := 'select G.ID,LISTEID=GL.ID, LISTEADI=GL.ADI,G.KONUSU,NOTLAR=GY.YORUM,' + #13#10 +
    'CARI=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.REHBERID),' + #13#10 +
    //'TARIH=CONVERT(VARCHAR(20), G.BASLAMATARIHI,113),' + #13#10 +
    ' G.BASLAMATARIHI,G.BITISTARIHI, ' + #13#10 +
	  ' DURUM=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI where BOLUM=-21042 and DIL=-1 and DEGER=G.DURUM '+DbSinir(1)+'), ' + #13#10 +
   	' TURU=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI where BOLUM=-21044 and DIL=-1 and DEGER=G.TURU '+DbSinir(1)+'), ' + #13#10 +
    ' PROJE=(select P.PROJEKODU FROM PROJELER P where P.ID=G.PROJEID), ' + #13#10 +
    ' EKIPMANAD = (select AD from EKIPMANLAR E where E.ID=G.EKIPMANID), ' + #13#10 +
    'ILGILI1=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.MUS_ILGILI),' + #13#10 +
    'ILGILI2=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.MUS_ILGILI2),' + #13#10 +
    'OLUSTURAN=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN),' + #13#10;
   if AktifVeriMotor = vmPG then
     s := s +
    'ATANAN1=(SELECT string_agg(R.FIRMA, '', '' order by GK.ID) FROM GOREVKULLANICI GK INNER JOIN REHBER R ON R.ID=GK.REHBERID WHERE GK.LISTGOREVID=G.ID AND GK.TUR=11),' + #13#10 +
    'BILGI1=(SELECT string_agg(R.FIRMA, '', '' order by GK.ID) FROM GOREVKULLANICI GK INNER JOIN REHBER R ON R.ID=GK.REHBERID WHERE GK.LISTGOREVID=G.ID AND GK.TUR=12),G.EKLEYEN' + #13#10
   else
     s := s +
    'ATANAN1=(SELECT [dbo].[fn_GorevVerilenKisilerUzunAd](11,G.ID,11)),' + #13#10 +
    'BILGI1=(SELECT [dbo].[fn_GorevVerilenKisilerUzunAd](11,G.ID,12)),G.EKLEYEN' + #13#10;
   s := s +
    'from GOREVLER G' + #13#10 +
    'left join GOREVYORUM GY on G.ID=GY.GOREVID and GY.TUR=1' + #13#10 +
    'left join GOREVLISTE GL on GL.ID=G.LISTEID' + #13#10 +
    'where';


   Tablo.TablodanSorguAc(8,s+' G.ID='+IntToStr(GorevId));
   RehId := Tablo.Query8.FieldByName('EKLEYEN').AsInteger;
   //konu ve içeriği alalım
   case KonuTur of
     1 : Konu:='Yeni Görev';
     2 : Konu:='Görev Devamı';
     3 : Konu:='Yeni Yorum';
     9 : Konu:='Görev Tamamlandı';
   end;
   Konu := Konu+' '+Tablo.Query8.Fields[0].AsString+' / '+Tablo.Query8.FieldByName('KONUSU').AsString;

   s:='';
   Trh:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn', Tablo.Query8.FieldByName('BASLAMATARIHI').AsDateTime)+' - '+
        FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn', Tablo.Query8.FieldByName('BITISTARIHI').AsDateTime);
   if Trh<>'' then
      s:=s+'<b> Tarih : </b> '+Trh+'<br/>';
   if Tablo.Query8.FieldByName('OLUSTURAN').asstring<>'' then
      s:=s+'<b>  Oluşturan : </b> '+Tablo.Query8.FieldByName('OLUSTURAN').asstring+'<br/>';
   s:=s+'<b>  Konu : </b> '+Tablo.Query8.FieldByName('KONUSU').AsString+' <br/>';
   if Tablo.Query8.FieldByName('DURUM').asstring<>'' then
      s:=s+'<b>  Durum : </b> '+Tablo.Query8.FieldByName('DURUM').asstring+'<br/>';
   if Tablo.Query8.FieldByName('TURU').asstring<>'' then
      s:=s+'<b>  Türü : </b> '+Tablo.Query8.FieldByName('TURU').asstring+'<br/>';
   if Tablo.Query8.FieldByName('LISTEID').AsInteger>0 then
      s:=s+'<b>  Klasör : </b> '+Tablo.Query8.FieldByName('LISTEADI').AsString+' <br/>';
   if (Tablo.Query8.FieldByName('CARI').asstring<>'')and(Tablo.Query8.FieldByName('CARI').asstring<>'-') then
      s:=s+'<b>  Müşteri : </b> '+Tablo.Query8.FieldByName('CARI').asstring+'<br/>';
   if Tablo.Query8.FieldByName('ILGILI1').asstring<>'' then
      s:=s+'<b>  İlgili : </b> '+Tablo.Query8.FieldByName('ILGILI1').asstring+' - '+Tablo.Query8.FieldByName('ILGILI2').asstring+'<br/>';
//   if Tablo.Query8.FieldByName('ILGILI2').asstring<>'' then
//      s:=s+'<b>  İlgili : </b> '+Tablo.Query8.FieldByName('ILGILI2').asstring+'<br/>';
   if Tablo.Query8.FieldByName('PROJE').asstring<>'' then
      s:=s+'<b>  Proje/Fırsat : </b> '+Tablo.Query8.FieldByName('PROJE').asstring+'<br/>';
   if Tablo.Query8.FieldByName('EKIPMANAD').AsString<>'' then
      s:=s+'<b>  Ekipman : </b> '+Tablo.Query8.FieldByName('EKIPMANAD').asstring+'<br/>';
   if Tablo.Query8.FieldByName('ATANAN1').asstring<>'' then
      s:=s+'<b>  Atanan : </b> '+Tablo.Query8.FieldByName('ATANAN1').asstring+'<br/>';
   if Tablo.Query8.FieldByName('BILGI1').asstring<>'' then
      s:=s+'<b>  Bilgi : </b> '+Tablo.Query8.FieldByName('BILGI1').asstring+'<br/>';

   Body := TStringStream.Create();
   if s<>'' then
      Body.WriteString(s);

//   if Tablo.Query8.FieldByName('LISTEID').AsInteger>0 then
//      Body.WriteString('<b>  Klasör : </b> <h2>'+Tablo.Query8.FieldByName('LISTEADI').AsString+'</h2> <br/>');
//   Body.WriteString('<b>  Konu : </b> <h3>'+Tablo.Query8.FieldByName('KONUSU').AsString+'</h3> <br/>');
   if Tablo.Query8.FieldByName('NOTLAR').AsString<>'' then
      Body.WriteString(' <p> '+stringreplace( Tablo.Query8.FieldByName('NOTLAR').AsString, #13#10,'<br/>',[rfReplaceAll])+'</p> <br/>');


//   Tablo.TablodanSorguAc(4, 'select GY.EKLEMETARIHI, EKLEYEN=R.FIRMA, [dbo].[RTF2Text]([YORUM]) AS [TextFromRTF], GY.EKLEYEN, D.AD'+
//         ' from GOREVYORUM GY inner join REHBER R on R.ID=GY.EKLEYEN left join DOKUMAN D on D.MODULID=GY.ID and MODUL=210 where GY.GOREVID='+IntToStr(GorevId)+'  and GY.TUR=33  order by 2 DESC ');
   Tablo.TablodanSorguAc(4, 'select GY.EKLEMETARIHI, EKLEYEN=R.FIRMA, GY.YORUM, GY.EKLEYEN, D.AD'+
         ' from GOREVYORUM GY inner join REHBER R on R.ID=GY.EKLEYEN left join DOKUMAN D on D.MODULID=GY.ID and MODUL=210 where GY.GOREVID='+IntToStr(GorevId)+'  and GY.TUR=33  order by 1 DESC ');
   if Tablo.Query4.RecordCount > 0 then begin
       //YorumEkleyen:= Tablo.Query4.Fields[2].AsInteger;
       Body.WriteString('<P> Yorumlar </P>');
       while not Tablo.Query4.eof do begin
          Trh:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn', Tablo.Query4.FieldByName('EKLEMETARIHI').AsDateTime);

          Body.WriteString('<b> '+Trh+' '+Tablo.Query4.FieldByName('EKLEYEN').AsString+' </b>');
          //if Trim(Tablo.Query4.Fields[1].AsString) <> '' then
          //   Body.WriteString('<p> '+Tablo.Query4.FieldByName('TextFromRTF').AsString+' </p>');
          if Trim(Tablo.Query4.FieldByName('YORUM').AsString) <> '' then begin
             GlobalRichEdit := TcxRichEdit.Create(nil);
             GlobalRichEdit.Parent := Anaform;
             GlobalRichEdit.Visible := False;
             GlobalRichEdit.EditValue := Tablo.Query4.FieldByName('YORUM').AsString;
             Body.WriteString('<p> ' + GlobalRichEdit.Lines.Text + ' </p>');
             GlobalRichEdit.destroy;
          end;
          if Trim(Tablo.Query4.FieldByName('AD').AsString) <> '' then
             Body.WriteString('<p> '+Tablo.Query4.FieldByName('AD').AsString+' </p>');
          Tablo.Query4.Next;
       end;
   end;
   Body.WriteString('<hr>');
   Body.WriteString('<p> <i> <b>Gentegre</b>''den gönderilmiştir. </i> </p>');

   //gönderen adr
   KimdenAdr := Tablo.MailAdresiBul(1, StrToInt(Kullanan));
   if KimdenAdr='' then begin
      Showmessage('Gönderen mail adresi bulunamadı!');
      Abort;
   end;

   if epostaalicilar = nil then begin
      EPostaAlicilar := TList<TEpostaAlici>.Create;
      EPostaAlicilarCC := TList<TEpostaAlici>.Create;
   end;

   if EPostaAlicilar.Count = 0 then
      MailAdresiSor;

   EkDosya := TList<String>.Create;
   DosyalarEkle;

   if EPostaAlicilar.Count>0 then begin
      DosyaAdi := HTML_Dosya;
      SonucMesaj := EpostaGonderRapor(EPostaHesapBilgileriniGetir(EpostaHesapID), Konu, DosyaAdi, EkDosya, EPostaAlicilar, EPostaAlicilarCC,
      Tablo.IdSMTP1, Tablo.iohSSLTLS,TabNo_GOREVLER, IntToStr(GorevId), RehId).SonucMesaji;
      EPostaAlicilar.Clear;
      EPostaAlicilarCC.Clear;
      //freeandnil(EPostaAlicilar);
      if SonucMesaj <> '' then
         Showmessage(SonucMesaj);
   end;
   Body.Free;
   freeandnil(EkDosya);
   DeleteFile(AtacDosya);
   AtamaYapildi := False;
   YorumYapildi := False;
   Result := True;
end;

function YeniGorevEkle(TabGorevler : TDataSet; ListeId, ProjeId : Integer; YeniGorevEdit:TcxTextEdit; Key:Word; DateEdit1:TcxDateEdit;
            TimeEdit1:tcxTimeEdit;CheckBAYRAK:TcxCheckBox;CariId:integer=0;PersonelId:integer=0;GorevTuru:integer=0; Yer:integer=0; YerId:integer=0):Integer;
var Bayrak : Integer;
    BasTar : TDateTime;
    function ServisKayitEkle(Konu:String; Bayrak : Integer; BasTrh :TDateTime):Integer;
    var Bastar:String;
         Year, Month, Day : Word;
         belgeno : TBelgeNo;
    begin
      DecodeDate(Bastrh, Year, Month, Day);
      if (BasTrh<>null)and(Year>2000) then
         Bastar := ''''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Bastrh)+''''
      else
         Bastar:='null';

      //belgeno:= SiradakiBelgeNumarasi(TabNo_SERVIS,Tablo.GENINI.BugunTrhSaat);
      //Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into SERVIS ([TARIH],[SERVISNO],[KONUSU],[BASLAMATARIHI],[BITISTARIHI],ACIL,'+
      //'ACKAPA,DISSERVIS,FIYAT_LISTESI,DEPO,DURUM,DEMIRBAS,SUBEID,KABUL_EDEN,EKLEYEN) values(getdate(),'''+ belgeno.belgeno+''','''+StringReplace(Trim(Konu),'''','',[rfreplaceall])+''','+
      //Bastar+','+Bastar+','+IntToStr(Bayrak)+',0,1,'+ IntToStr(VarsSatisFiyatID)+','+IntToStr(VarsDepo)+',1,0,'+IntToStr(SubeId)+','+Kullanan+','+Kullanan+') select SCOPE_IDENTITY()',[],[], True);
//      Result := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_prg_Servis_Yeni 0,'+IntToStr(SubeID)+','+Kullanan+', '''+Tablo.repServisKonusu.Properties.Items[0]+''', '''+formatdatetime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+'''  ',[],[],true);
      Result := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_prg_Servis_Yeni 0,'+IntToStr(SubeID)+','+Kullanan+', '''+StringReplace(Trim(Konu),'''','',[rfreplaceall])+''','+Bastar,[],[],true);
      if Bayrak=1 then
         veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SERVIS set ACIL=1 where ID='+IntToStr(Result),[],[]);
    end;

begin
   Result := 0;
   case Key of
     38: TabGorevler.Prior;
     40: TabGorevler.Next;
     13: begin
             YeniGorevEdit.text := Trim(YeniGorevEdit.text);
             if (YeniGorevEdit.Text = '')and(TabGorevler.RecordCount<1) then
                exit;
             if YeniGorevEdit.Text = '' then
                //DuzenleMenuClick(GorevGridDBTableView1)
             else begin
                BasTar:=0;
                if DateEdit1.Text<>'' then begin
                   if (TimeEdit1.Text<>'')and(TimeEdit1.Text<>'00:00')  then
                      BasTar := DateEdit1.Date+TimeEdit1.Time
                   else
                      BasTar := DateEdit1.Date;
                end;

                if (CheckBAYRAK.Checked)or(ListeId=Bayrakli) then
                    Bayrak := 1
                else
                    Bayrak:=0;

                case ListeId of
                   MasaUstu: begin
                                 ListeId := MasaUstu;
                              end;
                   Bugun   : begin
                                ListeId := MasaUstu;
                                BasTar := Tablo.GENINI.BugunTrh;
                             end;
                   Bayrakli: begin
                                 ListeId := MasaUstu;
                                // BasTar:=null;
                              end;
                   0..9999 : ListeId := ListeId;


                end;//case

                if ListeId = Servis then
                   Result := ServisKayitEkle(YeniGorevEdit.Text, Bayrak, BasTar)
                else
                   Result := Tablo.GorevOlustur(YeniGorevEdit.Text, ListeId,0,ProjeId,  Bayrak,CariId,PersonelId,0,GorevTuru,Yer,YerId, BasTar,Bastar);
                YeniGorevEdit.Text := '';
                DateEdit1.Clear;
                TimeEdit1.Clear;
                CheckBAYRAK.Checked := False;
                YeniGorevEdit.SetFocus;
             end;
         end;
   end;
end;

procedure Menu_Duzenle(Sender: TObject; TabGorevler:TDataSet; Scheduler:TcxScheduler=nil);
var GOREV_ID: String[15];
    selectedEvent : TcxSchedulerControlEvent;
    GorevDlg1: TGorevDlg;
begin
  if (Tcomponent(sender).classname= 'TcxScheduler')or(TPopupMenu(TMenuItem(Sender).GetParentComponent).PopupComponent.ClassName = 'TcxScheduler') then begin
     if Scheduler.SelectedEventCount = 0 then Exit;
     selectedEvent := Scheduler.SelectedEvents[0];
     GOREV_ID := selectedEvent.GetCustomFieldValueByName('GOREV_ID'); //
     if selectedEvent.GetCustomFieldValueByName('LISTEID')=Servis then
        Tablo.ServisSihirbazBaslat(False, 'D', 0, StrToIntDef(GOREV_ID,-1), 0)  //GOREV_ID
     else
        Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',StrToIntDef(GOREV_ID,-1),AtamaYapildi, YorumYapildi);   //GOREV_ID
  end else begin
     if TabGorevler.FieldByName('LISTEID').AsInteger=Servis then
        Tablo.ServisSihirbazBaslat(False, 'D',0,TabGorevler.FieldByName('ID').AsInteger, AktifRehberId)
     else begin
         GOREV_ID:= TabGorevler.FieldByName('ID').AsString;
         Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',StrToInt(GOREV_ID),AtamaYapildi, YorumYapildi);
     end;
  end;
  if AtamaYapildi then
      Gorev_EPostaGonder(1, StrToIntDef(GOREV_ID,-1))
  else if YorumYapildi then
      Gorev_EPostaGonder(3, StrToIntDef(GOREV_ID,-1));
end;

procedure UpdateveMail(AktifListe, ListeId, GorevId, Ekleyen:Integer; AcKapa, AltGorevVar : Boolean);
begin
   if AktifListe=Onayla then
      GorevUpdate(GorevId, 'DURUM = '+IntToStr(VarsayDurumSon))
   else begin
      if ListeId = Servis then
         ServisUpdate(GorevId, 'ACKAPA = '+IntToStr(Abs(StrToInt(BoolToStr(not AcKapa)))))
      else begin
         if AltGorevVar then  //alt görevler varsa onlara da uygulanır
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update GOREVLER set ACKAPA='+IntToStr(Abs(StrToInt(BoolToStr(not AcKapa))))+' where BAGIDUST = '+IntToStr(GorevId),[],[]);
         GorevUpdate(GorevId, 'ACKAPA = '+IntToStr(Abs(StrToInt(BoolToStr(not AcKapa)))));
      end;

      if (OnaySistemiAktif)and(IntToStr(Ekleyen)<>Kullanan) then begin
          //if ListeId = Servis then
             //ServisUpdate(GorevId, 'DURUM= '+IntToStr(VarsayDurumServisSonOnay))
          //else
             GorevUpdate(GorevId, 'DURUM = '+IntToStr(VarsayDurumSonOnay));
      end;
   end;

  if IntToStr(Ekleyen) <> Kullanan then begin //tamamlandı maili gidecek
     if epostaalicilar = nil then begin
        EPostaAlicilar := TList<TEpostaAlici>.Create;
        EPostaAlicilarCC := TList<TEpostaAlici>.Create;
     end;
     TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA', Ekleyen)+','+ Tablo.MailAdresiBul(1, Ekleyen), epostaalicilar);
     Gorev_EPostaGonder(9, GorevId);
  end;
end;

//procedure Menu_Tamam(Sender: TObject; View1 :TcxGridBTableView; Scheduler:TcxScheduler=nil; AktifListe:Smallint=0);
procedure Menu_Tamam(Sender: TObject; View1 :TcxGridDBTableView; Scheduler:TcxScheduler=nil; AktifListe:Smallint=0);
var GOREV_ID, Komut, Ekleyen: String[15];
    selectedEvent : TcxSchedulerControlEvent;
    I, ListeId:Integer;
    AcKapa : Boolean;
begin
  if (Tcomponent(sender).classname= 'TcxScheduler')or(TPopupMenu(TMenuItem(Sender).GetParentComponent).PopupComponent.ClassName = 'TcxScheduler') then begin
     if Scheduler.SelectedEventCount > 0 then
        for I := 0 to Scheduler.SelectedEventCount-1 do begin
            selectedEvent := Scheduler.SelectedEvents[I];
            GOREV_ID := selectedEvent.GetCustomFieldValueByName('GOREV_ID'); //
            Ekleyen  := selectedEvent.GetCustomFieldValueByName('EKLEYEN');
            AcKapa := selectedEvent.GetCustomFieldValueByName('ACKAPA') = 'True';
            ListeId  := selectedEvent.GetCustomFieldValueByName('LISTEID');
            UpdateveMail(AktifListe, ListeId, StrToInt(GOREV_ID),StrToInt(Ekleyen), AcKapa, False);
        end;
  end else begin  // soldaki listede tamamlandı yapldı
    if View1.Controller.SelectedRecordCount > 0 then
        for I := 0 to View1.Controller.SelectedRecordCount-1 do
//            if View1.IntToStr(View1.Selections[I].values[0]<>View1.IntToStr(View1.Selections[I].values[1] then
            begin
                GOREV_ID := VarToStr(View1.Controller.SelectedRows[i].Values[View1.DataController.GetItemByFieldName('ID').Index]);
                Ekleyen := VarToStr(View1.Controller.SelectedRows[i].Values[View1.DataController.GetItemByFieldName('EKLEYEN').Index]);
                AcKapa := VarToStr(View1.Controller.SelectedRows[i].Values[View1.DataController.GetItemByFieldName('ACKAPA').Index]) = 'True';
                ListeId := StrToIntDef( VarToStr(View1.Controller.SelectedRows[i].Values[View1.DataController.GetItemByFieldName('LISTEID').Index]), 0);
{                GOREV_ID := IntToStr(View1.IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('ID').ItemIndex]);
                Ekleyen  := IntToStr(View1.IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('EKLEYEN').ItemIndex] );
                AcKapa := View1.IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('ACKAPA').ItemIndex]='True';
                ListeId := View1.IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('LISTEID').ItemIndex]; }
                UpdateveMail(AktifListe, ListeId, StrToInt(GOREV_ID),StrToInt(Ekleyen), AcKapa, False);
            end;
  end;
end;


{
    if View1.SelectionCount > 0 then
        for I := 0 to View1.SelectionCount-1 do
            if View1.Selections[I].values[0]<>View1.Selections[I].values[1] then begin
                GOREV_ID := IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('ID').ItemIndex]);
                Ekleyen  := IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('EKLEYEN').ItemIndex] );
                AcKapa := View1.Selections[I].Values[View1.GetColumnByFieldName('ACKAPA').ItemIndex]='True';
                ListeId := View1.Selections[I].Values[View1.GetColumnByFieldName('LISTEID').ItemIndex];
                UpdateveMail(AktifListe, ListeId, StrToInt(GOREV_ID),StrToInt(Ekleyen), AcKapa, View1.Selections[I].HasChildren);
            end;
}

procedure Menu_Bayrak(Sender: TObject; View1 :TcxDBTreeList; Scheduler:TcxScheduler=nil);
var GOREV_ID, Komut : String[15];
    selectedEvent : TcxSchedulerControlEvent;
    I, ListeId:Integer;
    AcKapa, Bayrak: Boolean;
    procedure UpdateveMail;
    begin
      if ListeId = Servis then
         ServisUpdate(StrToInt(GOREV_ID), 'ACIL = '+IntToStr(Abs(StrToInt(BoolToStr(not Bayrak)))))
      else
         GorevUpdate(StrToInt(GOREV_ID), 'BAYRAK = '+IntToStr(Abs(StrToInt(BoolToStr(not Bayrak)))));
    end;
begin
  if (Tcomponent(sender).classname= 'TcxScheduler')or(TPopupMenu(TMenuItem(Sender).GetParentComponent).PopupComponent.ClassName = 'TcxScheduler') then begin
     if Scheduler.SelectedEventCount > 0 then
        for I := 0 to Scheduler.SelectedEventCount-1 do begin
            selectedEvent := Scheduler.SelectedEvents[I];
            GOREV_ID := selectedEvent.GetCustomFieldValueByName('GOREV_ID'); //
            Bayrak  := selectedEvent.GetCustomFieldValueByName('BAYRAK')='True';
            ListeId  := selectedEvent.GetCustomFieldValueByName('LISTEID');
            UpdateveMail;
        end;
  end else begin  // soldaki listede tamamlandı yapldı
     if View1.SelectionCount > 0 then
        for I := 0 to View1.SelectionCount-1 do
            if View1.Selections[I].values[0]<>View1.Selections[I].values[1] then begin
                GOREV_ID := IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('GOREV_ID').ItemIndex]);
                Bayrak := IntToStr(View1.Selections[I].Values[View1.GetColumnByFieldName('BAYRAK').ItemIndex])='True';
                ListeId := View1.Selections[I].Values[View1.GetColumnByFieldName('LISTEID').ItemIndex];
                UpdateveMail
            end;
  end;
end;
end.



