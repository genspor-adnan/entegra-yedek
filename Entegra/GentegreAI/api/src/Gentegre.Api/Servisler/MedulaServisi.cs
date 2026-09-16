using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// MEDULA (SGK) SERVİSİ (707) — mockup <c>Ekranlar/Medula/medula_sureci.html</c>.
///
/// <para><b>Yerelde önce yaz, sonra gönder.</b> Her Medula çağrısı önce
/// <c>medula_kuyruk</c> satırıdır (servis · işlem · kaynak · istek). Kapı
/// yanıt verirse satır kabul/hata olur ve sonuç ilgili tabloya işlenir
/// (takip no → <c>belge_provizyon</c>, işlem sırası → <c>medula_islem</c>,
/// e-reçete no → <c>recete</c>, fatura no → <c>medula_fatura</c>). Kapı
/// erişilemezse (2001) satır BEKLER; zamanlı iş ya da "bekleyenleri gönder"
/// aynı satırı tekrar dener. Hasta kabul ekranı Medula'nın nabzına bağlı
/// değildir.</para>
///
/// <para><b>Kapı soyutlanır.</b> <see cref="IMedulaKapisi"/> tek arayüz; bu
/// sürümde <see cref="MedulaSimulasyonKapisi"/> (SGK kuralları yerel
/// kurallarla: 1006 aynı gün açık takip, 1013 müstehak değil, 1020 tescil
/// eksik, 1100 SUT kodu yok, 1200 çıkışsız fatura, 3001 imzasız reçete).
/// Canlı SOAP kapısı aynı arayüzü uygular; ekran ve tablolar değişmez.
/// Hesap (<c>entegrasyon_hesap</c>, kod MEDULA) <c>test_mi = 0</c> ve URL
/// doluysa canlı kapı beklenir - bu sürümde bağlı değil, satır hata (2001)
/// alır ve bunu SÖYLER.</para>
/// </summary>
public sealed class MedulaServisi
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;
    private readonly IMedulaKapisi _kapi;

    public MedulaServisi(VeriKaynagi veri, LogDeposu log, IMedulaKapisi kapi)
    { _veri = veri; _log = log; _kapi = kapi; }

    public const int LogTabloKuyruk = 1150;
    public const int LogTabloFatura = 1151;
    public const int LogTabloDonem = 1152;
    public const int LogTabloRapor = 1153;

    public sealed record Sonuc(long KuyrukId, bool Kabul, bool Bekliyor, string Kod, string Mesaj,
                               JsonElement? Yanit);

    /// <summary>Kuyruğa satır yazar ve hemen dener (hasta bekliyor). Kapı kapalıysa bekler.</summary>
    public async Task<Sonuc> CagirAsync(string servis, string islem, string kaynakTablo, long? kaynakId,
        int? hastaId, int? belgeId, object istek, int kullaniciId, int? subeId, string ip,
        short oncelik = 5, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var istekJson = JsonSerializer.Serialize(istek);
        var kuyrukId = await baglanti.TekDegerAsync<long>("""
            insert into public.medula_kuyruk
                   (sube_id, servis, islem, kaynak_tablo, kaynak_id, hasta_id, belge_id, istek, oncelik, kullanici_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7::jsonb, @p8, @p9, @p9) returning id
            """, null, [subeId ?? 0, servis, islem, kaynakTablo, kaynakId, hastaId, belgeId, istekJson, oncelik, kullaniciId], iptal);
        return await DeneAsync(baglanti, kuyrukId, kullaniciId, subeId, ip, iptal);
    }

    /// <summary>Var olan kuyruk satırını (yeniden) dener.</summary>
    public async Task<Sonuc> DeneAsync(NpgsqlConnection baglanti, long kuyrukId, int kullaniciId, int? subeId,
        string ip, CancellationToken iptal)
    {
        var s = await baglanti.TekAsync("""
            select servis, islem, kaynak_tablo, kaynak_id, hasta_id, belge_id, istek::text, durum, deneme
              from public.medula_kuyruk where id = @p0
            """, null, [kuyrukId], o => new
        {
            servis = o.GetString(0), islem = o.GetString(1), kaynakTablo = o.GetString(2),
            kaynakId = o.IsDBNull(3) ? (long?)null : o.GetInt64(3),
            hastaId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
            belgeId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
            istek = o.GetString(6), durum = o.GetInt16(7), deneme = o.GetInt16(8),
        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Kuyruk satırı bulunamadı.");
        if (s.durum is 3 or 6)
            return new Sonuc(kuyrukId, s.durum == 3, false, "", "Satır zaten sonuçlanmış.", null);

        var istek = JsonDocument.Parse(s.istek).RootElement;
        var deneme = (short)(s.deneme + 1);
        var basla = DateTime.UtcNow;
        KapiYaniti yanit;
        try
        {
            yanit = await _kapi.CagirAsync(baglanti, s.islem, istek, s.hastaId, s.belgeId, s.kaynakId, iptal);
        }
        catch (Exception h)
        {
            yanit = new KapiYaniti("2001", "Servis erişilemiyor: " + h.Message, null, Erisilemedi: true);
        }
        var sure = (int)(DateTime.UtcNow - basla).TotalMilliseconds;

        var enFazla = await AyarAsync(baglanti, "medula.deneme_sayisi", 3, iptal);
        short durum;
        DateTime? sonraki = null;
        if (yanit.Erisilemedi)
        {
            // Kapı kapalı: BEKLER (1), deneme sayısı dolunca elle müdahale (5).
            durum = deneme >= enFazla ? (short)5 : (short)1;
            var araliklar = (await AyarAsync(baglanti, "medula.deneme_aralik_dk", "2,5,15", iptal)).Split(',');
            var dk = int.TryParse(araliklar[Math.Min(deneme - 1, araliklar.Length - 1)].Trim(), out var d) ? d : 5;
            if (durum == 1) sonraki = DateTime.UtcNow.AddMinutes(dk);
        }
        else durum = yanit.Kod == "0000" ? (short)3 : (short)4;

        await baglanti.CalistirAsync("""
            update public.medula_kuyruk
               set durum = @p1, deneme = @p2, sonraki_deneme = @p3, gonderim = now(), sure_ms = @p4,
                   sonuc_kod = @p5, sonuc_mesaj = @p6, yanit = @p7::jsonb,
                   degistiren = @p8, degistirme_tarihi = now()
             where id = @p0
            """, null, [kuyrukId, durum, deneme, sonraki, sure, yanit.Kod, yanit.Mesaj,
                        yanit.Yanit is null ? null : JsonSerializer.Serialize(yanit.Yanit), kullaniciId], iptal);

        // Sonucu ilgili tabloya işle - kabul de red de yazılır (red nedeni ekranda durur).
        if (!yanit.Erisilemedi)
            await SonucIsleAsync(baglanti, s.islem, s.kaynakTablo, s.kaynakId, s.belgeId, istek, yanit, kuyrukId, kullaniciId, iptal);

        await _log.YazAsync(LogIslemi.Degistir, LogTabloKuyruk, kuyrukId, kullaniciId, subeId, ip,
            new { s.islem, kod = yanit.Kod, durum }, tarafId: s.hastaId, iptal: iptal);

        return new Sonuc(kuyrukId, durum == 3, durum is 1 or 5, yanit.Kod, yanit.Mesaj,
            yanit.Yanit is null ? null : JsonSerializer.SerializeToElement(yanit.Yanit));
    }

    /// <summary>Bekleyen ve süresi gelen satırları sırayla dener (zamanlı iş / "bekleyenleri gönder").</summary>
    public async Task<(int denenen, int kabul, int bekleyen, int hata, string aciklama)> KuyrukCalistirAsync(
        int enFazla, int kullaniciId, int? subeId, string ip, bool hatalilarDa, CancellationToken iptal, bool hemen = false)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        // hemen: "Bekleyenleri gönder" düğmesi - sonraki deneme zamanını beklemez.
        //   Zamanlı iş beklemeyi tutar (kapı kapalıyken her dakika vurmasın).
        var ids = await baglanti.ListeAsync("""
            select id from public.medula_kuyruk
             where (durum = 1 and (@p2 or sonraki_deneme is null or sonraki_deneme <= now()))
                or (@p1 and durum in (4, 5))
             order by oncelik, id limit @p0
            """, null, [enFazla, hatalilarDa, hemen], o => o.GetInt64(0), iptal);
        int kabul = 0, bekleyen = 0, hata = 0;
        foreach (var id in ids)
        {
            var s = await DeneAsync(baglanti, id, kullaniciId, subeId, ip, iptal);
            if (s.Kabul) kabul++; else if (s.Bekliyor) bekleyen++; else hata++;
            if (s.Bekliyor && s.Kod == "2001") break;   // kapı kapalı: gerisini deneme
        }
        return (ids.Count, kabul, bekleyen, hata,
            ids.Count == 0 ? "Kuyrukta bekleyen çağrı yok." : $"{ids.Count} çağrı denendi: {kabul} kabul · {bekleyen} bekliyor · {hata} hata.");
    }

    // ------------------------------------------------------------ sonuç işleme ----
    private async Task SonucIsleAsync(NpgsqlConnection b, string islem, string kaynakTablo, long? kaynakId,
        int? belgeId, JsonElement istek, KapiYaniti y, long kuyrukId, int kullaniciId, CancellationToken iptal)
    {
        var ok = y.Kod == "0000";
        var yn = y.Yanit;
        switch (islem)
        {
            case "mustehaklikSorgu":
                if (belgeId is int mb)
                    await b.CalistirAsync("""
                        insert into public.belge_provizyon (id, sgk_mustehaklik, sgk_mustehaklik_zaman, sgk_sigorta_turu, sgk_red_nedeni, ekleyen)
                        values (@p0, @p1, now(), @p2, @p3, @p4)
                        on conflict (id) do update set sgk_mustehaklik = excluded.sgk_mustehaklik,
                            sgk_mustehaklik_zaman = now(), sgk_sigorta_turu = excluded.sgk_sigorta_turu,
                            sgk_red_nedeni = excluded.sgk_red_nedeni
                        """, null, [mb, (short)(ok ? 1 : 2), yn?.GetValueOrDefault("sigortaTuru")?.ToString() ?? "",
                                    ok ? "" : y.Mesaj, kullaniciId], iptal);
                break;
            case "hastaKabul":
                if (belgeId is int hb)
                    await b.CalistirAsync("""
                        insert into public.belge_provizyon
                               (id, sgk_durum, sgk_takip_no, sgk_provizyon_no, sgk_provizyon_tarihi, sgk_takip_tarihi,
                                sgk_gecerlilik, sgk_takip_turu, sgk_provizyon_tipi, sgk_tesis_kodu, sgk_brans_kodu,
                                sgk_hekim_tescil, sgk_red_nedeni, sgk_kuyruk_id, ekleyen)
                        values (@p0, @p1, @p2, @p3, now(), now(), now() + interval '10 days', @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
                        on conflict (id) do update set
                            sgk_durum = excluded.sgk_durum, sgk_takip_no = excluded.sgk_takip_no,
                            sgk_provizyon_no = excluded.sgk_provizyon_no,
                            sgk_provizyon_tarihi = case when excluded.sgk_durum = 1 then now() else belge_provizyon.sgk_provizyon_tarihi end,
                            sgk_takip_tarihi = case when excluded.sgk_durum = 1 then now() else belge_provizyon.sgk_takip_tarihi end,
                            sgk_gecerlilik = case when excluded.sgk_durum = 1 then now() + interval '10 days' else belge_provizyon.sgk_gecerlilik end,
                            sgk_takip_turu = excluded.sgk_takip_turu, sgk_provizyon_tipi = excluded.sgk_provizyon_tipi,
                            sgk_tesis_kodu = excluded.sgk_tesis_kodu, sgk_brans_kodu = excluded.sgk_brans_kodu,
                            sgk_hekim_tescil = excluded.sgk_hekim_tescil, sgk_red_nedeni = excluded.sgk_red_nedeni,
                            sgk_kuyruk_id = excluded.sgk_kuyruk_id
                        """, null, [hb, (short)(ok ? 1 : 2),
                                    ok ? yn?.GetValueOrDefault("takipNo")?.ToString() ?? "" : "",
                                    ok ? yn?.GetValueOrDefault("provizyonNo")?.ToString() ?? "" : "",
                                    (short)Sayi(istek, "takipTipi", 1), (short)Sayi(istek, "provizyonTipi", 1),
                                    Metin(istek, "tesisKodu"), Metin(istek, "bransKodu"), Metin(istek, "hekimTescil"),
                                    ok ? "" : y.Mesaj, kuyrukId, kullaniciId], iptal);
                break;
            case "hastaKabulIptal":
                if (ok && belgeId is int ib)
                    await b.CalistirAsync("""
                        update public.belge_provizyon set sgk_durum = 4, sgk_red_nedeni = 'İptal edildi', sgk_kuyruk_id = @p1 where id = @p0
                        """, null, [ib, kuyrukId], iptal);
                break;
            case "hastaCikisKayit":
                if (ok && belgeId is int cb)
                    await b.CalistirAsync("""
                        update public.belge_provizyon set sgk_cikis_zaman = now(), sgk_cikis_sekli = @p1 where id = @p0
                        """, null, [cb, (short)Sayi(istek, "cikisSekli", 1)], iptal);
                break;
            case "hizmetKayit":
            case "tetkikVeRadyolojiKayit":
                if (kaynakId is long mi)
                    await b.CalistirAsync("""
                        update public.medula_islem
                           set durum = @p1, sonuc_kod = @p2, sonuc_mesaj = @p3, medula_sira = @p4, kuyruk_id = @p5,
                               degistirme_tarihi = now()
                         where id = @p0
                        """, null, [(int)mi, (short)(ok ? 2 : 3), y.Kod, y.Mesaj,
                                    ok ? Sayi(yn, "sira", 0) : (int?)null, kuyrukId], iptal);
                break;
            case "hizmetKayitIptal":
                if (ok && kaynakId is long ii)
                    await b.CalistirAsync("update public.medula_islem set durum = 4, kuyruk_id = @p1, degistirme_tarihi = now() where id = @p0",
                        null, [(int)ii, kuyrukId], iptal);
                break;
            case "taniKayit":
                if (kaynakId is long ti)
                    await b.CalistirAsync("update public.medula_tani set durum = @p1, sonuc_kod = @p2, kuyruk_id = @p3 where id = @p0",
                        null, [(int)ti, (short)(ok ? 2 : 3), y.Kod, kuyrukId], iptal);
                break;
            case "eReceteKayit":
                if (kaynakId is long ri)
                    await b.CalistirAsync("""
                        update public.recete
                           set durum = case when @p1 then 3 else durum end,
                               medula_recete_no = case when @p1 then @p2 else medula_recete_no end,
                               medula_gonderim = now(), medula_sonuc = @p3, medula_kuyruk_id = @p4
                         where id = @p0
                        """, null, [(int)ri, ok, ok ? yn?.GetValueOrDefault("eReceteNo")?.ToString() ?? "" : "",
                                    (y.Kod + " " + y.Mesaj).Trim(), kuyrukId], iptal);
                break;
            case "eReceteSil":
                if (ok && kaynakId is long rs)
                    await b.CalistirAsync("""
                        update public.recete set durum = 4, medula_sonuc = 'Medula''dan silindi', medula_kuyruk_id = @p1 where id = @p0
                        """, null, [(int)rs, kuyrukId], iptal);
                break;
            case "raporKayit":
                if (kaynakId is long rp)
                    await b.CalistirAsync("""
                        update public.medula_rapor
                           set durum = @p1, rapor_no = case when @p1 = 3 then @p2 else rapor_no end,
                               medula_sonuc = @p3, kuyruk_id = @p4, degistirme_tarihi = now()
                         where id = @p0
                        """, null, [(int)rp, (short)(ok ? 3 : 5), ok ? yn?.GetValueOrDefault("raporNo")?.ToString() ?? "" : "",
                                    (y.Kod + " " + y.Mesaj).Trim(), kuyrukId], iptal);
                break;
            case "faturaKayit":
                if (kaynakId is long fi)
                    await b.CalistirAsync("""
                        update public.medula_fatura
                           set durum = case when @p1 then 2 else 1 end,
                               medula_fatura_no = case when @p1 then @p2 else '' end,
                               medula_tutar = case when @p1 then @p3 else medula_tutar end,
                               hasta_katilim = case when @p1 then @p4 else hasta_katilim end,
                               sgk_tutar = case when @p1 then @p3 - @p4 else sgk_tutar end,
                               kayit_zaman = case when @p1 then now() else kayit_zaman end,
                               sonuc_kod = @p5, sonuc_mesaj = @p6, kuyruk_id = @p7, degistirme_tarihi = now()
                         where id = @p0
                        """, null, [(int)fi, ok, ok ? yn?.GetValueOrDefault("faturaNo")?.ToString() ?? "" : "",
                                    Ondalik(yn, "tutar"), Ondalik(yn, "katilim"), y.Kod, y.Mesaj, kuyrukId], iptal);
                break;
            case "faturaIptal":
                if (ok && kaynakId is long fx)
                    await b.CalistirAsync("update public.medula_fatura set durum = 7, iptal_zaman = now(), kuyruk_id = @p1 where id = @p0",
                        null, [(int)fx, kuyrukId], iptal);
                break;
            case "donemSonlandir":
                if (kaynakId is long di)
                {
                    if (ok)
                    {
                        await b.CalistirAsync("""
                            update public.medula_donem set durum = 2, sonlandirma = now(), icmal_no = @p1, kuyruk_id = @p2, degistirme_tarihi = now() where id = @p0;
                            update public.medula_fatura set durum = 4, degistirme_tarihi = now() where donem_id = @p0 and durum = 3;
                            """, null, [(int)di, yn?.GetValueOrDefault("icmalNo")?.ToString() ?? "", kuyrukId], iptal);
                    }
                    else
                        await b.CalistirAsync("update public.medula_donem set aciklama = @p1, kuyruk_id = @p2 where id = @p0",
                            null, [(int)di, (y.Kod + " " + y.Mesaj).Trim(), kuyrukId], iptal);
                }
                break;
        }
    }

    // ------------------------------------------------------------- yardımcılar ----
    internal static async Task<int> AyarAsync(NpgsqlConnection b, string anahtar, int varsayilan, CancellationToken iptal)
    {
        var d = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = @p0", null, [anahtar], iptal);
        return int.TryParse(d, out var v) ? v : varsayilan;
    }
    internal static async Task<string> AyarAsync(NpgsqlConnection b, string anahtar, string varsayilan, CancellationToken iptal)
        => await b.TekDegerAsync<string>("select deger from public.referans where anahtar = @p0", null, [anahtar], iptal) ?? varsayilan;

    internal static int Sayi(JsonElement? e, string ad, int varsayilan)
    {
        if (e is null || e.Value.ValueKind != JsonValueKind.Object || !e.Value.TryGetProperty(ad, out var v)) return varsayilan;
        return v.ValueKind == JsonValueKind.Number ? v.GetInt32() : int.TryParse(v.ToString(), out var n) ? n : varsayilan;
    }
    // Sözlük değerleri kapıdan TİPLİ gelir (decimal/int); metne çevirip kültürle
    //   geri okumak "1600,00" → 160000 üretiyordu (Türkçe ondalık virgülü,
    //   invariant parse'da binlik ayracı sanılır). Önce tipe bak, sonra metin.
    internal static int Sayi(Dictionary<string, object?>? d, string ad, int varsayilan)
    {
        if (d is null || !d.TryGetValue(ad, out var v) || v is null) return varsayilan;
        return v switch { int i => i, long l => (int)l, short sh => sh, decimal m => (int)m, double db => (int)db,
                          _ => int.TryParse(v.ToString(), out var n) ? n : varsayilan };
    }
    internal static decimal Ondalik(Dictionary<string, object?>? d, string ad)
    {
        if (d is null || !d.TryGetValue(ad, out var v) || v is null) return 0m;
        return v switch { decimal m => m, int i => i, long l => l, double db => (decimal)db,
                          _ => decimal.TryParse(v.ToString(), System.Globalization.NumberStyles.Any,
                                                System.Globalization.CultureInfo.InvariantCulture, out var n) ? n : 0m };
    }
    internal static string Metin(JsonElement e, string ad)
        => e.ValueKind == JsonValueKind.Object && e.TryGetProperty(ad, out var v) ? v.ToString() : "";
}

