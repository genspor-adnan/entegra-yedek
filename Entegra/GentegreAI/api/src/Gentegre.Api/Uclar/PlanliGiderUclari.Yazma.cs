using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using static Gentegre.Api.Servisler.PlanliGiderMotoru;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PLANLI GİDER YAZMA: POST (yeni), PUT (sürümlü güncelle - önce dondurur), DELETE (eşleşmiş dönem
/// varsa 422), kopyala. Gövde <c>{kart, artislar[]}</c>; kart alanları GET'teki adlarla.
///
/// <para><b>Alan kuralı</b> (§3.2 ile aynı ruh): bilinmeyen alan 400; GET'in salt okunur alanları
/// (id, taraf, masraf, subeId, ekleyen…) yok sayılır. PUT'ta gönderilmeyen alan değişmez, `null`
/// boşaltır. Artış listesi gönderilirse TAM listedir (id'li satır güncellenir, id'siz eklenir,
/// listede olmayan silinir); gönderilmezse dokunulmaz.</para>
///
/// <para><b>Log</b> (ULog kuralları): ekleme tek satır (bütün alanlar) + her artış kendi satırı
/// (üst = tanım); değişiklik alan bazlı, değişen yoksa satır yok; silme DELETE'ten önce satırın
/// tam hâli + `__detaylar` (artışlar, dönem satırları).</para>
/// </summary>
public static partial class PlanliGiderUclari
{
    /// <summary>Yazılabilir kart alanları (mutable; tanımdan ya da yeni kayıt varsayılanından başlar).</summary>
    private sealed class Kayit
    {
        public string Ad = "";
        public long? KategoriId;
        public int Durum = 1;
        public int? TarafId, MasrafId, MasrafMerkeziId, SorumluId;
        public string ReferansNo = "", Aciklama = "";
        public int TutarTur = 1, OrtalamaDonem = 3;
        public string HesapKaynak = "";
        public decimal Tutar;
        public string Doviz = "TL";
        public decimal KdvOran, StopajOran;
        public int Periyot = 2, OdemeGunu = 1, TatilKural = 2;
        public DateTime? Baslangic, Bitis;
        public int? DonemSayisi;
        public int HatirlatmaGun;
        public int? OdemeHesapId;
        public int OdemeYontem = 1;
        public string KarsiIban = "", OdemeAciklama = "";
        public int EslesGun = 7;
        public decimal EslesYuzde = 5;
        public int EslesOtomatik = 1;

        public static Kayit Tanimdan(Tanim t) => new()
        {
            Ad = t.Ad, KategoriId = t.KategoriId, Durum = t.Durum, TarafId = t.TarafId, MasrafId = t.MasrafId,
            MasrafMerkeziId = t.MasrafMerkeziId, SorumluId = t.SorumluId, ReferansNo = t.ReferansNo, Aciklama = t.Aciklama,
            TutarTur = t.TutarTur, OrtalamaDonem = t.OrtalamaDonem, HesapKaynak = t.HesapKaynak, Tutar = t.Tutar, Doviz = t.Doviz,
            KdvOran = t.KdvOran, StopajOran = t.StopajOran, Periyot = t.Periyot, OdemeGunu = t.OdemeGunu, TatilKural = t.TatilKural,
            Baslangic = t.Baslangic, Bitis = t.Bitis, DonemSayisi = t.DonemSayisi, HatirlatmaGun = t.HatirlatmaGun,
            OdemeHesapId = t.OdemeHesapId, OdemeYontem = t.OdemeYontem, KarsiIban = t.KarsiIban, OdemeAciklama = t.OdemeAciklama,
            EslesGun = t.EslesGun, EslesYuzde = t.EslesYuzde, EslesOtomatik = t.EslesOtomatik,
        };

        /// <summary>Log / fark sözlüğü - kültürden bağımsız değerler (LogDeposu.Metin).</summary>
        public Dictionary<string, object?> Sozluk() => new()
        {
            ["ad"] = Ad, ["kategoriId"] = KategoriId, ["durum"] = Durum, ["tarafId"] = TarafId, ["masrafId"] = MasrafId,
            ["masrafMerkeziId"] = MasrafMerkeziId, ["sorumluId"] = SorumluId, ["referansNo"] = ReferansNo, ["aciklama"] = Aciklama,
            ["tutarTur"] = TutarTur, ["ortalamaDonem"] = OrtalamaDonem, ["hesapKaynak"] = HesapKaynak, ["tutar"] = N(Tutar),
            ["doviz"] = Doviz, ["kdvOran"] = N(KdvOran), ["stopajOran"] = N(StopajOran), ["periyot"] = Periyot, ["odemeGunu"] = OdemeGunu,
            ["tatilKural"] = TatilKural, ["baslangic"] = T(Baslangic), ["bitis"] = T(Bitis), ["donemSayisi"] = DonemSayisi,
            ["hatirlatmaGun"] = HatirlatmaGun, ["odemeHesapId"] = OdemeHesapId, ["odemeYontem"] = OdemeYontem,
            ["karsiIban"] = KarsiIban, ["odemeAciklama"] = OdemeAciklama, ["eslesGun"] = EslesGun, ["eslesYuzde"] = N(EslesYuzde),
            ["eslesOtomatik"] = EslesOtomatik,
        };
    }

    /// <summary>Ölçeği atar (20.00 → 20): fark logu yalnız gerçek değişikliği görsün.</summary>
    private static decimal N(decimal d) => d / 1.000000000000000000000000000000000m;

    private static readonly HashSet<string> SaltOkunur = new(StringComparer.Ordinal)
        { "id", "taraf", "masraf", "masrafMerkezi", "sorumlu", "odemeHesap", "sube", "subeId", "ekleyen", "ekleyenAd", "eklemeTarihi", "degistirmeTarihi", "surum" };

    private sealed record ArtisGirdisi(long? Id, DateTime Gecerlilik, int Tur, decimal Deger, string Aciklama);

    // ----------------------------------------------------------- json okuma --
    private static bool Bos(JsonElement e) => e.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined
                                              || (e.ValueKind == JsonValueKind.String && e.GetString()!.Trim() == "");

    private static decimal? Ondalik(JsonElement e, string alan, List<AlanHatasi> h)
    {
        if (Bos(e)) return null;
        if (e.ValueKind == JsonValueKind.Number && e.TryGetDecimal(out var d)) return d;
        if (e.ValueKind == JsonValueKind.String && decimal.TryParse(e.GetString(), NumberStyles.Number, CultureInfo.InvariantCulture, out d)) return d;
        h.Add(new AlanHatasi(alan, "Sayı olmalı."));
        return null;
    }

    private static int? Tamsayi(JsonElement e, string alan, List<AlanHatasi> h)
    {
        if (e.ValueKind == JsonValueKind.True) return 1;
        if (e.ValueKind == JsonValueKind.False) return 0;
        var d = Ondalik(e, alan, h);
        if (d is null) return null;
        if (d != Math.Truncate(d.Value) || d > int.MaxValue || d < int.MinValue) { h.Add(new AlanHatasi(alan, "Tam sayı olmalı.")); return null; }
        return (int)d.Value;
    }

    private static string Metin(JsonElement e, string alan, List<AlanHatasi> h)
    {
        if (e.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined) return "";
        if (e.ValueKind == JsonValueKind.String) return e.GetString()!.Trim();
        h.Add(new AlanHatasi(alan, "Metin olmalı."));
        return "";
    }

    private static DateTime? Tarih(JsonElement e, string alan, List<AlanHatasi> h)
    {
        if (Bos(e)) return null;
        var s = e.ValueKind == JsonValueKind.String ? e.GetString()! : "";
        if (s.Length >= 10 && DateTime.TryParseExact(s[..10], "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var d))
            return d.Date;
        h.Add(new AlanHatasi(alan, "Tarih yyyy-AA-gg olmalı."));
        return null;
    }

    /// <summary>Kart alanlarını kayda uygular (yalnız gönderilenler). Bilinmeyen alan 400.</summary>
    private static void Uygula(Kayit k, JsonElement kart, List<AlanHatasi> h)
    {
        if (kart.ValueKind != JsonValueKind.Object) throw GentegreHatasi.Dogrulama("Gövdede 'kart' nesnesi olmalı.", new AlanHatasi("kart", "Zorunlu."));
        foreach (var o in kart.EnumerateObject())
        {
            var e = o.Value;
            switch (o.Name)
            {
                case "ad": k.Ad = Metin(e, o.Name, h); break;
                case "kategoriId": k.KategoriId = Tamsayi(e, o.Name, h); break;
                case "durum": k.Durum = Tamsayi(e, o.Name, h) ?? 1; break;
                case "tarafId": k.TarafId = Tamsayi(e, o.Name, h); break;
                case "masrafId": k.MasrafId = Tamsayi(e, o.Name, h); break;
                case "masrafMerkeziId": k.MasrafMerkeziId = Tamsayi(e, o.Name, h); break;
                case "sorumluId": k.SorumluId = Tamsayi(e, o.Name, h); break;
                case "referansNo": k.ReferansNo = Metin(e, o.Name, h); break;
                case "aciklama": k.Aciklama = Metin(e, o.Name, h); break;
                case "tutarTur": k.TutarTur = Tamsayi(e, o.Name, h) ?? 1; break;
                case "ortalamaDonem": k.OrtalamaDonem = Tamsayi(e, o.Name, h) ?? 3; break;
                case "hesapKaynak": k.HesapKaynak = Metin(e, o.Name, h); break;
                case "tutar": k.Tutar = Ondalik(e, o.Name, h) ?? 0; break;
                case "doviz": k.Doviz = Metin(e, o.Name, h).ToUpperInvariant(); break;
                case "kdvOran": k.KdvOran = Ondalik(e, o.Name, h) ?? 0; break;
                case "stopajOran": k.StopajOran = Ondalik(e, o.Name, h) ?? 0; break;
                case "periyot": k.Periyot = Tamsayi(e, o.Name, h) ?? 2; break;
                case "odemeGunu": k.OdemeGunu = Tamsayi(e, o.Name, h) ?? 1; break;
                case "tatilKural": k.TatilKural = Tamsayi(e, o.Name, h) ?? 2; break;
                case "baslangic": k.Baslangic = Tarih(e, o.Name, h); break;
                case "bitis": k.Bitis = Tarih(e, o.Name, h); break;
                case "donemSayisi": k.DonemSayisi = Tamsayi(e, o.Name, h); break;
                case "hatirlatmaGun": k.HatirlatmaGun = Tamsayi(e, o.Name, h) ?? 0; break;
                case "odemeHesapId": k.OdemeHesapId = Tamsayi(e, o.Name, h); break;
                case "odemeYontem": k.OdemeYontem = Tamsayi(e, o.Name, h) ?? 1; break;
                case "karsiIban": k.KarsiIban = Metin(e, o.Name, h).Replace(" ", "").ToUpperInvariant(); break;
                case "odemeAciklama": k.OdemeAciklama = Metin(e, o.Name, h); break;
                case "eslesGun": k.EslesGun = Tamsayi(e, o.Name, h) ?? 7; break;
                case "eslesYuzde": k.EslesYuzde = Ondalik(e, o.Name, h) ?? 5; break;
                case "eslesOtomatik": k.EslesOtomatik = Tamsayi(e, o.Name, h) ?? 1; break;
                default:
                    if (!SaltOkunur.Contains(o.Name)) h.Add(new AlanHatasi(o.Name, "Bilinmeyen alan."));
                    break;
            }
        }
    }

    private static List<ArtisGirdisi>? ArtislariOku(JsonElement govde, List<AlanHatasi> h)
    {
        if (!govde.TryGetProperty("artislar", out var dizi) || dizi.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined) return null;
        if (dizi.ValueKind != JsonValueKind.Array) { h.Add(new AlanHatasi("artislar", "Liste olmalı.")); return null; }
        var l = new List<ArtisGirdisi>();
        var i = 0;
        foreach (var a in dizi.EnumerateArray())
        {
            var on = $"artislar[{i++}]";
            if (a.ValueKind != JsonValueKind.Object) { h.Add(new AlanHatasi(on, "Nesne olmalı.")); continue; }
            JsonElement Al(string ad) => a.TryGetProperty(ad, out var v) ? v : default;
            long? id = Tamsayi(Al("id"), on + ".id", h) is { } n && n > 0 ? n : null;
            var gec = Tarih(Al("gecerlilik"), on + ".gecerlilik", h);
            var tur = Tamsayi(Al("tur"), on + ".tur", h) ?? 1;
            var deger = Ondalik(Al("deger"), on + ".deger", h);
            var acik = Metin(Al("aciklama"), on + ".aciklama", h);
            if (gec is null) h.Add(new AlanHatasi(on + ".gecerlilik", "Zorunlu."));
            if (tur is not (1 or 2)) h.Add(new AlanHatasi(on + ".tur", "1 oran ya da 2 yeni tutar."));
            if (deger is null) h.Add(new AlanHatasi(on + ".deger", "Zorunlu."));
            else if (tur == 2 && deger < 0) h.Add(new AlanHatasi(on + ".deger", "Yeni tutar eksi olamaz."));
            else if (tur == 1 && (deger <= -100 || deger > 1000)) h.Add(new AlanHatasi(on + ".deger", "Oran -100 ile 1000 arasında olmalı."));
            if (acik.Length > 200) h.Add(new AlanHatasi(on + ".aciklama", "En çok 200 karakter."));
            if (gec is not null && deger is not null) l.Add(new ArtisGirdisi(id, gec.Value, tur, Math.Round(deger.Value, 4), acik));
        }
        foreach (var g in l.GroupBy(x => x.Gecerlilik).Where(g => g.Count() > 1))
            h.Add(new AlanHatasi("artislar", $"Aynı geçerlilik tarihi ({g.Key:dd.MM.yyyy}) iki kez verilmiş."));
        return l;
    }

    /// <summary>İş kuralları + uzunluklar. Tedarikçi / kategori / hesap şubesi DB'den.</summary>
    private static async Task DogrulaAsync(NpgsqlConnection b, NpgsqlTransaction tx, Kayit k, int sube, List<AlanHatasi> h,
        CancellationToken iptal)
    {
        void Kontrol(bool kosul, string alan, string mesaj) { if (!kosul) h.Add(new AlanHatasi(alan, mesaj)); }
        Kontrol(k.Ad.Length > 0, "ad", "Zorunlu.");
        Kontrol(k.Ad.Length <= 150, "ad", "En çok 150 karakter.");
        Kontrol(k.ReferansNo.Length <= 60, "referansNo", "En çok 60 karakter.");
        Kontrol(k.Aciklama.Length <= 500, "aciklama", "En çok 500 karakter.");
        Kontrol(k.Durum is 0 or 1, "durum", "1 aktif ya da 0 pasif.");
        Kontrol(k.TutarTur is >= 1 and <= 5, "tutarTur", "1-5 arası.");
        Kontrol(k.OrtalamaDonem is >= 1 and <= 24, "ortalamaDonem", "1-24 arası.");
        Kontrol(k.HesapKaynak is "" or "kdv" or "sgk", "hesapKaynak", "'kdv' ya da 'sgk'.");
        Kontrol(k.TutarTur != 4 || k.HesapKaynak.Length > 0, "hesapKaynak", "Hesaplanan tutarda kaynak seçilmeli (KDV / SGK).");
        Kontrol(k.Tutar >= 0 && k.Tutar <= 9_999_999_999_999m, "tutar", "0 ya da büyük olmalı.");
        Kontrol(k.Doviz.Length is >= 2 and <= 6, "doviz", "Para birimi seçilmeli.");
        Kontrol(k.KdvOran is >= 0 and <= 100, "kdvOran", "0-100 arası.");
        Kontrol(k.StopajOran is >= 0 and <= 100, "stopajOran", "0-100 arası.");
        Kontrol(k.Periyot is >= 1 and <= 6, "periyot", "1-6 arası.");
        Kontrol(k.Periyot == 1 ? k.OdemeGunu is >= 1 and <= 7 : k.OdemeGunu is >= 1 and <= 31, "odemeGunu",
            k.Periyot == 1 ? "Haftalıkta 1 (Pzt) - 7 (Paz)." : "1-31 arası.");
        Kontrol(k.TatilKural is >= 0 and <= 2, "tatilKural", "0, 1 ya da 2.");
        Kontrol(k.Baslangic is not null, "baslangic", "Zorunlu.");
        Kontrol(k.Bitis is null || k.Baslangic is null || k.Bitis >= k.Baslangic, "bitis", "Başlangıçtan önce olamaz.");
        Kontrol(k.DonemSayisi is null || k.DonemSayisi is >= 1 and <= 999, "donemSayisi", "1-999 arası.");
        Kontrol(k.HatirlatmaGun is >= 0 and <= 60, "hatirlatmaGun", "0-60 arası.");
        Kontrol(k.OdemeYontem is >= 1 and <= 5, "odemeYontem", "1-5 arası.");
        Kontrol(k.KarsiIban.Length <= 34, "karsiIban", "En çok 34 karakter.");
        Kontrol(k.OdemeAciklama.Length <= 200, "odemeAciklama", "En çok 200 karakter.");
        Kontrol(k.EslesGun is >= 0 and <= 60, "eslesGun", "0-60 arası.");
        Kontrol(k.EslesYuzde is >= 0 and <= 100, "eslesYuzde", "0-100 arası.");
        Kontrol(k.EslesOtomatik is 0 or 1, "eslesOtomatik", "0 ya da 1.");

        var kategoriKod = "";
        if (k.KategoriId is { } kid)
        {
            kategoriKod = await b.TekDegerAsync<string>("select kod from public.planli_gider_kategori where id = @p0", tx, [kid], iptal) ?? "";
            Kontrol(kategoriKod.Length > 0, "kategoriId", "Kategori bulunamadı.");
        }
        // ÖDENECEK YER (karar 25.10.2026): yalnız tedarikçi; zorunlu, tek istisna Vergi / SGK.
        if (k.TarafId is { } tid)
        {
            var tedarikci = await b.TekDegerAsync<bool>(
                "select exists (select 1 from public.taraf where id = @p0 and tedarikci = 1)", tx, [tid], iptal);
            Kontrol(tedarikci, "tarafId", "Ödenecek yer tedarikçi listesinden seçilmeli.");
        }
        else if (kategoriKod != "vergi_sgk")
            h.Add(new AlanHatasi("tarafId", "Ödenecek yer tedarikçi listesinden seçilmeli."));
        if (k.OdemeHesapId is { } hid)
        {
            var uygun = await b.TekDegerAsync<bool>("""
                select exists (select 1 from public.hesap where id = @p0 and tur in ('K', 'B', 'V', 'P')
                                 and (sube_id is null or sube_id = 0 or sube_id = @p1))
                """, tx, [hid, sube], iptal);
            Kontrol(uygun, "odemeHesapId", "Bu şubenin kasa / banka / kredi kartı hesabı seçilmeli.");
        }
        if (h.Count > 0) throw GentegreHatasi.Dogrulama("Planlı gider kaydedilemedi: alanları kontrol edin.", [.. h]);
    }

    private static object?[] Parametreler(Kayit k) =>
    [
        k.Ad, k.KategoriId, (short)k.Durum, k.TarafId, k.MasrafId, k.MasrafMerkeziId, k.SorumluId, k.ReferansNo, k.Aciklama,
        (short)k.TutarTur, (short)k.OrtalamaDonem, k.HesapKaynak, R(k.Tutar), k.Doviz, k.KdvOran, k.StopajOran, (short)k.Periyot,
        (short)k.OdemeGunu, (short)k.TatilKural, k.Baslangic, k.Bitis, k.DonemSayisi is { } ds ? (short)ds : null,
        (short)k.HatirlatmaGun, k.OdemeHesapId, (short)k.OdemeYontem, k.KarsiIban, k.OdemeAciklama, (short)k.EslesGun,
        k.EslesYuzde, (short)k.EslesOtomatik,
    ];

    private const string Kolonlar = """
        ad, kategori_id, durum, taraf_id, masraf_id, masraf_merkezi_id, sorumlu_id, referans_no, aciklama, tutar_tur,
        ortalama_donem, hesap_kaynak, tutar, doviz, kdv_oran, stopaj_oran, periyot, odeme_gunu, tatil_kural, baslangic, bitis,
        donem_sayisi, hatirlatma_gun, odeme_hesap_id, odeme_yontem, karsi_iban, odeme_aciklama, esles_gun, esles_yuzde,
        esles_otomatik
        """;

    private static async Task<int> EkleAsync(NpgsqlConnection b, NpgsqlTransaction tx, LogDeposu log, IstekBaglami baglam,
        Kayit k, List<ArtisGirdisi> artislar, string kaynak, CancellationToken iptal)
    {
        var sube = AktifSube(baglam);
        var par = Parametreler(k).ToList();
        par.Add(sube); par.Add(baglam.KullaniciId);
        var yer = string.Join(", ", Enumerable.Range(0, 30).Select(i => "@p" + i + (i is 19 or 20 ? "::date" : "")));
        var id = await b.TekDegerAsync<int>($"insert into public.planli_gider ({Kolonlar}, sube_id, ekleyen) values ({yer}, @p30, @p31) returning id",
            tx, [.. par], iptal);
        var bilgi = k.Sozluk().ToDictionary(x => x.Key, x => LogDeposu.Metin(x.Value));
        bilgi["kaynak"] = kaynak;
        await log.YazAsync(b, tx, LogIslemi.Ekle, LogTanim, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi,
            tarafId: k.TarafId, iptal: iptal);
        foreach (var a in artislar)
            await ArtisEkleAsync(b, tx, log, baglam, id, a, iptal);
        return id;
    }

    private static async Task ArtisEkleAsync(NpgsqlConnection b, NpgsqlTransaction tx, LogDeposu log, IstekBaglami baglam, int id,
        ArtisGirdisi a, CancellationToken iptal)
    {
        var aid = await b.TekDegerAsync<long>("""
            insert into public.planli_gider_artis (planli_gider_id, gecerlilik, tur, deger, aciklama, ekleyen)
            values (@p0, @p1::date, @p2, @p3, @p4, @p5) returning id
            """, tx, [id, a.Gecerlilik, (short)a.Tur, a.Deger, a.Aciklama, baglam.KullaniciId], iptal);
        await log.YazAsync(b, tx, LogIslemi.Ekle, LogArtis, aid, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            ArtisSozluk(a.Gecerlilik, a.Tur, a.Deger, a.Aciklama).ToDictionary(x => x.Key, x => LogDeposu.Metin(x.Value)),
            LogTanim, id, iptal: iptal);
    }

    private static Dictionary<string, object?> ArtisSozluk(DateTime gecerlilik, int tur, decimal deger, string aciklama) => new()
    {
        ["gecerlilik"] = T(gecerlilik), ["tur"] = tur, ["deger"] = N(deger), ["aciklama"] = aciklama,
    };

    private static void YazmaYetkisi(IstekBaglami baglam, Islem islem)
    {
        baglam.YetkiIste(Kod, islem);
        if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu ekran portalda kullanılamaz.");
    }

    private static void YazmaUclariniEkle(RouteGroupBuilder grup)
    {
        // =============================================================== POST ===
        grup.MapPost("/", async (JsonElement govde, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log, HttpContext ctx,
                                 CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Ekle);
            var sube = AktifSube(baglam);
            var hatalar = new List<AlanHatasi>();
            var k = new Kayit { SorumluId = baglam.KullaniciId, Baslangic = Saat.BugunDilim(baglam.ZamanDilimi) };
            if (govde.ValueKind != JsonValueKind.Object || !govde.TryGetProperty("kart", out var kart))
                throw GentegreHatasi.Dogrulama("Gövdede 'kart' nesnesi olmalı.", new AlanHatasi("kart", "Zorunlu."));
            Uygula(k, kart, hatalar);
            var artislar = ArtislariOku(govde, hatalar) ?? [];

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            await DogrulaAsync(b, tx, k, sube, hatalar, iptal);
            var id = await EkleAsync(b, tx, log, baglam, k, artislar.Select(a => a with { Id = null }).ToList(), "planli-gider", iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        // ================================================================ PUT ===
        grup.MapPut("/{id:int}", async (int id, JsonElement govde, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var sube = AktifSube(baglam);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            if (govde.ValueKind != JsonValueKind.Object || !govde.TryGetProperty("kart", out var kart) || kart.ValueKind != JsonValueKind.Object)
                throw GentegreHatasi.Dogrulama("Gövdede 'kart' nesnesi olmalı.", new AlanHatasi("kart", "Zorunlu."));
            var surum = kart.TryGetProperty("surum", out var sv) && sv.ValueKind == JsonValueKind.String ? sv.GetString()!.Trim() : "";
            if (surum.Length == 0) throw GentegreHatasi.Dogrulama("Sürüm (surum) zorunlu.", new AlanHatasi("surum", "Zorunlu."));

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            if (t.Surum != surum)
            {
                var guncel = await KartYanitiAsync(b, tx, baglam, id, iptal);
                throw GentegreHatasi.Cakisma(guncel);
            }

            var hatalar = new List<AlanHatasi>();
            var k = Kayit.Tanimdan(t);
            var eskiSozluk = k.Sozluk();
            Uygula(k, kart, hatalar);
            var artislar = ArtislariOku(govde, hatalar);
            var eskiArtis = p.Artislar[t.Id].ToList();
            if (artislar is not null)
                foreach (var a in artislar.Where(a => a.Id is not null && eskiArtis.All(x => x.Id != a.Id)))
                    hatalar.Add(new AlanHatasi("artislar", $"Artış #{a.Id} bu tanımın değil."));
            await DogrulaAsync(b, tx, k, sube, hatalar, iptal);

            // DONDURMA ÖNCE (karar): geçmiş / eşleşmiş dönemler ESKİ tanımın planıyla saklanır.
            await DondurAsync(b, tx, p, t, baglam.KullaniciId, iptal);

            var fark = LogDeposu.Fark(eskiSozluk, k.Sozluk());
            var artisDegisti = false;
            if (artislar is not null)
            {
                // Silinenler: log DELETE'ten önce, tam satır.
                foreach (var e in eskiArtis.Where(e => artislar.All(a => a.Id != e.Id)))
                {
                    await log.YazAsync(b, tx, LogIslemi.Sil, LogArtis, e.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                        ArtisSozluk(e.Gecerlilik, e.Tur, e.Deger, e.Aciklama).ToDictionary(x => x.Key, x => LogDeposu.Metin(x.Value)),
                        LogTanim, id, iptal: iptal);
                    await b.CalistirAsync("delete from public.planli_gider_artis where id = @p0", tx, [e.Id], iptal);
                    artisDegisti = true;
                }
                foreach (var a in artislar.Where(a => a.Id is not null))
                {
                    var e = eskiArtis.First(x => x.Id == a.Id);
                    var af = LogDeposu.Fark(ArtisSozluk(e.Gecerlilik, e.Tur, e.Deger, e.Aciklama), ArtisSozluk(a.Gecerlilik, a.Tur, a.Deger, a.Aciklama));
                    if (af is null) continue;
                    await b.CalistirAsync("""
                        update public.planli_gider_artis set gecerlilik = @p1::date, tur = @p2, deger = @p3, aciklama = @p4 where id = @p0
                        """, tx, [e.Id, a.Gecerlilik, (short)a.Tur, a.Deger, a.Aciklama], iptal);
                    await log.YazAsync(b, tx, LogIslemi.Degistir, LogArtis, e.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, af,
                        LogTanim, id, iptal: iptal);
                    artisDegisti = true;
                }
                foreach (var a in artislar.Where(a => a.Id is null))
                {
                    await ArtisEkleAsync(b, tx, log, baglam, id, a, iptal);
                    artisDegisti = true;
                }
            }

            if (fark is not null || artisDegisti)
            {
                var par = Parametreler(k).ToList();
                par.Add(baglam.KullaniciId); par.Add(id);
                var atama = string.Join(", ", Kolonlar.Split(',', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries)
                    .Select((c, i) => $"{c} = @p{i}" + (i is 19 or 20 ? "::date" : "")));
                await b.CalistirAsync($"update public.planli_gider set {atama}, degistiren = @p30, degistirme_tarihi = now() where id = @p31",
                    tx, [.. par], iptal);
            }
            if (fark is not null)
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTanim, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                    tarafId: k.TarafId, iptal: iptal);

            var yeniSurum = await b.TekDegerAsync<string>("select xmin::text from public.planli_gider where id = @p0", tx, [id], iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, surum = yeniSurum });
        });

        // ============================================================= DELETE ===
        grup.MapDelete("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log, HttpContext ctx,
                                           CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Sil);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            var satirlar = p.Satirlar[t.Id].ToList();
            var eslesmis = satirlar.Count(s => s.Durum is 3 or 4);
            if (eslesmis > 0)
                throw GentegreHatasi.IsKurali($"Bu tanımın {eslesmis} dönemi ödeme / faturayla eşleşmiş; silmek yerine pasife alın.",
                    new { tablo = "planli_gider_donem", adet = eslesmis });

            var tam = Kayit.Tanimdan(t).Sozluk().ToDictionary(x => x.Key, x => (object?)LogDeposu.Metin(x.Value));
            tam["id"] = t.Id.ToString(CultureInfo.InvariantCulture);
            tam["subeId"] = t.SubeId.ToString(CultureInfo.InvariantCulture);
            tam["__detaylar"] = new
            {
                artislar = p.Artislar[t.Id].Select(a => new { a.Id, gecerlilik = T(a.Gecerlilik), a.Tur, deger = LogDeposu.Metin(a.Deger), a.Aciklama }),
                donemler = satirlar.Select(s => new
                {
                    s.Id, vade = T(s.Vade), planTarihi = T(s.PlanTarihi), planTutar = LogDeposu.Metin(s.PlanTutar), s.Durum,
                    elleTutar = LogDeposu.Metin(s.ElleTutar), s.Aciklama,
                }),
            };
            await log.YazAsync(b, tx, LogIslemi.Sil, LogTanim, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, tam,
                tarafId: t.TarafId, iptal: iptal);
            await b.CalistirAsync("delete from public.planli_gider where id = @p0", tx, [id], iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, silindi = true });
        });

        // ============================================================ KOPYALA ===
        // YENİLEME = KOPYALA (karar): yeni dönem bitişten (yoksa bugünden) başlar, süre korunur; tutar
        //   bugüne kadarki artışlarla güncel tutardır; ileri tarihli artışlar taşınır.
        grup.MapPost("/{id:int}/kopyala", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log, HttpContext ctx,
                                                 CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Ekle);
            var sube = AktifSube(baglam);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal);
            var k = Kayit.Tanimdan(t);
            var yeniBas = t.Bitis is { } bt && bt.Date >= bugun ? bt.Date.AddDays(1) : bugun;
            k.Ad = (t.Ad.Length > 140 ? t.Ad[..140] : t.Ad) + " (kopya)";
            k.Durum = 1;
            k.Baslangic = yeniBas;
            k.Bitis = t.Bitis is { } b0 ? yeniBas.AddDays((b0.Date - t.Baslangic.Date).Days) : null;
            k.Tutar = PlanliGiderHesap.ArtisliTutar(t.Tutar, p.Artislar[t.Id].Select(a => a.Cekirdek), yeniBas);
            k.SorumluId = t.SorumluId ?? baglam.KullaniciId;
            var artislar = p.Artislar[t.Id].Where(a => a.Gecerlilik.Date > yeniBas)
                .Select(a => new ArtisGirdisi(null, a.Gecerlilik, a.Tur, a.Deger, a.Aciklama)).ToList();
            if (k.OdemeHesapId is not null && t.SubeId != sube) k.OdemeHesapId = null;
            await DogrulaAsync(b, tx, k, sube, [], iptal);
            var yeni = await EkleAsync(b, tx, log, baglam, k, artislar, "kopya #" + id, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id = yeni });
        });
    }
}
