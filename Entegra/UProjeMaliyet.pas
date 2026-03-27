unit UProjeMaliyet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, Data.DB, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, Vcl.Menus, FireDAC.Comp.Client, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, Vcl.ComCtrls, Vcl.ToolWin, cxCurrencyEdit,
  cxDropDownEdit, cxButtonEdit, cxTextEdit, Vcl.StdCtrls;

type
  TProjeMaliyetDlg = class(TForm)
    ToolBar4: TToolBar;
    BtnYeni: TToolButton;
    BtnSil: TToolButton;
    BtnKaydet: TToolButton;
    gridMaliyet: TcxGrid;
    gridMaliyetView: TcxGridDBTableView;
    gridMaliyetLevel1: TcxGridLevel;
    TabMaliyet: TFDQuery;
    DtsMaliyet: TDataSource;
    BtnIptal: TToolButton;
    TabMaliyetID: TAutoIncField;
    TabMaliyetYER: TIntegerField;
    TabMaliyetYERID: TIntegerField;
    TabMaliyetPROJEID: TIntegerField;
    TabMaliyetMASRAFID: TIntegerField;
    TabMaliyetTUTAR: TBCDField;
    TabMaliyetEKLEYEN: TIntegerField;
    TabMaliyetKUR: TWideStringField;
    TabMaliyetEKLEMETARIHI: TDateTimeField;
    TabMaliyetDEGISTIREN: TIntegerField;
    TabMaliyetDEGISTIRMETARIHI: TDateTimeField;
    TabMaliyetPROJEKODU: TWideStringField;
    TabMaliyetPROJEADI: TWideStringField;
    TabMaliyetMASRAFKODU: TWideStringField;
    TabMaliyetMASRAFADI: TWideStringField;
    gridMaliyetViewID: TcxGridDBColumn;
    gridMaliyetViewPROJEID: TcxGridDBColumn;
    gridMaliyetViewMASRAFID: TcxGridDBColumn;
    gridMaliyetViewTUTAR: TcxGridDBColumn;
    gridMaliyetViewKUR: TcxGridDBColumn;
    gridMaliyetViewPROJEKODU: TcxGridDBColumn;
    gridMaliyetViewPROJEADI: TcxGridDBColumn;
    gridMaliyetViewMASRAFKODU: TcxGridDBColumn;
    gridMaliyetViewMASRAFADI: TcxGridDBColumn;
    SqlMemoMasrafKalemi: TMemo;
    procedure DtsMaliyetStateChange(Sender: TObject);
    procedure BtnYeniClick(Sender: TObject);
    procedure BtnSilClick(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure TabMaliyetNewRecord(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure gridMaliyetViewPROJEKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure gridMaliyetViewMASRAFKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    Yer, YerId, RehberId, Tur : Integer;
  end;

var
  ProjeMaliyetDlg: TProjeMaliyetDlg;

implementation

uses  UTablo, prjconst, FetaKurulusSiniflari;

{$R *.dfm}

procedure TProjeMaliyetDlg.BtnIptalClick(Sender: TObject);
begin
   TabMaliyet.Cancel;
end;

procedure TProjeMaliyetDlg.BtnKaydetClick(Sender: TObject);
begin
   TabMaliyet.Post;
end;

procedure TProjeMaliyetDlg.BtnSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabMaliyet.Delete;
end;

procedure TProjeMaliyetDlg.BtnYeniClick(Sender: TObject);
begin
   TabMaliyet.Append;
end;

procedure TProjeMaliyetDlg.DtsMaliyetStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsMaliyet, BtnYeni, BtnSil, BtnKaydet, BtnIptal);
end;

procedure TProjeMaliyetDlg.FormShow(Sender: TObject);
begin
   TabloYenile( TabMaliyet, [Yer,YerId]);
end;

procedure TProjeMaliyetDlg.gridMaliyetViewMASRAFKODUPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI,SqlText: string;
  i: SmallInt;
begin

  if AButtonIndex = 0 then begin
      if (Tur in [14..29])or(Tur=88) then
        i := 1
     else
        i := 0;

    //eðer proje seçilmiþse ve o projeye girilmiþ bütçe var ise o bütçe kalemlerinden masraf kalemi seçilir
    if (TabMaliyet.FieldByName('PROJEID').AsString<>'')and
       (Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT top 1 * FROM PROJEBUTCE WHERE PROJEID='+TabMaliyet.FieldByName('PROJEID').AsString,[],[])) then
        SqlText := SqlMemoMasrafKalemi.Text+ ' and PROJEID='+TabMaliyet.FieldByName('PROJEID').AsString
     else
        SqlText := '';

    if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI,SqlText) then begin
      TabMaliyet.Edit;
      TabMaliyet.FieldByName('MASRAFID').AsString := MASRAFID;
      //EditMM.Text := MASRAFMERKEZI;
      //lblMasrafKod.Caption := MASRAFKODU;
    end;
  end else if AButtonIndex = 1 then begin
      TabMaliyet.Edit;
      TabMaliyet.FieldByName('MASRAFID').AsInteger := 0;
      //EditMM.Text := '';
      //lblMasrafKod.Caption := '';
  end;
  TabloYenile( TabMaliyet, [Yer,YerId]);
end;

procedure TProjeMaliyetDlg.gridMaliyetViewPROJEKODUPropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaPROJEIDGonder(nil, TabMaliyet, AButtonIndex, ProjeSecimi, RehberId);
   TabloYenile( TabMaliyet, [Yer,YerId]);
end;

procedure TProjeMaliyetDlg.TabMaliyetNewRecord(DataSet: TDataSet);
begin
   TabMaliyet.FieldByName('YER').AsInteger:=Yer;
   TabMaliyet.FieldByName('YERID').AsInteger:=YerId;
   TabMaliyet.FieldByName('TUTAR').Ascurrency:= 0;
   TabMaliyet.FieldByName('KUR').AsString:= CariDoviz;
end;

end.


