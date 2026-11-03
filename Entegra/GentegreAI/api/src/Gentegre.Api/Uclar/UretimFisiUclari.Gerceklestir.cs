using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>ÜRETİM FİŞİ - GERÇEKLEŞTİRME: maliyet (IAS 2), sarf / fire / giriş belgeleri, FEFO lot, otomatik çıktı lotu.</summary>
public static partial class UretimFisiUclari
{
    /// <summary>
    /// GERÇEKLEŞTİR: maliyeti hesapla, belgeleri kes, fişi 2'ye al, emir sayaçlarını yaz. Çağıranın işleminde (K12: fiş ile
    /// belgeler tek transaction - biri yazılıp öteki yazılmazsa stokta mal var fişte yok görünürdü).
    /// </summary>
    private static async Task<List<string>> GerceklestirAsync(NpgsqlConnection b, NpgsqlTransaction t, BelgeDeposu belgeDepo, LogDeposu log,
                                                              IstekBaglami baglam, int id, bool eksiyeIzin, CancellationToken iptal)
    {
        var bas = await BaslikOkuAsync(b, t, id, iptal, kilitle: true);
        if (bas.Durum != Taslak) throw GentegreHatasi.IsKurali("Yalnız taslak fiş gerçekleştirilir.");
        if (bas.SarfDepoId is not > 0) throw GentegreHatasi.IsKurali("Sarf deposu seçilmeli.");
        var girisDepo = bas.GirisDepoId ?? bas.SarfDepoId.Value;
        var (seviye, _) = await SeviyeOkuAsync(b, t, iptal);
        // MALZEME EKSİKKEN KAYIT (uretim_basit.html ③): basit uyarıyla izin, standart yetkiyle (kart "Değiştir" yetkisi zaten var -
        //   eksiye düşme ayrıca stok.negatif_davranis'a tabi), denetimli YOK.
        if (eksiyeIzin && seviye == SeviyeDenetimli)
            throw GentegreHatasi.IsKurali("Denetimli seviyede malzeme eksikken üretim kaydedilmez.");

        var satirlar = await b.ListeAsync("""
            select s.id, s.grup, s.stok_id, s.ad, s.ana_urun, s.miktar, s.birim_maliyet, s.elle_maliyet, s.fire_turu, s.izlemler::text,
                   coalesce(st.izleme, 0), coalesce(st.raf_omru_sure, 0), coalesce(st.raf_omru_birim, 0), coalesce(st.kod, ''), coalesce(st.ad, '')
              from public.uretim_fisi_satir s left join public.stok st on st.id = s.stok_id
             where s.fis_id = @p0 order by s.grup, s.sira, s.id for update of s
            """, t, [id], o => new Satir(o.GetInt32(0), o.GetInt16(1), o.IsDBNull(2) ? null : o.GetInt32(2), o.GetString(3), o.GetInt16(4) == 1,
                                        o.GetDecimal(5), o.GetDecimal(6), o.GetInt16(7) == 1, o.GetInt16(8),
                                        o.IsDBNull(9) ? null : o.GetString(9), o.GetInt32(10), o.GetInt32(11), o.GetInt32(12),
                                        o.GetString(13), o.GetString(14)), iptal);
        var ana = satirlar.FirstOrDefault(s => s.Grup == 4 && s.AnaUrun)
            ?? throw GentegreHatasi.IsKurali("Fişte ana ürün (çıktı) satırı yok.");
        if (ana.Miktar <= 0) throw GentegreHatasi.IsKurali("Ana ürün miktarı sıfırdan büyük olmalı.");
        if (!satirlar.Any(s => s.Grup == 1 && s.Miktar > 0))
            throw GentegreHatasi.IsKurali("Sarf satırı yok - ürün ağacından doldurun ya da malzeme ekleyin.");

        // SARF / FİRE BİRİM MALİYETİ: otomatik hesapta yöntemden (son / ortalama) HAREKET ANINDA okunur; elle değer korunur.
        var maliyetFn = bas.MaliyetYontemi == 1 ? "public.fn_uretim_stok_son_maliyeti" : "public.fn_uretim_stok_maliyeti";
        var maliyet = new Dictionary<int, decimal>();
        foreach (var s in satirlar.Where(s => s.Grup is 1 or 3 && s.StokId is > 0))
        {
            var m = s.BirimMaliyet;
            if (bas.OtomatikHesap || m <= 0)
                m = await b.TekDegerAsync<decimal>($"select {maliyetFn}(@p0)", t, [s.StokId], iptal);
            maliyet[s.Id] = m;
        }
        decimal Tutar(Satir s) => decimal.Round(s.Miktar * (maliyet.TryGetValue(s.Id, out var m) ? m : s.BirimMaliyet), 4);
        var malzeme   = satirlar.Where(s => s.Grup == 1).Sum(Tutar);
        var iscilik   = satirlar.Where(s => s.Grup == 2).Sum(Tutar);
        var fireNorm  = satirlar.Where(s => s.Grup == 3 && s.FireTuru != 2).Sum(Tutar);
        var fireAnorm = satirlar.Where(s => s.Grup == 3 && s.FireTuru == 2).Sum(Tutar);
        var yanUrun   = satirlar.Where(s => s.Grup == 4 && !s.AnaUrun).Sum(Tutar);
        var toplam    = malzeme + iscilik + fireNorm;
        var anaMaliyet = Math.Max(0, toplam - yanUrun);
        var birimMaliyet = decimal.Round(anaMaliyet / ana.Miktar, 4);

        var yazma = new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip);
        var secenek = new BelgeSecenekleri { Taslak = false, StokKontrolu = !eksiyeIzin };
        var uyarilar = new List<string>();

