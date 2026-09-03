using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Okuma yardimcilari: veri satirindan / JSON govdesinden tip donusumleri. Is kurali YOK - yalnizca 'null ise sifir, metin ise kirp' turu donusumler.
/// </summary>
public sealed partial class BelgeDeposu
{
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
                   b.rapor_dovizi as "raporDovizi", b.ekstre_dovizi as "ekstreDovizi",
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
                   -- BASVURU UZANTISI (296, belge_basvuru 1:1): basvurulan
                   --   bolum ve hekim. Randevusuz acilan basvuruda da
                   --   girilebilsin diye BELGEDE tutulur, randevudan okunmaz.
                   bb.bolum_id as "bolumId", coalesce(bl.ad, '') as "bolumAdi",
                   bb.personel_id as "personelId", coalesce(hk.unvan, '') as "personelAdi",
                   -- Basvuru sekmesi alanlari (298).
                   bb.basvuru_turu as "basvuruTuru", bb.gelis_sekli as "gelisSekli",
                   bb.gelis_nedeni as "gelisNedeni", bb.oda, bb.sira_no as "siraNo",
                   bb.refakatci,
                   -- Ambulans (300): odeyiciden bagimsiz, basvuruya ait kimlik.
                   bb.ambulans_hasta_no as "ambulansHastaNo",
                   bb.ambulans_bileklik_no as "ambulansBileklikNo",
                   -- PROVIZYON (299) ayri 1:1 tabloda. SGK ve ozel sigorta
                   --   AYNI ANDA olabilir: iki ayri alan takimi.
                   bp.sgk_durum as "sgkDurum", bp.sgk_provizyon_no as "sgkProvizyonNo",
                   bp.sgk_provizyon_tipi as "sgkProvizyonTipi",
                   bp.sgk_provizyon_tarihi as "sgkProvizyonTarihi",
                   bp.sgk_gecerlilik as "sgkGecerlilik",
                   bp.sgk_karsilama as "sgkKarsilama", bp.sgk_tutar as "sgkTutar",
                   bp.sgk_red_nedeni as "sgkRedNedeni",
                   bp.sgk_sigorta_turu as "sgkSigortaTuru",
                   -- SGK'da IKI numara var: basvuru (muracaat) ve o basvuru
                   --   altindaki takip; faturalama TAKIP no uzerinden yapilir.
                   bp.sgk_basvuru_no as "sgkBasvuruNo", bp.sgk_takip_no as "sgkTakipNo",
                   bp.sgk_takip_tarihi as "sgkTakipTarihi",
                   bp.sgk_takip_turu as "sgkTakipTuru", bp.sgk_tesis_kodu as "sgkTesisKodu",
                   bp.sgk_mustehaklik as "sgkMustehaklik",
                   bp.sgk_mustehaklik_zaman as "sgkMustehaklikZaman",
                   bp.sgk_sevkli as "sgkSevkli", bp.sgk_sevk_kurum as "sgkSevkKurum",
                   bp.oss_kurum_id as "ossKurumId",
                   coalesce(ok2.unvan, '') as "ossKurumAdi",
                   bp.oss_durum as "ossDurum", bp.oss_provizyon_no as "ossProvizyonNo",
                   bp.oss_provizyon_tarihi as "ossProvizyonTarihi",
                   bp.oss_gecerlilik as "ossGecerlilik",
                   bp.oss_karsilama as "ossKarsilama", bp.oss_tutar as "ossTutar",
                   bp.oss_red_nedeni as "ossRedNedeni",
                   bp.oss_police_no as "ossPoliceNo", bp.oss_hasar_no as "ossHasarNo",
                   bp.oss_brans as "ossBrans",
                   bp.aciklama as "provizyonAciklama",
                   b.vade_gun as "vadeGun",
                   -- Basvuruda (249) vade yerine odeyen kurum gosterilir.
                   bb.odeyen_kurum_id as "odeyenKurumId",
                   coalesce(ok.unvan, '') as "odeyenKurumAdi",
                   -- SEVKIYAT ayri tabloda (177): kaydi olmayan belgede gorunum
                   --   bos deger dondurur, sozlesme (alan adlari) degismedi.
                   sv.teslim_sekli as "teslimSekli",
                   sv.arac_plaka as "aracPlaka", sv.sofor_ad as "soforAd",
                   sv.sofor_tckn as "soforTckn", sv.teslim_eden_id as "teslimEdenId",
                   td.unvan as "teslimEdenAdi",
                   sv.teslim_alan_id as "teslimAlanId", ta.unvan as "teslimAlanAdi",
                   b.proje_id as "projeId", b.efatura_durum as "efaturaDurum",
                   -- Belgenin fiyat listesi (205) + adi: kart basliginda gosterilir.
                   b.fiyat_listesi_id as "fiyatListesiId",
                   coalesce(fl.ad, '') as "fiyatListesiAdi",
                   -- Belgeye isleyen kampanya (274): baslikta ROZET olarak
                   --   gorunur - "hangi anlasmayla fiyatlandi" belgenin uzerinde.
                   b.kampanya_id as "kampanyaId",
                   coalesce(nullif(kmp.kod, '') || ' · ', '')
                     || coalesce(kmp.ad, '') as "kampanyaAdi",
                   -- Teklif durumu (218) + revize no (220): yalniz tur 18'de anlamli.
                   b.teklif_durum as "teklifDurum",
                   b.revize_no as "revizeNo",
                   b.teklif_konusu as "teklifKonusu", b.teklif_teslim as "teklifTeslim",
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
                   -- Muhasebe fisi (190) ve zincirin ILERI ucu (F8): kartta
                   --   gosterilmez ama aksiyonlarin aktifligi bunlara bakar.
                   coalesce(b.muhasebe_fis_id, 0) as "fisId",
                   coalesce((select min(hs.belge_id) from public.belge_satir hs
                               join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
                               join public.belge hb on hb.id = hs.belge_id
                              where ks.belge_id = b.id and hb.durum <> 2), 0) as "hedefId",
                   b.xmin::text as surum
              from public.belge b
              left join public.fiyat_listesi fl on fl.id = b.fiyat_listesi_id
              left join public.kampanya kmp on kmp.id = b.kampanya_id
              left join public.depo  cd on cd.id = b.cikis_depo_id
              left join public.depo  gd on gd.id = b.giris_depo_id
              left join public.taraf sc on sc.id = b.satici_id
              left join public.belge_basvuru bb on bb.id = b.id
              left join public.belge_provizyon bp on bp.id = b.id
              left join public.taraf ok2 on ok2.id = bp.oss_kurum_id
              left join public.departman bl on bl.id = bb.bolum_id
              left join public.taraf     hk on hk.id = bb.personel_id
              left join public.taraf ok on ok.id = bb.odeyen_kurum_id
              join public.v_belge_sevkiyat sv on sv.belge_id = b.id
              left join public.taraf td on td.id = sv.teslim_eden_id
              left join public.taraf ta on ta.id = sv.teslim_alan_id
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
                   s.birim_carpan as "birimCarpan",
                   s.birim_fiyat as "birimFiyat", s.iskonto, s.iskonto2, s.kdv,
                   s.otv_yuzde as "otvYuzde", s.otv_miktar as "otvMiktar", s.tutar,
                   s.doviz_cinsi as "dovizCinsi", s.doviz_birim_fiyat as "dovizBirimFiyat",
                   s.doviz_tutari as "dovizTutari", s.doviz_kuru as "dovizKuru",
                   s.giris_depo_id as "girisDepoId", s.cikis_depo_id as "cikisDepoId",
                   s.izleme_kodu as "izlemeKodu",
                   -- Kart satiri KOD ve AD gosterir; id'yi ekranda kimse okuyamaz.
                   --   Satir hizmet ya da masraf olabilir: kod/ad hangisi doluysa
                   --   ondan gelir (hizmet satirinda stok bos, kart bos gorunuyordu).
                   coalesce(nullif(st.kod, ''), nullif(hz.kod, ''),
                            nullif(ms.kod, ''), '') as "stokKodu",
                   coalesce(nullif(st.ad, ''), nullif(hz.ad, ''),
                            nullif(ms.ad, ''), '') as "stokAdi",
                   coalesce(hz.ad, '')  as "hizmetAdi", coalesce(ms.ad, '') as "masrafAdi",
                   s.kapatilan_miktar as "kapatilanMiktar", s.kalan_miktar as "kalanMiktar",
                   s.kaynak_tur as "kaynakTur", s.kaynak_id as "kaynakId",
                   s.teslim_tarihi as "teslimTarihi", s.rezerve,
                   -- Odeme paylasimi (289): kurum/hasta payi ve kapanma sayaclari.
                   s.kurum_tutar as "kurumTutar", s.hasta_tutar as "hastaTutar",
                   s.karsilama, s.provizyon_no as "provizyonNo",
                   s.kurum_kapatilan as "kurumKapatilan",
                   s.hasta_kapatilan as "hastaKapatilan",
                   -- Kalemi fiyatlayan kampanya kurali (274) - satir geri
                   --   yuklendiginde bag korunsun, Kaydet onu silmesin.
                   s.kampanya_satir_id as "kampanyaSatirId"
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

