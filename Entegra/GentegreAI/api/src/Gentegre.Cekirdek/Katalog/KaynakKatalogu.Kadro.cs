namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KADRO HAREKETLERİ (840) — personelin pozisyon geçmişi.
///
/// <para>Kullanıcı: *"personelin pozisyon değişikliklerini kronolojik olarak
/// nasıl takip ederiz"*. `taraf_personel` yalnız bugünkü hâli tutuyordu;
/// `islem_log` denetim iziydi (yürürlük tarihi yok, tam fotoğraf yok).</para>
///
/// <para><b>Satır = o tarihteki tam pozisyon.</b> Liste varsayılanı en yeni
/// yürürlük - kadro defteri geriye doğru okunur.</para>
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> KadroTurKodlari = new()
    {
        ["1"] = "İşe giriş", ["2"] = "Terfi / unvan", ["3"] = "Birim değişikliği",
        ["4"] = "Yönetici değişikliği", ["5"] = "Şube nakli",
        ["6"] = "Çalışma şekli / sözleşme", ["7"] = "Vekâlet (süreli)",
        ["8"] = "Ücretsiz izin / askı", ["9"] = "İşten çıkış", ["10"] = "İşe dönüş",
        ["99"] = "Diğer",
    };

    /// <summary>Hareketin nereden geldiği: elle mi, karttan mı, göçten mi.</summary>
    internal static readonly Dictionary<string, string> KadroKaynakKodlari = new()
    {
        ["1"] = "Elle", ["2"] = "Karttan", ["3"] = "Dolgu",
    };

    private static KaynakTanimi PersonelHareketKaynagi() => new(
        Ad: "personel-hareket",
        YetkiKodu: "ik.kadro",
        Kaynak: "public.v_personel_hareket v",
        SubeKolonu: "v.sube_id",
        // EN YENİ YÜRÜRLÜK ÖNCE: "şu an ne" ve "en son ne değişti" aynı
        //   yerden okunur; ileri tarihliler de tepede durur ki gözden
        //   kaçmasın.
        VarsayilanSirala: "v.yururluk desc, v.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("tarafId", "v.taraf_id", "sayi", "Personel Id", Varsayilan: false),
            new("personelAd", "v.personel_ad", "metin", "Personel", Genislik: 200),
            new("sicilNo", "v.sicil_no", "metin", "Sicil", Genislik: 90, Varsayilan: false),
            new("yururluk", "v.yururluk", "tarih", "Yürürlük", Hizalama: "orta",
                                                   Genislik: 110),
            new("turAdi", "v.tur_adi", "metin", "Hareket", Genislik: 150,
                Bicim: "rozet", Filtrelenebilir: false),
            new("tur", "v.tur", "kod", "Tür Kodu", Kodlar: KadroTurKodlari,
                Varsayilan: false),
            // GOREV: serbest metin kolonu neredeyse hep bos (katalog gorevi
            //   `gorev_id`de) - hucre bos gorunuyordu. Once serbest metin,
            //   yoksa katalog adi (842).
            new("gorev", "case when coalesce(v.gorev, '') <> '' then v.gorev "
                       + "else coalesce(v.gorev_adi, '') end",
                "metin", "Görev / unvan", Genislik: 180, Filtrelenebilir: false),
            new("departmanAdi", "v.departman_adi", "metin", "Bölüm", Genislik: 150,
                Filtrelenebilir: false),
            new("yoneticiAd", "v.yonetici_ad", "metin", "Yönetici", Genislik: 160,
                Filtrelenebilir: false),
            new("subeAdi", "v.sube_adi", "metin", "Şube", Genislik: 130,
                Filtrelenebilir: false),
            new("bitis", "v.bitis", "tarih", "Bitiş", Hizalama: "orta", Genislik: 110),
            // DURUM ROZETİ: "bugün geçerli olan hangisi" listeden okunmalı -
            //   defterde on satır varken kartta duran birisidir.
            new("durumAdi",
                "case when v.gecerli = 1 then 'Geçerli' "
                + "when v.ileri = 1 then 'İleri tarihli' "
                + "when v.sureli = 1 then 'Süresi doldu' else 'Geçmiş' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("gecerli", "v.gecerli", "mantik", "Geçerli", Varsayilan: false),
            new("ileri", "v.ileri", "mantik", "İleri tarihli", Varsayilan: false),
            new("kararNo", "v.karar_no", "metin", "Karar No", Genislik: 110,
                Varsayilan: false),
            new("gerekce", "v.gerekce", "metin", "Gerekçe", Genislik: 220,
                Varsayilan: false),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
            // KAYNAK ADIYLA: kod sozlugu suzgec combosunu besliyor ama
            //   hucrede ham sayi ("1") kaliyordu - satirda ne oldugu
            //   okunmuyordu.
            new("kaynakAdi",
                "case v.kaynak when 1 then 'Elle' when 2 then 'Karttan' "
                + "when 3 then 'Dolgu' else '' end",
                "metin", "Kaynak", Hizalama: "orta", Genislik: 90,
                Filtrelenebilir: false),
            new("kaynak", "v.kaynak", "kod", "Kaynak Kodu", Kodlar: KadroKaynakKodlari,
                Varsayilan: false),
            new("eklemeTarihi", "v.ekleme_tarihi", "tarih", "Kayıt", Genislik: 120,
                Varsayilan: false),
            // İleri tarihli satır soluk değil DİKKAT çekmeli: henüz
            //   yürürlüğe girmemiş bir terfi gözden kaçmasın.
            new("satirRengi",
                "case when v.ileri = 1 then 'uyari' when v.gecerli = 1 then 'olumlu' "
                + "else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });
}
