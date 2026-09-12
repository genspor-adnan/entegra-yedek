using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ÖDEME DAĞILIMI — UÇTAN UCA AKIŞ (468/469/470/474).
///
/// <see cref="DagilimTestleri"/> saf hesabı (<c>fn_belge_satir_dagit</c>)
/// doğruluyor; burada GERÇEK ZİNCİR çalışıyor: sözleşme → fiyat listeleri →
/// başvuru → satır → <c>fn_belge_satir_dagilim_tazele</c>. Hesap doğru olup
/// zincirin bir halkası (liste çözümü, alt kurum, rota) yanlışsa ekranda yine
/// yanlış rakam çıkar - bu yüzden ikisi ayrı test.
///
/// <para>Testler KENDİ verisini açar ve <b>siler</b>; ortak veriye dokunmaz.</para>
/// </summary>
public class DagilimAkisTestleri : IClassFixture<VeritabaniOlgusu>, IAsyncLifetime
{
    private readonly VeritabaniOlgusu _olgu;
    public DagilimAkisTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private const string Etiket = "TEST_DAGILIM_AKIS";
    private readonly List<int> _belgeler = [];
    private readonly List<int> _sozlesmeler = [];
    private readonly List<int> _listeler = [];
    private readonly List<int> _taraflar = [];

    public Task InitializeAsync() => Task.CompletedTask;

    /// <summary>Açılan her kayıt geri alınır: sonraki koşu temiz veriyle başlar.</summary>
    public async Task DisposeAsync()
    {
        var veri = _olgu.Veri;
        if (veri is null) return;
        foreach (var b in _belgeler)
        {
            // Kasa islemi belgeye BAGLI (FK): once tahsilat ve emanet virmani.
            await veri.CalistirAsync(
                "delete from public.kasa_islem_dagitim where kasa_islem_id in " +
                "  (select id from public.kasa_islem where belge_id = @p0 " +
                "    or kaynak_tur = 473 and kaynak_id in " +
                "       (select id from public.kasa_islem where belge_id = @p0))", [b]);
            await veri.CalistirAsync(
                "delete from public.kasa_islem where kaynak_tur = 473 and kaynak_id in " +
                "  (select id from public.kasa_islem where belge_id = @p0)", [b]);
            await veri.CalistirAsync("delete from public.kasa_islem where belge_id = @p0", [b]);
            await veri.CalistirAsync(
                "delete from public.belge_satir_dagilim where belge_satir_id in " +
                "  (select id from public.belge_satir where belge_id = @p0)", [b]);
            await veri.CalistirAsync("delete from public.belge_satir where belge_id = @p0", [b]);
            await veri.CalistirAsync("delete from public.belge_basvuru where id = @p0", [b]);
            await veri.CalistirAsync("delete from public.belge where id = @p0", [b]);
        }
        foreach (var s in _sozlesmeler)
            await veri.CalistirAsync("delete from public.kurum_sozlesme where id = @p0", [s]);
        foreach (var l in _listeler)
        {
            await veri.CalistirAsync(
                "delete from public.fiyat_listesi_satir where liste_id = @p0", [l]);
            await veri.CalistirAsync("delete from public.fiyat_listesi where id = @p0", [l]);
        }
        foreach (var t in _taraflar)
        {
            await veri.CalistirAsync("delete from public.taraf_kurum where id = @p0", [t]);
            await veri.CalistirAsync("delete from public.taraf where id = @p0", [t]);
        }
    }

    // ------------------------------------------------------------- kurulum --

    /// <summary>
    /// KATILIM PAYI DOGURAN hizmet (602): katilim payi ayardaki SUT KODU
    /// listesine bagli (`basvuru.sgk_katilim_kodlari`, 592) - rastgele bir
    /// hizmette katilim HIC dogmaz ve "katilim ciro disi" testleri bos yere
    /// gecerdi. Kod eslesen yoksa ilk hizmete duselir.
    /// </summary>
    private async Task<int> HizmetAsync(VeriKaynagi veri)
        => await veri.TekDegerAsync<int>("""
            select coalesce(
              (select min(h.id) from public.hizmet h
                where btrim(h.kod) in (
                  select btrim(x) from public.referans r,
                       unnest(string_to_array(r.deger, ',')) x
                   where r.anahtar = 'basvuru.sgk_katilim_kodlari'
                     and btrim(x) <> '')),
              (select min(id) from public.hizmet))
            """);

