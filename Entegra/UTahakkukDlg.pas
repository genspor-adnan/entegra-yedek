unit UTahakkukDlg;
  //giren tutar bizim kullandığımız para birimi olup çıkan tutar onun döviz karşılığıdır..
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore,  cxGraphics, cxMaskEdit, cxDropDownEdit, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit, StdCtrls, ExtCtrls,DateUtils,
  JvExExtCtrls, JvExtComponent, JvPanel, cxLabel,Utablo, DB, FireDAC.Comp.Client, cxDBEdit, Math,
  cxLookAndFeelPainters, cxGroupBox, cxRadioGroup, dxSkinLondonLiquidSky,
  cxImageComboBox, cxCalendar, cxSpinEdit, cxButtonEdit , cxDBLabel,
  cxLookAndFeels, dxSkinLiquidSky, UGentegreFrameYonetimi, cxCheckBox,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Menus, frxClass, frxDBSet,
  UFastRap, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxCoreGraphics, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;
type
  TTahakkukDlg = class(TForm, IPopupDialog)
    UstPanel: TJvPanel;
    TabFatBaslik: TFDQuery;
    LabelAd: TcxLabel;
    DtsFatBaslik: TDataSource;
    OrtaPanel: TPanel;
    Label15: TcxLabel;
    LabelMasrafMerkezi: TcxLabel;
    cxLabel3: TcxLabel;
    EditTutar: TcxDBCurrencyEdit;
    EditMM: TcxButtonEdit;
    AltPanel: TPanel;
    iptalButton: TButton;
    tamamButton: TButton;
    LabelSRM: TcxLabel;
    EditSRMMerkezi: TcxButtonEdit;
    EditAciklama: TcxDBTextEdit;
    BeditBagliGorev: TcxButtonEdit;
    LabelProje: TcxLabel;
    LabelAktivite: TcxLabel;
    EditProje: TcxButtonEdit;
    cbIrsaliyeli: TcxDBCheckBox;
    PanelKarsilik: TPanel;
    EditDovTutar: TcxDBCurrencyEdit;
    EditKulKur: TcxDBCurrencyEdit;
    LabelKarsiligi: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    cxLabel1: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    EditTarih: TcxDBDateEdit;
    LabelTarih: TcxLabel;
    cxLabel2: TcxLabel;
    EditVade: TcxDBCurrencyEdit;
    KaydetveOdemeTus: TButton;
    EditDemirbas: TcxButtonEdit;
    lblDemirbas: TcxLabel;
    SqlMemoMasrafKalemi: TMemo;
    LabelCoklu: TcxLabel;
    ToolBar1: TToolBar;
    YaziciYaz: TToolButton;
    Panel1: TPanel;
    LabelKod: TcxLabel;
    Label1: TcxLabel;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YaziciyaYazdirMenu: TMenuItem;
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
    frxFATBASLIK: TfrxDBDataset;
    ComboDovKur: TcxDBComboBox;
    ComboKur: TcxDBComboBox;
    CheckEKSTREDEKULLAN: TcxDBCheckBox;
    procedure FormShow(Sender: TObject);
    procedure tamamButtonClick(Sender: TObject);
    procedure TabFatBaslikNewRecord(DataSet: TDataSet);
    procedure iptalButtonClick(Sender: TObject);
    procedure TabFatBaslikBeforePost(DataSet: TDataSet);
    procedure ComboBoxTahAciklamaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure TabFatBaslikBeforeEdit(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TabFatBaslikAfterPost(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LabelKodClick(Sender: TObject);
    procedure LabelAdClick(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BeditBagliGorevPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditProjeDblClick(Sender: TObject);
    procedure TabFatBaslikAfterOpen(DataSet: TDataSet);
    procedure EditTutarKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditDovTutarKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKulKurKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure KaydetveOdemeTusClick(Sender: TObject);
    procedure EditDemirbasPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelCokluClick(Sender: TObject);
    procedure ComboKurPropertiesCloseUp(Sender: TObject);
    procedure LabelKarsiligiClick(Sender: TObject);
  private
    procedure FirmaBilgileri(IDS:Integer);
    { Private declarations }
  public
    ID, RehberId, MasrafMerkezi,DemirbasID : Integer;
    Tur, Cagiran : SmallInt;  //Cagiran 1: Cari 3:Kasa 4:Banka
    IslemOp : Char;
    MakbuzNo, Kur: String[10];
    Aciklama : String[100];
    Tarih : TDateTime;
    Tutar : Currency;
    IptalSecildi,Kilit: Boolean;
    { Public declarations }
  end;

var
  TahakkukDlg : TTahakkukDlg;

implementation

uses FetaKurulusSiniflari, PrjConst, LocOnFly, fetautil, UGenelAnaSekmeFrame,
  URaporAraclari;

var OncekiTutar : Currency;
    OncekiHId, OncekiProjeId, OncekiMasrafId : Integer;
    BoslukVar,IlkAcilis : Boolean;

{$R *.dfm}

procedure TTahakkukDlg.TabFatBaslikAfterOpen(DataSet: TDataSet);
begin
  if TabFatBaslik.RecordCount>0 then begin
     if TabFatBaslik.FieldByName('KUR').AsString<>TabFatBaslik.FieldByName('DOVIZ_CINSI').AsString then
        LabelKarsiligiClick(nil);
     if TabFatBaslik.FieldByName('AKTIVITEID').AsString <> '' then
        BeditBagliGorev.Text := Tablo.AciklamaGetir('AKTIVITELER', 'KONUSU', TabFatBaslik.FieldByName('AKTIVITEID').Value);
  end;
end;

function TTahakkukDlg.EkranAdiAl: string;
begin
  case Tur of
    13  : Result := 'AlacakTahakkuku';
    17  : Result := 'BorcTahakkuku';
  else
    Result := 'Yok';
  end;
end;

procedure TTahakkukDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
  i : SmallInt;
  deger, FatTutar : Currency;
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl,frxFATBASLIK) then
    AFastReport.EnabledDataSets.Add(frxFATBASLIK)
  else begin
    frxFATBASLIK.DataSet := TabFatBaslik;
    AFastReport.EnabledDataSets.Add(frxFATBASLIK);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    Tablo.TabMusteri.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  end;
end;

procedure TTahakkukDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  tamamButtonClick(nil);
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set YAZDIRILDI=1 where ID='+TabFatBaslik.FieldByName('ID').AsString,[],[]);

end;

procedure TTahakkukDlg.TabFatBaslikAfterPost(DataSet: TDataSet);
begin
//   if (OncekiProjeId <> EditProje.Tag)or(OncekiMasrafId <> EditMM.Tag)then //değişiklik varsa
//       Tablo.CokluProjeMAsrafIslemleri(Tabno_FATBASLIK, TabFatBaslik.Fields[0].AsInteger ,OncekiProjeId, OncekiMasrafId, EditProje.Tag, EditMM.Tag, EditDovizTutar.Value, ComboDovizKur.Text);

   if islemOp='D' then  begin
      if Tur in [13] then
        Tablo.LogIslemleri(TabNo_TAHAKKUK_Alacak,ID, 4, TabFatBaslik)
      else if Tur in [17] then
        Tablo.LogIslemleri(TabNo_TAHAKKUK_Borc,ID, 4, TabFatBaslik)
   end;
   Tabloyenile(TabFatBaslik,[TabFatBaslik.FieldByName('ID').AsInteger]);
end;

procedure TTahakkukDlg.TabFatBaslikBeforeEdit(DataSet: TDataSet);
begin
   OncekiTutar := TabFatBaslik.FieldByName('FATURA_TUTARI').AsCurrency;

   if LogGun > 0 then begin
    Tablo.OncekiLogBelirle(TabFatBaslik);
   end;
end;

procedure TTahakkukDlg.TabFatBaslikBeforePost(DataSet: TDataSet);
begin
  if TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).AsString='' then
     raise Exception.Create(TDTutarDoluOlmali);
  case Tur of
    13 : BoslukVar := (BelgeGiderKalemi= 3)and(TabFatBaslik.FieldByName('MASRAFID').AsString='0');
    17 : BoslukVar := (BelgeGelirKalemi= 3)and(TabFatBaslik.FieldByName('MASRAFID').AsString='0');
  end;
  if BoslukVar then
     raise Exception.Create(LabelMasrafMerkezi.Caption+DoluOlmali);

  if KilitKontrolEt(1,Tur,EditTarih.Date, 2) then
      Abort;
  if PanelKarsilik.Visible then begin

    TabFatBaslik.FieldByName('DOVIZ_CINSI').Value := ComboDovKur.EditValue;
    if CheckEkstredeKullan.Checked then begin
       TabFatBaslik.FieldByName('RAPORDOVIZ').AsString := ComboDovKur.EditValue;
       TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency:=EditKulKur.EditValue;
       TabFatBaslik.FieldByName('DOVIZ_TUTARI').AsCurrency := EditDovTutar.EditValue;
//       TabFatBaslik.FieldByName('DOVIZ_CINSI').Value := ComboDovKur.EditValue;
    end else begin
  //     TabFatBaslik.FieldByName('DOVIZ_CINSI').Value := ComboKur.EditValue;
       TabFatBaslik.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
       if ComboKur.EditValue = CariDoviz then begin
          TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency:=1;
          TabFatBaslik.FieldByName('DOVIZ_TUTARI').AsCurrency := EditTutar.EditValue;
       end else begin
          TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency:=EditKulKur.EditValue;
          TabFatBaslik.FieldByName('DOVIZ_TUTARI').AsCurrency := EditDovTutar.EditValue;
       end;
 end;


     //TabFatBaslik.FieldByName('RAPORDOVIZ').AsString := ComboDovKur.EditValue;
  end else
  begin
     if ComboKur.EditValue = CariDoviz then begin//TL ise
        //TabFatBaslik.FieldByName('FATURA_TUTARI').AsCurrency := TabFatBaslik.FieldByName('DOVIZ_TUTARI').AsCurrency;
        TabFatBaslik.FieldByName('DOVIZ_TUTARI').AsCurrency := EditTutar.EditValue;
        TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency:=1;
     end else begin
        TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency:=DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', EditTarih.Date),
                             ComboKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));;
        TabFatBaslik.FieldByName('FATURA_TUTARI').AsCurrency := TabFatBaslik.FieldByName('DOVIZ_TUTARI').AsCurrency*TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency;
        TabFatBaslik.FieldByName('DOVIZ_CINSI').Value := ComboKur.EditValue;
     end;
  end;
  TabFatBaslik.FieldByName('TARIH').AsCurrency:=TabFatBaslik.FieldByName('FATURATARIH').AsCurrency;

  EkleyenDegistiren(TabFatBaslik);

  if not BoslukKontrol(EditTarih.Text, KontrolTarihi) then
     Abort;
  if not TarihKontrol(EditTarih.Date, KontrolTarihi) then
     Abort;
