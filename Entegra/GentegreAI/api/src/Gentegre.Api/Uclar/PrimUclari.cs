using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PRİM / HAKEDİŞ uçları (324/325).
///
/// Hesabın kendisi veritabanındadır (fn_prim_uret + tetikler): tahsilat
/// dağıtımı yazıldığında prim kendiliğinden doğar. Buradaki uçlar iki iş
/// yapar - kalemin ROLLERİNİ yazmak (primi kim hak ediyor) ve dönemi
/// KAPATMAK (satırları dondurmak).
/// </summary>
public static class PrimUclari
{
    /// <summary>Kalemin rol satırı: kim, hangi rolde, hangi payla.</summary>
    public sealed record RolSatiri(short Rol, int TarafId, decimal? PayYuzde);
    public sealed record RolIstegi(IReadOnlyList<RolSatiri> Satirlar);

    /// <summary>Dönem kapatma: kişinin açık hakediş satırlarını dondurur.</summary>
    public sealed record DonemIstegi(int TarafId, DateTime Baslangic, DateTime Bitis);

    /// <summary>Prim satırı onayı (330): onaylı satır yeniden hesaplanmaz.</summary>
    public sealed record OnayIstegi(IReadOnlyList<int> Satirlar, bool GeriAl);

    /// <summary>Kademe satırı: adet aralığı ve o aralıkta geçerli oran/tutar.</summary>
    public sealed record KademeSatiri(int AdetAlt, int? AdetUst, decimal Deger);
    public sealed record KademeIstegi(IReadOnlyList<KademeSatiri> Satirlar);


    public static void PrimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/prim").WithTags("Prim").RequireAuthorization();

        // --------------------------------------------- serit suzgecleri ----
        // GET /api/prim/hakedis-suzgec?bas=&bit=&rol=
        //
        // Hakedis satirlari seridindeki Prim Rolu / Kisi combolarini doldurur.
        // Kullanici: "tum kisiler ve tum roller listesine O TARIHLER ARASINDA
        // olanlar gelsin" - combo'da secilince BOS grid veren secenek
        // bulunmasin. Bu yuzden seceneklerin kaynagi rol/aday tanimlari degil,
        // ARALIKTAKI SATIRLARIN KENDISI.
        //
        // Kisi listesi rol verilirse ayrica daralir (rol combosu once secilir).
        grup.MapGet("/hakedis-suzgec", async (
            DateTime? bas, DateTime? bit, short? rol,
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // TARIH YOKSA TUMU (kullanici): bos uc "sinir yok" demek - grid ile
            //   ayni davranis. Bos aralikta combo TUM roller/kisiler ile dolar.
            //   Cast'lar acik: tipsiz NULL'i PG bazi baglamlarda cikaramiyor.
            var roller = await baglanti.ListeAsync("""
                select v.rol as id, min(v.rol_adi) as ad, count(*) as adet
                  from public.v_hakedis_satir v
                 where (@p0::date is null or v.tarih >= @p0::date)
                   and (@p1::date is null or v.tarih <= @p1::date)
                 group by v.rol
                 order by v.rol
                """, null, [bas, bit], OkuyucuGenisletmeleri.Sozluk, iptal);

            var kisiler = await baglanti.ListeAsync("""
                select v.taraf_id as id, min(v.kisi) as ad, count(*) as adet
                  from public.v_hakedis_satir v
                 where (@p0::date is null or v.tarih >= @p0::date)
                   and (@p1::date is null or v.tarih <= @p1::date)
                   and (@p2::smallint is null or v.rol = @p2::smallint)
                 group by v.taraf_id
                 order by min(v.kisi)
                """, null, [bas, bit, rol], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { roller, kisiler });
        });

