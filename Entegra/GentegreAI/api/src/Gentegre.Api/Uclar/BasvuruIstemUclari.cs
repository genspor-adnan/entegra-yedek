using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BAŞVURU → İSTEM BANKO KAPISI (912). Poliklinikte hekimin muayenede açtığı
/// lab/radyoloji isteği <c>serbest=0</c> ile başvuruya düşer; laboratuvar ve
/// radyoloji çalışma listesinde GÖRÜNMEZ. Banko tetkiği ücretlendirip
/// <b>serbest bırakınca</b> (serbest=1) istem worklist'e iner. Ödeme ayrı
/// aşamadır - serbest bırakmak "ücretlendirildi/kabule hazır" demektir, tahsilat
/// sonraya kalabilir. Acil/yatan/dış/banko kaynaklı istemler zaten serbest=1
/// gelir, burada listelenmez.
/// </summary>
public static class BasvuruIstemUclari
{
    public sealed record SerbestIstegi(int[]? LabIstemIdler, int[]? RadyolojiIstemIdler);

    public static void BasvuruIstemUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/basvuru").WithTags("Başvuru · Banko").RequireAuthorization();

        // BEKLEYEN İSTEMLER: banko ücretlendirme ekranı - hekimin açtığı ama
        //   henüz serbest bırakılmamış lab/radyoloji istekleri.
        //
        //   FİYAT ÖNİZLEMESİ (kullanıcı: "sağ tarafta hastanın kurumuna göre
        //   fiyatlar görünsün"): her istem için ücretlendirmede YAZILACAK
        //   fiyat - başvurunun fiyat listesi (kurum sözleşmesi) + kampanya +
        //   sözleşme iskontosu. Hesap ücretlendirme ucuyla AYNI yardımcıdan
        //   (FiyatBilgisiAsync) gelir; ekranın gösterdiği ile satıra yazılan
        //   ayrışmasın. Başvuruda zaten ücret satırı olan hizmet 0 sayılır
        //   (ücretlendirme onu tekrar eklemez).
        grup.MapGet("/{belgeId:int}/bekleyen-istem", async (
            int belgeId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            // PANEL TEK SATIR (kullanıcı: "TİT, hemogram ve diğer paneller tek
            //   satır görünmeli ve tek satır ücrete gelmeli"): panelden doğan
            //   istem satırları (TİT'in 21 parametresi) PANELİN adıyla bir kez
            //   yazılır ve PANELİN hizmetiyle fiyatlanır. Kural dış kurum
            //   başvurusundakiyle aynı: coalesce(panel.hizmet_id, tetkik.hizmet_id).
            var labHam = await b.ListeAsync("""
                select i.id, i.oncelik,
                       coalesce((select string_agg(x.ad, ', ' order by x.ad)
                                   from (select distinct coalesce(lp.ad, t.ad) as ad
                                           from public.lab_istem_satir s
                                           join public.lab_tetkik t on t.id = s.tetkik_id
                                           left join public.lab_panel lp on lp.id = s.panel_id
                                          where s.istem_id = i.id and s.durum <> 0) x), '') as tetkikler,
                       coalesce((select case t.bolum
                                     when 1 then 'Biyokimya' when 2 then 'Hematoloji'
                                     when 3 then 'Hormon' when 4 then 'Mikrobiyoloji'
                                     when 5 then 'Seroloji' when 6 then 'Koagülasyon'
                                     when 7 then 'İdrar' else 'Laboratuvar' end
                                   from public.lab_istem_satir s
                                   join public.lab_tetkik t on t.id = s.tetkik_id
                                  where s.istem_id = i.id and s.durum <> 0
                                  order by s.id limit 1), 'Laboratuvar') as kategori,
                       coalesce((select array_agg(distinct coalesce(lp.hizmet_id, t.hizmet_id))
                                   from public.lab_istem_satir s
                                   join public.lab_tetkik t on t.id = s.tetkik_id
                                   left join public.lab_panel lp on lp.id = s.panel_id
                                  where s.istem_id = i.id and s.durum <> 0
                                    and coalesce(lp.hizmet_id, t.hizmet_id) is not null), '{}'::int[]) as hizmetler
                  from public.lab_istem i
                 where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 9
                 order by i.id
                """, null, [belgeId],
                o => (Id: o.GetInt32(0), Oncelik: o.GetInt16(1), Tetkik: o.GetString(2),
                      Kategori: o.GetString(3), Hizmetler: (int[])o[4]), iptal);

            var radHam = await b.ListeAsync("""
                select i.id, i.oncelik, coalesce(hz.ad, '') as tetkik,
                       'Radyoloji · ' || case i.modalite when 1 then 'BT' when 2 then 'MR'
                            when 3 then 'USG' when 4 then 'Röntgen' when 5 then 'Mamografi'
                            when 6 then 'DEXA' when 7 then 'Anjiyo' when 8 then 'Skopi'
                            else 'Görüntüleme' end as kategori,
                       case when i.hizmet_id is null then '{}'::int[] else array[i.hizmet_id] end
                  from public.radyoloji_istem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 0
                 order by i.id
                """, null, [belgeId],
                o => (Id: o.GetInt32(0), Oncelik: o.GetInt16(1), Tetkik: o.GetString(2),
                      Kategori: o.GetString(3), Hizmetler: (int[])o[4]), iptal);

            var sz = await SozlesmeAsync(b, belgeId, iptal);
            // ÜCRETTE = ücret satırının hizmeti YA DA paket içeriği: check-up
            //   satırı girildiyse içindeki hemogram/glukoz istemi de ücrettedir.
            var ucrette = (await b.ListeAsync("""
                select distinct a.hizmet_id
                  from public.belge_satir bs
                 cross join lateral public.fn_hizmet_paket_kapsam(bs.hizmet_id) a
                 where bs.belge_id = @p0 and bs.hizmet_id is not null
                """, null, [belgeId], o => o.GetInt32(0), iptal)).ToHashSet();

            async Task<object> SatirAsync(string tur, (int Id, short Oncelik, string Tetkik,
                string Kategori, int[] Hizmetler) x, int iskonto)
            {
                decimal fiyat = 0, tutar = 0;
                foreach (var h in x.Hizmetler.Where(h => !ucrette.Contains(h)))
                {
                    var f = await FiyatBilgisiAsync(b, belgeId, sz, h, iptal);
                    fiyat += f;
                    tutar += Cekirdek.Katalog.BelgeHesap.SatirTutari(1m, f, iskonto);
                }
                return new
                {
                    tur, id = x.Id, oncelik = x.Oncelik, tetkik = x.Tetkik, kategori = x.Kategori,
                    fiyat, iskonto, tutar,
                    // Hizmeti yok: tetkiğin fiyatlanacak hizmet kartı tanımsız.
                    hizmetYok = x.Hizmetler.Length == 0,
                    // Hizmetlerin hepsi zaten başvuruda ücretli.
                    ucrette = x.Hizmetler.Length > 0 && x.Hizmetler.All(ucrette.Contains),
                };
            }

            var lab = new List<object>();
            foreach (var x in labHam) lab.Add(await SatirAsync("lab", x, sz.LabIskonto));
            var rad = new List<object>();
            foreach (var x in radHam) rad.Add(await SatirAsync("radyoloji", x, sz.RadIskonto));

            return Results.Ok(new { lab, radyoloji = rad,
                                    toplam = lab.Count + rad.Count,
                                    kurum = sz.Kurum, sozlesme = sz.Sozlesme,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // SERBEST BIRAK: banko ücretlendirdi → istemler worklist'e düşsün.
        //   Id verilmezse başvurunun TÜM bekleyen istemleri serbest bırakılır.
        grup.MapPost("/{belgeId:int}/istem-serbest", async (
            int belgeId, SerbestIstegi? istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);

            var labIds = istek?.LabIstemIdler;
            var radIds = istek?.RadyolojiIstemIdler;
            var hepsi = (labIds is null || labIds.Length == 0)
                      && (radIds is null || radIds.Length == 0);

            var labN = await b.CalistirAsync("""
                update public.lab_istem set serbest = 1, degistiren = @p1, degistirme_tarihi = now()
                 where belge_id = @p0 and serbest = 0
                   and (@p2::bool or id = any(@p3))
                """, null, [belgeId, baglam.KullaniciId, hepsi, labIds ?? []], iptal);

            var radN = await b.CalistirAsync("""
                update public.radyoloji_istem set serbest = 1, degistiren = @p1, degistirme_tarihi = now()
                 where belge_id = @p0 and serbest = 0
                   and (@p2::bool or id = any(@p3))
                """, null, [belgeId, baglam.KullaniciId, hepsi, radIds ?? []], iptal);

            return Results.Ok(new { lab = labN, radyoloji = radN, toplam = labN + radN,
                                    mesaj = labN + radN == 0
                                        ? "Serbest bırakılacak bekleyen istem yok."
                                        : $"{labN + radN} istem serbest bırakıldı, çalışma listelerine düştü.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // DOKTOR İSTEMİNİ ÜCRETLENDİR: başvurunun bekleyen (serbest=0) lab/
        //   radyoloji istemlerinin hizmetlerini ÜCRET satırı olarak başvuruya
        //   ekler (fiyat listesi + sözleşme iskontosu + karşılama). Banko
        //   "Doktor İstemi" düğmesinden çağırır. İstemler burada serbest
        //   BIRAKILMAZ - hasta vazgeçebilir; serbest bırakma başvuru KAYDINDA
        //   (fn_basvuru_istem_serbest_uygula) yapılır.
        grup.MapPost("/{belgeId:int}/istem-ucretlendir", async (
            int belgeId, SerbestIstegi? istek, VeriKaynagi veri, BelgeDeposu belgeDepo,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            // Seçili istem id'leri (grid'den); boşsa TÜM bekleyenler ücretlenir.
            var labIds = istek?.LabIstemIdler ?? [];
            var radIds = istek?.RadyolojiIstemIdler ?? [];
            var hepsi = labIds.Length == 0 && radIds.Length == 0;

            // Faturalanacak hizmetler: radyoloji istemin hizmeti; lab istemin
            //   tetkiklerinin hizmeti - PANELDEN doğan satırda PANELİN hizmeti
            //   (TİT/hemogram tek kalem, alt parametreleri ayrı ücret değil).
            //   Zaten başvuruda ücret satırı olan hizmet - ya da onu içeren paket
            //   (check-up) - atlanır (mükerrer kalem olmasın).
            var hizmetler = await b.ListeAsync("""
                select distinct hz.id, coalesce(hz.modalite, 0) as modalite
                  from (
                    select i.hizmet_id as hid from public.radyoloji_istem i
                     where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 0 and i.hizmet_id is not null
                       and (@p1::bool or i.id = any(@p3))
                    union
                    select coalesce(lp.hizmet_id, t.hizmet_id) from public.lab_istem i
                      join public.lab_istem_satir s on s.istem_id = i.id
                      join public.lab_tetkik t on t.id = s.tetkik_id
                      left join public.lab_panel lp on lp.id = s.panel_id
                     where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 9 and s.durum <> 0
                       and coalesce(lp.hizmet_id, t.hizmet_id) is not null
                       and (@p1::bool or i.id = any(@p2))
                  ) q
                  join public.hizmet hz on hz.id = q.hid
                 where not exists (select 1 from public.belge_satir bs
                                    cross join lateral public.fn_hizmet_paket_kapsam(bs.hizmet_id) a
                                    where bs.belge_id = @p0 and bs.hizmet_id is not null
                                      and a.hizmet_id = hz.id)
                """, null, [belgeId, hepsi, labIds, radIds], o => (Id: o.GetInt32(0), Modalite: o.GetInt32(1)), iptal);

            if (hizmetler.Count == 0)
                return Results.Ok(new { eklenen = 0, mesaj = "Ücretlendirilecek bekleyen doktor istemi yok.",
                                        izlemeNo = baglam.IzlemeNo });

            var sz = await SozlesmeAsync(b, belgeId, iptal);
            var (labIsk, radIsk, karsilama) = (sz.LabIskonto, sz.RadIskonto, sz.Karsilama);

            var (belge, satirlar) = await BelgeGovdesi.OkuAsync(b, belgeId, iptal);
            var sira = satirlar.Count;
            foreach (var h in hizmetler)
            {
                var fiyat = await FiyatBilgisiAsync(b, belgeId, sz, h.Id, iptal);
                var kdv = await b.TekDegerAsync<int>("select coalesce(kdv,0) from public.hizmet where id=@p0", null, [h.Id], iptal);
                var iskonto = h.Modalite > 0 ? radIsk : labIsk;
                satirlar.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>
                {
                    ["tur"] = 2, ["hizmetId"] = h.Id, ["miktar"] = 1m, ["birimFiyat"] = fiyat,
                    ["iskonto"] = (decimal)iskonto, ["iskontoKilit"] = iskonto > 0 ? 1 : 0,
                    ["pay"] = (int)karsilama, ["kdv"] = kdv, ["dovizCinsi"] = "TL", ["sira"] = ++sira,
                }));
            }
            await belgeDepo.GuncelleAsync(belgeId, belge, satirlar,
                new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);
            // Karşılama dağılımı (915) - kurum payı.
            await b.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(id) from public.belge_satir where belge_id=@p0 and hizmet_id is not null", null, [belgeId], iptal);
            // NOT: serbest bırakma BURADA YAPILMAZ (kullanici: "başvuru kaydedilip
            //   kapanınca istemler lab/radyolojide görünmeli"). Hasta pahalı
            //   tetkikten vazgeçip başvuruyu kaydetmeden kapatabilir; istem o
            //   ana kadar bekler. Serbest bırakma başvuru KAYDINDA (BelgeUclari
            //   POST/PUT → fn_basvuru_istem_serbest_uygula) yapılır.

            return Results.Ok(new { eklenen = hizmetler.Count,
                                    mesaj = $"{hizmetler.Count} doktor istemi ücretlendirildi; başvuru kaydedilince çalışma listesine düşer.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Başvurunun fiyatlama bağlamı: ödeyen kurum + sözleşme iskontoları +
    /// karşılama, hasta, kampanya. Sözleşme yoksa 0 (hasta öder, iskontosuz).
    /// </summary>
    private sealed record SozlesmeBilgisi(int HastaId, int? Kampanya, int LabIskonto,
        int RadIskonto, decimal Karsilama, string Kurum, string Sozlesme);

    private static async Task<SozlesmeBilgisi> SozlesmeAsync(Npgsql.NpgsqlConnection b, int belgeId,
                                                             CancellationToken iptal)
        => await b.TekAsync("""
            select bl.taraf_id, bl.kampanya_id,
                   coalesce(s.lab_iskonto, 0), coalesce(s.rad_iskonto, 0),
                   coalesce(s.varsayilan_karsilama, 0),
                   coalesce(nullif(k.unvan, ''), ''), coalesce(s.ad, '')
              from public.belge bl
              left join public.belge_basvuru bb on bb.id = bl.id
              left join public.kurum_sozlesme s on s.id = bb.sozlesme_id
              left join public.taraf k on k.id = bb.odeyen_kurum_id
             where bl.id = @p0
            """, null, [belgeId],
            o => new SozlesmeBilgisi(o.GetInt32(0), o.IsDBNull(1) ? null : o.GetInt32(1),
                    Convert.ToInt32(o.GetValue(2)), Convert.ToInt32(o.GetValue(3)),
                    Convert.ToDecimal(o.GetValue(4)), o.GetString(5), o.GetString(6)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

    /// <summary>
    /// TEK FİYAT KURALI (önizleme ve ücretlendirme aynı yerden): başvurunun
    /// fiyat listesi (kurum sözleşmesi) → yoksa hastanın kalem fiyatı →
    /// kampanya varsa kampanya fiyatı. İskonto burada DEĞİL - satırda
    /// uygulanır (BelgeHesap).
    /// </summary>
    private static async Task<decimal> FiyatBilgisiAsync(Npgsql.NpgsqlConnection b, int belgeId,
        SozlesmeBilgisi sz, int hizmetId, CancellationToken iptal)
    {
        var fiyat = await b.TekDegerAsync<decimal>("""
            select coalesce(
                (select fs.fiyat from public.fiyat_listesi_satir fs join public.belge bl on bl.id=@p2
                  where fs.liste_id=bl.fiyat_listesi_id and fs.hizmet_id=@p1 limit 1),
                (select f.fiyat from public.fn_belge_kalem_fiyati(@p0,2::smallint,null,@p1,current_date) f limit 1),
                0)
            """, null, [sz.HastaId, hizmetId, belgeId], iptal);
        if (sz.Kampanya is int kid && kid > 0 && fiyat > 0)
            fiyat = await b.TekDegerAsync<decimal>(
                "select coalesce(f.fiyat,@p3) from public.fn_kampanya_fiyat(@p0,null,@p1,@p2) f limit 1",
                null, [kid, hizmetId, fiyat, fiyat], iptal);
        return fiyat;
    }
}
