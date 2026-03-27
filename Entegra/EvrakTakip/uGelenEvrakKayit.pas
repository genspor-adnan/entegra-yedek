unit uGelenEvrakKayit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  uEvrakModule,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Comp.Client, System.Actions, Vcl.ActnList, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxDBEdit,
  cxTextEdit, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, cxDBData, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox,
  cxButtonEdit, cxLabel, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxMemo;

type
  TfrmGelenEvrakKayit = class(TForm)
    ActionList1: TActionList;
    actKaydet: TAction;
    actDosyaEkle: TAction;
    actBarkod: TAction;
    actKapat: TAction;
    qryEvrakTablo: TFDQuery;
    qryImaj: TFDQuery;
    dsEvrakTablo: TDataSource;
    dsImaj: TDataSource;
    Panel1: TPanel;
    buttonKapat: TSpeedButton;
    buttonBarcode: TSpeedButton;
    buttonDosyaEkle: TSpeedButton;
    buttonKaydet: TSpeedButton;
    checkHizliKaydet: TCheckBox;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    editEvrakTarihi: TcxDBDateEdit;
    PanelInput: TPanel;
    memoAciklama: TcxDBMemo;
    GridOzelAlan: TcxGrid;
    ViewOzelAlan: TcxGridDBTableView;
    GridOzelAlanLevel1: TcxGridLevel;
    cxLabel1: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    cxLabel15: TcxLabel;
    cxLabel16: TcxLabel;
    cxLabel17: TcxLabel;
    cxLabel18: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    editCevapSuresi: TcxDBTextEdit;
    editEsasNo: TcxDBTextEdit;
    editEvrakAdedi: TcxTextEdit;
    editEvrakDosyaKodu: TcxDBButtonEdit;
    editEvrakInsertDate: TcxDBDateEdit;
    editGelenEvrakNo: TcxDBTextEdit;
    editIlgiliEvrakNo: TcxDBButtonEdit;
    editKonusu: TcxDBTextEdit;
    evrakDosyaNumarasi: TcxDBTextEdit;
    lookupEvrakCinsi: TcxDBLookupComboBox;
    lookupGeldigiYerTur: TcxDBLookupComboBox;
    lookupGelisSekli: TcxDBLookupComboBox;
    lookupGizlilikDerecesi: TcxDBLookupComboBox;
    lookupHavaleEdilecekBirim: TcxDBLookupComboBox;
    lookupYaziDurumu: TcxDBLookupComboBox;
    memoEvrakIcerik: TcxDBMemo;
    actEkDosyalar: TAction;
    buttonDosyaEkleri: TSpeedButton;
    PanelEkDosyalar: TPanel;
    ViewImaj: TcxGridDBTableView;
    ImajLevel1: TcxGridLevel;
    GridImaj: TcxGrid;
    qryOzelAlan: TFDQuery;
    dsOzelAlan: TDataSource;
    ViewOzelAlanDOSYA_NO: TcxGridDBColumn;
    ViewOzelAlanAlanADI: TcxGridDBColumn;
    ViewOzelAlanOZEL_ALAN_REF: TcxGridDBColumn;
    ViewOzelAlanDEGER: TcxGridDBColumn;
    FileOpenDialog1: TFileOpenDialog;
    ViewImajID: TcxGridDBColumn;
    ViewImajYER_ID: TcxGridDBColumn;
    ViewImajDURUM: TcxGridDBColumn;
    ViewImajBELGENO: TcxGridDBColumn;
    ViewImajSURUM: TcxGridDBColumn;
    ViewImajBELGEADI: TcxGridDBColumn;
    ViewImajBELGE: TcxGridDBColumn;
    ViewImajBELGETURU: TcxGridDBColumn;
    ViewImajBOYUT: TcxGridDBColumn;
    editGeldigiYer: TcxDBTextEdit;
    procedure actEkDosyalarExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actKaydetExecute(Sender: TObject);
    procedure actDosyaEkleExecute(Sender: TObject);
    procedure actBarkodExecute(Sender: TObject);
    procedure actKapatExecute(Sender: TObject);
    procedure actEkDosyalarUpdate(Sender: TObject);
    procedure qryOzelAlanBeforePost(DataSet: TDataSet);
    procedure qryEvrakTabloAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    qryLookupYerTur,
    qryLookupYer,
    qryLookupHavaleBirim,
    qryLookupGelisSekli,
    qryLookupYaziDurumu,
    qryLookupGizlilik,
    qryLookupEvrakCinsi : TFDQuery;

    dsLookupYerTur,
    dsLookupYer,
    dsLookupHavaleBirim,
    dsLookupGelisSekli,
    dsLookupYaziDurumu,
    dsLookupGizlilik,
    dsLookupEvrakCinsi : TDataSource;

    procedure FillCxLookup( _data: TFDQuery; _dataSource: TdataSource; _lookupCombo: TcxDBLookupComboBox;
                            _KeyFieldNames, _ListFieldNames : string; _LookupSQL : string);
    procedure FillLookupControls;
  public
    { Public declarations }
    EvrakID : integer;
    function LocateTo( _ID : integer) : boolean;
  end;

