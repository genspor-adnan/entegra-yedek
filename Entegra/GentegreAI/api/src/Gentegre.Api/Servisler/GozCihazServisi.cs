using System.Globalization;
using System.Text.Json;
using System.Text.RegularExpressions;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GÖZ CİHAZ MESAJI AYRIŞTIRICISI (691/703).
///
/// <para>Ünitedeki otorefraktometre, tonometre, OCT ve biyometri kendi
/// çıktısını gönderiyor; bu servis onu <b>hastanın ölçüm satırına</b> çevirir.
/// Olmadığında tekniker sayıları ekrandan okuyup elle giriyordu — göz
/// ünitesinde bir ziyarette on beş sayı var ve elle giriş hem zaman alıyor hem
/// de rakam hatasını kaçınılmaz kılıyor.</para>
///
/// <para><b>TAHMİN YOK.</b> Hasta eşleşmezse ölçüm YAZILMAZ, mesaj sahipsiz
/// kalır ve kuyrukta bekler: tahmin ederek yazmak, başkasının ölçümünü
/// hastanın dosyasına koymaktır. Aynı sebeple muayenesi açılmamış hastanın
/// ölçümü de beklemeye alınır — kayıt açmak için hastayı görmek gerekir.</para>
///
/// <para><b>Eşleme haritası CİHAZDA</b> (<c>goz_cihaz.olcum_esleme</c>):
/// "S → sph", "IOP → gib". Her cihaz modeli kendi anahtarını kullanıyor;
/// haritayı koda gömmek, yeni cihaz alındığında sürüm çıkmayı gerektirirdi.</para>
///
/// <para><b>Mesaj İKİNCİ KEZ işlenebilir</b> (sürücü düzeltilince): ölçüm
/// satırı <c>cihaz_mesaj_id</c> taşır ve benzersiz indeks mükerrer yazımı
/// veritabanında engeller. "Önce sil sonra yaz" deseni, araya giren bir hatada
/// hastayı ölçümsüz bırakırdı.</para>
/// </summary>
public sealed class GozCihazServisi
{
    private readonly VeriKaynagi _veri;
    public GozCihazServisi(VeriKaynagi veri) { _veri = veri; }

    public sealed record Sonuc(int Okunan, int Islenen, int Sahipsiz, int Hatali,
                               string Aciklama);

    /// <summary>Ayrıştırılmış tek ölçüm: hangi göz, hangi ölçüm, hangi değer.</summary>
    private sealed record Deger(short Goz, string Olcum, decimal Sayi);

