using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Gentegre.Cekirdek.Uts;

/// <summary>
/// ÜTS SERVİS MODELLERİ - istek/cevap record'ları (UTSModels katmanı).
///
/// Sözleşme (TakipVeIzlemeWebServisTanimlariDokumani Rev 1.99): alan adları
/// ÜÇ HARFLİ BÜYÜK kodlardır (UNO/LNO/SNO/ADT/GIT/BNO/KUN/VBI...). Boş ya da
/// verilmeyen alan JSON'a HİÇ yazılmaz - null da yazılmaz; bu yüzden tüm
/// istek alanları nullable ve serileştirme <see cref="Json"/> seçenekleriyle
/// (WhenWritingNull) yapılır. Kural: BOŞ STRING ATANMAZ, null bırakılır.
///
/// Cevap zarfı ortak: SNC (bildirimlerde GUID metin - sayı DEĞİL) + MSJ[]
/// (TIP = BILGI / UYARI / HATA). Delphi'deki Models.pas'ın karşılığı; RTTI
/// mapper yerine System.Text.Json.
/// </summary>
public static class UtsJson
{
    /// <summary>Tek serileştirme ayarı: null alan yazılmaz, Türkçe kaçışsız.</summary>
    public static readonly JsonSerializerOptions Ayarlar = new()
    {
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };
}

// ------------------------------------------------------------ istekler ----

/// <summary>Alma bildirimi (s37): VBI = karşı tarafın verme bildirimi GUID'i.</summary>
public sealed record UtsAlmaIstek(
    [property: JsonPropertyName("VBI")] string? Vbi,
    [property: JsonPropertyName("UNO")] string? Uno = null,
    [property: JsonPropertyName("LNO")] string? Lno = null,
    [property: JsonPropertyName("SNO")] string? Sno = null,
    [property: JsonPropertyName("ADT")] decimal? Adt = null);

/// <summary>Verme bildirimi (s33): KUN = alan kurumun ÜTS numarası.</summary>
public sealed record UtsVermeIstek(
    [property: JsonPropertyName("UNO")] string? Uno,
    [property: JsonPropertyName("KUN")] string? Kun,
    [property: JsonPropertyName("BNO")] string? Bno,
    [property: JsonPropertyName("LNO")] string? Lno = null,
    [property: JsonPropertyName("SNO")] string? Sno = null,
    [property: JsonPropertyName("ADT")] decimal? Adt = null,
    [property: JsonPropertyName("GIT")] string? Git = null);

/// <summary>Kullanım bildirimi (s47): hasta/tüketici alanları serbest bırakıldı
/// (HBYS entegrasyonu ileride; ilk sürümde elle girilir).</summary>
public sealed record UtsKullanimIstek(
    [property: JsonPropertyName("UNO")] string? Uno,
    [property: JsonPropertyName("GIT")] string? Git,
    [property: JsonPropertyName("LNO")] string? Lno = null,
    [property: JsonPropertyName("SNO")] string? Sno = null,
    [property: JsonPropertyName("ADT")] decimal? Adt = null,
    [property: JsonPropertyName("TKN")] string? Tkn = null,   // hasta TCKN
    [property: JsonPropertyName("YKN")] string? Ykn = null,   // yabancı kimlik
    [property: JsonPropertyName("PAN")] string? Pan = null,   // pasaport
    [property: JsonPropertyName("HAA")] string? HastaAdi = null,
    [property: JsonPropertyName("HAS")] string? HastaSoyadi = null);

/// <summary>Bildirim iptali (s96): BID = ÜTS bildirim GUID'i. Gövde yalnız bu.</summary>
public sealed record UtsIptalIstek(
    [property: JsonPropertyName("BID")] string Bid);

/// <summary>Tekil ürün sorgusu (s99).</summary>
public sealed record UtsTekilUrunSorgu(
    [property: JsonPropertyName("UNO")] string? Uno,
    [property: JsonPropertyName("LNO")] string? Lno = null,
    [property: JsonPropertyName("SNO")] string? Sno = null);

/// <summary>Askıdakiler /offset (s120): OFF önceki cevaptan gelen imleç,
/// ADT kayıt sayısı (en çok 500).</summary>
public sealed record UtsAskidakilerSorgu(
    [property: JsonPropertyName("KUN")] string? Kun = null,
    [property: JsonPropertyName("UNO")] string? Uno = null,
    [property: JsonPropertyName("LNO")] string? Lno = null,
    [property: JsonPropertyName("SNO")] string? Sno = null,
    [property: JsonPropertyName("BNO")] string? Bno = null,
    [property: JsonPropertyName("ADT")] int? Adt = null,
    [property: JsonPropertyName("OFF")] string? Off = null);

/// <summary>Askıdakiler sayfalı düşüş ucu (s118): SAN = 10'luk sayfa no.</summary>
public sealed record UtsAskidakilerSayfaSorgu(
    [property: JsonPropertyName("SAN")] int San,
    [property: JsonPropertyName("KUN")] string? Kun = null,
    [property: JsonPropertyName("UNO")] string? Uno = null);

/// <summary>Bildirim detay sorgusu (s156): kendi bildirimimizin ÜTS kaydı.</summary>
public sealed record UtsBildirimDetaySorgu(
    [property: JsonPropertyName("BID")] string Bid);

// ------------------------------------------------------------- cevaplar ----

/// <summary>Cevap mesajı: TIP = BILGI / UYARI / HATA.</summary>
public sealed record UtsMesaj(
    [property: JsonPropertyName("TIP")] string? Tip,
    [property: JsonPropertyName("MET")] string? Met,
    [property: JsonPropertyName("KOD")] string? Kod);

/// <summary>Askıdaki satır (verme/askidakiler LST elemanı, s118).</summary>
public sealed record UtsAskidakiSatir(
    [property: JsonPropertyName("UNO")] string? Uno,
    [property: JsonPropertyName("LNO")] string? Lno,
    [property: JsonPropertyName("SNO")] string? Sno,
    [property: JsonPropertyName("BNO")] string? Bno,
    [property: JsonPropertyName("KUN")] object? Kun,     // sayı ya da metin dönebiliyor
    [property: JsonPropertyName("ADT")] decimal? Adt,
    [property: JsonPropertyName("BID")] string? Bid,
    [property: JsonPropertyName("BTI")] string? Bti,     // VERME / GECICI_VERME / GERI_CEKME_VERME
    [property: JsonPropertyName("BZA")] long? Bza,       // UNIX ms
    [property: JsonPropertyName("AKU")] string? Aku,     // veren kurum unvanı
    [property: JsonPropertyName("MME")] string? Mme);    // marka/model
