using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// MİKROBİYOLOJİ — KÜLTÜR İŞ AKIŞI (436).
///
/// <para>Ekim → planlı okumalar (24/48/72 s) → üreme/izolat →
/// identifikasyon → izolat başına antibiyogram → uzman onayı → rapor.</para>
///
/// <para><b>Ara rapor beklemez.</b> Gram boyama sonucu kültür bitmeden
/// hekime gider; sepsiste tedavi ilk saatte başlar. Ön rapor kaydı ayrı
/// alandır ve nihai raporda "ön rapor 09:30" olarak görünür.</para>
///
/// <para><b>Onayda özet lab_sonuc'a düşer.</b> Kültürün kendi tabloları
/// ayrıntıyı taşır, ama istem durumu / muayene sekmesi / e-Nabız tek sonuç
/// hattından okur - mikrobiyolojiyi ayrıca tanımak zorunda kalmazlar.</para>
/// </summary>
public sealed class KulturServisi(VeriKaynagi veri, LabServisi lab)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly LabServisi _lab = lab;

    // Durumlar (db/436): 0 iptal · 1 ekim · 2 inkübasyon · 3 üreme ·
    //   4 identifikasyon · 5 antibiyogram · 6 rapor bekliyor · 7 onaylı.
    private const short Ekim = 1, Inkubasyon = 2, Ureme = 3,
                        Antibiyogram = 5, RaporBekliyor = 6, Onayli = 7;

    public sealed record EkimIstegi(int[]? BesiyeriIdler, short? Sicaklik,
                                    short? Atmosfer, string? DirektBaki,
                                    string? GramSonuc, string? NumuneKalite);

    public sealed record OkumaIstegi(short? Saat, bool UremeVar, string? Bulgu,
                                     string? SonrakiAdim);

    public sealed record IzolatIstegi(int OrganizmaId, decimal? KoloniSayisi,
                                      string? KoloniBirim, short? IdYontem,
                                      decimal? IdGuven, short? Esbl,
                                      short? Karbapenemaz, short? Mrsa, short? Vre,
                                      short? Ampc, string? DirencNotu,
                                      bool? Anlamli);

    public sealed record AntibiyogramSatiri(int AntibiyotikId, decimal? Mic,
                                            string? MicIsaret, short? ZonMm,
                                            string Yorum, short? Kaynak,
                                            string? Aciklama);

    public sealed record AntibiyogramIstegi(AntibiyogramSatiri[]? Satirlar,
                                            string? Standart, string? StandartSurum);

    // =================================================================== ekim

    /// <summary>
    /// Kültürü açar: besiyeri seti tetkikten kopyalanır, okuma planı kurulur.
    ///
    /// <b>Besiyeri KOPYALANIR</b>: katalog sonradan değişse geçmiş kültürün
    /// hangi besiyerine ekildiği değişmemeli.
    /// </summary>
    public async Task<int> EkimAsync(int istemSatirId, EkimIstegi istek,
                                     IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var s = await baglanti.TekAsync("""
            select s.id, s.istem_id, s.tetkik_id, s.numune_id, i.taraf_id, i.sube_id,
                   t.tur, coalesce(n.durum, 0) as numune_durum
              from public.lab_istem_satir s
              join public.lab_istem i on i.id = s.istem_id
              join public.lab_tetkik t on t.id = s.tetkik_id
              left join public.lab_numune n on n.id = s.numune_id
             where s.id = @p0
            """, islem, [istemSatirId],
            o => new { Id = o.GetInt32(0), IstemId = o.GetInt32(1),
                       TetkikId = o.GetInt32(2),
                       NumuneId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                       HastaId = o.GetInt32(4), SubeId = o.GetInt32(5),
                       Tur = o.GetInt16(6), NumuneDurum = o.GetInt16(7) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem satırı bulunamadı.");

        if (s.Tur != 4)
            throw GentegreHatasi.IsKurali(
                "Bu tetkik kültür değil (tetkik kartında sonuç türü 'Kültür' olmalı).");

        // KABUL EDİLMEMİŞ NUMUNE EKİLMEZ: reddedilecek tüpten üreyen etken,
        //   hastaya ait olmayabilir (kontaminasyon) - rapor geri çekilir.
        if (s.NumuneDurum != 3)
            throw GentegreHatasi.IsKurali(
                "Numune laboratuvara kabul edilmeden ekim yapılamaz.");

        if (await baglanti.TekDegerAsync<int>(
                "select count(*) from public.lab_kultur where istem_satir_id = @p0",
                islem, [istemSatirId], iptal) > 0)
            throw GentegreHatasi.IsKurali("Bu tetkik için ekim zaten yapılmış.");

        var besiyeriler = istek.BesiyeriIdler is { Length: > 0 }
            ? await baglanti.ListeAsync("""
                select id, ilk_okuma_saat, sicaklik, atmosfer from public.lab_besiyeri
                 where id = any(@p0) and durum = 0
                """, islem, [istek.BesiyeriIdler],
                o => new { Id = o.GetInt32(0), Ilk = o.GetInt16(1),
                           Sicaklik = o.GetInt16(2), Atmosfer = o.GetInt16(3) }, iptal)
            // Seçim gelmediyse tetkiğin varsayılan seti.
            : await baglanti.ListeAsync("""
                select b.id, b.ilk_okuma_saat, b.sicaklik, b.atmosfer
                  from public.lab_tetkik_besiyeri tb
                  join public.lab_besiyeri b on b.id = tb.besiyeri_id
                 where tb.tetkik_id = @p0 and b.durum = 0
                 order by tb.sira, tb.id
                """, islem, [s.TetkikId],
                o => new { Id = o.GetInt32(0), Ilk = o.GetInt16(1),
                           Sicaklik = o.GetInt16(2), Atmosfer = o.GetInt16(3) }, iptal);

        if (besiyeriler.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Besiyeri seçilmedi ve tetkiğin varsayılan besiyeri seti tanımlı değil.");

        // Okuma planı EN ERKEN besiyerine göre: 24 saatlik plakayı 48. saatte
        //   okumak, negatif raporu güvenilmez yapar.
        var ilkOkuma = besiyeriler.Min(x => x.Ilk);

        var kulturId = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_kultur
                   (istem_satir_id, istem_id, numune_id, tetkik_id, hasta_id,
                    ekim_zamani, ekim_eden_id, sicaklik, atmosfer, sonraki_okuma,
                    direkt_baki, gram_sonuc, numune_kalite, durum, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, now(), @p5, @p6, @p7,
                    now() + make_interval(hours => @p8), @p9, @p10, @p11, @p12,
                    @p13, @p5)
            returning id
            """, islem,
            [s.Id, s.IstemId, s.NumuneId, s.TetkikId, s.HastaId, baglam.KullaniciId,
             istek.Sicaklik ?? besiyeriler[0].Sicaklik,
             istek.Atmosfer ?? besiyeriler[0].Atmosfer, (int)ilkOkuma,
             istek.DirektBaki ?? "", istek.GramSonuc ?? "", istek.NumuneKalite ?? "",
             Inkubasyon, s.SubeId], iptal);

        var sira = 0;
        foreach (var b in besiyeriler)
            await baglanti.CalistirAsync("""
                insert into public.lab_kultur_besiyeri (kultur_id, besiyeri_id, sira, ekleyen)
                values (@p0, @p1, @p2, @p3)
                """, islem, [kulturId, b.Id, (short)(++sira * 10), baglam.KullaniciId],
                iptal);

        // Satır "çalışılıyor": listede hâlâ "istendi" görünmesi, kültürün
        //   ekilip ekilmediğini belirsiz bırakırdı.
        await baglanti.CalistirAsync("""
            update public.lab_istem_satir set durum = 2 where id = @p0 and durum in (1, 6)
            """, islem, [s.Id], iptal);

        await islem.CommitAsync(iptal);
        return kulturId;
    }

    // ================================================================= okuma

    /// <summary>
    /// Planlı okuma kaydı. Üreme yoksa bir sonraki okuma planlanır; son
    /// okumada da üreme yoksa kültür "rapor bekliyor"a geçer.
    /// </summary>
    public async Task<string> OkumaAsync(int kulturId, OkumaIstegi istek,
                                         IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var k = await baglanti.TekAsync("""
            select k.id, k.durum, k.ekim_zamani,
                   (select max(b.son_okuma_saat) from public.lab_kultur_besiyeri kb
                      join public.lab_besiyeri b on b.id = kb.besiyeri_id
                     where kb.kultur_id = k.id) as son_saat
              from public.lab_kultur k where k.id = @p0 for update
            """, islem, [kulturId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1),
                       Ekim = o.GetDateTime(2),
                       SonSaat = o.IsDBNull(3) ? (short)48 : o.GetInt16(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Kültür bulunamadı.");

        if (k.Durum is Onayli or 0)
            throw GentegreHatasi.IsKurali("Onaylı ya da iptal edilmiş kültüre okuma eklenemez.");

        var saat = istek.Saat ?? (short)Math.Max(24,
            Math.Round((DateTime.Now - k.Ekim).TotalHours));

        await baglanti.CalistirAsync("""
            insert into public.lab_kultur_okuma
                   (kultur_id, saat, okuma_zamani, okuyan_id, ureme_var, bulgu,
                    sonraki_adim, ekleyen)
            values (@p0, @p1, now(), @p2, @p3, @p4, @p5, @p2)
            """, islem,
            [kulturId, saat, baglam.KullaniciId, (short)(istek.UremeVar ? 1 : 0),
             istek.Bulgu ?? "", istek.SonrakiAdim ?? ""], iptal);

        string mesaj;
        if (istek.UremeVar)
        {
            await baglanti.CalistirAsync("""
                update public.lab_kultur
                   set durum = @p1, sonraki_okuma = null,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [kulturId, Ureme, baglam.KullaniciId], iptal);
            mesaj = "Üreme kaydedildi - identifikasyon bekliyor.";
        }
        else if (saat >= k.SonSaat)
        {
            // SON OKUMADA DA ÜREME YOK: "üreme yok" bir sonuçtur, kültür
            //   raporlanmadan kapanmamalı.
            await baglanti.CalistirAsync("""
                update public.lab_kultur
                   set durum = @p1, sonraki_okuma = null,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [kulturId, RaporBekliyor, baglam.KullaniciId], iptal);
            mesaj = $"{saat}. saatte üreme yok - rapor bekliyor.";
        }
        else
        {
            var sonraki = (short)Math.Min(k.SonSaat, saat * 2);
            await baglanti.CalistirAsync("""
                update public.lab_kultur
                   set sonraki_okuma = ekim_zamani + make_interval(hours => @p1),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [kulturId, (int)sonraki, baglam.KullaniciId], iptal);
            mesaj = $"{saat}. saat okundu - {sonraki}. saatte tekrar okunacak.";
        }

        await islem.CommitAsync(iptal);
        return mesaj;
    }

    /// <summary>
    /// Ön rapor: Gram / erken üreme bulgusu hekime kültür bitmeden gider.
    /// Nihai raporda "ön rapor 09:30" satırı olarak durur.
    /// </summary>
    public async Task<string> OnRaporAsync(int kulturId, string metin, bool kritik,
                                           IstekBaglami baglam, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(metin))
            throw GentegreHatasi.Dogrulama("Ön rapor metni boş olamaz.",
                [new("metin", "Hekime gidecek cümleyi yazın.")]);

        await _veri.CalistirAsync("""
            update public.lab_kultur
               set on_rapor = @p1, on_rapor_zamani = now(),
                   kritik = greatest(kritik, @p2),
                   kritik_zamani = case when @p2 = 1 then coalesce(kritik_zamani, now())
                                        else kritik_zamani end,
                   degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, [kulturId, metin, (short)(kritik ? 1 : 0), baglam.KullaniciId], iptal);

        return kritik
            ? "Ön rapor kaydedildi ve KRİTİK olarak işaretlendi - hekime bildirin."
            : "Ön rapor kaydedildi.";
    }

    // ================================================================ izolat

    /// <summary>
    /// Üreyen etkeni (izolat) kaydeder. "Üreme yok" ve "normal flora" da
    /// birer izolat satırıdır: kültür sonuçsuz kapatılamaz.
    /// </summary>
    public async Task<int> IzolatAsync(int kulturId, IzolatIstegi istek,
                                       IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var durum = await baglanti.TekDegerAsync<short>(
            "select durum from public.lab_kultur where id = @p0", islem, [kulturId], iptal);
        if (durum == 0) throw GentegreHatasi.Bulunamadi("Kültür bulunamadı.");
        if (durum == Onayli)
            throw GentegreHatasi.IsKurali("Onaylı kültüre izolat eklenemez.");

        var izolatNo = (short)(await baglanti.TekDegerAsync<int>(
            "select coalesce(max(izolat_no), 0) from public.lab_kultur_ureme where kultur_id = @p0",
            islem, [kulturId], iptal) + 1);

        var id = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_kultur_ureme
                   (kultur_id, izolat_no, organizma_id, koloni_sayisi, koloni_birim,
                    anlamli, id_yontem, id_guven, esbl, karbapenemaz, mrsa, vre, ampc,
                    direnc_notu, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11,
                    @p12, @p13, @p14)
            returning id
            """, islem,
            [kulturId, izolatNo, istek.OrganizmaId, istek.KoloniSayisi,
             string.IsNullOrWhiteSpace(istek.KoloniBirim) ? "CFU/mL" : istek.KoloniBirim,
             (short)((istek.Anlamli ?? true) ? 1 : 0), istek.IdYontem ?? 1,
             istek.IdGuven, istek.Esbl ?? 0, istek.Karbapenemaz ?? 0, istek.Mrsa ?? 0,
             istek.Vre ?? 0, istek.Ampc ?? 0, istek.DirencNotu ?? "",
             baglam.KullaniciId], iptal);

        // Bildirimi zorunlu etken ya da dirençli mikroorganizma: enfeksiyon
        //   kontrol komitesi işaretlenir. Hastanın tedavisi ile hastanenin
        //   salgın yönetimi AYRI olaylar - biri diğerinin yerine geçmez.
        await baglanti.CalistirAsync("""
            update public.lab_kultur k
               set durum = case when k.durum < @p1 then @p1 else k.durum end,
                   ekk_bildirim = case
                       when o.bildirimi_zorunlu = 1 or u.mrsa = 2 or u.vre = 2
                            or u.karbapenemaz = 2 or u.esbl = 2 then 1
                       else k.ekk_bildirim end,
                   ekk_zamani = case
                       when (o.bildirimi_zorunlu = 1 or u.mrsa = 2 or u.vre = 2
                             or u.karbapenemaz = 2 or u.esbl = 2)
                            and k.ekk_zamani is null then now()
                       else k.ekk_zamani end,
                   degistiren = @p3, degistirme_tarihi = now()
              from public.lab_kultur_ureme u
              join public.lab_organizma o on o.id = u.organizma_id
             where u.id = @p2 and k.id = @p0
            """, islem, [kulturId, Ureme, id, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);
        return id;
    }

    // ========================================================== antibiyogram

    /// <summary>
    /// İzolatın antibiyogramını yazar ve kademeli bildirimi hesaplar.
    ///
    /// <b>Yorum standardı ve sürümü satırda saklanır</b> (EUCAST 2026 v16):
    /// kesim noktaları yıllık değişir; sürüm yazılmazsa eski rapor bugünün
    /// kuralıyla okunur.
    /// </summary>
    public async Task<(int Satir, int Bildirilen)> AntibiyogramAsync(int uremeId,
        AntibiyogramIstegi istek, IstekBaglami baglam, CancellationToken iptal)
    {
        if (istek.Satirlar is not { Length: > 0 })
            throw GentegreHatasi.Dogrulama("Antibiyogram satırı yok.",
                [new("satirlar", "En az bir antibiyotik sonucu girin.")]);

        foreach (var x in istek.Satirlar)
            if (x.Yorum is not ("S" or "I" or "R"))
                throw GentegreHatasi.Dogrulama("Geçersiz duyarlılık yorumu.",
                    [new("yorum", $"'{x.Yorum}' geçersiz - S, I ya da R olmalı.")]);

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var kulturId = await baglanti.TekDegerAsync<int>(
            "select kultur_id from public.lab_kultur_ureme where id = @p0",
            islem, [uremeId], iptal);
        if (kulturId == 0) throw GentegreHatasi.Bulunamadi("İzolat bulunamadı.");

        foreach (var x in istek.Satirlar)
            await baglanti.CalistirAsync("""
                insert into public.lab_antibiyogram
                       (ureme_id, antibiyotik_id, mic, mic_isaret, zon_mm, yorum,
                        kaynak, standart, standart_surum, cihaz_yorum, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8,
                        case when @p6 = 4 then '' else @p5 end, @p9, @p10)
                on conflict (ureme_id, antibiyotik_id) do update
                   set mic = excluded.mic, mic_isaret = excluded.mic_isaret,
                       zon_mm = excluded.zon_mm, yorum = excluded.yorum,
                       kaynak = excluded.kaynak, standart = excluded.standart,
                       standart_surum = excluded.standart_surum,
                       aciklama = excluded.aciklama,
                       degistiren = excluded.ekleyen, degistirme_tarihi = now()
                """, islem,
                [uremeId, x.AntibiyotikId, x.Mic, x.MicIsaret ?? "", x.ZonMm, x.Yorum,
                 x.Kaynak ?? 1, string.IsNullOrWhiteSpace(istek.Standart) ? "EUCAST"
                                                                          : istek.Standart,
                 istek.StandartSurum ?? "", x.Aciklama ?? "", baglam.KullaniciId], iptal);

        // Kademeli bildirim SUNUCUDA: ekranda hesaplanırsa rapor ile ekran
        //   ayrışır ve hangisinin doğru olduğu belirsiz kalır.
        await baglanti.CalistirAsync(
            "select public.fn_lab_antibiyogram_bildirim(@p0)", islem, [uremeId], iptal);

        var bildirilen = await baglanti.TekDegerAsync<int>(
            "select count(*) from public.lab_antibiyogram where ureme_id = @p0 and bildir = 1",
            islem, [uremeId], iptal);

        await baglanti.CalistirAsync("""
            update public.lab_kultur
               set durum = case when durum < @p1 then @p1 else durum end,
                   degistiren = @p2, degistirme_tarihi = now()
             where id = @p0
            """, islem, [kulturId, Antibiyogram, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);
        return (istek.Satirlar.Length, bildirilen);
    }

    /// <summary>
    /// Uzman S/I/R'yi değiştirir. GEREKÇE ZORUNLU: cihaz sonucunu sessizce
    /// ezmek, sonradan "bu neden R yazıyordu" sorusunu cevapsız bırakır.
    /// Uzman kararı kademeli bildirimde de korunur.
    /// </summary>
    public async Task<string> YorumDegistirAsync(int antibiyogramId, string yorum,
        bool bildir, string neden, IstekBaglami baglam, CancellationToken iptal)
    {
        if (yorum is not ("S" or "I" or "R"))
            throw GentegreHatasi.Dogrulama("Geçersiz duyarlılık yorumu.",
                [new("yorum", "S, I ya da R olmalı.")]);
        if (string.IsNullOrWhiteSpace(neden))
            throw GentegreHatasi.Dogrulama("Değiştirme nedeni zorunlu.",
                [new("neden", "Cihaz sonucunun neden değiştiğini yazın.")]);

        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_antibiyogram
               set yorum = @p1, bildir = @p2, kaynak = 4,
                   degistiren_id = @p3, degistirme_neden = @p4,
                   degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, [antibiyogramId, yorum, (short)(bildir ? 1 : 0), baglam.KullaniciId,
                  neden], iptal);

        if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Antibiyogram satırı yok.");
        return $"Yorum uzman kararıyla '{yorum}' yapıldı (gerekçe kayda geçti).";
    }

    // ================================================================== onay

    /// <summary>
    /// Uzman onayı: özet lab_sonuc'a yazılır, istem satırı kapanır.
    ///
    /// <b>İzolatsız kültür onaylanamaz</b>: "üreme yok" bile bir izolat
    /// satırıdır. Boş onay, hekime hiçbir şey söylemeyen rapor üretirdi.
    /// </summary>
    public async Task<string> OnaylaAsync(int kulturId, string? uzmanYorum,
                                          IstekBaglami baglam, CancellationToken iptal)
    {
        var k = await _veri.TekAsync("""
            select k.id, k.durum, k.istem_satir_id, k.sonuc_id,
                   (select count(*) from public.lab_kultur_ureme u
                     where u.kultur_id = k.id and u.durum = 1) as izolat
              from public.lab_kultur k where k.id = @p0
            """, [kulturId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1),
                       SatirId = o.GetInt32(2),
                       SonucId = o.IsDBNull(3) ? (long?)null : o.GetInt64(3),
                       Izolat = o.GetInt64(4) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Kültür bulunamadı.");

        if (k.Durum == Onayli) throw GentegreHatasi.IsKurali("Kültür zaten onaylı.");
        if (k.Durum == 0) throw GentegreHatasi.IsKurali("İptal edilmiş kültür onaylanamaz.");
        if (k.Izolat == 0)
            throw GentegreHatasi.IsKurali(
                "İzolat girilmemiş - üreme yoksa 'Üreme yok' satırı eklenmeli.");

        var ozet = await _veri.TekDegerAsync<string>(
            "select public.fn_lab_kultur_ozet(@p0)", [kulturId], iptal) ?? "";

        // Özet TEK SONUÇ HATTINA düşer: istem durumu, muayene sekmesi ve
        //   e-Nabız mikrobiyolojiyi ayrıca tanımak zorunda kalmaz.
        var sonuc = await _lab.SonucYazAsync(
            new LabServisi.SonucIstegi(k.SatirId, ozet, null, uzmanYorum, null),
            null, null, baglam, iptal, otoOnaySerbest: false);

        await _lab.OnaylaAsync(sonuc.SonucId, 2, baglam, iptal);

        await _veri.CalistirAsync("""
            update public.lab_kultur
               set durum = @p1, onay_id = @p2, onay_zamani = now(),
                   uzman_yorum = coalesce(nullif(@p3, ''), uzman_yorum),
                   sonuc_id = @p4, degistiren = @p2, degistirme_tarihi = now()
             where id = @p0
            """, [kulturId, Onayli, baglam.KullaniciId, uzmanYorum ?? "",
                  sonuc.SonucId], iptal);

        return $"Kültür onaylandı: {ozet}";
    }

    public async Task<string> IptalAsync(int kulturId, string neden,
                                         IstekBaglami baglam, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(neden))
            throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                [new("neden", "Kültürün neden iptal edildiğini yazın.")]);

        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_kultur
               set durum = 0, uzman_yorum = case when uzman_yorum = '' then @p1
                                                 else uzman_yorum || ' | ' || @p1 end,
                   degistiren = @p2, degistirme_tarihi = now()
             where id = @p0 and durum <> 7
            """, [kulturId, "İptal: " + neden, baglam.KullaniciId], iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali("Onaylı kültür iptal edilemez (düzeltme yapın).");

        // Tetkik yeniden çalışılmalı: satır "tekrar numune bekliyor"a döner,
        //   yoksa istem sessizce sonuçsuz kapanır.
        await _veri.CalistirAsync("""
            update public.lab_istem_satir s set durum = 6
              from public.lab_kultur k
             where k.id = @p0 and s.id = k.istem_satir_id and s.durum <> 0
            """, [kulturId], iptal);

        return "Kültür iptal edildi - tetkik tekrar numune bekliyor.";
    }
}
