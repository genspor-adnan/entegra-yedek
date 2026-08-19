namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Satir tutari hesabi. Delphi ile KURUSU KURUSUNA ayni olmak zorunda
/// (plan F1-05 kabul olcutu), bu yuzden formul birebir kopyalanmistir:
///
///   UFaturaWizard.TutarIslemler (satir 4366-4380):
///     TUTAR = KusuratAyarla(hane,
///               ((100 - ISKONTO)/100) *
///               ((100 - ISKONTO2)/100) *
///               KusuratAyarla(hane, ADET * BIRIMFIYAT))
///
/// UC KRITIK AYRINTI - "sadelestirilirse" sonuc kayar:
///   1. IC YUVARLAMA: adet * birim_fiyat ONCE yuvarlanir, iskonto ONDAN SONRA
///      uygulanir. Tek adimda carpmak farkli kurus verir.
///   2. IKI ISKONTO CARPIMSAL (kademeli), toplamsal degil: %10 + %10 = %19 indirim.
///   3. YUVARLAMA BICIMI: Delphi'nin Round'u banker's rounding'dir (yariyi cift
///      sayiya). .NET'te karsiligi MidpointRounding.ToEven - Math.Round varsayilani.
///      MidpointRounding.AwayFromZero kullanmak Delphi ile farkli sonuc verir.
/// </summary>
public static class BelgeHesap
{
    /// <summary>Tutar alani numeric(24,2) - varsayilan hane 2 (Ops: OndalikDijitSayTut).</summary>
    public const int VarsayilanHane = 2;

    public static decimal Yuvarla(decimal deger, int hane = VarsayilanHane)
        => Math.Round(deger, hane, MidpointRounding.ToEven);

    /// <summary>Delphi TutarIslemler ile birebir satir tutari.</summary>
    public static decimal SatirTutari(decimal adet, decimal birimFiyat,
                                      decimal iskonto = 0, decimal iskonto2 = 0,
                                      int hane = VarsayilanHane)
    {
        var brut = Yuvarla(adet * birimFiyat, hane);          // IC yuvarlama
        var net  = brut * ((100m - iskonto) / 100m)
                        * ((100m - iskonto2) / 100m);          // CARPIMSAL iskonto
        return Yuvarla(net, hane);
    }

    /// <summary>
    /// Yerel tutarin doviz karsiligi. Karar (19.08.2026): TL islemde de dolu
    /// tutulur (kur = 1), bos birakilmaz.
    /// </summary>
    public static decimal DovizKarsiligi(decimal tutar, decimal kur, int hane = 4)
        => kur <= 0 ? tutar : Yuvarla(tutar / kur, hane);

    /// <summary>Doviz birim fiyattan yerel birim fiyat (Delphi: BIRIMFIYAT = DOVIZ_BIRIMFIYAT * KUR).</summary>
    public static decimal YerelBirimFiyat(decimal dovizBirimFiyat, decimal kur, int hane = 6)
        => Yuvarla(dovizBirimFiyat * kur, hane);
}
