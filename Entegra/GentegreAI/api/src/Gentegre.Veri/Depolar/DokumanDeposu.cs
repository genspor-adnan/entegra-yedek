using System.Security.Cryptography;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed record DokumanSatiri(int Id, string Ad, string BelgeTuru, string ContentType, int Boyut,
    bool Varsayilan, short Sira, DateTime EklemeTarihi, string? PaylasimKodu);

public sealed record DokumanIcerik(byte[] Veri, string ContentType, string Ad);

/// <summary>
/// Genel resim/doküman deposu (057_dokuman.sql) - "kaynak" polimorfik (taraf/stok),
/// çoklu satır + tek varsayılan (partial unique index DB'de garanti eder). Resim/
/// doküman AYRI tablo DEĞİL - kullanıcı: "resim/doküman birlikte düşünelim" kararı.
/// </summary>
public sealed class DokumanDeposu
{
    private static readonly HashSet<string> KaynakBeyazListe =
        // "ebelge-xslt" (160): kart degil, e-Belge goruntuleme sablonlari -
        //   kaynak_id belge turu kodudur (1 e-Fatura, 2 e-Arsiv...).
        //   "sube" (193): firma logosu / kase / imza - belge_turu alani hangisi
        //   oldugunu tasir ('Logo' | 'Kaşe' | 'İmza' | 'Antet').
        //   "radyoloji-istem" (310): ISTEM KAGIDI - disaridan gelen hastanin
        //   getirdigi hekim istemi taranip/fotograflanip isteme eklenir; SGK ve
        //   sigorta faturalamasinda "istem belgesi nerede" sorusunun cevabidir.
        new(StringComparer.Ordinal)
            { "taraf", "stok", "ebelge-xslt", "sube", "radyoloji-istem" };

    private static readonly HashSet<string> IcerikTipiBeyazListe = new(StringComparer.OrdinalIgnoreCase)
    {
        "image/jpeg", "image/png", "image/webp", "image/gif",
        "application/pdf", "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "text/plain",
        // e-Belge XSLT sablonlari (160). Tarayici .xsl/.xslt icin cogunlukla
        //   "text/xml" gonderir, bazen hic gondermez - ucta bos tip XSLT'ye
        //   sabitleniyor.
        "application/xslt+xml", "text/xml", "application/xml",
    };

    private const int AzamiBoyut = 5 * 1024 * 1024; // 5 MB

    private readonly VeriKaynagi _veri;

    public DokumanDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>e-Belge tur kodu -> okunur ad (156/160 ile ayni kodlar).</summary>
    private static string EBelgeTuruAdi(int kod) => kod switch
    {
        1 => "e-Fatura",
        2 => "e-Arşiv",
        7 => "e-İrsaliye",
        8 => "e-SMM",
        _ => "",
    };

    private static string KaynakDogrula(string kaynak)
        => KaynakBeyazListe.Contains(kaynak) ? kaynak : throw new InvalidOperationException($"Bilinmeyen kaynak: {kaynak}");

