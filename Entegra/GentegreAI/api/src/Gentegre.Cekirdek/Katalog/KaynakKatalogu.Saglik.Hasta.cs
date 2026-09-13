namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HASTA KAYIT LİSTELERİ — reçete, alerji, kullanılan ilaç.
///
/// KaynakKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1183 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// REÇETELER (413) — muayenede yazılan ilaçlar.
    ///
    /// Reçete bir BELGEDİR: imzalanınca değişmez, ilaç adı satıra kopyalanır
    /// (katalog güncellenince eski reçetenin metni değişmemeli).
    /// </summary>
    private static KaynakTanimi Recete() => new(
        Ad: "recete",
        YetkiKodu: "muayene",
        Kaynak: "public.recete r "
              + "  join public.taraf h on h.id = r.hasta_id "
              + "  left join public.v_personel_lookup p on p.id = r.hekim_id "
              + "  left join public.muayene m on m.id = r.muayene_id",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.ekleme_tarihi desc, r.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "r.id",         "sayi",  "Id", Varsayilan: false),
            new("receteNo",   "r.recete_no",  "metin", "Reçete No", Hizalama: "orta",
                                              Genislik: 130),
            new("tarih",      "r.ekleme_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("hastaAdi",   "h.unvan",      "metin", "Hasta", Genislik: 220),
            new("hekimAdi",   "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 180),
            new("turAdi",
                "case r.tur when 1 then 'Kırmızı' when 2 then 'Yeşil' when 3 then 'Mor' "
                + "when 4 then 'Turuncu' else 'Normal' end",
                                              "metin", "Reçete Türü", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 110,
                                              Filtrelenebilir: false),
            new("tur",        "r.tur",        "kod",   "Tür Kodu", Varsayilan: false),
            new("ilacSayisi",
                "(select count(*) from public.recete_satir s where s.recete_id = r.id)",
                                              "sayi",  "İlaç", Hizalama: "orta", Genislik: 70),
            new("durumAdi",
                "case r.durum when 2 then 'İmzalı' when 3 then 'Medula Kabul' "
                + "when 4 then 'İptal' else 'Taslak' end",
                                              "metin", "Durum", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 120,
                                              Filtrelenebilir: false),
            new("durum",      "r.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            new("muayeneId",  "r.muayene_id", "sayi",  "Muayene Id", Varsayilan: false),
            new("hastaId",    "r.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false),
            new("protokolNo",
                "coalesce((select b.belge_no from public.belge b where b.id = m.belge_id), '')",
                                              "metin", "Protokol", Hizalama: "orta",
                                              Genislik: 130, Varsayilan: false)
        });

    /// <summary>
    /// HASTA ALERJİLERİ (413) — etken madde bazlı.
    ///
    /// Marka adı üzerinden tutmak, aynı etkeni taşıyan başka markayı
    /// kaçırırdı: "Augmentin alerjisi" kaydı başka amoksisilini engellemez.
    /// </summary>
    private static KaynakTanimi HastaAlerji() => new(
        Ad: "hasta-alerji",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_alerji a join public.taraf h on h.id = a.hasta_id",
        VarsayilanSirala: "a.siddet desc, a.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "a.id",        "sayi",  "Id", Varsayilan: false),
            new("hastaAdi",  "h.unvan",     "metin", "Hasta", Genislik: 220),
            new("turAdi",
                "case a.tur when 2 then 'Gıda' when 3 then 'Çevresel' when 4 then 'Lateks' "
                + "when 5 then 'Kontrast' else 'İlaç' end",
                                           "metin", "Tür", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("tur",       "a.tur",      "kod",   "Tür Kodu", Varsayilan: false),
            new("etken",     "a.etken",    "metin", "Etken / Ürün", Genislik: 220),
            new("etkenMadde","a.etken_madde", "metin", "Etken Madde", Genislik: 200),
            new("reaksiyon", "a.reaksiyon","metin", "Reaksiyon", Genislik: 200),
            new("siddetAdi",
                "case a.siddet when 4 then 'Anafilaksi' when 3 then 'Şiddetli' "
                + "when 2 then 'Orta' else 'Hafif' end",
                                           "metin", "Şiddet", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("siddet",    "a.siddet",   "kod",   "Şiddet Kodu", Varsayilan: false),
            new("dogrulandi","a.dogrulandi","mantik","Doğrulandı", Hizalama: "orta",
                                           Genislik: 100),
            new("aktif",     "a.aktif",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("hastaId",   "a.hasta_id", "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>
    /// HASTANIN KULLANDIĞI İLAÇLAR (413) — kümülatif, reçeteden bağımsız.
    ///
    /// Reçete satırlarıyla aynı şey DEĞİL: hasta başka kurumdan aldığını da
    /// kullanır, bizim yazdığımızın bir kısmını kullanmaz. Etkileşim kontrolü
    /// KULLANILANA bakmalı, yazılana değil.
    /// </summary>
    private static KaynakTanimi HastaIlac() => new(
        Ad: "hasta-ilac",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_ilac i join public.taraf h on h.id = i.hasta_id",
        VarsayilanSirala: "i.aktif desc, i.baslangic desc nulls last, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "i.id",         "sayi",  "Id", Varsayilan: false),
            new("hastaAdi",   "h.unvan",      "metin", "Hasta", Genislik: 200),
            new("ilacAd",     "i.ilac_ad",    "metin", "İlaç", Genislik: 280),
            new("etkenMadde", "i.etken_madde","metin", "Etken Madde", Genislik: 200),
            new("barkod",     "i.ilac_barkod","metin", "Barkod", Hizalama: "orta",
                                              Genislik: 140, Varsayilan: false),
            new("doz",        "i.doz",        "metin", "Doz", Hizalama: "orta", Genislik: 90),
            new("periyot",    "i.periyot",    "metin", "Periyot", Hizalama: "orta",
                                              Genislik: 90),
            new("baslangic",  "i.baslangic",  "tarih", "Başlangıç", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy", Genislik: 110),
            new("bitis",      "i.bitis",      "tarih", "Bitiş", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy", Genislik: 110),
            new("kaynakAdi",
                "case i.kaynak when 2 then 'Hasta Beyanı' when 3 then 'e-Nabız' "
                + "when 4 then 'Dış Kurum' else 'Reçete' end",
                                              "metin", "Kaynak", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 120,
                                              Filtrelenebilir: false),
            new("uyumAdi",
                "case i.uyum when 2 then 'Aralıklı' when 3 then 'Bırakmış' else 'Düzenli' end",
                                              "metin", "Uyum", Hizalama: "orta",
                                              Genislik: 100, Varsayilan: false),
            new("aktif",      "i.aktif",      "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("hastaId",    "i.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>
    /// e-NABIZ GÖNDERİM KUYRUĞU (415) — üretilen paketler ve durumları.
    ///
    /// "Eksik alan" (durum 0) ayrı bir durumdur, hata değil: paket üretildi
    /// ama zorunlu alanı boş olduğu için kuyruğa GİRMEDİ. Eksiği gönderim
    /// anında bulmak, hatayı hekim ekrandan ayrıldıktan saatler sonra geri
    /// getirirdi - bu yüzden liste eksikleri ayrı çipte gösterir.
    /// </summary>
}
