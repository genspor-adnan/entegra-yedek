unit UOpsiyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCoffee, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxDropDownEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, StdCtrls, cxButtons, ComCtrls, ToolWin, ADODB, ExtCtrls, cxContainer, cxLabel, cxTextEdit, Buttons, cxMaskEdit, cxSpinEdit, cxCheckBox;

type
  TOpsiyonDlg = class(TForm)
    DtsITSHesaplari: TDataSource;
    TabITSHesaplari: TADOQuery;
    GroupBox10: TGroupBox;
    ToolBar6: TToolBar;
    BtnITSHesapEkle: TToolButton;
    BtnITSHesapSil: TToolButton;
    ToolButton8: TToolButton;
    BtnITSHesapKaydet: TToolButton;
    BtnITSHesapVazgec: TToolButton;
    VarsayilanKaydet: TcxButton;
    GridITSHesaplari: TcxGrid;
    TvITSHesaplari: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    TvITSHesaplariID: TcxGridDBColumn;
    TvITSHesaplariGONDEREN: TcxGridDBColumn;
    TvITSHesaplariKULLANICIADI: TcxGridDBColumn;
    TvITSHesaplariSIFRE: TcxGridDBColumn;
    TvITSHesaplariSERVIS: TcxGridDBColumn;
    Panel1: TPanel;
    cxLabel1: TcxLabel;
    EdtGS1FirmaNumarasi: TcxTextEdit;
    Panel2: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxLabel2: TcxLabel;
    GroupBox1: TGroupBox;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    EdtKapasitePalet: TcxSpinEdit;
    EdtKapasiteKoli: TcxSpinEdit;
    EdtKapasiteBag: TcxSpinEdit;
    EdtKapasiteKutu: TcxSpinEdit;
    EdtKapasiteKucukBag: TcxSpinEdit;
    GroupBox2: TGroupBox;
    cxLabel8: TcxLabel;
    EdPaketYenilemeZamani: TcxSpinEdit;
    dk: TcxLabel;
    cxLabel9: TcxLabel;
    EdPaketKontrolEdilecekGun: TcxSpinEdit;
    ChkListelerGuncellesin: TcxCheckBox;
    ChkPaketlerGuncellesin: TcxCheckBox;
    cxLabel10: TcxLabel;
    EdtOtoSatýsGln: TcxTextEdit;
    ChkITSYeniServis: TcxCheckBox;
    procedure BtnITSHesapEkleClick(Sender: TObject);
    procedure BtnITSHesapKaydetClick(Sender: TObject);
    procedure BtnITSHesapSilClick(Sender: TObject);
    procedure BtnITSHesapVazgecClick(Sender: TObject);
    procedure VarsayilanKaydetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DtsITSHesaplariStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonDlg: TOpsiyonDlg;

implementation
Uses UTablo,PrjConst;

{$R *.dfm}

procedure TOpsiyonDlg.BtnITSHesapEkleClick(Sender: TObject);
begin
 if not TabITSHesaplari.Active then
  begin
    TabITSHesaplari.Close;
    TabITSHesaplari.Open;
  end;
  TabITSHesaplari.Append;
end;

procedure TOpsiyonDlg.BtnITSHesapKaydetClick(Sender: TObject);
begin
TabITSHesaplari.Post;
end;

procedure TOpsiyonDlg.BtnITSHesapSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+MB_ICONQUESTION)= ID_NO then Abort;
  TabITSHesaplari.Delete;
end;

procedure TOpsiyonDlg.BtnITSHesapVazgecClick(Sender: TObject);
begin
TabITSHesaplari.Cancel;
end;

procedure TOpsiyonDlg.CancelBtnClick(Sender: TObject);
begin
Close;
end;

procedure TOpsiyonDlg.DtsITSHesaplariStateChange(Sender: TObject);
begin
   BtnITSHesapEkle.Visible := not (DtsITSHesaplari.State in [dsEdit, dsInsert]);
   BtnITSHesapSil.Visible := BtnITSHesapEkle.Visible;
   BtnITSHesapKaydet.Visible:= not (BtnITSHesapEkle.Visible);
   BtnITSHesapVazgec.Visible:= BtnITSHesapKaydet.Visible;
