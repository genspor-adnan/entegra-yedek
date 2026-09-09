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
        // Tutar (352): doluysa satirdan miktar degil o TUTAR (matrah) kadar
        //   donusturulur - tutar bazli kismi donusum. Miktar hedef satirin
        //   miktaridir (kaynak miktari), birim fiyat tutar/miktar olur.
        IReadOnlyList<(int SatirId, decimal Miktar, decimal? Tutar, decimal? TutarKdvli)> secilen,
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

        // TUTAR BAZLI donusum pay mekanizmasiyla yurur (289 sayaclari tutar
        //   uzerinden): pay secilmemisse HASTA payi (1) sayilir - odeyen kurum
        //   yoksa satirin tamami zaten hasta payidir (Yazma: hastaTutar = tutar).
        var tutarBazli = secilen.Any(s => (s.Tutar ?? 0) > 0);
        if (tutarBazli && pay == 0) pay = 1;

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
                   b.fiyat_listesi_id, b.kampanya_id, bb.odeyen_kurum_id,
                   -- Kurum payi kuruma faturalanirken KIMLIK de kurumundur:
                   --   unvan ve vergi bilgisi hastadan kopyalanirsa fatura
                   --   yanlis kisiye kesilmis gorunur (289).
                   ok.unvan as odeyen_unvan, ok.vkno as odeyen_vkno,
                   -- SGK CARISI (468): TSS/Karma'da SGK payi ODEYENDEN farkli
                   --   bir cariye faturalanir; sozlesmeden okunur.
                   sz.sgk_kurum_id,
                   (select t2.unvan from public.taraf t2 where t2.id = sz.sgk_kurum_id)
                     as sgk_kurum_unvan,
                   ok.vd as odeyen_vd,
                   b.proje_id, b.sube_id, b.vade_gun, b.giris_depo_id, b.cikis_depo_id,
                   b.satici_id, bb.bolum_id, bb.personel_id,
                   b.ozel_kod, b.aciklama, b.belge_no, kt.ad as tur_adi
              from public.belge b
              left join public.belge_basvuru bb on bb.id = b.id
              left join public.kasa_islem_turu kt on kt.kod = b.tur
              left join public.taraf ok on ok.id = bb.odeyen_kurum_id
              left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
             where b.id = @p0
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", kaynakBelgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Kaynak belge bulunamadı.");
            kaynak = o.Sozluk();
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
                   s.tutar, s.tutar_kdvli, s.birim_fiyat_kdvli,
                   -- DAGILIM KOVALARI (470): donusum artik ince pay koduyla
                   --   calisir - SGK tahakkuku ile sigorta faturasi ayri
                   --   belgelere gider, ikisi tek "kurum payi" degildir.
                   coalesce(dg.sgk, 0) as dg_sgk, coalesce(dg.oss, 0) as dg_oss,
                   coalesce(dg.hasta_provizyon, 0) as dg_hasta_provizyon,
                   coalesce(dg.hasta_ek_katki, 0) as dg_hasta_ek_katki,
                   coalesce(dg.sgk_kapatilan, 0) as dg_sgk_kapatilan,
                   coalesce(dg.oss_kapatilan, 0) as dg_oss_kapatilan,
                   coalesce(dg.hasta_provizyon_kapatilan, 0) as dg_hasta_provizyon_kapatilan,
                   coalesce(dg.hasta_ek_katki_kapatilan, 0) as dg_hasta_ek_katki_kapatilan
              from public.belge_satir s
              left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
             where s.id = any(@p0)
             order by s.sira
             -- KILIT YALNIZ KAYNAK SATIRDA (`of s`): `for update` tek basina
             --   PG'de "cannot be applied to the nullable side of an outer
             --   join" ile patliyordu - dagilim satiri LEFT JOIN'in bos
             --   olabilen tarafi. Dagilim 1:1 ve yalniz OKUNUYOR; kilitlenmesi
             --   gereken kaynak satirin kendisi.
             for update of s
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", idler);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
            {
                var satir = o.Sozluk();
                kaynakSatirlar[Convert.ToInt32(satir["id"])] = satir;
            }
        }

        foreach (var (satirId, miktarSecim, tutarSecim, brutSecim) in secilen)
        {
            if (!kaynakSatirlar.TryGetValue(satirId, out var ks2))
                throw GentegreHatasi.Bulunamadi($"Kaynak satır bulunamadı: {satirId}");
            if (Convert.ToInt32(ks2["belge_id"]) != kaynakBelgeId)
                throw GentegreHatasi.Dogrulama("Satır bu belgeye ait değil.",
                    new AlanHatasi($"satirlar[{satirId}]", "Başka belgenin satırı."));

            var kalan = Convert.ToDecimal(ks2["kalan_miktar"] ?? 0m);
            // Tutar bazli satirda hedef miktar kaynagin miktaridir: 1 adet
            //   1000 TL'lik hizmet "1 adet 300 TL" olarak gider, 0,3 adet degil.
            var miktar = tutarBazli && (tutarSecim ?? 0) > 0
                ? Convert.ToDecimal(ks2["miktar"] ?? 0m) : miktarSecim;
            if (miktar <= 0)
                throw GentegreHatasi.Dogrulama("Miktar sıfırdan büyük olmalı.",
                    new AlanHatasi($"satirlar[{satirId}].miktar", "Sıfırdan büyük olmalı."));

            decimal? payTutarSecim = null;
            if (pay > 0)
            {
                // DAGILIMI OLMAYAN SATIR (ERP belgesi ya da eski kayit): tutar
                //   bazli donusum istenince satir o anda HASTA EK KATKISI =
                //   matrah olarak dagitilir; sayaclar boylece bu satirda da
                //   tutar uzerinden calisir (478 - eski pay kolonlari dustu).
                var kovaToplam = Convert.ToDecimal(ks2["dg_sgk"] ?? 0m)
                               + Convert.ToDecimal(ks2["dg_oss"] ?? 0m)
                               + Convert.ToDecimal(ks2["dg_hasta_provizyon"] ?? 0m)
                               + Convert.ToDecimal(ks2["dg_hasta_ek_katki"] ?? 0m);
                if (tutarBazli && pay is 1 or 4 && kovaToplam == 0)
                {
                    var matrah = Convert.ToDecimal(ks2["tutar"] ?? 0m);
                    await using var payKomut = new NpgsqlCommand("""
                        insert into public.belge_satir_dagilim
                               (belge_satir_id, rota, hasta_ek_katki, elle)
                        values (@p0, 1, @p1, 1)
                        on conflict (belge_satir_id) do update
                           set hasta_ek_katki = excluded.hasta_ek_katki, elle = 1
                        """, baglanti, islem);
                    payKomut.Parameters.AddWithValue("p0", satirId);
                    payKomut.Parameters.AddWithValue("p1", matrah);
                    await payKomut.ExecuteNonQueryAsync(iptal);
                    ks2["dg_hasta_ek_katki"] = matrah;
                    // Hasta payi istendiyse EK KATKI kovasindan gider.
                    if (pay == 1) pay = 4;
                }

                // PAY DONUSUMU: sinir miktar degil TUTAR. Ayni pay ikinci kez
                //   donusturulemez - yoksa kurum payi iki faturaya girerdi.
                // KOVA ADI PAY KODUNDAN (470): 1 hasta provizyon · 2 sgk ·
                //   3 oss · 4 hasta ek katki. Katilim payi (5) donusturulemez -
                //   ciro degil, SGK'ya emanettir.
                if (pay == 5)
                    throw GentegreHatasi.IsKurali(
                        "SGK katılım payı belgeye dönüştürülemez - ciro değil, SGK'ya emanettir.");
                var kovaAd = pay switch
                {
                    2 => "dg_sgk", 3 => "dg_oss", 4 => "dg_hasta_ek_katki",
                    _ => "dg_hasta_provizyon",
                };
                var payTutar = Convert.ToDecimal(ks2[kovaAd] ?? 0m);
                var payKapanan = Convert.ToDecimal(ks2[kovaAd + "_kapatilan"] ?? 0m);
                var payKalan = payTutar - payKapanan;
                if (payKalan <= 0)
                    throw GentegreHatasi.IsKurali(pay switch
                    {
                        2 => "Bu satırın SGK payı zaten kapatılmış.",
                        3 => "Bu satırın sigorta payı zaten kapatılmış.",
                        4 => "Bu satırın hasta ek katkısı zaten kapatılmış.",
                        _ => "Bu satırın hasta payı zaten kapatılmış.",
                    });

                // TUTAR SECIMI (352): payin kalanindan KUCUK bir tutar da
                //   donusturulebilir (tahsil edilen kadar fis); kalan kaynakta
                //   acik kalir ve sonra tahakkuka/fise cevrilir.
                if ((tutarSecim ?? 0) > 0)
                {
                    if (tutarSecim > payKalan + 0.005m)
                        throw GentegreHatasi.IsKurali(
                            $"Seçilen tutar payın kalanını aşıyor (istenen {tutarSecim:0.00}, kalan {payKalan:0.00}).");
                    payTutarSecim = decimal.Round(tutarSecim!.Value, 4);
                }
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
                stokDurumDegis: stokDusecek ? 1 : 0, izlemler, pay, payTutarSecim,
                // GIRILEN BRUT (kullanici): hedefin KDV dahil fiyati bundan
                //   yazilir; matrah brutten turetilir ve "500 girdim 499,99
                //   kesti" farki kapanir.
                payBrutSecim: (brutSecim ?? 0) > 0 ? decimal.Round(brutSecim!.Value, 4) : null));
        }

        // --------------------------------------------------- 3) hedef baslik ----
        var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["tur"] = hedefTur,
            ["tipi"] = kaynak["tipi"],
            // KURUM PAYI KURUMA FATURALANIR (289): hedef belgenin carisi hasta
            //   degil odeyen kurumdur - fatura sigortaya/SGK'ya kesilir.
            // KURUM PAYLARI (2 SGK · 3 sigorta) kuruma faturalanir; hasta
            //   kovalari (1 provizyon · 4 ek katki) hastaya. SGK carisi
            //   sozlesmede ayri tutulur (TSS/Karma'da odeyenden FARKLIDIR) -
            //   BelgeDonusum sorgusu onu `sgk_kurum_id` olarak getirir.
            ["tarafId"] = pay == 2 && kaynak["sgk_kurum_id"] is { } sk ? sk
                          : pay is 2 or 3 && kaynak["odeyen_kurum_id"] is { } ok
                          ? ok : kaynak["taraf_id"],
            ["tarafUnvan"] = pay == 2 && kaynak["sgk_kurum_unvan"] is { } su ? su
                             : pay is 2 or 3 && kaynak["odeyen_unvan"] is { } ou
                             ? ou : kaynak["taraf_unvan"],
            ["tarafVkno"] = pay is 2 or 3 ? kaynak["odeyen_vkno"] : kaynak["taraf_vkno"],
            ["tarafVd"] = pay is 2 or 3 ? kaynak["odeyen_vd"] : kaynak["taraf_vd"],
            ["tarafAdresId"] = kaynak["taraf_adres_id"],
            ["belgeTarihi"] = belgeTarihi ?? Saat.Simdi,
            ["belgeDovizi"] = kaynak["belge_dovizi"],
            ["dovizKuru"] = kaynak["doviz_kuru"],
            // RAPOR ve EKSTRE DOVIZI de kopyalanir: yalniz KUR tasinip doviz
            //   TL'ye dusunce belge "480 TL" gibi gorunuyordu - tutar EUR
            //   cinsinden hesaplanmis ama etiketi TL kalmisti (gercek vaka).
            ["raporDovizi"] = kaynak["rapor_dovizi"],
            ["ekstreDovizi"] = kaynak["ekstre_dovizi"],
            // KDV DURUMU HEDEF TURE GORE (372) - kaynaktan KOPYALANMAZ.
            //   Basvuru ve tahakkuk KDV DAHIL belgelerdir (hastaya/kuruma
            //   soylenen rakam brut); FATURA ve FIS ise matrahla kesilir -
            //   "fis/faturaya cevirirken birim fiyattan kdv cikacak"
            //   (kullanici). Kopyalansaydi basvurudan cikan fatura da "Dahil"
            //   dogar ve KDV iki kez sayilirdi.
            //   Tahakkuk turleri: 17 satis, 13 alis.
            //   BASVURUDAN (19) DOGAN BELGE DE DAHIL (kullanici: "500 TL fiş
            //   girdim ama 499,99 TL kesti"): hastaya soylenen rakam brut ve
            //   kurus cinsinden karsiligi olmayabiliyor (500 / 1,10 =
            //   454,5454...). "Hariç" belgede dip toplam KDV'yi MATRAHTAN
            //   yeniden hesapliyor ve 454,54 + 45,45 = 499,99 cikiyordu.
            //   "Dahil" belgede matrah bruttten turetilir, KDV = brut - matrah
            //   olur ve girilen rakam birebir tutar. Satir yine matrahla
            //   yazilir - fatura uzerinde KDV ayri satirdir.
            ["kdvDurum"] = hedefTur is 17 or 13 || Convert.ToInt32(kaynak["tur"]) == 19
                           ? "Dahil" : "Hariç",
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
            // Basvurudan turetilen belge bolumu/hekimi tasir (296): fatura
            //   hangi poliklinikte uretildigini kaybetmesin.
            ["bolumId"] = kaynak["bolum_id"],
            ["personelId"] = kaynak["personel_id"],
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
