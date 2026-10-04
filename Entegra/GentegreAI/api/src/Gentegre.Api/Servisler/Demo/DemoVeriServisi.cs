using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler.Demo;

/// <summary>Demo verisi ayarı (referans `demo.ayar`, json).</summary>
public sealed record DemoAyar(string Profil, string KurumAdi, string Sehir, int Tohum, string Olcek, string[] Moduller)
{
    public static readonly DemoAyar Varsayilan = new("hastane", "Örnek Şehir Hastanesi", "İstanbul / Kadıköy", 2611, "orta",
        ["yapi", "personel", "hasta", "randevu", "ik", "kullanici"]);
    public bool Var(string modul) => Moduller.Contains(modul, StringComparer.Ordinal);
}

/// <summary>Ölçek hazır ayarı: kaç kişi, kaç randevu, hangi tarih aralığı.</summary>
public sealed record DemoOlcek(int Personel, int Hasta, int Randevu, int GunGeri, int GunIleri)
{
    public static DemoOlcek Al(string ad) => ad switch
    {
        "kucuk" => new(30, 100, 400, 30, 7),
        "buyuk" => new(150, 800, 4000, 90, 30),
        _ => new(85, 300, 1400, 90, 14),
    };
}

/// <summary>
/// DEMO VERİSİ ÜRETİCİSİ (964, mockup Ekranlar/Ayarlar/demo_tohum.html).
///
/// YALNIZ `kurulum.demo = 1` kurulumda çalışır; kontrol her girişte yeniden
/// yapılır (uç da, gece işi de buradan geçer). Aynı tohum aynı veriyi üretir:
/// rastgelelik tek bir <see cref="Random"/>(tohum) dizisinden gelir, tarihler
/// BUGÜNE göre kurulur - tanıtım hangi gün yapılırsa "bugünün randevuları" dolu.
///
/// Üretilen her satır `demo_kayit`a yazılır; temizlik yalnız onlara ve demo
/// kişilere bağlı bilinen tablolara (randevu, İK talepleri, kullanıcı, kadro
/// hareketi) dokunur. Başka kayda bağlanmış demo kişi (ziyaretçinin açtığı
/// belge gibi) SİLİNMEZ, sayısı raporlanır.
///
/// Bütün kişiler kurgusal: TC kimlik 99'la başlayan, algoritmaya uyan ama
/// kimseye ait olmayan numara; telefon 0500 000 xx xx; e-posta @ornek.test.
/// </summary>
public sealed class DemoVeriServisi(VeriKaynagi veri, ILogger<DemoVeriServisi> gunluk)
{
    public const string DemoParola = "Demo!2026";
    private static readonly TimeSpan Istanbul = TimeSpan.FromHours(3);

    /// <summary>Demo kullanıcıları: rol kodu → kullanıcı kodu, rol başlığı, açılış ekranı.</summary>
    public static readonly (string Rol, string Kod, string Baslik, string Acilis)[] Kullanicilar =
    [
        ("bashekim", "demo.bashekim", "Başhekim", "Yönetim panosu"),
        ("hekim", "demo.hekim", "Poliklinik hekimi", "Muayene kuyruğu"),
        ("hemsire", "demo.hemsire", "Hemşire", "Servis"),
        ("kayit_kabul", "demo.kayit", "Kayıt kabul", "Randevular · bugün"),
        ("lab_uzmani", "demo.lab", "Laboratuvar", "Numune kabul + sonuç onay"),
        ("eczaci", "demo.eczane", "Eczane", "İlaç talepleri"),
        ("erp_ik", "demo.ik", "İK", "Personel listesi"),
    ];

    // ------------------------------------------------------------ ayar ----
    public async Task<bool> DemoMuAsync(CancellationToken iptal)
    {
        var d = await veri.TekDegerAsync<string?>(
            "select deger from public.referans where anahtar = 'kurulum.demo'", null, iptal);
        return d?.Trim() == "1";
    }

    public async Task DemoIsteAsync(CancellationToken iptal)
    {
        if (!await DemoMuAsync(iptal))
            throw GentegreHatasi.Yasak("Bu kurulum DEMO değil - demo verisi üretilemez / silinemez.");
    }

    public async Task<DemoAyar> AyarOkuAsync(CancellationToken iptal)
    {
        var j = await veri.TekDegerAsync<string?>(
            "select deger from public.referans where anahtar = 'demo.ayar'", null, iptal);
        if (string.IsNullOrWhiteSpace(j)) return DemoAyar.Varsayilan;
        try
        {
            return JsonSerializer.Deserialize<DemoAyar>(j, JsonOpt) ?? DemoAyar.Varsayilan;
        }
        catch (JsonException) { return DemoAyar.Varsayilan; }
    }

    public async Task AyarYazAsync(DemoAyar ayar, CancellationToken iptal)
    {
        var j = JsonSerializer.Serialize(ayar, JsonOpt);
        await veri.CalistirAsync("update public.referans set deger = @p0 where anahtar = 'demo.ayar'", [j], iptal);
    }

