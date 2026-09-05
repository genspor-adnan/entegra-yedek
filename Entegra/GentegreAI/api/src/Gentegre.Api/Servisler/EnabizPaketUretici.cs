using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-NABIZ PAKET ÜRETİMİ (415, Faz 1) — klinik olaydan USS paketine.
///
/// <para><b>Üretim gönderimden ayrıdır.</b> USS test hesabı / KTS tescili
/// henüz yok; paketler yine de üretilir ve kuyrukta bekler. Üretimi kapıya
/// bağlamak, kapı açıldığında geçmiş veriyi kaybetmek olurdu.</para>
///
/// <para><b>İdempotent.</b> Aynı kaynak için aynı içerik ikinci kez paket
/// açmaz (içerik hash'i). Muayene her kaydedildiğinde paket üretmek, USS'ye
/// aynı muayeneyi onlarca kez göndermek demekti.</para>
///
/// <para><b>Doğrulama üretim anında.</b> Zorunlu alan eksikse paket kuyruğa
/// GİRMEZ (durum 0 "eksik alan") ve eksiğin hangi kaynak kolondan gelmesi
/// gerektiği alan satırında yazar. Eksiği gönderim anında bulmak, hatayı
/// hekim ekrandan ayrıldıktan saatler sonra geri getirirdi.</para>
/// </summary>
public sealed class EnabizPaketUretici
{
    private readonly VeriKaynagi _veri;
    private readonly ILogger<EnabizPaketUretici> _gunluk;

    public EnabizPaketUretici(VeriKaynagi veri, ILogger<EnabizPaketUretici> gunluk)
    {
        _veri = veri;
        _gunluk = gunluk;
    }

    /// <summary>Paket kaynağı: 1 başvuru · 2 muayene · 3 reçete.</summary>
    public const short KaynakBasvuru = 1;
    public const short KaynakMuayene = 2;
    public const short KaynakRecete = 3;

    public sealed record Sonuc(long PaketId, string PaketNo, short Durum, int AlanSayisi,
                               IReadOnlyList<string> Eksikler);

