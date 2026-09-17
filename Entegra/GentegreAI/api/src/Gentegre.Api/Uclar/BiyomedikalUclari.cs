using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BİYOMEDİKAL İŞ AKIŞI UÇLARI (723 tabloları, 727/728 kuralları).
///
/// ARIZA KAPANINCA CİHAZ KENDİLİĞİNDEN AÇILMAZ. İş emri tamamlandığında
/// cihaz "aktif"e ancak BAŞKA açık arızası yoksa döner - iki arıza kaydı olan
/// bir cihazda birini kapatmak, cihazı kullanıma açmaz. Tek arıza varsayıp
/// koşulsuz açsaydık, ikinci arıza duruyorken cihaz hazır görünürdü.
///
/// KALİBRASYON SONUCU CİHAZA TETİKLE İŞLENİR (723): uygunsuz sonuç cihazı
/// kullanım dışı yapar, uygun sonuç yalnız KALİBRASYON yüzünden kapatılmışsa
/// açar. Uç bu işi tekrar etmez - iki yerde yapılsaydı biri unutulurdu.
/// Uç yalnız kaydın KENDİ koşullarını uygular (referans geçerliliği, ölçüm
/// sonuçlarıyla tutarlılık, uygunsuzda geriye dönük değerlendirme).
///
/// PARÇA ÇIKIŞI YALNIZ KURUMUN ÖDEDİĞİ PARÇA İÇİN. Garanti (2) ve sözleşme
/// (1) kapsamındaki parça tedarikçinin deposundan gelir; onu da stoktan
/// düşseydik hiç girmemiş bir malı çıkarmış olurduk.
/// </summary>
public static class BiyomedikalUclari
{
    // islem_log.tablo_id - KartKatalogu.Biyomedikal / .Demirbas ile aynı.
    private const int LogDemirbas = 925;
    private const int LogKalibrasyon = 1222;
    private const int LogIsEmri = 1224;
    /// <summary>Hareket kaydının kartı yok - kendi tablo kodu.</summary>
    private const int LogHareket = 1227;

    // ---------------------------------------------------------- istekler ----

    public sealed class OnarimOnayIstegi
    {
        /// <summary>Tahmini onarım maliyeti; boşsa iş emrindeki `maliyet`.</summary>
        public decimal? Tutar { get; set; }
        /// <summary>Boşsa iş emrinin kapsam alanından çıkarılır.</summary>
        public bool? KapsamDisi { get; set; }
    }

    /// <summary>
    /// ONARIM ONAY EŞİKLERİ (752). Kurum ayarı; varsayılanı çağrı yerinde
    /// tutuyoruz ki eşiğin NEDEN o değer olduğu kuralın yanında dursun.
    /// </summary>
    private static async Task<(decimal Teknik, decimal Mali, decimal Ust)>
        OnarimEsigiAsync(Npgsql.NpgsqlConnection baglanti, CancellationToken iptal)
    {
        async Task<decimal> Oku(string anahtar, decimal varsayilan)
        {
            var m = await AyarDeposu.MetinAsync(baglanti, null, anahtar, "", iptal);
            return decimal.TryParse(m, System.Globalization.NumberStyles.Any,
                       System.Globalization.CultureInfo.InvariantCulture, out var d) && d > 0
                ? d : varsayilan;
        }
        return (await Oku("demirbas.onarim_esik_teknik", 10_000),
                await Oku("demirbas.onarim_esik_mali", 50_000),
                await Oku("demirbas.onarim_esik_ust", 250_000));
    }

    public sealed class IsEmriAdimIstegi
    {
        /// <summary>ata · mudahale · parca-bekle · dis-servis · tamamla · iptal</summary>
        public string Adim { get; set; } = "";
        public DateTime? Zaman { get; set; }
        public int? YapanId { get; set; }
        public int? FirmaId { get; set; }
        /// <summary>Arıza süresince yerine konan cihaz (hizmet durmasın).</summary>
        public int? YedekDemirbasId { get; set; }
        public string? YapilanIs { get; set; }
        public string? Kapsam { get; set; }
        public decimal? Maliyet { get; set; }
        /// <summary>Zorunlu bakım maddeleri eksikken tamamla (gerekçe zorunlu).</summary>
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class ParcaCikisIstegi
    {
        public int? DepoId { get; set; }
        public IReadOnlyList<long>? SatirIdler { get; set; }
    }

