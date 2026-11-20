using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// RAPOR GÖNDERİMİ - LABORATUVAR (1394; kullanıcı 20.11.2026): gönderim birimi başvurunun lab BÖLÜMÜ - bölümün testleri
/// tamamı onaylanınca planlanır, bölümler ayrı ayrı gider; düzeltmede bekleyen gönderim iptal, yeniden onayda aynı kod;
/// panik değerde tek süre (0 = elle); hasta sayfasında "bağlantıda gizle" testi çıkmaz (dış doktor görür) ve geçmiş iki
/// sonuç gelir. Her test kendi transaction'ında çalışır ve geri alınır.
/// </summary>
public sealed class RaporGonderimLabTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private sealed record Zemin(int Sube, int Hasta, int Hekim, int Belge, int Istem, int Glukoz, int Hiv, int Kultur,
                                int SatirGlukoz, int SatirHiv, int SatirKultur);

    private static async Task<int> TetkikAsync(NpgsqlConnection b, NpgsqlTransaction t, string ad, short bolum, int sube, short gizle = 0)
    {
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, sube_id) values (@p0, @p1, @p2) returning id",
            t, [$"RGL{Guid.NewGuid().ToString("N")[..8]}", ad, sube], Iptal);
        return await b.TekDegerAsync<int>("""
            insert into public.lab_tetkik (kod, ad, tur, birim, ondalik, bolum, durum, hizmet_id, baglantida_gizle)
            values (@p0, @p1, 1, 'mg/dL', 1, @p2, 1, @p3, @p4) returning id
            """, t, [$"RGL{Guid.NewGuid().ToString("N")[..8]}", ad, bolum, hizmet, gizle], Iptal);
    }

    private static async Task<int> SatirAsync(NpgsqlConnection b, NpgsqlTransaction t, int istem, int tetkik, string deger,
                                              string bayrak, short panik, short durum)
    {
        var satir = await b.TekDegerAsync<int>(
            "insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira) values (@p0, @p1, @p2, 10) returning id",
            t, [istem, tetkik, durum], Iptal);
        await b.CalistirAsync("""
            insert into public.lab_sonuc (istem_satir_id, tetkik_id, deger_metin, birim, bayrak, panik, durum, olcum_zamani,
                                          onay_zamani, referans_alt, referans_ust, sube_id)
            values (@p0, @p1, @p2, 'mg/dL', @p3, @p4, @p5, now(), now(), 70, 100, 0)
            """, t, [satir, tetkik, deger, bayrak, panik, (short)(durum == 5 ? 3 : 1)], Iptal);
        return satir;
    }

    private static async Task<Zemin> ZeminAsync(NpgsqlConnection b, NpgsqlTransaction t, short glukozPanik = 0)
    {
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id, cep_tel) values ('RGL TEST HASTA', @p1, 1, @p0, '05321112233') returning id",
            t, [sube, $"RGL{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var hekim = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, personel, sube_id, cep_tel) values ('RGL TEST DIS HEKIM', @p1, 1, @p0, @p2) returning id",
            t, [sube, $"RGL{Guid.NewGuid().ToString("N")[..8]}", $"0544{Random.Shared.Next(1000000, 9999999)}"], Iptal);
        await b.CalistirAsync("insert into public.taraf_personel (id, dis_hekim, rapor_bildirim, sube_id) values (@p0, 1, 1, @p1)", t, [hekim, sube], Iptal);
        var belge = await b.TekDegerAsync<int>(
            "insert into public.belge (tipi, tur, taraf_id, belge_tarihi, genel_toplam, sube_id) values (30, 19, @p0, now(), 0, @p1) returning id",
            t, [hasta, sube], Iptal);
        var istem = await b.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik, belge_id, personel_id, istem_tarihi)
            values (@p0, @p1, @p2, 1, 3, 3, 1, @p3, @p4, now()) returning id
            """, t, [hasta, sube, $"RGL-{Guid.NewGuid().ToString("N")[..8]}", belge, hekim], Iptal);
        var glukoz = await TetkikAsync(b, t, "RGL Glukoz", 1, sube);
        var hiv = await TetkikAsync(b, t, "RGL Gizli Test", 1, sube, gizle: 1);
        var kultur = await TetkikAsync(b, t, "RGL Kültür", 4, sube);
        return new Zemin(sube, hasta, hekim, belge, istem, glukoz, hiv, kultur,
            await SatirAsync(b, t, istem, glukoz, "126", glukozPanik == 1 ? "HH" : "H", glukozPanik, 5),
            await SatirAsync(b, t, istem, hiv, "Negatif", "N", 0, 5),
            await SatirAsync(b, t, istem, kultur, "", "", 0, 2));
    }

    private static Task AyarAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube, int labPanik)
        => b.CalistirAsync("""
            insert into public.radyoloji_rapor_gonderim_ayar (sube_id, otomatik, lab_panik_dakika, web_kok)
            values (@p0, 1, @p1, 'https://rapor.test')
            on conflict (sube_id) do update set otomatik = 1, lab_panik_dakika = excluded.lab_panik_dakika, web_kok = excluded.web_kok,
                   borc_kontrol = 1, hasta_sms = 1, hasta_eposta = 0;
            """, t, [sube, labPanik], Iptal);

    private static Task<List<IDictionary<string, object?>>> SatirlarAsync(NpgsqlConnection b, NpgsqlTransaction t, int belge)
        => b.ListeAsync("""
            select lab_bolum, alici_tur, kod, durum, planlanan, kural, kanal from public.radyoloji_rapor_gonderim
             where kaynak = 2 and belge_id = @p0 order by lab_bolum, alici_tur
            """, t, [belge], OkuyucuGenisletmeleri.Sozluk, Iptal);

    [VtFact]
    public async Task Bolum_tamamlaninca_planlanir_bolumler_ayri_duzeltmede_iptal_kod_korunur()
    {
        if (!_olgu.Baglandi(nameof(Bolum_tamamlaninca_planlanir_bolumler_ayri_duzeltmede_iptal_kod_korunur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var z = await ZeminAsync(b, t);
        await AyarAsync(b, t, z.Sube, 0);
        await b.CalistirAsync("delete from public.radyoloji_rapor_gonderim_kural where sube_id = @p0", t, [z.Sube], Iptal);
        await b.CalistirAsync("insert into public.radyoloji_rapor_gonderim_kural (sube_id, kapsam, zaman_tur, saat) values (@p0, 0, 1, 2)", t, [z.Sube], Iptal);
        var simdi = new DateTime(2026, 11, 20, 9, 0, 0, DateTimeKind.Utc);

        // Biyokimya (2 test) tamamı onaylı → planlanır; Mikrobiyoloji çalışılıyor → planlanmaz.
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi);
        var s = await SatirlarAsync(b, t, z.Belge);
        Assert.Equal(2, s.Count);                                                 // hasta + gönderen dış doktor (SMS ister)
        Assert.All(s, x => Assert.Equal(1, Convert.ToInt32(x["lab_bolum"])));
        Assert.Equal(1, Convert.ToInt32(s[0]["durum"]));
        Assert.Equal(simdi.AddHours(2), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());
        var kod = s[0]["kod"]!.ToString();

        // Yeniden çağrı (her sonuç yazımında olur) planı YENİLEMEZ.
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi.AddHours(1));
        Assert.Equal(simdi.AddHours(2), ((DateTime)(await SatirlarAsync(b, t, z.Belge))[0]["planlanan"]!).ToUniversalTime());

        // Mikrobiyoloji onaylandı → AYRI satır (ayrı bildirim).
        await b.CalistirAsync("update public.lab_istem_satir set durum = 5 where id = @p0", t, [z.SatirKultur], Iptal);
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi.AddDays(3));
        s = await SatirlarAsync(b, t, z.Belge);
        Assert.Equal([1, 1, 4, 4], s.Select(x => Convert.ToInt32(x["lab_bolum"])).ToArray());
        Assert.NotEqual(kod, s[2]["kod"]!.ToString());

        // DÜZELTME: biyokimyada bir sonuç yeniden onay bekliyor → o bölümün gönderimi iptal; mikrobiyoloji etkilenmez.
        await b.CalistirAsync("update public.lab_istem_satir set durum = 3 where id = @p0", t, [z.SatirGlukoz], Iptal);
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi.AddDays(3));
        s = await SatirlarAsync(b, t, z.Belge);
        Assert.Equal([9, 9, 1, 1], s.Select(x => Convert.ToInt32(x["durum"])).ToArray());

        // Yeniden onay: aynı bağlantı kodu, yeniden planlanır.
        await b.CalistirAsync("update public.lab_istem_satir set durum = 5 where id = @p0", t, [z.SatirGlukoz], Iptal);
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi.AddDays(4));
        s = await SatirlarAsync(b, t, z.Belge);
        Assert.Equal(kod, s[0]["kod"]!.ToString());
        Assert.Equal(1, Convert.ToInt32(s[0]["durum"]));
        Assert.Equal(simdi.AddDays(4).AddHours(2), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());

        // TEK TESLİM LİSTESİ (1396): başvurunun iki bölümü iki lab satırı; kimlik -(başvuru*100 + bölüm); elden teslimle kapanır.
        var liste = await b.ListeAsync("""
            select satir_id, lab_bolum, takip_durum, tetkik, gizli_test, hasta_kod from public.v_radyoloji_teslim_takip
             where kaynak = 2 and belge_id = @p0 order by lab_bolum
            """, t, [z.Belge], OkuyucuGenisletmeleri.Sozluk, Iptal);
        Assert.Equal(2, liste.Count);
        Assert.Equal(-((long)z.Belge * 100 + 1), Convert.ToInt64(liste[0]["satir_id"]));
        Assert.Equal("Biyokimya · 2 test", liste[0]["tetkik"]!.ToString());
        Assert.Equal(1, Convert.ToInt32(liste[0]["gizli_test"]));
        Assert.Equal(kod, liste[0]["hasta_kod"]!.ToString());
        Assert.All(liste, x => Assert.Equal(1, Convert.ToInt32(x["takip_durum"])));
        await b.CalistirAsync("update public.lab_istem_satir set durum = 3 where id = @p0", t, [z.SatirKultur], Iptal);
        await b.CalistirAsync("insert into public.lab_sonuc_teslim (belge_id, bolum, tur, alan_ad, dijital) values (@p0, 1, 1, 'Kendisi', 0)", t, [z.Belge], Iptal);
        liste = await b.ListeAsync("""
            select takip_durum from public.v_radyoloji_teslim_takip where kaynak = 2 and belge_id = @p0 order by lab_bolum
            """, t, [z.Belge], OkuyucuGenisletmeleri.Sozluk, Iptal);
        Assert.Equal([2, 0], liste.Select(x => Convert.ToInt32(x["takip_durum"])).ToArray());   // teslim edildi · onay bekliyor

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Panik_degerde_tek_sure_sifir_elle()
    {
        if (!_olgu.Baglandi(nameof(Panik_degerde_tek_sure_sifir_elle))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var z = await ZeminAsync(b, t, glukozPanik: 1);
        var simdi = new DateTime(2026, 11, 20, 9, 0, 0, DateTimeKind.Utc);

        await AyarAsync(b, t, z.Sube, 0);                                         // 0: otomatik gitmez
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi);
        var s = await SatirlarAsync(b, t, z.Belge);
        Assert.Equal(0, Convert.ToInt32(s[0]["durum"]));
        Assert.Null(s[0]["planlanan"]);
        Assert.Contains("Panik", s[0]["kural"]!.ToString());

        await RaporGonderimi.IptalAsync(b, t, 0, 0, Iptal);                        // radyoloji iptali lab satırına dokunmaz
        await b.CalistirAsync("update public.radyoloji_rapor_gonderim set durum = 9 where kaynak = 2 and belge_id = @p0", t, [z.Belge], Iptal);
        await AyarAsync(b, t, z.Sube, 7);                                         // 7 dk
        await RaporGonderimi.LabPlanlaAsync(b, t, z.Istem, Iptal, simdi);
        s = await SatirlarAsync(b, t, z.Belge);
        Assert.Equal(simdi.AddMinutes(7), ((DateTime)s[0]["planlanan"]!).ToUniversalTime());

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Hasta_sayfasi_gizli_test_ve_gecmis_iki_sonuc()
    {
        if (!_olgu.Baglandi(nameof(Hasta_sayfasi_gizli_test_ve_gecmis_iki_sonuc))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var z = await ZeminAsync(b, t);
        // Üç eski başvuru: yalnız son İKİSİ geçmiş kolonlarına girer.
        foreach (var (gun, deger) in new[] { (30, "118"), (90, "104"), (200, "99") })
        {
            var eski = await b.TekDegerAsync<int>("""
                insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik, istem_tarihi)
                values (@p0, @p1, @p2, 1, 5, 3, 1, now() - make_interval(days => @p3)) returning id
                """, t, [z.Hasta, z.Sube, $"RGL-{Guid.NewGuid().ToString("N")[..8]}", gun], Iptal);
            await SatirAsync(b, t, eski, z.Glukoz, deger, "H", 0, 5);
        }

        JsonElement Veri(object o) => JsonSerializer.SerializeToElement(o);
        var hasta = Veri(await RaporGonderimi.LabRaporVerisiAsync(b, z.Belge, 1, hekim: false, Iptal));
        Assert.Equal("Biyokimya", hasta.GetProperty("bolumAd").GetString());
        Assert.Equal(1, hasta.GetProperty("gizlenen").GetInt32());               // gizli test hastaya çıkmaz
        var satirlar = hasta.GetProperty("satirlar").EnumerateArray().ToList();
        Assert.Single(satirlar);
        Assert.Equal("RGL Glukoz", satirlar[0].GetProperty("ad").GetString());
        Assert.Equal("70 – 100", satirlar[0].GetProperty("referans").GetString());
        Assert.Equal(2, hasta.GetProperty("gecmisGunler").GetArrayLength());
        Assert.Equal("118", satirlar[0].GetProperty("onceki1").GetProperty("deger").GetString());
        Assert.Equal("104", satirlar[0].GetProperty("onceki2").GetProperty("deger").GetString());
        // Kimlik no maskeli; kültür (başka bölüm) bu sayfada yok.
        Assert.DoesNotContain("RGL Kültür", hasta.GetRawText());

        var hekim = Veri(await RaporGonderimi.LabRaporVerisiAsync(b, z.Belge, 1, hekim: true, Iptal));
        Assert.Equal(0, hekim.GetProperty("gizlenen").GetInt32());               // gönderen dış doktor görür
        Assert.Equal(2, hekim.GetProperty("satirlar").GetArrayLength());

        await t.RollbackAsync();
    }
}
