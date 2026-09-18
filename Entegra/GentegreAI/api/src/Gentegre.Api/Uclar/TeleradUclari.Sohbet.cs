using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSTEK ÜZERİNDE YAZIŞMA (806) — gönderen kurum ↔ radyolog.
///
/// Tasarım notu (797) bunu baştan söylemişti: *"ayrı tablo yerine
/// `mesaj_sohbet.kaynak_tur/kaynak_id` de yeterli"*. Mesajlaşma modülü
/// (341/342) okunmamış sayacını, üyeliği, yanıtlamayı, ek dosyayı ve arşivi
/// zaten çözüyor; teleradyolojiye özel ikinci bir yazışma altyapısı bunların
/// ikincisini yazmak (ve birini unutmak) olurdu.
///
/// <b>Sohbeti SUNUCU açar, üyelerini de sunucu belirler:</b> gönderen kurumun
/// portal kullanıcısı ve isteğin atanan radyoloğu. Portal kullanıcısına
/// "istediğin kişiyle sohbet aç" demek, kurum içi personel listesini portala
/// açmak demekti (806 kuralı: portal rolü serbest sohbet açamaz).
///
/// <b>Aynı iş için tek sohbet</b> (`ux_mesaj_sohbet_kaynak`): ikincisi
/// açılsaydı yazışma iki listeye bölünür ve "yazdım ama görmedi" durumu
/// doğardı.
/// </summary>
public static partial class TeleradUclari
{
    private const string SohbetKaynagi = "telerad-istek";

    private static void SohbetUclariniEkle(RouteGroupBuilder grup)
    {
        // POST /api/telerad/istek/{id}/sohbet → sohbet id (yoksa açar)
        grup.MapPost("/istek/{id:int}/sohbet", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // MESAJ YETKİSİ ŞART: yazışma mesajlaşma modülünün işidir,
            //   teleradyoloji yalnız sohbeti doğru kayda bağlar.
            baglam.YetkiIste("mesaj", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);

            var istek = await baglanti.TekAsync("""
                select i.id, i.istek_no as "istekNo", i.kurum_id as "kurumId",
                       i.atanan_radyolog_id as "radyologId",
                       k.taraf_id as "kurumTarafId",
                       coalesce(t.unvan, '') as "kurumAdi"
                  from public.telerad_istek i
                  join public.telerad_kurum k on k.id = i.kurum_id
                  left join public.taraf t on t.id = k.taraf_id
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstek bulunamadı.");

            var kurumTaraf = Convert.ToInt32(istek["kurumTarafId"] ?? 0);
            var radyolog = istek["radyologId"] as int?;

            // KAPSAM BURADA DA GEÇERLİ (794/795): portal kullanıcısı yalnız
            //   KENDİ işinin yazışmasını açabilir - istek id'sini bilmek
            //   yetmez. İç kullanıcıda teleradyoloji görme yetkisi aranır.
            if (baglam.PortalTuru == PortalKapsamDisKurum)
            {
                if (kurumTaraf != baglam.KullaniciId)
                    throw GentegreHatasi.Bulunamadi("İstek bulunamadı.");
            }
            else if (baglam.PortalTuru == PortalKapsamDisDoktor)
            {
                if (radyolog != baglam.KullaniciId)
                    throw GentegreHatasi.Bulunamadi("İstek bulunamadı.");
            }
            else if (baglam.PortalTuru > 0)
            {
                throw GentegreHatasi.Yasak("Bu portal rolü teleradyoloji yazışması açamaz.");
            }
            else
            {
                baglam.YetkiIste("teleradyoloji", Islem.Gor);
            }

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var mevcut = await baglanti.TekDegerAsync<int?>("""
                select s.id from public.mesaj_sohbet s
                 where s.kaynak_tur = @p0 and s.kaynak_id = @p1 and s.durum = 1
                """, islem, [SohbetKaynagi, id], iptal);

            var sohbetId = mevcut ?? 0;
            if (sohbetId == 0)
            {
                // BAŞLIK İŞİN KENDİSİ: iki kişilik bir sohbette karşı tarafın
                //   adını başlık yapmak hangi işe ait olduğunu gizlerdi.
                var baslik = $"{istek["istekNo"]} · {istek["kurumAdi"]}";
                sohbetId = await baglanti.TekDegerAsync<int>("""
                    insert into public.mesaj_sohbet
                           (tip, ad, olusturan, son_mesaj_tarihi, kaynak_tur, kaynak_id)
                    values (3, @p0, @p1, (now())::timestamp, @p2, @p3)
                    returning id
                    """, islem, [baslik, baglam.KullaniciId, SohbetKaynagi, id], iptal);
            }

            // ÜYELER SUNUCUDAN: gönderen kurumun portal kullanıcısı, atanan
            //   radyolog ve sohbeti açan. Atama sonradan değişirse yeni
            //   radyolog bir sonraki açılışta eklenir - eski üye ÇIKARILMAZ,
            //   yazışma geçmişi sahipsiz kalmasın.
            var uyeler = new List<int> { baglam.KullaniciId };
            if (kurumTaraf > 0) uyeler.Add(kurumTaraf);
            if (radyolog is > 0) uyeler.Add(radyolog.Value);

            foreach (var u in uyeler.Distinct())
                await baglanti.CalistirAsync("""
                    insert into public.mesaj_uye (sohbet_id, kullanici_id, rol)
                    select @p0, @p1, 1
                     where exists (select 1 from public.taraf_kullanici tk
                                    where tk.id = @p1 and tk.aktif = 1)
                    on conflict (sohbet_id, kullanici_id) do nothing
                    """, islem, [sohbetId, u], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { sohbetId, istekNo = istek["istekNo"] });
        });
    }

    // PortalKapsam sabitleri Cekirdek'te; burada okunakli ad.
    private const short PortalKapsamDisDoktor = 1;
    private const short PortalKapsamDisKurum = 2;
}
