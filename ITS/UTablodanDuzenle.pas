unit UTablodanDuzenle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,UGirisKutusuEx,
  Dialogs, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, StdCtrls, Buttons,FetaKurulusSiniflari,
  DBCtrls, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls,PrjConst,
  ComCtrls, ToolWin, dxSkinLondonLiquidSky, OpenSQLServer, cxTextEdit;

type
  TTablodanDuzenleDlg = class(TForm)
    Panel2: TPanel;
    DBGrid1: TcxGrid;
    DBGrid1DBTableView1: TcxGridDBTableView;
    DBGrid1Level1: TcxGridLevel;
    DataSource1: TDataSource;
    Query1: TADOQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    GorTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SecTus: TToolButton;
    DBGrid1DBTableView1Column1: TcxGridDBColumn;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    procedure SilTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure DBGrid1DBTableView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TabloyuGrideYerlestir;
    procedure Query1AfterOpen(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DataSource1StateChange(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
  private
    { Private declarations }
  public
     SQLText,IslemTuru,FormCaption:string;  //Görev Þablonlarý için IslemTuru='GorevSablon'
    { Public declarations }
  end;

var
  TablodanDuzenleDlg: TTablodanDuzenleDlg;

implementation

Uses
  Utablo;

{$R *.dfm}

procedure TTablodanDuzenleDlg.DataSource1StateChange(Sender: TObject);
begin
  KaydetTus.Visible := (DataSource1.State in [dsEdit,dsInsert]);
  IptalTus.Visible := (DataSource1.State in [dsEdit,dsInsert]);
  YeniTus.Visible := not (DataSource1.State in [dsEdit,dsInsert]);
  SilTus.Visible := not (DataSource1.State in [dsEdit,dsInsert]);
  GorTus.Visible := not (DataSource1.State in [dsEdit,dsInsert]);
  SecTus.Visible := not (DataSource1.State in [dsEdit,dsInsert]);
end;

procedure TTablodanDuzenleDlg.DBGrid1DBTableView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  SecTusClick(Self);
end;

procedure TTablodanDuzenleDlg.FormShow(Sender: TObject);
begin
  Query1.Close;
  Query1.SQL.Text:=SQLText;
  Query1.Open;
  TabloyuGrideYerlestir;
  if IslemTuru='Baglantilar' then begin //column propertylerini burada yerleþtirelim..
    DBGrid1DBTableView1.GetColumnByFieldName('TUR').RepositoryItem:=Tablo.RepDBBaglantiTurleri;  //alan içinde %0% varsa ent. %1% varsa stokda kullanýlýr..

  end;
end;

procedure TTablodanDuzenleDlg.TabloyuGrideYerlestir;
var
  i:Integer;
Begin
  if DBGrid1DBTableView1.ColumnCount > 0 then begin
     for i := 0 to (DBGrid1DBTableView1.ColumnCount)-1 do
         DBGrid1DBTableView1.Columns[0].Free;
  end;
  for i := 0 to Query1.FieldCount-1 do begin
    DBGrid1DBTableView1.CreateColumn;
    with DBGrid1DBTableView1.Columns[i] do begin
      DataBinding.FieldName := Query1.Fields[i].FieldName;
      Caption := Query1.Fields[i].FieldName;
      if DataBinding.FieldName = 'SIFRE' then begin
       PropertiesClass := TcxTextEditProperties;
       Properties := Tablo.cxEditRepository1TextPasswordItem.Properties;
      end;
    end;
  end;
 DBGrid1DBTableView1.ApplyBestFit(nil);
End;

procedure TTablodanDuzenleDlg.KaydetTusClick(Sender: TObject);
begin
 Query1.Post;
end;

procedure TTablodanDuzenleDlg.IptalTusClick(Sender: TObject);
begin
 Query1.Cancel;
end;

procedure TTablodanDuzenleDlg.GorTusClick(Sender: TObject);
begin
 if IslemTuru='Baglantilar' then begin
    if OpenSQLServerForm <> nil then
       FreeAndNil(OpenSQLServerForm);
    Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
    OpenSQLServerForm.btnOk.Caption := 'Deðiþtir';
    OpenSQLServerForm.btnOk.OnClick := OpenSQLServerForm.btnEkleClick;
    OpenSQLServerForm.EditRemoteServer.Visible := True;
    OpenSQLServerForm.LabelRemoteServer.Visible := True;
    OpenSQLServerForm.TestRemoteCon.Visible := True;
    OpenSQLServerForm.ledUserName.Text := Query1.FieldByName('KULLANICIADI').AsString;
    OpenSQLServerForm.ledPassword.Text := Query1.FieldByName('SIFRE').AsString;
    OpenSQLServerForm.cboDatabases.Text := Query1.FieldByName('VERITABANI').AsString;
    OpenSQLServerForm.cboServers.Text := Query1.FieldByName('SERVERADRESI_YAKIN').AsString;
    OpenSQLServerForm.EditRemoteServer.Text := Query1.FieldByName('SERVERADRESI_UZAK').AsString;
    OpenSQLServerForm.ShowModal;
    if OpenSQLServerForm.ModalResult = mrOK then begin
      Query1.Edit;
      Query1.FieldByName('KULLANICIADI').AsString := OpenSQLServerForm.ledUserName.Text;
      Query1.FieldByName('SIFRE').AsString := OpenSQLServerForm.ledPassword.Text;
      Query1.FieldByName('VERITABANI').AsString := OpenSQLServerForm.cboDatabases.Text;
      Query1.FieldByName('SERVERADRESI_YAKIN').AsString := OpenSQLServerForm.cboServers.Text;
      Query1.FieldByName('SERVERADRESI_UZAK').AsString := OpenSQLServerForm.EditRemoteServer.Text;
      Query1.Post;
    end;
    FreeAndNil(OpenSQLServerForm);
  end else
     raise Exception.Create('IslemTuru belirtilmemiþ');

end;

procedure TTablodanDuzenleDlg.Query1AfterOpen(DataSet: TDataSet);
begin
   Siltus.Visible := Query1.RecordCount>0;
   GorTus.Visible := Siltus.Visible;
end;

procedure TTablodanDuzenleDlg.SecTusClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TTablodanDuzenleDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    Query1.Delete;
end;

procedure TTablodanDuzenleDlg.YeniTusClick(Sender: TObject);
var
  eskiad : Variant;
  ctrls : TGirdiDenetimleri;
begin
  if IslemTuru='Baglantilar' then begin
    ctrls := TGirdiDenetimleri.Create.Edit(('Yeni Firma Adý.'),@eskiad);
    if TGirisKutusuEx.BilgiAlEx('Firma Adý Giriniz.',ctrls) = mrOK then begin
      if OpenSQLServerForm <> nil then
         FreeAndNil(OpenSQLServerForm);
      Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
      OpenSQLServerForm.EditRemoteServer.Visible := True;
      OpenSQLServerForm.LabelRemoteServer.Visible := True;
      OpenSQLServerForm.btnOk.Caption := 'Ekle';
      OpenSQLServerForm.btnOk.OnClick := OpenSQLServerForm.btnEkleClick;
      OpenSQLServerForm.ShowModal;
      if OpenSQLServerForm.ModalResult = mrOK then
         Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'INSERT INTO BAGLANTILAR(TUR,SUBEADI,KULLANICIADI,SIFRE,VERITABANI,DURUM,SERVERADRESI_UZAK,SERVERADRESI_YAKIN)VALUES(&TUR,&SUBEADI,&KULLANICIADI,&SIFRE,&VERITABANI,&DURUM,&SERVERADRESI_UZAK,&SERVERADRESI_YAKIN)',
         ['&TUR','&SUBEADI','&KULLANICIADI','&SIFRE','&VERITABANI','&DURUM','&SERVERADRESI_UZAK','&SERVERADRESI_YAKIN'],
         [1,eskiad,OpenSQLServerForm.ledUserName.Text,OpenSQLServerForm.ledPassword.Text,OpenSQLServerForm.cboDatabases.Text,1,OpenSQLServerForm.EditRemoteServer.Text,OpenSQLServerForm.cboServers.Text]);
      FreeAndNil(OpenSQLServerForm);
    end;
    FormShow(Self);
  end else
    Query1.Append;
end;

end.
