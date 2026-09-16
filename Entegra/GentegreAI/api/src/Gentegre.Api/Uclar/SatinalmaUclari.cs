using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SATINALMA İŞ AKIŞI UÇLARI — TALEP ve ONAY ZİNCİRİ (724).
///
/// ONAY ZİNCİRİNİ SİSTEM KURAR, KULLANICI SEÇMEZ. "Kime göndereyim" sorusu
/// kullanıcıya sorulsaydı, zincir her talepte yeniden icat edilir ve pahalı
/// alım küçük bir imzayla geçebilirdi. Basamaklar TUTAR + BÜTÇE DURUMU'ndan
/// türer; eşikler `referans` tablosunda (kurum ayarı), kodda değil.
///
/// BASAMAK ATLANMAZ. Karar hep BEKLEYEN EN KÜÇÜK basamağa yazılır; üst
/// yönetim, birim sorumlusu onaylamadan onaylayamaz. Atlanabilseydi zincir
/// bir sıralama değil, bir öneri listesi olurdu.
///
/// SÖZLÜ ONAYIN SÜRESİ VAR. Acil alım sözlü onayla başlar (durum 4) ama
/// `yazili_son` damgası konur; süresi geçen sözlü onay listede ayrı görünür.
/// Süresiz bıraksaydık "sözlü onay aldık" kalıcı bir kaçış yolu olurdu.
///
/// TALEP `belge` DEĞİL, SİPARİŞ BELGEDİR. `/siparise` ucu talebi tür 9 alış
/// siparişine çevirir ve satırları `belge_satir`a taşır; talep satırı hangi
/// belge satırına gittiğini `belge_satir_id` ile tutar (bkz. `KorunanSatirSql`).
/// </summary>
public static partial class SatinalmaUclari
{
    // islem_log.tablo_id - KartKatalogu.Satinalma ile aynı.
    private const int LogTalep = 1241;
    private const int LogOnay = 1243;
    private const int LogTeklif = 1244;
    private const int LogKabul = 1247;
    private const int LogOlay = 1250;
    /// <summary>Sipariş takip uzantısı ve fatura kontrolü - kartları yok.</summary>
    private const int LogSiparis = 1251;
    private const int LogFatura = 1252;

    // talep.durum: 0 taslak · 1 onayda · 2 onaylandı · 3 reddedildi
    //              4 teklifte · 5 siparişe dönüştü · 6 birleştirildi · 8 iptal
    private const short TalepTaslak = 0;
    private const short TalepOnayda = 1;
    private const short TalepOnaylandi = 2;
    private const short TalepReddedildi = 3;
    private const short TalepTeklifte = 4;
    private const short TalepSiparise = 5;
    private const short TalepBirlestirildi = 6;
    private const short TalepIptal = 8;

    // ---------------------------------------------------------- istekler ----

    public sealed class TalepGonderIstegi
    {
        /// <summary>Zinciri yeniden kur (basamaklar değiştiyse). Karar verilmiş basamak korunur.</summary>
        public bool ZinciriYenile { get; set; }
    }

    public sealed class OnayKararIstegi
    {
        /// <summary>onayla · reddet · bilgi-iste · sozlu-onay</summary>
        public string Karar { get; set; } = "";
        public string? Gerekce { get; set; }
        /// <summary>Sözlü onayda yazılı tamamlama süresi (saat). Boşsa kurum ayarı.</summary>
        public int? YaziliSaat { get; set; }
    }

    public sealed class BirlestirIstegi
    {
        public long HedefId { get; set; }
        public IReadOnlyList<long> KaynakIdler { get; set; } = [];
    }

    public sealed class SipariseIstegi
    {
        public int TarafId { get; set; }
        public long? TeklifId { get; set; }
        public int? SozlesmeId { get; set; }
        public DateTime? SozTeslim { get; set; }
        public int? DepoId { get; set; }
        public string? Aciklama { get; set; }
    }

