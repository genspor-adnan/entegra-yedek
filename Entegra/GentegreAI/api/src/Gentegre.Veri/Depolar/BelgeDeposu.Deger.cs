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
                   b.vade_gun as "vadeGun",
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
                   -- Teklif durumu (218): yalniz tur 18'de anlamli.
                   b.teklif_durum as "teklifDurum",
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
              left join public.depo  cd on cd.id = b.cikis_depo_id
              left join public.depo  gd on gd.id = b.giris_depo_id
              left join public.taraf sc on sc.id = b.satici_id
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
                   s.teslim_tarihi as "teslimTarihi", s.rezerve
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

    /// <summary>Kaynak satiri hedef satir JSON'una cevirir (fiyat/iskonto/KDV aynen tasinir).</summary>
    private static Dictionary<string, JsonElement> SatirJson(
        IDictionary<string, object?> k, decimal miktar, int kaynakSatirId, int stokDurumDegis,
        IReadOnlyList<object>? izlemler = null)
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
