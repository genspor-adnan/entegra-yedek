using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TARAF (hasta / personel) MÜKERRER KONTROLÜ. Kullanıcı kuralı:
///   * KİMLİK NO = ENGEL: aynı kimlik no ile AKTİF kayıt varsa yeni kayıt
///     AÇILMAZ; kullanıcıya "mevcut karta geçilsin mi" sorulur. Diğer kayıt
///     PASİF ise aynı kimlik no ile yeni kayıt eklenebilir.
///   * TELEFON = UYARI · E-POSTA = UYARI: aynı olan aktif kayıt varsa uyarılır;
///     kullanıcı "evet" derse aynı telefon/e-posta ile kayıt eklenebilir
///     (aile bireyleri aynı numarayı/adresi paylaşır).
///
///   GET /api/hasta/mukerrer?rol=hasta|personel&amp;vkno=&amp;cepTel=&amp;eposta=&amp;haric=
///
/// Kimlik engeli sunucuda da uygulanır (<see cref="KimlikMukerrerKuraliAsync"/>):
/// ekran atlasa bile kart ucu aynı kimlikli AKTİF kaydı reddeder. Eşleşme rol
/// içinde kalır (hasta hastayla, personel personelle); cari/hasta/personel aynı
/// kimliği taşıyabilir. Telefon/e-posta son 10 hane / küçük harf ile karşılaştırılır.
/// </summary>
public static class HastaUclari
{
    // Kart adı -> taraf rol kolonu (mükerrer bu rol içinde aranır).
    private static string? RolKolonu(string kartAd) => kartAd switch
    {
        "hasta" or "hasta-aday" => "hasta",
        "personel" or "dis-hekim" => "personel",
        _ => null,
    };
    private static string? RolAdi(string rolKolonu) => rolKolonu switch
    {
        "hasta" => "hasta", "personel" => "personel", _ => null,
    };

    public sealed record MukerrerKayit(int Id, string Ad, string Kod, DateTime? DogumTarihi);
    public sealed record MukerrerYaniti(MukerrerKayit? Kimlik, IReadOnlyList<MukerrerKayit> Telefon,
                                        IReadOnlyList<MukerrerKayit> Eposta);

    // AKTİF kayıtlar (durum = 1): pasif kayıt ne engeller ne uyarır.
    private static string KayitSecimi(string rolKol) => $"""
        select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(t.kod, ''), h.dogum_tarihi
          from public.taraf t left join public.taraf_hasta h on h.id = t.id
         where t.{rolKol} = 1 and coalesce(t.durum, 0) = 1 and (@p1::int is null or t.id <> @p1)
        """;

    public static void HastaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hasta").WithTags("Hasta").RequireAuthorization();

