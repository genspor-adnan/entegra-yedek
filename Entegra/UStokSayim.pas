//Stok sayım için kullanılan sp ler
//  tek tek eklerken : sp_StokSayim ve  toplu eklerken : fn_StokSayimButun
unit UStokSayim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxStyles, dxSkinsCore, dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, StdCtrls, ComCtrls, ToolWin,
  cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, Menus,
  cxLookAndFeelPainters, cxButtons, cxCheckBox, cxDBEdit, DBCtrls,
  cxImageComboBox, FireDAC.Comp.Client, dxSkinLondonLiquidSky, cxCurrencyEdit, frxClass,
  PrjConst, FetaKurulusSiniflari, Fetautil, frxDBSet, UGentegreFrameYonetimi,
  Utablo, UStokHizmetAra, dxSkinLiquidSky, cxLookAndFeels, dxCore,
  cxDateUtils, cxNavigator, UBekletme, UIzleme, UStokLokasyon, cxImage,
  cxSpinEdit, ComObj, cxLabel,DateUtils, cxTimeEdit, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  frCoreClasses, FireDAC.Comp.DataSet;

type
  SayimKontrolu = record
    sonuc: Boolean;
    aciklama: string end;

  type
    TStokSayimDlg = class(TForm, IPopupDialog)
      pnlSol: TPanel;
      pnlSag: TPanel;
      grpFiltre: TGroupBox;
      pnlSagUst: TPanel;
      pnlSayimAksiyon: TPanel;
      tvSayimTutanak: TcxGridDBTableView;
      gridSayimTutanakLevel1: TcxGridLevel;
      gridSayimTutanak: TcxGrid;
      ToolBar5: TToolBar;
      btnSayimKalemEkle: TToolButton;
      btnSayimKalemSil: TToolButton;
      gridSayimListe: TcxGrid;
      tvSayimListe: TcxGridDBTableView;
      cxGridLevel1: TcxGridLevel;
      dateBaslangic: TcxDateEdit;
      dateBitis: TcxDateEdit;
      Label1: TcxLabel;
      Label2: TcxLabel;
      cbSayimDepo: TcxDBImageComboBox;
      lbSayimId: TDBText;
      dateSayimTarih: TcxDBDateEdit;
      checkSayimTamamlandi: TcxDBCheckBox;
      cbSayimYapan: TcxDBImageComboBox;
      cbSayimOnaylayan: TcxDBImageComboBox;
      Label3: TcxLabel;
      Label4: TcxLabel;
      Label5: TcxLabel;
      Label6: TcxLabel;
      Label7: TcxLabel;
      clmSayimListeDepo: TcxGridDBColumn;
      tvSayimListeColumn3: TcxGridDBColumn;
      clmSayimStokKod: TcxGridDBColumn;
      clmSayimStokAdi: TcxGridDBColumn;
      clmSayimSistemMiktar: TcxGridDBColumn;
      clmSayimSayimMiktar: TcxGridDBColumn;
      btnKalemKaydet: TToolButton;
      btnKalemVazgec: TToolButton;
      BtnTumStoklariEkle: TcxButton;
      TabSayTutanak: TFDQuery;
      dtsSayimTutanak: TDataSource;
      tabSayimKalemleri: TFDQuery;
      dtsSayimKalemleri: TDataSource;
      pmSayimTutanak: TPopupMenu;
      mnStokDurumGuncelle: TMenuItem;
      clmSayimBirimFiyat: TcxGridDBColumn;
      clmSayimTutar: TcxGridDBColumn;
      clmSayimStokBirim: TcxGridDBColumn;
      BtnTumKartlariSil: TcxButton;
      YaziciYaz: TToolButton;
      frxSayimKalemleri: TfrxDBDataset;
      cxLabel1: TcxLabel;
      cbFiyatAdi: TcxDBImageComboBox;
      tvSayimTutanakBARKOD: TcxGridDBColumn;
      tvSayimTutanakMARKA: TcxGridDBColumn;
      tvSayimTutanakGRUBU: TcxGridDBColumn;
      PopupMenuYaz: TPopupMenu;
      BaskiOnizlemeMenu: TMenuItem;
      YazcyaYazdr1: TMenuItem;
      N1: TMenuItem;
      Gnder1: TMenuItem;
      PDF1: TMenuItem;
      Word1: TMenuItem;
      Excel2: TMenuItem;
      CSV1: TMenuItem;
      ext1: TMenuItem;
      HTML2: TMenuItem;
      JPG1: TMenuItem;
      N2: TMenuItem;
      EMail1: TMenuItem;
      N3: TMenuItem;
      frxSayimTutanak: TfrxDBDataset;
      btnDosyadan: TToolButton;
      PopupDosyadan: TPopupMenu;
      ExcelDosya1: TMenuItem;
      SaymCihaz1: TMenuItem;
      ToolBar1: TToolBar;
      YeniSayim: TToolButton;
      SayimSil: TToolButton;
      SayimKaydet: TToolButton;
      SayimIptal: TToolButton;
    OpenDialog2: TOpenDialog;
    cxImage1: TcxImage;
    EditAra: TcxTextEdit;
    cxLabel2: TcxLabel;
    ComboSatisDurumu: TcxDBImageComboBox;
    tvSayimDEGISTIRMETARIHI: TcxGridDBColumn;
    cxLabel3: TcxLabel;
    cxDBTimeEdit1: TcxDBTimeEdit;
    PopupMenu1: TPopupMenu;
    IzlemBilgisiDuzenleMenu: TMenuItem;
    N4: TMenuItem;
    TumKaytlarnSaymMiktarlarnSfrAtaMenu: TMenuItem;
    tvSayimTutanakFARK: TcxGridDBColumn;
      procedure dtsSayimTutanakStateChange(Sender: TObject);
      procedure YeniSayimClick(Sender: TObject);
      procedure btnSayimKalemSilClick(Sender: TObject);
      procedure btnSayimKalemEkleClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure btnKalemKaydetClick(Sender: TObject);
      procedure btnKalemVazgecClick(Sender: TObject);
      procedure BtnTumStoklariEkleClick(Sender: TObject);
      procedure SayimSilClick(Sender: TObject);
      procedure TabSayTutanakNewRecord(DataSet: TDataSet);
      procedure tabSayimKalemleriNewRecord(DataSet: TDataSet);
      procedure dtsSayimKalemleriStateChange(Sender: TObject);
      procedure TabSayTutanakAfterScroll(DataSet: TDataSet);
      procedure mnStokDurumGuncelleClick(Sender: TObject);
      procedure TabSayTutanakBeforePost(DataSet: TDataSet);
      procedure pmSayimTutanakPopup(Sender: TObject);
      procedure BtnTumKartlariSilClick(Sender: TObject);
      procedure SeriNoDelete(StokID:integer;SeriNo:string);
      procedure SeriNoInsert(StokID:integer;SeriNo:string);
      procedure tabSayimKalemleriBeforePost(DataSet: TDataSet);
      procedure TabSayTutanakAfterPost(DataSet: TDataSet);
      procedure FaturaSayimFisiSil;
      function FatBaslikBul:integer;
      function EkranAdiAl: string;
      procedure YazdirmayaHazirla(AFastReport: TfrxReport);
      procedure BaskiOnizlemeMenuClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure tvSayimTutanakCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
      procedure FaturaSayimFisiOlusturGuncelle;
      procedure FaturaSayimFisiSatirlariniOlusturGuncelle(sayimGirfisfatbasid:integer;sayimCikfisfatbasid:integer);
      procedure lbSayimTipiClick(Sender: TObject);
      procedure SayimlariListele;
      procedure dateBitisPropertiesCloseUp(Sender: TObject);
      procedure TabSayTutanakBeforeDelete(DataSet: TDataSet);
      procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
      procedure TuslariDuzenle;
      procedure TabSayTutanakAfterOpen(DataSet: TDataSet);
      procedure ExcelDosya1Click(Sender: TObject);
      procedure SaymCihaz1Click(Sender: TObject);
      procedure SayimKaydetClick(Sender: TObject);
      procedure SayimIptalClick(Sender: TObject);
    procedure tabSayimKalemleriBeforeDelete(DataSet: TDataSet);
    procedure tabSayimKalemleriAfterPost(DataSet: TDataSet);
    procedure EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure IzlemBilgisiDuzenleMenuClick(Sender: TObject);
    procedure TumKaytlarnSaymMiktarlarnSfrAtaMenuClick(Sender: TObject);

    private
      BekletDlg: TBekletmeDlg;
      IzlemDlg:TIzlemeDlg;
      LokasyonDlg:TStokLokasyonDlg;
      { Private declarations }
    public

      { Public declarations }
    end;

  var
    StokSayimDlg: TStokSayimDlg;
    sayimKontrolSonucu: SayimKontrolu;
    oncekisayimmiktar: Double;
    AraDlg: TStokHizmetAraDlg;
    ExcelStokId,ButtonSelect :integer; // ExcelStokId =Eğer dosyadan aktarım ise yeni eklenen stokIdyi alıyor..    buttonSelect=messagedlg'den donen sonuc

