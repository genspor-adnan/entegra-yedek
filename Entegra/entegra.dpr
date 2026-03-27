program Entegra;

{$R *.dres}

uses
  Shellapi,
  LocUtils,
  Forms,
  sysutils,
  WinTypes,
  USabitler,
  cxFormats,
  Umesaj in '..\Ortak\Umesaj.pas' {MesajForm},
  UDokum in '..\Ortak\UDokum.pas' {DokumDlg},
  Fetautil in '..\Ortak\Fetautil.pas',
  UCombo in '..\Ortak\UCombo.pas' {ListeAyarlaDlg},
  Uliste in '..\Ortak\Uliste.pas' {ListeDlg},
  UGrid in '..\Ortak\UGrid.pas' {GridAyarlaDlg},
  UPrinter in '..\Ortak\UPrinter.pas' {PrinterDlg},
  UPaylasim in '..\Ortak\UPaylasim.pas',
  ULisans in '..\Ortak\ULisans.pas' {LisansDlg},
  UKasa in 'IcerikFrame\UKasa.pas' {KasaDlg},
  ULOGO in 'ULOGO.PAS' {Logo},
  UOPSDLG in 'UOPSDLG.pas' {OpsiyonDlg},
  UlisteCheck in '..\ortak\UlisteCheck.pas' {ListeCheckDlg},
  UVersiyon in 'UVersiyon.pas' {VersiyonDlg},
  UKrediNotlar in 'UKrediNotlar.pas' {KrediNotlarDlg},
  UVadesiGelmisler in 'UVadesiGelmisler.pas' {VadesiGelmislerDlg},
  UCekSenetArama in 'UCekSenetArama.pas' {CekSenetAramaDlg},
  UQuantGrid in '..\Ortak\UQuantGrid.pas' {QuantGrid: TDataModule},
  UDoviz in 'UDoviz.pas' {DovizDlg},
  USMS in '..\Ortak\USMS.pas' {SmsDlg},
  UMailYaz in 'UMailYaz.pas' {MailGonderDlg},
  lisansws in 'lisansws.pas',
  UCxUtils in '..\Ortak\UCxUtils.pas' {cxUtils: TDataModule},
  UCekListe in 'UCekListe.pas' {CekListeDlg},
  UDegerAra in 'UDegerAra.pas' {DegerAraDlg},
  UTakvim in 'IcerikFrame\UTakvim.pas' {TakvimDlg},
  UKrediEkle in 'UKrediEkle.pas' {KrediEkleDlg},
  UGunlukTakvim in 'UGunlukTakvim.pas' {GunlukTakvimDlg},
  UTakvimOnay in 'UTakvimOnay.pas' {TakvimOnayDlg},
  UOlaylar in 'UOlaylar.pas' {OlaylarDlg},
  UMaasTablo in 'IcerikFrame\UMaasTablo.pas' {MaasTabloDlg},
  UKrediler in 'IcerikFrame\UKrediler.pas' {KredilerDlg},
  UTeminatMektubu in 'IcerikFrame\UTeminatMektubu.pas' {TeminatMektubuDlg},
  UFrameYoneticisi in '..\Ortak\UFrameYoneticisi.pas',
  FetaKurulusSiniflari in '..\Ortak\FetaKurulusSiniflari.pas',
  FetaClassExtensions in '..\Ortak\FetaClassExtensions.pas',
  FetaClassExtensionsConsts in '..\Ortak\FetaClassExtensionsConsts.pas',
  UMultiCastEvent in '..\Ortak\UMultiCastEvent.pas',
  UGenelAnaSekmeFrame in 'AnaFrame\UGenelAnaSekmeFrame.pas' {GenelAnaSekmeFrame: TFrame},
  UReharadlg in 'IcerikFrame\UReharadlg.pas' {RehberAraDlg: TFrame},
  uMultDsEvent in '..\Ortak\uMultDsEvent.pas',
  UMultiDataSetEvent in 'UMultiDataSetEvent.pas',
  URehberAramaFrame in 'AramaFrame\URehberAramaFrame.pas' {RehberAramaFrame: TFrame},
  UAramaYokFrame in 'AramaFrame\UAramaYokFrame.pas' {AramaYokFrame: TFrame},
  //UCariDlgGenelAramaFrame in 'AramaFrame\UCariDlgGenelAramaFrame.pas' {CariDlgGenelAramaFrame: TFrame},
  UBankalarAramaFrame in 'AramaFrame\UBankalarAramaFrame.pas' {BankalarAramaFrame: TFrame},
  UBankaKredileriAramaFrame in 'AramaFrame\UBankaKredileriAramaFrame.pas' {BankaKredileriAramaFrame: TFrame},
  UTeminatMektubuAramaFrame in 'AramaFrame\UTeminatMektubuAramaFrame.pas' {TeminatMektubuAramaFrame: TFrame},
  UVadeliHesapAramaFrame in 'AramaFrame\UVadeliHesapAramaFrame.pas' {VadeliHesapAramaFrame: TFrame},
  UBankaCekleriAramaFrame in 'AramaFrame\UBankaCekleriAramaFrame.pas' {BankaCekleriAramaFrame: TFrame},
  UFaturalarAramaFrame in 'AramaFrame\UFaturalarAramaFrame.pas' {FaturalarAramaFrame: TFrame},
  UGunlukAksiyonAramaFrame in 'AramaFrame\UGunlukAksiyonAramaFrame.pas' {GunlukAksiyonAramaFrame: TFrame},
  UGenelGirisSayfasiFrame in 'GirisSayfaFrame\UGenelGirisSayfasiFrame.pas' {GenelGirisSayfasiFrame: TFrame},
  UBankaKredileriListeFrame in 'ListeFrame\UBankaKredileriListeFrame.pas' {BankaKredileriListeFrame: TFrame},
  UTeminatMektuplariListeFrame in 'ListeFrame\UTeminatMektuplariListeFrame.pas' {TeminatMektuplariListeFrame: TFrame},
  UVadeliHesaplarListeFrame in 'ListeFrame\UVadeliHesaplarListeFrame.pas' {VadeliHesaplarListeFrame: TFrame},
  UBankaCekleriListeFrame in 'ListeFrame\UBankaCekleriListeFrame.pas' {BankaCekleriListeFrame: TFrame},
  UAnaGirisSayfasiFrame in 'GirisSayfaFrame\UAnaGirisSayfasiFrame.pas' {AnaGirisSayfasiFrame: TFrame},
  UFastRap in '..\Ortak\UFastRap.pas' {FastRaporDlg},
  //UCariKartAksiyonFrame in 'AramaFrame\UCariKartAksiyonFrame.pas' {CariKartAksiyonFrame: TFrame},
  UTakvimAksiyonFrame in 'AramaFrame\UTakvimAksiyonFrame.pas' {TakvimAksiyonFrame: TFrame},
  UDokumGirisFrame in 'GirisSayfaFrame\UDokumGirisFrame.pas' {DokumGirisFrame: TFrame},
  UDokumlerAksiyonFrame in 'AramaFrame\UDokumlerAksiyonFrame.pas' {DokumlerAksiyonFrame: TFrame},
  UGentegreFrameYonetimi in 'UGentegreFrameYonetimi.pas',
  UAksiyonlarGorevFrame in 'GorevFrame\UAksiyonlarGorevFrame.pas' {AksiyonlarGorevFrame: TFrame},
  UBankaGorevFrame in 'GorevFrame\UBankaGorevFrame.pas' {BankaGorevFrame: TFrame},
  UCariGorevFrame in 'GorevFrame\UCariGorevFrame.pas' {CariGorevFrame: TFrame},
  UCekSenetGorevFrame in 'GorevFrame\UCekSenetGorevFrame.pas' {CekSenetGorevFrame: TFrame},
  UFaturaGorevFrame in 'GorevFrame\UFaturaGorevFrame.pas' {FaturaGorevFrame: TFrame},
  UKasaGorevFrame in 'GorevFrame\UKasaGorevFrame.pas' {KasaGorevFrame: TFrame},
  URaporAraclari in 'URaporAraclari.pas',
  UGirisKutusuEx in '..\Ortak\UGirisKutusuEx.pas' {GirisKutusuEx},
  UCekRiskPayi in 'UCekRiskPayi.pas' {CekRiskPayiDlg},
  UDBSListeFrame in 'UDBSListeFrame.pas' {DBSListeFrame: TFrame},
  UDBSAramaFrame in 'UDBSAramaFrame.pas' {DBSAramaFrame: TFrame},
  UDBS in 'UDBS.pas' {DBSDlg: TFrame},
  UBankalarListeFrame in 'UBankalarListeFrame.pas' {BankalarListeFrame: TFrame},
  UKasalarListeFrame in 'UKasalarListeFrame.pas' {KasalarListeFrame: TFrame},
  UKasalarAramaFrame in 'UKasalarAramaFrame.pas' {KasalarAramaFrame: TFrame},
  UMasrafGelir in 'UMasrafGelir.pas' {MasrafGelirDlg: TFrame},
  UBankalarAksiyonFrame in 'UBankalarAksiyonFrame.pas' {BankalarAksiyonFrame: TFrame},
  UKasalarAksiyonFrame in 'UKasalarAksiyonFrame.pas' {KasalarAksiyonFrame: TFrame},
  Notlar in 'Notlar.pas',
  UBankaSecimi in 'UBankaSecimi.pas' {BankaSecimDlg},
  UAcilisKaydi in 'UAcilisKaydi.pas' {AcilisKaydiDlg},
  UVadeliHesap in 'IcerikFrame\UVadeliHesap.pas' {VadeliHesapDlg: TFrame},
  GT_RehberAbout in 'GT_RehberAbout.pas' {AboutBox},
  UDokumAramaFrame in 'AramaFrame\UDokumAramaFrame.pas' {DokumAramaFrame: TFrame},
  PrjConst in 'PrjConst.pas',
  UBinarySave in '..\Ortak\UBinarySave.pas',
  Banka_TEB in 'Bankalar\Banka_TEB.pas',
  UHavaleEFT in 'UHavaleEFT.pas' {HavaleEFTEkrani},
  Banka_Garanti in 'Bankalar\Banka_Garanti.pas',
  UTakvimIslemleri in 'UTakvimIslemleri.pas',
  UBelgeIslemleri in 'UBelgeIslemleri.pas' {BelgeIslemleriDlg},
  UKasaWizard in 'UKasaWizard.pas' {KasaWizardDlg},
  UFtpBilgileri in 'Bankalar\UFtpBilgileri.pas' {BankaFTPBilgileriDLG},
  UHesapPlani in 'UHesapPlani.pas' {HesapPlaniDlg},
  UResim in 'UResim.pas' {ResimDlg},
  URehberAyar in 'URehberAyar.pas' {RehberAyarDlg},
  UPOSListeFrame in 'UPOSListeFrame.pas' {POSListeFrame: TFrame},
  UKrediKartiListeFrame in 'UKrediKartiListeFrame.pas' {KrediKartiListeFrame: TFrame},
  UKrediKarti in 'UKrediKarti.pas' {KrediKarti: TFrame},
  UPOS in 'UPOS.pas' {POS: TFrame},
  UTakvimBankaParaTransfer in 'UTakvimBankaParaTransfer.pas' {TakvimBankaParaTransferDLG},
  UGirdi in '..\Ortak\UGirdi.pas' {GirdiAyarlaDlg},
  UTakvimAcilisKaydi in 'UTakvimAcilisKaydi.pas' {Form1},
  UHesapKoduPicker in 'UHesapKoduPicker.pas' {HesapKoduPicker},
  UCekKocanWizard in 'UCekKocanWizard.pas' {CekKocanDlg},
  UCekListeFrame in 'ListeFrame\UCekListeFrame.pas' {CekSenetListeFrame: TFrame},
  USenetListeFrame in 'ListeFrame\USenetListeFrame.pas' {SenetListeFrame: TFrame},
  UCekAramaFrame in 'AramaFrame\UCekAramaFrame.pas' {CekAramaFrame: TFrame},
  USenetAramaFrame in 'AramaFrame\USenetAramaFrame.pas' {SenetAramaFrame},
  UKullaniciYetki in 'UKullaniciYetki.pas' {KullaniciYetkiDlg},
  Banka_ING in 'Bankalar\Banka_ING.pas',
  UTabloGiris in '..\Ortak\UTabloGiris.pas' {TabloGirisDlg},
  UTakvimVirman in 'UTakvimVirman.pas' {TakvimVirmanDlg},
  UParaDegisiklik in 'UParaDegisiklik.pas' {ParaDegisiklikDlg},
  UReplikasyon in 'UReplikasyon.pas' {ReplikasyonDlg},
  UTakvimKKEkstresi in 'UTakvimKKEkstresi.pas' {TakvimKKEkstresiDlg},
  UTakvimGenelHareket in 'UTakvimGenelHareket.pas' {TakvimGenelHareketDlg},
  UTakvimSenet in 'UTakvimSenet.pas' {TakvimSenetDlg},
  UAktiviteWizard in 'UAktiviteWizard.pas' {AktiviteWizardDlg},
  UOpsiyonCari in 'UOpsiyonCari.pas' {OpsiyonCariDlg},
  UTakvimAktivite in 'IcerikFrame\UTakvimAktivite.pas' {TakvimAktivite: TFrame},
  UTakvimAktiviteAramaFrame in 'AramaFrame\UTakvimAktiviteAramaFrame.pas',
  UGorevListeAramaFrame in 'AramaFrame\UGorevListeAramaFrame.pas' {GorevListeAramaFrame: TFrame},
  UGorevTakvimAramaFrame in 'AramaFrame\UGorevTakvimAramaFrame.pas' {GorevTakvimAramaFrame: TFrame},
  UGorevTakvimDlg in 'IcerikFrame\UGorevTakvimDlg.pas' {GorevTakvimDlg: TFrame},
  UGorevListeDlg in 'ListeFrame\UGorevListeDlg.pas' {GorevListeDlg: TFrame},
  UGorevWizard in 'UGorevWizard.pas' {GorevWizardDlg},
  UAktiviteListeDlg in 'ListeFrame\UAktiviteListeDlg.pas' {AktiviteListeDlg: TFrame},
  UAktiviteListeAramaFrame in 'ListeFrame\UAktiviteListeAramaFrame.pas' {AktiviteListeAramaFrame: TFrame},
  UOpsiyonAksiyon in 'UOpsiyonAksiyon.pas' {OpsiyonAksiyonDlg},
  UStokAksiyonFrame in 'AramaFrame\UStokAksiyonFrame.pas' {StokAksiyonFrame: TFrame},
  UStokAramaFrame in 'AramaFrame\UStokAramaFrame.pas' {StokAramaFrame: TFrame},
  UTeklifAksiyonFrame in 'AramaFrame\UTeklifAksiyonFrame.pas' {TeklifAksiyonFrame: TFrame},
  UTeklifAramaFrame in 'AramaFrame\UTeklifAramaFrame.pas' {TeklifAramaFrame: TFrame},
  UStokListeDlg in 'ListeFrame\UStokListeDlg.pas' {StokListeDlg: TFrame},
  UTeklifListeDlg in 'ListeFrame\UTeklifListeDlg.pas' {TeklifListeDlg: TFrame},
  UStokGorevFrame in 'GorevFrame\UStokGorevFrame.pas' {StokGorevFrame: TFrame},
  UTeklifGorevFrame in 'GorevFrame\UTeklifGorevFrame.pas' {TeklifGorevFrame: TFrame},
  UStokWizard in 'UStokWizard.pas' {StokWizardDlg},
  UOpsiyonStok in 'UOpsiyonStok.pas' {OpsiyonStokDlg},
  UProjeListeAramaFrame in 'ListeFrame\UProjeListeAramaFrame.pas' {ProjeListeAramaFrame: TFrame},
  UProjeListeDlg in 'ListeFrame\UProjeListeDlg.pas' {ProjeListeDlg: TFrame},
  UTakvimProje in 'IcerikFrame\UTakvimProje.pas' {TakvimProje: TFrame},
  UTakvimProjeAramaFrame in 'AramaFrame\UTakvimProjeAramaFrame.pas' {TakvimProjeAramaFrame: TFrame},
  UTeklifWizard in 'UTeklifWizard.pas' {TeklifWizardDlg},
  UOpsiyonTeklif in 'UOpsiyonTeklif.pas' {OpsiyonTeklifDlg},
  UOpsiyonFatura in 'UOpsiyonFatura.pas' {OpsiyonFaturaDlg},
  URehberWizard in 'URehberWizard.pas' {RehberWizardDlg},
  UCariFonksiyonlar in 'UCariFonksiyonlar.pas',
  UFaturalar in 'IcerikFrame\UFaturalar.pas' {FaturalarDlg: TFrame},
  UFaturaWizard in 'UFaturaWizard.pas' {FaturaWizardDlg},
  UTablodanDuzenle in 'UTablodanDuzenle.pas' {TablodanDuzenleDlg},
  UProjeWizard in 'UProjeWizard.pas' {ProjeWizardDlg},
  UKasaTanimWizard in 'UKasaTanimWizard.pas' {KasaTanimWizardDlg},
  UBankaTanimWizard in 'UBankaTanimWizard.pas' {BankaTanimWizardDlg},
  UAlarm in 'UAlarm.pas' {AlarmDlg},
  UFaturaTransferListe in 'IcerikFrame\UFaturaTransferListe.pas' {FatTransferListeDlg: TFrame},
  UFatTransferWizard in 'UFatTransferWizard.pas' {FatTransferWizardDlg},
  UFatTransferAramaFrame in 'AramaFrame\UFatTransferAramaFrame.pas' {FatTransferAramaFrame: TFrame},
  UComboImgDuzenle in '..\Ortak\UComboImgDuzenle.pas' {ImgListeAyarlaDlg},
  Usifre in 'Usifre.pas' {PasswordDlg},
  UKullaniciDuzenle in 'UKullaniciDuzenle.pas' {KullaniciDuzenleDlg},
  UStokSayim in 'UStokSayim.pas' {StokSayimDlg},
  UOpsiyonCekSenet in 'UOpsiyonCekSenet.pas' {OpsiyonCekSenetDlg},
  UBankaCekiWizard in 'UBankaCekiWizard.pas' {BankaCekleriWizardDlg},
  UTalimatWizard in 'UTalimatWizard.pas' {TalimatWizardDlg},
  UTalimatlarListeFrame in 'IcerikFrame\UTalimatlarListeFrame.pas' {TalimatlarListeFrame: TFrame},
  UTalimatAramaFrame in 'AramaFrame\UTalimatAramaFrame.pas' {TalimatAramaFrame: TFrame},
  EntegraActivityAutomationService1 in 'EntegraActivityAutomationService1.pas',
  UCekWizard in 'UCekWizard.pas' {CekWizardDlg},
  UMakbuzWizard in 'UMakbuzWizard.pas' {MakbuzWizardDlg},
  UNakitDlg in 'UNakitDlg.pas' {NakitDlg},
  UVersiyonGuncelle in 'UVersiyonGuncelle.pas',
  UServisAramaFrame in 'AramaFrame\UServisAramaFrame.pas' {ServisAramaFrame: TFrame},
  UServisGorevFrame in 'GorevFrame\UServisGorevFrame.pas' {ServisGorevFrame: TFrame},
  UServisDlg in 'IcerikFrame\UServisDlg.pas' {ServisDlg: TFrame},
  UServisListeDlg in 'ListeFrame\UServisListeDlg.pas' {ServisListeDlg: TFrame},
  USecForm in 'USecForm.pas' {SecimDlg},
  UServisWizard in 'UServisWizard.pas' {ServisWizardDlg},
  URehberAramaEkrani in 'URehberAramaEkrani.pas' {RehberAramaEkrani},
  UDemirbasAramaFrame in 'AramaFrame\UDemirbasAramaFrame.pas' {DemirbasAramaFrame: TFrame},
  UDemirbasListeDlg in 'ListeFrame\UDemirbasListeDlg.pas' {DemirbasListeDlg: TFrame},
  UDemirbasGorevFrame in 'GorevFrame\UDemirbasGorevFrame.pas' {DemirbasGorevFrame: TFrame},
  UDemirbasWizard in 'UDemirbasWizard.pas' {DemirbasWizardDlg},
  UAnaForm in 'UAnaForm.pas' {AnaForm},
  Utablo in 'Utablo.pas' {Tablo: TDataModule},
  UKrediHesapMakineDlg in 'UKrediHesapMakineDlg.pas' {KrediHesapMakineDlg},
  UDemirbasTamirServis in 'UDemirbasTamirServis.pas' {DemirbasTamirServisDLG},
  UDemirbasSigorta in 'UDemirbasSigorta.pas' {DemirbasSigortaDLG},
  UDemirbasHareket in 'UDemirbasHareket.pas' {DemirbasHareketDlg},
  UKodAgaci in 'UKodAgaci.pas' {KodAgaciDlg},
  UMailDokum in 'UMailDokum.pas' {MailDokumDlg},
  UYedekCalistir in 'UYedekCalistir.pas' {YedekCalistirDlg},
  UBekletme in 'UBekletme.pas' {BekletmeDlg},
  USeyirDefteri in 'USeyirDefteri.pas' {SeyirDefteriDlg},
  INGBankBordro_TLB in 'nys\INGBankBordro_TLB.pas',
  MSS_Sender in 'MSS_Sender.pas',
  TEB_Encrypter_TLB in 'TEBEncrypter\TEB_Encrypter_TLB.pas',
  UTahakkukDlg in 'UTahakkukDlg.pas' {TahakkukDlg},
  UHizmetAra in 'UHizmetAra.pas' {HizmetAraDlg},
  USerinoTakip in 'USerinoTakip.pas' {SeriNoDlg},
  UHesapHareketleri in 'UHesapHareketleri.pas' {HesapHareketleriDlg},
  INGEkstreWebService in 'Bankalar\INGEkstreWebService.pas',
  UAktiviteSablonWizard in 'UAktiviteSablonWizard.pas' {AktiviteSablonWizardDlg},
  UDokumSart in 'IcerikFrame\UDokumSart.pas' {DokumSartDlg},
  UOpsiyonBanka in 'UOpsiyonBanka.pas' {OpsiyonBankaDlg},
  USiparisWizard in 'USiparisWizard.pas' {SiparisWizardDlg},
  UFiyatDegisiklik in 'UFiyatDegisiklik.pas' {FiyatDegisiklikDlg},
  TEBEkstreWebServices in 'Bankalar\TEBEkstreWebServices.pas',
  UHizliGiris in 'UHizliGiris.pas' {HizliGirisDlg},
  UHizliGirisArama in 'UHizliGirisArama.pas' {HizliGirisArama},
  UHizliGirisTahsilat in 'UHizliGirisTahsilat.pas' {HizliGirisTahsilatDlg},
  UHizliGirisIsk in 'UHizliGirisIsk.pas' {HizliGirisIsk},
  UHizliGirisBaski in 'UHizliGirisBaski.pas' {HizliGirisBaskiDlg},
  UHizliGirisKKTahsilat in 'UHizliGirisKKTahsilat.pas' {HizliGirisKKTahsilatDlg},
  UHizliGirisKasaSay in 'UHizliGirisKasaSay.pas' {HizliGirisKasaSayDlg},
  UHizliGirisFiyatlandirma in 'UHizliGirisFiyatlandirma.pas' {HizliGirisFiyatlandirmaDlg},
  UStokHizmetAra in 'UStokHizmetAra.pas' {StokHizmetAraDlg},
  UHesapHareketleriAktarimAyarlari in 'UHesapHareketleriAktarimAyarlari.pas' {HesapHareketleriAktarimAyarlariDlg},
  UKampanyalar in 'UKampanyalar.pas' {KampanyalarDlg},
  UKarekodTakip in 'UKarekodTakip.pas' {KareKodDlg},
  //UScanner in 'UScanner.pas' {ScannerDlg},
  UBankaKredileriListeTanimlariFrame in 'AramaFrame\UBankaKredileriListeTanimlariFrame.pas' {BankaKredileriListeTanimlariFrame: TFrame};

