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
            // VARSAYILAN POS HESAP ADIYLA (992): banka alani kalkti, POS
            //   kendi tahsilat hesabiyla taniniyor.
            new("varsayilanPos",
                @"coalesce((select coalesce(ph.ad, '') || ' · ' || p.terminal_no
                              from public.banko_pos p
                              left join public.hesap ph on ph.id = p.hesap_id
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

    /// <summary>
    /// BANKO OTURUMLARI (987) — vardiya geçmişi. Fark eğilimi buradan okunur:
    /// aynı görevlide tekrarlayan noksan, eğitim ya da denetim konusudur.
    /// Oturum kaydı silinmez; akış ekranı (banko-oturum) yazar, bu liste okur.
    /// </summary>
    private static KaynakTanimi BankoOturum() => new(
        Ad: "bankoOturum",
        YetkiKodu: "banko_oturum",
        Kaynak: @"public.v_banko_oturum_ozet o
                  left join public.taraf t on t.id = o.kullanici_id
                  left join public.taraf ta on ta.id = o.teslim_alan_id",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "o.id", "sayi", "Oturum", Genislik: 90),
            new("bankoKod", "o.banko_kod", "metin", "Banko", Genislik: 100),
            new("bankoAd", "o.banko_ad", "metin", "Banko Adı", Genislik: 180),
            new("gorevli", "coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')",
                "metin", "Görevli", Genislik: 170, Filtrelenebilir: false),
            new("vardiya", "o.vardiya", "metin", "Vardiya", Genislik: 110),
            new("durumAdi",
                "case o.durum when 1 then 'Açılış onayı bekliyor' when 2 then 'Açık'" +
                " when 3 then 'Teslime gönderildi' when 4 then 'Kapandı'" +
                " when 5 then 'Reddedildi' else '' end",
                "metin", "Durum", Genislik: 150, Bicim: "rozet", Filtrelenebilir: false),
            new("durum", "o.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: KartKatalogu.OturumDurumKodlari),
            new("acilisTs", "o.acilis_ts", "zaman", "Açılış", Genislik: 140),
            new("kapanisTs", "o.kapanis_ts", "zaman", "Kapanış", Genislik: 140),
            new("devirTutar", "o.devir_tutar", "para", "Devir", Genislik: 110),
            new("acilisFark", "o.acilis_fark", "para", "Açılış Farkı", Genislik: 110),
            new("nakitTahsilat", "o.nakit_tahsilat", "para", "Nakit", Genislik: 110),
            new("posTutar", "o.pos_tutar", "para", "POS", Genislik: 110),
            new("islemAdet", "o.islem_adet", "sayi", "İşlem", Hizalama: "orta", Genislik: 80),
            new("kapanisSayim", "o.kapanis_sayim", "para", "Sayım", Genislik: 110),
            // FARK İŞARETLİ: eksi = noksan. Tek kolonda iki soru yanıtlanıyor.
            new("kapanisFark", "o.kapanis_fark", "para", "Fark", Genislik: 110),
            new("kasadaBirakilan", "o.kasada_birakilan", "para", "Bırakılan", Genislik: 110,
                Varsayilan: false),
            new("teslimEdilen", "o.teslim_edilen", "para", "Teslim", Genislik: 110,
                Varsayilan: false),
            new("teslimAlan", "coalesce(public.fn_taraf_ad(ta.unvan, ta.ad, ta.soyad)::varchar(120), '')",
                "metin", "Teslim Alan", Genislik: 170, Varsayilan: false, Filtrelenebilir: false),
            new("tutanakNo", "o.tutanak_no", "metin", "Tutanak", Genislik: 130, Varsayilan: false),
            new("farkAciklama", "o.fark_aciklama", "metin", "Fark Notu", Genislik: 240,
                Varsayilan: false),
        });
}
