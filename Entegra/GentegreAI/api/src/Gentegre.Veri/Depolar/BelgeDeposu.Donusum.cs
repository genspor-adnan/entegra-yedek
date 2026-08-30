using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// BELGE DONUSUMU (F8) - siparis -> irsaliye -> fatura zinciri.
///
/// Donusum AYRI BIR BELGE yazar; kaynakla bagi satir duzeyindedir
/// (belge_satir.kaynak_id) - kismi donusum bu bagla takip edilir ve kalan
/// miktar kaynak satirda kalir. Zincirin geriye izlenmesi (DonusumlerAsync) ve
/// acik satirlarin listelenmesi de burada.
/// </summary>
public sealed partial class BelgeDeposu
{

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
        string? belgeNo = null,
        // ODEME PAYLASIMI (289): 0 tum satir · 1 yalniz HASTA payi · 2 yalniz
        //   KURUM payi. Pay donusumunde hedef belgenin CARISI de degisir:
        //   kurum payi kuruma faturalanir, hastaya degil.
        short pay = 0)
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
                   b.teklif_durum,
                   b.rapor_dovizi, b.ekstre_dovizi,
                   -- Fiyatlama kimligi (274): liste BAZ, kampanya INDIRIM verdi;
                   --   ikisi de hedefe TASINIR - basvurudan cikan fatura
                   --   "hangi anlasmayla" kesildigini kaybetmemeli.
                   b.fiyat_listesi_id, b.kampanya_id, b.odeyen_kurum_id,
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

        // TEKLIF yalniz KABUL (3) durumundayken siparise donusur (kullanici):
        //   sunulmamis/reddedilmis teklif taahhude cevrilmemeli.
        if (Convert.ToInt32(kaynak["tur"]) == 18
            && Convert.ToInt32(kaynak["teklif_durum"] ?? 1) != 3)
            throw GentegreHatasi.IsKurali(
                "Teklif yalnız KABUL durumundayken siparişe dönüştürülebilir.");

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
                   s.stok_durum_degis, s.proje_id, s.kalan_miktar, s.belge_id,
                   s.kurum_tutar, s.hasta_tutar, s.kurum_kapatilan, s.hasta_kapatilan
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

            if (pay > 0)
            {
                // PAY DONUSUMU: sinir miktar degil TUTAR. Ayni pay ikinci kez
                //   donusturulemez - yoksa kurum payi iki faturaya girerdi.
                var payTutar = Convert.ToDecimal((pay == 1 ? ks2["hasta_tutar"] : ks2["kurum_tutar"]) ?? 0m);
                var payKapanan = Convert.ToDecimal(
                    (pay == 1 ? ks2["hasta_kapatilan"] : ks2["kurum_kapatilan"]) ?? 0m);
                if (payTutar - payKapanan <= 0)
                    throw GentegreHatasi.IsKurali(
                        pay == 1 ? "Bu satırın hasta payı zaten kapatılmış."
                                 : "Bu satırın kurum payı zaten kapatılmış.");
            }
            else if (miktar > kalan)
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
                stokDurumDegis: stokDusecek ? 1 : 0, izlemler, pay));
        }

        // --------------------------------------------------- 3) hedef baslik ----
        var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["tur"] = hedefTur,
            ["tipi"] = kaynak["tipi"],
            // KURUM PAYI KURUMA FATURALANIR (289): hedef belgenin carisi hasta
            //   degil odeyen kurumdur - fatura sigortaya/SGK'ya kesilir.
            ["tarafId"] = pay == 2 && kaynak["odeyen_kurum_id"] is { } ok
                          ? ok : kaynak["taraf_id"],
            ["tarafUnvan"] = kaynak["taraf_unvan"],
            ["tarafVkno"] = kaynak["taraf_vkno"],
            ["tarafVd"] = kaynak["taraf_vd"],
            ["tarafAdresId"] = kaynak["taraf_adres_id"],
            ["belgeTarihi"] = belgeTarihi ?? Saat.Simdi,
            ["belgeDovizi"] = kaynak["belge_dovizi"],
            ["dovizKuru"] = kaynak["doviz_kuru"],
            // RAPOR ve EKSTRE DOVIZI de kopyalanir: yalniz KUR tasinip doviz
            //   TL'ye dusunce belge "480 TL" gibi gorunuyordu - tutar EUR
            //   cinsinden hesaplanmis ama etiketi TL kalmisti (gercek vaka).
            ["raporDovizi"] = kaynak["rapor_dovizi"],
            ["ekstreDovizi"] = kaynak["ekstre_dovizi"],
            ["kdvDurum"] = kaynak["kdv_durum"],
            // FIYAT LISTESI + KAMPANYA + ODEYEN KURUM (274): satirlar zaten
            //   kaynagin fiyatiyla kopyalanir, tutar degismez - tasinan sey
            //   KIMLIK. Kopyalanmazsa basvurudan cikan fatura kurumsuz ve
            //   kampanyasiz aciliyor, sonradan eklenen kalem cari fiyatina
            //   dusuyordu (ayni belgede iki farkli fiyat politikasi).
            ["fiyatListesiId"] = kaynak["fiyat_listesi_id"],
            ["kampanyaId"] = kaynak["kampanya_id"],
            ["odeyenKurumId"] = kaynak["odeyen_kurum_id"],
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
}
