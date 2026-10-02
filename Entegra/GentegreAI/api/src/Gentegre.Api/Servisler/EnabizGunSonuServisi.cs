using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GÜN SONU ÖZETİ VE 407 PAKETİ (884 — KTS maddeleri H13 / D24).
///
/// <para><b>Gün sonu ne işe yarar:</b> kurum o gün ürettiği işin SAYILARINI
/// gönderir, Bakanlık bunu kendisine ULAŞAN paketlerle karşılaştırır. İki
/// sayı tutmuyorsa (oran %95-103 dışında) gönderim eksik demektir -
/// denetimde sorulan tam olarak bu orandır.</para>
///
/// <para><b>Hesap ve paket ayrı adımlar.</b> Önce sayılar yazılır
/// (<c>enabiz_gun_sonu</c> + satırları), sonra paket üretilir. Sayılar
/// kurumun kendi kaydıdır ve paket gönderilemese bile durur; gün sonu
/// ekranı onları gösterir.</para>
///
/// <para><b>Aynı gün yeniden hesaplanabilir</b> (geç girilen kayıtlar için):
/// satırlar güncellenir, ikinci bir gün kaydı açılmaz. İçerik değiştiyse
/// paket üretici de yeni sürüm açar - "aynı içerik → aynı paket" kuralı
/// gereksiz paket doğurmaz.</para>
/// </summary>
public sealed class EnabizGunSonuServisi
{
    private readonly VeriKaynagi _veri;
    private readonly EnabizPaketUretici _uretici;
    private readonly ILogger<EnabizGunSonuServisi> _gunluk;

    public EnabizGunSonuServisi(VeriKaynagi veri, EnabizPaketUretici uretici,
                                ILogger<EnabizGunSonuServisi> gunluk)
    {
        _veri = veri;
        _uretici = uretici;
        _gunluk = gunluk;
    }

    public const string PaketKodu = "GUN_SONU";

    public sealed record Sonuc(long GunSonuId, DateOnly Tarih, int OlcutSayisi, int ToplamSayi,
                               string? PaketNo, string Aciklama);

