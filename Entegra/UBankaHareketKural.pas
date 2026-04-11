unit UBankaHareketKural;

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
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  Vcl.ExtCtrls, FireDAC.Comp.Client, cxImageComboBox, cxButtonEdit, cxTextEdit, Vcl.ComCtrls,
  Vcl.ToolWin, dxBarBuiltInMenu, cxPC, cxCheckBox, cxContainer, cxDBEdit,
  cxLabel, cxCurrencyEdit, cxMaskEdit, cxDropDownEdit, dxDateRanges,
  dxScrollbarAnnotations, dxCoreGraphics, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TBankaHareketKuralDlg = class(TForm)
    Panel1: TPanel;
    DtsKural: TDataSource;
    TabKural: TFDQuery;
    TabKuralID: TAutoIncField;
    TabKuralBANKAKODU: TSmallintField;
    TabKuralTUR: TWordField;
    TabKuralISLEM: TSmallintField;
    TabKuralTUTAR: TSmallintField;
    TabKuralMASRAFID: TIntegerField;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton9: TToolButton;
    KaydetTus: TToolButton;
    ToolButton2: TToolButton;
    IptalTus: TToolButton;
    ToolButton3: TToolButton;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    TabSheetSatSut: TcxTabSheet;
    GridHareket: TcxGrid;
    GridHareketView: TcxGridDBTableView;
    GridHareketViewKOLON: TcxGridDBColumn;
    GridHareketLevel1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxGridDBTableView1Column1: TcxGridDBColumn;
    DtsSatSut: TDataSource;
    TabSatSut: TFDQuery;
    TabKuralHESAPID: TIntegerField;
    GridHareketViewISLEM: TcxGridDBColumn;
    TabKuralDEGER_GECEN: TWideStringField;
    AtilacakKelimlerTus: TToolButton;
    GridHareketViewTARAMA_KOLONU: TcxGridDBColumn;
    TabKuralTARAMA_KOLONU: TWordField;
    TabKuralESITLIK: TWordField;
    TabKuralDEGISTIREN: TIntegerField;
    TabKuralDEGISTIRMETARIHI: TDateTimeField;
    GridHareketViewBANKAKODU: TcxGridDBColumn;
    TabKuralKULLANICI: TBooleanField;
    GridHareketViewKULLANICI: TcxGridDBColumn;
    Panel4: TPanel;
    PanelOdemeTipi: TPanel;
    LabelOdemeTipi: TcxLabel;
    ComboOdemeTipi: TcxDBImageComboBox;
    Panel8: TPanel;
    PanelHesap: TPanel;
    cxLabel3: TcxLabel;
    EditHesapAd: TcxTextEdit;
    cxLabel4: TcxLabel;
    EditHesapKod: TcxButtonEdit;
    Panel5: TPanel;
    cxLabel5: TcxLabel;
    ComboPRGISLEMTIPI: TcxDBImageComboBox;
    Panel2: TPanel;
    cxLabel1: TcxLabel;
    EditMasrafKodu: TcxButtonEdit;
    cxLabel6: TcxLabel;
    EditMasrafAd: TcxTextEdit;
    PanelProje: TPanel;
    cxLabel2: TcxLabel;
    EditProje: TcxButtonEdit;
    procedure FormShow(Sender: TObject);
    procedure TabKuralNewRecord(DataSet: TDataSet);
    procedure YeniTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsKuralStateChange(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure AtilacakKelimlerTusClick(Sender: TObject);
    procedure GridHareketViewKOLONPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditHesapKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditMasrafKoduPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabKuralAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    BankaKodu : Integer;
  end;

var
  BankaHareketKuralDlg: TBankaHareketKuralDlg;

procedure HesapListele(Tablo1:TFDQuery; AButtonIndex: Integer; BankaKur:String; EditHesapKod, EditMasrafKodu:TcxButtonEdit;  EditHesapAd, EditMasrafAd:TcxTextEdit);

implementation

{$R *.dfm}

uses UTablo, PrjConst, FetaKurulusSiniflari, UGirisKutusuEx;

procedure HesapListele(Tablo1:TFDQuery; AButtonIndex: Integer; BankaKur:String; EditHesapKod, EditMasrafKodu:TcxButtonEdit;  EditHesapAd, EditMasrafAd:TcxTextEdit);
var Id,Tur : Integer;
    Degisti:Boolean;
    procedure Cari_Islem(Tip:smallint);
    begin
       Id := Tablo.RehberAra_IDGetir(Tip);
       if Id > 0 then begin
          Tablo1.FieldByName('HESAPID').AsInteger := Id;
          EditHesapKod.Text := Tablo.AciklamaGetir('REHBER','KOD', Id);
          EditHesapAd.Text := Tablo.AciklamaGetir('REHBER','FIRMA', Id);

          if Tablo1.FieldByName('Tutar').AsCurrency<0 then
             Tur := 32
          else
             Tur := 22;
          Tablo1.FieldByName('MASRAFID').AsInteger := Tablo.MasrafGelirKalemiGetir(Tur, Id);
          //Tablo1.FieldByName('MasrafKod').AsString := Tablo.AciklamaGetir('MASRAFGELIR','KOD', Tablo1.FieldByName('MASRAFID').AsInteger);
          EditMasrafKodu.Text :=  Tablo.AciklamaGetir('MASRAFGELIR','KOD', Tablo1.FieldByName('MASRAFID').AsInteger);
          EditMasrafAd.Text :=  Tablo.AciklamaGetir('MASRAFGELIR','AD', Tablo1.FieldByName('MASRAFID').AsInteger);
          Degisti:=True;
       end;
    end;
    procedure Kasali_Islem;
    var KasaID, KASAKODU, KASAADI, Kur: string;
    begin
      Kur := BankaKur;
      if Tablo.KasaHesapEkrani(KasaID, KASAKODU, KASAADI, Kur) then begin
          Tablo1.FieldByName('HESAPID').AsString := KasaID;
          EditHesapKod.Text := KASAKODU;
          EditHesapAd.Text := KASAADI;
          Degisti:=True;
      end;
    end;

    procedure Bankali_Islem(Tur:Integer);
    var HESAPID, HESAPKODU, HESAPNO, HESAPADI, Kur: string;
    begin
      HESAPID:='-1';
      if Tur=43 then //virman ise diğer bankanın kuru da aynı olmalı
         Kur := BankaKur
      else begin
         Kur := Tablo1.FieldByName('KUR').AsString;   //döviz alma veya satma ise
         if Kur='' then begin
            ShowMessage(MTParaBirimiGirin);
            exit;
         end;
      end;


      if Tablo.BankaHesapEkrani(25, HESAPID, HESAPKODU, HESAPNO, HESAPADI, Kur) then begin
          Tablo1.FieldByName('HESAPID').AsString := HESAPID;
          EditHesapKod.Text := HESAPKODU;
          EditHesapAd.Text := HESAPADI;
          Degisti:=True;
      end;
    end;

    procedure KK_Odeme;
    var KKID, KODU, ADI, Kur : string;
    begin
      Kur := BankaKur;
      if Tablo.KrediKartiEkrani(KKID, KODU, ADI, Kur) then begin
         Tablo1.FieldByName('HESAPID').AsString := KKID;
         EditHesapKod.Text := KODU;
         EditHesapAd.Text := ADI;
         Degisti:=True;
      end;
    end;

    procedure POS_Odeme;
    var KID, KODU, ADI, Kur : string;
    begin
      Kur := BankaKur;
      if Tablo.POSListeEkrani(KID, KODU, ADI, Kur) then begin
         Tablo1.FieldByName('HESAPID').AsString := KID;
         EditHesapKod.Text := KODU;
         EditHesapAd.Text := ADI;
         Degisti:=True;
      end;
    end;

    procedure Kredi_Odeme;
    var KID, KODU, ADI, Kur : string;
    begin
      Kur := BankaKur;
      if Tablo.KrediListeEkrani(KID, KODU, ADI, Kur) then begin
         Tablo1.FieldByName('HESAPID').AsString := KID;
         EditHesapKod.Text := KODU;
         EditHesapAd.Text := ADI;
         Degisti:=True;
      end;
    end;
begin
    Degisti := False;
    if AButtonIndex=0 then begin
       Tablo1.Edit;
       case Tablo1.FieldByName('PRGISLEMTIPI').AsInteger of
          32:Cari_Islem(-1);
          335:Cari_Islem(335);
          41,42:Kasali_Islem;
          43,47,48:Bankali_Islem(Tablo1.FieldByName('PRGISLEMTIPI').AsInteger);
          44: POS_Odeme;
          57: KK_Odeme;
          58: Kredi_Odeme;
       end;
    end
    else begin
        Tablo1.Edit;
        Tablo1.FieldByName('HESAPID').AsInteger := 0;
        EditHesapKod.Text := '';
        EditHesapAd.Text :=  '';
        Degisti:=True;
    end;
    if (Degisti=True)and(Tablo1.state in [dsEdit, dsInsert]) then begin
       Tablo1.FieldByName('DEGISTIREN').AsString := Kullanan;
       Tablo1.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GenINI.BugunTrhSaat;
       Tablo1.post;
    end;
end;

procedure TBankaHareketKuralDlg.AtilacakKelimlerTusClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Banka_Excel_Atilacak);
   Tablo.GENINI.ReadImageSection(Ops_Banka_Excel_Atilacak, Tablo.RepAtilacakListe.Properties.Items, False);
