using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BİLDİRİM KANALI SINAMASI (820) — SMS / e-posta hesabına GERÇEK bir test
/// mesajı gönderir.
///
/// <para><b>Neden ayrı uç:</b> "Sına" (340) adresin ayakta olup olmadığına
/// bakıyor. SMS ve e-postada bu hiçbir şey söylemez - sunucu ayakta ama
/// kullanıcı adı yanlışsa, gönderen adresi reddediliyorsa ya da XML gövdesi
/// sağlayıcının beklediği biçimde değilse yine "başarılı" derdi. Kanalın
/// çalıştığının tek kanıtı, ulaşan bir mesajdır.</para>
///
/// <para><b>Kuyruğa girmez, doğrudan gönderir:</b> sınama sonucu HEMEN
/// görülmeli; kuyruğa bırakılsa hata dakikalar sonra günlükte kalırdı.</para>
///
/// <para><b>Dışarıya mesaj gider</b> - gerçek SMS ücretlidir, e-posta gerçek
/// bir kutuya düşer. Bu yüzden yetki `entegrasyon` + <b>Değiştir</b>: salt
/// okur yetkiyle sınama tetiklenemez.</para>
/// </summary>
public static class EntegrasyonBildirimUclari
{
    public sealed record SinaIstegi(
        /// <summary>SMS'te 905XXXXXXXXX, e-postada adres.</summary>
        string Alici,
        string? Mesaj = null);

    public static void BildirimSinamaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/entegrasyon").WithTags("Entegrasyon")
                      .RequireAuthorization();

        grup.MapPost("/{id:int}/test-bildirim", async (
            int id, SinaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BildirimGondericiFabrikasi fabrika, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var alici = (istek.Alici ?? "").Trim();
            if (alici.Length == 0)
                throw GentegreHatasi.Dogrulama("Alıcı gerekli (telefon ya da e-posta).");

            await using var b = await veri.AcAsync(iptal);
            var hesap = await b.TekAsync("""
                select e.id, e.kod, e.ad, coalesce(e.aktif, 0) as aktif,
                       coalesce(e.ayarlar->>'bildirim_kanal', '') as kanal,
                       coalesce(e.kullanici_adi, '') as "kullaniciAdi",
                       case when coalesce(e.sifre, '') = '' then 0 else 1 end as "sifreVar"
                  from public.entegrasyon_hesap e where e.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Entegrasyon hesabı bulunamadı.");

            if (Convert.ToInt32(hesap["aktif"] ?? 0) != 1)
                throw GentegreHatasi.IsKurali("Hesap pasif - önce aktifleştirin.");

            // KANAL ANAHTARI ŞART: kuyruk sağlayıcıyı yalnız bununla buluyor.
            //   Eksikse hesap tanımlı görünür ama kanal kayıt modunda kalır -
            //   sınama "başarılı" deyip mesaj hiç gitmezdi.
            var kanalKodu = (string)(hesap["kanal"] ?? "");
            if (kanalKodu is not ("1" or "2"))
                throw GentegreHatasi.IsKurali(
                    "Hesapta `ayarlar.bildirim_kanal` yok (1 SMS · 2 e-posta); "
                    + "kuyruk bu hesabı kanal sağlayıcısı olarak görmez.");

            if (((string)(hesap["kullaniciAdi"] ?? "")).Length == 0
                || Convert.ToInt32(hesap["sifreVar"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali(
                    "Hesapta kullanıcı adı / parola boş - kurulumda girilmeli.");

            var kanal = kanalKodu == "1" ? BildirimKanali.Sms : BildirimKanali.Eposta;
            var govde = string.IsNullOrWhiteSpace(istek.Mesaj)
                ? $"Gentegre AI sınama mesajı ({DateTime.Now:dd.MM.yyyy HH:mm})."
                : istek.Mesaj!.Trim();

            // KUYRUĞA GİRMEZ: Id = 0 olan geçici kayıt, doğrudan sağlayıcıya.
            var kayit = new BildirimKaydi(0, kanal, alici, "Gentegre AI sınama", govde,
                                          HesapId: id, Deneme: 0, EnFazlaDeneme: 1);
            var gonderici = await fabrika.KurAsync(kayit, iptal);
            var sonuc = await gonderici.GonderAsync(kayit, iptal);

            var ozet = sonuc.Basarili
                ? $"Sınama gönderildi ({alici})."
                : $"Gönderilemedi: {sonuc.Hata}";
            await b.CalistirAsync("""
                update public.entegrasyon_hesap
                   set son_kullanim = now(), son_sonuc = left(@p1, 300)
                 where id = @p0
                """, null, [id, ozet], iptal);

            return Results.Ok(new
            {
                basarili = sonuc.Basarili,
                mesaj = ozet,
                // HAM YANIT GÖSTERİLİR: sağlayıcı "0" ya da "ERR:12" gibi
                //   kısa kodlar dönüyor; kurulumda tek ipucu bu olabiliyor.
                saglayiciRef = sonuc.SaglayiciRef,
                hamYanit = sonuc.HamYanit,
                httpDurum = sonuc.HttpDurum,
            });
        });
    }
}
