namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TELERADYOLOJİ NÖBET ÇİZELGESİ ve ATAMA KURALLARI (801) — liste kaynakları.
///
/// 797'de atama yalnız elleydi: gelen iş sırada bekliyor, birinin listeye
/// bakması gerekiyordu. Gece ve hafta sonu teleradyolojinin asıl iş saatidir;
/// o saatte listeye bakan kişi olmayabilir.
///
/// <b>Çizelge "şu an kim iş başında"yı,</b> kural <b>"hangi iş kime"yi</b>
/// söyler. İkisi de tanım ekranıdır - günlük işin (`telerad.ata`) değil,
/// kurulumun yetkisiyle açılır.
/// </summary>
public static partial class KaynakKatalogu
{
    private static readonly Dictionary<string, string> TeleradNobetTur = new()
        { ["1"] = "Gündüz", ["2"] = "Gece", ["3"] = "Hafta sonu", ["4"] = "Yedek" };

    private static readonly Dictionary<string, string> TeleradHedefTur = new()
        { ["1"] = "O anki nöbetçi", ["2"] = "Belirli radyolog", ["3"] = "En az yüklü" };

    /// <summary>NÖBET ÇİZELGESİ — kim, ne zaman iş başında.</summary>
    private static KaynakTanimi TeleradNobet() => new(
        Ad: "telerad-nobet",
        YetkiKodu: "teleradyoloji.nobet",
        // AÇIK İŞ SAYISI GÖRÜNÜMDEN: "nöbetçi kim" ile "üstünde kaç iş var"
        //   aynı satırda olmalı - çizelgeye bakan kişi devri buna göre yapar.
        Kaynak: "public.v_telerad_nobetci n",
        SubeKolonu: "n.sube_id",
        // ŞİMDİ NÖBETTE OLAN EN ÜSTTE, sonra yaklaşan vardiya: çizelgeye
        //   bakmanın sebebi çoğunlukla "şu an kim var" sorusudur.
        VarsayilanSirala: "n.su_an desc, n.baslangic desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "n.id",          "sayi",  "Id", Varsayilan: false),
            new("radyologAdi", "n.radyolog_adi", "metin", "Radyolog", Genislik: 200),
            new("suAnAdi",
                "case when n.su_an = 1 then 'NÖBETTE' else '' end",
                "metin", "Şimdi", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("turAdi",      "n.tur_adi",     "metin", "Vardiya", Hizalama: "orta",
                                                   Genislik: 110, Bicim: "rozet",
                                                   Filtrelenebilir: false),
            new("tur",         "n.tur",         "kod",   "Vardiya Kodu", Varsayilan: false,
                Kodlar: TeleradNobetTur),
            new("baslangic",   "n.baslangic",   "tarih", "Başlangıç", Hizalama: "orta",
                                                   Bicim: "dd.MM HH:mm"),
            new("bitis",       "n.bitis",       "tarih", "Bitiş", Hizalama: "orta",
                                                   Bicim: "dd.MM HH:mm"),
            new("acikIs",      "n.acik_is",     "sayi",  "Açık İş", Hizalama: "sag",
                                                   Genislik: 90),
            new("azamiIs",     "n.azami_is",    "sayi",  "Azami İş", Hizalama: "sag",
                                                   Genislik: 95),
            new("kurumId",     "n.kurum_id",    "sayi",  "Kurum Id", Varsayilan: false),
            new("modalite",    "n.modalite",    "kod",   "Modalite Kodu", Varsayilan: false),
            new("radyologId",  "n.radyolog_id", "sayi",  "Radyolog Id", Varsayilan: false),
            // ÇİP HAM DEĞERLE SÜZER: "Şimdi" kolonu rozet METNİ çizer ve
            //   filtrelenebilir değil - süzme etikete bağlanırsa etiket
            //   değişince çip sessizce boş liste getirirdi.
            new("suAn",        "n.su_an",       "mantik", "Şimdi Nöbette",
                                                   Varsayilan: false),
            // DOLAN NÖBETÇİ UYARI RENGİYLE: azami işi dolmuş radyolog
            //   çizelgede "var" görünür ama iş alamaz - satır bunu söylesin.
            //   Geçmiş vardiya soluk: bugünün çizelgesi öne çıksın.
            new("satirRengi",
                "case when n.bitis < now() then 'pasif' "
                + "when n.azami_is > 0 and n.acik_is >= n.azami_is then 'uyari' "
                + "else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });

    /// <summary>ATAMA KURALLARI — hangi iş kime.</summary>
    private static KaynakTanimi TeleradKural() => new(
        Ad: "telerad-kural",
        YetkiKodu: "teleradyoloji.kural",
        Kaynak: "public.telerad_atama_kurali k "
              + "  left join public.telerad_kurum tk on tk.id = k.kurum_id "
              + "  left join public.taraf kt on kt.id = tk.taraf_id "
              + "  left join public.taraf rt on rt.id = k.hedef_radyolog_id",
        SubeKolonu: "k.sube_id",
        // SIRA KARAR SIRASIDIR: ilk uyan kural kazanır - liste de o sırada
        //   okunmalı, yoksa hangi kuralın işlediği ekranda anlaşılmaz.
        VarsayilanSirala: "k.sira, k.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",       "sayi",  "Id", Varsayilan: false),
            new("sira",     "k.sira",     "sayi",  "Sıra", Hizalama: "sag", Genislik: 70),
            new("ad",       "k.ad",       "metin", "Kural", Genislik: 220),
            new("kurumAdi", "coalesce(public.fn_taraf_ad(kt.unvan, kt.ad, kt.soyad)::varchar(120), 'Tüm kurumlar')", "metin", "Kurum",
                                              Genislik: 190),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("k.modalite", "'Tümü'"),
                "metin", "Modalite", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("oncelikAdi",
                "case k.oncelik when 3 then 'ACİL' when 2 then 'Öncelikli' "
                + "when 1 then 'Rutin' else 'Tümü' end",
                "metin", "Öncelik", Hizalama: "orta", Genislik: 95, Bicim: "rozet",
                Filtrelenebilir: false),
            new("pencere",
                "case when k.saat_bas = '' or k.saat_bit = '' then 'Her saat' "
                + "else k.saat_bas || ' - ' || k.saat_bit end "
                + "|| case when k.gunler = '' then '' else ' · ' || k.gunler end",
                "metin", "Saat / Gün", Genislik: 150, Filtrelenebilir: false),
            new("hedefAdi",
                "case k.hedef_tur when 2 then coalesce(public.fn_taraf_ad(rt.unvan, rt.ad, rt.soyad)::varchar(120), '(radyolog silinmiş)') "
                + "when 3 then 'En az yüklü' else 'O anki nöbetçi' end",
                "metin", "Hedef", Genislik: 180, Filtrelenebilir: false),
            new("hedefTur", "k.hedef_tur", "kod", "Hedef Kodu", Varsayilan: false,
                Kodlar: TeleradHedefTur),
            new("azamiIs",  "k.azami_is", "sayi", "Azami İş", Hizalama: "sag",
                                              Genislik: 95),
            new("aktif",    "k.aktif",    "mantik", "Aktif", Hizalama: "orta"),
            new("kurumId",  "k.kurum_id", "sayi",  "Kurum Id", Varsayilan: false),
            // PASİF KURAL SOLUK: listede duruyor ama hiçbir işi dağıtmıyor -
            //   "kural var, neden çalışmıyor" sorusu buradan doğuyordu.
            new("satirRengi",
                "case when k.aktif = 0 then 'pasif' else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });
}
