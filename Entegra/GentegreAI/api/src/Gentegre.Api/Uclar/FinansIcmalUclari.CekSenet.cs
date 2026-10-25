using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇEK / SENET İCMALİ `GET /api/finans-icmal/cek-senet` (kullanıcı 25.10.2026 - mockup
/// Ekranlar/İcmal/cek_senet_icmali.html). "Elimizde ne kadarlık çek / senet var, nerede (portföy,
/// banka, teminat, ciro), ne zaman paraya dönüyor, hangisi riskli; kendi verdiğimiz çeklere hesapta
/// karşılık var mı?"
///
/// <para><b>Durum</b> `cek_senet.durum` - Çek / Senet Listesi'yle (KaynakKatalogu `cek-senet`) AYNI
/// kod ve ad: 10 Portföyde, 20 Ciro Edildi, 30 Tahsilde, 40 Teminatta, 50 Tahsil Edildi, 60
/// Karşılıksız, 70 İade, 0 İptal. Durum her evrakın son hareketidir (cek_senet_hareket
/// yeni_durum'u; aktarım 1147 ve kasa akışı ikisini birlikte yazar), ayrıca türetilmez.
/// Açık evrak = 10, 30, 40, 60 ve vadesi gelmemiş 20 (ciro edilmiş, vadesi geçmiş evrakta
/// rücu riski kalmaz).</para>
///
/// <para><b>Değer</b> (karar 25.10.2026): dövizli evrak BUGÜNKÜ kurla TL (fn_doviz_kur_getir,
/// alış - devir ekranıyla aynı yön); kur yoksa evrakın alış kuru. Alındığı günün kuru (yerel_tutar)
/// ve kur farkı satır ayrıntısında. Para birimi seçilirse yalnız o paradaki evrak, kendi tutarıyla.</para>
///
/// <para><b>Verilen çekler</b>: vade günündeki banka hesabı bakiyesi = bugünkü defter bakiyesi
/// (v_hesap_bakiye, Hesap Listesi'nin "Bakiye"si) + o hesapta tahsildeki alınan çeklerden vadesi
/// gelenler − aynı hesaptan o güne kadar ödenecek verilen evrakların birikimli toplamı; eksiye
/// düşerse satır "yetersiz". Hesabı boş evrakta bankası aynı, para birimi aynı TEK banka hesabı
/// varsa o hesap varsayılır (hesapTahmini).</para>
///
/// <para>İcmal KAYIT YAZMAZ: "bankaya tahsile ver" / "ciro et" ekranda mevcut çek / senet akışına
/// yönlendirir. Karşılıksız takibi burada yalnız durum rozetidir. Şube süzgeci sunucuda
/// (kullanıcının şubeleri). Rakamlar sunucuda; ekran toplamaz.</para>
/// </summary>
public static partial class FinansIcmalUclari
{
    private const string CekSenetKod = "finans.cek_senet_icmali";

    private static readonly CultureInfo CekSenetTr = CultureInfo.GetCultureInfo("tr-TR");

    /// <summary>Liste ile aynı durum adları (KaynakKatalogu.Kasa `cek-senet` durum kolonu).</summary>
    private static string CekSenetDurumAdi(int durum) => durum switch
    {
        10 => "Portföyde", 20 => "Ciro Edildi", 30 => "Tahsilde", 40 => "Teminatta",
        50 => "Tahsil Edildi", 60 => "Karşılıksız", 70 => "İade", 0 => "İptal", _ => "",
    };

    /// <summary>cek_senet_hareket.islem adları (072).</summary>
    private static string CekSenetIslemAdi(int islem, int yon) => islem switch
    {
        130 => yon == 2 ? "Verildi" : "Portföye giriş",
        131 => "Ciro edildi",
        132 => "Bankaya tahsile verildi",
        133 => "Tahsil edildi",
        134 => "Karşılıksız",
        135 => "İade",
        136 => "Ödendi",
        137 => "Teminata verildi",
        138 => "Teminattan döndü",
        139 => "İptal (geri alma)",
        _ => "İşlem " + islem,
    };

    private sealed class CekSenetHareket
    {
        public DateTime Tarih { get; init; }
        public int Islem { get; init; }
        public string Ad { get; init; } = "";
        public int EskiDurum { get; init; }
        public int YeniDurum { get; init; }
        public string Cari { get; init; } = "";
        public string Hesap { get; init; } = "";
        public string Aciklama { get; init; } = "";
        public string IslemNo { get; init; } = "";
    }

    private sealed class CekSenetEvrak
    {
        public int Id { get; init; }
        public int Tur { get; init; }
        public int Yon { get; init; }
        public int Durum { get; init; }
        public string DurumAdi { get; set; } = "";
        /// <summary>Rozetin ikinci parçası: tahsildeki hesap, teminat yeri, ciro edilen cari, karşılıksız notu.</summary>
        public string DurumEk { get; set; } = "";
        public string SeriNo { get; init; } = "";
        public string Kesideci { get; init; } = "";
        /// <summary>Keşideci cariden farklı (müşterinin müşterisi): risk.</summary>
        public bool UcuncuKisi { get; init; }
        public string Cari { get; init; } = "";
        public int? CariId { get; init; }
        public string CiroCari { get; init; } = "";
        public string Banka { get; init; } = "";
        public string BankaSube { get; init; } = "";
        public int? HesapId { get; init; }
        public string Hesap { get; init; } = "";
        public string HesapDoviz { get; init; } = "";
        public bool HesapTahmini { get; init; }
        public DateTime Tarih { get; init; }
        public DateTime Vade { get; init; }
        public int KalanGun { get; init; }
        public decimal Tutar { get; init; }
        public string Doviz { get; init; } = "TL";
        public decimal AlisKuru { get; init; }
        public decimal? BugunKur { get; init; }
        public bool KurYok { get; init; }
        /// <summary>Alındığı günün kuruyla TL (cek_senet.yerel_tutar).</summary>
        public decimal AlisDeger { get; init; }
        /// <summary>Hesap değeri: para birimi seçili değilse bugünkü kurla TL, seçiliyse evrakın kendi tutarı.</summary>
        public decimal Deger { get; init; }
        /// <summary>Bugünkü kurla TL − alış kuruyla TL (yalnız dövizli evrakta).</summary>
        public decimal KurFarki { get; init; }
        public string MakbuzNo { get; init; } = "";
        public string GirisIslemNo { get; init; } = "";
        public string Aciklama { get; init; } = "";
        /// <summary>Tahsile verme / ciro için seçilebilir: alınan ve portföyde.</summary>
        public bool Secilebilir { get; init; }
        public List<CekSenetHareket> Hareketler { get; set; } = [];
        // verilen evrak - vade günündeki hesap durumu (hesabın kendi para biriminde)
        public decimal? VadeBakiye { get; set; }
        public bool Yetersiz { get; set; }
        public bool Hesapsiz { get; set; }
    }

    private static int[] CekSenetSubeler(IstekBaglami baglam) => baglam.Subeler.Select(s => s.Id).ToArray();

    private static string CekSenetAnahtar(string ad) => (ad ?? "").Trim().ToUpper(CekSenetTr);

    /// <summary>Evrak tutarını hesabın para birimine çevirir (bugünkü kurlarla).</summary>
    private static decimal CekSenetHesapParasi(CekSenetEvrak e, string hesapDoviz, decimal hesapKur)
    {
        if (string.Equals(e.Doviz, hesapDoviz, StringComparison.OrdinalIgnoreCase) || hesapDoviz == "") return e.Tutar;
        var tl = e.Tutar * (e.Doviz == "TL" ? 1m : e.BugunKur ?? e.AlisKuru);
        return Math.Round(tl / (hesapKur > 0 ? hesapKur : 1m), 2);
    }

    private static bool CekSenetVadeUyar(string vade, int kalan) => vade switch
    {
        "gecmis" => kalan < 0,
        "7" => kalan is >= 0 and <= 7,
        "30" => kalan is >= 0 and <= 30,
        "60" => kalan is >= 0 and <= 60,
        "90" => kalan is >= 0 and <= 90,
        "sonra" => kalan > 90,
        _ => true,
    };

    private static void CekSenetUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/cek-senet", async (int? tur, string? para, string? banka, string? vade, DateTime? bas, DateTime? bit,
                                         VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(CekSenetKod, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var subeler = CekSenetSubeler(baglam);
            var t0 = tur is 1 or 2 ? tur.Value : 0;
            var pb = (para ?? "").Trim().ToUpperInvariant();
            if (pb.Length > 6) throw GentegreHatasi.Dogrulama("Para birimi geçersiz.");
            var vadeSecim = (vade ?? "").Trim();
            var bankaSecim = (banka ?? "").Trim();
            var donemBit = (bit ?? bugun).Date;
            var donemBas = (bas ?? new DateTime(donemBit.Year, donemBit.Month, 1)).Date;
            if (donemBas > donemBit) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            var tlMi = pb == "";
            await using var b = await veri.AcAsync(iptal);

            // ------------------------------------------------------------ açık evraklar --
            var ham = await b.ListeAsync("""
                select c.id, c.tur, c.yon, c.durum, coalesce(c.seri_no, ''), coalesce(btrim(c.kesideci), ''),
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), c.taraf_id,
                       coalesce(public.fn_taraf_ad(ct.unvan, ct.ad, ct.soyad)::varchar(160), ''),
                       coalesce(nullif(btrim(bk.kisa_ad), ''), nullif(btrim(bk.ad), ''), btrim(c.banka_adi), ''),
                       coalesce(nullif(btrim(bs.ad), ''), btrim(c.banka_subesi), ''),
                       hs.id, coalesce(hs.ad, ''), coalesce(hs.doviz_cinsi, ''), (c.hesap_id is null and th.id is not null),
                       c.tarih, c.vade, c.tutar, coalesce(nullif(c.doviz_cinsi, ''), 'TL'), c.doviz_kuru, c.yerel_tutar,
                       public.fn_doviz_kur_getir(coalesce(nullif(c.doviz_cinsi, ''), 'TL'), @p0::date, 2::smallint),
                       coalesce(c.makbuz_no, ''), coalesce(ki.islem_no, ''), coalesce(c.aciklama, ''),
                       coalesce(sh.aciklama, ''), coalesce(sh.hesap, ''), coalesce(sh.taraf, '')
                  from public.cek_senet c
                  left join public.taraf t  on t.id = c.taraf_id
                  left join public.taraf ct on ct.id = c.ciro_taraf_id
                  left join public.banka bk on bk.id = c.banka_id
                  left join public.banka_sube bs on bs.id = c.banka_sube_id
                  left join public.kasa_islem ki on ki.id = c.giris_kasa_islem_id
                  left join lateral (
                        select min(h2.id) as id from public.hesap h2
                         where c.hesap_id is null and c.yon = 2 and c.banka_id is not null
                           and h2.banka_id = c.banka_id and h2.tur = 'B' and coalesce(h2.durum, 1) = 1
                           and h2.doviz_cinsi = coalesce(nullif(c.doviz_cinsi, ''), 'TL')
                        having count(*) = 1) th on true
                  left join public.hesap hs on hs.id = coalesce(c.hesap_id, th.id)
                  left join lateral (
                        select h.aciklama, coalesce(hh.ad, '') as hesap,
                               coalesce(public.fn_taraf_ad(ht.unvan, ht.ad, ht.soyad)::varchar(160), '') as taraf
                          from public.cek_senet_hareket h
                          left join public.hesap hh on hh.id = h.hesap_id
                          left join public.taraf ht on ht.id = h.taraf_id
                         where h.cek_senet_id = c.id
                         order by h.tarih desc, h.id desc limit 1) sh on true
                 where c.durum in (10, 20, 30, 40, 60)
                   and not (c.durum = 20 and c.vade < @p0::date)
                   and c.sube_id = any(@p1::int[])
                   and (@p2 = 0 or c.tur = @p2)
                   and (@p3 = '' or coalesce(nullif(c.doviz_cinsi, ''), 'TL') = @p3)
                 order by c.vade, c.id
                """, null, [bugun, subeler, t0, pb], o =>
            {
                var durum = (int)o.GetInt16(3);
                var yon = (int)o.GetInt16(2);
                var kesideci = o.GetString(5);
                var cari = o.GetString(6);
                var doviz = o.GetString(18);
                var tutar = o.GetDecimal(17);
                var alisKur = o.GetDecimal(19);
                var yerel = o.GetDecimal(20);
                decimal? bugunKur = o.IsDBNull(21) ? null : o.GetDecimal(21);
                var kurYok = doviz != "TL" && bugunKur is null;
                var tlDeger = doviz == "TL" ? tutar : Math.Round(tutar * (bugunKur ?? alisKur), 2);
                var vadeT = o.GetDateTime(16).Date;
                return new CekSenetEvrak
                {
                    Id = o.GetInt32(0), Tur = o.GetInt16(1), Yon = yon, Durum = durum,
                    SeriNo = o.GetString(4),
                    Kesideci = kesideci.Length > 0 ? kesideci : cari,
                    UcuncuKisi = yon == 1 && kesideci.Length > 0 && cari.Length > 0
                                 && CekSenetAnahtar(kesideci) != CekSenetAnahtar(cari),
                    Cari = cari, CariId = o.IsDBNull(7) ? null : o.GetInt32(7),
                    CiroCari = o.GetString(8).Length > 0 ? o.GetString(8) : (durum == 20 ? o.GetString(27) : ""),
                    Banka = o.GetString(9), BankaSube = o.GetString(10),
                    HesapId = o.IsDBNull(11) ? null : o.GetInt32(11), Hesap = o.GetString(12), HesapDoviz = o.GetString(13),
                    HesapTahmini = o.GetBoolean(14),
                    Tarih = o.GetDateTime(15), Vade = vadeT, KalanGun = (int)(vadeT - bugun).TotalDays,
                    Tutar = tutar, Doviz = doviz, AlisKuru = alisKur, BugunKur = doviz == "TL" ? 1m : bugunKur, KurYok = kurYok,
                    AlisDeger = yerel,
                    Deger = tlMi ? tlDeger : tutar,
                    KurFarki = doviz == "TL" ? 0 : Math.Round(tlDeger - yerel, 2),
                    MakbuzNo = o.GetString(22), GirisIslemNo = o.GetString(23), Aciklama = o.GetString(24),
                    Secilebilir = yon == 1 && durum == 10,
                    DurumAdi = CekSenetDurumAdi(durum),
                    DurumEk = durum switch
                    {
                        30 => o.GetString(12).Length > 0 ? o.GetString(12) : o.GetString(26),
                        40 => o.GetString(26).Length > 0 ? o.GetString(26) : o.GetString(27),
                        60 => o.GetString(25),
                        _ => "",
                    },
                };
            }, iptal);

            // Süzgeç seçenekleri vade / banka süzülmeden önce: seçim listesi daralmasın.
            var bankalar = ham.Select(x => x.Banka).Where(x => x.Length > 0).Distinct()
                .OrderBy(x => x, StringComparer.Create(CekSenetTr, true)).ToList();
            var paralar = await b.ListeAsync("""
                select distinct coalesce(nullif(c.doviz_cinsi, ''), 'TL') from public.cek_senet c
                 where c.durum in (10, 20, 30, 40, 60) and c.sube_id = any(@p0::int[]) order by 1
                """, null, [subeler], o => o.GetString(0), iptal);

            var evraklar = ham.Where(x => (bankaSecim == "" || string.Equals(x.Banka, bankaSecim, StringComparison.CurrentCultureIgnoreCase))
                                       && CekSenetVadeUyar(vadeSecim, x.KalanGun)).ToList();

            // -------------------------------------------------------- evrak geçmişi --
            var idler = evraklar.Select(x => x.Id).ToArray();
            if (idler.Length > 0)
            {
                var hareketler = await b.ListeAsync("""
                    select h.cek_senet_id, h.tarih, h.islem, h.eski_durum, h.yeni_durum,
                           coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''),
                           coalesce(hh.ad, ''), coalesce(h.aciklama, ''), coalesce(ki.islem_no, '')
                      from public.cek_senet_hareket h
                      left join public.taraf t on t.id = h.taraf_id
                      left join public.hesap hh on hh.id = h.hesap_id
                      left join public.kasa_islem ki on ki.id = h.kasa_islem_id
                     where h.cek_senet_id = any(@p0::int[])
                     order by h.cek_senet_id, h.tarih, h.id
                    """, null, [idler], o => (id: o.GetInt32(0), h: new CekSenetHareket
                    {
                        Tarih = o.GetDateTime(1), Islem = o.GetInt16(2), EskiDurum = o.GetInt16(3), YeniDurum = o.GetInt16(4),
                        Cari = o.GetString(5), Hesap = o.GetString(6), Aciklama = o.GetString(7), IslemNo = o.GetString(8),
                    }), iptal);
                var harita = evraklar.ToDictionary(x => x.Id);
                foreach (var g in hareketler.GroupBy(x => x.id))
                    if (harita.TryGetValue(g.Key, out var e))
                        e.Hareketler = g.Select(x => new CekSenetHareket
                        {
                            Tarih = x.h.Tarih, Islem = x.h.Islem, Ad = CekSenetIslemAdi(x.h.Islem, e.Yon),
                            EskiDurum = x.h.EskiDurum, YeniDurum = x.h.YeniDurum, Cari = x.h.Cari, Hesap = x.h.Hesap,
                            Aciklama = x.h.Aciklama, IslemNo = x.h.IslemNo,
                        }).ToList();
            }

            var alinan = evraklar.Where(x => x.Yon == 1).ToList();
            var verilen = evraklar.Where(x => x.Yon == 2).ToList();
            static object Kume(IEnumerable<CekSenetEvrak> l) { var d = l.ToList(); return new { adet = d.Count, tutar = d.Sum(x => x.Deger) }; }

            // --------------------------------------------------------------- özet --
            var portfoy = alinan.Where(x => x.Durum == 10).ToList();
            var tahsilde = alinan.Where(x => x.Durum == 30).ToList();
            var teminat = alinan.Where(x => x.Durum == 40).ToList();
            var ciro = alinan.Where(x => x.Durum == 20).ToList();
            var karsiliksiz = alinan.Where(x => x.Durum == 60).ToList();
            var elde = alinan.Where(x => x.Durum is 10 or 30).ToList();     // vade takvimi "alınan"
            var portfoyTutar = portfoy.Sum(x => x.Deger);
            var ozet = new
            {
                portfoy = new
                {
                    tutar = portfoyTutar, adet = portfoy.Count,
                    ortVade = portfoyTutar > 0 ? (int?)Math.Round(portfoy.Sum(x => x.Deger * x.KalanGun) / portfoyTutar) : null,
                },
                tahsilde = new
                {
                    tutar = tahsilde.Sum(x => x.Deger), adet = tahsilde.Count,
                    hesaplar = tahsilde.GroupBy(x => x.DurumEk.Length > 0 ? x.DurumEk : "(hesap yok)")
                        .Select(g => new { ad = g.Key, adet = g.Count() }).OrderByDescending(x => x.adet).ToList(),
                },
                teminat = new { tutar = teminat.Sum(x => x.Deger), adet = teminat.Count },
                ciro = new { tutar = ciro.Sum(x => x.Deger), adet = ciro.Count },
                gun30 = Kume(elde.Where(x => x.KalanGun is >= 0 and <= 30)),
                gecmis = Kume(portfoy.Where(x => x.KalanGun < 0)),
                karsiliksiz = new
                {
                    tutar = karsiliksiz.Sum(x => x.Deger), adet = karsiliksiz.Count,
                    cek = karsiliksiz.Count(x => x.Tur == 1), senet = karsiliksiz.Count(x => x.Tur == 2),
                },
                verilen = new
                {
                    tutar = verilen.Sum(x => x.Deger), adet = verilen.Count,
                    gun60 = verilen.Count(x => x.KalanGun is >= 0 and <= 60),
                    gecmis = verilen.Count(x => x.KalanGun < 0),
                },
                elde = Kume(alinan.Where(x => x.Durum is 10 or 30 or 40)),
                dovizli = alinan.Count(x => x.Doviz != "TL"),
                kurFarki = alinan.Where(x => x.Doviz != "TL").Sum(x => x.KurFarki),
                kurYok = evraklar.Count(x => x.KurYok),
                ucuncuKisi = Kume(alinan.Where(x => x.UcuncuKisi && x.Durum is 10 or 30 or 40)),
            };
            var toplam = new { alinan = Kume(alinan), verilen = Kume(verilen), ikisi = Kume(evraklar) };

            // ------------------------------------------------------- durum akışı --
            var durumlar = new[]
            {
                new { kod = 10, ad = "Portföyde", adet = portfoy.Count, tutar = portfoyTutar },
                new { kod = 30, ad = "Bankada tahsilde", adet = tahsilde.Count, tutar = tahsilde.Sum(x => x.Deger) },
                new { kod = 40, ad = "Teminatta", adet = teminat.Count, tutar = teminat.Sum(x => x.Deger) },
                new { kod = 20, ad = "Ciro edildi (vadesi gelmemiş)", adet = ciro.Count, tutar = ciro.Sum(x => x.Deger) },
                new { kod = 60, ad = "Karşılıksız / protestolu", adet = karsiliksiz.Count, tutar = karsiliksiz.Sum(x => x.Deger) },
            };

            // Dönem içi hareketler (varsayılan bu ay): hareket defteri, evrakın kayıt TL karşılığıyla.
            var donemHam = await b.ListeAsync("""
                select c.yon, h.islem, count(distinct c.id)::int,
                       coalesce(sum(case when @p4 = '' then c.yerel_tutar else c.tutar end), 0)
                  from public.cek_senet_hareket h
                  join public.cek_senet c on c.id = h.cek_senet_id
                 where h.tarih >= @p0::date and h.tarih <= @p1::date
                   and c.sube_id = any(@p2::int[])
                   and (@p3 = 0 or c.tur = @p3)
                   and (@p4 = '' or coalesce(nullif(c.doviz_cinsi, ''), 'TL') = @p4)
                 group by 1, 2
                """, null, [donemBas, donemBit, subeler, t0, pb],
                o => (yon: (int)o.GetInt16(0), islem: (int)o.GetInt16(1), adet: o.GetInt32(2), tutar: o.GetDecimal(3)), iptal);
            object DonemSatiri(int yon, string ad, params int[] islemler)
            {
                var l = donemHam.Where(x => x.yon == yon && islemler.Contains(x.islem)).ToList();
                return new { ad, islem = islemler[0], adet = l.Sum(x => x.adet), tutar = l.Sum(x => x.tutar) };
            }
            var donem = new
            {
                bas = donemBas, bit = donemBit,
                alinan = new[]
                {
                    DonemSatiri(1, "Alındı (tahsilat)", 130),
                    DonemSatiri(1, "Tahsil edildi (hesaba geçti)", 133),
                    DonemSatiri(1, "Ciro edildi (tedarikçiye)", 131),
                    DonemSatiri(1, "Bankaya tahsile verildi", 132),
                    DonemSatiri(1, "Teminata verildi", 137),
                    DonemSatiri(1, "İade / karşılıksız döndü", 134, 135),
                },
                verilen = new[]
                {
                    DonemSatiri(2, "Verildi (ödeme)", 130),
                    DonemSatiri(2, "Ödendi", 136),
                    DonemSatiri(2, "İade / karşılıksız", 134, 135),
                },
            };

            // ------------------------------------------------------- vade takvimi --
            var dilimler = new List<(string ad, DateTime? bas, DateTime? bit, bool gecmis)>
            {
                ("Vadesi geçmiş", null, bugun.AddDays(-1), true),
                ($"{bugun:dd.MM} – {bugun.AddDays(6):dd.MM}", bugun, bugun.AddDays(6), false),
                ($"{bugun.AddDays(7):dd.MM} – {bugun.AddDays(13):dd.MM}", bugun.AddDays(7), bugun.AddDays(13), false),
            };
            var x0 = bugun.AddDays(14);
            if (x0.Day != 1)
            {
                var ay = new DateTime(x0.Year, x0.Month, 1).AddMonths(1).AddDays(-1);
                dilimler.Add(($"{x0:dd.MM} – {ay:dd.MM}", x0, ay, false));
                x0 = ay.AddDays(1);
            }
            for (var i = 0; i < 2; i++)
            {
                var son = x0.AddMonths(1).AddDays(-1);
                dilimler.Add((CekSenetTr.TextInfo.ToTitleCase(x0.ToString("MMMM yyyy", CekSenetTr)), x0, son, false));
                x0 = son.AddDays(1);
            }
            dilimler.Add((CekSenetTr.TextInfo.ToTitleCase(x0.ToString("MMMM yyyy", CekSenetTr)) + " ve sonrası", x0, null, false));
            bool Icinde(CekSenetEvrak e, DateTime? db, DateTime? ds) => (db is null || e.Vade >= db) && (ds is null || e.Vade <= ds);
            var takvim = dilimler.Select(d =>
            {
                var a = elde.Where(e => Icinde(e, d.bas, d.bit)).ToList();
                var v = verilen.Where(e => Icinde(e, d.bas, d.bit)).ToList();
                return new
                {
                    d.ad, d.bas, d.bit, d.gecmis,
                    alinan = a.Sum(x => x.Deger), alinanAdet = a.Count,
                    verilen = v.Sum(x => x.Deger), verilenAdet = v.Count,
                    net = a.Sum(x => x.Deger) - v.Sum(x => x.Deger),
                };
            }).ToList();
            var takvimToplam = new
            {
                alinan = elde.Sum(x => x.Deger), alinanAdet = elde.Count,
                verilen = verilen.Sum(x => x.Deger), verilenAdet = verilen.Count,
                net = elde.Sum(x => x.Deger) - verilen.Sum(x => x.Deger),
            };

            // ------------------------------------------------- keşideci / banka --
            var riskKume = alinan.Where(x => x.Durum is 10 or 30 or 40).ToList();
            var riskToplam = riskKume.Sum(x => x.Deger);
            var gecmisKarsiliksiz = (await b.ListeAsync("""
                select coalesce(nullif(btrim(c.kesideci), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''),
                       count(*)::int,
                       max(extract(year from coalesce((select max(h.tarih) from public.cek_senet_hareket h
                                                        where h.cek_senet_id = c.id and h.islem = 134), c.vade)))::int
                  from public.cek_senet c
                  left join public.taraf t on t.id = c.taraf_id
                 where c.yon = 1 and c.sube_id = any(@p0::int[])
                   and (c.durum = 60 or exists (select 1 from public.cek_senet_hareket h
                                                 where h.cek_senet_id = c.id and h.islem = 134))
                 group by 1
                """, null, [subeler], o => (ad: o.GetString(0), adet: o.GetInt32(1), yil: o.IsDBNull(2) ? (int?)null : o.GetInt32(2)), iptal))
                .GroupBy(x => CekSenetAnahtar(x.ad))
                .ToDictionary(g => g.Key, g => (adet: g.Sum(x => x.adet), yil: g.Max(x => x.yil)));
            var kesideciler = riskKume.GroupBy(x => CekSenetAnahtar(x.Kesideci)).Select(g =>
            {
                var tutar = g.Sum(x => x.Deger);
                var ks = gecmisKarsiliksiz.TryGetValue(g.Key, out var k) ? k : (adet: 0, yil: (int?)null);
                return new
                {
                    ad = g.First().Kesideci, adet = g.Count(), tutar,
                    pay = riskToplam > 0 ? Math.Round(tutar * 100 / riskToplam, 1) : 0,
                    ucuncuKisi = g.Any(x => x.UcuncuKisi),
                    cariler = g.Select(x => x.Cari).Where(x => x.Length > 0).Distinct().Take(3).ToList(),
                    karsiliksiz = ks.adet, karsiliksizYil = ks.yil,
                };
            }).OrderByDescending(x => x.tutar).ToList();
            var bankaDagilim = riskKume.GroupBy(x => x.Banka.Length > 0 ? x.Banka : "(banka yok / senet)")
                .Select(g => new { ad = g.Key, adet = g.Count(), tutar = g.Sum(x => x.Deger),
                                   pay = riskToplam > 0 ? Math.Round(g.Sum(x => x.Deger) * 100 / riskToplam, 1) : 0 })
                .OrderByDescending(x => x.tutar).ToList();

            // ------------------------------------- verilen: vade günündeki hesap --
            var hesapIdleri = verilen.Where(x => x.HesapId is > 0).Select(x => x.HesapId!.Value).Distinct().ToArray();
            var bakiyeler = hesapIdleri.Length == 0 ? new Dictionary<int, (decimal bakiye, decimal kur)>()
                : (await b.ListeAsync("""
                    select v.hesap_id, v.bakiye,
                           coalesce(public.fn_doviz_kur_getir(coalesce(nullif(v.doviz_cinsi, ''), 'TL'), @p1::date, 2::smallint), 1)
                      from public.v_hesap_bakiye v where v.hesap_id = any(@p0::int[])
                    """, null, [hesapIdleri, bugun], o => (id: o.GetInt32(0), bakiye: o.GetDecimal(1), kur: o.GetDecimal(2)), iptal))
                  .ToDictionary(x => x.id, x => (x.bakiye, x.kur));
            var hesaplar = new List<object>();
            foreach (var g in verilen.Where(x => x.HesapId is > 0).GroupBy(x => x.HesapId!.Value))
            {
                var hd = g.First().HesapDoviz;
                var (bakiye, hkur) = bakiyeler.TryGetValue(g.Key, out var bk) ? bk : (0m, 1m);
                var girisler = tahsilde.Where(x => x.HesapId == g.Key)
                    .Select(x => (x.Vade, tutar: CekSenetHesapParasi(x, hd, hkur))).ToList();
                var birikim = 0m;
                foreach (var e in g.OrderBy(x => x.Vade).ThenBy(x => x.Id))
                {
                    birikim += CekSenetHesapParasi(e, hd, hkur);
                    var giris = girisler.Where(x => x.Vade <= e.Vade).Sum(x => x.tutar);
                    e.VadeBakiye = Math.Round(bakiye + giris - birikim, 2);
                    e.Yetersiz = e.VadeBakiye < 0;
                }
                var l30 = g.Where(x => x.KalanGun <= 30).ToList();
                var odenecek30 = l30.Sum(x => CekSenetHesapParasi(x, hd, hkur));
                var giris30 = girisler.Where(x => x.Vade <= bugun.AddDays(30)).Sum(x => x.tutar);
                hesaplar.Add(new
                {
                    hesapId = g.Key, ad = g.First().Hesap, doviz = hd, tahmini = g.Any(x => x.HesapTahmini),
                    bakiye, odenecek30, adet30 = l30.Count, giris30,
                    odenecekToplam = g.Sum(x => CekSenetHesapParasi(x, hd, hkur)), adet = g.Count(),
                    kalan30 = bakiye + giris30 - odenecek30,
                    yeterli = bakiye + giris30 - odenecek30 >= 0,
                    yetersizEvrak = g.Count(x => x.Yetersiz),
                });
            }
            foreach (var e in verilen.Where(x => x.HesapId is not > 0)) e.Hesapsiz = true;

            return Results.Ok(new
            {
                tarih = bugun, para = pb, tur = t0, vade = vadeSecim, banka = bankaSecim,
                ozet, toplam, durumlar, donem,
                alinan, verilen,
                takvim, takvimToplam,
                kesideciler, bankaDagilim, riskToplam,
                hesaplar, hesapsizVerilen = verilen.Count(x => x.Hesapsiz),
                secim = new { bankalar, paralar },
            });
        });
    }
}
