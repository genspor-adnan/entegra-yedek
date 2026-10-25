using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// FİNANS İCMALLERİ `/api/finans-icmal` (kullanıcı 25.10.2026 - mockup Ekranlar/İcmal/
/// tahsilat_odeme_icmali.html, nakit_akis_icmali.html). Çek / Senet İcmali aynı sınıfın
/// ikinci parçasında (FinansIcmalUclari.CekSenet.cs).
///
/// <para><b>Tahsilat / Ödeme</b> `/tahsilat-odeme`: kaynak kasa işleminin KARŞI bacağı
/// (cari ya da gelir / gider kalemi; v_mali_hareket_ek, gerçekleşmiş) - tahsilat 21-26,
/// ödeme 31-36 + 52 (ciro) + 87 (kart ödeme iadesi) + 125. İade ters işaretli (eksi tutar);
/// iptal edilen işlem ve ters kaydı toplama girmez (v_mali_hareket_ek iptal kaynağını,
/// islem_durum 2 iptali dışarıda bırakır). Çekle tahsilat ÇEKİN ALINDIĞI GÜN sayılır
/// (karar 25.10.2026); POS tahsilatı brüt, komisyon ve hesaba geçen Gün / Hesap'ta.
/// Gün / Hesap kasa / banka / POS bacaklarından - Kasa / Gün Sonu ile aynı küme ve aynı
/// virman türleri (40-44). Ortalama tahsil süresi: tahsilat faturaya dağıtılmışsa dağıtım
/// (fatura tarihi → tahsilat), dağıtılmamışsa Cari İcmali'nin FIFO kuralı (karşı yöndeki
/// hareket vadesi en eski kalemi kapatır). Kalan bakiye Cari İcmali ile aynı küme.</para>
///
/// <para><b>Nakit Akış (Vade)</b> `/nakit-akis`: açılış = kasa + banka + POS bugünkü
/// bakiyesi (v_hesap_bakiye - hesap ekstresiyle aynı); giriş = açık satış alacaklarının
/// vadesi (Cari İcmali FIFO, para birimi kendi içinde) - tahsilat planı (61) varsa plan,
/// alınan çek / senet (portföy, tahsilde, teminatta); çıkış = açık borçların vadesi -
/// ödeme planı (71) varsa plan, verilen çek / senet, kredi taksiti (58), kredi kartı
/// borcu (57, son ödeme gününe), maaş (aktif personelin kartındaki aylık net maaş toplamı,
/// ay sonuna - bordro modülü yok). Dövizli kalem BUGÜNKÜ kurla TL (karar 25.10.2026) +
/// döviz pozisyonu. Senaryo (gecikme, gerçekleşme oranı, karşılıksız çek payı, ertele)
/// yalnız görünümdür: bu uç HİÇBİR ŞEY YAZMAZ.</para>
///
/// Rakamlar sunucuda; ekran toplamaz. Şube süzgeci kullanıcının şubeleriyle sınırlı,
/// cari kayıt kapsamı (baglam.Kapsam) uygulanır.
/// </summary>
public static partial class FinansIcmalUclari
{
    /// <summary>Ekran kodları - haklarını kasa.finans'tan kopyalar (Cari İcmali deseni).</summary>
    private const string KodTahsilatOdeme = "finans.tahsilat_odeme_icmali";
    private const string KodNakitAkis = "finans.nakit_akis_icmali";

    private static readonly int[] TahsilatTurleri = [21, 22, 23, 24, 25, 26];
    private static readonly int[] TahsilatOdemeTurleri = [31, 32, 33, 34, 35, 36, 52, 87, 125];
    /// <summary>Kasa / Gün Sonu ile aynı: hesaplar arası aktarım.</summary>
    private static readonly int[] TahsilatTransferTurleri = [40, 41, 42, 43, 44];

    public static void FinansIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/finans-icmal").WithTags("Finans İcmalleri").RequireAuthorization();
        CekSenetUclariniEkle(grup);   // Çek / Senet İcmali (FinansIcmalUclari.CekSenet.cs)

