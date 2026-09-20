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

    /// <summary>
    /// AŞI UYGULANDI: 207 Aşı Veri Seti paketi doğar (898, KTS H10).
    ///
    /// <para>Tetik uygulama KAYDEDİLDİĞİNDE; aşı geri alınamaz bir işlemdir,
    /// onay beklenmez. Başvuruya bağlı değilse (dış kayıt, saha uygulaması)
    /// paket üretilmez: hangi başvurunun aşısı olduğu bilinmeden USS'ye
    /// bağlanamaz.</para>
    ///
    /// <para><b>SYSTakipNo yoksa BEKLER</b> - 877'de öğrenilen ders: takip
    /// numarası içerik hash'ine girmediği için erken üretilen paket hiç
    /// tamamlanmıyordu.</para>
    /// </summary>
    public async Task AsiUygulandiAsync(int uygulamaId, int kullaniciId,
                                        CancellationToken iptal)
    {
        try
        {
            var belgeId = await _veri.TekDegerAsync<int>(
                "select coalesce(u.belge_id, 0) from public.asi_uygulama u "
                + " where u.id = @p0", [uygulamaId], iptal);
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("ASI", uygulamaId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz asi paketi uretilemedi (uygulama {Id})",
                             uygulamaId);
        }
    }

    /// <summary>
    /// GEBELİK SONUÇLANDI: 224 paketi doğar (902, KTS H10 - son paket).
    ///
    /// <para>Sonuç kaydı dosyayı kapatıyor; paket de aynı anda üretiliyor.
    /// İkisini ayırmak, kapanmış ama bildirilmemiş gebelikler üretirdi.</para>
    /// </summary>
    public async Task GebelikSonuclandiAsync(int sonucId, int kullaniciId,
                                             CancellationToken iptal)
    {
        try
        {
            var belgeId = await _veri.TekDegerAsync<int>("""
                select coalesce(s.belge_id,
                         (select max(i.belge_id) from public.gebe_izlem i
                           where i.gebelik_id = s.gebelik_id), 0)
                  from public.gebelik_sonuc s where s.id = @p0
                """, [sonucId], iptal);
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("GEBELIK_SONUCU", sonucId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz gebelik sonucu paketi uretilemedi (kayit {Id})",
                             sonucId);
        }
    }

    /// <summary>
    /// GEBELİK BİLDİRİMİ: 223 paketi doğar (901, KTS H10).
    ///
    /// <para><b>İzlemle birlikte çağrılır</b>, dosya açılışında değil:
    /// dosyanın kendi başvurusu yok, takip numarası izlemden geliyor. İlk
    /// izlem kaydedildiğinde bildirim de gider; sonraki izlemlerde "aynı
    /// içerik → aynı paket" kuralı yeni satır açmaz.</para>
    /// </summary>
    public async Task GebelikBildirimiAsync(int gebelikId, int kullaniciId,
                                            CancellationToken iptal)
    {
        try
        {
            // SAT ve ÖNCEKİ DOĞUM DURUMU olmadan paket eksik olur; üretip
            //   eksik göndermektense hiç üretmemek dürüst.
            var hazir = await _veri.TekDegerAsync<bool>("""
                select coalesce(bildirime_hazir, false) from public.v_gebelik
                 where id = @p0
                """, [gebelikId], iptal);
            if (!hazir) return;

            var belgeId = await _veri.TekDegerAsync<int>("""
                select coalesce(max(i.belge_id), 0) from public.gebe_izlem i
                 where i.gebelik_id = @p0
                """, [gebelikId], iptal);
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("GEBELIK_BILDIRIM", gebelikId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz gebelik bildirimi uretilemedi (dosya {Id})",
                             gebelikId);
        }
    }

    /// <summary>
    /// GEBE İZLEMİ KAYDEDİLDİ: 221 paketi doğar (900, KTS H10).
    ///
    /// <para>898/899'daki kuralın aynısı: başvuruya bağlı değilse üretilmez,
    /// SYSTakipNo yoksa bekler.</para>
    /// </summary>
    public async Task GebeIzlemiKaydedildiAsync(int izlemId, int kullaniciId,
                                                CancellationToken iptal)
    {
        try
        {
            var belgeId = await _veri.TekDegerAsync<int>(
                "select coalesce(i.belge_id, 0) from public.gebe_izlem i "
                + " where i.id = @p0", [izlemId], iptal);
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("GEBE_IZLEM", izlemId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz gebe izlem paketi uretilemedi (izlem {Id})",
                             izlemId);
        }
    }

    /// <summary>
    /// ÇOCUK İZLEMİ KAYDEDİLDİ: 209 paketi doğar (899, KTS H10).
    ///
    /// <para>Aşıdaki (898) kuralın aynısı: başvuruya bağlı değilse paket
    /// üretilmez, SYSTakipNo yoksa bekler.</para>
    /// </summary>
    public async Task CocukIzlemiKaydedildiAsync(int izlemId, int kullaniciId,
                                                 CancellationToken iptal)
    {
        try
        {
            var belgeId = await _veri.TekDegerAsync<int>(
                "select coalesce(i.belge_id, 0) from public.cocuk_izlem i "
                + " where i.id = @p0", [izlemId], iptal);
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("COCUK_IZLEM", izlemId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz cocuk izlem paketi uretilemedi (izlem {Id})",
                             izlemId);
        }
    }

    /// <summary>
    /// DİŞ SEANSI BİTTİ: ADSM Ağız ve Diş Sağlığı paketi doğar (876).
    ///
    /// <para>Tetik seansın BİTİŞİNDEdir: yarım seansın işlemleri henüz
    /// kesinleşmemiştir ve ücretlenmemiştir. Aynı başvuruda ikinci seans
    /// bitince paket yeniden üretilir - "aynı içerik → aynı paket" kuralı
    /// mükerrer satır açmaz, yeni işlem eklenince içerik değişip güncelleme
    /// paketi doğar (105'teki davranışın aynısı).</para>
    ///
    /// <para><b>Paket türü bugün KAPALI</b> (`aktif = 0`): USS paket numarası
    /// rehberden doğrulanmadan gönderim yapılmaz, <c>UretAsync</c> kapalı
    /// türde hiç satır açmaz. Tetik yine de bugünden yerinde durur - açılış
    /// günü kodun değil, kurulumun işi olsun.</para>
    /// </summary>
    public async Task DisSeansiBittiAsync(int seansId, int kullaniciId, CancellationToken iptal)
    {
        try
        {
            var belgeId = await _veri.TekDegerAsync<int>(
                "select coalesce(s.belge_id, 0) from public.dis_seans s where s.id = @p0",
                [seansId], iptal);
            // Başvurusuz seans USS'ye bağlanamaz: hangi kaydın işlemi olduğu
            //   bilinmiyor (muayenesiz diş seansı, 710).
            if (belgeId == 0) return;
            if (!await TakipNumarasiVarAsync(belgeId, iptal)) return;

            await _uretici.UretAsync("ADSM_AGIZ_DIS", belgeId, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz agiz-dis paketi uretilemedi (seans {Id})", seansId);
        }
    }

    private async Task<bool> TakipNumarasiVarAsync(int belgeId, CancellationToken iptal)
        => await _veri.TekDegerAsync<int>(
               "select count(*) from public.belge_basvuru bb " +
               " where bb.id = @p0 and coalesce(bb.sys_takip_no, '') <> ''",
               [belgeId], iptal) > 0;
}
