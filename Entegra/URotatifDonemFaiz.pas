unit URotatifDonemFaiz;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData, cxCheckBox,
  Vcl.ComCtrls, Vcl.ToolWin, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  cxLabel, Vcl.Buttons, Vcl.ExtCtrls, FireDAC.Comp.Client, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TRotatifDonemFaizDlg = class(TForm)
    KREDIROTATIFDONEM: TFDQuery;
    DtsRotatifFaiz: TDataSource;
    KREDIROTATIFFAIZ: TFDQuery;
    DtsRotatifDonem: TDataSource;
    Panel6: TPanel;
    SpeedButton3: TSpeedButton;
    Label44: TcxLabel;
    GridFaiz: TcxGrid;
    GridFaizView: TcxGridDBTableView;
    GridFaizViewID: TcxGridDBColumn;
    GridFaizViewKREDIID: TcxGridDBColumn;
    GridFaizViewBASTARIH: TcxGridDBColumn;
    GridFaizViewBITTARIH: TcxGridDBColumn;
    GridFaizViewORAN: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    ToolBar3: TToolBar;
    Label45: TcxLabel;
    FaizEkleTus: TToolButton;
    FaizSilTus: TToolButton;
    FaizKaydetTus: TToolButton;
    FaizIptalTus: TToolButton;
    Panel1: TPanel;
    ToolBar4: TToolBar;
    cxLabel2: TcxLabel;
    SatirEkleTus: TToolButton;
    DonemSilTus: TToolButton;
    DonemKaydetTus: TToolButton;
    DonemIptalTus: TToolButton;
    GridDonem: TcxGrid;
    GridDonemView: TcxGridDBTableView;
    GridDonemViewBASTARIH: TcxGridDBColumn;
    GridDonemViewBITTARIH: TcxGridDBColumn;
    GridDonemViewUYGULANDI: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    DonemEkleTus: TToolButton;
    procedure FaizEkleTusClick(Sender: TObject);
    procedure FaizIptalTusClick(Sender: TObject);
    procedure FaizKaydetTusClick(Sender: TObject);
    procedure FaizSilTusClick(Sender: TObject);
    procedure SatirEkleTusClick(Sender: TObject);
    procedure DonemIptalTusClick(Sender: TObject);
    procedure DonemKaydetTusClick(Sender: TObject);
    procedure DonemSilTusClick(Sender: TObject);
    procedure KREDIROTATIFDONEMNewRecord(DataSet: TDataSet);
    procedure KREDIROTATIFDONEMBeforePost(DataSet: TDataSet);
    procedure KREDIROTATIFFAIZNewRecord(DataSet: TDataSet);
    procedure KREDIROTATIFFAIZBeforePost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure DonemEkleTusClick(Sender: TObject);
    procedure DtsRotatifFaizStateChange(Sender: TObject);
    procedure DtsRotatifDonemStateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    KREDIID : Integer;
  end;

var
  RotatifDonemFaizDlg: TRotatifDonemFaizDlg;

implementation

uses UTablo, prjconst, FetaKurulusSiniflari;

{$R *.dfm}

var
   SonTarih : TDateTime;

procedure TRotatifDonemFaizDlg.SatirEkleTusClick(Sender: TObject);
begin
   KREDIROTATIFDonem.Append;
end;

