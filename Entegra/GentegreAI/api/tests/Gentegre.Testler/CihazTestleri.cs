using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Testler;

/// <summary>
/// CİHAZ SÜRÜCÜLERİ (432) — protokol çözümlemesi.
///
/// Sürücü I/O yapmadığı için ağ ve veritabanı olmadan test edilebiliyor;
/// buradaki hatalar sahada "sonuç geldi ama boş" ya da "değer yanlış teste
/// yazıldı" olarak görünür - ikisi de hasta sonucudur.
/// </summary>
public class CihazTestleri
{
    // Gercek bir biyokimya analizorunun urettigi bicimde ORU^R01.
    private const string Hl7 =
        "MSH|^~\\&|COBAS|LAB1|GENTEGRE|AI|20260906143000||ORU^R01|MSG0001|P|2.5\r" +
        "PID|1||1234567890^^^HASTANE^MR||YILMAZ^AYSE||19850101|F\r" +
        "OBR|1|IST-77|ORN-4521|CBC^Tam Kan^L|||20260906142000\r" +
        "OBX|1|NM|WBC^Lökosit^L||7.8|10*3/uL|4.0-10.0|N|||F|||20260906142500\r" +
        "OBX|2|NM|HGB^Hemoglobin^L||10.2|g/dL|12.0-16.0|L|||F|||20260906142500\r" +
        "OBX|3|ST|CRP^C-Reaktif Protein^L||<0.01|mg/L||N|||F\r";

    [Fact]
    public void Hl7_sonuc_mesaji_cozumlenir()
    {
        var m = new Hl7Surucu().Coz(Hl7);

        Assert.True(m.Gecerli, m.Hata);
        Assert.Equal("ORU^R01", m.MesajTipi);
        Assert.Equal("MSG0001", m.KontrolNo);
        Assert.Equal("IST-77", m.IstemNo);
        Assert.Equal("ORN-4521", m.OrnekNo);
        Assert.Equal("1234567890", m.HastaNo);
        Assert.Equal(new DateTime(2026, 9, 6, 14, 30, 0), m.CihazZamani);
        Assert.Equal(3, m.Kalemler.Count);
    }

    [Fact]
    public void Hl7_kalem_alanlari_dogru_yere_duser()
    {
        var m = new Hl7Surucu().Coz(Hl7);
        var hgb = m.Kalemler[1];

        Assert.Equal("HGB", hgb.TestKodu);
        Assert.Equal("Hemoglobin", hgb.TestAdi);
        Assert.Equal("10.2", hgb.Deger);
        Assert.Equal(10.2m, hgb.Sayisal);
        Assert.Equal("g/dL", hgb.Birim);
        Assert.Equal("12.0-16.0", hgb.Referans);
        Assert.Equal("L", hgb.Isaret);          // düşük
        Assert.Equal("F", hgb.Durum);           // final
        Assert.Equal(new DateTime(2026, 9, 6, 14, 25, 0), hgb.OlcumZamani);
    }

    [Fact]
    public void Esik_degeri_METIN_kalir_sayiya_zorlanmaz()
    {
        // "<0.01" sayı DEĞİLDİR: sayıya çevirmeye çalışmak ya 0 yazar
        //   (yanlış sonuç) ya da satırı düşürür (kayıp sonuç).
        var crp = new Hl7Surucu().Coz(Hl7).Kalemler[2];
        Assert.Equal("<0.01", crp.Deger);
        Assert.Null(crp.Sayisal);
    }

    [Fact]
    public void Ayiricilar_MSH_den_okunur_sabit_degil()
    {
        // Ayırıcı olarak '|' yerine '#', bileşen olarak '^' yerine '@'.
        var ozel =
            "MSH#@~\\&#CIHAZ#LAB#GENTEGRE#AI#20260906143000##ORU@R01#X1#P#2.5\r" +
            "OBX#1#NM#GLU@Glukoz##95#mg/dL#70-105#N###F\r";
        var m = new Hl7Surucu().Coz(ozel);

        Assert.True(m.Gecerli, m.Hata);
        Assert.Equal("X1", m.KontrolNo);
        Assert.Single(m.Kalemler);
        Assert.Equal("GLU", m.Kalemler[0].TestKodu);
        Assert.Equal("Glukoz", m.Kalemler[0].TestAdi);
        Assert.Equal(95m, m.Kalemler[0].Sayisal);
    }

