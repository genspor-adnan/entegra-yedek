unit UBelgeDonusum;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinLiquidSky, cxCustomData, UTablo, cxGridCustomPopupMenu, cxGridPopupMenu,
  cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxContainer, Vcl.ComCtrls,
  dxCore, cxDateUtils, cxDropDownEdit, cxCalendar, cxTextEdit, cxMaskEdit, cxImageComboBox, cxLabel,
  cxGroupBox, JvTimer, JvExControls, JvButton, JvNavigationPane, FireDAC.Comp.Client, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.ExtCtrls,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, Vcl.Menus, cxRadioGroup, UBekletme, UIzleme,
  cxCheckBox, Vcl.StdCtrls, UFiyatSor, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxBarBuiltInMenu,
  cxPC, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TBelgeDonusumDlg = class(TForm)
    PanelKaynak: TPanel;
    cxGridKaynak: TcxGrid;
    cxGridKaynakLevel1: TcxGridLevel;
    TabKaynak: TFDQuery;
    DtsKaynak: TDataSource;
    Panel1: TPanel;
    BtnSec: TJvNavPanelButton;
    Panel3: TPanel;
    cxGroupBox1: TcxGroupBox;
    cxGroupBox2: TcxGroupBox;
    cxLabel1: TcxLabel;
    cbTur: TcxImageComboBox;
    cxLabel4: TcxLabel;
    EdBelgeNo: TcxTextEdit;
    DtBas: TcxDateEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    DtBit: TcxDateEdit;
    edStokAd: TcxTextEdit;
    cxLabel6: TcxLabel;
    edStokKod: TcxTextEdit;
    cxLabel5: TcxLabel;
    edBarkod: TcxTextEdit;
    cxLabel7: TcxLabel;
    JvTimer1: TJvTimer;
    cxGridKaynakDBTableView1: TcxGridDBTableView;
    cxGridKaynakDBTableView1FIRMA: TcxGridDBColumn;
    cxGridKaynakDBTableView1TARIH: TcxGridDBColumn;
    cxGridKaynakDBTableView1BELGENO: TcxGridDBColumn;
    cxGridKaynakDBTableView1KOD: TcxGridDBColumn;
    cxGridKaynakDBTableView1STOKADI: TcxGridDBColumn;
    cxGridKaynakDBTableView1ADET: TcxGridDBColumn;
    cxGridKaynakDBTableView1BIRIM: TcxGridDBColumn;
    cxGridKaynakDBTableView1BIRIMFIYAT: TcxGridDBColumn;
    cxGridKaynakDBTableView1ISKONTO: TcxGridDBColumn;
    cxGridKaynakDBTableView1ISKONTO2: TcxGridDBColumn;
    cxGridKaynakDBTableView1TUTAR: TcxGridDBColumn;
    cxGridKaynakDBTableView1DONUSEN: TcxGridDBColumn;
    cxGridKaynakDBTableView1KALAN: TcxGridDBColumn;
    PopupGrid: TPopupMenu;
    StokDetay1: TMenuItem;
    zlemeDetay1: TMenuItem;
    PanelDetayliAra: TPanel;
    Panel4: TPanel;
    lbDetayliArama: TcxLabel;
    GrpBoyut: TcxGroupBox;
    GrpSKT: TcxGroupBox;
    EditAciklama: TcxTextEdit;
    GrpKarekod: TcxGroupBox;
    EditKarekod: TcxTextEdit;
    GrpSerino: TcxGroupBox;
    EditSerino: TcxTextEdit;
    DateSKT: TcxDateEdit;
    cbBoyutKombinasyon: TcxImageComboBox;
    cbBoyut1: TcxImageComboBox;
    cbBoyut2: TcxImageComboBox;
    cbBoyut3: TcxImageComboBox;
    rgIzlemTuru: TcxRadioGroup;
    cxGridPopupMenu1: TcxGridPopupMenu;
    cxGridKaynakDBTableView1TESLIMTARIHI: TcxGridDBColumn;
    cxGridKaynakDBTableView1KUR: TcxGridDBColumn;
    N1: TMenuItem;
    Gizle1: TMenuItem;
    GizlemeyiKaldr1: TMenuItem;
    checkKalmayanGoster: TcxCheckBox;
    checkGizlenenGoster: TcxCheckBox;
    cxGridKaynakDBTableView1GIZLE: TcxGridDBColumn;
    cxGridKaynakDBTableView1SATICI: TcxGridDBColumn;
    cxGridKaynakDBTableView1PROJEKODU: TcxGridDBColumn;
    cxGridKaynakDBTableView1IADE: TcxGridDBColumn;
    TabSeriLotHareket: TFDQuery;
    DtsSeriLotHareket: TDataSource;
    PageHareketSeriLot: TcxPageControl;
    cxTabSheet4: TcxTabSheet;
    GridSeriLotHareket: TcxGrid;
    GridSeriLotHareketView: TcxGridDBTableView;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    GridSeriLotHareketViewColumn1: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    cxGridKaynakDBTableView1SEVK: TcxGridDBColumn;
    cxGridKaynakDBTableView1URUNNO: TcxGridDBColumn;
    cxGridKaynakDBTableView1OZELKOD: TcxGridDBColumn;
    cxGridKaynakDBTableView1POZNO: TcxGridDBColumn;
    cxGridKaynakDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxLabel8: TcxLabel;
    edUrunNo: TcxTextEdit;
    cxGridKaynakDBTableView1DETAY_OZELKOD: TcxGridDBColumn;
    cxGridKaynakDBTableView1DETAY_OZELKOD2: TcxGridDBColumn;
    cxGridKaynakDBTableView1OZELKOD2: TcxGridDBColumn;
    cxGridKaynakDBTableView1EMIRNO: TcxGridDBColumn;
    cxGridKaynakDBTableView1DEPOAD: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure AramaYap;
    procedure TurCombosunuDoldur;
    procedure edBarkodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edStokAdPropertiesEditValueChanged(Sender: TObject);
    procedure DonusTipiGuncelle;
    procedure JvTimer1Timer(Sender: TObject);
    procedure BtnSecClick(Sender: TObject);
    procedure DtsKaynakStateChange(Sender: TObject);
    procedure StokEkle;
    function FiyatSor(Var TLFiyat:Currency; var DovizFiyat:Currency; Var Kur:String; var KDV:integer; var Adet:extended; var KurDegeri:extended; var Isk1:extended; var Isk2:extended; var StkID:integer;
             var UrunTur:integer; var BrmFyt:extended; var ProjeID:integer; var Aciklama:string;
             var En:extended;var Boy:extended; var Yuzey:extended;var Sayi:extended):Boolean;
    procedure cxGridKaynakDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure StokDetay1Click(Sender: TObject);
    procedure zlemeDetay1Click(Sender: TObject);
    procedure lbDetayliAramaClick(Sender: TObject);
    procedure EditSerinoPropertiesEditValueChanged(Sender: TObject);
    procedure EditSerinoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKarekodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditAciklamaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbBoyutKombinasyonPropertiesEditValueChanged(Sender: TObject);
    procedure rgIzlemTuruPropertiesEditValueChanged(Sender: TObject);
    procedure cxGridKaynakDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure Gizle1Click(Sender: TObject);
    procedure GizlemeyiKaldr1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabKaynakAfterScroll(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
    BekletDlg: TBekletmeDlg;
    IzlemDlg: TIzlemeDlg;
  public
    RehID,HedefBaslikTur,HedefBaslikID,DonusumTuru, SecilenUrunId,SecilenSatirId : integer;
    SecilenAdet : extended;
    SecilenBelgeNo : string;
    SecilenBelgeTeslimTr : TDateTime;
    GDepo,CDepo:integer;
    TabDetayGiris, TabKaynakBaslik : TFDQuery;
    { Public declarations }
  end;

var
  BelgeDonusumDlg: TBelgeDonusumDlg;
  HedefTablo : String[30];

implementation

uses
   FetaKurulusSiniflari, FetaClassExtensions, UUretimWizard, UAnaForm, PrjConst, UVeriMotor;

{$R *.dfm}

procedure TBelgeDonusumDlg.edBarkodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  (Sender as TcxTextEdit).PostEditValue;
end;

procedure TBelgeDonusumDlg.EditAciklamaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditAciklama.PostEditValue;
end;

procedure TBelgeDonusumDlg.EditKarekodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditKarekod.PostEditValue;
end;

procedure TBelgeDonusumDlg.EditSerinoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditSerino.PostEditValue;
end;

procedure TBelgeDonusumDlg.EditSerinoPropertiesEditValueChanged(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TBelgeDonusumDlg.edStokAdPropertiesEditValueChanged(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TBelgeDonusumDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GenRegIni.RegWriteString('BelgeDonusum', 'BaslamaTarihi', DtBas.EditValue, 'C');
  GenRegIni.RegWriteString('BelgeDonusum', 'BitisTarihi',   DtBit.EditValue, 'C');
end;

procedure TBelgeDonusumDlg.FormCreate(Sender: TObject);
begin
    DonusumTuru := 0;
    Tablo.GridAyarRestore('DonusumKaynakGridi',cxGridKaynakDBTableView1 );
end;

procedure TBelgeDonusumDlg.FormShow(Sender: TObject);
begin
  TurCombosunuDoldur;
  DtBas.EditValue := StrToDateDef(GenRegIni.RegReadString('BelgeDonusum', 'BaslamaTarihi',  '0','C'), Tablo.GENINI.BugunTrh-30);
  DtBas.PostEditValue;

  DtBit.EditValue := StrToDateDef(GenRegIni.RegReadString('BelgeDonusum', 'BitisTarihi',  '0','C'), Tablo.GENINI.BugunTrh);
  DtBit.PostEditValue;
  if cbTur.properties.Items.count>0 then begin
     if HedefBaslikTur=15 then
        cbTur.EditValue := 14
     else
        cbTur.EditValue := cbTur.Properties.Items[0].Value;
  end;
  cbTur.PostEditValue;
  cxGridKaynakDBTableView1BIRIMFIYAT.Visible :=  (cbTur.EditValue <> 101)and(cbTur.EditValue <> 105);//satınalma veya stok talebi değilse birim fiyat görünsün
  cxGridKaynakDBTableView1ISKONTO.Visible := cxGridKaynakDBTableView1BIRIMFIYAT.Visible;
  cxGridKaynakDBTableView1ISKONTO2.Visible := cxGridKaynakDBTableView1BIRIMFIYAT.Visible;
  cxGridKaynakDBTableView1TUTAR.Visible := cxGridKaynakDBTableView1BIRIMFIYAT.Visible;

  BtnSec.Visible := TabDetayGiris <> nil;
  //28.03.2024 AO alttaki kod eklendi..
 // AramaYap;
end;

procedure TBelgeDonusumDlg.Gizle1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DONUSUMBILGISIGIZLE(KAYNAKTUR,HEDEFTUR,KAYNAKID,EKLEYEN,EKLEMETARIHI)values('+VarToStr(cbTur.EditValue)+','+IntToStr(HedefBaslikTur)+','+TabKaynak.FieldByName('SATIRID').AsString+','+Kullanan+',GetDate())',[],[]);
  AramaYap;
end;

procedure TBelgeDonusumDlg.GizlemeyiKaldr1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DONUSUMBILGISIGIZLE where KAYNAKTUR='+VarToStr(cbTur.EditValue)+' and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID='+TabKaynak.FieldByName('SATIRID').AsString,[],[]);
  AramaYap;
end;

procedure TBelgeDonusumDlg.JvTimer1Timer(Sender: TObject);
begin
  AramaYap;
end;

procedure TBelgeDonusumDlg.lbDetayliAramaClick(Sender: TObject);
begin
  PanelDetayliAra.Visible := not PanelDetayliAra.Visible;
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TBelgeDonusumDlg.rgIzlemTuruPropertiesEditValueChanged(Sender: TObject);
begin
  GrpSerino.Visible := rgIzlemTuru.ItemIndex=0;
  GrpKarekod.Visible := rgIzlemTuru.ItemIndex=1;
  GrpSKT.Visible := rgIzlemTuru.ItemIndex=2;
  GrpBoyut.Visible := rgIzlemTuru.ItemIndex=3;
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TBelgeDonusumDlg.TabKaynakAfterScroll(DataSet: TDataSet);
begin
   if PageHareketSeriLot.Visible then begin
      TabloYenile(TabSeriLotHareket,[TabKaynak.FieldByName('STOKID').AsInteger, TabKaynak.FieldByName('SATIRID').AsInteger]);
      GridSeriLotHareketView.ApplyBestFit();
   end;
end;

procedure TBelgeDonusumDlg.TurCombosunuDoldur;
var cbTurler, s : string;
begin
  cbTur.Properties.Items.Clear;
  case HedefBaslikTur of
    9:begin //Alış Siparişi
      cbTur.Properties.items.Clear;
      with cbTur.Properties.items.Add do begin
        Description := 'Satış Teklifi';
        Value := 99;
      end;
      with cbTur.Properties.items.Add do begin
        Description := 'Satınalma Talebi';
        Value := 101;
      end;
    end;
    6, 66:begin  //üretim fişi - üretim emri
      cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(19) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;
    10:begin  //alış irsaliyesi
      cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(9,109) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;
    11,12:begin  //alış faturası  ve alış fişi
       // önce giriş depoya bakarız
        Tablo.TablodanSorguAc(1, 'select VARSAYILAN from DEPOLAR where ID='+IntToStr(GDepo));
       //eğer kons giriş depoysa listeye sadece gelen konsinyeler listelenir, ana depoysa gelen konsinye harici listelenir
       if Tablo.Query1.Fields[0].AsInteger=5 then
          s:='109'
       else
          s:='9,10';
      cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in('+s+') AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;
    //14:begin  //satış irsaliyesi
    //  cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(6,19,119) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    //end;
    14,15,16:begin  //satış irsaliye - faturası - fişi
        cbTurler := '';
        if cDepo <> 1 then begin //konsinye çıkış deposu ise sadece giden konsinye yapılmalıdır
           Tablo.TablodanSorguAc(1,'select VARSAYILAN from DEPOLAR where ID='+IntToStr(cDepo));
           if (Tablo.Query1.Recordcount>0)and(Tablo.Query1.Fields[0].AsInteger=7) then begin
               if HedefBaslikTur=15 then
                  cbTurler := '119,14'
               else
                  cbTurler := '119';
           end;
        end;

        if cbTurler = '' then begin
            if HedefBaslikTur in [14,16] then  //hedef irsaliye veya fiş ise
                    cbTurler := '6,14,19'
            else if HedefBaslikTur=15 then begin
                    if not (Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest]) then
                       cbTurler := '6,14,19'
                    else
                       cbTurler := '6,14,19,110';
            end;
        end;

//      if not (Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest]) then
//        cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(6,14,19,119) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items
//      else
//        cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(6,14,19,110,119) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
        cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in('+cbTurler+') AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;
    20:begin  //transfer
        cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(105) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;
    {16:begin  //satış fişi
      if not (Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest]) then
        cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(0) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items
      else
        cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(110) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;}
    19:begin //Satış Siparişi
      cbTur.Properties.items.Clear;
      with cbTur.Properties.items.Add do begin
        Description := 'Satış Teklifi';
        Value := 99;
      end;
    end;
    119:begin  //satış konsinye
      cbTur.Properties.items := Tablo.imgComboboxInit( 'select DEGER ,ANAHTAR from GENINI WHERE BOLUM=-1005 AND DEGER in(19) AND DIL='+IntToStr(Dil)+' ORDER BY 2 ').items;
    end;
  end;
end;

procedure TBelgeDonusumDlg.zlemeDetay1Click(Sender: TObject);
begin
//  AnaForm.StokIzlemeDetayiGosterBelge(cbTur.EditValue,TabKaynak.FieldByName('BASLIKID').AsInteger,TabKaynak.FieldByName('SATIRID').AsInteger,TabKaynak.FieldByName('IZLEME').AsInteger,TabKaynak.FieldByName('STOKID').AsInteger);
   PageHareketSeriLot.Visible := not PageHareketSeriLot.Visible;
   if PageHareketSeriLot.Visible then
      TabKaynakAfterScroll(TabKaynak);
end;

procedure TBelgeDonusumDlg.BtnSecClick(Sender: TObject);
begin
  if TabKaynak.FieldByName('KALAN').AsFloat > 0.0001 then begin
      StokEkle;
      TabloYenile(TabDetayGiris,[]);
      TabloYenile(TabKaynak,[]);
      BtnSec.Down := False;
      edBarkod.Text := '';
  end
  else
      Showmessage(DDKalan_sifir_eklenmez);
end;

procedure TBelgeDonusumDlg.cbBoyutKombinasyonPropertiesEditValueChanged(Sender: TObject);
begin
  if cbBoyutKombinasyon.EditValue>0 then begin
    Tablo.TablodanSorguAc(0,'select * from STOKBOYUTGRUPLARI where ID='+VarToStr(cbBoyutKombinasyon.EditValue));
    Tablo.GENINI.ReadImageSection(Tablo.Query0.FieldByName('BOYUT1').AsInteger,(cbBoyut1.Properties as TcxImageComboBoxProperties).Items,False);
    Tablo.GENINI.ReadImageSection(Tablo.Query0.FieldByName('BOYUT2').AsInteger,(cbBoyut2.Properties as TcxImageComboBoxProperties).Items,False);
    Tablo.GENINI.ReadImageSection(Tablo.Query0.FieldByName('BOYUT3').AsInteger,(cbBoyut3.Properties as TcxImageComboBoxProperties).Items,False);
    cbBoyut1.Visible := Tablo.Query0.FieldByName('BOYUT1').AsInteger<>0;
    cbBoyut2.Visible := Tablo.Query0.FieldByName('BOYUT2').AsInteger<>0;
    cbBoyut3.Visible := Tablo.Query0.FieldByName('BOYUT3').AsInteger<>0;
    cbBoyut1.Tag := Tablo.Query0.FieldByName('BOYUT1').AsInteger;
    cbBoyut2.Tag := Tablo.Query0.FieldByName('BOYUT2').AsInteger;
    cbBoyut3.Tag := Tablo.Query0.FieldByName('BOYUT3').AsInteger;
  end;
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TBelgeDonusumDlg.cxGridKaynakDBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := cxGridKaynak;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := cxGridKaynakDBTableView1;
  AnaForm.pmGridStil.Tags.Values[cxGridKaynak.Name] := 'DonusumKaynakGridi';
end;

procedure TBelgeDonusumDlg.cxGridKaynakDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  BtnSecClick(Self);
end;

function TBelgeDonusumDlg.FiyatSor(Var TLFiyat:Currency; var DovizFiyat:Currency; Var Kur:String; var KDV:integer; var Adet:extended; var KurDegeri:extended;
         var Isk1:extended; var Isk2:extended; var StkID:integer; var UrunTur:integer; var BrmFyt:extended; var ProjeID:integer; var Aciklama:string;
         var En:extended;var Boy:extended; var Yuzey:extended;var Sayi:extended):Boolean;
var
  FYS:TFiyatSorDlg;
  wrd:word;
begin
  Result:=False;
  if Kur='' then
    Kur:=CariDoviz;
  Application.CreateForm(TFiyatSorDlg,FYS);
  FYS.PanelStokAdi.Caption := Tablo.AciklamaGetir('STOKLAR','STOKADI',StkID);
  FYS.StokId := StkID;
  FYS.UrunTur := UrunTur;
  FYS.EditProje.Tag := ProjeID;
  FYS.EditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU',ProjeID);
  FYS.ComboKDV.PostEditValue;
  FYS.ComboKur.EditValue := Kur;
  FYS.ComboKur.PostEditValue;
  FYS.EditMiktar.EditValue := Adet;
  FYS.EditMiktar.PostEditValue;
  FYS.EditIsk1.EditValue := Isk1;
  FYS.EditIsk1.PostEditValue;
  FYS.EditIsk2.EditValue := Isk2;
  FYS.EditIsk2.PostEditValue;
  FYS.EditKurDegeri.EditValue := KurDegeri;
  FYS.EditKurDegeri.PostEditValue;
  FYS.AKDV := KDV;
  FYS.ComboKDV.EditValue := KDV;
  FYS.EditAciklama.Text := Aciklama;
  if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER) then begin
     FYS.EditEn.Value := En;
     FYS.EditBoy.Value := Boy;
     FYS.EditYuzey.Value := Yuzey;
     FYS.EditSayi.Value := Sayi;
  end;




  if Kur = CariDoviz then begin
    FYS.EditBirimFiyat.EditValue := TLFiyat;
    FYS.EditBirimFiyat.PostEditValue;
    FYS.EditBirimFiyatKeyUp(FYS.EditBirimFiyat,wrd,[]);
    {if FYS.ComboKur.EditValue = CariDoviz then   //TL ise
      FYS.EditDovizBirimFiyat.Value := 0
    else begin
      if FYS.CheckDovizBirimFiyat.checked then
        FYS.EditKurDegeri.Value := FYS.EditBirimFiyat.Value / FYS.EditDovizBirimFiyat.Value
      else
        FYS.EditDovizBirimFiyat.Value := FYS.EditBirimFiyat.Value / FYS.EditKurDegeri.Value;
    end;
    FYS.Hesapla;}
  end else begin
    FYS.EditDovizBirimFiyat.EditValue := DovizFiyat;
    FYS.EditDovizBirimFiyat.PostEditValue;
    FYS.EditDovizBirimFiyatKeyUp(FYS.EditDovizBirimFiyat,wrd,[]);
    {if FYS.CheckKur.checked then
      FYS.EditBirimFiyat.Value := FYS.EditDovizBirimFiyat.Value * FYS.EditKurDegeri.Value
    else
      FYS.EditKurDegeri.Value  := FYS.EditBirimFiyat.Value / FYS.EditDovizBirimFiyat.Value;
    FYS.Hesapla; }
  end;
  //03/08/2022 ao İPTAL EDİLDİ
  if TabKaynak.FieldByName('IZLEME').AsInteger > 0 then
     FYS.PanelMiktar.Enabled := False;


  FYS.ShowModal;
  if (FYS.ModalResult = mrOk) then begin
    if FYS.PanelMiktar.Enabled = False then
       FYS.PanelMiktar.Enabled := True;
    //if Kur = CariDoviz then
    TLFiyat:=FYS.EditBirimFiyat.EditValue;
    //else
    DovizFiyat:=FYS.EditDovizBirimFiyat.EditValue;
    ProjeID := FYS.EditProje.Tag;
    Kur:=FYS.ComboKur.EditValue;
    KDV:=FYS.AKDV;
    Adet:=FYS.EditMiktar.EditValue;
    KDV := FYS.AKDV;
    KurDegeri := FYS.EditKurDegeri.EditValue;
    Isk1 := FYS.EditIsk1.EditValue;
    Isk2 := FYS.EditIsk2.EditValue;
    Aciklama := FYS.EditAciklama.Text;
    if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER)  then begin
      En := FYS.EditEn.Value;
      Boy := FYS.EditBoy.Value;
      Yuzey := FYS.EditYuzey.Value;
      Sayi := FYS.EditSayi.Value;
    end;
    Result := True;
  end;
  FreeAndNil(FYS);
