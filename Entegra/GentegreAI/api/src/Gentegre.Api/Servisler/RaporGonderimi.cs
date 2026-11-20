using System.Globalization;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Xml;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// RADYOLOJİ RAPORU HASTAYA / GÖNDEREN DIŞ DOKTORA GÖNDERİM (1389-1391; kullanıcı 20.11.2026; mockup
/// Ekranlar/Radyoloji/radyoloji_rapor_hasta_goruntuleme.html).
///
///  * PLANLAMA (rapor onayı / e-imzası, aynı transaction): rapora özel bağlantı satırı (hasta: her zaman - kâğıttaki
///    karekod; gönderen dış doktor: kartında "rapor bildirimi istiyor" ise). Şube ayarında otomatik gönderim açıksa
///    zaman <see cref="RaporGonderimKurali"/> ile (kod › kategori › tümü; kritik bulguda tek süre, 0 = elle).
///  * İŞÇİ: zamanı gelen satırı gönderir. BORÇ KURALI: raporun BAŞVURUSUNUN hasta payı borcu varken ne hastaya ne
///    doktora gider - satır "borç bekliyor"da kalır, borç kapanınca sonraki turda kendiliğinden gider.
///  * BAĞLANTI: doğrulama adımı yok (kullanıcı kararı); borç varken raporu AÇMAZ, süresi dolan / iptal edilen açmaz.
///    Hastanın ilk açışı dijital teslim yazar (radyoloji_teslim tur 1 - "teslim edildi sayılsın").
///  * Onay geri alınırsa bekleyen gönderimler iptal; yeniden onayda aynı bağlantı kodu korunur (basılmış karekod yaşar).
/// </summary>
public sealed class RaporGonderimi(VeriKaynagi veri, BildirimDeposu bildirim, ILogger<RaporGonderimi> gunluk)
{
    /// <summary>bildirim.kaynak_tur: radyoloji rapor gönderimi (kaynak_id = radyoloji_rapor_gonderim.id).</summary>
    public const short KaynakRapor = 51;

    public const short AliciHasta = 1, AliciHekim = 2;
    public const short DurumHazir = 0, DurumPlanli = 1, DurumBorc = 2, DurumGonderildi = 3, DurumHata = 4, DurumIptal = 9;

    // ------------------------------------------------------------------------------------------------- planlama --
    private sealed record IstemBilgisi(int IstemId, int SubeId, int? BelgeId, int? HastaId, int HizmetId, bool Kritik,
        string HastaCep, string HastaEposta, int? HekimId, bool DisHekim, short HekimTercih, string HekimCep,
        string HekimEposta, string HizmetKod, string HizmetAd, int? Kategori);

    private sealed record Ayar(bool Otomatik, int KritikDakika, bool BorcKontrol, bool HastaSms, bool HastaEposta,
                               int GecerlilikGun, string WebKok);

