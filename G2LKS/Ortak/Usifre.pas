unit USifre;

interface

uses  Utablo,StdCtrls, Buttons, Controls, Classes, Forms, Dialogs, ADODb,
  Grids, DBGrids, Graphics, ExtCtrls, sysutils, Windows, ImgList, ComCtrls,
  ToolWin,  jpeg, Menus, DB, cxGraphics, dxSkinsCore,
  cxControls,Registry, ShellAPI,PrjConst,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, cxLookAndFeelPainters, cxButtons, dxSkinLondonLiquidSky,
  cxButtonEdit, cxLookAndFeels, System.ImageList;

type
  TPasswordDlg = class(TForm)
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label3: TLabel;
    Image2: TImage;
    ComboAd: TcxImageComboBox;
    TabKullanici: TADOQuery;
    Password: TcxTextEdit;
    Label2: TLabel;
    BEditDBList: TcxButtonEdit;
    OKBtn: TcxButton;
    CancelBtn: TcxButton;
    Label4: TLabel;
    cbLanguages: TcxImageComboBox;
    LblSube: TLabel;
    ComboSube: TcxImageComboBox;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Image2DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbDBListPropertiesInitPopup(Sender: TObject);
    procedure cbDBListPropertiesCloseUp(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CancelBtnClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure cbLanguagesPropertiesEditValueChanged(Sender: TObject);
    procedure ComboAdPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    //FDLLList : TDllInfoList;
     //procedure OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
     //procedure PopulateComboBox(CB : TcxComboBox);
    procedure YetkiliSubeleriDoldur;
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

uses  UCombo, UPaylasim, ULisans, UMesaj, FetaUtil, UGenSifre;//, USifDeg;
const
  RegBasKey = 'Software\GENTEGRE2';
var
   kapat : Boolean;
   YanlisSay : SmallInt;
   s, BilgisayarKodu : String[3];

{$R *.DFM}

function PasswordEkrani(Modul:String) : Boolean;
var sonuc : Boolean;
begin
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
      GenRegIni.RegWriteString('','KullanID', IntToStr(KullananID),'C');
      GenRegIni.RegWriteString('','SubeAdi', SubeAdi,'C');
      GenRegIni.RegWriteString('','SubeID', IntToStr(SubeId),'C');
   end;
   PasswordDlg.Destroy;
   result := sonuc;
//   MemWriteString('000');
end;

{procedure TPasswordDlg.OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
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
}
procedure TPasswordDlg.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  YanlisSay := 0;
  TabKullanici.Close;
  TabKullanici.SQL.Text := 'select K.ID,K.REHBERID,K.SIFRE,K.KOD,K.ROLID,K.DURUM,R.FIRMA '+
                           ' from REHBER R inner join KULLANICI K on K.REHBERID=R.ID where R.DURUM=1 and K.DURUM=1 order by 1';
  TabKullanici.Open;
  ComboAd.Properties.Items.Clear;
  TabKullanici.first;
  while not TabKullanici.eof do begin
    with ComboAd.Properties.Items.Add do begin
      Description := TabKullanici.FieldByName('FIRMA').AsString;
      Value := TabKullanici.FieldByName('ID').AsInteger;
    end;
    TabKullanici.Next;
  end;

  ComboAd.EditValue := GenRegIni.RegReadString('','KullanID', '0','C');
  BilgisayarKodu := GenRegIni.RegReadString('','BilgisayarKodu', '','C');
end;

procedure TPasswordDlg.FormDestroy(Sender: TObject);
begin
 //FDLLList.Free;
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
  {Localizer.InitReg('Software\Feta\genotip');
  FDLLList := TDllInfoList.Create;
  Localizer.OnLangSwitch := OnLangSwitch;}
  //PopulateComboBox(cbLanguages);
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
  cbLanguages.EditValue := GenRegIni.RegReadString('DilAyarlari','KullanimdakiDil','-1','C');
  cbLanguages.Properties.OnEditValueChanged := cbLanguagesPropertiesEditValueChanged;
end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
begin


//   Close;
end;

procedure TPasswordDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if not Kapat then begin
      CanClose := FALSE;
      PassWord.Text := ''
   end;
end;

procedure TPasswordDlg.Image1Click(Sender: TObject);
var Sifre1, Sifre2:String;
begin
   if (ComboAd.Text = '')or(Password.Text = '')then begin
      showmessage('Önce Kullanýcý Adý ve Parolayý Giriniz..');
      exit;
   end;
   KullanAdi := ComboAd.Text;
   SubeAdi   := ComboSube.Text;
   Sifre := PassWord.Text;
   if (TabKullanici.Locate('ID',ComboAd.EditValue ,[]))and(UgenSifre.Sifre(Sifre) = TabKullanici.FieldByName('SIFRE').AsString) then begin
      Sifre1:=''; Sifre1:='';
      if not MesajStrAl('', 'Yeni þifreyi giriniz : ','E',nil,Sifre1, 'Yeni þifreyi bir kez daha giriniz :','E',nil, Sifre2) then
         exit;
      if Sifre1 <> Sifre2 then
        showmessage('Þifre Giriþleri Uyumsuz!!! Deðiþtirilemedi...')
      else begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE KULLANICI SET SIFRE='''+UgenSifre.Sifre(Sifre1)+''' where ID = ''' + TabKullanici.FieldByName('ID').AsString +'''';
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
   // cbDBList.Visible := True;
   // cbDBList.Text:='';
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
{  if cbDBList.Text='' then
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
}
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
{
  if cbDBList.Properties.Items.Count=0 then begin
    //cbDBList.Properties.Items:=VeritabaniListesiGetir;
    Tablo.TablodanSorguAc(1,' select SUBEADI from BAGLANTILAR where TUR=1 and DURUM=1 ');
    while not Tablo.Query1.Eof do begin
      cbDBList.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
      Tablo.Query1.Next;
    end;
  end;
  }
end;

procedure TPasswordDlg.cbLanguagesPropertiesEditValueChanged(Sender: TObject);
var
  FileName : string;
  Index : integer;
  bRestart : boolean;
begin
  GenRegIni.RegWriteString('DilAyarlari','KullanimdakiDil',cbLanguages.EditValue,'C');
  RestartProgram := True;
  Application.Terminate;
  {ActiveLang:=cbLanguages.Text;
  Index := TComboBox(Sender).ItemIndex;
  FileName := FDLLList[Index].FileName;
  Localizer. SwitchToFile(FileName);
  bRestart := False;
  OnLangSwitch(nil, FDLLList[Index], bRestart);}

end;

procedure TPasswordDlg.YetkiliSubeleriDoldur;
Var
  Rol,SonGirilenSube:Integer;
begin
  if TabKullanici.Locate('FIRMA', ComboAd.text, []) then begin
    Tablo.TablodanSorguAc(1,'select R.ID,R.FIRMA from REHBER R where R.ID<0 ');
    if Tablo.Query1.RecordCount = 1 then begin
      LblSube.Visible:=False;
      ComboSube.Visible:=False;
      SubeVarmi:=False;
    end else begin
      LblSube.Visible:=True;
      ComboSube.Visible:=True;
      SubeVarmi:=True;
    end;
    Rol := TabKullanici.FieldByName('ROLID').AsInteger;
    SonGirilenSube := StrToInt(GenRegIni.RegReadString('','SubeID', '-1','C'));
    Tablo.TablodanSorguAc(1,'select R.ID,R.FIRMA from REHBER R inner join YETKI Y on convert(int,(''1198''+convert(varchar(10),-R.ID)))=Y.MODULID where R.ID<0 and Y.ROLID='+IntToStr(Rol)+' and Y.HAK=1');
    Tablo.Query1.first;
    ComboSube.Properties.Items.Clear;
    ComboSube.EditValue := 0;
    while not Tablo.Query1.eof do begin
      with ComboSube.Properties.Items.Add do begin
        Description := Tablo.Query1.FieldByName('FIRMA').AsString;
        Value := Tablo.Query1.FieldByName('ID').AsInteger;
      end;
      if SonGirilenSube = Tablo.Query1.FieldByName('ID').AsInteger then
         ComboSube.EditValue := SonGirilenSube;
      Tablo.Query1.Next;
    end;
    if Tablo.Query1.RecordCount = 1 then
      ComboSube.EditValue := Tablo.Query1.FieldByName('ID').Value;
    ComboSube.PostEditValue;
  end;
end;

procedure TPasswordDlg.ComboAdPropertiesChange(Sender: TObject);
begin
  YetkiliSubeleriDoldur;
end;

procedure TPasswordDlg.CancelBtnClick(Sender: TObject);
begin
  Kapat := True;
  ModalResult := mrCancel;
end;

procedure TPasswordDlg.cxButton1Click(Sender: TObject);
begin
   Sifresizler := 0;
   KullanAdi := ComboAd.Text;
   SubeAdi   := ComboSube.Text;
   SubeId    := ComboSube.EditValue;
   Sifre := UGenSifre.sifre(PassWord.Text);
   if (Sifre <>'') and ( Tablo.GENINI.ReadString(Ops_GenelOpsiyon_Sifre,'')<>'') then begin    //  GenelOpsiyon', Sifre, '')
      KullanAdi := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_Sifre,'');
      {if Tablo.KullaniciBilgisi(KullanAdi, 'Geçici') then Sifresizler := 4
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then Sifresizler := 1
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz') then Sifresizler := 2
      else if Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)') then Sifresizler := 3 }
   end;
