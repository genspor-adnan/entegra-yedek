unit UHizliGunsonuDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLondonLiquidSky, Vcl.Menus, cxStyles, dxSkinscxPCPainter, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData, cxCalendar,
  cxCurrencyEdit, cxImageComboBox, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  frxClass, frxDBSet, FireDAC.Comp.Client, cxTextEdit, cxImage, Vcl.StdCtrls,
  cxButtons, cxDropDownEdit, cxDBEdit, cxMaskEdit, cxLabel, Vcl.ExtCtrls,
  Vcl.ComCtrls, dxCore, cxDateUtils, JvExControls, JvButton, JvNavigationPane,
  cxButtonEdit, cxPCdxBarPopupMenu, cxPC, cxCheckBox, JvLookOut, Vcl.ToolWin,
  cxMemo, UTouchKeyboardWindow, Vcl.Imaging.jpeg, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, cxSplitter,
  dxSkinLiquidSky, dxBarBuiltInMenu, dxDateRanges, dxScrollbarAnnotations;

type
  THizliGunsonuDlg = class(TForm)
    pnlSagUst: TPanel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    cbDepo: TcxImageComboBox;
    dateTarih: TcxDateEdit;
    cxImage1: TcxImage;
    EditAra: TcxTextEdit;
    TabGunSonuStok: TFDQuery;
    DtsGunSonuStok: TDataSource;
    frxSayimKalemleri: TfrxDBDataset;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    cxLabel1: TcxLabel;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    gridSayimTutanak: TcxGrid;
    tvSayimTutanak: TcxGridDBTableView;
    tvSayimTutanakSTOKID: TcxGridDBColumn;
    tvSayimTutanakKATEGORIADI: TcxGridDBColumn;
    clmSayimStokAdi: TcxGridDBColumn;
    tvSayimTutanakBARKOD: TcxGridDBColumn;
    clmSayimStokBirimAD: TcxGridDBColumn;
    clmSayimSistemDEVIR: TcxGridDBColumn;
    tvSayimTutanakCIKAN: TcxGridDBColumn;
    tvSayimTutanakKALAN: TcxGridDBColumn;
    gridSayimTutanakLevel1: TcxGridLevel;
    tvSayimTutanakSARF: TcxGridDBColumn;
    cbSube: TcxImageComboBox;
    DtsTahsilat: TDataSource;
    TahsilDetayGrid: TcxGrid;
    TahsilDetayView: TcxGridDBTableView;
    TahsilDetayViewTAHTURAD: TcxGridDBColumn;
    TahsilDetayViewADI: TcxGridDBColumn;
    TahsilDetayViewTUTAR1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    ToolBar10: TToolBar;
    KasaSilTus: TToolButton;
    ToolButton14: TToolButton;
    TabTahsilat: TFDQuery;
    KasaListeleTus: TToolButton;
    EditFiltre: TcxComboBox;
    cxImage2: TcxImage;
    JvNavPanelButton1: TJvNavPanelButton;
    DtsGunSonuStokDetay: TDataSource;
    TabGunSonuStokDetay: TFDQuery;
    TahsilOzetGrid: TcxGrid;
    TahsilOzetView: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBTUTAR1: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TahsilDetayViewTUTAR2: TcxGridDBColumn;
    TahsilDetayViewColumn2: TcxGridDBColumn;
    TahsilOzetViewTUTAR2: TcxGridDBColumn;
    TahsilOzetViewTOPLAM: TcxGridDBColumn;
    DtsTahsilatOzet: TDataSource;
    TabTahsilatOzet: TFDQuery;
    DtsTahsilatDetay: TDataSource;
    TabTahsilatDetay: TFDQuery;
    SQLKasaDetayInsert: TcxMemo;
    ToolBar1: TToolBar;
    StokSil: TToolButton;
    ToolButton3: TToolButton;
    StokKaydet: TToolButton;
    ToolButton5: TToolButton;
    StokListele: TToolButton;
    SQLKasaOzetInsert: TcxMemo;
    TahsilDetayViewTAHTUR: TcxGridDBColumn;
    cxSplitter1: TcxSplitter;
    Panel1: TPanel;
    SQLIslem: TcxMemo;
    cxGrid2: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumnTUR: TcxGridDBColumn;
    cxGridDBColumnGIREN1: TcxGridDBColumn;
    cxGridDBColumnGIREN2: TcxGridDBColumn;
    cxGridDBColumnGIREN: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    Panel2: TPanel;
    TabGunSonuStokDetay2: TFDQuery;
    DtsGunSonuStokDetay2: TDataSource;
    cxGridDBTableViewSIRA: TcxGridDBColumn;
    SQLStokDetay2: TcxMemo;
    ToolBarSag: TToolBar;
    SatisTus: TToolButton;
    ToolButton2: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton1: TToolButton;
    TabCiro: TFDQuery;
    DtsCiro: TDataSource;
    TabSheetCiro: TcxTabSheet;
    ToolBar2: TToolBar;
    CiroListeleTus: TToolButton;
    ToolButton12: TToolButton;
    CiroListeSilTus: TToolButton;
    GridCiro: TcxGrid;
    GridCiroView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    GridCiroViewREHBERID: TcxGridDBColumn;
    GridCiroViewFIRMA: TcxGridDBColumn;
    GridCiroViewCIRO: TcxGridDBColumn;
    GridCiroViewTAHSIL: TcxGridDBColumn;
    SQLCiro: TcxMemo;
    GridCiroViewFARK: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure BtnSatisClick(Sender: TObject);
    procedure dateTarihPropertiesCloseUp(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure TabGunSonuStokSATISChange(Sender: TField);
    procedure EditFiltrePropertiesCloseUp(Sender: TObject);
    procedure cbSubePropertiesCloseUp(Sender: TObject);
    procedure cbDepoPropertiesCloseUp(Sender: TObject);
    procedure tvSayimTutanakCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TabGunSonuStokDetayAfterOpen(DataSet: TDataSet);
    procedure StokSilClick(Sender: TObject);
    procedure StokKaydetClick(Sender: TObject);
    procedure StokListeleClick(Sender: TObject);
    procedure TabTahsilatDetayAfterPost(DataSet: TDataSet);
    procedure TabTahsilatDetayBeforePost(DataSet: TDataSet);
    procedure KasaSilTusClick(Sender: TObject);
    procedure KasaListeleTusClick(Sender: TObject);
    procedure TabTahsilatDetayAfterOpen(DataSet: TDataSet);
    procedure TabTahsilatOzetBeforePost(DataSet: TDataSet);
    procedure TabGunSonuStokDetayAfterScroll(DataSet: TDataSet);
    procedure SatisTusClick(Sender: TObject);
    procedure TabGunSonuStokAfterScroll(DataSet: TDataSet);
    procedure CiroListeleTusClick(Sender: TObject);
    procedure CiroListeSilTusClick(Sender: TObject);
  private
    { Private declarations }
    Klavye1 : TKeyboardWindow;
    procedure IslemEkle(Tur:Smallint;Alan:String);
    procedure IslemDegis(ID, Tur:integer;IlkDeger,Mik:Real);
    function FatbaslikOlustur(Tur, Tip, Yeri,YerId:Integer; TurAd:String):integer;
  public
    { Public declarations }
  end;

var
  HizliGunsonuDlg: THizliGunsonuDlg;

implementation

{$R *.dfm}
uses UTablo, UGirisKutusuEx, PrjConst, FetaKurulusSiniflari, FetaUtil, UHizliGirisIsk,
  UHizliGunsonuForm;

var
   IslemTarihi : TDateTime;

procedure THizliGunsonuDlg.IslemEkle(Tur:Smallint; Alan:String);
var
  Miktar:Real;
begin
  Miktar := TabGunSonuStok.FieldByName(Alan).AsFloat;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select * from STOKGUNSONUISLEM where GUNSONUID=&ID and TUR=&TUR', ['&ID','&TUR'],[TabGunSonuStok.FieldByName('ID').AsFloat, Tur]) then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKGUNSONUISLEM set MIKTAR=&MIKTAR where GUNSONUID=&GUNSONUID '+
          ' and TUR=&TUR',['&MIKTAR','&GUNSONUID','&TUR'],[Float_ToStr(Miktar),TabGunSonuStok.Fields[0].AsInteger,Tur])
  else