    // ------------------------------------------------------------ kuyruk ----
    /// <summary>
    /// Bekleyen (0) ve sahipsiz (2) mesajları işler. SAHİPSİZ DE DENENİR:
    /// hasta sonradan eşleşebilir — muayene açılır, protokol düzeltilir.
    /// </summary>
    public async Task<Sonuc> CalistirAsync(int enFazla = 50, long? mesajId = null,
                                           CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var mesajlar = await baglanti.ListeAsync("""
            select m.id, m.cihaz_id, m.zaman, m.hasta_eslesme, m.ham,
                   c.tur, c.protokol, c.olcum_esleme::text, c.ad
              from public.goz_cihaz_mesaj m
              join public.goz_cihaz c on c.id = m.cihaz_id
             where (@p0::bigint is not null and m.id = @p0)
                or (@p0::bigint is null and m.islem_durum in (0, 2))
             order by m.zaman
             limit @p1
            """, null, [mesajId, enFazla], o => new
        {
            id = o.GetInt64(0),
            cihazId = o.GetInt32(1),
            zaman = o.GetDateTime(2),
            eslesme = o.GetString(3),
            ham = o.GetString(4),
            tur = (int)o.GetInt16(5),
            protokol = (int)o.GetInt16(6),
            esleme = o.GetString(7),
            cihazAd = o.GetString(8),
        }, iptal);

        int islenen = 0, sahipsiz = 0, hatali = 0;

        foreach (var m in mesajlar)
        {
            try
            {
                var harita = HaritaOku(m.esleme);
                var degerler = Ayristir(m.ham, m.protokol, harita);

                if (degerler.Count == 0)
                {
                    await DurumYazAsync(baglanti, m.id, 3,
                        "Mesajdan ölçüm çıkarılamadı (eşleme haritası ya da biçim uymuyor).",
                        iptal);
                    hatali++;
                    continue;
                }

                var hastaId = await HastaBulAsync(baglanti, m.eslesme, iptal);
                if (hastaId is null)
                {
                    await DurumYazAsync(baglanti, m.id, 2,
                        m.eslesme.Length == 0
                            ? "Mesajda hasta bilgisi yok; elle eşleştirilmeli."
                            : $"'{m.eslesme}' ile hasta bulunamadı.", iptal);
                    sahipsiz++;
                    continue;
                }

                // MUAYENE AÇILMAMIŞSA ÖLÇÜM YAZILMAZ: ölçüm bir muayenenin
                //   parçası. Muayenesiz yazmak, hekimin hiç görmediği hastada
                //   ölçüm geçmişi üretirdi. Mesaj kuyrukta bekler; muayene
                //   açılınca gece işi ya da düğme onu işler.
                var muayene = await MuayeneBulAsync(baglanti, hastaId.Value, m.zaman, iptal);
                if (muayene is null)
                {
                    await DurumYazAsync(baglanti, m.id, 2,
                        "Hasta bulundu ama o güne ait göz muayenesi yok; muayene açılınca işlenir.",
                        iptal);
                    sahipsiz++;
                    continue;
                }

                var yazilan = await YazAsync(baglanti, m.id, m.cihazId, m.tur,
                                             muayene.GozMuayeneId, muayene.MuayeneId,
                                             hastaId.Value, m.zaman, degerler, iptal);

                await DurumYazAsync(baglanti, m.id, 1,
                    $"{yazilan} ölçüm yazıldı ({m.cihazAd}).", iptal);
                islenen++;
            }
            catch (Exception h)
            {
                // TEK MESAJIN HATASI KUYRUĞU DÜŞÜRMEZ: sebebi satıra yazılır,
                //   kuyruk devam eder. Yoksa bozuk tek bir dosya, günün bütün
                //   ölçümlerini bekletirdi.
                await DurumYazAsync(baglanti, m.id, 3, Kirp(h.Message, 300), iptal);
                hatali++;
            }
        }

        var aciklama = mesajlar.Count == 0
            ? "İşlenecek cihaz mesajı yok."
            : $"{mesajlar.Count} mesaj: {islenen} işlendi, {sahipsiz} sahipsiz, {hatali} hata.";
        return new Sonuc(mesajlar.Count, islenen, sahipsiz, hatali, aciklama);
    }

    // ---------------------------------------------------------- ayrıştırma ----
    /// <summary>Cihazın kendi anahtarı → bizim ölçüm adımız (büyük/küçük harf duyarsız).</summary>
    private static Dictionary<string, string> HaritaOku(string json)
    {
        var harita = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (string.IsNullOrWhiteSpace(json)) return harita;
        using var belge = JsonDocument.Parse(json);
        foreach (var alan in belge.RootElement.EnumerateObject())
            harita[alan.Name] = alan.Value.GetString() ?? "";
        return harita;
    }

    /// <summary>
    /// Göz belirteçleri. Cihazlar R/L, OD/OS, RIGHT/LEFT karışık kullanıyor;
    /// üçünü de tanımak, her model için ayrı sürücü yazmaktan ucuz.
    /// </summary>
    private static short? GozKodu(string parca) => parca.ToUpperInvariant() switch
    {
        "R" or "OD" or "RIGHT" or "SAG" or "SAĞ" => 1,
        "L" or "OS" or "LEFT" or "SOL" => 2,
        "OU" or "BOTH" => 3,
        _ => null,
    };

    private static readonly Regex XmlEtiket =
        new(@"<([A-Za-z_][\w.]*)>\s*([^<]*)\s*</\1>", RegexOptions.Compiled);

