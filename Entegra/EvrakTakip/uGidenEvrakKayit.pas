unit uGidenEvrakKayit;

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
  TfrmGidenEvrakKayit = class(TForm)
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
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    editEvrakNo: TcxDBTextEdit;
    editEvrakTarihi: TcxDBDateEdit;
    PanelInput: TPanel;
    memoAciklama: TcxDBMemo;
    GridDagitim: TcxGrid;
    ViewDagitim: TcxGridDBTableView;
    DagitimLevel1: TcxGridLevel;
    cxLabel1: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    cxLabel15: TcxLabel;
    cxLabel17: TcxLabel;
    cxLabel18: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    editEsasNo: TcxDBTextEdit;
    editKonusu: TcxDBTextEdit;
    evrakDosyaNumarasi: TcxDBTextEdit;
    lookupYaziSekli: TcxDBLookupComboBox;
    lookupGizlilikDerecesi: TcxDBLookupComboBox;
    lookupYaziDurumu: TcxDBLookupComboBox;
    actEkDosyalar: TAction;
    buttonDosyaEkleri: TSpeedButton;
    PanelEkDosyalar: TPanel;
    ViewImaj: TcxGridDBTableView;
    ImajLevel1: TcxGridLevel;
    GridImaj: TcxGrid;
    qryilgili: TFDQuery;
    dsilgili: TDataSource;
    ViewDagitimDOSYA_NO: TcxGridDBColumn;
    ViewDagitimAlanADI: TcxGridDBColumn;
    ViewDagitimOZEL_ALAN_REF: TcxGridDBColumn;
    ViewDagitimDEGER: TcxGridDBColumn;
    FileOpenDialog1: TFileOpenDialog;
    lookupImzaYolu: TcxDBLookupComboBox;
    editDosyaKodu: TcxDBButtonEdit;
    Grdilgi: TcxGrid;
    Viewilgi: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxLabel2: TcxLabel;
    editEkListe: TcxDBMemo;
    dsDagitim: TDataSource;
    qryDagitim: TFDQuery;
    cxLabel4: TcxLabel;
    actTarama: TAction;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ViewImajID: TcxGridDBColumn;
    ViewImajYER_ID: TcxGridDBColumn;
    ViewImajDURUM: TcxGridDBColumn;
    ViewImajBELGENO: TcxGridDBColumn;
    ViewImajBELGEADI: TcxGridDBColumn;
    ViewImajBELGE: TcxGridDBColumn;
    ViewImajBELGETURU: TcxGridDBColumn;
    ViewImajBOYUT: TcxGridDBColumn;
    lookupGidecekYer: TcxDBLookupComboBox;
    procedure actEkDosyalarExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actKaydetExecute(Sender: TObject);
    procedure actDosyaEkleExecute(Sender: TObject);
    procedure actBarkodExecute(Sender: TObject);
    procedure actKapatExecute(Sender: TObject);
    procedure actEkDosyalarUpdate(Sender: TObject);
    procedure qryilgiliBeforePost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure qryEvrakTabloAfterScroll(DataSet: TDataSet);
    procedure actDuzenleGorExecute(Sender: TObject);
  private
    { Private declarations }
    qrylookupYaziSekli,
    qryLookupYaziDurumu,
    qryLookupGidecegiYer,
    qryLookupGizlilik     : TFDQuery;

    dslookupYaziSekli,
    dsLookupYaziDurumu,
    dsLookupGidecegiYer,
    dsLookupGizlilik      : TDataSource;

    procedure FillCxLookup( var _data: TFDQuery; var _dataSource: TdataSource; _lookupCombo: TcxDBLookupComboBox;
                            _KeyFieldNames, _ListFieldNames : string; _LookupSQL : string);
    procedure FillLookupControls;
  public
    { Public declarations }
    EvrakID : integer;
    function LocateTo( _ID : integer) : boolean;
  end;

var
  frmGidenEvrakKayit: TfrmGidenEvrakKayit;

function GidenEvrakFormEkleGoster( aOwner : TComponent; _EvrakID, KlasorID : integer; _yeniKayit : boolean) : integer;

implementation

{$R *.dfm}
uses
   uBelgeSecimDialog,
   FetaKurulusSiniflari,
   UTablo, PrjConst;


function GidenEvrakFormEkleGoster( aOwner : TComponent; _EvrakID, KlasorID : integer; _yeniKayit : boolean) : integer;
var
  frmGidenEvrak : TfrmGidenEvrakKayit;
begin
   try
     frmGidenEvrak := TfrmGidenEvrakKayit.Create(aOwner);
     frmGidenEvrak.EvrakID := _EvrakID;
     if _yeniKayit then
       begin

       end;
     if frmGidenEvrak.LocateTo(_EvrakID) then
     //frmGidenEvrak.actEkDosyalarExecute(frmGidenEvrak.actEkDosyalar);
       begin
         Result := frmGidenEvrak.ShowModal;
       end;
   finally
      frmGidenEvrak.Free;
   end;
end;


procedure TfrmGidenEvrakKayit.actBarkodExecute(Sender: TObject);
begin
//
end;

procedure TfrmGidenEvrakKayit.actDosyaEkleExecute(Sender: TObject);
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

procedure TfrmGidenEvrakKayit.actDuzenleGorExecute(Sender: TObject);
begin
  //
end;

