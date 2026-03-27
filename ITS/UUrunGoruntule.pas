unit UUrunGoruntule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvNavigationPane, StdCtrls, ExtCtrls, DB, ADODB, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, cxContainer, cxLabel, cxDBLabel;

type
  TUrunBilgiDlg = class(TForm)
    JvNavPanelHeader1: TJvNavPanelHeader;
    Label1: TLabel;
    Panel1: TPanel;
    JvNavPanelHeader4: TJvNavPanelHeader;
    Label3: TLabel;
    Panel3: TPanel;
    TabUrunDurum: TADOQuery;
    DtsUrunDurum: TDataSource;
    GridUrunDurum: TcxGrid;
    TvUrunDurum: TcxGridDBTableView;
    GlUrunDurum: TcxGridLevel;
    TabUrunDurumBILDIRIM_TARIH: TDateTimeField;
    TabUrunDurumURUN_DURUM: TStringField;
    TabUrunDurumHATA_KODU: TStringField;
    TabUrunDurumHATA_ACIKLAMA: TStringField;
    TvUrunDurumBILDIRIM_TARIH: TcxGridDBColumn;
    TvUrunDurumURUN_DURUM: TcxGridDBColumn;
    TvUrunDurumHATA_KODU: TcxGridDBColumn;
    TvUrunDurumHATA_ACIKLAMA: TcxGridDBColumn;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    TabUrunBilgi: TADOQuery;
    DtsTabUrunBilgi: TDataSource;
    TabUrunBilgiID: TAutoIncField;
    TabUrunBilgiGIRISTURU: TWordField;
    TabUrunBilgiSTOKID: TIntegerField;
    TabUrunBilgiGIRFATBASID: TIntegerField;
    TabUrunBilgiGIRFATURAID: TIntegerField;
    TabUrunBilgiURUNBARKOD: TStringField;
    TabUrunBilgiSIRANO: TStringField;
    TabUrunBilgiSERINO: TStringField;
    TabUrunBilgiCIKISTURU: TWordField;
    TabUrunBilgiCIKFATBASID: TIntegerField;
    TabUrunBilgiCIKFATURAID: TIntegerField;
    TabUrunBilgiGARANTIBITIS: TDateTimeField;
    TabUrunBilgiIZLEMTURU: TWordField;
    TabUrunBilgiONAY: TBooleanField;
    TabUrunBilgiSONKULLANIM: TDateTimeField;
    TabUrunBilgiLOTNO: TStringField;
    TabUrunBilgiURETIMTIPI: TStringField;
    TabUrunBilgiURUNCINSI: TStringField;
    TabUrunBilgiURETIMTARIHI: TDateTimeField;
    TabUrunBilgiPAKETID: TIntegerField;
    TabUrunBilgiTASIMA_BIRIMI_ID: TIntegerField;
    TabUrunBilgiDEPOID: TIntegerField;
    TabUrunBilgiSEC: TBooleanField;
    TabUrunBilgiPOSAYISI: TStringField;
    TabUrunBilgiID_1: TAutoIncField;
    TabUrunBilgiKOD: TWideStringField;
    TabUrunBilgiSTOKADI: TWideStringField;
    TabUrunBilgiTIPI: TSmallintField;
    TabUrunBilgiMARKA: TSmallintField;
    TabUrunBilgiMODEL: TSmallintField;
    TabUrunBilgiGRUBU: TSmallintField;
    TabUrunBilgiOZELLIK: TSmallintField;
    TabUrunBilgiOZELKOD: TWideStringField;
    TabUrunBilgiMUHKODU: TWideStringField;
    TabUrunBilgiANABIRIM: TWordField;
    TabUrunBilgiBIRIM2: TWordField;
    TabUrunBilgiBIRIM2MIKTAR: TIntegerField;
    TabUrunBilgiMINSTOK: TIntegerField;
    TabUrunBilgiYERI: TWordField;
    TabUrunBilgiURETICIID: TIntegerField;
    TabUrunBilgiSATICIID: TIntegerField;
    TabUrunBilgiKDV: TWordField;
    TabUrunBilgiEKVERGI: TWordField;
    TabUrunBilgiXBARKODX: TWideStringField;
    TabUrunBilgiDURUM: TWordField;
    TabUrunBilgiFIYAT_LISTE: TWordField;
    TabUrunBilgiIZLEME: TWordField;
    TabUrunBilgiRAFOMRU_SURE: TSmallintField;
    TabUrunBilgiRAFOMRU_BIRIM: TIntegerField;
    TabUrunBilgiMASRAFID: TSmallintField;
    TabUrunBilgiBOYUT_EN: TFloatField;
    TabUrunBilgiBOYUT_BOY: TFloatField;
    TabUrunBilgiBOYUT_YUKSEKLIK: TFloatField;
    TabUrunBilgiBOYUT_ALAN: TFloatField;
    TabUrunBilgiBOYUT_NET_HACIM: TFloatField;
    TabUrunBilgiBOYUT_BRUT_HACIM: TFloatField;
    TabUrunBilgiBOYUT_NET_AGIRLIK: TFloatField;
    TabUrunBilgiBOYUT_BRUT_AGIRLIK: TFloatField;
    TabUrunBilgiUZUNLUK_BIRIMI: TWordField;
    TabUrunBilgiALAN_BIRIMI: TWordField;
    TabUrunBilgiHACIM_BIRIMI: TWordField;
    TabUrunBilgiAGIRLIK_BIRIMI: TWordField;
    TabUrunBilgiNOTLAR: TWideStringField;
    TabUrunBilgiYETKIKODU: TWideStringField;
    TabUrunBilgiGARANTISURESI: TSmallintField;
    TabUrunBilgiKISAYOLGRUBU: TWordField;
    TabUrunBilgiPAKET: TBooleanField;
    TabUrunBilgiEKLEYEN: TSmallintField;
    TabUrunBilgiEKLEMETARIHI: TDateTimeField;
    TabUrunBilgiDEGISTIREN: TSmallintField;
    TabUrunBilgiDEGISTIRMETARIHI: TDateTimeField;
    TabUrunBilgiGELIRID: TSmallintField;
    TabUrunBilgiDETAYBOLUMU: TWideStringField;
    TabUrunBilgiID_2: TAutoIncField;
    TabUrunBilgiSTOKIDID: TIntegerField;
    TabUrunBilgiSTOKID_1: TIntegerField;
    TabUrunBilgiURUNKODU: TStringField;
    TabUrunBilgiDOGRULAMA_DURUM: TWideStringField;
    TabUrunBilgiDOGRULAMA_TARIH: TDateTimeField;
    TabUrunBilgiALIM_DURUM: TWideStringField;
    TabUrunBilgiALIM_BILDIRIM_TARIH: TDateTimeField;
    TabUrunBilgiSATIS_DURUM: TWideStringField;
    TabUrunBilgiSATIS_BILDIRIM_TARIH: TDateTimeField;
    TabUrunBilgiALIM_IADE_DURUM: TWideStringField;
    TabUrunBilgiALIM_IADE_BILDIRIM_TARIH: TDateTimeField;
    TabUrunBilgiSATIS_IPTAL_DURUM: TWideStringField;
    TabUrunBilgiSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField;
    TabUrunBilgiDEAKTIVASYON_DURUM: TWideStringField;
    TabUrunBilgiDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField;
    TabUrunBilgiMALALINANGLN: TWideStringField;
    TabUrunBilgiMALSATILANGLN: TWideStringField;
    TabUrunBilgiTRANSFERID: TStringField;
    TabUrunBilgiURETIM_DURUM: TStringField;
    TabUrunBilgiURETIM_BILDIRIM_TARIH: TDateTimeField;
    TabUrunDurumID: TAutoIncField;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxDBLabel5: TcxDBLabel;
    cxDBLabel6: TcxDBLabel;
    procedure FormShow(Sender: TObject);
    procedure TabUrunBilgiAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UrunBilgiDlg: TUrunBilgiDlg;

implementation

uses UTablo;

{$R *.dfm}

procedure TUrunBilgiDlg.FormShow(Sender: TObject);
begin
TabUrunBilgi.Close;
TabUrunBilgi.Parameters[0].Value := UTablo.TakipUrunIdId;
TabUrunBilgi.Open;

end;

procedure TUrunBilgiDlg.TabUrunBilgiAfterScroll(DataSet: TDataSet);
begin
TabUrunDurum.Close;
TabUrunDurum.Parameters[0].Value:= TabUrunBilgi.FieldByName('URUNBARKOD').AsString;
TabUrunDurum.Parameters[1].Value:= TabUrunBilgi.FieldByName('SIRANO').AsString;
TabUrunDurum.Open;

end;

end.