// //  if SubeVarmi then begin
//
//      Tablo.RepSubelerOrtak.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' ').Items;
//      Tablo.RepSubelerKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
//      Tablo.RepSubelerOrtakKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
//      Tablo.RepSubelerOrtakTumSubeler.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID < 0').Items;
////   end;
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
      Tablo.TabYetki.Parameters[0].Value := RolID;
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
      Password.SetFocus;
   end;
end;

procedure TPasswordDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  liste:TStringList;
  Eskicnnstring,EskiSube,YeniSube,databasename,Uzakcnn,Yakincnn:string;
  reg:TRegistry;
  kapat:Boolean;
begin
  EskiSube := BEditDBList.Text;
  liste := TStringList.Create;
//  liste := Tablo.ListedenDuzenle(Tablo.cnn, 'Baðlantý Bilgileri',' SELECT TUR,BAGLANTIADI=SUBEADI,SERVERADRESI_YAKIN,SERVERADRESI_UZAK,KULLANICIADI,SIFRE,VERITABANI FROM BAGLANTILAR where DURUM=1 and TUR like ''%0%'' ','Baglantilar',True,True,True);
  if liste.Count>0 then
    BEditDBList.Text := liste.Strings[1];
  YeniSube := BEditDBList.Text;
  if EskiSube <> YeniSube then begin
    reg := TRegistry.Create;
    kapat:=False;
    //çalýþan bir connection string oluþturmaya çalýþalým..
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey('Software\GENTEGRE2',True) then begin
        Uzakcnn := Tablo.ConnectionStringOlustur(liste.Strings[3],liste.Strings[4],liste.Strings[5],liste.Strings[6]);
        Yakincnn := Tablo.ConnectionStringOlustur(liste.Strings[2],liste.Strings[4],liste.Strings[5],liste.Strings[6]);

