using System.Globalization;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// RAPOR GÖNDERİMİ - LABORATUVAR (1394; kullanıcı 20.11.2026; mockup radyoloji_rapor_hasta_goruntuleme.html §7).
///
///  * GÖNDERİM BİRİMİ BÖLÜM ("labda hem biyokimya hem mikrobiyoloji varsa ve ayrı ayrı onam yapılıyorsa ayrı ayrı gider"):
///    bir başvurunun bir lab bölümünün (Biyokimya, Hematoloji, Mikrobiyoloji…) testlerinin TAMAMI onaylanınca o bölümün
///    bağlantısı kurulur ve gönderimi planlanır. Onayın dört yolu da (elle, otomatik, kültür, genetik) istem durumunu
///    tazeler - planlama oradan çağrılır.
///  * ZAMAN: bölümdeki testlerin kurallarından EN GEÇ olanı (kod › kategori › tümü - radyolojiyle aynı tablo). PANİK
///    DEĞER varsa kurallara bakılmaz: ayarın laboratuvar panik süresi (0 = elle).
///  * DÜZELTME: onaylı sonuç düzeltilince bölüm "tamamı onaylı" olmaktan çıkar - bekleyen gönderim iptal, bağlantı
///    "güncelleniyor" gösterir; yeniden onayda aynı bağlantı kodu yeniden planlanır.
///  * HASTA SAYFASI: Bakanlık "Tıbbi Laboratuvar Tetkik Sonuç Raporu" alanları, geçmiş iki sonuç, bayrak (ok işaretleri
///    istemcide). "Bağlantıda gizle" işaretli test hastaya gösterilmez (sayısı döner); gönderen dış doktor görür.
/// </summary>
public sealed partial class RaporGonderimi
{
    private static readonly Dictionary<short, string> LabBolumAdlari = new()
    {
        [1] = "Biyokimya", [2] = "Hematoloji", [3] = "Hormon", [4] = "Mikrobiyoloji", [5] = "Seroloji",
        [6] = "Koagülasyon", [7] = "İdrar", [9] = "Diğer",
    };

    public static string LabBolumAdi(short bolum) => LabBolumAdlari.GetValueOrDefault(bolum, "Laboratuvar");

    /// <summary>Bölümün o başvurudaki (iptal olmayan) testlerinin tamamı onaylı mı - SQL koşulu.</summary>
    private static string LabBolumOnayliSql(string belge, string bolum) => $"""
        (select count(*) > 0 and count(*) = count(*) filter (where ls_.durum = 5)
           from public.lab_istem li_
           join public.lab_istem_satir ls_ on ls_.istem_id = li_.id and ls_.durum <> 0
           left join public.lab_tetkik lt_ on lt_.id = ls_.tetkik_id
          where li_.belge_id = {belge} and coalesce(lt_.bolum, 9) = {bolum})
        """;

