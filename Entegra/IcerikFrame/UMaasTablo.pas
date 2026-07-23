unit UMaasTablo;
{PLANMAAS tablosunda YER alanı
 0: YERID=PersId Cari kartta tanımlanan Tahakkukları
 1: YERID=PersId Cari kartta tanımlanan Kesintileri
 91: YERID=PersId Cari kartta tanımlanan Ek Kesintileri

 11: YERID=PersId O ayki Tahakkukları
 21: YERID=PersId O ayki Kesintileri
 51: YERID=PersId TUTAR alanı Standart Bankadan Ödenen Miktarı
 61: YERID=PersId TUTAR alanı Standart Bankadan Ödenen Avansı
 62: YERID=PersId TUTAR alanı Standart Kasadan Ödenen Avansı
 100: YERID=-1 SIRA alanı Standart Maas gününü
 101: YERID=-1 SIRA alanı Standart Avans gününü
 gösterir

 Maaş Avansı verildiği zaman şu işlemler yapılır:
 KASA tablosuna 100 kasadan çıkış eklenir
 KASA tablosuna 196 kasasına giriş eklenir Burada KREDIID alanında taksit sayısı yazılır
 PLANMAAS tablosunda YER:1 YERID:RehberId ve DURUM:üstteki 196 kasasına eklenen KASA.Id yazılır (Taksit sayısı kadar bu satır eklenir)
 Silmede de bunları silmek gerekir..


 İş Avansı verildiği zaman şu işlemler yapılır:
 KASA tablosuna 100 kasadan çıkış eklenir
 KASA tablosuna 195.01 Personelin iş avansı kasasına giriş eklenir
}


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, cxDBEdit, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView,
  cxGrid, ComCtrls, ToolWin, ExtCtrls, FireDAC.Comp.Client, StdCtrls, Menus, cxCurrencyEdit,
  cxCheckBox, ComObj, cxMemo, UGentegreFrameYonetimi, dxSkinsCore,
  dxSkinscxPCPainter,UFrameYoneticisi, cxCalc, dxSkinLondonLiquidSky,
  frxClass, frxDBSet, cxSpinEdit, Buttons,Utablo, cxLookAndFeels,
  cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, cxPCdxBarPopupMenu, cxPC,
  cxLabel, JvExControls, JvNavigationPane, dxBarBuiltInMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations;