        // 1) SARF ÇIKIŞI (121): izlemli stokta lot seçilmemişse FEFO (SKT'si yakın önce) otomatik.
        var sarfSatirlari = new List<Dictionary<string, JsonElement>>();
        var sira = 0;
        foreach (var s in satirlar.Where(s => s.Grup == 1 && s.Miktar > 0))
            sarfSatirlari.Add(await BelgeSatiriAsync(b, t, s, maliyet[s.Id], bas.SarfDepoId.Value, cikis: true, ++sira, bas.No, bas, iptal));
        var (sarfBelgeId, u1) = await belgeDepo.KaydetAsync(b, t, Belge(BelgeTuru.SarfCikisi, bas, baglam, "cikisDepoId", bas.SarfDepoId.Value,
            $"Üretim sarfı · {bas.No}"), sarfSatirlari, secenek, yazma, iptal);
        uyarilar.AddRange(u1);

        // 2) FİRE ÇIKIŞI (123): birim maliyetli - normal fire mamule yüklenir, anormal ayrı toplanır (açıklamada yazar).
        int? fireBelgeId = null;
        var fireler = satirlar.Where(s => s.Grup == 3 && s.Miktar > 0).ToList();
        if (fireler.Count > 0)
        {
            var fireSatirlari = new List<Dictionary<string, JsonElement>>();
            sira = 0;
            foreach (var s in fireler)
                fireSatirlari.Add(await BelgeSatiriAsync(b, t, s, maliyet[s.Id], bas.SarfDepoId.Value, cikis: true, ++sira,
                    (s.FireTuru == 2 ? "anormal fire · " : "normal fire · ") + (s.Ad.Length > 0 ? s.Ad : bas.No), bas, iptal));
            var (fid, u2) = await belgeDepo.KaydetAsync(b, t, Belge(BelgeTuru.FireCikisi, bas, baglam, "cikisDepoId", bas.SarfDepoId.Value,
                $"Fire · {bas.No}"), fireSatirlari, secenek, yazma, iptal);
            fireBelgeId = fid; uyarilar.AddRange(u2);
        }

        // 3) ÜRETİM GİRİŞİ (122): ana ürün hesaplanan birim maliyetle, yan ürün elle değeriyle; izlemli çıktıya lot verilir
        //   (satırdaki lot, yoksa parti no / otomatik L-yyMM-no; SKT raf ömründen).
        var girisSatirlari = new List<Dictionary<string, JsonElement>>();
        sira = 0;
        foreach (var s in satirlar.Where(s => s.Grup == 4 && s.Miktar > 0))
            girisSatirlari.Add(await BelgeSatiriAsync(b, t, s, s.AnaUrun ? birimMaliyet : s.BirimMaliyet, girisDepo, cikis: false, ++sira,
                s.AnaUrun ? "ana ürün" : "yan ürün", bas, iptal));
        var (girisBelgeId, u3) = await belgeDepo.KaydetAsync(b, t, Belge(BelgeTuru.UretimGirisi, bas, baglam, "girisDepoId", girisDepo,
            $"Üretim girişi · {bas.No}"), girisSatirlari, new BelgeSecenekleri { Taslak = false, StokKontrolu = false }, yazma, iptal);
        uyarilar.AddRange(u3);

