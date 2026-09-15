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

    public async Task<(Dictionary<string, List<IDictionary<string, object?>>> Satirlar,
                       Dictionary<string, int> Toplam)> DetaylarAsync(
        KartTanimi tanim, long id, CancellationToken iptal = default)
    {
        var sonuc = new Dictionary<string, List<IDictionary<string, object?>>>(StringComparer.Ordinal);
        var toplam = new Dictionary<string, int>(StringComparer.Ordinal);
        if (tanim.Detaylar is not { Count: > 0 }) return (sonuc, toplam);

        await using var baglanti = await _veri.AcAsync(iptal);

        foreach (var detay in tanim.Detaylar)
        {
            // SAYFALI DETAY (525): kartla yalniz ilk sayfa gelir. Fiyat
            //   listesi satiri 14 bine cikinca kart yaniti 4 MB oluyor,
            //   tarayici o kadar satiri cizerken kilitleniyordu.
            // Varsayilan cip kartin ILK sayfasina da uygulanir (531).
            var ilkSuzgec = detay.VarsayilanCip is null
                ? null : new DetaySuzgeci(Cip: detay.VarsayilanCip);
            sonuc[detay.Ad] = await DetaySayfasiAsync(baglanti, detay, id, 1,
                                                      detay.SayfaBoyu, ilkSuzgec, iptal);
            if (detay.SayfaBoyu > 0)
                toplam[detay.Ad] = await DetayAdediAsync(baglanti, detay, id, ilkSuzgec, iptal);
        }

        return (sonuc, toplam);
    }

    /// <summary>
    /// Tek detayin BIR SAYFASI (525). <paramref name="boyut"/> 0 ise sinir
    /// yok - sayfasiz detaylarin bugunku davranisi budur.
    /// </summary>
    public async Task<List<IDictionary<string, object?>>> DetaySayfasiAsync(
        KartTanimi tanim, string detayAd, long id, int sayfa, int boyut,
        DetaySuzgeci? suzgec = null, CancellationToken iptal = default)
    {
        var detay = (tanim.Detaylar ?? Array.Empty<DetayTanimi>())
            .FirstOrDefault(d => string.Equals(d.Ad, detayAd, StringComparison.Ordinal))
            ?? throw new InvalidOperationException($"Bilinmeyen detay: {detayAd}");

        await using var baglanti = await _veri.AcAsync(iptal);
        return await DetaySayfasiAsync(baglanti, detay, id, sayfa, boyut, suzgec, iptal);
    }

    /// <summary>Detayin TOPLAM satir sayisi - sayfa seridi icin (525).</summary>
    public async Task<int> DetayAdediAsync(
        KartTanimi tanim, string detayAd, long id, DetaySuzgeci? suzgec = null,
        CancellationToken iptal = default)
    {
        var detay = (tanim.Detaylar ?? Array.Empty<DetayTanimi>())
            .FirstOrDefault(d => string.Equals(d.Ad, detayAd, StringComparison.Ordinal))
            ?? throw new InvalidOperationException($"Bilinmeyen detay: {detayAd}");

        await using var baglanti = await _veri.AcAsync(iptal);
        return await DetayAdediAsync(baglanti, detay, id, suzgec, iptal);
    }

    private static async Task<List<IDictionary<string, object?>>> DetaySayfasiAsync(
        NpgsqlConnection baglanti, DetayTanimi detay, long id, int sayfa, int boyut,
        DetaySuzgeci? suzgec, CancellationToken iptal)
    {
        var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
        var (kosul, par) = SuzgecKosulu(detay, suzgec, id);
        var sql = $"select {secim} from {detay.Tablo} where {kosul} "
                + $"order by {detay.Sirala}";
        if (boyut > 0)
            sql += $" limit {boyut} offset {Math.Max(sayfa - 1, 0) * (long)boyut}";

        await using var komut = baglanti.Komut(sql, null, par);

        var satirlar = new List<IDictionary<string, object?>>();
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
        {
            var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
            for (var i = 0; i < okuyucu.FieldCount; i++)
                satir[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
            satirlar.Add(satir);
        }
        return satirlar;
    }

    private static async Task<int> DetayAdediAsync(
        NpgsqlConnection baglanti, DetayTanimi detay, long id, DetaySuzgeci? suzgec,
        CancellationToken iptal)
    {
        var (kosul, par) = SuzgecKosulu(detay, suzgec, id);
        await using var komut = baglanti.Komut(
            $"select count(*) from {detay.Tablo} where {kosul}", null, par);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal) ?? 0);
    }

    /// <summary>
    /// SAYFALI DETAYIN SUNUCU TARAFI SUZGECI (526). Istekten SQL METNI GELMEZ:
    /// aranacak alanlar, kategori alani ve cip kosullari KATALOGDA yazili;
    /// istek yalniz metni ve secilen anahtarlari verir, hepsi parametre olur.
    /// </summary>
    private static (string Kosul, object?[] Par) SuzgecKosulu(
        DetayTanimi detay, DetaySuzgeci? suzgec, long id)
    {
        var par = new List<object?> { id };
        var kosul = $"{detay.UstKolon} = @p0";
        if (suzgec is null) return (kosul, par.ToArray());

        // ARAMA: katalogdaki alan ifadelerinde, ILIKE ile.
        if (!string.IsNullOrWhiteSpace(suzgec.Ara) && detay.AraAlanlari is { Count: > 0 })
        {
            var kolonlar = detay.AraAlanlari
                .Select(ad => detay.Alanlar.FirstOrDefault(a =>
                    string.Equals(a.Ad, ad, StringComparison.Ordinal))?.Kolon)
                .Where(k => k is not null).ToList();
            if (kolonlar.Count > 0)
            {
                par.Add($"%{suzgec.Ara.Trim()}%");
                var p = $"@p{par.Count - 1}";
                kosul += " and (" + string.Join(" or ",
                    kolonlar.Select(k => $"({k})::text ilike {p}")) + ")";
            }
        }

        // KATEGORI: secilen dal ALT AGACIYLA - ust dal secince altindakiler de
        //   gelsin (ekrandaki agac combosunun bugunku davranisi).
        if (suzgec.Kategori is > 0 && detay.KategoriAlani is { } katAd)
        {
            var kolon = detay.Alanlar.FirstOrDefault(a =>
                string.Equals(a.Ad, katAd, StringComparison.Ordinal))?.Kolon;
            if (kolon is not null)
            {
                par.Add(suzgec.Kategori.Value);
                var p = $"@p{par.Count - 1}";
                kosul += $" and ({kolon}) in ("
                       + "with recursive dal as ("
                       + $"  select k0.id from public.kategori k0 where k0.id = {p}"
                       + "  union all"
                       + "  select k1.id from public.kategori k1 join dal on k1.ust_id = dal.id)"
                       + " select id from dal)";
            }
        }

        // CIP: kosul katalogda yazili, istek yalniz kodu secer.
        if (!string.IsNullOrWhiteSpace(suzgec.Cip)
            && detay.Cipler is { } cipler
            && cipler.TryGetValue(suzgec.Cip, out var cipKosulu))
            kosul += $" and ({cipKosulu})";

        return (kosul, par.ToArray());
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
            // BOLUM AGACI (577): ust_id tasiyan gorunum - duz lookup agac cizemez.
            "public.v_departman_agac_lookup",
            // Personel gorevi (255) - departmana bagli combo.
            "public.v_gorev_lookup",
            // GOREV AGACI (570/571): ust_id GERCEK ust gorevi tasir;
            //   v_gorev_lookup ise departmani gosterir - iki ayri soru.
            "public.v_gorev_agac_lookup",
            // Randevu verilebilir personel (252) - randevu kartindaki hekim.
            "public.v_hekim_lookup",
            // Kampanya (268) - kurum sozlesmesinde secilir.
            "public.v_kampanya_lookup",
            // GOZ (693): cihaz, tetkik (yalniz goz hizmetleri), postop
            //   protokolu ve hastanin acik takip plani.
            "public.v_goz_cihaz_lookup", "public.v_goz_tetkik_lookup",
            "public.v_goz_protokol_lookup", "public.v_goz_takip_lookup",
            // YATAN HASTA (696): oda ve yatak secimi. Yatak adi icinde oda
            //   turu, servis ve DURUM var - bos yatagin verilebilir olup
            //   olmadigini oda belirler.
            "public.v_oda_lookup", "public.v_yatak_lookup",
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
            // Satis listeleri TARIFE TIPIYLE (587): anlasmali kurum sozlesmesinde
            //   combo kurumun turune uymayan tarifeyi gostermesin.
            "public.v_fiyat_listesi_tarife_lookup",
            // Muayene v1 (409/411): ICD-10 tani secici, muayene sablonu ve
            //   sablon alani. Beyaz listeye eklemeden kart HIC ACILMAZ
            //   ("Bilinmeyen kod tablosu" -> 500) - 358 ve 375'teki ayni tuzak.
            "public.v_icd_lookup",
            "public.v_muayene_sablon_lookup", "public.v_muayene_sablon_alan_lookup",
            // Dokuman v1 (419): belge turu ve klasor secici.
            "public.v_dokuman_kategori_lookup", "public.v_dokuman_klasor_lookup",
            "public.v_dokuman_akis_lookup",
            // Erisim sekmesi (425): rol adi.
            "public.v_rol_lookup",
            // Uretim v1 (429): is merkezi, urun agaci (kod + surum), uretim emri
            //   ve DEPO - uretim karti sarf/mamul/fire deposunu secer.
            "public.v_is_merkezi_lookup", "public.v_urun_agaci_lookup",
            "public.v_uretim_emri_lookup", "public.v_depo_lookup",
            // Sigorta v1 (430): saglayici, kurum hesabi ve entegrasyon hesabi.
            "public.v_sigorta_saglayici_lookup", "public.v_sigorta_hesap_lookup",
            "public.v_entegrasyon_hesap_lookup",
            // Cihaz ara katmani (432).
            "public.v_cihaz_lookup",
            // ISTEM KARTI (479): tetkigin baglanacagi tup - istem basina suzulur.
            "public.v_lab_numune_lookup",
            // KURUM SOZLESMESI ve ALT KURUM (468): basvuru ve kurum karti.
            "public.v_kurum_sozlesme_lookup",
            "public.v_alt_kurum_lookup",
            // Lab v1 (433/434): tetkik ve panel secimi (panel satiri, cihaz
            //   eslemesi ve tetkik kartinin varsayilan cihazi).
            "public.v_lab_tetkik_lookup", "public.v_lab_panel_lookup",
            // Mikrobiyoloji (436): besiyeri seti, izolat organizmasi ve
            //   antibiyogram antibiyotigi.
            "public.v_lab_besiyeri_lookup", "public.v_lab_organizma_lookup",
            "public.v_lab_antibiyotik_lookup",
            // Genetik (439): panel gen listesi, vaka paneli ve run secimi.
            "public.v_lab_gen_lookup", "public.v_lab_genetik_panel_lookup",
            "public.v_lab_genetik_run_lookup",
            // Kalite kontrol (442): kontrol lotu secimi.
            "public.v_lab_kk_lot_lookup",
            // Dis laboratuvar (445): tetkik kartinda ve gonderimde secim.
            "public.v_lab_dis_lab_lookup",
            // Stok/hizmet siniflandirmasi (544): kategori agaci TUR BAZINDA
            //   ayrildi - stok kartinda hizmet dallari cikiyordu.
            "public.v_stok_kategori_lookup", "public.v_hizmet_kategori_lookup",
            // SKRS lookup'lari (615): uyruk (236 ulke), meslek (5.461) ve
            //   klinik (240) acilir kutuya sigmayacak kadar buyuk, arama
            //   lookup'i olarak baglanir. Beyaz listeye ALINMAMIS olmalari
            //   hasta kartini hic acilmaz yapmisti: "Bilinmeyen kod tablosu:
            //   public.v_skrs_ulke_lookup" (izleme 01M2D4RV39D9BF8BQG4Q3M2Z5C).
            "public.v_skrs_ulke_lookup", "public.v_skrs_meslek_lookup",
            "public.v_skrs_klinik_lookup",
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
                // id METIN de olabilir (ICD-10 kodu "A09.0"): karsilastirma ve
                //   okuma tip VARSAYMAZ - "id = 0" varchar kolonda
                //   "operator does not exist" ile dusuyordu.
                $"select id, ad from {KodTablosuDogrula(tablo)} where aktif = 1 " +
                "order by case when id::text = '0' then 0 else 1 end, ad",
                null, r => (Id: r.GetValue(0)?.ToString() ?? "", Ad: r.GetString(1)), iptal))
            .ToDictionary(x => x.Id, x => x.Ad, StringComparer.Ordinal);

    /// <summary>
    /// BAGLI KOD LISTESI (544): deger -> UST listedeki deger. Model markaya,
    /// (ilerde) ilce ile baglanir. `KodTablosuUstAsync`in kod_liste karsiligi -
    /// ust bagi orada `ust_id` kolonunda, burada `kod_deger.ust_deger`de.
    /// </summary>
    public async Task<Dictionary<string, string>> KodListesiUstAsync(
        string kod, CancellationToken iptal = default)
        => (await _veri.ListeAsync("""
                select distinct on (d.deger) d.deger, d.ust_deger
                  from public.kod_deger d
                  join public.kod_liste l on l.id = d.liste_id
                 where l.kod = @p0 and d.dil in (0, -1) and d.ust_deger <> 0
                 order by d.deger, d.dil desc
                """,
                new object?[] { kod },
                r => (Deger: r.GetInt32(0), Ust: r.GetInt32(1)), iptal))
            .ToDictionary(x => x.Deger.ToString(CultureInfo.InvariantCulture),
                          x => x.Ust.ToString(CultureInfo.InvariantCulture),
                          StringComparer.Ordinal);

    /// <summary>
    /// YEREL PARA BIRIMI ARTIK SUBENIN AYARI (666): `sube.para_birimi`.
    /// Genel Ayarlar'daki `genel.yerel_para` KALDIRILDI - yurt disinda subesi
    /// olan kurumda tek bir "kurum parasi" yoktu; Berlin subesi avro tahsil eder.
    ///
    /// Sube verilmezse varsayilan sube, o da yoksa 'TL' kullanilir. Donen deger
    /// uygulamanin doviz listesi kodudur (TRY -> TL, bkz. ParaKoduYerellestir).
    /// </summary>
    public async Task<string> YerelParaAsync(int? subeId = null,
                                             CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var iso = await baglanti.TekDegerAsync<string>(
            "select para_birimi from public.sube " +
            " where (@p0::int is null or id = @p0) and aktif = 1 " +
            " order by case when id = @p0 then 0 else 1 end, varsayilan desc, id limit 1",
            null, new object?[] { subeId }, iptal);
        return Gentegre.Cekirdek.Katalog.KasaHesap.ParaKoduYerellestir(iso);
    }

    /// <summary>
    /// Urun modu: 1 Gentegre AI (ERP), 2 GenoTIP AI (HBYS), 3 ikisi. Kart
    /// metasi bazi secenekleri moda gore suzuyor (or. saglik entegrasyonlari
    /// ERP kurulumunda listelenmez).
    ///
    /// KAYNAK SUBENIN PROFILI (489): mod ekrandan `kurum_profil.urun_modu`ya
    /// yazilir; eskiden burasi `referans genel.urun_modu`yu okudugu icin
    /// ekranda HBYS secili olsa bile kurulum ERP gibi davraniyordu.
    /// </summary>
    public async Task<int> UrunModuAsync(CancellationToken iptal = default)
        => await UrunModuAsync(0, iptal);

    public async Task<int> UrunModuAsync(int subeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("select public.fn_urun_modu(@p0)", null, subeId);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal) ?? 1);
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

        // 666: yerel para SUBEDEN okunur (genel.yerel_para ayari kaldirildi).
        var yerelIso = await baglanti.TekDegerAsync<string>(
            "select para_birimi from public.sube where aktif = 1 " +
            " order by varsayilan desc, id limit 1", islem, null, iptal);
        var yerelPara = Gentegre.Cekirdek.Katalog.KasaHesap.ParaKoduYerellestir(yerelIso);
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