type
  TMaasTabloDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    GridMaas: TcxGrid;
    MaasTakvimView: TcxGridDBTableView;
    MaasTakvimViewTARIH: TcxGridDBColumn;
    MaasTakvimViewBANKA: TcxGridDBColumn;
    MaasTakvimViewKASA: TcxGridDBColumn;
    MaasTakvimViewKUR: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    DtsPlanMTablo: TDataSource;
    MaasTakvimViewFIRMA: TcxGridDBColumn;
    MaasTakvimViewKATEGORI: TcxGridDBColumn;
    TabloyuOlustur: TPopupMenu;
    OlusturMenu: TMenuItem;
    KasayagiderolarakIsleMenu: TMenuItem;
    BankayaexceltablosuhazrlaMenu: TMenuItem;
    MaasTakvimViewSEC: TcxGridDBColumn;
    PLANMTABLO: TFDQuery;
    N2: TMenuItem;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    MemoUyari: TcxMemo;
    MaasTakvimViewTAHAKKUKISLENDI: TcxGridDBColumn;
    MaasTakvimViewBANKAISLENDI: TcxGridDBColumn;
    MaasTakvimViewKASAISLENDI: TcxGridDBColumn;
    SeilileriTahakkukolarakile1: TMenuItem;
    SeilileriBankadandemeolarakile1: TMenuItem;
    SeilileriKasadandemeolarakile1: TMenuItem;
    MaasTakvimViewEXCELISLENDI: TcxGridDBColumn;
    ExceldenTabloyuolusturMenu: TMenuItem;
    TabloOlusturMenu: TMenuItem;
    DigerIslemlerMenu: TMenuItem;
    TabloyuSilMenu: TMenuItem;
    ExcelAlanEslestirmesiMenu: TMenuItem;
    MaasTakvimViewDURUM: TcxGridDBColumn;
    MaasTakvimViewTOPLAMMAAS: TcxGridDBColumn;
    SQLInsert: TMemo;
    MaasTakvimViewBORCLUBNKADI: TcxGridDBColumn;
    MaasTakvimViewALACAKLIBNKADI: TcxGridDBColumn;
    MaasTakvimViewBORCLUBNK: TcxGridDBColumn;
    MaasTakvimViewALACAKLIBNK: TcxGridDBColumn;
    BorcluBankaAtaMenu: TMenuItem;
    HepsinisecMenu: TMenuItem;
    HepsinikaldirMenu: TMenuItem;
    SecimiterscevirMenu: TMenuItem;
    AlacaklibankaataMenu: TMenuItem;
    MaasTakvimViewBORCLUKASA: TcxGridDBColumn;
    N1: TMenuItem;
    PersonelinKartnAcMenu: TMenuItem;
    PersonelinEkstresiniAcMenu: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    sttekinuygula1: TMenuItem;
    SeililereborluKasaata1: TMenuItem;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    frxMaasTablo: TfrxDBDataset;
    MaasTakvimViewBELGENO: TcxGridDBColumn;
    PanelAlt: TPanel;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxPageControl2: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    GridTahakkuk: TcxGrid;
    GridTahakkukView: TcxGridDBTableView;
    GridTahakkukViewETIKET: TcxGridDBColumn;
    GridTahakkukViewTUTAR: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    GridKesinti: TcxGrid;
    GridKesintiView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabTahakkuk: TFDQuery;
    DtsTahakkuk: TDataSource;
    TabKesinti: TFDQuery;
    DtsKesinti: TDataSource;
    SQLTahakkukInsert: TMemo;
    GridTahakkukViewKUR: TcxGridDBColumn;
    SQLUpdPlanMTablo: TMemo;
    MaasTakvimViewTAHAKKUK: TcxGridDBColumn;
    MaasTakvimViewKESINTI: TcxGridDBColumn;
    SQLKesInsert: TMemo;
    GridKesintiViewColumn1: TcxGridDBColumn;
    GridKesintiViewColumn2: TcxGridDBColumn;
    GridKesintiViewColumn3: TcxGridDBColumn;
    MaasTakvimViewODEBANKA: TcxGridDBColumn;
    MaasTakvimViewODEKASA: TcxGridDBColumn;
    MaasOdemeMemo: TMemo;
    AvansOdemeMemo: TMemo;
    AvansInsert: TMemo;
    KasayaAvansOlarakIsle: TMenuItem;
    MaasTakvimViewID: TcxGridDBColumn;
    MaasTakvimViewAGI: TcxGridDBColumn;
    PopupMenuTahakkuk: TPopupMenu;
    TahakkukDuzenle: TMenuItem;
    GridTahakkukViewSIRA: TcxGridDBColumn;
    PopupMenuKesinti: TPopupMenu;
    KesintiDuzenle: TMenuItem;
    AvansMaasIsle: TMemo;
    N6: TMenuItem;
    ExceldenPrimleriTabloyaEkleMenu: TMenuItem;
    frxTahakkuk: TfrxDBDataset;
    frxKesinti: TfrxDBDataset;
    SQLMesaiGetir: TMemo;
    SQLDevamsizlikGetir: TMemo;
    LabelMaasAralik: TcxLabel;
    TabKesintiYaz: TFDQuery;
    MaasTabloYaz: TFDQuery;
    SQLKesDevir: TMemo;
    Panel1: TPanel;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    CarsafListe: TToolButton;
    PanelYeniIs: TJvNavPanelHeader;
    ComboAy: TcxComboBox;
    ComboYil: TcxSpinEdit;
    ComboOdemeTuru: TcxComboBox;
    SQLUpdPlanMTablo2Adim: TMemo;
    SQLTahakkukInsert_Kopya: TMemo;
    MaasTakvimViewOZELKOD: TcxGridDBColumn;
    procedure ComboAyPropertiesChange(Sender: TObject);
    procedure TabloOlusturMenuClick(Sender: TObject);
    procedure MaasTakvimViewMAASPropertiesChange(Sender: TObject);
    procedure ExceldenTabloyuolusturMenuClick(Sender: TObject);
    procedure TabloyuSilMenuClick(Sender: TObject);
    procedure ExcelAlanEslestirmesiMenuClick(Sender: TObject);
    procedure BankayaexceltablosuhazrlaMenuClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SeilileriTahakkukolarakile1Click(Sender: TObject);
    procedure SeilileriBankadandemeolarakile1Click(Sender: TObject);
    procedure SeilileriKasadandemeolarakile1Click(Sender: TObject);
    function RehberdenMasrafMerkesiGetir(RehID:Integer):Integer;
    procedure PLANMTABLOCalcFields(DataSet: TDataSet);
    procedure BorcluBankaAtaMenuClick(Sender: TObject);
    procedure HepsinisecMenuClick(Sender: TObject);
    procedure AlacaklibankaataMenuClick(Sender: TObject);
    procedure PersonelinKartnAcMenuClick(Sender: TObject);
    procedure sttekinuygula1Click(Sender: TObject);
    procedure TabloyuOlusturPopup(Sender: TObject);
    procedure SeililereborluKasaata1Click(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure MaasTakvimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure PLANMTABLOAfterScroll(DataSet: TDataSet);
    procedure OdemeTuruPropertiesChange(Sender: TObject);
    procedure KasayaAvansOlarakIsleClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MaasTakvimViewSECPropertiesEditValueChanged(Sender: TObject);
    procedure PLANMTABLOAfterOpen(DataSet: TDataSet);
    procedure TahakkukDuzenleClick(Sender: TObject);
    procedure PopupMenuTahakkukPopup(Sender: TObject);
    procedure PopupMenuKesintiPopup(Sender: TObject);
    procedure KesintiDuzenleClick(Sender: TObject);
    procedure ExceldenPrimleriTabloyaEkleMenuClick(Sender: TObject);
    procedure CarsafListeClick(Sender: TObject);
    procedure MaasTabloYazAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    function PersonelEksikHesapBilgisi(SQL, Uyari : string) : Boolean;
    function Banka_Adi(ID:String) : string;
    procedure HazirlaMaasTabloParams(ASorgu: TFDQuery);
    procedure PlanMTabloGuncelle;
  public
    { Public declarations }
  end;

implementation
uses Umesaj, UCombo, Fetautil, UAnaForm, UAramaYokFrame, UFastRap, UGenelAnaSekmeFrame, URaporAraclari,
      FetaClassExtensions,FetaKurulusSiniflari,UGirisKutusuEx,PrjConst,UMaasListe,LocOnFly, UVeriMotor;
{$R *.dfm}
var
   BasTarihi, BitTarihi: TDateTime;
   //PdksBasTarihi, PdksBitTarihi
   MaasGunu, AvansGunu : smallint;
   PersonelID : Integer;
   Yazdiriliyor:Boolean;

procedure TMaasTabloDlg.HazirlaMaasTabloParams(ASorgu: TFDQuery);
begin
  if Pos(':T1', UpperCase(ASorgu.SQL.Text)) > 0 then
    if ASorgu.FindParam('T1') = nil then
      with ASorgu.Params.Add do
      begin
        Name := 'T1';
        ParamType := ptInput;
        DataType := ftDateTime;
      end
    else
    begin
      ASorgu.ParamByName('T1').ParamType := ptInput;
      ASorgu.ParamByName('T1').DataType := ftDateTime;
    end;

  if Pos(':T2', UpperCase(ASorgu.SQL.Text)) > 0 then
    if ASorgu.FindParam('T2') = nil then
      with ASorgu.Params.Add do
      begin
        Name := 'T2';
        ParamType := ptInput;
        DataType := ftDateTime;
      end
    else
    begin
      ASorgu.ParamByName('T2').ParamType := ptInput;
      ASorgu.ParamByName('T2').DataType := ftDateTime;
    end;

  if Pos(':DRM', UpperCase(ASorgu.SQL.Text)) > 0 then
    if ASorgu.FindParam('DRM') = nil then
      with ASorgu.Params.Add do
      begin
        Name := 'DRM';
        ParamType := ptInput;
        DataType := ftInteger;
      end
    else
    begin
      ASorgu.ParamByName('DRM').ParamType := ptInput;
      ASorgu.ParamByName('DRM').DataType := ftInteger;
    end;

  if Pos(':PDRM', UpperCase(ASorgu.SQL.Text)) > 0 then
    if ASorgu.FindParam('PDRM') = nil then
      with ASorgu.Params.Add do
      begin
        Name := 'PDRM';
        ParamType := ptInput;
        DataType := ftInteger;
      end
    else
    begin
      ASorgu.ParamByName('PDRM').ParamType := ptInput;
      ASorgu.ParamByName('PDRM').DataType := ftInteger;
    end;
end;

procedure TMaasTabloDlg.TahakkukDuzenleClick(Sender: TObject);
var
  Tutar:Variant;
  Baslik,YerID,PlanMTabloID,Sira:string;
  mResult:TModalResult;
begin
  if GridTahakkukView.Controller.SelectedRecordCount > 0 then begin
    Baslik := TabTahakkuk.FieldByName('ETIKET').AsString;
    Tutar := TabTahakkuk.FieldByName('TUTAR').AsString;
    mResult := TGirisKutusuEx.BilgiAlEx(Baslik+BGTutari_duzenle,TGirdiDenetimleri.Create.CurrencyEdit(BGTutar,@Tutar,2));
    if mResult = mrOk then begin
      YerID := PLANMTABLO.FieldByName('ID').AsString;
      PlanMTabloID := TabTahakkuk.FieldByName('ID').AsString;
      Sira := TabTahakkuk.FieldByName('SIRA').AsString;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE PLANMAAS SET TUTAR=&TUTAR WHERE ID=&ID',['&TUTAR','&ID'],[Tutar,PlanMTabloID]);
      PlanMTabloGuncelle;
      TabloYenile(PLANMTABLO,[BasTarihi,BitTarihi, ComboOdemeTuru.ItemIndex]);
      TabloYenile(TabTahakkuk,[YerID]);
    end;
  end;
end;

procedure TMaasTabloDlg.PlanMTabloGuncelle();
begin
  Tablo.Query4.Close;
  Tablo.Query4.SQL.Text := StringReplace(SQLUpdPlanMTablo.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
  Tablo.Query4.SQL.Text := StringReplace(Tablo.Query4.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
  if ComboOdemeTuru.ItemIndex = 2  then //'İşten çıkış'
     Tablo.Query4.SQL.Text := StringReplace(Tablo.Query4.SQL.Text, '--REHBERID', ' and REHBERID='+IntToStr(PersonelID), [rfReplaceAll]);
  if AktifVeriMotor = vmPG then Tablo.Query4.SQL.Text := PgSqlCevir(Tablo.Query4.SQL.Text);
  Tablo.Query4.Params[0].Value:=ComboOdemeTuru.ItemIndex;
  Tablo.Query4.ExecSQL;
  //tahakkukların ikinci aşamasını yapıyoruz. Prim ya da maaş çalışan varsa ya prime ya da maaşa göre tahakkuk update ediliyor
  Tablo.Query4.Close;
  Tablo.Query4.SQL.Text := StringReplace(SQLUpdPlanMTablo2Adim.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
  Tablo.Query4.SQL.Text := StringReplace(Tablo.Query4.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
  if ComboOdemeTuru.ItemIndex = 2  then //'İşten çıkış'
     Tablo.Query4.SQL.Text := StringReplace(Tablo.Query4.SQL.Text, '--REHBERID', ' and REHBERID='+IntToStr(PersonelID), [rfReplaceAll]);
  if AktifVeriMotor = vmPG then Tablo.Query4.SQL.Text := PgSqlCevir(Tablo.Query4.SQL.Text);
  Tablo.Query4.Params[0].Value:=ComboOdemeTuru.ItemIndex;
  Tablo.Query4.ExecSQL;
end;

procedure TMaasTabloDlg.AlacaklibankaataMenuClick(Sender: TObject);
var HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
begin
  //Önce borçlu banka Id si alalım
  HESAPID := PLANMTABLO.FieldByName('REHBERID').AsString;
  if not Tablo.BankaHesapEkrani(41,HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then
    exit;
  // değiştir
  PLANMTABLO.Edit;
  PLANMTABLO.FieldByName('ALACAKLIBNK').AsInteger := StrToIntDef(HESAPID,0);
  PLANMTABLO.Post;
  //Tablo.Query1.Close;
  //Tablo.Query1.SQL.Text := ' update PLANMTABLO set BORCLUBNK='+HESAPID+
  //      ' where SEC=1 and BANKAISLENDI = 0 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
  //Tablo.Query1.ExecSQL;
  //ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.BankayaexceltablosuhazrlaMenuClick(Sender: TObject);
var Excel, kitap, sayfa: variant;
    Satir, I, J, Adsoyad, HesapNo, Maas, Subeno : SmallInt;
    tut, s : string;
    kelimelist : TStringList;

    function SatirBul : Integer;
    var sat, sut, say, bulsat : SmallInt;
         function Bul : Boolean;
         begin
            i := 0;
            j := kelimelist.Count-1;
            while i < j do
              if Pos(kelimelist[i], tut) > 0 then
                 i := 999
              else
                 Inc(i);
           result := i = 999;
         end;
    begin
         // burada excelde ad soyad maaş gibi bilgilrerin yazılacağı satırı buluruz
         for sat := 1 to 15 do begin
           say := 0;
           for sut := 1 to 10 do begin
               tut := sayfa.Cells[Sat, Sut].Value;
               if tut <> '' then begin
                  tut := UpStr(tut);
                  if (tut<>'')and(Bul) then //bulundu
                     Inc(say);
               end;
           end;
           if say >= 3 then begin
              bulsat := sat;
              Break;
           end;
         end;

         if say >= 3 then
            Result := bulsat
         else
            Result := -1;
    end;

    function  KolonBul(s:String): Integer;
    var bulsat, sut : SmallInt;
    begin
       bulsat := -1;
       for sut := 1 to 10 do begin
           tut := sayfa.Cells[Satir, Sut].Value;
           if tut <> '' then begin
              tut := UpStr(tut);
              if Pos(s, UpStr(tut))>0 then begin//bulundu
                 bulsat := sut;
                 Break;
              end;
           end;
       end;
       Result := bulsat;
    end;

    function ExcelDosyasiAc:Boolean;
    begin
       if OpenDialog1.Execute then begin
          Excel := CreateOleObject('Excel.Application');
         //Excel kitabı ekranda görülmesin Excel.visible:=false;
          kitap:=Excel.Workbooks.Open(OpenDialog1.FileName);
         //birinci sayfayı seç
         sayfa:= kitap.worksheets[1];
         Result := True;
       end else
         Result := False;
    end;

    procedure ExceleKaydet;
    var I : SmallInt;
    begin
       kelimelist := TStringList.Create;
       for I := 0 to Memo1.Lines.Count - 1 do
           kelimelist.Add(Memo1.Lines[I]);
       Satir := SatirBul;
       if Satir = -1 then begin
          ShowMessage(MTTutarSatiriBulunamadi);
          exit;
       end;

       Adsoyad := KolonBul('AD');
       if Adsoyad = -1 then raise Exception.Create(MTTutarSutunuBulunamadi);

       HesapNo := KolonBul('HESAP');
       if HesapNo = -1 then raise Exception.Create(MTHesapNoSutunuBulunamadi);

       Maas  := KolonBul('TUTAR');
       if Maas=-1 then Maas := KolonBul('MEBLA');
       if Maas=-1 then Maas := KolonBul('MAA');
       if Maas=-1 then raise Exception.Create(MTTutarSutunuBulunamadi);

       Subeno := KolonBul('ŞUBE');


       PLANMTABLO.First;
       while not PLANMTABLO.Eof do begin
          if PLANMTABLO.FieldByName('SEC').AsBoolean then begin
             Tablo.Query1.Close;
             Tablo.Query1.SQL.Text := 'select BANKA, SUBENO, SUBE, HESAPNO from REHBERBANKA where REHBERID='+PLANMTABLO.FieldByName('REHBERID').AsString+' and VARSAYILAN=1';
             if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
             Tablo.Query1.Open;
             if Tablo.Query1.RecordCount>0 then begin
                if (PLANMTABLO.FieldByName('EXCELISLENDI').AsBoolean=False)and(Tablo.Query5.FieldByName('BANKA').AsString = Tablo.Query1.FieldByName('BANKA').AsString) then begin
                   Inc(Satir);
                   sayfa.Cells[Satir, Adsoyad].Value := PLANMTABLO.FieldByName('FIRMA').AsString;
                   sayfa.Cells[Satir, HesapNo].Value := Tablo.Query1.FieldByName('HESAPNO').AsString;
                   sayfa.Cells[Satir, Maas].Value := PLANMTABLO.FieldByName('ODEBANKA').AsString;
                   if Subeno > -1 then
                      sayfa.Cells[Satir, Subeno].Value := Tablo.Query1.FieldByName('SUBENO').AsString;
                   //Excele işlendi olarak işaretle
                   PLANMTABLO.Edit;
                   PLANMTABLO.FieldByName('EXCELISLENDI').AsBoolean := True;
                   PLANMTABLO.Post;
                end
             end else
                ShowMessage(PLANMTABLO.FieldByName('FIRMA').AsString+MTHesapNoBulunamadi);
          end;
          PLANMTABLO.Next;
       end;

       //burada excelde altta satırlar kalmışsa onlar silinir
       Inc(Satir);
       tut := sayfa.Cells[Satir, Adsoyad].Value;
       while tut<>'' do begin
         sayfa.Cells[Satir, Adsoyad].Value := '';
         sayfa.Cells[Satir, HesapNo].Value := '';
         sayfa.Cells[Satir, Maas].Value := '';
         if Subeno > -1 then
            sayfa.Cells[Satir, Subeno].Value := '';
         Inc(Satir);
         tut := sayfa.Cells[Satir, Adsoyad].Value
       end;
    end;

    procedure ExcelDosyasiKapat;
    begin
        // Excel dosyası kapatılıyor.
       if not VarIsEmpty(Excel) then begin
           Excel.DisplayAlerts:= False;
           Excel.Save;
           //Excel mesajlarını görünteleme
           Excel.Quit;
           Excel := Unassigned;
       end;
    end;
begin
   // banka hesabı kontrolü
   if PersonelEksikHesapBilgisi('(BORCLUBNK is null or BORCLUBNK = '''' ) AND T.DURUM=1', MTBorcluBankaHesapNoEksik) then exit;
   if PersonelEksikHesapBilgisi('(ALACAKLIBNK is null or ALACAKLIBNK='''') AND T.DURUM=1', MTAlacakliBankaHesapNoEksik) then exit;
   //Hangi excel tablosu açılacak ona bakalım
   Tablo.Query5.Close;
   Tablo.Query5.SQL.Text := ' select distinct BORCLUBNK from PLANMTABLO where TARIH >=:T1 and TARIH<:T2 AND SEC=1 AND DURUM=1';
   if AktifVeriMotor = vmPG then Tablo.Query5.SQL.Text := PgSqlCevir(Tablo.Query5.SQL.Text);
   Tablo.Query5.Params[0].Value := BasTarihi;
   Tablo.Query5.Params[1].Value := BitTarihi;
   Tablo.Query5.Open;
   if Tablo.Query5.RecordCount < 1 then
      ShowMessage(MTHicSecimYapilmamis)
   else  //her banka için ayrı excel tablosu açılıp içine atılacak
      while not Tablo.Query5.Eof do begin
         ShowMessage(Banka_Adi(Tablo.Query5.Fields[0].AsString)+MTExcelTablosunuSecin );
         if not ExcelDosyasiAc then exit;
         ExceleKaydet;
         ExcelDosyasiKapat;
         Tablo.Query5.Next;
      end;
end;

function TMaasTabloDlg.EkranAdiAl: string;
begin
   Result := 'MaasDlg';
end;

procedure TMaasTabloDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar3.Owner), DokumAdi, EkranAdi, frxMaasTablo) then begin
      AFastReport.EnabledDataSets.Add(frxMaasTablo);
      AFastReport.EnabledDataSets.Add(frxTahakkuk);
      AFastReport.EnabledDataSets.Add(frxKesinti);
      AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
   end else begin
      MaasTabloYaz.SQL.Text := StringReplace(PLANMTABLO.SQL.Text, '--and SEC=1', ' and SEC=1 ', []);
      HazirlaMaasTabloParams(MaasTabloYaz);
      TabloYenile(MaasTabloYaz, [PLANMTABLO.Params[0].Value,PLANMTABLO.Params[1].Value,PLANMTABLO.Params[2].Value]);
      frxMaasTablo.DataSet := MaasTabloYaz;//PLANMTABLO;
      AFastReport.EnabledDataSets.Add(frxMaasTablo);
      AFastReport.EnabledDataSets.Add(frxTahakkuk);
      AFastReport.EnabledDataSets.Add(frxKesinti);
      AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
   end;
end;

procedure TMaasTabloDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  Yazdiriliyor:=True;
  TabKesinti.ControlsDisabled;
  TabTahakkuk.ControlsDisabled;
  PLANMTABLO.ControlsDisabled;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
  Yazdiriliyor:=False;
  TabKesinti.EnableControls;
  TabTahakkuk.EnableControls;
  PLANMTABLO.EnableControls;
end;

procedure TMaasTabloDlg.Baslatildi;
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;

  Yazdiriliyor:=False;

  Tablo.TablodanSorguAc(1,'select SIRA from PLANMAAS where YER=100 and YERID=-1');
  if Tablo.Query1.RecordCount>0 then
      MaasGunu := Tablo.Query1.fields[0].AsInteger
  else
      MaasGunu := 1;

  Tablo.TablodanSorguAc(1,'select SIRA from PLANMAAS where YER=101 and YERID=-1');
  if Tablo.Query1.RecordCount>0 then
      AvansGunu := Tablo.Query1.fields[0].AsInteger
  else
      AvansGunu := 1;

//  MaasTakvimView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\MaasListeGridi',true,false,[gsoUseFilter],'MaasListeGridi');
  Tablo.GridAyarRestore('MaasListeGridi',MaasTakvimView );

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  PopupMenuYaz.Images := aktifFrame.ImageList1;
  ComboYil.Value := Cariyil;
  ComboAy.ItemIndex := StrToInt(FormatDateTime('MM', Tablo.GENINI.BugunTrh))-1;
  ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.BorcluBankaAtaMenuClick(Sender: TObject);
var HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
begin
  //Önce borçlu banka Id si alalım
  HESAPID := '-1';
  if not Tablo.BankaHesapEkrani(39,HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then
    exit;
  // değiştir
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update PLANMTABLO set BORCLUBNK='+HESAPID+
        ' where SEC=1 and BANKAISLENDI = 0 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.ExecSQL;
  ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.Button1Click(Sender: TObject);
begin
  PLANMTABLO.Edit;
end;

procedure TMaasTabloDlg.CarsafListeClick(Sender: TObject);
begin
  Application.CreateForm(TMaasListeDlg, MaasListeDlg);
  MaasListeDlg.showmodal;
  MaasListeDlg.destroy;
end;

procedure TMaasTabloDlg.ComboAyPropertiesChange(Sender: TObject);
begin
  if ComboOdemeTuru.ItemIndex = 2 then begin
     BasTarihi := Tablo.GENINI.BugunTrh-500;
     BitTarihi  := Tablo.GENINI.BugunTrh;
  end
  else begin
     BasTarihi := StrToDate(IntToStr(MaasGunu)+FormatSettings.DateSeparator+IntToStr(ComboAy.ItemIndex+1)+FormatSettings.DateSeparator+IntToStr(ComboYil.Value)+'');
     BitTarihi  := SysUtils.IncMonth(BasTarihi)-1;
  end;
   //PdksBitTarihi  := StrToDate(IntToStr(MaasGunu)+FormatSettings.DateSeparator+IntToStr(ComboAy.ItemIndex+1)+FormatSettings.DateSeparator+IntToStr(ComboYil.Value)+'');
   //PdksBasTarihi  := SysUtils.incMonth(PdksBitTarihi,-1);

   LabelMaasAralik.Caption:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm',BasTarihi)+' - '+FormatDateTime('dd'+FormatSettings.DateSeparator+'mm',BitTarihi-1);

   PLANMTABLO.close;
   if ComboOdemeTuru.Text = 'Avans Ödemesi' then
      PLANMTABLO.SQL.Text := AvansOdemeMemo.Text
   else
      PLANMTABLO.SQL.Text := MaasOdemeMemo.Text;
   HazirlaMaasTabloParams(PLANMTABLO);
   //PLANMTABLO.Params[0].Value := BasTarihi;
   //PLANMTABLO.Params[1].Value := BitTarihi;
   //PLANMTABLO.Open;
   TabloYenile(PLANMTABLO,[BasTarihi, BitTarihi, ComboOdemeTuru.ItemIndex]);
end;

procedure TMaasTabloDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TMaasTabloDlg.ExcelAlanEslestirmesiMenuClick(Sender: TObject);
var
  s : string;
  ExcelMaasEsles_TcKimNo,ExcelMaasEsles_Maas,ExcelMaasEsles_Banka,
  ExcelMaasEsles_Agi,ExcelMaasEsles_Diger,ExcelMaasEsles_Kasa,ExcelMaasEsles_AvBanka,
  ExcelMaasEsles_AvKasa,ExcelMaasEsles_OdeBanka,ExcelMaasEsles_OdeKasa : Variant;
begin
  Tablo.TablodanSorguAc(1,'select * from GENINI where BOLUM between -25010 and -25019');
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_TcKimNo,[]) then
     ExcelMaasEsles_TcKimNo := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_Maas,[]) then
     ExcelMaasEsles_Maas := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_Agi,[]) then
     ExcelMaasEsles_Agi := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_Diger,[]) then
     ExcelMaasEsles_Diger := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_Banka,[]) then
     ExcelMaasEsles_Banka := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_Kasa,[]) then
     ExcelMaasEsles_Kasa := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_AvBanka,[]) then
     ExcelMaasEsles_AvBanka := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_AvKasa,[]) then
     ExcelMaasEsles_AvKasa := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_OdeBanka,[]) then
     ExcelMaasEsles_OdeBanka := Tablo.Query1.FieldByName('DEGER').AsString;
  if Tablo.Query1.Locate('BOLUM',Ops_ExcelMaasEsles_OdeKasa,[]) then
     ExcelMaasEsles_OdeKasa := Tablo.Query1.FieldByName('DEGER').AsString;

  if TGirisKutusuEx.BilgiAlEx(BGBaslama_tarih, TGirdiDenetimleri.Create
                .Edit(BGTC_no,@ExcelMaasEsles_TcKimNo)
                .Edit(BGMaas,@ExcelMaasEsles_Maas)
                .Edit(BGAgi,@ExcelMaasEsles_Agi)
                .Edit(BGDiger,@ExcelMaasEsles_Diger)
                .Edit(BGBanka,@ExcelMaasEsles_Banka)
                .Edit(BGKasa,@ExcelMaasEsles_Kasa)
                .Edit(BGAvans_banka,@ExcelMaasEsles_AvBanka)
                .Edit(BGAvans_kasa,@ExcelMaasEsles_AvKasa)
                .Edit(BGOde_banka,@ExcelMaasEsles_OdeBanka)
                .Edit(BGOde_kasa,@ExcelMaasEsles_OdeKasa)
                ) = mrOk then begin
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_TcKimNo,ExcelMaasEsles_TcKimNo);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_Maas,ExcelMaasEsles_Maas);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_Agi,ExcelMaasEsles_Agi);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_Diger,ExcelMaasEsles_Diger);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_Banka,ExcelMaasEsles_Banka);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_Kasa,ExcelMaasEsles_Kasa);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_AvBanka,ExcelMaasEsles_AvBanka);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_AvKasa,ExcelMaasEsles_AvKasa);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_OdeBanka,ExcelMaasEsles_OdeBanka);
     Tablo.GENINI.WriteInteger(Ops_ExcelMaasEsles_OdeKasa,ExcelMaasEsles_OdeKasa);
  end;

