using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GEBELİK DOSYASI VE GEBE İZLEMİ (900 — KTS maddesi H10, USS 221).
///
/// <para><b>İzlem dosyaya bağlıdır.</b> 221 paketi gebelik haftasını
/// istemiyor ama "kaçıncı izlem" ancak bir gebelik içinde anlamlı: dosyasız
/// izlem, iki ayrı gebeliğin kayıtlarını birbirine karıştırırdı.</para>
///
/// <para><b>Aynı anda tek açık dosya</b> (kısmi benzersiz index). Yeni
/// gebelik açmak için öncekinin sonuçlanması ya da iptal edilmesi gerekir -
/// 224 Gebelik Sonucu paketi bu kapanışın üzerine kurulacak.</para>
/// </summary>
public static class GebeIzlemUclari
{
    public sealed record DosyaIstegi(int TarafId, DateOnly? Sat, DateOnly? BeklenenDogum,
        short? GebelikNo, short? RiskDurumu, string? Aciklama,
        // 223 Gebelik Bildirim'in ZORUNLU ögesi (901): SKRS "bir önceki
        //   doğum durumu". Boşsa bildirim paketi üretilmez.
        short? OncekiDogum);

    public sealed record IzlemIstegi(int GebelikId, short KacinciIzlem, int? BelgeId,
        int? MuayeneId, short? IslemTuru, DateTime? IzlemTarihi,
        decimal? BoyCm, decimal? KiloKg, short? Sistolik, short? Diastolik,
        short? FetusKalpSesi, decimal? Hemoglobin, short? IdrarProtein, short? Gdm,
        short? Demir, short? DVitamini, short? Anomali,
        IReadOnlyList<short>? Riskler, string? Oneri, string? Aciklama);

    public sealed record KapatIstegi(DateOnly? SonucTarihi, string? Aciklama);

    /// <summary>
    /// GEBELİK SONUCU (902, USS 224). Sonuç YALNIZ DOĞUM DEĞİLDİR: düşük ve
    /// tıbbi tahliye de bildirilir - doğum yöntemi ve bebek sayıları yalnız
    /// doğumla sonuçlanan gebeliklerde dolar.
    /// </summary>
    public sealed record SonucIstegi(short Sonuc, DateTime? SonlanmaTarihi,
        int? BelgeId, short? DogumYontemi, short? DogumYeri, short? DogumaYardim,
        short? CanliBebek, short? OluBebek, short? SezaryanEndikasyon,
        short? EndikasyonNeden, string? Aciklama);

    public static void GebeIzlemUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/gebelik").WithTags("Gebelik").RequireAuthorization();

