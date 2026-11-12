using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Testler;

/// <summary>
/// ORM^O01 ÜRETİCİSİ (Teletıp istem mesajı; kılavuz 3.43 § 3.1.3): alan konumları kılavuz tablolarıyla birebir, kaçış,
/// NW / XO / CA farkı, yabancı hasta ve gönderim öncesi denetim.
/// </summary>
public sealed class OrmUreticiTestleri
{
    private static OrmVerisi Ornek(OrmEmri emir = OrmEmri.Yeni) => new()
    {
        Emir = emir, FirmaKodu = "GENTEGRE", HbysAdi = "KOŞUYOLU GÖRÜNTÜLEME", KontrolNo = "MSG000000001",
        Zaman = new DateTime(2026, 11, 11, 9, 27, 4),
        HastaDosyaNo = "H-000084", HastaTckn = "78221082662", HastaSoyad = "DEMİR", HastaAd = "MEHMET",
        DogumTarihi = new DateTime(1962, 3, 4), Cinsiyet = "M", Adres = "A Mah.\nB Cad. No: 8", EvTelefonu = "02121234567", Eposta = "m@x.com",
        HastaSinifi = "O", BirimId = "12", BirimAdi = "Radyoloji", BasvuruReferansi = "ENB-77812", Sgk = true, MedulaTakipNo = "MT123",
        KabulZamani = new DateTime(2026, 11, 11, 9, 20, 0),
        AccessionNo = "R-000027", IstemZamani = new DateTime(2026, 11, 11, 9, 0, 0), PlanlananZaman = new DateTime(2026, 11, 11, 9, 30, 0),
        Giren = new("15", "KAYA", "AYŞE"), IsteyenHekim = new("12345678950", "GÜNEŞ", "ÖMER", "", "Uz.Dr."),
        KurumAdi = "Koşuyolu Görüntüleme Merkezi", KurumKisaAdi = "KOŞUYOLU", KurumSkrs = "148", SubeNo = "1", MedulaTesisKodu = "11740001",
        SutKodu = "801720", SutAdi = "Akciğer grafisi PA", Loinc = [new("36572-6", "XR Chest PA")],
        KlinikBilgi = "Öksürük\r\n2 hafta", SysTakipNo = "SYS-7A3F", HastaneReferansi = "ENB-77812", Modalite = "CR",
        Tanilar = [new("R05", "Öksürük", "A"), new("J18.9", "Pnömoni", "F")],
        Sikayet = "Öksürük | ateş", Gecmis = "Sigara\nkullanıyor",
    };

    private static string[] Seg(string mesaj, string ad) =>
        mesaj.Split('\r', StringSplitOptions.RemoveEmptyEntries).First(s => s.StartsWith(ad + "|")).Split('|');

    private static string[] SegHepsi(string mesaj, string ad) =>
        mesaj.Split('\r', StringSplitOptions.RemoveEmptyEntries).Where(s => s.StartsWith(ad + "|")).ToArray();

    [Fact]
    public void Yeni_istem_segment_duzeni_ve_MSH()
    {
        var m = OrmUretici.Uret(Ornek());
        var adlar = m.Split('\r', StringSplitOptions.RemoveEmptyEntries).Select(s => s[..3]).ToArray();
        Assert.Equal(["MSH", "PID", "PV1", "ORC", "OBR", "DG1", "DG1", "NTE", "NTE", "NTE", "NTE"], adlar);
        // 1330: Bakanlık HL7 doğrulayıcısı MSH-5/6 "TELETIP" ister (kullanıcı "doğrulayıcıya uyalım").
        Assert.StartsWith(@"MSH|^~\&|GENTEGRE|KOŞUYOLU GÖRÜNTÜLEME|TELETIP|TELETIP|20261111092704||ORM^O01|MSG000000001|P|2.3.1|", m);
        Assert.EndsWith("|UTF8", m.Split('\r')[0]);
        // MSH-18 = 18. alan: "MSH" + 17 ayraçtan sonra (MSH-1 ayracın kendisi).
        Assert.Equal("UTF8", Seg(m, "MSH")[17]);
    }

    [Fact]
    public void Dogrulayici_zorunlulari_PV1_50_ve_ORC_18_hic_bos_kalmaz()
    {
        // 1330: doğrulayıcı PV1-50'yi ve ORC-18'i her mesajda dolu ister.
        var ozel = OrmUretici.Uret(Ornek() with { Sgk = false, MedulaTakipNo = "", CihazGirisi = "" });
        Assert.Equal("0", Seg(ozel, "PV1")[50]);                 // takip no yok: "0"
        Assert.Equal("CR", Seg(ozel, "ORC")[18]);                // cihaz yok: modalite
        var cihazli = OrmUretici.Uret(Ornek() with { Sgk = false, MedulaTakipNo = "T9X", CihazGirisi = "TR-ANJ|01^A" });
        Assert.Equal("T9X", Seg(cihazli, "PV1")[50]);            // SGK dışında da varsa yazılır
        Assert.Equal("TR-ANJ01A", Seg(cihazli, "ORC")[18]);      // ayraçlar ayıklanır
    }

