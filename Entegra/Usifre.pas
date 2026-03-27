unit USifre;

interface

uses  Utablo,StdCtrls, Buttons, Controls, Classes, Forms, Dialogs, FireDAC.Comp.Client,
  Grids, DBGrids, Graphics, ExtCtrls, sysutils, Windows, ImgList, ComCtrls,
  ToolWin,  jpeg, Menus,  DB, cxGraphics, dxSkinsCore,
  cxControls, Registry, ShellAPI,  cxButtonEdit, DateUtils,LocOnFly,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, Keyboard,UTouchKeyboardWindow,
  cxImageComboBox, cxLookAndFeelPainters, cxButtons, dxSkinLondonLiquidSky, dxSkinLiquidSky,
  cxLookAndFeels, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxGDIPlusClasses,
  cxLabel, System.ImageList, dxCoreGraphics, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;
type
  TPasswordDlg = class(TForm)
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label3: TLabel;
    ComboAd: TcxImageComboBox;
    TabKullanici: TFDQuery;
    Password: TcxTextEdit;
    Label2: TLabel;
    BEditDBList: TcxButtonEdit;
    OKBtn: TcxButton;
    CancelBtn: TcxButton;
    cbLanguages: TcxImageComboBox;
    LblSube: TLabel;
    ComboSube: TcxImageComboBox;
    Image3: TImage;
    LabelAd: TLabel;
    LabelSifreDegis: TcxLabel;
    LabelSifreUnuttum: TcxLabel;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CancelBtnClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure cbLanguagesPropertiesEditValueChanged(Sender: TObject);
    procedure ComboAdPropertiesChange(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure LblSubeDblClick(Sender: TObject);
    procedure LabelSifreDegisClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure LabelSifreUnuttumClick(Sender: TObject);
  private
    { Private declarations }

    Klavye1 : TKeyboardWindow;
    //FDLLList : TDllInfoList;
     //procedure OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
    // procedure PopulateComboBox(CB : TcxComboBox);
    procedure YetkiliSubeleriDoldur;
    procedure SifreDegis;
//    function SifreKontrolu(inputStr,inputStr2: string):Boolean;
  public
    { Public declarations }
    Modul, Sifre : String;
    YanlisSay : integer;
  end;
resourcestring
  SLangChanged = 'Program dili değişti ("%s").'#13#10' Geçerli olabilmesi için yeniden başlatmalısınız';
var
  PasswordDlg : TPasswordDlg;

  function PasswordEkrani(Modul:String) : Boolean;
implementation

uses  UCombo, UPaylasim, ULisans, UMesaj, FetaUtil, UGenSifre,UWebServis, FetaKurulusSiniflari,PrjConst;
//, USifDeg;
const
  RegBasKey = 'Software\GENTEGRE2';
var
   kapat : Boolean;
   Kul_Dili : SmallInt;
   s, BilgisayarKodu : String[3];

{$R *.DFM}

function PasswordEkrani(Modul:String) : Boolean;
var
  ASifre:string;
  AKullanici,i,ParamSay:integer;
  DevamEdilecek:boolean;
begin
  Result := False;
  DevamEdilecek := False;
  ParamSay := 0;
  Application.CreateForm(TPasswordDlg, PasswordDlg);
  PasswordDlg.Modul := Modul;
  if ParamCount>=2 then begin
    for i := 1 to ParamCount do begin
      if copy(ParamStr(i),1,11)='/Kullanici:' then begin
        AKullanici := StrToIntDef(copy(ParamStr(i),12,Length(ParamStr(i))-11),0);
        ParamSay := ParamSay + 1;
      end else if copy(ParamStr(i),1,7)='/Sifre:' then begin
        ASifre := UGenSifre.DeSifre(copy(ParamStr(i),8,Length(ParamStr(i))-7));
        ParamSay := ParamSay + 1;
      end;
    end;
  end;
  if ParamSay=2 then begin
    PasswordDlg.FormShow(Nil);
    PasswordDlg.ComboAd.EditValue := AKullanici;
    PasswordDlg.ComboAd.PostEditValue;
    PasswordDlg.Password.EditValue := ASifre;
    PasswordDlg.Password.PostEditValue;
    PasswordDlg.cxButton1Click(Nil);
    if PasswordDlg.YanlisSay=0 then
      DevamEdilecek := True;
  end;
  if not DevamEdilecek then begin
    PasswordDlg.ShowModal;
    if PasswordDlg.ModalResult = mrOk then
      DevamEdilecek := True;
  end;
  if DevamEdilecek then begin
    GenRegIni.RegWriteString('','KullanAdi', KullanAdi,'C');
    GenRegIni.RegWriteString('','KullanKodu', Kullanan,'C');
    GenRegIni.RegWriteString('','KullanID', IntToStr(KullananID),'C');
    GenRegIni.RegWriteString('','SubeAdi', SubeAdi,'C');
    GenRegIni.RegWriteString('','SubeID', IntToStr(SubeId),'C');
    Result := True;
  end;
  PasswordDlg.Free;
//   MemWriteString('000');
end;

procedure TPasswordDlg.FormCreate(Sender: TObject);
begin
//  if CokluDilVar then begin
     LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  YanlisSay := 0;
  TabKullanici.Close;
  TabKullanici.SQL.Text := 'select K.ID,K.REHBERID,K.SIFRE,K.KOD,K.ROLID,K.DURUM, K.SORU,K.CEVAP, R.FIRMA,RO.TY '+
                           ' from REHBER R inner join KULLANICI K on K.REHBERID=R.ID left join ROLLER RO on K.ROLID=RO.ID where R.DURUM>0 and K.DURUM>0 and R.GRUP=335 order by R.FIRMA';
  TabloYenile(TabKullanici,[]);
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
  if Sektor in [Sektor_Cafe, Sektor_Rest] then
     LabelAd.Caption := 'GenoRes Restaurant Yönetimi';
end;

procedure TPasswordDlg.FormShow(Sender: TObject);
var
  i:Integer;
  cnnstr:string;
  matched:Boolean;
  reg:TRegistry;
  Trh:TDateTime;
begin
  try
    reg := TRegistry.Create;
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\GENTEGRE2\Login',True) then begin
      try
        Trh := reg.ReadDateTime('SonBasarisizGirTar');
      except
        Trh := IncMinute(now,-6);
        reg.WriteDateTime('SonBasarisizGirTar',Trh);
      end;

      if MinutesBetween(Trh,Now)<5.0 then begin
        ShowMessage(FormatDateTime('dd/mm/yyyy hh:nn:ss',IncMinute(Trh,5))+Girisyapamazsiniz);
        Tablo.ProgramiSonlandir;
      end;
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;

  Password.Properties.EchoMode := eemPassword;
  if Sender<>nil then
    Password.SetFocus;
   //Dil
  cbLanguages.Visible := (CokluDilVar)and(length(Diller) > 1);

  matched := False;
  Tablo.TablodanSorguAc(3,'select * from BAGLANTILAR where DURUM=1 and TUR like ''%0%''');
  cnnstr := Tablo.FDCnn.ConnectionString;
  while (not Tablo.Query3.Eof) and (not matched)do begin
    if ( UpperCase(cnnstr) = UpperCase(Tablo.ConnectionStringOlustur(Tablo.Query3.FieldByName('SERVERADRESI_YAKIN').AsString,Tablo.Query3.FieldByName('KULLANICIADI').AsString,Tablo.Query3.FieldByName('SIFRE').AsString,Tablo.Query3.FieldByName('VERITABANI').AsString)))
     or( UpperCase(cnnstr) = UpperCase(Tablo.ConnectionStringOlustur(Tablo.Query3.FieldByName('SERVERADRESI_UZAK').AsString,Tablo.Query3.FieldByName('KULLANICIADI').AsString,Tablo.Query3.FieldByName('SIFRE').AsString,Tablo.Query3.FieldByName('VERITABANI').AsString))) then begin
      //cbDBList.Text := Tablo.Query3.FieldByName('SUBEADI').AsString;
      BEditDBList.Text := Tablo.Query3.FieldByName('SUBEADI').AsString;
      matched := True;
    end;
    Tablo.Query3.Next;
  end;
  //cbLanguages.EditValue := GenRegIni.RegReadString('DilAyarlari','KullanimdakiDil','1','C');
  //cbLanguages.Properties.OnEditValueChanged := cbLanguagesPropertiesEditValueChanged;
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
   end
   else if Klavye1 <> nil then begin
      Klavye1.HideKeyboard;
      FreeAndNil(Klavye1);
   end;

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

procedure TPasswordDlg.Image1Click(Sender: TObject);
var s : string[100];
begin
  s := VTSifreKontrolu(GenRegIni,Tablo.FDCnn, True);
  if s <> '' then begin
    ServerAdi := s;
    ModalResult := mrCancel;
    Kapat := True;
  end;
end;

procedure TPasswordDlg.Image3Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height-100;
  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
  end;
end;

procedure TPasswordDlg.cbLanguagesPropertiesEditValueChanged(Sender: TObject);
var
  FileName : string;
  Index : integer;
  bRestart : boolean;
begin
  if not cbLanguages.Visible then exit;


  Dil := cbLanguages.EditValue;
  GenRegIni.RegWriteString('DilAyarlari','KullanimdakiDil',IntToStr(Dil),'C');


  case Dil of
    -2: begin LocalizerOnFly.SwitchTo(1033);  end;
    else LocalizerOnFly.SwitchTo(1055);
  end;

//  RestartProgram := True;
//  Application.Terminate;
  ActiveLang:=cbLanguages.Text;
//  Index := TComboBox(Sender).ItemIndex;
  //FileName := FDLLList[Index].FileName;
  //Localizer. SwitchToFile(FileName);
//  bRestart := False;
  //OnLangSwitch(nil, FDLLList[Index], bRestart);

  {  case ComboBox1.ItemIndex of
    1: LocalizerOnFly.SwitchTo(1033);
    else LocalizerOnFly.SwitchTo(1055);
  end;}
end;

procedure TPasswordDlg.YetkiliSubeleriDoldur;
Var
  Rol,SonGirilenSube:Integer;
begin
  if TabKullanici.Locate('FIRMA', ComboAd.text, []) then begin
    Tablo.TablodanSorguAc(1,'select count(ID) from REHBER R where R.ID<0 ');
    SubeVarmi:=Tablo.Query1.Fields[0].AsInteger>1;
    LblSube.Visible := SubeVarmi;
    ComboSube.Visible:=SubeVarmi;
    Rol := TabKullanici.FieldByName('ROLID').AsInteger;
    TamYetkili := TabKullanici.FieldByName('TY').AsBoolean;
    SonGirilenSube := StrToInt(GenRegIni.RegReadString('','SubeID', '-1','C'));
    if TamYetkili then
       Tablo.TablodanSorguAc(1,'select R.ID,R.FIRMA from REHBER R WHERE R.ID<0')
    else
       Tablo.TablodanSorguAc(1,'select R.ID,R.FIRMA from REHBER R inner join YETKI Y on convert(int,(''1198''+convert(varchar(10),-R.ID)))=Y.MODULID where R.ID<0 and Y.ROLID='+IntToStr(Rol)+' and Y.HAK=1');
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
   //Varsa DilDoldur
   if CokluDilVar then begin
      Tablo.TablodanSorguAc(1,'select isnull(DIL,-1) from KULLANICI where ID='+IntToStr(ComboAd.EditValue));
      Kul_Dili := Tablo.Query1.Fields[0].AsInteger;
      cbLanguages.EditValue := Kul_Dili;
   end;
end;

procedure TPasswordDlg.CancelBtnClick(Sender: TObject);
begin
  ProgKapat:=True;
  Kapat := True;
  ModalResult := mrCancel;
end;

procedure TPasswordDlg.cxButton1Click(Sender: TObject);
var
  reg:TRegistry;
  KulSay, sure:integer;
  SKT, Suan : TDateTime;
begin
  Tablo.RepositoryDoldur;
  Tablo.RepositoryDuzenle;
  if (SubeVarmi)and(ComboSube.Text='') then
     raise Exception.Create(Sube);
  if SubeVarmi then begin
     SubeAdi   := ComboSube.Text;
     SubeId    := ComboSube.EditValue;
  end Else
     SubeId:=-1;
  Tabloyenile(Tablo.TabBizim, []);
  if (CokluDilVar)and(Kul_Dili<>cbLanguages.EditValue) then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KULLANICI set DIL = &DILL where ID=&ID ',['&DILL','&ID'],[Dil, ComboAd.EditValue]);
  Sifresizler := 0;
  KullanAdi := ComboAd.Text;
  Sifre := UGenSifre.Desifre('0052005400569A');
  Sifre := UGenSifre.sifre(PassWord.Text);
  if (Sifre <>'') and ( Tablo.GENINI.ReadString(Ops_GenelOpsiyon_Sifre,'')<>'') then begin
      KullanAdi := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_Sifre,'');
  end;
  Tablo.RepSubelerOrtak.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' ').Items;
  Tablo.RepSubelerKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
  Tablo.RepSubelerOrtakKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
  Tablo.RepSubelerOrtakTumSubeler.Properties.Items := Tablo.imgComboboxInit('Select 1,''''  union all Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID < 0').Items;
  Tablo.RepStokDepolarAktif.Properties.Items := Tablo.imgComboboxInit('select ID=0,DEPOADI='''' union all select ID,DEPOADI from DEPOLAR where DURUM=1 ').Items;//and SUBEID='+IntToStr(SubeId)
  Tablo.RepStokDepolarTumu.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR').Items;//and SUBEID='+IntToStr(SubeId)
  Tablo.RepStokUretimDepolar.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1 and VARSAYILAN=9').Items;
    if Tablo.RepStokUretimDepolar.Properties.Items.Count=0 then
       Tablo.RepStokUretimDepolar.Properties.Items.assign(Tablo.RepStokDepolarAktif.Properties.Items);

  Kapat := True;
  if (TabKullanici.Locate('FIRMA', ComboAd.text, []))and(Sifre = TabKullanici.FieldByName('SIFRE').AsString) then begin

    SifreliSifre := Sifre;
    KullaniciID := TabKullanici.FieldByName('ID').AsInteger;
