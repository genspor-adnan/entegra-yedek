unit UCekListe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ToolWin, dxSkinsCore, dxSkinscxPCPainter, dxSkinLondonLiquidSky, cxContainer, cxLabel, dxSkinLiquidSky,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxDateRanges, dxScrollbarAnnotations;

type
  TCekListeDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    DateBaslangic: TDateTimePicker;
    DateBitis: TDateTimePicker;
    BtnListele: TSpeedButton;
    GrupCekTuru: TRadioGroup;
    GrupCekDurum: TRadioGroup;
    CekListesiTableview: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    TabCekListesi: TFDQuery;
    DtsCekListesi: TDataSource;
    Panel3: TPanel;
    Label4: TcxLabel;
    EditHesapKod: TEdit;
    CekListesiTableviewDBColumn1: TcxGridDBColumn;
    CekListesiTableviewDBColumn2: TcxGridDBColumn;
    CekListesiTableviewDBColumn3: TcxGridDBColumn;
    CekListesiTableviewDBColumn4: TcxGridDBColumn;
    CekListesiTableviewDBColumn5: TcxGridDBColumn;
    CekListesiTableviewDBColumn6: TcxGridDBColumn;
    ColumnGIREN: TcxGridDBColumn;
    ColumnCIKAN: TcxGridDBColumn;
    CekListesiTableviewDBColumn9: TcxGridDBColumn;
    CekListesiTableviewDBColumn10: TcxGridDBColumn;
    CekListesiTableviewDBColumn11: TcxGridDBColumn;
    CekListesiTableviewDBColumn12: TcxGridDBColumn;
    CekListesiTableviewDBColumn13: TcxGridDBColumn;
    CekListesiTableviewDBColumn14: TcxGridDBColumn;
    LabelGiren: TcxLabel;
    LabelCikan: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    LabelSayi: TcxLabel;
    ToolBar1: TToolBar;
    EkranYaz: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    CekListesiTableviewDBColumn7: TcxGridDBColumn;
    procedure GrupCekTuruClick(Sender: TObject);
    procedure BtnListeleClick(Sender: TObject);
    procedure TabCekListesiAfterOpen(DataSet: TDataSet);
    procedure EkranYazClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CekListeDlg: TCekListeDlg;
     cekturu , cekdurum : string;
implementation
Uses UTablo,LocOnFly,UVeriMotor;

{$R *.dfm}

procedure TCekListeDlg.GrupCekTuruClick(Sender: TObject);
begin
  case GrupCekTuru.ItemIndex of
    0 : begin
         GrupCekDurum.Enabled:= False;
        end;
    1 : begin
         GrupCekDurum.Enabled:= True;
         GrupCekDurum.Items.Clear;
         GrupCekDurum.Items.Add('Tümü');
         GrupCekDurum.Items.Add('Ödenmiş');
         GrupCekDurum.Items.Add('Ödenmemiş');
         GrupCekDurum.ItemIndex:=0;
         end;
    2 : begin
         GrupCekDurum.Enabled:= True;
         GrupCekDurum.Items.Clear;
         GrupCekDurum.Items.Add('Tümü');
         GrupCekDurum.Items.Add('Tahsil Edilmiş');
         GrupCekDurum.Items.Add('Tahsil Edilmemiş');
         GrupCekDurum.ItemIndex:=0;
        end;
   end;
end;

