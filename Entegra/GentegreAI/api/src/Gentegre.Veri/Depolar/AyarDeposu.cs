using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Genel Ayarlar ekranindaki tek satir (public.referans). <c>YardimBaslik</c> /
/// <c>Yardim</c> alan yanindaki "?" ikonunun gosterdigi metindir (public.help,
/// anahtar "ayar.&lt;referans anahtari&gt;") - ekranda paragraf olarak durmaz.
/// </summary>
public sealed record AyarSatiri(string Anahtar, string Deger, string Tip, string Aciklama,
    string YardimBaslik = "", string Yardim = "");

/// <summary>public.help satiri - "?" ikonunun gosterdigi metin.</summary>
public sealed record YardimKaydi(string Anahtar, string Baslik, string Metin);

/// <summary>
/// Firma geneli ayarlar - <c>public.referans</c> tablosu.
///
/// BEYAZ LISTE ile calisir: ekran yalnizca burada tanimli anahtarlari gorur ve
/// yazabilir. referans tablosunda gocten gelen yuzlerce eski opsiyon (ops_*)
/// var; hepsini ayar ekranina dokmek ne anlasilir ne guvenli olurdu.
///
/// DEGER OKUMA UCUZ OLMALI: belge kaydinin her cagrisinda okunuyor, o yuzden
/// sayisal ayarlar 60 saniyelik bellek onbelleginde tutulur (ayar yazilinca
/// onbellek hemen dusurulur).
/// </summary>
public sealed class AyarDeposu
{
    private readonly VeriKaynagi _veri;

    /// <summary>Ekranda gosterilen/yazilabilen ayarlar.</summary>
    public static readonly IReadOnlyList<string> BeyazListe = new[]
    {
        "genel.yerel_para",
        // Urun modu (215): 1 Gentegre AI (ERP), 2 GenoTIP AI (HBYS). Ad, menu
        //   (Kayit Kabul yalniz HBYS) ve mesaj basliklari buna gore degisir;
        //   giris yanitiyla istemciye tasinir.
        "genel.urun_modu",
        // Varsayilan doviz (219) - genel.doviz kod listesinden secilir.
        "genel.varsayilan_doviz",
        // ÜTS taban adresleri (223) - bos birakilirsa fn_uts_hesap resmi
        //   sabitlere duser.
        "uts.uretim_url",
        "uts.test_url",
        // Randevu takvimi (243): gun/saat duzeni.
        "randevu.baslangic_saat", "randevu.bitis_saat", "randevu.slot_dk",
        "randevu.varsayilan_sure", "randevu.calisma_gunleri",
        "randevu.ogle_baslangic", "randevu.ogle_bitis",
        // KAYIT KABUL (355): basvuruda POS tahsilati alininca ne olacak -
        //   0 aksiyon yok, 1 otomatik satis fisi kesilsin, 2 kullaniciya sorulsun.
        "basvuru.pos_aksiyon",
        // Radyoloji sarf dusumu (320): stok modulunu kullanmayan kurumda
        //   kapatilabilir; depo secimi sarf cikis fisinin kaynagidir.
        "radyoloji.sarf_aktif", "radyoloji.sarf_depo",
        "belge.geri_gun_siniri",
        "liste.sayfa_boyu",
        "stok.negatif_davranis",
        // Guvenlik ayarlarini KimlikServisi / KullaniciDeposu zaten referans
        //   tablosundan okuyordu; ekranda gorunmedikleri icin kimse
        //   degistiremiyordu (105).
        "guvenlik.jwt_dakika",
        "guvenlik.refresh_gun",
        "guvenlik.parola_min_uzunluk",
        "guvenlik.tek_oturum",
        "guvenlik.hatali_giris_siniri",
        "guvenlik.kilit_dakika",
        // Belge girisi - yon bazli (155). Delphi'deki Opsiyonlar > Fatura'nin
        //   karsiligi; ayni ayarin satis ve alista farkli degeri olabilir.
        "belge.satis.vade_gun", "belge.satis.varsayilan_seri",
        "belge.alis.vade_gun",  "belge.alis.varsayilan_seri",
        // e-Belge: ANA SALTER de (179) sube kaydina tasindi - "e-Fatura Mükellefi"
        //   kutusu. Burada yalniz belge turu basina DAVRANIS ayarlari kaldi
        //   (servis adresleri, sabit notlar, gelen belge alma).
        "efatura.gelen_al", "efatura.senaryo", "efatura.ihracat_gonder",
        // 185: e-Fatura mukellefi bilinen cari kac gun sonra yeniden sorulur.
        "efatura.mukellef_sorgu_gun",
        "efatura.uretim_url", "efatura.test_url", "efatura.sabit_notlar",
        "earsiv.uretim_url", "earsiv.gelen_url",
        "earsiv.test_url", "earsiv.sabit_notlar",
        "eirsaliye.gelen_al", "eirsaliye.gib_alias",
        "eirsaliye.uretim_url", "eirsaliye.test_url", "eirsaliye.sabit_notlar",
        "esmm.uretim_url", "esmm.test_url", "esmm.sabit_notlar",
    };

