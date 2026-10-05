using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE AKIŞI (409, Faz 1) — hekimin iki düğmesi.
///
/// Kartın alanlarını kaydetmek genel kart ucundan yürür; burada olan şey
/// DURUM GEÇİŞİdir ve geçişin kuralları vardır:
///
/// <para><b>Muayeneye Al</b> başlangıç zamanını yazar. Bu zaman USS "Muayene
/// Başlangıç" alanıdır ve kartın açılma zamanıyla aynı değildir: kart sabah
/// açılıp hasta öğleden sonra girebilir. İkinci kez basmak zamanı EZMEZ -
/// yoksa "hasta ne zaman girdi" sorusunun cevabı her tıklamada değişirdi.</para>
///
/// <para><b>Tamamla</b> kaydı kilitler, başvuruyu tahakkuka döndürür ve
/// e-Nabız kuyruğuna atar. Bu yüzden eksik kayıtta reddedilir: ana tanı,
/// şikayet ve karar zorunludur. Kontrolü gönderim anına bırakmak, hatayı
/// hekim ekrandan ayrıldıktan çok sonra geri getirirdi.</para>
/// </summary>
public static partial class MuayeneUclari
{
    public static void MuayeneUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/muayene").WithTags("Muayene").RequireAuthorization();

        // UÇLAR KONU BAŞINA AYRI DOSYADA (partial): tek metotta 29 uç ve 1748
        //   satır vardı, hangi ucun hangi ekranı beslediği okunmuyordu.
        TamamlaUclariniEkle(grup);
        SekmeUclariniEkle(grup);
        RaporUclariniEkle(grup);
        TaniUclariniEkle(grup);
        YzUclariniEkle(grup);
        IstemUclariniEkle(grup);

