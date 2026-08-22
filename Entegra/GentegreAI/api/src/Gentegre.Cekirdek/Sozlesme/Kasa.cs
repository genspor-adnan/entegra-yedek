using System.Text.Json;

namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>
/// API §9 - kasa (mali) islem kaydetme istegi.
///
/// BACAKLAR OPSIYONELDIR. Normal akista istemci yalnizca BASLIGI gonderir
/// (tur, hesap, cari, tutar, masraf); bacaklari sunucu islem turunun
/// SABLONUNDAN uretir (fn_kasa_islem_bacak_uret). Bacak listesi ancak serbest
/// mahsup (coklu kalem, elle dagitim) icin doldurulur - o zaman da denge
/// kurali (K5) aynen gecerlidir.
///
/// Istemci yerel (TL) tutar GONDERMEZ: kur x tutar hesabi sunucuda yapilir,
/// aksi halde ekranda gorunen ile muhasebeye giren tutar ayrisabilir.
/// </summary>
public sealed class KasaIslemYazmaIstegi
{
    public string? Surum { get; set; }
    public Dictionary<string, JsonElement>? Islem { get; set; }
    public List<Dictionary<string, JsonElement>>? Bacaklar { get; set; }
    public KasaSecenekleri Secenekler { get; set; } = new();
}

public sealed class KasaSecenekleri
{
    /// <summary>Taslak: makbuz numarasi TUKETILMEZ, fis yazilmaz (durum 0).</summary>
    public bool Taslak { get; set; }

    /// <summary>Plan (beklenen tahsilat/odeme): durum 1, bakiyeye girmez, fis yok.</summary>
    public bool Plan { get; set; }

    /// <summary>Kur bulunamazsa 422 ver (kapali: kur 1 varsayilir + uyari).</summary>
    public bool KurKontrolu { get; set; } = true;

    /// <summary>Tahsilat/odeme bu belgeyi kapatiyorsa (F4 kapatma).</summary>
    public int? BelgeId { get; set; }
}

public sealed class KasaIslemYaniti
{
    public IDictionary<string, object?> Islem { get; set; } = new Dictionary<string, object?>();
    public IReadOnlyList<IDictionary<string, object?>> Bacaklar { get; set; }
        = Array.Empty<IDictionary<string, object?>>();
    public FisOzeti? Fis { get; set; }
    public IReadOnlyList<string> Uyarilar { get; set; } = Array.Empty<string>();
    public string IzlemeNo { get; set; } = "";
}

public sealed class FisOzeti
{
    public int Id { get; set; }
    public string FisNo { get; set; } = "";
    public DateTime FisTarihi { get; set; }
    public int Tur { get; set; }
    public int Durum { get; set; }
    public decimal ToplamBorc { get; set; }
    public decimal ToplamAlacak { get; set; }
    public IReadOnlyList<FisSatiriOzeti> Satirlar { get; set; } = Array.Empty<FisSatiriOzeti>();
}

public sealed record FisSatiriOzeti(
    int Sira,
    string HesapKodu,
    string HesapAdi,
    decimal Borc,
    decimal Alacak,
    string DovizCinsi,
    decimal DovizBorc,
    decimal DovizAlacak,
    string Aciklama);

/// <summary>Katalog kaydi - ekran tur sekmelerini ve bacak sablonunu bundan cizer.</summary>
public sealed class KasaIslemTuru
{
    public int Kod { get; set; }
    public string Ad { get; set; } = "";
    public string Grup { get; set; } = "";
    public int Yon { get; set; }
    public string AnaHesapTuru { get; set; } = "";
    public string KarsiHesapTuru { get; set; } = "";
    public int CariZorunlu { get; set; }
    public int KalemTuru { get; set; }
    public bool PlanMi { get; set; }
    public bool FisMi { get; set; }
    public int FisTuru { get; set; }
    public string MakbuzBasligi { get; set; } = "";
    public JsonElement Sablon { get; set; }
}

/// <summary>kasa_islem.durum kod uzayi (DB check ile ayni).</summary>
public static class KasaDurum
{
    public const int Taslak      = 0;
    public const int Planli      = 1;
    public const int Gerceklesti = 2;
    public const int Iptal       = 3;
    public const int PlanKapandi = 4;
}
