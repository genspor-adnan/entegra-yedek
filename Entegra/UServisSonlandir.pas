unit UServisSonlandir;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxSchedulerStorage, UTablo, Vcl.Graphics,
  cxSchedulerCustomControls, cxSchedulerDateNavigator, dxSkinsCore,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, cxContainer, cxEdit, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, cxTextEdit, cxMaskEdit, cxSpinEdit, cxTimeEdit,
  cxLabel, cxDateNavigator, cxMemo, cxDropDownEdit, cxButtonEdit,
  cxImageComboBox, cxGroupBox, cxCheckBox, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxCoreGraphics,
  dxGDIPlusClasses, cxImage;

type
  TServisSonlandirDlg = class(TForm)
    ServisHarPanelAlt: TPanel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    GrpBaslama: TcxGroupBox;
    DateBaslama: TcxDateNavigator;
    cxLabel2: TcxLabel;
    TimeBaslama: TcxTimeEdit;
    GrpBitis: TcxGroupBox;
    DateBitis: TcxDateNavigator;
    cxLabel6: TcxLabel;
    TimeBitis: TcxTimeEdit;
    GroupDetay: TcxGroupBox;
    cxLabel1: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel5: TcxLabel;
    comboDurum: TcxImageComboBox;
    EditPersonel: TcxButtonEdit;
    Memociklama: TcxMemo;
    CheckBaslama: TcxCheckBox;
    CheckBitis: TcxCheckBox;
    CheckAciklama: TcxCheckBox;
    comboDisUyariTurux: TcxImageComboBox;
    comboUyariTurux: TcxImageComboBox;
    cxLabel7: TcxLabel;
    cxLabel4: TcxLabel;
    WhatsappImage: TcxImage;
    CheckWhatsapp: TcxCheckBox;
    procedure IptalTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure EditPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CheckBaslamaPropertiesEditValueChanged(Sender: TObject);
    procedure CheckBitisPropertiesEditValueChanged(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EnAyarla;
    procedure comboDurumPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckAciklamaPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ServisID, UyariTuru,DisUyariTuru:integer;
    YeniHareket:Boolean;
  end;

var
  ServisSonlandirDlg: TServisSonlandirDlg;

implementation

{$R *.dfm}

procedure TServisSonlandirDlg.CheckAciklamaPropertiesEditValueChanged(
  Sender: TObject);
begin
{  (Sender as TcxCheckBox).PostEditValue;
  GroupDetay.Visible := CheckAciklama.Checked;
  EnAyarla; }
end;

procedure TServisSonlandirDlg.CheckBaslamaPropertiesEditValueChanged(Sender: TObject);
begin
  (Sender as TcxCheckBox).PostEditValue;
   GrpBaslama.Visible := CheckBaslama.Checked;
  //CheckBitis.Enabled := CheckBaslama.Checked;
  //EnAyarla;
end;

procedure TServisSonlandirDlg.CheckBitisPropertiesEditValueChanged(Sender: TObject);
begin
  (Sender as TcxCheckBox).PostEditValue;
   GrpBitis.Visible := CheckBitis.Checked;
  //CheckBaslama.Enabled := not CheckBitis.Checked;
  //EnAyarla;
end;

procedure TServisSonlandirDlg.comboDurumPropertiesEditValueChanged(Sender: TObject);
begin
(*
  if (ServisID>0)and(comboDurum.EditValue<>null) then begin
   //insert mode ise en son hareket aranıyor   **kaynak durum**
     Tablo.TablodanSorguAc(9,'select top 1 ID,DURUM from SERVISHAREKET where SERVISID='+IntToStr(ServisID)+' order by ID desc');
     if Tablo.Query9.RecordCount > 0 then begin
        Tablo.TablodanSorguAc(0,' select ID,UYARITURU, DISUYARITURU, TARIHIDESOR from DURUMBAGLANTI where BOLUM=-3007 and KAYNAKDURUM='+Tablo.Query9.FieldByName('DURUM').AsString+
                                ' and HEDEFDURUM='+VarToStr(comboDurum.EditValue));
      if Tablo.Query0.RecordCount > 0 then begin
         UyariTuru := Tablo.Query0.FieldByName('UYARITURU').Value;
         DisUyariTuru := Tablo.Query0.FieldByName('DISUYARITURU').Value;
         //comboUyariTuru.EditValue := Tablo.Query0.FieldByName('UYARITURU').Value;
         //comboUyariTuru.PostEditValue;
         //comboDisUyariTuru.EditValue := Tablo.Query0.FieldByName('DISUYARITURU').Value;
         //comboDisUyariTuru.PostEditValue;
         if YeniHareket then begin
           if (Tablo.Query0.FieldByName('TARIHIDESOR').Value <> null) and (Tablo.Query0.FieldByName('TARIHIDESOR').AsBoolean) then begin
             CheckBitis.Checked := True;
             CheckBaslama.Checked := True;
             GrpBitis.Left := 0;
             GrpBaslama.Left := 0;
           end else begin
             CheckBaslama.Checked := False;
             CheckBitis.Checked := False;
           end;
         end else if not YeniHareket then begin
           if (Tablo.Query0.FieldByName('TARIHIDESOR').Value <> null) and (Tablo.Query0.FieldByName('TARIHIDESOR').AsBoolean) then
             CheckBitis.Checked := True;
         end;
      end;
    end;
  end;      *)
end;

procedure TServisSonlandirDlg.EditPersonelPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  RehID:integer;
begin
  RehID := Tablo.RehberAra_IDGetir(335,False,30);
  if RehID>0 then begin
    EditPersonel.Tag := RehID;
    EditPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',RehID);
  end;
end;

procedure TServisSonlandirDlg.EnAyarla;
var en : integer;
begin
(*  en := 16;
  if GrpBaslama.Visible then
    en := en + 300;
  {if GrpBitis.Visible then
    en := en + 150;}
  if GroupDetay.Visible then
    en := en + 300;
  Width := en;
  Position := poMainFormCenter;  *)
end;

procedure TServisSonlandirDlg.FormCreate(Sender: TObject);
begin
  ServisID := 0;
  try
    Tablo.AlanOlustur(TServisSonlandirDlg(Self), -1,nil);  //
  except
    showmessage('Ek alanlar oluşturuluken bir hata ile karşılaşıldı.');
  end;
end;

procedure TServisSonlandirDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
   ctrlPos : TPoint;
   clientPos : TPoint;
   Strin : String;
   ctrl  : TWinControl;
begin
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bileşen Ekle
    clientPos := Self.ScreenToClient(Mouse.CursorPos);
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TServisSonlandirDlg(Self),nil);
      Tablo.AlanOlustur(TServisSonlandirDlg(Self), -1,nil);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bileşen Düzenle
    clientPos := Self.ScreenToClient(Mouse.CursorPos);
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(ctrl.Name),TServisSonlandirDlg(Self),nil);
      Tablo.AlanOlustur(TServisSonlandirDlg(Self), -1,nil);
    end;
  end;
end;

procedure TServisSonlandirDlg.FormShow(Sender: TObject);
begin

  CheckBaslamaPropertiesEditValueChanged(CheckBaslama);
  //CheckBitisPropertiesEditValueChanged(CheckBitis);
  if comboDurum.ItemIndex = -1 then
    comboDurum.ItemIndex := 0;
  comboDurumPropertiesEditValueChanged(comboDurum);
  EnAyarla;
end;

procedure TServisSonlandirDlg.IptalTusClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TServisSonlandirDlg.KaydetTusClick(Sender: TObject);
begin
  if GrpBitis.Visible and ((DateBaslama.Date>DateBitis.Date)or((DateBaslama.Date=DateBitis.Date)and(TimeBaslama.Time>TimeBitis.Time))) then begin
    Application.MessageBox(PChar('Dikkat! Başlama bitişten sonra gerçekleşemez!'), PChar(''), MB_OK);
    Abort;
  end else
    ModalResult := mrOk
end;

end.
