namespace Gentegre.Cekirdek.Katalog;

public static partial class KaynakKatalogu
{
    /// <summary>
    /// SKRS EŞLEME MASASI - HİZMET -> SUT (1222, mockup Ekranlar/Aktarim/skrs_esleme_masasi.html; kullanıcı 01.11.2026:
    /// "eski müşterilerde gelişigüzel hizmet listeleri.. bakanlığın (SKRS) standardına oturtmak istiyorum").
    /// Satır = aktarılmış eski hizmet; adaylar fn_skrs_hizmet_adaylari'dan (jsonb, puanlı), karar durum / seçilen kod.
    /// Yetki: hizmet kartını değiştirebilen (kullanıcı kararı) - liste okuması hizmet kodunun Gör'ü.
    /// </summary>
    private static KaynakTanimi AktarimEslemeHizmet() => new(
        Ad: "aktarim-esleme-hizmet",
        YetkiKodu: "hizmet",
        Kaynak: "public.aktarim_esleme e left join public.skrs_sut ss on ss.kod = e.secilen_kod",
        SabitKosul: "e.liste = 'hizmet'",
        SubeKolonu: null,
        VarsayilanSirala: "e.uygulandi, e.kullanim desc, e.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "e.id",        "sayi",  "Id", Varsayilan: false),
            new("tur",        "e.tur",       "metin", "Tür", Hizalama: "orta", Bicim: "rozet", Genislik: 70),
            new("eskiKod",    "e.eski_kod",  "metin", "Eski kod", Genislik: 100),
            new("eskiAd",     "e.eski_ad",   "metin", "Eski ad", Genislik: 230),
            new("kullanim",   "e.kullanim",  "sayi",  "Kullanım", Hizalama: "sag", Genislik: 80),
            new("adayKod",    "coalesce(e.adaylar->0->>'kod', '')", "metin", "Öneri kodu", Genislik: 90),
            new("adayAd",     "coalesce(e.adaylar->0->>'ad', '')",  "metin", "Bakanlık önerisi (SUT)", Genislik: 260),
            new("adayPuan",   "coalesce((e.adaylar->0->>'puan')::numeric, 0)", "ondalik", "Güven", Hizalama: "sag",
                Bicim: "0.00", Genislik: 70),
            new("dikkat",     "coalesce(e.adaylar->0->>'dikkat', '')", "metin", "Dikkat", Bicim: "uyari", Genislik: 180),
            new("durumAdi",
                "case when e.uygulandi = 1 then 'Uygulandı' when e.durum = 1 then 'Onaylı' when e.durum = 2 then 'Kuruma özel' " +
                "     when e.durum = 4 then 'Yön ailesi' " +
                "     when e.durum = 3 then 'Aday yok' when e.adaylar->0->>'dikkat' is not null or coalesce((e.adaylar->0->>'puan')::numeric, 0) < 0.8 " +
                "     then 'Bakılmalı' else 'Onay bekliyor' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("durum",      "e.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("uygulandi",  "e.uygulandi", "mantik", "Uygulandı", Varsayilan: false),
            new("guvenKod",
                "case when e.durum <> 0 then 0 when e.adaylar->0->>'dikkat' is not null then 3 " +
                "     when coalesce((e.adaylar->0->>'puan')::numeric, 0) >= 0.8 then 1 else 2 end",
                "kod", "Güven Kodu", Varsayilan: false),
            new("secilenKod", "coalesce(e.secilen_kod, '')", "metin", "Seçilen kod", Genislik: 90),
            // YÖN AİLESİ (1232): eski yönsüz hizmetin SUT ailesi ("MRG, DİZ" - sağ / sol × kontrast) - kod istemde çözülür.
            new("aile",       "coalesce(e.aile->>'kok', '')", "metin", "Yön ailesi", Genislik: 150),
            new("secilenAd",  "coalesce(ss.ad, '')", "metin", "Seçilen (SUT)", Genislik: 220),
            new("notlar",     "e.notlar",    "metin", "Not", Varsayilan: false),
            new("modalite",   "e.modalite",  "kod",   "Modalite", Varsayilan: false),
            new("kayitId",    "e.kayit_id",  "sayi",  "Hizmet Id", Varsayilan: false),
        });

