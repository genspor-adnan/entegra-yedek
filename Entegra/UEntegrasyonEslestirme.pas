unit UEntegrasyonEslestirme;

interface
uses FireDAC.Comp.Client, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, dxSkinsCore, dxSkinLondonLiquidSky, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, cxLabel,
  cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, ExtCtrls,
  ComCtrls, ToolWin, cxButtonEdit, cxMemo, cxPC, StdCtrls, cxRadioGroup,
  cxCheckBox, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin,PrjConst,
  dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu,
  cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint;

type
  TEntegrasyonEslestirmeDlg = class(TForm)
    tabEslestirme: TFDQuery;
    dtsEslestirme: TDataSource;
    pgctrl: TcxPageControl;
    tsGunSonu: TcxTabSheet;
    tsStokKart: TcxTabSheet;
    tsStokGiris: TcxTabSheet;
    tsKurumFaturalari: TcxTabSheet;
    cxPageControl2: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    Panel2: TPanel;
    gridEslestirme: TcxGrid;
    tvEslestirme: TcxGridDBTableView;
    clmKaynakDeger: TcxGridDBColumn;
    clmHedefDeger: TcxGridDBColumn;
    clmHedefCari: TcxGridDBColumn;
    gridEslestirmeLevel1: TcxGridLevel;
    Panel1: TPanel;
    comboBaglanti: TcxImageComboBox;
    cxLabel1: TcxLabel;
    comboEntegrasyonTuru: TcxImageComboBox;
    cxLabel2: TcxLabel;
    ToolBar1: TToolBar;
    EslestirmeEkleTus: TToolButton;
    EslestirmeSilTus: TToolButton;
    ToolButton4: TToolButton;
    EslestirmeKaydetTus: TToolButton;
    EslestirmeIptalTus: TToolButton;
    cxTabSheet2: TcxTabSheet;
    GroupBox9: TGroupBox;
    RepGSCariHar: TcxRadioButton;
    RepGSTahsilat: TcxRadioButton;
    tsRehber: TcxTabSheet;
    cxMemo1: TcxMemo;
    cbGSAktarimiAktif: TcxCheckBox;
    cbStokKartAktarimi: TcxCheckBox;
    cbStokGirisAktarimiAktif: TcxCheckBox;
    cbKurumFaturalariAktarimi: TcxCheckBox;
    cbRehberKayitlariAktarimi: TcxCheckBox;
    cxPageControl3: TcxPageControl;
    cxTabSheet4: TcxTabSheet;
    cxTabSheet5: TcxTabSheet;
    cxPageControl4: TcxPageControl;
    cxTabSheet6: TcxTabSheet;
    cxTabSheet7: TcxTabSheet;
    cxPageControl5: TcxPageControl;
    cxTabSheet8: TcxTabSheet;
    cxTabSheet9: TcxTabSheet;
    cxPageControl6: TcxPageControl;
    cxTabSheet10: TcxTabSheet;
    cxTabSheet11: TcxTabSheet;
    cxMemo2: TcxMemo;
    cxMemo3: TcxMemo;
    cxMemo4: TcxMemo;
    cxMemo5: TcxMemo;
    TabAktarimAyarlari: TFDQuery;
    DtsAktarimAyarlari: TDataSource;
    PnAktarimAyarlari: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    ToolBar2: TToolBar;
    BtnAAKaydet: TToolButton;
    BtnAAIptal: TToolButton;
    cxGrid1DBTableView1SUBEADI: TcxGridDBColumn;
    cxGrid1DBTableView1Aktarim: TcxGridDBColumn;
    cnn2query: TFDQuery;
    ToolButton1: TToolButton;
    MemoRehber: TcxMemo;
    MemoRehberBilgi: TcxMemo;
    MemoStokKart: TcxMemo;
    MemoStokKartEkProcedure: TcxMemo;
    MemoStokFatura: TcxMemo;
    procedure EslestirmeEkleTusClick(Sender: TObject);
    procedure EslestirmeSilTusClick(Sender: TObject);
    procedure EslestirmeKaydetTusClick(Sender: TObject);
    procedure EslestirmeIptalTusClick(Sender: TObject);
    procedure dtsEslestirmeStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure comboBaglantiPropertiesEditValueChanged(Sender: TObject);
    procedure tabEslestirmeNewRecord(DataSet: TDataSet);
    procedure tabEslestirmeBeforePost(DataSet: TDataSet);
    procedure clmKaynakDegerPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure clmHedefCariPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure clmHedefCariGetDisplayText(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AText: string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbRehberKayitlariAktarimiPropertiesEditValueChanged(
      Sender: TObject);
    procedure cbStokKartAktarimiPropertiesEditValueChanged(Sender: TObject);
    procedure cbStokGirisAktarimiAktifPropertiesEditValueChanged(
      Sender: TObject);
    procedure cbGSAktarimiAktifPropertiesEditValueChanged(Sender: TObject);
    procedure cbKurumFaturalariAktarimiPropertiesEditValueChanged(
      Sender: TObject);
    procedure pgctrlPageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure TabAktarimAyarlariBeforePost(DataSet: TDataSet);
    procedure BtnAAKaydetClick(Sender: TObject);
    procedure BtnAAIptalClick(Sender: TObject);
    procedure DtsAktarimAyarlariStateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EntegrasyonEslestirmeDlg: TEntegrasyonEslestirmeDlg;

implementation
uses Utablo,FetaKurulusSiniflari;//LocOnFly,PrjConst;
{$R *.dfm}

procedure TEntegrasyonEslestirmeDlg.BtnAAIptalClick(Sender: TObject);
begin
  TabAktarimAyarlari.Cancel;
end;

procedure TEntegrasyonEslestirmeDlg.BtnAAKaydetClick(Sender: TObject);
begin
  TabAktarimAyarlari.Post;
end;

procedure TEntegrasyonEslestirmeDlg.cbGSAktarimiAktifPropertiesEditValueChanged(
  Sender: TObject);
begin
  cxPageControl2.Enabled:=cbGSAktarimiAktif.Checked;
end;

procedure TEntegrasyonEslestirmeDlg.cbKurumFaturalariAktarimiPropertiesEditValueChanged(
  Sender: TObject);
begin
  cxPageControl6.Enabled:=cbKurumFaturalariAktarimi.Checked;
end;

procedure TEntegrasyonEslestirmeDlg.cbRehberKayitlariAktarimiPropertiesEditValueChanged(
  Sender: TObject);
begin
  cxPageControl3.Enabled:=cbRehberKayitlariAktarimi.Checked;
end;

procedure TEntegrasyonEslestirmeDlg.cbStokGirisAktarimiAktifPropertiesEditValueChanged(
  Sender: TObject);
begin
  cxPageControl5.Enabled := cbStokGirisAktarimiAktif.Checked;
end;

procedure TEntegrasyonEslestirmeDlg.cbStokKartAktarimiPropertiesEditValueChanged(
  Sender: TObject);
begin
  cxPageControl4.Enabled:=cbStokKartAktarimi.Checked;
end;

procedure TEntegrasyonEslestirmeDlg.clmHedefCariGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  ID2:Integer;
begin
  if ARecord.Values[clmHedefCari.Index]<>Null then
    if ARecord.Values[clmHedefCari.Index]>-98 then  begin
      ID2:=ARecord.Values[clmHedefCari.Index];
      AText := Tablo.AciklamaGetir('REHBER','FIRMA',ID2);
    end else
      AText := '';
end;

procedure TEntegrasyonEslestirmeDlg.clmHedefCariPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(-1);
  if ID > -2 then
   begin
    if tabEslestirme.State=dsBrowse then
     tabEslestirme.Edit;
    tabEslestirme.FieldByName('HEDEFREHBERID').AsInteger:= ID;
   end;

end;

procedure TEntegrasyonEslestirmeDlg.clmKaynakDegerPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
 st : TStringList;
begin
  Tablo.BaglantiAc(comboBaglanti.EditValue,Tablo.FDCnn2);
  st:= TStringList.Create;
  case comboEntegrasyonTuru.EditValue of
    TabNo_GENOTIP_CARI_NAKIT : begin
                                 if Tablo.ListedenBilgiGetir('Tahsilat Türü Seçimi','select ANAHTAR from GENOTIPINI WHERE BOLUM = ''TAHSILAT_TURU'' AND DEGER NOT LIKE ''P%'' ',st,[],'EntegEslesTahsilatTuruNakit',BtnAAKaydetClick, Tablo.FDCnn2 ) then
                                  tabEslestirme.FieldByName('KAYNAKDEGER').AsString:= st[0];
                               end;
    TabNo_GENOTIP_CARI_POS : begin
                                 if Tablo.ListedenBilgiGetir('Tahsilat Türü Seçimi','select ANAHTAR from GENOTIPINI WHERE BOLUM = ''TAHSILAT_TURU'' AND DEGER LIKE ''P%'' ',st,[],'EntegEslesTahsilatTuruPos',BtnAAKaydetClick, Tablo.FDCnn2 ) then
                                  tabEslestirme.FieldByName('KAYNAKDEGER').AsString:= st[0];
                               end;

  end;


  st.Free;
end;

procedure TEntegrasyonEslestirmeDlg.comboBaglantiPropertiesEditValueChanged(
  Sender: TObject);
begin
   if comboBaglanti.Properties.Items.Count<=0 then
    begin
      Application.MessageBox(PChar(ENTanimlama_yap),PChar(Uyari), MB_OK+ MB_ICONINFORMATION);
      Close;
    end;


 case comboEntegrasyonTuru.EditValue of
   TabNo_GENOTIP_CARI_NAKIT :   clmHedefDeger.Properties:= Tablo.imgComboboxInit('select ID, KASAKODU+''-''+KASAADI KASAADI from KASALAR');
   TabNo_GENOTIP_CARI_POS : clmHedefDeger.Properties := Tablo.imgComboboxInit(' select ID,KODU+''-''+ADI POSADI from POS') ;
 end;

  TabloYenile(tabEslestirme,[comboBaglanti.EditValue, comboEntegrasyonTuru.EditValue]);
end;

procedure TEntegrasyonEslestirmeDlg.DtsAktarimAyarlariStateChange(
  Sender: TObject);
begin
  BtnAAKaydet.Visible := DtsAktarimAyarlari.State <> dsBrowse;
  BtnAAIptal.Visible := DtsAktarimAyarlari.State <> dsBrowse;
end;

procedure TEntegrasyonEslestirmeDlg.dtsEslestirmeStateChange(Sender: TObject);
begin
  EslestirmeEkleTus.Visible:= dtsEslestirme.State = dsBrowse;
  EslestirmeSilTus.Visible:= dtsEslestirme.State = dsBrowse;
  EslestirmeKaydetTus.Visible:= not (EslestirmeEkleTus.Visible);
  EslestirmeIptalTus.Visible:=  not (EslestirmeEkleTus.Visible);
end;

procedure TEntegrasyonEslestirmeDlg.EslestirmeEkleTusClick(Sender: TObject);
begin
 if not tabEslestirme.Active then
  TabloYenile(tabEslestirme,[comboBaglanti.EditValue, comboEntegrasyonTuru.EditValue]);

  tabEslestirme.Append;
end;

procedure TEntegrasyonEslestirmeDlg.EslestirmeIptalTusClick(Sender: TObject);
begin
 tabEslestirme.Cancel;
end;

procedure TEntegrasyonEslestirmeDlg.EslestirmeKaydetTusClick(Sender: TObject);
begin
  tabEslestirme.Post;
end;

procedure TEntegrasyonEslestirmeDlg.EslestirmeSilTusClick(Sender: TObject);
begin
  if tabEslestirme.RecordCount<=0 then
    abort;
  if Application.MessageBox(PChar(ENKayit_Silinsinmi),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)=ID_NO then
    Abort;

  tabEslestirme.Delete;
end;

procedure TEntegrasyonEslestirmeDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_RepGSCariHar,RepGSCariHar.Checked);//    GenelOpsiyon   RepGSCariHar
  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_RepGSTahsilat,RepGSTahsilat.Checked);// GenelOpsiyon    RepGSTahsilat
  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_AktarimRehberKayitlari,cbRehberKayitlariAktarimi.Checked);//GenelOpsiyon    AktarimRehberKayitlari
  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_AktarimStokKart,cbStokKartAktarimi.Checked);//  GenelOpsiyon     AktarimStokKart
  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_AktarimStokGiris,cbStokGirisAktarimiAktif.Checked);//   GenelOpsiyon    AktarimStokGiris
  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_AktarimGunSonu,cbGSAktarimiAktif.Checked);//   GenelOpsiyon    AktarimGunSonu
  Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_AktarimKurumFaturalari,cbKurumFaturalariAktarimi.Checked);//   GenelOpsiyon  AktarimKurumFaturalari