    private static readonly JsonSerializerOptions JsonOpt = new(JsonSerializerDefaults.Web);

    // -------------------------------------------------------- çalıştır ----
    /// <summary>
    /// Üretim kaydını açar (durum 0). Çalışan bir üretim varsa (30 dk içinde
    /// başlamış) yenisini açmaz - aynı anda iki üretim aynı kişileri iki kez yazardı.
    /// </summary>
    public async Task<int> UretimAcAsync(string tetik, int? kullaniciId, int tohum, CancellationToken iptal)
    {
        var calisan = await veri.TekDegerAsync<int?>("""
            select id from public.demo_uretim
             where durum = 0 and baslangic > now() - interval '30 minutes' order by id desc limit 1
            """, null, iptal);
        if (calisan is not null) throw GentegreHatasi.IsKurali("Bir demo üretimi zaten çalışıyor.");
        return await veri.TekDegerAsync<int>(
            "insert into public.demo_uretim (tetik, tohum, ekleyen, adim) values (@p0, @p1, @p2, 'Başlıyor') returning id",
            [tetik, tohum, kullaniciId], iptal);
    }

    /// <summary>Temizle + üret. Her adım ayrı işlemde; ilerleme demo_uretim'e yazılır.</summary>
    public async Task CalistirAsync(int uretimId, bool uret, CancellationToken iptal)
    {
        var ozet = new Dictionary<string, object>();
        try
        {
            await DemoIsteAsync(iptal);
            var ayar = await AyarOkuAsync(iptal);

            await AdimAsync(uretimId, "Demo verisi temizleniyor", ozet, iptal);
            var (silinen, kalan) = await TemizleAsync(iptal);
            ozet["silinen"] = silinen;
            if (kalan > 0) ozet["baglidanKalan"] = kalan;
            if (!uret) { await BitirAsync(uretimId, ozet, null, iptal); return; }

            var r = new Random(ayar.Tohum);
            var olcek = DemoOlcek.Al(ayar.Olcek);
            var bugun = DateOnly.FromDateTime(DateTime.UtcNow + Istanbul);
            await using var b = await veri.AcAsync(iptal);
            var ctx = await BaglamKurAsync(b, ayar, iptal);

            // KURUM ADI ANTETTE: yazılar ve ekran başlıkları demo kurumunu göstersin.
            if (ayar.Var("yapi") && !string.IsNullOrWhiteSpace(ayar.KurumAdi))
                await b.CalistirAsync("update public.sube set unvan = @p1 where id = @p0", null,
                    [ctx.SubeId, ayar.KurumAdi], iptal);

            if (ayar.Var("personel"))
            {
                await AdimAsync(uretimId, "Personel", ozet, iptal);
                ozet["personel"] = await PersonelUretAsync(b, ctx, r, olcek, bugun, iptal);
            }
            if (ayar.Var("kullanici") && ctx.Personel.Count > 0)
            {
                await AdimAsync(uretimId, "Demo kullanıcıları", ozet, iptal);
                ozet["kullanici"] = await KullaniciUretAsync(b, ctx, iptal);
            }
            if (ayar.Var("hasta"))
            {
                await AdimAsync(uretimId, "Hasta", ozet, iptal);
                ozet["hasta"] = await HastaUretAsync(b, ctx, r, olcek, bugun, iptal);
            }
            if (ayar.Var("randevu") && ctx.Hastalar.Count > 0 && ctx.Hekimler.Count > 0)
            {
                await AdimAsync(uretimId, "Randevu", ozet, iptal);
                ozet["randevu"] = await RandevuUretAsync(b, ctx, r, olcek, bugun, iptal);
            }
            if (ayar.Var("ik") && ctx.Personel.Count > 0)
            {
                await AdimAsync(uretimId, "İK talepleri", ozet, iptal);
                ozet["ik"] = await IkUretAsync(b, ctx, r, bugun, iptal);
            }
            await BitirAsync(uretimId, ozet, null, iptal);
        }
        catch (Exception h)
        {
            gunluk.LogError(h, "Demo üretimi #{Id} hata verdi.", uretimId);
            await BitirAsync(uretimId, ozet, h.Message, CancellationToken.None);
        }
    }

    private Task AdimAsync(int id, string adim, Dictionary<string, object> ozet, CancellationToken iptal) =>
        veri.CalistirAsync("update public.demo_uretim set adim = @p1, ozet = @p2::jsonb where id = @p0",
            [id, adim, JsonSerializer.Serialize(ozet)], iptal);

    private Task BitirAsync(int id, Dictionary<string, object> ozet, string? hata, CancellationToken iptal) =>
        veri.CalistirAsync("""
            update public.demo_uretim set durum = @p1, bitis = now(), ozet = @p2::jsonb, hata = @p3,
                   adim = case when @p1 = 1 then 'Tamamlandı' else 'Hata' end
             where id = @p0
            """, [id, hata is null ? (short)1 : (short)2, JsonSerializer.Serialize(ozet),
                  hata is null ? null : hata[..Math.Min(hata.Length, 1000)]], iptal);

