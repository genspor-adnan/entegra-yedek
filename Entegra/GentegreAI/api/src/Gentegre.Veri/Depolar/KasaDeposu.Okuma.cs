using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// KASA ISLEMI OKUMA: baslik + bacaklar, muhasebe fisi ozeti, islem turu
/// katalogu ve gunluk kur. Yazma/kesinlestirme tarafi KasaDeposu.cs'te.
/// </summary>
public sealed partial class KasaDeposu
{

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
            baslik = o.Sozluk();
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
            while (await o.ReadAsync(iptal)) bacaklar.Add(o.Sozluk());
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
        await using var komut = baglanti.Komut(
            "select public.fn_doviz_kur_getir(@p0, @p1::date, @p2::smallint)", null,
            dovizCinsi ?? "TL", tarih.Date, (short)yon);
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
        await using var komut = baglanti.Komut("""
            select tarih from public.doviz_kur
             where doviz_cinsi = public.fn_doviz_iso(@p0) and tarih <= @p1::date
             order by tarih desc limit 1
            """, null,
            dovizCinsi ?? "TL", tarih.Date);
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
}
