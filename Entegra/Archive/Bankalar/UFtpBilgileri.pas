unit UFtpBilgileri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,Utablo,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, ComCtrls, ToolWin, cxControls,
  cxContainer, cxEdit, cxGroupBox, cxRadioGroup, cxDBEdit, cxLabel, StdCtrls,
  Mask, DBCtrls, DB, UFDCompatHelpers, Menus, cxButtons, ExtCtrls, cxGraphics, cxTextEdit,
  cxMaskEdit, cxDropDownEdit,UHavaleEFT, cxCheckGroup, cxDBCheckGroup,UBinarySave,
  cxDBLabel, cxCheckBox, dxSkinscxPCPainter, cxPC, dxSkinLondonLiquidSky,
  cxLookAndFeels, cxPCdxBarPopupMenu, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TBankaFTPBilgileriDLG = class(TForm)
    DtsFTP: TDataSource;
    TabFTP: TFDQuery;
    OpenDialog1: TOpenDialog;
    ToolBar1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    btnIptal: TToolButton;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    RadioGuvenlikTuru: TcxDBRadioGroup;
    cxGroupBox1: TcxGroupBox;
    CheckBankaDeseniOlustur: TcxDBCheckBox;
    CheckBankaDeseniImzala: TcxDBCheckBox;
    cxLabel1: TcxLabel;
    cxGroupBox2: TcxGroupBox;
    LabelAdres: TcxLabel;
    LabelFTP: TcxLabel;
    EditAdres: TcxDBTextEdit;
    EditDizin: TcxDBTextEdit;
    LabelDizin: TcxLabel;
    LabelIkinokta: TcxLabel;
    LabelPort: TcxLabel;
    DBEdit1: TcxDBTextEdit;
    GroupSSH: TcxGroupBox;
    LabelSSH2: TcxLabel;
    EditAnahtarAdi: TcxDBTextEdit;
    EditAnahtarSifresi: TcxDBTextEdit;
    LabelSSH3: TcxLabel;
    cxGroupBox4: TcxGroupBox;
    LabelUser: TcxLabel;
    EditUser: TcxDBTextEdit;
    LabelPassword: TcxLabel;
    EditPassword: TcxDBTextEdit;
    BtnPrivateKey: TcxButton;
    LabelOzelAnahtar: TcxLabel;
    RadioKimlikDogrulamasi: TcxDBRadioGroup;
    GroupSSL: TcxGroupBox;
    CheckGroupSSHAnahtar: TcxDBCheckGroup;
    cxLabel2: TcxLabel;
    cxGroupBox6: TcxGroupBox;
    CheckTalimatOlustur: TcxDBCheckBox;
    CheckTalimatImzala: TcxDBCheckBox;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    RadioTextGonder: TcxDBRadioGroup;
    RadioTalimatGonder: TcxDBRadioGroup;
    CheckTextEmail: TcxDBCheckBox;
    CheckTalimatEmail: TcxDBCheckBox;
    GroupBoxEImza: TcxGroupBox;
    cxDBRadioGroup1: TcxDBRadioGroup;
    cxLabel5: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    GroupBoxEPosta: TcxGroupBox;
    EditKime: TcxDBTextEdit;
    EditBilgi: TcxDBTextEdit;
    EditGizli: TcxDBTextEdit;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    EditDizin2: TcxDBTextEdit;
    cxLabel9: TcxLabel;
    SheetExtre: TcxTabSheet;
    EditExKullaniciAdi: TcxDBTextEdit;
    EditExSifre: TcxDBTextEdit;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    CheckExtSor: TcxDBCheckBox;
    cxLabel12: TcxLabel;
    EditExServisID: TcxDBTextEdit;
    EditExAnahtar: TcxDBTextEdit;
    cxLabel13: TcxLabel;
    EditExFirmaAdi: TcxDBTextEdit;
    cxLabel14: TcxLabel;
    procedure BtnPrivateKeyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGuvenlikTuruClick(Sender: TObject);
    procedure TabFTPBeforePost(DataSet: TDataSet);
    procedure RadioKimlikDogrulamasiClick(Sender: TObject);
    procedure DtsFTPStateChange(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure TabFTPNewRecord(DataSet: TDataSet);
    procedure CheckBankaDeseniOlusturClick(Sender: TObject);
    procedure CheckTalimatOlusturClick(Sender: TObject);
    procedure CheckBankaDeseniImzalaClick(Sender: TObject);
    procedure CheckTalimatEmailPropertiesEditValueChanged(Sender: TObject);
    procedure CheckExtSorPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    BANKAKODU:Integer;
  end;

var
  BankaFTPBilgileriDLG: TBankaFTPBilgileriDLG;

implementation
  Uses LocOnFly;

{$R *.dfm}

procedure TBankaFTPBilgileriDLG.btnIptalClick(Sender: TObject);
begin
  Close;
end;

procedure TBankaFTPBilgileriDLG.BtnPrivateKeyClick(Sender: TObject);
Var
  str : string;
begin
   if OpenDialog1.Execute then begin
      Tablo.Query1.Close;
      //dosyaadi := ExtractFileName(OpenDialog1.FileName);
      str:= OpenDialog1.FileName ;
      Tablo.Query1.SQL.Text:=
      'UPDATE BANKAFTP SET FTP_PRIVATE_KEY = :PBELGE WHERE ID='+TabFTP.FieldByName('ID').asstring+'' ;
      KutugeYaz(Tablo.Query1, str);
   end;
end;
procedure TBankaFTPBilgileriDLG.CheckBankaDeseniImzalaClick(Sender: TObject);
begin
  if CheckBankaDeseniImzala.Checked = False then begin
     if CheckTalimatImzala.Checked = False then
        GroupBoxEImza.Visible := False   Else
        GroupBoxEImza.Visible := True;
  end else
     GroupBoxEImza.Visible := True;
end;

procedure TBankaFTPBilgileriDLG.CheckBankaDeseniOlusturClick(Sender: TObject);
begin
  if CheckBankaDeseniOlustur.Checked = False then begin
     TabFTP.Close;
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'UPDATE BANKAFTP SET TEXT_OLUSTUR = 0, TEXT_IMZALA = 0,TEXT_GONDER = 0, TEXT_EMAIL = 0 WHERE BANKAKODU = '+inttostr(BANKAKODU);
     Tablo.Query1.ExecSQL;
     TabFTP.Parameters[0].Value := BANKAKODU;
     TabFTP.Open;
  end;
  CheckBankaDeseniImzala.Visible := CheckBankaDeseniOlustur.Checked ;
  RadioTextGonder.Visible := CheckBankaDeseniOlustur.Checked ;
  CheckTextEmail.Visible := CheckBankaDeseniOlustur.Checked ;

  if CheckTextEmail.Checked = True then
     GroupBoxEPosta.Visible := CheckBankaDeseniOlustur.Checked
  else GroupBoxEPosta.Visible := False ;

  if CheckBankaDeseniImzala.Checked = True then
     GroupBoxEImza.Visible := CheckBankaDeseniOlustur.Checked
  else GroupBoxEImza.Visible := False ;

  if CheckTalimatEmail.Checked = True then
     GroupBoxEPosta.Visible := CheckTalimatOlustur.Checked
  else GroupBoxEPosta.Visible := False ;

  if CheckTalimatImzala.Checked = True then
     GroupBoxEImza.Visible := CheckTalimatOlustur.Checked
  else GroupBoxEImza.Visible := False ;
end;

procedure TBankaFTPBilgileriDLG.CheckExtSorPropertiesEditValueChanged(
  Sender: TObject);
begin
  EditExKullaniciAdi.Enabled := not CheckExtSor.Checked;
  EditExSifre.Enabled := not CheckExtSor.Checked;
end;

procedure TBankaFTPBilgileriDLG.CheckTalimatEmailPropertiesEditValueChanged(
  Sender: TObject);
begin
  if (CheckTalimatEmail.Checked) or (CheckTextEmail.Checked) then
     GroupBoxEPosta.Visible:=True
  else
     GroupBoxEPosta.Visible:=False;
end;

procedure TBankaFTPBilgileriDLG.CheckTalimatOlusturClick(Sender: TObject);
begin
  CheckTalimatImzala.Visible := CheckTalimatOlustur.Checked ;
  RadioTalimatGonder.Visible := CheckTalimatOlustur.Checked ;
  CheckTalimatEmail.Visible := CheckTalimatOlustur.Checked ;
  if CheckTalimatOlustur.Checked = False then begin
     TabFTP.Close;
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'UPDATE BANKAFTP SET TALIMAT_OLUSTUR = 0, TALIMAT_IMZALA = 0,TALIMAT_GONDER = 0, TALIMAT_EMAIL = 0 WHERE BANKAKODU = '+inttostr(BANKAKODU);
     Tablo.Query1.ExecSQL;
     TabFTP.Parameters[0].Value := BANKAKODU;
     TabFTP.Open;
  end;


  if CheckTalimatEmail.Checked = True then
     GroupBoxEPosta.Visible := CheckTalimatOlustur.Checked
  else GroupBoxEPosta.Visible := False ;

  if CheckTalimatImzala.Checked = True then
     GroupBoxEImza.Visible := CheckTalimatOlustur.Checked
  else GroupBoxEImza.Visible := False ;

  if CheckTextEmail.Checked = True then
     GroupBoxEPosta.Visible := CheckBankaDeseniOlustur.Checked
  else GroupBoxEPosta.Visible := False ;

  if CheckBankaDeseniImzala.Checked = True then
     GroupBoxEImza.Visible := CheckBankaDeseniOlustur.Checked
  else GroupBoxEImza.Visible := False ;
end;

procedure TBankaFTPBilgileriDLG.RadioKimlikDogrulamasiClick(Sender: TObject);
begin
  case RadioKimlikDogrulamasi.ItemIndex of
    0 :     //Parola ile
      begin
        BtnPrivateKey.Visible:=False;
        LabelOzelAnahtar.Visible:=False;
        EditPassword.Visible:=True;
        LabelPassword.Visible:=True;
      end;
    1 :     //Güvenlik Dosyasý Ýle
      begin
        BtnPrivateKey.Visible:=True;
        LabelOzelAnahtar.Visible:=True;
        EditPassword.Visible:=False;
        LabelPassword.Visible:=False;
      end;
  end;
end;

procedure TBankaFTPBilgileriDLG.DtsFTPStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsFTP.State in [dsInsert, dsEdit];
   IptalTus.visible := KaydetTus.visible;
end;

procedure TBankaFTPBilgileriDLG.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Tablo.GridTurkcelestir;
end;

procedure TBankaFTPBilgileriDLG.FormShow(Sender: TObject);
begin
  TabFTP.DisableControls;
  TabFTP.Close;
  TabFTP.Parameters[0].Value := BANKAKODU;
  TabFTP.Open;
  TabFTP.EnableControls;

  CheckTalimatOlusturClick(Self);
  CheckBankaDeseniOlusturClick(Self);
  RadioKimlikDogrulamasiClick(Self);
  RadioGuvenlikTuruClick(Self);
  CheckBankaDeseniImzalaClick(Self);
  GroupBoxEPosta.Visible := CheckTextEmail.Checked;
  GroupBoxEPosta.Visible := CheckTalimatEmail.Checked;

end;

procedure TBankaFTPBilgileriDLG.IptalTusClick(Sender: TObject);
begin
   TabFTP.Cancel;
end;

procedure TBankaFTPBilgileriDLG.KaydetTusClick(Sender: TObject);
begin
  TabFTP.Post;
end;

procedure TBankaFTPBilgileriDLG.RadioGuvenlikTuruClick(Sender: TObject);
begin
  case RadioGuvenlikTuru.ItemIndex of
    0 :
      begin
        GroupSSH.Visible:=False;
        GroupSSL.Visible:=False;
      end;
    1 :     //ftp over SA (ssl)
      begin
        GroupSSH.Visible:=False;
        GroupSSL.Visible:=True;
      end;
    2 :     //secure ftp (ssh)
      begin
        GroupSSH.Visible:=True;
        GroupSSL.Visible:=False;
      end;
  end;
end;

procedure TBankaFTPBilgileriDLG.TabFTPBeforePost(DataSet: TDataSet);
begin
  case RadioGuvenlikTuru.ItemIndex of
    0 :     //normal ftp
      begin
        CheckGroupSSHAnahtar.Clear;
        EditAnahtarAdi.Text := '';
        EditAnahtarSifresi.Text := '';
      end;
    1 :     //ftp over SA (ssl)
      begin
        CheckGroupSSHAnahtar.Clear;
        EditAnahtarAdi.Text := '';
        EditAnahtarSifresi.Text := '';
      end;
    2 :     //secure ftp (ssh)
      begin
         //ssh???
      end;
  end;
  case RadioKimlikDogrulamasi.ItemIndex of
    0 :     //Parola ile
      begin
        Tablo.Query1.SQL.Text:='UPDATE BANKAFTP SET FTP_PRIVATE_KEY='''' WHERE BANKALARID ='+inttostr(BANKAKODU)+''
      end;
    1 :     //Güvenlik Dosyasý Ýle
      begin
        EditPassword.Text:='';
      end;
  end;
end;

procedure TBankaFTPBilgileriDLG.TabFTPNewRecord(DataSet: TDataSet);
begin
   TabFTP.FieldByName('BANKAKODU').AsInteger := BANKAKODU;
   TabFTP.FieldByName('EKLEYEN').AsString := Kullanan;
   TabFTP.FieldByName('SUBEID').AsInteger := SubeID;
end;

End.


