using Gentegre.Cekirdek.Kimlik;

namespace Gentegre.Testler;

/// <summary>
/// MRZ ÇÖZÜCÜ (1255) - ICAO 9303 örnek belgeleri (Doc 9303 Part 5 TD1 / Part 4 TD3 "ERIKSSON ANNA MARIA" numuneleri,
/// kontrol haneleri standarttaki gibi) ve T.C. kimlik kartı düzeninde kurgulanmış bir örnek. Kontrol hanesi
/// tutmayan satır karta aktarılmaz; o yüzden hem tutan hem bozulan örnek sınanır.
/// </summary>
public sealed class MrzCozucuTestleri
{
    private static readonly DateOnly Bugun = new(2026, 11, 4);

    [Theory]
    [InlineData("D23145890", 7)]
    [InlineData("740812", 2)]
    [InlineData("120415", 9)]
    [InlineData("L898902C3", 6)]
    [InlineData("ZE184226B<<<<<", 1)]
    [InlineData("<<<<<<<<<<<<<<", 0)]
    public void Kontrol_hanesi_icao_ornekleri(string alan, int beklenen)
        => Assert.Equal(beklenen, MrzCozucu.KontrolHanesi(alan));

    [Fact]
    public void Td1_icao_numunesi_cozulur()
    {
        var s = MrzCozucu.Coz("""
            I<UTOD231458907<<<<<<<<<<<<<<<
            7408122F1204159UTO<<<<<<<<<<<6
            ERIKSSON<<ANNA<MARIA<<<<<<<<<<
            """, Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("TD1", s.Bicim);
        Assert.Equal("I", s.BelgeKodu);
        Assert.Equal("UTO", s.DuzenleyenUlke);
        Assert.Equal("D23145890", s.BelgeNo);
        Assert.Equal(new DateOnly(1974, 8, 12), s.DogumTarihi);
        Assert.Equal("K", s.Cinsiyet);
        Assert.Equal(new DateOnly(2012, 4, 15), s.SonKullanma);
        Assert.Equal("UTO", s.Uyruk);
        Assert.Equal("ERIKSSON", s.Soyad);
        Assert.Equal("ANNA MARIA", s.Ad);
        Assert.Equal("", s.KimlikNo);
        Assert.True(s.BilesikTamam);
    }

    [Fact]
    public void Tc_kimlik_karti_duzeni_kimlik_no_ile_cozulur()
    {
        // Satır 2 isteğe bağlı alanı T.C. kimlik no (NVİ algoritmasından geçen örnek numara).
        var s = MrzCozucu.Coz("""
            I<TURA12B345675<<<<<<<<<<<<<<<
            9001011M3012316TUR100000001462
            YILMAZ<<AHMET<<<<<<<<<<<<<<<<<
            """, Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("A12B34567", s.BelgeNo);
        Assert.Equal("10000000146", s.KimlikNo);
        Assert.Equal(new DateOnly(1990, 1, 1), s.DogumTarihi);
        Assert.Equal("E", s.Cinsiyet);
        Assert.Equal(new DateOnly(2030, 12, 31), s.SonKullanma);
        Assert.Equal("TUR", s.Uyruk);
        Assert.Equal("YILMAZ", s.Soyad);
        Assert.Equal("AHMET", s.Ad);
    }

    [Fact]
    public void Tc_kimlik_karti_gercek_duzen_kimlik_no_satir_1_istege_bagli_alanda()
    {
        // Gerçek T.C. kimlik kartı: belge no + kontrol + '<' + T.C. kimlik no satır 1'de; satır 2 isteğe bağlı alan boş.
        var s = MrzCozucu.Coz("""
            I<TURA10B305679<98765400166<<<
            9001011M3012316TUR<<<<<<<<<<<0
            YILMAZ<<AHMET<<<<<<<<<<<<<<<<<
            """, Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("A10B30567", s.BelgeNo);
        Assert.Equal("98765400166", s.KimlikNo);
    }

    [Fact]
    public void Ocr_bozulmasi_onarilir_dolgu_koşusu_O_0_ve_E_6()
    {
        // Gerçek kart denemesinden (04.11.2026) görülen bozulma deseni: dolgu '<' koşuları C/L/K, '0' 'O', '6' 'E',
        //   satırlar 32-33 karaktere uzamış, ad önüne 'C' sızmış.
        var s = MrzCozucu.Coz("""
            I<TURA1OB3O5679<987654OO166<<<
            9001011M3012316TURC<CLCC<C<<<<<<O
            YILMAZ<<CAHMETCCCLCLLLLLLLLLLLLK
            """, Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("A10B30567", s.BelgeNo);
        Assert.Equal("98765400166", s.KimlikNo);
        Assert.Equal(new DateOnly(1990, 1, 1), s.DogumTarihi);
        Assert.Equal("YILMAZ", s.Soyad);
        Assert.Equal("AHMET", s.Ad);
    }

    [Fact]
    public void Td3_pasaport_icao_numunesi_cozulur()
    {
        var s = MrzCozucu.Coz("""
            P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
            L898902C36UTO7408122F1204159ZE184226B<<<<<10
            """, Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("TD3", s.Bicim);
        Assert.Equal("P", s.BelgeKodu);
        Assert.Equal("L898902C3", s.BelgeNo);
        Assert.Equal("UTO", s.Uyruk);
        Assert.Equal(new DateOnly(1974, 8, 12), s.DogumTarihi);
        Assert.Equal("K", s.Cinsiyet);
        Assert.Equal(new DateOnly(2012, 4, 15), s.SonKullanma);
        Assert.Equal("ERIKSSON", s.Soyad);
        Assert.Equal("ANNA MARIA", s.Ad);
    }

    [Fact]
    public void Alman_pasaportu_D_ulke_kodu_DEU_olur_ve_bos_istege_bagli_alan_gecer()
    {
        var s = MrzCozucu.Coz("""
            P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<<<<<<<<<
            C01X00T478DEU6408125F2702227<<<<<<<<<<<<<<00
            """, Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("DEU", s.DuzenleyenUlke);
        Assert.Equal("DEU", s.Uyruk);
        Assert.Equal("Almanya Federal", MrzCozucu.UlkeAdi(s.Uyruk));
        Assert.Equal("C01X00T47", s.BelgeNo);
        Assert.Equal("MUSTERMANN", s.Soyad);
        Assert.Equal("ERIKA", s.Ad);
        Assert.Equal(new DateOnly(2027, 2, 22), s.SonKullanma);
    }

    [Fact]
    public void Bozuk_kontrol_hanesi_hata_verir_alan_yine_okunur()
    {
        // Doğum kontrol hanesi 2 yerine 3: bileşik de bozulur, belge no sağlam kalır.
        var s = MrzCozucu.Coz("""
            I<UTOD231458907<<<<<<<<<<<<<<<
            7408123F1204159UTO<<<<<<<<<<<6
            ERIKSSON<<ANNA<MARIA<<<<<<<<<<
            """, Bugun);
        Assert.NotNull(s);
        Assert.False(s.Gecerli);
        Assert.True(s.BelgeNoTamam);
        Assert.False(s.DogumTamam);
        Assert.False(s.BilesikTamam);
        Assert.Contains(s.Hatalar, h => h.Contains("Doğum tarihi"));
        Assert.Equal("ERIKSSON", s.Soyad);
    }

    [Fact]
    public void Yanlis_okunmus_tc_no_hata_sayilir()
    {
        var s = MrzCozucu.Coz("""
            I<TURA12B345675<<<<<<<<<<<<<<<
            9001011M3012316TUR100000001472
            YILMAZ<<AHMET<<<<<<<<<<<<<<<<<
            """, Bugun);
        Assert.NotNull(s);
        Assert.Equal("", s.KimlikNo);
        Assert.Contains(s.Hatalar, h => h.Contains("T.C. kimlik no"));
    }

    [Fact]
    public void Ocr_bosluklu_kucuk_harf_ve_kisa_dolgu_toparlanir()
    {
        // OCR satır sonundaki '<' dolgusunun bir kısmını düşürüp boşluk ve küçük harf üretebilir.
        var s = MrzCozucu.Coz("i<uto d231458907<<<<<<<<\n7408122F1204159UTO<<<<<<<<<<<6\nERIKSSON<<ANNA<MARIA<<<<", Bugun);
        Assert.NotNull(s);
        Assert.True(s.Gecerli, string.Join(" | ", s.Hatalar));
        Assert.Equal("ANNA MARIA", s.Ad);
    }

    [Theory]
    [InlineData("")]
    [InlineData("merhaba dünya")]
    [InlineData("I<UTOD231458907<<<<<<<<<<<<<<<")]            // tek satır
    public void Taninmayan_metin_null(string metin) => Assert.Null(MrzCozucu.Coz(metin, Bugun));
}
