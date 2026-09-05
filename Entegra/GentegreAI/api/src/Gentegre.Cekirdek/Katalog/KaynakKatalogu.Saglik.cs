namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MUAYENE ve LABORATUVAR listeleri (360).
///
/// Ikisi de kayit kabul zincirinin devamidir: basvuru (belge 19 / tipi 30)
/// acilir, ucret girilir, sonra hekim MUAYENE yazar ya da LAB ISTEMI acilir.
/// O yuzden listeler hastayi, protokolu ve hekimi tek satirda gosterir -
/// "kimin, hangi basvurudan" sorusu listede cevaplanabilsin.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi Muayene() => new(
        Ad: "muayene",
        YetkiKodu: "muayene",
        Kaynak: "public.muayene m "
              + "  join public.taraf h on h.id = m.taraf_id "
              + "  left join public.belge b on b.id = m.belge_id "
              + "  left join public.v_personel_lookup p on p.id = m.personel_id "
              + "  left join public.v_departman_lookup d on d.id = m.bolum_id",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "m.muayene_tarihi desc, m.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "m.id",             "sayi",  "Id", Varsayilan: false),
            new("muayeneNo",     "m.muayene_no",     "metin", "Muayene No", Hizalama: "orta",
                                                     Genislik: 120),
            new("muayeneTarihi", "m.muayene_tarihi", "tarih", "Tarih / Saat", Hizalama: "orta",
                                                     Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // Protokol: muayene hangi basvurudan dogdu - kabul ile klinigin bagi.
            new("protokolNo",    "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                     Hizalama: "orta", Genislik: 120),
            new("hastaAdi",      "h.unvan",          "metin", "Hasta", Genislik: 220),
            new("dosyaNo",       "h.kod",            "metin", "Dosya No", Hizalama: "orta",
                                                     Genislik: 110, Varsayilan: false),
            new("tcNo",          "coalesce(h.vkno, '')", "metin", "T.C. No", Hizalama: "orta",
                                                     Genislik: 110, Varsayilan: false),
            new("bolumAdi",      "coalesce(d.ad, '')", "metin", "Bölüm", Genislik: 150),
            new("hekimAdi",      "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 180),
            new("turAdi",
                "case m.tur when 2 then 'Uzaktan' when 3 then 'Konsültasyon' "
                + "when 4 then 'Kontrol' else 'Yüz Yüze' end",
                                                     "metin", "Tür", Hizalama: "orta",
                                                     Bicim: "rozet", Genislik: 120,
                                                     Filtrelenebilir: false),
            new("tur",           "m.tur",            "kod",   "Tür Kodu", Varsayilan: false),
            // TANI ARTIK SATIRDA (409): listede ANA tanı gösterilir - hekim
            //   listeye "hangi hasta neyle geldi" diye bakar, tanı kümesine
            //   değil. Ek tanılar kartın Tanı sekmesinde.
            new("anaTani",
                "coalesce((select i.ad from public.tani t "
                + "join public.icd i on i.kod = t.icd_kod "
                + "where t.muayene_id = m.id and t.tur = 1 limit 1), '')",
                                                     "metin", "Ana Tanı", Genislik: 240),
            new("anaTaniKodu",
                "coalesce((select t.icd_kod from public.tani t "
                + "where t.muayene_id = m.id and t.tur = 1 limit 1), '')",
                                                     "metin", "ICD", Hizalama: "orta",
                                                     Genislik: 100, Varsayilan: false),
            new("taniSayisi",
                "(select count(*) from public.tani t where t.muayene_id = m.id)",
                                                     "sayi",  "Tanı", Hizalama: "orta",
                                                     Genislik: 70, Varsayilan: false),
            // Bekleyen istem: "sonuç bekliyor" durumunun görünür karşılığı.
            new("bekleyenIstem",
                "(select count(*) from public.muayene_istem s "
                + "where s.muayene_id = m.id and s.sonuc_durum in (0, 1))",
                                                     "sayi",  "Bekleyen İstem", Hizalama: "orta",
                                                     Genislik: 120, Varsayilan: false),
            new("durumAdi",
                "case m.durum when 0 then 'İptal' when 2 then 'Sonuç Bekliyor' "
                + "when 3 then 'Tamamlandı' when 4 then 'Ek Not' else 'Açık' end",
                                                     "metin", "Durum", Hizalama: "orta",
                                                     Bicim: "rozet", Genislik: 130,
                                                     Filtrelenebilir: false),
            new("durum",         "m.durum",          "kod",   "Durum Kodu", Varsayilan: false),
            new("tarafId",       "m.taraf_id",       "sayi",  "Hasta Id", Varsayilan: false),
            new("belgeId",       "m.belge_id",       "sayi",  "Başvuru Id", Varsayilan: false),
            new("baslangic",     "m.baslangic",      "tarih", "Muayeneye Alındı",
                                                     Hizalama: "orta", Bicim: "HH:mm",
                                                     Genislik: 110, Varsayilan: false),
            new("tamamlanma",    "m.tamamlanma",     "tarih", "Tamamlandı", Hizalama: "orta",
                                                     Bicim: "HH:mm", Genislik: 110,
                                                     Varsayilan: false)
        });

    /// <summary>
    /// HEKİM ÇALIŞMA LİSTESİ (410, Faz 1) — hekimin gün içindeki işi.
    ///
    /// AYRI BİR TABLO YOK: liste kayıt kabulün açtığı başvurulardan (belge
    /// tür 19 + belge_basvuru) türer. Ayrı bir "çalışma listesi" tablosu,
    /// aynı hastanın iki yerde iki farklı durumda görünmesi demekti.
    ///
    /// Durum ÜÇ ZAMANDAN türetilir ve üçü ayrı soruların cevabıdır:
    /// kayıt (belge_tarihi) · çağırma (cagirma_zamani) · içeri giriş
    /// (muayene.baslangic). Tek alanla idare etmek hem "bekleme süresi"
    /// hem "muayene süresi" ölçüsünü kaybettirirdi.
    /// </summary>
    private static KaynakTanimi HekimCalismaListesi() => new(
        Ad: "hekim-listesi",
        YetkiKodu: "muayene",
        Kaynak: "public.belge b "
              + "  join public.belge_basvuru bb on bb.id = b.id "
              + "  join public.taraf h on h.id = b.taraf_id "
              + "  left join public.muayene m on m.belge_id = b.id and m.ust_muayene_id is null "
              + "  left join public.v_personel_lookup p on p.id = bb.personel_id "
              + "  left join public.v_departman_lookup d on d.id = bb.bolum_id "
              + "  left join public.taraf k on k.id = bb.odeyen_kurum_id",
        SabitKosul: "b.tur = 19 and coalesce(b.durum, 0) <> 2",
        SubeKolonu: "b.sube_id",
        // Once oncelik (acil/oncelikli), sonra kayit sirasi - listedeki sira
        //   cagirma sirasidir; kullanicinin siralamayi bilmesi gerekmesin.
        VarsayilanSirala: "bb.oncelik desc, b.belge_tarihi asc, b.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "b.id",              "sayi",  "Id", Varsayilan: false),
            new("siraNo",      "bb.sira_no",        "metin", "Sıra", Hizalama: "orta",
                                                    Genislik: 70),
            new("saat",        "b.belge_tarihi",    "tarih", "Saat", Hizalama: "orta",
                                                    Bicim: "HH:mm", Genislik: 70),
            new("protokolNo",  "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                    Hizalama: "orta", Genislik: 130),
            new("hastaAdi",    "h.unvan",           "metin", "Hasta", Genislik: 220),
            new("dosyaNo",     "h.kod",             "metin", "Dosya No", Hizalama: "orta",
                                                    Genislik: 110, Varsayilan: false),
            new("tcNo",        "coalesce(h.vkno, '')", "metin", "T.C. No", Hizalama: "orta",
                                                    Genislik: 110, Varsayilan: false),
            new("hekimAdi",    "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 170),
            new("bolumAdi",    "coalesce(d.ad, '')", "metin", "Bölüm", Genislik: 140),
            new("kurumAdi",    "coalesce(k.unvan, 'Özel')", "metin", "Kurum", Genislik: 150),
            new("oncelikAdi",
                "case bb.oncelik when 2 then 'Acil' when 1 then 'Öncelikli' else '' end",
                                                    "metin", "Öncelik", Hizalama: "orta",
                                                    Bicim: "rozet", Genislik: 90,
                                                    Filtrelenebilir: false),
            new("oncelik",     "bb.oncelik",        "kod",   "Öncelik Kodu",
                                                    Varsayilan: false),
            // BEKLEME: cagrilmadiysa SU ANA kadar, cagrildiysa cagirma anina
            //   kadar gecen sure. Cagrildiktan sonra da buyumeye devam etseydi
            //   liste "45 dk bekliyor" derken hasta iceride olurdu.
            new("beklemeDk",
                "greatest(0, (extract(epoch from "
                + "coalesce(bb.cagirma_zamani, now()) - b.belge_tarihi) / 60)::int)",
                                                    "sayi",  "Bekleme (dk)", Hizalama: "sag",
                                                    Genislik: 110),
            new("cagirmaZamani", "bb.cagirma_zamani", "tarih", "Çağrıldı", Hizalama: "orta",
                                                    Bicim: "HH:mm", Genislik: 90),
            new("durumAdi",
                """
                case
                  when m.durum = 3 then 'Tamamlandı'
                  when m.durum = 2 then 'Sonuç Bekliyor'
                  when m.baslangic is not null then 'Muayenede'
                  when bb.cagirma_zamani is not null then 'Çağrıldı'
                  else 'Bekliyor'
                end
                """,                                "metin", "Durum", Hizalama: "orta",
                                                    Bicim: "rozet", Genislik: 130,
                                                    Filtrelenebilir: false),
            // SAYISAL DURUM: cipler ve siralama bunun uzerinden yurur -
            //   metin karsilastirmasi dile bagimli olurdu.
            //   0 bekliyor · 1 cagrildi · 2 muayenede · 3 sonuc bekliyor · 4 tamamlandi
            new("durumKod",
                """
                case
                  when m.durum = 3 then 4
                  when m.durum = 2 then 3
                  when m.baslangic is not null then 2
                  when bb.cagirma_zamani is not null then 1
                  else 0
                end
                """,                                "sayi",  "Durum Kodu", Varsayilan: false),
            new("anaTani",
                "coalesce((select i.ad from public.tani t "
                + "join public.icd i on i.kod = t.icd_kod "
                + "where t.muayene_id = m.id and t.tur = 1 limit 1), '')",
                                                    "metin", "Ana Tanı", Genislik: 200,
                                                    Varsayilan: false),
            new("bekleyenIstem",
                "coalesce((select count(*) from public.muayene_istem s "
                + "where s.muayene_id = m.id and s.sonuc_durum in (0, 1)), 0)",
                                                    "sayi",  "Bekleyen İstem", Hizalama: "orta",
                                                    Genislik: 120, Varsayilan: false),
            new("muayeneId",   "coalesce(m.id, 0)", "sayi",  "Muayene Id", Varsayilan: false),
            new("tarafId",     "b.taraf_id",        "sayi",  "Hasta Id", Varsayilan: false),
            new("personelId",  "coalesce(bb.personel_id, 0)", "sayi", "Hekim Id",
                                                    Varsayilan: false)
        });

    /// <summary>
    /// MUAYENE ŞABLONLARI (411) — branş/kişisel fizik muayene şablonları.
    ///
    /// Kapsam tek tabloda: hekim dolu = kişisel, boş + bölüm dolu = branş,
    /// ikisi de boş = kurum. Kişisel şablonu ayrı tabloya koymak aynı şablon
    /// motorunu iki kez yazdırırdı; kurum şablonu gibi tutmak ise bir hekimin
    /// alıştığı düzeni herkese dayatırdı.
    /// </summary>
    private static KaynakTanimi MuayeneSablon() => new(
        Ad: "muayene-sablon",
        YetkiKodu: "muayene",
        Kaynak: "public.muayene_sablon s "
              + "  left join public.v_personel_lookup p on p.id = s.hekim_id "
              + "  left join public.v_departman_lookup d on d.id = s.bolum_id",
        VarsayilanSirala: "s.sira asc, s.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "s.id",       "sayi",  "Id", Varsayilan: false),
            new("kod",      "s.kod",      "metin", "Kod", Hizalama: "orta", Genislik: 110),
            new("ad",       "s.ad",       "metin", "Şablon", Genislik: 240),
            new("kapsamAdi",
                "case when s.hekim_id is not null then coalesce(p.ad, 'Kişisel') "
                + "when s.bolum_id is not null then coalesce(d.ad, 'Branş') "
                + "else 'Kurum' end",
                                          "metin", "Kapsam", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 160,
                                          Filtrelenebilir: false),
            new("turAdi",
                "case s.tur when 2 then 'Anamnez' when 3 then 'Sistem Sorgusu' "
                + "else 'Fizik Muayene' end",
                                          "metin", "Tür", Hizalama: "orta", Genislik: 130,
                                          Filtrelenebilir: false),
            new("tur",      "s.tur",      "kod",   "Tür Kodu", Varsayilan: false),
            new("alanSayisi",
                "(select count(*) from public.muayene_sablon_alan a where a.sablon_id = s.id)",
                                          "sayi",  "Alan", Hizalama: "orta", Genislik: 70),
            new("aciklama", "s.aciklama", "metin", "Açıklama", Genislik: 280,
                                          Varsayilan: false),
            new("sira",     "s.sira",     "sayi",  "Sıra", Hizalama: "orta", Genislik: 70,
                                          Varsayilan: false),
            new("durum",    "s.durum",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("hekimId",  "coalesce(s.hekim_id, 0)", "sayi", "Hekim Id", Varsayilan: false),
            new("bolumId",  "coalesce(s.bolum_id, 0)", "sayi", "Bölüm Id", Varsayilan: false)
        });

    /// <summary>
    /// METİN MAKROLARI (411) — kısayoldan hazır metin.
    ///
    /// Şablonun yerine geçmez: şablon ALAN tanımlar, makro METİN üretir -
    /// biri yapıyı, öteki hızı çözer.
    /// </summary>
    private static KaynakTanimi MetinMakro() => new(
        Ad: "metin-makro",
        YetkiKodu: "muayene",
        Kaynak: "public.metin_makro m "
              + "  left join public.v_personel_lookup p on p.id = m.hekim_id "
              + "  left join public.v_departman_lookup d on d.id = m.bolum_id",
        // SUBE SUZMESI YOK: makro kurumun metin kutuphanesidir, hekim baska
        //   subede calisirken de kisayollari gecerli olmali.
        VarsayilanSirala: "m.kisayol asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "m.id",       "sayi",  "Id", Varsayilan: false),
            new("kisayol",  "m.kisayol",  "metin", "Kısayol", Hizalama: "orta", Genislik: 100),
            new("alan",     "m.alan",     "metin", "Alan", Hizalama: "orta", Genislik: 120),
            new("metin",    "m.metin",    "metin", "Metin", Genislik: 420),
            new("aciklama", "m.aciklama", "metin", "Açıklama", Genislik: 200,
                                          Varsayilan: false),
            new("kapsamAdi",
                "case when m.hekim_id is not null then coalesce(p.ad, 'Kişisel') "
                + "when m.bolum_id is not null then coalesce(d.ad, 'Branş') "
                + "else 'Kurum' end",
                                          "metin", "Kapsam", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 160,
                                          Filtrelenebilir: false),
            // Kullanim sayaci: "kullanim sikligindan oner" bunu okur.
            new("kullanim", "m.kullanim", "sayi",  "Kullanım", Hizalama: "sag", Genislik: 90),
            new("durum",    "m.durum",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("hekimId",  "coalesce(m.hekim_id, 0)", "sayi", "Hekim Id", Varsayilan: false),
            new("bolumId",  "coalesce(m.bolum_id, 0)", "sayi", "Bölüm Id", Varsayilan: false)
        });

    /// <summary>
    /// REÇETELER (413) — muayenede yazılan ilaçlar.
    ///
    /// Reçete bir BELGEDİR: imzalanınca değişmez, ilaç adı satıra kopyalanır
    /// (katalog güncellenince eski reçetenin metni değişmemeli).
    /// </summary>
    private static KaynakTanimi Recete() => new(
        Ad: "recete",
        YetkiKodu: "muayene",
        Kaynak: "public.recete r "
              + "  join public.taraf h on h.id = r.hasta_id "
              + "  left join public.v_personel_lookup p on p.id = r.hekim_id "
              + "  left join public.muayene m on m.id = r.muayene_id",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.ekleme_tarihi desc, r.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "r.id",         "sayi",  "Id", Varsayilan: false),
            new("receteNo",   "r.recete_no",  "metin", "Reçete No", Hizalama: "orta",
                                              Genislik: 130),
            new("tarih",      "r.ekleme_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("hastaAdi",   "h.unvan",      "metin", "Hasta", Genislik: 220),
            new("hekimAdi",   "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 180),
            new("turAdi",
                "case r.tur when 1 then 'Kırmızı' when 2 then 'Yeşil' when 3 then 'Mor' "
                + "when 4 then 'Turuncu' else 'Normal' end",
                                              "metin", "Reçete Türü", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 110,
                                              Filtrelenebilir: false),
            new("tur",        "r.tur",        "kod",   "Tür Kodu", Varsayilan: false),
            new("ilacSayisi",
                "(select count(*) from public.recete_satir s where s.recete_id = r.id)",
                                              "sayi",  "İlaç", Hizalama: "orta", Genislik: 70),
            new("durumAdi",
                "case r.durum when 2 then 'İmzalı' when 3 then 'Medula Kabul' "
                + "when 4 then 'İptal' else 'Taslak' end",
                                              "metin", "Durum", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 120,
                                              Filtrelenebilir: false),
            new("durum",      "r.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            new("muayeneId",  "r.muayene_id", "sayi",  "Muayene Id", Varsayilan: false),
            new("hastaId",    "r.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false),
            new("protokolNo",
                "coalesce((select b.belge_no from public.belge b where b.id = m.belge_id), '')",
                                              "metin", "Protokol", Hizalama: "orta",
                                              Genislik: 130, Varsayilan: false)
        });

    /// <summary>
    /// HASTA ALERJİLERİ (413) — etken madde bazlı.
    ///
    /// Marka adı üzerinden tutmak, aynı etkeni taşıyan başka markayı
    /// kaçırırdı: "Augmentin alerjisi" kaydı başka amoksisilini engellemez.
    /// </summary>
    private static KaynakTanimi HastaAlerji() => new(
        Ad: "hasta-alerji",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_alerji a join public.taraf h on h.id = a.hasta_id",
        VarsayilanSirala: "a.siddet desc, a.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "a.id",        "sayi",  "Id", Varsayilan: false),
            new("hastaAdi",  "h.unvan",     "metin", "Hasta", Genislik: 220),
            new("turAdi",
                "case a.tur when 2 then 'Gıda' when 3 then 'Çevresel' when 4 then 'Lateks' "
                + "when 5 then 'Kontrast' else 'İlaç' end",
                                           "metin", "Tür", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("tur",       "a.tur",      "kod",   "Tür Kodu", Varsayilan: false),
            new("etken",     "a.etken",    "metin", "Etken / Ürün", Genislik: 220),
            new("etkenMadde","a.etken_madde", "metin", "Etken Madde", Genislik: 200),
            new("reaksiyon", "a.reaksiyon","metin", "Reaksiyon", Genislik: 200),
            new("siddetAdi",
                "case a.siddet when 4 then 'Anafilaksi' when 3 then 'Şiddetli' "
                + "when 2 then 'Orta' else 'Hafif' end",
                                           "metin", "Şiddet", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("siddet",    "a.siddet",   "kod",   "Şiddet Kodu", Varsayilan: false),
            new("dogrulandi","a.dogrulandi","mantik","Doğrulandı", Hizalama: "orta",
                                           Genislik: 100),
            new("aktif",     "a.aktif",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("hastaId",   "a.hasta_id", "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>
    /// HASTANIN KULLANDIĞI İLAÇLAR (413) — kümülatif, reçeteden bağımsız.
    ///
    /// Reçete satırlarıyla aynı şey DEĞİL: hasta başka kurumdan aldığını da
    /// kullanır, bizim yazdığımızın bir kısmını kullanmaz. Etkileşim kontrolü
    /// KULLANILANA bakmalı, yazılana değil.
    /// </summary>
    private static KaynakTanimi HastaIlac() => new(
        Ad: "hasta-ilac",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_ilac i join public.taraf h on h.id = i.hasta_id",
        VarsayilanSirala: "i.aktif desc, i.baslangic desc nulls last, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "i.id",         "sayi",  "Id", Varsayilan: false),
            new("hastaAdi",   "h.unvan",      "metin", "Hasta", Genislik: 200),
            new("ilacAd",     "i.ilac_ad",    "metin", "İlaç", Genislik: 280),
            new("etkenMadde", "i.etken_madde","metin", "Etken Madde", Genislik: 200),
            new("barkod",     "i.ilac_barkod","metin", "Barkod", Hizalama: "orta",
                                              Genislik: 140, Varsayilan: false),
            new("doz",        "i.doz",        "metin", "Doz", Hizalama: "orta", Genislik: 90),
            new("periyot",    "i.periyot",    "metin", "Periyot", Hizalama: "orta",
                                              Genislik: 90),
            new("baslangic",  "i.baslangic",  "tarih", "Başlangıç", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy", Genislik: 110),
            new("bitis",      "i.bitis",      "tarih", "Bitiş", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy", Genislik: 110),
            new("kaynakAdi",
                "case i.kaynak when 2 then 'Hasta Beyanı' when 3 then 'e-Nabız' "
                + "when 4 then 'Dış Kurum' else 'Reçete' end",
                                              "metin", "Kaynak", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 120,
                                              Filtrelenebilir: false),
            new("uyumAdi",
                "case i.uyum when 2 then 'Aralıklı' when 3 then 'Bırakmış' else 'Düzenli' end",
                                              "metin", "Uyum", Hizalama: "orta",
                                              Genislik: 100, Varsayilan: false),
            new("aktif",      "i.aktif",      "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("hastaId",    "i.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>
    /// e-NABIZ GÖNDERİM KUYRUĞU (415) — üretilen paketler ve durumları.
    ///
    /// "Eksik alan" (durum 0) ayrı bir durumdur, hata değil: paket üretildi
    /// ama zorunlu alanı boş olduğu için kuyruğa GİRMEDİ. Eksiği gönderim
    /// anında bulmak, hatayı hekim ekrandan ayrıldıktan saatler sonra geri
    /// getirirdi - bu yüzden liste eksikleri ayrı çipte gösterir.
    /// </summary>
    private static KaynakTanimi EnabizPaket() => new(
        Ad: "enabiz-paket",
        YetkiKodu: "entegrasyon",
        Kaynak: "public.enabiz_paket p "
              + "  join public.enabiz_paket_turu t on t.id = p.paket_turu_id "
              + "  left join public.taraf h on h.id = p.hasta_id "
              + "  left join public.v_personel_lookup k on k.id = p.hekim_id",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.uretim_tarihi desc, p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.id",          "sayi",  "Id", Varsayilan: false),
            new("paketNo",   "p.paket_no",    "metin", "Paket No", Hizalama: "orta",
                                              Genislik: 150),
            new("ussPaket",  "t.uss_paket_kodu", "metin", "USS", Hizalama: "orta",
                                              Genislik: 70),
            new("turAdi",    "t.ad",          "metin", "Paket Türü", Genislik: 190),
            new("turKod",    "t.kod",         "metin", "Tür Kodu", Varsayilan: false),
            new("hastaAdi",  "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 200),
            new("hekimAdi",  "coalesce(k.ad, '')", "metin", "Hekim", Genislik: 170,
                                              Varsayilan: false),
            new("olayTarihi","p.olay_tarihi", "tarih", "Olay", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("durumAdi",
                """
                case p.durum
                     when 0 then 'Eksik Alan' when 1 then 'Bekliyor'
                     when 2 then 'Gönderiliyor' when 3 then 'Gönderildi'
                     when 4 then 'Hatalı' when 5 then 'İptal' when 6 then 'Silindi'
                     else 'Bilinmiyor' end
                """,                          "metin", "Durum", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 120,
                                              Filtrelenebilir: false),
            new("durum",     "p.durum",       "kod",   "Durum Kodu", Varsayilan: false),
            // Eksik alan sayisi: "neyi duzeltmem lazim" sorusunun ilk cevabi.
            new("eksikAlan",
                "(select count(*) from public.enabiz_paket_alan a "
                + "where a.paket_id = p.id and a.gecerli = 0)",
                                              "sayi",  "Eksik", Hizalama: "orta",
                                              Genislik: 70),
            new("deneme",    "p.deneme",      "sayi",  "Deneme", Hizalama: "orta",
                                              Genislik: 80, Varsayilan: false),
            // SURE SINIRI: USS olaydan sonra belli sure icinde bildirim ister;
            //   gecikeni listede one cikarmak icin kalan saat hesaplanir.
            new("kalanSaat",
                "case when p.durum in (3, 5, 6) then null "
                + "else floor(extract(epoch from p.son_tarih - now()) / 3600)::int end",
                                              "sayi",  "Kalan (saat)", Hizalama: "sag",
                                              Genislik: 110),
            new("hataMesaj", "p.hata_mesaj",  "metin", "Hata", Genislik: 300,
                                              Varsayilan: false),
            new("ussPaketId","p.uss_paket_id","metin", "USS Kimlik", Genislik: 200,
                                              Varsayilan: false),
            new("kaynakTur", "p.kaynak_tur",  "sayi",  "Kaynak Tür", Varsayilan: false),
            new("kaynakId",  "p.kaynak_id",   "sayi",  "Kaynak Id", Varsayilan: false),
            new("belgeId",   "coalesce(p.belge_id, 0)", "sayi", "Başvuru Id",
                                              Varsayilan: false)
        });


    /// <summary>
    /// DOKÜMAN LİSTESİ (419) — kaynak üstü görünüm.
    ///
    /// Kart galerileri aynı tabloyu görmeye devam eder; burası klasör/tür/
    /// sürüm/durum ile KURUM GENELİNDE bakılan liste. Ayrı bir "kurumsal
    /// doküman" tablosu açmak, aynı dosyanın iki kopyasını ve iki farklı izin
    /// modelini doğururdu.
    /// </summary>
    private static KaynakTanimi Dokuman() => new(
        Ad: "dokuman",
        YetkiKodu: "dokuman",
        Kaynak: "public.dokuman d "
              + "  left join public.dokuman_turu t on t.id = d.belge_turu_id "
              + "  left join public.dokuman_klasor k on k.id = d.klasor_id "
              + "  left join public.v_kullanici_lookup u on u.id = d.sahip_id",
        SubeKolonu: "d.sube_id",
        SabitKosul: "d.durum <> 0",
        VarsayilanSirala: "d.ekleme_tarihi desc, d.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "d.id",        "sayi",  "Id", Varsayilan: false),
            new("kod",       "d.kod",       "metin", "Kod", Hizalama: "orta", Genislik: 110),
            new("ad",        "d.ad",        "metin", "Doküman", Genislik: 280),
            new("turAdi",    "coalesce(t.ad, d.belge_turu)", "metin", "Tür", Genislik: 150),
            new("klasorYolu","coalesce(k.yol, '')", "metin", "Klasör", Genislik: 180),
            // KAYNAK: dokuman polimorfik - kart galerisinden gelen satirin
            //   nereye bagli oldugu listede gorunmeli.
            new("kaynak",    "d.kaynak",    "metin", "Kaynak", Hizalama: "orta",
                                            Genislik: 130),
            new("kaynakId",  "d.kaynak_id", "sayi",  "Kaynak Id", Varsayilan: false),
            new("surumNo",   "d.surum_no",  "sayi",  "Sürüm", Hizalama: "orta", Genislik: 70),
            new("durumAdi",
                """
                case d.durum when 1 then 'Taslak' when 2 then 'Onayda' when 3 then 'Yayında'
                             when 4 then 'Arşiv' when 5 then 'İmha Edildi' else 'Silindi' end
                """,                        "metin", "Durum", Hizalama: "orta",
                                            Bicim: "rozet", Genislik: 110,
                                            Filtrelenebilir: false),
            new("durum",     "d.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("gizlilikAdi",
                """
                case d.gizlilik when 1 then 'Herkese Açık' when 3 then 'Gizli'
                                when 4 then 'Özel Nitelikli' else 'Kurum İçi' end
                """,                        "metin", "Gizlilik", Hizalama: "orta",
                                            Bicim: "rozet", Genislik: 130,
                                            Filtrelenebilir: false),
            new("gizlilik",  "d.gizlilik",  "kod",   "Gizlilik Kodu", Varsayilan: false),
            new("sahipAdi",  "coalesce(u.ad, '')", "metin", "Sahip", Genislik: 150,
                                            Varsayilan: false),
            new("boyutKb",   "(d.boyut / 1024)", "sayi", "Boyut (KB)", Hizalama: "sag",
                                            Genislik: 100, Varsayilan: false),
            new("gecerliBit","d.gecerli_bit","tarih", "Geçerlilik", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy", Genislik: 110),
            new("eklemeTarihi", "d.ekleme_tarihi", "tarih", "Yükleme", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("surumlu",   "d.surumlu",   "mantik","Sürümlü", Hizalama: "orta",
                                            Genislik: 90, Varsayilan: false),
            // Bekleyen onay: "onay kuyrugu" cipinin dayanagi.
            new("onaydaSurum",
                "(select count(*) from public.dokuman_surum s "
                + "where s.dokuman_id = d.id and s.durum = 2)",
                                            "sayi",  "Onayda", Hizalama: "orta",
                                            Genislik: 80, Varsayilan: false)
        });

    /// <summary>DOKÜMAN TÜRLERİ (419) — sürümlü mü, hangi akış, hangi gizlilik.</summary>
    private static KaynakTanimi DokumanTuru() => new(
        Ad: "dokuman-turu",
        YetkiKodu: "dokuman",
        Kaynak: "public.dokuman_turu t left join public.dokuman_akis a on a.id = t.akis_id",
        VarsayilanSirala: "t.sira asc, t.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "t.id",       "sayi",  "Id", Varsayilan: false),
            new("ad",       "t.ad",       "metin", "Tür", Genislik: 200),
            new("kisaltma", "t.kisaltma", "metin", "Kısaltma", Hizalama: "orta", Genislik: 90),
            new("surumlu",  "t.surumlu",  "mantik","Sürümlü", Hizalama: "orta", Genislik: 90),
            new("akisAdi",  "coalesce(a.ad, '')", "metin", "Onay Akışı", Genislik: 170),
            new("gizlilikAdi",
                "case t.gizlilik when 1 then 'Herkese Açık' when 3 then 'Gizli' "
                + "when 4 then 'Özel Nitelikli' else 'Kurum İçi' end",
                                          "metin", "Gizlilik", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 130,
                                          Filtrelenebilir: false),
            new("gizlilik", "t.gizlilik", "kod",   "Gizlilik Kodu", Varsayilan: false),
            new("gozdenGecirmeAy", "t.gozden_gecirme_ay", "sayi", "Gözden Geçirme (ay)",
                                          Hizalama: "orta", Genislik: 150, Varsayilan: false),
            new("aktif",    "t.aktif",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("sira",     "t.sira",     "sayi",  "Sıra", Hizalama: "orta", Genislik: 70,
                                          Varsayilan: false)
        });

    /// <summary>DOKÜMAN KLASÖRLERİ (419) — kurumsal ağaç (kaynak klasörleri sanal).</summary>
    private static KaynakTanimi DokumanKlasor() => new(
        Ad: "dokuman-klasor",
        YetkiKodu: "dokuman",
        Kaynak: "public.dokuman_klasor k "
              + "  left join public.dokuman_klasor ust on ust.id = k.ust_id "
              + "  left join public.dokuman_turu t on t.id = k.varsayilan_tur_id",
        VarsayilanSirala: "k.yol asc, k.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",       "sayi",  "Id", Varsayilan: false),
            new("ad",       "k.ad",       "metin", "Klasör", Genislik: 220),
            new("yol",      "k.yol",      "metin", "Yol", Genislik: 300),
            new("ustAdi",   "coalesce(ust.ad, '')", "metin", "Üst Klasör", Genislik: 180),
            new("varsayilanTurAdi", "coalesce(t.ad, '')", "metin", "Varsayılan Tür",
                                          Genislik: 160),
            new("dokumanSayisi",
                "(select count(*) from public.dokuman d "
                + "where d.klasor_id = k.id and d.durum <> 0)",
                                          "sayi",  "Doküman", Hizalama: "orta", Genislik: 90),
            new("aktif",    "k.aktif",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("sira",     "k.sira",     "sayi",  "Sıra", Hizalama: "orta", Genislik: 70,
                                          Varsayilan: false)
        });

    /// <summary>
    /// ONAY KUYRUĞU (419) — bekleyen onay adımları.
    ///
    /// Satır = ADIM, doküman değil: aynı doküman iki adımda iki farklı kişiyi
    /// bekliyor olabilir ve herkes yalnız kendi adımını görmeli.
    /// </summary>
    private static KaynakTanimi DokumanOnayKuyrugu() => new(
        Ad: "dokuman-onay",
        YetkiKodu: "dokuman.onayla",
        Kaynak: "public.dokuman_onay_adim a "
              + "  join public.dokuman_onay o on o.id = a.onay_id "
              + "  join public.dokuman d on d.id = o.dokuman_id "
              + "  left join public.dokuman_surum s on s.id = o.surum_id "
              + "  left join public.dokuman_turu t on t.id = d.belge_turu_id "
              + "  left join public.v_kullanici_lookup u on u.id = a.atanan_kullanici_id",
        SabitKosul: "o.durum = 1 and a.sira = o.guncel_adim",
        VarsayilanSirala: "o.baslama asc, a.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "a.id",        "sayi",  "Id", Varsayilan: false),
            new("onayId",    "o.id",        "sayi",  "Onay Id", Varsayilan: false),
            new("dokumanId", "d.id",        "sayi",  "Doküman Id", Varsayilan: false),
            new("dokumanAd", "d.ad",        "metin", "Doküman", Genislik: 280),
            new("kod",       "d.kod",       "metin", "Kod", Hizalama: "orta", Genislik: 110),
            new("turAdi",    "coalesce(t.ad, '')", "metin", "Tür", Genislik: 150),
            new("surumNo",   "coalesce(s.surum_no, 0)", "sayi", "Sürüm", Hizalama: "orta",
                                            Genislik: 70),
            new("adimAd",    "a.ad",        "metin", "Adım", Hizalama: "orta", Genislik: 120),
            new("atananAdi", "coalesce(u.ad, '')", "metin", "Atanan", Genislik: 160),
            new("baslama",   "o.baslama",   "tarih", "Başlama", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // BEKLEME GUNU: onay kuyrugunda gecikeni one cikarmanin tek yolu.
            new("beklemeGun",
                "greatest(0, (extract(epoch from now() - o.baslama) / 86400)::int)",
                                            "sayi",  "Bekleme (gün)", Hizalama: "sag",
                                            Genislik: 110)
        });


    /// <summary>
    /// HASTA KRONİK TANILARI (420).
    ///
    /// Muayenede "kronik" işaretlenen tanı buraya TETİKLE düşer. Hekime
    /// "bir de tıbbi özete ekle" dedirtmek, unutulduğunda bir sonraki hekimin
    /// eksik bilgiyle karar vermesi demekti.
    /// </summary>
    private static KaynakTanimi HastaKronikTani() => new(
        Ad: "hasta-kronik",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_kronik_tani k "
              + "  join public.taraf h on h.id = k.hasta_id "
              + "  left join public.v_personel_lookup p on p.id = k.takip_hekim_id",
        VarsayilanSirala: "k.durum asc, k.baslangic asc nulls last",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",       "sayi",  "Id", Varsayilan: false),
            new("hastaAdi", "h.unvan",    "metin", "Hasta", Genislik: 200),
            new("icdKod",   "k.icd_kod",  "metin", "ICD", Hizalama: "orta", Genislik: 90),
            new("taniAd",   "k.tani_ad",  "metin", "Tanı", Genislik: 300),
            new("baslangic","k.baslangic","tarih", "Başlangıç", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy", Genislik: 110),
            new("takipHekim","coalesce(p.ad, '')", "metin", "Takip Eden", Genislik: 170),
            new("durumAdi",
                "case k.durum when 2 then 'Kontrol Altında' when 3 then 'Geçmiş' "
                + "else 'Aktif' end",
                                          "metin", "Durum", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 130,
                                          Filtrelenebilir: false),
            new("durum",    "k.durum",    "kod",   "Durum Kodu", Varsayilan: false),
            new("kaynakAdi",
                "case k.kaynak when 2 then 'Hasta Beyanı' when 3 then 'e-Nabız' "
                + "when 4 then 'Dış Kurum' else 'Hekim' end",
                                          "metin", "Kaynak", Hizalama: "orta",
                                          Genislik: 120, Varsayilan: false),
            new("hastaId",  "k.hasta_id", "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>HASTA GEÇMİŞ OLAYLARI (420) — ameliyat · girişim · yatış · aşı.</summary>
    private static KaynakTanimi HastaGecmisOlay() => new(
        Ad: "hasta-gecmis",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_gecmis_olay o join public.taraf h on h.id = o.hasta_id",
        VarsayilanSirala: "o.tarih desc nulls last, o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "o.id",       "sayi",  "Id", Varsayilan: false),
            new("hastaAdi", "h.unvan",    "metin", "Hasta", Genislik: 200),
            new("turAdi",
                "case o.tur when 2 then 'Girişim' when 3 then 'Yatış' when 4 then 'Aşı' "
                + "when 5 then 'Travma' when 6 then 'Transfüzyon' else 'Ameliyat' end",
                                          "metin", "Tür", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 120,
                                          Filtrelenebilir: false),
            new("tur",      "o.tur",      "kod",   "Tür Kodu", Varsayilan: false),
            new("ad",       "o.ad",       "metin", "Olay", Genislik: 280),
            new("tarih",    "o.tarih",    "tarih", "Tarih", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy", Genislik: 110),
            new("kurum",    "o.kurum",    "metin", "Kurum", Genislik: 180),
            new("notMetni", "o.not_metni","metin", "Not", Genislik: 260, Varsayilan: false),
            new("hastaId",  "o.hasta_id", "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>
    /// HASTA TIBBİ ÖZETİ (420) — tek satırda alerji/kronik/ilaç sayıları.
    ///
    /// Muayene kartının üst şeridi ve Tıbbi Özet ekranı AYNI kaynağı okur:
    /// iki ayrı sorgu, iki farklı "aktif ilaç" tanımı üretirdi.
    /// </summary>
    private static KaynakTanimi HastaTibbiOzet() => new(
        Ad: "hasta-tibbi-ozet",
        YetkiKodu: "muayene",
        Kaynak: "public.v_hasta_tibbi_ozet o join public.taraf h on h.id = o.hasta_id",
        VarsayilanSirala: "o.son_muayene desc nulls last, h.unvan asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "o.hasta_id",     "sayi",  "Id", Varsayilan: false),
            new("hastaAdi",     "h.unvan",        "metin", "Hasta", Genislik: 220),
            new("dosyaNo",      "h.kod",          "metin", "Dosya No", Hizalama: "orta",
                                                  Genislik: 110),
            new("tcNo",         "coalesce(h.vkno, '')", "metin", "T.C. No", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            // AGIR ALERJI ayri kolon: listede "1 alerji" ile "anafilaksi"
            //   arasindaki fark, hekimin ilk bakisi icin belirleyici.
            new("agirAlerji",   "o.agir_alerji",  "sayi",  "Ağır Alerji", Hizalama: "orta",
                                                  Genislik: 100),
            new("alerjiSayisi", "o.alerji_sayisi","sayi",  "Alerji", Hizalama: "orta",
                                                  Genislik: 80),
            new("alerjiler",    "coalesce(o.alerjiler, '')", "metin", "Alerjiler",
                                                  Genislik: 240),
            new("kronikSayisi", "o.kronik_sayisi","sayi",  "Kronik", Hizalama: "orta",
                                                  Genislik: 80),
            new("kronikTanilar","coalesce(o.kronik_tanilar, '')", "metin", "Kronik Tanılar",
                                                  Genislik: 300),
            new("aktifIlac",    "o.aktif_ilac",   "sayi",  "Aktif İlaç", Hizalama: "orta",
                                                  Genislik: 100),
            new("gecmisOlay",   "o.gecmis_olay",  "sayi",  "Geçmiş Olay", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            new("sonMuayene",   "o.son_muayene",  "tarih", "Son Muayene", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy", Genislik: 120)
        });

    private static KaynakTanimi LabIstem() => new(
        Ad: "lab-istem",
        YetkiKodu: "lab",
        Kaynak: "public.lab_istem i "
              + "  join public.taraf h on h.id = i.taraf_id "
              + "  left join public.belge b on b.id = i.belge_id "
              + "  left join public.v_personel_lookup p on p.id = i.personel_id",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.istem_tarihi desc, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "i.id",           "sayi",  "Id", Varsayilan: false),
            new("istemNo",      "i.istem_no",     "metin", "İstem No", Hizalama: "orta",
                                                  Genislik: 120),
            new("istemTarihi",  "i.istem_tarihi", "tarih", "İstem Tarihi", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("protokolNo",   "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                  Hizalama: "orta", Genislik: 120),
            new("hastaAdi",     "h.unvan",        "metin", "Hasta", Genislik: 220),
            new("dosyaNo",      "h.kod",          "metin", "Dosya No", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            new("bolumAdi",
                "case i.bolum when 2 then 'Mikrobiyoloji' when 3 then 'Genetik' "
                + "when 4 then 'Patoloji' when 9 then 'Diğer' else 'Biyokimya' end",
                                                  "metin", "Bölüm", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 130,
                                                  Filtrelenebilir: false),
            new("bolum",        "i.bolum",        "kod",   "Bölüm Kodu", Varsayilan: false),
            new("hekimAdi",     "coalesce(p.ad, '')", "metin", "İsteyen Hekim", Genislik: 180),
            // Kac test var / kaci sonuclandi: teknisyen listede "bitti mi" gorsun.
            new("testSayisi",
                "(select count(*) from public.lab_istem_test t where t.istem_id = i.id)",
                                                  "sayi",  "Test", Hizalama: "sag", Genislik: 70,
                                                  Filtrelenebilir: false),
            new("sonuclanan",
                "(select count(*) from public.lab_istem_test t "
                + " where t.istem_id = i.id and t.sonuc <> '')",
                                                  "sayi",  "Sonuçlanan", Hizalama: "sag",
                                                  Genislik: 100, Filtrelenebilir: false),
            new("durumAdi",
                "case i.durum when 2 then 'Numune Alındı' when 3 then 'Çalışılıyor' "
                + "when 4 then 'Sonuçlandı' when 5 then 'Onaylandı' when 9 then 'İptal' "
                + "else 'İstendi' end",
                                                  "metin", "Durum", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 130,
                                                  Filtrelenebilir: false),
            new("durum",        "i.durum",        "kod",   "Durum Kodu", Varsayilan: false),
            new("sonucTarihi",  "i.sonuc_tarihi", "tarih", "Sonuç", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                                  Varsayilan: false),
            new("tarafId",      "i.taraf_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("belgeId",      "i.belge_id",     "sayi",  "Başvuru Id", Varsayilan: false)
        });

    /// <summary>
    /// PRIM ROL ADAYLARI (361) - "kim hangi rolde prim alabilir".
    ///
    /// Isaret kisinin kartinda durur (taraf_prim_rol); burasi onu listeler.
    /// Yonetim ekraninda tum roller gorunur, basvuru combosu ise asagidaki
    /// BasvuruHekim kaynagini kullanir.
    /// </summary>
    private static KaynakTanimi PrimRolAday() => new(
        Ad: "prim-rol-aday",
        // YETKI "belge": basvuru karti da bu listeden hekim combosunu dolduruyor
        //   (364) - kayit kabul memurunda prim yetkisi olmak zorunda degil.
        //   Liste yalniz ad + rol tasir, prim TUTARI icermez.
        YetkiKodu: "belge",
        Kaynak: "public.v_prim_rol_aday a",
        SubeKolonu: null,
        VarsayilanSirala: "a.rol, a.ad",
        Kolonlar: PrimRolKolonlari());

    private static KolonTanimi[] PrimRolKolonlari() =>
    [
        new("id",         "a.id",         "sayi",  "Id", Varsayilan: false),
        new("ad",         "a.ad",         "metin", "Kişi", Genislik: 240),
        new("rol",        "a.rol",        "kod",   "Rol Kodu", Varsayilan: false),
        new("rolAdi",
            "case a.rol when 1 then 'Gönderen' when 2 then 'İsteyen' "
            + "when 3 then 'Uygulayan' when 4 then 'Yapan' when 5 then 'Raporlayan' "
            + "when 6 then 'Onaylayan' when 7 then 'Anestezi' when 8 then 'Asistan' "
            + "when 9 then 'Teknisyen' else '' end",
                                          "metin", "Prim Rolü", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 130,
                                          Filtrelenebilir: false),
        // Dis hekim YALNIZ Gonderen olabilir (361) - listede ayrimi gorunsun.
        new("disMi",      "a.dis_mi",     "mantik", "Dış Hekim", Hizalama: "orta",
                                          Genislik: 100),
        new("varsayilan", "a.varsayilan", "mantik", "Önerilen", Hizalama: "orta",
                                          Genislik: 100),
        new("bolumId",    "a.bolum_id",   "sayi",  "Bölüm Id", Varsayilan: false),
        new("durum",      "a.durum",      "kod",   "Durum", Hizalama: "orta", Varsayilan: false)
    ];
}