end;

procedure TTahakkukDlg.TabFatBaslikNewRecord(DataSet: TDataSet);
var
  Etiketler,Bilgiler:TArrayOfString;
begin
  TabFatBaslik.FieldByName('FATURATARIH').AsDateTime := Tarih; //KasaTarihi.Date;
  TabFatBaslik.FieldByName('FATURANO').AsString := MakbuzNo;
  TabFatBaslik.FieldByName('YERI').AsInteger := Cagiran; //Cağıran:1:cari tahakkuk; 3 kasa tahakkuk; 4:banka tahakkuk
  if Cagiran=3 then begin//kasa için tahakkuk
     TabFatBaslik.FieldByName('REHBERID').AsInteger := 0;
     TabFatBaslik.FieldByName('KASA').AsInteger := RehberId;
  end else
     TabFatBaslik.FieldByName('REHBERID').AsInteger := RehberId;

  TabFatBaslik.FieldByName('TIPI').AsInteger := 1;
  TabFatBaslik.FieldByName('EKSTREDEKULLAN').AsBoolean := False;
 // if Tutar >0 then
 //    TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).AsCurrency := Tutar; //EditTahsilatTutar.Value;
  OncekiTutar := 0;
  TabFatBaslik.FieldByName('BASLIK').AsString := '';
  TabFatBaslik.FieldByName('ACIKLAMA').AsString := Aciklama; //ComboDovizTutar.Text;
  TabFatBaslik.FieldByName('TUR').AsInteger:= Tur; //ComboKurTah.Text;
  TabFatBaslik.FieldByName('RAPORDOVIZ').AsString := Kur; //ComboKurTah.Text;
  TabFatBaslik.FieldByName('KUR').AsString := CariDoviz;
  TabFatBaslik.FieldByName('DOVIZ_CINSI').AsString := CariDoviz;
  TabFatBaslik.FieldByName('EKLEYEN').AsString := Kullanan;
  ComboSube.EditValue := SubeID;

  ////Masraf açıklama
  if MasrafMerkezi > 0 then
     TabFatBaslik.FieldByName('MASRAFID').AsInteger := MasrafMerkezi
  else
     TabFatBaslik.FieldByName('MASRAFID').AsInteger := Tablo.MasrafGelirKalemiGetir(Tur,RehberID);

  if DemirbasID > 0 then begin
    TabFatBaslik.FieldByName('DEMIRBASID').AsInteger := DemirbasID;
    EditDemirbas.Text := Tablo.AciklamaGetir('DEMIRBAS', 'DEMIRBASADI',DemirbasID);
    EditDemirbas.Tag := DemirbasID;
  end;

  ////SRMMErkezi açıklama
  TabFatBaslik.FieldByName('MERKEZID').AsInteger := Tablo.SRMMerkeziGetir(Tur,RehberID);
  if TabFatBaslik.FieldByName('MERKEZID').AsString <>'' then
     EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', TabFatBaslik.FieldByName('MERKEZID').AsInteger);
  ///
