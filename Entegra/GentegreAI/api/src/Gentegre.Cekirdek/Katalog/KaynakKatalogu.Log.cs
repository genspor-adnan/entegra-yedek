namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Islem log listesi ve ham id -> ad cozumleme ifadeleri.
///
/// KaynakKatalogu tek dosyada 1389 satira ulasmisti; tanimlar konu basina
/// partial dosyalara ayrildi. Sozluk, Bul/Tumu ve kayit sirasi ana dosyada.
/// </summary>
public static partial class KaynakKatalogu
{
    // ---------------------------------------------------------- islem log ----
    // UInfo karsiligi. islem_log tarihe gore BOLUMLENMIS: varsayilan siralama
    //   tarih desc oldugu icin son kayitlar ilk bolumden gelir.
    //
    // islem_tipi ve tablo_id ham sayisal kodlar (Gentegre.Veri.Depolar.LogIslemi /
    //   KartTanimi.LogTabloId) - burada okunabilir metne cevriliyor ki UInfo gibi
    //   kullanici "2/71" degil "Degisiklik/Cari" gorsun.
    //
    // Kod/Ad (eski LOGCOZUM karsiligi): tablo_id'ye gore DOGRU tabloya (taraf/stok/
    //   belge/rol) LEFT JOIN ile kayit_id cozulur. Yalniz kart-seviyeli tablolar
    //   (71/73 taraf, 88 stok, 30 belge, 903 rol) cozulur - detay satirlari (adres,
    //   barkod, fiyat, izin, egitim... 340-907 arasi) icin Kod/Ad bos kalir; kayit
    //   silinmisse de (join eslesmez) bos kalir - "bilgi" JSON'daki anlik degerler
    //   burada kullanilmaz, cunku alan adlari tabloya gore degisir (tek SQL'de
    //   duzgun genellenemez).
    private static KaynakTanimi IslemLog() => new(
        Ad: "islem-log",
        YetkiKodu: "islem_log",
        Kaynak: """
            public.islem_log l
            left join public.taraf k on k.id = l.kullanici_id
            left join public.taraf kt on kt.id = l.kayit_id and l.tablo_id in (71, 73)
            left join public.taraf kut on kut.id = l.ust_kayit_id and l.ust_tablo_id in (71, 73)
            left join public.stok ks on ks.id = l.kayit_id and l.tablo_id = 88
            left join public.belge kb on kb.id = l.kayit_id and l.tablo_id = 30
            left join public.rol kr on kr.id = l.kayit_id and l.tablo_id = 903
            """,
        VarsayilanSirala: "l.tarih desc, l.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "l.id",                          "sayi",  "Id",        Varsayilan: false),
            new("tarih",      "(l.tarih + interval '3 hours')", "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("islemTipi",  IslemAdiIfade("l.islem_tipi"),   "metin", "İşlem",     Hizalama: "orta"),
            new("modul",      LogModulIfade(),                 "metin", "Modül",     Hizalama: "orta"),
            new("kod",        "case when l.ust_tablo_id in (71, 73) then kut.kod when l.tablo_id in (71, 73) then kt.kod when l.tablo_id = 88 then ks.kod when l.tablo_id = 30 then kb.belge_no when l.tablo_id = 903 then kr.kod end",
                                                                "metin", "Kod"),
            new("ad",         "case when l.ust_tablo_id in (71, 73) then kut.unvan when l.tablo_id in (71, 73) then kt.unvan when l.tablo_id = 88 then ks.ad when l.tablo_id = 30 then kb.taraf_unvan when l.tablo_id = 903 then kr.ad end",
                                                                "metin", "Ad"),
            new("kayitId",    "l.kayit_id",                    "sayi",  "Kayıt Id",  Hizalama: "sag"),
            new("kullanici",  "k.unvan",                       "metin", "Kullanıcı"),
            new("ip",         "l.ip",                          "metin", "IP"),
            new("ustTabloId", TabloAdiIfade("l.ust_tablo_id"), "metin", "Ust Tablo", Varsayilan: false),
            new("ustKayitId", "l.ust_kayit_id",                "sayi",  "Ust Kayit", Varsayilan: false),
            new("subeId",     "l.sube_id",                     "sayi",  "Sube",      Varsayilan: false),
            // Satir "Icerik" gorunumunde gosterilir (GenGrid icerikAlani) - grid kolonu
            //   olarak DEGIL, gizli veri olarak taşınır.
            new("bilgi",      "l.bilgi::text",                 "metin", "Icerik",    Varsayilan: false,
                                                                 Siralanabilir: false, Filtrelenebilir: false)
        });

