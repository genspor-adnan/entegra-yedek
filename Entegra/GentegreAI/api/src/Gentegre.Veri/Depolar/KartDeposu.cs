using System.Globalization;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Kart yazma islemi icin cagirandan gelen baglam (kim, hangi sube, hangi IP).</summary>
public sealed record YazmaBaglami(int KullaniciId, int? SubeId, string Ip,
    /// <summary>
    /// AKTIF SUBENIN ULKESI (666), ISO 3166 iki harf. Dogrulama kurallari buna
    /// bakar: TR disinda T.C. kimlik numarasi ve Turkiye telefon bicimi
    /// KONTROL EDILMEZ - Alman hastanin 11 haneli TCKN'si olmaz, kontrolu acik
    /// birakmak kaydi imkansiz kilardi. Varsayilan TR: bilgi gelmezse
    /// kontrolun ACIK kalmasi, sessizce kapanmasindan iyidir.
    /// </summary>
    string UlkeKod = "TR",
    /// <summary>
    /// KIMLIK NO BICIMI (679) - kurum profilinden cozulmus kural. Yazma
    /// yolunda alan dogrulamasi buna bakar; gelmezse kontrol ACIK kalir.
    /// </summary>
    Gentegre.Cekirdek.Katalog.KimlikKurali? KimlikKurali = null,
    /// <summary>
    /// AKTIF SUBENIN SAAT DILIMI (666/667), IANA adi. Kullanicinin yazdigi
    /// duvar saati bu dilimde yorumlanip UTC ana cevrilir; "ileri tarihli mi",
    /// "kac gun gecti" sorulari da bu dilimin GUNUNDE cevaplanir. Bos ise
    /// kurulus dilimi kullanilir.
    /// </summary>
    string ZamanDilimi = "")
{
    /// <summary>
    /// SUBE ZORUNLU olan kayitlar (belge, kasa islemi, cek/senet...) icin sube
    /// kimligi. Kullaniciya sube tanimlanmamissa `sube_id` 0 yaziliyor ve kayit
    /// veritabaninda FK ihlaliyle patliyordu:
    ///
    ///     fk_kasa_islem_sube - Key (sube_id)=(0) is not present in table "sube"
    ///
    /// Kullanici bunu "Beklenmeyen bir hata oluştu" olarak goruyordu; oysa
    /// eksik olan sey belli ve duzeltmesi yoneticinin elinde. Artik ne yapmasi
    /// gerektigini soyleyen bir DOGRULAMA hatasi doner.
    /// </summary>
    public int SubeZorunlu()
        => SubeId ?? throw GentegreHatasi.Dogrulama(
               "Kullanıcınıza şube tanımlı değil - bu kayıt bir şubeye bağlanmalı. "
             + "Yönetim > Kullanıcılar ekranından şube yetkisi verin.",
               new AlanHatasi("subeId", "Kullanıcının şubesi yok."));
}