    /// <summary>
    /// HAM METİNDEN ÖLÇÜM ÜÇLÜLERİ. İki biçim tanınır:
    ///
    ///   * SATIR/TOKEN: "R  S-2.25  C-0.75  A170  K1 43.25" — göz belirteci
    ///     bir kez geçer, sonraki anahtarlar ona aittir.
    ///   * ANAHTAR-ÖNCE: "IOP R 19.5  L 18.0  CCT R 545" — anahtar bir kez
    ///     geçer, ardından göz+değer çiftleri gelir.
    ///
    /// İkisini AYRI ayrıştırıcı yapmadık: aynı akış içinde "son görülen göz" ve
    /// "son görülen anahtar" birlikte taşınırsa iki biçim de tek geçişte
    /// çözülüyor. Üçüncü bir biçim çıkarsa buraya eklenir, cihaz başına sürücü
    /// yazılmaz.
    /// </summary>
    private static List<Deger> Ayristir(string ham, int protokol,
                                        Dictionary<string, string> harita)
    {
        var sonuc = new List<Deger>();
        if (string.IsNullOrWhiteSpace(ham) || harita.Count == 0) return sonuc;

        // PROTOKOL 1 = XML/dosya çıktısı (OCT raporu gibi).
        if (protokol == 1 || ham.TrimStart().StartsWith('<'))
        {
            short xmlGoz = 3;
            foreach (Match e in XmlEtiket.Matches(ham))
            {
                var ad = e.Groups[1].Value;
                var deger = e.Groups[2].Value.Trim();

                // <Eye>OD</Eye> gibi bir etiket sonraki ölçümlerin gözünü belirler.
                if (ad.Equals("Eye", StringComparison.OrdinalIgnoreCase)
                    || ad.Equals("Goz", StringComparison.OrdinalIgnoreCase))
                {
                    xmlGoz = GozKodu(deger) ?? xmlGoz;
                    continue;
                }
                // Etiket adında göz geçebilir: <OD_RNFL_Avg>
                var gozOnEk = ad.Length > 3 ? GozKodu(ad[..2]) : null;
                var anahtar = gozOnEk is null ? ad : ad[3..];

                if (!harita.TryGetValue(anahtar, out var olcum)) continue;
                if (!SayiOku(deger, out var sayi)) continue;   // "—" gibi boş değer atlanır
                sonuc.Add(new Deger(gozOnEk ?? xmlGoz, olcum, sayi));
            }
            return sonuc;
        }

        // DÜZ METİN: boşlukla ayrılmış token'lar.
        short? sonGoz = null;
        string? sonAnahtar = null;

        foreach (var ham2 in ham.Split([' ', '\t', '\r', '\n', ';', ','],
                                       StringSplitOptions.RemoveEmptyEntries))
        {
            var parca = ham2.Trim();

            if (GozKodu(parca) is short g) { sonGoz = g; continue; }

            // SIRA ÖNEMLİ - "K1" hem anahtar hem "K"+"1" gibi okunabiliyor:
            //
            //   1) Token'ın TAMAMI haritada mı? ("IOP", "CCT", "K1", "K2")
            //      Değeri bir sonraki token'da. Bu kontrol regex'ten ÖNCE
            //      olmalı: aksi hâlde "K1" tokeni "K" anahtarı + "1" değeri
            //      diye ayrışıyor ve ardından gelen 43.25 bir önceki anahtara
            //      (aks) yazılıyordu - otorefraktometre çıktısında aks 170
            //      yerine 44 görünüyordu.
            //   2) Yalnız sayı mı? Son anahtar + son göz ile eşleşir.
            //   3) Anahtar ve değer BİTİŞİK mi? ("S-2.25", "A170")
            //      Haritadaki anahtarlar UZUNDAN KISAYA denenir; "K1" varken
            //      "K" ile eşleşip yanlış ölçüme yazmasın.
            if (harita.ContainsKey(parca)) { sonAnahtar = parca; continue; }

            if (SayiOku(parca, out var sayi3))
            {
                if (sonAnahtar is not null && harita.TryGetValue(sonAnahtar, out var olcum3))
                    sonuc.Add(new Deger(sonGoz ?? 3, olcum3, sayi3));
                continue;
            }

            var bitisik = harita.Keys
                .Where(k => parca.StartsWith(k, StringComparison.OrdinalIgnoreCase))
                .OrderByDescending(k => k.Length)
                .FirstOrDefault(k => SayiOku(parca[k.Length..], out _));
            if (bitisik is not null && SayiOku(parca[bitisik.Length..], out var sayi2))
            {
                sonuc.Add(new Deger(sonGoz ?? 3, harita[bitisik], sayi2));
                sonAnahtar = bitisik;
            }
        }

        return sonuc;
    }

    private static bool SayiOku(string metin, out decimal sayi)
        => decimal.TryParse(metin.Replace(',', '.'), NumberStyles.Number,
                            CultureInfo.InvariantCulture, out sayi);

