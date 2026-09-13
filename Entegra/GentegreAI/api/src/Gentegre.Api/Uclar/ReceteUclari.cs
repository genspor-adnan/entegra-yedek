using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// e-REÇETE (413, Faz 1) — muayeneden reçete yazma.
///
/// <para><b>Kontrol yazma anında yapılır, imza anında değil.</b> Alerji uyarısı
/// ilaç eklenirken döner: hekim daha ilacı seçerken görsün, on ilaç yazıp
/// imzaya basınca değil. Uyarı ENGEL DEĞİLDİR - hekim gerekçesiyle geçebilir,
/// ama geçtiği uyarı satırda saklanır: sonradan "neyi görüp geçti" sorusunun
/// cevabı olmalı.</para>
///
/// <para><b>İmza reçeteyi kilitler</b> ve aktif ilaç listesine işler. Aktif
/// ilaç listesi reçete satırlarının kopyası değildir: hasta başka kurumdan
/// aldığını da kullanır, bizim yazdığımızın bir kısmını kullanmaz - etkileşim
/// kontrolü kullanılana bakmalı.</para>
///
/// <para>MEDULA KAPISI AÇIK DEĞİL: reçete yerel yazılır ve imzalanır, gönderim
/// kuyruğa girer (durum 2). Kapıyı beklemek muayene modülünü reçetesiz
/// bırakırdı.</para>
/// </summary>
public static class ReceteUclari
{
    /// <summary>Reçeteye eklenecek ilaç. Ad ve etken madde katalogdan alınır.</summary>
    public sealed record IlacIstegi(string Barkod, string? Doz, string? Periyot,
                                    int? SureGun, int? Kutu, string? Aciklama,
                                    string? UyariGerekce);

    public static void ReceteUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/recete").WithTags("Reçete").RequireAuthorization();

