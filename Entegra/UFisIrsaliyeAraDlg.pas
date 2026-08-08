unit UFisIrsaliyeAraDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxImageComboBox, cxCurrencyEdit, cxButtonEdit, cxTextEdit,
  cxCheckBox, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, cxContainer,
  cxMaskEdit, cxDropDownEdit, cxCalendar, ExtCtrls, cxGridLevel, UIzleme,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, FireDAC.Comp.Client, cxEditRepositoryItems, dxSkinLiquidSky, cxLookAndFeels, Vcl.ComCtrls, dxCore, cxDateUtils, cxNavigator,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TFisIrsaliyeAraDlg = class(TForm)
    Panel1: TPanel;
    GridFat: TcxGrid;
    GridFatDBTableView1: TcxGridDBTableView;
    GridFatDBTableView1TUR: TcxGridDBColumn;
    GridFatDBTableView1KOD1: TcxGridDBColumn;
    GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn;
    GridFatDBTableView1ADET1: TcxGridDBColumn;
    GridFatDBTableView1BIRIM1: TcxGridDBColumn;
    GridFatDBTableView1BIRIMFIYAT1: TcxGridDBColumn;
    GridFatDBTableView1ISKONTO1: TcxGridDBColumn;
    GridFatDBTableView1KDV1: TcxGridDBColumn;
    GridFatDBTableView1TUTAR1: TcxGridDBColumn;
    GridFatLevel1: TcxGridLevel;
    Label1: TLabel;
    dateBaslangic: TcxDateEdit;
    dateBitis: TcxDateEdit;
    Label2: TLabel;
    TabFatBaslik: TFDQuery;
    DtsFatBaslik: TDataSource;
    DtsFatura: TDataSource;
    TabFatura: TFDQuery;
    cxEditRepository1: TcxEditRepository;
    cxEditRepository1CheckBoxItem1: TcxEditRepositoryCheckBoxItem;
    Label3: TLabel;
    lblSeciliKayit: TLabel;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1Column2: TcxGridDBColumn;
    cxGrid1DBTableView1Column3: TcxGridDBColumn;
    cxGrid1DBTableView1Column4: TcxGridDBColumn;
    cxGrid1DBTableView1Column6: TcxGridDBColumn;
    GridSepet: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    dtsSepet: TDataSource;
    Panel2: TPanel;
    Panel3: TPanel;
    btnSecilileriEkle: TcxButton;
    btnTumunuEkle: TcxButton;
    btnIslemiTamamla: TcxButton;
    MemoFaturaDetaylari: TMemo;
    clmSec: TcxGridDBColumn;
    MemoSiparisDetaylari: TMemo;
    GridFatDBTableView1Column1: TcxGridDBColumn;
    MemoSepet: TMemo;
    GridFatDBTableView1Column2: TcxGridDBColumn;
    cxGridDBTableView1Column1: TcxGridDBColumn;
    cxGridDBTableView1Column2: TcxGridDBColumn;
    cxGridDBTableView1Column3: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    pmSepet: TPopupMenu;
    SatrSil1: TMenuItem;
    N1: TMenuItem;
    mnSil: TMenuItem;
    tabDonusumSepet: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure TabFatBaslikAfterOpen(DataSet: TDataSet);
    procedure TabFatBaslikAfterScroll(DataSet: TDataSet);
    procedure btnTumunuEkleClick(Sender: TObject);
    procedure DetaySatirlariGetir(BaslikId:integer);
    function SatiriSepeteEkle(satirid:integer):integer;
    procedure dateBitisPropertiesCloseUp(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnIslemiTamamlaClick(Sender: TObject);
    procedure GridFatDBTableView1StylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure SatrSil1Click(Sender: TObject);
    procedure mnSilClick(Sender: TObject);
    procedure SepetiYenile;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FisIrsaliyeAraDlg: TFisIrsaliyeAraDlg;
  FisIrsFirmaId, SeciliFatID, FisIrsTur,SeciliDepoId : Integer;
  SeciliBelgeTrh:TDateTime;
  SeciliFatIrsNo : string;
  IzlemDlg : TIzlemeDlg;

implementation

{$R *.dfm}
Uses UTablo, FetaKurulusSiniflari, UAnaForm;


procedure TFisIrsaliyeAraDlg.DetaySatirlariGetir(BaslikId:integer);
var
 turler:string;
begin


  TabFatura.Close;
  TabFatura.SQL.Text:= 'DECLARE @BASLIKID INT '+
                       ' SET @BASLIKID ='+inttostr(BaslikId)+' ';

 case TabFatBaslik.FieldByName('TUR').AsInteger of
   KasaTur_AlisIrsaliyesi,
   KasaTur_SatisIrsaliyesi :
                           begin
                                TabFatura.SQL.Add(MemoFaturaDetaylari.Text);
                            end;
   KasaTur_AlisSiparisi,
   KasaTur_SatisSiparisi : begin
                               TabFatura.SQL.Add(MemoSiparisDetaylari.Text);
                           end;
 end;
  TabFatura.Open;

end;
function TFisIrsaliyeAraDlg.SatiriSepeteEkle(satirid:integer):integer;
begin
//
end;
procedure TFisIrsaliyeAraDlg.SatrSil1Click(Sender: TObject);
begin
  if tabDonusumSepet.RecordCount<=0 then Abort;
  tabDonusumSepet.Delete;
end;

procedure TFisIrsaliyeAraDlg.btnIslemiTamamlaClick(Sender: TObject);
var
 DonusTuru, HedefBaslikTuru, belgetipi, hedefbaslikid, hareketyonu,depoid, faturasatirid: integer;
 donusumayarlari : TBelgeDonusumAyar;
 basliktablosu, detaytablosu, depoalani:string;
 GDepo,CDepo: Integer;
 stokyeterli:boolean;
 miktar : real;
begin
  if tabDonusumSepet.RecordCount<=0 then Abort;
  tabDonusumSepet.First;
  while not tabDonusumSepet.Eof do begin
    if FisIrsTur in [KasaTur_AlisFaturasi, KasaTur_SatisFaturasi] then
      belgetipi:=2
    else
      belgetipi:=1;
    DonusTuru:=Tablo.BelgeDonustur_DonusTipiBul(tabDonusumSepet.FieldByName('FATBASTUR').AsInteger,belgetipi );
    donusumayarlari:= Tablo.BelgeDonustur_BilgiAyarlari(DonusTuru, HedefBaslikTuru, basliktablosu, detaytablosu, depoalani);
    if tabDonusumSepet.FieldByName('TUR').AsInteger=1 then begin
       //çıkış türü fatura ise stok kontrol durumuna bakılıyor
      if donusumayarlari.Baslikturu in [KasaTur_SatisIrsaliyesi, KasaTur_SatisFaturasi] then begin
        //19.07.2026 AO: StokVarmi -> StokCikisYeterliMi (tarih-bazli; StokDurumKontrolKurali + mesaj helper icinde)
        //stokyeterli:= Tablo.StokVarmi( tabDonusumSepet.FieldByName('URUNID').AsInteger,
        //                    tabDonusumSepet.FieldByName(donusumayarlari.depoalani).AsInteger,
        //                    tabDonusumSepet.FieldByName('MIKTAR').AsFloat )
        var LKalan: Double;
        stokyeterli:= Tablo.StokCikisYeterliMi( tabDonusumSepet.FieldByName('URUNID').AsInteger,
                            tabDonusumSepet.FieldByName(donusumayarlari.depoalani).AsInteger, 0,
                            Tablo.GENINI.BugunTrh, tabDonusumSepet.FieldByName('MIKTAR').AsFloat, False, 0, LKalan);
      end
      else
        stokyeterli:=True; // alış belgelerinde stok kontrolüne takılmadan işlemin devam etmesi için
      if stokyeterli then begin
        Tablo.BelgeDonustur_DetaySatirOlustur(faturasatirid,DonusTuru,
                                               SeciliFatID,
                                               tabDonusumSepet.FieldByName('FATBASID').AsInteger,
                                               tabDonusumSepet.FieldByName('DETAYSATIRID').AsInteger,  //FATURA VEYA SIPARISDETAY tablosundaki ID değeri temp tabloda bu alanda saklanıyor
                                               tabDonusumSepet.FieldByName('ADET').AsFloat,
                                               tabDonusumSepet.FieldByName('BIRIM').AsFloat,
                                               tabDonusumSepet.FieldByName('MIKTAR').AsFloat,
                                               tabDonusumSepet.FieldByName('IZLEME').AsInteger,
                                               donusumayarlari.basliktablosu,donusumayarlari.detaytablosu,'FATBASLIK','FATURA');
        //izleme durumunun skt, serino gibi olması durumunda gerekli işlemler yapılmalı
        //eğer uygun miktar cıkısı yapılmamıssa ilgili satır silinmeli

        if tabDonusumSepet.FieldByName('IZLEME').AsInteger > 0 then begin //izlemesi var ise
          case DonusTuru of
            TabNo_DONUSUM_ALIS_IRS_FAT:; //bu durumda stokdurum bile değişmeyecek..
            TabNo_DONUSUM_SATIS_IRS_FAT:;
          else
            if tabDonusumSepet.FieldByName('GIRISDEPO').Value <> null then
              GDepo := tabDonusumSepet.FieldByName('GIRISDEPO').AsInteger
            else
              GDepo := 0;
            if tabDonusumSepet.FieldByName('CIKISDEPO').Value <> null then
              CDepo := tabDonusumSepet.FieldByName('CIKISDEPO').AsInteger
            else
              CDepo := 0;
            miktar := tabDonusumSepet.FieldByName('MIKTAR').AsInteger;
            // A8: ekran secer, yazma sp_Prog_Izleme_Yaz_Json ile hemen yapilir.
            //   Satir ID'si BURADA ZATEN BELLI (faturasatirid, yukarida
            //   BelgeDonustur_DetaySatirOlustur ile olustu) - erteleme gerekmiyor.
            //
            // ESKI CAGRIDA UC ALAN YANLISTI (08.08.2026 tespiti - kullanici
            //   "izlem ekrani bos geldi, lot yazamiyorum" dedi):
            //     1) satir ID'si 0 geciliyordu
            //     2) belge turu/basligi olarak KAYNAK belge veriliyordu
            //        (FATBASTUR / FATBASID) - oysa izlem HEDEF belgeye yazilir
            //     3) kaynak baslik/satir HIC gecilmiyordu
            //   (3) yuzunden ekran donusum listesi yerine BOS giris listesi
            //   aciyordu: tasinacak lotlar gorunmuyor, eklenecek satir da
            //   olmadigi icin hicbir alana yazilamiyordu.
            if not Anaform.StokIzlemeSec(
                                    tabDonusumSepet.FieldByName('URUNID').AsInteger,
                                    tabDonusumSepet.FieldByName('IZLEME').AsInteger,
                                    donusumayarlari.Baslikturu, belgetipi,
                                    SeciliFatID,
                                    faturasatirid,
                                    tabDonusumSepet.FieldByName('REHBERID').AsInteger, GDepo,  CDepo,
                                    miktar, miktar, True,
                                    tabDonusumSepet.FieldByName('FATBASID').AsInteger,
                                    tabDonusumSepet.FieldByName('DETAYSATIRID').AsInteger) then begin
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' DELETE FROM FATURA WHERE ID='+inttostr(faturasatirid),[],[]  );
              Abort;
            end;

          end;
        end;
      end;
    end;
     tabDonusumSepet.Next;
  end;
   mnSil.Click;// işlem tamamlandıktan sonra sepet boşaltılır
   Close;