    // ------------------------------------------------------- eşleştirme ----
    /// <summary>
    /// HASTA EŞLEŞTİRME sırası: hasta kodu → TCKN → o gün açılmış başvurunun
    /// belge numarası. Üçü de tutmazsa null döner ve mesaj sahipsiz kalır.
    /// "Ada göre en yakın" gibi bir tahmin YOK: yanlış hastaya yazılan ölçüm,
    /// hiç yazılmayandan çok daha pahalıdır.
    /// </summary>
    private static async Task<int?> HastaBulAsync(Npgsql.NpgsqlConnection baglanti,
                                                  string eslesme, CancellationToken iptal)
    {
        var anahtar = eslesme.Trim();
        if (anahtar.Length == 0) return null;

        return await baglanti.TekDegerAsync<int?>("""
            select coalesce(
                (select t.id from public.taraf t where t.kod = @p0 limit 1),
                (select t.id from public.taraf t where t.vkno = @p0 limit 1),
                (select b.taraf_id from public.belge b
                  where b.belge_no = @p0 and b.tur = 19 limit 1))
            """, null, [anahtar], iptal);
    }

    /// <summary>
    /// İKİ KİMLİK BİRDEN: ölçüm tabloları GÖZ MUAYENESİNE (goz_muayene),
    /// görüntüleme kaydı ise GENEL MUAYENEYE (muayene) bağlanıyor. Tek kimlik
    /// döndürüp ikisinde de kullanmak, görüntüleme satırını yabancı anahtar
    /// hatasına düşürüyordu.
    /// </summary>
    private sealed record MuayeneKimligi(int GozMuayeneId, int MuayeneId);

    /// <summary>
    /// MESAJIN GÜNÜNDEKİ göz muayenesi. Cihaz ölçümü muayene sırasında
    /// alınıyor; başka bir günün muayenesine yazmak, iki ziyareti tek
    /// muayenede karıştırırdı.
    /// </summary>
    private static async Task<MuayeneKimligi?> MuayeneBulAsync(
        Npgsql.NpgsqlConnection baglanti, int hastaId, DateTime zaman,
        CancellationToken iptal)
        => await baglanti.TekAsync("""
            select gm.id, m.id
              from public.goz_muayene gm
              join public.muayene m on m.id = gm.muayene_id
             where gm.hasta_id = @p0
               and m.muayene_tarihi >= @p1::date
               and m.muayene_tarihi <  (@p1::date + 1)
             order by m.muayene_tarihi desc
             limit 1
            """, null, [hastaId, zaman],
            o => new MuayeneKimligi(o.GetInt32(0), o.GetInt32(1)), iptal);