/// <summary>Kapı yanıtı: SGK sonuç kodu (0000 kabul), mesaj ve alanlar.</summary>
/// <summary>e-Reçete numarası biçimi: 6 haneli taban-36.</summary>
file static class MedulaYardimci
{
    public static string Taban36(long n)
    {
        const string h = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var s = ""; if (n <= 0) return "0";
        while (n > 0) { s = h[(int)(n % 36)] + s; n /= 36; }
        return s;
    }
}

public sealed record KapiYaniti(string Kod, string Mesaj, Dictionary<string, object?>? Yanit, bool Erisilemedi = false);

/// <summary>Medula kapısı: canlı SOAP ya da simülasyon - servis bunu bilmez.</summary>
public interface IMedulaKapisi
{
    Task<KapiYaniti> CagirAsync(NpgsqlConnection b, string islem, JsonElement istek, int? hastaId, int? belgeId,
                                long? kaynakId, CancellationToken iptal);
}

/// <summary>
/// SİMÜLASYON KAPISI: SGK kurallarını yerel veriyle taklit eder. Hesap
/// <c>test_mi = 0</c> ve URL doluysa canlı kapı beklenir - bu sürümde bağlı
/// değil: 2001 döner ki kimse kapıyı açık sanmasın. Ayar
/// <c>medula.kapi_kapali = 1</c> ile "SGK bakımda" hâli denenir (kuyruk
/// bekler, sonra gönderilir).
/// </summary>
public sealed class MedulaSimulasyonKapisi : IMedulaKapisi
{
    public async Task<KapiYaniti> CagirAsync(NpgsqlConnection b, string islem, JsonElement istek, int? hastaId,
        int? belgeId, long? kaynakId, CancellationToken iptal)
    {
        if (await MedulaServisi.AyarAsync(b, "medula.kapi_kapali", 0, iptal) == 1)
            throw new InvalidOperationException("Medula kapısı kapalı (simülasyon: bakım).");

        var canli = await b.TekDegerAsync<int?>("""
            select 1 from public.entegrasyon_hesap where kod = 'MEDULA' and coalesce(test_mi, 1) = 0 and url <> '' limit 1
            """, null, [], iptal);
        if (canli == 1)
            throw new InvalidOperationException("Canlı Medula SOAP kapısı bu sürümde bağlı değil; hesabı test moduna alın.");

        var tesis = await b.TekDegerAsync<string>("select kurum_kodu from public.entegrasyon_hesap where kod = 'MEDULA' limit 1", null, [], iptal) ?? "TEST";
        var takip = $"{DateTime.UtcNow:yyyyMMdd}{(belgeId ?? 0):D5}";

        switch (islem)
        {
            case "mustehaklikSorgu":
            {
                // Müstehak = hastanın aktif SGK kurum kaydı (taraf_hasta_kurum.tur = 3).
                var sgk = await b.TekDegerAsync<int?>("""
                    select 1 from public.taraf_hasta_kurum where hasta_id = @p0 and tur = 3 and aktif = 1
                       and (gecerlilik is null or gecerlilik >= current_date) limit 1
                    """, null, [hastaId], iptal);
                var tckn = MedulaServisi.Metin(istek, "tckn");
                if (tckn.Length != 11) return new("1001", "TC kimlik numarası 11 hane olmalı", null);
                return sgk == 1
                    ? new("0000", "Müstehak", new() { ["mustehak"] = true, ["sigortaTuru"] = "4/a", ["yakinlik"] = "Kendisi",
                                                       ["kapsam"] = "GSS", ["katilimPayi"] = true, ["sevkZorunlu"] = false })
                    : new("1013", "Sigortalılık / müstehaklık bulunamadı", new() { ["mustehak"] = false });
            }
            case "hastaKabul":
            {
                var m = await b.TekDegerAsync<short?>("select sgk_mustehaklik from public.belge_provizyon where id = @p0", null, [belgeId], iptal);
                if (m == 2) return new("1013", "Müstehak değil; provizyon verilemez", null);
                if (MedulaServisi.Metin(istek, "hekimTescil") == "") return new("1020", "Hekim tescil bilgisi eksik", null);
                var brans = MedulaServisi.Metin(istek, "bransKodu");
                var acik = await b.TekDegerAsync<string>("""
                    select p.sgk_takip_no from public.belge_provizyon p join public.belge x on x.id = p.id
                     where x.taraf_id = @p0 and p.id <> @p1 and p.sgk_durum = 1 and p.sgk_cikis_zaman is null
                       and p.sgk_takip_tarihi::date = current_date and p.sgk_brans_kodu = @p2 limit 1
                    """, null, [hastaId, belgeId, brans], iptal);
                if (acik is not null) return new("1006", $"Aynı gün aynı branşta açık takip var ({acik})", new() { ["acikTakipNo"] = acik });
                return new("0000", "Takip açıldı", new() { ["takipNo"] = takip, ["provizyonNo"] = "P" + takip, ["tesisKodu"] = tesis, ["gecerlilikGun"] = 10 });
            }
            case "hastaKabulIptal":
            {
                var kabul = await b.TekDegerAsync<int>("select count(*)::int from public.medula_islem where belge_id = @p0 and durum = 2", null, [belgeId], iptal);
                return kabul > 0 ? new("1030", "Takipte kabul edilmiş hizmet kaydı var; önce hizmet kayıtlarını iptal edin", null)
                                 : new("0000", "Takip iptal edildi", null);
            }
            case "hastaCikisKayit":
                return new("0000", "Hasta çıkışı kaydedildi", null);
            case "hizmetKayit":
            case "tetkikVeRadyolojiKayit":
            {
                var sut = MedulaServisi.Metin(istek, "sutKodu");
                if (sut == "") return new("1100", "SUT kodu yok - hizmet kartına SUT kodu yazın", null);
                var takipVar = await b.TekDegerAsync<int?>("select 1 from public.belge_provizyon where id = @p0 and sgk_durum = 1", null, [belgeId], iptal);
                if (takipVar != 1) return new("1101", "Takip açık değil; önce provizyon alın", null);
                var sira = await b.TekDegerAsync<int>("select coalesce(max(medula_sira), 0) + 1 from public.medula_islem where belge_id = @p0", null, [belgeId], iptal);
                return new("0000", "Hizmet kaydedildi", new() { ["sira"] = sira });
            }
            case "hizmetKayitIptal": return new("0000", "Hizmet kaydı iptal edildi", null);
            case "taniKayit":
            {
                var icd = MedulaServisi.Metin(istek, "icdKod");
                return icd == "" ? new("1110", "ICD-10 kodu yok", null) : new("0000", "Tanı kaydedildi", null);
            }
            case "eReceteKayit":
            {
                var durum = await b.TekDegerAsync<short?>("select durum from public.recete where id = @p0", null, [(int?)kaynakId], iptal);
                if (durum != 2) return new("3001", "Reçete imzalı değil", null);
                var ilac = await b.TekDegerAsync<int>("select count(*)::int from public.recete_satir where recete_id = @p0", null, [(int?)kaynakId], iptal);
                if (ilac == 0) return new("3002", "Reçetede ilaç yok", null);
                var no = MedulaYardimci.Taban36((kaynakId ?? 0) * 7919 + 100000);
                return new("0000", "e-Reçete kaydedildi", new() { ["eReceteNo"] = no.Length > 6 ? no[^6..] : no });
            }
            case "eReceteSil": return new("0000", "e-Reçete silindi", null);
            case "raporKayit":
            {
                if (MedulaServisi.Metin(istek, "icdKod") == "") return new("4001", "Rapor tanısı yok", null);
                return new("0000", "Rapor kaydedildi", new() { ["raporNo"] = $"R-{DateTime.UtcNow:yyyy}-{kaynakId:D5}" });
            }
            case "faturaKayit":
            {
                var cikis = await b.TekDegerAsync<DateTime?>("select sgk_cikis_zaman from public.belge_provizyon where id = @p0", null, [belgeId], iptal);
                if (cikis is null) return new("1200", "Hasta çıkışı kaydedilmemiş; fatura kesilemez", null);
                var tutar = await b.TekDegerAsync<decimal>("select coalesce(sum(tutar), 0) from public.medula_islem where belge_id = @p0 and durum = 2", null, [belgeId], iptal);
                if (tutar == 0) return new("1201", "Takipte kabul edilmiş hizmet kaydı yok", null);
                var katilim = await b.TekDegerAsync<int>("""
                    select count(*)::int from public.medula_islem i join public.hizmet h on h.sut_kodu = i.sut_kodu
                     where i.belge_id = @p0 and i.durum = 2 and h.ad ilike '%muayene%'
                    """, null, [belgeId], iptal) > 0
                    ? await MedulaServisi.AyarAsync(b, "medula.muayene_katilim_payi", 0, iptal) : 0;
                return new("0000", "Fatura kaydedildi", new() { ["faturaNo"] = "F" + takip, ["tutar"] = tutar, ["katilim"] = (decimal)katilim });
            }
            case "faturaIptal": return new("0000", "Fatura iptal edildi", null);
            case "donemSonlandir":
            {
                var n = await b.TekDegerAsync<int>("select count(*)::int from public.medula_fatura where donem_id = @p0 and durum = 3", null, [(int?)kaynakId], iptal);
                return n == 0 ? new("5001", "Dönemde kaydedilmiş fatura yok", null)
                              : new("0000", "Dönem sonlandırıldı", new() { ["icmalNo"] = $"I-{DateTime.UtcNow:yyyy-MM}-{kaynakId:D2}", ["faturaSayisi"] = n });
            }
            default:
                return new("9999", $"Bilinmeyen işlem: {islem}", null);
        }
    }
}
