using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>Seçilen kaydın önerileri (/api/gundem/kayit). Ortak tipler ve kurallar GundemUclari.cs'de.</summary>
public static partial class GundemUclari
{
    private static void KayitOneriUcu(IEndpointRouteBuilder yol)
    {
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
}