    // ------------------------------------------------------------- yazma ----
    private static async Task<int> YazAsync(Npgsql.NpgsqlConnection baglanti, long mesajId,
                                            int cihazId, int cihazTur, int gozMuayeneId,
                                            int muayeneId, int hastaId, DateTime zaman,
                                            List<Deger> degerler, CancellationToken iptal)
    {
        // GÖZ BAZINDA TEK SATIR: bir mesaj iki gözün değerlerini taşıyor,
        //   ölçüm tablosu ise göz bazlı. Aynı gözün sph/cyl/aks değerleri tek
        //   satırda toplanır - üç ayrı satır, "hangi sph hangi cyl ile" diye
        //   sorulmasına yol açardı.
        var gozler = degerler.Select(d => d.Goz).Distinct().ToList();
        var yazilan = 0;

        foreach (var goz in gozler)
        {
            var d = degerler.Where(x => x.Goz == goz)
                            .GroupBy(x => x.Olcum)
                            .ToDictionary(g => g.Key, g => g.Last().Sayi,
                                          StringComparer.OrdinalIgnoreCase);
            decimal? Al(string ad) => d.TryGetValue(ad, out var v) ? v : null;

            switch (cihazTur)
            {
                // OTOREFRAKTOMETRE / KERATOMETRE -> refraksiyon (tur 1).
                case 1:
                    await baglanti.CalistirAsync("""
                        insert into public.goz_refraksiyon
                            (goz_muayene_id, goz, kaynak, zaman, tur, sph, cyl, aks,
                             k1, k2, cihaz_id, cihaz_mesaj_id, ekleyen)
                        values (@p0, @p1, 3, @p2, 1, @p3, @p4, @p5, @p6, @p7, @p8, @p9, 0)
                        on conflict (cihaz_mesaj_id, goz) where cihaz_mesaj_id is not null
                        do nothing
                        """, null,
                        [gozMuayeneId, goz, zaman, Al("sph"), Al("cyl"),
                         Al("aks") is decimal a ? (short)a : null,
                         Al("k1"), Al("k2"), cihazId, mesajId], iptal);
                    yazilan++;
                    break;

                // TONOMETRE ve PAKİMETRE -> tonometri satırı. Pakimetre tek
                //   başına CCT ölçer; ayrı tablo açmak, glokom hesabında iki
                //   kaynaktan CCT aramak demekti.
                case 2:
                case 3:
                    await baglanti.CalistirAsync("""
                        insert into public.goz_tonometri
                            (goz_muayene_id, goz, kaynak, zaman, yontem, gib, cct_um,
                             cihaz_id, cihaz_mesaj_id, ekleyen)
                        values (@p0, @p1, 3, @p2, @p3, @p4, @p5, @p6, @p7, 0)
                        on conflict (cihaz_mesaj_id, goz) where cihaz_mesaj_id is not null
                        do nothing
                        """, null,
                        [gozMuayeneId, goz, zaman, (short)(cihazTur == 2 ? 1 : 5),
                         Al("gib"), Al("cct") is decimal c ? (short)c : null,
                         cihazId, mesajId], iptal);
                    yazilan++;
                    break;

                // GÖRÜNTÜLEME CİHAZLARI (OCT, görme alanı, fundus, topografi,
                //   biyometri, endotel, USG) -> görüntüleme + ölçüm satırları.
                default:
                    var goruntulemeId = await baglanti.TekDegerAsync<int>("""
                        insert into public.goz_goruntuleme
                            (muayene_id, hasta_id, goz, tetkik, cihaz_id, istem_zamani,
                             cekim_zamani, durum, cihaz_mesaj_id, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4, @p5, @p5, 2, @p6, 0)
                        on conflict (cihaz_mesaj_id, goz) where cihaz_mesaj_id is not null
                        do update set cekim_zamani = excluded.cekim_zamani
                        returning id
                        """, null,
                        [muayeneId, hastaId, goz, (short)TetkikKodu(cihazTur), cihazId,
                         zaman, mesajId], iptal);

                    foreach (var (olcum, deger) in d)
                    {
                        await baglanti.CalistirAsync("""
                            insert into public.goz_goruntuleme_olcum
                                (goruntuleme_id, goz, olcum, deger, ekleyen)
                            values (@p0, @p1, @p2, @p3, 0)
                            -- AYNI ÇEKİMDE AYNI ÖLÇÜM TEK SATIR (704): mesaj
                            --   yeniden işlendiğinde değer güncellenir. İkinci
                            --   satır açmak, trend eğrisinde aynı günü iki
                            --   nokta saydırırdı.
                            on conflict (goruntuleme_id, goz, olcum)
                            do update set deger = excluded.deger,
                                          degistirme_tarihi = now()
                            """, null, [goruntulemeId, goz, olcum, deger], iptal);
                        yazilan++;
                    }
                    break;
            }
        }

        return yazilan;
    }

    /// <summary>Cihaz türü → tetkik kodu (goz.goruntuleme_tur). Bilinmeyen tür 0 kalır.</summary>
    private static int TetkikKodu(int cihazTur) => cihazTur switch
    {
        4 => 1,   // OCT
        5 => 3,   // Görme alanı
        6 => 4,   // Fundus foto
        7 => 5,   // Topografi
        8 => 6,   // Biyometri
        9 => 7,   // Endotel
        10 => 8,  // USG
        _ => 0,
    };

    private static async Task DurumYazAsync(Npgsql.NpgsqlConnection baglanti, long id,
                                            short durum, string hata, CancellationToken iptal)
        => await baglanti.CalistirAsync("""
            update public.goz_cihaz_mesaj
               set islem_durum = @p1, hata = @p2, degistirme_tarihi = now()
             where id = @p0
            """, null, [id, durum, Kirp(hata, 300)], iptal);

    private static string Kirp(string m, int n) => m.Length <= n ? m : m[..n];
}
