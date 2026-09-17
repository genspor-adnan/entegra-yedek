namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SATINALMA LİSTE KAYNAKLARI (724).
///
/// SİPARİŞ VE FATURA `belge`DİR (tür 9 / 11): tutarlar oradan okunur,
/// burada yeniden hesaplanmaz. Süreç alanları (`belge_satinalma`) ve eşleştirme
/// sonucu (`satinalma_fatura_kontrol`) belgenin yanına ekleniyor.
///
/// BEKLEYEN ONAY SATIR SATIR: talep listesi "hangi basamakta, kaç gündür"
/// sorusunu yanıtlamalı. Tek "onayda" bayrağı, bekleyenin kim olduğunu
/// gizlerdi.
/// </summary>
public static partial class KaynakKatalogu
{
    // ---------------------------------------------------------- talep ----
    private static KaynakTanimi SatinalmaTalep() => new(
        Ad: "satinalmaTalep",
        YetkiKodu: "satinalma.talep",
        Kaynak: @"public.satinalma_talep t
                  left join public.departman d on d.id = t.departman_id
                  left join public.taraf i on i.id = t.isteyen_id
                  left join public.butce_kalem b on b.id = t.butce_kalem_id",
        SubeKolonu: "t.sube_id",
        // ACİL VE KRİTİK STOK ÖNCE: bekleyen yalnız kâğıt değil, hasta.
        VarsayilanSirala: "case when t.durum between 0 and 4 then 0 else 1 end," +
                          " t.oncelik, t.tarih",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "t.id", "sayi", "Id", Varsayilan: false),
            new("talepNo", "t.talep_no", "metin", "Talep No", Genislik: 120),
            new("tarih", "t.tarih", "tarih", "Tarih", Hizalama: "orta", Genislik: 110),
            new("departmanAd", "coalesce(d.ad, '')", "metin", "İsteyen Birim", Genislik: 150),
            new("isteyenAd", "coalesce(i.unvan, '')", "metin", "İsteyen", Genislik: 150,
                Varsayilan: false),
            // İlk kalem + kalan sayısı: liste satırı neyin talebi olduğunu
            //   söylemeli, karta girmeden.
            new("malzeme",
                "coalesce((select x.ad from public.satinalma_talep_satir x" +
                "           where x.talep_id = t.id order by x.sira, x.id limit 1), '')" +
                " || coalesce((select ' (+' || (count(*) - 1)::text || ' kalem)'" +
                "               from public.satinalma_talep_satir x" +
                "              where x.talep_id = t.id having count(*) > 1), '')",
                "metin", "Malzeme", Genislik: 260, Filtrelenebilir: false),
            new("kalem",
                "(select count(*) from public.satinalma_talep_satir x where x.talep_id = t.id)",
                "sayi", "Kalem", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("tahminiTutar", "t.tahmini_tutar", "para", "Tahmini", Hizalama: "sag",
                Genislik: 120),
            new("kaynakAdi",
                "case t.kaynak when 1 then 'Birim talebi' when 2 then 'Kritik stok'" +
                " when 3 then 'Arıza' when 4 then 'Periyodik' when 5 then 'Yatırım'" +
                " else 'Diğer' end",
                "metin", "Kaynak", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("kaynak", "t.kaynak", "kod", "Kaynak Kodu", Varsayilan: false,
                Kodlar: SaKaynakKodlari),
            new("oncelikAdi",
                "case t.oncelik when 1 then 'Acil' when 2 then 'Yüksek'" +
                " when 3 then 'Normal' else '' end",
                "metin", "Öncelik", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("oncelik", "t.oncelik", "kod", "Öncelik Kodu", Varsayilan: false,
                Kodlar: SaOncelikKodlari),
            new("butceAd", "coalesce(b.ad, '')", "metin", "Bütçe Kalemi", Genislik: 150),
            // BEKLEYEN BASAMAK: "onayda" demek yetmez, kimde beklediği görünmeli.
            // ONAY OMURGASI ÜZERİNDEN (738): basamaklar `onay_adim`da.
            //   Basamağın kendi ADI gösterilir - rol kodunu ikinci kez
            //   metne çevirmek, akış tanımındaki adı görmezden gelmekti
            //   ("Mali İşler (bütçe)" ile "Mali İşler" aynı rol, ayrı basamak).
            new("bekleyenBasamak",
                "(select v.adim_ad from public.v_onay_bekleyen v" +
                "  where v.kaynak_tur = 1241 and v.kaynak_id = t.id" +
                "  order by v.sira limit 1)",
                "metin", "Bekleyen", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("bekleyenGun",
                "(select (current_date - v.baslama::date) from public.v_onay_bekleyen v" +
                "  where v.kaynak_tur = 1241 and v.kaynak_id = t.id" +
                "  order by v.sira limit 1)",
                "sayi", "Bekleme (gün)", Hizalama: "sag", Genislik: 110,
                Filtrelenebilir: false),
            // GECİKEN BASAMAK: termini geçmiş onay, unutulmuş bir karardır.
            new("onayGecikmeGun",
                "coalesce((select max(v.gecikme_gun) from public.v_onay_bekleyen v" +
                "  where v.kaynak_tur = 1241 and v.kaynak_id = t.id), 0)",
                "sayi", "Onay Gecikmesi", Hizalama: "sag", Genislik: 120,
                Varsayilan: false),
            new("durumAdi",
                "case t.durum when 0 then 'Taslak' when 1 then 'Onayda'" +
                " when 2 then 'Onaylandı' when 3 then 'Reddedildi' when 4 then 'Teklifte'" +
                " when 5 then 'Siparişe dönüştü' when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 140, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "t.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: SaTalepDurumKodlari),
            // BİRLEŞTİRME FIRSATI: aynı stok için başka açık talep var mı.
            //   İki ayrı sipariş hem pahalı hem iki teslimat demek.
            new("birlestirilebilir",
                "case when exists (" +
                "  select 1 from public.satinalma_talep_satir a" +
                "    join public.satinalma_talep_satir c on c.stok_id = a.stok_id" +
                "    join public.satinalma_talep t2 on t2.id = c.talep_id" +
                "   where a.talep_id = t.id and a.stok_id is not null" +
                "     and t2.id <> t.id and t2.durum between 0 and 2) then 1 else 0 end",
                "kod", "Birleştirilebilir", Hizalama: "orta", Genislik: 130,
                Kodlar: SaEvetHayirKodlari),
            new("gerekce", "t.gerekce", "metin", "Gerekçe", Varsayilan: false),
            new("subeId", "t.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // --------------------------------------------------------- teklif ----
    private static KaynakTanimi SatinalmaTeklif() => new(
        Ad: "satinalmaTeklif",
        YetkiKodu: "satinalma.teklif",
        Kaynak: @"public.satinalma_teklif k
                  left join public.satinalma_talep t on t.id = k.talep_id
                  left join public.taraf f on f.id = k.karar_firma_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "case when k.durum between 0 and 2 then 0 else 1 end," +
                          " k.son_tarih, k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("teklifNo", "k.teklif_no", "metin", "Teklif No", Genislik: 120),
            new("konu", "k.konu", "metin", "Konu", Genislik: 260),
            new("usulAdi",
                "case k.usul when 1 then 'Doğrudan temin' when 2 then 'Teklif toplama'" +
                " when 3 then 'Açık ihale' when 4 then 'Pazarlık' else '' end",
                "metin", "Usul", Hizalama: "orta", Genislik: 140, Bicim: "rozet",
                Filtrelenebilir: false),
            new("usul", "k.usul", "kod", "Usul Kodu", Varsayilan: false, Kodlar: SaUsulKodlari),
            new("talepNo", "coalesce(t.talep_no, '')", "metin", "Talep", Genislik: 110),
            new("tahminiBedel", "k.tahmini_bedel", "para", "Tahmini Bedel",
                Hizalama: "sag", Genislik: 130),
            new("davetSayi",
                "(select count(*) from public.satinalma_teklif_firma x where x.teklif_id = k.id)",
                "sayi", "Davet", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("teklifSayi",
                "(select count(*) from public.satinalma_teklif_firma x" +
                " where x.teklif_id = k.id and x.durum >= 1 and x.durum <> 2)",
                "sayi", "Teklif", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("elenenSayi",
                "(select count(*) from public.satinalma_teklif_firma x" +
                " where x.teklif_id = k.id and x.durum = 3)",
                "sayi", "Elenen", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("sonTarih", "k.son_tarih", "zaman", "Son Teklif", Genislik: 140),
            // AĞIRLIK KİLİDİ: davet gittiyse ağırlıklar donmuştur. Listede
            //   görünsün - açık bir tekliften ağırlık değiştirmeye kalkışan
            //   kullanıcı reddi karttan önce burada görsün.
            new("agirlikKilit", "k.agirlik_kilit", "kod", "Ağırlık Kilidi",
                Hizalama: "orta", Genislik: 110, Kodlar: SaEvetHayirKodlari),
            new("durumAdi",
                "case k.durum when 0 then 'Hazırlık' when 1 then 'Davet gönderildi'" +
                " when 2 then 'Teklifler açıldı' when 3 then 'Karar verildi'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "k.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: SaTeklifDurumKodlari),
            new("kararFirma", "coalesce(f.unvan, '')", "metin", "Kazanan", Genislik: 170),
            // EN DÜŞÜK TEKLİF ALINMADIYSA gerekçe zorunlu: listede işaretlensin,
            //   denetimde ilk bakılan budur.
            new("enDusukAlindi",
                "case when k.durum = 3 and k.karar_firma_id is not null then" +
                "  case when k.karar_firma_id = (" +
                "      select x.firma_id from public.satinalma_teklif_firma x" +
                "       where x.teklif_id = k.id and x.durum in (4, 5) and x.tutar > 0" +
                "       order by x.tutar limit 1) then 1 else 0 end end",
                "kod", "En Düşük", Hizalama: "orta", Genislik: 100,
                Kodlar: SaEvetHayirKodlari),
            new("kararZamani", "k.karar_zamani", "zaman", "Karar", Genislik: 140,
                Varsayilan: false),
            new("subeId", "k.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // -------------------------------------------------------- sipariş ----
    // SİPARİŞ `belge` TÜR 9: tutarlar belgeden, süreç `belge_satinalma`dan.
    private static KaynakTanimi SatinalmaSiparis() => new(
        Ad: "satinalmaSiparis",
        YetkiKodu: "satinalma.siparis",
        Kaynak: @"public.belge b
                  join public.belge_satinalma s on s.id = b.id
                  left join public.taraf f on f.id = b.taraf_id
                  left join public.satinalma_talep t on t.id = s.talep_id
                  left join public.tedarikci_sozlesme sz on sz.id = s.sozlesme_id",
        SubeKolonu: "b.sube_id",
        SabitKosul: "b.tur = 9",
        VarsayilanSirala: "case when s.takip_durum in (0, 1) then 0 else 1 end," +
                          " s.soz_teslim, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "b.id", "sayi", "Id", Varsayilan: false),
            new("belgeNo", "coalesce(b.belge_no, '')", "metin", "Sipariş No", Genislik: 130),
            new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta",
                Genislik: 110),
            new("firmaAd", "coalesce(f.unvan, '')", "metin", "Tedarikçi", Genislik: 190),
            new("tutar", "b.genel_toplam", "para", "Tutar", Hizalama: "sag", Genislik: 130),
            new("sozTeslim", "s.soz_teslim", "tarih", "Söz Verilen", Hizalama: "orta",
                Genislik: 110),
            // GECİKME SÖZ VERİLEN TARİHTEN sayılır, sipariş tarihinden değil.
            new("gecikmeGun",
                "case when s.takip_durum in (0, 1) and s.soz_teslim is not null" +
                "      and s.soz_teslim < current_date" +
                " then (current_date - s.soz_teslim) end",
                "sayi", "Gecikme (gün)", Hizalama: "sag", Genislik: 110),
            new("takipAdi",
                "case s.takip_durum when 0 then 'Açık' when 1 then 'Kısmi teslim'" +
                " when 2 then 'Tamamlandı' when 8 then 'İptal' else '' end",
                "metin", "Takip", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("takipDurum", "s.takip_durum", "kod", "Takip Kodu", Varsayilan: false,
                Kodlar: SaTakipKodlari),
            new("cezaTutar", "s.ceza_tutar", "para", "Ceza", Hizalama: "sag", Genislik: 110),
            // CEZA HESAPLANIR AMA OTOMATİK KESİLMEZ: işlenip işlenmediği ayrı.
            new("cezaIslendi", "s.ceza_islendi", "kod", "Ceza İşlendi", Hizalama: "orta",
                Genislik: 110, Kodlar: SaEvetHayirKodlari),
            new("fiyatKaynak",
                "case when s.sozlesme_id is not null then 'Çerçeve anlaşma'" +
                " when s.teklif_id is not null then 'Teklif'" +
                " else 'Doğrudan' end",
                "metin", "Fiyat Kaynağı", Hizalama: "orta", Genislik: 140, Bicim: "rozet",
                Filtrelenebilir: false),
            new("sozlesmeNo", "coalesce(sz.sozlesme_no, '')", "metin", "Sözleşme",
                Genislik: 130, Varsayilan: false),
            new("talepNo", "coalesce(t.talep_no, '')", "metin", "Talep", Genislik: 110,
                Varsayilan: false),
            new("tarafId", "b.taraf_id", "sayi", "Tedarikçi Id", Varsayilan: false),
            new("subeId", "b.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // --------------------------------------------- fatura eşleştirmesi ----
    private static KaynakTanimi SatinalmaFatura() => new(
        Ad: "satinalmaFatura",
        YetkiKodu: "satinalma.fatura",
        Kaynak: @"public.satinalma_fatura_kontrol k
                  join public.belge b on b.id = k.fatura_belge_id
                  left join public.belge sp on sp.id = k.siparis_belge_id
                  left join public.taraf f on f.id = b.taraf_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "case when k.odeme_durum in (0, 2, 3) then 0 else 1 end," +
                          " b.belge_tarihi",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("faturaNo", "coalesce(b.belge_no, '')", "metin", "Fatura", Genislik: 140),
            new("firmaAd", "coalesce(f.unvan, '')", "metin", "Tedarikçi", Genislik: 190),
            new("siparisNo", "coalesce(sp.belge_no, '')", "metin", "Sipariş", Genislik: 130),
            new("siparisTutar", "k.siparis_tutar", "para", "Sipariş", Hizalama: "sag",
                Genislik: 120),
            new("teslimTutar", "k.teslim_tutar", "para", "Teslim", Hizalama: "sag",
                Genislik: 120),
            new("faturaTutar", "k.fatura_tutar", "para", "Fatura", Hizalama: "sag",
                Genislik: 120),
            new("farkTutar", "k.fark_tutar", "para", "Fark", Hizalama: "sag", Genislik: 120),
            new("sonucAdi",
                "case k.sonuc when 0 then 'Kontrol edilmedi' when 1 then 'Tuttu'" +
                " when 2 then 'Miktar farkı' when 3 then 'Fiyat farkı'" +
                " when 4 then 'Bilgi farkı' when 5 then 'Birden çok fark' else '' end",
                "metin", "Eşleştirme", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("sonuc", "k.sonuc", "kod", "Eşleştirme Kodu", Varsayilan: false,
                Kodlar: SaEslestirmeKodlari),
            new("odemeAdi",
                "case k.odeme_durum when 0 then 'Beklemede' when 1 then 'Ödemeye onay'" +
                " when 2 then 'Ödeme durduruldu' when 3 then 'İtiraz edildi'" +
                " when 4 then 'Düzeltildi' else '' end",
                "metin", "Ödeme", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("odemeDurum", "k.odeme_durum", "kod", "Ödeme Kodu", Varsayilan: false,
                Kodlar: SaOdemeKodlari),
            new("mahsupTutar", "k.mahsup_tutar", "para", "Mahsup", Hizalama: "sag",
                Genislik: 110, Varsayilan: false),
            new("farkMetni", "k.fark_metni", "metin", "Fark Açıklaması", Varsayilan: false),
            new("faturaBelgeId", "k.fatura_belge_id", "sayi", "Fatura Id", Varsayilan: false),
            new("subeId", "k.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // -------------------------------------------------- mal kabul ----
    private static KaynakTanimi SatinalmaKabul() => new(
        Ad: "satinalmaKabul",
        YetkiKodu: "satinalma.kabul",
        Kaynak: @"public.v_satinalma_kabul k
                  left join public.belge i on i.id = k.belge_id
                  left join public.belge sp on sp.id = k.siparis_belge_id
                  left join public.taraf f on f.id = i.taraf_id
                  left join public.departman b on b.id = k.kullanici_birim_id",
        SubeKolonu: "k.sube_id",
        // AÇIK TUTANAK ÜSTTE: sonucu girilmemiş muayene bekleyen iştir.
        VarsayilanSirala: "case when k.sonuc = 0 then 0 else 1 end, k.tarih desc, k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("tutanakNo", "coalesce(k.tutanak_no, '')", "metin", "Tutanak No", Genislik: 130),
            new("tarih", "k.tarih", "tarih", "Tarih", Hizalama: "orta", Genislik: 110),
            new("irsaliyeNo", "coalesce(i.belge_no, '')", "metin", "İrsaliye", Genislik: 130),
            new("siparisNo", "coalesce(sp.belge_no, '')", "metin", "Sipariş", Genislik: 130),
            new("firmaAd", "coalesce(f.unvan, '')", "metin", "Tedarikçi", Genislik: 190),
            new("kalem", "k.kalem", "sayi", "Kalem", Hizalama: "sag", Genislik: 80),
            // EKSİK ve RET AYRI SAYILIR: "5 kalemde eksik var" ile "2 kalem
            //   reddedildi" farklı iki sorudur - biri miktar, öteki kalite.
            new("eksikKalem", "k.eksik_kalem", "sayi", "Eksik", Hizalama: "sag", Genislik: 80),
            new("retKalem", "k.ret_kalem", "sayi", "Ret", Hizalama: "sag", Genislik: 80),
            // KISA MİAD SÖZLEŞMEDEN KIYASLANIR; sözleşme yoksa 0 gelir -
            //   uydurulmuş bir eşik kimseyi korumaz (733).
            new("kisaMiad", "k.kisa_miad", "sayi", "Kısa Miad", Hizalama: "sag", Genislik: 100),
            new("kabulTutar", "k.kabul_tutar", "para", "Kabul Tutarı",
                Hizalama: "sag", Genislik: 130, Bicim: "#,##0.00"),
            // KAREKOD (734). "8 / 12" tek sütunda: iki ayrı sütun olsaydı
            //   kullanıcı her satırda ikisini kafasında karşılaştırırdı.
            //   Beklenen 0 ise (ilaç olmayan kalem) tire - "0/0" yazmak
            //   "eksik okutuldu" gibi okunurdu.
            new("karekod",
                "case when coalesce(k.karekod_beklenen, 0) = 0" +
                "      and coalesce(k.karekod_okutulan, 0) = 0 then '—'" +
                " else coalesce(k.karekod_okutulan, 0)::text || ' / '" +
                "      || coalesce(k.karekod_beklenen, 0)::text end",
                "metin", "Karekod", Hizalama: "orta", Genislik: 100,
                Filtrelenebilir: false),
            // EKSİK OKUTMA SÜZÜLEBİLİR OLMALI: çipin bakacağı ölçülebilir alan.
            new("karekodEksik",
                "greatest(coalesce(k.karekod_beklenen, 0) - coalesce(k.karekod_okutulan, 0), 0)",
                "sayi", "Okutulmayan", Hizalama: "sag", Genislik: 110, Varsayilan: false),
            new("karekodOkutulan", "k.karekod_okutulan", "sayi", "Okutulan",
                Hizalama: "sag", Genislik: 100, Varsayilan: false),
            // İTS (736). KUTUSU OKUTULMUŞ AMA BİLDİRİLMEMİŞ tutanak,
            //   unutulmuş bir yasal yükümlülüktür - sütun onu görünür kılar.
            //   Hiç kutu okutulmamışsa tire: "bildirilmedi" demek, bildirimi
            //   gereken bir şey varmış gibi okunurdu.
            new("itsDurumAdi",
                "case when coalesce(k.karekod_okutulan, 0) = 0 then '—'" +
                " when k.its_durum is null then 'Bildirilmedi'" +
                " when k.its_durum = 0 then 'Taslak'" +
                " when k.its_durum = 1 then 'Kuyrukta'" +
                " when k.its_durum = 2 then 'Gönderiliyor'" +
                " when k.its_durum = 3 then 'Gönderildi'" +
                " when k.its_durum = 4 then 'HATALI' else '' end",
                "metin", "İTS", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("itsDurum", "coalesce(k.its_durum, -1)", "sayi", "İTS Kodu",
                Varsayilan: false),
            new("sonucAdi",
                "case k.sonuc when 0 then 'Açık' when 1 then 'Kabul'" +
                " when 2 then 'Kısmi kabul' when 3 then 'Ret' else '' end",
                "metin", "Sonuç", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("sonuc", "k.sonuc", "kod", "Sonuç Kodu", Varsayilan: false,
                Kodlar: SaKabulSonucKodlari),
            // SOĞUK ZİNCİR: gerekmiyorsa sütun boş kalır - "uygun" yazsaydık
            //   ölçülmemiş bir şeyi ölçülmüş gibi gösterirdik.
            new("sogukZincirAdi",
                "case when coalesce(k.soguk_zincir, 0) = 0 then ''" +
                " when k.soguk_zincir_uygun = 1 then 'Uygun'" +
                " when k.soguk_zincir_uygun = 2 then 'UYGUNSUZ' else 'Ölçülmedi' end",
                "metin", "Soğuk Zincir", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("sogukZincirUygun", "k.soguk_zincir_uygun", "kod", "Soğuk Zincir Kodu",
                Varsayilan: false, Kodlar: SaSogukKodlari),
            new("sicaklik", "k.sicaklik", "ondalik", "Sıcaklık (°C)",
                Hizalama: "sag", Genislik: 110, Varsayilan: false),
            new("kullaniciBirim", "coalesce(b.ad, '')", "metin", "Kullanıcı Birim",
                Genislik: 150, Varsayilan: false),
            new("kullaniciBirimOnay", "k.kullanici_birim_onay", "kod", "Birim Onayı",
                Hizalama: "orta", Genislik: 110, Kodlar: SaEvetHayirKodlari),
            new("komisyon", "coalesce(k.komisyon, '')", "metin", "Komisyon",
                Genislik: 200, Varsayilan: false),
            new("uygunsuzluk", "coalesce(k.uygunsuzluk, '')", "metin", "Uygunsuzluk",
                Genislik: 240, Varsayilan: false),
            new("belgeId", "k.belge_id", "sayi", "İrsaliye Belge", Varsayilan: false),
            new("siparisBelgeId", "k.siparis_belge_id", "sayi", "Sipariş Belge",
                Varsayilan: false),
            new("subeId", "k.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // ------------------------------------------------- tedarikçi skoru ----
    private static KaynakTanimi SatinalmaTedarikci() => new(
        Ad: "satinalmaTedarikci",
        YetkiKodu: "satinalma.tedarikci",
        Kaynak: @"public.v_tedarikci_skor v
                  join public.taraf t on t.id = v.firma_id",
        VarsayilanSirala: "v.skor",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.firma_id", "sayi", "Id", Varsayilan: false),
            new("unvan", "v.unvan", "metin", "Tedarikçi", Genislik: 240),
            new("vkno", "coalesce(t.vkno, '')", "metin", "VKN", Genislik: 120),
            new("skor", "v.skor", "ondalik", "Skor", Hizalama: "sag", Genislik: 90),
            // EŞİKLER: 70 altı izleme, 50 altı askı. Metin kolonu ki liste
            //   renklensin ve kullanıcı eşiği ezberlemek zorunda kalmasın.
            new("skorDurum",
                "case when v.skor < 50 then 'Askı eşiği' when v.skor < 70 then 'İzlemde'" +
                " else 'İyi' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("gecikme", "v.gecikme", "sayi", "Gecikme", Hizalama: "sag", Genislik: 90),
            new("uygunsuzluk", "v.uygunsuzluk", "sayi", "Uygunsuzluk", Hizalama: "sag",
                Genislik: 110),
            new("faturaFarki", "v.fatura_farki", "sayi", "Fatura Farkı", Hizalama: "sag",
                Genislik: 110),
            // SÜRESİ DOLAN BELGE YENİ SİPARİŞİ DURDURUR - listede uyarsın.
            new("belgeSuresiDoldu",
                "case when v.belge_suresi_doldu then 1 else 0 end",
                "kod", "Belge Süresi", Hizalama: "orta", Genislik: 110,
                Kodlar: SaBelgeKodlari),
            new("sozlesmeSayi",
                "(select count(*) from public.tedarikci_sozlesme z" +
                " where z.firma_id = v.firma_id and z.durum = 1)",
                "sayi", "Sözleşme", Hizalama: "sag", Genislik: 100,
                Filtrelenebilir: false),
        });

    // --------------------------------------------------------- bütçe ----
    private static KaynakTanimi SatinalmaButce() => new(
        Ad: "satinalmaButce",
        YetkiKodu: "satinalma.butce",
        Kaynak: "public.v_butce_durum v",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.kullanim_yuzde desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("yil", "v.yil", "sayi", "Yıl", Hizalama: "orta", Genislik: 80),
            new("kod", "v.kod", "metin", "Kod", Genislik: 110),
            new("ad", "v.ad", "metin", "Bütçe Kalemi", Genislik: 230),
            new("tutar", "v.tutar", "para", "Yıllık Bütçe", Hizalama: "sag", Genislik: 140),
            new("harcanan", "v.harcanan", "para", "Harcanan", Hizalama: "sag", Genislik: 140),
            // TAAHHÜT DE HARCAMADIR: açık sipariş faturalanmadı ama parası
            //   bağlandı. Ayrı gösterilir, kalandan düşülür.
            new("taahhut", "v.taahhut", "para", "Taahhüt", Hizalama: "sag", Genislik: 140),
            new("kalan", "v.kalan", "para", "Kalan", Hizalama: "sag", Genislik: 140),
            new("kullanimYuzde", "v.kullanim_yuzde", "ondalik", "Kullanım %",
                Hizalama: "sag", Genislik: 110),
            new("durumAdi",
                "case when v.kullanim_yuzde > 100 then 'Aşıldı'" +
                " when v.kullanim_yuzde >= 85 then 'İzlemde' else 'Normal' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("subeId", "v.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    internal static readonly Dictionary<string, string> SaKaynakKodlari = new()
    {
        ["1"] = "Birim talebi", ["2"] = "Kritik stok", ["3"] = "Arıza",
        ["4"] = "Periyodik", ["5"] = "Yatırım", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> SaOncelikKodlari = new()
    {
        ["1"] = "Acil", ["2"] = "Yüksek", ["3"] = "Normal",
    };

    internal static readonly Dictionary<string, string> SaTalepDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylandı", ["3"] = "Reddedildi",
        ["4"] = "Teklifte", ["5"] = "Siparişe dönüştü",
        // 6 BİRLEŞTİRİLDİ (akış ucu): kaynak talep SİLİNMEZ - "bu talebi kim
        //   açmıştı, ne oldu" sorusu birleştirmeden sonra da sorulur.
        //   `birlestirilen_id` hedefi gösterir. İptal (8) yazsaydık listede
        //   vazgeçilmiş taleple birleştirilmiş talep aynı görünürdü.
        ["6"] = "Birleştirildi", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> SaUsulKodlari = new()
    {
        ["1"] = "Doğrudan temin", ["2"] = "Teklif toplama", ["3"] = "Açık ihale",
        ["4"] = "Pazarlık",
    };

    internal static readonly Dictionary<string, string> SaTeklifDurumKodlari = new()
    {
        ["0"] = "Hazırlık", ["1"] = "Davet gönderildi", ["2"] = "Teklifler açıldı",
        ["3"] = "Karar verildi", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> SaTakipKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Kısmi teslim", ["2"] = "Tamamlandı", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> SaEslestirmeKodlari = new()
    {
        ["0"] = "Kontrol edilmedi", ["1"] = "Tuttu", ["2"] = "Miktar farkı",
        ["3"] = "Fiyat farkı", ["4"] = "Bilgi farkı", ["5"] = "Birden çok fark",
    };

    internal static readonly Dictionary<string, string> SaOdemeKodlari = new()
    {
        ["0"] = "Beklemede", ["1"] = "Ödemeye onay", ["2"] = "Ödeme durduruldu",
        ["3"] = "İtiraz edildi", ["4"] = "Düzeltildi",
    };

    internal static readonly Dictionary<string, string> SaBelgeKodlari = new()
    {
        ["1"] = "Süresi doldu", ["0"] = "Geçerli",
    };

    internal static readonly Dictionary<string, string> SaKabulSonucKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Kabul", ["2"] = "Kısmi kabul", ["3"] = "Ret",
    };

    internal static readonly Dictionary<string, string> SaSogukKodlari = new()
    {
        ["0"] = "Ölçülmedi", ["1"] = "Uygun", ["2"] = "Uygunsuz",
    };

    internal static readonly Dictionary<string, string> SaEvetHayirKodlari = new()
    {
        ["1"] = "Evet", ["0"] = "Hayır",
    };
}