//  if Kapat then begin
    if BilgisayarKodu <> '' then
      Kullanan:= BilgisayarKodu
    else begin
      Kullanan := TabKullanici.FieldByName('REHBERID').AsString;
      KullananID := TabKullanici.FieldByName('ID').AsInteger;
      //08/06/2020
      RolID := TabKullanici.FieldByName('ROLID').AsString;
      TamYetkili := TabKullanici.FieldByName('TY').AsBoolean;
      {if TabKullanici.FieldByName('OZELAYAR').AsBoolean then
         Kullanan_Ayar := StrToIntDef(Kullanan,0)
      else
         Kullanan_Ayar := 0; }
    end;
    if KullaniciID <> 2 then begin
        //şifre doğru giriş yaptı.. şimdi şifre süresi dolmuş mu bakalım
        Tablo.TablodanSorguAc(1,'select DATEDIFF(DAY, GETDATE(), isnull(SIFREDEGISME,getdate()-2)) AS GunSayisi from KULLANICI where REHBERID='+Kullanan);
        if Tablo.Query1.Fields[0].AsInteger < 1 then begin
           if TabKullanici.FieldByName('SORU').AsString = '' then begin//güvenlik sorusu yoksa o ekranı açalım
              if Tablo.KullaniciSihirbazBaslat(TabKullanici.Fields[0].AsInteger, TabKullanici.FieldByName('REHBERID').AsInteger, TabKullanici.FieldByName('ROLID').AsInteger)=False then begin
                 RestartProgram := False;
                 Tablo.ProgramiSonlandir;
                 exit;
              end;
           end else
              LabelSifreDegisClick(Self);
        end;
    end;
    //yetkiler a��l�r.(serkan)  Tablo.TabYetki.Close;
  if Tablo.TabYetki.Params.FindParam('PRolID') = nil then
    with Tablo.TabYetki.Params.Add do begin
      Name := 'PRolID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  Tablo.TabYetki.ParamByName('PRolID').Value := RolID;
  Tablo.TabYetki.Open;
  Tablo.TabYetkiEk.Close;
  if Tablo.TabYetkiEk.Params.FindParam('PRolID') = nil then
    with Tablo.TabYetkiEk.Params.Add do begin
      Name := 'PRolID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  Tablo.TabYetkiEk.ParamByName('PRolID').Value := RolID;
  Tablo.TabYetkiEk.Open;

