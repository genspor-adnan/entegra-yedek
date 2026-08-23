using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Belge kaydetme (API §4) - Faz 1'in kalbi. HEPSI YA DA HICBIRI: numara,
/// satirlar, stok durumu, cari hareket ve islem_log TEK TRANSACTION icinde yazilir.
///
/// Sira onemli - belge NUMARASI EN SON alinir: numara alan transaction rollback
/// olursa o numara BOSLUGA DUSER (e-Belge boslukluk kabul etmez). Once her sey
/// dogrulanir ve yazilir, numara en sonda satir kilidi altinda uretilir.
/// </summary>
public sealed class BelgeDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    // ISLEMLOG tablo kodlari (GENINI -11110): 30 = Fatbaslik
    private const int LogTabloBelge = 30;

    public BelgeDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>
    /// Stok CIKISI yonundeki belgeler. Cari tarafi olanlarda ayni zamanda
    /// "satis" demektir (cari BORCLANIR); cikis fisinde (4) cari yoktur, yalniz
    /// stok yonunu belirler. Alis/giris belgelerinde tam tersi.
    /// </summary>
    private static bool SatisMi(int tur) => tur is 14 or 15 or 16 or 119 or 29 or 105 or 133 or 4;

    /// <summary>
    /// Depolar arasi transfer (tur 20): TEK satir IKI depoyu birden oynatir -
    /// cikis deposundan duser, giris deposuna ekler. Cari yoktur, mal firmada kalir.
    /// </summary>
    private static bool TransferMi(int tur) => tur == 20;

    /// <summary>
    /// Stoktan talep (tur 105): bir birim depodan mal ISTER. Stok ve cari
    /// etkilemez - asil hareketi, talep karsilaninca kesilen transfer yapar.
    /// Zorunlusu: istenen depo + talep eden kisi.
    /// </summary>
    private static bool TalepMi(int tur) => tur == 105;

    /// <summary>
    /// Stok fisleri: 3 giris / 4 cikis. Irsaliye gibi calisir (stok oynar,
    /// miktar + birim fiyat girilir) ama CARI YOKTUR - karsilik gider/gelir
    /// hesabidir, o yuzden muhasebe fisi uretirler (fis_mi=1).
    /// TIPI fisin sebebini tasir (fire/sarf/imha/sayim...) ve zorunludur:
    /// muhasebe hesabi ona gore secilecek (F7).
    /// </summary>
    private static bool StokFisiMi(int tur) => tur is 3 or 4;

    /// <summary>
    /// Numarasi BIZDE degil, KARSI TARAFTA uretilen belge turleri. Alis faturasinin
    /// numarasi tedarikcinin fatura numarasidir: harf/tire icerebilir, bizim
    /// sayacimizla iliskisi yoktur (sayac tohumu eski veriden geldigi icin
    /// "3012026000357895" gibi anlamsiz numaralar uretiyordu). Kullanici girer.
    ///
    /// Alis irsaliyesi (10) ve alis fisi (12) simdilik DISARIDA: onlarin sayaci
    /// temiz calisiyor, ayni degisiklik istenirse buraya eklenir.
    /// </summary>
    private static bool DisNumaraliTur(int tur) => tur is 11;

    /// <summary>
    /// Ayni tedarikciden ayni numarayi ikinci kez girmeyi engeller (mukerrer alis
    /// faturasi = cari ve KDV iki kere). DB'de UNIQUE degil: eski goc verisinde
    /// zaten mukerrer satirlar var, kisit onlari reddedip guncellemeyi kilitlerdi.
    /// </summary>
    private static async Task MukerrerNoKontrolAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int tur, int tarafId, string belgeNo, int haricId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            select id from public.belge
             where tur = @p0 and taraf_id = @p1 and belge_no = @p2
               and durum <> 2 and id <> @p3
             limit 1
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", tur);
        komut.Parameters.AddWithValue("p1", tarafId);
        komut.Parameters.AddWithValue("p2", belgeNo);
        komut.Parameters.AddWithValue("p3", haricId);
        if (await komut.ExecuteScalarAsync(iptal) is { } varOlan and not DBNull)
            throw GentegreHatasi.IsKurali(
                $"Bu cariden \"{belgeNo}\" numarali belge zaten kayitli (#{varOlan}).");
    }

    public async Task<(int Id, List<string> Uyarilar)> KaydetAsync(
        IDictionary<string, object?> belge,
        List<Dictionary<string, JsonElement>> satirlar,
        BelgeSecenekleri secenekler,
        YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var (id, uyarilar) = await KaydetIcAsync(baglanti, islem, belge, satirlar, secenekler, baglam, iptal);

        await islem.CommitAsync(iptal);
        return (id, uyarilar);
    }

    /// <summary>
    /// Kaydetmenin TRANSACTION ICI cekirdegi. Donusum (F8) kaynak satirlari
    /// kilitledikten SONRA ayni transaction'da buraya girer - yoksa iki es
    /// zamanli donusum ayni kalani iki kez tuketirdi.
    /// </summary>
    private async Task<(int Id, List<string> Uyarilar)> KaydetIcAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IDictionary<string, object?> belge,
        List<Dictionary<string, JsonElement>> satirlar,
        BelgeSecenekleri secenekler,
        YazmaBaglami baglam,
        CancellationToken iptal,
        bool cariAtla = false)
    {
        var uyarilar = new List<string>();

        var tur = Sayi(belge, "tur");
        var tarafId = Sayi(belge, "tarafId");
        // Cari her belgede zorunlu DEGIL: depolar arasi transferde (20) karsi taraf
        //   yoktur, mal firmanin kendi depolari arasinda gezer. Zorunluluk katalogtan
        //   okunur (kasa_islem_turu.cari_zorunlu), koda gomulmez.
        var cariZorunlu = await CariZorunluMuAsync(baglanti, islem, tur, iptal);
        if (tarafId <= 0 && cariZorunlu)
            throw GentegreHatasi.Dogrulama("Cari secilmeli.", new AlanHatasi("tarafId", "Zorunlu."));
        if (satirlar.Count == 0)
            throw GentegreHatasi.Dogrulama("Belgede en az bir satir olmali.",
                new AlanHatasi("satirlar", "Bos birakilamaz."));

        // Transferde SORUMLULUK DEVRI kayda gecer: mali kim verdi, kim aldi.
        //   Iki depo arasinda kaybolan malin hesabi bu iki isimden sorulur -
        //   bu yuzden ikisi de zorunlu ve birbirinden farkli olmali.
        if (StokFisiMi(tur))
        {
            if (Sayi(belge, "tipi") <= 0)
                throw GentegreHatasi.Dogrulama("Fiş tipi seçilmeli.",
                    new AlanHatasi("tipi", "Zorunlu."));

            var depoAlani = SatisMi(tur) ? "cikisDepoId" : "girisDepoId";
            if (Sayi(belge, depoAlani) <= 0)
                throw GentegreHatasi.Dogrulama("Depo seçilmeli.",
                    new AlanHatasi(depoAlani, "Zorunlu."));
        }

        if (TalepMi(tur))
        {
            if (Sayi(belge, "cikisDepoId") <= 0)
                throw GentegreHatasi.Dogrulama("İstenen depo seçilmeli.",
                    new AlanHatasi("cikisDepoId", "Zorunlu."));
            // Talep eden, mali TESLIM ALACAK kisidir - ayni kolonda tutulur.
            if (Sayi(belge, "teslimAlanId") <= 0)
                throw GentegreHatasi.Dogrulama("Talep eden seçilmeli.",
                    new AlanHatasi("teslimAlanId", "Zorunlu."));
        }

        if (TransferMi(tur))
        {
            if (Sayi(belge, "teslimEdenId") <= 0)
                throw GentegreHatasi.Dogrulama("Teslim eden seçilmeli.",
                    new AlanHatasi("teslimEdenId", "Zorunlu."));
            if (Sayi(belge, "teslimAlanId") <= 0)
                throw GentegreHatasi.Dogrulama("Teslim alan seçilmeli.",
                    new AlanHatasi("teslimAlanId", "Zorunlu."));
            if (Sayi(belge, "teslimEdenId") == Sayi(belge, "teslimAlanId"))
                throw GentegreHatasi.IsKurali("Teslim eden ve teslim alan aynı kişi olamaz.");
        }

        // ------------------------------------------------- 0) BELGE TARIHI kurali ----
        // TUM belge turlerinde gecerli (kullanici karari): belge ILERI TARIHLI
        //   kesilemez ve 7 GUNDEN eskiye girilemez. Gerekce: stok ve cari bakiye
        //   gecmise donuk degistirilirse kapanmis gunun raporu tutmaz; ileri tarih
        //   ise e-Belge'de GIB tarafindan zaten reddedilir.
        //   Saat de tasinir: ayni gun icindeki hareket sirasi (stok dokumu) buna gore.
        BelgeTarihiKontrol(belge);

        // ---------------------------------------------- 1) taraf bilgisini DONDUR ----
        // Belge, kartin O ANDAKI halini tasir: kart sonradan degisse de belge degismez.
        //   tarafUnvan <- fatura_unvan (bos ise unvan). Istekte acikca gonderildiyse
        //   kullanicinin yazdigi deger kabul edilir (sozlesme §4/2).
        if (tarafId > 0)
        await using (var komut = new NpgsqlCommand("""
            select t.unvan, t.fatura_unvan, t.vkno, t.vd
              from public.taraf t where t.id = @p0
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", tarafId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi("Cari kayit bulunamadi.");

            var unvan = okuyucu.Metin("unvan");
            var faturaUnvan = okuyucu.Metin("fatura_unvan");
            Varsayilan(belge, "tarafUnvan", faturaUnvan.Length > 0 ? faturaUnvan : unvan);
            Varsayilan(belge, "tarafVkno", okuyucu.Metin("vkno"));
            Varsayilan(belge, "tarafVd", okuyucu.Metin("vd"));
        }

        var adresId = Sayi(belge, "tarafAdresId");
        if (adresId > 0)
        {
            await using var komut = new NpgsqlCommand("""
                select adres, ilce, il from public.taraf_adres where id = @p0 and taraf_id = @p1
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", adresId);
            komut.Parameters.AddWithValue("p1", tarafId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (await okuyucu.ReadAsync(iptal))
            {
                Varsayilan(belge, "tarafAdres", okuyucu.Metin("adres"));
                Varsayilan(belge, "tarafIlce", okuyucu.Metin("ilce"));
                Varsayilan(belge, "tarafIl", okuyucu.Metin("il"));
            }
        }

        // -------------------------------------- 2) gonderici (sube) kimligini DONDUR ----
        // 022 karari: her subenin kendi VKN/VD'si olabilir, belge o kimlikle gider.
        if (baglam.SubeId is { } subeId)
        {
            await using var komut = new NpgsqlCommand("""
                select coalesce(nullif(unvan, ''), ad) as unvan, vkno, efatura_alias, ebelge_seri
                  from public.sube where id = @p0
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", subeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (await okuyucu.ReadAsync(iptal))
            {
                Varsayilan(belge, "gondericiUnvan", okuyucu.Metin("unvan"));
                Varsayilan(belge, "gondericiVkno", okuyucu.Metin("vkno"));
                Varsayilan(belge, "gondericiAlias", okuyucu.Metin("efatura_alias"));
                if (Metin(belge, "belgeSeri").Length == 0)
                    Varsayilan(belge, "belgeSeri", okuyucu.Metin("ebelge_seri"));
            }
            belge["subeId"] = subeId;
        }

        // Doviz: TL islemde de dolu (026 karari)
        var belgeDovizi = Metin(belge, "belgeDovizi");
        if (belgeDovizi.Length == 0) { belgeDovizi = "TL"; belge["belgeDovizi"] = belgeDovizi; }
        var kur = Ondalik(belge, "dovizKuru");
        if (kur <= 0) { kur = 1m; belge["dovizKuru"] = kur; }
        if (Metin(belge, "kur").Length == 0) belge["kur"] = belgeDovizi;
        if (Metin(belge, "raporDovizi").Length == 0) belge["raporDovizi"] = belgeDovizi;
        if (Metin(belge, "kdvDurum").Length == 0) belge["kdvDurum"] = "Hariç";

        // ------------------------------------------------- 3) belge NUMARASI kimin ----
        // Alis faturasinin numarasi TEDARIKCININDIR: bizim sayacimiz uretemez
        //   (uretirse mukerrer/anlamsiz numara olur, e-Fatura eslesmesi kirilir).
        //   Kullanici girer, biz yalniz bosluk ve ayni tedarikciden mukerrer
        //   girisi kontrol ederiz. Diger turlerde numara EN SON, sayactan.
        var disNumara = DisNumaraliTur(tur);
        var girilenNo = Metin(belge, "belgeNo").Trim();

        if (disNumara)
        {
            if (girilenNo.Length == 0 && !secenekler.Taslak)
                throw GentegreHatasi.Dogrulama("Tedarikçi belge numarası girilmeli.",
                    new AlanHatasi("belgeNo", "Zorunlu."));
            if (girilenNo.Length > 0)
                await MukerrerNoKontrolAsync(baglanti, islem, tur, tarafId, girilenNo, 0, iptal);
            belge["belgeNo"] = girilenNo;
        }
        else
        {
            // Numara TASLAKTA alinmaz, kesinlestirmede de EN SON alinir (asagida).
            belge["belgeNo"] = "";
        }

        belge["durum"] = secenekler.Taslak ? 1 : 0;
        var belgeId = await BelgeEkleAsync(baglanti, islem, belge, baglam, iptal);

        // ------------------------------------------------------ 4) satirlar INSERT ----
        // Tur etkisi satirlardan ONCE okunur: stogu etkilemeyen bir belgede
        //   (siparis/teklif) satirin stok_durum_degis bayragi da 0 yazilmali -
        //   yoksa satir "stok dusurdum" diye isaretli kalir ve iptal/donusum gibi
        //   sonraki isler yanlis karar verir.
        var etki = await TurEtkileriAsync(baglanti, islem, tur, iptal);

        var sira = 0;
        foreach (var satir in satirlar)
        {
            sira++;
            await SatirEkleAsync(baglanti, islem, belgeId, sira, satir, belge, baglam,
                                 etki.Stok, uyarilar, iptal);
        }

        // ------------------------------------------------------------ 5) toplamlar ----
        // Tutarlar dip toplam formulunden gelir - Delphi ile birebir dogrulanmis
        //   fonksiyon (024). Toplami burada yeniden hesaplamak iki ayri dogruluk
        //   kaynagi yaratir; tek kaynak fn_belge_diptoplam'dir.
        await ToplamlariYazAsync(baglanti, islem, belgeId, iptal);

        // ----------------------------------------------- 6) stok durumu + hareket ----
        // HANGI belge turunun neyi etkiledigi KATALOGTA (kasa_islem_turu):
        //   siparis/teklif/talep bir TAAHHUTTUR - ne mal cikar ne cari borclanir.
        //   Irsaliyeden turetilen faturada stok TEKRAR dusmez (satir bazinda
        //   stok_durum_degis=0 yazilir, asagidaki sorgu onu zaten atlar).
        if (!secenekler.Taslak)
        {
            var (stokEtkiler, cariEtkiler) = etki;

            if (stokEtkiler)
                await StokDurumGuncelleAsync(baglanti, islem, belgeId, tur, secenekler.StokKontrolu, uyarilar, iptal);
            // cariAtla: kaynak belge (irsaliye) cariyi ZATEN borclandirdi - ondan
            //   turetilen fatura ikinci kez yazarsa cari bakiye ikiye katlanir.
            //   Stok tarafinda ayni koruma satir bazinda (stok_durum_degis=0) var.
            if (cariEtkiler && !cariAtla)
                await MaliHareketYazAsync(baglanti, islem, belgeId, tur, tarafId, baglam, iptal);

            // ------------------------------------------------------- 7) belge NUMARASI ----
            // EN SON: buraya kadar her sey basarili. Satir kilidi altinda, BOSLUKSUZ.
            // Dis numarali belgede (alis faturasi) numara kullanicidan geldi.
            if (!disNumara)
                await NumaraVerAsync(baglanti, islem, belgeId, tur, Metin(belge, "belgeSeri"), baglam.SubeId, iptal);
        }

        // ------------------------------------------------------------------ 8) log ----
        await _log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
                ["tarafId"] = tarafId.ToString(CultureInfo.InvariantCulture),
                ["satirAdedi"] = satirlar.Count.ToString(CultureInfo.InvariantCulture),
                ["taslak"] = secenekler.Taslak ? "1" : "0"
            },
            tarafId: tarafId, iptal: iptal);

        return (belgeId, uyarilar);
    }

    // ============================================================== donusum ====
    /// <summary>
    /// Siparis -> irsaliye -> fatura donusumu (F8).
    ///
    /// SIPARIS AYRI TABLO DEGILDIR: ayni `belge` tablosunun turudur, bu yuzden
    /// donusum de ayni kayit yolundan (KaydetIcAsync) gecer - stok, cari, numara
    /// ve toplam mantigi TEK yerde kalir.
    ///
    /// Kaynak satirlar `for update` ile KILITLENIR ve kalan miktar ayni
    /// transaction icinde kontrol edilir; iki kullanici ayni siparisi es zamanli
    /// donusturemez. Hedef satirlar `kaynak_tur=30, kaynak_id=<kaynak satir>` ile
    /// yazilir - kapatilan_miktar sayacini DB trigger'i gunceller.
    /// </summary>
    public async Task<(int Id, List<string> Uyarilar)> DonusturAsync(
        int kaynakBelgeId, int hedefTur,
        IReadOnlyList<(int SatirId, decimal Miktar)> secilen,
        DateTime? belgeTarihi, bool taslak,
        YazmaBaglami baglam, CancellationToken iptal = default,
        string? belgeNo = null)
    {
        if (secilen.Count == 0)
            throw GentegreHatasi.Dogrulama("Dönüştürülecek satır seçilmeli.",
                new AlanHatasi("satirlar", "Boş bırakılamaz."));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // ------------------------------------------------- 1) kaynak baslik ----
        IDictionary<string, object?> kaynak;
        await using (var komut = new NpgsqlCommand("""
            select b.id, b.tur, b.tipi, b.taraf_id, b.taraf_unvan, b.taraf_vkno, b.taraf_vd,
                   b.taraf_adres_id, b.belge_dovizi, b.doviz_kuru, b.kdv_durum, b.durum,
                   b.proje_id, b.sube_id, b.vade_gun, b.giris_depo_id, b.cikis_depo_id,
                   b.satici_id, b.ozel_kod, b.aciklama, b.belge_no, kt.ad as tur_adi
              from public.belge b
              left join public.kasa_islem_turu kt on kt.kod = b.tur
             where b.id = @p0
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", kaynakBelgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Kaynak belge bulunamadı.");
            kaynak = Satir(o);
        }

        if (Convert.ToInt32(kaynak["durum"]) != 0)
            throw GentegreHatasi.IsKurali("Yalnız kesinleşmiş belge dönüştürülebilir (taslak/iptal değil).");

        if (baglam.SubeId is { } sube && kaynak["sube_id"] is { } ks && Convert.ToInt32(ks) != sube)
            throw GentegreHatasi.Bulunamadi();

        var hedefEtki = await TurEtkileriAsync(baglanti, islem, hedefTur, iptal);

        // -------------------------- 2) kaynak satirlari KILITLE + kalan kontrol ----
        var satirlar = new List<Dictionary<string, JsonElement>>();
        var idler = secilen.Select(s => s.SatirId).ToArray();

        var kaynakSatirlar = new Dictionary<int, IDictionary<string, object?>>();
        await using (var komut = new NpgsqlCommand("""
            select s.id, s.tur, s.stok_id, s.hizmet_id, s.masraf_id, s.aciklama,
                   s.miktar, s.adet, s.birim, s.birim_fiyat, s.iskonto, s.iskonto2,
                   s.kdv, s.otv_yuzde, s.otv_miktar, s.kdv_muafiyeti,
                   s.doviz_cinsi, s.doviz_birim_fiyat, s.doviz_kuru,
                   s.giris_depo_id, s.cikis_depo_id, s.izleme, s.izleme_kodu,
                   s.stok_durum_degis, s.proje_id, s.kalan_miktar, s.belge_id
              from public.belge_satir s
             where s.id = any(@p0)
             order by s.sira
             for update
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", idler);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
            {
                var satir = Satir(o);
                kaynakSatirlar[Convert.ToInt32(satir["id"])] = satir;
            }
        }

        foreach (var (satirId, miktar) in secilen)
        {
            if (!kaynakSatirlar.TryGetValue(satirId, out var ks2))
                throw GentegreHatasi.Bulunamadi($"Kaynak satır bulunamadı: {satirId}");
            if (Convert.ToInt32(ks2["belge_id"]) != kaynakBelgeId)
                throw GentegreHatasi.Dogrulama("Satır bu belgeye ait değil.",
                    new AlanHatasi($"satirlar[{satirId}]", "Başka belgenin satırı."));

            var kalan = Convert.ToDecimal(ks2["kalan_miktar"] ?? 0m);
            if (miktar <= 0)
                throw GentegreHatasi.Dogrulama("Miktar sıfırdan büyük olmalı.",
                    new AlanHatasi($"satirlar[{satirId}].miktar", "Sıfırdan büyük olmalı."));
            if (miktar > kalan)
                throw GentegreHatasi.IsKurali(
                    $"Seçilen miktar kalanı aşıyor (istenen {miktar:0.####}, kalan {kalan:0.####}).");

            // Kaynak satir zaten stok dusurduyse (irsaliye) hedef TEKRAR dusurmez.
            var kaynakDusurdu = Convert.ToInt32(ks2["stok_durum_degis"] ?? 0) == 1
                                && Convert.ToInt32(kaynak["tur"]) is var kt2
                                && await StokEtkilerMiAsync(baglanti, islem, kt2, iptal);

            satirlar.Add(SatirJson(ks2, miktar, satirId,
                stokDurumDegis: hedefEtki.Stok && !kaynakDusurdu ? 1 : 0));
        }

        // --------------------------------------------------- 3) hedef baslik ----
        var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["tur"] = hedefTur,
            ["tipi"] = kaynak["tipi"],
            ["tarafId"] = kaynak["taraf_id"],
            ["tarafUnvan"] = kaynak["taraf_unvan"],
            ["tarafVkno"] = kaynak["taraf_vkno"],
            ["tarafVd"] = kaynak["taraf_vd"],
            ["tarafAdresId"] = kaynak["taraf_adres_id"],
            ["belgeTarihi"] = belgeTarihi ?? DateTime.Now,
            ["belgeDovizi"] = kaynak["belge_dovizi"],
            ["dovizKuru"] = kaynak["doviz_kuru"],
            ["kdvDurum"] = kaynak["kdv_durum"],
            ["projeId"] = kaynak["proje_id"],
            ["vadeGun"] = kaynak["vade_gun"],
            ["girisDepoId"] = kaynak["giris_depo_id"],
            ["cikisDepoId"] = kaynak["cikis_depo_id"],
            ["saticiId"] = kaynak["satici_id"],
            ["ozelKod"] = kaynak["ozel_kod"],
            ["aciklama"] = Kirp($"{kaynak["tur_adi"]} {kaynak["belge_no"]} dönüşümü", 200),
        };

        // Dis numarali hedefte (alis faturasi) numarayi kullanici verir - kaynagin
        //   irsaliye numarasi kopyalanmaz, sayac da uretmez.
        if (DisNumaraliTur(hedefTur)) belge["belgeNo"] = (belgeNo ?? "").Trim();

        // Kaynak turu cariyi zaten etkilediyse (irsaliye) hedef TEKRAR etkilemez;
        //   yalniz kaynagin etkilemedigi durumda (siparis) fatura/irsaliye yazar.
        var kaynakCariYazdi = (await TurEtkileriAsync(
            baglanti, islem, Convert.ToInt32(kaynak["tur"]), iptal)).Cari;

        var (yeniId, uyarilar) = await KaydetIcAsync(baglanti, islem, belge, satirlar,
            new BelgeSecenekleri { Taslak = taslak, StokKontrolu = true }, baglam, iptal,
            cariAtla: kaynakCariYazdi);

        // ------------------------------------------------ 4) baslik bagi + log ----
        // Satir bagi kapatma sayacini surer; baslik bagi "bu belge sundan turedi"
        //   sorusunun tek sorguluk cevabidir.
        await using (var komut = new NpgsqlCommand(
            "update public.belge set kaynak_tur = 30, kaynak_id = @p1 where id = @p0", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", yeniId);
            komut.Parameters.AddWithValue("p1", (long)kaynakBelgeId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, kaynakBelgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "donustur",
                ["hedefTur"] = hedefTur.ToString(CultureInfo.InvariantCulture),
                ["hedefBelgeId"] = yeniId.ToString(CultureInfo.InvariantCulture),
                ["satirAdedi"] = secilen.Count.ToString(CultureInfo.InvariantCulture)
            },
            tarafId: SayiNull(kaynak, "taraf_id"), iptal: iptal);

        await islem.CommitAsync(iptal);
        return (yeniId, uyarilar);
    }

    /// <summary>Acik (kalani olan) satirlar - donusum ekraninin kaynagi.</summary>
    public async Task<List<IDictionary<string, object?>>> AcikSatirlarAsync(
        int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select v.satir_id as "satirId", v.sira, v.satir_tur as "satirTur",
                   v.stok_id as "stokId", v.stok_kodu as "stokKodu", v.stok_adi as "stokAdi",
                   v.hizmet_id as "hizmetId", v.masraf_id as "masrafId", v.aciklama,
                   v.miktar, v.kapatilan_miktar as "kapatilanMiktar",
                   v.kalan_miktar as "kalanMiktar", v.birim,
                   v.birim_fiyat as "birimFiyat", v.iskonto, v.kdv,
                   v.belge_tur as "belgeTur", v.belge_tur_adi as "belgeTurAdi",
                   v.belge_no as "belgeNo", v.taraf_unvan as "tarafUnvan",
                   v.belge_dovizi as "belgeDovizi", v.kapanma_durum as "kapanmaDurum"
              from public.v_belge_acik_satir v
             where v.belge_id = @p0 order by v.sira
            """, baglanti);
        komut.Parameters.AddWithValue("p0", belgeId);

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(Satir(o));
        return liste;
    }

    /// <summary>
    /// Bu belgeden TURETILMIS belgeler (irsaliye kartinin Faturalama sekmesi).
    /// Satir bagindan gruplanir: bir irsaliye birden fazla faturaya bolunebilir.
    /// </summary>
    public async Task<List<IDictionary<string, object?>>> DonusumlerAsync(
        int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select hb.id                       as "belgeId",
                   hb.belge_no                 as "belgeNo",
                   hb.belge_tarihi             as "belgeTarihi",
                   coalesce(ht.ad, '')         as "turAdi",
                   hb.taraf_unvan              as "tarafUnvan",
                   sum(hs.miktar)              as miktar,
                   sum(hs.tutar)               as tutar,
                   hb.durum,
                   case hb.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end as "durumAdi"
              from public.belge_satir hs
              join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
              join public.belge hb       on hb.id = hs.belge_id
              left join public.kasa_islem_turu ht on ht.kod = hb.tur
             where ks.belge_id = @p0
             group by hb.id, hb.belge_no, hb.belge_tarihi, ht.ad, hb.taraf_unvan, hb.durum
             order by hb.belge_tarihi, hb.id
            """, baglanti);
        komut.Parameters.AddWithValue("p0", belgeId);

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(Satir(o));
        return liste;
    }

    /// <summary>Belge turunun stok/cari etkisi - katalogtan (kasa_islem_turu).</summary>
    private static async Task<(bool Stok, bool Cari)> TurEtkileriAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, int tur, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select stok_etkiler, cari_etkiler from public.kasa_islem_turu where kod = @p0",
            baglanti, islem);
        komut.Parameters.AddWithValue("p0", (short)tur);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        // Katalogda olmayan tur: eski davranis (ikisini de etkiler).
        if (!await o.ReadAsync(iptal)) return (true, true);
        return (o.Bayrak("stok_etkiler"), o.Bayrak("cari_etkiler"));
    }

    private static async Task<bool> StokEtkilerMiAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int tur, CancellationToken iptal)
        => (await TurEtkileriAsync(baglanti, islem, tur, iptal)).Stok;

    /// <summary>Belge tarihi penceresi: bugunden ileri YOK, 7 gunden eski YOK.</summary>
    private const int GeriyeGunSiniri = 7;

    private static void BelgeTarihiKontrol(IDictionary<string, object?> belge)
    {
        if (!belge.TryGetValue("belgeTarihi", out var ham) || ham is null) return;
        if (ham is not DateTime tarih)
        {
            if (!DateTime.TryParse(Convert.ToString(ham, CultureInfo.InvariantCulture),
                                   CultureInfo.InvariantCulture, DateTimeStyles.None, out tarih))
                return;
        }

        var simdi = DateTime.Now;
        // Ayni dakikadaki saat farki (istemci saati birkac saniye ileri olabilir)
        //   hata sayilmasin diye 5 dakikalik pay birakilir.
        if (tarih > simdi.AddMinutes(5))
            throw GentegreHatasi.Dogrulama("Belge tarihi ileri tarihli olamaz.",
                new AlanHatasi("belgeTarihi", $"En fazla {simdi:dd.MM.yyyy HH:mm} olabilir."));

        var enEski = simdi.Date.AddDays(-GeriyeGunSiniri);
        if (tarih < enEski)
            throw GentegreHatasi.Dogrulama(
                $"Belge tarihi {GeriyeGunSiniri} günden eski olamaz.",
                new AlanHatasi("belgeTarihi", $"En erken {enEski:dd.MM.yyyy} olabilir."));
    }

    /// <summary>
    /// Bu belge turunde cari SECILMEK ZORUNDA mi (kasa_islem_turu.cari_zorunlu:
    /// 1 zorunlu / 0 istege bagli / -1 yasak). Katalogda olmayan tur: zorunlu
    /// (eski davranis - yeni bir tur yanlislikla carisiz kaydedilmesin).
    /// </summary>
    private static async Task<bool> CariZorunluMuAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int tur, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select cari_zorunlu from public.kasa_islem_turu where kod = @p0", baglanti, islem);
        komut.Parameters.AddWithValue("p0", (short)tur);
        var d = await komut.ExecuteScalarAsync(iptal);
        return d is null or DBNull || Convert.ToInt32(d) == 1;
    }

    /// <summary>Kaynak satiri hedef satir JSON'una cevirir (fiyat/iskonto/KDV aynen tasinir).</summary>
    private static Dictionary<string, JsonElement> SatirJson(
        IDictionary<string, object?> k, decimal miktar, int kaynakSatirId, int stokDurumDegis)
    {
        var govde = new Dictionary<string, object?>
        {
            ["tur"] = k["tur"],
            ["stokId"] = k["stok_id"],
            ["hizmetId"] = k["hizmet_id"],
            ["masrafId"] = k["masraf_id"],
            ["aciklama"] = k["aciklama"],
            ["adet"] = miktar,
            ["miktar"] = miktar,
            ["birim"] = k["birim"],
            ["birimFiyat"] = k["birim_fiyat"],
            ["iskonto"] = k["iskonto"],
            ["iskonto2"] = k["iskonto2"],
            ["kdv"] = k["kdv"],
            ["otvYuzde"] = k["otv_yuzde"],
            ["otvMiktar"] = k["otv_miktar"],
            ["kdvMuafiyeti"] = k["kdv_muafiyeti"],
            ["dovizCinsi"] = k["doviz_cinsi"],
            ["dovizBirimFiyat"] = k["doviz_birim_fiyat"],
            ["dovizKuru"] = k["doviz_kuru"],
            ["girisDepoId"] = k["giris_depo_id"],
            ["cikisDepoId"] = k["cikis_depo_id"],
            ["izleme"] = k["izleme"],
            ["izlemeKodu"] = k["izleme_kodu"],
            ["stokDurumDegis"] = stokDurumDegis,
            ["kaynakTur"] = 30,
            ["kaynakId"] = kaynakSatirId,
        };

        var json = JsonSerializer.SerializeToElement(govde);
        var sonuc = new Dictionary<string, JsonElement>(StringComparer.Ordinal);
        foreach (var alan in json.EnumerateObject()) sonuc[alan.Name] = alan.Value;
        return sonuc;
    }

    private static string Kirp(string deger, int sinir)
        => deger.Length <= sinir ? deger : deger[..sinir];

    // ================================================================== okuma ====
    public async Task<(IDictionary<string, object?> Belge, List<IDictionary<string, object?>> Satirlar,
                       List<DipToplamSatiri> DipToplam)?> OkuAsync(int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        IDictionary<string, object?>? belge = null;
        await using (var komut = new NpgsqlCommand("""
            select b.id, b.tur, b.tipi, b.belge_seri as "belgeSeri", b.belge_no as "belgeNo",
                   b.belge_tarihi as "belgeTarihi", b.taraf_id as "tarafId",
                   b.taraf_unvan as "tarafUnvan", b.taraf_vkno as "tarafVkno",
                   b.gonderici_unvan as "gondericiUnvan", b.gonderici_vkno as "gondericiVkno",
                   b.matrah, b.kdv_tutari as "kdvTutari", b.ek_vergi as "ekVergi",
                   b.genel_toplam as "genelToplam", b.belge_dovizi as "belgeDovizi",
                   b.doviz_tutari as "dovizTutari", b.doviz_kuru as "dovizKuru",
                   b.kdv_durum as "kdvDurum", b.durum, b.sube_id as "subeId",
                   -- Irsaliye/siparis kartinin baslik alanlari (mockup ile birebir)
                   b.tipi, b.belge_seri as "belgeSeri",
                   b.irsaliye_no as "irsaliyeNo", b.irsaliye_tarihi as "irsaliyeTarihi",
                   b.taraf_vd as "tarafVd", b.taraf_adres_id as "tarafAdresId",
                   b.taraf_adres as "tarafAdres", b.taraf_ilce as "tarafIlce", b.taraf_il as "tarafIl",
                   b.cikis_depo_id as "cikisDepoId", cd.ad as "cikisDepoAdi",
                   b.giris_depo_id as "girisDepoId", gd.ad as "girisDepoAdi",
                   b.satici_id as "saticiId", sc.unvan as "saticiAdi",
                   b.teslim_sekli as "teslimSekli", b.vade_gun as "vadeGun",
                   b.arac_plaka as "aracPlaka", b.sofor_ad as "soforAd",
                   b.sofor_tckn as "soforTckn", b.teslim_eden_id as "teslimEdenId",
                   td.unvan as "teslimEdenAdi",
                   b.teslim_alan_id as "teslimAlanId", ta.unvan as "teslimAlanAdi",
                   b.proje_id as "projeId", b.efatura_durum as "efaturaDurum",
                   b.efatura_sonuc as "efaturaSonuc", b.senaryo, b.zarf_id as "zarfId",
                   b.gonderici_alias as "gondericiAlias",
                   -- e-Belge kuyrugundaki SON kayit: ETTN (uuid) ve GIB yaniti
                   --   kartin e-Belge sekmesinde gosterilir.
                   eb.uuid as "ettn", eb.belge_no as "eBelgeNo",
                   eb.gib_durum_kodu as "gibDurumKodu", eb.gib_durum_aciklama as "gibDurumAciklama",
                   eb.servis_durum_adi as "servisDurumAdi",
                   b.kapanma_durum as "kapanmaDurum",
                   b.kaynak_tur as "kaynakTur", b.kaynak_id as "kaynakId",
                   kb.belge_no as "kaynakBelgeNo", kb.belge_tarihi as "kaynakBelgeTarihi",
                   kt.ad as "kaynakTurAdi", b.aciklama,
                   b.xmin::text as surum
              from public.belge b
              left join public.depo  cd on cd.id = b.cikis_depo_id
              left join public.depo  gd on gd.id = b.giris_depo_id
              left join public.taraf sc on sc.id = b.satici_id
              left join public.taraf td on td.id = b.teslim_eden_id
              left join public.taraf ta on ta.id = b.teslim_alan_id
              left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30
              left join public.kasa_islem_turu kt on kt.kod = kb.tur
              left join lateral (
                  select e.uuid, e.belge_no, e.gib_durum_kodu, e.gib_durum_aciklama,
                         e.servis_durum_adi
                    from public.e_belge e
                   where e.belge_id = b.id
                   order by e.id desc
                   limit 1
              ) eb on true
             where b.id = @p0
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal)) return null;
            belge = Satir(okuyucu);
        }

        var satirlar = new List<IDictionary<string, object?>>();
        await using (var komut = new NpgsqlCommand("""
            select s.id, s.sira, s.tur, s.stok_id as "stokId", s.hizmet_id as "hizmetId",
                   s.masraf_id as "masrafId", s.aciklama, s.adet, s.miktar, s.birim,
                   s.birim_fiyat as "birimFiyat", s.iskonto, s.iskonto2, s.kdv,
                   s.otv_yuzde as "otvYuzde", s.otv_miktar as "otvMiktar", s.tutar,
                   s.doviz_cinsi as "dovizCinsi", s.doviz_birim_fiyat as "dovizBirimFiyat",
                   s.doviz_tutari as "dovizTutari", s.doviz_kuru as "dovizKuru",
                   s.giris_depo_id as "girisDepoId", s.cikis_depo_id as "cikisDepoId",
                   s.izleme_kodu as "izlemeKodu",
                   -- Kart satiri stok ADINI gosterir; id'yi ekranda kimse okuyamaz.
                   coalesce(st.kod, '') as "stokKodu", coalesce(st.ad, '') as "stokAdi",
                   coalesce(hz.ad, '')  as "hizmetAdi", coalesce(ms.ad, '') as "masrafAdi",
                   s.kapatilan_miktar as "kapatilanMiktar", s.kalan_miktar as "kalanMiktar",
                   s.kaynak_tur as "kaynakTur", s.kaynak_id as "kaynakId"
              from public.belge_satir s
              left join public.stok   st on st.id = s.stok_id
              left join public.hizmet hz on hz.id = s.hizmet_id
              left join public.masraf ms on ms.id = s.masraf_id
             where s.belge_id = @p0 order by s.sira, s.id
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal)) satirlar.Add(Satir(okuyucu));
        }

        var dip = await DipToplamAsync(baglanti, null, belgeId, iptal);
        return (belge!, satirlar, dip);
    }

    public async Task<List<DipToplamSatiri>> DipToplamAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int belgeId, CancellationToken iptal)
    {
        var sonuc = new List<DipToplamSatiri>();
        await using var komut = new NpgsqlCommand(
            "select * from public.fn_belge_diptoplam(@p0) order by d_tur", baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
        {
            sonuc.Add(new DipToplamSatiri(
                (int)okuyucu.GetDouble(okuyucu.GetOrdinal("d_tur")),
                okuyucu.Metin("d_aciklama"),
                (decimal)okuyucu.GetDouble(okuyucu.GetOrdinal("d_deger")),
                okuyucu.IsDBNull(okuyucu.GetOrdinal("d_doviz_tutari"))
                    ? 0 : (decimal)okuyucu.GetDouble(okuyucu.GetOrdinal("d_doviz_tutari")),
                okuyucu.Metin("d_kur"),
                okuyucu.Metin("d_belge_dovizi")));
        }
        return sonuc;
    }

    // ================================================================ ic adimlar ====
    private static readonly Dictionary<string, string> BelgeKolonlari = new(StringComparer.Ordinal)
    {
        ["tur"] = "tur", ["tipi"] = "tipi", ["tarafId"] = "taraf_id",
        ["tarafAdresId"] = "taraf_adres_id", ["tarafUnvan"] = "taraf_unvan",
        ["tarafVkno"] = "taraf_vkno", ["tarafVd"] = "taraf_vd", ["tarafAdres"] = "taraf_adres",
        ["tarafIlce"] = "taraf_ilce", ["tarafIl"] = "taraf_il",
        ["belgeSeri"] = "belge_seri", ["belgeNo"] = "belge_no", ["kocanNo"] = "kocan_no",
        ["belgeTarihi"] = "belge_tarihi", ["irsaliyeNo"] = "irsaliye_no",
        ["irsaliyeTarihi"] = "irsaliye_tarihi", ["girisDepoId"] = "giris_depo_id",
        ["cikisDepoId"] = "cikis_depo_id", ["subeId"] = "sube_id", ["projeId"] = "proje_id",
        ["kdvDurum"] = "kdv_durum", ["belgeDovizi"] = "belge_dovizi",
        ["dovizCinsi"] = "doviz_cinsi", ["dovizKuru"] = "doviz_kuru", ["kur"] = "kur",
        ["raporDovizi"] = "rapor_dovizi", ["vadeGun"] = "vade_gun", ["durum"] = "durum",
        ["aciklama"] = "aciklama", ["ozelKod"] = "ozel_kod", ["senaryo"] = "senaryo",
        ["gondericiUnvan"] = "gonderici_unvan", ["gondericiVkno"] = "gonderici_vkno",
        ["gondericiAlias"] = "gonderici_alias", ["saticiId"] = "satici_id",
        // Irsaliye karti (088): sevk bilgileri
        ["teslimSekli"] = "teslim_sekli", ["merkezId"] = "merkez_id",
        // 089 sevkiyat alanlari (e-Irsaliye UBL: plaka + sofor zorunlu)
        ["aracPlaka"] = "arac_plaka", ["soforAd"] = "sofor_ad", ["soforTckn"] = "sofor_tckn",
        ["tasiyiciId"] = "tasiyici_id", ["teslimEdenId"] = "teslim_eden_id",
        ["teslimAlanId"] = "teslim_alan_id"
    };

    private async Task<int> BelgeEkleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IDictionary<string, object?> belge, YazmaBaglami baglam, CancellationToken iptal)
    {
        var kolonlar = new List<string>();
        var parametreler = new List<object?>();

        foreach (var (ad, deger) in belge)
        {
            if (!BelgeKolonlari.TryGetValue(ad, out var kolon)) continue;
            kolonlar.Add(kolon);
            parametreler.Add(deger);
        }

        kolonlar.Add("ekleyen");
        parametreler.Add(baglam.KullaniciId);

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));

        var sql = $"insert into public.belge ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)}) returning id";

        await using var komut = Komut(baglanti, islem, sql, parametreler);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));
    }

    private async Task SatirEkleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int sira, Dictionary<string, JsonElement> satir,
        IDictionary<string, object?> belge, YazmaBaglami baglam, bool turStokEtkiler,
        List<string> uyarilar, CancellationToken iptal)
    {
        var tur = (int)JsonSayi(satir, "tur", 1);
        var stokId   = JsonSayiNull(satir, "stokId");
        var hizmetId = JsonSayiNull(satir, "hizmetId");
        var masrafId = JsonSayiNull(satir, "masrafId");

        // §4/3: uc bagdan yalniz BIRI dolu olabilir (veritabani check ile de zorlar).
        var bagAdedi = (stokId is not null ? 1 : 0) + (hizmetId is not null ? 1 : 0) +
                       (masrafId is not null ? 1 : 0);
        if (bagAdedi > 1)
            throw GentegreHatasi.Dogrulama($"{sira}. satirda birden fazla urun bagi var.",
                new AlanHatasi($"satirlar[{sira - 1}]", "stokId / hizmetId / masrafId birlikte olamaz."));

        var beklenen = tur switch { 1 => stokId, 2 => hizmetId, 3 => masrafId, _ => null };
        if (bagAdedi == 1 && beklenen is null)
            throw GentegreHatasi.Dogrulama($"{sira}. satirda tur ile urun bagi uyusmuyor.",
                new AlanHatasi($"satirlar[{sira - 1}].tur", "tur=1 stok, 2 hizmet, 3 masraf."));

        var adet       = JsonOndalik(satir, "adet", JsonOndalik(satir, "miktar", 0));
        var miktar     = JsonOndalik(satir, "miktar", adet);
        var iskonto    = JsonOndalik(satir, "iskonto", 0);
        var iskonto2   = JsonOndalik(satir, "iskonto2", 0);
        var kdv        = (int)JsonSayi(satir, "kdv", 0);

        // Doviz: satirin kuru yoksa belgenin kuru. TL islemde de kur = 1 (026).
        var kur = JsonOndalik(satir, "dovizKuru", 0);
        if (kur <= 0) kur = Ondalik(belge, "dovizKuru");
        if (kur <= 0) kur = 1m;
        var dovizCinsi = JsonMetin(satir, "dovizCinsi");
        if (dovizCinsi.Length == 0) dovizCinsi = Metin(belge, "belgeDovizi");
        if (dovizCinsi.Length == 0) dovizCinsi = "TL";

        // Birim fiyat doviz uzerinden verildiyse yerel karsiligi turetilir
        //   (Delphi: BIRIMFIYAT = DOVIZ_BIRIMFIYAT * DOVIZKURDEGERI).
        var dovizBirimFiyat = JsonOndalik(satir, "dovizBirimFiyat", 0);
        var birimFiyat = JsonOndalik(satir, "birimFiyat", 0);
        if (birimFiyat == 0 && dovizBirimFiyat != 0)
            birimFiyat = BelgeHesap.YerelBirimFiyat(dovizBirimFiyat, kur);
        if (dovizBirimFiyat == 0 && birimFiyat != 0)
            dovizBirimFiyat = BelgeHesap.DovizKarsiligi(birimFiyat, kur, 6);

        // TUTAR: Delphi formulu birebir (ic yuvarlama + carpimsal iskonto + banker's).
        var tutar      = BelgeHesap.SatirTutari(adet, birimFiyat, iskonto, iskonto2);
        var dovizTutar = BelgeHesap.SatirTutari(adet, dovizBirimFiyat, iskonto, iskonto2);

        var kolonlar = new List<string>
        {
            "belge_id", "sira", "tur", "stok_id", "hizmet_id", "masraf_id", "aciklama",
            "adet", "miktar", "birim", "birim_fiyat", "iskonto", "iskonto2", "kdv",
            "otv_yuzde", "otv_miktar", "kdv_muafiyeti", "tutar",
            "doviz_cinsi", "doviz_birim_fiyat", "doviz_tutari", "doviz_kuru",
            "giris_depo_id", "cikis_depo_id", "izleme", "izleme_kodu", "stok_durum_degis",
            // Donusum bagi (F8): kaynak_tur=30 -> kaynak belge_satir. Kapatma
            //   sayacini bu iki alan uzerinden DB trigger'i surer.
            "kaynak_tur", "kaynak_id", "proje_id",
            "sube_id", "ekleyen"
        };
        var parametreler = new List<object?>
        {
            belgeId, sira, tur, stokId, hizmetId, masrafId, JsonMetin(satir, "aciklama"),
            adet, miktar, (int)JsonSayi(satir, "birim", 0), birimFiyat, iskonto, iskonto2, (short)kdv,
            (short)JsonSayi(satir, "otvYuzde", 0), JsonOndalik(satir, "otvMiktar", 0),
            (short)JsonSayi(satir, "kdvMuafiyeti", 0), tutar,
            dovizCinsi, dovizBirimFiyat, dovizTutar, kur,
            JsonSayiNull(satir, "girisDepoId") ?? SayiNull(belge, "girisDepoId"),
            JsonSayiNull(satir, "cikisDepoId") ?? SayiNull(belge, "cikisDepoId"),
            (short)JsonSayi(satir, "izleme", 0), JsonMetin(satir, "izlemeKodu"),
            (short)(turStokEtkiler ? JsonSayi(satir, "stokDurumDegis", 1) : 0),
            (int)JsonSayi(satir, "kaynakTur", 0), JsonSayi(satir, "kaynakId", 0),
            JsonSayiNull(satir, "projeId") ?? SayiNull(belge, "projeId"),
            (short)(baglam.SubeId ?? 0), baglam.KullaniciId
        };

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));
        var sql = $"insert into public.belge_satir ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)})";

        await using var komut = Komut(baglanti, islem, sql, parametreler);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task ToplamlariYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, CancellationToken iptal)
    {
        var dip = await DipToplamAsync(baglanti, islem, belgeId, iptal);

        decimal Topla(int tur) => dip.Where(d => d.Tur == tur).Sum(d => d.Deger);

        var matrah = Topla(DipToplamTuru.AraToplam);
        var kdv    = Topla(DipToplamTuru.KdvToplam);
        var ek     = Topla(DipToplamTuru.EkVergi) + Topla(DipToplamTuru.Stopaj);
        var genel  = Topla(DipToplamTuru.GenelToplam);
        var dovizGenel = dip.Where(d => d.Tur == DipToplamTuru.GenelToplam).Sum(d => d.DovizTutari);

        await using var komut = new NpgsqlCommand("""
            update public.belge
               set matrah = @p1, kdv_tutari = @p2, ek_vergi = @p3, genel_toplam = @p4,
                   doviz_tutari = @p5
             where id = @p0
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        komut.Parameters.AddWithValue("p1", matrah);
        komut.Parameters.AddWithValue("p2", kdv);
        komut.Parameters.AddWithValue("p3", ek);
        komut.Parameters.AddWithValue("p4", genel);
        komut.Parameters.AddWithValue("p5", dovizGenel);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task StokDurumGuncelleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, bool stokKontrolu, List<string> uyarilar, CancellationToken iptal)
    {
        var satis = SatisMi(tur);
        var transfer = TransferMi(tur);

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
                                     stokKontrolu, uyarilar, iptal);
                await DepoyaYazAsync(baglanti, islem, stokId, girisDepo.Value, miktar, 0m,
                                     stokKontrolu, uyarilar, iptal);
                continue;
            }

            // Normal belge: yon TURDEN gelir, depo satirda hangisi doluysa o.
            var depoId = satis ? cikisDepo ?? girisDepo : girisDepo ?? cikisDepo;
            if (depoId is null) continue;

            await DepoyaYazAsync(baglanti, islem, stokId, depoId.Value,
                                 satis ? 0m : miktar, satis ? miktar : 0m,
                                 stokKontrolu, uyarilar, iptal);
        }
    }

    /// <summary>Tek depo satirini gunceller (yoksa acar) ve negatif bakiyeyi uyarir.</summary>
    private static async Task DepoyaYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int stokId, int depoId, decimal giren, decimal cikan,
        bool stokKontrolu, List<string> uyarilar, CancellationToken iptal)
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
        if (stokKontrolu && kalan < 0)
            uyarilar.Add($"Stok {stokId} deposunda bakiye negatife dustu ({kalan}).");
    }

    private async Task MaliHareketYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, int tarafId, YazmaBaglami baglam, CancellationToken iptal)
    {
        // Bacak duzeni (080 gocu ile gelen K2 kurali):
        //   doviz_cinsi = bacagin KENDI para birimi (belgenin dovizi)
        //   borc/alacak = O DOVIZDE tutar  (TL belgede zaten TL)
        //   yerel_borc / yerel_alacak = TL karsiligi (genel_toplam)
        //   doviz_kuru  = belgedeki kur
        // Eski "kur" ve "doviz_tutari" kolonlari 080'de DUSURULDU.
        // hesap_turu 'C' (cari) - eskiden yanlislikla '1' yaziliyordu; sema
        //   yorumu (012_sema_belge.sql:212) ve tum ekstre gorunumleri 'C' bekler.
        await using var komut = new NpgsqlCommand("""
            insert into public.mali_hareket
                (tur, hesap_turu, taraf_id, belge_id, belge_no, islem_tarihi,
                 borc, alacak, yerel_borc, yerel_alacak,
                 doviz_cinsi, doviz_kuru, aciklama, sube_id, ekleyen)
            select @p0, 'C', b.taraf_id, b.id, b.belge_no, b.belge_tarihi,
                   case when @p1 then coalesce(nullif(b.doviz_tutari, 0), b.genel_toplam) else 0 end,
                   case when @p1 then 0 else coalesce(nullif(b.doviz_tutari, 0), b.genel_toplam) end,
                   case when @p1 then b.genel_toplam else 0 end,
                   case when @p1 then 0 else b.genel_toplam end,
                   coalesce(nullif(btrim(b.belge_dovizi), ''), 'TL'),
                   case when coalesce(b.doviz_kuru, 0) > 0 then b.doviz_kuru else 1 end,
                   b.taraf_unvan, b.sube_id, @p2
              from public.belge b where b.id = @p3
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", (short)tur);
        komut.Parameters.AddWithValue("p1", SatisMi(tur));
        komut.Parameters.AddWithValue("p2", baglam.KullaniciId);
        komut.Parameters.AddWithValue("p3", belgeId);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task NumaraVerAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, string seri, int? subeId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            update public.belge
               set belge_no = public.fn_belge_no_uret(@p1, @p2, @p3)
             where id = @p0 and coalesce(belge_no, '') = ''
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        komut.Parameters.AddWithValue("p1", tur);
        komut.Parameters.AddWithValue("p2", seri ?? "");
        komut.Parameters.AddWithValue("p3", subeId ?? 0);
        await komut.ExecuteNonQueryAsync(iptal);

        // Numara belgeye yazildi; mali_hareket satirindaki kopyasi da guncellenir.
        await using var komut2 = new NpgsqlCommand("""
            update public.mali_hareket m
               set belge_no = b.belge_no
              from public.belge b
             where b.id = m.belge_id and m.belge_id = @p0
            """, baglanti, islem);
        komut2.Parameters.AddWithValue("p0", belgeId);
        await komut2.ExecuteNonQueryAsync(iptal);
    }

    // ================================================================ yardimci ====
    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    private static void Varsayilan(IDictionary<string, object?> hedef, string ad, string deger)
    {
        if (!hedef.TryGetValue(ad, out var mevcut) || mevcut is null ||
            (mevcut is string s && s.Length == 0))
            hedef[ad] = deger;
    }

    private static int Sayi(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : 0;

    private static int? SayiNull(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : null;

    private static decimal Ondalik(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToDecimal(v) : 0m;

    private static string Metin(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? v.ToString() ?? "" : "";

    private static long JsonSayi(Dictionary<string, JsonElement> d, string ad, long varsayilan)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.Number && e.TryGetInt64(out var l)
           ? l : varsayilan;

    private static int? JsonSayiNull(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.Number && e.TryGetInt32(out var i)
           ? i : null;

    private static decimal JsonOndalik(Dictionary<string, JsonElement> d, string ad, decimal varsayilan)
    {
        if (!d.TryGetValue(ad, out var e)) return varsayilan;
        return e.ValueKind switch
        {
            JsonValueKind.Number => e.GetDecimal(),
            JsonValueKind.String => decimal.TryParse(e.GetString(), NumberStyles.Number,
                                        CultureInfo.InvariantCulture, out var m) ? m : varsayilan,
            _ => varsayilan
        };
    }

    private static string JsonMetin(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.String
           ? e.GetString() ?? "" : "";

    private NpgsqlCommand Komut(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string sql, IReadOnlyList<object?> parametreler)
    {
        var komut = new NpgsqlCommand(sql, baglanti, islem);
        for (var i = 0; i < parametreler.Count; i++)
            komut.Parameters.AddWithValue("p" + i.ToString(CultureInfo.InvariantCulture),
                parametreler[i] ?? DBNull.Value);
        return komut;
    }
}
