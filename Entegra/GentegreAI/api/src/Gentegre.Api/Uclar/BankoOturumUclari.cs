using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BANKO OTURUMU (987, Ekranlar/Kayıt Kabul/banko_oturum_akisi_v2.html) —
/// vardiya akışı: açılış talebi → (ops.) sorumlu onayı → devir sayımı → gün
/// içi işlem → gün sonu sayımı → teslim ve kapanış.
///
/// OTURUM = BANKO + GÖREVLİ. Banko tanımında kullanıcı yoktur; sabah açılışta
/// uygun banko seçilir ve oturum giriş yapan kullanıcının adıyla başlar. Her
/// kasa işlemi <c>oturum_id</c> taşır, böylece "parayı kim, hangi kasadan
/// aldı" tek kolonla yanıtlanır.
///
/// DEVİR ELLE YAZILMAZ: açılıştaki sistem devri önceki oturumun
/// <c>kasada_birakilan</c> değeridir (<c>fn_banko_devir</c>). İstemciden gelen
/// devir değeri yok sayılır - elle yazılabilse kasadaki para ile kayıt
/// arasındaki bağ kopardı.
///
/// FARK AÇILIŞTA YAZILIR: devir ile sayım tutmuyorsa fark kapanışta değil
/// açılışta kaydedilir; sonraki görevli başkasının farkını devralmasın.
///
/// ONAYLAR OPSİYONEL VE AYRI (<c>banko.acilis_onay</c> /
/// <c>banko.gun_sonu_onay</c>): kapalıysa adım atlanır, görevli devri sayıp
/// doğrudan açar ya da kapatır. Küçük kurumda her sabah onay beklemek bankoyu
/// durdurur, büyük kurumda devir farkının imzası gerekir - kararı kurum verir.
///
/// SORUMLU KENDİ OTURUMUNU ONAYLAMAZ: karşılıklı imza değil denetim olması
/// için onaylayan ile görevli aynı kişi olamaz.
/// </summary>
public static class BankoOturumUclari
{
    // Durum: 1 açılış onayı bekliyor · 2 açık · 3 teslime gönderildi
    //        4 kapandı · 5 açılış reddedildi
    private const short OnayBekler = 1, Acik = 2, TeslimBekler = 3, Kapandi = 4, Reddedildi = 5;

    public static void BankoOturumUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/banko-oturum").WithTags("Banko Oturumu").RequireAuthorization();