    /// <summary>Metin (sayi olmayan) ayarlar - uzunluk disinda bicim serbest.</summary>
    private static readonly Dictionary<string, int> MetinAyar = new()
    {
        ["genel.yerel_para"] = 5,        // ISO kodu: TL, USD, EUR...
        ["genel.varsayilan_doviz"] = 5,
        ["belge.satis.varsayilan_seri"] = 10,
        ["belge.alis.varsayilan_seri"] = 10,
        ["efatura.uretim_url"] = 250,
        ["efatura.test_url"] = 250,
        ["efatura.sabit_notlar"] = 1000,
        ["earsiv.uretim_url"] = 250,
        ["earsiv.gelen_url"] = 250,
        ["earsiv.test_url"] = 250,
        ["uts.uretim_url"] = 250,
        ["uts.test_url"] = 250,
        ["earsiv.sabit_notlar"] = 1000,
        ["eirsaliye.gib_alias"] = 120,
        ["eirsaliye.uretim_url"] = 250,
        ["eirsaliye.test_url"] = 250,
        ["eirsaliye.sabit_notlar"] = 1000,
        ["esmm.uretim_url"] = 250,
        ["esmm.test_url"] = 250,
        ["esmm.sabit_notlar"] = 1000,
    };

    /// <summary>Ayar yoksa kullanilan degerler - DB'siz de dogru davranis.</summary>
    private static readonly Dictionary<string, int> Varsayilan = new()
    {
        ["genel.urun_modu"] = 1,
        ["belge.geri_gun_siniri"] = 7,
        // Tahsilat/odeme kac gun sonra kilitlensin (149): 0 kapali, -1 sinirsiz.
        ["kasa.duzenleme_gun"] = 7,
        ["liste.sayfa_boyu"] = 50,
        ["stok.negatif_davranis"] = 1,
        // POS tahsilatinda varsayilan AKSIYON YOK: kurulumu yapilmamis bir
        //   sistemde kendiliginden fis kesmek yanlis olurdu.
        ["basvuru.pos_aksiyon"] = 0,
        ["guvenlik.jwt_dakika"] = 30,
        ["guvenlik.refresh_gun"] = 30,
        ["guvenlik.parola_min_uzunluk"] = 8,
        ["guvenlik.tek_oturum"] = 0,
        ["guvenlik.hatali_giris_siniri"] = 5,
        ["guvenlik.kilit_dakika"] = 15,
        // Belge girisi (155)
        ["belge.satis.vade_gun"] = 30,
        ["belge.alis.vade_gun"] = 30,
        // e-Belge bayraklari KAPALI baslar: acik varsayilan, kurulumu
        //   yapilmamis bir sistemde belgeleri GIB'e gondermeye calisirdi.
        ["efatura.gelen_al"] = 0,
        ["efatura.senaryo"] = 1,          // Temel
        ["efatura.ihracat_gonder"] = 0,
        ["eirsaliye.gelen_al"] = 0,
    };