    // --------------------------------------------------------- temizle ----
    /// <summary>
    /// Demo kayıtlarını ve demo kişilere bağlı bilinen kayıtları siler. Başka
    /// bir kayda bağlı kalan demo kişi atlanır (savepoint) - sayısı döner.
    /// </summary>
    public async Task<(int Silinen, int Kalan)> TemizleAsync(CancellationToken iptal)
    {
        await DemoIsteAsync(iptal);
        await using var b = await veri.AcAsync(iptal);
        await using var islem = await b.BeginTransactionAsync(iptal);
        var kisiler = (await b.ListeAsync("select kayit_id from public.demo_kayit where tablo = 'taraf'", islem, [],
            o => (int)o.GetInt64(0), iptal)).ToArray();
        var silinen = 0;
        async Task Sil(string sql, params object?[] p) => silinen += await b.CalistirAsync(sql, islem, p, iptal);

        // Kişiye bağlı bilinen tablolar - ziyaretçinin demo kişiyle açtığı randevu / talep de gider.
        await Sil("delete from public.randevu where hasta_id = any(@p0) or hekim_id = any(@p0) " +
                  "or id in (select kayit_id from public.demo_kayit where tablo = 'randevu')", kisiler);
        await Sil("delete from public.personel_masraf_satir where beyan_id in (select id from public.personel_masraf where taraf_id = any(@p0))", kisiler);
        foreach (var t in new[] { "personel_masraf", "personel_avans", "personel_belge_talep", "personel_izin", "personel_egitim",
                                  "bildirim", "taraf_cihaz", "taraf_hasta_kurum" })
        {
            var kolon = t == "taraf_hasta_kurum" ? "hasta_id" : "taraf_id";
            await Sil($"delete from public.{t} where {kolon} = any(@p0)", kisiler);
        }
        await Sil("delete from public.personel_hareket where taraf_id = any(@p0) or yonetici_taraf_id = any(@p0)", kisiler);
        await Sil("update public.taraf_personel set yonetici_taraf_id = null where yonetici_taraf_id = any(@p0)", kisiler);
        await Sil("delete from public.kullanici_arama where kullanici_id = any(@p0)", kisiler);
        await Sil("delete from public.kullanici_katalog where kullanici_id = any(@p0)", kisiler);
        await Sil("delete from public.taraf_kullanici where id = any(@p0)", kisiler);
        // ÖZLÜK ÖNCE, HAREKET SONRA: özlük silinince kadro tetiği "çıkış" hareketi
        //   yazar ve silinecek kişiyi referanslar - o yüzden hareketler özlükten
        //   SONRA bir kez daha temizlenir.
        await Sil("delete from public.taraf_personel where id = any(@p0)", kisiler);
        await Sil("delete from public.personel_hareket where taraf_id = any(@p0) or yonetici_taraf_id = any(@p0)", kisiler);

        // Kişiler tek tek: başka kayda bağlıysa (ziyaretçinin belgesi) atlanır.
        var kalan = new List<int>();
        foreach (var id in kisiler)
        {
            await islem.SaveAsync("kisi", iptal);
            try
            {
                silinen += await b.CalistirAsync("delete from public.taraf where id = @p0", islem, [id], iptal);
                await islem.ReleaseAsync("kisi", iptal);
            }
            catch (PostgresException h)
            {
                await islem.RollbackAsync("kisi", iptal);
                if (kalan.Count == 0) gunluk.LogWarning("Demo temizlik: kişi #{Id} silinemedi: {Hata}", id, h.MessageText + " " + h.Detail);
                kalan.Add(id);
            }
        }
        await b.CalistirAsync("delete from public.demo_kayit where not (tablo = 'taraf' and kayit_id = any(@p0))", islem,
            [kalan.Select(x => (long)x).ToArray()], iptal);
        await islem.CommitAsync(iptal);
        return (silinen, kalan.Count);
    }

    // ---------------------------------------------------------- bağlam ----
    private sealed class Baglam
    {
        public int SubeId;
        public Dictionary<string, int> Rol = new();
        public Dictionary<string, int> Gorev = new();
        public Dictionary<string, int> Bolum = new();          // ad → id
        public List<int> KlinikBolumler = new();
        public HashSet<string> MevcutTc = new();
        public HashSet<string> MevcutKod = new();
        public HashSet<string> MevcutSicil = new();
        public HashSet<string> MevcutCep = new();
        public int TelSayac;
        public List<(int Id, string Rol, int Bolum, string Ad)> Personel = new();
        public List<(int Id, int Bolum)> Hekimler = new();
        public List<int> Hastalar = new();
        public int? SenaryoHasta;
        public List<(string Tablo, long Id)> Kayit = new();
        public int TcSayac;
    }

