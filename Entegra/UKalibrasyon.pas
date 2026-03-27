unit UKalibrasyon;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxDBLabel, cxDropDownEdit, cxDBEdit, cxCurrencyEdit, cxMemo, cxButtonEdit,
  cxTextEdit, cxMaskEdit, cxCalendar, cxLabel, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, Data.DB, FireDAC.Comp.Client, dxSkinLiquidSky,
  dxSkinLondonLiquidSky;

type
  TKalibrasyonDlg = class(TForm)
    dtsKalibrasyon: TDataSource;
    TabKalibrasyon: TFDQuery;
    ToolBar4: TToolBar;
    KalKaydetTus: TToolButton;
    KalIptalTus: TToolButton;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    cxLabel22: TcxLabel;
    DateKalibTarih: TcxDBDateEdit;
    cxLabel23: TcxLabel;
    DateKalibGecerlilikTarihi: TcxDBDateEdit;
    cxLabel13: TcxLabel;
    SertifikaKalibrasyon: TcxDBTextEdit;
    cxLabel14: TcxLabel;
    BEFirmaKalibrasyon: TcxButtonEdit;
    cxLabel15: TcxLabel;
    BEFirmaYetkiliKalibrasyon: TcxButtonEdit;
    NotlarKalibrasyon: TcxDBMemo;
    cxLabel16: TcxLabel;
    cxLabel17: TcxLabel;
    MaliyetKalibrasyon: TcxDBCurrencyEdit;
    ComboKurlarKalibrasyon: TcxDBComboBox;
    cxDBLabel2: TcxDBLabel;
    procedure TabKalibrasyonNewRecord(DataSet: TDataSet);
    procedure dtsKalibrasyonStateChange(Sender: TObject);
    procedure BEFirmaKalibrasyonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BEFirmaYetkiliKalibrasyonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KalKaydetTusClick(Sender: TObject);
    procedure KalIptalTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IslemOp: Char;
    Cagiran, DemirbasId, Id:Integer;
  end;

var
  KalibrasyonDlg: TKalibrasyonDlg;

implementation

{$R *.dfm}

uses UTablo, PrjConst;

procedure TKalibrasyonDlg.BEFirmaKalibrasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-99,AButtonIndex, TabKalibrasyon, 'REHBERID');
end;

procedure TKalibrasyonDlg.BEFirmaYetkiliKalibrasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
//var ID : Integer;
//  st:TStringList;
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabKalibrasyon);
{if TabKalibrasyon.FieldByName('GONDERILENFIRMA').AsInteger < 0  then
  Exit;
 if AButtonIndex = 0 then begin
     st := Tstringlist.create;
     if Tablo.ListedenBilgiGetir(MusteriilgiliSec, ' select ID, ADSOYAD from REHBERPERSONEL '+
                       ' where REHBERID='+TabKalibrasyon.FieldByName('GONDERILENFIRMA').AsString+' and NEREDE=1 and  ADSOYAD like''%<ara>%''  order by 2',st,[],'',TNotifyEvent(nil),Tablo.FDCnn) then begin
        TabKalibrasyon.Edit;
        TabKalibrasyon.FieldByName('FIRMAPERSONELI').AsString := st.Strings[0];
        BEFirmaYetkiliKalibrasyon.Text:= st.Strings[1];
     end;
 end else if AButtonIndex = 1 then begin
      TabKalibrasyon.Edit;
      TabKalibrasyon.FieldByName('FIRMAPERSONELI').AsInteger := 0;
      BEFirmaYetkiliKalibrasyon.Text := ''; }
 end;

procedure TKalibrasyonDlg.dtsKalibrasyonStateChange(Sender: TObject);
begin
  KalKaydetTus.Visible := dtsKalibrasyon.State in [dsEdit, dsInsert];
  KalIptalTus.Visible := KalKaydetTus.Visible;
end;

procedure TKalibrasyonDlg.FormShow(Sender: TObject);
begin
   TabloYenile(TabKalibrasyon,[Id]);
   case IslemOp of
     'E': TabKalibrasyon.Append;
     'D': begin
             if TabKalibrasyon.FieldByName('REHBERID').AsString <> '' then
                BEFirmaKalibrasyon.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabKalibrasyon.FieldByName('REHBERID').AsString);
             if TabKalibrasyon.FieldByName('FIRMAPERSONELI').AsString <> '' then
                BEFirmaYetkiliKalibrasyon.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabKalibrasyon.FieldByName('FIRMAPERSONELI').AsString);
           end;
     end;
     DateKalibTarih.SetFocus;
end;

procedure TKalibrasyonDlg.KalIptalTusClick(Sender: TObject);
begin
   TabKalibrasyon.Cancel;
   modalResult := mrCancel;
end;

procedure TKalibrasyonDlg.KalKaydetTusClick(Sender: TObject);
begin
   TabKalibrasyon.Post;
   modalResult := mrOK;
end;

procedure TKalibrasyonDlg.TabKalibrasyonNewRecord(DataSet: TDataSet);
begin
   TabKalibrasyon.FieldByName('DEMIRBASID').AsInteger := DemirbasId;
   BEFirmaKalibrasyon.Text :='';
   BEFirmaYetkiliKalibrasyon.Text :='';
   TabKalibrasyon.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrh;
   TabKalibrasyon.FieldByName('GECERLILIKTARIHI').AsDateTime := Tablo.GENINI.BugunTrh+365;
   TabKalibrasyon.FieldByName('MALIYET').AsCurrency := 0;
   TabKalibrasyon.FieldByName('KUR').AsString := CariDoviz;
   TabKalibrasyon.FieldByName('EKLEYEN').AsString := Kullanan;
end;

end.


