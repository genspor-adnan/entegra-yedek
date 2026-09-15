using System.Globalization;
using Gentegre.Cekirdek;
using System.Text.Json;
using System.Text.Json.Serialization;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Api.Uclar;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var kurucu = WebApplication.CreateBuilder(args);

// Turkce siralama/bicimlendirme - InvariantGlobalization kapali (Directory.Build.props).
var kultur = new CultureInfo("tr-TR");
CultureInfo.DefaultThreadCurrentCulture = kultur;
CultureInfo.DefaultThreadCurrentUICulture = kultur;

// ------------------------------------------------------------------ ayarlar ----
kurucu.Services.Configure<GuvenlikAyarlari>(kurucu.Configuration.GetSection("Guvenlik"));

var baglantiDizesi = kurucu.Configuration.GetConnectionString("Gentegre")
    ?? throw new InvalidOperationException("ConnectionStrings:Gentegre tanimli degil.");

// ------------------------------------------------------------------ servisler ----
kurucu.Services.AddSingleton(new VeriKaynagi(baglantiDizesi));
kurucu.Services.AddScoped<KullaniciDeposu>();
// Kimlik no bicimi (679) - kurum profilinden, sube basina 60 sn onbellekli.
kurucu.Services.AddScoped<KimlikKuraliDeposu>();
kurucu.Services.AddScoped<OturumDeposu>();
// Singleton: YetkiCozucu (singleton) tuketiyor, kendisi stateless (VeriKaynagi'yi sarar,
//   her cagride kendi baglantisini acar) - paylasilan mutable durumu yok.
kurucu.Services.AddSingleton<YetkiDeposu>();
kurucu.Services.AddScoped<ListeDeposu>();
kurucu.Services.AddScoped<KartDeposu>();
kurucu.Services.AddScoped<KullaniciAramaDeposu>();
kurucu.Services.AddScoped<TercihDeposu>();
// FAZ 0 - BILDIRIM (399): kuyruk deposu, saglayici fabrikasi ve arka plan iscisi.
//   Iscinin kendisi SINGLETON, deposu her turda scope'tan alinir.
kurucu.Services.AddScoped<BildirimDeposu>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.BildirimHesaplari>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.BildirimGondericiFabrikasi>();
kurucu.Services.AddHttpClient("bildirim");
kurucu.Services.AddHostedService<Gentegre.Api.Servisler.BildirimIscisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.RandevuHatirlatmasi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.PanikDegerBildirimi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.DisKurumBasvurusu>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.TitckIlacGuncelleme>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.SgkIlacListesi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.IlacKartFiyat>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.EnabizPaketUretici>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.EnabizTetikleyici>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.EnabizGonderimi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.ItsServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Uclar.ItsServisiKisayol>();
kurucu.Services.AddHttpClient("katalog");
// FAZ 0 - ZAMANLI ISLER (405): TITCK haftalik guncelleme gibi isler.
//   Isci SINGLETON (hosted) ama elle calistirma ucundan da cagriliyor -
//   bu yuzden ayrica singleton olarak kaydedilip hosted servis ondan alinir.
kurucu.Services.AddSingleton<Gentegre.Api.Servisler.ZamanliIsIscisi>();
kurucu.Services.AddHostedService(s => s.GetRequiredService<Gentegre.Api.Servisler.ZamanliIsIscisi>());
kurucu.Services.AddScoped<KisiDeposu>();
kurucu.Services.AddScoped<StokDurumDeposu>();
kurucu.Services.AddScoped<RandevuAyarDeposu>();
kurucu.Services.AddScoped<AyarDeposu>();
kurucu.Services.AddScoped<KurumProfilDeposu>();
kurucu.Services.AddScoped<PanelDeposu>();
kurucu.Services.AddScoped<RolYetkiDeposu>();
kurucu.Services.AddScoped<IskontoTalepDeposu>();
kurucu.Services.AddScoped<DokumDeposu>();
kurucu.Services.AddScoped<RolKullaniciDeposu>();
kurucu.Services.AddScoped<KullaniciSubeDeposu>();
kurucu.Services.AddScoped<YetkiSenkronu>();
kurucu.Services.AddScoped<DokumanDeposu>();
kurucu.Services.AddSingleton<ReferansDeposu>();
kurucu.Services.AddScoped<BelgeDeposu>();
// SIGORTA (430): kod cevirici + adapterler + is akisi servisi. Adapter'lar
//   ISigortaSaglayici olarak kayitli; servis kod eslesmesiyle dogrusunu secer.
kurucu.Services.AddScoped<Gentegre.Veri.Depolar.SigortaKodDeposu>();
kurucu.Services.AddScoped<Gentegre.Cekirdek.Sigorta.ISigortaKodCevirici>(
    s => s.GetRequiredService<Gentegre.Veri.Depolar.SigortaKodDeposu>());
