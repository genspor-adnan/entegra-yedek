using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖSTERGE PANELLERİ + ROL BAŞLANGICI (1103, mockup Ekranlar/Dashboard/gosterge_panelleri.html).
///
/// <para><b>Panel veri, gösterge kod:</b> paneller ve öğeleri tabloda (sayıları
/// zamanla artar); her gösterge değeri sunucudaki sabit katalogdan
/// (<c>fn_gosterge_kutu</c> / <c>fn_gosterge_blok</c>) hesaplanır.</para>
///
/// <para><b>Kim görür = rol yetki matrisi:</b> panel <c>gosterge.&lt;kod&gt;</c>
/// yetkisinde Gör olan kullanıcıya listelenir ve açılır; yetkisiz panel hiç dönmez.</para>
/// </summary>
public static class GostergeUclari
{
    public static void GostergeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/gosterge").WithTags("Gösterge panelleri").RequireAuthorization();

        // GET /api/gosterge - kullanıcının görebildiği paneller (Ctrl+K, Başlangıç ilk kutucuğu).
        //   Her panelin İLK kutu göstergesi de döner: Başlangıç satırında yanında yazılır.
        grup.MapGet("/", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var paneller = await b.ListeAsync("""
                select p.kod, p.ad, p.ikon, p.aciklama,
                       public.fn_gosterge_kutu((select o.gosterge_kod from public.gosterge_paneli_oge o
                                                 where o.panel_id = p.id and o.tur = 1 order by o.sira limit 1))::text as ilk
                  from public.gosterge_paneli p where p.aktif = 1 order by p.sira, p.ad
                """, null, [], o => new
                {
                    kod = o.GetString(0), ad = o.GetString(1), ikon = o.GetString(2), aciklama = o.GetString(3),
                    ilk = o.IsDBNull(4) ? (System.Text.Json.JsonElement?)null
                                        : System.Text.Json.JsonDocument.Parse(o.GetString(4)).RootElement.Clone(),
                }, iptal);
            // MENÜ DÜZENİ (17.10.2026): kurum profilinde gizlenen panel (menu_duzen `gosterge.<kod>`) listelenmez.
            return Results.Ok(paneller.Where(p => baglam.Yetkiler.Var("gosterge." + p.kod, Islem.Gor)
                                                  && !baglam.GizliEkranlar.Contains("gosterge." + p.kod)));
        });

        // GET /api/gosterge/tumu - MENÜ DÜZENİ editörü için bütün aktif paneller (yetkiden bağımsız;
        //   GenProfil'de teknisyen profilin hangi panelleri göstereceğini seçer).
        grup.MapGet("/tumu", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("menu.duzen", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var paneller = await b.ListeAsync(
                "select kod, ad, ikon from public.gosterge_paneli where aktif = 1 order by sira, ad", null, [],
                o => new { kod = o.GetString(0), ad = o.GetString(1), ikon = o.GetString(2) }, iptal);
            return Results.Ok(paneller);
        });

        // GET /api/gosterge/{kod} - panelin kutu ve bloklarının güncel değerleri.
        grup.MapGet("/{kod}", async (string kod, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("gosterge." + kod);
            if (!baglam.Yetkiler.Var("gosterge." + kod, Islem.Gor))
                throw GentegreHatasi.Yasak("Bu gösterge paneline yetkiniz yok.");
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("""
                select jsonb_build_object(
                  'kod', p.kod, 'ad', p.ad, 'ikon', p.ikon, 'aciklama', p.aciklama,
                  'kutular', coalesce((select jsonb_agg(public.fn_gosterge_kutu(o.gosterge_kod) || jsonb_build_object('kod', o.gosterge_kod)
                                                        order by o.sira)
                                         from public.gosterge_paneli_oge o where o.panel_id = p.id and o.tur = 1
                                          and public.fn_gosterge_kutu(o.gosterge_kod) is not null), '[]'::jsonb),
                  'bloklar', coalesce((select jsonb_agg(public.fn_gosterge_blok(o.gosterge_kod) || jsonb_build_object('kod', o.gosterge_kod)
                                                        order by o.sira)
                                         from public.gosterge_paneli_oge o where o.panel_id = p.id and o.tur = 2
                                          and public.fn_gosterge_blok(o.gosterge_kod) is not null), '[]'::jsonb))::text
                  from public.gosterge_paneli p where p.kod = @p0 and p.aktif = 1
                """, null, [kod], iptal) ?? throw GentegreHatasi.Bulunamadi("Gösterge paneli bulunamadı.");
            return Results.Content(json, "application/json; charset=utf-8");
        });

        // GET /api/baslangic/bekleyen - SADE BAŞLANGIÇ "Bekleyen işler" (kullanıcı 16.10.2026:
        //   "bekleyen konsültasyonlar, sonucu gelen istemler, bugünkü randevular"). Hepsi OTURUMUN
        //   KİŞİSİNE: konsültasyon bana ya da (hekim seçilmemişse) bölümüme gelen, yanıt bekleyen;
        //   istem benim istediğim, son 7 günde sonucu gelen (lab sonuçlandı / onaylandı, radyoloji
        //   onaylandı / teslim); randevu bugün benim, iptal / gelmedi dışı. Yetki: oturum yeter -
        //   sayılar kişinin kendi işi; ekrana geçiş o ekranın yetkisine bağlı.
        yol.MapGet("/api/baslangic/bekleyen", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("""
                with ben as (select t.id, t.departman from public.taraf t where t.id = @p0)
                select jsonb_build_object(
                  'konsultasyon', (select count(*) from public.konsultasyon k, ben
                                    where k.durum in (1, 2) and (@p1 = 0 or k.sube_id = @p1)
                                      and (k.hedef_hekim_id = ben.id
                                           or (k.hedef_hekim_id is null and k.hedef_bolum_id = ben.departman))),
                  'konsultasyonGecikmis', (select count(*) from public.konsultasyon k, ben
                                    where k.durum in (1, 2) and k.son_zaman < now() and (@p1 = 0 or k.sube_id = @p1)
                                      and (k.hedef_hekim_id = ben.id
                                           or (k.hedef_hekim_id is null and k.hedef_bolum_id = ben.departman))),
                  'istemSonuc', (select count(*) from public.lab_istem li
                                  where li.personel_id = @p0 and li.durum in (4, 5)
                                    and li.sonuc_tarihi >= current_date - 6)
                              + (select count(*) from public.radyoloji_istem ri
                                  where ri.istek_hekim_id = @p0 and ri.durum in (5, 6)
                                    and ri.degistirme_tarihi >= current_date - 6),
                  'randevu', (select count(*) from public.randevu r
                               where r.hekim_id = @p0 and r.baslangic::date = current_date and r.durum in (1, 2)),
                  'randevuBekleyen', (select count(*) from public.randevu r
                               where r.hekim_id = @p0 and r.baslangic::date = current_date and r.durum = 1)
                )::text
                """, null, [baglam.KullaniciId, baglam.SubeId ?? 0], iptal);

            // ONAY BEKLEYENLER (kullanıcı 16.10.2026: "bekleyen işlere onaylanacak bir şey varsa onlar da
            //   gelmeli"): Onayımdakiler kutusunun (v_onay_kutusu) karar sırası bende olan basamakları -
            //   bana / vekâletle bana atanmış, ya da rol basamağında karar aksiyonu yetkim olan. Rol
            //   eşlemesi bildirimdekiyle aynı (OnayBildirimi.AksiyonKodu).
            var onaylar = await b.ListeAsync("""
                select coalesce(v.akis_kod, ''), coalesce(v.rol, 0)::smallint, (v.atanan_kullanici_id is not null) as kisiye,
                       count(*)::int as adet, count(*) filter (where v.gecikme_gun > 0)::int as geciken
                  from public.v_onay_kutusu v
                 where v.durum = 0 and (@p1 = 0 or v.sube_id = @p1)
                   and (v.atanan_kullanici_id is null
                        or v.atanan_kullanici_id = @p0
                        or exists (select 1 from public.onay_vekalet k
                                    where k.devreden_id = v.atanan_kullanici_id and k.devralan_id = @p0 and k.aktif = 1
                                      and current_date between k.baslangic and k.bitis))
                 group by 1, 2, 3
                """, null, [baglam.KullaniciId, baglam.SubeId ?? 0],
                o => (Akis: o.GetString(0), Rol: o.GetInt16(1), Kisiye: o.GetBoolean(2), Adet: o.GetInt32(3), Geciken: o.GetInt32(4)),
                iptal);
            var benim = onaylar.Where(x => x.Kisiye
                || (OnayBildirimi.AksiyonKodu(x.Akis, x.Rol) is { Length: > 0 } kod && baglam.Yetkiler.AksiyonVar(kod))).ToList();
            var nesne = System.Text.Json.Nodes.JsonNode.Parse(json ?? "{}")!.AsObject();
            nesne["onay"] = benim.Sum(x => x.Adet);
            nesne["onayGeciken"] = benim.Sum(x => x.Geciken);

            // ÖZLÜK BELGELERİ (kullanıcı 22.10.2026: "bir personelin eksik belgesi varsa giriş ekranında
            //   bekleyen işler altında gösterilmeli"). İki kart: oturumun KENDİ eksik / süresi dolan /
            //   yaklaşan belgeleri (kendi verisi, yetki gerekmez) ve belge takip yetkilisine kurum geneli
            //   eksiği olan personel sayısı. Kural v_personel_belge_durum'la aynı (1135-1136).
            var belgeler = await b.ListeAsync("""
                select x.belge, x.durum, x.durum_adi, x.kalan_gun
                  from public.v_personel_belge_durum x
                 where x.personel_id = @p0 and ((x.zorunlu = 1 and x.durum = 1) or x.durum in (2, 3))
                 order by x.durum, x.kalan_gun nulls first, x.belge
                """, null, [baglam.KullaniciId],
                o => new { belge = o.GetString(0), durum = o.GetInt16(1), durumAdi = o.GetString(2),
                           kalanGun = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal);
            nesne["belgeEksik"] = belgeler.Count(x => x.durum is 1 or 2);
            nesne["belgeYaklasan"] = belgeler.Count(x => x.durum == 3);
            nesne["belgeler"] = System.Text.Json.JsonSerializer.SerializeToNode(belgeler,
                new System.Text.Json.JsonSerializerOptions(System.Text.Json.JsonSerializerDefaults.Web));
            if (baglam.Yetkiler.Var("ik.belge_takip.liste", Islem.Gor) || baglam.Yetkiler.Var("ik.belge_takip", Islem.Gor))
            {
                var ik = await b.TekAsync("""
                    select count(distinct x.personel_id) filter (where (x.zorunlu = 1 and x.durum = 1) or x.durum = 2)::int,
                           count(distinct x.personel_id) filter (where x.durum = 2)::int
                      from public.v_personel_belge_durum x
                    """, null, [], o => new { kisi = o.GetInt32(0), doldu = o.GetInt32(1) }, iptal);
                nesne["ikBelgeEksikKisi"] = ik?.kisi ?? 0;
                nesne["ikBelgeDolduKisi"] = ik?.doldu ?? 0;
            }
            return Results.Content(nesne.ToJsonString(), "application/json; charset=utf-8");
        }).WithTags("Gösterge panelleri").RequireAuthorization();

        // GET /api/baslangic - kullanıcının ROLLERİNİN elle düzenlenmiş Başlangıç kutucukları.
        //   Satır yoksa boş döner: ekran rolün yetkili menüsünden öneri çizer. Satırdaki
        //   `gosterge` sayacı katalogdan doldurulur.
        yol.MapGet("/api/baslangic", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var roller = baglam.RolIdleri.Count > 0 ? baglam.RolIdleri.ToArray() : [baglam.RolId];
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("""
                select coalesce(jsonb_agg(jsonb_build_object('ad', k.ad, 'ikon', k.ikon,
                         'satirlar', (select coalesce(jsonb_agg(s || case when s ? 'gosterge'
                                              then jsonb_build_object('deger', public.fn_gosterge_kutu(s->>'gosterge'))
                                              else '{}'::jsonb end order by ord), '[]'::jsonb)
                                        from jsonb_array_elements(k.satirlar) with ordinality e(s, ord)))
                         order by k.rol_sira, k.sira), '[]'::jsonb)::text
                  from (select rb.*, array_position(@p0::int[], rb.rol_id) as rol_sira
                          from public.rol_baslangic rb where rb.rol_id = any(@p0::int[])) k
                """, null, [roller], iptal);
            return Results.Content(json ?? "[]", "application/json; charset=utf-8");
        }).WithTags("Gösterge panelleri").RequireAuthorization();
    }
}
