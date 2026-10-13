// =============================================================================
//  GENTEGRE AKTARIM AJANI - Delphi (MSSQL) -> Gentegre AI, tek yön (dokuman/18 §11)
//
//  Müşteri sunucusunda çalışır, yalnız DIŞARI HTTPS açar. Change Tracking'den
//  değişiklikleri okur, toplam paketleri /api/aktarim/paket'e yollar.
//
//    GentegreAktarimAjani                 konsol kipi (Ctrl+C ile durur)
//    GentegreAktarimAjani --tek-tur       bir tur çalış, çık (0 = tamam, 1 = hata)
//    GentegreAktarimAjani --sifrele       ajan.json'daki düz sırları DPAPI ile şifrele
//    GentegreAktarimAjani --ayar <yol>    başka ayar dosyası (varsayılan exe yanında ajan.json)
//    sc create GentegreAktarim binPath= "<yol>\GentegreAktarimAjani.exe" start= auto
//                                         Windows servisi olarak (aynı exe)
// =============================================================================
using Gentegre.Aktarim.Ajan;
using Microsoft.Extensions.Logging;

Console.OutputEncoding = System.Text.Encoding.UTF8;
var ayarYolu = Path.Combine(AppContext.BaseDirectory, "ajan.json");
var i = Array.IndexOf(args, "--ayar");
if (i >= 0 && i + 1 < args.Length) ayarYolu = Path.GetFullPath(args[i + 1]);

if (args.Contains("--sifrele"))
{
    Console.WriteLine($"{Ayarlar.Sifrele(ayarYolu)} alan şifrelendi: {ayarYolu}");
    return 0;
}

var ayar = Ayarlar.Oku(ayarYolu);
var gunlukKlasoru = Path.IsPathRooted(ayar.GunlukKlasoru) ? ayar.GunlukKlasoru
                  : Path.Combine(Path.GetDirectoryName(ayarYolu)!, ayar.GunlukKlasoru);

if (args.Contains("--tek-tur"))
{
    using var fabrika = LoggerFactory.Create(b => b.AddSimpleConsole(o => o.SingleLine = true)
                                                   .AddProvider(new DosyaGunlugu(gunlukKlasoru)));
    var gunluk = fabrika.CreateLogger("Ajan");
    using var api = new ApiIstemci(ayar, gunluk);
    var aktarici = new Aktarici(new DelphiOkuyucu(ayar.GercekBaglanti), api, ayar, gunluk);
    var s = await aktarici.TurAsync(CancellationToken.None);
    gunluk.LogInformation("Tur: versiyon {V}, {P} paket, {K} kök, {S} silme{H}", s.Versiyon, s.Paket, s.Kok, s.Silinen,
                          s.Hata is null ? "" : " - HATA " + s.Hata);
    return s.Hata is null ? 0 : 1;
}

var kurucu = Host.CreateApplicationBuilder(args);
kurucu.Services.AddWindowsService(o => o.ServiceName = "GentegreAktarim");
kurucu.Logging.AddProvider(new DosyaGunlugu(gunlukKlasoru));
kurucu.Services.AddSingleton(ayar);
kurucu.Services.AddHostedService<AktarimIscisi>();
await kurucu.Build().RunAsync();
return 0;
