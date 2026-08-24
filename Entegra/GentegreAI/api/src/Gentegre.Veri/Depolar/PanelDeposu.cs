using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Ust seritteki kutu: bir sayi, bir tutar ve altinda kisa aciklama.</summary>
public sealed record PanelKutusu(string Anahtar, string Baslik, decimal Deger,
    string Birim, string Alt, string Yol, string Vurgu);

/// <summary>Panel listelerindeki satir (son belgeler / kritik stok).</summary>
public sealed record PanelSatiri(long Id, string Ana, string Yan, string Deger, string Yol);

public sealed record PanelYaniti(
    IReadOnlyList<PanelKutusu> Kutular,
    IReadOnlyList<PanelSatiri> SonBelgeler,
    IReadOnlyList<PanelSatiri> KritikStok,
    IReadOnlyList<PanelSatiri> BuyukBakiyeler);

/// <summary>
/// Ana sayfa paneli (giris_sayfasi.html mockup'i).
///
/// KURAL: yalnizca GERCEK veri gosterilir. Mockup'ta gorev/takvim/duyuru
/// kutulari da var ama o moduller SEMADA YOK - uydurma sayi koymak, panele
/// bakip karar veren kullaniciyi yaniltir. Onlar modul gelince eklenecek.
///
/// Tum sorgular SUBEYE gore suzulur (baglamdan gelen sube_id); sube secilmemisse
/// firma geneli okunur.
/// </summary>
public sealed class PanelDeposu
{
    private readonly VeriKaynagi _veri;