/// <summary>
/// Kart okuma / yazma / silme. Tum yazmalar TEK TRANSACTION - kart, detaylar ve
/// islem_log ya hep birlikte yazilir ya hicbiri.
///
/// Esszamanlilik damgasi = PG'nin satir surumu (xmin). Ayri "surum" kolonu yok;
/// guncelleme "where xmin = @surum" ile yazar, satir guncellenmediyse 409 doner.
/// </summary>
public sealed partial class KartDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    public KartDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    // ============================================================== EKLEME ====
    public async Task<long> EkleAsync(KartTanimi tanim, IDictionary<string, object?> degerler,
        Dictionary<string, DetayFarki>? detaylar, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        foreach (var (ad, deger) in tanim.YeniKayitVarsayilanlari ?? new Dictionary<string, object?>())
            if (!degerler.ContainsKey(ad))
                // "@simdi" DINAMIK varsayilan (151): sabit bir tarih yazilamaz,
                //   isaret kayit aninda kurulus saatiyle cozulur. Kart da ayni
                //   isareti anlar ve formu o anla acar.
                // 667: kayda yazilan "simdi" bir ANDIR (UTC); duvar saati
                //   yazmak sunucunun saat dilimine gore kayardi.
                degerler[ad] = deger as string == "@simdi" ? Saat.An : deger;

        // Kayit AKTIF SUBEYE yazilir. "subeId" yazilabilir olan kartlarda
        //   (Personel: "Çalıştığı Şube") kullanici deger yollamis olabilir - o zaman
        //   EZILMEZ, yoksa ayni fiziksel kolona iki kez deger atanip INSERT syntax
        //   hatasi verir.
        //   Eskiden kosul "SubeKolonu is null" idi: sube kolonu TANIMLI kartlarda
        //   (cek-senet, hesap...) sube HIC yazilmiyor, kolon 0 kaliyor ve
        //   sube(id) FK'si patliyordu ("Baglantili kayit bulunamadi").
        if ((tanim.SubeKolonu is not null || tanim.Alan("subeId") is not null)
            && baglam.SubeId is { } s && !degerler.ContainsKey("subeId"))
            degerler["__sube_id"] = s;

        await SlugUretAsync(baglanti, islem, tanim, degerler, null, iptal);
        await DovizHesaplaAsync(baglanti, islem, tanim, degerler, null, iptal);

        var kolonlar = new List<string>();
        var yerTutucular = new List<string>();
        var parametreler = new List<object?>();

        foreach (var (ad, deger) in degerler)
        {
            var kolon = ad == "__sube_id" ? "sube_id" : tanim.Alan(ad)?.Kolon;
            if (kolon is null) continue;
            kolonlar.Add(kolon);
            yerTutucular.Add("@p" + parametreler.Count.ToString(CultureInfo.InvariantCulture));
            parametreler.Add(deger);
        }

        kolonlar.Add("ekleyen");
        yerTutucular.Add("@p" + parametreler.Count.ToString(CultureInfo.InvariantCulture));
        parametreler.Add(baglam.KullaniciId);

        var sql = $"insert into {tanim.Tablo} ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)}) returning {tanim.IdKolonu}";

        long yeniId;
        await using (var komut = Komut(baglanti, islem, sql, parametreler))
            yeniId = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal));

        // Kod zorunlu degilse (cari/kisi) ve bos birakildiysa, ID numarasi kod olarak
        // atanir (kullanici: "kod verilmediyse ID no atasın") - bos kodla kart kalmasin.
        //
        // VERITABANI NUMARA VERDIYSE DOKUNULMAZ (396): hasta dosya numarasini
        //   taraf tetigi (tg_taraf_hasta_dosya_no) uretiyor - istekte kod bos
        //   geldigi icin burasi onun uzerine ID'yi yaziyordu ve "A/00000001"
        //   bekleyen kart "5057" ile aciliyordu. Guncelleme artik yalniz kod
        //   HALA BOSKEN calisir; gercek kod veritabanindan geri okunur.
        if (tanim.Alan("kod") is { Zorunlu: false } kodAlan &&
            string.IsNullOrWhiteSpace(degerler.TryGetValue("kod", out var kodDeger) ? kodDeger as string : null))
        {
            var kodMetni = yeniId.ToString(CultureInfo.InvariantCulture);
            await using (var kodKomut = new NpgsqlCommand(
                $"update {tanim.Tablo} set {kodAlan.Kolon} = @p0 "
                + $" where {tanim.IdKolonu} = @p1 and coalesce(btrim({kodAlan.Kolon}), '') = '' "
                + $"returning {kodAlan.Kolon}", baglanti, islem))
            {
                kodKomut.Parameters.AddWithValue("p0", kodMetni);
                kodKomut.Parameters.AddWithValue("p1", yeniId);
                var yazilan = await kodKomut.ExecuteScalarAsync(iptal) as string;
                if (yazilan is null)
                {
                    // Satir guncellenmedi = kod zaten dolu (tetik verdi): oku.
                    await using var okuKod = new NpgsqlCommand(
                        $"select {kodAlan.Kolon} from {tanim.Tablo} where {tanim.IdKolonu} = @p0",
                        baglanti, islem);
                    okuKod.Parameters.AddWithValue("p0", yeniId);
                    yazilan = await okuKod.ExecuteScalarAsync(iptal) as string;
                }
                kodMetni = yazilan ?? kodMetni;
            }
            degerler["kod"] = kodMetni;
        }

        Dictionary<string, List<Dictionary<string, string>>>? eklenenDetaylar = null;
        if (detaylar is not null)
            eklenenDetaylar = await DetayUygulaAsync(
                baglanti, islem, tanim, yeniId, detaylar, baglam, iptal, eklemeDetayLoguYaz: false);

        // Ekleme logu buyumesin: bos ve katalog varsayilani olan alanlar yazilmaz.
        var kartLogu = EklemeLogDegerleri(degerler, tanim.YeniKayitVarsayilanlari, baglam.SubeId);
        object logBilgisi = kartLogu;
        if (eklenenDetaylar is { Count: > 0 })
        {
            logBilgisi = new Dictionary<string, object?>
            {
                ["kart"] = kartLogu,
                ["detaylar"] = eklenenDetaylar
            };
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Ekle, tanim.LogTabloId, yeniId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip, logBilgisi,
            tarafId: tanim.Ad == "cari" ? (int)yeniId : null,
            stokId: tanim.Ad == "stok" ? (int)yeniId : null,
            iptal: iptal);

        await islem.CommitAsync(iptal);
        return yeniId;
    }

    // ========================================================== GUNCELLEME ====
    public async Task GuncelleAsync(KartTanimi tanim, long id, string surum,
        IDictionary<string, object?> degerler, Dictionary<string, DetayFarki>? detaylar,
        IReadOnlyList<KartAlani> okunabilirAlanlar, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var oncesi = await OkuAsync(baglanti, islem, tanim, id, okunabilirAlanlar, null, iptal)
                     ?? throw GentegreHatasi.Bulunamadi();

        // Tutar/kur/para birimi degistiyse yerel karsilik yeniden hesaplanir.
        //   Kismi guncellemede (yalniz "tutar" geldiginde) eksik degerler mevcut
        //   kayittan tamamlanir - yoksa kur 0 sayilip yerel tutar sifirlanirdi.
        await SlugUretAsync(baglanti, islem, tanim, degerler, id, iptal);
        await DovizHesaplaAsync(baglanti, islem, tanim, degerler, oncesi.Kart, iptal);

        if (degerler.Count > 0)
        {
            var atamalar = new List<string>();
            var parametreler = new List<object?>();

            foreach (var (ad, deger) in degerler)
            {
                var kolon = tanim.Alan(ad)?.Kolon;
                if (kolon is null) continue;
                atamalar.Add($"{kolon} = @p{parametreler.Count.ToString(CultureInfo.InvariantCulture)}");
                parametreler.Add(deger);
            }

            atamalar.Add($"degistiren = @p{parametreler.Count.ToString(CultureInfo.InvariantCulture)}");
            parametreler.Add(baglam.KullaniciId);

            var idSira = parametreler.Count;
            parametreler.Add(id);
            var surumSira = parametreler.Count;
            parametreler.Add(surum);

            // Esszamanlilik: satir baskasi tarafindan degistiyse xmin tutmaz -> 0 satir.
            var sql = $"update {tanim.Tablo} set {string.Join(", ", atamalar)} " +
                      $"where {tanim.IdKolonu} = @p{idSira.ToString(CultureInfo.InvariantCulture)} " +
                      $"and xmin::text = @p{surumSira.ToString(CultureInfo.InvariantCulture)}";

            int etkilenen;
            await using (var komut = Komut(baglanti, islem, sql, parametreler))
                etkilenen = await komut.ExecuteNonQueryAsync(iptal);

            if (etkilenen == 0)
            {
                await islem.RollbackAsync(iptal);
                var guncel = await OkuAsync(tanim, id, okunabilirAlanlar, null, iptal);
                if (guncel is null) throw GentegreHatasi.Bulunamadi();

                // Cakisan alanlar = kullanicinin YAZMAK ISTEDIGI degerlerden, sunucudaki
                //   guncel degerle ortusmeyenler. (Kullanicinin ekranindaki eski degeri
                //   bilmiyoruz - elimizdeki tek referans istekte gonderilen degerdir.)
                var cakisan = degerler
                    .Where(d => guncel.Value.Kart.TryGetValue(d.Key, out var g) &&
                                (g?.ToString() ?? "") != (d.Value?.ToString() ?? ""))
                    .Select(d => d.Key)
                    .ToList();

                var govde = new Dictionary<string, object?>(guncel.Value.Kart) { ["surum"] = guncel.Value.Surum };
                throw GentegreHatasi.Cakisma(govde, cakisan);
            }
        }

        if (detaylar is not null)
            await DetayUygulaAsync(baglanti, islem, tanim, id, detaylar, baglam, iptal);

        // Degisiklik logu alan bazli; hicbir alan degismediyse log satiri ACILMAZ.
        var sonrasi = await OkuAsync(baglanti, islem, tanim, id, okunabilirAlanlar, null, iptal);
        if (sonrasi is not null)
        {
            var fark = LogDeposu.Fark(oncesi.Kart, sonrasi.Value.Kart);
            if (fark is not null)
                await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, tanim.LogTabloId, id,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                    tarafId: tanim.Ad == "cari" ? (int)id : null,
                    stokId: tanim.Ad == "stok" ? (int)id : null,
                    iptal: iptal);
        }

        await islem.CommitAsync(iptal);
    }

    // =============================================================== SILME ====
    public async Task SilAsync(KartTanimi tanim, long id, IReadOnlyList<KartAlani> alanlar,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var mevcut = await OkuAsync(baglanti, islem, tanim, id, alanlar, null, iptal)
                     ?? throw GentegreHatasi.Bulunamadi();

        // Is kurali engelleri (§3.3): sebebi ve adedi ile 422.
        foreach (var engel in tanim.SilmeEngelleri ?? Array.Empty<SilmeEngeli>())
        {
            await using var sayim = baglanti.Komut(
                $"select count(*) from {engel.Tablo} where {engel.Kolon} = @p0", islem,
                id);
            var adet = Convert.ToInt64(await sayim.ExecuteScalarAsync(iptal) ?? 0L);

            if (adet > 0)
            {
                await islem.RollbackAsync(iptal);
                var tabloAdi = engel.Tablo.Replace("public.", "", StringComparison.Ordinal);
                throw GentegreHatasi.IsKurali(engel.Aciklama,
                    new SilmeEngelBilgisi(tabloAdi, adet, TabloAdlari.Coz(engel.Tablo)));
            }
        }

        // Detaylar da yedeklenir: "Geri Al" kart + detay birlikte diriltir.
        var detayYedegi = new Dictionary<string, object?>();
        foreach (var detay in tanim.Detaylar ?? Array.Empty<DetayTanimi>())
        {
            var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
            await using var komut = baglanti.Komut(
                $"select {secim} from {detay.Tablo} where {detay.UstKolon} = @p0", islem,
                id);

            var satirlar = new List<Dictionary<string, string>>();
            await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
            {
                while (await okuyucu.ReadAsync(iptal))
                {
                    var satir = new Dictionary<string, string>(StringComparer.Ordinal);
                    for (var i = 0; i < okuyucu.FieldCount; i++)
                        satir[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? "" : LogDeposu.Metin(okuyucu.GetValue(i));
                    satirlar.Add(satir);
                }
            }
            if (satirlar.Count > 0) detayYedegi[detay.Ad] = satirlar;
        }

        // SILME LOGU DELETE'TEN ONCE - satirin tam hali "Geri Al" icin saklanir.
        var yedek = mevcut.Kart.ToDictionary(d => d.Key, d => (object?)LogDeposu.Metin(d.Value));
        if (detayYedegi.Count > 0) yedek["__detaylar"] = detayYedegi;

        await _log.YazAsync(baglanti, islem, LogIslemi.Sil, tanim.LogTabloId, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip, yedek,
            tarafId: tanim.Ad == "cari" ? (int)id : null,
            stokId: tanim.Ad == "stok" ? (int)id : null,
            iptal: iptal);

        foreach (var detay in tanim.Detaylar ?? Array.Empty<DetayTanimi>())
        {
            await using var komut = baglanti.Komut(
                $"delete from {detay.Tablo} where {detay.UstKolon} = @p0", islem,
                id);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await using (var komut = new NpgsqlCommand(
            $"delete from {tanim.Tablo} where {tanim.IdKolonu} = @p0", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", id);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
    }

    private static Dictionary<string, string> EklemeLogDegerleri(
        IDictionary<string, object?> degerler,
        IReadOnlyDictionary<string, object?>? varsayilanlar = null,
        int? subeId = null)
    {
        var sonuc = new Dictionary<string, string>(StringComparer.Ordinal);

        foreach (var (alan, deger) in degerler)
        {
            if (alan == "__sube_id") continue;

            var metin = LogDeposu.Metin(deger);
            if (string.IsNullOrWhiteSpace(metin)) continue;
            if (subeId is not null && alan == "subeId" &&
                metin == subeId.Value.ToString(CultureInfo.InvariantCulture)) continue;
            if (varsayilanlar is not null &&
                varsayilanlar.TryGetValue(alan, out var varsayilan) &&
                metin == LogDeposu.Metin(varsayilan)) continue;

            sonuc[alan] = metin;
        }

        return sonuc;
    }


    private NpgsqlCommand Komut(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string sql, IReadOnlyList<object?> parametreler)
    {
        var komut = new NpgsqlCommand(sql, baglanti, islem);
        // NULL parametreler TIPLI (Parametre.Ekle) - dinamik kolon listesinde
        //   tipsiz NULL'i PG 42P08 ile reddediyor.
        Parametre.Ekle(komut, parametreler);
        return komut;
    }

    /// <summary>
    /// SlugKaynak'li alanlari (ör. rol.kod) teknik koda cevirir: kullanici
    /// "Satış Müdürü" yazsa da kayda "satis-muduru" gider. Bos birakilmissa
    /// kaynak alandan uretilir; ayni kod varsa -2, -3 eklenerek benzersizlestirilir.
    /// </summary>
    private static async Task SlugUretAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        KartTanimi tanim, IDictionary<string, object?> degerler, long? mevcutId,
        CancellationToken iptal)
    {
        foreach (var alan in tanim.Alanlar.Where(a => a.SlugKaynak is not null))
        {
            var verildi = degerler.TryGetValue(alan.Ad, out var d) ? d as string : null;
            var kaynak = verildi;
            if (string.IsNullOrWhiteSpace(kaynak))
            {
                // Bos birakildi: kaynak alandan uret. Guncellemede kaynak da
                //   gelmediyse mevcut kod korunur (alan sozlukten cikarilir).
                kaynak = degerler.TryGetValue(alan.SlugKaynak!, out var k) ? k as string : null;
                if (string.IsNullOrWhiteSpace(kaynak))
                {
                    if (mevcutId is not null) degerler.Remove(alan.Ad);
                    continue;
                }
            }

            var taban = Slug(kaynak!);
            if (taban.Length == 0) taban = "kayit";
            if (alan.EnFazlaUzunluk is { } uz && taban.Length > uz - 3)
                taban = taban[..(uz - 3)];

            var aday = taban;
            for (var n = 2; ; n++)
            {
                await using var komut = new NpgsqlCommand(
                    $"select 1 from {tanim.Tablo} where {alan.Kolon} = @p0"
                    + (mevcutId is null ? "" : $" and {tanim.IdKolonu} <> @p1"), baglanti, islem);
                komut.Parameters.AddWithValue("p0", aday);
                if (mevcutId is not null) komut.Parameters.AddWithValue("p1", mevcutId.Value);
                if (await komut.ExecuteScalarAsync(iptal) is null) break;
                aday = $"{taban}-{n.ToString(CultureInfo.InvariantCulture)}";
            }
            degerler[alan.Ad] = aday;
        }
    }

    /// <summary>Türkçe harfleri de çeviren ASCII slug: "Satış Müdürü" -> "satis-muduru".</summary>
    private static string Slug(string metin)
    {
        const string kaynak = "çğıöşüÇĞİÖŞÜ";
        const string hedef  = "cgiosucgiosu";
        var s = new System.Text.StringBuilder(metin.Length);
        foreach (var h in metin.Trim())
        {
            var i = kaynak.IndexOf(h, StringComparison.Ordinal);
            var c = i >= 0 ? hedef[i] : char.ToLowerInvariant(h);
            if (c is >= 'a' and <= 'z' or >= '0' and <= '9' or '.' or '_') s.Append(c);
            else if (s.Length > 0 && s[^1] != '-') s.Append('-');
        }
        return s.ToString().Trim('-');
    }
}
