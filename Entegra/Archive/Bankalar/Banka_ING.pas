unit Banka_ING;
//iþlem tarihi belirtilemiyor ve havaleler tek satýr olarak gidebiliyor..
interface

uses SysUtils, Utablo, UTalimatWizard, Fetautil, Windows , Messages, Variants, Classes,ZLIBEX,DB,
    Graphics, Controls, Forms, Dialogs, StdCtrls, INGBankBordro_TLB, ShellAPI, FetaKurulusSiniflari,
    UBinarySave,INGEkstreWebService,UGirisKutusuEx,XSBuiltIns,UFDCompatHelpers  ;  // ScSSHUtil

Function ING_Dosya_Olustur(TabKaynak:TFDQuery) : string ;
Function ING_AkibetSonucunuKaydet(TalimatID:Integer; var AkibetSatirlari:TStringList):Boolean;
function ING_AkibetAl(TalimatID:Integer):TStringList;
function INGHesapHareketleriniAl(BasTarih,BitTarih:TDateTime;BankaHesapID:Integer):Boolean;
function INGEkstreKasaTurGetir(ProgramKodu:string;Tutar:Currency):Integer;
Function INGHesapNoDuzenle(Subeno,Hesapno:String):string;
Function INGStringToCurrency(Str:String):Currency;
Function INGAciklamadanTCNoVKNoAyikla(Aciklama:String):String;
Function INGAciklamadanHesapIDAyikla(Aciklama:String):Integer;
function INGAciklamadanCariKodAyikla(Aciklama:String):String;


var
  INGEX:EkstreSoap;

implementation

uses UHesapHareketleri,PrjConst;

//Resourcestring
//  talhata =  'Talimat Hatasý: ';
//  borhata =  'Bordro Hatasý: ';

Function ING_Dosya_Olustur(TabKaynak:TFDQuery): string;
var
  MasrafBilgisi : SmallInt;
  Tutar:Currency;
  tal:_Talimat;
  bor:_NYSBordro;
  hat:_Hata;
  OdemeTarihi,EvrakNo,FirmaAd ,BorcluVergiNo,BorcluHesapNo,BorcluSubeKod,BorcluFirmaUnvan,BorcluFirmaKod,BorcluBankaKodu
  ,AlacakliBankaKod, AlacakliVergiNo,AlacakliAdres,AlacakliTelefonNo,AlacakliFaksNo,AlacakliePosta1
  ,AlacakliOtomatikAciklama,AlacakliHesapNo, AlacakliSubeKod,AlacakliFirmaUnvan,AlacakliFirmaKod,TCMBOdemeTuru
  ,FirmayaOzel1,FirmayaOzel2,FirmayaOzel3,FirmayaOzel5,endLine,AlacakliIBAN,TamYol: WideString;
