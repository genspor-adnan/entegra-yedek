namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// LABORATUVAR LİSTELERİ (433/434) — tetkik kataloğu, panel, numune,
/// sonuç ve cihaz test eşlemesi.
///
/// Mockup: Ekranlar/Lab/lab_sureci.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// TETKİK KATALOĞU — hizmetle 1:1. Fiyat/faturalama hizmet kartında,
    /// laboratuvar davranışı (numune, TAT, panik, delta) burada.
    /// </summary>
    private static KaynakTanimi LabTetkik() => new(
        Ad: "lab-tetkik",
        YetkiKodu: "lab.tetkik",
        Kaynak: "public.lab_tetkik t "
              + "  left join public.stok h on h.id = t.hizmet_id "
              + "  left join public.cihaz c on c.id = t.varsayilan_cihaz_id",
        // ANA VERI - subeler arasi ORTAK: tetkik katalogu kurumun tanimidir,
        //   sube basina ayri katalog tutmak ayni tetkigin iki farkli panik
        //   sinirini dogururdu.
        SubeKolonu: null,
        VarsayilanSirala: "t.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "t.id",  "sayi",  "Id", Varsayilan: false),
            // IKON SUTUNU (mockup): bolumun simgesi kodun SOLUNDA. Bolum
            //   kolonu varsayilan gorunumden cikinca satirin hangi dala ait
            //   oldugu kayboluyordu; simge bir kolon genisligi yer kaplamadan
            //   ayni bilgiyi verir - goz listeyi dala gore tarayabilir.
            new("ikon",
                "case t.bolum when 2 then '🩸' when 3 then '🧪' "
                + "when 4 then '🦠' when 5 then '🧫' when 6 then '🩸' "
                + "when 7 then '💧' when 9 then '🔬' else '🧪' end",
                                 "metin", "", Hizalama: "orta", Genislik: 34,
                                 Siralanabilir: false, Filtrelenebilir: false),
            new("kod", "t.kod", "metin", "Kod", Genislik: 100),
            new("ad",  "t.ad",  "metin", "Tetkik Adı", Genislik: 240),
            // KISA AD listede (mockup): cihaz ve rapor basligindaki ad budur -
            //   iki tetkigin uzun adi benzerken kisa adi ayirir.
            new("kisaAd", "t.kisa_ad", "metin", "Kısa Ad", Genislik: 110),
            new("bolumAdi",
                "case t.bolum when 2 then 'Hematoloji' when 3 then 'Hormon' "
                + "when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji' "
                + "when 6 then 'Koagülasyon' when 7 then 'İdrar' "
                + "when 9 then 'Diğer' else 'Biyokimya' end",
                                 "metin", "Bölüm", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false,
                                 Varsayilan: false),
            // BOLUM SUZGECI (492, kullanici: "tümü sağına filtre için Bölüm
            //   combosu"): kolonun kod sozlugu metayla gider, ust serit onu
            //   cizer. Etiketler kart metasindaki haritanin KENDISI - liste
            //   ile kart ayni adi soylesin.
            new("bolum", "t.bolum", "kod", "Bölüm Kodu", Varsayilan: false,
                Kodlar: KartKatalogu.LabTetkikBolumKodlari),
            new("turAdi",
                "case t.tur when 2 then 'Metin' when 3 then 'Seçenek' "
                + "when 4 then 'Kültür' else 'Sayısal' end",
                                 "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false,
                                 Varsayilan: false),
            new("tur", "t.tur", "kod", "Tür Kodu", Varsayilan: false),
            new("numuneTipiAdi",
                "case t.numune_tipi when 2 then 'Plazma' when 3 then 'Tam Kan' "
                + "when 4 then 'İdrar' when 5 then 'Gaita' when 6 then 'BOS' "
                + "when 7 then 'Swab' when 9 then 'Diğer' else 'Serum' end",
                                 "metin", "Numune", Hizalama: "orta", Genislik: 110,
                                 Filtrelenebilir: false),
            new("tupTipiAdi",
                "case t.tup_tipi when 2 then 'Mor (EDTA)' when 3 then 'Mavi (Sitrat)' "
                + "when 4 then 'Gri (Florür)' when 5 then 'Yeşil (Heparin)' "
                + "when 6 then 'İdrar Kabı' when 9 then 'Diğer' "
                + "else 'Sarı (Jelli)' end",
                                 "metin", "Tüp", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("birim", "t.birim", "metin", "Birim", Hizalama: "orta", Genislik: 80),
            // TAT: sözü verilen süre. Listede görünmezse gecikme fark edilmez.
            // BIRIMLI GOSTERIM (kullanici): dakika ham hâlde okunmuyordu -
            //   "30240" bir sayi, "21 gün" bir sozdur. Tam bolunuyorsa gun,
            //   degilse saat, o da degilse dakika. Ham dakika kolonu GIZLI
            //   duruyor: siralama ve suzgec onu kullanir (metin siralamasi
            //   "7 gün"u "48 sa"dan once koyardi).
            new("hedefTatAdi",
                "case when coalesce(t.hedef_tat_dk, 0) = 0 then '' "
                + " when t.hedef_tat_dk % 1440 = 0 then (t.hedef_tat_dk / 1440)::text || ' gün' "
                + " when t.hedef_tat_dk % 60 = 0 then (t.hedef_tat_dk / 60)::text || ' sa' "
                + " else t.hedef_tat_dk::text || ' dk' end",
                                 "metin", "TAT", Hizalama: "sag", Genislik: 90,
                                 Siralanabilir: false, Filtrelenebilir: false),
            new("hedefTat", "t.hedef_tat_dk", "sayi", "TAT (dk)", Hizalama: "sag",
                                 Genislik: 90, Varsayilan: false),
            // ÇALIŞMA DÜZENİ (486): "sürekli" mi yoksa haftanın belli
            //   günlerinde seri hâlinde mi. TAT tek başına yanıltıcı - 4
            //   saatlik bir tetkik cuma 14:31'de gelirse pazartesi çıkar.
            //   Kolon okunur metin: gün maskesi ve saatler tek hücrede.
            new("calismaOzeti",
                "case t.calisma_duzeni "
                + " when 1 then 'Mesai içi' "
                + " when 2 then "
                + "   trim(both ' ' from "
                + "     case when (t.calisma_gunleri &  1) > 0 then 'Pzt·' else '' end || "
                + "     case when (t.calisma_gunleri &  2) > 0 then 'Sal·' else '' end || "
                + "     case when (t.calisma_gunleri &  4) > 0 then 'Çar·' else '' end || "
                + "     case when (t.calisma_gunleri &  8) > 0 then 'Per·' else '' end || "
                + "     case when (t.calisma_gunleri & 16) > 0 then 'Cum·' else '' end || "
                + "     case when (t.calisma_gunleri & 32) > 0 then 'Cmt·' else '' end || "
                + "     case when (t.calisma_gunleri & 64) > 0 then 'Paz·' else '' end) "
                + "   || ' ' || t.calisma_saatleri "
                + " else 'Sürekli' end",
                                 "metin", "Çalışma", Hizalama: "orta", Genislik: 170,
                                 Siralanabilir: false, Filtrelenebilir: false),
            new("calismaDuzeni", "t.calisma_duzeni", "kod", "Çalışma Düzeni",
                                 Varsayilan: false),
            new("acilTat", "t.acil_tat_dk", "sayi", "Acil TAT", Hizalama: "sag",
                                 Genislik: 90, Varsayilan: false),
            // PANIK SINIRLARI ve REFERANS SAYISI varsayilan gorunumde YOK
            //   (mockup): katalog listesi "bu tetkik nedir, ne zaman ciker"
            //   sorusunu cevaplar; panik degeri kartin ve sonuc ekraninin isi.
            //   Kolonlar DURUYOR - "referansi yok" suzgeci onlari okuyor.
            new("panikAlt", "t.panik_alt", "sayi", "Panik Alt", Hizalama: "sag",
                                 Bicim: "#,##0.##", Genislik: 100, Varsayilan: false),
            new("panikUst", "t.panik_ust", "sayi", "Panik Üst", Hizalama: "sag",
                                 Bicim: "#,##0.##", Genislik: 100, Varsayilan: false),
            new("deltaYuzde", "t.delta_yuzde", "sayi", "Delta %", Hizalama: "sag",
                                 Bicim: "#,##0.#", Genislik: 90, Varsayilan: false),
            // YONTEM ve CIHAZ (mockup): "bu tetkik neyle calisiliyor" sorusu
            //   katalogun kendi sorusudur - cihazi olmayan tetkik elle girilir.
            new("yontem", "t.yontem", "metin", "Yöntem", Genislik: 140),
            new("cihazAdi", "coalesce(c.kod, '')", "metin", "Cihaz",
                                 Hizalama: "orta", Genislik: 130),
            // OTO ONAY ROZET (kullanici): tik isareti "acik mi kapali mi"
            //   sorusunu yarim cevapliyordu - bos hucre "kapali" mi yoksa
            //   "girilmemis" mi belli degildi. Ham kolon GIZLI: cip suzgeci
            //   ("Oto Onay") onu okuyor.
            new("otoOnayAdi",
                "case when t.oto_onay = 1 then 'Açık' else 'Kapalı' end",
                                 "metin", "Oto Onay", Hizalama: "orta",
                                 Bicim: "rozet", Genislik: 100,
                                 Siralanabilir: false, Filtrelenebilir: false),
            new("otoOnay", "t.oto_onay", "mantik", "Oto Onay Kodu", Hizalama: "orta",
                                 Genislik: 90, Varsayilan: false),
            // Referans satırı OLMAYAN tetkik bayrak üretemez - katalog eksikliği
            //   listede görünmezse sonuç sessizce "normal" çıkar.
            new("referansSayisi",
                "(select count(*) from public.lab_tetkik_referans r "
                + "where r.tetkik_id = t.id)",
                                 "sayi", "Referans", Hizalama: "orta", Genislik: 90,
                                 Filtrelenebilir: false, Varsayilan: false),
            new("hizmetAdi", "coalesce(h.kod || ' · ' || h.ad, '')", "metin", "Hizmet",
                                 Genislik: 220, Varsayilan: false),
            new("hizmetId", "t.hizmet_id", "sayi", "Hizmet Id", Varsayilan: false),
            new("loinc", "t.loinc", "metin", "LOINC", Hizalama: "orta", Genislik: 100,
                                 Varsayilan: false),
            new("durumAdi", "case t.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "t.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>PANELLER — istemde tek kalemde açılan tetkik grupları.</summary>
    private static KaynakTanimi LabPanel() => new(
        Ad: "lab-panel",
        YetkiKodu: "lab.tetkik",
        // `hizmet_id` HIZMETE bakar, stoga degil: liste "Hizmet" kolonunda
        //   ayni id'li bir STOGUN adini gosteriyordu (501 koprusunden sonra
        //   panellerin hepsinde dolu - hata gorunur hale geldi).
        Kaynak: "public.lab_panel p left join public.hizmet h on h.id = p.hizmet_id",
        SubeKolonu: null,                     // ana veri - ortak (tetkik gibi)
        VarsayilanSirala: "p.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "p.id",  "sayi",  "Id", Varsayilan: false),
            new("kod", "p.kod", "metin", "Kod", Genislik: 120),
            new("ad",  "p.ad",  "metin", "Panel", Genislik: 260),
            new("tetkikSayisi",
                "(select count(*) from public.lab_panel_satir s where s.panel_id = p.id)",
                                 "sayi", "Tetkik", Hizalama: "orta", Genislik: 80,
                                 Filtrelenebilir: false),
            new("hizmetAdi", "coalesce(h.kod || ' · ' || h.ad, '')", "metin", "Hizmet",
                                 Genislik: 220, Varsayilan: false),
            new("durumAdi", "case p.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "p.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// NUMUNE KABUL LİSTESİ — barkod, tüp, kabul/ret ve GECİKME.
    ///
    /// Bekleme süresi kolonu bilinçli: kabul edilmemiş tüp laboratuvarda
    /// bekliyorsa (pıhtılaşma, hemoliz) sonuç zaten güvenilmez olur.
    /// </summary>
    private static KaynakTanimi LabNumune() => new(
        Ad: "lab-numune",
        YetkiKodu: "lab.numune",
        Kaynak: "public.lab_numune n "
              + "  join public.lab_istem i on i.id = n.istem_id "
              + "  join public.taraf h on h.id = n.hasta_id",
        SubeKolonu: "n.sube_id",
        // BANKO KAPISI (912): poliklinik muayene isteğinin numunesi banko
        //   ücretlendirmesi beklerken (serbest=0) kabul kuyruğunda GÖRÜNMEZ.
        SabitKosul: "i.serbest = 1",
        // PORTAL (795): dis kurum kendi gonderdigi istemin NUMUNE durumunu
        //   gorur ("kan alindi mi, laba ulasti mi"); hasta kendi numunesini.
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: PortalKapsam.LabGonderen("i.belge_id", "i.personel_id"),
            disKurum:  "i.dis_kurum_id = {kullanici}",
            hasta:     "i.taraf_id = {kullanici}"),
        VarsayilanSirala: "n.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "n.id",     "sayi",  "Id", Varsayilan: false),
            new("barkod", "n.barkod", "metin", "Barkod", Hizalama: "orta", Genislik: 140),
            new("istemNo", "i.istem_no", "metin", "İstem No", Hizalama: "orta",
                                 Genislik: 130),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 220),
            new("dosyaNo", "coalesce(h.kod, '')", "metin", "Dosya No", Hizalama: "orta",
                                 Genislik: 110, Varsayilan: false),
            new("tupTipiAdi",
                "case n.tup_tipi when 2 then 'Mor (EDTA)' when 3 then 'Mavi (Sitrat)' "
                + "when 4 then 'Gri (Florür)' when 5 then 'Yeşil (Heparin)' "
                + "when 6 then 'İdrar Kabı' when 9 then 'Diğer' "
                + "else 'Sarı (Jelli)' end",
                                 "metin", "Tüp", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("tetkikSayisi",
                "(select count(*) from public.lab_istem_satir s "
                + "where s.numune_id = n.id and s.durum <> 0)",
                                 "sayi", "Tetkik", Hizalama: "orta", Genislik: 80,
                                 Filtrelenebilir: false),
            new("oncelikAdi",
                "case i.oncelik when 2 then 'Öncelikli' when 3 then 'Acil' "
                + "else 'Normal' end",
                                 "metin", "Öncelik", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false),
            new("alimZamani", "n.alim_zamani", "tarih", "Alındı", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("kabulZamani", "n.kabul_zamani", "tarih", "Kabul", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("beklemeDk",
                "case when n.kabul_zamani is null and n.alim_zamani is not null "
                + "then floor(extract(epoch from (now() - n.alim_zamani)) / 60)::int "
                + "else null end",
                                 "sayi", "Bekleme (dk)", Hizalama: "sag", Genislik: 110,
                                 Filtrelenebilir: false),
            // Kalite kodlari db/433: 1 uygun · 2 hemoliz · 3 lipemi · 4 ikter ·
            //   5 yetersiz · 6 pihti · 7 yanlis tup · 8 etiketsiz.
            new("kaliteAdi",
                "case n.kalite when 2 then 'Hemolizli' when 3 then 'Lipemik' "
                + "when 4 then 'İkterik' when 5 then 'Yetersiz' when 6 then 'Pıhtılı' "
                + "when 7 then 'Yanlış Tüp' when 8 then 'Etiketsiz' "
                + "else 'Uygun' end",
                                 "metin", "Kalite", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            new("durumAdi",
                "case n.durum when 0 then 'Reddedildi' when 2 then 'Alındı' "
                + "when 3 then 'Kabul' when 4 then 'Cihazda' when 5 then 'Saklamada' "
                + "when 6 then 'İmha' else 'Etiketlendi' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            new("durum", "n.durum", "kod", "Durum Kodu", Varsayilan: false),
            // SERUM İNDEKSLERİ (444): kabul ekranında "uygun" görünen numune
            //   cihazda hemolizli çıkabilir - indeksler ölçümle gelir ve
            //   hangi testin etkilendiğini kural belirler.
            new("indeksler",
                "case when n.hemoliz_idx is null and n.lipemi_idx is null "
                + "          and n.ikter_idx is null then '' else "
                + "concat_ws(' · ', "
                + "  case when n.hemoliz_idx is not null then 'H ' || n.hemoliz_idx end, "
                + "  case when n.lipemi_idx is not null then 'L ' || n.lipemi_idx end, "
                + "  case when n.ikter_idx is not null then 'İ ' || n.ikter_idx end) end",
                                 "metin", "HIL İndeks", Hizalama: "orta", Genislik: 130,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("retAciklama", "n.ret_aciklama", "metin", "Ret Nedeni", Genislik: 220,
                                 Varsayilan: false),
            new("istemId", "n.istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("hastaId", "n.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
        });

    /// <summary>
    /// SONUÇ LİSTESİ — onay kuyruğu.
    ///
    /// Bayrak/panik/delta sonucun KENDİSİNDEN okunur (yazılırken hesaplandı);
    /// listede yeniden hesaplamak, referans değişince eski raporu değiştirirdi.
    /// </summary>
    private static KaynakTanimi LabSonuc() => new(
        Ad: "lab-sonuc",
        YetkiKodu: "lab.sonuc",
        Kaynak: "public.lab_sonuc ls "
              + "  join public.lab_istem_satir s on s.id = ls.istem_satir_id "
              + "  join public.lab_istem i on i.id = s.istem_id "
              + "  join public.lab_tetkik t on t.id = ls.tetkik_id "
              + "  join public.taraf h on h.id = i.taraf_id "
              + "  left join public.lab_numune n on n.id = ls.numune_id "
              + "  left join public.cihaz c on c.id = ls.cihaz_id",
        SubeKolonu: "ls.sube_id",
        // PORTAL (794): sonuc en hassas kayit - kosulsuz kaynak portal
        //   roluNE KAPALIDIR, bu yuzden ucu de acikca yazilir.
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: PortalKapsam.LabGonderen("i.belge_id", "i.personel_id"),
            disKurum:  "i.dis_kurum_id = {kullanici}",
            hasta:     "i.taraf_id = {kullanici}"),
        VarsayilanSirala: "ls.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "ls.id", "sayi", "Id", Varsayilan: false),
            new("barkod", "coalesce(n.barkod, '')", "metin", "Barkod", Hizalama: "orta",
                                 Genislik: 140),
            new("istemNo", "i.istem_no", "metin", "İstem No", Hizalama: "orta",
                                 Genislik: 130, Varsayilan: false),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 200),
            new("tetkikKod", "t.kod", "metin", "Kod", Hizalama: "orta", Genislik: 90),
            new("tetkikAd", "t.ad", "metin", "Tetkik", Genislik: 200),
            new("deger", "ls.deger_metin", "metin", "Sonuç", Hizalama: "sag",
                                 Genislik: 110),
            new("birim", "ls.birim", "metin", "Birim", Hizalama: "orta", Genislik: 80),
            new("bayrak",
                "case ls.bayrak when 'LL' then '↓↓ Panik Düşük' "
                + "when 'HH' then '↑↑ Panik Yüksek' when 'L' then '↓ Düşük' "
                + "when 'H' then '↑ Yüksek' else 'Normal' end",
                                 "metin", "Değerlendirme", Hizalama: "orta",
                                 Bicim: "rozet", Genislik: 140, Filtrelenebilir: false),
            // REFERANS okunur biçimde: ham numeric ::text "0.000000 - 33.000000"
            //   diye çıkıyordu ve kolona sığmayıp kırpılıyordu. trim_scale
            //   gereksiz sıfırları atar, ondalık ayraç Türkçe.
            //   Tek taraflı sınır "≤ 35" / "≥ 60" yazılır: "0 - 35" alt sınır
            //   varmış gibi görünürdü.
            new("referans",
                "case when ls.referans_metin <> '' then ls.referans_metin "
                + "when ls.referans_alt is not null and ls.referans_ust is not null "
                + "then replace(trim_scale(ls.referans_alt)::text, '.', ',') || ' – ' "
                + "     || replace(trim_scale(ls.referans_ust)::text, '.', ',') "
                + "when ls.referans_ust is not null "
                + "then '≤ ' || replace(trim_scale(ls.referans_ust)::text, '.', ',') "
                + "when ls.referans_alt is not null "
                + "then '≥ ' || replace(trim_scale(ls.referans_alt)::text, '.', ',') "
                + "else '' end",
                                 "metin", "Referans", Hizalama: "orta", Genislik: 140,
                                 Filtrelenebilir: false),
            new("panik", "ls.panik", "mantik", "Panik", Hizalama: "orta", Genislik: 80),
            // ONCEKI DEGER ve DELTA (mockup: "Önceki (12.03.25)" ve "Δ"):
            //   uzman sonuca degil DEGISIME bakar - 142 mg/dL tek basina bir
            //   sey soylemez, 98'den 142'ye cikmis olmasi soyler.
            new("deltaOnceki",
                "case when ls.delta_onceki is null then '' "
                + "else replace(trim_scale(ls.delta_onceki)::text, '.', ',') end",
                                 "metin", "Önceki", Hizalama: "sag", Genislik: 90,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("deltaYuzdeMetin",
                "case when ls.delta_yuzde is null then '' "
                + "else case when ls.delta_yuzde > 0 then '+' else '' end "
                + "     || replace(trim_scale(round(ls.delta_yuzde))::text, '.', ',') "
                + "     || '%' end",
                                 "metin", "Δ", Hizalama: "sag", Genislik: 80,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("deltaUyari", "ls.delta_uyari", "mantik", "Delta", Hizalama: "orta",
                                 Genislik: 80),
            new("olcumZamani", "ls.olcum_zamani", "tarih", "Ölçüm", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("cihazAdi", "coalesce(c.kod, 'Elle')", "metin", "Kaynak", Hizalama: "orta",
                                 Genislik: 110),
            new("durumAdi",
                "case ls.durum when 2 then 'Teknik Onay' when 3 then 'Onaylı' "
                + "when 4 then 'İptal (düzeltildi)' else 'Bekliyor' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("durum", "ls.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("otoOnay", "ls.oto_onay", "mantik", "Oto", Hizalama: "orta", Genislik: 70,
                                 Varsayilan: false),
            new("onayZamani", "ls.onay_zamani", "tarih", "Onay", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                 Varsayilan: false),
            // İNDEKS UYARISI sonucun yanında durur: "K yüksek" ile "hemoliz
            //   yüzünden yüksek görünüyor" bambaşka iki şey.
            new("indeksUyari", "ls.indeks_uyari", "metin", "Numune Kalitesi Uyarısı",
                                 Genislik: 280),
            new("indeksDurum", "ls.indeks_durum", "kod", "İndeks Durumu",
                                 Varsayilan: false),
            new("yorum", "ls.yorum", "metin", "Yorum", Genislik: 240, Varsayilan: false),
            new("istemId", "s.istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("istemSatirId", "ls.istem_satir_id", "sayi", "Satır Id",
                                 Varsayilan: false),
        });

    /// <summary>
    /// CİHAZ TEST EŞLEME (434) — cihazın kendi kodu ile tetkik arasındaki köprü.
    /// Kayıt yoksa kod eşitliği kullanılır; tablo yalnız istisnalar için.
    /// </summary>
    private static KaynakTanimi LabCihazEsleme() => new(
        Ad: "lab-cihaz-esleme",
        YetkiKodu: "lab.cihaz",
        Kaynak: "public.lab_cihaz_test_esleme e "
              + "  join public.cihaz c on c.id = e.cihaz_id "
              + "  join public.lab_tetkik t on t.id = e.tetkik_id",
        SubeKolonu: null,                     // cihaz zaten subeli; esleme tanim
        VarsayilanSirala: "c.kod asc, e.cihaz_test_kodu asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "e.id", "sayi", "Id", Varsayilan: false),
            new("cihazAdi", "c.kod || ' · ' || c.ad", "metin", "Cihaz", Genislik: 220),
            new("cihazTestKodu", "e.cihaz_test_kodu", "metin", "Cihaz Kodu",
                                 Hizalama: "orta", Genislik: 130),
            new("altKod", "e.alt_kod", "metin", "Alt Kod", Hizalama: "orta",
                                 Genislik: 90, Varsayilan: false),
            new("tetkikAdi", "t.kod || ' · ' || t.ad", "metin", "Tetkik", Genislik: 240),
            new("cihazBirim", "e.cihaz_birim", "metin", "Cihaz Birimi", Hizalama: "orta",
                                 Genislik: 110),
            new("tetkikBirim", "t.birim", "metin", "Rapor Birimi", Hizalama: "orta",
                                 Genislik: 110),
            new("carpan", "e.carpan", "sayi", "Çarpan", Hizalama: "sag",
                                 Bicim: "#,##0.####", Genislik: 100),
            new("ofset", "e.ofset", "sayi", "Ofset", Hizalama: "sag",
                                 Bicim: "#,##0.####", Genislik: 100),
            new("durumAdi", "case e.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "e.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("cihazId", "e.cihaz_id", "sayi", "Cihaz Id", Varsayilan: false),
            new("tetkikId", "e.tetkik_id", "sayi", "Tetkik Id", Varsayilan: false),
        });

    /// <summary>
    /// AKILCI TEST İSTEM KURALLARI (873): Bakanlık listesi + SKRS süresi. Kurum
    /// düzeltebilir (aktif/pasif, branş, süre); kaynak sürümü kolonda görünür.
    /// </summary>
    private static KaynakTanimi LabAkilciKural() => new(
        Ad: "lab-akilci-kural",
        YetkiKodu: "lab.tetkik",
        Kaynak: "public.lab_akilci_kural k left join public.hizmet h on h.id = k.hizmet_id",
        SubeKolonu: null,
        VarsayilanSirala: "k.sut_kodu asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "k.id",        "sayi",  "Id", Varsayilan: false),
            new("sutKodu",   "k.sut_kodu",  "metin", "SUT Kodu", Genislik: 90),
            new("ad",        "k.ad",        "metin", "Test", Genislik: 260),
            new("hizmetVar", "case when k.hizmet_id is null then 0 else 1 end", "mantik", "Katalogda", Hizalama: "orta", Genislik: 80, Filtrelenebilir: false),
            new("sureGun",   "k.sure_gun",  "sayi",  "Tekrar (gün)", Hizalama: "sag", Genislik: 90),
            new("sureNotu",  "k.sure_notu", "metin", "Süre Notu", Genislik: 200, Varsayilan: false),
            new("tumBranslar", "k.tum_branslar", "mantik", "Tüm Branşlar", Hizalama: "orta", Genislik: 90),
            new("bransAdlari",
                "coalesce((select string_agg(d.ad, ', ' order by d.ad) from public.departman d where d.kod = any(string_to_array(k.brans_kodlari, ','))), '')",
                "metin", "Yetkili Branşlar", Genislik: 320, Siralanabilir: false),
            new("basamakAdi", "case k.basamak when 3 then '3. basamak' when 2 then '2. ve 3.' else 'kapsam dışı' end",
                "metin", "Basamak", Hizalama: "orta", Bicim: "rozet", Genislik: 100, Filtrelenebilir: false),
            new("basamak",   "k.basamak",   "sayi",  "Basamak Kodu", Varsayilan: false),
            new("refleks",   "k.refleks",   "mantik", "Refleks", Hizalama: "orta", Genislik: 70),
            new("kapali",    "k.kapali",    "mantik", "Kapalı", Hizalama: "orta", Genislik: 70),
            new("aktif",     "k.aktif",     "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
            new("aciklama",  "k.aciklama",  "metin", "Not", Genislik: 260, Varsayilan: false),
            new("kaynakSurum", "k.kaynak_surum", "metin", "Kaynak", Genislik: 150, Varsayilan: false),
        });

    /// <summary>
    /// BZBH HASTALIK LİSTESİ (882, KTS maddesi H5): bildirimi zorunlu
    /// bulaşıcı hastalıklar. ICD önekiyle eşleşir; tohum liste Bakanlık
    /// tebliğine göre doğrulanmayı bekler (<c>dogrulandi</c>).
    /// </summary>
    private static KaynakTanimi BzbhHastalik() => new(
        Ad: "bzbh-hastalik",
        YetkiKodu: "bzbh.hastalik",
        Kaynak: "public.bzbh_hastalik h",
        SubeKolonu: null,
        VarsayilanSirala: "h.icd_onek asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "h.id",        "sayi",  "Id", Varsayilan: false),
            new("icdOnek",   "h.icd_onek",  "metin", "ICD Öneki", Genislik: 90),
            new("ad",        "h.ad",        "metin", "Hastalık", Genislik: 240),
            new("grup",      "h.grup",      "sayi",  "Grup", Hizalama: "orta", Genislik: 60),
            new("grupAdi",
                "case h.grup when 1 then 'Grup A - ivedi' when 2 then 'Grup B' "
                + "when 3 then 'Grup C' when 4 then 'Grup D' else '' end",
                "metin", "Bildirim Grubu", Hizalama: "orta", Bicim: "rozet", Genislik: 130,
                Filtrelenebilir: false),
            new("sureSaat",  "h.sure_saat", "sayi",  "Süre (saat)", Hizalama: "sag", Genislik: 90),
            new("dogrulandi","h.dogrulandi","mantik", "Tebliğe göre doğrulandı",
                Hizalama: "orta", Genislik: 140),
            new("aciklama",  "h.aciklama",  "metin", "Açıklama", Genislik: 300, Varsayilan: false),
            new("aktif",     "h.aktif",     "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
        });

    /// <summary>
    /// NUMUNE RET KRİTERLERİ (879, KTS maddesi L6). Kod uzayı 433 ile aynı -
    /// geçmiş numunelerin `ret_neden` / `kalite` değerleri bu satırlara bağlı.
    /// </summary>
    private static KaynakTanimi LabRetNedeni() => new(
        Ad: "lab-ret-nedeni",
        YetkiKodu: "lab.ret_nedeni",
        Kaynak: "public.lab_ret_nedeni r",
        SubeKolonu: null,
        VarsayilanSirala: "r.sira asc, r.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "r.id",       "sayi",  "Id", Varsayilan: false),
            new("kod",      "r.kod",      "sayi",  "Kod", Hizalama: "orta", Genislik: 70),
            new("ad",       "r.ad",       "metin", "Ret Kriteri", Genislik: 220),
            new("aciklama", "r.aciklama", "metin", "Açıklama", Genislik: 320),
            new("kabuldeSecilebilir", "r.kabulde_secilebilir", "mantik",
                "Kabulde de seçilir", Hizalama: "orta", Genislik: 110),
            new("hastaBilgilendir", "r.hasta_bilgilendir", "mantik",
                "Hastaya e-Nabız mesajı", Hizalama: "orta", Genislik: 130),
            new("mesajSablonu", "r.mesaj_sablonu", "metin", "Mesaj Metni",
                Genislik: 320, Varsayilan: false),
            new("sira",     "r.sira",     "sayi",  "Sıra", Hizalama: "sag", Genislik: 60,
                Varsayilan: false),
            new("aktif",    "r.aktif",    "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
        });

    // ARŞİV KOD UZAYLARI (890) - SQL'deki kodların TEK okunur karşılığı.
    private static readonly Dictionary<string, string> LabArsivDurumlari = new()
        { ["1"] = "Arşivde", ["2"] = "Çıkarıldı", ["3"] = "İmha edildi" };

    private static readonly Dictionary<string, string> LabArsivCikisNedenleri = new()
        { ["1"] = "Tekrar çalışma", ["2"] = "Dış laboratuvara",
          ["3"] = "İmha", ["4"] = "Devir / iade" };

    // GEBELİK DOSYASI DURUMU (900): kapanan dosya 224'ün yeridir.
    private static readonly Dictionary<string, string> GebelikDurumlari = new()
        { ["1"] = "Devam ediyor", ["2"] = "Sonuçlandı", ["0"] = "İptal" };

    // ÇOCUK İZLEM KOD UZAYLARI (899).
    private static readonly Dictionary<string, string> CocukIzlemDurumlari = new()
        { ["1"] = "Geçerli", ["0"] = "İptal" };

    private static readonly Dictionary<string, string> CocukCinsiyetKodlari = new()
        { ["1"] = "Erkek", ["2"] = "Kız" };

    private static readonly Dictionary<string, string> CocukOlcutKodlari = new()
        { ["1"] = "Kilo (kg)", ["2"] = "Boy (cm)", ["3"] = "Baş çevresi (cm)" };

    // AŞI KAYIT DURUMU (898): uygulanmış aşı SİLİNMEZ, iptal edilir.
    private static readonly Dictionary<string, string> AsiDurumlari = new()
        { ["1"] = "Uygulandı", ["0"] = "İptal" };

    // PANİK DURUMU (894): teyit alınmamış olanlar listelenir.
    private static readonly Dictionary<string, string> LabPanikDurumlari = new()
        { ["1"] = "Bildirilmedi", ["2"] = "Teyit bekliyor", ["3"] = "Teyit alındı" };

    // TEKRAR TALEBİ KOD UZAYI (891).
    private static readonly Dictionary<string, string> LabTekrarTurleri = new()
        { ["1"] = "Aynı numuneden tekrar", ["2"] = "Yeni numune" };

    private static readonly Dictionary<string, string> LabTekrarDurumlari = new()
        { ["1"] = "Bekliyor", ["2"] = "Karşılandı", ["3"] = "İptal" };

    private static readonly Dictionary<string, string> LabArsivKonumTurleri = new()
        { ["1"] = "Ünite", ["2"] = "Raf", ["3"] = "Kutu" };

    /// <summary>
    /// NUMUNE ARŞİVİ (890, KTS L13) — arşivdeki/çıkmış tüpler.
    ///
    /// Görünüm `v_lab_arsiv`: konum yolu ("Derin dondurucu A / Raf 2 /
    /// Kutu 7"), göz ve kalan gün orada hesaplanıyor; listede yeniden
    /// hesaplamak, ekran ile imha listesinin ayrışması demekti.
    /// </summary>
    private static KaynakTanimi LabArsiv() => new(
        Ad: "lab-arsiv",
        YetkiKodu: "lab.arsiv",
        Kaynak: "public.v_lab_arsiv a",
        SubeKolonu: "a.sube_id",
        VarsayilanSirala: "a.giris_zamani desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "a.id",        "sayi",  "Id", Varsayilan: false),
            new("barkod",    "a.barkod",    "metin", "Barkod", Hizalama: "orta", Genislik: 130),
            new("hasta",     "a.hasta",     "metin", "Hasta", Genislik: 220),
            new("istemNo",   "a.istem_no",  "metin", "İstem No", Hizalama: "orta", Genislik: 120),
            new("konum",     "a.konum",     "metin", "Konum", Genislik: 260),
            new("goz",       "a.goz",       "metin", "Göz", Hizalama: "orta", Genislik: 60),
            new("sicaklik",  "a.sicaklik",  "sayi",  "°C", Hizalama: "sag", Genislik: 60),
            new("girisZamani", "a.giris_zamani", "tarihsaat", "Arşive Giriş", Genislik: 150),
            new("saklamaGun", "a.saklama_gun", "sayi", "Saklama (gün)", Hizalama: "sag",
                Genislik: 110, Varsayilan: false),
            new("imhaHedef", "a.imha_hedef", "tarih", "İmha Hedefi", Hizalama: "orta",
                Genislik: 110),
            // KALAN GÜN EKSİYSE SÜRE DOLMUŞ: listede sıralanabilir olmalı,
            //   imha listesi de aynı sayıya bakıyor.
            new("kalanGun",  "a.kalan_gun", "sayi", "Kalan Gün", Hizalama: "sag", Genislik: 90),
            new("durum",     "a.durum",     "kod",  "Durum", Hizalama: "orta", Genislik: 100,
                Kodlar: LabArsivDurumlari),
            new("cikisZamani", "a.cikis_zamani", "tarihsaat", "Çıkış", Genislik: 150,
                Varsayilan: false),
            new("cikisNeden", "a.cikis_neden", "kod", "Çıkış Nedeni", Hizalama: "orta",
                Genislik: 140, Kodlar: LabArsivCikisNedenleri, Varsayilan: false),
            new("notMetni",  "a.not_metni", "metin", "Not", Genislik: 220, Varsayilan: false),
        });

    /// <summary>
    /// TEKRAR TALEPLERİ (891, KTS L8) — laboratuvarın tekrar kuyruğu.
    ///
    /// Görünüm `v_lab_tekrar_istegi`: gerekçe ADI kod listesinden, tüpün
    /// arşiv yeri 890'dan geliyor - "aynı numuneden tekrar" talebinde
    /// teknisyenin ilk işi tüpü bulmaktır.
    /// </summary>
    private static KaynakTanimi LabTekrar() => new(
        Ad: "lab-tekrar",
        YetkiKodu: "lab.tekrar",
        Kaynak: "public.v_lab_tekrar_istegi t",
        SubeKolonu: "t.sube_id",
        VarsayilanSirala: "t.istek_zamani desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "t.id",       "sayi",  "Id", Varsayilan: false),
            new("satirId",  "t.satir_id", "sayi",  "Satır", Varsayilan: false),
            new("istemNo",  "t.istem_no", "metin", "İstem No", Hizalama: "orta", Genislik: 120),
            new("barkod",   "coalesce(t.barkod, '')", "metin", "Barkod",
                Hizalama: "orta", Genislik: 130),
            new("hasta",    "t.hasta",    "metin", "Hasta", Genislik: 200),
            new("tetkik",   "t.kod || ' · ' || t.tetkik", "metin", "Tetkik", Genislik: 220),
            new("tur",      "t.tur",      "kod",   "Tür", Hizalama: "orta", Genislik: 150,
                Kodlar: LabTekrarTurleri),
            new("gerekceAdi", "t.gerekce_adi", "metin", "Gerekçe", Genislik: 220),
            new("gerekce",  "t.gerekce",  "metin", "Açıklama", Genislik: 240, Varsayilan: false),
            new("isteyen",  "t.isteyen",  "metin", "İsteyen", Genislik: 160),
            new("istekZamani", "t.istek_zamani", "tarihsaat", "İstek", Genislik: 150),
            new("arsivYeri", "coalesce(t.arsiv_yeri, '')", "metin", "Tüp Arşivde",
                Genislik: 240),
            new("durum",    "t.durum",    "kod",   "Durum", Hizalama: "orta", Genislik: 110,
                Kodlar: LabTekrarDurumlari),
            new("kapanmaZamani", "t.kapanma_zamani", "tarihsaat", "Kapanış",
                Genislik: 150, Varsayilan: false),
            new("iptalNeden", "t.iptal_neden", "metin", "İptal Nedeni", Genislik: 220,
                Varsayilan: false),
        });

    /// <summary>
    /// PANİK DEĞERLER (894, KTS L2) — açık panikler ve bekleme süresi.
    ///
    /// Panik değer "bildirildi" ile kapanmaz; <b>okuma-geri teyidi</b> ile
    /// kapanır (kim, ne zaman). Liste bu yüzden teyitsiz kayıtları gösterir -
    /// teyit alınan panik tarihe düşer.
    /// </summary>
    private static KaynakTanimi LabPanik() => new(
        Ad: "lab-panik",
        YetkiKodu: "lab.panik",
        Kaynak: "public.v_lab_panik_acik p",
        SubeKolonu: "p.sube_id",
        // EN UZUN BEKLEYEN ÖNCE: sıralama, listenin kendisinin uyarısıdır.
        VarsayilanSirala: "p.gecen_dk desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.sonuc_id",  "sayi",  "Id", Varsayilan: false),
            new("satirId",   "p.satir_id",  "sayi",  "Satır", Varsayilan: false),
            new("istemNo",   "p.istem_no",  "metin", "İstem No", Hizalama: "orta",
                Genislik: 120),
            new("hasta",     "p.hasta",     "metin", "Hasta", Genislik: 200),
            new("tetkik",    "p.kod || ' · ' || p.tetkik", "metin", "Tetkik", Genislik: 200),
            new("deger",     "p.deger",     "metin", "Değer", Hizalama: "sag", Genislik: 90),
            new("birim",     "p.birim",     "metin", "Birim", Genislik: 70),
            new("bayrak",    "p.bayrak",    "metin", "Bayrak", Hizalama: "orta",
                Genislik: 70),
            new("olcumZamani", "p.olcum_zamani", "tarihsaat", "Ölçüm", Genislik: 150),
            new("gecenDk",   "p.gecen_dk",  "sayi",  "Bekleyen (dk)", Hizalama: "sag",
                Genislik: 110),
            new("hekim",     "p.hekim",     "metin", "İstem Hekimi", Genislik: 180),
            new("durum",     "p.durum",     "kod",   "Durum", Hizalama: "orta",
                Genislik: 150, Kodlar: LabPanikDurumlari),
            // TEYİT AKSİYONU BİLDİRİM KAYDINI İSTER: teyit, sonuca değil
            //   YAPILAN BİLDİRİME iliştirilir - hangi aramanın teyit
            //   edildiği belli olmalı.
            new("bildirimId", "p.bildirim_id", "sayi", "Bildirim Kaydı",
                Varsayilan: false),
            new("bildirimZamani", "p.bildirim_zamani", "tarihsaat", "Bildirim",
                Genislik: 150, Varsayilan: false),
            new("bildirilenAd", "p.bildirilen_ad", "metin", "Bildirilen Kişi",
                Genislik: 180, Varsayilan: false),
            new("yukseltme", "p.yukseltme", "mantik", "Yükseltildi", Hizalama: "orta",
                Genislik: 90),
        });

    /// <summary>
    /// BEBEK / ÇOCUK İZLEMLERİ (899, KTS H10 / USS 209).
    ///
    /// Persentil kolonları eğri verisi (`cocuk_buyume_lms`) yüklüyse dolu
    /// gelir; boşsa "hesaplanamadı" demektir, "sıfırıncı persentil" değil.
    /// </summary>
    private static KaynakTanimi CocukIzlem() => new(
        Ad: "cocuk-izlem",
        YetkiKodu: "cocuk.izlem",
        Kaynak: "public.v_cocuk_izlem i",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.izlem_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "i.id",      "sayi",  "Id", Varsayilan: false),
            new("tarafId", "i.taraf_id", "sayi", "Hasta Id", Varsayilan: false),
            new("cocuk",   "i.cocuk",   "metin", "Çocuk", Genislik: 220),
            new("kacinciIzlem", "i.kacinci_izlem", "sayi", "İzlem", Hizalama: "sag",
                Genislik: 70),
            new("izlemTarihi", "i.izlem_tarihi", "tarihsaat", "Tarih", Genislik: 150),
            new("yasAy",   "i.yas_ay",  "sayi",  "Yaş (ay)", Hizalama: "sag", Genislik: 80),
            new("boyCm",   "i.boy_cm",  "sayi",  "Boy (cm)", Hizalama: "sag", Genislik: 90),
            new("kiloKg",  "i.kilo_kg", "sayi",  "Kilo (kg)", Hizalama: "sag", Genislik: 90),
            new("basCevresiCm", "i.bas_cevresi_cm", "sayi", "Baş Ç. (cm)",
                Hizalama: "sag", Genislik: 100, Varsayilan: false),
            new("kiloPersentil", "i.kilo_persentil", "sayi", "Kilo %", Hizalama: "sag",
                Genislik: 80),
            new("boyPersentil", "i.boy_persentil", "sayi", "Boy %", Hizalama: "sag",
                Genislik: 80),
            new("basPersentil", "i.bas_persentil", "sayi", "Baş %", Hizalama: "sag",
                Genislik: 80, Varsayilan: false),
            new("hemoglobin", "i.hemoglobin", "sayi", "Hb", Hizalama: "sag",
                Genislik: 70, Varsayilan: false),
            new("enabizDurum", "i.enabiz_durum", "sayi", "e-Nabız", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("durum",   "i.durum",   "kod",   "Durum", Hizalama: "orta", Genislik: 90,
                Kodlar: CocukIzlemDurumlari),
            new("oneri",   "i.oneri",   "metin", "Öneri", Genislik: 260, Varsayilan: false),
        });

    /// <summary>BÜYÜME EĞRİSİ LMS VERİSİ (899): WHO/Bakanlık tabloları.</summary>
    private static KaynakTanimi CocukBuyumeLms() => new(
        Ad: "cocuk-buyume-lms",
        YetkiKodu: "cocuk.buyume_lms",
        Kaynak: "public.cocuk_buyume_lms b",
        SubeKolonu: null,
        VarsayilanSirala: "b.kaynak, b.cinsiyet, b.olcut, b.ay",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "b.id",     "sayi",  "Id", Varsayilan: false),
            new("kaynak", "b.kaynak", "metin", "Kaynak", Hizalama: "orta", Genislik: 90),
            new("cinsiyet", "b.cinsiyet", "kod", "Cinsiyet", Hizalama: "orta",
                Genislik: 90, Kodlar: CocukCinsiyetKodlari),
            new("olcut",  "b.olcut",  "kod",   "Ölçüt", Hizalama: "orta", Genislik: 110,
                Kodlar: CocukOlcutKodlari),
            new("ay",     "b.ay",     "sayi",  "Ay", Hizalama: "sag", Genislik: 60),
            new("l",      "b.l",      "sayi",  "L", Hizalama: "sag", Genislik: 90),
            new("m",      "b.m",      "sayi",  "M", Hizalama: "sag", Genislik: 90),
            new("s",      "b.s",      "sayi",  "S", Hizalama: "sag", Genislik: 90),
        });

    /// <summary>GEBELİK DOSYALARI (900, KTS H10).</summary>
    private static KaynakTanimi Gebelik() => new(
        Ad: "gebelik",
        YetkiKodu: "gebe.dosya",
        Kaynak: "public.v_gebelik g",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.durum asc, g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "g.id",      "sayi",  "Id", Varsayilan: false),
            new("tarafId", "g.taraf_id", "sayi", "Hasta Id", Varsayilan: false),
            new("gebe",    "g.gebe",    "metin", "Gebe", Genislik: 220),
            new("gebelikNo", "g.gebelik_no", "sayi", "Gebelik", Hizalama: "sag",
                Genislik: 80),
            new("sat",     "g.sat",     "tarih", "Son Adet", Hizalama: "orta",
                Genislik: 110),
            new("tahminiDogum", "g.tahmini_dogum", "tarih", "Tahmini Doğum",
                Hizalama: "orta", Genislik: 120),
            new("hafta",   "g.hafta",   "sayi",  "Hafta", Hizalama: "sag", Genislik: 70),
            new("izlemSayisi", "g.izlem_sayisi", "sayi", "İzlem", Hizalama: "sag",
                Genislik: 70),
            new("riskDurumu", "g.risk_durumu", "mantik", "Riskli", Hizalama: "orta",
                Genislik: 70),
            new("durum",   "g.durum",   "kod",   "Durum", Hizalama: "orta", Genislik: 110,
                Kodlar: GebelikDurumlari),
            new("sonucTarihi", "g.sonuc_tarihi", "tarih", "Sonuç", Hizalama: "orta",
                Genislik: 110, Varsayilan: false),
            new("aciklama", "g.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
        });

    /// <summary>GEBELİK SONUÇLARI (902, USS 224).</summary>
    private static KaynakTanimi GebelikSonuc() => new(
        Ad: "gebelik-sonuc",
        YetkiKodu: "gebe.sonuc",
        Kaynak: "public.v_gebelik_sonuc s",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.sonlanma_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "s.id",      "sayi",  "Id", Varsayilan: false),
            new("gebelikId", "s.gebelik_id", "sayi", "Dosya", Varsayilan: false),
            new("gebe",    "s.gebe",    "metin", "Gebe", Genislik: 220),
            new("gebelikNo", "s.gebelik_no", "sayi", "Gebelik", Hizalama: "sag",
                Genislik: 80, Varsayilan: false),
            new("sonlanmaTarihi", "s.sonlanma_tarihi", "tarihsaat", "Sonlanma",
                Genislik: 150),
            new("sonlanmaHaftasi", "s.sonlanma_haftasi", "sayi", "Hafta",
                Hizalama: "sag", Genislik: 70),
            new("sonuc",   "s.sonuc",   "sayi",  "Sonuç (SKRS)", Hizalama: "orta",
                Genislik: 110),
            new("dogumYontemi", "s.dogum_yontemi", "sayi", "Yöntem", Hizalama: "orta",
                Genislik: 90),
            new("canliBebek", "s.canli_bebek", "sayi", "Canlı", Hizalama: "sag",
                Genislik: 70),
            new("oluBebek", "s.olu_bebek", "sayi", "Ölü", Hizalama: "sag", Genislik: 70),
            new("izlemSayisi", "s.izlem_sayisi", "sayi", "İzlem", Hizalama: "sag",
                Genislik: 70, Varsayilan: false),
            new("enabizDurum", "s.enabiz_durum", "sayi", "e-Nabız", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("durum",   "s.durum",   "kod",   "Durum", Hizalama: "orta", Genislik: 90,
                Kodlar: CocukIzlemDurumlari),
            new("aciklama", "s.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
        });

    /// <summary>GEBE İZLEMLERİ (900, USS 221).</summary>
    private static KaynakTanimi GebeIzlem() => new(
        Ad: "gebe-izlem",
        YetkiKodu: "gebe.izlem",
        Kaynak: "public.v_gebe_izlem i",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.izlem_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "i.id",      "sayi",  "Id", Varsayilan: false),
            new("gebelikId", "i.gebelik_id", "sayi", "Dosya", Varsayilan: false),
            new("gebe",    "i.gebe",    "metin", "Gebe", Genislik: 220),
            new("kacinciIzlem", "i.kacinci_izlem", "sayi", "İzlem", Hizalama: "sag",
                Genislik: 70),
            new("hafta",   "i.hafta",   "sayi",  "Hafta", Hizalama: "sag", Genislik: 70),
            new("izlemTarihi", "i.izlem_tarihi", "tarihsaat", "Tarih", Genislik: 150),
            new("kiloKg",  "i.kilo_kg", "sayi",  "Kilo (kg)", Hizalama: "sag", Genislik: 90),
            // TANSİYON TEK KOLONDA: 120/80 iki hücrede okunmaz.
            new("tansiyon",
                "case when i.sistolik is null and i.diastolik is null then ''"
                + " else coalesce(i.sistolik::text, '?') || '/' "
                + "      || coalesce(i.diastolik::text, '?') end",
                "metin", "TA", Hizalama: "orta", Genislik: 80),
            new("fetusKalpSesi", "i.fetus_kalp_sesi", "sayi", "FKS", Hizalama: "sag",
                Genislik: 70),
            new("hemoglobin", "i.hemoglobin", "sayi", "Hb", Hizalama: "sag", Genislik: 70),
            new("riskSayisi", "i.risk_sayisi", "sayi", "Risk", Hizalama: "sag",
                Genislik: 70),
            new("enabizDurum", "i.enabiz_durum", "sayi", "e-Nabız", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("durum",   "i.durum",   "kod",   "Durum", Hizalama: "orta", Genislik: 90,
                Kodlar: CocukIzlemDurumlari),
            new("oneri",   "i.oneri",   "metin", "Öneri", Genislik: 240, Varsayilan: false),
        });

    /// <summary>AŞI KATALOĞU (898, KTS H10): SKRS kodlu aşı tanımları.</summary>
    private static KaynakTanimi AsiKatalogu() => new(
        Ad: "asi",
        YetkiKodu: "asi.katalog",
        Kaynak: "public.asi a left join public.stok s on s.id = a.stok_id",
        SubeKolonu: null,
        VarsayilanSirala: "a.sira asc, a.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",   "a.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",  "a.kod",  "metin", "Kod", Hizalama: "orta", Genislik: 90),
            new("ad",   "a.ad",   "metin", "Aşı", Genislik: 240),
            // SKRS KODU OLMAYAN AŞI e-NABIZ'A GİDEMEZ: kolon listede görünür
            //   olmalı ki eksik kalan fark edilsin.
            new("skrsKod", "a.skrs_kod", "metin", "SKRS Kodu", Hizalama: "orta",
                Genislik: 110),
            new("dozSayisi", "a.doz_sayisi", "sayi", "Şema (doz)", Hizalama: "sag",
                Genislik: 90),
            new("stok", "coalesce(s.ad, '')", "metin", "Stok Kartı", Genislik: 200),
            new("aciklama", "a.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
            new("aktif", "a.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
        });

    /// <summary>AŞI UYGULAMALARI (898): hasta bazlı kayıt - USS 207'nin kaynağı.</summary>
    private static KaynakTanimi AsiUygulama() => new(
        Ad: "asi-uygulama",
        YetkiKodu: "asi",
        Kaynak: "public.v_asi_uygulama u",
        SubeKolonu: "u.sube_id",
        VarsayilanSirala: "u.uygulama_zamani desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "u.id",      "sayi",  "Id", Varsayilan: false),
            new("tarafId", "u.taraf_id", "sayi", "Hasta Id", Varsayilan: false),
            new("hasta",   "u.hasta",   "metin", "Hasta", Genislik: 220),
            new("kimlikNo", "coalesce(u.kimlik_no, '')", "metin", "Kimlik No",
                Hizalama: "orta", Genislik: 110),
            new("asi",     "u.asi_kod || ' · ' || u.asi", "metin", "Aşı", Genislik: 240),
            new("dozNo",   "u.doz_no",  "sayi",  "Doz", Hizalama: "sag", Genislik: 60),
            new("kalanDoz", "u.kalan_doz", "sayi", "Kalan Doz", Hizalama: "sag",
                Genislik: 90, Varsayilan: false),
            new("lot",     "u.lot",     "metin", "Lot", Hizalama: "orta", Genislik: 110),
            new("barkod",  "u.barkod",  "metin", "Barkod", Hizalama: "orta", Genislik: 150,
                Varsayilan: false),
            new("uygulamaZamani", "u.uygulama_zamani", "tarihsaat", "Uygulama",
                Genislik: 150),
            new("uygulayan", "u.uygulayan", "metin", "Uygulayan", Genislik: 180),
            new("skrsKod", "u.skrs_kod", "metin", "SKRS", Hizalama: "orta", Genislik: 90,
                Varsayilan: false),
            new("enabizDurum", "u.enabiz_durum", "sayi", "e-Nabız", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("durum",   "u.durum",   "kod",   "Durum", Hizalama: "orta", Genislik: 90,
                Kodlar: AsiDurumlari),
            new("iptalNeden", "u.iptal_neden", "metin", "İptal Nedeni", Genislik: 220,
                Varsayilan: false),
        });

    /// <summary>ARŞİV KONUMLARI (890): ünite > raf > kutu.</summary>
    private static KaynakTanimi LabArsivKonum() => new(
        Ad: "lab-arsiv-konum",
        YetkiKodu: "lab.arsiv_konum",
        Kaynak: "public.lab_arsiv_konum k",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",      "k.kod",  "metin", "Kod", Hizalama: "orta", Genislik: 100),
            new("ad",       "k.ad",   "metin", "Ad", Genislik: 200),
            new("yol",      "public.fn_lab_arsiv_yol(k.id)", "metin", "Yol", Genislik: 280),
            new("tur",      "k.tur",  "kod",   "Tür", Hizalama: "orta", Genislik: 100,
                Kodlar: LabArsivKonumTurleri),
            new("sicaklik", "k.sicaklik", "sayi", "Hedef °C", Hizalama: "sag", Genislik: 80),
            new("satir",    "k.satir", "sayi", "Satır", Hizalama: "sag", Genislik: 60),
            new("sutun",    "k.sutun", "sayi", "Sütun", Hizalama: "sag", Genislik: 60),
            new("aciklama", "k.aciklama", "metin", "Açıklama", Genislik: 240, Varsayilan: false),
            new("aktif",    "k.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
        });

    /// <summary>SAKLAMA SÜRELERİ (890): tetkike özel kural genel kuralı ezer.</summary>
    private static KaynakTanimi LabSaklamaPolitika() => new(
        Ad: "lab-saklama-politika",
        YetkiKodu: "lab.saklama_politika",
        Kaynak: "public.lab_saklama_politika p left join public.lab_tetkik t on t.id = p.tetkik_id",
        SubeKolonu: null,
        VarsayilanSirala: "p.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "p.id",  "sayi",  "Id", Varsayilan: false),
            new("tetkik",   "coalesce(t.kod || ' · ' || t.ad, 'Tüm tetkikler')", "metin",
                "Tetkik", Genislik: 240),
            new("numuneTipi", "p.numune_tipi", "sayi", "Numune Tipi", Hizalama: "orta",
                Genislik: 100),
            new("gun",      "p.gun", "sayi", "Saklama (gün)", Hizalama: "sag", Genislik: 110),
            new("sicaklik", "p.sicaklik", "sayi", "°C", Hizalama: "sag", Genislik: 60),
            new("dayanak",  "p.dayanak", "metin", "Dayanak", Genislik: 220),
            new("aciklama", "p.aciklama", "metin", "Açıklama", Genislik: 240, Varsayilan: false),
            new("aktif",    "p.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
        });

    /// <summary>REFLEKS TEST KURALLARI (873 §6): kurum laboratuvarı tanımlar.</summary>
    private static KaynakTanimi LabRefleksKural() => new(
        Ad: "lab-refleks-kural",
        YetkiKodu: "lab.tetkik",
        Kaynak: "public.lab_refleks_kural k join public.lab_tetkik t on t.id = k.tetkik_id join public.lab_tetkik h on h.id = k.hedef_tetkik_id",
        SubeKolonu: null,
        VarsayilanSirala: "t.kod asc, k.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",     "sayi",  "Id", Varsayilan: false),
            new("tetkik",   "t.kod || ' · ' || t.ad", "metin", "Kaynak Tetkik", Genislik: 220),
            new("kosul",    "k.kosul",  "metin", "Koşul", Hizalama: "orta", Genislik: 80),
            new("esik",     "k.esik",   "sayi",  "Eşik", Hizalama: "sag", Genislik: 90),
            new("hedef",    "h.kod || ' · ' || h.ad", "metin", "Eklenecek Tetkik", Genislik: 220),
            new("aciklama", "k.aciklama", "metin", "Açıklama", Genislik: 240),
            new("aktif",    "k.aktif",  "mantik", "Aktif", Hizalama: "orta", Genislik: 60),
        });

    /// <summary>AKILCI İSTEM KARARLARI (873): hekim gerekçeleri / vazgeçmeler / refleks-reflektif izi (Bakanlık analizi).</summary>
    private static KaynakTanimi LabAkilciGerekce() => new(
        Ad: "lab-akilci-gerekce",
        YetkiKodu: "lab",
        Kaynak: "public.lab_akilci_gerekce g "
              + "left join public.hizmet h on h.id = g.hizmet_id "
              + "left join public.taraf p on p.id = g.hekim_id "
              + "left join public.taraf ha on ha.id = g.hasta_id "
              + "left join public.lab_istem i on i.id = g.istem_id",
        SubeKolonu: "g.sube_id",
        // PORTAL: dış hekim yalnız kendi kararlarını, dış kurum kendi isteminin
        //   kararlarını, hasta kendi kayıtlarını görür (Bakanlık izi kurum içidir).
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: "g.hekim_id = {kullanici}",
            disKurum:  "i.dis_kurum_id = {kullanici}",
            hasta:     "g.hasta_id = {kullanici}"),
        VarsayilanSirala: "g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "g.id",       "sayi",  "Id", Varsayilan: false),
            new("tarih",     "g.ekleme_tarihi", "tarih", "Tarih", Genislik: 130),
            new("hasta",     "coalesce(ha.unvan, '')", "metin", "Hasta", Genislik: 200),
            new("hekim",     "coalesce(p.unvan, '')", "metin", "Hekim", Genislik: 180),
            new("test",      "coalesce(h.ad, '')", "metin", "Test", Genislik: 220),
            new("kuralTuru", "g.kural_turu", "metin", "Kural", Hizalama: "orta", Bicim: "rozet", Genislik: 90),
            new("karar",     "g.karar",    "metin", "Karar", Hizalama: "orta", Bicim: "rozet", Genislik: 80),
            new("gerekce",
                "coalesce((select d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id "
                + " where l.kod = case when g.kural_turu = 'brans' then 'lab.akilci_klinik_gerekce' else 'lab.akilci_gerekce' end "
                + "   and d.deger = g.gerekce_kod and d.dil = 0), '')",
                "metin", "Gerekçe", Genislik: 260, Siralanabilir: false),
            new("aciklama",  "g.aciklama", "metin", "Açıklama", Genislik: 240),
            new("istemNo",   "coalesce(i.istem_no, '')", "metin", "İstem No", Genislik: 110),
            new("sonSonucTarihi", "g.son_sonuc_tarihi", "tarih", "Önceki Sonuç", Genislik: 130, Varsayilan: false),
        });
}
