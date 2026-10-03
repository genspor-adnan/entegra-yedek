using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇALIŞMA ŞABLONLARI ve İZİN &amp; İSTİSNALAR LİSTELERİ (mockup
/// <c>Ekranlar/Randevu/calisma_sablonlari_listesi.html</c>, <c>izin_istisnalar_listesi.html</c>).
///
/// Generic liste bu iki ekranın sorusunu cevaplayamıyordu ("kim ne zaman
/// çalışıyor, neresi eksik" / "kim ne zaman yok, hastalara ne oldu"): satır
/// başına doluluk, işlem bekleyen randevu, İK izninin aynı listede görünmesi
/// ve özet şeridi hesap ister. Liste küçük (doktor sayısı kadar) - sayfalama
/// yok, durum çiplerinin sayıları aynı süzgeçten.
///
/// Randevu anları (timestamptz) şubenin duvar saatine çevrilip karşılaştırılır
/// (<see cref="YerelSql"/>, 946 ile aynı kural).
/// </summary>
public static partial class CalismaPlaniUclari
{
    private const int LogSablon = 1170;     // KartKatalogu.CalismaPlani
    private const int LogIstisna = 1171;

    public sealed record SablonTopluIstegi(string Islem, int[] Idler, DateOnly? Bitis, int? HedefHekimId);
    public sealed record IstisnaTopluIstegi(string Islem, int[] Idler);

    private sealed record SablonSatiri(
        int Id, int HekimId, string Hekim, int DepartmanId, string Departman, int? SubeId, string Sube, string Ad,
        string Gunler, string Bas1, string Bit1, string? Bas2, string? Bit2, int SlotDk, string Kanallar,
        int Tekrar, DateOnly GecerliBas, DateOnly? GecerliBit, bool Aktif);

    private static void ListeUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------ şablon listesi ----
        // durum: aktif (varsayılan) · pasif · biten · tumu.
        grup.MapGet("/sablon-liste", async (
            string? durum, int? departmanId, int? subeId, string? ara,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu.plan", Islem.Gor);
            var bugun = DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            await using var b = await veri.AcAsync(iptal);

            var hepsi = await b.ListeAsync("""
                select s.id, s.hekim_id, s.hekim_adi, s.departman_id, coalesce(s.departman_adi, ''), s.sube_id, s.sube_adi,
                       s.ad, s.gunler, s.bas1, s.bit1, nullif(s.bas2, ''), nullif(s.bit2, ''), s.slot_dk, coalesce(s.kanallar, ''),
                       s.tekrar, s.gecerli_bas, s.gecerli_bit, s.aktif
                  from public.v_hekim_calisma_sablon s
                 where (@p0::integer is null or s.departman_id = @p0)
                   and (@p1::integer is null or s.sube_id is null or s.sube_id = @p1)
                   and (@p2::varchar is null or s.hekim_adi ilike '%' || @p2 || '%' or s.departman_adi ilike '%' || @p2 || '%'
                        or s.ad ilike '%' || @p2 || '%')
                 order by s.hekim_adi, s.aktif desc, s.gecerli_bas
                """, null, [departmanId, subeId, string.IsNullOrWhiteSpace(ara) ? null : ara.Trim()],
                o => new SablonSatiri(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetInt32(3), o.GetString(4),
                    o.IsDBNull(5) ? null : o.GetInt32(5), o.GetString(6), o.GetString(7), o.GetString(8), o.GetString(9),
                    o.GetString(10), o.IsDBNull(11) ? null : o.GetString(11), o.IsDBNull(12) ? null : o.GetString(12),
                    o.GetInt16(13), o.GetString(14), o.GetInt16(15), o.GetFieldValue<DateOnly>(16),
                    o.IsDBNull(17) ? null : o.GetFieldValue<DateOnly>(17), o.GetInt16(18) == 1), iptal);

            bool Biten(SablonSatiri s) => s.Aktif && s.GecerliBit is DateOnly e && e < bugun;
            bool Etkin(SablonSatiri s) => s.Aktif && !Biten(s);
            var sayac = new
            {
                aktif = hepsi.Count(Etkin), pasif = hepsi.Count(s => !s.Aktif), biten = hepsi.Count(Biten), tumu = hepsi.Count,
            };
            var secili = (durum ?? "aktif") switch
            {
                "pasif" => hepsi.Where(s => !s.Aktif).ToList(),
                "biten" => hepsi.Where(Biten).ToList(),
                "tumu" => hepsi,
                _ => hepsi.Where(Etkin).ToList(),
            };

            // 2 HAFTA DOLULUK: şablonun bloklarına düşen planlı randevular / slot.
            var hekimler = hepsi.Where(Etkin).Select(s => s.HekimId).Distinct().ToArray();
            var randevular = hekimler.Length == 0 ? [] : await b.ListeAsync($"""
                select r.hekim_id, {YerelSql}, r.sure_dk
                  from public.randevu r
                 where r.hekim_id = any(@p0) and r.durum in (1, 2)
                   and {YerelSql}::date between @p1 and @p2
                """, null, [hekimler, bugun, bugun.AddDays(13)],
                o => (hekim: o.GetInt32(0), bas: o.GetDateTime(1), sure: (int)o.GetInt16(2)), iptal);

            SablonEtkiIstegi Taslak(SablonSatiri s) => new(s.Id, s.HekimId, s.DepartmanId, s.Gunler, s.Bas1, s.Bit1,
                s.Bas2, s.Bit2, s.SlotDk, s.Tekrar, s.GecerliBas, s.GecerliBit);
            int doluluk(SablonSatiri s, out int kapasite)
            {
                var t = Taslak(s); var slot = Math.Max(s.SlotDk, 1); int dolu = 0; kapasite = 0;
                for (var g = bugun; g < bugun.AddDays(14); g = g.AddDays(1))
                {
                    var bl = SablonBloklari(t, g);
                    if (bl.Count == 0) continue;
                    kapasite += bl.Sum(x => (x.Bit - x.Bas) / slot);
                    foreach (var r in randevular.Where(r => r.hekim == s.HekimId && DateOnly.FromDateTime(r.bas) == g))
                    {
                        var bas = r.bas.Hour * 60 + r.bas.Minute;
                        if (Icinde(bl, bas, bas + Math.Max(r.sure, 1))) dolu += (int)Math.Ceiling(Math.Max(r.sure, 1) / (double)slot);
                    }
                }
                return kapasite == 0 ? 0 : (int)Math.Round(100.0 * dolu / kapasite);
            }

            // ÇAKIŞMA: eski veride (945 öncesi) aynı saate iki aktif şablon kalmış olabilir.
            var cakisan = (await b.ListeAsync("""
                select distinct a.id
                  from public.hekim_calisma_sablon a
                  join public.hekim_calisma_sablon x on x.hekim_id = a.hekim_id and x.id <> a.id and x.aktif = 1
                 where a.aktif = 1
                   and string_to_array(replace(a.gunler, ' ', ''), ',') && string_to_array(replace(x.gunler, ' ', ''), ',')
                   and daterange(a.gecerli_bas, coalesce(a.gecerli_bit, 'infinity'::date), '[]')
                       && daterange(x.gecerli_bas, coalesce(x.gecerli_bit, 'infinity'::date), '[]')
                   and exists (select 1
                                 from (values (a.bas1, a.bit1), (nullif(a.bas2, ''), nullif(a.bit2, ''))) p(b, e),
                                      (values (x.bas1, x.bit1), (nullif(x.bas2, ''), nullif(x.bit2, ''))) q(b, e)
                                where p.b is not null and q.b is not null and p.b < q.e and q.b < p.e)
                """, null, [], o => o.GetInt32(0), iptal)).ToHashSet();

            int haftalikSlot = 0, toplamKap = 0, toplamDoluYuzde = 0, sayilan = 0;
            var satirlar = secili.Select(s =>
            {
                var d = Etkin(s) ? doluluk(s, out var kap) : 0;
                return new
                {
                    s.Id, s.HekimId, hekim = s.Hekim, s.DepartmanId, departman = s.Departman, s.SubeId, sube = s.Sube, ad = s.Ad,
                    gunler = s.Gunler, s.Bas1, s.Bit1, s.Bas2, s.Bit2, s.SlotDk, kanallar = s.Kanallar, s.Tekrar,
                    s.GecerliBas, s.GecerliBit, s.Aktif, biten = Biten(s), doluluk = Etkin(s) ? d : (int?)null,
                    cakisma = cakisan.Contains(s.Id),
                };
            }).ToList();
            foreach (var s in hepsi.Where(Etkin))
            {
                var gunSay = s.Gunler.Split(',').Count(x => int.TryParse(x.Trim(), out var g) && g is >= 1 and <= 7);
                var gunSlot = SablonBloklari(Taslak(s) with { GecerliBas = DateOnly.MinValue, GecerliBit = null, Tekrar = 1, Gunler = "1" },
                                             new DateOnly(2024, 1, 1)).Sum(x => (x.Bit - x.Bas) / Math.Max(s.SlotDk, 1));   // 01.01.2024 Pazartesi
                haftalikSlot += gunSlot * gunSay / (s.Tekrar == 2 ? 2 : 1);
                var dy = doluluk(s, out var kap);
                if (kap > 0) { toplamKap += kap; toplamDoluYuzde += dy * kap; sayilan++; }
            }

            // ŞABLONU OLMAYAN DOKTOR: ünvanı Dr. olan ya da geçmişte şablonu olmuş aktif
            //   personel - randevu ve başvuru listelerinde görünmez (fn_hekim_planli).
            var sablonsuz = await b.ListeAsync("""
                select t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                       coalesce((select d.ad from public.departman d where d.id = t.departman), ''), coalesce(t.departman::integer, 0)
                  from public.taraf t
                 where t.personel = 1 and coalesce(t.durum, 1) = 1
                   and (t.unvan ilike '%dr%' or exists (select 1 from public.hekim_calisma_sablon s where s.hekim_id = t.id))
                   and not exists (select 1 from public.hekim_calisma_sablon s where s.hekim_id = t.id and s.aktif = 1
                                    and (s.gecerli_bit is null or s.gecerli_bit >= current_date))
                 order by 2
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1), departman = o.GetString(2), departmanId = o.GetInt32(3) }, iptal);
            var bitecek = hepsi.Where(s => Etkin(s) && s.GecerliBit is DateOnly e && e <= bugun.AddDays(30))
                               .Select(s => new { s.Id, s.Ad, hekim = s.Hekim, s.GecerliBit }).ToList();

            return Results.Ok(new
            {
                satirlar, sayac,
                ozet = new
                {
                    aktifSablon = sayac.aktif,
                    doktor = hepsi.Where(Etkin).Select(s => s.HekimId).Distinct().Count(),
                    bolum = hepsi.Where(Etkin).Select(s => s.DepartmanId).Distinct().Count(),
                    haftalikSlot,
                    doluluk = toplamKap == 0 ? 0 : (int)Math.Round((double)toplamDoluYuzde / toplamKap),
                    sablonsuz, bitecek,
                },
            });
        });

        // ------------------------------------------- şablon toplu işlem ----
        // pasif · bitis (gecerli_bit) · kopyala (başka doktora, aynı düzen).
        grup.MapPost("/sablon-toplu", async (SablonTopluIstegi istek, VeriKaynagi veri, LogDeposu log,
                                             BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var islemAdi = (istek.Islem ?? "").Trim().ToLowerInvariant();
            baglam.YetkiIste("randevu.plan", islemAdi == "kopyala" ? Islem.Ekle : Islem.Degistir);
            if (islemAdi is not ("pasif" or "bitis" or "kopyala")) throw GentegreHatasi.Dogrulama("Bilinmeyen işlem.");
            if (istek.Idler is not { Length: > 0 }) throw GentegreHatasi.Dogrulama("Şablon seçilmedi.");
            if (islemAdi == "bitis" && istek.Bitis is null) throw GentegreHatasi.Dogrulama("Bitiş tarihi girilmeli.");
            if (islemAdi == "kopyala" && istek.HedefHekimId is not > 0) throw GentegreHatasi.Dogrulama("Kopyalanacak doktor seçilmeli.");

            var sonuc = new List<object>();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var id in istek.Idler.Distinct().Take(200))
            {
                var s = await b.TekAsync("select ad, aktif, gecerli_bas, gecerli_bit, hekim_id from public.hekim_calisma_sablon where id = @p0",
                    islem, [id], o => new { ad = o.GetString(0), aktif = o.GetInt16(1), bas = o.GetFieldValue<DateOnly>(2),
                        bit = o.IsDBNull(3) ? (DateOnly?)null : o.GetFieldValue<DateOnly>(3), hekim = o.GetInt32(4) }, iptal);
                if (s is null) { sonuc.Add(new { id, basarili = false, mesaj = "Şablon bulunamadı." }); continue; }
                await islem.SaveAsync("satir", iptal);
                try
                {
                    if (islemAdi == "pasif")
                    {
                        if (s.aktif == 0) { sonuc.Add(new { id, basarili = true, mesaj = "Zaten pasif." }); continue; }
                        await b.CalistirAsync("update public.hekim_calisma_sablon set aktif = 0, degistiren = @p1, degistirme_tarihi = now() where id = @p0",
                            islem, [id, baglam.KullaniciId], iptal);
                        await log.YazAsync(b, islem, LogIslemi.Degistir, LogSablon, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                            new Dictionary<string, string> { ["aktif"] = "1 -> 0" }, iptal: iptal);
                        sonuc.Add(new { id, basarili = true, mesaj = "Pasife alındı." });
                    }
                    else if (islemAdi == "bitis")
                    {
                        var yeni = istek.Bitis!.Value;
                        if (yeni < s.bas) { sonuc.Add(new { id, basarili = false, mesaj = "Bitiş başlangıçtan önce olamaz." }); continue; }
                        if (s.bit == yeni) { sonuc.Add(new { id, basarili = true, mesaj = "Değişiklik yok." }); continue; }
                        await b.CalistirAsync("update public.hekim_calisma_sablon set gecerli_bit = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                            islem, [id, yeni, baglam.KullaniciId], iptal);
                        await log.YazAsync(b, islem, LogIslemi.Degistir, LogSablon, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                            new Dictionary<string, string> { ["gecerli_bit"] = $"{s.bit?.ToString("yyyy-MM-dd") ?? ""} -> {yeni:yyyy-MM-dd}" }, iptal: iptal);
                        sonuc.Add(new { id, basarili = true, mesaj = $"Bitiş {yeni:dd.MM.yyyy}." });
                    }
                    else
                    {
                        if (s.hekim == istek.HedefHekimId) { sonuc.Add(new { id, basarili = false, mesaj = "Aynı doktor." }); continue; }
                        var yeniId = await b.TekDegerAsync<int>("""
                            insert into public.hekim_calisma_sablon
                                   (sube_id, hekim_id, departman_id, ad, gunler, bas1, bit1, bas2, bit2, slot_dk, kanallar,
                                    gunluk_kota, portal_yuzde, kontrol_yuzde, tekrar, gecerli_bas, gecerli_bit, aktif, aciklama, ekleyen)
                            select sube_id, @p1, departman_id, ad, gunler, bas1, bit1, bas2, bit2, slot_dk, kanallar,
                                   gunluk_kota, portal_yuzde, kontrol_yuzde, tekrar, greatest(gecerli_bas, current_date), gecerli_bit, 1,
                                   left('Kopya: #' || id || case when aciklama <> '' then ' · ' || aciklama else '' end, 300), @p2
                              from public.hekim_calisma_sablon where id = @p0
                            returning id
                            """, islem, [id, istek.HedefHekimId, baglam.KullaniciId], iptal);
                        await log.YazAsync(b, islem, LogIslemi.Ekle, LogSablon, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                            new { kopya = id, hekim_id = istek.HedefHekimId }, iptal: iptal);
                        sonuc.Add(new { id, basarili = true, mesaj = $"Kopyalandı (#{yeniId})." });
                    }
                }
                catch (PostgresException h)
                {
                    // 945 çakışma kuralı vb.: satır geri alınır, sıradakine geçilir.
                    await islem.RollbackAsync("satir", iptal);
                    sonuc.Add(new { id, basarili = false, mesaj = h.MessageText });
                }
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { sonuc });
        });

        // ---------------------------------------------- istisna listesi ----
        // durum: 0 bekliyor (varsayılan) · 1 onaylı · 2 iptal · tumu.
        // tur: 1-5 ya da "ik". İK izni (personel_izin, onaylı) salt okunur satır.
        grup.MapGet("/istisna-liste", async (
            string? durum, string? tur, DateOnly? bas, DateOnly? bit, int? departmanId, string? ara,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu.plan", Islem.Gor);
            var bugun = DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            short? turNo = short.TryParse(tur, out var tn) && tn is >= 1 and <= 5 ? tn : null;
            var ikMi = tur == "ik";
            await using var b = await veri.AcAsync(iptal);

            // Etkilenen randevu: kapatan türde aralıktaki bütün planlılar, saat
            //   değişikliğinde yeni saatin dışındakiler; ek mesaide açılan blokta dolu olanlar.
            var hepsi = await b.ListeAsync($"""
                with ham as (
                    select 'istisna'::varchar as kaynak, i.id, i.tur, i.hekim_id, t.departman as hekim_bolum, i.departman_id,
                           i.bas_tarih, i.bit_tarih, i.saat_bas, i.saat_bit, coalesce(i.kanallar, '') as kanallar, i.slot_dk,
                           i.durum, i.aciklama, ''::varchar as ik_tur, ''::varchar as izin_no,
                           coalesce(ke.ad, '') as giren, i.ekleme_tarihi, coalesce(ko.ad, '') as onaylayan, i.onay_tarihi
                      from public.hekim_calisma_istisna i
                      join public.taraf t on t.id = i.hekim_id
                      left join public.v_kullanici_lookup ke on ke.id = i.ekleyen
                      left join public.v_kullanici_lookup ko on ko.id = i.onaylayan
                    union all
                    select 'ik', z.id, 0::smallint, z.taraf_id, t.departman, null::integer,
                           z.baslangic_tarihi, z.bitis_tarihi, null, null, '', null,
                           1::smallint, z.aciklama,
                           case z.tur when 1 then 'Yıllık izin' when 2 then 'Mazeret izni' when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin' else 'İzin' end,
                           z.izin_no, '', z.ekleme_tarihi, '', null
                      from public.personel_izin z
                      join public.taraf t on t.id = z.taraf_id
                     where z.durum = 2 and z.baslangic_tarihi is not null and z.bitis_tarihi is not null
                       and (exists (select 1 from public.hekim_calisma_sablon s where s.hekim_id = z.taraf_id)))
                select h.kaynak, h.id, h.tur, h.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                       coalesce(d.ad, ''), h.departman_id is not null,
                       h.bas_tarih, h.bit_tarih, h.saat_bas, h.saat_bit, h.kanallar, h.durum, h.aciklama, h.ik_tur, h.izin_no,
                       h.giren, h.ekleme_tarihi, h.onaylayan, h.onay_tarihi,
                       case when h.tur = 4 then 0 else (
                         select count(*) from public.randevu r
                          where r.hekim_id = h.hekim_id and r.durum = 1
                            and {YerelSql}::date between greatest(h.bas_tarih, current_date) and h.bit_tarih
                            and (h.departman_id is null or r.bolum = h.departman_id)
                            and (h.tur <> 3 or {YerelSql}::time < h.saat_bas::time
                                 or {YerelSql}::time + make_interval(mins => greatest(r.sure_dk, 1)::int) > h.saat_bit::time)) end::int,
                       case when h.tur = 4 then (
                         select count(*) from public.randevu r
                          where r.hekim_id = h.hekim_id and r.durum in (1, 2)
                            and {YerelSql}::date between h.bas_tarih and h.bit_tarih
                            and {YerelSql}::time >= h.saat_bas::time and {YerelSql}::time < h.saat_bit::time) else 0 end::int,
                       coalesce(h.slot_dk, (select s.slot_dk from public.hekim_calisma_sablon s
                                             where s.hekim_id = h.hekim_id and s.aktif = 1 order by s.id limit 1), 15)
                  from ham h
                  join public.taraf t on t.id = h.hekim_id
                  left join public.departman d on d.id = coalesce(h.departman_id, h.hekim_bolum::integer)
                 where (@p0::smallint is null or h.tur = @p0)
                   and (not @p1 or h.kaynak = 'ik')
                   and (@p2::date is null or h.bit_tarih >= @p2)
                   and (@p3::date is null or h.bas_tarih <= @p3)
                   and (@p4::integer is null or coalesce(h.departman_id, h.hekim_bolum::integer) = @p4)
                   and (@p5::varchar is null or public.fn_taraf_ad(t.unvan, t.ad, t.soyad) ilike '%' || @p5 || '%' or h.aciklama ilike '%' || @p5 || '%')
                 order by h.bas_tarih, 5
                """, null, [turNo, ikMi, bas, bit, departmanId, string.IsNullOrWhiteSpace(ara) ? null : ara.Trim()], o => new
            {
                kaynak = o.GetString(0), id = o.GetInt32(1), tur = (int)o.GetInt16(2), hekimId = o.GetInt32(3), hekim = o.GetString(4),
                departman = o.GetString(5), bolumSecili = o.GetBoolean(6),
                bas = o.GetFieldValue<DateOnly>(7), bit = o.GetFieldValue<DateOnly>(8),
                saatBas = o.IsDBNull(9) ? null : o.GetString(9), saatBit = o.IsDBNull(10) ? null : o.GetString(10),
                kanallar = o.GetString(11), durum = (int)o.GetInt16(12), aciklama = o.GetString(13), ikTur = o.GetString(14),
                izinNo = o.GetString(15), giren = o.GetString(16), eklemeTarihi = o.GetDateTime(17),
                onaylayan = o.GetString(18), onayTarihi = o.IsDBNull(19) ? (DateTime?)null : o.GetDateTime(19),
                bekleyen = o.GetInt32(20), ekDolu = o.GetInt32(21), slotDk = (int)o.GetInt16(22),
            }, iptal);

            var sayac = new
            {
                bekliyor = hepsi.Count(x => x.durum == 0), onayli = hepsi.Count(x => x.durum == 1),
                iptal = hepsi.Count(x => x.durum == 2), tumu = hepsi.Count,
            };
            var satirlar = (durum ?? "0") switch
            {
                "1" => hepsi.Where(x => x.durum == 1).ToList(),
                "2" => hepsi.Where(x => x.durum == 2).ToList(),
                "tumu" => hepsi,
                _ => hepsi.Where(x => x.durum == 0).ToList(),
            };

            // ÖZET süzgeçten BAĞIMSIZ (ekranın genel durumu): bugünden sonrası.
            var ozetSatir = await b.ListeAsync($"""
                select i.durum, i.tur, i.bas_tarih, i.bit_tarih, i.ekleme_tarihi,
                       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                       case when i.tur in (1, 2, 3, 5) and i.durum <> 2 then (
                         select count(*) from public.randevu r
                          where r.hekim_id = i.hekim_id and r.durum = 1
                            and {YerelSql}::date between greatest(i.bas_tarih, current_date) and i.bit_tarih
                            and (i.departman_id is null or r.bolum = i.departman_id)
                            and (i.tur <> 3 or {YerelSql}::time < i.saat_bas::time
                                 or {YerelSql}::time + make_interval(mins => greatest(r.sure_dk, 1)::int) > i.saat_bit::time)) else 0 end::int
                  from public.hekim_calisma_istisna i join public.taraf t on t.id = i.hekim_id
                 where i.bit_tarih >= current_date or i.durum = 0
                """, null, [], o => new
            {
                durum = (int)o.GetInt16(0), tur = (int)o.GetInt16(1), bas = o.GetFieldValue<DateOnly>(2), bit = o.GetFieldValue<DateOnly>(3),
                ekleme = o.GetDateTime(4), hekim = o.GetString(5), bekleyen = o.GetInt32(6),
            }, iptal);
            var ikBugun = await b.ListeAsync("""
                select distinct public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                  from public.personel_izin z join public.taraf t on t.id = z.taraf_id
                 where z.durum = 2 and current_date between z.baslangic_tarihi and z.bitis_tarihi
                   and exists (select 1 from public.hekim_calisma_sablon s where s.hekim_id = z.taraf_id)
                """, null, [], o => o.GetString(0), iptal);
            var bekleyenler = ozetSatir.Where(x => x.durum == 0).ToList();
            var bugunYok = ozetSatir.Where(x => x.durum == 1 && x.tur is 1 or 2 or 5 && x.bas <= bugun && x.bit >= bugun)
                                    .Select(x => x.hekim).Concat(ikBugun).Distinct().OrderBy(x => x).ToList();
            var otuz = ozetSatir.Where(x => x.durum != 2 && x.bas <= bugun.AddDays(30) && x.bit >= bugun).ToList();

            return Results.Ok(new
            {
                satirlar, sayac,
                ozet = new
                {
                    onayBekleyen = bekleyenler.Count,
                    enEskiGun = bekleyenler.Count == 0 ? 0 : (int)(DateTime.UtcNow - bekleyenler.Min(x => x.ekleme).ToUniversalTime()).TotalDays,
                    islemBekleyenRandevu = ozetSatir.Where(x => x.durum != 2).Sum(x => x.bekleyen),
                    bugunYok,
                    otuzGun = otuz.Count,
                    otuzGunTur = otuz.GroupBy(x => x.tur).ToDictionary(g => g.Key.ToString(), g => g.Count()),
                },
            });
        });

        // -------------------------------------------- istisna toplu işlem ----
        grup.MapPost("/istisna-toplu", async (IstisnaTopluIstegi istek, VeriKaynagi veri, LogDeposu log,
                                              BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu.plan", Islem.Degistir);
            var islemAdi = (istek.Islem ?? "").Trim().ToLowerInvariant();
            short hedef = islemAdi switch { "onayla" => 1, "iptal" => 2, _ => throw GentegreHatasi.Dogrulama("Bilinmeyen işlem.") };
            if (istek.Idler is not { Length: > 0 }) throw GentegreHatasi.Dogrulama("Kayıt seçilmedi.");

            var sonuc = new List<object>();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var id in istek.Idler.Distinct().Take(200))
            {
                var eski = await b.TekDegerAsync<short?>("select durum from public.hekim_calisma_istisna where id = @p0", islem, [id], iptal);
                if (eski is null) { sonuc.Add(new { id, basarili = false, mesaj = "Kayıt bulunamadı." }); continue; }
                if (eski == hedef) { sonuc.Add(new { id, basarili = true, mesaj = "Değişiklik yok." }); continue; }
                if (eski == 2 && hedef == 1) { sonuc.Add(new { id, basarili = false, mesaj = "İptal edilmiş istisna onaylanamaz." }); continue; }
                await islem.SaveAsync("satir", iptal);
                try
                {
                    await b.CalistirAsync("update public.hekim_calisma_istisna set durum = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                        islem, [id, hedef, baglam.KullaniciId], iptal);
                    await log.YazAsync(b, islem, LogIslemi.Degistir, LogIstisna, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                        new Dictionary<string, string> { ["durum"] = $"{eski} -> {hedef}" }, iptal: iptal);
                    sonuc.Add(new { id, basarili = true, mesaj = hedef == 1 ? "Onaylandı." : "İptal edildi." });
                }
                catch (PostgresException h)
                {
                    await islem.RollbackAsync("satir", iptal);
                    sonuc.Add(new { id, basarili = false, mesaj = h.MessageText });
                }
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { sonuc });
        });
    }
}