    /// <summary>
    /// Bir günün özetini hesaplar ve 407 paketini üretir.
    ///
    /// <para><paramref name="subeId"/> 0 ise kurum geneli. Şube bazlı
    /// hesaplama, çok şubeli kurumda her tesisin kendi gün sonunu
    /// göndermesi içindir - Bakanlık tarafında sayılar tesis koduyla
    /// eşleşir.</para>
    /// </summary>
    public async Task<Sonuc> HesaplaAsync(DateOnly tarih, int subeId, int kullaniciId,
                                          bool paketUret, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var gunId = await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_gun_sonu (sube_id, tarih, durum, hesap_zamani, ekleyen)
            values (@p0, @p1, 0, now(), @p2)
            on conflict (sube_id, tarih)
              do update set hesap_zamani = now(), degistirme_tarihi = now()
            returning id
            """, islem, [subeId, tarih, kullaniciId], iptal);

        // SAYILAR TEK SORGUDA: ölçüt tanımı + sayım motoru birlikte.
        //   Ölçüt kapalıysa satırı da SİLİNİR - kurum bir ölçütü kapattığında
        //   eski satır kalıp pakete girmeye devam ederdi.
        await baglanti.CalistirAsync("""
            insert into public.enabiz_gun_sonu_satir (gun_sonu_id, skrs_kod, sayi)
            select @p0, s.skrs_kod, s.sayi
              from public.fn_enabiz_gun_sonu_sayilar(@p1, @p2) s
            on conflict (gun_sonu_id, skrs_kod) do update set sayi = excluded.sayi
            """, islem, [gunId, tarih, subeId], iptal);
        await baglanti.CalistirAsync("""
            delete from public.enabiz_gun_sonu_satir
             where gun_sonu_id = @p0
               and skrs_kod not in (select skrs_kod from public.enabiz_gun_sonu_olcut
                                     where aktif = 1)
            """, islem, [gunId], iptal);

        // Agregat (count/sum) HER ZAMAN tek satir doner; bos donmesi imkansiz
        //   durumdur - sessiz null yerine acik hata.
        var ozet = await baglanti.TekAsync("""
            select count(*)::int, coalesce(sum(sayi), 0)::int
              from public.enabiz_gun_sonu_satir where gun_sonu_id = @p0
            """, islem, [gunId], o => new { Olcut = o.GetInt32(0), Toplam = o.GetInt32(1) }, iptal)
            ?? throw new InvalidOperationException("Gun sonu ozeti okunamadi.");

        await islem.CommitAsync(iptal);

        if (!paketUret)
            return new Sonuc(gunId, tarih, ozet.Olcut, ozet.Toplam, null,
                $"{tarih:dd.MM.yyyy}: {ozet.Olcut} ölçüt hesaplandı (paket üretilmedi).");

        try
        {
            var s = await _uretici.UretAsync(PaketKodu, (int)gunId, kullaniciId, iptal);
            if (s is null)
                return new Sonuc(gunId, tarih, ozet.Olcut, ozet.Toplam, null,
                    $"{tarih:dd.MM.yyyy}: {ozet.Olcut} ölçüt hesaplandı, "
                    + "407 paketi üretilmedi (paket türü kapalı olabilir).");

            await _veri.CalistirAsync("""
                update public.enabiz_gun_sonu
                   set durum = 1,
                       paket_id = (select p.id from public.enabiz_paket p where p.paket_no = @p1),
                       degistirme_tarihi = now()
                 where id = @p0
                """, [gunId, s.PaketNo], iptal);

            return new Sonuc(gunId, tarih, ozet.Olcut, ozet.Toplam, s.PaketNo,
                $"{tarih:dd.MM.yyyy}: {ozet.Olcut} ölçüt, 407 paketi {s.PaketNo}"
                + (s.Eksikler.Count == 0 ? "." : $" (eksik: {string.Join(", ", s.Eksikler)})."));
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "407 gun sonu paketi uretilemedi ({Tarih})", tarih);
            return new Sonuc(gunId, tarih, ozet.Olcut, ozet.Toplam, null,
                $"{tarih:dd.MM.yyyy}: sayılar hesaplandı, paket üretilemedi: {h.Message}");
        }
    }

    /// <summary>
    /// Zamanlı işin çağırdığı hâl: DÜNÜN gün sonu. Gün bitmeden hesaplamak,
    /// akşam açılan başvuruları saymamak demekti.
    /// </summary>
    public async Task<string> DunuHesaplaAsync(CancellationToken iptal)
    {
        var dun = DateOnly.FromDateTime(DateTime.Now.AddDays(-1));
        // ŞUBE BAZLI: çok şubeli kurumda her tesis kendi gün sonunu gönderir.
        //   Şube yoksa (tek tesis) kurum geneli tek satır.
        var subeler = await _veri.ListeAsync(
            "select id from public.sube where coalesce(aktif, 1) = 1 order by id",
            [], o => o.GetInt32(0), iptal);
        if (subeler.Count == 0) subeler = [0];

        var sonuclar = new List<string>();
        foreach (var sube in subeler)
        {
            var s = await HesaplaAsync(dun, sube, 0, paketUret: true, iptal);
            sonuclar.Add(s.Aciklama);
        }
        return string.Join(" | ", sonuclar);
    }

    // =============================================== ay sonu (885) ==

    /// <summary>408 Ay Sonu paket türünün kodu (885).</summary>
    public const string AyPaketKodu = "AY_SONU";

    public sealed record AySonucu(long AySonuId, int Yil, int Ay, int KlinikSayisi,
                                  int SatirSayisi, string? PaketNo, string Aciklama);

    /// <summary>
    /// Bir ayın KLİNİK KIRILIMLI özetini hesaplar ve 408 paketini üretir.
    ///
    /// <para>407 tesis toplamını gönderir, 408 aynı ölçütleri branş branş
    /// ister. Ölçüt listesi ORTAK (<c>enabiz_gun_sonu_olcut</c>): kurum bir
    /// ölçütü kapattığında hem günlük hem aylık özetten düşsün.</para>
    ///
    /// <para><b>Sıfır satır yazılmaz:</b> "o branş o ay hiç iş yapmadı"
    /// satırını göndermek, 100 bölümlü bir hastanede paketi binlerce
    /// sıfırla şişirirdi. Günlükte sıfır anlamlıydı (tesis o gün çalıştı
    /// ama yatış olmadı), aylık branş kırılımında değil.</para>
    /// </summary>
    public async Task<AySonucu> AyHesaplaAsync(int yil, int ay, int subeId, int kullaniciId,
                                               bool paketUret, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var ayId = await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_ay_sonu (sube_id, yil, ay, durum, hesap_zamani, ekleyen)
            values (@p0, @p1, @p2, 0, now(), @p3)
            on conflict (sube_id, yil, ay)
              do update set hesap_zamani = now(), degistirme_tarihi = now()
            returning id
            """, islem, [subeId, (short)yil, (short)ay, kullaniciId], iptal);