    [Fact]
    public void PID_PV1_kilavuz_bicimleri()
    {
        var m = OrmUretici.Uret(Ornek());
        var pid = Seg(m, "PID");
        Assert.Equal("148-H-000084", pid[2]);
        Assert.Equal("H-000084^^HBYS", pid[3]);
        Assert.Equal("78221082662^^^TC", pid[4]);
        Assert.Equal("DEMİR^MEHMET", pid[5]);
        Assert.Equal("19620304", pid[7]);
        Assert.Equal("A Mah. B Cad. No: 8", pid[11]);          // tek satır
        Assert.Equal("02121234567^^^m@x.com", pid[13]);
        var pv1 = Seg(m, "PV1");
        Assert.Equal("O", pv1[2]);
        Assert.Equal("ENB-77812^^^^^^^^12&Radyoloji&HBYS", pv1[19]);
        Assert.Equal("SGK", pv1[20]);
        Assert.Equal("20261111092000", pv1[44]);
        Assert.Equal("MT123", pv1[50]);
        Assert.Equal("V", pv1[51]);
    }

    [Fact]
    public void ORC_OBR_kilavuz_bicimleri()
    {
        var m = OrmUretici.Uret(Ornek());
        var orc = Seg(m, "ORC");
        Assert.Equal("NW", orc[1]);
        Assert.Equal("R-000027^HBYS", orc[2]);
        Assert.Equal("SC", orc[5]);
        Assert.Equal("1^once^^20261111093000", orc[7]);
        Assert.Equal("15^KAYA^AYŞE", orc[10]);
        Assert.Equal("12345678950^GÜNEŞ^ÖMER^^^Uz.Dr.", orc[12]);
        Assert.Equal("12^Radyoloji^KOŞUYOLU", orc[17]);
        Assert.Equal(@"Koşuyolu Görüntüleme Merkezi^^148\S\1\S\11740001", orc[21]);
        var obr = Seg(m, "OBR");
        Assert.Equal("R-000027^HBYS", obr[2]);
        Assert.Equal("R-000027^RBS", obr[3]);
        Assert.Equal("801720^Akciğer grafisi PA^SUT^36572-6^XR Chest PA^LNC", obr[4]);
        Assert.Equal("20261111090000", obr[6]);
        Assert.Equal("Öksürük 2 hafta", obr[13]);
        Assert.Equal("Radiology^^^^^R", obr[15]);
        Assert.Equal("12345678950^GÜNEŞ^ÖMER^^^Uz.Dr.", obr[16]);
        Assert.Equal("R-000027", obr[18]);
        Assert.Equal("SYS-7A3F", obr[20]);
        Assert.Equal("ENB-77812", obr[21]);
        Assert.Equal("CR", obr[24]);
        Assert.Equal("1^once^^20261111093000", obr[27]);
        Assert.Equal("20261111093000", obr[36]);
    }

    [Fact]
    public void DG1_ve_NTE()
    {
        var m = OrmUretici.Uret(Ornek());
        var dg = SegHepsi(m, "DG1");
        Assert.Equal("DG1|1||R05^Öksürük^I10|||A", dg[0]);
        Assert.Equal("DG1|2||J18.9^Pnömoni^I10|||F", dg[1]);
        var nte = SegHepsi(m, "NTE");
        Assert.Equal(@"NTE|1|P|Öksürük \F\ ateş|NTE0001^PatientComplaints^TELETIP", nte[0]);   // '|' kaçırıldı
        Assert.Equal("NTE|2|P|Sigara kullanıyor|NTE0002^PatientHistory^TELETIP", nte[1]);    // tek satır
        Assert.Equal("NTE|3|P||NTE0003^PatientSymptom^TELETIP", nte[2]);                     // boş da yazılır
        Assert.Equal("NTE|4|P||NTE0004^PatientCure^TELETIP", nte[3]);
    }

    [Fact]
    public void Guncelleme_XO_onaylayan_ve_NTE_yok()
    {
        var m = OrmUretici.Uret(Ornek(OrmEmri.Guncelle) with { Onaylayan = new("9", "X", "Y") });
        var orc = Seg(m, "ORC");
        Assert.Equal("XO", orc[1]);
        Assert.Equal("SC", orc[5]);
        Assert.True(orc.Length <= 11 || orc[11] == "");
        Assert.Contains(m.Split('\r'), s => s.StartsWith("OBR|"));
        Assert.DoesNotContain(m.Split('\r'), s => s.StartsWith("NTE|"));
    }

    [Fact]
    public void Iptal_CA_yalniz_MSH_PID_PV1_ORC()
    {
        var m = OrmUretici.Uret(Ornek(OrmEmri.Iptal));
        var adlar = m.Split('\r', StringSplitOptions.RemoveEmptyEntries).Select(s => s[..3]).ToArray();
        Assert.Equal(["MSH", "PID", "PV1", "ORC"], adlar);
        var orc = Seg(m, "ORC");
        Assert.Equal("CA", orc[1]);
        Assert.Equal("CA", orc[5]);
        Assert.Equal(@"Koşuyolu Görüntüleme Merkezi^^148\S\1\S\11740001", orc[21]);
    }

