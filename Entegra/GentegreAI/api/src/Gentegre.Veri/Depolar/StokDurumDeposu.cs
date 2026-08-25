using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Stok kartinin "Stok Durumu" sekmesindeki bir depo satiri
/// (Ekranlar/stok_karti.html: Depo x Miktar x Rezerve x Kullanilabilir x Min x Max x Durum).
/// </summary>
public sealed record StokDurumSatiri(
    int DepoId, string DepoAdi, decimal Miktar, decimal Rezerve, decimal Kullanilabilir,
    decimal Yolda, decimal? MinStok, decimal? MaxStok, string Durum);

/// <summary>Sekmenin ust seridi - dort KPI kutusu.</summary>
public sealed record StokDurumOzeti(
    decimal Toplam, decimal Rezerve, decimal Kullanilabilir, decimal Yolda, int DepoSayisi);

public sealed record StokDurumYaniti(
    StokDurumOzeti Ozet, IReadOnlyList<StokDurumSatiri> Satirlar, string Birim);

/// <summary>
/// "Hareketler" sekmesinin bir satiri. <c>Kalan</c> = donem devri uzerine yurumeli
/// bakiye (secili depo suzgeci neyse ona gore).
/// </summary>
/// <summary>
/// Cikis belgesinde secilebilecek LOT: stokta kalani olan izlem satiri (114).
/// Kalan, o lotun giris satirindan dusulerek yurur.
/// </summary>
/// <summary>Paket icerigi satiri (124) - belge kaleminde acilan alt satirlar.</summary>
public sealed record PaketIcerikSatiri(
    int stokId,
    string kod,
    string ad,
    int birim,
    decimal adet,
    int kdv,
    decimal fiyat,
    int izleme);

public sealed record StokLotSatiri(
    int seriLotId,
    string lotNo,
    string seriNo,
    DateTime? uretimTarihi,
    DateTime? sonKullanmaTarihi,
    decimal kalan,
    /// <summary>Lotun bulundugu depo. Gocmus hareketlerde bilinmiyor (null).</summary>
    int? depoId,
    string depoAdi);

public sealed record StokHareketSatiri(
    long BelgeId, DateTime Tarih, int BelgeTur, string BelgeTurAdi, string BelgeNo,
    string TarafUnvan, string Depo, string Yon, decimal Giris, decimal Cikis, decimal Kalan,
    string Aciklama);

public sealed record StokHareketYaniti(
    decimal Devir, decimal Kapanis, IReadOnlyList<StokHareketSatiri> Satirlar, string Birim);

