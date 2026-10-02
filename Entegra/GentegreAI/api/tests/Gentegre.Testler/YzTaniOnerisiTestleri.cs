using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// YZ TANI ÖNERİSİ (kullanıcı: "yaş cinsiyet vb bilgiler kullanılabilir ama
/// kimlik no ad soyad bilgileri kullanılmaz").
///
/// · Modele giden metinde hastanın / yakınlarının / hekimin adı, kimlik no,
///   telefon YOK; yaş ve cinsiyet VAR.
/// · Model çıktısı katalogla doğrulanır: uydurma kod atılır, ad katalogdan,
///   mevcut tanı tekrar önerilmez.
/// DB testi kendi muayene satırını açar ve siler; veritabanı yoksa atlanır.
/// </summary>
public sealed class YzTaniOnerisiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [Fact]
    public void Anonimlestir_adlari_kimlik_no_ve_telefonu_siler_klinik_metni_birakir()
    {
        var m = YzTaniOnerisi.Anonimlestir(
            "Zeynep KAYA (TC 12345678901, 0532 111 22 33) 3 gündür ateş; annesi ayşe de hasta. İlaç: parasetamol",
            ["Zeynep", "Kaya", "Ayşe"]);
        Assert.DoesNotContain("Zeynep", m);
        Assert.DoesNotContain("KAYA", m);
        Assert.DoesNotContain("ayşe", m);
        Assert.DoesNotContain("12345678901", m);
        Assert.DoesNotContain("0532", m);
        Assert.Contains("[kişi]", m);
        Assert.Contains("3 gündür ateş", m);
        Assert.Contains("parasetamol", m);
    }

    [Fact]
    public void Kullanici_metni_yas_cinsiyet_icerir_kimlik_icermez()
    {
        var b = new YzTaniOnerisi.Baglam(34, 410, 2, "İç Hastalıkları",
            "Mehmet Bey'in eşi Elif iki gündür boğaz ağrısı", "Elif ateşli", "Farinks hiperemik", "", "ateş 38.4 °C",
            ["J02.9 AKUT FARENJİT"], [], ["penisilin (döküntü)"], ["metformin"],
            ["Elif", "Demir", "Mehmet"]);
        var t = YzTaniOnerisi.KullaniciMetni(b);
        Assert.Contains("34 yaş", t);
        Assert.Contains("Kadın", t);
        Assert.Contains("boğaz ağrısı", t);
        Assert.Contains("penisilin", t);
        Assert.DoesNotContain("Elif", t);
        Assert.DoesNotContain("Mehmet", t);
        Assert.True(b.Yeterli);
        Assert.False((b with { Sikayet = "", Hikaye = " ", Bulgular = "" }).Yeterli);
    }

    [Fact]
    public void Coz_katalogda_olmayani_atar_adi_katalogdan_alir_mevcudu_tekrarlamaz()
    {
        var katalog = new Dictionary<string, string>
        {
            ["J02.9"] = "AKUT FARENJİT, TANIMLANMAMIŞ", ["J03.9"] = "AKUT TONSİLLİT, TANIMLANMAMIŞ",
            ["J06.9"] = "AKUT ÜST SOLUNUM YOLU ENFEKSİYONU",
        };
        var metin = """
            İşte öneriler:
            {"oneriler":[
              {"icd":"J03.9","olasilik":"yüksek","gerekce":"ateş ve tonsiller eksüda"},
              {"icd":"X99.9","olasilik":"orta","gerekce":"uydurma"},
              {"icd":"J02.9","olasilik":"orta","gerekce":"zaten var"},
              {"icd":"j06.9","olasilik":"??","gerekce":"viral olabilir"}],
             "kirmiziBayrak":"peritonsiller apse dışlanmalı","eksikBilgi":"öksürük var mı"}
            """;
        var (liste, kirmizi, eksik, atilan) = YzTaniOnerisi.Coz(metin, k => katalog.GetValueOrDefault(k), ["J02.9"]);
        Assert.Equal(["J03.9", "J06.9"], liste.Select(x => x.Kod));
        Assert.Equal("AKUT TONSİLLİT, TANIMLANMAMIŞ", liste[0].Ad);
        Assert.Equal("yuksek", liste[0].Olasilik);
        Assert.Equal("orta", liste[1].Olasilik);
        Assert.Equal(1, atilan);
        Assert.Contains("apse", kirmizi);
        Assert.Contains("öksürük", eksik);
        Assert.Empty(YzTaniOnerisi.Coz("model json vermedi", _ => "x", []).Oneriler);
    }

    [Fact]
    public void Tetkik_yaniti_katalog_disi_lab_kodunu_ve_taninmayan_modaliteyi_atar()
    {
        var metin = """
            {"oneriler":[
              {"tur":"lab","kod":"crp","gerekce":"bakteriyel/viral ayrımı"},
              {"tur":"lab","kod":"UYDURMA","gerekce":"x"},
              {"tur":"goruntuleme","modalite":"USG","bolge":"batın","gerekce":"apandisit"},
              {"tur":"goruntuleme","modalite":"sintigrafi","bolge":"tiroid","gerekce":"x"},
              {"tur":"goruntuleme","modalite":"Röntgen","bolge":"","gerekce":"x"}],
             "not":"idrar tahlili de düşünülebilir"}
            """;
        var (lab, gor, not, atilan) = YzIstemReceteOnerisi.CozTetkik(metin, new HashSet<string> { "CRP", "GLU" });
        Assert.Equal("CRP", Assert.Single(lab).Kod);
        var g = Assert.Single(gor);
        Assert.Equal(3, g.Modalite);
        Assert.Equal("batın", g.Bolge);
        Assert.Equal(3, atilan);
        Assert.Contains("idrar", not);
        Assert.Equal(["batın"], YzIstemReceteOnerisi.BolgeSozcukleri("Batın USG"));
        Assert.Equal(4, YzIstemReceteOnerisi.ModaliteKodu("Direkt grafi"));
    }

    [Fact]
    public void Ilac_yaniti_etken_madde_sade_alerji_cakismasi_yakalanir()
    {
        var (liste, _) = YzIstemReceteOnerisi.CozIlac("""
            {"oneriler":[{"etken":"Amoksisilin","gerekce":"bakteriyel tonsillit"},
                         {"etken":"amoksisilin","gerekce":"tekrar"},
                         {"etken":"Parasetamol","gerekce":"ateş"}],"not":""}
            """);
        Assert.Equal(["amoksisilin", "parasetamol"], liste.Select(x => x.Etken));
        Assert.True(YzIstemReceteOnerisi.AlerjiCakisir("amoksisilin", ["Amoksisilin (döküntü)"]));
        Assert.True(YzIstemReceteOnerisi.AlerjiCakisir("amoksisilin klavulanat", ["amoksisilin"]));
        Assert.False(YzIstemReceteOnerisi.AlerjiCakisir("parasetamol", ["penisilin (döküntü)"]));
        // Çapraz grup: penisilin alerjisi amoksisilini, NSAİİ alerjisi ibuprofeni eler.
        Assert.True(YzIstemReceteOnerisi.AlerjiCakisir("amoksisilin", ["Penisilin (döküntü)"]));
        Assert.True(YzIstemReceteOnerisi.AlerjiCakisir("ibuprofen", ["diklofenak (anjiyoödem)"]));
        Assert.False(YzIstemReceteOnerisi.AlerjiCakisir("azitromisin", ["Penisilin"]));
        // İngilizce yazım yedeği.
        Assert.Equal("azitromisin", YzIstemReceteOnerisi.TurkceYazim("azithromycin"));
        Assert.Equal("amoksisilin", YzIstemReceteOnerisi.TurkceYazim("amoxicillin"));
        Assert.Equal("siprofloksasin", YzIstemReceteOnerisi.TurkceYazim("ciprofloxacin"));
    }

    [VtFact]
    public async Task Muayeneden_toplanan_metinde_hastanin_adi_ve_kimlik_no_yok()
    {
        if (!_olgu.Baglandi(nameof(Muayeneden_toplanan_metinde_hastanin_adi_ve_kimlik_no_yok))) return;
        var veri = _olgu.Gerekli();
        var hasta = await veri.TekDegerAsync<int>(
            "select min(h.id) from public.taraf_hasta h join public.taraf t on t.id = h.id where coalesce(t.ad, '') <> ''", []);
        var ad = await veri.TekDegerAsync<string>("select ad from public.taraf where id = @p0", [hasta]) ?? "";
        var muayene = await veri.TekDegerAsync<int>("""
            insert into public.muayene (taraf_id, sikayet, hikaye)
            values (@p0, 'Karın ağrısı', @p1) returning id
            """, [hasta, $"{ad} sabahtan beri kusuyor, TC 11122233344"]);
        try
        {
            await using var b = await veri.AcAsync(CancellationToken.None);
            var bag = await YzTaniOnerisi.Topla(b, muayene, CancellationToken.None);
            Assert.NotNull(bag);
            var t = YzTaniOnerisi.KullaniciMetni(bag!);
            Assert.Contains("Karın ağrısı", t);
            Assert.Contains("kusuyor", t);
            Assert.DoesNotContain("11122233344", t);
            foreach (var sozcuk in ad.Split(' ', StringSplitOptions.RemoveEmptyEntries).Where(s => s.Length >= 2))
                Assert.DoesNotContain(sozcuk, t, StringComparison.CurrentCultureIgnoreCase);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.muayene where id = @p0", [muayene]);
        }
    }
}
