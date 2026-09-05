using System.Globalization;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// KART OKUMA: kartin kendisi, detay tablolari ve acilir listelerin (kod-ad,
/// kod_liste, kod tablosu) doldurulmasi. Yazma tarafi KartDeposu.cs'te.
/// </summary>
public sealed partial class KartDeposu
{

    // ============================================================== OKUMA ====
    public async Task<(IDictionary<string, object?> Kart, string Surum)?> OkuAsync(
        KartTanimi tanim, long id, IReadOnlyList<KartAlani> alanlar,
        IReadOnlyList<int>? kapsam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await OkuAsync(baglanti, null, tanim, id, alanlar, kapsam, iptal);
    }

    private async Task<(IDictionary<string, object?> Kart, string Surum)?> OkuAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, KartTanimi tanim, long id,
        IReadOnlyList<KartAlani> alanlar, IReadOnlyList<int>? kapsam, CancellationToken iptal)
    {
        var secim = string.Join(", ", alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
        var sql = new StringBuilder()
            .Append("select ").Append(secim).Append(", xmin::text as \"surum\"")
            .Append(" from ").Append(tanim.Tablo)
            .Append(" where ").Append(tanim.IdKolonu).Append(" = @p0")
            .ToString();

        if (!string.IsNullOrWhiteSpace(tanim.SabitKosul)) sql += $" and ({tanim.SabitKosul})";
        if (kapsam is { Count: > 0 } && tanim.KapsamKolonu is { } kk)
            sql += $" and {kk} = any(@p1)";

        await using var komut = baglanti.Komut(sql, islem,
            id);
        if (kapsam is { Count: > 0 } && tanim.KapsamKolonu is not null)
            komut.Parameters.AddWithValue("p1", kapsam.ToArray());

        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        if (!await okuyucu.ReadAsync(iptal)) return null;

        var kart = new Dictionary<string, object?>(StringComparer.Ordinal);
        string surum = "";
        for (var i = 0; i < okuyucu.FieldCount; i++)
        {
            var ad = okuyucu.GetName(i);
            var deger = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
            if (ad == "surum") surum = deger?.ToString() ?? "";
            else kart[ad] = deger;
        }

        return (kart, surum);
    }

    public async Task<Dictionary<string, List<IDictionary<string, object?>>>> DetaylarAsync(
        KartTanimi tanim, long id, CancellationToken iptal = default)
    {
        var sonuc = new Dictionary<string, List<IDictionary<string, object?>>>(StringComparer.Ordinal);
        if (tanim.Detaylar is not { Count: > 0 }) return sonuc;

        await using var baglanti = await _veri.AcAsync(iptal);

        foreach (var detay in tanim.Detaylar)
        {
            var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
            var sql = $"select {secim} from {detay.Tablo} where {detay.UstKolon} = @p0 order by {detay.Sirala}";

            await using var komut = baglanti.Komut(sql, null,
                id);

            var satirlar = new List<IDictionary<string, object?>>();
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal))
            {
                var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
                for (var i = 0; i < okuyucu.FieldCount; i++)
                    satir[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
                satirlar.Add(satir);
            }
            sonuc[detay.Ad] = satirlar;
        }

        return sonuc;
    }

    /// <summary>
    /// Kartta KULLANILAN kod degerlerinin adlarini cozer (API §3.1 "kodAd").
    /// Sabit listeler katalogda, digerleri kod_liste / kod_deger tablosunda.
    /// </summary>
    public async Task<Dictionary<string, IDictionary<string, string>>> KodAdAsync(
        KartTanimi tanim, IDictionary<string, object?> kart, CancellationToken iptal = default)
    {
        var sonuc = new Dictionary<string, IDictionary<string, string>>(StringComparer.Ordinal);

        foreach (var alan in tanim.Alanlar.Where(a => a.Tip == "kod"))
        {
            if (!kart.TryGetValue(alan.Ad, out var deger) || deger is null) continue;
            var anahtar = deger.ToString() ?? "";

            if (alan.SabitKodlar is { } sabit)
            {
                if (sabit.TryGetValue(anahtar, out var ad))
                    sonuc[alan.Ad] = new Dictionary<string, string> { [anahtar] = ad };
                continue;
            }

            if (alan.KodTablosu is { } tablo)
            {
                var ad3 = await _veri.TekDegerAsync<string>(
                    $"select ad from {KodTablosuDogrula(tablo)} where id = @p0 limit 1",
                    new object?[] { Convert.ToInt32(deger) }, iptal);
                if (!string.IsNullOrEmpty(ad3))
                    sonuc[alan.Ad] = new Dictionary<string, string> { [anahtar] = ad3 };
                continue;
            }

            if (alan.KodListesi is null) continue;

            var ad2 = await _veri.TekDegerAsync<string>("""
                select kd.ad from public.kod_deger kd
                  join public.kod_liste kl on kl.id = kd.liste_id
                 where kl.kod = @p0 and kd.deger = @p1
                 limit 1
                """, new object?[] { alan.KodListesi, Convert.ToInt32(deger) }, iptal);

            if (!string.IsNullOrEmpty(ad2))
                sonuc[alan.Ad] = new Dictionary<string, string> { [anahtar] = ad2 };
        }

        return sonuc;
    }

    /// <summary>
    /// KodListesi alaninin TAM secenek listesi (kod_liste/kod_deger) - kodAd yalniz
    /// kartta KULLANILAN tek degeri cozer, bu butun secilebilir listeyi doner.
    /// </summary>
    public async Task<Dictionary<string, string>> KodListesiSecenekleriAsync(
        string kodListesi, CancellationToken iptal = default)
        => (await _veri.ListeAsync("""
                select kd.deger, kd.ad from public.kod_deger kd
                  join public.kod_liste kl on kl.id = kd.liste_id
                 where kl.kod = @p0 and kd.aktif = 1
                 order by kd.sira
                """, new object?[] { kodListesi },
                r => (Deger: r.GetInt32(0), Ad: r.GetString(1)), iptal))
            .ToDictionary(x => x.Deger.ToString(CultureInfo.InvariantCulture), x => x.Ad, StringComparer.Ordinal);

    // "public.kategori" gibi kendi tablosu olan secim kaynaklari - katalogda SABIT
    //   (kullanicidan gelmez), yine de savunma amacli whitelist'e karsi dogrulanir.
    private static readonly HashSet<string> KodTablosuBeyazListe =
        new(StringComparer.Ordinal) {
            "public.kategori", "public.v_cari_lookup", "public.rol", "public.sube", "public.v_personel_lookup",
            "public.v_sube_baz_lookup",
            // Randevu (243): hasta secimi.
            "public.v_hasta_lookup",
            // Anlasmali kurum (249): hasta policesinde odeyen, kurum sozlesmesi
            //   satirinda kategori secimi.
            "public.v_kurum_lookup", "public.v_kategori_lookup",
            "public.v_tahsilat_turu_lookup",
            // Departman/bolum (251): personel kartinda tum departmanlar, randevu
            //   kartinda yalniz randevu verilebilen bolumler.
            "public.v_departman_lookup", "public.v_randevu_bolum_lookup",
            // Personel gorevi (255) - departmana bagli combo.
            "public.v_gorev_lookup",
            // Randevu verilebilir personel (252) - randevu kartindaki hekim.
            "public.v_hekim_lookup",
            // Kampanya (268) - kurum sozlesmesinde secilir.
            "public.v_kampanya_lookup",
            // RADYOLOJI (283/286): cihaz, tetkik (yalniz radyoloji hizmetleri)
            //   ve istem hekimi (ic + dis).
            "public.v_rad_cihaz_lookup", "public.v_rad_tetkik_lookup",
            "public.v_rad_hekim_lookup",
            // Randevunun CIHAZ kaynagi (316) - radyolojide randevu cihaza verilir.
            "public.v_radyoloji_cihaz_lookup",
            // Kasa alt sistemi (071/074). Hepsi "id, ad, aktif" kolonlu gorunum -
            //   hizmet/masraf/proje "durum" kullandigi icin gorunumle uyarlandi.
            "public.v_hesap_lookup", "public.v_proje_lookup", "public.v_hesap_plani_lookup",
            // Kasa atamasi (197): Ana Kasa + personel tek listede.
            "public.v_hesap_atama_lookup",
            "public.v_masraf_lookup", "public.v_hizmet_lookup", "public.v_masraf_merkezi_lookup",
            // Banka tanimlari (109) - cek/senet ve hesap kartlarindaki secim.
            "public.v_banka_lookup", "public.v_banka_sube_lookup",
            // ÜTS mensei ulkesi (119), firsat urun satirinda stok secimi (121).
            "public.v_ulke_lookup", "public.v_stok_lookup",
            // Numaralama (152) - dort gridin tur secim listeleri.
            "public.v_numara_turu_satis", "public.v_numara_turu_alis",
            // e-Belge entegrator secimi (171) - firma/sube kartinda.
            "public.v_ebelge_entegrator_lookup",
            "public.v_numara_turu_tahsilat", "public.v_numara_turu_odeme",
            // Kayit kabul numaralari (358): hasta dosya no + basvuru protokol no.
            //   Beyaz listede olmayinca kart 500 veriyordu ("Bilinmeyen kod tablosu")
            //   ve numara satiri cift tikla acilamiyordu.
            "public.v_numara_turu_kimlik",
            // Prim plani rol combosu (362) - rolun yaninda isaretli kisi sayisi.
            "public.v_prim_rol_lookup",
            // Prim plani "Prim Alanlar" sekmesi (375): prim rolu ISARETLI
            //   kisiler. Beyaz listeye eklenmedigi icin kart hic acilmadi
            //   ("Bilinmeyen kod tablosu" -> 500) - 358'deki ayni tuzak.
            "public.v_prim_taraf_lookup",
            // e-Belge seri kurallari (156).
            "public.v_ebelge_turu_lookup", "public.v_kullanici_lookup",
            "public.v_ebelge_yon_lookup",
            // Fiyat listesi (201) - taban liste secimi (kart + satir ezmesi).
            "public.v_fiyat_listesi_lookup",
            // Yon bazli: cari kartinda satis alani alis listesini gostermemeli (204).
            "public.v_fiyat_listesi_satis_lookup", "public.v_fiyat_listesi_alis_lookup",
            // Muayene v1 (409/411): ICD-10 tani secici, muayene sablonu ve
            //   sablon alani. Beyaz listeye eklemeden kart HIC ACILMAZ
            //   ("Bilinmeyen kod tablosu" -> 500) - 358 ve 375'teki ayni tuzak.
            "public.v_icd_lookup",
            "public.v_muayene_sablon_lookup", "public.v_muayene_sablon_alan_lookup",
            // Dokuman v1 (419): belge turu ve klasor secici.
            "public.v_dokuman_turu_lookup", "public.v_dokuman_klasor_lookup",
        };

    private static string KodTablosuDogrula(string tablo)
        => KodTablosuBeyazListe.Contains(tablo)
            ? tablo
            : throw new InvalidOperationException($"Bilinmeyen kod tablosu: {tablo}");

    /// <summary>
    /// KodTablosu alaninin TAM secenek listesi (form dropdown'u icin - kodAd yalniz
    /// kartta KULLANILAN tek degeri cozer, bu ise butun secilebilir listeyi doner).
    /// </summary>
    public async Task<Dictionary<string, string>> KodTablosuSecenekleriAsync(
        string tablo, CancellationToken iptal = default)
        => (await _veri.ListeAsync(
                // id = 0 satiri ("Kendisi" gibi sabit secenekler) alfabetik
                //   siraya girmez, HEP basta durur (227).
                $"select id, ad from {KodTablosuDogrula(tablo)} where aktif = 1 " +
                "order by case when id = 0 then 0 else 1 end, ad",
                null, r => (Id: r.GetInt32(0), Ad: r.GetString(1)), iptal))
            .ToDictionary(x => x.Id.ToString(CultureInfo.InvariantCulture), x => x.Ad, StringComparer.Ordinal);

    /// <summary>Yerel para birimi (ayar genel.yerel_para) - kart metasina eklenir.</summary>
    public async Task<string> YerelParaAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await AyarDeposu.MetinAsync(baglanti, null, "genel.yerel_para", "TL", iptal);
    }

    /// <summary>
    /// Urun modu (referans genel.urun_modu): 1 Gentegre AI (ERP),
    /// 2 GenoTIP AI (HBYS). Kart metasi bazi secenekleri moda gore suzuyor
    /// (or. saglik entegrasyonlari ERP kurulumunda listelenmez).
    /// </summary>
    public async Task<int> UrunModuAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        // Varsayilan (1 = ERP) AyarDeposu.Varsayilan sozlugunden gelir.
        return await AyarDeposu.SayiAsync(baglanti, null, "genel.urun_modu", iptal);
    }

    /// <summary>
    /// DOVIZ UCGENI (katalogdaki DovizKurali): kur ve yerel karsilik SUNUCUDA
    /// belirlenir.
    ///
    ///  - Yerel para (genel.yerel_para) secildiyse kur 1'e sabitlenir: "TL kayit,
    ///    kur 41" gibi bir sey olusamaz.
    ///  - Yabanci para ve kur bos/sifirsa kur 1 kabul edilir; kuru DOLDURMAK
    ///    arayuzun isi (tarih kurunu cagirir), sunucu yalniz tutarliligi korur.
    ///  - Yerel tutar = tutar x kur, her zaman yeniden hesaplanir - istemciden
    ///    gelen yerel tutara guvenilmez (API §3.2).
    ///
    /// Kismi guncellemede eksik degerler mevcut kayittan tamamlanir.
    /// </summary>
    private static async Task DovizHesaplaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, KartTanimi tanim,
        IDictionary<string, object?> degerler, IDictionary<string, object?>? mevcut,
        CancellationToken iptal)
    {
        if (tanim.Doviz is not { } d) return;

        // Guncellemede ucgenin hicbir alani gelmediyse dokunma (baska bir alan
        //   degistiriliyor demektir; kur/tutar aynen kalir).
        if (mevcut is not null &&
            !degerler.ContainsKey(d.CinsAlani) &&
            !degerler.ContainsKey(d.KurAlani) &&
            !degerler.ContainsKey(d.TutarAlani)) return;

        object? Al(string ad)
            => degerler.TryGetValue(ad, out var v) && v is not null ? v
             : mevcut is not null && mevcut.TryGetValue(ad, out var m) ? m : null;

        var yerelPara = await AyarDeposu.MetinAsync(baglanti, islem, "genel.yerel_para", "TL", iptal);
        var cins = Al(d.CinsAlani)?.ToString() ?? "";
        var kur = Ondalik(Al(d.KurAlani));

        if (cins.Length == 0 || string.Equals(cins, yerelPara, StringComparison.OrdinalIgnoreCase) || kur <= 0)
            kur = 1m;

        if (tanim.Alan(d.KurAlani) is not null) degerler[d.KurAlani] = kur;
        if (tanim.Alan(d.YerelAlani) is not null)
            degerler[d.YerelAlani] = decimal.Round(Ondalik(Al(d.TutarAlani)) * kur, 4);
    }

    private static decimal Ondalik(object? deger) => deger switch
    {
        null => 0m,
        decimal d => d,
        string s when decimal.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var p) => p,
        IConvertible c => Convert.ToDecimal(c, CultureInfo.InvariantCulture),
        _ => 0m
    };

    /// <summary>
    /// BAGLI secim listesinin ust bagi: secenek id -> ust id (or. sube -> banka).
    /// Gorunumun <c>ust_id</c> kolonu vardir; arayuz seceneklerini buna gore suzer.
    /// Ust'u bos olan satir hic donmez - suzulemeyecegi icin listede de yeri yok.
    /// </summary>
    public async Task<Dictionary<string, string>> KodTablosuUstAsync(
        string tablo, CancellationToken iptal = default)
        => (await _veri.ListeAsync(
                $"select id, ust_id from {KodTablosuDogrula(tablo)} where aktif = 1 and ust_id is not null",
                null, r => (Id: r.GetInt32(0), Ust: r.GetInt32(1)), iptal))
            .ToDictionary(x => x.Id.ToString(CultureInfo.InvariantCulture),
                          x => x.Ust.ToString(CultureInfo.InvariantCulture), StringComparer.Ordinal);
}