        // Satır maliyetleri ve fiş toplamları.
        foreach (var s in satirlar)
        {
            var m = s.Grup == 4 && s.AnaUrun ? birimMaliyet : maliyet.TryGetValue(s.Id, out var x) ? x : s.BirimMaliyet;
            await b.CalistirAsync("update public.uretim_fisi_satir set birim_maliyet = @p1, tutar = round(miktar * @p1, 4) where id = @p0",
                t, [s.Id, m], iptal);
        }
        await b.CalistirAsync("""
            update public.uretim_fisi
               set durum = 2, seviye = @p1, uretilen = @p2, malzeme = @p3, iscilik = @p4, fire_normal = @p5, fire_anormal = @p6,
                   yan_urun = @p7, toplam = @p8, birim_maliyet = @p9, sarf_belge_id = @p10, giris_belge_id = @p11, fire_belge_id = @p12,
                   gerceklesme_an = now(), gerceklestiren = @p13, bit = coalesce(bit, now()), degistiren = @p13, degistirme_tarihi = now()
             where id = @p0
            """, t, [id, seviye, ana.Miktar, malzeme, iscilik, fireNorm, fireAnorm, yanUrun, anaMaliyet, birimMaliyet,
                     sarfBelgeId, girisBelgeId, fireBelgeId, baglam.KullaniciId], iptal);

        if (bas.EmirId is > 0)
            await EmirSayacAsync(b, t, bas.EmirId.Value, id, geri: false, baglam.KullaniciId, iptal);

