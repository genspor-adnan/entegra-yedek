namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HASTANE ECZANESİ LİSTE KAYNAKLARI (722).
///
/// TÜRETİLEN KOLONLAR SQL'DE, İSTEMCİDE DEĞİL. "Kaç gün yeter", "kaç saat
/// geçti", "eksik ne" gibi sorular her satırda aynı hesapla yanıtlanmalı;
/// istemcide hesaplasaydık liste, döküm ve rapor üç ayrı sayı gösterirdi.
///
/// MİAD ÖNERİSİ TARİHE DEĞİL TÜKETİME BAKAR (`v_eczane_miad`): günlük 6 giden
/// kalem 14 gün kala iade edilmez, tüketilir. Aynı hesabı hem miad listesi hem
/// pano okusun diye görünümden geliyor.
/// </summary>
public static partial class KaynakKatalogu
{
    // ------------------------------------------------- eczacı kontrolü ----
    private static KaynakTanimi EczaneKontrol() => new(
        Ad: "eczaneKontrol",
        YetkiKodu: "eczane.order",
        Kaynak: @"public.eczane_kontrol k
                  join public.yatis_order o on o.id = k.order_id
                  left join public.yatis y on y.id = o.yatis_id
                  left join public.taraf h on h.id = y.hasta_id
                  left join public.taraf hk on hk.id = k.hekim_id
                  left join public.taraf ec on ec.id = k.eczaci_id
                  left join public.departman d on d.id = y.departman_id
                  left join public.yatak yt on yt.id = y.yatak_id",
        SubeKolonu: "k.sube_id",
        // BEKLEYEN ÖNCE, İÇİNDE DÜZEYE GÖRE: yüksek düzey uyarı (alerji)
        //   listenin başında durmalı - sırayı geliş zamanı belirlerse
        //   geçilemez uyarı sayfa altında kalır.
        VarsayilanSirala: "case when k.karar = 0 then 0 else 1 end, k.duzey desc, k.ekleme_tarihi",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("hastaAd", "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 160),
            new("yer", "coalesce(d.ad, '') || coalesce(' · ' || nullif(yt.kod, ''), '')",
                "metin", "Servis / Yatak", Genislik: 150, Filtrelenebilir: false),
            new("ilac", "coalesce(o.ad, '')", "metin", "İlaç", Genislik: 200),
            new("dozMetni",
                "coalesce(o.doz::text, '') || coalesce(' ' || nullif(o.birim, ''), '')" +
                " || coalesce(' · ' || nullif(o.siklik, ''), '')",
                "metin", "Doz / Sıklık", Genislik: 150, Filtrelenebilir: false),
            new("turAdi",
                "case k.tur when 1 then 'Alerji' when 2 then 'Etkileşim' when 3 then 'Doz'" +
                " when 4 then 'Mükerrer' when 5 then 'Yüksek riskli' when 6 then 'Uygulama yolu'" +
                " when 7 then 'Antibiyotik' when 8 then 'Sözel order' when 9 then 'Kontrollü'" +
                " else 'Diğer' end",
                "metin", "Uyarı", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur", "k.tur", "kod", "Uyarı Kodu", Varsayilan: false, Kodlar: EcKontrolTurKodlari),
            new("duzeyAdi",
                "case k.duzey when 1 then 'Bilgi' when 2 then 'Uyarı'" +
                " when 3 then 'Yüksek' else '' end",
                "metin", "Düzey", Hizalama: "orta", Genislik: 90, Bicim: "rozet",
                Filtrelenebilir: false),
            new("duzey", "k.duzey", "kod", "Düzey Kodu", Varsayilan: false,
                Kodlar: EcDuzeyKodlari),
            new("bulgu", "k.bulgu", "metin", "Bulgu", Genislik: 300),
            new("hekimAd", "coalesce(hk.unvan, '')", "metin", "Hekim", Genislik: 130),
            new("eczaciAd", "coalesce(ec.unvan, '')", "metin", "Eczacı", Genislik: 130),
            new("kararAdi",
                "case k.karar when 0 then 'Bekliyor' when 1 then 'Uygun'" +
                " when 2 then 'Öneri yapıldı' when 3 then 'Durduruldu' else '' end",
                "metin", "Karar", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("karar", "k.karar", "kod", "Karar Kodu", Varsayilan: false,
                Kodlar: EcKararKodlari),
            // BEKLEME SÜRESİ: eczacı kontrolü dozdan önce gelmeli - geciken
            //   uyarı, hastaya gitmiş ilaç demektir.
            new("beklemeDk",
                "case when k.karar = 0 then round(extract(epoch from" +
                " (now() - k.ekleme_tarihi)) / 60)::int end",
                "sayi", "Bekleme (dk)", Hizalama: "sag", Genislik: 110,
                Filtrelenebilir: false),
            new("onlenenHata", "k.onlenen_hata", "kod", "Önlenen Hata",
                Hizalama: "orta", Genislik: 110, Kodlar: EcEvetHayirKodlari),
            new("oneri", "k.oneri", "metin", "Öneri", Varsayilan: false),
            new("orderId", "k.order_id", "sayi", "Order Id", Varsayilan: false),
            new("subeId", "k.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // ------------------------------------------------------- ünite doz ----
    private static KaynakTanimi EczaneDoz() => new(
        Ad: "eczaneDoz",
        YetkiKodu: "eczane.doz",
        Kaynak: @"public.eczane_doz z
                  join public.order_uygulama u on u.id = z.uygulama_id
                  join public.yatis_order o on o.id = u.order_id
                  left join public.yatis y on y.id = o.yatis_id
                  left join public.taraf h on h.id = y.hasta_id
                  left join public.departman d on d.id = y.departman_id
                  left join public.yatak yt on yt.id = y.yatak_id
                  left join public.stok s on s.id = z.stok_id
                  left join public.stok_seri_lot l on l.id = z.seri_lot_id
                  left join public.taraf hz on hz.id = z.hazirlayan_id",
        SubeKolonu: "z.sube_id",
        VarsayilanSirala: "u.planlanan, d.ad, h.unvan",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "z.id", "sayi", "Id", Varsayilan: false),
            new("planlanan", "u.planlanan", "zaman", "Saat", Genislik: 130,
                Bicim: "HH:mm"),
            new("hastaAd", "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 160),
            new("yer", "coalesce(d.ad, '') || coalesce(' · ' || nullif(yt.kod, ''), '')",
                "metin", "Servis / Yatak", Genislik: 150, Filtrelenebilir: false),
            new("ilac", "coalesce(nullif(s.ad, ''), o.ad, '')", "metin", "İlaç", Genislik: 200),
            new("miktar", "z.miktar", "ondalik", "Miktar", Hizalama: "sag", Genislik: 90),
            new("lot", "coalesce(l.lot_no, '')", "metin", "Lot", Genislik: 100),
            new("skt", "l.son_kullanma_tarihi", "tarih", "SKT", Hizalama: "orta",
                Genislik: 100, Bicim: "MM.yyyy"),
            new("dozBarkod", "z.doz_barkod", "metin", "Doz Barkodu", Genislik: 150),
            new("hazirlayanAd", "coalesce(hz.unvan, '')", "metin", "Hazırlayan", Genislik: 140),
            // ÇİFT KONTROL yüksek riskli ilaçta zorunlu: yapılıp yapılmadığı
            //   listede görünsün, karta girmeden.
            new("kontrolVar",
                "case when z.kontrol_eden_id is not null then 1 else 0 end",
                "kod", "Çift Kontrol", Hizalama: "orta", Genislik: 110,
                Kodlar: EcEvetHayirKodlari, Filtrelenebilir: false),
            new("durumAdi",
                "case z.durum when 0 then 'Bekliyor' when 1 then 'Hazırlandı'" +
                " when 2 then 'Kontrol edildi' when 3 then 'Teslim edildi'" +
                " when 4 then 'Uygulandı' when 8 then 'İade' when 9 then 'İmha' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "z.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: EcDozDurumKodlari),
            new("teslimZamani", "z.teslim_zamani", "zaman", "Teslim", Genislik: 140,
                Varsayilan: false),
            new("subeId", "z.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // ---------------------------------------------------- hazırlama ----
    private static KaynakTanimi EczaneHazirlama() => new(
        Ad: "eczaneHazirlama",
        YetkiKodu: "eczane.hazirlama",
        Kaynak: @"public.eczane_hazirlama p
                  left join public.taraf h on h.id = p.hasta_id
                  left join public.taraf hz on hz.id = p.hazirlayan_id
                  left join public.taraf dg on dg.id = p.dogrulayan_id",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.planlanan",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "p.id", "sayi", "Id", Varsayilan: false),
            new("hazirlamaNo", "p.hazirlama_no", "metin", "No", Genislik: 110),
            new("turAdi",
                "case p.tur when 1 then 'Kemoterapi' when 2 then 'TPN'" +
                " when 3 then 'İnfüzyon' else 'Diğer' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur", "p.tur", "kod", "Tür Kodu", Varsayilan: false, Kodlar: EcHazirlamaTurKodlari),
            new("hastaAd", "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 170),
            new("protokol", "p.protokol", "metin", "Protokol", Genislik: 240),
            new("kur",
                "case when p.kur_toplam > 0 then p.kur_no::text || ' / ' || p.kur_toplam::text" +
                " else nullif(p.kur_no, 0)::text end",
                "metin", "Kür", Hizalama: "orta", Genislik: 80, Filtrelenebilir: false),
            new("vya", "p.vya_m2", "ondalik", "VYA (m²)", Hizalama: "sag", Genislik: 90),
            new("planlanan", "p.planlanan", "zaman", "Planlanan", Genislik: 140),
            // ÖN KOŞUL: hasta gelmeden hazırlanmaz - hazırlanıp iptal edilen
            //   kemoterapi çöpe gider. Listede tek bakışta görünmeli.
            new("hastaGeldi",
                "case when p.hasta_geldi_zamani is not null then 1 else 0 end",
                "kod", "Hasta Geldi", Hizalama: "orta", Genislik: 110,
                Kodlar: EcEvetHayirKodlari, Filtrelenebilir: false),
            new("ciftKontrol",
                "case when p.dogrulayan_id is not null then 1 else 0 end",
                "kod", "Çift Kontrol", Hizalama: "orta", Genislik: 110,
                Kodlar: EcEvetHayirKodlari, Filtrelenebilir: false),
            new("durumAdi",
                "case p.durum when 0 then 'Sırada' when 1 then 'Ön koşul bekliyor'" +
                " when 2 then 'Doz onayı bekliyor' when 3 then 'Hazırlanıyor'" +
                " when 4 then 'Hazır' when 5 then 'Teslim edildi'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "p.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: EcHazirlamaDurumKodlari),
            // SON KULLANIM hazırlama anından sayılır: kalan süre saatlerle
            //   ölçülür ve teslim edilmeyen ürün imhaya düşer.
            new("kalanDk",
                "case when p.son_kullanim is not null then" +
                " round(extract(epoch from (p.son_kullanim - now())) / 60)::int end",
                "sayi", "Kalan (dk)", Hizalama: "sag", Genislik: 100,
                Filtrelenebilir: false),
            new("sonKullanim", "p.son_kullanim", "zaman", "Son Kullanım", Genislik: 140,
                Varsayilan: false),
            new("hazirlayanAd", "coalesce(hz.unvan, '')", "metin", "Hazırlayan",
                Genislik: 140, Varsayilan: false),
            new("dogrulayanAd", "coalesce(dg.unvan, '')", "metin", "Doğrulayan",
                Genislik: 140, Varsayilan: false),
            new("hastaId", "p.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
            new("subeId", "p.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // --------------------------------------------------------- iade ----
    private static KaynakTanimi EczaneIade() => new(
        Ad: "eczaneIade",
        YetkiKodu: "eczane.iade",
        Kaynak: @"public.eczane_iade i
                  left join public.departman d on d.id = i.departman_id
                  left join public.stok s on s.id = i.stok_id
                  left join public.stok_seri_lot l on l.id = i.seri_lot_id
                  left join public.taraf kv on kv.id = i.karar_veren_id",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "case when i.karar = 0 then 0 else 1 end, i.ekleme_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "i.id", "sayi", "Id", Varsayilan: false),
            new("tarih", "i.ekleme_tarihi", "zaman", "Tarih", Genislik: 140),
            new("departmanAd", "coalesce(d.ad, '')", "metin", "Servis", Genislik: 150),
            new("ad", "coalesce(nullif(i.ad, ''), s.ad, '')", "metin", "İlaç", Genislik: 220),
            new("miktar", "i.miktar", "ondalik", "Miktar", Hizalama: "sag", Genislik: 90),
            new("lot", "coalesce(l.lot_no, '')", "metin", "Lot", Genislik: 100),
            new("iadeNeden", "i.iade_neden", "metin", "İade Nedeni", Genislik: 280),
            // ÜÇ SORU kararı belirler; üçü de "hayır" ise stoğa döner.
            //   Tek kolonda özetlenir: karar sonradan denetlenebilsin.
            new("engeller",
                "nullif(concat_ws(', '," +
                " case when i.ambalaj_acik = 1 then 'ambalaj açık' end," +
                " case when i.sulandirildi = 1 then 'sulandırılmış' end," +
                " case when i.soguk_zincir_bozuk = 1 then 'soğuk zincir' end), '')",
                "metin", "Engel", Genislik: 200, Filtrelenebilir: false),
            new("kararAdi",
                "case i.karar when 0 then 'Bekliyor' when 1 then 'Stoğa kabul'" +
                " when 2 then 'İmhaya' when 3 then 'Kasaya' else '' end",
                "metin", "Karar", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("karar", "i.karar", "kod", "Karar Kodu", Varsayilan: false,
                Kodlar: EcIadeKararKodlari),
            new("kararVerenAd", "coalesce(kv.unvan, '')", "metin", "Karar Veren",
                Genislik: 140, Varsayilan: false),
            new("stokId", "i.stok_id", "sayi", "Stok Id", Varsayilan: false),
            new("subeId", "i.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // --------------------------------------------------------- imha ----
    private static KaynakTanimi EczaneImha() => new(
        Ad: "eczaneImha",
        YetkiKodu: "eczane.imha",
        Kaynak: @"public.eczane_imha m
                  left join public.belge b on b.id = m.belge_id",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "m.tarih desc, m.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "m.id", "sayi", "Id", Varsayilan: false),
            new("tutanakNo", "m.tutanak_no", "metin", "Tutanak No", Genislik: 130),
            new("tarih", "m.tarih", "tarih", "Tarih", Hizalama: "orta", Genislik: 110),
            new("kalem",
                "(select count(*) from public.eczane_imha_satir x where x.imha_id = m.id)",
                "sayi", "Kalem", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("tutar",
                "(select coalesce(sum(x.tutar), 0) from public.eczane_imha_satir x" +
                " where x.imha_id = m.id)",
                "para", "Değer", Hizalama: "sag", Genislik: 120, Filtrelenebilir: false),
            // SİTOTOKSİK ATIK ayrı toplanır: tutanakta olup olmadığı listede
            //   görünmeli, ayrı kap ve ayrı taşıma gerektiriyor.
            new("sitotoksik",
                "case when exists (select 1 from public.eczane_imha_satir x" +
                " where x.imha_id = m.id and x.atik_sinifi = 2) then 1 else 0 end",
                "kod", "Sitotoksik", Hizalama: "orta", Genislik: 110,
                Kodlar: EcEvetHayirKodlari, Filtrelenebilir: false),
            new("durumAdi",
                "case m.durum when 0 then 'Açık' when 1 then 'Komisyon onayladı'" +
                " when 2 then 'İmha edildi' when 3 then 'İTS bildirildi' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "m.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: EcImhaDurumKodlari),
            new("komisyon", "m.komisyon", "metin", "Komisyon", Genislik: 240),
            new("belgeNo", "coalesce(b.belge_no, '')", "metin", "Çıkış Fişi",
                Genislik: 120, Varsayilan: false),
            new("subeId", "m.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // -------------------------------------------- kontrollü ilaç defteri ----
    private static KaynakTanimi KontrolluDefter() => new(
        Ad: "kontrolluDefter",
        YetkiKodu: "eczane.kontrollu",
        Kaynak: @"public.kontrollu_defter f
                  left join public.stok s on s.id = f.stok_id
                  left join public.stok_seri_lot l on l.id = f.seri_lot_id
                  left join public.taraf h on h.id = f.hasta_id
                  left join public.departman d on d.id = f.departman_id
                  left join public.taraf te on te.id = f.teslim_eden_id
                  left join public.taraf ta on ta.id = f.teslim_alan_id",
        SubeKolonu: "f.sube_id",
        VarsayilanSirala: "f.zaman desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "f.id", "sayi", "Id", Varsayilan: false),
            new("defterNo", "f.defter_no", "metin", "Defter No", Genislik: 120),
            new("zaman", "f.zaman", "zaman", "Zaman", Genislik: 150),
            new("hareketAdi",
                "case f.hareket when 1 then 'Giriş' when 2 then 'Çıkış'" +
                " when 3 then 'İade' when 4 then 'Artık imha' when 5 then 'Devir'" +
                " when 6 then 'Sayım' else '' end",
                "metin", "Hareket", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("hareket", "f.hareket", "kod", "Hareket Kodu", Varsayilan: false,
                Kodlar: EcDefterHareketKodlari),
            new("ad", "coalesce(nullif(f.ad, ''), s.ad, '')", "metin", "İlaç", Genislik: 200),
            new("miktar", "f.miktar", "ondalik", "Miktar", Hizalama: "sag", Genislik: 90),
            new("lot", "coalesce(l.lot_no, '')", "metin", "Lot", Genislik: 100,
                Varsayilan: false),
            new("receteRenkAdi",
                "case f.recete_renk when 1 then 'Kırmızı' when 2 then 'Yeşil' else '' end",
                "metin", "Reçete", Hizalama: "orta", Genislik: 90, Bicim: "rozet",
                Filtrelenebilir: false),
            new("receteRenk", "f.recete_renk", "kod", "Reçete Kodu", Varsayilan: false,
                Kodlar: EcReceteRenkKodlari),
            new("receteNo", "f.recete_no", "metin", "Reçete No", Genislik: 130),
            new("hastaAd", "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 150),
            new("departmanAd", "coalesce(d.ad, '')", "metin", "Birim", Genislik: 140),
            new("teslimEdenAd", "coalesce(te.unvan, '')", "metin", "Teslim Eden", Genislik: 140),
            new("teslimAlanAd", "coalesce(ta.unvan, '')", "metin", "Teslim Alan", Genislik: 140),
            // ÇİFT İMZA: teslim eden ve alan ayrı kişi olmalı. Eksikse
            //   listede görünsün - defter denetiminde ilk bakılan budur.
            new("ciftImza",
                "case when f.teslim_eden_id is not null and f.teslim_alan_id is not null" +
                " and f.teslim_eden_id <> f.teslim_alan_id then 1 else 0 end",
                "kod", "Çift İmza", Hizalama: "orta", Genislik: 100,
                Kodlar: EcEvetHayirKodlari, Filtrelenebilir: false),
            new("duzeltme",
                "case when f.duzeltilen_id is not null then 1 else 0 end",
                "kod", "Düzeltme", Hizalama: "orta", Genislik: 100,
                Kodlar: EcEvetHayirKodlari, Filtrelenebilir: false),
            new("subeId", "f.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // ---------------------------------------------------- miad takibi ----
    private static KaynakTanimi EczaneMiad() => new(
        Ad: "eczaneMiad",
        YetkiKodu: "stok",
        Kaynak: @"public.v_eczane_miad v
                  left join public.depo dp on dp.id = v.depo_id",
        VarsayilanSirala: "v.kalan_gun",
        Kolonlar: new KolonTanimi[]
        {
            new("stokId", "v.stok_id", "sayi", "Stok Id", Varsayilan: false),
            new("kod", "v.kod", "metin", "Kod", Genislik: 110),
            new("ad", "v.ad", "metin", "İlaç / Malzeme", Genislik: 250),
            new("depoAd", "coalesce(dp.ad, '')", "metin", "Depo", Genislik: 150),
            new("lotNo", "coalesce(v.lot_no, '')", "metin", "Lot", Genislik: 110),
            new("skt", "v.skt", "tarih", "SKT", Hizalama: "orta", Genislik: 110),
            new("kalanGun", "v.kalan_gun", "sayi", "Kalan Gün", Hizalama: "sag",
                Genislik: 100),
            new("miktar", "v.miktar", "ondalik", "Miktar", Hizalama: "sag", Genislik: 100),
            new("gunlukTuketim", "v.gunluk_tuketim", "ondalik", "Günlük Tüketim",
                Hizalama: "sag", Genislik: 120),
            // ÖNERİ TARİHE DEĞİL TÜKETİME BAKAR: günlük 6 giden kalem 14 gün
            //   kala iade edilmez, tüketilir. Hesap SQL'de - liste, döküm ve
            //   pano aynı öneriyi görsün.
            new("oneri",
                "case when v.kalan_gun < 0 then 'İmha'" +
                " when v.gunluk_tuketim > 0 and v.miktar / v.gunluk_tuketim <= v.kalan_gun" +
                "      then 'Tüketilir'" +
                " when v.kalan_gun <= 90 then 'İade / devir'" +
                " else 'İzlemde' end",
                "metin", "Öneri", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            // Eldeki miktar bu hızla kaç günde biter - "tüketilir mi" kararının dayanağı.
            new("tukenmeGun",
                "case when v.gunluk_tuketim > 0" +
                " then round(v.miktar / v.gunluk_tuketim)::int end",
                "sayi", "Tükenme (gün)", Hizalama: "sag", Genislik: 110,
                Filtrelenebilir: false),
            new("depoId", "v.depo_id", "sayi", "Depo Id", Varsayilan: false),
        });

    internal static readonly Dictionary<string, string> EcKontrolTurKodlari = new()
    {
        ["1"] = "Alerji", ["2"] = "Etkileşim", ["3"] = "Doz", ["4"] = "Mükerrer",
        ["5"] = "Yüksek riskli", ["6"] = "Uygulama yolu", ["7"] = "Antibiyotik",
        ["8"] = "Sözel order", ["9"] = "Kontrollü", ["99"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> EcDuzeyKodlari = new()
    {
        ["1"] = "Bilgi", ["2"] = "Uyarı", ["3"] = "Yüksek",
    };

    internal static readonly Dictionary<string, string> EcKararKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Uygun", ["2"] = "Öneri yapıldı", ["3"] = "Durduruldu",
    };

    internal static readonly Dictionary<string, string> EcDozDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Hazırlandı", ["2"] = "Kontrol edildi",
        ["3"] = "Teslim edildi", ["4"] = "Uygulandı", ["8"] = "İade", ["9"] = "İmha",
    };

    internal static readonly Dictionary<string, string> EcHazirlamaTurKodlari = new()
    {
        ["1"] = "Kemoterapi", ["2"] = "TPN", ["3"] = "İnfüzyon", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> EcHazirlamaDurumKodlari = new()
    {
        ["0"] = "Sırada", ["1"] = "Ön koşul bekliyor", ["2"] = "Doz onayı bekliyor",
        ["3"] = "Hazırlanıyor", ["4"] = "Hazır", ["5"] = "Teslim edildi", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> EcIadeKararKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Stoğa kabul", ["2"] = "İmhaya", ["3"] = "Kasaya",
    };

    internal static readonly Dictionary<string, string> EcImhaDurumKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Komisyon onayladı", ["2"] = "İmha edildi",
        ["3"] = "İTS bildirildi",
    };

    internal static readonly Dictionary<string, string> EcDefterHareketKodlari = new()
    {
        ["1"] = "Giriş", ["2"] = "Çıkış", ["3"] = "İade", ["4"] = "Artık imha",
        ["5"] = "Devir", ["6"] = "Sayım",
    };

    internal static readonly Dictionary<string, string> EcReceteRenkKodlari = new()
    {
        ["1"] = "Kırmızı (narkotik)", ["2"] = "Yeşil (psikotrop)",
    };

    internal static readonly Dictionary<string, string> EcEvetHayirKodlari = new()
    {
        ["1"] = "Evet", ["0"] = "Hayır",
    };
}