end;

procedure TMaasTabloDlg.ExceldenPrimleriTabloyaEkleMenuClick(Sender: TObject);
const TcKimNoSutunu=1;
      TutarSutunu=3;
var   Excel, kitap, sayfa: variant;
      PrimNo,PrimAd : String[20];
      tut : string;
      Sat:Smallint;
    procedure TahakkukTablosunaEkle(TCNo : String);
       function Kontrol(Sut:SmallInt) : String;
       begin
         if Sut > 0 then begin
            tut := sayfa.Cells[Sat, Sut].Value;
            if Tut = '' then
               Result := '0'
            else
               Result := Tut;
         end
         else
               Result := '0';
         Result := Stringreplace(Result,',','.',[]);
       end;
    begin
       Tablo.Query2.Close;
       Tablo.Query2.SQL.Text := 'select YER_ID, isnull(BH.ID,0) '+
               ' from REHBERBILGI RB left outer join BANKAHESAPLAR BH on RB.YER_ID=BH.REHBERID'+
               ' where YERI= 3  and  BILGI = '''+TCNo+''' '+
               ' order by BH.VARSAYILAN desc  ';
       if AktifVeriMotor = vmPG then Tablo.Query2.SQL.Text := PgSqlCevir(Tablo.Query2.SQL.Text);
       Tablo.Query2.Open;
       if Tablo.Query2.RecordCount < 1 then
          ShowMessage(TCNo+MTPersonelListesindeBulunamadi)
       else begin
           //Bu ay tabloda var mı
           Tablo.TablodanSorguAc(3,'select ID from PLANMTABLO where REHBERID='+Tablo.Query2.Fields[0].AsString+' and MONTH(TARIH)= '+IntToStr(ComboAy.ItemIndex+1));
           if Tablo.Query3.RecordCount < 1 then
              ShowMessage(TCNo+MTPersonelListesindeBulunamadi)
           else begin
               //prim bu ay için dahaönce eklendiyse update edilir
               Tablo.TablodanSorguAc(6,'select ID from PLANMAAS where YERID='+Tablo.Query3.Fields[0].AsString+' and YER=11 and SIRA=13');
               if Tablo.Query6.RecordCount < 1 then
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into PLANMAAS(YER,YERID,SIRA,ETIKET,TUTAR,KUR,EKLEYEN)values(11,'+Tablo.Query3.Fields[0].AsString+','+PrimNo+','''+PrimAd+''','+Kontrol(TutarSutunu)+','''+CariDoviz+''','+Kullanan+')',[],[])
               else
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update PLANMAAS set TUTAR = '+Kontrol(TutarSutunu)+' where ID='+Tablo.Query6.Fields[0].AsString,[],[]);
           end;
       end;
    end;
begin

  ShowMessage(MTAktarimkosullari);

    //Excel nesnesi oluştur
   if OpenDialog1.Execute then begin
        //Ekleyeceğimizprim bilgilerini alalım;
        Tablo.TablodanSorguAc(1,'select ADI,NO from REHBERVARSAYILAN where YERI=5 and NO=13');
        PrimNo := Tablo.Query1.Fields[1].AsString;
        PrimAd := Tablo.Query1.Fields[0].AsString;
        Excel := CreateOleObject('Excel.Application');
        //Excel kitabı ekranda görülmesin Excel.visible:=false;
        kitap:=Excel.Workbooks.Open(OpenDialog1.FileName);
        //birinci sayfayı seç
        sayfa:= kitap.worksheets[1];
        Sat:=2;
        //Verilen aralıktaki tüm hücrelere bakmak için döngü
        tut := sayfa.Cells[Sat, TcKimNoSutunu].Value;
        while tut <> '' do begin
           TahakkukTablosunaEkle(sayfa.Cells[Sat, TcKimNoSutunu].Value);
           Inc(Sat);
           tut := sayfa.Cells[Sat, TcKimNoSutunu].Value;
        end;
        // Excel dosyası kapatılıyor.
        if not VarIsEmpty(Excel) then begin
           Excel.DisplayAlerts:= False;
           //Excel mesajlarını görünteleme
           Excel.Quit;
           Excel := Unassigned;
        end;
        PlanMTabloGuncelle;
        ComboAyPropertiesChange(Self);
   end;
end;

procedure TMaasTabloDlg.ExceldenTabloyuolusturMenuClick(Sender: TObject);
var Excel, kitap, sayfa: variant;
    i,j,k, yer: integer;
    TcKimNo,Maas,Banka,Agi,Kasa,AvBanka,AvKasa,OdeBanka, OdeKasa, Sat : SmallInt;
    tut: string;
    bulundu : Boolean;
    tpl,tmaas,tagi:currency;
    procedure SutunlariOku;
    begin
       TcKimNo :=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_TcKimNo,-1);
       Maas :=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_Maas,-1);
       Banka:=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_Banka,-1);
       Agi :=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_Agi,-1);
       Kasa :=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_Kasa,-1);
       AvBanka := Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_AvBanka,-1);
       AvKasa :=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_AvKasa,-1);
       OdeBanka := Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_OdeBanka,-1);
       OdeKasa :=Tablo.GENINI.ReadInteger(Ops_ExcelMaasEsles_OdeKasa,-1);
       bulundu := False; //altta hangi satırdan itibaren veri var ona bakalım
       Sat := 1;
       repeat
         tut := sayfa.Cells[Sat, TcKimNo].Value;
         if Length(tut)=11 then
            bulundu := True
         else
            Inc(Sat);
       until bulundu;
    end;
    procedure MaasTablosunaEle(TCNo : String);
       function Kontrol(Sut:SmallInt) : String;
       begin
         if Sut > 0 then begin
            tut := sayfa.Cells[Sat, Sut].Value;
            if Tut = '' then
               Result := '0'
            else
               Result := Tut;
         end
         else
               Result := '0';
         Result := Stringreplace(Result,',','.',[]);
       end;
    begin
       Tablo.Query2.Close;
       Tablo.Query2.SQL.Text := 'select YER_ID, isnull(BH.ID,0) '+
               ' from REHBERBILGI RB left outer join BANKAHESAPLAR BH on RB.YER_ID=BH.REHBERID'+
               ' where YERI= 3  and  BILGI = '''+TCNo+''' '+
               ' order by BH.VARSAYILAN desc  ';
       if AktifVeriMotor = vmPG then Tablo.Query2.SQL.Text := PgSqlCevir(Tablo.Query2.SQL.Text);
       Tablo.Query2.Open;
       if Tablo.Query2.RecordCount < 1 then
          ShowMessage(TCNo+MTPersonelListesindeBulunamadi)
       else begin
           Tablo.Query1.Close;
//           tmaas:= StrToCurrDef(Kontrol(Maas),0);
//           tagi := StrToCurrDef(Kontrol(Agi),0);
//           tpl := tmaas+tagi;
           Tablo.Query1.SQL.Text := 'insert into PLANMTABLO (REHBERID, TARIH, SEC, MAAS,BANKA,VERGI,KASA,AVANSBANKA,AVANSKASA, '+
                       ' ODEBANKA,ODEKASA,ALACAKLIBNK,EXCELISLENDI,TAHAKKUKISLENDI,BANKAISLENDI,KASAISLENDI,KUR, EKLEYEN,TOPLAMMAAS,SUBEID) '+
                       'values('+ Tablo.Query2.Fields[0].AsString + ', cast('''+IntToStr(ComboAy.ItemIndex+1)+'/'+FormatDateTime('dd', Tablo.GENINI.BugunTrh)+'/'+IntToStr(ComboYil.Value)+''' as datetime), '+
                       '0,'+Kontrol( Maas)+','+Kontrol( Banka)+','+Kontrol( Agi)+','+Kontrol(Kasa)+','+Kontrol( AvBanka)+','+Kontrol( AvKasa)+','+
                       Kontrol( OdeBanka)+','+Kontrol( OdeKasa)+','+Tablo.Query2.Fields[1].asstring+',0,0,0,0,'''+CariDoviz+''','''+Kullanan+''','+Kontrol(Maas)+'+'+Kontrol(Agi)+','+IntToStr(SubeId)+')';
           if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
           Tablo.Query1.execsql;
           ComboAyPropertiesChange(Self);
       end;
    end;
begin
    //Excel nesnesi oluştur
  if OpenDialog1.Execute then begin
    Excel := CreateOleObject('Excel.Application');
    //Excel kitabı ekranda görülmesin Excel.visible:=false;
    kitap:=Excel.Workbooks.Open(OpenDialog1.FileName);
    //birinci sayfayı seç
    sayfa:= kitap.worksheets[1];
    //Verilen aralıktaki tüm hücrelere bakmak için döngü
    SutunlariOku;
    tut := sayfa.Cells[Sat, TcKimNo].Value;
    while tut <> '' do begin
      MaasTablosunaEle(sayfa.Cells[Sat, TcKimNo].Value);
      Inc(Sat);
      tut := sayfa.Cells[Sat, TcKimNo].Value;
    end;
    // Excel dosyası kapatılıyor.
    if not VarIsEmpty(Excel) then begin
      Excel.DisplayAlerts:= False;
      //Excel mesajlarını görünteleme
      Excel.Quit;
      Excel := Unassigned;
    end;
  end;
end;

procedure TMaasTabloDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TMaasTabloDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

function TMaasTabloDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TMaasTabloDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TMaasTabloDlg.Gorunmez;
begin

end;

procedure TMaasTabloDlg.GorunmezOlacak;
begin

end;

procedure TMaasTabloDlg.Gorunur;
begin

end;

procedure TMaasTabloDlg.GorunurOlacak;
begin

end;

procedure TMaasTabloDlg.HepsinisecMenuClick(Sender: TObject);
var s : string[50];
begin
    case TMenuItem(Sender).Tag of
      1 : s := 'SEC=1';
      2 : s := 'SEC=0';
      3 : s := 'SEC=(case when SEC = 1 then 0 else 1 end)';
    end;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := ' update PLANMTABLO set '+s+' where TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' '+
        ' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' AND DURUM='+IntToStr(ComboOdemeTuru.ItemIndex);
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;
    ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.MaasTabloYazAfterScroll(DataSet: TDataSet);
begin
   TabloYenile(TabTahakkuk, [MaasTabloYaz.FieldByName('ID').AsInteger]);
   if Yazdiriliyor then
//      TabloYenile(TabKesintiYaz, [MaasTabloYaz.FieldByName('ID').AsInteger, MaasTabloYaz.FieldByName('REHBERID').AsInteger,FormatDateTime('yyyy-mm-dd', BasTarihi),FormatDateTime('yyyy-mm-dd', BitTarihi)])
      TabloYenile(TabKesintiYaz, [MaasTabloYaz.FieldByName('ID').AsInteger, MaasTabloYaz.FieldByName('ID').AsInteger ])
   else
      TabloYenile(TabKesinti, [MaasTabloYaz.FieldByName('ID').AsInteger]);
end;

procedure TMaasTabloDlg.MaasTakvimViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=GridMaas;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=MaasTakvimView;
AnaForm.pmGridStil.Tags.Values[GridMaas.Name] := 'MaasListeGridi';
end;

procedure TMaasTabloDlg.MaasTakvimViewMAASPropertiesChange(Sender: TObject);
begin
  {MaasTakvimView.DataController.OnDataChanged := nil;
  try
    try
      with MaasTakvimView.Controller.FocusedRecord do begin
        Values[MaasTakvimViewKASA.Index] :=
          Values[MaasTakvimViewMAAS.Index] - Values[MaasTakvimViewBANKA.Index] - Values[MaasTakvimViewVERGI.Index];
      end;
    except

    end;
  finally
    MaasTakvimView.DataController.OnDataChanged := MaasTakvimViewDataControllerDataChanged;
  end; }

//   PLANMTABLO.FieldByName('KASA').AsCurrency := PLANMTABLO.FieldByName('MAAS').AsCurrency - PLANMTABLO.FieldByName('BANKA').AsCurrency - PLANMTABLO.FieldByName('VERGI').AsCurrency;
end;

procedure TMaasTabloDlg.MaasTakvimViewSECPropertiesEditValueChanged(
  Sender: TObject);
begin
 if DtsPlanMTablo.State = dsEdit then
 PLANMTABLO.Post;
end;

procedure TMaasTabloDlg.KesintiDuzenleClick(Sender: TObject);
var
  Tutar:Variant;
  Baslik,YerID,PlanMTabloID,Sira:string;
  mResult:TModalResult;
begin
  if GridKesintiView.Controller.SelectedRecordCount > 0 then begin
    Baslik := TabKesinti.FieldByName('ETIKET').AsString;
    Tutar := TabKesinti.FieldByName('TUTAR').AsString;
    mResult := TGirisKutusuEx.BilgiAlEx(Baslik+BGTutari_duzenle,TGirdiDenetimleri.Create.CurrencyEdit(BGTutar,@Tutar,2));
    if mResult = mrOk then begin
      YerID := PLANMTABLO.FieldByName('ID').AsString;
      PlanMTabloID := TabKesinti.FieldByName('ID').AsString;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE PLANMAAS SET TUTAR=&TUTAR WHERE ID=&ID',['&TUTAR','&ID'],[Tutar,PlanMTabloID]);
      PlanMTabloGuncelle;
      TabloYenile(PLANMTABLO,[BasTarihi,BitTarihi, ComboOdemeTuru.ItemIndex]);
      TabloYenile(TabKesinti,[YerID]);
    end;
  end;
end;

procedure TMaasTabloDlg.OdemeTuruPropertiesChange(Sender: TObject);
var
  I:Integer;
begin
  if ComboOdemeTuru.ItemIndex = 2 then begin
     BasTarihi := Tablo.GENINI.BugunTrh-500;
     BitTarihi  := Tablo.GENINI.BugunTrh;
     ComboAy.Visible := False;
     ComboYil.Visible := False;
   end else begin
     BasTarihi := StrToDate('1'+FormatSettings.DateSeparator+IntToStr(ComboAy.ItemIndex+1)+FormatSettings.DateSeparator+IntToStr(ComboYil.Value)+'');
     BitTarihi  := SysUtils.IncMonth(BasTarihi);
     ComboAy.Visible := True;
     ComboYil.Visible := True;
  end;
  PLANMTABLO.close;
  //Eğer ComboOdemeTuru seçili index'i 0 ise avans ödemesi 1 ise maaş ödemesidir
  case ComboOdemeTuru.ItemIndex of
    0:begin
      PLANMTABLO.SQL.Text := AvansOdemeMemo.Text;
      PLANMTABLO.Params[0].Value := BasTarihi;
      PLANMTABLO.Params[1].Value := BitTarihi;
      PLANMTABLO.Params[2].Value := ComboOdemeTuru.ItemIndex;
      //Avans ödemesinde Banka(dahil) kolonundan Toplammaas(dahil) kolonuna kadar olan kolonları gizle
      for I := (MaasTakvimViewBANKA.Index) to (MaasTakvimViewTOPLAMMAAS.Index) do
         MaasTakvimView.Columns[I].Visible := False;
      PanelAlt.Visible := False;
    end;
    1,2:begin
      PLANMTABLO.SQL.Text := MaasOdemeMemo.Text;
      PLANMTABLO.Params[0].Value := BasTarihi;
      PLANMTABLO.Params[1].Value := BitTarihi;
      PLANMTABLO.Params[2].Value := ComboOdemeTuru.ItemIndex;
      //Maaş ödemesinde Banka(dahil) kolonundan Toplammaas(dahil) kolonuna kadar olan kolonları göster
      for I := (MaasTakvimViewBANKA.Index) to (MaasTakvimViewTOPLAMMAAS.Index) do
         MaasTakvimView.Columns[I].Visible := True;
      PanelAlt.Visible := True;
    end;
  end;
  //PLANMTABLO.Open;
  TabloYenile(PLANMTABLO,[BasTarihi,BitTarihi, ComboOdemeTuru.ItemIndex]);
end;

procedure TMaasTabloDlg.PersonelinKartnAcMenuClick(Sender: TObject);
begin
  Tablo.IKSihirbazBaslat(0,PLANMTABLO.FieldByName('REHBERID').AsInteger,-100,-100, False);
end;

procedure TMaasTabloDlg.PopupMenu1Popup(Sender: TObject);
begin
//   if PLANMTABLO.RecordCount<1 then
//      raise Exception.Create('Önce listeyi oluşturun!');
end;

procedure TMaasTabloDlg.PopupMenuKesintiPopup(Sender: TObject);
begin
  TahakkukDuzenle.Enabled := (GridKesintiView.Controller.SelectedRecordCount>0);
end;

procedure TMaasTabloDlg.PopupMenuTahakkukPopup(Sender: TObject);
begin
  TahakkukDuzenle.Enabled := (GridTahakkukView.Controller.SelectedRecordCount>0);
end;

function TMaasTabloDlg.PersonelEksikHesapBilgisi(SQL, Uyari : string) : Boolean;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select T.REHBERID,R.KOD, R.FIRMA '+
                           ' from PLANMTABLO T inner join REHBER R on R.ID=T.REHBERID       '+
                           ' where SEC=1 and '+SQL+
                           ' and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.Open;
  if Tablo.Query1.RecordCount>0 then begin
      MemoUyari.Visible := True;
      MemoUyari.Clear;
      MemoUyari.Lines.Add(MTAsagidakiPersonellerden+Uyari);
      while not Tablo.Query1.eof do begin
         MemoUyari.Lines.Add( Tablo.Query1.Fields[1].AsString + ' ' + Tablo.Query1.Fields[2].AsString);
         Tablo.Query1.Next
      end;
  end
  else
      MemoUyari.Visible := False;
  Result := MemoUyari.Visible;
end;

procedure TMaasTabloDlg.SeililereborluKasaata1Click(Sender: TObject);
var  st : Tstringlist;
begin
  //Önce borçlu kasa Id si alalım
  st := Tstringlist.create;
  if Tablo.ListedenBilgiGetir(KasaListesi, 'select KASAKODU,KASAADI,ID from KASALAR where KASAADI like ''%<ara>%'' and DURUM = '+IntToStr(ComboOdemeTuru.ItemIndex)+' order by 1',st,[]) then begin
    // değiştir
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := ' update PLANMTABLO set BORCLUKASA='+st.Strings[2]+
          ' where SEC=1 and KASAISLENDI = 0 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;
  end;
  st.Free;
  ComboAyPropertiesChange(Self);
end;

function TMaasTabloDlg.RehberdenMasrafMerkesiGetir(RehID:Integer):Integer;
var Etiketler,Bilgiler:TArrayOfString;
begin
  Tablo.RehberEkBilgileriniGetir(RehID,2,[RehVars_Masraf_Merkezi],Etiketler,Bilgiler);
  if Bilgiler[0]<>'' then begin
    Tablo.TablodanSorguAc(5,'select ID from MASRAFGELIR where KOD=substring('''+Bilgiler[0]+''',0,(charindex('' '','''+Bilgiler[0]+''',0)))');
    Result := Tablo.Query5.Fields[0].AsInteger;
  end else
    Result := -99;
end;

procedure TMaasTabloDlg.SeilileriBankadandemeolarakile1Click(Sender: TObject);
var Tarih, BilgiGir:Variant;
begin
   //banka hesabı kontrolü
   if PersonelEksikHesapBilgisi('(BORCLUBNK is null or BORCLUBNK = '''') AND T.DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND T.ODEBANKA>0', MTBorcluBankaHesapNoEksik) then exit;
   //if PersonelEksikHesapBilgisi('(ALACAKLIBNK is null or ALACAKLIBNK='''')', MTAlacakliBankaHesapNoEksik) then exit;
   //banka ödeme
  //Tarihi al

  Tarih := (Tablo.GENINI.BugunTrhSaat);
  BilgiGir := 'Maaş Ödeme';
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(BGIslem_tarih_gir,@Tarih,dtkDate,'dd/MM/yyyy HH:mm:ss').Edit(BGAciklama_gir, @BilgiGir)) <> mrOk then
    Abort;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'Insert Into KASA (TUR, ISLEMTARIHI,PLANTARIHI, REHBERID, ACIKLAMA,HESAPTURU, HESAPID, BORC, ALACAK, KUR,'+
        ' MASRAFID,FATURAID, KREDIID,CEKSENETID, KASA, EKLEYEN,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU,YERI,YERID,R, EKSTREDEKULLAN, GIRISKAYNAK,BELGENO)'+
        ' select TUR=32, ISLEMTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+''',PLANTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+''', T.REHBERID, ACIKLAMA='''+VarToStr(BilgiGir) +''',''B'', BORCLUBNK, BORC=ODEBANKA, ALACAK=0,T.KUR,'+
        ' MASRAFID='+Tablo.GENINI.ReadString(Ops_IK_MaasMasrafKalemi,'0')+
        ',FATURAID=-1, KREDIID=-1, CEKSENETID=-1, KASA=1, EKLEYEN='''+Kullanan+''','+IntToStr(SubeId)+',DOVIZ_TUTARI=ODEBANKA,'''+CariDoviz+''',YERI='+ IntToStr(TabNo_PLANMTABLO)+',YERID=T.ID'+
        ',R=0, EKSTREDEKULLAN = 0, GIRISKAYNAK = '+IntToStr(Windows_Sekme_Giris)+', BELGENO ='''' '+
        ' from PLANMTABLO T inner join REHBER R on R.ID=T.REHBERID'+
        ' where SEC=1 and ODEBANKA>0 and BANKAISLENDI=0 AND T.DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.ExecSQL;
  //durumunu değiştir
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update PLANMTABLO set BANKAISLENDI=1'+
        ' where SEC=1 and BANKAISLENDI=0 AND DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND ODEBANKA>0.1 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.ExecSQL;
  ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.KasayaAvansOlarakIsleClick(Sender: TObject);
