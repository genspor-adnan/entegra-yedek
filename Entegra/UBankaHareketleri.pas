unit UBankaHareketleri;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, Data.DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, dxmdaset,
  Vcl.ExtCtrls, cxCurrencyEdit, cxButtonEdit, FireDAC.Comp.Client, Vcl.Menus, Vcl.ComCtrls,
  Vcl.ToolWin, cxCheckBox, cxImageComboBox, cxSplitter, cxCalendar, cxTextEdit,
  cxContainer, JvExControls, JvNavigationPane, cxMemo, cxDropDownEdit, cxDBEdit,
  cxMaskEdit, cxLabel, dxDateRanges, dxScrollbarAnnotations, dxCoreGraphics,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TBankaHareketlerDlg = class(TForm)
    DtsHareket: TDataSource;
    Menu1: TPopupMenu;
    N1: TMenuItem;
    KuralListesiniAcMenu: TMenuItem;
    KurallarUygulaMenu: TMenuItem;
    N2: TMenuItem;
    TumunuSecMenu: TMenuItem;
    mnBrak1: TMenuItem;
    SeilileriTersevir1: TMenuItem;
    PopupMenuKural: TPopupMenu;
    IslemTipineGoreMenu: TMenuItem;
    AciklamayaGoreMenu: TMenuItem;
    TabImport: TFDQuery;
    DtsImport: TDataSource;
    PanelSol: TPanel;
    PanelSag: TPanel;
    Panel1: TPanel;
    GridHareket: TcxGrid;
    GridHareketView: TcxGridDBTableView;
    GridHareketViewSec: TcxGridDBColumn;
    GridHareketViewRecId: TcxGridDBColumn;
    GridHareketViewTarih: TcxGridDBColumn;
    GridHareketViewNo: TcxGridDBColumn;
    GridHareketViewGELENISLEMTIPI: TcxGridDBColumn;
    GridHareketViewAciklama: TcxGridDBColumn;
    GridHareketViewTutar: TcxGridDBColumn;
    GridHareketViewMasrafId: TcxGridDBColumn;
    GridHareketViewProjeId: TcxGridDBColumn;
    GridHareketLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    Panel2: TPanel;
    GridImport: TcxGrid;
    GridImportView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridImportViewBANKAKODU: TcxGridDBColumn;
    GridImportViewTOPSAY: TcxGridDBColumn;
    GridImportViewKALANSAY: TcxGridDBColumn;
    GridImportViewEKLEMETARIHI: TcxGridDBColumn;
    TabHareket: TFDQuery;
    ToolBar2: TToolBar;
    ToolButton3: TToolButton;
    YeniExcelTus: TToolButton;
    GridHareketViewDURUM: TcxGridDBColumn;
    TabHareketID: TAutoIncField;
    TabHareketBANKAIMPORTID: TIntegerField;
    TabHareketDURUM: TWordField;
    TabHareketSEC: TBooleanField;
    TabHareketTARIH: TDateTimeField;
    TabHareketNO: TWideStringField;
    TabHareketGELENISLEMTIPI: TWideStringField;
    TabHareketACIKLAMA: TWideStringField;
    TabHareketTUTAR: TBCDField;
    TabHareketKUR: TWideStringField;
    TabHareketPRGISLEMTIPI: TSmallintField;
    TabHareketHESAPID: TIntegerField;
    TabHareketMASRAFID: TIntegerField;
    TabHareketPROJEID: TIntegerField;
    TabHareketDEGISTIREN: TSmallintField;
    TabHareketDEGISTIRMETARIHI: TDateTimeField;
    anmszveEksikleriSe1: TMenuItem;
    HazrlarSe1: TMenuItem;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    KuralListesiTus: TToolButton;
    SilTus2: TToolButton;
    ToolButton9: TToolButton;
    KaydetTus: TToolButton;
    JvNavPanelHeader2: TJvNavPanelHeader;
    checkTanimsiz: TcxCheckBox;
    CheckEksik: TcxCheckBox;
    CheckHazir: TcxCheckBox;
    CheckKayitli: TcxCheckBox;
    SQLMemo: TcxMemo;
    TabHareketKURDEGERI: TCurrencyField;
    GridImportViewKUR: TcxGridDBColumn;
    BuSatirdaKuralTestEtMenu: TMenuItem;
    TabHareketEKLEME: TSmallintField;
    SilTus: TToolButton;
    Panel4: TPanel;
    PanelKur: TPanel;
    PanelMasraf: TPanel;
    PanelOdemeTipi: TPanel;
    Panel8: TPanel;
    LabelMasrafMerkezi: TcxLabel;
    EditMasrafKodu: TcxButtonEdit;
    ComboDovKur: TcxDBComboBox;
    EditKulKur: TcxDBCurrencyEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    LabelOdemeTipi: TcxLabel;
    ComboOdemeTipi: TcxDBImageComboBox;
    TabHareketODEMETIPI: TIntegerField;
    PanelHesap: TPanel;
    cxLabel3: TcxLabel;
    EditHesapAd: TcxTextEdit;
    cxLabel4: TcxLabel;
    EditHesapKod: TcxButtonEdit;
    Panel5: TPanel;
    cxLabel5: TcxLabel;
    ComboPRGISLEMTIPI: TcxDBImageComboBox;
    PanelProje: TPanel;
    LabelProjeKodu: TcxLabel;
    EditProje: TcxButtonEdit;
    cxLabel6: TcxLabel;
    EditMasrafAd: TcxTextEdit;
    GridHareketViewPRGISLEMTIPI: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure KuralListesiniAcMenuClick(Sender: TObject);
    procedure KurallarUygulaMenuClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure TumunuSecMenuClick(Sender: TObject);
    procedure IslemTipineGoreMenuClick(Sender: TObject);
    procedure TabImportAfterScroll(DataSet: TDataSet);
    procedure YeniExcelTusClick(Sender: TObject);
    procedure TabHareketBeforePost(DataSet: TDataSet);
    procedure GridHareketViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridHareketViewStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure checkTanimsizPropertiesChange(Sender: TObject);
    procedure GridHareketViewAciklamaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BuSatirdaKuralTestEtMenuClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabHareketAfterScroll(DataSet: TDataSet);
    procedure EditHesapKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxDBImageComboBox1PropertiesChange(Sender: TObject);
    procedure EditMasrafKoduPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    procedure TabloAc;
    procedure BirSatiraKuralUygula(var Liste : TStringList);
  public
    { Public declarations }
    BankaKur, BankaIBAN : String;
    BankaKodu, BankaHesapId : Integer;
  end;

