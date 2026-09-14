using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Ücret sekmesindeki durum rozeti / zil satırı.</summary>
public sealed record IskontoTalebi(
    int Id, int BelgeId, decimal Oran, decimal OnaylananOran, string Gerekce,
    short Durum, string Isteyen, DateTime IstekTs, string Onaylayan,
    DateTime? OnayTs, string KararNotu,
    /// <summary>Talebe bağlı satır sayısı ve toplam etkilenen tutar - zilde özet.</summary>
    int SatirSayisi, decimal Tutar,
    /// <summary>Zil satırında hasta / protokol görünsün diye.</summary>
    string Hasta, string BelgeNo,
    /// <summary>Onay penceresinin hasta şeridi (663): 1 erkek · 2 kadın · 0 bilinmiyor.</summary>
    short Cinsiyet, int Yas, string Kurum, string Doktor,
    /// <summary>Talebe giren hizmetler - "Muayene, EKG, USG" gibi yan yana yazılır.</summary>
    IReadOnlyList<IskontoKalemi> Kalemler);

/// <summary>Talep satırının ekranda okunan hali. <paramref name="Oran"/> KALEM
/// BAZLI istenen yüzdedir (673) - onay ekranı kalem kalem gösterir.</summary>
public sealed record IskontoKalemi(string Ad, decimal Tutar, decimal Oran);

/// <summary>İskonto yetki tavanı olan rol - onay ekranının "Yetki Limitleri" sekmesi.</summary>
public sealed record IskontoLimiti(int RolId, string RolAd, decimal Tavan, int KullaniciSayisi);

/// <summary>
/// İSKONTO ONAY TALEPLERİ (662 / 663).
///
/// Kararın kendisi <c>fn_iskonto_talep_karar</c>'da: oranı satırlara yazmak ve
/// satırları kilitlemek AYRILAMAZ iki iştir - biri olup öteki olmazsa ya
/// onaysız indirim ya kilitli yanlış rakam kalır. C# tarafı yalnız yetkiyi
/// kontrol edip fonksiyonu çağırır.
/// </summary>
public sealed class IskontoTalepDeposu
{
    private readonly VeriKaynagi _veri;

    public IskontoTalepDeposu(VeriKaynagi veri) => _veri = veri;

    private const string SecimSql = """
        select t.id, t.belge_id, t.oran, t.onaylanan_oran, t.gerekce, t.durum,
               coalesce(ist.unvan, '')  as isteyen,
               t.istek_ts,
               coalesce(ony.unvan, '')  as onaylayan,
               t.onay_ts, t.karar_notu,
               (select count(*) from public.iskonto_talep_satir ts
                 where ts.talep_id = t.id)                         as satir_sayisi,
               coalesce((select sum(s.tutar) from public.iskonto_talep_satir ts
                          join public.belge_satir s on s.id = ts.belge_satir_id
                         where ts.talep_id = t.id), 0)             as tutar,
               coalesce(h.unvan, '')    as hasta,
               coalesce(b.belge_no, '') as belge_no,
               -- HASTA SERIDI (663): cinsiyet ikonu, yas, kurum, doktor.
               --   Yas dogum tarihinden ANLIK hesaplanir - talep aninda
               --   dondurmak, yil donunce yanlis gosterirdi.
               coalesce(th.cinsiyet, 0) as cinsiyet,
               case when th.dogum_tarihi is null then 0
                    else extract(year from age(th.dogum_tarihi))::int end as yas,
               coalesce(kr.unvan, '')   as kurum,
               coalesce(dr.unvan, '')   as doktor
          from public.iskonto_talep t
          join public.belge b        on b.id = t.belge_id
          left join public.taraf h   on h.id = b.taraf_id
          left join public.taraf ist on ist.id = t.isteyen_id
          left join public.taraf ony on ony.id = t.onay_id
          left join public.taraf_hasta th on th.id = b.taraf_id
          left join public.belge_basvuru bb on bb.id = b.id
          left join public.taraf kr on kr.id = bb.odeyen_kurum_id
          left join public.taraf dr on dr.id = bb.personel_id
        """;

    private static IskontoTalebi Oku(NpgsqlDataReader o) => new(
        o.GetInt32(0), o.GetInt32(1), o.GetDecimal(2), o.GetDecimal(3),
        o.GetString(4), o.GetInt16(5), o.GetString(6), o.GetDateTime(7),
        o.GetString(8), o.IsDBNull(9) ? null : o.GetDateTime(9), o.GetString(10),
        (int)o.GetInt64(11), o.GetDecimal(12), o.GetString(13), o.GetString(14),
        o.GetInt16(15), o.GetInt32(16), o.GetString(17), o.GetString(18),
        Array.Empty<IskontoKalemi>());

