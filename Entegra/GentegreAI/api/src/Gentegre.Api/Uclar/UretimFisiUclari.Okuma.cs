using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>ÜRETİM FİŞİ - OKUMA VE YAZMA YARDIMCILARI: mamul bandı, ağaçtan doldurma, satır / operasyon / kontrol yazımı, fiş okuma.</summary>
public static partial class UretimFisiUclari
{
    private sealed record AgacIzi(int Id, string Kod, short Surum, short Birim, decimal Cikti, int? SarfDepoId, int? MamulDepoId, int? FireDepoId);

    /// <summary>Ağaç izi: verilen ağaç ya da mamulün aktif varsayılanı; yoksa null (fiş ağaçsız da kesilebilir - "＋ Malzeme" ile).</summary>
    private static async Task<AgacIzi?> AgacIziAsync(NpgsqlConnection b, NpgsqlTransaction? t, int? agacId, int stokId, CancellationToken iptal)
    {
        var sql = agacId is > 0
            ? "select id, kod, surum, birim, coalesce(nullif(cikti_miktar, 0), 1), sarf_depo_id, mamul_depo_id, fire_depo_id from public.urun_agaci where id = @p0"
            : "select id, kod, surum, birim, coalesce(nullif(cikti_miktar, 0), 1), sarf_depo_id, mamul_depo_id, fire_depo_id from public.urun_agaci "
            + " where stok_id = @p0 and durum = 0 order by varsayilan desc, surum desc limit 1";
        return await b.TekAsync(sql, t, [agacId is > 0 ? agacId : stokId],
            o => new AgacIzi(o.GetInt32(0), o.GetString(1), o.GetInt16(2), o.GetInt16(3), o.GetDecimal(4),
                             o.IsDBNull(5) ? null : o.GetInt32(5), o.IsDBNull(6) ? null : o.GetInt32(6), o.IsDBNull(7) ? null : o.GetInt32(7)), iptal);
    }

    private static async Task<IDictionary<string, object?>?> MamulBilgisiAsync(NpgsqlConnection b, NpgsqlTransaction? t, int stokId, CancellationToken iptal)
        => await b.TekAsync("""
            select s.id, s.kod, s.ad, s.ana_birim as "birimKodu",
                   coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                              where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim), '') as "birimAdi",
                   s.izleme, s.raf_omru_sure as "rafOmruSure", s.raf_omru_birim as "rafOmruBirim",
                   coalesce((select k.ad from public.kategori k where k.id = s.kategori), '') as kategori,
                   a.id as "agacId", a.kod as "agacKod", a.surum as "agacSurum", a.cikti_miktar as "agacCikti",
                   a.sarf_depo_id as "sarfDepoId", a.mamul_depo_id as "mamulDepoId",
                   (select count(*) from public.urun_agaci x where x.stok_id = s.id and x.durum = 0) as "agacSayisi",
                   coalesce((select json_agg(json_build_object('depoId', d.depo_id, 'depoAdi', dp.ad, 'kalan', d.kalan) order by dp.ad)
                               from public.stok_durum d join public.depo dp on dp.id = d.depo_id
                              where d.stok_id = s.id and d.kalan <> 0), '[]'::json)::text as "depolar"
              from public.stok s
              left join lateral (select * from public.urun_agaci x where x.stok_id = s.id and x.durum = 0
                                  order by x.varsayilan desc, x.surum desc limit 1) a on true
             where s.id = @p0
            """, t, [stokId], OkuyucuGenisletmeleri.Sozluk, iptal);

    private sealed record DoldurSonucu(object? Agac, List<object> Satirlar);