end;

procedure TEntegrasyonEslestirmeDlg.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  RepGSCariHar.Checked := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_RepGSCariHar,True);// GenelOpsiyon','RepGSCariHar', True);
  RepGSTahsilat.Checked :=Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_RepGSTahsilat,False);//    GenelOpsiyon','RepGSTahsilat', False);

  cbRehberKayitlariAktarimi.Checked :=Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_AktarimRehberKayitlari,False);//    GenelOpsiyon','AktarimRehberKayitlari', False);
  cbStokKartAktarimi.Checked := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_AktarimStokKart,False);//   GenelOpsiyon','AktarimStokKart', False);
  cbStokGirisAktarimiAktif.Checked := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_AktarimStokGiris,False);//   GenelOpsiyon','AktarimStokGiris', False);
  cbGSAktarimiAktif.Checked := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_AktarimGunSonu,False);//    GenelOpsiyon','AktarimGunSonu', False);
  cbKurumFaturalariAktarimi.Checked := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_AktarimKurumFaturalari,False);//   GenelOpsiyon','AktarimKurumFaturalari', False);


  comboBaglanti.Properties:= Tablo.imgComboboxInit('SELECT ID,SUBEADI FROM BAGLANTILAR WHERE TUR LIKE ''%1%'' ');
  if comboBaglanti.Properties.Items.Count>0 then
    comboBaglanti.ItemIndex:=0;
  case comboEntegrasyonTuru.EditValue of
    TabNo_GENOTIP_CARI_NAKIT :   clmHedefDeger.Properties:= Tablo.imgComboboxInit('select ID, KASAKODU+''-''+KASAADI KASAADI from KASALAR');
    TabNo_GENOTIP_CARI_POS : clmHedefDeger.Properties := Tablo.imgComboboxInit(' select ID,KODU+''-''+ADI POSADI from POS') ;
  end;
  Tablo.GridTurkcelestir;