//  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit('Miktar Giriniz',@Mik,4)) = mrOk then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into [STOKGUNSONUISLEM] ([GUNSONUID],[TUR],[MIKTAR],[TAMAM],[EKLEYEN])'+
           ' values(&GUNSONUID,&TUR,&MIKTAR,&TAMAM,&EKLEYEN)',['&GUNSONUID','&TUR','&MIKTAR','&TAMAM','&EKLEYEN'],
             [TabGunSonuStok.Fields[0].AsInteger,Tur,Float_ToStr(Miktar),0,Kullanan]);
//       TabGunSonuStok.Edit;
//       TabGunSonuStok.FieldByName(Alan).AsFloat := TabGunSonuStok.FieldByName(Alan).AsFloat+Mik;
//       if Tur in [6,8] then //üRETİM VEYA İADE İSE EKLENİR
//          TabGunSonuStok.FieldByName('KALAN').AsFloat := TabGunSonuStok.FieldByName('KALAN').AsFloat+Mik
//       else
//          TabGunSonuStok.FieldByName('KALAN').AsFloat := TabGunSonuStok.FieldByName('KALAN').AsFloat-Mik;
//       TabGunSonuStok.Post;
//  end;
end;

procedure THizliGunsonuDlg.IslemDegis(ID, Tur:integer;IlkDeger,Mik:Real);
var Alan:String[20];
begin
   if TabGunSonuStok.Locate('ID', ID, []) then begin
       TabGunSonuStok.Edit;
       case Tur of
         1:Alan:='GELEN';
         4:Alan:='BOZUK';
         5:Alan:='SARF';
         6:Alan:='URETIM';
         7:Alan:='KAYIP';
         8:Alan:='IADE';
         15:Alan:='SATIS';
         20:Alan:='GIDEN';
       end;
       if Tur in [6,8] then begin//üRETİM VEYA İADE İSE EKLENİR
          TabGunSonuStok.FieldByName(Alan).AsFloat := TabGunSonuStok.FieldByName(Alan).AsFloat-IlkDeger+Mik;
          TabGunSonuStok.FieldByName('KALAN').AsFloat := TabGunSonuStok.FieldByName('KALAN').AsFloat-IlkDeger+Mik
       end else begin
          TabGunSonuStok.FieldByName(Alan).AsFloat := TabGunSonuStok.FieldByName(Alan).AsFloat-IlkDeger+Mik;
          TabGunSonuStok.FieldByName('KALAN').AsFloat := TabGunSonuStok.FieldByName('KALAN').AsFloat+IlkDeger-Mik;
       end;
       TabGunSonuStok.Post;
   end;