        grup.MapGet("/tahsilat-odeme", async (DateTime? bas, DateTime? bit, string? yon, int? sube, int? kisi, string? para,
                                              int? virman, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
                                              CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodTahsilatOdeme, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await TahsilatHesaplaAsync(b, baglam, bas, bit, yon, sube ?? 0, kisi ?? 0, para,
                (virman ?? 0) == 1, iptal));
        });

        grup.MapGet("/nakit-akis", async (int? ufuk, string? periyot, string? hesaplar, int? sube, int? ilkHafta, int? planli,
                                          int? gecikme, decimal? oran, decimal? karsiliksiz, int? ertele,
                                          VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodNakitAkis, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var secenek = new NakitSecenek(
                ufuk is 30 or 90 or 180 or 365 ? ufuk.Value : 90,
                periyot == "ay" ? "ay" : "hafta",
                (hesaplar ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .Select(x => int.TryParse(x, out var n) ? n : 0).Where(n => n > 0).Distinct().ToArray(),
                sube ?? 0, (ilkHafta ?? 1) == 1, (planli ?? 1) == 1, (gecikme ?? 1) == 1,
                oran is >= 0 and <= 100 ? oran : null,
                karsiliksiz is >= 0 and <= 100 ? karsiliksiz.Value : 5m,
                ertele is >= 0 and <= 90 ? ertele.Value : 0);
            return Results.Ok(await NakitHesaplaAsync(b, baglam, secenek, iptal));
        });
    }

    // =====================================================================================
    //                                    ORTAK
    // =====================================================================================

    private static int[] TahsilatSubeleri(IstekBaglami baglam) => baglam.Subeler.Select(s => s.Id).ToArray();

    /// <summary>Şube seçimi kullanıcının şubelerinden biri olmalı; değilse yok sayılır (tümü).</summary>
    private static int TahsilatSubeSec(int[] subeler, int sube) => sube > 0 && subeler.Contains(sube) ? sube : 0;

    /// <summary>Para birimi kodu (yalnız harf): boş = TL karşılığı.</summary>
    private static string TahsilatParaKodu(string? para)
    {
        var p = (para ?? "").Trim().ToUpperInvariant();
        return p.Length is >= 2 and <= 4 && p.All(char.IsLetter) ? p : "";
    }

    /// <summary>Kişi adı (kullanıcı / temsilci taraf kaydı).</summary>
    private static async Task<Dictionary<int, string>> TahsilatAdlarAsync(NpgsqlConnection b, IEnumerable<int> idler, CancellationToken iptal)
    {
        var dizi = idler.Where(x => x > 0).Distinct().ToArray();
        if (dizi.Length == 0) return new();
        return (await b.ListeAsync("""
            select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') from public.taraf t where t.id = any(@p0::int[])
            """, null, [dizi], o => (id: o.GetInt32(0), ad: o.GetString(1)), iptal)).ToDictionary(x => x.id, x => x.ad);
    }

    /// <summary>
    /// FIFO EŞLEŞMESİ - Cari İcmali'nin kuralı (karşı yöndeki hareket vadesi en eski kalemi
    /// kapatır; vade = hareketin plan tarihi, yoksa işlem + carinin vade günü). Kalemler vade
    /// sırasıyla, ödemeler tarih sırasıyla birikimli dizilir; aralıkların kesişimi eşleşen
    /// tutardır. <paramref name="musteri"/>: kalem = borç (satış), ödeme = alacak (tahsilat);
    /// değilse tersi. @p0 taraflar · @p1 son gün · @p2 bu tarihten itibaren ödemeler.
    /// Çıktı: ödeme bacağı id, taraf, ödeme tarihi, kalem tarihi, kalem vadesi, kalem belge no, tutar.
    /// </summary>
    private static string TahsilatEslesmeSorgusu(bool musteri)
    {
        var kalem = musteri ? "b" : "a";
        var odeme = musteri ? "a" : "b";
        return $"""
            with h as materialized (
                select e.id, e.taraf_id, e.islem_tarihi::date as tarih, coalesce(e.belge_no, '') as belge_no,
                       coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => coalesce(tm.vade_gun, 0)::int))::date as vade,
                       greatest(e.yerel_borc, 0) + greatest(-e.yerel_alacak, 0) as b,
                       greatest(e.yerel_alacak, 0) + greatest(-e.yerel_borc, 0) as a
                  from public.v_mali_hareket_ek e
                  left join public.taraf_musteri tm on tm.id = e.taraf_id
                 where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.bakiye_dahil = 1 and e.islem_durum in (1, 2)
                   and e.taraf_id = any(@p0::int[]) and e.islem_tarihi < @p1::date + 1
            ),
            k as (select taraf_id, tarih, vade, belge_no, {kalem} as t,
                         sum({kalem}) over (partition by taraf_id order by vade, id) as s
                    from h where {kalem} > 0),
            o as (select id, taraf_id, tarih, {odeme} as t,
                         sum({odeme}) over (partition by taraf_id order by tarih, id) as s
                    from h where {odeme} > 0)
            select o.id, o.taraf_id, o.tarih, k.tarih, k.vade, k.belge_no,
                   least(k.s, o.s) - greatest(k.s - k.t, o.s - o.t)
              from o join k on k.taraf_id = o.taraf_id and k.s - k.t < o.s and o.s - o.t < k.s
             where o.tarih >= @p2::date
            """;
    }

    private sealed record TahsilatEslesme(int OdemeId, int TarafId, DateTime OdemeTarihi, DateTime KalemTarihi,
        DateTime KalemVadesi, string BelgeNo, decimal Tutar);

    private static async Task<List<TahsilatEslesme>> TahsilatEslesmeAsync(NpgsqlConnection b, bool musteri, int[] taraflar,
        DateTime son, DateTime itibaren, CancellationToken iptal)
    {
        if (taraflar.Length == 0) return [];
        return await b.ListeAsync(TahsilatEslesmeSorgusu(musteri), null, [taraflar, son, itibaren], o => new TahsilatEslesme(
            o.GetInt32(0), o.GetInt32(1), o.GetDateTime(2), o.GetDateTime(3), o.GetDateTime(4), o.GetString(5), o.GetDecimal(6)), iptal);
    }

    /// <summary>
    /// AÇIK KALEMLER - Cari İcmali'nin FIFO'su (borç kaleminin açık kısmı = min(borç,
    /// max(0, vadeye göre birikimli borç - toplam alacak)); alacak simetrik), para birimi
    /// KENDİ İÇİNDE (taraf × döviz). @p0 son gün · @p1 kayıt kapsamı. Yerel tutar kalemin
    /// kendi kuruyla (yerel / döviz oranı).
    /// </summary>
    private const string TahsilatAcikKalemSorgusu = """
        with tr as materialized (
            select t.id, t.musteri, t.tedarikci, coalesce(tm.vade_gun, 0)::int as vade_gun,
                   coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad
              from public.taraf t
              left join public.taraf_musteri tm on tm.id = t.id
             where (t.musteri = 1 or t.tedarikci = 1) and t.personel = 0
               and (cardinality(@p1::int[]) = 0 or t.id = any(@p1::int[]))
        ),
        h as materialized (
            select e.id, e.taraf_id, coalesce(nullif(e.doviz_cinsi, ''), public.fn_yerel_para()) as doviz,
                   e.borc, e.alacak, e.yerel_borc, e.yerel_alacak, e.belge_id,
                   coalesce(nullif(e.belge_no, ''), nullif(e.islem_no, ''), '') as belge_no, coalesce(e.tur_adi, '') as tur_adi,
                   e.islem_tarihi::date as tarih,
                   coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => tr.vade_gun))::date as vade
              from public.v_mali_hareket_ek e
              join tr on tr.id = e.taraf_id
             where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.bakiye_dahil = 1 and e.islem_durum in (1, 2)
               and e.islem_tarihi < (@p0::date + 1)
        ),
        f as (
            select h.*,
                   sum(h.borc)   over w as bir_borc,  sum(h.alacak) over w as bir_alacak,
                   sum(h.borc)   over p as top_borc,  sum(h.alacak) over p as top_alacak
              from h
            window p as (partition by h.taraf_id, h.doviz),
                   w as (partition by h.taraf_id, h.doviz order by h.vade, h.id)
        ),
        a as (
            select f.*, least(f.borc,   greatest(0, f.bir_borc   - f.top_alacak)) as acik_borc,
                        least(f.alacak, greatest(0, f.bir_alacak - f.top_borc))   as acik_alacak
              from f
        )
        select a.id, a.taraf_id, tr.ad, tr.musteri::int, tr.tedarikci::int, a.doviz, a.tur_adi, a.belge_no,
               coalesce(a.belge_id, 0), a.tarih, a.vade, a.acik_borc, a.acik_alacak,
               case when a.borc <> 0 then a.yerel_borc / a.borc else 1 end,
               case when a.alacak <> 0 then a.yerel_alacak / a.alacak else 1 end
          from a join tr on tr.id = a.taraf_id
         where a.acik_borc > 0.005 or a.acik_alacak > 0.005
        """;

    private sealed record TahsilatAcikKalem(int Id, int TarafId, string Taraf, bool Musteri, bool Tedarikci, string Doviz,
        string TurAdi, string BelgeNo, int BelgeId, DateTime Tarih, DateTime Vade, decimal AcikBorc, decimal AcikAlacak,
        decimal KurBorc, decimal KurAlacak);

    private static Task<List<TahsilatAcikKalem>> TahsilatAcikKalemlerAsync(NpgsqlConnection b, DateTime son, int[] kapsam,
        CancellationToken iptal)
        => b.ListeAsync(TahsilatAcikKalemSorgusu, null, [son, kapsam], o => new TahsilatAcikKalem(
            o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetInt32(3) == 1, o.GetInt32(4) == 1, o.GetString(5), o.GetString(6),
            o.GetString(7), o.GetInt32(8), o.GetDateTime(9), o.GetDateTime(10), o.GetDecimal(11), o.GetDecimal(12),
            o.GetDecimal(13), o.GetDecimal(14)), iptal);

    // =====================================================================================
    //                                TAHSİLAT / ÖDEME
    // =====================================================================================

    private sealed record TahsilatSatiri(int Id, int KasaIslemId, int Tur, int TarafId, DateTime Tarih, string Doviz,
        bool Tahsilat, decimal Yerel, decimal Tutar, string Ad, string Kod, bool Musteri, bool Tedarikci, string BelgeNo,
        string Aciklama, string Hesap, string CekBanka, DateTime? CekVade, int Kisi, bool Avans, bool Aktarim,
        decimal KiTutar, decimal KiYerel, int HesapId);

    /// <summary>Ödeme aracı: anahtar, ad, kısa ad, sıra, A4 grubu.</summary>
    private static (string Anahtar, string Ad, string Kisa, int Sira, string Grup) TahsilatArac(int tur, bool tahsilat) => tahsilat
        ? tur switch
        {
            22 => ("havale", "Havale / EFT", "EFT", 1, "Havale / EFT"),
            25 => ("pos", "Kredi kartı / POS", "POS", 2, "Kredi kartı / POS"),
            23 => ("cek", "Çek", "Çek", 3, "Çek / Senet"),
            24 => ("senet", "Senet", "Senet", 4, "Çek / Senet"),
            21 => ("nakit", "Nakit", "Nakit", 5, "Nakit"),
            26 => ("kupon", "Kupon", "Kupon", 6, "Diğer"),
            _ => ("diger", "Diğer", "Diğer", 9, "Diğer"),
        }
        : tur switch
        {
            32 => ("havale", "Havale / EFT", "EFT", 1, "Havale / EFT"),
            33 => ("cek", "Verilen çek", "Çek", 2, "Çek / Senet"),
            34 => ("senet", "Verilen senet", "Senet", 3, "Çek / Senet"),
            52 => ("ciro", "Ciro edilen çek", "Ciro", 4, "Çek / Senet"),
            35 or 87 => ("kart", "Kredi kartı", "K.Kartı", 5, "Kredi kartı / POS"),
            125 => ("pos", "POS ile ödeme", "POS", 6, "Kredi kartı / POS"),
            31 => ("nakit", "Nakit", "Nakit", 7, "Nakit"),
            36 => ("kupon", "Kupon", "Kupon", 8, "Diğer"),
            _ => ("diger", "Diğer", "Diğer", 9, "Diğer"),
        };

    /// <summary>Gün / Hesap sütunları: ≤ 14 gün gün gün, ≤ 92 gün 7 günlük dilim, üstü ay.</summary>
    private static List<(DateTime Bas, DateTime Bit, string Ad)> TahsilatDonemleri(DateTime bas, DateTime bit)
    {
        var l = new List<(DateTime, DateTime, string)>();
        var gun = (int)(bit - bas).TotalDays + 1;
        if (gun <= 14)
            for (var d = bas; d <= bit; d = d.AddDays(1)) l.Add((d, d, d.ToString("dd.MM")));
        else if (gun <= 92)
        {
            var i = 1;
            for (var d = bas; d <= bit; d = d.AddDays(7), i++)
            {
                var s = d.AddDays(6) > bit ? bit : d.AddDays(6);
                l.Add((d, s, $"{i}. hafta"));
            }
        }
        else
        {
            var d = bas;
            while (d <= bit)
            {
                var ayBas = new DateTime(d.Year, d.Month, 1);
                var s = ayBas.AddMonths(1).AddDays(-1);
                if (s > bit) s = bit;
                l.Add((d, s, d.ToString("MM.yyyy")));
                d = s.AddDays(1);
            }
        }
        return l;
    }

    private static async Task<object> TahsilatHesaplaAsync(NpgsqlConnection b, IstekBaglami baglam, DateTime? bas, DateTime? bit,
        string? yon, int sube, int kisi, string? para, bool virman, CancellationToken iptal)
    {
        var bugun = Saat.Bugun.Date;
        var bitis = (bit ?? bugun).Date;
        var baslangic = (bas ?? new DateTime(bitis.Year, bitis.Month, 1)).Date;
        if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
        if ((bitis - baslangic).TotalDays > 366 * 2) throw GentegreHatasi.Dogrulama("Dönem en çok iki yıl olabilir.");
        var gun = (int)(bitis - baslangic).TotalDays + 1;
        var oncekiBas = baslangic.AddDays(-gun);       // karşılaştırma: aynı uzunlukta önceki dönem
        var subeler = TahsilatSubeleri(baglam);
        var s0 = TahsilatSubeSec(subeler, sube);
        var kapsam = baglam.Kapsam.ToArray();
        var pk = TahsilatParaKodu(para);
        var dovizli = pk != "";
        var yonKod = yon is "tahsilat" or "odeme" ? yon : "ikisi";

        // ---------------------------------------------------------------- hareketler --
        // KARŞI BACAK (cari ya da gelir / gider kalemi; masraf bacağı - POS / havale komisyonu - değil).
        //   Çek / senet tahsilatının para hesabı bacağı yok (portföy) - karşı bacak her türde var.
        var hamSatirlar = await b.ListeAsync("""
            with k as (
                select e.id, coalesce(e.kasa_islem_id, 0) as ki_id, e.tur::int as tur, coalesce(e.taraf_id, 0) as taraf_id,
                       e.islem_tarihi, coalesce(nullif(e.doviz_cinsi, ''), public.fn_yerel_para()) as doviz,
                       (e.tur = any(@p2::int[])) as tahsilat,
                       case when e.tur = any(@p2::int[]) then e.yerel_alacak - e.yerel_borc else e.yerel_borc - e.yerel_alacak end as yerel,
                       case when e.tur = any(@p2::int[]) then e.alacak - e.borc else e.borc - e.alacak end as tutar,
                       e.taraf_unvan, e.masraf_adi, e.aciklama, e.belge_no, e.islem_no,
                       coalesce(ki.cek_senet_id, m.cek_senet_id, m.ceksenet_id) as cek_id,
                       ki.oturum_id, coalesce(nullif(ki.ekleyen, 0), nullif(m.ekleyen, 0), 0) as ekleyen,
                       coalesce(ki.avans, 0)::int as avans, coalesce(ki.aktarim_kaynak, m.aktarim_kaynak, 0)::int as aktarim,
                       ki.tutar as ki_tutar, ki.yerel_tutar as ki_yerel
                  from public.v_mali_hareket_ek e
                  join public.mali_hareket m on m.id = e.id
                  left join public.kasa_islem ki on ki.id = e.kasa_islem_id
                 where e.islem_durum = 2 and (e.tur = any(@p2::int[]) or e.tur = any(@p3::int[]))
                   and e.hesap_turu in ('C', 'M') and coalesce(m.rol, '') <> 'masraf'
                   and e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
                   and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p4::int[]))
                   and (@p5 = 0 or e.sube_id = @p5)
                   and (cardinality(@p6::int[]) = 0 or e.taraf_id = any(@p6::int[]))
                   and (@p7 = '' or e.doviz_cinsi = @p7)
            )
            select k.id, k.ki_id, k.tur, k.taraf_id, k.islem_tarihi::date, k.doviz, k.tahsilat, k.yerel, k.tutar,
                   coalesce(nullif(k.taraf_unvan, ''), k.masraf_adi::text, ''), coalesce(t.kod, ''),
                   coalesce(t.musteri, 0)::int, coalesce(t.tedarikci, 0)::int,
                   coalesce(nullif(k.belge_no, ''), k.islem_no, ''), coalesce(k.aciklama, ''),
                   coalesce(hs.ad, ''), coalesce(cs.banka_adi, ''), cs.vade,
                   case when k.tur = 22 and coalesce(t.temsilci, 0) > 0 then t.temsilci
                        else coalesce(nullif(bo.kullanici_id, 0), k.ekleyen) end,
                   k.avans, k.aktarim, coalesce(k.ki_tutar, 0), coalesce(k.ki_yerel, 0), coalesce(hs.hesap_id, 0)
              from k
              left join public.taraf t on t.id = nullif(k.taraf_id, 0)
              left join public.banko_oturum bo on bo.id = k.oturum_id
              left join public.cek_senet cs on cs.id = k.cek_id
              left join lateral (
                   select a.hesap_id, h.ad from public.mali_hareket a join public.hesap h on h.id = a.hesap_id
                    where k.ki_id > 0 and a.kasa_islem_id = k.ki_id and a.hesap_turu in ('K', 'B', 'P', 'V')
                    order by a.sira limit 1) hs on true
             order by k.islem_tarihi, k.id
            """, null, [oncekiBas, bitis, TahsilatTurleri, TahsilatOdemeTurleri, subeler, s0, kapsam, pk], o => new TahsilatSatiri(
                o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3), o.GetDateTime(4), o.GetString(5), o.GetBoolean(6),
                o.GetDecimal(7), o.GetDecimal(8), o.GetString(9), o.GetString(10), o.GetInt32(11) == 1, o.GetInt32(12) == 1,
                o.GetString(13), o.GetString(14), o.GetString(15), o.GetString(16), o.IsDBNull(17) ? null : o.GetDateTime(17),
                o.IsDBNull(18) ? 0 : o.GetInt32(18), o.GetInt32(19) == 1, o.GetInt32(20) > 0, o.GetDecimal(21), o.GetDecimal(22),
                o.GetInt32(23)), iptal);

        // TAHSİL EDEN SEÇİLİYSE yalnız onun işlemleri (bütün sekmeler).
        var tum = hamSatirlar.Where(x => kisi == 0 || x.Kisi == kisi)
            .Where(x => yonKod == "ikisi" || (yonKod == "tahsilat") == x.Tahsilat).ToList();
        decimal D(TahsilatSatiri x) => dovizli ? x.Tutar : x.Yerel;
        var satirlar = tum.Where(x => x.Tarih.Date >= baslangic).ToList();
        var onceki = tum.Where(x => x.Tarih.Date < baslangic).ToList();
        var tah = satirlar.Where(x => x.Tahsilat).ToList();
        var ode = satirlar.Where(x => !x.Tahsilat).ToList();

        // ------------------------------------------------------------------ dağıtım --
        var kiIdler = tum.Where(x => x.KasaIslemId > 0).Select(x => x.KasaIslemId).Distinct().ToArray();
        Dictionary<int, (decimal Tutar, decimal GunTutar, string Belgeler)> dagitim = kiIdler.Length == 0 ? new()
            : (await b.ListeAsync("""
                select d.kasa_islem_id, sum(d.tutar),
                       sum(d.tutar * greatest(0, ki.islem_tarihi::date - b.belge_tarihi::date)),
                       string_agg(distinct coalesce(nullif(b.belge_no, ''), '#' || b.id), ', ')
                  from public.kasa_islem_dagitim d
                  join public.kasa_islem ki on ki.id = d.kasa_islem_id
                  join public.belge_satir bs on bs.id = d.belge_satir_id
                  join public.belge b on b.id = bs.belge_id
                 where d.kasa_islem_id = any(@p0::int[])
                 group by 1
                """, null, [kiIdler], o => (id: o.GetInt32(0), tutar: o.GetDecimal(1), gunTutar: o.GetDecimal(2), belgeler: o.GetString(3)), iptal))
              .ToDictionary(x => x.id, x => (x.tutar, x.gunTutar, x.belgeler));

        // FIFO (dağıtılmamış işlemler için): müşteri yönü tahsilat, tedarikçi yönü ödeme.
        var tahTaraf = tum.Where(x => x.Tahsilat && x.TarafId > 0).Select(x => x.TarafId).Distinct().ToArray();
        var odeTaraf = tum.Where(x => !x.Tahsilat && x.TarafId > 0).Select(x => x.TarafId).Distinct().ToArray();
        var fifoTah = (await TahsilatEslesmeAsync(b, true, tahTaraf, bitis, oncekiBas, iptal)).ToLookup(x => x.OdemeId);
        var fifoOde = (await TahsilatEslesmeAsync(b, false, odeTaraf, bitis, oncekiBas, iptal)).ToLookup(x => x.OdemeId);

        // İşlemin "fatura → para" ağırlıklı günü: (gün × tutar toplamı, tutar, belgeler).
        (decimal GunTutar, decimal Tutar, string Belgeler) Gun(TahsilatSatiri x)
        {
            if (x.KasaIslemId > 0 && dagitim.TryGetValue(x.KasaIslemId, out var d) && d.Tutar > 0)
                return (d.GunTutar, d.Tutar, d.Belgeler);
            var f = (x.Tahsilat ? fifoTah : fifoOde)[x.Id].ToList();
            if (f.Count == 0) return (0, 0, "");
            return (f.Sum(p => p.Tutar * Math.Max(0, (int)(p.OdemeTarihi - p.KalemTarihi).TotalDays)), f.Sum(p => p.Tutar),
                string.Join(", ", f.Select(p => p.BelgeNo).Where(s => s != "").Distinct().Take(6)));
        }
        int? OrtGun(IEnumerable<TahsilatSatiri> l)
        {
            var g = l.Where(x => D(x) > 0).Select(Gun).ToList();
            var t = g.Sum(x => x.Tutar);
            return t > 0 ? (int)Math.Round(g.Sum(x => x.GunTutar) / t) : null;
        }
        // Dağıtılmamış (yalnız bu sistemde girilmiş, artı tutarlı tahsilat; aktarımla gelen
        //   işlemin dağıtımı yok - ayrı sayılır). Tutar işlemin kendi parasında → yerel oranıyla.
        decimal Dagitilmamis(TahsilatSatiri x)
        {
            if (!x.Tahsilat || x.KasaIslemId == 0 || x.Aktarim || x.KiTutar <= 0) return 0;
            var dagitilan = dagitim.TryGetValue(x.KasaIslemId, out var d) ? d.Tutar : 0;
            var kalan = Math.Max(0, x.KiTutar - dagitilan);
            if (kalan <= 0.005m) return 0;
            return dovizli ? kalan : Math.Round(kalan * (x.KiYerel / x.KiTutar), 2);
        }

        // ------------------------------------------------------------- dönem satışı --
        var faturalar = await b.ListeAsync("""
            select coalesce(e.taraf_id, 0),
                   coalesce(sum(case when @p5 = '' then e.yerel_borc - e.yerel_alacak else e.borc - e.alacak end)
                            filter (where e.tur in (15, 16, 17)), 0),
                   coalesce(sum(case when @p5 = '' then e.yerel_alacak - e.yerel_borc else e.alacak - e.borc end)
                            filter (where e.tur in (11, 12, 13)), 0)
              from public.v_mali_hareket_ek e
             where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.bakiye_dahil = 1 and e.islem_durum in (1, 2)
               and e.tur in (11, 12, 13, 15, 16, 17)
               and e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
               and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p2::int[]))
               and (@p3 = 0 or e.sube_id = @p3)
               and (cardinality(@p4::int[]) = 0 or e.taraf_id = any(@p4::int[]))
               and (@p5 = '' or e.doviz_cinsi = @p5)
             group by 1
            """, null, [baslangic, bitis, subeler, s0, kapsam, pk], o => (taraf: o.GetInt32(0), satis: o.GetDecimal(1), alis: o.GetDecimal(2)), iptal);
        var faturaMap = faturalar.ToDictionary(x => x.taraf);

        // Kalan bakiye: Cari İcmali ile aynı küme (bakiyeye dahil cari hareketleri, bitiş gününe kadar).
        var cariIdler = satirlar.Where(x => x.TarafId > 0).Select(x => x.TarafId).Distinct().ToArray();
        var bakiyeler = cariIdler.Length == 0 ? new Dictionary<int, decimal>()
            : (await b.ListeAsync("""
                select e.taraf_id, sum(case when @p2 = '' then e.yerel_borc - e.yerel_alacak else e.borc - e.alacak end)
                  from public.v_mali_hareket_ek e
                 where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.bakiye_dahil = 1 and e.islem_durum in (1, 2)
                   and e.taraf_id = any(@p0::int[]) and e.islem_tarihi < @p1::date + 1
                   and (@p2 = '' or e.doviz_cinsi = @p2)
                 group by 1
                """, null, [cariIdler, bitis, pk], o => (id: o.GetInt32(0), bakiye: o.GetDecimal(1)), iptal))
              .ToDictionary(x => x.id, x => x.bakiye);

        // ------------------------------------------------------------- ödeme aracı --
        object Araclar(List<TahsilatSatiri> l, bool tahsilatMi)
        {
            var toplam = l.Sum(D);
            return l.GroupBy(x => TahsilatArac(x.Tur, tahsilatMi)).OrderBy(g => g.Key.Sira).Select(g => new
            {
                anahtar = g.Key.Anahtar, ad = g.Key.Ad, islem = g.Count(), tutar = g.Sum(D),
                pay = toplam != 0 ? Math.Round(100 * g.Sum(D) / toplam, 1) : 0m,
                iade = g.Where(x => D(x) < 0).Sum(D),
            }).ToList();
        }
        // AVANS MAHSUBU (bilgi): ön tahsilatın döneme faturalara dağıtılması para hareketi değildir,
        //   tahsilat toplamına girmez (avans alındığı gün kendi aracında sayılmıştır).
        var avansMahsup = await b.TekAsync("""
            select count(distinct d.kasa_islem_id)::int, coalesce(sum(d.tutar), 0)
              from public.kasa_islem_dagitim d
              join public.kasa_islem ki on ki.id = d.kasa_islem_id
             where coalesce(ki.avans, 0) = 1 and ki.durum = 2
               and d.ekleme_tarihi >= @p0::date and d.ekleme_tarihi < @p1::date + 1
               and (coalesce(ki.sube_id, 0) = 0 or ki.sube_id = any(@p2::int[])) and (@p3 = 0 or ki.sube_id = @p3)
               and (cardinality(@p4::int[]) = 0 or ki.taraf_id = any(@p4::int[]))
            """, null, [baslangic, bitis, subeler, s0, kapsam], o => new { islem = o.GetInt32(0), tutar = o.GetDecimal(1) }, iptal);

        // --------------------------------------------------------------- gün / hesap --
        var donemler = TahsilatDonemleri(baslangic, bitis);
        var bacaklar = await b.ListeAsync("""
            select e.hesap_id, coalesce(h.ad, ''), e.hesap_turu, coalesce(nullif(h.doviz_cinsi, ''), public.fn_yerel_para()),
                   e.tur::int, e.islem_tarihi::date,
                   case when @p4 = '' then coalesce(e.yerel_borc, 0) else coalesce(e.borc, 0) end,
                   case when @p4 = '' then coalesce(e.yerel_alacak, 0) else coalesce(e.alacak, 0) end,
                   coalesce(h.komisyon_orani, 0), coalesce(h.valor_gun, 0)::int, coalesce(e.kasa_islem_id, 0),
                   coalesce(h.banka_adi, ''), coalesce(h.iban, '')
              from public.v_mali_hareket_ek e
              join public.hesap h on h.id = e.hesap_id
             where e.hesap_ekstre = 1 and e.islem_durum = 2 and e.hesap_turu in ('K', 'B', 'P')
               and e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
               and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p2::int[]))
               and (@p3 = 0 or e.sube_id = @p3)
               and (@p4 = '' or e.doviz_cinsi = @p4)
            """, null, [baslangic, bitis, subeler, s0, pk], o => (hesap: o.GetInt32(0), ad: o.GetString(1), tur: o.GetString(2),
                doviz: o.GetString(3), islemTur: o.GetInt32(4), tarih: o.GetDateTime(5), borc: o.GetDecimal(6), alacak: o.GetDecimal(7),
                komisyon: o.GetDecimal(8), valor: o.GetInt32(9), ki: o.GetInt32(10), banka: o.GetString(11), iban: o.GetString(12)), iptal);
        int Dilim(DateTime t) => donemler.FindIndex(d => t.Date >= d.Bas && t.Date <= d.Bit);
        // POS → banka aktarımı (44): POS bacağının çıkışı ile banka bacağının girişi arası komisyon.
        var aktarim44 = bacaklar.Where(x => x.islemTur == 44 && x.ki > 0).GroupBy(x => x.ki).Select(g => (
            pos: g.Where(x => x.tur == "P").Select(x => x.hesap).FirstOrDefault(),
            cikan: g.Where(x => x.tur == "P").Sum(x => x.alacak - x.borc),
            gecen: g.Where(x => x.tur == "B").Sum(x => x.borc - x.alacak))).Where(x => x.pos > 0).ToList();
        var hesaplar = bacaklar.GroupBy(x => x.hesap).Select(g =>
        {
            var ilk = g.First();
            var normal = g.Where(x => !TahsilatTransferTurleri.Contains(x.islemTur)).ToList();
            var transfer = g.Where(x => TahsilatTransferTurleri.Contains(x.islemTur)).ToList();
            object? pos = null;
            if (ilk.tur == "P")
            {
                var brut = g.Where(x => x.islemTur == 25).Sum(x => x.borc);
                var komisyonCekim = g.Where(x => x.islemTur == 25).Sum(x => x.alacak);
                var ak = aktarim44.Where(x => x.pos == g.Key).ToList();
                var cikan = ak.Sum(x => x.cikan);
                var gecen = ak.Sum(x => x.gecen);
                var komisyonAktarim = Math.Max(0, cikan - gecen);
                var kayitli = komisyonCekim + komisyonAktarim;
                // Komisyon kaydı yoksa (aktarım yapılmamış) kart oranıyla TAHMİN - ayrı işaretli.
                var tahmini = kayitli == 0 && ilk.komisyon > 0 ? Math.Round(brut * ilk.komisyon / 100, 2) : 0;
                pos = new
                {
                    brut, komisyonCekim, aktarilan = cikan, hesabaGecen = gecen, komisyonAktarim, komisyon = kayitli,
                    tahminiKomisyon = tahmini, oran = ilk.komisyon, valor = ilk.valor,
                    bekleyen = Math.Max(0, brut - komisyonCekim - cikan),
                };
            }
            decimal[] Hucre(IEnumerable<(int hesap, string ad, string tur, string doviz, int islemTur, DateTime tarih, decimal borc,
                decimal alacak, decimal komisyon, int valor, int ki, string banka, string iban)> l)
            {
                var h = new decimal[donemler.Count];
                foreach (var x in l) { var i = Dilim(x.tarih); if (i >= 0) h[i] += x.borc - x.alacak; }
                return h;
            }
            return new
            {
                id = g.Key, ad = ilk.ad, tur = ilk.tur, doviz = ilk.doviz, banka = ilk.banka, iban = ilk.iban,
                hucreler = Hucre(normal), giris = normal.Sum(x => x.borc), cikis = normal.Sum(x => x.alacak),
                net = normal.Sum(x => x.borc - x.alacak),
                transferHucreler = virman ? Hucre(transfer) : Array.Empty<decimal>(),
                transferGiris = virman ? transfer.Sum(x => x.borc) : 0, transferCikis = virman ? transfer.Sum(x => x.alacak) : 0,
                normalVar = normal.Count > 0, pos,
            };
        }).Where(x => x.normalVar || virman).OrderBy(x => x.tur == "B" ? 0 : x.tur == "P" ? 1 : 2).ThenBy(x => x.ad).ToList();

        // Virmanlar (bilgi, kutu işaretliyse): hesaplar arası (çıkan bacak) + cari virman (49).
        object? virmanlar = null;
        if (virman)
        {
            var cariVirman = await b.TekAsync("""
                select count(*)::int, coalesce(sum(case when @p4 = '' then e.yerel_borc else e.borc end), 0)
                  from public.v_mali_hareket_ek e
                 where e.tur = 49 and e.hesap_turu = 'C' and e.islem_durum = 2 and coalesce(e.yerel_borc, 0) > 0
                   and e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
                   and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p2::int[])) and (@p3 = 0 or e.sube_id = @p3)
                   and (@p4 = '' or e.doviz_cinsi = @p4)
                """, null, [baslangic, bitis, subeler, s0, pk], o => new { islem = o.GetInt32(0), tutar = o.GetDecimal(1) }, iptal);
            var turAd = new Dictionary<int, string>
            {
                [40] = "Kasadan kasaya", [41] = "Kasadan bankaya", [42] = "Bankadan kasaya", [43] = "Bankadan bankaya",
                [44] = "POS'tan bankaya",
            };
            var liste = bacaklar.Where(x => TahsilatTransferTurleri.Contains(x.islemTur) && x.alacak > 0)
                .GroupBy(x => x.islemTur).OrderBy(g => g.Key)
                .Select(g => new { tur = g.Key, ad = turAd[g.Key], islem = g.Select(x => x.ki).Distinct().Count(), tutar = g.Sum(x => x.alacak) })
                .ToList();
            if (cariVirman is { islem: > 0 }) liste.Add(new { tur = 49, ad = "Cari virman", islem = cariVirman.islem, tutar = cariVirman.tutar });
            virmanlar = liste;
        }

        // --------------------------------------------------------------- tahsil eden --
        var kisiAdlari = await TahsilatAdlarAsync(b, hamSatirlar.Select(x => x.Kisi), iptal);
        var gunSonu = await b.ListeAsync("""
            select coalesce(o.kullanici_id, 0), coalesce(sum(o.kapanis_fark), 0)
              from public.banko_oturum o
             where o.durum = 4 and o.kapanis_ts >= @p0::date and o.kapanis_ts < @p1::date + 1
               and (coalesce(o.sube_id, 0) = 0 or o.sube_id = any(@p2::int[])) and (@p3 = 0 or o.sube_id = @p3)
             group by 1
            """, null, [baslangic, bitis, subeler, s0], o => (id: o.GetInt32(0), fark: o.GetDecimal(1)), iptal);
        var farkMap = gunSonu.ToDictionary(x => x.id, x => x.fark);
        var kisiler = tah.GroupBy(x => x.Kisi).Select(g => new
        {
            id = g.Key, ad = g.Key > 0 ? kisiAdlari.GetValueOrDefault(g.Key, $"#{g.Key}") : "(atanmamış)",
            islem = g.Count(), tahsilat = g.Sum(D),
            nakit = g.Where(x => x.Tur == 21).Sum(D), pos = g.Where(x => x.Tur == 25).Sum(D),
            havale = g.Where(x => x.Tur == 22).Sum(D), cekSenet = g.Where(x => x.Tur is 23 or 24).Sum(D),
            gunSonuFarki = farkMap.TryGetValue(g.Key, out var f) ? f : (decimal?)null,
        }).OrderByDescending(x => x.tahsilat).ToList();

        // ------------------------------------------------------------------- cariler --
        var cariler = satirlar.GroupBy(x => x.TarafId).Select(g =>
        {
            var ilk = g.First();
            var t = g.Where(x => x.Tahsilat).ToList();
            var o = g.Where(x => !x.Tahsilat).ToList();
            var tahsilat = t.Sum(D); var odeme = o.Sum(D);
            var tur = g.Key == 0 ? "carisiz" : ilk.Musteri && !ilk.Tedarikci ? "musteri" : !ilk.Musteri && ilk.Tedarikci ? "tedarikci"
                : tahsilat >= odeme ? "musteri" : "tedarikci";
            faturaMap.TryGetValue(g.Key, out var fm);
            var fatura = tur == "tedarikci" ? fm.alis : fm.satis;
            var para0 = tur == "tedarikci" ? odeme : tahsilat;
            return new
            {
                id = g.Key, ad = g.Key == 0 ? "(Carisiz - gelir / gider kalemi)" : ilk.Ad, kod = ilk.Kod, tur,
                tahsilat, odeme, islem = g.Count(), donemFatura = fatura,
                tahsilOrani = fatura > 0 ? Math.Round(100 * para0 / fatura, 1) : (decimal?)null,
                ortGun = OrtGun(tur == "tedarikci" ? o : t),
                dagitilmamis = t.Sum(Dagitilmamis),
                bakiye = g.Key > 0 && bakiyeler.TryGetValue(g.Key, out var bk) ? bk : (decimal?)null,
                islemler = g.OrderBy(x => x.Tarih).Take(60).Select(x =>
                {
                    var gn = Gun(x);
                    return new
                    {
                        tarih = x.Tarih, yon = x.Tahsilat ? "tahsilat" : "odeme", arac = TahsilatArac(x.Tur, x.Tahsilat).Kisa,
                        aracAnahtar = TahsilatArac(x.Tur, x.Tahsilat).Anahtar,
                        tutar = D(x), x.BelgeNo, hesap = x.Hesap, cek = x.CekBanka == "" && x.CekVade is null ? "" :
                            $"{x.CekBanka}{(x.CekVade is { } cv ? $" · vade {cv:dd.MM.yyyy}" : "")}",
                        faturalar = gn.Belgeler, dagitimli = x.KasaIslemId > 0 && dagitim.ContainsKey(x.KasaIslemId),
                    };
                }).ToList(),
            };
        }).OrderByDescending(x => x.tahsilat + x.odeme).ToList();

        // ------------------------------------------------------------------- dikkat --
        var acik = await TahsilatAcikKalemlerAsync(b, bitis, kapsam, iptal);
        var acikAlacak = acik.Where(x => x.AcikBorc > 0.005m).GroupBy(x => x.TarafId)
            .ToDictionary(g => g.Key, g => (adet: g.Count(), tutar: g.Sum(x => Math.Round(x.AcikBorc * x.KurBorc, 2))));
        var dagitilmamisListe = tah.Select(x => (x, kalan: Dagitilmamis(x))).Where(y => y.kalan > 0.005m)
            .OrderByDescending(y => y.x.Tarih).ToList();
        var iptaller = await b.ListeAsync("""
            select ters.islem_tarihi::date, coalesce(nullif(ki.taraf_unvan, ''),
                   public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), ki.tur::int,
                   case when @p6 = '' then ki.yerel_tutar else ki.tutar end, coalesce(nullif(ters.aciklama, ''), ki.aciklama, '')
              from public.kasa_islem ki
              join public.kasa_islem ters on ters.id = ki.iptal_islem_id
              left join public.taraf t on t.id = ki.taraf_id
             where ki.durum = 3 and ki.tur = any(@p2::int[])
               and ters.islem_tarihi >= @p0::date and ters.islem_tarihi < @p1::date + 1
               and (coalesce(ki.sube_id, 0) = 0 or ki.sube_id = any(@p3::int[])) and (@p4 = 0 or ki.sube_id = @p4)
               and (cardinality(@p5::int[]) = 0 or ki.taraf_id = any(@p5::int[]))
               and (@p6 = '' or ki.doviz_cinsi = @p6)
             order by ters.islem_tarihi desc limit 100
            """, null, [baslangic, bitis, TahsilatTurleri.Concat(TahsilatOdemeTurleri).ToArray(), subeler, s0, kapsam, pk],
            o => (tarih: o.GetDateTime(0), cari: o.GetString(1), tur: o.GetInt32(2), tutar: o.GetDecimal(3), neden: o.GetString(4)), iptal);
        var iadeIptal = satirlar.Where(x => D(x) < 0).Select(x => new
            {
                tarih = x.Tarih, cari = x.Ad, arac = TahsilatArac(x.Tur, x.Tahsilat).Kisa + " iade", yon = x.Tahsilat ? "tahsilat" : "odeme",
                tutar = D(x), neden = x.Aciklama,
            })
            .Concat(iptaller.Select(x => new
            {
                x.tarih, x.cari, arac = TahsilatArac(x.tur, TahsilatTurleri.Contains(x.tur)).Kisa + " iptal",
                yon = TahsilatTurleri.Contains(x.tur) ? "tahsilat" : "odeme", tutar = -x.tutar, x.neden,
            }))
            .Where(x => yonKod == "ikisi" || x.yon == yonKod)
            .OrderByDescending(x => x.tarih).Take(100).ToList();
        var odemesiz = await b.ListeAsync("""
            select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), x.bakiye, x.son_tahsilat
              from (select e.taraf_id, sum(e.yerel_borc - e.yerel_alacak) as bakiye,
                           max(e.islem_tarihi::date) filter (where e.yerel_alacak > 0 and e.tur not in (11, 12, 13, 15, 16, 17)) as son_tahsilat
                      from public.v_mali_hareket_ek e
                     where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.bakiye_dahil = 1 and e.islem_durum in (1, 2)
                       and e.islem_tarihi < @p1::date + 1
                       and (cardinality(@p2::int[]) = 0 or e.taraf_id = any(@p2::int[]))
                     group by e.taraf_id) x
              join public.taraf t on t.id = x.taraf_id
             where t.musteri = 1 and t.personel = 0 and x.bakiye > 0.005
               and (x.son_tahsilat is null or x.son_tahsilat < @p0::date)
             order by x.bakiye desc limit 50
            """, null, [baslangic, bitis, kapsam], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), bakiye = o.GetDecimal(2),
                sonTahsilat = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
                gun = o.IsDBNull(3) ? (int?)null : (int)(bugun - o.GetDateTime(3).Date).TotalDays,
            }, iptal);
        var gecmisOdeme = acik.Where(x => x.Tedarikci && x.AcikAlacak > 0.005m && x.Vade < bugun)
            .OrderBy(x => x.Vade).Take(50)
            .Select(x => new
            {
                id = x.TarafId, ad = x.Taraf, belgeNo = x.BelgeNo, belgeId = x.BelgeId, vade = x.Vade, gun = (int)(bugun - x.Vade).TotalDays,
                tutar = Math.Round(x.AcikAlacak * x.KurAlacak, 2), doviz = x.Doviz, dovizTutar = x.AcikAlacak,
            }).ToList();

        var dikkat = new
        {
            dagitilmamis = dagitilmamisListe.Take(200).Select(y => new
            {
                tarih = y.x.Tarih, id = y.x.TarafId, cari = y.x.Ad, arac = TahsilatArac(y.x.Tur, true).Kisa, tutar = y.kalan,
                avans = y.x.Avans,
                acikFatura = acikAlacak.TryGetValue(y.x.TarafId, out var af) ? af.adet : 0,
                acikTutar = acikAlacak.TryGetValue(y.x.TarafId, out var at) ? at.tutar : 0,
            }).ToList(),
            dagitilmamisAdet = dagitilmamisListe.Count, dagitilmamisTutar = dagitilmamisListe.Sum(y => y.kalan),
            iadeIptal, odemesiz, gecmisOdeme,
        };

        // --------------------------------------------------------------------- özet --
        var satisToplam = faturalar.Sum(x => x.satis);
        var tahToplam = tah.Sum(D);
        var cekSenet = tah.Where(x => x.Tur is 23 or 24).Sum(D);
        var ozet = new
        {
            tahsilat = tahToplam, tahsilatIslem = tah.Count, tahsilatCari = tah.Where(x => x.TarafId > 0).Select(x => x.TarafId).Distinct().Count(),
            odeme = ode.Sum(D), odemeIslem = ode.Count, odemeCari = ode.Where(x => x.TarafId > 0).Select(x => x.TarafId).Distinct().Count(),
            net = tahToplam - ode.Sum(D),
            satis = satisToplam, alis = faturalar.Sum(x => x.alis),
            tahsilatSatis = satisToplam > 0 ? Math.Round(100 * tahToplam / satisToplam, 1) : (decimal?)null,
            ortTahsilGun = OrtGun(tah), oncekiOrtTahsilGun = OrtGun(onceki.Where(x => x.Tahsilat)),
            ortOdemeGun = OrtGun(ode),
            dagitilmamis = dagitilmamisListe.Sum(y => y.kalan), dagitilmamisAdet = dagitilmamisListe.Count,
            aktarimTahsilat = tah.Count(x => x.Aktarim),
            cekSenet, cekSenetOran = tahToplam > 0 ? Math.Round(100 * cekSenet / tahToplam, 1) : 0m,
            cari = satirlar.Where(x => x.TarafId > 0).Select(x => x.TarafId).Distinct().Count(),
            islem = satirlar.Count, gun,
        };

        // A4: araç grubu × tahsilat / ödeme / net.
        var a4 = satirlar.GroupBy(x => TahsilatArac(x.Tur, x.Tahsilat).Grup)
            .Select(g => new
            {
                arac = g.Key, tahsilat = g.Where(x => x.Tahsilat).Sum(D), odeme = g.Where(x => !x.Tahsilat).Sum(D),
                sira = g.Min(x => TahsilatArac(x.Tur, x.Tahsilat).Sira),
            })
            .OrderBy(x => x.arac == "Diğer" ? 9 : x.sira)
            .Select(x => new { x.arac, x.tahsilat, x.odeme, net = x.tahsilat - x.odeme }).ToList();

        var paralar = await b.ListeAsync("""
            select distinct coalesce(nullif(e.doviz_cinsi, ''), public.fn_yerel_para())
              from public.v_mali_hareket_ek e
             where e.islem_durum = 2 and (e.tur = any(@p2::int[]) or e.tur = any(@p3::int[]))
               and e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
             order by 1
            """, null, [baslangic, bitis, TahsilatTurleri, TahsilatOdemeTurleri], o => o.GetString(0), iptal);

        return new
        {
            bas = baslangic, bit = bitis, yon = yonKod, sube = s0, kisi, para = pk, virman,
            ozet,
            araclar = new { tahsilat = Araclar(tah, true), odeme = Araclar(ode, false), avansMahsup, virmanlar },
            cariler,
            gunHesap = new { donemler = donemler.Select(d => new { bas = d.Bas, bit = d.Bit, ad = d.Ad }).ToList(), hesaplar },
            kisiler, dikkat, a4,
            secim = new
            {
                subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                kisiler = hamSatirlar.Where(x => x.Kisi > 0).Select(x => x.Kisi).Distinct()
                    .Select(id => new { id, ad = kisiAdlari.GetValueOrDefault(id, $"#{id}") }).OrderBy(x => x.ad).ToList(),
                paralar,
            },
            izlemeNo = baglam.IzlemeNo,
        };
    }

    // =====================================================================================
    //                                 NAKİT AKIŞ (VADE)
    // =====================================================================================

    private sealed record NakitSecenek(int Ufuk, string Periyot, int[] Hesaplar, int Sube, bool IlkHafta, bool Planli,
        bool Gecikme, decimal? Oran, decimal Karsiliksiz, int Ertele);

    /// <summary>Akış kalemi. Kolon: fatura · cek · plan (giriş) / tedarikci · verilenCek · planli (çıkış).</summary>
    private sealed record NakitKalem(string Yon, string Kolon, string Kaynak, int TarafId, string Taraf, string Belge,
        int BelgeId, int CekId, DateTime Vade, string Doviz, decimal Tutar, decimal Tl, bool Gecmis, string Esneklik,
        string Guven, int? Gecikme, string Hesap, bool Ucuncu);

    private sealed record NakitSenaryo(bool Gecikme, decimal Oran, decimal Karsiliksiz, int Ertele, decimal EkAcilis);

    private static async Task<object> NakitHesaplaAsync(NpgsqlConnection b, IstekBaglami baglam, NakitSecenek s, CancellationToken iptal)
    {
        var bugun = Saat.Bugun.Date;
        var son = bugun.AddDays(s.Ufuk);
        var subeler = TahsilatSubeleri(baglam);
        var s0 = TahsilatSubeSec(subeler, s.Sube);
        var kapsam = baglam.Kapsam.ToArray();
        var yerel = await b.TekDegerAsync<string>("select public.fn_yerel_para()", null, [], iptal) ?? "TL";

        // ------------------------------------------------------------ hesap bakiyeleri --
        var hesapListesi = await b.ListeAsync("""
            select v.hesap_id, coalesce(v.kod, ''), coalesce(v.ad, ''), v.tur, coalesce(nullif(v.doviz_cinsi, ''), public.fn_yerel_para()),
                   v.bakiye, v.yerel_bakiye, coalesce(h.limit_tutar, 0), coalesce(h.son_odeme_gunu, 0)::int, coalesce(h.banka_adi, '')
              from public.v_hesap_bakiye v
              join public.hesap h on h.id = v.hesap_id
             where v.durum = 1 and v.tur in ('K', 'B', 'P', 'V')
               and (v.sube_id is null or v.sube_id = 0 or v.sube_id = any(@p0::int[])) and (@p1 = 0 or v.sube_id = @p1)
             order by v.tur, v.ad
            """, null, [subeler, s0], o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2), tur: o.GetString(3),
                doviz: o.GetString(4), bakiye: o.GetDecimal(5), yerelBakiye: o.GetDecimal(6), limit: o.GetDecimal(7),
                sonOdemeGunu: o.GetInt32(8), banka: o.GetString(9)), iptal);

        // ---------------------------------------------------------------- açık kalemler --
        var acik = (await TahsilatAcikKalemlerAsync(b, bugun, kapsam, iptal)).Where(x => x.Vade <= son).ToList();
        var planlar = await b.ListeAsync("""
            select ki.id, ki.tur::int, coalesce(ki.taraf_id, 0),
                   coalesce(nullif(ki.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                   ki.plan_tarihi, coalesce(nullif(ki.doviz_cinsi, ''), public.fn_yerel_para()),
                   greatest(ki.tutar - coalesce(ki.gerceklesen_tutar, 0), 0),
                   coalesce(nullif(ki.islem_no, ''), '#' || ki.id), coalesce(ki.aciklama, ''), coalesce(h.ad, ''),
                   coalesce(nullif(ki.doviz_kuru, 0), 1)
              from public.kasa_islem ki
              left join public.taraf t on t.id = ki.taraf_id
              left join public.hesap h on h.id = ki.hesap_id
             where ki.durum = 1 and ki.tur in (61, 71) and ki.plan_tarihi is not null and ki.plan_tarihi <= @p0::date
               and ki.tutar - coalesce(ki.gerceklesen_tutar, 0) > 0.005
               and (coalesce(ki.sube_id, 0) = 0 or ki.sube_id = any(@p1::int[])) and (@p2 = 0 or ki.sube_id = @p2)
               and (cardinality(@p3::int[]) = 0 or ki.taraf_id = any(@p3::int[]))
            """, null, [son, subeler, s0, kapsam], o => (id: o.GetInt32(0), tur: o.GetInt32(1), taraf: o.GetInt32(2), ad: o.GetString(3),
                vade: o.GetDateTime(4), doviz: o.GetString(5), tutar: o.GetDecimal(6), no: o.GetString(7), aciklama: o.GetString(8),
                hesap: o.GetString(9), kur: o.GetDecimal(10)), iptal);
        var cekler = await b.ListeAsync("""
            select c.id, c.yon::int, c.tur::int, coalesce(c.taraf_id, 0),
                   coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(c.kesideci, ''), c.vade,
                   coalesce(nullif(c.doviz_cinsi, ''), public.fn_yerel_para()), c.tutar, coalesce(c.seri_no, ''),
                   coalesce(c.banka_adi, ''), coalesce(h.ad, ''), coalesce(nullif(c.doviz_kuru, 0), 1)
              from public.cek_senet c
              left join public.taraf t on t.id = c.taraf_id
              left join public.hesap h on h.id = c.hesap_id
             where ((c.yon = 1 and c.durum in (10, 30, 40)) or (c.yon = 2 and c.durum not in (0, 50, 60, 70)))
               and c.vade <= @p0::date
               and (coalesce(c.sube_id, 0) = 0 or c.sube_id = any(@p1::int[])) and (@p2 = 0 or c.sube_id = @p2)
               and (cardinality(@p3::int[]) = 0 or c.taraf_id = any(@p3::int[]))
            """, null, [son, subeler, s0, kapsam], o => (id: o.GetInt32(0), yon: o.GetInt32(1), tur: o.GetInt32(2), taraf: o.GetInt32(3),
                ad: o.GetString(4), kesideci: o.GetString(5), vade: o.GetDateTime(6), doviz: o.GetString(7), tutar: o.GetDecimal(8),
                seri: o.GetString(9), banka: o.GetString(10), hesap: o.GetString(11), kur: o.GetDecimal(12)), iptal);
        var taksitler = await b.ListeAsync("""
            select kt.id, kt.vade, kt.toplam - coalesce(kt.odenen, 0), coalesce(nullif(h.doviz_cinsi, ''), public.fn_yerel_para()),
                   coalesce(h.ad, ''), kt.sira::int, (select count(*)::int from public.kredi_taksit x where x.kredi_id = kt.kredi_id),
                   coalesce(bh.ad, '')
              from public.kredi_taksit kt
              join public.hesap h on h.id = kt.kredi_id
              left join public.hesap bh on bh.id = h.bagli_hesap_id
             where kt.durum <> 1 and kt.toplam - coalesce(kt.odenen, 0) > 0.005 and kt.vade <= @p0::date
               and (h.sube_id is null or h.sube_id = 0 or h.sube_id = any(@p1::int[])) and (@p2 = 0 or h.sube_id = @p2)
            """, null, [son, subeler, s0], o => (id: o.GetInt32(0), vade: o.GetDateTime(1), tutar: o.GetDecimal(2), doviz: o.GetString(3),
                kredi: o.GetString(4), sira: o.GetInt32(5), adet: o.GetInt32(6), hesap: o.GetString(7)), iptal);
        var maas = await b.TekAsync("""
            select count(*)::int, coalesce(sum(p.net_maas), 0)
              from public.taraf_personel p
              join public.taraf t on t.id = p.id
             where t.personel = 1 and t.durum = 1 and coalesce(p.net_maas, 0) > 0
               and (p.isten_cikis_tarihi is null or p.isten_cikis_tarihi > @p0::date)
               and (p.sube_id is null or p.sube_id = 0 or p.sube_id = any(@p1::int[])) and (@p2 = 0 or p.sube_id = @p2)
            """, null, [bugun, subeler, s0], o => new { kisi = o.GetInt32(0), tutar = o.GetDecimal(1) }, iptal);

        // ------------------------------------------------------------------- kurlar --
        // PLANLI GİDER (1177): tanımların eşleşmemiş dönemleri - dönem hesabı PlanliGiderMotoru'ndan (tek kaynak).
        var (planliGider, planliGiderTanim) = await Gentegre.Api.Servisler.PlanliGiderMotoru.AkisKalemleriAsync(
            b, subeler, s0, bugun, son, iptal);

        var dovizler = acik.Select(x => x.Doviz).Concat(planlar.Select(x => x.doviz)).Concat(cekler.Select(x => x.doviz))
            .Concat(taksitler.Select(x => x.doviz)).Concat(planliGider.Select(x => x.Doviz)).Concat(hesapListesi.Select(x => x.doviz)).Where(x => x != yerel).Distinct().ToArray();
        var kurlar = dovizler.Length == 0 ? new Dictionary<string, decimal?>()
            : (await b.ListeAsync("""
                select x.c, public.fn_doviz_kur_getir(x.c, @p1::date, 2::smallint) from unnest(@p0::text[]) as x(c)
                """, null, [dovizler, bugun], o => (c: o.GetString(0), k: o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1)), iptal))
              .ToDictionary(x => x.c, x => x.k);
        // KUR YOKSA kalem kendi (geçmiş) kuruyla - kurlar listesinde işaretli.
        decimal Tl(string doviz, decimal tutar, decimal eskiKur)
            => doviz == yerel ? tutar : Math.Round(tutar * (kurlar.GetValueOrDefault(doviz) ?? eskiKur), 2);

        // ----------------------------------------------------- carinin ortalama gecikmesi --
        var gecTaraf = acik.Where(x => x.AcikBorc > 0.005m).Select(x => x.TarafId)
            .Concat(planlar.Where(x => x.tur == 61).Select(x => x.taraf)).Where(x => x > 0).Distinct().ToArray();
        var eslesme = await TahsilatEslesmeAsync(b, true, gecTaraf, bugun, bugun.AddDays(-365), iptal);
        var son6 = eslesme.Where(x => x.OdemeTarihi >= bugun.AddDays(-180)).ToList();
        var gecikmeler = son6.GroupBy(x => x.TarafId).ToDictionary(g => g.Key, g =>
        {
            var t = g.Sum(x => x.Tutar);
            return t > 0 ? (int)Math.Round(g.Sum(x => x.Tutar * (decimal)(x.OdemeTarihi - x.KalemVadesi).TotalDays) / t) : 0;
        });
        var genelT = son6.Sum(x => x.Tutar);
        int? ortGecikme = genelT > 0 ? Math.Max(0, (int)Math.Round(son6.Sum(x => x.Tutar * (decimal)(x.OdemeTarihi - x.KalemVadesi).TotalDays) / genelT)) : null;
        // GERÇEKLEŞME ORANI (geçmiş): vadesi 90-270 gün önce dolan alacak kalemlerinin vadeden sonraki
        //   90 gün içinde tahsil edilen payı.
        var oranHam = gecTaraf.Length == 0 ? null : await b.TekAsync("""
            with h as (
                select e.id, e.taraf_id,
                       coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => coalesce(tm.vade_gun, 0)::int))::date as vade,
                       greatest(e.yerel_borc, 0) + greatest(-e.yerel_alacak, 0) as b
                  from public.v_mali_hareket_ek e
                  left join public.taraf_musteri tm on tm.id = e.taraf_id
                 where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.bakiye_dahil = 1 and e.islem_durum in (1, 2)
                   and e.taraf_id = any(@p0::int[]) and e.islem_tarihi < @p1::date + 1
            )
            select coalesce(sum(b), 0) from h where b > 0 and vade >= @p1::date - 270 and vade < @p1::date - 90
            """, null, [gecTaraf, bugun], o => new { toplam = o.GetDecimal(0) }, iptal);
        var oranToplam = oranHam?.toplam ?? 0;
        var oranTahsil = eslesme.Where(x => x.KalemVadesi >= bugun.AddDays(-270) && x.KalemVadesi < bugun.AddDays(-90)
                                            && x.OdemeTarihi <= x.KalemVadesi.AddDays(90)).Sum(x => x.Tutar);
        decimal? gecmisOran = oranToplam > 0 ? Math.Min(100, Math.Round(100 * oranTahsil / oranToplam, 0)) : null;
        var oran = s.Oran ?? gecmisOran ?? 100m;

        string Guven(int? g) => g is null ? "bilinmiyor" : g <= 7 ? "yüksek" : g <= 30 ? "orta" : "düşük";

        // ------------------------------------------------------------------- kalemler --
        var kalemler = new List<NakitKalem>();
        // Plan varsa plan (karar): carinin açık plan toplamı o carinin en eski açık kalemlerinden düşülür.
        var planDus = planlar.GroupBy(x => (x.taraf, x.doviz, giris: x.tur == 61)).ToDictionary(g => g.Key, g => g.Sum(x => x.tutar));
        foreach (var g in acik.GroupBy(x => (x.TarafId, x.Doviz)))
        {
            var kalanGiris = planDus.GetValueOrDefault((g.Key.TarafId, g.Key.Doviz, true));
            var kalanCikis = planDus.GetValueOrDefault((g.Key.TarafId, g.Key.Doviz, false));
            foreach (var x in g.OrderBy(x => x.Vade).ThenBy(x => x.Id))
            {
                var gec = gecikmeler.TryGetValue(x.TarafId, out var gg) ? Math.Max(0, gg) : (int?)null;
                if (x.AcikBorc > 0.005m)
                {
                    var dus = Math.Min(kalanGiris, x.AcikBorc); kalanGiris -= dus;
                    var t = x.AcikBorc - dus;
                    if (t > 0.005m)
                        kalemler.Add(new NakitKalem("giris", "fatura", x.TurAdi, x.TarafId, x.Taraf, x.BelgeNo, x.BelgeId, 0, x.Vade,
                            x.Doviz, t, Tl(x.Doviz, t, x.KurBorc), x.Vade < bugun, "", Guven(gec), gec, "", false));
                }
                if (x.AcikAlacak > 0.005m)
                {
                    var dus = Math.Min(kalanCikis, x.AcikAlacak); kalanCikis -= dus;
                    var t = x.AcikAlacak - dus;
                    if (t > 0.005m)
                        kalemler.Add(new NakitKalem("cikis", "tedarikci", x.TurAdi, x.TarafId, x.Taraf, x.BelgeNo, x.BelgeId, 0, x.Vade,
                            x.Doviz, t, Tl(x.Doviz, t, x.KurAlacak), x.Vade < bugun, "pazarlik", "", null, "", false));
                }
            }
        }
        foreach (var p in planlar)
        {
            var girisMi = p.tur == 61;
            if (!girisMi && !s.Planli) continue;
            var gec = girisMi && gecikmeler.TryGetValue(p.taraf, out var gg) ? Math.Max(0, gg) : (int?)null;
            kalemler.Add(new NakitKalem(girisMi ? "giris" : "cikis", girisMi ? "plan" : "planli",
                girisMi ? "Tahsilat planı" : "Planlı: ödeme planı", p.taraf, p.ad, p.no, 0, 0, p.vade, p.doviz, p.tutar,
                Tl(p.doviz, p.tutar, p.kur), p.vade < bugun, girisMi ? "" : "pazarlik", girisMi ? Guven(gec) : "", gec,
                p.hesap, false));
        }
        static string Norm(string a) => new string(a.ToUpperInvariant().Where(char.IsLetterOrDigit).ToArray());
        foreach (var c in cekler)
        {
            var ad = c.tur == 2 ? "senet" : "çek";
            if (c.yon == 1)
            {
                // 3. KİŞİ ÇEKİ: keşideci yazılı ve carinin kendisi değil.
                var ucuncu = c.kesideci != "" && Norm(c.kesideci) != Norm(c.ad);
                kalemler.Add(new NakitKalem("giris", "cek", "Alınan " + ad, c.taraf, c.ad,
                    c.seri != "" ? c.seri : $"#{c.id}", 0, c.id, c.vade, c.doviz, c.tutar, Tl(c.doviz, c.tutar, c.kur), c.vade < bugun,
                    "", ucuncu ? "3. kişi çek" : "yüksek", null, c.banka, ucuncu));
            }
            else
                kalemler.Add(new NakitKalem("cikis", "verilenCek", "Verilen " + ad, c.taraf, c.ad,
                    c.seri != "" ? c.seri : $"#{c.id}", 0, c.id, c.vade, c.doviz, c.tutar, Tl(c.doviz, c.tutar, c.kur), c.vade < bugun,
                    "ertelenemez", "", null, c.hesap, false));
        }
        var tanimlar = new List<object>();
        if (s.Planli)
        {
            foreach (var k in taksitler)
                kalemler.Add(new NakitKalem("cikis", "planli", "Planlı: kredi taksiti", 0, k.kredi, $"Taksit {k.sira}/{k.adet}", 0, 0,
                    k.vade, k.doviz, k.tutar, Tl(k.doviz, k.tutar, 1), k.vade < bugun, "ertelenemez", "", null, k.hesap, false));
            // KREDİ KARTI (57): bugünkü borç bir sonraki son ödeme gününe (ekstre kesimi ayrımı yok - yaklaşık).
            foreach (var v in hesapListesi.Where(x => x.tur == "V" && x.bakiye < -0.005m))
            {
                var gunNo = v.sonOdemeGunu is >= 1 and <= 31 ? v.sonOdemeGunu : 0;
                DateTime Gun(DateTime ay) => new(ay.Year, ay.Month, Math.Min(gunNo == 0 ? DateTime.DaysInMonth(ay.Year, ay.Month) : gunNo,
                    DateTime.DaysInMonth(ay.Year, ay.Month)));
                var vade = Gun(bugun);
                if (vade < bugun) vade = Gun(bugun.AddMonths(1));
                if (vade > son) continue;
                var t = -v.bakiye;
                kalemler.Add(new NakitKalem("cikis", "planli", "Planlı: kredi kartı ekstresi", 0, v.ad, "Kart borcu", 0, 0, vade,
                    v.doviz, t, Tl(v.doviz, t, v.bakiye != 0 ? v.yerelBakiye / v.bakiye : 1), false, "ertelenemez", "", null, v.banka, false));
            }
            // PLANLI GİDER (1177): "Planlı: {ad}"; gecikmiş (geçmiş, eşleşmemiş) Etkin'de ilk haftaya düşer;
            //   kredi kartıyla ödenen kalemin günü motor tarafından kartın ekstre son ödeme gününe alınmıştır.
            foreach (var g in planliGider)
                kalemler.Add(new NakitKalem("cikis", "planli", "Planlı: " + g.Ad, g.TarafId, g.Taraf,
                    g.Donem + (g.Tahmini ? " · tahmini" : ""), 0, 0, g.Vade, g.Doviz, g.Tutar, Tl(g.Doviz, g.Tutar, 1), g.Gecmis,
                    g.Esneklik, "", null, g.Hesap, false));
            // MAAŞ: bordro modülü yok - aktif personelin kartındaki aylık net maaş toplamı, her ayın son günü.
            if (maas is { tutar: > 0 })
                for (var ay = new DateTime(bugun.Year, bugun.Month, 1); ay <= son; ay = ay.AddMonths(1))
                {
                    var g = ay.AddMonths(1).AddDays(-1);
                    if (g < bugun || g > son) continue;
                    kalemler.Add(new NakitKalem("cikis", "planli", "Planlı: maaş", 0, $"Personel ({maas.kisi})",
                        $"Maaş {g:MM.yyyy}", 0, 0, g, yerel, maas.tutar, maas.tutar, false, "ertelenemez", "", null, "", false));
                }
        }
        tanimlar.Add(new
        {
            gider = "Maaş", kaynak = maas is { tutar: > 0 } ? $"personel kartlarındaki aylık net maaş toplamı ({maas.kisi} kişi) · her ayın son günü" : "—",
            durum = !s.Planli ? "kapali" : maas is { tutar: > 0 } ? "akista" : "tanimsiz",
        });
        tanimlar.Add(new
        {
            gider = "Kredi taksiti", kaynak = taksitler.Count > 0 ? $"kredi taksit planı (58) · {taksitler.Count} taksit" : "kredi taksit planı (58)",
            durum = !s.Planli ? "kapali" : taksitler.Count > 0 ? "akista" : "tanimsiz",
        });
        tanimlar.Add(new
        {
            gider = "Kredi kartı ekstresi", kaynak = "kart borcu (57) · son ödeme gününe",
            durum = !s.Planli ? "kapali" : hesapListesi.Any(x => x.tur == "V" && x.bakiye < -0.005m) ? "akista" : "tanimsiz",
        });
        tanimlar.Add(new
        {
            gider = "Ödeme planları", kaynak = "ödeme planı (71)",
            durum = !s.Planli ? "kapali" : planlar.Any(x => x.tur == 71) ? "akista" : "tanimsiz",
        });
        tanimlar.Add(new
        {
            gider = "Kira, vergi, SGK, abonelik",
            kaynak = planliGiderTanim > 0 ? $"planlı gider tanımları ({planliGiderTanim} aktif tanım)" : "planlı gider tanımı",
            durum = !s.Planli ? "kapali" : planliGiderTanim > 0 ? "akista" : "tanimsiz",
        });

        // ---------------------------------------------------------------- dönemler --
        var dilimler = new List<(DateTime Bas, DateTime Bit)>();
        if (s.Periyot == "ay")
        {
            var d = new DateTime(bugun.AddDays(1).Year, bugun.AddDays(1).Month, 1);
            while (d <= son) { dilimler.Add((d < bugun ? bugun : d, d.AddMonths(1).AddDays(-1))); d = d.AddMonths(1); }
        }
        else
        {
            var yarin = bugun.AddDays(1);
            var pzt = yarin.AddDays(-(((int)yarin.DayOfWeek + 6) % 7));
            for (var d = pzt; d <= son; d = d.AddDays(7)) dilimler.Add((d < bugun ? bugun : d, d.AddDays(6)));
        }
        int Dilim(DateTime t) => t <= dilimler[0].Bit ? 0 : dilimler.FindIndex(d => t >= d.Bas && t <= d.Bit);

        // Hesap süzgeci yalnız açılışı etkiler (kalemlerin ödeme hesabı çoğunlukla belli değil).
        var nakitHesap = hesapListesi.Where(x => x.tur is "K" or "B" or "P" && (s.Hesaplar.Length == 0 || s.Hesaplar.Contains(x.id))).ToList();
        decimal HesapTl((int id, string kod, string ad, string tur, string doviz, decimal bakiye, decimal yerelBakiye, decimal limit,
            int sonOdemeGunu, string banka) h) => h.doviz == yerel ? h.bakiye : Tl(h.doviz, h.bakiye, h.bakiye != 0 ? h.yerelBakiye / h.bakiye : 1);
        var acilis = nakitHesap.Sum(x => HesapTl(x));
        var kmh = hesapListesi.Where(x => x.tur == "B" && x.limit > 0 && (s.Hesaplar.Length == 0 || s.Hesaplar.Contains(x.id)))
            .Select(x => new { x.ad, limit = x.limit, bosta = Math.Max(0, x.limit - Math.Max(0, -HesapTl(x))) }).ToList();

        (DateTime Tarih, decimal Tl)? Etkin(NakitKalem k, NakitSenaryo sn)
        {
            DateTime t; var tl = k.Tl;
            if (k.Yon == "giris" && k.Kolon != "cek")
            {
                if (k.Gecmis) { if (!s.IlkHafta) return null; t = bugun; tl = Math.Round(tl * sn.Oran / 100, 2); }
                else t = sn.Gecikme && k.Gecikme is > 0 ? k.Vade.AddDays(k.Gecikme.Value) : k.Vade;
            }
            else
            {
                t = k.Vade < bugun ? bugun : k.Vade;
                if (k.Kolon == "cek" && k.Ucuncu) tl = Math.Round(tl * (1 - sn.Karsiliksiz / 100), 2);
                if (k.Esneklik == "pazarlik" && sn.Ertele > 0) t = t.AddDays(sn.Ertele);
            }
            return t > son ? null : (t, tl);
        }

        string[] kolonlar = ["fatura", "cek", "plan", "tedarikci", "verilenCek", "planli"];
        (List<decimal[]> Hucre, decimal[] Acilis, decimal[] Kapanis, int EnDusukIndex, decimal EnDusuk) Akis(NakitSenaryo sn)
        {
            var h = dilimler.Select(_ => new decimal[kolonlar.Length]).ToList();
            foreach (var k in kalemler)
            {
                if (Etkin(k, sn) is not { } e) continue;
                var i = Dilim(e.Tarih);
                if (i < 0) continue;
                h[i][Array.IndexOf(kolonlar, k.Kolon)] += e.Tl;
            }
            var ac = new decimal[dilimler.Count]; var ka = new decimal[dilimler.Count];
            var bak = acilis + sn.EkAcilis; var enI = 0; var en = decimal.MaxValue;
            for (var i = 0; i < dilimler.Count; i++)
            {
                ac[i] = bak;
                bak += h[i][0] + h[i][1] + h[i][2] - h[i][3] - h[i][4] - h[i][5];
                ka[i] = bak;
                if (bak < en) { en = bak; enI = i; }
            }
            return (h, ac, ka, enI, dilimler.Count == 0 ? acilis : en);
        }

        var secili = new NakitSenaryo(s.Gecikme, oran, s.Karsiliksiz, s.Ertele, 0);
        var iyimser = new NakitSenaryo(false, 100, 0, 0, 0);
        var ana = Akis(secili);
        var haftalar = dilimler.Select((d, i) => new
        {
            bas = d.Bas, bit = d.Bit, acilis = ana.Acilis[i],
            fatura = ana.Hucre[i][0], cek = ana.Hucre[i][1], plan = ana.Hucre[i][2], giris = ana.Hucre[i][0] + ana.Hucre[i][1] + ana.Hucre[i][2],
            tedarikci = ana.Hucre[i][3], verilenCek = ana.Hucre[i][4], planli = ana.Hucre[i][5],
            cikis = ana.Hucre[i][3] + ana.Hucre[i][4] + ana.Hucre[i][5], kapanis = ana.Kapanis[i],
            gecmisDahil = i == 0 && s.IlkHafta && kalemler.Any(k => k.Gecmis && k.Yon == "giris"),
        }).ToList();
        decimal Kol(int j) => ana.Hucre.Sum(x => x[j]);
        var kapanisSon = ana.Kapanis.Length > 0 ? ana.Kapanis[^1] : acilis;

        object SenaryoSatiri(string ad, NakitSenaryo sn, bool sec)
        {
            var a = Akis(sn);
            return new
            {
                ad, secili = sec, enDusuk = a.EnDusuk, hafta = dilimler.Count > 0 ? dilimler[a.EnDusukIndex].Bas : bugun,
                sonBakiye = a.Kapanis.Length > 0 ? a.Kapanis[^1] : acilis,
            };
        }
        var kmhToplam = kmh.Sum(x => x.bosta);
        var senaryolar = new List<object>
        {
            SenaryoSatiri("Vadeye göre (iyimser)", iyimser, false),
            SenaryoSatiri("Seçili senaryo", secili, true),
            SenaryoSatiri($"+ tedarikçi ödemeleri {s.Ertele + 15} gün ertelenirse", secili with { Ertele = s.Ertele + 15 }, false),
        };
        if (kmhToplam > 0) senaryolar.Add(SenaryoSatiri("+ KMH kullanılırsa", secili with { EkAcilis = kmhToplam }, false));

        // -------------------------------------------------------------- kalem listeleri --
        object Liste(string yon) => kalemler.Where(k => k.Yon == yon).OrderBy(k => k.Vade).ThenByDescending(k => k.Tl).Take(3000).Select(k =>
        {
            var e = Etkin(k, secili);
            return new
            {
                vade = k.Vade, kolon = k.Kolon, kaynak = k.Kaynak, tarafId = k.TarafId, taraf = k.Taraf, belge = k.Belge, belgeId = k.BelgeId,
                cekId = k.CekId, doviz = k.Doviz, tutar = k.Tutar, tl = k.Tl, gecmis = k.Gecmis, esneklik = k.Esneklik, guven = k.Guven,
                gecikme = k.Gecikme, hesap = k.Hesap, ucuncu = k.Ucuncu,
                beklenen = e?.Tarih, beklenenTl = e?.Tl, akista = e is not null,
            };
        }).ToList();

        // ------------------------------------------------------------- döviz pozisyonu --
        var dovizPozisyonu = kalemler.Where(k => k.Doviz != yerel).GroupBy(k => k.Doviz).OrderBy(g => g.Key).Select(g =>
        {
            var gir = g.Where(k => k.Yon == "giris").Sum(k => k.Tutar);
            var cik = g.Where(k => k.Yon == "cikis").Sum(k => k.Tutar);
            var kur = kurlar.GetValueOrDefault(g.Key);
            return new { doviz = g.Key, girecek = gir, cikacak = cik, acik = gir - cik, kur, kurYok = kur is null,
                         tl = kur is { } kk ? Math.Round((gir - cik) * kk, 2) : (decimal?)null };
        }).ToList();

        var vadesiGecmis = kalemler.Where(k => k.Yon == "giris" && k.Gecmis && k.Kolon != "cek").Sum(k => k.Tl);
        var giris = Kol(0) + Kol(1) + Kol(2);
        var cikis = Kol(3) + Kol(4) + Kol(5);
        var ozet = new
        {
            acilis, kasa = nakitHesap.Where(x => x.tur == "K").Sum(x => HesapTl(x)), banka = nakitHesap.Where(x => x.tur == "B").Sum(x => HesapTl(x)),
            pos = nakitHesap.Where(x => x.tur == "P").Sum(x => HesapTl(x)), hesapAdet = nakitHesap.Count,
            giris, girisFatura = Kol(0), girisCek = Kol(1), girisPlan = Kol(2),
            cikis, cikisTedarikci = Kol(3), cikisCek = Kol(4), cikisPlanli = Kol(5),
            sonBakiye = kapanisSon, fark = kapanisSon - acilis,
            enDusuk = ana.EnDusuk, enDusukBas = dilimler.Count > 0 ? dilimler[ana.EnDusukIndex].Bas : bugun,
            enDusukSira = ana.EnDusukIndex + 1,
            vadesiGecmisAlacak = vadesiGecmis, gecmisOran, oran, ortGecikme,
            kmh = kmhToplam, kmhHesaplar = kmh,
            girisKalem = kalemler.Count(k => k.Yon == "giris"), cikisKalem = kalemler.Count(k => k.Yon == "cikis"),
        };

        return new
        {
            bugun, son, ufuk = s.Ufuk, periyot = s.Periyot, hesaplar = s.Hesaplar, sube = s0, ilkHafta = s.IlkHafta, planli = s.Planli,
            senaryo = new { gecikme = s.Gecikme, oran, gecmisOran, karsiliksiz = s.Karsiliksiz, ertele = s.Ertele },
            ozet, haftalar, senaryolar, doviz = dovizPozisyonu, tanimlar,
            girisler = Liste("giris"), cikislar = Liste("cikis"),
            secim = new
            {
                subeler = baglam.Subeler.Select(x => new { id = x.Id, ad = x.Ad }).ToList(),
                hesaplar = hesapListesi.Where(x => x.tur is "K" or "B" or "P")
                    .Select(x => new { x.id, x.ad, x.tur, x.doviz, bakiye = x.bakiye, tl = HesapTl(x) }).ToList(),
            },
            izlemeNo = baglam.IzlemeNo,
        };
    }
}