    /// <summary>
    /// Test listesi. `katki` listenin `katki_tutar` alanidir - HASTA KATKISI
    /// (kova 4). "Ek katki" kurali (fiyat_listesi.ek_katki_tipi/deger) 539'da
    /// kaldirildi, 603'te olu fonksiyon da sokuldu: katki artik TEK kaynaktan,
    /// listenin `katki_tutar` alanindan gelir.
    /// </summary>
    private async Task<int> ListeAsync(VeriKaynagi veri, string ad, int hizmetId,
        decimal fiyat, decimal katki = 0)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, durum, yon, kdv_dahil, katki_tutar,
                                              baslangic, bitis)
            values (@p0, 1, 2, 0, @p1,
                    -- DONEM ZORUNLU (541): liste kaydi tarihsiz acilamaz.
                    --   Testin listesi BUGUNU kapsamali - tarife secimi
                    --   "bugun gecerli liste" diye suzuyor.
                    make_date(extract(year from current_date)::int, 1, 1),
                    make_date(extract(year from current_date)::int, 12, 31))
            returning id
            """, [$"{Etiket} {ad} {Guid.NewGuid():N}"[..40], katki]);
        _listeler.Add(id);
        await veri.CalistirAsync("""
            insert into public.fiyat_listesi_satir (liste_id, hizmet_id, fiyat, durum,
                                                    kdv_dahil, katki_tutar)
            values (@p0, @p1, @p2, 1, 0, @p3)
            """, [id, hizmetId, fiyat, katki]);
        return id;
    }

    private async Task<int> KurumAsync(VeriKaynagi veri, short tur, string ad)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, musteri, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} {ad}"]);
        _taraflar.Add(id);
        await veri.CalistirAsync(
            "insert into public.taraf_kurum (id, tur) values (@p0, @p1)",
            [id, tur]);
        return id;
    }

    private async Task<int> SozlesmeAsync(VeriKaynagi veri, int kurumId, short altKurum,
        int? tarifeListe, int? sutListe, int? sgkKurum, decimal karsilama = 0)
    {
        var id = await veri.TekDegerAsync<int>("""
            insert into public.kurum_sozlesme
                   (kurum_id, ad, alt_kurum, durum, fiyat_listesi_id,
                    sgk_fiyat_listesi_id, sgk_kurum_id, varsayilan_karsilama)
            values (@p0, @p1, @p2, 1, @p3, @p4, @p5, @p6) returning id
            """, [kurumId, Etiket, altKurum, tarifeListe, sutListe, sgkKurum, karsilama]);
        _sozlesmeler.Add(id);
        return id;
    }

    /// <summary>Başvuru + tek satır; satır tutarı TARİFE listesinden gelir.</summary>
    private async Task<(int BelgeId, int SatirId)> BasvuruAsync(VeriKaynagi veri,
        int kurumId, int sozlesmeId, short altKurum, short sgkKullan,
        int hizmetId, decimal tutar)
    {
        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, hasta, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} HASTA"]);
        _taraflar.Add(hastaId);

        var belgeId = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id)
            values (19, now(), @p0, 0, (select min(id) from public.sube)) returning id
            """, [hastaId]);
        _belgeler.Add(belgeId);

        await veri.CalistirAsync("""
            insert into public.belge_basvuru (id, odeyen_kurum_id, sozlesme_id,
                                              alt_kurum, sgk_kullan)
            values (@p0, @p1, @p2, @p3, @p4)
            """, [belgeId, kurumId, sozlesmeId, altKurum, sgkKullan]);

        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar,
                                            adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, 1, 2, @p1, 1, 1, @p2, @p2, 0,
                    (select min(id) from public.sube)) returning id
            """, [belgeId, hizmetId, tutar]);
        return (belgeId, satirId);
    }

    private sealed record Kova(short Rota, decimal Tutar, decimal Sgk, decimal Oss,
                               decimal HastaProvizyon, decimal HastaEkKatki,
                               decimal Katilim);

    private static Task<Kova?> OkuAsync(VeriKaynagi veri, int satirId)
        => veri.TekAsync("""
            select d.rota, s.tutar, d.sgk, d.oss, d.hasta_provizyon,
                   d.hasta_ek_katki, d.sgk_katilim_payi
              from public.belge_satir_dagilim d
              join public.belge_satir s on s.id = d.belge_satir_id
             where d.belge_satir_id = @p0
            """, [satirId],
            o => new Kova(o.GetInt16(0), o.GetDecimal(1), o.GetDecimal(2), o.GetDecimal(3),
                          o.GetDecimal(4), o.GetDecimal(5), o.GetDecimal(6)));

    // -------------------------------------------------------------- testler --

    [Fact]
    public async Task Ozel_hastada_tutarin_tamami_hastaya_yazilir()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 1, "OZEL");
        var soz = await SozlesmeAsync(veri, kurum, 0, tarife, null, null);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 0, 1, hizmet, 1000m);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);
        var k = await OkuAsync(veri, satirId);

        Assert.Equal((short)1, k!.Rota);
        Assert.Equal(1000m, k.HastaEkKatki);
        Assert.Equal(0m, k.Sgk + k.Oss + k.HastaProvizyon + k.Katilim);
    }

    [Fact]
    public async Task Oss_sozlesmesinde_karsilama_orani_kovalari_boler()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 2, "OSS");
        // %80 karşılama: provizyon gelmeden önce sözleşmenin varsayılanı işler.
        var soz = await SozlesmeAsync(veri, kurum, 201, tarife, null, null, 80m);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 201, 1, hizmet, 1000m);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);
        var k = await OkuAsync(veri, satirId);

        Assert.Equal((short)2, k!.Rota);
        Assert.Equal(800m, k.Oss);
        Assert.Equal(200m, k.HastaProvizyon);

        // Sigorta 850 onaylarsa hasta payı 150'ye iner.
        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, @p1)", [satirId, 850m]);
        var k2 = await OkuAsync(veri, satirId);
        Assert.Equal(850m, k2!.Oss);
        Assert.Equal(150m, k2.HastaProvizyon);
    }

    [Fact]
    public async Task Tss_de_sut_ve_ttb_listeleri_birlikte_calisir()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 2000m);
        // SUT listesi: 800 bedel, hasta katkısı 100 (listenin `katki_tutar`i).
        //   "Ek katkı %75" kuralı 539'da kaldırıldı - katkı tek kaynaktan gelir.
        var sut = await ListeAsync(veri, "SUT", hizmet, 800m, katki: 100m);
        var sgkKurum = await KurumAsync(veri, 3, "SGK");
        await SozlesmeAsync(veri, sgkKurum, 0, null, sut, sgkKurum);
        var kurum = await KurumAsync(veri, 2, "TSS SIRKET");
        var soz = await SozlesmeAsync(veri, kurum, 202, tarife, sut, sgkKurum);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 202, 1, hizmet, 2000m);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);
        var k = await OkuAsync(veri, satirId);

        // 800 SGK + 2000 sigorta + 100 hasta katkısı = 2900 · katılım 100 AYRI.
        Assert.Equal((short)3, k!.Rota);
        Assert.Equal(800m, k.Sgk);
        Assert.Equal(2000m, k.Oss);
        Assert.Equal(100m, k.HastaEkKatki);
        Assert.Equal(100m, k.Katilim);
        // SATIR TUTARI kovalardan doğar: rota 3'te toplam satıra yazılır.
        Assert.Equal(2900m, k.Tutar);
        Assert.Equal(k.Tutar, k.Sgk + k.Oss + k.HastaProvizyon + k.HastaEkKatki);
    }

    [Fact]
    public async Task Karma_da_sgk_kapatilinca_provizyon_ttb_uzerinden_yurur()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 4200m);
        var sut = await ListeAsync(veri, "SUT", hizmet, 500m, katki: 100m);
        var sgkKurum = await KurumAsync(veri, 3, "SGK2");
        await SozlesmeAsync(veri, sgkKurum, 0, null, sut, sgkKurum);
        var kurum = await KurumAsync(veri, 2, "KARMA SIRKET");
        var soz = await SozlesmeAsync(veri, kurum, 203, tarife, sut, sgkKurum);

        // 1) SGK katkısı AÇIK. TUTARI PROVİZYON BELİRLER (599, kullanıcı:
        //    "Karma'da hasta sadece 100 TL SGK katılım öder, onun dışında katkı
        //    ödemez"): satır 500 SGK + 2500 sigorta = 3000 yazılır, hastaya
        //    FARK ÇIKMAZ - tek ödediği katılım payıdır (ciro dışı).
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 203, 1, hizmet, 4200m);
        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, @p1)", [satirId, 2500m]);
        var acik = await OkuAsync(veri, satirId);
        Assert.Equal((short)4, acik!.Rota);
        Assert.Equal(500m, acik.Sgk);
        Assert.Equal(2500m, acik.Oss);
        Assert.Equal(0m, acik.HastaProvizyon);
        Assert.Equal(3000m, acik.Tutar);
        Assert.Equal(100m, acik.Katilim);

        // 2) Hasta SGK KULLANILMASIN dedi (kullanıcı): rota ÖSS'ye döner,
        //    sgk ve katılım 0 olur, provizyon TTB üzerinden yürür.
        await veri.CalistirAsync(
            "update public.belge_basvuru set sgk_kullan = 0 where id = " +
            "(select belge_id from public.belge_satir where id = @p0)", [satirId]);
        await veri.CalistirAsync(
            "select public.fn_belge_satir_dagilim_tazele(@p0, null, @p1)", [satirId, 2500m]);
        var kapali = await OkuAsync(veri, satirId);
        Assert.Equal((short)2, kapali!.Rota);
        Assert.Equal(0m, kapali.Sgk);
        Assert.Equal(0m, kapali.Katilim);
        Assert.Equal(2500m, kapali.Oss);
        // HASTA 500 = 3000 - 2500, 4200 - 2500 DEGIL (602): 1. bolumde Karma
        //   hesabi satirin tutarini provizyona gore 3000'e YAZDI (599/600
        //   geri yazma). Rota ÖSS'ye donunce tutar tarifeye (4200) geri
        //   DONMUYOR - rota 2 satirin kendi tutarini boluyor, tarife listesini
        //   yeniden okumuyor. Testin ölçtügü sey rota degisiminin kovalari
        //   dogru kurmasi; tutarin tarifeye donup donmemesi ayri bir karar.
        Assert.Equal(3000m, kapali.Tutar);
        Assert.Equal(500m, kapali.HastaProvizyon);
    }

    [Fact]
    public async Task Sgk_da_satir_sut_ve_ek_katkidan_dogar_katilim_ciro_disi()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        // SUT 800, hasta katkısı 100 (listenin `katki_tutar`i). "Ek katkı
        //   SABİT 500" kuralı 539'da kaldırıldı.
        var sut = await ListeAsync(veri, "SUT", hizmet, 800m, katki: 100m);
        var kurum = await KurumAsync(veri, 3, "SGK3");
        var soz = await SozlesmeAsync(veri, kurum, 0, null, sut, kurum);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 302, 1, hizmet, 800m);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);
        var k = await OkuAsync(veri, satirId);

        Assert.Equal((short)5, k!.Rota);
        Assert.Equal(900m, k.Tutar);            // 800 SUT + 100 hasta katkısı
        Assert.Equal(800m, k.Sgk);
        Assert.Equal(100m, k.HastaEkKatki);
        Assert.Equal(100m, k.Katilim);
        // KATILIM CİRO DIŞI: satır tutarına GİRMEZ.
        Assert.Equal(k.Tutar, k.Sgk + k.Oss + k.HastaProvizyon + k.HastaEkKatki);
    }

    [Fact]
    public async Task Sgk_basvurusunda_alt_kurum_zorunlu()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var sut = await ListeAsync(veri, "SUT", hizmet, 800m);
        var kurum = await KurumAsync(veri, 3, "SGK4");
        var soz = await SozlesmeAsync(veri, kurum, 0, null, sut, kurum);

        // Devredilen kurum (SSK/Bağ-Kur/…) seçilmeden başvuru kabul edilmez:
        //   hangi kuruma fatura kesileceği belirsiz kalırdı.
        var hata = await Assert.ThrowsAnyAsync<Exception>(async () =>
            await BasvuruAsync(veri, kurum, soz, 0, 1, hizmet, 800m));
        Assert.Contains("devredilen kurum", hata.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Iki_sozlesmeli_kurumda_secim_zorunlu_tek_sozlesme_otomatik()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 2, "IKI SOZLESME");
        var tek = await SozlesmeAsync(veri, kurum, 201, tarife, null, null, 80m);

        // TEK sözleşme: seçilmese de tetik kendisi atar.
        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, hasta, sube_id)
            values (@p0, 1, (select min(id) from public.sube)) returning id
            """, [$"{Etiket} HASTA2"]);
        _taraflar.Add(hastaId);
        var belgeId = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id)
            values (19, now(), @p0, 0, (select min(id) from public.sube)) returning id
            """, [hastaId]);
        _belgeler.Add(belgeId);
        await veri.CalistirAsync(
            "insert into public.belge_basvuru (id, odeyen_kurum_id) values (@p0, @p1)",
            [belgeId, kurum]);
        var atanan = await veri.TekDegerAsync<int>(
            "select sozlesme_id from public.belge_basvuru where id = @p0", [belgeId]);
        Assert.Equal(tek, atanan);

        // İKİNCİ sözleşme açılınca artık SEÇİM ZORUNLU: hangi poliçenin
        //   geçerli olduğunu sunucu tahmin edemez.
        //   (TSS sözleşmesi SGK carisi ister - SGK payı ona faturalanır.)
        var sgkKurum = await KurumAsync(veri, 3, "SGK5");
        await SozlesmeAsync(veri, kurum, 202, tarife, null, sgkKurum);
        var belge2 = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id)
            values (19, now(), @p0, 0, (select min(id) from public.sube)) returning id
            """, [hastaId]);
        _belgeler.Add(belge2);
        var hata = await Assert.ThrowsAnyAsync<Exception>(() =>
            veri.CalistirAsync(
                "insert into public.belge_basvuru (id, odeyen_kurum_id) values (@p0, @p1)",
                [belge2, kurum]));
        Assert.Contains("seçin", hata.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Kapatilmis_satira_tazeleme_dokunmaz()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 2, "KAPALI");
        var soz = await SozlesmeAsync(veri, kurum, 201, tarife, null, null, 80m);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 201, 1, hizmet, 1000m);
        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);

        // Satırın parası döndü (tahsil edildi): artık yeniden bölünemez -
        //   kesilmiş belge ile satır çelişirdi.
        await veri.CalistirAsync(
            "update public.belge_satir_dagilim set hasta_provizyon_tahsil = 200 " +
            " where belge_satir_id = @p0", [satirId]);
        // Sözleşme değişse bile dokunulmaz.
        await veri.CalistirAsync(
            "update public.kurum_sozlesme set varsayilan_karsilama = 50 where id = @p0",
            [soz]);
        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);

        var k = await OkuAsync(veri, satirId);
        Assert.Equal(800m, k!.Oss);          // %50'ye göre 500 DEĞİL
        Assert.Equal(200m, k.HastaProvizyon);
    }

    [Fact]
    public async Task Kova_toplami_satir_tutarini_tutmali()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 2, "DENGE");
        var soz = await SozlesmeAsync(veri, kurum, 201, tarife, null, null, 80m);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 201, 1, hizmet, 1000m);

        // Elle yazılan dağılım tutarı tutmuyorsa DB reddeder: sessizce kaybolan
        //   bir kuruş, icmalde açıklanamayan fark demektir.
        var hata = await Assert.ThrowsAnyAsync<Exception>(() =>
            veri.CalistirAsync("""
                insert into public.belge_satir_dagilim
                       (belge_satir_id, rota, oss, hasta_provizyon)
                values (@p0, 2, 600, 300)
                """, [satirId]));
        Assert.Contains("tutmuyor", hata.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Katilim_payi_tahsilati_SGK_carisine_emanet_yazilir()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var sut = await ListeAsync(veri, "SUT", hizmet, 800m, katki: 100m);
        var kurum = await KurumAsync(veri, 3, "SGK EMANET");
        var soz = await SozlesmeAsync(veri, kurum, 0, null, sut, kurum);
        var (belgeId, satirId) = await BasvuruAsync(veri, kurum, soz, 302, 1, hizmet, 800m);
        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);

        var hastaId = await veri.TekDegerAsync<int>(
            "select taraf_id from public.belge where id = @p0", [belgeId]);

        // Hastadan 100 TL katılım payı tahsil edildi (pay 5).
        var kasaId = await veri.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, durum, taraf_id, tutar,
                                           doviz_kuru, yerel_tutar, belge_id, sube_id, ekleyen)
            values (11, now(), 2, @p0, 100, 1, 100, @p1,
                    (select min(id) from public.sube), 0) returning id
            """, [hastaId, belgeId]);
        await veri.CalistirAsync("""
            insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay,
                                                   tutar, ekleyen)
            values (@p0, @p1, 5, 100, 0)
            """, [kasaId, satirId]);

        await veri.CalistirAsync("select public.fn_sgk_katilim_emanet_yaz(@p0)", [kasaId]);

        // CİRO DEĞİL EMANET: hasta carisinden SGK carisine tür-49 virman.
        var virman = await veri.TekAsync("""
            select v.tur, v.taraf_id, v.karsi_taraf_id, v.tutar
              from public.kasa_islem v
             where v.kaynak_tur = 473 and v.kaynak_id = @p0 and v.iptal_islem_id is null
            """, [kasaId],
            o => new { Tur = o.GetInt16(0), Hasta = o.GetInt32(1),
                       Sgk = o.GetInt32(2), Tutar = o.GetDecimal(3) });
        Assert.NotNull(virman);
        Assert.Equal((short)49, virman!.Tur);
        Assert.Equal(hastaId, virman.Hasta);
        Assert.Equal(kurum, virman.Sgk);
        Assert.Equal(100m, virman.Tutar);

        // Katılım tahsilatı SATIR SAYACINA da yazılır ama ciroya girmez.
        await veri.CalistirAsync("select public.fn_belge_satir_tahsil_tazele(@p0)", [satirId]);
        var katilimTahsil = await veri.TekDegerAsync<decimal>(
            "select sgk_katilim_tahsil from public.belge_satir_dagilim " +
            " where belge_satir_id = @p0", [satirId]);
        Assert.Equal(100m, katilimTahsil);

        // Temizlik ortak DisposeAsync'te: belgeye bağlı kasa kayıtları da
        //   oradan silinir (FK sırası tek yerde dursun).
    }

    [Fact]
    public async Task Elle_sabitlenen_dagilima_tazeleme_dokunmaz()
    {
        if (!_olgu.Baglandi(nameof(DagilimAkisTestleri))) return;
        var veri = _olgu.Gerekli();

        var hizmet = await HizmetAsync(veri);
        var tarife = await ListeAsync(veri, "TTB", hizmet, 1000m);
        var kurum = await KurumAsync(veri, 2, "ELLE");
        var soz = await SozlesmeAsync(veri, kurum, 201, tarife, null, null, 80m);
        var (_, satirId) = await BasvuruAsync(veri, kurum, soz, 201, 1, hizmet, 1000m);

        // Kullanıcı kovaları elle yazdı (elle = 1).
        await veri.CalistirAsync("""
            insert into public.belge_satir_dagilim
                   (belge_satir_id, rota, sgk, oss, hasta_provizyon, hasta_ek_katki, elle)
            values (@p0, 2, 0, 600, 400, 0, 1)
            on conflict (belge_satir_id) do update
               set oss = 600, hasta_provizyon = 400, elle = 1
            """, [satirId]);

        await veri.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", [satirId]);
        var k = await OkuAsync(veri, satirId);
        Assert.Equal(600m, k!.Oss);      // sözleşmenin %80'i (800) DEĞİL
        Assert.Equal(400m, k.HastaProvizyon);
    }
}
