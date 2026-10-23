using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEK EKSTRE `/api/ekstre` (mockup Ekranlar/ekstre_tek_ekran.html, kullanıcı 23.10.2026:
/// "müşteri/tedarikçi/kasa/banka/pos modülleri tek ekstre listesi kullanabilir mi" →
/// "genel ekstre mockup uygula").
///
/// <para>Beş hesap türü tek uçtan: <c>cari</c> (müşteri / tedarikçi = taraf), <c>kasa</c> K,
/// <c>banka</c> B, <c>pos</c> P, <c>kredi</c> R, <c>kredikarti</c> V (hesap tablosu);
/// <c>hesap</c> türü hesabın kendi türünü bulur (eski /hesap-ekstre?hesapId= yönlendirmesi).
/// Küme Kasa › Cari Ekstre / Hesap Ekstresi listeleriyle AYNI (v_mali_hareket_ek: cari için
/// hesap_turu C + cari_ekstre, hesap için hesap_id + hesap_ekstre), şube süzgeci listedeki
/// gibi. Farkı: dönem başı DEVİR satırı (dönemden önceki hareketlerin toplamı) ve ondan
/// yürüyen bakiye - eski listede bakiye tüm geçmişin kümülatifiydi, devir görünmüyordu.</para>
///
/// <para>Yetki iki katlı: ekran <c>finans.ekstre</c> (1158, kasa.finans'tan kopya), veri
/// seçilen türün kendi kodu (cari: mali_hareket; hesap: hesap.tanim / .banka / .pos /
/// .kredi / .kredi_karti - hesap-ekstre kaynağının satır kısıtıyla aynı). Yanıttaki
/// <c>turler</c> kullanıcının görebildiği türler - ekranın tür seçicisi onları çizer.</para>
/// </summary>
public static class EkstreUclari
{
    private const string Kod = "finans.ekstre";

    /// <summary>tür anahtarı → (hesap.tur harfi, veri yetki kodu). cari'nin harfi 'C' - hesap tablosunda yok.</summary>
    private static readonly (string tur, string harf, string yetki)[] Turler =
    [
        ("cari",       "C", "mali_hareket"),
        ("kasa",       "K", "hesap.tanim"),
        ("banka",      "B", "hesap.tanim.banka"),
        ("pos",        "P", "hesap.tanim.pos"),
        ("kredi",      "R", "hesap.tanim.kredi"),
        ("kredikarti", "V", "hesap.tanim.kredi_karti"),
    ];

    /// <summary>
    /// Ortak küme. @p0 cari mi · @p1 hesap / taraf id · @p2 bit (dahil) · @p3 şube (0 = hepsi).
    /// Cari: karşı taraf = işlemin hesabı (hangi kasa / banka); hesap: karşı = cari.
    /// </summary>
    private const string Kume = """
        select e.id, e.islem_tarihi, e.plan_tarihi, e.tur, coalesce(e.tur_adi, '') as tur_adi, coalesce(e.tur_grup, '') as tur_grup,
               coalesce(e.belge_no, '') as belge_no, coalesce(e.islem_no, '') as islem_no,
               coalesce(e.belge_id, 0) as belge_id, coalesce(e.kasa_islem_id, 0) as kasa_islem_id,
               coalesce(e.aciklama, '') as aciklama,
               coalesce(nullif(e.doviz_cinsi, ''), public.fn_yerel_para()) as doviz_cinsi,
               e.borc, e.alacak, coalesce(e.doviz_kuru, 0) as doviz_kuru, e.yerel_borc, e.yerel_alacak,
               (case when @p0 then coalesce(e.bakiye_dahil, 1) else 1 end)::int as bakiye_dahil,
               case when @p0 then coalesce(e.hesap_adi, '') else coalesce(e.taraf_unvan, '') end as karsi
          from public.v_mali_hareket_ek e
         where ((@p0 and e.hesap_turu = 'C' and e.taraf_id = @p1 and e.cari_ekstre = 1 and e.islem_durum in (1, 2))
             or (not @p0 and e.hesap_id = @p1 and e.hesap_ekstre = 1 and e.islem_durum = 2))
           and e.islem_tarihi < (@p2::date + 1)
           and (@p3 = 0 or e.sube_id = @p3)
        """;

    private sealed record Satir(int Id, DateTime Tarih, DateTime? Vade, int Tur, string TurAdi, string TurGrup,
        string BelgeNo, string IslemNo, int BelgeId, int KasaIslemId, string Aciklama, string Doviz,
        decimal Borc, decimal Alacak, decimal Kur, decimal YerelBorc, decimal YerelAlacak, bool BakiyeDahil, string Karsi);

    private static Satir Oku(Npgsql.NpgsqlDataReader o) => new(o.GetInt32(0), o.GetDateTime(1),
        o.IsDBNull(2) ? null : o.GetDateTime(2), o.GetInt16(3), o.GetString(4), o.GetString(5), o.GetString(6), o.GetString(7),
        o.GetInt32(8), o.GetInt32(9), o.GetString(10), o.GetString(11), o.GetDecimal(12), o.GetDecimal(13), o.GetDecimal(14),
        o.GetDecimal(15), o.GetDecimal(16), o.GetInt32(17) == 1, o.GetString(18));

    public static void EkstreUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ekstre").WithTags("Ekstre").RequireAuthorization();

        // HESAP SEÇİCİ: türün hesapları (cari: ad / kod araması, en çok 30; hesaplar: hepsi).
        grup.MapGet("/hesaplar", async (string tur, string? q, VeriKaynagi veri, BaglamCozucu cozucu,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var t = TurBul(tur);
            baglam.YetkiIste(t.yetki, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ara = "%" + (q ?? "").Trim() + "%";
            if (t.harf == "C")
                return Results.Ok(await b.ListeAsync("""
                    select t.id, coalesce(t.kod, ''), coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                           case when t.musteri = 1 and t.tedarikci = 1 then 'Müşteri · Tedarikçi'
                                when t.tedarikci = 1 then 'Tedarikçi' else 'Müşteri' end, t.durum
                      from public.taraf t
                     where (t.musteri = 1 or t.tedarikci = 1) and t.personel = 0
                       and (cardinality(@p1::int[]) = 0 or t.id = any(@p1::int[]))
                       and (@p0 = '%%' or t.kod ilike @p0 or t.unvan ilike @p0 or (t.ad || ' ' || t.soyad) ilike @p0)
                     order by t.durum desc, 3
                     limit 30
                    """, null, [ara, baglam.Kapsam.ToArray()], HesapOku, iptal));
            return Results.Ok(await b.ListeAsync("""
                select h.id, coalesce(h.kod, ''), h.ad,
                       h.doviz_cinsi || case when h.banka_adi <> '' then ' · ' || h.banka_adi else '' end
                                     || case when h.iban <> '' then ' · ' || right(h.iban, 6) else '' end, h.durum
                  from public.hesap h
                 where h.tur = @p1 and (@p0 = '%%' or h.kod ilike @p0 or h.ad ilike @p0)
                   and (@p2 = 0 or h.sube_id in (0, @p2))
                 order by h.durum desc, h.ad
                """, null, [ara, t.harf, baglam.SubeId ?? 0], HesapOku, iptal));
        });

        grup.MapGet("/", async (string tur, int? id, DateTime? bas, DateTime? bit,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Ekstre portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);

            // Eski /hesap-ekstre?hesapId= yolu: türü hesabın kendisinden.
            if (tur == "hesap")
            {
                var harf = id is > 0 ? await b.TekDegerAsync<string>("select tur from public.hesap where id = @p0", null, [id], iptal) : null;
                tur = Turler.FirstOrDefault(x => x.harf == harf).tur ?? "kasa";
            }
            var t = TurBul(tur);
            var turler = Turler.Where(x => baglam.Yetkiler.Var(x.yetki, Islem.Gor)).Select(x => x.tur).ToArray();
            baglam.YetkiIste(t.yetki, Islem.Gor);

            var bugun = Saat.Bugun.Date;
            var bitis = (bit ?? bugun).Date;
            var baslangic = (bas ?? new DateTime(bitis.Year, 1, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            var cari = t.harf == "C";
            var hesapId = id ?? 0;

            object? hesap = null;
            if (hesapId > 0)
            {
                if (cari)
                {
                    if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(hesapId)) throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
                    hesap = await b.TekAsync("""
                        select t.id, coalesce(t.kod, ''), coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                               t.musteri, t.tedarikci, t.durum, coalesce(tm.vade_gun, 0)::int, coalesce(tm.risk_limiti, 0)::numeric,
                               coalesce(o.vadesi_gecen, 0)::numeric, coalesce(o.bakiye, 0)::numeric, o.son_tahsilat, o.son_satis
                          from public.taraf t
                          left join public.taraf_musteri tm on tm.id = t.id
                          left join public.v_cari_ozet o on o.taraf_id = t.id
                         where t.id = @p0
                        """, null, [hesapId], o => (object)new
                        {
                            id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                            musteri = o.GetInt16(3) == 1, tedarikci = o.GetInt16(4) == 1, durum = o.GetInt16(5),
                            altBilgi = o.GetInt16(3) == 1 && o.GetInt16(4) == 1 ? "Müşteri · Tedarikçi" : o.GetInt16(4) == 1 ? "Tedarikçi" : "Müşteri",
                            vadeGun = o.GetInt32(6), riskLimiti = o.GetDecimal(7), vadesiGecen = o.GetDecimal(8),
                            toplamBakiye = o.GetDecimal(9),
                            sonTahsilat = o.IsDBNull(10) ? null : (DateTime?)o.GetDateTime(10),
                            sonSatis = o.IsDBNull(11) ? null : (DateTime?)o.GetDateTime(11),
                        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
                }
                else
                {
                    hesap = await b.TekAsync("""
                        select h.id, coalesce(h.kod, ''), h.ad, h.doviz_cinsi, h.durum, h.banka_adi, case when h.iban <> '' then '…' || right(h.iban, 6) else '' end,
                               coalesce(h.acilis_bakiye, 0), h.acilis_tarihi, coalesce(bh.ad, ''), h.alt_tur, h.limit_tutar
                          from public.hesap h
                          left join public.hesap bh on bh.id = h.bagli_hesap_id
                         where h.id = @p0 and h.tur = @p1 and (@p2 = 0 or h.sube_id in (0, @p2))
                        """, null, [hesapId, t.harf, baglam.SubeId ?? 0], o => (object)new
                        {
                            id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), doviz = o.GetString(3), durum = o.GetInt16(4),
                            altBilgi = string.Join(" · ", new[] { o.GetString(3), o.GetString(5), o.GetString(6) }.Where(x => x != "")),
                            acilisBakiye = o.GetDecimal(7), acilisTarihi = o.IsDBNull(8) ? null : (DateTime?)o.GetDateTime(8),
                            bagliHesap = o.GetString(9), altTur = o.GetInt16(10), limit = o.GetDecimal(11),
                        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hesap bulunamadı.");
                }
            }

            object?[] p = [cari, hesapId, bitis, baglam.SubeId ?? 0];
            var hepsi = hesapId > 0 ? await b.ListeAsync(Kume + " order by e.islem_tarihi, e.id", null, p, Oku, iptal) : [];

            // PARA BİRİMİ GRUPLARI: önce yerel, sonra alfabetik; devir = dönemden önceki bakiyeye
            //   dahil hareketler; bakiye devirden yürür (dahil olmayan satır bakiyeyi değiştirmez).
            var yerel = await b.TekDegerAsync<string>("select public.fn_yerel_para()", null, [], iptal) ?? "TL";
            var paralar = hepsi.GroupBy(s => s.Doviz)
                .OrderBy(g => g.Key == yerel ? 0 : 1).ThenBy(g => g.Key)
                .Select(g =>
                {
                    var devir = g.Where(s => s.Tarih < baslangic && s.BakiyeDahil).Sum(s => s.Borc - s.Alacak);
                    var devirYerel = g.Where(s => s.Tarih < baslangic && s.BakiyeDahil).Sum(s => s.YerelBorc - s.YerelAlacak);
                    var bakiye = devir; var bakiyeYerel = devirYerel;
                    var satirlar = g.Where(s => s.Tarih >= baslangic).Select(s =>
                    {
                        if (s.BakiyeDahil) { bakiye += s.Borc - s.Alacak; bakiyeYerel += s.YerelBorc - s.YerelAlacak; }
                        return new
                        {
                            s.Id, tarih = s.Tarih, vade = s.Vade, tur = s.Tur, turAdi = s.TurAdi, turGrup = s.TurGrup,
                            belgeNo = s.BelgeNo, islemNo = s.IslemNo, belgeId = s.BelgeId, kasaIslemId = s.KasaIslemId,
                            aciklama = s.Aciklama, karsi = s.Karsi, borc = s.Borc, alacak = s.Alacak, kur = s.Kur,
                            yerelBorc = s.YerelBorc, yerelAlacak = s.YerelAlacak, bakiye, bakiyeYerel, bakiyeDahil = s.BakiyeDahil,
                        };
                    }).ToList();
                    return new
                    {
                        doviz = g.Key, yerelMi = g.Key == yerel, devir, devirYerel,
                        borc = satirlar.Sum(s => s.borc), alacak = satirlar.Sum(s => s.alacak),
                        yerelBorc = satirlar.Sum(s => s.yerelBorc), yerelAlacak = satirlar.Sum(s => s.yerelAlacak),
                        bakiye, bakiyeYerel, adet = satirlar.Count, satirlar,
                    };
                }).ToList();

            var donem = hepsi.Where(s => s.Tarih >= baslangic).ToList();
            var ozet = new
            {
                devirYerel = paralar.Sum(x => x.devirYerel),
                borcYerel = paralar.Sum(x => x.yerelBorc), alacakYerel = paralar.Sum(x => x.yerelAlacak),
                bakiyeYerel = paralar.Sum(x => x.bakiyeYerel),
                adet = donem.Count, borcAdet = donem.Count(s => s.Borc != 0), alacakAdet = donem.Count(s => s.Alacak != 0),
                sonHareket = donem.LastOrDefault()?.Tarih,
                // Cari: son tahsilat = son alacak hareketi (tahsilat / çek); hesap: son giriş / çıkış.
                sonAlacak = donem.LastOrDefault(s => s.Alacak != 0)?.Tarih, sonAlacakTutar = donem.LastOrDefault(s => s.Alacak != 0)?.YerelAlacak ?? 0,
                sonAlacakTur = donem.LastOrDefault(s => s.Alacak != 0)?.TurAdi ?? "",
                sonBorc = donem.LastOrDefault(s => s.Borc != 0)?.Tarih, sonBorcTutar = donem.LastOrDefault(s => s.Borc != 0)?.YerelBorc ?? 0,
                sonBorcTur = donem.LastOrDefault(s => s.Borc != 0)?.TurAdi ?? "",
                // Vadesi geçen (cari, bugün itibarıyla - v_cari_ozet FIFO ile aynı), dönemden bağımsız.
            };

            return Results.Ok(new { tur, harf = t.harf, bas = baslangic, bit = bitis, yerel, turler, hesap, paralar, ozet });
        });
    }

    private static (string tur, string harf, string yetki) TurBul(string? tur)
    {
        var t = Turler.FirstOrDefault(x => x.tur == (tur ?? "").Trim().ToLowerInvariant());
        return t.tur is null ? throw GentegreHatasi.Dogrulama("Bilinmeyen ekstre türü.") : t;
    }

    private static object HesapOku(Npgsql.NpgsqlDataReader o) => new
    {
        id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), altBilgi = o.GetString(3), durum = o.GetInt16(4),
    };
}
