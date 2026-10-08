namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BANKO LİSTESİ (985, Ekranlar/Kayıt Kabul/banko_tanimi_v2.html).
///
/// POS SAYISI ÇALIŞAN CİHAZI SAYAR (durum = 1): "3 POS'u var" diyen bir
/// sütun, üçü de arızalıyken yanıltıcıdır - gün içinde kart geçmeyen banko
/// listede dolu görünürdü.
///
/// KASASIZ BANKO (tür 2, Danışma) kasa hesabı ve POS beklemez; listede boş
/// görünür, eksiklik değildir.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi Banko() => new(
        Ad: "banko",
        YetkiKodu: "banko",
        Kaynak: @"public.banko b
                  left join public.hesap h on h.id = b.hesap_id
                  left join public.sube s on s.id = b.sube_id",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "b.id", "sayi", "Id", Varsayilan: false),
            new("kod", "b.kod", "metin", "Kod", Genislik: 100),
            new("ad", "b.ad", "metin", "Banko Adı", Genislik: 200),
            new("subeAd", "coalesce(s.ad, '')", "metin", "Şube", Genislik: 130),
            new("konum", "b.konum", "metin", "Konum", Genislik: 180),
            new("turAdi",
                "case b.tur when 1 then 'Kayıt kabul + kasa' when 2 then 'Danışma (kasasız)'" +
                " when 3 then 'Numune kabul + kasa' when 4 then 'Yalnız kasa' else '' end",
                "metin", "Tür", Genislik: 160, Bicim: "rozet", Filtrelenebilir: false),
            new("tur", "b.tur", "kod", "Tür Kodu", Varsayilan: false,
                Kodlar: KartKatalogu.BankoTuruKodlari),
            new("hesapAd", "coalesce(h.ad, '')", "metin", "Kasa Hesabı", Genislik: 170),
            // ÇALIŞAN POS SAYISI: arızalı cihaz sayılmaz (yukarıdaki not).
            new("posSayi",
                "(select count(*) from public.banko_pos p where p.banko_id = b.id and p.durum = 1)",
                "sayi", "POS", Hizalama: "orta", Genislik: 70, Filtrelenebilir: false),
            new("posArizali",
                "(select count(*) from public.banko_pos p where p.banko_id = b.id and p.durum = 2)",
                "sayi", "Arızalı POS", Hizalama: "orta", Genislik: 100,
                Varsayilan: false, Filtrelenebilir: false),
            new("cihazSayi",
                "(select count(*) from public.banko_cihaz c where c.banko_id = b.id)",
                "sayi", "Cihaz", Hizalama: "orta", Genislik: 70,
                Varsayilan: false, Filtrelenebilir: false),
            new("varsayilanPos",
                @"coalesce((select coalesce(bk.ad, '') || ' · ' || p.terminal_no
                              from public.banko_pos p
                              left join public.banka bk on bk.id = p.banka_id
                             where p.banko_id = b.id and p.varsayilan = 1 limit 1), '')",
                "metin", "Varsayılan POS", Genislik: 170, Varsayilan: false,
                Filtrelenebilir: false),
            new("gunSonuSaat", "b.gun_sonu_saat", "metin", "Gün Sonu", Hizalama: "orta",
                Genislik: 90, Varsayilan: false),
            // ONAY AYARI LİSTEDE GÖRÜNÜR: "bu banko onaysız mı açılıyor"
            //   sorusu denetim sorusudur, kartı açmadan yanıtlanmalı.
            new("acilisOnay", "b.acilis_onay", "mantik", "Açılış Onayı", Hizalama: "orta",
                Genislik: 100, Varsayilan: false),
            new("gunSonuOnay", "b.gun_sonu_onay", "mantik", "Gün Sonu Onayı",
                Hizalama: "orta", Genislik: 110, Varsayilan: false),
            new("aktif", "b.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
        });
}