// Yetki olarak tek kendi mi Şube mi yoksa herkes mi
    ModulYetki_TekSubeTum.Cari := StrToIntDef(tablo.YetkiEkVarMi(2201),100);
    ModulYetki_TekSubeTum.Proje := StrToIntDef(tablo.YetkiEkVarMi(2111),1);
    ModulYetki_TekSubeTum.Aktivite := StrToIntDef(tablo.YetkiEkVarMi(2121),1);
    ModulYetki_TekSubeTum.Gorev := StrToIntDef(tablo.YetkiEkVarMi(2131),1);
    ModulYetki_TekSubeTum.Demirbas := StrToIntDef(tablo.YetkiEkVarMi(2801),1);
    ModulYetki_TekSubeTum.Teklif := StrToIntDef(tablo.YetkiEkVarMi(2901),1);
    ModulYetki_TekSubeTum.Servis := StrToIntDef(tablo.YetkiEkVarMi(3001),1);
    ModulYetki_TekSubeTum.IK := StrToIntDef(tablo.YetkiEkVarMi(3401),100);


    Tablo.TablodanSorguAc(5,'insert into LOG(TUR,TARIH,TABLOID,SATIRID,EKLEYEN,PCADI)values(1,Getdate(),-1,0,'+Kullanan+','''+Tablo.ClientName+''') select scope_identity()');
    LoginLogID := Tablo.Query5.Fields[0].AsInteger;
    Tablo.TablodanSorguAc(6,'insert into LOGHAR(LOGID,TABLOALANADI,ESKIALANDEGERI,YENIALANDEGERI,SUBEID)values('+IntToStr(LoginLogID)+',''LOGIN(GENTEGRE)'','''+ComboAd.Text+''',''Başarılı'','+IntToStr(SubeId)+') select Scope_Identity()');
    LoginLogHarID := Tablo.Query6.Fields[0].AsInteger;
    VarsayilanDegerleriAl;
    Tablo.KocanAyarlariInit;

    Tablo.TablodanSorguAc(1,' select isnull(R.GOREVID,0), isnull(R.DEPARTMAN,0) FROM KULLANICI K inner join ROLLER R on K.ROLID=R.ID where K.REHBERID='+Kullanan);
    if (Tablo.Query1.Fields[0].AsInteger=0)or(Tablo.Query1.Fields[1].AsInteger=0) then
        Showmessage('Girişi yapılan kullanıcı için Departman veya Görev tanımlı değildir. Lütfen tanımlayın!');
    Tablo.RepIsKlasorListesi.Properties.items := Tablo.imgComboboxInit( 'select distinct * from( select  GL.ID, GL.ADI FROM GOREVLISTE GL   WHERE GL.ID = -27 union all '+
      'SELECT GL.ID, GL.ADI FROM GOREVLISTE GL left join GOREVKULLANICI GK on GL.ID=GK.LISTGOREVID AND GK.TUR<=5' + #13#10 +
      'WHERE GL.DURUM=1 AND (GL.HERKESEACIK=1 OR GL.EKLEYEN='+Kullanan+' OR' + #13#10 +
      '	1=case  when GK.TUR=1 and GK.REHBERID ='+Kullanan+' then 1' + #13#10 +
      '	when GK.TUR=2 and GK.REHBERID='+Tablo.Query1.Fields[0].AsString+' then 1' + #13#10 +
      '	when GK.TUR=3 and GK.REHBERID='+Tablo.Query1.Fields[1].AsString+' then 1' + #13#10 +
      '	when GK.TUR=4 and GK.REHBERID='+IntToStr(SubeId)+' then 1' + #13#10 +
      '	end)) as liste1').items;

    if not Tablo.TablodanSorguAc(7,'select distinct COMPUTERNAME,SESSIONNAME,LOGONSERVER,USERNAME,USERDOMAIN from master.dbo.GLogins where Dateadd(minute,2,SOOT) > Getdate() '+
                                   ' and COMPUTERNAME+SESSIONNAME+LOGONSERVER+USERNAME+USERDOMAIN <> '''+Tablo.GetEnvVarValue('COMPUTERNAME')+Tablo.GetEnvVarValue('SESSIONNAME')+Tablo.GetEnvVarValue('LOGONSERVER')+Tablo.GetEnvVarValue('USERNAME')+Tablo.GetEnvVarValue('USERDOMAIN')+''' ') then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'create table master.dbo.GLogins(ID int IDENTITY(1,1),SOOT datetime,COMPUTERNAME nvarchar(50),SESSIONNAME nvarchar(50),LOGONSERVER nvarchar(50),USERNAME nvarchar(50),USERDOMAIN nvarchar(50),CONSTRAINT [PK_GLgn] PRIMARY KEY CLUSTERED (ID DESC) ON [PRIMARY])',[],[]);
      Tablo.TablodanSorguAc(7,'select distinct COMPUTERNAME,SESSIONNAME,LOGONSERVER,USERNAME,USERDOMAIN from master.dbo.GLogins where Dateadd(minute,2,SOOT) > Getdate() ');
    end;
    KulSay := StrToIntDef(UGenSifre.Desifre(Tablo.GENINI.ReadString(Ops_LsnsKulSay,'AA')),30);
    if Tablo.Query7.RecordCount>=KulSay then begin
      ShowMessage(IntToStr(KulSay)+Kullanicisayiasimi);
      CancelBtnClick(Self);
      Exit;
    end;
      Tablo.TablodanSorguAc(8,'insert into master.dbo.GLogins(SOOT,COMPUTERNAME,SESSIONNAME,LOGONSERVER,USERNAME,USERDOMAIN)values(GetDate(),'''+
                                    Tablo.GetEnvVarValue('COMPUTERNAME')+''','''+
                                    Tablo.GetEnvVarValue('SESSIONNAME')+''','''+
                                    Tablo.GetEnvVarValue('LOGONSERVER')+''','''+
                                    Tablo.GetEnvVarValue('USERNAME')+''','''+
                                    Tablo.GetEnvVarValue('USERDOMAIN')+''') select Scope_Identity()');

    UserSessionID := Tablo.Query8.Fields[0].AsInteger;
    Tablo.TimerUserSession.Enabled := True;

    //AO 25.06.2025 UTablodan buraya al�nd�.. duyuru i�eri�i
    Suan := Tablo.GENINI.BugunTrh;
    SKT:=Suan;
    SKT:=Tablo.GENINI.ReadDateTime(Ops_SonDuyuruCtrlTarihi, Suan);
    if SKT <= Suan then begin //lisans kontrol tarihi gelmi�.. Kurum kodunu soral�m..
       while SKT <= Suan do begin
         Tablo.DuyuruMotoru(SKT);
         SKT := incDay(SKT);
       end;
       Tablo.GENINI.WriteDateTime(Ops_SonDuyuruCtrlTarihi, SKT);
    end;
    //
    ModalResult := mrOK;
  end else
    Kapat := False;
  if not Kapat then begin
    Inc(YanlisSay);
    Password.Text:='';
    Tablo.TablodanSorguAc(5,'insert into LOG(TUR,TARIH,TABLOID,SATIRID,EKLEYEN,PCADI) values(1,Getdate(),-1,0,0,'''+Tablo.ClientName+''') select scope_identity()');
    LoginLogID := Tablo.Query5.Fields[0].AsInteger;
    Tablo.TablodanSorguAc(9,'insert into LOGHAR(LOGID,TABLOALANADI,ESKIALANDEGERI,YENIALANDEGERI,SUBEID)values('+IntToStr(LoginLogID)+',''LOGIN(GENTEGRE)'','''+KullanAdi+''',''Başarısız('+IntToStr(YanlisSay)+')'','+IntToStr(SubeId)+') select Scope_Identity()');
    if YanlisSay<5 then
      MessageDlg('Geçersiz Kullanıcı Adı veya Şifre ('+IntToStr(YanlisSay)+'. başarısız giriş denemesi)', mtInformation, [mbOK], 0)
    else
    begin
      MessageDlg(IntToStr(YanlisSay)+'. başarısız giriş denemesi. Oturumunuz '+FormatDateTime('dd/mm/yyyy hh:nn:ss',IncMinute(Now,5))+' tarihine kadar kitlenmiştir!', mtInformation, [mbOK], 0);
      try
        reg := TRegistry.Create;
        reg.RootKey := HKEY_CURRENT_USER;
        if reg.OpenKey('Software\GENTEGRE2\Login',True) then begin
          reg.WriteDateTime('SonBasarisizGirTar',Now);
        end;
      finally
        reg.CloseKey;
        reg.Free;
      end;
      Tablo.ProgramiSonlandir;
    end;
    if Sender <> nil then
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
  liste := TStringList.Create;                                                                                                                                                                      //and TUR like ''%0%''
  liste := Tablo.ListedenDuzenle(Tablo.FDCnn, 'Ba�lant� Bilgileri',' SELECT TUR,BAGLANTIADI=SUBEADI,SERVERADRESI_YAKIN,SERVERADRESI_UZAK,KULLANICIADI,SIFRE,VERITABANI FROM BAGLANTILAR where DURUM=1  ','Baglantilar',True,True,True);
  if liste.Count>0 then
    BEditDBList.Text := liste.Strings[1];
  YeniSube := BEditDBList.Text;
  if EskiSube <> YeniSube then begin
    reg := TRegistry.Create;
    kapat:=False;
    //çalışan bir connection string oluşturmaya çalışalım..
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey('Software\GENTEGRE2',True) then begin
        Uzakcnn := Tablo.ConnectionStringOlustur(liste.Strings[3],liste.Strings[4],liste.Strings[5],liste.Strings[6]);
        Yakincnn := Tablo.ConnectionStringOlustur(liste.Strings[2],liste.Strings[4],liste.Strings[5],liste.Strings[6]);

        if (UpperCase(Tablo.FDCnn.ConnectionString) <> UpperCase(Uzakcnn))
         and (UpperCase(Tablo.FDCnn.ConnectionString) <> UpperCase(Yakincnn)) then begin
          if Trim(liste.Strings[2])<>'' then begin
            try
              Tablo.FDCnn2.Connected:=False;
              Tablo.FDCnn2.ConnectionString := Yakincnn;
              Tablo.FDCnn2.Connected:=True;
            except
              Tablo.FDCnn2.Connected:=False;
              Tablo.FDCnn2.ConnectionString := Uzakcnn;
              Tablo.FDCnn2.Connected:=True;
            end;
          end else if Trim(liste.Strings[3])<>'' then begin
            Tablo.FDCnn2.Connected:=False;
            Tablo.FDCnn2.ConnectionString := Uzakcnn;
            Tablo.FDCnn2.Connected:=True;
          end else
            raise Exception.Create(Sunucubulunamadi);
        end;
        if Tablo.FDCnn2.Connected=True then begin
          reg.WriteString('ConnectionString',Yakincnn);
          reg.WriteString('ConnectionString2',Uzakcnn);
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
      ShellExecute(0,'open', PChar(Application.ExeName),PWideChar(RestartParameters), nil, SW_SHOWNORMAL) ;
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

procedure TPasswordDlg.SifreDegis;
var s, Sifre1, Sifre2:String;
    sure : integer;
 begin
      Sifre1:=''; Sifre1:='';
      repeat
          s:='';
          if not MesajStrAl('En az 8 karakter, rakam, küçük büyük harf ve karakter bulunmalıdır!', 'Yeni şifreyi giriniz : ','E',nil,Sifre1,
                            'Yeni şifreyi bir kez daha giriniz :','E',nil, Sifre2) then
             s:='-';
          if s='' then begin
            if TabKullanici.FieldByName('ID').AsInteger = 2 then
               s:=''
            else
               s := SifreKontrolu(TabKullanici.FieldByName('SIFRE').AsString, Sifre1, Sifre2);
            if s='' then begin
                sure := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_SifreSuresi, 6)*30;

                Tablo.Query1.Close;
                Tablo.Query1.SQL.Text := 'UPDATE KULLANICI SET SIFRE='''+UgenSifre.Sifre(Sifre1)+''','+
                     ' SIFREDEGISME = getdate() +'+ IntToStr(sure) +' where ID = ''' + TabKullanici.FieldByName('ID').AsString +'''';
                Tablo.Query1.ExecSQL;
                showmessage(Degistirildi);
                //tablo refresh yeni şifre kullanılamıyor..
                Tablo.TabKullan.Close;
                Tablo.TabKullan.Open;
                TabKullanici.Close;
                TabKullanici.Open;
            end
            else
                showmessage(s);
          end;
      until (s='')or(s='-');
 end;

procedure TPasswordDlg.LabelSifreDegisClick(Sender: TObject);
begin
   if (ComboAd.Text = '') then begin // or(Password.Text = '')t
      showmessage(Kullaniciadiparola);
      exit;
   end;

   KullanAdi := ComboAd.Text;
   SubeAdi   := ComboSube.Text;
   Sifre := PassWord.Text;
   if (TabKullanici.Locate('ID',ComboAd.EditValue ,[]))and(UgenSifre.Sifre(Sifre) = TabKullanici.FieldByName('SIFRE').AsString) then
       SifreDegis
    else
      showmessage(Gecersizsifre)
end;

procedure TPasswordDlg.LabelSifreUnuttumClick(Sender: TObject);
var soru, cevap:string;
begin
   if (ComboAd.Text = '') then begin // or(Password.Text = '')t
      showmessage(Kullaniciadiparola);
      exit;
   end;

   KullanAdi := ComboAd.Text;
   SubeAdi   := ComboSube.Text;
   //Sifre := PassWord.Text;
   if TabKullanici.Locate('ID',ComboAd.EditValue ,[]) then begin
      soru := Tablo.GENINI.AnahtarGetir(-24000, TabKullanici.FieldByName('SORU').AsInteger, -1, '');
      if soru='' then
         Showmessage('Güvenlik sorusu bulunamadı.')
      else begin
         cevap:='';
         if MesajStrAl('', soru,'E',nil,cevap,'','E',nil,cevap) then begin
            if UgenSifre.Sifre(Cevap) <> TabKullanici.FieldByName('CEVAP').AsString then
               Showmessage('Cevap eşleşmedi!')
            else //şifre değiş ekranı çağır
               SifreDegis
         end;
       end
   end;
end;

procedure TPasswordDlg.LblSubeDblClick(Sender: TObject);
begin
  SQLServis;
end;

end.