    private static async Task<Ayar> AyarOkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int subeId, CancellationToken iptal)
        => await b.TekAsync("""
            select otomatik, kritik_dakika, borc_kontrol, hasta_sms, hasta_eposta, gecerlilik_gun, web_kok
              from public.radyoloji_rapor_gonderim_ayar where sube_id = @p0
            """, tx, [subeId],
            o => new Ayar(o.GetInt16(0) == 1, o.GetInt32(1), o.GetInt16(2) == 1, o.GetInt16(3) == 1, o.GetInt16(4) == 1,
                          Math.Clamp(o.GetInt32(5), 1, 3650), o.GetString(6)), iptal)
           ?? new Ayar(false, 0, true, true, false, 30, "");

    /// <summary>Tahmin edilemez bağlantı kodu: 16 karakter, karışmayan harf / rakam (0 O 1 I yok) - 80 bit.</summary>
    public static string YeniKod()
    {
        const string alfabe = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Span<byte> bayt = stackalloc byte[16];
        RandomNumberGenerator.Fill(bayt);
        return string.Create(16, bayt.ToArray(), (hedef, kaynak) =>
        {
            for (var i = 0; i < hedef.Length; i++) hedef[i] = alfabe[kaynak[i] & 31];
        });
    }

    /// <summary>
    /// Rapor ONAYLANDI: bağlantı satırlarını kurar / tazeler ve (ayar açıksa) gönderimi planlar. Çağıranın
    /// transaction'ında - onay geri alınırsa planlama da geri alınır.
    /// </summary>
    public static async Task PlanlaAsync(NpgsqlConnection b, NpgsqlTransaction tx, int raporId, int kullaniciId,
                                         CancellationToken iptal, DateTime? simdi = null)
    {
        // EK RAPOR (addendum): ayrı bağlantı açılmaz - ASIL raporun bağlantısı yeniden planlanır (hasta tek bağlantıdan
        //   raporu ekleriyle görür; ek onaylanınca yeniden bilgilendirilir). Revize arşiv kopyası hiç planlanmaz.
        var ust = await b.TekAsync("select ust_rapor_id, coalesce(revize, 0) from public.radyoloji_rapor where id = @p0", tx,
            [raporId], o => (Ust: o.IsDBNull(0) ? (int?)null : o.GetInt32(0), Revize: o.GetInt16(1) == 1).ToTuple(), iptal);
        if (ust is null || ust.Item2) return;
        if (ust.Item1 is { } asil) raporId = asil;

        var i = await b.TekAsync("""
            select i.id, coalesce(i.sube_id, 0), i.belge_id, i.hasta_id, i.hizmet_id, coalesce(i.kritik, 0),
                   coalesce(nullif(btrim(h.cep_tel), ''), ''), coalesce(nullif(btrim(h.eposta), ''), ''),
                   i.istek_hekim_id, coalesce(tp.dis_hekim, 0), coalesce(tp.rapor_bildirim, 0),
                   coalesce(nullif(btrim(dh.cep_tel), ''), ''), coalesce(nullif(btrim(dh.eposta), ''), ''),
                   coalesce(hz.kod, ''), coalesce(hz.ad, ''), hz.kategori
              from public.radyoloji_rapor r
              join public.radyoloji_istem i on i.id = r.istem_id
              left join public.taraf h on h.id = i.hasta_id
              left join public.taraf dh on dh.id = i.istek_hekim_id
              left join public.taraf_personel tp on tp.id = i.istek_hekim_id
              left join public.hizmet hz on hz.id = i.hizmet_id
             where r.id = @p0
            """, tx, [raporId],
            o => new IstemBilgisi(o.GetInt32(0), o.GetInt32(1), o.IsDBNull(2) ? null : o.GetInt32(2),
                o.IsDBNull(3) ? null : o.GetInt32(3), o.IsDBNull(4) ? 0 : o.GetInt32(4), o.GetInt16(5) == 1,
                o.GetString(6), o.GetString(7), o.IsDBNull(8) ? null : o.GetInt32(8), o.GetInt16(9) == 1, o.GetInt16(10),
                o.GetString(11), o.GetString(12), o.GetString(13), o.GetString(14), o.IsDBNull(15) ? null : o.GetInt32(15)), iptal);
        if (i is null || i.SubeId <= 0) return;

        var ayar = await AyarOkuAsync(b, tx, i.SubeId, iptal);
        var an = simdi ?? Saat.An;

        // ZAMAN: kritik bulguda tek süre; değilse kural tablosu (kod › kategori › tümü).
        DateTime? planlanan = null;
        var kuralMetni = "";
        if (ayar.Otomatik)
        {
            if (i.Kritik)
            {
                if (ayar.KritikDakika > 0)
                {
                    planlanan = an.AddMinutes(ayar.KritikDakika);
                    kuralMetni = $"Kritik bulgu · {ayar.KritikDakika} dk sonra";
                }
                else kuralMetni = "Kritik bulgu · elle gönderilir";
            }
            else
            {
                var kurallar = await b.ListeAsync("""
                    select k.kapsam, k.kategori_id, k.hizmet_id, k.zaman_tur, k.saat, k.gun_dakika,
                           coalesce(kt.ad, nullif(btrim(coalesce(hz.kod, '') || ' ' || coalesce(hz.ad, '')), ''), '')
                      from public.radyoloji_rapor_gonderim_kural k
                      left join public.kategori kt on kt.id = k.kategori_id
                      left join public.hizmet hz on hz.id = k.hizmet_id
                     where k.sube_id = @p0 and k.aktif = 1
                    """, tx, [i.SubeId],
                    o => new RaporGonderimKurali.Kural(o.GetInt16(0), o.IsDBNull(1) ? null : o.GetInt32(1),
                        o.IsDBNull(2) ? null : o.GetInt32(2), o.GetInt16(3), o.GetInt32(4), o.GetInt32(5), o.GetString(6)), iptal);
                // Kategori zinciri: tetkiğin kategorisi ve üstleri, yakından uzağa.
                var zincir = i.Kategori is { } kat
                    ? await b.ListeAsync("""
                        with recursive z as (
                            select id, ust_id, 0 as d from public.kategori where id = @p0
                            union all
                            select k.id, k.ust_id, z.d + 1 from public.kategori k join z on k.id = z.ust_id where z.d < 20)
                        select id from z order by d
                        """, tx, [kat], o => o.GetInt32(0), iptal)
                    : [];
                if (RaporGonderimKurali.Sec(kurallar, i.HizmetId, zincir) is { } kural)
                {
                    var dilim = Saat.Dilim(await b.TekDegerAsync<string>("select public.fn_sube_zaman_dilimi(@p0)", tx, [i.SubeId], iptal));
                    planlanan = RaporGonderimKurali.Zaman(kural, an, dilim);
                    kuralMetni = RaporGonderimKurali.Aciklama(kural);
                }
                else kuralMetni = "Kural yok · elle gönderilir";
            }
        }

        var sonGecerli = an.AddDays(ayar.GecerlilikGun);

        // HASTA satırı her zaman: kâğıt çıktıdaki karekod bu bağlantıdır (SMS gitmese de).
        if (i.HastaId is > 0)
        {
            var kanal = (short)((ayar.HastaSms && i.HastaCep.Length > 0 ? 1 : 0) + (ayar.HastaEposta && i.HastaEposta.Length > 0 ? 2 : 0));
            await SatirYazAsync(b, tx, raporId, i, AliciHasta, i.HastaId.Value, kanal, i.HastaCep, i.HastaEposta, planlanan,
                                kuralMetni, sonGecerli, ayar.WebKok, kullaniciId,
                                kanalYokHata: ayar.HastaSms || ayar.HastaEposta ? "Cep telefonu / e-posta kayıtlı değil" : "", iptal);
        }

        // GÖNDEREN DIŞ DOKTOR: yalnız kartında rapor bildirimi isteyen.
        if (i.HekimId is > 0 && i.DisHekim && i.HekimTercih > 0)
        {
            var kanal = (short)(((i.HekimTercih & 1) == 1 && i.HekimCep.Length > 0 ? 1 : 0) + ((i.HekimTercih & 2) == 2 && i.HekimEposta.Length > 0 ? 2 : 0));
            await SatirYazAsync(b, tx, raporId, i, AliciHekim, i.HekimId.Value, kanal, i.HekimCep, i.HekimEposta, planlanan,
                                kuralMetni, sonGecerli, ayar.WebKok, kullaniciId,
                                kanalYokHata: "Doktorun cep telefonu / e-postası kayıtlı değil", iptal);
        }
        else
        {
            // Doktor değişti / tercihini kaldırdı: eski satır iptal.
            await b.CalistirAsync("""
                update public.radyoloji_rapor_gonderim set durum = 9, degistiren = @p1, degistirme_tarihi = now()
                 where rapor_id = @p0 and alici_tur = 2 and durum <> 9
                """, tx, [raporId, kullaniciId], iptal);
        }
    }

    private static async Task SatirYazAsync(NpgsqlConnection b, NpgsqlTransaction tx, int raporId, IstemBilgisi i,
        short aliciTur, int tarafId, short kanal, string cep, string eposta, DateTime? planlanan, string kural,
        DateTime sonGecerli, string webKok, int kullaniciId, string kanalYokHata, CancellationToken iptal)
    {
        // Otomatik planlandı ama kanal yok: gönderilemedi (liste nedenini gösterir). Plan yoksa "hazır" (elle).
        var durum = planlanan is null ? DurumHazir : kanal == 0 ? DurumHata : DurumPlanli;
        var hata = durum == DurumHata ? kanalYokHata : "";
        await b.CalistirAsync("""
            insert into public.radyoloji_rapor_gonderim
                   (rapor_id, istem_id, sube_id, alici_tur, taraf_id, kod, kanal, sms_alici, eposta_alici, planlanan,
                    kural, durum, hata, son_gecerli, web_kok, ekleyen, degistiren)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15, @p15)
            on conflict (rapor_id, alici_tur) do update
               set taraf_id = excluded.taraf_id, kanal = excluded.kanal, sms_alici = excluded.sms_alici,
                   eposta_alici = excluded.eposta_alici, planlanan = excluded.planlanan, kural = excluded.kural,
                   durum = excluded.durum, hata = excluded.hata, son_gecerli = excluded.son_gecerli,
                   web_kok = excluded.web_kok, gonderim = null, borca_ragmen = 0,
                   degistiren = excluded.degistiren, degistirme_tarihi = now()
            """, tx,
            [raporId, i.IstemId, i.SubeId, aliciTur, tarafId, YeniKod(), kanal, cep, eposta, planlanan, kural, durum, hata,
             sonGecerli, webKok, kullaniciId], iptal);
    }

    /// <summary>Onay geri alındı / rapor yeniden açıldı: bekleyen gönderimler iptal, bağlantı raporu açmaz.</summary>
    public static Task<int> IptalAsync(NpgsqlConnection b, NpgsqlTransaction tx, int raporId, int kullaniciId, CancellationToken iptal)
        => b.CalistirAsync("""
            update public.radyoloji_rapor_gonderim set durum = 9, degistiren = @p1, degistirme_tarihi = now()
             where rapor_id = @p0 and durum <> 9
            """, tx, [raporId, kullaniciId], iptal);

    // --------------------------------------------------------------------------------------------------- gönderim --
    /// <summary>Kuruş farkı eşiği (cari.icmal_esik, boş = 0,10): altı borç sayılmaz.</summary>
    private const string EsikSql = """
        coalesce((select nullif(replace(btrim(r.deger), ',', '.'), '')::numeric from public.referans r
                   where r.anahtar = 'cari.icmal_esik' limit 1), 0.10)
        """;

    /// <summary>Başvurunun hasta payı borcu (eşiğin üstündeyse); yoksa 0.</summary>
    public static async Task<decimal> BorcAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int? belgeId, CancellationToken iptal)
    {
        if (belgeId is not > 0) return 0;
        var kalan = await b.TekDegerAsync<decimal?>($"""
            select case when public.fn_basvuru_hasta_kalan(@p0) > {EsikSql} then public.fn_basvuru_hasta_kalan(@p0) else 0 end
            """, tx, [belgeId], iptal);
        return kalan ?? 0;
    }

    /// <summary>İşçi turu: zamanı gelen (planlı / borç bekleyen) satırlar. Gönderilen satır sayısı döner.</summary>
    public async Task<int> SiradakileriIsleAsync(int azami, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var idler = await b.ListeAsync("""
            select id from public.radyoloji_rapor_gonderim
             where durum in (1, 2) and planlanan <= now()
             order by planlanan limit @p0
            """, null, [azami], o => o.GetInt32(0), iptal);
        var gonderilen = 0;
        foreach (var id in idler)
        {
            try { if (await IsleAsync(b, id, 0, false, iptal) == DurumGonderildi) gonderilen++; }
            catch (Exception h) when (h is not OperationCanceledException)
            {
                gunluk.LogError(h, "Rapor gönderimi {Id} işlenemedi.", id);
            }
        }
        return gonderilen;
    }

    /// <summary>Elle: "Şimdi Gönder" / "Borca Rağmen Gönder" - zamanı beklemeden işler. Yeni durumu döner.</summary>
    public async Task<short> SimdiGonderAsync(int id, bool borcaRagmen, int kullaniciId, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await IsleAsync(b, id, kullaniciId, borcaRagmen, iptal, elle: true);
    }

    private sealed record Satir(int Id, int RaporId, int IstemId, int SubeId, short AliciTur, int? TarafId, string Kod,
        short Kanal, string Sms, string Eposta, short Durum, bool BorcaRagmen, string WebKok, DateTime SonGecerli,
        short RaporDurum, int? BelgeId, string Hasta, string Tetkik, DateTime? Cekim, string Sube, string Hekim, bool Revize);

    private static Task<Satir?> SatirOkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, string kosul, object deger, bool kilitle, CancellationToken iptal)
        => b.TekAsync($"""
            select g.id, g.rapor_id, g.istem_id, g.sube_id, g.alici_tur, g.taraf_id, g.kod, g.kanal, g.sms_alici,
                   g.eposta_alici, g.durum, g.borca_ragmen, g.web_kok, g.son_gecerli, r.durum, i.belge_id,
                   coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                   coalesce(hz.ad, ''), i.cekim_tarihi, coalesce(s.ad, ''),
                   coalesce(public.fn_taraf_ad(dh.unvan, dh.ad, dh.soyad)::varchar(120), ''), coalesce(r.revize, 0)
              from public.radyoloji_rapor_gonderim g
              join public.radyoloji_rapor r on r.id = g.rapor_id
              join public.radyoloji_istem i on i.id = g.istem_id
              left join public.taraf h on h.id = i.hasta_id
              left join public.hizmet hz on hz.id = i.hizmet_id
              left join public.sube s on s.id = g.sube_id
              left join public.taraf dh on dh.id = g.taraf_id and g.alici_tur = 2
             where {kosul} {(kilitle ? "for update of g" : "")}
            """, tx, [deger],
            o => new Satir(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3), o.GetInt16(4),
                o.IsDBNull(5) ? null : o.GetInt32(5), o.GetString(6), o.GetInt16(7), o.GetString(8), o.GetString(9),
                o.GetInt16(10), o.GetInt16(11) == 1, o.GetString(12), o.GetDateTime(13), o.GetInt16(14),
                o.IsDBNull(15) ? null : o.GetInt32(15), o.GetString(16), o.GetString(17),
                o.IsDBNull(18) ? null : o.GetDateTime(18), o.GetString(19), o.GetString(20), o.GetInt16(21) == 1), iptal);

    /// <summary>Hasta adı maskeli: "Ayşe K***" - SMS yanlış numaraya giderse tam ad açığa çıkmasın.</summary>
    public static string Maske(string ad)
    {
        var p = ad.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        return p.Length == 0 ? "" : p.Length == 1 ? p[0] : $"{string.Join(' ', p[..^1])} {p[^1][..1]}***";
    }

    private static string Rakamlar(string v) => new(v.Where(char.IsDigit).ToArray());

    public static string Baglanti(string webKok, string kod) => $"{webKok.TrimEnd('/')}/r/{kod}";

    private async Task<short> IsleAsync(NpgsqlConnection b, int id, int kullaniciId, bool borcaRagmen, CancellationToken iptal, bool elle = false)
    {
        await using var tx = await b.BeginTransactionAsync(iptal);
        var s = await SatirOkuAsync(b, tx, "g.id = @p0", id, true, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Gönderim kaydı bulunamadı.");

        async Task<short> BitirAsync(short durum, string hata = "", bool gonderildi = false)
        {
            await b.CalistirAsync("""
                update public.radyoloji_rapor_gonderim
                   set durum = @p1, hata = @p2, gonderim = case when @p3 then now() else gonderim end,
                       borca_ragmen = case when @p4 then 1 else borca_ragmen end,
                       planlanan = coalesce(planlanan, now()),
                       degistiren = case when @p5 > 0 then @p5 else degistiren end, degistirme_tarihi = now()
                 where id = @p0
                """, tx, [id, durum, hata.Length > 200 ? hata[..200] : hata, gonderildi, borcaRagmen, kullaniciId], iptal);
            await tx.CommitAsync(iptal);
            return durum;
        }

        if (!elle && s.Durum is not (DurumPlanli or DurumBorc)) { await tx.RollbackAsync(iptal); return s.Durum; }
        // Rapor artık onaylı değil (geri alındı / revize kopyası): gönderilmez.
        if (s.RaporDurum != 3 || s.Revize) return await BitirAsync(DurumIptal, "Rapor onaylı değil");

        var ayar = await AyarOkuAsync(b, tx, s.SubeId, iptal);
        if (ayar.BorcKontrol && !(s.BorcaRagmen || borcaRagmen) && await BorcAsync(b, tx, s.BelgeId, iptal) > 0)
            return await BitirAsync(DurumBorc);

        var kok = s.WebKok.Length > 0 ? s.WebKok : ayar.WebKok;
        if (kok.Length == 0) return await BitirAsync(DurumHata, "Bağlantı adresi tanımlı değil (Radyoloji › Rapor Gönderimi ayarını kaydedin)");
        if (s.Kanal == 0) return await BitirAsync(DurumHata, s.AliciTur == AliciHasta ? "Cep telefonu / e-posta kayıtlı değil" : "Doktorun cep telefonu / e-postası kayıtlı değil");

        var degisken = new Dictionary<string, string>
        {
            ["hasta"] = Maske(s.Hasta), ["tetkik"] = s.Tetkik,
            ["tarih"] = s.Cekim is { } c ? c.ToString("dd.MM.yyyy", CultureInfo.InvariantCulture) : "",
            ["link"] = Baglanti(kok, s.Kod), ["kurum"] = s.Sube, ["hekim"] = s.Hekim,
            ["gun"] = Math.Max(1, (int)Math.Ceiling((s.SonGecerli - Saat.An).TotalDays)).ToString(CultureInfo.InvariantCulture),
        };
        var hekim = s.AliciTur == AliciHekim;
        var yazilan = 0;
        if ((s.Kanal & 1) == 1 && Rakamlar(s.Sms) is { Length: >= 10 } tel)
            if (await bildirim.KuyrugaEkleAsync(b, tx, new BildirimIstegi(
                    SablonKodu: hekim ? "radyoloji.rapor_hekim" : "radyoloji.rapor_hasta", Kanal: BildirimKanali.Sms, Alici: tel,
                    Degiskenler: degisken, TarafId: s.TarafId, KaynakTur: KaynakRapor, KaynakId: s.Id, Oncelik: 4),
                    kullaniciId, s.SubeId, iptal) is not null) yazilan++;
        if ((s.Kanal & 2) == 2 && s.Eposta.Contains('@'))
            if (await bildirim.KuyrugaEkleAsync(b, tx, new BildirimIstegi(
                    SablonKodu: hekim ? "radyoloji.rapor_hekim_eposta" : "radyoloji.rapor_hasta_eposta", Kanal: BildirimKanali.Eposta,
                    Alici: s.Eposta, Degiskenler: degisken, TarafId: s.TarafId, KaynakTur: KaynakRapor, KaynakId: s.Id, Oncelik: 4),
                    kullaniciId, s.SubeId, iptal) is not null) yazilan++;
        return yazilan > 0
            ? await BitirAsync(DurumGonderildi, gonderildi: true)
            : await BitirAsync(DurumHata, "Telefon / e-posta geçersiz ya da bildirim şablonu pasif");
    }

    // --------------------------------------------------------------------------------------------- bağlantı açılışı --
    /// <summary>ok rapor gösterilir · iletisim borç var · sure süresi doldu · guncel rapor geri çekildi / güncelleniyor.</summary>
    public sealed record Acilis(string Durum, int RaporId, short AliciTur, DateTime SonGecerli, int SubeId);

    /// <summary>
    /// Bağlantı açıldı. Kod yoksa null. Borç / süre / iptal durumunda rapor GÖSTERİLMEZ (denemeler de sayılmaz - yalnız
    /// başarılı açılış sayaca ve dijital teslime yazılır).
    /// </summary>
    public async Task<Acilis?> AcAsync(string kod, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(kod) || kod.Length > 24) return null;
        await using var b = await veri.AcAsync(iptal);
        await using var tx = await b.BeginTransactionAsync(iptal);
        var s = await SatirOkuAsync(b, tx, "g.kod = @p0", kod.Trim().ToUpperInvariant(), true, iptal);
        if (s is null) return null;

        string durum;
        if (s.Durum == DurumIptal || s.RaporDurum != 3 || s.Revize) durum = "guncel";
        else if (s.SonGecerli < Saat.An) durum = "sure";
        else
        {
            var ayar = await AyarOkuAsync(b, tx, s.SubeId, iptal);
            durum = ayar.BorcKontrol && !s.BorcaRagmen && await BorcAsync(b, tx, s.BelgeId, iptal) > 0 ? "iletisim" : "ok";
        }

        if (durum == "ok")
        {
            await b.CalistirAsync("""
                update public.radyoloji_rapor_gonderim
                   set ilk_acilma = coalesce(ilk_acilma, now()), son_acilma = now(), acilma_sayisi = acilma_sayisi + 1
                 where id = @p0
                """, tx, [s.Id], iptal);
            // HASTANIN İLK AÇIŞI = DİJİTAL TESLİM (kullanıcı: "teslim edildi sayılsın"). Doktorun açması teslim değil.
            if (s.AliciTur == AliciHasta)
                await b.CalistirAsync("""
                    insert into public.radyoloji_teslim
                           (istem_id, rapor_id, tur, teslim_zamani, teslim_eden_id, alan_ad, alan_yakinlik,
                            kimlik_dogrulandi, aciklama, ekleyen, rapor_verildi, film_verildi, cd_verildi, dijital_verildi)
                    select @p0, @p1, 1, now()::timestamp, null, 'Hasta (bağlantı)', 'Kendisi', 0,
                           'Rapor bağlantısı açıldı', 0, 0, 0, 0, 1
                     where not exists (select 1 from public.radyoloji_teslim t
                                        where t.istem_id = @p0 and t.rapor_id = @p1 and t.teslim_eden_id is null and t.tur = 1)
                    """, tx, [s.IstemId, s.RaporId], iptal);
        }
        await tx.CommitAsync(iptal);
        return new Acilis(durum, s.RaporId, s.AliciTur, s.SonGecerli, s.SubeId);
    }

    // ------------------------------------------------------------------------------------------------- imza bilgisi --
    public sealed record ImzaBilgisi(bool Gecerli, string Hata, string Sahip, string Veren, DateTime? GecerlilikBas,
                                     DateTime? GecerlilikBit, string SeriNo);

    /// <summary>
    /// İmzalı XML'den panel bilgisi: imza kriptografik olarak geçerli mi (belge değişmemiş mi -
    /// <see cref="EImzaServisi.ImzaKimliginiDogrula"/>) ve imzalayan sertifikanın sahibi / veren kurum / geçerlilik /
    /// seri no. Sertifika iptal (OCSP) sorgusu YOK.
    /// </summary>
    public static ImzaBilgisi ImzaBilgisiOku(byte[] imzaXml)
    {
        var kimlik = EImzaServisi.ImzaKimliginiDogrula(imzaXml);
        try
        {
            var xml = new XmlDocument { PreserveWhitespace = true, XmlResolver = null };
            using (var okuyucu = XmlReader.Create(new MemoryStream(imzaXml),
                       new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit, XmlResolver = null }))
                xml.Load(okuyucu);
            X509Certificate2? secilen = null;
            foreach (XmlNode dugum in xml.GetElementsByTagName("X509Certificate", "http://www.w3.org/2000/09/xmldsig#"))
            {
                var c = X509CertificateLoader.LoadCertificate(Convert.FromBase64String(dugum.InnerText.Trim()));
                // Uç sertifika (CA olmayan) imzalayandır; zincirdeki kök / ara sertifikalar atlanır.
                var ca = c.Extensions.OfType<X509BasicConstraintsExtension>().FirstOrDefault()?.CertificateAuthority ?? false;
                if (!ca || secilen is null) { secilen?.Dispose(); secilen = c; if (!ca) break; } else c.Dispose();
            }
            if (secilen is null) return new(kimlik.Gecerli, kimlik.Hata, "", "", null, null, "");
            using (secilen)
                return new(kimlik.Gecerli, kimlik.Hata, secilen.GetNameInfo(X509NameType.SimpleName, false),
                           secilen.GetNameInfo(X509NameType.SimpleName, true), secilen.NotBefore.ToUniversalTime(),
                           secilen.NotAfter.ToUniversalTime(), secilen.SerialNumber);
        }
        catch (Exception h) when (h is XmlException or FormatException or CryptographicException)
        {
            return new(kimlik.Gecerli, kimlik.Hata.Length > 0 ? kimlik.Hata : "Sertifika okunamadı.", "", "", null, null, "");
        }
    }
}