    private static async Task<Baglam> BaglamKurAsync(NpgsqlConnection b, DemoAyar ayar, CancellationToken iptal)
    {
        var c = new Baglam
        {
            SubeId = await b.TekDegerAsync<int>("select min(id) from public.sube", null, [], iptal)
        };
        foreach (var r in await b.ListeAsync("select kod, id from public.rol", null, [], o => (o.GetString(0), o.GetInt32(1)), iptal))
            c.Rol[r.Item1] = r.Item2;
        foreach (var r in await b.ListeAsync("select ad, id from public.personel_gorev", null, [], o => (o.GetString(0), o.GetInt32(1)), iptal))
            c.Gorev.TryAdd(r.Item1, r.Item2);
        foreach (var r in await b.ListeAsync("""
            select d.ad, d.id, coalesce(u.ad, '') from public.departman d
              left join public.departman u on u.id = d.ustbirim_id
             where d.durum = 1 order by d.sira, d.ad
            """, null, [], o => (o.GetString(0), (int)o.GetInt16(1), o.GetString(2)), iptal))
        {
            c.Bolum.TryAdd(r.Item1, r.Item2);
            if (r.Item3 is "Dahili Bilimler" or "Cerrahi Bilimler" && r.Item1 != "Patoloji") c.KlinikBolumler.Add(r.Item2);
        }
        if (c.KlinikBolumler.Count == 0) c.KlinikBolumler.AddRange(c.Bolum.Values.Take(8));
        // Klinik sırası: tanıtımda en çok sorulan poliklinikler önce.
        var once = new[] { "İç Hastalıkları", "Çocuk Sağlığı ve Hastalıkları", "Kadın Hastalıkları ve Doğum", "Genel Cerrahi",
                           "Kardiyoloji", "Ortopedi ve Travmatoloji", "Göz Hastalıkları", "Kulak Burun Boğaz KBB",
                           "Nöroloji", "Üroloji", "Deri ve Zührevi Hastalıklar", "Göğüs Hastalıkları" };
        c.KlinikBolumler = once.Where(c.Bolum.ContainsKey).Select(x => c.Bolum[x])
            .Concat(c.KlinikBolumler).Distinct().ToList();
        foreach (var v in await b.ListeAsync("select coalesce(vkno, '') from public.taraf where vkno like '99%'", null, [],
                     o => o.GetString(0), iptal)) c.MevcutTc.Add(v);
        foreach (var v in await b.ListeAsync("select kod from public.taraf_kullanici", null, [], o => o.GetString(0), iptal))
            c.MevcutKod.Add(v);
        // Personel cep telefonu BENZERSİZ (ux_taraf_personel_cep): demo numaraları sayaçla verilir, mevcutla çakışmaz.
        foreach (var v in await b.ListeAsync(
                     "select right(regexp_replace(cep_tel, '[^0-9]', '', 'g'), 10) from public.taraf where personel = 1 and coalesce(cep_tel, '') <> ''",
                     null, [], o => o.GetString(0), iptal)) c.MevcutCep.Add(v);
        c.TelSayac = ayar.Tohum % 5000;
        // Silinemeyip kalan eski demo kişinin sicili yeniden verilmez.
        foreach (var v in await b.ListeAsync("select kod from public.taraf where kod like 'DM%'", null, [], o => o.GetString(0), iptal))
            c.MevcutSicil.Add(v);
        return c;
    }

    private static int? BolumAra(Baglam c, params string[] adlar)
    {
        foreach (var a in adlar) if (c.Bolum.TryGetValue(a, out var id)) return id;
        return null;
    }

    private static int? GorevAra(Baglam c, params string[] adlar)
    {
        foreach (var a in adlar) if (c.Gorev.TryGetValue(a, out var id)) return id;
        return null;
    }

    /// <summary>Kurgusal ama algoritmaya uyan TC: 99 ile başlar, mevcutla çakışmaz.</summary>
    private static string Tc(Baglam c)
    {
        while (true)
        {
            var govde = "99" + (1000000 + c.TcSayac++ * 7919 % 9000000).ToString("D7", CultureInfo.InvariantCulture);
            var d = govde.Select(ch => ch - '0').ToArray();
            var on = ((d[0] + d[2] + d[4] + d[6] + d[8]) * 7 - (d[1] + d[3] + d[5] + d[7])) % 10;
            if (on < 0) on += 10;
            var onbir = (d.Sum() + on) % 10;
            var tc = govde + on.ToString(CultureInfo.InvariantCulture) + onbir.ToString(CultureInfo.InvariantCulture);
            if (c.MevcutTc.Add(tc)) return tc;
        }
    }

    /// <summary>Benzersiz demo cep: 0500 000 xx xx, sayaçla.</summary>
    private static string Cep(Baglam c)
    {
        while (true)
        {
            var n = (c.TelSayac++ % 10000).ToString("D4", CultureInfo.InvariantCulture);
            if (c.MevcutCep.Add("500000" + n)) return $"0500 000 {n[..2]} {n[2..]}";
        }
    }

