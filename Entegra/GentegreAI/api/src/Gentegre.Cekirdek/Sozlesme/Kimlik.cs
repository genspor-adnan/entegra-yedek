namespace Gentegre.Cekirdek.Sozlesme;

public sealed class GirisIstegi
{
    public string Kod { get; set; } = "";
    public string Parola { get; set; } = "";
    public int? SubeId { get; set; }
}

public sealed class YenileIstegi
{
    public string RefreshToken { get; set; } = "";
}

/// <summary>
/// Kullanici Ayarlari > Hesabim (669): kisinin KENDI iletisim bilgisi.
/// Ad/gorev/rol burada YOK - onlar personel kartinda durur.
/// </summary>
public sealed class IletisimIstegi
{
    public string Eposta { get; set; } = "";
    public string CepTel { get; set; } = "";
}

public sealed class ParolaDegistirIstegi
{
    public string EskiParola { get; set; } = "";
    public string YeniParola { get; set; } = "";
}

/// <summary>Ilk parola belirleme - otomatik acilmis hesabin parolasi bostur.</summary>
public sealed class IlkParolaIstegi
{
    public string Kod { get; set; } = "";
    /// <summary>Kimlik kaniti: TCKN'nin son 4 hanesi.</summary>
    public string TcknSon4 { get; set; } = "";
    public string YeniParola { get; set; } = "";
}

public sealed class DilDegistirIstegi
{
    public int Dil { get; set; }
}

public sealed class GirisYaniti
{
    public string AccessToken { get; set; } = "";
    public string RefreshToken { get; set; } = "";
    public DateTime SonaErme { get; set; }            // access token
    public DateTime RefreshSonaErme { get; set; }
    public bool ParolaDegismeli { get; set; }
    /// <summary>
    /// Kullanici birden cok subede calisabiliyor ve giriste sube secmediyse true:
    /// istemci sube secim ekranini gosterir. Token yine de verilir (varsayilan sube ile),
    /// secim yapilinca POST /api/kimlik/sube ile yeni token alinir.
    /// </summary>
    public bool SubeSecimiGerekli { get; set; }
    public KullaniciOzeti Kullanici { get; set; } = new();
}

public sealed class SubeSecIstegi
{
    public int SubeId { get; set; }
}

public sealed class KullaniciOzeti
{
    public int Id { get; set; }                       // = taraf_id
    public string Kod { get; set; } = "";
    public string Ad { get; set; } = "";
    public int RolId { get; set; }
    public string RolAdi { get; set; } = "";
    /// <summary>
    /// EK rollerin adlari, virgulle (665). Ana rol BURADA DEGIL - `RolAdi`
    /// kisinin asil isi, bu alan yaninda tasidigi gorevler ("Iskonto
    /// Onaylayanlar"). Bos ise kisinin tek rolu var.
    /// </summary>
    public string EkRolAdlari { get; set; } = "";
    public int Dil { get; set; }
    /// <summary>
    /// ILK GIRIS PAROLA ZORUNLULUGU (674): varsayilan parola (personel kart
    /// id'si) ile giren kisi once kendi parolasini belirlemek zorundadir.
    /// Bayrak /ben yanitinda da tasinir - yalniz giris yanitinda olsaydi
    /// sayfa yenileyen kullanici zorunlulugu atlardi.
    /// </summary>
    public bool ParolaDegismeli { get; set; }
    public long YetkiSurumu { get; set; }
    public int? SubeId { get; set; }
    /// <summary>Aktif subede yazma hakki (rol_sube.yazma). 0 ise salt okuma.</summary>
    public bool SubeYazma { get; set; } = true;
    /// <summary>Kullanicinin giris / islem yapabilecegi subeler (rol_sube uzerinden rolunden gelir).</summary>
    public IReadOnlyList<SubeOzeti> Subeler { get; set; } = Array.Empty<SubeOzeti>();
    /// <summary>Urun modu (referans genel.urun_modu): 1 Gentegre AI (ERP),
    /// 2 GenoTIP AI (HBYS). Ad, menu ve mesaj basliklari buna gore degisir.</summary>
    public int UrunModu { get; set; } = 1;
    /// <summary>
    /// KURULUMDA ACIK MODULLER (359): kurum profilinin secili tipinden ve
    /// override'larindan cozulur (fn_kurum_modul_acik). Menu ve rotalar buna
    /// gore suzulur - kapali modulun ekrani hic cizilmez.
    /// </summary>
    public IReadOnlyList<string> Moduller { get; set; } = Array.Empty<string>();
    /// <summary>
    /// AKTIF SUBEDE basvuruda sorulan hekim rolu (361/364): lab/goruntuleme
    /// subesinde 1 "Gönderen" (dis doktor), digerlerinde 4 "Yapan" (personel).
    /// Basvuru karti doktor combosunu bu role gore doldurur.
    /// </summary>
    public int HekimRolu { get; set; } = 4;
}

/// <summary>
/// Kullanicinin calisabildigi sube + SUBENIN YEREL AYARLARI (666).
///
/// Ulke/para/saat istemciye SUBEDEN gelir: Berlin subesi avro tahsil eder,
/// Almanya saatiyle calisir ve orada T.C. kimlik numarasi yoktur. Bu üç deger
/// olmadan istemci her kurumu Turkiye sanardi.
/// </summary>
public sealed record SubeOzeti(int Id, string Ad, bool Varsayilan, bool Yazma,
    /// <summary>ISO 3166 iki harf; dogrulama kurallari BUNA bakar ('TR').</summary>
    string UlkeKod = "TR",
    /// <summary>Telefon kutusunun acilis kodu ('+90').</summary>
    string TelefonKodu = "+90",
    /// <summary>IANA adi ('Europe/Istanbul') - sabit saat farki DEGIL.</summary>
    string ZamanDilimi = "Europe/Istanbul",
    /// <summary>ISO 4217 ('TRY') - belgenin kendi dovizi ayridir.</summary>
    string ParaBirimi = "TRY");

/// <summary>GET /api/kimlik/ben - profil + cozulmus yetkiler.</summary>
public sealed class BenYaniti
{
    public KullaniciOzeti Kullanici { get; set; } = new();
    public IReadOnlyList<string> Aksiyonlar { get; set; } = Array.Empty<string>();

    /// <summary>
    /// SAYISAL SINIRI OLAN aksiyonlar (661): kod -> sinir. Ornek
    /// { "basvuru.iskonto": 20 } - bu rol en cok %20 iskonto yapabilir.
    /// Yalniz siniri TANIMLI olanlar doner; listede olmayan aksiyonun siniri
    /// yoktur (deger isteyen bir aksiyonsa "yapamaz" demektir).
    /// </summary>
    public IReadOnlyDictionary<string, decimal> AksiyonDegerleri { get; set; }
        = new Dictionary<string, decimal>();
    public IReadOnlyList<KaynakYetkisi> Kaynaklar { get; set; } = Array.Empty<KaynakYetkisi>();
}

public sealed record KaynakYetkisi(string Kod, bool Gor, bool Ekle, bool Degistir, bool Sil);
