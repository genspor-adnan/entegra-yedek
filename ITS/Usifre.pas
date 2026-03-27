unit USifre;

interface

uses  StdCtrls, Buttons, Controls, Classes, Forms, dbtables, Dialogs, ADODb,
  Grids, DBGrids, Graphics, ExtCtrls, sysutils, Windows, ImgList, ComCtrls,
  ToolWin,  jpeg,  Menus, LocUtils, DB, cxGraphics, dxSkinsCore,
  cxControls,Registry, ShellAPI,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  dxSkinLondonLiquidSky, cxButtonEdit, dxSkinBlack, dxSkinBlue, dxSkinCoffee, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, cxLookAndFeelPainters, cxButtons,
  cxLookAndFeels, dxSkinBlueprint, dxSkinCaramel, dxSkinDarkRoom,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
    dxSkinOffice2007Blue,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
   dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinVS2010, dxSkinWhiteprint;
//A ULisansEski,
type
  TPasswordDlg = class(TForm)
    ImageList1: TImageList;
    Label1: TLabel;
    Image2: TImage;
    ComboAd: TcxComboBox;
    cbLanguages: TcxComboBox;
    TabKullanici: TADOQuery;
    Password: TcxTextEdit;
    Label2: TLabel;
    cbDBList: TcxComboBox;
    BEditDBList: TcxButtonEdit;
    cmbKullanýcýTipi: TcxComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CancelBtn: TcxButton;
    OkBtn: TcxButton;
    Image1: TImage;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Image2DblClick(Sender: TObject);
    procedure cbLanguagesChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbDBListPropertiesInitPopup(Sender: TObject);
    procedure cbDBListPropertiesCloseUp(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbLanguagesPropertiesChange(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
  private
    { Private declarations }
    FDLLList : TDllInfoList;
     procedure OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
     procedure PopulateComboBox(CB : TcxComboBox);
  public
    { Public declarations }
    Modul, Sifre : String;
  end;
resourcestring
  SLangChanged = 'Program dili deðiþti ("%s").'#13#10' Geçerli olabilmesi için yeniden baþlatmalýsýnýz';
var
  PasswordDlg : TPasswordDlg;

  function PasswordEkrani(Modul:String) : Boolean;
implementation

uses UTablo, UCombo, UPaylasim, UMesaj, FetaUtil, UGenSifre;//, USifDeg; //A ULisans,
const
  RegBasKey = 'Software\GENTEGRE2';
var
   kapat : Boolean;
   YanlisSay : SmallInt;
   s, BilgisayarKodu : String[3];

{$R *.DFM}

procedure ServerAcikMi;
//var p   : TPing;
//    sl  : TStringList;
begin
  {sl:=TStringList.Create;
  p:=TPing.Create(nil);
  try
    Session.GetAliasParams('GENOTIPSQL', sl);
    p.Address:=sl.Values['SERVER NAME'];
    if p.Address='.' then p.Address := '127.0.0.1';
    if P.Ping = 0 then
       if Application.MessageBox(PChar('''+p.Address+'' adlý bilgisayara ulaþýlamýyor.'#13'Kablolarýnýzý kontrol edin..'#13'Devam etsin mi?'), 'Dikkat! Network hatasý!!!',MB_YESNO)<>IDYES then
          halt;
  finally
    sl.Free;
    p.Free;
  end;
  }
end;

function PasswordEkrani(Modul:String) : Boolean;
var sonuc : Boolean;
begin
   //ServerAcikMi;
  // Added by Adnan 03/01/2011 12:09:34  LisansKontrolu;
  // Added by Adnan 03/01/2011 12:09:34   MemAc;
   //Tablo.TabKullan.Open;
   // Added by Adnan 03/01/2011 12:09:34 s := MemReadString;
   Application.CreateForm(TPasswordDlg, PasswordDlg);
   PasswordDlg.Modul := Modul;
   PasswordDlg.ShowModal;
   sonuc := PasswordDlg.ModalResult = mrOk;
   if sonuc then  begin
      GenRegIni.RegWriteString('','KullanAdi', KullanAdi,'C');
      GenRegIni.RegWriteString('','KullanKodu', Kullanan,'C');
   end;
   PasswordDlg.Destroy;
   result := sonuc;
//   MemWriteString('000');
end;

procedure TPasswordDlg.OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
begin
  MessageBox(0, PChar(Format(SLangChanged, [AInfo.EnglishName])),
            'Dikkat', MB_OK + MB_ICONEXCLAMATION);
  Restart := False;
end;

procedure TPasswordDlg.PopulateComboBox(CB : TcxComboBox);
var
  I : integer;
  CurInfo : TDLLInfoItem;
begin
  FDLLList.Clear;

  if not Localizer.GetDllsInfo(FDLLList) then Exit; //can't get list of resource DLLs

  CurInfo := Localizer.GetCurrentInfo;
  for I := 0 to FDLLList.Count - 1 do
  begin
    CB.Properties.Items.Add(FDLLList[I].EnglishName);
    if CurInfo.Locale = FDLLList[I].Locale then
       CB.ItemIndex := I;
  end;
end;

procedure TPasswordDlg.FormCreate(Sender: TObject);
begin
  YanlisSay := 0;
  TabKullanici.Close;
  TabKullanici.SQL.Text := 'select K.ID,K.REHBERID,K.SIFRE,K.KOD,K.ROLID,K.DURUM,R.FIRMA '+
                           ' from REHBER R inner join KULLANICI K on K.REHBERID=R.ID where R.DURUM=1 order by 1';
  TabKullanici.Open;
  ComboAd.Clear;
  TabKullanici.first;
  while not TabKullanici.eof do begin
     ComboAd.Properties.Items.Add(TabKullanici.Fieldbyname('FIRMA').AsString);
     TabKullanici.next;
  end;
  ComboAd.Text := GenRegIni.RegReadString('','KullanAdi', '','C');
  BilgisayarKodu := GenRegIni.RegReadString('','BilgisayarKodu', '','C');


end;

procedure TPasswordDlg.FormDestroy(Sender: TObject);
begin
  FDLLList.Free;
end;

procedure TPasswordDlg.FormShow(Sender: TObject);
var
  i:Integer;
  cnnstr:string;
  matched:Boolean;
begin
  Password.Text := '';
  Password.Properties.EchoMode := eemPassword;
  Password.SetFocus;
   //Dil

    //firmaadý
  matched := False;
  Tablo.TablodanSorguAc(3,'select * from BAGLANTILAR where DURUM=1 and TUR like ''%0%''');
  cnnstr := Tablo.cnn.ConnectionString;
  while (not Tablo.Query3.Eof) and (not matched)do begin
    if ( UpperCase(cnnstr) = UpperCase(Tablo.ConnectionStringOlustur(Tablo.Query3.FieldByName('SERVERADRESI_YAKIN').AsString,Tablo.Query3.FieldByName('KULLANICIADI').AsString,Tablo.Query3.FieldByName('SIFRE').AsString,Tablo.Query3.FieldByName('VERITABANI').AsString)))
     or( UpperCase(cnnstr) = UpperCase(Tablo.ConnectionStringOlustur(Tablo.Query3.FieldByName('SERVERADRESI_UZAK').AsString,Tablo.Query3.FieldByName('KULLANICIADI').AsString,Tablo.Query3.FieldByName('SIFRE').AsString,Tablo.Query3.FieldByName('VERITABANI').AsString))) then begin
      //cbDBList.Text := Tablo.Query3.FieldByName('SUBEADI').AsString;
      BEditDBList.Text := Tablo.Query3.FieldByName('SUBEADI').AsString;
      matched := True;
    end;
    Tablo.Query3.Next;
  end;
end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
begin
   Sifresizler := 0;
   KullanAdi := ComboAd.Text;
   Sifre := UGenSifre.sifre(PassWord.Text);
   if (Sifre<>'')and(RehberIni.ReadString('GenelOpsiyon', Sifre, '') <>'') then begin
      KullanAdi := RehberIni.ReadString('GenelOpsiyon', Sifre, '');
      {if Tablo.KullaniciBilgisi(KullanAdi, 'Geçici') then Sifresizler := 4
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then Sifresizler := 1
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz') then Sifresizler := 2
      else if Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)') then Sifresizler := 3 }
   end;
   Kapat := True;
   if (TabKullanici.Locate('FIRMA', ComboAd.text, []))and(Sifre = TabKullanici.FieldByName('SIFRE').AsString) then begin
          if BilgisayarKodu <> '' then
             Kullanan:= BilgisayarKodu
          else begin
             Kullanan := TabKullanici.FieldByName('REHBERID').AsString;
             KullananID := TabKullanici.FieldByName('ID').AsInteger;
             RolID := TabKullanici.FieldByName('ROLID').AsString;
          end;
          //Super := TabKullan.FieldByName('SUPER').AsString='1';
          {if Tablo.KullaniciBilgisi(KullanAdi, Modul) then begin
             if not (Tablo.TabKulHar.FieldByName('GORME').AsString='1') then
                Kapat := False;
          end;  }
          //yetkiler açýlýr.(serkan)
          Tablo.TabYetki.Close;
          Tablo.TabYetki.Parameters[0].Value := KullananID;
          Tablo.TabYetki.Open;
           ModalResult := mrOK;
         // if (Modul='KULLANAN') and (not super) then
         //    Kapat := False;
   end
   else
       Kapat := False;

   if not Kapat then begin
      Inc(YanlisSay);
      Password.Text:='';
      MessageDlg('Geçersiz Kullanýcý Adý veya Þifre', mtInformation, [mbOK], 0);
   end;

   KullanimTipi := cmbKullanýcýTipi.ItemIndex;
   if KullanimTipi =  0 then
    KullanimLabel := 'Üretici '
    else
    begin
      KullanimLabel := 'Depo '
    end;
end;

procedure TPasswordDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if not Kapat then begin
      CanClose := FALSE;
      PassWord.Text := ''
   end;
end;

procedure TPasswordDlg.CancelBtnClick(Sender: TObject);
begin
  Kapat := True;
  ModalResult := mrCancel;
//  Close;
end;

procedure TPasswordDlg.Image1Click(Sender: TObject);
var Sifre1, Sifre2:String;
begin
   if (ComboAd.Text = '')or(Password.Text = '')then begin
      showmessage('Önce Kullanýcý Adý ve Parolayý Giriniz..');
      exit;
   end;
   KullanAdi := ComboAd.Text;
   Sifre := PassWord.Text;
   if (TabKullanici.Locate('KULLANICI',KullanAdi ,[]))and(UgenSifre.Sifre(Sifre) = TabKullanici.FieldByName('SIFRE').AsString) then begin
      Sifre1:=''; Sifre1:='';
      if not MesajStrAl('', 'Yeni þifreyi giriniz : ','E',nil,Sifre1, 'Yeni þifreyi bir kez daha giriniz :','E',nil, Sifre2) then
         exit;
      if Sifre1 <> Sifre2 then
        showmessage('Þifre Giriþleri Uyumsuz!!! Deðiþtirilemedi...')
      else begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE KULLANICI SET SIFRE='''+UgenSifre.Sifre(Sifre1)+''' where KULLANICI = ''' + KullanAdi +'''';
        Tablo.Query1.ExecSQL;
        showmessage('Þifre baþarýyla deðiþtirildi...');
        //tablo refresh yeni þifre kullanýlamýyor..
        Tablo.TabKullan.Close;
        Tablo.TabKullan.Open;
      end;
    end else
      showmessage('Geçersiz Þifre...')
end;

procedure TPasswordDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then OKBtn.Click
  else if Key = #27 then CancelBtn.Click;
end;

procedure TPasswordDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl])and(Key = 68) then begin
    cbDBList.Visible := True;
    cbDBList.Text:='';
    //cbDBList.Text:=Tablo.Database_Name;
  end;
end;

procedure TPasswordDlg.Image2DblClick(Sender: TObject);
var s : string[100];
begin
  //  VTSifreKontrolu(Tablo.cnn, True);
  s := VTSifreKontrolu(GenRegIni,tablo.cnn, True);
  if s <> '' then
  ServerAdi := s;
end;

procedure TPasswordDlg.cbDBListPropertiesCloseUp(Sender: TObject);
var
  Yenicnnstring,Eskicnnstring,databasename:string;
  reg:TRegistry;
  kapat:Boolean;
begin
  if cbDBList.Text='' then
    exit;
  reg := TRegistry.Create;
  kapat:=False;
  //çalýþan bir connection string oluþturmaya çalýþalým..
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\GENTEGRE2',True) then begin
      Tablo.TablodanSorguAc(2,'select * from BAGLANTILAR where SUBEADI='''+cbDBList.Text+'''');
      if True then
      Eskicnnstring := reg.ReadString('ConnectionString');
      if ((Pos(Tablo.Query2.FieldByName('SERVERADRESI_UZAK').AsString,Eskicnnstring)>0)
        or (Pos(Tablo.Query2.FieldByName('SERVERADRESI_YAKIN').AsString,Eskicnnstring)>0))
        and (Pos(Tablo.Query2.FieldByName('KULLANICIADI').AsString,Eskicnnstring)>0)
        and (Pos(Tablo.Query2.FieldByName('SIFRE').AsString,Eskicnnstring)>0)
        and (Pos(Tablo.Query2.FieldByName('VERITABANI').AsString,Eskicnnstring)>0) then
        Exit;
      try
        Yenicnnstring:=Tablo.ConnectionStringOlustur(Tablo.Query2.FieldByName('SERVERADRESI_YAKIN').AsString,Tablo.Query2.FieldByName('KULLANICIADI').AsString,Tablo.Query2.FieldByName('SIFRE').AsString,Tablo.Query2.FieldByName('VERITABANI').AsString);
        Tablo.cnn2.Connected:=False;
        Tablo.cnn2.ConnectionString := Yenicnnstring;
        Tablo.cnn2.Connected:=True;
      except
        Yenicnnstring:=Tablo.ConnectionStringOlustur(Tablo.Query2.FieldByName('SERVERADRESI_UZAK').AsString,Tablo.Query2.FieldByName('KULLANICIADI').AsString,Tablo.Query2.FieldByName('SIFRE').AsString,Tablo.Query2.FieldByName('VERITABANI').AsString);
        Tablo.cnn2.Connected:=False;
        Tablo.cnn2.ConnectionString := Yenicnnstring;
        Tablo.cnn2.Connected:=True;
      end;
      reg.WriteString('ConnectionString',Yenicnnstring);
      kapat:=True;
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
  if kapat then begin
    try
      ShellExecute(0,'open', PChar(Application.ExeName), '/nosplash', nil, SW_SHOWNORMAL) ;
      CancelBtnClick(Self);
    except
      CancelBtnClick(Self);
    end;
  end;

  {
  reg := TRegistry.Create;
  kapat:=False;
  try
    Tablo.ConnectionStringOlustur();
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ENTEGRA',True) then begin
      cnnstring := reg.ReadString('ConnectionString');
      databasename := copy(cnnstring, pos('Initial Catalog=', cnnstring) + 16, pos(';Data Source=', cnnstring) - pos('Initial Catalog=', cnnstring) - 16);
      if databasename<>cbDBList.Text then begin
        cnnstring:=StringReplace(cnnstring,'Initial Catalog='+databasename,'Initial Catalog='+cbDBList.Text,[rfReplaceAll]);
        reg.WriteString('ConnectionString',cnnstring);
        kapat:=True;
      end;
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
  if kapat then begin
    try
      ShellExecute(0,'open', PChar(Application.ExeName), '/nosplash', nil, SW_SHOWNORMAL) ;
      CancelBtnClick(Self);
    except
      CancelBtnClick(Self);
    end;
  end; }
end;

procedure TPasswordDlg.cbDBListPropertiesInitPopup(Sender: TObject);
begin
  if cbDBList.Properties.Items.Count=0 then begin
    cbDBList.Properties.Items:=VeritabaniListesiGetir;
    Tablo.TablodanSorguAc(1,' select SUBEADI from BAGLANTILAR where TUR=1 and DURUM=1 ');
    while not Tablo.Query1.Eof do begin
      cbDBList.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
      Tablo.Query1.Next;
    end;
  end;
end;

procedure TPasswordDlg.cbLanguagesChange(Sender: TObject);
var
  FileName : string;
  Index : integer;
  bRestart : boolean;
begin
  {Index := TComboBox(Sender).ItemIndex;
  FileName := FDLLList[Index].FileName;
  Localizer. SwitchToFile(FileName);
  bRestart := False;
  OnLangSwitch(nil, FDLLList[Index], bRestart);}
end;

procedure TPasswordDlg.cbLanguagesPropertiesChange(Sender: TObject);
begin
ActiveLang:=cbLanguages.Text;
end;

procedure TPasswordDlg.cxButton2Click(Sender: TObject);
begin
   Sifresizler := 0;
   KullanAdi := ComboAd.Text;
   Sifre := UGenSifre.sifre(PassWord.Text);
   if (Sifre<>'')and(RehberIni.ReadString('GenelOpsiyon', Sifre, '') <>'') then begin
      KullanAdi := RehberIni.ReadString('GenelOpsiyon', Sifre, '');
      {if Tablo.KullaniciBilgisi(KullanAdi, 'Geçici') then Sifresizler := 4
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then Sifresizler := 1
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz') then Sifresizler := 2
      else if Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)') then Sifresizler := 3 }
   end;
   Kapat := True;
   if (TabKullanici.Locate('FIRMA', ComboAd.text, []))and(Sifre = TabKullanici.FieldByName('SIFRE').AsString) then begin
          if BilgisayarKodu <> '' then
             Kullanan:= BilgisayarKodu
          else begin
             Kullanan := TabKullanici.FieldByName('REHBERID').AsString;
             KullananID := TabKullanici.FieldByName('ID').AsInteger;
             RolID := TabKullanici.FieldByName('ROLID').AsString;
          end;
          //Super := TabKullan.FieldByName('SUPER').AsString='1';
          {if Tablo.KullaniciBilgisi(KullanAdi, Modul) then begin
             if not (Tablo.TabKulHar.FieldByName('GORME').AsString='1') then
                Kapat := False;
          end;  }
          //yetkiler açýlýr.(serkan)
          Tablo.TabYetki.Close;
          Tablo.TabYetki.Parameters[0].Value := KullananID;
          Tablo.TabYetki.Open;
           ModalResult := mrOK;
         // if (Modul='KULLANAN') and (not super) then
         //    Kapat := False;
        Tablo.TablodanSorguAc(5,'insert into LOG(TARIH,TABLOID,SATIRID,EKLEYEN)values(Getdate(),0,0,'+Kullanan+') select scope_identity()');
        LoginLogID := Tablo.Query5.Fields[0].AsInteger;
        Tablo.TablodanSorguAc(6,'insert into LOGHAR(LOGID,TABLOALANADI,ESKIALANDEGERI,YENIALANDEGERI,SUBEID)values('+Tablo.Query5.Fields[0].AsString+',''LOGIN(ITS)'','''+ComboAd.Text+''',''Baþarýlý'','+IntToStr(SubeId)+') select Scope_Identity()');
        LoginLogHarID := Tablo.Query6.Fields[0].AsInteger;
   end
   else
       Kapat := False;

   if not Kapat then begin
      Inc(YanlisSay);
      Password.Text:='';
      MessageDlg('Geçersiz Kullanýcý Adý veya Þifre', mtInformation, [mbOK], 0);
      Tablo.TablodanSorguAc(5,'insert into LOG(TARIH,TABLOID,SATIRID,EKLEYEN)values(Getdate(),0,0,0) select scope_identity()');
      LoginLogID := Tablo.Query5.Fields[0].AsInteger;
      Tablo.TablodanSorguAc(6,'insert into LOGHAR(LOGID,TABLOALANADI,ESKIALANDEGERI,YENIALANDEGERI,SUBEID)values('+IntToStr(LoginLogID)+',''LOGIN(ITS)'','''+ComboAd.Text+''',''Baþarýsýz('+IntToStr(YanlisSay)+')'','+IntToStr(SubeId)+') select Scope_Identity()');
   end;

   KullanimTipi := cmbKullanýcýTipi.ItemIndex;
   if KullanimTipi =  0 then
    KullanimLabel := 'Üretici '
    else
    begin
      KullanimLabel := 'Depo '
    end;
end;

procedure TPasswordDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  liste:TStringList;
  Yenicnnstring,Eskicnnstring,EskiSube,YeniSube,databasename:string;
  reg:TRegistry;
  kapat:Boolean;
begin
  EskiSube := BEditDBList.Text;
  liste := TStringList.Create;
  liste := Tablo.ListedenDuzenle(Tablo.cnn, 'Baðlantý Bilgileri',' SELECT TUR,BAGLANTIADI=SUBEADI,SERVERADRESI_YAKIN,SERVERADRESI_UZAK,KULLANICIADI,SIFRE,VERITABANI FROM BAGLANTILAR ','Baglantilar',True,True,True);
  if liste.Count>0 then
    BEditDBList.Text := liste.Strings[0];
  YeniSube := BEditDBList.Text;
  if EskiSube <> YeniSube then begin
    reg := TRegistry.Create;
    kapat:=False;
    //çalýþan bir connection string oluþturmaya çalýþalým..
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey('Software\ITS',True) then begin
        if ( UpperCase(Tablo.cnn.ConnectionString) <> UpperCase(Tablo.ConnectionStringOlustur(liste.Strings[1],liste.Strings[3],liste.Strings[4],liste.Strings[5])))
         and ( UpperCase(Tablo.cnn.ConnectionString) <> UpperCase(Tablo.ConnectionStringOlustur(liste.Strings[2],liste.Strings[3],liste.Strings[4],liste.Strings[5]))) then begin
          try
            Tablo.cnn2.Connected:=False;
            Yenicnnstring:=Tablo.ConnectionStringOlustur(liste.Strings[2],liste.Strings[4],liste.Strings[5],liste.Strings[6]);
            Tablo.cnn2.ConnectionString := Yenicnnstring;
            Tablo.cnn2.Connected:=True;
          except
            Tablo.cnn2.Connected:=False;
            Yenicnnstring:=Tablo.ConnectionStringOlustur(liste.Strings[3],liste.Strings[4],liste.Strings[5],liste.Strings[6]);
            Tablo.cnn2.ConnectionString := Yenicnnstring;
            Tablo.cnn2.Connected:=True;
          end;
        end;
        if Tablo.cnn2.Connected=True then begin
          reg.WriteString('ConnectionString',Yenicnnstring);
          kapat:=True;
        end else
          BEditDBList.Text := EskiSube;
      end;
    finally
      reg.CloseKey;
      reg.Free;
    end;
  end;
  if kapat then begin
    try
      ShellExecute(0,'open', PChar(Application.ExeName), '/nosplash', nil, SW_SHOWNORMAL) ;
      CancelBtnClick(Self);
    except
      CancelBtnClick(Self);
    end;
  end;
end;


end.

