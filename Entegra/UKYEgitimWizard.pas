unit UKYEgitimWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxControls, cxContainer, cxEdit,
  cxLabel, cxDBLabel, JvWizard, JvExControls, StdCtrls, cxButtons, ExtCtrls, DB,
  FireDAC.Comp.Client, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, DateUtils,
  cxDataStorage, cxDBData, cxImageComboBox, ComCtrls, ToolWin, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxImage, cxDBEdit, cxTextEdit, cxMemo, cxMaskEdit,
  cxDropDownEdit, cxSpinEdit, cxButtonEdit, cxCheckBox, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCalendar,
  cxLookAndFeels, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, cxNavigator, dxSkinLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light;

type
  TKYEgitimWizardDlg = class(TForm)
    Panel1: TPanel;
    btnDOF: TcxButton;
    WizardKontrol: TJvWizard;
    PageDOF: TJvWizardInteriorPage;
    PageBelge: TJvWizardInteriorPage;
    BtnDokuman: TcxButton;
    TabEgitim: TFDQuery;
    DtsEgitim: TDataSource;
    TabBelge: TFDQuery;
    DtsBelge: TDataSource;
    ComboFaaliyet: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    LblBirim: TcxLabel;
    ToolBar2: TToolBar;
    BelgeEkleTus: TToolButton;
    BelgeSilTus: TToolButton;
    BelgeGorTus: TToolButton;
    ToolButton2: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    GridBelge: TcxGrid;
    GridBelgeDBTableViewImaj: TcxGridDBTableView;
    GridBelgeDBTableViewImajBELGEADI: TcxGridDBColumn;
    GridBelgeDBTableViewImajTUR: TcxGridDBColumn;
    GridBelgeDBTableViewImajACIKLAMA: TcxGridDBColumn;
    GridBelgeDBTableViewImajBELGE: TcxGridDBColumn;
    GridBelgeLevel1: TcxGridLevel;
    OpenDialog1: TOpenDialog;
    lblMusteri: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel11: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    ComboMusteri: TcxButtonEdit;
    ComboBolum: TcxDBImageComboBox;
    EditEgitimAcan: TcxButtonEdit;
    EditEgitimSorumlu: TcxButtonEdit;
    DateTarihBaslangic: TcxDBDateEdit;
    cxLabel3: TcxLabel;
    Panel6: TPanel;
    Panel7: TPanel;
    cxLabel10: TcxLabel;
    MemDofNeden: TcxDBMemo;
    EditEgitimKonusu: TcxDBTextEdit;
    cxLabel5: TcxLabel;
    DateTarihBitis: TcxDBDateEdit;
    TabEgitimKullanici: TFDQuery;
    DtsToplantiKullanici: TDataSource;
    Panel2: TPanel;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBTableView1Column1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    SatirEkle: TToolButton;
    KatilimKaydet: TToolButton;
    KatilimciSil: TToolButton;
    KatilimIptal: TToolButton;
    cxLabel6: TcxLabel;
    editKALITENO: TcxDBTextEdit;
    procedure TabEgitimAfterPost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure btnDOFClick(Sender: TObject);
    procedure BtnDokumanClick(Sender: TObject);
    procedure BelgeEkleTusClick(Sender: TObject);
    procedure TabEgitimAfterOpen(DataSet: TDataSet);
    procedure BelgeSilTusClick(Sender: TObject);
    procedure BelgeGorTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure DtsBelgeDataChange(Sender: TObject; Field: TField);
    procedure TabEgitimNewRecord(DataSet: TDataSet);
    procedure Kaydet;
    procedure Sil;
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure TabEgitimBeforePost(DataSet: TDataSet);
    procedure cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure ComboMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditDOFSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditDOFAcanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ComboFaaliyetPropertiesCloseUp(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure KatilimKaydetClick(Sender: TObject);
    procedure KatilimciSilClick(Sender: TObject);
    procedure KatilimIptalClick(Sender: TObject);
    procedure DtsToplantiKullaniciStateChange(Sender: TObject);
  private
    { Private declarations }
  public
    EgitimID:Integer;
    Cagiran:Integer;
    StokID:Integer;
    IslemOp:Char;

    { Public declarations }
  end;

var
  KYEgitimWizardDlg: TKYEgitimWizardDlg;

implementation

uses PrjConst, Utablo, UResim, UBinarySave, URehberAyar, FetaKurulusSiniflari, Fetautil, UCariFonksiyonlar, UKYDuzelticiVeOnleyiciFaalListeDlg;
{$R *.dfm}

procedure TKYEgitimWizardDlg.BelgeEkleTusClick(Sender: TObject);
var
  str: string;
begin
  if OpenDialog1.Execute then
  begin
    Tablo.Query1.Close;
    str := ExtractFileName(OpenDialog1.FileName);
    Tablo.Query1.SQL.Text := ' INSERT INTO IMAJ (REHBERID,YERI,YER_ID,BELGEADI,BELGE,EKLEYEN,SUBEID) ' + 'VALUES(' + IntToStr(EgitimID) + ',''' + IntToStr(TabNo_KY_DOF) + ''',' + IntToStr(EgitimId) + ',''' + str + ''',:PBELGE,''' + Kullanan + ''',' + IntToStr(SubeID) + ')';
    KutugeYaz(Tablo.Query1, OpenDialog1.FileName);
    TabBelge.Close;
    TabBelge.Open;
  end;
end;

procedure TKYEgitimWizardDlg.BelgeGorTusClick(Sender: TObject);
begin
  KutuktenOku(TabBelge, 'BELGE', 'BELGEADI', True);
end;

procedure TKYEgitimWizardDlg.BelgeSilTusClick(Sender: TObject);
begin
  if TabBelge.RecordCount > 0 then
    Tablo.BelgeSil(TabBelge);

end;

procedure TKYEgitimWizardDlg.BtnDokumanClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageBelge;
end;

procedure TKYEgitimWizardDlg.btnDOFClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageDOF;
end;

procedure TKYEgitimWizardDlg.ComboFaaliyetPropertiesCloseUp(Sender: TObject);
begin
 if ComboFaaliyet.EditValue = 0 then
  begin

    lblBirim.Visible := True;
    ComboBolum.Visible := True;
    lblMusteri.Visible := False;
    ComboMusteri.Visible := False;
  end;

 if ComboFaaliyet.EditValue = 1 then
  begin
    lblMusteri.Visible := True;
    ComboMusteri.Visible := True;
    lblBirim.Visible := False;
    ComboBolum.Visible := False;
  end;
end;

procedure TKYEgitimWizardDlg.ComboMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(-1);
  if ID > -2 then
  begin
    Tabegitim.Edit;
    Tabegitim.FieldByName('REHBERID').AsInteger := ID;
    ComboMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID); ;
  end;
end;

procedure TKYEgitimWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TKYEgitimWizardDlg.DtsBelgeDataChange(Sender: TObject; Field: TField);
begin
  BelgeEkleTus.Visible := TabBelge.State = dsBrowse;
  BelgeSilTus.Visible := TabBelge.State = dsBrowse;
  BelgeGorTus.Visible := TabBelge.State = dsBrowse;
  KaydetTus.Visible := TabBelge.State <> dsBrowse;
  IptalTus.Visible := TabBelge.State <> dsBrowse;
end;

procedure TKYEgitimWizardDlg.DtsToplantiKullaniciStateChange(Sender: TObject);
begin
  SatirEkle.Visible := DtsToplantiKullanici.State = dsBrowse;
  KatilimciSil.Visible := (DtsToplantiKullanici.State=dsBrowse)and(not TabEgitimKullanici.IsEmpty);
  KatilimKaydet.Visible := DtsToplantiKullanici.State in [dsEdit,dsInsert];
  KatilimIptal.Visible := DtsToplantiKullanici.State in [dsEdit,dsInsert];
end;

procedure TKYEgitimWizardDlg.EditDOFAcanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    Tabegitim.Edit;
    Tabegitim.FieldByName('EGITIMACAN').AsInteger := ID;
    EditEgitimAcan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
  end;
end;

procedure TKYEgitimWizardDlg.EditDOFSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    Tabegitim.Edit;
    Tabegitim.FieldByName('EGITIMSORUMLU').AsInteger := ID;
    EditEgitimSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
  end;
end;

procedure TKYEgitimWizardDlg.FormShow(Sender: TObject);
begin
  KYEgitimWizardDlg.Width:=726;
  KYEgitimWizardDlg.ClientWidth:=710;
  case IslemOp of
    'E':
      begin
        Tabegitim.SQL.Text := 'SELECT * FROM KALITEEGITIM';
        Tabegitim.Active := True;
        Tabegitim.Append;
        Tabegitim.Post;
        Tabegitim.Edit;
        ComboDURUM.EditValue := 1; // ComboDurum.Properties.Items[0].Value;
        EditEgitimAcan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', StrToInt(Kullanan));
        Tabegitim.FieldByName('EGITIMACAN').AsInteger := StrToInt(Kullanan);
        DateTarihBaslangic.Date := Now;
        DateTarihBitis.Date := Now;
      end;
    'D','K':
      begin
        TabloYenile(TabEgitim, [EgitimID]);
        if Tabegitim.FieldByName('EGITIMACAN').AsString <> '' then
          EditEgitimAcan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tabegitim.FieldByName('EGITIMACAN').AsInteger);
        if Tabegitim.FieldByName('EGITIMSORUMLU').AsString <> '' then
          EditEgitimSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tabegitim.FieldByName('EGITIMSORUMLU').AsInteger);
        if Tabegitim.FieldByName('REHBERID').AsString <> '' then
          ComboMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tabegitim.FieldByName('REHBERID').AsInteger);
        if Tabegitim.FieldByName('EGITIMTURU').AsInteger = 0 then
        begin

          lblBirim.Visible := True;
          ComboBolum.Visible := True;
          lblMusteri.Visible := False;
          ComboMusteri.Visible := False;
        end else
        begin
          lblMusteri.Visible := True;
          ComboMusteri.Visible := True;
          lblBirim.Visible := False;
          ComboBolum.Visible := False;
        end;
        Tabloyenile(TabEgitimKullanici, [EgitimID]);
      end;
  end;
end;

procedure TKYEgitimWizardDlg.IptalTusClick(Sender: TObject);
begin
  TabBelge.Cancel;
end;

procedure TKYEgitimWizardDlg.KaydetTusClick(Sender: TObject);
begin
  TabBelge.Post;
end;

procedure TKYEgitimWizardDlg.PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  Kaydet;
end;

procedure TKYEgitimWizardDlg.TabEgitimAfterOpen(DataSet: TDataSet);
begin
  if DataSet.RecordCount = 1 then
  begin
    EgitimID := Tabegitim.Fields[0].AsInteger;
    // TabloYenile(TabDOFDetay,[DOF_ID]);
    TabloYenile(TabBelge, [TabNo_KY_DOF, EgitimID]);

  end;
end;

procedure TKYEgitimWizardDlg.TabEgitimAfterPost(DataSet: TDataSet);
begin
  { if TabDOF.FieldByName('ID').AsInteger <> DOF_ID then begin
    DOF_ID := TabDOF.FieldByName('ID').AsInteger;
    end;
    Tabloyenile(TabDOF,[DOF_ID]); }
end;

procedure TKYEgitimWizardDlg.TabEgitimBeforePost(DataSet: TDataSet);
begin
  // EkleyenDegistiren(DataSet);
  
end;

procedure TKYEgitimWizardDlg.TabEgitimNewRecord(DataSet: TDataSet);
begin
  Tabegitim.FieldByName('EKLEYEN').Value := strtoint(Kullanan);
  Tabegitim.FieldByName('SUBEID').Value := SubeID;
  Tabegitim.FieldByName('EKLENMETARIHI').Value := Now;
  if (Tabegitim.FieldByName('DURUM').IsNull) then
   Tabegitim.FieldByName('DURUM').AsInteger := 1;

  Tabegitim.FieldByName('EGITIMNO').AsString := Tablo.IDdenNumaraGetir('KALITEEGITIM',5);
end;

procedure TKYEgitimWizardDlg.KatilimciSilClick(Sender: TObject);
begin
if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    TabEgitimKullanici.Delete;
  Tabloyenile(TabEgitimKullanici, [TabEgitim.FieldByName('ID').AsString]);
end;

procedure TKYEgitimWizardDlg.KatilimIptalClick(Sender: TObject);
begin
TabEgitimKullanici.Cancel;
end;

procedure TKYEgitimWizardDlg.KatilimKaydetClick(Sender: TObject);
begin
TabEgitimKullanici.Post;
end;

procedure TKYEgitimWizardDlg.Kaydet;
begin
  if Tabegitim.Active then
    if Tabegitim.State in [dsEdit, dsInsert] then
      Tabegitim.Post;

  if TabBelge.Active then
    if TabBelge.State in [dsEdit, dsInsert] then
      TabBelge.Post;
end;

procedure TKYEgitimWizardDlg.SatirEkleClick(Sender: TObject);
var
  Kullanicilar: TstringList;
  Kosul: string;
  i: integer;
begin        // EGITIM KULLANICI YER=2
  TabEgitim.post;

  Kullanicilar := TstringList.Create;
  Kullanicilar := Tablo.ListedenCokluSecim('', 'SELECT DISTINCT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID  ),R.GRUP,R.KATEGORI,R.SINIF  FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID' +
  ' WHERE  R.DURUM=1 AND K.DURUM=1 AND R.ID NOT IN (SELECT REHID FROM KALITEKULLANICI KK WHERE KK.REHID=R.ID AND KK.YER=2 AND KK.YERID='+TabEgitim.FieldByName('ID').AsString+')', [nil, nil, nil, Tablo.RepCariGrup, Tablo.RepCariBolum, Tablo.RepCariSinif], ['Id', 'Kullanýcý', 'Rol', 'Grup', 'Kategori', 'Sýnýf']);
  if Kullanicilar.Count > 0 then
  begin
    for I := 0 to Kullanicilar.Count - 1 do
    Begin
      Tablo.Query5.SQL.Text := 'INSERT INTO KALITEKULLANICI(YER,YERID,REHID)' + 'VALUES  (' + '''' + inttostr(2) + '''' + ',' + TabEgitim.FieldByName('ID').AsString + ',' + Kullanicilar[i] + ')'; // inttostr(ToplantiID)
      Tablo.Query5.ExecSQL;

    End;
    //TabEgitimKullanici.Close;
    //TabEgitimKullanici.Params[0].Value := TabEgitim.FieldByName('ID').AsString;
    //TabEgitimKullanici.Open;
    EgitimID := TabEgitim.FieldByName('ID').AsInteger;
    Tabloyenile(TabEgitimKullanici, [EgitimID]);
  end;
end;

procedure TKYEgitimWizardDlg.Sil;
begin
  if Tabegitim.Active then
  begin
   Tabegitim.Close;
   Tabegitim.SQL.Text:='Select TOP 1 * from KALITEEGITIM ORDER BY ID DESC';
   Tabegitim.Open;

    if Tabegitim.State in [dsEdit, dsInsert] then
      Tabegitim.Cancel;
    while not Tabegitim.IsEmpty do
      Tabegitim.Delete;
  end;

 { if TabBelge.Active then
  begin
    if TabBelge.State in [dsEdit, dsInsert] then
      TabBelge.Cancel;
    while not TabBelge.IsEmpty do
      TabBelge.Delete;
  end;}
end;

procedure TKYEgitimWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  if IslemOp in ['E', 'K'] then
     Sil;
end;

procedure TKYEgitimWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if not BoslukKontrol(ComboFaaliyet.text, 'Faaliyet Türü') then Abort;
  if  (ComboFaaliyet.ItemIndex =0) and (not BoslukKontrol(ComboBolum.text, 'Birim')) then Abort;
  if (ComboFaaliyet.ItemIndex =1) and (not BoslukKontrol(ComboMusteri.text, 'Müþteri')) then Abort;
  if not BoslukKontrol(EditEgitimAcan.text, 'Eðitim Açan') then Abort;
  if not BoslukKontrol(ComboDURUM.text, 'Durum') then Abort;
  //if not BoslukKontrol(ComboHataKaynagi.text, 'Tespit Kaynaðý') then Abort;
  //if (ComboHataKaynagi.ItemIndex =1) and (not BoslukKontrol(ComboMusteri.text, 'Müþteri')) then Abort;
  if not BoslukKontrol(EditEgitimSorumlu.text, 'Eðitim Sorumlusu') then Abort;
  if not BoslukKontrol(MemDofNeden.text, 'Eðitim Açýklama') then Abort;

  Kaydet;

  ModalResult := mrOk;
  end;

end.