        grup.MapGet("/mukerrer", async (string? rol, string? vkno, string? cepTel, string? eposta,
            int? haric, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var rolKol = (rol == "personel") ? "personel" : "hasta";
            baglam.YetkiIste(rolKol == "personel" ? "personel" : "hasta", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kimlik = await KimlikBulAsync(b, rolKol, vkno, haric, iptal);
            var telefon = await TelefonBulAsync(b, rolKol, cepTel, haric, iptal);
            var epostaL = await EpostaBulAsync(b, rolKol, eposta, haric, iptal);
            return Results.Ok(new MukerrerYaniti(kimlik, telefon, epostaL));
        });

        // KART ÖZETİ (kullanıcı 24.10.2026, mockup Kayıt Kabul/hasta_karti_v5.html): kartın üstündeki
        //   isim bandı ve sayı kutuları tek sorguda. Bakiye cari ekstreyle aynı kural (acikBorc kolonu).
        grup.MapGet("/{id:int}/kart-ozeti", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hasta", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync(KartOzetiSql, null, [id], OzetOku, iptal);
            return o is null ? Results.NotFound() : Results.Ok(o);
        });
    }

    public sealed record HastaKartOzeti(
        DateTime? DogumTarihi, short Cinsiyet, string KanGrubu, short Vefat, string Kurum,
        DateTime? SonBasvuru, string SonBolum, string SonDoktor, int BasvuruSayisi,
        DateTime? SonrakiRandevu, string RandevuBolum, string RandevuHekim,
        decimal Bakiye, int AlerjiSayisi, short AlerjiSiddet, IReadOnlyList<string> Alerjiler,
        int KronikSayisi, IReadOnlyList<string> Kronikler, int IlacSayisi, int BekleyenSonuc,
        DateTime? KayitTarihi);

    // Bekleyen sonuç: son 90 günün istendi / numune / çalışılıyor durumundaki lab istemleri.
    // Kronik: bitmemiş; alerji ve ilaç: aktif. Randevu: şu andan sonraki planlı / ertelenmiş (1, 5).
    // Kayıt: kartın ekleme tarihi ile ilk başvurudan erken olanı (aktarılan hastada ekleme = aktarım günü).
    private const string KartOzetiSql = """
        select h.dogum_tarihi, coalesce(h.cinsiyet, 0)::smallint,
               coalesce((select d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                          where l.kod = 'taraf.kan_grubu' and d.dil = 0 and d.deger = h.kan_grubu limit 1), ''),
               coalesce(h.vefat, 0)::smallint,
               coalesce((select public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120) from public.taraf k where k.id = h.kurum_id), ''),
               sb.belge_tarihi, coalesce(sb.bolum, ''), coalesce(sb.doktor, ''),
               (select count(*)::int from public.belge b where b.taraf_id = t.id and b.tur = 19),
               rn.baslangic, coalesce(rn.bolum, ''), coalesce(rn.hekim, ''),
               (select coalesce(sum(case when e.bakiye_dahil = 1 then e.yerel_borc - e.yerel_alacak else 0 end), 0)
                  from public.v_mali_hareket_ek e
                 where e.taraf_id = t.id and e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.islem_durum in (1, 2)),
               (select count(*)::int from public.hasta_alerji a where a.hasta_id = t.id and a.aktif = 1),
               coalesce((select max(a.siddet) from public.hasta_alerji a where a.hasta_id = t.id and a.aktif = 1), 0)::smallint,
               coalesce((select array_agg(x.etken order by x.siddet desc, x.id) from (
                   select a.id, a.siddet, coalesce(nullif(a.etken, ''), a.etken_madde) etken from public.hasta_alerji a
                    where a.hasta_id = t.id and a.aktif = 1 order by a.siddet desc, a.id limit 3) x), '{}'),
               (select count(*)::int from public.hasta_kronik_tani k where k.hasta_id = t.id and k.bitis is null),
               coalesce((select array_agg(x.ad order by x.id) from (
                   select k.id, coalesce(nullif(k.tani_ad, ''), k.icd_kod) ad from public.hasta_kronik_tani k
                    where k.hasta_id = t.id and k.bitis is null order by k.id limit 3) x), '{}'),
               (select count(*)::int from public.hasta_ilac i where i.hasta_id = t.id and i.aktif = 1),
               (select count(*)::int from public.lab_istem l where l.taraf_id = t.id and l.durum in (1, 2, 3)
                   and l.istem_tarihi > now() - interval '90 days'),
               least(t.ekleme_tarihi, (select min(b.belge_tarihi) from public.belge b where b.taraf_id = t.id and b.tur = 19))
          from public.taraf t
          left join public.taraf_hasta h on h.id = t.id
          left join lateral (
                select b.belge_tarihi, dp.ad bolum, public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) doktor
                  from public.belge b join public.belge_basvuru bb on bb.id = b.id
                  left join public.departman dp on dp.id = bb.bolum_id
                  left join public.taraf p on p.id = bb.personel_id
                 where b.taraf_id = t.id and b.tur = 19 order by b.belge_tarihi desc, b.id desc limit 1) sb on true
          left join lateral (
                select r.baslangic, dp.ad bolum, public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) hekim
                  from public.randevu r
                  left join public.departman dp on dp.id = r.bolum
                  left join public.taraf p on p.id = r.hekim_id
                 where r.hasta_id = t.id and r.durum in (1, 5) and r.baslangic > now()
                 order by r.baslangic limit 1) rn on true
         where t.id = @p0 and t.hasta = 1
        """;

    private static HastaKartOzeti OzetOku(NpgsqlDataReader o) => new(
        o.IsDBNull(0) ? null : o.GetDateTime(0), o.GetInt16(1), o.GetString(2), o.GetInt16(3), o.GetString(4),
        o.IsDBNull(5) ? null : o.GetDateTime(5), o.GetString(6), o.GetString(7), o.GetInt32(8),
        o.IsDBNull(9) ? null : o.GetDateTime(9), o.GetString(10), o.GetString(11),
        o.GetDecimal(12), o.GetInt32(13), o.GetInt16(14), o.GetFieldValue<string[]>(15),
        o.GetInt32(16), o.GetFieldValue<string[]>(17), o.GetInt32(18), o.GetInt32(19),
        o.IsDBNull(20) ? null : o.GetDateTime(20));

    /// <summary>
    /// Kart ucu (ekle / güncelle) SERT KURALI: aynı kimlik numaralı başka bir
    /// AKTİF hasta/personel varsa kayıt yazılmaz. Pasif kayıt engellemez.
    /// </summary>
    public static async Task KimlikMukerrerKuraliAsync(KartTanimi tanim, IDictionary<string, object?> degerler, VeriKaynagi veri, long? haricId, CancellationToken iptal)
    {
        var rolKol = RolKolonu(tanim.Ad);
        if (rolKol is null) return;
        if (!degerler.TryGetValue("vkno", out var v) || string.IsNullOrWhiteSpace(v?.ToString())) return;
        await using var b = await veri.AcAsync(iptal);
        var mevcut = await KimlikBulAsync(b, rolKol, v!.ToString(), haricId is null ? null : (int)haricId, iptal);
        if (mevcut is null) return;
        var ad = RolAdi(rolKol) == "personel" ? "personel" : "hasta";
        throw GentegreHatasi.Dogrulama(
            $"Bu kimlik numarası ile kayıtlı AKTİF {ad} var: {mevcut.Ad} (dosya {mevcut.Kod}, #{mevcut.Id}). "
            + "Yeni kayıt açılmaz - mevcut karta geçin. (Diğer kayıt pasifse aynı kimlikle eklenebilir.)",
            new AlanHatasi("vkno", $"Kayıtlı: {mevcut.Ad} (#{mevcut.Id})"));
    }

    private static async Task<MukerrerKayit?> KimlikBulAsync(NpgsqlConnection b, string rolKol, string? vkno, int? haric, CancellationToken iptal)
    {
        var kimlik = (vkno ?? "").Trim();
        if (kimlik == "") return null;
        return await b.TekAsync(KayitSecimi(rolKol) + " and t.vkno = @p0 order by t.id limit 1", null, [kimlik, haric], Oku, iptal);
    }

    private static async Task<IReadOnlyList<MukerrerKayit>> TelefonBulAsync(NpgsqlConnection b, string rolKol, string? tel, int? haric, CancellationToken iptal)
    {
        var anahtar = TelAnahtar(tel);
        if (anahtar.Length < 7) return [];
        return await b.ListeAsync(KayitSecimi(rolKol) + """
             and (right(regexp_replace(coalesce(t.cep_tel, ''), '\D', '', 'g'), 10) = @p0
               or right(regexp_replace(coalesce(t.telefon, ''), '\D', '', 'g'), 10) = @p0)
            order by t.id limit 5
            """, null, [anahtar, haric], Oku, iptal);
    }

    private static async Task<IReadOnlyList<MukerrerKayit>> EpostaBulAsync(NpgsqlConnection b, string rolKol, string? eposta, int? haric, CancellationToken iptal)
    {
        var e = (eposta ?? "").Trim().ToLowerInvariant();
        if (e.Length < 5 || !e.Contains('@')) return [];
        return await b.ListeAsync(KayitSecimi(rolKol) + " and lower(trim(coalesce(t.eposta, ''))) = @p0 order by t.id limit 5",
            null, [e, haric], Oku, iptal);
    }

    private static MukerrerKayit Oku(NpgsqlDataReader o)
        => new(o.GetInt32(0), o.GetString(1), o.GetString(2), o.IsDBNull(3) ? null : o.GetDateTime(3));

    /// <summary>Rakam dışı atılır, son 10 hane (fn_cagri_tel_anahtar ile aynı kural).</summary>
    private static string TelAnahtar(string? tel)
    {
        var d = new string((tel ?? "").Where(char.IsDigit).ToArray());
        return d.Length > 10 ? d[^10..] : d;
    }
}