end;

procedure TTahakkukDlg.BeditBagliGorevPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
  if AButtonIndex = 0 then
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(AktiviteSecimi,'SELECT ID,KONUSU,NOTLAR FROM AKTIVITELER where KONUSU like ''%<ara>%'' and MUSTERIID=' + TabFatBaslik.FieldByName('REHBERID').AsString, st, []) then begin
        TabFatBaslik.Edit;
        TabFatBaslik.FieldByName('AKTIVITEID').AsString := st.Strings[0];
        BeditBagliGorev.Text := st.Strings[1];
      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
    TabFatBaslik.Edit;
    TabFatBaslik.FieldByName('AKTIVITEID').AsString := '-1';
    BeditBagliGorev.Text := '';
    TabFatBaslik.Post;
  end;

end;

procedure TTahakkukDlg.EditProjeDblClick(Sender: TObject);
begin
//  if EditProje.Text <> '' then
//     Tablo.ProjeSihirbazBaslat('D', TabFatBaslik.FieldByName('PROJEID').AsInteger, TabFatBaslik.FieldByName('REHBERID').AsInteger, Tablo.GENINI.BugunTrh);
end;

procedure TTahakkukDlg.EditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(EditProje, TabFatBaslik, AButtonIndex,ProjeSecimi, TabFatBaslik.FieldByName('REHBERID').AsInteger);
end;