    public sealed class KalibrasyonTamamlaIstegi
    {
        /// <summary>1 uygun · 2 uygun değil · 3 şartlı uygun. Boşsa ölçümlerden türer.</summary>
        public short? Sonuc { get; set; }
        public DateTime? Gecerlilik { get; set; }
        public int? YapanId { get; set; }
        public int? FirmaId { get; set; }
        /// <summary>Uygunsuz sonuçta ZORUNLU: cihaz ne zamandır sapıyordu, kaç hastada kullanıldı.</summary>
        public string? GeriyeDonukDeger { get; set; }
        /// <summary>Referans sertifikası süresi dolmuşken tamamla (gerekçe zorunlu).</summary>
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class HareketIstegi
    {
        /// <summary>1 zimmet · 2 yer değişikliği · 3 yedek havuza · 4 havuzdan atama ·
        /// 5 atölyeye · 6 dış servise · 7 hurdaya · 8 sayımda bulundu</summary>
        public short Hareket { get; set; }
        public int? YeniDepartmanId { get; set; }
        public int? YeniZimmetId { get; set; }
        public long? IsEmriId { get; set; }
        public string? Aciklama { get; set; }
    }

    // ============================================================= kayıt ==
    public static void BiyomedikalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/demirbas").WithTags("Biyomedikal").RequireAuthorization();

        IsEmriUclari(grup);
        KalibrasyonUclari(grup);
        HareketUclari(grup);
    }

