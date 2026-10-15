namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KONSÜLTASYON İSTEK KARTI (1107) — mockup Ekranlar/Muayene/konsultasyon_karti.html (1).
///
/// İki taraf: <b>İsteyen</b> (kim, neden soruyor) · <b>Karşılayan</b> (kime, nerede, ne kadar
/// acil). Karşılayan hekim zorunlu değil - bölüm yeter, bölümün hekimi "Yanıtla" der.
/// Soru isteyen hekimindir; gönderildikten sonra yanıtlayan değiştiremez (e-Nabız 252
/// konsültasyon notu, 500 karakter).
///
/// Durum kartta yazılabilir AMA yalnız Taslak ↔ Gönderildi (6 ↔ 1); diğer geçişler
/// (yanıtla, yönlendir, reddet, gördüm) KonsultasyonUclari'ndadır ve DB tetiği kartın
/// başka geçiş yapmasına izin vermez.
/// </summary>
public static partial class KartKatalogu
{
    private const int KonsultasyonLog = 1540;

    private static KartTanimi KonsultasyonKarti() => new(
        Ad: "konsultasyon",
        YetkiKodu: "muayene.konsultasyon",
        Tablo: "public.konsultasyon",
        LogTabloId: KonsultasyonLog,
        SubeKolonu: "sube_id",
        // SİLME AÇIK (kullanıcı 15.10.2026: listeye sil ekle) - yalnız TASLAK silinir, kural db/1111 tetiğinde.
        // ANAHTARLAR DB KOLON ADLARI (kart yazıcısı kolona yazar).
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)6, ["aciliyet"] = (short)1, ["merkez"] = (short)1,
            ["karsilama_yeri"] = (short)1, ["neden"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("no", "no", "metin", Yazilabilir: false, Baslik: "No", Grup: "Konsültasyon", AltGrup: "Durum"),
            new("durum", "durum", "kod", SabitKodlar: KaynakKatalogu.KonsDurumKodlari, Baslik: "Durum", Grup: "Konsültasyon", AltGrup: "Durum"),
            new("tarafId", "taraf_id", "kod", Zorunlu: true, YalnizYeniKayitta: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "Konsültasyon", AltGrup: "Hasta"),
            new("belgeId", "belge_id", "sayi", Yazilabilir: false, Baslik: "Başvuru", Grup: "Konsültasyon", AltGrup: "Durum"),
            new("isteyenMuayeneId", "isteyen_muayene_id", "sayi", Yazilabilir: false, Baslik: "İsteyen Muayene", Grup: "Konsültasyon", AltGrup: "Durum"),

            // İSTEYEN
            new("istekZamani", "istek_zamani", "zaman", Yazilabilir: false, Baslik: "İstek zamanı", Grup: "Konsültasyon", AltGrup: "İsteyen"),
            new("istekBolumId", "istek_bolum_id", "kod", Zorunlu: true, KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm / birim", Grup: "Konsültasyon", AltGrup: "İsteyen"),
            new("isteyenHekimId", "isteyen_hekim_id", "kod", Zorunlu: true, KodTablosu: "public.v_hekim_lookup",
                Baslik: "İsteyen hekim", Grup: "Konsültasyon", AltGrup: "İsteyen"),
            new("sorumluHekimId", "sorumlu_hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Sorumlu hekim", Grup: "Konsültasyon", AltGrup: "İsteyen"),
            new("neden", "neden", "kod", Zorunlu: true, SabitKodlar: KaynakKatalogu.KonsNedenKodlari,
                Baslik: "Neden", Grup: "Konsültasyon", AltGrup: "İsteyen"),

            // KARŞILAYAN
            new("merkez", "merkez", "kod", SabitKodlar: KaynakKatalogu.KonsMerkezKodlari, Baslik: "Merkez", Grup: "Konsültasyon", AltGrup: "Karşılayan"),
            new("disMerkez", "dis_merkez", "metin", EnFazlaUzunluk: 160, Baslik: "Dış merkez", Grup: "Konsültasyon", AltGrup: "Karşılayan"),
            new("hedefBolumId", "hedef_bolum_id", "kod", Zorunlu: true, KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm", Grup: "Konsültasyon", AltGrup: "Karşılayan"),
            new("hedefHekimId", "hedef_hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Hekim", Grup: "Konsültasyon", AltGrup: "Karşılayan"),
            new("karsilamaYeri", "karsilama_yeri", "kod", Zorunlu: true, SabitKodlar: KaynakKatalogu.KonsKarsilamaKodlari,
                Baslik: "Karşılama yeri", Grup: "Konsültasyon", AltGrup: "Karşılayan"),
            new("aciliyet", "aciliyet", "kod", Zorunlu: true, SabitKodlar: KaynakKatalogu.KonsAciliyetKodlari,
                Baslik: "Aciliyet", Grup: "Konsültasyon", AltGrup: "Aciliyet"),
            new("sonZaman", "son_zaman", "zaman", Yazilabilir: false, Baslik: "Yanıt süresi sonu", Grup: "Konsültasyon", AltGrup: "Aciliyet"),

            // SORU (e-Nabız 252 konsültasyon notu)
            new("soru", "soru", "metin", Zorunlu: true, EnFazlaUzunluk: 500, Baslik: "Soru / istek notu", Grup: "Konsültasyon", AltGrup: "Soru"),

            // YANIT (uçlar yazar)
            new("yanitlayanId", "yanitlayan_id", "kod", Yazilabilir: false, KodTablosu: "public.v_hekim_lookup",
                Baslik: "Yanıtlayan", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("yanitlamaZamani", "yanitlama_zamani", "zaman", Yazilabilir: false, Baslik: "Yanıtlamaya alındı", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("yanitMuayeneId", "yanit_muayene_id", "sayi", Yazilabilir: false, Baslik: "Yanıt Muayenesi", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("yanitZamani", "yanit_zamani", "zaman", Yazilabilir: false, Baslik: "Yanıtlandı", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("sonuc", "sonuc", "kod", Yazilabilir: false, SabitKodlar: KaynakKatalogu.KonsSonucKodlari, Baslik: "Sonuç", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("retGerekce", "ret_gerekce", "metin", Yazilabilir: false, Baslik: "Ret gerekçesi", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("yonlendirmeNotu", "yonlendirme_notu", "metin", Yazilabilir: false, Baslik: "Yönlendirme notu", Grup: "Konsültasyon", AltGrup: "Yanıt"),
            new("gorduZamani", "gordu_zamani", "zaman", Yazilabilir: false, Baslik: "İsteyen gördü", Grup: "Konsültasyon", AltGrup: "Yanıt"),
        });
}
