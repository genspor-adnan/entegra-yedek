using System.Net;
using System.Net.Sockets;
using System.Text;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// KENDİ RAPORUMUZUN ORU'SU (1309): rapor onayı kuyruğa ORU (emir 4) açar - NW yoksa önce NW; aynı rapor iki kez
/// girmez; Teletıp kapalıyken hiçbir şey olmaz. Eşleme (ORM verisi + rapor) ve rapora özgü denetim; servis uçtan uca
/// sahte Teletıp'a ORU gönderir. Tetik testleri transaction içinde; servis testi kendi satırlarını açar ve siler.
/// </summary>
// Testler ortak TeleRadyoloji test hesabını (TeletipTestHesabi) açıp kapatır ve kurum.skrs_kodu'nu geçici değiştirir:
//   paralel koşarsa biri ötekini bozar. Aynı koleksiyon = sırayla.
[Collection("TeletipReferans")]
public sealed class TeletipOruTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static async Task<(int Istem, int Rapor)> ZeminAsync(NpgsqlConnection b, NpgsqlTransaction? t, bool aktif)
    {
        if (t is not null)
            await TeletipTestHesabi.AyarlaAsync(b, t, aktif);
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var ek = Guid.NewGuid().ToString("N")[..8];
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, kod, hasta, vkno, sube_id) values ('TT ORU HASTA', 'Ali', 'Çelik', @p1, 1, '10000000146', @p0) returning id",
            t, [sube, "TO" + ek], Iptal);
        var hekim = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, hekim, vkno, sube_id) values ('Dr.', 'Ömer', 'Güneş', 1, '12345678950', @p0) returning id",
            t, [sube], Iptal);
        var radyolog = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, hekim, vkno, sube_id) values ('Dr.', 'Ali', 'Akman', 1, '78221082662', @p0) returning id",
            t, [sube], Iptal);
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sut_kodu, loinc, sube_id) values (@p0, 'Beyin BT', 1, 1, '804490', '24725-4', @p1) returning id",
            t, ["TO" + ek, sube], Iptal);
        var istem = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, istek_hekim_id, cekim_tarihi)
            values (@p0, @p1, @p2, 1, @p3, 3, @p4, now()) returning id
            """, t, [sube, hasta, hizmet, "TO-" + ek, hekim], Iptal);
        var rapor = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_rapor (istem_id, durum, kilit, yazan_id, onaylayan_id, istem_nedeni_puan, cekim_kalite_puan)
            values (@p0, 1, 0, @p1, @p1, 4, 5) returning id
            """, t, [istem, radyolog], Iptal);
        foreach (var (sira, parca, metin) in new[]
        {
            (1, 1, "Kontrastsız aksiyel kesitler."),
            (2, 3, "Beyin parankiminde akut patoloji izlenmedi; ventriküller ve sulkuslar yaşla uyumlu, orta hat normal."),
            (3, 4, "Normal beyin BT."),
        })
            await b.CalistirAsync("insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, bakanlik_parca) values (@p0, @p1, '', @p2, @p3)",
                t, [rapor, sira, metin, (short)parca], Iptal);
        return (istem, rapor);
    }

    private static Task<List<(short Emir, short Durum, int? Rapor)>> SatirlarAsync(NpgsqlConnection b, NpgsqlTransaction t, int istem) =>
        b.ListeAsync("select emir, durum, rapor_id from public.teletip_gonderim where istem_id = @p0 order by id", t, [istem],
            o => (o.GetInt16(0), o.GetInt16(1), o.IsDBNull(2) ? (int?)null : o.GetInt32(2)), Iptal);

    private static Task OnaylaAsync(NpgsqlConnection b, NpgsqlTransaction t, int rapor) =>
        b.CalistirAsync("update public.radyoloji_rapor set durum = 3, kilit = 1, onay_tarihi = now() where id = @p0", t, [rapor], Iptal);

    [VtFact]
    public async Task Onay_once_NW_sonra_ORU_bir_kez()
    {
        if (!olgu.Baglandi(nameof(Onay_once_NW_sonra_ORU_bir_kez))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var (istem, rapor) = await ZeminAsync(b, t, aktif: true);
        // Zemin istemi durum 3 ile açtı - NW tetikten zaten geldi; yoksa onay tetiği açar.
        await OnaylaAsync(b, t, rapor);
        var s = await SatirlarAsync(b, t, istem);
        Assert.Equal((short)1, s[0].Emir);
        Assert.Equal((short)4, s[^1].Emir);
        Assert.Equal(rapor, s[^1].Rapor);
        // Onay geri alınıp yeniden verilse bile bekleyen ORU varken yenisi açılmaz.
        await b.CalistirAsync("update public.radyoloji_rapor set durum = 2 where id = @p0", t, [rapor], Iptal);
        await OnaylaAsync(b, t, rapor);
        Assert.Single(await SatirlarAsync(b, t, istem), x => x.Emir == 4);
    }

    [VtFact]
    public async Task NW_hic_yoksa_onay_once_NW_acar()
    {
        if (!olgu.Baglandi(nameof(NW_hic_yoksa_onay_once_NW_acar))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var (istem, rapor) = await ZeminAsync(b, t, aktif: false);          // istem Teletıp kapalıyken açıldı: NW yok
        Assert.Empty(await SatirlarAsync(b, t, istem));
        await TeletipTestHesabi.AyarlaAsync(b, t, true);
        await OnaylaAsync(b, t, rapor);
        Assert.Equal([(short)1, (short)4], (await SatirlarAsync(b, t, istem)).Select(x => x.Emir));
    }

    [VtFact]
    public async Task Kapaliyken_onay_kuyruga_girmez()
    {
        if (!olgu.Baglandi(nameof(Kapaliyken_onay_kuyruga_girmez))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var (istem, rapor) = await ZeminAsync(b, t, aktif: false);
        await OnaylaAsync(b, t, rapor);
        Assert.Empty(await SatirlarAsync(b, t, istem));
    }

    [VtFact]
    public async Task Rapor_verisi_parcalar_ve_radyolog()
    {
        if (!olgu.Baglandi(nameof(Rapor_verisi_parcalar_ve_radyolog))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var (_, rapor) = await ZeminAsync(b, t, aktif: false);
        await OnaylaAsync(b, t, rapor);
        var json = await b.TekDegerAsync<string>("select public.fn_teletip_oru_verisi(@p0)::text", t, [rapor], Iptal);
        var r = System.Text.Json.JsonSerializer.Deserialize<TeletipRaporVerisi>(json!,
            new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true })!;
        Assert.Equal("Kontrastsız aksiyel kesitler.", r.Teknik);
        Assert.StartsWith("Beyin parankiminde", r.Bulgular);
        Assert.Equal("Normal beyin BT.", r.Sonuc);
        Assert.Equal("78221082662", r.RadyologTckn);
        Assert.Equal("AKMAN", r.RadyologSoyad);
        Assert.Equal((short)4, r.IstemNedeniPuan);
        Assert.NotNull(r.OnayZamani);
        Assert.Equal("", r.RaporEksik);
        Assert.False(r.Duzeltme);
    }

    // ------------------------------------------------------------------ saf: eşleme ve denetim
    private static OrmVerisi Orm() => new()
    {
        FirmaKodu = "GENTEGRE", HbysAdi = "TEST", HastaDosyaNo = "H1", HastaTckn = "10000000146", HastaSoyad = "ÇELİK", HastaAd = "ALİ",
        BasvuruReferansi = "15042", HastaneReferansi = "15042", AccessionNo = "R-1", IstemZamani = DateTime.Now, PlanlananZaman = DateTime.Now,
        IsteyenHekim = new("12345678950", "GÜNEŞ", "ÖMER"), KurumAdi = "Test Hst", KurumSkrs = "148", MedulaTesisKodu = "11740001",
        SutKodu = "804490", SutAdi = "Beyin BT", Loinc = [new("24725-4", "CT Head")], SysTakipNo = "SYS1", Modalite = "CT",
        Tanilar = [new("R51", "Baş ağrısı")],
    };
    private static TeletipRaporVerisi Rapor() => new()
    {
        Teknik = "T", Bulgular = new string('x', 60), Sonuc = "S", OnayZamani = DateTime.Now, IstemNedeniPuan = 4, CekimKalitePuan = 5,
        RadyologTckn = "78221082662", RadyologSoyad = "AKMAN", RadyologAd = "ALİ",
    };

    [Fact]
    public void Esleme_Bakanlik_ORU_alanlari()
    {
        var m = OruUretici.Uret(TeletipOruKurucu.Kur(Orm(), Rapor()));
        var orc = m.Split('\r').First(x => x.StartsWith("ORC|")).Split('|');
        Assert.Equal("SN", orc[1]);
        Assert.Equal("R-1^HBYS", orc[2]);
        Assert.Equal(@"Test Hst^^148\S\1\S\11740001", orc[21]);
        var obx = m.Split('\r').First(x => x.StartsWith("OBX|")).Split('|');
        Assert.Equal("4^5", obx[13]);
        Assert.Equal("78221082662^AKMAN^ALİ", obx[16]);
        Assert.Equal("F", obx[11]);
        Assert.Contains("DG1|1||R51^^I10", m);
        // Ek rapor: OBX-11 C.
        var ek = OruUretici.Uret(TeletipOruKurucu.Kur(Orm(), Rapor() with { Duzeltme = true }));
        Assert.Equal("C", ek.Split('\r').First(x => x.StartsWith("OBX|")).Split('|')[11]);
    }

    [Fact]
    public void Denetim_rapora_ozgu_eksikler()
    {
        Assert.Empty(TeletipOruKurucu.Denetle(Orm(), Rapor()));
        var e = TeletipOruKurucu.Denetle(Orm(), Rapor() with
        {
            RadyologTckn = "", IstemNedeniPuan = 0, OnayZamani = null, RaporEksik = "Bakanlık profili: \"Bulgular\" en az 50 karakter olmalı (şu an 10).",
        });
        Assert.Contains(e, x => x.Contains("OBX-16"));
        Assert.Contains(e, x => x.Contains("OBX-13"));
        Assert.Contains(e, x => x.Contains("OBR-7"));
        Assert.Contains(e, x => x.Contains("50 karakter"));
        // ORM'in ortak denetimi de çalışır (kurum alanı).
        Assert.Contains(TeletipOruKurucu.Denetle(Orm() with { MedulaTesisKodu = "" }, Rapor()), x => x.Contains("MEDULA"));
    }

    // ------------------------------------------------------------------ servis: uçtan uca sahte Teletıp
    private sealed class SahteTeletip : IDisposable
    {
        private readonly TcpListener _d = new(IPAddress.Loopback, 0);
        public string Alinan { get; private set; } = "";
        public int Port => ((IPEndPoint)_d.LocalEndpoint).Port;
        public SahteTeletip() { _d.Start(); _ = Dongu(); }
        private async Task Dongu()
        {
            using var c = await _d.AcceptTcpClientAsync();
            using var s = c.GetStream();
            var tampon = new byte[65536]; var b = new List<byte>();
            while (!(b.Count > 1 && b[^2] == 0x1C && b[^1] == 0x0D))
            {
                var n = await s.ReadAsync(tampon);
                if (n == 0) return;
                b.AddRange(tampon.AsSpan(0, n).ToArray());
            }
            Alinan = Encoding.UTF8.GetString(b.ToArray(), 1, b.Count - 3);
            var kontrol = Alinan.Split('\r')[0].Split('|')[9];
            var yanit = Encoding.UTF8.GetBytes($"MSH|^~\\&|TELERADYOLOJI|TELERADYOLOJI|GENTEGRE|X|20261111||ACK|1|P|2.3.1\rMSA|AA|{kontrol}\r");
            await s.WriteAsync((byte[])[0x0B, .. yanit, 0x1C, 0x0D]);
        }
        public void Dispose() => _d.Stop();
    }

    [VtFact]
    public async Task Servis_ORU_gonderir_AA()
    {
        if (!olgu.Baglandi(nameof(Servis_ORU_gonderir_AA))) return;
        var veri = olgu.Gerekli();
        using var sahte = new SahteTeletip();
        var eski = new Dictionary<string, string>();
        string[] anahtarlar = ["kurum.skrs_kodu"];
        int istem = 0, rapor = 0; long gonderim = 0; string eskiTesis = "";
        await using (var b = await veri.AcAsync())
        {
            foreach (var a in anahtarlar)
                eski[a] = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = @p0", null, [a], Iptal) ?? "";
            eskiTesis = await b.TekDegerAsync<string>("select coalesce(tesis_kodu, '') from public.kurum_profil where sube_id = 0", null, [], Iptal) ?? "";
            await TeletipTestHesabi.AyarlaAsync(b, null, true, $"127.0.0.1:{sahte.Port}");
            await b.CalistirAsync("update public.referans set deger = '148' where anahtar = 'kurum.skrs_kodu'", null, [], Iptal);
            await b.CalistirAsync("update public.kurum_profil set tesis_kodu = '11740001' where sube_id = 0", null, [], Iptal);
            (istem, rapor) = await ZeminAsync(b, null, aktif: false);
            await b.CalistirAsync("update public.radyoloji_rapor set durum = 3, kilit = 1, onay_tarihi = now() where id = @p0", null, [rapor], Iptal);
            gonderim = await b.TekDegerAsync<long>(
                "insert into public.teletip_gonderim (istem_id, accession_no, emir, durum, rapor_id) values (@p0, 'TO', 4, 0, @p1) returning id",
                null, [istem, rapor], Iptal);
        }
        try
        {
            var servis = new TeletipOrmServisi(veri, new MllpIstemci(NullLogger<MllpIstemci>.Instance), NullLogger<TeletipOrmServisi>.Instance);
            var s = await servis.DeneAsync(gonderim, Iptal);
            // Başvurusuz test isteminde e-Nabız referansı / SYS yok - denetim bunları ister. Burada beklenen: eksikse
            //   gönderilmez (3), değilse AA (1). Test zemini başvurusuz olduğundan 3 ve eksik listesinde yalnız e-Nabız
            //   kaynaklı maddeler kalmalı; rapor / radyolog / kurum maddeleri OLMAMALI.
            if (s.Durum == 3)
            {
                Assert.DoesNotContain("OBX-16", s.Hata);
                Assert.DoesNotContain("OBX-13", s.Hata);
                Assert.DoesNotContain("50 karakter", s.Hata);
                Assert.DoesNotContain("MEDULA", s.Hata);
                Assert.Contains("OBR-20", s.Hata);
            }
            else
            {
                Assert.Equal(1, s.Durum);
                Assert.Contains("ORU^R01", sahte.Alinan);
            }
        }
        finally
        {
            await using var b = await veri.AcAsync();
            // Kendi açtığımız kayıtlar (hasta, hekim, radyolog, hizmet dahil) - tablo boşaltılmaz, yalnız bu id'ler.
            var kimler = await b.TekAsync("""
                select i.hasta_id, i.istek_hekim_id, i.hizmet_id, r.onaylayan_id
                  from public.radyoloji_istem i join public.radyoloji_rapor r on r.istem_id = i.id where i.id = @p0 and r.id = @p1
                """, null, [istem, rapor], o => new[] { o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3) }, Iptal);
            await b.CalistirAsync("delete from public.teletip_gonderim where istem_id = @p0 or id = @p1", null, [istem, gonderim], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_rapor_bolum where rapor_id = @p0", null, [rapor], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_rapor where id = @p0", null, [rapor], Iptal);
            await b.CalistirAsync("delete from public.radyoloji_istem where id = @p0", null, [istem], Iptal);
            if (kimler is not null)
            {
                await b.CalistirAsync("delete from public.hizmet where id = @p0", null, [kimler[2]], Iptal);
                await b.CalistirAsync("delete from public.taraf where id = any(@p0)", null, [new[] { kimler[0], kimler[1], kimler[3] }], Iptal);
            }
            foreach (var (a, d) in eski)
                await b.CalistirAsync("update public.referans set deger = @p1 where anahtar = @p0", null, [a, d], Iptal);
            await b.CalistirAsync("update public.kurum_profil set tesis_kodu = @p0 where sube_id = 0", null, [eskiTesis], Iptal);
        }
    }
}