kurucu.Services.AddScoped<Gentegre.Cekirdek.Sigorta.ISigortaSaglayici,
                          Gentegre.Api.Servisler.AsmedSaglayici>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.SigortaServisi>();
// CIHAZ ARA KATMANI (432): surucu I/O YAPMAZ, yalniz metni cevirir - bu yuzden
//   singleton. Alim/kayit CihazServisi'nde (scoped), dinleyici arka planda.
kurucu.Services.AddSingleton<Gentegre.Cekirdek.Cihaz.ICihazSurucu,
                             Gentegre.Cekirdek.Cihaz.Hl7Surucu>();
kurucu.Services.AddSingleton<Gentegre.Cekirdek.Cihaz.ICihazSurucu,
                             Gentegre.Cekirdek.Cihaz.AstmSurucu>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.CihazServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.LabServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.KulturServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.GenetikServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.KaliteKontrolServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.DisLabServisi>();
// AI REHBER (447): katalog okur, veri yazmaz - kayit degistirmez.
// DIL MODELI (450): anahtar sunucudan okunur (ANTHROPIC_API_KEY / Ai:ApiAnahtar /
//   gizli/ai-anahtar.txt); anahtar yokken saglayici "hazir degil" der ve rehber
//   katalogdan cevap vermeye devam eder.
kurucu.Services.AddHttpClient("ai");
kurucu.Services.AddSingleton(kurucu.Configuration.GetSection("Ai")
    .Get<Gentegre.Api.Servisler.ModelSecenekleri>() ?? new Gentegre.Api.Servisler.ModelSecenekleri());
kurucu.Services.AddSingleton<Gentegre.Api.Servisler.IModelSaglayici,
                             Gentegre.Api.Servisler.AnthropicSaglayici>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.RehberModeli>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.RehberServisi>();
// AI KONTROLLU ONERI (449): kayittaki eksikleri isaret eder, yazmaz.
kurucu.Services.AddScoped<Gentegre.Api.Servisler.OneriServisi>();
kurucu.Services.AddHostedService<Gentegre.Api.Servisler.CihazDinleyici>();
kurucu.Services.AddScoped<KasaDeposu>();
kurucu.Services.AddScoped<GunlukDeposu>();
kurucu.Services.AddScoped<UtsDeposu>();
kurucu.Services.AddSingleton<LogDeposu>();
kurucu.Services.AddScoped<KimlikServisi>();
kurucu.Services.AddScoped<BaglamCozucu>();
kurucu.Services.AddSingleton<JwtUretici>();
kurucu.Services.AddSingleton<YetkiCozucu>();

kurucu.Services.ConfigureHttpJsonOptions(o =>
{
    o.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    o.SerializerOptions.PropertyNameCaseInsensitive = true;
    o.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    // Liste satirlarinin anahtarlari katalogdaki adlardir - donusturulmez.
    o.SerializerOptions.DictionaryKeyPolicy = null;
});

var guvenlik = kurucu.Configuration.GetSection("Guvenlik").Get<GuvenlikAyarlari>() ?? new();

kurucu.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = guvenlik.Yayinci,
            ValidAudience = guvenlik.Hedef,
            IssuerSigningKey = new SymmetricSecurityKey(
                System.Text.Encoding.UTF8.GetBytes(guvenlik.ImzaAnahtari)),
            ClockSkew = TimeSpan.FromSeconds(30)
        };

        // 401 govdesi de sozlesmedeki bicimde donsun (API §1.2).
        o.Events = new JwtBearerEvents
        {
            OnChallenge = async ctx =>
            {
                ctx.HandleResponse();
                if (ctx.Response.HasStarted) return;
                ctx.Response.StatusCode = 401;
                ctx.Response.ContentType = "application/json; charset=utf-8";
                var govde = new
                {
                    hata = new
                    {
                        kod = "YETKISIZ",
                        mesaj = "Oturum gecersiz ya da suresi dolmus.",
                        izlemeNo = ctx.HttpContext.Items["izlemeNo"] as string ?? ""
                    }
                };
                await ctx.Response.WriteAsync(JsonSerializer.Serialize(govde, JsonAyarlari.Secenekler));
            }
        };
    });

kurucu.Services.AddAuthorization();
kurucu.Services.AddOpenApi();

kurucu.Services.AddCors(o => o.AddDefaultPolicy(p => p
    .WithOrigins(kurucu.Configuration.GetSection("Cors:Kaynaklar").Get<string[]>() ?? Array.Empty<string>())
    .AllowAnyHeader()
    .AllowAnyMethod()));

// Kurulus saat dilimi: konteyner UTC calissa da "simdi" Turkiye saatidir
//   (appsettings > Kurulus:SaatDilimi ile degistirilebilir).
Saat.DilimAyarla(kurucu.Configuration["Kurulus:SaatDilimi"]);

