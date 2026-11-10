using System.Globalization;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ROL KAPSAMI (kullanıcı 10.11.2026: "temsilci sadece kendi doktorlarını ve kendi ziyaretlerini görecek, sorumlu ve
/// yönetici hepsini"): kaynak / kart tanımındaki <c>RolKosullari</c> (rol kodu → SQL koşulu, <c>{kullanici}</c> yer
/// tutuculu) kullanıcının ROL KÜMESİNE göre uygulanır.
///
/// <para><b>Geniş rol kazanır:</b> kullanıcının kuralı OLMAYAN bir rolü varsa (yönetici, saha sorumlusu…) kısıt hiç
/// eklenmez. Bütün rolleri kurallı ise koşullar OR ile bağlanır. Portal kapsamından farkı: kuralsız kaynak AÇIK kalır -
/// bu iç kullanıcı, portal değil; yalnız işaretli kaynaklar daralır.</para>
/// </summary>
public static class RolKapsami
{
    /// <summary>Kaynağın rol kuralı; kullanıcıya uymuyorsa null. Kullanıcı id sayı olarak gömülür (parametre değil, int).</summary>
    public static string? Kosul(IReadOnlyDictionary<string, string>? kurallar, IReadOnlyList<string> rolKodlari, int kullaniciId)
    {
        if (kurallar is null || kurallar.Count == 0 || rolKodlari.Count == 0) return null;
        if (rolKodlari.Any(r => !kurallar.ContainsKey(r))) return null;
        var id = kullaniciId.ToString(CultureInfo.InvariantCulture);
        var parcalar = rolKodlari.Distinct()
            .Select(r => "(" + kurallar[r].Replace("{kullanici}", id) + ")");
        return "(" + string.Join(" or ", parcalar) + ")";
    }

    /// <summary>Kullanıcı bu kaynakta DAR kapsamda mı (yalnız kendi kayıtları)?</summary>
    public static bool Dar(IReadOnlyDictionary<string, string>? kurallar, IReadOnlyList<string> rolKodlari)
        => Kosul(kurallar, rolKodlari, 0) is not null;

    /// <summary>İki isteğe bağlı koşulu AND ile bağlar.</summary>
    public static string? Birlestir(string? a, string? b)
        => string.IsNullOrWhiteSpace(a) ? (string.IsNullOrWhiteSpace(b) ? null : b)
         : string.IsNullOrWhiteSpace(b) ? a : $"({a}) and ({b})";

    /// <summary>Saha temsilcisi rolü: yalnız kendi hekimleri / ziyaretleri.</summary>
    public const string SahaTemsilci = "saha_temsilci";

    /// <summary>Dış doktor "benim hekimim": şube temsilcisi satırı (aktif, tarih içinde) ya da varsayılan temsilci.</summary>
    public static string BenimHekimim(string hekimId, string varsayilanTemsilci) =>
        $"(exists (select 1 from public.dis_hekim_temsilci d where d.hekim_id = {hekimId} and d.temsilci_id = {{kullanici}}"
      + $" and coalesce(d.aktif, 1) = 1 and d.baslangic <= current_date and (d.bitis is null or d.bitis >= current_date))"
      + $" or {varsayilanTemsilci} = {{kullanici}})";
}
