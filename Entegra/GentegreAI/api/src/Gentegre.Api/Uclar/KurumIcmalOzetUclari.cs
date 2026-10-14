using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KURUM İCMALİ EKRANI (mockup Ekranlar/İcmal/kurum_icmal.html,
/// kullanıcı 10.10.2026: "kurum icmal ekranını kodla").
///
/// Ödeyen kurumların (ÖSS / SGK / kurumu öder - taraf_kurum.tur 2..4; tür 1
/// "Özel (Ücretli)" hastanın kendisidir, kurum değildir) bir dönemdeki
/// başvuruları TEK yanıtta. Kurum seçilmezse bütün kurumlar; birden çok kurum seçilebilir.
///
/// Hesap kuralları hasta icmaliyle (HastaIcmalUclari) AYNI:
///   toplam = belge.genel_toplam, kurum = satır dağılımındaki SGK + ÖSS payı,
///   hasta  = toplam - kurum. İptal başvuru (durum 6) girmez.
/// Kesinti SGK'da Medula kesintisinden (medula_kesinti, kabul edilen itirazın
/// iadesi düşülmüş) gelir; kurumdan
/// istenen = kurum payı - kesinti. Dönem icmali / faturası 289'un tablosundan
/// (kurum_icmal); oluşturma ve faturalama 289'un uçlarıyla yapılır, bu uç
/// yalnız OKUR.
/// </summary>
public static class KurumIcmalOzetUclari
{
    public static void KurumIcmalOzetUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-icmal").WithTags("Kurum İcmali").RequireAuthorization();

        grup.MapGet("/ozet", async (string? kurumlar, DateTime? bas, DateTime? bit,
                                    VeriKaynagi veri, BaglamCozucu cozucu,
                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Kurum İcmalleri listesiyle aynı veri kapısı (kurum.icmal_ozet AyniGrup
            //   ile "kurum"u açar, 1015).
            baglam.YetkiIste("kurum", Islem.Gor);
            // Varsayılan dönem: geçen ay (kurum faturası ay kapanınca kesilir).
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            var bitis = sonGun.AddDays(1);
            // SEÇİLİ KURUMLAR (kullanıcı: "Dönemdeki Kurumlar'ın soluna check"):
            //   virgüllü id listesi; boşsa bütün kurumlar. Tek kurum seçiliyse
            //   cari, açık kurum payı ve icmal / fatura işlemleri açılır.
            var secili = (kurumlar ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => int.TryParse(x, out var n) ? n : 0).Where(n => n > 0).Distinct().ToArray();
            var kurum = secili.Length == 1 ? secili[0] : 0;
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            // Dönemdeki kurum başvuruları - kurumlar özeti ve başvuru listesi
            //   aynı kümeden beslenir (@p0 boş dizi ise bütün kurumlar).
            const string Basvurular = """
                with bsv as (
                    select be.id, be.belge_no, be.belge_tarihi, be.genel_toplam, be.taraf_id,
                           bb.hasta_id, bb.bolum_id, bb.odeyen_kurum_id, k.tur
                      from public.belge be
                      join public.belge_basvuru bb on bb.id = be.id
                      join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
                     -- tur 19 = BAŞVURU; tipi 30 hasta (16) / kurum (17) tahakkukunu
                     --   da taşır - onlar başvurudan türetilir, sayılırsa çift sayım.
                     where be.tipi = 30 and be.tur = 19 and be.durum <> 6 and k.tur in (2, 3, 4)
                       and (cardinality(@p0::int[]) = 0 or bb.odeyen_kurum_id = any(@p0::int[]))
                       and be.belge_tarihi >= @p1 and be.belge_tarihi < @p2
                       and (@p3 = 0 or coalesce(be.sube_id, 0) in (0, @p3)))
                """;

            var basvurular = await b.ListeAsync(Basvurular + """
                select s.id, s.belge_no, s.belge_tarihi, s.genel_toplam,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       coalesce(d.ad, ''), s.odeyen_kurum_id,
                       coalesce(public.fn_taraf_ad(ok.unvan, ok.ad, ok.soyad)::varchar(120), ''),
                       coalesce(p.kurum, 0), coalesce(p.kalem, 0), coalesce(kz.tutar, 0),
                       coalesce(case s.tur when 2 then bp.oss_durum when 3 then bp.sgk_durum end, -1)::int,
                       exists (select 1 from public.kurum_icmal_satir ks
                                 join public.belge_satir st on st.id = ks.belge_satir_id
                                where st.belge_id = s.id),
                       coalesce(case s.tur
                                  when 2 then nullif(concat_ws(' / ', nullif(bp.oss_police_no, ''),
                                                               nullif(bp.oss_provizyon_no, '')), '')
                                  when 3 then coalesce(nullif(bp.sgk_provizyon_no, ''), nullif(bp.sgk_takip_no, ''))
                                end, ''),
                       coalesce(s.hasta_id, s.taraf_id)
                  from bsv s
                  left join public.taraf h on h.id = coalesce(s.hasta_id, s.taraf_id)
                  left join public.departman d on d.id = s.bolum_id
                  left join public.taraf ok on ok.id = s.odeyen_kurum_id
                  left join public.belge_provizyon bp on bp.id = s.id
                  left join lateral (
                      select sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0)) as kurum, count(*) as kalem
                        from public.belge_satir st
                        left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                       where st.belge_id = s.id) p on true
                  left join lateral (
                      select sum(mk.tutar - coalesce(mk.iade_tutar, 0)) as tutar
                        from public.medula_kesinti mk
                        join public.medula_fatura mf on mf.id = mk.medula_fatura_id
                       where mf.belge_id = s.id) kz on true
                 order by s.belge_tarihi, s.id
                """, null, [secili, baslangic, bitis, sube], o =>
            {
                var toplam = o.GetDecimal(3);
                var kurumPayi = Math.Min(o.GetDecimal(8), toplam);
                var kesinti = Math.Min(o.GetDecimal(10), kurumPayi);
                return new
                {
                    id = o.GetInt32(0), protokolNo = o.GetString(1),
                    tarih = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                    toplam, hasta = o.GetString(4), bolum = o.GetString(5),
                    kurumId = o.GetInt32(6), kurum = o.GetString(7),
                    kurumPayi, kalem = o.GetInt64(9),
                    hastaPayi = toplam - kurumPayi, kesinti, net = kurumPayi - kesinti,
                    // -1: kurumun provizyonu yok (kurumu öder); 0 alınmadı,
                    //   1 onay, 2 red, 3 kısmi, 4 iptal (kod listesi provizyon.durum).
                    provizyon = o.GetInt32(11),
                    icmalde = o.GetBoolean(12),
                    // ÖSS: poliçe / provizyon; SGK: provizyon (yoksa takip) no.
                    provizyonNo = o.GetString(13),
                    hastaId = o.IsDBNull(14) ? (int?)null : o.GetInt32(14),
                };
            }, iptal);

            // KURUMLAR: dönemde başvurusu olan her kurum (kurum seçili olsa da
            //   bütün liste - sekme kurum değiştirmek için de kullanılır).
            var kurumOzetleri = await b.ListeAsync(Basvurular.Replace("(cardinality(@p0::int[]) = 0 or bb.odeyen_kurum_id = any(@p0::int[]))", "cardinality(@p0::int[]) >= 0") + """
                , satir as (
                    select s.odeyen_kurum_id as kid, s.genel_toplam,
                           least(coalesce((select sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0))
                                             from public.belge_satir st
                                             join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                                            where st.belge_id = s.id), 0), s.genel_toplam) as kurum,
                           coalesce((select sum(mk.tutar - coalesce(mk.iade_tutar, 0)) from public.medula_kesinti mk
                                       join public.medula_fatura mf on mf.id = mk.medula_fatura_id
                                      where mf.belge_id = s.id), 0) as kesinti
                      from bsv s)
                select x.kid, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       k.tur,
                       coalesce((select kd.ad from public.kod_deger kd
                                   join public.kod_liste kl on kl.id = kd.liste_id
                                  where kl.kod = 'taraf.kurum_turu' and kd.deger = k.tur), ''),
                       count(*), sum(x.genel_toplam), sum(x.kurum), sum(least(x.kesinti, x.kurum)),
                       coalesce((select i.durum from public.kurum_icmal i
                                  where i.kurum_id = x.kid and i.durum > 0
                                    and i.donem_bas < @p2 and i.donem_bit >= @p1
                                  order by i.id desc limit 1), 0)::int
                  from satir x
                  join public.taraf t on t.id = x.kid
                  join public.taraf_kurum k on k.id = x.kid
                 group by x.kid, t.unvan, t.ad, t.soyad, k.tur
                 order by sum(x.kurum) desc
                """, null, [Array.Empty<int>(), baslangic, bitis, sube], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), tur = o.GetInt16(2), turAdi = o.GetString(3),
                basvuru = o.GetInt64(4), toplam = o.GetDecimal(5), kurumPayi = o.GetDecimal(6),
                kesinti = o.GetDecimal(7), net = o.GetDecimal(6) - o.GetDecimal(7),
                // 0 açık (icmal yok), 1 icmal hazırlandı, 2 faturalandı.
                icmalDurum = o.GetInt32(8),
            }, iptal);

            var idler = basvurular.Select(x => x.id).ToArray();

            var hizmetGruplari = await b.ListeAsync("""
                select coalesce(kt.ad, 'Diğer'), count(*), sum(st.tutar),
                       sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0))
                  from public.belge_satir st
                  left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                  left join public.hizmet h on h.id = st.hizmet_id
                  left join public.kategori kt on kt.id = h.kategori
                 where st.belge_id = any(@p0)
                 group by 1
                 order by 4 desc
                """, null, [idler], o => new
            {
                grup = o.GetString(0), kalem = o.GetInt64(1), toplam = o.GetDecimal(2),
                kurumPayi = o.GetDecimal(3), hastaPayi = o.GetDecimal(2) - o.GetDecimal(3),
            }, iptal);

            var kesintiler = await b.ListeAsync("""
                select mk.id, be.belge_no,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       coalesce(mk.sut_kodu, ''), coalesce(mk.kesinti_kodu, ''), coalesce(mk.aciklama, ''),
                       mk.tutar, coalesce(mk.itiraz_durum, 0), coalesce(mk.iade_tutar, 0)
                  from public.medula_kesinti mk
                  join public.medula_fatura mf on mf.id = mk.medula_fatura_id
                  join public.belge be on be.id = mf.belge_id
                  join public.belge_basvuru bb on bb.id = be.id
                  left join public.taraf h on h.id = coalesce(bb.hasta_id, be.taraf_id)
                 where mf.belge_id = any(@p0)
                 order by be.belge_tarihi, mk.id
                """, null, [idler], o => new
            {
                id = o.GetInt32(0), protokolNo = o.GetString(1), hasta = o.GetString(2),
                sutKodu = o.GetString(3), kod = o.GetString(4), aciklama = o.GetString(5),
                tutar = o.GetDecimal(6), itirazDurum = o.GetInt16(7), iade = o.GetDecimal(8),
            }, iptal);

            // DÖNEM İCMALLERİ (289): seçili kurumun (ya da hepsinin) bu dönemle
            //   kesişen icmalleri - adım çubuğu ve "Faturala" düğmesi buradan.
            var icmaller = await b.ListeAsync("""
                select i.id, i.kurum_id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       i.donem_bas, i.donem_bit, i.durum, coalesce(i.toplam, 0),
                       i.belge_id, coalesce(f.belge_no, ''), f.belge_tarihi, coalesce(f.genel_toplam, 0),
                       coalesce((select sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end)
                                   from public.kasa_islem ki
                                   join public.kasa_islem_turu kt on kt.kod = ki.tur
                                  where ki.belge_id = i.belge_id and ki.durum <> 9
                                    and kt.grup in ('tahsilat', 'ceksenet', 'kupon')), 0)
                  from public.kurum_icmal i
                  left join public.taraf t on t.id = i.kurum_id
                  left join public.belge f on f.id = i.belge_id
                 where i.durum > 0 and (cardinality(@p0::int[]) = 0 or i.kurum_id = any(@p0::int[]))
                   and i.donem_bas < @p2 and i.donem_bit >= @p1
                   and (@p3 = 0 or coalesce(i.sube_id, 0) in (0, @p3))
                 order by i.donem_bas, i.id
                """, null, [secili, baslangic, bitis, sube], o => new
            {
                id = o.GetInt32(0), kurumId = o.GetInt32(1), kurum = o.GetString(2),
                donemBas = o.GetDateTime(3), donemBit = o.GetDateTime(4), durum = o.GetInt16(5),
                toplam = o.GetDecimal(6), belgeId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                faturaNo = o.GetString(8), faturaTarihi = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                faturaTutari = o.GetDecimal(10), tahsil = o.GetDecimal(11),
            }, iptal);

            // KURUM CARİSİ: yalnız tek kurum seçiliyken - kurumun genel bakiyesi
            //   ve dönemdeki hareketleri (fatura, tahsilat, devreden).
            object? cari = null;
            if (kurum > 0)
            {
                var devreden = await b.TekDegerAsync<decimal?>("""
                    select coalesce(sum(e.yerel_borc - e.yerel_alacak), 0) from public.v_cari_ekstre e
                     where e.taraf_id = @p0 and e.bakiye_dahil = 1 and e.islem_tarihi < @p1
                    """, null, [kurum, baslangic], iptal) ?? 0m;
                var hareketler = await b.ListeAsync("""
                    select e.islem_tarihi, coalesce(nullif(e.belge_no, ''), e.islem_no, ''),
                           coalesce(e.tur_adi, ''), coalesce(e.aciklama, ''), e.yerel_borc, e.yerel_alacak
                      from public.v_cari_ekstre e
                     where e.taraf_id = @p0 and e.bakiye_dahil = 1
                       and e.islem_tarihi >= @p1
                     order by e.islem_tarihi, e.id
                    """, null, [kurum, baslangic], o => new
                {
                    tarih = o.IsDBNull(0) ? (DateTime?)null : o.GetDateTime(0),
                    belge = o.GetString(1), tur = o.GetString(2), aciklama = o.GetString(3),
                    borc = o.GetDecimal(4), alacak = o.GetDecimal(5),
                }, iptal);
                var vkn = await b.TekDegerAsync<string>(
                    "select coalesce(vkno, '') from public.taraf where id = @p0", null, [kurum], iptal) ?? "";
                cari = new
                {
                    vkn, devreden, hareketler,
                    bakiye = devreden + hareketler.Sum(h => h.borc - h.alacak),
                };
            }

            // FATURALANACAK AÇIK KURUM PAYI (289'un önizleme kümesi): icmal
            //   oluşturulabilir mi sorusunun cevabı. Yalnız tek kurumda anlamlı.
            decimal acikKurumPayi = 0;
            if (kurum > 0)
                acikKurumPayi = await b.TekDegerAsync<decimal?>("""
                    select coalesce(sum(dg.sgk + dg.oss - dg.sgk_kapatilan - dg.oss_kapatilan), 0)
                      from public.belge_satir s
                      join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
                      join public.belge b on b.id = s.belge_id
                      join public.belge_basvuru bb on bb.id = b.id
                     where bb.odeyen_kurum_id = @p0 and b.durum = 0
                       and b.belge_tarihi >= @p1 and b.belge_tarihi < @p2
                       and (dg.sgk + dg.oss) > (dg.sgk_kapatilan + dg.oss_kapatilan)
                       and coalesce(s.pay, 0) = 0
                       and not exists (select 1 from public.kurum_icmal_satir ks
                                        where ks.belge_satir_id = s.id)
                    """, null, [kurum, baslangic, bitis], iptal) ?? 0m;

            var ozet = new
            {
                basvuru = basvurular.Count,
                hasta = basvurular.Select(x => x.hasta).Distinct().Count(),
                provizyonlu = basvurular.Count(x => x.provizyon is 1 or 3),
                red = basvurular.Count(x => x.provizyon == 2),
                kalem = basvurular.Sum(x => x.kalem),
                toplam = basvurular.Sum(x => x.toplam),
                kurumPayi = basvurular.Sum(x => x.kurumPayi),
                hastaPayi = basvurular.Sum(x => x.hastaPayi),
                kesinti = basvurular.Sum(x => x.kesinti),
                kesintiBasvuru = basvurular.Count(x => x.kesinti > 0),
                net = basvurular.Sum(x => x.net),
                faturalanan = icmaller.Where(i => i.belgeId is not null).Sum(i => i.faturaTutari),
                tahsil = icmaller.Sum(i => i.tahsil),
                acikKurumPayi,
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun },
                kurumId = kurum, secili,
                ozet, kurumlar = kurumOzetleri, basvurular, hizmetGruplari, kesintiler, icmaller, cari,
            });
        });

        // ------------------------------------------------ icmal kayıtları ----
        // İCMALLER SEKMESİ (ver2, kullanıcı 10.10.2026: "kurum icmallerini kurum
        //   icmali ekranına sekme olarak alalım"): eski Kurum İcmalleri
        //   listesinin yerine. DÖNEMDEN BAĞIMSIZ bütün icmal kayıtları; kurum
        //   seçimi isteğe bağlı süzgeç. Durum: 1 hazırlanıyor, 2 faturalandı;
        //   faturanın tamamı tahsil edildiyse "tahsil edildi" sayılır.
        grup.MapGet("/kayitlar", async (string? kurumlar, VeriKaynagi veri, BaglamCozucu cozucu,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kurum", Islem.Gor);
            var secili = (kurumlar ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => int.TryParse(x, out var n) ? n : 0).Where(n => n > 0).Distinct().ToArray();
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select i.id, i.kurum_id,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       i.donem_bas, i.donem_bit, i.durum, coalesce(i.toplam, 0), coalesce(i.aciklama, ''),
                       coalesce(s.satir, 0), coalesce(s.basvuru, 0), coalesce(kz.tutar, 0),
                       i.belge_id, coalesce(f.belge_no, ''), f.belge_tarihi, coalesce(f.genel_toplam, 0),
                       coalesce(f.vade_gun, 0),
                       coalesce((select sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end)
                                   from public.kasa_islem ki
                                   join public.kasa_islem_turu kt on kt.kod = ki.tur
                                  where ki.belge_id = i.belge_id and ki.durum <> 9
                                    and kt.grup in ('tahsilat', 'ceksenet', 'kupon')), 0)
                  from public.kurum_icmal i
                  left join public.taraf t on t.id = i.kurum_id
                  left join public.belge f on f.id = i.belge_id
                  left join lateral (
                      select count(*) as satir, count(distinct st.belge_id) as basvuru
                        from public.kurum_icmal_satir ks
                        join public.belge_satir st on st.id = ks.belge_satir_id
                       where ks.icmal_id = i.id) s on true
                  -- Kesinti: icmaldeki başvuruların Medula kesintisi (iade düşülmüş).
                  left join lateral (
                      select sum(mk.tutar - coalesce(mk.iade_tutar, 0)) as tutar
                        from public.medula_kesinti mk
                        join public.medula_fatura mf on mf.id = mk.medula_fatura_id
                       where mf.belge_id in (select st.belge_id from public.kurum_icmal_satir ks
                                               join public.belge_satir st on st.id = ks.belge_satir_id
                                              where ks.icmal_id = i.id)) kz on true
                 where i.durum > 0
                   and (cardinality(@p0::int[]) = 0 or i.kurum_id = any(@p0::int[]))
                   and (@p1 = 0 or coalesce(i.sube_id, 0) in (0, @p1))
                 order by i.donem_bas desc, i.id desc
                 limit 500
                """, null, [secili, baglam.SubeId ?? 0], o =>
            {
                var durum = o.GetInt16(5);
                var fatura = o.GetDecimal(14);
                var tahsil = o.GetDecimal(16);
                var faturaTarihi = o.IsDBNull(13) ? (DateTime?)null : o.GetDateTime(13);
                var vadeGun = o.GetInt32(15);
                DateTime? vade = faturaTarihi?.Date.AddDays(vadeGun);
                return new
                {
                    id = o.GetInt32(0), kurumId = o.GetInt32(1), kurum = o.GetString(2),
                    donemBas = o.GetDateTime(3), donemBit = o.GetDateTime(4), durum,
                    kurumPayi = o.GetDecimal(6), aciklama = o.GetString(7),
                    satir = o.GetInt64(8), basvuru = o.GetInt64(9), kesinti = o.GetDecimal(10),
                    belgeId = o.IsDBNull(11) ? (int?)null : o.GetInt32(11), faturaNo = o.GetString(12),
                    faturaTarihi, faturaTutari = fatura, tahsil, vade,
                    // tahsil edildi > faturalandı (vadesi geçti / kısmi) > hazırlanıyor
                    durumKod = durum == 1 ? "hazirlaniyor"
                             : fatura > 0 && tahsil >= fatura - 0.005m ? "tahsil"
                             : "faturalandi",
                    vadesiGecti = durum == 2 && tahsil < fatura - 0.005m && vadeGun > 0
                                  && vade < Saat.Bugun,
                };
            }, iptal);
            return Results.Ok(new { kayitlar = liste });
        });

        // İcmalin satırları (İcmaller sekmesinde satıra tıklayınca açılır).
        grup.MapGet("/{id:int}/satirlar", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
                                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kurum", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select be.belge_no, be.belge_tarihi,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       coalesce(hz.ad, sk.ad, ''), ks.tutar
                  from public.kurum_icmal_satir ks
                  join public.belge_satir st on st.id = ks.belge_satir_id
                  join public.belge be on be.id = st.belge_id
                  left join public.belge_basvuru bb on bb.id = be.id
                  left join public.taraf h on h.id = coalesce(bb.hasta_id, be.taraf_id)
                  left join public.hizmet hz on hz.id = st.hizmet_id
                  left join public.stok sk on sk.id = st.stok_id
                 where ks.icmal_id = @p0
                 order by be.belge_tarihi, be.id, st.sira
                """, null, [id], o => new
            {
                protokolNo = o.GetString(0), tarih = o.IsDBNull(1) ? (DateTime?)null : o.GetDateTime(1),
                hasta = o.GetString(2), kalem = o.GetString(3), tutar = o.GetDecimal(4),
            }, iptal);
            return Results.Ok(new { satirlar });
        });
    }
}
