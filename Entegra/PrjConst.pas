unit PrjConst;

interface




resourcestring


 // Bilgi al
   jvIptal='İptal';
   jvIleri='İleri >';
   jvGeri='< Geri';
   jvSon='Son';
   jvAktivite='Aktivite / Görev Bilgileri';
   jvAktiviteDetay='Ek Detay Bilgiler';
   jvDokuman='Doküman bilgileri';
   jvIzlem='İzlem bilgileri';
   jvAktiviteYinele='Aktivite Yineleme';
   jvTarihce='Tarihçe';
   jvCekKocan='Çek Koçanları';
   jvCekHesap='Çek Hesapları';
   jvSablonDuzenle='Aktivite / Görev Şablonu';
   jvIsSuresi = 'İş süresi 7 günden büyük olamaz!';
   jvHesapOlusturmaDuzenleme='Hesap oluşturma ve düzenleme';
   jvCek='Çek';
   jvBaskasiCek='Başkasının çeki';
   jvSenet='Senet';
   jvBaskasiSenet='Başkasının seneti';
   jvCekSihirbaz='Çek Sihirbazı';
   jvSenetSihirbaz='Senet Sihirbazı';
   jvDemirbas='Demirbas bilgileri';
   Devam_Etmek = 'Devam etmek istiyor musunuz?';
   KarekodAitDegil = 'Bu karekod bu stoğa ait değil';

   BGYeni_bilgi_girisi='Yeni bilgi girişi.';
   BGListeye_bilgi_ekle='Listeye bilgi ekle';
   BGKilit_tarih_gir='Yeni kilit tarihini giriniz';
   BGOtomatik_gun='Otomatik gün giriniz';
   BGTutari_duzenle=' tutarı düzenle';
   BGTutar='Tutar';
   BGBaslama_tarih='Başlama Tarih Bilgisi';
   BGBaslangic_tarih_gir='Başlama Tarihini Giriniz';
   BGTC_no='TC Kimlik No';
   BGMaas='Maaş';
   BGAgi='Agi';
   BGDiger='Diğer';
   BGBanka='Banka';
   BGKasa='Kasa';
   BGAvans_banka='AvBanka';
   BGAvans_kasa='AvKasa';
   BGOde_banka='OdeBanka';
   BGOde_kasa='OdeKasa';
   Coklu_Senet = 'Çoklu Senet';
   BGBanka_maas_tutar=' bankadan maaş tutarı.';
   BGAvans_miktari=' için ödenecek avans miktarı';
   BGDokum_Rapor_Ad_Degistir='Döküm/Rapor Ad Değiştir';
   BGYeni_ad='Yeni Adı';
   BGDokum_Rapor_Kopyala='Döküm/Rapor Kopyalama';
   BGYeni_rapor='Yeni Rapor';
   BGBilgi_gir=' bilgisini giriniz';
   BGVardiya_Tur_Sec='Vardiya Türü Seçiniz';
   BGKredi_odemesi='Kredi Ödemesi';
   BGOdeme_tarihi='Ödeme Tarihi :';
   BGKredi_giris='Kredi Girişi';
   BGYeni_kod_gir='Yeni kodu giriniz. ';
   BGYeni_banka='Yeni Banka';
   BGYeni_sube='Yeni Şube';
   BGBanka_kod='Banka Kodu *';
   BGBanka_adi='Banka Adı *';
   BGSube_Kod='Şube Kodu *';
   BGSube_Ad= 'Şube Adı *';
   BGSubeler='Şubeler...';
   BGMusteri_kodu_gir='Müşteri kodunuzu giriniz.';
   BGMusteri_kodu='Müşteri Kodu';
   BGProje_kodu='Proje Kodu';
   BGMusteri_notu='Müşteri Notu';
   BGSiparis_notu='Sipariş Notu';
   BGLisans_no_gir='Lütfen lisans numaranızı giriniz.';
   BGLisans_no_yetkili_ara='Lisans Numarası İçin; GenYazılım:02163450378 Granit Bilg.:02164490019';
   BGIslem_tarih_gir='İşlem tarihini giriniz.';
   BGSaat_gir='Saatini giriniz.';
   BGAciklama_gir='Açıklama giriniz.';
   BGTarih_gir=' Tarihini Giriniz.';
   BGEski_rol_adi='Eski Rol Adı: ';
   BGYetki_durumu='Yetki Durumu';
   BGYeni_rol_adi_gir='Yeni Rol Adını Giriniz.';
   BGYeni_test_adi_gir='Yeni Test Adını Giriniz.';
   BGYeni='Yeni ';
   BGDegeri_bos_olamaz=' Değeri Boş Olamaz.';
   BGBolum='Bölüm: ';
   BGYeni_bolum_adi='Yeni Bölüm Adını Giriniz.';
   BGYeni_Departman_adi='Yeni Departman Adını Giriniz.';
   BGPersonel_secimi='Personel Seçimi';
   BGBilgi='Bilgiler.';
   BGMail_adres_gir='Mail adresi giriniz.';
   BGMail_adresi='Mail Adresi:';
   BGBarkod_baslangic_karakter='Barkod Başlangıç Karekterleri';
   BGAciklama='Açıklama';
   BGYeni_birim='Yeni Birim : ';
   BGYeni_birim_gir='Yeni birim girin';
   BGYeni_tur_gir='Yeni türü girin';
   BGYeni_tur='Yeni Tür : ';
   BGBoyut_sec='Boyut Seçimi';
   BGKampanya_kodu_gir='Yeni Kampanya kodunu giriniz.';
   BGKampanya_adi_gir='Yeni Kampanya adını giriniz.';
   BGMerkez_depo=' ve Merkez Depo';
   BGBoyut_tanimi='Yeni Boyut Tanımı';
   BGBoyut_adi='Yeni Boyut Adı';
   BGExcel_satiri_gir='Excel başlama satırı giriniz.';
   BGOdeme_Girisi='Ödeme bilgi girişi.';
   BGOdeme_turu='Ödeme türünü seçiniz.';
   BGTahsilat_bilgi_gir='Tahsilat bilgi girişi.';
   BGTahsilat_turu_sec='Tahsilat türünü seçiniz.';
   BGKur_degeri= 'Kur Değeri';
   BGFirma_adi_gir='Firma Adı Giriniz.';
   BGKopyalanacak_Demirbas_Miktari=' Kopyalanacak demirbaş miktarını giriniz.';
   BGYazici_Bilgisini_gir='Yazıcı bilgilerini girin';
   BGYazici_sec='Yazıcı Seçimi:';
   BGKopya_sayisi='Kopya Sayısı:';
   BGYeni_fiyat_adi_gir=' fiyat adını kopyalıyorsunuz.Yeni Fiyat adı giriniz';
   BGFiyat_sec='Fiyat Seçimi';
   BGNakliye_bilgileri='Nakliye Bilgileri';
   BGNakliye_tipi='Nakliye Tipi'  ;
   BGNakliye_tutari='Nakliye Tutarı';
   BGIskonto_aciklama='İskonto Açıklaması';
   BGIskonto_orani='İskonto Oranı:';
   BGTeklif_bilgi='Teklif Bilgileri';
   BGTeslim_sekli='Teslim Şekli';
   BGTeslim_alan='Teslim Alan';
   BGTeslim_Tarihi='Teslim Tarihi';
   BGSiradaki_belge_no='Sıradaki Belge Numarası:'  ;
   BGBelge_tarihi='Belge Tarihi';
   BGBelge_no='Belge Numarası';
   BGIade_miktari='İade edilen miktarı girin' ;
   BGUretim_miktari_gir='Üretim Miktarını Girin';
   BGRecete_bilgileri='Reçete Tanım Bilgileri.';
   BGRecete_kodu_gir='Reçete Kodu Giriniz.';
   BGRecete_adi_gir='Reçete Adı Giriniz.';
   BGPara_transfer_kalan_tutar='Para transferi: Kalan Tutar=';
   BGDepo_kullan='Depo Kullanımı';
   BGKasa_kullan='Kasa Kullanımı';
   BGPos_kullan='POS Kullanımı';
   BGYeni_Barkod_gir='Yeni Barkod girişi.';
   BGBarkod_no='Barkod Numarası:';
   BGIse_giris_tarih='İşe Giriş Tarihi :';
   BGIsten_cikis_tarih='İşten Çıkış Tarihi :';
   BGIsten_cikis_Nedeni='İşten Çıkış Nedeni :';
   BGIade_alindi_yeni_fatura_no=' İade alınıyor.Yeni Fatura No giriniz';
   BGEksiIskontoGirilemez='Eksi İskonto Girilemez!';
   BGSadeceIskonto2Girilemez='İskonto1 olmadan iskonto2 Girilemez!';
   BGYeni_versiyon_no='Yeni Revizyon No Girin';
   BGVersiyon_aciklama_gir='Revizyon Açıklaması Girin';
   BGKart_no='Kart No :';
   BGDuyuru_yorumu='Duyuru Yorumu';
   BGYorum_yaz='Yorumunuzu yazınız.';
   BGErteleme_giris='Erteleme girişi.';
   BGErteleme_tarih_gir='Erteleme tarihi giriniz';
   BGErteleme_nedeni_gir='Erteleme nedeni giriniz';
   BGYeni_zarf_bilgi_gir='Yeni zarf bilgilerini girin';
   BGZarf_ismi='Zarf İsmi:';
   BGGiris_saat_gir='Giriş Saati Gir.';
   BGCikis_saat_gir='Çıkış Saati Gir.';
   BGMola_saat_gir='Mola Süresi Gir.';
   BGBilgisini_gir=' bilgisini giriniz.';
   BGIzin_bilgi_gir=' İzin Bilgilerini giriniz ';
   BGIzin_tarih_gir='İzin Tarihini Giriniz';
   BGGun_miktari_gir= 'Gün Miktarını Giriniz';
   BGBankadan_odenecek_maas='Bankadan ödenecek maaş tutarı';
   BGMaas_kesintisi_duzenle='Maaş kesintisi düzenle';
   BGYeni_maas_kesintisi='Yeni maaş kesintisi';
   BGBelgeTipiSecimi='Bir Belge Tipi Seçiniz.';
   BGBelgeTipi='Belge Tipi';
   Guncellendi = 'Güncellendi';
   Ithalat='İthalat';
   Ihracat='İhracat';
   ExceldenVerilerAktariliyor='Veriler aktarılıyor. Bekleyiniz...';
   GIBtenSorgulamaYapilamadi = 'Bu firma için GİB ten sorgulama yapılamamıştır. İnternet vb. kontrol edip tekrar deneyiniz..';
   YerelParaZorunlu = 'Para birimlerinden birisi yerel para olmak zorunda!';
   EnUstte = 'En Üstte';
   EnAltta = 'En Üstte';

   YetkilerAynidegil = 'Yetkiler aynı değil';
  //Sektör Adları
    Sektor_ERP_Ad='ERP';
    Sektor_Tekstil_Ad='Tekstil Bilgi Sistemi';
    Sektor_Gida_Ad='Gida Bilgi Sistemi';
    Sektor_OtomotivServis_Ad='Otomotiv Bilgi Sistemi';
    Sektor_Market_Ad='Market Bilgi Sistemi';
    Sektor_Firin_Ad='Unlu Mamüller Bilgi Sistemi';
    Sektor_Firin_Cafe_Ad='Unlu Mamüller ve Cafe Bilgi Sistemi';
    Sektor_Cafe_Ad='Cafe Bilgi Sistemi';
    Sektor_Rest_Ad='Restaurant Bilgi Sistemi';

  //Uyarı
    GirenAdetUyari = 'Giriş işleminde sadece giren adet dolu olabilir!';
    CikanAdetUyari = 'Çıkış işleminde sadece çıkan adet dolu olabilir!';
    sButce_Silin = 'Önce bütçe bilgileri silin';
    sDetay_Silin = 'Önce detay bilgileri silin';
    Girisyapamazsiniz=' tarihine kadar programa giriş yapamassınız!';
    Kullaniciadiparola='Önce Kullanıcı Adı ve Parolayı Giriniz..';
    Degistirilemedi='Şifre Girişleri Uyumsuz!!! Değiştirilemedi...';
    GirdiginizSifre = 'Girdiğiniz şifre :';
    OncekiSifreileAyni = '- Önceki şifre ile aynı.';
    AyniDegil = '- Aynı değil.';
    SifreKisa = '- 8 karakterden kısa.';
    HicRakamYok = '- Hiç rakam bulundurmuyor.';
    HicKucukHarfYok = '- Hiç küçük harf bulundurmuyor.';
    HicBuyukHarfYok = '- Hiç büyük harf bulundurmuyor.';
    HicOzelKarakterYok = '- Hiç özel karakter bulundurmuyor.';




    Degistirildi='Şifre başarıyla değiştirildi...';
    Gecersizsifre='Geçersiz Şifre...';
    Kullanicisayiasimi=' Olan Lisanslı Kullanıcı Sayınızı Aşıyorsunuz!';
    Sube='Şube Seçin!';
    Sunucubulunamadi='Sunucu Bilgisi Bulunamadı!';
    Yetkisiz_Islem='Yetkisiz İşlem' ;
    GenotipBaglantiHatasi='Genotıp Bağlantı Hatası';
    Uygulanacak_Komut_Hatasi='Uygulanacak Komut Bulunamadı!';
    Uygulama_tamam='Uygulama gerçekleşti.';
    Uygulanamayan_alt_sorgu_sayisi=' Adet Alt Sorgu Uygulanamadı!!';
    //Adet = 'Faturadaki Lot Adet';
    Guncelleme_Satiri_Hatasi='Güncellenecek satırı seçiniz.';
    Uygulandi='Bu değişiklik daha önce uygulanmış..';
    Listeden_sec='Listeden seçim yapınız.';
    Degistirilmez='Komut değiştirilemez..';
    Minimum_gun_sayisi='Girilecek gün minumum 1 olmalıdır.';
    Yedek_Alindi='Yedek alınmıştır.';
    Yedek_alma_basarisiz_server_kontrol_edin='Yedek alma başarısız oldu.Server bağlantı bilgilerini kontrol ediniz.';
    Yedek_Alindi_Sikistirma_Basarisiz_server_kontrol='Servere yedek alınmıştır.Sıkıştırma işlemi gerçekleşmedi.Server bağlantı bilgilerini kontrol ediniz.';
    Yedek_al='Yedek alınız.';
    Tanimlama_eksik_hatali='Tanımlamalar eksik ya da hatalı..';

    Devir_gerceklesti='Devir İşleminiz Gerçekleştirildi.';
    Devir_silindi='Devir Silme İşleminiz Gerçekleştirildi.';

    En_Az_Bir='En az bir satır bilgi olmak zorundadır!';

  //Onay
    SGenotipOnay = 'Gentegre Onay' ;
    SSilmeSorusu = 'Kaydı silmek istediğinize emin misiniz?';
    KaydetmeSorusu = 'Yapılan işlemleri kaydetmek ister misiniz?'+#13#10+'Evet:Kaydet Hayır:Kaydetme İptal:Geri Dön';
    GDonusumSorusu = 'Tüm öğeleri kalıcı olarak silmek istediğinizden emin misini?' ;
    KisayolUyari ='Dosya geri yüklenmeden kısayol geri yüklenemez!';
    DosyayaYazmaBitti='Dosyaya yazma işlemi sona erdi...';

  //cxGrid Türkçeleştirme
    cxGruplamak = 'Gruplamak istediğiniz kolonu buraya sürükleyin';//'Drag a column header here to group by that column';
    cxGeri= 'Geri dönüşümlü bir değer oluşturamazsınız';//'You cannot create recursive levels';
    cxOnay= 'Onay';
    cxKayit= 'Kayıt silinsin mi?'; //'Delete record?');
    cxSecilen= 'Seçilen tüm kayıtlar silinsin mi?'; //'Delete all selected records?');
    cxGosterilecek= 'Gösterilecek kayıt yok.'; //'<No data to display>');
    cxFiltre= 'Filtre oluşturmak için buraya tıklayın .'; //'Click here to define a filter');
    cxYeni= 'Yeni bir satır oluşturmak için buraya tıklayın'; //'Click here to add a new row');
    cxFiltre2= 'Filtre boş'; //'<Filter is Empty>');
    cxOzellestirme= 'Özelleştirme'; //'Customization');
    cxSutunlar ='Sütunlar'; //'Columns');
    cxFiltreyi= 'Filtreyi uygula'; //'Apply Filter');
    cxOzellestir = 'Özelleştir…'; //'Customize…');
    cxSutunu= 'Sütunu Gizlemek/Göstermek veya hareket ettirmek için buraya tıklayın'; //'Click here to show/hide/move columns');
    cxBantlar= 'Bantlar';//'Bands');
    cxBanti= 'Bantı Gizlemek/Göstermek veya hareket ettirmek için buraya tıklayın'; //'Click here to show/hide/move bands');
    cxSatirlar= 'Satırlar'; //'Rows');
    cxAraci= 'Aracı bir bileşenin eksik!'#1310'% s bileşeni forma ekleyin.'; //'Missing an intermediary component!'#13#10'Please add a %s component to the form.');
    //m.y.
    cxRES_TarihBugun = 'Bugün';                  // 'Today'
    cxRES_TarihTemizle = 'Temizle';              // 'Clear';
    cxRES_TarihSimdi = 'Şimdi';                  //  'Now';
    cxRES_TarihTamam = 'Tamam';                  //  'OK';
    cxRES_TarihVazgec = 'Vazgeç';                //  'Cancel';
    cxRES_TarihGecersizTarih = 'Geçersiz Tarih'; //  'Invalid Date';

    cxRES_SFilterDialogRows = 'Satırları göster:'; //  'Show rows where:'
    cxRES_SFilterDialogCharactersSeries = 'herhangi bir karakter dizisini sunmak için'; // 'to represent any series of characters'
    cxRES_SFilterDialogSingleCharacter = 'herhangi bir karakteri sunmak için'; // 'to represent any single character'
    cxRES_SFilterAddCondition= 'Koşul &Ekle';
    cxRES_SFilterAddGroup= 'Grup&Ekle';
    cxRES_SFilterAndCaption= 've';
    cxRES_SFilterBlankCaption= 'boşluk';
    cxRES_SFilterBoolOperatorAnd= 'VE';
    cxRES_SFilterBoolOperatorNotAnd= 'DEĞİL VE';
    cxRES_SFilterBoolOperatorNotOr= 'DEĞİL VEYA';
    cxRES_SFilterBoolOperatorOr= 'VEYA';
    cxRES_SFilterBoxAllCaption= '(Tümü)';
    cxRES_SFilterBoxBlanksCaption= '(Boş Olanlar)';
    cxRES_SFilterBoxCustomCaption= '(Özelleştir...)';
    cxRES_SFilterBoxNonBlanksCaption= '(BoşOlmayanlar)';
    cxRES_SFilterClearAll= 'Tümünü &Temizle';
    cxRES_SFilterControlDialogActionApplyCaption= '&Uygula';
    cxRES_SFilterControlDialogActionCancelCaption= 'İptal et';
    cxRES_SFilterControlDialogActionOkCaption= 'TAMAM';
    cxRES_SFilterControlDialogActionOpenCaption= '&Aç...';
    cxRES_SFilterControlDialogActionOpenHint= 'Open|Opens var olan filtre';
    cxRES_SFilterControlDialogActionSaveCaption= '&Olarak kaydet...';
    cxRES_SFilterControlDialogActionSaveHint= 'Save As|Saves aktif filtreyi yeni isimle kaydet';
    cxRES_SFilterControlDialogCaption= 'Filtre oluşturucu';
    cxRES_SFilterControlDialogFileExt= 'Dosya uzantısı';
    cxRES_SFilterControlDialogFileFilter= 'Filtreler (*.flt)|*.flt';
    cxRES_SFilterControlDialogNewFile= 'Yeni dosya';
    cxRES_SFilterControlDialogOpenDialogCaption= 'Varolan bir filtreyi açın';
    cxRES_SFilterControlDialogSaveDialogCaption= 'Etkin filtre dosyaya Kaydet';
    cxRES_SFilterControlNullString= '<boş>';
    cxRES_SFilterDialogCaption= 'Özel filtre';
    cxRES_SFilterDialogInvalidValue= 'Geçersiz değer';
    cxRES_SFilterDialogOperationAnd= 'VE';
    cxRES_SFilterDialogOperationOr= 'VEYA';
    cxRES_SFilterDialogUse= 'Kullan';
    cxRES_SFilterErrorBuilding= 'Kaynaktan filtre oluştrulamaz';
    cxRES_SFilterFooterAddCondition= 'yeni bir koşul eklemek için tuşa basınız';
    cxRES_SFilterGroupCaption= 'aşağıdaki komutları uygular';
    cxRES_SFilterNotCaption= 'değil';
    cxRES_SFilterOperatorBeginsWith= 'ile başlayan';
    cxRES_SFilterOperatorBetween= 'arasında';
    cxRES_SFilterOperatorContains= 'içeren';
    cxRES_SFilterOperatorDoesNotBeginWith= 'ile başlamayan';
    cxRES_SFilterOperatorDoesNotContain= 'içermeyen';
    cxRES_SFilterOperatorDoesNotEndWith= 'ile bitmeyen';
    cxRES_SFilterOperatorEndsWith= 'ile biten';
    cxRES_SFilterOperatorEqual= 'eşittir';
    cxRES_SFilterOperatorFuture= 'ileriki';
    cxRES_SFilterOperatorGreater= 'den büyük olan';
    cxRES_SFilterOperatorGreaterEqual= 'den büyük ya da eşit olan';
    cxRES_SFilterOperatorInList= 'geçen';
    cxRES_SFilterOperatorIsNotNull= 'boş olmayan';
    cxRES_SFilterOperatorIsNull= 'boş olan';
    cxRES_SFilterOperatorLast14Days= 'son 14 gün';
    cxRES_SFilterOperatorLast30Days= 'son 30 gün';
    cxRES_SFilterOperatorLast7Days= 'son 7 gün';
    cxRES_SFilterOperatorLastMonth= 'geçen ay';
    cxRES_SFilterOperatorLastTwoWeeks= 'son iki hafta';
    cxRES_SFilterOperatorLastWeek= 'geçen hafta';
    cxRES_SFilterOperatorLastYear= 'geçen yıl';
    cxRES_SFilterOperatorLess= 'den az olan';
    cxRES_SFilterOperatorLessEqual= 'den az ya da eşit olan';
    cxRES_SFilterOperatorLike= 'benzeyen (Like)';
    cxRES_SFilterOperatorNext14Days= 'sonraki 14 gün';
    cxRES_SFilterOperatorNext30Days= 'sonraki 30 gün';
    cxRES_SFilterOperatorNext7Days= 'sonraki 7 gün';
    cxRES_SFilterOperatorNextMonth= 'sonraki ay';
    cxRES_SFilterOperatorNextTwoWeeks= 'sonraki iki hafta';
    cxRES_SFilterOperatorNextWeek= 'sonraki hafta';
    cxRES_SFilterOperatorNextYear= 'sonraki yıl';
    cxRES_SFilterOperatorNotBetween= 'arasında olmayan';
    cxRES_SFilterOperatorNotEqual= 'eşit olmayan';
    cxRES_SFilterOperatorNotInList= 'geçmeyen';
    cxRES_SFilterOperatorNotLike= 'benzemeyen (not Like)';
    cxRES_SFilterOperatorPast= 'önceki';
    cxRES_SFilterOperatorThisMonth= 'bu ay';
    cxRES_SFilterOperatorThisWeek= 'bu hafta';
    cxRES_SFilterOperatorThisYear= 'bu yıl';
    cxRES_SFilterOperatorToday= 'bugün';
    cxRES_SFilterOperatorTomorrow= 'yarın';
    cxRES_SFilterOperatorYesterday= 'dün';
    cxRES_SFilterOrCaption= 'ya da';
    cxRES_SFilterRemoveRow= '&Satırı kaldır';
    cxRES_SFilterRootButtonCaption= 'Filtre';
    cxRES_SFilterRootGroupCaption= '<kök>';
    cxRES_SGridAlignCenter= 'Ortala';
    cxRES_SGridAlignLeft= 'Sola Hizala';
    cxRES_SGridAlignmentSubMenu= 'Hizalama';
    cxRES_SGridAlignRight= 'Sağa Hizala';
    cxRES_SGridAvgMenuItem= 'Ortalama';
    cxRES_SGridBestFit= 'En Uygun';
    cxRES_SGridBestFitAllColumns= 'En Uygun (Tüm sütunlar)';
    cxRES_SGridClearGrouping= 'Gruplamayı Temizle';
    cxRES_SGridClearSorting= 'Sıralamayı temizle';
    cxRES_SGridCountMenuItem= 'Adet';
    cxRES_SGridFieldChooser= 'Alan Seçici';
    cxRES_SGridFullCollapse= 'Tam daralt';
    cxRES_SGridFullExpand= 'Tam genişlet';
    cxRES_SGridGroupByBox= 'Kutuya göre grupla';
    cxRES_SGridGroupByThisField= 'Bu alana göre grupla';
    cxRES_SGridHideGroupByBox= 'Gruplamayı gizle';
    cxRES_SGridMaxMenuItem= 'Maks';
    cxRES_SGridMinMenuItem= 'Min ';
    cxRES_SGridNone= 'Hiçbiri';
    cxRES_SGridNoneMenuItem= 'Hiçbiri';
    cxRES_SGridRemoveColumn= 'Bu kolonu kaldır';
    cxRES_SGridRemoveThisGroupItem= 'Gruplamadan kaldır';
    cxRES_SGridShowExpressionEditor= 'İfade Düzenleyici...';
    cxRES_SGridShowFindPanel= 'Paneli bul';
    cxRES_SGridShowFooter= 'Altband';
    cxRES_SGridShowGroupFooter= 'Grup Altbantı göster';
    cxRES_SGridSortByGroupValues= 'Grup değerine göre sırala';
    cxRES_SGridSortBySummary= '%s için %s';
    cxRES_SGridSortBySummaryCaption= 'Grup özetine göre sırala:';
    cxRES_SGridSortColumnAsc= 'Artana göre sırala';
    cxRES_SGridSortColumnDesc= 'Azalana göre sırala';
    cxRES_SGridSumMenuItem= 'Toplam';
    cxRES_SMenuItemCaptionAssignFromWebCam= 'Kameradan &ata...';
    cxRES_SMenuItemCaptionCopy= '&Kopyala';
    cxRES_SMenuItemCaptionCut= 'Ke&s';
    cxRES_SMenuItemCaptionDelete= '&Sil';
    cxRES_SMenuItemCaptionLoad= '&Yükle...';
    cxRES_SMenuItemCaptionPaste= '&Yapıştır';
    cxRES_SMenuItemCaptionSave= 'Olarak&kaydet...';
    cxRES_SNoMatchesFound= 'Eşleşme bulunamadı';
    //M.Y 06.02.2024
    cxRES_scxQuickCustomizationAllCommandCaption= '(Tümü)';
    cxRES_scxQuickCustomizationSortedCommandCaption = '(Sıralı)';

  //AnaGirisSayfasi
    AGS_Arama = 'Genel Arama';
    AGS_Iletisim = 'İletişim';
    AGS_Mesajlasma = 'Mesaj';
    AGS_Duyuru = 'Duyuru';
    AGS_CRM = 'CRM';
    AGS_Aktivite = 'Aktivite';
    AGS_Gorevler = 'Görev';
    AGS_Projeler = 'Proje';
    AGS_Servis= 'Servis';
    AGS_Günlük = 'Günlük';
    AGS_Haber = 'Haber';
    AGS_Piyasa = 'Piyasa';
    AGS_HavaDurumu = 'Hava Durumu';
    AGS_Yonetim = 'Yönetim';
    AGS_FinansAnalizi = 'Finans';
    AGS_CRMAnalizi = 'CRM';
    AGS_TeklifAnalizi = 'Teklif';
    AGS_ServisAnalizi = 'Servis';
    AGS_FarkliDurumVeAtayanSecilemez = 'Farklı durum ve görev atayan seçilemez';
    AGS_FarkliDurumVeSorumluSecilemez = 'Farklı durum ve sorumlu seçilemez';

  //Ödeme - tahsilat
    SOdeme = 'Ödeme';
    STahsilat = 'Tahsilat';
    SMakbuzNoGir = 'Makbuz Numarasını Giriniz.';

  //Fatura
    SGelenFaturaBilgileri = 'Gelen Fatura Bilgileri';
    SFaturaTarihi ='Fatura Tarihi';
    SFaturaNo='Fatura No';
    SSatisIrs='Satış İrsaliyesi';
    SSatisFat='Satış Faturası';
    SSatisFis='Satış Fişi';
    SGirisFisi='Giriş Fişi';
    SCikisFisi='Çıkış Fişi';

  //UFaturalar ,UFaturaTransferListe
    idd='İşaretlilerin Durumunu Değiştir' ;
    UrungirilmedenKaydedilemez ='Ürün veya hizmet satırı girilmeden kaydedilemez!';
    Transferurunlersilinemez='Transfer edilen ürünler hareket görmüştür.Silinemez.';
    Adetsifirvesifirdankucukolamaz='Adet sıfır veya sıfırdan küçük olamaz!';
    Urungirilmedenkadedilmez='Ürün adı girilmeden kaydedilemez!';
    Mailbulunamadiadresekle='Mail adresi bulunamadı! Mail adresi eklemek istermisiniz?';
    Excelkolonayarlarinigiriniz='Seçenekler/Opsiyonlar/Alış Satış ekranında varsayılan excel kolon ayarlarını giriniz';
    Stokfiyatgir='Stok Fiyat bilgilerini giriniz..';
    Excelverikaydedildi='Excel verileri kaydedilmiştir.';
    Butarihoncesiislemyapilmaz='Kilitlenmiş bilgi, işlem yapılamaz!';
    CikisYapilmis='Lot/Seri No lu ürün çıkışı yapılmış!';
    BildirimYapilmis='ÜTS Bildirimi Yapılmış!';
    BildirimYapilmisSilinemez='ÜTS Bildirimi Yapılmış Silinemez!';
    BildirimYapilmisDegisemez='ÜTS Bildirimi Yapılmış Değişemez!';
    DonusumYapilamaz='İzleme bilgisi olan belgel buradan dönüşüm yapılamaz! Yeni belge oluşturup dönüşüm butonundan seçin.';
    DonusumYapilmis='Dönüşüm Yapılmış!';
    Butariheislemyapilmaz='Kilitlenmiş tarih alanına veya devir öncesine işlem yapılamaz!';
    DevirOncesineIslemEklenmez='İşlem yapmaya çalıştığınız tarihin sonrasında bir devir kaydı var!';
    Planlifaturaiptalolsunmu='Bu faturada oluşturulmuş plan vardır.İptal etmek istiyor musunuz? ';
    Belge_olustu='Belge Oluşturuldu';
    Belge_olusmadi='Belge Oluşturulmadı';
    Belge_goruldu =  'Belge görüldü';
    Belge_degisti =  'Belge değiştirildi';
    Belge_revize = 'Belge revize edildi';
    Form_Kaydedildi = 'Form Kaydedildi';
    SifirYuzArasinda = '0 ile 100 arasında olmalı';
    Irsaliyeyapilsinmi='Bu siparişi irsaliyeleştirmek istiyor musunuz ? ';
    Hareketgormussilinemez='Hareket görmüş, kayıt silinemez. Belge ID:';
    Kilitlibelgedeislemyapilmaz='Seçilenler arasında kilitli belge vardır.Kilitli belgeler de işlem yapılamaz !';
    Planlibelgesilinmedi='Seçilenler arasında plan oluşturulmuş belge vardır.Bu belgeler silinmemiştir. !';
    Kilitliveplanlibelgesilinemez='Seçilenler arasında kilitli ve plan oluşturulmuş belge vardır.Bu belgeler silinmemiştir. !';
    faturaplanlisilinecekmi='Bu faturada oluşturulmuş plan vardır.Silmek istiyor musunuz? ';
    Tanimsiz_Firma='Tanımlı olmayan firmalar vardır.';
    Farklicariberaberbelgelenmez='Farklı cari kayıtlar bir arada belgelendirilemez!';
    Girenirsaliyelisiparis='Bu Siparişin irsaliyesi oluşturulmuştur.Giren';
    Cikanirsaliyelisiparis='Bu Siparişin irsaliyesi oluşturulmuştur.Çıkan';
    Girenirsaliyelifatura='Bu irsaliyenin Faturası oluşturulmuştur.Giren';
    Cikanirsaliyelifatura='Bu irsaliyenin Faturası oluşturulmuştur.Çıkan';
    HesapEfaturadadevamedecekmisin='Bu hesap EFatura kullanmaktadır. Yine de devam etmek istiyor musunuz?';
    MukerrerKayit = 'Aynı gün, aynı tutarda, aynı türde ve aynı cari için oluşturulmuş bir belge daha var. Devam etsin mi?';
    Adresdegistikartguncelle='Adres Değişti. Cari Kartta güncellensin mi?';
    Uruniadeedilmisdevamedecekmisin='Bu ürün daha önce iade edilmiş. Devam etmek istiyor musunuz?';
    Urunfiyatfarkivardevamedecekmisin='Bu ürün için daha önce fiyat farkı oluşturulmuş. Devam etmek istiyor musunuz?';
    Irsaliyedefaturaileiptaledilsinmi='Faturaya bağlı irsaliyeler de bu fatura ile birlikte iptal edilsin mi?';
    Secilisatirlarsilinsinmi='Seçili plan satırları silinsin mi?';
    Belgeiptaledilsinmi='Bu Belgeyi iptal etmek istediğinize emin misiniz?';
    Islemgorenfaturadadegisiklikyapilmaz='İşlem gören efatura üzerinde değişiklik/silme yapılamaz!';
    DonusturulmusSilinemez='"Dönüştürülmüş Belge", silinemez!';
    DonusturulmusDegisemez='"Dönüştürülmüş Belge", değişemez!';
    Belgenogirisiyanlis='Belgeno alanına yanlış tipte veri girişi yapıyorsunuz.';
    //Yetkisiz_Islem='Yetkisiz işlem';
    Iskontooraniasildi='Max iskonto oranını aştınız.';
    Adetsifirolamaz='Adet sıfır veya sıfırdan küçük olamaz!';
    AltVeriVarSilinemez = 'Alt veriler var, silinemez!';

  //Fiş
    SGelenFisBilgileri = 'Gelen Fiş Bilgileri';
    SFisTarihi ='Fiş Tarihi';
    SFisNo='Fiş No';
    SAlisIrs='Alış İrsaliyesi';
    SAlisFat='Alış Faturası';
    SAlisFis='Alış Fişi';

  //UMasrafGelir
    Ay_Yanlis = 'Ay bilgisi 1 ile 12 arasında olmalı!';
    MGKayitlarbasariylakopyalandi = 'Kayıtlar başarıyla kopyalandı.';
    MGKaydedildi='Veriler kaydedilmiştir.';
    MGFarklikod='Girilen Kod farklı olmalı.';
    MGSilinmez='Bu sözleşmeye demirbaş eklenmiştir.Silinemez !';
    CariAktarimkosullari='Aktarılacak kolonlar sırasıyla "Kod,Ad,Grup,İlk Temas,Sektor,Kategori,Sinif,Temsilci,Bolge,AltBolge,Ozelkod,Muhkodu,Peryot,'+
                       'VergiDai,VergiNo,IsTel, Faks, CepTel,	Eposta, Web, Adres,PK, Ilce, Il, Ulke,PostaDgt,EPostaDgt,Vade,Notlar, Firma ÜTS No, Firma Resmi Ad" şeklinde olmalıdır..';

    StokAktarimkosullari='Aktarılacak kolonlar sırasıyla "Kod,Ad,Kategori,Tipi,Barkod,Marka,Model,Grubu, Ozellik, AnaBirim,Birim2,Birim2Carpan,KDV,OTV_Katsayi, OTV_Yuzde,Izleme,KulSekli,'+
                'Garanti, Web, OzelKod,Ekipman, Notlar, Fiyat, ParaBirimi, FiyatAdi, Ürün No" şeklinde olmalıdır..';

    UTSUrunAktarimkosullari='Aktarılacak kolonlar sırasıyla'+#13+#10+
      '"KURUM_ADI,KURUM_UTS_NO,STOKKOD,URUNNO,'+#13+#10+
      ' SERINO,LOTNO,ADET,FİYAT,ÜRT,SKT"'+#13+#10+
      ' şeklinde olmalıdır..';

    MGAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Kod (Yazı),'+#13+#10+
              '     * sütun2(B):Ad (Yazı),'+#13+#10+
              '     * sütun3(C):KDV (Numerik),'+#13+#10+
              '     * sütun4(D):Şube ID (Numerik) '+#13+#10+
              '   öğelerine sahip olmalıdır.';
    KrediAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile 9 sütun:'+#13+#10+
              '     * sütun1(A):Tarih,'+#13+#10+
              '     * son sütun9(I):Açıklama,'+#13+#10+
              '   öğelerine sahip olmalıdır.';
     MGHatalikayit='Hatalı formatta kayıt ekliyorsunuz!';
     MGKurum='Önce kurum seçin';
     MGKodvar='Bu kod daha önce eklenmiş!';
     MGEmirNovar='Bu Emir No daha önce eklenmiş!';

  //Banka_TEB ,Banka_Garanti
    secimyapilmadihata = 'Alıcı listesinden en az bir seçim yapınız.' ;

  //UHavalaeEFT
    Logayazamadihata = 'Dosya imza log veritabanına kaydedilemedi.';
    yanlistelnohata = 'Geçerli bir telefon numarası giriniz.';
    yanlisoperatorhata = 'Elektronik imza türkcell ve avea için kullanılmaktadır, operatör seçiminizi yapınız.';
    eimzahata = 'Elektronik imza başarısız.';
    secimyokhata = 'En az bir Havale/EFT seçmelisiniz.';
    bankadanodemeyokhata = 'Seçtiğiniz tarihte banka üzerinden ödemeniz bulunmamaktadır. Başka bir tarih seçin yada ödeme türünüzü düzeltin.';
    Dosyaturuhata = 'Yanlış türde bir dosya oluşturuldu.';
    Eminmisin = 'Havale/Eft Sihirbazından çıkmak istediğinize emin misiniz?';
    FTPhatali='FTP Bilgileri Hatalı';
    BankaHareketAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Tarih (Tarih),'+#13+#10+
              '     * sütun2(B):No (Yazı),'+#13+#10+
              '     * sütun3(C):Açıklama (Yazı),'+#13+#10+
              '     * sütun6(F):Tutar (Numerik) '+#13+#10+
              '   öğelerine sahip olmalıdır.';

  //PDKSListeFrame
    PDKSSil='Seçili satırlar silinsin mi?';
    PDKSSec='Personel Seçiniz !' ;

  //PosListeFrame
    PosOranSilmeOnayi = 'Seçili olan pos oranı silinsinmi?';
    PosOranPosSecimi = 'Yeni kayıt için öncelikle pos seçimi yapmalısınız.';
    PosSilinecekkayitsec='Silme İşlemi İçin Herhangi Bir Kayıt Seçmediniz.';
    POSBulunamadi='Kredi Kartı tahsilatı için POS tanımı yapılmalı.';

  //UHesapPlanı
    YanlisTabHata = 'Kartlar üzerinde düzenleme yapamazsınız, sadece hesap planını değiştirebilirsiniz. Lütfen Sağ Tuş menüsünden "Görünüm \ Sadece Plan" ı seçiniz.';
    Kaydedildi='Başarıyla kaydedilmiştir.';
    Yanlis_Isaret='Hesap adında kesme işareti olamaz!';

  //Takvim
    TAksiyonsil='Bu aksiyon silinsin mi?';
    TFaturaPlanliSilinsinmi='Bu faturada oluşturulmuş plan vardır.Silmek istiyor musunuz? ';

  //UTakvimBankaParaTransfer
    TutarGiren = 'Tutar(Giren):  ';
    ParaGiren = 'Para Transferi(Giren)';
    TutarCikan =  'Tutar(Çıkan):  ';
    ParaCikan =  'Para Transferi(Çıkan)';
    istarih = 'İşlem Tarihi:  ' ;
    gerceklesen = 'Gerçekleşen ';
    pltarih =  'Plan Tarihi:  ';
    planlanan =  'Planlanan ';
    kasa111 = 'Kasa:  ';
    CVarsayilan = 'Varsayılan';
    Varskasa111 = 'Varsayılan Kasa:  ';
    kasakodu = 'Kasa Kodu:  ';
    cNakit = 'Nakit    ';
    banka111 = 'Banka:  ';
    sube1 = 'Şube:  ';
    hesap1 = 'Hesap:  ';
    bankakk1 = 'Banka:  ';
    subekk1 = 'Kart No:  ';
    hesapkk1 = 'Tanımlı Kişi:  ';
    bankakk2 = 'Banka:  ';
    subekk2 = 'POS No:  ';
    hesapkk2 = 'POS Adı:  ';
    PosCihazi = 'POS   ';
    KKarti = 'Kredi Kartı  ';
    SQLBulunamadi='SQL Bulunamadı..';
    GrupAdi = 'Grup Adı';


  //UTakvimKKEkstresi
    dekstiresi=' Dönemi Ekstre Bilgileri.';
    faiz_donem_odemesi='Arada faiz dönem ödemesi var eklensin mi?';
  //UTakvimVirman

  //UTablo ,Senetler
    //HareketGormusSilinemez =  'Hareket görmüş bilgi silinemez!';
    CekKasaHareketiHatasi= 'Tahsilatı bulunan çek kaydı silinemez!';
    CekFarkliDurum= 'Farklı durumdaki çekler bir arada işlem göremez!';
    CekHareketHareketiHatasi = 'Hareket görmüş çek kaydı silinemez!';
    CekPortfoyHariciHatasi = 'Sadece Portföydeki çekler silinebilir!';
    IntBaglanti = 'İnternet bağlantınız yok';
    Emailhatasitekraryollayin='Error while trying to send email';
    Listele='Önce kayıtları listeleyiniz.';
    Kayityok='Aktarılacak herhangi bir kayıt yok.';
    Kayitsec='Aktarılacak kayıtları seçiniz.';
    Iadeyapilamaz='Bu faturada oluşturulmuş plan vardır.İade yapılamaz ' ;
    Personelbilgisayarkullanacakmi='Bu personel bilgisayar kullanacak mı?';
    Uzerineyazilsinmi='Bu isimde kayıtlı dosya var. Üzerine yazılsın mı?';
    BirIsimGiriniz='İşleme devam etmek için lütfen bir isim giriniz.';
    Yanlistarih='Erteleme geri bir tarihe olamaz!';
    BosOlamaz='Erteleme nedeni boş olamaz!';
    KurGuncellenemedi='Döviz Kurları Güncellenemedi';
    KurGuncellendi='Döviz Kurları Güncellendi';
    Hataliadsifre='Kullanıcı Adı / Şifre Hatalı!';
    MailHata='Mail Gönderim Hatası';
    GecerliEPosta='Geçerli Bir Eposta Hesabı Seçiniz';
    EPosta_Enazbiralici='Alıcı listesinde en az bir alıcı olmalıdır.';
    Outlookacik='E-Posta gönderim programı açık görünüyor. Kapatıp tekrar deneyin.';
    CekiSilin='Çek girişi hareketi silinemez, Lütfen çekin kendisini silin.';
    Sonhareketsilinebilir='Sadece son hareketi silebilirsiniz.';
    Bulunamiyor='Seçtiğiniz satır bulunamıyor!';
    Guncellemetekraroturumacin='Lisans bilgileriniz güncellendi, tekrar oturum açın.';
    Guncellemetekraroturumacilacak='Lisans bilgileriniz güncellendi, tekrar oturum açılacak.';
    LisansSilinecek='Lisans bilgileriniz tekrar düzenlemeniz için silinecek. Devam etmek istediğinize emin misiniz?';
    Lisansyenileme='Lisansınızın son kullanım tarihine girdiniz. Lisansınızı yenilemeniz gerekmektedir.';
    Baglantikontrolediniz='ile bağlantınızı kontrol ediniz.' ;
    Yedeklemeyap=' gündür datalarınızın yedeği alınmamıştır..';
    LisansyenilemeMaksimum19girisyapilabilir='Lisans süreniz sona ermiştir. Lisansınızı yenilemeden en fazla 19 kez daha giriş yapabilirsiniz.';
    Lisanssizgirissayisi='Lisans süreniz sona ermiştir. Lisansınızı yenilemeden  maksimum yapabileceğiniz giriş sayısı : ';
    LisansHatasi='Lisans Hatası!';

    max14karakter = '14 karakterden fazla olamaz!';

    Lisansalin='Lisanssız Kullanım Süreniz Sona Ermiştir. Lütfen Lisans Alın.';
    Kullanilmisstok='Bu stok daha önce stok sayımlarında kullanılmıştır.';
    Fatkulstok='Bu stok daha önce fatura/fiş/irsaliye içerisinde kullanılmıştır.';
    Sipariskulstok='Bu stok daha önce siparişte kullanılmıştır.';
    SipariskulNo='Bu sipariş numarası daha önce başka bir siparişte de kullanılmıştır.';
    Teklifkulstok='Bu stok daha önce teklifte kullanılmıştır.';
    ServiskulStok='Bu stok daha önce serviste kullanılmıştır.';
    Musteriekipmanaeklensinmi=' adlı stok müşteri ekipmanları listesine eklensin mi?';
    stokServisekipmanaeklensinmi='Bu stok servis ekipmanları listesine eklensin mi?';
    stokServisekipmandanciksinmi='Bu stok servis ekipmanları listesinden çıkarılsın mı?';
    Servisekipmankullanılanstok='Bu stok daha önce servis ekipmanlarında kullanılmıştır.';
    Servisekipmankullanilanstok='Bu stok daha önce servis ekipmanlarında kullanılmıştır.';
    Gecersizalanadi='Stil Denetiminde Kullanılan Alan Adı Geçersiz: ';
    Gecersizkosul='Stil Denetiminde Kullanılan Koşullar Geçersiz: ';
    IzlemeSecin='İzleme Yöntemi seçin!';
    IzlemliUrunVar = 'İzleme bilgili ürün bulundu. DÖNÜŞÜM butonundan dönüştürülebilir!';
    Maksimumdosyaboyutu='Arşive atılabilecek maksimum dosya boyutu :';
    Kartsilinemez='Hareket görmüş stok kartı silinemez!'  ;
    StokKartBulunamadi= 'Stok kartı bulunamadı!';
    Birim2Miktar1olmasi='1. Birim ve 2. Birim aynı ise miktar sadece 1 olabilir!';
    Fazlakarakteruyarisi='EAN13 için yapılmış tanımlama hatalı.. Tanımlama 12 karakterden oluşmalı ve 13. kontrol karakteri belirtilmemelidir.';
    Islemturubelirtilmemis='IslemTuru belirtilmemiş';
    Isim_='İsim';
    SGirisYapildi = 'Giriş yapıldı';
    SOdemePlanlandi = 'Ödeme planlandı';
    SOdendi = 'Ödendi';
    SCikisYapildi = 'Çıkış yapıldı';
    STahsilatPlanlandi = 'Tahsilat planlandı';
    STahsilEdildi = 'Tahsil edildi';
    SBekliyor = 'Bekliyor';
    SOnaylandi = 'Onaylandı';
    SImzalandi = 'İmzalandı';
    SPortfoyde = 'Portföyde';
    STahsilataVerildi = 'Tahsilata verildi';
    SDoldurunuz=' boş bırakılamaz .';
    SProjeFirsatKapansin = 'Projeye oluştuktan sonra fırsat kapansın mı?';

  //Cari - Rehber Ekranları
    CRPasif_kayda_islem_olmaz= 'Pasif kayda işlem yapılamaz';
    CRPasif_kayda_islem_Secimi= 'Dikkat! Pasif kayda işlem yapılamaz! Devam etmek istiyor musunuz?';
    CRPlanli_belge_silinemez='Seçilenler arasında plan oluşturulmuş belge vardır.Bu belgeler silinmemiştir. !';
    CRKilitli_planli_belge_silinemez='Seçilenler arasında kilitli ve plan oluşturulmuş belge vardır.Bu belgeler silinmemiştir. !' ;
    CRKilittarih_oncesi_islem_yok='Kilit tarihi ve öncesine işlem yapılamaz !';
    CROpsiyon_kaydi_bulunamadi='Giriş yapılabilecek opsiyon kaydı bulunamadı!';
    CRIslem_basarisiz_eslesen_kayit_bulundu='İşleminiz Gerçekleşmedi! Girmiş olduğunuz bilgiyle eşleşen kayıt bulunmuştur.' ;
    CRAktarim_Kosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Tarih,'+#13+#10+
              '     * sütun2(B):Borç(Numerik),'+#13+#10+
              '     * sütun3(C):Alacak(Numerik),'+#13+#10+
              '     * sütun4(D):Para Birimi (Yazı),'+#13+#10+
              '     * sütun5(E):Açıklama(Yazı),'+#13+#10+
              '     * sütun6(F):Kur(Nümerik),'+#13+#10+
              '     * sütun7(G):Karşılığı(Nümerik),'+#13+#10+
              '     * sütun8(H):Karşılığı Para Birimi (Nümerik),'+#13+#10+
              '   öğelerine sahip olmalıdır.' ;
    CRKart_bulunamadi='Cari kartı bulunamadı!';
    CRAlan_silinsinmi=' alanını silmek istiyor musunuz ?' ;
    CRPersonel_carikart_var='Bu personele daha önce cari kart açılmış!';
    CRKarakter_sayisi='Karakter sayısı :' ;
    CRalisSatis_belgesi_kopyala='Alış ve Satış belgelerini kopyalayabilirsiniz.' ;
    CRKimlik_no_kullanilmis='Bu kimlik no daha önce kullanılmıştır: ';
    CRKilitli_belge_islem_yapilamaz='Seçilenler arasında kilitli belge vardır.Kilitli belgeler de işlem yapılamaz !' ;
    CRRisk_limiti_asimi_islem_basarisiz='Yetkinizin aşan bir risk limiti tanımladınız. İşleminiz kaydedilemeyecektir.';

  //Cek
    CCek_kayit_silinemez_ceki_sil='Çeklerin ilk giriş kayıtları silinemez! Lütfen çeki silmeyi deneyin.';
    CHata_kaydi_sil_ekle='Çek Kaydı Hata İçermektedir. Lütfen Kaydı Silip Tekrar Ekleyin.';
    CBu_tarih_oncesi_islem_kaydi_yapamazsiniz='Son işlem tarihinin öncesine işlem kaydedemezsiniz.: ';
    CHesap_bilgisi_bulunamadi='Banka hesap bilgileri bulunamadı!';

  //Kasa
    KPlanli_fatura_silinsinmi='Bu faturada oluşturulmuş plan vardır.Silmek istiyor musunuz? ';
    KBu_ekrandan_silinemez_Hizli_Satistan='Bu kayıt Hızlı Satış ekranından oluşturulmuştur, bu ekrandan silinemez.';
    KKilittarih_oncesi_islem_yok='Kilit tarihi ve öncesine işlem yapılamaz !';
    KAksiyon_silinsinmi='Bu aksiyon silinsin mi?' ;
    KAlisSatis_belgesi_kopyala='Alış ve Satış belgelerini kopyalayabilirsiniz.' ;
    KTanimsiz_islem= 'Tanımsız bir işlem seçtiniz!'  ;
    KKayit_silinsinmi='Seçili Kayıt Silinecektir, Onaylıyor musunuz?';
    KOnceki_kayit_silinsinmi='Daha önceden aktarılmış bir kaydı tekrar aktarmaya çalışıyorsunuz, Önceki kayıt silinsin mi?';
    KSecili_kisiye_eklensinmi=' "VergiNo - TCNo" Rehber kayıtlarında seçtiğiniz kişiye eklensin mi?';
    KIslem_basarili='İşlem Başarılı.';
    KIslem_basarisiz='İşlem Başarısız.';
    KGecersiz='Geçersiz TC/VK No!';
    KKasa_tanimla='Kasa tanımı yapınız.';
    KOdeme_tipi='Ödeme Tipi Seçiniz.';
    KKupon_tipi='Kupon Tipi Seçiniz.';
    KKasa_bulunamadi='Tanımlı kasa bulunamadı!';
    KSube_sec='Hareketler ortak olmaz! Şube seçin..';
    KHatali_tarih='Kilit tarihi ileri bir tarih olamaz.';
    KGeri_donusu_yok='Veri tabanında ilgili alan genişletilecektir. Bu işlemin geri dönüşü yoktur. Onaylıyor musunuz?';
    KSablon_silinsinmi='Şablonu silmek istiyor musunuz?';
    EFatSenaryoDegisti = 'Bildirimli ürün tespit edildi. Senaryo "İlaç_TıbbiCihaz" olarak değiştirildi!';
    EFatBildirimliUrunTesbiti = 'DİKKAT!! Bildirimli ürün tesbit edildi.. Senaryo kontrolü yapın! Eminseniz devam edin!';
    EFatSenaryoUygunDegil = 'Bildirimli ürün tespit edilemedi. Senaryo "İlaç_TıbbiCihaz" olarak kaydedilemez!';
    SenaryoSecin = 'Senaryo dolu olmalı!';
  //Satın Alma
    SAMail_Bulunamadi='Mail adresi bulunamadı!';
    SAKaydedilemez='Ürün veya hizmet satırı girilmeden kaydedilemez!';

  // İnsan Kaynakları // İzlem Bilgisi
    IKSifirdan_buyuk =' İzin miktarı sıfırdan büyük olmalı.';
    IKDolu_alan =' İzin miktarı daha önce girilmiştir.'  ;
    //IKSifirdan_buyuk = ' İzin miktarı sıfırdan büyük olmalı.';
    IKKayit_bulunamadi='Giriş yapılabilecek opsiyon kaydı bulunamadı!';
    IKDoldurun='Zorunlu alanları boş geçemezsiniz.';
    IKYanlis_taksit_sayisi='Taksit sayısı 1''den küçük veya 24''den büyük olamaz.';
    IKEksik_bilgi='REHBER Hareketleri altında ''İşe Giriş Tarihi'' girilmelidir.';
    IKMaksimum_sayi='Maksimum karakter sayısı :';
    IKSilinemez='Girilmiş bilgi var silinemez!';
    IKMail_atilsinmi='Toplantı bilgileri Katılımcılara e-posta ile gönderilsin mi?';
    Yoplanti_Yeri='Toplantı yeri';

    ekli = 'Zaten eklenmiş!';
    IZBilgi_gir='İzlem bilgisini giriniz!';
    IzlemKullanilmis='İzlem bilgisi başka yerde kullanılmış!';

  // Kullanıcı
    KTum_Kullanicilar = 'Tüm Kullanıcılar';
    KUKaydedilmeden_cikilsinmi='Yapılan Değişiklikler Kaydedilmedi, Çıkmak İstiyor musunuz?';
    KUTekrar_deneyiniz='Lütfen Şifreyi kontrol ederek tekrar deneyiniz.';
    KUGecersiz_sifre='Geçersiz Şifre Girdiniz!';
    KUkullanici_sil='Kullanıcı silinecek onaylıyor musunuz?';
    KURol_sil='Rol Silinecek Onaylıyor musunuz?';
    KUYetkili_rol_giriniz='En az 1 tam yetkili rol bulunmalıdır!';
    KUYonetici_silinemez='Yönetici Rolü silinemez yada değiştirilemez!';


  //Banka
    BCek_kocani_tanimli_silin= 'Bu çek kredisinde çek koçanı tanımlanmış, önce onu silin!' ;
    BHello_world= 'hello world';
    BAksiyon_silinsinmi='Bu aksiyon silinsin mi?' ;
    BBanka_kodu=' Banka koduyla ' ;
    BBanka_adi= 'BANKAADI';
    BBanka_ismi_degistirilsinmi=' banka bulunmuştur.Verdiğiniz banka ismiyle değiştirilsinmi?' ;
    BSube_kodu=' şube koduyla ' ;
    BSube_adi='SUBEADI' ;
    BSube_adi_degistirilsinmi= ' şube bulunmuştur.Verdiğiniz şube ismiyle değiştirilsinmi?';
    BZorunlu_alan_doldur='Zorunlu alanları doldurunuz!' ;
    BAktarim_tamam='Aktarım tamamlandı..' ;
    BSube_var_silinemez='Banka Şubeleri var, silinemez!' ;
    BYapilmis_islem='daha önce bu rotatif kredi için bu referans no ile giriş yapılmış!';
    BPlanlar_silinsinmi='Öncede oluşturulmuş tüm planlar silinecektir.Kabul ediyor musunuz?';
    BTeminat_sonlansinmi='Bu teminatı sonlandırmak istediğinize emin misiniz?';
    BKomisyon_turu_sec='Bir Komisyon Türü Seçmelisiniz!';
    BVadeli_islem_Silinemez='Vadeli işlemler var. Silinemez!';



  //UKullaniciYetki  ,UKullaniciDüzenle
    gorsun = 'Görsün';
    eklesin = 'Eklesin';
    degistirsin = 'Değiştirsin';
    silsin='Silsin';
    yonetici = 'Yönetici';
    kullanici = 'Kullanıcı';
    roldegishata = 'Başlangıç Rolleri ile ilgili değişiklik yapılamaz!';
    yetkileri = ' Yetkileri';
    kullanicilari =' Kullanıcıları';
    rolsilinemez = 'Seçili rolün tanımlı olduğu kullanıcılar mevcut, öncelikle bu kullanıcıların rollerini değiştirip daha sonra silme işlemini tekrar deneyiniz.';
    rolyonsilinemez = 'Yönetici rolü silinemez!';
    mukerrerkod = 'Seçtiğiniz kullanıcı kodu daha önce kullanılmıştır, lütfen düzeltip tekrar deneyiniz..';
    kullanicisilinemez = 'Silmek istediğiniz kullanıcının yapmış olduğu işlemler vardır. Önce bu işlemleri siliniz.';
    rolyok = 'Seçili Rol Bulunamadı!';
    kullaniciyok = 'Seçili Kullanıcı Bulunamadı!!';

  //Banka_ING
    talhata =  'Talimat Hatası: ';
    borhata =  'Bordro Hatası: ';



  ////Errors
      BozukKayit= 'Açmaya çalıştığınız kaydın içeriği bozulmuştur lütfen silip tekrar oluşturunuz.';

  ////captions
      islem41= 'Kasadan bankaya para transferi'; //41
      islem42= 'Bankadan kasaya  para transferi'; //42
      islem43= 'Bankadaki hesaplar arası para transferi'; //43
      islem45= 'Kasadaki nakit paranın bir kısmıyla döviz alma'; //45
      islem46= 'Döviz kasasındaki paranın bir kısmını bozdurma'; //46
      islem47= 'Bankadaki nakit paranın bir kısmıyla döviz alma'; //47
      islem48= 'Döviz hesabındaki paranın bir kısmını bozdurma'; //48
      islem51= 'Elimzde bulunan çeki bankadan tahsil etme';  //51
      islem52= 'Elimzde bulunan senedi bankadan tahsil etme'; //52
      islem53= 'Verdiğimiz çek karşılığı bankadan ödeme';  //53
      islem54= 'Verdiğimiz senet karşılığı bankadan ödeme'; //54
      islem58= 'Alınmış olan kredi taksitlerinin ödemesi'; //58
      islem95= 'Bankoda tahsil edilmiş olan kredi kartlarının girişi';  //95
      islem91= 'Bankoda tahsil edilmiş olan nakit ödemelerin girişi';  //91

    ////Panels
      Tutar123='Tutar:  ';
      banka11='Banka:  ';
      sube11='Sube:  ';
      hesap11='Hesap:  ';
      kasaadi11='Kasa Adı:  ';
      kasakodu11='Kasa Kodu:  ';
      kasakur11='  ';
      posadi='Pos Adı:  ';
      poskodu='Pos Kodu:  ';
      posbankasi='Bankası:  ';



  //UGorevWizard
    SablonYap='Aşağıdaki görevi şablon olarak kaydet.';
    SablonKaldir='Aşağıdaki görevin şablon özelliğini kaldır.';


    GorevAktarim_Kosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1  (A):ListeAdı,'+#13+#10+
              '     * sütun2  (B):Konusu,'+#13+#10+
              '     * sütun3  (C):Türü,'+#13+#10+
              '     * sütun4  (D):Açık/Kapalı(Açık:0/Kapalı:1),'+#13+#10+
              '     * sütun5  (E):Bayrak(Yok:0/Bayrak var:1),'+#13+#10+
              '       sütun6  (F):Durum,'+#13+#10+
              '     * sütun7  (G):Atayan,'+#13+#10+
              '       sütun8  (H):Atanan,'+#13+#10+
              '       sütun9  (I):Başlama Tarihi,'+#13+#10+
              '       sütun10 (J):Bitiş Tarihi,'+#13+#10+
              '       sütun11 (K):Cari Kod, (Dolu ise burası kullanılır)'+#13+#10+
              '       sütun12 (L):Cari Ad,'+#13+#10+
              '       sütun13 (M):Cari İlgili,'+#13+#10+
              '       sütun14 (N):Notlar,'+#13+#10+
              '       sütun15 (N):Yorum,'+#13+#10+
              '   öğelerine sahip olmalıdır. (Yıldızlar zorunlu)' ;


  //URehberWizar
    isimeksikhata = 'Lütfen ilgili kişinin ismini doldurarak tekrar deneyin.';
    zorunlualanhata ='Lütfen farklı renk ile belirlenmiş zorunlu alanların tümünü doldurarak tekrar deneyin.';
    yenisorgugirin ='Yeni sorgunuzu giriniz.';
    RWOnceGrupSeciniz = 'Önce grup seçin!';
    RWAdSoyad = 'Adı Soyadı';
    RWUnvan = 'Ünvan';
    RWBirAy = '1 ay';
    RWUcAy = '3 ay';
    RWAltiAy = '6 ay';
    RWBirYil = '1 yıl';
    RWikiYil = '2 yıl';
    RWTumKayitlar = 'Tüm Kayıtlar';

  //USifre
    SLangChanged = 'Program dili değişti ("%s").'#13#10' Geçerli olabilmesi için yeniden başlatmalısınız';

  //Terazi
    IptalEdilsinmi=' iptal edilecektir, devam etmek istiyor musunuz?';
    DaraKodGirilmemis='Dara için kodlar girilmemiş!';

  //UAnaForm
    Aksiyonlar1 = 'CRM';
    Cari1 = 'Cari';
    CekSenet1 = 'ÇekSenet';
    Banka1 = 'Banka';
    Fatura1 = 'Alış/Satış';
    Kasa1 = 'Kasa';
    Stok1 = 'Stok';
    Demirbas1 = 'Demirbaş';
    Teklif1 = 'Teklif';
    Siparis1 = 'Sipariş';
    Servis1 = 'Servis';
    Dokuman1 = 'Doküman';
    Uretim1 = 'Üretim';
    IK1='İK';
    AFBilgi_birden_fazla_eklenemez='Aynı bilgi birden fazla eklenemez!: ' ;
    AFYanlis_deger_girisi='Yanlış tipte değer girişi yapıyorsunuz!: ';
    AFAd_sifre_destek_gir='Gelecek olan ekrandaki kullanıcı adı ve şifresi kısımlarına destek yazın..';
    AGOkunmayan_akt_gorev='Okunmayan aktivite-görev bilgisi adedi :';
    AGGrafik_kategori_yok='Grafik için Kategori bulunamadı..';
    AGsec_sil='Silinecek Duyuruyu seçiniz.';
    AGKosul_sil='Önce Koşulları Silmelisiniz...';

  // Dokum
    DExele_kaydedildi='Veriler Excele kaydedilmiştir.';
    DRapor_gorulecek_onayi='Tüm kullanıcılar bu raporu görecektir. Onaylıyor musunuz?';
    DRapor_gorulmeyecek_onayi='Tüm kullanıcılar bu raporu göremeyecektir. Onaylıyor musunuz?';
    DEklenmis_fat_tekrar_eklensinmi='Dikkat eklenmiş fatura. Bunu da eklesin mi?';
    DDokum_gormek_icin_yetki='Döküm kopyalandı. Yönetici dışınaki kullanıcıların görmesi için yetki verilmelidir.';

  // Dokuman
   DOKGeriDonusumIslem='Geri Dönüşüm Klasörü üzerinde işlem yapılamaz!';
   DOKBir_Klasor_sart='En az bir klasör bulunmak zorunda..';
   DOKDokumanda_degisiklik_yapan='Doküman üzerinde değişiklik yapılmaktadır. Değişiklik Yapan:';
   DOKAdi_ayni_olacak='Döküman adı aynı olmak zorunda!';
   DOKUzanti_bulunamadi='Dosya uzantısı bulunamadı.';
   DOKEklenmis_dok_bulunamadi='Eklenmiş döküman bulunamadı. ';
   DOKVersiyon_no_ver='Önce şu anki dokümana versiyon no verin';


  //Aboutbox
    ABMusteri_no_yok='Girdiğiniz Müşteri No ile eşleşme sağlanamadı.';
    ABHatali_kod='Müşteri kodunu hatalı girdiniz.';
    ABGuncellendi_tekrar_oturum_ac='Lisans bilgileriniz güncellendi, tekrar oturum açın.';

  //Aktivite
    AKGoogle_takvim_silinemedi='Google Takvim Silinemedi.';
    AKBos_olmaz=' boş olamaz';
    AKTemsilciye_Eposta_gönderilsinmi='Aktivite bilgisi müşteri temsilcisine e-posta gönderilsin mi?';
    AKTemsilciye_SMS_gönderilsinmi='Aktivite bilgisi müşteri temsilcisine sms gönderilsin mi?';
    AKCalendar_kayit_edilemedi='Google calendar kayit edilemedi.';
    AKBos_birakilamaz='Liste boş bırakılamaz';
    AKEtiket_bos_birakilamaz='Etiket adı boş bırakılamaz';

  //Alarm
    ALGorevler_animsaticilardan_cikartilsinmi='Görevlerin tümünü anımsatılacaklardan çıkartmak istediğinize emin misiniz?';

  //Mesajlasma
    MsgDosyayiPaylasiyorsunuz = 'Dosyayı Paylaşıyorsunuz';
    MsgDosyaSizinlePaylasiliyor = 'Sizinle Dosya Paylaşıyor';
    MsgDosyaPaylasiminiIptalEttiniz = 'Dosya Paylaşımını İptal Ettiniz';
    MsgDosyaPaylasiminizIptalEdildi = 'Dosya Paylaşımınız İptal Edildi';
    MsgDosyaPaylasiminiKabulEttiniz = 'Dosya Paylaşımını Kabul Ettiniz';
    MsgDosyaPaylasiminizKabulEdildi = 'Dosya Paylaşımınız Kabul Edildi';
    MsgDosyaPaylasiminiReddettiniz = 'Dosya Paylaşımını Reddettiniz';
    MsgDosyaPaylasiminizReddedildi = 'Dosya Paylaşımınız Reddedildi';
    MsgDosyaAliniyor = 'Dosya Alınıyor';
    MsgDosyaVeriliyor = 'Dosya Veriliyor';
    MsgDosyaAlmayiDurduruldunuz = 'Dosya Almayı Durdurdunuz';
    MsgDosyaPaylasimiAliciTarafindanDurduruldu = 'Dosya Paylaşımı Alıcı Tarafından Durduruldu';
    MsgDosyaVermeyiDurduruldunuz = 'Dosya Vermeyi Durdurdunuz';
    MsgDosyaPaylasimiGonderenTarafindanDurduruldu = 'Dosya Paylaşımı Gönderici Tarafından Durduruldu';
    MsgDosyaAliminizTamamlandi = 'Dosya Alımınız Tamamlandi';
    MsgDosyaGonderiminizTamamlandi = 'Dosya Gönderiminiz Tamamlandi';
    MsgUzerinekayitedilsinmi='Aynı mesaj başlığı ile kayıtlı mesaj var. Üzerine kaydedilsin mi?';
    MsgBaslikYaz='Mesaj başlığı boş bırakılamaz';


  //TEB_Encrypter_TLB
    dtlServerPage = '(none)';
    dtlOcxPage = '(none)';

  //UDokumSart
    STextNotFound = 'Metin bulunmadı';
    SNoSelectionAvailable = 'Arama işlemi tüm metin içerisinde yapılsın mı?';

  //Ekipman
    EHareketli_silinemez='Hareket görmüş ekipman silinemez..';

  //Entegrasyon
    ENTanimlama_yap='Entegrasyon Yapılabilecek Bağlantı Tanımı bulunamadı, önce tanımlama yapmanız gerekmektedir.';
    ENKayit_Silinsinmi='Seçili Kayıt Silinecektir Onaylıyor musunuz?';
    Kaynak_doldur='Kaynak Değeri dolu olmalıdır.';
    ENDegerleri_doldur='Kaynak ve Hedef Değerleri dolu olmalıdır.';
    ENCari_bilgisi_doldur='Cari Bilgisi Boş Olamaz';

  //UDemirbasWizard
    DWYeniDemirbas = 'Yeni Demirbaş girmelisiniz.';
    DWislemYapilmaz = 'Bu demirbaşı ile işlem yapamazsınız.';
    DWTransferYapilmaz = 'Bu demirbaşı transfer yapamazsınız.';
    DWKayitliDegil =  'Bu demirbaş kayıtlı değildir.';
    DWServisYapilmaz = 'Bu demirbaş ile servis işlemi yapamazsınız.';
    DWZimmetYapilmaz = 'Bu demirbaşı zimmet yapamazsınız.';
    DWiadeYapilmaz = 'Bu demirbaşı İade yapamazsınız.';
    DWGarTarihiGir = 'Garanti Bitiş Tarihini giriniz.';
    DWBitisTarihiGir = 'Bitiş Tarihini Giriniz.';
    DWBakimPeriyoduBirimi = 'Bakım Periyodu birimini giriniz.';
    DWTakipSilme='Seçili demişbaş takibini silmek istediğinize eminmisiniz?';
    DWAmortismanBaslik='Amortisman Oranları';
    DWAmortismanSilme='Seçili amortismanı iptal etmek istediğinize eminmisiniz?';

  //USenetWizard
    SWSenetGirBilg = 'Senet Giriş Bilgileri';
    SWSenetCikBilg = 'Senet Çıkış Bilgileri';

  //UCekWizard
    kullanilmisserino = 'Bu Seri No daha önce kullanılmıştır.' ; //UKasaWizard
    CWCekGirBilg = 'Çek Giriş Bilgileri';
    CWCekCikBilg = 'Çek Çıkış Bilgileri';
    CWKontBanka = 'Banka';
    CWKontCariKod = 'Cari Kod';
    CWKontSeriNo = 'Seri No';
    CWKontKod = 'Kod';
    CWKontKesideYei = 'Keşide Yeri';
    CWKontKesideTarihi = 'Vade Tarihi';
    CWKontTutar = 'Tutar';
    CWCekKocaniCek = 'Çek Koçanı Listesi';
    CWCekKocanBulunamadi = 'Tanımlı çek koçanı bulunamadı!';
    CWTarihAtansinmi = 'Seçtiğiniz "Tarih" tatil gününe denk geliyor, sonraki uygun tarih atansın mı?';
    CWKayitIleriTarihliOlamaz = 'Kayıt gelecekte bir tarihe olamaz!';

    DahaOnceKontrolEdilmis = 'Daha önce kontrol edilmiştir.';
  //UCekKocanWizard
    serinohata='Bu aralıktaki Seri Nolar diğer koçanlarda kullanılmıştır.'; //

  //UKasaWizard
    KWOdemeKanali = 'Ödeme kanalı';
    KWTahsilatKanali = 'Tahsilat kanalı';
    KWYapilanHarcamaSec = 'Yapılan harcama hangi masraf kalemine aitse listeden onu seçin';
    KWGirenGelirSec = 'Kasaya giren gelir hangi gelir kalemine aitse listeden onu seçin';
    KWAkt_KayitBulunamadi = 'Seçilen veritabanında aktarılmamış kayıt bulunamadı.';
    KWTahsilatGirisi = ' Tahsilat Girişi';
    KWMusteriAlacaklandir = 'Müşteri''yi alacaklandır';
    KWMusteriBorclandir = 'Müşteri''yi borçlandır';
    KWNakitGirisiVarsa = 'Müşteri''den TL, $, € gibi nakit girişi varsa';
    KWNakitCikisiVarsa = 'Müşteri''ye TL, $, € gibi nakit çıkışı varsa';
    KWHesaplarimizaGonderimYapilmissa = 'Müşteri''den banka hesaplarımıza gönderim yapılmışsa';
    KWHesaplarinaOdemeYapilmissa = 'Müşteri''nin banka hesabına ödeme  gönderilmişse';
    KWCekveyaSenetAlinmissa = 'Müşteri''den Çek veya Senet alınmışsa';
    KWCekveyaSenetVerilmisse = 'Müşteri''ye Çek veya Senetle ödeme yapılmışsa';
    KWKrediKartiileTahsilat = 'Kredi Kartı ile tahsilat';
    KWKrediKartiileOdeme = 'Kredi Kartı ile ödeme';
    KWTahsilatPlani = 'Tahsilat Planı';
    KWDuzenliTahsilat = 'Düzenli Tahsilat';
    KWAvansTahsilati = 'Avans Tahsilatı';
    KWKomisyon = 'Komisyon';
    KWOdemePlani = 'Ödeme Planı';
    KWDuzenliOdeme = 'Düzenli Ödeme';
    KWPersonelMaasi = 'Personel Maaş';
    KWAksiyonSecin = 'Bir aksiyon seçin';
    KWKasadanKasayaTransfer = 'Kasadan kasaya para transferi varsa';
    KWKasadanBankayaTransfer = 'Kasadan bankaya para transferi varsa';
    KWBankadanKasayaTransfer = 'Bankadan kasaya  para transferi varsa';
    KWBankadakiHesaplarArasiTransfer = 'Bankadaki hesaplar arası para transferi varsa';
    KWBankadaArbitraj = 'Banka hesaplar arası arbitraj varsa';
    KWPOSBankaArasiTransfer = 'POS hesabından banka hesabına yapılan para transferi';
    KWKasadakiParaylaDovizAlirsa = 'Kasadaki nakit paranın bir kısmıyla döviz alınırsa';
    KWDovizKasasindakiBozdurulacaksa = 'Döviz kasasındaki paranın bir kısmı bozdurulacaksa ';
    KWBankadakiParaylaDovizAlirsa = 'Bankadaki nakit paranın bir kısmıyla döviz alınırsa';
    KWDovizHesabindakiBozdurulacaksa = 'Döviz hesabındaki paranın bir kısmı bozdurulacaksa';
    KWEldekiCekBankadanTahsilati = 'Elimizde bulunan çek bankadan tahsil edilirse';
    KWEldekiSenetBankadanTahsilati = 'Elimizde bulunan senet bankadan tahsil edilirse';
    KWCekBankadanOdenirse = 'Verdiğimiz çek karşılığı bankadan ödenirse';
    KWSenetBankadanOdenirse = 'Verdiğimiz senet karşılığı bankadan ödenirse';
    KWKrediGirisi = 'Kredi Girişi';
    KWKrediGirisiBankaya = 'Kredi girişi banka hesabına eklnsin mi?';
    KWKrediOdemesiYapilir = 'Kredi kartı taksitlerinin ödemesi yapılır';
    KWKrediOdemesiIade = 'Kredi kartı ödemesinin iadesi yapılır';
    KWAlinmisKrediOdemesiYapilir = 'Alınmış olan kredi taksitlerinin ödemesi yapılır';
    KWNakitOdemelerinGirisiYapilir = 'Bankada tahsil edilmiş olan nakit ödemelerin girişi yapılır';
    KWKrediGirisiYapilir = 'Bankoda tahsil edilmiş olan kredi kartlarının girişi yapılır';
    KWFaizGirisiYapilir = 'Bankadan faiz/kar payı tahsilatı yapılır';
    KWFaizCikisiYapilir = 'Bankaya faiz/masraf ödemesi yapılır';
    KWOnceOdemeKanaliSec = 'Önce ödeme kanalını seçin!';
    KWOnceHesabiTanimla = 'Önce hesabı tanımlayın!';
    KWKasaVeyaBankaHesabiTanimla = 'Tanımlı hesap bulunamadı. Kasa veya Banka hesabı tanımlayın!';
    KWAnaPara = 'Anapara';
    KWFaiz = 'Faiz';
    KWAnaparaveFaiz = 'Anapara+Faiz';
    KWLutfenSecin = 'Lütfen Seçin ';
    KWOdemeTuru = 'Ödeme Türü:';
    KWValorVarmi = 'Valör var mı?';
    KWOdemeEkrani = 'Ödeme Ekranı';
    KWOdemeBilgileriGir = 'Ödeme bilgilerini girin';
    KWTahsilatEkrani = 'Tahsilat Ekranı';
    KWTahsilatBilgileriGir = 'Tahsilat bilgilerini girin';
    KWAnaparaveFaizTutariGir = 'Anapara veya Faiz tutarını girin!';
    KWBakiyedenFazlaOdenemez = 'Kredi ödemesinde Anapara veya Faiz bakiyeden fazla ödenemez!';
    KWTutariGiriniz = 'Tutarı girin!';
    KWDovizdenSonraCikisTLOlmali = 'Döviz satışında çıkış kasası TL olmalı';
    KWDovizdenSonraCikisTLOlamaz = 'Döviz satışında çıkış kasası TL olamaz';
    KWTutarKismiBosOlamaz = 'Tutar kısmı boş olamaz!';
    KWHedefHesapSecYoksaTanimla = 'Önce hedef hesabı seçin, yoksa tanımlayın!';
    KWMiktariGirin = 'Miktarı girin!';
    KWDovizKurunuGiriniz = 'Döviz Kurunu Giriniz: ?';
    KWDovizKarsiGiriniz = 'Döviz Karşılığını Giriniz';
    KWAnaparaBorctanBuyukOlamaz = 'Ödenecek anapara kalan anapara borçtan büyük olamaz!';
    KWFaizBorctanBuyukOlamaz = 'Ödenecek faiz kalan faiz borçtan büyük olamaz!';
    KWKrediKapandiOlarakIsaretlensinmi = 'Bu kredi kapandı olarak işaretlensin mi?';
    KWKapandiOlarakIsaretlensinmi = 'Kapandı olarak işaretlensin mi?';
    KWKrediKartiSec = 'Kredi Kartı Seçme';
    KWCekSenetArama = 'Çek / Senet Arama';
    KWTumu = 'Tümü';
    KWPortfoyde = 'Portföyde';
    KWTahsilEdildi = 'Tahsil Edildi';
    KWCiroEdildi ='Ciro Edildi';
    KWTahsileVerildi = 'Tahsile Verildi';
    KWTeminataVerildi ='Teminata Verildi';
    KWProtestoEdildi = 'Protesto Edildi';
    KWKarsiligiYok = 'Karşılığı Yok';
    KWTahsilEdilemiyor = 'Tahsil Edilemiyor';
    KWKrediSec = 'Kredi Seçme';
    KWOdenmemisler = 'Ödenmemişler';
    KWOdenmisler = 'Ödenmişler';
    KWListedenSec = 'Listeden seçim yapın!';
    KWTahsilEdilmis = 'Daha önce tahsil edilmiş!';
    MiktarBuyuk = 'Miktar Durumdan büyük olamaz!';
    SKTKucukOlamaz='SKT bugünden küçük olamaz!';
    URTKucukOlamaz='URT bugünden büyük olamaz!';
    BugundenBuyukOlamaz='Bugünden büyük olamaz!';
  //UKasaTanımWizard
    KTWKasaKodu = 'Kasa Kodu';
    KTWKasaAdı =  'Kasa Adı';
    KTWParaBirimi ='Para Birimi';

  //UServisWizard
  // Servis
    SERWServis_Servis = 'Servis';
    SERWServis_Servis_dis = 'Dış Servis';
    SERWServis_Servis_ic = 'İç Servis';
    SERWServis_Ekipman = 'Servis Ekipman';
    SERWServis_Problem = 'Servis Problem';
    SERWServis_FizikselDurum = 'Servis Fiziksel Durum';
    SERWServis_Aksesuar = 'Servis Aksesuar';
    SERWServis_Nedeni = 'Servis Nedeni';
    SERWServis_Planlanan = 'Servis Planlanan';
    SERWServis_Yapilan = 'Servis Yapılan';
    SERWServis_Uygulama = 'Servis Uygulama';
    SERWServis_Iade = 'Servis İade';
    SERWServis_Testler = 'Servis Testler';
    SERWServis_Giderler= 'Servis Giderler';
    SERWServis_Notlar = 'Servis Notlar';
    SERWServisEkipman = 'Servis Ekipmanları';
    SERWSorumluOldugunServisVar = 'Sorumlu olarak atandiginiz yeni bir servis var. Servis No:';
    SERWBelge_olusturuldu='Seçilen uygulamaların belgesi oluşturulmuştur.';
    SERWMusteri_SMS='Servis bilgisi müşteri temsilcisine sms gönderilsin mi?';
    SERWMusteri_EPosta='Servis bilgisi müşteri temsilcisine e-posta gönderilsin mi?';
    SERWOnaysiz_uygulanamaz='Onaysız işlemler uygulanamaz!';
    SERAd_Gir='Ad alanı boş bırakılamaz!';
    SERYanlis_tarih='Bitiş tarihi başlamadan önce olamaz!';
    SERBaslik_belirtin='Başlık veya Detay olduğunu belirtiniz. ';
    Servis_Atanan_Dolu_Olmali = 'Servisi kapatmak için en az bir atanan olmalı!';
    Servis_Har_Baslangic = 'Servis hereketi eklenemedi. Lütfen servis opsiyonları içerisinden uygun şekilde düzenleyin.';
    SonSerisHareketiEksik = 'Son servis hareketi henüz tamamlanmamış. Yeni bir hareket eklemeden önce Başlama ve Bitiş alanlarını doldurmalısınız.';
  //UGorevWizard
    GWGecmiseAtanamaz = '"Bitiş Tarihi" geçmişe atanamaz!';
    GWGecmisTarihliSecilmez = 'Görev Başlangıç tarihi geçmiş tarihli seçilemez';
    GWBitTarihKucukSecilemez = 'Bitiş tarihi Başlama tarihinden küçük olamaz';
    GWGunSecimiYapilmali = 'Öncelikle gün seçimi yapmalısınız';
    GWKacHaftadaBirYapilacak = 'Planlamanın kaç haftada bir yapılacağını seçiniz';
    GWYeniTarihDegeri = 'Yeni Tarih Değeri';
    GWErtelemeTarihiGirin = 'Erteleme Tarihi girin';
    GWErtelemeTarihiBosOlmaz = 'Erteleme Tarihi Boş Olamaz.';
    GWDegisiklikIcınAciklamaGir = 'Durum değişikliğiniz için bir açıklama giriniz.';
    GWAciklamaGir = 'Açıklamayı girin';
    GWAciklamaBosOlamaz = 'Açıklama Boş Olamaz.';
    GWDurumYeniGorevOlamaz = 'Görevin Durumu Yeni Görev olarak değiştirilemez!';
    GWDegisiklikKaydedilmedi = 'Hata: Değişiklik kaydedilemedi!';
    GWSablonYok = 'Böyle bir şablon artık yok!';
    GWAynıisimdeSablonVar = 'Aynı isimde çok sayıda şablon var!';
    GWAktarilamayanAlanlar = 'Aktarılamayan Alanlar:';
    GWYeniGorevOlustur = 'Yeni Görev Oluşturma Sihirbazı';
    GWGorevDuzenleme = 'Görev Düzenleme Sihirbazı';
    GWYeniGorevSablonuOlustur = 'Yeni Görev Şablonu Oluşturma Sihirbazı';
    GWGorevSablonuDuzenleme = 'Görev Şablonu Düzenleme Sihirbazı';
    GWBoyleBirGorevYok = 'Böyle bir görev yok!!!';
    GWIslemOpBelirtilmeli = 'İşlem Op Belirtilmeli!!';
    GWKayitlardaHatalarOlustu = 'Bazı kayıtlarda hatalar oluştu: ';

  //UProjeWizard
    PWSilerekTekrarDeneyin = 'Detay Kayıtları varken bu işlemi gerçekleştiremessiniz, detay bilgilerini silerek tekrar deneyiniz.';
    PWHepsiSilinecektirUyari = 'Yeni şablon oluşturulurken bu bölümdeki girilmiş tüm detay bilgileri silinecektir.';
    PWSonucBilgisiGir = 'Projeyi kapatırken Sonuç Bilgisi girilmelidir.';
    PWBitRarihKucukSecilemez = 'Proje Bitiş tarihi Başlama tarihinden küçük olamaz';
    PWListefiyatiKurBilgisiGir = 'Liste Fiyatı için kur bilgisi giriniz';
    PWSatisFiyatiKurBilgisiGir = 'Satış Fiyatı için kur bilgisi giriniz';
    PWSeciliKaydiListedenSil = 'Seçili Kaydı listeden silmek istiyor musunuz?';
    PWTurSec='Proje Tipi Tanımı yapabilmek için Proje Türü Seçilmelidir';
    PWButceAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Kod (Yazı),'+#13+#10+
              '     * sütun2(B):Ad (Yazı),'+#13+#10+
              '     * sütun3(C):Birim (Yazı),'+#13+#10+
              '     * sütun4(D):Miktar (Numerik),'+#13+#10+
              '     * sütun5(E):Birim Fiyat (Numerik) '+#13+#10+
              '     * sütun6(F):Tutar (Numerik) '+#13+#10+
              '   öğelerine sahip olmalıdır.';
    PWReceteAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Ürün Kodu (Yazı),'+#13+#10+
              '     * sütun2(B):Ürün Adı (Yazı),'+#13+#10+
              '     * sütun5(C):Sarf Kodu (Yazı) '+#13+#10+
              '     * sütun6(D):Sarf Adı (Yazı) '+#13+#10+
              '     * sütun4(E):Miktar (Numerik),'+#13+#10+
              '     * sütun3(F):Birim (Yazı),'+#13+#10+
              '   öğelerine sahip olmalıdır.';
    PWReceteOprAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Reçete ID (Numerik),'+#13+#10+
              '     * sütun2(B):Konusu (Yazı),'+#13+#10+
              '     * sütun4(c):Sıra (Numerik),'+#13+#10+
              '   öğelerine sahip olmalıdır.';

  //UFaturaWizard
    FWYuzdesiniGirin = 'Yüzdesini girin';
    FWToplamTutariGir = 'Toplam tutarı girin.';
    FWKurGir = 'Kuru girin.';
    FWMalFazlasiGir = 'Mal fazlası olarak verilecek miktarı girin.';
    FWTutarGir = 'Yeni tutarı girin. Bu işlem birim fiyatları değiştirecektir!';
    FWGiris = 'Giriş ';
    FWCikis = 'Çıkış ';
    FWGelen = 'Gelen ';
    FWGiden = 'Giden ';
    FWGiderPusula = 'Gider Pusulası';
    FWIrsaliye = 'İrsaliye';
    FWFatura = 'Fatura';
    FWFis = 'Fiş';
    FWKonsinye = 'Konsinye';
    FWSayfa = 'Sayfa';
    FWBasligi = ' Başlığı';
    FWAdresi= ' Adresi';
    FWIlcesi= ' İlçesi';
    FWIli = ' İli';
    FWVD = ' Vergi Dairesi';
    FWVNO = ' Vergi No';
    FWVade = ' Vade';
    FWBilgileri = ' bilgileri';
    FWOlustur = ' Oluştur';
    FWSeciniz = 'Seçiniz';
    FWKurumunaGiden = ' Kurumuna Giden ';
    FWKurumundanGelen = ' Kurumundan Gelen ';
    FWKaynagaUygulansinmi = 'İşlem Kaynak Belgeye de uygulansın mı?';
    FWHedefeUygulansinmi = 'İşlem Hedef Belgeye de uygulansın mı?';
    FWKayitSilinemez = 'Bu ürüne ait seri numaraları hareket görmüş.Kayıt silinemez.';
    FWKayitBelgeYilindanFarkliOlamaz = 'Kayıt yılı belge yılından küçük olamaz.';
    FWKayitveBelgeTarihiIleriTarihOlamaz = 'Kayıt tarihi ve belge tarihi ileri bir gün olamaz.';
    FWSadeceRakamGir = 'Fatura numarasında rakam dışında karakter olamaz!';
    FWFaturaNoKullanilmistir = ' tarihinde bu fatura numarası kullanılmış!';
    FWFislerdeEkranKullanilmaz = 'Belge türü Fiş olan kayıtlar için bu ekran kullanılamaz';
    FWFirmayaAitSiparisYoktur = 'Bu firmaya ait sipariş bulunmamaktadır.';
    FWFirmayaAitIrsaliyeYoktur = 'Bu firmaya ait irsaliye bulunmamaktadır.';
    FWFirmayaAitSiparisIrsaliyeYoktur = 'Bu firmaya ait Sipariş ve İrsaliye bulunmamaktadır.';
    FWNoluFatura = 'Nolu Fatura';
    FWFaturaninTahsilati = 'Nolu Faturanın Tahsilatı.';
    FWFaturaninOdemesi = 'Nolu Faturanın Ödemesi.';
    FWIadeurunbulunamadi='İade alınacak ürün bulunamadı';
    FWBubasliktakikayitlarsilinsinmi='Bu başlığın altındaki bütün kayıtlar silinecektir. Onaylıyor musunuz?';
    FWAdkullanilmis='Bu adla daha önce eklenmiş..';
    KonsinyeDeismez='Konsinye carisi değişemez!';
      Yetersiz_Miktar='Yetersiz miktar.. Başka bilgisayardan çıkılmış olabilir..';
  //UFatTransferWizard
    FTWTransferleriSil = 'Önce Transfer satırlarını silmeniz gerekiyor';
    FTWGirisDeposuBosOlamaz = 'Giriş Deposu boş olamaz';
    FTWCikisDeposuBosOlamaz = 'Çıkış Deposu boş olamaz';
    FTWDepolarAyniOlamaz = 'Giriş Çıkış Depoları aynı olamaz';
    FTWTarihKucukOlamaz = 'Başlama bitişten sonra olamaz';
    FTWTarihUzakOlamaz = 'Verdiğiniz tarih o kadar uzak olamaz';

  //UMakbuzWizard
    MWTahsilat = 'Tahsilat ' ;
    MWOdeme = 'Ödeme ';
    MWMakbuzNo= 'Makbuz No ';
    MWSeciliMakbuzSilinecek = 'Seçili Makbuz satırı silinecektir. Onaylıyor musunuz?';
    MWSatirGirilmisSilinemez = 'Girilmiş detay satırı var, değiştirilemez!';

  //UTeklifWizard
  //Teklif
    TETeklifSiparisiOlusturuldu='Bu Teklifin siparişi oluşturulmuştur.';
    TESevkAdresiGir='Sevk adresi boş olamaz.';
    TWAlternatif = 'Alternatif ';
    TWYeniTeklifeAit = 'Teklif kopyalandı. Ekrandaki görüntü yeni teklife aittir..';
    TWDetaySatirBos='Teklif detay satırları boş olamaz.';
    TWOnayIptal='Tüm Onaylar Kaldırılacaktır!';
    TWSilinsinmi=' alanını silmek istiyor musunuz ?';
    TWDikkatMusteriDegistirme='Dikkat! Bu teklifin müşterisini değiştiriyorsunuz. ';

  //UTalimatWizard
  //Talimatlar
    SurecAdimindakiKullanici='Süreç adımındaki kullanıcı:';
    KullaniciEklendi = 'Kullanıcı olarak eklendi';
    TalimatSilinemez='Sürecin içerisinde işlem görmüş talimat. silinemez.' ;
    BankaDeseniYok='Bu banka için desen bulunmamaktadır..';
    TalWBankaTalimati = 'Banka Talimatı';
    TalWTalimat = 'Talimat: ';
    TalWTarihAralikOdeme = ' tarih aralığındaki ödeme.';
    TalWile = ' ile ';
    TalWAlacaktanBuyukOlamaz = ' için yapılacak ödemede Borç, Alacaktan büyük olamaz..';
    TalWTalimatSlash = 'Talimat\';
    TalWDosyayaYazilamadi = 'Dosya veritabanına yazılamadı!';
    TalWKaydetmedenCikacakmisin = 'Yaptığınız değişiklikleri kaydetmeden çıkmak istediğinize emin misiniz?';
    TalWIslemIptalEdiliyor = 'Kayıt işlemi iptal ediliyor.';
    TalW14HaneliGiriniz = 'Başında 0 ile 14 haneli giriniz.';
    TalWTurkceKarakterHaric = 'Türkçe karakter içermeden giriniz';
    TalWYeni = 'Yeni ';
    TalWDegeri = ' Değeri';
    TalWSeciliIsleminizYok = 'Seçili işleminiz yok!';
    IslemUzunSurebilir = 'Bu işlem uzun sürebilir. Devam edilsin mi?';

  //UAktiviteWizard
    AWNo ='No        :';
    AWTuru = 'Türü';
    AWTipi = 'Tipi      :';
    AWSorumlu = 'Sorumlu   :';
    AWKapsam = 'Kapsam   :';
    AWAtayan = 'Atayan    :';
    AWTakipci = 'Takipçi   :';
    AWBilgi = 'Bilgi     :';
    AWKonusu = 'Konusu    :';
    AWKonum = 'Konum     :' ;
    AWMusteri = 'Müşteri   :';
    AWDurum = 'Durum     :';
    AWPuan = 'Puan      :';
    AWOncelik = 'Öncelik   :';
    AWBaslangic = 'Başlama :';
    AWBitis = 'Bitiş     :';
    AWNotlar = 'Notlar';
    AWMusteriSecimiYap = 'Önce Müşteri Seçimi Yapmanız gerekmektedir.';
    AWBuPersonelSecilemez = 'Seçilen personel bu tarihte izinli, bu personel seçilemez';
    AWVekaletEdenSecilecek = 'Seçilen personel bu tarihte izinli, vekalet eden personel seçilecek.';
    AWVekaletEdenSecilmemis = 'Seçilen personel bu tarihte izinli, vekalet edecek personel seçilmemiş. İzinler ekranından gerekli ayarlamayı yapıp tekrar deneyiniz.';
    AWPersonelBuTarihteIzinli = 'Seçilen personel bu tarihte izinli';
    AWGecmisTarihliSecilemez = 'Görev Başlangıç tarihi geçmiş tarihli seçilemez';
    AWGorevBitisTarihiBuyukOlacak = 'Görev Bitiş tarihi Başlama tarihinden küçük olamaz';
    AWGunSecimiYapmalisiniz = 'Öncelikle gün seçimi yapmalısınız';
    AWTurBosOlamaz = 'Tür bilgisi boş olamaz';
    AWDetayBilgileriniSilTekrarDene = 'Detay Kayıtları varken bu işlemi gerçekleştiremessiniz, detay bilgilerini silerek tekrar deneyiniz.';
    AWAktarilamayanAlanalar = 'Aktarılamayan Alanlar:';
    AWBoyleBirSablonArtikYok = 'Böyle bir şablon artık yok!';
    AWAyniIsimdeSablonVar = 'Aynı isimde çok sayıda şablon var!';
    AWKaydediliyorOnayliyormusun = 'Öncelikle yaptığınız değişikliklerin kaydedilmesi gerekmektedir. Onaylıyor musunuz?';
    AWBitisTarihiKucukOlamaz = 'Bitiş tarihi başlama tarihinden küçük olamaz!';
    AWOnceMusteriSecin = 'Önce müşteri seçin!';
    AWAktiviteTuru = 'Aktivite Türü';
    AWSorumluBilgisi = 'Sorumlu Bilgisi';
    AWAktiviteKonusu = 'Aktivite Konusu';
    AWYeniFirmaAdi = 'Yeni Firma Adı.';
    AWSablonAdiniGiriniz = 'Şablon Adını Giriniz';
    AWSablonTanımlandi = 'Şablon Tanımlandı';
    AWSorumluOldugunAktiviteVar = 'Sorumlu olarak atandiginiz yeni bir aktivite var.Aktivite No:';
    AWTakipciOldugunAktiviteVar = 'Takipci olarak atandiginiz yeni bir aktivite var.Aktivite No:';
    AWBilgilendirilecekOldugunAktiviteVar = 'Bilgilendirilecek kisi olarak secildiginiz yeni bir aktivite var.Aktivite No:';
    AWNotGirisiSilinebilir = 'Not girişi sadece ekleyen kullanıcı tarafından silinebilir';
    AWNotSahibiDuzenlemeYapabilir = 'Bu not üzerinde sadece not sahibi düzenleme yapabilir';
    AWSorumluHaricindeEklemeYapılmazAltEkle = 'Sorumlu haricinde ekleme yapılmaz.Ancak alta ekleme yapabilirsiniz.';
    AWSorumluHaricindeDegisYapilmaz = 'Sorumlu haricinde değişiklik yapılmaz.';
    AWSorumluHaricindeEklemeYapilmaz = 'Sorumlu haricinde ekleme yapılmaz.';
    AWGoreviAtayanHaricindeOnaylandiYapilmaz = 'Görevi Atayan haricinde Onaylandı yapılmaz.';
    AWSorumluHaricindeSilmeYapilmaz = 'Sorumlu haricinde silme yapılmaz.';
    AWGoreviAtayanVeSorumluAyniOlamaz = 'Görevi Atayan ve Sorumlu aynı olamaz.';


  //UBankaTanimWizard
    BTWIBANGecersiz = 'IBAN Numarası Geçersiz!';
    BTWYeniBankaGir = 'Yeni Banka Adını Giriniz.';
    BTWBankaAdi = 'Banka Adı:';
    BTWBankaAdiBosOlamaz = 'Banka Adı Boş Olamaz.';
    BTWYeniSubeGir = 'Yeni Şube Adını Giriniz.';
    BTWSubeAdi = 'Şube Adı:';
    BTWSubeAdiBosOlamaz = 'Şube Adı Boş Olamaz.';
    BTWYeniSubeKoduGir = 'Yeni Şube Kodunu Giriniz.';
    BTWSubeKoduBosOlamaz = 'Şube Kodu Boş Olamaz.';

  //UOpsDlg
    ODlgHerYilTatikicin = ' Her yıl,  tatil için';
    ODlgTatilinAdiniGiriniz = 'Tatilin adını giriniz :';
    ODlgGunuGiriniz = 'Günü giriniz :';
    ODlgAyiGiriniz = 'Ayı Giriniz';
    ODlgOnayliyormusunu = ' silinecektir. Onaylıyor musunuz?';
    ODlgAktifFisKocanNo = 'Fiş Koçan No:';
    ODlgAktifFaturaKocanNo = 'Fatura Koçan No:';
    ODlgAktifIrsaliyeKocanNo = 'İrsaliye Koçan No:';
    ODlgAktifAlisSiparisKocanNo = 'Alış Siparişi Koçan No:';
    ODlgAktifSatisSiparisKocanNo = 'SatışSiparişi Koçan No:';
    ODlgAktifGiderPusulasiKocanNo = 'Gider Pusulası Koçan No:';
    ODlgAktifIrsaliyeliFaturaKocanNo = 'İrsaliyeli Fatura Koçan No:';
    ODlgAktifTransferKocanNo = 'Transfer Fişi Koçan No:';
    ODlgAktifServisKocanNo = 'Servis Fişi Koçan No:';
    ODlgAktifATeklifKocanNo = 'Alınan Teklif Koçan No:';
    ODlgAktifVTeklifKocanNo = 'Verilen Teklif Koçan No:';

    ODlgAktifTahsilKocanNo = 'Tahsilat Makbuz No:';
    ODlgAktifTediyeKocanNo = 'Tediye Makbuz No:';
    ODlgAktifVirmanKocanNo = 'Virman Makbuz No:';



    ODlgBayraminilkGununun = ' bayramının ilk gününün';
    ODlgGununuGiriniz = 'Gününü giriniz :';
    ODlgAyiniGiriniz = 'Ayını Giriniz';
    ODlgStilTanimiYapiniz = 'Önce stil tanımı yapmanız gerekmektedir.';
    ODlgStilKosulSilinecektir = 'Seçili Stil koşul tanımı silinecektir. Onaylıyor musunuz?';
    ODlgStilSilinecektir = 'Seçili Stil tanımı silinecektir. Onaylıyor musunuz?';
    ODlgSMSServisBosOlamaz = 'SMS Servisi Boş Olamaz';
    ODlgBilgilerBosBirakilamaz = 'Kullanıcı Adı-Şifre-Başlık bilgileri boş olamaz';
    ODlgStilAdiBosBirakilamaz = 'Stil Adı Boş Bırakılamaz';

  //UNakitDlg
    NDTutarDoluOlmali = 'Tutar dolu olmalı!';
    NDAlis = 'Alış: ';
    NDSatis = 'Satış: ';
    NDEfAlis = 'Ef.Alış: ';
    NDEfSatis = 'Ef.Satış: ';
    NDPos = 'POS: ';
    NDKurBilgisiBosOlamaz = 'Kur Bilgisi Boş Olamaz';
    NDBakiyeYetersiz = 'Bakiye yetersiz!';
    NDBakiyeYetersizDevammi ='Bakiye yetersiz! Yine de devam etsin mi?';
    NDKalanBakiye = 'Kalan Bakiye:';

  //URehAraDlg
    RDAksiyonSilinsinmi = 'Seçilen aksiyonlar silinsin mi?';
    RDYorumMedyaVarSilinemez = 'Yorum/Medya var, Silinemez!';
    RDDOFVarSilinemez = 'DÖF bilgisi var, Silinemez!';
    RDGorevVarSilinemez = 'Görev bilgisi var, Silinemez!';
    RDAnaFirmaSilinemez = 'Ana Firma Silinemez!';
    RDYoneticiKullaniciSilinemez = 'Yönetici Kullanıcı Silinemez!';
    RDKrediTanimiSilinemez = 'Kredi Tanımı Silinemez!';
    RDBankaTanimiSilinemez = 'Banka Tanımı Silinemez!';
    RDPlanVerisiVarSilinemez = ' tarihinde girilmiş ödeme,tahsilat veya plan verisi var, silinemez!';
    RDFaturaVerisiVarSilinemez = 'Girilmiş fatura verisi var, silinemez!';
    RDCekVerisiVarSilinemez = 'Girilmiş çek verisi var, silinemez!';
    RDSenetVerisiVarSilinemez = 'Girilmiş senet verisi var, silinemez!';
    RDPersonelBigisiVarSilinemez = 'Girilmiş personel bilgisi var, silinemez!';
    RDiletisimBigisiVarSilinemez = 'Girilmiş iletişim bilgisi var, silinemez!';
    RDBankaVerisiVarSilinemez = 'Girilmiş banka bilgisi var, silinemez!';
    RDProjeVerisiVarSilinemez = 'Girilmiş proje bilgisi var, silinemez!';
    RDAktiviteVerisiVarSilinemez = 'Girilmiş aktivite verisi var, silinemez!';
    RDTeklifVerisiVarSilinemez = 'Girilmiş teklif verisi var, silinemez!';
    RDServisVerisiVarSilinemez = 'Girilmiş servis verisi var, silinemez!';
    RDServisHarVerisiVarSilinemez = 'Girilmiş birden çok hareket verisi var, silinemez!';
    RDServisTekHareketVarSilinemez = 'Bir serviste en az bir hareket olmalıdır, silinemez!';
    RDKararVerisiVarSilinemez = 'Girilmiş karar verisi var, silinemez!';
    RDDokumanVerisiVarSilinemez = 'Girilmiş döküman verisi var, silinemez!';
    RDYeniilgiliADSoyadGir = 'Yeni İlgili Adı-Soyadını Giriniz.';
    RDIlgiliIletisimSec = 'Kopyalanacak İletişim Bilgilerini Seçiniz.';
    RDIletisimAdresiSecimi = 'İletişim Adresi Seçimi';
    RDAdSoyad = 'Ad-Soyad: ';
    RDIlgiliGecmisi = 'İlgili Geçmişi';
    RDGirilmisBankaBilgisiVarSilinemez = ' tarihinde girilmiş banka bilgisi var, silinemez!';
    RDOnceAramaYapin = 'Önce arama yapın!';
    RDAlisveSatisBelgeKopyalayin = 'Alış ve Satış belgelerini kopyalayabilirsiniz.';

  //UTahakkukDlg
    TDTutarDoluOlmali = 'Tutar dolu olmalı!';

  //UStokListeDlg
    SDStok = 'Stok';
    SDKSeviyeMiktariBilgisi = ' için Seviye Bilgisi';
    SDKMaksimumSeviyeMiktariGir = 'Maksimum Seviye Miktar Giriniz';
    SDKMinimumSeviyeMiktariGir = 'Minimum Seviye Miktar Giriniz';
    SDKKritikSeviyeMiktariGir = 'Kritik Seviye Miktar Giriniz';
    SDBaglantiZamanAsimi = '-Bağlantı Zaman Aşımı!';
    SDKartTanimliDegil = '-Kart Tanımlı Değil!';
    SDStokSayimVerisiVarSilinemez = 'Girilmiş stok sayımı verisi var, silinemez!';
    SDStokVerisiVarSilinemez = 'Girilmiş stok verisi var, silinemez!';
    SDStokDetayKopyalansinMi = 'Detay bilgilerini de kopyalamak ister misiniz?';
    SDStokEkleme = 'Giriş';
    SDStokCikartma = 'Çıkış';
    SDStokTiransfer = 'Transfer';
    SDStokDurum = 'Durum';
    SDStokGirisDepo = 'Giriş Depo';
    SDStokCikisDepo = 'Çıkış Depo';
    SDVarsayilan_Depo='Varsayılan Depo';
    SDStokAciklama = 'Açıklama';

  //STOK
    STUrun_var='Bu ürün daha önce eklenmiş;' ;
    STYeniSatir=' Yeni bir satır daha eklemek istiyor musunuz)';
    STUzerine_ekle=' Üzerine eklemek için Evet';
    STYeni_satir_hayir=' Yeni Satır için Hayır';
    STIptale_tiklayin=' İşlemi iptal etmek için İptal e tıklayın' ;
    STBu_islem_var='Bu hizmet daha önce eklenmiş;' ;
    STeklemek_icin_Evet=' Üzerine eklemek için Evet';
    STSatir_hayir='Yeni Satır için Hayır' ;
    STIslem_iptal=' İşlemi iptal etmek için İptal e tıklayın';
    STstok_adi='STOKADI'  ;
    STListeden_cik=' listeden çıksın mı?' ;
    STUrun_listede_var='Seçilen ürün listede vardır.' ;
    STKilide_islem_yapilamaz='Kilit tarihi ve öncesine işlem yapılamaz !' ;
    DahaOnceEklenmis='Daha önce eklenmiş!' ;
    STRecete_bulunamadi='Kayıtlı Reçete Bulunamadı.';
    STsil_tekrar_dene='Birden fazla sayıda reçete bulundu.. Lütfen fazla reçeteleri silerek tekrar deneyin.';
    STOnce_sil='Önce sayım kalemlerini silmeniz gerekmektedir.' ;
    STDepo_bos_olmaz='Sayım Depo Bilgisi Boş olamaz' ;
    STFiyat_gir='Fiyat Adı Boş Olamaz' ;
    STHepsi_silinecek_onay='Bütün Sayım Kalemleri Temizlenecektir. Onaylıyor musunuz?';
    STDuzenleniyor_tekrar_dene='Sayım Tutanağındaki düzenleme modunda, işlemi tamamladıktan sonra tekrar deneyiniz.';
    STTutanak_onayla='Stok Durumu güncellemek için sayım tutanağının onaylanmış olması gerekmektedir.';
    STUrun_kaydi_yok='Sayım Tutanağında ürün kaydı bulunamadı' ;
    STOnaylanmamis_sayim_ekran_kapansinmi='Sistemde henüz Onaylanmamış sayım var, Ekranı kapatmak istiyor musunuz?' ;
    STsayim_sil_onay='Seçili sayım bilgisi silinecektir. Onaylıyor musunuz?' ;
    STAktarim_kosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):Kod (Yazı),'+#13+#10+
              '     * sütun2(B):Ad (Yazı),'+#13+#10+
              '     * sütun3(C):Birim (Yazı),'+#13+#10+
              '     * sütun4(D):Adet (Numerik),'+#13+#10+
              '     * sütun5(E):Birim Fiyat (Numerik)'+#13+#10+
              '     * sütun6(F):Sonuç Alanı (Boş, bu alan aktarım sırasında doldurulacaktır)'+#13+#10+
              '   öğelerine sahip olmalıdır.'      ;
    STAktarim_tamam='Aktarım tamamlandı.';
    STListede_var='Seçilen ürün listede vardır.';
    STAlan_silinsinmi=' alanını silmek istiyor musunuz ?' ;
    STStokfiyat_kontrol_et='Opsiyonlar/Stok/Fiyat Listelerinden StokFiyatları kontrol ediniz.';
    STMarka_sec='Model Tanımı yapabilmek için Marka Seçilmelidir';
    STBarkodu_doldur='Barkod Bilgisi Boş Olamaz' ;
    STGecerli_deger_gir='Barkod birimi için geçerli bir değer seçiniz';
    STStokkart_tanimli_deger_gir='Barkod birimi için stok kartında tanımlı olan bir değer giriniz' ;
    STAciklama_alani_doldur='Açıklama alanı boş olamaz';
    STUrun_once_girilmis=' kodlu ürün daha önce girilmiş';
    STKampanya_kodu_degistir='Kampanya Kodu farklı olmalı.';
    STKampanya_adi_degistir='Kampanya Adı farklı olmalı.';
    STkod_sifir_olamaz='Kod Sıfır(0) olamaz'  ;
    STkategorisinde=' kategorisinde '  ;
    STKayit_etkilendi=' kayıt etkilenmiştir.' ;
    STKayit_bulunamadi=' kategorisinde uygulanacak kayıt bulunamadı.';
    STHareketli_Silinemez='Hareket görmüş kayıt silinemez!';
    STBirimler_farkli_degismez='Anabirim ve 2.birim farklı.. Değiştirilemez!' ;
    STDepo_adi='DEPOADI' ;
    STDepo_silinsinmi=' adlı depo silinsin mi?';
    STBarkod_uretiminde='Barkod üretiminde;'+#13#10
                +'"_" karakteri, barkodun sayaç bölümünü,'+#13#10
                +'"#" karakteri, barkodun miktar(gram/kg) bölümünü'+#13#10
                +'"$" karakteri, barkodun miktar(Adet) bölümünü'+#13#10
                +'"G" karakteri, barkodun Gün bölümünü'+#13#10
                +'"A" karakteri, barkodun Ay bölümünü'+#13#10
                +'"Y" karakteri, barkodun Yıl bölümünü(2 veya 4 karekter)'+#13#10
                +'"L" karakteri, barkodun Lot Numarasını'+#13#10
                +'"S" karakteri, barkodun Seri Numarasını'+#13#10
                +'"C" karakteri, barkodun Checksum bölümünü'+#13#10
                +'"O" karakteri, barkodun 1. Boyutunu'+#13#10
                +'"P" karakteri, barkodun 2. Boyutunu'+#13#10
                +'"Q" karakteri, barkodun 3. Boyutunu'+#13#10
                +'gösterir'      ;
    STDepo_hareketli_silinmez='Depo hareket görmüştür, silinemez.';
    STDepo_SiparişHareketi_silinemez='Depo sipariş hareketi görmüştür, silinemez.';
    STDepo_SiparisHareketi_silinemez='Depo siparis hareketi gormustur, silinemez.';
    STDepo_servisHareketi_silinemez='Depo servis hareketi görmüştür, silinemez.';
    STayni_isim_var='Aynı isimde depo eklenemez.' ;
    SFarkli_isim_var='Farklı isimde depo eklenemez.' ;
    STMerkez_bir_depo_olmali='Varsayılanı Merkez olan en az bir depo olmalı.';
    STEKlenen_depo_merkezde_olmali='Eklenen ilk deponun Varsayılanı Merkez olmalı.' ;
    STFiyatadi_kayitli='Bu Fiyat adı kayıtlıdır.';
    STFiyatadi_silinecekmi=' fiyat adı silinecektir. Onaylıyor musunuz?';
    STFiyatadi_silinemez='Bu Fiyat adı son kayıttır. Silinemez.';
    STFiyatadi_tasinsinmi=' Fiyat adı taşınacaktır. Onaylıyor musunuz?';
    STListe_fiyatadi_sec='Listede görünecek Alış-Satış fiyat adlarını seçiniz.';
    STListeden_sec='Listeden seçim yapınız.';
    STFiyatadi_tasindi=' Fiyat adı taşınmıştır.';
    STBos_tutar_olusturuldu=' fiyatının boş tutarları oluşturuldu..';
    STRakam_gir='Sadece rakam giriniz.';
    STFiyat_adi_gir='Fiyat adı boş olamaz.';
    STBilgi_alani_doldur='Boş bilgi alanı olamaz!';
    STYanlis_karakter='Yanlış karakter girilmiş!';
    STKod_degistir='Kampanya Kodu farklı olmalı.';
    STad_degistir='Kampanya Adı farklı olmalı.';
    STSiliniz='Önce koşul ve sonuçları silmelisiniz!';
    STTestadi_kayitli='Bu Test adı kayıtlıdır.';
    STSablonadi_kayitli='Bu Şablon adı kayıtlıdır.';

  //UProjeListeDlg
    PDFaturaVerisiVarSilinemez = 'Girilmiş Fatura verisi var, Silinemez';

  //UAktiviteListeDlg
    ADOkunmayan = 'Okunmayan ';
    ADAktiviteGorevBilgisiVar = ' adet aktivite-görev bilgisi var';
    ADKaydiOlusturanSilebilir = 'Bu kayıt başkası tarafından oluşturulmuştur, Yalnızca oluşturan kişi kaydı silebilir';
    ADBagliAktiviteVarSilinemez = 'Bu Aktiviteye Bağlı Aktivite verisi var, Silinemez';
    ADKaydiOlusturanDegistirebilir='Bu kayıt başkası tarafından oluşturulmuştur, Yalnızca oluşturan kişi kaydı değiştirebilir';
    ADKaydiOlusturanOnaylayabilir='Bu kayıt başkası tarafından oluşturulmuştur,Yalnızca oluşturan kişi kaydı Onaylayabilir.';

  //UDemirbasListeDlg
    DDFarkliDurumVeZimmetSahibiSecilemez = 'Farklı durum ve zimmet sahibi seçilemez';
    DDDemirbasFarkliDurum= 'Farklı durumdaki demirbaşlar bir arada işlem göremez!';
    DDDemirbasileIslemYapamazsiniz = 'Bu demirbaşı ile işlem yapamazsınız.';
    DDDemirbasiIadeYapamazsin = 'Bu demirbaşı İade yapamazsınız.';
    DDDemirbasiZimmetYapamazsin = 'Bu demirbaşı Zimmet yapamazsınız.';
    DDDemirbasKayipIslemYapamazsin = 'Bu demirbaş ile kayıp işlem yapamazsınız.';
    DDDemirbasiTransferYapamazsin = 'Bu demirbaşı Transfer yapamazsınız.';
    DDDemirbasServisGonderYapamazsin = 'Bu demirbaş şu anda zaten serviste.';
    DDDemirbasServisTekniksorumluata = 'Önce teknik servise kabul edecek personeli atayın!';
    DDDemirbasServisIadeYapamazsin = 'Bu demirbaş ile servis iade işlemi yapamazsınız.';
    DDDemirbasServisIslemiYapamazsin = 'Bu demirbaş ile servis işlemi yapamazsınız.';
    DDServisHareketGormusSilinemez = 'Bu Demirbaş servis hareketi görmüştür.Silinemez !';
    DDKalibrasyonHareketGormusSilinemez = 'Bu Demirbaş Kalibrasyon hareketi görmüştür.Silinemez !';
    DDTakipHareketGormusSilinemez = 'Bu Demirbaş Takip hareketi görmüştür.Silinemez !';
    DDYorumMedyaHareketGormusSilinemez = 'Bu Demirbaş Yorum/Medya hareketi görmüştür.Silinemez !';
    DDTutanakHareketGormusSilinemez = 'Bu Demirbaş tutanak hareketi görmüştür.Silinemez !';
    DDmasrafHareketGormusSilinemez = 'Bu Demirbaş masraf / gelir hareketi görmüştür.Silinemez !';
    DDUst_bilgi_kayit='Önce Üst Bilgiyi Kaydedin';
    DDKaydedilsinmi='Değişiklikleri kaydetmek istiyor musunuz';
    DDSilinsinmi='Tutanağı silmek istiyor musunuz ?';
    DDUst_bilgiyi_kaydet='Önce Üst Bilgiyi Kaydedin';
    DDKayit_demirbastan_cikarilacak_onay='Seçili Kayıt Demirbaş tutanağından çıkarılacaktır, Onaylıyor musunuz?';
    DDSube_Demirbas_depo_tanimla='Bu şube için "Demirbaş" deposu tanımlayın';
    DDDepoda_kalmamistir=' adlı stok Demirbaş deposunda kalmamıştır.';
    DDDepodaki_kadar_kopyala='Demirbaş deposunda istenen miktar kalmamıştır. Depodaki kadar kopyalansın mı?';
    DDSilinecek_sozlesme_sec='Silinecek sözleşme kaydını seçiniz.';
    DDSilinecek_servis_sec='Silinecek Tamir-Servis kaydını seçiniz.';
    DDBitis_tarih_buyuk_gir=' Sigorta Bitiş Tarihini büyük giriniz.';
    DDKalan_sifir_eklenmez='Kalanı sıfır olanlar eklenemez.';
    DDAlan_silinsinmi=' alanını silmek istiyor musunuz ?';
    DDModel_icin_marka_sec='Model Tanımı yapabilmek için Marka Seçilmelidir';
    DDTutanak_silinsinmi='Tutanağı silmek istiyor musunuz ?';
    DDKategori_secilemez='Kategori seçimi yapılamaz!';


  //UKampanyaDlg
    KDDetayGirilmisSilinsinmi = 'Bu kampanyaya girilmiş alt bilgiler vardır.Silinsin mi ?';

  //UKrediHesapMakineDlg
    KDOdemeTakvimiHesaplanmamis = 'Ödeme takvimi hesaplanmamış!';
    KDSatisTutariGirilmemis = 'Satış tutarı girilmemiş!';
    KDBasitFaizOrani = 'Basit Faiz Oranı';

  // KDBasitFaiz = ' Basit Faiz %';
    KDOranBosOlamaz = 'Oran Boş Olamaz.';
    KDKDVliKira = 'KDV li Kira';
    KDTaksit = 'Taksit';

  //UBDSListeFrame
    BDSVeriSilinsinmi = 'Seçili veri silinsin mi?';

  //Barkod
    BRfazla_giris_uyarisi='Gerekenden Farklı Miktarda Giriş Yapıyorsunuz!';

  //UReplikasyon
    RBagli = 'Bağlı';
    RBaglantiYok = 'Bağlantı Yok';
    RGenotipdanRehberAl = 'Genotıpdan Rehber Al';
    RGenotipeRehberVer = 'Genotıpa Rehber Ver';
    RGenotipdanStokFaturasiAl = 'Genotıpdan Stok Faturası Al';
    RGentegreDevirCariBankaKasa = 'Gentegre Devir(Cari,Banka,Kasa)';
    RGentegreDevirCekSenet = 'Gentegre Devir(Çek,Senet)';
    RGentegreDevirCariYılDetay = 'Gentegre Devir(Cari Yıl Detay)';
    RGenotipdanStokKartAl = 'Genotıpdan Stok Kart Al';
    RGenotipaStokKartVer ='Genotıpa Stok Kart Ver';
    RHataliSatirSayisi = 'Hatalı/Aktarılamayan satır sayısı: ';
    RAktarimBasarili = 'Tebrikler, aktarımınız başarılı.';
    RAktarimHatasi = 'Aktarım Hatası';
    REntegraBaglantiHatasi = 'Entegra Bağlantı Hatası';
    //RGenotipBaglantiHatasi = 'Genotıp Bağlantı Hatası';
    RFaturaSilinmeyeUygunDegildir = 'Faturanın Entegrada durumu silinmeye uygun değildir.';
    REntegraFaturaSilmeHatasi = 'Entegra fatura silme hatası';
    RFaturadaEslesmeicinFirmaKoduYok = 'Genotıp faturasında eşleşme için firma kodu bulunamadı!';
    ROnceRehberKayitlariniziAktarin = 'Genotıp faturasındaki rehber kaydı Entegrada bulunamadı. lütfen ilk önce rehber kayıtlarınızı aktarınız!';
    ROdemeTarihiGirilmemis = 'Ödeme planı oluşturulamadı: Ödeme tarihi girilmemiş.';
    RDigerTumAlanlarOpsiyoneldir = 'Rehber entegrasyonunda ''KOD'' ve ''FIRMA'' alanları zorunlu alanlardır. Diğer tüm alanlar opsiyoneldir.';
    RHesapPlaniniYapilandir = 'Aktarımdan önce Hesap Planınızı uygun olarak yapılandırmalısınız.';
    RBirSonrakiKayittanDevamEdilecek = 'Aktarımda zorunlu alanlardan birinin boş kalması durumunda o kayıt atlanacak ve bir sonraki kayıttan devam edilecektir.';
    REklenecekOpsiyonelAlanlar = 'Kayıtlarda eklenecek olan opsiyonel alanlar;';
    RAdresBilgileri = 'Adres,PK,ILCE,IL,Fatura Başlığı,Vergi Dairesi,Vergi No,İş Tel,Cep Tel,Ev Tel,E-Posta,Web Adresidir.';
    REklenecekAlanlar = 'Kayıtlarda eklenecek olan alanlar;';
    RAdresBilgileri2 = 'Kod,Ünvan,Adres,PK,ILCE,IL,Fatura Başlığı,Vergi Dairesi,Vergi No,İş Tel,Cep Tel,Ev Tel,E-Posta,Web Adresidir.';
    RBuBolumeGecmedenOnce = 'Bu bölüme geçmeden önce;';
    RRehberAktarımınıTamamla = 'Hesap planınızı oluşturmalı ve rehber aktarımınızı tamamlamalısınız.';
    REntegradaTanımlıOlmasıGerek = 'Faturaların ilgili kurumlarının Entegrada da tanımlı olması gerekmektedir. ';
    RRehberAktariminiziTamamla = 'Bu bölüme geçmeden önce daha önce yapmadıysanız lütfen rehber aktarımınızı tamamlayınız.';
    RBirlikteAktarilacaktir = 'Faturalar tüm satırları, var ise masraf/gelir merkezleri ve planlanan ödeme tarihleri ile birlikte aktarılacatır.';
    RCariDevirKayitlariAktarilmayacak = 'Eklenmemiş Rehber kayıtları için Cari devir kayıtları aktarılmayacaktır.';
    RBankaTanimlamalariYenidenDuzenle = 'Banka tanımlama sistemi değiştiğinden; Bankalar bölümü içerisinden tüm banka tanımlamalarınızı yeniden düzenlemelisiniz.';
    RLogayaTiklayarakYap = 'Bu düzenlemeleri seçmiş olduğunuz bankanın logosuna tıklayarak kolayca yapabilirsiniz.';
    RCekVeSenetlericerisinden = 'Çek ve Senetler içerisinden;';
    RTumVerilerAktarilacaktir = 'Vade tarihi henüz gelmemiş olanlar ile ve durumu ödendi yada iptal olarak işaretlenmemiş tüm veriler aktarılacaktır.';
    RDuzenlemeleriTamamlamisOlmali = 'Tüm diğer aktarım işlemlerini bitirmiş ve aktarımlar sonrasındaki düzenlemeleri tamamlamış olmanız gerekmektedir.';
    RKayitlarSistemUzerineEklenebilir = 'Detay kayıtları ancak kullanıma geçmiş bir sistem üzerine eklenebilir!';

  //UTablo
    TGorevUzerindeDegisiklikYapamaz = 'Görevle ilişkisi olmayan kişiler görev üzerinde değişiklik yapamaz.';
    TIptalEdilmisGorevAktifEdilemez = 'İptal edilmiş bir görev tekrar aktif edilemez';
    TDurumuAtayanDegistirebilir = 'Onaylanmış bir görevin durumu yalnızca atayan kişi tarafından değiştirilebilir';
    TGoreviAtayanOnaylar = 'Görev ancak atayan kişi tarafından onaylanabilir';
    TGoreviAtayanIptalEder = 'Görev ancak atayan kişi tarafından iptal edilebilir';
    TErtelemeAtayanKisiYapar = 'Görev erteleme onayı yalnızca görevi atayan kişi tarafından yapılabilir';
    TErtelemeTarihiDoluOlmalidir = 'Görev Erteleme tarihi dolu olmalıdır';
    TYok = '(yok)';
    TSurumBilgisiYok = 'Sürüm bilgisi yok';
    TCikmakIstediginizKadarUrunYok = 'Stokta çıkmak istediğiniz kadar ürün yok';
    TCikmakIstediginizKadarUrunYokYinedeCik = 'Stokta çıkmak istediğiniz kadar ürün yok, Yine de Çıkış yapmak istiyor musunuz?';
    TYetkiAlanindakiPersoneller = 'Yetki Alanındaki personeller';
    TAyniKodaSahipKayitOlamaz = 'Aynı koda veya no"ya sahip iki kayıt bulunamaz...';
    TAyniAdaSahipKayitOlamaz = 'Aynı ada sahip iki kayıt bulunamaz...';
    TBosAlanHatasi = 'Boş alan hatası';
    TSeriNumaraDahaOnce = 'Bu seri numarası daha önce ' ;
    TIsimliMusterideKullanilmistir = ' isimli müşteride kullanılmış!';
    TKlasorAdiniGirin = 'Klasör Adını Giriniz';
    TKlasorResiminiSeciniz = 'Klasör Resmini Seçiniz';
    TServerAdiniGirin = 'Aktarım Yapılacak Server Adını Giriniz.';
    TServerAdiVeyaIpAdresi = 'Server Adı veya IP Adresi:';
    TServerAdiBosOlamaz = 'Server Adı Boş Olamaz.';
    TVeritabaniAdiniGiriniz = 'Aktarım Yapılacak Veritabanı Adını Giriniz.';
    TVeritabaniAdi = 'Veritabanı Adı:';
    TDizinAdi = 'Dizin Adı';
    TVeritabaniBosOlamaz = 'Veritabanı Adı Boş Olamaz.';
    TKullaniciAdiniGiriniz = 'Kullanıcı Adını Giriniz.';
    TKullaniciAdi = 'Kullanıcı Adı:';
    TKullaniciAdiBosOlamaz = 'Kullanıcı Adı Boş Olamaz.';
    TSifre = 'Şifre';
    TYeniSifreyiGiriniz = 'Yeni Şifreyi Giriniz.';
    TServerSifresiniGiriniz = 'Aktarım Yapılacak Server Şifresini Giriniz.';
    TServerSifresi = 'Server Şifresi';
    TDikkatBulunamayanIndex = 'Dikkat! Bulunamayan İndeks : ';
    TVarsayilanFiyaSec = 'Kasa opsiyonlardan varsayılan alış satış fiyatlarını ayarlayınız! Hatalara sebep olabilir.';
    TEklenecekBilgiyiYaz = 'Eklemek istediğiniz bilgiyi buraya yazınız.';
    TDurumDegisikligiBilgisiGir = 'Durum değişikliği ile ilgili bilgi giriniz.';
    TYeniDurumAcıklamasiGir = 'Yeni Durum için açıklama girin.';
    TREHBERINIexTablosunda = 'REHBERINIEX tablosunda ' ;
    TBolumuIcin = ' bölümü için ' ;
    TAnahtariBulunamadi = ' Anahtarı bulunamadı!';
    TAktiviteSablonlari = 'Aktivite Şablonları';
    TTalimatSureciUyarisi = 'Talimat Süreci Uyarısı';
    TEPostaHatali = 'EPosta Hatalı..';
    TBaglantiKurulamadi = 'Bağlantıda Hata(FTP): Bağlantı Kurulamadı!';
    TDosyaTransferEdilemedi = 'Bağlantıda Hata(FTP): Dosya Transfer Edilemedi!';
    TBaglantiTuruDesteklenmiyor = 'Bağlantı türü desteklenmiyor!';
    TFTPBilgileriYokyadaHatali = 'FTP Bilgileri Yok yada Hatalı!';
    TKayitIslemiGerceklestirilemedi = ' Kayıt İşlemi Gerçekleştirilemedi!!';
    TAktarilamayanAlanlar = 'Aktivite Oluşturuldu, Aktarılamayan Alanlar:';
    TAktiviteSablonuBulunamadi = 'Hata: Aktivite Şablonu Bulunamadı!';
    TAkibetAlinirkenLutfenBekleyin = 'Akibet bilgileri alınırken lütfen bekleyiniz..';
    TBaglantiBilgileriAliniyor = 'Bağlantı Bilgileri Alınıyor...';
    TDesenBulunmamaktadir = 'Bu banka için desen bulunmamaktadır..';
    TBaglantiKuruluyor = 'Bağlantı Kuruluyor..';
    TSonlandirmaIslemleriYapiliyor = 'Sonlandırma işlemleri yapılıyor..';
    TTalimatImzalanirkenBekle = 'Talimat imzalanırken lütfen bekleyiniz..';
    TTelefonNoHatali = 'Telefon no hatalı.. Rehber kayıtlarınıza gözatın..';
    TGSMOperatoruHatali = 'GSM Operatörü hatalı.. Rehber kayıtlarınıza gözatın..';
    TParmakIziAliniyor = 'Parmak izi alınıyor...';
    TImzaGonderimHatasi = 'İmza Gönderim Hatası:';
    TEimzaMesaji = 'E-imza mesaji';
    TImzaGercekDosyaKaydediliyor = 'İmza Gerçek, Dosya kaydediliyor..';
    TDosyaKistiriliyor = 'Dosya Sıkıştırılıyor..';
    TDosyaVeritabaninaYazilamadi = 'Dosya veritabanına yazılamadı!';
    TDosyaBasariylaKaydedildi = 'Dosya Başarıyla kaydedildi.';
    TGirilmisBilgiVarOnce = 'Girilmiş bilgi var. Önce ';
    TBilgileriniSiliniz = ' bilgilerini siliniz...';
    TZimmetIadeKaydi = 'Zimmet İade Kaydı';
    TZimmetIadeVeren = 'Zimmet İade Veren';
    TZimmetIadeAlani = 'Zimmet İade Alan';
    TYeniZimmetKaydi = 'Yeni Zimmet Kaydı';
    TDemirbasKayipKaydi = 'Demirbaş Kayıp Kaydı';
    TZimmetSahibi = 'Zimmet Sahibi';
    TDemirbasHurdaKaydi = 'Demirbaş Hurda Kaydı';
    TZimmetTransferKaydi = 'Zimmet Transfer Kaydı';

 //URehberAyar
    RGirilmisBilgiVar = 'Girilmiş bilgi var! Silinemez/Değiştirilemez';

 //URehberAramaEkrani
    RAEPersonelAramaEkrani = 'Personel arama ekranı';
    RAEAramaEkrani = 'Arama ekranı';
    RAEPersonelHareketiSilme = 'Seçili olan personel hareketini silmek istediğinize eminmisiniz?';

  //UOpsiyonStok
    OSIslemTamamlandi = 'İşlem Tamamlandı';
    OSDegisiklikKaydedilsinmi = 'Depo Tanımlarında yaptığınız değişiklik kaydedilsin mi?';
    OSDepoAdiBosOlamaz = 'Depo Adı Boş olamaz';
    DonusumDepoAyniOlmali = 'Dönüşümde Kaynak depo ile hedef depo aynı olmalı';

  //ULisans
    LKurumKodunuGir = 'Lisans için kurum kodunu girin:';
    LKurumKoduBosOlamaz = 'Kurum Kodu Boş Olamaz.';
    LTerminalLimitinizDolu = 'Terminal Limitiniz Dolu';
    LTerminalSayisiniAyarlayiniz = 'Lütfen Lisanslama modülünden aktif terminal sayısını ayarlayınız.';
    LTerminalAktifDegil = 'Bu terminal aktif değil';
    LDuzenlemeYapmalisin = 'Aktif hale getirebilmek için GenLisanslama Modülünden, Terminaller bölümünden düzenleme yapmalısınız';
    LTerminalKayitliDegil = 'Bu terminal tanımlı değil';
    LTerminaliKaydetmekicinOK = 'Terminali kaydetmek için ismi yazıp Tamama tıklamalısınız';
    LLisans = 'Lisans';
    LEntegraileIrtibataGec = 'Sistemin çalışma izni yok. Yetkili firmanız ile irtibata geçmeniz gerekmektedir.';
    LModulLisansi = 'Modül Lisansı';
    LLisansınBulunmamaktadir = 'Bu modül için lisansınız bulunmamaktadır';
    LTerminal = 'Terminal';
    LTerminalSistemdeKayitliDegil = 'Bu terminal sistemde kayıtlı değil.';
    LServerAyarDegismisIrtibataGec = 'Server ayarlarınız değişmiş. Lütfen yetkili firmanız ile görüşünüz.';
    LYeniBirLisansAlmanGerek = 'Yeni bir lisans almanız gerekebilir.';
    LDemoSuresi = 'Demo süresi';
    LDemoSuresininDolmasina = 'Demo süresinin dolmasına  ';
    LDemoSuresiDolmustur = 'Demo süresi dolmuştur.';
    LLisansSuresi = 'Lisans süresi';
    LLisansSuresininDolmasina = 'Lisans süresinin dolmasına ';
    LGunKalmistir = ' gün kalmıştır.';
    LLisansSuresiDolmustur = 'Lisans hata kodu : HK-020.';
    LLisansDondurulmustur = 'Lisans dondurulmuştur';
    LYazilimCalismayacaktir = 'Yazılım çalışmayacaktır';
    LBuisimdeKayitliTerminalVar = 'Bu isimde kayıtlı terminal var.';
    LTerminalKaydedildi = 'Terminal kaydedildi.';

  //UMaasTablo
    MTTutarSatiriBulunamadi = 'Ad Soyad - Hesapno - Tutar satırı bulunamadı..';
    MTTutarSutunuBulunamadi = 'Tutar sütunu bulunamadı!';
    MTHesapNoSutunuBulunamadi = 'Hesap No sütunu bulunamadı!';
    MTHesapNoBulunamadi = ' Hesap No bulunamadı!';
    MTBorcluBankaHesapNoEksik = 'borçlu banka hesap numaraları eksik!';
    MTAlacakliBankaHesapNoEksik = 'alacaklı banka hesap numaraları eksik!';
    MTHicSecimYapilmamis = ' Hiç seçim yapılmamış!';
    MTExcelTablosunuSecin = ' Excel tablosunu seçin!';
    MTExceleAktarildi = 'Excele aktarıldı..';
    MTKimlikNoSutunNo = 'T.C.Kimlik No Sütun No :';
    MTToplamMaasSutunNo = 'Toplam Maaş Sütun No :';
    MTBankadanOdenecekSutunNo = 'Bankadan Ödenecek Sütun No :';
    MTAgiSutunNo = 'Agi Sütun No :';
    MTKasaSutunNo = 'Kasa Sütun No :';
    MTBankadanAvansSutunNo = 'Bankadan Avans Sütun No :';
    MTKasadanAvansSutunNo = 'Kasadan Avans Sütun No :';
    MTKasadanOdenecekSutunNo = 'Kasadan Ödenecek Sütun No :';
    MTPersonelListesindeBulunamadi = ' T.C.Kimlik No Personel listesinde bulunamadı!';
    MTAsagidakiPersonellerden = 'Aşağıdaki personellerden ';
    MTBorcluKasaBilgisiEksik = 'borçlu kasa bilgisi eksik!';
    MTMakbuzNoVerilsinmi = 'Makbuz Numarası verilsin mi?';
    MTMakbuzKesmeOnayi = 'Makbuz kesme onayı';
    MTParaBirimiEksik = 'para birimi eksik!';
    MTParaBirimiGirin = 'Para Birimi girin!';
    MTOnceMaasTablosunuBosalt = 'Yeniden oluşturmak için önce maaş tablosunu boşaltmalısınız!';
    MTAktarimkosullari='Aktarım Koşulları:'+#13+#10+
              ' - Aktarım dosyası excell uzantısına sahip olmalıdır.'+#13+#10+
              ' - Aktarılacak belge sırası ile;'+#13+#10+
              '     * sütun1(A):TC Kimlik No,'+#13+#10+
              '     * sütun2(B):Ad Soyad,'+#13+#10+
              '     * sütun3(C):Prim(Numerik),'+#13+#10+
              '   öğelerine sahip olmalıdır.';

  //UKrediler
    KGirilmisOdemeTakvimiVarSilinsinmi = 'Daha önce girilmiş ödeme takvimi var. Silinsin mi?';
    KKrediHesabinaEklensinmi = 'Kredi hesabına eklensin mi?';
    KDahaOnceEklenmis = 'Daha önce eklenmiş';
    KOdemePlaniTumuyleSilinsinmi = 'Ödeme planı tümüyle silinsin mi?';
    KKrediBilgisiSilinsinmi = 'Kredi bilgisi silinsin mi?';
    KOdemeBilgisiSilinsinmi = 'Ödeme bilgisi silinsin mi?';
    KBuKredinin = 'Bu kredinin ';
    KTarihindeOdemesiVarSilinemez = ' tarihinde ödemesi var silinemez!';

  //üretim
    FTWUretimleriSil = 'Önce Transfer satırlarını silmeniz gerekiyor';
    URKayitSilinemez='Hareket Görmüş Kayıt Silinemez!';
    URAdedBosOlamaz='Üretim Adedi Boş Olamaz!';
    UROnceOperasyonEkle='Önce operasyon ekleyin!';
    UROnceUretimEkle='Önce üretim satırı ekleyin!';
    URUrunlerIcinKalite='Sadece ürünler için kalite bilgisi girilebilir!';
    UROnceOperasyonlariSil='Bu işlemi yapabilmek için önce operasyonları silmelisiniz!';
    URBirimHatasi='Anabirim ve birim 2 hatası!!';
    URSifirdanKucukUyarisi='Ürün adedi 0 dan küçük olamaz!';
    URSifirdanBuyukUyarisi='Bileşen adedi 0 dan büyük olamaz!';
    UREslesmediUyarisi='Operasyon Üretim ile eşleşmedi!!';
    URAktarilacakKayitYok='Aktarılacak kayıt bulunamadı.';
    URUretimEmirleriniSil='Önce bu plan dahilindeki üretim emirlerini silmelisiniz!';
    URUretimOperasyonuSil='Önce bu plan dahilindeki üretim operasyonlarını silmelisiniz!';
    URUretimFisSil='Önce bu plan dahilindeki üretim fişlerini silmelisiniz!'  ;
    URSiparissizIslemOlmaz ='Alınan sipariş olmadan işlem yapılamaz.';
    URPlanOlustur='Önce bir plan oluşturmalısınız.';
    URYeniReceteYap='Kayıtlı Reçete Bulunamadı. Önce Yeni Reçete Oluşturmalısınız.';
    URYeterliKayitUyarisi='Yeterli kayıt girilmemiştir.';
    URKodAdUyarisi='Kod ve Ad boş olamaz!';
    URIslemVarReceteAktarilmaz='İşlem satırları varken reçete bilgisi aktaramazsınız!!';


  //HizliGiris
    HGToplam = 'Toplam';
    HGOdenmis = 'Ödenmiş';
    HGNakitOdeme ='Nakit';
    HGKKOdeme = 'KK';
    HGDigerOdeme = 'Diğer';
    HGIadeCeki = 'İade Çeki';
    HGHediyeCeki = 'Hediye Çeki';
    HGKasa_Acilis='Kasa Açılışı yapmadan işlem yapamazsınız.';
    HGKasa_Iade_Tamamlandi='İade İşlemi Tamamlandı.';
    HGKasa_Iade_Bulunamadi='İade alınacak ürün bulunamadı.';
    HGKasa_Iade_MaxAdet='Satış yapılmış miktardan fazla iade alamazsınız.';
    HGKasadan='Kasadan Çıkış Yapılamadı. ';
    HGCarikart='Carikart seçmeden işleme devam edemezsiniz.';
    HGKasa_Ayarlarinda= 'Kasa Ayarlarında geçerli bir müşteri kaydı seçiniz';
    HGTanimli_depo_bulunamadi='Bu şubenin tanımlı deposu bulunamadı!' ;
    HGKayit_iptal_edilsinmi='Girilmiş kayıtlar var, iptal edilecektir, devam etmek istiyor musunuz?';
    HGBelge_Numarasi_uzun='Belge Numarası fazla uzun, lütfen kontrol ediniz.';
    HGTablo_dusurme_basarisiz='Tablo düşürme işlemi başarısız oldu.' ;
    HGIskonto_Yapilamaz='Bu Ürüne İskonto Yapılamaz!';
    HGSiparis_iptal_edilir='Sipariş edilmiş, silinemez, iptal edilebilir!';
    HGstok_boyutu_eksik='Bu stok için boyut tanımlamalarınız eksik veya hatalıdır.';
    HGbarkod_tanimlariniz_hatali='Boyutlara göre yapılan barkod tanımlamalarınız hatalı.';
    HGIslem_yarim_kapatilamaz='Seçilmiş ürünler var. İşlem yarım kalmış. Kapatılamaz..' ;
    HGSatistan_Buyuk_iskonto_yapilamaz='Satış tutarından büyük iskonto tutarı girilemez';
    HGdegistirme_yetkiniz_yok='Bu kayıttan sonra oluşturulmuş kasa kaydı olduğu için bu kaydı değiştirme yetkiniz yok.' ;
    HGfarki_onayliyormusun='Onaylıyor musunuz?';
    HGkasa_kapat='Önce açık olan kasanızı kapatmalısınız!';
    HGkasa_aktif_degil='Kasa Açılış Kapanış İşlemleri Aktif Değil.' ;
    HGkasa_kapandi='Kasa Kapatma işlemi yapıldı.';
    HGOnce_kaydetin='Önce yapılan işlemi kaydedin veya iptal edin!' ;
    HGsilinsinmi=' silinsin mi?' ;
    HGsecililer_var_kapatilamaz='Ortada seçilenler var, kapatılamaz..' ;
    HGsifirdan_buyuk_kapatilmaz='Kalan tutar sıfırdan büyük, kapatılamaz..' ;
    HGTahsilat_eklenemez='Kalan sıfırlandı. Tahsilat eklenemez..';
    HGKapatmak_icin_sil='Girilmiş tahsilatlar var. Kapatmak için üzerine tıklayarak silin..' ;
    HGYazdirilsinmi='Yazdırılsın mı';



  //Genel
    TamEkran = 'Tam Ekran';
    KucukEkran = 'Küçük Ekran';
    Uyari = 'U Y A R I';
    Kaydet='KAYDET';
    Onay = 'O N A Y';
    Bilgi = 'B İ L G İ';
    HataPrj = 'H A T A';
    Dikkat = 'D İ K K A T';
    Adres = 'Adres : ';
    isTel = 'İş Tel : ';
    cepTel = 'Mobil : ';
    EPosta = 'Eposta : ';
    Seciniz = 'Seçiniz';
    SerinoSec = 'Seri No Listesi';
    GelirMerkeziSec = 'Gelir Merkezi';
    MasrafMerkeziSec = 'Masraf Merkezi';
    BosBirakilamaz = ' boş bırakılamaz.';
    SifirOlamaz = ' 0 olamaz.';
    HizmetSecimi = 'Hizmet Seçimi';
    StokSecimi ='Stok Kart Listesi';
    KasaListesi = 'Kasa Listesi';
    KampanyaSecimi = 'Kampanya Listesi';
    MusteriilgiliSec = 'Müşteri İlgili Listesi';
    HizmetUrunSec = 'Hizmet/Ürün Seçimi';
    AktiviteSecimi = 'Aktivite Seçimi';
    ProjeSecimi = 'Proje Seçimi';
    ServisSecimi = 'Servis Seçimi';
    AksiyonSecimi = 'Aksiyon Seçin!';
    AktiviteGorevSec = 'Aktivite/Görev Listesi';
    TeklifSec ='Teklif Listesi';
    MasrafMerkeziPrj = 'Masraf Kalemi';
    MasrafAdi = 'Masraf Adı';
    GelirMerkezi = 'Gelir Kalemi';
    GelirAdi = 'Gelir Adı';
    KategoriListesi = 'Kategori Listesi';
    UlkeListesi = 'Ülke Listesi';
    TabloHatali = 'Tablo Hatalı!!';
    BankaSecimi = 'Banka Seçimi';
    BaglantiBilgileri = 'Bağlantı Bilgileri';
    Tahsilat = 'Tahsilat';
    AlacakTahakkuku = 'Alacak Tahakkuku';
    Odeme = 'Ödeme';
    Alacak = 'Alacak ';
    Borc = 'Borç ';
    BorcTahakkuku = 'Borç Tahakkuku';
    BorcAlacak = 'Borç ve alacak aynı anda dolu olamaz!';
    NakitTahsilat = 'Nakit Tahsilat';
    GelenHavaleEFT = 'Gelen Havale / EFT';
    KurFarkiGeliri='Kur Farkı Geliri';
    KurFarkiGideri='Kur Farkı Gideri';
    PosileTahsilat = 'POS ile Tahsilat ';
    PosileOdeme = 'POS ile Ödeme ';
    NakitOdeme = 'Nakit Ödeme';
    GonderilenHavaleEFT = 'Gönderilen Havale / EFT ';
    KrediKartiileOdeme = 'Kredi Kartı ile Ödeme';
    KrediKartiileOdemeIade = 'Kredi Kartına İade';
    IadeCekiileOdeme ='İade Çeki ile Ödeme';
    IadeCekiileTahsilat ='İade Çeki ile Tahsilat';
    HediyeCekiileOdeme ='Hediye Çeki ile Ödeme';
    HediyeCekiileTahsilat ='Hediye Çeki ile Tahsilat';
    KuponileOdeme ='Kupon ile Ödeme';
    KuponileTahsilat ='Kupon ile Tahsilat';
    Degis = 'Değiş';
    KayitIslemi = 'Kayıt işlemi yapılmadı kaydetmek istiyormusunuz?';
    UrunDoluOlmali = 'Ürün bilgiler dolu olmalı!';
    AdetDoluOlmali = 'Adet dolu olmalı!';
    DoluOlmali = ' dolu olmalı!';
    ConnectionNesnesiAcik = 'Connection Nesnesi Açık';
    Server = 'Server';
    Veritabaniprj = 'Veritabanı';
    Cuma = 'Cuma';
    Cumartesi = 'Cumartesi';
    Pazar = 'Pazar';
    YeniBelgeCikisi = 'Yeni Belge Çıkışı';
    YeniBilgiGirisi = 'Yeni bilgi girişi';
    DosyaAdiniGirin = 'Dosya adını girin';
    BaslikAdiniGirin = 'Başlık adını girin';
    ilgiliAdiniGirin = 'İlgili adını girin';
    BildirimYapan = 'Bildirim yapan';
    IletisimAdiniGirin = 'İletişim adını girin';
    Bilgilendirma = 'Bilgilendirme';
    SeriNoGirin = 'Seri numarasını girin!';
    BankayiSecveGirin = 'Bankayı seçin girin!';
    GecersizSeriNo = 'Geçersiz Seri Numarası!';
    GecersizLisans = 'Lisanslama sorunu. Lisans için arayınız!';
    Urun='Ürün';
    Sarf='Sarf';
    Adet='Adet';

    KontrolAktiviteTuru = 'Aktivite Türü';
    KontrolAktiviteKonusu = 'Aktivite Konusu';
    KontrolStokKodu = 'Stok Kodu';
    KontrolStokAdi = 'Stok Adı';
    KontrolDemirbasAdi = 'Demirbaş Adı';
    KontrolKategori= 'Kategori';
    KontrolAnaBirimi = 'Ana Birimi';
    KontrolKDV = 'KDV';
    KontrolKDVDahil = 'KDV Dahil';
    KontrolKDVHaric = 'KDV Hariç';
    Kontrol2Birim = '2.Birim';
    Kontrol2BirimCarpani = '2.Birim Çarpanı';
    KontrolAlimTarihi= 'Alım Tarihi';
    KontrolKabulEden = 'Kabul Eden';
    KontrolEkleyen = 'Ekleyen';
    KontrolLokasyon = 'Lokasyon';
    KontrolDurum = 'Durum';
    KontrolMaasTarih = 'Maas Tarihi';
    KontrolTuru = 'Türü';
    KontrolFiyatListeAdi = 'Fiyat Adı';
    KontrolKonusu = 'Konusu';
    KontrolSorumlu = 'Sorumlu';
    KontrolSorumluBilgisi = 'Sorumlu Bilgisi';
    KontrolAsamaSorumlusu = 'Aşama Sorumlusu';
    KontrolAsamasi = 'Aşaması';
    KontrolDurumu = 'Durumu';
    KontrolGorevAtayan = 'Görev Atayan';
    KontrolGorevAtanan = 'Görev Atanan';
    KontrolBaslangisTarihi = 'Baslangıç Tarihi';
    KontrolBitisTarihi = 'Bitiş Tarihi';
    KontrolGorevBasligi = 'Görev Başlığı';
    KontrolSablonAdi = 'Şablon Adı';
    KontrolFaturaAdet = 'Fatura adet';
    KontrolBirimFiyati = 'Birim Fiyat';
    KontrolFaturaTarihi = 'Fatura Tarihi';
    KontrolTarihi = ' Tarih';
    KontrolNo = ' No';
    KontrolStatu = 'Statü';
    KontrolDokumanNo = 'Döküman No';
    KontrolSurum = 'Sürüm';
    KontrolYonu = 'Yönü';
    KontrolDokumanAd = 'Döküman Ad';
    KontrolGrup = 'Grup';
    KontrolKod = 'Kod' ;
    KontrolKodAdi = 'Kod Adı' ;
    KontrolFirma = 'Firma';
    KontrolBolge = 'Bölge';
    KontrolAltBolge = 'Alt Bölge';
    KontrolKonu = 'Konu';
    KontrolTipi = 'Tipi';
    KontrolAciklama = 'Açıklama';
    KontrolIcerikTuru = 'İçerik Türü';
    KontrolBankaHesabi = 'Banka Hesabı';
    KontrolCekKrediKodu = 'Çek Kredi Kodu';
    KontrolCekKrediAdi = 'Çek Kredi Adı';
    KontrolCekKrediSozlesmeNo = 'Çek Kredi Sözleşme No';
    KontrolTeminati = 'Teminatı';
    KontrolLimitTipi = 'Limit Tipi';
    KontrolMinSeviye = 'Min.Seviye';
    KontrolLimitSuresi = 'Limit Süresi';
    KontrolLimit = 'Limit';
    KontrolBankaSubesi = 'Banka Şubesi';
    KontrolHesapKodu = 'Hesap Kodu';
    KontrolHesapAdi = 'Hesap Adı';
    KontrolHesapNo = 'Hesap No';
    KontrolParaBirimi = 'Para Birimi';
    KontrolHesapTipi = 'Hesap Tipi';
    KontrolSubeAdi = 'Şube Adı';
    KontrolSubeKodu = 'Şube Kodu';
    KontrolEposta = 'EPosta';
    KontrolKullaniciAdi = 'Kullanıcı Adı';
    KontrolGonderen = 'Gönderen';
    KontrolSifre = 'Şifre';
    KontrolSunucu = 'Sunucu';
    KontrolPort = 'Port';
    KontrolKocanNo = 'Koçan No';
    KontrolBaslangicNo = 'Başlangıç No';
    KontrolKrediKodu = 'Kredi Kodu';
    KontrolKrediAdi = 'Kredi Adı';
    KontrolSozlesmeNo = 'Sözleşme No';
    KontrolKrediTuru = 'Kredi Türü';
    KontrolBankaKoduTicari = 'Banka Kodu (Ticari)';
    KontrolKullanimSuresi = 'Kullanım Süresi';
    KontrolGelir = 'Gelir';
    KontrolMasraf = 'Masraf';
    KontrolKur = 'Kur';
    KontrolSevkAdresi = 'Sevk Adresi';
    Depo   = 'Depo';

    GecerliBirimTipiDegil = 'Seçilen birim bu ürün için geçerli bir birim tipi değil';
    SeciliSatirSil = 'Seçili kayıt silinecektir. Onaylıyor musunuz?';
    BirlestirAciklama = 'Birleştirmede girilmiş açıklamalar silinecektir. Devam etsin mi?';

    cnst_SablonAdiBosOlamaz ='Şablon Adı Boş Olamaz';

    Silinemedi=' den silinemedi...';
    Yazilamadi=' ye yazılamadı...';

    Tablo_sec='Öncelikle tablo seçin!';

        //Sipariş
    Sil_Onay='Seçili satır silinecektir. Onaylıyor musunuz?';
    Yanlis_Ekran='Belge türü Fiş olan kayıtlar için bu ekran kullanılamaz';
    Yeniden_duzenleme='Fiyat liste adı değişti. Yeniden düzenlensin mi?';
    Yanlis_karakter='Sipariş numarasında rakam dışında karakter olamaz!';
    Yanlis_numara=' tarihinde bu Sipariş numarası kullanılmış!';
    Onaylanmis_siparis= 'Bu Sipariş Daha Önce Onaylanmış.' ;
    Aksiyon_sec='Aksiyon Seçin!';




  //UItsEczaDepo
    Its_Islem_Gonderildi = 'İts sistemine gönderim tamamlandı.';
    Its_Islem_Secilen_Adet_Gecerli_Degil = 'Seçilen adet geçerli değil';

  //Döküman Yönetimi
    DYIcerikSilmeSorusu = 'İçerikteki &Parametre& silmek istediğinize emin misiniz?';
    DYKlasor ='Klasör';
    DYDokuman ='Döküman';
    DYBelge ='Belge';
    DYKlasoru ='Klasörü';
    DYDokumani ='Dökümanı';
    DYBelgeyi ='Belgeyi';
    DAltKlasor='Tüm alt klasorlere uygulamak ister misiniz?';
    //Yetkisiz_Islem='Yetkisiz işlem!';
    DMusteri_kod_girilmemis='Müşteri Kod Girilmemiş';
    DMasraf_kod_girilmemis='Masraf Kod Girilmemiş';
    DFiyat_girilmemis='B.Fiyat Girilmemiş';
    DOdeme_girilmemis='Ödeme Girilmemiş';
    DGiris_yapin='Lütfen Önce Giriş Yapın';
    DBos_alan='Boş Alan';
    DKayit_yapildi='Kayıt Yapıldı';
    DKaydedilmedi_cikis_olacakmi='Kaydedilmemiş! Yine de çıkmak istiyor musunuz';

  //UMailSablon
    MailSablonSilmeOnayi = 'Mail Şablonunu silmek istediğinize eminmisiniz?';
    Subebilgisigir='Şube Bilgisi Boş olamaz';
    Kimebilgisigir='Kime Bilgisi Boş olamaz';
    Mesajturugir='Mesaj Türü Bilgisi Boş olamaz';
    Oncelikgir='Öncelik Bilgisi Boş olamaz';
    Gonderengir='Gönderen Bilgisi Boş olamaz';
    Gonderildi='Mesajınız Gönderildi';
    EPostaGonderildi='E-Posta Gönderildi..';

    Gonderim_tamam='Gönderim İşlemi Tamamlanamadı';
    Listedencikarilsinmi='Seçili ek dosya listeden çıkarılacaktır. Onaylıyor musunuz?';

    EskiVersiyonKullniliyor = 'Programın eski versiyonlarından birini kullanmaktasınız, lütfen sistem yöneticiniz ile iletişime geçiniz.';


  //Destekdlh
    Destekdlg_MusteriKodu_Mesaj = 'Müşteri kodunuz bulunamadı.'+#13#10+'Yazılım firmanızla görüşüp sorunu giderebilirsiniz.';

