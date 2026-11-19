using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Gentegre.Cekirdek;

namespace Gentegre.Api.Servisler;

/// <summary>
/// RANDEVU SMS'LERİ — kayıtta BİLGİ, randevudan önce HATIRLATMA (Faz 0 · 399; 1382).
///
/// BİLGİ (1382, kullanıcı 19.11.2026: "randevu kartına SMS Gönder Check ekle.. default seçili olsun.. randevu alan
/// hastaya randevu bilgilerini içeren bir sms atalım.. şubeye özgü olsun mesaj.. istersek mesajı değiştirebilelim"):
/// kartta işaret (`randevu.sms_gonder`) varsa kayıtta hemen kuyruğa konur. Metin kartta elle değiştirildiyse o
/// (`sms_metni`, gönderilince temizlenir), yoksa ŞUBENİN bilgi şablonu. Aynı randevu saati için bir kez gider
/// (`sms_bilgi_baslangic`); saat değişirse yeni bilgi gider.
///
/// HATIRLATMA: kayıt anında `planlanan` zamanla kuyruğa konur (işçi zamanı gelmeden almaz). ŞUBE AYARI varsa
/// (randevu_sms_ayar) açık / saat / metin oradan; yoksa eski kurum geneli ayar (randevu.hatirlatma_acik / _saat,
/// şablon randevu.hatirlatma). Kartta "Hatırlatma SMS'i" işareti kaldırıldıysa (`sms_hatirlatma` = 0) konmaz.
/// HER KAYITTA TAZELENİR: bekleyen hatırlatma iptal edilip yenisi konur (saat değişmiş olabilir) - kuyruktaki BİLGİ
/// SMS'ine dokunulmaz. İptal / gelmedi / ertelendi durumunda yalnız iptal.
///
/// SESSİZ KALMA KURALI: telefon yoksa, ayar kapalıysa ya da zaman geçmişse kuyruğa satır konmaz (sebep günlüğe).
/// Randevu kaydı bu yüzden başarısız olmamalı; çağıran try/catch ile sarar.
///
/// SAAT ŞUBENİN DİLİMİNDE (1382): baslangic timestamptz (UTC) - mesaja şubenin yerel saati yazılır; eskiden UTC
/// olduğu gibi yazılıyordu (İstanbul'da 3 saat geri).
/// </summary>
public sealed class RandevuHatirlatmasi
{
    private readonly VeriKaynagi _veri;
    private readonly BildirimDeposu _bildirim;
    private readonly ILogger<RandevuHatirlatmasi> _gunluk;

    public RandevuHatirlatmasi(VeriKaynagi veri, BildirimDeposu bildirim,
                               ILogger<RandevuHatirlatmasi> gunluk)
    {
        _veri = veri;
        _bildirim = bildirim;
        _gunluk = gunluk;
    }

    /// <summary>Bildirim kaynağı: 4 = randevu (kuyruk `kaynak_tur`).</summary>
    private const short KaynakRandevu = 4;

    /// <summary>Gönderilmeyecek randevu durumları: 3 gelmedi · 4 iptal · 5 ertelendi (1119).</summary>
    private static readonly short[] KapaliDurumlar = [3, 4, 5];

    /// <summary>Şube şablonu boşsa kullanılan metinler. Değişkenler: <see cref="Degiskenler"/>.</summary>
    public const string VarsayilanBilgi =
        "Sayın {hasta}, {tarih} {gun} saat {saat} {bolum} randevunuz oluşturulmuştur. {sube} Tel: {telefon}";
    public const string VarsayilanHatirlatma =
        "Sayın {hasta}, {tarih} {gun} saat {saat} {bolum} randevunuzu hatırlatırız. Lütfen 15 dk önce geliniz. {sube} Tel: {telefon}";

