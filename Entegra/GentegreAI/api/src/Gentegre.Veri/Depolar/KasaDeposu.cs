using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Kasa (mali) islem kaydetme - API §9. HEPSI YA DA HICBIRI: baslik, bacaklar,
/// muhasebe fisi, yan etkiler ve islem_log TEK TRANSACTION icinde yazilir.
///
/// IS KURALLARI BURADA DEGIL, MOTORDA (076_fn_kasa.sql): bacak uretimi, denge,
/// fisleme ve iptal veritabani fonksiyonlaridir. Bu sinif sadece istegi
/// dogrular, kur/snapshot doldurur ve motoru cagirir. Kurali iki yerde
/// tutmak, iki farkli sonuc demektir.
///
/// MAKBUZ NUMARASI EN SON: fn_kasa_islem_kesinlestir once dogrular ve fisler,
/// numarayi en sonda satir kilidi altinda uretir - rollback numarayi harcamaz.
/// </summary>
public sealed partial class KasaDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    /// <summary>islem_log tablo kodu (078 seed): 908 = kasa_islem.</summary>
    private const int LogTabloKasa = 908;

    /// <summary>Motorun is-kurali hatalari bu SQLSTATE ile gelir (076).</summary>
    private const string IsKuraliKodu = "GK422";

    public KasaDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    // ================================================================ yazma ====
    public async Task<(int Id, List<string> Uyarilar)> KaydetAsync(
        IDictionary<string, object?> islem,
        List<Dictionary<string, JsonElement>>? bacaklar,
        KasaSecenekleri secenekler,
        YazmaBaglami baglam,
        CancellationToken iptal = default,
        CekSenetGirisi? cekSenet = null)
    {
        var uyarilar = new List<string>();

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        var tur = (int)Sayi(islem, "tur");
        if (tur <= 0)
            throw GentegreHatasi.Dogrulama("İşlem türü seçilmeli.", new AlanHatasi("tur", "Zorunlu."));

        var katalog = await TurOkuAsync(baglanti, tx, tur, iptal)
            ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen işlem türü: {tur}",
                   new AlanHatasi("tur", "Katalogda yok."));

        if (baglam.SubeId is { } sube) islem["subeId"] = sube;

        await TarafSnapshotAsync(baglanti, tx, islem, iptal);
        await DovizDoldurAsync(baglanti, tx, islem, secenekler, uyarilar, iptal);

        // Durum: plan > taslak > (gerceklesecek). Gerceklesme kesinlestirmede olur.
        islem["durum"] = secenekler.Plan ? KasaDurum.Planli : KasaDurum.Taslak;
        islem["islemNo"] = "";
        if (secenekler.BelgeId is { } bId) islem["belgeId"] = bId;

        // CEK/SENET: kiymet basliktan ONCE acilir - motor bacagi uretirken
        //   cek_senet_id'yi hazir bulmali (yoksa 422 "kiymet secilmeli").
        //   Plan/taslak dahil her durumda acilir: plan da belirli bir cekin
        //   vadesidir. Kiymetsiz gelen cek/senet turu erken ve okunur biter.
        var cekSenetId = 0;
        if (KasaHesap.CekSenetTuru(tur))
        {
            if (cekSenet is null)
                throw GentegreHatasi.Dogrulama(
                    "Çek/senet bilgileri girilmeli (vade zorunlu).",
                    new AlanHatasi("cekSenet", "Zorunlu."));
            cekSenetId = await CekSenetEkleAsync(baglanti, tx, tur, cekSenet, islem, baglam, iptal);
            islem["cekSenetId"] = cekSenetId;
        }

        var id = await BaslikEkleAsync(baglanti, tx, islem, baglam, iptal);

        if (cekSenetId > 0)
            await CekSenetBaglaAsync(baglanti, tx, cekSenetId, id, islem, baglam, iptal);

        // Bacaklar: istemci vermediyse sablondan uretilir (normal akis).
        if (bacaklar is { Count: > 0 })
            await BacakYazAsync(baglanti, tx, id, bacaklar, islem, baglam, iptal);
        else
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_bacak_uret(@p0)",
                             new object?[] { id }, iptal);

        if (!secenekler.Taslak && !secenekler.Plan)
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_kesinlestir(@p0, @p1)",
                             new object?[] { id, baglam.KullaniciId }, iptal);

        await _log.YazAsync(baglanti, tx, LogIslemi.Ekle, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
                ["turAdi"] = katalog.Ad,
                ["tutar"] = Ondalik(islem, "tutar").ToString(CultureInfo.InvariantCulture),
                ["dovizCinsi"] = Metin(islem, "dovizCinsi"),
                ["durum"] = (secenekler.Taslak || secenekler.Plan ? "taslak" : "gerceklesti")
            },
            tarafId: SayiNull(islem, "tarafId"), iptal: iptal);

        await tx.CommitAsync(iptal);
        return (id, uyarilar);
    }

    /// <summary>Taslak/plan duzenleme. Gerceklesmis islem degistirilemez - iptal edilir.</summary>
    public async Task<List<string>> GuncelleAsync(
        int id, IDictionary<string, object?> islem,
        List<Dictionary<string, JsonElement>>? bacaklar,
        KasaSecenekleri secenekler, string? surum,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        var uyarilar = new List<string>();

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        int durum;
        string mevcutSurum;
        await using (var komut = new NpgsqlCommand(
            "select durum, xmin::text as surum from public.kasa_islem where id = @p0 for update",
            baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", id);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            durum = o.Sayi("durum");
            mevcutSurum = o.Metin("surum");
        }

        if (!string.IsNullOrEmpty(surum) && surum != mevcutSurum)
            throw GentegreHatasi.Cakisma(new { id, surum = mevcutSurum });

        if (durum >= KasaDurum.Gerceklesti)
            throw GentegreHatasi.IsKurali(
                "Gerçekleşmiş işlem değiştirilemez - İptal edip yeniden girin.");

        await TarafSnapshotAsync(baglanti, tx, islem, iptal);
        await DovizDoldurAsync(baglanti, tx, islem, secenekler, uyarilar, iptal);
        islem.Remove("durum");
        islem.Remove("islemNo");

        await BaslikGuncelleAsync(baglanti, tx, id, islem, baglam, iptal);

        if (bacaklar is { Count: > 0 })
        {
            await using var sil = new NpgsqlCommand(
                "delete from public.mali_hareket where kasa_islem_id = @p0", baglanti, tx);
            sil.Parameters.AddWithValue("p0", id);
            await sil.ExecuteNonQueryAsync(iptal);

            var tam = await BaslikSozlukAsync(baglanti, tx, id, iptal);
            await BacakYazAsync(baglanti, tx, id, bacaklar, tam, baglam, iptal);
        }
        else
        {
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_bacak_uret(@p0)",
                             new object?[] { id }, iptal);
        }

        if (!secenekler.Taslak && !secenekler.Plan)
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_kesinlestir(@p0, @p1)",
                             new object?[] { id, baglam.KullaniciId }, iptal);

        await _log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["alanSayisi"] = islem.Count.ToString(CultureInfo.InvariantCulture) },
            tarafId: SayiNull(islem, "tarafId"), iptal: iptal);

        await tx.CommitAsync(iptal);
        return uyarilar;
    }

    public async Task KesinlestirAsync(int id, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_kesinlestir(@p0, @p1)",
                         new object?[] { id, baglam.KullaniciId }, iptal);

        await _log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["aksiyon"] = "kesinlestir" }, iptal: iptal);

        await tx.CommitAsync(iptal);
    }

    /// <summary>Iptal = ters baslik + ters fis. Kayit SILINMEZ (izlenebilirlik).</summary>
    public async Task<int> IptalAsync(int id, string sebep, DateTime? tarih,
                                      YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        int yeniId;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_kasa_islem_iptal(@p0, @p1, @p2, @p3)", baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", id);
            komut.Parameters.AddWithValue("p1", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p2", (object?)tarih?.Date ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", sebep ?? "");
            yeniId = Convert.ToInt32(await CalistirAsync(komut, iptal));
        }

        await _log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "iptal",
                ["sebep"] = sebep ?? "",
                ["tersIslemId"] = yeniId.ToString(CultureInfo.InvariantCulture)
            }, iptal: iptal);

        await tx.CommitAsync(iptal);
        return yeniId;
    }

    /// <summary>
    /// Plan gerceklesmesi (K10): plan DEGISMEZ, yeni bir islem basligi acilir ve
    /// plandan yalniz `gerceklesen_tutar` birikir. Kismi gerceklesme dogaldir.
    /// </summary>
    public async Task<int> PlanGerceklestirAsync(int planId, int hesapId, decimal? tutar,
        DateTime? tarih, int? tur, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        int yeniId;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_plan_gerceklestir(@p0, @p1, @p2, @p3::date, @p4, @p5)", baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", planId);
            komut.Parameters.AddWithValue("p1", hesapId);
            komut.Parameters.AddWithValue("p2", (object?)tutar ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", (object?)tarih?.Date ?? DBNull.Value);
            komut.Parameters.AddWithValue("p4", (object?)tur ?? DBNull.Value);
            komut.Parameters.AddWithValue("p5", baglam.KullaniciId);
            yeniId = Convert.ToInt32(await CalistirAsync(komut, iptal));
        }

        await _log.YazAsync(baglanti, tx, LogIslemi.Ekle, LogTabloKasa, yeniId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "plan-gerceklestir",
                ["planId"] = planId.ToString(CultureInfo.InvariantCulture),
                ["tutar"] = (tutar ?? 0).ToString(CultureInfo.InvariantCulture)
            }, iptal: iptal);

        await tx.CommitAsync(iptal);
        return yeniId;
    }

    public async Task SilAsync(int id, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        // Gerceklesmis/fislenmis kayit DB trigger'i ile korunur (076) - burada
        //   tekrar kontrol etmiyoruz; tek kural kaynagi motor.
        await _log.YazAsync(baglanti, tx, LogIslemi.Sil, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["aksiyon"] = "sil" }, iptal: iptal);

        await using (var komut = new NpgsqlCommand(
            "delete from public.kasa_islem where id = @p0", baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", id);
            if (Convert.ToInt32(await CalistirAsync(komut, iptal, satirSayisi: true)) == 0)
                throw GentegreHatasi.Bulunamadi();
        }

        await tx.CommitAsync(iptal);
    }

    // ================================================================ okuma ====
    public async Task<KasaIslemYaniti?> OkuAsync(int id, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        IDictionary<string, object?>? baslik = null;
        await using (var komut = new NpgsqlCommand(BaslikSecim + " where ki.id = @p0", baglanti))
        {
            komut.Parameters.AddWithValue("p0", id);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) return null;
            baslik = Satir(o);
        }

        var bacaklar = new List<IDictionary<string, object?>>();
        await using (var komut = new NpgsqlCommand("""
            select m.id, m.sira, m.rol, m.hesap_turu as "hesapTuru", m.hesap_id as "hesapId",
                   h.ad as "hesapAdi", m.taraf_id as "tarafId", t.unvan as "tarafUnvan",
                   m.masraf_id as "masrafId", ms.ad as "masrafAdi",
                   m.hizmet_id as "hizmetId", hz.ad as "hizmetAdi",
                   m.proje_id as "projeId", p.ad as "projeAdi",
                   m.borc, m.alacak, m.yerel_borc as "yerelBorc", m.yerel_alacak as "yerelAlacak",
                   m.doviz_cinsi as "dovizCinsi", m.doviz_kuru as "dovizKuru", m.aciklama
              from public.mali_hareket m
              left join public.hesap  h  on h.id  = m.hesap_id
              left join public.taraf  t  on t.id  = m.taraf_id
              left join public.masraf ms on ms.id = m.masraf_id
              left join public.hizmet hz on hz.id = m.hizmet_id
              left join public.proje  p  on p.id  = m.proje_id
             where m.kasa_islem_id = @p0 order by m.sira
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", id);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal)) bacaklar.Add(Satir(o));
        }

        var fisId = baslik.TryGetValue("muhasebeFisId", out var f) && f is not null
                    ? Convert.ToInt32(f) : 0;

        return new KasaIslemYaniti
        {
            Islem = baslik,
            Bacaklar = bacaklar,
            Fis = fisId > 0 ? await FisOkuAsync(baglanti, fisId, iptal) : null
        };
    }

    public async Task<FisOzeti?> FisOkuAsync(NpgsqlConnection baglanti, int fisId, CancellationToken iptal)
    {
        FisOzeti? fis = null;
        await using (var komut = new NpgsqlCommand("""
            select id, fis_no, fis_tarihi, tur, durum, toplam_borc, toplam_alacak
              from public.muhasebe_fis where id = @p0
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", fisId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) return null;
            fis = new FisOzeti
            {
                Id = o.Sayi("id"),
                FisNo = o.Metin("fis_no"),
                FisTarihi = o.Tarih("fis_tarihi") ?? default,
                Tur = o.Sayi("tur"),
                Durum = o.Sayi("durum"),
                ToplamBorc = o.GetDecimal(o.GetOrdinal("toplam_borc")),
                ToplamAlacak = o.GetDecimal(o.GetOrdinal("toplam_alacak"))
            };
        }

        var satirlar = new List<FisSatiriOzeti>();
        await using (var komut = new NpgsqlCommand("""
            select s.sira, hp.kod, hp.ad, s.borc, s.alacak, s.doviz_cinsi,
                   s.doviz_borc, s.doviz_alacak, s.aciklama
              from public.muhasebe_fis_satir s
              join public.hesap_plani hp on hp.id = s.hesap_plani_id
             where s.fis_id = @p0 order by s.sira
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", fisId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
                satirlar.Add(new FisSatiriOzeti(
                    o.Sayi("sira"), o.Metin("kod"), o.Metin("ad"),
                    o.GetDecimal(o.GetOrdinal("borc")), o.GetDecimal(o.GetOrdinal("alacak")),
                    o.Metin("doviz_cinsi"),
                    o.GetDecimal(o.GetOrdinal("doviz_borc")), o.GetDecimal(o.GetOrdinal("doviz_alacak")),
                    o.Metin("aciklama")));
        }

        fis.Satirlar = satirlar;
        return fis;
    }

    public async Task<FisOzeti?> FisOkuAsync(int fisId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await FisOkuAsync(baglanti, fisId, iptal);
    }

    /// <summary>
    /// Tur katalogu - BELGE turleri de dahil (grup='belge'). Kasa karti kendi
    /// grubunu suzer; belge karti da tur adini/gruplarini buradan okur, boylece
    /// tur adlari istemciye ikinci kez kopyalanmaz.
    /// </summary>
    public async Task<List<KasaIslemTuru>> TurlerAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select kod, ad, grup, yon, ana_hesap_turu, karsi_hesap_turu, cari_zorunlu,
                   kalem_turu, plan_mi, fis_mi, fis_turu, makbuz_basligi, sablon::text as sablon
              from public.kasa_islem_turu
             where aktif = 1
             order by sira, kod
            """, baglanti);

        var liste = new List<KasaIslemTuru>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new KasaIslemTuru
            {
                Kod = o.Sayi("kod"),
                Ad = o.Metin("ad"),
                Grup = o.Metin("grup"),
                Yon = o.Sayi("yon"),
                AnaHesapTuru = o.Metin("ana_hesap_turu"),
                KarsiHesapTuru = o.Metin("karsi_hesap_turu"),
                CariZorunlu = o.Sayi("cari_zorunlu"),
                KalemTuru = o.Sayi("kalem_turu"),
                PlanMi = o.Bayrak("plan_mi"),
                FisMi = o.Bayrak("fis_mi"),
                FisTuru = o.Sayi("fis_turu"),
                MakbuzBasligi = o.Metin("makbuz_basligi"),
                Sablon = JsonDocument.Parse(o.Metin("sablon")).RootElement.Clone()
            });
        return liste;
    }

    /// <summary>Ekranin kur kutusu icin: o tarihin kuru (yoksa onceki en yakin gun).</summary>
    public async Task<decimal?> KurAsync(string dovizCinsi, DateTime tarih, int yon,
                                         CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand(
            "select public.fn_doviz_kur_getir(@p0, @p1::date, @p2::smallint)", baglanti);
        komut.Parameters.AddWithValue("p0", dovizCinsi ?? "TL");
        komut.Parameters.AddWithValue("p1", tarih.Date);
        komut.Parameters.AddWithValue("p2", (short)yon);
        var sonuc = await komut.ExecuteScalarAsync(iptal);
        return sonuc is null or DBNull ? null : Convert.ToDecimal(sonuc);
    }

    /// <summary>
    /// Kurun GERCEKTEN hangi gune ait oldugu. fn_doviz_kur_getir istenen tarihe
    /// kur yoksa onceki en yakin gunu kullanir; arayuz "24.08 kuru" derken aslinda
    /// 18.08 kurunu gosteriyor olabilirdi - kullanici bunu bilmeli.
    /// </summary>
    public async Task<DateTime?> KurTarihiAsync(string dovizCinsi, DateTime tarih,
                                                CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select tarih from public.doviz_kur
             where doviz_cinsi = public.fn_doviz_iso(@p0) and tarih <= @p1::date
             order by tarih desc limit 1
            """, baglanti);
        komut.Parameters.AddWithValue("p0", dovizCinsi ?? "TL");
        komut.Parameters.AddWithValue("p1", tarih.Date);
        var sonuc = await komut.ExecuteScalarAsync(iptal);
        return sonuc is null or DBNull ? null : Convert.ToDateTime(sonuc);
    }

    // ============================================================ yardimcilar ====
    private const string BaslikSecim = """
        select ki.id, ki.tur, kt.ad as "turAdi", kt.grup as "turGrup",
               ki.islem_no as "islemNo", ki.makbuz_no as "makbuzNo",
               ki.islem_tarihi as "islemTarihi", ki.plan_tarihi as "planTarihi", ki.durum,
               ki.taraf_id as "tarafId", ki.taraf_unvan as "tarafUnvan",
               ki.karsi_taraf_id as "karsiTarafId",
               ki.hesap_id as "hesapId", h.ad as "hesapAdi",
               ki.karsi_hesap_id as "karsiHesapId", kh.ad as "karsiHesapAdi",
               ki.doviz_cinsi as "dovizCinsi", ki.tutar, ki.doviz_kuru as "dovizKuru",
               ki.yerel_tutar as "yerelTutar",
               ki.karsi_doviz_cinsi as "karsiDovizCinsi", ki.karsi_tutar as "karsiTutar",
               ki.karsi_kur as "karsiKur",
               ki.masraf_tutar as "masrafTutar", ki.masraf_id as "masrafId",
               ki.hizmet_id as "hizmetId", ki.proje_id as "projeId", p.ad as "projeAdi",
               ki.merkez_id as "merkezId", ki.belge_id as "belgeId",
               ki.plan_islem_id as "planIslemId", ki.gerceklesen_tutar as "gerceklesenTutar",
               ki.kalan_tutar as "kalanTutar", ki.iptal_islem_id as "iptalIslemId",
               ki.muhasebe_fis_id as "muhasebeFisId", ki.aciklama, ki.sube_id as "subeId",
               ki.xmin::text as surum
          from public.kasa_islem ki
          left join public.kasa_islem_turu kt on kt.kod = ki.tur
          left join public.hesap h  on h.id  = ki.hesap_id
          left join public.hesap kh on kh.id = ki.karsi_hesap_id
          left join public.proje p  on p.id  = ki.proje_id
        """;

    private static string JsonMetin(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() ?? "" : "";

    private static decimal JsonOndalik(Dictionary<string, JsonElement> d, string ad, decimal varsayilan)
        => d.TryGetValue(ad, out var v) && v.ValueKind == JsonValueKind.Number ? v.GetDecimal() : varsayilan;

    private static int? JsonSayiNull(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var v) && v.ValueKind == JsonValueKind.Number ? v.GetInt32() : null;
}