    /// <summary>
    /// TALEPLERİN KALEMLERİ TEK SORGUDA (663): onay penceresi hizmet adlarını
    /// yan yana yazar. Talep başına ayrı sorgu atmak, zil her açıldığında
    /// bekleyen sayısı kadar gidiş dönüş demekti.
    /// </summary>
    private static async Task KalemleriDoldurAsync(NpgsqlConnection baglanti,
        List<IskontoTalebi> liste, CancellationToken iptal)
    {
        if (liste.Count == 0) return;
        var idler = liste.Select(x => x.Id).ToArray();
        var kova = new Dictionary<int, List<IskontoKalemi>>();

        await using (var komut = baglanti.Komut("""
            select ts.talep_id,
                   coalesce(nullif(s.aciklama, ''),
                            nullif(hz.ad, ''), nullif(st.ad, ''), '(kalem)') as ad,
                   coalesce(s.tutar, 0) as tutar,
                   -- Eski taleplerde satir orani 0 olabilir: baslik orani.
                   case when coalesce(ts.oran, 0) > 0 then ts.oran else t.oran end as oran
              from public.iskonto_talep_satir ts
              join public.iskonto_talep t on t.id = ts.talep_id
              join public.belge_satir s on s.id = ts.belge_satir_id
              left join public.hizmet hz on hz.id = s.hizmet_id
              left join public.stok st   on st.id = s.stok_id
             where ts.talep_id = any(@p0)
             order by ts.talep_id, s.sira
            """, null, idler))
        {
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal))
            {
                var talepId = okuyucu.GetInt32(0);
                if (!kova.TryGetValue(talepId, out var dizi))
                    kova[talepId] = dizi = new List<IskontoKalemi>();
                dizi.Add(new IskontoKalemi(okuyucu.GetString(1), okuyucu.GetDecimal(2),
                                           okuyucu.GetDecimal(3)));
            }
        }

        for (var i = 0; i < liste.Count; i++)
            if (kova.TryGetValue(liste[i].Id, out var dizi))
                liste[i] = liste[i] with { Kalemler = dizi };
    }

    public async Task<IReadOnlyList<IskontoTalebi>> BelgeTalepleriAsync(
        int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var sonuc = new List<IskontoTalebi>();
        await using (var komut = baglanti.Komut(
            SecimSql + " where t.belge_id = @p0 order by t.id desc", null, belgeId))
        {
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal)) sonuc.Add(Oku(okuyucu));
        }
        await KalemleriDoldurAsync(baglanti, sonuc, iptal);
        return sonuc;
    }

    /// <summary>
    /// ZİLE DÜŞENLER: bekleyen talepler, YALNIZ tavanı yeten kullanıcıya.
    /// Tavanı %10 olan birine %20'lik talep gösterilmez - onaylayamayacağı bir
    /// işi listede tutmak, talebi bekletirken kimsenin üstlenmediği bir kuyruk
    /// yaratırdı.
    ///
    /// "İlk onaylayandan sonra ötekilerde görünmesin" (663) için ek bir şey
    /// gerekmez: süzgeç <c>durum = 0</c>'dır, karar verilen talep herkesin
    /// listesinden aynı anda düşer.
    /// </summary>
    public async Task<IReadOnlyList<IskontoTalebi>> BekleyenlerAsync(
        int subeId, decimal tavan, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var sonuc = new List<IskontoTalebi>();
        await using (var komut = baglanti.Komut(
            SecimSql + """
             where t.durum = 0
               and t.oran <= @p1
               -- Şube süzmesi SUNUCUDA (API §7): başka şubenin talebi hiç dönmez.
               and (@p0 = 0 or t.sube_id is null or t.sube_id = @p0)
             order by t.istek_ts
            """, null, subeId, tavan))
        {
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal)) sonuc.Add(Oku(okuyucu));
        }
        await KalemleriDoldurAsync(baglanti, sonuc, iptal);
        return sonuc;
    }

    /// <summary>
    /// SONUCLANANLAR (666) - onay ekraninin denetim izi. Bekleyenlerden farki
    /// TAVAN SUZMESI YOKTUR: gecmis bir karar kaydidir, kimin neyi onayladigi
    /// tavani dusuk olandan da saklanmaz. Sube suzmesi yine sunucuda.
    /// </summary>
    public async Task<IReadOnlyList<IskontoTalebi>> GecmisAsync(
        int subeId, int gun, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var sonuc = new List<IskontoTalebi>();
        await using (var komut = baglanti.Komut(
            SecimSql + """
             where t.durum <> 0
               and t.istek_ts >= (current_date - (@p1::int - 1))
               and (@p0 = 0 or t.sube_id is null or t.sube_id = @p0)
             order by coalesce(t.onay_ts, t.istek_ts) desc
             limit 200
            """, null, subeId, gun <= 0 ? 1 : gun))
        {
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal)) sonuc.Add(Oku(okuyucu));
        }
        await KalemleriDoldurAsync(baglanti, sonuc, iptal);
        return sonuc;
    }

    /// <summary>
    /// YETKI LIMITLERI (666): hangi rol en cok kac yuzde verebilir. Onay
    /// ekraninda okunur - "bu talep neden bana dustu" sorusunun cevabi
    /// tavanlarin karsilastirmasidir. `rol_yetki.deger` sayisal sinirdir (661).
    /// </summary>
    public async Task<IReadOnlyList<IskontoLimiti>> LimitlerAsync(
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var sonuc = new List<IskontoLimiti>();
        await using var komut = baglanti.Komut("""
            select r.id, r.ad,
                   coalesce(nullif(ry.deger, '')::numeric, 0) as tavan,
                   -- Ana rolu bu olanlar + EK rol olarak tasiyanlar (665).
                   (select count(*) from public.taraf_kullanici k
                     where k.rol_id = r.id and k.aktif = 1)
                   + (select count(*) from public.kullanici_rol kr
                       join public.taraf_kullanici k2 on k2.id = kr.kullanici_id
                      where kr.rol_id = r.id and k2.aktif = 1) as kisi
              from public.rol r
              join public.rol_yetki ry on ry.rol_id = r.id
              join public.yetki y      on y.id = ry.yetki_id
             where y.kod = 'basvuru.iskonto'
               and coalesce(nullif(ry.deger, '')::numeric, 0) > 0
             order by 3 desc, r.ad
            """, null);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
            sonuc.Add(new IskontoLimiti(okuyucu.GetInt32(0), okuyucu.GetString(1),
                okuyucu.GetDecimal(2), (int)okuyucu.GetInt64(3)));
        return sonuc;
    }

    /// <summary>
    /// Talep acar. <paramref name="kalemler"/> KALEM BAZLI oranlari tasir (673);
    /// baslik orani bunlarin EN YUKSEGIDIR - yetki tavani onunla olculur,
    /// cunku siniri zorlayan kalem odur.
    /// </summary>
    public async Task<int> TalepAcAsync(int belgeId, decimal oran, string gerekce,
        IReadOnlyList<(int SatirId, decimal Oran)> kalemler, YazmaBaglami baglam,
        int subeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using var basKomut = baglanti.Komut("""
            insert into public.iskonto_talep
                   (belge_id, sube_id, oran, gerekce, durum, isteyen_id, ekleyen)
            values (@p0, nullif(@p1, 0), @p2, @p3, 0, @p4, @p4)
            returning id
            """, islem, belgeId, subeId, oran, gerekce, baglam.KullaniciId);
        var id = (int)(await basKomut.ExecuteScalarAsync(iptal))!;

        // SATIRIN O ANKİ FİYATI saklanır: onay ertesi gün gelse de yetkilinin
        //   gördüğü rakam kararını verdiği rakamdır. Oran da SATIRDA (673).
        var idler = kalemler.Select(k => k.SatirId).ToArray();
        var oranlar = kalemler.Select(k => k.Oran).ToArray();
        await using var satirKomut = baglanti.Komut("""
            insert into public.iskonto_talep_satir
                   (talep_id, belge_satir_id, birim_fiyat, onceki_iskonto, oran)
            select @p0, s.id, s.birim_fiyat, s.iskonto, g.oran
              from unnest(@p2::int[], @p3::numeric[]) as g(satir_id, oran)
              join public.belge_satir s on s.id = g.satir_id
             where s.belge_id = @p1
            on conflict (talep_id, belge_satir_id) do nothing
            """, islem, id, belgeId, idler, oranlar);
        await satirKomut.ExecuteNonQueryAsync(iptal);

        await islem.CommitAsync(iptal);
        return id;
    }

    public async Task KararAsync(int talepId, short onay, decimal oran, string not,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select public.fn_iskonto_talep_karar(@p0, @p1, @p2, @p3, @p4)", null,
            talepId, onay, oran, not, baglam.KullaniciId);
        await komut.ExecuteNonQueryAsync(iptal);
    }
}
