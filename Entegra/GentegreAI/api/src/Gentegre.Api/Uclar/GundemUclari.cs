using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÜNDEM ve KAYIT ÖNERİLERİ (kullanıcı 03.11.2026, mockup Ekranlar/ana_sayfa_yz_komut.html - katman 1 ve 2):
/// "kullanıcının rolüne göre yönlendirmesi gerek.. bugünkü işlerim .. 'Demir' yazarsa Demir İnşaat (Müş), Demir Medikal (Ted),
/// Demir Eren (Kişi), Demir Öztürk (Personel) gelse, seçince önerileri listelese".
///
/// <para><b>Tek motor, rol + yetki:</b> ERP / HBYS ayrımı yok. Her kart, her öneri ve her aranan kayıt türü bir yetki
/// koduna bağlı; yetkisi olmayana sorgu hiç çalışmaz, satır hiç dönmez (istemci gizlemez). Kullanıcı: "yetkisi yoksa fatura
/// kesemez".</para>
/// <para><b>YZ yok:</b> bu uçlar kural ve sayımdır - ücretsiz, denetlenebilir. Serbest soru (katman 3) ayrı.</para>
/// </summary>
public static class GundemUclari
{
    /// <summary>Ad aramasında tür başına en çok satır (toplam 5 tür).</summary>
    private const int TurBasinaSatir = 3;

    public static void GundemUclariniEkle(this IEndpointRouteBuilder yol)
    {
        // GET /api/hizli-bul/kayit-ad?q= - Ctrl+K AD İLE KAYIT (katman 1). Cari aramasının (cari-ad) genişletilmiş hali:
        //   müşteri, tedarikçi, kişi, personel, hasta - her tür KENDİ yetkisiyle (cari · cari.tedarikci · cari.kisi ·
        //   personel · hasta). Her kelime ünvan / ad / soyad / kod içinde (fn_ara_metin, liste aramasıyla aynı). Yalnız aktif
        //   kayıt; başı eşleşen önce. Telefon / kimlik no DÖNMEZ (palet satırında gerekmiyor).
        yol.MapGet("/api/hizli-bul/kayit-ad", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kelimeler = (q ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(k => k.Length >= 2).Take(4).ToList();
            if (kelimeler.Count == 0 || kelimeler.Sum(k => k.Length) < 3)
                return Results.Ok(new { kayitlar = Array.Empty<object>() });

            // Tür -> taraf rol kolonu + yetki. Yetkisi olmayan tür sorguya hiç girmez.
            var turler = new List<(string Tur, string Kolon)>();
            if (baglam.Yetkiler.Var("cari", Islem.Gor)) turler.Add(("musteri", "musteri"));
            if (baglam.Yetkiler.Var("cari.tedarikci", Islem.Gor) || baglam.Yetkiler.Var("cari", Islem.Gor)) turler.Add(("tedarikci", "tedarikci"));
            if (baglam.Yetkiler.Var("cari.kisi", Islem.Gor)) turler.Add(("kisi", "kisi"));
            if (baglam.Yetkiler.Var("personel", Islem.Gor)) turler.Add(("personel", "personel"));
            if (baglam.Yetkiler.Var("hasta", Islem.Gor)) turler.Add(("hasta", "hasta"));
            if (turler.Count == 0) return Results.Ok(new { kayitlar = Array.Empty<object>() });

            var kosul = string.Join(" and ", kelimeler.Select((_, i) =>
                $"public.fn_ara_metin(coalesce(t.unvan, '') || ' ' || coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '') || ' ' || coalesce(t.kod, '')) like '%' || public.fn_ara_metin(@p{i + 1}) || '%'"));
            // Tür birleşimi: her tür kendi alt sorgusu, kendi sınırıyla (müşteri çoksa personel düşmesin).
            //   Aynı kişi iki rolde olabilir (müşteri + tedarikçi) - her rol ayrı satır, ilk geçen kalır.
            var parcalar = turler.Select(t => $$"""
                (select '{{t.Tur}}' as tur, t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), '') as ad,
                        coalesce(t.kod, '') as kod, t.musteri = 1 as musteri, t.tedarikci = 1 as tedarikci,
                        case '{{t.Tur}}'
                          when 'personel' then coalesce(t.gorev, '')
                          when 'kisi' then coalesce((select public.fn_taraf_ad(b.unvan, b.ad, b.soyad)::varchar(160)
                                                       from public.taraf b where b.id = t.bag_id), '')
                          when 'hasta' then coalesce(extract(year from age(t.d_tarih))::int || ' yaş', '')
                          else coalesce((select a.il from public.taraf_adres a where a.taraf_id = t.id
                                          order by a.varsayilan desc, a.id limit 1), '') end as bilgi,
                        (public.fn_ara_metin(coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''))
                           like public.fn_ara_metin(@p1) || '%') as basi
                   from public.taraf t
                  where t.{{t.Kolon}} = 1 and coalesce(t.durum, 1) = 1
                    and (cardinality(@p0::int[]) = 0 or t.id = any(@p0::int[]))
                    and {{kosul}}
                  order by 8 desc, t.id desc
                  limit {{TurBasinaSatir}})
                """);
            var sql = string.Join("\nunion all\n", parcalar);
            var kapsam = baglam.Kapsam.Count > 0 ? baglam.Kapsam.ToArray() : [];
            var l = await veri.ListeAsync(sql, [kapsam, .. kelimeler.Cast<object?>()],
                o => new { tur = o.GetString(0), id = o.GetInt32(1), ad = o.GetString(2), kod = o.GetString(3),
                           musteri = o.GetBoolean(4), tedarikci = o.GetBoolean(5), bilgi = o.GetString(6) }, iptal);
            return Results.Ok(new { kayitlar = l });
        }).RequireAuthorization().WithTags("Hızlı bul");

        // GET /api/hizli-bul/vergi-no?q= - Ctrl+K DÜZ VKN / TCKN (kullanıcı 03.11.2026: "prompt'a vkno girdim hiç bir bilgi
        //   gelmedi .. 10 ise müş/ted/anlaşmalı kurum .. 11 hane hasta/personel olabilir .. 11 haneli müşteri de olabilir
        //   bireysel .. tc no ya fatura kesmiş olabilir"). Numaraya kayıtlı müşteri / tedarikçi / kurum kartı (her rol ayrı
        //   satır, kendi yetkisiyle; PASİF dahil - kart yeniden etkinleştirilir) + o numaraya kesilmiş SON satış belgeleri
        //   (kartı olmayan nihai tüketici / bireysel). Hasta / personel 11 hanesi paletin kimlik niyetinde (ayrı uç).
        yol.MapGet("/api/hizli-bul/vergi-no", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var no = new string((q ?? "").Where(char.IsDigit).ToArray());
            if (no.Length is not (10 or 11) || no.Distinct().Count() == 1)
                return Results.Ok(new { kayitlar = Array.Empty<object>(), belgeler = Array.Empty<object>() });
            var roller = new List<string>();
            if (baglam.Yetkiler.Var("cari", Islem.Gor)) roller.Add("musteri");
            if (baglam.Yetkiler.Var("cari.tedarikci", Islem.Gor) || baglam.Yetkiler.Var("cari", Islem.Gor)) roller.Add("tedarikci");
            if (baglam.Yetkiler.Var("kurum", Islem.Gor) || baglam.Yetkiler.Var("kurum.liste", Islem.Gor)) roller.Add("kurum");
            var kapsam = baglam.Kapsam.Count > 0 ? baglam.Kapsam.ToArray() : [];
            await using var b = await veri.AcAsync(iptal);
            List<object> kayitlar = roller.Count == 0 ? [] : [.. await b.ListeAsync("""
                select r.tur, t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), coalesce(t.kod, ''),
                       coalesce(t.durum, 1)::int, t.musteri = 1, t.tedarikci = 1
                  from public.taraf t
                  cross join lateral (values ('musteri', t.musteri), ('tedarikci', t.tedarikci), ('kurum', t.kurum)) r(tur, var)
                 where regexp_replace(coalesce(t.vkno, ''), '[^0-9]', '', 'g') = @p0
                   and r.var = 1 and r.tur = any(@p1::text[])
                   and (cardinality(@p2::int[]) = 0 or t.id = any(@p2::int[]))
                 order by (coalesce(t.durum, 1) = 1) desc, t.id
                 limit 6
                """, null, [no, roller.ToArray(), kapsam],
                o => new { tur = o.GetString(0), id = o.GetInt32(1), ad = o.GetString(2), kod = o.GetString(3), durum = o.GetInt32(4),
                           musteri = o.GetBoolean(5), tedarikci = o.GetBoolean(6) }, iptal)];
            List<object> belgeler = !baglam.Yetkiler.Var("belge.satis.fatura", Islem.Gor) && !baglam.Yetkiler.Var("belge.satis", Islem.Gor) ? [] :
                [.. await b.ListeAsync("""
                    select b.id, b.tur::int, coalesce(b.belge_no, ''), b.belge_tarihi, coalesce(b.taraf_unvan, ''), coalesce(b.genel_toplam, 0)
                      from public.belge b
                     where regexp_replace(coalesce(b.taraf_vkno, ''), '[^0-9]', '', 'g') = @p0
                       and b.tur in (14, 15, 16, 19) and b.durum <> 2 and coalesce(b.tipi, 0) <> 30
                       and (cardinality(@p1::int[]) = 0 or b.taraf_id = any(@p1::int[]))
                     order by b.belge_tarihi desc, b.id desc
                     limit 3
                    """, null, [no, kapsam],
                    o => new { id = o.GetInt32(0), tur = o.GetInt32(1), no = o.GetString(2), tarih = o.GetDateTime(3),
                               unvan = o.GetString(4), tutar = o.GetDecimal(5) }, iptal)];
            return Results.Ok(new { kayitlar, belgeler });
        }).RequireAuthorization().WithTags("Hızlı bul");

