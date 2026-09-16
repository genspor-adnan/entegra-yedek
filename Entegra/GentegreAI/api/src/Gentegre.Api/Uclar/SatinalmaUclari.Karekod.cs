using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Its;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MAL KABUL — KAREKOD / SERİ UÇLARI (734).
///
/// OKUTULAN KUTU `its_bildirim_satir`A YAZILIR, yeni bir tabloya değil:
/// muayenede okutulan kodlar ile İTS'e bildirilecek kodlar AYNI kodlardır
/// (427). İkinci bir tablo açsaydık aynı kutunun iki kaydı olur, biri
/// diğerinden sapar ve "hangisi doğru" sorusu ancak ihtilâf çıkınca sorulurdu.
///
/// ============ TEK TEK OKUTULUR, HEPSİ YA DA HİÇBİRİ DEĞİL ============
/// `/api/its/bildirim` ucu toplu çalışır ve BİR kod bozuksa hiçbirini yazmaz -
/// orada doğru davranış budur, çünkü orası bildirimi AÇAN yerdir. Mal kabulde
/// ise iki yüz kutu tek tek okutulur: yirminci kutu okunamadı diye önceki
/// on dokuzu silmek, sayımı baştan başlatmak olurdu. Bu yüzden burada her kod
/// KENDİ SONUCUYLA döner (yazıldı · mükerrer · beklenmeyen · okunamadı) ve
/// okunabilenler yazılır.
///
/// ============ SONUÇ SINIFLARI ========================================
/// * <b>yazildi</b>   - çözümlendi, muayene satırlarından biriyle eşleşti.
/// * <b>mukerrer</b>  - bu kutu (GTIN + seri) zaten okutulmuş. Serileştirmenin
///                      bütün amacı bu: aynı kutu iki kez sayılmamalı.
///                      `ux_its_karekod_tekil` veritabanı tarafında da korur.
/// * <b>beklenmeyen</b> - kod geçerli ama bu tutanakta o kalem yok. Sipariş
///                      dışı ürün ya da yanlış koliye bakılıyor demektir;
///                      YAZILIR (kayda geçsin) ama işaretlenir.
/// * <b>okunamadi</b> - karekod çözümlenemedi. Yazılmaz.
///
/// KATALOGDA OLMAYAN GTIN de "beklenmeyen"dir: ilaç kataloğu TİTCK'den gelir,
/// orada olmayan bir kutu ya yeni ruhsatlıdır (katalog güncellenmeli) ya da
/// o kutu bize ait değildir. İkisi de kullanıcıya söylenmeli.
/// </summary>
public static partial class SatinalmaUclari
{
    /// <summary>islem_log.tablo_id - İTS bildirim satırı.</summary>
    private const int LogItsSatir = 1254;

    public sealed class KarekodOkutIstegi
    {
        /// <summary>Okutulan ham karekod(lar). Tek tek de, toplu da gönderilebilir.</summary>
        public IReadOnlyList<string> Karekodlar { get; set; } = [];
        /// <summary>Gönderen deponun GLN'i (mal alım bildiriminde İTS ister).</summary>
        public string? KarsiGln { get; set; }
    }

    public sealed class KarekodSil
    {
        public long SatirId { get; set; }
        public string? Gerekce { get; set; }
    }

