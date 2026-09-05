using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// İLAÇ KARTI ve FİYATI (406/407/408) — ilaç kataloğu ile stok/fiyat dünyası
/// arasındaki tek geçit.
///
/// İki kural bütün akışları belirliyor:
///
/// <para><b>1. İlaç bir stok değildir.</b> TİTCK kataloğu 23 bin satırlık bir
/// REFERANS listesidir; hepsine peşinen stok kartı açmak stok listesini
/// kullanılamaz hale getirirdi. Kart <b>ilk kullanımda</b> açılır ve
/// <c>ilac.stok_id</c> ile bağlanır.</para>
///
/// <para><b>2. İlan edilen ilaç fiyatı KDV DAHİLDİR, stok kartındaki fiyat
/// MATRAHTIR.</b> Çevrim yapılmazsa kalem penceresi kart fiyatını bir kez daha
/// brütleştirir (148,50 -> 163,35) ve hata sessizdir: rakam makul görünür,
/// yalnız KDV kadar fazladır. Çevrim <c>fn_ilac_stok_fiyati</c> içindedir (408),
/// burada tekrarlanmaz.</para>
///
/// Uçlar bu sınıfa ince bir kabuktur: aynı SQL dört ayrı uçta kopyalanınca
/// 408 düzeltmesini dördüne birden uygulamak gerekmişti.
/// </summary>
public sealed class IlacKartFiyat
{
    private readonly VeriKaynagi _veri;
    public IlacKartFiyat(VeriKaynagi veri) => _veri = veri;

    public sealed record KartSonucu(int StokId, string Barkod, string Ad, decimal Fiyat);
    public sealed record FiyatSatiri(string Barkod, decimal Perakende, decimal Kdv);
    public sealed record FiyatSonucu(int Okunan, int Yazilan, int StokGuncellenen, int Eslesmeyen);

    /// <summary>
    /// İlacın stok kartını verir; yoksa açar.
    ///
    /// TEKRARLANABİLİR: ikinci çağrı aynı kartı döndürür. Aynı barkodla elle
    /// açılmış bir kart varsa o benimsenir — yenisini açmak depoyu ikiye
    /// bölerdi. İlaç bulunamazsa <c>null</c>.
    /// </summary>
    public async Task<KartSonucu?> StokKartiAsync(int ilacId, int kullaniciId, int? subeId,
                                                  CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var ilac = await baglanti.TekAsync("""
            select i.barkod, i.ad, i.stok_id from public.ilac i where i.id = @p0 for update
            """, islem, [ilacId], o => new
            {
                Barkod = o.GetString(0), Ad = o.GetString(1),
                StokId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
            }, iptal);
        if (ilac is null) return null;

        var stokId = ilac.StokId ?? await KartAcAsync(baglanti, islem, ilacId, ilac.Barkod,
                                                      ilac.Ad, kullaniciId, subeId, iptal);

        // KART VARDI AMA FİYATSIZDI: ilaca fiyat sonradan girilmiş olabilir
        //   (önce kart açılıp sonra fiyat yüklenen sıra). Listede ilaç fiyatlı
        //   görünüp kalem penceresine boş gelmesinin sebebi buydu.
        await StokFiyatiYazAsync(baglanti, islem, [ilac.Barkod], kullaniciId,
                                 zorla: false, iptal);

        var fiyat = await baglanti.TekDegerAsync<decimal>(
            "select coalesce((select fiyat from public.fn_stok_kart_fiyat(@p0, 1::smallint)), 0)",
            islem, [stokId], iptal);

        await islem.CommitAsync(iptal);
        return new KartSonucu(stokId, ilac.Barkod, ilac.Ad, fiyat);
    }

