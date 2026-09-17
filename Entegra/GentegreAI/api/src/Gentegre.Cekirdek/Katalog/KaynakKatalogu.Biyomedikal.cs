namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BİYOMEDİKAL LİSTE KAYNAKLARI (723).
///
/// "HAZIR" TANIMI TEK YERDE (`v_demirbas_durum`): arızasız **ve** kalibrasyonu
/// geçerli. Çalışan ama kalibrasyonu geçmiş cihaz kullanılabilirlik sayısına
/// girmez - ölçtüğü değere güvenilmiyor. Liste, pano ve döküm aynı görünümü
/// okur; üç yerde ayrı hesaplasaydık üç farklı yüzde çıkardı.
///
/// GECİKME GÜN OLARAK SQL'DE hesaplanır: "14 gün geçti" ile "14 gün kaldı"
/// arasındaki fark işaret; istemcide hesaplanırsa saat dilimi ve gün başlangıcı
/// yüzünden bir gün kayar.
/// </summary>
public static partial class KaynakKatalogu
{
    // ------------------------------------------------------- envanter ----
    private static KaynakTanimi DemirbasCihaz() => new(
        Ad: "demirbasCihaz",
        YetkiKodu: "demirbas.envanter",
        Kaynak: @"public.demirbas d
                  left join public.v_demirbas_durum v on v.id = d.id
                  left join public.departman dp on dp.id = d.departman_id
                  left join public.taraf z on z.id = d.zimmet_taraf_id",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.risk_sinifi, d.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "d.id", "sayi", "Id", Varsayilan: false),
            new("kod", "d.kod", "metin", "Demirbaş No", Genislik: 120),
            new("ad", "d.ad", "metin", "Cihaz", Genislik: 220),
            new("markaModel",
                "nullif(concat_ws(' ', nullif(d.marka, ''), nullif(d.model, '')), '')",
                "metin", "Marka / Model", Genislik: 180, Filtrelenebilir: false),
            new("seriNo", "d.seri_no", "metin", "Seri No", Genislik: 130),
            new("departmanAd", "coalesce(dp.ad, '')", "metin", "Birim", Genislik: 150),
            new("riskAdi",
                "case d.risk_sinifi when 1 then 'Yaşam desteği' when 2 then 'Yüksek'" +
                " when 3 then 'Orta' when 4 then 'Düşük' else '' end",
                "metin", "Risk", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("riskSinifi", "d.risk_sinifi", "kod", "Risk Kodu", Varsayilan: false,
                Kodlar: DbRiskKodlari),
            new("kalibrasyonGecerlilik", "d.kalibrasyon_gecerlilik", "tarih",
                "Kalibrasyon", Hizalama: "orta", Genislik: 110),
            // GECİKME İŞARETLİ SAYIDIR: eksi = geçti, artı = kaldı. Tek kolonda
            //   iki soru yanıtlanıyor, iki kolon açmak listeyi genişletirdi.
            // GEÇERLİLİK VARSA GÜN SAYILIR - periyot ayarına bakılmaz (728):
            //   periyodu yazılmamış ama sertifikası olan cihazın da kaç günü
            //   kaldığı bilinir. `v_demirbas_durum` ile aynı tâbilik ölçütü.
            new("kalibrasyonGun",
                "case when d.kalibrasyon_gecerlilik is not null" +
                " then (d.kalibrasyon_gecerlilik - current_date) end",
                "sayi", "Kal. Gün", Hizalama: "sag", Genislik: 90),
            new("sonrakiBakim", "d.sonraki_bakim", "tarih", "Bakım", Hizalama: "orta",
                Genislik: 110),
            new("bakimGun",
                "case when d.sonraki_bakim is not null" +
                " then (d.sonraki_bakim - current_date) end",
                "sayi", "Bakım Gün", Hizalama: "sag", Genislik: 95, Filtrelenebilir: false),
            new("hazir", "case when v.hazir then 1 else 0 end", "kod", "Hazır",
                Hizalama: "orta", Genislik: 90, Kodlar: DbEvetHayirKodlari),
            new("arizali", "case when v.arizali then 1 else 0 end", "kod", "Arızalı",
                Hizalama: "orta", Genislik: 90, Kodlar: DbEvetHayirKodlari),
            new("durumAdi",
                "case d.durum when 1 then 'Kullanımda' when 2 then 'Depoda'" +
                " when 3 then 'Kullanım dışı' when 4 then 'Hurda' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "d.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: DbDurumKodlari),
            new("yedekHavuz", "d.yedek_havuz", "kod", "Yedek Havuzu", Hizalama: "orta",
                Genislik: 110, Kodlar: DbEvetHayirKodlari),
            new("zimmetAd", "coalesce(z.unvan, '')", "metin", "Zimmet", Genislik: 160,
                Varsayilan: false),
            new("garantiBitis", "d.garanti_bitis", "tarih", "Garanti", Hizalama: "orta",
                Genislik: 110, Varsayilan: false),
            new("sozlesmeBitis", "d.sozlesme_bitis", "tarih", "Sözleşme", Hizalama: "orta",
                Genislik: 110, Varsayilan: false),
            new("alisTutari", "d.alis_tutari", "para", "Alış Bedeli", Hizalama: "sag",
                Genislik: 120, Varsayilan: false),
            new("departmanId", "d.departman_id", "sayi", "Birim Id", Varsayilan: false),
            new("subeId", "d.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // ---------------------------------------------------- kalibrasyon ----
    private static KaynakTanimi DemirbasKalibrasyon() => new(
        Ad: "demirbasKalibrasyon",
        YetkiKodu: "demirbas.kalibrasyon",
        Kaynak: @"public.demirbas_kalibrasyon k
                  join public.demirbas d on d.id = k.demirbas_id
                  left join public.taraf y on y.id = k.yapan_id
                  left join public.taraf f on f.id = k.firma_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.tarih desc, k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("kayitNo", "k.kayit_no", "metin", "Kayıt No", Genislik: 120),
            new("tarih", "k.tarih", "tarih", "Tarih", Hizalama: "orta", Genislik: 110),
            new("turAdi",
                "case k.tur when 1 then 'Kalibrasyon' when 2 then 'Elektriksel güvenlik'" +
                " when 3 then 'Doğrulama' else '' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur", "k.tur", "kod", "Tür Kodu", Varsayilan: false, Kodlar: DbKalibTurKodlari),
            new("demirbasKod", "d.kod", "metin", "Demirbaş No", Genislik: 120),
            new("cihazAd", "d.ad", "metin", "Cihaz", Genislik: 200),
            new("ayarSonrasi", "k.ayar_sonrasi", "kod", "Ayar Sonrası", Hizalama: "orta",
                Genislik: 110, Kodlar: DbEvetHayirKodlari),
            new("sonucAdi",
                "case k.sonuc when 0 then 'Açık' when 1 then 'Uygun'" +
                " when 2 then 'Uygun değil' when 3 then 'Şartlı uygun' else '' end",
                "metin", "Sonuç", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("sonuc", "k.sonuc", "kod", "Sonuç Kodu", Varsayilan: false,
                Kodlar: DbKalibSonucKodlari),
            // SINIR DIŞI NOKTA SAYISI: "uygun değil" tek başına az şey söyler,
            //   kaç noktada saptığı listede görünmeli.
            new("sinirDisi",
                "(select count(*) from public.demirbas_kalibrasyon_olcum o" +
                " where o.kalibrasyon_id = k.id and o.sonuc = 2)",
                "sayi", "Sınır Dışı", Hizalama: "sag", Genislik: 100,
                Filtrelenebilir: false),
            new("olcumSayi",
                "(select count(*) from public.demirbas_kalibrasyon_olcum o" +
                " where o.kalibrasyon_id = k.id)",
                "sayi", "Ölçüm", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("gecerlilik", "k.gecerlilik", "tarih", "Geçerlilik", Hizalama: "orta",
                Genislik: 110),
            new("yapanAd",
                "coalesce(nullif(f.unvan, ''), nullif(y.unvan, ''), '')",
                "metin", "Yapan", Genislik: 170, Filtrelenebilir: false),
            // İZLENEBİLİRLİK: ölçen cihazın kendi kalibrasyonu geçerli olmalı.
            //   Geçersizse ölçüm bir sayıdır, delil değildir - listede uyarsın.
            new("referansGecerli",
                "case when k.referans_gecerlilik is null then 0" +
                " when k.referans_gecerlilik >= k.tarih then 1 else 2 end",
                "kod", "Referans", Hizalama: "orta", Genislik: 110,
                Kodlar: DbReferansKodlari, Filtrelenebilir: false),
            new("referansCihaz", "k.referans_cihaz", "metin", "Referans Cihaz",
                Genislik: 180, Varsayilan: false),
            new("geriyeDonukDeger", "k.geriye_donuk_deger", "metin",
                "Geriye Dönük Değerlendirme", Varsayilan: false),
            new("demirbasId", "k.demirbas_id", "sayi", "Demirbaş Id", Varsayilan: false),
            new("subeId", "k.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // -------------------------------------------------------- iş emri ----
    private static KaynakTanimi DemirbasIsEmri() => new(
        Ad: "demirbasIsEmri",
        YetkiKodu: "demirbas.isemri",
        Kaynak: @"public.demirbas_is_emri e
                  join public.demirbas d on d.id = e.demirbas_id
                  left join public.departman dp on dp.id = e.departman_id
                  left join public.taraf y on y.id = e.yapan_id
                  left join public.taraf f on f.id = e.firma_id
                  left join public.demirbas yd on yd.id = e.yedek_demirbas_id",
        SubeKolonu: "e.sube_id",
        // AÇIK OLANLAR ÖNCE, İÇİNDE ÖNCELİĞE GÖRE: kritik arıza sayfa altında
        //   kalmamalı - öncelik cihazın yerinden gelir, kendisinden değil.
        VarsayilanSirala: "case when e.durum between 0 and 4 then 0 else 1 end," +
                          " e.oncelik, e.bildirim_zamani",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "e.id", "sayi", "Id", Varsayilan: false),
            new("isEmriNo", "e.is_emri_no", "metin", "İş Emri", Genislik: 120),
            new("turAdi",
                "case e.tur when 1 then 'Periyodik bakım' when 2 then 'Arıza'" +
                " when 3 then 'Kalibrasyon kaynaklı' when 4 then 'Kurulum' else '' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur", "e.tur", "kod", "Tür Kodu", Varsayilan: false, Kodlar: DbIsEmriTurKodlari),
            new("demirbasKod", "d.kod", "metin", "Demirbaş No", Genislik: 120),
            new("cihazAd", "d.ad", "metin", "Cihaz", Genislik: 200),
            new("departmanAd", "coalesce(dp.ad, '')", "metin", "Birim", Genislik: 140),
            new("arizaMetni", "e.ariza_metni", "metin", "Arıza / İş", Genislik: 280),
            new("oncelikAdi",
                "case e.oncelik when 1 then 'Kritik' when 2 then 'Yüksek'" +
                " when 3 then 'Normal' when 4 then 'Düşük' else '' end",
                "metin", "Öncelik", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("oncelik", "e.oncelik", "kod", "Öncelik Kodu", Varsayilan: false,
                Kodlar: DbOncelikKodlari),
            // DURUŞ BİLDİRİM ANINDAN sayılır, "ne zaman bakıldığı"ndan değil.
            new("durusSaat",
                "case when e.tur = 2 then round(extract(epoch from" +
                " (coalesce(e.tamamlanma, now()) - e.bildirim_zamani)) / 3600)::int end",
                "sayi", "Duruş (sa)", Hizalama: "sag", Genislik: 100,
                Filtrelenebilir: false),
            // YANIT SÜRESİ ayrı ölçülür: ilki biyomedikalin, onarım süresi
            //   çoğu zaman tedarikçinin performansıdır.
            new("yanitDk",
                "case when e.ilk_mudahale is not null then round(extract(epoch from" +
                " (e.ilk_mudahale - e.bildirim_zamani)) / 60)::int end",
                "sayi", "Yanıt (dk)", Hizalama: "sag", Genislik: 100,
                Filtrelenebilir: false),
            // YEDEK: yaşam destek cihazında yedek atanmadan iş emri açılmaz -
            //   atanmamışsa listede görünsün.
            new("yedekKod", "coalesce(yd.kod, '')", "metin", "Yedek Cihaz", Genislik: 120,
                Filtrelenebilir: false),
            new("durumAdi",
                "case e.durum when 0 then 'Açık' when 1 then 'Atandı'" +
                " when 2 then 'Müdahalede' when 3 then 'Parça bekliyor'" +
                " when 4 then 'Dış serviste' when 5 then 'Tamamlandı'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 140, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "e.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: DbIsEmriDurumKodlari),
            new("yapanAd",
                "coalesce(nullif(f.unvan, ''), nullif(y.unvan, ''), '')",
                "metin", "Yapan", Genislik: 160, Filtrelenebilir: false),
            new("planlanan", "e.planlanan", "tarih", "Planlanan", Hizalama: "orta",
                Genislik: 110),
            new("maliyet", "e.maliyet", "para", "Maliyet", Hizalama: "sag", Genislik: 110,
                Varsayilan: false),
            new("hastaEtkilendi", "e.hasta_etkilendi", "kod", "Hasta Etkilendi",
                Hizalama: "orta", Genislik: 120, Kodlar: DbEvetHayirKodlari),
            new("bildirimZamani", "e.bildirim_zamani", "zaman", "Bildirim", Genislik: 140,
                Varsayilan: false),
            new("demirbasId", "e.demirbas_id", "sayi", "Demirbaş Id", Varsayilan: false),
            new("subeId", "e.sube_id", "sayi", "Şube", Varsayilan: false),
            // ONARIM ONAYI (752): "bu onarım onaylı mı" sorusu listede
            //   yanıtlanmalı - eşiği aşan ama onaya gönderilmemiş iş emri,
            //   faturası gelene kadar kimsenin dikkatini çekmez.
            new("onayDurumAdi",
                "case coalesce(e.onay_durum, 0) when 1 then 'Onayda'" +
                " when 2 then 'Onaylı' when 3 then 'REDDEDİLDİ' else '—' end",
                "metin", "Onarım Onayı", Hizalama: "orta", Genislik: 120,
                Bicim: "rozet", Filtrelenebilir: false),
            new("onayDurum", "coalesce(e.onay_durum, 0)", "sayi", "Onay Kodu",
                Varsayilan: false),
            new("onayliTutar", "e.onayli_tutar", "para", "Onaylanan", Hizalama: "sag",
                Genislik: 110, Varsayilan: false),
        });

    internal static readonly Dictionary<string, string> DbRiskKodlari = new()
    {
        ["1"] = "Yaşam desteği", ["2"] = "Yüksek", ["3"] = "Orta", ["4"] = "Düşük",
    };

    internal static readonly Dictionary<string, string> DbDurumKodlari = new()
    {
        ["1"] = "Kullanımda", ["2"] = "Depoda", ["3"] = "Kullanım dışı", ["4"] = "Hurda",
    };

    internal static readonly Dictionary<string, string> DbKalibTurKodlari = new()
    {
        ["1"] = "Kalibrasyon", ["2"] = "Elektriksel güvenlik", ["3"] = "Doğrulama",
    };

    internal static readonly Dictionary<string, string> DbKalibSonucKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Uygun", ["2"] = "Uygun değil", ["3"] = "Şartlı uygun",
    };

    internal static readonly Dictionary<string, string> DbReferansKodlari = new()
    {
        ["0"] = "Belirtilmedi", ["1"] = "Geçerli", ["2"] = "Süresi dolmuş",
    };

    internal static readonly Dictionary<string, string> DbIsEmriTurKodlari = new()
    {
        ["1"] = "Periyodik bakım", ["2"] = "Arıza", ["3"] = "Kalibrasyon kaynaklı",
        ["4"] = "Kurulum",
    };

    internal static readonly Dictionary<string, string> DbIsEmriDurumKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Atandı", ["2"] = "Müdahalede", ["3"] = "Parça bekliyor",
        ["4"] = "Dış serviste", ["5"] = "Tamamlandı", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> DbOncelikKodlari = new()
    {
        ["1"] = "Kritik", ["2"] = "Yüksek", ["3"] = "Normal", ["4"] = "Düşük",
    };

    internal static readonly Dictionary<string, string> DbEvetHayirKodlari = new()
    {
        ["1"] = "Evet", ["0"] = "Hayır",
    };
}
