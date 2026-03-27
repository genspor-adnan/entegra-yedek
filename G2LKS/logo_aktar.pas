unit logo_aktar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Win.ADODB, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, cxContainer, Vcl.ComCtrls, dxCore,
  cxDateUtils, Vcl.StdCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, Vcl.Menus, cxButtons, Xml.xmldom, Xml.XMLIntf,
  Xml.Win.msxmldom, Xml.XMLDoc, cxMemo, dxmdaset, cxCheckBox;

type
  Tlogoaktar = class(TForm)
    QR_ftbaslik2: TADOQuery;
    SR_ftbaslik: TDataSource;
    Panel1: TPanel;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    Panel2: TPanel;
    cxDateEdit2: TcxDateEdit;
    cxDateEdit1: TcxDateEdit;
    Panel3: TPanel;
    cxRadioButton1: TcxRadioButton;
    cxRadioButton2: TcxRadioButton;
    cxButton1: TcxButton;
    XMLDocument1: TXMLDocument;
    QR_detay: TADOQuery;
    QR_logostok: TADOQuery;
    QR_logostokCODE: TStringField;
    QR_logostokNAME: TStringField;
    QR_logocari: TADOQuery;
    QR_logocariCODE: TStringField;
    QR_logocariDEFINITION_: TStringField;
    Panel5: TPanel;
    cxButton2: TcxButton;
    Panel4: TPanel;
    Panel6: TPanel;
    cxButton3: TcxButton;
    cxButton4: TcxButton;
    QR_logofatura: TADOQuery;
    QR_update: TADOQuery;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    ADOQuery1: TADOQuery;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    QR_detayKOD: TWideStringField;
    QR_detaySTOKADI: TWideStringField;
    QR_detayID: TIntegerField;
    QR_detayFATBASID: TIntegerField;
    QR_detayREHBERID: TIntegerField;
    QR_detaySEC: TWideStringField;
    QR_detayTUR: TSmallintField;
    QR_detayURUNID: TIntegerField;
    QR_detayACIKLAMA: TWideMemoField;
    QR_detayADET: TFloatField;
    QR_detayMF: TFloatField;
    QR_detayBIRIM: TSmallintField;
    QR_detayMIKTAR: TFloatField;
    QR_detayBIRIMFIYAT: TFMTBCDField;
    QR_detayTUTAR: TFMTBCDField;
    QR_detayKUR: TWideStringField;
    QR_detayISKONTO: TFloatField;
    QR_detayKDV: TSmallintField;
    QR_detayMASRAFID: TSmallintField;
    QR_detayIZLEMEKODU: TWideStringField;
    QR_detayOZELKOD: TWideStringField;
    QR_detayMUHKODU: TWideStringField;
    QR_detayKASA: TSmallintField;
    QR_detayONAY: TWideStringField;
    QR_detayDOVIZ_TUTARI: TFMTBCDField;
    QR_detayDOVIZ_KURU: TWideStringField;
    QR_detayISKONTO2: TFloatField;
    QR_detayIZLEME: TSmallintField;
    QR_detayIADEADET: TFloatField;
    QR_detayIADEFATURAID: TIntegerField;
    QR_detayYERI: TIntegerField;
    QR_detayYERID: TIntegerField;
    QR_detayEKLEYEN: TIntegerField;
    QR_detayEKLEMETARIHI: TDateTimeField;
    QR_detayDEGISTIREN: TIntegerField;
    QR_detayDEGISTIRMETARIHI: TDateTimeField;
    QR_detayDOVIZ_BIRIMFIYAT: TFMTBCDField;
    QR_detayDOVIZKURDEGERI: TBCDField;
    QR_detayPROJEID: TIntegerField;
    QR_detayKAMPANYAID: TIntegerField;
    QR_detayVADE: TWordField;
    QR_detaySTOKDURUMDEGIS: TBooleanField;
    QR_detaySUBEID: TSmallintField;
    QR_detayKDVMUHAFIYETI: TSmallintField;
    QR_detayEKMALIYET: TBCDField;
    QR_detayBASTAR: TDateTimeField;
    QR_detayBITTAR: TDateTimeField;
    QR_detayURETIMPLANID: TIntegerField;
    QR_detayURETIMPLANDETAYID: TIntegerField;
    QR_detayMERKEZID: TIntegerField;
    QR_detayckdvtut: TFloatField;
    ADOQuery1KOD: TWideStringField;
    ADOQuery1STOKADI: TWideStringField;
    ADOQuery1ID: TIntegerField;
    ADOQuery1FATBASID: TIntegerField;
    ADOQuery1REHBERID: TIntegerField;
    ADOQuery1SEC: TWideStringField;
    ADOQuery1TUR: TSmallintField;
    ADOQuery1URUNID: TIntegerField;
    ADOQuery1ACIKLAMA: TWideMemoField;
    ADOQuery1ADET: TFloatField;
    ADOQuery1MF: TFloatField;
    ADOQuery1BIRIM: TSmallintField;
    ADOQuery1MIKTAR: TFloatField;
    ADOQuery1BIRIMFIYAT: TFMTBCDField;
    ADOQuery1TUTAR: TFMTBCDField;
    ADOQuery1KUR: TWideStringField;
    ADOQuery1ISKONTO: TFloatField;
    ADOQuery1KDV: TSmallintField;
    ADOQuery1MASRAFID: TSmallintField;
    ADOQuery1IZLEMEKODU: TWideStringField;
    ADOQuery1OZELKOD: TWideStringField;
    ADOQuery1MUHKODU: TWideStringField;
    ADOQuery1KASA: TSmallintField;
    ADOQuery1ONAY: TWideStringField;
    ADOQuery1DOVIZ_TUTARI: TFMTBCDField;
    ADOQuery1DOVIZ_KURU: TWideStringField;
    ADOQuery1ISKONTO2: TFloatField;
    ADOQuery1IZLEME: TSmallintField;
    ADOQuery1IADEADET: TFloatField;
    ADOQuery1IADEFATURAID: TIntegerField;
    ADOQuery1YERI: TIntegerField;
    ADOQuery1YERID: TIntegerField;
    ADOQuery1EKLEYEN: TIntegerField;
    ADOQuery1EKLEMETARIHI: TDateTimeField;
    ADOQuery1DEGISTIREN: TIntegerField;
    ADOQuery1DEGISTIRMETARIHI: TDateTimeField;
    ADOQuery1DOVIZ_BIRIMFIYAT: TFMTBCDField;
    ADOQuery1DOVIZKURDEGERI: TBCDField;
    ADOQuery1PROJEID: TIntegerField;
    ADOQuery1KAMPANYAID: TIntegerField;
    ADOQuery1VADE: TWordField;
    ADOQuery1STOKDURUMDEGIS: TBooleanField;
    ADOQuery1SUBEID: TSmallintField;
    ADOQuery1KDVMUHAFIYETI: TSmallintField;
    ADOQuery1EKMALIYET: TBCDField;
    ADOQuery1BASTAR: TDateTimeField;
    ADOQuery1BITTAR: TDateTimeField;
    ADOQuery1URETIMPLANID: TIntegerField;
    ADOQuery1URETIMPLANDETAYID: TIntegerField;
    ADOQuery1MERKEZID: TIntegerField;
    cxGrid2DBTableView1KOD: TcxGridDBColumn;
    cxGrid2DBTableView1STOKADI: TcxGridDBColumn;
    cxGrid2DBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGrid2DBTableView1ADET: TcxGridDBColumn;
    cxGrid2DBTableView1BIRIM: TcxGridDBColumn;
    cxGrid2DBTableView1MIKTAR: TcxGridDBColumn;
    cxGrid2DBTableView1BIRIMFIYAT: TcxGridDBColumn;
    cxGrid2DBTableView1TUTAR: TcxGridDBColumn;
    cxGrid2DBTableView1KDV: TcxGridDBColumn;
    QR_ftbaslik2ID: TAutoIncField;
    QR_ftbaslik2TARIH: TDateTimeField;
    QR_ftbaslik2TUR: TSmallintField;
    QR_ftbaslik2TIPI: TSmallintField;
    QR_ftbaslik2REHBERID: TIntegerField;
    QR_ftbaslik2FATURATARIH: TDateTimeField;
    QR_ftbaslik2KOD: TWideStringField;
    QR_ftbaslik2FIRMA: TWideStringField;
    QR_ftbaslik2KDVDURUM: TWideStringField;
    QR_ftbaslik2FATURA_MATRAHI: TBCDField;
    QR_ftbaslik2KDV_TUTARI: TBCDField;
    QR_ftbaslik2FATURA_TUTARI: TBCDField;
    QR_ftbaslik2ACIKLAMA: TWideStringField;
    QR_ftbaslik2IRSALIYE_NO: TSmallintField;
    QR_ftbaslik2IRSALIYENO: TStringField;
    QR_ftbaslik2IRSALIYETARIH: TDateTimeField;
    QR_ftbaslik2AD: TWideStringField;
    cxGrid1DBTableView1FATURATARIH: TcxGridDBColumn;
    cxGrid1DBTableView1KOD: TcxGridDBColumn;
    cxGrid1DBTableView1FIRMA: TcxGridDBColumn;
    cxGrid1DBTableView1FATURA_MATRAHI: TcxGridDBColumn;
    cxGrid1DBTableView1KDV_TUTARI: TcxGridDBColumn;
    cxGrid1DBTableView1FATURA_TUTARI: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGrid1DBTableView1AD: TcxGridDBColumn;
    QR_ftbaslik2FATURANO: TWideStringField;
    cxGrid1DBTableView1FATURANO: TcxGridDBColumn;
    sqltext: TRichEdit;
    volustur: TRichEdit;
    ADOCommand1: TADOCommand;
    ADOQuery2: TADOQuery;
    QR_ftbaslik: TdxMemData;
    QR_ftbaslikID: TIntegerField;
    QR_ftbaslikTARIH: TDateTimeField;
    QR_ftbaslikTUR: TIntegerField;
    QR_ftbaslikTIPI: TIntegerField;
    QR_ftbaslikREHBERID: TIntegerField;
    QR_ftbaslikFATURATARIH: TDateTimeField;
    QR_ftbaslikKOD: TStringField;
    QR_ftbaslikFIRMA: TStringField;
    QR_ftbaslikKDVDURUM: TStringField;
    QR_ftbaslikFATURA_MATRAHI: TCurrencyField;
    QR_ftbaslikKDV_TUTARI: TCurrencyField;
    QR_ftbaslikFATURANO: TStringField;
    QR_ftbaslikACIKLAMA: TStringField;
    QR_ftbaslikAD: TStringField;
    QR_ftbaslikFATURA_TUTARI: TCurrencyField;
    QR_ftbasliksec: TIntegerField;
    cxGrid1DBTableView1sec: TcxGridDBColumn;
    RichEdit1: TRichEdit;
    QR_logohizmet: TADOQuery;
    PopupMenu1: TPopupMenu;
    mnSe1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure QR_detayCalcFields(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
    procedure cxButton4Click(Sender: TObject);
    procedure cxGrid1DBTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure mnSe1Click(Sender: TObject);
  private
  procedure alisXML;
  procedure satisXML;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  logoaktar: Tlogoaktar;

implementation

{$R *.dfm}

uses UTablo,PrjConst;
 var
 logofirmakod,logodonem:string;
procedure Tlogoaktar.satisXML;
var
  Doc: IXMLDocument;
  invoice,purchase,dispatches,dispatch: IXMLNode;
  transactions,transaction,campaing,paymentlist,payment,intel: IXMLNode;
  miktar,toplam,b_fiyat,kdvtutar:string;
begin

  Doc := NewXMLDocument;
  purchase := Doc.AddChild('SALES_INVOICES');

  QR_ftbaslik.First;
        While not QR_ftbaslik.eof Do
       begin
  invoice := purchase.AddChild('INVOICE');
  invoice.Attributes['DBOP'] := 'INS';
  invoice.AddChild('TYPE').Text := '8';
  invoice.AddChild('NUMBER').Text := QR_ftbaslikFATURANO.AsString;   //fatura_no
  invoice.AddChild('DATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
  invoice.AddChild('TIME').Text := '304492610';
  invoice.AddChild('DOC_NUMBER').Text:=''; //belge no ???
  invoice.AddChild('ARP_CODE').Text := QR_ftbaslikkod.AsString; //carikod
  invoice.AddChild('POST_FLAGS').Text := '247';
  invoice.AddChild('VAT_RATE').Text := '18'; //kdv oraný ???
  invoice.AddChild('TOTAL_DISCOUNTED').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);  //kdvsiz
  invoice.AddChild('TOTAL_VAT').Text :=floattostr(QR_ftbaslikKDV_TUTARI.AsFloat); //kdv
  invoice.AddChild('TOTAL_GROSS').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
  invoice.AddChild('TOTAL_NET').Text := floattostr(QR_ftbaslikFATURA_TUTARI.AsFloat); //g.toplam
  invoice.AddChild('TC_NET').Text := floattostr(QR_ftbaslikFATURA_TUTARI.AsFloat);
  invoice.AddChild('CREATED_BY').Text := '1';
  invoice.AddChild('DATE_CREATED').Text :=datetostr(QR_ftbaslikFATURATARIH.Value);
  invoice.AddChild('HOUR_CREATED').Text := '15';
  invoice.AddChild('MIN_CREATED').Text := '20';
  invoice.AddChild('SEC_CREATED').Text := '25';
  invoice.AddChild('CURRSEL_TOTALS').Text := '1';
//  invoice.AddChild('DATA_REFERENCE').Text := '5';

      dispatches := invoice.AddChild('DISPATCHES');
          dispatch:=  dispatches.AddChild('DISPATCH');
          dispatch.AddChild('TYPE').Text := '8';
          dispatch.AddChild('NUMBER').Text := QR_ftbaslikFATURANO.AsString;;
          dispatch.AddChild('DATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
          dispatch.AddChild('TIME').Text := '304492610';
          dispatch.AddChild('DOC_NUMBER').Text := '';
          dispatch.AddChild('INVOICE_NUMBER').Text :=QR_ftbaslikFATURANO.AsString;
          dispatch.AddChild('ARP_CODE').Text := QR_ftbaslikKOD.AsString;;
          dispatch.AddChild('INVOICED').Text := '1';
          dispatch.AddChild('TOTAL_DISCOUNTED').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
          dispatch.AddChild('TOTAL_VAT').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
          dispatch.AddChild('TOTAL_GROSS').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
          dispatch.AddChild('TOTAL_NET').Text := floattostr(QR_ftbaslikFATURA_TUTARI.AsFloat);
          dispatch.AddChild('CREATED_BY').Text := '1';
          dispatch.AddChild('DATE_CREATED').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
          dispatch.AddChild('HOUR_CREATED').Text := '15';
          dispatch.AddChild('MIN_CREATED').Text := '20';
          dispatch.AddChild('SEC_CREATED').Text := '25';
          dispatch.AddChild('CURRSEL_TOTALS').Text := '1';
 //         dispatch.AddChild('DATA_REFERENCE').Text := '5';
          dispatch.AddChild('ORIG_NUMBER').Text := QR_ftbaslikFATURANO.AsString;
          dispatch.AddChild('ORGLOGOID').Text := '';
          dispatch.AddChild('DEDUCTIONPART1').Text := '2';
          dispatch.AddChild('DEDUCTIONPART2').Text := '3';
          dispatch.AddChild('AFFECT_RISK').Text := '0';

          QR_detay.Close;
          QR_detay.SQL.Clear;
          QR_detay.SQL.Add('select * from uv_FATURASTOK where FATBASID='''+QR_ftbaslikid.AsString+'''');
          QR_detay.Open;
          QR_detay.First;
        While not QR_detay.eof Do
      begin
        miktar:=QR_detayMIKTAR.AsString;
        miktar:=StringReplace(miktar,',','.',[rfReplaceAll, rfIgnoreCase]);
        toplam:=QR_detayTUTAR.AsString;
        toplam:=StringReplace(toplam,',','.',[rfReplaceAll, rfIgnoreCase]);
        b_fiyat:=QR_detayBIRIMFIYAT.AsString;
        b_fiyat:=StringReplace(b_fiyat,',','.',[rfReplaceAll, rfIgnoreCase]);
        kdvtutar:=QR_detayckdvtut.AsString;
        kdvtutar:=StringReplace(kdvtutar,',','.',[rfReplaceAll, rfIgnoreCase]);
                       transactions := invoice.AddChild('TRANSACTIONS');
                 transaction:=  transactions.AddChild('TRANSACTION');
                 if QR_detayTUR.AsInteger=1 then transaction.AddChild('TYPE').Text := '0';
                 if QR_detayTUR.AsInteger=0 then transaction.AddChild('TYPE').Text := '4';
                 transaction.AddChild('MASTER_CODE').Text :=QR_detayKOD.AsString;
                 transaction.AddChild('QUANTITY').Text :=miktar;
                 transaction.AddChild('PRICE').Text :=b_fiyat;
                 transaction.AddChild('TOTAL').Text := toplam;
                 transaction.AddChild('UNIT_CODE').Text := 'ADET';
                 transaction.AddChild('UNIT_CONV1').Text := '1';
                 transaction.AddChild('UNIT_CONV2').Text := '1';
                 transaction.AddChild('VAT_RATE').Text :=QR_detayKDV.AsString;
                 transaction.AddChild('VAT_AMOUNT').Text :=kdvtutar;
                 transaction.AddChild('VAT_BASE').Text :=toplam;
                 transaction.AddChild('BILLED').Text := '1';
                 transaction.AddChild('TOTAL_NET').Text := toplam;
  //               transaction.AddChild('DATA_REFERENCE').Text := '10';
                 transaction.AddChild('DISPATCH_NUMBER').Text :=QR_ftbaslikFATURANO.AsString;
                 transaction.AddChild('DETAILS').Text := '';
                 transaction.AddChild('DIST_ORD_REFERENCE').Text := '0';

       QR_detay.Next;
        end;


                      campaing := transaction.AddChild('CAMPAIGN_INFOS');
                          campaing.AddChild('CAMPAIGN_INFO').Text := '';
                transaction.AddChild('EDT_CURR').Text := '1';
                transaction.AddChild('ORGLOGOID').Text := '';
                transaction.AddChild('DEFNFLDSLIST').Text := '';
                transaction.AddChild('MONTH').Text := '2';
                transaction.AddChild('YEAR').Text := '2014';

                    paymentlist := invoice.AddChild('PAYMENT_LIST');
                 payment:=  paymentlist.AddChild('PAYMENT');
                 payment.AddChild('DATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
                 payment.AddChild('MODULENR').Text := '4';
              //   payment.AddChild('SIGN').Text := '1';
                 payment.AddChild('TRCODE').Text := '8';
                 payment.AddChild('TOTAL').Text := floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
                 payment.AddChild('PROCDATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
                 payment.AddChild('DATA_REFERENCE').Text := '0';
                 payment.AddChild('DISCOUNT_DUEDATE').Text :=datetostr(QR_ftbaslikFATURATARIH.Value);
                 payment.AddChild('PAY_NO').Text := '1';
                 payment.AddChild('DISCTRLIST').Text := '';
                 payment.AddChild('DISCTRDELLIST').Text := '0';

  invoice.AddChild('ORGLOGOID').Text := '';
  invoice.AddChild('DEFNFLDSLIST').Text := '';
  invoice.AddChild('DEDUCTIONPART1').Text := '2';
  invoice.AddChild('DEDUCTIONPART2').Text := '3';
//  invoice.AddChild('DATA_LINK_REFERENCE').Text := '5';

      intel:= invoice.AddChild('INTEL_LIST');
      intel.AddChild('INTEL').Text := '';
      invoice.AddChild('AFFECT_RISK').Text := '0';

        QR_ftbaslik.Next;
        end;

Doc.Version := '1.0';
Doc.Encoding := 'ISO-8859-9';
Doc.SaveToFile('logo1.xml');


end;

procedure Tlogoaktar.alisXML;
var
  Doc: IXMLDocument;
  invoice,purchase,dispatches,dispatch: IXMLNode;
  transactions,transaction,campaing,paymentlist,payment,intel: IXMLNode;
  miktar,toplam,b_fiyat,kdvtutar:string;
begin

  Doc := NewXMLDocument;
  purchase := Doc.AddChild('PURCHASE_INVOICES');

  QR_ftbaslik.First;
        While not QR_ftbaslik.eof Do
       begin
     if QR_ftbasliksec.AsInteger=1 then begin
  invoice := purchase.AddChild('INVOICE');
  invoice.Attributes['DBOP'] := 'INS';
  invoice.AddChild('TYPE').Text := '1';
  invoice.AddChild('NUMBER').Text := QR_ftbaslikFATURANO.AsString;   //fatura_no
  invoice.AddChild('DATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
  invoice.AddChild('TIME').Text := '304492610';
  invoice.AddChild('DOC_NUMBER').Text:=''; //belge no ???
  invoice.AddChild('ARP_CODE').Text := QR_ftbaslikkod.AsString; //carikod
  invoice.AddChild('POST_FLAGS').Text := '247';
  invoice.AddChild('VAT_RATE').Text := '18'; //kdv oraný ???
  invoice.AddChild('TOTAL_DISCOUNTED').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);  //kdvsiz
  invoice.AddChild('TOTAL_VAT').Text :=floattostr(QR_ftbaslikKDV_TUTARI.AsFloat); //kdv
  invoice.AddChild('TOTAL_GROSS').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
  invoice.AddChild('TOTAL_NET').Text := floattostr(QR_ftbaslikFATURA_TUTARI.AsFloat); //g.toplam
  invoice.AddChild('TC_NET').Text := floattostr(QR_ftbaslikFATURA_TUTARI.AsFloat);
  invoice.AddChild('CREATED_BY').Text := '1';
  invoice.AddChild('DATE_CREATED').Text :=datetostr(QR_ftbaslikFATURATARIH.Value);
  invoice.AddChild('HOUR_CREATED').Text := '15';
  invoice.AddChild('MIN_CREATED').Text := '20';
  invoice.AddChild('SEC_CREATED').Text := '25';
  invoice.AddChild('CURRSEL_TOTALS').Text := '2';
//  invoice.AddChild('DATA_REFERENCE').Text := '5';

      dispatches := invoice.AddChild('DISPATCHES');
          dispatch:=  dispatches.AddChild('DISPATCH');
          dispatch.AddChild('TYPE').Text := '1';
          dispatch.AddChild('NUMBER').Text := QR_ftbaslikFATURANO.AsString;;
          dispatch.AddChild('DATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
          dispatch.AddChild('TIME').Text := '304492610';
          dispatch.AddChild('DOC_NUMBER').Text := '';
          dispatch.AddChild('INVOICE_NUMBER').Text :=QR_ftbaslikFATURANO.AsString;
          dispatch.AddChild('ARP_CODE').Text := QR_ftbaslikKOD.AsString;;
          dispatch.AddChild('INVOICED').Text := '1';
          dispatch.AddChild('TOTAL_DISCOUNTED').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
          dispatch.AddChild('TOTAL_VAT').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
          dispatch.AddChild('TOTAL_GROSS').Text :=floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
          dispatch.AddChild('TOTAL_NET').Text := floattostr(QR_ftbaslikFATURA_TUTARI.AsFloat);
          dispatch.AddChild('CREATED_BY').Text := '1';
          dispatch.AddChild('DATE_CREATED').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
          dispatch.AddChild('HOUR_CREATED').Text := '15';
          dispatch.AddChild('MIN_CREATED').Text := '20';
          dispatch.AddChild('SEC_CREATED').Text := '25';
          dispatch.AddChild('CURRSEL_TOTALS').Text := '2';
 //         dispatch.AddChild('DATA_REFERENCE').Text := '5';
          dispatch.AddChild('ORIG_NUMBER').Text := QR_ftbaslikFATURANO.AsString;
          dispatch.AddChild('ORGLOGOID').Text := '';
          dispatch.AddChild('DEDUCTIONPART1').Text := '2';
          dispatch.AddChild('DEDUCTIONPART2').Text := '3';
          dispatch.AddChild('AFFECT_RISK').Text := '0';

          QR_detay.Close;
          QR_detay.SQL.Clear;
          QR_detay.SQL.Add('select * from uv_FATURASTOK where FATBASID='''+QR_ftbaslikid.AsString+'''');
          QR_detay.Open;
          QR_detay.First;
        While not QR_detay.eof Do
      begin
        miktar:=QR_detayMIKTAR.AsString;
        miktar:=StringReplace(miktar,',','.',[rfReplaceAll, rfIgnoreCase]);
        toplam:=QR_detayTUTAR.AsString;
        toplam:=StringReplace(toplam,',','.',[rfReplaceAll, rfIgnoreCase]);
        b_fiyat:=QR_detayBIRIMFIYAT.AsString;
        b_fiyat:=StringReplace(b_fiyat,',','.',[rfReplaceAll, rfIgnoreCase]);
        kdvtutar:=QR_detayckdvtut.AsString;
        kdvtutar:=StringReplace(kdvtutar,',','.',[rfReplaceAll, rfIgnoreCase]);
                       transactions := invoice.AddChild('TRANSACTIONS');
                 transaction:=  transactions.AddChild('TRANSACTION');
                 if QR_detayTUR.AsInteger=1 then transaction.AddChild('TYPE').Text := '0';
                 if QR_detayTUR.AsInteger=0 then transaction.AddChild('TYPE').Text := '4';
                 transaction.AddChild('MASTER_CODE').Text :=QR_detayKOD.AsString;
                 transaction.AddChild('QUANTITY').Text :=miktar;
                 transaction.AddChild('PRICE').Text :=b_fiyat;
                 transaction.AddChild('TOTAL').Text := toplam;
                 transaction.AddChild('UNIT_CODE').Text := 'ADET';
                 transaction.AddChild('UNIT_CONV1').Text := '1';
                 transaction.AddChild('UNIT_CONV2').Text := '1';
                 transaction.AddChild('VAT_RATE').Text :=QR_detayKDV.AsString;
                 transaction.AddChild('VAT_AMOUNT').Text :=kdvtutar;
                 transaction.AddChild('VAT_BASE').Text :=toplam;
                 transaction.AddChild('BILLED').Text := '1';
                 transaction.AddChild('TOTAL_NET').Text := toplam;
  //               transaction.AddChild('DATA_REFERENCE').Text := '10';
                 transaction.AddChild('DISPATCH_NUMBER').Text :=QR_ftbaslikFATURANO.AsString;
                 transaction.AddChild('DETAILS').Text := '';
                 transaction.AddChild('DIST_ORD_REFERENCE').Text := '0';

       QR_detay.Next;
        end;


                      campaing := transaction.AddChild('CAMPAIGN_INFOS');
                          campaing.AddChild('CAMPAIGN_INFO').Text := '';
                transaction.AddChild('EDT_CURR').Text := '1';
                transaction.AddChild('ORGLOGOID').Text := '';
                transaction.AddChild('DEFNFLDSLIST').Text := '';
                transaction.AddChild('MONTH').Text := '2';
                transaction.AddChild('YEAR').Text := '2014';

                    paymentlist := invoice.AddChild('PAYMENT_LIST');
                 payment:=  paymentlist.AddChild('PAYMENT');
                 payment.AddChild('DATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
                 payment.AddChild('MODULENR').Text := '4';
                 payment.AddChild('SIGN').Text := '1';
                 payment.AddChild('TRCODE').Text := '1';
                 payment.AddChild('TOTAL').Text := floattostr(QR_ftbaslikFATURA_MATRAHI.AsFloat);
                 payment.AddChild('PROCDATE').Text := datetostr(QR_ftbaslikFATURATARIH.Value);
                 payment.AddChild('DATA_REFERENCE').Text := '0';
                 payment.AddChild('DISCOUNT_DUEDATE').Text :=datetostr(QR_ftbaslikFATURATARIH.Value);
                 payment.AddChild('PAY_NO').Text := '1';
                 payment.AddChild('DISCTRLIST').Text := '';
                 payment.AddChild('DISCTRDELLIST').Text := '0';

  invoice.AddChild('ORGLOGOID').Text := '';
  invoice.AddChild('DEFNFLDSLIST').Text := '';
  invoice.AddChild('DEDUCTIONPART1').Text := '2';
  invoice.AddChild('DEDUCTIONPART2').Text := '3';
//  invoice.AddChild('DATA_LINK_REFERENCE').Text := '5';

      intel:= invoice.AddChild('INTEL_LIST');
      intel.AddChild('INTEL').Text := '';
      invoice.AddChild('AFFECT_RISK').Text := '0';

     end;
        QR_ftbaslik.Next;
        end;

Doc.Version := '1.0';
Doc.Encoding := 'ISO-8859-9';
Doc.SaveToFile('logo1.xml');

end;


procedure Tlogoaktar.cxButton1Click(Sender: TObject);

begin
  QR_ftbaslik.Close;
  QR_ftbaslik2.Close;
  QR_ftbaslik2.SQL.Clear;
  QR_ftbaslik2.SQL.Add(sqltext.Text);
//  QR_ftbaslik.SQL.Add('SELECT dbo.FATBASLIK.ID, dbo.FATBASLIK.TARIH, dbo.FATBASLIK.TUR, dbo.FATBASLIK.TIPI, dbo.FATBASLIK.REHBERID, dbo.FATBASLIK.FATURATARIH, dbo.REHBER.KOD,');
//  QR_ftbaslik.SQL.Add('dbo.REHBER.FIRMA, dbo.FATBASLIK.KDVDURUM, dbo.FATBASLIK.FATURA_MATRAHI, dbo.FATBASLIK.KDV_TUTARI, dbo.FATBASLIK.FATURA_TUTARI,');
//  QR_ftbaslik.SQL.Add('dbo.FATBASLIK.ACIKLAMA, dbo.FATBASLIK.IRSALIYE_NO, dbo.FATBASLIK.IRSALIYENO, dbo.FATBASLIK.IRSALIYETARIH, dbo.ISLEMTURLERI.AD,dbo.FATBASLIK.FATURANO');
//  QR_ftbaslik.SQL.Add('FROM dbo.FATBASLIK LEFT OUTER JOIN dbo.ISLEMTURLERI ON dbo.FATBASLIK.TUR = dbo.ISLEMTURLERI.TUR LEFT OUTER JOIN dbo.REHBER ON dbo.FATBASLIK.REHBERID = dbo.REHBER.ID');
  QR_ftbaslik2.SQL.Add('where dbo.FATBASLIK.FATURATARIH between :trh1 and :trh2');



  if cxradiobutton1.Checked=true then QR_ftbaslik2.SQL.Add ('and dbo.FATBASLIK.TUR=''11'' and TIPI=''1''');
  if cxradiobutton2.Checked=true then QR_ftbaslik2.SQL.Add ('and dbo.FATBASLIK.TUR=''15'' and TIPI=''1''');

  QR_ftbaslik2.Parameters.ParamByName('trh1').Value:=datetostr(cxdateedit1.Date);
  QR_ftbaslik2.Parameters.ParamByName('trh2').Value:=datetostr(cxdateedit2.Date);
  QR_ftbaslik2.Open;
  QR_ftbaslik.DisableControls;
  QR_ftbaslik.Open;

  QR_ftbaslik2.First;
  while not QR_ftbaslik2.Eof do begin
      QR_ftbaslik.Append;
      QR_ftbaslikID.AsInteger:=QR_ftbaslik2ID.AsInteger;
      QR_ftbaslikTARIH.Value:=QR_ftbaslik2TARIH.Value;
      QR_ftbaslikTUR.AsInteger:=QR_ftbaslik2TUR.AsInteger;
      QR_ftbaslikTIPI.AsInteger:=QR_ftbaslik2TIPI.AsInteger;
      QR_ftbaslikREHBERID.AsInteger:=QR_ftbaslik2REHBERID.AsInteger;
      QR_ftbaslikFATURATARIH.Value:=QR_ftbaslik2FATURATARIH.Value;
      QR_ftbaslikKOD.AsString:=QR_ftbaslik2KOD.AsString;
      QR_ftbaslikFIRMA.AsString:=QR_ftbaslik2FIRMA.AsString;
      QR_ftbaslikKDVDURUM.AsString:=QR_ftbaslik2KDVDURUM.AsString;
      QR_ftbaslikFATURA_MATRAHI.AsCurrency:=QR_ftbaslik2FATURA_MATRAHI.AsCurrency;
      QR_ftbaslikKDV_TUTARI.AsCurrency:=QR_ftbaslik2KDV_TUTARI.AsCurrency;
      QR_ftbaslikFATURA_TUTARI.AsCurrency:=QR_ftbaslik2FATURA_TUTARI.AsCurrency;
      QR_ftbaslikFATURANO.AsString:=QR_ftbaslik2FATURANO.AsString;
      QR_ftbaslikACIKLAMA.AsString:=QR_ftbaslik2ACIKLAMA.AsString;
      QR_ftbaslikAD.AsString:=QR_ftbaslik2AD.AsString;
      QR_ftbasliksec.AsInteger:=0;
      QR_ftbaslik.Post;
      QR_ftbaslik2.Next;
      end;
  QR_ftbaslik.EnableControls;
end;

procedure Tlogoaktar.cxButton2Click(Sender: TObject);
begin
if cxRadioButton1.Checked=true then alisXML;
if cxradiobutton2.Checked=true then satisXML;
application.MessageBox('Logo1.xml Dosyasý Oluþturuldu','XML Dosya',MB_ICONINFORMATION+MB_ok);
end;

procedure Tlogoaktar.cxButton3Click(Sender: TObject);
var
tablocari,tablostok,tablohizmet:string;
begin
  QR_ftbaslik.DisableControls;
  richedit1.Clear;
  cxbutton2.Enabled:=false;
  tablocari:='LG_'+logofirmakod+'_CLCARD';
  tablostok:='LG_'+logofirmakod+'_ITEMS';
  tablohizmet:='LG_'+logofirmakod+'_SRVCARD';
    if QR_ftbaslik.Active=false then application.MessageBox('Lütfen Ýlk Önce Listeleme Yapýn','Hata',MB_ICONINFORMATION+MB_ok)
    else
    begin
    QR_ftbaslik.First;
          While not QR_ftbaslik.eof Do
          begin
            if QR_ftbasliksec.AsInteger=1 then begin

              QR_logocari.Close;
              QR_logocari.SQL.Clear;
              QR_logocari.SQL.Add('select CODE,DEFINITION_ from '+tablocari+'');
              QR_logocari.SQL.Add('where CODE = '''+QR_ftbaslikkod.AsString+'''');
              QR_logocari.Open;
                if QR_logocari.RecordCount=0 then
                begin
                Richedit1.Lines.Add('CARI KOD:'+QR_ftbaslikkod.AsString);
                end;
              QR_detay.Close;
              QR_detay.SQL.Clear;
              QR_detay.SQL.Add('select * from uv_FATURASTOK where FATBASID='''+QR_ftbaslikid.AsString+'''');
              QR_detay.Open;
              QR_detay.First;
                      While not QR_detay.eof Do
                      begin
                        if QR_detayTUR.AsInteger=1 then begin

                      QR_logostok.Close;
                      QR_logostok.SQL.Clear;
                      QR_logostok.SQL.Add('select CODE,NAME from '+tablostok+'');
                      QR_logostok.SQL.Add('where CODE = '''+QR_detayKOD.AsString+'''');
                      QR_logostok.Open;
                        if QR_logostok.RecordCount=0 then
                        begin
                        richedit1.SelAttributes.Color:=clred;
                        richedit1.Lines.Add('STOK KOD:'+QR_detayKOD.AsString);
                        end;
                        end;
                         if QR_detayTUR.AsInteger=0 then begin

                      QR_logohizmet.Close;
                      QR_logohizmet.SQL.Clear;
                      QR_logohizmet.SQL.Add('select CODE,DEFINITION_ from '+tablohizmet+'');
                      QR_logohizmet.SQL.Add('where CODE = '''+QR_detayKOD.AsString+'''');
                      QR_logohizmet.Open;
                        if QR_logohizmet.RecordCount=0 then
                        begin
                        richedit1.SelAttributes.Color:=clblue;
                        richedit1.Lines.Add('HÝZMET KOD:'+QR_detayKOD.AsString);
                        end;
                        end;
                      QR_detay.Next;
                      end;
             end;
          QR_ftbaslik.Next;
          end;
      end;
              if richedit1.Lines.Count=0 then
              begin
              richedit1.Lines.Add('Aktarým Yapýlabilir');
              cxbutton2.Enabled:=true;
              end;
   QR_ftbaslik.EnableControls;
end;

procedure Tlogoaktar.cxButton4Click(Sender: TObject);
var
tablofatura:string;
begin
    tablofatura:='LG_'+logofirmakod+'_'+logodonem+'_INVOICE';

      if QR_ftbaslik.Active=false then application.MessageBox('Lütfen Ýlk Önce Listeleme Yapýn','Hata',MB_ICONINFORMATION+MB_ok)
    else
    begin
    QR_ftbaslik.First;
          While not QR_ftbaslik.eof Do
          begin
           if QR_ftbasliksec.AsInteger=1 then begin
          QR_logofatura.Close;
          QR_logofatura.SQL.Clear;
          QR_logofatura.SQL.Add('select FICHENO from '+tablofatura+'');
          QR_logofatura.SQL.Add('where FICHENO='''+QR_ftbaslikFATURANO.AsString+'''');
          QR_logofatura.Open;
              if QR_logofatura.RecordCount=1 then
              begin
              QR_update.Close;
              QR_update.SQL.Clear;
              QR_update.SQL.Add('update FATBASLIK set MUHAKTAR =''1''');
              QR_update.SQL.Add('where FATURANO='''+QR_ftbaslikfaturano.AsString+'''');
              QR_update.ExecSQL;
              QR_update.Close;
              end;
           end;
           QR_ftbaslik.Next;
          end;
    application.MessageBox('UPDATE YAPILDI','OK',MB_ICONINFORMATION+MB_ok)
    end;
end;

procedure Tlogoaktar.cxGrid1DBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
adoquery1.Close;
adoquery1.SQL.Clear;
adoquery1.SQL.Add('select * from uv_FATURASTOK where FATBASID='''+QR_ftbaslikid.AsString+'''');
adoquery1.Open;
end;

procedure Tlogoaktar.FormCreate(Sender: TObject);
begin
  inherited;
//  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=aktarim_yolu',Tablo.configuration.Root);
//  aktarimYoluEdit.Text := node.Params.Values['yol'];

 case Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,G2MuhEnt_LKS) of
   G2MuhEnt_LKS:begin
//       showmessage('logo');
    end;
   G2MuhEnt_Orka :begin
//      showmessage('orko');
      logoaktar.Close;
    end;
 end;



  QR_logostok.Connection:=tablo.lksConnection;
  QR_logocari.Connection:=tablo.lksConnection;
  QR_logohizmet.Connection:=tablo.lksConnection;
  QR_logofatura.Connection:=tablo.lksConnection;
  QR_ftbaslik2.Connection:=tablo.cnn;
  QR_detay.Connection:=tablo.cnn;
  QR_update.Connection:=tablo.cnn;
  adoquery1.Connection:=tablo.cnn;
  adoquery2.Connection:=tablo.cnn;
  adoquery2.Close;
  adoquery2.SQL.Clear;
  adoquery2.SQL.Add('select * from sysobjects where xtype=''V'' and name=''uv_FATURASTOK''');
  adoquery2.Open;
  if adoquery2.RecordCount=0 then begin
     adocommand1.Connection:=tablo.cnn;
     adocommand1.CommandText:= volustur.Text;
     adocommand1.Execute;
     end;






end;

procedure Tlogoaktar.FormShow(Sender: TObject);
begin
Logofirmakod:=Tablo.GENINI.ReadString(Ops_G2LKS_FirmaNo,'-999');
Logodonem:=Tablo.GENINI.ReadString(Ops_G2LKS_DonemNo,'-999');
cxdateedit1.Date:=now-30;
cxdateedit2.Date:=now;
QR_logostok.Open;
end;

procedure Tlogoaktar.mnSe1Click(Sender: TObject);
begin
  QR_ftbaslik.DisableControls;
  QR_ftbaslik.First;
  while not QR_Ftbaslik.Eof do begin
      QR_ftbaslik.Edit;
      QR_ftbasliksec.AsInteger:=1;
      QR_ftbaslik.Post;
      QR_ftbaslik.Next;
  end;
   QR_ftbaslik.EnableControls;

end;

procedure Tlogoaktar.QR_detayCalcFields(DataSet: TDataSet);
begin

QR_detayckdvtut.AsCurrency:=QR_detayKDV.AsCurrency * QR_detayTUTAR.AsCurrency / 100;

end;

end.