procedure TfrmGidenEvrakKayit.actEkDosyalarExecute(Sender: TObject);
var
  comp : TComponent;
begin
  if TAction(Sender).Checked then
    begin
      comp := TAction(Sender).GetParentComponent;
      TAction(Sender).ImageIndex := 59;
      TSpeedButton(TAction(Sender).ActionComponent).ImageIndex := TAction(Sender).ImageIndex;
      //TAction(Sender).Caption := 'Dosya Ekleri G�ster';
      PanelEkDosyalar.Visible := False;
      Width := 614;
    end
    else
    begin
      TAction(Sender).ImageIndex := 58;
      TSpeedButton(TAction(Sender).ActionComponent).ImageIndex := TAction(Sender).ImageIndex;
      //TAction(Sender).Caption := 'Dosya Eklerini Gizle';
      PanelEkDosyalar.Visible := True;
      Width := 868;
    end;

end;

procedure TfrmGidenEvrakKayit.actEkDosyalarUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (qryEvrakTablo.State = dsInsert) or (qryEvrakTablo.RecordCount>0);
end;

procedure TfrmGidenEvrakKayit.actKapatExecute(Sender: TObject);
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

procedure TfrmGidenEvrakKayit.actKaydetExecute(Sender: TObject);
begin
  qryEvrakTablo.Post;
end;

procedure TfrmGidenEvrakKayit.FillCxLookup(var _data: TFDQuery; var _dataSource: TdataSource;
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


procedure TfrmGidenEvrakKayit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if qryEvrakTablo.State in [dsEdit, dsInsert] then
    begin
      CanClose :=  Application.MessageBox(PChar(sDegisiklikVar), PChar(SGenotipOnay), MB_YESNO) = IDYES;
      if CanClose then
        qryEvrakTablo.Cancel;
    end;
end;

procedure TfrmGidenEvrakKayit.FillLookupControls;

    function Lookupfrom_GENINI (_Bolum : integer) : string;
    begin
      Result := 'SELECT DEGER, ANAHTAR FROM GENINI WHERE BOLUM='+_Bolum.ToString+' ORDER BY ANAHTAR';
    end;
begin
  { DONE -oM�cahit -cGiden/Gelen Evrak : Combolar GENINI den doldurulacak }
  FillCxLookup(qryLookupGidecegiYer,dsLookupGidecegiYer, lookupGidecekYer,'ID', 'FIRMA', 'SELECT * FROM REHBER where GRUP = 335 AND DURUM=1 ORDER BY FIRMA');
  //FillCxLookup(qrylookupYaziSekli,dslookupYaziSekli, lookupYaziSekli,'ID', 'ADI', 'SELECT * FROM EVRAK_CINSI');
  //FillCxLookup(qryLookupYaziDurumu,dsLookupYaziDurumu, lookupYaziDurumu,'ID', 'ADI', 'SELECT * FROM EVRAK_YAZI_DURUMU');
  //FillCxLookup(qryLookupGizlilik,dsLookupGizlilik, lookupGizlilikDerecesi,'ID', 'ADI', 'SELECT * FROM EVRAK_GIZLILIK');

  FillCxLookup(qrylookupYaziSekli,dslookupYaziSekli, lookupYaziSekli,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakCinsi {-4002}));
  FillCxLookup(qryLookupYaziDurumu,dsLookupYaziDurumu, lookupYaziDurumu,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakYaziDurumu {-4003}));
  FillCxLookup(qryLookupGizlilik,dsLookupGizlilik, lookupGizlilikDerecesi,'DEGER', 'ANAHTAR', Lookupfrom_GENINI( constEvrakGizlilik {-3206}));


end;

procedure TfrmGidenEvrakKayit.FormCreate(Sender: TObject);
begin
  PanelEkDosyalar.Visible := False;
  Width := 614;
  FillLookupControls;
  qryEvrakTablo.Open;
end;

procedure TfrmGidenEvrakKayit.FormDestroy(Sender: TObject);
begin
    qryLookupGidecegiYer.Free;
    qrylookupYaziSekli.Free;
    qryLookupYaziDurumu.Free;
    qryLookupGizlilik.Free;
    dsLookupGidecegiYer.Free;
    dsLookupYaziSekli.Free;
    dsLookupYaziDurumu.Free;
    dsLookupGizlilik.Free;
end;

procedure TfrmGidenEvrakKayit.FormShow(Sender: TObject);
begin
   ActiveControl := editEvrakNo;
end;

function TfrmGidenEvrakKayit.LocateTo(_ID: integer) : boolean;
begin
   Result := qryEvrakTablo.Locate('ID', _ID, []);
   if not Result then
     raise Exception.Create('�lgili ['+_ID.ToString+'] Kay�t bulunamad�!');
end;

procedure TfrmGidenEvrakKayit.qryEvrakTabloAfterScroll(DataSet: TDataSet);
begin
  qryImaj.Params[0].Value := qryEvrakTablo.FieldByName('ID').AsInteger;
  qryImaj.Close;
  qryImaj.Open;
end;

procedure TfrmGidenEvrakKayit.qryilgiliBeforePost(DataSet: TDataSet);
begin
   raise Exception.Create('Kurgu Hen�z tamamlanmad�!');
   //qryOzelAlan.FieldByName('DOSYA_NO').AsString := qryEvrakTablo.FieldByName('GELEN_EVRAK_NUMARASI').AsString;
end;

end.