    /// <summary>
    /// Fiyat satırlarını tarihçeye yazar (kaynak 9 — elle) ve bağlı stok
    /// kartlarının satış fiyatını tazeler.
    ///
    /// Tek fiyat girişi de toplu yükleme de BURADAN geçer: ikisi ayrı yazılınca
    /// biri düzeltilip öteki eskide kalıyordu. Resmi TİTCK listesi kaynak 1 ile
    /// ayrı durur; buradaki satırlar onun üzerine yazmaz.
    /// </summary>
    public async Task<FiyatSonucu> FiyatYazAsync(IReadOnlyList<FiyatSatiri> satirlar,
        DateOnly yururluk, string kaynakSurum, int kullaniciId, CancellationToken iptal)
    {
        if (satirlar.Count == 0) return new FiyatSonucu(0, 0, 0, 0);

        var barkodlar = satirlar.Select(x => x.Barkod).ToArray();
        var fiyatlar = satirlar.Select(x => x.Perakende).ToArray();
        var kdvler = satirlar.Select(x => x.Kdv).ToArray();
        var gun = yururluk.ToDateTime(TimeOnly.MinValue);

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var yazilan = await baglanti.CalistirAsync("""
            insert into public.ilac_fiyat (barkod, kaynak, yururluk_bas, perakende_fiyat,
                                           kdv_oran, kaynak_surum, ekleyen)
            select t.barkod, 9, @p3::date, t.fiyat, t.kdv, @p5, @p4
              from unnest(@p0::varchar[], @p1::numeric[], @p2::numeric[])
                   as t(barkod, fiyat, kdv)
            on conflict (barkod, kaynak, yururluk_bas) do update
               set perakende_fiyat = excluded.perakende_fiyat,
                   kdv_oran = excluded.kdv_oran
            """, islem, [barkodlar, fiyatlar, kdvler, gun, kullaniciId, kaynakSurum], iptal);

        // Gölge kolonlar ÖNCE tazelenir: stok fiyatı onlardan türetiliyor.
        await baglanti.TekDegerAsync<int>(
            "select public.fn_ilac_fiyat_golge_tazele()", islem, [], iptal);

        var stokGuncellenen = await StokFiyatiYazAsync(baglanti, islem, barkodlar,
                                                       kullaniciId, zorla: true, iptal);

        var eslesmeyen = await baglanti.TekDegerAsync<int>("""
            select count(*) from unnest(@p0::varchar[]) b(barkod)
             where not exists (select 1 from public.ilac i where i.barkod = b.barkod)
            """, islem, [barkodlar], iptal);

        await islem.CommitAsync(iptal);
        return new FiyatSonucu(satirlar.Count, yazilan, stokGuncellenen, eslesmeyen);
    }

    // --------------------------------------------------------------- içeriden
    private static async Task<int> KartAcAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int ilacId, string barkod, string ad, int kullaniciId, int? subeId,
        CancellationToken iptal)
    {
        // Aynı barkodla elle açılmış kart varsa o benimsenir.
        var stokId = await baglanti.TekDegerAsync<int?>("""
            select s.id from public.stok s
             where s.kod = @p0
                or exists (select 1 from public.stok_barkod b
                            where b.stok_id = s.id and b.barkod = @p0)
             limit 1
            """, islem, [barkod], iptal);

        // Kart kodu BARKODDUR (ilacın kimliği o), izleme KAREKOD (İTS), KDV %10.
        stokId ??= await baglanti.TekDegerAsync<int>("""
            insert into public.stok (kod, ad, tipi, ana_birim, kdv, izleme, durum,
                                     sube_id, satilan, alinan, giris_kaynak, ekleyen)
            values (@p0, @p1, 51, 51, 10, 4, 1, @p2, 1, 1, 2, @p3)
            returning id
            """, islem, [barkod, ad, subeId ?? 1, kullaniciId], iptal);

        await baglanti.CalistirAsync("""
            insert into public.stok_barkod (stok_id, barkod, varsayilan)
            select @p0, @p1, 1
             where not exists (select 1 from public.stok_barkod b where b.barkod = @p1)
            """, islem, [stokId, barkod], iptal);

        await baglanti.CalistirAsync(
            "update public.ilac set stok_id = @p1, guncelleme = now() where id = @p0",
            islem, [ilacId, stokId], iptal);

        return stokId.Value;
    }

    /// <summary>
    /// İlan edilen fiyatı stok kartının SATIŞ fiyatına yazar (MATRAH olarak).
    ///
    /// <paramref name="zorla"/> false iken yalnız fiyatı OLMAYAN kart doldurulur:
    /// kart açılışında kullanıcının elle girdiği fiyatı ezmek yanlış olurdu.
    /// Fiyat girişinde ise kullanıcı bilerek yeni fiyat veriyor — üzerine yazılır.
    /// </summary>
    private static Task<int> StokFiyatiYazAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string[] barkodlar, int kullaniciId, bool zorla,
        CancellationToken iptal)
    {
        var eksikSarti = zorla ? "" :
            """
               and not exists (select 1 from public.stok_fiyat sf
                                where sf.stok_id = i.stok_id and sf.satis = 1 and sf.fiyat > 0)
            """;
        return baglanti.CalistirAsync($"""
            insert into public.stok_fiyat (stok_id, fiyat_adi, birim, fiyat,
                                           doviz_cinsi, satis, ekleyen)
            select i.stok_id, 0, 51, public.fn_ilac_stok_fiyati(i.barkod), 'TL', 1, @p1
              from unnest(@p0::varchar[]) as t(barkod)
              join public.ilac i on i.barkod = t.barkod and i.stok_id is not null
             where public.fn_ilac_stok_fiyati(i.barkod) > 0
            {eksikSarti}
            on conflict (stok_id, fiyat_adi, birim, satis, doviz_cinsi)
            do update set fiyat = excluded.fiyat, degistiren = excluded.ekleyen
            """, islem, [barkodlar, kullaniciId], iptal);
    }
}