        await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new { gerceklesti = true, seviye, uretilen = ana.Miktar, malzeme, iscilik, fireNormal = fireNorm, fireAnormal = fireAnorm,
                  yanUrun, toplam = anaMaliyet, birimMaliyet, sarfBelgeId, girisBelgeId, fireBelgeId,
                  karantina = seviye == SeviyeDenetimli }, stokId: bas.StokId, iptal: iptal);
        if (seviye == SeviyeDenetimli)
            uyarilar.Add("Çıktı KARANTİNADA: kalite kontrol listesi tamamlanıp serbest bırakılmadan satılabilir sayılmaz.");
        return uyarilar;
    }

    private sealed record Satir(int Id, short Grup, int? StokId, string Ad, bool AnaUrun, decimal Miktar, decimal BirimMaliyet, bool ElleMaliyet,
                                short FireTuru, string? IzlemlerJson, int Izleme, int RafSure, int RafBirim, string StokKod, string StokAd);

    private static Dictionary<string, object?> Belge(int tur, Baslik bas, IstekBaglami baglam, string depoAlani, int depoId, string aciklama)
        => new(StringComparer.Ordinal)
        {
            ["tur"] = tur, ["tipi"] = 1, ["belgeTarihi"] = bas.Bas ?? Saat.Simdi, ["belgeDovizi"] = "TL", ["dovizKuru"] = 1m,
            [depoAlani] = depoId, ["subeId"] = baglam.SubeId ?? bas.SubeId,
            ["kaynakTur"] = BelgeTuru.KaynakTurUretimFisi, ["kaynakId"] = bas.Id, ["aciklama"] = aciklama,
        };

    /// <summary>Fiş satırı → belge satırı. Çıkışta izlemli stokta lot yoksa FEFO; girişte lot yoksa parti / otomatik numara.</summary>
    private static async Task<Dictionary<string, JsonElement>> BelgeSatiriAsync(NpgsqlConnection b, NpgsqlTransaction t, Satir s, decimal birimFiyat,
        int depoId, bool cikis, int sira, string aciklama, Baslik bas, CancellationToken iptal)
    {
        var alanlar = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["tur"] = 1, ["stokId"] = s.StokId, ["miktar"] = s.Miktar, ["birimFiyat"] = birimFiyat, ["kdv"] = 0, ["dovizCinsi"] = "TL",
            [cikis ? "cikisDepoId" : "girisDepoId"] = depoId, ["aciklama"] = aciklama, ["sira"] = sira,
        };
        if (s.Izleme > 0)
        {
            List<object> izlemler = [];
            if (!string.IsNullOrEmpty(s.IzlemlerJson))
            {
                var dizi = JsonSerializer.Deserialize<JsonElement>(s.IzlemlerJson);
                if (dizi.ValueKind == JsonValueKind.Array)
                    foreach (var e in dizi.EnumerateArray())
                    {
                        var d = JsonDeger.JsonNesne(e);
                        var m = JsonDeger.JsonOndalik(d, "miktar", 0);
                        if (m <= 0) continue;
                        izlemler.Add(new Dictionary<string, object?>
                        {
                            ["seriLotId"] = JsonDeger.JsonSayiNull(d, "seriLotId"), ["lotNo"] = JsonDeger.JsonMetin(d, "lotNo"),
                            ["seriNo"] = JsonDeger.JsonMetin(d, "seriNo"), ["uretimTarihi"] = JsonDeger.JsonTarih(d, "uretimTarihi"),
                            ["sonKullanmaTarihi"] = JsonDeger.JsonTarih(d, "sonKullanmaTarihi"), ["durum"] = 0, ["miktar"] = m,
                        });
                    }
            }
            if (izlemler.Count == 0)
                izlemler = cikis ? await LotFefoAsync(b, t, s, depoId, iptal) : OtomatikLot(s, bas);
            alanlar["izlemler"] = izlemler;
        }
        return BelgeGovdesi.Satir(alanlar);
    }

    /// <summary>FEFO: SKT'si en yakın lottan başlayarak miktarı karşıla (uretim_emri_v2 "Rezervasyon FEFO"). Yetmezse 422.</summary>
    private static async Task<List<object>> LotFefoAsync(NpgsqlConnection b, NpgsqlTransaction t, Satir s, int depoId, CancellationToken iptal)
    {
        var lotlar = await b.ListeAsync("""
            select ld.seri_lot_id, ld.kalan from public.stok_lot_durum ld join public.stok_seri_lot l on l.id = ld.seri_lot_id
             where ld.stok_id = @p0 and ld.depo_id = @p1 and ld.kalan > 0
             order by l.son_kullanma_tarihi asc nulls last, ld.seri_lot_id
            """, t, [s.StokId, depoId], o => new { Id = o.GetInt32(0), Kalan = o.GetDecimal(1) }, iptal);
        var kalan = s.Miktar; var sonuc = new List<object>();
        foreach (var l in lotlar)
        {
            if (kalan <= 0) break;
            var al = Math.Min(l.Kalan, kalan); kalan -= al;
            sonuc.Add(new Dictionary<string, object?> { ["seriLotId"] = l.Id, ["miktar"] = al, ["durum"] = 0 });
        }
        if (kalan > 0.0001m)
            throw GentegreHatasi.IsKurali($"{s.StokKod} {s.StokAd}: depodaki lotlar {s.Miktar:0.####} miktarı karşılamıyor ({kalan:0.####} eksik) - lot seçin ya da miktarı düşürün.");
        return sonuc;
    }

    /// <summary>Çıktıya lot: parti no, yoksa L-yyMM-<fiş sırası>; SKT raf ömründen (gün / ay / yıl), üretim tarihi fiş tarihi.</summary>
    private static List<object> OtomatikLot(Satir s, Baslik bas)
    {
        var tarih = bas.Bas ?? Saat.Simdi;
        var lotNo = bas.PartiNo.Length > 0 ? bas.PartiNo : $"L-{tarih:yyMM}-{bas.No[(bas.No.LastIndexOf('/') + 1)..]}";
        DateTime? skt = s.RafSure > 0 ? s.RafBirim switch { 1 => tarih.AddDays(s.RafSure), 3 => tarih.AddYears(s.RafSure), _ => tarih.AddMonths(s.RafSure) } : null;
        var kural = (lot: s.Izleme is 2 or 5 or 6, seri: s.Izleme is 1 or 6);
        var liste = new List<object>();
        if (kural.seri && !kural.lot)
        {
            // Seri izlemede her adet ayrı seri: SN-yyMMdd-001…
            var adet = (int)Math.Ceiling(s.Miktar);
            for (var i = 1; i <= adet; i++)
                liste.Add(new Dictionary<string, object?> { ["lotNo"] = "", ["seriNo"] = $"SN-{tarih:yyMMdd}-{i:000}", ["uretimTarihi"] = tarih,
                    ["sonKullanmaTarihi"] = skt, ["durum"] = 0, ["miktar"] = i == adet ? s.Miktar - (adet - 1) : 1m });
            return liste;
        }
        liste.Add(new Dictionary<string, object?> { ["lotNo"] = lotNo, ["seriNo"] = kural.seri ? $"SN-{tarih:yyMMdd}-001" : "",
            ["uretimTarihi"] = tarih, ["sonKullanmaTarihi"] = skt, ["durum"] = 0, ["miktar"] = s.Miktar });
        return liste;
    }
}
