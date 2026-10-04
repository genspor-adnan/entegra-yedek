using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TALEPLERİM (mockup <c>Ekranlar/Taleplerim/taleplerim.html</c>): kişinin
/// KENDİ açtığı izin, avans, masraf, belge, arıza ve malzeme talepleri tek
/// listede, onay zincirinde nerede beklediğiyle.
///
/// YETKİ YOK: yalnız oturumdaki kişinin (taraf = kullanıcı) kayıtları döner;
/// başkasının talebi bu uçtan hiç okunamaz. Talep açma / gönderme / geri
/// çekme mevcut modül uçlarındadır - onlar kendi kaydında İK yetkisi aramaz
/// (<see cref="KendiTalebi"/>).
///
/// DURUM GRUBU sunucuda: altı modülün altı ayrı durum kodu var; istemci
/// "açık / tamamlanan / reddedilen" çiplerini kodlardan çıkarsaydı her modül
/// eklenişinde iki yer ayrışırdı.
///   taslak · onayda · acik (onaylı, işi sürüyor) · tamam · red · iptal
/// </summary>
public static class TaleplerimUclari
{
    // islem_log.tablo_id = onay.kaynak_tur
    private const int IzinTur = 904, AvansTur = 1257, MasrafTur = 1312,
                      BelgeTur = 1314, SatinalmaTur = 1241;

