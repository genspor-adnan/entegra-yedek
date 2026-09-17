namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUM kartı — anlaşmalı kurum, sigorta, SGK.
///
/// KartKatalogu.Cari.cs dosyasindan ayrildi: tek dosyada 1140 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
    // -------------------------------------------------------------- kurum ----
    /// <summary>
    /// ANLASMALI KURUM karti (249, kullanici: "hastanenin sozlesme yaptigi
    /// kurumlarin listesi... bunlar da bir nevi musteri, hastanin odemesini
    /// yapacak"). Cari kartinin turevi - kurum da fatura edilen, tahsilat
    /// yapilan bir caridir; ayri bir kart tipi acmak ayni alanlari ikinci kez
    /// tanimlamak olurdu. Farki: iki sekme (sozlesme basligi + fiyat politikasi
    /// satirlari) ve `kurum = 1` rol bayragi.
    /// </summary>
    private static KartTanimi Kurum()
    {
        var c = Cari();
        var alanlar = c.Alanlar.Select(a => a.Ad switch
        {
            "kod"   => a with { Baslik = "Kurum Kodu" },
            "unvan" => a with { Baslik = "Kurum Adı" },
            // CARI KAMPANYASI KURUMDA GIZLI (kullanici): kurumun fiyat kurali
            //   SOZLESMEDEN gelir (taraf_kurum.kampanya_id). Ayni kartta iki
            //   kampanya alani gorunmesi "hangisi gecerli" sorusunu doguruyordu -
            //   cozum sirasi zaten sozlesme > cari > genel (fn_taraf_kampanya),
            //   yani kurumda cari alani hicbir zaman kazanmaz.
            "kampanyaId" => a with { Gizli = true },
            // CRM ALANLARI KURUMDA GIZLI (484, kullanici: "kurum karti
            //   tanimlamalardan kaldirilacaklar: ilk temas, sektor, alt
            //   sektor, bolge"). Bunlar SATIS TAKIBI alanlaridir - kurumun
            //   "hangi fuarda tanistik", "hangi sektorde" bilgisi anlasmali
            //   kurum kaydinda karsiligi olmayan sorulardir; bir sigorta
            //   sirketinin sektoru sorulmaz. Kolonlar DURUYOR ve degerler
            //   TASINIYOR (Gizli): cari olarak girilmis eski kayitlarin
            //   verisi kaydetmede silinmesin.
            "ilkTemas" or "sektor" or "altSektor" or "bolge" => a with { Gizli = true },
            // ÜTS KURUM NO KURUMDA GIZLI (484, kullanici). KUN, ÜTS verme
            //   bildiriminde (225) MALIN TESLIM EDILDIGI saglik tesisini
            //   tanimlar - tibbi cihaz alicisi carinin alanidir. Anlasmali
            //   kurum (sigorta / SGK) mal teslim alan taraf degil, odemeyi
            //   yapan taraftir; kartinda karsiligi olmayan bir soruydu.
            //   Kolon DURUYOR, deger TASINIYOR: ayni taraf hem tedarikci hem
            //   anlasmali kurum olabilir, kurum kartindan kaydetmek onun ÜTS
            //   numarasini silmesin.
            "utsKurumNo" => a with { Gizli = true },
            // KISI ALANLARI VE ROL KUTULARI KURUMDA GIZLI (484, kullanici:
            //   "ad, soyad, kisi, musteri, tedarikci check'lerini kaldir").
            //   Ad/Soyad ve "Kişi" bir GERCEK KISI carisinin alanlaridir -
            //   kurumun unvani vardir, adi soyadi yoktur. Musteri/Tedarikci
            //   ise cari ROLLERI: anlasmali kurumun rolu zaten `kurum`
            //   bayragidir ve kart onu kendisi yaziyor; kutuyu kullaniciya
            //   sormak, isaretini kaldirmasi hâlinde kurumu kendi listesinden
            //   dusurebilecegi anlamina geliyordu.
            //   Degerler TASINIYOR (Gizli): ayni taraf hem tedarikci hem
            //   anlasmali kurum olabilir - kurum kartindan kaydetmek oteki
            //   rolunu silmesin.
            "ad" or "soyad" or "kisi" or "musteri" or "tedarikci" => a with { Gizli = true },
            // TEMSILCI ILE KURUM TURU YER DEGISTIRDI (484, kullanici).
            //   Kimlik seridinde artik KURUM TURU duruyor: hangi anlasma
            //   kurallarinin isleyecegini (Ozel / OSS / SGK) o belirler,
            //   kurumun en temel bilgisidir. Temsilci satis takibi alanidir -
            //   Tanımlama kutusuna indi.
            "temsilci" => a with { Grup = null, AltGrup = "Tanımlama" },
            _ => a
        }).ToList();
        alanlar.Add(new KartAlani("kurum", "kurum", "mantik", Baslik: "Kurum", Gizli: true));

        var detaylar = (c.Detaylar ?? Array.Empty<DetayTanimi>()).ToList();
        // KURUM TURU 1:1 kalir - kurumun kendisine ait tek bilgi (468).
        //   Sozlesmeye ait ne varsa asagidaki 1:N gride tasindi.
        detaylar.Add(new DetayTanimi("kurumRolu", "public.taraf_kurum", "id", new KartAlani[]
        {
            new("id",  "id",  "sayi", Yazilabilir: false),
            new("tur", "tur", "kod",  Zorunlu: true,
                KodListesi: "taraf.kurum_turu", Baslik: "Kurum Türü"),
        }, SubeKolonu: null, Baslik: "Kurum Türü", LogTabloId: 1265, TekSatir: true));

        // SOZLESMELER - 1:N (468, kullanici: "alt kurum sozlesmeye bagli;
        //   birden fazla sozlesme varsa hasta secer"). Ayni sigorta sirketiyle
        //   OSS, TSS ve Karma police ayri sartlarla calisilir; tek satira
        //   sigdirmak kurumu uc kez cari acmayi gerektiriyordu.
        detaylar.Add(new DetayTanimi("sozlesmeler", "public.kurum_sozlesme", "kurum_id",
        new KartAlani[]
        {
            new("id",  "id",  "sayi", Yazilabilir: false),
            new("ad",  "ad",  "metin", EnFazlaUzunluk: 120, Baslik: "Sözleşme"),
            // ALT KURUM = police turu (OSS/TSS/Karma) ya da SGK'da devredilen
            //   kurum. Lookup kurum TURUNE gore suzulur (v_alt_kurum_lookup.ust_id).
            new("altKurum", "alt_kurum", "kod",
                KodTablosu: "public.v_alt_kurum_lookup", Baslik: "Alt Kurum / Poliçe"),
            new("sozlesmeNo", "sozlesme_no", "metin", EnFazlaUzunluk: 60, Baslik: "Sözleşme No"),
            new("baslangic",  "baslangic",   "tarih", Baslik: "Başlama"),
            new("bitis",      "bitis",       "tarih", Baslik: "Bitiş"),
            new("durum",      "durum",       "mantik", Baslik: "Aktif"),
            // HASTANENIN FIYATI: kuruma uygulanan tarife (TTB/HUV ya da ozel).
            //   Adi "Fiyat Listesi" (587, kullanici) - kartin her yerinde ayni
            //   sey "fiyat listesi" diye geciyor, tek yerde "tarife" demek
            //   ikinci bir kavram varmis gibi duruyordu.
            //   Lookup TARIFE TIPINI tasir (`ust_id`); ekran kurum turune
            //   uymayan listeleri gizler - SGK sozlesmesine Özel tarifesi
            //   secilmesi sessiz yanlis fiyatlandirmadir.
            new("fiyatListesiId", "fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_tarife_lookup",
                UstBilgisi: true, Baslik: "Fiyat Listesi"),
            // KAMPANYA FIYAT LISTESININ SAGINDA (kullanici): ikisi de "bu kuruma
            //   hangi fiyat uygulanir" sorusunun parcasi - liste taban, kampanya
            //   onun uzerindeki indirim. SUT listesi ve SGK carisi ayri bir
            //   konudur, arkaya duser.
            new("kampanyaId", "kampanya_id", "kod",
                KodTablosu: "public.v_kampanya_lookup", Baslik: "Kampanya"),
            // SUT listesi: SGK bedeli + katilim payi + EK KATKI kurali. Ek
            //   katki artik listede (kullanici: "fiyat listesine koysak daha
            //   anlasilir olur") - sozlesmede sayi tutulmaz.
            //   Combo YALNIZ SUT tarifeli listeleri gosterir (kullanici): bu alan
            //   SGK'nin odedigi bedeli tasir, oraya Özel ya da TTB listesi
            //   secmek sessiz yanlis provizyon demektir. Suzme ekranda,
            //   lookup'in tarife tipi (`ust_id`) uzerinden.
            new("sgkFiyatListesiId", "sgk_fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_tarife_lookup",
                UstBilgisi: true, Baslik: "SUT Listesi"),
            // SGK payinin faturalanacagi cari: TSS/Karma'da odeyen kurumdan
            //   FARKLIDIR (sigorta sirketi ile SGK ayri kayitlardir).
            new("sgkKurumId", "sgk_kurum_id", "kod",
                KodTablosu: "public.v_kurum_lookup", Baslik: "SGK Carisi"),
            new("faturalamaModu", "faturalama_modu", "kod",
                KodListesi: "kurum.faturalama_modu", Baslik: "Faturalama"),
            new("varsayilanKarsilama", "varsayilan_karsilama", "para",
                Baslik: "Varsayılan Karşılama %"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
        }, SubeKolonu: "sube_id", Sirala: "alt_kurum, id", Baslik: "Sözleşmeler",
           LogTabloId: 1264));


        return c with
        {
            Ad = "kurum",
            YetkiKodu = "kurum",
            SabitKosul = "kurum = 1",
            YeniKayitVarsayilanlari = new Dictionary<string, object?>
            {
                ["kurum"] = (short)1,
                // Kurum AYNI ZAMANDA MUSTERI: basvuru/faturada cari olarak
                //   secilebilsin, cari hesabi ve ekstresi calissin.
                ["musteri"] = (short)1,
                ["durum"] = (short)1
            },
            Alanlar = alanlar.ToArray(),
            Detaylar = detaylar.ToArray()
        };
    }
}
