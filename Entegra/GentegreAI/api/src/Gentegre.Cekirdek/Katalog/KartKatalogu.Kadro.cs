namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KADRO HAREKETİ KARTI (840).
///
/// <para>Bir satır = personelin o tarihteki <b>tam</b> pozisyonu. Kart
/// doldurulup kaydedilince `taraf_personel` ondan türetilir (DB tetiği) -
/// kartla defter iki ayrı gerçek söylemesin.</para>
///
/// <para><b>Yürürlük zorunlu, karar tarihi değil:</b> "1 Ocak'tan itibaren"
/// bugünden girilebilir; o güne kadar personel kartında görünmez.</para>
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi PersonelHareket() => new(
        Ad: "personel-hareket",
        YetkiKodu: "ik.kadro",
        Tablo: "public.personel_hareket",
        // Yeni tablo - eski GENINI karşılığı yok. 940 RADYOLOJİ İSTEMİNİN
        //   (test yakaladı: aynı id iki tabloya verilince denetim izinde
        //   kayıtlar birbirine karışır); sıradaki boş numara alındı.
        LogTabloId: 1325,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)2,          // en sık girilen hareket: terfi/unvan
            ["kaynak"] = (short)1,       // elle girilen
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Personel",
                Grup: "Hareket", KodTablosu: "public.v_personel_lookup"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Hareket Türü",
                Grup: "Hareket", SabitKodlar: KaynakKatalogu.KadroTurKodlari),
            new("yururluk", "yururluk", "tarih", Zorunlu: true, Baslik: "Yürürlük",
                Grup: "Hareket"),
            // BİTİŞ YALNIZ SÜRELİ HAREKETTE: vekâlet ve askı bitince önceki
            //   pozisyon yeniden geçerli olur; kalıcı harekette boş bırakılır.
            new("bitis", "bitis", "tarih", Baslik: "Bitiş (süreli ise)", Grup: "Hareket"),

            new("gorev", "gorev", "metin", EnFazlaUzunluk: 100, Baslik: "Görev / unvan",
                Grup: "Pozisyon"),
            new("gorevId", "gorev_id", "kod", Baslik: "Görev (katalog)", Grup: "Pozisyon",
                KodTablosu: "public.v_gorev_agac_lookup", Agac: true),
            new("departmanId", "departman_id", "kod", Baslik: "Bölüm", Grup: "Pozisyon",
                KodTablosu: "public.v_departman_agac_lookup", Agac: true),
            // ANA ROL (843): pozisyonun YETKI tarafi. Hareket kaydedilince
            //   `taraf_kullanici.rol_id`e yazilir - rol degisikligi de artik
            //   yururluk tarihiyle defterde durur.
            new("rolId", "rol_id", "kod", Baslik: "Ana Rol", Grup: "Pozisyon",
                KodTablosu: "public.v_rol_lookup"),
            new("yoneticiTarafId", "yonetici_taraf_id", "kod", Baslik: "Yönetici",
                Grup: "Pozisyon", KodTablosu: "public.v_personel_lookup"),
            new("subeId", "sube_id", "kod", Baslik: "Şube", Grup: "Pozisyon",
                KodTablosu: "public.v_sube_lookup"),
            new("unvan", "unvan", "metin", EnFazlaUzunluk: 120, Baslik: "Kadro unvanı",
                Grup: "Pozisyon"),

            new("kararNo", "karar_no", "metin", EnFazlaUzunluk: 50, Baslik: "Karar No",
                Grup: "Belge"),
            new("belgeNo", "belge_no", "metin", EnFazlaUzunluk: 50, Baslik: "Belge No",
                Grup: "Belge"),
            new("gerekce", "gerekce", "metin", EnFazlaUzunluk: 300, Baslik: "Gerekçe",
                Grup: "Belge"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 500, Baslik: "Açıklama",
                Grup: "Belge"),
            // KAYNAK OKUNUR: karttan türetilen satırı elle "elle girildi"
            //   yapmak izi bozardı.
            new("kaynak", "kaynak", "kod", Yazilabilir: false, Baslik: "Kaynak",
                Grup: "Belge", SabitKodlar: KaynakKatalogu.KadroKaynakKodlari),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false),
        });
}