    /// <summary>
    /// KİŞİNİN TÜM TALEPLERİ (izin, avans, masraf, belge, arıza, malzeme) tek
    /// listede; @p0 = taraf. Taleplerim paneli ve personel kartının "Talepler"
    /// sekmesi aynı sorguyu kullanır - durum adları iki yerde ayrışmasın.
    /// </summary>
    internal static string TalepSorgusu(string suzgec, int sinir, string sirala = "t.son_hareket desc") => $$"""
                with t as (
                  select 'izin' as tur, i.id, i.izin_no as no, i.durum,
                         case i.tur when 1 then 'Yıllık izin' when 2 then 'Mazeret izni'
                                    when 3 then 'Rapor' when 4 then 'Ücretsiz izin'
                                    else 'İzin' end as baslik,
                         to_char(i.baslangic_tarihi, 'DD.MM')
                           || case when i.bitis_tarihi <> i.baslangic_tarihi
                                   then '–' || to_char(i.bitis_tarihi, 'DD.MM') else '' end
                           || case when i.saat_bas is not null
                                   then ' ' || i.saat_bas || '–' || i.saat_bit else '' end
                           || ' · ' || replace(rtrim(to_char(i.gun, 'FM990.9'), '.'), '.', ',') || ' gün' as detay,
                         null::numeric as tutar,
                         case i.durum when 0 then 'taslak' when 1 then 'onayda'
                              when 2 then case when i.bitis_tarihi >= current_date then 'acik' else 'tamam' end
                              when 3 then 'red' else 'iptal' end as grup,
                         case i.durum when 0 then 'Taslak' when 1 then 'Onayda'
                              when 2 then case when current_date between i.baslangic_tarihi and i.bitis_tarihi
                                               then 'İzinde' when i.bitis_tarihi < current_date then 'Kullanıldı'
                                               else 'Onaylandı' end
                              when 3 then 'Reddedildi' else 'İptal' end as durum_adi,
                         nullif(i.red_neden, '') as red_neden,
                         i.ekleme_tarihi, coalesce(i.degistirme_tarihi, i.ekleme_tarihi) as son_hareket,
                         coalesce(i.degistiren, 0) as son_degistiren,
                         {{IzinTur}} as kaynak_tur
                    from public.personel_izin i where i.taraf_id = @p0
                  union all
                  select 'avans', a.id, a.avans_no, a.durum, 'Avans',
                         a.taksit_sayisi || ' taksit' || coalesce(' · ' || nullif(a.gerekce, ''), ''),
                         a.tutar,
                         case a.durum when 0 then 'taslak' when 1 then 'onayda' when 2 then 'acik'
                              when 3 then 'red' when 4 then 'acik' when 5 then 'tamam' else 'iptal' end,
                         case a.durum when 0 then 'Taslak' when 1 then 'Onayda' when 2 then 'Ödenecek'
                              when 3 then 'Reddedildi' when 4 then 'Ödendi · kesintide'
                              when 5 then 'Kapandı' else 'İptal' end,
                         nullif(a.red_neden, ''),
                         a.ekleme_tarihi, coalesce(a.degistirme_tarihi, a.ekleme_tarihi), coalesce(a.degistiren, 0), {{AvansTur}}
                    from public.personel_avans a where a.taraf_id = @p0
                  union all
                  select 'masraf', m.id, m.beyan_no, m.durum, 'Masraf',
                         coalesce(nullif(m.aciklama, ''), 'Masraf beyanı')
                           || ' · ' || (select count(*) from public.personel_masraf_satir s where s.beyan_id = m.id) || ' belge',
                         m.toplam_tutar,
                         case m.durum when 0 then 'taslak' when 1 then 'onayda' when 2 then 'tamam'
                              when 3 then 'red' else 'iptal' end,
                         case m.durum when 0 then 'Taslak' when 1 then 'Onayda' when 2 then 'Onaylandı'
                              when 3 then 'Reddedildi' else 'İptal' end,
                         nullif(m.red_neden, ''),
                         m.ekleme_tarihi, coalesce(m.degistirme_tarihi, m.ekleme_tarihi), coalesce(m.degistiren, 0), {{MasrafTur}}
                    from public.personel_masraf m where m.taraf_id = @p0
                  union all
                  select 'belge', g.id, g.talep_no, g.durum,
                         case g.tur when 1 then 'Çalışma belgesi' when 2 then 'Maaş yazısı'
                                    when 3 then 'Vize yazısı' when 4 then 'SGK hizmet dökümü'
                                    else 'Belge' end,
                         coalesce(nullif(g.muhatap, ''), 'ilgili makama') || ' · ' || g.adet || ' adet',
                         null::numeric,
                         case g.durum when 0 then 'taslak' when 1 then 'onayda' when 2 then 'acik'
                              when 3 then 'red' when 4 then 'acik' when 5 then 'tamam' else 'iptal' end,
                         case g.durum when 0 then 'Taslak' when 1 then 'Onayda' when 2 then 'Hazırlanıyor'
                              when 3 then 'Reddedildi' when 4 then 'Hazır' when 5 then 'Teslim edildi'
                              else 'İptal' end,
                         nullif(g.red_neden, ''),
                         g.ekleme_tarihi, coalesce(g.degistirme_tarihi, g.ekleme_tarihi), coalesce(g.degistiren, 0), {{BelgeTur}}
                    from public.personel_belge_talep g where g.taraf_id = @p0
                  union all
                  select 'ariza', z.id, z.talep_no, z.durum, 'Arıza',
                         left(z.aciklama, 80) || coalesce(' · ' || nullif(z.konum, ''), ''),
                         null::numeric,
                         -- ÇÖZÜLDÜ AÇIKTA KALIR (954): bildirenin onayını bekliyor.
                         case when z.durum in (1, 2, 3, 4) then 'acik' when z.durum = 5 then 'tamam'
                              else 'iptal' end,
                         case z.durum when 1 then 'Açık' when 2 then 'Atandı' when 3 then 'Serviste'
                              when 4 then 'Çözüldü · onayınızı bekliyor' when 5 then 'Kapandı' else 'İptal' end,
                         null::varchar,
                         z.ekleme_tarihi, coalesce(z.degistirme_tarihi, z.ekleme_tarihi), coalesce(z.degistiren, 0), 0
                    from public.ariza_talep z where z.talep_eden = @p0
                  union all
                  select 'malzeme', s.id::int, s.talep_no, s.durum, 'Malzeme talebi',
                         coalesce(nullif(s.gerekce, ''), 'Satınalma talebi'),
                         nullif(s.tahmini_tutar, 0),
                         case s.durum when 0 then 'taslak' when 1 then 'onayda' when 3 then 'red'
                              when 8 then 'iptal' when 5 then 'tamam' else 'acik' end,
                         case s.durum when 0 then 'Taslak' when 1 then 'Onayda' when 2 then 'Onaylandı'
                              when 3 then 'Reddedildi' when 4 then 'Teklifte' when 5 then 'Siparişte'
                              else 'İptal' end,
                         nullif(s.red_neden, ''),
                         s.ekleme_tarihi, coalesce(s.degistirme_tarihi, s.ekleme_tarihi), coalesce(s.degistiren, 0), {{SatinalmaTur}}
                    from public.satinalma_talep s where s.isteyen_id = @p0
                )
                select t.tur, t.id, t.no, t.durum, t.baslik, t.detay, t.tutar, t.grup,
                       t.durum_adi as "durumAdi", t.red_neden as "redNeden",
                       t.ekleme_tarihi as "eklemeTarihi", t.son_hareket as "sonHareket",
                       t.son_degistiren as "sonDegistiren",
                       t.kaynak_tur as "kaynakTur",
                       ob.adim_ad as "adimAd", ob.gecikme_gun as "gecikmeGun",
                       ob.baslama as "adimBaslama"
                  from t
                  -- SIRADAKİ BASAMAK: zincirin en küçük sıralı bekleyen basamağı
                  left join lateral (
                       select v.adim_ad, v.gecikme_gun, v.baslama
                         from public.v_onay_bekleyen v
                        where t.grup = 'onayda' and v.kaynak_tur = t.kaynak_tur
                          and v.kaynak_id = t.id
                        order by v.sira limit 1) ob on true
                 where {{suzgec}}
                 order by {{sirala}}
                 limit {{sinir}}
                """;

