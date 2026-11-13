namespace Gentegre.Testler;

/// <summary>
/// TEK A4 ŞABLON → BAKANLIK DÖRT PARÇASI (1332, kullanıcı 13.11.2026: "bakanlığın istediği 4 parça esas olmalı").
/// SQL `fn_rad_sablon_bol` web'deki "Başlıklardan böl" (web/src/sayfalar/radyoloji/sablonBolme.ts) ile AYNI kuralı
/// uygular; örnekler sablonBolme.test.ts'tekilerle aynıdır - biri değişirse diğeri de değişmeli.
/// Yalnız saf işlevler çağrılır, veri yazılmaz.
/// </summary>
public sealed class SablonBakanlikBolmeTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private sealed record Bolum(string Baslik, string Html, short Parca, short Zorunlu);

    private async Task<List<Bolum>> Bol(string html) =>
        await _olgu.Gerekli().ListeAsync(
            "select baslik, html, bakanlik_parca, zorunlu from public.fn_rad_sablon_bol(@p0) order by sira",
            [html], o => new Bolum(o.GetString(0), o.GetString(1), o.GetInt16(2), o.GetInt16(3)));

    [VtFact]
    public async Task Baslik_yalniz_tek_basina_ya_da_iki_noktayla()
    {
        if (!_olgu.Baglandi(nameof(Baslik_yalniz_tek_basina_ya_da_iki_noktayla))) return;
        async Task<(short?, string?)> B(string m) => (await _olgu.Gerekli().ListeAsync(
            "select parca, kalan from public.fn_rad_baslik_bul(@p0)", [m],
            o => ((short?)(o.IsDBNull(0) ? null : o.GetInt16(0)), o.IsDBNull(1) ? null : o.GetString(1))))[0];

        Assert.Equal(((short?)3, ""), await B("BULGULAR"));
        Assert.Equal(((short?)3, ""), await B("Bulgular :"));
        Assert.Equal(((short?)1, "T2W koronal"), await B("Teknik : T2W koronal"));
        Assert.Equal(((short?)4, ""), await B("SONUÇ:"));
        Assert.Equal(((short?)4, ""), await B("Sonuç ve öneriler:"));
        Assert.Equal(((short?)0, ""), await B("Klinik Bilgi:"));
        Assert.Equal(((short?)null, (string?)null), await B("Bulgular ile uyumlu görünüm"));
    }

    [VtFact]
    public async Task Eski_sablon_dort_parcaya_tablo_bulgularda()
    {
        if (!_olgu.Baglandi(nameof(Eski_sablon_dort_parcaya_tablo_bulgularda))) return;
        var b = await Bol("<p>SAĞ DİZ MR</p><p><i>Teknik : T2W koronal</i></p><p><b><u>Bulgular</u>:</b></p>"
            + "<p>Menisküs normal.</p><table><tbody><tr><td>a</td></tr></tbody></table><p><b>SONUÇ:</b></p><p>Normal.</p>");
        Assert.Equal(["Teknik", "Karşılaştırma", "Bulgular", "Sonuç ve öneriler"], b.Select(x => x.Baslik));
        Assert.Equal([1, 2, 3, 4], b.Select(x => (int)x.Parca));
        Assert.Equal([0, 0, 1, 1], b.Select(x => (int)x.Zorunlu));
        Assert.Equal("<p>T2W koronal</p>", b[0].Html);
        Assert.Equal("", b[1].Html);
        Assert.Contains("SAĞ DİZ MR", b[2].Html);
        Assert.Contains("<table>", b[2].Html);
        Assert.Equal("<p>Normal.</p>", b[3].Html);

        var s = await Bol("<p><b>Bulgular:</b></p><p style=\"text-align: justify\"><br></p><p style=\"x\"><span style=\"y\"> </span></p><p>Var.</p>");
        Assert.Equal("<p>Var.</p>", s.Single(x => x.Parca == 3).Html);
    }

    [VtFact]
    public async Task Eski_Word_kalintilari_atilir()
    {
        if (!_olgu.Baglandi(nameof(Eski_Word_kalintilari_atilir))) return;
        var b = await Bol("<table><tbody><tr><td>HASTA ADI</td><td><b>@ADSOYAD</b></td></tr></tbody></table>"
            + "<p><br></p><p>Sayın Meslektaşım,</p><p><b>Teknik: </b>T2A aksial.</p>"
            + "<p><b><u>Bulgular</u></b><b>:</b></p><p>Karaciğer boyutları normal, parankim homojen, fokal lezyon izlenmedi.</p>"
            + "<p><b>SONU&#199;:</b></p><p><b>Normal sınırlarda.</b></p><p><br></p>"
            + "<p style=\"text-align: center\">Saygılarımızla,</p><p>Rad.Dr. X</p>");
        Assert.Equal([1, 2, 3, 4], b.Select(x => (int)x.Parca));
        Assert.Equal("<p>T2A aksial.</p>", b[0].Html);
        Assert.Equal("<p>Karaciğer boyutları normal, parankim homojen, fokal lezyon izlenmedi.</p>", b[2].Html);
        Assert.Equal("<p><b>Normal sınırlarda.</b></p>", b[3].Html);
        Assert.DoesNotMatch("@ADSOYAD|Meslektaşım|Saygılarımızla|Rad\\.Dr", string.Concat(b.Select(x => x.Html)));

        var y = await Bol("<p>BULGULAR:</p><p>Ölçüm @OLCUM mm.</p>");       // başlıktan sonra yer tutucu korunur
        Assert.Equal("<p>Ölçüm @OLCUM mm.</p>", y[2].Html);
    }

    // 1333 (kod incelemesi) - aynı örnekler sablonBolme.test.ts'te.
    [VtFact]
    public async Task Yer_tutuculu_baslik_ve_saran_tablo_korunur_yorum_yok_sayilir()
    {
        if (!_olgu.Baglandi(nameof(Yer_tutuculu_baslik_ve_saran_tablo_korunur_yorum_yok_sayilir))) return;
        var a = await Bol("<p>BULGULAR: @OLCUM mm kalınlık.</p><p>SONUÇ:</p><p>Normal.</p>");
        Assert.Equal("<p>@OLCUM mm kalınlık.</p>", a[2].Html);
        var uzun = string.Concat(Enumerable.Repeat("Karaciğer boyutları normal, parankim homojen. ", 8));
        var t = await Bol($"<table><tbody><tr><td>@ADSOYAD</td><td>{uzun}</td></tr></tbody></table>");
        Assert.Contains("Karaciğer boyutları normal", t[2].Html);
        var k = await Bol("<!--StartFragment--><p>Serbest metin.</p><!--EndFragment-->");
        Assert.Equal("<p>Serbest metin.</p>", k[2].Html);
    }

    [VtFact]
    public async Task Gecersiz_karakter_varligi_patlatmaz_oldugu_gibi_kalir()
    {
        if (!_olgu.Baglandi(nameof(Gecersiz_karakter_varligi_patlatmaz_oldugu_gibi_kalir))) return;
        var cozulen = (await _olgu.Gerekli().ListeAsync("select public.fn_html_varlik_coz(@p0)",
            ["a&#xD800;b&#55357;c&#x0;d&#xFFFFFF;e&#0;f&#231;g&#xE7;"], o => o.GetString(0)))[0];
        Assert.Equal("a&#xD800;b&#55357;c&#x0;d&#xFFFFFF;e&#0;fçgç", cozulen);
        var b = await Bol("<p>BULGULAR:</p><p>Kist &#55357; izlendi, boyutu normal sınırlarda, çevre doku doğal.</p>");
        Assert.Contains("Kist", b[2].Html);
    }

    [VtFact]
    public async Task Basliksiz_metin_butunuyle_bulgulara_klinik_bilgi_ayri()
    {
        if (!_olgu.Baglandi(nameof(Basliksiz_metin_butunuyle_bulgulara_klinik_bilgi_ayri))) return;
        var b = await Bol("<p>Serbest metin.</p>");
        Assert.Equal("<p>Serbest metin.</p>", b.Single(x => x.Parca == 3).Html);
        Assert.Equal(4, b.Count);                                          // boş klinik bilgi bölümü açılmaz

        var k = await Bol("<p>Klinik bilgi: baş ağrısı</p><p>BULGULAR:</p><p>Yok.</p>");
        Assert.Equal(("Klinik bilgi", "<p>baş ağrısı</p>", (short)0), (k[0].Baslik, k[0].Html, k[0].Parca));
        Assert.Equal(5, k.Count);
    }
}