end;

procedure THizliGunsonuDlg.BtnSatisClick(Sender: TObject);
begin
//   IslemEkle(TJvExpressButton(Sender).Tag, TcxButton(Sender).HelpKeyword);
end;

procedure THizliGunsonuDlg.cbDepoPropertiesCloseUp(Sender: TObject);
begin
   if Cbdepo.Properties.Items.Count >1 then
      dateTarihPropertiesCloseUp(Self);
end;

procedure THizliGunsonuDlg.cbSubePropertiesCloseUp(Sender: TObject);
begin
  cbDepo.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR WHERE SUBEID='+IntToStr(CbSube.EditValue)).Items;
  cbDepo.EditValue := cbDepo.Properties.Items[0].Value;
  dateTarihPropertiesCloseUp(Self);
end;

procedure THizliGunsonuDlg.CiroListeleTusClick(Sender: TObject);
var s:string;
begin
   s:=StringReplace(SQLCiro.Text, '@TARIHBAS', FormatDateTime('yyyy-mm-dd 00:00', dateTarih.date),[rfReplaceAll]);
   s:=StringReplace(s, '@TARIHBIT', FormatDateTime('yyyy-mm-dd 23:59', dateTarih.date),[rfReplaceAll]);
   s:=StringReplace(s, '@SUBEID', IntTostr(cbSube.EditValue),[rfReplaceAll]);
   TabCiro.Close;
   TabCiro.SQL.Text := s;
   TabloYenile(TabCiro, []);
   GridCiroView.ApplyBestFit(nil);
end;

procedure THizliGunsonuDlg.CiroListeSilTusClick(Sender: TObject);
begin
   TabCiro.Close;
end;

