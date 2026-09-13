namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// İTS BİLDİRİMİ, laboratuvar istemi ve prim rol adayları.
///
/// KaynakKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1183 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// İTS BİLDİRİM KUYRUĞU (427) — ilaç karekod bildirimleri.
    ///
    /// ÜTS ile karıştırılmaz: ÜTS tıbbi cihaz, İTS ilaç. Ayrı kurum, ayrı
    /// servis, ayrı liste - tek ekranda toplamak iki farklı mevzuatı aynı
    /// kolonlara sıkıştırmak olurdu.
    /// </summary>
    private static KaynakTanimi ItsBildirim() => new(
        Ad: "its-bildirim",
        YetkiKodu: "stok",
        Kaynak: "public.its_bildirim b "
              + "  left join public.belge bg on bg.id = b.belge_id "
              + "  left join public.taraf k on k.vkno = b.karsi_gln",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.ekleme_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "b.id",          "sayi",  "Id", Varsayilan: false),
            new("turAdi",
                "case b.tur when 2 then 'Tüketim' when 3 then 'İade' "
                + "when 4 then 'Deaktivasyon' when 5 then 'Transfer' else 'Mal Alım' end",
                                               "metin", "Tür", Hizalama: "orta",
                                               Bicim: "rozet", Genislik: 120,
                                               Filtrelenebilir: false),
            new("tur",        "b.tur",         "kod",   "Tür Kodu", Varsayilan: false),
            new("islemTarihi","b.islem_tarihi","tarih", "İşlem", Hizalama: "orta",
                                               Bicim: "dd.MM.yyyy", Genislik: 110),
            // KUTU SAYISI: bildirimin buyuklugu satir sayisiyla olculur -
            //   "kac kutu bildirildi" en sik sorulan sey.
            new("kutuSayisi",
                "(select count(*) from public.its_bildirim_satir s where s.bildirim_id = b.id)",
                                               "sayi",  "Kutu", Hizalama: "orta", Genislik: 70),
            new("karsiGln",   "b.karsi_gln",   "metin", "Karşı GLN", Hizalama: "orta",
                                               Genislik: 130),
            new("karsiAd",    "coalesce(k.unvan, '')", "metin", "Karşı Taraf", Genislik: 200),
            new("belgeNo",    "coalesce(bg.belge_no, '')", "metin", "Belge", Hizalama: "orta",
                                               Genislik: 140, Varsayilan: false),
            new("durumAdi",
                """
                case b.durum when 0 then 'Hazırlanıyor' when 1 then 'Bekliyor'
                             when 2 then 'Gönderiliyor' when 3 then 'Gönderildi'
                             when 4 then 'Hatalı' when 5 then 'İptal' else '' end
                """,                           "metin", "Durum", Hizalama: "orta",
                                               Bicim: "rozet", Genislik: 120,
                                               Filtrelenebilir: false),
            new("durum",      "b.durum",       "kod",   "Durum Kodu", Varsayilan: false),
            new("itsNo",      "b.its_bildirim_no", "metin", "İTS No", Hizalama: "orta",
                                               Genislik: 160),
            new("deneme",     "b.deneme",      "sayi",  "Deneme", Hizalama: "orta",
                                               Genislik: 80, Varsayilan: false),
            new("hataMesaj",  "b.hata_mesaj",  "metin", "Hata", Genislik: 300,
                                               Varsayilan: false),
            // TEST ORTAMI ROZETI: canli ve test bildirimleri ayni listede
            //   durur; hangisinin gercek oldugu gorunmezse "gonderdik" sanip
            //   yasal yukumluluk atlanabilir.
            new("ortam",
                "case when b.test_mi = 1 then 'Test' else 'Canlı' end",
                                               "metin", "Ortam", Hizalama: "orta",
                                               Bicim: "rozet", Genislik: 80),
            new("eklemeTarihi","b.ekleme_tarihi","tarih","Oluşturma", Hizalama: "orta",
                                               Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                               Varsayilan: false)
        });

    private static KaynakTanimi LabIstem() => new(
        Ad: "lab-istem",
        YetkiKodu: "lab",
        Kaynak: "public.lab_istem i "
              + "  join public.taraf h on h.id = i.taraf_id "
              + "  left join public.taraf_hasta th on th.id = i.taraf_id "
              + "  left join public.belge b on b.id = i.belge_id "
              + "  left join public.v_personel_lookup p on p.id = i.personel_id "
              + "  left join public.taraf dk on dk.id = i.dis_kurum_id",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.istem_tarihi desc, i.id desc",
        // KOLON SIRASI = mockup lab_istem_numune_kabul.html grid'i:
        //   İstem No · Hasta · Yaş/C · Protokol · İsteyen · Öncelik ·
        //   Bölümler · Tüp · İstem · Numune · Durum.
        //   Sonuç sayaçları (Test/Sonuçlanan/Panik) bu ekranın işi değil -
        //   kolon seçiciden açılabilir ama varsayılan gelmez; kabul
        //   bankosunun sorusu "tüp hazır mı", "sonuç çıktı mı" değil.
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "i.id",           "sayi",  "Id", Varsayilan: false),
            new("istemNo",      "i.istem_no",     "metin", "İstem No", Hizalama: "orta",
                                                  Genislik: 120),
            new("hastaAdi",     "h.unvan",        "metin", "Hasta", Genislik: 200),
            // YAS/CINSIYET tek kolonda ("39 K"): iki ayri dar kolon yerine
            //   mockup'taki gibi tek okunur birim - referans araligi ve tup
            //   hacmi kararini birlikte etkilerler.
            new("yasCinsiyet",
                "trim(case when th.dogum_tarihi is null then '' "
                + "when age(th.dogum_tarihi) >= interval '2 years' "
                + "     then extract(year from age(th.dogum_tarihi))::int::text "
                + "when age(th.dogum_tarihi) >= interval '1 month' "
                + "     then (extract(year from age(th.dogum_tarihi))::int * 12 "
                + "           + extract(month from age(th.dogum_tarihi))::int)::text || ' ay' "
                + "else (current_date - th.dogum_tarihi)::text || ' g' end "
                + "|| ' ' || case coalesce(th.cinsiyet, 0) "
                + "               when 1 then 'E' when 2 then 'K' else '' end)",
                                                  "metin", "Yaş/C", Hizalama: "orta",
                                                  Genislik: 70, Filtrelenebilir: false),
            new("protokolNo",   "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                  Hizalama: "orta", Genislik: 120),
            new("dosyaNo",      "h.kod",          "metin", "Dosya No", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            new("bolumAdi",
                "case i.bolum when 2 then 'Mikrobiyoloji' when 3 then 'Genetik' "
                + "when 4 then 'Patoloji' when 9 then 'Diğer' else 'Biyokimya' end",
                                                  "metin", "Bölüm", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 130,
                                                  Filtrelenebilir: false,
                                                  Varsayilan: false),
            new("bolum",        "i.bolum",        "kod",   "Bölüm Kodu", Varsayilan: false),
            // ISTEYEN: dis istemde gonderen KURUM, ic istemde hekim. Mockup
            //   ikisini ayni kolonda gosteriyor ("Deniz Tip Merkezi (dis)").
            new("hekimAdi",
                "case when i.dis_kurum_id is not null "
                + "     then coalesce(dk.unvan, '') || ' (dış)' "
                + "     else coalesce(p.ad, '') end",
                                                  "metin", "İsteyen", Genislik: 180,
                                                  Filtrelenebilir: false),
            new("oncelikAdi",
                "case i.oncelik when 2 then 'Öncelikli' when 3 then 'Acil' "
                + "else 'Normal' end",            "metin", "Öncelik", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 100,
                                                  Filtrelenebilir: false),
            // Kac test var / kaci sonuclandi: teknisyen listede "bitti mi" gorsun.
            // 433'te lab_istem_test -> lab_istem_satir olarak adlandirildi;
            //   sonuc artik satirda degil lab_sonuc'ta durur (onay/duzeltme
            //   gecmisi tek satira sigmiyordu).
            new("testSayisi",
                "(select count(*) from public.lab_istem_satir t "
                + " where t.istem_id = i.id and t.durum <> 0)",
                                                  "sayi",  "Test", Hizalama: "sag", Genislik: 70,
                                                  Filtrelenebilir: false, Varsayilan: false),
            new("sonuclanan",
                "(select count(*) from public.lab_istem_satir t "
                + " where t.istem_id = i.id and t.durum in (3, 4, 5))",
                                                  "sayi",  "Sonuçlanan", Hizalama: "sag",
                                                  Genislik: 100, Filtrelenebilir: false,
                                                  Varsayilan: false),
            // BOLUMLER (mockup: "Biyokimya · Hematoloji · Mikrobiyoloji"):
            //   istem basligindaki tek bolum kodu, cok bolumlu istemde
            //   yaniltici - tup hangi laboratuvara gidecek sorusunun cevabi
            //   TETKIKLERIN bolumleridir.
            new("bolumler",
                "coalesce((select string_agg(distinct case t.bolum "
                + "               when 2 then 'Hematoloji' when 3 then 'Hormon' "
                + "               when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji' "
                + "               when 6 then 'Koagülasyon' when 7 then 'İdrar' "
                + "               when 9 then 'Diğer' else 'Biyokimya' end, ' · ') "
                + "            from public.lab_istem_satir s "
                + "            join public.lab_tetkik t on t.id = s.tetkik_id "
                + "           where s.istem_id = i.id and s.durum <> 0), '')",
                                                  "metin", "Bölümler", Genislik: 240,
                                                  Filtrelenebilir: false),
            // TUP SAYISI: barkod uretilmemis istem "0" gosterir - kan alma
            //   bankosu once plani cikarmasi gerektigini listede gorur.
            new("tupSayisi",
                "(select count(*) from public.lab_numune n where n.istem_id = i.id)",
                                                  "sayi",  "Tüp", Hizalama: "orta",
                                                  Genislik: 60, Filtrelenebilir: false),
            new("istemTarihi",  "i.istem_tarihi", "tarih", "İstem", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // NUMUNE: ilk tupun alim zamani. Bos ise numune HENUZ ALINMADI -
            //   mockup'ta bu kolon "—" ise satir "Numune bekliyor"dur.
            new("numuneZamani",
                "(select min(n.alim_zamani) from public.lab_numune n "
                + " where n.istem_id = i.id)",
                                                  "tarih", "Numune", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                                  Filtrelenebilir: false),
            // RET: reddedilen tup varsa satir kirmizi okunmali; cip de bunu
            //   suzer (mockup "Ret" cipi).
            new("retSayisi",
                "(select count(*) from public.lab_numune n "
                + " where n.istem_id = i.id and n.ret = 1)",
                                                  "sayi",  "Ret", Hizalama: "orta",
                                                  Genislik: 60, Varsayilan: false),
            new("disIstem",
                "case when i.dis_kurum_id is not null then 1 else 0 end",
                                                  "kod",   "Dış İstem", Varsayilan: false),
            // PANIK: onay kuyrugunda oncelik bu satirda; listede gorunmezse
            //   panik deger sirasini bekler.
            new("panikSayisi",
                "(select count(*) from public.lab_istem_satir t "
                + "  join public.lab_sonuc ls on ls.istem_satir_id = t.id "
                + " where t.istem_id = i.id and ls.panik = 1 and ls.durum <> 4)",
                                                  "sayi",  "Panik", Hizalama: "sag",
                                                  Genislik: 80, Filtrelenebilir: false,
                                                  Varsayilan: false),
            new("oncelik",      "i.oncelik",      "kod",   "Öncelik Kodu",
                                                  Varsayilan: false),
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
