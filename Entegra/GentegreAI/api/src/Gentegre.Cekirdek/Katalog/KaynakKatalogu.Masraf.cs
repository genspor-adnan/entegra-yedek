namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MASRAF BEYANI VE BELGE TALEBİ LİSTELERİ (764 / 765).
///
/// İKİSİNİN ASIL SORUSU FARKLI. Masrafta soru "ne kadar ve kaç belge" -
/// onaylayan tutarı belgeye bakarak değerlendirir. Belge talebinde soru
/// "ne zaman hazır olacak" - orada onay bir formalite, bekleyen şey yazının
/// kendisidir. Bu yüzden ikisi aynı kolon düzenini paylaşmıyor.
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> MasrafDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylandı",
        ["3"] = "Reddedildi", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> BelgeTalepDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Hazırlanacak",
        ["3"] = "Reddedildi", ["4"] = "Hazırlandı", ["5"] = "Teslim Edildi",
        ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> BelgeTalepTurKodlari = new()
    {
        ["1"] = "Çalışma Belgesi", ["2"] = "Maaş Yazısı", ["3"] = "Vize Yazısı",
        ["4"] = "SGK Hizmet Dökümü", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> TeslimSekliKodlari = new()
    {
        ["1"] = "Elden", ["2"] = "e-Posta", ["3"] = "Kargo",
    };

    private static KaynakTanimi PersonelMasrafKaynagi() => new(
        Ad: "personelMasraf",
        YetkiKodu: "ik.masraf",
        Kaynak: "public.v_personel_masraf v",
        SubeKolonu: "v.sube_id",
        // AÇIK OLANLAR ÖNCE: karara bağlanmış beyan arşivdir.
        VarsayilanSirala: "case when v.durum in (0, 1) then 0 else 1 end," +
                          " v.beyan_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("beyanNo", "v.beyan_no", "metin", "Beyan No", Genislik: 120,
                Varsayilan: false),
            new("personelAd", "v.personel_ad", "metin", "Personel", Genislik: 200),
            new("gorevAd", "v.gorev_ad", "metin", "Görev", Genislik: 150,
                Varsayilan: false),
            new("amirAd", "v.amir_ad", "metin", "Âmiri", Genislik: 160,
                Varsayilan: false),
            new("beyanTarihi", "v.beyan_tarihi", "tarih", "Beyan", Hizalama: "orta",
                Genislik: 110),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 260),
            new("toplamTutar", "v.toplam_tutar", "para", "Tutar", Hizalama: "sag",
                Genislik: 120),
            // BELGE SAYISI: tutar tek başına beyanı anlatmaz - "3.000 TL /
            //   1 belge" ile "3.000 TL / 12 belge" farklı şeylerdir.
            new("satirSayisi", "v.satir_sayisi", "sayi", "Belge", Hizalama: "sag",
                Genislik: 80),
            // GEÇ BEYAN unutulmuş masraftır: en eski harcama ile beyan tarihi
            //   arasındaki fark denetimde ilk bakılan yerdir.
            new("ilkHarcama", "v.ilk_harcama", "tarih", "İlk Harcama",
                Hizalama: "orta", Genislik: 110, Varsayilan: false),
            new("durumAdi",
                "case v.durum when 0 then 'Taslak' when 1 then 'Onayda'" +
                " when 2 then 'Onaylandı' when 3 then 'Reddedildi'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "v.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: MasrafDurumKodlari),
            new("bekleyenBasamak", "coalesce(v.bekleyen_basamak, '')", "metin",
                "Bekleyen", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("redNeden", "v.red_neden", "metin", "Red Nedeni", Genislik: 240,
                Varsayilan: false),
            new("tarafId", "v.taraf_id", "sayi", "Personel Id", Varsayilan: false),
        });

    private static KaynakTanimi BelgeTalepKaynagi() => new(
        Ad: "personelBelgeTalep",
        YetkiKodu: "ik.belge_talep",
        Kaynak: "public.v_personel_belge_talep v",
        SubeKolonu: "v.sube_id",
        // BEKLEYEN ÖNCE, sonra en eski: personelin beklediği şey yazının
        //   kendisi - en uzun bekleyen en üstte olmalı.
        VarsayilanSirala: "case when v.durum in (1, 2, 4) then 0 else 1 end," +
                          " v.talep_tarihi",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("talepNo", "v.talep_no", "metin", "Talep No", Genislik: 120,
                Varsayilan: false),
            new("personelAd", "v.personel_ad", "metin", "Personel", Genislik: 200),
            new("gorevAd", "v.gorev_ad", "metin", "Görev", Genislik: 150,
                Varsayilan: false),
            new("talepTarihi", "v.talep_tarihi", "tarih", "Talep", Hizalama: "orta",
                Genislik: 110),
            new("turAdi", "v.tur_adi", "metin", "Belge Türü", Genislik: 150),
            new("tur", "v.tur", "kod", "Tür Kodu", Varsayilan: false,
                Kodlar: BelgeTalepTurKodlari),
            // AMAÇ yazının METNİNİ belirler - listede görünmezse İK her
            //   talebi açmak zorunda kalır.
            new("amac", "v.amac", "metin", "Amaç", Genislik: 220),
            new("muhatap", "v.muhatap", "metin", "Muhatap", Genislik: 180,
                Varsayilan: false),
            new("adet", "v.adet", "sayi", "Nüsha", Hizalama: "sag", Genislik: 70,
                Varsayilan: false),
            new("teslimSekli", "v.teslim_sekli", "kod", "Teslim", Hizalama: "orta",
                Genislik: 90, Kodlar: TeslimSekliKodlari, Varsayilan: false),
            new("durumAdi",
                "case v.durum when 0 then 'Taslak' when 1 then 'Onayda'" +
                " when 2 then 'Hazırlanacak' when 3 then 'Reddedildi'" +
                " when 4 then 'Hazırlandı' when 5 then 'Teslim Edildi'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "v.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: BelgeTalepDurumKodlari),
            // BEKLEME GÜNÜ teslime kadar işler: onay değil belge bekleniyor.
            new("beklemeGun", "v.bekleme_gun", "sayi", "Bekleme (gün)",
                Hizalama: "sag", Genislik: 110),
            new("otomatikOnay", "v.otomatik_onay", "mantik", "Otomatik",
                Hizalama: "orta", Genislik: 90, Varsayilan: false),
            new("hazirlayanAd", "v.hazirlayan_ad", "metin", "Hazırlayan",
                Genislik: 160, Varsayilan: false),
            new("teslimTarihi", "v.teslim_tarihi", "zaman", "Teslim",
                Hizalama: "orta", Genislik: 130, Varsayilan: false),
            new("redNeden", "v.red_neden", "metin", "Red Nedeni", Genislik: 220,
                Varsayilan: false),
            new("tarafId", "v.taraf_id", "sayi", "Personel Id", Varsayilan: false),
        });
}
