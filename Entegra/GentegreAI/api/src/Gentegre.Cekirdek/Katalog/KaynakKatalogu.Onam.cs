namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FAZ 0 — ORTAK PLATFORM LISTELERI (398-401): onam, bildirim ve klinik
/// kataloglar (ICD-10 / ilaç).
///
/// Üçü de tek bir dikeye ait değil: onamı teletıp da genetik de ister,
/// bildirimi randevu da panik değer de, ICD'yi muayene de provizyon da.
/// Yol haritası bu yüzden ortak platforma koydu - her modül kendi kopyasını
/// yazarsa "hangi onam ne zaman verildi" ya da "SMS gitti mi" soruları
/// modül başına ayrı yerde aranır.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Onam metinleri ve sürümleri (398).</summary>
    private static KaynakTanimi OnamMetni() => new(
        Ad: "onam-metni",
        YetkiKodu: "onam",
        Kaynak: "public.onam_metni m",
        VarsayilanSirala: "m.kod asc, m.surum desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "m.id",           "sayi",  "Id", Varsayilan: false),
            new("kod",          "m.kod",          "metin", "Kod", Genislik: 160),
            new("ad",           "m.ad",           "metin", "Onam Adı", Genislik: 280),
            new("turAdi",
                "case m.tur when 1 then 'KVKK Aydınlatma' when 2 then 'Açık Rıza' "
                + "when 3 then 'Tıbbi İşlem' when 4 then 'Teletıp' when 5 then 'Genetik' "
                + "when 6 then 'Fotoğraf / Video' else 'Diğer' end",
                                                  "metin", "Tür", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 140,
                                                  Filtrelenebilir: false),
            new("tur",          "m.tur",          "kod",   "Tür Kodu", Varsayilan: false),
            // SURUM listede GORUNUR: aynı kodun iki sürümü yan yana durur ve
            //   hangisinin yürürlükte olduğu tarihlerden okunur.
            new("surum",        "m.surum",        "sayi",  "Sürüm", Hizalama: "orta", Genislik: 80),
            new("yururlukBas",  "m.yururluk_bas", "tarih", "Yürürlük", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy", Genislik: 110),
            new("yururlukBit",  "m.yururluk_bit", "tarih", "Bitiş", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy", Genislik: 110),
            new("zorunlu",      "m.zorunlu",      "mantik", "Zorunlu", Hizalama: "orta", Genislik: 90),
            new("durum",        "m.durum",        "kod",   "Durum", Hizalama: "orta", Genislik: 90),
            new("aciklama",     "m.aciklama",     "metin", "Açıklama", Varsayilan: false)
        });

    /// <summary>Verilen / reddedilen onamlar (398). Kaynak generic.</summary>
    private static KaynakTanimi Onam() => new(
        Ad: "onam",
        YetkiKodu: "onam",
        Kaynak: "public.onam o "
              + "  join public.onam_metni m on m.id = o.metin_id "
              + "  join public.taraf t on t.id = o.taraf_id "
              + "  left join public.taraf v on v.id = o.veren_taraf_id",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.tarih desc, o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "o.id",       "sayi",  "Id", Varsayilan: false),
            new("tarih",      "o.tarih",    "tarih", "Tarih", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("kisi",       "t.unvan",    "metin", "Kişi", Genislik: 220),
            new("onamAdi",    "m.ad",       "metin", "Onam", Genislik: 260),
            new("surum",      "o.surum",    "sayi",  "Sürüm", Hizalama: "orta", Genislik: 80),
            // SONUC rozet: onam listesinde okunacak TEK sey "verdi mi".
            new("sonucAdi",
                "case o.sonuc when 1 then 'Verildi' when 0 then 'Reddedildi' "
                + "else 'Geri Çekildi' end",
                                            "metin", "Sonuç", Hizalama: "orta",
                                            Bicim: "rozet", Genislik: 120, Filtrelenebilir: false),
            new("sonuc",      "o.sonuc",    "kod",   "Sonuç Kodu", Varsayilan: false),
            new("kanalAdi",
                "case o.kanal when 1 then 'Islak İmza' when 2 then 'Dijital' "
                + "when 3 then 'Sözlü' when 4 then 'e-İmza' else '' end",
                                            "metin", "Kanal", Hizalama: "orta", Genislik: 110,
                                            Filtrelenebilir: false),
            new("kanal",      "o.kanal",    "kod",   "Kanal Kodu", Varsayilan: false),
            // VEREN kisi hasta degilse (veli/vasi) listede gorunur - bos ise
            //   onami kisinin KENDISI vermistir.
            new("verenKisi",  "coalesce(v.unvan, '')", "metin", "Veren (vekil)", Genislik: 200,
                                            Varsayilan: false),
            new("yakinlik",   "o.veren_yakinlik", "metin", "Yakınlık", Varsayilan: false),
            new("kaynakTur",  "o.kaynak_tur", "kod", "Kaynak Türü", Varsayilan: false),
            new("kaynakId",   "o.kaynak_id",  "sayi", "Kaynak Id", Varsayilan: false),
            new("gecerlilik", "o.gecerlilik", "tarih", "Geçerlilik", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy", Genislik: 110, Varsayilan: false),
            new("dokumanId",  "o.dokuman_id", "sayi", "Belge Id", Varsayilan: false),
            new("tarafId",    "o.taraf_id",   "sayi", "Kişi Id", Varsayilan: false),
            new("aciklama",   "o.aciklama",   "metin", "Açıklama", Varsayilan: false)
        });

    /// <summary>Bildirim şablonları (399).</summary>
    private static KaynakTanimi BildirimSablon() => new(
        Ad: "bildirim-sablon",
        YetkiKodu: "bildirim_sablon",
        Kaynak: "public.bildirim_sablon s",
        VarsayilanSirala: "s.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "s.id",    "sayi",  "Id", Varsayilan: false),
            new("kod",      "s.kod",   "metin", "Kod", Genislik: 200),
            new("ad",       "s.ad",    "metin", "Şablon", Genislik: 240),
            new("kanalAdi",
                "case s.kanal when 1 then 'SMS' when 2 then 'E-posta' "
                + "when 3 then 'Push' when 4 then 'WhatsApp' else '' end",
                                       "metin", "Kanal", Hizalama: "orta", Bicim: "rozet",
                                       Genislik: 110, Filtrelenebilir: false),
            new("kanal",    "s.kanal", "kod",   "Kanal Kodu", Varsayilan: false),
            new("konu",     "s.konu",  "metin", "Konu", Genislik: 220),
            new("govde",    "s.govde", "metin", "Gövde", Varsayilan: false),
            new("saatBas",  "s.saat_bas", "sayi", "Saat (baş)", Hizalama: "orta",
                                       Genislik: 90, Varsayilan: false),
            new("saatBit",  "s.saat_bit", "sayi", "Saat (bit)", Hizalama: "orta",
                                       Genislik: 90, Varsayilan: false),
            new("durum",    "s.durum", "kod",   "Durum", Hizalama: "orta", Genislik: 90)
        });

    /// <summary>
    /// Bildirim kuyruğu (399) - "gitti mi" sorusunun tek yeri.
    /// Gövde listede gösterilmez (uzun); kolon seçicide açılabilir.
    /// </summary>
    private static KaynakTanimi Bildirim() => new(
        Ad: "bildirim",
        YetkiKodu: "bildirim",
        Kaynak: "public.bildirim b "
              + "  left join public.bildirim_sablon s on s.id = b.sablon_id "
              + "  left join public.taraf t on t.id = b.taraf_id "
              + "  left join public.entegrasyon_hesap h on h.id = b.hesap_id",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "b.id",        "sayi",  "Id", Varsayilan: false),
            new("planlanan",  "b.planlanan", "tarih", "Planlanan", Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("kanalAdi",
                "case b.kanal when 1 then 'SMS' when 2 then 'E-posta' "
                + "when 3 then 'Push' when 4 then 'WhatsApp' else '' end",
                                             "metin", "Kanal", Hizalama: "orta", Bicim: "rozet",
                                             Genislik: 100, Filtrelenebilir: false),
            new("kanal",      "b.kanal",     "kod",   "Kanal Kodu", Varsayilan: false),
            new("alici",      "b.alici",     "metin", "Alıcı", Genislik: 180),
            new("kisi",       "coalesce(t.unvan, '')", "metin", "Kişi", Genislik: 200),
            new("sablonAdi",  "coalesce(s.ad, '')", "metin", "Şablon", Genislik: 180),
            new("konu",       "b.konu",      "metin", "Konu", Genislik: 200, Varsayilan: false),
            new("govde",      "b.govde",     "metin", "Gövde", Varsayilan: false),
            new("durumAdi",
                "case b.durum when 1 then 'Kuyrukta' when 2 then 'Gönderiliyor' "
                + "when 3 then 'Gönderildi' when 4 then 'Hata' when 5 then 'İptal' "
                + "else 'Vazgeçildi' end",
                                             "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                             Genislik: 120, Filtrelenebilir: false),
            new("durum",      "b.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("deneme",     "b.deneme",    "sayi",  "Deneme", Hizalama: "orta", Genislik: 80),
            new("gonderim",   "b.gonderim",  "tarih", "Gönderim", Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("hata",       "b.hata",      "metin", "Hata", Genislik: 240),
            new("hesapAdi",   "coalesce(h.ad, '')", "metin", "Sağlayıcı", Genislik: 160,
                                             Varsayilan: false),
            new("kaynakTur",  "b.kaynak_tur", "kod",  "Kaynak Türü", Varsayilan: false),
            new("kaynakId",   "b.kaynak_id",  "sayi", "Kaynak Id", Varsayilan: false),
            new("oncelik",    "b.oncelik",    "sayi", "Öncelik", Hizalama: "orta",
                                             Genislik: 80, Varsayilan: false)
        });

    /// <summary>ICD-10 tanı kataloğu (400) - salt görünüm, senkron doldurur.</summary>
    private static KaynakTanimi Icd() => new(
        Ad: "icd",
        YetkiKodu: "katalog",
        Kaynak: "public.icd i",
        VarsayilanSirala: "i.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("kod",     "i.kod",     "metin", "ICD Kodu", Genislik: 110),
            new("ad",      "i.ad",      "metin", "Tanı", Genislik: 420),
            new("ustKod",  "coalesce(i.ust_kod, '')", "metin", "Üst Kod", Hizalama: "orta",
                                        Genislik: 110),
            new("seviye",  "i.seviye",  "sayi",  "Seviye", Hizalama: "orta", Genislik: 80,
                                        Varsayilan: false),
            new("cinsiyet","i.cinsiyet","kod",   "Cinsiyet Kısıtı", Varsayilan: false),
            new("aktif",   "i.aktif",   "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("guncelleme", "i.guncelleme", "tarih", "Güncelleme", Hizalama: "orta",
                                        Bicim: "dd.MM.yyyy", Genislik: 110, Varsayilan: false)
        });

    /// <summary>İlaç kataloğu (400) - barkod birincil.</summary>
    private static KaynakTanimi Ilac() => new(
        Ad: "ilac",
        YetkiKodu: "katalog",
        Kaynak: "public.ilac i left join public.stok s on s.id = i.stok_id",
        VarsayilanSirala: "i.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "i.id",          "sayi",  "Id", Varsayilan: false),
            new("barkod",      "i.barkod",      "metin", "Barkod", Genislik: 140),
            new("ad",          "i.ad",          "metin", "İlaç", Genislik: 340),
            new("etkenMadde",  "i.etken_madde", "metin", "Etken Madde", Genislik: 240),
            new("atcKod",      "i.atc_kod",     "metin", "ATC", Hizalama: "orta", Genislik: 100),
            new("firma",       "i.firma",       "metin", "Firma", Genislik: 200, Varsayilan: false),
            new("receteTuruAdi",
                "case i.recete_turu when 1 then 'Kırmızı' when 2 then 'Yeşil' "
                + "when 3 then 'Mor' when 4 then 'Turuncu' else 'Normal' end",
                                                "metin", "Reçete", Hizalama: "orta",
                                                Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("receteTuru",  "i.recete_turu", "kod",   "Reçete Kodu", Varsayilan: false),
            new("stokAdi",     "coalesce(s.ad, '')", "metin", "Stok Kartı", Genislik: 200,
                                                Varsayilan: false),
            new("aktif",       "i.aktif",       "mantik","Aktif", Hizalama: "orta", Genislik: 80)
        });
}