var
  GeriDonusID1,GeriDonusID2,I:Integer;
  PlanID:string;
begin
  //Personel bilgisinde KUR bilgisi varsa ve Durum=0(Avans Ödemesiyse) ODEBANKA ve ODEKASA toplamı 0'dam büyükse işleme izin veriliyor.
  if PersonelEksikHesapBilgisi('(KUR is null or KUR = '''' ) AND T.DURUM=0 AND (T.ODEBANKA+T.ODEKASA)>0', MTParaBirimiEksik) then exit;
  //Avans işle
  PLANMTABLO.First;
  for I := 0 to MaasTakvimView.DataController.RecordCount-1 do
  begin
    //Odekasa, OdeBanka bilgileri 0'dan büyükse ve seçilmiş satırsa işlem yapılacak
    if ((PLANMTABLO.FieldByName('ODEKASA').AsCurrency > 0.1) or (PLANMTABLO.FieldByName('ODEBANKA').AsCurrency > 0.1)) and (PLANMTABLO.FieldByName('SEC').AsBoolean) then begin
      PlanID := MaasTakvimView.DataController.GetValue(I,MaasTakvimViewID.Index);

      //Avans işlemi için kasa'ya borç kaydı açılıyor.
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'INSERT INTO KASA(DOVIZ_TUTARI, DOVIZ_KURU, TUR, ISLEMTARIHI, PLANTARIHI, REHBERID, ACIKLAMA, HESAPTURU, HESAPID, BORC, ALACAK, KUR,'+
      ' FATURAID,KREDIID,CEKSENETID,KASA,EKLEYEN,SUBEID,GERIDONUSID,YERI,YERID)'+
      ' SELECT 0, ''TL'', 40, ISLEMTARIHI=T.TARIH, PLANTARIHI=T.TARIH, T.REHBERID, ACIKLAMA='''+FormatdateTime('mmmm yyyy', BasTarihi)+' ''+ (SELECT CASE TUR WHEN ''B'' THEN ''Bankadan'' WHEN ''K'' THEN ''Kasadan'' '+
      ' END FROM dbo.PLANMAAS P WHERE P.YERID=T.REHBERID AND YER=61) + '' Avans Ödeme'',HESAPTURU=(SELECT TUR FROM dbo.PLANMAAS P WHERE P.YERID=T.REHBERID AND YER=61), HESAPID=(SELECT CASE TUR WHEN ''B'' THEN T.BORCLUBNK WHEN ''K'' THEN T.BORCLUKASA END '+
      ' FROM dbo.PLANMAAS P WHERE YER=61 AND P.YERID=T.REHBERID), BORC=(T.ODEBANKA+T.ODEKASA), ALACAK=0,'+
      ' T.KUR, FATURAID=-1, KREDIID=-1, CEKSENETID=-1,'+IntToStr(Kasa)+','''+ Kullanan + ''',' +IntToStr(SubeId)+',0,'+IntToStr(TabNo_PLANMTABLO)+',T.ID'+
      ' FROM PLANMTABLO T WHERE T.ID='+PlanID+' AND SEC=1 AND T.DURUM=0 AND (T.ODEBANKA+T.ODEKASA) > 0 AND (T.BANKAISLENDI=0 AND T.KASAISLENDI=0) AND'+
      ' TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''''+
      ' SELECT SCOPE_IDENTITY()';
      if AktifVeriMotor = vmPG then Tablo.Query3.SQL.Text := PgSqlCevir(Tablo.Query3.SQL.Text);
      Tablo.Query3.Open;

      //Insert'in id'si alınıp geni dönüş id olarak kullanılacak.
      GeriDonusID1 := Tablo.Query3.Fields[0].AsInteger;

      //Avans işlemi için kasa'ya alacak kaydı açılıyor.
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'INSERT INTO KASA(DOVIZ_TUTARI,DOVIZ_KURU,TUR,ISLEMTARIHI, PLANTARIHI, REHBERID, ACIKLAMA, HESAPTURU, HESAPID, BORC, ALACAK, KUR,'+
      ' FATURAID,KREDIID,CEKSENETID,KASA,EKLEYEN,SUBEID,GERIDONUSID,YERI,YERID)'+
      ' SELECT 0, ''TL'', 40, ISLEMTARIHI=T.TARIH, PLANTARIHI=T.TARIH, T.REHBERID, ACIKLAMA='''+FormatdateTime('mmmm yyyy', BasTarihi)+' ''+'+
      ' (SELECT CASE TUR WHEN ''B'' THEN ''Bankadan'' WHEN ''K'' THEN ''Kasadan'' END FROM dbo.PLANMAAS P '+
      ' WHERE P.YERID=T.REHBERID AND YER=61) + '' Avans Ödeme'',''K'',(SELECT ID FROM KASALAR WHERE KASATUR=196 AND KUR=''TL''),'+
      ' BORC=0, ALACAK=(T.ODEBANKA+T.ODEKASA), T.KUR, FATURAID=-1, KREDIID=-1, CEKSENETID=-1,'+IntToStr(Kasa)+','''+ Kullanan + ''',' +IntToStr(SubeId)+','+IntToStr(GeriDonusID1)+','+IntToStr(TabNo_PLANMTABLO)+',T.ID'+
      ' FROM PLANMTABLO T WHERE T.ID='+PlanID+' AND SEC=1 AND T.DURUM=0 AND (T.ODEBANKA+T.ODEKASA) > 0 AND '+
      ' (T.BANKAISLENDI=0 AND T.KASAISLENDI=0) AND TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''''+
      ' SELECT SCOPE_IDENTITY()';
      if AktifVeriMotor = vmPG then Tablo.Query3.SQL.Text := PgSqlCevir(Tablo.Query3.SQL.Text);
      Tablo.Query3.Open;

      //Insert'in id'si alınıp geri dönüş id olarak kullanılacak.
      GeriDonusID2 := Tablo.Query3.Fields[0].AsInteger;
      //İlk insert'ün Geridönüş id'si güncelleniyor
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE KASA SET GERIDONUSID=&GERIDONUSID WHERE ID=&ID',['&GERIDONUSID','&ID'],[GeriDonusID2,GeriDonusID1]);

     //Etiket := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SELECT ETIKET FROM REHBERAYAR WHERE YERI=5 AND VARSAYILAN=31 AND SIRA=&SIRA',['&SIRA'],[Sira],True);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO PLANMAAS (ETIKET,SIRA,TUTAR,TARIH, YERID, EKLEYEN, EKLEMETARIHI, TUR, YER, KUR, ACIKLAMA,DURUM) '+
       ' SELECT ETIKET=''Avans'',SIRA=0,TUTAR=(T.ODEBANKA+T.ODEKASA),T.TARIH, YERID=T.REHBERID, '+
       ' EKLEYEN='+Kullanan+', EKLEMETARIHI=getdate(), TUR=case when ODEBANKA>0 then ''B'' else ''K'' end, YER=1, T.KUR, ACIKLAMA='''',DURUM='+IntToStr(GeriDonusID2)+
       ' FROM PLANMTABLO T WHERE T.ID='+PlanID+' AND SEC=1 AND T.DURUM=0 AND (T.ODEBANKA+T.ODEKASA) > 0 AND '+
       ' (T.BANKAISLENDI=0 AND T.KASAISLENDI=0) AND TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+'''', [],[]) ;
    end;
    PLANMTABLO.Next;
  end;

  //Secili olan avanslardan kasa ise kasa islendi banka ise bankaislendi yapılıyor.
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE T SET KASAISLENDI=(CASE P.TUR WHEN ''K'' THEN 1 ELSE 0 END),'+
	'	BANKAISLENDI=(CASE P.TUR WHEN ''B'' THEN 1 ELSE 0 END) FROM dbo.PLANMTABLO T'+
  ' INNER JOIN PLANMAAS P ON P.YERID=T.REHBERID WHERE T.SEC=1 AND P.YER=61 AND T.KASAISLENDI=0'+
  ' AND T.BANKAISLENDI=0 AND T.TARIH >='''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' AND'+
  ' T.TARIH<'''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' AND (T.ODEKASA>0 OR T.ODEBANKA>0)',[],[]);

  ComboAyPropertiesChange(Self);
  ///  Önemli bilgiler
  ///  Durum=2 işten çıkış; 1'e maaş ödemesi 0 ise avans ödemesidir.
  ///  KasaTur=196 avans kasasıdır
  ///  YER=61 Standart avans ödemesidir
  ///  YER=51 Bankadan maaş ödemesidir
