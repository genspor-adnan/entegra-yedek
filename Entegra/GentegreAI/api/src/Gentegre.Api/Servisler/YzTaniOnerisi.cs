using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Gentegre.Api.Servisler.Yardim;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// YZ TANI ÖNERİSİ (kullanıcı: "ICD tanı arama ekranına YZ Önerisi butonu
/// ekle.. yapay zeka girilmiş bilgilerden hekime öneri olması amacıyla tanı
/// koymaya yardımcı olmalı.. yaş cinsiyet vb kullanılabilir ama kimlik no ad
/// soyad kullanılmaz").
///
/// <b>KARAR HEKİMİNDİR.</b> Çıktı yalnız ICD arama penceresinde bir öneri
/// listesidir; hiçbir tanı kendiliğinden yazılmaz.
///
/// <b>ANONİMLEŞTİRME SUNUCUDA.</b> Bağlam istemciden ALINMAZ - muayene
/// kaydından sunucu toplar, böylece ekrana ne gelirse gelsin modele giden
/// alanlar sabittir:
/// <list type="bullet">
/// <item>Giden: yaş (yıl; 2 yaş altı ay), cinsiyet, bölüm adı, şikâyet,
///   hikâye, muayene bulguları, son vital, muayenenin mevcut tanıları, kronik
///   tanılar, alerji ve aktif ilaç ETKEN maddeleri, değerlendirme/plan.</item>
/// <item>Gitmeyen: ad, soyad, TC kimlik / pasaport no, doğum tarihi (yalnız
///   yaş), adres, telefon, protokol / muayene numarası, hekim adı.</item>
/// <item>Serbest metinler iki kez süzülür: <see cref="PiiMaske"/> (kimlik no,
///   telefon, e-posta, IBAN, uzun sayılar) ve hastanın / anne-babasının /
///   hekimin ADLARI metinden sözcük olarak silinir ([kişi]).</item>
/// </list>
///
/// <b>DOĞRULAMA.</b> Modelin önerdiği her kod ICD kataloğunda (aktif) aranır;
/// katalogda olmayan kod atılır, ad katalogdan yazılır (modelin yazdığı ad
/// kullanılmaz). Kontör rehberle ortak (<see cref="RehberServisi.KontorDurumAsync"/>).
/// </summary>
public static partial class YzTaniOnerisi
{
    public const string SistemYonergesi = """
        Sen bir hastane bilgi sisteminde HEKİME yardımcı klinik karar destek aracısın.
        Sana anonimleştirilmiş bir poliklinik muayenesi verilecek (yaş, cinsiyet,
        bölüm, şikâyet, hikâye, bulgular, vital, mevcut tanılar, kronik hastalıklar,
        alerjiler, kullandığı ilaçlar).

        Görevin: hekimin değerlendirmesi için OLASI TANILARI ICD-10 kodlarıyla önermek.
        - En fazla 6 öneri, en olası önce. Ayırıcı tanıda atlanmaması gereken ciddi
          durum varsa onu da ekle ve "kirmiziBayrak" alanında belirt.
        - Kod Türkiye'de kullanılan ICD-10 (ör. "J06.9", "I10"); uydurma kod yazma.
        - Mevcut tanılarda zaten olan kodu tekrar önerme.
        - Yaş ve cinsiyete uymayan tanı önerme.
        - "gerekce": verilen bulgulardan hangisine dayandığını 25 sözcüğü geçmeden yaz.
        - "kirmiziBayrak": atlanmaması gereken ciddi durumu ve NEDEN düşünüldüğünü kısa bir
          Türkçe cümleyle yaz (yalnız kod yazma); yoksa boş bırak.
        - Bilgi yetersizse az öneri ver ve "eksikBilgi" alanında ne sorulmalı yaz.
        - Tedavi, ilaç ya da doz ÖNERME; yalnız tanı.
        Kesin tanı koymadığını hekim bilir; uyarı cümlesi yazma.

        YALNIZ şu JSON'u döndür, başka metin yazma:
        {"oneriler":[{"icd":"J06.9","olasilik":"yuksek|orta|dusuk","gerekce":"..."}],
         "kirmiziBayrak":"", "eksikBilgi":""}
        """;

    /// <summary>Modelden sonra doğrulanmış tek öneri.</summary>
    public sealed record Oneri(string Kod, string Ad, string Olasilik, string Gerekce);

    /// <summary>Ekrana dönen sonuç.</summary>
    public sealed record Sonuc(IReadOnlyList<Oneri> Oneriler, string KirmiziBayrak, string EksikBilgi,
                               int AtilanKod, string Model);