procedure TTahakkukDlg.ComboBoxTahAciklamaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI, SqlText: string;
    i : SmallInt;
begin
  if AButtonIndex = 0 then begin
     //eğer proje seçilmişse ve o projeye girilmiş bütçe var ise o bütçe kalemlerinden masraf kalemi seçilir
    if (TabFatBaslik.FieldByName('PROJEID').AsString<>'')and
       (Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT top 1 * FROM PROJEBUTCE WHERE PROJEID='+TabFatBaslik.FieldByName('PROJEID').AsString,[],[])) then
        SqlText := SqlMemoMasrafKalemi.Text+ ' and PROJEID='+IntToStr( EditProje.Tag )
     else
        SqlText := '';

      if (Tur in [14..29])or(Tur=88) then
        i := 1
     else
        i := 0;

     if (Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI, SqlText)) then begin
        TabFatBaslik.Edit;
        if ((TabFatBaslik.FieldByName('ACIKLAMA').AsString='')or(TabFatBaslik.FieldByName('ACIKLAMA').AsString=EditMM.Text)) then
          TabFatBaslik.FieldByName('ACIKLAMA').AsString := MASRAFMERKEZI;

        TabFatBaslik.FieldByName('MASRAFID').AsString := MASRAFID;
        EditMM.Text := MASRAFMERKEZI;
     end;
  end else if AButtonIndex = 1 then  begin
        TabFatBaslik.Edit;
        if TabFatBaslik.FieldByName('ACIKLAMA').AsString=EditMM.Text then
          TabFatBaslik.FieldByName('ACIKLAMA').AsString := '';

        TabFatBaslik.FieldByName('MASRAFID').AsString := '-1';
        EditMM.Text := '';
  end;

end;

procedure TTahakkukDlg.ComboKurPropertiesCloseUp(Sender: TObject);
var
   PBirimi:String[10];
