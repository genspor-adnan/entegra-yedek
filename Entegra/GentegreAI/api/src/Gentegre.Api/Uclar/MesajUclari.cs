using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MESAJLAR uçları (341/342) — İletişim &amp; AI › Mesajlar.
///
/// Mockup: `Ekranlar/umesajlar.html`. Üç panel: sohbet listesi · akış · sohbet
/// bilgisi. Uçlar da bu üç panele göre bölündü.
///
/// OKUNDU bilgisi mesaj başına tutulmaz: `mesaj_uye.son_okuma` damgası
/// (342) - sohbet açıldığında ileri taşınır. Gerçek zamanlı iletim (websocket)
/// YOK; istemci listeyi kısa aralıkla tazeliyor. Yazışma trafiği kurum içi ve
/// düşük hacimli, ayrı bir soket altyapısı kurmanın bedeli bugün için karşılığı
/// olmayan bir yatırım olurdu - arayüz tarafı değişmeden sonradan eklenebilir.
/// </summary>
public static class MesajUclari
{
    public sealed record SohbetIstegi(short Tip, string? Ad, IReadOnlyList<int> Uyeler);
    public sealed record KayitIstegi(string Modul, int KayitId, string? Ozet);
    public sealed record GonderIstegi(string Metin, int? YanitId, KayitIstegi? Kayit);
    public sealed record BayrakIstegi(short? Favori, short? Sabit, short? Sessiz, short? Arsiv);