    public PanelDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<PanelYaniti> OkuAsync(int? subeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var kutular = new List<PanelKutusu>();
        var sube = (object?)subeId ?? DBNull.Value;

        // ---------------------------------------------------------- ay ozeti ---
        // Ay basindan bugune KESIN (durum=0) belgeler. Satis ve alis ayri:
        //   biri ciro, digeri maliyet - tek kutuda toplamak anlamsiz olurdu.
        await using (var komut = new NpgsqlCommand("""
            select
              coalesce(sum(genel_toplam) filter (where tur in (14,15,16,119)), 0) as satis,
              count(*)                   filter (where tur in (14,15,16,119))     as satis_adet,
              coalesce(sum(genel_toplam) filter (where tur in (10,11,12,109)), 0) as alis,
              count(*)                   filter (where tur in (10,11,12,109))     as alis_adet
              from public.belge
             where durum = 0
               and belge_tarihi >= date_trunc('month', now())
               and (@p0::int is null or sube_id = @p0)
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", sube);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (await o.ReadAsync(iptal))
            {
                kutular.Add(new("aySatis", "Bu Ay Satış", o.GetDecimal(0), "₺",
                    $"{o.GetInt64(1)} belge", "/belge", "olumlu"));
                kutular.Add(new("ayAlis", "Bu Ay Alış", o.GetDecimal(2), "₺",
                    $"{o.GetInt64(3)} belge", "/alis-fatura", ""));
            }
        }

        // ------------------------------------------------------ acik siparis ---
        await using (var komut = new NpgsqlCommand("""
            select count(*), coalesce(sum(genel_toplam), 0)
              from public.belge
             where tur in (9, 19) and durum = 0 and coalesce(kapanma_durum, 0) < 2
               and (@p0::int is null or sube_id = @p0)
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", sube);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (await o.ReadAsync(iptal))
                kutular.Add(new("acikSiparis", "Açık Sipariş", o.GetInt64(0), "adet",
                    $"{o.GetDecimal(1):N0} ₺ tutarında", "/siparis", "uyari"));
        }

        // --------------------------------------------------- e-Belge kuyrugu ---
        // Kesilmis ama GIB'e gonderilmemis satis fatura/irsaliyeleri.
        await using (var komut = new NpgsqlCommand("""
            select count(*) from public.belge
             where tur in (14, 15) and durum = 0 and coalesce(efatura_durum, 0) = 0
               and (@p0::int is null or sube_id = @p0)
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", sube);
            var n = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal) ?? 0L);
            kutular.Add(new("eBelge", "Gönderilmemiş e-Belge", n, "adet",
                "kuyrukta bekliyor", "/e-belge", n > 0 ? "uyari" : ""));
        }

        // -------------------------------------------------------- kritik stok --
        // "Kullanilabilir" = kalan - acik satis siparisi (stok kartindaki kural).
        //   Esigi olmayan stok kritik sayilmaz; yoksa binlerce kalem listelenirdi.
        const string KritikSorgu = """
            with rez as (
                select bs.stok_id, sum(bs.kalan_miktar) as m
                  from public.belge_satir bs
                  join public.belge b on b.id = bs.belge_id
                 where b.tur = 19 and b.durum = 0 and bs.kalan_miktar > 0
                 group by 1
            )
            select s.id, s.kod, s.ad,
                   sum(sd.kalan) - coalesce(max(r.m), 0) as kullanilabilir,
                   max(s.min_stok) as esik
              from public.stok_durum sd
              join public.stok s on s.id = sd.stok_id
              left join rez r on r.stok_id = sd.stok_id
             where s.durum = 1 and coalesce(s.min_stok, 0) > 0
             group by s.id, s.kod, s.ad
            having sum(sd.kalan) - coalesce(max(r.m), 0) <= max(s.min_stok)
            """;

        await using (var komut = new NpgsqlCommand(
            $"select count(*) from ({KritikSorgu}) x", baglanti))
        {
            var n = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal) ?? 0L);
            kutular.Add(new("kritikStok", "Kritik Stok", n, "kalem",
                "minimum seviyenin altında", "/stok", n > 0 ? "hata" : ""));
        }

        // ------------------------------------------------------ kasa + banka ---
        await using (var komut = new NpgsqlCommand("""
            select coalesce(sum(yerel_bakiye), 0), count(*)
              from public.v_hesap_bakiye
             where tur in ('K', 'B') and durum = 1
               and (@p0::int is null or sube_id = @p0)
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", sube);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (await o.ReadAsync(iptal))
                kutular.Add(new("nakit", "Kasa + Banka", o.GetDecimal(0), "₺",
                    $"{o.GetInt64(1)} hesap", "/kasa-hesap", "olumlu"));
        }

        // ------------------------------------------------------- son belgeler --
        var sonBelgeler = new List<PanelSatiri>();
        await using (var komut = new NpgsqlCommand("""
            select b.id, coalesce(kt.ad, '') as tur_adi, coalesce(b.belge_no, ''),
                   coalesce(b.taraf_unvan, ''), b.genel_toplam, b.belge_tarihi, b.tur
              from public.belge b
              left join public.kasa_islem_turu kt on kt.kod = b.tur
             where b.durum = 0 and (@p0::int is null or b.sube_id = @p0)
             order by b.belge_tarihi desc, b.id desc
             limit 8
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", sube);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
                sonBelgeler.Add(new(o.GetInt64(0),
                    $"{o.GetString(1)} {o.GetString(2)}".Trim(),
                    o.GetString(3),
                    o.GetDecimal(4).ToString("N2"),
                    BelgeYolu(o.GetInt32(6))));
        }

        // -------------------------------------------------------- kritik liste --
        var kritik = new List<PanelSatiri>();
        await using (var komut = new NpgsqlCommand(
            $"{KritikSorgu} order by 4 limit 8", baglanti))
        {
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
                kritik.Add(new(o.GetInt64(0), o.GetString(1), o.GetString(2),
                    $"{o.GetDecimal(3):N2} / {o.GetDecimal(4):N0}", "/stok"));
        }

        // ------------------------------------------------- en buyuk bakiyeler --
        // Cari ekstresinin son bakiyesi: kimden alacakliyiz (musteri) sorusunun
        //   panel cevabi. Borclu taraf (negatif) ayri satirda gorunur.
        var bakiyeler = new List<PanelSatiri>();
        await using (var komut = new NpgsqlCommand("""
            select t.id, coalesce(t.unvan, ''),
                   case when sum(e.yerel_borc - e.yerel_alacak) >= 0 then 'Alacak' else 'Borç' end,
                   abs(sum(e.yerel_borc - e.yerel_alacak)) as bakiye
              from public.v_cari_ekstre e
              join public.taraf t on t.id = e.taraf_id
             group by t.id, t.unvan
            having abs(sum(e.yerel_borc - e.yerel_alacak)) > 0
             order by 4 desc
             limit 8
            """, baglanti))
        {
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
                bakiyeler.Add(new(o.GetInt64(0), o.GetString(1), o.GetString(2),
                    o.GetDecimal(3).ToString("N2"), "/cari"));
        }

        return new PanelYaniti(kutular, sonBelgeler, kritik, bakiyeler);
    }

    /// <summary>Panel satirindan hangi liste ekranina gidilecegi (kart modal olarak acilir).</summary>
    private static string BelgeYolu(int tur) => tur switch
    {
        19 => "/siparis", 14 => "/satis-irsaliye", 15 => "/belge", 16 => "/satis-fisi",
        13 => "/tahakkuk", 119 => "/satis-konsinye",
        9 => "/alis-siparis", 10 => "/alis-irsaliye", 11 => "/alis-fatura",
        12 => "/alis-fisi", 17 => "/borc-tahakkuk", 109 => "/alis-konsinye",
        20 => "/stok-transfer", 105 => "/stok-talep", 3 => "/giris-fis", 4 => "/cikis-fis",
        _ => "/belge",
    };
}
