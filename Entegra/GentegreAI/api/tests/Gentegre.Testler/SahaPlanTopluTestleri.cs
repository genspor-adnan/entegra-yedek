using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ZİYARET PLANI = PANEL + ÇEKMECE (mockup temsilci_paneli_plan_v2.html; 1299): plan yanıtı özet kutularını ve
/// "sırası gelenler"i taşır; toplu planla seçili hedefleri güne sırayla yazar (saat verilmezse gündeki sondan + aralık),
/// o gün zaten planlı olanı atlar; Planı Üret hekim seçimiyle yalnız seçilenlere öneri açar.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class SahaPlanTopluTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<int> HekimAsync(TestDunyasi d, string ad, short siklik, string ilce)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, durum, sube_id) values ('', @p1, @p0, 1, 1, @p2) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id, ziyaret_sikligi_hafta) select y.id, 1, @p2, @p3 from y returning id",
            [d.Onek + ad.Replace(" ", "")[^2..], d.Onek + " " + ad, Merkez, siklik]);
        await api.Veri.CalistirAsync("insert into public.taraf_adres (taraf_id, ilce, varsayilan, sube_id) values (@p0, @p1, 1, @p2)", [id, ilce, Merkez]);
        d.Temizle($"delete from public.dis_hekim_ziyaret where hekim_id = {id}");
        d.Temizle($"delete from public.dis_hekim_temsilci where hekim_id = {id}");
        d.Temizle($"delete from public.taraf_adres where taraf_id = {id}");
        d.Temizle($"delete from public.taraf_personel where id = {id}");
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Plan_ozet_siradakiler_toplu_planla_ve_secili_uretim()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("sahaplan", ["dis_doktor.plan:g", "dis_doktor.ziyaret:ged", "dis_doktor:g"]);
        var (t, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(t, Merkez, yazma: true, varsayilan: true);
        await api.Veri.CalistirAsync("insert into public.taraf_personel (id, dis_hekim, sube_id) values (@p0, 0, @p1) on conflict (id) do nothing", [t, Merkez]);
        d.Temizle($"delete from public.taraf_personel where id = {t}");
        // Üç hekim: h1 gecikmiş (6 hafta önce ziyaret, sıklık 4), h2 sıklık 4 hiç ziyaret yok (sırası = kayıt + 4 hafta), h3 sıklıksız.
        var h1 = await HekimAsync(d, "Dr Geciken", 4, "Üsküdar");
        var h2 = await HekimAsync(d, "Dr Yeni Kayit", 4, "Üsküdar");
        var h3 = await HekimAsync(d, "Dr Sikliksiz", 0, "Kadıköy");
        foreach (var h in new[] { h1, h2, h3 })
            await api.Veri.CalistirAsync("insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')", [h, Merkez, t]);
        await api.Veri.CalistirAsync(
            "insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, durum, sonuc, hatirlat) values (@p0, @p1, @p2, now() - interval '42 days', 1, 1, 0)", [h1, t, Merkez]);

        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        var a = api.Istemci(access, Merkez);
        var bugun = DateOnly.FromDateTime(DateTime.Today);
        var haftaBas = bugun.AddDays(-(((int)bugun.DayOfWeek + 6) % 7));
        // Çarşamba; geçtiyse BUGÜN (aynı hafta): "planlı ziyaret" yalnız tarih >= bugün olanı sayar (1300) - Perşembe'den
        //   itibaren geçmiş Çarşamba'ya planlanan ziyaret işaretlenmiyor, test haftanın ikinci yarısında düşüyordu.
        var gun = haftaBas.AddDays(2) < bugun ? bugun : haftaBas.AddDays(2);

        // 1) Plan yanıtı: özet + sırası gelenler (h1 geciken; h3 sıklıksız listede değil).
        var plan = await (await a.GetAsync($"/api/dis-hekim/plan?hafta={haftaBas:yyyy-MM-dd}&temsilciId={t}")).Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(plan.TryGetProperty("ozet", out var ozet) && ozet.ValueKind == JsonValueKind.Object, "ozet yok");
        Assert.Equal(3, ozet.GetProperty("hedef_sayisi").GetInt32());
        Assert.Equal(1, ozet.GetProperty("sikliksiz_sayisi").GetInt32());
        var siradakiler = plan.GetProperty("siradakiler").EnumerateArray().Select(x => x.GetProperty("hekim_id").GetInt32()).ToList();
        Assert.Contains(h1, siradakiler);
        // h3 sıklıksız ama YENİ kayıt (90 gün): "yeni" ölçütüyle listede, gecikme 0.
        var h3Satir = plan.GetProperty("siradakiler").EnumerateArray().First(x => x.GetProperty("hekim_id").GetInt32() == h3);
        Assert.Equal(1, h3Satir.GetProperty("yeni_hekim").GetInt32());
        Assert.Equal(0, h3Satir.GetProperty("gecikme_gun").GetInt32());
        var h1Satir = plan.GetProperty("siradakiler").EnumerateArray().First(x => x.GetProperty("hekim_id").GetInt32() == h1);
        Assert.InRange(h1Satir.GetProperty("gecikme_gun").GetInt32(), 13, 15);
        Assert.Equal("Üsküdar", h1Satir.GetProperty("hekim_ilce").GetString());

        // 2) Toplu planla: h1 + h2 Çarşamba'ya; saat verilmedi -> 09:00 ve 10:30 (90 dk).
        var toplu = await a.PostAsJsonAsync("/api/dis-hekim/planla-toplu", new { hekimIdler = new[] { h1, h2 }, gun = gun.ToString("yyyy-MM-dd"), temsilciId = t });
        var tj = await toplu.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(toplu.IsSuccessStatusCode, tj.ToString());
        Assert.Equal(2, tj.GetProperty("sayi").GetInt32());
        var saatler = await api.Veri.ListeAsync(
            "select to_char(z.tarih, 'HH24:MI') from public.dis_hekim_ziyaret z where z.temsilci_id = @p0 and z.tarih::date = @p1 and z.durum = 0 order by z.tarih",
            new object?[] { t, gun }, o => o.GetString(0));
        Assert.Equal(["09:00", "10:30"], saatler);
        // Aynı gün tekrar: ikisi de atlanır; çekmeceden düşer (planlı ziyareti var).
        var tekrar = await (await a.PostAsJsonAsync("/api/dis-hekim/planla-toplu", new { hekimIdler = new[] { h1, h2 }, gun = gun.ToString("yyyy-MM-dd"), temsilciId = t })).Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(0, tekrar.GetProperty("sayi").GetInt32());
        Assert.Equal(2, tekrar.GetProperty("atlanan").GetInt32());
        var plan2 = await (await a.GetAsync($"/api/dis-hekim/plan?hafta={haftaBas:yyyy-MM-dd}&temsilciId={t}")).Content.ReadFromJsonAsync<JsonElement>();
        // Hedef listede KALIR (ilçe görünümü), planlı ziyareti işaretlenir.
        var h1Plan = plan2.GetProperty("siradakiler").EnumerateArray().First(x => x.GetProperty("hekim_id").GetInt32() == h1);
        Assert.Equal(JsonValueKind.Number, h1Plan.GetProperty("planli_ziyaret_id").ValueKind);
        // Günün işi satırı sıra bilgisini taşır.
        var z1 = plan2.GetProperty("ziyaretler").EnumerateArray().First(x => x.GetProperty("hekim_id").GetInt32() == h1);
        Assert.Equal(4, z1.GetProperty("siklik_hafta").GetInt32());

        // 3) Planı Üret seçili hedefle (1299): sıklıksız h3 normalde üretilmez, seçilince ÖNERİ açılır.
        var uret = await (await a.PostAsJsonAsync("/api/dis-hekim/plan/uret", new { haftaBas = haftaBas.ToString("yyyy-MM-dd"), temsilciId = t, hekimIdler = new[] { h3 } })).Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(1, uret.GetProperty("sayi").GetInt32());
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select count(*) from public.dis_hekim_ziyaret where hekim_id = @p0 and oneri = 1 and durum = 0", [h3]));
    }
}