{$R entegra.KLR}

{$R *.RES}
begin

  Application.Initialize;
  if GetThreadLocale <> $41F then
    SetThreadLocale($41F);
  GetFormatSettings;
  cxFormatController.UseDelphiDateTimeFormats := True;
{  CurrencyString := 'TL';
  CurrencyFormat := 3;
  NegCurrFormat := 8;
  ThousandSeparator := ',';
  DecimalSeparator := '.';
  CurrencyDecimals := 2;
  DateSeparator := '/';
  ShortDateFormat := 'dd/mm/yyyy';
  LongDateFormat := 'dd MMMM yyyy dddd';
  TimeSeparator := ':';
  TimeAMString := '';
  TimePMString := '';
  ShortTimeFormat := 'hh:mm';
  LongTimeFormat := 'hh:mm:ss';
  ListSeparator := ';';
 Application.Title := 'Entegra Finans';
  cxFormatController.UseDelphiDateTimeFormats := True;
  //  Application.CreateForm(TPasswordDlg, PasswordDlg);
  {  if GetParamIndex('DBInfo') > 0 then (* DB parametrelerini ayarlamak için *)
  begin
    Tablo.SetConnectionParams;
    Application.Terminate;
    ShellExecute(0, 'open', PChar(Application.ExeName), '/nosplash', nil, SW_SHOWNORMAL); (* /nosplash  parametresi program tanýtým ekranýn gözükmemesi için *)
    Exit;
  end;
}
// Tablo.TabKullan.Open;
//  Tablo.TabKulHar.Open;
   Application.CreateForm(TTablo, Tablo);
  if PasswordEkrani('Gentegre') then begin
    Application.CreateForm(TQuantGrid, QuantGrid);
    TRaporAraclari.Modul := 'C';
    Application.CreateForm(TAnaForm, AnaForm);
    Application.CreateForm(TFastRaporDlg, FastRaporDlg);
    TRaporAraclari.Ini := RehberIni;
    Application.Run;
    if (RestartProgram) then
       ShellExecute(0, 'open', PChar(Application.ExeName), '/nosplash', nil, SW_SHOWNORMAL);
  end
  else begin
    Tablo.Destroy;
    halt;
  end;
end.

