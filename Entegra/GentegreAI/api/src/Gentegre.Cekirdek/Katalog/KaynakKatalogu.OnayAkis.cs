namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ONAY AKIŞI LİSTESİ (742).
///
/// LİSTE "BU AKIŞ İŞLİYOR MU" SORUSUNU YANITLAR: basamak sayısı, yürüyen
/// onay, geciken. Yalnız ad ve kod gösterseydik akış listesi bir sözlük
/// olurdu - oysa yöneticinin sorusu kuralın kendisi değil, sonucu.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi OnayAkisKaynagi() => new(
        Ad: "onayAkis",
        YetkiKodu: "kullanici.onay_akis",   // 1004 aşama 2: kendi kodu
        Kaynak: "public.v_onay_akis v",
        // ŞUBE SÜZMESİ YOK: akış KURUM GENELİ bir tanımdır - imza düzeni
        //   şubeye göre değişmez. Süzseydik şubesiz (kurum geneli) tanımlar
        //   listede hiç görünmezdi; nitekim ilk denemede liste boş geldi.
        SubeKolonu: null,
        VarsayilanSirala: "v.aktif desc, v.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("kod", "v.kod", "metin", "Akış Kodu", Genislik: 170),
            new("ad", "v.ad", "metin", "Adı", Genislik: 230),
            // KAYIT TÜRÜ ADI kart kataloğundaki tek listeden (OnKaynakTuruKodlari): sabit CASE yalnız satınalmayı
            //   biliyordu, öbür yedi akış "Bilinmiyor" görünüyordu (10.11.2026).
            new("kaynakTurAdi", KaynakTuruAdiIfade("v.kaynak_tur"),
                "metin", "Hangi Kayıt", Genislik: 170, Bicim: "rozet",
                Filtrelenebilir: false),
            new("kaynakTur", "v.kaynak_tur", "sayi", "Kayıt Türü", Varsayilan: false),
            new("olcuAdi", "v.olcu_adi", "metin", "Karar Ölçüsü", Genislik: 140),
            // BASAMAK ZİNCİRİ (mockup Ekranlar/Onay/onay_akis_listesi.html): aktif basamaklar sırayla, koşulu
            //   yanında - "Birim Sorumlusu › Mali İşler ≥ 50.000 › Mali İşler ⚑ bütçe › Muhasebe ⓘ".
            new("basamaklar",
                "coalesce((select string_agg(d.ad" +
                "   || case when coalesce(d.esik_alt, 0) > 0 then ' ≥ ' || trim(to_char(d.esik_alt, 'FM999G999G999G990D##'))" +
                "           when d.bayrak <> '' then ' ⚑ ' || d.bayrak else '' end" +
                "   || case when d.karar_turu = 1 then ' ⓘ' else '' end, ' › ' order by d.sira, d.id)" +
                "   from public.onay_akis_adim d where d.akis_id = v.id and d.aktif = 1), '')",
                "metin", "Basamaklar", Genislik: 420, Siralanabilir: false, Filtrelenebilir: false),
            new("basamak", "v.basamak", "sayi", "Basamak", Hizalama: "sag", Genislik: 90, Varsayilan: false),
            // TABAN BASAMAK SIFIRSA küçük kayıt hiç imzasız geçer - listede
            //   görünmeli, kart açmadan.
            new("tabanBasamak", "v.taban_basamak", "sayi", "Her Kayıtta",
                Hizalama: "sag", Genislik: 110),
            new("yuruyen", "v.yuruyen", "sayi", "Yürüyen", Hizalama: "sag", Genislik: 90),
            new("geciken", "v.geciken", "sayi", "Geciken", Hizalama: "sag", Genislik: 90),
            new("sonKullanim", "v.son_kullanim", "tarih", "Son Kullanım",
                Hizalama: "orta", Genislik: 120, Bicim: "dd.MM.yyyy HH:mm"),
            new("aktif", "v.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 280,
                Varsayilan: false),
        });

    /// <summary>kaynak_tur -> ad; kart kataloğundaki tek sözlükten CASE üretir (yeni tür = tek yer).</summary>
    private static string KaynakTuruAdiIfade(string kolon)
    {
        var dallar = string.Concat(KartKatalogu.OnKaynakTuruKodlari
            .Select(k => $" when {k.Key} then '{k.Value.Replace("'", "''")}'"));
        return $"case {kolon}{dallar} else 'Tür ' || {kolon}::text end";
    }
}
