using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HEMŞİRE İZLEMİ (699, mockup <c>Ekranlar/Yatan/hemsire_izlem.html</c>).
///
/// <para><b>Nöbet ekranıdır:</b> ölçüm girişi, vital eğrisi, aldığı-çıkardığı
/// dengesi, risk ölçekleri ve gözlem notu aynı yerde durur. Beşi ayrı ekrana
/// bölünseydi hemşire her ölçümde dört kez gezinirdi ve kayıt nöbet sonunda
/// toplu yazılırdı — saatinde yazılmayan izlem, izlem değildir.</para>
///
/// <para><b>Sıvı dengesi HESAPLANIR, yazılmaz.</b> Gün ortasında eklenen bir
/// serum, elle tutulan toplamı sessizce yanlışlar; kalp yetmezliği ve böbrek
/// hastasında "+450" ile "+1.450" arasındaki fark tedavi değiştirir.</para>
///
/// <para><b>Erken uyarı skoru veritabanında hesaplanır</b> (699
/// <c>fn_erken_uyari</c> + tetikleyici): kural üç ayrı yazma yolunda da
/// çalışmalı. Ekranda hesaplansaydı, kart sekmesinden girilen ölçümün skoru
/// boş kalırdı.</para>
///
/// <para><b>Gözlem notu silinmez, düzeltilmez:</b> yanlış yazılan not yeni bir
/// satırla düzeltilir ve ikisi de durur. Hemşire gözlemi hukuki bir kayıttır —
/// üzerine yazılabilseydi değeri kalmazdı.</para>
/// </summary>
public static partial class YatanUclari
{
    public sealed record IzlemIstegi(
        int YatisId, DateTime? Zaman, short? Sistolik, short? Diyastolik,
        short? Nabiz, short? Solunum, decimal? Ates, short? Spo2,
        short? AgriVas, short? Gks, short? KanSekeri, string? Not);

    public sealed record SiviIstegi(int YatisId, DateTime? Zaman, short Yon, short Tur,
                                    decimal MiktarMl, string? Aciklama);

    public sealed record RiskIstegi(int YatisId, short Olcek, short? Puan,
                                    short? RiskDuzeyi, string? Onlem);

    public sealed record GozlemIstegi(int YatisId, string Not);

