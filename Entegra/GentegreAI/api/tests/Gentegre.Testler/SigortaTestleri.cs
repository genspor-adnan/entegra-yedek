using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sigorta;

namespace Gentegre.Testler;

/// <summary>
/// ÖZEL SİGORTA v1 (430) — kanonik sözleşme ve ekran kuralları.
///
/// Buradaki hatalar hastanın cebinden çıkacak tutarı değiştirir: pay
/// dağıtımı yanlış olursa vezne yanlış tahsil eder, provizyon kartı
/// düzenlenebilir olursa şirketin dediği ile bizdeki kayıt ayrışır.
/// </summary>
public class SigortaTestleri
{
    [Fact]
    public void KodEslemeAlanlari_kanonik_isimlerle_ayni()
    {
        // db/430'daki `alan` degerleri ile C# sabitleri birebir olmalı:
        //   biri "hekim_unvani" öteki "hekimUnvani" derse eşleme sessizce
        //   boş döner ve alan servise HİÇ gitmez.
        Assert.Equal("provizyon_tipi", SigortaKanonik.Alan.ProvizyonTipi);
        Assert.Equal("yatis_turu",     SigortaKanonik.Alan.YatisTuru);
        Assert.Equal("hizmet_tipi",    SigortaKanonik.Alan.HizmetTipi);
        Assert.Equal("vaka_tipi",      SigortaKanonik.Alan.VakaTipi);
        Assert.Equal("talep_turu",     SigortaKanonik.Alan.TalepTuru);
        Assert.Equal("hekim_unvani",   SigortaKanonik.Alan.HekimUnvani);
        Assert.Equal("kimlik_tipi",    SigortaKanonik.Alan.KimlikTipi);
        Assert.Equal("police_tipi",    SigortaKanonik.Alan.PoliceTipi);
        Assert.Equal("police_turu",    SigortaKanonik.Alan.PoliceTuru);
        Assert.Equal("islem_kaynagi",  SigortaKanonik.Alan.IslemKaynagi);
        Assert.Equal("malzeme_tipi",   SigortaKanonik.Alan.MalzemeTipi);
        Assert.Equal("iptal_nedeni",   SigortaKanonik.Alan.IptalNedeni);
        Assert.Equal("dokuman_tipi",   SigortaKanonik.Alan.DokumanTipi);
    }

    [Fact]
    public void DurumKodlari_db_ile_ayni_sirada()
    {
        // db/430: 1 taslak · 2 gönderildi · 3 onaylı · 4 kısmi · 5 red · 6 iptal.
        Assert.Equal(1, SigortaKanonik.Durum.Taslak);
        Assert.Equal(2, SigortaKanonik.Durum.Gonderildi);
        Assert.Equal(3, SigortaKanonik.Durum.Onayli);
        Assert.Equal(4, SigortaKanonik.Durum.Kismi);
        Assert.Equal(5, SigortaKanonik.Durum.Red);
        Assert.Equal(6, SigortaKanonik.Durum.Iptal);
    }

    [Fact]
    public void Provizyonun_KARTI_yok()
    {
        // Provizyon bir belge değil, dış servisin yanıtı: elle düzenlenirse
        //   şirketin dediği ile bizdeki kayıt ayrışır.
        Assert.Null(KartKatalogu.Bul("sigorta-provizyon"));
        Assert.NotNull(KaynakKatalogu.Bul("sigorta-provizyon"));
    }

    [Fact]
    public void Sigorta_kaynaklari_sigorta_yetkisine_bagli()
    {
        // Belge yetkisine bağlamak, faturayı gören herkese poliçe ve tanı
        //   bilgisini açardı (özel nitelikli veri).
        foreach (var ad in new[] { "sigorta-provizyon", "sigorta-hesap",
                                   "sigorta-kod-esleme", "sigorta-istek-log" })
            Assert.Equal("sigorta", KaynakKatalogu.Bul(ad)?.YetkiKodu);
    }

    [Fact]
    public void Provizyon_listesinde_pay_kirilimi_var()
    {
        // Vezne "kurum ne ödeyecek, hastadan ne alınacak" sorusunu kart
        //   açmadan görebilmeli.
        var k = KaynakKatalogu.Bul("sigorta-provizyon");
        Assert.NotNull(k);
        foreach (var kolon in new[] { "talepToplam", "sirketPayi", "hastaPayi" })
            Assert.NotNull(k!.Kolon(kolon));
    }

    [Fact]
    public void Iptal_ve_ayar_ayri_aksiyon_yetkisi_ister()
    {
        var liste = AksiyonKatalogu.Ekran("sigorta-provizyon-liste")!;
        Assert.Equal("sigorta.iptal",
            liste.First(a => a.Kod == "sigorta.iptal").AksiyonYetkisi);
        Assert.Equal("sigorta.provizyon",
            liste.First(a => a.Kod == "sigorta.dokuman").AksiyonYetkisi);

        var hesap = AksiyonKatalogu.Ekran("sigorta-hesap-liste")!;
        Assert.Equal("sigorta.ayar",
            hesap.First(a => a.Kod == "sigorta.hesap-test").AksiyonYetkisi);
    }

    [Fact]
    public void Hesap_kartinda_parola_alani_YOK()
    {
        // Kimlik bilgisi entegrasyon hesabı kartında durur; iki yerde
        //   saklamak, birini değiştirip ötekini unutmak demekti.
        var kart = KartKatalogu.Bul("sigorta-hesap");
        Assert.NotNull(kart);
        Assert.All(kart!.Alanlar, a =>
            Assert.DoesNotContain("parola", a.Ad, StringComparison.OrdinalIgnoreCase));
        Assert.All(kart.Alanlar, a =>
            Assert.DoesNotContain("sifre", a.Ad, StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public void Yetenek_bayraklari_ekrani_surer()
    {
        // v1'de paket ve ekstre YOK: bayrak açık bırakılırsa ekran
        //   çalışmayan bir düğme çizer.
        var y = new SaglayiciYetenek(Police: true, Provizyon: true, Iptal: true,
                                     Dokuman: true, Paket: false, Ekstre: false);
        Assert.True(y.Provizyon);
        Assert.False(y.Paket);
        Assert.False(y.Ekstre);
    }
}
