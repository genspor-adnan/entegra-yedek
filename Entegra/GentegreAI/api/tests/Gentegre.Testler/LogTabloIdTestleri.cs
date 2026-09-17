using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// LOG TABLO KODU BENZERSİZLİĞİ (757).
///
/// `islem_log.tablo_id` denetim izinin "neyin kaydı" sorusuna verdiği tek
/// cevap ve `kayit_id` ancak onunla birlikte anlam taşır. İki FARKLI tablo
/// aynı numarayı alırsa satırın hangi kayda ait olduğu artık kayıttan
/// okunamaz - ve numaraya bakarak kaydı çözen her yol (log ekranının
/// join'leri, onay omurgasının `kaynak_tur`u, `kasa_islem.kaynak_tur`)
/// yanlış tabloya gider.
///
/// 753-756 arasında bu hata dört kez ayıklandı ve hepsi de ancak
/// kullanıldıktan SONRA fark edildi: yeni bir kart yazarken boş sanılan bir
/// numara alınıyordu, çünkü kullanılan numaraların tek bir listesi yok -
/// katalog dosyalarına ve `Uclar` sabitlerine dağılmış durumda. Bu test o
/// listenin yerini tutuyor: aynı numarayı iki tabloya veren bir değişiklik
/// derlemeden değil, buradan geri döner.
///
/// VERİTABANI GEREKTİRMEZ: katalog saf veridir, test onu bellekte gezer.
/// </summary>
public class LogTabloIdTestleri
{
    /// <summary>
    /// MODÜL İÇİ GRUPLAMALAR MUAF: bir modülün birkaç detay tablosunu tek
    /// numarayla izlemek bilinçli bir tercihtir (göz muayenesinin yedi ölçüm
    /// tablosu "ölçüm detayı" olarak tek başlık altında loglanır). Çakışma
    /// olarak saydığımız şey FARKLI MODÜLLERİN aynı numaraya oturması.
    ///
    /// Muafiyet listesi ELLE tutulur ve kısa kalmalıdır: buraya numara
    /// eklemek "bu iki tabloyu ayırt etmekten vazgeçtik" demektir.
    /// </summary>
    private static readonly HashSet<int> GruplananKodlar = new()
    {
        1101,   // göz görüntüleme + biyometri + ölçüm
        1106,   // göz muayenesi ölçüm detayları (refraksiyon, fundus, ...)
        1107,   // göz işlem detayları (enjeksiyon / lazer / ameliyat)
        1121,   // yatış izlem detayları (izlem, risk, sıvı, yatak, epikriz)
        1124,   // yatış order + uygulama
        1133,   // diş seansı işlem + sarf
        1153,   // medula raporu + satırları
    };

    [Fact]
    public void AyniLogTabloIdIkiFarkliTabloyaVerilmemeli()
    {
        var kova = new Dictionary<int, SortedSet<string>>();

        void Ekle(int kod, string tablo)
        {
            if (kod == 0) return;                 // 0 = kartın kendi kodu kullanılır
            if (!kova.TryGetValue(kod, out var kume))
                kova[kod] = kume = new SortedSet<string>(StringComparer.Ordinal);
            kume.Add(tablo);
        }

        foreach (var kart in KartKatalogu.Tumu)
        {
            Ekle(kart.LogTabloId, kart.Tablo);
            foreach (var detay in kart.Detaylar ?? [])
                Ekle(detay.LogTabloId, detay.Tablo);
        }

        var carpisan = kova
            .Where(x => x.Value.Count > 1 && !GruplananKodlar.Contains(x.Key))
            .OrderBy(x => x.Key)
            .Select(x => $"  {x.Key}: {string.Join(" | ", x.Value)}")
            .ToList();

        Assert.True(carpisan.Count == 0,
            "Aynı LogTabloId birden çok tabloya verilmiş - denetim izinde "
            + "kayıtlar birbirine karışır:\n" + string.Join("\n", carpisan));
    }

    /// <summary>
    /// Muafiyet listesi ÇÜRÜMESİN: gruplama sonradan çözülürse (tablolar ayrı
    /// numara alırsa) buradaki satır da kalkmalı. Ölü bir muafiyet, ileride
    /// gerçek bir çakışmayı sessizce örter.
    /// </summary>
    [Fact]
    public void GruplananKodlarListesindeOlu_Kayit_Olmamali()
    {
        var kova = new Dictionary<int, HashSet<string>>();
        foreach (var kart in KartKatalogu.Tumu)
        {
            void Ekle(int kod, string tablo)
            {
                if (kod == 0) return;
                if (!kova.TryGetValue(kod, out var k)) kova[kod] = k = new HashSet<string>();
                k.Add(tablo);
            }
            Ekle(kart.LogTabloId, kart.Tablo);
            foreach (var detay in kart.Detaylar ?? []) Ekle(detay.LogTabloId, detay.Tablo);
        }

        var olu = GruplananKodlar
            .Where(k => !kova.TryGetValue(k, out var t) || t.Count <= 1)
            .OrderBy(k => k)
            .ToList();

        Assert.True(olu.Count == 0,
            "Muafiyet listesindeki şu kodlar artık tek tabloya ait; satırı "
            + "kaldırın: " + string.Join(", ", olu));
    }
}