    /// <summary>Şablonda kullanılabilen değişkenler (ayar ekranı listeler).</summary>
    public static readonly (string Ad, string Aciklama)[] Degiskenler =
    [
        ("hasta", "Hasta adı"), ("tarih", "Randevu tarihi"), ("gun", "Gün adı"), ("saat", "Randevu saati"),
        ("bolum", "Bölüm / poliklinik"), ("hekim", "Doktor"), ("sube", "Şube / kurum adı"),
        ("adres", "Şube adresi"), ("telefon", "Şube telefonu"),
    ];

    /// <summary>Şablonu doldurur; bilinmeyen {x} olduğu gibi kalır, fazla boşluk toplanır.</summary>
    public static string Doldur(string sablon, IReadOnlyDictionary<string, string> d)
    {
        var s = System.Text.RegularExpressions.Regex.Replace(sablon, @"\{([a-z_]+)\}",
            m => d.TryGetValue(m.Groups[1].Value, out var v) ? v : m.Value);
        return System.Text.RegularExpressions.Regex.Replace(s, @"\s{2,}", " ").Trim();
    }

    /// <summary>Şubenin SMS ayarı; satır yoksa null (eski kurum geneli hatırlatma geçerli).</summary>
    public sealed record SubeAyari(string BilgiSablon, bool HatirlatmaAcik, int HatirlatmaSaat, string HatirlatmaSablon,
                                   bool BilgiVarsayilan = true);

    public async Task<SubeAyari?> SubeAyariAsync(int subeId, CancellationToken iptal)
        => await _veri.TekAsync("""
            select bilgi_sablon, hatirlatma_acik, hatirlatma_saat, hatirlatma_sablon, bilgi_varsayilan
              from public.randevu_sms_ayar where sube_id = @p0
            """, new object?[] { subeId },
            o => new SubeAyari(o.GetString(0), o.GetInt16(1) == 1, o.GetInt16(2), o.GetString(3), o.GetInt16(4) == 1), iptal);

    /// <summary>Mesaj değişkenleri - randevu kaydından ya da kartın kaydedilmemiş alanlarından (önizleme).</summary>
    public async Task<(Dictionary<string, string> Degerler, string Telefon)> VeriAsync(
        int subeId, int? hastaId, DateTime baslangic, int? bolum, int? hekimId, CancellationToken iptal)
    {
        var v = await _veri.TekAsync("""
            select coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) from public.taraf t where t.id = @p1), ''),
                   coalesce((select t.cep_tel from public.taraf t where t.id = @p1), ''),
                   coalesce((select d.ad from public.v_departman_lookup d where d.id = @p2), ''),
                   coalesce((select public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120) from public.taraf h where h.id = @p3), ''),
                   coalesce(nullif(s.unvan, ''), s.ad, ''),
                   btrim(concat_ws(' ', nullif(s.adres, ''), nullif(s.ilce, ''), nullif(s.il, ''))),
                   coalesce(s.telefon, ''), coalesce(s.zaman_dilimi, '')
              from public.sube s where s.id = @p0
            """, new object?[] { subeId, hastaId ?? 0, bolum ?? 0, hekimId ?? 0 },
            o => new[] { o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetString(4), o.GetString(5),
                         o.GetString(6), o.GetString(7) }, iptal)
            ?? ["", "", "", "", "", "", "", ""];
        // Kayıttan UTC (timestamptz), karttan (önizleme) dilimsiz ŞUBE yerel saati gelir - ikisi de şubenin diliminde.
        var dilim = v[7].Length > 0 ? v[7] : null;
        var yerel = Saat.Yerel(baslangic.Kind == DateTimeKind.Utc ? baslangic : Saat.UtcYap(baslangic, dilim), dilim);
        var tr = System.Globalization.CultureInfo.GetCultureInfo("tr-TR");
        return (new Dictionary<string, string>
        {
            ["hasta"] = v[0], ["tarih"] = yerel.ToString("dd.MM.yyyy"), ["gun"] = yerel.ToString("dddd", tr),
            ["saat"] = yerel.ToString("HH:mm"), ["bolum"] = v[2], ["hekim"] = v[3], ["sube"] = v[4],
            ["adres"] = v[5], ["telefon"] = v[6],
        }, v[1]);
    }