    /// <summary>Muayeneden toplanan ham bağlam (anonimleştirmeden ÖNCE).</summary>
    public sealed record Baglam(
        int? YasYil, int? YasAy, short Cinsiyet, string Bolum,
        string Sikayet, string Hikaye, string Bulgular, string Karar, string Vital,
        IReadOnlyList<string> Tanilar, IReadOnlyList<string> Kronik,
        IReadOnlyList<string> Alerji, IReadOnlyList<string> Ilac,
        IReadOnlyList<string> SilinecekAdlar,
        IReadOnlyList<string>? Istemler = null, IReadOnlyList<string>? Recete = null)
    {
        /// <summary>Öneri için en az bir klinik metin var mı?</summary>
        public bool Yeterli => (Sikayet + Hikaye + Bulgular).Trim().Length > 0;
    }

    [GeneratedRegex(@"[\p{L}]{2,}")]
    private static partial Regex Sozcuk();

    /// <summary>
    /// Serbest metni modele gidecek hâle getirir: PiiMaske + verilen adların
    /// sözcük olarak silinmesi (büyük/küçük harf ve Türkçe i/İ duyarsız).
    /// </summary>
    public static string Anonimlestir(string? metin, IReadOnlyCollection<string> adlar)
    {
        var m = PiiMaske.Uygula(metin);
        if (m.Length == 0 || adlar.Count == 0) return m;
        var tr = CultureInfo.GetCultureInfo("tr-TR");
        var kume = new HashSet<string>(
            adlar.SelectMany(a => Sozcuk().Matches(a ?? "").Select(x => x.Value.ToLower(tr))), StringComparer.Ordinal);
        if (kume.Count == 0) return m;
        return Sozcuk().Replace(m, x => kume.Contains(x.Value.ToLower(tr)) ? "[kişi]" : x.Value);
    }

    /// <summary>Modele giden kullanıcı metni. Kimlik alanı YOKTUR; serbest metinler anonim.</summary>
    public static string KullaniciMetni(Baglam b)
    {
        string A(string s) => Anonimlestir(s, b.SilinecekAdlar).Trim();
        string L(IEnumerable<string> l) { var x = l.Select(A).Where(s => s.Length > 0).ToList();
                                          return x.Count == 0 ? "yok" : string.Join("; ", x); }
        var yas = b.YasYil is >= 2 ? $"{b.YasYil} yaş" : b.YasAy is not null ? $"{b.YasAy} aylık" : "bilinmiyor";
        var cins = b.Cinsiyet switch { 1 => "Erkek", 2 => "Kadın", _ => "belirtilmemiş" };
        var sb = new StringBuilder();
        sb.AppendLine($"Yaş: {yas}");
        sb.AppendLine($"Cinsiyet: {cins}");
        sb.AppendLine($"Bölüm: {A(b.Bolum)}");
        sb.AppendLine($"Şikâyet: {Bos(A(b.Sikayet))}");
        sb.AppendLine($"Hikâye: {Bos(A(b.Hikaye))}");
        sb.AppendLine($"Muayene bulguları: {Bos(A(b.Bulgular))}");
        sb.AppendLine($"Vital: {Bos(b.Vital)}");
        sb.AppendLine($"Değerlendirme / plan notu: {Bos(A(b.Karar))}");
        sb.AppendLine($"Bu muayenedeki mevcut tanılar: {L(b.Tanilar)}");
        sb.AppendLine($"Kronik hastalıklar: {L(b.Kronik)}");
        sb.AppendLine($"Alerjiler: {L(b.Alerji)}");
        sb.AppendLine($"Kullandığı ilaçlar (etken madde): {L(b.Ilac)}");
        if (b.Istemler is not null) sb.AppendLine($"Bu muayenede istenmiş tetkikler: {L(b.Istemler)}");
        if (b.Recete is not null) sb.AppendLine($"Bu muayenede reçeteye yazılmış ilaçlar: {L(b.Recete)}");
        return sb.ToString();
    }

    private static string Bos(string s) => s.Length == 0 ? "girilmemiş" : s;