    private static string Telefon(Random r) =>
        $"0500 000 {r.Next(10, 99).ToString(CultureInfo.InvariantCulture)} {r.Next(10, 99).ToString(CultureInfo.InvariantCulture)}";

    private static string Eposta(string ad, string soyad, int n) =>
        $"{Ascii(ad)}.{Ascii(soyad)}{n.ToString(CultureInfo.InvariantCulture)}@ornek.test";

    private static string Ascii(string s) => new string(s.ToLowerInvariant()
        .Replace('ç', 'c').Replace('ğ', 'g').Replace('ı', 'i').Replace('ö', 'o').Replace('ş', 's').Replace('ü', 'u')
        .Where(char.IsLetterOrDigit).ToArray());

    private static async Task KayitYazAsync(NpgsqlConnection b, NpgsqlTransaction islem, Baglam c, CancellationToken iptal)
    {
        if (c.Kayit.Count == 0) return;
        await b.CalistirAsync("""
            insert into public.demo_kayit (tablo, kayit_id)
            select unnest(@p0::varchar[]), unnest(@p1::bigint[])
            """, islem, [c.Kayit.Select(k => k.Tablo).ToArray(), c.Kayit.Select(k => k.Id).ToArray()], iptal);
        c.Kayit.Clear();
    }

    // -------------------------------------------------------- personel ----
    private static async Task<int> PersonelUretAsync(NpgsqlConnection b, Baglam c, Random r, DemoOlcek o, DateOnly bugun,
        CancellationToken iptal)
    {
        // Kadro dağılımı (orta: 85). Oranlar hastane kadrosuna yakın.
        var n = o.Personel;
        var plan = new List<(string Rol, string[] Gorev, int? Bolum, int Adet, string Unvan)>
        {
            ("bashekim", ["Başhekim"], BolumAra(c, "Başhekimlik"), 1, "Dr."),
            ("hekim", ["Uzman Hekim"], null, Math.Max(4, n * 26 / 100), "Dr."),
            ("hemsire", ["Hemşire"], null, Math.Max(3, n * 32 / 100), ""),
            ("kayit_kabul", ["Hasta Kabul Görevlisi"], BolumAra(c, "Hasta Kabul / Danışma"), Math.Max(2, n * 9 / 100), ""),
            ("lab_uzmani", ["Laborant"], BolumAra(c, "Tıbbi Biyokimya"), Math.Max(2, n * 9 / 100), ""),
            ("eczaci", ["Eczacı"], BolumAra(c, "Depo / Ambar"), Math.Max(1, n * 5 / 100), ""),
            ("erp_ik", ["İnsan Kaynakları Uzmanı", "İK Uzmanı"], BolumAra(c, "İnsan Kaynakları"), Math.Max(1, n * 4 / 100), ""),
            ("muhasebe", ["Muhasebe Elemanı"], BolumAra(c, "Muhasebe ve Finans"), Math.Max(1, n * 5 / 100), ""),
            ("atanmamis", ["Teknik / Destek"], BolumAra(c, "Teknik Servis / Biyomedikal"), Math.Max(1, n * 4 / 100), ""),
        };
        await using var islem = await b.BeginTransactionAsync(iptal);
        int? bashekim = null;
        var sira = 0;
        foreach (var p in plan)
        {
            for (var i = 0; i < p.Adet; i++)
            {
                var kadin = r.NextDouble() < (p.Rol == "hemsire" ? 0.85 : 0.5);
                var ad = Ad(r, kadin);
                var soyad = Soyad(r);
                var bolum = p.Bolum ?? (p.Rol == "hekim" ? c.KlinikBolumler[i % c.KlinikBolumler.Count]
                                      : c.KlinikBolumler[r.Next(Math.Min(6, c.KlinikBolumler.Count))]);
                var giris = bugun.AddDays(-r.Next(60, 365 * 18));
                string sicil;
                do sicil = "DM" + (++sira).ToString("D4", CultureInfo.InvariantCulture); while (!c.MevcutSicil.Add(sicil));
                var id = await b.TekDegerAsync<int>("""
                    insert into public.taraf (kod, unvan, ad, soyad, personel, hekim, randevu_verilebilir, durum, departman, gorev_id,
                                              vkno, cep_tel, eposta, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, 1, @p4, @p4, 1, @p5, @p6, @p7, @p8, @p9, @p10, 0) returning id
                    """, islem, [sicil, p.Unvan, ad, soyad,
                                 (short)(p.Rol is "hekim" or "bashekim" ? 1 : 0), (short)bolum,
                                 GorevAra(c, p.Gorev) is int g ? (short)g : null, Tc(c), Cep(c),
                                 Eposta(ad, soyad, sira), c.SubeId], iptal);
                await b.CalistirAsync("""
                    insert into public.taraf_personel (id, dogum_tarihi, cinsiyet, ise_giris_tarihi, sube_id, uyruk,
                                                       calisma_sekli, sgk_sicil_no, yonetici_taraf_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, 9980, 1, @p5, @p6, 0)
                    """, islem, [id, bugun.AddYears(-r.Next(24, 60)).AddDays(-r.Next(365)).ToDateTime(TimeOnly.MinValue),
                                 (short)(kadin ? 2 : 1), giris.ToDateTime(TimeOnly.MinValue), c.SubeId,
                                 r.Next(1000000, 9999999).ToString(CultureInfo.InvariantCulture), bashekim], iptal);
                c.Kayit.Add(("taraf", id));
                c.Personel.Add((id, p.Rol, bolum, $"{p.Unvan} {ad} {soyad}".Trim()));
                if (p.Rol == "hekim") c.Hekimler.Add((id, bolum));
                if (p.Rol == "bashekim") bashekim = id;
            }
        }
        await KayitYazAsync(b, islem, c, iptal);
        await islem.CommitAsync(iptal);
        return c.Personel.Count;
    }