    /// <summary>Sayisal ayarlarin kabul araligi (yoksa yalniz "0 veya buyuk" kurali).</summary>
    private static readonly Dictionary<string, (int EnAz, int EnCok)> Aralik = new()
    {
        // Sunucu tek istekte 500'den fazlasini gondermiyor (ListeIstegi.EnBuyukBoyut);
        //   10'un altinda sayfalama ekrani surekli istek atmaya cevirir.
        ["liste.sayfa_boyu"] = (10, 500),
        ["stok.negatif_davranis"] = (0, 2),          // serbest / uyar / engelle
        ["basvuru.pos_aksiyon"] = (0, 2),            // yok / otomatik fis / sor
        ["efatura.senaryo"] = (1, 8),                // 1 Temel / 2 Ticari / 8 Ilac
        ["belge.satis.vade_gun"] = (0, 3650),
        ["belge.alis.vade_gun"] = (0, 3650),
        ["guvenlik.jwt_dakika"] = (5, 1440),
        ["guvenlik.refresh_gun"] = (1, 365),
        ["guvenlik.parola_min_uzunluk"] = (6, 64),
        ["guvenlik.tek_oturum"] = (0, 1),            // mantik ayari
        ["guvenlik.hatali_giris_siniri"] = (3, 20),
        ["guvenlik.kilit_dakika"] = (1, 1440),
    };

    private static readonly Dictionary<string, (int Deger, DateTime Zaman)> Onbellek = new();
    private static readonly TimeSpan OnbellekSuresi = TimeSpan.FromSeconds(60);
    private static readonly object Kilit = new();

    public AyarDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<IReadOnlyList<AyarSatiri>> ListeleAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select r.anahtar, r.deger, r.tip, r.aciklama,
                   coalesce(h.baslik, ''), coalesce(h.metin, '')
              from public.referans r
              left join public.help h
                     on h.anahtar = 'ayar.' || r.anahtar and h.dil = 0
             where r.anahtar = any(@p0)
             order by r.anahtar
            """, null,
            // (object?) SART: `params` bir DIZIYI tek basina verirsen ACAR ve her
            //   ogesi ayri parametre olur (@p0 dizi yerine ilk anahtar olurdu ->
            //   "op ANY/ALL (array) requires array on right side").
            (object?)BeyazListe.ToArray());

        var liste = new List<AyarSatiri>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new AyarSatiri(o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3),
                                     o.GetString(4), o.GetString(5)));

        // DB'de henuz satiri olmayan ayar da ekranda gorunsun (varsayilaniyla).
        foreach (var anahtar in BeyazListe)
            if (!liste.Any(x => x.Anahtar == anahtar))
                liste.Add(new AyarSatiri(anahtar,
                    Varsayilan.TryGetValue(anahtar, out var v) ? v.ToString() : "", "sayi", ""));

        return liste;
    }

    public async Task<IReadOnlyList<AyarSatiri>> YazAsync(string anahtar, string deger,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (!BeyazListe.Contains(anahtar))
            throw GentegreHatasi.Dogrulama($"Bilinmeyen ayar: {anahtar}",
                new AlanHatasi("anahtar", "Böyle bir ayar yok."));

        if (MetinAyar.TryGetValue(anahtar, out var enFazla))
        {
            deger = deger.Trim().ToUpperInvariant();
            if (deger.Length == 0)
                throw GentegreHatasi.Dogrulama("Değer boş bırakılamaz.",
                    new AlanHatasi("deger", "Zorunlu."));
            if (deger.Length > enFazla)
                throw GentegreHatasi.Dogrulama($"En fazla {enFazla} karakter olabilir.",
                    new AlanHatasi("deger", $"En fazla {enFazla} karakter."));
        }

        // Sayisal ayarlarda deger dogrulanir: "abc" yazilirsa belge kaydi patlardi.
        if (Varsayilan.ContainsKey(anahtar))
        {
            if (!int.TryParse(deger, out var sayi) || sayi < 0)
                throw GentegreHatasi.Dogrulama("Değer 0 veya daha büyük bir tam sayı olmalı.",
                    new AlanHatasi("deger", "Geçersiz sayı."));

            if (Aralik.TryGetValue(anahtar, out var sinir) &&
                (sayi < sinir.EnAz || sayi > sinir.EnCok))
                throw GentegreHatasi.Dogrulama(
                    $"Değer {sinir.EnAz} ile {sinir.EnCok} arasında olmalı.",
                    new AlanHatasi("deger", $"{sinir.EnAz}-{sinir.EnCok}"));

            deger = sayi.ToString();
        }

        await using var baglanti = await _veri.AcAsync(iptal);
        await using (var komut = new NpgsqlCommand("""
            insert into public.referans (anahtar, deger, tip, kapsam, degistiren, degistirme_tarihi)
            values (@p0, @p1, @p3, 'firma', @p2, now()::timestamp)
            on conflict (anahtar) do update
               set deger = excluded.deger, degistiren = excluded.degistiren,
                   degistirme_tarihi = excluded.degistirme_tarihi,
                   guncelleme = now()::timestamp
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", anahtar);
            komut.Parameters.AddWithValue("p1", deger);
            komut.Parameters.AddWithValue("p2", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p3", MetinAyar.ContainsKey(anahtar) ? "metin" : "sayi");
            await komut.ExecuteNonQueryAsync(iptal);
        }