begin
//   PanelKarsilik.Visible := ComboKur.EditValue<>CariDoviz;
{   if (not IlkAcilis)and(Sender <> nil) then begin
       EditKulKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', EditTarih.Date), ComboKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
       if EditKulKur.Value=0 then
          EditKulKur.Value:=1;
       TabFatBaslik.FieldByName('FATURA_TUTARI').Value := EditTutar.Value*EditKulKur.Value;
       TabFatBaslik.FieldByName('DOVIZ_CINSI').Value := ComboKur.EditValue;
  end
  else
       EditKulKur.EditValue := TabFatBaslik.FieldByName('DOVIZKUR').AsCurrency;}

 // if (ComboKur.EditValue<>CariDoviz)or(ComboDovKur.EditValue<>CariDoviz) then


   if ComboKur.EditValue<>CariDoviz then
     PBirimi:= ComboKur.EditValue
  else
     PBirimi:= ComboDovKur.EditValue;

  //if IslemOp = 'D' then
  //    EditDovTutarKeyUp(Self, K, [])
  //else
   EditKulKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', EditTarih.Date), PBirimi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
   EditKulKur.PostEditValue;
   LabelKarsiligiClick(Self);
end;

procedure TTahakkukDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (IptalSecildi) and ((IslemOp = 'E') or (IslemOp='K')) then// eğer yeni kayıtsa ve iptal edildiyse kaydedilmiş bilgilir silinmesi lazım
    if (TabFatBaslik.Active) and (TabFatBaslik.Fields[0].AsString <> '') then
     begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from FATBASLIK where ID=&yer_id ',[ '&yer_id'],[ TabFatBaslik.FieldByName('ID').AsInteger]);
     end;
end;

procedure TTahakkukDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := not BoslukVar;
end;

procedure TTahakkukDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);// Dil Yükleniyor.
   Tutar := 0;
   Kur := CariDoviz;
   LogID:=0;
   IptalSecildi := true;

   LabelKarsiligi.Visible := DovizTakibi;
   //PanelKarsilik.Visible := DovizTakibi;
end;

procedure TTahakkukDlg.FormShow(Sender: TObject);
Var
  Gelirmi:Smallint;
  ra: string;
  Etiketler,Bilgiler:TArrayOfString;
  aktifFrame: TGenelAnaSekmeFrame;
