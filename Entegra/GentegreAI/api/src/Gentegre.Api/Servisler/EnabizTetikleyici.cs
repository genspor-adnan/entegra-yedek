using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// HANGİ PAKET NE ZAMAN DOĞAR — tek yer.
///
/// Kural iki ayrı dosyaya dağılmıştı: başvuru kaydedilince 101 (ve koşullu
/// 102) `BelgeUclari` içinde, 101 gönderilince 102 `EnabizGonderimi` içinde
/// üretiliyordu. İkisi de aynı soruyu cevaplıyor - "şimdi hangi paket
/// doğmalı" - ve cevabın yarısını görüp öbür yarısını kaçırmak kolaydı:
/// 102'nin kaydetme anında üretilmesi tam bu yüzden aylarca fark edilmedi
/// (o an takip numarası henüz yoktur, paket hiç doğmazdı).
///
/// Üretim SESSİZDİR: e-Nabız ikincil iştir, hasta kaydı birincil. Paket
/// üretilemezse belge kaydı da gönderim de düşmez, hata yalnız günlüğe
/// yazılır.
/// </summary>
public sealed class EnabizTetikleyici
{
    private readonly VeriKaynagi _veri;
    private readonly EnabizPaketUretici _uretici;
    private readonly ILogger<EnabizTetikleyici> _gunluk;

    public EnabizTetikleyici(VeriKaynagi veri, EnabizPaketUretici uretici,
                             ILogger<EnabizTetikleyici> gunluk)
    {
        _veri = veri;
        _uretici = uretici;
        _gunluk = gunluk;
    }

    /// <summary>
    /// BAŞVURU KAYDEDİLDİ: 101 üretilir, takip numarası varsa 102 de.
    ///
    /// Kılavuz açık: "Bu paket, hasta KAYDI YAPILDIĞINDA ... gönderilecektir."
    /// Paket bir süre yalnız muayeneye alınırken üretiliyordu ve muayeneye
    /// alınmayan başvuru (kayıt yaptırıp giden hasta) USS'ye hiç
    /// bildirilmiyordu. Muayeneye alma tetiği yerinde kalır: orada paket
    /// yeniden üretilir, "aynı içerik → aynı paket" kuralı mükerrer satır
    /// açmaz ve kayıtta eksik kalan alan o an tamamlanır.
    /// </summary>
    public async Task BasvuruKaydedildiAsync(int belgeId, int kullaniciId,
                                             CancellationToken iptal)
    {
        try
        {
            // YALNIZ BAŞVURU (tur 19): öteki belge türlerinin USS karşılığı yok.
            var basvuruMu = await _veri.TekDegerAsync<int>(
                "select count(*) from public.belge b " +
                " join public.belge_basvuru bb on bb.id = b.id " +
                " where b.id = @p0 and b.tur = 19", [belgeId], iptal);
            if (basvuruMu == 0) return;

            await _uretici.UretAsync("HASTA_KABUL", belgeId, kullaniciId, iptal);

            // 102 işlem paketi 101 GİTTİKTEN SONRA anlamlıdır: ilk zorunlu
            //   alanı SYSTakipNo'dur. Numara yokken üretmek, kuyruğa doğuştan
            //   ölü bir satır bırakmak olurdu - gönderilse "E1004 SYSTakipNo
            //   bos olamaz" ile dönerdi.
            if (await TakipNumarasiVarAsync(belgeId, iptal))
                await _uretici.UretAsync("HASTA_ISLEM", belgeId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz paketi uretilemedi (basvuru {Id})", belgeId);
        }
    }

    /// <summary>
    /// 101 GÖNDERİLDİ: işlem paketi (102) hemen doğar.
    ///
    /// Takip numarası tam burada, 101'in yanıtında gelir. Üretim belgenin bir
    /// sonraki kaydedilmesine bırakılmıştı ve pratikte hiç olmuyordu:
    /// kullanıcı kalemi girip kaydediyor (numara henüz yok), 101'i gönderiyor
    /// (numara geliyor) ve bir daha kaydetmek için sebebi kalmıyor.
    /// </summary>
    public async Task PaketGonderildiAsync(long paketId, int kullaniciId,
                                           CancellationToken iptal)
    {
        try
        {
            var kaynak = await _veri.TekDegerAsync<int>("""
                select coalesce(p.kaynak_id, 0)
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where p.id = @p0 and t.uss_paket_kodu = '101' and p.kaynak_tur = 1
                """, [paketId], iptal);
            if (kaynak == 0) return;

            await _uretici.UretAsync("HASTA_ISLEM", kaynak, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz islem paketi uretilemedi (101 paket {Id})",
                             paketId);
        }
    }

    /// <summary>
    /// LABORATUVAR SONUCU ONAYLANDI: 105 doğar (632).
    ///
    /// Tetik SONUÇ onayındadır, istem açılışında değil: e-Nabız'a giden şey
    /// sonucun kendisidir ve onaylanmamış sonuç hastanın dosyasına da
    /// yazılmaz. Bir istemde birden çok tetkik olur - her onayda paket
    /// yeniden üretilir, "aynı içerik → aynı paket" mükerrer satır açmaz;
    /// yeni sonuç eklenince içerik değişip güncelleme paketi doğar.
    ///
    /// TAKİP NUMARASI YOKSA ÜRETİLMEZ: 102'deki ile aynı kural - ilk zorunlu
    /// alan SYSTakipNo'dur, numara gelmeden üretilen paket kuyruğa doğuştan
    /// ölü düşer.
    /// </summary>
    public async Task LabSonucOnaylandiAsync(int istemId, int kullaniciId,
                                             CancellationToken iptal)
    {
        try
        {
            var belgeId = await _veri.TekDegerAsync<int>(
                "select coalesce(i.belge_id, 0) from public.lab_istem i "
                + " where i.id = @p0", [istemId], iptal);
            // Belgesiz istem (dış kurum numunesi) USS'ye bağlanamaz: hangi
            //   başvurunun sonucu olduğu bilinmiyor.
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("LAB_SONUC", istemId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz lab sonuc paketi uretilemedi (istem {Id})",
                             istemId);
        }
    }

    private async Task<bool> TakipNumarasiVarAsync(int belgeId, CancellationToken iptal)
        => await _veri.TekDegerAsync<int>(
               "select count(*) from public.belge_basvuru bb " +
               " where bb.id = @p0 and coalesce(bb.sys_takip_no, '') <> ''",
               [belgeId], iptal) > 0;
}