    // ============================================================= kayıt ==
    public static void SatinalmaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/satinalma").WithTags("Satınalma").RequireAuthorization();

        TalepUclari(grup);
        TeklifUclari(grup);
        SiparisUclari(grup);
        KarekodUclari(grup);
        ItsUclari(grup);
    }

    // ============================================================= talep ==
    private static void TalepUclari(RouteGroupBuilder grup)
    {
        // ONAYA GÖNDER: zinciri kurar, durumu "onayda"ya alır.
        grup.MapPost("/talep/{id:long}/gonder", async (
            long id, TalepGonderIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.talep", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var t = await baglanti.TekAsync("""
                select t.durum, t.tahmini_tutar as "tahminiTutar",
                       t.butce_kalem_id as "butceKalemId", t.oncelik, t.tarih,
                       (select count(*) from public.satinalma_talep_satir s
                         where s.talep_id = t.id) as "satirSayisi",
                       -- NULLIF ŞART: `tahmini_tutar` NOT NULL DEFAULT 0'dır,
                       --   `coalesce` onu hiçbir zaman atlamaz ve satır tutarı
                       --   hep 0 çıkardı - zincir de en kısa hâline düşerdi
                       --   ("yazmayan az imzayla geçer").
                       (select coalesce(sum(coalesce(nullif(s.tahmini_tutar, 0),
                               coalesce(s.son_alis_fiyat, 0) * s.miktar)), 0)
                          from public.satinalma_talep_satir s
                         where s.talep_id = t.id) as "satirTutar",
                       (select count(*) from public.satinalma_onay o
                         where o.talep_id = t.id and o.durum <> 0) as "kararliBasamak"
                  from public.satinalma_talep t where t.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");

            var durum = Convert.ToInt16(t["durum"] ?? (short)0);
            if (durum is TalepReddedildi or TalepIptal or TalepBirlestirildi)
                throw GentegreHatasi.IsKurali("Kapanmış talep onaya gönderilemez.");
            if (durum >= TalepOnaylandi)
                throw GentegreHatasi.IsKurali("Bu talep zaten onaylanmış.");
            if (Convert.ToInt32(t["satirSayisi"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali("Satırı olmayan talep onaya gönderilemez.");

            if (durum == TalepOnayda && !istek.ZinciriYenile)
                throw GentegreHatasi.IsKurali(
                    "Talep zaten onayda - zinciri yeniden kurmak için `zinciriYenile` gerekir.");

            // TUTAR: başlıktaki tahmin boşsa satırlardan türer. Boş bırakılan
            //   bir tutar zinciri en kısa hâline düşürürdü - "yazmayan az
            //   imzayla geçer" gibi bir kural olamaz.
            var tutar = t["tahminiTutar"] is { } tt && Convert.ToDecimal(tt) > 0
                ? Convert.ToDecimal(tt)
                : Convert.ToDecimal(t["satirTutar"] ?? 0m);

            var butceDurumu = await ButceDurumuAsync(baglanti, null,
                t["butceKalemId"] as int?, tutar, iptal);

            var basamaklar = await ZincirKurAsync(baglanti, tutar, butceDurumu, iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // KARAR VERİLMİŞ BASAMAK SİLİNMEZ. Zincir yenilenirken verilmiş
            //   imzaları da silseydik, onaylayan kişinin kaydı kaybolur ve
            //   zincir "hiç onaylanmamış" görünürdü.
            await baglanti.CalistirAsync("""
                delete from public.satinalma_onay
                 where talep_id = @p0 and durum = 0
                """, islem, [id], iptal);

            var mevcut = await baglanti.ListeAsync<int>("""
                select basamak from public.satinalma_onay where talep_id = @p0
                """, islem, [id], o => o.GetInt16(0), iptal);

            var eklenen = 0;
            foreach (var (basamak, rol) in basamaklar)
            {
                if (mevcut.Contains(basamak)) continue;
                await baglanti.CalistirAsync("""
                    insert into public.satinalma_onay (talep_id, basamak, rol, durum, ekleyen)
                    values (@p0, @p1, @p2, 0, @p3)
                    """, islem, [id, basamak, rol, baglam.KullaniciId], iptal);
                eklenen++;
            }

            await baglanti.CalistirAsync("""
                update public.satinalma_talep
                   set durum = @p1, tahmini_tutar = @p2,
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, TalepOnayda, tutar, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    durum = TalepOnayda, tutar, butceDurumu,
                    basamaklar = basamaklar.Select(b => new { b.Basamak, b.Rol }),
                    eklenen
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                durum = TalepOnayda, tutar, butceDurumu,
                basamaklar = basamaklar.Select(b => new { basamak = b.Basamak, rol = b.Rol }),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // BASAMAK KARARI. Hep BEKLEYEN EN KÜÇÜK basamağa yazılır.
        grup.MapPost("/talep/{id:long}/karar", async (
            long id, OnayKararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);

            var karar = (istek.Karar ?? "").Trim().ToLowerInvariant();
            // onay durumu: 0 bekliyor · 1 onaylandı · 2 reddedildi
            //              3 bilgi istendi · 4 sözlü onay
            var kararKodu = karar switch
            {
                "onayla" => (short)1,
                "reddet" => (short)2,
                "bilgi-iste" => (short)3,
                "sozlu-onay" => (short)4,
                _ => throw GentegreHatasi.Dogrulama("Bilinmeyen karar.",
                        new AlanHatasi("karar", "onayla · reddet · bilgi-iste · sozlu-onay"))
            };

            if (kararKodu is 2 or 3 && string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("gerekce", "Ret ve bilgi isteğinde gerekçe zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var t = await baglanti.TekAsync("""
                select t.durum,
                       (select min(o.basamak) from public.satinalma_onay o
                         where o.talep_id = t.id and o.durum in (0, 3)) as "bekleyen",
                       (select count(*) from public.satinalma_onay o
                         where o.talep_id = t.id) as "basamakSayisi"
                  from public.satinalma_talep t where t.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");

            if (Convert.ToInt16(t["durum"] ?? (short)0) != TalepOnayda)
                throw GentegreHatasi.IsKurali("Onayda olmayan talepte karar verilemez.");
            if (t["bekleyen"] is null)
                throw GentegreHatasi.IsKurali("Bekleyen onay basamağı yok.");

            var basamak = Convert.ToInt16(t["bekleyen"]);

            var o = await baglanti.TekAsync("""
                select o.id, o.rol from public.satinalma_onay o
                 where o.talep_id = @p0 and o.basamak = @p1
                """, null, [id, basamak], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Onay basamağı bulunamadı.");

            // YETKİ BASAMAĞIN ROLÜNE GÖRE (724 yetkileri). Birim sorumlusunun
            //   yetkisiyle üst yönetim basamağı imzalanamaz - zincirin anlamı
            //   farklı kişilerin bakması.
            var rol = Convert.ToInt16(o["rol"] ?? (short)1);
            baglam.AksiyonIste(rol switch
            {
                1 => "satinalma.onay_birim",
                2 => "satinalma.onay_satinalma",
                4 => "satinalma.onay_satinalma",
                _ => "satinalma.onay_ust"
            });

            var simdi = DateTime.Now;
            // SÖZLÜ ONAYIN YAZILI TAMAMLAMA SÜRESİ - kurum ayarı, varsayılan 24 saat.
            var yaziliSaat = istek.YaziliSaat
                ?? await AyarSayiAsync(baglanti, "satinalma.sozlu_onay_saat", 24, iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.satinalma_onay
                   set durum = @p2, onaylayan_id = @p3, karar_zamani = @p4,
                       gerekce = coalesce(nullif(@p5, ''), gerekce),
                       yazili_son = case when @p2 = 4 then @p4 + (@p6 || ' hours')::interval
                                         else yazili_son end,
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where talep_id = @p0 and basamak = @p1
                """, islem,
                [id, basamak, kararKodu, baglam.KullaniciId, simdi,
                 istek.Gerekce ?? "", ((int)yaziliSaat).ToString()], iptal);

            short yeniDurum;
            short? sonrakiBasamak = null;

            if (kararKodu == 2)
            {
                // RET ZİNCİRİ BİTİRİR: bekleyen basamakları da kapatırız, yoksa
                //   reddedilmiş bir talep listede hâlâ "onayda" görünürdü.
                await baglanti.CalistirAsync("""
                    update public.satinalma_onay set durum = 2, karar_zamani = @p1,
                           gerekce = 'Talep reddedildi'
                     where talep_id = @p0 and durum = 0
                    """, islem, [id, simdi], iptal);
                yeniDurum = TalepReddedildi;
                await baglanti.CalistirAsync("""
                    update public.satinalma_talep set durum = @p1, red_neden = @p2,
                           degistiren = @p3, degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, islem, [id, yeniDurum, istek.Gerekce ?? "", baglam.KullaniciId], iptal);
            }
            else if (kararKodu == 3)
            {
                // BİLGİ İSTENDİ zinciri DURDURUR ama bitirmez: basamak hâlâ
                //   bekleyendir (durum 3 de bekleyen sayılır), talep onayda kalır.
                yeniDurum = TalepOnayda;
            }
            else
            {
                // ONAY (1) ya da SÖZLÜ ONAY (4): sıradaki basamağa geç.
                sonrakiBasamak = await baglanti.TekDegerAsync<short?>("""
                    select min(o.basamak) from public.satinalma_onay o
                     where o.talep_id = @p0 and o.durum in (0, 3)
                    """, islem, [id], iptal);

                yeniDurum = sonrakiBasamak is null ? TalepOnaylandi : TalepOnayda;
                await baglanti.CalistirAsync("""
                    update public.satinalma_talep set durum = @p1,
                           degistiren = @p2, degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, islem, [id, yeniDurum, baglam.KullaniciId], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogOnay,
                Convert.ToInt64(o["id"]), baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { karar, basamak, rol, gerekce = istek.Gerekce, talepDurum = yeniDurum },
                LogTalep, id, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                karar, basamak, talepDurum = yeniDurum, sonrakiBasamak,
                yaziliSon = kararKodu == 4 ? simdi.AddHours((double)yaziliSaat) : (DateTime?)null,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // TALEPLERİ BİRLEŞTİR. Aynı kalemi ayrı ayrı sipariş etmek pazarlık
        //   gücünü de kargo parasını da harcar.
        grup.MapPost("/talep/birlestir", async (
            BirlestirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.talep", Islem.Degistir);

            if (istek.KaynakIdler.Count == 0)
                throw GentegreHatasi.Dogrulama("Birleştirilecek talep seçilmedi.",
                    new AlanHatasi("kaynakIdler", "En az bir talep seçilmeli."));
            if (istek.KaynakIdler.Contains(istek.HedefId))
                throw GentegreHatasi.Dogrulama("Hedef talep kaynak olamaz.",
                    new AlanHatasi("kaynakIdler", "Hedef talep kendi içine birleştirilemez."));

            await using var baglanti = await veri.AcAsync(iptal);

            var hedef = await baglanti.TekAsync("""
                select t.durum, t.talep_no as "talepNo" from public.satinalma_talep t
                 where t.id = @p0
                """, null, [istek.HedefId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Hedef talep bulunamadı.");

            // HEDEF HENÜZ ONAYLANMAMIŞ OLMALI: onaylanmış bir talebe satır
            //   eklemek, onaylanan tutarı imzasız büyütmektir.
            if (Convert.ToInt16(hedef["durum"] ?? (short)0) >= TalepOnaylandi)
                throw GentegreHatasi.IsKurali(
                    "Onaylanmış talebe satır eklenemez - onaylanan tutar imzasız büyümemeli.");

            var kaynaklar = istek.KaynakIdler.ToArray();
            var uygunsuz = await baglanti.ListeAsync<string>("""
                select t.talep_no || ' (' || t.durum || ')'
                  from public.satinalma_talep t
                 where t.id = any(@p0) and t.durum >= @p1
                """, null, [kaynaklar, TalepOnaylandi], o => o.GetString(0), iptal);

            if (uygunsuz.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Onaylanmış/kapanmış talep birleştirilemez: " + string.Join(", ", uygunsuz));

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var tasinan = await baglanti.CalistirAsync("""
                update public.satinalma_talep_satir
                   set talep_id = @p0,
                       aciklama = trim(both ' ' from coalesce(aciklama, '')
                                  || ' · ' || (select 'Kaynak: ' || k.talep_no
                                                 from public.satinalma_talep k
                                                where k.id = satinalma_talep_satir.talep_id))
                 where talep_id = any(@p1)
                """, islem, [istek.HedefId, kaynaklar], iptal);

            // KAYNAK TALEP SİLİNMEZ: "bu talebi kim açmıştı, ne oldu" sorusu
            //   birleştirmeden sonra da sorulur. Durumu 6 (birleştirildi) olur
            //   ve `birlestirilen_id` hedefi gösterir.
            await baglanti.CalistirAsync("""
                update public.satinalma_talep
                   set durum = @p2, birlestirilen_id = @p0,
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = any(@p1)
                """, islem, [istek.HedefId, kaynaklar, TalepBirlestirildi, baglam.KullaniciId], iptal);

            // Bekleyen onay basamakları da kapanır - birleştirilmiş talebin
            //   onayı hedef talepte alınacak.
            await baglanti.CalistirAsync("""
                update public.satinalma_onay set durum = 2, karar_zamani = now(),
                       gerekce = 'Talep birleştirildi'
                 where talep_id = any(@p0) and durum = 0
                """, islem, [kaynaklar], iptal);

            // Hedefin tahmini tutarı satırlardan yeniden hesaplanır.
            var yeniTutar = await baglanti.TekDegerAsync<decimal>("""
                update public.satinalma_talep t
                   set tahmini_tutar = (
                        select coalesce(sum(coalesce(nullif(s.tahmini_tutar, 0),
                                coalesce(s.son_alis_fiyat, 0) * s.miktar)), 0)
                          from public.satinalma_talep_satir s where s.talep_id = t.id),
                       degistiren = @p1, degistirme_tarihi = (now())::timestamp
                 where t.id = @p0 returning t.tahmini_tutar
                """, islem, [istek.HedefId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTalep, istek.HedefId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { birlestirilen = kaynaklar, tasinanSatir = tasinan, yeniTutar },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                hedefId = istek.HedefId, birlestirilen = kaynaklar.Length,
                tasinanSatir = tasinan, tahminiTutar = yeniTutar, izlemeNo = baglam.IzlemeNo
            });
        });
    }

    // ------------------------------------------------------- yardımcılar ----

    /// <summary>
    /// BÜTÇE DURUMU: 0 kalem yok · 1 yeterli · 2 aşıyor (uyar) · 3 aşıyor (engel).
    ///
    /// Aşımda ne olacağını KALEM belirler (`butce_kalem.asim_davranis`,
    /// 724): bazı kalemler (ilaç, acil sarf) aşılırsa uyarır, bazıları
    /// (yatırım) durdurur. Tek genel kural koysaydık ya acil alım dururdu ya
    /// bütçe anlamsızlaşırdı. `v_butce_durum` taahhüdü (açık sipariş) de
    /// düşer - aynı para iki kez harcanmasın.
    /// </summary>
    private static async Task<short> ButceDurumuAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, int? butceKalemId,
        decimal tutar, CancellationToken iptal)
    {
        if (butceKalemId is null) return 0;

        var b = await baglanti.TekAsync("""
            select v.kalan, coalesce(k.asim_davranis, 1) as "asimDavranis"
              from public.v_butce_durum v
              join public.butce_kalem k on k.id = v.id
             where v.id = @p0
            """, islem, [butceKalemId], OkuyucuGenisletmeleri.Sozluk, iptal);

        if (b is null) return 0;
        var kalan = Convert.ToDecimal(b["kalan"] ?? 0m);
        if (tutar <= kalan) return 1;

        // 0 uyar · 1 ek onay ister · 2 engeller
        return Convert.ToInt16(b["asimDavranis"] ?? (short)1) switch
        {
            0 => (short)2,
            2 => (short)3,
            _ => (short)2
        };
    }

    /// <summary>
    /// Basamakları TUTAR ve BÜTÇE DURUMUNDAN kurar. Eşikler `referans`ta -
    /// kurum kendi sınırını belirler, kodda sabit bir rakam olamaz.
    ///
    /// rol: 1 birim sorumlusu · 2 satınalma · 3 başhekim/müdür ·
    ///      4 mali işler · 5 yönetim kurulu
    /// </summary>
    private static async Task<List<(short Basamak, short Rol)>> ZincirKurAsync(
        NpgsqlConnection baglanti, decimal tutar, short butceDurumu, CancellationToken iptal)
    {
        var esikSatinalma = await AyarSayiAsync(baglanti, "satinalma.esik_satinalma", 0, iptal);
        var esikMali = await AyarSayiAsync(baglanti, "satinalma.esik_mali", 50_000, iptal);
        var esikUst = await AyarSayiAsync(baglanti, "satinalma.esik_ust", 250_000, iptal);

        // BİRİM SORUMLUSU HER TALEPTE VAR: talebi açan kişinin âmiri, talebin
        //   gerçekten o birimin işi olduğunu söyleyen tek kişidir.
        var zincir = new List<(short, short)> { ((short)1, (short)1) };
        short sira = 2;

        if (tutar >= esikSatinalma) zincir.Add((sira++, 2));
        if (tutar >= esikMali) zincir.Add((sira++, 4));

        // BÜTÇE AŞIMI EK BASAMAK EKLER (mali işler zaten yoksa): bütçesi
        //   olmayan ya da aşan bir harcamanın sorumlusu ayrıca sorulmalı.
        if (butceDurumu is 0 or 2 or 3 && !zincir.Any(z => z.Item2 == 4))
            zincir.Add((sira++, 4));

        if (tutar >= esikUst || butceDurumu == 3) zincir.Add((sira++, 5));

        return zincir.Select(z => ((short)z.Item1, (short)z.Item2)).ToList();
    }

    /// <summary>
    /// SAYISAL KURUM AYARI, VARSAYILANI ÇAĞRI YERİNDE.
    ///
    /// `AyarDeposu.SayiAsync` varsayılanları kendi statik sözlüğünden okur;
    /// oraya yazmak, eşiğin NEDEN o değer olduğu bilgisini kuralın yanından
    /// alıp ayrı bir listeye taşırdı. Burada ayar yoksa çağıranın verdiği
    /// varsayılan geçerli - onay eşiğinin gerekçesi eşiğin yanında duruyor.
    /// </summary>
    private static async Task<decimal> AyarSayiAsync(
        NpgsqlConnection baglanti, string anahtar, decimal varsayilan, CancellationToken iptal)
    {
        var metin = await AyarDeposu.MetinAsync(baglanti, null, anahtar, "", iptal);
        return decimal.TryParse(metin, System.Globalization.NumberStyles.Any,
                   System.Globalization.CultureInfo.InvariantCulture, out var d)
            ? d : varsayilan;
    }
}
