using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇALIŞMA ŞABLONU ve İZİN &amp; İSTİSNA KARTLARININ uçları (945; mockup
/// <c>Ekranlar/Randevu/calisma_sablonu_karti.html</c>, <c>izin_istisna_karti.html</c>).
///
/// Kayıt generic kartla yazılır (<c>calisma-sablon</c> / <c>calisma-istisna</c>);
/// burada yalnız kartın KAYDETMEDEN ÖNCE gösterdiği hesaplar ve istisnanın
/// etkilediği randevulara toplu işlem:
///   * şablon etkisi: kapasite, doluluk, kaydedince plan dışında kalacak
///     randevular, çakışan aktif şablon (kayıt tetikle engellenir, kart
///     önceden söyler), doktorun diğer şablonları;
///   * istisna bağlamı: istisnanın haftası, etkilenen randevular, yakın
///     istisnalar (İK izni salt okunur);
///   * toplu işlem: iptal / başka doktora aktar / sonraki boş güne kaydır /
///     SMS. Kurallar (mesai dışı, çakışma, izin) randevu tetiklerinde - bu uç
///     onları ikinci kez yazmaz, satır satır dener ve sonucu döner.
/// </summary>
public static partial class CalismaPlaniUclari
{
    private const int LogRandevu = 1259;          // KartKatalogu.Randevu ile aynı
    private const short KaynakRandevu = 4;        // bildirim.kaynak_tur (RandevuHatirlatmasi)

    public sealed record SablonEtkiIstegi(
        int? Id, int HekimId, int? DepartmanId, string Gunler, string Bas1, string Bit1,
        string? Bas2, string? Bit2, int SlotDk, int Tekrar, DateOnly GecerliBas, DateOnly? GecerliBit);

    public sealed record IstisnaRandevuIstegi(string Islem, int[] RandevuIdleri, int? HedefHekimId, string? Mesaj);

    private sealed record Aralik(int Bas, int Bit);
    /// <summary>Baslangic: şubenin DUVAR SAATİ (plan blokları duvar saatidir); Utc: istemciye giden an.</summary>
    private sealed record RandevuSatiri(int Id, DateTime Baslangic, DateTime Utc, int SureDk, string Hasta, int Bolum);

    /// <summary>
    /// randevu.baslangic timestamptz (667) - bir AN. Plan blokları ise duvar saati:
    /// karşılaştırma randevunun ŞUBESİNİN saat diliminde yapılır (946 ile aynı kural).
    /// </summary>
    private const string YerelSql =
        "(r.baslangic at time zone coalesce((select nullif(sb.zaman_dilimi, '') from public.sube sb where sb.id = r.sube_id), 'Europe/Istanbul'))";

    private static int Dakika(string? s) =>
        TimeOnly.TryParseExact(s ?? "", "HH:mm", out var t) ? t.Hour * 60 + t.Minute : -1;

    /// <summary>Şablonun o gün ürettiği bloklar (fn_hekim_calisma_bloklari'nin şablon kuralı).</summary>
    private static List<Aralik> SablonBloklari(SablonEtkiIstegi s, DateOnly gun)
    {
        var bos = new List<Aralik>();
        if (gun < s.GecerliBas || (s.GecerliBit is DateOnly bit && gun > bit)) return bos;
        var gunNo = ((int)gun.DayOfWeek + 6) % 7 + 1;                         // 1 Pzt … 7 Paz
        if (!s.Gunler.Split(',').Select(x => x.Trim()).Contains(gunNo.ToString())) return bos;
        if (s.Tekrar == 2 && ((gun.DayNumber - s.GecerliBas.DayNumber) / 7) % 2 != 0) return bos;
        int b1 = Dakika(s.Bas1), e1 = Dakika(s.Bit1), b2 = Dakika(s.Bas2), e2 = Dakika(s.Bit2);
        if (b1 >= 0 && e1 > b1) bos.Add(new(b1, e1));
        if (b2 >= 0 && e2 > b2) bos.Add(new(b2, e2));
        return bos;
    }

    private static bool Icinde(IEnumerable<Aralik> bloklar, int bas, int bit) =>
        bloklar.Any(b => bas >= b.Bas && bit <= b.Bit);

    private static void KartUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------- yeni şablon varsayılanı ----
        // ⚙ Varsayılanlar penceresinin yazdığı ayarlar (randevu.*). Öğle arası
        //   girildiyse iki blok, yoksa tek blok - 718'in geçiş kuralıyla aynı.
        grup.MapGet("/sablon-varsayilan", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu.plan", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ayar = (await b.ListeAsync("select anahtar, deger from public.referans where anahtar like 'randevu.%'", null, [],
                o => (o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1)), iptal)).ToDictionary(x => x.Item1, x => x.Item2);
            string Al(string a, string vs) => ayar.TryGetValue(a, out var d) && !string.IsNullOrWhiteSpace(d) ? d.Trim() : vs;
            var bas = Al("randevu.baslangic_saat", "09:00");
            var bit = Al("randevu.bitis_saat", "18:00");
            var ob = Al("randevu.ogle_baslangic", "");
            var ok = Al("randevu.ogle_bitis", "");
            var ikiBlok = Dakika(ob) > Dakika(bas) && Dakika(ok) > Dakika(ob) && Dakika(bit) > Dakika(ok);
            return Results.Ok(new
            {
                gunler = Al("randevu.calisma_gunleri", "1,2,3,4,5"),
                bas1 = bas, bit1 = ikiBlok ? ob : bit,
                bas2 = ikiBlok ? ok : null, bit2 = ikiBlok ? bit : null,
                slotDk = int.TryParse(Al("randevu.slot_dk", "15"), out var sl) && sl > 0 ? sl : 15,
            });
        });

        // ------------------------------------------------- şablon etkisi ----
        grup.MapPost("/sablon-etki", async (SablonEtkiIstegi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu.plan", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var bugun = DateOnly.FromDateTime(Saat.Bugun);
            var son = bugun.AddDays(89);

            // Bugünkü plan (kaydedilmiş hâl): kaynak 1/2 açık bloklar, 3/4 kapalı gün.
            var plan = s.HekimId > 0 ? await b.ListeAsync("""
                select gun, to_char(saat_bas, 'HH24:MI'), to_char(saat_bit, 'HH24:MI'), kaynak, sablon_id
                  from public.fn_hekim_calisma_bloklari(0, @p0, @p1, @p2)
                """, null, [bugun, son, s.HekimId], o => new
            {
                gun = o.GetFieldValue<DateOnly>(0), bas = o.IsDBNull(1) ? -1 : Dakika(o.GetString(1)),
                bit = o.IsDBNull(2) ? -1 : Dakika(o.GetString(2)), kaynak = (int)o.GetInt16(3),
                sablonId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
            }, iptal) : [];
            var kapaliGun = plan.Where(p => p.kaynak is 3 or 4).Select(p => p.gun).ToHashSet();
            List<Aralik> Mevcut(DateOnly g) => plan.Where(p => p.gun == g && p.kaynak is 1 or 2 && p.bas >= 0)
                                                   .Select(p => new Aralik(p.bas, p.bit)).ToList();
            List<Aralik> Digerleri(DateOnly g) => plan.Where(p => p.gun == g && p.kaynak is 1 or 2 && p.bas >= 0
                                                                 && (s.Id is null || p.sablonId != s.Id))
                                                      .Select(p => new Aralik(p.bas, p.bit)).ToList();

            var randevular = s.HekimId > 0 ? await b.ListeAsync($"""
                select r.id, {YerelSql}, r.baslangic, r.sure_dk, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), r.bolum
                  from public.randevu r join public.taraf t on t.id = r.hasta_id
                 where r.hekim_id = @p0 and r.durum = 1 and r.baslangic >= now() and {YerelSql}::date <= @p1
                 order by r.baslangic
                """, null, [s.HekimId, son],
                o => new RandevuSatiri(o.GetInt32(0), o.GetDateTime(1), o.GetDateTime(2), o.GetInt16(3), o.GetString(4), o.GetInt16(5)), iptal) : [];

            // KAYDEDİNCE PLAN DIŞINDA KALACAK: bugün bir bloğun içinde olan, yeni
            //   şablon + doktorun diğer blokları ile dışarıda kalan randevu.
            //   Kapalı günlerdeki randevu bu şablonun sonucu değil - istisnanın.
            var disarida = new List<object>();
            foreach (var r in randevular)
            {
                var g = DateOnly.FromDateTime(r.Baslangic);
                if (kapaliGun.Contains(g)) continue;
                var bas = r.Baslangic.Hour * 60 + r.Baslangic.Minute;
                var bit = bas + Math.Max(r.SureDk, 1);
                if (!Icinde(Mevcut(g), bas, bit)) continue;
                if (Icinde(SablonBloklari(s, g).Concat(Digerleri(g)), bas, bit)) continue;
                disarida.Add(new { r.Id, baslangic = r.Utc, sureDk = r.SureDk, hasta = r.Hasta });
            }

            // KAPASİTE / DOLULUK (önümüzdeki 14 gün, yalnız bu şablonun blokları).
            int kapasite = 0, dolu = 0, randevu14 = 0;
            var slot = Math.Max(s.SlotDk, 1);
            for (var g = bugun; g < bugun.AddDays(14); g = g.AddDays(1))
            {
                if (kapaliGun.Contains(g)) continue;
                var bl = SablonBloklari(s, g);
                kapasite += bl.Sum(x => (x.Bit - x.Bas) / slot);
                foreach (var r in randevular.Where(r => DateOnly.FromDateTime(r.Baslangic) == g))
                {
                    var bas = r.Baslangic.Hour * 60 + r.Baslangic.Minute;
                    if (!Icinde(bl, bas, bas + Math.Max(r.SureDk, 1))) continue;
                    randevu14++;
                    dolu += (int)Math.Ceiling(Math.Max(r.SureDk, 1) / (double)slot);
                }
            }

            // ÇAKIŞAN AKTİF ŞABLON: 945 tetiğinin kuralı (kayıt orada engellenir).
            var cakisan = s.HekimId > 0 ? await b.ListeAsync("""
                select x.id, x.ad, coalesce(d.ad, ''),
                       x.bas1 || '–' || x.bit1 || case when nullif(x.bas2, '') is not null then ' · ' || x.bas2 || '–' || x.bit2 else '' end
                  from public.hekim_calisma_sablon x
                  left join public.departman d on d.id = x.departman_id
                 where x.hekim_id = @p0 and x.aktif = 1 and x.id <> coalesce(@p1, -1)
                   and string_to_array(replace(x.gunler, ' ', ''), ',') && string_to_array(replace(@p2, ' ', ''), ',')
                   and daterange(x.gecerli_bas, coalesce(x.gecerli_bit, 'infinity'::date), '[]')
                       && daterange(@p3::date, coalesce(@p4::date, 'infinity'::date), '[]')
                   and not (x.tekrar = 2 and @p5 = 2 and (@p3::date - x.gecerli_bas) % 7 = 0
                            and abs((@p3::date - x.gecerli_bas) / 7) % 2 = 1)
                   and exists (select 1
                                 from (values (x.bas1, x.bit1), (nullif(x.bas2, ''), nullif(x.bit2, ''))) a(b, e),
                                      (values (@p6::varchar, @p7::varchar), (nullif(@p8::varchar, ''), nullif(@p9::varchar, ''))) n(b, e)
                                where a.b is not null and n.b is not null and a.b < n.e and n.b < a.e)
                 order by x.id
                """, null, [s.HekimId, s.Id, s.Gunler ?? "", s.GecerliBas, s.GecerliBit, (short)s.Tekrar,
                            s.Bas1 ?? "", s.Bit1 ?? "", s.Bas2 ?? "", s.Bit2 ?? ""],
                o => new { id = o.GetInt32(0), ad = o.GetString(1), departman = o.GetString(2), saat = o.GetString(3) }, iptal) : [];

            var digerleri = s.HekimId > 0 ? await b.ListeAsync("""
                select x.id, x.ad, coalesce(d.ad, ''), x.gunler, x.aktif, x.gecerli_bit
                  from public.hekim_calisma_sablon x left join public.departman d on d.id = x.departman_id
                 where x.hekim_id = @p0
                 order by x.aktif desc, x.id
                """, null, [s.HekimId], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), departman = o.GetString(2), gunler = o.GetString(3),
                aktif = o.GetInt16(4) == 1, gecerliBit = o.IsDBNull(5) ? (DateOnly?)null : o.GetFieldValue<DateOnly>(5),
            }, iptal) : [];

            var kayit = s.Id is int id ? await b.TekAsync("""
                select coalesce(ke.ad, ''), x.ekleme_tarihi, coalesce(kd.ad, ''), x.degistirme_tarihi
                  from public.hekim_calisma_sablon x
                  left join public.v_kullanici_lookup ke on ke.id = x.ekleyen
                  left join public.v_kullanici_lookup kd on kd.id = x.degistiren
                 where x.id = @p0
                """, null, [id], o => new
            {
                ekleyen = o.GetString(0), eklemeTarihi = o.GetDateTime(1),
                degistiren = o.GetString(2), degistirmeTarihi = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
            }, iptal) : null;

            return Results.Ok(new
            {
                randevu14, kapasite14 = kapasite,
                doluluk = kapasite == 0 ? 0 : (int)Math.Round(100.0 * dolu / kapasite),
                disarida, cakisan, digerleri, kayit,
            });
        });

        // ---------------------------------------------- istisna bağlamı ----
        grup.MapGet("/istisna-baglam", async (
            int hekimId, DateOnly bas, DateOnly bit, int? tur, string? saatBas, string? saatBit, int? departmanId, int? id,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu.plan", Islem.Gor);
            if (bit < bas) bit = bas;
            if (bit.DayNumber - bas.DayNumber > 62) bit = bas.AddDays(62);
            await using var b = await veri.AcAsync(iptal);

            // İstisnanın ilk haftası (Pzt-Paz): kart üstüne bu formun etkisini çizer.
            var haftaBas = bas.AddDays(-(((int)bas.DayOfWeek + 6) % 7));
            var hafta = await b.ListeAsync("""
                select f.gun, to_char(f.saat_bas, 'HH24:MI'), to_char(f.saat_bit, 'HH24:MI'), f.kaynak, f.istisna_tur,
                       f.istisna_id, f.departman, f.aciklama, coalesce(s.ad, '')
                  from public.fn_hekim_calisma_bloklari(0, @p0, @p1, @p2) f
                  left join public.hekim_calisma_sablon s on s.id = f.sablon_id
                 order by f.gun, f.saat_bas
                """, null, [haftaBas, haftaBas.AddDays(6), hekimId], o => new
            {
                gun = o.GetFieldValue<DateOnly>(0), saatBas = o.IsDBNull(1) ? null : o.GetString(1),
                saatBit = o.IsDBNull(2) ? null : o.GetString(2), kaynak = (int)o.GetInt16(3),
                istisnaTur = o.IsDBNull(4) ? (int?)null : o.GetInt16(4), istisnaId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                departman = o.GetString(6), aciklama = o.GetString(7), sablon = o.GetString(8),
            }, iptal);

            // ETKİLENEN RANDEVULAR: izin / kongre / kapalı aralıktaki bütün planlı
            //   randevular; saat değişikliğinde yeni saatlerin dışında kalanlar;
            //   ek mesai hiçbir randevuyu etkilemez.
            var randevular = tur == 4 ? [] : await b.ListeAsync($"""
                select r.id, r.baslangic, r.sure_dk, r.hasta_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                       coalesce(kd.ad, ''), length(regexp_replace(coalesce(t.cep_tel, ''), '[^0-9]', '', 'g')) >= 10
                  from public.randevu r
                  join public.taraf t on t.id = r.hasta_id
                  left join public.kod_liste kl on kl.kod = 'randevu.tip'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = r.tip
                 where r.hekim_id = @p0 and r.durum = 1
                   and {YerelSql}::date between @p1 and @p2
                   and (@p3::integer is null or r.bolum = @p3)
                   and (@p4::smallint <> 3 or @p5::time is null
                        or {YerelSql}::time < @p5::time
                        or {YerelSql}::time + make_interval(mins => greatest(r.sure_dk, 1)::int) > @p6::time)
                 order by r.baslangic
                """, null, [hekimId, bas, bit,
                            departmanId, (short)(tur ?? 1),
                            Dakika(saatBas) >= 0 ? TimeOnly.ParseExact(saatBas!, "HH:mm") : null,
                            Dakika(saatBit) >= 0 ? TimeOnly.ParseExact(saatBit!, "HH:mm") : null],
                o => new
                {
                    id = o.GetInt32(0), baslangic = o.GetDateTime(1), sureDk = (int)o.GetInt16(2), hastaId = o.GetInt32(3),
                    hasta = o.GetString(4), tip = o.GetString(5), telefonVar = o.GetBoolean(6),
                }, iptal);

            // YAKIN İSTİSNALAR: plan istisnaları + İK'dan onaylanan / onaydaki izin (salt okunur).
            var yakin = await b.ListeAsync("""
                select * from (
                    select i.id, i.bas_tarih, i.bit_tarih, coalesce(kd.ad, ''), i.durum, 'istisna'::varchar as kaynak, i.aciklama
                      from public.hekim_calisma_istisna i
                      left join public.kod_liste kl on kl.kod = 'calisma.istisna_tur'
                      left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = i.tur
                     where i.hekim_id = @p0 and i.bit_tarih >= current_date - 7 and i.durum <> 2
                    union all
                    select z.id, z.baslangic_tarihi, z.bitis_tarihi,
                           case z.tur when 1 then 'Yıllık izin' when 2 then 'Mazeret izni' when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin' else 'İzin' end,
                           case z.durum when 2 then 1 else 0 end, 'ik', z.aciklama
                      from public.personel_izin z
                     where z.taraf_id = @p0 and z.durum in (1, 2) and z.bitis_tarihi >= current_date - 7
                ) y order by 2, 1 limit 12
                """, null, [hekimId], o => new
            {
                id = o.GetInt32(0), bas = o.GetFieldValue<DateOnly>(1), bit = o.GetFieldValue<DateOnly>(2),
                tur = o.GetString(3), onayli = o.GetInt16(4) == 1, kaynak = o.GetString(5), aciklama = o.GetString(6),
            }, iptal);

            // Aktarma hedefi: aktif şablonu olan diğer doktorlar (bölümü öne alınır).
            var doktorlar = await b.ListeAsync("""
                select distinct t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                       bool_or(s.departman_id = coalesce(@p1, -1)) over (partition by t.id)
                  from public.hekim_calisma_sablon s join public.taraf t on t.id = s.hekim_id
                 where s.aktif = 1 and s.hekim_id <> @p0
                 order by 3 desc, 2
                """, null, [hekimId, departmanId], o => new { id = o.GetInt32(0), ad = o.GetString(1), ayniBolum = o.GetBoolean(2) }, iptal);

            var kayit = id is int iid ? await b.TekAsync("""
                select coalesce(ke.ad, ''), x.ekleme_tarihi, coalesce(ko.ad, ''), x.onay_tarihi
                  from public.hekim_calisma_istisna x
                  left join public.v_kullanici_lookup ke on ke.id = x.ekleyen
                  left join public.v_kullanici_lookup ko on ko.id = x.onaylayan
                 where x.id = @p0
                """, null, [iid], o => new
            {
                ekleyen = o.GetString(0), eklemeTarihi = o.GetDateTime(1),
                onaylayan = o.GetString(2), onayTarihi = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
            }, iptal) : null;

            return Results.Ok(new { haftaBas, hafta, randevular, yakin, doktorlar, kayit });
        });

        // ------------------------------ etkilenen randevulara toplu işlem ----
        grup.MapPost("/istisna-randevu", async (
            IstisnaRandevuIstegi istek, VeriKaynagi veri, LogDeposu log, KayitErisimi erisim, BildirimDeposu bildirim,
            Servisler.RandevuHatirlatmasi hatirlatma, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Degistir);
            var islemAdi = (istek.Islem ?? "").Trim().ToLowerInvariant();
            if (islemAdi is not ("iptal" or "aktar" or "kaydir" or "sms"))
                throw GentegreHatasi.Dogrulama("Bilinmeyen işlem.");
            if (istek.RandevuIdleri is not { Length: > 0 }) throw GentegreHatasi.Dogrulama("Randevu seçilmedi.");
            if (istek.RandevuIdleri.Length > 200) throw GentegreHatasi.Dogrulama("Tek seferde en çok 200 randevu.");
            if (islemAdi == "aktar" && istek.HedefHekimId is not > 0) throw GentegreHatasi.Dogrulama("Aktarılacak doktor seçilmeli.");

            var sonuc = new List<object>();
            var degisen = new List<int>();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);

            // Kaydırmada aynı partide verilen saatler bir sonrakine verilmez.
            var verilen = new Dictionary<int, List<(DateTime bas, DateTime bit)>>();

            foreach (var rid in istek.RandevuIdleri.Distinct().Order())
            {
                if (!await erisim.GorunurAsync(baglam, "randevu", rid, iptal))
                { sonuc.Add(new { id = rid, basarili = false, mesaj = "Randevu bulunamadı." }); continue; }

                var r = await b.TekAsync($"""
                    select r.hekim_id, {YerelSql}, r.sure_dk, r.durum, r.hasta_id, r.sube_id, r.bolum,
                           public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                           regexp_replace(coalesce(t.cep_tel, ''), '[^0-9]', '', 'g'),
                           coalesce((select public.fn_taraf_ad(h.unvan, h.ad, h.soyad) from public.taraf h where h.id = r.hekim_id), '')::varchar(120)
                      from public.randevu r join public.taraf t on t.id = r.hasta_id where r.id = @p0
                    """, islem, [rid], o => new
                {
                    hekimId = o.IsDBNull(0) ? 0 : o.GetInt32(0), baslangic = o.GetDateTime(1), sureDk = (int)o.GetInt16(2),
                    durum = o.GetInt16(3), hastaId = o.GetInt32(4), subeId = o.GetInt32(5), bolum = o.GetInt16(6),
                    hasta = o.GetString(7), telefon = o.GetString(8), hekim = o.GetString(9),
                }, iptal);
                if (r is null) { sonuc.Add(new { id = rid, basarili = false, mesaj = "Randevu bulunamadı." }); continue; }
                if (r.durum != 1 && islemAdi != "sms") { sonuc.Add(new { id = rid, basarili = false, mesaj = "Randevu planlı değil." }); continue; }

                if (islemAdi == "sms")
                {
                    var tel = r.telefon.StartsWith("90") && r.telefon.Length > 10 ? r.telefon[2..] : r.telefon;
                    if (tel.StartsWith('0')) tel = tel[1..];
                    if (tel.Length < 10) { sonuc.Add(new { id = rid, basarili = false, mesaj = "Hastanın cep telefonu yok." }); continue; }
                    var govde = string.IsNullOrWhiteSpace(istek.Mesaj)
                        ? $"Sayın {r.hasta}, {r.baslangic:dd.MM.yyyy HH:mm} tarihli {r.hekim} randevunuz doktorunuzun programındaki değişiklik nedeniyle gerçekleştirilemeyecektir. Yeni randevu için lütfen bizi arayın."
                        : istek.Mesaj.Trim();
                    await bildirim.KuyrugaEkleAsync(new BildirimIstegi(null, BildirimKanali.Sms, tel, Govde: govde,
                        TarafId: r.hastaId, KaynakTur: KaynakRandevu, KaynakId: rid, Oncelik: 3),
                        baglam.KullaniciId, r.subeId > 0 ? r.subeId : null, iptal);
                    sonuc.Add(new { id = rid, basarili = true, mesaj = "SMS kuyruğa kondu." });
                    continue;
                }

                int? yeniHekim = null; DateTime? yeniBas = null;
                if (islemAdi == "aktar")
                {
                    if (istek.HedefHekimId == r.hekimId) { sonuc.Add(new { id = rid, basarili = false, mesaj = "Aynı doktor." }); continue; }
                    yeniHekim = istek.HedefHekimId;
                }
                else if (islemAdi == "kaydir")
                {
                    yeniBas = await SonrakiBosSaatAsync(b, islem, r.hekimId, r.baslangic, r.sureDk, r.bolum, verilen, iptal);
                    if (yeniBas is null) { sonuc.Add(new { id = rid, basarili = false, mesaj = "30 gün içinde boş saat yok." }); continue; }
                }

                await islem.SaveAsync("satir", iptal);
                try
                {
                    await b.CalistirAsync("""
                        update public.randevu
                           set durum = case when @p1 then 4 else durum end,
                               hekim_id = coalesce(@p2, hekim_id),
                               baslangic = coalesce(@p3::timestamp at time zone coalesce(
                                   (select nullif(sb.zaman_dilimi, '') from public.sube sb where sb.id = randevu.sube_id),
                                   'Europe/Istanbul'), baslangic),
                               degistiren = @p4, degistirme_tarihi = now()
                         where id = @p0
                        """, islem, [rid, islemAdi == "iptal", yeniHekim, yeniBas, baglam.KullaniciId], iptal);

                    // Alan bazlı değişiklik logu (ULog kuralı: "eski -> yeni").
                    var fark = new Dictionary<string, string>();
                    if (islemAdi == "iptal") fark["durum"] = "1 -> 4";
                    if (yeniHekim is int yh) fark["hekim_id"] = $"{r.hekimId} -> {yh}";
                    if (yeniBas is DateTime yb) fark["baslangic"] = $"{r.baslangic:yyyy-MM-dd HH:mm} -> {yb:yyyy-MM-dd HH:mm}";
                    await log.YazAsync(b, islem, LogIslemi.Degistir, LogRandevu, rid, baglam.KullaniciId, baglam.SubeId,
                        baglam.Ip, fark, tarafId: r.hastaId, iptal: iptal);

                    degisen.Add(rid);
                    if (yeniBas is DateTime vb)
                    {
                        if (!verilen.TryGetValue(r.hekimId, out var l)) verilen[r.hekimId] = l = [];
                        l.Add((vb, vb.AddMinutes(Math.Max(r.sureDk, 1))));
                    }
                    sonuc.Add(new
                    {
                        id = rid, basarili = true,
                        mesaj = islemAdi == "iptal" ? "İptal edildi." : islemAdi == "aktar" ? "Aktarıldı." : $"{yeniBas:dd.MM.yyyy HH:mm} saatine kaydırıldı.",
                    });
                }
                catch (PostgresException h)
                {
                    // Tetik kuralı (mesai dışı, çakışma, izin): satır geri alınır, sıradakine geçilir.
                    await islem.RollbackAsync("satir", iptal);
                    sonuc.Add(new { id = rid, basarili = false, mesaj = h.MessageText });
                }
            }

            await islem.CommitAsync(iptal);
            foreach (var rid in degisen) await hatirlatma.TazeleAsync(rid, baglam.KullaniciId, iptal);
            return Results.Ok(new { sonuc });
        });
    }

    /// <summary>
    /// Randevu için doktorun planında, istisna sonrası ilk boş saat (30 gün).
    /// Aynı bölümün blokları önce; dolu randevular ve bu partide verilenler atlanır.
    /// </summary>
    private static async Task<DateTime?> SonrakiBosSaatAsync(NpgsqlConnection b, NpgsqlTransaction islem, int hekimId,
        DateTime eski, int sureDk, int bolum, Dictionary<int, List<(DateTime bas, DateTime bit)>> verilen, CancellationToken iptal)
    {
        var ilk = DateOnly.FromDateTime(eski).AddDays(1);
        var bugun = DateOnly.FromDateTime(Saat.Bugun);
        if (ilk <= bugun) ilk = bugun.AddDays(1);
        var son = ilk.AddDays(30);
        var bloklar = await b.ListeAsync("""
            select gun, to_char(saat_bas, 'HH24:MI'), to_char(saat_bit, 'HH24:MI'), slot_dk, departman_id
              from public.fn_hekim_calisma_bloklari(0, @p0, @p1, @p2)
             where kaynak in (1, 2) and saat_bas is not null
             order by gun, saat_bas
            """, islem, [ilk, son, hekimId], o => new
        {
            gun = o.GetFieldValue<DateOnly>(0), bas = Dakika(o.GetString(1)), bit = Dakika(o.GetString(2)),
            slot = Math.Max((int)o.GetInt16(3), 5), departman = o.GetInt32(4),
        }, iptal);
        var dolu = await b.ListeAsync($"""
            select {YerelSql}, {YerelSql} + make_interval(mins => greatest(r.sure_dk, 1)::int)
              from public.randevu r where r.hekim_id = @p0 and r.durum <> 4 and {YerelSql}::date between @p1 and @p2
            """, islem, [hekimId, ilk, son],
            o => (bas: o.GetDateTime(0), bit: o.GetDateTime(1)), iptal);
        if (verilen.TryGetValue(hekimId, out var v)) dolu.AddRange(v);

        foreach (var gun in bloklar.Select(x => x.gun).Distinct())
            foreach (var bl in bloklar.Where(x => x.gun == gun).OrderBy(x => x.departman == bolum ? 0 : 1).ThenBy(x => x.bas))
                for (var t = bl.bas; t + sureDk <= bl.bit; t += bl.slot)
                {
                    var bas = gun.ToDateTime(TimeOnly.MinValue).AddMinutes(t);
                    var bit = bas.AddMinutes(Math.Max(sureDk, 1));
                    if (!dolu.Any(d => d.bas < bit && bas < d.bit)) return bas;
                }
        return null;
    }
}
