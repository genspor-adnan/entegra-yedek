using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BİLDİRİM ŞABLONU KARTI (1354, mockup Ekranlar/Ayarlar/bildirim_sablonu_karti.html, 17.11.2026):
///  * GET  /api/bildirim-sablon/{id}/ozet   - değişkenler, kanalın gönderen başlığı, bu ayki gönderim sayısı
///  * POST /api/bildirim-sablon/{id}/deneme - kendi numarana / adresine örnek değerlerle gerçek gönderim
/// Metin önizlemesi ve SMS sayacı istemcide (kartın o anki, kaydedilmemiş metni üzerinden).
/// </summary>
public static class BildirimSablonKartUclari
{
    public sealed record DenemeIstegi(string? Alici, Dictionary<string, string>? Degerler);

    public static void BildirimSablonKartUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/bildirim-sablon").WithTags("Bildirim Şablonu").RequireAuthorization();

        grup.MapGet("/{id:int}/ozet", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bildirim_sablon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ozet = await b.TekAsync("""
                select s.kod, s.kanal::int, coalesce(s.degiskenler, '{}'::jsonb)::text, s.sistem::int,
                       coalesce((select h.ayarlar ->> 'baslik' from public.entegrasyon_hesap h
                                  where h.aktif = 1 and coalesce(h.ayarlar ->> 'bildirim_kanal', '') = s.kanal::text
                                  order by h.test_mi, h.id limit 1), '') as gonderen,
                       coalesce((select h.ad from public.entegrasyon_hesap h
                                  where h.aktif = 1 and coalesce(h.ayarlar ->> 'bildirim_kanal', '') = s.kanal::text
                                  order by h.test_mi, h.id limit 1), '') as hesap,
                       (select count(*) from public.bildirim x
                         where x.sablon_id = s.id and x.ekleme_tarihi >= date_trunc('month', now()))::int as bu_ay,
                       (select count(*) from public.bildirim x where x.sablon_id = s.id and x.durum = 4)::int as hatali
                  from public.bildirim_sablon s where s.id = @p0
                """, null, [id], o => new
                {
                    kod = o.GetString(0), kanal = o.GetInt32(1),
                    degiskenler = JsonSerializer.Deserialize<Dictionary<string, string>>(o.GetString(2)) ?? new(),
                    sistem = o.GetInt32(3) == 1, gonderen = o.GetString(4), hesap = o.GetString(5),
                    buAy = o.GetInt32(6), hatali = o.GetInt32(7),
                }, iptal);
            return ozet is null ? HataSonucu.Bulunamadi() : Results.Ok(ozet);
        });

        grup.MapPost("/{id:int}/deneme", async (int id, DenemeIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            BildirimDeposu bildirim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bildirim_sablon", Islem.Degistir);
            // Kuyruğa yazar (deneme mesajı ve günlüğü): salt okunur oturum / şube göndermez (kod inceleme 17.11.2026).
            baglam.YazmaIste();
            var alici = (istek.Alici ?? "").Trim();
            if (alici.Length == 0) throw GentegreHatasi.IsKurali("Alıcıyı girin (cep telefonu ya da e-posta).");
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync("select kod, kanal, konu, govde from public.bildirim_sablon where id = @p0", null, [id],
                o => new { Kod = o.GetString(0), Kanal = (BildirimKanali)o.GetInt16(1), Konu = o.GetString(2), Govde = o.GetString(3) }, iptal)
                ?? throw GentegreHatasi.IsKurali("Şablon bulunamadı.");
            if (s.Kanal == BildirimKanali.Sms && alici.Count(char.IsDigit) < 10)
                throw GentegreHatasi.IsKurali("SMS için geçerli bir cep telefonu girin.");
            if (s.Kanal == BildirimKanali.Eposta && !alici.Contains('@'))
                throw GentegreHatasi.IsKurali("E-posta için geçerli bir adres girin.");

            // Değişkenler: {{ad}} ve @AD (büyük harf) yazımlarının ikisi de doldurulur (basvuru.kvkk_sms @ONAYKODU kullanır).
            var degerler = istek.Degerler ?? new();
            string Doldur(string metin)
            {
                var m = BildirimSablonu.Doldur(metin, degerler);
                foreach (var (ad, deger) in degerler) m = m.Replace("@" + ad.ToUpperInvariant(), deger, StringComparison.OrdinalIgnoreCase);
                return m;
            }
            try
            {
                var bid = await bildirim.KuyrugaEkleAsync(b, null, new BildirimIstegi(s.Kod, s.Kanal, alici,
                    Konu: s.Konu.Length > 0 ? "[DENEME] " + Doldur(s.Konu) : null, Govde: Doldur(s.Govde),
                    KullaniciId: baglam.KullaniciId, KaynakTur: 1287, KaynakId: id, Oncelik: 1), baglam.KullaniciId, baglam.SubeId, iptal);
                // PASİF ŞABLON (kod inceleme 17.11.2026): kuyruk pasif şablonu sessizce atlar (null) - ekran "gönderildi"
                //   deyip SMS hiç gelmiyordu.
                if (bid is null)
                    throw GentegreHatasi.IsKurali("Şablon pasif - deneme gönderilmedi. Durum'u Aktif yapıp kaydedin, sonra deneyin.");
                return Results.Ok(new { bildirimId = bid });
            }
            catch (InvalidOperationException h)
            {
                throw GentegreHatasi.IsKurali("Gönderilemedi: " + h.Message);
            }
        });
    }
}