procedure TRotatifDonemFaizDlg.DonemEkleTusClick(Sender: TObject);
    procedure Ekle(Bastar,BitTar:TDateTime);
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO [dbo].[KREDIROTATIFDONEM]([KREDIID],[BASTARIH],[BITTARIH],[UYGULANDI],[EKLEYEN])'+
        ' VALUES('+IntToStr(KREDIID)+','''+FormatDateTime('yyyy-mm-dd', BasTar)+''','''+FormatDateTime('yyyy-mm-dd', BitTar)+''',0,'+Kullanan+')',[],[]);
    end;
begin
    Ekle(StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil)),StrToDateTime('31'+FormatSettings.DateSeparator+'03'+FormatSettings.DateSeparator+IntToStr(CariYil)) );
    Ekle(StrToDateTime('01'+FormatSettings.DateSeparator+'04'+FormatSettings.DateSeparator+IntToStr(CariYil)),StrToDateTime('30'+FormatSettings.DateSeparator+'06'+FormatSettings.DateSeparator+IntToStr(CariYil)) );
    Ekle(StrToDateTime('01'+FormatSettings.DateSeparator+'07'+FormatSettings.DateSeparator+IntToStr(CariYil)),StrToDateTime('30'+FormatSettings.DateSeparator+'09'+FormatSettings.DateSeparator+IntToStr(CariYil)) );
    Ekle(StrToDateTime('01'+FormatSettings.DateSeparator+'10'+FormatSettings.DateSeparator+IntToStr(CariYil)),StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil)) );
    TabloYenile(KREDIROTATIFDonem,[KREDIID]);
end;

procedure TRotatifDonemFaizDlg.DonemIptalTusClick(Sender: TObject);
begin
   KREDIROTATIFDonem.Cancel;
end;

procedure TRotatifDonemFaizDlg.DonemKaydetTusClick(Sender: TObject);
begin
   KREDIROTATIFDonem.post;
end;

procedure TRotatifDonemFaizDlg.DonemSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     KREDIROTATIFDonem.Delete;
end;

procedure TRotatifDonemFaizDlg.DtsRotatifDonemStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsRotatifDonem, DonemEkleTus,DonemSilTus,DonemKaydetTus,DonemIptalTus);
end;

procedure TRotatifDonemFaizDlg.DtsRotatifFaizStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsRotatifFaiz, FaizEkleTus,FaizSilTus,FaizKaydetTus,FaizIptalTus);
end;

procedure TRotatifDonemFaizDlg.FaizEkleTusClick(Sender: TObject);
begin
   KREDIROTATIFFaiz.Last;
   if KREDIROTATIFFaiz.RecordCount>0 then
      SonTarih := KREDIROTATIFFaiz.FieldByName('BITTARIH').AsDateTime
   else
      SonTarih := Tablo.GENINI.BugunTrh;
   KREDIROTATIFFaiz.Append;
end;

procedure TRotatifDonemFaizDlg.FaizIptalTusClick(Sender: TObject);
begin
   KREDIROTATIFFaiz.Cancel;
end;

procedure TRotatifDonemFaizDlg.FaizKaydetTusClick(Sender: TObject);
begin
   KREDIROTATIFFaiz.Post;
end;

procedure TRotatifDonemFaizDlg.FaizSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     KREDIROTATIFFaiz.Delete;
end;

procedure TRotatifDonemFaizDlg.FormShow(Sender: TObject);
begin
    TabloYenile(KREDIROTATIFFaiz, [KREDIID]);
    TabloYenile(KREDIROTATIFDonem,[KREDIID]);
end;

procedure TRotatifDonemFaizDlg.KREDIROTATIFDONEMBeforePost(DataSet: TDataSet);
begin
   KREDIROTATIFDonem.FieldByName('DEGISTIREN').AsString := Kullanan;
   KREDIROTATIFDonem.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
   KREDIROTATIFDonem.FieldByName('BASTARIH').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',  KREDIROTATIFDonem.FieldByName('BASTARIH').AsDateTime);
   KREDIROTATIFDonem.FieldByName('BITTARIH').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',  KREDIROTATIFDonem.FieldByName('BITTARIH').AsDateTime);
end;

procedure TRotatifDonemFaizDlg.KREDIROTATIFDONEMNewRecord(DataSet: TDataSet);
begin
   KREDIROTATIFDonem.FieldByName('EKLEYEN').AsString := Kullanan;
   KREDIROTATIFDonem.FieldByName('KREDIID').AsInteger := KREDIID;
   KREDIROTATIFDonem.FieldByName('BASTARIH').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',  Tablo.GENINI.BugunTrh);
   KREDIROTATIFDonem.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TRotatifDonemFaizDlg.KREDIROTATIFFAIZBeforePost(DataSet: TDataSet);
begin
   KREDIROTATIFFaiz.FieldByName('DEGISTIREN').AsString := Kullanan;
   KREDIROTATIFFaiz.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
   //KREDIROTATIFFaiz.FieldByName('BASTARIH').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',  KREDIROTATIFFaiz.FieldByName('BASTARIH').AsDateTime);
   //KREDIROTATIFFaiz.FieldByName('BITTARIH').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',  KREDIROTATIFFaiz.FieldByName('BITTARIH').AsDateTime);
end;

procedure TRotatifDonemFaizDlg.KREDIROTATIFFAIZNewRecord(DataSet: TDataSet);
begin
   KREDIROTATIFFaiz.FieldByName('EKLEYEN').AsString := Kullanan;
   KREDIROTATIFFaiz.FieldByName('KREDIID').AsInteger := KREDIID;
   KREDIROTATIFFaiz.FieldByName('BASTARIH').AsDateTime := SonTarih;
   KREDIROTATIFFaiz.FieldByName('BITTARIH').AsDateTime := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+'2050');;
   KREDIROTATIFFaiz.FieldByName('SUBEID').AsInteger := SubeID;
end;

end.



