using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE SEKMELERİ, ŞABLON VE BULGU METNİ — bkz. <c>MuayeneUclari</c>.
///
/// <para>Şablon uygulama, sekme verisi, önceki muayeneden kopyalama, "tümü normal",
/// vücut şeması ve özet derleme. Hepsi KART İÇİ yazma yollarıdır: kuralları
/// (kapalı muayeneye yazılamaz, şablonsuz bulgu girilemez) sunucuda durur,
/// ekran yalnız sonucu gösterir.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void SekmeUclariniEkle(RouteGroupBuilder grup)
    {
        // POST /api/muayene/{id}/sablon/{sablonId} - şablonu muayeneye uygula
        //   Şablon alanları bulgu satırı olarak AÇILIR, "normal" İŞARETSİZ
        //   (kullanıcı: "sistem tümüyle check olmadan gelmeli; istenirse
        //   hepsini işaretle butonuna basılmalı"). Hepsini normal yapmak
        //   hekimin bilinçli eylemi: "Tümü normal işaretle" (muayene.normal) -
        //   muayene edilmemiş sistem kendiliğinden "doğal" görünmesin.
        //   Var olan bulgular KORUNUR: şablon değiştirmek yazılmış bulguyu
        //   silmemeli.
        grup.MapPost("/{id:int}/sablon/{sablonId:int}", async (
            int id, int sablonId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var varMi = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.muayene where id = @p0", islem, [id], iptal);
            if (varMi == 0) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            var acilan = await baglanti.CalistirAsync("""
                insert into public.muayene_bulgu (muayene_id, sablon_alan_id, normal)
                select @p0, a.id, 0
                  from public.muayene_sablon_alan a
                 where a.sablon_id = @p1
                on conflict (muayene_id, sablon_alan_id) do nothing
                """, islem, [id, sablonId], iptal);

            await baglanti.CalistirAsync("""
                update public.muayene
                   set sablon_id = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, sablonId, baglam.KullaniciId], iptal);

            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, sablonId, acilan, bulguOzet = ozet,
                                    mesaj = $"{acilan} alan sablondan acildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/sekme-verisi - mockup'taki e-Reçete, Sevk /
        //   Konsültasyon, İşlem & Ücret ve Geçmiş sekmelerinin verisi.
        //
        //   TEK UÇ: dördü de aynı muayenenin çevresindeki kayıtlar ve hepsi
        //   sekme değiştikçe ayrı ayrı istenirse kart açılışı dört ek gidiş
        //   dönüş yapar. Yetki muayene üzerinden çözülür; her sorgu ya
        //   muayenenin kendisine ya da başvurusuna bağlıdır.
        grup.MapGet("/{id:int}/sekme-verisi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var m = await baglanti.TekAsync(
                "select m.belge_id, m.taraf_id, m.ust_muayene_id " +
                "  from public.muayene m where m.id = @p0",
                null, [id],
                o => new { BelgeId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0),
                           HastaId = o.GetInt32(1),
                           UstId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadi.");

            // e-REÇETE: reçete başlıkları + satırları. İlaç adı satırda SAKLI
            //   (ilaç kataloğu değişse bile yazılan ilaç değişmemeli).
            var receteler = await baglanti.ListeAsync(
                "select r.id, r.recete_no as \"receteNo\", r.tur, r.durum, " +
                "       r.aciklama, r.imza_zamani as \"imzaZamani\", " +
                "       r.medula_gonderim as \"medulaGonderim\", " +
                "       r.medula_sonuc as \"medulaSonuc\", r.ekleme_tarihi as \"tarih\", " +
                "       coalesce(p.ad, '') as hekim, " +
                "       (select count(*) from public.recete_satir s where s.recete_id = r.id) as ilac " +
                "  from public.recete r " +
                "  left join public.v_personel_lookup p on p.id = r.hekim_id " +
                " where r.muayene_id = @p0 order by r.id desc",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var receteSatirlari = await baglanti.ListeAsync(
                "select s.recete_id as \"receteId\", s.ilac_barkod as \"barkod\", " +
                "       s.ilac_ad as \"ilac\", s.doz, s.periyot, s.kullanim_sekli as \"kullanim\", " +
                "       s.sure_gun as \"sureGun\", s.kutu, s.aciklama, " +
                "       s.etkilesim_uyari as \"uyari\" " +
                "  from public.recete_satir s " +
                "  join public.recete r on r.id = s.recete_id " +
                " where r.muayene_id = @p0 order by s.recete_id desc, s.sira, s.id",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KONSÜLTASYON: bu muayeneden İSTENEN muayeneler (ust_muayene_id)
            //   ve varsa bu muayeneyi İSTEYEN muayene.
            var konsultasyonlar = await baglanti.ListeAsync(
                "select k.id, coalesce(d.ad, '') as bolum, coalesce(p.ad, '') as hekim, " +
                "       k.muayene_tarihi as tarih, k.durum, " +
                // SORU isteyen hekimin cumlesi, YANIT cevaplayanin karari:
                //   ikisi de alt muayenede durur (465) - yaniti "sonuc geldi
                //   mi" diye ayri bir yerde aramak gerekmesin.
                "       coalesce(k.konsultasyon_soru, '') as soru, " +
                "       coalesce(nullif(k.karar, ''), '') as yanit, " +
                "       k.tamamlanma as \"yanitZamani\", " +
                "       coalesce((select i.ad from public.tani t " +
                "                   join public.icd i on i.kod = t.icd_kod " +
                "                  where t.muayene_id = k.id and t.tur = 1 limit 1), '') as \"anaTani\" " +
                "  from public.muayene k " +
                "  left join public.v_departman_lookup d on d.id = k.bolum_id " +
                "  left join public.v_personel_lookup p on p.id = k.personel_id " +
                " where k.ust_muayene_id = @p0 order by k.id desc",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // İŞLEM & ÜCRET: başvuru belgesinin satırları - muayene, tetkik ve
            //   işlemlerin ücreti başvuruda toplanır (tahakkuk oradan çıkar).
            var islemler = m.BelgeId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync(
                    "select bs.id, coalesce(h.kod, '') as kod, " +
                    "       coalesce(h.ad, coalesce(st.ad, '')) as ad, " +
                    "       bs.adet, bs.birim_fiyat as \"birimFiyat\", bs.iskonto, " +
                    "       bs.tutar, bs.kdv, " +
                    "       bs.aciklama " +
                    "  from public.belge_satir bs " +
                    "  left join public.hizmet h on h.id = bs.hizmet_id " +
                    "  left join public.stok st on st.id = bs.stok_id " +
                    " where bs.belge_id = @p0 order by bs.sira, bs.id",
                    null, [m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // GEÇMİŞ: aynı hastanın diğer muayeneleri (en yeni önce).
            var gecmis = await baglanti.ListeAsync(
                "select g.id, g.muayene_tarihi as tarih, coalesce(d.ad, '') as bolum, " +
                "       coalesce(p.ad, '') as hekim, g.durum, " +
                "       coalesce(nullif(g.sikayet, ''), '') as sikayet, " +
                // OZET: hekimin KARARI (yoksa sikayet). Mockup "DM kontrolu;
                //   HbA1c 7,4; doz artirildi" - bir satirda o muayenenin ne
                //   oldugunu soyleyen metin.
                "       coalesce(nullif(g.karar, ''), nullif(g.sikayet, ''), '') as ozet, " +
                // TANILAR: tum ICD kodlari (ana tani once) - "E11.9 · I10".
                "       coalesce((select string_agg(t2.icd_kod, ' · ' order by t2.tur, t2.sira, t2.id) " +
                "                   from public.tani t2 where t2.muayene_id = g.id), '') as tanilar, " +
                "       coalesce((select i.ad from public.tani t " +
                "                   join public.icd i on i.kod = t.icd_kod " +
                "                  where t.muayene_id = g.id and t.tur = 1 limit 1), '') as \"anaTani\" " +
                "  from public.muayene g " +
                "  left join public.v_departman_lookup d on d.id = g.bolum_id " +
                "  left join public.v_personel_lookup p on p.id = g.personel_id " +
                " where g.taraf_id = @p1 and g.id <> @p0 " +
                " order by g.muayene_tarihi desc, g.id desc limit 50",
                null, [id, m.HastaId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // RECETENIN TANISI muayenenin tanisidir (mockup e-Recete basligi):
            //   ayri sorulacak bir sey degil - ana tani once.
            var tanilar = await baglanti.TekDegerAsync<string>(
                "select coalesce(string_agg(t.icd_kod, ' · ' order by t.tur, t.sira, t.id), '') " +
                "  from public.tani t where t.muayene_id = @p0", null, [id], iptal);

            return Results.Ok(new { muayeneId = id, belgeId = m.BelgeId,
                                    ustMuayeneId = m.UstId, tanilar,
                                    receteler, receteSatirlari, konsultasyonlar,
                                    islemler, gecmis, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/onceki-kopyala/{kaynakId}
        //   Mockup Geçmiş panelindeki "↺ kopyala": kronik hastanın önceki
        //   muayenesinden anamnez ve tanılar bu muayeneye taşınır.
        //
        //   BOŞ ALAN DOLDURULUR, YAZILAN EZİLMEZ: hekim şikâyeti yazdıktan
        //   sonra kopyalarsa kendi cümlesini kaybetmemeli. Tanılarda aynı ICD
        //   zaten varsa atlanır; ana tanı varken gelenler EK tanı olur.
        //
        //   FİZİK MUAYENE VE VİTAL KOPYALANMAZ: onlar O GÜNÜN ölçümüdür;
        //   geçen muayenenin bulgusunu bugüne yazmak kayıt uydurmaktır.
        grup.MapPost("/{id:int}/onceki-kopyala/{kaynakId:int}", async (
            int id, int kaynakId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            if (id == kaynakId)
                throw GentegreHatasi.Dogrulama("Muayene kendinden kopyalanamaz.");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // AYNI HASTA ŞARTI: başka hastanın anamnezini bu karta taşımak
            //   hasta karıştırmanın en sessiz yoludur.
            var ayniHasta = await baglanti.TekDegerAsync<int>(
                "select case when (select taraf_id from public.muayene where id = @p0) " +
                "          = (select taraf_id from public.muayene where id = @p1) " +
                "       then 1 else 0 end", islem, [id, kaynakId], iptal);
            if (ayniHasta != 1)
                throw GentegreHatasi.IsKurali("Kaynak muayene bu hastaya ait degil.");

            await baglanti.CalistirAsync(
                "update public.muayene m " +
                "   set sikayet = case when coalesce(trim(m.sikayet), '') = '' " +
                "                      then k.sikayet else m.sikayet end, " +
                "       hikaye = case when coalesce(trim(m.hikaye), '') = '' " +
                "                     then k.hikaye else m.hikaye end, " +
                "       ozgecmis_notu = case when coalesce(trim(m.ozgecmis_notu), '') = '' " +
                "                            then k.ozgecmis_notu else m.ozgecmis_notu end, " +
                "       soygecmis_notu = case when coalesce(trim(m.soygecmis_notu), '') = '' " +
                "                             then k.soygecmis_notu else m.soygecmis_notu end, " +
                "       aliskanlik_notu = case when coalesce(trim(m.aliskanlik_notu), '') = '' " +
                "                              then k.aliskanlik_notu else m.aliskanlik_notu end, " +
                "       degistiren = @p2, degistirme_tarihi = now() " +
                "  from public.muayene k " +
                " where m.id = @p0 and k.id = @p1",
                islem, [id, kaynakId, baglam.KullaniciId], iptal);

            var anaVar = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.tani where muayene_id = @p0 and tur = 1",
                islem, [id], iptal);

            var taniEklenen = await baglanti.CalistirAsync(
                "insert into public.tani (muayene_id, icd_kod, tur, kesinlik, kronik, " +
                "                         not_metni, ekleyen) " +
                "select @p0, t.icd_kod, " +
                "       case when @p2 > 0 then 2 else t.tur end, " +
                "       t.kesinlik, t.kronik, t.not_metni, @p3 " +
                "  from public.tani t " +
                " where t.muayene_id = @p1 " +
                "   and not exists (select 1 from public.tani v " +
                "                    where v.muayene_id = @p0 and v.icd_kod = t.icd_kod) " +
                " order by t.tur, t.sira, t.id",
                islem, [id, kaynakId, anaVar, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, kaynakId, taniEklenen,
                                    mesaj = $"Onceki muayeneden anamnez kopyalandi"
                                          + (taniEklenen > 0 ? $", {taniEklenen} tani eklendi." : "."),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/tumu-normal - açık bulgu satırlarını "normal"
        //   işaretle (mockup muayene_karti.html "Tümü normal işaretle").
        //   Hekim yalnızca SAPANI yazar; normalleri tek tek işaretlemek
        //   poliklinikte en çok tekrarlanan tıklamaydı.
        //   BULGU METNİ YAZILMIŞ SATIRA DOKUNULMAZ: "normal" demek yazılmış
        //   patolojik bulguyu geçersiz kılardı - orası hekimin kararı.
        grup.MapPost("/{id:int}/tumu-normal", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var varMi = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.muayene where id = @p0", islem, [id], iptal);
            if (varMi == 0) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            var isaretlenen = await baglanti.CalistirAsync(
                "update public.muayene_bulgu set normal = 1 " +
                " where muayene_id = @p0 and coalesce(normal, 0) = 0 " +
                "   and coalesce(trim(deger_metin), '') = ''",
                islem, [id], iptal);

            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, isaretlenen, bulguOzet = ozet,
                                    mesaj = isaretlenen == 0
                                        ? "Isaretlenecek bos bulgu satiri yok."
                                        : $"{isaretlenen} sistem normal isaretlendi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // VÜCUT ŞEMASI (kullanıcı: Şablon Muayene'de "Vücut şeması" düğmesi;
        //   seçim: "bölge seç, bulguya yaz"). Seçilen bölgeler + not şablonun
        //   VÜCUT ŞEMASI (tip 5) satırına yazılır: metin deger_metin'e (özete
        //   ve rapora giden), yapısal liste deger_json'a (pencere yeniden
        //   açılınca işaretli gelsin). Şablonda tip 5 satır yoksa şablona
        //   "Vücut şeması" alanı EKLENİR - bulgu satırı şablon alanı ister.
        grup.MapGet("/{id:int}/vucut-semasi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var json = await baglanti.TekDegerAsync<string>("""
                select coalesce((select b.deger_json::text
                                   from public.muayene_bulgu b
                                   join public.muayene_sablon_alan a on a.id = b.sablon_alan_id
                                  where b.muayene_id = @p0 and a.tip = 5
                                  order by b.id limit 1), '')
                """, null, [id], iptal) ?? "";
            var bolgeler = new List<string>();
            var not = "";
            if (json.Length > 0)
            {
                using var d = System.Text.Json.JsonDocument.Parse(json);
                if (d.RootElement.TryGetProperty("bolgeler", out var b) && b.ValueKind == System.Text.Json.JsonValueKind.Array)
                    bolgeler.AddRange(b.EnumerateArray().Select(x => x.GetString() ?? "").Where(x => x.Length > 0));
                if (d.RootElement.TryGetProperty("not", out var n)) not = n.GetString() ?? "";
            }
            return Results.Ok(new { id, bolgeler, not, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/{id:int}/vucut-semasi", async (
            int id, VucutSemasiIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            var bolgeler = (istek.Bolgeler ?? [])
                .Select(x => (x ?? "").Trim()).Where(x => x.Length > 0)
                .Distinct().ToList();
            var not = (istek.Not ?? "").Trim();
            if (bolgeler.Count > 40 || bolgeler.Any(x => x.Length > 60))
                throw GentegreHatasi.Dogrulama("Bölge listesi geçersiz.", [new("bolgeler", "En çok 40 bölge, her biri 60 karakter.")]);
            if (not.Length > 500)
                throw GentegreHatasi.Dogrulama("Not çok uzun.", [new("not", "En çok 500 karakter.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync(
                "select durum, sablon_id from public.muayene where id = @p0 for update",
                islem, [id], o => new { Durum = o.GetInt16(0), SablonId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Tamamlanmış muayenenin bulgusu değiştirilemez.");
            if (m.SablonId is null)
                throw GentegreHatasi.IsKurali("Önce muayene şablonu seçin ya da uygulayın.");

            var alanId = await baglanti.TekDegerAsync<int?>(
                "select id from public.muayene_sablon_alan where sablon_id = @p0 and tip = 5 order by sira, id limit 1",
                islem, [m.SablonId], iptal);
            if (alanId is null)
            {
                await baglanti.CalistirAsync("""
                    insert into public.muayene_sablon_alan (sablon_id, kod, ad, tip, sira, ekleyen)
                    values (@p0, 'vucutsema', 'Vücut şeması', 5,
                            coalesce((select max(sira) from public.muayene_sablon_alan where sablon_id = @p0), 0) + 1,
                            @p1)
                    on conflict (sablon_id, kod) do nothing
                    """, islem, [m.SablonId, baglam.KullaniciId], iptal);
                alanId = await baglanti.TekDegerAsync<int?>(
                    "select id from public.muayene_sablon_alan where sablon_id = @p0 and kod = 'vucutsema'",
                    islem, [m.SablonId], iptal);
            }

            var metin = string.Join(", ", bolgeler) + (not.Length > 0 ? (bolgeler.Count > 0 ? " — " : "") + not : "");
            var json = System.Text.Json.JsonSerializer.Serialize(new { bolgeler, not });
            await baglanti.CalistirAsync("""
                insert into public.muayene_bulgu (muayene_id, sablon_alan_id, normal, deger_metin, deger_json, ekleyen)
                values (@p0, @p1, 0, nullif(@p2, ''), case when @p2 = '' then null else @p3::jsonb end, @p4)
                on conflict (muayene_id, sablon_alan_id) do update
                   set normal = 0, deger_metin = excluded.deger_metin, deger_json = excluded.deger_json,
                       degistiren = @p4, degistirme_tarihi = now()
                """, islem, [id, alanId!.Value, metin, json, baglam.KullaniciId], iptal);

            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, bolgeler, metin, bulguOzet = ozet,
                                    mesaj = bolgeler.Count == 0 && not.Length == 0
                                        ? "Vücut şeması temizlendi." : "Vücut şeması bulguya yazıldı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/bulgu-metni - kaydedilmis bulgulardan metin,
        //   YAZMADAN (Muayene Ozeti sekmesi). bulgu_ozet alani hekimin
        //   duzeltebildigi rapor metnidir; ozet sekmesi gridin GUNCEL halini
        //   gosterir (kullanici: "sistemde degisiklik yaptim ozete yansimadi").
        grup.MapGet("/{id:int}/bulgu-metni", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var metin = await BulguMetniAsync(baglanti, null, id, iptal);
            return Results.Ok(new { id, metin, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/bulgu-metni { satirlar } - EKRANDAKI (henuz
        //   kaydedilmemis) satirlardan metin; HICBIR SEY YAZMAZ (kullanici:
        //   "sistemde yazdiklarim ozete yansimadi" - Kaydet'e basmadan ozet
        //   sekmesine geciyordu). Alan adi/normal metni sablondan okunur.
        grup.MapPost("/{id:int}/bulgu-metni", async (
            int id, BulguMetniIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            var satirlar = (istek.Satirlar ?? []).Take(500).Select(x => new
            {
                sablon_alan_id = x.SablonAlanId, normal = x.Normal ? 1 : 0,
                deger_metin = x.DegerMetin, deger_sayi = x.DegerSayi, taraf = x.Taraf ?? 0,
            });
            await using var baglanti = await veri.AcAsync(iptal);
            var metin = await BulguMetniAsync(baglanti, null, id, iptal,
                System.Text.Json.JsonSerializer.Serialize(satirlar));
            return Results.Ok(new { id, metin, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/ozet-derle - bulgulardan metin üret
        //   Rapora ve e-Nabız 103'e giden metin BUDUR. Hekim üzerine yazabilir;
        //   derleme metni EZER çünkü çağıran zaten "bulgulardan yeniden üret"
        //   demektedir.
        grup.MapPost("/{id:int}/ozet-derle", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, bulguOzet = ozet, izlemeNo = baglam.IzlemeNo });
        });
    }
}
