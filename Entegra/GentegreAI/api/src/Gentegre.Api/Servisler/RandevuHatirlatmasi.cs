using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// RANDEVU HATIRLATMASI (Faz 0 · 399) — randevu kaydedilince hatırlatma
/// bildirimini kuyruğa koyar.
///
/// Neden kayıt anında kuyruğa konur (gece bir iş tarayıp göndermek yerine):
/// kuyruk zaten <c>planlanan</c> alanını biliyor ve işçi zamanı gelmeden
/// almıyor. Böylece "hangi randevuya hatırlatma gitti / gidecek" sorusu tek
/// tabloda cevaplanır, ayrı bir zamanlayıcıya gerek kalmaz.
///
/// HER KAYITTA TAZELENİR: randevu saati değişirse eski hatırlatma iptal edilip
/// yenisi konur — yoksa hasta eski saat için mesaj alır. Randevu iptal/gelmedi
/// durumuna geçerse yalnız iptal edilir.
///
/// SESSİZ KALMA KURALI: telefon yoksa, ayar kapalıysa ya da hatırlatma zamanı
/// GEÇMİŞSE kuyruğa satır konmaz. Bu bir hata değildir - randevu kaydı bu
/// yüzden başarısız olmamalı; bu yüzden çağıran tarafta try/catch ile sarılır.
/// </summary>
public sealed class RandevuHatirlatmasi
{
    private readonly VeriKaynagi _veri;
    private readonly BildirimDeposu _bildirim;
    private readonly ILogger<RandevuHatirlatmasi> _gunluk;

    public RandevuHatirlatmasi(VeriKaynagi veri, BildirimDeposu bildirim,
                               ILogger<RandevuHatirlatmasi> gunluk)
    {
        _veri = veri;
        _bildirim = bildirim;
        _gunluk = gunluk;
    }

    /// <summary>Bildirim kaynağı: 4 = randevu (kuyruk `kaynak_tur`).</summary>
    private const short KaynakRandevu = 4;

    /// <summary>Hatırlatma gönderilmeyecek randevu durumları: 3 iptal · 4 gelmedi.</summary>
    private static readonly short[] KapaliDurumlar = [3, 4];

    public async Task TazeleAsync(long randevuId, int kullaniciId, CancellationToken iptal)
    {
        // 1) Bu randevunun BEKLEYEN hatırlatması varsa iptal: saat değişmiş
        //    olabilir, eski satır yanlış zamanı söyler.
        await _veri.CalistirAsync("""
            update public.bildirim set durum = 5
             where kaynak_tur = @p0 and kaynak_id = @p1 and durum in (1, 4)
            """, new object?[] { KaynakRandevu, (int)randevuId }, iptal);

        var r = await _veri.TekAsync("""
            select r.baslangic, r.durum, coalesce(r.sube_id, 0) as sube_id,
                   coalesce(t.unvan, '')   as hasta,
                   coalesce(t.cep_tel, '') as telefon,
                   coalesce(d.ad, '')      as bolum,
                   -- Kurum adi SUBEDEN: cok subeli kurumda hasta hangi subeye
                   --   geliyorsa onun unvani yazilmali (unvan bossa kisa ad).
                   coalesce(nullif(s.unvan, ''), s.ad, '') as kurum
              from public.randevu r
              left join public.taraf t on t.id = r.hasta_id
              left join public.v_departman_lookup d on d.id = r.bolum
              left join public.sube s on s.id = r.sube_id
             where r.id = @p0
            """, new object?[] { (int)randevuId },
            o => new
            {
                Baslangic = o.GetDateTime(0),
                Durum = o.GetInt16(1),
                SubeId = o.GetInt32(2),
                Hasta = o.GetString(3),
                Telefon = o.GetString(4),
                Bolum = o.GetString(5),
                Kurum = o.GetString(6),
            }, iptal);

        if (r is null) return;
        if (KapaliDurumlar.Contains(r.Durum)) return;      // iptal/gelmedi: yalnız iptal

        var acik = await AyarAsync("randevu.hatirlatma_acik", "1", iptal);
        if (acik == "0") return;

        var saat = int.TryParse(await AyarAsync("randevu.hatirlatma_saat", "24", iptal), out var sa)
                   ? Math.Clamp(sa, 1, 168) : 24;

        var telefon = Rakamlar(r.Telefon);
        if (telefon.Length < 10)
        {
            // Telefon yoksa kuyruğa satır KONMAZ ama sebep günlüğe düşer:
            //   "hatırlatma neden gitmedi" sorusu cevapsız kalmasın.
            _gunluk.LogInformation(
                "Randevu {Id}: hatırlatma kuyruğa konmadı - hastanın cep telefonu yok.", randevuId);
            return;
        }

        var planlanan = r.Baslangic.AddHours(-saat);
        // GEÇMİŞ ZAMANA hatırlatma konmaz: aynı gün açılan randevuda mesaj
        //   "yarın" yerine anında giderdi. Randevuya 2 saatten az kaldıysa da
        //   hatırlatmanın anlamı yok.
        if (planlanan <= DateTime.Now || r.Baslangic <= DateTime.Now.AddHours(2)) return;

        await _bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                SablonKodu: "randevu.hatirlatma",
                Kanal: null,                       // şablon hangi kanalsa o
                Alici: telefon,
                Degiskenler: new Dictionary<string, string>
                {
                    ["hasta_ad"] = r.Hasta,
                    ["tarih"] = r.Baslangic.ToString("dd.MM.yyyy HH:mm"),
                    ["bolum"] = r.Bolum,
                    ["kurum"] = r.Kurum,
                },
                KaynakTur: KaynakRandevu,
                KaynakId: (int)randevuId,
                Oncelik: 7,                        // hatırlatma acele değil
                Planlanan: planlanan),
            kullaniciId, r.SubeId > 0 ? r.SubeId : null, iptal);
    }

    private async Task<string> AyarAsync(string anahtar, string varsayilan, CancellationToken iptal)
        => await _veri.TekDegerAsync<string>(
               "select deger from public.referans where anahtar = @p0",
               new object?[] { anahtar }, iptal) is { Length: > 0 } d ? d : varsayilan;

    /// <summary>Telefonu yalnız rakamlara indirger ("0 (555) 111 22 33" → "5551112233").</summary>
    private static string Rakamlar(string metin)
    {
        var s = new string(metin.Where(char.IsDigit).ToArray());
        if (s.StartsWith("90", StringComparison.Ordinal) && s.Length > 10) s = s[2..];
        return s.TrimStart('0');
    }
}