end;

procedure TBankaHareketKuralDlg.DtsKuralStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsKural, YeniTus, SilTus, KaydetTus, IptalTus);
end;

procedure TBankaHareketKuralDlg.EditHesapKodPropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
   HesapListele(TabKural, AButtonIndex, '', EditHesapKod, EditMasrafKodu, EditHesapAd, EditMasrafAd);
end;

procedure TBankaHareketKuralDlg.EditMasrafKoduPropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var MASRAFID,MASRAFKODU,MASRAFMERKEZI: string;
begin
    TabKural.Edit;
    if AButtonIndex=0 then begin
       if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI)then begin
          TabKural.FieldByName('MASRAFID').AsString := MASRAFID;
          EditMasrafKodu.Text := MASRAFKODU;
          EditMasrafAd.Text := MASRAFMERKEZI;
       end
     end else begin
          TabKural.FieldByName('MASRAFID').AsString := '0';
          EditMasrafKodu.Text :='';
          EditMasrafAd.Text := '';
     end;
     TabKural.Post;
end;

procedure TBankaHareketKuralDlg.FormShow(Sender: TObject);
begin
   cxPageControl1.ActivePageIndex := 0;
   TabSheetSatSut.TabVisible:=False;
   Panel1.Caption := '  '+Tablo.AciklamaGetir('BANKALAR','BANKAADI', BankaKodu, 'BANKAKODU');
   TabloYenile(TabKural, [BankaKodu]);
{   if TabIslemler.recordcount<1 then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into [BANKAKURAL]([BANKAKODU],[TUR],[ISLEM],KOLON,ESITLIK) '+
         'select '+IntToStr(BankaKodu)+',2,DEGER,3,4 from GENINI where BOLUM=25011 ORDER BY SIRA ',[], []);
      TabloYenile(TabIslemler, [BankaKodu]);
   end; }
   TabloYenile(TabSatSut, [BankaKodu]);
   if TabSatSut.recordcount<1 then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into [BANKAKURAL]([BANKAKODU],[TUR],[PRGISLEMTIPI],HESAPID) '+
         'select '+IntToStr(BankaKodu)+',1,DEGER,0 from GENINI where BOLUM=25010 ORDER BY SIRA ',[], []);
      TabloYenile(TabSatSut, [BankaKodu]);
   end;