        // GET /api/gundem - ROL GÜNDEMİ (katman 2). Kart listesi kullanıcıyla 03.11.2026'da kararlaştırıldı. Her kart:
        //   yetki kodu (biri yeterli) + modül; ikisi de yoksa SORGUSU ÇALIŞMAZ. Boş kart (sayı 0) dönmez. Kurallar mevcut
        //   icmallerin kuralıdır (cari FIFO = CariIcmalUclari.Kume, çek açık kuralı nakit akışınki, irsaliye-fatura bağı
        //   kaynak_tur=30 ...) - gündem ikinci bir hesap YAZMAZ, aynı sayıyı kısa yoldan söyler.
        yol.MapGet("/api/gundem", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            var subeler = baglam.Subeler.Count > 0 ? baglam.Subeler.Select(s => s.Id).ToArray() : (sube > 0 ? [sube] : Array.Empty<int>());
            var moduller = await Gentegre.Veri.Depolar.KurumProfilDeposu.AcikModullerAsync(b, sube, iptal);
            bool Modul(string m) => moduller.Count == 0 || moduller.Contains(m);
            bool Yetki(params string[] kodlar) => kodlar.Any(k => baglam.Yetkiler.Var(k, Islem.Gor));
            var kartlar = new List<GundemKarti>();
            void Ekle(GundemKarti? k) { if (k is not null) kartlar.Add(k); }

            // ---- F1 / F2 / S4 · cari vadeleri (FIFO, bütün geçmiş) - tek sorgu --------------------------------------
            var cariOdeme = Modul("kasa") && Yetki("finans.cari_icmali", "finans.nakit_akis_icmali");
            var cariTahsil = Modul("kasa") && Yetki("finans.cari_icmali", "finans.alacak_yaslandirma");
            var risk = Modul("kasa") && Yetki("finans.musteri_risk_icmali");
            Cari7? cari = null;
            if (cariOdeme || cariTahsil || risk)
            {
                var kapsam = baglam.Kapsam.Count > 0 ? baglam.Kapsam.ToArray() : [];
                cari = await b.TekAsync(CariIcmalUclari.Kume + """
                    , t as (select a.taraf_id, sum(a.acik_borc - a.acik_alacak) as bakiye from acik a group by 1)
                    select
                      coalesce(sum(a.acik_alacak) filter (where a.acik_alacak > 0.005 and a.vade >= current_date and a.vade < current_date + 8), 0),
                      count(distinct a.taraf_id) filter (where a.acik_alacak > 0.005 and a.vade < current_date + 8)::int,
                      coalesce(sum(a.acik_alacak) filter (where a.acik_alacak > 0.005 and a.vade < current_date), 0),
                      coalesce(sum(a.acik_borc) filter (where a.acik_borc > 0.005 and a.vade = current_date), 0),
                      coalesce(sum(a.acik_borc) filter (where a.acik_borc > 0.005 and a.vade < current_date), 0),
                      count(distinct a.taraf_id) filter (where a.acik_borc > 0.005 and a.vade < current_date)::int,
                      coalesce(max(current_date - a.vade::date) filter (where a.acik_borc > 0.005 and a.vade < current_date), 0)::int,
                      (select count(*) from t join tr on tr.id = t.taraf_id
                        where tr.musteri = 1 and tr.risk_limiti > 0 and t.bakiye >= tr.risk_limiti * 0.9)::int,
                      (select count(*) from t join tr on tr.id = t.taraf_id
                        where tr.musteri = 1 and tr.risk_limiti > 0 and t.bakiye > tr.risk_limiti)::int,
                      coalesce(sum(a.acik_borc) filter (where a.acik_borc > 0.005 and a.vade >= current_date and a.vade < current_date + 8), 0),
                      coalesce((select string_agg(x.ad, ', ' order by x.tutar desc) from (
                          select tr.ad, sum(a2.acik_alacak) as tutar from acik a2 join tr on tr.id = a2.taraf_id
                           where a2.acik_alacak > 0.005 and a2.vade >= current_date and a2.vade < current_date + 8
                           group by tr.ad order by 2 desc limit 3) x), '')
                      from acik a
                    """, null, [new DateTime(1900, 1, 1), DateTime.Today, 0, 0, kapsam, 0],
                    o => new Cari7(o.GetDecimal(0), o.GetInt32(1), o.GetDecimal(2), o.GetDecimal(3), o.GetDecimal(4), o.GetInt32(5),
                                   o.GetInt32(6), o.GetInt32(7), o.GetInt32(8), o.GetDecimal(9), o.GetString(10)), iptal);
            }
            if (cari is not null && cariOdeme && (cari.Odeme7 > 0.005m || cari.OdemeGecen > 0.005m))
                Ekle(new("odeme", "Ödeme vadesi", "💸", cari.OdemeCari.ToString(), cari.OdemeGecen > 0.005m ? "kir" : "sar",
                    [new("7 gün içinde", Para(cari.Odeme7)), new("Vadesi geçen", Para(cari.OdemeGecen)),
                     .. (cari.OdemeIlk3.Length > 0 ? new[] { new GundemSatiri(cari.OdemeIlk3, "") } : [])],
                    "/cari-icmali?kapsam=tedarikci", [new("Cari İcmali", "/cari-icmali?kapsam=tedarikci")]));
            if (cari is not null && cariTahsil && (cari.TahsilBugun > 0.005m || cari.TahsilGecen > 0.005m))
                Ekle(new("tahsilat", "Tahsil edilecek", "📥", cari.TahsilGecenCari.ToString(), cari.TahsilGecen > 0.005m ? "kir" : "yes",
                    [new("Vadesi bugün", Para(cari.TahsilBugun)), new("Vadesi geçen", Para(cari.TahsilGecen)),
                     new("En eski", cari.EnEskiGun > 0 ? $"{cari.EnEskiGun} gün" : "—")],
                    "/cari-icmali?kapsam=musteri", [new("Cari İcmali", "/cari-icmali?kapsam=musteri")]));
            if (cari is not null && risk && cari.Risk90 > 0)
                Ekle(new("risk", "Risk limitine yaklaşan", "⚠", cari.Risk90.ToString(), cari.RiskAsan > 0 ? "kir" : "sar",
                    [new("Limiti aşan", cari.RiskAsan.ToString()), new("Bakiyesi limitin %90'ında", (cari.Risk90 - cari.RiskAsan).ToString())],
                    "/musteri-risk-icmali", [new("Müşteri Risk İcmali", "/musteri-risk-icmali")]));

            // ---- F3 · çek / senet (7 gün) - açık kuralı nakit akışınki ---------------------------------------------
            if (Modul("kasa") && Yetki("finans.cek_senet_icmali", "cek_senet.liste", "cek_senet"))
            {
                var c = await b.TekAsync("""
                    select count(*) filter (where c.yon = 1)::int, coalesce(sum(c.yerel_tutar) filter (where c.yon = 1), 0),
                           count(*) filter (where c.yon = 2)::int, coalesce(sum(c.yerel_tutar) filter (where c.yon = 2), 0)
                      from public.cek_senet c
                     where c.vade >= current_date and c.vade < current_date + 8
                       and ((c.yon = 1 and c.durum in (10, 30, 40)) or (c.yon = 2 and c.durum not in (0, 50, 60, 70)))
                       and (coalesce(c.sube_id, 0) = 0 or cardinality(@p0::int[]) = 0 or c.sube_id = any(@p0::int[]))
                    """, null, [subeler], o => new { ad = o.GetInt32(0), at = o.GetDecimal(1), vd = o.GetInt32(2), vt = o.GetDecimal(3) }, iptal);
                if (c is not null && c.ad + c.vd > 0)
                    Ekle(new("cek", "Çek / senet vadesi (7 gün)", "🧾", (c.ad + c.vd).ToString(), c.vd > 0 ? "sar" : "mav",
                        [new($"Alınan · {c.ad}", Para(c.at)), new($"Verilen · {c.vd}", Para(c.vt))],
                        "/cek-senet-icmali?vade=7", [new("Çek / Senet İcmali", "/cek-senet-icmali?vade=7")]));
            }

            // ---- F4 · kredi taksiti (7 gün + geciken) ---------------------------------------------------------------
            if (Modul("kasa") && Yetki("finans.nakit_akis_icmali", "hesap.tanim.kredi.liste", "kredi"))
            {
                var k = await b.TekAsync("""
                    select count(*)::int, coalesce(sum(kt.toplam - coalesce(kt.odenen, 0)), 0),
                           count(*) filter (where kt.vade < current_date)::int
                      from public.kredi_taksit kt join public.hesap h on h.id = kt.kredi_id
                     where kt.durum <> 1 and kt.toplam - coalesce(kt.odenen, 0) > 0.005 and kt.vade < current_date + 8
                       and (h.sube_id is null or h.sube_id = 0 or cardinality(@p0::int[]) = 0 or h.sube_id = any(@p0::int[]))
                    """, null, [subeler], o => new { adet = o.GetInt32(0), tutar = o.GetDecimal(1), geciken = o.GetInt32(2) }, iptal);
                if (k is not null && k.adet > 0)
                    Ekle(new("kredi", "Kredi taksiti", "🏦", k.adet.ToString(), k.geciken > 0 ? "kir" : "sar",
                        [new("7 gün içinde ödenecek", Para(k.tutar)), new("Geciken taksit", k.geciken.ToString())],
                        "/nakit-akis-icmali", [new("Nakit Akış İcmali", "/nakit-akis-icmali"), new("Kredi Hesapları", "/kredi-hesap")]));
            }

            // ---- F5 · planlı ödemeler (kira, abonelik, kart ...) - PlanliGiderMotoru'nun kuralı ---------------------
            if (Modul("kasa") && Yetki("finans.planli_gider"))
            {
                var (kalemler, _) = await PlanliGiderMotoru.AkisKalemleriAsync(b, subeler, 0, DateTime.Today, DateTime.Today.AddDays(7), iptal);
                var gecmis = kalemler.Count(x => x.Gecmis);
                if (kalemler.Count > 0)
                    Ekle(new("planli", "Planlı ödemeler", "📆", kalemler.Count.ToString(), gecmis > 0 ? "kir" : "sar",
                        [new("7 gün içinde", Para(kalemler.Where(x => !x.Gecmis).Sum(x => x.Tutar))), new("Geciken", gecmis.ToString()),
                         new GundemSatiri(string.Join(", ", kalemler.OrderBy(x => x.Vade).Take(3).Select(x => x.Ad)), "")],
                        "/planli-gider", [new("Planlı Giderler", "/planli-gider")]));
            }

            // ---- F6 · nakit durumu (kasa + banka) + 7 günün vadeleri ------------------------------------------------
            if (Modul("kasa") && Yetki("finans.nakit_akis_icmali"))
            {
                var bakiye = await b.TekDegerAsync<decimal>("""
                    select coalesce(sum(v.yerel_bakiye), 0) from public.v_hesap_bakiye v
                     where v.tur in ('K', 'B') and v.durum = 1
                       and (v.sube_id is null or v.sube_id = 0 or cardinality(@p0::int[]) = 0 or v.sube_id = any(@p0::int[]))
                    """, null, [subeler], iptal);
                var giris = cari?.Tahsil7 ?? 0; var cikis = cari?.Odeme7 ?? 0;
                Ekle(new("nakit", "Nakit durumu", "📊", "", "mav",
                    [new("Kasa + banka", Para(bakiye)), new("7 gün tahsilat − ödeme vadesi", Para(giris - cikis))],
                    "/nakit-akis-icmali", [new("Nakit Akış İcmali", "/nakit-akis-icmali")]));
            }

            // ---- F7 · banka hareketi eşleşme bekliyor -----------------------------------------------------------------
            if (Modul("kasa") && Yetki("banka.hareket"))
            {
                var n = await b.TekDegerAsync<int>("""
                    select count(*)::int from public.banka_hareket h
                     where h.durum in (0, 1, 4) and (@p0 = 0 or h.sube_id = @p0)
                    """, null, [sube], iptal);
                if (n > 0)
                    Ekle(new("banka", "Banka hareketi bekliyor", "🔗", n.ToString(), "sar",
                        [new("İşlenmemiş hareket", n.ToString())], "/banka-hareket", [new("Banka Hareketleri", "/banka-hareket")]));
            }

            // ---- S1 / S6 · faturası kesilmemiş irsaliye (kaynak_tur = 30 bağı, eşleşme icmalinin kuralı) -------------
            async Task Irsaliye(string kod, int tur, string baslik, string yon, string liste, string yetki)
            {
                if (!Modul("erp_satis") || !Yetki("irsaliye_fatura_eslesme", yetki)) return;
                var r = await b.TekAsync(IrsaliyeSql, null, [tur, subeler],
                    o => new { adet = o.GetInt32(0), tutar = o.GetDecimal(1), gun = o.GetInt32(2) }, iptal);
                if (r is null || r.adet == 0) return;
                Ekle(new(kod, baslik, "🚚", r.adet.ToString(), r.gun > 7 ? "kir" : "sar",
                    [new("Tutar", Para(r.tutar)), new("En eski", $"{r.gun} gün")],
                    $"/irsaliye-fatura-eslesme?yon={yon}&bas=2000-01-01", [new("İrsaliye-Fatura Eşleşme", $"/irsaliye-fatura-eslesme?yon={yon}&bas=2000-01-01"), new("İrsaliye Listesi", liste)]));
            }
            await Irsaliye("irsSatis", 14, "Faturalanmamış satış irsaliyesi", "satis", "/satis-irsaliye", "belge.satis.irsaliye");

            // ---- S2 / S5 · açık sipariş, termini bugün / geçmiş (v_belge_acik_satir) ---------------------------------
            async Task Siparis(string kod, int tur, string baslik, string yon, string liste, string yetki, string modul)
            {
                if (!Modul(modul) || !Yetki("siparis.icmali", yetki)) return;
                var r = await b.TekAsync("""
                    select count(distinct a.belge_id)::int,
                           count(distinct a.belge_id) filter (where coalesce(s.teslim_tarihi::date, bsa.soz_teslim::date) <= current_date)::int
                      from public.v_belge_acik_satir a
                      join public.belge b on b.id = a.belge_id
                      join public.belge_satir s on s.id = a.satir_id
                      left join public.belge_satinalma bsa on bsa.id = b.id
                     where b.tur = @p0 and coalesce(b.tipi, 0) <> 30
                       and (b.sube_id is null or cardinality(@p1::int[]) = 0 or b.sube_id = any(@p1::int[]))
                    """, null, [tur, subeler], o => new { acik = o.GetInt32(0), termin = o.GetInt32(1) }, iptal);
                if (r is null || r.acik == 0) return;
                Ekle(new(kod, baslik, "📋", r.acik.ToString(), r.termin > 0 ? "kir" : "mav",
                    [new("Termini bugün / geçen", r.termin.ToString())],
                    $"/siparis-icmali?yon={yon}&durum=acikkismi&termin=gecen", [new("Sipariş İcmali", $"/siparis-icmali?yon={yon}&durum=acikkismi"), new("Sipariş Listesi", liste)]));
            }
            await Siparis("sipSatis", 19, "Açık satış siparişi", "satis", "/siparis", "belge.satis.siparis", "erp_satis");

            // ---- S3 · cevap bekleyen teklif (7 günden eski, dönüşmemiş) ---------------------------------------------
            if (Modul("erp_satis") && Yetki("satis.teklif_icmali", "belge.satis"))
            {
                var r = await b.TekAsync("""
                    select count(*)::int, coalesce(sum(b.genel_toplam), 0)
                      from public.belge b
                     where b.tur = 18 and b.durum <> 2 and coalesce(b.teklif_durum, 1) in (1, 2)
                       and coalesce(b.degistirme_tarihi, b.ekleme_tarihi) < now() - interval '7 days'
                       and (b.sube_id is null or cardinality(@p0::int[]) = 0 or b.sube_id = any(@p0::int[]))
                       and not exists (select 1 from public.belge_satir s join public.belge_satir hs
                                         on hs.kaynak_tur = 30 and hs.kaynak_id = s.id where s.belge_id = b.id)
                    """, null, [subeler], o => new { adet = o.GetInt32(0), tutar = o.GetDecimal(1) }, iptal);
                if (r is not null && r.adet > 0)
                    Ekle(new("teklif", "Cevap bekleyen teklif", "📝", r.adet.ToString(), "sar",
                        [new("7 günden eski", Para(r.tutar))], "/teklif-icmali", [new("Teklif İcmali", "/teklif-icmali"), new("Teklif Listesi", "/teklif")]));
            }

            // ---- S5 / S6 · satınalma tarafı --------------------------------------------------------------------------
            await Siparis("sipAlis", 9, "Açık alış siparişi", "alis", "/alis-siparis", "belge.alis", "erp_satis");
            await Irsaliye("irsAlis", 10, "Faturası gelmemiş alış irsaliyesi", "alis", "/alis-irsaliye", "belge.alis.irsaliye");

            // ---- D1 · kritik stok (fn_kritik_stok_talep kuralı: eldeki = kalan - rezerve <= asgari) ------------------
            if (Modul("stok") && Yetki("stok.kritik_stok_icmali"))
            {
                var n = await b.TekDegerAsync<int>("""
                    select count(distinct s.id)::int
                      from public.stok_durum sd join public.stok s on s.id = sd.stok_id join public.depo d on d.id = sd.depo_id
                     where s.durum = 1 and d.durum = 1
                       and (d.sube_id is null or cardinality(@p0::int[]) = 0 or d.sube_id = any(@p0::int[]))
                       and coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0)) > 0
                       and (sd.kalan - coalesce(sd.rezerve, 0)) <= coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0))
                    """, null, [subeler], iptal);
                if (n > 0)
                    Ekle(new("kritikStok", "Kritik stok", "📦", n.ToString(), "sar", [new("Asgari stoğun altında", $"{n} kalem")],
                        "/stok-kritik-stok-icmali", [new("Kritik Stok İcmali", "/stok-kritik-stok-icmali")]));
            }

            // ---- D2 · SKT 30 gün içinde ------------------------------------------------------------------------------
            if (Modul("stok") && Yetki("stok.skt_icmali"))
            {
                var r = await b.TekAsync("""
                    select count(*) filter (where l.son_kullanma_tarihi::date >= current_date)::int,
                           count(*) filter (where l.son_kullanma_tarihi::date < current_date)::int
                      from public.stok_lot_durum ld join public.stok_seri_lot l on l.id = ld.seri_lot_id
                      join public.depo d on d.id = ld.depo_id
                     where ld.kalan <> 0 and l.son_kullanma_tarihi is not null and l.son_kullanma_tarihi::date < current_date + 31
                       and (d.sube_id is null or cardinality(@p0::int[]) = 0 or d.sube_id = any(@p0::int[]))
                    """, null, [subeler], o => new { yakin = o.GetInt32(0), gecmis = o.GetInt32(1) }, iptal);
                if (r is not null && r.yakin + r.gecmis > 0)
                    Ekle(new("skt", "Son kullanma tarihi", "⏳", r.yakin.ToString(), r.gecmis > 0 ? "kir" : "sar",
                        [new("30 gün içinde", $"{r.yakin} lot"), new("Tarihi geçmiş (stokta)", $"{r.gecmis} lot")],
                        "/stok-skt-icmali?ufuk=30", [new("SKT / Lot İcmali", "/stok-skt-icmali?ufuk=30")]));
            }

            // ---- D3 · açık sayım ----------------------------------------------------------------------------------------
            if (Modul("stok") && Yetki("stok.sayim.liste", "stok.sayim"))
            {
                var n = await b.TekDegerAsync<int>("""
                    select count(*)::int from public.stok_sayim x
                     where x.durum = 0 and (x.sube_id is null or cardinality(@p0::int[]) = 0 or x.sube_id = any(@p0::int[]))
                    """, null, [subeler], iptal);
                if (n > 0)
                    Ekle(new("sayim", "Açık sayım", "🔢", n.ToString(), "mav", [new("Kapanmamış sayım", n.ToString())],
                        "/stok-sayim", [new("Stok Sayımları", "/stok-sayim")]));
            }

            // ---- H1 · bugünkü randevular (şube, şubenin saat diliminde) ----------------------------------------------
            if (Modul("randevu") && Yetki("randevu.liste", "randevu.icmal", "randevu"))
            {
                var r = await b.TekAsync("""
                    with sb as (select coalesce(nullif(max(s.zaman_dilimi), ''), 'Europe/Istanbul') as dilim from public.sube s where s.id = @p0)
                    select count(*) filter (where r.durum not in (4, 5))::int,
                           count(*) filter (where r.durum = 2)::int,
                           count(*) filter (where r.durum = 1 and r.baslangic < now())::int,
                           count(*) filter (where r.durum = 1 and r.baslangic >= now() and r.baslangic < now() + interval '1 hour')::int
                      from public.randevu r, sb
                     where (r.baslangic at time zone sb.dilim)::date = (now() at time zone sb.dilim)::date
                       and (@p0 = 0 or r.sube_id = @p0) and r.hekim_id is not null
                    """, null, [sube], o => new { top = o.GetInt32(0), geldi = o.GetInt32(1), gelmedi = o.GetInt32(2), saat = o.GetInt32(3) }, iptal);
                if (r is not null && r.top > 0)
                    Ekle(new("randevu", "Bugünkü randevular", "📅", r.top.ToString(), r.gelmedi > 0 ? "sar" : "mav",
                        [new("Geldi", r.geldi.ToString()), new("Saati geçti, gelmedi", r.gelmedi.ToString()), new("Sonraki 1 saat", r.saat.ToString())],
                        "/randevu", [new("Randevu Listesi", "/randevu")]));
            }

            // ---- H2 · Medula hataları ----------------------------------------------------------------------------------
            if (Modul("medula") && Yetki("medula", "medula.cagri_gunlugu"))
            {
                var r = await b.TekAsync("""
                    select count(*) filter (where k.durum = 4)::int, count(*) filter (where k.durum = 5)::int,
                           count(*) filter (where k.durum in (4, 5) and k.islem = 'hastaKabul')::int
                      from public.medula_kuyruk k where k.durum in (4, 5) and (@p0 = 0 or k.sube_id = @p0)
                    """, null, [sube], o => new { hata = o.GetInt32(0), elle = o.GetInt32(1), prov = o.GetInt32(2) }, iptal);
                if (r is not null && r.hata + r.elle > 0)
                    Ekle(new("medula", "Medula hatası", "⚠", (r.hata + r.elle).ToString(), "kir",
                        [new("Provizyon", r.prov.ToString()), new("Hata / elle müdahale", $"{r.hata} / {r.elle}")],
                        "/medula-kuyruk", [new("Medula Çağrıları", "/medula-kuyruk")]));
            }

            // ---- H3 · tahsil edilmemiş hasta payı (açık satır kalanı) -------------------------------------------------
            if (Yetki("hasta.borc_takip"))
            {
                var r = await b.TekAsync("""
                    select count(distinct a.belge_id)::int, coalesce(sum(coalesce(a.hasta_provizyon_kalan, 0) + coalesce(a.hasta_ek_katki_kalan, 0)), 0)
                      from public.v_belge_acik_satir a
                     where coalesce(a.hasta_provizyon_kalan, 0) + coalesce(a.hasta_ek_katki_kalan, 0) > 0.005
                       and (@p0 = 0 or coalesce(a.sube_id, 0) in (0, @p0))
                    """, null, [sube], o => new { adet = o.GetInt32(0), tutar = o.GetDecimal(1) }, iptal);
                if (r is not null && r.adet > 0)
                    Ekle(new("hastaBorc", "Tahsil edilmemiş hasta payı", "💳", r.adet.ToString(), "sar",
                        [new("Katkı payı / fark", Para(r.tutar))], "/hasta-borc-takibi", [new("Hasta Borç Takibi", "/hasta-borc-takibi")]));
            }

            // ---- H4 · banko oturumum -------------------------------------------------------------------------------------
            if (Yetki("banko_oturum"))
            {
                var r = await b.TekAsync("""
                    select o.durum::int, coalesce(o.nakit_tahsilat, 0) - coalesce(o.nakit_iade, 0), coalesce(o.pos_tutar, 0), coalesce(o.islem_adet, 0)::int
                      from public.v_banko_oturum_ozet o where o.kullanici_id = @p0 and o.durum in (1, 2, 3)
                     order by o.id desc limit 1
                    """, null, [baglam.KullaniciId], o => new { durum = o.GetInt32(0), nakit = o.GetDecimal(1), pos = o.GetDecimal(2), adet = o.GetInt32(3) }, iptal);
                if (r is not null)
                    Ekle(new("banko", r.durum == 2 ? "Banko oturumu açık" : r.durum == 1 ? "Oturum açılış onayı bekliyor" : "Oturum teslimde", "🧾",
                        r.adet.ToString(), r.durum == 2 ? "yes" : "sar",
                        [new("Nakit", Para(r.nakit)), new("Kart", Para(r.pos)), new("İşlem", r.adet.ToString())],
                        "/banko-oturum", [new("Banko Oturumu", "/banko-oturum")]));
            }

            // ---- H5 · laboratuvar: panik değer + onay bekleyen sonuç ------------------------------------------------------
            if (Modul("lab") && Yetki("lab.sonuc", "lab.panik"))
            {
                var r = await b.TekAsync("""
                    select (select count(*) from public.lab_sonuc ls where ls.durum in (1, 2) and (@p0 = 0 or ls.sube_id = @p0))::int,
                           (select count(*) from public.v_lab_panik_acik p where p.teyit_zamani is null and (@p0 = 0 or p.sube_id = @p0))::int
                    """, null, [sube], o => new { onay = o.GetInt32(0), panik = o.GetInt32(1) }, iptal);
                if (r is not null && r.onay + r.panik > 0)
                    Ekle(new("lab", "Laboratuvar", "🧪", (r.onay + r.panik).ToString(), r.panik > 0 ? "kir" : "sar",
                        [new("Panik değer (teyitsiz)", r.panik.ToString()), new("Onay bekleyen sonuç", r.onay.ToString())],
                        r.panik > 0 ? "/lab-panik" : "/lab-sonuc", [new("Panik Değerler", "/lab-panik"), new("Sonuç Onayı", "/lab-sonuc")]));
            }

            // ---- G3 · görevlerim + hatırlatmalarım (kendi kayıtları, yetki gerekmez) --------------------------------------
            {
                var r = await b.TekAsync("""
                    select (select count(*) from public.gorev g where g.sorumlu_id = @p0 and g.durum in (0, 1) and g.termin < now())::int,
                           (select count(*) from public.gorev g where g.sorumlu_id = @p0 and g.durum in (0, 1)
                               and g.termin >= now() and g.termin::date = current_date)::int,
                           (select count(*) from public.hatirlatma h where h.sahip_id = @p0 and h.durum = 1 and h.zaman < now())::int,
                           (select count(*) from public.hatirlatma h where h.sahip_id = @p0 and h.durum = 1
                               and h.zaman >= now() and h.zaman::date = current_date)::int
                    """, null, [baglam.KullaniciId], o => new { gec = o.GetInt32(0), bugun = o.GetInt32(1), hgec = o.GetInt32(2), hbugun = o.GetInt32(3) }, iptal);
                if (r is not null && r.gec + r.bugun > 0)
                    Ekle(new("gorev", "Görevlerim", "✅", (r.gec + r.bugun).ToString(), r.gec > 0 ? "kir" : "mav",
                        [new("Geciken", r.gec.ToString()), new("Bugün", r.bugun.ToString())], "/gorev", [new("Görev Listesi", "/gorev")]));
                if (r is not null && r.hgec + r.hbugun > 0)
                    Ekle(new("hatirlatma", "Hatırlatmalarım", "⏰", (r.hgec + r.hbugun).ToString(), r.hgec > 0 ? "kir" : "mav",
                        [new("Geçmiş", r.hgec.ToString()), new("Bugün", r.hbugun.ToString())], "/hatirlatmalarim", [new("Hatırlatmalarım", "/hatirlatmalarim")]));
            }

            // Kırmızı önce, sonra sarı / yeşil / mavi; aynı tonda tanım sırası.
            var sira = new Dictionary<string, int> { ["kir"] = 0, ["sar"] = 1, ["yes"] = 2, ["mav"] = 3 };
            return Results.Ok(new { kartlar = kartlar.Select((k, i) => (k, i)).OrderBy(x => sira[x.k.Ton]).ThenBy(x => x.i).Select(x => x.k) });
        }).RequireAuthorization().WithTags("Gündem");

        // GET /api/gundem/kayit?tur=&id= - SEÇİLEN KAYDIN ÖNERİLERİ (katman 2). Her öneri bir işleme ve onun yetkisine bağlı:
        //   yetkisi yoksa öneri hiç gelmez ("yetkisi yoksa fatura kesemez"). Özet kutuları yalnız görme yetkisiyle.
        yol.MapGet("/api/gundem/kayit", async (string? tur, int? id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (id is not int kayitId || kayitId <= 0) return Results.Ok(new { ozet = Array.Empty<object>(), oneriler = Array.Empty<object>() });
            bool Gor(string k) => baglam.Yetkiler.Var(k, Islem.Gor);
            bool Ekle(string k) => baglam.Yetkiler.Var(k, Islem.Ekle);
            // Kayıt kapsamı (portal / kısıtlı kullanıcı): kapsam dışı kayda öneri yok.
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(kayitId))
                return Results.Ok(new { ozet = Array.Empty<object>(), oneriler = Array.Empty<object>() });
            await using var b = await veri.AcAsync(iptal);
            var ozet = new List<KayitOzeti>();
            var oneriler = new List<KayitOnerisi>();
            var ad = await b.TekDegerAsync<string>("select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), '') from public.taraf t where t.id = @p0",
                null, [kayitId], iptal) ?? "";
            var adQ = Uri.EscapeDataString(ad);

            switch (tur)
            {
                case "musteri" or "tedarikci":
                {
                    if (!Gor("cari") && !Gor("cari.tedarikci")) break;
                    var satis = tur == "musteri";
                    // Bakiye + vade: cari icmalin FIFO kuralı, yalnız bu taraf (kapsam dizisi = [id]).
                    var c = await b.TekAsync(CariIcmalUclari.Kume + """
                        select coalesce(sum(a.acik_borc - a.acik_alacak), 0),
                               coalesce(sum(a.acik_borc) filter (where a.acik_borc > 0.005 and a.vade < current_date), 0),
                               coalesce(max(current_date - a.vade::date) filter (where a.acik_borc > 0.005 and a.vade < current_date), 0)::int,
                               coalesce(sum(a.acik_alacak) filter (where a.acik_alacak > 0.005 and a.vade < current_date + 8), 0),
                               coalesce(min(a.vade::date) filter (where a.acik_alacak > 0.005), null)
                          from acik a
                        """, null, [new DateTime(1900, 1, 1), DateTime.Today, 0, 0, new[] { kayitId }, 1],
                        o => new { bakiye = o.GetDecimal(0), gecen = o.GetDecimal(1), gun = o.GetInt32(2), odeme7 = o.GetDecimal(3),
                                   ilkOdeme = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4) }, iptal);
                    if (c is not null)
                    {
                        ozet.Add(new("Bakiye", Para(Math.Abs(c.bakiye)) + (c.bakiye > 0.005m ? " B" : c.bakiye < -0.005m ? " A" : ""),
                                     satis && c.bakiye > 0.005m ? "kir" : null));
                        if (satis && c.gecen > 0.005m) ozet.Add(new("Vadesi geçen", $"{Para(c.gecen)} · {c.gun} gün", "kir"));
                        if (!satis && c.odeme7 > 0.005m) ozet.Add(new("7 günde ödenecek", Para(c.odeme7), "sar"));
                    }
                    var irsTur = satis ? 14 : 10;
                    var irs = await b.ListeAsync("""
                        select b.id, coalesce(b.belge_no, ''), (current_date - b.belge_tarihi::date)::int, coalesce(b.genel_toplam, 0)
                          from public.belge b
                         where b.tur = @p0 and b.durum = 0 and b.taraf_id = @p1
                           and exists (select 1 from public.belge_satir s where s.belge_id = b.id and s.miktar > 0
                                         and s.miktar - coalesce((select sum(hs.miktar) from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                                                                   where hs.kaynak_tur = 30 and hs.kaynak_id = s.id and hb.durum = 0), 0) > 0.0001)
                         order by b.belge_tarihi
                         limit 20
                        """, null, [irsTur, kayitId], o => new { id = o.GetInt32(0), no = o.GetString(1), gun = o.GetInt32(2), tutar = o.GetDecimal(3) }, iptal);
                    var irsListe = satis ? "/satis-irsaliye" : "/alis-irsaliye";
                    var fatYetki = satis ? "belge.satis.fatura" : "belge.alis_fatura";
                    if (irs.Count > 0 && Gor(satis ? "belge.satis.irsaliye" : "belge.alis.irsaliye"))
                    {
                        ozet.Add(new(satis ? "Faturalanmamış irsaliye" : "Faturası gelmemiş irsaliye", $"{irs.Count} · {Para(irs.Sum(x => x.tutar))}", "sar"));
                        if (Ekle(fatYetki))
                            oneriler.Add(new("irsFatura", "⇄", satis ? $"{irs.Count} irsaliye faturaya dönüştürülmeli" : $"{irs.Count} alış irsaliyesinin faturası girilmeli",
                                string.Join(", ", irs.Take(3).Select(x => $"{x.no} ({x.gun} gün)")),
                                irs.Take(3).Select((x, i) => new KayitEylemi(i == 0 ? $"{x.no} aç · Belge Dönüştür" : x.no, $"{irsListe}/{x.id}", i == 0)).ToList()));
                    }
                    var sipTur = satis ? 19 : 9;
                    var sip = await b.ListeAsync("""
                        select a.belge_id, max(a.belge_no), max(coalesce(s.teslim_tarihi::date, bsa.soz_teslim::date))
                          from public.v_belge_acik_satir a
                          join public.belge b on b.id = a.belge_id
                          join public.belge_satir s on s.id = a.satir_id
                          left join public.belge_satinalma bsa on bsa.id = b.id
                         where b.tur = @p0 and coalesce(b.tipi, 0) <> 30 and b.taraf_id = @p1
                         group by a.belge_id order by 3 nulls last limit 10
                        """, null, [sipTur, kayitId], o => new { id = o.GetInt32(0), no = o.IsDBNull(1) ? "" : o.GetString(1),
                                                                termin = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2) }, iptal);
                    var sipListe = satis ? "/siparis" : "/alis-siparis";
                    if (sip.Count > 0 && Gor(satis ? "belge.satis.siparis" : "belge.alis"))
                    {
                        ozet.Add(new("Açık sipariş", sip.Count.ToString()));
                        if (Ekle(satis ? "belge.satis.irsaliye" : "belge.alis.irsaliye"))
                            oneriler.Add(new("sipIrs", "🚚", satis ? $"{sip.Count} açık sipariş — irsaliye kes" : $"{sip.Count} açık alış siparişi — mal kabul",
                                string.Join(", ", sip.Take(3).Select(x => x.no + (x.termin is DateTime t ? $" (termin {t:dd.MM})" : ""))),
                                sip.Take(3).Select((x, i) => new KayitEylemi(i == 0 ? $"{x.no} aç · Belge Dönüştür" : x.no, $"{sipListe}/{x.id}", i == 0)).ToList()));
                    }
                    if (satis && Gor("belge.satis"))
                    {
                        var tek = await b.TekDegerAsync<int>("""
                            select count(*)::int from public.belge b
                             where b.tur = 18 and b.durum <> 2 and coalesce(b.teklif_durum, 1) in (1, 2) and b.taraf_id = @p0
                               and not exists (select 1 from public.belge_satir s join public.belge_satir hs
                                                 on hs.kaynak_tur = 30 and hs.kaynak_id = s.id where s.belge_id = b.id)
                            """, null, [kayitId], iptal);
                        if (tek > 0) oneriler.Add(new("teklif", "📝", $"{tek} cevap bekleyen teklif", "sunuldu / hazırlanıyor",
                            [new("Teklif Listesi", "/teklif")]));
                    }
                    // Yeni işlem - her düğme kendi Ekle yetkisiyle.
                    var yeni = new List<KayitEylemi>();
                    var ek = $"tarafId={kayitId}&tarafUnvan={adQ}";
                    if (satis)
                    {
                        if (Ekle("belge.satis.siparis")) yeni.Add(new("Sipariş", $"/siparis/yeni?{ek}"));
                        if (Ekle("belge.satis.fatura")) yeni.Add(new("Fatura", $"/belge/yeni?tur=15&{ek}"));
                        if (Ekle("belge.satis.irsaliye")) yeni.Add(new("İrsaliye", $"/satis-irsaliye/yeni?{ek}"));
                        if (Ekle("belge.satis")) yeni.Add(new("Teklif", $"/teklif/yeni?{ek}"));
                    }
                    else
                    {
                        if (Ekle("belge.alis")) yeni.Add(new("Alış siparişi", $"/alis-siparis/yeni?{ek}"));
                        if (Ekle("belge.alis_fatura")) yeni.Add(new("Alış faturası", $"/alis-fatura/yeni?{ek}"));
                        if (Ekle("belge.alis.irsaliye")) yeni.Add(new("Alış irsaliyesi", $"/alis-irsaliye/yeni?{ek}"));
                    }
                    if (yeni.Count > 0) oneriler.Add(new("yeni", "＋", "Yeni işlem", satis ? "müşteri seçili açılır" : "tedarikçi seçili açılır", yeni));
                    var gor = new List<KayitEylemi>();
                    if (Gor("finans.ekstre")) gor.Add(new("Ekstre", $"/ekstre?tur=cari&id={kayitId}"));
                    gor.Add(new(satis ? "Müşteri kartı" : "Tedarikçi kartı", $"{(satis ? "/cari" : "/tedarikci")}/{kayitId}"));
                    oneriler.Add(new("gor", "📄", "Görüntüle", "", gor));
                    break;
                }
                case "kisi":
                {
                    if (!Gor("cari.kisi")) break;
                    var bag = await b.TekAsync("""
                        select bt.id, coalesce(public.fn_taraf_ad(bt.unvan, bt.ad, bt.soyad)::varchar(160), ''), bt.musteri = 1
                          from public.taraf k join public.taraf bt on bt.id = k.bag_id where k.id = @p0
                        """, null, [kayitId], o => new { id = o.GetInt32(0), ad = o.GetString(1), musteri = o.GetBoolean(2) }, iptal);
                    if (bag is not null && Gor("cari"))
                        oneriler.Add(new("bagli", "🏢", $"Bağlı cari: {bag.ad}", "kişinin çalıştığı firma",
                            [new("Cari kartı", $"{(bag.musteri ? "/cari" : "/tedarikci")}/{bag.id}", true)]));
                    oneriler.Add(new("gor", "👤", "Kişi kartı", "", [new("Aç", $"/kisi/{kayitId}", true)]));
                    break;
                }
                case "personel":
                {
                    if (!Gor("personel")) break;
                    var p = await b.TekAsync("""
                        select (select count(*) from public.v_personel_belge_durum x
                                 where x.personel_id = @p0 and ((x.zorunlu = 1 and x.durum = 1) or x.durum = 2))::int,
                               (select count(*) from public.personel_izin i where i.taraf_id = @p0 and i.durum = 1)::int
                        """, null, [kayitId], o => new { belge = o.GetInt32(0), izinOnayda = o.GetInt32(1) }, iptal);
                    if (p is not null && p.belge > 0) ozet.Add(new("Eksik özlük belgesi", p.belge.ToString(), "sar"));
                    if (p is not null && p.izinOnayda > 0) ozet.Add(new("Onayda izin", p.izinOnayda.ToString()));
                    if (Ekle("ik.izin.liste") || Ekle("ik.izin"))
                        oneriler.Add(new("izin", "🌴", "İzin gir", "izin talebi oluşturulur", [new("İzin Listesi", "/personel-izin", true)]));
                    oneriler.Add(new("gor", "🪪", "Personel kartı", "", [new("Aç", $"/personel/{kayitId}", true)]));
                    break;
                }
                case "hasta":
                {
                    if (!Gor("hasta")) break;
                    var h = await b.TekAsync("""
                        with sb as (select coalesce(nullif(max(s.zaman_dilimi), ''), 'Europe/Istanbul') as dilim from public.sube s where s.id = @p1)
                        select (select r.id from public.randevu r, sb where r.hasta_id = @p0 and r.durum = 1
                                   and (r.baslangic at time zone sb.dilim)::date = (now() at time zone sb.dilim)::date
                                 order by r.baslangic limit 1),
                               (select to_char(r.baslangic at time zone sb.dilim, 'HH24:MI')
                                  from public.randevu r, sb where r.hasta_id = @p0 and r.durum = 1
                                   and (r.baslangic at time zone sb.dilim)::date = (now() at time zone sb.dilim)::date
                                 order by r.baslangic limit 1),
                               (select be.id from sb, public.belge be join public.belge_basvuru bb on bb.id = be.id
                                 where be.tur = 19 and be.tipi = 30 and be.durum not in (2, 6)
                                   and coalesce(bb.hasta_id, be.taraf_id) = @p0
                                   and (be.belge_tarihi at time zone sb.dilim)::date = (now() at time zone sb.dilim)::date
                                 order by be.belge_tarihi desc, be.id desc limit 1),
                               (select coalesce(sum(coalesce(a.hasta_provizyon_kalan, 0) + coalesce(a.hasta_ek_katki_kalan, 0)), 0)
                                  from public.v_belge_acik_satir a where a.taraf_id = @p0)
                        """, null, [kayitId, baglam.SubeId ?? 0],
                        o => new { randevu = o.IsDBNull(0) ? 0 : o.GetInt32(0), randevuAd = o.IsDBNull(1) ? "" : o.GetString(1),
                                   basvuru = o.IsDBNull(2) ? 0 : o.GetInt32(2), borc = o.IsDBNull(3) ? 0 : o.GetDecimal(3) }, iptal);
                    if (h is not null)
                    {
                        if (h.randevu > 0) ozet.Add(new("Bugün randevu", $"saat {h.randevuAd}"));
                        if (h.borc > 0.005m) ozet.Add(new("Hasta borcu", Para(h.borc), "sar"));
                        if (h.basvuru > 0 && Gor("belge"))
                            oneriler.Add(new("acikBasvuru", "📝", "Bugün başvurusu var — onu aç", "yeni başvuru açmak yerine mevcut başvuru",
                                [new("Başvuruyu aç", $"/basvuru/{h.basvuru}", true)]));
                        else if (Ekle("belge"))
                            oneriler.Add(new("basvuru", "📝", h.randevu > 0 ? $"Randevusundan başvuru aç — saat {h.randevuAd}" : "Yeni başvuru",
                                h.randevu > 0 ? "bugünkü randevu" : "", [new("Başvuru aç", $"/basvuru/yeni?{$"tarafId={kayitId}&tarafUnvan={adQ}"}", true)]));
                        if (h.borc > 0.005m && Gor("hasta.borc_takip"))
                            oneriler.Add(new("borc", "💳", $"Tahsil edilmemiş hasta payı {Para(h.borc)}", "", [new("Hasta Borç Takibi", "/hasta-borc-takibi")]));
                    }
                    var gor = new List<KayitEylemi> { new("Hasta kartı", $"/hasta/{kayitId}") };
                    if (Gor("randevu")) gor.Add(new("Randevu", "/randevu"));
                    oneriler.Add(new("gor", "🧑", "Görüntüle", "", gor));
                    break;
                }
            }
            return Results.Ok(new { ozet, oneriler });
        }).RequireAuthorization().WithTags("Gündem");
    }

    /// <summary>Faturası kesilmemiş irsaliye: kesin irsaliyenin en az bir satırında kesin hedef belgelere (kaynak_tur = 30)
    ///   aktarılmamış miktar kaldıysa - İrsaliye-Fatura Eşleşme icmalinin kuralı. @p0 belge türü · @p1 şubeler.</summary>
    private const string IrsaliyeSql = """
        select count(*)::int, coalesce(sum(b.genel_toplam), 0), coalesce(max(current_date - b.belge_tarihi::date), 0)::int
          from public.belge b
         where b.tur = @p0 and b.durum = 0
           and (b.sube_id is null or cardinality(@p1::int[]) = 0 or b.sube_id = any(@p1::int[]))
           and exists (select 1 from public.belge_satir s where s.belge_id = b.id and s.miktar > 0
                         and s.miktar - coalesce((select sum(hs.miktar) from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                                                   where hs.kaynak_tur = 30 and hs.kaynak_id = s.id and hb.durum = 0), 0) > 0.0001)
        """;

    private static readonly System.Globalization.CultureInfo Tr = new("tr-TR");
    private static string Para(decimal d) => d.ToString("N2", Tr);

    private sealed record Cari7(decimal Odeme7, int OdemeCari, decimal OdemeGecen, decimal TahsilBugun, decimal TahsilGecen,
        int TahsilGecenCari, int EnEskiGun, int Risk90, int RiskAsan, decimal Tahsil7, string OdemeIlk3);

    public sealed record GundemSatiri(string Ad, string Deger);
    public sealed record GundemEylemi(string Ad, string Yol);
    public sealed record GundemKarti(string Kod, string Baslik, string Ikon, string Sayi, string Ton,
        List<GundemSatiri> Satirlar, string Yol, List<GundemEylemi> Eylemler);
    public sealed record KayitOzeti(string Etiket, string Deger, string? Ton = null);
    public sealed record KayitEylemi(string Ad, string Yol, bool Birincil = false);
    public sealed record KayitOnerisi(string Kod, string Ikon, string Ad, string Neden, List<KayitEylemi> Eylemler);
}