    [Fact]
    public void Segment_SIRASI_degil_ADI_okunur()
    {
        // Araya NTE ve SPM giriyor; "üçüncü satır OBR'dir" varsayımı kırılırdı.
        var karisik =
            "MSH|^~\\&|C|L|G|A|20260906143000||ORU^R01|K9|P|2.5\r" +
            "NTE|1||Cihaz notu\r" +
            "PID|1||999^^^H^MR||TEST^HASTA\r" +
            "SPM|1|ORN-9|||||||||||||20260906\r" +
            "OBX|1|NM|NA^Sodyum||140|mmol/L|136-145|N|||F\r";
        var m = new Hl7Surucu().Coz(karisik);

        Assert.True(m.Gecerli, m.Hata);
        Assert.Equal("ORN-9", m.OrnekNo);
        Assert.Equal("999", m.HastaNo);
        Assert.Single(m.Kalemler);
    }

    [Fact]
    public void Hl7_olmayan_metin_HATA_doner_kayit_dusmez()
    {
        var m = new Hl7Surucu().Coz("bu bir HL7 mesaji degil");
        Assert.False(m.Gecerli);
        Assert.Contains("MSH", m.Hata);
    }

    [Fact]
    public void Astm_sonuc_kayitlari_cozumlenir()
    {
        var astm =
            "H|\\^&|||OTOREF^1.0|||||||P|1|20260906143000\r" +
            "P|1||555||YILMAZ^AYSE\r" +
            "O|1|ORN-12|IST-5|^^^SPH|||20260906142000\r" +
            "R|1|^^^SPH_R|-1.25|D||N||F||||20260906142500\r" +
            "R|2|^^^CYL_R|-0.50|D||N||F||||20260906142500\r" +
            "L|1|N\r";
        var m = new AstmSurucu().Coz(astm);

        Assert.True(m.Gecerli, m.Hata);
        Assert.Equal("ORN-12", m.OrnekNo);
        Assert.Equal("IST-5", m.IstemNo);
        Assert.Equal("555", m.HastaNo);
        Assert.Equal(2, m.Kalemler.Count);
        Assert.Equal("SPH_R", m.Kalemler[0].TestKodu);
        Assert.Equal(-1.25m, m.Kalemler[0].Sayisal);
        Assert.Equal("D", m.Kalemler[0].Birim);
        // ASTM'de mesaj kimliği yok: örnek no + zaman tekillik anahtarı olur.
        Assert.StartsWith("ORN-12-", m.KontrolNo);
    }

    [Fact]
    public void Zaman_kisa_bicimleri_de_okunur()
    {
        Assert.Equal(new DateTime(2026, 9, 6), CihazCevrim.Zaman("20260906"));
        Assert.Equal(new DateTime(2026, 9, 6, 14, 30, 0), CihazCevrim.Zaman("202609061430"));
        // Saat dilimi eki yok sayılır - cihaz yerel saatiyle konuşur.
        Assert.Equal(new DateTime(2026, 9, 6, 14, 30, 0),
                     CihazCevrim.Zaman("20260906143000+0300"));
        Assert.Null(CihazCevrim.Zaman(""));
    }

    [Fact]
    public void Sayi_virgullu_ondaligi_okur_esigi_okumaz()
    {
        Assert.Equal(1.25m, CihazCevrim.Sayi("1,25"));
        Assert.Equal(1.25m, CihazCevrim.Sayi("1.25"));
        Assert.Null(CihazCevrim.Sayi("<0.01"));
        Assert.Null(CihazCevrim.Sayi("POZİTİF"));
    }
}
