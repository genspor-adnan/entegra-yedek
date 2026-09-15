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
        await using var komut = baglanti.Komut("""
            select id from public.belge
             where tur = @p0 and taraf_id = @p1 and belge_no = @p2
               and durum <> 2 and id <> @p3
             limit 1
            """, islem,
            tur, tarafId, belgeNo, haricId);
        if (await komut.ExecuteScalarAsync(iptal) is { } varOlan and not DBNull)
            throw GentegreHatasi.IsKurali(
                $"Bu cariden \"{belgeNo}\" numarali belge zaten kayitli (#{varOlan}).");
    }

    /// <summary>
    /// Numarasi ENTEGRATORDEN gelecek belge mi?
    ///
    /// Satis faturasi e-Fatura/e-Arsiv olarak, satis irsaliyesi e-Irsaliye
    /// olarak gider. Iki kosul birlikte aranir:
    ///   1. ANA SALTER = subenin e-Fatura MUKELLEFIYETI (179). Ayri bir
    ///      "e-Belge kullanimda" ayari YOK - ayni soruyu iki yerden sormak
    ///      (ayar + bayrak) tutarsizlik uretiyordu;
    ///   2. BELGENIN TURUNDE de mukellef mi (172). Mukellefiyet GIB kaydidir ve
    ///      VKN'ye baglidir; merkezin kimligiyle gonderen sube merkezin
    ///      mukellefiyetini kullanir (fn_ebelge_mukellef_mi bunu cozer).
    ///
    /// Mukellefiyet KONTROL EDILMEZSE: mukellef olmayan firmada belge "0"
    /// numarayla kalir, hazirlama da "mukellef degilsiniz" diye reddeder ve
    /// belge numarasiz kilitlenirdi.
    ///
    /// Faturada e-Fatura YA DA e-Arsiv yeterli: alici GIB mukellefi ise
    /// e-Fatura, degilse e-Arsiv kesilir - hangisi olacagi hazirlamada belli olur.
    /// </summary>
    private static async Task<bool> EBelgeNumaraliMiAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int tur, int? subeId, CancellationToken iptal)
    {
        if (tur != BelgeTuru.SatisFaturasi && tur != BelgeTuru.SatisIrsaliyesi) return false;

        await using var komut = new NpgsqlCommand(
            tur == BelgeTuru.SatisFaturasi
                ? """
                  select public.fn_ebelge_acik(@p0)
                     and (public.fn_ebelge_mukellef_mi(@p0, 1)
                       or public.fn_ebelge_mukellef_mi(@p0, 2))
                  """
                : "select public.fn_ebelge_acik(@p0) and public.fn_ebelge_mukellef_mi(@p0, 7)",
            baglanti, islem);
        // Sube bilinmiyorsa (oturum sube secmemis) varsayilan sube kullanilir -
        //   fonksiyon null'i boyle cozer.
        komut.Parameters.AddWithValue("p0", (object?)subeId ?? DBNull.Value);
        return await komut.ExecuteScalarAsync(iptal) is bool b && b;
    }

    /// <summary>e-Belge bekleyen belgede numara alani "0" kalir.</summary>
    private static async Task NumaraSifirlaAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int belgeId, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut("""
            update public.belge set belge_no = '0'
             where id = @p0 and coalesce(belge_no, '') = ''
            """, islem,
            belgeId);
        await komut.ExecuteNonQueryAsync(iptal);
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
        // DONUSMUS BELGE (kapanma_durum > 0)
        //   SIPARIS: duzenlenebilir. Kullanici kapanmis siparise YENI SATIR
        //     ekleyebilmeli; donusmus satirlar ise KORUNUR (hedef belge onlara
        //     bagli) - asagida silinmez ve istemciden gelen kopyalari atlanir.
        //   FATURA / IRSALIYE: kilit surer. Turetilmis belgenin kalemini
        //     degistirmek hedef belgeyi ve muhasebe fisini tutarsiz birakir.
        var siparisMi = tur is 9 or 19;
        if (kapanma > 0 && !siparisMi)
            throw GentegreHatasi.IsKurali(
                "Bu belgeden fatura turetilmis; once turetilen belgeyi iptal edin.");
        // 667: belge tarihi veritabanindan UTC AN olarak gelir; "kac gun once"
        //   sorusu KURULUS gunune gore sorulur (gece 01:00'deki bir belge UTC'de
        //   onceki gune duser).
        if (duzenlemeGun > 0 &&
            Saat.BugunDilim(baglam.ZamanDilimi) >
                Saat.Yerel(belgeTarihi, baglam.ZamanDilimi).Date.AddDays(duzenlemeGun))
            throw GentegreHatasi.IsKurali(
                $"Belge tarihinden {duzenlemeGun} gun gecti; kayit kilitlendi.");

        // --------------------------------- 2) eski etkiyi geri al (stok + cari) ----
        var uyarilar = new List<string>();
        if (eskiDurum == 0)                            // taslak stok/cari yazmaz
        {
            await StokDurumGeriAlAsync(baglanti, islem, belgeId, tur, tipi, iptal);
            // YALNIZ BELGENIN KENDI cari satiri silinir (`kasa_islem_id is null`).
            //   Kosulsuz silme, belgeye baglanmis TAHSILATLARIN bacaklarini da
            //   siliyordu: taslak fise nakit tahsilat girilip fis tekrar
            //   kaydedilince kasa islemi duruyor ama cari ekstrede ve hesap
            //   bakiyesinde hicbir iz kalmiyordu (kullanici bildirimi: satis
            //   fisi 114356 - tahsilat Eren'in ekstresinde yok). Tahsilatin
            //   bacaklari kasa islemine aittir, belge onlari yeniden yazmaz.
            await using var sil = baglanti.Komut(
                "delete from public.mali_hareket " +
                " where belge_id = @p0 and kasa_islem_id is null", islem,
                belgeId);
            await sil.ExecuteNonQueryAsync(iptal);
        }

        // DONUSMUS SATIRLAR SILINMEZ: hedef belgenin satirlari bunlara
        //   (belge_satir.kaynak_id) bagli; silinirse zincir kopar ve
        //   kapatilan_miktar tetigi bozulur.
        // BASKA KAYITLARIN KULLANDIGI SATIR DA SILINMEZ: radyoloji istemi,
        //   UTS bildirimi, konsultasyon ve kurum icmali satiri belge_satir'a
        //   NO ACTION ile bagli - silinmeye calisilinca istek 23503 ile
        //   dusuyordu ("Baglantili kayit bulunamadi ya da baska kayitlar
        //   tarafindan kullaniliyor"; basvuru 114317: kalemlerinden radyoloji
        //   istemi acilmisti ve kart bir daha KAYDEDILEMIYORDU - Dönüşüm
        //   sekmesinden "Fiş" demek de once kaydettigi icin ayni hataya
        //   dusuyordu). Korunan satir donusmus satirla ayni muameleyi gorur:
        //   yerinde kalir, istemcinin kopyasi atilir.
        var korunan = new List<int>();
        await using (var oku = baglanti.Komut(KorunanSatirSql, islem, belgeId, kapanma > 0))
        {
            await using var o = await oku.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal)) korunan.Add(o.GetInt32(0));
        }

        await using (var sil = new NpgsqlCommand("""
            delete from public.stok_izleme where belge_id = @p0
                  and coalesce(array_length(@p1::int[], 1), 0) = 0;
            delete from public.belge_satir  where belge_id = @p0
                  and not (id = any(@p1::int[]));
            """, baglanti, islem))
        {
            sil.Parameters.AddWithValue("p0", belgeId);
            sil.Parameters.AddWithValue("p1", korunan.ToArray());
            await sil.ExecuteNonQueryAsync(iptal);
        }

        // Istemci TUM satirlari gonderir; korunanlarin kopyasi ATILIR, yoksa
        //   ayni kalem iki kez yazilirdi.
        if (korunan.Count > 0)
        {
            satirlar = satirlar
                // Kimlik alani istemcide "satirId", kart okumasinda "id" adiyla
                //   geliyor - ikisi de kabul edilir.
                .Where(x => !((x.TryGetValue("satirId", out var sid)
                               && sid.ValueKind == JsonValueKind.Number
                               && korunan.Contains(sid.GetInt32()))
                              || (x.TryGetValue("id", out var kid)
                                  && kid.ValueKind == JsonValueKind.Number
                                  && korunan.Contains(kid.GetInt32()))))
                .ToList();
        }

        // ------------------------------------------- 3) yeni haliyle yeniden yaz ----
        // Numara ve seri KORUNUR: duzenleme yeni belge degildir.
        belge["belgeNo"] = belgeNo;
        belge["belgeSeri"] = belgeSeri;
        belge["id"] = belgeId;
        var (_, yeniUyarilar) = await KaydetIcAsync(baglanti, islem, belge, satirlar,
                                                    secenekler, baglam, iptal, belgeId,
                                                    korunanSayisi: korunan.Count);
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
        await using var komut = baglanti.Komut("""
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
            """, islem,
            belgeId, cikis);
        await komut.ExecuteNonQueryAsync(iptal);

        // Lot bakiyeleri: belgenin izlem satirlari ters isaretle geri alinir.
        await using var lot = baglanti.Komut("""
            update public.stok_lot_durum l
               set kalan = l.kalan + case when @p1 then i.miktar else -i.miktar end
              from (select stok_id, depo_id, seri_lot_id, sum(adet) as miktar
                      from public.stok_izleme
                     where belge_id = @p0 and seri_lot_id is not null
                     group by 1, 2, 3) i
             where l.stok_id = i.stok_id and l.depo_id = i.depo_id
               and l.seri_lot_id = i.seri_lot_id
            """, islem,
            belgeId, cikis);
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
        bool cariAtla = false,
        // YERINDE KALAN (korunan) SATIR SAYISI: donusumle dogmus ya da baska
        //   kayitlarin kullandigi satirlar istemci govdesinden ATILIR - belge
        //   yine de bos degildir. Sayilmazsa "Belgede en az bir satir olmali"
        //   diyerek fisin kaydini reddediyordu (kullanici: fisi acip
        //   "Değişiklikleri Kaydet" deyince belge kayboldu).
        int korunanSayisi = 0)
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
        // SIPARIS/BASVURU (19) SATIRSIZ acilabilir: kayit kabulde once basvuru
        //   acilir (hasta gelir, protokol verilir), hizmetler muayene sirasinda
        //   eklenir. Diger turlerde bos belge anlamsizdir - stok/cari etkisi
        //   olmayan bir kayit numara tuketirdi.
        if (satirlar.Count + korunanSayisi == 0 && tur != BelgeTuru.SatisSiparisi)
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
        await BelgeTarihiKontrolAsync(baglanti, islem, belge, iptal, baglam.ZamanDilimi);

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
            await using var komut = baglanti.Komut("""
                select adres, ilce, il from public.taraf_adres where id = @p0 and taraf_id = @p1
                """, islem,
                adresId, tarafId);
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
            await using var komut = baglanti.Komut("""
                select coalesce(nullif(unvan, ''), ad) as unvan, vkno, efatura_alias, ebelge_seri
                  from public.sube where id = @p0
                """, islem,
                subeId);
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

        // SEVKIYAT ayri tabloda (177): plaka/sofor/tasiyici/teslim bilgileri.
        //   Satir yalniz bilgi girilmisse acilir; bosaltilmissa silinir.
        // 1:1 UZANTILAR (tek yazici, BelgeDeposu.Yazma.UzantiYazAsync): satir
        //   yalniz dolu bilgi varsa acilir, bosaltilinca silinir.
        await UzantiYazAsync(baglanti, islem, "public.belge_sevkiyat", SevkiyatKolonlari,
                             belgeId, belge, baglam, iptal);
        // Basvuru (296/298): bolum, personel, odeyen kurum, kabul alanlari.
        await UzantiYazAsync(baglanti, islem, "public.belge_basvuru", BasvuruKolonlari,
                             belgeId, belge, baglam, iptal);
        // Provizyon (299): SGK/MEDULA ve ozel sigorta alanlari.
        await UzantiYazAsync(baglanti, islem, "public.belge_provizyon", ProvizyonKolonlari,
                             belgeId, belge, baglam, iptal);

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
            {
                // e-BELGE NUMARAYI BIZ VERMEYIZ (kullanici): e-Fatura/e-Arsiv ya da
                //   e-Irsaliye acikken numara ENTEGRATORDEN gelir; kendi sayacimizi
                //   harcarsak ayni belge iki numara tasir ve seri bosluklu kalir.
                //   Numara alani "0" ile birakilir, gonderim sonucu gercek numarayi
                //   yazar (Delphi'de de FATURANO = 0 bekliyor).
                if (await EBelgeNumaraliMiAsync(baglanti, islem, tur, baglam.SubeId, iptal))
                    await NumaraSifirlaAsync(baglanti, islem, belgeId, iptal);
                else
                    await NumaraVerAsync(baglanti, islem, belgeId, tur,
                                         Metin(belge, "belgeSeri"), baglam.SubeId, iptal);
            }
        }

        // --------------------------------------------------------- 7b) MUHASEBE FISI ----
        // Kesin belge muhasebeye de girer (190). Taslak fislenmez: numarasi ve
        //   kesinligi yok. SUBE AYARI (192) belirler: entegrasyon kapaliysa ya da
        //   fis uretimi "gun sonu / elle" secilmisse burada uretilmez, toplu
        //   fisleme yapar. Fis uretimi belgeyi DUSURMEZ: eslemesi eksikse uyari
        //   doner, belge kaydi ayakta kalir ve hata KALICI IZ birakir
        //   (muhasebe_fis_hata) - "kac belge fislenmedi" sorusu cevaplanabilsin.
        if (!secenekler.Taslak)
        {
            try
            {
                // TUR de sorulur (280): siparis/teklif/talep/irsaliye/konsinye
                //   ve transfer TAAHHUT belgesidir - mali sonuc faturada dogar,
                //   fis kesilirse ayni tutar fatura fisinde IKINCI kez girer.
                await using var fis = baglanti.Komut("""
                    select case when public.fn_belge_fis_uretilsin(@p2, @p3)
                                then public.fn_belge_fisle(@p0, @p1) end
                    """, islem,
                    belgeId, baglam.KullaniciId, (object?)baglam.SubeId ?? DBNull.Value, tur);
                await fis.ExecuteScalarAsync(iptal);
            }
            catch (PostgresException h)
            {
                uyarilar.Add("Muhasebe fişi üretilemedi: " + h.MessageText);
                await using var iz = baglanti.Komut("""
                    insert into public.muhasebe_fis_hata
                           (kaynak_tur, kaynak_id, hata_mesaji, sube_id, ekleyen)
                    values (2, @p0, left(@p1, 500), @p2, @p3)
                    on conflict (kaynak_tur, kaynak_id) where cozuldu = 0
                    do update set hata_mesaji = excluded.hata_mesaji,
                                  deneme_tarihi = now()::timestamp
                    """, islem,
                    belgeId, h.MessageText, (object?)baglam.SubeId ?? DBNull.Value, baglam.KullaniciId);
                await iz.ExecuteNonQueryAsync(iptal);
            }
        }

        // ------------------------------------------------------------------ 8) log ----
        // Belge no bilgiye yazilir: kayit SILINDIKTEN sonra da log listesinde
        //   Kod cozulebilsin (canli kayitta join zaten cozuyor). Numara bu
        //   noktada verilmis oluyor (7. adim).
        await using var noKomut = baglanti.Komut(
            "select belge_no from public.belge where id = @p0", islem, belgeId);
        var logBelgeNo = (await noKomut.ExecuteScalarAsync(iptal))?.ToString() ?? "";

        await _log.YazAsync(baglanti, islem,
            mevcutId > 0 ? LogIslemi.Degistir : LogIslemi.Ekle, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
                ["belgeNo"] = logBelgeNo,
                ["tarafId"] = tarafId.ToString(CultureInfo.InvariantCulture),
                ["satirAdedi"] = satirlar.Count.ToString(CultureInfo.InvariantCulture),
                ["taslak"] = secenekler.Taslak ? "1" : "0"
            },
            tarafId: tarafId, iptal: iptal);

        return (belgeId, uyarilar);
    }

    /// <summary>Belge turunun stok/cari etkisi - katalogtan (kasa_islem_turu).</summary>
    private static async Task<(bool Stok, bool Cari)> TurEtkileriAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, int tur, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut(
            "select stok_etkiler, cari_etkiler from public.kasa_islem_turu where kod = @p0", islem,
            (short)tur);
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
        IDictionary<string, object?> belge, CancellationToken iptal,
        string? zamanDilimi = null)
    {
        if (!belge.TryGetValue("belgeTarihi", out var ham) || ham is null) return;
        if (ham is not DateTime tarih)
        {
            if (!DateTime.TryParse(Convert.ToString(ham, CultureInfo.InvariantCulture),
                                   CultureInfo.InvariantCulture, DateTimeStyles.None, out tarih))
                return;
        }

        // SUBENIN saati (666): konteyner UTC calisirken kullanicinin yerel
        //   saatini "ileri tarihli" saymasin - ve cok ulkeli kurumda "yerel"
        //   kurulusun degil, BELGENIN KESILDIGI subenin saatidir.
        var simdi = Saat.SimdiDilim(zamanDilimi);
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
        await using var komut = baglanti.Komut(
            "select cari_zorunlu from public.kasa_islem_turu where kod = @p0", islem,
            (short)tur);
        var d = await komut.ExecuteScalarAsync(iptal);
        return d is null or DBNull || Convert.ToInt32(d) == 1;
    }

    public async Task<List<DipToplamSatiri>> DipToplamAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int belgeId, CancellationToken iptal)
    {
        var sonuc = new List<DipToplamSatiri>();
        await using var komut = baglanti.Komut(
            "select * from public.fn_belge_diptoplam(@p0) order by d_tur", islem,
            belgeId);
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

    /// <summary>
    /// Bir belge satirinin BELGEYE YAZILAN brut tutari (KDV dahil), alias
    /// <c>hs</c> uzerinden. Donusen tutar iki yerde okunuyor (kartin
    /// "donusenBelgeTutari" seridi ve Donusum sekmesi gridi); matrahtan
    /// yeniden hesaplamak 500 TL'lik fisi gridde 500,01 gosteriyordu, o yuzden
    /// ikisi de AYNI ifadeyi kullanir. tutar_kdvli eski satirlarda bos olabilir
    /// - o zaman matrahtan turetilir.
    /// </summary>
    internal const string YazilanBrutSql = """
        case when coalesce(hs.tutar_kdvli, 0) > 0 then hs.tutar_kdvli
             else round(hs.tutar * (1 + coalesce(hs.kdv, 0) / 100.0), 2) end
        """;

    /// <summary>
    /// Silinmemesi gereken belge satirlari: donusmus (kapatilan_miktar) ya da
    /// baska bir kaydin (radyoloji istemi / konsultasyon / UTS bildirimi /
    /// kurum icmali / sigorta provizyonu) isaret ettigi satirlar.
    ///
    /// <para><b>belge_satir'a NO ACTION ile bagli HER tablo burada olmali.</b>
    /// Eksik kalan tablo kartin bir daha KAYDEDILEMEMESI demek (23503) - hata
    /// kaydetme aninda ve alakasiz bir mesajla cikiyor. `KorunanSatirTestleri`
    /// bu listeyi `pg_constraint` ile karsilastirir.</para>
    /// </summary>
    private const string KorunanSatirSql = """
        select s.id from public.belge_satir s
         where s.belge_id = @p0
           and (
                (@p1 and coalesce(s.kapatilan_miktar, 0) > 0)
             or exists (select 1 from public.radyoloji_istem r
                         where r.belge_satir_id = s.id)
             or exists (select 1 from public.radyoloji_konsultasyon k
                         where k.belge_satir_id = s.id)
             or exists (select 1 from public.uts_bildirim u
                         where u.belge_satir_id = s.id)
             or exists (select 1 from public.kurum_icmal_satir i
                         where i.belge_satir_id = s.id)
             -- GOZ GORUNTULEMESI / ISLEMI OLAN SATIR (691): radyoloji
             --   istemiyle ayni kural - OCT cekildikten ya da enjeksiyon
             --   uygulandiktan sonra ucret satiri silinip yeniden yazilirsa
             --   klinik kayit sahipsiz kalir; veritabani da birakmaz
             --   (NO ACTION).
             or exists (select 1 from public.goz_goruntuleme gg
                         where gg.belge_satir_id = s.id)
             or exists (select 1 from public.goz_islem gi
                         where gi.ucret_belge_satir_id = s.id)
             -- PROVIZYONA GIRMIS SATIR (kullanici: basvuru kaydet ->
             --   "sigorta_provizyon_satir_belge_satir_id_fkey"): sirkete
             --   gonderilen satirin kimligi hospitalRowNumber olarak
             --   provizyonda DURUYOR - yanittaki tutar kirilimi bizim
             --   satirimiza o numarayla baglaniyor. Satir silinip yeniden
             --   yazilsa yeni id alir ve kirilim hicbir satira oturmaz;
             --   veritabani da zaten birakmiyor (NO ACTION).
             or exists (select 1 from public.sigorta_provizyon_satir sp
                         where sp.belge_satir_id = s.id)
             -- TAHSILAT DAGITIMI OLAN SATIR: kasa_islem_dagitim satira
             --   CASCADE ile bagli; satir silinip yeniden yazilinca dagitim
             --   (ve ona bagli hakedis_satir) sessizce yok oluyordu. Basvuru
             --   yeniden kaydedilince "tahsil edilen kadar" hesabi sifira
             --   dusuyor, kesilen fis geri alinamiyor ve prim kayboluyordu
             --   (kullanici: fisi silip basvuruyu kaydettikten sonra).
             or exists (select 1 from public.kasa_islem_dagitim d
                         where d.belge_satir_id = s.id)
             -- DONUSUMLE DOGMUS SATIR (kullanici: "fişi açıp Değişiklikleri
             --   Kaydet dedim, belge kayboldu"): hedef satirin kaynak bagi
             --   (kaynak_tur = 30) istemci govdesinde YOK; satir silinip
             --   yeniden yazilinca bag kopuyor, kaynak basvurunun
             --   kapatilan_miktar tetigi geri donuyor ve fis "Dönüşüm"
             --   listesinden kayboluyordu. Bagli satir yerinde kalir.
             or (s.kaynak_tur = 30 and coalesce(s.kaynak_id, 0) > 0)
             -- BASKA SATIRIN KAYNAGI OLAN SATIR (kullanici: "500 fiş kestim,
             --   açık belge 400'e düşmeliydi"): tutar bazli donusumde
             --   kapatilan_miktar ARTMAZ (miktar degil TUTAR kapanir), bu
             --   yuzden kaynak satir "donusmus" sayilmiyor ve basvuru
             --   kaydedilince silinip yeniden yaziliyordu. Silinince dagilim
             --   (cascade) ve hedefin kaynak bagi da gidiyor, kapatilan
             --   sifirlaniyordu.
             or exists (select 1 from public.belge_satir h
                         where h.kaynak_tur = 30 and h.kaynak_id = s.id)
           )
        """;
}
