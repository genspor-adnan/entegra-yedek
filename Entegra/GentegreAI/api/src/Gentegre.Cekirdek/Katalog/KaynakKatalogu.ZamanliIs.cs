namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ZAMANLI İŞLER (405) — ne zaman çalışacağı ve son durumu.
///
/// Liste "bu iş çalışıyor mu, ne zaman çalıştı, sonucu neydi" sorusunu tek
/// bakışta cevaplar: son sonuç ve süre kolonları bu yüzden varsayılan.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi ZamanliIs() => new(
        Ad: "zamanli-is",
        YetkiKodu: "zamanli_is",
        Kaynak: "public.zamanli_is z",
        VarsayilanSirala: "z.aktif desc, z.sonraki asc nulls last",
        Kolonlar: new KolonTanimi[]
        {
            new("kod",   "z.kod", "metin", "Kod", Genislik: 160),
            new("ad",    "z.ad",  "metin", "İş", Genislik: 280),
            new("periyotAdi",
                "case z.periyot when 1 then 'Saatlik' when 2 then 'Günlük' "
                + "when 4 then 'Aylık' else 'Haftalık' end",
                                 "metin", "Periyot", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            new("periyot", "z.periyot", "kod", "Periyot Kodu", Varsayilan: false),
            // ZAMAN tek hucrede okunur: "Pazartesi 04:00" gibi - gun ve saati
            //   ayri kolonlarda gostermek listeyi genisletiyordu.
            new("zaman",
                "case z.periyot "
                + " when 1 then 'her saat' "
                + " when 2 then to_char(make_time(z.saat, z.dakika, 0), 'HH24:MI') "
                + " when 4 then 'ayın ' || z.gun || '. günü ' "
                + "         || to_char(make_time(z.saat, z.dakika, 0), 'HH24:MI') "
                + " else (array['Pazartesi','Salı','Çarşamba','Perşembe','Cuma',"
                + "             'Cumartesi','Pazar'])[greatest(least(z.gun, 7), 1)] || ' ' "
                + "      || to_char(make_time(z.saat, z.dakika, 0), 'HH24:MI') end",
                                 "metin", "Zaman", Hizalama: "orta", Genislik: 150,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("sonraki",     "z.sonraki",     "tarih", "Sıradaki", Hizalama: "orta",
                                                Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("sonCalisma",  "z.son_calisma", "tarih", "Son Çalışma", Hizalama: "orta",
                                                Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("durumAdi",
                "case when z.calisiyor = 1 then 'Çalışıyor' "
                + "when z.son_calisma is null then 'Hiç çalışmadı' "
                + "when z.basarili = 1 then 'Başarılı' else 'Hata' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 120, Filtrelenebilir: false),
            new("sonSonuc",    "z.son_sonuc",   "metin", "Son Sonuç", Genislik: 340),
            new("sureMs",      "z.sure_ms",     "sayi",  "Süre (ms)", Hizalama: "sag",
                                                Genislik: 90, Varsayilan: false),
            new("calisiyor",   "z.calisiyor",   "mantik", "Çalışıyor", Varsayilan: false),
            new("aktif",       "z.aktif",       "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("aciklama",    "z.aciklama",    "metin", "Açıklama", Varsayilan: false)
        });
}