/// <summary>
/// Depo bazli stok durumu.
///
/// Miktar SALT OKUNURDUR: <c>stok_durum</c> belge kaydinda guncellenir, buradan
/// elle degistirilemez. Yazilabilen tek sey depo bazli MIN/MAX seviyedir (099).
///
/// REZERVE = acik SATIS siparisi (tur 19) satirlarinin kalan miktari - mal daha
/// cikmadi ama soz verildi. YOLDA = acik ALIS siparisi (tur 9) kalani - henuz
/// girmedi ama bekleniyor. Ikisi de F8'in <c>kalan_miktar</c> sayacindan gelir,
/// ayri bir rezervasyon tablosu yoktur.
/// </summary>
public sealed class StokDurumDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    /// <summary>GENINI -11110: 88 = Stoklar (stok kartiyla ayni log tablosu).</summary>
    private const int LogTabloStok = 88;

    public StokDurumDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    public async Task<StokDurumYaniti> OkuAsync(long stokId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        decimal kartMin = 0m;
        string birim = "";
        await using (var komut = new NpgsqlCommand("""
            select s.min_stok, coalesce(kd.ad, '') as birim
              from public.stok s
              left join public.kod_liste kl on kl.kod = 'stok.ana_birim'
              left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = s.ana_birim
             where s.id = @p0
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Stok bulunamadı.");
            kartMin = o.IsDBNull(0) ? 0m : o.GetDecimal(0);
            birim = o.GetString(1);
        }

        // Depo listesi PASIF depoyu da tasir - gecmiste oraya mal girmis olabilir;
        //   miktari olmayan pasif depo ise gosterilmez (asagidaki where).
        var satirlar = new List<StokDurumSatiri>();
        await using (var komut = new NpgsqlCommand("""
            with rez as (
                -- Acik SATIS siparisi: cikis deposundan soz verilmis miktar.
                select coalesce(bs.cikis_depo_id, b.cikis_depo_id) as depo_id,
                       sum(bs.kalan_miktar) as miktar
                  from public.belge_satir bs
                  join public.belge b on b.id = bs.belge_id
                 where b.tur = 19 and b.durum = 0 and bs.stok_id = @p0 and bs.kalan_miktar > 0
                 group by 1
            ), yol as (
                -- Acik ALIS siparisi: giris deposuna beklenen miktar.
                select coalesce(bs.giris_depo_id, b.giris_depo_id) as depo_id,
                       sum(bs.kalan_miktar) as miktar
                  from public.belge_satir bs
                  join public.belge b on b.id = bs.belge_id
                 where b.tur = 9 and b.durum = 0 and bs.stok_id = @p0 and bs.kalan_miktar > 0
                 group by 1
            )
            select d.id, d.ad,
                   coalesce(sd.kalan, 0)   as miktar,
                   coalesce(rez.miktar, 0) as rezerve,
                   coalesce(yol.miktar, 0) as yolda,
                   sd.min_stok, sd.max_stok
              from public.depo d
              left join public.stok_durum sd on sd.depo_id = d.id and sd.stok_id = @p0
              left join rez on rez.depo_id = d.id
              left join yol on yol.depo_id = d.id
             where coalesce(sd.kalan, 0) <> 0
                or coalesce(rez.miktar, 0) <> 0
                or coalesce(yol.miktar, 0) <> 0
                or (d.durum = 1 and sd.stok_id is not null)
             order by d.varsayilan desc, d.ad
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
            {
                var miktar   = o.GetDecimal(2);
                var rezerve  = o.GetDecimal(3);
                var yolda    = o.GetDecimal(4);
                var min      = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5);
                var max      = o.IsDBNull(6) ? (decimal?)null : o.GetDecimal(6);
                var kullanilabilir = miktar - rezerve;

                satirlar.Add(new StokDurumSatiri(
                    o.GetInt32(0), o.GetString(1), miktar, rezerve, kullanilabilir, yolda,
                    min, max, Seviye(kullanilabilir, min ?? kartMin)));
            }
        }

        var ozet = new StokDurumOzeti(
            satirlar.Sum(s => s.Miktar),
            satirlar.Sum(s => s.Rezerve),
            satirlar.Sum(s => s.Kullanilabilir),
            satirlar.Sum(s => s.Yolda),
            satirlar.Count(s => s.Miktar != 0));

        return new StokDurumYaniti(ozet, satirlar, birim);
    }

    /// <summary>
    /// Kritik seviye kurali: KULLANILABILIR (rezerve dusulmus) miktar esikle
    /// karsilastirilir - depoda mal gorunup hepsi soz verilmisse "Yeterli" demek
    /// yaniltici olurdu. Esik 0 ise kritik uyarisi verilmez (limit tanimlanmamis).
    /// </summary>
    private static string Seviye(decimal kullanilabilir, decimal esik)
    {
        if (kullanilabilir <= 0) return "yok";
        if (esik > 0 && kullanilabilir <= esik) return "kritik";
        return "yeterli";
    }

    /// <summary>
    /// Stok hareket dokumu (kart "Hareketler" sekmesi).
    ///
    /// Kaynak <c>belge_satir</c>'dir: STOGU GERCEKTEN OYNATAN satirlar
    /// (<c>stok_durum_degis = 1</c>) - irsaliyeden turetilen fatura satiri stogu
    /// ikinci kez oynatmadigi icin dokumde de gorunmez, yoksa ayni mal iki kez
    /// girmis gibi okunurdu.
    ///
    /// DEVIR: baslangic tarihinden ONCEKI hareketlerin net toplami. Kalan sutunu
    /// devirden baslayip satir satir yurur; boylece son satirin kalani ile
    /// stok_durum.kalan (tum depo, tum tarih secildiginde) ayni cikar.
    /// </summary>
    public async Task<StokHareketYaniti> HareketAsync(long stokId, DateTime bas, DateTime bit,
        int? depoId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        string birim = "";
        await using (var komut = new NpgsqlCommand("""
            select coalesce(kd.ad, '')
              from public.stok s
              left join public.kod_liste kl on kl.kod = 'stok.ana_birim'
              left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = s.ana_birim
             where s.id = @p0
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            birim = (await komut.ExecuteScalarAsync(iptal)) as string ?? "";
        }

        // Depo suzgeci iki tarafa da bakar: transferde ayni satir bir depodan
        //   cikip digerine girer. Suzgec yoksa (@p3 null) satirin kendi yonu gecerli.
        //   Yon = satirda giris deposu VAR MI - alis/giris belgesinde giris_depo_id,
        //   satis/cikis belgesinde cikis_depo_id dolu gelir.
        const string GirisIfade = """
            case when coalesce(bs.giris_depo_id, b.giris_depo_id) is not null
                      and (@p3::int is null or coalesce(bs.giris_depo_id, b.giris_depo_id) = @p3)
                 then bs.miktar else 0 end
            """;
        const string CikisIfade = """
            case when coalesce(bs.cikis_depo_id, b.cikis_depo_id) is not null
                      and (@p3::int is null or coalesce(bs.cikis_depo_id, b.cikis_depo_id) = @p3)
                 then bs.miktar else 0 end
            """;
        const string Suzgec = """
             where bs.stok_id = @p0 and bs.stok_durum_degis = 1 and b.durum = 0
               and (@p3::int is null
                    or coalesce(bs.giris_depo_id, b.giris_depo_id) = @p3
                    or coalesce(bs.cikis_depo_id, b.cikis_depo_id) = @p3)
            """;

        decimal devir;
        await using (var komut = new NpgsqlCommand($"""
            select coalesce(sum(({GirisIfade}) - ({CikisIfade})), 0)
              from public.belge_satir bs
              join public.belge b on b.id = bs.belge_id
            {Suzgec} and b.belge_tarihi < @p1
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", bas);
            komut.Parameters.AddWithValue("p3", (object?)depoId ?? DBNull.Value);
            devir = Convert.ToDecimal(await komut.ExecuteScalarAsync(iptal));
        }

        var satirlar = new List<StokHareketSatiri>();
        var kalan = devir;
        await using (var komut = new NpgsqlCommand($"""
            select b.id, b.belge_tarihi, b.tur, coalesce(t.ad, '') as tur_adi,
                   coalesce(b.belge_no, '') as belge_no, coalesce(b.taraf_unvan, '') as taraf,
                   coalesce(gd.ad, '') as giris_depo, coalesce(cd.ad, '') as cikis_depo,
                   {GirisIfade} as giris,
                   {CikisIfade} as cikis,
                   coalesce(bs.aciklama, '') as aciklama
              from public.belge_satir bs
              join public.belge b on b.id = bs.belge_id
              left join public.kasa_islem_turu t on t.kod = b.tur
              left join public.depo gd on gd.id = coalesce(bs.giris_depo_id, b.giris_depo_id)
              left join public.depo cd on cd.id = coalesce(bs.cikis_depo_id, b.cikis_depo_id)
            {Suzgec} and b.belge_tarihi >= @p1 and b.belge_tarihi < @p2
             order by b.belge_tarihi, bs.id
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", bas);
            komut.Parameters.AddWithValue("p2", bit);
            komut.Parameters.AddWithValue("p3", (object?)depoId ?? DBNull.Value);

            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
            {
                var giris = o.GetDecimal(8);
                var cikis = o.GetDecimal(9);
                kalan += giris - cikis;

                var girisDepo = o.GetString(6);
                var cikisDepo = o.GetString(7);
                // Transfer: iki depo da dolu - mockup'taki "Merkez -> Ankara" gosterimi.
                var depoMetni = girisDepo.Length > 0 && cikisDepo.Length > 0
                    ? $"{cikisDepo} → {girisDepo}"
                    : girisDepo.Length > 0 ? girisDepo : cikisDepo;

                // Depo suzgeci YOKKEN transfer satiri hem girer hem cikar (net 0):
                //   "Giris" ya da "Cikis" demek yaniltici olurdu.
                var yon = giris > 0 && cikis > 0 ? "transfer" : giris > 0 ? "giris" : "cikis";

                satirlar.Add(new StokHareketSatiri(
                    o.GetInt64(0), o.GetDateTime(1), o.GetInt32(2), o.GetString(3), o.GetString(4),
                    o.GetString(5), depoMetni, yon,
                    giris, cikis, kalan, o.GetString(10)));
            }
        }

        return new StokHareketYaniti(devir, kalan, satirlar, birim);
    }

    /// <summary>
    /// Depo bazli min/max seviyeyi yazar. Miktar kolonlarina DOKUNMAZ. Satir yoksa
    /// acilir (stok o depoda hic hareket gormemis olabilir ama limiti tanimlanabilir).
    /// </summary>
    public async Task<StokDurumYaniti> LimitYazAsync(long stokId, int depoId,
        decimal? minStok, decimal? maxStok, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (minStok is < 0 || maxStok is < 0)
            throw GentegreHatasi.Dogrulama("Seviye eksi olamaz.",
                new AlanHatasi(minStok is < 0 ? "minStok" : "maxStok", "Sıfırdan küçük olamaz."));
        if (minStok is { } m && maxStok is { } x && x > 0 && m > x)
            throw GentegreHatasi.IsKurali("Minimum seviye maksimumdan büyük olamaz.");

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using (var komut = new NpgsqlCommand("""
            insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan, min_stok, max_stok)
            values (@p0, @p1, 0, 0, 0, @p2, @p3)
            on conflict (stok_id, depo_id)
              do update set min_stok = excluded.min_stok, max_stok = excluded.max_stok
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", depoId);
            komut.Parameters.AddWithValue("p2", (object?)minStok ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", (object?)maxStok ?? DBNull.Value);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloStok, stokId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "stokDurumLimit",
                ["depoId"] = depoId.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["minStok"] = minStok?.ToString(System.Globalization.CultureInfo.InvariantCulture) ?? "",
                ["maxStok"] = maxStok?.ToString(System.Globalization.CultureInfo.InvariantCulture) ?? ""
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return await OkuAsync(stokId, iptal);
    }

    /// <summary>
    /// STOK KARTI KOPYALA (126): karti tum alanlariyla cogaltir, kod sonuna
    /// "_Kn", ad sonuna " kopya" ekler; paket ise ICERIGI de kopyalanir.
    ///
    /// Kopyalama mantigi SQL fonksiyonunda (fn_stok_kopyala): kolon listesi
    /// dinamik okundugu icin stok tablosuna kolon eklendiginde burasi
    /// guncellenmek zorunda kalmaz.
    /// </summary>
    public async Task<long> KopyalaAsync(long stokId, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        long yeniId;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_stok_kopyala(@p0, @p1, @p2)", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", (int)stokId);
            komut.Parameters.AddWithValue("p1", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p2", (object?)baglam.SubeId ?? DBNull.Value);
            var d = await komut.ExecuteScalarAsync(iptal);
            if (d is null || d == DBNull.Value)
                throw GentegreHatasi.IsKurali("Stok kartı kopyalanamadı.");
            yeniId = Convert.ToInt64(d);
        }

        // Log YENI kayda yazilir (kaynak kart degismedi); bilgi alaninda
        //   kaynagin id'si durur - "bu kart nereden cogaltildi" izi kalsin.
        await _log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloStok, yeniId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "stokKopyala",
                ["kaynakStokId"] = stokId.ToString(System.Globalization.CultureInfo.InvariantCulture)
            }, stokId: (int)yeniId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return yeniId;
    }

    /// <summary>
    /// Stokta KALANI olan LOTLAR - cikis belgesinde secim listesi ve stok
    /// kartindaki depo bazli lot dokumu.
    ///
    /// KAYNAK stok_lot_durum (117): lot bakiyesinin TEK dogruluk kaynagi.
    /// stok_izleme.kalan buna KARISTIRILMAZ - o alan eski sistemde de "bu belge
    /// satirindan devredilmemis miktar" (donusid zinciri) demekti; satis
    /// faturasi satirinin bile kalani olur.
    ///
    /// LOT BAZINDA, hareket bazinda DEGIL: ayni lot her girisde yeni bir izlem
    /// satiri uretir; kullaniciya "PTL4106210826" lotunu alti kez gostermek
    /// (50, 38, 40, 20, 6, 4) secimi imkansiz kilar. Lotun kalani toplanir,
    /// tuketim sirasi sunucunun isidir (giris sirasiyla, FIFO).
    ///
    /// Sira SKT'ye gore (once tukenecek olan once): son kullanma tarihi olan mal
    /// FEFO ile cikar, tarihi olmayanlar giris sirasiyla arkada. Kullanici yine
    /// istedigini secebilir; sira yalniz dogru olani ONE getirir.
    ///
    /// DEPO KIRILIMI YOK: izlem satiri depo tutmuyor (goc semasi da tutmuyordu),
    /// bu yuzden lot kalanlari stok genelindedir. Depo bazli lot gerekirse
    /// stok_izleme'ye depo kolonu eklenmeli - o ayri bir istir.
    /// </summary>
    public async Task<IReadOnlyList<StokLotSatiri>> LotlarAsync(
        long stokId, int? depoId = null, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select ld.seri_lot_id, l.lot_no, l.seri_no,
                   case when l.uretim_tarihi in (timestamp '1899-12-31 00:00',
                                                 timestamp '1990-01-01 00:00')
                        then null else l.uretim_tarihi end,
                   case when l.son_kullanma_tarihi in (timestamp '1899-12-31 00:00',
                                                       timestamp '1990-01-01 00:00')
                        then null else l.son_kullanma_tarihi end,
                   ld.kalan, ld.depo_id, coalesce(d.ad, '')
              from public.stok_lot_durum ld
              join public.stok_seri_lot l on l.id = ld.seri_lot_id
              left join public.depo d on d.id = ld.depo_id
             where ld.stok_id = @p0
               and ld.kalan > 0
               and (@p1::int is null or ld.depo_id = @p1)
             order by l.son_kullanma_tarihi asc nulls last, ld.seri_lot_id asc
            """, baglanti);
        komut.Parameters.AddWithValue("p0", (int)stokId);
        komut.Parameters.AddWithValue("p1", (object?)depoId ?? DBNull.Value);

        var sonuc = new List<StokLotSatiri>();
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
            sonuc.Add(new StokLotSatiri(
                okuyucu.GetInt32(0),
                okuyucu.IsDBNull(1) ? "" : okuyucu.GetString(1),
                okuyucu.IsDBNull(2) ? "" : okuyucu.GetString(2),
                okuyucu.IsDBNull(3) ? null : okuyucu.GetDateTime(3),
                okuyucu.IsDBNull(4) ? null : okuyucu.GetDateTime(4),
                okuyucu.GetDecimal(5),
                okuyucu.IsDBNull(6) ? null : okuyucu.GetInt32(6),
                okuyucu.IsDBNull(7) ? "" : okuyucu.GetString(7)));
        return sonuc;
    }

    /// <summary>
    /// Paketin icerigi (124). Belge kalemi paket secildiginde bu satirlar
    /// belgeye eklenir; her satirin KDV'si ve izleme turu kendi stok kartindan
    /// gelir - paketten miras almaz.
    /// </summary>
    public async Task<IReadOnlyList<PaketIcerikSatiri>> PaketIcerigiAsync(
        long paketStokId, bool alis = false, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select s.id, s.kod, s.ad,
                   case when p.birim > 0 then p.birim else s.ana_birim end as birim,
                   p.adet, s.kdv, s.izleme,
                   -- FIYAT: pakette girilmisse O, girilmemisse stogun KENDI kart
                   --   fiyati. Kart fiyati kurali fn_stok_kart_fiyat'ta (128) -
                   --   liste kolonlariyla ayni yerden okunur.
                   case when p.birim_fiyat > 0 then p.birim_fiyat
                        else coalesce((select fiyat from public.fn_stok_kart_fiyat(
                                         s.id, (case when @p1 then 0 else 1 end)::smallint)), 0)
                   end as fiyat
              from public.stok_paket p
              join public.stok s on s.id = p.icerik_stok_id
             where p.paket_stok_id = @p0
             order by p.id
            """, baglanti);
        komut.Parameters.AddWithValue("p0", (int)paketStokId);
        komut.Parameters.AddWithValue("p1", alis);

        var sonuc = new List<PaketIcerikSatiri>();
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
            sonuc.Add(new PaketIcerikSatiri(
                okuyucu.GetInt32(0),
                okuyucu.IsDBNull(1) ? "" : okuyucu.GetString(1),
                okuyucu.IsDBNull(2) ? "" : okuyucu.GetString(2),
                okuyucu.IsDBNull(3) ? 0 : Convert.ToInt32(okuyucu.GetValue(3)),
                okuyucu.GetDecimal(4),
                okuyucu.IsDBNull(5) ? 0 : Convert.ToInt32(okuyucu.GetValue(5)),
                okuyucu.IsDBNull(7) ? 0m : okuyucu.GetDecimal(7),
                okuyucu.IsDBNull(6) ? 0 : Convert.ToInt32(okuyucu.GetValue(6))));
        return sonuc;
    }
}