begin


  IlkAcilis:=True;
  EditProje.Visible := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_ProjeGozuksun, True);
  LabelProje.Visible := EditProje.Visible;
  EditDemirbas.Visible := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_DemirbasGozuksun, True);
  lblDemirbas.Visible := EditProje.Visible;
  case Tur of
    13 : begin
           Caption :=Alacak +' Tahakkuk';// Tahsilat;
           Label1.Caption := Alacak+Label1.Caption;
           LabelMasrafMerkezi.Visible := BelgeGiderKalemi>1;
           EditMM.Visible := BelgeGiderKalemi>1;
           //LabelCoklu.Visible := BelgeGiderKalemi > 3;
           LabelMasrafMerkezi.Caption := 'Masraf Kalemi';

           LabelSRM.Visible := BelgeGiderSRM>1;
           EditSRMMerkezi.Visible := BelgeGiderSRM>1;
           KaydetveOdemeTus.caption := 'Kaydet ve Öde';
         end;
    17 : begin
           Caption := Borc +' Tahakkuk';//Odeme;
           Label1.Caption := Borc+Label1.Caption;
           LabelMasrafMerkezi.Visible := BelgeGelirKalemi>1;
           EditMM.Visible := BelgeGelirKalemi>1;
           //LabelCoklu.Visible := BelgeGiderKalemi > 3;
           LabelMasrafMerkezi.Caption := 'Gelir Kalemi';

           LabelSRM.Visible := BelgeGelirSRM>1;
           EditSRMMerkezi.Visible := BelgeGelirSRM>1;
           KaydetveOdemeTus.caption := 'Kaydet ve Tahsil Et';
         end;
  end;
 // ComboKur.RepositoryItem := Tablo.cxEditRepository1ComboBoxItemKurlar;
  EditTutar.SetFocus;
  Kilit := False;

  TabloYenile(TabFatBaslik, [ID]);
  if IslemOp = 'E' then begin
     TabFatBaslik.Append;
  end else if IslemOp in ['D', 'K'] then begin
     Kilit := KilitKontrolEt(2,Tur,EditTarih.Date,2);
     if Kilit then begin
        TabFatBaslik.Close;
        TabFatBaslik.Open;
     end;
     ComboSube.EditValue := TabFatBaslik.FieldByName('SUBEID').AsInteger;
     //de�i�iklik i�in gelen tutar kuru tl de�ilse alttaki
     if (ComboKur.EditValue<>CariDoviz)and(PanelKarsilik.Visible = False) then
        //ComboKurPropertiesCloseUp(Self);
        PanelKarsilik.visible:=True;
  end;
  { else if IslemOp='K' then begin     dışarı alındıııı

   ID := Tablo.SQLSatiriKopyala('FATBASLIK',ID,['TARIH', 'FATURATARIH', 'EKLEYEN', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
            [Tablo.GENINI.BugunTrh, Tablo.GENINI.BugunTrhSaat, Kullanan,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
    TabFatBaslik.Close;
    TabFatBaslik.Params[0].Value := ID;
    TabFatBaslik.Open;
  end; }

  if (Cagiran=3)or(RehberId < -1) then begin//Kasa bilgileri
     Tablo.TablodanSorguAc(1,'Select KASAKODU,KASAADI,KUR from KASALAR Where ID='+IntToStr(Abs(RehberId)));
     LabelKod.Caption := Tablo.Query1.Fields[0].AsString;
     LabelAd.Caption := Tablo.Query1.Fields[1].AsString;
     ComboKur.EditValue := Tablo.Query1.Fields[2].AsString;
     ComboKur.Enabled := False;
     if (not PanelKarsilik.Visible)and(ComboKur.EditValue<>CariDoviz) then begin
         IlkAcilis := False;
         LabelKarsiligiClick(Self);
     end;
  end
  else begin
     FirmaBilgileri(RehberId);
//     ComboKur.EditValue := CariDoviz;
  end;

   ////Masraf açıklama
   ///
    if TabFatBaslik.FieldByName('MASRAFID').AsString <>'' then //begin
       EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabFatBaslik.FieldByName('MASRAFID').AsInteger);

  ////SRMMErkezi açıklama
     if TabFatBaslik.FieldByName('MERKEZID').AsString <>'' then //begin
        EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', TabFatBaslik.FieldByName('MERKEZID').AsInteger);
  if TabFatBaslik.FieldByName('DEMIRBASID').AsString <>'' then begin
    EditDemirbas.Text := Tablo.AciklamaGetir('DEMIRBAS', 'DEMIRBASADI', DemirbasID);
    EditDemirbas.Tag := DemirbasID;
  end;

  Tablo.ProjeMaliyetOnDeger(OncekiProjeId,OncekiMasrafId,EditProje,EditMM,TabFatBaslik.FieldByName('PROJEID').AsInteger,
        TabFatBaslik.FieldByName('MASRAFID').AsInteger, TabFatBaslik.FieldByName('REHBERID').AsInteger, TabFatBaslik.FieldByName('TUR').AsInteger);

  IlkAcilis:=False;

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;


end;

procedure TTahakkukDlg.iptalButtonClick(Sender: TObject);
begin
  BoslukVar:=False;
  close;
end;

procedure TTahakkukDlg.KaydetveOdemeTusClick(Sender: TObject);
begin
   if TabFatBaslik.State in [dsInsert, dsEdit] then
     TabFatBaslik.Post;
   if Tablo.TahsilatIslemi(Tur,TabFatBaslik.FieldByName('REHBERID').AsInteger,TabFatBaslik.FieldByName('MASRAFID').AsInteger, TabFatBaslik.FieldByName('FATURA_TUTARI').AsCurrency,
              TabFatBaslik.FieldByName('KUR').AsString,TabFatBaslik.FieldByName('ACIKLAMA').AsString, TabFatBaslik.FieldByName('FATURATARIH').AsDateTime) then
      TamamButton.Click
end;

procedure TTahakkukDlg.LabelAdClick(Sender: TObject);
begin
  Tablo.RehberSihirbazBaslat(0, TabFatBaslik.FieldByName('REHBERID').AsInteger, -100, -100, False);
  FirmaBilgileri(RehberId);
end;

procedure TTahakkukDlg.LabelCokluClick(Sender: TObject);
begin
  if TabFatbaslik.State  in [dsEdit,dsInsert] then
     TabFatbaslik.Post;
  Tablo.ProjeMaliyetIslemleri(Tabno_FatBaslik,TabFatbaslik.Fields[0].AsInteger,TabFatbaslik.FieldByName('REHBERID').AsInteger, Tur)
end;

procedure TTahakkukDlg.LabelKarsiligiClick(Sender: TObject);
var
//   PBirimi:String[10];
   K:Word;
begin
   {TabFatbaslik.Edit;
   PanelKarsilik.Visible := not PanelKarsilik.Visible;
   if PanelKarsilik.Visible then
      ComboKurPropertiesCloseUp(Self);    }
  if not DovizTakibi then exit;

  PanelKarsilik.Visible := True;//(ComboKur.EditValue<>CariDoviz)or(TabKasa.FieldByName('EKSTREDEKULLAN').AsBoolean);
  {
  if ComboKur.EditValue<>CariDoviz then
     PBirimi:= ComboKur.EditValue
  else
     PBirimi:= ComboDovKur.EditValue;

  if IslemOp = 'D' then
      EditDovTutarKeyUp(Self, K, [])
  else
      EditKulKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', EditTarih.Date), PBirimi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
  }
  if not IlkAcilis then
     EditTutarKeyUp(Self, K, []);
end;

procedure TTahakkukDlg.LabelKodClick(Sender: TObject);
var
  Id: Integer;
  SonucListe : TStringList;
begin
  if Cagiran=3 then begin //Kasa tahakkuksa
       SonucListe := TStringList.Create;
       if Tablo.ListedenBilgiGetir('Kasa Seçimi','select ID, KASAKODU, KASAADI, KUR FROM KASALAR where DURUM=1 and (KASAKODU like ''%<ara>%'' or KASAADI like ''%<ara>%'')',SonucListe,[nil, nil, nil])then begin
          Id := -1 * StrToIntDef(SonucListe[0],0);
          LabelKod.Caption := SonucListe[1];
          LabelAd.Caption := SonucListe[2];
       end else
          Id := 0;
       SonucListe.Free;
  end else begin //cari
       Id := Tablo.RehberAra_IDGetir(-1);
       FirmaBilgileri(Id)
  end;
  if Id <> 0 then
  begin
    RehberId := Id;
    if TabFatBaslik.State = dsBrowse then
      TabFatBaslik.Edit;
    TabFatBaslik.FieldByName('REHBERID').AsInteger := RehberId;
  end;
end;
procedure TTahakkukDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
  Gelirmi : Smallint;
begin

  if AButtonIndex = 0 then
    try
      if Tur in [14..29] then
        Gelirmi := 1
     else
        Gelirmi := 0;

      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir('Sorumluluk Merkezi seçiniz','SELECT ID,MERKEZKODU,MERKEZADI FROM SRMMERKEZI where GELIRMI ='+IntToStr(Gelirmi)+' and MERKEZADI like ''%<ara>%'' ',  st, []) then begin
        TabFatBaslik.Edit;
        TabFatBaslik.FieldByName('MERKEZID').AsString := st.Strings[0];
        EditSRMMerkezi.Text := st.Strings[2];
      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
      TabFatBaslik.Edit;
      TabFatBaslik.FieldByName('MERKEZID').AsInteger := 0;
      EditSRMMerkezi.Text := '';
  end;
end;

procedure TTahakkukDlg.EditDemirbasPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
  if AButtonIndex = 0 then
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir('Demirbaş seçiniz','SELECT ID,DEMIRBASNO,DEMIRBASADI FROM DEMIRBAS where DEMIRBASNO like ''%<ara>%'' or DEMIRBASADI like ''%<ara>%'' ',  st, []) then begin
        TabFatBaslik.Edit;
        TabFatBaslik.FieldByName('DEMIRBASID').AsString := st.Strings[0];
        EditDemirbas.Text := st.Strings[2];
        EditDemirbas.Tag := StrToInt(st.Strings[0]);
      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
      TabFatBaslik.Edit;
      TabFatBaslik.FieldByName('DEMIRBASID').AsInteger := 0;
      EditDemirbas.Text := '';
      EditDemirbas.Tag := 0;
  end;
end;

procedure TTahakkukDlg.EditTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

   if PanelKarsilik.Visible then begin
      if ComboKur.EditValue = ComboDovKur.EditValue then
                  EditKulKur.Value := 1;
      if (ComboKur.EditValue=CariDoviz)and(EditKulKur.Value>0) then
          EditDovTutar.Value := EditTutar.Value / EditKulKur.Value
      else if ComboKur.EditValue<>CariDoviz then
          EditDovTutar.Value := EditTutar.Value * EditKulKur.Value;
   end;
   EditTutar.PostEditValue;

//   if PanelKarsilik.Visible then begin
//      EditFaturaTutar.Value := EditDovizTutar.Value*EditKulKur.value;//çarp
//      EditFaturaTutar.PostEditValue;
//   end;
end;

procedure TTahakkukDlg.EditDovTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//     EditDovizTutar.Value := EditFaturaTutar.Value/EditKulKur.value;//böl
//     EditDovizTutar.PostEditValue;

  EditDovTutar.PostEditValue;
  if ComboKur.EditValue=CariDoviz then
        EditKulKur.EditValue := TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).Value/TabFatBaslik.FieldByName('DOVIZ_TUTARI').Value
  else begin
        if TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).Value<>0 then
            EditKulKur.EditValue := TabFatBaslik.FieldByName('DOVIZ_TUTARI').Value/TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).Value
        else
           EditKulKur.EditValue := 1;
  end;
  EditKulKur.PostEditValue;
