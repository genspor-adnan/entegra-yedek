using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Cekirdek.Aktarim;

/// <summary>
/// DELPHI AKTARIMI - SALT OKUNUR KİP (1089, dokuman/18 §10): veri kaynağı Delphi iken
/// web'de yazılamayan kaynakların TEK listesi. Asıl kural veritabanında
/// (<c>trg_aktarim_salt_okunur</c>) - her yazma yolu orada reddedilir; bu liste
/// yalnız ekranın kapalı düğmeyi baştan göstermesi için (kart yetkisi, araç çubuğu).
/// Kararlar: web'e özgü ekler (not, ek belge, görev) açık; e-Belge Delphi'de;
/// yeni kayıt kapalı - taraf'ta yalnız CARİ (kişi / personel / hasta web'in).
/// </summary>
public static class AktarilanKaynaklar
{
    /// <summary>Delphi'den gelen tablolar (1089 tetiğiyle aynı küme).</summary>
    public static readonly IReadOnlySet<string> Tablolar = new HashSet<string>(StringComparer.Ordinal)
    {
        "public.taraf", "public.taraf_adres", "public.stok", "public.stok_barkod", "public.stok_fiyat",
        "public.stok_seri_lot", "public.stok_durum", "public.hizmet", "public.hizmet_fiyat", "public.masraf",
        "public.masraf_fiyat", "public.depo", "public.doviz_kur", "public.masraf_merkezi", "public.proje",
        "public.hesap", "public.kredi", "public.is_merkezi", "public.urun_agaci", "public.urun_agaci_satir",
        "public.urun_agaci_operasyon", "public.belge", "public.belge_satir", "public.stok_izleme",
        "public.mali_hareket", "public.kasa_islem",
    };

    /// <summary>Taraf kartlarından yalnız bunlar Delphi'nin (cari rolü).</summary>
    private static readonly IReadOnlySet<string> CariKartlari = new HashSet<string>(StringComparer.Ordinal) { "cari" };

    /// <summary>Yazma aksiyonu kapanan ekran yetki kodları (tam ad).</summary>
    private static readonly IReadOnlySet<string> Kodlar = new HashSet<string>(StringComparer.Ordinal)
    {
        "belge", "belge_satir", "cari", "cari.tedarikci", "depo", "doviz_kur", "hesap", "hizmet",
        "kasa_islem", "kasa.finans", "masraf", "masraf_merkezi", "proje", "stok",
        "uretim.is_merkezi", "uretim.urun_agaci",
    };

    /// <summary>Önek: bütün alış / satış / stok / kurum belgeleri ve hesap tanımları (".ayar" hariç).</summary>
    private static readonly string[] Onekler = ["belge.alis", "belge.satis", "belge.stok", "belge.kurum_", "hesap.tanim"];

    public static bool KartKapali(KartTanimi k)
        => Tablolar.Contains(k.Tablo) && (k.Tablo != "public.taraf" || CariKartlari.Contains(k.Ad));

    public static bool YetkiKapali(string? kod)
        => kod is not null && !kod.EndsWith(".ayar", StringComparison.Ordinal)
           && (Kodlar.Contains(kod) || Onekler.Any(o => kod.StartsWith(o, StringComparison.Ordinal)));

    /// <summary>Kaynak kodu olmayan yazma aksiyonları (belge / kasa akışı, e-Belge gönderimi).</summary>
    private static readonly IReadOnlySet<string> KapaliAksiyonYetkileri = new HashSet<string>(StringComparer.Ordinal)
    {
        "ebelge.gonder", "belge.iptal", "belge.donustur", "belge.kesinlestir",
        "kasa.iptal", "kasa.kesinlestir", "kasa.gerceklestir", "stok",
    };

    /// <summary>Delphi kipinde pasif gösterilecek aksiyon: aktarılan kaynağa yazan ya da e-Belge (karar 2).</summary>
    public static bool AksiyonKapali(AksiyonTanimi a)
        => a.Grup.Equals("ebelge", StringComparison.OrdinalIgnoreCase)
           || (a.Islem != Yetki.Islem.Gor && YetkiKapali(a.KaynakKodu))
           || (a.AksiyonYetkisi is { } y && KapaliAksiyonYetkileri.Contains(y));

    public const string Mesaj = "Bu kayıt Delphi ERP'den gelir; değişikliği Delphi'de yapın.";
}
