using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ LABORATUVAR GÖNDERİMİ (445) — veritabanı kuralları.
///
/// Numune binadan çıktıktan sonra elimizde yalnız kayıt kalır. Buradaki
/// kurallar o kaydın tutarlılığını korur: aynı tetkik iki kez gönderilemez
/// (mükerrer fatura ve iki farklı sonuç), gecikme görünümü sözleşme TAT'ını
/// aşanı gösterir.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class DisLabTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public DisLabTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private static async Task<(int DisLabId, int HastaId, int IstemId, int SatirId,
                               int NumuneId)>
        KurAsync(VeriKaynagi veri, string kod, short tatGun = 3)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'TSH'");

        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, tedarikci, sube_id)
            values ('TEST DISLAB', 'TEST', 'DISLAB', 1, 1,
                    (select min(id) from public.sube))
            returning id
            """);
        var disLabId = await veri.TekDegerAsync<int>("""
            insert into public.lab_dis_lab (taraf_id, kod, ad, sozlesme_tat_gun, durum)
            values (@p0, @p1, 'TEST DIŞ LAB', @p2, 0)
            returning id
            """, [hastaId, kod, tatGun]);

        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, istem_no, bolum, durum)
            values (@p0, 'TEST-DL', 1, 1) returning id
            """, [hastaId]);
        var barkod = await veri.TekDegerAsync<string>(
            "select public.fn_lab_barkod_uret(0)") ?? "";
        var numuneId = await veri.TekDegerAsync<int>("""
            insert into public.lab_numune (barkod, istem_id, hasta_id, numune_tipi,
                                           tup_tipi, durum)
            values (@p0, @p1, @p2, 1, 1, 3) returning id
            """, [barkod, istemId, hastaId]);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, numune_id,
                                                kod, ad, durum, sira)
            values (@p0, @p1, @p2, 'TSH', 'TSH', 1, 10) returning id
            """, [istemId, tetkikId, numuneId]);

        return (disLabId, hastaId, istemId, satirId, numuneId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int disLabId, int hastaId,
                                           int istemId)
    {
        await veri.CalistirAsync("""
            delete from public.lab_dis_gonderim_satir
             where gonderim_id in (select id from public.lab_dis_gonderim
                                    where dis_lab_id = @p0)
            """, [disLabId]);
        await veri.CalistirAsync(
            "update public.lab_istem_satir set dis_gonderim_id = null where istem_id = @p0",
            [istemId]);
        await veri.CalistirAsync(
            "delete from public.lab_dis_gonderim where dis_lab_id = @p0", [disLabId]);
        await veri.CalistirAsync("delete from public.lab_dis_test where dis_lab_id = @p0",
                                 [disLabId]);
        await veri.CalistirAsync("delete from public.lab_dis_lab where id = @p0",
                                 [disLabId]);
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
                                 [istemId]);
        await veri.CalistirAsync("delete from public.lab_numune where istem_id = @p0",
                                 [istemId]);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId]);
        await veri.CalistirAsync("delete from public.taraf where id = @p0", [hastaId]);
    }

    private static async Task<int> GonderimAcAsync(VeriKaynagi veri, int disLabId,
        int satirId, int numuneId, int gunOnce = 0)
    {
        var no = await veri.TekDegerAsync<string>(
            "select public.fn_lab_dis_gonderim_no()") ?? "";
        var id = await veri.TekDegerAsync<int>("""
            insert into public.lab_dis_gonderim
                   (gonderim_no, dis_lab_id, gonderim_zamani, durum, tasima_kosulu)
            values (@p0, @p1, now() - make_interval(days => @p2), 2, 2)
            returning id
            """, [no, disLabId, gunOnce]);
        var tetkikId = await veri.TekDegerAsync<int>(
            "select tetkik_id from public.lab_istem_satir where id = @p0", [satirId]);
        await veri.CalistirAsync("""
            insert into public.lab_dis_gonderim_satir
                   (gonderim_id, istem_satir_id, numune_id, tetkik_id, durum)
            values (@p0, @p1, @p2, @p3, 1)
            """, [id, satirId, numuneId, tetkikId]);
        await veri.CalistirAsync("""
            update public.lab_istem_satir set durum = 7, dis_gonderim_id = @p1
             where id = @p0
            """, [satirId, id]);
        return id;
    }

    [Fact]
    public async Task Gonderim_numarasi_YILA_gore_artar()
    {
        if (!_olgu.Baglandi(nameof(Gonderim_numarasi_YILA_gore_artar))) return;
        var veri = _olgu.Gerekli();

        var a = await veri.TekDegerAsync<string>(
            "select public.fn_lab_dis_gonderim_no()") ?? "";
        var b = await veri.TekDegerAsync<string>(
            "select public.fn_lab_dis_gonderim_no()") ?? "";

        Assert.StartsWith($"DL-{DateTime.Today.Year}/", a);
        Assert.NotEqual(a, b);
    }

    [Fact]
    public async Task AYNI_TETKIK_iki_kez_gonderilemez()
    {
        if (!_olgu.Baglandi(nameof(AYNI_TETKIK_iki_kez_gonderilemez))) return;
        var veri = _olgu.Gerekli();

        var (disLabId, hastaId, istemId, satirId, numuneId) =
            await KurAsync(veri, "TEST-DL-MUK");
        try
        {
            var ilk = await GonderimAcAsync(veri, disLabId, satirId, numuneId);
            Assert.True(ilk > 0);

            // Mükerrer gönderim hem ikinci kez faturalanır hem iki farklı
            //   sonuç döndürür - benzersiz indeks buna izin vermez.
            await Assert.ThrowsAsync<Npgsql.PostgresException>(async () =>
                await GonderimAcAsync(veri, disLabId, satirId, numuneId));
        }
        finally { await TemizleAsync(veri, disLabId, hastaId, istemId); }
    }

    [Fact]
    public async Task Dis_lab_REDDEDINCE_ayni_tetkik_yeniden_gonderilebilir()
    {
        if (!_olgu.Baglandi(nameof(Dis_lab_REDDEDINCE_ayni_tetkik_yeniden_gonderilebilir)))
            return;
        var veri = _olgu.Gerekli();

        var (disLabId, hastaId, istemId, satirId, numuneId) =
            await KurAsync(veri, "TEST-DL-RET");
        try
        {
            var ilk = await GonderimAcAsync(veri, disLabId, satirId, numuneId);

            // Reddedilen satır benzersizlik kısıtının DIŞINDA (durum 3):
            //   numune yeniden alınıp tekrar gönderilebilmeli.
            await veri.CalistirAsync("""
                update public.lab_dis_gonderim_satir set durum = 3,
                       ret_neden = 'Yetersiz numune'
                 where gonderim_id = @p0 and istem_satir_id = @p1
                """, [ilk, satirId]);

            var ikinci = await GonderimAcAsync(veri, disLabId, satirId, numuneId);
            Assert.NotEqual(ilk, ikinci);
        }
        finally { await TemizleAsync(veri, disLabId, hastaId, istemId); }
    }

    [Fact]
    public async Task Geciken_gorunumu_SOZLESME_TATini_asani_listeler()
    {
        if (!_olgu.Baglandi(nameof(Geciken_gorunumu_SOZLESME_TATini_asani_listeler)))
            return;
        var veri = _olgu.Gerekli();

        // Sözleşme TAT 3 gün; gönderim 10 gün önce yapıldı ve sonuç yok.
        var (disLabId, hastaId, istemId, satirId, numuneId) =
            await KurAsync(veri, "TEST-DL-GEC", tatGun: 3);
        try
        {
            var id = await GonderimAcAsync(veri, disLabId, satirId, numuneId,
                                           gunOnce: 10);

            var satir = await veri.TekAsync("""
                select gecikme_gun, bekleyen, toplam from public.v_lab_dis_geciken
                 where id = @p0
                """, [id],
                o => new { Gecikme = o.GetInt32(0), Bekleyen = o.GetInt64(1),
                           Toplam = o.GetInt64(2) });

            Assert.NotNull(satir);
            Assert.Equal(7, satir!.Gecikme);      // 10 - 3
            Assert.Equal(1, satir.Bekleyen);

            // Sonuç gelince listeden düşer: gecikme "bekleyen tetkik" içindir.
            await veri.CalistirAsync("""
                update public.lab_dis_gonderim_satir set durum = 2, sonuc_zamani = now()
                 where gonderim_id = @p0
                """, [id]);
            Assert.Equal(0, await veri.TekDegerAsync<long>(
                "select count(*) from public.v_lab_dis_geciken where id = @p0", [id]));
        }
        finally { await TemizleAsync(veri, disLabId, hastaId, istemId); }
    }

    [Fact]
    public async Task Gonderilen_satir_DIS_LAB_durumuna_gecer()
    {
        if (!_olgu.Baglandi(nameof(Gonderilen_satir_DIS_LAB_durumuna_gecer))) return;
        var veri = _olgu.Gerekli();

        var (disLabId, hastaId, istemId, satirId, numuneId) =
            await KurAsync(veri, "TEST-DL-DURUM");
        try
        {
            await GonderimAcAsync(veri, disLabId, satirId, numuneId);

            var s = await veri.TekAsync("""
                select durum, dis_gonderim_id from public.lab_istem_satir where id = @p0
                """, [satirId],
                o => new { Durum = o.GetInt16(0),
                           Gonderim = o.IsDBNull(1) ? (int?)null : o.GetInt32(1) });

            // Durum 7 = dış lab: teknisyen o tüpü kendi cihazında aramasın,
            //   çalışma listesinde "bekliyor" olarak durmasın.
            Assert.Equal(7, s!.Durum);
            Assert.NotNull(s.Gonderim);
        }
        finally { await TemizleAsync(veri, disLabId, hastaId, istemId); }
    }
}