    // ============================================================ iş emri ==
    private static void IsEmriUclari(RouteGroupBuilder grup)
    {
        // --------------------------------------------- onarım onayı ----
        // ONAY ONARIMDAN ÖNCE (752): iş emri dış servise gönderilmeden ya da
        //   tamamlanmadan önce yürür. Sonradan onaylatmak "onay" değil, olan
        //   biteni kayda geçirmektir - ve kimse hayır diyemez.
        grup.MapPost("/is-emri/{id:long}/onaya-gonder", async (
            long id, OnarimOnayIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("demirbas.isemri", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var e = await baglanti.TekAsync("""
                select e.durum, e.maliyet, e.kapsam, e.onay_durum as "onayDurum",
                       coalesce(nullif(d.ad, ''), '') as "cihazAd"
                  from public.demirbas_is_emri e
                  left join public.demirbas d on d.id = e.demirbas_id
                 where e.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İş emri bulunamadı.");

            if (Convert.ToInt16(e["durum"] ?? (short)0) is 5 or 8)
                throw GentegreHatasi.IsKurali("Kapanmış iş emri onaya gönderilemez.");

            // TUTAR TAHMİNDİR AMA ZORUNLUDUR: "ne kadar" sorusunun yanıtı
            //   olmadan onay istenmez - imza atan neye imza attığını bilmeli.
            var tutar = istek.Tutar ?? Convert.ToDecimal(e["maliyet"] ?? 0m);
            if (tutar <= 0)
                throw GentegreHatasi.Dogrulama("Onaylanacak tutar zorunlu.",
                    new AlanHatasi("tutar",
                        "Tahmini onarım maliyetini girin - sıfır tutara onay istenmez."));

            var esik = await OnarimEsigiAsync(baglanti, iptal);
            if (tutar < esik.Teknik)
                throw GentegreHatasi.IsKurali(
                    $"Bu tutar onay eşiğinin altında ({esik.Teknik:N0} TL) - "
                    + "onarım onaysız yapılabilir.");

            // KAPSAM DIŞI BAYRAĞI: garanti/sözleşme kapsamındaki onarım
            //   kurumun cebinden çıkmaz; kapsam dışı olan ayrıca sorulur.
            var kapsam = (e["kapsam"] as string ?? "").Trim();
            var bayraklar = new List<string>();
            if (istek.KapsamDisi ?? kapsam.Length == 0) bayraklar.Add("kapsam_disi");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var zincir = await onay.BaslatAsync(baglanti, islem, "demirbas.onarim",
                id, tutar, bayraklar, baglam, iptal);

            await baglanti.CalistirAsync("""
                update public.demirbas_is_emri
                   set onay_durum = 1, onayli_tutar = @p1,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, tutar, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogIsEmri, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { onayDurum = 1, tutar, bayraklar, basamak = zincir.Adimlar.Count },
                iptal: iptal);

            await islem.CommitAsync(iptal);

            try
            {
                await haber.SiradakiniBildirAsync(baglanti, zincir.OnayId,
                    baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { /* zincir kuruldu; bildirim hatası onu düşürmez */ }

            return Results.Ok(new
            {
                onayDurum = 1, tutar, bayraklar,
                basamaklar = zincir.Adimlar.Select(a => new { a.Sira, a.Ad, a.Rol }),
                izlemeNo = baglam.IzlemeNo
            });
        });

        grup.MapPost("/is-emri/{id:long}/adim", async (
            long id, IsEmriAdimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("demirbas.isemri", Islem.Degistir);

            var adim = (istek.Adim ?? "").Trim().ToLowerInvariant();
            // durum: 0 açık · 1 atandı · 2 müdahalede · 3 parça bekliyor
            //        4 dış serviste · 5 tamamlandı · 8 iptal
            var hedef = adim switch
            {
                "ata" => (short)1,
                "mudahale" => (short)2,
                "parca-bekle" => (short)3,
                "dis-servis" => (short)4,
                "tamamla" => (short)5,
                "iptal" => (short)8,
                _ => throw GentegreHatasi.Dogrulama("Bilinmeyen iş emri adımı.",
                        new AlanHatasi("adim",
                            "ata · mudahale · parca-bekle · dis-servis · tamamla · iptal"))
            };

            if (adim == "iptal" && string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    new AlanHatasi("gerekce", "İptal nedeni zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var e = await baglanti.TekAsync("""
                select e.durum, e.tur, e.demirbas_id as "demirbasId",
                       e.ilk_mudahale as "ilkMudahale", e.tamamlanma,
                       e.yedek_demirbas_id as "yedekId",
                       e.maliyet, e.onay_durum as "onayDurum",
                       e.onayli_tutar as "onayliTutar",
                       (select count(*) from public.demirbas_is_emri_madde m
                         where m.is_emri_id = e.id and m.zorunlu = 1
                           and coalesce(m.sonuc, 0) = 0) as "eksikMadde",
                       (select count(*) from public.demirbas_is_emri_madde m
                         where m.is_emri_id = e.id and m.sonuc = 2) as "bulguluMadde",
                       (select count(*) from public.demirbas_is_emri_parca p
                         where p.is_emri_id = e.id and p.kapsam = 0
                           and p.belge_id is null and p.stok_id is not null) as "dusulmemisParca"
                  from public.demirbas_is_emri e where e.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İş emri bulunamadı.");

            var durum = Convert.ToInt16(e["durum"] ?? (short)0);
            if (durum is 5 or 8)
                throw GentegreHatasi.IsKurali("Kapanmış iş emrinde akış ilerletilemez.");

            var uyarilar = new List<string>();

            // MASRAFLI ONARIM ONAYSIZ İLERLEMEZ (752). Eşiği aşan bir onarım
            //   dış servise gönderilmeden ya da tamamlanmadan önce onaydan
            //   geçmeli: fatura geldikten sonra "kim onayladı" diye sormak,
            //   sormamakla aynı şey.
            //
            //   ARA ADIMLAR SERBEST: cihaza bakmak, parça beklemek para
            //   harcamaz - onayı oraya dayatmak teknisyeni bekletirdi.
            if (adim is "dis-servis" or "tamamla")
            {
                var maliyet = Convert.ToDecimal(e["maliyet"] ?? 0m);
                var onayDurum = Convert.ToInt16(e["onayDurum"] ?? (short)0);
                var esik = await OnarimEsigiAsync(baglanti, iptal);

                if (maliyet >= esik.Teknik && onayDurum != 2)
                {
                    if (onayDurum == 1)
                        throw GentegreHatasi.IsKurali(
                            $"Onarım onayı bekleniyor ({maliyet:N0} TL) - karar "
                            + "verilmeden iş emri ilerletilemez.");
                    if (onayDurum == 3)
                        throw GentegreHatasi.IsKurali(
                            "Onarım onayı REDDEDİLDİ - bu tutarla iş emri "
                            + "ilerletilemez. Maliyeti düşürüp yeniden onaya gönderin.");
                    throw GentegreHatasi.IsKurali(
                        $"{maliyet:N0} TL onarım {esik.Teknik:N0} TL eşiğini aşıyor - "
                        + "önce onaya gönderin.", new { esik = esik.Teknik, maliyet });
                }

                // ONAYLANAN TUTAR AŞILDIYSA SÖYLENİR: onay 50.000'e verildiyse
                //   90.000'lik iş o onayın kapsamında değildir.
                var onayli = e["onayliTutar"] as decimal?;
                if (onayDurum == 2 && onayli is not null && maliyet > onayli.Value)
                    uyarilar.Add($"Gerçekleşen maliyet ({maliyet:N0} TL) onaylanan "
                                 + $"tutarı ({onayli.Value:N0} TL) aşıyor - "
                                 + "yeniden onay gerekebilir.");
            }

            if (adim == "tamamla")
            {
                // ZORUNLU BAKIM MADDESİ. Periyodik bakımın bütün anlamı listeyi
                //   baştan sona uygulamaktır; yarım uygulanan bakım "bakım
                //   yapıldı" diye kaydedilirse cihazın geçmişi yalan söyler.
                var eksik = Convert.ToInt32(e["eksikMadde"] ?? 0);
                if (eksik > 0)
                {
                    if (!istek.Zorla)
                        throw GentegreHatasi.IsKurali(
                            $"{eksik} zorunlu bakım maddesi işaretsiz - iş emri tamamlanamaz.",
                            new { eksikMadde = eksik });
                    if (string.IsNullOrWhiteSpace(istek.Gerekce))
                        throw GentegreHatasi.Dogrulama("Eksik maddeyle kapatılıyorsa gerekçe zorunlu.",
                            new AlanHatasi("gerekce", "Gerekçe zorunlu."));
                    uyarilar.Add($"{eksik} zorunlu madde işaretsiz kapatıldı.");
                }

                // BULGU VARSA UYARI: "tamamlandı" ile "sorunsuz" aynı şey değil.
                if (Convert.ToInt32(e["bulguluMadde"] ?? 0) > 0)
                    uyarilar.Add("Bulgu bildirilen madde var - izlem gerekebilir.");

                // PARÇA DÜŞÜLMEMİŞ: engel değil, uyarı. İş emrini açık tutmak,
                //   teknisyeni işi kapatmamaya iter; eksik stok hareketi ise
                //   sonradan tamamlanabilir.
                if (Convert.ToInt32(e["dusulmemisParca"] ?? 0) > 0)
                    uyarilar.Add("Kurumun ödediği parçalar henüz stoktan düşülmedi.");
            }

            var zaman = istek.Zaman ?? DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // İLK MÜDAHALE bir kez yazılır: yanıt süresi ondan hesaplanır,
            //   üzerine yazılsaydı gösterge her müdahalede sıfırlanırdı.
            var sonDurum = await baglanti.TekDegerAsync<int>("""
                update public.demirbas_is_emri
                   set durum = case when @p1 = 8 then 8 else greatest(durum, @p1) end,
                       yapan_id = coalesce(@p2, yapan_id),
                       firma_id = coalesce(@p3, firma_id),
                       yedek_demirbas_id = coalesce(@p4, yedek_demirbas_id),
                       ilk_mudahale = case when @p1 = 2 then coalesce(ilk_mudahale, @p5)
                                           else ilk_mudahale end,
                       tamamlanma = case when @p1 = 5 then coalesce(tamamlanma, @p5)
                                         else tamamlanma end,
                       yapilan_is = coalesce(nullif(@p6, ''), yapilan_is),
                       kapsam = coalesce(nullif(@p7, ''), kapsam),
                       maliyet = coalesce(@p8, maliyet),
                       aciklama = case when @p1 = 8
                                       then trim(both ' ' from coalesce(aciklama, '')
                                                 || ' · İptal: ' || coalesce(@p9, ''))
                                       else aciklama end,
                       degistiren = @p10, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                returning durum
                """, islem,
                [id, hedef, istek.YapanId, istek.FirmaId, istek.YedekDemirbasId, zaman,
                 istek.YapilanIs ?? "", istek.Kapsam ?? "", istek.Maliyet,
                 istek.Gerekce ?? "", baglam.KullaniciId], iptal);

            // --- CİHAZ DURUMU. Arıza iş emri (tür 2) cihazı arızalıya çeker,
            //     kapanınca BAŞKA açık arızası yoksa aktife döndürür. Kalibrasyon
            //     yüzünden kullanım dışı (durum 3) bırakılmış cihazı AÇMAZ -
            //     o kapının anahtarı kalibrasyon kaydındadır (723 tetiği).
            var demirbasId = e["demirbasId"] is { } dbi ? Convert.ToInt32(dbi) : 0;
            var cihazDurum = (int?)null;
            if (demirbasId > 0 && Convert.ToInt16(e["tur"] ?? (short)0) == 2)
            {
                if (adim == "mudahale" || adim == "ata")
                    cihazDurum = await baglanti.TekDegerAsync<int?>("""
                        update public.demirbas set durum = 2, degistiren = @p1,
                               degistirme_tarihi = (now())::timestamp
                         where id = @p0 and durum = 1 returning durum
                        """, islem, [demirbasId, baglam.KullaniciId], iptal);

                if (adim is "tamamla" or "iptal")
                    cihazDurum = await baglanti.TekDegerAsync<int?>("""
                        update public.demirbas set durum = 1, degistiren = @p1,
                               degistirme_tarihi = (now())::timestamp
                         where id = @p0 and durum = 2
                           and not exists (select 1 from public.demirbas_is_emri x
                                            where x.demirbas_id = @p0 and x.tur = 2
                                              and x.durum between 0 and 4 and x.id <> @p2)
                        returning durum
                        """, islem, [demirbasId, baglam.KullaniciId, id], iptal);

                // NEDENİ AYIRT ET. Güncelleme `durum = 2` koşuluyla çalışıyor;
                //   hiç satır dönmemesi "başka arıza var" demek DEĞİL - cihaz
                //   kalibrasyon yüzünden kullanım dışı (3) ya da hurda (4) da
                //   olabilir. Tek mesaj yazsaydık teknisyen olmayan bir arızayı
                //   arardı.
                if (adim is "tamamla" or "iptal" && cihazDurum is null)
                {
                    var neden = await baglanti.TekAsync("""
                        select d.durum,
                               (select count(*) from public.demirbas_is_emri x
                                 where x.demirbas_id = d.id and x.tur = 2
                                   and x.durum between 0 and 4 and x.id <> @p1) as "acikAriza"
                          from public.demirbas d where d.id = @p0
                        """, islem, [demirbasId, id], OkuyucuGenisletmeleri.Sozluk, iptal);

                    var cd = Convert.ToInt16(neden?["durum"] ?? (short)0);
                    if (Convert.ToInt32(neden?["acikAriza"] ?? 0) > 0)
                        uyarilar.Add("Cihazda başka açık arıza var - kullanıma açılmadı.");
                    else if (cd == 3)
                        uyarilar.Add("Cihaz kalibrasyon nedeniyle kullanım dışı - "
                                     + "arıza kapandı ama kullanıma açılmadı.");
                    else if (cd == 4)
                        uyarilar.Add("Cihaz hurdaya ayrılmış.");
                    else if (cd != 1)
                        uyarilar.Add($"Cihaz kullanıma açılmadı (durum {cd}).");
                    cihazDurum = cd;
                }
            }

            // YEDEK CİHAZ İADE: iş kapanınca havuza döner, yoksa yedek cihaz
            //   sonsuza dek "ödünçte" görünür ve bir dahaki arızada bulunamaz.
            if (adim is "tamamla" or "iptal" && e["yedekId"] is { } yedek)
            {
                await baglanti.CalistirAsync("""
                    insert into public.demirbas_hareket
                        (demirbas_id, zaman, hareket, is_emri_id, aciklama, ekleyen)
                    values (@p0, now(), 3, @p1, 'İş emri kapandı - yedek havuza döndü', @p2)
                    """, islem, [Convert.ToInt32(yedek), id, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync("""
                    update public.demirbas set yedek_havuz = 1, degistiren = @p1,
                           degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, islem, [Convert.ToInt32(yedek), baglam.KullaniciId], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogIsEmri, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { adim, zaman, cihazDurum, uyarilar, gerekce = istek.Gerekce },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                adim, zaman, durum = sonDurum, cihazDurum, uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // PARÇA ÇIKIŞI. Yalnız `kapsam = 0` (kurum ödüyor) parçalar düşülür.
        grup.MapPost("/is-emri/{id:long}/parca-cikis", async (
            long id, ParcaCikisIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("demirbas.isemri", Islem.Degistir);
            baglam.YetkiIste("stok", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var e = await baglanti.TekAsync("""
                select e.is_emri_no as "isEmriNo", e.durum, e.sube_id as "subeId",
                       coalesce(d.kod, '') as "cihazKod"
                  from public.demirbas_is_emri e
                  left join public.demirbas d on d.id = e.demirbas_id
                 where e.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İş emri bulunamadı.");

            if (Convert.ToInt16(e["durum"] ?? (short)0) == 8)
                throw GentegreHatasi.IsKurali("İptal edilmiş iş emrinin parçası düşülmez.");

            var secim = istek.SatirIdler is { Count: > 0 } ? istek.SatirIdler.ToArray() : null;
            var satirlar = await baglanti.ListeAsync("""
                select p.id, p.stok_id as "stokId", p.miktar,
                       coalesce(nullif(p.ad, ''), s.ad, p.parca_no, '') as ad
                  from public.demirbas_is_emri_parca p
                  left join public.stok s on s.id = p.stok_id
                 where p.is_emri_id = @p0 and p.belge_id is null
                   and p.stok_id is not null and p.miktar > 0
                   -- KAPSAM 0 = KURUM ÖDÜYOR. Garanti/sözleşme parçası
                   --   tedarikçinin malıdır; stoğumuza hiç girmedi.
                   and coalesce(p.kapsam, 0) = 0
                   and (@p1::bigint[] is null or p.id = any(@p1::bigint[]))
                 order by p.id
                """, null, [id, secim], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (satirlar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Düşülecek parça yok - garanti/sözleşme kapsamındaki parçalar stoktan düşülmez.");

            var depoAyar = await AyarDeposu.MetinAsync(baglanti, null, "demirbas.parca_depo", "", iptal);
            var depoId = istek.DepoId
                ?? await baglanti.TekDegerAsync<int?>("""
                    select coalesce(nullif(@p0, '')::int,
                           (select min(x.id) from public.depo x
                             where x.varsayilan = 1 and coalesce(x.durum, 1) = 1),
                           (select min(x.id) from public.depo x where coalesce(x.durum, 1) = 1))
                    """, null, [depoAyar], iptal)
                ?? throw GentegreHatasi.IsKurali(
                    "Parça çıkışı için depo bulunamadı - Genel Ayarlar'dan teknik servis deposunu seçin.");

            var fis = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 4,                       // 4 = Stok Çıkış Fişi (carisiz)
                ["tipi"] = 1,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["cikisDepoId"] = depoId,
                ["subeId"] = baglam.SubeId ?? e["subeId"],
                ["aciklama"] = $"Teknik servis parça · {e["isEmriNo"]} · {e["cihazKod"]}",
            };

            var govde = new List<Dictionary<string, JsonElement>>();
            var sira = 0;
            foreach (var p in satirlar)
                govde.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 1,
                    ["stokId"] = p["stokId"],
                    ["miktar"] = p["miktar"],
                    ["birimFiyat"] = 0m,           // maliyet stok tarafında
                    ["kdv"] = 0,
                    ["dovizCinsi"] = "TL",
                    ["cikisDepoId"] = depoId,
                    ["aciklama"] = $"{e["isEmriNo"]} · {p["ad"]}",
                    ["sira"] = ++sira,
                }));

            var (fisId, uyarilar) = await belgeDepo.KaydetAsync(
                fis, govde,
                new BelgeSecenekleri { Taslak = false, StokKontrolu = true },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            await baglanti.CalistirAsync("""
                update public.demirbas_is_emri_parca
                   set belge_id = @p1, degistiren = @p2,
                       degistirme_tarihi = (now())::timestamp
                 where is_emri_id = @p0 and id = any(@p3)
                """, null, [id, fisId, baglam.KullaniciId,
                            satirlar.Select(x => Convert.ToInt64(x["id"])).ToArray()], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogIsEmri, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { belgeId = fisId, satir = satirlar.Count, depoId }, iptal: iptal);

            return Results.Ok(new
            {
                belgeId = fisId, satir = satirlar.Count, depoId, uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });
    }

    // ======================================================= kalibrasyon ==
    private static void KalibrasyonUclari(RouteGroupBuilder grup)
    {
        grup.MapPost("/kalibrasyon/{id:long}/tamamla", async (
            long id, KalibrasyonTamamlaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("demirbas.kalibrasyon", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.sonuc, k.tur, k.tarih, k.demirbas_id as "demirbasId",
                       k.referans_gecerlilik as "referansGecerlilik",
                       coalesce(nullif(k.referans_cihaz, ''), '') as "referansCihaz",
                       coalesce(d.kalibrasyon_periyot_ay, 0) as "periyotAy",
                       (select count(*) from public.demirbas_kalibrasyon_olcum o
                         where o.kalibrasyon_id = k.id) as "olcumSayisi",
                       (select count(*) from public.demirbas_kalibrasyon_olcum o
                         where o.kalibrasyon_id = k.id and o.sonuc = 2) as "sinirDisi",
                       (select count(*) from public.demirbas_kalibrasyon_olcum o
                         where o.kalibrasyon_id = k.id and coalesce(o.sonuc, 0) = 0) as "degerlendirilmemis"
                  from public.demirbas_kalibrasyon k
                  left join public.demirbas d on d.id = k.demirbas_id
                 where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kalibrasyon kaydı bulunamadı.");

            if (Convert.ToInt16(k["sonuc"] ?? (short)0) != 0)
                throw GentegreHatasi.IsKurali("Bu kalibrasyon zaten sonuçlandırılmış.");

            var olcumSayisi = Convert.ToInt32(k["olcumSayisi"] ?? 0);
            if (olcumSayisi == 0)
                throw GentegreHatasi.IsKurali("Ölçümü olmayan kalibrasyon sonuçlandırılamaz.");
            if (Convert.ToInt32(k["degerlendirilmemis"] ?? 0) > 0)
                throw GentegreHatasi.IsKurali(
                    "Değerlendirilmemiş ölçüm var - ölçülen değeri girilmemiş nokta bırakılamaz.");

            // REFERANS CİHAZIN SERTİFİKASI GEÇERLİ OLMALI. Geçersiz referansla
            //   yapılan ölçüm ölçüm değil tahmindir; sertifika da onu belgeler.
            if (k["referansGecerlilik"] is DateTime rg && rg.Date < DateTime.Today)
            {
                if (!istek.Zorla)
                    throw GentegreHatasi.IsKurali(
                        $"Referans cihazın sertifikası {rg:dd.MM.yyyy} tarihinde dolmuş - "
                        + "bu ölçümle kalibrasyon sonuçlandırılamaz.",
                        new { referansGecerlilik = rg, referansCihaz = k["referansCihaz"] });
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Süresi dolmuş referansla gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Gerekçe zorunlu."));
            }

            // SONUÇ ÖLÇÜMLERDEN TÜRER. Elle "uygun" denebilir ama sınır dışı
            //   ölçüm varken uygun demek, ölçümü yok saymaktır - istenirse
            //   "şartlı uygun" (3) yazılır, ama sessizce "uygun" olamaz.
            var sinirDisi = Convert.ToInt32(k["sinirDisi"] ?? 0);
            var turetilen = (short)(sinirDisi > 0 ? 2 : 1);
            var sonuc = istek.Sonuc ?? turetilen;
            if (sonuc is < 1 or > 3)
                throw GentegreHatasi.Dogrulama("Geçersiz sonuç.",
                    new AlanHatasi("sonuc", "1 uygun · 2 uygun değil · 3 şartlı uygun"));
            if (sinirDisi > 0 && sonuc == 1)
                throw GentegreHatasi.IsKurali(
                    $"{sinirDisi} ölçüm sınır dışı - sonuç 'uygun' olamaz "
                    + "(uygun değil ya da şartlı uygun).", new { sinirDisi });

            // UYGUNSUZ SONUCUN ASIL SORUSU: cihaz ne zamandır sapıyordu, o
            //   sürede kaç hastada kullanıldı. Yanıtı yazmadan kayıt kapanmaz.
            if (sonuc == 2 && string.IsNullOrWhiteSpace(istek.GeriyeDonukDeger))
                throw GentegreHatasi.Dogrulama("Geriye dönük değerlendirme zorunlu.",
                    new AlanHatasi("geriyeDonukDeger",
                        "Uygunsuz sonuçta cihazın ne zamandan beri saptığı ve etkilenen "
                        + "hastalar değerlendirilmeli."));

            // GEÇERLİLİK: verilmezse cihazın periyodundan türer. Periyot da
            //   yoksa boş kalır - uydurulmuş bir geçerlilik tarihi, olmayan
            //   bir güvenceyi belgelemektir.
            var tarih = k["tarih"] is DateTime t ? t : DateTime.Today;
            var periyot = Convert.ToInt32(k["periyotAy"] ?? 0);
            DateTime? gecerlilik = istek.Gecerlilik
                ?? (sonuc != 2 && periyot > 0 ? tarih.AddMonths(periyot) : null);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.demirbas_kalibrasyon
                   set sonuc = @p1, gecerlilik = @p2,
                       yapan_id = coalesce(@p3, yapan_id),
                       firma_id = coalesce(@p4, firma_id),
                       geriye_donuk_deger = coalesce(nullif(@p5, ''), geriye_donuk_deger),
                       degistiren = @p6, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, sonuc, gecerlilik, istek.YapanId, istek.FirmaId,
                 istek.GeriyeDonukDeger ?? "", baglam.KullaniciId], iptal);

            // CİHAZ KÜNYESİ TETİKLE GÜNCELLENİR (723). Burada yalnız SONUCU
            //   okuyup çağırana veriyoruz - ikinci kez yazsaydık tetikle
            //   çelişebilirdik.
            var cihaz = await baglanti.TekAsync("""
                select d.durum, d.son_kalibrasyon as "sonKalibrasyon",
                       d.kalibrasyon_gecerlilik as "kalibrasyonGecerlilik",
                       v.hazir
                  from public.demirbas d
                  left join public.v_demirbas_durum v on v.id = d.id
                 where d.id = @p0
                """, islem, [k["demirbasId"]], OkuyucuGenisletmeleri.Sozluk, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogKalibrasyon, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    sonuc, gecerlilik, sinirDisi, olcumSayisi,
                    turetilenSonuc = turetilen,
                    referansGecersiz = istek.Zorla ? istek.Gerekce : null
                }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var uyarilar = new List<string>();
            if (gecerlilik is null && sonuc != 2)
                uyarilar.Add("Geçerlilik tarihi yok - cihazın kalibrasyon periyodu tanımlı değil.");
            if (sonuc == 2) uyarilar.Add("Cihaz kullanım dışı bırakıldı (uygunsuz kalibrasyon).");
            if (sonuc == 3) uyarilar.Add("Şartlı uygun - kullanım koşulu kayda yazılmalı.");

            return Results.Ok(new { sonuc, gecerlilik, sinirDisi, cihaz, uyarilar, izlemeNo = baglam.IzlemeNo });
        });
    }

    // =========================================================== hareket ==
    private static void HareketUclari(RouteGroupBuilder grup)
    {
        // ZİMMET / YER / HAVUZ / HURDA. Hareket satırı ESKİ ve YENİ değeri
        //   birlikte tutar: "şu an kimde" sorusunu demirbaş kartı, "ne zaman
        //   kimden kime geçti" sorusunu bu defter yanıtlar. Yalnız kartı
        //   güncelleseydik ikincisi hiç sorulamazdı.
        grup.MapPost("/{id:int}/hareket", async (
            int id, HareketIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);

            if (istek.Hareket is < 1 or > 8)
                throw GentegreHatasi.Dogrulama("Geçersiz hareket.",
                    new AlanHatasi("hareket",
                        "1 zimmet · 2 yer · 3 yedek havuza · 4 havuzdan · 5 atölye · "
                        + "6 dış servis · 7 hurda · 8 sayımda bulundu"));

            // YETKİ HAREKETE GÖRE. Hurdaya ayırmak bir varlığı defterden
            //   düşürmektir; zimmet değiştirmekle aynı kapıdan geçmemeli.
            if (istek.Hareket == 7) baglam.AksiyonIste("demirbas.hurda");
            else if (istek.Hareket == 1) baglam.AksiyonIste("demirbas.zimmet");
            else baglam.YetkiIste("demirbas", Islem.Degistir);

            if (istek.Hareket == 7 && string.IsNullOrWhiteSpace(istek.Aciklama))
                throw GentegreHatasi.Dogrulama("Hurda gerekçesi zorunlu.",
                    new AlanHatasi("aciklama", "Hurdaya ayırma gerekçesi zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var d = await baglanti.TekAsync("""
                select d.durum, d.departman_id as "departmanId",
                       d.zimmet_taraf_id as "zimmetId", d.lokasyon, d.yedek_havuz as "yedekHavuz",
                       (select count(*) from public.demirbas_is_emri x
                         where x.demirbas_id = d.id and x.durum between 0 and 4) as "acikIsEmri"
                  from public.demirbas d where d.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Demirbaş bulunamadı.");

            if (Convert.ToInt16(d["durum"] ?? (short)0) == 4)
                throw GentegreHatasi.IsKurali("Hurdaya ayrılmış demirbaşta hareket yapılamaz.");

            // AÇIK İŞ EMRİ VARKEN HURDA YOK: kapatılmamış bir iş emri, sahibi
            //   olmayan bir maliyet ve sahipsiz bir parça çıkışı bırakır.
            if (istek.Hareket == 7 && Convert.ToInt32(d["acikIsEmri"] ?? 0) > 0)
                throw GentegreHatasi.IsKurali(
                    "Açık iş emri varken cihaz hurdaya ayrılamaz - önce iş emirlerini kapatın.");

            // Hareketin cihaz künyesine yansıması.
            var (yeniDurum, yeniLokasyon, yeniHavuz) = istek.Hareket switch
            {
                3 => ((short?)null, (short?)2, (short?)1),   // yedek havuza -> depo
                4 => (null, (short?)1, (short?)0),           // havuzdan atama -> kullanımda
                5 => (null, (short?)3, null),                // atölyeye -> serviste
                6 => (null, (short?)3, null),                // dış servise -> serviste
                7 => ((short?)4, (short?)2, (short?)0),      // hurda
                _ => (null, null, null)
            };

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var hareketId = await baglanti.TekDegerAsync<long>("""
                insert into public.demirbas_hareket
                    (demirbas_id, zaman, hareket, eski_departman_id, yeni_departman_id,
                     eski_zimmet_id, yeni_zimmet_id, is_emri_id, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
                returning id
                """, islem,
                [id, simdi, istek.Hareket, d["departmanId"], istek.YeniDepartmanId,
                 d["zimmetId"], istek.YeniZimmetId, istek.IsEmriId,
                 istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.demirbas
                   set departman_id = coalesce(@p1, departman_id),
                       zimmet_taraf_id = coalesce(@p2, zimmet_taraf_id),
                       durum = coalesce(@p3::smallint, durum),
                       lokasyon = coalesce(@p4::smallint, lokasyon),
                       yedek_havuz = coalesce(@p5::smallint, yedek_havuz),
                       degistiren = @p6, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, istek.YeniDepartmanId, istek.YeniZimmetId, yeniDurum, yeniLokasyon,
                 yeniHavuz, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogHareket, hareketId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    demirbasId = id, hareket = istek.Hareket,
                    eskiDepartman = d["departmanId"], yeniDepartman = istek.YeniDepartmanId,
                    eskiZimmet = d["zimmetId"], yeniZimmet = istek.YeniZimmetId,
                    aciklama = istek.Aciklama
                }, LogDemirbas, id, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = hareketId, zaman = simdi, izlemeNo = baglam.IzlemeNo });
        });
    }
}
