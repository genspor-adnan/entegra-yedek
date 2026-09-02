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
                "left join public.v_entegrasyon_kod_lookup k on k.id = e.kod",
        VarsayilanSirala: "e.kod, e.test_mi desc, e.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "e.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",      "e.kod",  "metin", "Kod", Genislik: 90),
            new("kodAdi",   "coalesce(k.ad, e.kod)", "metin", "Entegrasyon",
                                               Genislik: 240, Filtrelenebilir: false),
            new("ad",       "e.ad",   "metin", "Ad", Genislik: 200),
            new("sube",     "coalesce(s.ad, 'Tümü')", "metin", "Şube", Genislik: 140,
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
            new("aktif",    "e.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("sonKullanim", "e.son_kullanim", "tarih", "Son Kullanım",
                                               Bicim: "dd.MM.yyyy HH:mm", Genislik: 140),
            new("sonSonuc", "e.son_sonuc", "metin", "Son Sonuç", Genislik: 260),
        });
}