    /// <summary>
    /// SKRS EŞLEME MASASI - BÖLÜM / BRANŞ (1224): eski serbest metin (POLIKLINIK / UZMANLIK) -> departman (SKRS kodlu bölüm)
    /// ya da SKRS branş (hekim.brans). Kullanım = eski başvuru / hekim sayısı. Karar 2 = yok say (bölüm / branş değil).
    /// </summary>
    private static KaynakTanimi AktarimEslemeMetin(string liste, string hedefAdSql, string hedefJoin, string onerBaslik) => new(
        Ad: "aktarim-esleme-" + liste,
        YetkiKodu: "hizmet",
        Kaynak: "public.aktarim_esleme e " + hedefJoin,
        SabitKosul: $"e.liste = '{liste}'",
        SubeKolonu: null,
        VarsayilanSirala: "e.uygulandi, e.kullanim desc, e.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "e.id",        "sayi",  "Id", Varsayilan: false),
            new("eskiAd",    "e.eski_ad",   "metin", liste == "bolum" ? "Eski poliklinik" : "Eski uzmanlık", Genislik: 220),
            new("kullanim",  "e.kullanim",  "sayi",  liste == "bolum" ? "Başvuru" : "Hekim", Hizalama: "sag", Genislik: 80),
            new("adayAd",    "coalesce(e.adaylar->0->>'ad', '')", "metin", onerBaslik, Genislik: 280),
            new("adayPuan",  "coalesce((e.adaylar->0->>'puan')::numeric, 0)", "ondalik", "Güven", Hizalama: "sag",
                Bicim: "0.00", Genislik: 70),
            new("notlar",    "e.notlar",    "metin", "Not", Bicim: "uyari", Genislik: 220),
            new("durumAdi",
                "case when e.uygulandi = 1 then 'Uygulandı' when e.durum = 1 then 'Onaylı' when e.durum = 2 then 'Yok sayıldı' " +
                "     when e.durum = 3 then 'Aday yok' when coalesce((e.adaylar->0->>'puan')::numeric, 0) < 0.8 then 'Bakılmalı' " +
                "     else 'Onay bekliyor' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("durum",     "e.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("uygulandi", "e.uygulandi", "mantik", "Uygulandı", Varsayilan: false),
            new("guvenKod",
                "case when e.durum <> 0 then 0 when coalesce((e.adaylar->0->>'puan')::numeric, 0) >= 0.8 then 1 else 2 end",
                "kod", "Güven Kodu", Varsayilan: false),
            new("secilenAd", hedefAdSql, "metin", "Seçilen", Genislik: 240),
            new("secilenKod", "coalesce(e.secilen_kod, '')", "metin", "Seçilen kod", Varsayilan: false),
        });

    private static KaynakTanimi AktarimEslemeBolum() => AktarimEslemeMetin("bolum",
        "coalesce(dp.ad || coalesce(' · ' || nullif(dp.kod, ''), ''), '')",
        "left join public.departman dp on e.secilen_kod ~ '^[0-9]+$' and dp.id = e.secilen_kod::int",
        "Önerilen bölüm (SKRS kodu)");

    private static KaynakTanimi AktarimEslemeBrans() => AktarimEslemeMetin("brans",
        "coalesce(bk.ad, '')",
        "left join lateral (select d.ad from public.kod_deger d join public.kod_liste kl on kl.id = d.liste_id " +
        "                    where kl.kod = 'hekim.brans' and d.dil = 0 and d.deger::text = e.secilen_kod limit 1) bk on true",
        "Önerilen SKRS branşı");
}