var
  BankaHareketlerDlg: TBankaHareketlerDlg;

implementation

{$R *.dfm}

uses UTablo, UExceldenVeriAl, PrjConst, UBankaHareketKural, UGirisKutusuEx, FetaKurulusSiniflari, UAnaForm;

var
   KuralUygulaniyor : Boolean;

procedure TBankaHareketlerDlg.TabloAc;
var s:string;
   procedure Yap(C:TcxCheckBox; Tag:Smallint);
   begin
      if C.Checked then begin
         if s<>'' then s:=s+',';
         s:=s+IntToStr(Tag);
      end;
   end;
begin
   s:='';
   Yap(CheckTanimsiz, 0);
   Yap(CheckEksik, 1);
   Yap(CheckHazir, 2);
   Yap(CheckKayitli, 9);
   if s<>'' then
      TabHareket.SQL.Text := StringReplace(SQLMemo.Text, '-----', 'and DURUM in ('+s+')', [])
   else
      TabHareket.SQL.Text := SQLMemo.Text;
   TabloYenile(TabHareket, [TabImport.Fields[0].AsInteger]);
end;


procedure TBankaHareketlerDlg.checkTanimsizPropertiesChange(Sender: TObject);
begin
  TabloAc;
end;

procedure TBankaHareketlerDlg.cxDBImageComboBox1PropertiesChange(Sender: TObject);
var i : smallint;
begin
   //i := TabHareket.FieldByName('PRGISLEMTIPI').AsInteger;
   if ComboPRGISLEMTIPI.EditValue<>null then begin
      i := ComboPRGISLEMTIPI.EditValue;
      PanelHesap.Visible := i <> 132;
      PanelMasraf.Visible := (i=32)or(i=58)or(i=132)or(i=335);
      PanelKur.Visible := (TabImport.FieldByName('KUR').AsString<>CariDoviz)or(i in [47, 48]);
      if (PanelKur.Visible)and(TabImport.FieldByName('KUR').AsString<>CariDoviz) then begin
         ComboDovKur.EditValue := CariDoviz;
         ComboDovKur.Enabled := False
      end else begin
         ComboDovKur.EditValue := '';
         ComboDovKur.Enabled := True;
      end;
      PanelOdemeTipi.Visible := i = 335;
   end;
end;

procedure TBankaHareketlerDlg.EditHesapKodPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
   HesapListele(TabHareket, AButtonIndex, BankaKur, EditHesapKod,EditMasrafKodu, EditMasrafAd, EditHesapAd);
end;

procedure TBankaHareketlerDlg.EditMasrafKoduPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var MASRAFID,MASRAFKODU,MASRAFMERKEZI: string;
begin
    TabHareket.Edit;
    if AButtonIndex=0 then begin
       if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI)then begin
          TabHareket.FieldByName('MASRAFID').AsString := MASRAFID;
          EditMasrafKodu.Text := MASRAFKODU;
          EditMasrafAd.Text := MASRAFMERKEZI;
       end
     end else begin
          TabHareket.FieldByName('MASRAFID').AsString := '0';
          EditMasrafKodu.Text :='';
          EditMasrafAd.Text := '';
     end;
     TabHareket.Post;
end;

procedure TBankaHareketlerDlg.EditProjePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
   if Tablo.EditButtonaPROJEIDGonder(nil, TabHareket, AButtonIndex,ProjeSecimi, TabHareket.FieldByName('HESAPID').AsInteger) then begin
      if TabHareket.State = dsBrowse then
         TabHareket.Edit;
      EditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU', TabHareket.FieldByName('PROJEID').AsInteger);
   end;
end;

procedure TBankaHareketlerDlg.FormShow(Sender: TObject);
begin
   Tablo.GridTurkcelestir;
   Tablo.GridAyarRestore('BankaImportHareketGridi', GridHareketView);
   Tablo.GENINI.ReadImageSection(Ops_Banka_Excel_Atilacak, Tablo.RepAtilacakListe.Properties.Items, False);
   KuralUygulaniyor:=False;
   TabloYenile(TabImport, []);
   WindowState := wsMaximized;
end;

procedure TBankaHareketlerDlg.GridHareketViewAciklamaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var s1,s2:variant;
begin
   s1:=TabHareket.FieldByName('GELENISLEMTIPI').AsString;
   s2:=TabHareket.FieldByName('ACIKLAMA').AsString;
   TGirisKutusuEx.BilgiAlEx('', TGirdiDenetimleri.Create.Edit('Ýþlem Tipi', @s1).Memo('Açýklama', @s2));
end;

procedure TBankaHareketlerDlg.GridHareketViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridHareket;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridHareketView;
 // AnaForm.pmGridStil.Tags.Values[GridHareket.Name]:='BankaImportHareketGridi';
end;