    public static void TaleplerimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ben").WithTags("Taleplerim").RequireAuthorization();

        // PERSONEL KARTI "TALEPLER" SEKMESİ (kullanıcı: "izinler sekmesi yerine
        //   Talepler sekmesi olsa ve tüm talepler sondan başa doğru sıralı
        //   listelense"): süzgeç yok, en yeni talep üstte.
        yol.MapGet("/api/ik/personel/{tarafId:int}/talepler", async (int tarafId, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIsteKendi(tarafId, "personel", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync(TalepSorgusu("true", 1000, "t.ekleme_tarihi desc, t.id desc"),
                null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        }).WithTags("Taleplerim").RequireAuthorization();

        grup.MapGet("/talepler", async (BaglamCozucu cozucu, VeriKaynagi veri,
                                         HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var ben = baglam.KullaniciId;

            // SON 1 YIL + hâlâ açık olanlar: eski tamamlanmış talepler listeyi
            //   şişirmesin; açık bir talep ne kadar eski olursa olsun görünür.
            // SON 1 YIL + hâlâ açık olanlar (TalepSorgusu).
            var satirlar = await b.ListeAsync(TalepSorgusu(
                "t.grup in ('taslak', 'onayda', 'acik') or t.son_hareket > now() - interval '1 year'", 300),
                null, [ben], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ONAYIMI BEKLEYEN: yalnız kişiye ya da vekâletle kişiye atanmış
            //   basamaklar. Rol basamakları (kim yetkiliyse) Onayımdakiler
            //   ekranında listelenir; rozete katılsaydı rol basamağı olan
            //   kurumda herkesin rozeti hep dolu görünürdü.
            // ONAYLAR (gelen_talepler mockup): panel ve "Bana gelenler" satırları
            //   - kim istedi, ne, hangi basamak; karar /api/onay/kayit/../karar ile.
            var onaylar = await b.ListeAsync("""
                select v.kaynak_tur as "kaynakTur", v.kaynak_id as "kaynakId",
                       v.kayit_no as "kayitNo", v.konu, v.talep_eden as "talepEden",
                       v.adim_ad as "adimAd", v.akis_kod as "akisKod", v.akis_ad as "akisAd",
                       v.olcu, v.olcu_adi as "olcuAdi", v.baslama, v.gecikme_gun as "gecikmeGun"
                  from public.v_onay_kutusu v
                 where v.durum = 0
                   and (v.atanan_kullanici_id = @p0
                        or exists (select 1 from public.onay_vekalet k
                                    where k.devreden_id = v.atanan_kullanici_id
                                      and k.devralan_id = @p0 and k.aktif = 1
                                      and current_date between k.baslangic and k.bitis))
                 order by v.gecikme_gun desc, v.baslama
                 limit 50
                """, null, [ben], OkuyucuGenisletmeleri.Sozluk, iptal);
            var onayBekleyen = (long)onaylar.Count;

            // ÖDENECEK: onaylanmış ama ödenmemiş avans + onaylanmış masraf
            //   (masrafın ödemesi bu modülde değil; onaylı = bordroya/kasaya gider).
            var odenecek = await b.TekDegerAsync<decimal?>("""
                select coalesce((select sum(tutar) from public.personel_avans
                                  where taraf_id = @p0 and durum = 2), 0)
                     + coalesce((select sum(toplam_tutar) from public.personel_masraf
                                  where taraf_id = @p0 and durum = 2
                                    and coalesce(degistirme_tarihi, ekleme_tarihi) > now() - interval '60 days'), 0)
                """, null, [ben], iptal);

            // PERSONEL Mİ: izin / avans / masraf / belge personel kartı ister
            //   (taraf_personel). Personel olmayan kullanıcıda (ör. admin) bu
            //   talepler açılamaz - ekran düğmeleri kapatır, hata vermez.
            var personel = await b.TekDegerAsync<bool>(
                "select exists (select 1 from public.taraf_personel where id = @p0)",
                null, [ben], iptal);

            return Results.Ok(new
            {
                satirlar, onayBekleyen, onaylar, odenecek = odenecek ?? 0m, personel,
                tarafId = ben, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
