unit UYilSonuDevirIslemleri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, Menus, cxLookAndFeelPainters,
  StdCtrls, cxButtons, cxControls, cxContainer, cxEdit, cxCheckBox, dxCore,
  cxRadioGroup, ExtCtrls, Utablo, cxLabel, DB, cxTextEdit, cxMaskEdit,
  cxSpinEdit, cxMemo, cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  Vcl.ComCtrls, cxDateUtils, ubekletme, dxSkinLiquidSky, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, FireDAC.Comp.Client;

type
  TYilSonuDevirIslemleriDlg = class(TForm)
    Panel1: TPanel;
    BtnOlustur: TcxButton;
    BtnSil: TcxButton;
    CheckCari: TcxCheckBox;
    CheckKasa: TcxCheckBox;
    CheckBanka: TcxCheckBox;
    CheckPos: TcxCheckBox;
    CheckStok: TcxCheckBox;
    SpinYil: TcxSpinEdit;
    cxLabel1: TcxLabel;
    LbCari: TcxLabel;
    LbKasa: TcxLabel;
    LbBanka: TcxLabel;
    LbPos: TcxLabel;
    LbStok: TcxLabel;
    cxLabel2: TcxLabel;
    DateBaslangic: TcxDateEdit;
    CheckDevirleriAl: TcxCheckBox;
    memoStokDurum: TcxMemo;
    CheckKredi: TcxCheckBox;
    lbKrediler: TcxLabel;
    CheckKrediKartlari: TcxCheckBox;
    LbKK: TcxLabel;
    ButunPersYillikIzinEkle: TcxButton;
    cbIsYapKur: TcxComboBox;
    cxLabel3: TcxLabel;
    checkKurFarki: TcxCheckBox;
    procedure BtnOlusturClick(Sender: TObject);
    procedure IniyeKaydet(Tur,Yil:Integer;Sil,Ekle:Boolean);
    procedure BtnSilClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpinYilPropertiesEditValueChanged(Sender: TObject);
    procedure ButunPersYillikIzinEkleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  YilSonuDevirIslemleriDlg: TYilSonuDevirIslemleriDlg;

implementation

uses
  FetaKurulusSiniflari,DateUtils,UStokListeDlg,PrjConst,LocOnFly, UIKListeDlg, FetaUtil;

{$R *.dfm}

procedure TYilSonuDevirIslemleriDlg.BtnOlusturClick(Sender: TObject);
var
  FatBasID, I:Integer;
  s:string;
  BekletDlg: TBekletmeDlg;
  procedure YeniBaglantiIleKomutCalistir(const ASQL: string);
  begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ASQL, [], [], False, nil);
  end;
  procedure DovizKuru_Guncelle(Tur:char; Doviz:String);
  begin
    s:=Float_ToStr(DovizKuruBul(IntToStr(SpinYil.Value-1)+'-12-31 00:00', Doviz, cbIsYapKur.text));
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update KASA set DOVIZ_KURU='''+CariDoviz+''', DOVIZ_TUTARI=DOVIZ_TUTARI*'+s+
       ' where KUR='''+Doviz+''' and TUR=2 and HESAPTURU= '''+Tur+''' and '+
       ' ISLEMTARIHI between '''+IntToStr(SpinYil.Value-1)+'-12-31'' and '''+IntToStr(SpinYil.Value)+'-01-01''',[],[],False,nil);
  end;
