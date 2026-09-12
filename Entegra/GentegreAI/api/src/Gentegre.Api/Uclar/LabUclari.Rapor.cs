using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LAB RAPORU — sonuç raporunun derlenmesi.
///
/// Uclar LabUclari.cs dosyasindan ayrildi: tek dosyada 2103 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class LabUclari
{
    private static void RaporEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------------ rapor ---

        // GET /api/lab/rapor/{istemId} - HASTAYA VERİLEN belge.
        //
        // Çalışma ekranlarından AYRI uç: çıktının ihtiyacı iş akışı değil,
        // kurum anteti, kimlik satırları, RAPORLANACAK sonuçlar ve imzadır.
        // Tek uç üç bölümü de döndürür (sayısal · kültür · genetik) çünkü bir
        // istemde birden çok tür bulunabilir; sayfa hangi bölüm doluysa onu
        // basar. Üç ayrı uç, aynı hastanın raporunu üç parçaya bölerdi.
        //
        // YALNIZ ONAYLI SONUÇLAR: onaylanmamış değer hastaya verilen belgeye
        // giremez - taslak rapor "geçici" damgasıyla basılır.
        grup.MapGet("/rapor/{istemId:int}", async (
            int istemId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.id, i.istem_no as "istemNo", i.istem_tarihi as "istemTarihi",
                       i.durum, i.oncelik, i.klinik_bilgi as "klinikBilgi",
                       i.tani_icd as "taniIcd", i.sonuc_tarihi as "sonucTarihi",
                       i.hedef_bitis as "hedefBitis",
                       coalesce(h.unvan, '') as "hastaAdi", coalesce(h.kod, '') as "hastaNo",
                       coalesce(h.vkno, '') as "hastaTc",
                       hs.dogum_tarihi as "dogumTarihi", coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(p.unvan, '') as "isteyenHekim",
                       coalesce(b.belge_no, '') as "protokolNo",
                       coalesce(ok.unvan, '') as "odeyenKurum",
                       (select min(n.alim_zamani) from public.lab_numune n
                         where n.istem_id = i.id) as "numuneAlim",
                       (select min(n.kabul_zamani) from public.lab_numune n
                         where n.istem_id = i.id) as "numuneKabul"
                  from public.lab_istem i
                  left join public.taraf h on h.id = i.taraf_id
                  left join public.taraf_hasta hs on hs.id = i.taraf_id
                  left join public.taraf p on p.id = i.personel_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where i.id = @p0
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            // SAYISAL SONUÇLAR (biyokimya/hematoloji): bayrak, referans ve
            //   ölçüm zamanı SONUÇLA BİRLİKTE saklandığı gibi basılır -
            //   yeniden hesaplanmaz, yoksa eski rapor bugünkü referansla
            //   yeniden yorumlanmış olurdu.
            var sonuclar = await baglanti.ListeAsync("""
                select t.kod, t.ad, ls.deger_metin as deger, ls.birim, ls.bayrak,
                       ls.referans_alt as "referansAlt", ls.referans_ust as "referansUst",
                       ls.referans_metin as "referansMetin", ls.panik,
                       ls.delta_onceki as "deltaOnceki", ls.delta_yuzde as "deltaYuzde",
                       ls.delta_uyari as "deltaUyari", ls.yorum, ls.tekrar_no as "tekrarNo",
                       ls.olcum_zamani as "olcumZamani", ls.onay_zamani as "onayZamani",
                       coalesce(t.yontem, '') as yontem, coalesce(c.ad, '') as "cihazAdi",
                       coalesce(o.unvan, '') as "onaylayan", t.bolum,
                       coalesce(n.barkod, '') as barkod,
                       -- NUMUNE KALİTESİ raporun zorunlu parçası (ISO 15189):
                       --   "K yüksek" ile "hemoliz nedeniyle yüksek görünüyor"
                       --   hekim için bambaşka iki bilgi.
                       ls.indeks_durum as "indeksDurum", ls.indeks_uyari as "indeksUyari",
                       n.hemoliz_idx as "hemolizIdx", n.lipemi_idx as "lipemiIdx",
                       n.ikter_idx as "ikterIdx"
                  from public.lab_istem_satir s
                  join public.lab_tetkik t on t.id = s.tetkik_id
                  join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
                  left join public.lab_numune n on n.id = ls.numune_id
                  left join public.cihaz c on c.id = ls.cihaz_id
                  left join public.taraf o on o.id = ls.onay_id
                 where s.istem_id = @p0 and s.durum <> 0 and t.tur in (1, 2, 3)
                 order by t.bolum, s.sira, t.kod
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KÜLTÜR: rapor bölümü izolat + antibiyogram. Antibiyogramda
            //   YALNIZ bildir = 1 satırlar - kademeli bildirim kararı burada
            //   da geçerli; gizlenen ajanı basmak kuralı anlamsız kılardı.
            var kulturler = await baglanti.ListeAsync("""
                select k.id, t.kod, t.ad, coalesce(n.barkod, '') as barkod,
                       k.ekim_zamani as "ekimZamani", k.direkt_baki as "direktBaki",
                       k.gram_sonuc as "gramSonuc", k.numune_kalite as "numuneKalite",
                       k.on_rapor as "onRapor", k.on_rapor_zamani as "onRaporZamani",
                       k.uzman_yorum as "uzmanYorum", k.onay_zamani as "onayZamani",
                       k.kritik, k.ekk_bildirim as "ekkBildirim", k.durum,
                       coalesce(o.unvan, '') as "onaylayan",
                       public.fn_lab_kultur_ozet(k.id) as ozet,
                       coalesce((select string_agg(b.ad || coalesce(' (lot ' || nullif(kb.lot, '') || ')', ''),
                                                   ' · ' order by kb.sira)
                                   from public.lab_kultur_besiyeri kb
                                   join public.lab_besiyeri b on b.id = kb.besiyeri_id
                                  where kb.kultur_id = k.id), '') as besiyeri
                  from public.lab_kultur k
                  join public.lab_tetkik t on t.id = k.tetkik_id
                  left join public.lab_numune n on n.id = k.numune_id
                  left join public.taraf o on o.id = k.onay_id
                 where k.istem_id = @p0 and k.durum <> 0
                 order by k.id
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var izolatlar = await baglanti.ListeAsync("""
                select u.id, u.kultur_id as "kulturId", u.izolat_no as "izolatNo",
                       o.ad as organizma, u.koloni_sayisi as "koloniSayisi",
                       u.koloni_birim as "koloniBirim", u.anlamli,
                       u.id_yontem as "idYontem", u.id_guven as "idGuven",
                       u.esbl, u.karbapenemaz, u.mrsa, u.vre, u.ampc,
                       u.direnc_notu as "direncNotu", o.bildirimi_zorunlu as "bildirimiZorunlu"
                  from public.lab_kultur_ureme u
                  join public.lab_organizma o on o.id = u.organizma_id
                  join public.lab_kultur k on k.id = u.kultur_id
                 where k.istem_id = @p0 and u.durum = 1
                 order by u.kultur_id, u.izolat_no
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var antibiyogram = await baglanti.ListeAsync("""
                select g.ureme_id as "uremeId", a.ad as antibiyotik, a.basamak,
                       g.mic, g.mic_isaret as "micIsaret", g.zon_mm as "zonMm",
                       g.yorum, g.standart, g.standart_surum as "standartSurum",
                       g.aciklama, a.yalniz_uriner as "yalnizUriner"
                  from public.lab_antibiyogram g
                  join public.lab_antibiyotik a on a.id = g.antibiyotik_id
                  join public.lab_kultur_ureme u on u.id = g.ureme_id
                  join public.lab_kultur k on k.id = u.kultur_id
                 where k.istem_id = @p0 and g.bildir = 1
                 order by g.ureme_id, a.basamak, a.ad
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // GENETİK: vaka başlığı, yöntem/kalite ve RAPORLANAN varyantlar.
            //   Hastanın istemediği ikincil bulgular raporla = 0 olduğu için
            //   burada da görünmez.
            var vakalar = await baglanti.ListeAsync("""
                select g.id, g.vaka_no as "vakaNo", t.kod, t.ad,
                       coalesce(n.barkod, '') as barkod,
                       g.endikasyon, g.tani_icd as "taniIcd",
                       g.aile_oykusu as "aileOykusu",
                       g.onam_surum as "onamSurum", g.onam_tarihi as "onamTarihi",
                       g.tesadufi_bulgu as "tesadufiBulgu",
                       g.veri_saklama_yil as "veriSaklamaYil",
                       g.izolasyon_tarihi as "izolasyonTarihi",
                       g.dna_konsantrasyon as "dnaKonsantrasyon",
                       g.dna_saflik as "dnaSaflik",
                       g.kapsama_yuzde as "kapsamaYuzde", g.ort_derinlik as "ortDerinlik",
                       g.kontaminasyon, g.cinsiyet_dogrulama as "cinsiyetDogrulama",
                       g.uzman_yorum as "uzmanYorum", g.oneriler, g.sinirliliklar,
                       g.onay_zamani as "onayZamani", g.durum, g.rapor_surum as "raporSurum",
                       coalesce(o.unvan, '') as "onaylayan",
                       public.fn_lab_genetik_ozet(g.id) as ozet,
                       coalesce(p.ad, '') as panel, coalesce(p.yontem, 1) as yontem,
                       coalesce(p.referans_genom, '') as "referansGenom",
                       coalesce(p.pipeline, '') as pipeline,
                       coalesce(r.kod, '') as "runKodu", coalesce(r.cihaz_adi, '') as cihaz,
                       r.q30,
                       coalesce((select string_agg(ge.sembol, ', ' order by ge.sembol)
                                   from public.lab_genetik_panel_gen pg
                                   join public.lab_gen ge on ge.id = pg.gen_id
                                  where pg.panel_id = p.id), '') as "genListesi"
                  from public.lab_genetik_vaka g
                  join public.lab_tetkik t on t.id = g.tetkik_id
                  left join public.lab_genetik_panel p on p.id = g.panel_id
                  left join public.lab_genetik_run r on r.id = g.run_id
                  left join public.lab_numune n on n.id = g.numune_id
                  left join public.taraf o on o.id = g.onay_id
                 where g.istem_id = @p0 and g.durum <> 0
                 order by g.id
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var varyantlar = await baglanti.ListeAsync("""
                select v.vaka_id as "vakaId", v.gen_sembol as "genSembol",
                       v.transkript, v.hgvs_c as "hgvsC", v.hgvs_p as "hgvsP",
                       v.zigosite, v.kalitim, v.gnomad_af as "gnomadAf",
                       v.clinvar, v.acmg_kriterler as "acmgKriterler", v.sinif,
                       v.dogrulama, v.dogrulama_yontem as "dogrulamaYontem",
                       v.dogrulama_tarihi as "dogrulamaTarihi", v.yorum
                  from public.lab_varyant v
                  join public.lab_genetik_vaka g on g.id = v.vaka_id
                 where g.istem_id = @p0 and v.raporla = 1
                 order by v.vaka_id, v.sinif desc, v.gen_sembol
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ANTET: istemin şubesi; yoksa varsayılan şube. Kurum kimliği
            //   hastaya verilen belgede zorunludur.
            var kurum = await baglanti.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad) as unvan, s.adres, s.ilce, s.il,
                       s.telefon, s.mersis_no as "mersisNo", s.vkno, s.vd
                  from public.sube s
                 where s.id = coalesce((select i.sube_id from public.lab_istem i
                                         where i.id = @p0),
                                       (select id from public.sube where varsayilan = 1 limit 1))
                """, null, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { istem, sonuclar, kulturler, izolatlar, antibiyogram,
                                    vakalar, varyantlar, kurum, izlemeNo = baglam.IzlemeNo });
        });
    }
}
