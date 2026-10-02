using Gentegre.Cekirdek.Cihaz;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// GRAFİK TİPLİ SONUÇ (892 — KTS denetim maddesi L10).
///
/// İki yol test edilir: cihazın gönderdiği HL7 mesajının ÇÖZÜMLENMESİ
/// (veritabanı gerektirmez) ve grafiğin sonuca bağlanıp raporda görünmesi.
///
/// Elektroforezde asıl bulgu eğrinin biçimidir; sayıyı alıp eğriyi atmak,
/// sonucun yarısını kaybetmektir.
/// </summary>
public class GrafikSonucTestleri
{
    // Gömülü PNG (ED) + sayı dizisi (NA) taşıyan gerçekçi ORU.
    //   OBX-5 ED biçimi: kaynak^tip^altTip^kodlama^veri
    private const string Hl7 =
        "MSH|^~\\&|CAPILLARYS|LAB1|GENTEGRE|AI|20260920101500||ORU^R01|MSG-GRF|P|2.5\r" +
        "PID|1||1234567890^^^HASTANE^MR||YILMAZ^AYSE||19850101|F\r" +
        "OBR|1|IST-90|ORN-9001|SPE^Protein Elektroforezi^L|||20260920101000\r" +
        "OBX|1|NM|ALB^Albümin^L||58.2|%|55.8-66.1|N|||F|||20260920101200\r" +
        "OBX|2|ED|SPEGRF^Elektroforez eğrisi^L||^image^PNG^Base64^aGVsbG8=|||||F\r" +
        "OBX|3|NA|SPESERI^Eğri noktaları^L||12.5^13.1^18.9^40.2^22.0|%||||F\r";

    [Fact]
    public void Gomulu_goruntu_ve_sayi_dizisi_COZUMLENIR()
    {
        var m = new Hl7Surucu().Coz(Hl7);

        Assert.True(m.Gecerli, m.Hata);
        Assert.Equal(3, m.Kalemler.Count);

        // NM kalemi eskisi gibi: sayısal değer yerinde.
        Assert.Equal("NM", m.Kalemler[0].DegerTipi);
        Assert.Equal(58.2m, m.Kalemler[0].Sayisal);

        // ED: base64 çözülür, MIME tipi kurulur. HAM BASE64 `Deger` alanında
        //   TUTULMAZ - varchar(200)'e sığmaz ve okunacak bir şey değildir.
        var ed = m.Kalemler[1];
        Assert.Equal("ED", ed.DegerTipi);
        Assert.Equal("image/png", ed.GomuluTip);
        Assert.Equal("hello", System.Text.Encoding.UTF8.GetString(ed.Gomulu!));
        Assert.DoesNotContain("aGVsbG8", ed.Deger, StringComparison.Ordinal);
        Assert.Null(ed.Sayisal);

        // NA: noktalar dizi olarak gelir; görüntüye çevrilmez.
        var na = m.Kalemler[2];
        Assert.Equal("NA", na.DegerTipi);
        Assert.Equal(5, na.Seri!.Count);
        Assert.Equal(40.2m, na.Seri[3]);
        Assert.Null(na.Sayisal);
    }

    [Fact]
    public void Bozuk_base64_MESAJI_DUSURMEZ()
    {
        // Tek bir kalem yüzünden bütün mesajın düşmesi, gelen SAYISAL
        //   sonuçları da kaybettirirdi - kalem metne düşer, mesaj geçerli.
        var bozuk = Hl7.Replace("aGVsbG8=", "bu-base64-degil!!");
        var m = new Hl7Surucu().Coz(bozuk);

        Assert.True(m.Gecerli, m.Hata);
        Assert.Equal(3, m.Kalemler.Count);
        Assert.Null(m.Kalemler[1].Gomulu);
        Assert.Equal(58.2m, m.Kalemler[0].Sayisal);
    }

    [Fact]
    public void Base64_olmayan_kodlama_GOMULU_SAYILMAZ()
    {
        // "A" (ASCII) kodlaması metin sonuçtur; ikili içerik değildir.
        var metin = Hl7.Replace("^image^PNG^Base64^aGVsbG8=", "^text^PLAIN^A^Normal patern");
        var m = new Hl7Surucu().Coz(metin);

        Assert.Null(m.Kalemler[1].Gomulu);
        Assert.Equal("ED", m.Kalemler[1].DegerTipi);
    }
}

/// <summary>
/// GRAFİK KAYDI VE RAPOR SÜZGECİ (892) — veritabanı gerektirir.
/// </summary>
public sealed class GrafikKaydiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Bos_grafik_KABUL_EDILMEZ_ve_raporda_bayragi_suzer()
    {
        if (!_olgu.Baglandi(nameof(Bos_grafik_KABUL_EDILMEZ_ve_raporda_bayragi_suzer))) return;
        var veri = _olgu.Gerekli();

        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU' limit 1", null,
            CancellationToken.None);
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-GRF-' || floor(random() * 1000000)::text, 1, 2, 3, 1)
            returning id
            """, [hastaId], CancellationToken.None);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 3, 10) returning id
            """, [istemId, tetkikId], CancellationToken.None);
        try
        {
            // BOŞ GRAFİK OLMAZ: ne görüntü ne seri - kayıt reddedilir.
            var h = await Assert.ThrowsAsync<Npgsql.PostgresException>(() =>
                veri.CalistirAsync("""
                    insert into public.lab_sonuc_grafik (istem_satir_id, tur, baslik)
                    values (@p0, 1, 'boş')
                    """, [satirId], CancellationToken.None));
            Assert.Contains("ck_lab_grafik_icerik", h.Message, StringComparison.Ordinal);

            // Seri ile kayıt: biri raporda, biri değil.
            await veri.CalistirAsync("""
                insert into public.lab_sonuc_grafik
                       (istem_satir_id, tur, baslik, seri, kaynak, raporda)
                values (@p0, 1, 'Elektroforez', '{"y":[1,2,3]}'::jsonb, 1, 1),
                       (@p0, 4, 'Kalibrasyon', '{"y":[4,5,6]}'::jsonb, 1, 0)
                """, [satirId], CancellationToken.None);

            Assert.Equal(2, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.v_lab_sonuc_grafik where satir_id = @p0
                """, [satirId], CancellationToken.None));

            // RAPOR YALNIZ `raporda = 1` OLANI BASAR: ham kalibrasyon eğrisi
            //   laboratuvarın iç kaydıdır, hastanın raporuna girmez.
            Assert.Equal(1, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.v_lab_sonuc_grafik
                 where satir_id = @p0 and raporda = 1
                """, [satirId], CancellationToken.None));

            // Seri jsonb olarak DURUYOR: görüntüye çevrilseydi ölçek
            //   sonsuza kadar donardı.
            Assert.Equal("{\"y\": [1, 2, 3]}", await veri.TekDegerAsync<string>("""
                select seri::text from public.v_lab_sonuc_grafik
                 where satir_id = @p0 and raporda = 1
                """, [satirId], CancellationToken.None));
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.lab_sonuc_grafik where istem_satir_id = @p0", [satirId],
                CancellationToken.None);
            await veri.CalistirAsync("delete from public.lab_istem_satir where id = @p0",
                                     [satirId], CancellationToken.None);
            await veri.CalistirAsync("delete from public.lab_istem where id = @p0",
                                     [istemId], CancellationToken.None);
        }
    }
}
