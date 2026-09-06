using System.Diagnostics;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// ZAMANLI İŞ KAYIT DEFTERİ (405) — kod → yapılacak iş.
///
/// İşin ZAMANI veritabanında (`zamanli_is`), KENDİSİ burada. Böylece kimse
/// tabloya kod bilmeyen bir satır ekleyip "çalışmıyor" diye aramaz: bilinmeyen
/// kod çalıştırılmaz, sebebi son sonuç alanına yazılır.
/// </summary>
public static class ZamanliIsler
{
    /// <summary>İş: kapsamdan servisini alır, çalışır ve KISA bir sonuç metni döner.</summary>
    public delegate Task<string> Is(IServiceProvider servisler, CancellationToken iptal);

    public static readonly IReadOnlyDictionary<string, Is> Kayitli = new Dictionary<string, Is>
    {
        // TİTCK ilaç listesi: haftalık yayın, gece indirilir.
        ["titck.ilac"] = async (servisler, iptal) =>
        {
            var titck = servisler.GetRequiredService<TitckIlacGuncelleme>();
            var s = await titck.GuncelleAsync(iptal);
            return $"TİTCK {s.Tarih}: {s.Yazilan} ürün ({s.Askida} askıda), {s.Atlanan} atlandı.";
        },

        // SKRS e-Reçete listesi: REÇETE TÜRÜNÜN kaynağı (ruhsat listesinde yok).
        //   Haftalık yayın; ilaç listesinden BIR GUN SONRA çalışır ki yeni
        //   barkodlar önce katalogda olsun, sonra türü yazılsın.
        ["titck.recete"] = async (servisler, iptal) =>
        {
            var titck = servisler.GetRequiredService<TitckIlacGuncelleme>();
            var s = await titck.ReceteTuruGuncelleAsync(iptal);
            return $"SKRS e-Reçete {s.Tarih}: {s.Yazilan} ilacın reçete türü güncellendi.";
        },

        // e-NABIZ KUYRUĞU: sık çalışır (USS olaydan sonra saatlerle ölçülen bir
        //   süre sınırı koyuyor). Hesap tanımlı değilse iş SESSİZCE BAŞARILI
        //   sayılmaz - sonuç metni durumu söyler, yoksa kurum gönderim
        //   yapıldığını sanırdı.
        ["enabiz.gonder"] = async (servisler, iptal) =>
        {
            var gonderim = servisler.GetRequiredService<EnabizGonderimi>();
            var s = await gonderim.CalistirAsync(50, null, null, iptal);
            return s.Aciklama;
        },
    };
}

/// <summary>
/// ZAMANLI İŞ İŞÇİSİ (405) — dakikada bir bakar, zamanı gelen işi çalıştırır.
///
/// Bildirim işçisiyle aynı disiplin:
///   * Satır KİLİTLENEREK alınır (`calisiyor = 1` atomik update) — iki sunucu
///     aynı işi aynı anda çalıştırmaz.
///   * Tek işin hatası işçiyi DÜŞÜRMEZ; hata satıra yazılır ve iş bir sonraki
///     periyoda ertelenir.
///   * Yarıda kalan (servis çöktü) satır 6 saat sonra serbest bırakılır —
///     aksi hâlde iş bir daha hiç çalışmaz ve kimse fark etmez.
///
/// Cron yazmadım: bu ürünün ihtiyacı "haftada bir, gece" ölçüsünde. Cron
/// ifadesi ekranda da kullanıcıya anlatılması gereken ikinci bir dil olurdu.
/// </summary>
public sealed class ZamanliIsIscisi : BackgroundService
{
    private readonly IServiceProvider _servisler;
    private readonly ILogger<ZamanliIsIscisi> _gunluk;
    private readonly bool _aktif;

    public ZamanliIsIscisi(IServiceProvider servisler, ILogger<ZamanliIsIscisi> gunluk,
                           IConfiguration ayar)
    {
        _servisler = servisler;
        _gunluk = gunluk;
        _aktif = ayar.GetValue("ZamanliIs:Aktif", true);
    }

    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        if (!_aktif)
        {
            _gunluk.LogInformation("Zamanlı iş işçisi KAPALI (ZamanliIs:Aktif=false).");
            return;
        }

        // Açılışta: yarıda kalanları serbest bırak ve zamanı olmayan işlere
        //   sonraki çalışma zamanı ver (yeni eklenen iş hemen hesaplansın).
        await GuvenliAsync(BaslangicAsync, "başlangıç bakımı", iptal);