end;

procedure TTahakkukDlg.EditKulKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//   EditFaturaTutar.Value := EditDovizTutar.Value*EditKulKur.value;//çarp
//   EditFaturaTutar.PostEditValue;
  TabFatBaslik.Edit;
  if ComboKur.EditValue=CariDoviz then begin
    TabFatBaslik.FieldByName('DOVIZ_TUTARI').Value := TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).Value/EditKulKur.value//böl
  end else if ComboDovKur.EditValue=CariDoviz then begin
    TabFatBaslik.FieldByName('DOVIZ_TUTARI').Value := TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).Value*EditKulKur.value//çarp
  end else begin
    TabFatBaslik.FieldByName('DOVIZ_TUTARI').Value := TabFatBaslik.FieldByName(EditTutar.DataBinding.DataField).Value*EditKulKur.value//??çarp
  end;
end;

procedure TTahakkukDlg.FirmaBilgileri(IDS:Integer);
begin
  Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(IDS)+' and VARSAYILAN = 1 ');
  TabloYenile(Tablo.tabCariBilgileri, [IDS,tablo.Query1.Fields[0].AsInteger]);
  TabloYenile(Tablo.tabCariBilgileri, [IDS,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
//  lblMusteriTel.Caption := isTel + Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
//  lblMusteriEposta.Caption := EPosta + Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TTahakkukDlg.tamamButtonClick(Sender: TObject);
begin
   if PanelKarsilik.Visible then begin
      if (ComboKur.EditValue<>CariDoviz)and(ComboDovKur.EditValue<>CariDoviz) then begin
         Showmessage(YerelParaZorunlu);
         Abort
      end;

   end;


   //Daha önce eklendi kontrolü yapalım
   if (Veritabani.VeriVarMi(Tablo.FDCnn,'select * from FATBASLIK where ID<>'+IntToStr(TabFatBaslik.Fields[0].AsInteger)+' and REHBERID='+IntToStr(TabFatBaslik.FieldByName('REHBERID').AsInteger)+
         ' and FATURATARIH between '''+FormatDateTime('yyyy-mm-dd 00:00',EditTarih.Date)+'''  and '''+FormatDateTime('yyyy-mm-dd 23:59:59',EditTarih.Date)+''''+
         ' and TUR='+IntToStr(TabFatBaslik.FieldByName('TUR').AsInteger)+' and  '+EditDovTutar.DataBinding.DataField+'='+ Float_ToStr(EditTutar.Value),[],[]))
      and(Application.MessageBox(PChar(DahaOnceEklenmis+' '+Devam_Etmek),PChar(Onay),MB_YESNO)=ID_NO)then
      abort;
   if TabFatBaslik.State in [dsInsert, dsEdit] then begin
     if TabFatBaslik.FieldByName('REHBERID').AsInteger = -99 then
       TabFatBaslik.FieldByName('REHBERID').AsInteger := 0;
     TabFatBaslik.Post ;
   end;

  IptalSecildi := False;



   if Sender <> nil then
     ModalResult := mrOk;

end;

end.







