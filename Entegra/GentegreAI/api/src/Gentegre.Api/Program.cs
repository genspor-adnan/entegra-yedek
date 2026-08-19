using System.Globalization;
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
kurucu.Services.AddScoped<OturumDeposu>();
// Singleton: YetkiCozucu (singleton) tuketiyor, kendisi stateless (VeriKaynagi'yi sarar,
//   her cagride kendi baglantisini acar) - paylasilan mutable durumu yok.
kurucu.Services.AddSingleton<YetkiDeposu>();
kurucu.Services.AddScoped<ListeDeposu>();
kurucu.Services.AddScoped<KartDeposu>();
kurucu.Services.AddScoped<BelgeDeposu>();
kurucu.Services.AddScoped<GunlukDeposu>();
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
        zaman = DateTime.Now
    });
}).AllowAnonymous().WithTags("Saglik");

uygulama.KimlikUclariniEkle();
uygulama.ListeUclariniEkle();
uygulama.KartUclariniEkle();
uygulama.BelgeUclariniEkle();
uygulama.AksiyonUclariniEkle();

uygulama.Run();