    /// <summary>Muayene kaydından bağlamı toplar. Kayıt yoksa null.</summary>
    public static async Task<Baglam?> Topla(NpgsqlConnection b, int muayeneId, CancellationToken iptal)
    {
        var m = await b.TekAsync("""
            select h.dogum_tarihi, coalesce(h.cinsiyet, 0),
                   coalesce((select d.ad from public.departman d where d.id = m.bolum_id), ''),
                   coalesce(m.sikayet, ''), coalesce(m.hikaye, ''), coalesce(m.karar, ''),
                   coalesce(t.ad, ''), coalesce(t.soyad, ''), coalesce(t.unvan, ''),
                   coalesce(h.ana_adi, ''), coalesce(h.baba_adi, ''),
                   coalesce(p.ad, ''), coalesce(p.soyad, ''), m.taraf_id
              from public.muayene m
              join public.taraf t on t.id = m.taraf_id
              left join public.taraf_hasta h on h.id = m.taraf_id
              left join public.taraf p on p.id = m.personel_id
             where m.id = @p0
            """, null, [muayeneId], o => new
            {
                Dogum = o.IsDBNull(0) ? (DateTime?)null : o.GetDateTime(0),
                Cinsiyet = o.GetInt16(1), Bolum = o.GetString(2),
                Sikayet = o.GetString(3), Hikaye = o.GetString(4), Karar = o.GetString(5),
                Adlar = new[] { o.GetString(6), o.GetString(7), o.GetString(8), o.GetString(9),
                                o.GetString(10), o.GetString(11), o.GetString(12) },
                Hasta = o.GetInt32(13),
            }, iptal);
        if (m is null) return null;

        int? yil = null, ay = null;
        if (m.Dogum is { } d)
        {
            var bugun = DateTime.Today;
            var aylar = (bugun.Year - d.Year) * 12 + bugun.Month - d.Month - (bugun.Day < d.Day ? 1 : 0);
            yil = aylar / 12; ay = aylar;
        }

        var bulgular = await b.ListeAsync("""
            select coalesce(nullif(a.grup, ''), '') || case when a.grup <> '' then ' - ' else '' end || a.ad,
                   case when b.normal = 1 and a.normal_metni <> '' then a.normal_metni
                        when b.normal = 1 then 'normal'
                        else coalesce(nullif(btrim(b.deger_metin), ''),
                                      case when b.deger_sayi is null then '' else b.deger_sayi::text || ' ' || a.birim end) end,
                   case b.taraf when 1 then 'sağ' when 2 then 'sol' when 3 then 'bilateral' else '' end
              from public.muayene_bulgu b
              join public.muayene_sablon_alan a on a.id = b.sablon_alan_id
             where b.muayene_id = @p0
             order by a.sira, a.id
            """, null, [muayeneId], o => (Ad: o.GetString(0), Deger: o.GetString(1), Taraf: o.GetString(2)), iptal);
        var bulguMetni = string.Join("; ", bulgular.Where(x => x.Deger.Trim().Length > 0)
            .Select(x => x.Taraf.Length > 0 ? $"{x.Ad} ({x.Taraf}): {x.Deger}" : $"{x.Ad}: {x.Deger}"));
        if (bulguMetni.Length == 0)
            bulguMetni = await b.TekDegerAsync<string>(
                "select coalesce(bulgu_ozet, '') from public.muayene where id = @p0", null, [muayeneId], iptal) ?? "";

        var vital = await b.TekAsync("""
            select concat_ws(', ',
                     case when v.sistolik is not null then 'TA ' || v.sistolik || '/' || coalesce(v.diyastolik::text, '?') || ' mmHg' end,
                     case when v.nabiz is not null then 'nabız ' || v.nabiz || '/dk' end,
                     case when v.ates is not null then 'ateş ' || v.ates || ' °C' end,
                     case when v.spo2 is not null then 'SpO2 %' || v.spo2 end,
                     case when v.solunum is not null then 'solunum ' || v.solunum || '/dk' end,
                     case when v.agri_vas is not null then 'ağrı VAS ' || v.agri_vas end,
                     case when v.bki is not null then 'BKİ ' || v.bki end,
                     case when v.glukoz_parmak is not null then 'parmak glukoz ' || v.glukoz_parmak end)
              from public.muayene_vital v where v.muayene_id = @p0
             order by v.zaman desc nulls last, v.id desc limit 1
            """, null, [muayeneId], o => o.IsDBNull(0) ? "" : o.GetString(0), iptal) ?? "";

        var tanilar = await b.ListeAsync("""
            select t.icd_kod || ' ' || coalesce(i.ad, '')
              from public.tani t left join public.icd i on i.kod = t.icd_kod
             where t.muayene_id = @p0 order by t.tur, t.sira, t.id
            """, null, [muayeneId], o => o.GetString(0), iptal);
        var kronik = await b.ListeAsync("""
            select k.icd_kod || ' ' || coalesce(nullif(k.tani_ad, ''), i.ad, '')
              from public.hasta_kronik_tani k left join public.icd i on i.kod = k.icd_kod
             where k.hasta_id = @p0 and k.durum <> 3 order by k.id
            """, null, [m.Hasta], o => o.GetString(0), iptal);
        var alerji = await b.ListeAsync("""
            select coalesce(nullif(a.etken_madde, ''), a.etken)
                   || case when a.reaksiyon <> '' then ' (' || a.reaksiyon || ')' else '' end
              from public.hasta_alerji a where a.hasta_id = @p0 and a.aktif = 1 order by a.id
            """, null, [m.Hasta], o => o.GetString(0), iptal);
        var ilac = await b.ListeAsync("""
            select coalesce(nullif(i.etken_madde, ''), i.ilac_ad)
              from public.hasta_ilac i where i.hasta_id = @p0 and i.aktif = 1 order by i.id
            """, null, [m.Hasta], o => o.GetString(0), iptal);

        // İSTEM ve REÇETE (tetkik / ilaç önerisi aynı şeyi tekrar önermesin).
        var istemler = await b.ListeAsync("""
            select x.ad from (
              select ls.ad, s.id, ls.sira
                from public.muayene_istem s
                join public.lab_istem_satir ls on ls.istem_id = s.hedef_id
               where s.muayene_id = @p0 and s.hedef_tablo = 'lab_istem'
              union all
              select coalesce(h.ad, ''), s.id, 0
                from public.muayene_istem s
                join public.radyoloji_istem r on r.id = s.hedef_id
                left join public.hizmet h on h.id = r.hizmet_id
               where s.muayene_id = @p0 and s.hedef_tablo = 'radyoloji_istem') x
             where x.ad <> '' order by x.id, x.sira
            """, null, [muayeneId], o => o.GetString(0), iptal);
        var recete = await b.ListeAsync("""
            select coalesce(nullif(i.etken_madde, ''), rs.ilac_ad)
              from public.recete r join public.recete_satir rs on rs.recete_id = r.id
              left join public.ilac i on i.barkod = rs.ilac_barkod
             where r.muayene_id = @p0 order by rs.id
            """, null, [muayeneId], o => o.GetString(0), iptal);

        return new Baglam(yil, ay, m.Cinsiyet, m.Bolum, m.Sikayet, m.Hikaye, bulguMetni, m.Karar, vital,
                          tanilar, kronik, alerji, ilac,
                          m.Adlar.Where(a => a.Trim().Length > 0).ToList(), istemler, recete);
    }