        // ÖNCE TEMİZLE: bir branş o ay iş yapmayı bıraktıysa eski satırı
        //   kalıp pakete girmeye devam ederdi.
        await baglanti.CalistirAsync(
            "delete from public.enabiz_ay_sonu_satir where ay_sonu_id = @p0", islem, [ayId], iptal);
        await baglanti.CalistirAsync("""
            insert into public.enabiz_ay_sonu_satir (ay_sonu_id, klinik_kodu, skrs_kod, sayi)
            select @p0, s.klinik_kodu, s.skrs_kod, s.sayi
              from public.fn_enabiz_ay_sonu_sayilar(@p1, @p2, @p3) s
            """, islem, [ayId, yil, ay, subeId], iptal);

        var ozet = await baglanti.TekAsync("""
            select count(distinct klinik_kodu)::int, count(*)::int
              from public.enabiz_ay_sonu_satir where ay_sonu_id = @p0
            """, islem, [ayId], o => new { Klinik = o.GetInt32(0), Satir = o.GetInt32(1) }, iptal)
            ?? throw new InvalidOperationException("Ay sonu ozeti okunamadi.");

        await islem.CommitAsync(iptal);

        if (!paketUret)
            return new AySonucu(ayId, yil, ay, ozet.Klinik, ozet.Satir, null,
                $"{ay:00}.{yil}: {ozet.Klinik} klinik / {ozet.Satir} satır (paket üretilmedi).");

        try
        {
            var s = await _uretici.UretAsync(AyPaketKodu, (int)ayId, kullaniciId, iptal);
            if (s is null)
                return new AySonucu(ayId, yil, ay, ozet.Klinik, ozet.Satir, null,
                    $"{ay:00}.{yil}: {ozet.Satir} satır hesaplandı, 408 paketi üretilmedi.");

            await _veri.CalistirAsync("""
                update public.enabiz_ay_sonu
                   set durum = 1,
                       paket_id = (select p.id from public.enabiz_paket p where p.paket_no = @p1),
                       degistirme_tarihi = now()
                 where id = @p0
                """, [ayId, s.PaketNo], iptal);

            return new AySonucu(ayId, yil, ay, ozet.Klinik, ozet.Satir, s.PaketNo,
                $"{ay:00}.{yil}: {ozet.Klinik} klinik, 408 paketi {s.PaketNo}"
                + (s.Eksikler.Count == 0 ? "." : $" (eksik: {string.Join(", ", s.Eksikler)})."));
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "408 ay sonu paketi uretilemedi ({Yil}-{Ay})", yil, ay);
            return new AySonucu(ayId, yil, ay, ozet.Klinik, ozet.Satir, null,
                $"{ay:00}.{yil}: sayılar hesaplandı, paket üretilemedi: {h.Message}");
        }
    }

    /// <summary>Zamanlı işin çağırdığı hâl: ÖNCEKİ ay (ayın 2'sinde çalışır).</summary>
    public async Task<string> OncekiAyiHesaplaAsync(CancellationToken iptal)
    {
        var d = DateTime.Now.AddMonths(-1);
        var subeler = await _veri.ListeAsync(
            "select id from public.sube where coalesce(aktif, 1) = 1 order by id",
            [], o => o.GetInt32(0), iptal);
        if (subeler.Count == 0) subeler = [0];

        var sonuclar = new List<string>();
        foreach (var sube in subeler)
            sonuclar.Add((await AyHesaplaAsync(d.Year, d.Month, sube, 0, true, iptal)).Aciklama);
        return string.Join(" | ", sonuclar);
    }
}