    // ------------------------------------------------------- kullanıcı ----
    private static async Task<int> KullaniciUretAsync(NpgsqlConnection b, Baglam c, CancellationToken iptal)
    {
        var hash = BCrypt.Net.BCrypt.HashPassword(DemoParola);
        await using var islem = await b.BeginTransactionAsync(iptal);
        var adet = 0;
        foreach (var k in Kullanicilar)
        {
            if (!c.Rol.TryGetValue(k.Rol, out var rolId) || c.MevcutKod.Contains(k.Kod)) continue;
            var kisi = c.Personel.FirstOrDefault(p => p.Rol == k.Rol);
            if (kisi.Id == 0) continue;
            await b.CalistirAsync("""
                insert into public.taraf_kullanici (id, kod, parola_hash, parola_algo, parola_tarihi, parola_degismeli,
                                                    rol_id, aktif, dil, ekleyen)
                values (@p0, @p1, @p2, 'bcrypt', now(), 0, @p3, 1, 0, 0)
                """, islem, [kisi.Id, k.Kod, hash, rolId], iptal);
            // Ana rol taraf_kullanici.rol_id'de; kullanici_rol yalnız EK roller içindir.
            await b.CalistirAsync("""
                insert into public.kullanici_sube (taraf_id, sube_id, varsayilan, yazma, ekleyen)
                values (@p0, @p1, 1, 1, 0) on conflict do nothing
                """, islem, [kisi.Id, c.SubeId], iptal);
            adet++;
        }
        await islem.CommitAsync(iptal);
        return adet;
    }

    // ----------------------------------------------------------- hasta ----
    private static async Task<int> HastaUretAsync(NpgsqlConnection b, Baglam c, Random r, DemoOlcek o, DateOnly bugun,
        CancellationToken iptal)
    {
        await using var islem = await b.BeginTransactionAsync(iptal);
        for (var i = 0; i < o.Hasta; i++)
        {
            // SENARYO HASTASI hep ilk: "Elif Demo", 34 yaş, kadın - tanıtım onunla anlatılır.
            var senaryo = i == 0;
            var kadin = senaryo || r.NextDouble() < 0.52;
            var ad = senaryo ? "Elif" : Ad(r, kadin);
            var soyad = senaryo ? "Demo" : Soyad(r);
            // Yaş dağılımı: çocuk %18, yetişkin %62, 65+ %20.
            var yas = senaryo ? 34 : r.NextDouble() switch { < 0.18 => r.Next(0, 18), < 0.80 => r.Next(18, 65), _ => r.Next(65, 92) };
            var id = await b.TekDegerAsync<int>("""
                insert into public.taraf (unvan, ad, soyad, hasta, durum, vkno, cep_tel, eposta, sube_id, ekleyen)
                values (@p0, @p1, @p2, 1, 1, @p3, @p4, @p5, @p6, 0) returning id
                """, islem, [$"{ad} {soyad}", ad, soyad, Tc(c), Telefon(r), Eposta(ad, soyad, 1000 + i), c.SubeId], iptal);
            await b.CalistirAsync("""
                insert into public.taraf_hasta (id, dogum_tarihi, cinsiyet, uyruk, kan_grubu, medeni_hal, ekleyen)
                values (@p0, @p1, @p2, 9980, @p3, @p4, 0)
                """, islem, [id, bugun.AddYears(-yas).AddDays(-r.Next(365)).ToDateTime(TimeOnly.MinValue),
                             (short)(kadin ? 2 : 1), (short)r.Next(1, 9), (short)(yas < 18 ? 1 : r.Next(1, 3))], iptal);
            c.Kayit.Add(("taraf", id));
            c.Hastalar.Add(id);
            if (senaryo) c.SenaryoHasta = id;
        }
        await KayitYazAsync(b, islem, c, iptal);
        await islem.CommitAsync(iptal);
        return c.Hastalar.Count;
    }

