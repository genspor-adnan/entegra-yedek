using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// RADYOLOJİ RAPOR GÖNDERİMİ (1389-1392; kullanıcı 20.11.2026): gönderim zamanı kod › kategori › tümü, kritik bulguda
/// tek süre (0 = elle); borç kuralı raporun BAŞVURUSUNA bakar; gönderen dış doktor yalnız kartında istiyorsa; yeniden
/// onayda bağlantı kodu korunur. Veritabanı testleri kendi transaction'ında çalışır ve geri alınır.
/// </summary>
public sealed class RaporGonderimTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    // ------------------------------------------------------------------------------------------ saf kurallar --
    private static readonly RaporGonderimKurali.Kural Tumu = new(0, null, null, 1, 2, 0);
    private static readonly RaporGonderimKurali.Kural KatMr = new(1, 14, null, 1, 3, 0, "MR");
    private static readonly RaporGonderimKurali.Kural KatUst = new(1, 5, null, 2, 0, 900, "Görüntüleme");
    private static readonly RaporGonderimKurali.Kural Kod = new(2, null, 77, 1, 1, 0, "804.160 Akciğer grafisi");

    [Fact]
    public void Oncelik_kod_sonra_kategori_sonra_tumu()
    {
        RaporGonderimKurali.Kural[] kurallar = [Tumu, KatMr, KatUst, Kod];
        Assert.Same(Kod, RaporGonderimKurali.Sec(kurallar, 77, [14, 5]));        // kod kategoriyi yener
        Assert.Same(KatMr, RaporGonderimKurali.Sec(kurallar, 1, [14, 5]));       // en yakın kategori
        Assert.Same(KatUst, RaporGonderimKurali.Sec(kurallar, 1, [99, 5]));      // üst kategori
        Assert.Same(Tumu, RaporGonderimKurali.Sec(kurallar, 1, [42]));           // hiçbiri: tümü
        Assert.Null(RaporGonderimKurali.Sec([KatMr, Kod], 1, [42]));             // tümü de yok: otomatik gitmez
    }

    [Fact]
    public void Zaman_saat_sonra_ve_ertesi_gun_sube_saatiyle()
    {
        var istanbul = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
        var simdi = new DateTime(2026, 11, 20, 20, 30, 0, DateTimeKind.Utc);     // İstanbul 23:30
        Assert.Equal(simdi.AddHours(3), RaporGonderimKurali.Zaman(KatMr, simdi, istanbul));
        Assert.Equal(simdi, RaporGonderimKurali.Zaman(new(0, null, null, 0, 0, 0), simdi, istanbul));
        // Ertesi gün 15:00 İstanbul = 12:00 UTC; "ertesi gün" şubenin gününe göre (21 Kasım), UTC gününe göre değil.
        Assert.Equal(new DateTime(2026, 11, 21, 12, 0, 0, DateTimeKind.Utc), RaporGonderimKurali.Zaman(KatUst, simdi, istanbul));
        // UTC'de gün dönmüş ama şubede dönmemişken de doğru: UTC 21.11 00:30 = İstanbul 03:30 → 22.11 15:00.
        Assert.Equal(new DateTime(2026, 11, 22, 12, 0, 0, DateTimeKind.Utc),
                     RaporGonderimKurali.Zaman(KatUst, new DateTime(2026, 11, 21, 0, 30, 0, DateTimeKind.Utc), istanbul));
        Assert.Equal("Kategori MR · 3 saat sonra", RaporGonderimKurali.Aciklama(KatMr));
        Assert.Equal("Kategori Görüntüleme · ertesi gün 15:00", RaporGonderimKurali.Aciklama(KatUst));
    }

    [Fact]
    public void Baglanti_kodu_ve_maske()
    {
        var kod = RaporGonderimi.YeniKod();
        Assert.Equal(16, kod.Length);
        Assert.DoesNotContain(kod, c => "01OI".Contains(c));
        Assert.NotEqual(kod, RaporGonderimi.YeniKod());
        Assert.Equal("Ayşe K***", RaporGonderimi.Maske("Ayşe Kaya"));
        Assert.Equal("Ali Rıza D***", RaporGonderimi.Maske("Ali Rıza Demir"));
        Assert.Equal("https://x.com/ai/r/ABCD", RaporGonderimi.Baglanti("https://x.com/ai/", "ABCD"));
    }

    // ------------------------------------------------------------------------------------------- veritabanı --
    private sealed record Zemin(int Sube, int Hasta, int Hekim, int Hizmet, int Kategori, int Belge, int Istem, int Rapor);

    private static async Task<Zemin> ZeminAsync(NpgsqlConnection b, NpgsqlTransaction t, bool kritik = false, short hekimTercih = 3)
    {
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id, cep_tel, eposta) values ('RG TEST HASTA', @p1, 1, @p0, '05321112233', 'h@test.tr') returning id",
            t, [sube, $"RGH{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var hekim = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, personel, sube_id, cep_tel, eposta) values ('RG TEST DIS HEKIM', @p1, 1, @p0, '05442223344', 'd@test.tr') returning id",
            t, [sube, $"RGD{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        await b.CalistirAsync(
            "insert into public.taraf_personel (id, dis_hekim, rapor_bildirim, sube_id) values (@p0, 1, @p1, @p2)",
            t, [hekim, hekimTercih, sube], Iptal);
        var ust = await b.TekDegerAsync<int>("insert into public.kategori (kod, ad) values (@p0, 'RG ÜST') returning id",
            t, [$"RGU{Guid.NewGuid().ToString("N")[..6]}"], Iptal);
        var kategori = await b.TekDegerAsync<int>("insert into public.kategori (kod, ad, ust_id) values (@p0, 'RG MR', @p1) returning id",
            t, [$"RGK{Guid.NewGuid().ToString("N")[..6]}", ust], Iptal);
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, kategori, sube_id) values (@p0, 'RG TEST MR', 1, 2, @p1, @p2) returning id",
            t, [$"RG{Guid.NewGuid().ToString("N")[..8]}", kategori, sube], Iptal);
        var belge = await b.TekDegerAsync<int>(
            "insert into public.belge (tipi, tur, taraf_id, belge_tarihi, genel_toplam, sube_id) values (30, 19, @p0, now(), 1000, @p1) returning id",
            t, [hasta, sube], Iptal);
        var istem = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, belge_id, istek_hekim_id, kritik)
            values (@p0, @p1, @p2, 2, @p3, 5, @p4, @p5, @p6) returning id
            """, t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12], belge, hekim, (short)(kritik ? 1 : 0)], Iptal);
        var rapor = await b.TekDegerAsync<int>(
            "insert into public.radyoloji_rapor (istem_id, durum, kilit) values (@p0, 3, 1) returning id", t, [istem], Iptal);
        return new Zemin(sube, hasta, hekim, hizmet, kategori, belge, istem, rapor);
    }

    private static Task AyarAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube, bool otomatik, int kritikDk)
        => b.CalistirAsync("""
            insert into public.radyoloji_rapor_gonderim_ayar (sube_id, otomatik, kritik_dakika, web_kok)
            values (@p0, @p1, @p2, 'https://rapor.test')
            on conflict (sube_id) do update set otomatik = excluded.otomatik, kritik_dakika = excluded.kritik_dakika,
                   web_kok = excluded.web_kok, borc_kontrol = 1, hasta_sms = 1, hasta_eposta = 0
            """, t, [sube, (short)(otomatik ? 1 : 0), kritikDk], Iptal);

    private static Task<List<IDictionary<string, object?>>> SatirlarAsync(NpgsqlConnection b, NpgsqlTransaction t, int rapor)
        => b.ListeAsync("""
            select alici_tur, kod, kanal, durum, planlanan, kural from public.radyoloji_rapor_gonderim
             where rapor_id = @p0 order by alici_tur
            """, t, [rapor], OkuyucuGenisletmeleri.Sozluk, Iptal);

    [VtFact]
    public async Task Planlama_kategori_kurali_dis_hekim_ve_kod_korunur()
    {
        if (!_olgu.Baglandi(nameof(Planlama_kategori_kurali_dis_hekim_ve_kod_korunur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var z = await ZeminAsync(b, t);
        await AyarAsync(b, t, z.Sube, true, 5);
        await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim_kural where sube_id = @p0", t, [z.Sube], Iptal);
        await b.CalistirAsync("""
            insert into public.radyoloji_rapor_gonderim_kural (sube_id, kapsam, kategori_id, hizmet_id, zaman_tur, saat)
            values (@p0, 0, null, null, 1, 2), (@p0, 1, @p1, null, 1, 3)
            """, t, [z.Sube, z.Kategori], Iptal);

        var simdi = new DateTime(2026, 11, 20, 9, 0, 0, DateTimeKind.Utc);
        await RaporGonderimi.PlanlaAsync(b, t, z.Rapor, 0, Iptal, simdi);
        var s = await SatirlarAsync(b, t, z.Rapor);
        Assert.Equal(2, s.Count);                                               // hasta + gönderen dış doktor
        Assert.Equal(1, Convert.ToInt32(s[0]["durum"]));                        // planlandı
        Assert.Equal(1, Convert.ToInt32(s[0]["kanal"]));                        // hasta: yalnız SMS (ayar)
        Assert.Equal(3, Convert.ToInt32(s[1]["kanal"]));                        // doktor: tercihi ikisi
        Assert.Equal(simdi.AddHours(3), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());   // kategori kuralı (3 saat)
        Assert.Contains("Kategori RG MR", s[0]["kural"]!.ToString());
        var kod = s[0]["kod"]!.ToString();

        // KOD KURALI kategoriyi yener; yeniden onayda bağlantı kodu AYNI kalır (basılmış karekod yaşar).
        await b.CalistirAsync("""
            insert into public.radyoloji_rapor_gonderim_kural (sube_id, kapsam, hizmet_id, zaman_tur, saat) values (@p0, 2, @p1, 1, 1)
            """, t, [z.Sube, z.Hizmet], Iptal);
        await RaporGonderimi.IptalAsync(b, t, z.Rapor, 0, Iptal);
        Assert.All(await SatirlarAsync(b, t, z.Rapor), x => Assert.Equal(9, Convert.ToInt32(x["durum"])));
        await RaporGonderimi.PlanlaAsync(b, t, z.Rapor, 0, Iptal, simdi);
        s = await SatirlarAsync(b, t, z.Rapor);
        Assert.Equal(kod, s[0]["kod"]!.ToString());
        Assert.Equal(simdi.AddHours(1), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());
        Assert.StartsWith("Kod", s[0]["kural"]!.ToString());

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kritik_tek_sure_sifir_elle_ve_otomatik_kapaliyken_yalniz_baglanti()
    {
        if (!_olgu.Baglandi(nameof(Kritik_tek_sure_sifir_elle_ve_otomatik_kapaliyken_yalniz_baglanti))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var z = await ZeminAsync(b, t, kritik: true, hekimTercih: 0);
        var simdi = new DateTime(2026, 11, 20, 9, 0, 0, DateTimeKind.Utc);

        // Kritik: kurallara bakılmaz, 5 dk. Dış doktor rapor bildirimi istemiyor: satırı yok.
        await AyarAsync(b, t, z.Sube, true, 5);
        await RaporGonderimi.PlanlaAsync(b, t, z.Rapor, 0, Iptal, simdi);
        var s = await SatirlarAsync(b, t, z.Rapor);
        Assert.Single(s);
        Assert.Equal(simdi.AddMinutes(5), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());

        // Kritik süre 0: otomatik gitmez (hazır, plan yok) - bağlantı yine var.
        await AyarAsync(b, t, z.Sube, true, 0);
        await RaporGonderimi.PlanlaAsync(b, t, z.Rapor, 0, Iptal, simdi);
        s = await SatirlarAsync(b, t, z.Rapor);
        Assert.Equal(0, Convert.ToInt32(s[0]["durum"]));
        Assert.Null(s[0]["planlanan"]);

        // Otomatik kapalı: yalnız bağlantı (kâğıttaki karekod için).
        await AyarAsync(b, t, z.Sube, false, 5);
        await RaporGonderimi.PlanlaAsync(b, t, z.Rapor, 0, Iptal, simdi);
        s = await SatirlarAsync(b, t, z.Rapor);
        Assert.Equal(0, Convert.ToInt32(s[0]["durum"]));
        Assert.Equal(16, s[0]["kod"]!.ToString()!.Length);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Borc_yalniz_basvurunun_hasta_payi_ve_tahsilatla_kapanir()
    {
        if (!_olgu.Baglandi(nameof(Borc_yalniz_basvurunun_hasta_payi_ve_tahsilatla_kapanir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var z = await ZeminAsync(b, t);

        Assert.Equal(1000m, await RaporGonderimi.BorcAsync(b, t, z.Belge, Iptal));
        Assert.Equal(0m, await RaporGonderimi.BorcAsync(b, t, null, Iptal));     // başvurusuz istem: borç yok

        // Tahsilat (gerçekleşmiş kasa işlemi) borcu kapatır; eşik altı kalan borç sayılmaz.
        var tur = await b.TekDegerAsync<int>("select kod from public.kasa_islem_turu where yon = 1 order by kod limit 1", t, [], Iptal);
        await b.CalistirAsync("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, tutar, yerel_tutar, durum, belge_id, sube_id)
            values (@p0, now(), @p1, 999.95, 999.95, 2, @p2, @p3)
            """, t, [tur, z.Hasta, z.Belge, z.Sube], Iptal);
        Assert.Equal(0m, await RaporGonderimi.BorcAsync(b, t, z.Belge, Iptal));

        await t.RollbackAsync();
    }
}