end;

procedure TOpsiyonDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
TabITSHesaplari.Close;
end;

procedure TOpsiyonDlg.FormCreate(Sender: TObject);
begin
  EdtGS1FirmaNumarasi.Text := RehberIni.ReadString('GenelOpsiyon', 'GS1FirmaNumarasý', '896');
  EdtOtoSatýsGln.Text := RehberIni.ReadString('GenelOpsiyon', 'OtoSatýsGln', '');
  EdtKapasitePalet.Text := RehberIni.ReadString('GenelOpsiyon', 'Kapasite Palet', '1000');
  EdtKapasiteKoli.Text := RehberIni.ReadString('GenelOpsiyon', 'Kapasite Koli', '72');
  EdtKapasiteBag.Text := RehberIni.ReadString('GenelOpsiyon', 'Kapasite Bað', '16');
  EdtKapasiteKutu.Text := RehberIni.ReadString('GenelOpsiyon', 'Kapasite Kutu', '8');
  EdtKapasiteKucukBag.Text := RehberIni.ReadString('GenelOpsiyon', 'Kapasite Küçük Bað', '0');
  EdPaketYenilemeZamani.Text := RehberIni.ReadString('GenelOpsiyon', 'Paket Yenileme Zamaný', '10');
  EdPaketKontrolEdilecekGun.Text := RehberIni.ReadString('GenelOpsiyon', 'Paket Kontrol Edilecek Gün', '10');
  ChkListelerGuncellesin.Checked := RehberIni.ReadBool('GenelOpsiyon', 'Listeler Güncellesin', False);
  ChkITSYeniServis.Checked := RehberIni.ReadBool('GenelOpsiyon', 'ITSYeniServis', False);

  ChkPaketlerGuncellesin.Checked := RehberIni.ReadBool('GenelOpsiyon', 'Paketler Güncellesin', False);
end;

procedure TOpsiyonDlg.FormShow(Sender: TObject);
begin
         TabITSHesaplari.Close;
         TabITSHesaplari.Open;
end;

procedure TOpsiyonDlg.KaydetTusClick(Sender: TObject);
begin
  RehberIni.WriteString('GenelOpsiyon','GS1FirmaNumarasý',EdtGS1FirmaNumarasi.Text);
  RehberIni.WriteString('GenelOpsiyon','OtoSatýsGln',EdtOtoSatýsGln.Text);
  RehberIni.WriteString('GenelOpsiyon','Kapasite Palet',EdtKapasitePalet.Text);
  RehberIni.WriteString('GenelOpsiyon','Kapasite Koli',EdtKapasiteKoli.Text);
  RehberIni.WriteString('GenelOpsiyon','Kapasite Bað',EdtKapasiteBag.Text);
  RehberIni.WriteString('GenelOpsiyon','Kapasite Kutu',EdtKapasiteKutu.Text);
  RehberIni.WriteString('GenelOpsiyon','Kapasite Küçük Bað',EdtKapasiteKucukBag.Text);
  RehberIni.WriteString('GenelOpsiyon','Paket Yenileme Zamaný',EdPaketYenilemeZamani.Text);
  RehberIni.WriteString('GenelOpsiyon','Paket Kontrol Edilecek Gün',EdPaketKontrolEdilecekGun.Text);
  RehberIni.WriteBool('GenelOpsiyon','Listeler Güncellesin',ChkListelerGuncellesin.Checked);
  RehberIni.WriteBool('GenelOpsiyon','ITSYeniServis',ChkITSYeniServis.Checked);
  RehberIni.WriteBool('GenelOpsiyon','Paketler Güncellesin',ChkPaketlerGuncellesin.Checked);
end;

procedure TOpsiyonDlg.VarsayilanKaydetClick(Sender: TObject);
begin
 if (TabITSHesaplari.RecordCount>0)then
  if (TabITSHesaplari.State=dsbrowse) then
   begin
    RehberIni.WriteString('GenelOpsiyon','ITSHesapId',TabITSHesaplari.FieldByName('ID').AsString);
    ITSHesapID:=TabITSHesaplari.FieldByName('ID').AsInteger;
   end;

end;

end.
