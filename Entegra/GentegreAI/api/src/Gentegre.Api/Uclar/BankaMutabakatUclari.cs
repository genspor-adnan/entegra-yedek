using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BANKA MUTABAKAT İCMALİ `/api/banka-mutabakat` (1178, mockup Ekranlar/İcmal/banka_mutabakat_icmali.html,
/// kararlar 25.10.2026). "Bankadaki para ile sistemdeki para tutuyor mu; tutmuyorsa farkın her kuruşu neden?"
///
/// <para><b>Banka bakiyesi (gün sonu):</b> API'li hesapta (hesap.banka_kaynak 1) o günün sonuna kadarki SON
/// banka hareketinin işlem sonrası bakiyesi (banka_hareket.bakiye); hareket bakiyesi yoksa ve günden sonra
/// hareket gelmemişse son çekimin bakiyesi (hesap.banka_bakiye). Son çekim gün bitmeden yapıldıysa bakiye
/// "eksik" sayılır, onay verilmez. API'siz hesapta o gün için elle girilen gün sonu bakiyesi
/// (hesap_gun_bakiye; kredi kartında ekstre bakiyesi - kaynak 2); yoksa dosyadan gelen hareketin bakiyesi;
/// o da yoksa "bakiye girilmedi" (karar B3).</para>
/// <para><b>Sistem bakiyesi:</b> hesap ekstresi / v_hesap_bakiye ile AYNI küme (v_mali_hareket_ek, hesap_ekstre 1,
/// kesin işlem islem_durum 2), mutabakat gününün sonuna kadar. Tarih esası İŞLEM TARİHİ (karar B2) - gün
/// sınırı oturumun (şube) saat diliminde.</para>
/// <para><b>Açıklama listeleri</b> (klasik banka mutabakatı): İŞLENMEMİŞ = günün sonuna kadarki banka
/// hareketlerinden sistemde karşılığı olmayanlar (bekliyor / öneri hazır / seçim bekliyor / yoksayılan; işlenmiş
/// ama bağlı kasa işlemi günden sonra tarihli olan da). YOLDA = hesabın banka hareketi akışı başladıktan sonraki,
/// eşleşen banka hareketi (o güne kadar) olmayan kesin kasa işlemi bacakları - akışı olmayan hesapta liste boştur.
/// Düzeltilmiş banka = banka + yolda; düzeltilmiş sistem = sistem + işlenmemiş; açıklanmayan = fark. Yolda
/// eşiği 3 iş günü (çekte vade + 1 gün) - aşan kırmızı. Valörü günden sonraki hareket "valör bekleyen" bilgi
/// satırıdır, fark sayılmaz.</para>
/// <para><b>Onay</b> (banka_mutabakat, gün + hesap): aksiyon `banka.mutabakat_onay`, yalnız açıklanmayan 0 iken;
/// o günün bakiyeleri ve listeleri `detay`ta dondurulur. Genel Ayarlar `banka.mutabakat_dort_goz` = 1 ise onaylayan
/// HAZIRLAYANDAN farklı olmalı - hazırlayan: API'siz hesapta o günün bakiyesini son giren, API'li hesapta o güne
/// kadarki banka hareketlerini en son işleyen / eşleştiren (hiçbiri yoksa kısıt yok).
/// BOZULDU (karar B4): onaylı günün ŞİMDİKİ sistem ya da banka bakiyesi dondurulandan farklıysa okumada
/// "bozuldu" raporlanır (GET hiçbir şey yazmaz); satırın durum 2 / bozulma_* alanları yazan uçlarda işlenir -
/// onay (hesabın son 400 günü, yeniden onaydan önce) ve elle bakiye (o gün).</para>
/// <para><b>Eşleştir:</b> banka hareketini VAR OLAN kesin kasa işlemine bağlar (BankaHareketServisi.EslestirAsync);
/// tolerans Genel Ayarlar `banka.mutabakat_tolerans_kurus` (boş = 0). Seçilenleri İşle istemcide Banka
/// Hareketleri'nin kendi uçlarıyla (/api/banka-hareket/isle-toplu).</para>
/// Yetki: ekran `finans.banka_mutabakat` (Gör); elle bakiye ve eşleştirme `banka.hareket` Değiştir; şube yazma
/// hakkı. Hesaplar kullanıcının şubelerinden (şubesiz hesap herkese). Rakamlar sunucuda; ekran toplamaz.
/// </summary>
public static class BankaMutabakatUclari
{
    private const string Kod = "finans.banka_mutabakat";
    private const string KodOnay = "banka.mutabakat_onay";
    private const string KodHareket = "banka.hareket";
    /// <summary>islem_log.tablo_id (1178) - LogTabloIdTestleri deseniyle boş blok.</summary>
    private const int LogTabloGunBakiye = 1741;
    private const int LogTabloMutabakat = 1742;
    private const int LogTabloBankaHareket = 1743;
    private const int YoldaEsikIsGunu = 3;
    private const int ListeSiniri = 500;
    private const int GecmisGun = 60;

    public sealed record BakiyeIstegi(int HesapId, DateTime? Gun, decimal? Bakiye, short? Kaynak, string? Aciklama, string? Surum);
    public sealed record OnayIstegi(DateTime? Gun, int[]? HesapIdler);
    public sealed record EslesIstegi(long HareketId, int KasaIslemId);

    // ================================================================ kayıtlar ===

    private sealed record HesapK(int Id, string Tur, string Kod, string Ad, string Doviz, string Iban, short BankaKaynak,
                                 DateTime? BeslemeBas, DateTime? SonCekim);

    private sealed record GunB(int HesapId, DateOnly Gun, decimal? Besleme, DateTime? BeslemeZaman, bool Sonra, bool CekimKapsar,
        decimal? ApiBakiye, bool ApiKapsar, DateTime? ApiZaman, long? ElleId, decimal? Elle, short ElleKaynak, string ElleAciklama,
        int ElleGiren, string ElleGirenAd, DateTime? ElleZaman, string ElleSurum, decimal Sistem, int ApiHazirlayan,
        string ApiHazirlayanAd, decimal ValorBekleyen, decimal? Kur);

    /// <summary>Çözülmüş banka bakiyesi. Kaynak: api · dosya · elle · ekstre · yok.</summary>
    private sealed record BankaDegeri(decimal? Tutar, string Kaynak, DateTime? Zaman, string Not, bool Eksik,
                                      int Hazirlayan, string HazirlayanAd);

    private sealed record Islenmemis(long Id, int HesapId, string HesapAd, DateTime Tarih, DateTime Gun, DateTime? Valor,
        string Aciklama, string KarsiAd, string KarsiIban, decimal Tutar, short Durum, string OneriTur, string OneriHedef,
        int Guven, string OneriNeden, int? KasaIslemId);

    private sealed record Yolda(int? KasaIslemId, string IslemNo, DateTime Tarih, DateTime Gun, int HesapId, string HesapAd,
        string TurAdi, string Karsi, string Aciklama, decimal Tutar, bool Cek, DateTime? Vade, int IsGunu, bool Gecikti, string DurumMetni);

    private sealed record OnayK(long Id, int HesapId, DateOnly Gun, decimal Banka, decimal Sistem, decimal Aciklanmayan, short Durum,
        int Hazirlayan, int Onaylayan, string OnaylayanAd, DateTime OnayAn, DateTime? BozulmaAn, string BozulmaNeden);

    private sealed class Sonuc
    {
        public required HesapK H { get; init; }
        public required GunB G { get; init; }
        public required BankaDegeri B { get; init; }
        public required List<Islenmemis> Isl { get; init; }
        public required List<Yolda> Yol { get; init; }
        public OnayK? Onay { get; init; }
        /// <summary>Onaylı gün şimdi tutmuyorsa neden; tutuyorsa boş.</summary>
        public string Bozulma { get; init; } = "";
        public decimal Sistem => G.Sistem;
        public decimal YoldaToplam => R(Yol.Sum(y => y.Tutar));
        public decimal IslToplam => R(Isl.Sum(x => x.Tutar));
        public decimal? Fark => B.Tutar is { } t ? R(t - Sistem) : null;
        public decimal? DuzBanka => B.Tutar is { } t ? R(t + YoldaToplam) : null;
        public decimal DuzSistem => R(Sistem + IslToplam);
        public decimal? Aciklanmayan => DuzBanka is { } d ? R(d - DuzSistem) : null;
        public bool Onayli => Onay is { Durum: 1 } && Bozulma == "";
        public bool Bozuk => Onay is not null && !Onayli;

        public string Durum => B.Tutar is null ? "bakiye_yok"
            : Onayli ? "onayli" : Bozuk ? "bozuldu"
            : Math.Abs(Fark ?? 0) < 0.005m ? "tutuyor"
            : Math.Abs(Aciklanmayan ?? 0) < 0.005m ? "aciklandi" : "fark";

        public string Engel(bool dortGoz, int kullanici)
        {
            if (B.Tutar is null)
                return H.BankaKaynak == 1 ? "Bu gün için banka bakiyesi yok - bankadan çekin." : "Bu gün için banka bakiyesi girilmedi.";
            if (B.Eksik) return "Son çekim gün sonundan önce yapılmış - önce bankadan çekin.";
            if (Math.Abs(Aciklanmayan ?? 0) >= 0.005m)
                return $"Açıklanmayan fark var ({(Aciklanmayan ?? 0).ToString("N2", Tr)}).";
            if (Onayli) return "Bu gün zaten onaylı.";
            if (dortGoz && B.Hazirlayan > 0 && B.Hazirlayan == kullanici)
                return "Dört göz: bu günün hazırlayanı sizsiniz - başka bir yetkili onaylamalı.";
            return "";
        }
    }

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");
    private static readonly JsonSerializerOptions DetayJson = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal? Tl(decimal? tutar, decimal? kur) => tutar is { } t && kur is { } k ? R(t * k) : null;

    // ================================================================== uçlar ===

    public static void BankaMutabakatUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/banka-mutabakat").WithTags("Banka Mutabakat İcmali").RequireAuthorization();

        // --------------------------------------------------------------- icmal ---
        grup.MapGet("/", async (string? gun, int? hesap, int? sube, int? kart, VeriKaynagi veri, BaglamCozucu cozucu,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = DateOnly.FromDateTime(Saat.BugunDilim(baglam.ZamanDilimi));
            var g = GunCoz(gun, bugun);
            var kartDahil = (kart ?? 1) == 1;

            await using var b = await veri.AcAsync(iptal);
            var yerel = await YerelAsync(b, iptal);
            var tumu = await HesaplariOkuAsync(b, null, baglam, kartDahil, sube ?? 0, iptal);
            var hesaplar = hesap is > 0 ? tumu.Where(x => x.Id == hesap).ToList() : tumu;
            var dortGoz = await AyarDeposu.SayiAsync(b, null, "banka.mutabakat_dort_goz", iptal) == 1;
            var tolerans = await ToleransAsync(b, iptal);
            var sonuclar = await HesaplaAsync(b, null, hesaplar, g, yerel, iptal);

            // ------------------------------------------------------- geçmiş --
            var gecmisRows = await OnaylarAsync(b, null, hesaplar.Select(x => x.Id).ToArray(), null, GecmisGun, iptal);
            var gecmisB = await GunlerAsync(b, null, gecmisRows.Select(r => (r.HesapId, r.Gun)).ToList(), yerel, iptal);
            var hMap = hesaplar.ToDictionary(x => x.Id);
            var gecmis = gecmisRows.GroupBy(r => r.Gun).OrderByDescending(x => x.Key).Select(grp =>
            {
                var satirlar = grp.Select(r =>
                {
                    var gb = gecmisB.GetValueOrDefault((r.HesapId, r.Gun));
                    var neden = r.Durum == 1 && gb is not null ? BozulmaNedeni(r, gb, BankaCoz(hMap[r.HesapId], gb)) : "";
                    var bozuk = r.Durum == 2 || neden != "";
                    return new
                    {
                        hesapId = r.HesapId, hesapAd = hMap[r.HesapId].Ad, banka = r.Banka, sistem = r.Sistem,
                        aciklanmayan = r.Aciklanmayan, durum = bozuk ? "bozuldu" : "onayli",
                        bozulmaNeden = bozuk ? (neden != "" ? neden : r.BozulmaNeden) : null,
                        onaylayan = r.OnaylayanAd, onayAn = r.OnayAn,
                        bankaTl = Tl(r.Banka, gb?.Kur), sistemTl = Tl(r.Sistem, gb?.Kur), bozuk,
                    };
                }).ToList();
                var son = grp.OrderByDescending(r => r.OnayAn).First();
                return new
                {
                    gun = grp.Key, aySonu = grp.Key.AddDays(1).Day == 1,
                    onayli = satirlar.Count(s => !s.bozuk), bozuldu = satirlar.Count(s => s.bozuk), toplamHesap = hesaplar.Count,
                    banka = R(satirlar.Sum(s => s.bankaTl ?? 0)), sistem = R(satirlar.Sum(s => s.sistemTl ?? 0)),
                    aciklanmayan = R(satirlar.Sum(s => s.aciklanmayan)),
                    onaylayan = son.OnaylayanAd, onayAn = son.OnayAn,
                    satirlar = satirlar.Select(s => new { s.hesapId, s.hesapAd, s.banka, s.sistem, s.aciklanmayan, s.durum, s.bozulmaNeden, s.onaylayan, s.onayAn }),
                };
            }).ToList();
            var sonOnay = gecmis.FirstOrDefault(x => x.onayli > 0);

            // ------------------------------------------------------- yetkiler --
            var y = baglam.Yetkiler;
            var yaz = baglam.SubeYazma;
            var yetkiler = new
            {
                onay = y.AksiyonVar(KodOnay) && yaz,
                bakiyeGir = y.Var(KodHareket, Islem.Degistir) && yaz,
                esles = y.Var(KodHareket, Islem.Degistir) && yaz,
                isle = y.Var(KodHareket, Islem.Degistir) && y.Var("kasa_islem", Islem.Ekle) && yaz,
                cek = y.Var(KodHareket, Islem.Ekle) && yaz,
                hareketGor = y.Var(KodHareket, Islem.Gor),
            };

            // -------------------------------------------------------- satırlar --
            var satir = sonuclar.Select(s => HesapSatiri(s, dortGoz, baglam.KullaniciId)).ToList();
            var islAll = sonuclar.SelectMany(s => s.Isl).OrderByDescending(x => x.Tarih).ThenByDescending(x => x.Id).ToList();
            var yolAll = sonuclar.SelectMany(s => s.Yol).OrderByDescending(x => x.Gecikti).ThenBy(x => x.Tarih).ToList();
            decimal Top(Func<Sonuc, decimal?> f) => R(sonuclar.Sum(s => Tl(f(s), s.G.Kur) ?? 0));
            var farkTl = Top(s => s.Fark);
            var aciklanmayanTl = Top(s => s.Aciklanmayan);

            return Results.Ok(new
            {
                gun = g, bugun, dun = bugun.AddDays(-1), aySonu = new DateOnly(bugun.Year, bugun.Month, 1).AddDays(-1),
                yerel, kart = kartDahil, hesap = hesap ?? 0, sube = sube ?? 0,
                ayar = new { tolerans, dortGoz, yoldaEsik = YoldaEsikIsGunu },
                yetkiler,
                secim = new
                {
                    hesaplar = tumu.Select(x => new { x.Id, x.Ad, x.Tur, api = x.BankaKaynak == 1 }),
                    subeler = baglam.Subeler.Select(s => new { s.Id, s.Ad }),
                },
                ozet = new
                {
                    hesap = sonuclar.Count,
                    bankaBakiye = Top(s => s.B.Tutar), sistemBakiye = Top(s => s.Sistem), fark = farkTl,
                    farkHesap = sonuclar.Count(s => Math.Abs(s.Fark ?? 0) >= 0.005m),
                    islenmemisAdet = islAll.Count, islenmemisTutar = Top(s => s.IslToplam),
                    oneriHazir = islAll.Count(x => x.Durum == 1),
                    yoldaAdet = yolAll.Count, yoldaTutar = Top(s => s.YoldaToplam), yoldaGeciken = yolAll.Count(x => x.Gecikti),
                    aciklanan = R(farkTl - aciklanmayanTl), aciklanmayan = aciklanmayanTl,
                    aciklananYuzde = farkTl != 0 ? Math.Round((farkTl - aciklanmayanTl) / farkTl * 100m, 0) : (decimal?)null,
                    valorBekleyen = Top(s => s.G.ValorBekleyen),
                    api = sonuclar.Count(s => s.H.BankaKaynak == 1), elle = sonuclar.Count(s => s.H.BankaKaynak != 1),
                    bakiyesiz = sonuclar.Count(s => s.B.Tutar is null),
                    onayli = sonuclar.Count(s => s.Onayli), bozuldu = sonuclar.Count(s => s.Bozuk),
                    onaylanabilir = sonuclar.Count(s => s.Engel(dortGoz, baglam.KullaniciId) == ""),
                    sonCekim = sonuclar.Select(s => s.H.SonCekim).Where(x => x is not null).Max(),
                    kurYok = sonuclar.Where(s => s.G.Kur is null).Select(s => s.H.Doviz).Distinct().ToList(),
                    sonOnay = sonOnay is null ? null : new { sonOnay.gun, sonOnay.onaylayan, sonOnay.onayli, sonOnay.toplamHesap },
                },
                hesaplar = satir,
                islenmemis = islAll.Take(ListeSiniri).Select(x => IslenmemisSatiri(x, g)),
                yolda = yolAll.Take(ListeSiniri).Select(YoldaSatiri),
                gecmis,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // -------------------------------------------------------- günlük bakiye ---
        grup.MapGet("/gunluk", async (int hesapId, string? gun, int? n, VeriKaynagi veri, BaglamCozucu cozucu,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = DateOnly.FromDateTime(Saat.BugunDilim(baglam.ZamanDilimi));
            var g = GunCoz(gun, bugun);
            var adet = n is >= 7 and <= 31 ? n.Value : 10;
            await using var b = await veri.AcAsync(iptal);
            var yerel = await YerelAsync(b, iptal);
            var h = (await HesaplariOkuAsync(b, null, baglam, true, 0, iptal)).FirstOrDefault(x => x.Id == hesapId)
                    ?? throw GentegreHatasi.Bulunamadi("Hesap bulunamadı.");
            var gunler = Enumerable.Range(0, adet).Select(i => g.AddDays(i - adet + 1)).ToList();
            var gb = await GunlerAsync(b, null, gunler.Select(d => (h.Id, d)).ToList(), yerel, iptal);
            var onaylar = (await OnaylarAsync(b, null, [h.Id], gunler.ToArray(), 0, iptal)).ToDictionary(o => o.Gun);
            var satirlar = gunler.Select(d =>
            {
                var x = gb[(h.Id, d)];
                var bd = BankaCoz(h, x);
                var o = onaylar.GetValueOrDefault(d);
                var neden = o is { Durum: 1 } ? BozulmaNedeni(o, x, bd) : "";
                return new
                {
                    gun = d, banka = bd.Tutar, kaynak = bd.Kaynak, eksik = bd.Eksik, sistem = x.Sistem,
                    fark = bd.Tutar is { } t ? R(t - x.Sistem) : (decimal?)null,
                    onay = o is null ? null : new
                    {
                        durum = o.Durum == 2 || neden != "" ? "bozuldu" : "onayli", onaylayan = o.OnaylayanAd, onayAn = o.OnayAn,
                        bozulmaNeden = neden != "" ? neden : o.BozulmaNeden,
                    },
                };
            }).ToList();
            return Results.Ok(new { hesap = new { h.Id, h.Ad, h.Doviz, kaynak = h.BankaKaynak }, gun = g, satirlar });
        });

        // --------------------------------------------------- eşleştirme adayları ---
        grup.MapGet("/esles-aday", async (long hareketId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var bh = await b.TekAsync("""
                select h.id, h.hesap_id, h.islem_tarihi, h.tutar, h.aciklama, h.karsi_ad, h.durum
                  from public.banka_hareket h where h.id = @p0
                """, null, [hareketId], o => new
                {
                    Id = o.GetInt64(0), Hesap = o.GetInt32(1), Tarih = o.GetDateTime(2), Tutar = o.GetDecimal(3),
                    Aciklama = o.GetString(4), KarsiAd = o.GetString(5), Durum = o.GetInt16(6),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
            var h = (await HesaplariOkuAsync(b, null, baglam, true, 0, iptal)).FirstOrDefault(x => x.Id == bh.Hesap)
                    ?? throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
            var tolerans = await ToleransAsync(b, iptal);
            var adaylar = await b.ListeAsync("""
                select m.kasa_islem_id, coalesce(max(m.islem_no), ''), min(m.islem_tarihi), coalesce(max(m.tur_adi), ''),
                       coalesce(max(m.taraf_unvan), ''), coalesce(max(m.aciklama), ''), sum(m.borc - m.alacak)
                  from public.v_mali_hareket_ek m
                 where m.hesap_id = @p0 and m.hesap_ekstre = 1 and m.islem_durum = 2 and m.kasa_islem_id is not null
                   and m.islem_tarihi between @p1 - interval '45 day' and @p1 + interval '45 day'
                   and not exists (select 1 from public.banka_hareket x
                                    where x.hesap_id = m.hesap_id and x.kasa_islem_id = m.kasa_islem_id and x.durum = 2)
                 group by m.kasa_islem_id
                having abs(sum(m.borc - m.alacak) - @p2) <= @p3
                 order by abs(extract(epoch from min(m.islem_tarihi) - @p1)), m.kasa_islem_id
                 limit 50
                """, null, [h.Id, bh.Tarih, bh.Tutar, tolerans], o => new
                {
                    kasaIslemId = o.GetInt32(0), islemNo = o.GetString(1), tarih = o.GetDateTime(2), turAdi = o.GetString(3),
                    karsi = o.GetString(4), aciklama = o.GetString(5), tutar = o.GetDecimal(6), fark = R(o.GetDecimal(6) - bh.Tutar),
                }, iptal);
            return Results.Ok(new
            {
                hareket = new { bh.Id, hesapId = h.Id, hesapAd = h.Ad, bh.Tarih, bh.Tutar, bh.Aciklama, bh.KarsiAd, bh.Durum },
                tolerans, adaylar,
            });
        });

        // ---------------------------------------------------------------- eşleştir ---
        grup.MapPost("/esles", async (EslesIstegi i, BankaHareketServisi servis, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste(KodHareket, Islem.Degistir);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            if (i.HareketId <= 0 || i.KasaIslemId <= 0) throw GentegreHatasi.Dogrulama("Hareket ve kasa işlemi seçilmeli.");
            decimal tolerans;
            await using (var b = await veri.AcAsync(iptal))
            {
                var hesapId = await b.TekDegerAsync<int?>("select hesap_id from public.banka_hareket where id = @p0", null, [i.HareketId], iptal)
                              ?? throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
                if ((await HesaplariOkuAsync(b, null, baglam, true, 0, iptal)).All(x => x.Id != hesapId))
                    throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
                tolerans = await ToleransAsync(b, iptal);
            }
            var s = await servis.EslestirAsync(i.HareketId, i.KasaIslemId, tolerans, baglam.KullaniciId, iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloBankaHareket, i.HareketId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["durum"] = "işlenmemiş -> işlendi (eşleştirme)", ["kasaIslemId"] = i.KasaIslemId.ToString(CultureInfo.InvariantCulture),
                    ["kasaIslemNo"] = s.IslemNo, ["bankaTutar"] = LogDeposu.Metin(s.BankaTutar), ["kasaTutar"] = LogDeposu.Metin(s.KasaTutar),
                    ["hesapId"] = s.HesapId.ToString(CultureInfo.InvariantCulture), ["kaynak"] = "banka-mutabakat",
                }, iptal: iptal);
            return Results.Ok(new { tamam = true, kasaIslemId = i.KasaIslemId, islemNo = s.IslemNo, fark = R(s.KasaTutar - s.BankaTutar) });
        });

        // ------------------------------------------------- elle gün sonu bakiyesi ---
        grup.MapPost("/bakiye", async (BakiyeIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                       HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste(KodHareket, Islem.Degistir);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = DateOnly.FromDateTime(Saat.BugunDilim(baglam.ZamanDilimi));
            if (i.Gun is null) throw GentegreHatasi.Dogrulama("Gün seçilmeli.", new AlanHatasi("gun", "Zorunlu."));
            var gun = DateOnly.FromDateTime(i.Gun.Value);
            if (gun > bugun || gun.Year < 2000) throw GentegreHatasi.Dogrulama("Gün bugünden sonra olamaz.", new AlanHatasi("gun", "Geçersiz gün."));
            if (i.Bakiye is null) throw GentegreHatasi.Dogrulama("Bakiye girilmeli.", new AlanHatasi("bakiye", "Zorunlu."));
            if (Math.Abs(i.Bakiye.Value) > 9_999_999_999_999m) throw GentegreHatasi.Dogrulama("Tutar çok büyük.", new AlanHatasi("bakiye", "Geçersiz."));
            var bakiye = R(i.Bakiye.Value);
            var kaynak = i.Kaynak is 2 ? (short)2 : (short)1;
            var aciklama = (i.Aciklama ?? "").Trim();
            if (aciklama.Length > 300) throw GentegreHatasi.Dogrulama("Açıklama en çok 300 karakter.", new AlanHatasi("aciklama", "En çok 300 karakter."));

            await using var b = await veri.AcAsync(iptal);
            var h = (await HesaplariOkuAsync(b, null, baglam, true, 0, iptal)).FirstOrDefault(x => x.Id == i.HesapId)
                    ?? throw GentegreHatasi.Bulunamadi("Hesap bulunamadı.");
            if (h.BankaKaynak == 1)
                throw GentegreHatasi.IsKurali("Bu hesabın bakiyesi bankadan (API) gelir - elle girilmez. Bankadan çekin.");

            await using (var tx = await b.BeginTransactionAsync(iptal))
            {
                var eski = await BakiyeOkuAsync(b, tx, h.Id, gun, true, iptal);
                var surum = (i.Surum ?? "").Trim();
                if (eski is not null && surum.Length > 0 && surum != eski.surum) throw GentegreHatasi.Cakisma(eski);
                var bilgi = new Dictionary<string, string>
                {
                    ["hesapId"] = h.Id.ToString(CultureInfo.InvariantCulture), ["hesap"] = h.Ad,
                    ["gun"] = gun.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture), ["kaynak"] = "banka-mutabakat",
                };
                if (eski is null)
                {
                    var id = await b.TekDegerAsync<long>("""
                        insert into public.hesap_gun_bakiye (hesap_id, gun, bakiye, kaynak, aciklama, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4, @p5) returning id
                        """, tx, [h.Id, gun, bakiye, kaynak, aciklama, baglam.KullaniciId], iptal);
                    bilgi["bakiye"] = LogDeposu.Metin(bakiye);
                    bilgi["bakiyeKaynagi"] = kaynak == 2 ? "ekstre" : "elle";
                    bilgi["aciklama"] = aciklama;
                    await log.YazAsync(b, tx, LogIslemi.Ekle, LogTabloGunBakiye, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi, iptal: iptal);
                }
                else
                {
                    var fark = LogDeposu.Fark(
                        new Dictionary<string, object?> { ["bakiye"] = eski.bakiye, ["bakiyeKaynagi"] = eski.kaynak == 2 ? "ekstre" : "elle", ["aciklama"] = eski.aciklama },
                        new Dictionary<string, object?> { ["bakiye"] = bakiye, ["bakiyeKaynagi"] = kaynak == 2 ? "ekstre" : "elle", ["aciklama"] = aciklama });
                    if (fark is not null)
                    {
                        await b.CalistirAsync("""
                            update public.hesap_gun_bakiye set bakiye = @p1, kaynak = @p2, aciklama = @p3, degistiren = @p4, degistirme_tarihi = now()
                             where id = @p0
                            """, tx, [eski.id, bakiye, kaynak, aciklama, baglam.KullaniciId], iptal);
                        foreach (var (k, v) in bilgi) fark[k] = v;
                        await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloGunBakiye, eski.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark, iptal: iptal);
                    }
                }
                await tx.CommitAsync(iptal);
            }
            // O günün onayı bu bakiyeyle artık tutmuyorsa "bozuldu" (karar B4).
            var yerel = await YerelAsync(b, iptal);
            await BozulmalariYazAsync(b, [h], gun, baglam, log, yerel, iptal);
            return Results.Ok(new { kayit = await BakiyeOkuAsync(b, null, h.Id, gun, false, iptal), izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------------- onay ---
        grup.MapPost("/onay", async (OnayIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                     HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.AksiyonIste(KodOnay);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = DateOnly.FromDateTime(Saat.BugunDilim(baglam.ZamanDilimi));
            if (i.Gun is null) throw GentegreHatasi.Dogrulama("Mutabakat günü seçilmeli.", new AlanHatasi("gun", "Zorunlu."));
            var gun = DateOnly.FromDateTime(i.Gun.Value);
            if (gun > bugun || gun.Year < 2000) throw GentegreHatasi.Dogrulama("Gün bugünden sonra olamaz.", new AlanHatasi("gun", "Geçersiz gün."));
            var idler = (i.HesapIdler ?? []).Where(x => x > 0).Distinct().ToArray();
            if (idler.Length == 0) throw GentegreHatasi.Dogrulama("Onaylanacak hesap seçilmeli.", new AlanHatasi("hesapIdler", "Zorunlu."));

            await using var b = await veri.AcAsync(iptal);
            var yerel = await YerelAsync(b, iptal);
            var tumu = await HesaplariOkuAsync(b, null, baglam, true, 0, iptal);
            var hesaplar = tumu.Where(x => idler.Contains(x.Id)).ToList();
            if (hesaplar.Count != idler.Length) throw GentegreHatasi.Bulunamadi("Hesap bulunamadı.");
            var dortGoz = await AyarDeposu.SayiAsync(b, null, "banka.mutabakat_dort_goz", iptal) == 1;

            // Geriye dönük kayıtla bozulmuş onayları önce işle (yeniden onay bunların üstüne yazar).
            await BozulmalariYazAsync(b, hesaplar, null, baglam, log, yerel, iptal);
            var sonuclar = await HesaplaAsync(b, null, hesaplar, gun, yerel, iptal);

            var onaylanan = new List<int>();
            var hatalar = new List<object>();
            foreach (var s in sonuclar)
            {
                var engel = s.Engel(dortGoz, baglam.KullaniciId);
                if (engel != "") { hatalar.Add(new { hesapId = s.H.Id, ad = s.H.Ad, neden = engel }); continue; }
                var detay = JsonSerializer.Serialize(new
                {
                    kaynak = s.B.Kaynak, bankaZamani = s.B.Zaman, kur = s.G.Kur, valorBekleyen = s.G.ValorBekleyen,
                    yoldaToplam = s.YoldaToplam, islenmemisToplam = s.IslToplam,
                    yolda = s.Yol.Select(y => new { y.KasaIslemId, y.IslemNo, y.Tarih, y.Tutar }),
                    islenmemis = s.Isl.Select(x => new { x.Id, x.Tarih, x.Tutar, x.Durum }),
                }, DetayJson);
                await using var tx = await b.BeginTransactionAsync(iptal);
                var yazilan = await b.ListeAsync("""
                    insert into public.banka_mutabakat (hesap_id, gun, banka_bakiye, sistem_bakiye, aciklanmayan, durum, detay,
                                                        hazirlayan, onaylayan, onay_an)
                    values (@p0, @p1, @p2, @p3, @p4, 1, @p5::jsonb, @p6, @p7, now())
                    on conflict (hesap_id, gun) do update
                       set banka_bakiye = excluded.banka_bakiye, sistem_bakiye = excluded.sistem_bakiye,
                           aciklanmayan = excluded.aciklanmayan, durum = 1, detay = excluded.detay, hazirlayan = excluded.hazirlayan,
                           onaylayan = excluded.onaylayan, onay_an = now(), bozulma_an = null, bozulma_neden = ''
                     where public.banka_mutabakat.durum = 2
                    returning id, (xmax = 0)
                    """, tx, [s.H.Id, gun, s.B.Tutar!.Value, s.Sistem, s.Aciklanmayan ?? 0, detay, s.B.Hazirlayan, baglam.KullaniciId],
                    o => (id: o.GetInt64(0), yeni: o.GetBoolean(1)), iptal);
                if (yazilan.Count == 0)
                {
                    await tx.RollbackAsync(iptal);
                    hatalar.Add(new { hesapId = s.H.Id, ad = s.H.Ad, neden = "Bu gün zaten onaylı." });
                    continue;
                }
                await log.YazAsync(b, tx, yazilan[0].yeni ? LogIslemi.Ekle : LogIslemi.Degistir, LogTabloMutabakat, yazilan[0].id,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, new Dictionary<string, string>
                    {
                        ["hesapId"] = s.H.Id.ToString(CultureInfo.InvariantCulture), ["hesap"] = s.H.Ad,
                        ["gun"] = gun.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                        ["bankaBakiye"] = LogDeposu.Metin(s.B.Tutar), ["sistemBakiye"] = LogDeposu.Metin(s.Sistem),
                        ["bankaKaynagi"] = s.B.Kaynak, ["yolda"] = LogDeposu.Metin(s.YoldaToplam), ["islenmemis"] = LogDeposu.Metin(s.IslToplam),
                        ["hazirlayan"] = s.B.Hazirlayan.ToString(CultureInfo.InvariantCulture),
                        ["durum"] = yazilan[0].yeni ? "onaylı" : "bozuldu -> onaylı (yeniden onay)", ["kaynak"] = "banka-mutabakat",
                    }, iptal: iptal);
                await tx.CommitAsync(iptal);
                onaylanan.Add(s.H.Id);
            }
            return Results.Ok(new { gun, onaylanan, hatalar, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ============================================================== hesaplama ===

    private static DateOnly GunCoz(string? gun, DateOnly bugun)
    {
        var s = (gun ?? "").Trim();
        if (s.Length == 0) return bugun.AddDays(-1);   // karar B1: dünün gün sonu
        if (!DateOnly.TryParseExact(s.Length > 10 ? s[..10] : s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var g)
            || g.Year < 2000)
            throw GentegreHatasi.Dogrulama("Gün yyyy-AA-gg biçiminde olmalı.", new AlanHatasi("gun", "Geçersiz gün."));
        if (g > bugun) throw GentegreHatasi.Dogrulama("Mutabakat günü bugünden sonra olamaz.", new AlanHatasi("gun", "Geçersiz gün."));
        return g;
    }

    private static async Task<string> YerelAsync(NpgsqlConnection b, CancellationToken iptal)
        => await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6)", null, null, iptal) ?? "TL";

    /// <summary>Eşleştirme toleransı (TL): Genel Ayarlar `banka.mutabakat_tolerans_kurus` / 100; boş = 0.</summary>
    private static async Task<decimal> ToleransAsync(NpgsqlConnection b, CancellationToken iptal)
        => Math.Max(0, await AyarDeposu.SayiAsync(b, null, "banka.mutabakat_tolerans_kurus", iptal)) / 100m;

    /// <summary>
    /// Kullanıcının görebileceği banka hesapları (+ kart dahilse POS ve kredi kartı): hesabın şubesi kullanıcının
    /// şubelerinden biri ya da şubesiz. <paramref name="sube"/> seçiliyse o şube + şubesizler.
    /// </summary>
    private static async Task<List<HesapK>> HesaplariOkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, IstekBaglami baglam,
        bool kart, int sube, CancellationToken iptal)
    {
        var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
        var s0 = sube > 0 && subeler.Contains(sube) ? sube : 0;
        string[] turler = kart ? ["B", "P", "V"] : ["B"];
        return await b.ListeAsync("""
            select x.id, x.tur, coalesce(x.kod, ''), x.ad, coalesce(nullif(x.doviz_cinsi, ''), 'TL'), coalesce(x.iban, ''), x.banka_kaynak,
                   (select min(bh.islem_tarihi)::date from public.banka_hareket bh where bh.hesap_id = x.id), x.banka_son_cekim
              from public.hesap x
             where x.tur = any(@p0::text[]) and coalesce(x.durum, 1) = 1
               and (coalesce(x.sube_id, 0) = 0 or x.sube_id = any(@p1::int[]))
               and (@p2 = 0 or coalesce(x.sube_id, 0) = 0 or x.sube_id = @p2)
             order by case x.tur when 'B' then 0 when 'V' then 1 else 2 end, (x.banka_kaynak <> 1), x.ad
            """, tx, [turler, subeler, s0], o => new HesapK(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetString(4),
                o.GetString(5), o.GetInt16(6), o.IsDBNull(7) ? null : o.GetDateTime(7), o.IsDBNull(8) ? null : o.GetDateTime(8)), iptal);
    }

    /// <summary>(hesap, gün) çiftleri için gün sonu banka verisi, elle bakiye, sistem bakiyesi, valör bekleyen, kur.</summary>
    private static async Task<Dictionary<(int, DateOnly), GunB>> GunlerAsync(NpgsqlConnection b, NpgsqlTransaction? tx,
        List<(int hesap, DateOnly gun)> ciftler, string yerel, CancellationToken iptal)
    {
        var tekil = ciftler.Distinct().ToList();
        if (tekil.Count == 0) return new();
        var liste = await b.ListeAsync("""
            select x.id, x.gun,
                   f.bakiye, f.islem_tarihi,
                   exists (select 1 from public.banka_hareket s where s.hesap_id = x.id and s.islem_tarihi >= x.gun + 1),
                   coalesce(h.banka_son_cekim >= x.gun + 1, false),
                   h.banka_bakiye, coalesce(h.banka_bakiye_zaman >= x.gun + 1, false), h.banka_bakiye_zaman,
                   e.id, e.bakiye, coalesce(e.kaynak, 1::smallint), coalesce(e.aciklama, ''),
                   coalesce(case when e.degistiren > 0 then e.degistiren else e.ekleyen end, 0),
                   coalesce(public.fn_taraf_ad(eu.unvan, eu.ad, eu.soyad)::varchar(120), ''),
                   coalesce(e.degistirme_tarihi, e.ekleme_tarihi), coalesce(e.xmin::text, ''),
                   (select coalesce(sum(m.borc - m.alacak), 0) from public.v_mali_hareket_ek m
                     where m.hesap_id = x.id and m.hesap_ekstre = 1 and m.islem_durum = 2 and m.islem_tarihi < x.gun + 1),
                   coalesce(ih.isleyen, 0), coalesce(public.fn_taraf_ad(iu.unvan, iu.ad, iu.soyad)::varchar(120), ''),
                   (select coalesce(sum(v.tutar), 0) from public.banka_hareket v
                     where v.hesap_id = x.id and v.durum <> 3 and v.islem_tarihi < x.gun + 1 and v.valor_tarihi > x.gun),
                   case when upper(coalesce(nullif(h.doviz_cinsi, ''), 'TL')) in ('TL', 'TRY') or h.doviz_cinsi = @p2 then 1::numeric
                        else public.fn_doviz_kur_getir(h.doviz_cinsi, x.gun, 2::smallint) end
              from unnest(@p0::int[], @p1::date[]) as x(id, gun)
              join public.hesap h on h.id = x.id
              left join lateral (select f0.bakiye, f0.islem_tarihi from public.banka_hareket f0
                                  where f0.hesap_id = x.id and f0.bakiye is not null and f0.islem_tarihi < x.gun + 1
                                  order by f0.islem_tarihi desc, f0.id desc limit 1) f on true
              left join public.hesap_gun_bakiye e on e.hesap_id = x.id and e.gun = x.gun
              left join public.taraf eu on eu.id = case when e.degistiren > 0 then e.degistiren else e.ekleyen end
              left join lateral (select i0.isleyen from public.banka_hareket i0
                                  where i0.hesap_id = x.id and i0.islem_tarihi < x.gun + 1 and i0.isleyen > 0
                                  order by i0.isleme_zamani desc nulls last limit 1) ih on true
              left join public.taraf iu on iu.id = ih.isleyen
            """, tx, [tekil.Select(c => c.hesap).ToArray(), tekil.Select(c => c.gun).ToArray(), yerel], o => new GunB(
                o.GetInt32(0), DateOnly.FromDateTime(o.GetDateTime(1)),
                o.IsDBNull(2) ? null : o.GetDecimal(2), o.IsDBNull(3) ? null : o.GetDateTime(3),
                o.GetBoolean(4), o.GetBoolean(5),
                o.IsDBNull(6) ? null : o.GetDecimal(6), o.GetBoolean(7), o.IsDBNull(8) ? null : o.GetDateTime(8),
                o.IsDBNull(9) ? null : o.GetInt64(9), o.IsDBNull(10) ? null : o.GetDecimal(10), o.GetInt16(11), o.GetString(12),
                o.GetInt32(13), o.GetString(14), o.IsDBNull(15) ? null : o.GetDateTime(15), o.GetString(16),
                o.GetDecimal(17), o.GetInt32(18), o.GetString(19), o.GetDecimal(20), o.IsDBNull(21) ? null : o.GetDecimal(21)), iptal);
        return liste.ToDictionary(x => (x.HesapId, x.Gun));
    }

    /// <summary>Banka bakiyesinin kaynağını seçer (sınıf açıklamasındaki sıra).</summary>
    private static BankaDegeri BankaCoz(HesapK h, GunB g)
    {
        BankaDegeri? Elle() => g.Elle is { } e
            ? new BankaDegeri(e, g.ElleKaynak == 2 ? "ekstre" : "elle", g.ElleZaman, g.ElleAciklama, false, g.ElleGiren, g.ElleGirenAd)
            : null;
        if (h.BankaKaynak == 1)
        {
            if (g.Besleme is { } f) return new BankaDegeri(f, "api", g.BeslemeZaman, "", !g.CekimKapsar, g.ApiHazirlayan, g.ApiHazirlayanAd);
            if (g.ApiBakiye is { } a && g.ApiKapsar && !g.Sonra)
                return new BankaDegeri(a, "api", g.ApiZaman, "son çekim bakiyesi", false, g.ApiHazirlayan, g.ApiHazirlayanAd);
            return Elle() ?? new BankaDegeri(null, "yok", null, "", false, 0, "");
        }
        return Elle()
               ?? (g.Besleme is { } d ? new BankaDegeri(d, "dosya", g.BeslemeZaman, "", false, g.ApiHazirlayan, g.ApiHazirlayanAd) : null)
               ?? new BankaDegeri(null, "yok", null, "", false, 0, "");
    }

    /// <summary>Onaylı günün şimdiki değerleri dondurulandan farklıysa neden; tutuyorsa boş.</summary>
    private static string BozulmaNedeni(OnayK o, GunB g, BankaDegeri bd)
    {
        if (Math.Abs(R(g.Sistem) - o.Sistem) >= 0.005m)
            return $"Sistem bakiyesi değişti (onayda {o.Sistem.ToString("N2", Tr)}, şimdi {g.Sistem.ToString("N2", Tr)}) - o güne geriye dönük kayıt.";
        if (bd.Tutar is { } t && Math.Abs(t - o.Banka) >= 0.005m)
            return $"Banka bakiyesi değişti (onayda {o.Banka.ToString("N2", Tr)}, şimdi {t.ToString("N2", Tr)}).";
        return "";
    }

    private static int IsGunu(DateOnly bas, DateOnly bit)
    {
        var n = 0;
        for (var d = bas.AddDays(1); d <= bit; d = d.AddDays(1))
            if (d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday)) n++;
        return n;
    }

    /// <summary>Hesapların <paramref name="gun"/> sonu mutabakatı: bakiyeler, iki açıklama listesi, onay.</summary>
    private static async Task<List<Sonuc>> HesaplaAsync(NpgsqlConnection b, NpgsqlTransaction? tx, List<HesapK> hesaplar,
        DateOnly gun, string yerel, CancellationToken iptal)
    {
        if (hesaplar.Count == 0) return [];
        var idler = hesaplar.Select(x => x.Id).ToArray();
        var gb = await GunlerAsync(b, tx, hesaplar.Select(x => (x.Id, gun)).ToList(), yerel, iptal);

        // İŞLENMEMİŞ: banka var, sistem (o güne kadar) yok.
        var isl = await b.ListeAsync("""
            select bh.id, bh.hesap_id, x.ad, bh.islem_tarihi, bh.islem_tarihi::date, bh.valor_tarihi, bh.aciklama, bh.karsi_ad, bh.karsi_iban,
                   bh.tutar, bh.durum, coalesce(bh.oneri ->> 'tur', ''), coalesce(bh.oneri ->> 'tarafAd', bh.oneri ->> 'hedefHesapAd', ''),
                   coalesce((bh.oneri ->> 'guven')::int, 0), coalesce(bh.oneri ->> 'neden', ''), bh.kasa_islem_id
              from public.banka_hareket bh join public.hesap x on x.id = bh.hesap_id
             where bh.hesap_id = any(@p0::int[]) and bh.islem_tarihi < @p1::date + 1
               and not (bh.durum = 2 and exists (
                       select 1 from public.v_mali_hareket_ek m
                        where m.kasa_islem_id = bh.kasa_islem_id and m.hesap_id = bh.hesap_id and m.hesap_ekstre = 1
                          and m.islem_durum = 2 and m.islem_tarihi < @p1::date + 1))
             order by bh.islem_tarihi desc, bh.id desc
            """, tx, [idler, gun], o => new Islenmemis(o.GetInt64(0), o.GetInt32(1), o.GetString(2), o.GetDateTime(3), o.GetDateTime(4),
                o.IsDBNull(5) ? null : o.GetDateTime(5), o.GetString(6), o.GetString(7), o.GetString(8), o.GetDecimal(9), o.GetInt16(10),
                o.GetString(11), o.GetString(12), o.GetInt32(13), o.GetString(14), o.IsDBNull(15) ? null : o.GetInt32(15)), iptal);

        // YOLDA: sistem var, banka (o güne kadar) yok - yalnız hesabın banka hareketi akışı başladıktan sonrası.
        var yolHam = await b.ListeAsync("""
            select m.kasa_islem_id, coalesce(m.islem_no, ''), m.islem_tarihi, m.islem_tarihi::date, m.hesap_id, x.ad,
                   coalesce(m.tur_adi, ''), coalesce(m.taraf_unvan, ''), coalesce(m.aciklama, ''), m.borc - m.alacak,
                   coalesce(m.cek_senet_id, 0), cs.vade
              from public.v_mali_hareket_ek m
              join public.hesap x on x.id = m.hesap_id
              left join public.cek_senet cs on cs.id = nullif(m.cek_senet_id, 0)
             where m.hesap_id = any(@p0::int[]) and m.hesap_ekstre = 1 and m.islem_durum = 2
               and m.islem_tarihi < @p1::date + 1
               and m.islem_tarihi >= (select min(b0.islem_tarihi)::date from public.banka_hareket b0 where b0.hesap_id = m.hesap_id)
               and abs(m.borc - m.alacak) >= 0.005
               and not exists (select 1 from public.banka_hareket bh
                                where bh.hesap_id = m.hesap_id and bh.kasa_islem_id = m.kasa_islem_id
                                  and bh.durum = 2 and bh.islem_tarihi < @p1::date + 1)
             order by m.islem_tarihi, m.kasa_islem_id
            """, tx, [idler, gun], o => (kasa: o.IsDBNull(0) ? (int?)null : o.GetInt32(0), no: o.GetString(1), tarih: o.GetDateTime(2),
                gun: o.GetDateTime(3), hesap: o.GetInt32(4), hesapAd: o.GetString(5), turAdi: o.GetString(6), karsi: o.GetString(7),
                aciklama: o.GetString(8), tutar: o.GetDecimal(9), cek: o.GetInt32(10) > 0, vade: o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11)), iptal);
        // Aynı kasa işleminin aynı hesaptaki bacakları tek satır (tutar + masraf gibi).
        var yol = yolHam.GroupBy(y => y.kasa is { } k ? $"{y.hesap}:{k}" : $"{y.hesap}:{y.tarih.Ticks}:{y.no}:{y.tutar}")
            .Select(grp =>
            {
                var y = grp.First();
                var tutar = R(grp.Sum(z => z.tutar));
                var isg = IsGunu(DateOnly.FromDateTime(y.gun), gun);
                bool gecikti; string metin;
                if (y.cek && y.vade is { } v)
                {
                    var vd = DateOnly.FromDateTime(v);
                    gecikti = gun > vd.AddDays(1);
                    metin = gecikti ? $"vadesi {vd.ToString("dd.MM", Tr)} geçti, bankada yok - kontrol" : $"vadesi {vd.ToString("dd.MM", Tr)} · normal";
                }
                else
                {
                    gecikti = isg > YoldaEsikIsGunu;
                    metin = gecikti ? $"{isg} iş günüdür bankada yok - kontrol" : "normal";
                }
                return new Yolda(y.kasa, y.no, y.tarih, y.gun, y.hesap, y.hesapAd, y.turAdi, y.karsi, y.aciklama, tutar, y.cek, y.vade,
                                 isg, gecikti, metin);
            }).ToList();

        var onaylar = (await OnaylarAsync(b, tx, idler, [gun], 0, iptal)).ToDictionary(o => o.HesapId);
        return hesaplar.Select(h =>
        {
            var g = gb[(h.Id, gun)];
            var bd = BankaCoz(h, g);
            var o = onaylar.GetValueOrDefault(h.Id);
            return new Sonuc
            {
                H = h, G = g, B = bd,
                Isl = isl.Where(x => x.HesapId == h.Id).ToList(),
                Yol = yol.Where(x => x.HesapId == h.Id).ToList(),
                Onay = o,
                Bozulma = o is { Durum: 1 } ? BozulmaNedeni(o, g, bd) : o is { Durum: 2 } ? (o.BozulmaNeden != "" ? o.BozulmaNeden : "bozuldu") : "",
            };
        }).ToList();
    }

    /// <summary>
    /// Onay satırları. <paramref name="gunler"/> verilirse yalnız o günler; değilse son <paramref name="sonGun"/>
    /// farklı onay günü.
    /// </summary>
    private static Task<List<OnayK>> OnaylarAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int[] hesaplar, DateOnly[]? gunler,
        int sonGun, CancellationToken iptal)
        => hesaplar.Length == 0 ? Task.FromResult(new List<OnayK>()) : b.ListeAsync("""
            select m.id, m.hesap_id, m.gun, m.banka_bakiye, m.sistem_bakiye, m.aciklanmayan, m.durum, m.hazirlayan, m.onaylayan,
                   coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''), m.onay_an, m.bozulma_an, m.bozulma_neden
              from public.banka_mutabakat m
              left join public.taraf u on u.id = m.onaylayan
             where m.hesap_id = any(@p0::int[])
               and (case when @p1::date[] is null
                         then m.gun in (select distinct z.gun from public.banka_mutabakat z where z.hesap_id = any(@p0::int[])
                                         order by z.gun desc limit @p2)
                         else m.gun = any(@p1::date[]) end)
             order by m.gun desc, m.hesap_id
            """, tx, [hesaplar, gunler, Math.Max(1, sonGun)], o => new OnayK(o.GetInt64(0), o.GetInt32(1), DateOnly.FromDateTime(o.GetDateTime(2)),
                o.GetDecimal(3), o.GetDecimal(4), o.GetDecimal(5), o.GetInt16(6), o.GetInt32(7), o.GetInt32(8), o.GetString(9),
                o.GetDateTime(10), o.IsDBNull(11) ? null : o.GetDateTime(11), o.GetString(12)), iptal);

    /// <summary>
    /// BOZULMA YAZIMI (karar B4): onaylı (durum 1) günlerden şimdiki değeri dondurulandan farklı olanlar durum 2 olur,
    /// bozulma anı / nedeni yazılır ve loglanır. <paramref name="tekGun"/> yoksa hesabın son 400 günü.
    /// </summary>
    private static async Task BozulmalariYazAsync(NpgsqlConnection b, List<HesapK> hesaplar, DateOnly? tekGun, IstekBaglami baglam,
        LogDeposu log, string yerel, CancellationToken iptal)
    {
        if (hesaplar.Count == 0) return;
        var bugun = DateOnly.FromDateTime(Saat.BugunDilim(baglam.ZamanDilimi));
        var satirlar = await b.ListeAsync("""
            select m.id, m.hesap_id, m.gun, m.banka_bakiye, m.sistem_bakiye
              from public.banka_mutabakat m
             where m.hesap_id = any(@p0::int[]) and m.durum = 1
               and (case when @p1::date is null then m.gun >= @p2::date else m.gun = @p1::date end)
            """, null, [hesaplar.Select(x => x.Id).ToArray(), tekGun, bugun.AddDays(-400)], o => new OnayK(o.GetInt64(0), o.GetInt32(1),
                DateOnly.FromDateTime(o.GetDateTime(2)), o.GetDecimal(3), o.GetDecimal(4), 0, 1, 0, 0, "", DateTime.MinValue, null, ""), iptal);
        if (satirlar.Count == 0) return;
        var gb = await GunlerAsync(b, null, satirlar.Select(r => (r.HesapId, r.Gun)).ToList(), yerel, iptal);
        var hMap = hesaplar.ToDictionary(x => x.Id);
        foreach (var r in satirlar)
        {
            var g = gb[(r.HesapId, r.Gun)];
            var neden = BozulmaNedeni(r, g, BankaCoz(hMap[r.HesapId], g));
            if (neden == "") continue;
            await using var tx = await b.BeginTransactionAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.banka_mutabakat set durum = 2, bozulma_an = now(), bozulma_neden = left(@p1, 300)
                 where id = @p0 and durum = 1
                """, tx, [r.Id, neden], iptal);
            if (n > 0)
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloMutabakat, r.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["durum"] = "onaylı -> bozuldu", ["neden"] = neden, ["hesapId"] = r.HesapId.ToString(CultureInfo.InvariantCulture),
                        ["gun"] = r.Gun.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture), ["kaynak"] = "banka-mutabakat",
                    }, iptal: iptal);
            await tx.CommitAsync(iptal);
        }
    }

    private sealed record BakiyeKaydi(long id, int hesapId, DateOnly gun, decimal bakiye, short kaynak, string aciklama,
                                      string giren, DateTime? zaman, string surum);

    private static async Task<BakiyeKaydi?> BakiyeOkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int hesap, DateOnly gun,
        bool kilitle, CancellationToken iptal)
    {
        var l = await b.ListeAsync("""
            select e.id, e.hesap_id, e.gun, e.bakiye, e.kaynak, e.aciklama,
                   coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''),
                   coalesce(e.degistirme_tarihi, e.ekleme_tarihi), e.xmin::text
              from public.hesap_gun_bakiye e
              left join public.taraf u on u.id = case when e.degistiren > 0 then e.degistiren else e.ekleyen end
             where e.hesap_id = @p0 and e.gun = @p1
            """ + (kilitle ? " for update of e" : ""), tx, [hesap, gun], o => new BakiyeKaydi(o.GetInt64(0), o.GetInt32(1),
                DateOnly.FromDateTime(o.GetDateTime(2)), o.GetDecimal(3), o.GetInt16(4), o.GetString(5), o.GetString(6),
                o.IsDBNull(7) ? null : o.GetDateTime(7), o.GetString(8)), iptal);
        return l.Count > 0 ? l[0] : null;
    }

    // =============================================================== satırlar ===

    private static string Ozetle(IEnumerable<string> adlar)
        => string.Join(", ", adlar.Where(a => a != "").GroupBy(a => a).OrderByDescending(g => g.Count())
            .Select(g => g.Count() > 1 ? $"{g.Count()} {g.Key}" : g.Key).Take(4));

    private static string IslNot(IEnumerable<Islenmemis> l)
    {
        var x = l.ToList();
        if (x.Count == 0) return "";
        var parca = new List<string>();
        var oneri = x.Count(z => z.Durum == 1);
        var secim = x.Count(z => z.Durum == 4);
        var yok = x.Count(z => z.Durum == 3);
        if (oneri > 0) parca.Add($"{oneri} öneri hazır");
        if (secim > 0) parca.Add($"{secim} seçim bekliyor");
        if (yok > 0) parca.Add($"{yok} yoksayılan");
        var ad = Ozetle(x.Select(z => z.OneriTur switch
        {
            "tahsilat" => "tahsilat", "tediye" => "ödeme", "virman" => "virman", "pos" => "POS", "masraf" => "masraf", _ => "",
        }));
        if (ad != "") parca.Insert(0, ad);
        return string.Join(" · ", parca);
    }

    private static object HesapSatiri(Sonuc s, bool dortGoz, int kullanici)
    {
        var yc = s.Yol.Where(y => y.Tutar < 0).ToList();
        var yg = s.Yol.Where(y => y.Tutar > 0).ToList();
        var ig = s.Isl.Where(x => x.Tutar > 0).ToList();
        var ic = s.Isl.Where(x => x.Tutar < 0).ToList();
        var engel = s.Engel(dortGoz, kullanici);
        return new
        {
            id = s.H.Id, ad = s.H.Ad, tur = s.H.Tur, kod = s.H.Kod, doviz = s.H.Doviz, iban = s.H.Iban,
            api = s.H.BankaKaynak == 1, akisVar = s.H.BeslemeBas is not null, akisBas = s.H.BeslemeBas,
            kaynak = s.B.Kaynak, bankaBakiye = s.B.Tutar, bakiyeZamani = s.B.Zaman, bakiyeNot = s.B.Not,
            bakiyeGiren = s.B.Kaynak is "elle" or "ekstre" ? s.G.ElleGirenAd : null,
            elle = s.G.Elle is null ? null : new { bakiye = s.G.Elle, kaynak = s.G.ElleKaynak, aciklama = s.G.ElleAciklama, giren = s.G.ElleGirenAd, zaman = s.G.ElleZaman, surum = s.G.ElleSurum },
            cekimEksik = s.B.Eksik, sonCekim = s.H.SonCekim,
            sistemBakiye = R(s.Sistem), fark = s.Fark,
            islenmemisAdet = s.Isl.Count, islenmemisTutar = s.IslToplam, oneriHazir = s.Isl.Count(x => x.Durum == 1),
            yoldaAdet = s.Yol.Count, yoldaTutar = s.YoldaToplam, yoldaGeciken = s.Yol.Count(y => y.Gecikti),
            aciklanmayan = s.Aciklanmayan, valorBekleyen = R(s.G.ValorBekleyen), kur = s.G.Kur,
            yerelMi = s.G.Kur == 1m,
            durum = s.Durum,
            onay = s.Onay is null ? null : new
            {
                durum = s.Onayli ? "onayli" : "bozuldu", onaylayan = s.Onay.OnaylayanAd, onayAn = s.Onay.OnayAn,
                banka = s.Onay.Banka, sistem = s.Onay.Sistem, bozulmaNeden = s.Onayli ? null : s.Bozulma,
            },
            onaylanabilir = engel == "", onayEngel = engel == "" ? null : engel,
            hazirlayan = s.B.Hazirlayan > 0 ? s.B.HazirlayanAd : null,
            tablo = new
            {
                banka = s.B.Tutar,
                yoldaCikis = R(yc.Sum(y => y.Tutar)), yoldaCikisAdet = yc.Count, yoldaCikisNot = Ozetle(yc.Select(y => y.TurAdi)),
                yoldaGiris = R(yg.Sum(y => y.Tutar)), yoldaGirisAdet = yg.Count, yoldaGirisNot = Ozetle(yg.Select(y => y.TurAdi)),
                duzeltilmisBanka = s.DuzBanka,
                sistem = R(s.Sistem),
                islenmemisGiris = R(ig.Sum(x => x.Tutar)), islenmemisGirisAdet = ig.Count, islenmemisGirisNot = IslNot(ig),
                islenmemisCikis = R(ic.Sum(x => x.Tutar)), islenmemisCikisAdet = ic.Count, islenmemisCikisNot = IslNot(ic),
                duzeltilmisSistem = s.DuzSistem,
                aciklanmayan = s.Aciklanmayan,
            },
        };
    }

    private static object IslenmemisSatiri(Islenmemis x, DateOnly gun) => new
    {
        x.Id, x.HesapId, x.HesapAd, x.Tarih, valor = x.Valor, x.Aciklama, x.KarsiAd, x.KarsiIban, x.Tutar, x.Durum,
        oneriTur = x.OneriTur, oneriHedef = x.OneriHedef, guven = x.Guven, neden = x.OneriNeden,
        valorBekleyen = x.Valor is { } v && DateOnly.FromDateTime(v) > gun,
        // İşlenmiş ama bağlı kasa işlemi günden sonra tarihli.
        sonraIslendi = x.Durum == 2,
    };

    private static object YoldaSatiri(Yolda y) => new
    {
        y.KasaIslemId, y.IslemNo, y.Tarih, y.HesapId, y.HesapAd, y.TurAdi, y.Karsi, y.Aciklama, y.Tutar,
        gun = y.IsGunu, y.Cek, y.Vade, y.Gecikti, y.DurumMetni,
    };
}
