using Gentegre.Api.Servisler;
using Gentegre.Api.Uclar;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELERADYOLOJİ ŞUBE HESABI (1317-1318): kurum kimliği şube → kurum geneli → eski yer; gönderim hesabı şube satırı →
/// kurum geneli (canlı önce, pasif sayılmaz); hesap modelinde şubenin hesabı yoksa kuyruğa satır AÇILMAZ; hesap modeli
/// yokken eski teletip.* ayarları (geri uyum); MEDULA / e-Nabız okuyucuları profil boşsa eski yere düşer.
/// Hepsi tek işlemde, sonunda geri alınır.
/// </summary>
[Collection("TeletipReferans")]
public sealed class TeleradyolojiHesapTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static readonly CancellationToken Iptal = CancellationToken.None;

    [Fact]
    public void Adres_host_port()
    {
        // Kanal sınaması MllpIstemci.AdresCoz'u kullanır (HL7 host:port ve HTTP kanal adresi).
        Assert.Equal(("10.0.0.12", 6661), MllpIstemci.AdresCoz("10.0.0.12:6661"));
        Assert.Equal(("10.1.0.12", 8082), MllpIstemci.AdresCoz("http://10.1.0.12:8082/kos/"));
        Assert.Equal(("teletip.saglik.gov.tr", 443), MllpIstemci.AdresCoz("https://teletip.saglik.gov.tr/x"));
        Assert.Equal(("", 0), MllpIstemci.AdresCoz(""));
        Assert.Equal(("", 0), MllpIstemci.AdresCoz("sadece-ad"));
    }

    private static async Task<long> HesapAsync(NpgsqlConnection b, NpgsqlTransaction t, int? sube, short aktif, short test, string hl7) =>
        await b.TekDegerAsync<long>("""
            insert into public.entegrasyon_hesap (kod, ad, sube_id, test_mi, aktif, uygulama_kodu, url, ayarlar)
            values ('TELERADYOLOJI', 'TT TR', @p0, @p2, @p1, 'FIRMA', @p3, '{"subeNo":"7","xdsAdres":"http://x:8082/kos/"}'::jsonb) returning id
            """, t, [sube, aktif, test, hl7], Iptal);

    [VtFact]
    public async Task Sube_hesabi_kimligi_ve_kuyruk_kapisi()
    {
        if (!olgu.Baglandi(nameof(Sube_hesabi_kimligi_ve_kuyruk_kapisi))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        // Temiz zemin: bu işlemde başka TELERADYOLOJI satırı görünmesin.
        await b.CalistirAsync("update public.entegrasyon_hesap set kod = 'TELERADYOLOJI_X' where kod = 'TELERADYOLOJI'", t, [], Iptal);
        // 1321: kimliğin ANA kaynağı e-Nabız hesabı - önce yokken (kurum profili yedeği), sonra varken denenir.
        await b.CalistirAsync("update public.entegrasyon_hesap set kod = 'ENABIZ_X' where kod = 'ENABIZ'", t, [], Iptal);
        var subeler = await b.ListeAsync("select id from public.sube where aktif = 1 order by id limit 2", t, [], o => o.GetInt32(0), Iptal);
        Assert.True(subeler.Count >= 1);
        int s1 = subeler[0], s2 = subeler.Count > 1 ? subeler[1] : 0;

        // --- kimlik: şube satırı → kurum geneli
        await b.CalistirAsync("""
            insert into public.kurum_profil (sube_id, urun_modu, kurum_tipi, skrs_kodu, tesis_kodu, bakanlik_ad)
            values (0, 2, 'muayenehane', '147', '34100001', 'Kurum Geneli Ad')
            on conflict (sube_id) do update set skrs_kodu = '147', tesis_kodu = '34100001', bakanlik_ad = 'Kurum Geneli Ad'
            """, t, [], Iptal);
        await b.CalistirAsync("""
            insert into public.kurum_profil (sube_id, urun_modu, kurum_tipi, skrs_kodu, tesis_kodu, bakanlik_ad)
            values (@p0, 2, 'muayenehane', '148', '34123456', 'Şube Ad')
            on conflict (sube_id) do update set skrs_kodu = '148', tesis_kodu = '34123456', bakanlik_ad = 'Şube Ad'
            """, t, [s1], Iptal);
        var k1 = await b.TekAsync("select ad, skrs, tesis from public.fn_kurum_kimlik(@p0)", t, [s1], o => new[] { o.GetString(0), o.GetString(1), o.GetString(2) }, Iptal);
        Assert.Equal(new[] { "Şube Ad", "148", "34123456" }, k1);
        var k0 = await b.TekAsync("select ad, skrs, tesis from public.fn_kurum_kimlik(0)", t, [], o => new[] { o.GetString(0), o.GetString(1), o.GetString(2) }, Iptal);
        Assert.Equal(new[] { "Kurum Geneli Ad", "147", "34100001" }, k0);
        Assert.Equal("148", await b.TekDegerAsync<string>("select public.fn_kurum_skrs(@p0)", t, [s1], Iptal));
        Assert.Equal("34123456", await b.TekDegerAsync<string>("select public.fn_kurum_tesis(@p0)", t, [s1], Iptal));
        Assert.Equal("kurum profili (şube)", await b.TekDegerAsync<string>("select kaynak from public.fn_kurum_kimlik(@p0)", t, [s1], Iptal));

        // e-Nabız hesabı (kurum geneli) ANA kaynak: profili ezer; şubenin kendi e-Nabız satırı kurum genelini ezer.
        await b.CalistirAsync("""
            insert into public.entegrasyon_hesap (kod, ad, sube_id, test_mi, aktif, kurum_kodu, ayarlar)
            values ('ENABIZ', 'TT ENABIZ', null, 0, 1, '500154', '{"medulaTesisKodu":"11068891","bakanlikAd":"Enabiz Ad"}'::jsonb)
            """, t, [], Iptal);
        // 1323: şubenin KENDİ profili kurum geneli e-Nabız'ı ezer (sıra: şube e-Nabız → şube profili → kurum geneli e-Nabız).
        var ke = await b.TekAsync("select ad, skrs, tesis, kaynak, sube_enabiz_id from public.fn_kurum_kimlik(@p0)", t, [s1],
            o => new[] { o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3), o.IsDBNull(4) ? "" : o.GetInt32(4).ToString() }, Iptal);
        Assert.Equal(new[] { "Şube Ad", "148", "34123456", "kurum profili (şube)", "" }, ke);
        // Kurum geneli (şube 0) e-Nabız'dan.
        var k0e = await b.TekAsync("select ad, skrs, tesis, kaynak from public.fn_kurum_kimlik(0)", t, [],
            o => new[] { o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3) }, Iptal);
        Assert.Equal(new[] { "Enabiz Ad", "500154", "11068891", "e-Nabız (kurum geneli)" }, k0e);
        await b.CalistirAsync("""
            insert into public.entegrasyon_hesap (kod, ad, sube_id, test_mi, aktif, kurum_kodu, ayarlar)
            values ('ENABIZ', 'TT ENABIZ şube', @p0, 0, 1, '500155', '{}'::jsonb)
            """, t, [s1], Iptal);
        var ks = await b.TekAsync("select skrs, tesis, kaynak, sube_enabiz_id is not null from public.fn_kurum_kimlik(@p0)", t, [s1],
            o => new[] { o.GetString(0), o.GetString(1), o.GetString(2), o.GetBoolean(3).ToString() }, Iptal);
        Assert.Equal(new[] { "500155", "34123456", "e-Nabız (şube)", "True" }, ks);      // tesis şube e-Nabız'da yok → şube profili

        // --- hesap modeli yok: eski ayarlar (teletip.aktif) - geri uyum
        Assert.False(await b.TekDegerAsync<bool>("select public.fn_teletip_hesap_modeli()", t, [], Iptal));
        await b.CalistirAsync("update public.referans set deger = '1' where anahtar = 'teletip.aktif'", t, [], Iptal);
        Assert.Equal("Teletıp Ayarları (eski)", await b.TekDegerAsync<string>("select public.fn_teletip_hesap_ayar(@p0) ->> 'HesapAd'", t, [s1], Iptal));

        // --- hesap modeli: kurum geneli pasif + şube s1 canlı + s1 beta
        var genel = await HesapAsync(b, t, null, 0, 0, "10.0.0.1:6661");
        var canli = await HesapAsync(b, t, s1, 1, 0, "10.1.0.1:6661");
        await HesapAsync(b, t, s1, 1, 1, "10.1.0.9:6661");
        Assert.Equal(canli, await b.TekDegerAsync<long>("select public.fn_teletip_hesap(@p0)", t, [s1], Iptal));            // canlı önce
        Assert.Equal("7", await b.TekDegerAsync<string>("select public.fn_teletip_hesap_ayar(@p0) ->> 'SubeNo'", t, [s1], Iptal));
        Assert.True(await b.TekDegerAsync<bool>("select public.fn_teletip_aktif()", t, [], Iptal));
        if (s2 > 0)
        {
            Assert.Null(await b.TekDegerAsync<int?>("select public.fn_teletip_hesap(@p0)", t, [s2], Iptal));              // genel pasif
            // Kuyruk kapısı: hesabı olmayan şubenin satırı açılmaz; hesabı olanınki açılır.
            var acilmadi = await b.TekDegerAsync<long?>(
                "insert into public.teletip_gonderim (kanal, emir, durum, accession_no, sube_id) values (1, 1, 0, 'TT-KAPI', @p0) returning id", t, [s2], Iptal);
            Assert.Null(acilmadi);
            await b.CalistirAsync("update public.entegrasyon_hesap set aktif = 1 where id = @p0", t, [genel], Iptal);
            Assert.Equal(genel, await b.TekDegerAsync<long>("select public.fn_teletip_hesap(@p0)", t, [s2], Iptal));      // kurum geneline düşer
        }
        var acildi = await b.TekDegerAsync<long?>(
            "insert into public.teletip_gonderim (kanal, emir, durum, accession_no, sube_id) values (1, 1, 0, 'TT-KAPI', @p0) returning id", t, [s1], Iptal);
        Assert.NotNull(acildi);
        await t.RollbackAsync();
    }
}