    /// <summary>
    /// Verilen paket türü için paketi üretir (varsa mevcudu döndürür).
    ///
    /// Alan çözümleme SQL'de: USS alanı ile kaynak kolon eşlemesi tek yerde
    /// dursun, C# tarafında satır satır okuma/yazma olmasın.
    /// </summary>
    public async Task<Sonuc?> UretAsync(string paketKodu, int kaynakId, int kullaniciId,
                                        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var tur = await baglanti.TekAsync("""
            select t.id, t.uss_paket_kodu, t.sure_siniri_saat, t.zorunlu_alanlar::text, t.aktif
              from public.enabiz_paket_turu t where t.kod = @p0
            """, islem, [paketKodu], o => new
            {
                Id = o.GetInt16(0), Kod = o.GetString(1), Sure = o.GetInt16(2),
                Zorunlu = o.GetString(3), Aktif = o.GetInt16(4),
            }, iptal);

        // Tur kapaliysa paket URETILMEZ: kurum o paketi gondermiyor demektir.
        if (tur is null || tur.Aktif != 1) return null;

        var alanlar = await AlanlariCozAsync(baglanti, islem, paketKodu, kaynakId, iptal);
        if (alanlar.Count == 0) return null;

        var zorunlu = JsonSerializer.Deserialize<string[]>(tur.Zorunlu) ?? [];
        var eksikler = zorunlu
            .Where(z => !alanlar.Any(a => a.Alan == z && a.Deger.Trim().Length > 0))
            .ToList();

        var baglam = await BaglamAlAsync(baglanti, islem, paketKodu, kaynakId, iptal);
        if (baglam is null) return null;

        var hash = Hash(alanlar.Select(a => $"{a.Alan}={a.Deger}"));
        var kaynakTur = MuayeneKaynakli(paketKodu) ? KaynakMuayene : KaynakBasvuru;

        // AYNI ICERIK -> AYNI PAKET. Kaynak yeniden kaydedilince yeni satir
        //   acilmaz; icerik degistiyse yeni paket (guncelleme) acilir.
        //
        // IPTAL EDILEN (durum 5) SAYILMAZ: "kaynaktan yeniden uret" once eski
        //   paketi iptal ediyor; iptali de "mevcut" saymak, kaynak degismediginde
        //   paketi tamamen yok ederdi (iptal edildi, yenisi acilmadi).
        var mevcut = await baglanti.TekAsync("""
            select p.id, p.paket_no, p.durum from public.enabiz_paket p
             where p.paket_turu_id = @p0 and p.kaynak_tur = @p1 and p.kaynak_id = @p2
               and p.islem = 1 and p.icerik_hash = @p3 and p.durum <> 5
             limit 1
            """, islem, [tur.Id, kaynakTur, kaynakId, hash],
            o => new { Id = o.GetInt64(0), No = o.GetString(1), Durum = o.GetInt16(2) },
            iptal);
        if (mevcut is not null)
        {
            await islem.CommitAsync(iptal);
            // Mevcut paketin GERCEK durumu doner: bos paket no ve durum 0
            //   dondurmek, cagiraninin "eksik alan var" sanmasina yol aciyordu.
            return new Sonuc(mevcut.Id, mevcut.No, mevcut.Durum, alanlar.Count, eksikler);
        }

        var durum = (short)(eksikler.Count > 0 ? 0 : 1);
        var paketId = await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_paket
                   (paket_no, paket_turu_id, islem, kaynak_tur, kaynak_id, belge_id,
                    hasta_id, hekim_id, sube_id, olay_tarihi, son_tarih, durum,
                    icerik_hash, ekleyen)
            values ('', @p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7,
                    @p7 + (@p8 || ' hours')::interval, @p9, @p10, @p11)
            returning id
            """, islem,
            [tur.Id, kaynakTur, kaynakId, baglam.BelgeId, baglam.HastaId, baglam.HekimId,
             baglam.SubeId, baglam.OlayTarihi, tur.Sure, durum, hash, kullaniciId], iptal);

        // Paket no INSERT SONRASI: yil + sira, kullanicinin kuyruk ekraninda
        //   arayabilecegi tek kimlik.
        var paketNo = $"PK-{DateTime.Today:yyyy}-{paketId:000000}";
        await baglanti.CalistirAsync(
            "update public.enabiz_paket set paket_no = @p1 where id = @p0",
            islem, [paketId, paketNo], iptal);

        var sira = 0;
        foreach (var a in alanlar)
        {
            var eksikMi = zorunlu.Contains(a.Alan) && a.Deger.Trim().Length == 0;
            await baglanti.CalistirAsync("""
                insert into public.enabiz_paket_alan
                       (paket_id, uss_alan, deger, kaynak_alan, skrs_liste, gecerli, sorun, sira)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7)
                """, islem,
                [paketId, a.Alan, a.Deger, a.Kaynak, a.SkrsListe,
                 (short)(eksikMi ? 0 : 1),
                 eksikMi ? $"Zorunlu alan bos ({a.Kaynak})" : "", (short)sira++], iptal);
        }

        await islem.CommitAsync(iptal);
        _gunluk.LogInformation("e-Nabiz paketi uretildi {No} ({Kod}) durum {Durum}",
            paketNo, paketKodu, durum);

        return new Sonuc(paketId, paketNo, durum, alanlar.Count, eksikler);
    }

    // ------------------------------------------------------------------ alan
    private sealed record AlanDegeri(string Alan, string Deger, string Kaynak, string SkrsListe);

    private sealed record PaketBaglami(int? BelgeId, int? HastaId, int? HekimId, int SubeId,
                                       DateTime OlayTarihi);

    /// <summary>
    /// Paketin kaynağı muayene mi, başvuru mu.
    ///
    /// 106 Hasta Çıkış da MUAYENEDEN doğar (çıkış zamanı muayenenin
    /// tamamlanmasıdır). Tek tek "== MUAYENE" karşılaştırması yüzünden 106
    /// hiç üretilmiyordu: bağlam başvuru sanılıp muayene id'siyle belge
    /// aranıyor, bulunamayınca paket sessizce atlanıyordu.
    /// </summary>
    private static bool MuayeneKaynakli(string paketKodu)
        => paketKodu is "MUAYENE" or "HASTA_CIKIS";

    private static async Task<PaketBaglami?> BaglamAlAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string paketKodu, int kaynakId, CancellationToken iptal)
        => MuayeneKaynakli(paketKodu)
            ? await baglanti.TekAsync("""
                select m.belge_id, m.taraf_id, m.personel_id, m.sube_id,
                       coalesce(m.baslangic, m.muayene_tarihi)
                  from public.muayene m where m.id = @p0
                """, islem, [kaynakId], Oku, iptal)
            : await baglanti.TekAsync("""
                select b.id, b.taraf_id, bb.personel_id, b.sube_id, b.belge_tarihi
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0
                """, islem, [kaynakId], Oku, iptal);

    private static PaketBaglami Oku(NpgsqlDataReader o) => new(
        o.IsDBNull(0) ? null : o.GetInt32(0),
        o.IsDBNull(1) ? null : o.GetInt32(1),
        o.IsDBNull(2) ? null : o.GetInt32(2),
        o.GetInt32(3),
        o.IsDBNull(4) ? DateTime.Now : o.GetDateTime(4));

    /// <summary>
    /// USS alanlarını kaynak kolonlardan çözer.
    ///
    /// Eşleme SQL'de tek yerde: hangi USS alanının nereden geldiği paket
    /// kartında da aynı metinle görünsün (kaynak_alan kolonu). KLİNİK gibi
    /// yerel tanımlar `enabiz_kod_esleme` üzerinden SKRS koduna çevrilir -
    /// departman tablosunda SKRS kodu YOK, olmamalı da: aynı departman farklı
    /// kılavuz sürümünde farklı koda eşlenebilir.
    /// </summary>
    private static Task<List<AlanDegeri>> AlanlariCozAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string paketKodu, int kaynakId, CancellationToken iptal)
    {
        var sql = paketKodu switch
        {
            "HASTA_KABUL" => """
                select 'TesisKodu', coalesce((select e.uygulama_kodu
                                                from public.entegrasyon_hesap e
                                               where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.uygulama_kodu', ''
                  from public.belge b where b.id = @p0
                union all select 'HastaKimlikNo', coalesce(h.vkno, ''), 'taraf.vkno', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id where b.id = @p0
                union all select 'ProtokolNo', coalesce(b.belge_no, ''), 'belge.belge_no', ''
                  from public.belge b where b.id = @p0
                union all select 'KabulZamani', to_char(b.belge_tarihi, 'YYYY-MM-DD"T"HH24:MI:SS'),
                       'belge.belge_tarihi', ''
                  from public.belge b where b.id = @p0
                union all select 'KlinikKodu',
                       coalesce((select k.skrs_kod from public.enabiz_kod_esleme k
                                  where k.esleme_turu = 'KLINIK' and k.yerel_id = bb.bolum_id
                                    and k.aktif = 1 limit 1), ''),
                       'enabiz_kod_esleme.KLINIK', 'SKRS Klinik'
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HekimKimlikNo',
                       coalesce((select t.vkno from public.taraf t where t.id = bb.personel_id), ''),
                       'taraf.vkno (hekim)', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'KabulSekli',
                       coalesce((select k.skrs_kod from public.enabiz_kod_esleme k
                                  where k.esleme_turu = 'BASVURU_TURU'
                                    and k.yerel_kod = bb.basvuru_turu::text
                                    and k.aktif = 1 limit 1), ''),
                       'enabiz_kod_esleme.BASVURU_TURU', 'SKRS Kabul Sekli'
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'OdeyenKurum',
                       coalesce((select t.unvan from public.taraf t
                                  where t.id = bb.odeyen_kurum_id), ''),
                       'taraf_hasta_kurum', ''
                  from public.belge_basvuru bb where bb.id = @p0
                """,

            "MUAYENE" => """
                select 'TesisKodu', coalesce((select e.uygulama_kodu
                                                from public.entegrasyon_hesap e
                                               where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.uygulama_kodu', ''
                  from public.muayene m where m.id = @p0
                union all select 'HastaKimlikNo', coalesce(h.vkno, ''), 'taraf.vkno', ''
                  from public.muayene m join public.taraf h on h.id = m.taraf_id where m.id = @p0
                union all select 'ProtokolNo',
                       coalesce((select b.belge_no from public.belge b where b.id = m.belge_id), ''),
                       'belge.belge_no', ''
                  from public.muayene m where m.id = @p0
                union all select 'MuayeneBaslangicZamani',
                       coalesce(to_char(m.baslangic, 'YYYY-MM-DD"T"HH24:MI:SS'), ''),
                       'muayene.baslangic', ''
                  from public.muayene m where m.id = @p0
                union all select 'MuayeneBitisZamani',
                       coalesce(to_char(coalesce(m.bitis, m.tamamlanma),
                                        'YYYY-MM-DD"T"HH24:MI:SS'), ''),
                       'muayene.bitis', ''
                  from public.muayene m where m.id = @p0
                union all select 'MuayeneTuru', m.tur::text, 'muayene.tur', 'SKRS Muayene Turu'
                  from public.muayene m where m.id = @p0
                union all select 'AnaTani',
                       coalesce((select t.icd_kod from public.tani t
                                  where t.muayene_id = m.id and t.tur = 1 limit 1), ''),
                       'tani (tur=1)', 'ICD-10'
                  from public.muayene m where m.id = @p0
                union all select 'EkTanilar',
                       coalesce((select string_agg(t.icd_kod, ',' order by t.sira)
                                   from public.tani t
                                  where t.muayene_id = m.id and t.tur <> 1), ''),
                       'tani (tur<>1)', 'ICD-10'
                  from public.muayene m where m.id = @p0
                union all select 'Sikayet', left(m.sikayet, 400), 'muayene.sikayet', ''
                  from public.muayene m where m.id = @p0
                union all select 'Hikaye', left(m.hikaye, 400), 'muayene.hikaye', ''
                  from public.muayene m where m.id = @p0
                union all select 'Bulgu', left(m.bulgu_ozet, 400), 'muayene.bulgu_ozet', ''
                  from public.muayene m where m.id = @p0
                -- Vital SON OLCUMDEN: USS Agirlik/Boy/Tansiyon/Ates/Nabiz tek deger ister.
                union all select 'Agirlik',
                       coalesce((select v.kilo_kg::text from public.muayene_vital v
                                  where v.muayene_id = m.id and v.kilo_kg is not null
                                  order by v.zaman desc limit 1), ''),
                       'muayene_vital.kilo_kg', ''
                  from public.muayene m where m.id = @p0
                union all select 'Boy',
                       coalesce((select v.boy_cm::text from public.muayene_vital v
                                  where v.muayene_id = m.id and v.boy_cm is not null
                                  order by v.zaman desc limit 1), ''),
                       'muayene_vital.boy_cm', ''
                  from public.muayene m where m.id = @p0
                union all select 'Tansiyon',
                       coalesce((select v.sistolik || '/' || v.diyastolik
                                   from public.muayene_vital v
                                  where v.muayene_id = m.id and v.sistolik is not null
                                  order by v.zaman desc limit 1), ''),
                       'muayene_vital.sistolik/diyastolik', ''
                  from public.muayene m where m.id = @p0
                union all select 'Ates',
                       coalesce((select v.ates::text from public.muayene_vital v
                                  where v.muayene_id = m.id and v.ates is not null
                                  order by v.zaman desc limit 1), ''),
                       'muayene_vital.ates', ''
                  from public.muayene m where m.id = @p0
                union all select 'Nabiz',
                       coalesce((select v.nabiz::text from public.muayene_vital v
                                  where v.muayene_id = m.id and v.nabiz is not null
                                  order by v.zaman desc limit 1), ''),
                       'muayene_vital.nabiz', ''
                  from public.muayene m where m.id = @p0
                """,

            "HASTA_CIKIS" => """
                select 'TesisKodu', coalesce((select e.uygulama_kodu
                                                from public.entegrasyon_hesap e
                                               where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.uygulama_kodu', ''
                  from public.muayene m where m.id = @p0
                union all select 'HastaKimlikNo', coalesce(h.vkno, ''), 'taraf.vkno', ''
                  from public.muayene m join public.taraf h on h.id = m.taraf_id where m.id = @p0
                union all select 'ProtokolNo',
                       coalesce((select b.belge_no from public.belge b where b.id = m.belge_id), ''),
                       'belge.belge_no', ''
                  from public.muayene m where m.id = @p0
                union all select 'CikisZamani',
                       coalesce(to_char(coalesce(m.tamamlanma, m.bitis),
                                        'YYYY-MM-DD"T"HH24:MI:SS'), ''),
                       'muayene.tamamlanma', ''
                  from public.muayene m where m.id = @p0
                -- CIKIS SEKLI yonlendirmeden TURETILIR: ayri bir kolon acmak,
                --   hekimin ayni bilgiyi iki kez girmesi olurdu.
                union all select 'CikisSekli',
                       case m.yonlendirme when 1 then 'SEVK_KURUM_ICI'
                                          when 2 then 'SEVK_KURUM_DISI'
                                          when 3 then 'YATIS'
                                          when 4 then 'ACIL_SEVK'
                                          else 'SIFA' end,
                       'muayene.yonlendirme', 'SKRS Cikis Sekli'
                  from public.muayene m where m.id = @p0
                union all select 'SevkKlinik', m.sevk_klinik_kod, 'muayene.sevk_klinik_kod',
                       'SKRS Klinik'
                  from public.muayene m where m.id = @p0
                union all select 'SevkTesis', m.sevk_tesis_kodu, 'muayene.sevk_tesis_kodu', ''
                  from public.muayene m where m.id = @p0
                """,

            _ => "",
        };

        return sql.Length == 0
            ? Task.FromResult(new List<AlanDegeri>())
            : baglanti.ListeAsync(sql, islem, [kaynakId],
                o => new AlanDegeri(o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
                                    o.GetString(2), o.GetString(3)), iptal);
    }

    /// <summary>İçerik parmak izi - aynı içerik ikinci kez paket açmasın.</summary>
    private static string Hash(IEnumerable<string> parcalar)
        => Convert.ToHexString(SHA256.HashData(
               Encoding.UTF8.GetBytes(string.Join("\n", parcalar)))).ToLowerInvariant()[..64];
}
