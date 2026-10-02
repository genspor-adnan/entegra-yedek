using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE ŞABLONLARI — bölüm ve doktora göre (927; mockup
/// Ekranlar/Muayene/muayene_sablon_listesi.html · muayene_sablon_karti.html).
///
/// Kart yazımı genel kart ucundan (muayene-sablon); burada kartın DÜĞMELERİ:
/// <list type="bullet">
/// <item>Kopyala (bana): ortak şablonu kullanıcının kendi şablonu olarak
///   çoğaltır (alanlarıyla); ortak şablon değişmez, kaynak iz olarak kalır.</item>
/// <item>Bölüm varsayılanı: bölümde tek ⭐ - eskisi AYNI işlemde kalkar
///   (kısmi benzersiz indeks ikinciye izin vermez).</item>
/// <item>Kullanım ve geçmiş: muayene.sablon_id ve islem_log'dan okunur.</item>
/// </list>
/// </summary>
public static class MuayeneSablonUclari
{
    private sealed record SablonKodu(string Kod);
    private sealed record SablonKapsami(int? Bolum, int? Hekim, short Durum);

    /// <summary>Bölüm ortak ve başka doktorların şablonlarını yönetme yetkisi (929).</summary>
    public const string YonetimAksiyonu = "muayene.sablon_yonet";

    /// <summary>
    /// DOKTOR YALNIZ KENDİ ŞABLONUNU DÜZENLER (kullanıcı; 929). Genel kart
    /// uçları (ekle / değiştir / sil) "muayene-sablon" için bunu çağırır:
    /// <c>muayene.sablon_yonet</c> yetkisi olmayan kullanıcı
    /// <list type="bullet">
    /// <item>yalnız doktoru KENDİSİ olan şablonu değiştirir / siler;</item>
    /// <item>yeni şablonu yalnız kendi adına açar (bölüm ortak açamaz);</item>
    /// <item>şablonu başkasına ya da bölüm ortağa ÇEVİREMEZ.</item>
    /// </list>
    /// Ortak şablonu kendine uyarlamanın yolu "Kopyala (bana)" - ortak şablon değişmez.
    /// Kullanıcı kimliği doktorun taraf kaydıdır (hekim_id = KullaniciId).
    /// </summary>
    public static async Task YazmaKuraliAsync(Cekirdek.Katalog.KartTanimi tanim, IstekBaglami baglam,
        IDictionary<string, object?>? degerler, VeriKaynagi veri, long? id, CancellationToken iptal)
    {
        if (tanim.Ad != "muayene-sablon" || baglam.Yetkiler.AksiyonVar(YonetimAksiyonu)) return;
        const string yol = " Ortak şablonu kendinize uyarlamak için \"Kopyala (bana)\" kullanın.";

        if (id is not null)
        {
            var sahip = await veri.TekDegerAsync<int?>(
                "select hekim_id from public.muayene_sablon where id = @p0", [id.Value], iptal);
            if (sahip != baglam.KullaniciId)
                throw GentegreHatasi.Yasak("Bu şablonu yalnız sahibi doktor ya da şablon yöneticisi değiştirebilir." + yol);
        }

        // Doktor alanı: yeni kayıtta ZORUNLU kendisi; güncellemede verildiyse kendisi.
        object? hedef = null;
        var verildi = degerler is not null && degerler.TryGetValue("hekimId", out hedef);
        if (degerler is not null && (id is null || verildi))
        {
            var yeni = hedef is null ? (int?)null : Convert.ToInt32(hedef, System.Globalization.CultureInfo.InvariantCulture);
            if (yeni != baglam.KullaniciId)
                throw GentegreHatasi.Yasak("Şablonu yalnız kendi adınıza (Doktor = siz) açabilir / bırakabilirsiniz;"
                    + " bölüm ortak şablonu şablon yöneticisi açar." + yol);
        }
    }

    /// <summary>islem_log tablo numaraları: şablon kartı ve alan detayı.</summary>
    private const int SablonLog = 1292, AlanLog = 967;

    /// <summary>Hekim tercihi detaylarının log numaraları (931, KartKatalogu ile aynı).</summary>
    private static readonly Dictionary<int, string> TercihLoglari = new()
    {
        [1370] = "Sık Tanılar", [1371] = "Reçete Şablonları", [1372] = "İstem Panelleri",
        [1373] = "Metin Makroları", [1374] = "Kurallar",
    };

    /// <summary>
    /// ŞABLON KURALLARI (931): muayeneye uygulanan şablonların (bölüm ortak +
    /// doktorun kendi + muayeneye uygulanmış; <c>fn_muayene_sablon_kapsami</c>)
    /// AKTİF "zorunlu_*" kurallarından karşılanmayanlar. Tamamlama bunları
    /// yasal zorunluluklarla birlikte TEK SEFERDE bildirir.
    /// 933: tercihlerde doktorun şablonu bölümünkini GİZLER, kurallarda
    /// gizlemez (p_kural = true) - doktor kendi kopyasıyla bölüm kuralını atlatamaz.
    /// </summary>
    public static async Task<List<AlanHatasi>> KuralEksikleriAsync(
        Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction? islem, int muayeneId, CancellationToken iptal)
    {
        var kodlar = await b.ListeAsync("""
            select distinct k.kod
              from public.fn_muayene_sablon_kapsami(@p0, true) x
              join public.muayene_sablon_kural k on k.sablon_id = x.sablon_id and k.aktif = 1
            """, islem, [muayeneId], o => o.GetString(0), iptal);
        var eksik = new List<AlanHatasi>();
        if (kodlar.Count == 0) return eksik;

        var d = await b.TekAsync("""
            select length(btrim(coalesce(m.hikaye, ''))),
                   (select count(*) from public.muayene_bulgu u where u.muayene_id = m.id),
                   (select count(*) from public.muayene_vital v where v.muayene_id = m.id),
                   (select count(*) from public.tani t where t.muayene_id = m.id and t.tur <> 1)
              from public.muayene m where m.id = @p0
            """, islem, [muayeneId],
            o => new KuralDurumu(o.GetInt32(0), o.GetInt64(1), o.GetInt64(2), o.GetInt64(3)), iptal);
        if (d is null) return eksik;

        if (kodlar.Contains("zorunlu_hikaye") && d.Hikaye == 0)
            eksik.Add(new("hikaye", "Hikaye zorunlu (sablon kurali)."));
        if (kodlar.Contains("zorunlu_bulgu") && d.Bulgu == 0)
            eksik.Add(new("bulgular", "Sablon muayenede en az bir bulgu zorunlu (sablon kurali)."));
        if (kodlar.Contains("zorunlu_vital") && d.Vital == 0)
            eksik.Add(new("vital", "En az bir vital olcum zorunlu (sablon kurali)."));
        if (kodlar.Contains("zorunlu_ek_tani") && d.EkTani == 0)
            eksik.Add(new("tanilar", "Ana taniya ek en az bir tani zorunlu (sablon kurali)."));
        return eksik;
    }

    private sealed record KuralDurumu(int Hikaye, long Bulgu, long Vital, long EkTani);

    /// <summary>Makro kullanım sayacı isteği: kaynak 's' şablon, 'k' kurum makrosu.</summary>
    public sealed record MakroKullanimIstegi(string Kaynak, int Id);

    public static void MuayeneSablonUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/muayene-sablon").WithTags("Muayene Şablonu").RequireAuthorization();

        // POST /api/muayene-sablon/{id}/kopyala - şablonu kullanıcıya kopyala.
        //   Kod benzersiz: "<kod>-<kullanıcı>" (varsa sonuna sayı). Doktor =
        //   kullanıcının kendisi (kullanıcı kimliği personel taraf kaydıdır).
        grup.MapPost("/{id:int}/kopyala", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Ekle);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var kaynak = await b.TekAsync(
                "select kod from public.muayene_sablon where id = @p0", islem, [id],
                o => new SablonKodu(o.GetString(0)), iptal)
                ?? throw GentegreHatasi.Bulunamadi();

            var kok = $"{kaynak.Kod}-{baglam.KullaniciId}";
            if (kok.Length > 26) kok = kok[..26];
            var kod = kok;
            for (var n = 2; await b.TekDegerAsync<int>(
                     "select count(*) from public.muayene_sablon where kod = @p0", islem, [kod], iptal) > 0; n++)
                kod = $"{kok}-{n}";

            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.muayene_sablon
                       (kod, ad, bolum_id, hekim_id, tur, aciklama, sira, durum, sube_id,
                        ekleyen, varsayilan, kaynak_sablon_id)
                select @p1, left(ad || ' (kopya)', 120), bolum_id, @p2, tur, aciklama, sira, 1, sube_id,
                       @p2, 0, id
                  from public.muayene_sablon where id = @p0
                returning id
                """, islem, [id, kod, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                insert into public.muayene_sablon_alan
                       (sablon_id, grup, kod, ad, tip, secenekler, birim, normal_metni,
                        taraf_sorulur, zorunlu, sira, ekleyen)
                select @p1, grup, kod, ad, tip, secenekler, birim, normal_metni,
                       taraf_sorulur, zorunlu, sira, @p2
                  from public.muayene_sablon_alan where sablon_id = @p0
                """, islem, [id, yeniId, baglam.KullaniciId], iptal);
            // HEKİM TERCİHLERİ de kopyalanır (931): kopya şablonun bütünüdür.
            await b.CalistirAsync("""
                insert into public.muayene_sablon_tani (sablon_id, sira, icd_kod, aciklama, ekleyen)
                select @p1, sira, icd_kod, aciklama, @p2 from public.muayene_sablon_tani where sablon_id = @p0;
                insert into public.muayene_sablon_recete
                       (sablon_id, sira, grup, icd_kod, ilac_barkod, ilac_ad, doz, periyot,
                        kullanim_sekli, sure_gun, kutu, aciklama, ekleyen)
                select @p1, sira, grup, icd_kod, ilac_barkod, ilac_ad, doz, periyot,
                       kullanim_sekli, sure_gun, kutu, aciklama, @p2
                  from public.muayene_sablon_recete where sablon_id = @p0;
                insert into public.muayene_sablon_panel (sablon_id, sira, panel_id, aciklama, ekleyen)
                select @p1, sira, panel_id, aciklama, @p2 from public.muayene_sablon_panel where sablon_id = @p0;
                insert into public.muayene_sablon_makro (sablon_id, sira, kisayol, alan, metin, ekleyen)
                select @p1, sira, kisayol, alan, metin, @p2 from public.muayene_sablon_makro where sablon_id = @p0;
                insert into public.muayene_sablon_kural (sablon_id, kod, aktif, aciklama, ekleyen)
                select @p1, kod, aktif, aciklama, @p2 from public.muayene_sablon_kural where sablon_id = @p0;
                """, islem, [id, yeniId, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id = yeniId, kod, mesaj = "Şablon size kopyalandı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene-sablon/{id}/varsayilan - bölüm varsayılanı yap.
        //   Yalnız BÖLÜM ORTAK (doktoru boş, bölümü dolu) ve aktif şablon.
        grup.MapPost("/{id:int}/varsayilan", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            // Bölüm varsayılanı bütün bölümü etkiler: şablon yöneticisinin işi.
            baglam.AksiyonIste(YonetimAksiyonu);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var s = await b.TekAsync(
                "select bolum_id, hekim_id, durum from public.muayene_sablon where id = @p0", islem, [id],
                o => new SablonKapsami(o.IsDBNull(0) ? null : o.GetInt32(0),
                                       o.IsDBNull(1) ? null : o.GetInt32(1), o.GetInt16(2)), iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            if (s.Bolum is null || s.Hekim is not null || s.Durum != 1)
                throw GentegreHatasi.IsKurali(
                    "Bölüm varsayılanı yalnız bölümü seçili, doktoru boş (bölüm ortak) ve aktif şablon olabilir.");

            await b.CalistirAsync("""
                update public.muayene_sablon set varsayilan = 0, degistiren = @p2, degistirme_tarihi = now()
                 where bolum_id = @p1 and varsayilan = 1 and id <> @p0
                """, islem, [id, s.Bolum, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.muayene_sablon set varsayilan = 1, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, mesaj = "Bölüm varsayılanı yapıldı.", izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene-sablon/{id}/kullanim - son 30 gün: toplam, doktora göre, son muayeneler.
        grup.MapGet("/{id:int}/kullanim", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var doktorlar = await b.ListeAsync("""
                select coalesce(p.ad, '—'), count(*)::int
                  from public.muayene m
                  left join public.v_personel_lookup p on p.id = m.personel_id
                 where m.sablon_id = @p0 and m.muayene_tarihi >= now() - interval '30 days'
                 group by p.ad order by 2 desc limit 20
                """, null, [id], o => new { ad = o.GetString(0), adet = o.GetInt32(1) }, iptal);
            var son = await b.ListeAsync("""
                select m.id, m.muayene_tarihi, coalesce(h.unvan, ''), coalesce(p.ad, '')
                  from public.muayene m
                  left join public.taraf h on h.id = m.taraf_id
                  left join public.v_personel_lookup p on p.id = m.personel_id
                 where m.sablon_id = @p0
                 order by m.muayene_tarihi desc limit 10
                """, null, [id],
                o => new { muayeneId = o.GetInt32(0), tarih = o.GetDateTime(1),
                           hasta = o.GetString(2), doktor = o.GetString(3) }, iptal);
            return Results.Ok(new {
                toplam30 = doktorlar.Sum(d => d.adet), doktorSayisi = doktorlar.Count,
                doktorlar, son, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene-sablon/muayene/{muayeneId}/sablonlar - muayenede uygulanabilecek
        //   şablonlar ÖNCELİK SIRASIYLA (933, kullanıcı: "doktor adına şablon varsa onu
        //   kullansın yoksa genel branş şablonu"): 0 doktorun bu bölümdeki şablonları,
        //   1 bölüm ortak (⭐ varsayılan önce), 2 diğer aktif şablonlar. `onerilen`:
        //   doktorun fizik muayene şablonu, yoksa bölüm varsayılanı, yoksa bölümün
        //   ilk ortak fizik muayene şablonu. Doktor = muayenenin doktoru (yoksa kullanıcı).
        grup.MapGet("/muayene/{muayeneId:int}/sablonlar", async (
            int muayeneId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var sablonlar = await b.ListeAsync("""
                with m as (
                  select bolum_id, coalesce(personel_id, @p1) hekim from public.muayene where id = @p0
                )
                select s.id, s.ad, s.tur, s.varsayilan,
                       case when s.hekim_id = m.hekim and s.bolum_id = m.bolum_id then 0
                            when s.hekim_id is null and s.bolum_id = m.bolum_id then 1
                            else 2 end oncelik,
                       coalesce((select a.ad from public.v_personel_lookup a where a.id = s.hekim_id), '') doktor,
                       (select count(*)::int from public.muayene_sablon_alan x where x.sablon_id = s.id) alan
                  from public.muayene_sablon s cross join m
                 where s.durum = 1
                   -- başka doktorun kişisel şablonu listelenmez
                   and (s.hekim_id is null or s.hekim_id = m.hekim)
                 order by oncelik, (s.tur <> 1), s.varsayilan desc, s.sira, s.ad
                """, null, [muayeneId, baglam.KullaniciId], o => new
                {
                    id = o.GetInt32(0), ad = o.GetString(1), tur = (int)o.GetInt16(2),
                    varsayilan = o.GetInt16(3) == 1, oncelik = o.GetInt32(4),
                    doktor = o.GetString(5), alanSayisi = o.GetInt32(6),
                }, iptal);
            var onerilen = sablonlar.FirstOrDefault(s => s.oncelik < 2 && s.tur == 1);
            return Results.Ok(new { sablonlar, onerilen, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene-sablon/muayene/{muayeneId}/tercihler - muayeneye uygulanan
        //   şablonların (fn_muayene_sablon_kapsami) sık tanıları, reçete şablonları,
        //   istem panelleri ve makroları. Doktorun kendi şablonundakiler önce gelir;
        //   aynı tanı / panel iki şablonda varsa bir kez döner.
        grup.MapGet("/muayene/{muayeneId:int}/tercihler", async (
            int muayeneId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var tanilar = await b.ListeAsync("""
                select kod, ad from (
                  select distinct on (t.icd_kod) t.icd_kod kod, coalesce(i.ad, '') ad,
                         case x.kisisel when 1 then 0 when 2 then 1 else 2 end oncelik, t.sira
                    from public.fn_muayene_sablon_kapsami(@p0) x
                    join public.muayene_sablon_tani t on t.sablon_id = x.sablon_id
                    left join public.icd i on i.kod = t.icd_kod
                   order by t.icd_kod, oncelik, t.sira) q
                 order by oncelik, sira, kod
                """, null, [muayeneId], o => new { kod = o.GetString(0), ad = o.GetString(1) }, iptal);
            var receteSatirlari = await b.ListeAsync("""
                select s.ad, r.grup, r.ilac_barkod, r.ilac_ad, r.doz, r.periyot, r.kullanim_sekli,
                       r.sure_gun, r.kutu, r.aciklama, r.icd_kod
                  from public.fn_muayene_sablon_kapsami(@p0) x
                  join public.muayene_sablon s on s.id = x.sablon_id
                  join public.muayene_sablon_recete r on r.sablon_id = x.sablon_id
                 order by case x.kisisel when 1 then 0 when 2 then 1 else 2 end, s.id, r.grup, r.sira, r.id
                """, null, [muayeneId], o => new
                {
                    sablon = o.GetString(0), grup = o.GetString(1), barkod = o.GetString(2),
                    ilac = o.GetString(3), doz = o.GetString(4), periyot = o.GetString(5),
                    kullanimSekli = (int)o.GetInt16(6), sureGun = (int)o.GetInt16(7),
                    kutu = (int)o.GetInt16(8), aciklama = o.GetString(9), icdKod = o.GetString(10),
                }, iptal);
            var receteler = receteSatirlari
                .GroupBy(r => (r.sablon, r.grup))
                .Select(g => new { g.Key.sablon, g.Key.grup, satirlar = g.ToList() })
                .ToList();
            var paneller = await b.ListeAsync("""
                select id, kod, ad from (
                  select distinct on (p.id) p.id, p.kod, p.ad,
                         case x.kisisel when 1 then 0 when 2 then 1 else 2 end oncelik, t.sira
                    from public.fn_muayene_sablon_kapsami(@p0) x
                    join public.muayene_sablon_panel t on t.sablon_id = x.sablon_id
                    join public.lab_panel p on p.id = t.panel_id and p.durum = 0
                   order by p.id, oncelik, t.sira) q
                 order by oncelik, sira, ad
                """, null, [muayeneId],
                o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2) }, iptal);
            // MAKROLAR: şablonunkiler + kurum makroları (metin_makro, 411; doktor /
            //   bölüm kapsamı tutan aktif satırlar). Aynı kısayol+alan şablonda
            //   da varsa ŞABLONUNKİ geçer: bölüm/doktor tercihi kurum geneline üstündür.
            var makrolar = await b.ListeAsync("""
                select kisayol, alan, metin, kaynak, id, kullanim from (
                  select distinct on (kisayol, alan) kisayol, alan, metin, kaynak, id, kullanim from (
                    select t.kisayol, t.alan, t.metin, 's' kaynak, t.id, t.kullanim,
                           case x.kisisel when 1 then 0 when 2 then 1 else 2 end oncelik, t.sira
                      from public.fn_muayene_sablon_kapsami(@p0) x
                      join public.muayene_sablon_makro t on t.sablon_id = x.sablon_id
                    union all
                    select k.kisayol, k.alan, k.metin, 'k', k.id, k.kullanim,
                           case when k.hekim_id is not null then 3 when k.bolum_id is not null then 4 else 5 end, 0
                      from public.metin_makro k
                      join public.muayene m on m.id = @p0
                     where k.durum = 1
                       and (k.hekim_id is null or k.hekim_id = m.personel_id)
                       and (k.bolum_id is null or k.bolum_id = m.bolum_id)) u
                   order by kisayol, alan, oncelik, sira) q
                 order by kisayol, alan
                """, null, [muayeneId],
                o => new { kisayol = o.GetString(0), alan = o.GetString(1), metin = o.GetString(2),
                           kaynak = o.GetString(3), id = o.GetInt32(4), kullanim = o.GetInt32(5) }, iptal);
            return Results.Ok(new { tanilar, receteler, paneller, makrolar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene-sablon/makro-kullanim - muayenede alana yazılan makronun
        //   kullanım sayısı (932): ipucu çipi ya da kısayol + boşluk. kaynak 's' =
        //   şablon makrosu, 'k' = kurum makrosu (metin_makro). Yalnız sayaç:
        //   islem_log'a yazılmaz (her tıkta log satırı gürültü olurdu).
        grup.MapPost("/makro-kullanim", async (
            MakroKullanimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            var tablo = istek.Kaynak switch
            {
                "s" => "public.muayene_sablon_makro",
                "k" => "public.metin_makro",
                _ => throw GentegreHatasi.Dogrulama("Makro kaynağı geçersiz.", [new("kaynak", "'s' ya da 'k' olmalı.")]),
            };
            var n = await veri.CalistirAsync(
                $"update {tablo} set kullanim = kullanim + 1 where id = @p0", [istek.Id], iptal);
            if (n == 0) throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene-sablon/{id}/gecmis - şablon ve alanlarının değişiklik kaydı.
        grup.MapGet("/{id:int}/gecmis", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select g.tarih, coalesce(k.ad, ''), g.islem_tipi, g.tablo_id, coalesce(g.bilgi::text, '')
                  from public.islem_log g
                  left join public.v_kullanici_lookup k on k.id = g.kullanici_id
                 where (g.tablo_id = @p1 and g.kayit_id = @p0)
                    or (g.tablo_id = @p2 and (g.ust_kayit_id = @p0
                        or g.kayit_id in (select a.id from public.muayene_sablon_alan a where a.sablon_id = @p0)))
                    or (g.tablo_id = any(@p3) and g.ust_kayit_id = @p0)
                 order by g.tarih desc, g.id desc
                 limit 60
                """, null, [id, SablonLog, AlanLog, TercihLoglari.Keys.ToArray()],
                o => new { tarih = o.GetDateTime(0), kullanici = o.GetString(1),
                           islemTipi = (int)o.GetInt16(2), alan = o.GetInt32(3) == AlanLog,
                           bolum = o.GetInt32(3) == AlanLog ? "Alanlar"
                                 : TercihLoglari.GetValueOrDefault(o.GetInt32(3), "Şablon"),
                           bilgi = o.GetString(4) }, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });
    }
}
