using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// DENETİM 28.09.2026 — FAZ A: ŞUBE, KAYIT VE ROL ERİŞİMİ (bulgu 1, 2, 3, 7).
///
/// <para>Her test GERÇEK API sürecine gerçek HTTP isteği atar ve kararın
/// kendisini (durum kodu) ve yan etkisini (satır / işlem günlüğü) izole test
/// veritabanından okur. Eski davranışta bu testlerin her biri kırmızıdır:
/// şubesiz token şube süzgeçsiz listeyi okuyordu, salt okuyucu fiyat listesi
/// üretebiliyordu, grafik ucu satırın şubesine bakmıyordu, tetkik izni
/// token'daki eski rolle soruluyordu.</para>
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class ErisimGuvenligiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    // ------------------------------------------------------------ bulgu 1 ----

    [VtFact]
    public async Task Son_sube_yetkisi_kalkinca_ayni_token_sube_verisine_erisemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var pasif = await d.PasifSubeAsync();
        var rol = await d.RolAsync("liste", "lab:g");
        var (u, kod) = await d.KullaniciAsync(rol, pasif);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);

        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);

        Assert.Equal(HttpStatusCode.OK, (await h.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);

        // Son şube yetkisi kaldırıldı; token hâlâ geçerli.
        await d.SubeAlAsync(u, Merkez);

        var y = await h.PostAsJsonAsync("/api/liste/lab-istem", new { });
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);
        Assert.Equal("YASAK", await ApiSunucuOlgusu.HataKoduAsync(y));

        // Profil ucu açık kalır ama YAZMA hakkı yok, aktif şube yok.
        var ben = await h.GetFromJsonAsync<JsonElement>("/api/kimlik/ben");
        var k = ben.GetProperty("kullanici");
        Assert.False(k.GetProperty("subeYazma").GetBoolean());
        Assert.False(k.TryGetProperty("subeId", out var s) && s.ValueKind == JsonValueKind.Number);
    }

    [VtFact]
    public async Task Sube_basligi_yetkisizse_ya_da_bozuksa_reddedilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("baslik", "lab:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);

        using (var h = api.Istemci(access, Merkez))
            Assert.Equal(HttpStatusCode.OK, (await h.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);

        using (var h = api.Istemci(access, Ankara))
            Assert.Equal(HttpStatusCode.Forbidden, (await h.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);

        using (var h = api.Istemci(access))
        {
            h.DefaultRequestHeaders.Add("X-Sube-Id", "1;drop");
            var y = await h.PostAsJsonAsync("/api/liste/lab-istem", new { });
            Assert.Equal(HttpStatusCode.BadRequest, y.StatusCode);
        }
    }

    // ------------------------------------------------------------ bulgu 2 ----

    [VtFact]
    public async Task Salt_okunur_subede_yazan_aksiyon_reddedilir_ve_yan_etki_birakmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("fiyat", "fiyat_listesi:g", "fiyat_listesi.uret", "veri.iceri-al");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: false, varsayilan: true);

        var liste = await api.Veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, baslangic, bitis)
            values (@p0, current_date, current_date + 30) returning id
            """, [d.Onek + " liste"]);
        d.Temizle($"delete from public.fiyat_listesi where id = {liste}");
        d.Temizle($"delete from public.fiyat_listesi_satir where liste_id = {liste}");

        async Task<(long Satir, long Log)> Durum() => (
            await api.Veri.TekDegerAsync<long>(
                "select count(*) from public.fiyat_listesi_satir where liste_id = @p0", [liste]),
            await api.Veri.TekDegerAsync<long>(
                "select count(*) from public.islem_log where kayit_id = @p0 and kullanici_id = @p1",
                [liste, u]));

        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);

        var once = await Durum();
        var y = await h.PostAsJsonAsync($"/api/fiyat-listesi/{liste}/uret", new { });
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);
        Assert.Equal(once, await Durum());

        // OKUYAN aksiyon salt okuma şubesinde çalışmaya devam eder.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync("/api/iceri-alma/hedefler")).StatusCode);

        // Aynı işlem yazılabilir şubede tamamlanır ve günlüğe düşer.
        await d.SubeVerAsync(u, Merkez, yazma: true);
        y = await h.PostAsJsonAsync($"/api/fiyat-listesi/{liste}/uret", new { });
        Assert.True(y.IsSuccessStatusCode, await y.Content.ReadAsStringAsync());
        Assert.Equal(once.Log + 1, (await Durum()).Log);
    }

    // ------------------------------------------------------------ bulgu 3 ----

    private async Task<(int Istem, int Satir, int Grafik)> LabKaydiAsync(TestDunyasi d, int tetkik,
        int hasta, int sube)
    {
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, @p1, @p2, 1, 2, 3, 1) returning id
            """, [hasta, sube, d.Onek + "-" + Guid.NewGuid().ToString("N")[..6]]);
        var satir = await api.Veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 3, 10) returning id
            """, [istem, tetkik]);
        var grafik = await api.Veri.TekDegerAsync<int>("""
            insert into public.lab_sonuc_grafik (istem_satir_id, tur, baslik, seri, kaynak, raporda, sube_id)
            values (@p0, 1, 'Eğri', '{"y":[1,2,3]}'::jsonb, 1, 1, @p1) returning id
            """, [satir, sube]);
        d.Temizle($"delete from public.lab_istem where id = {istem}");
        d.Temizle($"delete from public.lab_istem_satir where id = {satir}");
        d.Temizle($"delete from public.lab_sonuc where istem_satir_id = {satir}");
        d.Temizle($"delete from public.lab_sonuc_grafik where istem_satir_id = {satir}");
        return (istem, satir, grafik);
    }

    private async Task<int> TetkikAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.lab_tetkik (kod, ad) values (@p0, @p1) returning id",
            [d.Onek.ToUpperInvariant(), d.Onek + " tetkik"]);
        d.Temizle($"delete from public.lab_tetkik where id = {id}");
        return id;
    }

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, 1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4]]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    private async Task<int> DokumanAsync(TestDunyasi d, int satir, int sube, string kaynak = "lab-sonuc")
    {
        var hash = Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N");
        await api.Veri.CalistirAsync("""
            insert into public.dokuman_icerik (hash, icerik, content_type, boyut)
            values (@p0, @p1, 'image/png', 5)
            """, [hash, "hello"u8.ToArray()]);
        var id = await api.Veri.TekDegerAsync<int>("""
            insert into public.dokuman (kaynak, kaynak_id, ad, content_type, boyut, hash, sube_id)
            values (@p3, @p0, 'egri.png', 'image/png', 5, @p1, @p2) returning id
            """, [satir, hash, sube, kaynak]);
        d.Temizle($"delete from public.dokuman_icerik where hash = '{hash}'");
        d.Temizle($"delete from public.dokuman where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Lab_grafigi_ve_bagli_uclar_baska_subenin_kaydini_vermez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tetkik = await TetkikAsync(d);
        var hasta = await HastaAsync(d);
        var a = await LabKaydiAsync(d, tetkik, hasta, Merkez);
        var b = await LabKaydiAsync(d, tetkik, hasta, Ankara);
        var dokA = await DokumanAsync(d, a.Satir, Merkez);
        var dokB = await DokumanAsync(d, b.Satir, Ankara);

        var rol = await d.RolAsync("lab", "lab:g", "lab.sonuc:gd", "lab.grafik.yukle");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        // Kendi şubesi: görünür.
        var kendi = await h.GetFromJsonAsync<JsonElement>($"/api/lab/satir/{a.Satir}/grafik");
        Assert.Equal(1, kendi.GetProperty("satirlar").GetArrayLength());
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/dokuman-icerik/{dokA}")).StatusCode);

        // Başka şube: okuma, yükleme, değiştirme, silme, rapor, detay, geçmiş, dosya
        //   hepsi "bulunamadı" - var olmayan kayıtla AYNI cevap.
        var yok = await h.GetAsync("/api/lab/satir/2147483000/grafik");
        Assert.Equal(HttpStatusCode.NotFound, yok.StatusCode);
        foreach (var yol in new[]
        {
            $"/api/lab/satir/{b.Satir}/grafik", $"/api/lab/rapor/{b.Istem}",
            $"/api/lab/istem/{b.Istem}", $"/api/lab/satir/{b.Satir}/gecmis",
            $"/api/dokuman-icerik/{dokB}",
        })
            Assert.True((await h.GetAsync(yol)).StatusCode == HttpStatusCode.NotFound, yol);

        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PutAsJsonAsync($"/api/lab/grafik/{b.Grafik}", new { baslik = "x" })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.DeleteAsync($"/api/lab/grafik/{b.Grafik}")).StatusCode);
        using (var form = new MultipartFormDataContent { { new ByteArrayContent([1, 2, 3]), "dosya", "a.png" } })
            Assert.Equal(HttpStatusCode.NotFound,
                (await h.PostAsync($"/api/lab/satir/{b.Satir}/grafik", form)).StatusCode);

        // Yan etki yok: B'nin grafiği yerinde ve değişmedi, dosya eklenmedi.
        Assert.Equal("Eğri", await api.Veri.TekDegerAsync<string>(
            "select baslik from public.lab_sonuc_grafik where id = @p0", [b.Grafik]));
        Assert.Equal(1L, await api.Veri.TekDegerAsync<long>(
            "select count(*) from public.lab_sonuc_grafik where istem_satir_id = @p0", [b.Satir]));

        // O şubeye yetki verilince ve o şubede çalışınca aynı kayıt açılır.
        await d.SubeVerAsync(u, Ankara, yazma: true);
        using var hb = api.Istemci(access, Ankara);
        Assert.Equal(HttpStatusCode.OK, (await hb.GetAsync($"/api/lab/satir/{b.Satir}/grafik")).StatusCode);
    }

    [VtFact]
    public async Task Portal_hastasi_baskasinin_grafigine_ulasamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tetkik = await TetkikAsync(d);
        var rol = await d.RolAsync("portal", "lab.sonuc:g");
        await api.Veri.CalistirAsync("update public.rol set portal_turu = 3 where id = @p0", [rol]);

        var (p1, kod) = await d.KullaniciAsync(rol, Merkez, hasta: true);
        await d.SubeVerAsync(p1, Merkez, yazma: false, varsayilan: true);
        var baska = await HastaAsync(d);

        var kendi = await LabKaydiAsync(d, tetkik, p1, Merkez);
        var elin = await LabKaydiAsync(d, tetkik, baska, Merkez);

        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/lab/satir/{kendi.Satir}/grafik")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/lab/satir/{elin.Satir}/grafik")).StatusCode);
    }

    // ------------------------------------------------------------ bulgu 7 ----

    [VtFact]
    public async Task Tetkik_izni_token_degil_guncel_rol_kumesinden_cozulur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tetkik = await TetkikAsync(d);
        var hasta = await HastaAsync(d);
        var k = await LabKaydiAsync(d, tetkik, hasta, Merkez);
        await api.Veri.CalistirAsync("""
            insert into public.lab_sonuc (istem_satir_id, tetkik_id, sube_id, deger_metin, durum)
            values (@p0, @p1, 1, '5', 3)
            """, [k.Satir, tetkik]);

        var r1 = await d.RolAsync("r1", "lab.sonuc:g");
        var r2 = await d.RolAsync("r2", "lab.sonuc:g");
        var r3 = await d.RolAsync("r3", "lab:g");       // genel sonuç izni YOK
        // Tetkik KISITLI: yalnız r2 ve r3 görebilir.
        await api.Veri.CalistirAsync("""
            insert into public.lab_tetkik_kisit (tetkik_id, rol_id, iste, gor, onayla)
            values (@p0, @p1, 1, 1, 1), (@p0, @p2, 1, 1, 1)
            """, [tetkik, r2, r3]);

        var (u, kod) = await d.KullaniciAsync(r1, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);   // TOKEN DEĞİŞMEZ

        async Task<(HttpStatusCode Grafik, long Liste)> Durum()
        {
            var g = (await h.GetAsync($"/api/lab/satir/{k.Satir}/grafik")).StatusCode;
            var l = await h.PostAsJsonAsync("/api/liste/lab-sonuc", new
            {
                filtre = new { alan = "istemSatirId", op = "esit", deger = k.Satir }
            });
            var liste = l.IsSuccessStatusCode
                ? (await l.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("toplamKayit").GetInt64()
                : -1;
            return (g, liste);
        }

        Assert.Equal((HttpStatusCode.Forbidden, 0L), await Durum());

        // Ek rol eklendi: sonraki istekte izin.
        await api.Veri.CalistirAsync("insert into public.kullanici_rol (kullanici_id, rol_id) values (@p0, @p1)", [u, r2]);
        Assert.Equal((HttpStatusCode.OK, 1L), await Durum());

        // Ek rol çıkarıldı: izin geri alınır.
        await api.Veri.CalistirAsync("delete from public.kullanici_rol where kullanici_id = @p0", [u]);
        Assert.Equal((HttpStatusCode.Forbidden, 0L), await Durum());

        // Ana rol değişti (token'daki rol hâlâ r1).
        await api.Veri.CalistirAsync("update public.taraf_kullanici set rol_id = @p1 where id = @p0", [u, r2]);
        Assert.Equal((HttpStatusCode.OK, 1L), await Durum());

        // Kısıt kaldırıldı / eklendi: aynı istekte karar tazelenir.
        await api.Veri.CalistirAsync("update public.lab_tetkik_kisit set gor = 0 where tetkik_id = @p0 and rol_id = @p1", [tetkik, r2]);
        Assert.Equal((HttpStatusCode.Forbidden, 0L), await Durum());

        // Tetkik izni GENEL KAYNAK İZNİNİN yerine geçmez: r3 tetkike izinli ama
        //   `lab.sonuc` yetkisi yok.
        await api.Veri.CalistirAsync("update public.taraf_kullanici set rol_id = @p1 where id = @p0", [u, r3]);
        Assert.Equal(HttpStatusCode.Forbidden, (await h.GetAsync($"/api/lab/satir/{k.Satir}/grafik")).StatusCode);
    }

    // ------------------------------------ tekrar denetim #1 (doküman) ----

    private async Task<(string Kod, bool Var)> DokumanDurumuAsync(int dokuman)
        => (await api.Veri.TekDegerAsync<string>(
                "select coalesce(paylasim_kodu, '') from public.dokuman where id = @p0", [dokuman]) ?? "",
            await api.Veri.TekDegerAsync<long>(
                "select count(*) from public.dokuman where id = @p0", [dokuman]) == 1);

    private async Task<int> CariAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, musteri, sube_id) values (@p0, 1, 1) returning id",
            [d.Onek + " cari " + Guid.NewGuid().ToString("N")[..4]]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Baska_kart_yolu_altinda_lab_dokumani_paylasilamaz_silinemez_degistirilemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tetkik = await TetkikAsync(d);
        var hasta = await HastaAsync(d);
        var b = await LabKaydiAsync(d, tetkik, hasta, Ankara);
        var dokLab = await DokumanAsync(d, b.Satir, Ankara);          // başka şubenin lab dosyası
        var cari = await CariAsync(d);
        var dokCari = await DokumanAsync(d, cari, Merkez, "taraf");   // kendi yetkisindeki cari dosyası

        // Cari yetkisi TAM, lab yetkisi YOK; kullanıcı Merkez'de.
        var rol = await d.RolAsync("carici", "cari:gdk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);

        // ESKİ SALDIRI: cari yolu + lab dokümanı kimliği.
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/dokuman/cari/{cari}/{dokLab}/paylas", new { })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/dokuman/cari/{cari}/{dokLab}/varsayilan", new { })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PutAsJsonAsync($"/api/dokuman/cari/{cari}/{dokLab}", new { ad = "x" })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.DeleteAsync($"/api/dokuman/cari/{cari}/{dokLab}")).StatusCode);
        // "Kendi kartı" istisnası URL'ye değil gerçek sahipliğe bağlı.
        Assert.Equal(HttpStatusCode.NotFound, (await h.DeleteAsync($"/api/dokuman/personel/{u}/{dokLab}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/dokuman/personel/{u}/{dokLab}/paylas", new { })).StatusCode);
        // Fiziksel ad yolu (doküman listesi) ve doğrudan içerik de kapalı.
        Assert.Equal(HttpStatusCode.NotFound, (await h.DeleteAsync($"/api/dokuman/lab-sonuc/{b.Satir}/{dokLab}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/dokuman-icerik/{dokLab}")).StatusCode);

        // Yan etki yok: kod üretilmedi, doküman yerinde.
        Assert.Equal(("", true), await DokumanDurumuAsync(dokLab));

        // Aynı kullanıcı kendi yetkisindeki cari dokümanını paylaşabilir ve okuyabilir.
        Assert.Equal(HttpStatusCode.OK, (await h.PostAsJsonAsync($"/api/dokuman/cari/{cari}/{dokCari}/paylas", new { })).StatusCode);
        Assert.NotEqual("", (await DokumanDurumuAsync(dokCari)).Kod);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/dokuman-icerik/{dokCari}")).StatusCode);
    }

    [VtFact]
    public async Task Dokuman_icerigi_ve_yonetim_uclari_kaynak_yetkisi_ve_kapsami_ister()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tetkik = await TetkikAsync(d);
        var hasta = await HastaAsync(d);
        var b = await LabKaydiAsync(d, tetkik, hasta, Ankara);
        var dokLab = await DokumanAsync(d, b.Satir, Ankara);
        var cari = await CariAsync(d);
        var dokCari = await DokumanAsync(d, cari, Merkez, "taraf");
        var dokKlasor = await DokumanAsync(d, 2147480000, Merkez, "klasor");

        // Yalnız DOKÜMAN YÖNETİMİ yetkisi: kart/lab yetkisi yok.
        var rol = await d.RolAsync("dms", "dokuman:gdk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);

        // Lab dışındaki kaynak da kapsam ister: cari yetkisi olmayan cari dosyasını açamaz.
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/dokuman-icerik/{dokCari}")).StatusCode);

        // DMS kimliğiyle alternatif yollar kapalı.
        foreach (var dok in new[] { dokLab, dokCari })
        {
            Assert.Equal(HttpStatusCode.NotFound,
                (await h.PostAsJsonAsync($"/api/dokuman-yonetim/{dok}/paylasim", new { gunSayisi = 1 })).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound,
                (await h.PostAsJsonAsync($"/api/dokuman-yonetim/{dok}/tasi", new { gizlilik = 1 })).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound,
                (await h.PostAsJsonAsync($"/api/dokuman-yonetim/{dok}/surum", new { hash = "x" })).StatusCode);
            Assert.Equal(0L, await api.Veri.TekDegerAsync<long>(
                "select count(*) from public.dokuman_paylasim where dokuman_id = @p0", [dok]));
        }

        // Kurumsal klasör dokümanı DMS yetkisiyle yönetilir ve paylaşılır.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/dokuman-icerik/{dokKlasor}")).StatusCode);
        var y = await h.PostAsJsonAsync($"/api/dokuman-yonetim/{dokKlasor}/paylasim", new { gunSayisi = 1 });
        Assert.True(y.IsSuccessStatusCode, await y.Content.ReadAsStringAsync());
        d.Temizle($"delete from public.dokuman_olay where dokuman_id in ({dokLab}, {dokCari}, {dokKlasor})");
        d.Temizle($"delete from public.dokuman_paylasim where dokuman_id = {dokKlasor}");
    }
}