procedure TBankaHareketlerDlg.GridHareketViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TBankaHareketlerDlg.IslemTipineGoreMenuClick(Sender: TObject);
var ACIKLAMA:Variant;
begin
   if TabHareket.State in [dsEdit, dsInsert] then
      TabHareket.Post;
   if TabHareket.FieldByName('PRGISLEMTIPI').AsInteger<1 then
      ShowMessage('Prg.Ýþlem Tipi dolu olmalýdýr!')
   else if (TabHareket.FieldByName('PRGISLEMTIPI').AsInteger<1)or((TabHareket.FieldByName('HESAPID').AsInteger<1)and(TabHareket.FieldByName('MASRAFID').AsInteger<1)) then
       ShowMessage('Hesap Kod veya Masraf Koddan biri dolu olmalýdýr!')
   else begin
       ACIKLAMA := TabHareket.FieldByName(TMenuItem(Sender).Hint).AsString;
       if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Memo('Ýçinde geçecek kelimeler:', @ACIKLAMA)) <> mrOk then
          Abort;
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into [BANKAKURAL]([BANKAKODU],KULLANICI,PRGISLEMTIPI,[TUR],TARAMA_KOLONU,[DEGER_GECEN],[HESAPID],[MASRAFID])values(0,1,'+
       TabHareket.FieldByName('PRGISLEMTIPI').AsString+',2,'+IntToStr(TMenuItem(Sender).Tag)+','''+VarToStr(ACIKLAMA)+''','+TabHareket.FieldByName('HESAPID').AsString+','+TabHareket.FieldByName('MASRAFID').AsString+')',[],[]);
   end;
end;

procedure TBankaHareketlerDlg.KaydetTusClick(Sender: TObject);
var s,s2 : string;
    Tur : Integer;
   procedure Kasa_Islemleri(CiftSatir:Boolean; Tur, RehberId:Integer;HesapTur:char;Kur:String; Borc, Alacak : Currency;FaturaId:Integer=0; KrediId:Integer=0;Yer:Integer=0;YerId:Integer=0);
   var ID,ID2:integer;
       KurDegeri:Real;
       DovizDegeri:Currency;
   begin
      KurDegeri := 1;
      if BankaKur<>CariDoviz then //döviz hareketi ise TL deðerini de yazalým
         KurDegeri:=TabHareket.FieldByName('KURDEGERI').AsFloat;

      ID := Tablo.KasaKaydet(Tur, TabHareket.FieldByName('Tarih').AsDateTime, TabHareket.FieldByName('Tarih').AsDateTime,RehberId,
             TabHareket.FieldByName('ACIKLAMA').AsString, TabImport.FieldByName('BANKAHESAPID').AsInteger,BankaKur,CariDoviz,0,
             Borc, Alacak,Abs(Borc-Alacak)*KurDegeri,0,FaturaId,KrediId,0,0,SubeId,'B', Yer,YerId, TabHareket.FieldByName('No').AsString,Windows_Excelden);
      if CiftSatir then begin
         if Tur in[47,48] then begin//eðer döviz alýþ/satýþ ise döviz kur deðerine bölmek gerek
            if BankaKur=CariDoviz then begin //TL ise bölünür
               Borc := Borc/TabHareket.FieldByName('KURDEGERI').AsFloat;
               Alacak := Alacak/TabHareket.FieldByName('KURDEGERI').AsFloat;
            end else begin
               Borc := Borc*TabHareket.FieldByName('KURDEGERI').AsFloat;
               Alacak := Alacak*TabHareket.FieldByName('KURDEGERI').AsFloat;
            end;
         end;

          KurDegeri := 1;
          if Kur<>CariDoviz then //döviz hareketi ise TL deðerini de yazalým
             KurDegeri:=TabHareket.FieldByName('KURDEGERI').AsFloat;
          ID2 := Tablo.KasaKaydet(Tur, TabHareket.FieldByName('Tarih').AsDateTime, TabHareket.FieldByName('Tarih').AsDateTime,0,
                 TabHareket.FieldByName('ACIKLAMA').AsString, TabHareket.FieldByName('HESAPID').AsInteger,Kur,CariDoviz,0,
                 Alacak,Borc,Abs(Borc-Alacak)*KurDegeri,0,FaturaId,KrediId,0,0,SubeId, HesapTur, Yer,YerId, TabHareket.FieldByName('No').AsString,Windows_Excelden);
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' update KASA set GERIDONUSID = '+IntToStr(ID2)+' where ID = '+IntToStr(ID),[],[]);
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' update KASA set GERIDONUSID = '+IntToStr(ID)+' where ID = '+IntToStr(ID2),[],[]);
      end;
      TabHareket.Edit;
      TabHareket.FieldByName('DURUM').AsInteger := 9;  //durum kayýtlý yapýlýr
      //Otomatik Kural ekleme
{      if (TabHareket.FieldByName('EKLEME').AsInteger = 1)then
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into [BANKAKURAL]([BANKAKODU],KULLANICI,PRGISLEMTIPI,[TUR],TARAMA_KOLONU,[DEGER_GECEN],[HESAPID],[MASRAFID])values('+
          '0,1,'+TabHareket.FieldByName('PRGISLEMTIPI').AsString+',2,2,'''+TabHareket.FieldByName('ACIKLAMA').AsString+''','+TabHareket.FieldByName('HESAPID').AsString+','+TabHareket.FieldByName('MASRAFID').AsString+')',[],[]);}
      TabHareket.Post;
   end;
begin
   if TabHareket.State in [dsEdit, dsInsert] then
      TabHareket.Post;
   Tur := TabHareket.FieldByName('PRGISLEMTIPI').AsInteger;
   TabHareket.DisableControls;
   TabHareket.First;
   while not TabHareket.eof do begin
    if (TabHareket.FieldByName('Sec').AsBoolean = True)and(TabHareket.FieldByName('DURUM').AsInteger = 2) then begin
        if (TabHareket.FieldByName('HESAPID').AsInteger<1)and(TabHareket.FieldByName('MASRAFID').AsInteger<1) then
           showmessage('Hesap Kod veya Masraf Kodundan biri dolu olmalý')
        else
           case Tur of
                32,335,532: begin  //havale veya personel maaþ, DBS
                    if TabHareket.FieldByName('Tutar').AsCurrency<0 then
                       Kasa_Islemleri(False, 32,TabHareket.FieldByName('HESAPID').AsInteger, 'B',BankaKur, Abs(TabHareket.FieldByName('Tutar').AsCurrency), 0)
                    else
                       Kasa_Islemleri(False, 22,TabHareket.FieldByName('HESAPID').AsInteger, 'B',BankaKur, 0, Abs(TabHareket.FieldByName('Tutar').AsCurrency));
                    //eft yaptýðýmýz bir carinin excelde IBANý varsa ve cari kaydýnda yoksa onu carinin kaydýna ekleyelim
                    if (Tur=32)and(TabHareket.FieldByName('EKLEME').AsInteger = 2)then begin
                        s := copy(TabHareket.FieldByName('ACIKLAMA').AsString, pos('EKLE@', TabHareket.FieldByName('ACIKLAMA').AsString)+5, 100);
                        if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM BANKAHESAPLAR where IBAN='''+s+''' ',[],[])=False then
                           Tablo.TablodanSorguAc(1,'select ID from BANKASUBELER WHERE BANKAKODU='+copy(s,5,5)+' and SUBEKODU=99999 ');
                           if Tablo.Query1.RecordCount>0 then
                              s2:=Tablo.Query1.Fields[0].AsString
                           else
                              s2:='0';
                           Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'insert into BANKAHESAPLAR(BANKASUBELERID,REHBERID,IBAN,HESAPKODU,HESAPNO,EKLEYEN,KUR,DURUM,TIPI,VARSAYILAN,CEKHESABI,KREDILIHESAP,'+
                              'KREDIKARTI,MAASHESABI,GUNLUKAKSIYONDAGOSTER)values('+s2+','+TabHareket.FieldByName('HESAPID').AsString+','''+s+''',0,'+copy(s,11,100)+','+Kullanan+','''+
                              TabHareket.FieldByName('KUR').AsString+''',1,0,0,0,0,0,0,0)',[],[]);
                   end;
                end;
                41:Kasa_Islemleri(True, 41,0,'K',BankaKur,0,Abs(TabHareket.FieldByName('Tutar').AsCurrency)); //Bankaya Yatan
                42:Kasa_Islemleri(True, 42,0,'K',BankaKur,Abs(TabHareket.FieldByName('Tutar').AsCurrency), 0); //Bankadan Çekilen
                43:if TabHareket.FieldByName('Tutar').AsCurrency > 0 then
                      Kasa_Islemleri(True, 43,0,'B',BankaKur,0,Abs(TabHareket.FieldByName('Tutar').AsCurrency)) //Banka Virmaný Gelen
                   else
                      Kasa_Islemleri(True, 43,0,'B',BankaKur, Abs(TabHareket.FieldByName('Tutar').AsCurrency), 0); //Banka Virmaný Giden
                44:Kasa_Islemleri(True, 44,0, 'P',BankaKur, 0, Abs(TabHareket.FieldByName('Tutar').AsCurrency)); //pos AKTARIMI
                47,48:
                   if ((Tur=47)and(BankaKur=CariDoviz))or      //Bankadan döviz alýþ  ve hesap TL ise
                      ((Tur=48)and(BankaKur<>CariDoviz)) then // Bankadan döviz satýþ  ve hesap TL deðil ise
                       Kasa_Islemleri(True, Tur,0, 'B',TabHareket.FieldByName('KUR').AsString, Abs(TabHareket.FieldByName('Tutar').AsCurrency),0)
                   else
                       Kasa_Islemleri(True, Tur,0, 'B',TabHareket.FieldByName('KUR').AsString, 0, Abs(TabHareket.FieldByName('Tutar').AsCurrency)); //Bankadan döviz satýþ
                51:Kasa_Islemleri(False, 51,0,'B',BankaKur,0,Abs(TabHareket.FieldByName('Tutar').AsCurrency));   //Çekin Tahsilatý
                53:Kasa_Islemleri(False, 53,0,'B',BankaKur,Abs(TabHareket.FieldByName('Tutar').AsCurrency),0);    //Çekin Ödenmesi
                57:Kasa_Islemleri(True, 57,0,'V',BankaKur,Abs(TabHareket.FieldByName('Tutar').AsCurrency),0);//KK
                58:Kasa_Islemleri(True, 58,0,'R',BankaKur,Abs(TabHareket.FieldByName('Tutar').AsCurrency),0,TabHareket.FieldByName('HESAPID').AsInteger,
                       TabHareket.FieldByName('HESAPID').AsInteger,TabNo_PLANKREDI,TabHareket.FieldByName('HESAPID').AsInteger);//Kredi
                132: Kasa_Islemleri(False, 32,0, 'B',BankaKur, Abs(TabHareket.FieldByName('Tutar').AsCurrency), 0);
           end;
    end;
    TabHareket.Next;
   end;
   TabHareket.EnableControls;
   //kalaný güncelle
   Tablo.TablodanSorguAc(1, 'select count(ID) from BANKAIMPORTHAREKET  where BANKAIMPORTID='+TabImport.Fields[0].AsString+' and DURUM=9');
   TabImport.Edit;
   TabImport.FieldByName('KALANSAY').AsInteger := TabImport.FieldByName('TOPLAMSAY').AsInteger-Tablo.Query1.Fields[0].AsInteger;
   TabImport.Post;
end;

procedure TBankaHareketlerDlg.BirSatiraKuralUygula(var Liste : TStringList);
var bulundu : boolean;
    Bas, Bit, ind, j, Harf, Rakam : Smallint;
    Kelime, ACIKLAMA, CariAd, HesapNo, KrediNo, CekNo, CariAd2Kelime, IBAN : string;
    RehberId, HesapId:integer;
    function KelimeGetir(var s:string):string;
    begin
      bit := pos(' ', s);
      case bit of
        0 : begin
              Result := s;
              s := '';
            end;
       else begin
              Result := copy(s, 1, bit);
              s := copy(s, bit+1, 200);
            end;
      end;
      Result := trim(Result);
    end;

    function HarfRakamSay(s:string):Boolean;
    var k:smallint;
    begin
      Harf:=0;  Rakam:=0;
      for k := 1 to length(s) do
         if s[k] in ['0'..'9'] then
            inc(Rakam)
         else
            inc(Harf)
    end;
    function Listeyi_Doldur(MaxHarf, MaxRakam : Integer; AtilacaklariAt : Boolean):String;
    var j : Smallint;
        Aciklama2 : string;
    begin
      //ÖNCE GEREKSÝZ ATILACAK KELÝMELERÝ ATALIM
      Aciklama2:=ACIKLAMA;
      if AtilacaklariAt then
         for j := 0 to Tablo.RepAtilacakListe.Properties.Items.Count-1 do
              Aciklama2:= StringReplace(Aciklama2, Tablo.RepAtilacakListe.Properties.Items[j].Description, ' ', [rfReplaceAll]);
      Result :='';
      Liste.clear;
      while Aciklama2<>'' do begin
         Kelime := KelimeGetir(Aciklama2);
         if (Kelime<>'')and((Kelime[1]='T')and(Kelime[2]='R')and(Kelime[3] in ['0'..'9']))and(Kelime<>BankaIBAN) then //eðer IBAN varsa ve þu anki ise geçersizdir. baþka IBAN bulmamýz lazým
            Result := Kelime;
         HarfRakamSay(Kelime);
         if (Kelime<>'')and(Harf <= MaxHarf)and(Rakam<MaxRakam) then
            Liste.Add(Kelime);
      end;
    end;

   function RehberIDBul:Integer; //Açýklamada geçen isimden Id bulur
      function YeniCiftKelime : string;
      begin
         Result:='';
         if ind <= Liste.Count-1 then begin
             Result := Liste.Strings[ind];
             inc(ind);
             if ind <= Liste.Count-1 then
                Result := Result+' '+Liste.Strings[ind];
         end;
      end;
   begin
      Result:=0;
      IBAN:=Listeyi_Doldur(100,3, True); //Hem liste oluþtursun hem de bu arada IBAN varsa onu alalým ki IBAN a göre iþlem yapalým
      if IBAN<>'' then begin //IBAN varsa
         Tablo.TablodanSorguAc(1,'select ID, REHBERID,KUR from BANKAHESAPLAR where IBAN='''+IBAN+''' ');
         Tablo.Query1.FetchAll;
         if not Tablo.Query1.IsEmpty then begin
            if Tablo.Query1.FieldByName('REHBERID').AsInteger < 0 then begin//bizim  demek ki virman..  iþlem tipini virman yapýp hesapId ise bu banka hesap ID yi çakalým
               TabHareket.FieldByName('PRGISLEMTIPI').AsInteger:=43;
               Result := Tablo.Query1.FieldByName('ID').AsInteger;
            end else
               Result := Tablo.Query1.FieldByName('REHBERID').AsInteger;  //müþteriyse cari ID yi bulup dönelim
         end
         else if TabHareket.FieldByName('EKLEME').AsInteger = 0 then begin//BU IBANDAN bir kayýt yoksa eklemek için Açýklamanýn sonuna koyalým ayrýca EKLEME alanýný true yapalým ki bunu ekleyeceðimizi bilelim
              TabHareket.FieldByName('ACIKLAMA').AsString := TabHareket.FieldByName('ACIKLAMA').AsString+' EKLE@'+IBAN;
              TabHareket.FieldByName('EKLEME').AsInteger := 2;
         end;
      end;

      if Result=0 then begin // IBAN yoksa veya sonuç çýkmadýysa
          ind:=0;                   //açýklamadan 2 kelime alarak rehber tablosunda aramaya baþlýyoruz..
          CariAd := YeniCiftKelime;
          while (Result=0)and(ind<=Liste.Count-1) do begin
             Tablo.TablodanSorguAc(1, 'select top 2 ID from REHBER where ID>0 and GRUP in (120,320) and FIRMA like '''+CariAd+'%'''); //sadece alýcý ve satýcýlara bakar
             Tablo.Query1.FetchAll;
             case Tablo.query1.RecordCount of
                 0 : CariAd := YeniCiftKelime;
                 1 : Result := Tablo.Query1.Fields[0].AsInteger;
                else begin inc(ind); //bu iki kelimeyle çok deðer döndü bir kelime daha ekleyelim. Ör. "Asya Nakliyat" çok dönmüþse "Asya Nakliyat Taþýma"
                           CariAd := CariAd+' '+Liste.Strings[ind];
                     end;
             end;
          end;
      end;
   end;
   function RehberIDBul2:Integer;//Açýklamada DBS geçerse ödenen fatura no dan Cari Id bulur
   begin            //DBS ODM/5068924/A17100804
      Listeyi_Doldur(100,100, True);

      ind:=0; Result:=0;
      while (Result=0)and(ind<=Liste.Count-1) do begin
         Tablo.TablodanSorguAc(7, 'select ID, REHBERID, FATURA_TUTARI from FATBASLIK where ISNULL(FATURASERI,'''')+FATURANO = '''+Liste.Strings[ind]+'''');
         Tablo.Query7.FetchAll;
         case Tablo.query7.RecordCount of
             0 : inc(ind);
             1 : Result := Tablo.Query7.Fields[0].AsInteger;
            else begin //BÝRDEN FAZLA DÖNMÜÞSE tutara bakalým
                  Result := Tablo.Query7.Fields[0].AsInteger;
                 end;
         end;
      end;
   end;

   function CekIdBul:Integer;
   begin
      Listeyi_Doldur(0,100, True);

      ind:=0; Result:=0;
      while (Result=0)and(ind<=Liste.Count-1) do begin
         Tablo.TablodanSorguAc(7, 'select top 2 ID, SERINO, REHBERID from CEKLER where SERINO = '''+Liste.Strings[ind]+'''');
         Tablo.Query7.FetchAll;
         case Tablo.query7.RecordCount of
             0 : inc(ind);
             1 : Result := Tablo.Query7.Fields[0].AsInteger;
            else begin //BÝRDEN FAZLA DÖNMÜÞSE tutara bakalým
                  Result := Tablo.Query7.Fields[0].AsInteger;
                 end;
         end;
      end;
   end;

   function KrediKartIdBul:Integer;
   begin
      Listeyi_Doldur(0,100, True);
      ind:=0; Result:=0;
      while (Result=0)and(ind<=Liste.Count-1) do begin
         Tablo.TablodanSorguAc(1, 'select top 2 ID from KREDIKARTI where NOSU = '''+Liste.Strings[ind]+'''');
         Tablo.Query1.FetchAll;
         case Tablo.query1.RecordCount of
             0 : inc(ind);
             1 : Result := Tablo.Query1.Fields[0].AsInteger;
            else begin //BÝRDEN FAZLA DÖNMÜÞSE tutara bakalým
                  Result := Tablo.Query1.Fields[0].AsInteger;
                 end;
         end;
      end;
   end;

   function POSIdBul:Integer;
   begin
      Listeyi_Doldur(0,100, True);
      ind:=0; Result:=0;
      while (Result=0)and(ind<=Liste.Count-1) do begin
         Tablo.TablodanSorguAc(1, 'select top 2 ID from POS where NOSU = '''+Liste.Strings[ind]+'''');
         Tablo.Query1.FetchAll;
         case Tablo.query1.RecordCount of
             0 : inc(ind);
             1 : Result := Tablo.Query1.Fields[0].AsInteger;
            else begin //BÝRDEN FAZLA DÖNMÜÞSE tutara bakalým
                  Result := Tablo.Query1.Fields[0].AsInteger;
                 end;
         end;
      end;
   end;

   function KrediIdBul:Integer;
       function Tara:Integer;
       begin
          ind:=0; Result:=0;
          while (Result=0)and(ind<=Liste.Count-1) do begin
             Tablo.TablodanSorguAc(1, 'select top 2 ID from KREDILER where SOZLESMENO = '''+Liste.Strings[ind]+'''');
             Tablo.Query1.FetchAll;
             case Tablo.query1.RecordCount of
                 0 : inc(ind);
                 1 : Result := Tablo.Query1.Fields[0].AsInteger;
                else begin //BÝRDEN FAZLA DÖNMÜÞSE tutara bakalým
                      Result := Tablo.Query1.Fields[0].AsInteger;
                     end;
             end;
          end;
       end;
   begin
      Listeyi_Doldur(100, 100, False); //TAKSITLI-011029415-00000019-00001  açýklama böyle  önce tireleri atmadan deneyelim
      Result := Tara;
      if Result=0 then  //þayet bulamazsak atýlacaklarý atýp öyle tekrar deneyelim
         Listeyi_Doldur(100, 100, True);
         Result := Tara;
   end;

   procedure IcindeGeceneBak;
//   procedure IcindeGeceneBak(Tarama:smallint; Alan:string);
   var Alan : String[20];
   begin
      Tablo.TablodanSorguAc(0, 'select PRGISLEMTIPI, DEGER_GECEN, TARAMA_KOLONU, HESAPID, MASRAFID, KULLANICI'+
                               ' from BANKAKURAL '+
                               ' where BANKAKODU in(0,'+IntToStr(BankaKodu)+ ') and TUR=2 '+
                               ' order by KULLANICI desc, TARAMA_KOLONU ');
                               //' and TARAMA_KOLONU ='+IntToStr(Tarama)+'  order by HESAPID DESC, MASRAFID DESC, LEN(DEGER_GECEN) desc');
      bulundu := False;

      while (not bulundu)and(not Tablo.Query0.eof) do begin
         if Tablo.Query0.FieldByName('TARAMA_KOLONU').AsInteger=1 then
            Alan := 'GELENISLEMTIPI'
         else
            Alan := 'ACIKLAMA';
         if pos(Tablo.Query0.FieldByName('DEGER_GECEN').AsString, TabHareket.FieldByName(Alan).AsString)>0 then
            bulundu := True
         else
            Tablo.Query0.next;
      end;

   end;
begin
          //önce bakalým hareketteki excel_iþlem TÝPÝNE GÖRE BAKALIM
//          IcindeGeceneBak(1,'GELENISLEMTIPI');
          IcindeGeceneBak;
//          if not bulundu then  //iþlem tipinde yoksa açýklamaya bakalým tekrar
//             IcindeGeceneBak(2,'ACIKLAMA');

          if bulundu then begin
              TabHareket.Edit;
              TabHareket.FieldByName('PRGISLEMTIPI').AsString := Tablo.Query0.FieldByName('PRGISLEMTIPI').AsString;
              ACIKLAMA := TabHareket.FieldByName('GELENISLEMTIPI').AsString+' '+TabHareket.FieldByName('ACIKLAMA').AsString;
              HesapId := Tablo.Query0.FieldByName('HESAPID').AsInteger;
              TabHareket.FieldByName('HESAPID').AsInteger := HesapId;
              TabHareket.FieldByName('MASRAFID').AsInteger := Tablo.Query0.FieldByName('MASRAFID').AsInteger;

              case TabHareket.FieldByName('PRGISLEMTIPI').AsInteger of
                32,132,532:begin
                         case TabHareket.FieldByName('PRGISLEMTIPI').AsInteger of
                            32 : if HesapId=0 then //HesapId := RehberIdBul;
                                    TabHareket.FieldByName('HESAPID').AsInteger :=RehberIdBul;
                           //132 : HesapId := 0;
                           532 : if HesapId=0 then //HesapId := RehberIdBul2;
                                    TabHareket.FieldByName('HESAPID').AsInteger :=RehberIdBul2;
                         end;
                         //Hesap_Masraf('HESAPID','HesapKod','HesapAd','REHBER','KOD','FIRMA');
                         //Hesap_Masraf('MASRAFID','MasrafKod','MasrafAd','MASRAFGELIR','KOD','AD');
                       end;
                51,53: begin
                         //HesapId := CekIdBul;  //ÇEK
                         //Hesap_Masraf('HESAPID','HesapKod','HesapAd','REHBER','KOD','FIRMA');
                         if HesapId=0 then
                            TabHareket.FieldByName('HESAPID').AsInteger := CekIdBul;;
                         //if TabHareket.FieldByName('HESAPID').AsInteger > 0 then begin
                         //   TabHareket.FieldByName('HesapKod').AsString := Tablo.query7.FieldByName('SERINO').AsString;
                         //   TabHareket.FieldByName('HesapAd').AsString := Tablo.AciklamaGetir('REHBER','FIRMA', Tablo.query7.FieldByName('REHBERID').AsInteger);
                         //end;
                       end;
                //41,42: Hesap_Masraf('HESAPID','HesapKod','HesapAd','KASALAR','KASAKODU','KASAADI');
                //43,47,48:Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','BANKAHESAPLAR','HESAPKODU','HESAPADI');
                44:begin
                         if HesapId=0 then //HesapId := POSIdBul;  //POS
                            TabHareket.FieldByName('HESAPID').AsInteger := POSIdBul;
                         //Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','KREDIKARTI','KODU','ADI');
                   end;
                57:begin
                         if HesapId=0 then //HesapId := KrediKartIdBul;  //KK
                            TabHareket.FieldByName('HESAPID').AsInteger := KrediKartIdBul;  //KK
                         //Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','KREDIKARTI','KODU','ADI');
                   end;
                58:begin
                         if HesapId=0 then //HesapId := KrediIdBul;  //KREDÝ
                            TabHareket.FieldByName('HESAPID').AsInteger := KrediIdBul;  //KK
                         //Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','KREDILER','KREDIKODU','ADI');
                   end;
                end;
              TabHareket.Post;
        end;
end;

procedure TBankaHareketlerDlg.KurallarUygulaMenuClick(Sender: TObject);
var Liste : TStringList;
begin
   if TabHareket.State in [dsEdit, dsInsert] then
      TabHareket.Post;
   KuralUygulaniyor:=True;
   TabHareket.DisableControls;
   Liste:=TStringList.Create;
   TabHareket.First;
   while not TabHareket.eof do begin
      if TabHareket.FieldByName('SEC').AsBoolean = True then
         BirSatiraKuralUygula(Liste);
      TabHareket.Next;
   end;
   //Sabit.Free; Degisken.Free; Deger.Free;
   KuralUygulaniyor:=False;
   Liste.Free;
   TabHareket.EnableControls;
end;

procedure TBankaHareketlerDlg.BuSatirdaKuralTestEtMenuClick(Sender: TObject);
var Liste : TStringList;
begin
   KuralUygulaniyor:=True;
   TabHareket.DisableControls;
   Liste:=TStringList.Create;
   TabHareket.Edit;
   TabHareket.FieldByName('DURUM').AsInteger := 0;
   TabHareket.FieldByName('PRGISLEMTIPI').AsInteger := 0;
   TabHareket.FieldByName('HESAPID').AsInteger:=0;
   TabHareket.FieldByName('MASRAFID').AsInteger:=0;
   TabHareket.FieldByName('PROJEID').AsInteger:=0;
   TabHareket.Post;
   BirSatiraKuralUygula(Liste);
   //Sabit.Free; Degisken.Free; Deger.Free;
   KuralUygulaniyor:=False;
   Liste.Free;
   TabHareket.EnableControls;
end;

procedure TBankaHareketlerDlg.KuralListesiniAcMenuClick(Sender: TObject);
begin
   Application.CreateForm(TBankaHareketKuralDlg, BankaHareketKuralDlg);
   BankaHareketKuralDlg.BankaKodu := BankaKodu;
   BankaHareketKuralDlg.ShowModal;
   BankaHareketKuralDlg.Destroy;
end;

procedure TBankaHareketlerDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil), PChar(Onay),    MB_YESNO + MB_ICONQUESTION) = ID_YES then begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from BANKAIMPORTHAREKET where BANKAIMPORTID='+TabImport.FieldByName('ID').AsString,[], []);
     TabImport.Delete;
  end;
end;

procedure TBankaHareketlerDlg.TabHareketAfterScroll(DataSet: TDataSet);
   procedure Hesap_Masraf(Id,Kod,Ad,Tablo1,TabloKod,TabloAd:String);
   begin
      //TabHareket.FieldByName(Kod).AsString := Tablo.AciklamaGetir(Tablo1,TabloKod, TabHareket.FieldByName(Id).AsInteger);
      //TabHareket.FieldByName(Ad).AsString := Tablo.AciklamaGetir(Tablo1,TabloAd, TabHareket.FieldByName(Id).AsInteger);
      EditHesapKod.Text := Tablo.AciklamaGetir(Tablo1,TabloKod, TabHareket.FieldByName(Id).AsInteger);
      EditHesapAd.Text := Tablo.AciklamaGetir(Tablo1,TabloAd, TabHareket.FieldByName(Id).AsInteger);
   end;
begin
          case TabHareket.FieldByName('PRGISLEMTIPI').AsInteger of
            32,132,335,532:begin
                     Hesap_Masraf('HESAPID','HesapKod','HesapAd','REHBER','KOD','FIRMA');
                     //Hesap_Masraf('MASRAFID','MasrafKod','MasrafAd','MASRAFGELIR','KOD','AD');
                   end;
            51,53: begin
                     Hesap_Masraf('HESAPID','HesapKod','HesapAd','CEKLER','SERINO','SERINO');
                    { if TabHareket.FieldByName('HESAPID').AsInteger > 0 then begin
                        TabHareket.FieldByName('HesapKod').AsString := Tablo.query7.FieldByName('SERINO').AsString;
                        TabHareket.FieldByName('HesapAd').AsString := Tablo.AciklamaGetir('REHBER','FIRMA', Tablo.query7.FieldByName('REHBERID').AsInteger);
                     end;   }
                   end;
            41,42: Hesap_Masraf('HESAPID','HesapKod','HesapAd','KASALAR','KASAKODU','KASAADI');
            43,47,48:Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','BANKAHESAPLAR','HESAPKODU','HESAPADI');
            44:begin
                     Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','POS','KODU','ADI');
               end;
            57:begin
                     Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','KREDIKARTI','KODU','ADI');
               end;
            58:begin
                     Hesap_Masraf('HESAPID','HESAPKOD','HESAPAD','KREDILER','KREDIKODU','ADI');
               end;
            end;



   if TabHareket.FieldByName('MASRAFID').AsString <> '' then begin
      EditMasrafKodu.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'KOD', TabHareket.FieldByName('MASRAFID').AsInteger);
      EditMasrafAd.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabHareket.FieldByName('MASRAFID').AsInteger);
   end;
   if TabHareket.FieldByName('PROJEID').AsString<>'' then
      EditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU', TabHareket.FieldByName('PROJEID').AsInteger);
end;

procedure TBankaHareketlerDlg.TabHareketBeforePost(DataSet: TDataSet);
var OncekiDurum:Smallint;
begin
   if TabHareket.FieldByName('DURUM').AsInteger < 9 then begin
      OncekiDurum := TabHareket.FieldByName('DURUM').AsInteger;
       case TabHareket.FieldByName('PRGISLEMTIPI').AsInteger of
         0:;//aynen kalacak
         132 : if TabHareket.FieldByName('MASRAFID').AsInteger>0 then
                  TabHareket.FieldByName('DURUM').AsInteger := 2
               else
                  TabHareket.FieldByName('DURUM').AsInteger := 1;
         47,48: //döviz alýþ satýþ ise 3 alan da dolu olmalý
               if (TabHareket.FieldByName('HESAPID').AsInteger>0)and(TabHareket.FieldByName('KURDEGERI').AsString<>'')and
                  (TabHareket.FieldByName('KUR').AsString<>'') then
                  TabHareket.FieldByName('DURUM').AsInteger := 2
               else
                  TabHareket.FieldByName('DURUM').AsInteger := 1;
         else
               if TabHareket.FieldByName('HESAPID').AsInteger>0 then
                  TabHareket.FieldByName('DURUM').AsInteger := 2
               else
                  TabHareket.FieldByName('DURUM').AsInteger := 1;
       end;
      //eðer önceden hazýr deðilse ve þimdi hazýr olmuþsa bunu kurallara ekleyelim
      if (KuralUygulaniyor=False)and(OncekiDurum < 2)and( TabHareket.FieldByName('DURUM').AsInteger=2) then
          TabHareket.FieldByName('EKLEME').AsInteger := 1;

   end;
end;

procedure TBankaHareketlerDlg.TabImportAfterScroll(DataSet: TDataSet);
begin
   TabloAc;
   if not TabImport.IsEmpty then begin
      BankaKur := TabImport.FieldByName('KUR').AsString;
      BankaKodu:= TabImport.FieldByName('BANKAKODU').AsInteger;
      BankaHesapId:= TabImport.FieldByName('BANKAHESAPID').AsInteger;
      BankaIBAN:= Tablo.AciklamaGetir('BANKAHESAPLAR', 'IBAN', BankaHesapId);
      SilTus.Visible := TabImport.FieldByName('TOPLAMSAY').AsInteger=TabImport.FieldByName('KALANSAY').AsInteger;
   end
   else
      SilTus.Visible := False;
   Panel1.Caption := TabImport.FieldByName('HESAPADI').AsString; //Tablo.AciklamaGetir('BANKALAR','BANKAADI', BankaKodu, 'BANKAKODU')+
//        Tablo.AciklamaGetir('BANKAHESAPLAR','HESAPADI', TabImport.FieldByName('BANKAHESAPID').AsInteger);
end;

procedure TBankaHareketlerDlg.TumunuSecMenuClick(Sender: TObject);
var s:string;
begin
    case TMenuItem(Sender).Tag of
     0,1: s:=IntToStr(TMenuItem(Sender).Tag);
     2 :  s:='1-SEC';//seçililer ters
     3 :  s:='case when DURUM < 2 then 1 else 0 end ';        //"Tanýmsýz" ve "Eksikleri" Seç
     4 :  s:='case when DURUM = 2 then 1 else 0 end '        //"Hazýr" Seç
    end;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update BANKAIMPORTHAREKET set SEC='+s+' where BANKAIMPORTID='+TabImport.Fields[0].AsString, [],[]);
    TabloAc;
end;

procedure TBankaHareketlerDlg.YeniExcelTusClick(Sender: TObject);
begin
   Excel2BankaHareket(TabImport, TabHareket); //okunan excelden BankaKodu, HesapId,  BankaKur bilgileri gelir..
   //Kuralý Uygulayalým
   KurallarUygulaMenu.Click;
   TabloYenile(TabImport, []);
end;

end.