    // --------------------------------------------------------- randevu ----
    private static async Task<int> RandevuUretAsync(NpgsqlConnection b, Baglam c, Random r, DemoOlcek o, DateOnly bugun,
        CancellationToken iptal)
    {
        // Slotlar 08:30-12:00 ve 13:00-16:30, 20 dk. Doluluk hedef adede göre.
        var saatler = new List<TimeOnly>();
        for (var t = new TimeOnly(8, 30); t < new TimeOnly(12, 0); t = t.AddMinutes(20)) saatler.Add(t);
        for (var t = new TimeOnly(13, 0); t < new TimeOnly(16, 30); t = t.AddMinutes(20)) saatler.Add(t);
        var gunler = Enumerable.Range(-o.GunGeri, o.GunGeri + o.GunIleri + 1).Select(bugun.AddDays)
            .Where(g => g == bugun || g.DayOfWeek is not DayOfWeek.Saturday and not DayOfWeek.Sunday).ToList();
        // BUGÜN HER ZAMAN DOLU: tanıtım hafta sonu da yapılabilir - "bugünün randevuları" boş görünmesin.
        var oran = Math.Min(0.95, (double)o.Randevu / Math.Max(1, c.Hekimler.Count * gunler.Count * saatler.Count));
        var simdi = DateTimeOffset.UtcNow.ToOffset(Istanbul);
        var dolu = new HashSet<(int, DateTimeOffset)>();
        var adet = 0;

        await using var islem = await b.BeginTransactionAsync(iptal);
        async Task Ekle(int hekim, int bolum, int hasta, DateTimeOffset bas, short durum)
        {
            if (!dolu.Add((hasta, bas))) return;
            await islem.SaveAsync("rv", iptal);
            try
            {
                var id = await b.TekDegerAsync<int>("""
                    insert into public.randevu (sube_id, bolum, hekim_id, hasta_id, baslangic, sure_dk, durum, aciklama, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, 20, @p5, '', 0) returning id
                    """, islem, [c.SubeId, (short)bolum, hekim, hasta, bas.ToUniversalTime(), durum], iptal);
                await islem.ReleaseAsync("rv", iptal);
                c.Kayit.Add(("randevu", id));
                adet++;
            }
            catch (PostgresException) { await islem.RollbackAsync("rv", iptal); }   // çakışma / izin kuralı: atla
        }

        // Senaryo: Elif Demo bugün 10:30, ilk klinikteki ilk hekim.
        var senaryoSaat = new DateTimeOffset(bugun.ToDateTime(new TimeOnly(10, 30)), Istanbul);
        if (c.SenaryoHasta is int sh)
            await Ekle(c.Hekimler[0].Id, c.Hekimler[0].Bolum, sh, senaryoSaat, 1);

        foreach (var (hekim, bolum) in c.Hekimler)
            foreach (var g in gunler)
                foreach (var s in saatler)
                {
                    var bugunMu = g == bugun;
                    if (r.NextDouble() >= (bugunMu ? Math.Min(0.95, oran * 1.6) : oran)) continue;
                    var bas = new DateTimeOffset(g.ToDateTime(s), Istanbul);
                    if (hekim == c.Hekimler[0].Id && bas == senaryoSaat) continue;
                    var hasta = c.Hastalar[1 + r.Next(Math.Max(1, c.Hastalar.Count - 1)) % Math.Max(1, c.Hastalar.Count - 1)];
                    var x = r.NextDouble();
                    short durum = bas < simdi
                        ? (x < 0.80 ? (short)2 : x < 0.92 ? (short)3 : (short)4)
                        : (x < 0.96 ? (short)1 : (short)4);
                    await Ekle(hekim, bolum, hasta, bas, durum);
                }
        await KayitYazAsync(b, islem, c, iptal);
        await islem.CommitAsync(iptal);
        return adet;
    }