begin
  //dll register edilmeye çalýþýlýr.. zaten edilmiþ ise yapcak birþey yok..
  ShellExecute(0{Handle}, 'open',pwidechar('cmd.exe'),pwidechar('Regsvr32 '+GetCurrentDir+'\nys\INGBankBordro.DLL'),nil,sw_hide);
  //ShellExecute(0,nil,pwidechar('cmd.exe'),pwidechar('Regsvr32 '+GetCurrentDir+'\INGBankBordro.DLL'),nil,sw_hide);

  //Bilgiler deðiþkenlere atanýr... [DCC Error] Banka_ING.pas(38): E2036 Variable required
  OdemeTarihi := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',TalimatWizardDlg.DateIslem.Date);
  EvrakNo := 'ING'+FormatDateTime('yyyymmddhhnnss', Tablo.GENINI.BuguntrhSaat);
  FirmaAd := Tablo.TabBizim.FieldByName('FIRMA').AsString;
  //Bordro Oluþturulur
  bor := CoNYSBordro.Create;
  hat := CoHata.Create;
  //ve baþlýk bilgileri girilir...
  bor.OdemeTarihi := OdemeTarihi;
  bor.EvrakNo := EvrakNo;
  bor.FirmaAd  := FirmaAd;
  TabKaynak.First;
  while not TabKaynak.eof do begin
    tal := CoTalimat.Create;
    //bilgiler girilir....
    BorcluVergiNo := TabKaynak.FieldByName('G_VNO').AsString;
    BorcluHesapNo := TabKaynak.FieldByName('G_HESAPNO').AsString;
    BorcluSubeKod := TabKaynak.FieldByName('G_SUBE_KODU').AsString;
    BorcluFirmaUnvan := Tablo.TabBizim.FieldByName('FIRMA').AsString;
    BorcluFirmaKod := TabKaynak.FieldByName('G_MUSTERINO').AsString;
    BorcluBankaKodu := '99';
    //tal.BorcluMuhasebeReferansNo := '100.01.001';
    //tal.BorcluKullaniciAciklama := 'biz';
    //tal.BorcluOtomatikAciklama := 'otomatik açýklama';
    tal.BorcluVergiNo := BorcluVergiNo;
    tal.BorcluHesapNo := BorcluHesapNo;
    tal.BorcluSubeKod := BorcluSubeKod;
    tal.BorcluFirmaUnvan := BorcluFirmaUnvan;
    tal.BorcluFirmaKod := BorcluFirmaKod;
    tal.BorcluBankaKod := BorcluBankaKodu;
    AlacakliIBAN := '';
    if Length(TabKaynak.FieldByName('IBAN').AsString)>15 then
      AlacakliBankaKod :=       TabKaynak.FieldByName('BANKAKODU').AsString
    else
      AlacakliBankaKod :=       Copy(TabKaynak.FieldByName('IBAN').AsString,5,5);
    AlacakliVergiNo :=          StringReplace(TabKaynak.FieldByName('VNO').AsString,' ','',[rfReplaceAll]);
    AlacakliAdres :=            TabKaynak.FieldByName('ADRES').AsString;
    AlacakliTelefonNo :=        StringReplace(TabKaynak.FieldByName('ISTEL').AsString,' ','',[rfReplaceAll]);
    AlacakliFaksNo :=           StringReplace(TabKaynak.FieldByName('FAX').AsString,' ','',[rfReplaceAll]);
    AlacakliePosta1 :=          StringReplace(TabKaynak.FieldByName('EMAIL').AsString,' ','',[rfReplaceAll]);
    AlacakliOtomatikAciklama := TabKaynak.FieldByName('ACIKLAMA').AsString;
    AlacakliHesapNo :=          TabKaynak.FieldByName('HESAPNO').AsString;
    AlacakliSubeKod :=          TabKaynak.FieldByName('SUBEKODU').AsString;
    AlacakliFirmaUnvan :=       TabKaynak.FieldByName('UNVAN').AsString;
    AlacakliFirmaKod :=         TabKaynak.FieldByName('REHKOD').AsString;
    AlacakliIBAN :=             TabKaynak.FieldByName('IBAN').AsString;
    FirmayaOzel1 :=             'RehberID:'+TabKaynak.FieldByName('REHID').AsString;
    FirmayaOzel2 :=             'RehberKod:'+TabKaynak.FieldByName('REHKOD').AsString;
    FirmayaOzel3 :=             'RehberUnvan:'+TabKaynak.FieldByName('UNVAN').AsString;
    FirmayaOzel5 :=             '12312';

    //tal.AlacakliBabaAdi := 'deneme';
    tal.AlacakliVergiNo := AlacakliVergiNo;
    tal.AlacakliAdres := AlacakliAdres;
    tal.AlacakliTelefonNo := AlacakliTelefonNo;
    tal.AlacakliFaksNo := AlacakliFaksNo;
    tal.AlacakliePosta1 :=AlacakliePosta1;
    tal.AlacakliePosta2 := AlacakliePosta1;
    //tal.AlacakliMuhasebeReferansNo := '120.01.001';
    tal.AlacakliOtomatikAciklama := AlacakliOtomatikAciklama;
    tal.AlacakliBankaKod := AlacakliBankaKod;
    if Length(TabKaynak.FieldByName('IBAN').AsString)>15 then begin
      tal.AlacakliHesapNo  := AlacakliIBAN;
      AlacakliSubeKod      := '90001';
      tal.AlacakliSubeKod  := AlacakliSubeKod;
    end else begin
      tal.AlacakliHesapNo  := AlacakliHesapNo;
      tal.AlacakliSubeKod  := AlacakliSubeKod;
    end;
    tal.AlacakliFirmaUnvan := AlacakliFirmaUnvan;
    tal.AlacakliFirmaKod := AlacakliFirmaKod;
    MasrafBilgisi := 0;
    TCMBOdemeTuru := '99';
    Tutar := TabKaynak.FieldByName('TUTAR').AsCurrency;
   // tal.TCMBOdemeKodu := TCMBOdemeTuru;

    tal.MasrafBilgisi := MasrafBilgisi;
    tal.tutar := Tutar;
    tal.FirmayaOzel1 := FirmayaOzel1;
    tal.FirmayaOzel2 := FirmayaOzel2;
    tal.FirmayaOzel3 := FirmayaOzel3;
    tal.FirmayaOzel5 := FirmayaOzel5;
    try
      tal.Kaydet;
    Except
      raise Exception.Create(talhata+tal.Get_Hatalar);  //tal.Kaydet; çalýþmadan önce hata oluþmuyor..
    end;
    bor.Talimat_Olustur(tal);
    TabKaynak.next;
  end;
  if StrToInt(bor.HataAdet) = 0 then
    if StrToInt(bor.HataliTalimatAdet) = 0  then begin
      bor.Kaydet;
      TamYol := GetCurrentDir+'\Talimat\'+'ISF'+bor.BordroAd;
      //bor.ExportDosya(TamYol);
    end Else
      raise Exception.Create(talhata+tal.Get_Hatalar)
  else
    raise Exception.Create(borhata+endLine);

  TalimatWizardDlg.INGDosyaSifresi:=bor.BordroPassword;
  Result := 'ISF'+bor.BordroAd;
  //if RenameFile(GetCurrentDir+'\Talimat\'+Result,GetCurrentDir+'\Talimat\'+Result+'_'+bor.BordroPassword)then
  //  Result := Result+'_'+bor.BordroPassword;