        // ------------------------------------------------- kalem rolleri ----
        // GET /api/prim/kalem/{belgeSatirId}/roller
        grup.MapGet("/kalem/{satirId:int}/roller", async (
            int satirId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select r.id, r.rol, coalesce(kd.ad, '') as "rolAdi",
                       r.taraf_id as "tarafId", coalesce(t.unvan, '') as kisi,
                       r.pay_yuzde as "payYuzde", r.kaynak
                  from public.belge_satir_rol r
                  left join public.taraf t on t.id = r.taraf_id
                  left join public.kod_liste kl on kl.kod = 'prim.rol'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = r.rol
                 where r.belge_satir_id = @p0
                 order by r.rol, r.id
                """, null, [satirId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Bu kalemden DOGMUS primler: rol degistirilince ne olacagini
            //   kullanici gormeli (kesinlesmis satir yeniden hesaplanmaz).
            var primler = await baglanti.ListeAsync("""
                select hs.id, hs.taraf_id as "tarafId", coalesce(t.unvan, '') as kisi,
                       hs.rol, hs.tarih, hs.taban, hs.deger, hs.tutar, hs.durum
                  from public.hakedis_satir hs
                  left join public.taraf t on t.id = hs.taraf_id
                 where hs.belge_satir_id = @p0 and hs.durum <> 0
                 order by hs.id
                """, null, [satirId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar, primler });
        });

        // POST /api/prim/kalem/{satirId}/roller — TOPLU yazar.
        //   Roller kalemin etiketidir: eksik gönderilen satır SİLİNMİŞ sayılır.
        //   Yazımdan sonra o kalemin tahsilat dağıtımları yeniden hesaplanır -
        //   rol değişince primin de değişmesi gerekir.
        grup.MapPost("/kalem/{satirId:int}/roller", async (
            int satirId, RolIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Degistir);

            var satirlar = (istek.Satirlar ?? []).Where(x => x.TarafId > 0 && x.Rol > 0).ToList();

            // Ayni rolde toplam pay %100'u asmamali: iki cerrah %50/%50 olur,
            //   %70/%70 olmaz - yoksa kalemden hak edilenden fazla prim doğar.
            foreach (var g in satirlar.GroupBy(x => x.Rol))
            {
                var toplam = g.Sum(x => x.PayYuzde ?? 100);
                if (toplam > 100.005m)
                    throw GentegreHatasi.IsKurali(
                        $"Aynı roldeki pay yüzdeleri toplamı %100'ü aşamaz (bulunan: %{toplam:0.##}).");
            }

            await using var baglanti = await veri.AcAsync(iptal);
            await using var tx = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync(
                "delete from public.belge_satir_rol where belge_satir_id = @p0",
                tx, [satirId], iptal);

            foreach (var sa in satirlar)
                await baglanti.CalistirAsync("""
                    insert into public.belge_satir_rol
                           (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak, ekleyen)
                    values (@p0, @p1, @p2, coalesce(@p3, 100), 1, @p4)
                    on conflict (belge_satir_id, rol, taraf_id)
                    do update set pay_yuzde = excluded.pay_yuzde
                    """, tx, [satirId, sa.Rol, sa.TarafId, sa.PayYuzde, baglam.KullaniciId], iptal);

            await tx.CommitAsync(iptal);

            // Primi tazele: rol degisti, hakedis satiri da degismeli.
            //
            // IKI YOL DA CALISTIRILIR:
            //   fn_prim_uret        TAHSILAT zamanli planlar - kasa dagitimi
            //                       basina bir hakedis satiri.
            //   fn_prim_uret_belge  FATURALAMA zamanli planlar - kalemin gelir
            //                       belgesi (fis/fatura/tahakkuk) uzerinden.
            //
            // IKINCISI EKSIKTI ve sessiz bir bosluk uretiyordu: faturalama
            // zamanli prim yalnizca DONUSUM aninda (tg_prim_donusum) doguyordu,
            // yani rol SONRADAN yazilirsa - "hekimi yazmayi unutmusuz, ekleyelim"
            // - hicbir prim olusmuyor ve eksiklik ancak ay sonunda fark
            // ediliyordu. Rol degisikligi primin KENDISINI degistirir; tazeleme
            // her iki yolu da kapsamak zorunda.
            //
            // fn_prim_uret_belge kendi icinde ONCE yeniden uretilebilir
            // satirlari siler (durum 1-2, dagitim_id null), yani cift satir
            // uretmez; onayli/odenmis satirlara dokunmaz.
            var uretilen = await baglanti.TekDegerAsync<int>("""
                select coalesce((select sum(public.fn_prim_uret(d.id))
                                   from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = @p0), 0)
                     + coalesce(public.fn_prim_uret_belge(@p0), 0)
                """, null, [satirId], iptal);

            return Results.Ok(new { satirSayisi = satirlar.Count, primSatiri = uretilen });
        });

        // ------------------------------------------------------ kademeler ----
        // Kademe, plan satirinin COCUGU (prim_plani_kademe.satir_id) - yani
        //   kartin TORUNU. Kart cercevesi bir detayi yalnizca kartin kendi
        //   id'siyle baglar, torun seviyesine ulasmaz; bu yuzden kademe kendi
        //   uclariyla okunup yazilir ve arayuzde SATIR MODALINE gomulur
        //   (kullanici: "a yı yap").
        //
        // TAM LISTE YAZILIR (replace): kademeler bir ARALIK KUMESIDIR, tek tek
        //   satir eklemek/silmek araligi gecici olarak tutarsiz birakir
        //   ("1-2 %5" silinip "1-5 %9" yazilana kadar 3. is orana dusmez).
        //   Kullanici pencerede tabloyu tamamlar, tek islemde yerine konur.

        // GET /api/prim/satir/{satirId}/kademeler
        grup.MapGet("/satir/{satirId:int}/kademeler", async (
            int satirId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var satirlar = await baglanti.ListeAsync("""
                select k.id, k.adet_alt as "adetAlt", k.adet_ust as "adetUst",
                       k.deger
                  from public.prim_plani_kademe k
                 where k.satir_id = @p0
                 order by k.adet_alt, k.id
                """, null, [satirId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar });
        });

        // PUT /api/prim/satir/{satirId}/kademeler
        grup.MapPut("/satir/{satirId:int}/kademeler", async (
            int satirId, KademeIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Degistir);

            var satirlar = istek.Satirlar ?? [];

            // ARALIKLAR CAKISMAMALI: "1-5 %10" ile "3-8 %12" ayni adet icin iki
            //   cevap verir ve hangisinin gecerli oldugu SIRALAMAYA kalir -
            //   kullanicinin goremeyecegi bir kural. Ust siniri bos olan
            //   aralik "ve yukarisi" demektir, en fazla BIR tane olabilir.
            var acikUclu = satirlar.Count(x => x.AdetUst is null);
            if (acikUclu > 1)
                throw GentegreHatasi.IsKurali(
                    "Üst sınırı boş (\"ve yukarısı\") yalnızca BİR kademe olabilir.");

            foreach (var k in satirlar)
            {
                if (k.AdetAlt < 0)
                    throw GentegreHatasi.Dogrulama("Adet alt sınırı eksi olamaz.");
                if (k.AdetUst is { } ust && ust < k.AdetAlt)
                    throw GentegreHatasi.Dogrulama(
                        $"Kademe aralığı ters: {k.AdetAlt} - {ust}.");
            }

            foreach (var (a, i) in satirlar.Select((x, i) => (x, i)))
            foreach (var b in satirlar.Skip(i + 1))
            {
                var aUst = a.AdetUst ?? int.MaxValue;
                var bUst = b.AdetUst ?? int.MaxValue;
                if (a.AdetAlt <= bUst && b.AdetAlt <= aUst)
                    throw GentegreHatasi.IsKurali(
                        $"Kademe aralıkları çakışıyor: {a.AdetAlt}-{(a.AdetUst?.ToString() ?? "üstü")} "
                        + $"ile {b.AdetAlt}-{(b.AdetUst?.ToString() ?? "üstü")}.");
            }

            await using var baglanti = await veri.AcAsync(iptal);
            await using var tx = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync(
                "delete from public.prim_plani_kademe where satir_id = @p0",
                tx, [satirId], iptal);

            foreach (var k in satirlar)
                await baglanti.CalistirAsync("""
                    insert into public.prim_plani_kademe (satir_id, adet_alt, adet_ust, deger)
                    values (@p0, @p1, @p2, @p3)
                    """, tx, [satirId, k.AdetAlt, k.AdetUst, k.Deger], iptal);

            await tx.CommitAsync(iptal);
            return Results.Ok(new { satirSayisi = satirlar.Count });
        });

        // --------------------------------------------------- dönem kapat ----
        // POST /api/prim/donem-kapat
        //   Kişinin o dönemdeki AÇIK hakediş satırlarını bir başlığa bağlar ve
        //   dondurur. Geri alınamaz olduğu için ayrı yetki ister.
        grup.MapPost("/donem-kapat", async (
            DonemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Degistir);
            baglam.AksiyonIste("prim.donem_kapat");

            if (istek.TarafId <= 0)
                throw GentegreHatasi.IsKurali("Hakedişi kapatılacak kişi seçilmeli.");
            if (istek.Bitis < istek.Baslangic)
                throw GentegreHatasi.IsKurali("Dönem bitişi başlangıçtan önce olamaz.");

            await using var baglanti = await veri.AcAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                select public.fn_hakedis_kapat(@p0, @p1::date, @p2::date, @p3, @p4)
                """, null,
                [istek.TarafId, istek.Baslangic, istek.Bitis,
                 baglam.KullaniciId, baglam.SubeId], iptal);

            var kayit = await baglanti.TekAsync("""
                select h.id, h.toplam, h.donem_baslangic as "donemBaslangic",
                       h.donem_bitis as "donemBitis",
                       (select count(*) from public.hakedis_satir s where s.hakedis_id = h.id)
                       as "satirSayisi"
                  from public.hakedis h where h.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(kayit);
        });

        // ------------------------------------------------------- onay (330) --
        // Onay, primi KILITLER: rol ya da belge türü sonradan değişse bile
        //   satır yeniden hesaplanmaz. Taslak satır onaylanamaz - önce kalem
        //   gelir belgesine dönüşmeli (kural veritabanında).
        grup.MapPost("/onayla", async (
            OnayIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Degistir);
            baglam.AksiyonIste("prim.onayla");

            var idler = (istek.Satirlar ?? []).Where(x => x > 0).Distinct().ToList();
            if (idler.Count == 0)
                throw GentegreHatasi.IsKurali("Onaylanacak satır seçilmeli.");

            await using var baglanti = await veri.AcAsync(iptal);

            var sayac = 0;
            foreach (var id in idler)
            {
                await baglanti.TekDegerAsync<short>(
                    "select public.fn_prim_onayla(@p0, @p1)", null,
                    [id, istek.GeriAl ? (short)1 : (short)0], iptal);
                sayac++;
            }

            return Results.Ok(new { satirSayisi = sayac, geriAl = istek.GeriAl });
        });

        // -------------------------------------------- kendi hakedişim ---
        // GET /api/prim/hakedisim?bas=&bit=
        //
        // HEKİMİN KENDİ EKRANI (mockup Ekranlar/Muayene/hekim_hakedislerim):
        // dönem özeti, kaynak kırılımı, satır listesi ve ödeme geçmişi.
        //
        // SÜZGECİ SUNUCU KOYAR: `taraf_id` istekten DEĞİL oturumdan gelir -
        // istemciye bırakılsa parametreyi değiştiren herkes başkasının
        // primini okurdu. `prim.kendi` yetkisi yalnız bunu açar; bütün
        // kişileri gören ekran `prim` yetkisindedir (muhasebe).
        //
        // TAHSİL EDİLEN / BEKLEYEN AYRI: prim planı "hakediş anı =
        // tahsilatta" ise faturalanmış ama tahsil edilmemiş tutar henüz hak
        // edilmiş değildir (`kaynak_tur` 1 tahsilat · 2 faturalama). Tek
        // toplam göstermek hekime olmayan parayı vaat ederdi.
        grup.MapGet("/hakedisim", async (
            DateTime? bas, DateTime? bit,
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim.kendi", Islem.Gor);

            var baslangic = bas?.Date ?? new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var bitis = bit?.Date ?? baslangic.AddMonths(1).AddDays(-1);
            var kisi = baglam.KullaniciId;

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select hs.id, hs.tarih, coalesce(hs.hasta, '') as hasta,
                       coalesce(hs.kalem, '') as kalem,
                       hs.kaynak_tur as "kaynakTur", hs.kaynak_adi as "kaynakAdi",
                       hs.pay, hs.pay_adi as "payAdi",
                       hs.taban, hs.oran_tipi as "oranTipi", hs.deger,
                       hs.tutar, hs.durum, hs.durum_adi as "durumAdi",
                       hs.rol, hs.rol_adi as "rolAdi",
                       hs.belge_id as "belgeId", hs.belge_tur_adi as "belgeTurAdi",
                       coalesce(b.belge_no, '') as "belgeNo"
                  from public.v_hakedis_satir hs
                  left join public.belge b on b.id = hs.belge_id
                 where hs.taraf_id = @p0 and hs.tarih between @p1 and @p2
                 order by hs.tarih, hs.id
                """, null, [kisi, baslangic, bitis],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            // ÖZET satırlardan TÜRETİLMEZ, ayrı sorguyla alınır: liste
            //   sayfalanabilir, özet dönemin tamamını söylemeli.
            var ozet = await baglanti.TekAsync("""
                select coalesce(sum(tutar), 0) as toplam,
                       coalesce(sum(tutar) filter (where kaynak_tur = 1), 0) as tahsil,
                       coalesce(sum(tutar) filter (where kaynak_tur = 2), 0) as bekleyen,
                       count(*) as satir,
                       count(distinct belge_id) as belge,
                       coalesce(sum(taban), 0) as taban
                  from public.v_hakedis_satir
                 where taraf_id = @p0 and tarih between @p1 and @p2
                """, null, [kisi, baslangic, bitis],
                o => new { Toplam = o.GetDecimal(0), Tahsil = o.GetDecimal(1),
                           Bekleyen = o.GetDecimal(2), Satir = o.GetInt64(3),
                           Belge = o.GetInt64(4), Taban = o.GetDecimal(5) }, iptal);

            // KAYNAK KIRILIMI: hekimin ikinci sorusu "bu para nereden geldi"
            //   - muayeneden mi, girişimden mi, istediği tetkikten mi.
            var kirilim = await baglanti.ListeAsync("""
                select coalesce(rol_adi, 'Diğer') as "ad",
                       count(*) as "satir", coalesce(sum(tutar), 0) as "tutar"
                  from public.v_hakedis_satir
                 where taraf_id = @p0 and tarih between @p1 and @p2
                 group by rol_adi order by 3 desc
                """, null, [kisi, baslangic, bitis],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            // ÖDEME GEÇMİŞİ: kapanmış dönemler (hakedis başlığı).
            var gecmis = await baglanti.ListeAsync("""
                select h.id, h.donem_baslangic as "donemBaslangic",
                       h.donem_bitis as "donemBitis", h.durum, h.toplam,
                       coalesce(h.aciklama, '') as "aciklama"
                  from public.hakedis h
                 where h.taraf_id = @p0
                 order by h.donem_baslangic desc limit 6
                """, null, [kisi],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                kisiId = kisi,
                donem = new { baslangic, bitis },
                ozet = new
                {
                    toplam = ozet?.Toplam ?? 0m, tahsil = ozet?.Tahsil ?? 0m,
                    bekleyen = ozet?.Bekleyen ?? 0m, taban = ozet?.Taban ?? 0m,
                    satir = ozet?.Satir ?? 0, belge = ozet?.Belge ?? 0,
                },
                kirilim, satirlar, gecmis,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ------------------------------------------------ açık hakedişler ---
        // Dönem kapatma ekranı için: kişi bazında açık (dondurulmamış) tutar.
        grup.MapGet("/acik", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            // TASLAK satirlar da dondurulur (tutar 0 olsa bile): kullanici
            //   "neden kapatamiyorum" sorusunun cevabini ekranda gormeli.
            return Results.Ok(await baglanti.ListeAsync("""
                select o.taraf_id as "tarafId", o.kisi, o.acik_satir as "acikSatir",
                       o.acik_tutar as "acikTutar", o.taslak_satir as "taslakSatir",
                       o.taslak_tutar as "taslakTutar",
                       o.kapanan_tutar as "kapananTutar",
                       o.ilk_tarih as "ilkTarih", o.son_tarih as "sonTarih"
                  from public.v_hakedis_ozet o
                 where o.acik_tutar > 0 or o.taslak_tutar > 0
                 order by o.acik_tutar desc, o.taslak_tutar desc
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal));
        });
    }
}