    public async Task TazeleAsync(long randevuId, int kullaniciId, CancellationToken iptal)
    {
        // 1) BEKLEYEN HATIRLATMA iptal (saat değişmiş olabilir). BİLGİ SMS'i (randevu.bilgi) kuyrukta bekliyorsa kalır.
        await _veri.CalistirAsync("""
            update public.bildirim set durum = 5
             where kaynak_tur = @p0 and kaynak_id = @p1 and durum in (1, 4)
               and coalesce(sablon_id, 0) <> coalesce((select id from public.bildirim_sablon where kod = 'randevu.bilgi'), -1)
            """, new object?[] { KaynakRandevu, (int)randevuId }, iptal);

        var r = await _veri.TekAsync("""
            select r.baslangic, r.durum, coalesce(r.sube_id, 0), r.hasta_id, r.bolum, r.hekim_id,
                   coalesce(r.sms_gonder, 0), coalesce(r.sms_metni, ''), coalesce(r.sms_hatirlatma, 1), r.sms_bilgi_baslangic
              from public.randevu r where r.id = @p0
            """, new object?[] { (int)randevuId },
            o => new
            {
                Baslangic = o.GetDateTime(0), Durum = o.GetInt16(1), SubeId = o.GetInt32(2),
                HastaId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), Bolum = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                HekimId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                SmsGonder = o.GetInt16(6) == 1, SmsMetni = o.GetString(7), SmsHatirlatma = o.GetInt16(8) == 1,
                BilgiBaslangic = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
            }, iptal);

        if (r is null) return;
        if (KapaliDurumlar.Contains(r.Durum)) return;      // iptal/gelmedi: yalnız iptal
        if (Saat.AnOlarak(r.Baslangic) <= Saat.An) return; // geçmiş randevuya mesaj yok

        var (degerler, telefonHam) = await VeriAsync(r.SubeId, r.HastaId, r.Baslangic, r.Bolum, r.HekimId, iptal);
        var telefon = Rakamlar(telefonHam);
        if (telefon.Length < 10)
        {
            if (r.SmsGonder || r.SmsHatirlatma)
                _gunluk.LogInformation("Randevu {Id}: SMS kuyruğa konmadı - hastanın cep telefonu yok.", randevuId);
            return;
        }
        var ayar = r.SubeId > 0 ? await SubeAyariAsync(r.SubeId, iptal) : null;