end;

procedure TBelgeDonusumDlg.DonusTipiGuncelle;
begin
  //if DonusumTuru > 0 then
    //exit;

  HedefTablo := 'FATURA';
  case HedefBaslikTur of //Kaynak Türü
    6:begin //Üretim Fişi
        DonusumTuru := TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN;
    end;
    9:begin //Alış Siparişi
      if cbTur.EditValue = 99 then  //28.3.24 AO     9 değerini 99 a dönüştürdüm
        DonusumTuru := TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS
      else if cbTur.EditValue = 101 then
        DonusumTuru := TabNo_DONUSUM_SATINALMATALEP_SIPARIS;
    end;
    10:begin  //alış irsaliyesi
      if cbTur.EditValue = 9 then
        DonusumTuru := TabNo_DONUSUM_ALIS_SIPARIS_IRS
      else if cbTur.EditValue = 109 then
        DonusumTuru := TabNo_DONUSUM_Gelen_Konsinye_Irsaliye
      else
        DonusumTuru := 0;
    end;
    11:begin  //alış faturası
      if cbTur.EditValue = 9 then
        DonusumTuru := TabNo_DONUSUM_ALIS_SIPARIS_FAT
      else if cbTur.EditValue = 10 then
        DonusumTuru := TabNo_DONUSUM_ALIS_IRS_FAT
      else if cbTur.EditValue = 109 then
        DonusumTuru := TabNo_DONUSUM_Gelen_Konsinye_Fatura
      else
        DonusumTuru := 0;
    end;
    12:begin  //alış fişi
      if cbTur.EditValue = 9 then
        DonusumTuru := TabNo_DONUSUM_ALIS_SIPARIS_FIS
      else if cbTur.EditValue = 10 then
        DonusumTuru := TabNo_DONUSUM_ALIS_IRS_FIS
      //else if cbTur.EditValue = 109 then
      //  DonusumTuru := TabNo_DONUSUM_Gelen_Konsinye_Fis
      else
        DonusumTuru := 0;
    end;
    14:begin  //satış irsaliyesi
      if cbTur.EditValue = 19 then
        DonusumTuru := TabNo_DONUSUM_SATIS_SIPARIS_IRS
      else if cbTur.EditValue = 6 then
        DonusumTuru := TabNo_DONUSUM_URETIM_IRSALIYE
      else if cbTur.EditValue = 119 then
        DonusumTuru := TabNo_DONUSUM_Giden_Konsinye_Irsaliye
      else
        DonusumTuru := 0;
    end;
    15:begin  //satış faturası
      case cbTur.EditValue of
      6  : DonusumTuru := TabNo_DONUSUM_URETIM_FATURA;
      14 : DonusumTuru := TabNo_DONUSUM_SATIS_IRS_FAT;
      19 : DonusumTuru := TabNo_DONUSUM_SATIS_SIPARIS_FAT;
      110: DonusumTuru := TabNo_DONUSUM_ADISYON_FATURA;
      119: DonusumTuru := TabNo_DONUSUM_Giden_Konsinye_Fatura;
      else
        DonusumTuru := 0;
      end;
    end;
    16:begin  //satış fişi
      case cbTur.EditValue of
       6  : DonusumTuru := TabNo_DONUSUM_URETIM_FIS;
       14 : DonusumTuru := TabNo_DONUSUM_SATIS_IRS_FIS;
       19 : DonusumTuru := TabNo_DONUSUM_SATIS_SIPARIS_FIS;
       110: DonusumTuru := TabNo_DONUSUM_ADISYON_FIS;
       119: DonusumTuru := TabNo_DONUSUM_Giden_Konsinye_FIS;
      else
        DonusumTuru := 0;
      end;
    end;
    19:begin //Satış Siparişi
      DonusumTuru := TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS;
    end;
    20:begin //Satış Siparişi
      if cbTur.EditValue=105 then
        DonusumTuru := TabNo_DONUSUM_STOKTALEP_TRANSFER;
    end;
    66 : begin
           DonusumTuru := TabNo_SIPARISDETAY;
           HedefTablo := 'URETIMEMRIDETAY';
         end;
    119: if cbTur.EditValue = 19 then
            DonusumTuru := TabNo_DONUSUM_SATIS_SIPARIS_KON
  else
    DonusumTuru := 0;
  end;
