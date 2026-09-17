namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ONAY GELEN KUTUSU (738/739).
///
/// TEK KUTU, TÜM MODÜLLER. "Onayımda ne var" sorusu bugün yalnız Talepler
/// listesinden yanıtlanabiliyordu; izin, avans ve masraflı onarım gelince
/// kullanıcı aynı soruyu dört ekranda sormak zorunda kalırdı - ve birini
/// açmayı unutunca onay orada beklerdi.
///
/// SATIR BİR BASAMAKTIR, bir kayıt değil: aynı talebin iki basamağı iki ayrı
/// kişiye düşer. Kayıt başına tek satır gösterseydik, sıradaki basamağın
/// sahibi kendi işini göremezdi.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi OnayKutusu() => new(
        Ad: "onayKutusu",
        // YETKİ: onay kutusunu görmek ayrı bir iş değil - kayıtları görme
        //   yetkisi basamağın rolünde zaten var. Kutunun kendisi yalnız
        //   listeler; karar uçları kendi yetkilerini ayrıca ister.
        YetkiKodu: "panel",
        Kaynak: "public.v_onay_kutusu v",
        SubeKolonu: "v.sube_id",
        // GECİKEN ÖNCE, sonra en eski bekleyen: onay kuyruğunda "en yeni
        //   üstte" sıralaması, unutulanı en dibe iter.
        VarsayilanSirala: "v.gecikme_gun desc, v.baslama",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("onayId", "v.onay_id", "sayi", "Onay", Varsayilan: false),
            new("kaynakTur", "v.kaynak_tur", "sayi", "Kayıt Türü", Varsayilan: false),
            new("kaynakId", "v.kaynak_id", "sayi", "Kayıt Id", Varsayilan: false),
            // TÜR ROZETİ HER AKIŞ İÇİN: kutu beş modülü birden taşıyor ve
            //   "Diğer" yazan bir rozet, karar verecek kişiye önüne düşen
            //   şeyin ne olduğunu söylemez. Yeni akış eklenince buraya da
            //   bir dal gelir (v_onay_kutusu'ndaki dalın eşi).
            new("turAdi",
                "case v.kaynak_tur when 1241 then 'Satınalma Talebi'" +
                " when 904  then 'İzin'" +
                " when 1224 then 'Onarım'" +
                " when 1257 then 'Avans'" +
                " when 1256 then 'İskonto'" +
                " when 976  then 'Doküman'" +
                " else 'Diğer' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("kayitNo", "v.kayit_no", "metin", "Kayıt No", Genislik: 130),
            new("konu", "v.konu", "metin", "Konu", Genislik: 280),
            new("talepEden", "v.talep_eden", "metin", "Talep Eden", Genislik: 160),
            new("birim", "v.birim", "metin", "Birim", Genislik: 150),
            // ÖLÇÜ VE ADI AYRI KOLON: tutar mı gün mü olduğu akışa göre değişir.
            //   Tek "Tutar" başlığı koysaydık izin talebinde "14 TL" yazardı.
            new("olcu", "v.olcu", "ondalik", "Ölçü", Hizalama: "sag", Genislik: 120),
            new("olcuAdi", "v.olcu_adi", "metin", "Ölçü Birimi", Genislik: 110,
                Varsayilan: false),
            new("adimAd", "v.adim_ad", "metin", "Basamak", Genislik: 170),
            new("sira", "v.sira", "sayi", "Sıra", Hizalama: "sag", Genislik: 70,
                Varsayilan: false),
            new("rol", "v.rol", "sayi", "Rol", Varsayilan: false),
            new("durumAdi",
                "case v.durum when 0 then 'Bekliyor' when 3 then 'Bilgi istendi'" +
                " else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "v.durum", "sayi", "Durum Kodu", Varsayilan: false),
            new("gerekce", "v.gerekce", "metin", "Not", Genislik: 220, Varsayilan: false),
            new("baslama", "v.baslama", "zaman", "Başlama", Hizalama: "orta",
                Genislik: 140, Varsayilan: false),
            new("bekleyenGun", "(current_date - v.baslama::date)", "sayi", "Bekleme (gün)",
                Hizalama: "sag", Genislik: 120, Filtrelenebilir: false),
            new("termin", "v.termin", "zaman", "Termin", Hizalama: "orta", Genislik: 140),
            // GECİKME sessiz onay DEĞİLDİR: süre dolunca kimse onaylanmış
            //   sayılmaz, yalnız görünür olur.
            new("gecikmeGun", "v.gecikme_gun", "sayi", "Gecikme (gün)", Hizalama: "sag",
                Genislik: 120),
            new("akisAd", "v.akis_ad", "metin", "Akış", Genislik: 180, Varsayilan: false),
            new("akisKod", "v.akis_kod", "metin", "Akış Kodu", Varsayilan: false),
            new("atananKullaniciId", "v.atanan_kullanici_id", "sayi", "Atanan",
                Varsayilan: false),
        });
}
