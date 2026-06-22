unit UTablodanDuzenle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,UGirisKutusuEx,
  Dialogs, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client, StdCtrls, Buttons,FetaKurulusSiniflari,
  DBCtrls, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls,
  ComCtrls, ToolWin, dxSkinLondonLiquidSky, OpenSQLServer, cxTextEdit,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TTablodanDuzenleDlg = class(TForm)
    Panel2: TPanel;
    DBGrid1: TcxGrid;
    DBGrid1DBTableView1: TcxGridDBTableView;
    DBGrid1Level1: TcxGridLevel;
    DataSource1: TDataSource;
    Query1: TFDQuery;
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
    procedure FormCreate(Sender: TObject);
    procedure Query1NewRecord(DataSet: TDataSet);
    procedure DBGrid1DBTableView1CanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }

  public
     GriddenDuzenle : Boolean;
     SQLText,IslemTuru,FormCaption:string;  //Görev Şablonları için IslemTuru='GorevSablon'
    { Public declarations }
  end;

var
  TablodanDuzenleDlg: TTablodanDuzenleDlg;

implementation

Uses
  Utablo, LocOnFly,PrjConst, UAnaForm;

{$R *.dfm}

procedure TTablodanDuzenleDlg.DataSource1StateChange(Sender: TObject);
begin
  KaydetTus.Visible := (GriddenDuzenle) and (DataSource1.State in [dsEdit,dsInsert]);
  IptalTus.Visible := (GriddenDuzenle) and (DataSource1.State in [dsEdit,dsInsert]);
  YeniTus.Visible := (GriddenDuzenle) and (not (DataSource1.State in [dsEdit,dsInsert]));
  SilTus.Visible := (GriddenDuzenle) and (not (DataSource1.State in [dsEdit,dsInsert]));

  GorTus.Visible := (GriddenDuzenle) and (not (DataSource1.State in [dsEdit,dsInsert]));
  SecTus.Visible := not (DataSource1.State in [dsEdit,dsInsert]);
end;

procedure TTablodanDuzenleDlg.DBGrid1DBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=DBGrid1;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=DBGrid1DBTableView1;
 // AnaForm.pmGridStil.Tags.Values[GridSorgu.Name]:='ÜTSSorguGridi';

end;

procedure TTablodanDuzenleDlg.DBGrid1DBTableView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  SecTusClick(Self);
end;

procedure TTablodanDuzenleDlg.FormCreate(Sender: TObject);
begin
 Tablo.GridTurkcelestir;
 if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
end;

procedure TTablodanDuzenleDlg.FormShow(Sender: TObject);
begin
  Query1.Close;
  Query1.SQL.Text:=SQLText;
  Query1.Open;
  TabloyuGrideYerlestir;
  if IslemTuru='Baglantilar' then begin //column propertylerini burada yerleştirelim..
    DBGrid1DBTableView1.GetColumnByFieldName('TUR').RepositoryItem:=Tablo.RepDBBaglantiTurleri;  //alan içinde %0% varsa ent. %1% varsa stokda kullanılır..
  end;
  if IslemTuru='ServisBaglanti' then begin //column propertylerini burada yerleştirelim..
    DBGrid1DBTableView1.GetColumnByFieldName('ID').Visible := False;
    DBGrid1DBTableView1.GetColumnByFieldName('KAYNAKDURUM').RepositoryItem:=Tablo.RepServisDurum;
    DBGrid1DBTableView1.GetColumnByFieldName('HEDEFDURUM').RepositoryItem:=Tablo.RepServisDurum;
    DBGrid1DBTableView1.GetColumnByFieldName('UYARITURU').RepositoryItem:=Tablo.repUyariTurleri;
    DBGrid1DBTableView1.GetColumnByFieldName('ACILIS').RepositoryItem:=Tablo.cxEditRepository1CheckBoxItem1;
    DBGrid1DBTableView1.GetColumnByFieldName('KAPANIS').RepositoryItem:=Tablo.cxEditRepository1CheckBoxItem1;
    DBGrid1DBTableView1.GetColumnByFieldName('YERI').Visible := False;
    DBGrid1DBTableView1.GetColumnByFieldName('BOLUM').Visible := False;
    DBGrid1DBTableView1.GetColumnByFieldName('EKLEYEN').Visible := False;
  end;
  if (IslemTuru='şubeler')or(IslemTuru='Şubeler')or(IslemTuru='tubeler') then begin
    DBGrid1DBTableView1.OptionsData.Appending := False;
    DBGrid1DBTableView1.OptionsData.Inserting := False;
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
   if IslemTuru='REHBER_KOTA' then begin
    DBGrid1DBTableView1.GetColumnByFieldName('REHBERID').Visible := False;
    DBGrid1DBTableView1.GetColumnByFieldName('ID').Visible := False;
    DBGrid1DBTableView1.GetColumnByFieldName('KUR').RepositoryItem := Tablo.cxEditRepository1ComboBoxItemKurlar;
  end;
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
  if IslemTuru='şubeler' then begin
    Tablo.RehberSihirbazBaslat(0, Query1.Fields[0].asinteger,-100, -100,  False);
    Query1.Close;
    Query1.Open;
  end else if IslemTuru='Baglantilar' then begin
    if OpenSQLServerForm <> nil then
       FreeAndNil(OpenSQLServerForm);
    Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
    OpenSQLServerForm.btnOk.Caption := 'Değiştir';
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
     raise Exception.Create(Islemturubelirtilmemis);

end;

procedure TTablodanDuzenleDlg.Query1AfterOpen(DataSet: TDataSet);
begin
   Siltus.Visible := (GriddenDuzenle)and(Query1.RecordCount>0);
   GorTus.Visible := (GriddenDuzenle)and(Siltus.Visible);

