using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Stok tarafi: depo miktarlari ve seri/lot izlemi (114-118). Girişte lot dagitimi, cikista lottan dusme ve stok_lot_durum bakiyesi burada.
/// </summary>
public sealed partial class BelgeDeposu
{
    // ============================================================ lot / seri ====
    /// <summary>
    /// Satirin LOT/SERI dagilimini yazar (stok_seri_lot + stok_izleme).
    ///
    /// Kural stok kartindan gelir (stok.izleme): 0 izlemsiz, 1 Seri No, 2 Lot No,
    /// 3 SKT, 4 Karekod, 5 Lot No + SKT, 6 Seri No + Lot No. Izlemli bir stokta
    /// GIRIS belgesinde lot bilgisi ZORUNLUDUR - girilmezse mal hangi lottan
    /// geldigi bilinmeden depoya girer ve geri izlenemez (gida/ilac/medikal
    /// tarafinda tek sebeple: geri cagirma).
    ///
    /// Bir kalem 1:n lot tasiyabilir; lot miktarlarinin toplami satir miktarina
    /// ESIT olmali - eksik/fazla dagitim depo miktariyla lot toplamini ayirir.
    ///
    /// CIKIS belgelerinde bu yol henuz calismaz: cikista lot SECILIR (mevcut
    /// stoktan, kalan miktarina gore) - ayri ekran, ayri kural.
    /// </summary>
    private async Task IzlemYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int satirId, int stokId, int sira, int belgeTur, decimal adet,
        Dictionary<string, JsonElement> satir, IDictionary<string, object?> belge,
        bool turStokEtkiler, List<string> uyarilar, CancellationToken iptal)
    {
        // Hareketin deposu (115): giris yonlu belgede giris deposu, cikista
        //   cikis deposu. Transferde IKISI de var - tuketim cikis deposundan,
        //   yeni satir giris deposuna yazilir.
        int? girisDepo = JsonSayiNull(satir, "girisDepoId") ?? SayiNull(belge, "girisDepoId");
        int? cikisDepo = JsonSayiNull(satir, "cikisDepoId") ?? SayiNull(belge, "cikisDepoId");
        var stokIzleme = await StokIzlemeTuruAsync(baglanti, islem, stokId, iptal);
        var izlemler = satir.TryGetValue("izlemler", out var dizi) && dizi.ValueKind == JsonValueKind.Array
            ? dizi.EnumerateArray().ToList()
            : new List<JsonElement>();

        if (stokIzleme == 0)
        {
            if (izlemler.Count > 0)
                throw GentegreHatasi.Dogrulama($"{sira}. satirdaki stok izlemli degil.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Bu stok icin lot/seri tutulmuyor."));
            return;
        }

        // Stok izlemli ama belge stogu etkilemiyorsa (siparis/teklif/talep) lot
        //   istemenin anlami yok: henuz fiziki hareket yok. Irsaliyeden turetilen
        //   faturada da stok TEKRAR dusmez - lot da tekrar dusmemeli
        //   (stokDurumDegis satir bazinda 0 gelir).
        if (!turStokEtkiler || JsonSayi(satir, "stokDurumDegis", 1) == 0) return;

        // CIKIS ve TRANSFER: lot girilmez, mevcut lotlardan SECILIR.
        //   Fark tuketimin sonucunda: cikista mal gider (yeni satirin kalani 0),
        //   transferde mal DEPO DEGISTIRIR - ayni lot stokta durmaya devam eder,
        //   o yuzden yeni satir kalanini TASIR. Aksi halde depolar arasi her
        //   transfer lot kalanini eritir, urun stokta gorunur ama lotu kalmaz.
        if (BelgeTuru.CikisMi(belgeTur) || BelgeTuru.TransferMi(belgeTur))
        {
            await IzlemDusAsync(baglanti, islem, belgeId, satirId, stokId, sira,
                                belgeTur, stokIzleme, adet, izlemler,
                                kalaniTasi: BelgeTuru.TransferMi(belgeTur),
                                kaynakDepo: cikisDepo,
                                hedefDepo: BelgeTuru.TransferMi(belgeTur) ? girisDepo : cikisDepo,
                                iptal);
            return;
        }

        if (izlemler.Count == 0)
            throw GentegreHatasi.Dogrulama($"{sira}. satir icin lot/seri girilmeli.",
                new AlanHatasi($"satirlar[{sira - 1}].izlemler", "İzlemli stok - lot bilgisi zorunlu."));

        var lotGerekli  = stokIzleme is 2 or 5 or 6;
        var seriGerekli = stokIzleme is 1 or 6;
        var sktGerekli  = stokIzleme is 3 or 5;

        decimal toplam = 0;
        foreach (var oge in izlemler)
        {
            var izlem  = JsonNesne(oge);
            var lotNo  = JsonMetin(izlem, "lotNo").Trim();
            var seriNo = JsonMetin(izlem, "seriNo").Trim();
            var miktar = JsonOndalik(izlem, "miktar", 0);
            var uretim = JsonTarih(izlem, "uretimTarihi");
            var skt    = JsonTarih(izlem, "sonKullanmaTarihi");

            if (miktar <= 0)
                throw GentegreHatasi.Dogrulama($"{sira}. satirdaki lot miktari sifirdan buyuk olmali.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Miktar sifir olamaz."));
            if (lotGerekli && lotNo.Length == 0)
                throw GentegreHatasi.Dogrulama($"{sira}. satirda Lot No girilmeli.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Lot No zorunlu."));
            if (seriGerekli && seriNo.Length == 0)
                throw GentegreHatasi.Dogrulama($"{sira}. satirda Seri No girilmeli.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Seri No zorunlu."));
            if (sktGerekli && skt is null)
                throw GentegreHatasi.Dogrulama($"{sira}. satirda son kullanma tarihi girilmeli.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "SKT zorunlu."));

            toplam += miktar;

            // SKT GECMIS: engel degil UYARI - mal fiilen gelmis olabilir (iade,
            //   imha oncesi giris). Karar kullanicinin, ama kayit sessiz gecmez.
            if (skt is { } sonGun && sonGun.Date < DateTime.Today)
                uyarilar.Add($"{sira}. satır, lot {(lotNo.Length > 0 ? lotNo : seriNo)}: " +
                             $"son kullanma tarihi geçmiş ({sonGun:dd.MM.yyyy}).");

            var seriLotId = await SeriLotIdAsync(baglanti, islem, stokId, lotNo, seriNo,
                                                 uretim, skt, iptal);

            await using var komut = new NpgsqlCommand("""
                insert into public.stok_izleme
                    (stok_id, seri_lot_id, izlem_tur, belge_tur, belge_id, belge_satir_id,
                     adet, kalan, durum, depo_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p6, @p7, @p9, @p8)
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", seriLotId);
            komut.Parameters.AddWithValue("p2", (short)stokIzleme);
            komut.Parameters.AddWithValue("p3", (short)belgeTur);
            komut.Parameters.AddWithValue("p4", belgeId);
            komut.Parameters.AddWithValue("p5", satirId);
            komut.Parameters.AddWithValue("p6", miktar);
            // Giriste durum her zaman 0 (kullanici karari); diger durumlar
            //   kod listesi tanimlanınca isletilecek.
            komut.Parameters.AddWithValue("p7", (short)JsonSayi(izlem, "durum", 0));
            komut.Parameters.AddWithValue("p8", 0);
            komut.Parameters.AddWithValue("p9", (object?)girisDepo ?? DBNull.Value);
            await komut.ExecuteNonQueryAsync(iptal);

            // Lot BAKIYESI (117) - stok_durum'un lot kirilimi. Izlem satiri
            //   hareket defteri, bakiye burada tutulur.
            if (girisDepo is { } gd)
                await LotDurumYazAsync(baglanti, islem, stokId, gd, seriLotId, miktar, iptal);
        }

        // Lot toplami satir miktarini TUTMALI: tutmazsa depodaki miktar ile
        //   lotlarin toplami ayrisir, sonraki cikislar lot bulamaz.
        if (Math.Abs(toplam - adet) > 0.0001m)
            throw GentegreHatasi.Dogrulama(
                $"{sira}. satirda lot toplami ({toplam:0.####}) miktarla ({adet:0.####}) ayni degil.",
                new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Lot miktarlari toplami satir miktarina esit olmali."));
    }

    /// <summary>
    /// CIKIS belgesinde lot TUKETIMI (satis irsaliyesi/faturasi, konsinye cikis,
    /// cikis fisi). Kullanici stoktaki lotlardan secer; her secim icin:
    ///
    ///  - kaynak izlem satirinin KALANI dusulur (yetmezse 422 - depoda olmayan
    ///    lottan mal cikamaz),
    ///  - cikisin kendi izlem satiri yazilir (donus_id = kaynak satir), boylece
    ///    "bu lot hangi belgeyle cikti" sorusu cevaplanabilir. Cikis satirinin
    ///    kalani 0'dir: o mal artik stokta degil.
    ///
    /// Kalan dusumu tek UPDATE icinde kosullu yapilir (kalan >= miktar): iki
    /// kullanici ayni lotu ayni anda tuketirse ikincisi hata alir, eksiye dusmez.
    /// </summary>

    /// <summary>
    /// CIKIS belgesinde lot TUKETIMI (satis irsaliyesi/faturasi, konsinye cikis,
    /// cikis fisi). Kullanici stoktaki lotlardan secer; her secim icin:
    ///
    ///  - kaynak izlem satirinin KALANI dusulur (yetmezse 422 - depoda olmayan
    ///    lottan mal cikamaz),
    ///  - cikisin kendi izlem satiri yazilir (donus_id = kaynak satir), boylece
    ///    "bu lot hangi belgeyle cikti" sorusu cevaplanabilir. Cikis satirinin
    ///    kalani 0'dir: o mal artik stokta degil.
    ///
    /// Kalan dusumu tek UPDATE icinde kosullu yapilir (kalan >= miktar): iki
    /// kullanici ayni lotu ayni anda tuketirse ikincisi hata alir, eksiye dusmez.
    /// </summary>
    private static async Task IzlemDusAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int satirId, int stokId, int sira, int belgeTur, int stokIzleme,
        decimal adet, List<JsonElement> izlemler, bool kalaniTasi,
        int? kaynakDepo, int? hedefDepo, CancellationToken iptal)
    {
        if (izlemler.Count == 0)
            throw GentegreHatasi.Dogrulama($"{sira}. satir icin lot secilmeli.",
                new AlanHatasi($"satirlar[{sira - 1}].izlemler", "İzlemli stok - çıkışta lot seçimi zorunlu."));

        decimal toplam = 0;
        foreach (var oge in izlemler)
        {
            var izlem  = JsonNesne(oge);
            var seriLotId = (int)JsonSayi(izlem, "seriLotId", 0);
            var miktar = JsonOndalik(izlem, "miktar", 0);

            if (seriLotId <= 0)
                throw GentegreHatasi.Dogrulama($"{sira}. satirda lot secimi gecersiz.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Stoktaki bir lot secilmeli."));
            if (miktar <= 0)
                throw GentegreHatasi.Dogrulama($"{sira}. satirdaki lot miktari sifirdan buyuk olmali.",
                    new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Miktar sifir olamaz."));

            toplam += miktar;
            await LottanDusAsync(baglanti, islem, belgeId, satirId, stokId, sira,
                                 belgeTur, stokIzleme, seriLotId, miktar, kalaniTasi,
                                 kaynakDepo, hedefDepo, iptal);
        }

        if (Math.Abs(toplam - adet) > 0.0001m)
            throw GentegreHatasi.Dogrulama(
                $"{sira}. satirda secilen lot toplami ({toplam:0.####}) miktarla ({adet:0.####}) ayni degil.",
                new AlanHatasi($"satirlar[{sira - 1}].izlemler", "Secilen lot miktarlari satir miktarina esit olmali."));
    }

    /// <summary>
    /// Secilen LOTTAN miktar kadar dusum. Bir lotun stogu birden fazla GIRIS
    /// hareketine dagilmis olabilir (ayni lot iki kez alinmis); tuketim giris
    /// sirasiyla (FIFO) yapilir ve tuketilen her giris icin bir cikis satiri
    /// yazilir (donus_id = tuketilen giris). Boylece "bu cikis hangi girisin
    /// malini goturdu" sorusu satir satir cevaplanabilir.
    /// </summary>

    /// <summary>
    /// Secilen LOTTAN miktar kadar dusum. Bir lotun stogu birden fazla GIRIS
    /// hareketine dagilmis olabilir (ayni lot iki kez alinmis); tuketim giris
    /// sirasiyla (FIFO) yapilir ve tuketilen her giris icin bir cikis satiri
    /// yazilir (donus_id = tuketilen giris). Boylece "bu cikis hangi girisin
    /// malini goturdu" sorusu satir satir cevaplanabilir.
    /// </summary>
    private static async Task LottanDusAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int satirId, int stokId, int sira, int belgeTur, int stokIzleme,
        int seriLotId, decimal miktar, bool kalaniTasi,
        int? kaynakDepo, int? hedefDepo, CancellationToken iptal)
    {
        // 1) YETERLILIK: tek dogruluk kaynagi lot bakiyesidir (stok_lot_durum,
        //    117). Eskiden izlem satirlarinin kalani toplanip bakiliyordu; o
        //    alan gocmus veride "zincir devri" anlamina geldigi icin depoda
        //    olmayan mali VAR gosterebiliyordu.
        if (kaynakDepo is { } depo)
        {
            await using var kontrol = new NpgsqlCommand("""
                select kalan from public.stok_lot_durum
                 where stok_id = @p0 and depo_id = @p1 and seri_lot_id = @p2
                 for update
                """, baglanti, islem);
            kontrol.Parameters.AddWithValue("p0", stokId);
            kontrol.Parameters.AddWithValue("p1", depo);
            kontrol.Parameters.AddWithValue("p2", seriLotId);
            var eldeki = await kontrol.ExecuteScalarAsync(iptal) is { } d and not DBNull
                ? Convert.ToDecimal(d) : 0m;
            if (eldeki < miktar)
                throw GentegreHatasi.IsKurali(
                    $"{sira}. satirda secilen lotta bu depoda {eldeki:0.####} kaldi, {miktar:0.####} istendi.");
        }

        // 2) ZINCIR: hangi girisin malinin gittigini izleyebilmek icin lotun
        //    giris hareketlerinden FIFO dusulur. Gocmus veride zincir eksik
        //    olabilir - bulunabildigi kadar dusulur, bakiye kontrolu zaten
        //    yukarida yapildi.
        var kalanIstek = miktar;
        var kaynaklar = new List<(int Id, decimal Kalan)>();
        await using (var komut = new NpgsqlCommand("""
            select id, kalan from public.stok_izleme
             where stok_id = @p0 and seri_lot_id = @p1 and kalan > 0
               and belge_tur not in (14, 15, 16, 119, 4, 29, 105, 133, 101)
               and (@p2::int is null or depo_id = @p2 or depo_id is null)
             order by id
             for update
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", seriLotId);
            komut.Parameters.AddWithValue("p2", (object?)kaynakDepo ?? DBNull.Value);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal))
                kaynaklar.Add((okuyucu.GetInt32(0), okuyucu.GetDecimal(1)));
        }

        var ilkKaynak = 0;
        foreach (var (kaynakId, kaynakKalan) in kaynaklar)
        {
            if (kalanIstek <= 0) break;
            var pay = Math.Min(kaynakKalan, kalanIstek);
            kalanIstek -= pay;
            if (ilkKaynak == 0) ilkKaynak = kaynakId;

            await using var dus = new NpgsqlCommand(
                "update public.stok_izleme set kalan = kalan - @p1 where id = @p0 and kalan >= @p1",
                baglanti, islem);
            dus.Parameters.AddWithValue("p0", kaynakId);
            dus.Parameters.AddWithValue("p1", pay);
            await dus.ExecuteNonQueryAsync(iptal);
        }

        // 3) HAREKET: cikisin kendi izlem satiri - tek satir, tam miktar.
        //    Transferde kalan TASINIR (mal stokta), cikista 0 (mal gitti).
        await using (var komut = new NpgsqlCommand("""
            insert into public.stok_izleme
                (stok_id, seri_lot_id, izlem_tur, belge_tur, belge_id, belge_satir_id,
                 adet, kalan, durum, donus_id, depo_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, 0, @p8, @p9, 0)
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", seriLotId);
            komut.Parameters.AddWithValue("p2", (short)stokIzleme);
            komut.Parameters.AddWithValue("p3", (short)belgeTur);
            komut.Parameters.AddWithValue("p4", belgeId);
            komut.Parameters.AddWithValue("p5", satirId);
            komut.Parameters.AddWithValue("p6", miktar);
            komut.Parameters.AddWithValue("p7", kalaniTasi ? miktar : 0m);
            komut.Parameters.AddWithValue("p8", ilkKaynak);
            komut.Parameters.AddWithValue("p9", (object?)hedefDepo ?? DBNull.Value);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        // 4) BAKIYE: kaynak depodan duser; transferde hedef depoya eklenir.
        if (kaynakDepo is { } kd)
            await LotDurumYazAsync(baglanti, islem, stokId, kd, seriLotId, -miktar, iptal);
        if (kalaniTasi && hedefDepo is { } hd)
            await LotDurumYazAsync(baglanti, islem, stokId, hd, seriLotId, miktar, iptal);
    }

    /// <summary>
    /// Lot bakiyesini (117) degistirir: stok x depo x lot basina tek satir.
    /// Belge kaydinda stok_durum ile AYNI anda yurur - biri artarken digeri
    /// artmazsa lot dokumu depo miktariyla ayrisir.
    /// </summary>

    /// <summary>
    /// Lot bakiyesini (117) degistirir: stok x depo x lot basina tek satir.
    /// Belge kaydinda stok_durum ile AYNI anda yurur - biri artarken digeri
    /// artmazsa lot dokumu depo miktariyla ayrisir.
    /// </summary>
    private static async Task LotDurumYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int stokId, int depoId, int seriLotId, decimal degisim, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            insert into public.stok_lot_durum (stok_id, depo_id, seri_lot_id, kalan)
            values (@p0, @p1, @p2, @p3)
            on conflict (stok_id, depo_id, seri_lot_id) do update
               set kalan = stok_lot_durum.kalan + excluded.kalan
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", stokId);
        komut.Parameters.AddWithValue("p1", depoId);
        komut.Parameters.AddWithValue("p2", seriLotId);
        komut.Parameters.AddWithValue("p3", degisim);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    /// <summary>Stok kartindaki izleme turu (0 = izlemsiz).</summary>

    /// <summary>Stok kartindaki izleme turu (0 = izlemsiz).</summary>
    private static async Task<int> StokIzlemeTuruAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int stokId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select izleme from public.stok where id = @p0", baglanti, islem);
        komut.Parameters.AddWithValue("p0", stokId);
        var sonuc = await komut.ExecuteScalarAsync(iptal);
        return sonuc is null or DBNull ? 0 : Convert.ToInt32(sonuc);
    }

    /// <summary>
    /// Lot kimligini bulur, yoksa acar (114'teki benzersiz kimlik: stok + lot + seri).
    /// Var olan lotun tarihleri BOSSA doldurulur, DOLUYSA korunur: ilk giristeki
    /// uretim/SKT bilgisi dogru kabul edilir, sonraki girisin farkli yazmasi
    /// gecmisi degistirmemeli.
    /// </summary>

    /// <summary>
    /// Lot kimligini bulur, yoksa acar (114'teki benzersiz kimlik: stok + lot + seri).
    /// Var olan lotun tarihleri BOSSA doldurulur, DOLUYSA korunur: ilk giristeki
    /// uretim/SKT bilgisi dogru kabul edilir, sonraki girisin farkli yazmasi
    /// gecmisi degistirmemeli.
    /// </summary>
    private static async Task<int> SeriLotIdAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int stokId, string lotNo, string seriNo,
        DateTime? uretim, DateTime? skt, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            insert into public.stok_seri_lot (stok_id, lot_no, seri_no, uretim_tarihi, son_kullanma_tarihi)
            values (@p0, @p1, @p2, @p3, @p4)
            on conflict (stok_id, lot_no, seri_no) do update
               set uretim_tarihi = coalesce(public.stok_seri_lot.uretim_tarihi, excluded.uretim_tarihi),
                   son_kullanma_tarihi = coalesce(public.stok_seri_lot.son_kullanma_tarihi,
                                                  excluded.son_kullanma_tarihi)
            returning id
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", stokId);
        komut.Parameters.AddWithValue("p1", lotNo);
        komut.Parameters.AddWithValue("p2", seriNo);
        komut.Parameters.AddWithValue("p3", (object?)uretim ?? DBNull.Value);
        komut.Parameters.AddWithValue("p4", (object?)skt ?? DBNull.Value);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));
    }

    private async Task StokDurumGuncelleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, int tipi, bool stokKontrolu, List<string> uyarilar,
        CancellationToken iptal)
    {
        // IADEDE YON TERS: satis iadesinde mal depoya GERI GIRER (132).
        var cikis = BelgeTuru.CikisMi(tur, tipi);
        var transfer = BelgeTuru.TransferMi(tur);
        // Ayar belge basina BIR KEZ okunur (60 sn onbellekli) - satir basina degil.
        var negatifDavranis = await AyarDeposu.SayiAsync(baglanti, islem,
                                                        "stok.negatif_davranis", iptal);

        // stok_durum_degis = 0 olan satirlar stok bakiyesini ETKILEMEZ.
        // Transferde IKI depo da okunur: satir cikis deposundan duser, giris
        //   deposuna eklenir - tek satir iki hareket uretir.
        await using var oku = new NpgsqlCommand("""
            select s.stok_id, s.miktar, s.adet,
                   coalesce(s.cikis_depo_id, b.cikis_depo_id) as cikis_depo_id,
                   coalesce(s.giris_depo_id, b.giris_depo_id) as giris_depo_id
              from public.belge_satir s
              join public.belge b on b.id = s.belge_id
             where s.belge_id = @p0 and s.tur = 1 and s.stok_id is not null
               and s.stok_durum_degis = 1
            """, baglanti, islem);
        oku.Parameters.AddWithValue("p0", belgeId);

        var hareketler = new List<(int StokId, decimal Miktar, int? CikisDepo, int? GirisDepo)>();
        await using (var okuyucu = await oku.ExecuteReaderAsync(iptal))
            while (await okuyucu.ReadAsync(iptal))
            {
                var miktar = okuyucu.GetDecimal(okuyucu.GetOrdinal("miktar"));
                if (miktar == 0) miktar = okuyucu.GetDecimal(okuyucu.GetOrdinal("adet"));
                hareketler.Add((okuyucu.Sayi("stok_id"), miktar,
                                okuyucu.SayiNull("cikis_depo_id"), okuyucu.SayiNull("giris_depo_id")));
            }

        foreach (var (stokId, miktar, cikisDepo, girisDepo) in hareketler)
        {
            if (transfer)
            {
                if (cikisDepo is null || girisDepo is null)
                    throw GentegreHatasi.Dogrulama("Transferde çıkış ve giriş deposu seçilmeli.",
                        new AlanHatasi(cikisDepo is null ? "cikisDepoId" : "girisDepoId", "Zorunlu."));
                if (cikisDepo == girisDepo)
                    throw GentegreHatasi.IsKurali("Çıkış ve giriş deposu aynı olamaz.");

                await DepoyaYazAsync(baglanti, islem, stokId, cikisDepo.Value, 0m, miktar,
                                     stokKontrolu, negatifDavranis, uyarilar, iptal);
                await DepoyaYazAsync(baglanti, islem, stokId, girisDepo.Value, miktar, 0m,
                                     stokKontrolu, negatifDavranis, uyarilar, iptal);
                continue;
            }

            // Normal belge: yon TURDEN gelir, depo satirda hangisi doluysa o.
            var depoId = cikis ? cikisDepo ?? girisDepo : girisDepo ?? cikisDepo;
            if (depoId is null) continue;

            await DepoyaYazAsync(baglanti, islem, stokId, depoId.Value,
                                 cikis ? 0m : miktar, cikis ? miktar : 0m,
                                 stokKontrolu, negatifDavranis, uyarilar, iptal);
        }
    }

    /// <summary>
    /// Tek depo satirini gunceller (yoksa acar). Bakiye eksiye duserse ne
    /// olacagini AYAR belirler (stok.negatif_davranis, db/107):
    /// 0 serbest / 1 uyar / 2 engelle. Eskiden her zaman "uyar" idi.
    /// </summary>

    /// <summary>
    /// Tek depo satirini gunceller (yoksa acar). Bakiye eksiye duserse ne
    /// olacagini AYAR belirler (stok.negatif_davranis, db/107):
    /// 0 serbest / 1 uyar / 2 engelle. Eskiden her zaman "uyar" idi.
    /// </summary>
    private static async Task DepoyaYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int stokId, int depoId, decimal giren, decimal cikan,
        bool stokKontrolu, int negatifDavranis, List<string> uyarilar, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan)
            values (@p0, @p1, @p2, @p3, @p2 - @p3)
            on conflict (stok_id, depo_id) do update
               set giren = stok_durum.giren + excluded.giren,
                   cikan = stok_durum.cikan + excluded.cikan,
                   kalan = stok_durum.kalan + excluded.giren - excluded.cikan
            returning kalan
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", stokId);
        komut.Parameters.AddWithValue("p1", depoId);
        komut.Parameters.AddWithValue("p2", giren);
        komut.Parameters.AddWithValue("p3", cikan);

        var kalan = Convert.ToDecimal(await komut.ExecuteScalarAsync(iptal) ?? 0m);
        if (!stokKontrolu || kalan >= 0 || negatifDavranis == 0) return;

        if (negatifDavranis >= 2)
            throw GentegreHatasi.IsKurali(
                $"Stok bakiyesi yetersiz: bu depoda {kalan:0.####} kalıyor. " +
                "Önce giriş yapılmalı (Genel Ayarlar > Stok: negatif stok engelli).");

        uyarilar.Add($"Stok {stokId} deposunda bakiye negatife dustu ({kalan}).");
    }
}