        while (!iptal.IsCancellationRequested)
        {
            await GuvenliAsync(TurAsync, "tur", iptal);
            await Task.Delay(TimeSpan.FromMinutes(1), iptal)
                      .ContinueWith(_ => { }, CancellationToken.None);
        }
    }

    private async Task GuvenliAsync(Func<CancellationToken, Task> is_, string ad,
                                    CancellationToken iptal)
    {
        try { await is_(iptal); }
        catch (OperationCanceledException) when (iptal.IsCancellationRequested) { }
        catch (Exception h) { _gunluk.LogError(h, "Zamanlı iş {Ad} hata verdi.", ad); }
    }

    private async Task BaslangicAsync(CancellationToken iptal)
    {
        await using var kapsam = _servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();

        var serbest = await veri.CalistirAsync("""
            update public.zamanli_is
               set calisiyor = 0,
                   son_sonuc = 'Çalışma yarıda kaldı (servis yeniden başladı).',
                   basarili = 0
             where calisiyor = 1 and calisma_bas < now() - interval '6 hours'
            """, null, iptal);
        if (serbest > 0)
            _gunluk.LogWarning("Zamanlı iş: yarıda kalan {Adet} kayıt serbest bırakıldı.", serbest);

        // Sonraki zamanı olmayan (yeni eklenmiş) işler hesaplansın.
        var kodlar = await veri.ListeAsync(
            "select kod from public.zamanli_is where aktif = 1 and sonraki is null",
            null, o => o.GetString(0), iptal);
        foreach (var kod in kodlar) await SonrakiYazAsync(veri, kod, iptal);
    }

    private async Task TurAsync(CancellationToken iptal)
    {
        await using var kapsam = _servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();

        // Zamanı gelen İLK işi kilitleyerek al (aynı anda tek iş yeter).
        var kod = await veri.TekDegerAsync<string>("""
            with secilen as (
                select kod from public.zamanli_is
                 where aktif = 1 and calisiyor = 0
                   and sonraki is not null and sonraki <= now()
                 order by sonraki
                 limit 1
                 for update skip locked
            )
            update public.zamanli_is z
               set calisiyor = 1, calisma_bas = now()
              from secilen s where z.kod = s.kod
            returning z.kod
            """, null, iptal);

        if (string.IsNullOrEmpty(kod)) return;
        await CalistirAsync(kod, veri, iptal);
    }

    /// <summary>Kilidi ALINMIŞ işi çalıştırır ve sonucu yazar.</summary>
    private async Task CalistirAsync(string kod, VeriKaynagi veri, CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        var basarili = false;
        string sonuc;

        try
        {
            if (!ZamanliIsler.Kayitli.TryGetValue(kod, out var is_))
            {
                // Kodu olmayan satır: sessizce beklemek yerine sebep yazılır.
                sonuc = $"Bilinmeyen iş kodu: {kod} - kodda karşılığı yok.";
            }
            else
            {
                await using var kapsam = _servisler.CreateAsyncScope();
                sonuc = await is_(kapsam.ServiceProvider, iptal);
                basarili = true;
                _gunluk.LogInformation("Zamanlı iş {Kod}: {Sonuc}", kod, sonuc);
            }
        }
        catch (Exception h)
        {
            sonuc = h.Message;
            _gunluk.LogError(h, "Zamanlı iş {Kod} başarısız.", kod);
        }
        kronometre.Stop();

        // Sonuç yazımı İPTAL EDİLEMEZ: yoksa satır "çalışıyor" durumunda kalır.
        await veri.CalistirAsync("""
            update public.zamanli_is
               set calisiyor = 0, son_calisma = now(), basarili = @p1,
                   son_sonuc = @p2, sure_ms = @p3
             where kod = @p0
            """, new object?[] { kod, basarili ? (short)1 : (short)0, Kirp(sonuc, 400),
                                 (int)kronometre.ElapsedMilliseconds }, CancellationToken.None);

        await SonrakiYazAsync(veri, kod, CancellationToken.None);
    }

    /// <summary>Elle "Şimdi Çalıştır" (uçtan çağrılır): kilit alır, çalıştırır.</summary>
    public async Task<string> ElleCalistirAsync(string kod, CancellationToken iptal)
    {
        await using var kapsam = _servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();

        var alindi = await veri.CalistirAsync("""
            update public.zamanli_is set calisiyor = 1, calisma_bas = now()
             where kod = @p0 and calisiyor = 0
            """, new object?[] { kod }, iptal);
        if (alindi == 0) return "İş şu anda zaten çalışıyor.";

        await CalistirAsync(kod, veri, iptal);

        return await veri.TekDegerAsync<string>(
            "select son_sonuc from public.zamanli_is where kod = @p0",
            new object?[] { kod }, iptal) ?? "";
    }

    /// <summary>
    /// Sonraki çalışma zamanı: periyot + gün/saat. Geçmişte kalırsa ileri
    /// atılır — servis kapalıyken kaçan iş, açılışta HEMEN değil bir sonraki
    /// normal saatinde çalışır (gece işi mesai içinde başlamasın).
    /// </summary>
    private static async Task SonrakiYazAsync(VeriKaynagi veri, string kod, CancellationToken iptal)
    {
        var s = await veri.TekAsync("""
            select periyot, gun, saat, dakika from public.zamanli_is where kod = @p0
            """, new object?[] { kod },
            o => new Plan(o.GetInt16(0), o.GetInt16(1), o.GetInt16(2), o.GetInt16(3)), iptal);
        if (s is null) return;

        // ZAMAN VERITABANINDAN OKUNUR, uygulamanin saatinden DEGIL.
        //   Kuyruk "sonraki <= now()" ile taraniyor (PG saati); sonraki ise
        //   uygulamanin saatiyle yaziliyordu. Konteyner UTC, veritabani yerel
        //   saat dilimindeyse fark kadar GERIDE bir zaman yaziliyor ve is
        //   HER TURDA yeniden calisiyordu - sunucuda enabiz.gonder dakikada
        //   bir calisip gunlugu dolduruyordu.
        var simdi = await veri.TekDegerAsync<DateTime>("select now()", null, iptal);
        var hedef = Cekirdek.Zamanlama.ZamanlamaHesabi.Sonraki(
            simdi, s.Periyot, s.Gun, s.Saat, s.Dakika);

        await veri.CalistirAsync("update public.zamanli_is set sonraki = @p1 where kod = @p0",
            new object?[] { kod, hedef }, iptal);
    }

    /// <summary>Zamanlama alanlari - deger tipi (tuple) generic kisitina uymuyor.</summary>
    private sealed record Plan(short Periyot, short Gun, short Saat, short Dakika);




    private static string Kirp(string m, int n) => m.Length <= n ? m : m[..n];
}