var
  frmGelenEvrakKayit: TfrmGelenEvrakKayit;

function GelenEvrakFormEkleGoster( aOwner : TComponent; _EvrakID, KlasorID : integer; _ReadOnly : boolean) : integer;

implementation

{$R *.dfm}
uses
   uBelgeSecimDialog,
   FetaKurulusSiniflari,
   UTablo, PrjConst;


function GelenEvrakFormEkleGoster( aOwner : TComponent; _EvrakID, KlasorID : integer; _ReadOnly : boolean) : integer;
var
  frmGelenEvrak : TfrmGelenEvrakKayit;
begin
   try
     frmGelenEvrak := TfrmGelenEvrakKayit.Create(aOwner);
     frmGelenEvrak.EvrakID := _EvrakID;
     if _ReadOnly then
       begin

       end;
     if frmGelenEvrak.LocateTo(_EvrakID) then
     //frmGelenEvrak.actEkDosyalarExecute(frmGelenEvrak.actEkDosyalar);
       begin
         Result := frmGelenEvrak.ShowModal;
       end;
   finally
      frmGelenEvrak.Free;
   end;
end;


procedure TfrmGelenEvrakKayit.actBarkodExecute(Sender: TObject);
begin
//
end;

procedure TfrmGelenEvrakKayit.actDosyaEkleExecute(Sender: TObject);
begin
    case GetBelgeEkleTuru_Dialog of
      1001 : // Dosyadan se�im
         begin
            if FileOpenDialog1.Execute then
              begin
                 Tablo.TablodanSorguAc(5,' SELECT BELGEADI FROM IMAJ WHERE YER_ID='+qryEvrakTablo.FieldByName('ID').AsString
                                        +' AND BELGEADI='+QuotedStr(FileOpenDialog1.FileName), FALSE);
                 if (Tablo.Query5.Fields[0].AsString<>'') and (Tablo.Query5.Fields[0].AsString=FileOpenDialog1.FileName) then
                   if Application.MessageBox(PWideChar('"'+FileOpenDialog1.FileName+'" belgesi var g�r�n�yor. Yine de Eklemek ister misiniz ?'),
                     PWideChar(Dikkat), MB_YESNO) = IDNO then
                      Exit;

                 Tablo.BelgeEkleme(FileOpenDialog1.FileName, -99, 1, qryEvrakTablo.FieldByName('ID').AsInteger, {qryImaj} nil);
                 qryImaj.Params[0].Value := qryEvrakTablo.FieldByName('ID').AsInteger;
                 qryImaj.Close;
                 qryImaj.Open;
              end;
         end;
      1002 : // Taray�c�dan Ekle
         begin
           //
         end;
    end;
end;

procedure TfrmGelenEvrakKayit.actEkDosyalarExecute(Sender: TObject);
var
  comp : TComponent;
