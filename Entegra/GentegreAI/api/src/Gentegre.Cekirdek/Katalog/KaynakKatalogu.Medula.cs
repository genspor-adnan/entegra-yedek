namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MEDULA LİSTELERİ (707) — takipler, hizmet kayıtları, faturalar, dönemler,
/// kesintiler, raporlar, kuyruk. Özel sayfalar (hasta kabul, hizmet kaydı,
/// fatura & dönem, kuyruk) <c>/api/medula</c> uçlarından okur; bu listeler
/// menüdeki tarama/rapor görünümleridir.
/// </summary>
public static partial class KaynakKatalogu
{
    private const string MedulaTakipDurumAdi =
        "case coalesce(v.sgk_durum, 0) when 1 then case when v.sgk_cikis_zaman is null then 'Açık takip' else 'Kapatıldı' end "
        + "when 2 then 'Reddedildi' when 3 then 'Kısmi' when 4 then 'İptal' else 'Provizyon alınmadı' end";

    private static KaynakTanimi MedulaTakip() => new(
        Ad: "medula-takip",
        YetkiKodu: "medula",
        Kaynak: "public.v_medula_takip v",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.belge_id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "v.belge_id",       "sayi",  "Id", Varsayilan: false),
            new("belgeNo",     "v.belge_no",       "metin", "Başvuru", Genislik: 110),
            new("tarih",       "v.belge_tarihi",   "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("hasta",       "v.hasta_adi",      "metin", "Hasta", Genislik: 200),
            new("hastaId",     "v.hasta_id",       "sayi",  "Hasta Id", Varsayilan: false),
            new("hekim",       "coalesce(v.hekim_adi, '')", "metin", "Hekim", Genislik: 150),
            new("odeyen",      "coalesce(v.odeyen_adi, 'Ücretli')", "metin", "Ödeyen", Genislik: 140),
            new("takipNo",     "v.sgk_takip_no",   "metin", "Takip No", Genislik: 130),
            new("durumAdi",    MedulaTakipDurumAdi, "metin", "Takip Durumu", Hizalama: "orta", Bicim: "rozet", Genislik: 130, Filtrelenebilir: false),
            new("sgkDurum",    "coalesce(v.sgk_durum, 0)", "kod", "Durum Kodu", Varsayilan: false),
            new("mustehaklik", "case coalesce(v.sgk_mustehaklik, 0) when 1 then 'Müstehak' when 2 then 'Değil' else '—' end",
                "metin", "Müstehaklık", Hizalama: "orta", Bicim: "rozet", Genislik: 100, Filtrelenebilir: false),
            new("kabulIslem",  "v.kabul_islem",    "sayi",  "Kabul", Hizalama: "sag", Genislik: 70),
            new("hataliIslem", "v.hatali_islem",   "sayi",  "Hata", Hizalama: "sag", Genislik: 70),
            new("yerelTutar",  "v.yerel_tutar",    "para",  "Yerel Tutar", Hizalama: "sag"),
            new("medulaTutar", "v.medula_tutar",   "para",  "Medula Tutarı", Hizalama: "sag"),
            new("faturaNo",    "coalesce(v.medula_fatura_no, '')", "metin", "Fatura No", Genislik: 130),
            new("cikis",       "v.sgk_cikis_zaman", "tarih", "Çıkış", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("hataSayisi",  "v.hata_sayisi",    "sayi",  "Kuyruk Hatası", Hizalama: "sag", Genislik: 90, Varsayilan: false),
            new("acik",        "case when coalesce(v.sgk_durum, 0) = 1 and v.sgk_cikis_zaman is null then 1 else 0 end", "mantik", "Açık", Varsayilan: false),
            new("faturasiz",   "case when v.medula_fatura_id is null and v.sgk_cikis_zaman is not null and v.kabul_islem > 0 then 1 else 0 end",
                "mantik", "Fatura Bekliyor", Varsayilan: false),
        });