        lock (Kilit) Onbellek.Remove(anahtar);
        return await ListeleAsync(iptal);
    }

    /// <summary>
    /// Tek bir yardim metni (public.help). Ayar disindaki ekranlar da ayni ucu
    /// kullanir - anahtar duzeni "kart.&lt;kart&gt;.&lt;alan&gt;" gibi genisler.
    /// </summary>
    /// <summary>
    public async Task<YardimKaydi?> YardimAsync(string anahtar, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select baslik, metin from public.help where anahtar = @p0 and dil = 0", null,
            anahtar);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        return await o.ReadAsync(iptal) ? new YardimKaydi(anahtar, o.GetString(0), o.GetString(1)) : null;
    }

    /// <summary>
    /// Sayisal ayari okur (60 sn onbellekli). Ayni baglanti/transaction icinden
    /// cagrilabilsin diye baglanti disaridan verilir - belge kaydi ortasinda
    /// ikinci bir baglanti acmak havuzu bosuna mesgul ederdi.
    /// </summary>
    public static async Task<int> SayiAsync(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string anahtar, CancellationToken iptal = default)
    {
        lock (Kilit)
            if (Onbellek.TryGetValue(anahtar, out var kayit) &&
                DateTime.UtcNow - kayit.Zaman < OnbellekSuresi)
                return kayit.Deger;

        var sonuc = Varsayilan.TryGetValue(anahtar, out var v) ? v : 0;
        await using (var komut = new NpgsqlCommand(
            "select deger from public.referans where anahtar = @p0", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", anahtar);
            if (await komut.ExecuteScalarAsync(iptal) is string metin &&
                int.TryParse(metin, out var okunan))
                sonuc = okunan;
        }

        lock (Kilit) Onbellek[anahtar] = (sonuc, DateTime.UtcNow);
        return sonuc;
    }

    /// <summary>
    /// Metin ayari okur (or. genel.yerel_para = "TL"). Sayisal olanin aksine
    /// onbelleklenmez: metin ayarlar tek tek ve seyrek okunuyor, buna karsilik
    /// yanlis onbellekten donen para birimi butun tutarlari bozardi.
    /// </summary>
    public static async Task<string> MetinAsync(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string anahtar, string varsayilan, CancellationToken iptal = default)
    {
        await using var komut = baglanti.Komut(
            "select deger from public.referans where anahtar = @p0", islem,
            anahtar);
        return await komut.ExecuteScalarAsync(iptal) is string metin && metin.Length > 0
            ? metin : varsayilan;
    }
}