end;

procedure TEntegrasyonEslestirmeDlg.pgctrlPageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  if NewPage=tsRehber then begin
    PnAktarimAyarlari.Parent := cxTabSheet4;
    cxGrid1DBTableView1Aktarim.DataBinding.FieldName := 'GENOTIP_REHBER';
    TabAktarimAyarlari.Close;
    TabAktarimAyarlari.Open;
  end else if NewPage=tsStokKart then begin
    PnAktarimAyarlari.Parent := cxTabSheet6;
    cxGrid1DBTableView1Aktarim.DataBinding.FieldName := 'GENOTIP_STOKKART';
    TabAktarimAyarlari.Close;
    TabAktarimAyarlari.Open;
  end else if NewPage=tsStokGiris then begin
    PnAktarimAyarlari.Parent := cxTabSheet8;
    cxGrid1DBTableView1Aktarim.DataBinding.FieldName := 'GENOTIP_STOKGIRIS';
    TabAktarimAyarlari.Close;
    TabAktarimAyarlari.Open;
  end else if NewPage=tsGunSonu then begin
    //
  end else if NewPage=tsKurumFaturalari then begin
   //
  end;
end;

procedure TEntegrasyonEslestirmeDlg.TabAktarimAyarlariBeforePost(
  DataSet: TDataSet);
