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
    cxGridKaynakDBTableView1BASLIK_OZELKOD: TcxGridDBColumn;
    cxGridKaynakDBTableView1BASLIK_OZELKOD2: TcxGridDBColumn;
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
  HedefTablo   : String[30];

implementation

uses
   System.JSON, FetaKurulusSiniflari, FetaClassExtensions, UUretimWizard, UAnaForm, PrjConst, UVeriMotor;

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
  // 03/08/2022'de izlemeli urunlerde miktar kilitlenmisti: eski akis kaynagin
  //   TUM kalanini tasiyor, hangi seri/lottan ne kadar gittigi takip
  //   edilemiyordu. Artik her tasinan izlem satiri DONUSID ile kaynagina bagli
  //   ve sp_Prog_Izleme_Aktar_Json "istenenAdet" kadar FIFO tasiyor; kaynagin
  //   KALAN'ini TG_IzlemOrjinalYap dusuruyor. Kilide gerek kalmadi. (08.08.2026)
  //   Eski hali:
  //   if TabKaynak.FieldByName('IZLEME').AsInteger > 0 then
  //      FYS.PanelMiktar.Enabled := False;


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

    // ============================================================
    // KAYNAK SIPARIS + IZLEMLI URUN  -> DEPODAN SECIM   (plan A5)
    //
    // SIPARIS stok hareketi yapmaz, STOKIZLEME kaydi YOKTUR - tasinacak bir
    //   sey de yoktur. Lotlar DEPODAKI BAKIYEDEN secilir. Bu dal bugune kadar
    //   HIC yoktu: izlemli urun iceren siparis irsaliyeye donusturuldugunde
    //   seri/lot hic sorulmuyor, belge izlemsiz olusuyordu (siparis 23202).
    //
    // Ekran YALNIZ SECIM kipinde ve KaynakSatirID VERILMEDEN acilir; boylece
    //   UIzleme'nin "depodan cikis" dali (SQLCikan) calisir. Yazmayi SP yapar.
    // ============================================================
    //   Yalniz stok hareketi yapan hedeflerde: siparisten siparise/teklife
    //   donusumde (hedef SIPARISDETAY) izlem kavrami yoktur.
    if (TabDetayGiris.FieldByName('IZLEME').AsInteger > 0)
       and (i in [9, 19, 101, 105, 109])
       and (HedefBaslikTur in [10, 11, 12, 14, 15, 16, 119]) then begin
       var LDepoSec: TIzlemeDlg := nil;
       var LDepoJson: TJSONObject := TJSONObject.Create;
       try
         try
           Application.CreateForm(TIzlemeDlg, LDepoSec);
           LDepoSec.YalnizSecim    := True;
           LDepoSec.StokID         := TabDetayGiris.FieldByName('URUNID').AsInteger;
           LDepoSec.IzlemTur       := TabDetayGiris.FieldByName('IZLEME').AsInteger;
           LDepoSec.IslemTur       := HedefBaslikTur;
           LDepoSec.IslemTip       := 1;
           LDepoSec.BaslikID       := HedefBaslikID;
           LDepoSec.SatirID        := TabDetayGiris.FieldByName('ID').AsInteger;
           LDepoSec.KaynakBaslikID := 0;   // kaynakta izlem kaydi YOK -> depodan
           LDepoSec.KaynakSatirID  := 0;
           LDepoSec.GirDepo        := CDepo;
           LDepoSec.CikDepo        := CDepo;
           LDepoSec.GerekliMiktar  := TabDetayGiris.FieldByName('ADET').AsFloat;
           LDepoSec.KALAN          := TabDetayGiris.FieldByName('ADET').AsFloat;
           LDepoSec.StokDurumDegis := True;   // siparisten cikis: stok GERCEKTEN duser
           LDepoSec.RehberId       := RehID;
           LDepoSec.ShowModal;
           if (LDepoSec.ModalResult <> mrOk) or (Trim(LDepoSec.SecimJson) = '') then begin
             TabDetayGiris.Delete;
             Abort;
           end;
           // kaynak.satirId GONDERILMEZ -> SP depodan kipe gecer, DONUSID=0
           LDepoJson.AddPair('hedef', TJSONObject.Create
             .AddPair('tur',      TJSONNumber.Create(HedefBaslikTur))
             .AddPair('baslikId', TJSONNumber.Create(HedefBaslikID))
             .AddPair('satirId',  TJSONNumber.Create(TabDetayGiris.FieldByName('ID').AsInteger)));
           LDepoJson.AddPair('depoId',       TJSONNumber.Create(CDepo));
           LDepoJson.AddPair('stokHareketi', TJSONBool.Create(True));
           LDepoJson.AddPair('kullaniciId',  TJSONNumber.Create(StrToIntDef(Trim(Kullanan), 0)));
           LDepoJson.AddPair('secim',
             TJSONObject.ParseJSONValue(LDepoSec.SecimJson) as TJSONArray);
         finally
           FreeAndNil(LDepoSec);
         end;
       except
         LDepoJson.Free;
         raise;
       end;
       Tablo.ApiCagir('sp_Prog_Izleme_Aktar_Json', LDepoJson);
    end
    else if (TabDetayGiris.FieldByName('IZLEME').AsInteger > 0)and(i in [10,11,14,15,119] ) then begin
       // ============================================================
       // SERI/LOT TASIMA - KANONIK SP  (A4)
       //   dbo.sp_Prog_Izleme_Aktar_Json
       //
       // Onceki hali: kaynak izlem kayitlari SQLSatiriKopyala ile satir satir
       //   kopyalaniyor, STOKIZLEMEDEPO elle insert ediliyor ve kaynaga
       //   "update STOKIZLEME set KALAN = 0" yaziliyordu.
       //   O UPDATE HATALIYDI: TG_IzlemOrjinalYap yeni satirin DONUSID'sine
       //   bakip kaynagin KALAN'ini ZATEN dogru dusuruyor (testle dogrulandi:
       //   kalan 2, 1 adet tasima -> 1). Ustune sifir yazmak KISMI tasimada
       //   kalani yok ediyordu. Yeni SP kalana elle DOKUNMAZ.
       //
       // stokHareketi=False -> STOKIZLEMEDEPO satiri ADET=0 ile acilir
       //   (K-B karari; eski koddaki "satis irsaliyesinden faturaya donuste
       //    stok izlem depoya atmamali" dali bunun karsiligi).
       // ============================================================
       var LStokHar: Boolean := (DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Irsaliye) or
                                (DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Fatura) or
                                (DonusumTuru = TabNo_DONUSUM_Giden_Konsinye_Fis);
       // Satis irsaliyesi -> fatura: stoktan zaten irsaliyeyle cikilmis,
       //   depo hareketi YAPILMAZ (satir ADET=0 ile acilir).
       var LIzlemJson: TJSONObject := TJSONObject.Create;
       LIzlemJson.AddPair('kaynak', TJSONObject.Create
         .AddPair('satirId', TJSONNumber.Create(TabKaynak.FieldByName('SATIRID').AsInteger)));
       LIzlemJson.AddPair('hedef', TJSONObject.Create
         .AddPair('tur',      TJSONNumber.Create(HedefBaslikTur))
         .AddPair('baslikId', TJSONNumber.Create(HedefBaslikID))
         .AddPair('satirId',  TJSONNumber.Create(TabDetayGiris.FieldByName('ID').AsInteger)));
       LIzlemJson.AddPair('depoId',       TJSONNumber.Create(CDepo));
       LIzlemJson.AddPair('stokHareketi', TJSONBool.Create(LStokHar));
       // KISMI DONUSUM: yalniz bu satira secilen adet kadar seri/lot tasinir.
       //   Gonderilmezse SP kaynagin tum kalanini tasir - adet dusurulmusse
       //   izlem ile satir adedi tutmazdi.
       LIzlemJson.AddPair('istenenAdet',
         TJSONNumber.Create(TabDetayGiris.FieldByName('ADET').AsFloat));
       LIzlemJson.AddPair('kullaniciId',  TJSONNumber.Create(StrToIntDef(Trim(Kullanan), 0)));

       // ---- KISMI ADET: hangi seri/lottan alinacagini KULLANICI secer ----
       //   Adet birebir tam alinmissa secime gerek yok - kaynakta ne varsa
       //   hepsi gider (eski davranis, ek tiklama yok).
       //   Adet dusurulmusse ekran YALNIZ SECIM kipinde acilir: hicbir sey
       //   yazmaz, isaretlenenleri secim[] olarak dondurur; yazmayi SP yapar.
       //   Vazgecilirse satir donusturulmez.
       if TabDetayGiris.FieldByName('ADET').AsFloat <
          TabKaynak.FieldByName('ADET').AsFloat - 0.0001 then
       begin
         var LKalanMik: real := TabDetayGiris.FieldByName('ADET').AsFloat;
         var LSecDlg: TIzlemeDlg := nil;
         try
           Application.CreateForm(TIzlemeDlg, LSecDlg);
           LSecDlg.YalnizSecim     := True;
           LSecDlg.StokID          := TabDetayGiris.FieldByName('URUNID').AsInteger;
           LSecDlg.IzlemTur        := TabDetayGiris.FieldByName('IZLEME').AsInteger;
           LSecDlg.IslemTur        := HedefBaslikTur;
           LSecDlg.IslemTip        := 1;
           LSecDlg.BaslikID        := HedefBaslikID;
           LSecDlg.SatirID         := TabDetayGiris.FieldByName('ID').AsInteger;
           LSecDlg.KaynakBaslikID  := TabKaynak.FieldByName('BASLIKID').AsInteger;
           LSecDlg.KaynakSatirID   := TabKaynak.FieldByName('SATIRID').AsInteger;
           LSecDlg.GirDepo         := CDepo;
           LSecDlg.CikDepo         := CDepo;
           LSecDlg.GerekliMiktar   := LKalanMik;
           LSecDlg.KALAN           := LKalanMik;
           LSecDlg.StokDurumDegis  := LStokHar;
           LSecDlg.RehberId        := RehId;
           LSecDlg.ShowModal;
           if LSecDlg.ModalResult <> mrOk then begin
             LIzlemJson.Free;
             TabDetayGiris.Delete;
             Abort;
           end;
           if Trim(LSecDlg.SecimJson) <> '' then
             LIzlemJson.AddPair('secim',
               TJSONObject.ParseJSONValue(LSecDlg.SecimJson) as TJSONArray);
         finally
           FreeAndNil(LSecDlg);
         end;
       end;

       Tablo.ApiCagir('sp_Prog_Izleme_Aktar_Json', LIzlemJson);
    end;

    // ============================================================
    // KAYNAK BELGENIN DURUMU
    //
    // Bu ekran kaynak belgenin DURUM'unu guncellemiyordu: tamamen donusmus
    //   bir siparis listede hala "acik" gorunuyordu (kalan 0 oldugu halde
    //   DURUM 0 kaliyordu - 08.08.2026 tespiti, siparis 23205).
    //   Yeni SP tabanli donusum yolunda bunu sp_Prog_BelgeDonusum_Sonlandir
    //   yapiyor; eski ekran yolunda karsiligi yoktu.
    //
    // Hesap merkezi: sp_Api_Belge_DurumHesapla_Json (Tablo.BelgeDurumHesapla).
    //   Kalan miktara bakip kapali/kismi/acik durumunu yeniden hesaplar -
    //   idempotent, satir basina cagrilmasi zararsiz.
    // TEKLIF (99) kaynagi DISARIDA: durum hesabi yalniz siparis ve belge icin
    //   tanimli.
    var LKaynakTur: Integer := StrToIntDef(VarToStr(cbTur.EditValue), 0);
    if (LKaynakTur <> 99) and (TabKaynak.Active) and
       (TabKaynak.FieldByName('BASLIKID').AsInteger > 0) then
    begin
      if LKaynakTur in [9, 19, 101, 105] then
        Tablo.BelgeDurumHesapla(TabKaynak.FieldByName('BASLIKID').AsInteger, 'siparis')
      else
        Tablo.BelgeDurumHesapla(TabKaynak.FieldByName('BASLIKID').AsInteger, 'belge');
    end;

  end;