procedure TCekListeDlg.BtnListeleClick(Sender: TObject);
begin
   case GrupCekTuru.ItemIndex of
   0 : begin   // Tüm cekleri göster seçili ise
          TabCekListesi.Close;
          TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT '+DbUst(1)+'TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')  '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''101%'' OR HESAPKODU LIKE ''103%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' order BY HESAPKODU,VADE ';
         TabCekListesi.Open;
         LabelSayi.Caption:= 'Toplam Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
         cekturu:='Bütün Çekler';
       end;

   1 : begin
         case GrupCekDurum.ItemIndex of // Verilen Çekleri göster seçili ise
          0: begin      // VERİLEN ÇEKLERİN TÜMÜ GÖRÜNSÜN
                 TabCekListesi.Close;
                 TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT '+DbUst(1)+' TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')    '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' HESAPKODU LIKE ''103%'' AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' order BY HESAPKODU,VADE ';
                 TabCekListesi.Open;
                 LabelSayi.Caption:= 'Toplam Verilen Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
                 cekturu:='Verilen Çekler';
                 cekdurum:='Tümü';
             end;
          1: begin     // VERİLEN ÇEKLERİN ÖDENMİŞLERİ GÖRÜNSÜN
          TabCekListesi.Close;
          TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT '+DbUst(1)+' TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')     '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''103%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' AND SIRANO  IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                   ' order BY HESAPKODU,VADE ';
         TabCekListesi.Open;
         LabelSayi.Caption:= 'Ödenmiş Verilen Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
         cekdurum:= 'Ödenmiş';
         cekturu:= 'Verilen Çekler';
             end;
          2: begin     // VERİLEN CEKLERİN ÖDENMEMİŞLERİ GÖRÜNSÜN
               TabCekListesi.Close;
               TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT '+DbUst(1)+' TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')    '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''103%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'') AND'+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' AND SIRANO  NOT IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                   ' order BY HESAPKODU,VADE ';
              TabCekListesi.Open;
              LabelSayi.Caption:= 'Ödenmemiş Verilen Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
              cekdurum:= 'Ödenmemiş';
              cekturu:= 'Verilen Çekler';
             end;

         end;
       end;
   2 : begin            // ALINAN ÇEKLERİ GÖRÜNTÜLEME
         case GrupCekDurum.ItemIndex of
          0: begin    // ALINAN ÇEKLERİN TÜMÜ GÖRÜNSÜN
               TabCekListesi.Close;
               TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                         ' ,SIRANO, ODEMETARIH = ( SELECT '+DbUst(1)+' TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')      '+
                                         ' FROM KASA K'+
                                         ' WHERE '+
                                         ' (HESAPKODU LIKE ''101%'' ) AND '+
                                         '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'')  AND'+
                                         ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                         ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                         ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                         ' order BY HESAPKODU,VADE ';
               TabCekListesi.Open;
               LabelSayi.Caption:= 'Alınan Toplam Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
               cekturu:='Alınan Çekler';
               cekdurum:='Tümü'

             end;
          1: begin          // ALINAN ÇEKLERİN TAHSİL EDİLMİŞLERİ GÖRÜNSÜN
               TabCekListesi.Close;
               TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                         ' ,SIRANO, ODEMETARIH = ( SELECT '+DbUst(1)+' TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')     '+
                                         ' FROM KASA K'+
                                         ' WHERE '+
                                         ' (HESAPKODU LIKE ''101%'' ) AND '+
                                         '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'') AND '+
                                         ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                         ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                         ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                         ' AND SIRANO IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                         ' order BY HESAPKODU,VADE ';
               TabCekListesi.Open;
               LabelSayi.Caption:= 'Tahsil Edilmiş Alınan Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
               cekdurum:= 'Tahsil Edilmiş';
               cekturu:='Alınan Çekler';
             end;
          2: begin     // ALINAN CEKLERİN TAHSİL EDİLMEMİŞLERİ GÖRÜNSÜN.
              TabCekListesi.Close;
              TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT  '+DbUst(1)+'TARIH FROM KASA WHERE CEKSENETID = K.SIRANO '+DbSinir(1)+')       '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''101%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VİRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' AND SIRANO NOT IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                   ' order BY HESAPKODU,VADE ';
              TabCekListesi.Open;
              LabelSayi.Caption:= 'Tahsil Edilmemiş Alınan Çek Sayısı : '+ inttostr(TabCekListesi.RecordCount);
              cekdurum:= 'Tahsil Edilmemiş';
              cekturu:='Alınan Çekler';
             end;

         end;
       end;
   end;
end;


procedure TCekListeDlg.TabCekListesiAfterOpen(DataSet: TDataSet);
begin
  CekListesiTableView.ApplyBestFit(nil);
  LabelCikan.Caption:= CekListesiTableview.DataController.Summary.FooterSummaryTexts[1];
  LabelGiren.Caption:= CekListesiTableview.DataController.Summary.FooterSummaryTexts[0];

end;

procedure TCekListeDlg.EkranYazClick(Sender: TObject);

begin             {
  RapTablo.CEKLISTE.Close;
  RapTablo.CEKLISTE.SQL.Text := TabCekListesi.SQL.Text;
  RapTablo.CEKLISTE.Open;


  RapTablo.SAYFABASLIK.Close;
  RapTablo.SAYFABASLIK.SQL.Text:= 'SELECT TARIH1= '''+ FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',DateBaslangic.DateTime)+''' ,'+
                                  ' TARIH2='''+FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',DateBitis.DateTime)+''', '+
                                  ' CEKTURU = '''+ cekturu+''', CEKDURUM = '''+cekdurum+'''' ;
  RapTablo.SAYFABASLIK.Open;

                 }

  //TabloDokum.Ekran_Yazici_Islemi(Sender);

end;

procedure TCekListeDlg.ToolButton1Click(Sender: TObject);
begin
 Close;
end;

procedure TCekListeDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  DateBaslangic.DateTime:= now;
  DateBitis.DateTime:= now+30;
end;

end.

