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
              // Hasta demografisi (cinsiyet/dogum) baglam seridinde gosterilir:
              //   "ZEYNEP DEMIR K 45y". Ayri istek atmak yerine ayni satirda.
              + "  left join public.taraf_hasta th on th.id = h.id "
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
            new("tcNo",          "coalesce(h.vkno, '')", "metin", "Kimlik No", Hizalama: "orta",
                                                     Genislik: 110, Varsayilan: false),
            new("bolumAdi",      "coalesce(d.ad, '')", "metin", "Bölüm", Genislik: 150),
            new("hekimAdi",      "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 180),
            // KANAL (461, mockup muayene_listesi.html "Kanal"): hastanin nasil
            //   geldigi - uzaktan (teletip) muayene ile yuz yuze ayni listede
            //   durur, hekim hangisine hazirlanacagini bilmeli.
            // Kanal YALNIZ iletisim bicimi: uzaktan (teletip) mi, yuz yuze mi.
            //   Muayenenin TURU (kontrol/konsultasyon) ayri bilgidir ve
            //   "Tür" kolonunda durur - ikisini tek kolona sikistirmak
            //   "Kontrol" ile "Online"i ayni sutunda yarisirdi.
            new("kanal",
                "case m.tur when 2 then 'Online' else 'Yüz yüze' end",
                                          "metin", "Kanal", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 110,
                                          Filtrelenebilir: false),

            // UYARI (461): hekimin satira bakmadan once gormesi gerekeni TEK
            //   kolonda toplar. Sira ONEM sirasi: panik deger > alerji >
            //   tamamlanmis ama tanisiz > yeni gelen sonuc. Karar SUNUCUDA
            //   uretilir - istemci "alerji var mi" diye ayrica sorgulamaz.
            // UYARI (461): hekimin satira bakmadan once gormesi gerekeni TEK
            //   kolonda toplar. Sira ONEM sirasi: panik deger > alerji >
            //   tamamlanmis ama tanisiz > sonuc geldi. Karar SUNUCUDA uretilir;
            //   istemci "alerji var mi" diye ayrica sorgulamaz.
            //
            // ISTEM MUAYENEYE DEGIL BASVURUYA BAGLI: `muayene_istem` yalniz
            //   muayeneden acilan istemi baglar; bankodan/kabulden acilan
            //   tetkik yalnizca belge (basvuru) uzerinden gorunur. Ilk surum
            //   bag tablosuna bakiyordu ve uyari hep bos kaliyordu.
            new("uyari",
                """
                case
                  when exists (
                    select 1 from public.lab_istem li
                      join public.lab_istem_satir ls on ls.istem_id = li.id
                      join public.lab_sonuc so on so.istem_satir_id = ls.id
                     where li.belge_id = m.belge_id and so.panik = 1)
                    then 'PANİK sonuç'
                  when exists (
                    select 1 from public.hasta_alerji al
                     where al.hasta_id = m.taraf_id and coalesce(al.aktif, 1) = 1)
                    then 'Alerji kaydı var'
                  when m.durum = 3 and not exists (
                    select 1 from public.tani ta where ta.muayene_id = m.id)
                    then 'Tanı girilmedi'
                  when m.durum = 2 and exists (
                    select 1 from public.lab_istem li
                      join public.lab_istem_satir ls on ls.istem_id = li.id
                      join public.lab_sonuc so on so.istem_satir_id = ls.id
                     where li.belge_id = m.belge_id and so.onay_zamani is not null)
                    then 'Sonuç geldi'
                  else '' end
                """,                      "metin", "Uyarı", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 140,
                                          Filtrelenebilir: false, Siralanabilir: false),

            new("turAdi",
                "case m.tur when 2 then 'Uzaktan' when 3 then 'Konsültasyon' "
                + "when 4 then 'Kontrol' else 'Yüz Yüze' end",
                                                     "metin", "Tür", Hizalama: "orta",
                                                     Bicim: "rozet", Varsayilan: false, Genislik: 120,
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
                                                     Varsayilan: false),
            new("bitis",         "m.bitis",          "tarih", "Bitiş", Hizalama: "orta",
                                                     Bicim: "HH:mm", Genislik: 110,
                                                     Varsayilan: false),
            // CINSIYET HARFI ve YAS SUNUCUDA hesaplanir: "45 y" istemcide
            //   dogum tarihinden cikarilirsa her ekran kendi kuralini yazar
            //   (ay/gun kirilimi, vefat, tarihsiz hasta). Tek yer, tek kural.
            new("cinsiyetKisa",
                "case coalesce(th.cinsiyet, 0) when 1 then 'E' when 2 then 'K' else '' end",
                                                     "metin", "C.", Hizalama: "orta",
                                                     Genislik: 40, Filtrelenebilir: false,
                                                     Varsayilan: false),
            // Bebeklerde yil yerine ay/gun: "3 ay" ile "0 y" arasindaki fark
            //   doz ve referans araligi kararini degistirir.
            new("yasMetni",
                "case when th.dogum_tarihi is null then '' "
                + "when age(th.dogum_tarihi) >= interval '2 years' "
                + "     then extract(year from age(th.dogum_tarihi))::int::text || 'y' "
                + "when age(th.dogum_tarihi) >= interval '1 month' "
                + "     then (extract(year from age(th.dogum_tarihi))::int * 12 "
                + "           + extract(month from age(th.dogum_tarihi))::int)::text || 'ay' "
                + "else (current_date - th.dogum_tarihi)::text || 'g' end",
                                                     "metin", "Yaş", Hizalama: "orta",
                                                     Genislik: 70, Filtrelenebilir: false,
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
            // TARIH + SAAT (kullanici): calisma listesi gun suzgeciyle acilsa da
            //   gecmis gune bakildiginda yalniz saat hangi gun oldugunu
            //   soylemiyordu.
            new("saat",        "b.belge_tarihi",    "tarih", "Tarih / Saat",
                                                    Hizalama: "orta",
                                                    Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("protokolNo",  "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                    Hizalama: "orta", Genislik: 130),
            new("hastaAdi",    "h.unvan",           "metin", "Hasta", Genislik: 220),
            new("dosyaNo",     "h.kod",             "metin", "Dosya No", Hizalama: "orta",
                                                    Genislik: 110, Varsayilan: false),
            new("tcNo",        "coalesce(h.vkno, '')", "metin", "Kimlik No", Hizalama: "orta",
                                                    Genislik: 110, Varsayilan: false),
            // BOLUM HEKIMDEN ONCE (kullanici): calisma listesinde once hangi
            //   bolume, sonra hangi hekime bakiliyor - siralama okuma sirasi.
            new("bolumAdi",    "coalesce(d.ad, '')", "metin", "Bölüm", Genislik: 140),
            new("hekimAdi",    "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 170),
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

}
