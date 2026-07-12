unit UKYDuzelticiVeOnleyiciFaalWizard;

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
  cxLookAndFeels, dxSkinLiquidSky, cxNavigator, cxGroupBox, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TKYDuzelticiVeOnleyiciFaalWizardDlg = class(TForm)
    Panel1: TPanel;
    btnDOF: TcxButton;
    WizardKontrol: TJvWizard;
    PageDOF: TJvWizardInteriorPage;
    PageBelge: TJvWizardInteriorPage;
    BtnDokuman: TcxButton;
    TabDOF: TFDQuery;
    DtsDOF: TDataSource;
    TabBelge: TFDQuery;
    DtsBelge: TDataSource;
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
    cxGroupBox1: TcxGroupBox;
    ComboFaaliyet: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    editDOFNo: TcxDBTextEdit;
    cxLabel6: TcxLabel;
    lblMusteri: TcxLabel;
    cxLabel8: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    ComboHataKaynagi: TcxDBImageComboBox;
    ComboMusteri: TcxButtonEdit;
    EditDOFAcan: TcxButtonEdit;
    DateTarih: TcxDBDateEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    LabelKategori: TcxLabel;
    EditKartTipiAdi: TcxDBTextEdit;
    cxLabel12: TcxLabel;
    MemDofNeden: TcxDBMemo;
    cxLabel13: TcxLabel;
    cxGroupBox2: TcxGroupBox;
    MemDofSavunma: TcxDBMemo;
    cxLabel11: TcxLabel;
    EditDOFSorumlu: TcxButtonEdit;
    cxLabel5: TcxLabel;
    DateSAVUNMAISTEMETARIHI: TcxDBDateEdit;
    cxLabel3: TcxLabel;
    cxLabel14: TcxLabel;
    cxLabel15: TcxLabel;
    cxDBDateEdit2: TcxDBDateEdit;
    cxGroupBox3: TcxGroupBox;
    MemoSONUC: TcxDBMemo;
    cxLabel18: TcxLabel;
    cxLabel19: TcxLabel;
    dateSONUCTARIHI: TcxDBDateEdit;
    EditDepartman: TcxButtonEdit;
    EditUrun: TcxButtonEdit;
    ComboOTVYUZDE: TcxDBImageComboBox;
    BeditProje: TcxButtonEdit;
    cxLabel7: TcxLabel;
    cxDBCheckBox1: TcxDBCheckBox;
    CheckBoxACIL: TcxDBCheckBox;
    procedure TabDOFAfterPost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure btnDOFClick(Sender: TObject);
    procedure BtnDokumanClick(Sender: TObject);
    procedure BelgeEkleTusClick(Sender: TObject);
    procedure TabDOFAfterOpen(DataSet: TDataSet);
    procedure BelgeSilTusClick(Sender: TObject);
    procedure BelgeGorTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure DtsBelgeDataChange(Sender: TObject; Field: TField);
    procedure TabDOFNewRecord(DataSet: TDataSet);
    procedure Kaydet;
    procedure Sil;
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure TabDOFBeforePost(DataSet: TDataSet);
    procedure cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure ComboHataKaynagiPropertiesCloseUp(Sender: TObject);
    procedure ComboMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditDOFSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditDOFAcanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditDepartmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelKategoriClick(Sender: TObject);
    procedure EditUrunPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    Cagiran, Yer, YerId, DOF_ID: Integer;
    IslemOp: Char;
    { Public declarations }
  end;

var
  KYDuzelticiVeOnleyiciFaalWizardDlg: TKYDuzelticiVeOnleyiciFaalWizardDlg;

implementation

uses PrjConst, Utablo, UResim, UBinarySave, URehberAyar, FetaKurulusSiniflari, Fetautil, UCariFonksiyonlar,
     UKYDuzelticiVeOnleyiciFaalListeDlg, UAnaForm, UVeriMotor;
{$R *.dfm}

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.BeditProjePropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabDOF, AButtonIndex,ProjeSecimi, TabDOF.FieldByName('REHBERID').AsInteger);
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.BelgeEkleTusClick(Sender: TObject);
var
  str: string;
