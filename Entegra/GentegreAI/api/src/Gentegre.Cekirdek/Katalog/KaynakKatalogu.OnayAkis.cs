namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ONAY AKIŞI LİSTESİ (742).
///
/// LİSTE "BU AKIŞ İŞLİYOR MU" SORUSUNU YANITLAR: basamak sayısı, yürüyen
/// onay, geciken. Yalnız ad ve kod gösterseydik akış listesi bir sözlük
/// olurdu - oysa yöneticinin sorusu kuralın kendisi değil, sonucu.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi OnayAkisKaynagi() => new(
        Ad: "onayAkis",
        YetkiKodu: "kullanici",
        Kaynak: "public.v_onay_akis v",
        // ŞUBE SÜZMESİ YOK: akış KURUM GENELİ bir tanımdır - imza düzeni
        //   şubeye göre değişmez. Süzseydik şubesiz (kurum geneli) tanımlar
        //   listede hiç görünmezdi; nitekim ilk denemede liste boş geldi.
        SubeKolonu: null,
        VarsayilanSirala: "v.aktif desc, v.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("kod", "v.kod", "metin", "Akış Kodu", Genislik: 170),
            new("ad", "v.ad", "metin", "Adı", Genislik: 230),
            new("kaynakTurAdi",
                "case v.kaynak_tur when 1241 then 'Satınalma Talebi' else 'Bilinmiyor' end",
                "metin", "Hangi Kayıt", Genislik: 170, Bicim: "rozet",
                Filtrelenebilir: false),
            new("kaynakTur", "v.kaynak_tur", "sayi", "Kayıt Türü", Varsayilan: false),
            new("olcuAdi", "v.olcu_adi", "metin", "Karar Ölçüsü", Genislik: 140),
            new("basamak", "v.basamak", "sayi", "Basamak", Hizalama: "sag", Genislik: 90),
            // TABAN BASAMAK SIFIRSA küçük kayıt hiç imzasız geçer - listede
            //   görünmeli, kart açmadan.
            new("tabanBasamak", "v.taban_basamak", "sayi", "Her Kayıtta",
                Hizalama: "sag", Genislik: 110),
            new("yuruyen", "v.yuruyen", "sayi", "Yürüyen", Hizalama: "sag", Genislik: 90),
            new("geciken", "v.geciken", "sayi", "Geciken", Hizalama: "sag", Genislik: 90),
            new("sonKullanim", "v.son_kullanim", "tarih", "Son Kullanım",
                Hizalama: "orta", Genislik: 120, Bicim: "dd.MM.yyyy HH:mm"),
            new("aktif", "v.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 280,
                Varsayilan: false),
        });
}