//        if (UpperCase(Tablo.cnn.ConnectionString) <> UpperCase(Uzakcnn))
//         and (UpperCase(Tablo.cnn.ConnectionString) <> UpperCase(Yakincnn)) then begin
//          if Trim(liste.Strings[2])<>'' then begin
//            try
//              Tablo.cnn2.Connected:=False;
//              Tablo.cnn2.ConnectionString := Yakincnn;
//              Tablo.cnn2.Connected:=True;
//            except
//              Tablo.cnn2.Connected:=False;
//              Tablo.cnn2.ConnectionString := Uzakcnn;
//              Tablo.cnn2.Connected:=True;
//            end;
//          end else if Trim(liste.Strings[3])<>'' then begin
//            Tablo.cnn2.Connected:=False;
//            Tablo.cnn2.ConnectionString := Uzakcnn;
//            Tablo.cnn2.Connected:=True;
//          end else
//            raise Exception.Create('Sunucu Bilgisi Bulunamadý!');
//        end;
//        if Tablo.cnn2.Connected=True then begin
//          reg.WriteString('ConnectionString',Yakincnn);
//          reg.WriteString('ConnectionString2',Uzakcnn);
//          kapat:=True;
//        end else
//          BEditDBList.Text := EskiSube;
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

procedure TPasswordDlg.Label4Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://www.genyazilim.com', '', nil, SW_SHOWNORMAL);
end;


end.

