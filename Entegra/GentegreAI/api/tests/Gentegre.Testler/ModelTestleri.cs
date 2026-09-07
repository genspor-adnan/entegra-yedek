using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// DİL MODELİ KATMANI (450) — model <b>anlatır, karar vermez</b>.
///
/// Buradaki testler modelin dört sınırını tutuyor: uydurduğu ekran geçmez,
/// kullanıcının göremediği ekran modele hiç gitmez, kontör yoksa çağrı
/// yapılmaz, model düşerse asistan susmaz (katalog cevabı verilir).
/// </summary>
public class ModelTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public ModelTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    /// <summary>Gerçek sağlayıcı yerine sabit cevap: ağ yok, ücret yok.</summary>
    private sealed class SahteSaglayici(string? cevap, bool hazir = true) : IModelSaglayici
    {
        public int Cagri;
        public string SonBaglam = "";
        public bool Hazir => hazir;
        public string Ad => "sahte-model";

        public Task<ModelYaniti?> IsteAsync(ModelIstegi istek, CancellationToken iptal)
        {
            Cagri++;
            SonBaglam = istek.Kullanici;
            return Task.FromResult(cevap is null
                ? null : new ModelYaniti(cevap, 120, 60, "sahte-model"));
        }
    }

    private sealed record KontorSatiri(decimal Bakiye, short Aktif);
    private sealed record HareketSatiri(int Jeton, short Kaynak, string Model);

    private static IstekBaglami Baglam(params string[] kodlar) => new()
    {
        KullaniciId = 1,
        RolId = 1,
        SubeId = 1,
        Yetkiler = new YetkiSeti(1,
            kodlar.Select(k => new YetkiKaydi(k, 0, true, true, true, true)), []),
        IzlemeNo = "test",
    };

    private static RehberServisi Servis(VeriKaynagi veri, SahteSaglayici saglayici) =>
        new(veri, new RehberModeli(saglayici, NullLogger<RehberModeli>.Instance));

    private const string GecerliCevap = """
        {"cevap":"Demirbaş zimmetini şöyle devredersiniz:",
         "adimlar":[{"metin":"Demirbaş listesini açın.","ekran":"/demirbas"},
                    {"metin":"Zimmet sekmesinden yeni kişiyi seçin.","ekran":null}],
         "eksikBilgiSorusu":null,"guven":0.8}
        """;

    // ------------------------------------------------------ çıktı doğrulaması

    [Fact]
    public void Coz_UYDURULAN_EKRANI_atar()
    {
        // Modelin "şu ekrandan yaparsın" dediği ekran gerçekten yoksa, adım
        //   metni kalır ama DÜĞME çizilmez: olmayan menüyü tarif eden asistan
        //   yanlış cevaptan beterdir.
        var beyaz = new List<RehberModeli.Ekran> { new("demirbas", "/demirbas", "Demirbaş") };
        var c = RehberModeli.Coz("""
            {"cevap":"Şöyle:","adimlar":[
               {"metin":"Gerçek ekran.","ekran":"/demirbas"},
               {"metin":"Uydurma ekran.","ekran":"/gizli-panel"}],"guven":0.9}
            """, beyaz);

        Assert.NotNull(c);
        Assert.Equal("/demirbas", c!.Adimlar[0].Ekran);
        Assert.Null(c.Adimlar[1].Ekran);          // beyaz listede yok - atıldı
    }

    [Fact]
    public void Coz_KOD_BLOGUNDAKI_jsonu_okur()
    {
        // Model JSON'u ``` içine sarabiliyor; sözleşme bozulmasın diye ilk
        //   '{' ile son '}' arası alınır.
        var c = RehberModeli.Coz("```json\n{\"cevap\":\"Merhaba\",\"guven\":0.5}\n```", []);
        Assert.Equal("Merhaba", c!.Cevap);
    }

    [Fact]
    public void Coz_BOZUK_cevapta_null_doner()
    {
        Assert.Null(RehberModeli.Coz("cevabım şu: bilmiyorum", []));
        Assert.Null(RehberModeli.Coz("{bozuk json", []));
    }

    // ------------------------------------------------------------- kontör ---

    /// <summary>Kontör satırını test için ayarlar; eski değeri geri verir.</summary>
    private async Task<KontorSatiri?> KontorAyarlaAsync(decimal bakiye)
    {
        var veri = _olgu.Gerekli();
        var eski = await veri.TekAsync(
            "select bakiye, model_aktif from public.ai_kontor where id = 1",
            null, o => new KontorSatiri(o.GetDecimal(0), o.GetInt16(1)));
        await veri.CalistirAsync(
            "update public.ai_kontor set bakiye = @p0, model_aktif = 1 where id = 1",
            [bakiye]);
        return eski;
    }

    private async Task KontorGeriAlAsync(KontorSatiri? eski) =>
        await _olgu.Gerekli().CalistirAsync(
            "update public.ai_kontor set bakiye = @p0, model_aktif = @p1 where id = 1",
            [eski?.Bakiye ?? 0m, eski?.Aktif ?? (short)1]);

    [Fact]
    public async Task Model_cevabi_KONTOR_duser_ve_gunluge_yazar()
    {
        if (!_olgu.Baglandi(nameof(Model_cevabi_KONTOR_duser_ve_gunluge_yazar))) return;
        var veri = _olgu.Gerekli();
        var saglayici = new SahteSaglayici(GecerliCevap);
        var eski = await KontorAyarlaAsync(10m);
        try
        {
            var y = await Servis(veri, saglayici).CevaplaAsync(
                new RehberServisi.Istek("demirbaş zimmet nasıl devredilir", null, null, null),
                Baglam("demirbas"), CancellationToken.None);

            Assert.True(y.ModelKullanildi, "model cevabı kullanılmadı");
            Assert.Equal(5, y.KaynakTuru);
            Assert.Equal("sahte-model", y.Model);
            Assert.Equal("/demirbas", y.Adimlar[0].Rota);
            Assert.Equal(1, saglayici.Cagri);

            // Kontör ÇAĞRI BAŞARILI OLUNCA düşer; hareket jetonuyla yazılır.
            var bakiye = await veri.TekDegerAsync<decimal>(
                "select bakiye from public.ai_kontor where id = 1");
            Assert.Equal(9m, bakiye);
            var hareket = await veri.TekAsync("""
                select h.jeton, l.kaynak, l.model
                  from public.ai_kontor_hareket h
                  join public.ai_rehber_log l on l.id = h.rehber_log_id
                 order by h.id desc limit 1
                """, null, o => new HareketSatiri(o.GetInt32(0), o.GetInt16(1),
                                                  o.GetString(2)));
            Assert.NotNull(hareket);
            Assert.Equal(180, hareket!.Jeton);      // 120 giriş + 60 çıkış
            Assert.Equal(5, hareket.Kaynak);
            Assert.Equal("sahte-model", hareket.Model);
        }
        finally { await KontorGeriAlAsync(eski); }
    }

    [Fact]
    public async Task Kontor_yoksa_MODEL_CAGRILMAZ()
    {
        if (!_olgu.Baglandi(nameof(Kontor_yoksa_MODEL_CAGRILMAZ))) return;
        var veri = _olgu.Gerekli();
        var saglayici = new SahteSaglayici(GecerliCevap);
        var eski = await KontorAyarlaAsync(0m);
        try
        {
            var y = await Servis(veri, saglayici).CevaplaAsync(
                new RehberServisi.Istek("demirbaş zimmet nasıl devredilir", null, null, null),
                Baglam("demirbas"), CancellationToken.None);

            // Ödeyemeyeceğimiz çağrı hiç yapılmaz; asistan da susmaz.
            Assert.Equal(0, saglayici.Cagri);
            Assert.False(y.ModelKullanildi);
            Assert.Contains(y.Uyarilar, u => u.Contains("kontör",
                                                        StringComparison.OrdinalIgnoreCase));
            Assert.False(string.IsNullOrWhiteSpace(y.Cevap));
        }
        finally { await KontorGeriAlAsync(eski); }
    }

    [Fact]
    public async Task Model_dusunce_KATALOG_cevabi_verilir()
    {
        if (!_olgu.Baglandi(nameof(Model_dusunce_KATALOG_cevabi_verilir))) return;
        var veri = _olgu.Gerekli();
        var saglayici = new SahteSaglayici(null);          // sağlayıcı hata verdi
        var eski = await KontorAyarlaAsync(10m);
        try
        {
            var y = await Servis(veri, saglayici).CevaplaAsync(
                new RehberServisi.Istek("demirbaş zimmet nasıl devredilir", null, null, null),
                Baglam("demirbas"), CancellationToken.None);

            Assert.Equal(1, saglayici.Cagri);
            Assert.False(y.ModelKullanildi);
            Assert.False(string.IsNullOrWhiteSpace(y.Cevap));
            // Ödemediğimiz çağrı için kontör alınmaz.
            var bakiye = await veri.TekDegerAsync<decimal>(
                "select bakiye from public.ai_kontor where id = 1");
            Assert.Equal(10m, bakiye);
        }
        finally { await KontorGeriAlAsync(eski); }
    }

    [Fact]
    public async Task Yetkisiz_ekran_MODELE_GONDERILMEZ()
    {
        if (!_olgu.Baglandi(nameof(Yetkisiz_ekran_MODELE_GONDERILMEZ))) return;
        var veri = _olgu.Gerekli();
        var eski = await KontorAyarlaAsync(10m);
        try
        {
            // Aynı soru, iki yetki kümesi. Hasta ekranı yalnız yetkili olanın
            //   bağlamında görünmeli: modele giden liste "önerilebilecek
            //   ekranlar" listesidir - göremediği ekran oraya girerse asistan
            //   onu önerir.
            // Soru bilerek KATALOG KONUSU OLMAYAN bir şey: model dalı ancak
            //   katalog cevaplayamadığında çalışır.
            var yetkili = new SahteSaglayici(GecerliCevap);
            await Servis(veri, yetkili).CevaplaAsync(
                new RehberServisi.Istek("demirbaş doküman", null, null, null),
                Baglam("demirbas", "dokuman"), CancellationToken.None);

            var yetkisiz = new SahteSaglayici(GecerliCevap);
            await Servis(veri, yetkisiz).CevaplaAsync(
                new RehberServisi.Istek("demirbaş doküman", null, null, null),
                Baglam("demirbas"), CancellationToken.None);

            Assert.Contains("/dokuman", yetkili.SonBaglam, StringComparison.Ordinal);
            Assert.DoesNotContain("/dokuman", yetkisiz.SonBaglam, StringComparison.Ordinal);
        }
        finally { await KontorGeriAlAsync(eski); }
    }

    [Fact]
    public async Task Katalog_KONUYU_bulduysa_model_cagrilmaz()
    {
        if (!_olgu.Baglandi(nameof(Katalog_KONUYU_bulduysa_model_cagrilmaz))) return;
        var veri = _olgu.Gerekli();
        var saglayici = new SahteSaglayici(GecerliCevap);
        var eski = await KontorAyarlaAsync(10m);
        try
        {
            // Katalog cevabı ÜCRETSİZ ve denetlenebilir: adımları kurum yazdı.
            //   Model yalnız katalogun boş kaldığı yerde devreye girer.
            var y = await Servis(veri, saglayici).CevaplaAsync(
                new RehberServisi.Istek("Yeni hasta kaydı nasıl açılır?", null, null, null),
                Baglam("personel", "belge"), CancellationToken.None);

            Assert.Equal("hasta-kayit", y.KonuKod);
            Assert.Equal(0, saglayici.Cagri);
            Assert.False(y.ModelKullanildi);
        }
        finally { await KontorGeriAlAsync(eski); }
    }

    [Fact]
    public void Anahtar_yoksa_SAGLAYICI_hazir_degildir()
    {
        // Anahtar gelmeden sistem çalışmaya devam etmeli: "hazır değil" =
        //   katalog rehberi, hata değil.
        var saglayici = new SahteSaglayici(GecerliCevap, hazir: false);
        var model = new RehberModeli(saglayici, NullLogger<RehberModeli>.Instance);
        Assert.False(model.Hazir);
    }
}
