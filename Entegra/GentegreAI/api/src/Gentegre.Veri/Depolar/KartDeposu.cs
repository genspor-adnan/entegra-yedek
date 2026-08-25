using System.Globalization;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Kart yazma islemi icin cagirandan gelen baglam (kim, hangi sube, hangi IP).</summary>
public sealed record YazmaBaglami(int KullaniciId, int? SubeId, string Ip)
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
public sealed class KartDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    public KartDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    // ============================================================== OKUMA ====
    public async Task<(IDictionary<string, object?> Kart, string Surum)?> OkuAsync(
        KartTanimi tanim, long id, IReadOnlyList<KartAlani> alanlar,
        IReadOnlyList<int>? kapsam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await OkuAsync(baglanti, null, tanim, id, alanlar, kapsam, iptal);
    }

    private async Task<(IDictionary<string, object?> Kart, string Surum)?> OkuAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, KartTanimi tanim, long id,
        IReadOnlyList<KartAlani> alanlar, IReadOnlyList<int>? kapsam, CancellationToken iptal)
    {
        var secim = string.Join(", ", alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
        var sql = new StringBuilder()
            .Append("select ").Append(secim).Append(", xmin::text as \"surum\"")
            .Append(" from ").Append(tanim.Tablo)
            .Append(" where ").Append(tanim.IdKolonu).Append(" = @p0")
            .ToString();

        if (!string.IsNullOrWhiteSpace(tanim.SabitKosul)) sql += $" and ({tanim.SabitKosul})";
        if (kapsam is { Count: > 0 } && tanim.KapsamKolonu is { } kk)
            sql += $" and {kk} = any(@p1)";

        await using var komut = new NpgsqlCommand(sql, baglanti, islem);
        komut.Parameters.AddWithValue("p0", id);
        if (kapsam is { Count: > 0 } && tanim.KapsamKolonu is not null)
            komut.Parameters.AddWithValue("p1", kapsam.ToArray());

        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        if (!await okuyucu.ReadAsync(iptal)) return null;

        var kart = new Dictionary<string, object?>(StringComparer.Ordinal);
        string surum = "";
        for (var i = 0; i < okuyucu.FieldCount; i++)
        {
            var ad = okuyucu.GetName(i);
            var deger = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
            if (ad == "surum") surum = deger?.ToString() ?? "";
            else kart[ad] = deger;
        }

        return (kart, surum);
    }

    public async Task<Dictionary<string, List<IDictionary<string, object?>>>> DetaylarAsync(
        KartTanimi tanim, long id, CancellationToken iptal = default)
    {
        var sonuc = new Dictionary<string, List<IDictionary<string, object?>>>(StringComparer.Ordinal);
        if (tanim.Detaylar is not { Count: > 0 }) return sonuc;

        await using var baglanti = await _veri.AcAsync(iptal);

        foreach (var detay in tanim.Detaylar)
        {
            var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
            var sql = $"select {secim} from {detay.Tablo} where {detay.UstKolon} = @p0 order by {detay.Sirala}";

            await using var komut = new NpgsqlCommand(sql, baglanti);
            komut.Parameters.AddWithValue("p0", id);

            var satirlar = new List<IDictionary<string, object?>>();
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal))
            {
                var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
                for (var i = 0; i < okuyucu.FieldCount; i++)
                    satir[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
                satirlar.Add(satir);
            }
            sonuc[detay.Ad] = satirlar;
        }

        return sonuc;
    }

    /// <summary>
    /// Kartta KULLANILAN kod degerlerinin adlarini cozer (API §3.1 "kodAd").
    /// Sabit listeler katalogda, digerleri kod_liste / kod_deger tablosunda.
    /// </summary>
    public async Task<Dictionary<string, IDictionary<string, string>>> KodAdAsync(
        KartTanimi tanim, IDictionary<string, object?> kart, CancellationToken iptal = default)
    {
        var sonuc = new Dictionary<string, IDictionary<string, string>>(StringComparer.Ordinal);

        foreach (var alan in tanim.Alanlar.Where(a => a.Tip == "kod"))
        {
            if (!kart.TryGetValue(alan.Ad, out var deger) || deger is null) continue;
            var anahtar = deger.ToString() ?? "";

            if (alan.SabitKodlar is { } sabit)
            {
                if (sabit.TryGetValue(anahtar, out var ad))
                    sonuc[alan.Ad] = new Dictionary<string, string> { [anahtar] = ad };
                continue;
            }

            if (alan.KodTablosu is { } tablo)
            {
                var ad3 = await _veri.TekDegerAsync<string>(
                    $"select ad from {KodTablosuDogrula(tablo)} where id = @p0 limit 1",
                    new object?[] { Convert.ToInt32(deger) }, iptal);
                if (!string.IsNullOrEmpty(ad3))
                    sonuc[alan.Ad] = new Dictionary<string, string> { [anahtar] = ad3 };
                continue;
            }

            if (alan.KodListesi is null) continue;

            var ad2 = await _veri.TekDegerAsync<string>("""
                select kd.ad from public.kod_deger kd
                  join public.kod_liste kl on kl.id = kd.liste_id
                 where kl.kod = @p0 and kd.deger = @p1
                 limit 1
                """, new object?[] { alan.KodListesi, Convert.ToInt32(deger) }, iptal);

            if (!string.IsNullOrEmpty(ad2))
                sonuc[alan.Ad] = new Dictionary<string, string> { [anahtar] = ad2 };
        }

        return sonuc;
    }

    /// <summary>
    /// KodListesi alaninin TAM secenek listesi (kod_liste/kod_deger) - kodAd yalniz
    /// kartta KULLANILAN tek degeri cozer, bu butun secilebilir listeyi doner.
    /// </summary>
    public async Task<Dictionary<string, string>> KodListesiSecenekleriAsync(
        string kodListesi, CancellationToken iptal = default)
        => (await _veri.ListeAsync("""
                select kd.deger, kd.ad from public.kod_deger kd
                  join public.kod_liste kl on kl.id = kd.liste_id
                 where kl.kod = @p0 and kd.aktif = 1
                 order by kd.sira
                """, new object?[] { kodListesi },
                r => (Deger: r.GetInt32(0), Ad: r.GetString(1)), iptal))
            .ToDictionary(x => x.Deger.ToString(CultureInfo.InvariantCulture), x => x.Ad, StringComparer.Ordinal);

    // "public.kategori" gibi kendi tablosu olan secim kaynaklari - katalogda SABIT
    //   (kullanicidan gelmez), yine de savunma amacli whitelist'e karsi dogrulanir.
    private static readonly HashSet<string> KodTablosuBeyazListe =
        new(StringComparer.Ordinal) {
            "public.kategori", "public.v_cari_lookup", "public.rol", "public.sube", "public.v_personel_lookup",
            // Kasa alt sistemi (071/074). Hepsi "id, ad, aktif" kolonlu gorunum -
            //   hizmet/masraf/proje "durum" kullandigi icin gorunumle uyarlandi.
            "public.v_hesap_lookup", "public.v_proje_lookup", "public.v_hesap_plani_lookup",
            "public.v_masraf_lookup", "public.v_hizmet_lookup", "public.v_masraf_merkezi_lookup",
            // Banka tanimlari (109) - cek/senet ve hesap kartlarindaki secim.
            "public.v_banka_lookup", "public.v_banka_sube_lookup",
            // ÜTS mensei ulkesi (119), firsat urun satirinda stok secimi (121).
            "public.v_ulke_lookup", "public.v_stok_lookup",
        };

    private static string KodTablosuDogrula(string tablo)
        => KodTablosuBeyazListe.Contains(tablo)
            ? tablo
            : throw new InvalidOperationException($"Bilinmeyen kod tablosu: {tablo}");

    /// <summary>
    /// KodTablosu alaninin TAM secenek listesi (form dropdown'u icin - kodAd yalniz
    /// kartta KULLANILAN tek degeri cozer, bu ise butun secilebilir listeyi doner).
    /// </summary>
    public async Task<Dictionary<string, string>> KodTablosuSecenekleriAsync(
        string tablo, CancellationToken iptal = default)
        => (await _veri.ListeAsync(
                $"select id, ad from {KodTablosuDogrula(tablo)} where aktif = 1 order by ad",
                null, r => (Id: r.GetInt32(0), Ad: r.GetString(1)), iptal))
            .ToDictionary(x => x.Id.ToString(CultureInfo.InvariantCulture), x => x.Ad, StringComparer.Ordinal);

    /// <summary>Yerel para birimi (ayar genel.yerel_para) - kart metasina eklenir.</summary>
    public async Task<string> YerelParaAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await AyarDeposu.MetinAsync(baglanti, null, "genel.yerel_para", "TL", iptal);
    }

    /// <summary>
    /// DOVIZ UCGENI (katalogdaki DovizKurali): kur ve yerel karsilik SUNUCUDA
    /// belirlenir.
    ///
    ///  - Yerel para (genel.yerel_para) secildiyse kur 1'e sabitlenir: "TL kayit,
    ///    kur 41" gibi bir sey olusamaz.
    ///  - Yabanci para ve kur bos/sifirsa kur 1 kabul edilir; kuru DOLDURMAK
    ///    arayuzun isi (tarih kurunu cagirir), sunucu yalniz tutarliligi korur.
    ///  - Yerel tutar = tutar x kur, her zaman yeniden hesaplanir - istemciden
    ///    gelen yerel tutara guvenilmez (API §3.2).
    ///
    /// Kismi guncellemede eksik degerler mevcut kayittan tamamlanir.
    /// </summary>
    private static async Task DovizHesaplaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, KartTanimi tanim,
        IDictionary<string, object?> degerler, IDictionary<string, object?>? mevcut,
        CancellationToken iptal)
    {
        if (tanim.Doviz is not { } d) return;

        // Guncellemede ucgenin hicbir alani gelmediyse dokunma (baska bir alan
        //   degistiriliyor demektir; kur/tutar aynen kalir).
        if (mevcut is not null &&
            !degerler.ContainsKey(d.CinsAlani) &&
            !degerler.ContainsKey(d.KurAlani) &&
            !degerler.ContainsKey(d.TutarAlani)) return;

        object? Al(string ad)
            => degerler.TryGetValue(ad, out var v) && v is not null ? v
             : mevcut is not null && mevcut.TryGetValue(ad, out var m) ? m : null;

        var yerelPara = await AyarDeposu.MetinAsync(baglanti, islem, "genel.yerel_para", "TL", iptal);
        var cins = Al(d.CinsAlani)?.ToString() ?? "";
        var kur = Ondalik(Al(d.KurAlani));

        if (cins.Length == 0 || string.Equals(cins, yerelPara, StringComparison.OrdinalIgnoreCase) || kur <= 0)
            kur = 1m;

        if (tanim.Alan(d.KurAlani) is not null) degerler[d.KurAlani] = kur;
        if (tanim.Alan(d.YerelAlani) is not null)
            degerler[d.YerelAlani] = decimal.Round(Ondalik(Al(d.TutarAlani)) * kur, 4);
    }

    private static decimal Ondalik(object? deger) => deger switch
    {
        null => 0m,
        decimal d => d,
        string s when decimal.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var p) => p,
        IConvertible c => Convert.ToDecimal(c, CultureInfo.InvariantCulture),
        _ => 0m
    };

    /// <summary>
    /// BAGLI secim listesinin ust bagi: secenek id -> ust id (or. sube -> banka).
    /// Gorunumun <c>ust_id</c> kolonu vardir; arayuz seceneklerini buna gore suzer.
    /// Ust'u bos olan satir hic donmez - suzulemeyecegi icin listede de yeri yok.
    /// </summary>
    public async Task<Dictionary<string, string>> KodTablosuUstAsync(
        string tablo, CancellationToken iptal = default)
        => (await _veri.ListeAsync(
                $"select id, ust_id from {KodTablosuDogrula(tablo)} where aktif = 1 and ust_id is not null",
                null, r => (Id: r.GetInt32(0), Ust: r.GetInt32(1)), iptal))
            .ToDictionary(x => x.Id.ToString(CultureInfo.InvariantCulture),
                          x => x.Ust.ToString(CultureInfo.InvariantCulture), StringComparer.Ordinal);

    // ============================================================== EKLEME ====
    public async Task<long> EkleAsync(KartTanimi tanim, IDictionary<string, object?> degerler,
        Dictionary<string, DetayFarki>? detaylar, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        foreach (var (ad, deger) in tanim.YeniKayitVarsayilanlari ?? new Dictionary<string, object?>())
            if (!degerler.ContainsKey(ad)) degerler[ad] = deger;

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
        if (tanim.Alan("kod") is { Zorunlu: false } kodAlan &&
            string.IsNullOrWhiteSpace(degerler.TryGetValue("kod", out var kodDeger) ? kodDeger as string : null))
        {
            var kodMetni = yeniId.ToString(CultureInfo.InvariantCulture);
            await using (var kodKomut = new NpgsqlCommand(
                $"update {tanim.Tablo} set {kodAlan.Kolon} = @p0 where {tanim.IdKolonu} = @p1", baglanti, islem))
            {
                kodKomut.Parameters.AddWithValue("p0", kodMetni);
                kodKomut.Parameters.AddWithValue("p1", yeniId);
                await kodKomut.ExecuteNonQueryAsync(iptal);
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
            await using var sayim = new NpgsqlCommand(
                $"select count(*) from {engel.Tablo} where {engel.Kolon} = @p0", baglanti, islem);
            sayim.Parameters.AddWithValue("p0", id);
            var adet = Convert.ToInt64(await sayim.ExecuteScalarAsync(iptal) ?? 0L);

            if (adet > 0)
            {
                await islem.RollbackAsync(iptal);
                var tabloAdi = engel.Tablo.Replace("public.", "", StringComparison.Ordinal);
                throw GentegreHatasi.IsKurali(engel.Aciklama,
                    new SilmeEngelBilgisi(tabloAdi, adet));
            }
        }

        // Detaylar da yedeklenir: "Geri Al" kart + detay birlikte diriltir.
        var detayYedegi = new Dictionary<string, object?>();
        foreach (var detay in tanim.Detaylar ?? Array.Empty<DetayTanimi>())
        {
            var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
            await using var komut = new NpgsqlCommand(
                $"select {secim} from {detay.Tablo} where {detay.UstKolon} = @p0", baglanti, islem);
            komut.Parameters.AddWithValue("p0", id);

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
            await using var komut = new NpgsqlCommand(
                $"delete from {detay.Tablo} where {detay.UstKolon} = @p0", baglanti, islem);
            komut.Parameters.AddWithValue("p0", id);
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

    // ========================================================== detay farki ====
    private async Task<Dictionary<string, List<Dictionary<string, string>>>> DetayUygulaAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        KartTanimi tanim, long ustId, Dictionary<string, DetayFarki> farklar,
        YazmaBaglami baglam, CancellationToken iptal, bool eklemeDetayLoguYaz = true)
    {
        var eklenenLoglari = new Dictionary<string, List<Dictionary<string, string>>>(StringComparer.Ordinal);

        foreach (var (ad, fark) in farklar)
        {
            var detay = tanim.Detay(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen detay: {ad}",
                       new AlanHatasi(ad, "Bu kartta boyle bir detay yok."));

            foreach (var satir in fark.Eklenen ?? new List<Dictionary<string, JsonElement>>())
            {
                var degerler = DetayDegerleri(detay, satir, yeni: true);
                var kolonlar = new List<string> { detay.UstKolon, "ekleyen" };
                var parametreler = new List<object?> { ustId, baglam.KullaniciId };

                // 019'da sube_id kolonlari NOT NULL yapildi: detay satiri oturumun subesine yazilir.
                if (detay.SubeKolonu is { } detaySube)
                {
                    kolonlar.Add(detaySube);
                    parametreler.Add(baglam.SubeId);
                }

                foreach (var (alanAdi, deger) in degerler)
                {
                    kolonlar.Add(detay.Alanlar.First(a => a.Ad == alanAdi).Kolon);
                    parametreler.Add(deger);
                }

                var yerTutucular = Enumerable.Range(0, parametreler.Count)
                    .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));

                var sql = $"insert into {detay.Tablo} ({string.Join(", ", kolonlar)}) " +
                          $"values ({string.Join(", ", yerTutucular)}) returning {detay.IdKolonu}";

                long detayId;
                await using (var komut = Komut(baglanti, islem, sql, parametreler))
                    detayId = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal));

                var logDegerleri = EklemeLogDegerleri(degerler);
                if (logDegerleri.Count > 0)
                    logDegerleri["id"] = detayId.ToString(CultureInfo.InvariantCulture);

                if (logDegerleri.Count > 0)
                {
                    if (!eklenenLoglari.TryGetValue(ad, out var detayListesi))
                        eklenenLoglari[ad] = detayListesi = new List<Dictionary<string, string>>();
                    detayListesi.Add(logDegerleri);
                }

                if (eklemeDetayLoguYaz && logDegerleri.Count > 0)
                    await DetayLogAsync(baglanti, islem, tanim, detay, LogIslemi.Ekle, detayId, ustId,
                        logDegerleri, baglam, iptal);
            }

            foreach (var satir in fark.Degisen ?? new List<Dictionary<string, JsonElement>>())
            {
                if (!satir.TryGetValue("id", out var idElemani) || !idElemani.TryGetInt64(out var satirId))
                    throw GentegreHatasi.Dogrulama($"{ad}: degisen satirda id yok.",
                        new AlanHatasi(ad, "Degisen detay satiri id tasimali."));

                var degerler = DetayDegerleri(detay, satir, yeni: false);
                if (degerler.Count == 0) continue;

                var atamalar = new List<string>();
                var parametreler = new List<object?>();

                foreach (var (alanAdi, deger) in degerler)
                {
                    var kolon = detay.Alanlar.First(a => a.Ad == alanAdi).Kolon;
                    atamalar.Add($"{kolon} = @p{parametreler.Count.ToString(CultureInfo.InvariantCulture)}");
                    parametreler.Add(deger);
                }

                atamalar.Add($"degistiren = @p{parametreler.Count.ToString(CultureInfo.InvariantCulture)}");
                parametreler.Add(baglam.KullaniciId);

                var idSira = parametreler.Count;
                parametreler.Add(satirId);
                var ustSira = parametreler.Count;
                parametreler.Add(ustId);

                // Ust kayit kontrolu: baska karta ait satir guncellenemez.
                var sql = $"update {detay.Tablo} set {string.Join(", ", atamalar)} " +
                          $"where {detay.IdKolonu} = @p{idSira.ToString(CultureInfo.InvariantCulture)} " +
                          $"and {detay.UstKolon} = @p{ustSira.ToString(CultureInfo.InvariantCulture)}";

                await using (var komut = Komut(baglanti, islem, sql, parametreler))
                    if (await komut.ExecuteNonQueryAsync(iptal) == 0)
                        throw GentegreHatasi.Bulunamadi($"{ad}: {satirId} nolu satir bu kartta yok.");

                await DetayLogAsync(baglanti, islem, tanim, detay, LogIslemi.Degistir, satirId, ustId,
                    degerler.ToDictionary(d => d.Key, d => LogDeposu.Metin(d.Value)), baglam, iptal);
            }

            foreach (var satirId in fark.Silinen ?? new List<long>())
            {
                // Silme logu DELETE'ten ONCE: satirin tam hali saklanir ("Geri Al").
                var yedek = new Dictionary<string, string>(StringComparer.Ordinal);
                var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
                await using (var oku = new NpgsqlCommand(
                    $"select {secim} from {detay.Tablo} where {detay.IdKolonu} = @p0 and {detay.UstKolon} = @p1",
                    baglanti, islem))
                {
                    oku.Parameters.AddWithValue("p0", satirId);
                    oku.Parameters.AddWithValue("p1", ustId);
                    await using var okuyucu = await oku.ExecuteReaderAsync(iptal);
                    if (await okuyucu.ReadAsync(iptal))
                        for (var i = 0; i < okuyucu.FieldCount; i++)
                            yedek[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? "" : LogDeposu.Metin(okuyucu.GetValue(i));
                }

                if (yedek.Count > 0)
                    await DetayLogAsync(baglanti, islem, tanim, detay, LogIslemi.Sil, satirId, ustId,
                        yedek, baglam, iptal);

                await using var komut = new NpgsqlCommand(
                    $"delete from {detay.Tablo} where {detay.IdKolonu} = @p0 and {detay.UstKolon} = @p1",
                    baglanti, islem);
                komut.Parameters.AddWithValue("p0", satirId);
                komut.Parameters.AddWithValue("p1", ustId);
                await komut.ExecuteNonQueryAsync(iptal);
            }
        }

        return eklenenLoglari;
    }

    /// <summary>
    /// Detay satiri logu. Kart logundan ayri satir acilir ama ust_tablo_id /
    /// ust_kayit_id ile karta baglanir - UInfo ekrani kart gecmisinde birlikte gosterir.
    /// </summary>
    private async Task DetayLogAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        KartTanimi tanim, DetayTanimi detay, short islemTipi, long detayId, long ustId,
        Dictionary<string, string> bilgi, YazmaBaglami baglam, CancellationToken iptal)
        => await _log.YazAsync(baglanti, islem, islemTipi,
            detay.LogTabloId == 0 ? tanim.LogTabloId : detay.LogTabloId,
            detayId, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi,
            ustTabloId: tanim.LogTabloId, ustKayitId: ustId,
            tarafId: tanim.Ad == "cari" ? (int)ustId : null,
            stokId: tanim.Ad == "stok" ? (int)ustId : null,
            iptal: iptal);

    private static Dictionary<string, object?> DetayDegerleri(DetayTanimi detay,
        Dictionary<string, JsonElement> gelen, bool yeni)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);

        foreach (var (ad, deger) in gelen)
        {
            if (ad == "id") continue;

            var alan = detay.Alanlar.FirstOrDefault(a => a.Ad == ad)
                ?? throw GentegreHatasi.Dogrulama($"{detay.Ad}: bilinmeyen alan {ad}",
                       new AlanHatasi($"{detay.Ad}.{ad}", "Bu detayda boyle bir alan yok."));

            if (!alan.Yazilabilir) continue;

            var cevrilmis = DegerCevirici.Cevir(deger, alan.Tip, $"{detay.Ad}.{ad}", ad);
            DegerCevirici.UzunlukKontrol(alan, cevrilmis, $"{detay.Ad}.{ad}");
            sonuc[ad] = cevrilmis;
        }

        if (yeni)
            foreach (var zorunlu in detay.Alanlar.Where(a => a.Zorunlu))
                if (!sonuc.TryGetValue(zorunlu.Ad, out var d) || d is null ||
                    (d is string m && m.Length == 0))
                    throw GentegreHatasi.Dogrulama($"{detay.Ad}: {zorunlu.Etiket} zorunlu.",
                        new AlanHatasi($"{detay.Ad}.{zorunlu.Ad}", $"{zorunlu.Etiket} boş bırakılamaz."));

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
}