end;

procedure TBelgeDonusumDlg.DtsKaynakStateChange(Sender: TObject);
begin
  BtnSec.Enabled := (TabKaynak.State=dsBrowse)and(TabKaynak.Recordcount>0);
end;

procedure TBelgeDonusumDlg.StokDetay1Click(Sender: TObject);
begin
  AnaForm.StokDurumDetayBaslat(TabKaynak.FieldByName('STOKID').AsInteger, TabKaynak.FieldByName('STOKADI').AsString);
end;

procedure TBelgeDonusumDlg.StokEkle;
Var
  TLFiyat, DovizFiyat:Currency;
  AKur,AAciklama:String;
  Kalan : String[20];
  AKDV,i,ReceteID,StkID,UrnTur,PrjID, ID:integer;
  AAdet,AKurDegeri,Miktar,AIsk1,AIsk2,ABrmFiyat, En,Boy,Yuzey,Sayi : extended;
  procedure DegerAta(DovizAlan:String);
    begin
       if TabKaynakBaslik.FieldByName(DovizAlan).AsString=CariDoviz then begin //ilk kez yabancı para birimi varsa onu koyup değerini de atalım
          if TabKaynakBaslik.state=dsBrowse then
             TabKaynakBaslik.edit;
          TabKaynakBaslik.FieldByName(DovizAlan).AsString := AKur;
          if TabKaynakBaslik.state=dsBrowse then
             TabKaynakBaslik.edit;
          TabKaynakBaslik.FieldByName('DOVIZKUR').AsFloat := AKurDegeri;
          case HedefBaslikTur of
            //9,19 : TabGiris.FieldByName('TEKLIF_DOVIZI').AsString := AKur; //sipariş
             100 : TabKaynakBaslik.FieldByName('TEKLIF_DOVIZI').AsString := AKur; //teklif
          end;
       end;
    end;