procedure THizliGunsonuDlg.cxPageControl1Change(Sender: TObject);
begin
   case cxPageControl1.ActivePageIndex of
    0 :  begin
           TabloYenile( TabGunSonuStok, [dateTarih.Date,cbDepo.EditValue]);
           TabGunSonuStokDetay.Close;
           TabloYenile(TabGunSonuStokDetay, [TabGunSonuStok.Fields[0].AsInteger,'%'+Trim(EditAra.text)+'%','%'+EditFiltre.text+'%']);
           if TabGunSonuStok.RecordCount > 0  then begin
              if (EditFiltre.Properties.Items.Count < 1)and(TabGunSonuStokDetay.recordcount>0) then
                  EditFiltre.Properties := Tablo.ComboboxInit( 'SELECT '''' AS ACIKLAMA UNION ALL '+
                                        'SELECT distinct ACIKLAMA= (SELECT K.AD FROM KATEGORI K INNER JOIN STOKLAR S ON S.ID=SGS.STOKID WHERE S.KATEGORI =K.ID)'+
        //                                ' FROM STOKGUNSONUDETAY SGS where TARIH='''+FormatDateTime('yyyy-mm-dd',dateTarih.Date)+''' AND DEPOID='+IntToStr(cbDepo.EditValue)+' order by 1');
                                        ' FROM STOKGUNSONUDETAY SGS where SGSID='+TabGunSonuStok.Fields[0].AsString+' order by 1');
           end;
         end;
    1: begin //KASA
          TabloYenile( TabTahsilat, [dateTarih.Date,cbSube.EditValue]);
          {if TabTahsilat.Recordcount = 0 then begin
             TabloYenile( 0 );
             TabloYenile( 0 );
          end else begin }
             TabloYenile( TabTahsilatDetay, [TabTahsilat.Fields[0].AsInteger]);
             TabloYenile( TabTahsilatOzet, [TabTahsilat.Fields[0].AsInteger]);
          //end
       end;
   end;
end;

procedure THizliGunsonuDlg.dateTarihPropertiesCloseUp(Sender: TObject);
begin
   cxPageControl1Change(self);
end;

procedure THizliGunsonuDlg.EditFiltrePropertiesCloseUp(Sender: TObject);
begin
   cxPageControl1Change(self);
end;

procedure THizliGunsonuDlg.FormShow(Sender: TObject);
begin
   dateTarih.Date := Tablo.GENINI.BugunTrh;
   cbSube.EditValue := SubeId;
//   cbDepo.EditValue := VarsDepo;
   cbDepo.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR WHERE SUBEID='+IntToStr(CbSube.EditValue)).Items;
   cbDepo.EditValue := cbDepo.Properties.Items[0].Value;
   cxPageControl1Change(self);
   cbSube.Enabled :=  cbSube.EditValue = -1; //merkezde giriliyorsa diğer şubeler de görünebilir
   dateTarih.Enabled :=  cbSube.EditValue = -1; //merkezde giriliyorsa diğer tarihler de görünebilir
end;

procedure THizliGunsonuDlg.KasaSilTusClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASAGUNSONUDETAY WHERE KID='+TabTahsilat.Fields[0].AsString,[],[]);
   cxPageControl1Change(self);
end;

procedure THizliGunsonuDlg.KapatTusClick(Sender: TObject);
begin
   Close
end;

procedure THizliGunsonuDlg.SatisTusClick(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
  Adet : Real;
begin
    Adet := AdetGetir('Adet giriniz','1', TabGunSonuStokDetay.FieldByName('STOKID').AsInteger, TabGunSonuStokDetay.FieldByName('BIRIM').AsInteger, True );
    if Adet=-9999 then begin

//  ctrls := TGirdiDenetimleri.Create.CurrencyEdit('Miktar Girin', @Bilgi,3);    //.Edit(KDBasitFaizOrani, @Bilgi);
//  if TGirisKutusuEx.BilgiAlEx(TcxButton(Sender).Caption+ 'Miktar Girin', ctrls) = mrOk then begin
//      if trim(Bilgi) = '' then begin
         MessageDlg((BGDegeri_bos_olamaz), mtError, [mbOK], 0);
         Exit;
      End
      else begin
         //Bilgi:=StringReplace(Bilgi,',','.',[rfReplaceAll]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKGUNSONUDETAY set '+TcxButton(Sender).HelpKeyword+' = '+Float_ToStr(Adet)+ ' where ID='+TabGunSonuStokDetay.Fields[0].AsString,[],[]);
         if TabGunSonuStok.FieldByName('KAYIT').AsBoolean then begin
            TabGunSonuStok.Edit;
            TabGunSonuStok.FieldByName('KAYIT').AsBoolean:=False;
            TabGunSonuStok.Post;
            StokKaydet.visible := True;
         end;
         TabloYenile(TabGunSonuStokDetay, [TabGunSonuStok.Fields[0].AsInteger,'%'+Trim(EditAra.text)+'%','%'+EditFiltre.text+'%']);
//         TabGunSonuStokDetayAfterScroll(TabGunSonuStokDetay2);
         StokKaydet.visible := True;
      end;
end;

procedure THizliGunsonuDlg.StokSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete F from FATURA F inner join FATBASLIK FB on F.FATBASID = FB.ID and  FB.YERI='+IntToStr(TabNo_STOKGUNSONU)+' and FB.YERID='+TabGunSonuStok.Fields[0].AsString ,[],[]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from FATBASLIK WHERE YERI='+IntToStr(TabNo_STOKGUNSONU)+' and YERID='+TabGunSonuStok.Fields[0].AsString ,[],[]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKGUNSONUDETAY WHERE SGSID='+TabGunSonuStok.Fields[0].AsString,[],[]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKGUNSONU WHERE ID='+TabGunSonuStok.Fields[0].AsString,[],[]);
     dateTarihPropertiesCloseUp(Self);
  end;
end;

procedure THizliGunsonuDlg.TabGunSonuStokAfterScroll(DataSet: TDataSet);
begin
   StokKaydet.visible := (TabGunSonuStok.RecordCount>0)and(not TabGunSonuStok.FieldByName('KAYIT').AsBoolean);
end;

procedure THizliGunsonuDlg.TabGunSonuStokDetayAfterOpen(DataSet: TDataSet);
begin
   StokListele.visible := TabGunSonuStokDetay.RecordCount<1;
   StokSil.visible := not StokListele.visible;
   TabGunSonuStokDetay2.Close;
   ToolBarSag.visible := not StokListele.visible;
end;

procedure THizliGunsonuDlg.TabGunSonuStokDetayAfterScroll(DataSet: TDataSet);
begin
   if TabGunSonuStokDetay.RecordCount=0 then
      exit;
   TabGunSonuStokDetay2.Close;
   TabGunSonuStokDetay2.SQL.Text := StringReplace( SQLStokDetay2.Text, '&ID', TabGunSonuStokDetay.FieldByName('ID').AsString, [rfReplaceAll]);
   TabloYenile(TabGunSonuStokDetay2,[]);
   cxGridDBTableView2.DataController.Groups.FullExpand;
end;

procedure THizliGunsonuDlg.TabGunSonuStokSATISChange(Sender: TField);
begin
//   DEVIR,GELEN,SATIS,IADE,BOZUK,SARF,GIDEN,KAYIP,KALAN,SAYILAN
//   TabGunSonuStok.FieldByName('KALAN').AsFloat := TabGunSonuStok.FieldByName('DEVIR').AsFloat+TabGunSonuStok.FieldByName('URETIM').AsFloat+TabGunSonuStok.FieldByName('GELEN').AsFloat+
//     TabGunSonuStok.FieldByName('IADE').AsFloat-TabGunSonuStok.FieldByName('SATIS').AsFloat-TabGunSonuStok.FieldByName('BOZUK').AsFloat-
//     TabGunSonuStok.FieldByName('SARF').AsFloat-TabGunSonuStok.FieldByName('GIDEN').AsFloat-TabGunSonuStok.FieldByName('KAYIP').AsFloat;

end;

procedure THizliGunsonuDlg.TabTahsilatDetayAfterOpen(DataSet: TDataSet);
begin
   TahsilDetayView.DataController.Groups.FullExpand;
   KasaListeleTus.visible := TabTahsilatDetay.RecordCount<1;
   KasaSilTus.visible := not KasaListeleTus.visible;
end;

procedure THizliGunsonuDlg.TabTahsilatDetayAfterPost(DataSet: TDataSet);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update KASAGUNSONUDETAY set TUTAR1= (select SUM(TOPLAM) from KASAGUNSONUDETAY K '+
      ' where KID='+TabTahsilatDetay.FieldByName('KID').AsString+' and KASATUR='+TabTahsilatDetay.FieldByName('KASATUR').AsString+
      ' and KASAID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and DETAY=1) where KID='+TabTahsilatDetay.FieldByName('KID').AsString+
      ' and KASATUR='+TabTahsilatDetay.FieldByName('KASATUR').AsString+' and KASAID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and DETAY=0 ',[],[]);
   TabloYenile( TabTahsilatOzet, [TabTahsilat.Fields[0].AsInteger]);
end;

procedure THizliGunsonuDlg.TabTahsilatDetayBeforePost(DataSet: TDataSet);
begin
   TabTahsilatDetay.FieldByName('TOPLAM').AsCurrency := TabTahsilatDetay.FieldByName('TUTAR1').AsCurrency+TabTahsilatDetay.FieldByName('TUTAR2').AsCurrency
end;

procedure THizliGunsonuDlg.TabTahsilatOzetBeforePost(DataSet: TDataSet);
begin
   TabTahsilatOzet.FieldByName('TOPLAM').AsCurrency := TabTahsilatOzet.FieldByName('TUTAR2').AsCurrency-TabTahsilatOzet.FieldByName('TUTAR1').AsCurrency
end;

procedure THizliGunsonuDlg.StokListeleClick(Sender: TObject);
begin
   //alttaki sp de hem günsonu stok hem günsonu stokdetay oluşturulur

   //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKGUNSONU

   if TabGunSonuStok.RecordCount=0 then begin
      TabGunSonuStok.Append;
      TabGunSonuStok.FieldByName('TARIH').AsDateTime := dateTarih.Date;
      TabGunSonuStok.FieldByName('SUBEID').AsInteger := cbSube.EditValue;
      TabGunSonuStok.FieldByName('DEPOID').AsInteger := cbDepo.EditValue;
      TabGunSonuStok.FieldByName('KAYIT').AsBoolean:= False;
      TabGunSonuStok.FieldByName('EKLEYEN').AsString := Kullanan;
      TabGunSonuStok.Post;
   end;

   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' exec [dbo].[Sp_Prg_GunSonuStokKontrol] '+TabGunSonuStok.Fields[0].AsString+','''+FormatDateTime('yyyy-mm-dd', dateTarih.Date)+''', &PrmDepo,&PSube, &PEkleyen',
               ['&PrmDepo','&PSube', '&PEkleyen'],[cbDepo.EditValue, cbSube.EditValue, StrToIntDef(Kullanan, 0)]);

//   TabloYenile( TabGunSonuStok, [dateTarih.Date,cbDepo.EditValue]);
//   TabloYenile( TabGunSonuStokDetay, [TabGunSonuStok.Fields[0].AsInteger,'%'+Trim(EditAra.text)+'%','%'+EditFiltre.text+'%']);

//   if EditFiltre.Properties.Items.Count<1 then
//      EditFiltre.Properties := Tablo.ComboboxInit( 'SELECT '''' AS ACIKLAMA UNION ALL '+
//                                'SELECT distinct ACIKLAMA= (SELECT K.AD FROM KATEGORI K INNER JOIN STOKLAR S ON S.ID=SGS.STOKID WHERE S.KATEGORI =K.ID)'+
//                                ' FROM STOKGUNSONU SGS where TARIH='''+FormatDateTime('yyyy-mm-dd',dateTarih.Date)+''' AND DEPOID='+IntToStr(cbDepo.EditValue)+' order by 1');
   cxPageControl1Change(Self);
end;

procedure THizliGunsonuDlg.tvSayimTutanakCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Application.CreateForm(THizliGunsonuForm, HizliGunsonuForm);
  HizliGunsonuForm.DtsGunSonuStokDetay.DataSet := TabGunSonuStokDetay;
  HizliGunsonuForm.ShowModal;
  HizliGunsonuForm.Destroy;
end;

procedure THizliGunsonuDlg.KasaListeleTusClick(Sender: TObject);
var s:string;
begin
          if TabTahsilat.RecordCount=0 then begin
             TabTahsilat.Append;
             TabTahsilat.FieldByName('TARIH').AsDateTime := dateTarih.Date;
             TabTahsilat.FieldByName('SUBEID').AsInteger := cbSube.EditValue;
             TabTahsilat.Post;
          end;

   if TabTahsilatDetay.RecordCount=0 then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, SQLKasaDetayInsert.text,['&KID','&EKLEYEN','&SUBE'],[TabTahsilat.Fields[0].AsInteger, Kullanan, cbSube.EditValue]);
      TabloYenile( TabTahsilatDetay, [TabTahsilat.Fields[0].AsInteger]);
      while not TabTahsilatDetay.Eof do begin
         if TabTahsilatDetay.FieldByName('TAHTUR').AsInteger < 10 then
            s:= 'select sum(ALACAK)'
         else
            s:= 'select -1*sum(BORC)';
         s:=s+' from KASA where ISLEMTARIHI between '''+FormatDateTime('yyyy-mm-dd', dateTarih.date)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59', dateTarih.date)+''' and SUBEID='+IntToStr(cbsube.editvalue);
         case TabTahsilatDetay.FieldByName('TAHTUR').AsInteger of
           1: case TabTahsilatDetay.FieldByName('KASATUR').AsInteger of //bugünkü satışlar
                1: s:=s+' and TUR=21  and isnull(FATURAID,0)>0'; //bugünkü nakit
                2: s:=s+' and TUR=25  and HESAPID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and isnull(FATURAID,0)>0'; //bugünkü KK
                3: s:=s+' and TUR=26  and CEKSENETID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and isnull(FATURAID,0)>0'; //bugünkü yemek çeki
              end;
           2: case TabTahsilatDetay.FieldByName('KASATUR').AsInteger of //önceki  satışlardan tahsilatlar
                1: s:=s+' and TUR=21  and isnull(FATURAID,0)=0'; //bugünkü nakit
                2: s:=s+' and TUR=25  and HESAPID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and isnull(FATURAID,0)=0'; //bugünkü KK
                3: s:=s+' and TUR=26  and CEKSENETID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and isnull(FATURAID,0)=0'; //bugünkü yemek çeki
              end;
           3: case TabTahsilatDetay.FieldByName('KASATUR').AsInteger of //kapora alınan
                1: s:=s+' and TUR=21  and isnull(FATURAID,0)=1'; //bugünkü nakit
                2: s:=s+' and TUR=25  and HESAPID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and isnull(FATURAID,0)=1'; //bugünkü KK
                3: s:=s+' and TUR=26  and CEKSENETID='+TabTahsilatDetay.FieldByName('KASAID').AsString+' and isnull(FATURAID,0)=1'; //bugünkü yemek çeki
              end;
           11: case TabTahsilatDetay.FieldByName('KASATUR').AsInteger of //ödemeler
                1: s:=s+' and TUR=31 '; //bugünkü nakit
                2: s:=s+' and TUR=35  and HESAPID='+TabTahsilatDetay.FieldByName('KASAID').AsString; //bugünkü KK
              end;
           12: s:=s+' and TUR=40 ' //merkeze giden
         end;
         Tablo.TablodanSorguAc(5, s);
         TabTahsilatDetay.Edit;
         TabTahsilatDetay.FieldByName('TUTAR1').AsCurrency := Tablo.Query5.Fields[0].AsCurrency;
         TabTahsilatDetay.Post;
         TabTahsilatDetay.next;
      end;
   end;
   //
   if TabTahsilatOzet.RecordCount=0 then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, SQLKasaOzetInsert.text,['&KID','&EKLEYEN'],[TabTahsilat.Fields[0].AsInteger, Kullanan]);
      TabloYenile( TabTahsilatOzet, [TabTahsilat.Fields[0].AsInteger]);
   end;
