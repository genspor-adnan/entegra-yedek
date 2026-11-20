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

        // EK RAPOR (addendum) onaylanınca ayrı bağlantı açılmaz: asıl raporun satırı yeniden planlanır, kod aynı.
        var ek = await b.TekDegerAsync<int>(
            "insert into public.radyoloji_rapor (istem_id, durum, kilit, ust_rapor_id) values (@p0, 3, 1, @p1) returning id", t, [z.Istem, z.Rapor], Iptal);
        await RaporGonderimi.PlanlaAsync(b, t, ek, 0, Iptal, simdi.AddHours(5));
        Assert.Empty(await SatirlarAsync(b, t, ek));
        s = await SatirlarAsync(b, t, z.Rapor);
        Assert.Equal(kod, s[0]["kod"]!.ToString());
        Assert.Equal(simdi.AddHours(6), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());
        // Teslim listesi gönderimi isteme göre bulur (1393): en son rapor kaydı ek rapor olsa da görünür.
        Assert.Equal(1, await b.TekDegerAsync<int>(
            "select hasta_gonderim_durum::int from public.v_radyoloji_teslim_takip where istem_id = @p0", t, [z.Istem], Iptal));

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

    /// <summary>
    /// ÇEKİRDEK KURAL uçtan uca (gerçek servis, kendi transaction'ları): başvurunun borcu varken gönderim BEKLER ve
    /// bağlantı raporu açmaz; borç kapanınca aynı satır gönderilir (bildirim kuyruğa yazılır) ve bağlantı açılır;
    /// hastanın açması dijital teslim yazar; "borca rağmen" borç varken de gönderir. Satırlarını sonunda siler.
    /// </summary>
    [VtFact]
    public async Task Borc_varken_bekler_kapaninca_gonderir_ve_baglanti_acilir()
    {
        if (!_olgu.Baglandi(nameof(Borc_varken_bekler_kapaninca_gonderir_ve_baglanti_acilir))) return;
        var veri = _olgu.Gerekli();
        var gunluk = new HataToplayan();
        var servis = new RaporGonderimi(veri, new Gentegre.Veri.Depolar.BildirimDeposu(veri), gunluk);
        Zemin z;
        await using var b = await veri.AcAsync();
        var eskiAyar = await b.ListeAsync("select * from public.radyoloji_rapor_gonderim_ayar", null, [], OkuyucuGenisletmeleri.Sozluk, Iptal);
        await using (var t = await b.BeginTransactionAsync())
        {
            z = await ZeminAsync(b, t);
            await AyarAsync(b, t, z.Sube, true, 0);
            await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim_kural where sube_id = @p0 and kapsam = 2 and hizmet_id = @p1", t, [z.Sube, z.Hizmet], Iptal);
            await b.CalistirAsync("insert into public.radyoloji_rapor_gonderim_kural (sube_id, kapsam, hizmet_id, zaman_tur) values (@p0, 2, @p1, 0)", t, [z.Sube, z.Hizmet], Iptal);
            await RaporGonderimi.PlanlaAsync(b, t, z.Rapor, 0, Iptal);
            await t.CommitAsync();
        }
        try
        {
            var hasta = (Id: await b.TekDegerAsync<int>("select id from public.radyoloji_rapor_gonderim where rapor_id = @p0 and alici_tur = 1", null, [z.Rapor], Iptal),
                         Kod: await b.TekDegerAsync<string>("select kod from public.radyoloji_rapor_gonderim where rapor_id = @p0 and alici_tur = 1", null, [z.Rapor], Iptal) ?? "");
            var hekim = await b.TekDegerAsync<int>("select id from public.radyoloji_rapor_gonderim where rapor_id = @p0 and alici_tur = 2", null, [z.Rapor], Iptal);

            // BORÇ VAR (1000): bekler, bildirim yazılmaz, bağlantı raporu açmaz.
            Assert.Equal(RaporGonderimi.DurumBorc, await servis.SimdiGonderAsync(hasta.Id, false, 0, Iptal));
            Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.bildirim where kaynak_tur = 51 and kaynak_id = @p0", null, [hasta.Id], Iptal));
            Assert.Equal("iletisim", (await servis.AcAsync(hasta.Kod, Iptal))!.Durum);
            Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.radyoloji_teslim where istem_id = @p0", null, [z.Istem], Iptal));

            // BORCA RAĞMEN (dış doktora): borç varken de gider; hastanın satırı beklemeye devam eder.
            Assert.Equal(RaporGonderimi.DurumGonderildi, await servis.SimdiGonderAsync(hekim, true, 0, Iptal));
            Assert.Equal(2L, await b.TekDegerAsync<long>("select count(*) from public.bildirim where kaynak_tur = 51 and kaynak_id = @p0", null, [hekim], Iptal));

            // BORÇ KAPANDI: işçi turu bekleyeni gönderir (SMS; hastada e-posta kapalı), bağlantı açılır.
            await b.CalistirAsync("update public.belge set genel_toplam = 0 where id = @p0", null, [z.Belge], Iptal);
            Assert.Equal(0m, await RaporGonderimi.BorcAsync(b, null, z.Belge, Iptal));
            // İşçi "zamanı gelen"e VERİTABANI saatiyle bakar; uygulama saati birkaç yüz ms ileride olabilir - kısa bekleme.
            var gonderilen = 0;
            for (var deneme = 0; deneme < 20 && gonderilen == 0; deneme++)
            {
                gonderilen = await servis.SiradakileriIsleAsync(500, Iptal);
                if (gonderilen == 0) await Task.Delay(250);
            }
            Assert.True(gonderilen >= 1, "İşçi turu göndermedi: " + string.Join(" | ", gunluk.Hatalar));
            Assert.Equal(3, await b.TekDegerAsync<int>("select durum::int from public.radyoloji_rapor_gonderim where id = @p0", null, [hasta.Id], Iptal));
            var govde = await b.TekDegerAsync<string>("select govde from public.bildirim where kaynak_tur = 51 and kaynak_id = @p0 and kanal = 1", null, [hasta.Id], Iptal);
            Assert.Contains($"https://rapor.test/r/{hasta.Kod}", govde);
            Assert.Contains("RG TEST H***", govde);                                  // ad maskeli
            var acilis = await servis.AcAsync(hasta.Kod.ToLowerInvariant(), Iptal);   // kod büyük / küçük harf duyarsız
            Assert.Equal("ok", acilis!.Durum);
            await servis.AcAsync(hasta.Kod, Iptal);
            // Hastanın açması dijital teslim: tek satır (ikinci açılış yinelemez), teslim listesi "teslim edildi".
            Assert.Equal(1L, await b.TekDegerAsync<long>("select count(*) from public.radyoloji_teslim where istem_id = @p0 and tur = 1 and dijital_verildi = 1", null, [z.Istem], Iptal));
            Assert.Equal(2, await b.TekDegerAsync<int>("select takip_durum from public.v_radyoloji_teslim_takip where istem_id = @p0", null, [z.Istem], Iptal));
            Assert.Equal(2, await b.TekDegerAsync<int>("select acilma_sayisi from public.radyoloji_rapor_gonderim where id = @p0", null, [hasta.Id], Iptal));

            // ONAY GERİ ALINDI: bağlantı raporu açmaz.
            await using (var t = await b.BeginTransactionAsync())
            {
                await RaporGonderimi.IptalAsync(b, t, z.Rapor, 0, Iptal);
                await t.CommitAsync();
            }
            Assert.Equal("guncel", (await servis.AcAsync(hasta.Kod, Iptal))!.Durum);
            Assert.Null(await servis.AcAsync("OLMAYANKOD", Iptal));
        }
        finally
        {
            await b.CalistirAsync("""
                delete from public.bildirim where kaynak_tur = 51 and kaynak_id in (select id from public.radyoloji_rapor_gonderim where rapor_id = @p0);
                """, null, [z.Rapor], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_teslim where istem_id = @p0", null, [z.Istem], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim where rapor_id = @p0", null, [z.Rapor], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim_kural where sube_id = @p0 and hizmet_id = @p1", null, [z.Sube, z.Hizmet], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_rapor where id = @p0", null, [z.Rapor], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_istem where id = @p0", null, [z.Istem], Iptal);
            await b.CalistirAsync("delete from public.belge where id = @p0", null, [z.Belge], Iptal);
            await b.CalistirAsync("delete from public.hizmet where id = @p0", null, [z.Hizmet], Iptal);
            await b.CalistirAsync("delete from public.kategori where id = @p0 or id = (select ust_id from public.kategori where id = @p0)", null, [z.Kategori], Iptal);
            await b.CalistirAsync("delete from public.taraf_personel where id = @p0", null, [z.Hekim], Iptal);
            await b.CalistirAsync("delete from public.taraf where id in (@p0, @p1)", null, [z.Hasta, z.Hekim], Iptal);
            // Şube ayarı testten önceki haline döner (test DB'sinde başka testin ayarı olabilir).
            if (eskiAyar.Count == 0) await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim_ayar where sube_id = @p0", null, [z.Sube], Iptal);
        }
    }

    /// <summary>İşçi turunun yuttuğu hataları testte görünür kılar.</summary>
    private sealed class HataToplayan : Microsoft.Extensions.Logging.ILogger<RaporGonderimi>
    {
        public List<string> Hatalar { get; } = [];
        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;
        public bool IsEnabled(Microsoft.Extensions.Logging.LogLevel logLevel) => true;
        public void Log<TState>(Microsoft.Extensions.Logging.LogLevel logLevel, Microsoft.Extensions.Logging.EventId eventId,
                                TState state, Exception? exception, Func<TState, Exception?, string> formatter)
        { if (exception is not null) Hatalar.Add(exception.GetType().Name + ": " + exception.Message); }
    }
}
