namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// RADYOLOJİ ÇALIŞMA LİSTESİ (283) - modülün giriş ekranı.
///
/// Satır = istem kaydı. Rapor yazma, PACS açma ve onay buradan başlar; bu
/// yüzden liste hem klinik (modalite, çekim, rapor durumu) hem idari
/// (ödeyen kurum, protokol no) bilgiyi tek satırda gösterir.
///
/// Kaynak DOĞRUDAN TABLO (view değil): görünüm kolonları filtrelenebilir
/// olmalı ve şube süzmesi SubeKolonu ile yapılıyor - v_radyoloji_worklist
/// raporlama/dış sorgu için duruyor.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi RadyolojiIstem() => new(
        Ad: "radyoloji-istem",
        YetkiKodu: "radyoloji",
        Kaynak: "public.radyoloji_istem i " +
                "left join public.taraf  h  on h.id  = i.hasta_id " +
                "left join public.hizmet hz on hz.id = i.hizmet_id " +
                "left join public.taraf  ih on ih.id = i.istek_hekim_id " +
                "left join public.taraf  ik on ik.id = i.istek_kurum_id " +
                "left join public.belge  b  on b.id  = i.belge_id " +
                "left join public.taraf  ok on ok.id = b.odeyen_kurum_id " +
                "left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id " +
                "left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null " +
                "left join public.taraf  ry on ry.id = coalesce(r.onaylayan_id, r.yazan_id)",
        SubeKolonu: "i.sube_id",
        // ACİL en üstte, sonra en eski bekleyen: liste açılınca "önce neye
        //   bakmalıyım" sorusu sıralamayla cevaplanır.
        VarsayilanSirala: "i.oncelik desc, coalesce(i.cekim_tarihi, i.ekleme_tarihi) asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "i.id",              "sayi",  "Id",            Varsayilan: false),
            new("saat",          "coalesce(i.cekim_tarihi, i.ekleme_tarihi)",
                                                      "tarih", "Saat",          Hizalama: "orta",
                                                                                Bicim: "dd.MM.yyyy HH:mm",
                                                                                Genislik: 130),
            new("modaliteAdi",
                "case i.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' " +
                "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' " +
                "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                                      "metin", "Mod.",          Hizalama: "orta",
                                                                                Bicim: "rozet", Genislik: 80,
                                                                                Filtrelenebilir: false),
            new("modalite",      "i.modalite",        "kod",   "Modalite Kodu", Varsayilan: false),
            new("accessionNo",   "i.accession_no",    "metin", "Accession",     Genislik: 150),
            new("hastaAdi",      "coalesce(h.unvan, '')", "metin", "Hasta",     Genislik: 190),
            new("tetkikKodu",    "coalesce(hz.kod, '')",  "metin", "Tetkik Kodu", Varsayilan: false),
            new("tetkikAdi",     "coalesce(hz.ad, '')",   "metin", "Tetkik",    Genislik: 230),
            // İsteyen: iç hekim kayıtlıysa adı, değilse dış hekim serbest alanı.
            new("isteyen",
                "coalesce(nullif(ih.unvan, ''), nullif(i.dis_hekim_ad, ''), '')",
                                                      "metin", "İstem Yapan",   Genislik: 170,
                                                                                Filtrelenebilir: false),
            new("isteyenKurum",  "coalesce(ik.unvan, '')", "metin", "İsteyen Kurum",
                                                                                Genislik: 160, Varsayilan: false),
            new("odeyenKurum",   "coalesce(ok.unvan, '')", "metin", "Ödeyen Kurum",
                                                                                Genislik: 170,
                                                                                Filtrelenebilir: false),
            new("oncelikAdi",
                "case i.oncelik when 2 then 'ACİL' else 'Normal' end",
                                                      "metin", "Öncelik",       Hizalama: "orta",
                                                                                Bicim: "rozet", Genislik: 85,
                                                                                Filtrelenebilir: false),
            new("oncelik",       "i.oncelik",         "kod",   "Öncelik Kodu",  Varsayilan: false),
            new("durumAdi",
                "case i.durum when 0 then 'İptal' when 1 then 'Bekliyor' " +
                "when 2 then 'Çekildi' when 3 then 'Raporlanıyor' when 4 then 'Ön Rapor' " +
                "when 5 then 'Onaylandı' when 6 then 'Teslim Edildi' else '' end",
                                                      "metin", "Durum",         Hizalama: "orta",
                                                                                Bicim: "rozet", Genislik: 110,
                                                                                Filtrelenebilir: false),
            new("durum",         "i.durum",           "kod",   "Durum Kodu",    Varsayilan: false),
            new("raporlayan",    "coalesce(ry.unvan, '')", "metin", "Radyolog", Genislik: 160,
                                                                                Filtrelenebilir: false),
            // Bekleme süresi kalite göstergesidir: acil bir tetkik ne kadar
            //   beklemiş, ekranı açan hemen görmeli.
            new("beklemeDk",
                "round(extract(epoch from (now()::timestamp " +
                "  - coalesce(i.cekim_tarihi, i.ekleme_tarihi))) / 60)::integer",
                                                      "sayi",  "Bekleme (dk)",  Hizalama: "sag",
                                                                                Genislik: 110,
                                                                                Filtrelenebilir: false),
            new("cihazAdi",      "coalesce(cz.ad, '')", "metin", "Cihaz",       Genislik: 150, Varsayilan: false),
            new("belgeNo",       "coalesce(b.belge_no, '')", "metin", "Protokol", Genislik: 120, Varsayilan: false),
            new("onTani",        "i.on_tani",         "metin", "Ön Tanı",       Genislik: 100, Varsayilan: false),
            new("studyUid",      "i.study_uid",       "metin", "Study UID",     Varsayilan: false),
            new("kritik",        "i.kritik",          "mantik","Kritik",        Hizalama: "orta",
                                                                                Varsayilan: false),
            new("hastaId",       "i.hasta_id",        "sayi",  "Hasta Id",      Varsayilan: false),
            new("belgeId",       "i.belge_id",        "sayi",  "Belge Id",      Varsayilan: false),
            new("raporId",       "r.id",              "sayi",  "Rapor Id",      Varsayilan: false),
            new("raporDurum",    "coalesce(r.durum, 0)", "kod", "Rapor Durum Kodu", Varsayilan: false),
        });
}