    /// <summary>
    /// Lab isteminin durumu tazelendi: başvurunun bölümlerine bakılır - tamamı onaylanan bölüm planlanır, artık tam
    /// onaylı olmayan (düzeltme) bölümün bekleyen gönderimi iptal edilir. Zaten planlı / gönderilmiş bölüme dokunulmaz.
    /// </summary>
    public static async Task LabPlanlaAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int istemId, CancellationToken iptal,
                                            DateTime? simdi = null)
    {
        var istem = await b.TekAsync("""
            select i.belge_id, coalesce(i.sube_id, 0), i.taraf_id, i.personel_id,
                   coalesce(nullif(btrim(h.cep_tel), ''), ''), coalesce(nullif(btrim(h.eposta), ''), ''),
                   coalesce(tp.dis_hekim, 0), coalesce(tp.rapor_bildirim, 0),
                   coalesce(nullif(btrim(dh.cep_tel), ''), ''), coalesce(nullif(btrim(dh.eposta), ''), '')
              from public.lab_istem i
              left join public.taraf h on h.id = i.taraf_id
              left join public.taraf dh on dh.id = i.personel_id
              left join public.taraf_personel tp on tp.id = i.personel_id
             where i.id = @p0
            """, tx, [istemId], o => new
            {
                BelgeId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), SubeId = o.GetInt32(1),
                HastaId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), HekimId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                HastaCep = o.GetString(4), HastaEposta = o.GetString(5), DisHekim = o.GetInt16(6) == 1,
                HekimTercih = o.GetInt16(7), HekimCep = o.GetString(8), HekimEposta = o.GetString(9),
            }, iptal);
        // Başvurusuz istem (dış kurum numunesi vb.): hasta bağlantısı / borç kuralı başvuruya dayanır - planlanmaz.
        if (istem?.BelgeId is not { } belgeId || istem.SubeId <= 0 || istem.HastaId is not > 0) return;

        var bolumler = await b.ListeAsync("""
            select coalesce(t.bolum, 9)::smallint, count(*), count(*) filter (where s.durum = 5),
                   coalesce(bool_or(coalesce(ls.panik, 0) = 1), false)
              from public.lab_istem li
              join public.lab_istem_satir s on s.istem_id = li.id and s.durum <> 0
              left join public.lab_tetkik t on t.id = s.tetkik_id
              left join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
             where li.belge_id = @p0
             group by 1
            """, tx, [belgeId],
            o => (Bolum: o.GetInt16(0), Toplam: o.GetInt64(1), Onayli: o.GetInt64(2), Panik: o.GetBoolean(3)), iptal);
        var mevcut = await b.ListeAsync("""
            select lab_bolum, durum from public.radyoloji_rapor_gonderim
             where kaynak = 2 and belge_id = @p0 and alici_tur = 1
            """, tx, [belgeId], o => (Bolum: o.GetInt16(0), Durum: o.GetInt16(1)), iptal);

        Ayar? ayar = null;
        List<RaporGonderimKurali.Kural>? kurallar = null;
        var an = simdi ?? Saat.An;

        foreach (var bl in bolumler)
        {
            var tamam = bl.Toplam > 0 && bl.Onayli == bl.Toplam;
            var satir = mevcut.Where(m => m.Bolum == bl.Bolum).Select(m => (short?)m.Durum).FirstOrDefault();
            if (!tamam)
            {
                // DÜZELTME / yeni test eklendi: bölüm artık tam onaylı değil - bekleyen gönderim iptal, bağlantı kapalı.
                if (satir is not null && satir != DurumIptal)
                    await b.CalistirAsync("""
                        update public.radyoloji_rapor_gonderim set durum = 9, degistirme_tarihi = now()
                         where kaynak = 2 and belge_id = @p0 and lab_bolum = @p1 and durum <> 9
                        """, tx, [belgeId, bl.Bolum], iptal);
                continue;
            }
            if (satir is not null && satir != DurumIptal) continue;        // zaten planlı / gönderilmiş

            ayar ??= await AyarOkuAsync(b, tx, istem.SubeId, iptal);
            DateTime? planlanan = null;
            var kuralMetni = "";
            if (ayar.Otomatik)
            {
                if (bl.Panik)
                {
                    if (ayar.LabPanikDakika > 0)
                    {
                        planlanan = an.AddMinutes(ayar.LabPanikDakika);
                        kuralMetni = $"Panik değer · {ayar.LabPanikDakika} dk sonra";
                    }
                    else kuralMetni = "Panik değer · elle gönderilir";
                }
                else
                {
                    kurallar ??= await KurallarAsync(b, tx, istem.SubeId, iptal);
                    var dilim = Saat.Dilim(await b.TekDegerAsync<string>("select public.fn_sube_zaman_dilimi(@p0)", tx, [istem.SubeId], iptal));
                    // Bölümün testleri: her biri kendi kuralıyla; EN GEÇ olan uygulanır (tek bildirim).
                    var testler = await b.ListeAsync("""
                        select distinct coalesce(t.hizmet_id, 0), hz.kategori
                          from public.lab_istem li
                          join public.lab_istem_satir s on s.istem_id = li.id and s.durum <> 0
                          left join public.lab_tetkik t on t.id = s.tetkik_id
                          left join public.hizmet hz on hz.id = t.hizmet_id
                         where li.belge_id = @p0 and coalesce(t.bolum, 9) = @p1
                        """, tx, [belgeId, bl.Bolum],
                        o => (Hizmet: o.GetInt32(0), Kategori: o.IsDBNull(1) ? (int?)null : o.GetInt32(1)), iptal);
                    var zincirler = new Dictionary<int, IReadOnlyList<int>>();
                    foreach (var t in testler)
                    {
                        IReadOnlyList<int> zincir = [];
                        if (t.Kategori is { } kat && !zincirler.TryGetValue(kat, out zincir!))
                            zincirler[kat] = zincir = await KategoriZinciriAsync(b, tx, kat, iptal);
                        if (RaporGonderimKurali.Sec(kurallar, t.Hizmet, zincir) is not { } kural) continue;
                        var z = RaporGonderimKurali.Zaman(kural, an, dilim);
                        if (planlanan is null || z > planlanan) { planlanan = z; kuralMetni = RaporGonderimKurali.Aciklama(kural); }
                    }
                    if (planlanan is null) kuralMetni = "Kural yok · elle gönderilir";
                }
            }
            var sonGecerli = an.AddDays(ayar.GecerlilikGun);

            var hastaKanal = (short)((ayar.HastaSms && istem.HastaCep.Length > 0 ? 1 : 0) + (ayar.HastaEposta && istem.HastaEposta.Length > 0 ? 2 : 0));
            await LabSatirYazAsync(b, tx, belgeId, bl.Bolum, istem.SubeId, AliciHasta, istem.HastaId.Value, hastaKanal,
                istem.HastaCep, istem.HastaEposta, planlanan, kuralMetni, sonGecerli, ayar.WebKok,
                ayar.HastaSms || ayar.HastaEposta ? "Cep telefonu / e-posta kayıtlı değil" : "", iptal);

            if (istem.HekimId is > 0 && istem.DisHekim && istem.HekimTercih > 0)
            {
                var kanal = (short)(((istem.HekimTercih & 1) == 1 && istem.HekimCep.Length > 0 ? 1 : 0)
                                  + ((istem.HekimTercih & 2) == 2 && istem.HekimEposta.Length > 0 ? 2 : 0));
                await LabSatirYazAsync(b, tx, belgeId, bl.Bolum, istem.SubeId, AliciHekim, istem.HekimId.Value, kanal,
                    istem.HekimCep, istem.HekimEposta, planlanan, kuralMetni, sonGecerli, ayar.WebKok,
                    "Doktorun cep telefonu / e-postası kayıtlı değil", iptal);
            }
        }
    }

    private static Task LabSatirYazAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int belgeId, short bolum, int subeId,
        short aliciTur, int tarafId, short kanal, string cep, string eposta, DateTime? planlanan, string kural,
        DateTime sonGecerli, string webKok, string kanalYokHata, CancellationToken iptal)
    {
        var durum = planlanan is null ? DurumHazir : kanal == 0 ? DurumHata : DurumPlanli;
        return b.CalistirAsync("""
            insert into public.radyoloji_rapor_gonderim
                   (kaynak, belge_id, lab_bolum, sube_id, alici_tur, taraf_id, kod, kanal, sms_alici, eposta_alici, planlanan,
                    kural, durum, hata, son_gecerli, web_kok)
            values (2, @p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14)
            on conflict (belge_id, lab_bolum, alici_tur) where kaynak = 2 do update
               set taraf_id = excluded.taraf_id, kanal = excluded.kanal, sms_alici = excluded.sms_alici,
                   eposta_alici = excluded.eposta_alici, planlanan = excluded.planlanan, kural = excluded.kural,
                   durum = excluded.durum, hata = excluded.hata, son_gecerli = excluded.son_gecerli,
                   web_kok = excluded.web_kok, gonderim = null, borca_ragmen = 0, degistirme_tarihi = now()
            """, tx,
            [belgeId, bolum, subeId, aliciTur, tarafId, YeniKod(), kanal, cep, eposta, planlanan, kural, durum,
             durum == DurumHata ? kanalYokHata : "", sonGecerli, webKok], iptal);
    }

    private static Task<List<RaporGonderimKurali.Kural>> KurallarAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int subeId, CancellationToken iptal)
        => b.ListeAsync("""
            select k.kapsam, k.kategori_id, k.hizmet_id, k.zaman_tur, k.saat, k.gun_dakika,
                   coalesce(kt.ad, nullif(btrim(coalesce(hz.kod, '') || ' ' || coalesce(hz.ad, '')), ''), '')
              from public.radyoloji_rapor_gonderim_kural k
              left join public.kategori kt on kt.id = k.kategori_id
              left join public.hizmet hz on hz.id = k.hizmet_id
             where k.sube_id = @p0 and k.aktif = 1
            """, tx, [subeId],
            o => new RaporGonderimKurali.Kural(o.GetInt16(0), o.IsDBNull(1) ? null : o.GetInt32(1),
                o.IsDBNull(2) ? null : o.GetInt32(2), o.GetInt16(3), o.GetInt32(4), o.GetInt32(5), o.GetString(6)), iptal);

    private static async Task<IReadOnlyList<int>> KategoriZinciriAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int kategori, CancellationToken iptal)
        => await b.ListeAsync("""
            with recursive z as (
                select id, ust_id, 0 as d from public.kategori where id = @p0
                union all
                select k.id, k.ust_id, z.d + 1 from public.kategori k join z on k.id = z.ust_id where z.d < 20)
            select id from z order by d
            """, tx, [kategori], o => o.GetInt32(0), iptal);

    // ----------------------------------------------------------------------------------------- hasta sayfası verisi --
    private static string TcMaske(string v) => v.Length >= 5 ? $"{v[..2]}{new string('*', v.Length - 4)}{v[^2..]}" : v;

    /// <summary>
    /// Bağlantı sayfasının lab verisi: Bakanlık "Tıbbi Laboratuvar Tetkik Sonuç Raporu" alanları + bölümün ONAYLI
    /// sonuçları + her testin geçmiş iki sonucu. <paramref name="hekim"/> false ise "bağlantıda gizle" testleri çıkar.
    /// </summary>
    public static async Task<object> LabRaporVerisiAsync(NpgsqlConnection b, int belgeId, short bolum, bool hekim, CancellationToken iptal)
    {
        var baslik = await b.TekAsync("""
            select coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), coalesce(h.vkno, ''),
                   hs.dogum_tarihi, coalesce(hs.cinsiyet, 0), coalesce(h.kod, ''), coalesce(be.belge_no, ''),
                   coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), ''),
                   coalesce(public.fn_taraf_ad(ok.unvan, ok.ad, ok.soyad)::varchar(120), 'Ücretli'),
                   coalesce(sb.ad, ''), coalesce(d.ad, ''), i.taraf_id, i.sube_id,
                   (select min(x.istem_tarihi) from public.lab_istem x where x.belge_id = be.id)
              from public.belge be
              join lateral (select * from public.lab_istem x where x.belge_id = be.id order by x.id limit 1) i on true
              left join public.taraf h on h.id = i.taraf_id
              left join public.taraf_hasta hs on hs.id = i.taraf_id
              left join public.taraf p on p.id = i.personel_id
              left join public.belge_basvuru bb on bb.id = be.id
              left join public.taraf ok on ok.id = bb.odeyen_kurum_id
              left join public.departman d on d.id = bb.bolum_id
              left join public.sube sb on sb.id = i.sube_id
             where be.id = @p0
            """, null, [belgeId], o => new
            {
                Hasta = o.GetString(0), Tc = o.GetString(1), Dogum = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                Cinsiyet = o.GetInt16(3), DosyaNo = o.GetString(4), ProtokolNo = o.GetString(5), Isteyen = o.GetString(6),
                Kurum = o.GetString(7), Sube = o.GetString(8), Yer = o.GetString(9),
                HastaId = o.IsDBNull(10) ? 0 : o.GetInt32(10), SubeId = o.IsDBNull(11) ? 0 : o.GetInt32(11),
                Istem = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Sonuç bulunamadı.");

        var tum = await b.ListeAsync("""
            select s.tetkik_id, t.kod, t.ad, coalesce(ls.deger_metin, ''), coalesce(ls.birim, ''), coalesce(ls.bayrak, ''),
                   coalesce(ls.panik, 0), ls.referans_alt, ls.referans_ust, coalesce(ls.referans_metin, ''),
                   coalesce(ls.karar_notu, ''), coalesce(ls.yorum, ''), coalesce(n.barkod, ''), n.alim_zamani, n.kabul_zamani,
                   ls.onay_zamani, ls.onay_id, coalesce(t.baglantida_gizle, 0), coalesce(n.numune_tipi, 0), coalesce(t.yontem, '')
              from public.lab_istem li
              join public.lab_istem_satir s on s.istem_id = li.id and s.durum = 5
              join public.lab_tetkik t on t.id = s.tetkik_id
              join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
              left join public.lab_numune n on n.id = ls.numune_id
             where li.belge_id = @p0 and coalesce(t.bolum, 9) = @p1
             order by s.sira, t.kod
            """, null, [belgeId, bolum], o => new
            {
                TetkikId = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2), Sonuc = o.GetString(3), Birim = o.GetString(4),
                Bayrak = o.GetString(5), Panik = o.GetInt16(6) == 1,
                RefAlt = o.IsDBNull(7) ? (decimal?)null : o.GetDecimal(7), RefUst = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                RefMetin = o.GetString(9), Karar = o.GetString(10), Yorum = o.GetString(11), Barkod = o.GetString(12),
                Alim = o.IsDBNull(13) ? (DateTime?)null : o.GetDateTime(13), Kabul = o.IsDBNull(14) ? (DateTime?)null : o.GetDateTime(14),
                Onay = o.IsDBNull(15) ? (DateTime?)null : o.GetDateTime(15), OnayId = o.IsDBNull(16) ? 0 : o.GetInt32(16),
                Gizli = o.GetInt16(17) == 1, NumuneTipi = o.GetInt16(18), Yontem = o.GetString(19),
            }, iptal);

        // "BAĞLANTIDA GİZLE": hastaya gösterilmez (sayısı döner, adı dönmez); gönderen dış doktor görür.
        var gorunen = hekim ? tum : tum.Where(x => !x.Gizli).ToList();
        var gizlenen = tum.Count - gorunen.Count;

        // GEÇMİŞ İKİ SONUÇ: hastanın bu başvurudan ÖNCEKİ onaylı sonuçları; kolonlar son iki gün (tüm tablo için ortak).
        var tetkikler = gorunen.Select(x => x.TetkikId).Distinct().ToArray();
        var gecmis = tetkikler.Length == 0 || baslik.HastaId == 0 ? [] : await b.ListeAsync("""
            select li.istem_tarihi::date, s.tetkik_id, coalesce(ls.deger_metin, ''), coalesce(ls.bayrak, ''), coalesce(ls.panik, 0)
              from public.lab_istem li
              join public.lab_istem_satir s on s.istem_id = li.id
              join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
             where li.taraf_id = @p0 and li.belge_id is distinct from @p1 and s.tetkik_id = any(@p2)
               and li.istem_tarihi < coalesce(@p3, now())
             order by li.istem_tarihi desc, ls.onay_zamani desc
            """, null, [baslik.HastaId, belgeId, tetkikler, baslik.Istem],
            o => (Gun: o.GetDateTime(0), Tetkik: o.GetInt32(1), Deger: o.GetString(2), Bayrak: o.GetString(3), Panik: o.GetInt16(4) == 1), iptal);
        var gunler = gecmis.Select(g => g.Gun).Distinct().OrderByDescending(g => g).Take(2).ToArray();
        object? Onceki(int tetkik, int sira)
        {
            if (sira >= gunler.Length) return null;
            var g = gecmis.FirstOrDefault(x => x.Gun == gunler[sira] && x.Tetkik == tetkik);
            return g.Tetkik == 0 ? null : new { deger = g.Deger, bayrak = g.Bayrak, panik = g.Panik };
        }

        // ONAYLAYAN UZMAN: bölümde en çok sonucu onaylayan (otomatik onayda boş olabilir).
        var onayId = gorunen.Where(x => x.OnayId > 0).GroupBy(x => x.OnayId).OrderByDescending(g => g.Count()).Select(g => g.Key).FirstOrDefault();
        var uzman = onayId == 0 ? null : await b.TekAsync("""
            select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(tp.brans::text, ''), coalesce(tp.tescil_no, '')
              from public.taraf t left join public.taraf_personel tp on tp.id = t.id where t.id = @p0
            """, null, [onayId], o => new { ad = o.GetString(0), brans = o.GetString(1), tescilNo = o.GetString(2) }, iptal);

        var ornekler = gorunen.Select(x => x.Barkod).Where(x => x.Length > 0).Distinct().ToArray();
        string Referans(decimal? alt, decimal? ust, string metin)
            => metin.Length > 0 ? metin
             : alt is not null && ust is not null ? $"{alt.Value.ToString("0.####", CultureInfo.GetCultureInfo("tr-TR"))} – {ust.Value.ToString("0.####", CultureInfo.GetCultureInfo("tr-TR"))}"
             : alt is not null ? $"> {alt.Value.ToString("0.####", CultureInfo.GetCultureInfo("tr-TR"))}"
             : ust is not null ? $"< {ust.Value.ToString("0.####", CultureInfo.GetCultureInfo("tr-TR"))}" : "";

        return new
        {
            bolum, bolumAd = LabBolumAdi(bolum),
            baslik = new
            {
                hasta = baslik.Hasta, tc = TcMaske(baslik.Tc), dogumTarihi = baslik.Dogum, cinsiyet = baslik.Cinsiyet,
                dosyaNo = baslik.DosyaNo, protokolNo = baslik.ProtokolNo, isteyen = baslik.Isteyen, kurum = baslik.Kurum,
                sube = baslik.Sube, gonderilecekYer = baslik.Yer,
                // RAPOR NO: protokol + örnek no. ÖRNEK NO protokolden bağımsız numune numarası (lab_numune.barkod).
                raporNo = string.Join('.', new[] { baslik.ProtokolNo, ornekler.FirstOrDefault() ?? "" }.Where(x => x.Length > 0)),
                ornekNo = string.Join(", ", ornekler),
                istemZamani = baslik.Istem, numuneAlma = gorunen.Min(x => x.Alim), numuneKabul = gorunen.Min(x => x.Kabul),
                onayZamani = gorunen.Max(x => x.Onay), basimZamani = Saat.An,
            },
            gecmisGunler = gunler,
            satirlar = gorunen.Select(x => new
            {
                kod = x.Kod, ad = x.Ad, sonuc = x.Sonuc, birim = x.Birim, bayrak = x.Bayrak, panik = x.Panik,
                referans = Referans(x.RefAlt, x.RefUst, x.RefMetin), kararNotu = x.Karar, yorum = x.Yorum, ornekNo = x.Barkod,
                yontem = x.Yontem, onceki1 = Onceki(x.TetkikId, 0), onceki2 = Onceki(x.TetkikId, 1),
            }),
            gizlenen, uzman,
        };
    }
}