end;

procedure TBankaHareketKuralDlg.GridHareketViewKOLONPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var s1 : variant;
begin
   s1:=TabKural.FieldByName('DEGER_GECEN').AsString;
   TGirisKutusuEx.BilgiAlEx('', TGirdiDenetimleri.Create.Memo('Açıklama', @s1));
end;

procedure TBankaHareketKuralDlg.IptalTusClick(Sender: TObject);
begin
    TabKural.Cancel;
end;

procedure TBankaHareketKuralDlg.KaydetTusClick(Sender: TObject);
begin
   TabKural.Post;
end;

procedure TBankaHareketKuralDlg.Panel1DblClick(Sender: TObject);
begin
   TabSheetSatSut.TabVisible:=True;
   AtilacakKelimlerTus.Visible :=True;
end;

procedure TBankaHareketKuralDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabKural.Delete;
end;

procedure TBankaHareketKuralDlg.TabKuralAfterScroll(DataSet: TDataSet);
    procedure Islem(HesapId, HKod, HAd, TabAd, TKod, TAd : string);
    begin
       EditHesapKod.Text := Tablo.AciklamaGetir(TabAd, TKod, TabKural.FieldByName(HesapId).AsInteger);
       EditHesapAd.Text  :=  Tablo.AciklamaGetir(TabAd, TAd, TabKural.FieldByName(HesapId).AsInteger);
    end;
begin
   case TabKural.FieldByName('PRGISLEMTIPI').AsInteger of
      32,132,335:begin
               Islem('HESAPID','HESAPKOD','HESAPAD','REHBER','KOD','FIRMA');
//               Islem('MASRAFID','MasrafKod','MasrafAd','MASRAFGELIR','KOD','AD');
               if TabKural.FieldByName('MASRAFID').AsString <> '' then begin
                  EditMasrafKodu.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'KOD', TabKural.FieldByName('MASRAFID').AsInteger);
                  EditMasrafAd.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabKural.FieldByName('MASRAFID').AsInteger);
               end;
             end;
      41,42:Islem('HESAPID','HESAPKOD','HESAPAD','KASALAR','KASAKODU','KASAADI');
      43,47,48:Islem('HESAPID','HESAPKOD','HESAPAD','BANKAHESAPLAR','HESAPKODU','HESAPADI');
      57: Islem('HESAPID','HESAPKOD','HESAPAD','KREDIKARTI','KODU','ADI');
      58: Islem('HESAPID','HESAPKOD','HESAPAD','KREDILER','KREDIKODU','ADI');
   end;
end;

procedure TBankaHareketKuralDlg.TabKuralNewRecord(DataSet: TDataSet);
begin
   TabKural.FieldByName('KULLANICI').AsBoolean := False;
   TabKural.FieldByName('TUR').AsInteger := 2;
   TabKural.FieldByName('BANKAKODU').AsInteger := 0;//BankaKodu;
   TabKural.FieldByName('TARAMA_KOLONU').AsInteger:=2;
   TabKural.FieldByName('HESAPID').AsInteger:=0;
   TabKural.FieldByName('MASRAFID').AsInteger:=0;
   TabKural.FieldByName('DEGER_GECEN').AsString := '';
end;

procedure TBankaHareketKuralDlg.YeniTusClick(Sender: TObject);
begin
   TabKural.Append;
end;

end.