end;

procedure TMaasTabloDlg.SeilileriKasadandemeolarakile1Click(Sender: TObject);
var Tarih, BilgiGir : Variant;
   function SQLKomutugetir : string;
   begin
      Result := ' Insert Into KASA (TUR, ISLEMTARIHI,PLANTARIHI, REHBERID,BELGENO, ACIKLAMA, HESAPTURU, HESAPID, BORC, ALACAK, KUR,'+
                ' MASRAFID, DURUM,FATURAID, KREDIID,CEKSENETID, KASA, EKLEYEN, SUBEID, DOVIZ_TUTARI, DOVIZ_KURU, YERI, YERID,R,EKSTREDEKULLAN,GIRISKAYNAK)'+
                ' select TUR=31, ISLEMTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+''',PLANTARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+''', T.REHBERID,T.BELGENO, ACIKLAMA='''+ VarToStr(BilgiGir)+''',''K'', HESAPID=BORCLUKASA, BORC=ODEKASA, ALACAK=0,T.KUR,'+
                ' MASRAFID='+Tablo.GENINI.ReadString(Ops_IK_MaasMasrafKalemi,'0')+
                ', T.DURUM,FATURAID=-1, KREDIID=-1, CEKSENETID=-1, KASA=1, EKLEYEN='''+Kullanan+''','+IntToStr(SubeId)+',DOVIZ_TUTARI=ODEKASA,''TL'',YERI= '+IntToStr(TabNo_PLANMTABLO)+' ,YERID=T.ID, R=1, EKSTREDEKULLAN = 0,GIRISKAYNAK=1 '+
                ' from PLANMTABLO T inner join REHBER R on R.ID=T.REHBERID WHERE T.DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND T.ODEKASA>0';
   end;
begin
  if PersonelEksikHesapBilgisi('(BORCLUKASA is null or BORCLUKASA = '''' ) AND T.DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND T.ODEKASA>0.1', MTBorcluKasaBilgisiEksik) then
     exit;
   // kasa ödeme
  //Tarihi al
  Tarih := Tablo.GENINI.BugunTrhSaat;
  BilgiGir := 'Maaş Ödeme';
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(BGIslem_tarih_gir,@Tarih,dtkDate,'dd/MM/yyyy HH:mm:ss').Edit(BGAciklama_gir, @BilgiGir)) <> mrOk then
  Abort;
   Tablo.TablodanSorguAc(2,' select ID from MASRAFGELIR where VARSAYILAN=3 ');
      if Application.MessageBox(PChar(MTMakbuzNoVerilsinmi),PChar(MTMakbuzKesmeOnayi) , MB_YESNO) = IDYES then begin
         PLANMTABLO.ControlsDisabled;
         PLANMTABLO.First;
         while not PLANMTABLO.Eof do begin
            if (PLANMTABLO.FieldByName('SEC').AsBoolean) and (PLANMTABLO.FieldByName('ODEKASA').AsCurrency>0.1)and
               (not PLANMTABLO.FieldByName('KASAISLENDI').AsBoolean) then begin
               PLANMTABLO.Edit;
               PLANMTABLO.FieldByName('BELGENO').AsString := SiradakiMakbuzNumarasi(31);
               PLANMTABLO.FieldByName('KASAISLENDI').AsBoolean := True;
               PLANMTABLO.FieldByName('TOPLAMMAAS').AsCurrency := PLANMTABLO.FieldByName('ODEKASA').AsCurrency+PLANMTABLO.FieldByName('ODEBANKA').AsCurrency;
               PLANMTABLO.Post;
               Tablo.Query1.Close;
               Tablo.Query1.SQL.Text := SQLKomutugetir;
               Tablo.Query1.SQL.Add(' and T.ID='+PLANMTABLO.FieldByName('ID').AsString);
               if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
               Tablo.Query1.ExecSQL;
            end;
            PLANMTABLO.Next;
         end;
         PLANMTABLO.EnableControls;
      end
      else begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := SQLKomutugetir;
         Tablo.Query1.SQL.Add(' and SEC=1 and ODEKASA>0.1 and KASAISLENDI=0'+
                      ' and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ');
         if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
         Tablo.Query1.ExecSQL;
        //durumunu değiştir
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := ' update PLANMTABLO set KASAISLENDI=1'+
            ' where SEC = 1 and ODEKASA>0.1 AND KASAISLENDI=0 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
         if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
         Tablo.Query1.ExecSQL;
      end;
      ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TMaasTabloDlg.SeilileriTahakkukolarakile1Click(Sender: TObject);
 var Tarih, BilgiGir :variant;
 begin
  if PersonelEksikHesapBilgisi('(KUR is null or KUR = '''' ) AND T.DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND T.TAHAKKUK>0', MTParaBirimiEksik) then exit;
  //Tarih sor
  Tarih := (Tablo.GENINI.BugunTrhSaat);
  BilgiGir := 'Maaş Tahakkuk';
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(BGIslem_tarih_gir,@Tarih,dtkDate,'dd/MM/yyyy HH:mm:ss').Edit(BGAciklama_gir, @BilgiGir)) <> mrOk then
    Abort;
  //Tahakkuk işle
  Tablo.Query1.Close;                                   //gelmediği günleri çıkaralaım
  Tablo.Query1.SQL.Text := 'Insert Into FATBASLIK (TUR,TARIH,FATURATARIH,REHBERID,ACIKLAMA,FATURA_TUTARI,KUR, '
    +'TIPI,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR,EKSTREDEKULLAN,RAPORDOVIZ, '
    +'MASRAFID,DURUM,KASA,YERI,YERID,EKLEYEN,SUBEID) '
    +'select TUR=13,TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+''', FATURATARIH='''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+''',T.REHBERID,ACIKLAMA='''+VarToStr(BilgiGir)+''', '
    +'FATURA_TUTARI=T.TAHAKKUK-( select ISNULL(SUM(TUTAR),0.0) from PLANMAAS where YER=21 and YERID=T.ID AND SIRA=15) ,T.KUR, '
    +'TIPI=1,DOVIZ_TUTARI=T.TAHAKKUK-( select ISNULL(SUM(TUTAR),0.0) from PLANMAAS where YER=21 and YERID=T.ID AND SIRA=15), '
    +'DOVIZ_CINSI=T.KUR,DOVIZKUR=1.0,EKSTREDEKULLAN=0,RAPORDOVIZ=T.KUR,'
    +'MASRAFID='+Tablo.GENINI.ReadString(Ops_IK_MaasMasrafKalemi,'0')
    +',T.DURUM,KASA='+IntToStr(Kasa)+',YERI='+IntToStr(TabNo_PLANMTABLO)+',YERID=T.ID, EKLEYEN='''+Kullanan+''','+IntToStr(SubeId)
    +'from PLANMTABLO T inner join REHBER R on R.ID=T.REHBERID   '
    +'where T.SEC=1 and TAHAKKUKISLENDI=0 and T.DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND T.TAHAKKUK>0 AND TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;
  //durumunu değiştir
  //Burada alınmış olan avanslar maaştan düşülür.
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := StringReplace(AvansMaasIsle.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
  Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.ExecSQL;


  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update PLANMTABLO set TAHAKKUKISLENDI=1'+
        ' where SEC=1 and TAHAKKUKISLENDI=0 AND TAHAKKUK>0 AND DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' ';
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.ExecSQL;
  ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TMaasTabloDlg.sttekinuygula1Click(Sender: TObject);
begin
    SeilileriTahakkukolarakile1Click(Self);
    SeilileriBankadandemeolarakile1Click(Self);
    SeilileriKasadandemeolarakile1Click(Self);
end;

procedure TMaasTabloDlg.TabloOlusturMenuClick(Sender: TObject);
var
  AvansTutari, OdemeKaynagi, Tutar, Tarih:Variant;
  YerID,FirmaAdi:string;
  Degisti:Boolean;
  mResult:TModalResult;
  Yil, Ay, Gun : Word;
begin
  if (ComboOdemeTuru.ItemIndex<2)and(PLANMTABLO.RecordCount>0) then
     raise Exception.Create(MTOnceMaasTablosunuBosalt);

  if ComboOdemeTuru.ItemIndex=2 then begin//işten çıkış  ise personel seç, çıkış tarihi al
     PersonelID := Tablo.RehberAra_IDGetir(335);
     if PersonelID < 1 then Abort;
     Tarih := Tablo.GENINI.BugunTrh;
     if TGirisKutusuEx.BilgiAlEx(FWCikis, TGirdiDenetimleri.Create.DateTimePicker(BGIsten_cikis_tarih+':', @Tarih,dtkDate)) <> mrOk then
        Abort;
     BitTarihi := TDateTime(Tarih);     //31/3/2016
     DecodeDate(BitTarihi, Yil, Ay, Gun);
     if MaasGunu>Gun then
        Dec(Ay);
     BasTarihi := StrToDate(IntToStr(MaasGunu)+FormatSettings.DateSeparator+IntToStr(Ay)+FormatSettings.DateSeparator+IntToStr(Yil)+''); // 15/02/2016
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PLANMTABLO set SEC=0 where SEC=1',[],[]);
  end;


  Tablo.Query1.Close;
  if ComboOdemeTuru.ItemIndex>0  then begin //  'Maaş Ödemesi' veya 'İşten çıkış'
//     Tablo.Query1.SQL.Text := StringReplace(SQLInsert.Text, ':PTRH', FormatDateTime('yyyy-mm-dd', StrToDateDef(IntToStr(MaasGunu)+FormatSettings.DateSeparator+
     Tablo.Query1.SQL.Text := StringReplace(SQLInsert.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
     Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
     if ComboOdemeTuru.ItemIndex = 2  then //'İşten çıkış'
        Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, '--R.ID', ' and R.ID='+IntToStr(PersonelID), [rfReplaceAll]);
     if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
     Tablo.Query1.Params[0].Value:=ComboOdemeTuru.ItemIndex;
     Tablo.Query1.ExecSQL;
    //Burada personelin sayfasındaki tahakkukları getiririz.
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := StringReplace(SQLTahakkukInsert.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
     Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
     if ComboOdemeTuru.ItemIndex = 2  then //'İşten çıkış'
        Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, '--M.YERID', ' and M.YERID='+IntToStr(PersonelID), [rfReplaceAll]);
     if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
     Tablo.Query1.Params[0].Value:=11;
     Tablo.Query1.Params[1].Value:=0;
     Tablo.Query1.ExecSQL;
     //Burada ek olarak girilmiş kesintileri getiririz
     Tablo.Query1.Close;
     Tablo.Query1.Params[0].Value:=21;
     Tablo.Query1.Params[1].Value:=91;
     Tablo.Query1.ExecSQL;
    //Eğer ayarlarda "Mesai" varsa pdks'den bakılarak onlar da eklenir
     Tablo.TablodanSorguAc(1, 'select * from REHBERAYAR where YERI=5 and VARSAYILAN=17');
     if Tablo.Query1.RecordCount>0 then begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := StringReplace(SQLMesaiGetir.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
        Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
        if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
        Tablo.Query1.ExecSQL;
     end;
     PlanMTabloGuncelle;
    //Burada personelin sayfasındaki devreden kesintileri getiririz.
    if Tablo.GENINI.ReadBoolean(Ops_IK_CheckMaasDevir, True) then begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := StringReplace(SQLKesDevir.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
        Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
        if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
        Tablo.Query1.ExecSQL;
    end;
    //Burada personelin sayfasındaki kesintileri getiririz. Eğer ayarlarda "Gelmediği gün" varsa pdks'den bakılarak onlar da eklenir
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := StringReplace(SQLKesInsert.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
    Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
    if ComboOdemeTuru.ItemIndex = 2  then //'İşten çıkış'
        Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, '--T.REHBERID', ' and T.REHBERID='+IntToStr(PersonelID), [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;
    Tablo.TablodanSorguAc(1, 'select * from REHBERAYAR where YERI=6 and VARSAYILAN=35');
    if Tablo.Query1.RecordCount>0 then begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := StringReplace(SQLDevamsizlikGetir.Text, 'BAŞLANGIÇTARİHİ', FormatDateTime('yyyy-mm-dd', BasTarihi), [rfReplaceAll]);
        Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, 'BİTİŞTARİHİ', FormatDateTime('yyyy-mm-dd', BitTarihi), [rfReplaceAll]);
        if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
        Tablo.Query1.ExecSQL;
    end;
    PlanMTabloGuncelle;
   {//Burada banka ödemesi girilmemiş olanların banka tutarını alırız
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'select R.ID,R.FIRMA,R.KOD,BELGENO='''','+
    ' BANKA=(SELECT ISNULL(SUM(TUTAR),0) FROM dbo.PLANMAAS PM WHERE PM.YER=51 AND PM.YERID=R.ID)'+
    ' from REHBER R'+
    ' where R.DURUM = 1 AND R.GRUP = 335';
    Tablo.Query3.Open;
    while not Tablo.Query3.Eof do begin
      YerID := Tablo.Query3.Fields[0].AsString;
      FirmaAdi := Tablo.Query3.FieldByName('FIRMA').AsString;
      Tablo.TablodanSorguAc(5,'SELECT TUTAR FROM PLANMAAS WHERE YERID='+YerID+' AND YER=51');
      if (Tablo.Query3.FieldByName('BANKA').AsInteger = 0) and Tablo.Query5.IsEmpty then begin
        Tutar := 0;
        mResult := TGirisKutusuEx.BilgiAlEx(FirmaAdi+BGBanka_maas_tutar,TGirdiDenetimleri.Create
        .CurrencyEdit('Tutar',@Tutar,2));

        if mResult = mrOk then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO PLANMAAS (TUTAR,YER,YERID,KUR,EKLEYEN,EKLEMETARIHI)'+
            ' VALUES(&TUTAR,51,&YERID,&KUR,&EKLEYEN,GETDATE())',
            ['&TUTAR','&YERID','&KUR','&EKLEYEN'], [Tutar,YerID,CariDoviz,Kullanan]);
        end;
      end;
      Tablo.Query3.Next;
      Degisti := True;
    end;
    if Degisti then begin
      PlanMTabloGuncelle;
    end; }

  end else if ComboOdemeTuru.Text = 'Avans Ödemesi' then begin
    Tablo.Query1.SQL.Text := StringReplace(AvansInsert.Text, ':PTRH', FormatDateTime('yyyy-mm-dd', StrToDateDef(IntToStr(AvansGunu)+FormatSettings.DateSeparator+
              IntToStr(ComboAy.ItemIndex+1)+FormatSettings.DateSeparator+ComboYil.Text,Tablo.GENINI.BugunTrh )), [rfReplaceAll]);
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;

    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'select R.ID,R.FIRMA,R.KOD,BELGENO='''','+
    ' AVANS=(SELECT ISNULL(SUM(TUTAR),0) FROM dbo.PLANMAAS PM WHERE PM.YER=61 AND PM.YERID=R.ID)'+
    ' from REHBER R'+
    ' where R.DURUM > 0 AND R.GRUP = 335';
    if AktifVeriMotor = vmPG then Tablo.Query3.SQL.Text := PgSqlCevir(Tablo.Query3.SQL.Text);
    Tablo.Query3.Open;
    while not Tablo.Query3.Eof do begin
      YerID := Tablo.Query3.Fields[0].AsString;
      FirmaAdi := Tablo.Query3.FieldByName('FIRMA').AsString;
      Tablo.TablodanSorguAc(5,'SELECT TUTAR FROM PLANMAAS WHERE YERID='+YerID+' AND YER=61');
      if (Tablo.Query3.FieldByName('AVANS').AsInteger = 0) and Tablo.Query5.IsEmpty then begin
        AvansTutari := 0;
        OdemeKaynagi := 'K';
        mResult := TGirisKutusuEx.BilgiAlEx(FirmaAdi+BGAvans_miktari,TGirdiDenetimleri.Create
        .ImageComboBox('Ödeme kaynağı',@OdemeKaynagi,Tablo.FDCnn,'SELECT ''B'' TUR, ''Banka'' ADI UNION ALL SELECT ''K'' TUR, ''Kasa''')
        .CurrencyEdit('Avans tutarı',@AvansTutari,2));
        if mResult = mrOk then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO PLANMAAS (TUTAR,YER,YERID,KUR,TUR,EKLEYEN,EKLEMETARIHI)'+
          ' VALUES(&TUTAR,61,&YERID,&KUR,&TUR,&EKLEYEN,GETDATE())',
          ['&TUTAR','&YERID','&KUR','&TUR','&EKLEYEN'], [AvansTutari,YerID,CariDoviz,OdemeKaynagi,Kullanan]);
        end;
      end;
      Tablo.Query3.Next;
    end;
  end;

  HepsinisecMenuClick(Sender);
  ComboAyPropertiesChange(Self);
