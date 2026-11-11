using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELETIP ORM KUYRUĞU (1302): radyoloji_istem tetiği hangi olayda hangi emri (NW / XO / CA) kuyruğa alır, mesaj
/// verisi C# OrmVerisi'ne birebir okunur mu, gönderim servisi ACK'e göre durumu doğru yazar mı.
/// Tetik testleri transaction içinde (geri alınır); servis testi kendi satırlarını açar ve siler.
/// </summary>
// Servis testleri ortak referans ayarlarını (teletip.hl7_adres / firma_kodu) geçici değiştirir: paralel koşarsa biri
//   ötekinin geçici değerini "eski" sanıp geri yazar. Aynı koleksiyon = sırayla.
[Collection("TeletipReferans")]
public sealed class TeletipOrmKuyruguTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static async Task<int> IstemAsync(NpgsqlConnection b, NpgsqlTransaction t, string accession, bool aktif = true,
                                              bool accessionBekliyor = false)
    {
        await b.CalistirAsync("update public.referans set deger = @p0 where anahtar = 'teletip.aktif'", t, [aktif ? "1" : "0"], Iptal);
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, kod, hasta, vkno, sube_id) values ('TT HASTA', 'Ali', 'Çelik', @p1, 1, '10000000146', @p0) returning id",
            t, [sube, "TT" + Guid.NewGuid().ToString("N")[..8]], Iptal);
        var hekim = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, hekim, vkno, sube_id) values ('Dr.', 'Ömer', 'Güneş', 1, '12345678950', @p0) returning id",
            t, [sube], Iptal);
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sut_kodu, loinc, sube_id) values (@p0, 'Beyin BT', 1, 1, '804490', '24725-4', @p1) returning id",
            t, ["TT" + Guid.NewGuid().ToString("N")[..8], sube], Iptal);
        return await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, istek_hekim_id, on_tani,
                                                accession_bekliyor)
            values (@p0, @p1, @p2, 1, @p3, 1, @p4, 'R51 Baş ağrısı', @p5) returning id
            """, t, [sube, hasta, hizmet, accession, hekim, (short)(accessionBekliyor ? 1 : 0)], Iptal);
    }

    private static Task<List<(short Emir, short Durum, string Acc, bool Veri)>> SatirlarAsync(NpgsqlConnection b, NpgsqlTransaction t, int istem) =>
        b.ListeAsync("select emir, durum, accession_no, veri is not null from public.teletip_gonderim where istem_id = @p0 order by id",
            t, [istem], o => (o.GetInt16(0), o.GetInt16(1), o.GetString(2), o.GetBoolean(3)), Iptal);

    private static string Acc() => "TT-" + Guid.NewGuid().ToString("N")[..10];

    [VtFact]
    public async Task Kapaliyken_kuyruga_bir_sey_girmez()
    {
        if (!olgu.Baglandi(nameof(Kapaliyken_kuyruga_bir_sey_girmez))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var istem = await IstemAsync(b, t, Acc(), aktif: false);
        Assert.Empty(await SatirlarAsync(b, t, istem));
    }

    [VtFact]
    public async Task Hazir_istem_bir_kez_NW_accessionsiz_istem_beklemez()
    {
        if (!olgu.Baglandi(nameof(Hazir_istem_bir_kez_NW_accessionsiz_istem_beklemez))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        // Sevkli istem: accession gönderen kurumdan bekleniyor - hazır değil.
        var istem = await IstemAsync(b, t, "", accessionBekliyor: true);
        Assert.Empty(await SatirlarAsync(b, t, istem));
        await b.CalistirAsync("update public.radyoloji_istem set accession_no = @p1, accession_bekliyor = 0 where id = @p0", t, [istem, Acc()], Iptal);
        var s = await SatirlarAsync(b, t, istem);
        Assert.Single(s);
        Assert.Equal((short)1, s[0].Emir);
        // NW gönderilmeden yapılan değişiklik XO açmaz (NW gönderim anında güncel veriden kurulur).
        await b.CalistirAsync("update public.radyoloji_istem set klinik_bilgi = 'değişti' where id = @p0", t, [istem], Iptal);
        Assert.Single(await SatirlarAsync(b, t, istem));
    }

    [VtFact]
    public async Task NW_gittikten_sonra_degisiklik_tek_XO()
    {
        if (!olgu.Baglandi(nameof(NW_gittikten_sonra_degisiklik_tek_XO))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var istem = await IstemAsync(b, t, Acc());
        await b.CalistirAsync("update public.teletip_gonderim set durum = 1 where istem_id = @p0", t, [istem], Iptal);
        await b.CalistirAsync("update public.radyoloji_istem set klinik_bilgi = 'bir' where id = @p0", t, [istem], Iptal);
        await b.CalistirAsync("update public.radyoloji_istem set klinik_bilgi = 'iki' where id = @p0", t, [istem], Iptal);
        await b.CalistirAsync("update public.radyoloji_istem set aciklama = 'ilgisiz' where id = @p0", t, [istem], Iptal);   // mesajda yok
        var s = await SatirlarAsync(b, t, istem);
        Assert.Equal([(short)1, (short)2], s.Select(x => x.Emir));
    }

    [VtFact]
    public async Task Iptal_gonderilmisse_CA_anlik_goruntuyle_gonderilmemisse_atlanir()
    {
        if (!olgu.Baglandi(nameof(Iptal_gonderilmisse_CA_anlik_goruntuyle_gonderilmemisse_atlanir))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var gitmis = await IstemAsync(b, t, Acc());
        await b.CalistirAsync("update public.teletip_gonderim set durum = 1 where istem_id = @p0", t, [gitmis], Iptal);
        await b.CalistirAsync("update public.radyoloji_istem set durum = 0 where id = @p0", t, [gitmis], Iptal);
        var s1 = await SatirlarAsync(b, t, gitmis);
        Assert.Equal((short)3, s1[^1].Emir);
        Assert.True(s1[^1].Veri);

        var gitmemis = await IstemAsync(b, t, Acc());
        await b.CalistirAsync("update public.radyoloji_istem set durum = 0 where id = @p0", t, [gitmemis], Iptal);
        var s2 = await SatirlarAsync(b, t, gitmemis);
        Assert.Single(s2);
        Assert.Equal((short)4, s2[0].Durum);                            // NW atlandı, CA yok
    }

    [VtFact]
    public async Task Silinen_istem_icin_CA_kalir()
    {
        if (!olgu.Baglandi(nameof(Silinen_istem_icin_CA_kalir))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var acc = Acc();
        var istem = await IstemAsync(b, t, acc);
        await b.CalistirAsync("update public.teletip_gonderim set durum = 1 where istem_id = @p0", t, [istem], Iptal);
        await b.CalistirAsync("delete from public.radyoloji_istem where id = @p0", t, [istem], Iptal);
        var ca = await b.TekAsync("select istem_id, veri->>'AccessionNo' as acc from public.teletip_gonderim where accession_no = @p0 and emir = 3",
            t, [acc], o => new { IstemId = o.SayiNull("istem_id"), Acc = o.Metin("acc") }, Iptal);
        Assert.NotNull(ca);
        Assert.Null(ca!.IstemId);                                         // istem gitti, iz kaldı
        Assert.Equal(acc, ca.Acc);
    }

    [VtFact]
    public async Task Accession_degisirse_eskiye_CA_yeniye_NW()
    {
        if (!olgu.Baglandi(nameof(Accession_degisirse_eskiye_CA_yeniye_NW))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var eski = Acc();
        var yeni = Acc();
        var istem = await IstemAsync(b, t, eski);
        await b.CalistirAsync("update public.teletip_gonderim set durum = 1 where istem_id = @p0", t, [istem], Iptal);
        await b.CalistirAsync("update public.radyoloji_istem set accession_no = @p1 where id = @p0", t, [istem, yeni], Iptal);
        var s = await SatirlarAsync(b, t, istem);
        Assert.Equal((short)3, s[1].Emir);
        Assert.Equal(eski, s[1].Acc);
        Assert.Equal((short)1, s[2].Emir);
        Assert.Equal(yeni, s[2].Acc);
    }

    // KOS (1310): PACS çalışması bağlanınca (study_uid boştan doluya) kanal 2 satırı; aynı değer tekrar yazılınca yeni
    //   satır yok; değişince (bekleyen varken) yine tek bekleyen. Kapalıyken hiçbir şey.
    [VtFact]
    public async Task Calisma_baglaninca_KOS_kuyruga()
    {
        if (!olgu.Baglandi(nameof(Calisma_baglaninca_KOS_kuyruga))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var istem = await IstemAsync(b, t, Acc());
        async Task<int> Kos() => (int)await b.TekDegerAsync<long>(
            "select count(*) from public.teletip_gonderim where istem_id = @p0 and kanal = 2", t, [istem], Iptal);
        Assert.Equal(0, await Kos());
        await b.CalistirAsync("update public.radyoloji_istem set study_uid = '1.2.3.4.5' where id = @p0", t, [istem], Iptal);
        Assert.Equal(1, await Kos());
        await b.CalistirAsync("update public.radyoloji_istem set study_uid = '1.2.3.4.5' where id = @p0", t, [istem], Iptal);
        await b.CalistirAsync("update public.radyoloji_istem set study_uid = '1.2.3.4.6' where id = @p0", t, [istem], Iptal);
        Assert.Equal(1, await Kos());                                   // bekleyen KOS varken yenisi açılmaz
        var kos = await b.TekDegerAsync<string>("select public.fn_teletip_kos_verisi(@p0)::text", t, [istem], Iptal);
        Assert.Contains("1.2.3.4.6", kos);

        var kapali = await IstemAsync(b, t, Acc(), aktif: false);
        await b.CalistirAsync("update public.radyoloji_istem set study_uid = '1.2.3.4.7' where id = @p0", t, [kapali], Iptal);
        Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.teletip_gonderim where istem_id = @p0", t, [kapali], Iptal));
    }

    [VtFact]
    public async Task Veri_fonksiyonu_OrmVerisi_ne_okunur()
    {
        if (!olgu.Baglandi(nameof(Veri_fonksiyonu_OrmVerisi_ne_okunur))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var acc = Acc();
        var istem = await IstemAsync(b, t, acc);
        var json = await b.TekDegerAsync<string>("select public.fn_teletip_orm_verisi(@p0)::text", t, [istem], Iptal);
        var v = JsonSerializer.Deserialize<OrmVerisi>(json!, new JsonSerializerOptions { PropertyNameCaseInsensitive = true })!;
        Assert.Equal(acc, v.AccessionNo);
        Assert.Equal("10000000146", v.HastaTckn);
        Assert.Equal("ÇELİK", v.HastaSoyad);
        Assert.Equal("12345678950", v.IsteyenHekim.Kimlik);
        Assert.Equal("GÜNEŞ", v.IsteyenHekim.Soyad);
        Assert.Equal("804490", v.SutKodu);
        Assert.Equal("24725-4", Assert.Single(v.Loinc).Kod);
        Assert.Equal("CT", v.Modalite);
        Assert.Equal("R51", Assert.Single(v.Tanilar).Icd);
        Assert.NotNull(v.PlanlananZaman);
        // Başvurusuz istemde e-Nabız referansı yok: denetim bunu yakalar (gidemez).
        Assert.Contains(OrmUretici.Denetle(v with { FirmaKodu = "X", KurumSkrs = "148" }), x => x.Contains("PV1-19"));
    }

    // ------------------------------------------------------------------ servis
    private sealed class SahteTeletip : IDisposable
    {
        private readonly TcpListener _d = new(IPAddress.Loopback, 0);
        public string Alinan { get; private set; } = "";
        public int Port => ((IPEndPoint)_d.LocalEndpoint).Port;
        public SahteTeletip(string ack) { _d.Start(); _ = Dongu(ack); }
        private async Task Dongu(string ack)
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
            var yanit = Encoding.UTF8.GetBytes($"MSH|^~\\&|TELERADYOLOJI|TELERADYOLOJI|GENTEGRE|X|20261111||ACK|1|P|2.3.1\rMSA|{ack}|{kontrol}|{(ack == "AA" ? "" : "0278: PV1-19 bos")}\r");
            await s.WriteAsync((byte[])[0x0B, .. yanit, 0x1C, 0x0D]);
        }
        public void Dispose() => _d.Stop();
    }

    [VtTheory]
    [InlineData("AA", 1)]
    [InlineData("AE", 2)]
    public async Task Servis_ACKe_gore_durum_yazar(string ack, short beklenen)
    {
        if (!olgu.Baglandi(nameof(Servis_ACKe_gore_durum_yazar))) return;
        var veri = olgu.Gerekli();
        using var sahte = new SahteTeletip(ack);
        var anlik = JsonSerializer.Serialize(new OrmVerisi
        {
            HastaDosyaNo = "H1", HastaTckn = "10000000146", HastaSoyad = "ÇELİK", HastaAd = "ALİ", BasvuruReferansi = "ENB1",
            AccessionNo = Acc(), IstemZamani = DateTime.Now, PlanlananZaman = DateTime.Now, KurumSkrs = "148", KurumAdi = "Test",
            MedulaTesisKodu = "11740001",
            IsteyenHekim = new("12345678950", "GÜNEŞ", "ÖMER"), SutKodu = "804490", SutAdi = "Beyin BT", Loinc = [new("24725-4", "CT Head")],
            SysTakipNo = "SYS1", HastaneReferansi = "ENB1", Modalite = "CT",
        });
        long id = 0;
        string eskiAdres = "", eskiFirma = "";
        await using (var b = await veri.AcAsync())
        {
            eskiAdres = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = 'teletip.hl7_adres'", null, [], Iptal) ?? "";
            eskiFirma = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = 'teletip.firma_kodu'", null, [], Iptal) ?? "";
            await b.CalistirAsync("update public.referans set deger = @p0 where anahtar = 'teletip.hl7_adres'", null, [$"127.0.0.1:{sahte.Port}"], Iptal);
            await b.CalistirAsync("update public.referans set deger = 'GENTEGRE' where anahtar = 'teletip.firma_kodu'", null, [], Iptal);
            id = await b.TekDegerAsync<long>(
                "insert into public.teletip_gonderim (istem_id, accession_no, emir, durum, veri) values (null, 'TT', 3, 0, @p0::jsonb) returning id",
                null, [anlik], Iptal);
        }
        try
        {
            var servis = new TeletipOrmServisi(veri, new MllpIstemci(NullLogger<MllpIstemci>.Instance), NullLogger<TeletipOrmServisi>.Instance);
            var s = await servis.DeneAsync(id, Iptal);
            Assert.Equal(beklenen, s.Durum);
            Assert.StartsWith("MSH|^~\\&|GENTEGRE|", sahte.Alinan);
            Assert.Contains("ORC|CA|", sahte.Alinan);
            await using var b = await veri.AcAsync();
            var (durum, ackKodu, mesaj) = (await b.TekAsync("select durum, ack_kodu, mesaj from public.teletip_gonderim where id = @p0", null, [id],
                o => Tuple.Create(o.GetInt16(0), o.GetString(1), o.GetString(2)), Iptal))!;
            Assert.Equal(beklenen, durum);
            Assert.Equal(ack, ackKodu);
            Assert.Contains("ORM^O01", mesaj);
        }
        finally
        {
            await using var b = await veri.AcAsync();
            await b.CalistirAsync("delete from public.teletip_gonderim where id = @p0", null, [id], Iptal);
            await b.CalistirAsync("update public.referans set deger = @p0 where anahtar = 'teletip.hl7_adres'", null, [eskiAdres], Iptal);
            await b.CalistirAsync("update public.referans set deger = @p0 where anahtar = 'teletip.firma_kodu'", null, [eskiFirma], Iptal);
        }
    }

    [Fact]
    public void Geri_cekilme_artar() =>
        Assert.True(TeletipOrmServisi.Geri(1) < TeletipOrmServisi.Geri(3) && TeletipOrmServisi.Geri(3) < TeletipOrmServisi.Geri(9));
}