    // ============================================================ kayıt ==
    private static void KarekodUclari(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------- okutma ----
        grup.MapPost("/kabul/{id:long}/karekod", async (
            long id, KarekodOkutIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Degistir);

            if (istek.Karekodlar is not { Count: > 0 })
                throw GentegreHatasi.Dogrulama("Okutulan karekod yok.",
                    new AlanHatasi("karekodlar", "En az bir karekod gerekli."));

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.sonuc, k.belge_id as "belgeId", k.sube_id as "subeId",
                       b.taraf_id as "tarafId"
                  from public.satinalma_kabul k
                  left join public.belge b on b.id = k.belge_id
                 where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kabul tutanağı bulunamadı.");

            // KARARI VERİLMİŞ TUTANAĞA KUTU EKLENMEZ: sayım kapandı, tutanak
            //   imzalandı. Sonradan okutulan kutu, imzalanmış bir sayımı
            //   değiştirmek olurdu.
            if (Convert.ToInt16(k["sonuc"] ?? (short)0) != 0)
                throw GentegreHatasi.IsKurali(
                    "Kararı verilmiş tutanağa karekod eklenemez.");

            // Muayene satırlarındaki stoklar: eşleşme kümesi.
            var beklenen = await baglanti.ListeAsync("""
                select s.stok_id as "stokId", s.ad, s.skt
                  from public.satinalma_kabul_satir s
                 where s.kabul_id = @p0 and s.stok_id is not null
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // BİLDİRİM BİR KEZ AÇILIR, kutular ona eklenir. Her okutmada yeni
            //   bildirim açsaydık İTS'e iki yüz ayrı bildirim giderdi.
            //   GÖNDERİLMİŞ bildirime eklenmez - yeni bir tanesi açılır;
            //   gönderilmiş bir bildirimi değiştirmek, karşı tarafta olmayan
            //   bir içeriği varmış gibi göstermektir.
            var bildirimId = await baglanti.TekDegerAsync<int?>("""
                select b.id from public.its_bildirim b
                 where b.tur = 1 and b.belge_id = @p0 and b.durum in (0, 1, 4)
                 order by b.id desc limit 1
                """, islem, [k["belgeId"]], iptal);

            if (bildirimId is null)
                bildirimId = await baglanti.TekDegerAsync<int>("""
                    insert into public.its_bildirim (tur, durum, sube_id, test_mi,
                                                     belge_id, karsi_gln, islem_tarihi, ekleyen)
                    select 1, 0, @p0,
                           coalesce((select e.test_mi from public.entegrasyon_hesap e
                                      where e.kod = 'ITS' limit 1), 1),
                           @p1, @p2, current_date, @p3
                    returning id
                    """, islem,
                    [baglam.SubeId ?? k["subeId"], k["belgeId"], istek.KarsiGln ?? "",
                     baglam.KullaniciId], iptal);

            var sonuclar = new List<object>();
            int yazildi = 0, mukerrer = 0, beklenmeyenSayi = 0, okunamadi = 0;

            foreach (var ham in istek.Karekodlar)
            {
                var kod = KarekodCozumleme.Coz(ham);
                if (!kod.Gecerli)
                {
                    okunamadi++;
                    sonuclar.Add(new { karekod = ham, sonuc = "okunamadi", mesaj = kod.Hata });
                    continue;
                }

                var barkod = KarekodCozumleme.GtinBarkod(kod.Gtin);
                // GTIN -> STOK İKİ YOLDAN: ilaç kataloğunun bağı
                //   (`ilac.stok_id`) ve kurumun kendi barkod listesi
                //   (`stok_barkod`). Yalnız kataloğa baksaydık, stok
                //   kartlarını TİTCK kataloğuna bağlamamış bir kurumda
                //   HER KUTU "beklenmeyen" görünürdü - okuyucu çalışır
                //   ama ekran hiçbir şeyi eşleştiremezdi.
                var stokId = await baglanti.TekDegerAsync<int?>("""
                    select coalesce(
                        (select i.stok_id from public.ilac i
                          where i.barkod = @p0 and i.stok_id is not null limit 1),
                        (select b.stok_id from public.stok_barkod b
                          where b.barkod in (@p0, @p1) limit 1))
                    """, islem, [barkod, kod.Gtin], iptal);

                // MÜKERRER: aynı kutu ikinci kez. Veritabanı da reddediyor
                //   (`ux_its_karekod_tekil`) ama önce burada yakalanır ki
                //   kullanıcıya SEBEBİ söylensin ve öteki kodlar yazılmaya
                //   devam etsin - tek bir çakışma iki yüz okutmayı düşürmemeli.
                var varOlan = await baglanti.TekAsync("""
                    select b.id, b.kabul_id as "kabulId" from public.its_bildirim_satir b
                     where b.gtin = @p0 and b.seri_no = @p1 and b.seri_no <> ''
                     limit 1
                    """, islem, [kod.Gtin, kod.SeriNo], OkuyucuGenisletmeleri.Sozluk, iptal);

                if (varOlan is not null)
                {
                    mukerrer++;
                    var ayniTutanak = varOlan["kabulId"] is { } kt && Convert.ToInt64(kt) == id;
                    sonuclar.Add(new
                    {
                        karekod = ham, kod.Gtin, kod.SeriNo, sonuc = "mukerrer",
                        mesaj = ayniTutanak
                            ? "Bu kutu bu tutanakta zaten okutuldu."
                            : "Bu kutu BAŞKA bir kayıtta okutulmuş.",
                    });
                    continue;
                }

                var eslesen = stokId is { } sid
                    ? beklenen.FirstOrDefault(x => Convert.ToInt32(x["stokId"]) == sid)
                    : null;
                var beklenmeyen = eslesen is null;
                if (beklenmeyen) beklenmeyenSayi++; else yazildi++;

                // BEKLENMEYENİN İKİ SEBEBİ AYRI: kutu kataloğumuzda hiç yok mu
                //   (yeni ruhsat / yabancı kutu), yoksa var ama BU tutanakta
                //   beklenmiyor mu (yanlış koli)? İkisi farklı iş gerektirir -
                //   biri katalog güncellemesi, öteki sevkiyatı sorgulamak.
                var sebep = !beklenmeyen ? ""
                    : stokId is null
                        ? "İlaç kataloğunda yok (yeni ruhsat ya da yabancı kutu)"
                        : "Bu tutanağın muayene satırlarında yok";

                var satirId = await baglanti.TekDegerAsync<int>("""
                    insert into public.its_bildirim_satir
                        (bildirim_id, kabul_id, karekod, gtin, seri_no, parti_no,
                         son_kullanma, ilac_barkod, stok_id, dogrulama, dogrulama_not, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6::date, @p7, @p8, @p9, @p10, @p11)
                    returning id
                    """, islem,
                    [bildirimId, id, ham, kod.Gtin, kod.SeriNo, kod.PartiNo,
                     kod.SonKullanma?.ToDateTime(TimeOnly.MinValue), barkod, stokId,
                     // dogrulama: 0 sorulmadı · 2 bu tutanakta beklenmiyor
                     (short)(beklenmeyen ? 2 : 0),
                     sebep,
                     baglam.KullaniciId], iptal);

                // MİAD ÇELİŞKİSİ UYARIDIR, ENGEL DEĞİL: kutunun üstündeki
                //   tarih doğrudur; çelişen şey muayene satırına elle yazılmış
                //   olandır. Kutuyu reddetmek yerine ikisini de göstermek
                //   sayan kişiye hangisinin düzeltileceğini sorar.
                string? uyari = null;
                if (eslesen is not null && kod.SonKullanma is { } skt)
                {
                    if (eslesen["skt"] is DateTime beklenenSkt
                        && DateOnly.FromDateTime(beklenenSkt) != skt)
                        uyari = $"Satırdaki miad {beklenenSkt:dd.MM.yyyy}, kutuda {skt:dd.MM.yyyy}.";
                    if (skt.ToDateTime(TimeOnly.MinValue).Date < DateTime.Today)
                        uyari = (uyari is null ? "" : uyari + " ") + "Kutunun miadı GEÇMİŞ.";
                }

                sonuclar.Add(new
                {
                    karekod = ham, kod.Gtin, kod.SeriNo, kod.PartiNo,
                    sonKullanma = kod.SonKullanma, stokId,
                    ad = eslesen?["ad"] ?? "",
                    sonuc = beklenmeyen ? "beklenmeyen" : "yazildi",
                    mesaj = sebep,
                    satirId, uyari,
                });
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogItsSatir, bildirimId.Value,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    kabulId = id, okutulan = istek.Karekodlar.Count,
                    yazildi, mukerrer, beklenmeyen = beklenmeyenSayi, okunamadi
                }, LogKabul, id, iptal: iptal);

            await islem.CommitAsync(iptal);

            // Okutma sonrası TABLO: satır başına beklenen/okutulan.
            var ozet = await baglanti.ListeAsync("""
                select v.sira, v.ad, v.stok_id as "stokId", v.beklenen, v.okutulan,
                       v.skt_celiskisi as "sktCeliskisi", v.miadi_gecmis as "miadiGecmis"
                  from public.v_kabul_karekod_satir v
                 where v.kabul_id = @p0 order by v.sira
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                bildirimId, yazildi, mukerrer, beklenmeyen = beklenmeyenSayi, okunamadi,
                sonuclar, ozet, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------ özet ----
        // Sekme açılışında tablo: "hangi kalemde kaç kutu okutuldu".
        grup.MapGet("/kabul/{id:long}/karekod", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var ozet = await baglanti.ListeAsync("""
                select v.sira, v.ad, v.stok_id as "stokId", v.beklenen, v.okutulan,
                       v.skt_celiskisi as "sktCeliskisi", v.miadi_gecmis as "miadiGecmis"
                  from public.v_kabul_karekod_satir v
                 where v.kabul_id = @p0 order by v.sira
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var kutular = await baglanti.ListeAsync("""
                select b.id, b.gtin, b.seri_no as "seriNo", b.parti_no as "partiNo",
                       b.son_kullanma as "sonKullanma", b.stok_id as "stokId",
                       coalesce(s.ad, '') as ad, b.dogrulama,
                       b.dogrulama_not as "dogrulamaNot", b.ekleme_tarihi as "okutma",
                       coalesce(bl.durum, 0) as "bildirimDurum"
                  from public.its_bildirim_satir b
                  left join public.stok s on s.id = b.stok_id
                  left join public.its_bildirim bl on bl.id = b.bildirim_id
                 where b.kabul_id = @p0 order by b.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { ozet, kutular, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------- yanlış okutma ----
        // YANLIŞ OKUTULAN KUTU SİLİNİR, ama yalnız BİLDİRİLMEMİŞ olan.
        //   Gönderilmiş bir bildirimin satırını silmek, karşı tarafta duran
        //   bir kaydı bizde yokmuş gibi göstermektir - İTS'te düzeltme ayrı
        //   bir işlemdir (deaktivasyon).
        grup.MapPost("/kabul/{id:long}/karekod-sil", async (
            long id, KarekodSil istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.gtin, b.seri_no as "seriNo", coalesce(bl.durum, 0) as durum
                  from public.its_bildirim_satir b
                  left join public.its_bildirim bl on bl.id = b.bildirim_id
                 where b.id = @p0 and b.kabul_id = @p1
                """, null, [istek.SatirId, id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Okutulan kutu bu tutanakta bulunamadı.");

            var durum = Convert.ToInt16(b["durum"] ?? (short)0);
            if (durum is 2 or 3)
                throw GentegreHatasi.IsKurali(
                    "Bu kutu İTS'e bildirilmiş - satır silinemez. Düzeltme deaktivasyon "
                    + "bildirimiyle yapılır.");

            await baglanti.CalistirAsync(
                "delete from public.its_bildirim_satir where id = @p0 and kabul_id = @p1",
                null, [istek.SatirId, id], iptal);

            await log.YazAsync(LogIslemi.Sil, LogItsSatir, istek.SatirId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { kabulId = id, gtin = b["gtin"], seriNo = b["seriNo"],
                      gerekce = istek.Gerekce }, LogKabul, id, iptal: iptal);

            return Results.Ok(new { silindi = true, izlemeNo = baglam.IzlemeNo });
        });
    }
}