        // GET /api/recete/kontrol?hastaId=&barkod= - alerji + tekrar kontrolü
        //   İlaç seçilirken çağrılır; yazmadan önce uyarı görünsün.
        grup.MapGet("/kontrol", async (
            int hastaId, string barkod, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            var uyarilar = await UyarilariTopla(veri, hastaId, barkod, iptal);
            return Results.Ok(new { hastaId, barkod, uyarilar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/recete/muayene/{muayeneId} - reçete aç (yoksa) ve ilaç ekle
        grup.MapPost("/muayene/{muayeneId:int}", async (
            int muayeneId, IlacIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            var barkod = new string((istek.Barkod ?? "").Where(char.IsDigit).ToArray());
            if (barkod.Length is < 8 or > 20)
                throw GentegreHatasi.Dogrulama("Ilac barkodu gecersiz.",
                    [new("barkod", "8-20 haneli barkod girin.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync("""
                select m.taraf_id, m.personel_id, m.sube_id, m.durum
                  from public.muayene m where m.id = @p0
                """, islem, [muayeneId], o => new
                {
                    HastaId = o.GetInt32(0),
                    HekimId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    SubeId = o.GetInt32(2), Durum = o.GetInt16(3),
                }, iptal);
            if (m is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Tamamlanmis muayeneye recete yazilamaz.");

            var ilac = await baglanti.TekAsync("""
                select i.ad, i.etken_madde, i.recete_turu
                  from public.ilac i where i.barkod = @p0
                """, islem, [barkod],
                o => new { Ad = o.GetString(0), Etken = o.GetString(1), Tur = o.GetInt16(2) },
                iptal);
            if (ilac is null)
                throw GentegreHatasi.Dogrulama("Ilac katalogda bulunamadi.",
                    [new("barkod", "Barkod ilac kataloguyla eslesmiyor.")]);

            // RECETE TURU EN YUKSEK SATIRDAN gelir: kirmizi bir ilac eklenince
            //   recete kirmizi olur. Normal kalmasi, kontrollu ilaci normal
            //   receteye yazmak demekti.
            var receteId = await baglanti.TekDegerAsync<int?>("""
                select r.id from public.recete r
                 where r.muayene_id = @p0 and r.durum = 1
                 order by r.id desc limit 1
                """, islem, [muayeneId], iptal);

            // RECETE NO AYARDAN (635): `numara_sablonu` tur 905 satiri varsa
            //   numara verilir, yoksa BOS kalir - bugunku davranis. MEDULA
            //   recete numarasi AYRI: o disaridan gelir, bu kurumun kendi
            //   takip numarasi.
            receteId ??= await baglanti.TekDegerAsync<int>("""
                insert into public.recete (muayene_id, hasta_id, hekim_id, tur, durum,
                                           sube_id, ekleyen, recete_no)
                values (@p0, @p1, @p2, 0, 1, @p3, @p4,
                        public.fn_numara_kimlik_uret(905, @p3, 'recete', 'recete_no',
                                                     current_date))
                returning id
                """, islem, [muayeneId, m.HastaId, m.HekimId, m.SubeId, baglam.KullaniciId],
                iptal);

            var uyarilar = await UyarilariTopla(veri, m.HastaId, barkod, iptal);
            var uyariMetni = string.Join(" · ", uyarilar);

            var satirId = await baglanti.TekDegerAsync<int>("""
                insert into public.recete_satir (recete_id, ilac_barkod, ilac_ad, doz, periyot,
                                                 sure_gun, kutu, aciklama, etkilesim_uyari,
                                                 sira, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8,
                        coalesce((select max(s.sira) + 1 from public.recete_satir s
                                   where s.recete_id = @p0), 1), @p9)
                returning id
                """, islem,
                [receteId, barkod, ilac.Ad, istek.Doz ?? "", istek.Periyot ?? "",
                 (short)(istek.SureGun ?? 0), (short)(istek.Kutu ?? 1), istek.Aciklama ?? "",
                 uyariMetni.Length > 200 ? uyariMetni[..200] : uyariMetni,
                 baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.recete r
                   set tur = greatest(r.tur, @p1), degistiren = @p2, degistirme_tarihi = now()
                 where r.id = @p0
                """, islem, [receteId, ilac.Tur, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { receteId, satirId, barkod, ilac.Ad, uyarilar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // DELETE /api/recete/{id}/ilac/{satirId} - imzalanmamış reçeteden ilaç çıkar
        //   İMZALI REÇETEYE DOKUNULMAZ: imza reçeteyi kilitler; yanlış ilaç
        //   varsa reçete iptal edilip yenisi yazılır - imzalanan kâğıdın
        //   içeriğini sonradan değiştirmek izi bozar.
        grup.MapDelete("/{id:int}/ilac/{satirId:int}", async (
            int id, int satirId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var durum = await baglanti.TekDegerAsync<int>(
                "select durum from public.recete where id = @p0", null, [id], iptal);
            if (durum != 1)
                throw GentegreHatasi.IsKurali(
                    "Imzalanmis ya da iptal edilmis receteden ilac cikarilamaz.");

            var silinen = await baglanti.CalistirAsync(
                "delete from public.recete_satir where id = @p0 and recete_id = @p1",
                null, [satirId, id], iptal);
            if (silinen == 0) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Ilac satiri bulunamadi." } });

            return Results.Ok(new { id, satirId, mesaj = "Ilac cikarildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/recete/muayene/{muayeneId}/kopyala - önceki reçeteyi kopyala
        //   Kronik hastada her muayenede aynı ilaçlar yeniden yazılıyor;
        //   elle yazmak hem uzun hem de doz/periyot hatasının kapısı.
        //   HASTANIN SON İMZALI reçetesi kopyalanır; zaten yazılmış barkodlar
        //   atlanır (ikinci kez eklenmesi çift doz demek olurdu).
        grup.MapPost("/muayene/{muayeneId:int}/kopyala", async (
            int muayeneId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync(
                "select m.taraf_id, m.personel_id, m.sube_id from public.muayene m " +
                " where m.id = @p0", islem, [muayeneId],
                o => new { HastaId = o.GetInt32(0),
                           HekimId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           SubeId = o.GetInt32(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadi.");

            var kaynakId = await baglanti.TekDegerAsync<int>(
                "select coalesce((select r.id from public.recete r " +
                "                  where r.hasta_id = @p0 and r.muayene_id <> @p1 " +
                "                    and r.durum >= 2 " +
                "                  order by r.imza_zamani desc nulls last, r.id desc " +
                "                  limit 1), 0)", islem, [m.HastaId, muayeneId], iptal);
            if (kaynakId == 0)
                throw GentegreHatasi.IsKurali("Bu hastanin kopyalanacak imzali recetesi yok.");

            var hedefId = await baglanti.TekDegerAsync<int>(
                "select coalesce((select r.id from public.recete r " +
                "                  where r.muayene_id = @p0 and r.durum = 1 " +
                "                  order by r.id desc limit 1), 0)",
                islem, [muayeneId], iptal);
            if (hedefId == 0)
                hedefId = await baglanti.TekDegerAsync<int>(
                    "insert into public.recete (muayene_id, hasta_id, hekim_id, " +
                    "                           sube_id, ekleyen, recete_no) " +
                    // 635: numara sablondan; sablon yoksa bos kalir.
                    "values (@p0, @p1, @p2, @p3, @p4, " +
                    "        public.fn_numara_kimlik_uret(905, @p3, 'recete', " +
                    "                                     'recete_no', current_date)) " +
                    "returning id",
                    islem, [muayeneId, m.HastaId, m.HekimId, m.SubeId,
                            baglam.KullaniciId], iptal);

            var eklenen = await baglanti.CalistirAsync(
                "insert into public.recete_satir (recete_id, ilac_barkod, ilac_ad, doz, " +
                "        periyot, kullanim_sekli, sure_gun, kutu, aciklama, sira, ekleyen) " +
                "select @p1, s.ilac_barkod, s.ilac_ad, s.doz, s.periyot, s.kullanim_sekli, " +
                "       s.sure_gun, s.kutu, s.aciklama, s.sira, @p2 " +
                "  from public.recete_satir s " +
                " where s.recete_id = @p0 " +
                "   and not exists (select 1 from public.recete_satir v " +
                "                    where v.recete_id = @p1 " +
                "                      and v.ilac_barkod = s.ilac_barkod)",
                islem, [kaynakId, hedefId, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { receteId = hedefId, kaynakReceteId = kaynakId, eklenen,
                                    mesaj = eklenen == 0
                                        ? "Onceki recetedeki ilaclar zaten listede."
                                        : $"{eklenen} ilac onceki receteden kopyalandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/recete/{id}/imzala
        //   İmza reçeteyi KİLİTLER ve aktif ilaç listesine işler. Medula
        //   kapısı açılınca gönderim buradan tetiklenecek; şimdilik durum 2.
        grup.MapPost("/{id:int}/imzala", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var r = await baglanti.TekAsync("""
                select r.durum, r.hasta_id,
                       (select count(*) from public.recete_satir s where s.recete_id = r.id)
                  from public.recete r where r.id = @p0 for update
                """, islem, [id],
                o => new { Durum = o.GetInt16(0), HastaId = o.GetInt32(1),
                           Satir = o.GetInt64(2) }, iptal);

            if (r is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Recete bulunamadi." } });
            if (r.Durum != 1)
                throw GentegreHatasi.IsKurali("Recete zaten imzalanmis ya da iptal.");
            if (r.Satir == 0)
                throw GentegreHatasi.Dogrulama("Bos recete imzalanamaz.",
                    [new("ilaclar", "En az bir ilac ekleyin.")]);

            await baglanti.CalistirAsync("""
                update public.recete
                   set durum = 2, imza_zamani = now(),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            // AKTIF ILAC LISTESINE ISLE: ayni barkod zaten aktifse yeniden
            //   eklenmez - liste "su an ne kullaniyor" sorusunun cevabi,
            //   recete tarihcesi degil.
            var eklenen = await baglanti.CalistirAsync("""
                insert into public.hasta_ilac (hasta_id, ilac_barkod, ilac_ad, etken_madde,
                                               doz, periyot, baslangic, recete_satir_id,
                                               kaynak, ekleyen)
                select @p1, s.ilac_barkod, s.ilac_ad, coalesce(i.etken_madde, ''),
                       s.doz, s.periyot, current_date, s.id, 1, @p2
                  from public.recete_satir s
                  left join public.ilac i on i.barkod = s.ilac_barkod
                 where s.recete_id = @p0
                   and not exists (select 1 from public.hasta_ilac h
                                    where h.hasta_id = @p1 and h.aktif = 1
                                      and h.ilac_barkod = s.ilac_barkod)
                """, islem, [id, r.HastaId, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, aktifIlacaEklenen = eklenen,
                                    mesaj = "Recete imzalandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// İlaç için hasta bazlı uyarıları toplar.
    ///
    /// İki kaynak: hastanın ALERJİLERİ (etken madde bazlı, db/413'teki
    /// fonksiyon) ve AKTİF İLAÇ listesindeki tekrar (aynı etken maddeyi ikinci
    /// kez yazmak, hastanın iki markadan çift doz alması demektir).
    ///
    /// Yanlış pozitif yanlış negatife yeğdir: hekim uyarıyı okuyup geçebilir,
    /// kaçırılmış alerjiyi geri alamaz.
    /// </summary>
    private static async Task<List<string>> UyarilariTopla(VeriKaynagi veri, int hastaId,
        string barkod, CancellationToken iptal)
    {
        var uyarilar = await veri.ListeAsync("""
            select 'ALERJİ: ' || a.etken
                 || case a.siddet when 4 then ' (anafilaksi)' when 3 then ' (şiddetli)'
                                  when 2 then ' (orta)' else '' end
                 || case when a.reaksiyon <> '' then ' - ' || a.reaksiyon else '' end
              from public.fn_ilac_alerji_kontrol(@p0, @p1) a
            """, [hastaId, barkod], o => o.GetString(0), iptal);

        var tekrar = await veri.ListeAsync("""
            select 'TEKRAR: ' || h.ilac_ad || ' aynı etken maddeyi taşıyor ('
                 || h.etken_madde || ')'
              from public.hasta_ilac h
              join public.ilac i on i.barkod = @p1
             where h.hasta_id = @p0 and h.aktif = 1
               and h.etken_madde <> '' and i.etken_madde <> ''
               and h.ilac_barkod <> @p1
               and lower(h.etken_madde) = lower(i.etken_madde)
            """, [hastaId, barkod], o => o.GetString(0), iptal);

        uyarilar.AddRange(tekrar);
        return uyarilar;
    }
}
