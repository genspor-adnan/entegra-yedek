using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Bir bolumun (departman) ya da bir hekimin randevu duzeni (251). Bos alan
/// UST SEVIYEDEN miras alinir: hekim -> bolum -> Genel Ayarlar. Her seviyede
/// tum alanlari doldurmaya zorlamak, tek bir ogle arasi farki icin butun
/// duzeni kopyalatirdi.
/// </summary>
public sealed record RandevuAyarSatiri(
    int? Id,
    int DepartmanId,
    int? HekimId,
    string Ad,                    // bolum ya da hekim adi (ekranda gosterilir)
    string BaslangicSaat,
    string BitisSaat,
    string OgleBaslangic,
    string OgleBitis,
    int? SlotDk,
    int? VarsayilanSure,
    string CalismaGunleri,
    short Aktif,
    string Aciklama);

/// <summary>Sol agacin bir dugumu: bolum + altindaki hekimler.</summary>
public sealed record RandevuBolumDugumu(
    int DepartmanId,
    string Ad,
    RandevuAyarSatiri Ayar,
    IReadOnlyList<RandevuAyarSatiri> Hekimler);

/// <summary>
/// Randevu Ayarlari > Bolumler sekmesinin veri kaynagi (251, kullanici: "solda
/// randevu verilen bolumler ve bu departmandaki hekimler, saginda o bolume/
/// hekime ait randevu ayarlari - master detail").
/// </summary>
public sealed class RandevuAyarDeposu
{
    private readonly VeriKaynagi _veri;

    public RandevuAyarDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>Randevu verilebilen bolumler + hekimleri + kayitli ayarlari.</summary>
    public async Task<IReadOnlyList<RandevuBolumDugumu>> AgacAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        // Bolumler ve hekimler TEK sorguda: bolum satirinda hekim_id null.
        //   Hekim = personel (taraf.personel = 1) ve departmani o bolum.
        await using var komut = new NpgsqlCommand("""
            select d.id, d.ad, null::integer as hekim_id, d.ad as satir_ad, 0 as tip
              from public.departman d
             where d.durum = 1 and (public.fn_bolum_planli(d.id) = 1 or d.randevusuz_kabul = 1)
            union all
            select d.id, d.ad, t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, 1
              from public.departman d
              join public.taraf t on t.departman = d.id and t.personel = 1
             where d.durum = 1 and (public.fn_bolum_planli(d.id) = 1 or d.randevusuz_kabul = 1)
               -- Bolumdeki HER personel degil, CALISMA PLANI olan (711): bayrak kalkti.
               and public.fn_hekim_planli(t.id) = 1
               and coalesce(t.durum, 1) = 1
             order by 2, 5, 4
            """, baglanti);

        var dugumler = new List<(int Id, string Ad, List<(int HekimId, string Ad)> Hekimler)>();
        await using (var o = await komut.ExecuteReaderAsync(iptal))
        {
            while (await o.ReadAsync(iptal))
            {
                var bolumId = o.GetInt32(0);
                var bolumAd = o.GetString(1);
                var dugum = dugumler.FirstOrDefault(x => x.Id == bolumId);
                if (dugum.Hekimler is null)
                {
                    dugum = (bolumId, bolumAd, new List<(int, string)>());
                    dugumler.Add(dugum);
                }
                if (!o.IsDBNull(2)) dugum.Hekimler.Add((o.GetInt32(2), o.GetString(3)));
            }
        }

        var ayarlar = new List<(int DepartmanId, int? HekimId, RandevuAyarSatiri Satir)>();
        await using (var ak = new NpgsqlCommand("""
            select id, departman_id, hekim_id, baslangic_saat, bitis_saat,
                   ogle_baslangic, ogle_bitis, slot_dk, varsayilan_sure,
                   calisma_gunleri, aktif, aciklama
              from public.randevu_bolum_ayar
            """, baglanti))
        await using (var o = await ak.ExecuteReaderAsync(iptal))
        {
            while (await o.ReadAsync(iptal))
                ayarlar.Add((o.GetInt32(1), o.IsDBNull(2) ? null : o.GetInt32(2),
                    new RandevuAyarSatiri(o.GetInt32(0), o.GetInt32(1),
                        o.IsDBNull(2) ? null : o.GetInt32(2), "",
                        o.GetString(3), o.GetString(4), o.GetString(5), o.GetString(6),
                        o.IsDBNull(7) ? null : o.GetInt16(7),
                        o.IsDBNull(8) ? null : o.GetInt16(8),
                        o.GetString(9), o.GetInt16(10), o.GetString(11))));
        }

