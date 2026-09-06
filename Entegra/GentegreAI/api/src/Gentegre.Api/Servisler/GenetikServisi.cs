using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GENETİK LABORATUVARI (439) — vaka, DNA izolasyon, run, varyant, rapor.
///
/// <para><b>Onam olmadan rapor yok.</b> Genetik veri özel nitelikli kişisel
/// veridir (KVKK md. 6); tesadüfi bulgu tercihi de onamda durur ve
/// raporlamayı doğrudan etkiler - "istemiyorum" diyen hastaya ikincil bulgu
/// yazılmaz.</para>
///
/// <para><b>Sınıf kanıttan TÜRETİLİR.</b> ACMG kanıt kodları saklanır, sınıfı
/// <c>fn_lab_acmg_sinif</c> hesaplar (tetikleyici). Yalnız "patojenik"
/// yazsaydık, "neden" sorusu cevapsız kalır ve yeniden değerlendirme
/// imkânsızlaşırdı.</para>
///
/// <para><b>Laboratuvar varyant bilgi bankası</b> aynı varyantı ikinci kez
/// gören laboratuvarın önceki yorumunu getirir; yorum değiştiğinde eski
/// vakalar "yeniden değerlendirme" listesine düşer.</para>
/// </summary>
public sealed class GenetikServisi(VeriKaynagi veri, LabServisi lab)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly LabServisi _lab = lab;

    // Durumlar (db/439): 0 iptal · 1 numune · 2 izolasyon · 3 run'da ·
    //   4 analiz · 5 doğrulama · 6 rapor bekliyor · 7 onaylı.
    private const short Numune = 1, Izolasyon = 2, Runda = 3, Analiz = 4,
                        Dogrulama = 5, RaporBekliyor = 6, Onayli = 7;

    public sealed record VakaIstegi(int? PanelId, string? Endikasyon, string? TaniIcd,
                                    string? AileOykusu, int? AnaVakaId, short? AileRolu);

    public sealed record OnamIstegi(string Surum, short TesadufiBulgu,
                                    short? VeriSaklamaYil, bool? ArastirmaIzni);

    public sealed record IzolasyonIstegi(decimal Konsantrasyon, decimal Saflik,
                                         string? Not);

    public sealed record RunaAlIstegi(int? RunId, string? RunKodu, string? CihazAdi,
                                      string? Kit, string? KitLot, string? FlowCell,
                                      string? BarkodIndex);

    public sealed record KaliteIstegi(decimal? Q30, long? OkumaSayisi,
                                      decimal? OrtDerinlik, decimal? KapsamaYuzde,
                                      decimal? Kontaminasyon, short? CinsiyetDogrulama,
                                      short? Kalite, string? FastqYol, string? BamYol,
                                      string? VcfYol, string? HamHash);

    public sealed record VaryantIstegi(string GenSembol, string? Transkript,
                                       string HgvsC, string? HgvsP, short? Zigosite,
                                       int? Derinlik, decimal? Vaf, decimal? GnomadAf,
                                       string? ClinVar, string? ClinVarId,
                                       string[]? AcmgKriterler, bool? IkincilBulgu,
                                       string? Yorum);

    public sealed record VaryantSonucu(int Id, short Sinif, string SinifAdi,
                                       bool Raporlanir, string? BankaUyarisi);

    // ================================================================== vaka

    /// <summary>
    /// İstem satırından genetik vaka açar. Panel verilmezse tetkiğin adına
    /// göre değil, açıkça seçilir - yanlış panelle açılan vaka, yanlış gen
    /// listesiyle raporlanır.
    /// </summary>
    public async Task<(int Id, string VakaNo)> VakaAcAsync(int istemSatirId,
        VakaIstegi istek, IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var s = await baglanti.TekAsync("""
            select s.id, s.istem_id, s.tetkik_id, s.numune_id, i.taraf_id, i.sube_id,
                   t.tur, i.klinik_bilgi, i.tani_icd
              from public.lab_istem_satir s
              join public.lab_istem i on i.id = s.istem_id
              join public.lab_tetkik t on t.id = s.tetkik_id
             where s.id = @p0
            """, islem, [istemSatirId],
            o => new { Id = o.GetInt32(0), IstemId = o.GetInt32(1),
                       TetkikId = o.GetInt32(2),
                       NumuneId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                       HastaId = o.GetInt32(4), SubeId = o.GetInt32(5),
                       Tur = o.GetInt16(6), Klinik = o.GetString(7),
                       Tani = o.GetString(8) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem satırı bulunamadı.");

        if (s.Tur != 5)
            throw GentegreHatasi.IsKurali(
                "Bu tetkik genetik değil (tetkik kartında sonuç türü 'Genetik' olmalı).");

        if (await baglanti.TekDegerAsync<int>(
                "select count(*) from public.lab_genetik_vaka where istem_satir_id = @p0",
                islem, [istemSatirId], iptal) > 0)
            throw GentegreHatasi.IsKurali("Bu tetkik için vaka zaten açılmış.");

        var vakaNo = await baglanti.TekDegerAsync<string>("""
            select 'GEN-' || to_char(current_date, 'YYYY') || '/' ||
                   public.fn_numara_sirada(
                       'lab_genetik_vaka.vaka_no|Y' || to_char(current_date, 'YYYY'),
                       'lab_genetik_vaka', 'vaka_no',
                       'yil ' || to_char(current_date, 'YYYY'), 4, 1)
            """, islem, [], iptal) ?? "";

        // Hedef bitiş panelin TAT'ından: genetikte süre gün/hafta ölçeğinde,
        //   dakikalık TAT alanı anlamsız kalırdı.
        var id = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_genetik_vaka
                   (vaka_no, istem_satir_id, istem_id, numune_id, tetkik_id, hasta_id,
                    panel_id, endikasyon, tani_icd, aile_oykusu, ana_vaka_id, aile_rolu,
                    durum, hedef_bitis, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11,
                    @p12,
                    now() + make_interval(days =>
                        coalesce((select p.hedef_tat_gun from public.lab_genetik_panel p
                                   where p.id = @p6), 21)),
                    @p13, @p14)
            returning id
            """, islem,
            [vakaNo, s.Id, s.IstemId, s.NumuneId, s.TetkikId, s.HastaId, istek.PanelId,
             string.IsNullOrWhiteSpace(istek.Endikasyon) ? s.Klinik : istek.Endikasyon,
             string.IsNullOrWhiteSpace(istek.TaniIcd) ? s.Tani : istek.TaniIcd,
             istek.AileOykusu ?? "", istek.AnaVakaId, istek.AileRolu ?? 1, Numune,
             s.SubeId, baglam.KullaniciId], iptal);

        await baglanti.CalistirAsync("""
            update public.lab_istem_satir set durum = 2 where id = @p0 and durum in (1, 6)
            """, islem, [s.Id], iptal);

        await islem.CommitAsync(iptal);
        return (id, vakaNo);
    }

    /// <summary>
    /// Onam kaydı. Tesadüfi bulgu tercihi RAPORLAMAYI değiştirir; onamsız
    /// vaka onaylanamaz.
    /// </summary>
    public async Task<string> OnamAsync(int vakaId, OnamIstegi istek,
                                        IstekBaglami baglam, CancellationToken iptal)
    {
        if (istek.TesadufiBulgu is not (1 or 2))
            throw GentegreHatasi.Dogrulama("Tesadüfi bulgu tercihi belirtilmeli.",
                [new("tesadufiBulgu", "1 istiyor · 2 istemiyor")]);

        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_genetik_vaka
               set onam_surum = @p1, onam_tarihi = now(), tesadufi_bulgu = @p2,
                   veri_saklama_yil = coalesce(@p3, veri_saklama_yil),
                   arastirma_izni = @p4, degistiren = @p5, degistirme_tarihi = now()
             where id = @p0 and durum <> 7
            """, [vakaId, istek.Surum, istek.TesadufiBulgu, istek.VeriSaklamaYil,
                  (short)((istek.ArastirmaIzni ?? false) ? 1 : 0), baglam.KullaniciId],
            iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali("Onaylanmış vakanın onamı değiştirilemez.");

        // Hasta istemiyorsa ikincil bulgular ANINDA raporlamadan çıkar:
        //   tercihi kaydedip raporda bırakmak, onamı kâğıt üstünde bırakırdı.
        if (istek.TesadufiBulgu == 2)
            await _veri.CalistirAsync("""
                update public.lab_varyant set raporla = 0
                 where vaka_id = @p0 and ikincil_bulgu = 1
                """, [vakaId], iptal);

        return istek.TesadufiBulgu == 2
            ? "Onam kaydedildi - tesadüfi (ikincil) bulgular raporlanmayacak."
            : "Onam kaydedildi - tesadüfi bulgular da raporlanacak.";
    }

    public async Task<string> IzolasyonAsync(int vakaId, IzolasyonIstegi istek,
                                             IstekBaglami baglam, CancellationToken iptal)
    {
        await _veri.CalistirAsync("""
            update public.lab_genetik_vaka
               set izolasyon_tarihi = now(), dna_konsantrasyon = @p1, dna_saflik = @p2,
                   izolasyon_notu = @p3,
                   durum = case when durum < @p4 then @p4 else durum end,
                   degistiren = @p5, degistirme_tarihi = now()
             where id = @p0
            """, [vakaId, istek.Konsantrasyon, istek.Saflik, istek.Not ?? "",
                  Izolasyon, baglam.KullaniciId], iptal);

        // DÜŞÜK SAFLIK SESSİZ GEÇMEZ: A260/280 < 1.7 protein/fenol bulaşına
        //   işaret eder ve yanlış negatif üretir. Kaydı engellemek yerine
        //   uyarı döneriz - karar teknisyenin.
        return istek.Saflik < 1.7m
            ? $"İzolasyon kaydedildi. UYARI: A260/280 = {istek.Saflik:0.00} düşük "
              + "(protein/fenol bulaşı) - yeniden izolasyon değerlendirilmeli."
            : "İzolasyon kaydedildi.";
    }

    // =================================================================== run

    /// <summary>Vakayı bir dizileme run'ına alır; run yoksa açar.</summary>
    public async Task<(int RunId, string RunKodu)> RunaAlAsync(int vakaId,
        RunaAlIstegi istek, IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var subeId = await baglanti.TekDegerAsync<int>(
            "select sube_id from public.lab_genetik_vaka where id = @p0",
            islem, [vakaId], iptal);

        int runId;
        string runKodu;
        if (istek.RunId is > 0)
        {
            runId = istek.RunId.Value;
            runKodu = await baglanti.TekDegerAsync<string>(
                "select kod from public.lab_genetik_run where id = @p0",
                islem, [runId], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Run bulunamadı.");
        }
        else
        {
            runKodu = string.IsNullOrWhiteSpace(istek.RunKodu)
                ? await baglanti.TekDegerAsync<string>("""
                    select 'RUN-' || public.fn_numara_sirada(
                        'lab_genetik_run.kod', 'lab_genetik_run', 'kod', '', 4, 1)
                    """, islem, [], iptal) ?? ""
                : istek.RunKodu;

            runId = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_genetik_run
                       (kod, cihaz_adi, kit, kit_lot, flow_cell, durum, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 2, @p5, @p6)
                returning id
                """, islem,
                [runKodu, istek.CihazAdi ?? "", istek.Kit ?? "", istek.KitLot ?? "",
                 istek.FlowCell ?? "", subeId, baglam.KullaniciId], iptal);
        }

        await baglanti.CalistirAsync("""
            insert into public.lab_genetik_run_ornek (run_id, vaka_id, barkod_index, ekleyen)
            values (@p0, @p1, @p2, @p3)
            on conflict (run_id, vaka_id) do nothing
            """, islem, [runId, vakaId, istek.BarkodIndex ?? "", baglam.KullaniciId],
            iptal);

        await baglanti.CalistirAsync("""
            update public.lab_genetik_run r
               set ornek_sayisi = (select count(*) from public.lab_genetik_run_ornek x
                                    where x.run_id = r.id)
             where r.id = @p0
            """, islem, [runId], iptal);

        await baglanti.CalistirAsync("""
            update public.lab_genetik_vaka
               set run_id = @p1, durum = case when durum < @p2 then @p2 else durum end,
                   degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, islem, [vakaId, runId, Runda, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);
        return (runId, runKodu);
    }

    /// <summary>
    /// Run/örnek kalite metrikleri. Kontrolü geçmeyen ya da kapsaması düşük
    /// örnekte NEGATİF sonuç da güvenilmezdir - metrikler rapora girer.
    /// </summary>
    public async Task<string> KaliteAsync(int vakaId, KaliteIstegi istek,
                                          IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await baglanti.CalistirAsync("""
            update public.lab_genetik_vaka
               set kapsama_yuzde = coalesce(@p1, kapsama_yuzde),
                   ort_derinlik = coalesce(@p2, ort_derinlik),
                   kontaminasyon = coalesce(@p3, kontaminasyon),
                   cinsiyet_dogrulama = coalesce(@p4, cinsiyet_dogrulama),
                   fastq_yol = coalesce(nullif(@p5, ''), fastq_yol),
                   bam_yol = coalesce(nullif(@p6, ''), bam_yol),
                   vcf_yol = coalesce(nullif(@p7, ''), vcf_yol),
                   ham_hash = coalesce(nullif(@p8, ''), ham_hash),
                   durum = case when durum < @p9 then @p9 else durum end,
                   degistiren = @p10, degistirme_tarihi = now()
             where id = @p0
            """, islem,
            [vakaId, istek.KapsamaYuzde, istek.OrtDerinlik, istek.Kontaminasyon,
             istek.CinsiyetDogrulama, istek.FastqYol ?? "", istek.BamYol ?? "",
             istek.VcfYol ?? "", istek.HamHash ?? "", Analiz, baglam.KullaniciId], iptal);

        await baglanti.CalistirAsync("""
            update public.lab_genetik_run_ornek
               set q30 = coalesce(@p1, q30), okuma_sayisi = coalesce(@p2, okuma_sayisi),
                   ort_derinlik = coalesce(@p3, ort_derinlik),
                   kapsama_yuzde = coalesce(@p4, kapsama_yuzde),
                   kontaminasyon = coalesce(@p5, kontaminasyon),
                   kalite = coalesce(@p6, kalite),
                   degistiren = @p7, degistirme_tarihi = now()
             where vaka_id = @p0
            """, islem,
            [vakaId, istek.Q30, istek.OkumaSayisi, istek.OrtDerinlik, istek.KapsamaYuzde,
             istek.Kontaminasyon, istek.Kalite, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);

        // KAPSAMA UYARISI: hedefin %95'inden azı yeterli derinlikteyse
        //   "varyant yok" demek, bakılamayan bölgeyi temiz saymaktır.
        return istek.KapsamaYuzde is { } k && k < 95m
            ? $"Kalite kaydedildi. UYARI: hedef kapsama %{k:0.0} - kapsanamayan "
              + "bölgeler raporun sınırlılıklarında belirtilmeli."
            : "Kalite metrikleri kaydedildi.";
    }

    // =============================================================== varyant

    /// <summary>
    /// Varyant ekler; sınıf ACMG kanıtlarından TÜRETİLİR (tetikleyici).
    /// Laboratuvar bilgi bankasında aynı varyant varsa önceki yorum uyarı
    /// olarak döner - aynı varyantın iki hastada farklı sınıflanması
    /// laboratuvarın en sık kalite kusurudur.
    /// </summary>
    public async Task<VaryantSonucu> VaryantAsync(int vakaId, VaryantIstegi istek,
        IstekBaglami baglam, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(istek.GenSembol) || string.IsNullOrWhiteSpace(istek.HgvsC))
            throw GentegreHatasi.Dogrulama("Gen ve HGVS c. zorunlu.",
                [new("hgvsC", "Örnek: NM_000256.3:c.1504C>T için c.1504C>T")]);

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var vaka = await baglanti.TekAsync("""
            select durum, tesadufi_bulgu from public.lab_genetik_vaka where id = @p0
            """, islem, [vakaId],
            o => new { Durum = o.GetInt16(0), Tesadufi = o.GetInt16(1) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Vaka bulunamadı.");

        if (vaka.Durum == Onayli)
            throw GentegreHatasi.IsKurali(
                "Onaylı vakaya varyant eklenemez - yeni rapor sürümü açın.");

        var gen = await baglanti.TekAsync("""
            select id, transkript, kalitim from public.lab_gen
             where upper(sembol) = upper(@p0)
            """, islem, [istek.GenSembol],
            o => new { Id = o.GetInt32(0), Transkript = o.GetString(1),
                       Kalitim = o.GetInt16(2) }, iptal);

        var banka = await baglanti.TekAsync("""
            select sinif, surum, kanit_ozeti, degerlendirme_tarihi
              from public.lab_varyant_bilgi
             where upper(gen_sembol) = upper(@p0) and hgvs_c = @p1
            """, islem, [istek.GenSembol, istek.HgvsC],
            o => new { Sinif = o.GetInt16(0), Surum = o.GetInt16(1),
                       Ozet = o.GetString(2), Tarih = o.GetDateTime(3) }, iptal);

        var id = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_varyant
                   (vaka_id, gen_id, gen_sembol, transkript, hgvs_c, hgvs_p, zigosite,
                    kalitim, derinlik, vaf, gnomad_af, clinvar, clinvar_id,
                    acmg_kriterler, ikincil_bulgu, yorum, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11,
                    @p12, @p13, @p14, @p15, @p16)
            returning id
            """, islem,
            [vakaId, gen?.Id, istek.GenSembol.ToUpperInvariant(),
             string.IsNullOrWhiteSpace(istek.Transkript) ? gen?.Transkript ?? ""
                                                         : istek.Transkript,
             istek.HgvsC, istek.HgvsP ?? "", istek.Zigosite ?? 1,
             (short)(gen?.Kalitim ?? 0), istek.Derinlik, istek.Vaf, istek.GnomadAf,
             istek.ClinVar ?? "", istek.ClinVarId ?? "",
             istek.AcmgKriterler ?? [], (short)((istek.IkincilBulgu ?? false) ? 1 : 0),
             istek.Yorum ?? "", baglam.KullaniciId], iptal);

        var yeni = await baglanti.TekAsync(
            "select sinif, raporla from public.lab_varyant where id = @p0",
            islem, [id],
            o => new { Sinif = o.GetInt16(0), Raporla = o.GetInt16(1) == 1 }, iptal)!;

        // Hasta tesadüfi bulgu istemiyorsa ikincil bulgu raporlanmaz.
        if (vaka.Tesadufi == 2 && (istek.IkincilBulgu ?? false))
            await baglanti.CalistirAsync(
                "update public.lab_varyant set raporla = 0 where id = @p0",
                islem, [id], iptal);

        // BİLGİ BANKASI: ilk görülüşte kayıt açılır, sonrakilerde sayaç artar.
        //   Sınıf bankadakinden farklıysa uyarı döner - sessizce kabul etmek,
        //   aynı varyantın iki hastada farklı sınıflanması demektir.
        await baglanti.CalistirAsync("""
            insert into public.lab_varyant_bilgi
                   (gen_sembol, transkript, hgvs_c, hgvs_p, acmg_kriterler, sinif,
                    degerlendiren_id, ekleyen)
            values (upper(@p0), @p1, @p2, @p3, @p4, @p5, @p6, @p6)
            on conflict (upper(gen_sembol), hgvs_c) do update
               set gorulme_sayisi = public.lab_varyant_bilgi.gorulme_sayisi + 1
            """, islem,
            [istek.GenSembol, istek.Transkript ?? gen?.Transkript ?? "", istek.HgvsC,
             istek.HgvsP ?? "", istek.AcmgKriterler ?? [], yeni!.Sinif,
             baglam.KullaniciId], iptal);

        await baglanti.CalistirAsync("""
            update public.lab_genetik_vaka
               set durum = case when durum < @p1 then @p1 else durum end,
                   degistiren = @p2, degistirme_tarihi = now()
             where id = @p0
            """, islem, [vakaId, Analiz, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);

        var uyari = banka is not null && banka.Sinif != yeni.Sinif
            ? $"Bu varyant laboratuvarda daha önce sınıf {banka.Sinif} olarak "
              + $"değerlendirilmiş ({banka.Tarih:dd.MM.yyyy}, sürüm {banka.Surum}). "
              + "Farklı sınıflama gerekçelendirilmeli."
            : null;

        return new VaryantSonucu(id, yeni.Sinif, SinifAdi(yeni.Sinif),
                                 yeni.Raporla && !(vaka.Tesadufi == 2
                                                   && (istek.IkincilBulgu ?? false)),
                                 uyari);
    }

    public static string SinifAdi(short sinif) => sinif switch
    {
        1 => "Benign",
        2 => "Olası benign",
        4 => "Olası patojenik",
        5 => "Patojenik",
        _ => "Klinik önemi belirsiz (VUS)",
    };

    /// <summary>
    /// Uzman sınıfı ezer. GEREKÇE ZORUNLU: kural motorunun sonucunu sessizce
    /// değiştirmek, raporun dayanağını görünmez kılar.
    /// </summary>
    public async Task<string> SinifDegistirAsync(int varyantId, short sinif,
        string neden, bool? raporla, IstekBaglami baglam, CancellationToken iptal)
    {
        if (sinif is < 1 or > 5)
            throw GentegreHatasi.Dogrulama("Geçersiz sınıf.",
                [new("sinif", "1 benign … 5 patojenik")]);
        if (string.IsNullOrWhiteSpace(neden))
            throw GentegreHatasi.Dogrulama("Değiştirme gerekçesi zorunlu.",
                [new("neden", "ACMG hesabının neden geçersiz olduğunu yazın.")]);

        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_varyant
               set sinif = @p1, sinif_elle = 1, sinif_neden = @p2,
                   raporla = coalesce(@p3, raporla),
                   degistiren = @p4, degistirme_tarihi = now()
             where id = @p0
            """, [varyantId, sinif, neden,
                  raporla is null ? null : (short)(raporla.Value ? 1 : 0),
                  baglam.KullaniciId], iptal);

        if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Varyant bulunamadı.");
        return $"Sınıf uzman kararıyla '{SinifAdi(sinif)}' yapıldı (gerekçe kayda geçti).";
    }

    /// <summary>Sanger doğrulama isteği / sonucu.</summary>
    public async Task<string> DogrulamaAsync(int varyantId, short durum, string? yontem,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_varyant
               set dogrulama = @p1, dogrulama_yontem = coalesce(nullif(@p2, ''), 'Sanger'),
                   dogrulama_tarihi = case when @p1 >= 2 then now() else dogrulama_tarihi end,
                   degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, [varyantId, durum, yontem ?? "", baglam.KullaniciId], iptal);

        if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Varyant bulunamadı.");

        if (durum == 1)
            await _veri.CalistirAsync("""
                update public.lab_genetik_vaka g
                   set durum = case when g.durum < @p1 then @p1 else g.durum end
                  from public.lab_varyant v
                 where v.id = @p0 and g.id = v.vaka_id
                """, [varyantId, Dogrulama], iptal);

        // DOĞRULANAMAYAN VARYANT RAPORDAN ÇIKAR: dizileme artefaktı olabilir;
        //   raporda bırakmak hastaya olmayan bir tanı koymak olur.
        if (durum == 3)
            await _veri.CalistirAsync(
                "update public.lab_varyant set raporla = 0 where id = @p0",
                [varyantId], iptal);

        return durum switch
        {
            1 => "Doğrulama istendi (Sanger).",
            2 => "Varyant doğrulandı.",
            3 => "Varyant DOĞRULANAMADI - rapordan çıkarıldı.",
            _ => "Doğrulama durumu güncellendi.",
        };
    }

    // ================================================================== onay

    /// <summary>
    /// Uzman onayı: sonuç özeti üretilir, lab_sonuc'a yazılır ve bilgi
    /// bankası bu vakadaki sınıflarla güncellenir.
    ///
    /// <b>Onamsız vaka onaylanamaz</b> (KVKK md. 6) ve <b>doğrulama bekleyen
    /// patojenik varyant varken rapor kapanmaz</b>: tek yöntemle saptanmış
    /// patojenik varyantla hastaya kalıcı tanı konur.
    /// </summary>
    public async Task<string> OnaylaAsync(int vakaId, string? uzmanYorum,
        string? oneriler, string? sinirliliklar, IstekBaglami baglam,
        CancellationToken iptal)
    {
        var v = await _veri.TekAsync("""
            select g.durum, g.istem_satir_id, g.onam_tarihi, g.tesadufi_bulgu,
                   (select count(*) from public.lab_varyant x
                     where x.vaka_id = g.id and x.raporla = 1 and x.sinif >= 4
                       and x.dogrulama in (0, 1)) as dogrulanmamis
              from public.lab_genetik_vaka g where g.id = @p0
            """, [vakaId],
            o => new { Durum = o.GetInt16(0), SatirId = o.GetInt32(1),
                       Onam = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                       Tesadufi = o.GetInt16(3), Dogrulanmamis = o.GetInt64(4) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Vaka bulunamadı.");

        if (v.Durum == Onayli) throw GentegreHatasi.IsKurali("Vaka zaten onaylı.");
        if (v.Durum == 0) throw GentegreHatasi.IsKurali("İptal edilmiş vaka onaylanamaz.");
        if (v.Onam is null || v.Tesadufi == 0)
            throw GentegreHatasi.IsKurali(
                "Onam kaydı yok - genetik veri özel nitelikli kişisel veridir "
                + "(KVKK md. 6), onamsız rapor verilemez.");
        if (v.Dogrulanmamis > 0)
            throw GentegreHatasi.IsKurali(
                $"{v.Dogrulanmamis} patojenik/olası patojenik varyant doğrulanmamış - "
                + "Sanger doğrulaması tamamlanmadan rapor onaylanamaz.");

        var ozet = await _veri.TekDegerAsync<string>(
            "select public.fn_lab_genetik_ozet(@p0)", [vakaId], iptal) ?? "";

        var sonuc = await _lab.SonucYazAsync(
            new LabServisi.SonucIstegi(v.SatirId, ozet, null, uzmanYorum, null),
            null, null, baglam, iptal, otoOnaySerbest: false);
        await _lab.OnaylaAsync(sonuc.SonucId, 2, baglam, iptal);

        await _veri.CalistirAsync("""
            update public.lab_genetik_vaka
               set durum = @p1, onay_id = @p2, onay_zamani = now(), sonuc_ozeti = @p3,
                   uzman_yorum = coalesce(nullif(@p4, ''), uzman_yorum),
                   oneriler = coalesce(nullif(@p5, ''), oneriler),
                   sinirliliklar = coalesce(nullif(@p6, ''), sinirliliklar),
                   sonuc_id = @p7, degistiren = @p2, degistirme_tarihi = now()
             where id = @p0
            """, [vakaId, Onayli, baglam.KullaniciId, ozet, uzmanYorum ?? "",
                  oneriler ?? "", sinirliliklar ?? "", sonuc.SonucId], iptal);

        // BİLGİ BANKASI GÜNCELLENİR: sınıf değiştiyse sürüm artar ve eski
        //   vakalar v_lab_varyant_yeniden listesine düşer.
        await _veri.CalistirAsync("""
            update public.lab_varyant_bilgi b
               set sinif = v.sinif, acmg_kriterler = v.acmg_kriterler,
                   surum = b.surum + 1, degerlendirme_tarihi = now(),
                   degerlendiren_id = @p1, degistiren = @p1, degistirme_tarihi = now()
              from public.lab_varyant v
             where v.vaka_id = @p0 and v.raporla = 1
               and upper(b.gen_sembol) = upper(v.gen_sembol) and b.hgvs_c = v.hgvs_c
               and b.sinif <> v.sinif
            """, [vakaId, baglam.KullaniciId], iptal);

        return $"Vaka onaylandı: {ozet}";
    }

    public async Task<string> IptalAsync(int vakaId, string neden, IstekBaglami baglam,
                                         CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(neden))
            throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                [new("neden", "Vakanın neden iptal edildiğini yazın.")]);

        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_genetik_vaka
               set durum = 0, uzman_yorum = case when uzman_yorum = '' then @p1
                                                 else uzman_yorum || ' | ' || @p1 end,
                   degistiren = @p2, degistirme_tarihi = now()
             where id = @p0 and durum <> 7
            """, [vakaId, "İptal: " + neden, baglam.KullaniciId], iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali("Onaylı vaka iptal edilemez.");

        await _veri.CalistirAsync("""
            update public.lab_istem_satir s set durum = 6
              from public.lab_genetik_vaka g
             where g.id = @p0 and s.id = g.istem_satir_id and s.durum <> 0
            """, [vakaId], iptal);

        return "Vaka iptal edildi - tetkik tekrar numune bekliyor.";
    }
}