implementation

Uses  UAnaForm,UHizmetAra, UFastRap, URaporAraclari, UGenelAnaSekmeFrame,FetaClassExtensions,UGirisKutusuEx,LocOnFly,UKategori, UExceldenVeriAl, UVeriMotor;
{$R *.dfm}

procedure TStokSayimDlg.SayimlariListele;
begin
  TabloYenile(TabSayTutanak, [FormatDateTime('yyyy-mm-dd 00:00', dateBaslangic.Date), FormatDateTime('yyyy-mm-dd 23:59', dateBitis.Date)]);
end;

procedure  TStokSayimDlg.FaturaSayimFisiSatirlariniOlusturGuncelle(sayimGirfisfatbasid:integer;sayimCikfisfatbasid:integer);
var
  LokasyonKullan:boolean;
  SatirMiktar:extended;
  KulFatbasID, SatirID, RehberId:integer;
  BelgeNo: TBelgeNo;
  KocanNo: integer;
  GirDepoID,CikDepoID:variant;
  IslemTur, IslemTip, GirDepo, CikDepo : smallint;
  function FiseSatirEkle(SayimKalemID:integer; Miktar : Real):Integer;
  var MiktarStr : String[50];
  begin
     if KulFatbasID = 0 then begin
        KocanNo := KocannoBul(IslemTur);
        BelgeNo := SiradakiBelgeNumarasi(IslemTur, Tablo.GENINI.BugunTrhSaat);
        Tablo.TablodanSorguAc(0,'select ID from REHBERILETISIM where REHBERID=-1 order by VARSAYILAN desc');
        RehberId := -1;
        TabloYenile(Tablo.tabCariBilgileri, [RehberId,Tablo.Query0.FieldByName('ID').AsInteger]);
        KulFatbasID := StrToIntDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO FATBASLIK (TARIH, KOCANNO, FATURANO, TUR, TIPI, REHBERID,DURUM,DOVIZKUR, ACIK_KAPALI, EKSTREDEKULLAN, GIRISKAYNAK, YERI,YERID, ANAKAYITID, '+
                  ' FATURATARIH, GIRISDEPO, CIKISDEPO, EKLEYEN, EKLEMETARIHI , KDVDURUM, KUR, DOVIZ_CINSI, RAPORDOVIZ, FATURADOVIZI,SUBEID, BASLIK, ADRES, ILCE, IL, VD, VNO ) '+
                  ' VALUES ('''+formatdatetime('yyyy-mm-dd hh:nn:ss', TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime)+''', '+inttostr(KocanNo)+','''+BelgeNo.BelgeNo+''','+
                  IntToStr(IslemTur)+','+IntToStr(IslemTip)+', -1,0,1.0,0,0,1,99,'+TabSayTutanak.FieldByName('ID').AsString+','+TabSayTutanak.FieldByName('ID').AsString+','''+formatdatetime('yyyy-mm-dd hh:nn:ss', TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime)+''',  '+
                  IntToStr(GirDepo)+','+IntToStr(CikDepo)+','+Kullanan+', GETDATE(), ''Hariç'','''+CariDoviz+''','''+CariDoviz+''','''+CariDoviz+''','''+CariDoviz+''','+
                  '0, &BASLIK, &ADRES, &ILCE, &IL, &VD, &VNO) SELECT ID = SCOPE_IDENTITY() ',
                  ['&BASLIK', '&ADRES', '&ILCE', '&IL', '&VD', '&VNO'], [Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString,Tablo.tabCariBilgileri.FieldByName('ADRES').AsString,
                  Tablo.tabCariBilgileri.FieldByName('ILCE').AsString, Tablo.tabCariBilgileri.FieldByName('IL').AsString,
                  Tablo.tabCariBilgileri.FieldByName('VERGIDAI').AsString, Tablo.tabCariBilgileri.FieldByName('VERGINO').AsString],True),0);


              //    ''+Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString+''', '''+Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+''','+
              //    ''+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+''','''+Tablo.tabCariBilgileri.FieldByName('IL').AsString+''', '+
              //    ''+Tablo.tabCariBilgileri.FieldByName('VERGIDAI').AsString+''','''+Tablo.tabCariBilgileri.FieldByName('VERGINO').AsString+''','+
              //    IntToStr(SubeId)+' ) SELECT ID = SCOPE_IDENTITY() ',[],[],True),0);
        if IslemTur = 4 then
           sayimCikfisfatbasid := KulFatbasID
        else
           sayimGirfisfatbasid := KulFatbasID;
     end;
     MiktarStr := StringReplace(FloatToStr(Miktar), ',', '.', [rfReplaceAll]);
     Tablo.TablodanSorguAc(2, ' INSERT INTO FATURA  (FATBASID, REHBERID, TUR, URUNID,  ADET, BIRIM, MIKTAR, BIRIMFIYAT,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI, TUTAR,DOVIZ_TUTARI, KDV, IZLEME, KUR,DOVIZ_KURU,  YERI, YERID,DEGISTIRMETARIHI,SUBEID) '+
                                ' SELECT '+inttostr(KulFatbasID)+',-1,1,STOKID,ADET='+MiktarStr+','+
                                ' S.ANABIRIM, MIKTAR='+MiktarStr+', SSK.BIRIMFIYAT,SSK.BIRIMFIYAT,1.0, '+
                                ' TUTAR='+MiktarStr+'*BIRIMFIYAT,DOVIZ_TUTARI='+MiktarStr+'*BIRIMFIYAT,S.KDV,S.IZLEME,'''+CariDoviz+''','''+CariDoviz+''', 120, SSK.ID,SSK.DEGISTIRMETARIHI,'+IntToStr(SubeId)+
                                ' FROM STOKSAYIMKALEMLERI SSK INNER JOIN STOKLAR S ON SSK.STOKID = S.ID '+
                                ' WHERE SSK.ID = '+ IntToStr(SayimKalemID) +' select scope_identity()');
     Result := Tablo.Query2.Fields[0].AsInteger;
  end;

  procedure IzlemVar(SayimKalemID:integer; GirenCikan:char);
  begin
     //önce bakalım eksik var mı yanı fiş çıkışı olacak                                                                                       //  > veya <
     Tablo.TablodanSorguAc(7, 'select abs(sum(KALAN)) FROM STOKIZLEME WHERE BELGETUR=99 and SATIRID='+IntToStr(SayimKalemID)+ ' and KALAN '+GirenCikan+' 0');
     if Tablo.Query7.Fields[0].AsFloat > 0 then   // toplam çıkan lotlar için ön tarafa adet girilmeli
         SatirID := FiseSatirEkle(tabSayimKalemleri.FieldByName('ID').AsInteger, Tablo.Query7.Fields[0].AsFloat);

     Tablo.TablodanSorguAc(8, 'select SI.ID, SI.STOKID,SERINO, LOTNO, SKT, URT, KALAN = ABS(KALAN), DURUM= SI.ADET '+
                              'from STOKIZLEME SI inner join [STOKSERILOT] SSL ON SI.SERILOTID=SSL.ID  '+
                              'where BELGETUR=99 and SATIRID='+IntToStr(SayimKalemID)+ ' and KALAN '+GirenCikan+' 0');
     Tablo.IzlemBilgisiKaydet(Tablo.Query8, IslemTur,IslemTip, 0, KulFatbasID, SatirID, tabSayimKalemleri.FieldByName('IZLEME').AsInteger, GirDepo, CikDepo, True);


  end;

  procedure UpdateBaslikToplamlar(KulFatbasID : integer);
  begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:= 'UPDATE FATBASLIK SET FATURA_MATRAHI = ARATOPLAM,KDV_TUTARI = KDV_MATRAHI, FATURA_TUTARI = FATURATOPLAMI, DOVIZ_TUTARI= FATURATOPLAMI FROM FATBASLIK FB INNER JOIN  ';
      Tablo.Query1.SQL.Add(' (SELECT FATBASID, ARATOPLAM = isnull(SUM(ROUND(TUTAR,2)),0) , ');
      Tablo.Query1.SQL.Add(' KDV_MATRAHI = ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0),2), ');
      Tablo.Query1.SQL.Add(' FATURATOPLAMI = isnull(SUM(ROUND(TUTAR,2)),0)  ');
      Tablo.Query1.SQL.Add(' FROM FATURA WHERE FATBASID = '+inttostr(KulFatbasID)+'  GROUP BY FATBASID ) AS B ');
      Tablo.Query1.SQL.Add(' ON FB.ID = B.FATBASID ' );
      Tablo.Query1.SQL.Add(' WHERE FB.ID ='+inttostr(KulFatbasID)+' ');
      Tablo.Query1.ExecSQL;
  end;
begin
  if BekletDlg <> nil then
     FreeAndNil(BekletDlg);
  Application.CreateForm(TBekletmeDlg, BekletDlg);
  BekletDlg.cxProgressBar1.Position := 0;
  BekletDlg.Caption := 'Sayım İşlemi Tamamlanırken Lütfen Bekleyiniz...';
  BekletDlg.Show;


  LokasyonKullan := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_LokasyonVar,False);
  tabSayimKalemleri.FetchAll;
  tabSayimKalemleri.First;
  while not tabSayimKalemleri.Eof do begin  //fatura satırlarını insert ediyoruz..

    BekletDlg.cxProgressBar1.Position := ABS(100.0*(tabSayimKalemleri.RecNo/tabSayimKalemleri.RecordCount));
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := tabSayimKalemleri.FieldByName('KOD').AsString+' - '+tabSayimKalemleri.FieldByName('AD').AsString;
    BekletDlg.LabelUstTaraf.Update;

    if (tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsString<>'')and(tabSayimKalemleri.FieldByName('SISTEMDEKIMIKTAR').AsFloat<>tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsFloat) then begin
       //önce bakıyoruz izlem var mı
       //eğer izlem varsa bir kalemin hem lot eksikleri hem de fazlaları olabilir..
       if tabSayimKalemleri.FieldByName('IZLEME').AsInteger > 0 then begin
           //sayım eksiği çıkış fişine girilecek
           KulFatbasID := sayimCikfisfatbasid;
           IslemTur := 4; IslemTip := 16; GirDepo := 0; CikDepo := TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger;
           IzlemVar(tabSayimKalemleri.FieldByName('ID').AsInteger, '<');

           //sayım fazlası giriş fişine girilecek
           KulFatbasID := sayimGirfisfatbasid;
           IslemTur := 3; IslemTip := 17; GirDepo := TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger; CikDepo := 0;
           IzlemVar(tabSayimKalemleri.FieldByName('ID').AsInteger, '>');
       end
       else begin //İzlem yooook
           if tabSayimKalemleri.FieldByName('SISTEMDEKIMIKTAR').AsFloat>tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsFloat then begin
              //sayım eksiği çıkış fişine girilecek
              KulFatbasID := sayimCikfisfatbasid;
              IslemTur := 4; IslemTip := 16;
              GirDepo := 0; CikDepo := TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger;
           end else begin
              //sayım fazlası giriş fişine girilecek
              KulFatbasID := sayimGirfisfatbasid;
              IslemTur := 3; IslemTip := 17;
              GirDepo := TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger; CikDepo := 0;
           end;
                         //   ABS(ISNULL(SAYIMMIKTAR,0)-ISNULL(SISTEMDEKIMIKTAR,0))
          SatirID := FiseSatirEkle(tabSayimKalemleri.FieldByName('ID').AsInteger, Abs(tabSayimKalemleri.FieldByName('SISTEMDEKIMIKTAR').AsFloat-tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsFloat));
      end;

      //izleme ve lokasyon insert edilecek..
    {  if tabSayimKalemleri.FieldByName('IZLEME').AsInteger>0 then begin
         Tablo.TablodanSorguAc(8, 'select SI.ID, SI.STOKID,SERINO, LOTNO, SKT, URT, KALAN = ABS(KALAN), DURUM= SI.ADET '+
                                  'from STOKIZLEME SI inner join [STOKSERILOT] SSL ON SI.SERILOTID=SSL.ID  '+
                                  'where BELGETUR=99 and SATIRID='+tabSayimKalemleri.FieldByName('ID').AsString + ' and ABS(KALAN) > 0');
         Tablo.IzlemBilgisiKaydet(Tablo.Query8, IslemTur,IslemTip, 0, KulFatbasID, SatirID, tabSayimKalemleri.FieldByName('IZLEME').AsInteger, GirDepo, CikDepo, True);
      end;

      {if tabSayimKalemleri.FieldByName('IZLEME').AsInteger>0 then begin
        //o depodaki eski SERINO bilgileri için bir sıfırlama yapılıcak..
        //herzaman giriş depo kullanılacak, gerekir ise - giriş yapılacak..
        Tablo.Query5.Close;
        Tablo.Query5.SQL.Text := ' declare @DepoID int declare @StokID int set @DepoID='+VarToStr(cbSayimDepo.EditValue)+' set @StokID='+tabSayimKalemleri.FieldByName('STOKID').AsString;
        Tablo.Query5.SQL.Add('INSERT INTO STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,IZLEMID,SERINO,LOTNO,SKT,MIKTAR)');
        Tablo.Query5.SQL.Add('select STOKID,'+IntToStr(KasaTur_StokSayimFisi)+','+IntToStr(KulFatbasID)+','+Tablo.Query2.Fields[0].AsString+',');
        Tablo.Query5.SQL.Add( tabSayimKalemleri.FieldByName('IZLEME').AsString+',SERINO,LOTNO,SKT,');
        Tablo.Query5.SQL.Add(' MIKTAR=isnull((select SUM(SI2.MIKTAR)from STOKIZLEME SI2 where SI2.DURUM=1 and SI2.CIKISDEPO=@DepoID and SI2.STOKID=SI1.STOKID and SI1.SKT=SI2.SKT ');
        Tablo.Query5.SQL.Add('   and SI1.IZLEMID=SI2.IZLEMID and SI1.SERINO=SI2.SERINO and isnull(SI2.LOTNO,'''')=isnull(SI1.LOTNO,'''')),0.0)');
        Tablo.Query5.SQL.Add('  -isnull((select SUM(SI2.MIKTAR)from STOKIZLEME SI2 where SI2.DURUM=1 and SI2.GIRISDEPO=@DepoID and SI2.STOKID=SI1.STOKID and SI1.SKT=SI2.SKT ');
        Tablo.Query5.SQL.Add('   and SI1.IZLEMID=SI2.IZLEMID and SI1.SERINO=SI2.SERINO and isnull(SI2.LOTNO,'''')=isnull(SI1.LOTNO,'''')),0.0)');
        Tablo.Query5.SQL.Add('from STOKIZLEME SI1');
        Tablo.Query5.SQL.Add('where SI1.STOKID=@StokID and SI1.DURUM=1');
        Tablo.Query5.SQL.Add('group by SI1.STOKID,SI1.IZLEMID,SI1.SKT,SI1.LOTNO,SI1.SERINO,SI1.IZLEMTUR');
        Tablo.Query5.ExecSQL;
        //sayılanlar da yeniden giriş olarak yazılacak..
        veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,IZLEMTUR,MIKTAR,IZLEMID,SERINO,LOTNO,SKT,DURUM)'+
                                          'select STOKID,BELGETUR,'+IntToStr(KulFatbasID)+','+Tablo.Query2.Fields[0].AsString+',GIRISDEPO,0,IZLEMTUR,MIKTAR,IZLEMID,SERINO,LOTNO,SKT,1 from STOKIZLEME '+
                                          'where DURUM=0 and BELGETUR=99 and BASLIKID='+TabSayTutanak.FieldByName('ID').AsString+' and SATIRID='+tabSayimKalemleri.FieldByName('ID').AsString,[],[]);

      end;}
      if LokasyonKullan then begin
        //o depodaki eski lokasyon bilgileri için bir sıfırlama yapılıcak..
        Tablo.Query6.Close;
        Tablo.Query6.SQL.Text := 'INSERT INTO STOKLOKASYON(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,MIKTAR,GIRISLOKASYONID,CIKISLOKASYONID,DURUM)';
        Tablo.Query6.SQL.Add('select '+tabSayimKalemleri.FieldByName('STOKID').AsString+','+IntToStr(KasaTur_StokSayimFisi)+','+IntToStr(KulFatbasID)+','+Tablo.Query2.Fields[0].AsString+','+VarToStr(cbSayimDepo.EditValue)+',0,MIKTAR=-Miktar,GIRISLOKASYONID=Lokasyon,0,1');
        Tablo.Query6.SQL.Add('from [dbo].[fn_STOK_LOKASYON_DURUM] ('+tabSayimKalemleri.FieldByName('STOKID').AsString+','+VarToStr(cbSayimDepo.EditValue)+')');
        Tablo.Query6.ExecSQL;
        //herzaman giriş depo kullanılacak, gerekir ise - giriş yapılacak..
        veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKLOKASYON(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,MIKTAR,GIRISLOKASYONID,CIKISLOKASYONID,DURUM)'+
                                          'select STOKID,BELGETUR,'+IntToStr(KulFatbasID)+','+Tablo.Query2.Fields[0].AsString+',GIRISDEPO,0,MIKTAR,GIRISLOKASYONID,0,1 from STOKLOKASYON '+
                                          'where DURUM=0 and BELGETUR=99 and BASLIKID='+TabSayTutanak.FieldByName('ID').AsString+' and SATIRID='+tabSayimKalemleri.FieldByName('ID').AsString,[],[]);

      end;
    end;
    tabSayimKalemleri.Next;
  end;

    BekletDlg.cxProgressBar1.Position := 100;
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Sayım Sonlandırılıyor..';
    BekletDlg.LabelUstTaraf.Update;

  // sayım fiş tablosu oluşturulduktan sonra fatbaslıktaki tutar alanları güncellenir.
{  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:= 'UPDATE FATBASLIK SET FATURA_MATRAHI = ARATOPLAM,KDV_TUTARI = KDV_MATRAHI, FATURA_TUTARI = FATURATOPLAMI FROM FATBASLIK FB INNER JOIN  ';
  Tablo.Query1.SQL.Add(' (SELECT FATBASID, ARATOPLAM = isnull(SUM(ROUND(TUTAR,2)),0) , ');
  Tablo.Query1.SQL.Add(' KDV_MATRAHI = ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0),2), ');
  Tablo.Query1.SQL.Add(' FATURATOPLAMI = isnull(SUM(ROUND(TUTAR,2)),0)  ');
  Tablo.Query1.SQL.Add(' FROM FATURA WHERE FATBASID = '+inttostr(sayimCikfisfatbasid)+'  GROUP BY FATBASID ) AS B ');
  Tablo.Query1.SQL.Add(' ON FB.ID = B.FATBASID ' );
  Tablo.Query1.SQL.Add(' WHERE FB.ID ='+inttostr(sayimCikfisfatbasid)+' ');
  Tablo.Query1.ExecSQL;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:= 'UPDATE FATBASLIK SET FATURA_MATRAHI = ARATOPLAM,KDV_TUTARI = KDV_MATRAHI, FATURA_TUTARI = FATURATOPLAMI FROM FATBASLIK FB INNER JOIN  ';
  Tablo.Query1.SQL.Add(' (SELECT FATBASID, ARATOPLAM = isnull(SUM(ROUND(TUTAR,2)),0) , ');
  Tablo.Query1.SQL.Add(' KDV_MATRAHI = ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0),2), ');
  Tablo.Query1.SQL.Add(' FATURATOPLAMI = isnull(SUM(ROUND(TUTAR,2)),0)  ');
  Tablo.Query1.SQL.Add(' FROM FATURA WHERE FATBASID = '+inttostr(sayimGirfisfatbasid)+'  GROUP BY FATBASID ) AS B ');
  Tablo.Query1.SQL.Add(' ON FB.ID = B.FATBASID ' );
  Tablo.Query1.SQL.Add(' WHERE FB.ID ='+inttostr(sayimGirfisfatbasid)+' ');
  Tablo.Query1.ExecSQL;   }
  if sayimCikfisfatbasid > 0 then
     UpdateBaslikToplamlar(sayimCikfisfatbasid);
  if sayimGirfisfatbasid > 0 then
     UpdateBaslikToplamlar(sayimGirfisfatbasid);

  if BekletDlg <> nil then
     FreeAndNil(BekletDlg);
end;

procedure TStokSayimDlg.FaturaSayimFisiOlusturGuncelle;
//var girID,cikID:integer;

 {  function FatBaslikOlustur(Tur, Tipi, GDepo,CDepo :integer) : integer;
   begin
     Result := StrToIntDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO FATBASLIK (TARIH, TUR, TIPI, REHBERID, ANAKAYITID, FATURATARIH, GIRISDEPO, CIKISDEPO, EKLEYEN, EKLEMETARIHI , KDVDURUM,SUBEID ) '+
                  ' VALUES ('''+formatdatetime('yyyy-mm-dd hh:nn:ss', TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime)+''', '+
                  IntToStr(Tur)+','+IntToStr(Tipi)+', -1,'+TabSayTutanak.FieldByName('ID').AsString+','''+formatdatetime('yyyy-mm-dd hh:nn:ss', TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime)+''',  '+
                  IntToStr(GDepo)+','+IntToStr(CDepo)+','+Kullanan+', GETDATE(), ''Hariç'','+IntToStr(SubeId)+' ) SELECT ID = SCOPE_IDENTITY() ',[],[],True),0);
   end;   }

begin
  //Önce temizlik yapılacak..
  TabloYenile(tabSayimKalemleri,[TabSayTutanak.FieldByName('ID').AsInteger, '%%', '%%']);
  FaturaSayimFisiSil;
  //giriş fişi oluşuyor    giriş fişi:3 - sayım fazlası:17
 { Tablo.TablodanSorguAc(1,'select count(*) from  STOKSAYIMKALEMLERI SS where SS.SAYIMID='+TabSayTutanak.FieldByName('ID').AsString+' and SISTEMDEKIMIKTAR<SAYIMMIKTAR ');
  if Tablo.Query1.fields[0].AsInteger>0 then
     girID := FatBaslikOlustur(3, 17, TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger, 0)
  else
     girID := 0;
  //çıkış fişi oluşuyor    çıkış fişi:4 - sayım eksiği:16
  Tablo.TablodanSorguAc(1,'select count(*) from  STOKSAYIMKALEMLERI SS where SS.SAYIMID='+TabSayTutanak.FieldByName('ID').AsString+' and SISTEMDEKIMIKTAR>SAYIMMIKTAR ');
  if Tablo.Query1.fields[0].AsInteger>0 then
     cikID := FatBaslikOlustur(4, 16, 0, TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger)
  else
     cikID := 0; }
  FaturaSayimFisiSatirlariniOlusturGuncelle(0,0); //girID,cikID);
  //serinolari onaylıyoruz çıkış ekranlarında görünmesi için
end;

procedure TStokSayimDlg.SayimIptalClick(Sender: TObject);
begin
  TabSayTutanak.Cancel;
end;

procedure TStokSayimDlg.SayimKaydetClick(Sender: TObject);
begin
  TabSayTutanak.Post;
end;

procedure TStokSayimDlg.SayimSilClick(Sender: TObject);
begin
  if tabSayimKalemleri.RecordCount > 0 then begin
    Application.MessageBox(PChar(STOnce_sil),PChar(Bilgi), MB_OK + MB_ICONWARNING);
    Abort
  end;
  //önce İlgili fatura kaydı silinsin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:= 'DELETE FROM FATBASLIK WHERE TUR = 7 AND ANAKAYITID ='+ TabSayTutanak.FieldByName('ID').AsString +' ';
  Tablo.Query1.ExecSQL;

  TabSayTutanak.Delete;
  SayimlariListele;
end;

procedure TStokSayimDlg.SaymCihaz1Click(Sender: TObject);
var
  Ftxt: Textfile;
  i: Integer;
  sl: TStringList;
  SatirTur,Satir: String;
  StokId,SayimId,IzlemeTuru,DepoIDsi,UrunLokasyon,UrunBirim,BoyutID:integer;
  UrunBarkodu,UrunAdi,UrunKodu,UrunRafBarcode,BoyutAdi,Serino:string;
  SKT,Tarih:Tdatetime;
  SayimMiktari:extended;
  Fiyat:Currency;
begin
  if OpenDialog2.Execute then begin //burada text dosyayı seçtiriyoruz.. uzantısı .txt .dat gibi olabilir..
    sl := TStringList.Create;
    try
      sl.LoadFromFile(OpenDialog2.Filename);
      for I := 0 to sl.Count-1 do begin
        //dosya içerisindeki ',' leri '.' ile değiştirerek başlamak gerekiyor..
        StokId := 0;
        SayimId := 0;
        SayimMiktari := 0.0;
        Serino := '';
        SKT := 0.0;
        BoyutID := 0;
        Satir := StringReplace(sl.Strings[i],',','.',[rfReplaceAll]);
        SatirTur := dize.SinirlandirilmisMetin(Satir,'|');
        if SatirTur='S' then begin //stok kartı
          //' Stok Id,' Sayım Id,' İzleme Turu Id,' Depo ID si,' Ürün Barkodu,' Sayım Miktari,
          //' Ürün Adı,' Ürün Kodu,' Ürün Birim,' Ürün Raf Barcode,' Ürün Lokasyon,' Tarih
          //S|28|1|0|2|8691273367000|3|100X100 PLAYFUL SİYAH|100X100PLY93|58|||01.01.2006
          StokId := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          SayimId := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          IzlemeTuru := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          DepoIDsi := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          UrunBarkodu := dize.SinirlandirilmisMetin(Satir,'|');
          SayimMiktari := StrToFloatDef(StringReplace(dize.SinirlandirilmisMetin(Satir,'|'),'.',FormatSettings.DecimalSeparator,[rfReplaceAll]),0.0);
          UrunAdi := dize.SinirlandirilmisMetin(Satir,'|');
          UrunKodu := dize.SinirlandirilmisMetin(Satir,'|');
          UrunBirim := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          UrunLokasyon := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          UrunRafBarcode := dize.SinirlandirilmisMetin(Satir,'|');
          Tarih := StrToDateTimeDef(StringReplace(dize.SinirlandirilmisMetin(Satir,'|'),'.',FormatSettings.DateSeparator,[rfReplaceAll]),0.0);
          if (StokId>0)and(SayimId>0)and(SayimMiktari>0.0) then begin
            Tablo.TablodanSorguAc(0,'select * from STOKSAYIMKALEMLERI where SAYIMID='+TabSayTutanak.FieldByName('ID').AsString+' and STOKID='+IntToStr(StokId));
            if Tablo.Query0.RecordCount=0 then begin //ilk kez insert işlemi
              Tablo.TablodanSorguAc(1,'select KALAN=isnull(sum(isnull(SD.KALAN,0)),0) from STOKLAR S left outer join STOKDURUM SD on S.ID=SD.STOKID where S.ID='+IntToStr(StokId)+' and SD.DEPOID='+VarToStr(cbSayimDepo.EditValue));
              Tablo.TablodanSorguAc(2,'select FIYAT=isnull(FIYAT,0.0) from STOKFIYAT where STOKID='+IntToStr(StokId)+' and FIYATADI='+VarToStr(cbFiyatAdi.EditValue)+' and BIRIM='+IntToStr(UrunBirim)+' and SATIS=0 ');
              if Tablo.Query2.RecordCount=0 then
                Fiyat := 0.0
              else
                Fiyat := Tablo.Query2.FieldByName('FIYAT').AsCurrency;
              Tablo.TablodanSorguAc(3,'INSERT INTO STOKSAYIMKALEMLERI(SAYIMID,STOKID,SISTEMDEKIMIKTAR,SAYIMMIKTAR,BIRIMFIYAT,TUTAR,IZLEME,KUR,SUBEID,DOSYAID)'+
                                      ' VALUES('+TabSayTutanak.FieldByName('ID').AsString+','
                                                +IntToStr(StokId)+','
                                                +Tablo.Query1.FieldByName('KALAN').AsString+','
                                                +StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                +StringReplace(FloatToStr(Fiyat),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                +'0.0,'//tutar birimfiyata göre bilaare güncellenecek..
                                                +IntToStr(IzlemeTuru)+','''
                                                +CariDoviz+''','
                                                +IntToStr(SubeID)+','
                                                +IntToStr(SayimId)+') select scope_identity()',True);
              if UrunLokasyon>0 then begin //lokasyon içeren sayım..
                veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKLOKASYON(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,MIKTAR,GIRISLOKASYONID,CIKISLOKASYONID,DURUM)'+
                                                        'values('+IntToStr(StokId)+',99,'+TabSayTutanak.FieldByName('ID').AsString+','+Tablo.Query3.Fields[0].AsString+','
                                                                +VarToStr(cbSayimDepo.EditValue)+','+VarToStr(cbSayimDepo.EditValue)+','
                                                                +StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                                +IntToStr(UrunLokasyon)+','+IntToStr(UrunLokasyon)+',0)',[],[]);
              end;
            end else begin //üstüne ekleme işlemleri
              //sayımmiktar güncellenir..
              veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKSAYIMKALEMLERI set SAYIMMIKTAR=SAYIMMIKTAR+'+StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+' where ID='+Tablo.Query0.FieldByName('ID').AsString,[],[]);
              //lokasyon varsa lokasyon eklenir..
              if UrunLokasyon>0 then begin //lokasyon içeren sayımda yeni lokasyon da üstüne eklenecek..
                veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKLOKASYON(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,MIKTAR,GIRISLOKASYONID,CIKISLOKASYONID,DURUM)'+
                                                        'values('+IntToStr(StokId)+',99,'+TabSayTutanak.FieldByName('ID').AsString+','+Tablo.Query0.Fields[0].AsString+','
                                                                +VarToStr(cbSayimDepo.EditValue)+','+VarToStr(cbSayimDepo.EditValue)+','
                                                                +StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                                +IntToStr(UrunLokasyon)+','+IntToStr(UrunLokasyon)+',0)',[],[]);
              end;
            end;
          end;
        end else if SatirTur='SSKT' then begin//izleme bilgisi skt
          //Sayım ID,Son Kullanım Tarihi,Miktar,Tarih
          //SSKT|1|21.10.2013|1|25.09.2013
          SayimId := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          SKT := StrToDateTimeDef(StringReplace(dize.SinirlandirilmisMetin(Satir,'|'),'.',FormatSettings.DateSeparator,[rfReplaceAll]),0.0);
          SayimMiktari := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          Tarih := StrToDateTimeDef(StringReplace(dize.SinirlandirilmisMetin(Satir,'|'),'.',FormatSettings.DateSeparator,[rfReplaceAll]),0.0);
          Tablo.TablodanSorguAc(0,'select * from STOKSAYIMKALEMLERI where SAYIMID='+TabSayTutanak.FieldByName('ID').AsString+' and DOSYAID='+IntToStr(SayimId));
          if (Tablo.Query0.RecordCount=1) and (SayimId>0) and (SKT>0.0) and (SayimMiktari>0) then
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKIZLEME(STOKID, DEPOID, BELGETUR, BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,IZLEMTUR,MIKTAR,IZLEM,IZLEMID,ACIKLAMA,SKT,DURUM)'+
                                                    'values('+Tablo.Query0.FieldByName('STOKID').AsString+','+TabSayTutanak.FieldByName('SAYIMDEPO').AsString+',99,'+TabSayTutanak.FieldByName('ID').AsString+','+Tablo.Query0.Fields[0].AsString+','
                                                                +VarToStr(cbSayimDepo.EditValue)+','+VarToStr(cbSayimDepo.EditValue)+',2,'
                                                                +StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                                +' '''+FormatDateTime('yyyy-mm-dd hh:nn',SKT)+''',0,'''+FormatDateTime('yyyy-mm-dd hh:nn',SKT)+''','''+FormatDateTime('yyyy-mm-dd hh:nn',SKT)+''',0)',[],[]);

        end else if SatirTur='SBYT' then begin//izleme bilgisi boyut
          //Sayım ID, STOK ID, ID,TURU,Miktar,Tarih
          //SBYT|1|28|Kırmızı M ID si|Kırmızı M|3|25.09.2013
          SayimId := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          StokId := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          BoyutID := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          BoyutAdi := dize.SinirlandirilmisMetin(Satir,'|');
          SayimMiktari := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          Tarih := StrToDateTimeDef(StringReplace(dize.SinirlandirilmisMetin(Satir,'|'),'.',FormatSettings.DateSeparator,[rfReplaceAll]),0.0);
          Tablo.TablodanSorguAc(0,'select * from STOKSAYIMKALEMLERI where SAYIMID='+TabSayTutanak.FieldByName('ID').AsString+' and DOSYAID='+IntToStr(SayimId));
          if (Tablo.Query0.RecordCount=1) and (SayimId>0) and (BoyutID>0.0) and (SayimMiktari>0) then
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKIZLEME(STOKID,DEPOID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,IZLEMTUR,MIKTAR,IZLEM,IZLEMID,ACIKLAMA,SKT,DURUM)'+
                                                    'values('+Tablo.Query0.FieldByName('STOKID').AsString+','+TabSayTutanak.FieldByName('SAYIMDEPO').AsString+',99,'+TabSayTutanak.FieldByName('ID').AsString+','+Tablo.Query0.Fields[0].AsString+','
                                                                +VarToStr(cbSayimDepo.EditValue)+','+VarToStr(cbSayimDepo.EditValue)+',4,'
                                                                +StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                                +' '''+BoyutAdi+''','+IntToStr(BoyutID)+','''+BoyutAdi+''',null,0)',[],[]);
        end else if SatirTur='SKRKSN' then begin//izleme bilgisi serino/karekod
          //Sayım ID,Seri Numarası veya  Kare Kodu,Tarih
          //SKRKSN|1|54687984564163|25.09.2013
          SayimId := StrToIntDef(dize.SinirlandirilmisMetin(Satir,'|'),0);
          Serino := dize.SinirlandirilmisMetin(Satir,'|');
          SayimMiktari := 1.0;
          Tarih := StrToDateTimeDef(StringReplace(dize.SinirlandirilmisMetin(Satir,'|'),'.',FormatSettings.DateSeparator,[rfReplaceAll]),0.0);
          Tablo.TablodanSorguAc(0,'select * from STOKSAYIMKALEMLERI where SAYIMID='+TabSayTutanak.FieldByName('ID').AsString+' and DOSYAID='+IntToStr(SayimId));
          if (Tablo.Query0.RecordCount=1) and (SayimId>0) and (Serino>'') then
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKIZLEME(STOKID,DEPOID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,IZLEMTUR,MIKTAR,IZLEM,IZLEMID,ACIKLAMA,SKT,DURUM)'+
                                                    'values('+Tablo.Query0.FieldByName('STOKID').AsString+',99,'+TabSayTutanak.FieldByName('ID').AsString+','+Tablo.Query0.Fields[0].AsString+','
                                                                +VarToStr(cbSayimDepo.EditValue)+','+VarToStr(cbSayimDepo.EditValue)+',1,'
                                                                +StringReplace(FloatToStr(SayimMiktari),FormatSettings.DecimalSeparator,'.',[rfReplaceAll])+','
                                                                +' '''+Serino+''',0,'''+Serino+''',null,0)',[],[]);
        end;
      end;
    finally
      sl.Free;
    end;
  end;
  TabSayTutanakAfterScroll(TabSayTutanak);

end;

procedure TStokSayimDlg.ExcelDosya1Click(Sender: TObject);
begin
  Excel2StokSayimm(TabSayTutanak, TabSayimKalemleri, ExcelStokId);
  TabSayTutanakAfterScroll(TabSayTutanak);
end;

procedure TStokSayimDlg.tabSayimKalemleriAfterPost(DataSet: TDataSet);
begin
  if IzlemDlg<>nil then begin
    IzlemDlg.SatirID := tabSayimKalemleri.FieldByName('ID').AsInteger;
    FreeAndNil(IzlemDlg);
  end;
  if LokasyonDlg<>nil then begin
    LokasyonDlg.SatirID := tabSayimKalemleri.FieldByName('ID').AsInteger;
    FreeAndNil(LokasyonDlg);
  end;
end;

procedure TStokSayimDlg.tabSayimKalemleriBeforeDelete(DataSet: TDataSet);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BELGETUR=&BTur and BASLIKID=&BID and SATIRID=&SID',
                ['&BTur','&BID','&SID'],[99,TabSayTutanak.FieldByName('ID').AsString,tabSayimKalemleri.FieldByName('ID').AsString]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKLOKASYON where DURUM=0 and BELGETUR=&BTur and BASLIKID=&BID and SATIRID=&SID',
                ['&BTur','&BID','&SID'],[99,TabSayTutanak.FieldByName('ID').AsString,tabSayimKalemleri.FieldByName('ID').AsString]);
end;

procedure TStokSayimDlg.tabSayimKalemleriBeforePost(DataSet: TDataSet);
  var DetID:integer;
      miktar : real;
begin
  if (tabSayimKalemleri.State=dsInsert)or(tabSayimKalemleri.FieldByName('SAYIMMIKTAR').OldValue <> tabSayimKalemleri.FieldByName('SAYIMMIKTAR').NewValue) then begin
    //insert modunda detay id si yok..
    if tabSayimKalemleri.FieldByName('ID').Value <> null then
      DetID := tabSayimKalemleri.FieldByName('ID').AsInteger
    else
      DetID := 0;

    if Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_LokasyonVar,False) then begin
      if not Anaform.StokLokasyonSor(LokasyonDlg,tabSayimKalemleri.FieldByName('STOKID').AsInteger,99,
                      TabSayTutanak.FieldByName('ID').AsInteger,DetID,cbSayimDepo.EditValue,0,
                      tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsFloat,False) then begin
        FreeAndNil(LokasyonDlg);
        tabSayimKalemleri.Cancel;
        Abort;
      end;
    end;
    if tabSayimKalemleri.FieldByName('IZLEME').AsInteger > 0 then begin
      miktar := tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsInteger;
      if not Anaform.StokIzleme(IzlemDlg,tabSayimKalemleri.FieldByName('STOKID').AsInteger, tabSayimKalemleri.FieldByName('IZLEME').AsInteger, 99, 1,
                      TabSayTutanak.FieldByName('ID').AsInteger,DetID,0,TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger, TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger,
                      miktar, miktar) then begin                                                  //Adnan
        FreeAndNil(IzlemDlg);
        tabSayimKalemleri.Cancel;
        Abort;
      end;
    end;
    if tabSayimKalemleri.FieldByName('IZLEME').Value = null then
      tabSayimKalemleri.FieldByName('IZLEME').AsInteger := 0;
  end;

  tabSayimKalemleri.FieldByName('TUTAR').Value := tabSayimKalemleri.FieldByName('BIRIMFIYAT').AsCurrency * tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsFloat;
end;

procedure TStokSayimDlg.tabSayimKalemleriNewRecord(DataSet: TDataSet);
var Trh:TDateTime;
begin
  oncekisayimmiktar:=0;
  tabSayimKalemleri.FieldByName('SAYIMID').AsInteger := TabSayTutanak.FieldByName('ID').AsInteger;
  tabSayimKalemleri.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
  tabSayimKalemleri.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;

  if tabSayTutanak.FieldByName('SATISDURUMU').AsBoolean then
     tabSayimKalemleri.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat
  else
     tabSayimKalemleri.FieldByName('DEGISTIRMETARIHI').AsDateTime := tabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime;
//  Tablo.ADOStoredProc1.ProcedureName:='sp_StokSayim';
//  if TabSayTutanak.FieldByName('SATISDURUMU').AsBoolean=False then //Satış kapalıysa genel tarih
//     Tablo.ADOStoredProc1.Params[0].Value :=  TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime
//     Trh := TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime
//  else
//     Tablo.ADOStoredProc1.Params[0].Value :=  tabSayimKalemleri.FieldByName('DEGISTIRMETARIHI').AsDateTime; //açıksa o satırın zamanı
//     Trh := tabSayimKalemleri.FieldByName('DEGISTIRMETARIHI').AsDateTime;
//  Tablo.ADOStoredProc1.Params[1].Value :=  tabSayimKalemleri.FieldByName('STOKID').Value;
//  Tablo.ADOStoredProc1.Params[2].Value :=  TabSayTutanak.FieldByName('SAYIMDEPO').Value;
//  Tablo.ADOStoredProc1.Open;

//  Tablo.TablodanSorguAc(2,'sp_StokSayim '''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Trh)+''','+tabSayimKalemleri.FieldByName('STOKID').AsString+','+TabSayTutanak.FieldByName('SAYIMDEPO').AsString);
//  tabSayimKalemleri.FieldByName('SISTEMDEKIMIKTAR').Value := Tablo.Query2.Fields[0].Value;

//  tabSayimKalemleri.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TStokSayimDlg.TumKaytlarnSaymMiktarlarnSfrAtaMenuClick(Sender: TObject);
begin
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKSAYIMKALEMLERI set SAYIMMIKTAR=0 where SAYIMID='+TabSayTutanak.FieldByName('ID').AsString,[],[]);
   TabloYenile(tabSayimKalemleri,[TabSayTutanak.FieldByName('ID').AsInteger, '%'+EditAra.Text+'%', '%'+EditAra.Text+'%']);
end;

procedure TStokSayimDlg.TuslariDuzenle;
begin
  ToolBar5.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  //gridSayimTutanak.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  tvSayimTutanak.OptionsData.Editing := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  tvSayimTutanak.OptionsData.Deleting := tvSayimTutanak.OptionsData.Editing;
  cbSayimDepo.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  dateSayimTarih.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  cbSayimYapan.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  cbFiyatAdi.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  cbSayimOnaylayan.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  BtnTumStoklariEkle.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  BtnTumKartlariSil.Enabled := ((TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert))and(checkSayimTamamlandi.Checked <> True);
  checkSayimTamamlandi.Enabled := (TabSayTutanak.RecordCount>0)or(TabSayTutanak.State=dsInsert);
end;

procedure TStokSayimDlg.SeriNoInsert(StokID:integer;SeriNo:string);
begin
  tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='Select * from STOKID';
  Tablo.Query1.Open;
  Tablo.Query1.Insert;
  Tablo.Query1.FieldByName('GIRISTURU').AsInteger:=0;
  Tablo.Query1.FieldByName('STOKID').AsInteger:=StokID;
  Tablo.Query1.FieldByName('SERINO').AsString:=SeriNo;
  Tablo.Query1.Post;
end;

procedure TStokSayimDlg.SeriNoDelete(StokID:integer;SeriNo:string);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='Delete from STOKID where STOKID=:A0 and SERINO=:A1';
  Tablo.Query1.Params[0].Value:=StokID;
  Tablo.Query1.Params[1].Value:=SeriNo;
  Tablo.Query1.ExecSQL;
end;

procedure TStokSayimDlg.TabSayTutanakAfterOpen(DataSet: TDataSet);
begin
   TabloYenile(tabSayimKalemleri,[TabSayTutanak.FieldByName('ID').AsInteger, '%'+EditAra.Text+'%', '%'+EditAra.Text+'%']);
   TuslariDuzenle;
end;

procedure TStokSayimDlg.TabSayTutanakAfterPost(DataSet: TDataSet);
begin
  if TabSayTutanak.FieldByName('SAYIMONAY').AsInteger = 1 then
     FaturaSayimFisiOlusturGuncelle
  else
     FaturaSayimFisiSil;
  TuslariDuzenle;
end;

procedure TStokSayimDlg.FaturaSayimFisiSil;
begin
//giriş fişi:3 - sayım fazlası:17
//çıkış fişi:4 - sayım eksiği:16
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete S from STOKLOKASYON S inner join FATBASLIK FB on FB.ID=S.BASLIKID where FB.TUR in (3,4) and FB.TIPI in (16,17) AND ANAKAYITID = '+TabSayTutanak.FieldByName('ID').AsString,[],[]);
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete S from STOKIZLEME S inner join FATBASLIK FB on FB.ID=S.BASLIKID where FB.TUR in (3,4) and FB.TIPI in (16,17) AND ANAKAYITID = '+TabSayTutanak.FieldByName('ID').AsString,[],[]);
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete F from FATURA F inner join FATBASLIK FB on FB.ID=F.FATBASID where FB.TUR in (3,4) and FB.TIPI in (16,17) AND FB.YERI=99 AND FB.YERID = '+TabSayTutanak.FieldByName('ID').AsString,[],[]);
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from FATBASLIK where TUR in (3,4) and TIPI in (16,17) AND YERI=99 AND YERID = '+TabSayTutanak.FieldByName('ID').AsString,[],[]);
end;


procedure TStokSayimDlg.TabSayTutanakAfterScroll(DataSet: TDataSet);
var Key: Word;
begin
  Key:=0;
  EditAraKeyUp(Self, Key, []);
  TuslariDuzenle;
  TabloYenile(tabSayimKalemleri,[TabSayTutanak.FieldByName('ID').AsInteger, '%'+EditAra.Text+'%', '%'+EditAra.Text+'%']);
end;

procedure TStokSayimDlg.TabSayTutanakBeforeDelete(DataSet: TDataSet);
begin
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := ' UPDATE DEPOLAR SET SONSAYIMTARIHI = ISNULL((SELECT MAX(SAYIMTARIHI) FROM STOKSAYIM ' + ' WHERE SAYIMDEPO = ' + TabSayTutanak.FieldByName('SAYIMDEPO').AsString + ' AND SAYIMONAY = 1 ),''1900-01-01'') ' + '  WHERE ID =' + TabSayTutanak.FieldByName('SAYIMDEPO').AsString + '';
    Tablo.Query3.ExecSQL;
end;

procedure TStokSayimDlg.TabSayTutanakBeforePost(DataSet: TDataSet);
begin
  if not TarihKontrol(dateSayimTarih.Date, 'Sayım' + KontrolTarihi) then
     Abort;
  if TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger<=0 then begin
     Application.MessageBox(PChar(STDepo_bos_olmaz),PChar(HataPrj),MB_OK+MB_ICONWARNING);
     Abort;
  end;
  if TabSayTutanak.FieldByName('FIYATADI').AsInteger<=0 then begin
     Application.MessageBox(PChar(STFiyat_gir),PChar(HataPrj),MB_OK+ MB_ICONERROR);
     abort;
  end;
  if TabSayTutanak.FieldByName('SAYIMONAY').AsInteger = 1 then begin
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := ' UPDATE DEPOLAR SET SONSAYIMTARIHI = ''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime) + ''' ' + ' where ID =' + TabSayTutanak.FieldByName('SAYIMDEPO').AsString + ' ';
    Tablo.Query3.ExecSQL;
  end else begin
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := ' UPDATE DEPOLAR SET SONSAYIMTARIHI = ISNULL((SELECT MAX(SAYIMTARIHI) FROM STOKSAYIM ' + ' WHERE SAYIMDEPO = ' + TabSayTutanak.FieldByName('SAYIMDEPO').AsString + ' AND SAYIMONAY = 1 ),''1900-01-01'') ' + '  WHERE ID =' + TabSayTutanak.FieldByName('SAYIMDEPO').AsString + '';
    Tablo.Query3.ExecSQL;
  end;
end;

procedure TStokSayimDlg.TabSayTutanakNewRecord(DataSet: TDataSet);
begin
  TabSayTutanak.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
  TabSayTutanak.FieldByName('SAYIMTARIHI').Value := Tablo.GENINI.BugunTrhSaat;
  TabSayTutanak.FieldByName('SAYIMYAPAN').AsInteger := StrToInt(Kullanan);
  TabSayTutanak.FieldByName('SATISDURUMU').AsBoolean := False;
//  TabSayTutanak.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TStokSayimDlg.btnKalemKaydetClick(Sender: TObject);
begin
  tabSayimKalemleri.Post;
end;

procedure TStokSayimDlg.btnKalemVazgecClick(Sender: TObject);
begin
  tabSayimKalemleri.Cancel;
end;

function TStokSayimDlg.FatBaslikBul:integer;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:= 'SELECT ID FROM FATBASLIK WHERE TUR = 7 AND ANAKAYITID = '+TabSayTutanak.FieldByName('ID').AsString+' ';
  Tablo.Query1.Open;
  Result:= Tablo.Query1.Fields[0].AsInteger;
end;

procedure TStokSayimDlg.BtnTumStoklariEkleClick(Sender: TObject);
var  SayimTrh,s :string;
begin
   Application.CreateForm(TKategoriDlg, KategoriDlg);
   KategoriDlg.Cagiran:=3;
   KategoriDlg.StokKartinSubesi := SubeId;
   KategoriDlg.ShowModal;
   s:='';
   if KategoriDlg.ModalResult = mrOk then begin //kategori seçilmişse
      KategoriDlg.Kategori.first;
      while not KategoriDlg.Kategori.eof do begin
        if KategoriDlg.Kategori.FieldByname('SEC').AsBoolean then begin
           if s<>'' then s:=s+',';
           s:=s+KategoriDlg.Kategori.FieldByname('ID').AsString;
        end;
        KategoriDlg.Kategori.next;
      end;

      s := ' S.KATEGORI in ('+s+') and ';

   end;
   KategoriDlg.destroy;

   if TabSayTutanak.State in [dsEdit, dsInsert] then
      TabSayTutanak.Post;
   SayimTrh := FormatDateTime('yyyy-mm-dd hh:nn:ss', TabSayTutanak.FieldByName('SAYIMTARIHI').AsDateTime);
   Tablo.Query1.Close; //SAYIMMIKTAR
   Tablo.Query1.SQL.Text := 'INSERT INTO STOKSAYIMKALEMLERI (SAYIMID, STOKID, SISTEMDEKIMIKTAR,  EKLEYEN, EKLEMETARIHI, DEGISTIRMETARIHI, IZLEME, BIRIMFIYAT,TUTAR,KUR ) '
      +' SELECT '+IntToStr(TabSayTutanak.FieldByName('ID').AsInteger)+','
      +' S.ID,KALAN=A.KALAN, ' + Kullanan + ','''+SayimTrh+''','''+SayimTrh+''', S.IZLEME,(case when isnull(SF.FIYAT,0.0)=-1.0 then 0.0 else isnull(SF.FIYAT,0.0) end),0.0,isnull(SF.KUR,'''+CariDoviz+''')   '
      +' FROM STOKLAR S   '
      +' left outer join STOKFIYAT SF on S.ID=SF.STOKID and SF.SATIS=0 and PAKETID=0 and SF.BIRIM=S.ANABIRIM and FIYATADI='+IntToStr(cbFiyatAdi.EditValue)
      +' LEFT JOIN [dbo].[fn_StokSayimButun] ('''+SayimTrh+''') A ON A.STOKID=S.ID AND A.DEPOID='+IntToStr(cbSayimDepo.EditValue)
      +' WHERE '+s+' DURUM > 0 and S.ID NOT IN (SELECT STOKID FROM STOKSAYIMKALEMLERI WHERE SAYIMID ='+IntToStr(TabSayTutanak.FieldByName('ID').AsInteger)+')';
//      +' and ISNULL(SD.DEPOID,'+IntToStr(cbSayimDepo.EditValue)+') = '+IntToStr(cbSayimDepo.EditValue);
   Tablo.Query1.ExecSQL;
   TabloYenile(tabSayimKalemleri,[TabSayTutanak.FieldByName('ID').AsInteger, '%'+EditAra.Text+'%',  '%'+EditAra.Text+'%']);
end;

procedure TStokSayimDlg.BtnTumKartlariSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(STHepsi_silinecek_onay),PChar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_NO then
     Abort
  else begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BELGETUR=&BTur and BASLIKID=&BID ',
                  ['&BTur','&BID'],[99,TabSayTutanak.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKLOKASYON where DURUM=0 and BELGETUR=&BTur and BASLIKID=&BID ',
                  ['&BTur','&BID'],[99,TabSayTutanak.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKSAYIMKALEMLERI where SAYIMID=&SID ',
                  ['&SID'],[TabSayTutanak.FieldByName('ID').AsInteger]);
     TabSayTutanakAfterScroll(tabSayimKalemleri);
  end;
end;

procedure TStokSayimDlg.mnStokDurumGuncelleClick(Sender: TObject);
begin
  if not TabSayTutanak.Active then
    Abort;
  if TabSayTutanak.FieldByName('ID').AsInteger < 0 then
    Abort;
  if TabSayTutanak.State in [dsEdit, dsInsert] then
  begin
    Application.MessageBox(PChar(STDuzenleniyor_tekrar_dene),PChar(HataPrj), MB_OK + MB_ICONERROR);
    Abort;
  end;

  if TabSayTutanak.FieldByName('SAYIMONAY').AsInteger = 0 then
  begin
    Application.MessageBox(PChar(STTutanak_onayla),PChar(HataPrj), MB_OK + MB_ICONERROR);
    Abort;
  end;
  if tabSayimKalemleri.RecordCount <= 0 then
  begin
    Application.MessageBox(PChar(STUrun_kaydi_yok), PChar(HataPrj), MB_OK + MB_ICONERROR);
    Abort;
  end;


end;

procedure TStokSayimDlg.dateBitisPropertiesCloseUp(Sender: TObject);
begin
  SayimlariListele;
end;

procedure TStokSayimDlg.dtsSayimKalemleriStateChange(Sender: TObject);
begin
  btnKalemKaydet.Enabled := dtsSayimKalemleri.State in [dsEdit, dsInsert];
  btnKalemVazgec.Enabled := dtsSayimKalemleri.State in [dsEdit, dsInsert];
  btnSayimKalemEkle.Enabled := dtsSayimKalemleri.State =dsBrowse;
  btnSayimKalemSil.Enabled := dtsSayimKalemleri.State =dsBrowse;
  YaziciYaz.Enabled := dtsSayimKalemleri.State =dsBrowse;
  btnDosyadan.Enabled := dtsSayimKalemleri.State =dsBrowse;

end;

procedure TStokSayimDlg.dtsSayimTutanakStateChange(Sender: TObject);
begin
  SayimKaydet.Visible := dtsSayimTutanak.State in [dsEdit, dsInsert];
  SayimIptal.Visible := dtsSayimTutanak.State in [dsEdit, dsInsert];
  YeniSayim.Visible := dtsSayimTutanak.State = dsBrowse;
  SayimSil.Visible := dtsSayimTutanak.State = dsBrowse;

end;

procedure TStokSayimDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Tablo.TablodanSorguAc(1,'SELECT '+DbUst(1)+'ID FROM STOKSAYIM WHERE ISNULL(SAYIMONAY,0)=0 '+DbSinir(1));
  if Tablo.Query1.RecordCount=1 then
   begin
     if Application.MessageBox(PChar(STOnaylanmamis_sayim_ekran_kapansinmi),PChar(Uyari),MB_YESNO+ MB_ICONQUESTION) = ID_YES then
      CanClose:=True
     else
      CanClose:=False;
   end
 else
   CanClose:=True;

end;

procedure TStokSayimDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //tvSayimTutanak.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokSayimTutanak',true,false,[gsoUseFilter],'StokSayimTutanak');
  Tablo.GridAyarRestore('StokSayimTutanak',tvSayimTutanak );
  Tablo.GridTurkcelestir;
  dateBaslangic.Date := Tablo.GENINI.BugunTrh-150;  ////StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2011 00:00');
  dateBitis.Date := EndOfTheYear(Tablo.GENINI.BugunTrh); //StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+'2011 23:59');
end;

procedure TStokSayimDlg.FormShow(Sender: TObject);
var
  ra:String;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  SayimlariListele;
  ButtonSelect:=-1;
  //PopupMenuYaz.Images := TGenelAnaSekmeFrame(1).ImageList1;
end;

procedure TStokSayimDlg.IzlemBilgisiDuzenleMenuClick(Sender: TObject);
var miktar : real;
begin
     miktar := tabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsInteger;
     if not Anaform.StokIzleme(IzlemDlg,tabSayimKalemleri.FieldByName('STOKID').AsInteger,tabSayimKalemleri.FieldByName('IZLEME').AsInteger,99, 1,
                TabSayTutanak.FieldByName('ID').AsInteger,tabSayimKalemleri.FieldByName('ID').AsInteger,TabSayTutanak.FieldByName('ID').AsInteger,
                TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger,TabSayTutanak.FieldByName('SAYIMDEPO').AsInteger,
                TabSayimKalemleri.FieldByName('SAYIMMIKTAR').AsInteger, miktar) then
        FreeAndNil(IzlemDlg);
end;

procedure TStokSayimDlg.lbSayimTipiClick(Sender: TObject);
begin

   Tablo.LabelClickCombobox(Sender);
end;

procedure TStokSayimDlg.pmSayimTutanakPopup(Sender: TObject);
begin
  mnStokDurumGuncelle.Enabled := TabSayTutanak.FieldByName('SAYIMONAY').AsInteger = 1;
end;

procedure TStokSayimDlg.btnSayimKalemEkleClick(Sender: TObject);
begin
  if TabSayTutanak.State in [dsInsert,dsEdit] then begin
    TabSayTutanak.Post;
  end;
  if tabSayimKalemleri.State in [dsInsert,dsEdit] then begin
    tabSayimKalemleri.Post;
    tabSayimKalemleri.Close;
    tabSayimKalemleri.Params[0].Value := StrToIntDef(lbSayimId.Caption,0);
    tabSayimKalemleri.Open;
  end;
  if AraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  AraDlg.StokSayimID := StrToIntDef(lbSayimId.Caption,0);
  AraDlg.TabGiris:=TabSayTutanak;
  AraDlg.TabDetayGiris:=tabSayimKalemleri;
  AraDlg.KalanAdetGetir:=True;
  AraDlg.SheetHizmet.TabVisible:=False;
  AraDlg.FiyatlariGetir:=True;
  AraDlg.cbFiyatAdi.EditValue := cbFiyatAdi.EditValue;
  AraDlg.GirisCikis:=FWGiris;
  AraDlg.cbStokDepo.EditValue:=cbSayimDepo.EditValue;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := 99;

  AraDlg.ShowModal;
  FreeAndNil(AraDlg);
  TabSayTutanakAfterScroll(TabSayTutanak);
end;

procedure TStokSayimDlg.btnSayimKalemSilClick(Sender: TObject);
begin
  if tabSayimKalemleri.RecordCount<=0 then
    abort;
  if Application.MessageBox(PChar(STsayim_sil_onay),PChar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_NO then
    Abort;
  tabSayimKalemleri.Delete;
end;

procedure TStokSayimDlg.tvSayimTutanakCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=gridSayimTutanak;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=tvSayimTutanak;
  AnaForm.pmGridStil.Tags.Values[gridSayimTutanak.Name]:='StokSayimTutanak';
end;

procedure TStokSayimDlg.YeniSayimClick(Sender: TObject);
begin
  TabSayTutanak.Append;
  TuslariDuzenle;
end;

procedure TStokSayimDlg.EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  tabSayimKalemleri.Locate('AD',EditAra.Text,[]);
   TabloYenile(tabSayimKalemleri,[TabSayTutanak.FieldByName('ID').AsInteger, '%'+EditAra.Text+'%', '%'+EditAra.Text+'%']);
end;

function TStokSayimDlg.EkranAdiAl: string;
begin
  Result:='StokSayimEkr';
end;

procedure TStokSayimDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxSayimKalemleri);
  AFastReport.EnabledDataSets.Add(frxSayimTutanak);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);

end;

procedure TStokSayimDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

end.