end;

function THizliGunsonuDlg.FatbaslikOlustur(Tur,Tip, Yeri,YerId:Integer; TurAd:String):integer;
var
  belgeno : TBelgeNo;
  RehberId,GDepo,CDepo:Integer;
  FATURA_MATRAHI, KDV_TUTARI : Extended;
  BrFiyat:String;
begin
   if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * from STOKGUNSONUDETAY WHERE SGSID='+TabGunSonuStok.Fields[0].AsString+' and abs('+TurAd+')>0.0 and KAYIT=0',[],[]) then
      exit;

  if Tur in [8,16] then
     RehberId:=VarsMusteri
  else
     RehberId:=cbSube.EditValue;

  if Tur in [6,8] then begin
     GDepo:=cbDepo.EditValue; CDepo:=0;
  end else begin
     GDepo:=0; CDepo:=cbDepo.EditValue;
  end;


  belgeno:= SiradakiBelgeNumarasi(Tur, IslemTarihi);
  Tablo.Query7.Close;
  Tablo.Query7.SQL.Text:= 'INSERT INTO FATBASLIK (TARIH,FATURATARIH,FATURANO,KOCANNO,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO, EKVERGI,KUR,DOVIZ_CINSI,SAYFA';
  Tablo.Query7.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID,ANAKAYITID,LOKASYON,ISYERI,AKTIVITEID,STOKISK,FATURA_MATRAHI,FATURA_TUTARI,DOVIZKUR,'+
            'KDV_TUTARI,DOVIZ_TUTARI,ZARFID,GIRISKAYNAK,DURUM,FIYAT_LISTESI,ACIK_KAPALI,EKSTREDEKULLAN,RAPORDOVIZ,FATURADOVIZI) ');
  Tablo.Query7.SQL.Add(' VALUES('''+FormatDateTime('mm/dd/yyyy hh:nn:ss', IslemTarihi)+''','''+FormatDateTime('mm/dd/yyyy hh:nn:ss', IslemTarihi)+''','''+belgeno.belgeno+''','+IntToStr(KocannoBul(6))+
                                     ','+IntToStr(Tur)+','+IntToStr(Tip)+','+IntToStr(RehberId)+','+IntToStr(GDepo)+','+IntToStr(CDepo));
  Tablo.Query7.SQL.Add(' ,0.0,'''+CariDoviz+''','''+CariDoviz+''',0,');
  Tablo.Query7.SQL.Add(' '''','+Kullanan+',''Hariç'','+ IntToStr(cbSube.EditValue)+','+IntToStr(TabNo_STOKGUNSONU)+','+TabGunSonuStok.Fields[0].AsString+',-1,0,0,-1'+
                    ',0,0,0,'+Float_ToStr(DovizKurDegeri)+',0,0,'+IntToStr(Tur)+','+IntToStr(Windows_Kasiyer_Gunsonu)+
                    ',0,'+Tablo.GenIni.ReadString(StrToInt('-77'+SubeIDYazi+'05'), '-99')+',1,0'+','''+CariDoviz+''','''+CariDoviz+''') SELECT SCOPE_IDENTITY()');
  Tablo.Query7.Open;

  Result := Tablo.Query7.Fields[0].AsInteger;

  Tablo.TablodanSorguAc(8, 'Select * from FATBASLIK where ID='+Tablo.Query7.Fields[0].AsString);
  Tablo.FaturaBaslik(Tablo.Query8, cbSube.EditValue);
  Tablo.Query8.Post;

  BrFiyat := 'case when SF.KDVDURUM=0 then SF.FIYAT else SF.FIYAT/nullif(((100.0+KDV)/100.0),0) end ';
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
  Tablo.Query6.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,'+
                       'MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,GIRISKAYNAK)  ');
  Tablo.Query6.SQL.Add('select '+Tablo.Query7.Fields[0].AsString+','+IntToStr(RehberId)+',1,S.ID,'''',abs(SGS.'+TurAd+')'+//FormatFloat('#.######',TabIslem.FieldByName('MIKTAR').AsFloat)+
                       ',S.ANABIRIM,abs(SGS.'+TurAd+'),BIRIMFIYAT='+BrFiyat+',TUTAR=cast(abs(SGS.'+TurAd+')*'+BrFiyat+' as money),'''+CariDoviz+''',0,0,S.KDV,'+
                       'cast(abs(SGS.'+TurAd+')*'+BrFiyat+' as money),'''+CariDoviz+''',cast(abs(SGS.'+TurAd+')*'+BrFiyat+' as money),1.0');
  Tablo.Query6.SQL.Add(',S.MASRAFID,S.IZLEME,1,'+IntToStr(cbSube.EditValue)+','+Kullanan+',0,0,'+IntToStr(Windows_Kasiyer_Gunsonu));
  Tablo.Query6.SQL.Add(' from STOKGUNSONUDETAY SGS inner join STOKLAR S on SGS.STOKID=S.ID '+
                            ' inner join STOKFIYAT SF on SGS.STOKID=SF.STOKID and SF.FIYATADI='+IntToStr(VarsSatisFiyatID)+' and SF.BIRIM=S.ANABIRIM '+
                            ' where SGSID='+TabGunSonuStok.Fields[0].AsString+' and abs(SGS.'+TurAd+')>0.0');
  Tablo.Query6.ExecSQL;

  Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
      ' isnull(ROUND(sum(TUTAR*(KDV/100.0)),2),0.0) AS KDVTOPLAM ' +
//      ' isnull(ROUND(sum(DOVIZ_TUTARI*((KDV*(100.0-KDVMUHAFIYETI)/100.0)/100.0)),2),0.0) AS DOVIZKDVTOPLAM , ' +
//      ' isnull(ROUND(sum(MALIYET),2),0.0) as MALIYET_ORT, isnull(ROUND(sum(EKMALIYET),2),0.0) as MALIYET_SON '+
      ' from FATURA where FATBASID=' + Tablo.Query7.Fields[0].AsString;
  Tablo.Query1.Open;

  FATURA_MATRAHI := Tablo.Query1.FieldByName('ARATOPLAM').AsExtended;
  KDV_TUTARI     := Tablo.Query1.FieldByName('KDVTOPLAM').AsExtended;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set FATURA_MATRAHI='+Float_ToStr(FATURA_MATRAHI)+','+
    'KDV_TUTARI='+Float_ToStr(KDV_TUTARI)+',FATURA_TUTARI='+Float_ToStr(FATURA_MATRAHI+KDV_TUTARI)+', DOVIZ_TUTARI=0.0 WHERE ID='+Tablo.Query7.Fields[0].AsString ,[],[]);
//  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKGUNSONUDETAY set KAYIT=1 WHERE SGSID='+TabGunSonuStok.Fields[0].AsString+' and '+TurAd+'>0.0 and  KAYIT=0' ,[],[]);
  Result := Tablo.Query7.Fields[0].AsInteger;
end;

procedure THizliGunsonuDlg.StokKaydetClick(Sender: TObject);
var S:string[30];
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete F from FATURA F inner join FATBASLIK FB on F.FATBASID = FB.ID and  FB.YERI='+IntToStr(TabNo_STOKGUNSONU)+' and FB.YERID='+TabGunSonuStok.Fields[0].AsString ,[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from FATBASLIK WHERE YERI='+IntToStr(TabNo_STOKGUNSONU)+' and YERID='+TabGunSonuStok.Fields[0].AsString ,[],[]);

   s:= StringReplace(dateTarih.text,'.',FormatSettings.dateseparator, [rfReplaceAll]);
   s:= StringReplace(s,'/',FormatSettings.dateseparator, [rfReplaceAll]);
   s:= s+' 23:55';
   IslemTarihi:= StrToDateTimeDef(s, Tablo.GENINI.BugunTrhSaat);
   FatbaslikOlustur(6,1, 0, 0, 'URETIM_2');
   FatbaslikOlustur(8,1, 0, 0, 'IADE_2');
   FatbaslikOlustur(16,1, 0, 0, 'PSATIS_2');
   //FatbaslikOlustur(20,1, 0, 0, 'GIDEN_2');
   FatbaslikOlustur(4,11, 0, 0, 'SARF_2');
   //FatbaslikOlustur(4,12, 0, 0, 'KAYIP_2');
   FatbaslikOlustur(4,12, 0, 0, 'BOZUK_2');
   TabGunSonuStok.Edit;
   TabGunSonuStok.FieldByName('KAYIT').AsBoolean:=True;
   TabGunSonuStok.Post;
   StokKaydet.visible := False;
end;

procedure THizliGunsonuDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := 200;//Top + Height;

  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;
end;

end.