    public async Task<IReadOnlyList<DokumanSatiri>> ListeleAsync(string kaynak, long kaynakId, CancellationToken iptal = default)
    {
        KaynakDogrula(kaynak);
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select id, ad, belge_turu, content_type, boyut, varsayilan, sira, ekleme_tarihi, paylasim_kodu
              from public.dokuman
             where kaynak = @p0 and kaynak_id = @p1
             order by sira, id
            """, null,
            kaynak, kaynakId);

        var sonuc = new List<DokumanSatiri>();
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
            sonuc.Add(new DokumanSatiri(
                okuyucu.GetInt32(0), okuyucu.GetString(1), okuyucu.GetString(2), okuyucu.GetString(3),
                okuyucu.GetInt32(4), okuyucu.GetInt16(5) == 1, okuyucu.GetInt16(6), okuyucu.GetDateTime(7),
                okuyucu.IsDBNull(8) ? null : okuyucu.GetString(8)));
        return sonuc;
    }

    /// <param name="yon">0 uygulanmaz · 1 gelen · 2 giden (160). e-Belge XSLT
    /// sablonlarinda gelen/giden ayrimi; diger kaynaklarda 0 kalir.</param>
    public async Task<IReadOnlyList<DokumanSatiri>> EkleAsync(string kaynak, long kaynakId, string ad,
        string contentType, byte[] veri, bool varsayilanIstendi, YazmaBaglami baglam,
        CancellationToken iptal = default, short yon = 0)
    {
        KaynakDogrula(kaynak);
        if (!IcerikTipiBeyazListe.Contains(contentType))
            throw GentegreHatasi.Dogrulama($"Desteklenmeyen dosya türü: {contentType}",
                new AlanHatasi("dosya", "Bu dosya türü kabul edilmiyor."));
        if (veri.Length == 0 || veri.Length > AzamiBoyut)
            throw GentegreHatasi.Dogrulama("Dosya boyutu 5 MB'ı aşamaz.",
                new AlanHatasi("dosya", "Dosya boş veya çok büyük."));

        var resimMi = contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase);
        var hash = Convert.ToHexString(SHA256.HashData(veri));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // Eski resimler HİÇ SİLİNMEZ (kullanici: "fotoğraf kısmından yeni resim eklersek
        //   eski resim silinmesin doküman kısmında devam etsin"). "varsayilanIstendi"
        //   caller'a gore degisir: PersonelKimlikOzet Fotograf kutusu true gonderir (yeni
        //   resim varsayilan/profil resmi olur), DokumanGalerisi "+ Dosya Ekle" false
        //   gonderir (sadece listeye eklenir, mevcut varsayilan degismez) - ilk resimde
        //   yine de otomatik varsayilan olur (hic resim yoksa secilecek baska aday yok).
        var mevcutResimVarMi = false;
        if (resimMi)
        {
            await using var kontrol = baglanti.Komut("""
                select exists(select 1 from public.dokuman
                               where kaynak = @p0 and kaynak_id = @p1 and content_type like 'image/%')
                """, islem,
                kaynak, kaynakId);
            mevcutResimVarMi = (bool)(await kontrol.ExecuteScalarAsync(iptal))!;
        }
        var varsayilanOlacak = resimMi && (varsayilanIstendi || !mevcutResimVarMi);

        if (varsayilanOlacak)
            await VarsayilaniKaldirAsync(baglanti, islem, kaynak, kaynakId, baglam.KullaniciId, iptal, yon);

        // İçerik dedup: aynı hash zaten varsa bytea'yı tekrar yazmadan referans_sayisi'ni
        // artır, yoksa yeni içerik satırı aç (059_dokuman_dedup.sql).
        await using (var icerikEkle = new NpgsqlCommand("""
            insert into public.dokuman_icerik (hash, icerik, content_type, boyut, referans_sayisi)
            values (@p0, @p1, @p2, @p3, 1)
            on conflict (hash) do update set referans_sayisi = public.dokuman_icerik.referans_sayisi + 1
            """, baglanti, islem))
        {
            icerikEkle.Parameters.AddWithValue("p0", hash);
            icerikEkle.Parameters.AddWithValue("p1", veri);
            icerikEkle.Parameters.AddWithValue("p2", contentType);
            icerikEkle.Parameters.AddWithValue("p3", veri.Length);
            await icerikEkle.ExecuteNonQueryAsync(iptal);
        }

        await using (var ekle = new NpgsqlCommand("""
            insert into public.dokuman (kaynak, kaynak_id, ad, content_type, boyut, hash,
                                        varsayilan, sube_id, ekleyen, yon, belge_turu)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10)
            """, baglanti, islem))
        {
            ekle.Parameters.AddWithValue("p0", kaynak);
            ekle.Parameters.AddWithValue("p1", kaynakId);
            ekle.Parameters.AddWithValue("p2", ad);
            ekle.Parameters.AddWithValue("p3", contentType);
            ekle.Parameters.AddWithValue("p4", veri.Length);
            ekle.Parameters.AddWithValue("p5", hash);
            ekle.Parameters.AddWithValue("p6", (short)(varsayilanOlacak ? 1 : 0));
            // p9 asagida: yon (0 uygulanmaz / 1 gelen / 2 giden).
            ekle.Parameters.AddWithValue("p7", baglam.SubeId ?? 1);
            ekle.Parameters.AddWithValue("p8", baglam.KullaniciId);
            ekle.Parameters.AddWithValue("p9", yon);
            // BELGE TURU: XSLT kaynaginda tur kodundan okunur adi turetilir
            //   (kaynak_id = 1 e-Fatura ...). Kart dokumanlarinda kullanici
            //   yazar; ekleme aninda bos kalir, duzenlemeden girilir.
            ekle.Parameters.AddWithValue("p10", kaynak == "ebelge-xslt"
                ? EBelgeTuruAdi((int)kaynakId) : "");
            await ekle.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
        return await ListeleAsync(kaynak, kaynakId, iptal);
    }

    /// <summary>
    /// Dokuman bilgilerini duzenler. Kart dokumaninda yalniz AD ve belge turu
    /// anlamlidir; e-Belge XSLT sablonunda (160) ayrica hangi belge turune ait
    /// oldugu (kaynak_id), yonu ve varsayilanligi da degistirilebilir - orada
    /// bunlar dosyanin kimligidir, sonradan duzeltilebilmeli.
    /// </summary>
    public async Task<IReadOnlyList<DokumanSatiri>> DuzenleAsync(int dokumanId, string yeniAd, string? yeniBelgeTuru,
        YazmaBaglami baglam, CancellationToken iptal = default,
        int? yeniKaynakId = null, short? yeniYon = null, bool? yeniVarsayilan = null)
    {
        if (string.IsNullOrWhiteSpace(yeniAd))
            throw GentegreHatasi.Dogrulama("Ad boş olamaz.", new AlanHatasi("ad", "Ad girilmeli."));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var (kaynak, kaynakId, mevcutYon) = await SatirBulAsync(baglanti, islem,
            "select kaynak, kaynak_id, yon from public.dokuman where id = @p0", dokumanId,
            r => (r.GetString(0), r.GetInt32(1), r.GetInt16(2)), iptal);

        var hedefKaynakId = yeniKaynakId ?? kaynakId;
        var hedefYon = yeniYon ?? mevcutYon;

        // Varsayilan yapiliyorsa ONCE ayni tur+yondeki eskisi birakilir -
        //   kismi tekil indeks (kaynak, kaynak_id, yon) iki varsayilana izin vermez.
        if (yeniVarsayilan == true)
            await VarsayilaniKaldirAsync(baglanti, islem, kaynak, hedefKaynakId,
                                         baglam.KullaniciId, iptal, hedefYon);

        await using (var guncelle = new NpgsqlCommand("""
            update public.dokuman
               set ad = @p0, belge_turu = @p1, kaynak_id = @p4, yon = @p5,
                   varsayilan = coalesce(@p6, varsayilan), degistiren = @p2
             where id = @p3
            """, baglanti, islem))
        {
            guncelle.Parameters.AddWithValue("p0", yeniAd.Trim());
            // XSLT'de belge turu ADI kod'dan turetilir - kullanicidan gelmez.
            guncelle.Parameters.AddWithValue("p1", kaynak == "ebelge-xslt"
                ? EBelgeTuruAdi(hedefKaynakId) : (yeniBelgeTuru ?? "").Trim());
            guncelle.Parameters.AddWithValue("p2", baglam.KullaniciId);
            guncelle.Parameters.AddWithValue("p3", dokumanId);
            guncelle.Parameters.AddWithValue("p4", hedefKaynakId);
            guncelle.Parameters.AddWithValue("p5", hedefYon);
            guncelle.Parameters.AddWithValue("p6",
                yeniVarsayilan is null ? DBNull.Value : (short)(yeniVarsayilan.Value ? 1 : 0));
            await guncelle.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
        // Tur degistiyse liste HEDEF turden okunur - kayit artik orada.
        return await ListeleAsync(kaynak, hedefKaynakId, iptal);
    }

    public async Task<IReadOnlyList<DokumanSatiri>> VarsayilanYapAsync(int dokumanId, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var (kaynak, kaynakId, contentType, yon) = await SatirBulAsync(baglanti, islem,
            "select kaynak, kaynak_id, content_type, yon from public.dokuman where id = @p0", dokumanId,
            r => (r.GetString(0), r.GetInt32(1), r.GetString(2), r.GetInt16(3)), iptal);
        // "Varsayilan" kartlarda ANA GORSEL demek - resim olmayan dosyanin
        //   varsayilan olmasi anlamsizdi. e-Belge XSLT'sinde ise anlami baska:
        //   "bu tur+yon icin kullanilacak sablon" (160) - orada resim sarti yok.
        if (kaynak != "ebelge-xslt"
            && !contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
            throw GentegreHatasi.Dogrulama("Sadece resim varsayılan yapılabilir.",
                new AlanHatasi("dosya", "Bu doküman resim değil."));

        await VarsayilaniKaldirAsync(baglanti, islem, kaynak, kaynakId, baglam.KullaniciId, iptal, yon);
        await using (var guncelle = new NpgsqlCommand(
            "update public.dokuman set varsayilan = 1, degistiren = @p0 where id = @p1", baglanti, islem))
        {
            guncelle.Parameters.AddWithValue("p0", baglam.KullaniciId);
            guncelle.Parameters.AddWithValue("p1", dokumanId);
            await guncelle.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
        return await ListeleAsync(kaynak, kaynakId, iptal);
    }

    public async Task<IReadOnlyList<DokumanSatiri>> SilAsync(int dokumanId, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var (kaynak, kaynakId, varsayilanMiydi, hash) = await SatirBulAsync(baglanti, islem,
            "select kaynak, kaynak_id, varsayilan, hash from public.dokuman where id = @p0", dokumanId,
            r => (r.GetString(0), r.GetInt32(1), r.GetInt16(2) == 1, r.GetString(3)), iptal);

        await using (var sil = new NpgsqlCommand("delete from public.dokuman where id = @p0", baglanti, islem))
        {
            sil.Parameters.AddWithValue("p0", dokumanId);
            await sil.ExecuteNonQueryAsync(iptal);
        }

        // Referans_sayisi dus, baska satir kullanmiyorsa icerigi de sil (dedup'in geri
        // yuzu - paylasilan bytea'yi son referans gidince temizle).
        await using (var azalt = new NpgsqlCommand(
            "update public.dokuman_icerik set referans_sayisi = referans_sayisi - 1 where hash = @p0", baglanti, islem))
        {
            azalt.Parameters.AddWithValue("p0", hash);
            await azalt.ExecuteNonQueryAsync(iptal);
        }
        await using (var temizle = new NpgsqlCommand(
            "delete from public.dokuman_icerik where hash = @p0 and referans_sayisi <= 0", baglanti, islem))
        {
            temizle.Parameters.AddWithValue("p0", hash);
            await temizle.ExecuteNonQueryAsync(iptal);
        }

        // Silinen varsayilan resimdiyse, kalan bir resmi (varsa) yeni varsayilan yap -
        // galeri hep "biri varsayilan" kuralini korusun.
        if (varsayilanMiydi)
        {
            await using var yeniAday = baglanti.Komut("""
                update public.dokuman set varsayilan = 1
                 where id = (
                     select id from public.dokuman
                      where kaynak = @p0 and kaynak_id = @p1 and content_type like 'image/%'
                      order by sira, id limit 1)
                """, islem,
                kaynak, kaynakId);
            await yeniAday.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
        return await ListeleAsync(kaynak, kaynakId, iptal);
    }

    public async Task<DokumanIcerik?> IcerikAsync(int dokumanId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select i.icerik, d.content_type, d.ad
              from public.dokuman d join public.dokuman_icerik i on i.hash = d.hash
             where d.id = @p0
            """, null,
            dokumanId);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        if (!await okuyucu.ReadAsync(iptal)) return null;
        return new DokumanIcerik((byte[])okuyucu[0], okuyucu.GetString(1), okuyucu.GetString(2));
    }

    /// <summary>
    /// Paylaşım kodu üretir/döner (idempotent - zaten varsa AYNI kod döner). Bu kod
    /// kimliksiz (auth gerektirmeyen) `IcerikPaylasimKoduIleAsync` ile eşleşir - kullanıcı:
    /// "adres ver onu gönderince doküman açılsın" (bağlantıyı alan herkes içeriği görür,
    /// tahmin edilemez token dışında bir erişim kontrolü YOK - kasıtlı, "gizli bağlantı"
    /// modeli, Google Drive paylaşım linki gibi).
    /// </summary>
    public async Task<string> PaylasAsync(int dokumanId, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        string? mevcutKod;
        await using (var kontrol = new NpgsqlCommand(
            "select paylasim_kodu from public.dokuman where id = @p0", baglanti, islem))
        {
            kontrol.Parameters.AddWithValue("p0", dokumanId);
            await using var okuyucu = await kontrol.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Doküman bulunamadı.");
            mevcutKod = okuyucu.IsDBNull(0) ? null : okuyucu.GetString(0);
        }
        if (mevcutKod is not null)
        {
            await islem.CommitAsync(iptal);
            return mevcutKod;
        }

        var yeniKod = Guid.NewGuid().ToString("N");
        await using (var guncelle = new NpgsqlCommand(
            "update public.dokuman set paylasim_kodu = @p0, degistiren = @p1 where id = @p2", baglanti, islem))
        {
            guncelle.Parameters.AddWithValue("p0", yeniKod);
            guncelle.Parameters.AddWithValue("p1", baglam.KullaniciId);
            guncelle.Parameters.AddWithValue("p2", dokumanId);
            await guncelle.ExecuteNonQueryAsync(iptal);
        }
        await islem.CommitAsync(iptal);
        return yeniKod;
    }

    /// <summary>Kimliksiz paylaşım ucu içindir - <see cref="PaylasAsync"/> ile üretilen kod.</summary>
    public async Task<DokumanIcerik?> IcerikPaylasimKoduIleAsync(string kod, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select i.icerik, d.content_type, d.ad
              from public.dokuman d join public.dokuman_icerik i on i.hash = d.hash
             where d.paylasim_kodu = @p0
            """, null,
            kod);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        if (!await okuyucu.ReadAsync(iptal)) return null;
        return new DokumanIcerik((byte[])okuyucu[0], okuyucu.GetString(1), okuyucu.GetString(2));
    }

    // dokumanId'den tek satır okur, yoksa Bulunamadi fırlatır - Duzenle/VarsayilanYap/Sil
    // hep "önce kaynak/kaynakId (+ birkaç kolon) çek" ile başlar, bu tekrarı toplar.
    private static async Task<T> SatirBulAsync<T>(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        string sql, int dokumanId, Func<NpgsqlDataReader, T> oku, CancellationToken iptal)
    {
        await using var kontrol = baglanti.Komut(sql, islem,
            dokumanId);
        await using var okuyucu = await kontrol.ExecuteReaderAsync(iptal);
        if (!await okuyucu.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Doküman bulunamadı.");
        return oku(okuyucu);
    }

    /// <summary>
    /// Ayni kaynagin onceki varsayilanini birakir. YONE DUYARLI (160): varsayilan
    /// kisiti (kaynak, kaynak_id, yon) uzerinde - gelen sablonu varsayilan
    /// yapmak, gidenin varsayilanini dusurmemeli.
    /// </summary>
    private static async Task VarsayilaniKaldirAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        string kaynak, long kaynakId, int kullaniciId, CancellationToken iptal, short yon = 0)
    {
        await using var komut = baglanti.Komut("""
            update public.dokuman set varsayilan = 0, degistiren = @p0
             where kaynak = @p1 and kaynak_id = @p2 and yon = @p3 and varsayilan = 1
            """, islem,
            kullaniciId, kaynak, kaynakId, yon);
        await komut.ExecuteNonQueryAsync(iptal);
    }
}