    // ------------------------------------------------------------- İK ----
    private static async Task<int> IkUretAsync(NpgsqlConnection b, Baglam c, Random r, DateOnly bugun, CancellationToken iptal)
    {
        await using var islem = await b.BeginTransactionAsync(iptal);
        var adet = 0;
        // Hekimlere izin yazılmaz: geçmiş randevularıyla çakışıp tutarsız tablo çizerdi.
        foreach (var p in c.Personel.Where(p => p.Rol != "hekim"))
        {
            var x = r.NextDouble();
            if (x < 0.55)
            {
                // Geçmiş yıllık izin (onaylı), %20'sine ileri tarihli planlı izin, %8 taslak.
                var bas = bugun.AddDays(-r.Next(10, 80));
                var gun = r.Next(2, 8);
                adet += await IzinAsync(p.Id, bas, gun, 2, "Yıllık izin");
                if (r.NextDouble() < 0.20) adet += await IzinAsync(p.Id, bugun.AddDays(r.Next(5, 40)), r.Next(2, 6), 2, "Planlı yıllık izin");
                else if (r.NextDouble() < 0.10) adet += await IzinAsync(p.Id, bugun.AddDays(r.Next(10, 50)), r.Next(1, 4), 0, "Taslak");
            }
            if (r.NextDouble() < 0.07)
            {
                var id = await b.TekDegerAsync<int>("""
                    insert into public.personel_avans (taraf_id, talep_tarihi, tutar, gerekce, taksit_sayisi, ilk_donem, durum, sube_id, ekleyen)
                    values (@p0, @p1, @p2, 'Ev kirası / acil ihtiyaç', @p3, to_char(@p1::date + interval '1 month', 'YYYY-MM'), @p4, @p5, 0)
                    returning id
                    """, islem, [p.Id, bugun.AddDays(-r.Next(5, 60)).ToDateTime(TimeOnly.MinValue), (decimal)(r.Next(3, 16) * 1000),
                                 (short)r.Next(1, 4), (short)(r.NextDouble() < 0.6 ? 4 : 5), c.SubeId], iptal);
                c.Kayit.Add(("personel_avans", id)); adet++;
            }
            if (r.NextDouble() < 0.10)
            {
                var tarih = bugun.AddDays(-r.Next(3, 70));
                var id = await b.TekDegerAsync<int>("""
                    insert into public.personel_belge_talep (taraf_id, sube_id, talep_tarihi, tur, amac, adet, teslim_sekli, durum,
                                                             otomatik_onay, hazirlama_tarihi, teslim_tarihi, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, 1, 1, 5, 1, @p5, @p5, 0) returning id
                    """, islem, [p.Id, c.SubeId, tarih.ToDateTime(TimeOnly.MinValue), (short)r.Next(1, 3),
                                 r.NextDouble() < 0.5 ? "Banka kredi başvurusu" : "Kira sözleşmesi",
                                 new DateTimeOffset(tarih.AddDays(1).ToDateTime(new TimeOnly(11, 0)), Istanbul).ToUniversalTime()], iptal);
                c.Kayit.Add(("personel_belge_talep", id)); adet++;
            }
        }
        await KayitYazAsync(b, islem, c, iptal);
        await islem.CommitAsync(iptal);
        return adet;

        async Task<int> IzinAsync(int taraf, DateOnly bas, int gun, short durum, string aciklama)
        {
            var id = await b.TekDegerAsync<int>("""
                insert into public.personel_izin (taraf_id, tur, baslangic_tarihi, bitis_tarihi, gun, aciklama, durum, sube_id,
                                                  talep_tarihi, is_gunu, ekleyen)
                values (@p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7, 0, 0) returning id
                """, islem, [taraf, bas.ToDateTime(TimeOnly.MinValue), bas.AddDays(gun - 1).ToDateTime(TimeOnly.MinValue),
                             (decimal)gun, aciklama, durum, c.SubeId, bas.AddDays(-10).ToDateTime(TimeOnly.MinValue)], iptal);
            c.Kayit.Add(("personel_izin", id));
            return 1;
        }
    }

    // ----------------------------------------------------------- adlar ----
    private static readonly string[] KadinAd = ["Ayşe", "Fatma", "Zeynep", "Elif", "Merve", "Esra", "Büşra", "Selin", "Derya", "Gamze",
        "Hatice", "Emine", "Sevgi", "Yasemin", "Tuğba", "Ebru", "Özlem", "Nur", "Cansu", "Damla", "Ece", "İrem", "Pınar", "Burcu", "Aslı",
        "Melike", "Sibel", "Gülşen", "Nazlı", "Ceren"];
    private static readonly string[] ErkekAd = ["Mehmet", "Mustafa", "Ahmet", "Ali", "Hüseyin", "Hasan", "İbrahim", "Murat", "Ömer", "Emre",
        "Burak", "Can", "Kerem", "Serkan", "Volkan", "Onur", "Tolga", "Cem", "Barış", "Eren", "Yusuf", "Furkan", "Gökhan", "Kaan",
        "Oğuz", "Selim", "Tuncay", "Umut", "Yiğit", "Berk"];
    private static readonly string[] Soyadlar = ["Yılmaz", "Kaya", "Demir", "Şahin", "Çelik", "Yıldız", "Yıldırım", "Öztürk", "Aydın",
        "Özdemir", "Arslan", "Doğan", "Kılıç", "Aslan", "Çetin", "Kara", "Koç", "Kurt", "Özkan", "Şimşek", "Polat", "Korkmaz",
        "Karaca", "Erdoğan", "Güneş", "Aksoy", "Tekin", "Ünal", "Bozkurt", "Turan", "Kaplan", "Avcı", "Sarı", "Taş", "Bulut"];

    private static string Ad(Random r, bool kadin) => kadin ? KadinAd[r.Next(KadinAd.Length)] : ErkekAd[r.Next(ErkekAd.Length)];
    private static string Soyad(Random r) => Soyadlar[r.Next(Soyadlar.Length)];
}
