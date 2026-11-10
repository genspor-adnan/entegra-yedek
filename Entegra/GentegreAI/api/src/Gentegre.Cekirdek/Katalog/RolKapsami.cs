namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ROL KAPSAMI (kullanıcı 10.11.2026: "temsilci sadece kendi doktorlarını ve kendi ziyaretlerini görecek, sorumlu ve
/// yönetici hepsini"): kaynak / kart tanımındaki <c>RolKosullari</c> (rol kodu → SQL koşulu, <c>{kullanici}</c> yer
/// tutuculu) kullanıcının ROL KÜMESİNE göre uygulanır.
///
/// <para><b>Geniş rol kazanır:</b> kullanıcının kuralı OLMAYAN bir rolü varsa (yönetici, saha sorumlusu…) kısıt hiç
/// eklenmez. Bütün rolleri kurallı ise koşullar OR ile bağlanır. Portal kapsamından farkı: kuralsız kaynak AÇIK kalır -
/// bu iç kullanıcı, portal değil; yalnız işaretli kaynaklar daralır.</para>
///
/// <para><b>Yer tutucu PARAMETREYLE bağlanır</b> (OKUBENI: değerler SQL'e yazılmaz): bu sınıf koşulu
/// <c>{kullanici}</c> ile döndürür; liste tarafı <c>SorguUretici.EkranKosulu</c>, kart tarafı
/// <c>KartDeposu</c> (<c>@rk</c>) bağlar. Rol kodları sistem rolüdür (göç 1296, <c>sistem = 1</c>: kod değişmez).</para>
/// </summary>
public static class RolKapsami
{
    public const string Kullanici = "{kullanici}";

    /// <summary>Kaynağın rol kuralı (yer tutuculu); kullanıcının geniş rolü varsa ya da kural yoksa null.</summary>
    public static string? Kosul(IReadOnlyDictionary<string, string>? kurallar, IReadOnlyList<string> rolKodlari)
    {
        if (kurallar is null || kurallar.Count == 0 || rolKodlari.Count == 0) return null;
        if (rolKodlari.Any(r => !kurallar.ContainsKey(r))) return null;
        var parcalar = rolKodlari.Distinct().Select(r => "(" + kurallar[r] + ")");
        return "(" + string.Join(" or ", parcalar) + ")";
    }

    /// <summary>Kullanıcı bu kaynakta DAR kapsamda mı (yalnız kendi kayıtları)?</summary>
    public static bool Dar(IReadOnlyDictionary<string, string>? kurallar, IReadOnlyList<string> rolKodlari)
        => Kosul(kurallar, rolKodlari) is not null;

    /// <summary>İki isteğe bağlı koşulu AND ile bağlar.</summary>
    public static string? Birlestir(string? a, string? b)
        => string.IsNullOrWhiteSpace(a) ? (string.IsNullOrWhiteSpace(b) ? null : b)
         : string.IsNullOrWhiteSpace(b) ? a : $"({a}) and ({b})";

    /// <summary>Saha temsilcisi rolü (sistem rolü, 1296): yalnız kendi hekimleri / ziyaretleri.</summary>
    public const string SahaTemsilci = "saha_temsilci";

    /// <summary>
    /// Dış doktor "benim hekimim" - hekim, talep ve vade kuralları AYNI tanımı kullanır: herhangi bir şubede aktif,
    /// tarih içi şube temsilcisi satırı YA DA kartın varsayılan temsilcisi (<c>taraf.temsilci</c>). Şubeye
    /// bakılmaz: temsilci hekimini hangi şubeden olursa olsun görür; talebi / vadesi de onunla gelir.
    /// </summary>
    public static string BenimHekimim(string hekimId) =>
        $"(exists (select 1 from public.dis_hekim_temsilci d where d.hekim_id = {hekimId} and d.temsilci_id = {Kullanici}"
      + " and coalesce(d.aktif, 1) = 1 and d.baslangic <= current_date and (d.bitis is null or d.bitis >= current_date))"
      + $" or exists (select 1 from public.taraf th where th.id = {hekimId} and th.temsilci = {Kullanici}))";
}