end;


Function ING_AkibetSonucunuKaydet(TalimatID:Integer; var AkibetSatirlari:TStringList):Boolean;
var
  I,SiraNo,Durum:Integer;
  AkibetSonuc:string;
begin
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

function ING_AkibetAl(TalimatID:Integer):TStringList;
var
  st1,st2:TMemoryStream;
  TempFs:TFileStream;
  FTPDestination,GonderilmisBelgeAdi,AlinacakBelgeAdi:string;
  DosyaIcerik:TStringList;
begin
(*  // Talimata Bakalým
  Tablo.TablodanSorguAc(1, 'Select * from TALIMATLAR where ID=' + inttostr(TalimatID));
  // gitmiþ olan belgeyi açalým..
  Tablo.TablodanSorguAc(2, 'Select * from TALIMATBELGELER where DURUM=1 and SUREC=1 and TALIMATID=' + inttostr(TalimatID));
  GonderilmisBelgeAdi := Tablo.Query2.FieldByName('BELGEADI').AsString;
  Tablo.TablodanSorguAc(3, 'Select * from BANKAFTP where BANKAKODU=99');
  St1 := TMemoryStream.Create;
  //güvenlik bilgilerini girelim...
  if Tablo.Query3.FieldByName('FTP_GUVENLIK_TURU').AsString = 'SSH' then begin
    if Tablo.Query3.FieldByName('FTP_USER').AsBoolean=False then begin //'FTP_AUTHENTICATION'  alanýnýn deðerine göre
      Tablo.ScSSHClient1.Authentication := atPassword;
      Tablo.ScSSHClient1.User := Tablo.Query3.FieldByName('FTP_USER').AsString;
      Tablo.ScSSHClient1.PassWord := Tablo.Query3.FieldByName('FTP_PASSWORD').AsString;
    end else if Tablo.Query3.FieldByName('FTP_USER').AsBoolean=True then begin
      Tablo.ScSSHClient1.Authentication := atPublicKey;
      Tablo.ScSSHClient1.User := Tablo.Query3.FieldByName('FTP_USER').AsString;
      KutuktenOku(Tablo.Query3, 'FTP_PRIVATE_KEY', 'TempKey.key', True);
      Tablo.ScSSHClient1.PrivateKeyName := 'TempKey.key';
    end;
    Tablo.ScSSHClient1.HostName := Tablo.Query3.FieldByName('FTP_ADRES').AsString;
    // ScSSHClient1.HostKeyAlgorithms.Assign(TabBankaAyar.FieldByName('FTP_HOST_KEY_ALGORITHM').asstring) ;//yada ssh-dss  yada ikisi birden...
    Tablo.ScSSHClient1.Port := Tablo.Query3.FieldByName('FTP_PORT').AsInteger;
    //ScSSHClient1.HostKeyName := Query4.FieldByName('FTP_HOST_KEY_NAME').AsString;
    //ScFileStorage1.PassWord := Query4.FieldByName('FTP_HOST_KEY_PASSWORD').AsString;
    FTPDestination := Tablo.Query3.FieldByName('FTP_DIZIN_AKIBET').AsString;
    FTPDestination := StringReplace(FTPDestination,'/','\',[rfReplaceAll]);
    if copy(FTPDestination,1,1)<>'\' then
      FTPDestination := '\'+FTPDestination;
    if copy(FTPDestination, length(FTPDestination),1) <> '\' then
      FTPDestination := FTPDestination + '\';
    //if copy(FTPDestination, length(FTPDestination),1) = '\' then
    //  FTPDestination := copy(FTPDestination, 1, length(FTPDestination)-1);
    try
      Tablo.ScSSHClient1.Connect;
    Except
      raise Exception.Create('Baðlantýda Hata(SFTP): Baðlantý Kurulamadý!');
    end;
    if not Tablo.ScSFTPClient1.Active then
     Tablo.ScSFTPClient1.Initialize;
    //dosyaadýný bulalým...
    // stream to file.. yoksa alamayiz....
    try
    //gönderdiðimiz
    // ISF000080445001020110426_58696 dosyasý için;
    //AISF000080445001020110426.txt  dosyasýný alacaðýz..
      AlinacakBelgeAdi := 'A'+Copy(GonderilmisBelgeAdi,1,pos('_',GonderilmisBelgeAdi)-1)+'.txt';
      Tablo.ScSFTPClient1.DownloadFile(FTPDestination+AlinacakBelgeAdi,GetEnvironmentVariable('TEMP') + '\' + AlinacakBelgeAdi, True);
      // Result := GonderilmisBelgeAdi;
    Except
      raise Exception.Create('Baðlantýda Hata(SFTP): Dosya Transfer Edilemedi!');
    end;
    Tablo.ScSFTPClient1.Disconnect;
    Tablo.ScSSHClient1.Disconnect;
  end Else if Tablo.Query3.FieldByName('FTP_GUVENLIK_TURU').AsString = 'SSL' then begin
    raise Exception.Create('Baðlantý türü desteklenmiyor!');
  end Else if Tablo.Query3.FieldByName('FTP_GUVENLIK_TURU').AsString = 'Yok' then begin
    raise Exception.Create('Baðlantý türü desteklenmiyor!');
  end Else
    raise Exception.Create('FTP Bilgileri Yok yada Hatalý!');

  // ******************************************************\\
  (* st1 deki akibete istedimizi yapabiliriz.. *)
  if AlinacakBelgeAdi <> '' then begin
    try
      DosyaIcerik := TStringList.Create;
      DosyaIcerik.LoadFromFile(GetEnvironmentVariable('TEMP')+ '\' + AlinacakBelgeAdi);
      Result:=DosyaIcerik;
    finally
      //DosyaIcerik.Free;
    end;
    // Temp içinde text i oluþturalým..buradan txt açýp bilgileri okuyalým..
    TempFs := TFileStream.Create(GetEnvironmentVariable('TEMP')+ '\' + AlinacakBelgeAdi, fmCreate);
    St1.Position := 0;
    TempFs.Position := 0;
    St1.CopyFrom(TempFs,TempFs.Size);
    //TempFs.CopyFrom(St1, St1.Size);
    // burada txt dosyanýn satýrlarýný okuyabiliriz...
    TempFs.Free;
  // ******************************************************\\
  // bilgiler st1 içine geldi ise;
    if St1 <> nil then begin
      // sýkýþtýrýp veritabanýna yazalým..
      St2 := TMemoryStream.Create;
      St1.Position := 0;
      St2.Position := 0;
      ZCompressStream(St1, St2);
      St1.Free;
      // dosyayý içeri alalým..
      try
        // eski belgeyi pasif hale getirelim
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update TALIMATBELGELER set DURUM=0 where TALIMATID=&TalimatID ',['&TalimatID'], [TalimatID]);
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

end;

Function INGHesapNoDuzenle(Subeno,Hesapno:String):string;
begin
  // hesapnoyu sorgudan istenilecek hale getirir..
  //12312312-1 þeklinde bir hesap varsa;
  if Pos('-',Hesapno)=0 then
    Hesapno:=Hesapno+'-1';
  Result:=Subeno+'-C-'+Hesapno//copy(Hesapno,1,Pos('-',Hesapno))+'MT-'+copy(Hesapno,Pos('-',Hesapno)+1,Length(Hesapno));

end;

Function INGStringToCurrency(Str:String):Currency;
var TempStr:string;
Begin
  try
    TempStr := StringReplace(Str,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
    TempStr := StringReplace(TempStr,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
  finally
    Result := StrToCurrDef(TempStr,0.0);
  end;
End;

Function INGAciklamadanTCNoVKNoAyikla(Aciklama:String):String;
var
  Baslangic,Bitis:Integer;
Begin
  Baslangic := Pos('VKN/TCKN:',Aciklama)+9;
  if Length(Aciklama) in [Baslangic+10,Baslangic+11] then
    Bitis := Length(Aciklama)
  else
    Bitis := Pos(' BANKA/ÞUBE:',Aciklama);
  Result:=Copy(Aciklama,Baslangic,Bitis);
End;

function INGAciklamadanCariKodAyikla(Aciklama:String):String;
var
  i,j:Integer;
begin
  //açýklama2 den cari kod alýnýr
 (*320.01.1000 GÖND.
  301.02.030. GÖND.
  320.01.1082 GÖND.
  320.01.1108 GÖND.
  320.01.347. GÖND.
  320.01.185. GÖND. gibi açýklamar için;  *)
  j:=0;
  for I := 0 to Length(Aciklama)-1 do
    if (Copy(Aciklama,i,1)='.') or (Copy(Aciklama,i,1)='0') or (Copy(Aciklama,i,1)='1') or (Copy(Aciklama,i,1)='2') or (Copy(Aciklama,i,1)='3') or (Copy(Aciklama,i,1)='4') or
       (Copy(Aciklama,i,1)='5') or (Copy(Aciklama,i,1)='6') or (Copy(Aciklama,i,1)='7') or (Copy(Aciklama,i,1)='8') or (Copy(Aciklama,i,1)='9') then
       if j = i-1 then
          j:= i;//burada kod kaçýncý karaktere kadar uzuyor onu hesaplarýz..
  while Copy(Aciklama,j,1)='.' do
    j:=j-1; //son karakter '.' olamaz!!!!
  Result:= Copy(Aciklama,0,j);
end;


Function INGAciklamadanHesapIDAyikla(Aciklama:String):Integer;
var
  Hesapno,Subeno:string;
Begin
(*
Ahmetten Alýnan
GELEN EFT- ULTRA-EMAR SAÐLI-112IM2447335
DENIZ ECZA DEPOSU TI-112OM30425113
POLIMED ILAC VE TIBB-112OM30425118
Test Hesap Hareketlerinden gelen..
INT TLM NO:2017175 199-C-7315-MT-1 TANER
INT TLM NO:2017175 199-C-7315-MT-1 TANER
INT TLM NO:2017175 199-C-7315-MT-1 TANER
*)
  Result:=-99;
  Hesapno := Copy(Aciklama,(Length(Aciklama)-5),6);
  Subeno := Copy(Aciklama,(Length(Aciklama)-10),3);
  if (StrToIntDef(Hesapno,-99)<>-99)and(StrToIntDef(Subeno,-99)<>-99)then begin
    Tablo.TablodanSorguAc(1,'select BH.ID from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID where BH.HESAPNO like ''%'+Hesapno+'%'' and BS.SUBEKODU like ''%'+Subeno+'%''');
    if Tablo.Query1.RecordCount=1 then
      Result:=Tablo.Query1.Fields[0].AsInteger;
  end;
End;

function INGHesapHareketleriniAl(BasTarih,BitTarih:TDateTime;BankaHesapID:Integer):Boolean;
var
  i,j,YerID,MusteriHesapID : Integer;
  SonHareketTarihi:Largeint;
  Kullanici,Sifre,Hesapno,TCNOVKNO : string;
  Hareketler : HareketlerBakiye;
  //Bakiyeesap : Array_Of_HareketlerBakiyeHesap;
  ctrls : TGirdiDenetimleri;
  Degisken : Variant;
  Etiketler,Bilgiler : TArrayOfString;
begin
  Tablo.TablodanSorguAc(3, 'Select * from BANKAFTP where BANKAKODU=99');
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
  //(subeno-C-hesno-MT-1 formatýnda MT ve MY hesaplar)
  Tablo.TablodanSorguAc(5, 'Select * from BANKAHESAPLAR where ID='+inttostr(BankaHesapID));
  Tablo.TablodanSorguAc(6, 'Select * from BANKASUBELER where ID='+Tablo.Query5.FieldByName('BANKASUBELERID').AsString);
  try
    INGEX := GetEkstreSoap(False,'https://cm-online.ingbank.com.tr/ekstre.asmx?wsdl',HesapHareketleriDlg.HTTPRIOINGBank);
  Except
  end;
  Hareketler := INGEX.Sorgula(Kullanici,Sifre,
              INGHesapNoDuzenle(Tablo.Query4.FieldByName('SUBEKODU').AsString,Tablo.Query4.FieldByName('HESAPNO').AsString),
              FormatDateTime('DD/MM/YYYY',BasTarih),
              FormatDateTime('DD/MM/YYYY',BitTarih),'');
  if Hareketler.hataKodu = '0' then begin
    HesapHareketleriDlg.TabHesapHareketleri.Close;
    HesapHareketleriDlg.TabHesapHareketleri.Parameters[0].Value := 99;
    HesapHareketleriDlg.TabHesapHareketleri.Parameters[1].Value := BankaHesapID;
    HesapHareketleriDlg.TabHesapHareketleri.Open;
    for I := 0 to Length(Hareketler.Hesap) - 1 do begin
      {Hareketler.Hesap[I].HesapNo;
      Hareketler.Hesap[I].HesapAdi;
      Hareketler.Hesap[I].ParaKod;
      Hareketler.Hesap[I].MusteriNo;
      Hareketler.Hesap[I].SubeKodu;
      Hareketler.Hesap[I].SubeAdi;
      Hareketler.Hesap[I].HesapAcilisTarihi;
      Hareketler.Hesap[I].Hareket;}
      SonHareketTarihi:=Tablo.Query5.FieldByName('SONHAREKETTARIHI').AsLargeInt;
        //Hareketler.Hesap[I].Bakiye;
      for J := 0 to Length(Hareketler.Hesap[I].Hareket) - 1 do begin
        //refno alanýndan 2007032311553134670 gibi bir tarih dönecek..
        Tablo.TablodanSorguAc(1,'select ID from BANKAHESAPHAREKETLER where BANKAKODU=99 and REFNO='''+Hareketler.Hesap[I].Hareket[j].RefNo+'''');
        //hareket daha önce alýnmýþ mý???
        if Tablo.Query1.RecordCount=0 then begin
          HesapHareketleriDlg.TabHesapHareketleri.Append;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BANKAKODU').AsInteger:=99;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BANKAHESAPID').AsInteger:=BankaHesapID;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('TARIH').AsDateTime:=StrToDateTime(Copy(Hareketler.Hesap[I].Hareket[j].Tarih,1,2)+FormatSettings.DateSeparator+Copy(Hareketler.Hesap[I].Hareket[j].Tarih,4,2)+FormatSettings.DateSeparator+Copy(Hareketler.Hesap[I].Hareket[j].Tarih,7,4) +' '+Hareketler.Hesap[I].Hareket[j].IslemSaati);
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('ISLEMSUBE').AsString:=Hareketler.Hesap[I].Hareket[j].IslemSube;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('FISNO').AsString:=Hareketler.Hesap[I].Hareket[j].FisNo;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('VALOR').AsString:=Hareketler.Hesap[I].Hareket[j].Valor;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('TUTAR').AsCurrency:=INGStringToCurrency(Hareketler.Hesap[I].Hareket[j].Tutar);
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('BAKIYE').AsCurrency:=INGStringToCurrency(Hareketler.Hesap[I].Hareket[j].Bakiye);
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('ACIKLAMA1').AsString:=Hareketler.Hesap[I].Hareket[j].Aciklama1;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('ACIKLAMA2').AsString:=Hareketler.Hesap[I].Hareket[j].Aciklama2;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('PROGRAMKOD').AsString:=Hareketler.Hesap[I].Hareket[j].ProgramKod;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('REFNO').AsString:=Hareketler.Hesap[I].Hareket[j].RefNo;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger:=2;
          HesapHareketleriDlg.TabHesapHareketleri.FieldByName('SEC').AsBoolean := False;
          HesapHareketleriDlg.TabHesapHareketleri.Post;
          if SonHareketTarihi<StrToInt64(Hareketler.Hesap[I].Hareket[j].RefNo) then
             SonHareketTarihi:=StrToInt64(Hareketler.Hesap[I].Hareket[j].RefNo);
        end;
      end;
    end;
    Tablo.Query5.Edit;
    Tablo.Query5.FieldByName('SONHAREKETTARIHI').AsLargeInt := SonHareketTarihi;
    try
      Tablo.Query5.FieldByName('BAKIYE').AsCurrency := INGStringToCurrency(Hareketler.Hesap[I].Bakiye);
    except
    end;

    Tablo.Query5.Post;
    Result:=True;
  end else
    raise Exception.Create(Hareketler.hataAciklama);
end;


function INGEkstreKasaTurGetir(ProgramKodu:string;Tutar:Currency):Integer;
begin
  if ProgramKodu='TRF' then  // Havale Gelen/Giden
    if Tutar>0 then
      Result := 22
    else
      Result := 32
  else if ProgramKodu='VRM' then // Hesaplararasý Aktarým
    Result := 43
  else if ProgramKodu='EFT' then // Gelen/Giden EFT
    if Tutar>0 then
      Result := 22
    else
      Result := 32
  else if ProgramKodu='HSY' then // Hesaba Yatan
    Result := 41
  else if ProgramKodu='FEX' then // Döviz Alýþ/Satýþ
    if Tutar>0 then
      Result := 48
    else
      Result := 47
  else if ProgramKodu='BND' then
    Result := -99 // Hazine Bonosu Alýþ/Satýþ
  else if ProgramKodu='IFN' then
    Result := -99 // Yatýrým Fonu Alýþ/Satýþ
  else if ProgramKodu='CHK' then
    if Tutar>0 then
      Result := 53 //çek tahsilat 53
    else
      Result := 51 //çek ödeme 51
  else if ProgramKodu='BOE' then
    Result := -99 // Senet Tahsilatý / Senet Ödeme
  else if ProgramKodu='TDP' then
    Result := -99 // Vadeli Mevduat Ýþlemleri
  else if ProgramKodu='LDP' then
    Result := -99 // Kredi Kullaným/Geri Ödeme
  else if ProgramKodu='INT' then
    Result := -99 // Faiz Gelirleri / Giderleri
  else if ProgramKodu='EXP' then
    Result := -99 // Ýhracat Tahsilatý
  else if ProgramKodu='IMP' then
    Result := -99 // Ýthalat Ödemeleri
  else if ProgramKodu='IMC' then
    Result := -99 // Ýthalat Masrafý
  else if ProgramKodu='SEC' then
    Result := -99 // Repo Açýlýþ/Geridönüþ
  else if ProgramKodu='SUF' then
    Result := -99 // Ýthalat Vergi Fon Ödemesi
  else if ProgramKodu='TAX' then
    Result := -99 // Stopaj Vergi
  else if ProgramKodu='CHG01' then
    Result := -99 // Banka Masraflarý (Çek)
  else if ProgramKodu='CHG02' then
    Result := -99 // Banka Masraflarý (Yurtdýþý Havale)
  else if ProgramKodu='CHG03' then
    Result := -99 // Banka Masraflarý (Diðer)
  else if ProgramKodu='COM' then
    Result := -99 // Teminat Mektubu Komisyonu
  else if ProgramKodu='DDB' then
    Result := -99 // Doðrudan Borçlandýrma Ýþlemleri
  else if ProgramKodu='INV' then
    Result := -99 // Fatura Ödemeleri
  else if ProgramKodu='PRO' then
    Result := -99 // Senet Protesto Masrafý
  else if ProgramKodu='CCP' then
    Result := -99 // Kredi Kartý Ýþlemleri
  else if ProgramKodu='MSC' then
    Result := -99 //  Diðer Ýþlemler
  else
    Result := -99 //Tanýmsýz.. anlamsýz..
end;

end.