    private static KaynakTanimi MedulaIslem() => new(
        Ad: "medula-islem",
        YetkiKodu: "medula.hizmet",
        Kaynak: "public.medula_islem i join public.belge b on b.id = i.belge_id join public.taraf t on t.id = b.taraf_id left join public.taraf h on h.id = i.hekim_id",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "i.id",         "sayi",  "Id", Varsayilan: false),
            new("tarih",     "i.tarih",      "tarih", "Tarih", Hizalama: "orta"),
            new("takipNo",   "i.takip_no",   "metin", "Takip No", Genislik: 130),
            new("hasta",     "t.unvan",      "metin", "Hasta", Genislik: 190),
            new("belgeId",   "i.belge_id",   "sayi",  "Başvuru Id", Varsayilan: false),
            new("sutKodu",   "i.sut_kodu",   "metin", "SUT", Genislik: 80),
            new("islem",     "i.islem_adi",  "metin", "İşlem", Genislik: 240),
            new("adet",      "i.adet",       "sayi",  "Adet", Hizalama: "sag", Genislik: 60),
            new("tutar",     "i.tutar",      "para",  "Tutar", Hizalama: "sag"),
            new("hekim",     "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 150),
            new("tetkik",    "i.tetkik",     "mantik", "Tetkik", Hizalama: "orta", Genislik: 60),
            new("durumAdi",  "case i.durum when 1 then 'Bekliyor' when 2 then 'Kabul' when 3 then 'Hata' when 4 then 'İptal' when 5 then 'Ücretli' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 90, Filtrelenebilir: false),
            new("durum",     "i.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            new("sonuc",     "case when i.sonuc_kod = '' then '' else i.sonuc_kod || ' · ' || i.sonuc_mesaj end", "metin", "Sonuç", Genislik: 260, Filtrelenebilir: false),
        });

    private static KaynakTanimi MedulaFatura() => new(
        Ad: "medula-fatura",
        YetkiKodu: "medula.fatura",
        Kaynak: "public.v_medula_fatura f",
        SubeKolonu: "f.sube_id",
        VarsayilanSirala: "f.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "f.id",              "sayi",  "Id", Varsayilan: false),
            new("faturaNo",    "f.medula_fatura_no", "metin", "Fatura No", Genislik: 130),
            new("tarih",       "f.fatura_tarihi",   "tarih", "Tarih", Hizalama: "orta"),
            new("takipNo",     "f.takip_no",        "metin", "Takip No", Genislik: 130),
            new("hasta",       "f.hasta_adi",       "metin", "Hasta", Genislik: 190),
            new("hastaId",     "f.hasta_id",        "sayi",  "Hasta Id", Varsayilan: false),
            new("belgeId",     "f.belge_id",        "sayi",  "Başvuru Id", Varsayilan: false),
            new("hekim",       "f.hekim_adi",       "metin", "Hekim", Genislik: 140),
            new("turAdi",      "case f.fatura_turu when 1 then 'Ayaktan' when 2 then 'Yatan' when 3 then 'Günübirlik' when 4 then 'Acil' else '' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 90, Filtrelenebilir: false),
            new("donem",       "case when f.donem_yil is null then '' else f.donem_yil || '/' || lpad(f.donem_ay::text, 2, '0') end",
                "metin", "Dönem", Hizalama: "orta", Genislik: 80, Filtrelenebilir: false),
            new("yerelTutar",  "f.yerel_tutar",     "para",  "Yerel", Hizalama: "sag"),
            new("medulaTutar", "f.medula_tutar",    "para",  "Medula", Hizalama: "sag"),
            new("katilim",     "f.hasta_katilim",   "para",  "Katılım", Hizalama: "sag"),
            new("fark",        "f.fark",            "para",  "Fark", Hizalama: "sag"),
            new("kesinti",     "f.kesinti",         "para",  "Kesinti", Hizalama: "sag"),
            new("durumAdi",    "case f.durum when 1 then 'Taslak' when 2 then 'Kaydedildi' when 3 then 'Dönemde' when 4 then 'Dönem kapandı' "
                             + "when 5 then 'İncelendi' when 6 then 'Ödendi' when 7 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 120, Filtrelenebilir: false),
            new("durum",       "f.durum",           "kod",   "Durum Kodu", Varsayilan: false),
            new("sonuc",       "case when f.sonuc_kod = '' then '' else f.sonuc_kod || ' · ' || f.sonuc_mesaj end", "metin", "Sonuç", Genislik: 220, Filtrelenebilir: false),
        });

    private static KaynakTanimi MedulaDonem() => new(
        Ad: "medula-donem",
        YetkiKodu: "medula.fatura",
        Kaynak: "public.medula_donem d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.yil desc, d.ay desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "d.id",           "sayi",  "Id", Varsayilan: false),
            new("donem",       "d.yil || '/' || lpad(d.ay::text, 2, '0')", "metin", "Dönem", Hizalama: "orta", Genislik: 90, Filtrelenebilir: false),
            new("yil",         "d.yil",          "sayi",  "Yıl", Varsayilan: false),
            new("ay",          "d.ay",           "sayi",  "Ay", Varsayilan: false),
            new("faturaSayisi","d.fatura_sayisi","sayi",  "Fatura", Hizalama: "sag", Genislik: 80),
            new("toplam",      "d.toplam",       "para",  "Tutar", Hizalama: "sag"),
            new("kesinti",     "d.kesinti",      "para",  "Kesinti", Hizalama: "sag"),
            new("net",         "d.toplam - d.kesinti", "para", "Net", Hizalama: "sag"),
            new("odenen",      "d.odenen",       "para",  "Ödenen", Hizalama: "sag"),
            new("kalan",       "d.toplam - d.kesinti - d.odenen", "para", "Kalan", Hizalama: "sag"),
            new("sonlandirma", "d.sonlandirma",  "tarih", "Sonlandırma", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("icmalNo",     "d.icmal_no",     "metin", "İcmal", Genislik: 120),
            new("odemeTarihi", "d.odeme_tarihi", "tarih", "Ödeme", Hizalama: "orta"),
            new("durumAdi",    "case d.durum when 1 then 'Açık' when 2 then 'Sonlandırıldı' when 3 then 'İncelemede' when 4 then 'Kapandı' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("durum",       "d.durum",        "kod",   "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi MedulaKesinti() => new(
        Ad: "medula-kesinti",
        YetkiKodu: "medula.fatura",
        Kaynak: "public.medula_kesinti k join public.medula_fatura f on f.id = k.medula_fatura_id join public.taraf t on t.id = f.hasta_id left join public.medula_donem d on d.id = k.donem_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "k.id",              "sayi",  "Id", Varsayilan: false),
            new("faturaNo",    "f.medula_fatura_no", "metin", "Fatura No", Genislik: 130),
            new("hasta",       "t.unvan",           "metin", "Hasta", Genislik: 180),
            new("takipNo",     "f.takip_no",        "metin", "Takip", Genislik: 130),
            new("donem",       "case when d.id is null then '' else d.yil || '/' || lpad(d.ay::text, 2, '0') end", "metin", "Dönem", Hizalama: "orta", Genislik: 80, Filtrelenebilir: false),
            new("sutKodu",     "k.sut_kodu",        "metin", "SUT", Genislik: 80),
            new("kesintiKodu", "k.kesinti_kodu",    "metin", "Kod", Genislik: 70),
            new("aciklama",    "k.aciklama",        "metin", "Açıklama", Genislik: 240),
            new("tutar",       "k.tutar",           "para",  "Kesinti", Hizalama: "sag"),
            new("itirazAdi",   "case k.itiraz_durum when 1 then 'İtiraz edildi' when 2 then 'Kabul · iade' when 3 then 'Red' else 'Edilmedi' end",
                "metin", "İtiraz", Hizalama: "orta", Bicim: "rozet", Genislik: 120, Filtrelenebilir: false),
            new("itirazDurum", "k.itiraz_durum",    "kod",   "İtiraz Kodu", Varsayilan: false),
            new("iade",        "k.iade_tutar",      "para",  "İade", Hizalama: "sag"),
            new("itirazZaman", "k.itiraz_zaman",    "tarih", "İtiraz Tarihi", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
        });

    private static KaynakTanimi MedulaRapor() => new(
        Ad: "medula-rapor",
        YetkiKodu: "medula.recete",
        Kaynak: "public.medula_rapor r join public.taraf t on t.id = r.hasta_id left join public.taraf h on h.id = r.hekim_id",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "r.id",         "sayi",  "Id", Varsayilan: false),
            new("raporNo",   "r.rapor_no",   "metin", "Rapor No", Genislik: 120),
            new("hasta",     "t.unvan",      "metin", "Hasta", Genislik: 190),
            new("hastaId",   "r.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false),
            new("turAdi",    "case r.rapor_turu when 1 then 'İlaç' when 2 then 'Sevk' when 3 then 'İş göremezlik' when 4 then 'Malzeme' when 5 then 'Refakat' else '' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 100, Filtrelenebilir: false),
            new("raporTuru", "r.rapor_turu", "kod",   "Tür Kodu", Varsayilan: false),
            new("icdKod",    "r.icd_kod",    "metin", "ICD", Genislik: 70),
            new("tani",      "r.tani",       "metin", "Tanı", Genislik: 200),
            new("baslangic", "r.baslangic",  "tarih", "Başlangıç", Hizalama: "orta"),
            new("bitis",     "r.bitis",      "tarih", "Bitiş", Hizalama: "orta"),
            new("hekim",     "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 140),
            new("durumAdi",  "case r.durum when 1 then 'Taslak' when 2 then 'İmzalı' when 3 then 'Medula kabul' when 4 then 'İptal' when 5 then 'Hata' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("durum",     "r.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            new("sonuc",     "r.medula_sonuc", "metin", "Medula Sonucu", Genislik: 200, Filtrelenebilir: false),
        });

    private static KaynakTanimi MedulaKuyruk() => new(
        Ad: "medula-kuyruk",
        YetkiKodu: "medula",
        Kaynak: "public.v_medula_kuyruk q",
        SubeKolonu: "q.sube_id",
        VarsayilanSirala: "q.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "q.id",           "sayi",  "Id", Varsayilan: false),
            new("zaman",     "q.ekleme_tarihi","tarih", "Zaman", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("servis",    "q.servis",       "metin", "Servis", Genislik: 160),
            new("islem",     "q.islem",        "metin", "İşlem", Genislik: 150),
            new("kaynak",    "q.kaynak_tablo || ' ' || coalesce(q.kaynak_id::text, '')", "metin", "Kaynak", Genislik: 150, Filtrelenebilir: false),
            new("hasta",     "q.hasta_adi",    "metin", "Hasta", Genislik: 170),
            new("belgeId",   "q.belge_id",     "sayi",  "Başvuru Id", Varsayilan: false),
            new("durumAdi",  "case q.durum when 1 then 'Bekliyor' when 2 then 'Gönderildi' when 3 then 'Kabul' when 4 then 'Hata' when 5 then 'Elle müdahale' when 6 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("durum",     "q.durum",        "kod",   "Durum Kodu", Varsayilan: false),
            new("sonucKod",  "q.sonuc_kod",    "metin", "Kod", Hizalama: "orta", Genislik: 70),
            new("sonucMesaj","q.sonuc_mesaj",  "metin", "Mesaj", Genislik: 280),
            new("deneme",    "q.deneme",       "sayi",  "Deneme", Hizalama: "orta", Genislik: 70),
            new("sonraki",   "q.sonraki_deneme", "tarih", "Sonraki", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("sureMs",    "q.sure_ms",      "sayi",  "Süre (ms)", Hizalama: "sag", Genislik: 80),
            new("kullanici", "q.kullanici_adi","metin", "Kullanıcı", Genislik: 130),
        });
}
