using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// PARA İNCELEMESİ 18.11.2026 bulgu 4-10 düzeltmeleri:
///  4 rapor = belge dövizi (ikisi yabancı) cari hareketi döviz tutarıyla yazılır · 5 üçüncü döviz ekstresi reddedilir
///  6 düzeltilen tahsilat plana iki kez eklenmez · 7 gerçekleşmiş işlem taslağa çekilemez · 8 aynı satır payına
///  eşzamanlı dağıtım fazlası reddedilir · 9 dönüşümde aynı satır iki kez seçilemez · 10 iptalde SGK katılım emaneti
///  de iptal olur.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class ParaKasaIncelemesiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private static readonly string Tarih = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:00");

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("para", yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private async Task<int> TarafAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, musteri, tedarikci, durum, sube_id) values (@p0, 1, 1, 1, @p1) returning id",
            [d.Onek + " para cari", Merkez]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Rapor_ve_belge_dovizi_yabanciysa_cari_doviz_tutariyla_borclanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await IstemciAsync(d, "belge:gedk", "belge.alis.fis:gedk");
        var depo = await api.Veri.TekDegerAsync<int>(
            "insert into public.depo (ad, durum, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " Depo", Merkez]);
        d.Temizle($"delete from public.stok_durum where depo_id = {depo}");
        d.Temizle($"delete from public.depo where id = {depo}");
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-STK", d.Onek + " stok", Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        var taraf = await TarafAsync(d);

        var y = await h.PostAsJsonAsync("/api/belge/", new
        {
            belge = new { tur = 12, tipi = 1, belgeTarihi = Tarih, tarafId = taraf, girisDepoId = depo, belgeNo = "D" + d.Onek[^6..],
                          belgeDovizi = "USD", raporDovizi = "USD", ekstreDovizi = "USD", dovizKuru = 48 },
            satirlar = new[] { new { tur = 1, stokId = stok, adet = 1, miktar = 1, birimFiyat = 48000, kdv = 0 } },
        });
        var g = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {g}");
        var id = JsonDocument.Parse(g).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {id}");
        d.Temizle($"delete from public.mali_hareket where belge_id = {id}");
        d.Temizle($"delete from public.stok_izleme where belge_id = {id}");
        d.Temizle($"delete from public.belge_satir where belge_id = {id}");
        d.Temizle($"delete from public.belge where id = {id}");

        var r = await api.Veri.TekAsync("""
            select b.genel_toplam, b.doviz_tutari, m.borc + m.alacak, m.yerel_borc + m.yerel_alacak, m.doviz_cinsi
              from public.belge b join public.mali_hareket m on m.belge_id = b.id and m.hesap_turu = 'C'
             where b.id = @p0
            """, [id], o => new object[] { o.GetDecimal(0), o.GetDecimal(1), o.GetDecimal(2), o.GetDecimal(3), o.GetString(4) });
        Assert.NotNull(r);
        var genel = (decimal)r![0];
        Assert.Equal(Math.Round(genel / 48m, 2), (decimal)r[1]);   // eskiden 0
        Assert.Equal("USD", r[4]);
        Assert.Equal((decimal)r[1], (decimal)r[2]);                 // eskiden TL genel toplam USD etiketiyle
        Assert.Equal(genel, (decimal)r[3]);
    }

    [VtFact]
    public async Task Ucuncu_doviz_ekstresi_reddedilir_ve_duzeltme_plani_iki_kez_saymaz()
    {
        await using var b = await api.Veri.AcAsync();
        await using var tx = await b.BeginTransactionAsync();   // hepsi geri alınır
        var taraf = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, musteri, durum, sube_id) values ('PARA-PLAN', 1, 1, 1) returning id", tx, []);
        var hesap = await b.TekDegerAsync<int>(
            "select id from public.hesap where coalesce(doviz_cinsi, 'TL') = 'TL' order by id limit 1", tx, []);
        var plan = await b.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar, sube_id, ekleyen, durum)
            values (61, now(), @p0, 1000, 'TL', 1, 1000, 1, 0, 1) returning id
            """, tx, [taraf]);
        var isl = await b.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, hesap_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar,
                                           sube_id, ekleyen, durum, plan_islem_id)
            values (21, now(), @p0, @p1, 400, 'TL', 1, 400, 1, 0, 0, @p2) returning id
            """, tx, [taraf, hesap, plan]);
        await b.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", tx, [isl]);
        await b.CalistirAsync("select public.fn_kasa_islem_kesinlestir(@p0, 0)", tx, [isl]);
        decimal Gerceklesen() => b.TekDegerAsync<decimal>(
            "select gerceklesen_tutar from public.kasa_islem where id = @p0", tx, [plan]).GetAwaiter().GetResult();
        Assert.Equal(400m, Gerceklesen());

        // 6) 400 -> 450 düzeltme: plan 450 (eskiden 850).
        await b.CalistirAsync("select public.fn_kasa_islem_duzelt_hazirla(@p0)", tx, [isl]);
        await b.CalistirAsync("update public.kasa_islem set tutar = 450, yerel_tutar = 450 where id = @p0", tx, [isl]);
        await b.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", tx, [isl]);
        await b.CalistirAsync("select public.fn_kasa_islem_kesinlestir(@p0, 0)", tx, [isl]);
        Assert.Equal(450m, Gerceklesen());

        // 5) TL işlem + USD ekstre: çevrilmemiş tutar USD etiketiyle yazılmaz.
        await b.CalistirAsync("select public.fn_kasa_islem_duzelt_hazirla(@p0)", tx, [isl]);
        await b.CalistirAsync("update public.kasa_islem set ekstre_dovizi = 'USD' where id = @p0", tx, [isl]);
        await b.CalistirAsync("savepoint s", tx, []);
        var hata = await Assert.ThrowsAnyAsync<Exception>(() =>
            b.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", tx, [isl]));
        Assert.Contains("Ekstre dövizi", hata.Message);
        await b.CalistirAsync("rollback to savepoint s", tx, []);
        await tx.RollbackAsync();
    }

    [VtFact]
    public async Task Gerceklesmis_islem_taslaga_cekilemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await IstemciAsync(d, "kasa_islem:gd");
        var taraf = await TarafAsync(d);
        var hesap = await api.Veri.TekDegerAsync<int>(
            "select id from public.hesap where coalesce(doviz_cinsi, 'TL') = 'TL' order by id limit 1");
        var isl = await api.Veri.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, hesap_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar,
                                           sube_id, ekleyen, durum)
            values (21, now(), @p0, @p1, 5000, 'TL', 1, 5000, 1, 0, 0) returning id
            """, [taraf, hesap]);
        KasaTemizligi(d, $"taraf_id = {taraf}");
        await api.Veri.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", [isl]);
        await api.Veri.CalistirAsync("select public.fn_kasa_islem_kesinlestir(@p0, 0)", [isl]);

        var y = await h.PutAsJsonAsync($"/api/kasa-islem/{isl}", new
        {
            islem = new { aciklama = "taslağa çek" },
            secenekler = new { taslak = true },
        });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, y.StatusCode);
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select durum::int from public.kasa_islem where id = @p0", [isl]));
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.mali_hareket where kasa_islem_id = @p0", [isl]));
    }

    [VtFact]
    public async Task Ayni_satir_payina_eszamanli_dagitim_fazlasi_reddedilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var taraf = await TarafAsync(d);
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no, kdv_durum, belge_dovizi, rapor_dovizi, doviz_kuru)
            values (19, 30, 0, now(), @p0, 1, 'DAGTEST', 'Dahil', 'TL', 'TL', 1) returning id
            """, [taraf]);
        var satir = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, adet, miktar, birim_fiyat, kdv, tutar, doviz_birim_fiyat, sube_id)
            values (@p0, 1, 2, 1, 1, 500, 0, 500, 500, 1) returning id
            """, [belge]);
        await api.Veri.CalistirAsync("""
            insert into public.belge_satir_dagilim (belge_satir_id, rota, hasta_provizyon, elle) values (@p0, 1, 500, 1)
            on conflict (belge_satir_id) do update set hasta_provizyon = 500, sgk = 0, oss = 0, hasta_ek_katki = 0, elle = 1
            """, [satir]);
        async Task<int> Tahsilat()
        {
            var id = await api.Veri.TekDegerAsync<int>("""
                insert into public.kasa_islem (tur, islem_tarihi, taraf_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar, belge_id, sube_id, ekleyen, durum)
                values (21, now(), @p0, 500, 'TL', 1, 500, @p1, 1, 0, 2) returning id
                """, [taraf, belge]);
            return id;
        }
        var a = await Tahsilat();
        var bIsl = await Tahsilat();
        // Temizlik TERS sırada çalışır: dağıtım, işlemler, dağılım, satır, belge.
        d.Temizle($"delete from public.belge where id = {belge}");
        d.Temizle($"delete from public.belge_satir where id = {satir}");
        d.Temizle($"delete from public.belge_satir_dagilim where belge_satir_id = {satir}");
        d.Temizle($"delete from public.kasa_islem where id in ({a}, {bIsl})");
        d.Temizle($"delete from public.kasa_islem_dagitim where belge_satir_id = {satir}");

        const string Dagit = "insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar) values (@p0, @p1, 1, 500)";
        await using var ba = await api.Veri.AcAsync();
        await using var ta = await ba.BeginTransactionAsync();
        await ba.CalistirAsync(Dagit, ta, [a, satir]);

        await using var bb = await api.Veri.AcAsync();
        await using var tb = await bb.BeginTransactionAsync();
        var ikinci = Task.Run(() => bb.CalistirAsync(Dagit, tb, [bIsl, satir]));
        await Task.Delay(500);
        Assert.False(ikinci.IsCompleted);          // satır kilidini bekliyor (eskiden ikisi de geçiyordu)
        await ta.CommitAsync();
        var hata = await Assert.ThrowsAnyAsync<Exception>(() => ikinci);
        Assert.Contains("payından fazla", hata.Message);
    }

    [VtFact]
    public async Task Donusumde_ayni_satir_iki_kez_secilemez()
    {
        var acik = await api.Veri.TekAsync<int[]>("""
            select b.id, s.id from public.belge b
              join public.belge_satir s on s.belge_id = b.id
              join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
             where b.tur = 19 and b.tipi = 30 and b.durum = 0 and b.sube_id = @p0 and dg.hasta_provizyon - dg.hasta_provizyon_kapatilan >= 20
             order by b.id limit 1
            """, [Merkez], o => new[] { o.GetInt32(0), o.GetInt32(1) });
        Assert.True(acik is not null, "Test veritabanında hasta payı açık başvuru yok.");
        await using var d = new TestDunyasi(api.Veri);
        using var h = await IstemciAsync(d, "belge:gedk", "belge.donustur", "belge.satis.fis:gedk", "belge.satis.tahakkuk:gedk");
        var y = await h.PostAsJsonAsync($"/api/belge/{acik![0]}/donustur", new
        {
            hedefTur = 17, pay = 1,
            satirlar = new[] { new { satirId = acik[1], miktar = 0m, tutar = 10m }, new { satirId = acik[1], miktar = 0m, tutar = 10m } },
        });
        Assert.Equal(HttpStatusCode.BadRequest, y.StatusCode);
    }

    /// <summary>Taraflara ait kasa işlemleri + bacak + fiş temizliği (iptal ters kaydı ve emanet virmanı dahil).</summary>
    private static void KasaTemizligi(TestDunyasi d, string tarafKosulu)
    {
        var islemler = $"select id from public.kasa_islem where {tarafKosulu.Replace("taraf_id", "kasa_islem.taraf_id")}"
                     + $" or {tarafKosulu.Replace("taraf_id", "kasa_islem.karsi_taraf_id")}";
        // Ters sırada çalışır: bağlar koparılır -> fiş satırı -> fiş -> bacak -> işlem.
        d.Temizle($"delete from public.kasa_islem where id in ({islemler})");
        d.Temizle($"delete from public.mali_hareket where kasa_islem_id in ({islemler})");
        d.Temizle($"delete from public.muhasebe_fis where kaynak_tur = 1 and kaynak_id in ({islemler})");
        d.Temizle($"delete from public.muhasebe_fis_satir where fis_id in (select id from public.muhasebe_fis where kaynak_tur = 1 and kaynak_id in ({islemler}))");
        d.Temizle($"update public.muhasebe_fis set ters_fis_id = null where kaynak_tur = 1 and kaynak_id in ({islemler})");
        d.Temizle($"update public.kasa_islem set muhasebe_fis_id = null, iptal_islem_id = null where id in ({islemler})");
    }

    [VtFact]
    public async Task Tahsilat_iptalinde_SGK_katilim_emaneti_de_iptal_olur()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await IstemciAsync(d, "kasa_islem:gd", "kasa.iptal");
        var hasta = await TarafAsync(d);
        // Yürürlükte sözleşmesi olan, son başvurularda ödeyen olan bir kurum (başvuru tetiği sözleşme ister).
        var sgk = await api.Veri.TekDegerAsync<int?>("""
            select bb.odeyen_kurum_id from public.belge_basvuru bb join public.belge b on b.id = bb.id
             where bb.odeyen_kurum_id is not null and b.belge_tarihi > now() - interval '60 day'
             group by 1 order by count(*) desc limit 1
            """);
        Assert.True(sgk is not null, "Test veritabanında sözleşmeli kurum yok.");
        var hesap = await api.Veri.TekDegerAsync<int>(
            "select id from public.hesap where coalesce(doviz_cinsi, 'TL') = 'TL' order by id limit 1");
        var basvuru = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no, kdv_durum, belge_dovizi, rapor_dovizi, doviz_kuru)
            values (19, 30, 0, now(), @p0, 1, 'EMANETTEST', 'Dahil', 'TL', 'TL', 1) returning id
            """, [hasta]);
        await api.Veri.CalistirAsync("""
            insert into public.belge_basvuru (id, odeyen_kurum_id) values (@p0, @p1)
            on conflict (id) do update set odeyen_kurum_id = excluded.odeyen_kurum_id
            """, [basvuru, sgk]);
        var satir = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, adet, miktar, birim_fiyat, kdv, tutar, doviz_birim_fiyat, sube_id)
            values (@p0, 1, 2, 1, 1, 50, 0, 50, 50, 1) returning id
            """, [basvuru]);
        await api.Veri.CalistirAsync("""
            insert into public.belge_satir_dagilim (belge_satir_id, rota, hasta_provizyon, sgk_katilim_payi, elle)
            values (@p0, 1, 50, 50, 1)
            on conflict (belge_satir_id) do update set hasta_provizyon = 50, sgk_katilim_payi = 50, elle = 1
            """, [satir]);
        d.Temizle($"delete from public.belge where id = {basvuru}");
        d.Temizle($"delete from public.belge_basvuru where id = {basvuru}");
        d.Temizle($"delete from public.belge_satir where id = {satir}");
        d.Temizle($"delete from public.belge_satir_dagilim where belge_satir_id = {satir}");
        KasaTemizligi(d, $"taraf_id = {hasta}");
        d.Temizle($"delete from public.kasa_islem_dagitim where belge_satir_id = {satir}");

        var isl = await api.Veri.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, hesap_id, tutar, doviz_cinsi, doviz_kuru, yerel_tutar,
                                           belge_id, sube_id, ekleyen, durum)
            values (21, now(), @p0, @p1, 50, 'TL', 1, 50, @p2, 1, 0, 0) returning id
            """, [hasta, hesap, basvuru]);
        await api.Veri.CalistirAsync("select public.fn_kasa_islem_bacak_uret(@p0)", [isl]);
        await api.Veri.CalistirAsync("select public.fn_kasa_islem_kesinlestir(@p0, 0)", [isl]);
        await api.Veri.CalistirAsync(
            "insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar) values (@p0, @p1, 5, 50)", [isl, satir]);
        await api.Veri.CalistirAsync("select public.fn_sgk_katilim_emanet_yaz(@p0)", [isl]);
        const string Canli = "select count(*)::int from public.kasa_islem where kaynak_tur = 473 and kaynak_id = @p0 and durum = 2 and iptal_islem_id is null";
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(Canli, [isl]));

        var y = await h.PostAsJsonAsync($"/api/kasa-islem/{isl}/iptal", new { sebep = "test iptali" });
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {await y.Content.ReadAsStringAsync()}");
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(Canli, [isl]));   // eskiden virman canlı kalıyordu
    }
}
