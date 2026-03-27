unit UHizliGirisKasaOzet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans,
  dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, cxLabel, JvExControls, JvButton,
  JvNavigationPane, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  Vcl.ExtCtrls, Utablo, FireDAC.Comp.Client, Vcl.ComCtrls,
  cxEditRepositoryItems, cxCalendar, dateutils, Vcl.Menus, Vcl.StdCtrls,
  cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, dxCore,
  cxDateUtils, cxSplitter, cxDBNavigator;

type
  THizliGirisKasaOzet = class(TForm)
    Panel1: TPanel;
    pnlSag: TPanel;
    TabKasaOzet: TFDQuery;
    DtsKasaOzet: TDataSource;
    pnlSagUst: TPanel;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    cxLabel9: TcxLabel;
    pnlUstMenu: TPanel;
    btnkasabilgisi: TcxButton;
    btnKasaKapat: TcxButton;
    pnlAcBilgi: TPanel;
    lblAcilisTarih: TcxLabel;
    lblAcan: TcxLabel;
    cmbAcan: TcxImageComboBox;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    lblAcilisTutari: TcxLabel;
    edtAcilisTutar: TcxTextEdit;
    cmbSubeler: TcxImageComboBox;
    TabGenelSorgu: TFDQuery;
    TabCihazBilgisi: TFDQuery;
    DtsCihazBilgisi: TDataSource;
    TabSayimBilgisi: TFDQuery;
    DtsSayimBilgisi: TDataSource;
    TabFunction: TFDQuery;
    TabTempCihazIslem: TFDQuery;
    TabTempSayimIslem: TFDQuery;
    TabGiris: TFDQuery;
    btnKaydet: TJvNavPanelButton;
    dtpKasaOzetTarih: TcxDateEdit;
    edtAciklama: TcxTextEdit;
    lblAciklama: TcxLabel;
    TabKasaAcKapatSuzmeList: TFDQuery;
    DtsKasaAcKapatSuzmeList: TDataSource;
    pnlGenel: TPanel;
    cxButton2: TcxButton;
    cxLabel1: TcxLabel;
    cxDateEdit1: TcxDateEdit;
    cxDateEdit2: TcxDateEdit;
    pnlSagg: TPanel;
    pnlSagAltGrid: TPanel;
    cxDateEdit3: TcxDateEdit;
    pnlSplitter: TPanel;
    Panel3: TPanel;
    cxLabel5: TcxLabel;
    cxLabel3: TcxLabel;
    cmbSonGunListe: TcxImageComboBox;
    cxSplitter1: TcxSplitter;
    Panel2: TPanel;
    cmbDurum: TcxImageComboBox;
    cxLabel6: TcxLabel;
    pnlSolGrid2: TPanel;
    pnlSagPanel: TPanel;
    pnlSagGrid: TPanel;
    JvNavPanelHeader2: TJvNavPanelHeader;
    pnlSolGrid: TPanel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    GridCihazBilgileri: TcxGrid;
    GridCihazBilgileriView: TcxGridDBTableView;
    GridCihazBilgileriLevel1: TcxGridLevel;
    JvNavPanelHeader3: TJvNavPanelHeader;
    GridCihazBilgileriViewADI: TcxGridDBColumn;
    GridCihazBilgileriViewTUTAR_KAPANIS: TcxGridDBColumn;
    GridSayimBilgisi: TcxGrid;
    GridSayimBilgisiView: TcxGridDBTableView;
    GridSayimBilgisiViewADI: TcxGridDBColumn;
    GridSayimBilgisiViewTUTAR_KAPANIS: TcxGridDBColumn;
    GridSayimBilgisiLevel1: TcxGridLevel;
    GridKasaOzet: TcxGrid;
    GridKasaOzetView: TcxGridDBTableView;
    GridKasaOzetViewTIP: TcxGridDBColumn;
    GridKasaOzetViewTUR: TcxGridDBColumn;
    GridKasaOzetViewBORC: TcxGridDBColumn;
    GridKasaOzetViewALACAK: TcxGridDBColumn;
    GridKasaOzetViewKUR: TcxGridDBColumn;
    GridKasaOzetLevel1: TcxGridLevel;
    TabAcikKasaBilgi: TFDQuery;
    GridKasaAcKapatSuzmeList: TcxGrid;
    GridKasaAcKapatSuzmeListTableView: TcxGridDBTableView;
    GridKasaAcKapatSuzmeListTableViewACILIS_TARIH: TcxGridDBColumn;
    GridKasaAcKapatSuzmeListLevel1: TcxGridLevel;
    procedure KapatTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnkasabilgisiClick(Sender: TObject);
    procedure btnKasaKapatClick(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure cmbSonGunListePropertiesChange(Sender: TObject);
    procedure TabKasaAcKapatSuzmeListAfterScroll(DataSet: TDataSet);
    procedure cxSplitter1AfterClose(Sender: TObject);
    procedure cxSplitter1AfterOpen(Sender: TObject);
    procedure TabCihazBilgisiBeforePost(DataSet: TDataSet);
    procedure TabSayimBilgisiBeforePost(DataSet: TDataSet);
  private
    procedure KasaOzetikiTarihAralikBulma(BaslangicTarih,
      BitisTarih: TDateTime);
    procedure GorunumIlkGiris;
    procedure GorunumKasaActiktanSonra;
    function KasaKayitKontrol(): Boolean;
    function KasaIslemIDAl: integer;
    procedure KasaAcKapaGenelIslemListesi(Deger: String);
    procedure SuzmeModunaGecis;
    procedure TempListe;
    procedure AcikKasaninBilgileriniAlma;

    { Private declarations }
  public
    { Public declarations }
    Kasa: integer;
    KasaIslem: Integer;
  end;

const
  // CÝHAZLAR
  Nakit: Integer = 5; // NAKÝTTOPLAM TUR
  Pos: Integer = 6; // POSTOPLAM TUR
  SatisTutar: Integer = 7; // SATIÞTOPLAMTUTAR TUR
  PosIslemleri: integer = 11; // POSISLEMLERI TUR
  // SAYIMLAR
  NakitSayim: Integer = 20; // NAKÝTSAYIM TUR
  MultinetTicketSayim: integer = 30; // MULTINETTICKET TUR
  HediyeSayim: Integer = 40; // HEDÝYE TUR
  IadeSayim: Integer = 50; // IADE TUR
  AcilisTutar: Integer = 0; // AÇILIÞ TUTAR TUR
  KapanisTutar: Integer = 100; // KAPANIÞ TUTAR TUR
  // ÝADE VE HEDÝYECEKÝ ID'LER
  HediyeID: Integer = -1; // HEDÝYE ÇEKÝ ID
  IadeID: Integer = -2; // IADE ID

var
  HizliGirisKasaOzet: THizliGirisKasaOzet;

implementation

{$R *.dfm}

uses UHizliGirisAnaMenu;

procedure THizliGirisKasaOzet.KasaOzetikiTarihAralikBulma(BaslangicTarih,
  BitisTarih: TDateTime);
begin
  TabKasaOzet.Close;
  TabKasaOzet.Params[0].Value := BaslangicTarih;
  TabKasaOzet.Params[1].Value := BitisTarih;
  TabKasaOzet.Open;
end;

Procedure THizliGirisKasaOzet.KasaAcKapaGenelIslemListesi(Deger: String);
begin
  TabKasaAcKapatSuzmeList.Close;
  TabKasaAcKapatSuzmeList.SQL.Text := 'SELECT TOP ' + Deger +
    ' K.ID,K.KASAID,K.ACILIS_TARIH,K.KAPANIS_TARIH,K.ACAN_KISI,K.KAPATAN_KISI,K.ACIKLAMA,K.SUBEID ,K.ACILISTUTAR,K.DURUM'
    + #13#10 + 'FROM dbo.KASAACKAPAT K' + #13#10 +
    'INNER JOIN REHBER R ON R.ID=K.ACAN_KISI' + #13#10 +
    'INNER JOIN dbo.KULLANICI KB ON R.ID=KB.REHBERID' + #13#10 +
    'INNER JOIN dbo.REHBER RB ON RB.ID=K.KAPATAN_KISI' + #13#10 +
    'INNER JOIN REHBER RBS ON RBS.ID=K.SUBEID' + #13#10 + 'WHERE KASAID='''+IntToStr(VarsKasa)+'''' +
    #13#10 + 'AND KAPANIS_TARIH IS NOT NULL ORDER BY ACILIS_TARIH DESC';
  TabKasaAcKapatSuzmeList.Open;
  GridKasaAcKapatSuzmeListTableView.ApplyBestFit(nil);
end;

function THizliGirisKasaOzet.KasaKayitKontrol(): Boolean;
begin
  TabFunction.Close;
  TabFunction.SQL.Text := 'SELECT * FROM KASAACKAPAT WHERE KASAID=''' +IntToStr(VarsKasa) + ''' AND KAPANIS_TARIH IS NULL';
  TabFunction.Open;
  if TabFunction.RecordCount > 0 then
    result := True
  else
    result := False;
end;
procedure THizliGirisKasaOzet.AcikKasaninBilgileriniAlma();
begin
  TabAcikKasaBilgi.Close;
  TabAcikKasaBilgi.SQL.Text:='SELECT * FROM KASAACKAPAT WHERE KASAID=''' +IntToStr(VarsKasa) + ''' AND KAPANIS_TARIH IS NULL';
  TabAcikKasaBilgi.Open;
end;

function THizliGirisKasaOzet.KasaIslemIDAl(): integer;
begin
  TabFunction.Close;
  TabFunction.SQL.Text := 'SELECT * FROM KASAACKAPAT WHERE KASAID=''' +IntToStr(VarsKasa) + ''' AND KAPANIS_TARIH IS NULL';
  TabFunction.Open;
  result := TabFunction.FieldByName('ID').AsInteger;
end;

procedure THizliGirisKasaOzet.SuzmeModunaGecis();
begin
     if cxSplitter1.State = ssOpened then
   begin
    KasaOzetikiTarihAralikBulma(StartofTheDay(TabKasaAcKapatSuzmeList.FieldByName('ACILIS_TARIH').AsDateTime), EndOfTheDay(TabKasaAcKapatSuzmeList.FieldByName('ACILIS_TARIH').AsDateTime));
    GridKasaOzetView.ViewData.Expand(True);
    TabCihazBilgisi.Close;
    TabCihazBilgisi.SQL.Text:= 'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,''Yazar Kasa Nakit'' AS ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                               'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                               'WHERE KASAACKAPAT_ID=:ID AND KD.YER=5' + #13#10 +
                               'UNION' + #13#10 +
                               'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,''Yazar Kasa Pos'' AS ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                               'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                               'WHERE KASAACKAPAT_ID=:ID1 AND KD.YER=6' + #13#10 +
                               'UNION' + #13#10 +
                               'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,P.ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                               'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                               'INNER JOIN POS P ON KD.HESAP_ID=P.BANKAHESAPID' + #13#10 +
                               'WHERE KASAACKAPAT_ID=:ID2 AND KD.YER=11';
    TabCihazBilgisi.Params[0].Value := TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabCihazBilgisi.Params[1].Value := TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabCihazBilgisi.Params[2].Value := TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabCihazBilgisi.Open;

    TabSayimBilgisi.Close;
    TabSayimBilgisi.SQL.Text:= 'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,''Nakit Tutar'' AS ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                              'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                              'WHERE KASAACKAPAT_ID=:ID AND KD.YER=100' + #13#10 +
                              'UNION' + #13#10 +
							                'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,''Hediye Çeki Sayým Tutar'' AS ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                              'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                              'WHERE KASAACKAPAT_ID=:ID3 AND KD.YER=40' + #13#10 +
                              'UNION' + #13#10 +
                              'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,''Ýade Sayým Tutar'' AS ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                              'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                              'WHERE KASAACKAPAT_ID=:ID2 AND KD.YER=50' + #13#10 +
                              'UNION' + #13#10 +
							                'SELECT KD.KASAACKAPAT_ID,KD.HESAP_ID,PK.ADI,KD.TUTAR_SISTEM,KD.TUTAR_KAPANIS,KD.KUR' + #13#10 +
                              'FROM dbo.KASAACKAPAT_DETAY KD' + #13#10 +
                              'INNER JOIN PARA_KUPON PK ON KD.HESAP_ID=PK.ID' + #13#10 +
                              'WHERE KASAACKAPAT_ID=:ID1 AND KD.YER=30';
    TabSayimBilgisi.Params[0].Value :=TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabSayimBilgisi.Params[1].Value :=TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabSayimBilgisi.Params[2].Value :=TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabSayimBilgisi.Params[3].Value :=TabKasaAcKapatSuzmeList.FieldByName('ID').AsInteger;
    TabSayimBilgisi.Open;
   end
end;

procedure THizliGirisKasaOzet.TempListe();
begin
  TabCihazBilgisi.Close;
  TabCihazBilgisi.SQL.Text:='IF  EXISTS (SELECT * FROM tempdb.sys.objects WHERE name=''##TEMPPOS'' AND type=''u'')' + #13#10 +
                            'DROP TABLE ##TEMPPOS' + #13#10 +
                            'SELECT ID AS KASAACKAPAT_ID,ADI,BANKAHESAPID,KUR INTO ##TEMPPOS FROM dbo.POS' + #13#10 +
                            'ALTER TABLE ##TEMPPOS ADD TUTAR_KAPANIS MONEY' + #13#10 +
                            'ALTER TABLE ##TEMPPOS ADD YER INTEGER' + #13#10 +
                            'UPDATE ##TEMPPOS SET YER=11' + #13#10 +
                            'INSERT INTO ##TEMPPOS (ADI,KUR,TUTAR_KAPANIS,YER) VALUES (''Yazar Kasa Nakit'',''TL'',0,5)' + #13#10 +
                            'INSERT INTO ##TEMPPOS (ADI,KUR,TUTAR_KAPANIS,YER) VALUES (''Yazar Kasa Pos'',''TL'',0,6)' + #13#10 +
                            'UPDATE ##TEMPPOS SET TUTAR_KAPANIS=0' + #13#10 +
                            'UPDATE ##TEMPPOS SET BANKAHESAPID=0 WHERE YER=5' + #13#10 +
                            'UPDATE ##TEMPPOS SET BANKAHESAPID=0 WHERE YER=6' + #13#10 +
                            'UPDATE ##TEMPPOS SET BANKAHESAPID=0 WHERE YER=7' + #13#10 +
                            'SELECT * FROM ##TEMPPOS';
  TabCihazBilgisi.Open;

  TabSayimBilgisi.Close;
  TabSayimBilgisi.SQL.Text:='IF  EXISTS (SELECT * FROM tempdb.sys.objects WHERE name=''##TEMPKUP'' AND type=''u'')' + #13#10 +
                            'DROP TABLE ##TEMPKUP' + #13#10 +
                            'SELECT ID AS KASAACKAPAT_ID,TUR,ADI,KUR INTO ##TEMPKUP FROM dbo.PARA_KUPON WHERE TUR=26' + #13#10 +
                            'ALTER TABLE ##TEMPKUP ADD TUTAR_KAPANIS MONEY' + #13#10 +
                            'ALTER TABLE ##TEMPKUP ADD HESAPID INTEGER' + #13#10 +
                            'ALTER TABLE ##TEMPKUP ADD YER INTEGER' + #13#10 +
                            'INSERT INTO ##TEMPKUP (ADI,TUTAR_KAPANIS,YER) VALUES (''Nakit Tutar'',0,100)' + #13#10 +
                            'INSERT INTO ##TEMPKUP (ADI,TUTAR_KAPANIS,YER) VALUES (''Hediye Çeki Sayým Tutar'',0,40)' + #13#10 +
                            'INSERT INTO ##TEMPKUP (ADI,TUTAR_KAPANIS,YER) VALUES (''Ýade Sayým Tutar'',0,50)' + #13#10 +
                            'UPDATE ##TEMPKUP SET TUTAR_KAPANIS=0' + #13#10 +
                            'UPDATE ##TEMPKUP SET KUR=''TL''' + #13#10 +
                            'UPDATE ##TEMPKUP SET YER=30 WHERE TUR=26' + #13#10 +
                            'SELECT * FROM ##TEMPKUP';
  TabSayimBilgisi.Open;
end;

procedure THizliGirisKasaOzet.TabCihazBilgisiBeforePost(DataSet: TDataSet);
begin
  TabTempCihazIslem.Close;
  TabTempCihazIslem.SQL.Text :='UPDATE ##TEMPPOS SET TUTAR_KAPANIS=:FIYAT WHERE KASAACKAPAT_ID=:ID';
  TabTempCihazIslem.Params[0].Value := TabCihazBilgisi.FieldByName('TUTAR_KAPANIS').AsCurrency;
  TabTempCihazIslem.Params[1].Value := TabCihazBilgisi.FieldByName('KASAACKAPAT_ID').AsInteger;
  TabTempCihazIslem.ExecSQL;
end;

procedure THizliGirisKasaOzet.TabKasaAcKapatSuzmeListAfterScroll
  (DataSet: TDataSet);
begin
  SuzmeModunaGecis;
  edtAcilisTutar.Text:=TabKasaAcKapatSuzmeList.FieldByName('ACILISTUTAR').AsString;
  dtpKasaOzetTarih.Date:=TabKasaAcKapatSuzmeList.FieldByName('KAPANIS_TARIH').AsDateTime;
//  cmbAcan.EditValue:=TabKasaAcKapatSuzmeList.FieldByName('KAPATAN_KISI').AsInteger;
  cmbSubeler.EditValue:=TabKasaAcKapatSuzmeList.FieldByName('SUBEID').AsInteger;
  cmbDurum.EditValue:=TabKasaAcKapatSuzmeList.FieldByName('DURUM').AsInteger;
  edtAciklama.Text:=TabKasaAcKapatSuzmeList.FieldByName('ACIKLAMA').AsString;
end;

procedure THizliGirisKasaOzet.TabSayimBilgisiBeforePost(DataSet: TDataSet);
begin
  TabTempSayimIslem.Close;
  TabTempSayimIslem.SQL.Text := 'UPDATE ##TEMPKUP SET TUTAR_KAPANIS=:FIYAT WHERE KASAACKAPAT_ID=:ID';
  TabTempSayimIslem.Params[0].Value := TabSayimBilgisi.FieldByName('TUTAR_KAPANIS').AsCurrency;
  TabTempSayimIslem.Params[1].Value := TabSayimBilgisi.FieldByName('KASAACKAPAT_ID').AsInteger;
  TabTempSayimIslem.ExecSQL;
end;

procedure THizliGirisKasaOzet.GorunumIlkGiris();
begin
  pnlAcBilgi.Visible := True;
  pnlSolGrid.Visible := False;
  pnlSagGrid.Visible := False;
  pnlSagAltGrid.Visible := False;
  lblAciklama.Visible := False;
  edtAciklama.Visible := False;
end;

procedure THizliGirisKasaOzet.GorunumKasaActiktanSonra();
begin
  pnlSolGrid.Visible := True;
  pnlSagGrid.Visible := True;
  pnlSagAltGrid.Visible := True;
  lblAciklama.Visible := True;
  edtAciklama.Visible := True;
end;

procedure THizliGirisKasaOzet.btnKaydetClick(Sender: TObject);
var
  Kontrol: Boolean;
begin
  TabCihazBilgisi.Close;
  TabCihazBilgisi.Open;
  TabSayimBilgisi.Close;
  TabSayimBilgisi.Open;
  try
      TabGenelSorgu.Close;
      TabGenelSorgu.SQL.Text := 'INSERT INTO KASAACKAPAT (KASAID,ACILIS_TARIH,ACAN_KISI,ACIKLAMA,SUBEID,DURUM,ACILISTUTAR)'
        + 'VALUES (:KASAID,:ACILIS_TARIH,:ACAN_KISI,:ACIKLAMA,:SUBEID,:DURUM,:ACILISTUTAR)select scope_identity()';
      TabGenelSorgu.Params[0].Value := Kasa;
      TabGenelSorgu.Params[1].Value := dtpKasaOzetTarih.Date;
      TabGenelSorgu.Params[2].Value := cmbAcan.EditValue;
      TabGenelSorgu.Params[3].Value := edtAciklama.Text;
      TabGenelSorgu.Params[4].Value := cmbSubeler.EditValue;
      TabGenelSorgu.Params[5].Value := cmbDurum.EditValue;
      TabGenelSorgu.Params[6].Value := edtAcilisTutar.Text;
      TabGenelSorgu.Open;
      KasaIslem := StrToInt(TabGenelSorgu.Fields[0].AsString);
      btnKaydet.Visible := False;
      btnkasabilgisi.Visible:=True;
      btnKasaKapat.Visible:=True;
      GorunumKasaActiktanSonra;
  except

  end;
  GorunumIlkGiris;
end;

procedure THizliGirisKasaOzet.cmbSonGunListePropertiesChange(Sender: TObject);
begin
  KasaAcKapaGenelIslemListesi(cmbSonGunListe.Text);
end;

procedure THizliGirisKasaOzet.cxSplitter1AfterClose(Sender: TObject);
var
  KasaAcilmaKayit: Boolean;
begin
  KasaOzetikiTarihAralikBulma(StartofTheDay(Tablo.GENINI.BugunTrh),EndOfTheDay(Tablo.GENINI.BugunTrh));
  GridKasaOzetView.ViewData.Expand(True);
  pnlSolGrid.Visible := False;
  pnlSagGrid.Visible := False;
  pnlSagAltGrid.Visible := False;

  GridKasaAcKapatSuzmeListTableView.ApplyBestFit(nil);

  edtAcilisTutar.Enabled:=True;
  cmbAcan.Enabled:=True;
  cmbSubeler.Enabled:=True;
  cmbDurum.Enabled:=True;
  edtAciklama.Enabled:=True;
   //SÝSTEME GÝRENLERÝN BÝLGÝSÝ
  cmbAcan.EditValue := Kullanan;
  cmbSubeler.EditValue := SubeId;
  cmbSonGunListe.EditValue := 3;
  dtpKasaOzetTarih.Date := Tablo.GENINI.BugunTrhSaat;
  edtAcilisTutar.Text:='0';
  edtAciklama.Text:='';
  cmbDurum.EditValue:=1;
  //
  KasaAcilmaKayit := KasaKayitKontrol;
  //btnKaydet.Visible := True;
  if KasaAcilmaKayit = False then
  begin
    btnKaydet.Visible:=True;
    btnkasabilgisi.Visible := False;
    btnKasaKapat.Visible := False;
  end
  else
  begin
    btnKaydet.Visible:=False;
    btnkasabilgisi.Visible := True;
    btnKasaKapat.Visible := True;
    AcikKasaninBilgileriniAlma;
    edtAcilisTutar.Text := TabAcikKasaBilgi.FieldByName('ACILISTUTAR').AsString;
    cmbAcan.EditValue:=TabAcikKasaBilgi.FieldByName('ACAN_KISI').AsInteger;
    cmbSubeler.EditValue:=TabAcikKasaBilgi.FieldByName('SUBEID').AsInteger;
    cmbDurum.EditValue:=TabAcikKasaBilgi.FieldByName('DURUM').AsInteger;
  end;
end;

procedure THizliGirisKasaOzet.cxSplitter1AfterOpen(Sender: TObject);
var
  KasaAcilmaKayit: Boolean;
begin
  GridKasaAcKapatSuzmeListTableView.ApplyBestFit(nil);
  pnlSolGrid.Visible := True;
  pnlSagGrid.Visible := True;
  pnlSagAltGrid.Visible := True;

  btnkasabilgisi.Visible := False;
  btnKasaKapat.Visible := False;
  btnKaydet.Visible:=False;

  TabKasaAcKapatSuzmeList.Close;
  TabKasaAcKapatSuzmeList.Open;

  edtAcilisTutar.Enabled:=False;
  cmbAcan.Enabled:=False;
  cmbSubeler.Enabled:=False;
  cmbDurum.Enabled:=False;
  edtAciklama.Enabled:=False;

  SuzmeModunaGecis;
end;
procedure THizliGirisKasaOzet.btnkasabilgisiClick(Sender: TObject);
begin
  cxSplitter1.CloseSplitter;
  KasaOzetikiTarihAralikBulma(StartofTheDay(Tablo.GENINI.BugunTrh), EndOfTheDay(Tablo.GENINI.BugunTrh));
  GridKasaOzetView.ViewData.Expand(True);
  pnlSolGrid.Visible := True;
  pnlSagGrid.Visible := True;
  pnlSagAltGrid.Visible := True;
  TempListe;
end;

procedure THizliGirisKasaOzet.btnKasaKapatClick(Sender: TObject);
var
  I: integer;
  Kontrol: Boolean;
begin
  if TabSayimBilgisi.State = dsEdit then TabSayimBilgisi.Post;
  if TabCihazBilgisi.State=dsEdit then TabCihazBilgisi.Post;

  edtAcilisTutar.Text := '0';
  Kontrol := KasaKayitKontrol();
  if Kontrol = False then
  begin
    TabGenelSorgu.Close;
    TabGenelSorgu.SQL.Text :='UPDATE KASAACKAPAT SET KAPANIS_TARIH=:KAPANISTARIH,KAPATAN_KISI=:KAPATANKISI,ACIKLAMA=:ACIKLAMA WHERE ID=:ID';
    TabGenelSorgu.Params[0].Value := Tablo.GENINI.BugunTrhSaat;
    TabGenelSorgu.Params[1].Value := cmbAcan.EditValue;
    TabGenelSorgu.Params[2].Value := Trim(edtAciklama.Text);
    TabGenelSorgu.Params[3].Value := KasaIslem;
    TabGenelSorgu.ExecSQL;
  end
  else
  begin
    KasaIslem := KasaIslemIDAl;
    TabGenelSorgu.Close;
    TabGenelSorgu.SQL.Text := 'UPDATE KASAACKAPAT SET KAPANIS_TARIH=:KAPANISTARIH,KAPATAN_KISI=:KAPATANKISI,ACIKLAMA=:ACIKLAMA WHERE ID=:ID';
    TabGenelSorgu.Params[0].Value := Tablo.GENINI.BugunTrhSaat;
    TabGenelSorgu.Params[1].Value := cmbAcan.EditValue;
    TabGenelSorgu.Params[2].Value := Trim(edtAciklama.Text);
    TabGenelSorgu.Params[3].Value := KasaIslem;
    TabGenelSorgu.ExecSQL;
  end;
  // KASA KAPATMA TEMP AKTARIMLAR
  TabTempCihazIslem.Close;
  TabTempCihazIslem.SQL.Text := 'SELECT * FROM ##TEMPPOS';
  TabTempCihazIslem.Open;
  for I := 0 to TabTempCihazIslem.RecordCount - 1 do
  begin
    try
      TabGenelSorgu.Close;
      TabGenelSorgu.SQL.Text :=
        'INSERT INTO KASAACKAPAT_DETAY(KASAACKAPAT_ID,YER,HESAP_ID,TUTAR_SISTEM,TUTAR_KAPANIS,KUR)'
        + 'VALUES (:KASAACKAPAT_ID,:YER,:HESAP_ID,:TUTAR_SISTEM,:TUTAR_KAPANIS,:KUR)';
      TabGenelSorgu.Params[0].Value := KasaIslem;
      TabGenelSorgu.Params[1].Value := TabTempCihazIslem.FieldByName('YER')
        .AsInteger;
      if TabTempCihazIslem.FieldByName('YER').AsInteger = Nakit then
        TabGenelSorgu.Params[2].Value := Kasa
      else if TabTempCihazIslem.FieldByName('YER').AsInteger = Pos then
        TabGenelSorgu.Params[2].Value := 0 // SORULACAK
      else if TabTempCihazIslem.FieldByName('YER').AsInteger = SatisTutar then
        TabGenelSorgu.Params[2].Value := 0 // SORULACAK
      else if TabTempCihazIslem.FieldByName('YER').AsInteger = PosIslemleri then
        TabGenelSorgu.Params[2].Value := TabTempCihazIslem.FieldByName('BANKAHESAPID').AsInteger;
      TabGenelSorgu.Params[3].Value := 0;
      TabGenelSorgu.Params[4].Value := TabTempCihazIslem.FieldByName('TUTAR_KAPANIS').AsString;
      TabGenelSorgu.Params[5].Value := 'TL';
      TabGenelSorgu.ExecSQL;
    except

    end;
    TabTempCihazIslem.Next;
  end;

  TabTempSayimIslem.Close;
  TabTempSayimIslem.SQL.Text := 'SELECT * FROM ##TEMPKUP';
  TabTempSayimIslem.Open;
  for I := 0 to TabTempSayimIslem.RecordCount - 1 do
  begin
    try
      TabGenelSorgu.Close;
      TabGenelSorgu.SQL.Text :=
        'INSERT INTO KASAACKAPAT_DETAY(KASAACKAPAT_ID,YER,HESAP_ID,TUTAR_SISTEM,TUTAR_KAPANIS,KUR)'
        + 'VALUES (:KASAACKAPAT_ID,:YER,:HESAP_ID,:TUTAR_SISTEM,:TUTAR_KAPANIS,:KUR)';
      TabGenelSorgu.Params[0].Value := KasaIslem;
      TabGenelSorgu.Params[1].Value := TabTempSayimIslem.FieldByName('YER')
        .AsInteger;

      if TabTempSayimIslem.FieldByName('YER').AsInteger = KapanisTutar then
        TabGenelSorgu.Params[2].Value := Kasa // SORULACAK
//      else if TabTempSayimIslem.FieldByName('YER').AsInteger = NakitSayim then
//        TabGenelSorgu.Params[2].Value := Kasa
      else if TabTempSayimIslem.FieldByName('YER').AsInteger = HediyeSayim then
        TabGenelSorgu.Params[2].Value := HediyeID
      else if TabTempSayimIslem.FieldByName('YER').AsInteger = IadeSayim then
        TabGenelSorgu.Params[2].Value := IadeID
      else if TabTempSayimIslem.FieldByName('YER').AsInteger = MultinetTicketSayim
      then
        TabGenelSorgu.Params[2].Value := TabTempSayimIslem.FieldByName('KASAACKAPAT_ID').AsInteger;
      TabGenelSorgu.Params[3].Value := 0;
      TabGenelSorgu.Params[4].Value := TabTempSayimIslem.FieldByName('TUTAR_KAPANIS').AsString;
      TabGenelSorgu.Params[5].Value := 'TL';
      TabGenelSorgu.ExecSQL;
    except

    end;
    TabTempSayimIslem.Next;
  end;
   Kontrol := KasaKayitKontrol();
   btnKaydet.Visible:=False;
   btnkasabilgisi.Visible:=False;
   btnKasaKapat.Visible:=False;
   GorunumIlkGiris;
   btnKaydet.Visible:=True;
end;

procedure THizliGirisKasaOzet.FormCreate(Sender: TObject);
var
  KasaAcilmaKayit: Boolean;
begin
  GridKasaAcKapatSuzmeListTableView.ApplyBestFit(nil);
  WindowState := wsMaximized;
  cxSplitter1.CloseSplitter;
  TempListe;
  cmbSonGunListe.EditValue := 3;

  dtpKasaOzetTarih.Date := Tablo.GENINI.BugunTrhSaat;
  GridKasaOzetView.ViewData.Expand(True);
  cmbSubeler.Properties.Items := Tablo.imgComboboxInit('SELECT ID,FIRMA FROM dbo.REHBER WHERE ID<0').Items;
  cmbAcan.Properties.Items := Tablo.imgComboboxInit('SELECT R.ID,R.FIRMA FROM dbo.KULLANICI K INNER JOIN REHBER R ON K.REHBERID=R.ID AND R.DURUM=1').Items;
  cmbAcan.EditValue := Kullanan;
  cmbSubeler.EditValue := SubeId;
  if RolID = '-1' then
    cmbSubeler.Enabled := True
  else
  cmbSubeler.Enabled := False;
  edtAcilisTutar.Text := '0';
  KasaAcilmaKayit := KasaKayitKontrol;
  btnKaydet.Visible := True;
  if KasaAcilmaKayit = False then
  begin
    GorunumIlkGiris;
    btnKaydet.Visible:=True;
    btnkasabilgisi.Visible:=False;
    btnKasaKapat.Visible:=False;
  end
  else
  begin
    GorunumKasaActiktanSonra;
    btnkasabilgisi.Visible:=True;
    btnKasaKapat.Visible:=True;
    btnKaydet.Visible := False;
    GorunumIlkGiris;

    AcikKasaninBilgileriniAlma;
    edtAcilisTutar.Text := TabAcikKasaBilgi.FieldByName('ACILISTUTAR').AsString;
    cmbAcan.EditValue:=TabAcikKasaBilgi.FieldByName('ACAN_KISI').AsInteger;
    cmbSubeler.EditValue:=TabAcikKasaBilgi.FieldByName('SUBEID').AsInteger;
    cmbDurum.EditValue:=TabAcikKasaBilgi.FieldByName('DURUM').AsInteger;

  end;
end;

procedure THizliGirisKasaOzet.FormShow(Sender: TObject);
//var
 // KasaAcilmaKayit: Boolean;
begin
//  GridKasaAcKapatSuzmeListTableView.ApplyBestFit(nil);
//
//  TabCihazBilgisi.Close;
//  TabCihazBilgisi.Open;
//  TabSayimBilgisi.Close;
//  TabSayimBilgisi.Open;
//  KasaAcilmaKayit := KasaKayitKontrol;
//  if KasaAcilmaKayit = False then
//  begin
//    GorunumIlkGiris;
//
//  end
//  else
//  begin
//    GorunumKasaActiktanSonra;
//    btnKaydet.Visible := False;
//    TabGenelSorgu.Close;
//    TabGenelSorgu.SQL.Text := 'SELECT * FROM KASAACKAPAT WHERE KASAID=''' +
//      IntToStr(Kasa) + ''' AND KAPANIS_TARIH IS NULL';
//    TabGenelSorgu.Open;
//    edtAcilisTutar.Text := TabGenelSorgu.FieldByName('ACILISTUTAR').AsString;
//
//  end;
end;

procedure THizliGirisKasaOzet.KapatTusClick(Sender: TObject);
begin
  Close;
end;

end.



