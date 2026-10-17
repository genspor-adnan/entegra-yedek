using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RANDEVU ERTELEME (1119; kullanıcı 17.10.2026: "randevu ertelemeyi nasıl yapacağız?" → "ilk yol").
///
/// Saat üstüne yazılmaz: eski randevu "Ertelendi" (durum 5) kalır, nedeni yazılır; aynı hasta /
/// hekim / cihaz / hizmet ile YENİ randevu açılır ve eskisine bağlanır (onceki_randevu_id). Raporda
/// ertelenen ayrı sayılır, kartta ve listede iz görünür.
///
/// Randevuya bağlı iş kayıtları yeni randevuya taşınır: radyoloji istemi (kabul randevudan açılır),
/// FTR seansı (tarih / saati de), diş laboratuvar aşaması. Hepsi tek işlemde - tetik (çakışma, mesai,
/// izin) reddederse hiçbir şey değişmez.
/// </summary>
public static partial class RandevuUclari
{
    private const int LogRandevu = 1259;            // KartKatalogu.Randevu ile aynı

    /// <summary>Baslangic: şubenin yerel saati "yyyy-MM-ddTHH:mm". Hekim / cihaz boşsa eskisi kalır.</summary>
    public sealed record ErteleIstegi(DateTime Baslangic, string? Neden, short? SureDk = null,
                                      int? HekimId = null, int? CihazId = null);

    private static void ErteleUcunuEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/{id:int}/ertele", async (
            int id, ErteleIstegi istek, VeriKaynagi veri, LogDeposu log, KayitErisimi erisim,
            Servisler.RandevuHatirlatmasi hatirlatma, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Degistir);
            var neden = (istek.Neden ?? "").Trim();
            if (neden.Length == 0)
                throw GentegreHatasi.Dogrulama("Erteleme nedeni yazılmalı.", new AlanHatasi("neden", "Zorunlu."));
            if (neden.Length > 200) neden = neden[..200];
            if (istek.SureDk is <= 0) throw GentegreHatasi.Dogrulama("Süre sıfırdan büyük olmalı.");
            if (!await erisim.GorunurAsync(baglam, "randevu", id, iptal)) throw GentegreHatasi.Bulunamadi("Randevu bulunamadı.");

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);

            var e = await b.TekAsync("""
                select r.durum, r.belge_id, r.hasta_id, r.hekim_id, r.cihaz_id, r.sure_dk,
                       to_char(r.baslangic at time zone coalesce((select nullif(sb.zaman_dilimi, '') from public.sube sb
                                                                  where sb.id = r.sube_id), 'Europe/Istanbul'), 'YYYY-MM-DD HH24:MI'),
                       (@p1::timestamp at time zone coalesce((select nullif(sb.zaman_dilimi, '') from public.sube sb
                                                              where sb.id = r.sube_id), 'Europe/Istanbul')) < now() - interval '5 minutes'
                  from public.randevu r where r.id = @p0
                   for update of r
                """, islem, [id, istek.Baslangic], o => new
            {
                durum = o.GetInt16(0), belgeli = !o.IsDBNull(1), hastaId = o.GetInt32(2),
                hekimId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                cihazId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                sureDk = o.GetInt16(5), eskiSaat = o.GetString(6), gecmis = o.GetBoolean(7),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Randevu bulunamadı.");

            if (e.durum != 1) throw GentegreHatasi.IsKurali("Yalnız planlanmış randevu ertelenir.");
            if (e.belgeli) throw GentegreHatasi.IsKurali("Başvuruya dönüşmüş randevu ertelenmez.");
            if (e.gecmis) throw GentegreHatasi.Dogrulama("Yeni randevu geçmişe verilemez.");

            // Önce eski kayıt slotu boşaltır (tekil hekim / saat indeksi ve çakışma tetiği 5'i saymaz).
            await b.CalistirAsync("""
                update public.randevu set durum = 5, erteleme_nedeni = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, neden, baglam.KullaniciId], iptal);

            var hekimId = istek.HekimId ?? e.hekimId;
            var cihazId = istek.CihazId ?? e.cihazId;
            var sureDk = istek.SureDk ?? e.sureDk;
            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.randevu
                       (sube_id, bolum, hekim_id, hasta_id, baslangic, sure_dk, durum, aciklama, hizmet_id, tip, kaynak,
                        cihaz_id, unit_id, plan_satir_id, lab_isemri_id, onceki_randevu_id, ekleyen)
                select r.sube_id, r.bolum, @p1, r.hasta_id,
                       @p3::timestamp at time zone coalesce((select nullif(sb.zaman_dilimi, '') from public.sube sb
                                                              where sb.id = r.sube_id), 'Europe/Istanbul'),
                       @p4, 1, r.aciklama, r.hizmet_id, r.tip, r.kaynak, @p2, r.unit_id, r.plan_satir_id, r.lab_isemri_id,
                       r.id, @p5
                  from public.randevu r where r.id = @p0
                returning id
                """, islem, [id, hekimId, cihazId, istek.Baslangic, sureDk, baglam.KullaniciId], iptal);

            // Bağlı iş kayıtları yeni randevuya.
            await b.CalistirAsync("update public.radyoloji_istem set randevu_id = @p1 where randevu_id = @p0",
                islem, [id, yeniId], iptal);
            await b.CalistirAsync("update public.dis_lab_isemri_asama set randevu_id = @p1 where randevu_id = @p0",
                islem, [id, yeniId], iptal);
            await b.CalistirAsync("""
                update public.ftr_seans
                   set randevu_id = @p1, tarih = @p2::timestamp::date, saat = to_char(@p2::timestamp, 'HH24:MI'),
                       degistiren = @p3, degistirme_tarihi = now()
                 where randevu_id = @p0 and durum = 1
                """, islem, [id, yeniId, istek.Baslangic, baglam.KullaniciId], iptal);

            // Alan bazlı log (ULog kuralı): eskide durum değişikliği, yenide ekleme.
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogRandevu, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["durum"] = "1 -> 5", ["erteleme_nedeni"] = neden, ["yeni_randevu"] = yeniId.ToString() },
                tarafId: e.hastaId, iptal: iptal);
            await log.YazAsync(b, islem, LogIslemi.Ekle, LogRandevu, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { ertelenen = id, eskiSaat = e.eskiSaat, baslangic = istek.Baslangic.ToString("yyyy-MM-dd HH:mm"), neden },
                tarafId: e.hastaId, iptal: iptal);

            await islem.CommitAsync(iptal);
            // Eski randevunun bekleyen hatırlatması düşer, yenisi kurulur.
            await hatirlatma.TazeleAsync(id, baglam.KullaniciId, iptal);
            await hatirlatma.TazeleAsync(yeniId, baglam.KullaniciId, iptal);
            return Results.Ok(new { id = yeniId, ertelenen = id });
        });
    }
}