begin
  if OpenDialog1.Execute then
  begin
    Tablo.Query1.Close;
    str := ExtractFileName(OpenDialog1.FileName);
    Tablo.Query1.SQL.Text := ' INSERT INTO IMAJ (REHBERID,YERI,YER_ID,BELGEADI,BELGE,EKLEYEN,SUBEID) ' + 'VALUES(' + IntToStr(DOF_ID) + ',''' + IntToStr(TabNo_KY_DOF) + ''',' + IntToStr(DOF_ID) + ',''' + str + ''',:PBELGE,''' + Kullanan + ''',' + IntToStr(SubeID) + ')';
    KutugeYaz(Tablo.Query1, OpenDialog1.FileName);
    TabBelge.Close;
    TabBelge.Open;
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.BelgeGorTusClick(Sender: TObject);
begin
  KutuktenOku(TabBelge, 'BELGE', 'BELGEADI', True);
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.BelgeSilTusClick(Sender: TObject);
begin
  if TabBelge.RecordCount > 0 then
    Tablo.BelgeSil(TabBelge);

end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.BtnDokumanClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageBelge;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.btnDOFClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageDOF;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.ComboHataKaynagiPropertiesCloseUp(Sender: TObject);
begin
  if ComboHataKaynagi.ItemIndex = 1 then
  begin
    lblMusteri.Visible := True;
    ComboMusteri.Visible := True;
  end
  else
  begin
    lblMusteri.Visible := False;
    ComboMusteri.Visible := False;
  end;

end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.ComboMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(-1);
  if ID > -2 then
  begin
    TabDOF.Edit;
    TabDOF.FieldByName('REHBERID').AsInteger := ID;
    ComboMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID); ;
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.LabelKategoriClick(Sender: TObject);
begin
   tablo.GeniniBaslat(Ops_KaliteDofKategori);
   tablo.GENINI.ReadImageSection(Ops_KaliteDofKategori, tablo.RepKaliteDofKategori.Properties.Items);
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.DtsBelgeDataChange(Sender: TObject; Field: TField);
begin
  BelgeEkleTus.Visible := TabBelge.State = dsBrowse;
  BelgeSilTus.Visible := TabBelge.State = dsBrowse;
  BelgeGorTus.Visible := TabBelge.State = dsBrowse;
  KaydetTus.Visible := TabBelge.State <> dsBrowse;
  IptalTus.Visible := TabBelge.State <> dsBrowse;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.EditDepartmanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   tablo.EditDepartmanSec(TcxButtonEdit(Sender), AButtonIndex,1, TabDOF, 'DEPARTMAN');
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.EditDOFAcanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    TabDOF.Edit;
    TabDOF.FieldByName('DOFACAN').AsInteger := ID;
    EditDOFAcan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.EditDOFSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    TabDOF.Edit;
    TabDOF.FieldByName('DOFSORUMLU').AsInteger := ID;
    EditDOFSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    Tablo.TablodanSorguAc(1,' select SINIF from REHBER where ID ='+IntToStr(ID));
    tablo.EditDepartmanSec(TcxButtonEdit(Sender), AButtonIndex,1, TabDOF, 'DEPARTMAN', Tablo.Query1.Fields[0].AsInteger);
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.EditUrunPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  StokID,Tur:integer;
begin
  Tur:=2;
  StokID := AnaForm.StokAraIdGetir(TabNo_DOF, Tur, False);
  if StokID>0 then begin
     Tablo.TablodanSorguAc(9,'select ID,KOD,STOKADI from STOKLAR where ID='+IntToStr(StokID));
     if (Tablo.Query9.Active)and(not Tablo.Query9.IsEmpty) then begin
         EditUrun.Text := Tablo.Query9.FieldByName('STOKADI').AsString;
         TabDOF.Edit;
         TabDOF.FieldByName('URUNTIPI').AsBoolean := Tur=1;
         TabDOF.FieldByName('URUNID').AsInteger := StokID;
     end;
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.FormShow(Sender: TObject);
begin
  case IslemOp of
    'E':
      begin
        TabDOF.SQL.Text := 'SELECT * FROM KALITEDOF';
        TabDOF.Active := True;
        TabDOF.Append;
        TabDOF.Post;
        TabDOF.Edit;
        ComboDURUM.EditValue := 1; // ComboDurum.Properties.Items[0].Value;
        EditDOFAcan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', StrToInt(Kullanan));
        TabDOF.FieldByName('DOFACAN').AsInteger := StrToInt(Kullanan);
        DateTarih.Date := Today;
      end;
    'D','K':
      begin
        TabloYenile(TabDOF, [DOF_ID]);
        // TabloYenile(TabDOFDetay,[DOF_ID]);
        if TabDOF.FieldByName('DOFACAN').AsString <> '' then
           EditDOFAcan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDOF.FieldByName('DOFACAN').AsInteger);
        if TabDOF.FieldByName('DOFSORUMLU').AsString <> '' then
           EditDOFSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDOF.FieldByName('DOFSORUMLU').AsInteger);
        if TabDOF.FieldByName('DEPARTMAN').AsString <> '' then begin
           Tablo.TablodanSorguAc(1,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
              ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
              ' from ROLLER ROL where ROL.ID='+TabDOF.FieldByName('DEPARTMAN').AsString);
           EditDepartman.text := Tablo.Query1.Fields[1].AsString+' / '+Tablo.Query1.Fields[2].AsString;
        end;

        if TabDOF.FieldByName('URUNID').AsString<>'' then begin
           Tablo.TablodanSorguAc(9,'select ID,KOD,STOKADI from STOKLAR where ID='+TabDOF.FieldByName('URUNID').AsString);
           if (Tablo.Query9.Active)and(not Tablo.Query9.IsEmpty) then
               EditUrun.Text := Tablo.Query9.FieldByName('STOKADI').AsString;
        end;

        if TabDOF.FieldByName('REHBERID').AsString <> '' then
           ComboMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDOF.FieldByName('REHBERID').AsInteger);
        if TabDOF.FieldByName('TESPITKAYNAGI').AsInteger = 1 then begin
           lblMusteri.Visible := True;
           ComboMusteri.Visible := True;
        end
        else begin
           lblMusteri.Visible := False;
           ComboMusteri.Visible := False;
        end;

        if (TabDOF.FieldByName('PROJEID').Value <> null) and (TabDOF.FieldByName('PROJEID').AsInteger>0) then begin
          Tablo.TablodanSorguAc(9,'select ID,AD=isnull(PROJEKODU,'''')+'' / ''+isnull(PROJEADI,'''') from PROJELER where ID='+TabDOF.FieldByName('PROJEID').AsString);
          if not Tablo.Query9.IsEmpty then begin
            BeditProje.Text := Tablo.Query9.FieldByName('AD').AsString;
            BeditProje.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
          end;
        end;

      end;
  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.IptalTusClick(Sender: TObject);
begin
  TabBelge.Cancel;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.KaydetTusClick(Sender: TObject);
begin
  TabBelge.Post;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  Kaydet;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.TabDOFAfterOpen(DataSet: TDataSet);
begin
  if DataSet.RecordCount = 1 then
  begin
    DOF_ID := TabDOF.Fields[0].AsInteger;
    // TabloYenile(TabDOFDetay,[DOF_ID]);
    TabloYenile(TabBelge, [TabNo_KY_DOF, DOF_ID]);

  end;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.TabDOFAfterPost(DataSet: TDataSet);
begin
  { if TabDOF.FieldByName('ID').AsInteger <> DOF_ID then begin
    DOF_ID := TabDOF.FieldByName('ID').AsInteger;
    end;
    Tabloyenile(TabDOF,[DOF_ID]); }
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.TabDOFBeforePost(DataSet: TDataSet);
begin
  // EkleyenDegistiren(DataSet);
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.TabDOFNewRecord(DataSet: TDataSet);
begin
   TabDOF.FieldByName('EKLEYEN').Value := strtoint(Kullanan);
   TabDOF.FieldByName('SUBEID').Value := SubeID;
   if (TabDOF.FieldByName('DURUM').IsNull) then
       TabDOF.FieldByName('DURUM').AsInteger := 1;
   TabDOF.FieldByName('YER').AsInteger := Yer;
   TabDOF.FieldByName('YER_ID').AsInteger := YerId;
   TabDOF.FieldByName('URUNTIPI').AsBoolean := True;
   TabDOF.FieldByName('ACIL').AsBoolean := False;
   TabDOF.FieldByName('ONEMLI').AsBoolean := False;
   TabDOF.FieldByName('DOFNO').AsString := Tablo.IDdenNumaraGetir('KALITEDOF',5);
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.Kaydet;
begin
   if TabDOF.Active then
      if TabDOF.State in [dsEdit, dsInsert] then
         TabDOF.Post;

   if TabBelge.Active then
      if TabBelge.State in [dsEdit, dsInsert] then
         TabBelge.Post;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.Sil;
begin
  if TabDOF.Active then
  begin
   TabDOF.Close;
   TabDOF.SQL.Text:='Select '+DbUst(1)+'* from KALITEDOF ORDER BY ID DESC '+DbSinir(1);
   TabDOF.Open;

   if TabDOF.State in [dsEdit, dsInsert] then
      TabDOF.Cancel;
  while not TabDOF.IsEmpty do
      TabDOF.Delete;
end;

 { if TabBelge.Active then
  begin
    if TabBelge.State in [dsEdit, dsInsert] then
      TabBelge.Cancel;
    while not TabBelge.IsEmpty do
      TabBelge.Delete;
  end;}
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  if IslemOp in ['E', 'K'] then
     Sil;
end;

procedure TKYDuzelticiVeOnleyiciFaalWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if not BoslukKontrol(ComboFaaliyet.text, 'Tipi') then Abort;
  //if not BoslukKontrol(ComboBolum.text, 'Birim') then Abort;
  if not BoslukKontrol(EditDOFAcan.text, 'DÖF Açan') then Abort;
  if not BoslukKontrol(ComboDURUM.text, 'Durum') then Abort;
  if not BoslukKontrol(ComboHataKaynagi.text, 'Tespit Kaynağı') then Abort;
  if (ComboHataKaynagi.ItemIndex =1) and (not BoslukKontrol(ComboMusteri.text, 'Müşteri')) then Abort;
  if not BoslukKontrol(EditDOFSorumlu.text, 'DÖF Sorumlusu') then Abort;
  if not BoslukKontrol(MemDofNeden.text, 'Uygunsuzluğun Tanımı') then Abort;

  Kaydet;

  ModalResult := mrOk;
  end;

end.