Begin
  if HedefBaslikTur=66 then begin  //Üretim Emri ise
     SecilenUrunId := TabKaynak.FieldByName('STOKID').AsInteger;
     SecilenSatirId := TabKaynak.FieldByName('SATIRID').AsInteger;
     RehID := TabKaynak.FieldByName('REHBERID').AsInteger;
     SecilenAdet := TabKaynak.FieldByName('KALAN').AsFloat;
     SecilenBelgeNo := TabKaynak.FieldByName('BELGENO').AsString;
     SecilenBelgeTeslimTr := TabKaynak.FieldByName('TESLIMTARIHI').AsDateTime;
     close;
     exit;
  end;

  if HedefBaslikTur=6 then begin  //Üretim Fişi ise
     TabKaynakBaslik.Edit;
     TabKaynakBaslik.FieldByName('REHBERID').AsInteger := TabKaynak.FieldByName('REHBERID').AsInteger;
     TabKaynakBaslik.FieldByName('REHBERILETID').AsInteger := TabKaynak.FieldByName('REHBERILETID').AsInteger;
     TabKaynakBaslik.FieldByname('SENARYO').AsInteger := Tablo.GENINI.ReadInteger(Ops_Uretim_Senaryo, 1);
     TabKaynakBaslik.Post;
  end;

  if (DonusumTuru = TabNo_DONUSUM_STOKTALEP_TRANSFER)and(HedefBaslikTur=20)and(TabKaynakBaslik.FieldByName('ID').AsString='') then begin  //talepten Transfer Fişine  ise
     TabKaynakBaslik.Edit;                                                                                  //  ve üst bilgiler boşsa
     TabKaynakBaslik.FieldByName('GIRISDEPO').AsInteger := TabKaynak.FieldByName('GIRISDEPO').AsInteger;
     TabKaynakBaslik.FieldByName('CIKISDEPO').AsInteger := TabKaynak.FieldByName('CIKISDEPO').AsInteger;
     TabKaynakBaslik.Post;
     HedefBaslikID := TabKaynakBaslik.FieldByName('ID').AsInteger;
  end;


  //önce kaynak belge depo ile hedef belge depolar uyuşuyor mu kontrol edelim..
  Tablo.TablodanSorguAc(1, 'select GIRISDEPO, CIKISDEPO from FATBASLIK where ID='+IntToStr(HedefBaslikID));
  if ((   DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Irsaliye)or(DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Fatura)
      or(DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Fis)or (DonusumTuru = TabNo_DONUSUM_SATIS_IRS_FAT))and
     (TabKaynakBaslik.FieldByName('CIKISDEPO').AsString <> Tablo.Query1.FieldByName('CIKISDEPO').AsString) then begin
     showmessage(DonusumDepoAyniOlmali);
     exit;
  end
  else if ((DonusumTuru = TabNo_DONUSUM_Gelen_Konsinye_Irsaliye)or(DonusumTuru = TabNo_DONUSUM_Gelen_Konsinye_Fatura)or
     (DonusumTuru = TabNo_DONUSUM_ALIS_IRS_FAT)) and
     (TabKaynakBaslik.FieldByName('GIRISDEPO').AsString <> Tablo.Query1.FieldByName('GIRISDEPO').AsString) then begin
     showmessage(DonusumDepoAyniOlmali);
     exit;
  end
  else if (DonusumTuru = TabNo_DONUSUM_STOKTALEP_TRANSFER) and
     (TabKaynakBaslik.FieldByName('CIKISDEPO').AsString <> Tablo.Query1.FieldByName('CIKISDEPO').AsString)and
     (TabKaynakBaslik.FieldByName('GIRISDEPO').AsString <> Tablo.Query1.FieldByName('GIRISDEPO').AsString) then begin
     showmessage(DonusumDepoAyniOlmali);
     exit;
  end;

  //if StrToIntDef(VarToStr(cbTur.EditValue),0) = 99 then
  TLFiyat:=TabKaynak.FieldByName('BIRIMFIYAT').AsCurrency;
  //else
  DovizFiyat:=TabKaynak.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency;

  if StrToIntDef(VarToStr(cbTur.EditValue),0) = 99 then
    AKur:=TabKaynak.FieldByName('KUR').Value
  else
    AKur:=TabKaynak.FieldByName('DOVIZ_KURU').Value;

  AKDV:=TabKaynak.FieldByName('KDV').AsInteger;
  ABrmFiyat:=TabKaynak.FieldByName('BIRIMFIYAT').AsFloat;
  AAdet:=TabKaynak.FieldByName('KALAN').AsFloat;
  AIsk1:=TabKaynak.FieldByName('Iskonto').AsFloat;
  AIsk2:=TabKaynak.FieldByName('Iskonto2').AsFloat;
  AKurDegeri:=TabKaynak.FieldByName('DOVIZKURDEGERI').AsCurrency;
  StkID := TabKaynak.FieldByName('STOKID').AsInteger;
  PrjID := TabKaynak.FieldByName('PROJEID').AsInteger;
  AAciklama := TabKaynak.FieldByName('ACIKLAMA').AsString;
  UrnTur := 1;

  if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER) then begin  // and(TUR in[109,119])
     if TabKaynak.FieldByName('EN').Value<>null then
        En := TabKaynak.FieldByName('EN').Value;
     if TabKaynak.FieldByName('BOY').Value<>null then
        Boy := TabKaynak.FieldByName('BOY').Value;
     if TabKaynak.FieldByName('YUZEY').Value<>null then
        Yuzey := TabKaynak.FieldByName('YUZEY').Value;
     if TabKaynak.FieldByName('SAYI').Value<>null then
        Sayi := TabKaynak.FieldByName('SAYI').Value;
  end else begin
    En:=0;Boy:=0;Yuzey:=0;Sayi:=0;
  end;

  if (DonusumTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN)or(DonusumTuru = TabNo_DONUSUM_STOKTALEP_TRANSFER)
  or (FiyatSor(TLFiyat, DovizFiyat,AKur,AKDV,AAdet,AKurDegeri,AIsk1,AIsk2,StkID,UrnTur,ABrmFiyat,PrjID,AAciklama, En,Boy,Yuzey,Sayi)) then begin
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    Application.CreateForm(TBekletmeDlg, BekletDlg);
    BekletDlg.Show;
    BekletDlg.cxProgressBar1.Position := 0;
    BekletDlg.Caption := TabKaynak.FieldByName('STOKADI').AsString;
    BekletDlg.LabelUstTaraf.Caption := '';
    BekletDlg.LabelUstTaraf.Update;
    i := 0;
    while i < 20 do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      sleep(5);
      inc(i);
    end;
    if TabDetayGiris.Owner.Name='UretimWizardDlg' then begin
      (TabDetayGiris.Owner as TUretimWizardDlg).YeniMiktar := TabKaynak.FieldByName('KALAN').AsFloat;
    end;
    try
      if TabDetayGiris.State in [dsEdit,dsInsert] then
        TabDetayGiris.Post;
    finally
      TabDetayGiris.Append;
    end;
    while i < 60 do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      sleep(5);
      inc(i);
    end;

     if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER) then begin  // and(TUR in[109,119])
        TabDetayGiris.FieldByName('EN').Value := En;
        TabDetayGiris.FieldByName('BOY').Value := Boy;
        TabDetayGiris.FieldByName('YUZEY').Value := Yuzey;
        TabDetayGiris.FieldByName('SAYI').Value := Sayi;
     end;


    TabDetayGiris.FieldByName('TUR').Value := 1; // stok
    TabDetayGiris.FieldByName('URUNID').AsInteger := TabKaynak.FieldByName('STOKID').AsInteger;
    if TabDetayGiris.Owner.Name<>'UretimWizardDlg' then begin
      TabDetayGiris.FieldByName('ADET').AsFloat := AAdet;
      TabDetayGiris.FieldByName('MIKTAR').AsFloat := TabKaynak.FieldByName('MIKTAR').AsFloat*(AAdet/TabKaynak.FieldByName('ADET').AsFloat);
    end;
    if (DonusumTuru=TabNo_DONUSUM_SATINALMATALEP_SIPARIS)or(DonusumTuru=TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS)or(DonusumTuru=TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS) then
        TabDetayGiris.FieldByName('TESLIMTARIHI').AsDatetime := TabKaynak.FieldByName('TESLIMTARIHI').AsDatetime
    else if DonusumTuru=TabNo_DONUSUM_STOKTALEP_TRANSFER then
        TabDetayGiris.FieldByName('BASTAR').AsDatetime := TabKaynak.FieldByName('TESLIMTARIHI').AsDatetime;
    TabDetayGiris.FieldByName('BIRIM').AsInteger := TabKaynak.FieldByName('BIRIM').AsInteger;
    TabDetayGiris.FieldByName('ISKONTO').AsFloat := AIsk1;
    TabDetayGiris.FieldByName('ISKONTO2').AsFloat := AIsk2;
    TabDetayGiris.FieldByName('KDV').AsInteger := AKDV;
    TabDetayGiris.FieldByName('YERI').AsInteger := DonusumTuru;
    TabDetayGiris.FieldByName('YERID').AsInteger := TabKaynak.FieldByName('SATIRID').AsInteger;
    TabDetayGiris.FieldByName('PROJEID').AsInteger := PrjID;
    TabDetayGiris.FieldByName('IZLEME').AsInteger := TabKaynak.FieldByName('IZLEME').AsInteger;
    TabDetayGiris.FieldByName('ACIKLAMA').Value := AAciklama;
    TabDetayGiris.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
    TabDetayGiris.FieldByName('POZNO').Value := TabKaynak.FieldByName('POZNO').Value;
    TabDetayGiris.FieldByName('OZELKOD').Value := TabKaynak.FieldByName('DETAY_OZELKOD').Value;
    TabDetayGiris.FieldByName('OZELKOD2').Value := TabKaynak.FieldByName('DETAY_OZELKOD2').Value;
    TabDetayGiris.FieldByName('MUHKODU').Value := TabKaynak.FieldByName('MUHKODU').Value;
    if DonusumTuru <> TabNo_DONUSUM_STOKTALEP_TRANSFER then begin
      TabDetayGiris.FieldByName('MASRAFID').Value := TabKaynak.FieldByName('MASRAFID').Value;
      TabDetayGiris.FieldByName('MERKEZID').Value := TabKaynak.FieldByName('MERKEZID').Value;
      TabDetayGiris.FieldByName('KAMPANYAID').Value := TabKaynak.FieldByName('KAMPANYAID').Value;
    end;

    if AKur<>CariDoviz then
       TabDetayGiris.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency := DovizFiyat
    else
       TabDetayGiris.FieldByName('DOVIZ_BIRIMFIYAT').AsCurrency := TLFiyat;
    TabDetayGiris.FieldByName('DOVIZ_KURU').Value := AKur;

    if (not DovizTakibi)or(AKurDegeri=0.0) then
       AKurDegeri:= 1.0;
    TabDetayGiris.FieldByName('DOVIZKURDEGERI').AsCurrency := AKurDegeri;
    TabDetayGiris.FieldByName('KUR').Value := CariDoviz;
    TabDetayGiris.FieldByName('BIRIMFIYAT').AsCurrency := TLFiyat;//AFiyat * AKurDegeri;

    if StrToIntDef(VarToStr(cbTur.EditValue),0) in[99,101] then
      //tekliften siparişe geçişte stok durum yok..
    else if StrToIntDef(VarToStr(cbTur.EditValue),0) in[6,9,19,105,109,119] then
      TabDetayGiris.FieldByName('STOKDURUMDEGIS').AsBoolean := True
    else
      TabDetayGiris.FieldByName('STOKDURUMDEGIS').AsBoolean := False;

    while i < 80 do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      sleep(5);
      inc(i);
    end;
    try
      (*if ((TabDetayGiris.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Giden_Konsinye_Fatura)or(TabDetayGiris.FieldByName('YERI').AsInteger = TabNo_DONUSUM_Gelen_Konsinye_Fatura))and(TabDetayGiris.FieldByName('IZLEME').AsInteger>0) then begin//pasif izleme bilgileri sorulacak
        Miktar := TabDetayGiris.FieldByName('MIKTAR').AsFloat;
        if not Anaform.StokIzleme(IzlemDlg,TabDetayGiris.FieldByName('URUNID').AsInteger,TabDetayGiris.FieldByName('IZLEME').AsInteger,HedefBaslikTur,1,HedefBaslikID,0,
               RehId,Miktar,Miktar,'',TabKaynak.FieldByName('BASLIKID').AsInteger, TabKaynak.FieldByName('SATIRID').AsInteger ) then begin
          FreeAndNil(IzlemDlg);
          TabDetayGiris.Cancel;
          Abort;
        end;
      end;  8/1/019 AO *)
      TabDetayGiris.Post;
      //27.10.2023 AO
      if HedefBaslikTur in [9,10,11,12,14,15,16,19] then //irsaliye fe faturalar için
         DegerAta('RAPORDOVIZ')
     // else if stokhizmetaracagirantur = 100 then //TEKLİFSE
     //  DegerAta('DOVIZ_KURU')
      else
         DegerAta('DOVIZ_CINSI');

      //
      if (DonusumTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN)and(TabDetayGiris.Owner.Name='UretimWizardDlg') then begin
        ReceteID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select isnull((select ID from URETIMRECETE where STOKID='+TabDetayGiris.FieldByName('URUNID').AsString+'),0)',[],[],True);
        if ReceteID>0 then
          (TabDetayGiris.Owner as TUretimWizardDlg).RecetedenEkle(ReceteID,TabDetayGiris.FieldByName('MIKTAR').AsFloat,False);
      end;

      if IzlemDlg<>nil then begin
        IzlemDlg.SatirID := TabDetayGiris.FieldByName('ID').AsInteger;
        FreeAndNil(IzlemDlg);
      end;
    finally
      while i < 100 do begin
        BekletDlg.cxProgressBar1.Position := i;
        BekletDlg.cxProgressBar1.Refresh;
        sleep(5);
        inc(i);
      end;
      if BekletDlg <> nil then
         FreeAndNil(BekletDlg);
    end;
    //01/04/2022 AO   izlenen satırsa aynen devam eder
    i:=cbTur.EditValue;
    if (TabDetayGiris.FieldByName('IZLEME').AsInteger > 0)and(i in [10,11,14,15,119] ) then begin
       Tablo.TablodanSorguAc(9,'select ID, KALAN from STOKIZLEME where SATIRID='+TabKaynak.FieldByName('SATIRID').AsString+'  AND KALAN>0 ');
       while not Tablo.Query9.Eof  do begin
         ID := Tablo.SQLSatiriKopyala('STOKIZLEME', Tablo.Query9.Fields[0].AsInteger,[ 'BELGETUR', 'BASLIKID','SATIRID', 'EKLEYEN', 'DONUSID', 'ADET'],
                  [ HedefBaslikTur, HedefBaslikID, TabDetayGiris.FieldByName('ID').AsInteger, Kullanan, Tablo.Query9.Fields[0].AsString, Tablo.Query9.FieldByName('KALAN').AsInteger ]);
         if (DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Irsaliye)or(DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Fatura) or
            (DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Fis) or (DonusumTuru = TabNo_DONUSUM_SATIS_IRS_FAT) then begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEME set KALAN = 0 where ID = '+Tablo.Query9.Fields[0].AsString, [], []);
            //
            if DonusumTuru = TabNo_DONUSUM_SATIS_IRS_FAT then   //08/11/2022 AO satış irsaliyesinden faturaya dönüş ise stok izlemdepoya atmamalı
               Kalan := '0.0'
            else
               Kalan := stringreplace(FloatToStr(-1 * Tablo.Query9.FieldByName('KALAN').AsFloat),',','.',[]);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) values('+
                      IntToStr(Id)+','+IntToStr(CDepo)+','+Kalan+')', [], []);


         end;


         Tablo.Query9.next;
       end;
       // TabKaynak.FieldByName('SATIRID').AsInteger
    end;

  end;