    [Fact]
    public void Yabanci_hasta_pasaport_ve_ulke_kodu()
    {
        var m = OrmUretici.Uret(Ornek() with { HastaTckn = "", PasaportNo = "P123456", UlkeKodu = "9893" });
        var pid = Seg(m, "PID");
        Assert.Equal("P123456^^^PASS", pid[4]);
        Assert.Equal("9893", pid[26]);
        Assert.Empty(OrmUretici.Denetle(Ornek() with { HastaTckn = "", PasaportNo = "P123456", UlkeKodu = "9893" }));
        Assert.Contains(OrmUretici.Denetle(Ornek() with { HastaTckn = "", PasaportNo = "P123456" }), x => x.Contains("PID-26"));
    }

    [Fact]
    public void Kacis_alan_icindeki_ayraclar()
    {
        var m = OrmUretici.Uret(Ornek() with { HastaSoyad = "A^B", KurumAdi = "X|Y" });
        Assert.Equal(@"A\S\B^MEHMET", Seg(m, "PID")[5]);
        Assert.StartsWith(@"X\F\Y^^148\S\1", Seg(m, "ORC")[21]);
    }

    [Fact]
    public void LOINC_yoksa_OBR4_yalniz_SUT_ve_denetim_uyarir()
    {
        var v = Ornek() with { Loinc = [] };
        Assert.Equal("801720^Akciğer grafisi PA^SUT", OrmUretici.Obr4(v));
        Assert.Contains(OrmUretici.Denetle(v), x => x.Contains("LOINC"));
        var cok = Ornek() with { Loinc = [new("1", "a"), new("2", "b")] };
        Assert.Equal("801720^Akciğer grafisi PA^SUT^1^a^LNC^2^b^LNC", OrmUretici.Obr4(cok));
    }

    [Fact]
    public void Denetim_eksiksiz_ornekte_bos()
    {
        Assert.Empty(OrmUretici.Denetle(Ornek()));
    }

    [Theory]
    [InlineData("AccessionNo", "Accession")]
    [InlineData("BasvuruReferansi", "PV1-19")]
    [InlineData("SysTakipNo", "OBR-20")]
    [InlineData("KurumSkrs", "ORC-21")]
    [InlineData("FirmaKodu", "MSH-3")]
    public void Denetim_bos_alani_yakalar(string alan, string beklenen)
    {
        var v = alan switch
        {
            "AccessionNo" => Ornek() with { AccessionNo = "" },
            "BasvuruReferansi" => Ornek() with { BasvuruReferansi = "" },
            "SysTakipNo" => Ornek() with { SysTakipNo = "" },
            "KurumSkrs" => Ornek() with { KurumSkrs = "" },
            _ => Ornek() with { FirmaKodu = "" },
        };
        Assert.Contains(OrmUretici.Denetle(v), x => x.Contains(beklenen));
    }

    [Fact]
    public void Denetim_hekim_TCKN_SUT_modalite_hasta_TCKN()
    {
        var e = OrmUretici.Denetle(Ornek() with
        {
            IsteyenHekim = new("12345678901", "A", "B"), SutKodu = "80.17", Modalite = "C", HastaTckn = "12345678901",
        });
        Assert.Contains(e, x => x.Contains("ORC-12"));
        Assert.Contains(e, x => x.Contains("0008"));
        Assert.Contains(e, x => x.Contains("0003"));
        Assert.Contains(e, x => x.Contains("PID-4"));
    }

    [Theory]
    [InlineData("", "MEDULA tesis kodu yok")]
    [InlineData("1174", "8 haneli")]
    [InlineData("1174000A", "8 haneli")]
    public void Denetim_MEDULA_tesis_kodu(string tesis, string beklenen)
    {
        Assert.Contains(OrmUretici.Denetle(Ornek() with { MedulaTesisKodu = tesis }), x => x.Contains(beklenen));
        // İptal mesajında da ORC-21 var: orada da aranır.
        Assert.Contains(OrmUretici.Denetle(Ornek(OrmEmri.Iptal) with { MedulaTesisKodu = tesis }), x => x.Contains(beklenen));
    }

    [Fact]
    public void Iptal_denetimi_yalniz_kimlik_alanlari()
    {
        var v = Ornek(OrmEmri.Iptal) with { SysTakipNo = "", Loinc = [], BasvuruReferansi = "" };
        Assert.Empty(OrmUretici.Denetle(v));
    }

    [Theory]
    [InlineData("10000000146", true)]
    [InlineData("78221082662", true)]
    [InlineData("12345678901", false)]
    [InlineData("01234567890", false)]
    [InlineData("1234", false)]
    public void TCKN_algoritmasi(string t, bool beklenen) => Assert.Equal(beklenen, OrmUretici.TcknGecerli(t));
}
