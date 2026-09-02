namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ENTEGRASYON HESAPLARI listesi (336) - Ayarlar › Kayıt Kabul › Entegrasyon.
///
/// Şifre KOLON OLARAK DÖNMEZ: listede yalnız "dolu mu" bilgisi gösterilir;
/// gerçek değer yalnız kartı açan (yetkili) kullanıcıya gider.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi EntegrasyonHesap() => new(
        Ad: "entegrasyon-hesap",
        YetkiKodu: "entegrasyon",
        Kaynak: "public.entegrasyon_hesap e " +
                "left join public.sube s on s.id = e.sube_id " +
                "left join public.sube bs on bs.id = e.baz_sube_id " +
                "left join public.v_entegrasyon_kod_lookup k on k.id = e.kod " +
                "left join public.ebelge_entegrator ent on ent.id = e.entegrator_id",
        // Sira kullanici istegi (337): e-Fatura en ustte, sonra UTS, sonra
        //   kod listesinin kendi sirasi.
        VarsayilanSirala: "coalesce(k.sira, 99), e.kod, e.test_mi desc, e.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "e.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",      "e.kod",  "metin", "Kod", Genislik: 90),
            new("kodAdi",   "coalesce(k.ad, e.kod)", "metin", "Entegrasyon",
                                               Genislik: 240, Filtrelenebilir: false),
            new("ad",       "e.ad",   "metin", "Ad", Genislik: 200),
            // Sube / baz sube ROZET (kullanici): hesabin kime ait oldugu ve
            //   baska subeden mi okundugu bir bakista gorulsun.
            new("sube",     "coalesce(s.ad, 'Tümü')", "metin", "Şube", Genislik: 140,
                                               Bicim: "rozet", Hizalama: "orta",
                                               Filtrelenebilir: false),
            // Baz sube (338): dolu ise bu subenin islemleri o subenin hesabiyla.
            new("bazSube",  "coalesce(bs.ad, 'Kendisi')", "metin", "Baz Şube", Genislik: 130,
                                               Bicim: "rozet", Hizalama: "orta",
                                               Filtrelenebilir: false),
            new("ortam",
                "case when e.test_mi = 1 then 'TEST' else 'CANLI' end",
                                      "metin", "Ortam", Hizalama: "orta",
                                      Bicim: "rozet", Genislik: 90, Filtrelenebilir: false),
            new("testMi",   "e.test_mi", "sayi", "Test Kodu", Varsayilan: false),
            new("kullaniciAdi", "e.kullanici_adi", "metin", "Kullanıcı", Genislik: 160),
            // Sifre DEGERI listede yok: yalniz tanimli olup olmadigi.
            new("sifreVar",
                "case when coalesce(e.sifre, '') <> '' then 1 else 0 end",
                                      "mantik", "Şifre", Hizalama: "orta", Genislik: 80,
                                      Filtrelenebilir: false),
            new("uygulamaKodu", "e.uygulama_kodu", "metin", "Uygulama Kodu", Genislik: 140),
            // e-Belge satirlarinda dolu (337); oteki servislerde bos.
            new("entegratorAdi", "coalesce(ent.ad, '')", "metin", "Entegratör",
                                      Genislik: 130, Filtrelenebilir: false),
            new("aktif",    "e.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("sonKullanim", "e.son_kullanim", "tarih", "Son Kullanım",
                                               Bicim: "dd.MM.yyyy HH:mm", Genislik: 140),
            new("sonSonuc", "e.son_sonuc", "metin", "Son Sonuç", Genislik: 260),
        });
}