end;

procedure TMaasTabloDlg.TabloyuOlusturPopup(Sender: TObject);
var i : SmallInt;
begin
  if ComboOdemeTuru.Text = 'Maaş Ödemesi' then begin
    KasayagiderolarakIsleMenu.Visible := True;
    KasayaAvansOlarakIsle.Visible := False;
  end else if ComboOdemeTuru.Text = 'Avans Ödemesi' then begin
    KasayagiderolarakIsleMenu.Visible := False;
    KasayaAvansOlarakIsle.Visible := True;
  end;
  for i := 1 to TabloyuOlustur.Items.Count - 1 do
   TabloyuOlustur.Items[i].Enabled := (TabloyuOlustur.Items[i].Name='DigerIslemlerMenu')or(PLANMTABLO.RecordCount>0);
end;

procedure TMaasTabloDlg.TabloyuSilMenuClick(Sender: TObject);
var
  id:string;
  function IDGetir(sqltext:string):string;
    var id:string;
  begin
    with Tablo.Query2 do begin
      Close;
      SQL.Text := sqltext;
      Open;
      id:='0';
      while not Eof do begin
        id := id+','+Fields[0].AsString;
        Next;
      end;
    end;
    Result := id;
  end;
begin
  if ComboOdemeTuru.ItemIndex >= 1 then begin  //MAAŞ VE ÇIKIŞ
   //Öncelikle kasa ve fatbaslık'dan ilgili kayıtlar siliniyor
   id := IDGetir('SELECT ID FROM PLANMTABLO T WHERE SEC=1 AND DURUM='+IntToStr(ComboOdemeTuru.ItemIndex)+' AND T.TARIH >='''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and T.TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+'''');
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM KASA WHERE YERID IN ('+id+') AND YERI='+IntToStr(TabNo_PLANMTABLO),[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM FATBASLIK WHERE YERID IN ('+id+') AND YERI='+IntToStr(TabNo_PLANMTABLO),[],[]);
   //tahakkuk ve kesintileri silelim
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE M from  PLANMAAS M inner join PLANMTABLO T on YER in (11,21) and M.YERID=T.ID '+
         ' where  YER in (11,21) and T.SEC=1 and T.TARIH >='''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and T.TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+'''  ',[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from PLANMTABLO where SEC=1 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' AND DURUM='+IntToStr(ComboOdemeTuru.ItemIndex),[],[]);
  end else begin //'Avans Ödemesi'
   //Öncelikle kasa ve fatbaslık'dan ilgili kayıtlar siliniyor
   id := IDGetir('SELECT ID FROM PLANMTABLO T WHERE SEC=1 AND DURUM=0 AND T.TARIH >='''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and T.TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+'''');
   //Önce  PLANMAAS tablosundaki
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from PLANMAAS where YER=1 and DURUM in (select ID from KASA where YERI='+IntToStr(TabNo_PLANMTABLO)+' and '+
     ' YERID IN ('+id+') and ALACAK>0.0)',[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM KASA WHERE YERID IN ('+id+') AND YERI='+IntToStr(TabNo_PLANMTABLO),[],[]);
   //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM FATBASLIK WHERE YERID IN ('+id+') AND YERI='+IntToStr(TabNo_PLANMTABLO),[],[]);
   //Avans kayıtları siliniyor
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from PLANMTABLO where SEC=1 and TARIH >= '''+FormatDateTime('yyyy-mm-dd', BasTarihi)+''' and TARIH<='''+FormatDateTime('yyyy-mm-dd', BitTarihi)+''' AND DURUM=0',[],[]);
  end;
  ComboAyPropertiesChange(Self);
end;

function TMaasTabloDlg.Banka_Adi(ID:String) : string;
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := ' Select BANKAADI from BANKALAR B '+
             ' inner join BANKASUBELER BS on B.BANKAKODU=BS.BANKAKODU '+
             ' inner join BANKAHESAPLAR BH on BH.BANKASUBELERID=BS.ID '+
             ' where BH.ID='+ID;
   if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
   Tablo.Query1.Open;
   Result := Tablo.Query1.Fields[0].AsString;
end;

procedure TMaasTabloDlg.PLANMTABLOAfterOpen(DataSet: TDataSet);
begin
  MaasTakvimView.ApplyBestFit(nil);
end;

procedure TMaasTabloDlg.PLANMTABLOAfterScroll(DataSet: TDataSet);
begin
   TabloYenile(TabTahakkuk, [PLANMTABLO.FieldByName('ID').AsInteger]);
   if Yazdiriliyor then
//      TabloYenile(TabKesintiYaz, [PLANMTABLO.FieldByName('ID').AsInteger,PLANMTABLO.FieldByName('REHBERID').AsInteger,FormatDateTime('yyyy-mm-dd', BasTarihi),FormatDateTime('yyyy-mm-dd', BitTarihi)])
      TabloYenile(TabKesintiYaz, [MaasTabloYaz.FieldByName('ID').AsInteger, MaasTabloYaz.FieldByName('ID').AsInteger ])
   else
      TabloYenile(TabKesinti, [PLANMTABLO.FieldByName('ID').AsInteger]);
end;

procedure TMaasTabloDlg.PLANMTABLOCalcFields(DataSet: TDataSet);
begin
//   if (PLANMTABLOALACAKLIBNK.AsString <> '')and(PLANMTABLOALACAKLIBNKADI.AsString = '') then
//       PLANMTABLOALACAKLIBNKADI.AsString := Banka_Adi(PLANMTABLOALACAKLIBNK.AsString);
end;

procedure TMaasTabloDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMaasTabloDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TMaasTabloDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMaasTabloDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  Classes.RegisterClass(TMaasTabloDlg);

end.






