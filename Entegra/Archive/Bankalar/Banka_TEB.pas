unit Banka_TEB;

interface

uses SysUtils,Utablo,Fetautil,UTalimatWizard,Classes,FetaKurulusSiniflari,ZLIBEX,Dialogs,UBinarySave,DB,
  Windows,ShellAPI,Controls,UFDCompatHelpers;

function TEB_Dosya_Olustur(TabKaynak:TFDQuery):string;
function TEB_Dosya_OlusturIBAN(TabKaynak:TFDQuery):string;
function TEB_AkibetAl(TalimatID:Integer):TStringList;
Function Teb_AkibetSonucunuKaydet(TalimatID:Integer; var AkibetSatirlari:TStringList):Boolean;
function TEBHesapHareketleriniAl(BasTarih,BitTarih:TDateTime;BankaHesapID:Integer):Boolean;
function TEBInputDataXMLOlustur(FrmAd,FrmAnh,SbNo,HesNo:string;BasTar,BitTar:TDateTime):string;
function TebXMLParse(BankaHesapID:Integer;XMLString:String):Integer;
function TEBEkstreKasaTurGetir(ProgramKodu,BA:string):Integer;


implementation


uses
  JclStrings, TEB_Encrypter_TLB,UHesapHareketleri,UGirisKutusuEx,TEBEkstreWebServices,ECXMLParser,PrjConst;

function TEB_Dosya_OlusturIBAN(TabKaynak:TFDQuery) : string;
var
  F: Textfile;
  Dosya_Adi,FirmaAdiIlkBolumu, HesapNo, SubeNo,Bankakodu,MusteriNo,
  HedefBankakodu ,HedefSubeNo, HedefHesapNo,HedefFirma,Dosyatarih,islemtarih,Aciklama,
  Tutar,StrToplam,TCkimlikno,IBANNo,VergiNo,VergiDai,EMail,RehKod: String;
  str  : string;
  Say : SmallInt;
  Toplam : Real;
  dllhandle : THandle;
  teb : OleVariant;
  enc : TEncrypterClass;
begin
   ShellExecuteA(0{Handle}, 'open',PAnsiChar('cmd.exe'),PAnsiChar('%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe '+GetCurrentDir+'\TEB.Encrypter.dll'),nil,SW_HIDE);
   //ilk önce /Talimat Klasörü yok ise oluþturulur..
   if not DirectoryExists('Talimat') then
      CreateDir('Talimat');
   //Aþaðýdakiler bizim hesaba ait bilgilerimiz
   HesapNo := TalimatWizardDlg.TabGonderen.FieldByName('HESAPNO').AsString;
   while Length(HesapNo)< 8 do   //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalý
         HesapNo := '0'+HesapNo;
   SubeNo := TalimatWizardDlg.TabGonderen.FieldByName('SUBEKODU').AsString;
   while Length(SubeNo)< 4 do
         SubeNo := '0'+SubeNo;
   FirmaAdiIlkBolumu:=TurkceDegisBoslukBirakma(Copy(Tablo.TabBizim.FieldByName('FIRMA').AsString,1,9)); //ilk 9 karakter gelecek
   //txt dosya adý bilgilerimiz
   (*Örnek: ODaaggsadksnGhhhhhhhhssssfirma_adi$.TXT
            OD0231145512G012358170123abcd_gida$.TXT
            OD0402130943G001231340105$     *)
   //Dosya_Adi := 'TEB'+FormatDateTime('yyyymmddhhnnss', Tablo.GENINI.BuguntrhSaat)+'G'+HesapNo+SubeNo+'$.txt';
   Dosya_Adi:=FormatDateTime('mmddhhnnss', Tablo.GENINI.BuguntrhSaat)+'G'+HesapNo+SubeNo+FirmaAdiIlkBolumu+'$.txt';
