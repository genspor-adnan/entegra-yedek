using System.Diagnostics;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// DÖKÜM TANIMLARI (686): kayıt, sürüm, görünürlük ve ÇALIŞTIRMA.
///
/// Çalıştırma iki yol: liste çıktısı ListeDeposu'nun kendisidir (aynı sayfalama,
/// aynı toplamlar); özet çıktısı SorguUretici.Ozet ile tek sorgu + isteğe bağlı
/// kıyas sorgusu. İkisinde de WHERE liste ekranıyla birebir - döküm, listeden
/// farklı bir veri gösteremez.
/// </summary>
public sealed class DokumDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly ListeDeposu _liste;

    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    public DokumDeposu(VeriKaynagi veri, ListeDeposu liste) { _veri = veri; _liste = liste; }

    private const string SecimSql = """
        select d.id, d.kod, d.ad, d.aciklama, d.kaynak, d.tanim::text, d.surum, coalesce(d.sahip_id, 0),
               coalesce(tk.kod, '') as sahip, d.gorunurluk, d.roller, d.son_calisma, d.calisma_sayisi,
               d.sistem, d.urun_modu, d.modul, d.menu_grup
          from public.dokum_tanimi d
          left join public.taraf_kullanici tk on tk.id = d.sahip_id
        """;

    private static DokumKaydi Oku(NpgsqlDataReader o, int kullaniciId, bool tamYetki) => new()
    {
        Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2), Aciklama = o.GetString(3),
        Kaynak = o.GetString(4),
        Tanim = JsonSerializer.Deserialize<DokumTanimi>(o.GetString(5), Json) ?? new DokumTanimi(),
        Surum = o.GetInt32(6), SahipId = o.GetInt32(7), Sahip = o.GetString(8),
        Gorunurluk = o.GetInt16(9), Roller = o.IsDBNull(10) ? [] : o.GetFieldValue<int[]>(10),
        SonCalisma = o.IsDBNull(11) ? null : o.GetDateTime(11), CalismaSayisi = o.GetInt32(12),
        Sistem = o.GetInt16(13) == 1, UrunModu = o.GetInt16(14), Modul = o.GetString(15),
        // 690: dokumun MENU GRUBU - grup icindeki "Dökümler" ogesi buna gore
        //   suzer. Kaynaktan turetmek yanlisti: `belge` hem basvuru hem satis
        //   hem alis ekranlarinda kullaniliyor.
        MenuGrup = o.GetString(16),
        // Düzenleme: sahibi ya da Degistir yetkisi olan (yönetici). STANDART
        //   döküm kimse tarafından düzenlenmez - kopyalanır (688).
        Duzenlenebilir = o.GetInt16(13) != 1 && (tamYetki || o.GetInt32(7) == kullaniciId),
    };

    /// <summary>
    /// Kullanıcının GÖRDÜĞÜ dökümler: kendisininkiler + rolüne paylaşılanlar +
    /// kurum geneli. Kaynak yetkisi ayrıca ÇAĞIRAN tarafından süzülür (katalog
    /// bilgisi burada yok).
    /// </summary>
    public Task<List<DokumKaydi>> ListeAsync(int kullaniciId, int rolId, bool tamYetki,
                                             string? kaynak, CancellationToken iptal)
        => _veri.ListeAsync(SecimSql + """
             where d.aktif = 1
               and (@p0 or d.sahip_id = @p1 or d.gorunurluk = 2
                    or (d.gorunurluk = 1 and @p2 = any(d.roller)))
               and (@p3 = '' or d.kaynak = @p3)
             order by d.sistem desc, d.ad
            """, [tamYetki, kullaniciId, rolId, kaynak ?? ""],
            o => Oku(o, kullaniciId, tamYetki), iptal);

    public Task<DokumKaydi?> BulAsync(int id, int kullaniciId, bool tamYetki, CancellationToken iptal)
        => _veri.TekAsync(SecimSql + " where d.id = @p0", [id],
            o => Oku(o, kullaniciId, tamYetki), iptal);

    /// <summary>Kaydeder; varsa yeni sürüm yazar. Kod boşsa addan üretilir.</summary>
    public async Task<int> KaydetAsync(DokumKaydi k, YazmaBaglami baglam, CancellationToken iptal)
    {
        var tanim = JsonSerializer.Serialize(k.Tanim, Json);
        var kod = string.IsNullOrWhiteSpace(k.Kod) ? KodUret(k.Ad) : k.Kod.Trim();

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        int id;
        if (k.Id > 0)
        {
            id = k.Id;
            await baglanti.CalistirAsync("""
                update public.dokum_tanimi
                   set kod = @p1, ad = @p2, aciklama = @p3, kaynak = @p4, tanim = @p5::jsonb,
                       surum = surum + 1, gorunurluk = @p6, roller = @p7,
                       degistiren = @p8, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, kod, k.Ad.Trim(), k.Aciklama ?? "", k.Kaynak, tanim, k.Gorunurluk,
                      k.Roller, baglam.KullaniciId], iptal);
        }
        else
        {
            // KOD BENZERSİZ: aynı addan ikinci döküm açılırsa sonek alır.
            var sayi = await baglanti.TekDegerAsync<long>(
                "select count(*) from public.dokum_tanimi where kod like @p0 || '%'", islem, [kod], iptal);
            if (sayi > 0) kod = $"{kod}-{sayi + 1}";
            id = await baglanti.TekDegerAsync<int>("""
                insert into public.dokum_tanimi
                    (kod, ad, aciklama, kaynak, tanim, sahip_id, gorunurluk, roller, sube_id,
                     ekleyen, degistiren)
                values (@p0, @p1, @p2, @p3, @p4::jsonb, @p5, @p6, @p7, @p8, @p5, @p5)
                returning id
                """, islem, [kod, k.Ad.Trim(), k.Aciklama ?? "", k.Kaynak, tanim, baglam.KullaniciId,
                      k.Gorunurluk, k.Roller, baglam.SubeId], iptal);
        }

        await baglanti.CalistirAsync("""
            insert into public.dokum_surum (dokum_id, surum, tanim, kullanici_id)
            select id, surum, tanim, @p1 from public.dokum_tanimi where id = @p0
            """, islem, [id, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);
        return id;
    }

    public Task<int> PasifeAlAsync(int id, YazmaBaglami baglam, CancellationToken iptal)
        => _veri.CalistirAsync(
            "update public.dokum_tanimi set aktif = 0, degistiren = @p1, degistirme_tarihi = now() where id = @p0",
            [id, baglam.KullaniciId], iptal);

    public Task<List<(int Surum, DateTime Tarih, string Kullanici)>> SurumlerAsync(int id, CancellationToken iptal)
        => _veri.ListeAsync("""
            select s.surum, s.tarih, coalesce(tk.kod, '')
              from public.dokum_surum s
              left join public.taraf_kullanici tk on tk.id = s.kullanici_id
             where s.dokum_id = @p0 order by s.surum desc limit 20
            """, [id], o => (o.GetInt32(0), o.GetDateTime(1), o.GetString(2)), iptal);

    /// <summary>Sayaç: son çalışma zamanı + adet. Kayıtlı dökümde çağrılır.</summary>
    public Task CalistirildiAsync(int id, CancellationToken iptal)
        => _veri.CalistirAsync(
            "update public.dokum_tanimi set son_calisma = now(), calisma_sayisi = calisma_sayisi + 1 where id = @p0",
            [id], iptal);

    /// <summary>Liste çıktısı: ListeDeposu'nun kendisi - döküm listeden farklı bir şey göstermez.</summary>
    public Task<ListeYaniti> ListeCalistirAsync(KaynakTanimi kaynak, DokumTanimi tanim, Kosul? filtre,
        IReadOnlyList<KolonTanimi> kolonlar, int sayfa, int boyut, int? subeId,
        IReadOnlyList<int>? kapsam, string izlemeNo, int? kullaniciId, CancellationToken iptal)
    {
        var istek = new ListeIstegi
        {
            Sayfa = sayfa, Boyut = boyut, Filtre = filtre, Sirala = tanim.Sirala,
            Toplam = tanim.Toplam, Grup = tanim.Grup,
        };
        // Yalnız tanımdaki kolonlar (görünür kümeden) gider; seçilmemişse hepsi.
        //   GRUP ve TOPLAM kolonları her zaman eklenir: grup kolonu listede
        //   gösterilmese de satırda gelmeli - yoksa istemci "(boş)" grubu
        //   çiziyordu (lab istemleri, bölüm koduna göre grup).
        var secilen = tanim.Kolonlar is { Count: > 0 }
            ? kolonlar.Where(k => tanim.Kolonlar.Contains(k.Ad)
                                  || (tanim.Grup?.Contains(k.Ad) ?? false)
                                  || (tanim.Toplam?.Contains(k.Ad) ?? false)).ToList()
            : kolonlar.ToList();
        return _liste.SorgulaAsync(kaynak, istek, secilen, subeId, kapsam, izlemeNo, kullaniciId, iptal);
    }

    /// <summary>Özet çıktısı: tek sorgu; kıyas varsa ikinci sorgu aynı plan, kaydırılmış tarih.</summary>
    public async Task<OzetYaniti> OzetCalistirAsync(KaynakTanimi kaynak, DokumTanimi tanim, Kosul? filtre,
        int? subeId, IReadOnlyList<int>? kapsam, string izlemeNo, CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        var plan = new SorguUretici(kaynak).Ozet(tanim, filtre, subeId, kapsam);

        await using var baglanti = await _veri.AcAsync(iptal);
        var satirlar = await Satirlar(baglanti, plan.Sorgu, iptal);

        List<IDictionary<string, object?>>? kiyas = null;
        var kiyasAraligi = "";
        if (ParametreCozucu.Kiyas(filtre, kaynak, tanim.Kiyas) is { } k)
        {
            var kiyasPlan = new SorguUretici(kaynak).Ozet(tanim, k.Filtre, subeId, kapsam);
            kiyas = await Satirlar(baglanti, kiyasPlan.Sorgu, iptal);
            kiyasAraligi = k.Aralik;
        }

        kronometre.Stop();
        return new OzetYaniti
        {
            Boyutlar = plan.Boyutlar, Olculer = plan.Olculer, Satirlar = satirlar,
            Kiyas = kiyas, KiyasAraligi = kiyasAraligi,
            SureMs = kronometre.ElapsedMilliseconds, IzlemeNo = izlemeNo,
        };
    }

    private async Task<List<IDictionary<string, object?>>> Satirlar(NpgsqlConnection baglanti,
        SorguParcasi sorgu, CancellationToken iptal)
    {
        var liste = new List<IDictionary<string, object?>>();
        await using var komut = _veri.Komut(baglanti, sorgu.Sql, sorgu.Parametreler);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
        {
            var satir = new Dictionary<string, object?>(okuyucu.FieldCount, StringComparer.Ordinal);
            for (var i = 0; i < okuyucu.FieldCount; i++)
                satir[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
            liste.Add(satir);
        }
        return liste;
    }

    /// <summary>Kurum anteti (baskı): aktif şube; yoksa varsayılan şube.</summary>
    public Task<Dictionary<string, object?>?> AntetAsync(int? subeId, CancellationToken iptal)
        => _veri.TekAsync("""
            select coalesce(nullif(s.unvan, ''), s.ad) as unvan, s.adres, s.ilce, s.il,
                   s.telefon, s.mersis_no as "mersisNo", s.vkno, s.vd, s.ad as "subeAd"
              from public.sube s
             where s.id = coalesce(@p0, (select id from public.sube where varsayilan = 1 limit 1))
            """, [subeId], o =>
            {
                var d = new Dictionary<string, object?>(StringComparer.Ordinal);
                for (var i = 0; i < o.FieldCount; i++) d[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
                return d;
            }, iptal);

    /// <summary>"Kurum bazlı hekim cirosu" → "kurum-bazli-hekim-cirosu".</summary>
    private static string KodUret(string ad)
    {
        var s = ad.Trim().ToLowerInvariant()
            .Replace('ı', 'i').Replace('ğ', 'g').Replace('ü', 'u').Replace('ş', 's')
            .Replace('ö', 'o').Replace('ç', 'c').Replace('İ', 'i');
        var sb = new System.Text.StringBuilder();
        foreach (var ch in s)
            sb.Append(char.IsLetterOrDigit(ch) ? ch : '-');
        var kod = System.Text.RegularExpressions.Regex.Replace(sb.ToString(), "-+", "-").Trim('-');
        return kod.Length == 0 ? "dokum" : kod[..Math.Min(kod.Length, 50)];
    }
}