end;

procedure TFisIrsaliyeAraDlg.SepetiYenile;
begin
 tabDonusumSepet.Close;
 tabDonusumSepet.Open;
end;

procedure TFisIrsaliyeAraDlg.btnTumunuEkleClick(Sender: TObject);
 function SepeteEkle:Integer;
  begin
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text:= 'IF NOT EXISTS (SELECT ID FROM ##SEPET_BELGEDONUSUM WHERE FATBASTUR = '+TabFatBaslik.FieldByName('TUR').AsString+'  '+
                            ' AND DETAYSATIRID = '+TabFatura.FieldByName('ID').AsString+' ) '+
                            ' BEGIN '+
                            ' INSERT INTO ##SEPET_BELGEDONUSUM ( FATBASID, FATBASTUR, FATBASTARIH, GIRISDEPO, CIKISDEPO, FATBASBELGENO, FATBASKDVDURUM, DETAYSATIRID, REHBERID ,TUR, URUNID, '+
                            ' KOD, AD, BIRIM, ADET, MIKTAR, BIRIMFIYAT, ISKONTO, TUTAR, KDV, IZLEME ) '+
                            ' VALUES ('+TabFatBaslik.FieldByName('ID').AsString+','+TabFatBaslik.FieldByName('TUR').AsString+','''+FormatDateTime('yyyy-mm-dd hh:nn',TabFatBaslik.FieldByName('TARIH').AsDateTime)+''', '+
                            ' '+inttostr(TabFatBaslik.FieldByName('GIRISDEPO').AsInteger)+','+inttostr(TabFatBaslik.FieldByName('CIKISDEPO').AsInteger)+', '+
                            ' '''+TabFatBaslik.FieldByName('BELGENO').AsString+''', '''+TabFatBaslik.FieldByName('KDVDURUM').AsString+''',  '+
                            ' '+TabFatura.FieldByName('ID').AsString+', '+ TabFatBaslik.FieldByName('REHBERID').AsString+','+ TabFatura.FieldByName('TUR').AsString+','+
                            ' '+TabFatura.FieldByName('URUNID').AsString+','''+TabFatura.FieldByName('KOD').AsString+''','''+TabFatura.FieldByName('AD').AsString+''' , '+
                            ' '+inttostr(TabFatura.FieldByName('BIRIM').AsInteger)+','+ FloatToStr(TabFatura.FieldByName('BEKLEYENMIKTAR').AsFloat)+', '+
                            ' '+FloatToStr(TabFatura.FieldByName('BEKLEYENMIKTAR').AsFloat)+', CAST ( REPLACE('''+  TabFatura.FieldByName('BIRIMFIYAT').AsString +''','','',''.'') AS MONEY ) , '+
                            ' '+FloatToStr(TabFatura.FieldByName('ISKONTO').AsFloat) +', '+
                            ' '+ ' (100.0-isnull('+TabFatura.FieldByName('ISKONTO2').AsString+',0.0))*(100.0-'+TabFatura.FieldByName('ISKONTO').AsString+')*'+FloatToStr(TabFatura.FieldByName('BEKLEYENMIKTAR').AsFloat)+'*CAST ( REPLACE('''+  TabFatura.FieldByName('BIRIMFIYAT').AsString +''','','',''.'') AS MONEY ) /10000.0, '+
                            ' '+TabFatura.FieldByName('KDV').AsString+' ,'+inttostr(TabFatura.FieldByName('IZLEME').AsInteger)+' '+
                            ' ) '+
                            ' END '+
                            '';
    Tablo.Query5.ExecSQL;

  end;

begin
 if TabFatura.RecordCount<=0 then abort;
//
  TabFatura.First;
  while not TabFatura.Eof do
   begin
     if (clmSec.EditValue='True') or ((Sender as TcxButton)= btnTumunuEkle) then
       begin
         if TabFatura.FieldByName('BEKLEYENMIKTAR').AsFloat>0  then
             SepeteEkle;
       end;
     TabFatura.Next;
   end;
   DetaySatirlariGetir(TabFatBaslik.FieldByName('ID').AsInteger);
   SepetiYenile;
end;

procedure TFisIrsaliyeAraDlg.FormCreate(Sender: TObject);
begin
  //önce temp tabloyu oluşturuyoruz
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text:= MemoSepet.Text;
  Tablo.Query6.Open;

  SepetiYenile;

  dateBaslangic.Date:= Now-30;
  dateBitis.Date:= Now;

end;

procedure TFisIrsaliyeAraDlg.FormShow(Sender: TObject);
begin
  dateBitisPropertiesCloseUp(Self);
end;

procedure TFisIrsaliyeAraDlg.GridFatDBTableView1StylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
 AColumn1 : TcxGridColumn;
 sepetid : Integer;
begin
  AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('SEPETID');

  if (AColumn1 <> nil) then begin
    sepetid:=Sender.DataController.GetValue(ARecord.RecordIndex,AColumn1.Index);
     if sepetid>0 then
       AStyle:= Tablo.cxstSecili;
  end;
end;

procedure TFisIrsaliyeAraDlg.mnSilClick(Sender: TObject);
begin
  if tabDonusumSepet.RecordCount<=0 then abort;
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:=' TRUNCATE TABLE ##SEPET_BELGEDONUSUM ';
  Tablo.Query2.ExecSQL;
  SepetiYenile;
  DetaySatirlariGetir(TabFatBaslik.FieldByName('ID').AsInteger);
end;

procedure TFisIrsaliyeAraDlg.TabFatBaslikAfterOpen(DataSet: TDataSet);
begin
  btnSecilileriEkle.Enabled:= TabFatBaslik.RecordCount>0;
   lblSeciliKayit.Caption:='0';
end;

procedure TFisIrsaliyeAraDlg.TabFatBaslikAfterScroll(DataSet: TDataSet);
begin
  if DetayAktif then
    DetaySatirlariGetir(TabFatBaslik.FieldByName('ID').AsInteger);
end;

procedure TFisIrsaliyeAraDlg.dateBitisPropertiesCloseUp(Sender: TObject);
var
 sipsql, irssql : string;
begin
   sipsql:=
              ' select  F.ID, F.TARIH, F.TUR, F.REHBERID, F.CIKISDEPO, F.GIRISDEPO, F.KDVDURUM, '+
              ' F.SIPARIS_TUTARI AS BELGETUTARI,  F.SIPARISNO AS BELGENO , CARIKOD=R.KOD,CARIAD=R.FIRMA '+
                           '   from   '+
                           '     SIPARIS F (NOLOCK)                       '+
                           '     inner join REHBER R on R.ID = F.REHBERID   '+
                           '   where          '+
                           '   REHBERID = '+IntToStr(FisIrsFirmaId)+' AND     '+
                           '  TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 00:00', dateBaslangic.Date)+''' '+
                           ' AND '''+FormatDateTime('yyyy-mm-dd 23:59',dateBitis.Date)+''' ';

   irssql:= ' select  F.ID, F.TARIH, F.TUR, F.REHBERID, F.CIKISDEPO, F.GIRISDEPO, F.KDVDURUM, '+
            ' F.FATURA_TUTARI AS BELGETUTARI, F.FATURANO AS BELGENO , CARIKOD=R.KOD,CARIAD=R.FIRMA '+
                           '   from   '+
                           '     FATBASLIK F (NOLOCK)                       '+
                           '     inner join REHBER R on R.ID = F.REHBERID   '+
                           '   where          '+
                           ' F.ID <>'+inttostr(SeciliFatID)+ ' AND                  '+
                           '                   REHBERID = '+IntToStr(FisIrsFirmaId)+' AND     '+
                           '                   TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 00:00', dateBaslangic.Date)+''' '+
                           ' AND '''+FormatDateTime('yyyy-mm-dd 23:59',dateBitis.Date)+''' ';
   DetayAktif:=False;

   TabFatBaslik.Close;
   TabFatBaslik.SQL.Text:='';
   case FisIrsTur of
     10 : begin // gelen irsaliye  ise
            TabFatBaslik.SQL.Add(sipsql);
            TabFatBaslik.SQL.Add(' AND TUR = 9 ');
            TabFatBaslik.SQL.Add(' AND GIRISDEPO='+inttostr(SeciliDepoId)+' ');
          end;
     11 : begin // gelen fatura ise
            TabFatBaslik.SQL.Add(sipsql);
            TabFatBaslik.SQL.Add(' AND TUR = 9 ');
            TabFatBaslik.SQL.Add(' AND GIRISDEPO='+inttostr(SeciliDepoId)+' ');
            TabFatBaslik.SQL.Add(' UNION ALL ');
            TabFatBaslik.SQL.Add(irssql);
            TabFatBaslik.SQL.Add(' AND TUR = 10 ');
            TabFatBaslik.SQL.Add(' AND GIRISDEPO='+inttostr(SeciliDepoId)+' ');
          end;

     14 : begin // Giden irsaliye  ise
            TabFatBaslik.SQL.Add(sipsql);
            TabFatBaslik.SQL.Add(' AND TUR = 19 ');
            TabFatBaslik.SQL.Add(' AND CIKISDEPO='+inttostr(SeciliDepoId)+' ');
          end;
     15 : begin // giden fatura ise  giden fiş ve irsaliyeler gelsin
            TabFatBaslik.SQL.Add(sipsql);
            TabFatBaslik.SQL.Add(' AND TUR = 19 ');
            TabFatBaslik.SQL.Add(' AND CIKISDEPO='+inttostr(SeciliDepoId)+' ');
            TabFatBaslik.SQL.Add(' UNION ALL ');
            TabFatBaslik.SQL.Add(irssql);
            TabFatBaslik.SQL.Add(' AND TUR = 14 ');
            TabFatBaslik.SQL.Add(' AND CIKISDEPO='+inttostr(SeciliDepoId)+' ');
          end;
   end;
   TabFatBaslik.Open;
   if TabFatBaslik.RecordCount > 0 then begin
     DetayAktif:=True;
     TabFatBaslikAfterScroll(TabFatBaslik);
     FisIrsVarmi :=True;
   end else begin
     FisIrsVarmi:=False;
   end;

end;

end.



