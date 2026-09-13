using System.Text.RegularExpressions;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// BELGE_SATIR'A NO ACTION İLE BAĞLI HER TABLO "KORUNAN SATIR" SORGUSUNDA
/// OLMALI.
///
/// Belge kaydetme satırları siler ve yeniden yazar. Başka bir kaydın işaret
/// ettiği satır silinemez; `BelgeDeposu.KorunanSatirSql` bu satırları ayırıp
/// yerinde bırakır. Listeye eklenmemiş bir tablo, kartın bir daha
/// KAYDEDİLEMEMESİ demektir - hata kaydetme anında, kullanıcının o sırada
/// yaptığı işle ilgisiz bir mesajla çıkar:
///
///   "Bağlantılı kayıt bulunamadı ya da bu kayıt başka kayıtlarda
///    kullanıldığı için silinemiyor (…_belge_satir_id_fkey)."
///
/// GERÇEK VAKALAR: önce radyoloji istemi açılmış başvuru kaydedilemedi;
/// sonra aynısı `sigorta_provizyon_satir` ile yaşandı - provizyon alınmış
/// başvuru bir daha kaydedilemiyordu. İkisi de aynı eksik: yeni tablo
/// belge_satir'a bağlanırken bu sorgu unutuldu.
///
/// CASCADE olanlar listede OLMAK ZORUNDA DEĞİL (veritabanı kendi siler), ama
/// bazıları bilerek listede: silinmeleri veri kaybı olurdu
/// (`kasa_islem_dagitim` - tahsilat dağılımı ve ona bağlı hakediş). Bu yüzden
/// test yalnız NO ACTION olanları ZORUNLU tutar.
/// </summary>
public sealed class KorunanSatirTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static string KorunanSatirSql()
    {
        // Sorgu `internal` değil `private const` - yansımayla değil KAYNAKTAN
        //   okunur. Metnin kendisi zaten testin konusu.
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var yol = Path.Combine(dizin!.FullName, "src", "Gentegre.Veri",
                               "Depolar", "BelgeDeposu.cs");
        var metin = File.ReadAllText(yol);
        var m = Regex.Match(metin,
            @"KorunanSatirSql\s*=\s*""""""(?<govde>.*?)"""""";",
            RegexOptions.Singleline);
        Assert.True(m.Success, "KorunanSatirSql kaynakta bulunamadı.");
        return m.Groups["govde"].Value;
    }

    [Fact]
    public async Task NoAction_bagli_tablolar_korunan_sorgusunda()
    {
        if (!_olgu.Baglandi(nameof(NoAction_bagli_tablolar_korunan_sorgusunda))) return;
        var veri = _olgu.Gerekli();

        // confdeltype 'a' = NO ACTION: satır silinmeye çalışılınca 23503.
        var tablolar = await veri.ListeAsync("""
            select c.conrelid::regclass::text
              from pg_constraint c
             where c.confrelid = 'public.belge_satir'::regclass
               and c.contype = 'f' and c.confdeltype = 'a'
             order by 1
            """, null, o => o.GetString(0), CancellationToken.None);

        Assert.NotEmpty(tablolar);   // sorgu tutmuyorsa test boşuna yeşil olmasın

        var sql = KorunanSatirSql();
        var eksik = tablolar
            .Select(t => t.StartsWith("public.", StringComparison.Ordinal) ? t[7..] : t)
            .Where(t => !sql.Contains("public." + t, StringComparison.Ordinal))
            .ToList();

        Assert.True(eksik.Count == 0,
            "belge_satir'a NO ACTION ile bağlı ama KorunanSatirSql'de olmayan "
            + "tablo - o satırı kullanan belge BİR DAHA KAYDEDİLEMEZ:\n  "
            + string.Join("\n  ", eksik));
    }
}
