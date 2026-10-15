namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SEVK KARTI (1110) — mockup Ekranlar/Muayene/sevk_karti_v2.html (sade).
///
/// Altı alan: tür, nereye (kurum dışında tesis + klinik; kurum içinde / yatışta bölüm),
/// neden, ulaşım, not, ekler (ekler gösterimdir, kayıt değil). Hasta, hekim, bölüm ve
/// başvuru muayeneden gelir. Kart YALNIZ TASLAĞI yazar; gönder / iptal / sonuç
/// SevkUclari'ndadır (DB tetiği kartın durum değiştirmesine izin vermez).
/// </summary>
public static partial class KartKatalogu
{
    private const int SevkLog = 1550;

    private static KartTanimi SevkKarti() => new(
        Ad: "sevk",
        // Muayene yetkisi (16.10.2026) - muayene.sevk yalnız Sevk Listesi menüsü.
        YetkiKodu: "muayene",
        Tablo: "public.sevk",
        LogTabloId: SevkLog,
        SubeKolonu: "sube_id",
        // SİLME AÇIK (kullanıcı 15.10.2026: listeye sil ekle) - yalnız TASLAK silinir, kural db/1111 tetiğinde.
        // ANAHTARLAR DB KOLON ADLARI (kart yazıcısı kolona yazar).
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["tur"] = (short)1, ["ulasim"] = (short)1, ["neden"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("no", "no", "metin", Yazilabilir: false, Baslik: "No", Grup: "Sevk", AltGrup: "Durum"),
            new("durum", "durum", "kod", Yazilabilir: false, SabitKodlar: KaynakKatalogu.SevkDurumKodlari, Baslik: "Durum", Grup: "Sevk", AltGrup: "Durum"),
            new("tarafId", "taraf_id", "kod", Zorunlu: true, YalnizYeniKayitta: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "Sevk", AltGrup: "Hasta"),
            new("belgeId", "belge_id", "sayi", Yazilabilir: false, Baslik: "Başvuru", Grup: "Sevk", AltGrup: "Durum"),
            new("muayeneId", "muayene_id", "sayi", Yazilabilir: false, Baslik: "Muayene", Grup: "Sevk", AltGrup: "Durum"),
            new("hekimId", "hekim_id", "kod", Yazilabilir: false, KodTablosu: "public.v_hekim_lookup", Baslik: "Hekim", Grup: "Sevk", AltGrup: "Durum"),
            new("bolumId", "bolum_id", "kod", Yazilabilir: false, KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "Sevk", AltGrup: "Durum"),
            new("sevkZamani", "sevk_zamani", "zaman", Yazilabilir: false, Baslik: "Sevk zamanı", Grup: "Sevk", AltGrup: "Durum"),

            new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: KaynakKatalogu.SevkTurKodlari, Baslik: "Tür", Grup: "Sevk", AltGrup: "Sevk"),
            // NEREYE - kurum dışı: tesis (SKRS kurum kodu + ad) ve klinik (SKRS); kurum içi / yatış: bölüm.
            new("tesisKodu", "tesis_kodu", "metin", EnFazlaUzunluk: 20, Baslik: "Tesis kodu", Grup: "Sevk", AltGrup: "Sevk"),
            new("tesisAd", "tesis_ad", "metin", EnFazlaUzunluk: 160, Baslik: "Tesis", Grup: "Sevk", AltGrup: "Sevk"),
            new("klinikId", "klinik_id", "kod", KodTablosu: "public.v_skrs_klinik_lookup", Baslik: "Klinik", Grup: "Sevk", AltGrup: "Sevk"),
            new("hedefBolumId", "hedef_bolum_id", "kod", KodTablosu: "public.v_tibbi_bolum_lookup" /* 1112 */, Baslik: "Bölüm", Grup: "Sevk", AltGrup: "Sevk"),
            new("neden", "neden", "kod", Zorunlu: true, SabitKodlar: KaynakKatalogu.SevkNedenKodlari, Baslik: "Neden", Grup: "Sevk", AltGrup: "Sevk"),
            new("ulasim", "ulasim", "kod", SabitKodlar: KaynakKatalogu.SevkUlasimKodlari, Baslik: "Ulaşım", Grup: "Sevk", AltGrup: "Sevk"),
            new("notu", "notu", "metin", Zorunlu: true, EnFazlaUzunluk: 500, Baslik: "Not (karşı hekime)", Grup: "Sevk", AltGrup: "Not"),

            // GÖNDERİM (uçlar yazar)
            new("imzaZamani", "imza_zamani", "zaman", Yazilabilir: false, Baslik: "Gönderildi", Grup: "Sevk", AltGrup: "Gönderim"),
            new("medulaSevkNo", "medula_sevk_no", "metin", Yazilabilir: false, Baslik: "Medula sevk no", Grup: "Sevk", AltGrup: "Gönderim"),
            new("sonucZamani", "sonuc_zamani", "zaman", Yazilabilir: false, Baslik: "Sonuç döndü", Grup: "Sevk", AltGrup: "Gönderim"),
            new("iptalGerekce", "iptal_gerekce", "metin", Yazilabilir: false, Baslik: "İptal gerekçesi", Grup: "Sevk", AltGrup: "Gönderim"),
        });
}