const
  //OPSİYONLAR
 //Genel Opsiyonlar 10___
    MesajGrup=99;

    Ops_Dokum_Degis=-11111;
    Ops_TabloNo=-11110;
    Ops_GenelOpsiyon_Log = -10001;
    Ops_GenelOpsiyon_GenYazilimIPAdress = -10002;
    Ops_GenelOpsiyon_GenYazilimAdres = -10009;
    Ops_UyariOpsiyon_YenilemeSuresi = -10003;
    Ops_UyariOpsiyon_YeniKayitSuresi = -10004;
    Ops_UyariOpsiyon_Gorunmesin = -10140;
    Ops_GenelOpsiyon_VarsayilanDoviz = -10005;
    Ops_Dokuman_Dizin = -10006;
    Ops_VeriTabaniAdi = -10007;
    Ops_GenelOpsiyon_LogEkleme = -10011;
    Ops_GenelOpsiyon_LogSilme = -10012;
    Ops_GenelOpsiyon_LogDegistirme = -10013;
    Ops_GenelOpsiyon_DovizPanelGor = -10014;
    Ops_GenelOpsiyon_DovizOtoGuncelle = -10015;
    Ops_UyariOpsiyon_Aktif = -10016;
    Ops_Dokuman_Kayit_Yeri = -10017;
    Ops_Dokuman_MaxBoyut = -10018;
    Ops_GenelOpsiyon_ITSHesapId = -10019;
    Ops_GenelOpsiyon_EpostaHesapId = -10020;
    Ops_GenelOpsiyon_SMSHesapId = -10021;
    Ops_GenelOpsiyon_VersiyonNo = -10022;
    Ops_GenelOpsiyon_RepGSCariHar = -10023;
    Ops_GenelOpsiyon_RepGSTahsilat = -10024;
    Ops_Entegrasyon_Ent_Server = -10025;
    Ops_Entegrasyon_Ent_DB = -10026;
    Ops_GenelOpsiyon_BSMV = -10027;
    Ops_GenelOpsiyon_KURUMADI = -10028;
    Ops_IlaçFiyatOranBilgileri_Kademe1_Barem = -10029;
    Ops_IlaçFiyatOranBilgileri_Kademe1_Etiket = -10030;
    Ops_IlaçFiyatOranBilgileri_Kademe1_DepoKar = -10031;
    Ops_IlaçFiyatOranBilgileri_Kademe1_EczaciKar = -10032;
    Ops_IlaçFiyatOranBilgileri_Kademe2_Barem = -10033;
    Ops_IlaçFiyatOranBilgileri_Kademe2_Etiket = -10034;
    Ops_IlaçFiyatOranBilgileri_Kademe2_DepoKar = -10035;
    Ops_IlaçFiyatOranBilgileri_Kademe2_EczaciKar = -10036;
    Ops_IlaçFiyatOranBilgileri_Kademe3_Barem = -10037;
    Ops_IlaçFiyatOranBilgileri_Kademe3_Etiket = -10038;
    Ops_IlaçFiyatOranBilgileri_Kademe3_DepoKar = -10039;
    Ops_IlaçFiyatOranBilgileri_Kademe3_EczaciKar = -10040;
    Ops_IlaçFiyatOranBilgileri_Kademe4_Barem = -10041;
    Ops_IlaçFiyatOranBilgileri_Kademe4_Etiket = -10042;
    Ops_IlaçFiyatOranBilgileri_Kademe4_DepoKar = -10043;
    Ops_IlaçFiyatOranBilgileri_Kademe4_EczaciKar = -10044;
    Ops_IlaçFiyatOranBilgileri_Kademe5_Barem = -10045;
    Ops_IlaçFiyatOranBilgileri_Kademe5_DepoKar = -10046;
    Ops_IlaçFiyatOranBilgileri_Kademe5_EczaciKar = -10047;
    Ops_IlaçFiyatOranBilgileri_KDVOranı = -10048;

    Ops_GenelOpsiyon_AktarimRehberKayitlari = -10049;
    Ops_GenelOpsiyon_AktarimStokKart = -10050;
    Ops_GenelOpsiyon_AktarimStokGiris = -10051;
    Ops_GenelOpsiyon_AktarimGunSonu = -10052;
    Ops_GenelOpsiyon_AktarimKurumFaturalari = -10053;
    Ops_GenelOpsiyon_SifreSuresi = -10154;

    Ops_Yedekleme_YedeklemeDizin = -10054;
    Ops_Yedekleme_YedeklemeAdi = -10055;
    Ops_Yedekleme_Winrar = -10056;
    Ops_Yedekleme_Kapanirken = -10057;
    Ops_Yedekleme_TutulacakCheck = -10058;
    Ops_Yedekleme_TutulacakGun = -10059;
    Ops_Yedekleme_PaylasimAdi = -10060;
    Ops_Yedekleme_PaylasimYolu = -10061;
    Ops_Yedekleme_GeciciSurucu = -10062;
    Ops_Yedekleme_KullaniciAdi = -10063;
    Ops_Yedekleme_Sifre = -10064;
    Ops_Yedekleme_Rar = -10065;
    Ops_Yedekleme_Zip = -10066;
    Ops_Yedekleme_Backup = -10067;
    Ops_Yedekleme_SonYedek_Giris = -10068;
    Ops_Yedekleme_SonYedek_Cikis = -10069;
    Ops_GenelOpsiyon_Sifre = -10070;
    Ops_Yedekleme_HerKapanistaYedek = -10071;
    Ops_ChatOpsiyon_Adres = -10072;
    Ops_ChatOpsiyon_Port = -10073;
    Ops_ProxyAdres = -10086;
    Ops_ProxyPort = -10087;
    Ops_HavaDurumu_Il = -10074;
    Ops_OpsiyonDuyuru_BilgilendirmeMail = -10075;
    Ops_OpsiyonDuyuru_BilgilendirmeSms = -10076;
    Ops_GenelOpsiyon_GSMTelKod=-10077;
    Ops_Yedekleme_Gunluk = -10078;
    Ops_Yedekleme_Haftalik = -10079;
    Ops_Yedekleme_Aylik = -10080;
    Ops_Yedekleme_SonYedek_DokumanTarih = -10081;
    Ops_SonKilitUpdateTarihi = -10082;
    Ops_GenelOpsiyon_SifreYontemi=-10083;
    Ops_GenelOpsiyon_GorunurDurumu = -10084;
    Ops_Yedekleme_TerminaledeYedekle = -10085;
    Ops_GenelOpsiyon_EskiTarihKayit = -10099;
    Ops_GenelOpsiyon_IleriTarihKayit = -10088;

    Ops_SonDuyuruCtrlTarihi = -10089;
    Ops_SonrakiSifreSureCtrlTarihi = -17777;

    Ops_SonLsnsCtrlTarihi = -10090;
    Ops_SonrakiLsnsCtrlTarihi = -10091;
    Ops_Server_Sid_Number = -10092;
    Ops_DenemeLoginSay = -10093;
    Ops_LsnsKulSay = -10094;
    Ops_LsnsSKT = -10095;
    Ops_LsnsGnclleme = -10096;
    Ops_LsnsKurumKodu = -10097;
    Ops_DenemeLoginKalan = -10098;

    Ops_GenelOpsiyon_RaporUpd=-10129;
    Ops_GenelOpsiyon_RaporGun=-10130;

    Ops_GenelOpsiyon_VarsayDoviz=-10135;
    Ops_GenelOpsiyon_VarsayYabanciBirim=-10136;
    Ops_GenelOpsiyon_TarihFarkiFormati=-10138;

    Ops_KaynakDB=-22000;
    Ops_SAP_DBAd=-22010;
 //CRM Opsiyonlar 21___
    Ops_CRM_Aktivite=-21050;
    Ops_Gorev_Peryot = -21000;
    Ops_GorevOpsiyon_DurumAciklama = -21001;
    Ops_GorevXgungoster = -21002;
   { Ops_AktiviteOpsiyon_PersonelYetkiKontrol = -21003;
    Ops_AktiviteOpsiyon_TarihceEkleSorumlu = -21004;
    Ops_AktiviteOpsiyon_TarihceEkleTakipci = -21005;
    Ops_AktiviteOpsiyon_TarihceEkleMusteri = -21006;
    Ops_AktiviteOpsiyon_TarihceEkleDurum = -21007;
    Ops_AktiviteOpsiyon_TarihceEkleTO = -21008;
    Ops_AktiviteOpsiyon_TarihceEkleTuru = -21009;
    Ops_AktiviteOpsiyon_BagliAktiviteKullan = -21010;
    Ops_AktiviteOpsiyon_GorevAtamaIzınKontrol = -21011;
    Ops_AktiviteOpsiyon_AmiriTakipciGetir = -21012;
    Ops_AktiviteOpsiyon_AmiriBilgilendirilecekGetir = -21013;
    }
    Ops_ProjeOpsiyon_ProjTrhcSorumlu = -21014;
    Ops_ProjeOpsiyon_ProjTrhcAsama = -21015;
    Ops_ProjeOpsiyon_ProjTrhcDurum = -21016;
    Ops_ProjeOpsiyon_ProjTrhcSonuc = -21017;
    Ops_ProjeOpsiyon_ProjTrhcMusteriIlgili = -21018;
    Ops_ProjeOpsiyon_ProjeKoduUretme = -21019;

    Ops_GroupOtomatikKod = -21218;
    Ops_FirsatOpsiyon_ProjeKoduUretme = -21219;
    Ops_ProjeOpsiyon_LojistikSekme= -21220;
    Ops_FirsatOpsiyon_AsamaSekme= -21221;
    Ops_FirsatOpsiyon_IsListesiSekme= -21224;

    Ops_AktiviteOpsiyon_AktiviteEpostaBildirimAktif = -21020;
    Ops_AktiviteOpsiyon_AktiviteSMSBildirimAktif = -21021;
    Ops_AktiviteOpsiyon_AktiviteEpostaBildirimSekli = -21022;

    Ops_ProjeOpsiyon_ProjeMaliyetEflowKullan = -21035;

    Ops_Gorev_AnimsatOnce = -21040;
    Ops_Gorev_AnimsatSonra = -21041;
    Ops_Gorev_Durum = -21042;
    Ops_Gorev_Son_Kac = -21043;
    Ops_Gorev_Turu=-21044;
    Ops_Gorev_Turu_Demirbas=-21045;


    EFatura_Senaryo = -11009;


    Ops_OpsiyonIsListesi_OnayAktif = -21070;

    Ops_OpsiyonIsListesi_Varsayilan_Durum_Yeni = -21071;
    Ops_OpsiyonIsListesi_Varsayilan_Durum_SonOnay = -21072;
    Ops_OpsiyonIsListesi_Varsayilan_Durum_SonRed = -21073;
    Ops_OpsiyonIsListesi_Varsayilan_Durum_Son = -21074;

    Ops_CheckProjeGor = -21076;
    Ops_CheckEkipmanGor = -21075;
    Ops_CheckDemirbasGor = -21077;
    Ops_CheckServisGor = -21078;
    Ops_CheckToplantiGor = -21079;
    Ops_CheckGoogleTakvim = -21080;


    Ops_Projeler_KodGrubu = -21023;
    Ops_ProjeOpsiyon_ProjTrhcAsamaSorumlu = -21024;
    Ops_OpsiyonProje_VarsayilanKlasor = -021025;
    Ops_OpsiyonAktivite_VarsayilanKlasor = -021026;
    Ops_OpsiyonProje_GorunecekSubeler = -21027;
    Ops_OpsiyonAktivite_BilgilendirmeMail = -21028;
    Ops_OpsiyonAktivite_BilgilendirmeSms =-21029;
    Ops_OpsiyonAKtivite_BilgilendirmeMailrapor=-21030;
    Ops_ProjeOpsiyon_PanelAlan = -21031;
    Ops_OpsiyonIs_VarsayilanKlasor = -21032;


    Ops_ProjeOpsiyon_ProjeKapatma = -21119;
 //Cari Opsiyonlar  22___

    Ops_OpsiyonCari_CariKodGirisi = -22001;
    Ops_OpsiyonCari_VarsayilanKlasor =-22002;
    Ops_OpsiyonCari_GorunecekSubeler =-22003;
    Ops_OpsiyonCari_VardiyaGiris = -22004;
    Ops_OpsiyonCari_VardiyaCikis = -22005;
    Ops_OpsiyonCari_PDKSBilgiGirisi = -22006;   //Manuel-Cihazdan
    Ops_OpsiyonCari_PersonelHareketTur = -22007;
    Ops_OpsiyonCari_GirisTurleri = -22008;
    Ops_OpsiyonCari_KartNoTakipTuru=-22009;
    Ops_OpsiyonCari_VardiyaTur=-22010;
    //Ops_OpsiyonCari_CheckKurumsalZorunlu=-22012;
    Ops_OpsiyonCari_Zorunlu_BOLGE=-22013;
    Ops_OpsiyonCari_Zorunlu_ALTBOLGE=-22014;
    Ops_OpsiyonCari_PersKodGirisi=-22015;

    Ops_OpsiyonCari_ResmiCalisma=-22020;
    Ops_OpsiyonCari_DiniCalisma=-22021;
    Ops_OpsiyonCari_ResmiMesai=-22022;
    Ops_OpsiyonCari_DiniMesai=-22023;
    Ops_IK_OdemeEksiOlamaz= -22024;

    Ops_IK_Listeler = -2250;

    Ops_IK_Ogrenim = -2255;

    Ops_IK_YDil = -2256;

    Ops_OpsiyonCari_CallerIDCalistir= -22028;

    Ops_OpsiyonCari_NotTuru=-22035;
    Ops_OpsiyonCari_OtomatikDoldur=-22036;  // Vergi No'dan mukellef bilgisi otomatik getir

 //Kasa Opsiyonlar 23___
    Ops_KasaOpsiyon_KDVOrani = -23001;
    Ops_StokHizliGiris_KasaAcilisKapanis = -23002;
    Ops_StokHizliGiris_HerGiristeKimlikDogrula = -23003;
    Ops_HizliGiris_IskontodaAciklamaSor = -23004;
    Ops_StokHizliGiris_TahTurNakit = -23009;
    Ops_StokHizliGiris_TahTurPOS = -23010;
    Ops_StokHizliGiris_TahTurAcikHesap= -23078;
    Ops_StokHizliGiris_TahTurHC = -23011;
    Ops_StokHizliGiris_TahTurIC = -23012;
    Ops_StokHizliGiris_TahTurKupon = -23013;
    Ops_StokHizliGiris_OdeTurNakit = -23014;
    Ops_StokHizliGiris_OdeTurHC = -23015;
    Ops_StokHizliGiris_OdeTurPOS = -23016;
    Ops_StokHizliGiris_OdeTurIC = -23017;
    Ops_StokHizliGiris_OdeTurKupon = -23018;
    Ops_KasaOpsiyon_BakiyeKurali = -23019;
    Ops_KasaOpsiyon_BelgeGiderMerkezi = -23020;
    Ops_KasaOpsiyon_BelgeGelirMerkezi = -23021;
    Ops_KasaOpsiyon_OdemeGiderMerkezi = -23022;
    Ops_KasaOpsiyon_TahsilatGiderMerkezi = -23023;
    Ops_OpsiyonKasa_KategoriEn= -23024;
    Ops_OpsiyonKasa_KategoriBoy= -23025;
    Ops_OpsiyonKasa_UrunKartEn= -23026;
    Ops_OpsiyonKasa_UrunKartBoy= -23027;
    Ops_OpsiyonKasa_ResimPixel= -23028;
    Ops_OpsiyonKasa_ResimCerceve= -23029;
    Ops_OpsiyonKasa_AciklamaSatir= -23030;
    Ops_StokHizliGiris_VarsayilanKDVDurum = -23036;
    Ops_KasaOpsiyon_ButceyiFaturalardanHesapla = -23037;
    Ops_HizliGiris_BaskiBelgeNoSor = -23038;
    Ops_HizliGiris_FazlaIskontoYapabilir = -23039;
    Ops_HizliGiris_FaturaBilgisiSor = -23040;
    Ops_Kasiyer_CheckSatisKodDahil= -23101;
    Ops_Kasiyer_CheckSiparisKodDahil= -23102;
    Ops_Kasiyer_CheckTransferKodDahil= -23103;
    Ops_Kasiyer_CheckDaraKodDahil= -23104;
    Ops_Kasiyer_OzelKodGoster = -23177;
    Ops_Kasiyer_CheckNakliye = -23179;
    Ops_Kasiyer_NakliyeID = -23180;
    Ops_Kasiyer_TahTurleri = -23195;

    Ops_Kasiyer_CheckKalanAcik = -23196;
    Ops_Kasiyer_CheckKalanIsk = -23197;
    Ops_Kasiyer_PerakendeAcilHesaba=-23198;

    Ops_Kasiyer_SiparisYazKapansin= -23228;
    Ops_Kasiyer_HesapYazKapansin=  -23229;
    Ops_Kasiyer_PerakendeyeSatis = -23230;



    Ops_KasaBasZamani=-23400;
    Ops_KasaBitZamani=-23401;
    Ops_KasaEkleGun=-23402;

    Ops_Adisyon_Durumlar=-23501;
    Ops_Adisyon_SiparisYeni=-23502;
    Ops_Adisyon_SiparisYaz=-23503;
    Ops_Adisyon_SiparisKurye=-23504;
    Ops_Adisyon_ComboSiparisIptal=-23505;
    Ops_Adisyon_SiparisTahsil=-23506;

    Ops_KasaOpsiyon_BelgeGiderSRM = -23181;//23020;
    Ops_KasaOpsiyon_BelgeGelirSRM = -23182;//23021;
    Ops_KasaOpsiyon_OdemeGiderSRM = -23183;//23022;
    Ops_KasaOpsiyon_TahsilatGiderSRM = -23184;//23023;


    Ops_Kasiyer_UrunBirimleriniTopla = -23190;
    Ops_Kasiyer_UrunBirimleriniToplamaID = -23191;

    Ops_Cafe_CheckGarsonAdiSorPC = -23201;
    Ops_Cafe_CheckGarsonAdiSorMobil = -23204;
    Ops_Cafe_CheckKisiSaySor = -23202;
    Ops_Cafe_CheckSifreSifirla= -23203;

    Ops_Cafe_CheckRezervasyon = -23205;

    Ops_HizliGiris_CheckServis = -23215;
    Ops_HizliGiris_EditServisOran = -23216;
    Ops_HizliGiris_EditServisId = -23217;


    Ops_HizliGiris_ColorComboBos =-23220;
    Ops_HizliGiris_ColorComboDolu=-23221;
    Ops_HizliGiris_ColorComboRezerve=-23222;
    Ops_HizliGiris_ColorComboHesap=-23223;
    Ops_HizliGiris_ColorComboBirles=-23224;

    Ops_Cafe_CheckGarsonAdi=-23234;
    Ops_Cafe_CheckKisiSay=-23235;
    Ops_Cafe_CheckAcilisZamani=-23236;
    Ops_Cafe_CheckGecenZaman=-23237;
    Ops_Cafe_CheckMasaTutar=-23238;

    Ops_KasaEkran_Banka = -23041;
    Ops_KasaEkran_CekveSenet = -23042;
    Ops_KasaEkran_Tahakkuk = -23043;
    Ops_KasaEkran_Kasa = -23044;
    Ops_KasaEkran_Plan = -23045;

    Ops_ExcelMaasEsles_TcKimNo = -25010;
    Ops_ExcelMaasEsles_Maas = -25011;
    Ops_ExcelMaasEsles_Banka = -25012;
    Ops_ExcelMaasEsles_Agi = -25013;
    Ops_ExcelMaasEsles_Diger = -25014;
    Ops_ExcelMaasEsles_Kasa = -25015;
    Ops_ExcelMaasEsles_AvBanka = -25016;
    Ops_ExcelMaasEsles_AvKasa = -25017;
    Ops_ExcelMaasEsles_OdeBanka = -25018;
    Ops_ExcelMaasEsles_OdeKasa = -25019;

    Ops_OpsiyonKasa_GorunecekSubelerMM = -23055;
    Ops_OpsiyonKasa_GorunecekSubelerKasa = -23056;
    Ops_OpsiyonKasa_BilgilendirmeMail = 23057;
    Ops_OpsiyonKasa_BilgilendirmeSms = 23058;
    Ops_HizliGiris_FisGiris = -23059;
    Ops_HizliGiris_FaturaGiris = -23060;
    Ops_HizliGiris_PusulaGiris = -23061;
    Ops_HizliGiris_BelgesizGiris = -23062;

    //Ops_StokHizliGiris_SadeceFatKaydet = -23063;
    Ops_HizliGiris_FisBaski = -23064;
    Ops_HizliGiris_FaturaBaski = -23065;
    Ops_OpsiyonKasa_MasraflariOdemelerdenDerle = 23066;
    Ops_HizliGiris_SiparisYonu= -23067;
    Ops_HizliGiris_TeraziPort  = -23068;
    Ops_HizliGiris_TeraziBoudRare    = -23069;
    Ops_HizliGiris_TeraziDataBits    = -23070;
    Ops_HizliGiris_TeraziStopBits    = -23071;
    Ops_HizliGiris_TeraziParity      = -23072;
    Ops_HizliGiris_TeraziFlowControl = -23073;
    Ops_HizliGiris_Terazi_Kg_Cevir   = -23074;
    Ops_HizliGiris_BarkodVar = -23075;
    Ops_HizliGiris_Irsaliye = -23076;
    Ops_HizliGiris_IrsaliyeBaski = -23077;
    Ops_CheckTransferKaydetYaz = -23079;

    Ops_HizliGiris_GratisGunluk = -23087;
    Ops_HizliGiris_GratisBasGun = -23088;
    Ops_HizliGiris_Cafe = -23090;
    Ops_HizliGiris_FiyatBasamak=-23092;

    Ops_IK_EditIzinYil1=-23301;
    Ops_IK_EditIzinYil2=-23302;
    Ops_IK_EditIzinYil3=-23303;
    Ops_IK_EditIzinSure1=-23311;
    Ops_IK_EditIzinSure2=-23312;
    Ops_IK_EditIzinSure3=-23313;
    Ops_IK_CheckIzinCumartesi=-23321;
    Ops_IK_CheckIzinPazar=-23322;

    Ops_IK_CheckMolaSuresi= -23324;

    Ops_IK_CheckMaasDevir= -23325;
    Ops_IK_MaasMasrafKalemi=-23330;

    Ops_IK_Cinsiyet = -23355;


    ops_guvenlik_sorusu = -24000;
 //Alış-Satış Opsiyonlar 24___
    Ops_FaturaOpsiyon_ZorunluPlanOlustur =-24001;
    Ops_FaturaOpsiyon_OndalikDijitSayBr = -24002;
    Ops_FaturaOpsiyon_OndalikDijitSayTut =-24003;
    Ops_FaturaOpsiyon_SatirlaraVade = -24004;
    Ops_FaturaOpsiyon_BasligaVade = -24005;
    Ops_FaturaOpsiyon_OndalikDijitSayDoviz =-24006;
    Ops_OpsiyonFatura_VarsayilanKlasor =-24007;
    Ops_OpsiyonSiparis_VarsayilanKlasor =-24008;
    Ops_FaturaOpsiyon_StokVarsayilanKalmayanBilgisi =-24009;
    Ops_FaturaOpsiyon_BelgeOlusturma =-24010;
    Ops_FaturaOpsiyon_BelgedeDoviz =-24011;
    Ops_FaturaOpsiyon_DonusumGozuksun =-24012;
    Ops_FaturaOpsiyon_KDVDahil=-24013;
    Ops_FaturaOpsiyon_OndalikDijitSayMiktar =-24014;
    Ops_FaturaOpsiyon_ProjeGozuksun =-24018;
    Ops_FaturaOpsiyon_DemirbasGozuksun =-24019;
    Ops_OpsiyonSiparis_AlinanDurum =-24020;
    Ops_OpsiyonSiparis_VerilenDurum =-24021;
    Ops_OpsiyonEIrsaliye = -24023;
    Ops_OpsiyonIhracatGonder = -24024;
    Ops_FaturaOpsiyon_Ozelkod1=-24025;
    Ops_FaturaOpsiyon_Ozelkod2=-24026;
    Ops_FaturaOpsiyon_Ozelkod1_Liste=-24027;
    Ops_FaturaOpsiyon_Ozelkod2_Liste=-24028;



    Ops_FaturaOpsiyon_E_FaturaKullanimda =-24030;
    Ops_FaturaOpsiyon_Entegrator=-24031;
    Ops_FaturaOpsiyon_Ent_Adres=-24032;
    Ops_FaturaOpsiyon_Ent_Kullanici=-24033;
    Ops_FaturaOpsiyon_Ent_Sifre =-24034;
    Ops_FaturaOpsiyon_Senaryo= -24035;
    Ops_FaturaOpsiyon_Bedelsiz = -24036;
    Ops_FaturaOpsiyon_Maliyet_Trh = -24037;
    Ops_FaturaOpsiyon_Maliyet_Kod= -24038;
    Ops_FaturaOpsiyon_Maliyet_Hesap = -24039;
    Ops_FaturaOpsiyon_Eksiskontoya = -24040;
    Ops_FaturaOpsiyon_SerbestMeslek= -24045;
    Ops_FaturaOpsiyon_Kira= -24046;
    Ops_FaturaOpsiyon_GiderPusulasi= -24047;
    Ops_FaturaOpsiyon_EFaturaDB = -24050;
    Ops_FaturaOpsiyon_Bosluk_Baslik= -24060;
    Ops_FaturaOpsiyon_Bosluk_Adres= -24061;
    Ops_FaturaOpsiyon_Bosluk_Ilce= -24062;
    Ops_FaturaOpsiyon_Bosluk_Il= -24063;
    Ops_FaturaOpsiyon_Bosluk_VD= -24064;
    Ops_FaturaOpsiyon_Bosluk_VNo= -24065;
    Ops_FaturaOpsiyon_Bosluk_Depo= -24066;
    Ops_FaturaOpsiyon_Bosluk_FiyatAdi= -24067;
    Ops_FaturaOpsiyon_Bosluk_Vade= -24068;
    Ops_FaturaOpsiyon_ProjeFirsatSec= -24069;
    Ops_FaturaOpsiyon_EnBoyAktif= -24070;
    Ops_FaturaOpsiyon_PozNoVar = -24071;
    Ops_FaturaOpsiyon_PozNoAralik = -24072;
    Ops_FaturaOpsiyon_HastaFaturaSekmesi = -24074;
    Ops_FaturaOpsiyon_HastaSiparisSekmesi = -24075;
    Ops_FaturaOpsiyon_EFaturaXSLT = -24076;
    Ops_FaturaOpsiyon_EArsivFaturaXSLT = -24077;
    Ops_FaturaOpsiyon_ESMMXSLT = -24078;
    Ops_FaturaOpsiyon_EIrsaliyeXSLT = -24079;
    Ops_FaturaOpsiyon_EBelgeAktif = -24080;
    Ops_FaturaOpsiyon_EBelgeTestAktif = -24081;
    Ops_FaturaOpsiyon_EBelgeVergiNo = -24082;
    Ops_FaturaOpsiyon_EFaturaAktif = -24083;
    Ops_FaturaOpsiyon_EArsivFaturaAktif = -24084;
    Ops_FaturaOpsiyon_ESMMAktif = -24085;
    Ops_FaturaOpsiyon_EFaturaTestURL = -24086;
    Ops_FaturaOpsiyon_EArsivFaturaTestURL = -24087;
    Ops_FaturaOpsiyon_EArsivFaturaUretimURL = -24088;
    Ops_FaturaOpsiyon_ESMMTestURL = -24089;
    Ops_FaturaOpsiyon_ESMMUretimURL = -24090;
    Ops_FaturaOpsiyon_EIrsaliyeTestURL = -24091;
    Ops_FaturaOpsiyon_EIrsaliyeUretimURL = -24092;
    Ops_FaturaOpsiyon_EFaturaSeriler = -24093;
    Ops_FaturaOpsiyon_EArsivFaturaSeriler = -24094;
    Ops_FaturaOpsiyon_ESMMSeriler = -24095;
    Ops_FaturaOpsiyon_EIrsaliyeSeriler = -24096;
    Ops_FaturaOpsiyon_EFaturaSabitNotlar = -24097;
    Ops_FaturaOpsiyon_EArsivFaturaSabitNotlar = -24098;
    Ops_FaturaOpsiyon_ESMMSabitNotlar = -24099;
    Ops_FaturaOpsiyon_EIrsaliyeSabitNotlar = -24100;
    Ops_FaturaOpsiyon_EBelgeKullanici = -24101;
    Ops_FaturaOpsiyon_EBelgeSifre = -24102;
    Ops_FaturaOpsiyon_EBelgeSOAPTestURL = -24103;
    Ops_FaturaOpsiyon_EBelgeSOAPUretimURL = -24104;
    Ops_FaturaOpsiyon_EIrsaliyeGIBAlias = -24105;
    // Gelen e-Belge XSLT opsiyonlari (DOKUMLER.RAPORID = 1/11/31/51)
    Ops_FaturaOpsiyon_EFaturaGelenXSLT = -24107;
    Ops_FaturaOpsiyon_EArsivFaturaGelenXSLT = -24108;
    Ops_FaturaOpsiyon_ESMMGelenXSLT = -24109;
    Ops_FaturaOpsiyon_EIrsaliyeGelenXSLT = -24110;
    // Cari olusturulurken kullanilacak kok HESAPKODU (HESAPPLANI'dan secilir).
    Ops_FaturaOpsiyon_CariKod = -24111;
    Ops_FaturaOpsiyon_GelenEFaturaAl = -24112;
    // Sevk bilgisi dialogunda gecmis secimi icin saklanan son sevk bilgileri (GENINI BOLUM)
    Ops_FaturaOpsiyon_SonSevkBilgileri = -24113;
    // Cari/kurum ozel e-Belge XSLT'leri (GENINI BOLUM; her satir: DEGER=REHBERID, ANAHTAR=XSLT adi)
    Ops_KurumXSLT_EFatura = -24114;
    Ops_KurumXSLT_EArsiv = -24115;
    Ops_KurumXSLT_EIrsaliye = -24116;
    Ops_FaturaOpsiyon_GelenEIrsaliyeyiAl = -24117;
    Ops_FaturaOpsiyon_EArsivGelenURL = -24118; //Gelen e-Arsivler icin URL
    Ops_FaturaOpsiyon_UBL_ZIP = -24119; //EBELGE.UBL_XML'i COMPRESS ile sakla (bool)
    Ops_FaturaOpsiyon_DepoDBAdi = -24120; //e-Belge/arsiv 2. DB adi (string, default GENDEPO)

    Ops_FaturaOpsiyon_Poliklinik = -25000;
    Ops_FaturaOpsiyon_Referans = -25002;

    Ops_Fatura_ExcelEslesme = -45678;
 //Banka Opsiyonlar  25___
    Ops_OpsiyonBanka_MasrafTutar = 25001;
    Ops_OpsiyonBanka_MasrafMerkezi = 25002;
    Ops_OpsiyonBanka_GorunecekSubeler = 25003;
    Ops_OpsiyonKredi_BilgilendirmeMail = 25004;
    Ops_OpsiyonKredi_BilgilendirmeSms = 25005;
    Ops_OpsiyonKrediKarti_BilgilendirmeMail = 25006;
    Ops_OpsiyonKrediKarti_BilgilendirmeSms = 25007;
    Ops_OpsiyonBanka_KrediTipi = 25008;
    Ops_OpsiyonBanka_Rotatif_Dönemleri = 25009;


    Ops_Banka_Excelden_SatSut= 25010;
    Ops_Banka_Excelden_Islemler=25011;

    Ops_Banka_Excel_Atilacak = 25015;
    Ops_OpsiyonBanka_KrediTeminat = 25018;
    Ops_OpsiyonBanka_KrediLimitSureTipi = 25019;

 //Çek-Senet Opsiyonlar  26___
    Ops_Cekler_CekSeriNoKontrolu = 26001;
    Ops_Cekler_CekRiskPayiKontrolu = 26002;
    Ops_Cekler_CekOdemedeMMAktar = 26003;
    Ops_Senetler_SenetOdemedeMMAktar = 26004;
    Ops_Cekler_CekOdemedeMMSil = 26005;
    Ops_OpsiyonSenetler_VarsayilanKlasor = 26006;
    Ops_OpsiyonCekler_VarsayilanKlasor = 26007;
    Ops_OpsiyonCekler_BilgilendirmeMail = 26008;
    Ops_OpsiyonCekler_BilgilendirmeSms = 26009;
    Ops_OpsiyonSenetler_BilgilendirmeMail = 26010;
    Ops_OpsiyonSenetler_BilgilendirmeSms = 26011;
    Ops_Cekler_KurBilgisiSor = 26013;
    Ops_Cekler_BirimRiskTutari = 26015;

 //Stok Opsiyonlar  27___
    Ops_StokOpsiyon_StokVarsayilanBirim = -27001;
    Ops_StokOpsiyon_StokDurumKontrolKurali = -27002;
    Ops_StokOpsiyon_StokAraFocusKurali = -27003;
    Ops_StokOpsiyon_StokKodGirisi = -27004;
    Ops_StokOpsiyon_StokKalmayanlar = -27005;
    Ops_StokOpsiyon_OnayliSayimDegistirme = -27006;
    Ops_OpsiyonStok_VarsayilanKlasor = 27007;
    Ops_StokOpsiyon_GorunecekSubeler = 27008;
    Ops_StokOpsiyon_LokasyonVar = -27009;
    Ops_StokOpsiyon_StokSeviyeleriGiris = -27010;
    Ops_StokOpsiyon_OtomatikBoyutOlusturma = -27011;
    Ops_StokOpsiyon_HareketBasla= -27012;
    Ops_StokOpsiyon_StokMaliyetHesapYontemi= -27015;
    Ops_StokOpsiyon_MuhasebeKodlar = -27016;
    Ops_StokOpsiyon_Birim2Miktar1denFarkliOlamaz = -27016;


 //Demirbaş Opsiyonlar 28___
    Ops_OpsiyonDemirbas_VarsayilanKlasor = 28001;
    Ops_OpsiyonDemirbas_Stoktan= 28003;
    Ops_OpsiyonDemirbas_TakipTur= -28004;
    Ops_DemirbasOpsiyon_DemirbasKodGirisi=28008;
    Ops_OpsiyonDemirbas_ServisDurumu=-28011;
    Ops_OpsiyonDemirbas_OlusacakAksiyon=-28013;
    Ops_DemirbasOpsiyon_AksiyonTetik=-28014;
    Ops_DemirbasOpsiyon_MailSablon=-28015;
    Ops_DemirbasOpsiyon_GorevTuru=-28016;

 //Teklif Opsiyonlar  29___
    Ops_TeklifOpsiyon_NoDijitSay = 29001;
    Ops_TeklifOpsiyon_NoSifirla = 29002;
    Ops_OpsiyonTeklif_VarsayilanKlasor = 29003;
    Ops_OpsiyonTeklif_VarsayilanKur = 29004;
    Ops_OpsiyonTeklif_OnayBekleme = 29005;
    Ops_OpsiyonTeklif_Onaylandi = 29006;

 //Servis Opsiyonlar 30___

    Ops_OpsiyonServis_Kapsam = -30000;
    Ops_OpsiyonServis_VarsayilanServisTuru   = -30011;
    Ops_OpsiyonServis_Senaryo  = -30010;
    Ops_OpsiyonServis_OnayEvetDurum  = -30012;
    Ops_OpsiyonServis_OnayHayirDurum  = -30014;
    Ops_OpsiyonServis_CevapSure = -30015;
    Ops_OpsiyonServis_CevapsizDurum = -30016;


    Ops_OpsiyonServis_VarsayilanKlasor = -30013;
    Ops_OpsiyonServis_Genel= -30020;

    Ops_Servis_Serino= -30022;
    Ops_Servis_Proje=-30023;
    Ops_Servis_ProjeFirsatSec=-30021;
    Ops_Servis_Lokasyon=-30024;
    Ops_Servis_TeslimSekmesi=-30025;
    Ops_Servis_EkAlanlarSekmesi=-30026;
    Ops_ServisBirdenFazlaSorumluPers=-30027;
    Ops_Servis_BelgelerSekmesi=-30028;
    Ops_Servis_GenelSekmesi=-30029;
    Ops_Servis_YorumSekmesi=-30030;
    Ops_ServisHareketlerSekmesi=-30031;
    Ops_Servis_OzellikSekmesi=-30032;
    Ops_Servis_TureDurum=-30033;
 //Döküman Opsiyonlar  32___
    Ops_Dokuman_GoogleWsdl =-31001;
    Ops_Dokuman_GelenKutusu = -31002;
    Ops_Dokuman_GidenKutusu = -31003;
    Ops_Dokuman_TarayiciKullanimda = -31004;
    Ops_Dokuman_BildirimTurleri = -31009;
    Ops_Dokuman_RevizeMiktar  = -31010;
 //Kalite Opsiyonlar
    Ops_CheckKaliteKontrol=-32000;
    Ops_OpsiyonKalite_BilgilendirmeMailrapor = -32001;
    Ops_KaliteDofKategori= -32002;

    Ops_KaliteOlcuAletleri= -32052;
    Ops_KaliteTestleri= -32053;

    Ops_KYDenetimTipi=-32007;
    Ops_KYDenetimDurum=-32008;
    Ops_KYDenetimKategori=-32009;

    Ops_KYSapmaOlayKategori=-32100;
    Ops_KYSapmaOlayDurum=-32101;
 //ITS Opsiyonlar
    Ops_ITSOpsiyon_Imalatci  = -33001;
    Ops_ITSOpsiyon_Depocu    = -33002;
    Ops_ITSOpsiyon_Etiket    = -33003;

    Ops_CheckUTSKullanimda = -33051;
    Ops_EditUTSToken = -33052;
    Ops_EditUTSFirmaNo = -33053;
    Ops_CheckTest = -33054;
    Ops_CheckUrunNoTek = -33055;
 //İÇERİKLER
 //Genel İniler 10__

    Ops_YDil_Aktif=-1000;
    Ops_AktifPasif = -1001;
    Ops_HaftanınGünleri = -1003;
    Ops_KURLAR = -1004;
    Ops_KasaTurleri = -1005;
    Ops_DepoVarsayilan = -1006;
    Ops_FiyatListeAdi = -1007;
    Ops_FiyatListeAdiAlis = -1008;
    Ops_DovizEslestir = -1009;
    Ops_Belge_DurumS = -1010;
    Ops_Belge_Turu = -1011;
    Ops_TabloId= -1012;
    Ops_Desteklenen_Diller= -1013;
    ops_Fatura_Durumu=-1015;
    Ops_Sektor=-10000;
    Ops_Sektor_Liste=-10100;
    Ops_RepImhaGerekce=-1016;
    Ops_TahsilatTürleri = -1021;
 // CRM iniler 21__
    Ops_Aktivite_Tipi = -2101;
    Ops_Aktivite_Konum = -2102;
    Ops_Aktivite_Oncelik =-2103;
    Ops_Aktivite_Puan = -2104;
    Ops_Aktivite_Durum = -2105;
    Ops_Aktivite_Türü = -2106;
    Ops_Aktivite_Konu = -2107;
    Ops_Aktivite_TarihceDurumu = -2108;

    Ops_Firsat_Aplikasyon = -2111;
    Ops_Firsat_Turu = -2112;
    Ops_Firsat_Durum = -2114;
    Ops_Firsat_Asama = -2113;

    Ops_Firsat_Sonuç = -2115;
    Ops_Firsat_Sebebi = -2116;
    Ops_Firsat_Konusu = -2117;
    Ops_Firsat_Olasilik=-2119;
    Ops_Firsat_Lojistik_Tipi=-2121;
    Ops_Firsat_Asama2=-2124;

    Ops_Proje_Aplikasyon = -2131;
    Ops_Proje_Turu = -2132;
    Ops_Proje_Asama = -2133;
    Ops_Proje_Durum = -2134;
    Ops_Proje_Konusu = -2137;

    Ops_Görev_Durum=-2118;
    Ops_Gorev_Konusu = -2122;

    Ops_AnaKaynak = -2120;

 //Cari İniler  22__
    Ops_CariKart_Grup        = -2200;
    Ops_CariKart_Durum       = -2201;

    Ops_Bizim_Departman       = -2251;
    Ops_Bizim_Gorev           = -2252;

 //Ops_CariKart_Grup      = -2202;
    Ops_CariKart_Sinif       = -2203;
    Ops_CariKart_Kategori    = -2208;
    Ops_CariKart_Gorev       = -2205;
    Ops_CariKart_Bolum       = -2206;
    Ops_CariKart_Sektor      = -2204;
    Ops_CariKart_Temas       = -2207;

    Ops_CariKart_Statu       = -2209;
    Ops_CariKart_Bolge       = -2210;
    Ops_CariKart_PDKSDurum   = -2211;

    Ops_CariKart_IskTurleri   = -2221;

    Ops_IK_Statu             = -2230;


    PDKS_BaslaSat=-2280;
    PDKS_TarihSat=-2281;
    PDKS_TarihSut=-2282;
    PDKS_AdSut   =-2283;
    PDKS_SoyadSut=-2284;
    PDKS_GirSut  =-2285;
    PDKS_CikSut  =-2286;
    PDKS_AcikSut =-2287;
 //Kasa İniler 23__
    Ops_Masraf_Turu = -2301;
    Ops_Masraf_Grubu = -2302;
    Ops_Masraf_SozlesmeTipi = -2303;
    Ops_Varsayılan_Masraf_Gelir_Merkezleri= -2304;
    Ops_GELIRAD = -2305;
    Ops_MASRAFAD= -2306;
    Ops_TahsilatAciklama = -2307;
    Ops_OdemeAciklama = -2308;
    Ops_ExcelMaasEsles = -2309;

    Ops_RestCokSatilanKod    = -2318;
    Ops_HizliSatisCokSatilanKod    = -2319;
    Ops_HizliSatisSatisKod    = -2320;
    Ops_HizliSatisSiparisKod  = -2321;
    Ops_HizliSatisTransferKod = -2322;
    Ops_HizliSatisDaraKod     = -2323;
    Ops_HizliSatisTerazi      = -2324;
    Ops_HizliSatisCafeKod     = -2325;
    Ops_HizliSatisKuponlar   = -2329;

    Ops_TevkifatOranlari = -2331;
    Ops_TevkifatNedeni   = -2332; //Tevkifatlı fatura (TIPI=22) tevkifat nedenleri GENINI bölümü
    Ops_KDVIstisnaNedeni = -2333; //KDV İstisna fatura (TIPI=24) istisna nedenleri GENINI bölümü

    //Ops_Kasiyer_Cafe_Sip_Sablon = -238701; -238702; -238703; -238704; -238705
    //Ops_Kasiyer_Cafe_Hesap_Sablon = -238801;-238802;-238803;-238804;-238805;

 //Alış-Satış İniler 24__
    Ops_FatDetayTur = -2401;
    Ops_FaturaTipi = -2407;

    Ops_UretimTuru = -2411;

    Ops_UretimEmirTuru = -2488;

 //Banka İniler  25__
    Ops_POS_Türü = -2501;
    Ops_POS_Statüsü = -2502;
    Ops_Talimat_Durum = -2503;
    Ops_KrediKarti_Türü = -2504;

 //Çek-Senet İniler  26__
    Ops_Cek_Durum_Alinan = -2601;
    Ops_Cek_Durum_Verilen = -2602;
    Ops_Senet_Durum = -2651;

 //Stok İniler  27__
    Ops_StokKart_Marka = -2701;
    Ops_StokKart_MarkaRakip = -2727;
    Ops_StokKart_Anabirim = -2702;
    Ops_StokKart_Tipi = -2703;
    Ops_StokKart_Grubu = -2704 ;
    Ops_StokKart_Ozellik = -2705 ;
    Ops_StokKart_Izleme = -2706;
    Ops_StokKart_ZamanBirimi = -2707;
    Ops_StokKart_Durum = -2708;
    Ops_StokKart_IsOrtagiiliskiTuru = -2709;
    Ops_StokKart_UzunlukBirimi = -2710;
    Ops_StokKart_AlanBirimi = -2711;
    Ops_StokKart_HacimBirimi = -2712;
    Ops_StokKart_AgirlikBirimi = -2713;
    Ops_StokKart_BarkodTipi = -2714;
    Ops_StokKart_SayımTutanakTipi = -2715;
    Ops_StokKart_Analiz = -2716;
    //2717 kullanılmış sanırım..
    Ops_StokKart_Icerik = -2718;
    Ops_StokKart_FisTipi = -2720;
    Ops_StokKart_Kategori = -2721;
    Ops_StokKart_EsdegerTur=-2725;
    Ops_StokKart_Kullanim=-2726;
    Ops_StokKart_MuhasebeKodlari=-2755;
    Ops_StokKart_OTV=-2756;
    Ops_StokKart_MedikalSinif=-2757;

    Ops_KampanyaTürleri = -2780;
    Ops_KampanyaKosulTürleri = -2781;
    Ops_KampanyaSonucTürleri = -2782;


    Ops_IsEmri_Durum = -2785;
    Ops_IsEmri_Tur = -2786;
    Ops_IsEmri_Oncelik = -2787;

    Ops_RepFasonTipi = -2799;

    Ops_StokKart_KDV = -2790;
    Ops_StokKart_KaynakUretimYeri =-2791;
    Ops_StokKart_EkstraTur =-2798;

    Ops_Uretim_Recete_KDV_Durum = -33100;
    Ops_Uretim_Senaryo= -33101;
    Ops_CheckCariSor= -33102;

    Ops_EditUretLotNoOnek = -33103;

    Ops_UEmriEditSekme1 = -33105;
    Ops_UEmriEditSekme2 = -33106;
    Ops_UEmriEditSekme3 = -33107;

    Ops_EditIsEmriSekme1 = -33111;
    Ops_EditIsEmriSekme2 = -33112;
    Ops_RadioGroupLotKaynak = -33114;

    Ops_StokKategoriTurleri = -27990001; //bu key altına -27990001,-27990002,-27990003 gibi eklenmeye devam edilicektir..bu aralık rezerve!!

 //Demirbaş İniler 28__
    Ops_Demirbas_Aksiyon = -2801;
    Ops_Demirbas_AlimSekli =-2802;
    Ops_Demirbas_Durum = -2803;
    Ops_Demirbas_Marka = -2804;

 //Teklif İniler  29__   ve SatınAlma İniler
    Ops_Teklif_Turu = -2901;
    Ops_Teklif_Durum = -2902;
    Ops_Teklif_Teslim_Sekli = -2903;
    Ops_Teklif_Odeme = -2904;
    Ops_Teklif_Bilgi = -2905;
    Ops_Teklif_Konusu = -2907;
    Ops_Teklif_BilgiSablonu = -2908;
    Ops_SatinAlma_Asama     = -2909;
    Ops_Teklif_Sonuc =-2911;
    Ops_Teklif_Sebebi =-2912;


 //Servis İniler 30__
    Ops_Servis_Teslim_Sekli = -3001;
    Ops_Servis_Kabul_Sekli = -3002;
    Ops_Servis_Bildirim_Şekli = -3003;
    Ops_Servis_Bildirim_Yazisi = -3004;
    Ops_Servis_OnaySekli = -3005;
    Ops_Servis_Turu = -3006;
    Ops_Servis_Durum = -3007;
    Ops_Servis_Ucreti = -3008;
    Ops_Servis_Konusu = -3009;
    Ops_ServisDetayGuruplari = -3010;
    Ops_Servis_TeslimAl = -3011;
    Ops_Servis_Sorunlar = -3012;
    Ops_Servis_Kapsam = -3013;
    Ops_Servis_Genel_Icerik = -3015;
    Ops_ServisAsama_Durum = -3027;

    Ops_Bildirim_Adres=-5001;
 //Döküman İniler  32__
    Ops_Dokuman_Modul = -3201;
    Ops_Dokuman_Bolumu = -3202;
    Ops_Dokuman_Konusu = -3203;
    Ops_Dokuman_Kategori = -3204;
    Ops_Dokuman_Yonu = -3205;
    Ops_Dokuman_Gizlilik = -3206;
    Ops_Dokuman_Tipi = -3207;
    Ops_Sozlesme_Sure = -3225;
 //YılSonu İniler 33_
    Ops_DevirIslemleri = -3301;

 //Duyuru
    DUYazilanlar_kaydedilmedi_onayla='Yazdıklarınız kaydedilmeyip iptal edilecektir. Onaylıyor musunuz?';
    DUAlici_sec='Alıcı girilmedi. Şimdi alıcı seçmek ister misiniz?';
    DUKonu_doldur='Konu boş olamaz!';
    DUIcerik_doldur='İçerik boş olamaz!';
    DUOnemderecesi_doldur='Önem Derecesi boş olamaz!';
    DUKategori_doldur='Kategori boş olamaz!';
 //Duyuru İniler 34_
    Ops_Seviye = -3401;
    Ops_DuyuruKategori = -3402;

 //IzinTurleri inileri 35_
    Ops_IzinTurleri = -3501;
    Ops_IzinTurleri_Birim = -3502;
    Ops_ISTEN_CIKIS_SEBEBI =-3503;
    Ops_ResmiTatilGunleri=-3540;
    Ops_DiniTatilGunleri2014=-32014;
    Ops_DiniTatilGunleri2015=-32015;
    Ops_DiniTatilGunleri2016=-32016;
    Ops_DiniTatilGunleri2017=-32017;
    Ops_DiniTatilGunleri2018=-32018;
    Ops_DiniTatilGunleri2019=-32019;
    Ops_DiniTatilGunleri2020=-32020;
    Ops_DiniTatilGunleri2021=-32021;
    Ops_DiniTatilGunleri2022=-32022;
    Ops_DiniTatilGunleri2023=-32023;
    Ops_DiniTatilGunleri2024=-32024;
    Ops_DiniTatilGunleri2025=-32025;
    Ops_DiniTatilGunleri2026=-32026;
    Ops_DiniTatilGunleri2027=-32027;
    Ops_DiniTatilGunleri2028=-32028;
    Ops_DiniTatilGunleri2029=-32029;
    Ops_DiniTatilGunleri2030=-32030;


   //////////////
   ///  G2LKS opsiyonkları
    Ops_G2LKS_Registry = -100040;
    Ops_G2LKS_LOGOExportPath = -100041;
    Ops_G2LKS_Server = -100042;
    Ops_G2LKS_Kullanici = -100043;
    Ops_G2LKS_Sifre = -100044;
    Ops_G2LKS_VeriTabani = -100045;
    Ops_G2LKS_FirmaNo = -100046;
    Ops_G2LKS_DonemNo = -100047;
    Ops_G2LKS_MuhasebeProg = -100048;
    Ops_G2LKS_MuhAktarDurum = -100049;
    Ops_G2LKS_VarsayilanMuhasebeProg = -100050;
    Ops_G2LKS_ORKAExportPath = -100051;

  //Entegrasyon Firmaları
    G2MuhEnt_LKS = 1;
    G2MuhEnt_Orka = 2;
    G2MuhEnt_Mikro = 3;

  //Destek
    Destekdlg_MusteriKodu = -3601;
    Destekdlg_SorumluKisi = -3602;
  // Social Media
  //m.y. Mücahit Yağmur
    sDegisiklikVar = 'İçerik değişikliği yok sayılacak. Yine de kapatmak istiyor musnuz?';
    sKayitlarSifirlanacak = 'Veri içeriği başlangıç değerlerine getirilecek. Devam etmek istiyor musunuz ?';
      { DONE -oMücahit -cConstants : GENINI içinden alınacak birçok Combo değerler, EVRAK_ tabloları unutulacak. }

    // constEvrakGizlilik = -4001// EVRAK_GIZLILIK -3206
    constEvrakGizlilik = Ops_Dokuman_Gizlilik;
    constEvrakCinsi = -4002;      // EVRAK_CINSI
    constEvrakYaziDurumu = -4003; // EVRAK_YAZI_DURUMU Aktif, Beklemede Durumx

    constEvrakGelenYerTur = -4004;// EVRAK_GELEN_YER_TUR  Kamu, Kurum içi, Tüzel..
    constEvrakGelisSekli = -4005; // EVRAK_GELIS_SEKLI    Posta, ePosta, Faks, Elden vs.vs
    constEvrakPostaTuru = -4006;  // EVRAK_POSTA_TUR      Elden, İadeli Taahhütlü, Adi Posta, APS vs

    Ops_SocialMedia = -48001;
    Ops_SocialMedia_Meta = -48002;
    Ops_SocialMedia_LinkedIn = -48003;
    Ops_SocialMedia_Xtwitter = -48004;
    Ops_SocialMedia_IMAP     = -48005;
    Ops_SocialMedia_MetaGuncelleme = -48006;


  // ASCII aliases for mixed-encoding usages
  Ops_HaftaninGunleri = Ops_HaftanınGünleri;
  Ops_Aktivite_Turu = Ops_Aktivite_Türü;
  Ops_Firsat_Sonuc = Ops_Firsat_Sonuç;
  Ops_StokKart_SayimTutanakTipi = Ops_StokKart_SayımTutanakTipi;
  Ops_KampanyaTurleri = Ops_KampanyaTürleri;
  Ops_KampanyaKosulTurleri = Ops_KampanyaKosulTürleri;
  Ops_KampanyaSonucTurleri = Ops_KampanyaSonucTürleri;
  Ops_Servis_Bildirim_Sekli = Ops_Servis_Bildirim_Şekli;
  Ops_POS_Turu = Ops_POS_Türü;
  Ops_POS_Statusu = Ops_POS_Statüsü;
  Ops_KrediKarti_Turu = Ops_KrediKarti_Türü;
  Ops_Varsayilan_Masraf_Gelir_Merkezleri = Ops_Varsayılan_Masraf_Gelir_Merkezleri;

implementation

end.