        RandevuAyarSatiri Coz(int departmanId, int? hekimId, string ad)
        {
            var v = ayarlar.FirstOrDefault(a => a.DepartmanId == departmanId && a.HekimId == hekimId);
            return v.Satir is null
                ? new RandevuAyarSatiri(null, departmanId, hekimId, ad, "", "", "", "",
                                        null, null, "", 1, "")
                : v.Satir with { Ad = ad };
        }

        return dugumler.Select(d => new RandevuBolumDugumu(
            d.Id, d.Ad, Coz(d.Id, null, d.Ad),
            d.Hekimler.Select(h => Coz(d.Id, h.HekimId, h.Ad)).ToList())).ToList();
    }

    /// <summary>Bolum ya da hekim ayarini yazar (upsert - benzersiz indeksler uzerinden).</summary>
    public async Task YazAsync(RandevuAyarSatiri s, int kullaniciId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        // Hekim satirinda hekim_id dolu, bolum satirinda null; iki ayri kismi
        //   benzersiz indeks var, "on conflict" ikisini birden hedefleyemez -
        //   once update, satir yoksa insert.
        await using (var g = new NpgsqlCommand("""
            update public.randevu_bolum_ayar
               set baslangic_saat = @p2, bitis_saat = @p3, ogle_baslangic = @p4,
                   ogle_bitis = @p5, slot_dk = @p6, varsayilan_sure = @p7,
                   calisma_gunleri = @p8, aktif = @p9, aciklama = @p10,
                   degistiren = @p11, degistirme_tarihi = now()::timestamp
             where departman_id = @p0
               and hekim_id is not distinct from @p1
            """, baglanti))
        {
            Doldur(g, s, kullaniciId);
            if (await g.ExecuteNonQueryAsync(iptal) > 0) return;
        }

        await using var e = new NpgsqlCommand("""
            insert into public.randevu_bolum_ayar
                   (departman_id, hekim_id, baslangic_saat, bitis_saat, ogle_baslangic,
                    ogle_bitis, slot_dk, varsayilan_sure, calisma_gunleri, aktif,
                    aciklama, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
            """, baglanti);
        Doldur(e, s, kullaniciId);
        await e.ExecuteNonQueryAsync(iptal);
    }

    private static void Doldur(NpgsqlCommand k, RandevuAyarSatiri s, int kullaniciId)
    {
        k.Parameters.AddWithValue("p0", s.DepartmanId);
        k.Parameters.AddWithValue("p1", (object?)s.HekimId ?? DBNull.Value);
        k.Parameters.AddWithValue("p2", s.BaslangicSaat ?? "");
        k.Parameters.AddWithValue("p3", s.BitisSaat ?? "");
        k.Parameters.AddWithValue("p4", s.OgleBaslangic ?? "");
        k.Parameters.AddWithValue("p5", s.OgleBitis ?? "");
        k.Parameters.AddWithValue("p6", (object?)s.SlotDk ?? DBNull.Value);
        k.Parameters.AddWithValue("p7", (object?)s.VarsayilanSure ?? DBNull.Value);
        k.Parameters.AddWithValue("p8", s.CalismaGunleri ?? "");
        k.Parameters.AddWithValue("p9", s.Aktif);
        k.Parameters.AddWithValue("p10", s.Aciklama ?? "");
        k.Parameters.AddWithValue("p11", kullaniciId);
    }

    /// <summary>
    /// Departmani randevu bolumu yapar / bolumlukten cikarir (711: bayrak yerine
    /// CALISMA PLANI). Ekle: bolumdeki hekimlere (taraf.hekim=1 ya da personel)
    /// sablonu yoksa genel ayarlardan "Standart hafta" sablonu acilir; hekimsiz
    /// bolum randevusuz kabul olur. Cikar: bolumun sablonlari pasiflenir,
    /// randevusuz kabul kalkar.
    /// </summary>
    /// <summary>
    /// BOLUMUN DOKTORLARI (Calisma Sablonlari > Bolum penceresi): bolumdeki
    /// aktif hekim/personel ve o bolumde AKTIF sablonu olup olmadigi - pencere
    /// "sablonu yok, acilacak" / "zaten aktif sablonu var" diye listeler.
    /// </summary>
    public Task<List<(int Id, string Ad, bool SablonVar)>> BolumDoktorlariAsync(int departmanId,
        CancellationToken iptal = default)
        => _veri.ListeAsync("""
            select t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),
                   exists (select 1 from public.hekim_calisma_sablon s
                            where s.hekim_id = t.id and s.departman_id = @p0 and s.aktif = 1)
              from public.taraf t
             where t.departman = @p0 and coalesce(t.durum, 1) = 1 and (t.hekim = 1 or t.personel = 1)
             order by 2
            """, new object?[] { departmanId },
            o => (o.GetInt32(0), o.GetString(1), o.GetBoolean(2)), iptal);

    public async Task<int> BolumIsaretleAsync(int departmanId, bool bolumMu, int kullaniciId = 0,
        IReadOnlyCollection<int>? hekimIdleri = null, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        if (!bolumMu)
        {
            await using var k0 = new NpgsqlCommand(
                "update public.hekim_calisma_sablon set aktif = 0, degistiren = @p1, degistirme_tarihi = now() where departman_id = @p0 and aktif = 1;" +
                "update public.departman set randevusuz_kabul = 0 where id = @p0", baglanti);
            k0.Parameters.AddWithValue("p0", departmanId); k0.Parameters.AddWithValue("p1", kullaniciId);
            return await k0.ExecuteNonQueryAsync(iptal);
        }
        // VARSAYILAN DUZEN (Calisma Sablonlari > Varsayilanlar): ogle arasi
        //   tanimliysa iki blok (bas-ogle_bas, ogle_bit-bitis), yoksa tek blok.
        // DOKTOR SECIMI: hekimIdleri verilirse yalniz onlara (pencerede
        //   isaretlenenler); verilmezse bolumde sablonu olmayan herkese.
        await using var k = new NpgsqlCommand("""
            with v as (
                select coalesce(nullif((select deger from public.referans where anahtar = 'randevu.calisma_gunleri'), ''), '1,2,3,4,5') as gunler,
                       coalesce(nullif((select deger from public.referans where anahtar = 'randevu.baslangic_saat'), ''), '09:00') as bas,
                       coalesce(nullif((select deger from public.referans where anahtar = 'randevu.bitis_saat'), ''), '18:00') as bit,
                       nullif((select deger from public.referans where anahtar = 'randevu.ogle_baslangic'), '') as ogle_bas,
                       nullif((select deger from public.referans where anahtar = 'randevu.ogle_bitis'), '') as ogle_bit,
                       coalesce(nullif((select deger from public.referans where anahtar = 'randevu.slot_dk'), '')::int, 15) as slot)
            insert into public.hekim_calisma_sablon (hekim_id, departman_id, ad, gunler, bas1, bit1, bas2, bit2, slot_dk, aciklama, ekleyen)
            select t.id, @p0, 'Standart hafta', v.gunler,
                   v.bas,
                   case when v.ogle_bas is not null and v.ogle_bit is not null then v.ogle_bas else v.bit end,
                   case when v.ogle_bas is not null and v.ogle_bit is not null then v.ogle_bit else '' end,
                   case when v.ogle_bas is not null and v.ogle_bit is not null then v.bit else '' end,
                   v.slot, 'Çalışma Şablonları › Bölümü randevuya aç', @p1
              from public.taraf t cross join v
             where t.departman = @p0 and coalesce(t.durum, 1) = 1 and (t.hekim = 1 or t.personel = 1)
               and (cardinality(@p2::int[]) = 0 or t.id = any(@p2::int[]))
               and not exists (select 1 from public.hekim_calisma_sablon s where s.hekim_id = t.id and s.departman_id = @p0 and s.aktif = 1)
            """, baglanti);
        k.Parameters.AddWithValue("p0", departmanId); k.Parameters.AddWithValue("p1", kullaniciId);
        k.Parameters.AddWithValue("p2", (hekimIdleri ?? Array.Empty<int>()).ToArray());
        var eklenen = await k.ExecuteNonQueryAsync(iptal);
        // HEKIMSIZ bolum (acil, lab, radyoloji): randevusuz kabul. Doktoru olan
        //   ama pencerede kimse secilmeyen bolum bu dala DUSMEZ.
        var doktorVar = (await BolumDoktorlariAsync(departmanId, iptal)).Count > 0;
        if (eklenen == 0 && !doktorVar)
        {
            // Hekimsiz bolum (acil, lab, radyoloji): randevusuz kabul.
            await using var k2 = new NpgsqlCommand("update public.departman set randevusuz_kabul = 1 where id = @p0", baglanti);
            k2.Parameters.AddWithValue("p0", departmanId);
            await k2.ExecuteNonQueryAsync(iptal);
        }
        return eklenen;
    }
}