    private sealed record HamOneri(string? icd, string? olasilik, string? gerekce);
    private sealed record HamYanit(List<HamOneri>? oneriler, string? kirmiziBayrak, string? eksikBilgi);

    /// <summary>
    /// Model metnini çözer ve kodları KATALOGLA doğrular. <paramref name="katalog"/>
    /// geçerli kod → katalog adı; bulunamayan kod atılır (sayısı döner).
    /// </summary>
    public static (List<Oneri> Oneriler, string KirmiziBayrak, string EksikBilgi, int Atilan) Coz(
        string metin, Func<string, string?> katalog, IReadOnlyCollection<string> mevcut)
    {
        var bas = metin.IndexOf('{');
        var son = metin.LastIndexOf('}');
        if (bas < 0 || son <= bas) return ([], "", "", 0);
        HamYanit? h;
        try
        {
            h = JsonSerializer.Deserialize<HamYanit>(metin[bas..(son + 1)],
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch (JsonException) { return ([], "", "", 0); }
        if (h is null) return ([], "", "", 0);

        var liste = new List<Oneri>();
        var atilan = 0;
        foreach (var o in (h.oneriler ?? []).Take(8))
        {
            var kod = (o.icd ?? "").Trim().ToUpperInvariant();
            var ad = kod.Length == 0 ? null : katalog(kod);
            if (ad is null) { atilan++; continue; }
            if (mevcut.Contains(kod) || liste.Any(x => x.Kod == kod)) continue;
            var olas = (o.olasilik ?? "").Trim().ToLowerInvariant() switch
            {
                "yuksek" or "yüksek" => "yuksek", "dusuk" or "düşük" => "dusuk", _ => "orta",
            };
            var gerekce = (o.gerekce ?? "").Trim();
            if (gerekce.Length > 300) gerekce = gerekce[..300];
            liste.Add(new Oneri(kod, ad, olas, gerekce));
        }
        string Kirp(string? s) { s = (s ?? "").Trim(); return s.Length > 300 ? s[..300] : s; }
        return (liste, Kirp(h.kirmiziBayrak), Kirp(h.eksikBilgi), atilan);
    }
}