        // GET /api/gebelik/hasta/{id} - dosyalar + açık dosyanın izlemleri.
        grup.MapGet("/hasta/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("gebe.dosya", Islem.Gor);

            var dosyalar = await veri.ListeAsync("""
                select id, sat, beklenen_dogum as "beklenenDogum",
                       tahmini_dogum as "tahminiDogum", hafta,
                       gebelik_no as "gebelikNo", risk_durumu as "riskDurumu",
                       durum, sonuc_tarihi as "sonucTarihi",
                       izlem_sayisi as "izlemSayisi", aciklama,
                       onceki_dogum as "oncekiDogum",
                       bildirime_hazir as "bildirimeHazir"
                  from public.v_gebelik
                 where taraf_id = @p0
                 order by durum, id desc
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var acik = await veri.TekDegerAsync<int?>("""
                select id from public.gebelik where taraf_id = @p0 and durum = 1 limit 1
                """, [id], iptal);

            var izlemler = acik is null ? [] : await veri.ListeAsync("""
                select id, kacinci_izlem as "kacinciIzlem", izlem_tarihi as "izlemTarihi",
                       hafta, boy_cm as "boyCm", kilo_kg as "kiloKg",
                       sistolik, diastolik, fetus_kalp_sesi as "fetusKalpSesi",
                       hemoglobin, idrar_protein as "idrarProtein", gdm,
                       demir, d_vitamini as "dVitamini", anomali,
                       risk_sayisi as "riskSayisi", oneri, durum,
                       iptal_neden as "iptalNeden", enabiz_durum as "enabizDurum"
                  from public.v_gebe_izlem
                 where gebelik_id = @p0
                 order by kacinci_izlem desc, id desc
                """, [acik.Value], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sonraki = acik is null ? 1 : await veri.TekDegerAsync<int>("""
                select coalesce(max(kacinci_izlem), 0)::int + 1
                  from public.gebe_izlem where gebelik_id = @p0 and durum = 1
                """, [acik.Value], iptal);

            // SONUÇ KAYITLARI: kapanmış dosyaların 224 bilgisi ekranda
            //   görünsün - "kapandı ama bildirilmedi" fark edilebilmeli.
            var sonuclar = await veri.ListeAsync("""
                select id, gebelik_id as "gebelikId",
                       sonlanma_tarihi as "sonlanmaTarihi",
                       sonlanma_haftasi as "sonlanmaHaftasi", sonuc,
                       dogum_yontemi as "dogumYontemi",
                       canli_bebek as "canliBebek", olu_bebek as "oluBebek",
                       enabiz_durum as "enabizDurum", durum
                  from public.v_gebelik_sonuc
                 where taraf_id = @p0
                 order by sonlanma_tarihi desc
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { dosyalar, acikGebelikId = acik, izlemler, sonraki,
                                    sonuclar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gebelik - dosya açar.
        grup.MapPost("/", async (
            DosyaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("gebe.dosya", Islem.Ekle);

            // SAT ya da BEKLENEN DOĞUM: biri olmadan hafta hesaplanamaz ve
            //   izlem takvimi kurulamaz (veritabanı kısıtı da bunu tutuyor).
            if (istek.Sat is null && istek.BeklenenDogum is null)
                throw GentegreHatasi.Dogrulama(
                    "Son adet tarihi ya da beklenen doğum tarihi gerekli.",
                    [new("sat", "İkisinden biri girilmeli - hafta bundan hesaplanıyor.")]);

            try
            {
                var id = await veri.TekDegerAsync<int>("""
                    insert into public.gebelik
                           (taraf_id, sat, beklenen_dogum, gebelik_no, risk_durumu,
                            aciklama, onceki_dogum, sube_id, ekleyen)
                    values (@p0, @p1, @p2, coalesce(@p3, 1), coalesce(@p4, 0), @p5,
                            @p8, @p6, @p7)
                    returning id
                    """,
                    [istek.TarafId, istek.Sat, istek.BeklenenDogum, istek.GebelikNo,
                     istek.RiskDurumu, istek.Aciklama ?? "", baglam.SubeId ?? 0,
                     baglam.KullaniciId, istek.OncekiDogum], iptal);

                var hafta = await veri.TekDegerAsync<int?>("""
                    select hafta from public.v_gebelik where id = @p0
                    """, [id], iptal);

                return Results.Ok(new { id, hafta,
                    mesaj = hafta is null ? "Gebelik dosyası açıldı."
                                          : $"Gebelik dosyası açıldı ({hafta}. hafta).",
                    izlemeNo = baglam.IzlemeNo });
            }
            catch (Npgsql.PostgresException h) when (h.SqlState == "23505")
            {
                // AÇIK DOSYA ZATEN VAR: ikinci dosya, izlemlerin hangisine
                //   ait olduğunu belirsiz bırakırdı.
                throw GentegreHatasi.IsKurali(
                    "Bu hastanın açık bir gebelik dosyası zaten var; önce onu "
                    + "sonuçlandırın ya da iptal edin.");
            }
        });

        // POST /api/gebelik/{id}/kapat - dosyayı sonuçlandırır (224'ün yeri).
        grup.MapPost("/{id:int}/kapat", async (
            int id, KapatIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("gebe.dosya", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.gebelik
                   set durum = 2, sonuc_tarihi = coalesce(@p1, current_date),
                       aciklama = case when coalesce(@p2, '') = '' then aciklama else @p2 end,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, [id, istek.SonucTarihi, istek.Aciklama, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Açık gebelik dosyası bulunamadı.");

            // 224 GEBELİK SONUCU PAKETİ HENÜZ BAĞLI DEĞİL: doğum/düşük
            //   ayrıntısı (doğum şekli, bebek bilgileri) kayıt altında değil.
            //   Dosya kapanışı o paketin YERİDİR - açılışı ayrı iş.
            return Results.Ok(new { id,
                mesaj = "Gebelik dosyası sonuçlandırıldı. "
                      + "(Gebelik Sonucu paketi henüz gönderilmiyor - doğum kaydı gerekiyor.)",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gebelik/{id}/sonuc - gebelik sonucu + 224 paketi.
        //   Kayıt dosyayı KAPATIR: iki adımı ayrı bırakmak, kapanmış ama
        //   bildirilmemiş gebelikler üretirdi (`v_gebelik_sonucsuz` bunları
        //   zaten sayıyor).
        grup.MapPost("/{id:int}/sonuc", async (
            int id, SonucIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            EnabizTetikleyici tetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("gebe.sonuc", Islem.Ekle);

            int sonucId;
            try
            {
                sonucId = await veri.TekDegerAsync<int>("""
                    select public.fn_gebelik_sonucla(@p0, @p1, @p2, @p3)
                    """, [id, istek.Sonuc, istek.SonlanmaTarihi, baglam.KullaniciId],
                    iptal);
            }
            catch (Npgsql.PostgresException h) when (h.SqlState == "23505")
            {
                // BİR GEBELİĞİN TEK GEÇERLİ SONUCU OLUR.
                throw GentegreHatasi.IsKurali(
                    "Bu gebeliğin sonucu zaten kayıtlı.");
            }
            catch (Npgsql.PostgresException h) when (h.SqlState == "P0001")
            {
                throw GentegreHatasi.IsKurali(h.MessageText);
            }

            // Ayrıntılar ikinci adımda: doğumla sonuçlanmayan gebelikte
            //   bunların hepsi boş kalır.
            await veri.CalistirAsync("""
                update public.gebelik_sonuc
                   set belge_id = @p1, dogum_yontemi = @p2, dogum_yeri = @p3,
                       doguma_yardim = @p4, canli_bebek = @p5, olu_bebek = @p6,
                       sezaryan_endikasyon = @p7, endikasyon_neden = @p8,
                       aciklama = @p9
                 where id = @p0
                """,
                [sonucId, istek.BelgeId, istek.DogumYontemi, istek.DogumYeri,
                 istek.DogumaYardim, istek.CanliBebek, istek.OluBebek,
                 istek.SezaryanEndikasyon, istek.EndikasyonNeden,
                 istek.Aciklama ?? ""], iptal);

            await tetik.GebelikSonuclandiAsync(sonucId, baglam.KullaniciId, iptal);

            return Results.Ok(new { id = sonucId, gebelikId = id,
                mesaj = "Gebelik sonucu kaydedildi ve dosya kapatıldı.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gebelik/izlem - izlem kaydı + 221 paketi.
        grup.MapPost("/izlem", async (
            IzlemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            EnabizTetikleyici tetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("gebe.izlem", Islem.Ekle);

            var dosya = await veri.TekAsync("""
                select taraf_id, durum from public.gebelik where id = @p0
                """, [istek.GebelikId],
                o => new { TarafId = o.GetInt32(0), Durum = o.GetInt16(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Gebelik dosyası bulunamadı.");

            if (dosya.Durum != 1)
                throw GentegreHatasi.IsKurali(
                    "Kapanmış gebelik dosyasına izlem eklenemez.");

            int id;
            try
            {
                id = await veri.TekDegerAsync<int>("""
                    insert into public.gebe_izlem
                           (gebelik_id, taraf_id, belge_id, muayene_id, kacinci_izlem,
                            islem_turu, izlem_tarihi, boy_cm, kilo_kg, sistolik,
                            diastolik, fetus_kalp_sesi, hemoglobin, idrar_protein,
                            gdm, demir, d_vitamini, anomali, oneri, aciklama,
                            sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, coalesce(@p6, now()),
                            @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15,
                            @p16, @p17, @p18, @p19, @p20, @p21)
                    returning id
                    """,
                    [istek.GebelikId, dosya.TarafId, istek.BelgeId, istek.MuayeneId,
                     istek.KacinciIzlem, istek.IslemTuru, istek.IzlemTarihi,
                     istek.BoyCm, istek.KiloKg, istek.Sistolik, istek.Diastolik,
                     istek.FetusKalpSesi, istek.Hemoglobin, istek.IdrarProtein,
                     istek.Gdm, istek.Demir, istek.DVitamini, istek.Anomali,
                     istek.Oneri ?? "", istek.Aciklama ?? "", baglam.SubeId ?? 0,
                     baglam.KullaniciId], iptal);
            }
            catch (Npgsql.PostgresException h) when (h.SqlState == "23505")
            {
                throw GentegreHatasi.IsKurali(
                    $"Bu gebeliğin {istek.KacinciIzlem}. izlemi zaten kayıtlı.");
            }

            // RİSK FAKTÖRLERİ TEKRARLI: pakette [1], [2] ... olarak gider.
            var sira = (short)0;
            foreach (var r in (istek.Riskler ?? []).Distinct())
                await veri.CalistirAsync("""
                    insert into public.gebe_izlem_risk (izlem_id, risk, sira)
                    values (@p0, @p1, @p2) on conflict do nothing
                    """, [id, r, ++sira], iptal);

            await tetik.GebeIzlemiKaydedildiAsync(id, baglam.KullaniciId, iptal);
            // 223 GEBELİK BİLDİRİMİ (901): dosyanın kendi başvurusu yok,
            //   takip numarası izlemden geliyor - bu yüzden bildirim de
            //   izlemle birlikte üretiliyor. "Aynı içerik → aynı paket"
            //   sonraki izlemlerde yeni satır açmaz.
            await tetik.GebelikBildirimiAsync(istek.GebelikId, baglam.KullaniciId, iptal);

            var hafta = await veri.TekDegerAsync<int?>("""
                select hafta from public.v_gebe_izlem where id = @p0
                """, [id], iptal);

            return Results.Ok(new { id, hafta,
                mesaj = $"{istek.KacinciIzlem}. gebe izlemi kaydedildi"
                      + (hafta is null ? "." : $" ({hafta}. hafta)."),
                izlemeNo = baglam.IzlemeNo });
        });
    }
}