//H620111003003200112000000003943308-MT-120111003    00000000
//D00990011200000003943308-MT-1TRY00000000000000001.0001/01/2011 ile 04/10/2011 tarih aralýðýndaki ödeme.         120.00002           ULTRA-EMAR                                                                                          00000000008870101112FIRAT VD.                     Bilgi@Gozdehastanesi.com.tr                                                                                                                           TR030009900394330800100001
//T00000000000100000000000000001.00

   AssignFile(F,('Talimat\'+Dosya_Adi));
   Rewrite(F);
   MusteriNo := TalimatWizardDlg.TabGonderen.FieldByName('MUSTERINO').AsString;
   while Length(MusteriNo)< 8 do
         MusteriNo := '0'+MusteriNo;
   Dosyatarih:= FormatDateTime('yyyymmdd', Tablo.GENINI.BuguntrhSaat);
   islemtarih:= FormatDateTime('yyyymmdd', TalimatWizardDlg.DateIslem.Date);
   Bankakodu := TalimatWizardDlg.TabGonderen.FieldByName('BANKAKODU').AsString;
   while Length(Bankakodu)< 4 do
         Bankakodu := '0'+Bankakodu;
   //Ýlk satýr bizim bilgilerimiz
   (*Örnek: H620090923003200145001234501234567820090923 00000000 veya
            H620091223003200145001234501234567820090923221012345678*)
   str := 'H6'+Dosyatarih+Bankakodu+'0'+SubeNo+MusteriNo+HesapNo+islemtarih+'    00000000';
   Writeln(F, str);
   //alýcý hesap bilgileri ve tutarlarý (birden fazla satýr olabilir)
   TalimatWizardDlg.TabAlicilar.First;
   Say := 0;
   Toplam := 0;
   TabKaynak.First;
   while not  TabKaynak.eof do begin
     //THavaleEFTEkrani.cxGridDBTableView1.DataController.GetRowIndexByRecordIndex ;
     //Aþaðýdakiler müþteri hesabýnaa ait bilgiler
     HedefBankakodu := TabKaynak.FieldByName('BANKAKODU').AsString;
     while Length(HedefBankakodu)< 4 do
          HedefBankakodu := '0'+HedefBankakodu;
     HedefSubeNo := TabKaynak.FieldByName('SUBEKODU').AsString;
     while Length(HedefSubeNo)< 5 do
          HedefSubeNo := '0'+HedefSubeNo;
     HedefHesapNo := TabKaynak.FieldByName('HESAPNO').AsString;
     while Length(HedefHesapNo)< 19 do
          HedefHesapNo := '0'+HedefHesapNo;
     TCkimlikno := TabKaynak.FieldByName('TCKIMLIKNO').AsString;
     while Length(TCkimlikno)< 16 do
          TCkimlikno := TCkimlikno+' ';
     IBANNo := TabKaynak.FieldByName('IBAN').AsString;
     while Length(IBANNo)< 26 do
          IBANNo := IBANNo+' ';
     Tutar := formatFloat('00000000000000000.00',  TabKaynak.FieldByName('TUTAR').AsFloat);
     //decimal ayýraç . olmak zorunda.
     Tutar := StringReplace(Tutar,',','.',[rfReplaceAll, rfIgnoreCase]);
     Aciklama := copy(TabKaynak.FieldByName('ACIKLAMA').AsString,1,60);
     while Length(aciklama)< 60 do
          aciklama := aciklama+' ';
     HedefFirma := copy(TabKaynak.FieldByName('UNVAN').AsString,1,50);
     while Length(HedefFirma)< 50 do
          HedefFirma := HedefFirma+' ';
     VergiNo := copy(TabKaynak.FieldByName('VNO').AsString,1,10); //numeric
     while Length(VergiNo)< 10 do
          VergiNo := '0'+VergiNo;
     VergiDai := copy(TabKaynak.FieldByName('VD').AsString,1,30); //alphanumeric
     while Length(VergiDai)< 30 do
          VergiDai := VergiDai+' ';
     EMail := copy(TabKaynak.FieldByName('EMAIL').AsString,1,150);// ;ile ayýrarak yazýlabilir
     while Length(EMail)< 150 do
          EMail := EMail+' ';
     RehKod := copy(TabKaynak.FieldByName('REHKOD').AsString,1,20);// ;ile ayýrarak yazýlabilir
     while Length(RehKod)< 20 do
          RehKod := RehKod+' ';
     //DETAY SATIRI
     str := 'D'+HedefBankakodu+HedefSubeNo+HedefHesapNo+'TRY'+Tutar+aciklama+
     RehKod+HedefFirma+
     '                                                  '+
     '0000000000'+VergiNo+VergiDai+EMail+
     IBANNo+TCkimlikno;
     Writeln(F, str);
     inc(Say);
     Toplam := Toplam + TabKaynak.FieldByName('TUTAR').AsFloat;

     TabKaynak.next;
   end;
   StrToplam := FormatFloat('00000000000000000.00',  Toplam);
   StrToplam := StringReplace(StrToplam,',','.',[rfReplaceAll]);
   //son satýr toplam bilgilerimiz
   (* ÖRNEK :T00000000000100000000000020071.80*)
   str := 'T'+Format('%.12d', [Say])+StrToplam;
   Writeln(F, str);
   CloseFile(F);
   //önemli not!!!! TLB dosyasýnýn register edilmesi gerekiyor..
   //"C:\Windows\Microsoft.NET\Framework\v4.0.30319\regtlibv12.exe" reg ediyor ve parametre olarak
   //"C:\GenSoft\Delphi\Entegra\Entegra\TEBEncrypter\TEB.Encrypter.tlb" nin kullanýlmasý gerekiyor..
   //sonrasýnda da tlb dosyasý dll in yanýnda olmak zorundadýr..

   //enc := TEncrypterClass.Create(nil);
   //teb := enc.DefaultInterface;
   //StringToFile(('Talimat\'+'OD'+Dosya_Adi),teb.Sifrele(FileToString('Talimat\'+Dosya_Adi),'12345678'));
   StringToFile(('Talimat\'+'OD'+Dosya_Adi),FileToString('Talimat\'+Dosya_Adi));
   if say=0 then
   raise exception.Create(secimyapilmadihata);

   Result := 'OD'+Dosya_Adi;
end;

function TEB_Dosya_Olustur(TabKaynak:TFDQuery) : string;
//Resourcestring
//  secimyapilmadihata = 'Alýcý listesinden en az bir seçim yapýnýz.' ;
var
  F: Textfile;
  Dosya_Adi,FirmaAdiIlkBolumu, HesapNo, SubeNo,Bankakodu,MusteriNo,
  HedefBankakodu ,HedefSubeNo, HedefHesapNo,HedefFirma,Dosyatarih,islemtarih,Aciklama,Tutar,
  StrToplam,VergiNo,VergiDai,EMail,RehKod: String;
  str  : string;
  Say : SmallInt;
  Toplam : Real;
  dllhandle : THandle;
  teb : OleVariant;
  enc : TEncrypterClass;
begin
   ShellExecuteA(0{Handle}, 'open',PAnsiChar('cmd.exe'),PAnsiChar('%windir%\Microsoft.NET\Framework\v4.0.30319\regasm.exe '+GetCurrentDir+'\TEB.Encrypter.dll'),nil,SW_HIDE);
   //ilk önce /Talimat Klasörü yok ise oluþturulur..
   if not DirectoryExists('Talimat') then
      CreateDir('Talimat');
   //Aþaðýdakiler bizim hesaba ait bilgilerimiz
   HesapNo := TabKaynak.FieldByName('HESAPNO').AsString;
   while Length(HesapNo)< 8 do   //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalý
         HesapNo := '0'+HesapNo;
   SubeNo := TabKaynak.FieldByName('SUBEKODU').AsString;
   while Length(SubeNo)< 4 do
         SubeNo := '0'+SubeNo;
   FirmaAdiIlkBolumu:=TurkceDegisBoslukBirakma(Copy(Tablo.TabBizim.FieldByName('FIRMA').AsString,1,9)); //ilk 9 karakter gelecek
   //txt dosya adý bilgilerimiz
   (*Örnek: ODaaggsadksnGhhhhhhhhssssfirma_adi$.TXT
            OD0231145512G012358170123abcd_gida$.TXT
            OD0402130943G001231340105$
            *)
   //Dosya_Adi := 'TEB'+FormatDateTime('yyyymmddhhnnss', Tablo.GENINI.BuguntrhSaat)+'G'+HesapNo+SubeNo+'$.txt';
   Dosya_Adi:=FormatDateTime('mmddhhnnss', Tablo.GENINI.BuguntrhSaat)+'G'+HesapNo+SubeNo+FirmaAdiIlkBolumu+'$.txt';

   AssignFile(F,('Talimat\'+Dosya_Adi));
   Rewrite(F);
   MusteriNo := TalimatWizardDlg.TabGonderen.FieldByName('MUSTERINO').AsString;
   while Length(MusteriNo)< 8 do
         MusteriNo := '0'+MusteriNo;
   Dosyatarih:= FormatDateTime('yyyymmdd', Tablo.GENINI.BuguntrhSaat);
   islemtarih:= FormatDateTime('yyyymmdd', Tablo.GENINI.BuguntrhSaat);
   Bankakodu := TalimatWizardDlg.TabGonderen.FieldByName('BANKAKODU').AsString;
   while Length(Bankakodu)< 4 do
         Bankakodu := '0'+Bankakodu;
   //Ýlk satýr bizim bilgilerimiz
   (*Örnek: H620090923003200145001234501234567820090923 00000000 veya
            H620091223003200145001234501234567820090923221012345678*)
   str := 'H6'+Dosyatarih+Bankakodu+'0'+SubeNo+MusteriNo+HesapNo+islemtarih+'    00000000';
   Writeln(F, str);
   //alýcý hesap bilgileri ve tutarlarý (birden fazla satýr olabilir)
   TalimatWizardDlg.TabAlicilar.First;
   Say := 0;
   Toplam := 0;
   TabKaynak.First;
   while not  TabKaynak.eof do begin
     //THavaleEFTEkrani.cxGridDBTableView1.DataController.GetRowIndexByRecordIndex ;
     //Aþaðýdakiler müþteri hesabýnaa ait bilgiler
     HedefBankakodu := TabKaynak.FieldByName('BANKAKODU').AsString;
     while Length(HedefBankakodu)< 4 do
          HedefBankakodu := '0'+HedefBankakodu;
     HedefSubeNo := TabKaynak.FieldByName('SUBEKODU').AsString;
     while Length(HedefSubeNo)< 5 do
          HedefSubeNo := '0'+HedefSubeNo;
     HedefHesapNo := TabKaynak.FieldByName('HESAPNO').AsString;
     while Length(HedefHesapNo)< 19 do
          HedefHesapNo := '0'+HedefHesapNo;
     VergiNo := copy(TabKaynak.FieldByName('VNO').AsString,1,10); //numeric
     while Length(VergiNo)< 10 do
          VergiNo := '0'+VergiNo;
     VergiDai := copy(TabKaynak.FieldByName('VD').AsString,1,30); //alphanumeric
     while Length(VergiDai)< 30 do
          VergiDai := VergiDai+' ';
     EMail := copy(TabKaynak.FieldByName('EMAIL').AsString,1,150);// ;ile ayýrarak yazýlabilir
     while Length(EMail)< 150 do
          EMail := EMail+' ';
     Tutar := formatFloat('00000000000000000.00',  TabKaynak.FieldByName('TUTAR').AsFloat);
     //decimal ayýraç . olmak zorunda.
     Tutar := StringReplace(Tutar,',','.',[rfReplaceAll, rfIgnoreCase]);
     Aciklama := copy(TabKaynak.FieldByName('ACIKLAMA').AsString,1,60);
     while Length(aciklama)< 60 do
          aciklama := aciklama+' ';
     HedefFirma := copy(TabKaynak.FieldByName('UNVAN').AsString,1,50);
     while Length(HedefFirma)< 50 do
          HedefFirma := HedefFirma+' ';
     //DETAY SATIRI
     str := 'D'+HedefBankakodu+HedefSubeNo+HedefHesapNo+'TRY'+Tutar+aciklama+
     '                    '+HedefFirma+//'                                                  '+
     '                                                  '+
     '0000000000'+'0000000000'+'                              '+'                                                                                                                                                      '+
     '                          '+'                ';
     Writeln(F, str);
     inc(Say);
     Toplam := Toplam + TabKaynak.FieldByName('TUTAR').AsFloat;

     TabKaynak.next;
   end;
   StrToplam := FormatFloat('00000000000000000.00',  Toplam);
   StrToplam := StringReplace(StrToplam,',','.',[rfReplaceAll]);
   //son satýr toplam bilgilerimiz
   (* ÖRNEK :T00000000000100000000000020071.80*)
   str := 'T'+Format('%.12d', [Say])+StrToplam;
   Writeln(F, str);
   CloseFile(F);
   //önemli not!!!! TLB dosyasýnýn register edilmesi gerekiyor..
   //"C:\Windows\Microsoft.NET\Framework\v4.0.30319\regtlibv12.exe" reg ediyor ve parametre olarak
   //"C:\GenSoft\Delphi\Entegra\Entegra\TEBEncrypter\TEB.Encrypter.tlb" nin kullanýlmasý gerekiyor..
   //sonrasýnda da tlb dosyasý dll in yanýnda olmak zorundadýr..

   //enc := TEncrypterClass.Create(nil);
   //teb := enc.DefaultInterface;
   //StringToFile(('Talimat\'+'OD'+Dosya_Adi),teb.Sifrele(FileToString('Talimat\'+Dosya_Adi),'12345678'));
   StringToFile(('Talimat\'+'OD'+Dosya_Adi),FileToString('Talimat\'+Dosya_Adi));
   if say=0 then
   raise exception.Create(secimyapilmadihata);

   Result := 'OD'+Dosya_Adi;
end;

Function Teb_AkibetSonucunuKaydet(TalimatID:Integer; var AkibetSatirlari:TStringList):Boolean;
var
  I,SiraNo,Durum:Integer;
  AkibetSonuc:string;
begin
  if AkibetSatirlari = nil then
    raise Exception.Create('Uygun Dosya Bulunamadý!');
  for I := 0 to AkibetSatirlari.Count-1 do begin
    if I=0 then begin
      //Baþlýk Kaydý
      SiraNo := 0;
      AkibetSonuc := Copy(Copy(AkibetSatirlari.Strings[I],61,length(AkibetSatirlari.Strings[I])),1,50);
    end else if (I>0) and (I<(AkibetSatirlari.Count-1)) then begin
      //Detay Kayýtlarý
      SiraNo := I;
      AkibetSonuc := Copy(Copy(AkibetSatirlari.Strings[I],480,length(AkibetSatirlari.Strings[I])),1,50);
    end else if I=AkibetSatirlari.Count-1 then begin
      //Sonuç Kaydý
      SiraNo :=255;
      AkibetSonuc := Copy(Copy(AkibetSatirlari.Strings[I],39,length(AkibetSatirlari.Strings[I])),1,50);
    end;
    if Trim(AkibetSonuc) = 'Baþarýlý iþlem' then
       Durum := 9;
    Veritabani.BasitKomutÇalýþtýr(tablo.cnn,'update TALIMATDETAY set AKIBETSONUC = &AkibetSonuc where SIRANO=&SiraNo and TALIMATID=&TalimatID  ',
       ['&AkibetSonuc','&Durum','&SiraNo','&TalimatID'],[AkibetSonuc,Durum,SiraNo,TalimatID]);
  end;
end;

function TEB_AkibetAl(TalimatID:Integer):TStringList;
var
  I:Integer;
  st1,st2:TMemoryStream;
  TempFs:TFileStream;
  FTPDestination,GonderilmisBelgeAdi,AlinacakBelgeAdi:string;
  DosyaIcerik:TStringList;
begin
  // Talimata Bakalým
  Tablo.TablodanSorguAc(1, 'Select * from TALIMATLAR where ID=' + inttostr(TalimatID));
  // gitmiþ olan belgeyi açalým..
  Tablo.TablodanSorguAc(2, 'Select * from TALIMATBELGELER where DURUM=1 and SUREC=1 and TALIMATID=' + inttostr(TalimatID));
  GonderilmisBelgeAdi := Tablo.Query2.FieldByName('BELGEADI').AsString;
  Tablo.TablodanSorguAc(3, 'Select * from BANKAFTP where BANKAKODU=32');
  St1 := TMemoryStream.Create;
  if Tablo.Query3.FieldByName('FTP_GUVENLIK_TURU').AsString = 'Yok' then begin
    Tablo.IdFTP1.Host := Tablo.Query3.FieldByName('FTP_ADRES').AsString;
    Tablo.IdFTP1.UserName := Tablo.Query3.FieldByName('FTP_USER').AsString;
    Tablo.IdFTP1.PassWord := Tablo.Query3.FieldByName('FTP_PASSWORD').AsString;
    Tablo.IdFTP1.Port := Tablo.Query3.FieldByName('FTP_PORT').Value;
    FTPDestination := Tablo.Query3.FieldByName('FTP_DIZIN').AsString;
    // FTP ye baðlanalým..
    try
      if not Tablo.IdFTP1.Connected then
        Tablo.IdFTP1.Connect;
    Except
      Tablo.IdFTP1.Disconnect;
      raise Exception.Create('Baðlantýda Hata(FTP): Baðlantý Kurulamadý!');
    end;
    Tablo.idFTP1.List(nil, '', False);
    AlinacakBelgeAdi := '';
    for I := 0 to Tablo.IdFTP1.ListResult.Count - 1 do begin
      if (copy(Tablo.IdFTP1.ListResult.Strings[I], 3, 27) = copy(GonderilmisBelgeAdi, 3, 27)) and
        (Tablo.IdFTP1.ListResult.Strings[I] <> GonderilmisBelgeAdi) then
        AlinacakBelgeAdi := Tablo.IdFTP1.ListResult.Strings[I];
    end;
    if AlinacakBelgeAdi = '' then begin
      Tablo.IdFTP1.Disconnect;
      Exit;
    end;
    // dosyayý st1 e alalým..
    try
      Tablo.IdFTP1.Get(AlinacakBelgeAdi, St1, True); // Put(St2,FTPDestination+GonderilmisBelgeAdi,False);
      // sonra da silelim..
      // IdFTP1.Delete(GonderilmisBelgeAdi);
      // Result := GonderilmisBelgeAdi;
    Except
      Tablo.IdFTP1.Disconnect;
      raise Exception.Create
        ('Baðlantýda Hata(FTP): Dosya Transfer Edilemedi!');
    end;
  end Else if Tablo.Query3.FieldByName('FTP_GUVENLIK_TURU').AsString = 'SSH' then begin
    raise Exception.Create('Baðlantý türü desteklenmiyor!');
  end Else if Tablo.Query3.FieldByName('FTP_GUVENLIK_TURU').AsString = 'SSL' then begin
    raise Exception.Create('Baðlantý türü desteklenmiyor!');
  end Else
    raise Exception.Create('FTP Bilgileri Yok yada Hatalý!');

  // ******************************************************\\
  (* st1 deki akibete istedimizi yapabiliriz.. *)
  if AlinacakBelgeAdi <> '' then begin
    // Temp içinde text i oluþturalým..buradan txt açýp bilgileri okuyalým..
    TempFs := TFileStream.Create(GetEnvironmentVariable('TEMP')+ '\' + AlinacakBelgeAdi, fmCreate);
    St1.Position := 0;
    TempFs.CopyFrom(St1, St1.Size);
    // burada txt dosyanýn satýrlarýný okuyabiliriz...
    TempFs.Free;
    try
      DosyaIcerik := TStringList.Create;
      DosyaIcerik.LoadFromFile(GetEnvironmentVariable('TEMP')+ '\' + AlinacakBelgeAdi);
      Result:=DosyaIcerik;
    finally
      //DosyaIcerik.Free;
    end;
  end;

  // ******************************************************\\
  // bilgiler st1 içine geldi ise;
  if St1 <> nil then begin
    // sýkýþtýrýp veritabanýna yazalým..
    St2 := TMemoryStream.Create;
    St1.Position := 0;
    St2.Position := 0;
    ZCompressStream(St1, St2);
    // dosyayý içeri alalým..
    try
      // eski belgeyi pasif hale getirelim
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,
        'update TALIMATBELGELER set DURUM=0 where TALIMATID=&TalimatID ',
        ['&TalimatID'], [TalimatID]);
      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text:='Insert into TALIMATBELGELER (TALIMATID,BELGE,BELGEADI,SUREC,DURUM,SUBEID) values(:TalimatID, :Dosya ,:BelgeAdi,1,1,'+IntToStr(SubeId)+')  select scope_identity()';
      Tablo.Query4.ParamCheck;
      Tablo.Query4.Parameters[0].Value := TalimatID;
      Tablo.Query4.Parameters[1].LoadFromStream(St2, ftBlob);
      Tablo.Query4.Parameters[2].Value := AlinacakBelgeAdi;
      Tablo.Query4.Open;
    except
      Showmessage('Dosya veritabanýna yazýlamadý!');
    end;
  End;
  St2.Free;
end;

function TEBInputDataXMLOlustur(FrmAd,FrmAnh,SbNo,HesNo:string;BasTar,BitTar:TDateTime):string;
begin
(*
'<![CDATA[<HAREKETLER><SUBENO>105</SUBENO><HESNO>123134</HESNO><BASTAR>01/07/2011</BASTAR><BITTAR>11/07/2011</BITTAR><DETAYLAR></DETAYLAR></HAREKETLER>]]>'
*)
  Result := '<HESHARSORGU>';
  Result := Result + '<FIRMA_AD>'+FrmAd+'</FIRMA_AD>';
  Result := Result + '<FIRMA_ANAHTAR>'+FrmAnh+'</FIRMA_ANAHTAR>';
  Result := Result + '<SUBENO>'+SbNo+'</SUBENO>';
  Result := Result + '<HESNO>'+HesNo+'</HESNO>';
  Result := Result + '<BASTAR>'+StringReplace(StringReplace(FormatDateTime('dd/mm/yyyy',BasTar),'.','/',[rfReplaceAll]),'-','/',[rfReplaceAll])+'</BASTAR>';
  Result := Result + '<BITTAR>'+StringReplace(StringReplace(FormatDateTime('dd/mm/yyyy',BitTar),'.','/',[rfReplaceAll]),'-','/',[rfReplaceAll])+'</BITTAR>';
  Result := Result + '</HESHARSORGU>';
end;

function TEBHesapHareketleriniAl(BasTarih,BitTarih:TDateTime;BankaHesapID:Integer):Boolean;
var
  i,j,YerID,MusteriHesapID : Integer;
  SonHareketTarihi:Largeint;
  Kullanici,Sifre,ServiceID,Hesapno,TCNOVKNO,Strg : string;
  ctrls : TGirdiDenetimleri;
  Degisken : Variant;
  TWS:TEBWebServices;
  TWSResult:TEBWebServiceResult;
begin
  Result:=False;
  Tablo.TablodanSorguAc(3, 'Select * from BANKAFTP where BANKAKODU=32');
  Tablo.TablodanSorguAc(4, 'Select * from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID where BH.ID='+inttostr(BankaHesapID));
//  INGEX := GetEkstreSoap(False,'https://cm-online.ingbank.com.tr/ekstre.asmx?wsdl',HesapHareketleriDlg.HTTPRIOINGBank);
  if Tablo.Query3.FieldByName('EKSTREHERSEFERINDESOR').AsBoolean then begin
    ctrls := TGirdiDenetimleri.Create.Edit(('Kullanýcý Adý:'),@Degisken);
    if TGirisKutusuEx.BilgiAlEx('ING Bank Online Ekstre.',ctrls) = mrOK then begin
      Kullanici:=Degisken;
      ctrls := TGirdiDenetimleri.Create.Edit(('Þifre:'),@Degisken);
      if TGirisKutusuEx.BilgiAlEx('ING Bank Online Ekstre.',ctrls) = mrOK then
        Sifre := Degisken
      else
        Exit;
    end else
      Exit;
  end else begin
    Kullanici:=Tablo.Query3.FieldByName('EKSTREKULLANICI').AsString;
    Sifre:=Tablo.Query3.FieldByName('EKSTRESIFRE').AsString;
  end;
  ServiceID := Tablo.Query3.FieldByName('EKSTRESERVISID').AsString;
  Tablo.TablodanSorguAc(5, 'Select * from BANKAHESAPLAR where ID='+inttostr(BankaHesapID));
  Tablo.TablodanSorguAc(6, 'Select * from BANKASUBELER where ID='+Tablo.Query5.FieldByName('BANKASUBELERID').AsString);
  try
    TWS:=TEBEkstreWebServices.GetTEBWebServices(False,'https://ext.teb.com.tr/tebws/TEBWebServices?WSDL',HesapHareketleriDlg.HTTPSRIOTEB);
    //TWS:=TEBEkstreWebServices.GetTEBWebServices(False,'https://213.148.68.30/tebws/TEBWebServices?WSDL',HesapHareketleriDlg.HTTPSRIOTEB);
  Except
  end;
  TWSResult := TWS.TEBWebSrv(Kullanici,Sifre,ServiceID,'P',
                  TEBInputDataXMLOlustur(Tablo.Query3.FieldByName('EKSTREFIRMAADI').AsString,
                                        Tablo.Query3.FieldByName('EKSTREANAHTAR').AsString,
                                        Tablo.Query6.FieldByName('SUBEKODU').AsString,
                                        Tablo.Query5.FieldByName('HESAPNO').AsString,
                                        HesapHareketleriDlg.DateBaslangic.Date,
                                        HesapHareketleriDlg.DateBitis.Date));
 // TWSResult := TWS.TEBWebSrv('WSHSHRGON','9512364785','378','P','<HESHARSORGU><FIRMA_AD>feta</FIRMA_AD><FIRMA_ANAHTAR>nt26ft86bg</FIRMA_ANAHTAR><SUBENO>105</SUBENO><HESNO>123134</HESNO><BASTAR>'+FormatDateTime('DD/MM/YYYY',BasTarih)+'</BASTAR><BITTAR>'+FormatDateTime('DD/MM/YYYY',BitTarih)+'</BITTAR></HESHARSORGU>');
  //ServiceID:Firmalara banka tarafýndan verilen web servis numarasý
  //Anahtar da sanýrým teb in herkese farklý olarak verdiði bir numara.. ne iþe yaradýðýný bilmiyorum..
  //Environment:Web Servisin hangi ortamda çalýþacaðý bilgisi. (D-Development, T-Test, P-Production)
  if TWSResult.errorCode = '00' then begin
    HesapHareketleriDlg.TabHesapHareketleri.Close;
    HesapHareketleriDlg.TabHesapHareketleri.Parameters[0].Value := 32;
    HesapHareketleriDlg.TabHesapHareketleri.Parameters[1].Value := BankaHesapID;
    HesapHareketleriDlg.TabHesapHareketleri.Open;
    Strg:=TWSResult.outputDataXML;
    (*
    '<![CDATA[<HAREKETLER><SUBENO>105</SUBENO><HESNO>123134</HESNO><BASTAR>01/07/2011</BASTAR><BITTAR>11/07/2011</BITTAR><DETAYLAR></DETAYLAR></HAREKETLER>]]>'
    *)
    if TebXMLParse(BankaHesapID,Copy(Strg,10,Length(Strg)-12))>0 then
      Result:=True;
  end else
    raise Exception.Create(TWSResult.errorMsg);
end;

function TebXMLParse(BankaHesapID:Integer;XMLString:String):Integer;
var
  xml: TECXMLParser;
  strStream  : TStringStream;
  I,J: Integer;
  Hareketler,Detaylar,Detay : TXMLItem;
  BA,MusteriRef,GonderenAd,GonderenBanka,GonderenSube:string;
  Etiketler,Bilgiler : TArrayOfString;
begin
  Result:=0;
  if Pos('<DETAYLAR></DETAYLAR>',XMLString)=0 then begin //detay satýrý var ise..
    xml := TECXMLParser.Create(nil);
  //  xml.DefaultLargeTokenizer := True;
    strStream := TStringStream.Create(#13#10 + XMLString + #13#10);
    try
      xml.LoadFromStream(strStream);
      Hareketler := xml.Root;
      Detaylar := Hareketler.NamedItem['DETAYLAR'];
      Result := Result + Detaylar.Count;
      J:=0;
      for I := 0 to Detaylar.Count - 1 do begin
        Detay := Detaylar.SubItems[i];
        //refno alanýndan 2007032311553134670 gibi bir tarih dönecek..
        Tablo.TablodanSorguAc(1,'select ID from BANKAHESAPHAREKETLER where BANKAKODU=32 and REFNO='''+Detay.NamedItem['HAREKET_KEY'].Text+'''');
        //hareket daha önce alýnmýþ mý???
        if Tablo.Query1.RecordCount=0 then begin
          HesapHareketleriDlg.TabHesapHareketleri.Append;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BANKAKODU').AsInteger:=32;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BANKAHESAPID').AsInteger:=BankaHesapID;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('REFNO').AsString := Detay.NamedItem['HAREKET_KEY'].Text;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('TARIH').Value := Copy(Detay.NamedItem['ISLEM_TAR'].Text,1,2)+'/'+Copy(Detay.NamedItem['ISLEM_TAR'].Text,4,2)+'/'+Copy(Detay.NamedItem['ISLEM_TAR'].Text,7,4)+' '+Detay.NamedItem['ISLEM_TAR_SAAT'].Text;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('PROGRAMKOD').AsString := Detay.NamedItem['ISLEM_TUR'].Text;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('TUTAR').AsCurrency := StrToCurrDef(Detay.NamedItem['TUTAR'].Text,0.0);
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BAKIYE').AsCurrency := StrToCurrDef(Detay.NamedItem['ANLIK_BKY'].Text,0.0);
          //HesapHareketleriDlg.TabHesapHareketleri.FieldByName('KUR').AsString := Detay.NamedItem['PARAKOD'].Text;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('ACIKLAMA1').AsString := Detay.NamedItem['ACIKLAMA'].Text;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('ACIKLAMA2').AsString := Detay.NamedItem['ISLEM_ACK'].Text;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('REHBERKOD').AsString := Trim(Detay.NamedItem['MUSTERI_REF'].Text);//buradan rehberid bulunacak..

         {GonderenAd := Detay.NamedItem['GONDEREN_AD'].Text;
          GonderenBanka := Detay.NamedItem['GONDEREN_BANKA'].Text;
          GonderenSube := Detay.NamedItem['GONDEREN_SUBE'].Text;   }
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('SEC').AsBoolean := False;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger:=2;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BORCALACAK').AsString:=Detay.NamedItem['BA'].Text;
          if Detay.NamedItem['BA'].Text='A' then begin//borç'B'(para çýkýþý)/alacak'A'(para giriþi)
            HesapHareketleriDlg.TabHesapHareketleri.FieldByName('VKTCNO').AsString := Detay.NamedItem['BORCLU_VKN'].Text;
          end else if Detay.NamedItem['BA'].Text='B' then begin
            HesapHareketleriDlg.TabHesapHareketleri.FieldByName('VKTCNO').AsString := Detay.NamedItem['ALACAKLI_VKN'].Text;
            HesapHareketleriDlg.TabHesapHareketleri.FieldByName('TUTAR').AsCurrency := -1*HesapHareketleriDlg.TabHesapHareketleri.FieldByName('TUTAR').AsCurrency;
          end;
          HesapHareketleriDlg.TabHesapHareketleri.Post;
          inc(J);
        end;
      end;
    finally
      HesapHareketleriDlg.TabHesapHareketleri.Close;
      HesapHareketleriDlg.TabHesapHareketleri.Parameters[0].Value := 32;
      HesapHareketleriDlg.TabHesapHareketleri.Parameters[1].Value := BankaHesapID;
      HesapHareketleriDlg.TabHesapHareketleri.Open;
      xml.Free;
      strStream.Free;
    end;
  end;
  Result:=J;
(*<HAREKETLER>
	<SUBENO>Þube Numarasý</SUBENO>
	<HESNO>Hesap Numarasý</HESNO>
	<BASTAR>Baþlangýç Tarihi</BASTAR>
	<BITTAR>Bitiþ Tarihi</BITTAR>
	<DETAYLAR>
		<DETAY>
			<HAREKET_KEY> Ýlgili hareketin bildirim numarasý </HAREKET_KEY>
			<ISLEM_TAR>Hareket Ýþlem Numarasý</ISLEM_TAR>
			<BA>Borçlu Alacaklý Bilgisi</BA>
			<PARAKOD>Parakodu Bilgisi</PARAKOD>
			<TUTAR>Ýþlem Tutarý</TUTAR>
			<ACIKLAMA>Hareket Açýklama</ACIKLAMA>
			<MUSTERI_REF>Müþteri Referansý</MUSTERI_REF>
			<GONDEREN_AD>Gönderen Adý</GONDEREN_AD>
			<GONDEREN_BANKA>Gönderen Banka</GONDEREN_BANKA>
			<GONDEREN_SUBE>Gönderen Þube</GONDEREN_SUBE>
			<ISLEM_TAR_SAAT>Ýþlemim Saat Bilgisi</ISLEM_TAR_SAAT>
			<ANLIK_BKY>Anlýk Bakiye Bilgisi</ANLIK_BKY>
			<ISLEM_ACK>Ýþlem Açýklama</ISLEM_ACK>
			<ISLEM_TUR>Ýþlem Türü</ISLEM_TUR>
			<BORCLU_VKN>Borçlu VKN Bilgisi</BORCLU_VKN>
			<ALACAKLI_VKN>Alacaklý VKN Bilgisi</ALACAKLI_VKN>
		</DETAY>
	</DETAYLAR>
</HAREKETLER>  *)
end;

function TEBEkstreKasaTurGetir(ProgramKodu,BA:string):Integer;
begin //borç'B'(para çýkýþý)/alacak'A'(para giriþi)

  if ProgramKodu = '22'	then // TL Havale (Þubelerarasý)
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu = '23' then // YP Havale (Þubelerarasý)
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '24' then // EFT ile TL Havale (Yurtiçi Bankaya)
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '25' then // Adrese Gelen Havale Ödemesi
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '28' then // Müþteri Hesaplarý Arasýnda Virman
    Result := 43
  else if ProgramKodu =  '63' then // YP Hesaptan Baþka Bankaya Havale Göndermek
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '227' then // EFT Merkezinden Gelen Havaleyi Kaydetmek
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '260' then // Kurum Ödemeleri-Havale
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '378' then // Merkezi Vezne para yatýrma
    if BA='A' then
      Result:=41
    else
      Result:=42
  else if ProgramKodu =  '418' then // Gelen Havaleyi Kaydetme(Hesaba)
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '624' then // FET sisteminden Yapýlan Virman Ýþlemi
    Result:=43
  else if ProgramKodu =  '626' then // FET sisteminden Yapýlan Havale Ýþlemi
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '633' then // Kurum Ödemeleri-Virman
    Result:=43
  else if ProgramKodu =  '688' then // FET sisteminden Yapýlan YP Havale Ýþlemi
    if BA='A' then
      Result:=22
    else
      Result:=32
  else if ProgramKodu =  '1207' then // DBS Tahsilatý
    Result:=-99
  else
    Result:=-99;

end;


end.