    /// <summary>Kullanıcı bu sohbetin üyesi mi - değilse hiçbir uç çalışmaz.</summary>
    private static async Task UyeMiAsync(NpgsqlConnection baglanti, int sohbetId, int kullaniciId,
                                         CancellationToken iptal)
    {
        var v = await baglanti.TekAsync(
            "select 1 from public.mesaj_uye where sohbet_id = @p0 and kullanici_id = @p1 "
            + "and ayrilma_tarihi is null", null, [sohbetId, kullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (v is null)
            throw GentegreHatasi.IsKurali("Bu sohbetin üyesi değilsiniz.");
    }

    public static void MesajUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/mesaj").WithTags("Mesaj").RequireAuthorization();

        // --------------------------------------------------- sohbet listesi --
        // GET /api/mesaj/sohbetler?filtre=tumu|okunmamis|grup|favori|arsiv&ara=
        grup.MapGet("/sohbetler", async (
            string? filtre, string? ara, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // Arşiv AYRI bir çip: arşivlenen sohbet öteki çiplerde görünmez -
            //   yoksa "Tümü" listesi kullanıcının kaldırdığı sohbetlerle dolar.
            var kosul = (filtre ?? "tumu") switch
            {
                "okunmamis" => "and v.okunmamis > 0 and v.arsiv = 0",
                "grup"      => "and v.tip = 2 and v.arsiv = 0",
                "favori"    => "and v.favori = 1 and v.arsiv = 0",
                "arsiv"     => "and v.arsiv = 1",
                _           => "and v.arsiv = 0",
            };

            var sohbetler = await baglanti.ListeAsync($"""
                select v.id, v.tip, v.baslik, v.karsi_id as "karsiId",
                       v.son_mesaj_tarihi as "sonTarih", coalesce(v.son_metin, '') as "sonMetin",
                       v.son_gonderen_id as "sonGonderenId", v.okunmamis,
                       v.uye_sayisi as "uyeSayisi", v.favori, v.sabit, v.sessiz, v.arsiv, v.rol
                  from public.v_mesaj_sohbet v
                 where v.kullanici_id = @p0 {kosul}
                   and (@p1 = '' or v.baslik ilike '%' || @p1 || '%'
                        or coalesce(v.son_metin, '') ilike '%' || @p1 || '%')
                 order by v.sabit desc, v.son_mesaj_tarihi desc nulls last, v.id desc
                """, null, [baglam.KullaniciId, ara ?? ""], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Durum çubuğu sayaçları (mockup): okunmamış mesaj / sohbet.
            var ozet = await baglanti.TekAsync("""
                select coalesce(sum(v.okunmamis), 0)::int as "okunmamisMesaj",
                       count(*) filter (where v.okunmamis > 0)::int as "okunmamisSohbet",
                       -- Mockup durum cubugu: BUGUN gonderilen mesaj / ek /
                       --   ilistirilen kayit - yalniz kullanicinin uyesi
                       --   oldugu sohbetlerden sayilir.
                       (select count(*) from public.mesaj m
                         where m.durum = 1 and m.tarih::date = current_date
                           and exists (select 1 from public.mesaj_uye u
                                        where u.sohbet_id = m.sohbet_id
                                          and u.kullanici_id = @p0))::int as "bugunMesaj",
                       (select count(*) from public.mesaj_ek e
                         join public.mesaj m on m.id = e.mesaj_id
                         where m.tarih::date = current_date
                           and exists (select 1 from public.mesaj_uye u
                                        where u.sohbet_id = m.sohbet_id
                                          and u.kullanici_id = @p0))::int as "bugunEk",
                       (select count(*) from public.mesaj_kayit k
                         join public.mesaj m on m.id = k.mesaj_id
                         where m.tarih::date = current_date
                           and exists (select 1 from public.mesaj_uye u
                                        where u.sohbet_id = m.sohbet_id
                                          and u.kullanici_id = @p0))::int as "bugunKayit"
                  from public.v_mesaj_sohbet v
                 where v.kullanici_id = @p0 and v.arsiv = 0
                """, null, [baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { sohbetler, ozet });
        });

        // ------------------------------------------------------ yeni sohbet --
        // POST /api/mesaj/sohbet  {tip, ad, uyeler[]}
        grup.MapPost("/sohbet", async (
            SohbetIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Ekle);

            var uyeler = (istek.Uyeler ?? []).Where(u => u > 0).Distinct().ToList();
            if (uyeler.Count == 0)
                throw GentegreHatasi.IsKurali("En az bir kişi seçin.");
            if (istek.Tip == 2 && string.IsNullOrWhiteSpace(istek.Ad))
                throw GentegreHatasi.IsKurali("Grup adı zorunludur.");

            await using var baglanti = await veri.AcAsync(iptal);

            // KİŞİ SOHBETİ TEKİLDİR: aynı iki kişi arasında ikinci sohbet
            //   açılmaz - yoksa yazışma iki listeye bölünür ve kullanıcı
            //   "yazdım ama görmedi" durumuna düşer.
            if (istek.Tip == 1 && uyeler.Count == 1)
            {
                var mevcut = await baglanti.TekAsync("""
                    select s.id from public.mesaj_sohbet s
                     where s.tip = 1 and s.durum = 1
                       and exists (select 1 from public.mesaj_uye u where u.sohbet_id = s.id
                                    and u.kullanici_id = @p0)
                       and exists (select 1 from public.mesaj_uye u where u.sohbet_id = s.id
                                    and u.kullanici_id = @p1)
                       and (select count(*) from public.mesaj_uye u where u.sohbet_id = s.id) = 2
                     order by s.id limit 1
                    """, null, [baglam.KullaniciId, uyeler[0]], OkuyucuGenisletmeleri.Sozluk, iptal);
                if (mevcut is not null)
                    return Results.Ok(new { id = Convert.ToInt32(mevcut["id"]), mevcutMu = true });
            }

            await using var tx = await baglanti.BeginTransactionAsync(iptal);

            var yeni = await baglanti.TekAsync("""
                insert into public.mesaj_sohbet (tip, ad, olusturan, son_mesaj_tarihi)
                values (@p0, @p1, @p2, (now())::timestamp)
                returning id
                """, tx, [istek.Tip, istek.Ad ?? "", baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var sohbetId = Convert.ToInt32(yeni!["id"]);

            // Kurucu YÖNETİCİ rolüyle girer (grup adını değiştirebilsin,
            //   üye ekleyip çıkarabilsin).
            await baglanti.CalistirAsync("""
                insert into public.mesaj_uye (sohbet_id, kullanici_id, rol, son_okuma)
                values (@p0, @p1, 2, (now())::timestamp)
                """, tx, [sohbetId, baglam.KullaniciId], iptal);

            foreach (var u in uyeler.Where(u => u != baglam.KullaniciId))
                await baglanti.CalistirAsync("""
                    insert into public.mesaj_uye (sohbet_id, kullanici_id, rol)
                    values (@p0, @p1, 1)
                    on conflict (sohbet_id, kullanici_id) do nothing
                    """, tx, [sohbetId, u], iptal);

            await tx.CommitAsync(iptal);
            return Results.Ok(new { id = sohbetId, mevcutMu = false });
        });

        // ----------------------------------------------------- mesaj akışı ---
        // GET /api/mesaj/{sohbetId}/mesajlar?sonrasi=<id>
        grup.MapGet("/{sohbetId:int}/mesajlar", async (
            int sohbetId, int? sonrasi, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await UyeMiAsync(baglanti, sohbetId, baglam.KullaniciId, iptal);

            // `sonrasi` verilirse yalnız YENİ mesajlar döner: tazeleme her
            //   seferinde bütün akışı taşımasın.
            var mesajlar = await baglanti.ListeAsync("""
                select m.id, m.gonderen_id as "gonderenId",
                       coalesce(nullif(btrim(t.unvan), ''), t.kod) as gonderen,
                       m.tip, case when m.durum = 2 then '' else m.metin end as metin,
                       m.tarih, m.durum, m.sabit, m.yanit_id as "yanitId",
                       (select left(y.metin, 120) from public.mesaj y where y.id = m.yanit_id) as "yanitMetin",
                       (select coalesce(nullif(btrim(t2.unvan), ''), t2.kod)
                          from public.mesaj y join public.taraf t2 on t2.id = y.gonderen_id
                         where y.id = m.yanit_id) as "yanitGonderen",
                       -- Okundu: karşı tarafın son okuma damgası bu mesajı geçtiyse.
                       (select count(*) from public.mesaj_uye u
                         where u.sohbet_id = m.sohbet_id and u.kullanici_id <> m.gonderen_id
                           and u.ayrilma_tarihi is null
                           and (u.son_okuma is null or u.son_okuma < m.tarih))::int as "okumayan"
                  from public.mesaj m
                  join public.taraf t on t.id = m.gonderen_id
                 where m.sohbet_id = @p0
                   and (@p1 = 0 or m.id > @p1)
                 order by m.tarih, m.id
                """, null, [sohbetId, sonrasi ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sohbet = await baglanti.TekAsync("""
                select v.id, v.tip, v.baslik, v.karsi_id as "karsiId", v.uye_sayisi as "uyeSayisi",
                       v.favori, v.sabit, v.sessiz, v.arsiv, v.rol
                  from public.v_mesaj_sohbet v
                 where v.id = @p0 and v.kullanici_id = @p1
                """, null, [sohbetId, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { sohbet, mesajlar });
        });

        // POST /api/mesaj/{sohbetId}/gonder
        grup.MapPost("/{sohbetId:int}/gonder", async (
            int sohbetId, GonderIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Ekle);

            var metin = (istek.Metin ?? "").Trim();
            if (metin.Length == 0) throw GentegreHatasi.IsKurali("Boş mesaj gönderilemez.");

            await using var baglanti = await veri.AcAsync(iptal);
            await UyeMiAsync(baglanti, sohbetId, baglam.KullaniciId, iptal);

            var yeni = await baglanti.TekAsync("""
                insert into public.mesaj (sohbet_id, gonderen_id, tip, metin, yanit_id)
                values (@p0, @p1, 1, @p2, nullif(@p3, 0))
                returning id, tarih
                """, null,
                [sohbetId, baglam.KullaniciId, metin, istek.YanitId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KAYIT İLİŞTİRME (mockup "Gentegre Kaydı İliştir"): kartın kendisi
            //   kopyalanmaz - modül + kayıt kimliği yazılır, "Kartı Aç" ilgili
            //   ekranı çalıştırır ve yetki orada kontrol edilir.
            if (istek.Kayit is { } k && !string.IsNullOrWhiteSpace(k.Modul) && k.KayitId > 0)
                await baglanti.CalistirAsync("""
                    insert into public.mesaj_kayit (mesaj_id, modul, kayit_id, ozet)
                    values (@p0, @p1, @p2, @p3)
                    """, null,
                    [Convert.ToInt32(yeni!["id"]), k.Modul, k.KayitId, k.Ozet ?? ""], iptal);

            // Gönderen kendi mesajını okumuş sayılır: kendi yazdığı mesaj
            //   "okunmamış" sayacına düşmesin.
            await baglanti.CalistirAsync("""
                update public.mesaj_uye set son_okuma = (now())::timestamp
                 where sohbet_id = @p0 and kullanici_id = @p1
                """, null, [sohbetId, baglam.KullaniciId], iptal);

            return Results.Ok(new { id = Convert.ToInt32(yeni!["id"]), tarih = yeni["tarih"] });
        });

        // POST /api/mesaj/{sohbetId}/okundu — son okuma damgasını ileri taşır.
        grup.MapPost("/{sohbetId:int}/okundu", async (
            int sohbetId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await baglanti.CalistirAsync("""
                update public.mesaj_uye set son_okuma = (now())::timestamp
                 where sohbet_id = @p0 and kullanici_id = @p1
                """, null, [sohbetId, baglam.KullaniciId], iptal);

            return Results.Ok(new { tamam = true });
        });

        // POST /api/mesaj/{sohbetId}/bayrak — favori / sabit / sessiz / arşiv.
        //   Bayraklar KİŞİYE özel (342): birinin sabitlemesi ötekinin listesini
        //   değiştirmez.
        grup.MapPost("/{sohbetId:int}/bayrak", async (
            int sohbetId, BayrakIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await UyeMiAsync(baglanti, sohbetId, baglam.KullaniciId, iptal);

            await baglanti.CalistirAsync("""
                update public.mesaj_uye
                   set favori = coalesce(nullif(@p2, -1), favori),
                       sabit  = coalesce(nullif(@p3, -1), sabit),
                       sessiz = coalesce(nullif(@p4, -1), sessiz),
                       arsiv  = coalesce(nullif(@p5, -1), arsiv)
                 where sohbet_id = @p0 and kullanici_id = @p1
                """, null,
                [sohbetId, baglam.KullaniciId, (short)(istek.Favori ?? -1),
                 (short)(istek.Sabit ?? -1), (short)(istek.Sessiz ?? -1),
                 (short)(istek.Arsiv ?? -1)], iptal);

            return Results.Ok(new { tamam = true });
        });

        // ------------------------------------------------- sohbet bilgisi ----
        // GET /api/mesaj/{sohbetId}/bilgi — sağ panel: künye, üyeler, ekler,
        //   iliştirilen kayıtlar, sabitlenen mesajlar.
        grup.MapGet("/{sohbetId:int}/bilgi", async (
            int sohbetId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await UyeMiAsync(baglanti, sohbetId, baglam.KullaniciId, iptal);

            var uyeler = await baglanti.ListeAsync("""
                select u.kullanici_id as "kullaniciId",
                       coalesce(nullif(btrim(t.unvan), ''), t.kod) as ad,
                       u.rol, u.son_okuma as "sonOkuma",
                       coalesce(p.gorev, '') as gorev, coalesce(t.telefon, '') as telefon,
                       coalesce(t.eposta, '') as eposta
                  from public.mesaj_uye u
                  join public.taraf t on t.id = u.kullanici_id
                  left join public.taraf_personel p on p.id = u.kullanici_id
                 where u.sohbet_id = @p0 and u.ayrilma_tarihi is null
                 order by u.rol desc, ad
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var ekler = await baglanti.ListeAsync("""
                select e.id, e.ad, e.dokuman_id as "dokumanId", m.tarih
                  from public.mesaj_ek e join public.mesaj m on m.id = e.mesaj_id
                 where m.sohbet_id = @p0 and m.durum = 1
                 order by m.tarih desc limit 50
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var kayitlar = await baglanti.ListeAsync("""
                select k.id, k.modul, k.kayit_id as "kayitId", k.ozet, m.tarih
                  from public.mesaj_kayit k join public.mesaj m on m.id = k.mesaj_id
                 where m.sohbet_id = @p0 and m.durum = 1
                 order by m.tarih desc limit 50
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sabitler = await baglanti.ListeAsync("""
                select m.id, m.metin, m.tarih,
                       coalesce(nullif(btrim(t.unvan), ''), t.kod) as gonderen
                  from public.mesaj m join public.taraf t on t.id = m.gonderen_id
                 where m.sohbet_id = @p0 and m.sabit = 1 and m.durum = 1
                 order by m.tarih desc
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KÜNYE (mockup sağ panel): kişi sohbetinde karşı tarafın kartı -
            //   grup sohbetinde anlamı yok, null döner.
            var kunye = await baglanti.TekAsync("""
                select t.id, coalesce(nullif(btrim(t.unvan), ''), t.kod) as ad,
                       t.kod,
                       coalesce(p.gorev, '') as gorev,
                       coalesce(t.telefon, '') as telefon, coalesce(t.cep_tel, '') as cep,
                       coalesce(t.eposta, '') as eposta,
                       coalesce(s2.ad, '') as sube,
                       coalesce(kd.ad, '') as departman,
                       -- BAGLI CARI (mockup kunyesinde "Cari" satiri + "Cari
                       --   Kartini Ac"): kisi bir cariye bagliysa gosterilir.
                       t.bag_id as "cariId",
                       coalesce((select coalesce(nullif(btrim(b.unvan), ''), b.kod)
                                   from public.taraf b where b.id = t.bag_id), '') as cari
                  from public.v_mesaj_sohbet v
                  join public.taraf t on t.id = v.karsi_id
                  left join public.taraf_personel p on p.id = t.id
                  left join public.sube s2 on s2.id = p.sube_id
                  left join public.kod_liste kl on kl.kod = 'personel.departman'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = p.departman
                 where v.id = @p0 and v.kullanici_id = @p1 and v.tip = 1
                """, null, [sohbetId, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kunye, uyeler, ekler, kayitlar, sabitler });
        });

        // POST /api/mesaj/mesaj/{id}/sabit — mesajı sabitle / çöz.
        grup.MapPost("/mesaj/{id:int}/sabit", async (
            int id, bool? geriAl, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await baglanti.CalistirAsync("""
                update public.mesaj m set sabit = @p1
                 where m.id = @p0
                   and exists (select 1 from public.mesaj_uye u
                                where u.sohbet_id = m.sohbet_id and u.kullanici_id = @p2)
                """, null, [id, (short)(geriAl == true ? 0 : 1), baglam.KullaniciId], iptal);

            return Results.Ok(new { tamam = true });
        });

        // DELETE /api/mesaj/mesaj/{id} — KENDİ mesajını siler (metin gizlenir,
        //   satır kalır: okundu hesabı ve yanıt zinciri bozulmasın).
        grup.MapDelete("/mesaj/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Sil);

            await using var baglanti = await veri.AcAsync(iptal);
            var etkilenen = await baglanti.CalistirAsync("""
                update public.mesaj set durum = 2
                 where id = @p0 and gonderen_id = @p1 and durum = 1
                """, null, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Yalnız kendi mesajınızı silebilirsiniz.");

            return Results.Ok(new { tamam = true });
        });

        // GET /api/mesaj/kisiler?ara= — yeni sohbet için kullanıcı arama.
        //   Sohbet KULLANICISI olanlar listelenir (kullanıcı hesabı olmayan
        //   personele mesaj gönderilemez - okuyacağı bir ekran yok).
        grup.MapGet("/kisiler", async (
            string? ara, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("mesaj", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var kisiler = await baglanti.ListeAsync("""
                select k.id, coalesce(nullif(btrim(t.unvan), ''), k.kod) as ad,
                       coalesce(p.gorev, '') as gorev
                  from public.taraf_kullanici k
                  join public.taraf t on t.id = k.id
                  left join public.taraf_personel p on p.id = k.id
                 where k.aktif = 1 and k.id <> @p0
                   and (@p1 = '' or coalesce(t.unvan, '') ilike '%' || @p1 || '%'
                        or k.kod ilike '%' || @p1 || '%')
                 order by ad limit 50
                """, null, [baglam.KullaniciId, ara ?? ""], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kisiler });
        });
    }
}