End;

procedure TBelgeDonusumDlg.AramaYap;
var
  locateID:integer;
  Kaynak : Integer;
  jP : TJSONObject;
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
  locateID := 0;
  if (TabKaynak.Active)and(TabKaynak.RecordCount>0) then
    locateID := TabKaynak.FieldByName('SATIRID').AsInteger;
  // MOTOR SEAM: PG'de Tablo.ListeSPJson fn_prog_belgedonusum_kaynak_json2 cagirir (vmPG-Exit kaldirildi).
  // cbTur -> kaynak belge tipi
  case StrToIntDef(VarToStr(cbTur.EditValue), 0) of
    99:                  Kaynak := 1;   // TEKLIF
    9, 19, 101, 105:     Kaynak := 2;   // SIPARIS
    6, 10, 14, 109, 110, 119: Kaynak := 3;   // FATBASLIK
  else
    Kaynak := 0;
  end;
  if (DonusumTuru = 0) or (Kaynak = 0) then begin
    TabKaynak.Close;
    Exit;
  end;
  // STANDART SISTEM: 3 inline dal (TEKLIF/SIPARIS/FATBASLIK) -> sp_Prog_BelgeDonusum_Kaynak_Json2.
  jP := TJSONObject.Create;
  jP.AddPair('Kaynak', TJSONNumber.Create(Kaynak));
  jP.AddPair('CbTur', TJSONNumber.Create(StrToIntDef(VarToStr(cbTur.EditValue), 0)));
  jP.AddPair('DonusumTuru', TJSONNumber.Create(DonusumTuru));
  jP.AddPair('HedefBaslikTur', TJSONNumber.Create(HedefBaslikTur));
  if HedefTablo = 'URETIMEMRIDETAY' then
    jP.AddPair('HedefUretim', TJSONNumber.Create(1))
  else
    jP.AddPair('HedefUretim', TJSONNumber.Create(0));
  // EnBoy: opsiyonla (EnBoyHesaplamaAktif) -> SP kolon-listesine EN/BOY/YUZEY/SAYI ekler
  if EnBoyHesaplamaAktif and (DonusumTuru <> TabNo_DONUSUM_STOKTALEP_TRANSFER) then
    jP.AddPair('EnBoy', TJSONNumber.Create(1))
  else
    jP.AddPair('EnBoy', TJSONNumber.Create(0));
  jP.AddPair('TarihBas', FormatDateTime('yyyy-mm-dd 00:00:00', DtBas.Date));
  jP.AddPair('TarihBit', FormatDateTime('yyyy-mm-dd 23:59:59', DtBit.Date));
  if RehID > 0 then
    jP.AddPair('RehID', TJSONNumber.Create(RehID));
  if VarToStrDef(EdBelgeNo.EditValue, '') <> '' then
    jP.AddPair('BelgeNo', VarToStr(EdBelgeNo.EditValue));
  if VarToStrDef(edStokKod.EditValue, '') <> '' then
    jP.AddPair('StokKod', VarToStr(edStokKod.EditValue));
  if VarToStrDef(edUrunNo.EditValue, '') <> '' then
    jP.AddPair('UrunNo', VarToStr(edUrunNo.EditValue));
  if VarToStrDef(edStokAd.EditValue, '') <> '' then
    jP.AddPair('StokAd', VarToStr(edStokAd.EditValue));
  if VarToStrDef(edBarkod.EditValue, '') <> '' then
    jP.AddPair('Barkod', BarkodOku(VarToStr(edBarkod.EditValue)));
  if checkKalmayanGoster.Checked then
    jP.AddPair('KalmayanGoster', TJSONNumber.Create(1));
  if checkGizlenenGoster.Checked then
    jP.AddPair('GizlenenGoster', TJSONNumber.Create(1));
  // izleme detayli-arama: alt-arama STOKSERILOT (SERINO/SKT) uzerinden SP'de
  if PanelDetayliAra.Visible then begin
    if GrpSerino.Visible then begin
      jP.AddPair('IzlemeTur', TJSONNumber.Create(1));
      if EditSerino.Text <> '' then jP.AddPair('Serino', EditSerino.Text);
    end
    else if GrpSKT.Visible then begin
      jP.AddPair('IzlemeTur', TJSONNumber.Create(2));
      if DateSKT.Text <> '' then jP.AddPair('SktTarih', FormatDateTime('yyyy-mm-dd 00:00:00', DateSKT.Date));
    end
    else if GrpKarekod.Visible then begin
      jP.AddPair('IzlemeTur', TJSONNumber.Create(3));
      if EditKarekod.Text <> '' then jP.AddPair('Karekod', EditKarekod.Text);
    end
    else if GrpBoyut.Visible then begin
      jP.AddPair('IzlemeTur', TJSONNumber.Create(4));
      if (cbBoyutKombinasyon.Text <> '') and (EditKarekod.Text <> '') then
        jP.AddPair('BoyutPattern', '%'+cbBoyut1.Text+'%'+cbBoyut2.Text+'%'+cbBoyut3.Text+'%');
    end;
  end;
  Tablo.ListeSPJson(TabKaynak,  'sp_Prog_BelgeDonusum_Kaynak_Json2', '', jP, locateID, 'SATIRID');
end;

end.