var
  EntDBName,GenDBName:string;
  procedure SorguyuDuzenleyipCalistir(Memo:TStrings;cnn:TFDConnection);
  var
    I: Integer;
    Q: TFDQuery;
  begin
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := cnn;
      Q.SQL.Clear;
      for I := 0 to Memo.Count - 1 do
        Q.SQL.Add(StringReplace(StringReplace(Memo[I], 'GEN2005', GenDBName, [rfReplaceAll]), 'ENTEGRA', EntDBName, [rfReplaceAll]));
      Q.ExecSQL;
    finally
      Q.Free;
    end;
  end;
begin
  Tablo.TablodanSorguAc(6,'select DB_NAME()');
  EntDBName:=Tablo.Query6.Fields[0].AsString;
  GenDBName:=TabAktarimAyarlari.FieldByName('VERITABANI').AsString;
  Tablo.BaglantiAc(TabAktarimAyarlari.FieldByName('ID').AsInteger,Tablo.FDCnn2);
  if Tablo.FDCnn2.Connected then
    if pgctrl.ActivePage=tsRehber then
      if TabAktarimAyarlari.FieldByName('GENOTIP_REHBER').AsBoolean then begin
        SorguyuDuzenleyipCalistir(MemoRehber.Lines,Tablo.FDCnn);
        SorguyuDuzenleyipCalistir(MemoRehberBilgi.Lines,Tablo.FDCnn);
      end else begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DROP TRIGGER [dbo].[TG_GenotipRehberEntegrasyon] ',[],[]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DROP TRIGGER [dbo].[TG_GenotipRehberBilgiEntegrasyon] ',[],[]);
      end
    else if pgctrl.ActivePage=tsStokKart then
      if TabAktarimAyarlari.FieldByName('GENOTIP_STOKKART').AsBoolean then begin
        SorguyuDuzenleyipCalistir(MemoStokKart.Lines,Tablo.FDCnn2);
        SorguyuDuzenleyipCalistir(MemoStokKartEkProcedure.Lines,Tablo.FDCnn);
      end else begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn2,'DROP TRIGGER [dbo].[TG_EntegraStokEntegrasyon]  ',[],[]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DROP PROCEDURE  [dbo].[p_INIdenDegerGetirYoksaEkle] ',[],[]);
      end
    else if pgctrl.ActivePage=tsStokGiris then
      if TabAktarimAyarlari.FieldByName('GENOTIP_STOKGIRIS').AsBoolean then begin
        SorguyuDuzenleyipCalistir(MemoStokFatura.Lines,Tablo.FDCnn2);
      end else begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn2,'DROP TRIGGER [dbo].[TG_EntegraStokFaturaAktarimi] ',[],[]);
      end
    else if pgctrl.ActivePage=tsGunSonu then begin
      //
    end else if pgctrl.ActivePage=tsKurumFaturalari then begin
      //
    end;
end;

procedure TEntegrasyonEslestirmeDlg.tabEslestirmeBeforePost(DataSet: TDataSet);
begin
  if (Trim(tabEslestirme.FieldByName('KAYNAKDEGER').AsString) ='') or (Trim(tabEslestirme.FieldByName('HEDEFDEGER').AsString)='') then
   begin
     Application.MessageBox(PChar(ENDegerleri_doldur),PChar(Uyari),  MB_OK+ MB_ICONWARNING);
     abort;
   end;
  if tabEslestirme.FieldByName('HEDEFREHBERID').AsInteger=0 then
   begin
     Application.MessageBox(PChar(ENCari_bilgisi_doldur),PChar(Uyari), MB_OK+ MB_ICONWARNING);
     abort;
   end;
end;

procedure TEntegrasyonEslestirmeDlg.tabEslestirmeNewRecord(DataSet: TDataSet);
begin
  tabEslestirme.FieldByName('BAGLANTIID').AsInteger:= comboBaglanti.EditValue;
  tabEslestirme.FieldByName('YER').AsInteger:= comboEntegrasyonTuru.EditValue;
end;

end.






