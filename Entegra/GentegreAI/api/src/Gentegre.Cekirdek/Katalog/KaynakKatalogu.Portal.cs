namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PORTALA ÖZEL MALİ EKRANLAR (824) — dış kurum yöneticisi.
///
/// <para><b>Neden kurum içi ekranlar açılmadı:</b> `belge` listesi
/// <c>hastaAdi</c>, <c>doktor</c>, <c>poliklinik</c> kolonları taşıyor;
/// `cari-ekstre` satır açıklamasında başvuru faturasının metni geçiyor ve o
/// metin hasta adı içerebiliyor. Kullanıcı kararı: <i>"fatura satırında hasta
/// adı görünmesin"</i>.</para>
///
/// <para>Bunu "kolonu gizle" ile çözmek geçici olurdu: gizlenen kolon bir gün
/// varsayılan görünüme geri eklendiğinde sessizce açılır. <b>Olmayan kolon
/// açılamaz</b> - bu yüzden portal için DAR kaynak yazıldı.</para>
///
/// <para><b>Kapsam kurumun kendisi:</b> `{kullanici}` portal kapsam kimliğidir
/// (819) - kurum hesabı kişi başı açılıyor, kapsam kurumun cari kaydına
/// bağlanıyor. Klinik rol bu ekranları görmez (yetki `portal.mali` onda yok).
/// </para>
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>KURUMUN FATURALARI — başlık düzeyi: no, tarih, tutar, kalan.</summary>
    private static KaynakTanimi KurumBelge() => new(
        Ad: "kurum-belge",
        YetkiKodu: "portal.mali",
        // BELGE TÜRÜ `kasa_islem_turu`DAN, KOD ÜZERİNDEN: `belge` kaynağının
        //   (KaynakKatalogu.Belge.cs) kullandığı bağın aynısı. İlk yazımda
        //   olmayan bir tablo (`belge_turu`) ve yanlış kolon (`bt.id = b.tur`)
        //   vardı; ekran tarayıcıda 500 veriyordu - kolon varlığını kontrol
        //   eden test canlı sorguyu çalıştırmıyordu.
        Kaynak: "public.belge b "
              + "  left join public.kasa_islem_turu bt on bt.kod = b.tur",
        SubeKolonu: "b.sube_id",
        // SON KESİLEN ÖNCE: kurum "bu ayın faturası geldi mi" diye bakıyor.
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        // YALNIZ KURUM PORTALI: hasta ve dış hekim kendi faturasını buradan
        //   görmez - hastanın ödemesi başka bir ekranın (ve kararın) işi.
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: "false",
            disKurum:  "b.taraf_id = {kullanici}",
            hasta:     "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "b.id",            "sayi",  "Id", Varsayilan: false),
            new("belgeNo",     "b.belge_no",      "metin", "Belge No", Genislik: 150),
            new("belgeTarihi", "b.belge_tarihi",  "tarih", "Tarih", Hizalama: "orta",
                                                  Genislik: 110),
            new("turAdi",      "coalesce(bt.ad, '')", "metin", "Belge Türü", Genislik: 150,
                Filtrelenebilir: false),
            new("tur",         "b.tur",           "kod",   "Tür Kodu", Varsayilan: false),
            new("tutar",       "b.genel_toplam",  "para",  "Tutar", Hizalama: "sag",
                                                  Genislik: 130),
            // ÖDENEN, BELGEDE DEĞİL KASADA: `belge` tablosunda ödenen kolonu
            //   yok - tahsilat kasa işlemlerinden toplanır (kurum içi belge
            //   listesindeki `tahsilatDurum` ile AYNI hesap).
            new("odenen",      "(select coalesce(sum(ki.tutar), 0) from public.kasa_islem ki where ki.belge_id = b.id and ki.durum = 2)", "para", "Ödenen", Hizalama: "sag",
                                                  Genislik: 130, Filtrelenebilir: false),
            new("kalan",       "coalesce(b.genel_toplam, 0) - (select coalesce(sum(ki.tutar), 0) from public.kasa_islem ki where ki.belge_id = b.id and ki.durum = 2)",
                                                  "para",  "Kalan", Hizalama: "sag",
                                                  Genislik: 130, Filtrelenebilir: false),
            // ÖDENDİ Mİ: kurumun ilk sorusu bu; tutarı çıkarmak zorunda kalmasın.
            new("odemeDurum",
                "case when coalesce(b.genel_toplam, 0) - (select coalesce(sum(ki.tutar), 0) from public.kasa_islem ki where ki.belge_id = b.id and ki.durum = 2) <= 0.01 "
                + "then 'Ödendi' else 'Açık' end",
                "metin", "Ödeme", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            // Açık fatura sarı: "vadesi geçti" ayrımı için ödeme planı gerekir,
            //   o veri portalda yok - uydurma renk vermek yanlış olurdu.
            new("satirRengi",
                "case when coalesce(b.genel_toplam, 0) - (select coalesce(sum(ki.tutar), 0) from public.kasa_islem ki where ki.belge_id = b.id and ki.durum = 2) > 0.01 "
                + "then 'uyari' else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });

    /// <summary>KURUMUN EKSTRESİ — borç/alacak/bakiye. AÇIKLAMA KOLONU YOK.</summary>
    private static KaynakTanimi KurumEkstre() => new(
        Ad: "kurum-ekstre",
        YetkiKodu: "portal.mali",
        Kaynak: "public.v_cari_ekstre e",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.islem_tarihi, e.id",
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: "false",
            disKurum:  "e.taraf_id = {kullanici}",
            hasta:     "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "e.id",           "sayi",  "Id", Varsayilan: false),
            new("islemTarihi", "e.islem_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                                 Bicim: "dd.MM.yyyy", Genislik: 110),
            new("belgeNo",     "e.belge_no",     "metin", "Belge No", Genislik: 150),
            new("turAdi",      "e.tur_adi",      "metin", "İşlem", Genislik: 160,
                Filtrelenebilir: false),
            // `aciklama` BİLEREK YOK: başvuru faturasının açıklaması hasta adı
            //   taşıyabiliyor (kullanıcı kararı).
            new("borc",        "e.borc",         "para",  "Borç", Hizalama: "sag",
                                                 Genislik: 130),
            new("alacak",      "e.alacak",       "para",  "Alacak", Hizalama: "sag",
                                                 Genislik: 130),
            new("bakiye",      "e.yerel_bakiye", "para",  "Bakiye", Hizalama: "sag",
                                                 Genislik: 140, Siralanabilir: false,
                                                 Filtrelenebilir: false),
        });
}