    /// <summary>
    /// Ağaçtan satır önerisi. Sarf: ağaç miktarı ÷ ağaç çıktısı = birim ihtiyaç; plan = birim ihtiyaç × miktar × (1 + fire%).
    /// Gider: operasyonlar - (hazırlık + birim süre × miktar) / 60 saat × (operasyon ücreti, yoksa iş merkezi). Çıktı: ana ürün.
    /// Birim maliyet yönteme göre; sarf deposundaki kalan satırla gelir (eksik vurgusu ekranda).
    /// </summary>
    private static async Task<DoldurSonucu> AgactanDoldurAsync(NpgsqlConnection b, NpgsqlTransaction? t, int stokId, int? agacId,
                                                               decimal miktar, int? sarfDepoId, short yontem, CancellationToken iptal)
    {
        var agac = await AgacIziAsync(b, t, agacId, stokId, iptal)
            ?? throw GentegreHatasi.IsKurali("Bu mamul için aktif ürün ağacı yok - önce ağaç tanımlayın ya da malzemeleri elle ekleyin.");
        var depo = sarfDepoId ?? agac.SarfDepoId;
        var maliyetFn = yontem == 1 ? "public.fn_uretim_stok_son_maliyeti" : "public.fn_uretim_stok_maliyeti";
        var sarf = await b.ListeAsync($"""
            select s.bilesen_stok_id, st.kod, st.ad, st.izleme, s.birim, round(s.miktar / @p1, 6) as birim_ihtiyac, s.fire_yuzde,
                   {maliyetFn}(s.bilesen_stok_id) as maliyet,
                   coalesce((select d.kalan from public.stok_durum d where d.stok_id = s.bilesen_stok_id and d.depo_id = coalesce(s.depo_id, @p2)), 0) as kalan,
                   coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                              where kl.kod = 'stok.ana_birim' and kd.deger = st.ana_birim), '') as birim_adi,
                   s.aciklama
              from public.urun_agaci_satir s join public.stok st on st.id = s.bilesen_stok_id
             where s.agac_id = @p0 order by s.sira, s.id
            """, t, [agac.Id, agac.Cikti, depo],
            o => new { StokId = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2), Izleme = (int)o.GetInt16(3), Birim = o.GetInt16(4),
                       BirimIhtiyac = o.GetDecimal(5), Fire = o.GetDecimal(6), Maliyet = o.GetDecimal(7), Kalan = o.GetDecimal(8),
                       BirimAdi = o.GetString(9), Aciklama = o.GetString(10) }, iptal);
        var opr = await b.ListeAsync("""
            select o.ad, o.hazirlik_dk, o.birim_sure_dk, coalesce(nullif(o.saat_ucreti, 0), im.saat_ucreti, 0), o.is_merkezi_id
              from public.urun_agaci_operasyon o left join public.is_merkezi im on im.id = o.is_merkezi_id
             where o.agac_id = @p0 order by o.sira, o.id
            """, t, [agac.Id], o => new { Ad = o.GetString(0), Hazirlik = o.GetDecimal(1), BirimSure = o.GetDecimal(2),
                                          Ucret = o.GetDecimal(3), IsMerkeziId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4) }, iptal);
        var mamul = await MamulBilgisiAsync(b, t, stokId, iptal);

        var satirlar = new List<object>();
        var sira = 0;
        foreach (var s in sarf)
        {
            var plan = decimal.Round(s.BirimIhtiyac * miktar * (1 + s.Fire / 100), 6);
            satirlar.Add(new { sira = ++sira, grup = 1, stokId = s.StokId, stokKod = s.Kod, stokAd = s.Ad, izleme = s.Izleme, birim = s.Birim,
                               birimAdi = s.BirimAdi, birimIhtiyac = decimal.Round(s.BirimIhtiyac * (1 + s.Fire / 100), 6), planMiktar = plan,
                               miktar = plan, birimMaliyet = s.Maliyet, tutar = decimal.Round(plan * s.Maliyet, 4), depoKalan = s.Kalan,
                               eksik = Math.Max(0, plan - s.Kalan), anaUrun = false, elleMaliyet = false, fireTuru = 1, aciklama = s.Aciklama });
        }
        foreach (var o in opr)
        {
            var saat = decimal.Round((o.Hazirlik + o.BirimSure * miktar / agac.Cikti) / 60, 3);
            if (saat <= 0 || o.Ucret <= 0) continue;
            satirlar.Add(new { sira = ++sira, grup = 2, stokId = (int?)null, stokKod = "", stokAd = o.Ad, izleme = 0, birim = 0,
                               birimAdi = "Saat", birimIhtiyac = 0m, planMiktar = saat, miktar = saat, birimMaliyet = o.Ucret,
                               tutar = decimal.Round(saat * o.Ucret, 4), depoKalan = 0m, eksik = 0m, anaUrun = false, elleMaliyet = false,
                               fireTuru = 1, aciklama = "operasyon: " + o.Ad, isMerkeziId = o.IsMerkeziId });
        }
        var mamulBirim = mamul is null ? "" : Convert.ToString(mamul["birimAdi"]) ?? "";
        satirlar.Add(new { sira = ++sira, grup = 4, stokId = stokId, stokKod = mamul is null ? "" : Convert.ToString(mamul["kod"]) ?? "",
                           stokAd = mamul is null ? "" : Convert.ToString(mamul["ad"]) ?? "", izleme = mamul is null ? 0 : Convert.ToInt32(mamul["izleme"]),
                           birim = agac.Birim, birimAdi = mamulBirim, birimIhtiyac = 1m, planMiktar = miktar, miktar, birimMaliyet = 0m,
                           tutar = 0m, depoKalan = 0m, eksik = 0m, anaUrun = true, elleMaliyet = false, fireTuru = 1, aciklama = "ana ürün" });
        // camelCase serileştirme: SarfDepoId / sarfDepoId çakışır - ağacın kendi deposu ayrı adla.
        return new DoldurSonucu(new { id = agac.Id, kod = agac.Kod, surum = agac.Surum, cikti = agac.Cikti,
                                      agacSarfDepoId = agac.SarfDepoId, mamulDepoId = agac.MamulDepoId, sarfDepoId = depo }, satirlar);
    }

    private static async Task SatirlariYazAsync(NpgsqlConnection b, NpgsqlTransaction t, int fisId, FisIstegi istek, int kullaniciId, CancellationToken iptal)
    {
        var sira = 0;
        foreach (var s in istek.Satirlar)
        {
            if (s.Miktar <= 0 && s.Grup != 2) continue;      // boş satır kaydedilmez
            // Gider satırı: tutar = miktar × birim (saat × ücret); 0 saatli tek tutar da olabilir (basit "İşçilik / gider").
            var tutar = decimal.Round(s.Miktar * s.BirimMaliyet, 4);
            await b.CalistirAsync("""
                insert into public.uretim_fisi_satir
                       (fis_id, sira, grup, stok_id, masraf_id, ad, ana_urun, birim_ihtiyac, plan_miktar, miktar, birim,
                        birim_maliyet, tutar, elle_maliyet, fire_turu, izlemler, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15::jsonb, @p16, @p17)
                """, t, [fisId, ++sira, s.Grup, s.Grup == 2 ? null : s.StokId, s.MasrafId, (s.Ad ?? "").Trim(),
                         (short)(s.Grup == 4 && s.AnaUrun ? 1 : 0), s.BirimIhtiyac, s.PlanMiktar, s.Miktar, s.Birim, s.BirimMaliyet, tutar,
                         (short)(s.ElleMaliyet ? 1 : 0), s.FireTuru == 2 ? (short)2 : (short)1,
                         s.Izlemler is { ValueKind: JsonValueKind.Array } iz && iz.GetArrayLength() > 0 ? iz.GetRawText() : null,
                         s.Aciklama ?? "", kullaniciId], iptal);
        }
        await OperasyonlariYazAsync(b, t, fisId, istek.Operasyonlar ?? [], kullaniciId, iptal);
        var ks = 0;
        foreach (var k in istek.Kontroller ?? [])
        {
            if (string.IsNullOrWhiteSpace(k.Ad)) continue;
            await b.CalistirAsync("""
                insert into public.uretim_fisi_kontrol (fis_id, sira, ad, kriter, sonuc, yapan_id, zaman, notu, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
                """, t, [fisId, ++ks, k.Ad.Trim(), k.Kriter ?? "", k.Sonuc is 1 or 2 ? k.Sonuc : (short)0,
                         k.Sonuc == 0 ? null : kullaniciId, k.Sonuc == 0 ? null : Saat.Simdi, k.Notu ?? "", kullaniciId], iptal);
        }
    }

    private static async Task OperasyonlariYazAsync(NpgsqlConnection b, NpgsqlTransaction t, int fisId, FisOperasyonIstegi[] satirlar,
                                                    int kullaniciId, CancellationToken iptal)
    {
        var sira = 0;
        foreach (var o in satirlar)
        {
            if (string.IsNullOrWhiteSpace(o.Ad) && o.TarafId is not > 0) continue;
            await b.CalistirAsync("""
                insert into public.uretim_fisi_operasyon
                       (fis_id, sira, ad, taraf_id, is_merkezi_id, bas, bit, mola_dk, sure_saat, adet, saat_ucreti, durum, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13)
                """, t, [fisId, ++sira, (o.Ad ?? "").Trim(), o.TarafId, o.IsMerkeziId, o.Bas, o.Bit, o.MolaDk, o.SureSaat, o.Adet,
                         o.SaatUcreti, o.Durum == 0 ? (short)0 : (short)1, o.Aciklama ?? "", kullaniciId], iptal);
        }
    }

    private sealed record Baslik(int Id, string No, short Durum, string Seviye, int StokId, int? EmirId, decimal Miktar, short Birim,
                                 int? SarfDepoId, int? GirisDepoId, int? SarfBelgeId, int? GirisBelgeId, int? FireBelgeId,
                                 short MaliyetYontemi, bool OtomatikHesap, string PartiNo, DateTime? Bas, int SubeId, long Surum, string Aciklama);

    private static async Task<Baslik> BaslikOkuAsync(NpgsqlConnection b, NpgsqlTransaction? t, int id, CancellationToken iptal, bool kilitle = false)
        => await b.TekAsync("""
            select id, no, durum, seviye, stok_id, emir_id, miktar, birim, sarf_depo_id, giris_depo_id, sarf_belge_id, giris_belge_id,
                   fire_belge_id, maliyet_yontemi, otomatik_hesap, parti_no, bas, sube_id, xmin::text::bigint, aciklama
              from public.uretim_fisi where id = @p0
            """ + (kilitle ? " for update" : ""), t, [id],
            o => new Baslik(o.GetInt32(0), o.GetString(1), o.GetInt16(2), o.GetString(3), o.GetInt32(4),
                            o.IsDBNull(5) ? null : o.GetInt32(5), o.GetDecimal(6), o.GetInt16(7),
                            o.IsDBNull(8) ? null : o.GetInt32(8), o.IsDBNull(9) ? null : o.GetInt32(9),
                            o.IsDBNull(10) ? null : o.GetInt32(10), o.IsDBNull(11) ? null : o.GetInt32(11),
                            o.IsDBNull(12) ? null : o.GetInt32(12), o.GetInt16(13), o.GetInt16(14) == 1, o.GetString(15),
                            o.IsDBNull(16) ? null : o.GetDateTime(16), o.GetInt32(17), o.GetInt64(18), o.GetString(19)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Üretim fişi bulunamadı.");

    private sealed record FisTam(IDictionary<string, object?> Fis, List<IDictionary<string, object?>> Satirlar,
                                 List<IDictionary<string, object?>> Operasyonlar, List<IDictionary<string, object?>> Kontroller,
                                 List<IDictionary<string, object?>> Belgeler, IDictionary<string, object?>? Emir);

    private static async Task<FisTam> FisOkuAsync(NpgsqlConnection b, NpgsqlTransaction? t, int id, CancellationToken iptal)
    {
        var fis = await b.TekAsync("""
            select f.id, f.no, f.durum, f.seviye, f.stok_id as "stokId", st.kod as "stokKod", st.ad as "stokAd", st.izleme,
                   coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                              where kl.kod = 'stok.ana_birim' and kd.deger = st.ana_birim), '') as "birimAdi",
                   coalesce((select k.ad from public.kategori k where k.id = st.kategori), '') as kategori,
                   st.raf_omru_sure as "rafOmruSure", st.raf_omru_birim as "rafOmruBirim",
                   f.agac_id as "agacId", coalesce(a.kod, '') as "agacKod", f.agac_surum as "agacSurum",
                   f.emir_id as "emirId", f.miktar, f.uretilen, f.birim, f.bas, f.bit,
                   f.sarf_depo_id as "sarfDepoId", coalesce(sd.ad, '') as "sarfDepoAdi",
                   f.giris_depo_id as "girisDepoId", coalesce(gd.ad, '') as "girisDepoAdi",
                   f.is_merkezi_id as "isMerkeziId", coalesce(im.ad, '') as "isMerkeziAdi",
                   f.sorumlu_id as "sorumluId", coalesce(public.fn_taraf_ad(so.unvan, so.ad, so.soyad)::varchar(120), '') as "sorumluAdi",
                   f.onaylayan_id as "onaylayanId", f.proje_id as "projeId", f.parti_no as "partiNo",
                   f.maliyet_yontemi as "maliyetYontemi", f.otomatik_hesap as "otomatikHesap", f.doviz_cinsi as "dovizCinsi",
                   f.malzeme, f.iscilik, f.fire_normal as "fireNormal", f.fire_anormal as "fireAnormal", f.yan_urun as "yanUrun",
                   f.toplam, f.birim_maliyet as "birimMaliyet",
                   f.sarf_belge_id as "sarfBelgeId", f.giris_belge_id as "girisBelgeId", f.fire_belge_id as "fireBelgeId",
                   f.gerceklesme_an as "gerceklesmeAn", coalesce(gk.ad, '') as "gerceklestirenAdi",
                   f.serbest_an as "serbestAn", coalesce(sk.ad, '') as "serbestAdi", f.serbest_gerekce as "serbestGerekce",
                   f.ters_an as "tersAn", coalesce(tk.ad, '') as "tersAdi", f.ters_neden as "tersNeden",
                   f.aciklama, f.sube_id as "subeId", f.ekleme_tarihi as "eklemeTarihi", coalesce(ek.ad, '') as "ekleyenAdi",
                   f.xmin::text::bigint as surum,
                   coalesce((select d.kalan from public.stok_durum d where d.stok_id = f.stok_id and d.depo_id = f.giris_depo_id), 0) as "girisDepoKalan"
              from public.uretim_fisi f
              join public.stok st on st.id = f.stok_id
              left join public.urun_agaci a on a.id = f.agac_id
              left join public.depo sd on sd.id = f.sarf_depo_id
              left join public.depo gd on gd.id = f.giris_depo_id
              left join public.is_merkezi im on im.id = f.is_merkezi_id
              left join public.taraf so on so.id = f.sorumlu_id
              left join public.v_kullanici_lookup gk on gk.id = f.gerceklestiren
              left join public.v_kullanici_lookup sk on sk.id = f.serbest_kullanici_id
              left join public.v_kullanici_lookup tk on tk.id = f.ters_kullanici_id
              left join public.v_kullanici_lookup ek on ek.id = f.ekleyen
             where f.id = @p0
            """, t, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Üretim fişi bulunamadı.");

        var satirlar = await b.ListeAsync("""
            select s.id, s.sira, s.grup, s.stok_id as "stokId", coalesce(st.kod, '') as "stokKod",
                   case when s.grup = 2 then coalesce(nullif(s.ad, ''), m.ad, '') else coalesce(st.ad, '') end as "stokAd",
                   coalesce(st.izleme, 0) as izleme, s.masraf_id as "masrafId", s.ad, s.ana_urun as "anaUrun",
                   s.birim_ihtiyac as "birimIhtiyac", s.plan_miktar as "planMiktar", s.miktar, s.birim,
                   case when s.grup = 2 then 'Saat' else coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                              where kl.kod = 'stok.ana_birim' and kd.deger = st.ana_birim), '') end as "birimAdi",
                   s.birim_maliyet as "birimMaliyet", s.tutar, s.elle_maliyet as "elleMaliyet", s.fire_turu as "fireTuru",
                   s.izlemler::text as "izlemlerJson", s.aciklama,
                   coalesce((select d.kalan from public.stok_durum d where d.stok_id = s.stok_id and d.depo_id = f.sarf_depo_id), 0) as "depoKalan"
              from public.uretim_fisi_satir s
              join public.uretim_fisi f on f.id = s.fis_id
              left join public.stok st on st.id = s.stok_id
              left join public.masraf m on m.id = s.masraf_id
             where s.fis_id = @p0 order by s.grup, s.sira, s.id
            """, t, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
        foreach (var s in satirlar)
        {
            // jsonb metni gerçek JSON olarak dönsün (istemci dizi bekler).
            s["izlemler"] = s["izlemlerJson"] is string j && j.Length > 0 ? JsonSerializer.Deserialize<JsonElement>(j) : null;
            s.Remove("izlemlerJson");
        }

        var operasyonlar = await b.ListeAsync("""
            select o.id, o.sira, o.ad, o.taraf_id as "tarafId", coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), '') as "personelAdi",
                   o.is_merkezi_id as "isMerkeziId", coalesce(im.ad, '') as "isMerkeziAdi", o.bas, o.bit, o.mola_dk as "molaDk",
                   o.sure_saat as "sureSaat", o.adet, o.saat_ucreti as "saatUcreti", o.tutar, o.durum, o.aciklama
              from public.uretim_fisi_operasyon o
              left join public.taraf p on p.id = o.taraf_id
              left join public.is_merkezi im on im.id = o.is_merkezi_id
             where o.fis_id = @p0 order by o.sira, o.id
            """, t, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

        var kontroller = await b.ListeAsync("""
            select k.id, k.sira, k.ad, k.kriter, k.sonuc, k.yapan_id as "yapanId", coalesce(u.ad, '') as "yapanAdi", k.zaman, k.notu
              from public.uretim_fisi_kontrol k left join public.v_kullanici_lookup u on u.id = k.yapan_id
             where k.fis_id = @p0 order by k.sira, k.id
            """, t, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

        var belgeler = await b.ListeAsync("""
            select b.id, b.tur, coalesce(t.ad, '') as "turAdi", b.belge_tarihi as "belgeTarihi",
                   nullif(btrim(b.belge_seri || ' ' || b.belge_no), '') as "belgeNo", b.genel_toplam as tutar,
                   coalesce(gd.ad, cd.ad, '') as "depoAdi"
              from public.belge b
              left join public.kasa_islem_turu t on t.kod = b.tur
              left join public.depo gd on gd.id = b.giris_depo_id
              left join public.depo cd on cd.id = b.cikis_depo_id
             where b.kaynak_tur = @p1 and b.kaynak_id = @p0 order by b.tur, b.id
            """, t, [id, BelgeTuru.KaynakTurUretimFisi], OkuyucuGenisletmeleri.Sozluk, iptal);

        var emir = fis["emirId"] is int eid ? await b.TekAsync("""
            select e.id, e.no, e.durum, e.adet, e.uretilen_adet as "uretilenAdet", e.termin
              from public.uretim_emri e where e.id = @p0
            """, t, [eid], OkuyucuGenisletmeleri.Sozluk, iptal) : null;

        return new FisTam(fis, satirlar, operasyonlar, kontroller, belgeler, emir);
    }

    private static object LotSatiri(NpgsqlDataReader o) => new
    {
        belgeId = o.GetInt32(0), stokKod = o.GetString(1), stokAd = o.GetString(2), lotNo = o.GetString(3), seriNo = o.GetString(4),
        skt = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), miktar = o.GetDecimal(6), tedarikci = o.GetString(7),
    };
}
