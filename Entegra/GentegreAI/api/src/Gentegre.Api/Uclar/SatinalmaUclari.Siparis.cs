using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SATINALMA — SİPARİŞ, MAL KABUL ve FATURA UÇLARI (724).
///
/// SİPARİŞ `belge` TÜR 9'DUR. `/talep/{id}/siparise` talebi belgeye çevirir;
/// tutarlar `fn_belge_diptoplam`dan, satırlar `belge_satir`dan. İkinci bir
/// sipariş tablosu açsaydık para iki yerde hesaplanır ve ikisi zamanla
/// ayrışırdı. `belge_satinalma` 1:1 uzantısı yalnız SÜRECİ taşır: teslim
/// taahhüdü, gecikme, ceza, sözleşme bağı.
///
/// TALEP SATIRI HANGİ BELGE SATIRINA GİTTİĞİNİ TUTAR (`belge_satir_id`) ve o
/// bağ `KorunanSatirSql`de korunur - sipariş düzenlenip satırlar yeniden
/// yazılsa bile talebin gösterdiği satır yok olmaz.
///
/// ÜÇLÜ EŞLEŞTİRME: sipariş - irsaliye (teslim) - fatura. Üçü tutmuyorsa
/// ödeme kendiliğinden durmaz ama FARK YAZILIR; ödeme kararı ayrı bir
/// yetkiyle (`satinalma.odeme_onay`) verilir. Farkı otomatik kapatsaydık,
/// tedarikçiyle konuşulması gereken şey sessizce ödenmiş olurdu.
///
/// CEZA KENDİLİĞİNDEN TAHSİL OLMAZ. Hesap sözleşmeden gelir (binde/gün, üst
/// sınır %) ama işlenmesi ayrı bir karardır (`satinalma.ceza`) - işlenmeyen
/// ceza, sözleşmeyi bir tavsiyeye çevirir, o yüzden listede ayrı görünür.
/// </summary>
public static partial class SatinalmaUclari
{
    public sealed class TakipIstegi
    {
        /// <summary>0 açık · 1 kısmi teslim · 2 tamamlandı · 8 iptal</summary>
        public short? TakipDurum { get; set; }
        public DateTime? SozTeslim { get; set; }
        public DateTime? IlkTeslim { get; set; }
        public DateTime? SonTeslim { get; set; }
        /// <summary>Gecikme bildirimi yapıldı damgası.</summary>
        public bool GecikmeBildir { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class CezaIstegi
    {
        /// <summary>Boşsa sözleşmeden hesaplanır.</summary>
        public decimal? Tutar { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class KabulIstegi
    {
        public int BelgeId { get; set; }
        public int? SiparisBelgeId { get; set; }
        /// <summary>
        /// 0 açık (varsayılan) · 1 kabul · 2 kısmi · 3 ret. TUTANAK AÇIK
        /// DOĞAR: mal geldi, muayene sırada. Sonucu açılışta zorunlu kılsaydık
        /// kullanıcı kalemleri saymadan bir karar yazmak zorunda kalır,
        /// tutanak da o kararı belgelerdi. Karar `/karar` ucundan verilir ve
        /// satırlardan da türer (733 tetiği).
        /// </summary>
        public short Sonuc { get; set; }
        public string? Komisyon { get; set; }
        public string? Uygunsuzluk { get; set; }
        public string? TutanakNo { get; set; }
        public int? KullaniciBirimId { get; set; }
        public bool KullaniciBirimOnay { get; set; }
        /// <summary>Satırları irsaliyeden doldur (varsayılan evet).</summary>
        public bool SatirDoldur { get; set; } = true;
    }

    public sealed class KabulKararIstegi
    {
        /// <summary>1 kabul · 2 kısmi kabul · 3 ret</summary>
        public short Sonuc { get; set; }
        public string? Komisyon { get; set; }
        public string? Uygunsuzluk { get; set; }
        public bool KullaniciBirimOnay { get; set; }
        public int? KullaniciBirimId { get; set; }
        /// <summary>Soğuk zincir ölçümü: 0 ölçülmedi · 1 uygun · 2 uygunsuz.</summary>
        public short? SogukZincirUygun { get; set; }
        public decimal? Sicaklik { get; set; }
        public string? TasimaKosulu { get; set; }
    }

    public sealed class TumunuKabulIstegi
    {
        /// <summary>Sayılanı irsaliyedekiyle eşitle (varsayılan evet).</summary>
        public bool SayilaniEsitle { get; set; } = true;
    }

    public sealed class EslestirIstegi
    {
        public int FaturaBelgeId { get; set; }
        public int? SiparisBelgeId { get; set; }
    }

    public sealed class OdemeKararIstegi
    {
        /// <summary>1 ödemeye onay · 2 ödeme durduruldu · 3 itiraz edildi · 4 düzeltildi</summary>
        public short Karar { get; set; }
        public string? Metin { get; set; }
        public decimal? MahsupTutar { get; set; }
    }

    // ========================================================== sipariş ==
    private static void SiparisUclari(RouteGroupBuilder grup)
    {
        // TALEBİ SİPARİŞE ÇEVİR.
        grup.MapPost("/talep/{id:long}/siparise", async (
            long id, SipariseIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.siparis", Islem.Ekle);

            if (istek.TarafId <= 0)
                throw GentegreHatasi.Dogrulama("Tedarikçi zorunlu.",
                    new AlanHatasi("tarafId", "Sipariş için tedarikçi seçilmeli."));

            await using var baglanti = await veri.AcAsync(iptal);

            var t = await baglanti.TekAsync("""
                select t.durum, t.talep_no as "talepNo", t.sube_id as "subeId",
                       t.departman_id as "departmanId"
                  from public.satinalma_talep t where t.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");

            // ONAYSIZ TALEP SİPARİŞE DÖNMEZ: zincir tam da bunun için var.
            var durum = Convert.ToInt16(t["durum"] ?? (short)0);
            if (durum is not (TalepOnaylandi or TalepTeklifte))
                throw GentegreHatasi.IsKurali(
                    "Yalnız onaylanmış (ya da teklifi tamamlanmış) talep siparişe dönüştürülebilir.");

            var satirlar = await baglanti.ListeAsync("""
                select s.id, s.stok_id as "stokId", s.hizmet_id as "hizmetId",
                       coalesce(nullif(s.ad, ''), st.ad, '') as ad,
                       s.miktar, coalesce(s.son_alis_fiyat, 0) as fiyat, s.sira
                  from public.satinalma_talep_satir s
                  left join public.stok st on st.id = s.stok_id
                 where s.talep_id = @p0 and s.belge_satir_id is null and s.miktar > 0
                 order by s.sira, s.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (satirlar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Siparişe dönüşecek satır yok - satırlar zaten siparişe bağlanmış olabilir.");

            // SÖZLEŞME FİYATI SİPARİŞİ BAĞLAR: sözleşme seçildiyse birim fiyat
            //   oradan gelir, "son alış fiyatı" tahmininden değil. İki fiyat
            //   olsaydı hangisinin geçerli olduğu faturada tartışılırdı.
            var sozlesmeFiyat = istek.SozlesmeId is { } soz
                ? await baglanti.ListeAsync("""
                    select f.stok_id as "stokId", f.hizmet_id as "hizmetId",
                           f.birim_fiyat as "birimFiyat"
                      from public.tedarikci_sozlesme_fiyat f
                     where f.sozlesme_id = @p0
                       and (f.gecerli_bas is null or f.gecerli_bas <= current_date)
                       and (f.gecerli_son is null or f.gecerli_son >= current_date)
                    """, null, [soz], OkuyucuGenisletmeleri.Sozluk, iptal)
                : [];

            var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 9,                        // 9 = Alış Siparişi
                ["tipi"] = 1,
                ["tarafId"] = istek.TarafId,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["subeId"] = baglam.SubeId ?? t["subeId"],
                ["aciklama"] = istek.Aciklama
                    ?? $"Satınalma talebi {t["talepNo"]}",
            };
            if (istek.DepoId is { } dep) belge["girisDepoId"] = dep;

            var govde = new List<Dictionary<string, JsonElement>>();
            var sira = 0;
            foreach (var s in satirlar)
            {
                var fiyat = Convert.ToDecimal(s["fiyat"] ?? 0m);
                var sf = sozlesmeFiyat.FirstOrDefault(f =>
                    (s["stokId"] is not null && f["stokId"] is not null
                     && Convert.ToInt32(f["stokId"]) == Convert.ToInt32(s["stokId"]))
                    || (s["hizmetId"] is not null && f["hizmetId"] is not null
                        && Convert.ToInt32(f["hizmetId"]) == Convert.ToInt32(s["hizmetId"])));
                if (sf is not null) fiyat = Convert.ToDecimal(sf["birimFiyat"] ?? 0m);

                govde.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = s["stokId"] is not null ? 1 : 2,   // 1 stok · 2 hizmet
                    ["stokId"] = s["stokId"],
                    ["hizmetId"] = s["hizmetId"],
                    ["aciklama"] = s["ad"],
                    ["miktar"] = s["miktar"],
                    ["birimFiyat"] = fiyat,
                    ["dovizCinsi"] = "TL",
                    ["sira"] = ++sira,
                }));
            }

            var (belgeId, uyarilar) = await belgeDepo.KaydetAsync(
                belge, govde,
                // SİPARİŞ STOK ETKİLEMEZ: mal henüz gelmedi. Kontrol açmak,
                //   olmayan bir bakiyeyi sorgulamak olurdu.
                new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // TALEP SATIRI -> BELGE SATIRI BAĞI. Sıraya göre eşleştiriyoruz:
            //   belge hattı satırları verdiğimiz sırayla yazıyor.
            var belgeSatirlari = await baglanti.ListeAsync<long>("""
                select id from public.belge_satir where belge_id = @p0 order by sira, id
                """, islem, [belgeId], o => o.GetInt64(0), iptal);

            var baglanan = 0;
            for (var i = 0; i < satirlar.Count && i < belgeSatirlari.Count; i++)
                baglanan += await baglanti.CalistirAsync("""
                    update public.satinalma_talep_satir set belge_satir_id = @p1
                     where id = @p0
                    """, islem, [Convert.ToInt64(satirlar[i]["id"]), belgeSatirlari[i]], iptal);

            // SÜREÇ UZANTISI (1:1). Belgenin kendisi ticari kayıt; taahhüt,
            //   gecikme ve ceza burada durur.
            await baglanti.CalistirAsync("""
                insert into public.belge_satinalma
                    (id, talep_id, teklif_id, sozlesme_id, soz_teslim, takip_durum)
                values (@p0, @p1, @p2, @p3, @p4, 0)
                on conflict (id) do update
                   set talep_id = excluded.talep_id, teklif_id = excluded.teklif_id,
                       sozlesme_id = excluded.sozlesme_id, soz_teslim = excluded.soz_teslim
                """, islem,
                [belgeId, id, istek.TeklifId, istek.SozlesmeId, istek.SozTeslim], iptal);

            await baglanti.CalistirAsync("""
                update public.satinalma_talep set durum = @p1,
                       degistiren = @p2, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, TalepSiparise, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    belgeId, tarafId = istek.TarafId, satir = satirlar.Count,
                    baglanan, sozlesmeId = istek.SozlesmeId, sozTeslim = istek.SozTeslim
                }, iptal: iptal);

            await islem.CommitAsync(iptal);

            if (baglanan < satirlar.Count)
                uyarilar = [.. (uyarilar ?? []),
                            "Bazı talep satırları sipariş satırına bağlanamadı."];

            return Results.Ok(new
            {
                belgeId, satir = satirlar.Count, baglanan, uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // SİPARİŞ TAKİBİ: teslim damgaları, gecikme bildirimi, kısmi kabul.
        grup.MapPost("/siparis/{id:int}/takip", async (
            int id, TakipIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.siparis", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var s = await baglanti.TekAsync("""
                select b.belge_no as "belgeNo", b.taraf_id as "tarafId",
                       s.takip_durum as "takipDurum", s.soz_teslim as "sozTeslim",
                       s.gecikme_bildirim as "gecikmeBildirim", s.sozlesme_id as "sozlesmeId"
                  from public.belge b
                  join public.belge_satinalma s on s.id = b.id
                 where b.id = @p0 and b.tur = 9
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Alış siparişi bulunamadı.");

            if (Convert.ToInt16(s["takipDurum"] ?? (short)0) == 8 && istek.TakipDurum != 8)
                throw GentegreHatasi.IsKurali("İptal edilmiş siparişte takip ilerletilemez.");

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // GECİKME GÜNÜ SÖZ VERİLEN TARİHTEN sayılır, sipariş tarihinden
            //   değil - taahhüt neyse ona göre geç kalınır.
            var gecikme = await baglanti.TekDegerAsync<int>("""
                update public.belge_satinalma
                   set takip_durum = coalesce(@p1::smallint, takip_durum),
                       soz_teslim = coalesce(@p2, soz_teslim),
                       ilk_teslim = coalesce(@p3, ilk_teslim),
                       son_teslim = coalesce(@p4, son_teslim),
                       gecikme_bildirim = case when @p5 then coalesce(gecikme_bildirim, @p6)
                                               else gecikme_bildirim end,
                       aciklama = coalesce(nullif(@p7, ''), aciklama),
                       gecikme_gun = greatest(0, coalesce(
                            case when coalesce(@p1::smallint, takip_durum) = 2
                                 then (coalesce(@p4, son_teslim) - coalesce(@p2, soz_teslim))
                                 else (current_date - coalesce(@p2, soz_teslim)) end, 0))
                 where id = @p0
                returning gecikme_gun
                """, islem,
                [id, istek.TakipDurum, istek.SozTeslim, istek.IlkTeslim, istek.SonTeslim,
                 istek.GecikmeBildir, simdi, istek.Aciklama ?? ""], iptal);

            // GECİKME BİR OLAYDIR: tedarikçi skoru olaylardan türer, elle
            //   girilmez. Aynı sipariş için ikinci kez yazmayız.
            var olayYazildi = false;
            if (gecikme > 0 && s["tarafId"] is { } taraf)
                olayYazildi = await baglanti.CalistirAsync("""
                    insert into public.tedarikci_olay
                        (sube_id, firma_id, zaman, tur, belge_id, sozlesme_id,
                         aciklama, skor_etki, ekleyen)
                    select @p0, @p1, @p2, 1, @p3, @p4,
                           'Gecikme: ' || @p5 || ' gün', -1 * least(@p5, 10), @p6
                     where not exists (select 1 from public.tedarikci_olay o
                                        where o.belge_id = @p3 and o.tur = 1)
                    """, islem,
                    [baglam.SubeId ?? 0, Convert.ToInt32(taraf), simdi, id,
                     s["sozlesmeId"], gecikme, baglam.KullaniciId], iptal) > 0;

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogSiparis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    takipDurum = istek.TakipDurum, gecikmeGun = gecikme,
                    gecikmeBildirildi = istek.GecikmeBildir, olayYazildi
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                gecikmeGun = gecikme, takipDurum = istek.TakipDurum,
                olayYazildi, izlemeNo = baglam.IzlemeNo
            });
        });

        // CEZA İŞLE. Hesap sözleşmeden; işlemek ayrı karar.
        grup.MapPost("/siparis/{id:int}/ceza", async (
            int id, CezaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.siparis", Islem.Degistir);
            baglam.AksiyonIste("satinalma.ceza");

            await using var baglanti = await veri.AcAsync(iptal);

            var s = await baglanti.TekAsync("""
                select b.genel_toplam as "tutar", b.taraf_id as "tarafId",
                       s.gecikme_gun as "gecikmeGun", s.ceza_islendi as "cezaIslendi",
                       s.sozlesme_id as "sozlesmeId",
                       z.ceza_binde as "cezaBinde", z.ceza_ust_yuzde as "cezaUstYuzde"
                  from public.belge b
                  join public.belge_satinalma s on s.id = b.id
                  left join public.tedarikci_sozlesme z on z.id = s.sozlesme_id
                 where b.id = @p0 and b.tur = 9
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Alış siparişi bulunamadı.");

            if (Convert.ToInt16(s["cezaIslendi"] ?? (short)0) == 1)
                throw GentegreHatasi.IsKurali("Bu sipariş için ceza zaten işlenmiş.");

            var gecikme = Convert.ToInt32(s["gecikmeGun"] ?? 0);
            if (gecikme <= 0)
                throw GentegreHatasi.IsKurali("Gecikme yok - ceza hesaplanamaz.");

            var tutar = istek.Tutar;
            decimal? ustSinir = null;
            if (tutar is null)
            {
                // SÖZLEŞMESİZ CEZA HESAPLANMAZ: cezanın oranı sözleşmede yazar;
                //   uydurulmuş bir oran, tahsil edilemeyecek bir alacaktır.
                if (s["cezaBinde"] is null)
                    throw GentegreHatasi.IsKurali(
                        "Sözleşmede gecikme cezası oranı yok - tutar elle girilmeli.");

                var bedel = Convert.ToDecimal(s["tutar"] ?? 0m);
                var binde = Convert.ToDecimal(s["cezaBinde"] ?? 0m);
                tutar = Math.Round(bedel * binde / 1000m * gecikme, 2);

                // ÜST SINIR: sözleşmedeki yüzde. Sınırsız ceza, sözleşmeyi
                //   fesih yerine ceza toplama aracına çevirirdi.
                if (s["cezaUstYuzde"] is { } uy && Convert.ToDecimal(uy) > 0)
                {
                    ustSinir = Math.Round(bedel * Convert.ToDecimal(uy) / 100m, 2);
                    if (tutar > ustSinir) tutar = ustSinir;
                }
            }

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.belge_satinalma
                   set ceza_tutar = @p1, ceza_islendi = 1,
                       aciklama = trim(both ' ' from coalesce(aciklama, '')
                                  || ' · Ceza: ' || @p1)
                 where id = @p0
                """, islem, [id, tutar], iptal);

            if (s["tarafId"] is { } taraf)
                await baglanti.CalistirAsync("""
                    insert into public.tedarikci_olay
                        (sube_id, firma_id, zaman, tur, belge_id, sozlesme_id,
                         aciklama, skor_etki, ekleyen)
                    values (@p0, @p1, @p2, 1, @p3, @p4,
                            'Gecikme cezası işlendi: ' || @p5, -2, @p6)
                    """, islem,
                    [baglam.SubeId ?? 0, Convert.ToInt32(taraf), simdi, id,
                     s["sozlesmeId"], tutar, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogSiparis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { cezaTutar = tutar, gecikmeGun = gecikme, ustSinir, aciklama = istek.Aciklama },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                cezaTutar = tutar, gecikmeGun = gecikme, ustSinir,
                izlemeNo = baglam.IzlemeNo
            });
        });

        KabulFaturaUclari(grup);
    }

    /// <summary>
    /// KAREKOD EKSİĞİ UYARISI (737). Karekod taşıyan kalemde okutulan kutu
    /// sayısı beklenenin altındaysa, "sayıldı" denen şeyin bir kısmı hiç
    /// okutulmamış demektir. Kararı ENGELLEMEZ - karekodsuz gelen sevkiyat
    /// elle de sayılır - ama sessiz kalmak eksik okutmayı görünmez yapardı.
    /// Miat çelişkisi ve miadı geçmiş kutu da aynı yerde söylenir: ikisi de
    /// "kabul" imzasından önce bilinmesi gereken şeyler.
    /// </summary>
    private static async Task<List<string>> KarekodEksigiUyarisi(
        Npgsql.NpgsqlConnection baglanti, long kabulId, CancellationToken iptal)
    {
        var satirlar = await baglanti.ListeAsync("""
            select v.ad, v.beklenen, v.okutulan,
                   v.skt_celiskisi as "sktCeliskisi", v.miadi_gecmis as "miadiGecmis"
              from public.v_kabul_karekod_satir v
             where v.kabul_id = @p0 and v.beklenen > 0
               and (v.okutulan < v.beklenen or v.skt_celiskisi > 0 or v.miadi_gecmis > 0)
             order by v.sira
            """, null, [kabulId], OkuyucuGenisletmeleri.Sozluk, iptal);

        var uyarilar = new List<string>();
        foreach (var s in satirlar)
        {
            var beklenen = Convert.ToInt32(s["beklenen"] ?? 0);
            var okutulan = Convert.ToInt32(s["okutulan"] ?? 0);
            var celiski = Convert.ToInt32(s["sktCeliskisi"] ?? 0);
            var gecmis = Convert.ToInt32(s["miadiGecmis"] ?? 0);
            var notlar = new List<string>();
            if (okutulan < beklenen)
                notlar.Add($"{beklenen - okutulan} kutu okutulmadı ({okutulan}/{beklenen})");
            if (celiski > 0) notlar.Add($"{celiski} kutuda miat çelişkisi");
            if (gecmis > 0) notlar.Add($"{gecmis} kutu MİADI GEÇMİŞ");
            uyarilar.Add($"{s["ad"]}: {string.Join(" · ", notlar)}.");
        }
        return uyarilar;
    }

    // ================================================= mal kabul & fatura ==
    private static void KabulFaturaUclari(RouteGroupBuilder grup)
    {
        // ------------------------------------ tutanak bekleyen belgeler ----
        // TUTANAK BİR BELGEDEN DOĞAR. Ekranın "Yeni" düğmesi genel kart
        //   açıyordu: kart yalnız başlığı yazar, satırları İRSALİYEDEN
        //   kopyalayan uç (`POST /kabul`) çalışmazdı - sonuçta sıfır
        //   kalemli, muayene edilemeyen bir tutanak kalırdı ortada.
        //   Kullanıcıya belge NUMARASINI sormak da yetmiyordu: kart ham
        //   `belge_id` istiyordu, o da kimsenin ezberinde olmayan bir iç
        //   numaradır. Bu uç seçilebilir listeyi verir.
        //
        //   TUTANAĞI OLAN BELGE LİSTEDE YOK: bir belgenin tek tutanağı olur
        //   (`POST /kabul` de reddediyor), seçenek olarak göstermek
        //   kullanıcıyı hataya davet etmek olurdu.
        grup.MapGet("/kabul/bekleyen-belgeler", async (
            string? ara, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // İPTAL BELGE (durum 2) GELMEZ: iptal edilmiş bir irsaliyeyi
            //   muayene etmek, olmayan bir sevkiyatı tutanağa bağlamaktır.
            var satirlar = await baglanti.ListeAsync("""
                select b.id,
                       coalesce(nullif(b.belge_no, ''), '#' || b.id) as "belgeNo",
                       b.tur, b.belge_tarihi as "belgeTarihi",
                       coalesce(t.unvan, '')                        as "tedarikci",
                       (select count(*) from public.belge_satir s
                         where s.belge_id = b.id)                   as "satir",
                       -- SİPARİŞ BAĞI VARSA TAŞINIR, UYDURULMAZ: irsaliye bir
                       --   alış siparişinden dönüştürüldüyse `kaynak_id` o
                       --   siparişi gösterir. Bağ yoksa boş kalır - tedarikçiye
                       --   bakıp "herhalde şu siparişindir" demek, muayeneyi
                       --   yanlış siparişle karşılaştırmak olurdu.
                       (select s.id from public.belge s
                         where s.id = b.kaynak_id and coalesce(b.kaynak_id, 0) > 0
                           and s.tur = 9)                           as "siparisBelgeId"
                  from public.belge b
                  left join public.taraf t on t.id = b.taraf_id
                 where b.tur in (10, 11)
                   and coalesce(b.durum, 0) <> 2
                   and (@p0 is null or b.sube_id = @p0)
                   and not exists (select 1 from public.satinalma_kabul k
                                    where k.belge_id = b.id)
                   and (@p1 = '' or coalesce(b.belge_no, '') ilike '%' || @p1 || '%'
                        or coalesce(t.unvan, '') ilike '%' || @p1 || '%')
                 order by b.belge_tarihi desc, b.id desc
                 limit 50
                """, null, [baglam.SubeId, (ara ?? "").Trim()],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // MAL KABUL TUTANAĞI. İrsaliye ile siparişi KARŞILAŞTIRIR - tek belgeye
        //   bağlansaydı "sipariş dışı gelen" hiç görünmezdi.
        grup.MapPost("/kabul", async (
            KabulIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Ekle);

            if (istek.Sonuc is < 0 or > 3)
                throw GentegreHatasi.Dogrulama("Geçersiz sonuç.",
                    new AlanHatasi("sonuc", "0 açık · 1 kabul · 2 kısmi kabul · 3 ret"));
            if (istek.Sonuc is 2 or 3 && string.IsNullOrWhiteSpace(istek.Uygunsuzluk))
                throw GentegreHatasi.Dogrulama("Uygunsuzluk metni zorunlu.",
                    new AlanHatasi("uygunsuzluk", "Kısmi kabul ve rette uygunsuzluk yazılmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.tur, b.taraf_id as "tarafId", b.sube_id as "subeId",
                       coalesce(b.belge_no, '') as "belgeNo"
                  from public.belge b where b.id = @p0
                """, null, [istek.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İrsaliye/fatura bulunamadı.");

            var mevcut = await baglanti.TekDegerAsync<long?>("""
                select id from public.satinalma_kabul where belge_id = @p0
                """, null, [istek.BelgeId], iptal);
            if (mevcut is not null)
                throw GentegreHatasi.IsKurali("Bu belge için kabul tutanağı zaten var.");

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var kabulId = await baglanti.TekDegerAsync<long>("""
                insert into public.satinalma_kabul
                    (sube_id, belge_id, siparis_belge_id, tarih, komisyon, sonuc,
                     uygunsuzluk, kullanici_birim_onay, kullanici_birim_id,
                     tutanak_no, ekleyen)
                values (@p0, @p1, @p2, current_date, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
                returning id
                """, islem,
                [baglam.SubeId ?? b["subeId"], istek.BelgeId, istek.SiparisBelgeId,
                 istek.Komisyon ?? "", istek.Sonuc, istek.Uygunsuzluk ?? "",
                 (short)(istek.KullaniciBirimOnay ? 1 : 0), istek.KullaniciBirimId,
                 istek.TutanakNo ?? "", baglam.KullaniciId], iptal);

            // ---- SATIRLAR İRSALİYEDEN KOPYALANIR (733).
            //
            //   ÜÇ MİKTAR AYRI: sipariş · irsaliye · sayılan. Sayılan burada
            //   irsaliyedekine eşit doğar - muayenede sayan kişi düzeltir.
            //   Sıfır doğsaydı "henüz sayılmadı" ile "sıfır sayıldı" aynı
            //   görünürdü; irsaliyeye eşit doğunca FARK, sayımın kendisi olur.
            //
            //   SİPARİŞ MİKTARI aynı stoğun sipariş satırlarının TOPLAMIDIR:
            //   bir kalem siparişte iki satır hâlinde olabilir (iki teslim
            //   tarihi), irsaliyede tek satır gelir.
            //
            //   LOT ve MİAD belgenin izlem satırından: mal kabulün asıl
            //   sorularından biri "hangi lot, ne miadla girdi".
            var satirSayisi = 0;
            if (istek.SatirDoldur)
                satirSayisi = await baglanti.CalistirAsync("""
                    insert into public.satinalma_kabul_satir
                        (kabul_id, sira, stok_id, ad, birim, siparis_miktar,
                         irsaliye_miktar, sayilan, birim_fiyat, lot, skt,
                         belge_satir_id, ekleyen)
                    select @p0,
                           row_number() over (order by bs.sira, bs.id),
                           bs.stok_id,
                           coalesce(nullif(bs.aciklama, ''), st.ad, ''),
                           -- BİRİM BELGEDE KOD (smallint), tutanakta METİN:
                           --   muayene tutanağı basılıp imzalanan bir kâğıt,
                           --   üstünde "3" değil "AD" yazmalı. Kod listesinden
                           --   çözülüyor; çözülemezse boş kalır (uydurulmuş bir
                           --   birim, yanlış miktar okumaya yol açar).
                           coalesce((select kd.ad from public.kod_deger kd
                                       join public.kod_liste kl on kl.id = kd.liste_id
                                      where kl.kod = 'stok.ana_birim'
                                        and kd.deger = coalesce(bs.birim, st.ana_birim)
                                        and kd.dil = 0), ''),
                           coalesce((select sum(ss.miktar) from public.belge_satir ss
                                      where ss.belge_id = @p2::int
                                        and ss.stok_id = bs.stok_id), 0),
                           bs.miktar, bs.miktar, bs.birim_fiyat,
                           coalesce((select max(iz.lot_no) from public.v_belge_satir_izlem iz
                                      where iz.belge_satir_id = bs.id), ''),
                           (select max(iz.son_kullanma_tarihi)::date
                              from public.v_belge_satir_izlem iz
                             where iz.belge_satir_id = bs.id),
                           bs.id, @p3
                      from public.belge_satir bs
                      left join public.stok st on st.id = bs.stok_id
                     where bs.belge_id = @p1 and bs.stok_id is not null and bs.miktar > 0
                    """, islem,
                    [kabulId, istek.BelgeId, istek.SiparisBelgeId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogKabul, kabulId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    belgeId = istek.BelgeId, siparisBelgeId = istek.SiparisBelgeId,
                    sonuc = istek.Sonuc, uygunsuzluk = istek.Uygunsuzluk, satirSayisi
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id = kabulId, sonuc = istek.Sonuc, satir = satirSayisi,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // TÜM KALEMLERİ KABUL ET. Muayenede istisna yoksa otuz satırı tek
        //   tek işaretlemek zaman kaybı; istisna varsa zaten satır satır
        //   girilir. SAYILANI İRSALİYEYE EŞİTLEMEK İSTEĞE BAĞLI: sayım
        //   yapılmışsa onu ezmemeli.
        grup.MapPost("/kabul/{id:long}/tumunu-kabul", async (
            long id, TumunuKabulIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.sonuc, k.tutanak_no as "tutanakNo",
                       (select count(*) from public.satinalma_kabul_satir s
                         where s.kabul_id = k.id) as "kalem"
                  from public.satinalma_kabul k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kabul tutanağı bulunamadı.");

            if (Convert.ToInt32(k["kalem"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali("Tutanakta muayene satırı yok.");
            // REDDEDİLMİŞ TUTANAK TOPLU KABULLE GERİ ALINMAZ: ret kalem dışı
            //   bir sebeple verilmiş olabilir; geri almak ayrı bir karardır.
            if (Convert.ToInt16(k["sonuc"] ?? (short)0) == 3)
                throw GentegreHatasi.IsKurali(
                    "Reddedilmiş tutanakta toplu kabul yapılamaz.");

            var etkilenen = await baglanti.CalistirAsync("""
                update public.satinalma_kabul_satir
                   set sayilan = case when @p1 then irsaliye_miktar else sayilan end,
                       sonuc = 1, degistiren = @p2,
                       degistirme_tarihi = (now())::timestamp
                 where kabul_id = @p0 and sonuc = 0
                """, null, [id, istek.SayilaniEsitle, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogKabul, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { tumunuKabul = etkilenen, sayilaniEsitle = istek.SayilaniEsitle },
                iptal: iptal);

            // KAREKOD EKSİKSE SÖYLENİR, ENGELLENMEZ. "Sayılan = irsaliye
            //   miktarı" demek kutuları saydığını iddia etmektir; kutuların
            //   bir kısmı hiç okutulmamışsa bu iddia dayanaksızdır. Yine de
            //   engellemiyoruz: karekodsuz gelen (okuyucusu bozuk, kodu
            //   silinmiş) sevkiyat elle de sayılır - ama sessiz kalsaydık
            //   eksik okutma hiç fark edilmezdi.
            var uyarilar = await KarekodEksigiUyarisi(baglanti, id, iptal);

            return Results.Ok(new
            {
                kabulEdilen = etkilenen, uyarilar, izlemeNo = baglam.IzlemeNo
            });
        });

        // KOMİSYON KARARI. Tutanağın sonucu satırlardan da türüyor (733
        //   tetiği) ama tetik BAŞLIĞI YALNIZ AŞAĞI çeker; komisyon kalem
        //   dışı bir sebeple (belge eksiği, sözleşme ihlali) tutanağın
        //   tamamını reddedebilir ve o karar burada verilir.
        //
        //   SİPARİŞİ DE BU KARAR KAPATIR: tam kabul "tamamlandı", kısmi
        //   kabul "kısmi teslim". Tutanak açılışında kapatsaydık, muayenesi
        //   yapılmamış bir teslimat siparişi kapatmış olurdu.
        grup.MapPost("/kabul/{id:long}/karar", async (
            long id, KabulKararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Degistir);

            if (istek.Sonuc is < 1 or > 3)
                throw GentegreHatasi.Dogrulama("Geçersiz sonuç.",
                    new AlanHatasi("sonuc", "1 kabul · 2 kısmi kabul · 3 ret"));
            if (istek.Sonuc is 2 or 3 && string.IsNullOrWhiteSpace(istek.Uygunsuzluk))
                throw GentegreHatasi.Dogrulama("Uygunsuzluk metni zorunlu.",
                    new AlanHatasi("uygunsuzluk",
                        "Kısmi kabul ve rette neyin uygunsuz olduğu yazılmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.sonuc, k.belge_id as "belgeId",
                       k.siparis_belge_id as "siparisBelgeId",
                       k.soguk_zincir as "sogukZincir", b.taraf_id as "tarafId",
                       (select count(*) from public.satinalma_kabul_satir s
                         where s.kabul_id = k.id) as "kalem",
                       (select count(*) from public.satinalma_kabul_satir s
                         where s.kabul_id = k.id and s.sonuc = 0) as "bekleyen",
                       (select count(*) from public.satinalma_kabul_satir s
                         where s.kabul_id = k.id and s.sonuc = 3) as "ret"
                  from public.satinalma_kabul k
                  left join public.belge b on b.id = k.belge_id
                 where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kabul tutanağı bulunamadı.");

            // SATIRSIZ TUTANAK KARARA BAĞLANMAZ. "Bekleyen satır yok" iki
            //   ayrı şey olabilir: her kalem muayene edildi ya da HİÇ KALEM
            //   YOK. İkincisini de geçirseydik - ki geçiriyordu - hiçbir
            //   kalem sayılmadan "Kabul" edilmiş bir tutanak çıkardı
            //   ortaya; sayım yapılmadığını gösteren tek iz kalmazdı.
            //   (735'te düzeltilen hatanın kardeşi: orada da "bekleyen
            //   yoksa kabul say" kestirmesi vardı.)
            if (Convert.ToInt32(k["kalem"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali(
                    "Muayene satırı olmayan tutanak karara bağlanamaz - "
                    + "önce irsaliye kalemlerini tutanağa alın.");

            // MUAYENESİ BİTMEMİŞ TUTANAK KARARA BAĞLANMAZ: bekleyen satır,
            //   "bu kalem için henüz bir şey söylemedik" demektir.
            var bekleyen = Convert.ToInt32(k["bekleyen"] ?? 0);
            if (bekleyen > 0)
                throw GentegreHatasi.IsKurali(
                    $"{bekleyen} kalemin muayenesi tamamlanmamış.", new { bekleyen });

            // SOĞUK ZİNCİR GEREKİYORSA ÖLÇÜM YAZILMALI. "Ölçülmedi" ile
            //   "uygun" aynı şey değil; ölçülmemiş bir sevkiyatı kabul etmek
            //   kurumun sonradan hesabını vereceği bir karardır.
            var soguk = istek.SogukZincirUygun ?? (short)0;
            if (Convert.ToInt16(k["sogukZincir"] ?? (short)0) == 1 && soguk == 0
                && istek.Sonuc != 3)
                throw GentegreHatasi.Dogrulama("Soğuk zincir ölçümü zorunlu.",
                    new AlanHatasi("sogukZincirUygun",
                        "Soğuk zincir gerektiren sevkiyatta ölçüm sonucu yazılmalı."));

            var uyarilar = new List<string>();
            if (soguk == 2 && istek.Sonuc != 3)
                uyarilar.Add("Soğuk zincir uygunsuz - kabul kararı tutanağa yazıldı.");
            // KAREKOD EKSİĞİ KARARDAN ÖNCE SÖYLENİR (737): imza atılan yer
            //   burası. Reddedilen sevkiyatta sorulmaz - kutu sayısı artık
            //   bizim sorunumuz değil.
            if (istek.Sonuc != 3)
                uyarilar.AddRange(await KarekodEksigiUyarisi(baglanti, id, iptal));

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.satinalma_kabul
                   set sonuc = @p1, komisyon = coalesce(nullif(@p2, ''), komisyon),
                       uygunsuzluk = coalesce(nullif(@p3, ''), uygunsuzluk),
                       kullanici_birim_onay = @p4,
                       kullanici_birim_id = coalesce(@p5, kullanici_birim_id),
                       soguk_zincir_uygun = @p6,
                       sicaklik = coalesce(@p7, sicaklik),
                       tasima_kosulu = coalesce(nullif(@p8, ''), tasima_kosulu),
                       degistiren = @p9, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, istek.Sonuc, istek.Komisyon ?? "", istek.Uygunsuzluk ?? "",
                 (short)(istek.KullaniciBirimOnay ? 1 : 0), istek.KullaniciBirimId,
                 soguk, istek.Sicaklik, istek.TasimaKosulu ?? "", baglam.KullaniciId], iptal);

            // SİPARİŞİ KAPAT (bkz. yukarı). Ret hâlinde sipariş AÇIK KALIR:
            //   mal geri gidiyor, taahhüt sürüyor.
            if (k["siparisBelgeId"] is { } sip && istek.Sonuc != 3)
                await baglanti.CalistirAsync("""
                    update public.belge_satinalma
                       set takip_durum = case when @p1 = 1 then 2 else 1 end,
                           kismi_kabul = case when @p1 = 2 then 1 else kismi_kabul end,
                           ilk_teslim = coalesce(ilk_teslim, current_date),
                           son_teslim = current_date
                     where id = @p0
                    """, islem, [Convert.ToInt32(sip), istek.Sonuc], iptal);

            // UYGUNSUZLUK BİR OLAYDIR: tedarikçi skoru olaylardan türer,
            //   elle girilmez. Aynı belge için ikinci kez yazılmaz.
            if ((istek.Sonuc is 2 or 3 || soguk == 2) && k["tarafId"] is { } taraf)
                await baglanti.CalistirAsync("""
                    insert into public.tedarikci_olay
                        (sube_id, firma_id, zaman, tur, belge_id, aciklama, skor_etki, ekleyen)
                    select @p0, @p1, @p2, 2, @p3, @p4, @p5, @p6
                     where not exists (select 1 from public.tedarikci_olay o
                                        where o.belge_id = @p3 and o.tur = 2)
                    """, islem,
                    [baglam.SubeId ?? 0, Convert.ToInt32(taraf), simdi, k["belgeId"],
                     "Mal kabul uygunsuzluğu: "
                     + (string.IsNullOrWhiteSpace(istek.Uygunsuzluk)
                        ? "soğuk zincir uygunsuz" : istek.Uygunsuzluk),
                     istek.Sonuc == 3 ? -5m : -2m, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogKabul, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    sonuc = istek.Sonuc, uygunsuzluk = istek.Uygunsuzluk,
                    sogukZincirUygun = soguk, sicaklik = istek.Sicaklik,
                    retKalem = k["ret"], uyarilar
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                sonuc = istek.Sonuc, retKalem = k["ret"], uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });
        // ÜÇLÜ EŞLEŞTİRME: sipariş - teslim - fatura.
        grup.MapPost("/fatura-eslestir", async (
            EslestirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.fatura", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var f = await baglanti.TekAsync("""
                select b.tur, b.genel_toplam as "faturaTutar", b.taraf_id as "tarafId",
                       b.sube_id as "subeId", coalesce(b.belge_no, '') as "belgeNo"
                  from public.belge b where b.id = @p0
                """, null, [istek.FaturaBelgeId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Fatura bulunamadı.");

            if (Convert.ToInt16(f["tur"] ?? (short)0) != 11)
                throw GentegreHatasi.IsKurali("Bu belge alış faturası (tür 11) değil.");

            // SİPARİŞ VERİLMEDİYSE talebin siparişinden bulunur. Bulunamazsa
            //   eşleştirme yapılamaz - "sipariş dışı fatura" da bir sonuçtur
            //   ama onu uydurmayız, kullanıcı siparişi seçmeli.
            var siparisId = istek.SiparisBelgeId;
            if (siparisId is null && f["tarafId"] is { } tf)
                siparisId = await baglanti.TekDegerAsync<int?>("""
                    select b.id from public.belge b
                      join public.belge_satinalma s on s.id = b.id
                     where b.tur = 9 and b.taraf_id = @p0 and s.takip_durum in (1, 2)
                     order by b.belge_tarihi desc, b.id desc limit 1
                    """, null, [Convert.ToInt32(tf)], iptal);

            if (siparisId is null)
                throw GentegreHatasi.IsKurali(
                    "Eşleştirilecek sipariş bulunamadı - siparişi seçin.");

            var s = await baglanti.TekAsync("""
                select b.genel_toplam as "siparisTutar",
                       (select coalesce(sum(i.genel_toplam), 0)
                          from public.satinalma_kabul k
                          join public.belge i on i.id = k.belge_id
                         where k.siparis_belge_id = b.id and k.sonuc in (1, 2)) as "teslimTutar"
                  from public.belge b where b.id = @p0 and b.tur = 9
                """, null, [siparisId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Alış siparişi bulunamadı.");

            var faturaTutar = Convert.ToDecimal(f["faturaTutar"] ?? 0m);
            var siparisTutar = Convert.ToDecimal(s["siparisTutar"] ?? 0m);
            var teslimTutar = Convert.ToDecimal(s["teslimTutar"] ?? 0m);

            // KARŞILAŞTIRMA TABANI TESLİMDİR, SİPARİŞ DEĞİL: ödenecek olan
            //   gelen maldır. Teslim kaydı hiç yoksa siparişe düşeriz ve bunu
            //   fark metnine yazarız - sessizce siparişi taban almak, gelmemiş
            //   malı ödemeye açmak olurdu.
            var taban = teslimTutar > 0 ? teslimTutar : siparisTutar;
            var fark = Math.Round(faturaTutar - taban, 2);

            // TOLERANS kurum ayarı (kuruş farkları fatura kontrolünü boğmasın).
            var tolerans = await AyarSayiAsync(baglanti,
                "satinalma.eslestirme_tolerans_kurus", 100m, iptal) / 100m;

            // sonuc: 0 kontrol edilmedi · 1 tuttu · 2 miktar farkı ·
            //        3 fiyat farkı · 4 KDV/bilgi farkı · 5 birden çok fark
            var farkMetni = new List<string>();
            short sonuc;
            if (Math.Abs(fark) <= tolerans)
            {
                sonuc = 1;
            }
            else
            {
                // Miktar mı fiyat mı ayrımını satır kırılımı olmadan yapamayız;
                //   tutar farkını "fiyat farkı" saymak yerine kaynağını yazıyoruz.
                sonuc = 3;
                farkMetni.Add(fark > 0
                    ? $"Fatura teslimden {fark:N2} fazla"
                    : $"Fatura teslimden {Math.Abs(fark):N2} eksik");
            }

            if (teslimTutar <= 0)
            {
                farkMetni.Add("Teslim (mal kabul) kaydı yok - sipariş tutarı taban alındı.");
                if (sonuc == 1) sonuc = 4;
            }
            if (teslimTutar > 0 && siparisTutar > 0
                && Math.Abs(teslimTutar - siparisTutar) > tolerans)
            {
                farkMetni.Add($"Teslim siparişten {teslimTutar - siparisTutar:N2} sapıyor");
                sonuc = sonuc == 1 ? (short)2 : (short)5;
            }

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var kayitId = await baglanti.TekDegerAsync<long>("""
                insert into public.satinalma_fatura_kontrol
                    (sube_id, fatura_belge_id, siparis_belge_id, sonuc,
                     siparis_tutar, teslim_tutar, fatura_tutar, fark_tutar, fark_metni,
                     odeme_durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, 0, @p9)
                on conflict (fatura_belge_id) do update
                   set siparis_belge_id = excluded.siparis_belge_id,
                       sonuc = excluded.sonuc, siparis_tutar = excluded.siparis_tutar,
                       teslim_tutar = excluded.teslim_tutar,
                       fatura_tutar = excluded.fatura_tutar,
                       fark_tutar = excluded.fark_tutar, fark_metni = excluded.fark_metni,
                       degistiren = excluded.ekleyen
                returning id
                """, islem,
                [baglam.SubeId ?? f["subeId"], istek.FaturaBelgeId, siparisId, sonuc,
                 siparisTutar, teslimTutar, faturaTutar, fark,
                 string.Join(" · ", farkMetni), baglam.KullaniciId], iptal);

            // FATURA FARKI DA BİR OLAYDIR (tür 3). Aynı fatura için tekrar yazılmaz.
            if (sonuc != 1 && f["tarafId"] is { } taraf)
                await baglanti.CalistirAsync("""
                    insert into public.tedarikci_olay
                        (sube_id, firma_id, zaman, tur, belge_id, aciklama, skor_etki, ekleyen)
                    select @p0, @p1, @p2, 3, @p3, @p4, -1, @p5
                     where not exists (select 1 from public.tedarikci_olay o
                                        where o.belge_id = @p3 and o.tur = 3)
                    """, islem,
                    [baglam.SubeId ?? 0, Convert.ToInt32(taraf), simdi, istek.FaturaBelgeId,
                     "Fatura farkı: " + string.Join(" · ", farkMetni), baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogFatura, kayitId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.FaturaBelgeId, siparisId, sonuc, siparisTutar, teslimTutar,
                      faturaTutar, fark, farkMetni }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id = kayitId, sonuc, siparisTutar, teslimTutar, faturaTutar,
                farkTutar = fark, farkMetni = string.Join(" · ", farkMetni),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ÖDEME KARARI. Eşleştirmeden AYRI yetki: farkı görmekle ödemeyi
        //   serbest bırakmak aynı sorumluluk değil.
        grup.MapPost("/fatura/{id:long}/odeme", async (
            long id, OdemeKararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.fatura", Islem.Degistir);
            baglam.AksiyonIste("satinalma.odeme_onay");

            if (istek.Karar is < 1 or > 4)
                throw GentegreHatasi.Dogrulama("Geçersiz karar.",
                    new AlanHatasi("karar",
                        "1 ödemeye onay · 2 ödeme durduruldu · 3 itiraz edildi · 4 düzeltildi"));
            if (istek.Karar is 2 or 3 && string.IsNullOrWhiteSpace(istek.Metin))
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("metin", "Durdurma ve itirazda gerekçe zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.sonuc, k.fark_tutar as "farkTutar", k.odeme_durum as "odemeDurum",
                       k.fatura_belge_id as "faturaBelgeId"
                  from public.satinalma_fatura_kontrol k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Fatura kontrolü bulunamadı.");

            if (Convert.ToInt16(k["sonuc"] ?? (short)0) == 0)
                throw GentegreHatasi.IsKurali(
                    "Eşleştirme yapılmadan ödeme kararı verilemez.");

            // FARK VARKEN ONAY, MAHSUP YA DA GEREKÇE İSTER. Farkı görüp
            //   "tamam" demek, farkın kendisini kayıttan silmez ama neden
            //   ödendiğini de yazmaz - denetimde sorulacak olan tam da bu.
            var fark = Convert.ToDecimal(k["farkTutar"] ?? 0m);
            if (istek.Karar == 1 && Math.Abs(fark) > 0
                && istek.MahsupTutar is null && string.IsNullOrWhiteSpace(istek.Metin))
                throw GentegreHatasi.Dogrulama("Farklı faturada onay gerekçesi ya da mahsup zorunlu.",
                    new AlanHatasi("metin", $"Fark {fark:N2} - gerekçe ya da mahsup tutarı girin."));

            var simdi = DateTime.Now;

            await baglanti.CalistirAsync("""
                update public.satinalma_fatura_kontrol
                   set odeme_durum = @p1,
                       mahsup_tutar = coalesce(@p2, mahsup_tutar),
                       itiraz_zamani = case when @p1 = 3 then coalesce(itiraz_zamani, @p3)
                                            else itiraz_zamani end,
                       itiraz_metni = case when @p1 = 3 then coalesce(nullif(@p4, ''), itiraz_metni)
                                           else itiraz_metni end,
                       fark_metni = case when @p1 <> 3 and nullif(@p4, '') is not null
                                         then trim(both ' ' from coalesce(fark_metni, '')
                                              || ' · ' || @p4)
                                         else fark_metni end,
                       karar_veren_id = @p5, karar_zamani = @p3,
                       degistiren = @p5, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, null,
                [id, istek.Karar, istek.MahsupTutar, simdi, istek.Metin ?? "",
                 baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogFatura, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { karar = istek.Karar, fark, mahsup = istek.MahsupTutar, metin = istek.Metin },
                iptal: iptal);

            return Results.Ok(new
            {
                odemeDurum = istek.Karar, kararZamani = simdi, izlemeNo = baglam.IzlemeNo
            });
        });
    }
}
