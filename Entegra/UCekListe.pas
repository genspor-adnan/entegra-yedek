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
Uses UTablo,LocOnFly;

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
         GrupCekDurum.Items.Add('Ödenmiþ');
         GrupCekDurum.Items.Add('Ödenmemiþ');
         GrupCekDurum.ItemIndex:=0;
         end;
    2 : begin
         GrupCekDurum.Enabled:= True;
         GrupCekDurum.Items.Clear;
         GrupCekDurum.Items.Add('Tümü');
         GrupCekDurum.Items.Add('Tahsil Edilmiþ');
         GrupCekDurum.Items.Add('Tahsil Edilmemiþ');
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
                                   ' ,SIRANO, ODEMETARIH = ( SELECT top 1 TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )  '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''101%'' OR HESAPKODU LIKE ''103%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' order BY HESAPKODU,VADE ';
         TabCekListesi.Open;
         LabelSayi.Caption:= 'Toplam Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
         cekturu:='Bütün Çekler';
       end;

   1 : begin
         case GrupCekDurum.ItemIndex of // Verilen Çekleri göster seçili ise
          0: begin      // VERÝLEN ÇEKLERÝN TÜMÜ GÖRÜNSÜN
                 TabCekListesi.Close;
                 TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT top 1  TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )    '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' HESAPKODU LIKE ''103%'' AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' order BY HESAPKODU,VADE ';
                 TabCekListesi.Open;
                 LabelSayi.Caption:= 'Toplam Verilen Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
                 cekturu:='Verilen Çekler';
                 cekdurum:='Tümü';
             end;
          1: begin     // VERÝLEN ÇEKLERÝN ÖDENMÝÞLERÝ GÖRÜNSÜN
          TabCekListesi.Close;
          TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT top 1  TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )     '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''103%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' AND SIRANO  IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                   ' order BY HESAPKODU,VADE ';
         TabCekListesi.Open;
         LabelSayi.Caption:= 'Ödenmiþ Verilen Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
         cekdurum:= 'Ödenmiþ';
         cekturu:= 'Verilen Çekler';
             end;
          2: begin     // VERÝLEN CEKLERÝN ÖDENMEMÝÞLERÝ GÖRÜNSÜN
               TabCekListesi.Close;
               TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT top 1  TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )    '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''103%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'') AND'+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' AND SIRANO  NOT IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                   ' order BY HESAPKODU,VADE ';
              TabCekListesi.Open;
              LabelSayi.Caption:= 'Ödenmemiþ Verilen Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
              cekdurum:= 'Ödenmemiþ';
              cekturu:= 'Verilen Çekler';
             end;

         end;
       end;
   2 : begin            // ALINAN ÇEKLERÝ GÖRÜNTÜLEME
         case GrupCekDurum.ItemIndex of
          0: begin    // ALINAN ÇEKLERÝN TÜMÜ GÖRÜNSÜN
               TabCekListesi.Close;
               TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                         ' ,SIRANO, ODEMETARIH = ( SELECT top 1  TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )      '+
                                         ' FROM KASA K'+
                                         ' WHERE '+
                                         ' (HESAPKODU LIKE ''101%'' ) AND '+
                                         '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'')  AND'+
                                         ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                         ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                         ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                         ' order BY HESAPKODU,VADE ';
               TabCekListesi.Open;
               LabelSayi.Caption:= 'Alýnan Toplam Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
               cekturu:='Alýnan Çekler';
               cekdurum:='Tümü'

             end;
          1: begin          // ALINAN ÇEKLERÝN TAHSÝL EDÝLMÝÞLERÝ GÖRÜNSÜN
               TabCekListesi.Close;
               TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                         ' ,SIRANO, ODEMETARIH = ( SELECT top 1  TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )     '+
                                         ' FROM KASA K'+
                                         ' WHERE '+
                                         ' (HESAPKODU LIKE ''101%'' ) AND '+
                                         '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'') AND '+
                                         ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                         ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                         ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                         ' AND SIRANO IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                         ' order BY HESAPKODU,VADE ';
               TabCekListesi.Open;
               LabelSayi.Caption:= 'Tahsil Edilmiþ Alýnan Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
               cekdurum:= 'Tahsil Edilmiþ';
               cekturu:='Alýnan Çekler';
             end;
          2: begin     // ALINAN CEKLERÝN TAHSÝL EDÝLMEMÝÞLERÝ GÖRÜNSÜN.
              TabCekListesi.Close;
              TabCekListesi.SQL.Text:= 'SELECT TARIH, CARIKOD, CARIAD, ACIKLAMA, BORC, ALACAK, HESAPKODU, HESAPADI, KUR, MASRAFKOD, MASRAFAD,VADE '+
                                   ' ,SIRANO, ODEMETARIH = ( SELECT  top 1 TARIH FROM KASA WHERE CEKSENETID = K.SIRANO )       '+
                                   ' FROM KASA K'+
                                   ' WHERE '+
                                   ' (HESAPKODU LIKE ''101%'' ) AND '+
                                   '  ISNULL(CARIKOD,'''') NOT IN (''KASA'',''VÝRMAN'') AND '+
                                   ' ISNULL(HESAPKODU,'''') LIKE '''+ EditHesapKod.Text+'%'' AND '+
                                   ' ISNULL(VADE,''1900-01-01'') BETWEEN '''+ FormatDateTime('yyyy-mm-dd 00:00',datebaslangic.date)+''' AND '+
                                   ' ''' + FormatDateTime('yyyy-mm-dd 23:59',datebitis.date)+ ''' ' +
                                   ' AND SIRANO NOT IN (SELECT DISTINCT CEKSENETID FROM KASA WHERE CEKSENETID IS NOT NULL ) '+
                                   ' order BY HESAPKODU,VADE ';
              TabCekListesi.Open;
              LabelSayi.Caption:= 'Tahsil Edilmemiþ Alýnan Çek Sayýsý : '+ inttostr(TabCekListesi.RecordCount);
              cekdurum:= 'Tahsil Edilmemiþ';
              cekturu:='Alýnan Çekler';
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