    /// <summary>Gentegre.Veri.Depolar.LogIslemi (0 Sil / 1 Ekle / 2 Degistir) okunabilir metne.</summary>

    /// <summary>Gentegre.Veri.Depolar.LogIslemi (0 Sil / 1 Ekle / 2 Degistir) okunabilir metne.</summary>
    private static string IslemAdiIfade(string kolon) => $"""
        case {kolon}
            when 0 then 'Silme'
            when 1 then 'Ekleme'
            when 2 then 'Değişiklik'
            else {kolon}::text
        end
        """;

    /// <summary>
    /// LogTabloId (KartKatalogu'ndaki tablo kodlari) okunabilir ada. 71 hem cari hem
    /// kisi hem hasta icin ortak (ucu de ayni fiziksel taraf tablosu) - ayrim satirin
    /// kendisinden (taraf_id) yapilmaz, eski GENDEPO'daki ayni belirsizlik burada da var.
    /// </summary>

    /// <summary>
    /// LogTabloId (KartKatalogu'ndaki tablo kodlari) okunabilir ada. 71 hem cari hem
    /// kisi hem hasta icin ortak (ucu de ayni fiziksel taraf tablosu) - ayrim satirin
    /// kendisinden (taraf_id) yapilmaz, eski GENDEPO'daki ayni belirsizlik burada da var.
    /// </summary>
    private static string TabloAdiIfade(string kolon) => $"""
        case {kolon}
            when 0 then ''
            when 30 then 'Belge'
            when 71 then 'Cari/Kişi/Hasta'
            when 73 then 'Personel'
            when 88 then 'Stok'
            when 340 then 'Stok Barkod'
            when 346 then 'Stok Fiyat'
            when 901 then 'Adres'
            when 902 then 'Stok Seri/Lot'
            when 903 then 'Rol'
            when 904 then 'İzin'
            when 905 then 'Eğitim/Sertifika'
            when 906 then 'Acil Durum Kişi'
            when 907 then 'Hasta Bilgisi'
            else {kolon}::text
        end
        """;

    private static string LogModulIfade() => """
        case
            when l.ust_tablo_id = 73 then 'Personel'
            when l.ust_tablo_id = 71 then
                case
                    when kut.grup = 101 then 'Hasta'
                    when kut.kisi = 1 then 'Kişi'
                    when kut.musteri = 1 and kut.tedarikci = 1 then 'Müşteri/Tedarikçi'
                    when kut.tedarikci = 1 then 'Tedarikçi'
                    when kut.musteri = 1 then 'Müşteri'
                    else 'Cari'
                end
            when l.tablo_id = 73 then 'Personel'
            when l.tablo_id = 71 then
                case
                    when kt.grup = 101 then 'Hasta'
                    when kt.kisi = 1 then 'Kişi'
                    when kt.musteri = 1 and kt.tedarikci = 1 then 'Müşteri/Tedarikçi'
                    when kt.tedarikci = 1 then 'Tedarikçi'
                    when kt.musteri = 1 then 'Müşteri'
                    else 'Cari'
                end
            when l.tablo_id = 30 then 'Belge'
            when l.tablo_id = 88 then 'Stok'
            when l.tablo_id = 903 then 'Rol'
            else ''
        end
        """;

    // ---------------------------------------------------------------- rol ----
}