end;

procedure TTablodanDuzenleDlg.Query1NewRecord(DataSet: TDataSet);
begin
  if IslemTuru='ServisBaglanti' then begin //column propertylerini burada yerleştirelim..
    Query1.FieldByName('YERI').AsInteger := Tabno_Servis;
    Query1.FieldByName('BOLUM').AsInteger := Ops_Servis_Durum;
    Query1.FieldByName('EKLEYEN').AsString := Kullanan;
    Query1.FieldByName('KAYNAKDURUM').AsInteger := 0;

  end else if IslemTuru='REHBER_KOTA' then begin
    Query1.FieldByName('REHBERID').AsInteger := Tablo.TabMusteri.Tag;
    Query1.FieldByName('KUR').AsString := CariDoviz;
  end;
end;

procedure TTablodanDuzenleDlg.SecTusClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TTablodanDuzenleDlg.SilTusClick(Sender: TObject);
begin
  if (IslemTuru='şubeler')and(Query1.Fields[0].AsInteger=-1) then
     Showmessage('Ana firma silinemez!')
  else
     if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
        Query1.Delete;
end;

procedure TTablodanDuzenleDlg.YeniTusClick(Sender: TObject);
var
  eskiad : Variant;
  ctrls : TGirdiDenetimleri;
  YeniID : Integer;
  YeniKod : string;
begin
  if (IslemTuru='şubeler')or(IslemTuru='Şubeler')or(IslemTuru='tubeler') then begin
    ctrls := TGirdiDenetimleri.Create.Edit((BGYeni_sube),@eskiad);
    if TGirisKutusuEx.BilgiAlEx(BGSube_Ad,ctrls) = mrOK then begin
       Tablo.TablodanSorguAc(2, 'select min(ID) from REHBER ');
       YeniID := -1*(abs(Tablo.Query2.Fields[0].AsInteger)+1);
       repeat
         YeniKod := Format('%.4d', [Abs(YeniID)]);
         if not Veritabani.VeriVarMi(Tablo.FDCnn,'select ID from REHBER where KOD=&KOD',['&KOD'],[YeniKod]) then
           Break;
         Dec(YeniID);
       until False;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SET IDENTITY_INSERT dbo.REHBER ON',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO REHBER(ID,KOD,FIRMA,STATU,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID)VALUES(&ID,&KOD,&FIRMA,&STATU,&DURUM,&EKLEYEN,&EKLEMETARIHI,'+IntToStr(SubeId)+')',
         ['&ID','&KOD','&FIRMA','&STATU','&DURUM','&EKLEYEN','&EKLEMETARIHI'],
         [YeniID,YeniKod,eskiad,1,1,Kullanan,FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SET IDENTITY_INSERT dbo.REHBER OFF',[],[]);
       Query1.Close;
       Query1.Open;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
                  ' delete from YETKI where MODULID like ''__98%'' and ROLID=-1 and SUBEID='+IntToStr(YeniID)+
                  ' insert into YETKI(ROLID,MODULID,HAK,TUR,SUBEID) '+
                  ' select -1,convert(varchar(4),M.MODULID)+convert(varchar(5),-1*('+IntToStr(YeniID)+')),1,1,'+IntToStr(YeniID)+' ' +
                  ' from MODUL M where LEN(M.MODULID)=4 and M.MODULID like ''__98'' '+
                  ' and not exists (select 1 from YETKI Y where Y.ROLID=-1 and Y.MODULID=convert(bigint,convert(varchar(4),M.MODULID)+convert(varchar(5),-1*('+IntToStr(YeniID)+'))) and Y.TUR=1 and Y.SUBEID='+IntToStr(YeniID)+') ',[],[]);
    end;
  end else if IslemTuru='Baglantilar' then begin
    ctrls := TGirdiDenetimleri.Create.Edit((AWYeniFirmaAdi),@eskiad);
    if TGirisKutusuEx.BilgiAlEx(BGFirma_adi_gir,ctrls) = mrOK then begin
      if OpenSQLServerForm <> nil then
         FreeAndNil(OpenSQLServerForm);
      Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
      OpenSQLServerForm.EditRemoteServer.Visible := True;
      OpenSQLServerForm.LabelRemoteServer.Visible := True;
      OpenSQLServerForm.btnOk.Caption := 'Ekle';
      OpenSQLServerForm.btnOk.OnClick := OpenSQLServerForm.btnEkleClick;
      OpenSQLServerForm.ShowModal;
      if OpenSQLServerForm.ModalResult = mrOK then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO BAGLANTILAR(TUR,SUBEADI,KULLANICIADI,SIFRE,VERITABANI,DURUM,SERVERADRESI_UZAK,SERVERADRESI_YAKIN,SUBEID)VALUES(&TUR,&SUBEADI,&KULLANICIADI,&SIFRE,&VERITABANI,&DURUM,&SERVERADRESI_UZAK,&SERVERADRESI_YAKIN,'+IntToStr(SubeId)+')',
         ['&TUR','&SUBEADI','&KULLANICIADI','&SIFRE','&VERITABANI','&DURUM','&SERVERADRESI_UZAK','&SERVERADRESI_YAKIN'],
         [1,eskiad,OpenSQLServerForm.ledUserName.Text,OpenSQLServerForm.ledPassword.Text,OpenSQLServerForm.cboDatabases.Text,1,OpenSQLServerForm.EditRemoteServer.Text,OpenSQLServerForm.cboServers.Text]);
      FreeAndNil(OpenSQLServerForm);
    end;
    FormShow(Self);
  end else
    Query1.Append;
end;

end.





