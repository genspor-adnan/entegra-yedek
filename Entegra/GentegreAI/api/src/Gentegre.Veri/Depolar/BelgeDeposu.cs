using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek;
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
public sealed partial class BelgeDeposu
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
    /// BELGE DUZENLEME (135) - kayitli belgeyi yeniden yazar.
    ///
    /// Kesin belge numara tuketmis, stok dusmus ve cari islenmis olur; duzenleme
    /// bu uc izi de tutarli birakmali. Yol: ESKI ETKIYI GERI AL (stok hareketini
    /// ters cevir, cari bacagini sil), satirlari sil, yeni satirlari yaz ve
    /// etkiyi yeniden uygula. Belge NUMARASI ve kimligi korunur.
    ///
    /// KILIT (degistirilemez):
    ///   - e-Belge gonderilmis (efatura_durum > 0),
    ///   - belgeden fatura turetilmis (kapanma_durum > 0),
    ///   - belge tarihinden `belge.duzenleme_gun` gun gecmis (0 = duzenleme
    ///     kapali, -1 = sinirsiz).
    /// </summary>
    public async Task<(int Id, List<string> Uyarilar)> GuncelleAsync(
        int belgeId,
        IDictionary<string, object?> belge,
        List<Dictionary<string, JsonElement>> satirlar,
        BelgeSecenekleri secenekler,
        YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // --------------------------------------------------- 1) kilit kontrolu ----
        int tur, tipi, eskiDurum, efaturaDurum, kapanma;
        DateTime belgeTarihi;
        string belgeNo, belgeSeri;
        await using (var komut = new NpgsqlCommand("""
            select tur, coalesce(tipi, 0), durum, coalesce(efatura_durum, 0),
                   coalesce(kapanma_durum, 0), belge_tarihi,
                   coalesce(belge_no, ''), coalesce(belge_seri, '')
              from public.belge where id = @p0 for update
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi("Belge bulunamadi.");
            tur = o.GetInt32(0); tipi = o.GetInt32(1); eskiDurum = o.GetInt32(2);
            efaturaDurum = o.GetInt32(3); kapanma = o.GetInt32(4);
            belgeTarihi = o.GetDateTime(5); belgeNo = o.GetString(6); belgeSeri = o.GetString(7);
        }

        var duzenlemeGun = await AyarDeposu.SayiAsync(baglanti, islem, "belge.duzenleme_gun", iptal);
        if (duzenlemeGun == 0)
            throw GentegreHatasi.IsKurali(
                "Belge duzenleme kapali (Ayarlar > belge.duzenleme_gun).");
        if (efaturaDurum > 0)
            throw GentegreHatasi.IsKurali(
                "e-Belge gonderilmis belge degistirilemez; iptal edip yeniden kesin.");
        if (kapanma > 0)
            throw GentegreHatasi.IsKurali(
                "Bu belgeden fatura turetilmis; once turetilen belgeyi iptal edin.");
        if (duzenlemeGun > 0 && Saat.Bugun > belgeTarihi.Date.AddDays(duzenlemeGun))
            throw GentegreHatasi.IsKurali(
                $"Belge tarihinden {duzenlemeGun} gun gecti; kayit kilitlendi.");

        // --------------------------------- 2) eski etkiyi geri al (stok + cari) ----
        var uyarilar = new List<string>();
        if (eskiDurum == 0)                            // taslak stok/cari yazmaz
        {
            await StokDurumGeriAlAsync(baglanti, islem, belgeId, tur, tipi, iptal);
            await using var sil = new NpgsqlCommand(
                "delete from public.mali_hareket where belge_id = @p0", baglanti, islem);
            sil.Parameters.AddWithValue("p0", belgeId);
            await sil.ExecuteNonQueryAsync(iptal);
        }

        await using (var sil = new NpgsqlCommand("""
            delete from public.stok_izleme where belge_id = @p0;
            delete from public.belge_satir  where belge_id = @p0;
            """, baglanti, islem))
        {
            sil.Parameters.AddWithValue("p0", belgeId);
            await sil.ExecuteNonQueryAsync(iptal);
        }

        // ------------------------------------------- 3) yeni haliyle yeniden yaz ----
        // Numara ve seri KORUNUR: duzenleme yeni belge degildir.
        belge["belgeNo"] = belgeNo;
        belge["belgeSeri"] = belgeSeri;
        belge["id"] = belgeId;
        var (_, yeniUyarilar) = await KaydetIcAsync(baglanti, islem, belge, satirlar,
                                                    secenekler, baglam, iptal, belgeId);
        uyarilar.AddRange(yeniUyarilar);

        await islem.CommitAsync(iptal);
        return (belgeId, uyarilar);
    }

    /// <summary>
    /// Belgenin stok etkisini TERS cevirir (duzenleme / iptal): giren miktar
    /// cikar, cikan miktar girer. Lot bakiyeleri stok_izleme uzerinden ayni
    /// yolla geri alinir.
    /// </summary>
    private static async Task StokDurumGeriAlAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int belgeId, int tur, int tipi, CancellationToken iptal)
    {
        var cikis = BelgeTuru.CikisMi(tur, tipi);
        await using var komut = new NpgsqlCommand("""
            update public.stok_durum d
               set giren = d.giren - case when @p1 then 0 else k.miktar end,
                   cikan = d.cikan - case when @p1 then k.miktar else 0 end,
                   kalan = d.kalan + case when @p1 then k.miktar else -k.miktar end
              from (select s.stok_id,
                           coalesce(s.cikis_depo_id, s.giris_depo_id,
                                    b.cikis_depo_id, b.giris_depo_id) as depo_id,
                           sum(s.miktar) as miktar
                      from public.belge_satir s
                      join public.belge b on b.id = s.belge_id
                     where s.belge_id = @p0 and s.stok_id is not null
                     group by 1, 2) k
             where d.stok_id = k.stok_id and d.depo_id = k.depo_id
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        komut.Parameters.AddWithValue("p1", cikis);
        await komut.ExecuteNonQueryAsync(iptal);

        // Lot bakiyeleri: belgenin izlem satirlari ters isaretle geri alinir.
        await using var lot = new NpgsqlCommand("""
            update public.stok_lot_durum l
               set kalan = l.kalan + case when @p1 then i.miktar else -i.miktar end
              from (select stok_id, depo_id, seri_lot_id, sum(adet) as miktar
                      from public.stok_izleme
                     where belge_id = @p0 and seri_lot_id is not null
                     group by 1, 2, 3) i
             where l.stok_id = i.stok_id and l.depo_id = i.depo_id
               and l.seri_lot_id = i.seri_lot_id
            """, baglanti, islem);
        lot.Parameters.AddWithValue("p0", belgeId);
        lot.Parameters.AddWithValue("p1", cikis);
        await lot.ExecuteNonQueryAsync(iptal);
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
        int mevcutId = 0,
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
        if (BelgeTuru.StokFisiMi(tur))
        {
            if (Sayi(belge, "tipi") <= 0)
                throw GentegreHatasi.Dogrulama("Fiş tipi seçilmeli.",
                    new AlanHatasi("tipi", "Zorunlu."));

            var depoAlani = BelgeTuru.CikisMi(tur) ? "cikisDepoId" : "girisDepoId";
            if (Sayi(belge, depoAlani) <= 0)
                throw GentegreHatasi.Dogrulama("Depo seçilmeli.",
                    new AlanHatasi(depoAlani, "Zorunlu."));
        }

        if (BelgeTuru.TalepMi(tur))
        {
            if (Sayi(belge, "cikisDepoId") <= 0)
                throw GentegreHatasi.Dogrulama("İstenen depo seçilmeli.",
                    new AlanHatasi("cikisDepoId", "Zorunlu."));
            // Talep eden, mali TESLIM ALACAK kisidir - ayni kolonda tutulur.
            if (Sayi(belge, "teslimAlanId") <= 0)
                throw GentegreHatasi.Dogrulama("Talep eden seçilmeli.",
                    new AlanHatasi("teslimAlanId", "Zorunlu."));
        }

        if (BelgeTuru.TransferMi(tur))
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
        await BelgeTarihiKontrolAsync(baglanti, islem, belge, iptal);

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
        // Sube ZORUNLU: yoksa `sube_id` 0 yazilip FK ihlaliyle patliyordu -
        //   kullanici "Beklenmeyen bir hata" goruyordu (bkz. YazmaBaglami).
        {
            var subeId = baglam.SubeZorunlu();
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
        // Ekstre dovizi verilmediyse rapor doviziyle ayni (134).
        if (Metin(belge, "ekstreDovizi").Length == 0)
            belge["ekstreDovizi"] = Metin(belge, "raporDovizi");
        if (Metin(belge, "kdvDurum").Length == 0) belge["kdvDurum"] = "Hariç";

        // ------------------------------------------------- 3) belge NUMARASI kimin ----
        // Alis faturasinin numarasi TEDARIKCININDIR: bizim sayacimiz uretemez
        //   (uretirse mukerrer/anlamsiz numara olur, e-Fatura eslesmesi kirilir).
        //   Kullanici girer, biz yalniz bosluk ve ayni tedarikciden mukerrer
        //   girisi kontrol ederiz. Diger turlerde numara EN SON, sayactan.
        var disNumara = BelgeTuru.DisNumarali(tur);
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
        // DUZENLEME (135): mevcut belge yeniden yazilir - yeni kayit acilmaz,
        //   numara ve kimlik korunur.
        var belgeId = mevcutId > 0
            ? await BelgeGuncelleAsync(baglanti, islem, mevcutId, belge, baglam, iptal)
            : await BelgeEkleAsync(baglanti, islem, belge, baglam, iptal);

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
                await StokDurumGuncelleAsync(baglanti, islem, belgeId, tur, Sayi(belge, "tipi"),
                                             secenekler.StokKontrolu, uyarilar, iptal);
            // cariAtla: kaynak belge (irsaliye) cariyi ZATEN borclandirdi - ondan
            //   turetilen fatura ikinci kez yazarsa cari bakiye ikiye katlanir.
            //   Stok tarafinda ayni koruma satir bazinda (stok_durum_degis=0) var.
            if (cariEtkiler && !cariAtla)
                await MaliHareketYazAsync(baglanti, islem, belgeId, tur, Sayi(belge, "tipi"),
                                          tarafId, baglam, iptal);

            // ------------------------------------------------------- 7) belge NUMARASI ----
            // EN SON: buraya kadar her sey basarili. Satir kilidi altinda, BOSLUKSUZ.
            // Dis numarali belgede (alis faturasi) numara kullanicidan geldi.
            //   Duzenlemede numara ZATEN VAR - yeniden uretilmez.
            if (!disNumara && mevcutId == 0)
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

            var stokDusecek = hedefEtki.Stok && !kaynakDusurdu;

            // Izlemli stokta CIKISA donusum: kaynakta lot yok (siparis stok
            //   dusurmez), hedef ise lot ister. Lotlar FIFO ile otomatik tahsis
            //   edilir (kullanici karari) - kullanici isterse olusan belgeyi
            //   acip degistirir.
            IReadOnlyList<object>? izlemler = null;
            var stokId = ks2["stok_id"] is { } sid and not DBNull ? Convert.ToInt32(sid) : 0;
            if (stokDusecek && stokId > 0
                && BelgeTuru.CikisMi(hedefTur, Convert.ToInt32(kaynak["tipi"] ?? 0))
                && await StokIzlemeTuruAsync(baglanti, islem, stokId, iptal) > 0)
            {
                var cikisDepo = ks2["cikis_depo_id"] is { } sd and not DBNull ? Convert.ToInt32(sd)
                              : kaynak["cikis_depo_id"] is { } bd and not DBNull ? Convert.ToInt32(bd)
                              : (int?)null;
                izlemler = await FifoLotTahsisAsync(baglanti, islem, stokId, cikisDepo, miktar,
                                                    satirlar.Count + 1, iptal);
            }

            satirlar.Add(SatirJson(ks2, miktar, satirId,
                stokDurumDegis: stokDusecek ? 1 : 0, izlemler));
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
            ["belgeTarihi"] = belgeTarihi ?? Saat.Simdi,
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
        if (BelgeTuru.DisNumarali(hedefTur)) belge["belgeNo"] = (belgeNo ?? "").Trim();

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

    /// <summary>
    /// TERMIN GUNCELLEME (140): satirlarin teslim tarihini toplu degistirir.
    ///
    /// Belgeyi YENIDEN YAZMAZ. Termin ne stok ne cari ne de tutar etkiler; bu
    /// yuzden "kayitli belge duzenleme" kilidine (135) de takilmaz - e-Belgesi
    /// gonderilmis ya da faturalanmis bir siparisin kalan kalemleri icin de
    /// yeni tarih verilebilir. Tedarikci gecikince siparisi iptal edip yeniden
    /// kesmek yerine tarih guncellenir: numara, fiyat ve donusum zinciri kalir.
    ///
    /// Bos tarih = termin KALDIRILDI (belirsiz). Yalniz belgenin KENDI satirlari
    /// guncellenir - baska belgenin satir kimligi gonderilirse sessizce atlanmaz,
    /// 404 verir.
    /// </summary>
    public async Task<int> TerminGuncelleAsync(
        int belgeId, IReadOnlyList<(int SatirId, DateTime? Tarih)> satirlar,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (satirlar.Count == 0)
            throw GentegreHatasi.Dogrulama("Güncellenecek satır yok.",
                new AlanHatasi("satirlar", "Boş bırakılamaz."));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        IDictionary<string, object?> belge;
        await using (var komut = new NpgsqlCommand(
            "select id, tur, durum, sube_id, taraf_id, belge_no from public.belge where id = @p0",
            baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            belge = Satir(o);
        }

        if (baglam.SubeId is { } sube && belge["sube_id"] is { } bs
            && Convert.ToInt32(bs) != sube)
            throw GentegreHatasi.Bulunamadi();

        if (Convert.ToInt32(belge["durum"]) == 2)
            throw GentegreHatasi.IsKurali("İptal edilmiş belgede termin güncellenemez.");

        var degisen = 0;
        foreach (var (satirId, tarih) in satirlar)
        {
            await using var komut = new NpgsqlCommand("""
                update public.belge_satir
                   set teslim_tarihi = @p2, degistiren = @p3
                 where id = @p0 and belge_id = @p1
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", satirId);
            komut.Parameters.AddWithValue("p1", belgeId);
            komut.Parameters.AddWithValue("p2", (object?)tarih ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", baglam.KullaniciId);
            var etkilenen = await komut.ExecuteNonQueryAsync(iptal);
            if (etkilenen == 0)
                throw GentegreHatasi.Bulunamadi($"Satır bu belgeye ait değil: {satirId}");
            degisen += etkilenen;
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "termin",
                ["satirAdedi"] = degisen.ToString(CultureInfo.InvariantCulture),
                // En ileri tarih ozet olarak yeterli: "termin nereye cekildi".
                ["yeniTermin"] = satirlar.Where(s => s.Tarih is not null)
                    .Select(s => s.Tarih!.Value)
                    .DefaultIfEmpty()
                    .Max()
                    .ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
            },
            tarafId: SayiNull(belge, "taraf_id"), iptal: iptal);

        await islem.CommitAsync(iptal);
        return degisen;
    }

    /// <summary>
    /// SIPARIS REZERVASYONU (142): satirlarin KALAN miktarini depoda ayirir
    /// (ac=true) ya da birakir (ac=false).
    ///
    /// Stok DUSMEZ - o irsaliyede olur; yalniz "soz verilmis" miktar isaretlenir
    /// ve stok aramasinda kullanilabilir (kalan - rezerve) olarak gorunur.
    /// Kural motorda (fn_belge_rezerve): yalniz kesin SIPARISTE calisir, sevk
    /// edildikce rezerv kendiliginden cozulur.
    /// </summary>
    public async Task<int> RezerveAsync(int belgeId, bool ac,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        if (baglam.SubeId is { } sube)
        {
            await using var kontrol = new NpgsqlCommand(
                "select sube_id from public.belge where id = @p0", baglanti, islem);
            kontrol.Parameters.AddWithValue("p0", belgeId);
            var bs = await kontrol.ExecuteScalarAsync(iptal);
            if (bs is null) throw GentegreHatasi.Bulunamadi();
            if (bs is not DBNull && Convert.ToInt32(bs) != sube) throw GentegreHatasi.Bulunamadi();
        }

        int adet;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_belge_rezerve(@p0, @p1)", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            komut.Parameters.AddWithValue("p1", ac);
            try
            {
                adet = Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));
            }
            catch (PostgresException h) when (h.SqlState == "GK422")
            {
                throw GentegreHatasi.IsKurali(h.MessageText);
            }
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = ac ? "rezerve" : "rezerve-kaldir",
                ["satirAdedi"] = adet.ToString(CultureInfo.InvariantCulture)
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return adet;
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
    /// IADE EDILEBILIR SATIRLAR (132) - iade faturasinda "onceki alinanlar".
    ///
    /// Carinin kesin fatura/fis satirlari; miktar, iade edilmis miktar ve
    /// kaynaktan gelen fiyat/iskonto/KDV ile birlikte. Tamami iade edilmis
    /// satirlar DUSER (kalan = 0), boylece ayni kalem iki kez iade edilemez.
    /// belgeId verilirse yalniz o belgenin satirlari (belge uzerinden iade).
    /// </summary>
    public async Task<List<IDictionary<string, object?>>> IadeSatirlariAsync(
        int tarafId, int? belgeId, string? ara, IReadOnlyList<int>? turler = null,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select v.satir_id as "satirId", v.belge_id as "belgeId",
                   v.belge_tur as "belgeTur", v.belge_no as "belgeNo",
                   v.belge_tarihi as "belgeTarihi", v.taraf_id as "tarafId",
                   v.taraf_unvan as "tarafUnvan", v.sira,
                   v.satir_tur as "satirTur", v.stok_id as "stokId",
                   v.stok_kodu as "stokKodu", v.stok_adi as "stokAdi",
                   v.hizmet_id as "hizmetId", v.aciklama,
                   v.miktar, v.iade_miktar as "iadeMiktar",
                   (v.miktar - v.iade_miktar) as "kalanMiktar",
                   v.birim, v.birim_fiyat as "birimFiyat", v.iskonto, v.kdv,
                   v.doviz_cinsi as "dovizCinsi", v.izleme, v.izleme_kodu as "izlemeKodu"
              from public.v_iade_edilebilir_satir v
             where (@p0 <= 0 or v.taraf_id = @p0)
               and (@p1 <= 0 or v.belge_id = @p1)
               -- Iade FATURASINDA fatura, iade IRSALIYESINDE irsaliye satirlari
               --   (133): ayni mal iki kaynaktan iade edilip cift sayilmasin.
               and (cardinality(@p3::int[]) = 0 or v.belge_tur = any(@p3::int[]))
               and (v.miktar - v.iade_miktar) > 0
               and (@p2 = '' or v.stok_kodu ilike '%' || @p2 || '%'
                             or v.stok_adi  ilike '%' || @p2 || '%'
                             or v.belge_no  ilike '%' || @p2 || '%')
             order by v.belge_tarihi desc, v.belge_id desc, v.sira
             limit 200
            """, baglanti);
        komut.Parameters.AddWithValue("p0", tarafId);
        komut.Parameters.AddWithValue("p1", belgeId ?? 0);
        komut.Parameters.AddWithValue("p2", ara ?? "");
        komut.Parameters.AddWithValue("p3", (turler ?? Array.Empty<int>()).ToArray());

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

    /// <summary>
    /// Belge tarihi penceresi: bugunden ileri YOK, N gunden eski YOK.
    /// N = Genel Ayarlar'daki `belge.geri_gun_siniri` (db/102, varsayilan 7).
    /// 0 girilirse geriye donuk sinir KAPANIR - ileri tarih yasagi ayarla
    /// kapatilamaz, onu GIB zaten reddeder.
    /// </summary>
    private static async Task BelgeTarihiKontrolAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IDictionary<string, object?> belge, CancellationToken iptal)
    {
        if (!belge.TryGetValue("belgeTarihi", out var ham) || ham is null) return;
        if (ham is not DateTime tarih)
        {
            if (!DateTime.TryParse(Convert.ToString(ham, CultureInfo.InvariantCulture),
                                   CultureInfo.InvariantCulture, DateTimeStyles.None, out tarih))
                return;
        }

        // Kurulus saat dilimi (Saat.Simdi): konteyner UTC calisirken kullanicinin
        //   yerel saatini "ileri tarihli" saymasin.
        var simdi = Saat.Simdi;
        // Ayni dakikadaki saat farki (istemci saati birkac saniye ileri olabilir)
        //   hata sayilmasin diye 5 dakikalik pay birakilir.
        if (tarih > simdi.AddMinutes(5))
            throw GentegreHatasi.Dogrulama("Belge tarihi ileri tarihli olamaz.",
                new AlanHatasi("belgeTarihi", $"En fazla {simdi:dd.MM.yyyy HH:mm} olabilir."));

        var geriGun = await AyarDeposu.SayiAsync(baglanti, islem, "belge.geri_gun_siniri", iptal);
        if (geriGun <= 0) return;                       // 0 = geriye donuk sinir yok

        var enEski = simdi.Date.AddDays(-geriGun);
        if (tarih < enEski)
            throw GentegreHatasi.Dogrulama(
                $"Belge tarihi {geriGun} günden eski olamaz.",
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