begin
  if TAction(Sender).Checked then
    begin
      comp := TAction(Sender).GetParentComponent;
      TAction(Sender).ImageIndex := 59;
      TSpeedButton(TAction(Sender).ActionComponent).ImageIndex := TAction(Sender).ImageIndex;
      TAction(Sender).Caption := 'Dosya Ekleri G�ster';
      PanelEkDosyalar.Visible := False;
      Width := 614;
    end
    else
    begin
      TAction(Sender).ImageIndex := 58;
      TSpeedButton(TAction(Sender).ActionComponent).ImageIndex := TAction(Sender).ImageIndex;
      TAction(Sender).Caption := 'Dosya Eklerini Gizle';
      PanelEkDosyalar.Visible := True;
      Width := 868;
    end;

end;

procedure TfrmGelenEvrakKayit.actEkDosyalarUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (qryEvrakTablo.State = dsInsert) or (qryEvrakTablo.RecordCount>0);
end;

procedure TfrmGelenEvrakKayit.actKapatExecute(Sender: TObject);
var
  DosyaID : integer;
begin
  if qryImaj.RecordCount<1 then
    begin
      if Application.MessageBox(PWideChar('Evrak Kayd�na ait her hangi bir Belge eklenmemi�. Evrak kayd� silinsin mi?'), PWideChar(SGenotipOnay), MB_YESNO + MB_ICONQUESTION) = IDYES then
       begin
          // DOKUMAN dosyas�ndan mevcut Kayd�n silinmesi sa�lanacak
          DosyaID := qryEvrakTablo.FieldByName('ID').AsInteger;
          qryEvrakTablo.Close;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DOKUMAN where ID='+DosyaID.ToString,[],[]);
          ModalResult := mrCancel;
          Close;
       end
         else
      Application.MessageBox(PWideChar('Kapatma eylemi iptal edildi. Belge eklenmesini sa�lay�n.'), PWideChar(SGenotipOnay), MB_OK + MB_ICONINFORMATION);
    end
    else
  Close;
end;

procedure TfrmGelenEvrakKayit.actKaydetExecute(Sender: TObject);
begin
  qryEvrakTablo.Post;
end;

procedure TfrmGelenEvrakKayit.FillCxLookup(_data: TFDQuery; _dataSource: TdataSource;
  _lookupCombo: TcxDBLookupComboBox; _KeyFieldNames, _ListFieldNames, _LookupSQL: string);
begin
  if Not Assigned(_data) then
    _data := TFDQuery.Create(Self);
  if Not Assigned(_dataSource) then
    _dataSource := TDataSource.Create(Self);
  _data.Connection := Tablo.FDCnn;
  _data.SQL.Text := _LookupSQL;
  _data.Open;
  _dataSource.DataSet := _data;
  //_lookupCombo.Properties := TcxLookupComboBoxProperties.Create(Self);
  _lookupCombo.Properties.ListSource := _dataSource;
  _lookupCombo.Properties.KeyFieldNames := _KeyFieldNames;
  _lookupCombo.Properties.ListFieldNames := _ListFieldNames;
  _lookupCombo.Properties.ListOptions.ShowHeader := False;
end;


procedure TfrmGelenEvrakKayit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if qryEvrakTablo.State in [dsEdit, dsInsert] then
    begin
      CanClose :=  Application.MessageBox(PChar(sDegisiklikVar), PChar(SGenotipOnay), MB_YESNO) = IDYES;
      if CanClose then
        qryEvrakTablo.Cancel;
    end;
end;

procedure TfrmGelenEvrakKayit.FillLookupControls;

    function Lookupfrom_GENINI (_Bolum : integer) : string;
    begin
      Result := 'SELECT DEGER, ANAHTAR FROM GENINI WHERE BOLUM='+_Bolum.ToString+' ORDER BY ANAHTAR';
    end;

begin
  { DONE -oM�cahit -cGiden/Gelen Evrak : Combolar GENINI den doldurulacak }
