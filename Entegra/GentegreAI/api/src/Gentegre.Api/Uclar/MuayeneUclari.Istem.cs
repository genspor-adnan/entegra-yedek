using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENEDEN İSTEM — bkz. <c>MuayeneUclari</c>.
///
/// <para>Lab / radyoloji / göz istemi ve "sonucu gördüm" işareti. İstem muayeneye
/// yazılır, ücret başvuruya gider; başvurusuz istem yok (974). Tamamlanmış
/// muayeneye istem eklenmez.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void IstemUclariniEkle(RouteGroupBuilder grup)
    {
        // POST /api/muayene/{id}/istem - muayeneden istem aç
        //   Asıl kayıt MODÜL TABLOSUNDA açılır (radyoloji_istem); muayene_istem
        //   bağ ve durum satırıdır. Modülü atlayıp yalnız bağ satırı yazmak,
        //   radyolojinin çalışma listesinde görünmeyen bir istem üretirdi.
        grup.MapPost("/{id:int}/istem", async (
            int id, IstemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.LabServisi lab, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync("""
                select m.taraf_id, m.belge_id, m.personel_id, m.sube_id, m.durum,
                       coalesce((select t.icd_kod from public.tani t
                                  where t.muayene_id = m.id and t.tur = 1 limit 1), '')
                  from public.muayene m where m.id = @p0
                """, islem, [id], o => new
                {
                    HastaId = o.GetInt32(0),
                    BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    HekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    SubeId = o.GetInt32(3), Durum = o.GetInt16(4), OnTani = o.GetString(5),
                }, iptal);

            if (m is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Tamamlanmis muayeneye istem eklenemez.");

            string hedefTablo = "";
            int? hedefId = null;

            // GORUNTULEME: radyoloji istemi acilir. On tani ve klinik bilgi
            //   BIRLIKTE gider - radyolog "neden cekiyoruz" bilmeden rapor
            //   yazamaz.
            if (istek.Tur == 2)
            {
                if (istek.HizmetId is not > 0)
                    throw GentegreHatasi.Dogrulama("Goruntuleme istemi icin hizmet secilmeli.",
                        [new("hizmetId", "Tetkik (hizmet) secin.")]);

                // HIZMET RADYOLOJI TETKIKI OLMALI (459). Kart ekraninda tetkik
                //   listesi zaten radyolojiyle sinirli; ACIK KAPI BURASIYDI -
                //   muayeneden gonderilen hizmet id serbestti ve laboratuvar
                //   tetkiki ("17-KETOSTEROİD") radyoloji kuyruguna dusuyordu.
                //   Modalite = tetkikin cihaz ailesi; sifirsa istem hicbir
                //   cihaza gonderilemez (MWL "hangi cihaz" sorusunu cevapsiz
                //   birakir). Ayni kural DB tetiginde de var - bu kontrol
                //   kullaniciya ANLASILIR mesaj vermek icin.
                var modalite = await baglanti.TekDegerAsync<int>(
                    "select coalesce(modalite, 0) from public.hizmet where id = @p0",
                    islem, [istek.HizmetId], iptal);
                if (modalite <= 0)
                    throw GentegreHatasi.Dogrulama(
                        "Secilen tetkik radyoloji tetkiki degil (hizmet kartinda modalite yok).",
                        [new("hizmetId", "Radyoloji tetkiki secin ya da hizmet kartina "
                                         + "modalite girin.")]);

                // SERBEST (912): poliklinik başvurusunda muayene isteği banko
                //   ücretlendirmesi bekler (serbest=0) → çekim listesinde
                //   BANKO SERBEST BIRAKANA KADAR görünmez. Acil/yatan başvuru,
                //   acil öncelik ve kapı-kapalı kurum bypass eder (fn 1 döner).
                hedefId = await baglanti.TekDegerAsync<int>("""
                    insert into public.radyoloji_istem
                           (sube_id, belge_id, hasta_id, hizmet_id, modalite, durum, oncelik,
                            istek_hekim_id, on_tani, klinik_bilgi, aciklama, serbest, accession_no)
                    values (@p0, @p1, @p2, @p3, @p9, 1, @p4, @p5, @p6, @p7, @p7,
                            public.fn_istem_serbest(
                                (select basvuru_turu from public.belge_basvuru where id = @p1)::smallint,
                                @p4::smallint, 1::smallint),
                            public.fn_numara_kimlik_uret(903, @p0, 'radyoloji_istem',
                                                         'accession_no', current_date))
                    returning id
                    """, islem,
                    [m.SubeId, m.BelgeId, m.HastaId, istek.HizmetId,
                     (short)(istek.Aciliyet ?? 1), m.HekimId, m.OnTani,
                     istek.Aciklama ?? "", istek.Aciklama ?? "", (short)modalite], iptal);
                hedefTablo = "radyoloji_istem";
            }

            // LABORATUVAR (433): asil kayit lab_istem'de acilir; tup plani ve
            //   barkodlar orada uretilir. Muayeneden istenen tetkigin numune
            //   plani olmadan acilmasi, kan alma biriminde "hangi tup" sorusunu
            //   cevapsiz birakirdi.
            // GÖZ GÖRÜNTÜLEME (974): lab / radyolojiyle AYNI akış - başvuruya bekleyen
            //   istem (serbest=0), banko ücret + başvuru kaydı serbest bırakır, teknisyen
            //   ancak ondan sonra çeker. Ücret hizmeti goz_tetkik_hizmet'ten.
            if (istek.Tur == 6)
            {
                if (m.BelgeId is not > 0)
                    throw GentegreHatasi.IsKurali("Göz görüntüleme istemi için muayenenin başvurusu olmalı.");
                if (istek.GozTetkik is not (>= 1 and <= 15))
                    throw GentegreHatasi.Dogrulama("Göz tetkiki seçilmeli.", [new("gozTetkik", "Tetkik seçin.")]);
                var gozHizmet = await baglanti.TekDegerAsync<int?>(
                    "select hizmet_id from public.goz_tetkik_hizmet where tetkik = @p0", islem, [istek.GozTetkik.Value], iptal)
                    ?? throw GentegreHatasi.IsKurali("Bu tetkik için ücret hizmeti tanımlı değil (göz tetkik - hizmet eşlemesi).");
                hedefId = await baglanti.TekDegerAsync<int>("""
                    insert into public.goz_goruntuleme
                        (sube_id, muayene_id, hasta_id, goz, tetkik, hizmet_id, belge_id, serbest, oncelik,
                         istek_hekim_id, klinik_soru, istem_zamani, durum, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6,
                            public.fn_istem_serbest((select basvuru_turu from public.belge_basvuru where id = @p6)::smallint,
                                                    @p7::smallint, 1::smallint),
                            @p7, @p8, @p9, now(), 1, @p10)
                    returning id
                    """, islem,
                    [m.SubeId, id, m.HastaId, (short)(istek.Goz is (>= 1 and <= 3) ? istek.Goz.Value : 3),
                     (short)istek.GozTetkik.Value, gozHizmet, m.BelgeId, (short)(istek.Aciliyet ?? 1), m.HekimId,
                     (istek.Aciklama ?? "").Trim(), baglam.KullaniciId], iptal);
                hedefTablo = "goz_goruntuleme";
            }

            if (istek.Tur == 1)
            {
                if (m.BelgeId is not > 0)
                    throw GentegreHatasi.IsKurali(
                        "Laboratuvar istemi icin muayenenin basvurusu olmali.");

                var satirlar = new List<Servisler.LabServisi.IstemSatiriIstegi>();
                foreach (var t in istek.TetkikIdler ?? [])
                    satirlar.Add(new(t, null));
                foreach (var p in istek.PanelIdler ?? [])
                    satirlar.Add(new(null, p));
                if (satirlar.Count == 0)
                    throw GentegreHatasi.Dogrulama("Laboratuvar istemi icin tetkik secilmeli.",
                        [new("tetkikIdler", "En az bir tetkik ya da panel secin.")]);

                // Lab istemi KENDI islemini acar; bag satiri onun ardindan
                //   yazilir - lab istemi acilamazsa bag satiri da olusmaz.
                await islem.CommitAsync(iptal);
                hedefId = await lab.IstemAcAsync(m.BelgeId.Value, satirlar,
                    (short)(istek.Aciliyet ?? 1), istek.Aciklama ?? "", m.OnTani,
                    baglam, iptal, akilci: istek.Akilci);
                hedefTablo = "lab_istem";

                var bagId = await veri.TekDegerAsync<int>("""
                    insert into public.muayene_istem
                           (muayene_id, tur, hedef_tablo, hedef_id, aciliyet,
                            sonuc_durum, ekleyen)
                    values (@p0, 1, 'lab_istem', @p1, @p2, 0, @p3)
                    returning id
                    """,
                    [id, hedefId, (short)(istek.Aciliyet ?? 0), baglam.KullaniciId], iptal);

                return Results.Ok(new { istemId = bagId, hedefTablo, hedefId,
                                        mesaj = "Laboratuvar istemi acildi, barkodlar uretildi.",
                                        izlemeNo = baglam.IzlemeNo });
            }

            var istemId = await baglanti.TekDegerAsync<int>("""
                insert into public.muayene_istem
                       (muayene_id, tur, hedef_tablo, hedef_id, aciliyet, sonuc_durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 0, @p5)
                returning id
                """, islem,
                [id, (short)istek.Tur, hedefTablo, hedefId, (short)(istek.Aciliyet ?? 0),
                 baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // Muayene durumu (sonuc bekliyor) TETIKLE yansiyor (418): modul
            //   kodlarina "muayene_istem'i de guncelle" satiri eklemek, birini
            //   unutunca sessizce bozulan bir bag birakirdi.
            return Results.Ok(new { istemId, hedefTablo, hedefId,
                                    mesaj = hedefTablo.Length > 0
                                        ? "Istem acildi ve modul calisma listesine dustu."
                                        : "Istem kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/istem/{id}/gordu - hekim sonucu gördü
        //   Panik değer teyidi ve "sonuç bekliyor" rozetinin kapanması bunun
        //   üzerinden yürür: sonucun gelmesi ile hekimin görmesi ayrı olaylar.
        grup.MapPost("/istem/{id:int}/gordu", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            var zaman = await veri.TekDegerAsync<DateTime?>("""
                update public.muayene_istem
                   set hekim_gordu = coalesce(hekim_gordu, now()),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning hekim_gordu
                """, [id, baglam.KullaniciId], iptal);

            if (zaman is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Istem bulunamadi." } });

            return Results.Ok(new { id, hekimGordu = zaman, izlemeNo = baglam.IzlemeNo });
        });
    }
}
