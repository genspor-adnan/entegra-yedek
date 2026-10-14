namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PATOLOJİ LİSTELERİ (1104) — vakalar (dış lab + kurum içi ORTAK), dış lab
/// gönderimi ve tanımlar (materyal tipi, boya / antikor, ret nedeni).
///
/// Mockup: Ekranlar/Patoloji/patoloji_vakalar.html, patoloji_gonderim.html,
/// KurumIci/patoloji_arsiv_tanimlar.html (Tanımlar).
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Vaka durum adı (pat_vaka.durum) - liste, kart ve uçlar aynı metni kullanır.</summary>
    internal const string PatVakaDurumSql =
        "case v.durum when 0 then 'İptal' when 1 then 'İstendi' when 2 then 'Hazırlandı' "
        + "when 3 then 'Gönderildi' when 4 then 'Kabul edildi' when 5 then 'Makroskopide' "
        + "when 6 then 'Doku takibinde' when 7 then 'Kesit / boyama' when 8 then 'Mikroskopide' "
        + "when 9 then 'Ek inceleme' when 10 then 'Ön rapor' "
        + "when 11 then case when v.calisma_yeri = 1 then 'Rapor geldi · görülmedi' else 'Onaylandı · görülmedi' end "
        + "when 12 then 'Hekim gördü' when 90 then 'Reddedildi' else '' end";

    /// <summary>
    /// VAKALAR — tek liste, iki iş yeri. "Nerede" vakanın kim tarafından
    /// çalışıldığıdır; TAT lab kabulünden rapora sayılır (gönderim → kabul ayrı).
    /// </summary>
    private static KaynakTanimi PatolojiVaka() => new(
        Ad: "patoloji-vaka",
        YetkiKodu: "patoloji.vaka",
        Kaynak: "public.pat_vaka v "
              + "  join public.taraf h on h.id = v.hasta_id "
              + "  left join public.taraf i on i.id = v.isteyen_id "
              + "  left join public.lab_dis_lab d on d.id = v.dis_lab_id "
              + "  left join public.departman b on b.id = v.bolum_id "
              + "  left join public.pat_gonderim g on g.id = v.gonderim_id",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.istem_zamani desc, v.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("vakaNo", "v.vaka_no", "metin", "Vaka", Hizalama: "orta", Genislik: 120),
            new("nerede", "case v.calisma_yeri when 2 then '🏠 Kurum içi' else '🚚 ' || coalesce(d.ad, 'Dış lab') end",
                "metin", "Nerede", Genislik: 190, Filtrelenebilir: false),
            new("calismaYeri", "v.calisma_yeri", "kod", "Nerede Kodu", Varsayilan: false),
            new("labNo", "case when v.calisma_yeri = 2 then v.patoloji_no else v.lab_vaka_no end",
                "metin", "Lab / Patoloji No", Hizalama: "orta", Genislik: 130),
            new("hastaAdi", "public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120)", "metin", "Hasta", Genislik: 170),
            new("hastaId", "v.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
            new("materyal",
                "coalesce((select string_agg(coalesce(t.ad, '') || case when m.lokalizasyon <> '' then ' · ' || m.lokalizasyon else '' end, ', ' order by m.harf) "
                + "from public.pat_materyal m left join public.pat_materyal_tipi t on t.id = m.materyal_tipi_id where m.vaka_id = v.id), '')",
                "metin", "Materyal", Genislik: 240, Filtrelenebilir: false, Siralanabilir: false),
            new("kapSayisi", "(select count(*) from public.pat_materyal m where m.vaka_id = v.id)",
                "sayi", "Kap", Hizalama: "orta", Genislik: 60, Filtrelenebilir: false),
            new("turAdi", "case v.tur when 2 then 'Sitoloji' when 3 then 'Frozen' when 4 then 'Konsültasyon' else 'Histopatoloji' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 110, Filtrelenebilir: false),
            new("tur", "v.tur", "kod", "Tür Kodu", Varsayilan: false),
            new("isteyen", "coalesce(public.fn_taraf_ad(i.unvan, i.ad, i.soyad)::varchar(120), '')", "metin", "İsteyen", Genislik: 150),
            new("bolum", "coalesce(b.ad, '')", "metin", "Bölüm", Genislik: 140, Varsayilan: false),
            new("istemZamani", "v.istem_zamani", "tarih", "İstem", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 125),
            new("kabulZamani", "v.kabul_zamani", "tarih", "Kabul", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 125),
            // TAT: kabulden bugüne (rapor geldiyse rapora) geçen gün / sözleşme günü.
            new("tat",
                "case when v.kabul_zamani is null then '' else "
                + "((coalesce(v.rapor_zamani, now())::date - v.kabul_zamani::date))::text || ' / ' || "
                + "coalesce((select max(t.tat_gun) from public.pat_materyal m join public.pat_materyal_tipi t on t.id = m.materyal_tipi_id where m.vaka_id = v.id), d.pat_tat_gun, 3)::text || ' gün' end",
                "metin", "TAT", Hizalama: "orta", Genislik: 100, Filtrelenebilir: false, Siralanabilir: false),
            new("tatAsti",
                "case when v.kabul_zamani is not null and v.rapor_zamani is null and "
                + "(now()::date - v.kabul_zamani::date) > coalesce((select max(t.tat_gun) from public.pat_materyal m "
                + "join public.pat_materyal_tipi t on t.id = m.materyal_tipi_id where m.vaka_id = v.id), d.pat_tat_gun, 3) then 1 else 0 end",
                "mantik", "TAT Aşan", Varsayilan: false),
            new("ekOnayBekleyen", "(select count(*) from public.pat_ek_inceleme e where e.vaka_id = v.id and e.onay = 1)",
                "sayi", "Onay Bekleyen Ek İnceleme", Varsayilan: false),
            new("gonderimNo", "coalesce(g.gonderim_no, '')", "metin", "Gönderim", Hizalama: "orta", Genislik: 120, Varsayilan: false),
            new("durumAdi", PatVakaDurumSql, "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 170, Filtrelenebilir: false),
            new("durum", "v.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("onTani", "v.on_tani", "metin", "Ön Tanı", Genislik: 90, Varsayilan: false),
        });

    /// <summary>DIŞ LAB GÖNDERİMİ — paket (aynı laba gidecek vakalar), kurye, teslim.</summary>
    private static KaynakTanimi PatolojiGonderim() => new(
        Ad: "patoloji-gonderim",
        YetkiKodu: "patoloji.gonderim",
        Kaynak: "public.pat_gonderim g join public.lab_dis_lab d on d.id = g.dis_lab_id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "g.id", "sayi", "Id", Varsayilan: false),
            new("gonderimNo", "g.gonderim_no", "metin", "Gönderim", Hizalama: "orta", Genislik: 130),
            new("disLab", "d.ad", "metin", "Laboratuvar", Genislik: 200),
            new("disLabId", "g.dis_lab_id", "sayi", "Lab Id", Varsayilan: false),
            new("baglanti", "case d.baglanti_turu when 1 then 'API' when 2 then 'HL7' when 3 then 'FHIR' when 4 then 'Portal' else 'Elle' end",
                "metin", "Bağlantı", Hizalama: "orta", Bicim: "rozet", Genislik: 90, Filtrelenebilir: false),
            new("vakaSayisi", "(select count(*) from public.pat_vaka v where v.gonderim_id = g.id)",
                "sayi", "Vaka", Hizalama: "orta", Genislik: 60, Filtrelenebilir: false),
            new("kapSayisi", "(select count(*) from public.pat_materyal m join public.pat_vaka v on v.id = m.vaka_id where v.gonderim_id = g.id)",
                "sayi", "Kap", Hizalama: "orta", Genislik: 60, Filtrelenebilir: false),
            new("hazirlandi", "g.ekleme_tarihi", "tarih", "Hazırlandı", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 125),
            new("kurye", "g.kurye", "metin", "Kurye", Genislik: 150),
            new("iletim",
                "case g.iletim_durumu when 1 then '✔ ' || to_char(g.iletim_zamani, 'DD.MM HH24:MI') when 2 then '✖ hata' else '—' end",
                "metin", "Laba İletim", Hizalama: "orta", Genislik: 110, Filtrelenebilir: false),
            new("iletimDurumu", "g.iletim_durumu", "kod", "İletim Kodu", Varsayilan: false),
            new("teslimZamani", "g.teslim_zamani", "tarih", "Lab Kabul", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 125),
            new("durumAdi",
                "case when g.durum = 0 then 'İptal' when g.iletim_durumu = 2 and g.durum = 1 then 'İletilemedi' "
                + "when g.durum = 1 then 'Hazırlanıyor' when g.durum = 2 then 'Yolda' else 'Lab teslim aldı' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 130, Filtrelenebilir: false),
            new("durum", "g.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("aciklama", "g.aciklama", "metin", "Açıklama", Genislik: 220, Varsayilan: false),
        });

    private static KaynakTanimi PatolojiMateryalTipi() => new(
        Ad: "patoloji-materyal-tipi",
        YetkiKodu: "patoloji.tanim.materyal",
        Kaynak: "public.pat_materyal_tipi m left join public.lab_dis_lab d on d.id = m.dis_lab_id "
              + "left join public.hizmet z on z.id = m.hizmet_id",
        SubeKolonu: null,
        VarsayilanSirala: "m.sira asc, m.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "m.id", "sayi", "Id", Varsayilan: false),
            new("kod", "m.kod", "metin", "Kod", Hizalama: "orta", Genislik: 110),
            new("ad", "m.ad", "metin", "Materyal Tipi", Genislik: 220),
            new("vakaTuruAdi", "case m.vaka_turu when 2 then 'Sitoloji' when 3 then 'Frozen' when 4 then 'Konsültasyon' else 'Histopatoloji' end",
                "metin", "Vaka Türü", Hizalama: "orta", Genislik: 120, Filtrelenebilir: false),
            new("nerede", "case m.calisma_yeri when 2 then 'Kurum içi' else 'Dış lab' end", "metin", "Nerede", Hizalama: "orta", Genislik: 100, Filtrelenebilir: false),
            new("disLab", "coalesce(d.ad, '')", "metin", "Varsayılan Lab", Genislik: 180),
            new("tatGun", "m.tat_gun", "sayi", "TAT (gün)", Hizalama: "sag", Genislik: 90),
            new("hizmet", "coalesce(z.ad, '')", "metin", "Hizmet (ücret)", Genislik: 200),
            new("aktifAdi", "case m.aktif when 1 then 'Aktif' else 'Pasif' end", "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 80, Filtrelenebilir: false),
            new("aktif", "m.aktif", "kod", "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi PatolojiBoya() => new(
        Ad: "patoloji-boya",
        YetkiKodu: "patoloji.tanim.boya",
        Kaynak: "public.pat_boya b left join public.hizmet z on z.id = b.hizmet_id",
        SubeKolonu: null,
        VarsayilanSirala: "b.sira asc, b.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "b.id", "sayi", "Id", Varsayilan: false),
            new("ad", "b.ad", "metin", "Ad", Genislik: 180),
            new("turAdi", "case b.tur when 1 then 'Rutin' when 2 then 'Özel boya' when 3 then 'İHK' when 4 then 'Moleküler' else 'Ek kesit' end",
                "metin", "Tür", Hizalama: "orta", Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("tur", "b.tur", "kod", "Tür Kodu", Varsayilan: false),
            new("klon", "b.klon", "metin", "Klon", Hizalama: "orta", Genislik: 100),
            new("platform", "b.platform", "metin", "Platform", Genislik: 160),
            new("sonucBicimi", "b.sonuc_bicimi", "metin", "Sonuç Biçimi", Genislik: 180),
            new("kontrolDoku", "b.kontrol_doku", "metin", "Kontrol Doku", Genislik: 150),
            new("hizmet", "coalesce(z.ad, '')", "metin", "Hizmet (ücret)", Genislik: 180),
            new("aktifAdi", "case b.aktif when 1 then 'Aktif' else 'Pasif' end", "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 80, Filtrelenebilir: false),
            new("aktif", "b.aktif", "kod", "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi PatolojiRetNedeni() => new(
        Ad: "patoloji-ret-nedeni",
        YetkiKodu: "patoloji.tanim.ret",
        Kaynak: "public.pat_ret_nedeni r",
        SubeKolonu: null,
        VarsayilanSirala: "r.sira asc, r.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "r.id", "sayi", "Id", Varsayilan: false),
            new("ad", "r.ad", "metin", "Ret Nedeni", Genislik: 260),
            new("davranisAdi", "case r.davranis when 2 then 'Koşullu kabul' when 3 then 'Bekletilir · istem istenir' else 'Ret · hekime bildirim' end",
                "metin", "Davranış", Genislik: 220, Filtrelenebilir: false),
            new("aktifAdi", "case r.aktif when 1 then 'Aktif' else 'Pasif' end", "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 80, Filtrelenebilir: false),
            new("aktif", "r.aktif", "kod", "Aktif Kodu", Varsayilan: false),
        });
}