        // ---------------------------------------------------- uygun bankolar
        // Listede yalnız bu şubedeki AKTİF, KASALI ve canlı oturumu olmayan
        //   bankolar çıkar: başkasının açık oturumuna girilmez, danışma
        //   bankosunda (tür 2) kasa yok - oturum beklenmez.
        grup.MapGet("/uygun-bankolar", async (VeriKaynagi veri, BaglamCozucu cozucu,
                                              HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("banko-oturum");
            baglam.YetkiIste("banko_oturum", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select b.id, b.kod, b.ad, b.konum, b.tur, coalesce(h.ad, '') as hesap,
                       public.fn_banko_devir(b.id) as devir,
                       b.acilis_onay, b.gun_sonu_onay, b.kupur_dokumu, b.devir_tutar
                  from public.banko b
                  left join public.hesap h on h.id = b.hesap_id
                 where b.aktif = 1 and b.sube_id = @p0 and b.tur <> 2
                   and not exists (select 1 from public.banko_oturum o
                                    where o.banko_id = b.id and o.durum in (1, 2, 3))
                 order by b.kod
                """, null, [baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                konum = o.GetString(3), tur = o.GetInt16(4), hesap = o.GetString(5),
                devir = o.GetDecimal(6), acilisOnay = o.GetInt16(7) == 1,
                gunSonuOnay = o.GetInt16(8) == 1, kupurDokumu = o.GetInt16(9) == 1,
                birakilacak = o.GetDecimal(10),
            }, iptal);
            return Results.Ok(liste);
        });

        // ------------------------------------------------------ aktif oturum
        // Kullanıcının canlı oturumu (varsa): gün içi şeridin kaynağı.
        grup.MapGet("/aktif", async (VeriKaynagi veri, BaglamCozucu cozucu,
                                     HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_oturum", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await OturumAsync(b, """
                where o.kullanici_id = @p0 and o.durum in (1, 2, 3)
                order by o.id desc limit 1
                """, [baglam.KullaniciId], iptal);
            return o is null ? Results.Ok(new { oturum = (object?)null }) : Results.Ok(new { oturum = o });
        });

        grup.MapGet("/{id:long}", async (long id, VeriKaynagi veri, BaglamCozucu cozucu,
                                         HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_oturum", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await OturumAsync(b, "where o.id = @p0 and o.sube_id = @p1", [id, baglam.SubeId ?? 0], iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Oturum bulunamadı.");
            var kupur = await b.ListeAsync("""
                select asama, birim, adet from public.banko_oturum_kupur
                 where oturum_id = @p0 order by asama, birim desc
                """, null, [id],
                r => new { asama = r.GetInt16(0), birim = r.GetDecimal(1), adet = r.GetInt32(2) }, iptal);
            // ODEME TURU DOKUMU (989): gun sonunda kasiyer ile sorumlu bu
            //   tabloya bakarak mutabik kalir - tek "nakit/POS" toplami
            //   "hangi turden ne kadar girdi" sorusunu yanitlamiyor.
            var turler = await b.ListeAsync("""
                select tur, tur_adi, tur_grup, hesap_turu, kasa_durumu,
                       adet, tahsilat, iade, net
                  from public.v_banko_oturum_tur_ozeti
                 where oturum_id = @p0
                 order by kasa_durumu, tur
                """, null, [id], r => new
            {
                tur = r.GetInt16(0), turAdi = r.GetString(1), turGrup = r.GetString(2),
                hesapTuru = r.GetString(3), kasaDurumu = r.GetInt32(4),
                adet = r.GetInt64(5), tahsilat = r.GetDecimal(6),
                iade = r.GetDecimal(7), net = r.GetDecimal(8),
            }, iptal);
            // POS GUN SONU ESLESMESI (990): her cihazin kendi toplami ayri
            //   anlam tasiyor - "hangi terminalde fark var" sorusu tek POS
            //   toplamiyla yanitlanamaz.
            var posListe = await b.ListeAsync("""
                select banko_pos_id, banka_adi, terminal_no, pos_durum,
                       sistem_toplam, cihaz_toplam, fark, eslesme_durum, eslesme_not
                  from public.v_banko_oturum_pos
                 where oturum_id = @p0
                 order by terminal_no
                """, null, [id], r => new
            {
                bankoPosId = r.GetInt32(0), bankaAdi = r.GetString(1),
                terminalNo = r.GetString(2), posDurum = r.GetInt16(3),
                sistemToplam = r.GetDecimal(4),
                cihazToplam = r.IsDBNull(5) ? (decimal?)null : r.GetDecimal(5),
                fark = r.IsDBNull(6) ? (decimal?)null : r.GetDecimal(6),
                eslesmeDurum = r.IsDBNull(7) ? (short?)null : r.GetInt16(7),
                eslesmeNot = r.IsDBNull(8) ? "" : r.GetString(8),
            }, iptal);
            // TERMINALE BAGLANMAMIS POS TAHSILATI: sessizce 0 gostermek,
            //   gorevliyi "cihazda para var sistemde yok" yanilgisina
            //   surukler - para kayitta, yalniz hangi terminalden gectigi
            //   yazilmamistir (tahsilat ekrani POS'u yazmaya baslayana kadar
            //   tum POS tahsilati burada toplanir).
            var atanmamis = await b.TekAsync("""
                select toplam, adet from public.v_banko_oturum_pos_atanmamis
                 where oturum_id = @p0
                """, null, [id],
                r => new { toplam = r.GetDecimal(0), adet = r.GetInt64(1) }, iptal);
            return Results.Ok(new
            {
                oturum = o, kupurler = kupur, turler, pos = posListe,
                posAtanmamis = atanmamis,
            });
        });

        // ------------------------------------------------------------- açılış
        grup.MapPost("/ac", async (AcIstegi istek, VeriKaynagi veri, LogDeposu log,
                                   BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("banko-oturum");
            baglam.YetkiIste("banko_oturum", Islem.Ekle);
            if (istek.BankoId is not > 0) throw GentegreHatasi.Dogrulama("Banko seçilmeli.");

            await using var b = await veri.AcAsync(iptal);
            var banko = await b.TekAsync("""
                select b.id, b.ad, b.tur, b.aktif, b.sube_id, b.acilis_onay, b.devir_tutar,
                       public.fn_banko_devir(b.id)
                  from public.banko b where b.id = @p0
                """, null, [istek.BankoId], o => new
            {
                Id = o.GetInt32(0), Ad = o.GetString(1), Tur = o.GetInt16(2),
                Aktif = o.GetInt16(3), SubeId = o.GetInt32(4), AcilisOnay = o.GetInt16(5) == 1,
                Birakilacak = o.GetDecimal(6), Devir = o.GetDecimal(7),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Banko bulunamadı.");

            if (banko.Aktif != 1)
                throw GentegreHatasi.IsKurali("Pasif bankoda oturum açılamaz.");
            // KASASIZ BANKO (tür 2 Danışma): tahsilat yapmaz, oturumu da olmaz.
            if (banko.Tur == 2)
                throw GentegreHatasi.IsKurali("Danışma bankosunda kasa yok; oturum açılmaz.");
            if (banko.SubeId != (baglam.SubeId ?? 0))
                throw GentegreHatasi.IsKurali("Banko başka şubeye ait.");

            // DEVİR SUNUCUDAN: istemciden gelen değer yok sayılır.
            var devir = banko.Devir;
            var sayim = Math.Round(istek.AcilisSayim ?? 0m, 2);
            var fark = Math.Round(sayim - devir, 2);
            var durum = banko.AcilisOnay ? OnayBekler : Acik;

            await using var islem = await b.BeginTransactionAsync(iptal);
            long id;
            try
            {
                id = await b.TekDegerAsync<long>("""
                    insert into public.banko_oturum
                        (banko_id, sube_id, kullanici_id, vardiya, durum, devir_tutar,
                         acilis_sayim, acilis_fark, acilis_not, acilis_ts,
                         kasada_birakilan, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8,
                            case when @p4 = 2 then now() end, @p9, @p2)
                    returning id
                    """, islem,
                    [banko.Id, baglam.SubeId ?? 0, baglam.KullaniciId, Kirp(istek.Vardiya, 30),
                     durum, devir, sayim, fark, Kirp(istek.Not, 400), banko.Birakilacak], iptal);
            }
            catch (PostgresException h) when (h.SqlState == "23505")
            {
                // Canlı oturum kısıtı: ikisi de kullanıcıya anlamlı mesaj ister.
                throw GentegreHatasi.IsKurali(
                    h.ConstraintName == "banko_oturum_canli_kullanici"
                        ? "Açık bir oturumunuz var; yeni oturum açmadan önce onu kapatın."
                        : "Bu bankoda açık bir oturum var; aynı kasada iki oturum olmaz.");
            }

            await KupurYazAsync(b, islem, id, 1, istek.Kupurler, baglam.KullaniciId, iptal);
            await log.YazAsync(b, islem, LogIslemi.Ekle, LogTablo, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { banko = banko.Ad, devir, sayim, fark, onayBekler = banko.AcilisOnay }, iptal: iptal);
            await islem.CommitAsync(iptal);

            var oturum = await OturumAsync(b, "where o.id = @p0", [id], iptal);
            return Results.Ok(new
            {
                oturum,
                mesaj = banko.AcilisOnay
                    ? "Açılış talebi sorumluya gönderildi; onay gelene kadar tahsilat girilemez."
                    : "Oturum açıldı.",
            });
        });

        // -------------------------------------------------------- onay kuyruğu
        grup.MapGet("/onay-kuyrugu", async (VeriKaynagi veri, BaglamCozucu cozucu,
                                            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("banko-onay");
            baglam.YetkiIste("banko_onay", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            // Açılış (1) ve kapanış (3) bekleyenler BİR kuyrukta: sorumlunun
            //   işi "bekleyen imza", türü ayırt etmek için `tur` kolonu var.
            var liste = await b.ListeAsync("""
                select o.id, case when o.durum = 1 then 'acilis' else 'kapanis' end as tur,
                       o.banko_kod, o.banko_ad,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as gorevli,
                       o.kullanici_id, o.vardiya,
                       case when o.durum = 1 then o.devir_tutar else o.kapanis_beklenen end as beklenen,
                       case when o.durum = 1 then o.acilis_sayim else o.kapanis_sayim end  as sayim,
                       case when o.durum = 1 then o.acilis_fark  else o.kapanis_fark  end  as fark,
                       case when o.durum = 1 then o.acilis_not else o.fark_aciklama end    as not,
                       o.acilis_talep_ts as talep_ts, o.kapanis_talep_ts,
                       o.durum, o.nakit_tahsilat, o.pos_tutar, o.islem_adet, o.teslim_edilen
                  from public.v_banko_oturum_ozet o
                  left join public.taraf t on t.id = o.kullanici_id
                 where o.durum in (1, 3) and o.sube_id = @p0
                 order by o.durum, coalesce(o.kapanis_talep_ts, o.acilis_talep_ts)
                """, null, [baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt64(0), tur = o.GetString(1), bankoKod = o.GetString(2),
                bankoAd = o.GetString(3), gorevli = o.GetString(4), kullaniciId = o.GetInt32(5),
                vardiya = o.GetString(6), beklenen = o.GetDecimal(7), sayim = o.GetDecimal(8),
                fark = o.GetDecimal(9), not = o.GetString(10), talepTs = o.GetDateTime(11),
                kapanisTalepTs = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
                durum = o.GetInt16(13), nakit = o.GetDecimal(14), pos = o.GetDecimal(15),
                islemAdet = o.GetInt64(16), teslimEdilen = o.GetDecimal(17),
                // KENDİ OTURUMU: düğme istemcide de kapalı gelsin; sunucu yine
                //   reddeder ama kullanıcıya tıklanabilir bir yol göstermeyelim.
                kendisi = o.GetInt32(5) == baglam.KullaniciId,
            }, iptal);
            return Results.Ok(liste);
        });

        // ----------------------------------------------------- açılış onayı
        grup.MapPost("/{id:long}/onayla", async (long id, OnayIstegi? istek, VeriKaynagi veri,
            LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_onay", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var o = await DurumAsync(b, id, baglam.SubeId ?? 0, iptal);
            var fisNotu = "";

            if (o.KullaniciId == baglam.KullaniciId)
                throw GentegreHatasi.IsKurali("Kendi oturumunuzu onaylayamazsınız.");

            await using var islem = await b.BeginTransactionAsync(iptal);
            if (o.Durum == OnayBekler)
            {
                await b.CalistirAsync("""
                    update public.banko_oturum
                       set durum = 2, acilis_ts = now(), acilis_onay_id = @p1,
                           acilis_onay_ts = now(), degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId], iptal);
            }
            else if (o.Durum == TeslimBekler)
            {
                // KAPANIŞ ONAYI: oturum kapanır, fark fişi burada yazılır -
                //   fark ayrı fişle muhasebeleşir, kasa bakiyesi sayımla
                //   eşitlenir ve fark geçmişi bozulmaz.
                var tutanak = await TutanakNoAsync(b, islem, iptal);
                await b.CalistirAsync("""
                    update public.banko_oturum
                       set durum = 4, kapanis_ts = now(), kapanis_onay_id = @p1,
                           kapanis_onay_ts = now(), tutanak_no = @p2,
                           teslim_alan_id = coalesce(teslim_alan_id, @p1),
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId, tutanak], iptal);
                // FARK FISI KAPANISTA YAZILIR, teslime gonderirken degil:
                //   sorumlu reddederse gorevli yeniden sayar ve fark degisir -
                //   her denemede fis yazmak kasayi birkac kez duzeltirdi.
                var ozet = await OturumAsync(b, "where o.id = @p0", [id], iptal);
                if (ozet is not null)
                    fisNotu = await FarkFisiAsync(b, islem, id, ozet.BankoId, ozet.HesapId,
                                                  ozet.KapanisFark, ozet.FarkNeden,
                                                  ozet.FarkAciklama, baglam, iptal);
            }
            else throw GentegreHatasi.IsKurali("Bu oturum onay beklemiyor.");

            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTablo, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { onay = o.Durum == OnayBekler ? "acilis" : "kapanis", not = istek?.Not ?? "" },
                iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                oturum = await OturumAsync(b, "where o.id = @p0", [id], iptal),
                mesaj = (o.Durum == OnayBekler ? "Oturum açıldı." : "Oturum kapandı.") + fisNotu,
            });
        });

        grup.MapPost("/{id:long}/reddet", async (long id, OnayIstegi istek, VeriKaynagi veri,
            LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_onay", Islem.Degistir);
            if (string.IsNullOrWhiteSpace(istek.Not))
                throw GentegreHatasi.Dogrulama("Red nedeni yazılmalı.");
            await using var b = await veri.AcAsync(iptal);
            var o = await DurumAsync(b, id, baglam.SubeId ?? 0, iptal);
            if (o.KullaniciId == baglam.KullaniciId)
                throw GentegreHatasi.IsKurali("Kendi oturumunuzu reddedemezsiniz.");

            await using var islem = await b.BeginTransactionAsync(iptal);
            if (o.Durum == OnayBekler)
            {
                await b.CalistirAsync("""
                    update public.banko_oturum
                       set durum = 5, red_neden = @p2, degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId, Kirp(istek.Not, 400)], iptal);
            }
            else if (o.Durum == TeslimBekler)
            {
                // KAPANIŞ REDDİ oturumu kapatmaz, AÇIK durumuna döndürür:
                //   görevli yeniden sayar. Reddi "kapandı" saymak, sayımı
                //   düzeltilemez hale getirirdi.
                await b.CalistirAsync("""
                    update public.banko_oturum
                       set durum = 2, kapanis_talep_ts = null, red_neden = @p2,
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId, Kirp(istek.Not, 400)], iptal);
            }
            else throw GentegreHatasi.IsKurali("Bu oturum onay beklemiyor.");

            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTablo, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { red = istek.Not }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { oturum = await OturumAsync(b, "where o.id = @p0", [id], iptal) });
        });

        // ----------------------------------------------------------- gün sonu
        grup.MapPost("/{id:long}/gun-sonu", async (long id, GunSonuIstegi istek, VeriKaynagi veri,
            LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_oturum", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var ozet = await OturumAsync(b, "where o.id = @p0 and o.sube_id = @p1",
                                         [id, baglam.SubeId ?? 0], iptal)
                       ?? throw GentegreHatasi.Bulunamadi("Oturum bulunamadı.");

            if (ozet.Durum != Acik)
                throw GentegreHatasi.IsKurali(ozet.Durum == TeslimBekler
                    ? "Oturum zaten teslime gönderildi."
                    : "Yalnız açık oturum için gün sonu yapılır.");
            // KENDİ OTURUMU: başkasının kasasını saymak teslim değil devir
            //   olur; sorumlu gerekirse önce oturumu kendine aktarır.
            if (ozet.KullaniciId != baglam.KullaniciId
                && !baglam.Yetkiler.Var("banko_onay", Islem.Degistir))
                throw GentegreHatasi.IsKurali("Bu oturum başka bir görevliye ait.");

            var sayim = Math.Round(istek.KapanisSayim ?? 0m, 2);
            var beklenen = ozet.BeklenenNakit;
            var fark = Math.Round(sayim - beklenen, 2);
            // FARK FİŞSİZ KAPANIŞ YOK: fark varsa neden ve açıklama zorunlu.
            //   Açıklamasız fark, kasada eksik parayı "kayıt" haline getirirdi.
            if (fark != 0 && (istek.FarkNeden is not > 0 || string.IsNullOrWhiteSpace(istek.FarkAciklama)))
                throw GentegreHatasi.Dogrulama("Fark var: fark nedeni ve açıklaması zorunlu.",
                    new AlanHatasi("farkAciklama", "Fark varsa neden ve açıklama girilmeli."));

            var birakilan = Math.Round(istek.KasadaBirakilan ?? 0m, 2);
            if (birakilan < 0) throw GentegreHatasi.Dogrulama("Kasada bırakılan eksi olamaz.");
            // BIRAKILAN SAYILANI AŞAMAZ: olmayan parayı yarına devretmek,
            //   ertesi gün açılışta hazır fark üretirdi.
            if (birakilan > sayim)
                throw GentegreHatasi.Dogrulama("Kasada bırakılan tutar sayılan nakitten fazla olamaz.",
                    new AlanHatasi("kasadaBirakilan", "Sayılan nakitten fazla olamaz."));

            var onayIster = ozet.GunSonuOnay;
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.banko_oturum
                   set durum = @p1, kapanis_talep_ts = now(),
                       kapanis_sayim = @p2, kapanis_beklenen = @p3, kapanis_fark = @p4,
                       fark_neden = @p5, fark_aciklama = @p6,
                       kasada_birakilan = @p7, teslim_edilen = @p8,
                       teslim_alan_id = @p9,
                       kapanis_ts = case when @p1 = 4 then now() end,
                       degistiren = @p10, degistirme_tarihi = now()
                 where id = @p0
                """, islem,
                [id, onayIster ? TeslimBekler : Kapandi, sayim, beklenen, fark,
                 (short)(istek.FarkNeden ?? 0), Kirp(istek.FarkAciklama, 600),
                 birakilan, Math.Round(sayim - birakilan, 2),
                 istek.TeslimAlanId, baglam.KullaniciId], iptal);

            await b.CalistirAsync("delete from public.banko_oturum_kupur where oturum_id = @p0 and asama = 2",
                                  islem, [id], iptal);
            await KupurYazAsync(b, islem, id, 2, istek.Kupurler, baglam.KullaniciId, iptal);

            string? tutanak = null;
            string fisNotu = "";
            if (!onayIster)
            {
                tutanak = await TutanakNoAsync(b, islem, iptal);
                await b.CalistirAsync(
                    "update public.banko_oturum set tutanak_no = @p1 where id = @p0",
                    islem, [id, tutanak], iptal);
                fisNotu = await FarkFisiAsync(b, islem, id, ozet.BankoId, ozet.HesapId,
                                              fark, istek.FarkNeden ?? 0, istek.FarkAciklama,
                                              baglam, iptal);
            }

            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTablo, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { gunSonu = true, beklenen, sayim, fark, birakilan, onayIster }, iptal: iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                oturum = await OturumAsync(b, "where o.id = @p0", [id], iptal),
                tutanakNo = tutanak,
                mesaj = (onayIster
                    ? "Sayım kaydedildi, teslime gönderildi; onay gelene kadar bankoda tahsilat girilemez."
                    : "Oturum kapandı.") + fisNotu,
            });
        });

        // --------------------------------------------- POS gun sonu eslesmesi
        // Gorevli her cihazin gun sonu raporundaki toplami girer; sistem
        //   kendi toplamini dondurur ve farki yazar. FARK GUN SONUNU
        //   ENGELLEMEZ: POS farki banka ekstresiyle kapanir (komisyon,
        //   taksit, gun kaymasi) - nakit sayim farkiyla ayni sey degil.
        grup.MapPost("/{id:long}/pos-eslestir", async (long id, PosEslesmeIstegi istek,
            VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_oturum", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var o = await DurumAsync(b, id, baglam.SubeId ?? 0, iptal);
            if (o.Durum != Acik && o.Durum != TeslimBekler)
                throw GentegreHatasi.IsKurali("Yalnız açık ya da teslimde olan oturumda POS eşleştirilir.");

            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var satir in istek.Satirlar ?? [])
            {
                if (satir.BankoPosId is not > 0) continue;
                // SISTEM TOPLAMI YAZILDIGI AN DONDURULUR: sonraki duzeltme
                //   fisleri gecmis mutabakati oynatmasin.
                var sistem = await b.TekDegerAsync<decimal?>("""
                    select sistem_toplam from public.v_banko_oturum_pos
                     where oturum_id = @p0 and banko_pos_id = @p1
                    """, islem, [id, satir.BankoPosId], iptal) ?? 0m;
                var cihaz = Math.Round(satir.CihazToplam ?? 0m, 2);
                var fark = Math.Round(cihaz - sistem, 2);
                var durum = (short)(satir.UlasilamadiMi == true ? 3 : fark == 0 ? 1 : 2);
                await b.CalistirAsync("""
                    insert into public.banko_oturum_pos
                           (oturum_id, banko_pos_id, cihaz_toplam, sistem_toplam, fark,
                            durum, aciklama, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7)
                    on conflict (oturum_id, banko_pos_id) do update
                       set cihaz_toplam = @p2, sistem_toplam = @p3, fark = @p4,
                           durum = @p5, aciklama = @p6
                    """, islem,
                    [id, satir.BankoPosId, cihaz, sistem, fark, durum,
                     Kirp(satir.Aciklama, 300), baglam.KullaniciId], iptal);
            }
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTablo, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { posEslesme = (istek.Satirlar ?? []).Count }, iptal: iptal);
            await islem.CommitAsync(iptal);

            var liste = await b.ListeAsync("""
                select banko_pos_id, sistem_toplam, cihaz_toplam, fark, eslesme_durum
                  from public.v_banko_oturum_pos where oturum_id = @p0 order by terminal_no
                """, null, [id], r => new
            {
                bankoPosId = r.GetInt32(0), sistemToplam = r.GetDecimal(1),
                cihazToplam = r.IsDBNull(2) ? (decimal?)null : r.GetDecimal(2),
                fark = r.IsDBNull(3) ? (decimal?)null : r.GetDecimal(3),
                eslesmeDurum = r.IsDBNull(4) ? (short?)null : r.GetInt16(4),
            }, iptal);
            return Results.Ok(new { pos = liste });
        });

        // ------------------------------------------------------- yeniden aç
        // AYRI YETKİ: kapanan oturum normalde düzeltilmez, hatalı tahsilat
        //   iade/düzeltme fişiyle çözülür. Yine de yanlış kapatılan oturum
        //   için bir yol gerekiyor; kim açtığı loga yazılır.
        grup.MapPost("/{id:long}/yeniden-ac", async (long id, OnayIstegi istek, VeriKaynagi veri,
            LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("banko_oturum.yeniden_ac", Islem.Degistir);
            if (string.IsNullOrWhiteSpace(istek.Not))
                throw GentegreHatasi.Dogrulama("Yeniden açma gerekçesi yazılmalı.");
            await using var b = await veri.AcAsync(iptal);
            var o = await DurumAsync(b, id, baglam.SubeId ?? 0, iptal);
            if (o.Durum != Kapandi) throw GentegreHatasi.IsKurali("Yalnız kapanmış oturum yeniden açılır.");

            await using var islem = await b.BeginTransactionAsync(iptal);
            try
            {
                await b.CalistirAsync("""
                    update public.banko_oturum
                       set durum = 2, kapanis_ts = null, kapanis_talep_ts = null,
                           kapanis_onay_id = null, kapanis_onay_ts = null,
                           red_neden = @p2, degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId, Kirp(istek.Not, 400)], iptal);
            }
            catch (PostgresException h) when (h.SqlState == "23505")
            {
                throw GentegreHatasi.IsKurali(
                    "Bankoda ya da görevlide canlı oturum var; önce onu kapatın.");
            }
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTablo, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { yenidenAc = istek.Not }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { oturum = await OturumAsync(b, "where o.id = @p0", [id], iptal) });
        });
    }

    // ------------------------------------------------------------- yardımcı
    /// <summary>islem_log.tablo_id — banko oturumu.</summary>
    private const int LogTablo = 1385;

    private static string Kirp(string? m, int n) => (m ?? "").Length <= n ? m ?? "" : m![..n];

    private sealed record OturumDurumu(short Durum, int KullaniciId, int BankoId);

    private static async Task<OturumDurumu> DurumAsync(
        NpgsqlConnection b, long id, int subeId, CancellationToken iptal)
        => await b.TekAsync("""
               select durum, kullanici_id, banko_id from public.banko_oturum
                where id = @p0 and sube_id = @p1
               """, null, [id, subeId],
               o => new OturumDurumu(o.GetInt16(0), o.GetInt32(1), o.GetInt32(2)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Oturum bulunamadı.");

    private static async Task KupurYazAsync(NpgsqlConnection b, NpgsqlTransaction islem, long id,
        short asama, IReadOnlyList<KupurSatiri>? kupurler, int kullanici, CancellationToken iptal)
    {
        if (kupurler is null) return;
        foreach (var k in kupurler)
        {
            // Sıfır adet satırı yazılmaz: döküm "hangi kupürden kaç tane"
            //   bilgisidir, boş satır gürültüdür.
            if (k.Birim is not > 0 || k.Adet is not > 0) continue;
            await b.CalistirAsync("""
                insert into public.banko_oturum_kupur (oturum_id, asama, birim, adet, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4)
                """, islem, [id, asama, k.Birim, k.Adet, kullanici], iptal);
        }
    }

    /// <summary>
    /// FARK FİŞİ (988, mockup banko_gun_sonu_kasa_teslimi.html "Fark Fişini
    /// Oluştur"): sayım farkı ayrı bir kasa işlemiyle muhasebeleşir - kasa
    /// bakiyesi sayıma çekilir, fark geçmişi bozulmaz ve ertesi gün aynı fark
    /// devretmez.
    ///
    /// NOKSAN = kasadan çıkış, FAZLA = kasaya giriş. Karşı hesap kurum ayarından
    /// (`banko.fark_hesap_id`); tanımlı değilse fiş ÜRETİLMEZ ve kullanıcıya
    /// söylenir - gün sonunu bloke etmek yerine (banko kapanmalı) eksik ayarı
    /// bildirmek doğru.
    ///
    /// Fiş oturuma bağlanır (<c>oturum_id</c>, <c>kaynak_tur</c> = 1385) ama
    /// oturum sayaçlarına GİRMEZ: gün içi sayaçlar "banko ne tahsil etti"
    /// sorusunu yanıtlıyor, düzeltme fişi oraya karışırsa rakamlar tutmaz.
    /// </summary>
    private static async Task<string> FarkFisiAsync(NpgsqlConnection b, NpgsqlTransaction islem,
        long oturumId, int bankoId, int? kasaHesapId, decimal fark, short neden, string? aciklama,
        IstekBaglami baglam, CancellationToken iptal)
    {
        if (fark == 0) return "";
        if (kasaHesapId is not > 0)
            return " Fark fişi üretilmedi: bankonun kasa hesabı tanımlı değil.";

        var karsi = await AyarAsync(b, islem, "banko.fark_hesap_id", iptal);
        if (!int.TryParse(karsi, out var karsiHesap) || karsiHesap <= 0)
            return " Fark fişi üretilmedi: \"Kasa sayım farkı hesabı\" (banko.fark_hesap_id) tanımlı değil.";

        var turAnahtar = fark > 0 ? "banko.fark_tur_fazla" : "banko.fark_tur_noksan";
        var tur = short.TryParse(await AyarAsync(b, islem, turAnahtar, iptal), out var t)
                  ? t : (short)(fark > 0 ? 3 : 4);

        var not = $"Kasa sayım farkı - banko oturumu #{oturumId}"
                  + (FarkNedenleri.TryGetValue(neden, out var ad) ? $" ({ad})" : "")
                  + (string.IsNullOrWhiteSpace(aciklama) ? "" : $": {aciklama}");

        var fisId = await b.TekDegerAsync<long>("""
            insert into public.kasa_islem
                   (tur, islem_tarihi, durum, hesap_id, karsi_hesap_id, doviz_cinsi,
                    tutar, doviz_kuru, yerel_tutar, kaynak_tur, kaynak_id, oturum_id,
                    aciklama, sube_id, ekleyen)
            values (@p0, now(), 1, @p1, @p2, 'TL', @p3, 1, @p3, 1385, @p4, @p4,
                    @p5, @p6, @p7)
            returning id
            """, islem,
            [tur, kasaHesapId, karsiHesap, Math.Abs(fark), oturumId,
             Kirp(not, 300), baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

        await b.CalistirAsync(
            "update public.banko_oturum set fark_islem_id = @p1 where id = @p0",
            islem, [oturumId, (int)fisId], iptal);

        return $" Fark fişi oluşturuldu (#{fisId}, {Math.Abs(fark):N2} ₺ "
               + (fark > 0 ? "fazla" : "noksan") + ").";
    }

    private static async Task<string> AyarAsync(NpgsqlConnection b, NpgsqlTransaction islem,
                                                string anahtar, CancellationToken iptal)
        => await b.TekDegerAsync<string>("select deger from public.referans where anahtar = @p0",
                                         islem, [anahtar], iptal) ?? "";

    /// <summary>Fark nedeni kodları - `banko_oturum.fark_neden`.</summary>
    private static readonly Dictionary<short, string> FarkNedenleri = new()
    {
        [1] = "Para üstü hatası", [2] = "Eksik tahsilat", [3] = "Fazla tahsilat",
        [4] = "Kayıt dışı ödeme", [5] = "Sayım hatası", [99] = "Diğer",
    };

    /// <summary>Tutanak no: TT-yyyy-nnnnnn, yıl içinde sıralı.</summary>
    private static async Task<string> TutanakNoAsync(NpgsqlConnection b, NpgsqlTransaction islem,
                                                     CancellationToken iptal)
    {
        var n = await b.TekDegerAsync<int>("""
            select coalesce(max(nullif(split_part(tutanak_no, '-', 3), '')::int), 0) + 1
              from public.banko_oturum
             where tutanak_no like 'TT-' || to_char(now(), 'YYYY') || '-%'
            """, islem, [], iptal);
        return $"TT-{DateTime.Now:yyyy}-{n:000000}";
    }

    private static async Task<OturumOzeti?> OturumAsync(NpgsqlConnection b, string kosul,
        object?[] par, CancellationToken iptal)
        => await b.TekAsync($"""
               select o.id, o.banko_id, o.banko_kod, o.banko_ad, o.kullanici_id, o.vardiya,
                      o.durum, o.devir_tutar, o.acilis_sayim, o.acilis_fark, o.acilis_not,
                      o.acilis_talep_ts,
                      o.acilis_ts, o.acilis_onay_id, o.acilis_onay_ts, o.red_neden,
                      o.nakit_tahsilat, o.nakit_iade, o.pos_tutar, o.banka_tutar, o.islem_adet,
                      o.beklenen_nakit, o.kapanis_sayim, o.kapanis_beklenen, o.kapanis_fark,
                      o.fark_neden, o.fark_aciklama, o.kasada_birakilan, o.teslim_edilen,
                      o.teslim_alan_id, o.kapanis_talep_ts, o.kapanis_ts, o.kapanis_onay_id,
                      o.tutanak_no, o.acilis_onay, o.gun_sonu_onay, o.kupur_dokumu,
                      o.banko_devir_hedef, o.hesap_id, o.fark_islem_id, o.cek_tutar,
                      coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as gorevli
                 from public.v_banko_oturum_ozet o
                 left join public.taraf t on t.id = o.kullanici_id
                 {kosul}
               """, null, par, o => new OturumOzeti(
                   o.GetInt64(0), o.GetInt32(1), o.GetString(2), o.GetString(3), o.GetInt32(4),
                   o.GetString(5), o.GetInt16(6), o.GetDecimal(7), o.GetDecimal(8), o.GetDecimal(9),
                   o.GetString(10), o.GetDateTime(11),
                   o.IsDBNull(12) ? null : o.GetDateTime(12),
                   o.IsDBNull(13) ? null : o.GetInt32(13),
                   o.IsDBNull(14) ? null : o.GetDateTime(14), o.GetString(15),
                   o.GetDecimal(16), o.GetDecimal(17), o.GetDecimal(18), o.GetDecimal(19),
                   o.GetInt64(20), o.GetDecimal(21), o.GetDecimal(22), o.GetDecimal(23),
                   o.GetDecimal(24), o.GetInt16(25), o.GetString(26), o.GetDecimal(27),
                   o.GetDecimal(28), o.IsDBNull(29) ? null : o.GetInt32(29),
                   o.IsDBNull(30) ? null : o.GetDateTime(30),
                   o.IsDBNull(31) ? null : o.GetDateTime(31),
                   o.IsDBNull(32) ? null : o.GetInt32(32), o.GetString(33),
                   o.GetInt16(34) == 1, o.GetInt16(35) == 1, o.GetInt16(36) == 1,
                   o.GetDecimal(37), o.IsDBNull(38) ? null : o.GetInt32(38),
                   o.IsDBNull(39) ? null : o.GetInt32(39), o.GetDecimal(40),
                   o.GetString(41)), iptal);

    public sealed record OturumOzeti(
        long Id, int BankoId, string BankoKod, string BankoAd, int KullaniciId, string Vardiya,
        short Durum, decimal DevirTutar, decimal AcilisSayim, decimal AcilisFark, string AcilisNot,
        DateTime AcilisTalepTs, DateTime? AcilisTs, int? AcilisOnayId, DateTime? AcilisOnayTs, string RedNeden,
        decimal NakitTahsilat, decimal NakitIade, decimal PosTutar, decimal BankaTutar,
        long IslemAdet, decimal BeklenenNakit, decimal KapanisSayim, decimal KapanisBeklenen,
        decimal KapanisFark, short FarkNeden, string FarkAciklama, decimal KasadaBirakilan,
        decimal TeslimEdilen, int? TeslimAlanId, DateTime? KapanisTalepTs, DateTime? KapanisTs,
        int? KapanisOnayId, string TutanakNo, bool AcilisOnay, bool GunSonuOnay, bool KupurDokumu,
        decimal BankoDevirHedef, int? HesapId, int? FarkIslemId, decimal CekTutar,
        string Gorevli);

    public sealed record KupurSatiri(decimal? Birim, int? Adet);
    public sealed record PosEslesmeSatiri(int? BankoPosId, decimal? CihazToplam,
                                          bool? UlasilamadiMi, string? Aciklama);
    public sealed record PosEslesmeIstegi(List<PosEslesmeSatiri>? Satirlar);
    public sealed record AcIstegi(int? BankoId, string? Vardiya, decimal? AcilisSayim, string? Not,
                                  List<KupurSatiri>? Kupurler);
    public sealed record OnayIstegi(string? Not);
    public sealed record GunSonuIstegi(decimal? KapanisSayim, short? FarkNeden, string? FarkAciklama,
                                       decimal? KasadaBirakilan, int? TeslimAlanId,
                                       List<KupurSatiri>? Kupurler);
}