End;

procedure TBelgeDonusumDlg.AramaYap;
var
  locateID:integer;
  DonusumStr : string[20];
  function BarkodOku(OkunanBarkod : string): string;
  begin
     OkunanBarkod := Trim(OkunanBarkod);
     if (pos('01', OkunanBarkod)=1)and(pos('17', OkunanBarkod)=17) then //Karekod 01 ile başlayıp 14 karakter stokkodu
         OkunanBarkod := copy(OkunanBarkod,3,14)
     else if (pos('(01)', OkunanBarkod)>0) then //Karekod Ör : (10) BL005222511       (01) 8681489704423
         OkunanBarkod := Tablo.KarekodOku(1, OkunanBarkod)
     else
         OkunanBarkod :=  OkunanBarkod;  //yoksa kendisi
     Result := OkunanBarkod;
  end;
begin
  JvTimer1.Enabled := False;
  DonusTipiGuncelle;
  if (TabKaynak.Active)and(TabKaynak.RecordCount>0) then
    locateID := TabKaynak.FieldByName('SATIRID').AsInteger;
  if DonusumTuru<>0 then begin
    if StrToIntDef(VarToStr(cbTur.EditValue),0) = 99 then begin //alış siparişi , satış siparişi
      // verilen sipariş HedefBaslikTur(9) için tüm carilerin kayıtları gelmeli!!
      TabKaynak.SQL.Text := 'select BASLIKID=S.ID,SATIRID=SD.ID,STOKID=ST.ID,REHBERID=R.ID, R.FIRMA,S.TARIH,BELGENO=S.TEKLIFNO,ST.KOD,ST.STOKADI,ST.ANABIRIM,SD.ACIKLAMA,ST.IZLEME,ST.OZELKOD,ST.OZELKOD2, ST.MUHKODU,SD.KDV,SD.KUR,SD.DOVIZ_KURU,';
      TabKaynak.SQL.Add(' SD.ADET,SD.MIKTAR,SD.BIRIM,SD.BIRIMFIYAT,SD.ISKONTO,SD.ISKONTO2,SD.TUTAR,SD.DOVIZ_BIRIMFIYAT,SD.DOVIZ_KURU,SD.DOVIZKURDEGERI,SD.DOVIZ_TUTARI,SD.MASRAFID,SD.MERKEZID,SD.KAMPANYAID,');
      TabKaynak.SQL.Add(' DONUSEN=isnull((select sum(F1.ADET) from SIPARISDETAY F1  where F1.YERI=428 and F1.YERID=SD.ID ),0.0),');
      TabKaynak.SQL.Add(' IADE=0.0,');
      TabKaynak.SQL.Add(' KALAN=ADET-isnull((select sum(F1.ADET) from SIPARISDETAY F1 where F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0)');
      TabKaynak.SQL.Add(' -isnull((select sum(F1.ADET) from SIPARISDETAY F1 where F1.YERI=416 and F1.YERID=SD.ID ),0.0)');//İADE ÇIKARILIR
      TabKaynak.SQL.Add(' ,SD.TESLIMTARIHI ');
      TabKaynak.SQL.Add(' ,SATICI=S.HAZIRLAYAN ');
      TabKaynak.SQL.Add(' ,SD.PROJEID, SD.POZNO, ST.URUNNO ');
      TabKaynak.SQL.Add(' ,DETAY_OZELKOD = SD.OZELKOD, DETAY_OZELKOD2 = SD.OZELKOD2 ');
      TabKaynak.SQL.Add(' ,PROJEKODU=(Select '+DbUst(1)+'P.PROJEKODU from PROJELER P Where P.ID=SD.PROJEID '+DbSinir(1)+') ');
      TabKaynak.SQL.Add(' ,GIZLE= case when exists(select ID from DONUSUMBILGISIGIZLE where KAYNAKTUR=99 and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID=SD.ID) then 1 else 0 end ');
      if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER)  then
         TabKaynak.SQL.Add(',SD.EN,SD.BOY,SD.YUZEY,SD.SAYI, SD.POZNO, SD.ACIKLAMA');
      TabKaynak.SQL.Add(' from TEKLIF S inner join TEKLIFDETAY SD on S.ID=SD.TEKLIFID inner join');
      TabKaynak.SQL.Add(' STOKLAR ST on SD.TUR=1 and SD.URUNID=ST.ID inner join REHBER R on R.ID=S.REHBERID');
      // 20-09-2023 AO  S.ONAYLAYAN>0 and   onaylayan kaldırıldı
      TabKaynak.SQL.Add(' where  S.TARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', DtBas.Date)+''' ');
      TabKaynak.SQL.Add(' and S.TARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59', DtBit.Date)+''' ');
      if VarToStrDef(cbTur.EditValue,'0')<>'99' then
        TabKaynak.SQL.Add(' and S.TUR='+VarToStrDef(cbTur.EditValue,'0'));
      if (RehID>0) and (HedefBaslikTur<>9) then
        TabKaynak.SQL.Add(' and R.ID='+IntToStr(RehID));
      if VarToStrDef(EdBelgeNo.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and S.TEKLIFNONO like ''%'+VarToStr(EdBelgeNo.EditValue)+'%'' ');
      if VarToStrDef(edStokKod.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.KOD like ''%'+VarToStr(edStokKod.EditValue)+'%'' ');
      if VarToStrDef(edUrunNo.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.URUNNO like ''%'+VarToStr(edUrunNo.EditValue)+'%'' ');
      if VarToStrDef(edStokAd.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.STOKADI like ''%'+VarToStr(edStokAd.EditValue)+'%'' ');
      if VarToStrDef(edBarkod.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.ID in( select STOKID from STOKBARKOD where BARKOD like ''%'+BarkodOku(VarToStr(edBarkod.EditValue))+'%'' )');
      if checkKalmayanGoster.Checked <> True then
        TabKaynak.SQL.Add(' and SD.ADET > isnull((select sum(F1.ADET) from SIPARISDETAY F1 where F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0)');
      if checkGizlenenGoster.Checked <> True then
        TabKaynak.SQL.Add(' and not exists (select ID from DONUSUMBILGISIGIZLE where KAYNAKTUR=99 and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID=SD.ID) ');
      (*if PanelDetayliAra.Visible then begin
        if GrpSerino.Visible then begin //serino=1
          TabKaynak.SQL.Add(' and ST.IZLEME = 1 ');
          if EditSerino.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+EditSerino.Text+'%'') ');
        end else if GrpSKT.Visible then begin //skt=2
          TabKaynak.SQL.Add(' and ST.IZLEME = 2 ');
          if DateSKT.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.SKT = '''+FormatDateTime('yyyy-mm-dd',DateSKT.Date)+'''+'' 00:00'') ');
          if EditAciklama.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.ACIKLAMA like ''%'+EditAciklama.Text+'%'') ');
        end else if GrpKarekod.Visible then begin //karekod=3
          TabKaynak.SQL.Add(' and ST.IZLEME = 3 ');
          if EditKarekod.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+EditKarekod.Text+'%'') ');
        end else if GrpBoyut.Visible then begin //boyut=4
          TabKaynak.SQL.Add(' and ST.IZLEME = 4 ');
          if cbBoyutKombinasyon.Text <> '' then begin
            if EditKarekod.Text <> '' then
              TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+cbBoyut1.Text+'%'+cbBoyut2.Text+'%'+cbBoyut3.Text+'%'') ');
          end;
        end;
      end; *)
      TabloYenile(TabKaynak,[],locateID,'SATIRID');
    end else if StrToIntDef(VarToStr(cbTur.EditValue),0) in[9,19,101,105] then begin //alış siparişi , satış siparişi
      TabKaynak.SQL.Text := 'select BASLIKID=S.ID,SATIRID=SD.ID,STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,TARIH=S.SIPARISTARIH,BELGENO=S.SIPARISNO,ST.KOD,ST.STOKADI,ST.ANABIRIM,SD.ACIKLAMA,ST.IZLEME,ST.OZELKOD,ST.OZELKOD2,ST.MUHKODU,SD.KDV,SD.KUR,SD.DOVIZ_KURU,';
      TabKaynak.SQL.Add(' SD.ADET,SD.MIKTAR,SD.BIRIM,SD.BIRIMFIYAT,SD.ISKONTO,SD.ISKONTO2,SD.TUTAR,SD.DOVIZ_BIRIMFIYAT,SD.DOVIZ_KURU,SD.DOVIZKURDEGERI,SD.DOVIZ_TUTARI,SD.MASRAFID,SD.MERKEZID,SD.KAMPANYAID,');
      TabKaynak.SQL.Add(' DONUSEN=isnull((select sum(F1.ADET) from SIPARISDETAY F1 where F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0) ' +
                        '        + isnull((select sum(F1.ADET) from '+HedefTablo+' F1 where F1.URUNID=SD.URUNID and F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0),');
      TabKaynak.SQL.Add(' IADE=0.0,');
      TabKaynak.SQL.Add(' KALAN=ADET-(ABS(isnull((select sum(F1.ADET) from SIPARISDETAY F1 where F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0)) ' +
                        ' + ABS(isnull((select sum(F1.ADET) from '+HedefTablo+' F1 where F1.URUNID=SD.URUNID and F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0)))');
      TabKaynak.SQL.Add(' ,SD.TESLIMTARIHI, S.REHBERILETID, SEVK = (SELECT AD FROM  REHBERILETISIM WHERE ID=S.REHBERILETID) ');
      TabKaynak.SQL.Add(' ,SATICI=S.SATICIKODU,  DEPOAD = (select DEPOADI from DEPOLAR where ID= case when S.TUR = 19 then S.CIKISDEPO else S.GIRISDEPO end ) ');
      TabKaynak.SQL.Add(' ,SD.PROJEID, SD.POZNO, ST.URUNNO, S.DETAYBOLUMU ');
      TabKaynak.SQL.Add(' ,PROJEKODU=(Select '+DbUst(1)+'P.PROJEKODU from PROJELER P Where P.ID=SD.PROJEID '+DbSinir(1)+') ');
      TabKaynak.SQL.Add(' ,GIZLE= case when exists(select ID from DONUSUMBILGISIGIZLE where KAYNAKTUR=S.TUR and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID=SD.ID) then 1 else 0 end ');
      TabKaynak.SQL.Add(' ,DETAY_OZELKOD = SD.OZELKOD, DETAY_OZELKOD2 = SD.OZELKOD2 ');
      if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER)  then
         TabKaynak.SQL.Add(',SD.EN,SD.BOY,SD.YUZEY,SD.SAYI,SD.POZNO, SD.ACIKLAMA');
      TabKaynak.SQL.Add(' from SIPARIS S inner join SIPARISDETAY SD on S.ID=SD.SIPARISID inner join');
      TabKaynak.SQL.Add(' STOKLAR ST on SD.TUR=1 and SD.URUNID=ST.ID inner join REHBER R on R.ID=S.REHBERID');
      TabKaynak.SQL.Add(' where S.SIPARISTARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', DtBas.Date)+''' ');
      TabKaynak.SQL.Add(' and S.SIPARISTARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59', DtBit.Date)+''' ');
      if (RehID<>0)and(StrToIntDef(VarToStr(cbTur.EditValue),0) <> 101) then
        TabKaynak.SQL.Add(' and R.ID='+IntToStr(RehID));
      TabKaynak.SQL.Add(' and S.TUR='+VarToStrDef(cbTur.EditValue,'0'));
      if VarToStrDef(EdBelgeNo.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and S.SIPARISNO like ''%'+VarToStr(EdBelgeNo.EditValue)+'%'' ');
      if VarToStrDef(edStokKod.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.KOD like ''%'+VarToStr(edStokKod.EditValue)+'%'' ');
      if VarToStrDef(edUrunNo.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.URUNNO like ''%'+VarToStr(edUrunNo.EditValue)+'%'' ');
      if VarToStrDef(edStokAd.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.STOKADI like ''%'+VarToStr(edStokAd.EditValue)+'%'' ');
      if VarToStrDef(edBarkod.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.ID in( select STOKID from STOKBARKOD where BARKOD like ''%'+BarkodOku(VarToStr(edBarkod.EditValue))+'%'' )');

      if checkKalmayanGoster.Checked <> True then begin
         if HedefBaslikTur=66 then   //Üretim Emri ise
            TabKaynak.SQL.Add(' and SD.ADET > ABS(isnull((select sum(S1.ADET) from SIPARISDETAY S1 where S1.YERI='+IntToStr(DonusumTuru)+' and S1.YERID=SD.ID ),0.0)) + ABS(isnull((select sum(F1.ADET) from URETIMEMRIDETAY F1 where F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0))')
         else
            TabKaynak.SQL.Add(' and SD.ADET > ABS(isnull((select sum(S1.ADET) from SIPARISDETAY S1 where S1.YERI='+IntToStr(DonusumTuru)+' and S1.YERID=SD.ID ),0.0)) + ABS(isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI='+IntToStr(DonusumTuru)+' and F1.YERID=SD.ID ),0.0))');
      end;
      if checkGizlenenGoster.Checked <> True then
        TabKaynak.SQL.Add(' and not exists (select ID from DONUSUMBILGISIGIZLE where KAYNAKTUR=S.TUR and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID=SD.ID) ');
      if PanelDetayliAra.Visible then begin
        if GrpSerino.Visible then begin //serino=1
          TabKaynak.SQL.Add(' and ST.IZLEME = 1 ');
          if EditSerino.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+EditSerino.Text+'%'') ');
        end else if GrpSKT.Visible then begin //skt=2
          TabKaynak.SQL.Add(' and ST.IZLEME = 2 ');
          if DateSKT.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.SKT = '''+FormatDateTime('yyyy-mm-dd',DateSKT.Date)+'''+'' 00:00'') ');
          if EditAciklama.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.ACIKLAMA like ''%'+EditAciklama.Text+'%'') ');
        end else if GrpKarekod.Visible then begin //karekod=3
          TabKaynak.SQL.Add(' and ST.IZLEME = 3 ');
          if EditKarekod.Text <> '' then
            TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+EditKarekod.Text+'%'') ');
        end else if GrpBoyut.Visible then begin //boyut=4
          TabKaynak.SQL.Add(' and ST.IZLEME = 4 ');
          if cbBoyutKombinasyon.Text <> '' then begin
            if EditKarekod.Text <> '' then
              TabKaynak.SQL.Add(' and SD.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+cbBoyut1.Text+'%'+cbBoyut2.Text+'%'+cbBoyut3.Text+'%'') ');
          end;
        end;
      end;
      TabloYenile(TabKaynak,[],locateID,'SATIRID');
    end else if StrToIntDef(VarToStr(cbTur.EditValue),0) in[6,10,14,109,110,119] then begin  //alış irsaliyesi,satış irsaliyesi,giden konsinye,adisyon,gelen konsinye
      if DonusumTuru = 411 then
         DonusumStr := ' in (411,424) '
      else
         DonusumStr := ' = '+IntToStr(DonusumTuru);
      TabKaynak.SQL.Text := 'select BASLIKID=FB.ID,SATIRID=F.ID,STOKID=ST.ID,REHBERID=R.ID,R.FIRMA,TARIH=FB.FATURATARIH,BELGENO=FB.FATURANO,ST.KOD,ST.STOKADI,ST.ANABIRIM,F.ACIKLAMA,ST.IZLEME,ST.OZELKOD,ST.OZELKOD2,ST.MUHKODU,F.KDV,F.KUR,F.DOVIZ_KURU,';
      TabKaynak.SQL.Add(' F.ADET,F.MIKTAR,F.BIRIM,F.BIRIMFIYAT,F.ISKONTO,F.ISKONTO2,F.TUTAR,F.DOVIZ_BIRIMFIYAT,F.DOVIZ_KURU,F.DOVIZKURDEGERI,F.DOVIZ_TUTARI,F.MASRAFID,F.MERKEZID,F.KAMPANYAID,');
      TabKaynak.SQL.Add(' DONUSEN=isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI '+DonusumStr+' and F1.YERID=F.ID ),0.0),');
      TabKaynak.SQL.Add(' IADE=isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI=416 and F1.YERID=F.ID ),0.0),');
      TabKaynak.SQL.Add(' KALAN=ADET-isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI '+DonusumStr+' and F1.YERID=F.ID ),0.0)');
      TabKaynak.SQL.Add(' -isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI=416 and F1.YERID=F.ID ),0.0)');//İADE ÇIKARILIR
      TabKaynak.SQL.Add(' ,TESLIMTARIHI=FB.FATURATARIH ');
      TabKaynak.SQL.Add(' ,SATICI=FB.SATICIKODU,  DEPOAD = (select DEPOADI from DEPOLAR where ID= case when FB.TUR in (10,11,12, 119) then FB.GIRISDEPO else FB.CIKISDEPO end ) ');
      TabKaynak.SQL.Add(' ,F.PROJEID, F.POZNO, ST.URUNNO, FB.DETAYBOLUMU ');
      TabKaynak.SQL.Add(' ,PROJEKODU=(Select '+DbUst(1)+'P.PROJEKODU from PROJELER P Where P.ID=F.PROJEID '+DbSinir(1)+') ');
      TabKaynak.SQL.Add(' ,GIZLE= case when exists(select ID from DONUSUMBILGISIGIZLE where KAYNAKTUR=FB.TUR and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID=F.ID) then 1 else 0 end ');
      TabKaynak.SQL.Add(' ,DETAY_OZELKOD=F.OZELKOD, DETAY_OZELKOD2=F.OZELKOD2 ');
      if (EnBoyHesaplamaAktif)and(DonusumTuru<>TabNo_DONUSUM_STOKTALEP_TRANSFER)  then
         TabKaynak.SQL.Add(',F.EN,F.BOY,F.YUZEY,F.SAYI, F.POZNO, F.ACIKLAMA');
      TabKaynak.SQL.Add(' from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID inner join');
      TabKaynak.SQL.Add(' STOKLAR ST on F.TUR=1 and F.URUNID=ST.ID inner join REHBER R on R.ID=FB.REHBERID');
      TabKaynak.SQL.Add(' where FB.FATURATARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', DtBas.Date)+''' ');
      TabKaynak.SQL.Add(' and FB.FATURATARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59', DtBit.Date)+''' ');
      if RehID<>0 then
        TabKaynak.SQL.Add(' and R.ID='+IntToStr(RehID));
      TabKaynak.SQL.Add(' and FB.TUR='+VarToStrDef(cbTur.EditValue,'0'));
      if VarToStrDef(EdBelgeNo.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and FB.FATURANO like ''%'+VarToStr(EdBelgeNo.EditValue)+'%'' ');
      if VarToStrDef(edStokKod.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.KOD like ''%'+VarToStr(edStokKod.EditValue)+'%'' ');
      if VarToStrDef(edUrunNo.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.URUNNO like ''%'+VarToStr(edUrunNo.EditValue)+'%'' ');
      if VarToStrDef(edStokAd.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.STOKADI like ''%'+VarToStr(edStokAd.EditValue)+'%'' ');
      if VarToStrDef(edBarkod.EditValue,'') <> '' then
        TabKaynak.SQL.Add(' and ST.ID in( select STOKID from STOKBARKOD where BARKOD like ''%'+BarkodOku(VarToStr(edBarkod.EditValue))+'%'' )');
      if checkKalmayanGoster.Checked <> True then
        TabKaynak.SQL.Add(' and ADET > isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI '+DonusumStr+' and F1.YERID=F.ID ),0.0)');
      if checkGizlenenGoster.Checked <> True then
        TabKaynak.SQL.Add(' and not exists (select ID from DONUSUMBILGISIGIZLE where KAYNAKTUR=FB.TUR and HEDEFTUR='+IntToStr(HedefBaslikTur)+' and KAYNAKID=F.ID) ');
      if PanelDetayliAra.Visible then begin
        if GrpSerino.Visible then begin //serino=1
          TabKaynak.SQL.Add(' and ST.IZLEME = 1 ');
          if EditSerino.Text <> '' then
            TabKaynak.SQL.Add(' and F.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+EditSerino.Text+'%'') ');
        end else if GrpSKT.Visible then begin //skt=2
          TabKaynak.SQL.Add(' and ST.IZLEME = 2 ');
          if DateSKT.Text <> '' then
            TabKaynak.SQL.Add(' and F.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.SKT = '''+FormatDateTime('yyyy-mm-dd',DateSKT.Date)+'''+'' 00:00'') ');
          if EditAciklama.Text <> '' then
            TabKaynak.SQL.Add(' and F.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.ACIKLAMA like ''%'+EditAciklama.Text+'%'') ');
        end else if GrpKarekod.Visible then begin //karekod=3
          TabKaynak.SQL.Add(' and ST.IZLEME = 3 ');
          if EditKarekod.Text <> '' then
            TabKaynak.SQL.Add(' and F.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+EditKarekod.Text+'%'') ');
        end else if GrpBoyut.Visible then begin //boyut=4
          TabKaynak.SQL.Add(' and ST.IZLEME = 4 ');
          if cbBoyutKombinasyon.Text <> '' then begin
            if EditKarekod.Text <> '' then
              TabKaynak.SQL.Add(' and F.ID in(select SI.SATIRID from STOKIZLEME SI where SI.BELGETUR='+VarToStr(cbTur.EditValue)+' and SI.IZLEM like ''%'+cbBoyut1.Text+'%'+cbBoyut2.Text+'%'+cbBoyut3.Text+'%'') ');
          end;
        end;
      end;
      TabloYenile(TabKaynak,[],locateID,'SATIRID');
    end else
      TabKaynak.Close;
  end;
end;

end.