//  FillCxLookup(qryLookupYerTur,dsLookupYerTur, lookupGeldigiYerTur,'ID', 'TUR', 'SELECT * FROM EVRAK_GELEN_YER_TUR');
//  FillCxLookup(qryLookupYer,dsLookupYer, lookupGeldigiYer,'ID', 'YER_BIRIM_KODU', 'SELECT * FROM EVRAK_GELEN_YER');
//  FillCxLookup(qryLookupHavaleBirim,dsLookupHavaleBirim, lookupHavaleEdilecekBirim,'ID', 'BIRIM_ADI', 'SELECT * FROM EVRAK_BIRIMI');
//  FillCxLookup(qryLookupGelisSekli,dsLookupGelisSekli, lookupGelisSekli,'ID', 'ADI', 'SELECT * FROM EVRAK_GELIS_SEKLI');
//  FillCxLookup(qryLookupYaziDurumu,dsLookupYaziDurumu, lookupYaziDurumu,'ID', 'ADI', 'SELECT * FROM EVRAK_YAZI_DURUMU');
//  FillCxLookup(qryLookupGizlilik,dsLookupGizlilik, lookupGizlilikDerecesi,'ID', 'ADI', 'SELECT * FROM EVRAK_GIZLILIK');
//  FillCxLookup(qrylookupEvrakCinsi,dslookupEvrakCinsi, lookupEvrakCinsi,'ID', 'ADI', 'SELECT * FROM EVRAK_CINSI');

  FillCxLookup(qryLookupYerTur,dsLookupYerTur, lookupGeldigiYerTur,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakGelenYerTur{-4004}));
  //FillCxLookup(qryLookupYer,dsLookupYer, lookupGeldigiYer,'DEGER', 'ANAHTAR', 'SELECT * FROM EVRAK_GELEN_YER');
  FillCxLookup(qryLookupHavaleBirim,dsLookupHavaleBirim, lookupHavaleEdilecekBirim,'ID', 'FIRMA', 'SELECT * FROM REHBER where GRUP = 335 AND DURUM=1 ORDER BY FIRMA');
  FillCxLookup(qryLookupGelisSekli,dsLookupGelisSekli, lookupGelisSekli,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakGelisSekli {-4006}));
  FillCxLookup(qryLookupYaziDurumu,dsLookupYaziDurumu, lookupYaziDurumu,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakYaziDurumu {-4003}));
  FillCxLookup(qryLookupGizlilik,dsLookupGizlilik, lookupGizlilikDerecesi,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakGizlilik {-3206}));
  FillCxLookup(qrylookupEvrakCinsi,dslookupEvrakCinsi, lookupEvrakCinsi,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakCinsi {-4002}));

end;

procedure TfrmGelenEvrakKayit.FormCreate(Sender: TObject);
begin
  PanelEkDosyalar.Visible := False;
  Width := 614;
  FillLookupControls;
  qryEvrakTablo.Open;
end;

procedure TfrmGelenEvrakKayit.FormDestroy(Sender: TObject);
begin
    qryLookupYerTur.Free;
    qryLookupYer.Free;
    qryLookupHavaleBirim.Free;
    qryLookupGelisSekli.Free;
    qryLookupYaziDurumu.Free;
    qryLookupGizlilik.Free;
    qryLookupEvrakCinsi.Free;

    dsLookupYerTur.Free;
    dsLookupYer.Free;
    dsLookupHavaleBirim.Free;
    dsLookupGelisSekli.Free;
    dsLookupYaziDurumu.Free;
    dsLookupGizlilik.Free;
    dsLookupEvrakCinsi.Free;
end;

function TfrmGelenEvrakKayit.LocateTo(_ID: integer) : boolean;
begin
   Result := qryEvrakTablo.Locate('ID', _ID, []);
   if not Result then
     raise Exception.Create('�lgili ['+_ID.ToString+'] Kay�t bulunamad�!');
end;

procedure TfrmGelenEvrakKayit.qryEvrakTabloAfterScroll(DataSet: TDataSet);
begin
  qryImaj.Params[0].Value := qryEvrakTablo.FieldByName('ID').AsInteger;
  qryImaj.Close;
  qryImaj.Open;
end;

procedure TfrmGelenEvrakKayit.qryOzelAlanBeforePost(DataSet: TDataSet);
begin
   raise Exception.Create('Kurgu Hen�z tamamlanmad�!');
   //qryOzelAlan.FieldByName('DOSYA_NO').AsString := qryEvrakTablo.FieldByName('GELEN_EVRAK_NUMARASI').AsString;
end;

end.





