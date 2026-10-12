using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

public sealed class KysEgitimIstegi
{
    public string Ad { get; set; } = "";
    /// <summary>personel_egitim.tur - 2 sertifika · 3 eğitim (1 diploma yetkinlik eğitimi değil).</summary>
    public short Tur { get; set; } = 3;
    /// <summary>Eğitmen / kurum (personel_egitim.kurum).</summary>
    public string Egitmen { get; set; } = "";
    /// <summary>Metin: '2026' · '2026-09-25' · '25.09.2026' (056).</summary>
    public string Tarih { get; set; } = "";
    public string Gecerlilik { get; set; } = "";
    public List<int> Katilimcilar { get; set; } = [];
}

/// <summary>
/// KURUMSAL KALİTE — EĞİTİM KAYDI (1056, mockup Ekranlar/Kalite2/egitim.html).
///
/// EĞİTİM = personel_egitim SATIRLARININ GRUBU (ad + tür + eğitmen + tarih +
/// şube); kimliği grubun en küçük satır id'si (v_kalite_egitim ile aynı).
/// Ayrı tablo yok: satırlar personel kartının "Eğitim / Sertifika" sekmesinde
/// de görünür. Kaydet grubu bütün olarak yazar - alanlar her satırda
/// güncellenir, listeden çıkan katılımcının satırı silinir, eklenen için
/// satır açılır. Loglar personel kartı detayının koduyla (905, üst 73 =
/// personel kartı): kişinin kartındaki geçmişte de görünür. Silme logu
/// DELETE'ten ÖNCE, tam satırla.
/// </summary>
public static class KysEgitimUclari
{
    private const int LogPersonelEgitim = 905;   // KartKatalogu.Cari "egitimler" detayı
    private const int LogPersonelKarti = 73;     // personel kartı (GENINI IK = 73)

    private sealed record Satir(int Id, int TarafId, string Ad, short Tur, string Kurum,
                                string Tarih, string Gecerlilik, int SubeId);

    public static void KysEgitimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kys-egitim").WithTags("Kurumsal Kalite").RequireAuthorization();