        // Kalemin LOT dagilimi: kart acilinca kullanici hangi lottan kac adet
        //   girdigini geri gormeli (114). Izlemsiz belgede sorgu bos doner.
        await using (var komut = new NpgsqlCommand("""
            select i.belge_satir_id as "satirId", i.lot_no as "lotNo", i.seri_no as "seriNo",
                   i.uretim_tarihi as "uretimTarihi", i.son_kullanma_tarihi as "sonKullanmaTarihi",
                   i.durum, i.adet as "miktar", i.kalan
              from public.v_belge_satir_izlem i
             where i.belge_id = @p0
             order by i.belge_satir_id, i.id
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            var haritali = new Dictionary<int, List<IDictionary<string, object?>>>();
            while (await okuyucu.ReadAsync(iptal))
            {
                var kayit = Satir(okuyucu);
                var satirId = Convert.ToInt32(kayit["satirId"]);
                if (!haritali.TryGetValue(satirId, out var liste))
                    haritali[satirId] = liste = new List<IDictionary<string, object?>>();
                liste.Add(kayit);
            }
            foreach (var s in satirlar)
                if (s.TryGetValue("id", out var sid) && sid is not null &&
                    haritali.TryGetValue(Convert.ToInt32(sid), out var liste))
                    s["izlemler"] = liste;
        }

        var dip = await DipToplamAsync(baglanti, null, belgeId, iptal);
        return (belge!, satirlar, dip);
    }

    /// <summary>
    /// Kaynak satiri hedef satir JSON'una cevirir (fiyat/iskonto/KDV aynen tasinir).
    ///
    /// PAY DONUSUMU (289): `pay` 1 (hasta) ya da 2 (kurum) verilirse hedef satir
    /// o payin TUTARIYLA uretilir - birim fiyat pay tutarindan turetilir ve
    /// iskonto sifirlanir (indirim zaten pay hesabina girmistir). Boylece ayni
    /// basvuru satiri iki ayri belgeye (hasta fisi + kurum faturasi) bolunebilir.
    /// </summary>
    private static Dictionary<string, JsonElement> SatirJson(
        IDictionary<string, object?> k, decimal miktar, int kaynakSatirId, int stokDurumDegis,
        IReadOnlyList<object>? izlemler = null, short pay = 0,
        // TUTAR SECIMI (352): pay donusumunde payin kalaninin TAMAMI yerine
        //   verilen tutar kadar - "tahsil edilen 300 TL'si fis". Kalan kaynakta.
        decimal? payTutarSecim = null)
    {
        var birimFiyat = k["birim_fiyat"];
        var dovizBirimFiyat = k["doviz_birim_fiyat"];
        var iskonto = k["iskonto"];
        var iskonto2 = k["iskonto2"];
        var payKalan = 0m;

        if (pay > 0)
        {
            var payTutar = Convert.ToDecimal(
                (pay == 1 ? k["hasta_tutar"] : k["kurum_tutar"]) ?? 0m);
            // Kalan pay: kismi donusumde ayni paydan ikinci kez alinmasin.
            var kapanan = Convert.ToDecimal(
                (pay == 1 ? k["hasta_kapatilan"] : k["kurum_kapatilan"]) ?? 0m);
            var kalan = payTutar - kapanan;
            if (payTutarSecim is { } secim && secim > 0 && secim < kalan) kalan = secim;
            payKalan = kalan;
            birimFiyat = miktar > 0 ? decimal.Round(kalan / miktar, 6) : kalan;
            // DOVIZ FIYATI DA PAYDAN: kaynaktan aynen kopyalaninca dip toplamin
            //   doviz sutunu KAYNAK fiyatiyla hesaplaniyor, belge.doviz_tutari
            //   oradan doluyor ve mali_hareket.borc onu kullaniyordu - 30 TL'lik
            //   hasta tahakkuku cariye 165 TL borc yaziyordu (gercek vaka).
            dovizBirimFiyat = birimFiyat;
            iskonto = 0m;
            iskonto2 = 0m;
        }

        var govde = new Dictionary<string, object?>
        {
            ["pay"] = pay,
            // PAY HEDEFTE SABITTIR: tutarlar acikca yazilmazsa kayit hatti
            //   satiri odeyen kuruma gore YENIDEN paylastiriyor - hasta payi
            //   tahakkuku "kurum payi" olarak isaretlenip donem icmaline
            //   giriyordu (ayni tutar ikinci kez kuruma faturalanirdi).
            ["kurumTutar"] = pay == 2 ? payKalan : pay == 1 ? 0m : (object?)null,
            ["hastaTutar"] = pay == 1 ? payKalan : pay == 2 ? 0m : (object?)null,
            ["karsilama"] = pay > 0 ? 0m : (object?)null,
            ["tur"] = k["tur"],
            ["stokId"] = k["stok_id"],
            ["hizmetId"] = k["hizmet_id"],
            ["masrafId"] = k["masraf_id"],
            ["aciklama"] = k["aciklama"],
            ["adet"] = miktar,
            ["miktar"] = miktar,
            ["birim"] = k["birim"],
            ["birimFiyat"] = birimFiyat,
            ["iskonto"] = iskonto,
            ["iskonto2"] = iskonto2,
            ["kdv"] = k["kdv"],
            ["otvYuzde"] = k["otv_yuzde"],
            ["otvMiktar"] = k["otv_miktar"],
            ["kdvMuafiyeti"] = k["kdv_muafiyeti"],
            ["dovizCinsi"] = k["doviz_cinsi"],
            ["dovizBirimFiyat"] = dovizBirimFiyat,
            ["dovizKuru"] = k["doviz_kuru"],
            ["girisDepoId"] = k["giris_depo_id"],
            ["cikisDepoId"] = k["cikis_depo_id"],
            ["izleme"] = k["izleme"],
            ["izlemeKodu"] = k["izleme_kodu"],
            ["stokDurumDegis"] = stokDurumDegis,
            ["kaynakTur"] = 30,
            ["kaynakId"] = kaynakSatirId,
            // Izlemli stokta cikisa donusumde lotlar FIFO ile burada tahsis
            //   edilir (kaynak siparis stok dusurmedigi icin lot tasimaz).
            ["izlemler"] = izlemler,
        };

        var json = JsonSerializer.SerializeToElement(govde);
        var sonuc = new Dictionary<string, JsonElement>(StringComparer.Ordinal);
        foreach (var alan in json.EnumerateObject()) sonuc[alan.Name] = alan.Value;
        return sonuc;
    }
}