begin

  if BekletDlg <> nil then
     FreeAndNil(BekletDlg);
  Application.CreateForm(TBekletmeDlg, BekletDlg);
  BekletDlg.cxProgressBar1.Position := 0;
  BekletDlg.Caption := 'Yýl sonu devirleri oluþturuluyor. Lütfen Bekleyiniz...';
  BekletDlg.Show;
  if CheckCari.Checked then begin
  //  MemodanSorguCalistir(MemoCariler);

    BekletDlg.cxProgressBar1.Position := ABS(100.0*1/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Cari Kayýtlar Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Devir_Cari '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','''+cbIsYapKur.text+''','+IntToStr(Ord(CheckDevirleriAl.Checked))); 
    IniyeKaydet(CheckCari.Tag,SpinYil.Value,True,True);
    if checkKurFarki.Checked then
      YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Cari_KurFarki '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','''+cbIsYapKur.text+''',1');

  end;
  if CheckKasa.Checked then begin
//    MemodanSorguCalistir(MemoKasalar);
    BekletDlg.cxProgressBar1.Position := ABS(100.0*2/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Kasa Kayýtlarý Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
     YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Devir_Kasa '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','+IntToStr(Ord(CheckDevirleriAl.Checked))); 
     IniyeKaydet(CheckKasa.Tag,SpinYil.Value,True,True);
     for I := 0 to TcxComboBoxProperties(Tablo.cxEditRepository1ComboBoxItemKurlar.Properties).Items.Count-1 do
       if TcxComboBoxProperties(Tablo.cxEditRepository1ComboBoxItemKurlar.Properties).Items[I]<>CariDoviz then
          DovizKuru_Guncelle('K', TcxComboBoxProperties(Tablo.cxEditRepository1ComboBoxItemKurlar.Properties).Items[I]);
  end;
  if CheckBanka.Checked then begin
//     MemodanSorguCalistir(MemoBankalar);
    BekletDlg.cxProgressBar1.Position := ABS(100.0*3/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Banka Kayýtlarý Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
     YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Devir_Banka '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','+IntToStr(Ord(CheckDevirleriAl.Checked))); 
     IniyeKaydet(CheckBanka.Tag, SpinYil.Value, True, True);
     for I := 0 to TcxComboBoxProperties(Tablo.cxEditRepository1ComboBoxItemKurlar.Properties).Items.Count-1 do
      if TcxComboBoxProperties(Tablo.cxEditRepository1ComboBoxItemKurlar.Properties).Items[I]<>CariDoviz then
         DovizKuru_Guncelle('B', TcxComboBoxProperties(Tablo.cxEditRepository1ComboBoxItemKurlar.Properties).Items[I]);
  end;
  if CheckKredi.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*4/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Kredi Kayýtlarý Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
//     MemodanSorguCalistir(MemoKrediler);
     YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Devir_Kredi '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','+IntToStr(Ord(CheckDevirleriAl.Checked))); 
     IniyeKaydet(CheckKredi.Tag, SpinYil.Value, True, True);
  end;
  if CheckPos.Checked then begin

    BekletDlg.cxProgressBar1.Position := ABS(100.0*5/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Pos Kayýtlarý Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
//     MemodanSorguCalistir(MemoPOS);
     YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Devir_POS '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','+IntToStr(Ord(CheckDevirleriAl.Checked))); 
     IniyeKaydet(CheckPos.Tag, SpinYil.Value, True, True);
  end;
   if CheckKrediKartlari.Checked then begin

    BekletDlg.cxProgressBar1.Position := ABS(100.0*6/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Kredi Kartý Kayýtlarý Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
     //MemodanSorguCalistir(MemoKrediKartlari);
     YeniBaglantiIleKomutCalistir('EXEC Sp_Prg_Devir_KK '''+FormatDateTime('yyyy-mm-dd', DateBaslangic.EditValue)+''', '+IntToStr(SpinYil.EditValue)+
       ','''+CariDoviz+''','+IntToStr(Ord(CheckDevirleriAl.Checked))); 
     IniyeKaydet(CheckKrediKartlari.Tag, SpinYil.Value, True, True);
  end;

  if CheckStok.Checked then begin

    BekletDlg.cxProgressBar1.Position := ABS(100.0*7/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Stok Kayýtlarý Oluþturuluyor.. ';
    BekletDlg.LabelUstTaraf.Update;
     //Önce Triggerlarý disable edelim
     YeniBaglantiIleKomutCalistir('disable TRIGGER [dbo].[TG_StokDurumGuncelle] on [dbo].[FATURA] ');
     YeniBaglantiIleKomutCalistir('disable TRIGGER [dbo].[TG_StokFiyatGuncelle] on [dbo].[FATURA] ');

   //Önce geçen seneye göre (31/12 ye göre) stok durumlarýný alalým
   YeniBaglantiIleKomutCalistir('truncate table STOKDURUM ');
   YeniBaglantiIleKomutCalistir('EXEC SP_Prg_GenelStokDuruMGuncelle 0,'''+IntToStr(SpinYil.value-1)+'-01-01 00:00'','''+IntToStr(SpinYil.value-1)+'-12-31 23:59'' ');


    //Tablo.TumStokDurumlariGuncelle;
    Tablo.TablodanSorguAc(1,'select * from DEPOLAR where DURUM=1');
    Tablo.Query1.FetchAll;
    while not Tablo.Query1.Eof do begin

      BekletDlg.cxProgressBar1.Position := ABS(100.0*((7/8)+((1/8)*(Tablo.Query1.RecNo/Tablo.Query1.RecordCount))));
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := Tablo.Query1.FieldByName('DEPOADI').AsString + ' için Kayýtlar Oluþturuluyor..';
      BekletDlg.LabelUstTaraf.Update;

      Tablo.TablodanSorguAc(2,'INSERT INTO FATBASLIK (TARIH,FATURATARIH,TUR,TIPI,REHBERID,CIKISDEPO,EKLEYEN ) '
                             +' VALUES (''' //önce çýkýþ faturasý oluþturulur..
                             +IntToStr(SpinYil.EditValue-1)+'-12-31 23:59'','''
                             +IntToStr(SpinYil.EditValue-1)+'-12-31 23:59'',2,1,-1,'
                             +Tablo.Query1.FieldByName('ID').AsString+','+Kullanan+') '
                             +'SELECT SCOPE_IDENTITY()');
      Tablo.TablodanSorguAc(3,'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KDV,IZLEME,KUR,EKLEYEN) '
                             +'select '+Tablo.Query2.Fields[0].AsString
                             +',-1,1,S.ID,''Devir'',SD.KALAN,S.ANABIRIM,SD.KALAN,0,0,S.KDV,S.IZLEME,'''
                             +CariDoviz+''','+Kullanan
                             //+' from STOKLAR S inner join ('+StringReplace(memoStokDurum.Lines.Text,'@Yil',SpinYil.Text,[rfReplaceAll])+')as SD on S.ID=SD.URUNID '
                             +' from STOKLAR S inner join STOKDURUM SD on S.ID=SD.STOKID '
                             +' where SD.DEPOID='+Tablo.Query1.FieldByName('ID').AsString
                             +'SELECT SCOPE_IDENTITY()');
      Tablo.TablodanSorguAc(2,'INSERT INTO FATBASLIK (TARIH,FATURATARIH,TUR,TIPI,REHBERID,GIRISDEPO,EKLEYEN ) '
                             +' VALUES (''' //sonra giriþ faturasý oluþturulur..
                             +IntToStr(SpinYil.EditValue)+'-01-01 00:00'','''
                             +IntToStr(SpinYil.EditValue)+'-01-01 00:00'',2,1,-1,'
                             +Tablo.Query1.FieldByName('ID').AsString+','+Kullanan+') '
                             +'SELECT SCOPE_IDENTITY()');
      Tablo.TablodanSorguAc(3,'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KDV,IZLEME,KUR,EKLEYEN) '
                             +'select '+Tablo.Query2.Fields[0].AsString
                             +',-1,1,S.ID,''Devir'',SD.KALAN,S.ANABIRIM,SD.KALAN,0,0,S.KDV,S.IZLEME,'''
                             +CariDoviz+''','+Kullanan
                             //+' from STOKLAR S inner join ('+StringReplace(memoStokDurum.Lines.Text,'@Yil',SpinYil.Text,[rfReplaceAll])+')as SD on S.ID=SD.URUNID '
                             +' from STOKLAR S inner join STOKDURUM SD on S.ID=SD.STOKID '
                             +' where SD.DEPOID='+Tablo.Query1.FieldByName('ID').AsString
                             +' SELECT SCOPE_IDENTITY()');
      Tablo.Query1.Next;
    end;
    //þimdi yeni seneye göre (01/01 den) stok durumlarýný alalým

    BekletDlg.cxProgressBar1.Position := 100;
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Ýþlem Sonlandýrýlýyor..';
    BekletDlg.LabelUstTaraf.Update;

    YeniBaglantiIleKomutCalistir('truncate table STOKDURUM ');
    YeniBaglantiIleKomutCalistir('EXEC SP_Prg_GenelStokDuruMGuncelle 0,'''+IntToStr(SpinYil.value)+'-01-01 00:00'','''+IntToStr(SpinYil.value)+'-12-31 23:59'' ');

     YeniBaglantiIleKomutCalistir('enable TRIGGER [dbo].[TG_StokDurumGuncelle] on [dbo].[FATURA] ');
     YeniBaglantiIleKomutCalistir('enable TRIGGER [dbo].[TG_StokFiyatGuncelle] on [dbo].[FATURA] ');
    IniyeKaydet(CheckStok.Tag,SpinYil.Value,True,True);
  end;
  ShowMessage(Devir_gerceklesti);

  if BekletDlg <> nil then
    FreeAndNil(BekletDlg);
  ModalResult :=  mrOk;
end;

procedure TYilSonuDevirIslemleriDlg.BtnSilClick(Sender: TObject);
var
  BasTar,BitTar:string;
  BekletDlg: TBekletmeDlg;
begin
  if BekletDlg <> nil then
     FreeAndNil(BekletDlg);
  Application.CreateForm(TBekletmeDlg, BekletDlg);
  BekletDlg.cxProgressBar1.Position := 0;
  BekletDlg.Caption := 'Yýl sonu devirleri siliniyor. Lütfen Bekleyiniz...';
  BekletDlg.Show;

  BasTar := IntToStr(SpinYil.Value-1)+'-12-31 23:59:00';
  BitTar := IntToStr(SpinYil.Value)  +'-01-01 00:00:02';
  if CheckCari.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*1/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Cari Kayýtlar Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR=2 and HESAPTURU='''' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);
    IniyeKaydet(CheckCari.Tag,SpinYil.Value,True,False);
    if checkKurFarki.Checked then
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR in (88,98) and HESAPTURU='''' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);


  end;
  if CheckKasa.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*2/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Kasa Kayýtlarý Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR=2 and HESAPTURU=''K'' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);
    IniyeKaydet(CheckKasa.Tag,SpinYil.Value,True,False);
  end;
  if CheckBanka.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*3/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Banka Kayýtlarý Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR=2 and HESAPTURU=''B'' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);
    IniyeKaydet(CheckBanka.Tag,SpinYil.Value,True,False);
  end;
  if CheckKredi.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*4/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Kredi Kayýtlarý Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR=2 and HESAPTURU=''R'' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);
    IniyeKaydet(CheckKredi.Tag,SpinYil.Value,True,False);
  end;
  if CheckPos.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*5/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Pos Kayýtlarý Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR=2 and HESAPTURU = ''P'' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);
    IniyeKaydet(CheckPos.Tag,SpinYil.Value,True,False);
  end;
  if CheckKrediKartlari.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*6/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Kredi Kayýtlarý Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from KASA where TUR=2 and HESAPTURU = ''V'' and ISLEMTARIHI between &BasTar and &BitTar ',['&BasTar','&BitTar'],[BasTar,BitTar]);
    IniyeKaydet(CheckKrediKartlari.Tag,SpinYil.Value,True,False);
  end;
  if CheckStok.Checked then begin
    BekletDlg.cxProgressBar1.Position := ABS(100.0*7/8);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Stok Kayýtlarý Siliniyor.. ';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'disable TRIGGER [dbo].[TG_StokDurumGuncelle] on [dbo].[FATURA] ',[],[]);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'disable TRIGGER [dbo].[TG_StokFiyatGuncelle] on [dbo].[FATURA] ',[],[]);
    Tablo.TablodanSorguAc(1,' select * from FATBASLIK where TUR=2 and TARIH between '''+BasTar+''' and '''+BitTar+''' ');
    Tablo.Query1.FetchAll;

    while not Tablo.Query1.IsEmpty do begin
      BekletDlg.cxProgressBar1.Position := ABS(100.0*((7/8)+((1/8)*(Tablo.Query1.RecNo/Tablo.Query1.RecordCount))));
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := 'Stok Depo No:'+IntToStr(Tablo.Query1.RecNo)+'/'+IntToStr(Tablo.Query1.RecordCount);
      BekletDlg.LabelUstTaraf.Update;
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from FATURA where FATBASID=&FatBasID ',['&FatBasID'],[Tablo.Query1.Fields[0].AsInteger]);
      Tablo.Query1.Delete;
    end;
    //Tablo.TumStokDurumlariGuncelle;
    IniyeKaydet(CheckStok.Tag,SpinYil.Value,True,False);
    BekletDlg.cxProgressBar1.Position := 100;
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Ýþlem Sonlandýrýlýyor..';
    BekletDlg.LabelUstTaraf.Update;
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'enable TRIGGER [dbo].[TG_StokDurumGuncelle] on [dbo].[FATURA] ',[],[]);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'enable TRIGGER [dbo].[TG_StokFiyatGuncelle] on [dbo].[FATURA] ',[],[]);
  end;

  if BekletDlg <> nil then
    FreeAndNil(BekletDlg);
  ShowMessage(Devir_silindi);
  ModalResult := mrOk;
end;

procedure TYilSonuDevirIslemleriDlg.ButunPersYillikIzinEkleClick(Sender: TObject);
begin
   ButunPersonelinHakedilenIzinleriniEkle;
end;

procedure TYilSonuDevirIslemleriDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  SpinYil.Value := YearOf(Tablo.GENINI.BugunTrh);
  DateBaslangic.EditValue := StartOfTheYear(IncYear(Tablo.GENINI.BugunTrh,-1));
end;

procedure TYilSonuDevirIslemleriDlg.IniyeKaydet(Tur,Yil:Integer;Sil,Ekle:Boolean);
begin
  if Sil then
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Ops_DevirIslemleri)+' and ANAHTAR='''+IntToStr(Tur)+''' and DEGER='''+IntToStr(Yil)+''' ',[],[]);
  if Ekle then
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL) VALUES('+IntToStr(Ops_DevirIslemleri)+','''+IntToStr(Tur)+''','''+IntToStr(Yil)+''','''+IntToStr(Tur)+''') ',[],[]);
End;

procedure TYilSonuDevirIslemleriDlg.SpinYilPropertiesEditValueChanged(
  Sender: TObject);
begin
  Tablo.TablodanSorguAc(2,'select * from GENINI where BOLUM='+IntToStr(Ops_DevirIslemleri)+' and DEGER='''+IntToStr(SpinYil.EditValue)+''' ');   // BOLUM= Devir Ýþlemleri
  LbCari.Visible := Tablo.Query2.Locate('ANAHTAR',CheckCari.Tag,[]);
  LbKasa.Visible := Tablo.Query2.Locate('ANAHTAR',CheckKasa.Tag,[]);
  LbBanka.Visible := Tablo.Query2.Locate('ANAHTAR',CheckBanka.Tag,[]);
  LbPos.Visible := Tablo.Query2.Locate('ANAHTAR',CheckPos.Tag,[]);
  LbKK.Visible := Tablo.Query2.Locate('ANAHTAR',CheckKrediKartlari.Tag,[]);
  LbStok.Visible := Tablo.Query2.Locate('ANAHTAR',CheckStok.Tag,[]);
  LbKrediler.Visible := Tablo.Query2.Locate('ANAHTAR',CheckKredi.Tag,[]);
  DateBaslangic.EditValue := StartOfTheYear(RecodeYear(Tablo.GENINI.BugunTrh,SpinYil.EditValue-1));

end;

end.