        // POST /api/muayene/{id}/al - "Muayeneye Al"
        // GET /api/muayene/ozet?gun=YYYY-MM-DD - LISTE OZET SERIDI (461)
        //
        // Mockup `muayene_listesi.html` ustundeki alti kutu: poliklinigin o
        //   gunku hali. Tek uctan gelir - alti ayri istek ekranin yarisini
        //   dolu yarisini bos gosterirdi (radyoloji/lab panosu deseni).
        //
        // SAYILAR SUBEYE SUZULUR: baska subenin poliklinigi bu ekranin isi
        //   degil; yetki katmani zaten subeyi baglama koyuyor.
        grup.MapGet("/ozet", async (
            string? gun, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            var tarih = DateTime.TryParse(gun, out var t) ? t.Date : DateTime.Today;
            var sube = baglam.SubeId ?? 0;

            await using var baglanti = await veri.AcAsync(iptal);

            var sayac = await baglanti.TekAsync("""
                select
                  count(*)                                        as "muayene",
                  count(*) filter (where m.durum = 1)             as "acik",
                  count(*) filter (where m.durum = 2)             as "tamamlanan",
                  -- ORTALAMA SURE yalniz TAMAMLANANLARDA anlamli: acik
                  --   muayenenin suresi "simdiye kadar" demek, ortalamayi
                  --   suni sekilde buyutur.
                  coalesce(round(avg(extract(epoch from (m.tamamlanma - m.baslangic)) / 60)
                           filter (where m.durum = 2 and m.baslangic is not null
                                     and m.tamamlanma is not null)), 0) as "ortDk",
                  -- BEKLEYEN: muayeneye hic alinmamis kayit (baslangic bos).
                  count(*) filter (where m.baslangic is null and m.durum = 1) as "bekleyen",
                  coalesce(max(extract(epoch from (now() - m.ekleme_tarihi)) / 60)
                           filter (where m.baslangic is null and m.durum = 1), 0)::int
                                                                  as "enUzunBeklemeDk",
                  -- TANI GIRILMEMIS: tamamlanmis ama tanisi olmayan muayene -
                  --   basvuru tahakkuka dusmez, e-Nabiz paketi eksik alanda kalir.
                  count(*) filter (where m.durum = 2 and not exists
                      (select 1 from public.tani ta where ta.muayene_id = m.id))
                                                                  as "tanisiz"
                  from public.muayene m
                 where m.muayene_tarihi >= @p0 and m.muayene_tarihi < @p0 + interval '1 day'
                   and (@p1 = 0 or m.sube_id = @p1)
                """, null, [tarih, sube], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SONUC: bugun ONAYLANAN lab satiri ve raporlanan radyoloji -
            //   "sonuc geldi" bilgisi hekimin siradaki isini belirler.
            var sonuc = await baglanti.TekAsync("""
                select
                  (select count(*) from public.lab_sonuc s
                    where s.onay_zamani >= @p0 and s.onay_zamani < @p0 + interval '1 day') as "lab",
                  (select count(*) from public.radyoloji_rapor r
                    where r.onay_tarihi >= @p0
                      and r.onay_tarihi < @p0 + interval '1 day') as "radyoloji",
                  (select count(*) from public.lab_istem_satir ls
                     join public.lab_istem li on li.id = ls.istem_id
                    where ls.durum in (1, 2) and li.istem_tarihi >= @p0 - interval '7 days')
                                                                             as "bekleyenTetkik"
                """, null, [tarih], OkuyucuGenisletmeleri.Sozluk, iptal);

            // e-NABIZ: bugunku muayene paketleri (kaynak_tur = 2) kacinci
            //   gonderildi. Bildirim yukumlulugu gun icinde izlenmeli.
            var enabiz = await baglanti.TekAsync("""
                select count(*) as "toplam",
                       count(*) filter (where p.durum = 3) as "gonderilen"
                  from public.enabiz_paket p
                 where p.kaynak_tur = 2 and p.uretim_tarihi >= @p0
                   and p.uretim_tarihi < @p0 + interval '1 day'
                   and (@p1 = 0 or p.sube_id = @p1)
                """, null, [tarih, sube], OkuyucuGenisletmeleri.Sozluk, iptal);

            var randevu = await baglanti.TekAsync("""
                select count(*) as "randevu",
                       count(*) filter (where r.durum = 4) as "gelmedi"
                  from public.randevu r
                 where r.baslangic >= @p0 and r.baslangic < @p0 + interval '1 day'
                   and (@p1 = 0 or r.sube_id = @p1)
                """, null, [tarih, sube], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                gun = tarih.ToString("yyyy-MM-dd"),
                sayac, sonuc, enabiz, randevu, izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPost("/{id:int}/al", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            // coalesce: ikinci tikta zaman EZILMEZ.
            var zaman = await veri.TekDegerAsync<DateTime?>("""
                update public.muayene
                   set baslangic = coalesce(baslangic, now()),
                       durum = case when durum = 0 then 1 else durum end,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning baslangic
                """, [id, baglam.KullaniciId], iptal);

            if (zaman is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            return Results.Ok(new { id, baslangic = zaman,
                                    mesaj = $"Muayeneye alindi ({zaman:HH:mm}).",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/sira/cagir - "Sıradakini Çağır" / seçili hastayı çağır
        //   Sıra kuralı SQL'de (fn_siradaki_hasta): önce öncelik, sonra kayıt
        //   sırası. İstemcinin sırayı hesaplaması, iki hekimin aynı anda
        //   basmasında aynı hastayı iki kez çağırmak olurdu.
        grup.MapPost("/sira/cagir", async (
            CagirIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var belgeId = istek?.BelgeId ?? 0;
            if (belgeId == 0)
            {
                var hekim = istek?.HekimId ?? 0;
                if (hekim == 0)
                    throw GentegreHatasi.Dogrulama("Hekim secilmeli.",
                        [new("hekimId", "Siradakini cagirmak icin hekim gerekli.")]);

                belgeId = await baglanti.TekDegerAsync<int>(
                    "select coalesce(public.fn_siradaki_hasta(@p0, @p1), 0)",
                    islem, [hekim, baglam.SubeId], iptal);
                if (belgeId == 0)
                    return Results.Ok(new { belgeId = 0, mesaj = "Bekleyen hasta yok.",
                                            izlemeNo = baglam.IzlemeNo });
            }

            // Cagirma zamani IKINCI TIKTA EZILMEZ: bekleme suresi olcusu
            //   cagirma anindan hesaplaniyor, tekrar cagirmak onu bozmamali.
            //   Tekrar cagirma yine de anons icin gecerli bir istektir.
            var kayit = await baglanti.TekAsync("""
                update public.belge_basvuru bb
                   set cagirma_zamani = coalesce(bb.cagirma_zamani, now()),
                       cagiran_id = coalesce(bb.cagiran_id, @p1),
                       degistiren = @p1, degistirme_tarihi = now()
                 where bb.id = @p0
                returning bb.cagirma_zamani, bb.sira_no,
                          (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan from public.belge b
                             join public.taraf t on t.id = b.taraf_id where b.id = bb.id)
                """, islem, [belgeId, baglam.KullaniciId], o => new
                {
                    Zaman = o.GetDateTime(0), SiraNo = o.GetString(1),
                    Hasta = o.IsDBNull(2) ? "" : o.GetString(2),
                }, iptal);

            if (kayit is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Basvuru bulunamadi." } });

            await islem.CommitAsync(iptal);

            // Bekleme ekraninda KISALTILMIS ad gosterilir (KVKK): salonda
            //   herkesin duydugu bir listede tam ad okunmamali.
            return Results.Ok(new { belgeId, kayit.SiraNo, cagirma = kayit.Zaman,
                                    hasta = kayit.Hasta, ekranAdi = AdiKisalt(kayit.Hasta),
                                    mesaj = $"{kayit.Hasta} cagrildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/basvuru/{belgeId}/al - "Muayeneye Al"
        //   Muayene kaydi YOKSA ACILIR: hekim once "muayene ekle" deyip sonra
        //   hastayi secmek zorunda kalmasin - kart basvurudan turer.
        grup.MapPost("/basvuru/{belgeId:int}/al", async (
            int belgeId, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici enabiz,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.taraf_id, bb.personel_id, bb.bolum_id, b.sube_id,
                       (select m.id from public.muayene m
                         where m.belge_id = b.id and m.ust_muayene_id is null)
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0 and b.tur = 19
                 for update of b
                """, islem, [belgeId], o => new
                {
                    TarafId = o.GetInt32(0),
                    PersonelId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    BolumId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    SubeId = o.GetInt32(3),
                    MuayeneId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                }, iptal);

            if (b is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Basvuru bulunamadi." } });

            // MUAYENE NO AYARDAN (634): `numara_sablonu` tur 902 satiri varsa
            //   numara verilir, yoksa BOS kalir - bugunku davranis. Kolon
            //   bastan beri vardi ama hic doldurulmuyordu; numarasi olmayan
            //   bir alana kendiliginden numara basmak, kurumun istemedigi bir
            //   kimligi kayitlara yazmak olurdu.
            var muayeneId = b.MuayeneId ?? await baglanti.TekDegerAsync<int>("""
                insert into public.muayene (belge_id, taraf_id, sube_id, bolum_id, personel_id,
                                            muayene_tarihi, tur, durum, ekleyen, muayene_no)
                values (@p0, @p1, @p2, @p3, @p4, now(), 1, 1, @p5,
                        public.fn_numara_kimlik_uret(902, @p2, 'muayene', 'muayene_no', current_date))
                returning id
                """, islem, [belgeId, b.TarafId, b.SubeId, b.BolumId, b.PersonelId,
                             baglam.KullaniciId], iptal);

            // Cagirilmadan "Muayeneye Al" denirse cagirma zamani da yazilir:
            //   hasta zaten iceride, bekleme suresi o an bitmistir.
            await baglanti.CalistirAsync("""
                update public.belge_basvuru
                   set cagirma_zamani = coalesce(cagirma_zamani, now()),
                       cagiran_id = coalesce(cagiran_id, @p1)
                 where id = @p0
                """, islem, [belgeId, baglam.KullaniciId], iptal);

            var baslangic = await baglanti.TekDegerAsync<DateTime>("""
                update public.muayene
                   set baslangic = coalesce(baslangic, now()),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning baslangic
                """, islem, [muayeneId, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // e-NABIZ 101 HASTA KAYIT: kabul paketi. Basvuru acilirken degil
            //   MUAYENEYE ALINIRKEN uretilir - kayit kabulde hekim/klinik
            //   henuz kesin degil, paket eksik alanla acilirdi.
            try { await enabiz.UretAsync("HASTA_KABUL", belgeId, baglam.KullaniciId, iptal); }
            catch (Exception h)
            {
                ctx.RequestServices.GetRequiredService<ILoggerFactory>()
                   .CreateLogger("enabiz").LogError(h,
                       "e-Nabiz 101 paketi uretilemedi (basvuru {Id})", belgeId);
            }

            return Results.Ok(new { belgeId, muayeneId, baslangic,
                                    yeni = b.MuayeneId is null,
                                    mesaj = $"Muayeneye alindi ({baslangic:HH:mm}).",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Bulgulardan MUAYENE ÖZETİ metnini derler ve karta yazar.
    ///
    /// Kural: alan "normal" işaretliyse şablonun hazır cümlesi, değilse
    /// hekimin yazdığı metin. Sistem başlığı (grup) satırın önüne düşer -
    /// rapor okunurken hangi sistemin anlatıldığı belli olsun.
    ///
    /// Boş bırakılan ve normal işaretlenmemiş alan metne HİÇ GİRMEZ: "Batın:"
    /// diye boş bir satır, muayene edilmediğini değil özensizliği gösterirdi.
    /// </summary>
    private sealed record TamamlamaVerisi(short Durum, int? BelgeId, string Sikayet, string Karar,
        long AnaTani, long BekleyenIstem, bool Baslatildi, string CikisKodu, string Takip,
        long Istem, long Recete);

    /// <summary>Tamamlama kuralinin okudugu alanlar (Tamamla'da satir kilitli).</summary>
    private static Task<TamamlamaVerisi?> TamamlamaVerisiAsync(Npgsql.NpgsqlConnection baglanti,
        Npgsql.NpgsqlTransaction? islem, int id, bool kilitle, CancellationToken iptal) =>
        baglanti.TekAsync("""
            select m.durum, m.belge_id, btrim(m.sikayet), btrim(m.karar),
                   (select count(*) from public.tani t
                     where t.muayene_id = m.id and t.tur = 1),
                   (select count(*) from public.muayene_istem s
                     where s.muayene_id = m.id and s.sonuc_durum in (0, 1)),
                   -- e-NABIZ 103/106'NIN ZORUNLU ALANLARI (628):
                   --   baslangic zamani, cikis sekli ve basvurunun
                   --   SYS takip numarasi.
                   (m.baslangic is not null),
                   coalesce(public.fn_skrs_kod('cikis.sekli', m.cikis_sekli), ''),
                   coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                              where bb.id = m.belge_id), ''),
                   -- KONTROL LISTESI BILGI MADDELERI (istem / recete): zorunlu
                   --   degil, ozet sekmesinde "yapildi mi" diye gorunur.
                   (select count(*) from public.muayene_istem s where s.muayene_id = m.id),
                   (select count(*) from public.recete r
                     where r.muayene_id = m.id and r.durum <> 4
                       and exists (select 1 from public.recete_satir rs where rs.recete_id = r.id))
              from public.muayene m where m.id = @p0
            """ + (kilitle ? " for update" : ""), islem, [id], o => new TamamlamaVerisi(
                o.GetInt16(0), o.IsDBNull(1) ? null : o.GetInt32(1),
                o.GetString(2), o.GetString(3), o.GetInt64(4), o.GetInt64(5),
                o.GetBoolean(6), o.GetString(7), o.GetString(8),
                o.GetInt64(9), o.GetInt64(10)), iptal);

    /// <summary>
    /// TAMAMLAMA KURALI (muayene sureci, adim 10) - TEK YER. Tamam olanlar da
    /// listede: ozet sekmesi kontrol listesini buradan cizer, Tamamla
    /// tamam olmayan ZORUNLU maddeleri tek seferde reddeder. Zorunlu=false
    /// maddeler (istem, recete) yalniz bilgidir: her muayenede olmazlar.
    /// </summary>
    private static async Task<List<(string Alan, string Ad, bool Tamam, string Mesaj, bool Zorunlu)>> TamamlamaKontrolleriAsync(
        Npgsql.NpgsqlConnection baglanti, Npgsql.NpgsqlTransaction? islem, int id,
        TamamlamaVerisi m, CancellationToken iptal)
    {
        // SIRA HEKIMIN IS AKISI (kullanici): muayeneye al > sikayet/hikaye >
        //   ana tani > istem > recete > degerlendirme/sonuc > cikis sekli.
        var k = new List<(string Alan, string Ad, bool Tamam, string Mesaj, bool Zorunlu)>
        {
            ("baslangic", "Muayeneye alındı", m.Baslatildi,
                "Muayene baslatilmamis - 'Muayeneye Al' ile baslangic zamani yazilmali.", true),
            ("sikayet", "Şikâyet / Hikâye", m.Sikayet.Length > 0, "Sikayet zorunlu.", true),
            ("tanilar", "Ana tanı", m.AnaTani > 0, "Ana tani zorunlu.", true),
            ("istem", "İstem", m.Istem > 0, "Bu muayenede istem yok.", false),
            ("recete", "Reçete", m.Recete > 0, "Bu muayenede reçete yok.", false),
            ("karar", "Değerlendirme / Sonuç", m.Karar.Length > 0, "Degerlendirme / sonuc zorunlu.", true),
            ("cikisSekli", "Çıkış şekli", m.CikisKodu.Length > 0,
                "Cikis sekli secilmeli (e-Nabiz cikis bildiriminin zorunlu alani).", true),
        };
        // e-NABIZ'IN ZORUNLU ALANLARI DA BURADA DURDURUR (628): listedeki
        //   "Muayeneye alındı" ve "Çıkış şekli" maddeleri.
        //
        // 103 ve 106 muayene tamamlanirken uretilir; USS o paketleri
        //   eksik alanla REDDEDIYOR ve hata hekime SAATLER SONRA, kuyruk
        //   ekraninda donuyordu - o sirada muayene kilitli ve duzeltmek
        //   icin geri acmak gerekiyor. Kontrol tamamlama anina alindi:
        //     · MUAYENE_BASLANGIC_TARIHI (103) -> muayeneye alinmis olmali
        //     · CIKIS_SEKLI (106)              -> SKRS listesinde gecerli kod
        //   Gercek vaka: CIKIS_SEKLI bos gonderildi, "E1014 ... eksik
        //   elemanlar var: CIKIS_SEKLI" (paket 652).
        // BÖLÜM / DOKTOR ŞABLON KURALLARI (931) - aynı listeye, tek seferde.
        foreach (var e in await MuayeneSablonUclari.KuralEksikleriAsync(baglanti, islem, id, iptal))
            k.Add((e.Alan, e.Mesaj, false, e.Mesaj, true));
        return k;
    }

    private static async Task<string> OzetDerleAsync(Npgsql.NpgsqlConnection baglanti,
        Npgsql.NpgsqlTransaction islem, int muayeneId, CancellationToken iptal)
    {
        var metin = await BulguMetniAsync(baglanti, islem, muayeneId, iptal);
        await baglanti.CalistirAsync(
            "update public.muayene set bulgu_ozet = @p1 where id = @p0",
            islem, [muayeneId, metin], iptal);
        return metin;
    }

    /// <summary>
    /// Bulgu satirlarindan metin - YAZMAZ. "Normal" isaretsiz VE bulgusu bos
    /// satir metne girmez (kullanici: "check yok ve edit girilmediyse ozete
    /// o satir gelmesin"); normal isaretli satir sablonun normal metniyle,
    /// bulgusu yazili satir yazilan bulguyla gelir.
    /// </summary>
    private static async Task<string> BulguMetniAsync(Npgsql.NpgsqlConnection baglanti,
        Npgsql.NpgsqlTransaction? islem, int muayeneId, CancellationToken iptal,
        string? satirJson = null)
    {
        // KAYNAK: kayitli satirlar ya da (ozet sekmesi) ekrandaki KAYDEDILMEMIS
        //   satirlar - bicim kurali ayni, tek yerde.
        var kaynak = satirJson is null
            ? "public.muayene_bulgu b"
            : "jsonb_to_recordset(@p1::jsonb) as b(sablon_alan_id int, normal int, "
              + "deger_metin text, deger_sayi numeric, taraf int)";
        var kosul = satirJson is null ? "b.muayene_id = @p0" : "true";
        var satirlar = await baglanti.ListeAsync("""
            select coalesce(nullif(a.grup, ''), a.ad) as baslik,
                   -- NORMAL ISARETLI: yazilan bulgu > sablonun normal metni > 'Doğal'
                   --   (normal metni tanimsiz isaretli satir ozetten DUSUYORDU).
                   case when b.normal = 1 then coalesce(nullif(btrim(b.deger_metin), ''),
                                                        nullif(a.normal_metni, ''), 'Doğal')
                        else coalesce(nullif(btrim(b.deger_metin), ''),
                                      case when b.deger_sayi is null then ''
                                           else b.deger_sayi::text || ' ' || a.birim end) end,
                   case b.taraf when 1 then 'Sag' when 2 then 'Sol'
                                when 3 then 'Bilateral' else '' end
              from {{KAYNAK}}
              join public.muayene_sablon_alan a on a.id = b.sablon_alan_id
             where {{KOSUL}}
             order by a.sira asc, a.id asc
            """.Replace("{{KAYNAK}}", kaynak).Replace("{{KOSUL}}", kosul),
            islem, satirJson is null ? [muayeneId] : [muayeneId, satirJson],
            o => (Baslik: o.GetString(0), Deger: o.GetString(1), Taraf: o.GetString(2)),
            iptal);

        return string.Join("\n", satirlar
            .Where(x => x.Deger.Trim().Length > 0)
            .Select(x => x.Taraf.Length > 0
                ? $"{x.Baslik} ({x.Taraf}): {x.Deger}"
                : $"{x.Baslik}: {x.Deger}"));
    }

    /// <summary>
    /// Muayeneden açılan istem.
    ///
    /// <c>Tur</c>: 1 lab · 2 görüntüleme · 3 konsültasyon · 4 işlem · 5 dış tetkik.
    /// Görüntülemede <c>HizmetId</c> zorunlu - radyoloji istemi hizmetsiz açılamaz.
    /// </summary>
    private sealed record YzHizmet(int Id, string Kod, string Ad);

    /// <summary>
    /// YZ önerilerinin ORTAK kapısı: yetki, model hazır mı, anonim bağlam
    /// (yetersizse doğrulama hatası), kontör izni, çağrı. Başarısız çağrı
    /// ücretlendirilmez; ücret <see cref="YzKontorDusAsync"/> ile, yanıt
    /// işlendikten sonra düşülür.
    /// </summary>
    private static async Task<(Servisler.YzTaniOnerisi.Baglam Bag, Servisler.ModelYaniti Yanit, decimal Ucret, int SureMs)> YzCagirAsync(
        IstekBaglami baglam, Npgsql.NpgsqlConnection b, Servisler.IModelSaglayici model, int muayeneId,
        string ozellik, Func<Servisler.YzTaniOnerisi.Baglam, string> sistem, CancellationToken iptal)
    {
        baglam.YetkiIste("muayene", Islem.Degistir);
        if (!model.Hazir)
            throw GentegreHatasi.IsKurali(
                "YZ modeli bu kurulumda yapılandırılmamış (API anahtarı yok); yöneticiye bildirin.");
        var bag = await Servisler.YzTaniOnerisi.Topla(b, muayeneId, iptal)
                  ?? throw GentegreHatasi.Bulunamadi();
        if (!bag.Yeterli)
            throw GentegreHatasi.Dogrulama("YZ önerisi için önce şikâyet, hikâye ya da muayene bulgusu girin.",
                [new("sikayet", "Şikâyet / hikâye / bulgu boş.")]);

        var kontor = await Servisler.RehberServisi.KontorDurumAsync(b, iptal, ozellik, baglam.KullaniciId);
        if (!kontor.Izin)
            throw GentegreHatasi.IsKurali(kontor.Sebep.Length > 0
                ? kontor.Sebep.Replace("cevaplar şimdilik katalog ve yardım belgelerinden üretiliyor", "YZ önerisi kullanılamıyor")
                              .Replace("cevaplar katalogdan üretiliyor", "YZ önerisi kullanılamıyor")
                : "YZ kullanımı bu kurulumda kapalı.");

        var kronometre = System.Diagnostics.Stopwatch.StartNew();
        var yanit = await model.IsteAsync(new Servisler.ModelIstegi(
            sistem(bag), Servisler.YzTaniOnerisi.KullaniciMetni(bag)), iptal);
        if (yanit is null)
        {
            // BAŞARISIZ ÇAĞRI da görünür (934): 0 tutarlı iz; kontör düşülmez.
            await Servisler.RehberServisi.BasarisizYazAsync(b, baglam, ozellik, muayeneId,
                (int)kronometre.ElapsedMilliseconds, "Modele ulaşılamadı / zaman aşımı - ücretlendirilmedi", iptal);
            throw GentegreHatasi.IsKurali("YZ modeline ulaşılamadı; biraz sonra tekrar deneyin (kontör düşülmedi).");
        }
        return (bag, yanit, kontor.Ucret, (int)kronometre.ElapsedMilliseconds);
    }

    /// <summary>Başarılı YZ önerisinin kontörü. Açıklama "YZ önerisi" ile başlar (günlük sınır sayacı).</summary>
    private static Task YzKontorDusAsync(Npgsql.NpgsqlConnection b, IstekBaglami baglam, decimal ucret,
        Servisler.ModelYaniti yanit, string ozellik, string ozet, int muayeneId, int sureMs, CancellationToken iptal)
        => Servisler.RehberServisi.KontorDusAsync(b, baglam, ucret, yanit.GirisJeton + yanit.CikisJeton, null,
               yanit.Model, iptal, $"YZ önerisi - {ozet}", ozellik, muayeneId, sureMs);

    public sealed record IstemIstegi(int Tur, int? HizmetId, int? Aciliyet, string? Aciklama,
                                     int[]? TetkikIdler, int[]? PanelIdler,
                                     /// <summary>Akılcı istem kararları (873).</summary>
                                     Servisler.LabServisi.AkilciKarar[]? Akilci = null,
                                     /// <summary>Göz görüntüleme (Tur 6, 974): goz.tetkik kodu ve göz (1 OD · 2 OS · 3 OU).</summary>
                                     short? GozTetkik = null, short? Goz = null);

    /// <summary>İstek gövdesi: belge verilmezse hekimin SIRADAKİ hastası çağrılır.</summary>
    public sealed record CagirIstegi(int? BelgeId, int? HekimId);

    /// <summary>Ozet onizlemesi icin ekrandaki bulgu satiri.</summary>
    public sealed record BulguSatiri(int SablonAlanId, bool Normal, string? DegerMetin,
        decimal? DegerSayi, int? Taraf);
    public sealed record BulguMetniIstegi(BulguSatiri[]? Satirlar);

    /// <summary>Vücut şeması: seçilen bölge adları + serbest not.</summary>
    public sealed record VucutSemasiIstegi(string[]? Bolgeler, string? Not);

    /// <summary>Tanı ekleme: ICD penceresinde seçili kesinlik (1 Kesin · 2 Ön) ve
    /// taraf; tür (SKRS tani.turu) isteğe bağlı. Tür verilmezse Ön tanı = tür 3,
    /// kesin tanıda ilk tanı ana, sonrakiler ek; taraf "—".</summary>
    public sealed record TaniEkleIstegi(short? Tur, short? Taraf, short? Kesinlik = null);

    /// <summary>Yeni rapor: Tür 1 İstirahat · 2 Sağlık durumu · 3 İlaç kullanım · 4 İş göremezlik.
    /// Modal ön bilgilerle açılır; tarih/gün/açıklama/ICD doldurulup kaydedilir.</summary>
    public sealed record RaporEkleIstegi(int Tur, int? AltTur, string? Baslangic,
                                         int? Gun, string? Bitis, string? Aciklama, string? IcdKod);

    /// <summary>
    /// Bekleme ekranı için adı kısaltır: "Ayşe Yılmaz" → "A. Y***".
    ///
    /// Salonda herkesin gördüğü bir ekranda tam ad okunmamalı; çağrılan kişi
    /// kendini tanısın yeter.
    /// </summary>
    private static string AdiKisalt(string ad)
    {
        var parcalar = (ad ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries);
        if (parcalar.Length == 0) return "";
        var bas = string.Join(" ", parcalar[..^1].Select(x => x[..1] + "."));
        var son = parcalar[^1];
        return (bas.Length > 0 ? bas + " " : "") + son[..1] + new string('*', Math.Min(3, son.Length));
    }
}