// e-Belge gonderimi entegratore HTTP ile gider: named client, makul zaman asimi
//   (gonderim entegratorde 1-2 dakika surebiliyor).
kurucu.Services.AddHttpClient("ebelge", i => i.Timeout = TimeSpan.FromMinutes(2));
// ÜTS (Saglik Bakanligi Urun Takip Sistemi) - ayni desen (223).
kurucu.Services.AddHttpClient("uts", i => i.Timeout = TimeSpan.FromMinutes(2));
// SKRS (Saglik.NET kod sunucusu, 336): kod listeleri buyuk olabiliyor.
kurucu.Services.AddHttpClient("skrs", i => i.Timeout = TimeSpan.FromMinutes(2));
kurucu.Services.AddScoped<Gentegre.Api.Servisler.UtsServisi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.EBelgeGonderimi>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.EBelgeSorgu>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.EBelgeGelen>();
kurucu.Services.AddScoped<Gentegre.Api.Servisler.GelenBelgeAktar>();

var uygulama = kurucu.Build();

// ------------------------------------------------------------------- boru hatti ----
uygulama.UseMiddleware<HataAraKatmani>();
uygulama.UseCors();
uygulama.UseAuthentication();
uygulama.UseAuthorization();

if (uygulama.Environment.IsDevelopment())
    uygulama.MapOpenApi();

uygulama.MapGet("/api/saglik", async (VeriKaynagi veri, CancellationToken iptal) =>
{
    var surum = await veri.TekDegerAsync<string>("select version()", null, iptal);
    return Results.Ok(new
    {
        durum = "ayakta",
        veritabani = surum,
        zaman = Saat.Simdi
    });
}).AllowAnonymous().WithTags("Saglik");

uygulama.KimlikUclariniEkle();
uygulama.ListeUclariniEkle();
uygulama.KartUclariniEkle();
uygulama.KisiUclariniEkle();
uygulama.StokDurumUclariniEkle();
// Randevu Ayarlari > Bolumler (251): bolum/hekim bazli randevu duzeni.
uygulama.RandevuUclariniEkle();
uygulama.RadyolojiUclariniEkle();
uygulama.IcmalUclariniEkle();

uygulama.PrimUclariniEkle();
uygulama.EntegrasyonUclariniEkle();
uygulama.MesajUclariniEkle();
uygulama.AiUclariniEkle();
uygulama.AyarUclariniEkle();
uygulama.TercihUclariniEkle();
uygulama.BildirimUclariniEkle();
uygulama.KatalogUclariniEkle();
uygulama.MuayeneUclariniEkle();
uygulama.ReceteUclariniEkle();
uygulama.EnabizUclariniEkle();
uygulama.ItsUclariniEkle();
uygulama.ZamanliIsUclariniEkle();
uygulama.KurumProfilUclariniEkle();
uygulama.PanelUclariniEkle();
uygulama.RolYetkiUclariniEkle();
uygulama.IskontoOnayUclariniEkle();
uygulama.DokumUclariniEkle();
uygulama.DokumanUclariniEkle();
uygulama.DokumanYonetimUclariniEkle();
uygulama.GelenBelgeUclariniEkle();
uygulama.CeviriUclariniEkle();
uygulama.DokumanIcerikUcunuEkle();
uygulama.ReferansUclariniEkle();
uygulama.BelgeUclariniEkle();
uygulama.KasaUclariniEkle();
uygulama.FiyatListesiUclariniEkle();
uygulama.IceriAlmaUclariniEkle();
uygulama.AksiyonUclariniEkle();
uygulama.KodListeUclariniEkle();
uygulama.UtsUclariniEkle();
uygulama.UretimUclariniEkle();
uygulama.SigortaUclariniEkle();
uygulama.CihazUclariniEkle();
uygulama.LabUclariniEkle();

// YETKI SENKRONU (kullanici: "menulerdeki ekle/sil/degisimlerde yetki matrisini
//   update et"): katalogdaki ekran/aksiyon yetkileri ile `yetki` tablosu her
//   aciliste karsilastirilir - yeni ekran matriste kendiliginden belirir,
//   kaldirilan ekranin yetkisi pasiflesir. Hata uygulamayi DURDURMAZ.
using (var kapsam = uygulama.Services.CreateScope())
{
    try
    {
        await kapsam.ServiceProvider.GetRequiredService<YetkiSenkronu>().CalistirAsync();
    }
    catch (Exception h)
    {
        kapsam.ServiceProvider.GetRequiredService<ILogger<Program>>()
              .LogWarning(h, "Yetki senkronu calistirilamadi - matris eski haliyle acilir.");
    }
}

uygulama.Run();
