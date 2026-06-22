unit UKullaniciGiris;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinFoggy, cxGraphics, cxLookAndFeelPainters,
  cxGroupBox, cxRadioGroup, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, cxControls, cxContainer, cxEdit, cxLabel, ExtCtrls, Menus,
  StdCtrls, cxButtons, Buttons, dxSkinLondonLiquidSky,UGenSifre,
  JvExControls, JvButton, JvNavigationPane, ImgList, PngImageList,UTouchKeyboardWindow,
  cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  DB, cxDBData, cxCheckBox, cxImage, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, FireDAC.Comp.Client,
  cxGridCardView, UTablo,UAnaForm,cxGridDBCardView, cxLookAndFeels, cxNavigator,
  cxGridCustomLayoutView, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxDateRanges, dxScrollbarAnnotations;

type
  TKullaniciGirisDlg = class(TForm)
    TabKullanici: TFDQuery;
    DtsKullanici: TDataSource;
    PanelKey: TPanel;
    BtnNum1: TJvNavPanelButton;
    BtnNum8: TJvNavPanelButton;
    BtnNum7: TJvNavPanelButton;
    BtnNum6: TJvNavPanelButton;
    BtnNum4: TJvNavPanelButton;
    BtnNum5: TJvNavPanelButton;
    BtnNum2: TJvNavPanelButton;
    BtnNum3: TJvNavPanelButton;
    BtnNum9: TJvNavPanelButton;
    BtnNum0: TJvNavPanelButton;
    BtnNumBspc: TJvNavPanelButton;
    btnLogin: TJvNavPanelButton;
    cxLabel2: TcxLabel;
    edPassword: TcxTextEdit;
    JvNavPanelButton1: TJvNavPanelButton;
    cxGridKul: TcxGrid;
    cxGridKulDBCardView1: TcxGridDBCardView;
    cxGridKulDBCardView1IMAJ: TcxGridDBCardViewRow;
    cxGridKulDBCardView1FIRMA: TcxGridDBCardViewRow;
    cxGridLevel1: TcxGridLevel;
    procedure rgDbTypePropertiesEditValueChanged(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabKullaniciAfterScroll(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure BtnNum0Click(Sender: TObject);
    procedure BtnNumBspcClick(Sender: TObject);
    procedure cxGridKulDBCardView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    Klavye1:TKeyboardWindow;
    { Private declarations }
  public
    { Public declarations }
    Cagiran:integer;
  end;
  function Sifre(s :string) :string;
var
  KullaniciGirisDlg: TKullaniciGirisDlg;
  secilenkullanici,secilenkullaniciadi, secilenkullaniciKod:string;
implementation
 Uses ADOConEd,PrjConst,LocOnFly;
{$R *.dfm}
function Sifre(s :string) :string;
var
  i :Integer;
  X :Byte;
  r :string;
begin

  X := 0;
  for i := 1 to Length(s) do
  begin
    // Tüm karakterler için XOR değeri belirleniyor.
    X := X xor Ord(s[i]);
  end;
  for i := 1 to Length(s) do
  begin
    // Her bir karakterin sayısal karşılığına X ve dizi indisi ekleniyor ve
    // X ile XOR yapılıyor
    r := r + IntToHex((Ord(s[i]) + (X + i)) xor X, 4)
  end;
  // Şifreli Metinin sonuna X 170 ile XOR yapılarak Ekleniyor.
  Result := r + IntToHex(X xor 170, 2);
end;

procedure TKullaniciGirisDlg.btnKapatClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

procedure TKullaniciGirisDlg.btnLoginClick(Sender: TObject);
begin
    Tablo.Query4.Close;
    Tablo.Query4.SQL.Text:= 'select * FROM KULLANICI WHERE REHBERID='''+TabKullanici.FieldByName('REHBERID').AsString+''' ';
    Tablo.Query4.Open;
    if Sifre(edPassword.Text)<> Tablo.Query4.FieldByName('SIFRE').AsString then begin
          Application.MessageBox(PChar(KUGecersiz_sifre),PChar(Uyari),MB_OK+ MB_ICONWARNING);
          Abort;
        end
    else begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text:= 'select K.REHBERID,K.KOD,R.FIRMA '+
                     ' from REHBER R inner join KULLANICI K on K.REHBERID=R.ID where K.REHBERID ='+TabKullanici.FieldByName('REHBERID').AsString+' order by 1';
        Tablo.Query1.Open;
        secilenkullanici:= Tablo.Query1.FieldByName('REHBERID').AsString;  //icUserName.EditValue;
        secilenkullaniciKod:= Tablo.Query1.FieldByName('KOD').AsString;  //icUserName.EditValue;
        secilenkullaniciadi:= Tablo.Query1.FieldByName('FIRMA').AsString; //icUserName.Text;
        ModalResult:= mrOk;
    end;
end;

procedure TKullaniciGirisDlg.BtnNum0Click(Sender: TObject);
begin
   edPassword.Text := edPassword.Text+(Sender as TJvNavPanelButton).Caption;
   edPassword.SelStart:= Length(edPassword.Text);
   edPassword.PostEditValue;
end;

procedure TKullaniciGirisDlg.BtnNumBspcClick(Sender: TObject);
begin
   if edPassword.SelLength>0 then
      edPassword.ClearSelection
    else begin
      edPassword.Text := Copy(edPassword.Text,1,Length(edPassword.Text)-1);
      edPassword.SelStart:= Length(edPassword.Text);
      edPassword.PostEditValue;
   end
end;

procedure TKullaniciGirisDlg.cxGridKulDBCardView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   if Cagiran=2 then
      ModalResult:= mrOk;
end;

procedure TKullaniciGirisDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (PanelKey.Visible)and(Klavye1<>nil) then
      FreeAndNil(Klavye1);
end;

procedure TKullaniciGirisDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabKullanici.Close;
  TabKullanici.Open;

{
 try          yetkisiz kul           sistem hatası java null pointer exception
  Tablo.FDCnn.Connected:=False;
  Tablo.FDCnn.ConnectionString:= GenRegIni.RegReadString('','ConnectionString','','C');
  if Tablo.FDCnn.ConnectionString<>'' then
   Tablo.FDCnn.Connected:=True
  else
   btnCnnSet.Click;
 except
   btnCnnSet.Click;
 end;
 }


  Tablo.GridTurkcelestir;
end;

procedure TKullaniciGirisDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    btnLogin.click
  else if Key=27 then
     if Klavye1<>Nil then
        FreeAndNil(Klavye1);
end;

procedure TKullaniciGirisDlg.FormShow(Sender: TObject);
begin
  TabKullanici.AfterScroll := TabKullaniciAfterScroll;
  if Cagiran = 2 then
     PanelKey.Visible := False;
end;

procedure TKullaniciGirisDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height;
  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;
end;

procedure TKullaniciGirisDlg.rgDbTypePropertiesEditValueChanged(
  Sender: TObject);
begin
{ try
  Tablo.GetUserList(rgDbType.ItemIndex);

  edPassword.Enabled:= rgDbType.ItemIndex>-1;
  icUserName.Enabled:= edPassword.Enabled;

  case rgDbType.ItemIndex of
   0 : begin
        icUserName.RepositoryItem:= Tablo.repGenotipKullanici;
        edPassword.Text:='';
       end;
   1 : begin
        icUserName.RepositoryItem:= Tablo.repEntegraKullanici;
        edPassword.Text:='';
       end;
  end;
 except
   Application.MessageBox('Kullanıcı Listesi Yüklenemedi','U Y A R I', MB_OK+ MB_ICONWARNING);
 end;
 }
end;

procedure TKullaniciGirisDlg.TabKullaniciAfterScroll(DataSet: TDataSet);
begin
  edPassword.Text := '';
  cxGridKulDBCardView1.DataController.SelectRows(cxGridKulDBCardView1.DataController.GetFocusedRowIndex,cxGridKulDBCardView1.DataController.GetFocusedRowIndex);
  //SetFocusedControl(edPassword);
  if PanelKey.Visible then
     edPassword.SetFocus;
end;

end.