        // 2) BİLGİ: işaretliyse ve bu randevu saati için daha önce gitmediyse.
        if (r.SmsGonder && r.BilgiBaslangic != r.Baslangic)
        {
            var metin = r.SmsMetni.Trim().Length > 0 ? r.SmsMetni.Trim()
                      : Doldur(ayar?.BilgiSablon is { Length: > 0 } b ? b : VarsayilanBilgi, degerler);
            await _bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                    SablonKodu: "randevu.bilgi", Kanal: null, Alici: telefon,
                    Degiskenler: new Dictionary<string, string> { ["metin"] = metin },
                    TarafId: r.HastaId, KaynakTur: KaynakRandevu, KaynakId: (int)randevuId, Oncelik: 4),
                kullaniciId, r.SubeId > 0 ? r.SubeId : null, iptal);
            await _veri.CalistirAsync("""
                update public.randevu set sms_bilgi_baslangic = baslangic, sms_metni = '' where id = @p0
                """, new object?[] { (int)randevuId }, iptal);
        }

        // 3) HATIRLATMA: şube ayarı varsa o, yoksa eski kurum geneli ayar. Kartta kaldırıldıysa yok.
        if (!r.SmsHatirlatma) return;
        bool acik; int saat; string sablonKod; Dictionary<string, string> hDegisken;
        if (ayar is not null)
        {
            acik = ayar.HatirlatmaAcik;
            saat = Math.Clamp(ayar.HatirlatmaSaat, 1, 168);
            sablonKod = "randevu.hatirlatma_sube";
            hDegisken = new() { ["metin"] = Doldur(ayar.HatirlatmaSablon is { Length: > 0 } h ? h : VarsayilanHatirlatma, degerler) };
        }
        else
        {
            // VARSAYILAN KAPALI (kullanici 08.10.2026): ayar satırı yoksa gönderilmez - SMS ücretli ve hastaya gider.
            acik = await AyarAsync("randevu.hatirlatma_acik", "0", iptal) == "1";
            saat = int.TryParse(await AyarAsync("randevu.hatirlatma_saat", "24", iptal), out var sa) ? Math.Clamp(sa, 1, 168) : 24;
            sablonKod = "randevu.hatirlatma";
            hDegisken = new()
            {
                ["hasta_ad"] = degerler["hasta"], ["tarih"] = $"{degerler["tarih"]} {degerler["saat"]}",
                ["bolum"] = degerler["bolum"], ["kurum"] = degerler["sube"],
            };
        }
        if (!acik) return;

        var planlanan = Saat.AnOlarak(r.Baslangic).AddHours(-saat);
        // Geçmiş zamana hatırlatma konmaz (aynı gün açılan randevuda "yarın" yerine anında giderdi); randevuya 2 saatten
        //   az kaldıysa hatırlatmanın anlamı yok.
        if (planlanan <= Saat.An || Saat.AnOlarak(r.Baslangic) <= Saat.An.AddHours(2)) return;

        await _bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                SablonKodu: sablonKod, Kanal: null, Alici: telefon, Degiskenler: hDegisken,
                TarafId: r.HastaId, KaynakTur: KaynakRandevu, KaynakId: (int)randevuId,
                Oncelik: 7,                        // hatırlatma acele değil
                Planlanan: planlanan),
            kullaniciId, r.SubeId > 0 ? r.SubeId : null, iptal);
    }

    /// <summary>
    /// ŞUBENİN GEÇERLİ HATIRLATMASI (kod inceleme 19.11.2026): şube ayarı varsa o; yoksa TazeleAsync'in kullandığı kurum
    /// geneli randevu.hatirlatma_acik / _saat. Ayar penceresi ve kart önizlemesi bunu gösterir - "kapalı" görünüp
    /// pencereyi kaydetmek kurum geneli açık hatırlatmayı o şubede sessizce kapatmasın.
    /// </summary>
    public async Task<(bool Acik, int Saat)> GecerliHatirlatmaAsync(SubeAyari? ayar, CancellationToken iptal)
    {
        if (ayar is not null) return (ayar.HatirlatmaAcik, ayar.HatirlatmaSaat);
        var acik = await AyarAsync("randevu.hatirlatma_acik", "0", iptal) == "1";
        var saat = int.TryParse(await AyarAsync("randevu.hatirlatma_saat", "24", iptal), out var sa) ? Math.Clamp(sa, 1, 168) : 24;
        return (acik, saat);
    }

    private async Task<string> AyarAsync(string anahtar, string varsayilan, CancellationToken iptal)
        => await _veri.TekDegerAsync<string>(
               "select deger from public.referans where anahtar = @p0",
               new object?[] { anahtar }, iptal) is { Length: > 0 } d ? d : varsayilan;

    /// <summary>Telefonu yalnız rakamlara indirger ("0 (555) 111 22 33" → "5551112233").</summary>
    public static string Rakamlar(string metin)
    {
        var s = new string(metin.Where(char.IsDigit).ToArray());
        if (s.StartsWith("90", StringComparison.Ordinal) && s.Length > 10) s = s[2..];
        return s.TrimStart('0');
    }
}