        grup.MapGet("/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.egitim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await GrupAsync(b, null, id, baglam, iptal);
            var ilk = satirlar[0];
            var katilimcilar = await b.ListeAsync("""
                select e.id, e.taraf_id as "tarafId",
                       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad,
                       coalesce(d.ad, '') as birim
                  from public.personel_egitim e
                  join public.taraf t on t.id = e.taraf_id
                  left join public.departman d on d.id = t.departman
                 where e.id = any(@p0)
                 order by t.ad, t.soyad
                """, null, [satirlar.Select(s => s.Id).ToArray()], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new
            {
                id = satirlar.Min(s => s.Id), ad = ilk.Ad, tur = ilk.Tur, egitmen = ilk.Kurum,
                tarih = ilk.Tarih, gecerlilik = ilk.Gecerlilik, katilimcilar, izlemeNo = baglam.IzlemeNo
            });
        });

        // Kaydet: id 0 = yeni eğitim. Dönen id grubun yeni kimliği (en küçük satır).
        grup.MapPut("/{id:int}", async (int id, KysEgitimIstegi istek, BaglamCozucu cozucu,
            VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.egitim", id == 0 ? Islem.Ekle : Islem.Degistir);
            Dogrula(istek);
            var subeId = baglam.SubeId ?? throw GentegreHatasi.IsKurali("Önce aktif şubeyi seçin.");

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);

            var mevcut = id == 0 ? [] : await GrupAsync(b, tx, id, baglam, iptal);
            var istenen = istek.Katilimcilar.Distinct().ToHashSet();

            // Seçilenler gerçekten personel mi (başka taraf id'si yazılmasın).
            var personel = (await b.ListeAsync("""
                select id from public.taraf where personel = 1 and id = any(@p0)
                """, tx, [istenen.ToArray()], r => r.GetInt32(0), iptal)).ToHashSet();
            if (personel.Count != istenen.Count)
                throw GentegreHatasi.Dogrulama("Katılımcılardan biri personel değil.");

            // Çıkanlar: log önce, sonra sil.
            foreach (var s in mevcut.Where(s => !istenen.Contains(s.TarafId)))
            {
                await log.YazAsync(b, tx, LogIslemi.Sil, LogPersonelEgitim, s.Id, baglam.KullaniciId,
                    baglam.SubeId, baglam.Ip, s, LogPersonelKarti, s.TarafId, s.TarafId, iptal: iptal);
                await b.CalistirAsync("delete from public.personel_egitim where id = @p0", tx, [s.Id], iptal);
            }

            // Kalanlar: alan farkı varsa güncelle, değişen alanlar loglanır.
            foreach (var s in mevcut.Where(s => istenen.Contains(s.TarafId)))
            {
                var fark = new Dictionary<string, object?>();
                if (s.Ad != istek.Ad) fark["ad"] = new { eski = s.Ad, yeni = istek.Ad };
                if (s.Tur != istek.Tur) fark["tur"] = new { eski = s.Tur, yeni = istek.Tur };
                if (s.Kurum != istek.Egitmen) fark["kurum"] = new { eski = s.Kurum, yeni = istek.Egitmen };
                if (s.Tarih != istek.Tarih) fark["tarih"] = new { eski = s.Tarih, yeni = istek.Tarih };
                if (s.Gecerlilik != istek.Gecerlilik) fark["gecerlilik"] = new { eski = s.Gecerlilik, yeni = istek.Gecerlilik };
                if (fark.Count == 0) continue;
                await b.CalistirAsync("""
                    update public.personel_egitim
                       set ad = @p1, tur = @p2, kurum = @p3, tarih = @p4, gecerlilik = @p5, degistiren = @p6
                     where id = @p0
                    """, tx, [s.Id, istek.Ad, istek.Tur, istek.Egitmen, istek.Tarih, istek.Gecerlilik,
                              baglam.KullaniciId], iptal);
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogPersonelEgitim, s.Id, baglam.KullaniciId,
                    baglam.SubeId, baglam.Ip, fark, LogPersonelKarti, s.TarafId, s.TarafId, iptal: iptal);
            }

            // Yeniler. Grup şubesi: mevcut grubunki, yeni eğitimde aktif şube.
            var grupSube = mevcut.Count > 0 ? mevcut[0].SubeId : subeId;
            var varolan = mevcut.Select(s => s.TarafId).ToHashSet();
            foreach (var tarafId in istenen.Where(t => !varolan.Contains(t)))
            {
                var yeniId = await b.TekDegerAsync<int>("""
                    insert into public.personel_egitim (taraf_id, tur, ad, kurum, tarih, gecerlilik, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7) returning id
                    """, tx, [tarafId, istek.Tur, istek.Ad, istek.Egitmen, istek.Tarih, istek.Gecerlilik,
                              grupSube, baglam.KullaniciId], iptal);
                await log.YazAsync(b, tx, LogIslemi.Ekle, LogPersonelEgitim, yeniId, baglam.KullaniciId,
                    baglam.SubeId, baglam.Ip,
                    new { taraf_id = tarafId, tur = istek.Tur, ad = istek.Ad, kurum = istek.Egitmen,
                          tarih = istek.Tarih, gecerlilik = istek.Gecerlilik, kaynak = "kys-egitim" },
                    LogPersonelKarti, tarafId, tarafId, iptal: iptal);
            }

            // Yeni kimlik: grubun en küçük satırı (ilk satır silinmiş olabilir).
            var yeniKimlik = await b.TekDegerAsync<int>("""
                select min(id) from public.personel_egitim
                 where ad = @p0 and tur = @p1 and kurum = @p2 and tarih = @p3 and sube_id = @p4
                """, tx, [istek.Ad, istek.Tur, istek.Egitmen, istek.Tarih, grupSube], iptal);
            // BELGELER GRUPLA GİDER (1065): katılım listesi / sertifika grup
            //   kimliğine bağlı; o satır çıkarıldıysa kimlik değişti, ekler taşınır.
            if (id != 0 && yeniKimlik != id)
                await b.CalistirAsync("""
                    update public.dokuman set kaynak_id = @p1 where kaynak = 'kys-egitim' and kaynak_id = @p0
                    """, tx, [id, yeniKimlik], iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id = yeniKimlik, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapDelete("/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.egitim", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var satirlar = await GrupAsync(b, tx, id, baglam, iptal);
            // Belgesi olan eğitim silinmez (1065): ek sahipsiz kalırdı.
            if (await b.TekDegerAsync<bool>("""
                    select exists (select 1 from public.dokuman where kaynak = 'kys-egitim' and kaynak_id = @p0)
                    """, tx, [id], iptal))
                throw GentegreHatasi.IsKurali("Eğitimin belgeleri var; önce Belgeler bölümünden silin.");
            foreach (var s in satirlar)
            {
                await log.YazAsync(b, tx, LogIslemi.Sil, LogPersonelEgitim, s.Id, baglam.KullaniciId,
                    baglam.SubeId, baglam.Ip, s, LogPersonelKarti, s.TarafId, s.TarafId, iptal: iptal);
                await b.CalistirAsync("delete from public.personel_egitim where id = @p0", tx, [s.Id], iptal);
            }
            await tx.CommitAsync(iptal);
            return Results.Ok(new { silinen = satirlar.Count, izlemeNo = baglam.IzlemeNo });
        });

        // Katılımcı arama: İK'nın personel listesi 'personel' yetkisi ister,
        //   kalite sorumlusunda olmayabilir - yalnız ad + birim döner.
        grup.MapGet("/personel", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.egitim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad,
                       coalesce(d.ad, '') as birim
                  from public.taraf t
                  left join public.departman d on d.id = t.departman
                 where t.personel = 1 and t.durum = 1
                   and (@p0 = '' or (coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '') || ' ' || coalesce(d.ad, '')) ilike '%' || @p0 || '%')
                 order by t.ad, t.soyad
                 limit 30
                """, null, [(q ?? "").Trim()], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });
    }

    private static void Dogrula(KysEgitimIstegi istek)
    {
        istek.Ad = (istek.Ad ?? "").Trim();
        istek.Egitmen = (istek.Egitmen ?? "").Trim();
        istek.Tarih = (istek.Tarih ?? "").Trim();
        istek.Gecerlilik = (istek.Gecerlilik ?? "").Trim();
        var hatalar = new List<AlanHatasi>();
        if (istek.Ad.Length == 0) hatalar.Add(new AlanHatasi("ad", "Eğitim adı zorunlu."));
        if (istek.Ad.Length > 200) hatalar.Add(new AlanHatasi("ad", "Eğitim adı en çok 200 karakter."));
        if (istek.Egitmen.Length > 150) hatalar.Add(new AlanHatasi("egitmen", "Eğitmen en çok 150 karakter."));
        if (istek.Tarih.Length == 0) hatalar.Add(new AlanHatasi("tarih", "Tarih zorunlu."));
        if (istek.Tarih.Length > 10) hatalar.Add(new AlanHatasi("tarih", "Tarih: 2026, 2026-09-25 ya da 25.09.2026."));
        if (istek.Gecerlilik.Length > 60) hatalar.Add(new AlanHatasi("gecerlilik", "Geçerlilik en çok 60 karakter."));
        if (istek.Tur is not (2 or 3)) hatalar.Add(new AlanHatasi("tur", "Tür: 2 sertifika, 3 eğitim."));
        if (istek.Katilimcilar is not { Count: > 0 }) hatalar.Add(new AlanHatasi("katilimcilar", "En az bir katılımcı seçin."));
        if (hatalar.Count > 0) throw GentegreHatasi.Dogrulama("Eğitim kaydı eksik.", [.. hatalar]);
    }

    /// <summary>
    /// id'nin ait olduğu eğitim grubu (aynı ad / tür / eğitmen / tarih / şube).
    /// Başka şubenin kaydı açılmaz - liste de aktif şubeye süzülür.
    /// </summary>
    private static async Task<List<Satir>> GrupAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int id,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var satirlar = await b.ListeAsync("""
            select g.id, g.taraf_id, g.ad, g.tur, g.kurum, g.tarih, g.gecerlilik, g.sube_id
              from public.personel_egitim e
              join public.personel_egitim g
                on g.ad = e.ad and g.tur = e.tur and g.kurum = e.kurum and g.tarih = e.tarih and g.sube_id = e.sube_id
             where e.id = @p0 and e.tur in (2, 3) and (@p1::integer is null or e.sube_id = @p1)
             order by g.id
            """, tx, [id, baglam.SubeId],
            r => new Satir(r.GetInt32(0), r.GetInt32(1), r.GetString(2), r.GetInt16(3), r.GetString(4),
                           r.GetString(5), r.GetString(6), r.GetInt32(7)), iptal);
        return satirlar.Count > 0 ? satirlar : throw GentegreHatasi.Bulunamadi("Eğitim kaydı bulunamadı.");
    }
}
