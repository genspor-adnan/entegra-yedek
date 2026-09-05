using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Testler;

/// <summary>
/// LİSTE SQL ÜRETİCİSİ — ürünün güvenlik sınırı burada.
///
/// Sözleşmenin iki taahhüdü var ve ikisi de sessizce kırılabilir:
///   1. İstekten gelen HİÇBİR METİN SQL'e girmez; değerler daima parametre.
///   2. Alan adı beyaz listeden geçer (KaynakKatalogu); bilinmeyen alan
///      görmezden gelinmez, istek reddedilir.
///
/// "Görmezden gelme" en sinsi hata olurdu: filtre uygulanmadan tüm satırlar
/// dönerdi ve ekran doğru görünürdü.
/// </summary>
public class SorguUreticiTestleri
{
    private static SorguUretici Uretici(string kaynakAdi = "hasta")
        => new(KaynakKatalogu.Bul(kaynakAdi)
               ?? throw new InvalidOperationException($"kaynak yok: {kaynakAdi}"));

    private static IReadOnlyList<KolonTanimi> Kolonlar(string kaynakAdi = "hasta")
        => KaynakKatalogu.Bul(kaynakAdi)!.Kolonlar.Take(3).ToList();

    [Fact]
    public void FiltreDegeri_SQLE_GOMULMEZ_parametreOlur()
    {
        var istek = new ListeIstegi
        {
            Filtre = new Kosul { Alan = "unvan", Op = KosulOperatoru.Icerir, Deger = "O'BRIEN" },
        };

        var p = Uretici().Satirlar(istek, Kolonlar(), subeId: 1,
                                   kapsamTarafIdleri: null, kullaniciId: null);

        Assert.DoesNotContain("O'BRIEN", p.Sql, StringComparison.OrdinalIgnoreCase);
        Assert.Contains(p.Parametreler, x => x is string s && s.Contains("O'BRIEN"));
    }

    [Fact]
    public void BilinmeyenAlan_SESSIZCE_GECILMEZ()
    {
        var istek = new ListeIstegi
        {
            Filtre = new Kosul { Alan = "boyle_bir_alan_yok", Op = KosulOperatoru.Esit, Deger = 1 },
        };

        var hata = Record.Exception(() =>
            Uretici().Satirlar(istek, Kolonlar(), 1, null, null));

        Assert.NotNull(hata);
        Assert.Contains("boyle_bir_alan_yok", hata!.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void SubeSuzgeci_SUNUCUDA_eklenir()
    {
        // Şube istekte gelmez, sunucuda damgalanır (API §8). Eklenmezse bir
        //   şubenin kullanıcısı ötekinin verisini görürdü.
        var kaynak = KaynakKatalogu.Bul("hasta")!;
        var p = Uretici().Satirlar(new ListeIstegi(), Kolonlar(), subeId: 7, null, null);

        if (kaynak.SubeKolonu is not null || kaynak.SubeKosulu is not null)
            Assert.Contains(p.Parametreler, x => x is int i && i == 7);
    }

    [Fact]
    public void Boyut_UST_SINIRA_kirpilir()
    {
        // İstemci 100 bin isteyebilir; sözleşme sınırı 500.
        var p = Uretici().Satirlar(new ListeIstegi { Boyut = 100_000 }, Kolonlar(), 1, null, null);
        Assert.Contains(p.Parametreler, x => x is int i && i == ListeIstegi.EnBuyukBoyut);
    }

    [Fact]
    public void Siralama_BEYAZ_LISTEDEN_gecer()
    {
        // Sıralama alanı da SQL'e giriyor: uydurma alan sıralamaya girmemeli
        //   (varsayılan sıralamaya düşer), yoksa "order by; drop table" yolu açılır.
        var istek = new ListeIstegi
        {
            Sirala = [new Siralama { Alan = "unvan; drop table taraf", Yon = "asc" }],
        };
        var p = Uretici().Satirlar(istek, Kolonlar(), 1, null, null);
        Assert.DoesNotContain("drop table", p.Sql, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void SonSikAranan_gorunumu_KULLANICI_yoksa_JOIN_eklemez()
    {
        // Kullanıcı kimliği yoksa (iç çağrı) "son aranan" join'i eklenemez;
        //   eklenirse sorgu parametresiz kalıp patlardı.
        var istek = new ListeIstegi { Gorunum = "son" };
        var p = Uretici().Satirlar(istek, Kolonlar(), 1, null, kullaniciId: null);
        Assert.DoesNotContain("kullanici_arama", p.Sql, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void SonAranan_gorunumu_kullaniciVarsa_SIRALAMA_kullanici_aramasindan()
    {
        var istek = new ListeIstegi { Gorunum = "son" };
        var p = Uretici().Satirlar(istek, Kolonlar(), 1, null, kullaniciId: 42);
        Assert.Contains("kullanici_arama", p.Sql, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("ka.son_tarih desc", p.Sql, StringComparison.OrdinalIgnoreCase);
        // 399/400 ile eklenen sıralama anahtarları da seçime giriyor.
        Assert.Contains("aramaSonTarih", p.Sql, StringComparison.Ordinal);
    }
}