    private static void IzlemUclariniEkle(RouteGroupBuilder grup)
    {
        // ----------------------------------------------- nöbet ekranı verisi ----
        // TEK İSTEK: vital serisi + sıvı + risk + gözlem. Dördü aynı ekranda
        //   yan yana; ayrı isteklere bölmek ekranı parça parça doldururdu.
        grup.MapGet("/izlem", async (
            int yatisId, int? saat, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.izlem", Islem.Gor);

            // PENCERE 48 SAAT: eğri "şu an ne oluyor" sorusunu cevaplar.
            //   Yatışın tamamını çizmek, altıncı günde ilk günün ateşini
            //   bugünün ateşiyle aynı ekranda sıkıştırırdı.
            var pencere = Math.Clamp(saat ?? 48, 6, 24 * 14);

            await using var baglanti = await veri.AcAsync(iptal);

            var vitaller = await baglanti.ListeAsync("""
                select i.id, i.zaman, i.sistolik, i.diyastolik, i.nabiz, i.solunum,
                       i.ates, i.spo2, i.agri_vas, i.gks, i.kan_sekeri, i.erken_uyari,
                       i.bildirim_zamani, i.not_metin,
                       coalesce(t.unvan, '') as olcen
                  from public.yatis_izlem i
                  left join public.taraf t on t.id = i.olcen_id
                 where i.yatis_id = @p0
                   and i.zaman >= now() - make_interval(hours => @p1)
                 order by i.zaman
                """, null, [yatisId, pencere], o => new
            {
                id = o.GetInt64(0),
                zaman = o.GetDateTime(1),
                sistolik = o.IsDBNull(2) ? (int?)null : (int)o.GetInt16(2),
                diyastolik = o.IsDBNull(3) ? (int?)null : (int)o.GetInt16(3),
                nabiz = o.IsDBNull(4) ? (int?)null : (int)o.GetInt16(4),
                solunum = o.IsDBNull(5) ? (int?)null : (int)o.GetInt16(5),
                ates = o.IsDBNull(6) ? (decimal?)null : o.GetDecimal(6),
                spo2 = o.IsDBNull(7) ? (int?)null : (int)o.GetInt16(7),
                agriVas = o.IsDBNull(8) ? (int?)null : (int)o.GetInt16(8),
                gks = o.IsDBNull(9) ? (int?)null : (int)o.GetInt16(9),
                kanSekeri = o.IsDBNull(10) ? (int?)null : (int)o.GetInt16(10),
                erkenUyari = o.IsDBNull(11) ? (int?)null : (int)o.GetInt16(11),
                bildirimZamani = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
                not_ = o.GetString(13),
                olcen = o.GetString(14),
            }, iptal);

            var sivilar = await baglanti.ListeAsync("""
                select s.id, s.zaman, s.yon, s.tur, s.miktar_ml, s.aciklama,
                       coalesce(t.unvan, '') as kaydeden,
                       coalesce(k.ad, '')    as tur_ad
                  from public.yatis_sivi s
                  left join public.taraf t on t.id = s.ekleyen
                  left join public.kod_deger k on k.deger = s.tur
                   and k.liste_id = (select l.id from public.kod_liste l
                                      where l.kod = 'yatan.sivi_tur')
                 where s.yatis_id = @p0
                   and s.zaman >= now() - make_interval(hours => @p1)
                 order by s.zaman desc
                """, null, [yatisId, pencere], o => new
            {
                id = o.GetInt64(0),
                zaman = o.GetDateTime(1),
                yon = (int)o.GetInt16(2),
                tur = (int)o.GetInt16(3),
                miktarMl = o.GetDecimal(4),
                aciklama = o.GetString(5),
                kaydeden = o.GetString(6),
                turAd = o.GetString(7),
            }, iptal);

            // SIVI DENGESİ: bugünün toplamları + hastanın kilosu (idrar
            //   mL/kg/sa için). Kilo YOKSA oran hesaplanmaz - varsayılan kiloyla
            //   hesaplamak, olmayan bir ölçümü varmış gibi gösterirdi.
            var denge = await baglanti.TekAsync("""
                select coalesce(sum(case when s.yon = 1 then s.miktar_ml else 0 end), 0) as aldi,
                       coalesce(sum(case when s.yon = 2 then s.miktar_ml else 0 end), 0) as cikardi,
                       coalesce(sum(case when s.yon = 2 and s.tur = 4
                                         then s.miktar_ml else 0 end), 0) as idrar,
                       -- KİLO HASTA KARTINDA DEĞİL, SON MUAYENE VİTALİNDE:
                       --   şemada tek bir "hastanın kilosu" alanı yok ve
                       --   olmaması doğru - kilo bir ölçümdür, zamanla değişir.
                       --   İdrar mL/kg/sa için EN SON ölçülen kilo kullanılır.
                       (select mv.kilo_kg
                          from public.muayene_vital mv
                          join public.muayene m on m.id = mv.muayene_id
                         where m.taraf_id = (select y.hasta_id from public.yatis y
                                              where y.id = @p0)
                           and mv.kilo_kg is not null
                         order by m.muayene_tarihi desc limit 1) as kilo
                  from public.yatis_sivi s
                 where s.yatis_id = @p0 and s.zaman >= now() - interval '24 hours'
                """, null, [yatisId], o => new
            {
                aldi = o.GetDecimal(0),
                cikardi = o.GetDecimal(1),
                idrar = o.GetDecimal(2),
                kilo = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
            }, iptal);

            // RİSK: her ölçeğin SON değeri + yaşı. Süresi geçen ölçek ekranda
            //   sararır (24 saat) - eşiği sunucu söyler ki iki ekran aynı
            //   "eskimiş" tanımını kullansın.
            var riskler = await baglanti.ListeAsync("""
                select r.id, r.zaman, r.olcek, r.puan, r.risk_duzeyi, r.onlem,
                       coalesce(t.unvan, '') as degerlendiren,
                       coalesce(k.ad, '')    as olcek_ad,
                       (extract(epoch from (now() - r.zaman)) / 3600)::int as saat_once
                  from public.yatis_risk r
                  left join public.taraf t on t.id = r.degerlendiren_id
                  left join public.kod_deger k on k.deger = r.olcek
                   and k.liste_id = (select l.id from public.kod_liste l
                                      where l.kod = 'yatan.risk_olcek')
                 where r.yatis_id = @p0
                 order by r.zaman desc
                 limit 40
                """, null, [yatisId], o => new
            {
                id = o.GetInt64(0),
                zaman = o.GetDateTime(1),
                olcek = (int)o.GetInt16(2),
                puan = o.IsDBNull(3) ? (int?)null : (int)o.GetInt16(3),
                duzey = o.IsDBNull(4) ? (int?)null : (int)o.GetInt16(4),
                onlem = o.GetString(5),
                degerlendiren = o.GetString(6),
                olcekAd = o.GetString(7),
                saatOnce = o.GetInt32(8),
            }, iptal);

            // GÖZLEM NOTLARI izlem satırının not alanından gelir: ayrı tablo
            //   açmak, "saat 06:30'da ateş 38,9 ölçüldü ve şunu yaptım"
            //   cümlesini ölçümünden koparırdı.
            var gozlemler = vitaller
                .Where(v => !string.IsNullOrWhiteSpace(v.not_))
                .OrderByDescending(v => v.zaman)
                .Select(v => new { v.id, v.zaman, not_ = v.not_, v.olcen })
                .ToList();

            return Results.Ok(new
            {
                pencereSaat = pencere,
                vitaller,
                sivilar,
                denge = new
                {
                    denge!.aldi, denge.cikardi,
                    fark = denge.aldi - denge.cikardi,
                    denge.idrar, denge.kilo,
                    // mL/kg/sa: kilo yoksa NULL. Eşik 0,5 - altı oligüridir.
                    idrarOrani = denge.kilo is > 0
                        ? Math.Round(denge.idrar / denge.kilo.Value / 24, 2)
                        : (decimal?)null,
                },
                riskler,
                gozlemler,
            });
        });

        // --------------------------------------------------- ölçüm kaydetme ----
        grup.MapPost("/izlem", async (
            IzlemIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.izlem", Islem.Ekle);

            if (istek.YatisId <= 0)
                throw GentegreHatasi.Dogrulama("Yatış seçilmeli.",
                    new AlanHatasi("yatisId", "Zorunlu."));

            // BOŞ ÖLÇÜM SATIRI AÇILMAZ: hiçbir değeri olmayan kayıt, "ölçüm
            //   yapıldı" izlenimi verir ve eğride hayalet nokta üretir.
            var doluMu = istek.Sistolik is not null || istek.Diyastolik is not null
                      || istek.Nabiz is not null || istek.Solunum is not null
                      || istek.Ates is not null || istek.Spo2 is not null
                      || istek.AgriVas is not null || istek.Gks is not null
                      || istek.KanSekeri is not null
                      || !string.IsNullOrWhiteSpace(istek.Not);
            if (!doluMu)
                throw GentegreHatasi.Dogrulama("En az bir ölçüm ya da not girilmeli.");

            await using var baglanti = await veri.AcAsync(iptal);

            // ERKEN UYARI SKORU YAZILMAZ: veritabanı tetikleyicisi hesaplar
            //   (699). Burada hesaplasaydık, kart sekmesinden girilen ölçüm
            //   skorsuz kalırdı.
            var id = await baglanti.TekDegerAsync<long>("""
                insert into public.yatis_izlem
                    (yatis_id, zaman, olcen_id, sistolik, diyastolik, nabiz, solunum,
                     ates, spo2, agri_vas, gks, kan_sekeri, not_metin, ekleyen)
                values (@p0, coalesce(@p1, now()), @p2, @p3, @p4, @p5, @p6,
                        @p7, @p8, @p9, @p10, @p11, coalesce(@p12, ''), @p2)
                returning id
                """, null,
                [istek.YatisId, istek.Zaman, baglam.KullaniciId,
                 istek.Sistolik, istek.Diyastolik, istek.Nabiz, istek.Solunum,
                 istek.Ates, istek.Spo2, istek.AgriVas, istek.Gks, istek.KanSekeri,
                 istek.Not?.Trim()], iptal);

            var skor = await baglanti.TekDegerAsync<int?>(
                "select erken_uyari from public.yatis_izlem where id = @p0",
                null, [id], iptal);

            // EŞİK AŞILDIYSA EKRAN SÖYLER: "acaba arasam mı" kararı kişiye
            //   bırakılmaz. Bildirimin kendisi hemşirenin işi - sistem onun
            //   yerine hekimi aramaz, ama sessiz de kalmaz.
            return Results.Ok(new
            {
                id,
                erkenUyari = skor,
                bildirimGerek = skor >= 5,
            });
        });

        // ------------------------------------------------- hekime bildirildi ----
        // Bildirim SATIRDA durur: "eşik aşıldı, hekime haber verildi mi"
        //   sorusunun cevabı ölçümün yanında olmalı.
        grup.MapPost("/izlem/{id:long}/bildirildi", async (
            long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.izlem", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.yatis_izlem
                   set bildirim_zamani = now(), degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and bildirim_zamani is null
                """, new object?[] { id, baglam.KullaniciId }, iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Kayıt bulunamadı ya da bildirim zaten yazılmış.");

            return Results.Ok(new { id, bildirildi = true });
        });

        // ------------------------------------------------------- sıvı kaydı ----
        grup.MapPost("/sivi", async (
            SiviIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.izlem", Islem.Ekle);

            if (istek.MiktarMl <= 0)
                throw GentegreHatasi.Dogrulama("Miktar sıfırdan büyük olmalı.",
                    new AlanHatasi("miktarMl", "Zorunlu."));
            if (istek.Yon is not (1 or 2))
                throw GentegreHatasi.Dogrulama("Yön seçilmeli (aldığı / çıkardığı).",
                    new AlanHatasi("yon", "Zorunlu."));

            var id = await veri.TekDegerAsync<long>("""
                insert into public.yatis_sivi
                    (yatis_id, zaman, yon, tur, miktar_ml, aciklama, ekleyen)
                values (@p0, coalesce(@p1, now()), @p2, @p3, @p4, coalesce(@p5, ''), @p6)
                returning id
                """, new object?[]
                {
                    istek.YatisId, istek.Zaman, istek.Yon, istek.Tur,
                    istek.MiktarMl, istek.Aciklama?.Trim(), baglam.KullaniciId,
                }, iptal);

            return Results.Ok(new { id });
        });

        // ------------------------------------------- risk değerlendirmesi ----
        grup.MapPost("/risk", async (
            RiskIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.izlem", Islem.Ekle);

            // ÖNLEMSİZ "YÜKSEK RİSK" BOŞ KAYITTIR: puan tek başına kayıt
            //   değildir, alınan önlem de satırda durmalı. Denetimde de
            //   klinikte de karşılığı olan şey önlemdir.
            if (istek.RiskDuzeyi >= 2 && string.IsNullOrWhiteSpace(istek.Onlem))
                throw GentegreHatasi.Dogrulama(
                    "Orta/yüksek riskte alınan önlem yazılmalı.",
                    new AlanHatasi("onlem", "Zorunlu."));

            var id = await veri.TekDegerAsync<long>("""
                insert into public.yatis_risk
                    (yatis_id, zaman, olcek, puan, risk_duzeyi, onlem,
                     degerlendiren_id, ekleyen)
                values (@p0, now(), @p1, @p2, @p3, coalesce(@p4, ''), @p5, @p5)
                returning id
                """, new object?[]
                {
                    istek.YatisId, istek.Olcek, istek.Puan, istek.RiskDuzeyi,
                    istek.Onlem?.Trim(), baglam.KullaniciId,
                }, iptal);

            return Results.Ok(new { id });
        });

        // ----------------------------------------------------- gözlem notu ----
        // NOT SİLİNMEZ, DÜZELTİLMEZ: yanlış yazılan not yeni bir satırla
        //   düzeltilir ve ikisi de durur. Bu yüzden güncelleme ucu YOK.
        grup.MapPost("/gozlem", async (
            GozlemIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.izlem", Islem.Ekle);

            if (string.IsNullOrWhiteSpace(istek.Not))
                throw GentegreHatasi.Dogrulama("Gözlem metni boş olamaz.",
                    new AlanHatasi("not", "Zorunlu."));

            var id = await veri.TekDegerAsync<long>("""
                insert into public.yatis_izlem (yatis_id, zaman, olcen_id, not_metin, ekleyen)
                values (@p0, now(), @p1, @p2, @p1)
                returning id
                """, new object?[] { istek.YatisId, baglam.KullaniciId, istek.Not.Trim() },
                iptal);

            return Results.Ok(new { id });
        });
    }
}
