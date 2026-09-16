using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DİŞ KLİNİĞİ (706) — liste/kart dışı uçlar. Mockup
/// <c>Ekranlar/Dis Klinigi/dis_hasta_karti_v5.html</c> (hasta kartı),
/// <c>dis_gunluk_akis.html</c>, <c>dis_seans_kaydi.html</c>,
/// <c>dis_lab_isemri.html</c>, <c>dis_odeme_plani.html</c>.
///
/// <para><b>Hasta kartı TEK SORUDA döner:</b> odontogram (üç katman), aktif
/// plan ve satırları, seans geçmişi, lab işleri, ağız özeti. Hekim dişe
/// bakarken planı görür ve işlem ekler - beş ayrı istek beş ayrı bekleme
/// olurdu.</para>
///
/// <para><b>Odontograma yazan tek yol bu dosyadadır</b> (bulgu, planlanan,
/// tamamlanan). Genel kart odontogram tablosunu bilmez: "yeni durum eskisini
/// pasifleştirir" kuralı tek yerde durur.</para>
/// </summary>
public static partial class DisUclari
{
    private const int LogTabloPlan       = 1130;
    private const int LogTabloPlanSatir  = 1131;
    private const int LogTabloSeans      = 1132;
    private const int LogTabloLabIsemri  = 1134;
    private const int LogTabloOdontogram = 1140;
    private const int LogTabloDisMuayene = 1141;

    /// <summary>Başvuru belge türü (tür 19 / tipi 30) - 296 ile aynı.</summary>
    private const int BasvuruTuru = 19;
    private const int BasvuruTipi = 30;

    public static void DisUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dis").WithTags("Diş").RequireAuthorization();

        HastaKartiUcunuEkle(grup);
        OdontogramUclariniEkle(grup);
        PlanUclariniEkle(grup);
        AkisUclariniEkle(grup);
        SeansUclariniEkle(grup);
        SeansKartUclariniEkle(grup);
        PlanKartUclariniEkle(grup);
        DisMuayeneUclariniEkle(grup);
        LabUclariniEkle(grup);
    }

    // ================================================================ hasta kartı ==
    private static void HastaKartiUcunuEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/hasta/{hastaId:int}/kart", async (
            int hastaId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.hasta", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var hasta = await baglanti.TekAsync("""
                select t.id, t.unvan, t.cep_tel, th.dogum_tarihi,
                       extract(year from age(current_date, th.dogum_tarihi))::int as yas,
                       coalesce(th.cinsiyet, 0)::int as cinsiyet,
                       (select string_agg(coalesce(nullif(a.etken, ''), a.etken_madde), ', ') from public.hasta_alerji a where a.hasta_id = t.id and a.aktif = 1) as alerji,
                       -- TIBBI UYARILAR (kullanici): alerjinin yanina kronik tani ve surekli ilac -
                       --   Tibbi Ozet ile ayni kaynaklar (hasta_kronik_tani durum 1, hasta_ilac aktif).
                       (select string_agg(coalesce(nullif(k.tani_ad, ''), k.icd_kod), ', ' order by k.id) from public.hasta_kronik_tani k where k.hasta_id = t.id and k.durum = 1) as kronik,
                       (select string_agg(coalesce(nullif(i.ilac_ad, ''), i.etken_madde), ', ' order by i.id) from public.hasta_ilac i where i.hasta_id = t.id and i.aktif = 1 and (i.bitis is null or i.bitis >= current_date)) as ilac,
                       (select m.muayene_tarihi from public.muayene m where m.taraf_id = t.id
                         order by m.muayene_tarihi desc limit 1) as son_muayene,
                       (select coalesce(h.unvan, '') from public.muayene m
                          left join public.taraf h on h.id = m.personel_id
                         where m.taraf_id = t.id order by m.muayene_tarihi desc limit 1) as son_hekim,
                       (select dm.dental_anamnez from public.dis_muayene dm where dm.hasta_id = t.id
                         order by dm.id desc limit 1) as dental_anamnez,
                       (select count(*) from public.dis_seans s where s.hasta_id = t.id)::int as seans_sayisi
                  from public.taraf t
                  left join public.taraf_hasta th on th.id = t.id
                 where t.id = @p0
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0),
                unvan = o.GetString(1),
                cepTel = o.Metin("cep_tel"),
                dogumTarihi = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
                yas = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                cinsiyet = o.GetInt32(5),
                alerji = o.Metin("alerji"), kronik = o.Metin("kronik"), ilac = o.Metin("ilac"),
                sonMuayene = o.IsDBNull(o.GetOrdinal("son_muayene")) ? (DateTime?)null : o.GetDateTime(o.GetOrdinal("son_muayene")),
                sonHekim = o.Metin("son_hekim"),
                dentalAnamnez = o.Metin("dental_anamnez"),
                seansSayisi = o.GetInt32(o.GetOrdinal("seans_sayisi")),
            }, iptal);
            if (hasta is null) throw Gentegre.Cekirdek.Sozlesme.GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

            // ODONTOGRAM: yalnız AKTİF satırlar, üç katman birden. Şema ve diş
            //   tablosu aynı diziden çizilir.
            var odontogram = await baglanti.ListeAsync("""
                select o.id, o.dis_no, o.yuzeyler, o.durum_kod, o.katman, o.kaynak, o.tarih,
                       o.plan_satir_id, o.not_metin, o.dentisyon
                  from public.dis_odontogram o
                 where o.hasta_id = @p0 and o.aktif = 1
                 order by o.dis_no, o.katman, o.id
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), disNo = (int)o.GetInt16(1), yuzeyler = o.GetString(2),
                durumKod = (int)o.GetInt16(3), katman = (int)o.GetInt16(4), kaynak = (int)o.GetInt16(5),
                tarih = o.GetDateTime(6), planSatirId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                notMetin = o.GetString(8), dentisyon = (int)o.GetInt16(9),
            }, iptal);

            // AKTİF PLAN: taslak/sunuldu/onaylı/sürüyor olan en yeni plan; hiç
            //   açık plan yoksa SON plan (tamamlanmış) gösterilir - hekim "ne
            //   yapılmıştı"yı görsün, yeni işlem ekleyince yeni plan açılır.
            var plan = await baglanti.TekAsync("""
                select p.id, p.plan_no, p.durum, p.varyant, p.toplam, p.indirim, p.net,
                       coalesce(h.unvan, '') as hekim, p.ekleme_tarihi::date as tarih,
                       p.hasta_onay_zamani, p.proforma_no, p.gecerlilik_bitis, p.fiyat_listesi_id,
                       (select coalesce(sum(s.net), 0) from public.dis_tedavi_plani_satir s
                         where s.plan_id = p.id and s.durum = 3) as yapilan,
                       (select coalesce(sum(k.odenen), 0) from public.dis_odeme_plani o
                           join public.dis_odeme_taksit k on k.odeme_plani_id = o.id
                          where o.plan_id = p.id) as tahsil,
                       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum <> 4)::int as satir_sayisi,
                       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum = 3)::int as yapilan_sayisi,
                       (select o.id from public.dis_odeme_plani o where o.plan_id = p.id) as odeme_plani_id,
                       (select p2.plan_no from public.dis_tedavi_plani p2
                         where p2.hasta_id = p.hasta_id and p2.id <> p.id and p2.durum = 5
                         order by p2.id desc limit 1) as onceki_plan_no
                  from public.dis_tedavi_plani p
                  left join public.taraf h on h.id = p.hekim_id
                 where p.hasta_id = @p0
                 order by (p.durum in (1, 2, 3, 4)) desc, p.id desc limit 1
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), planNo = o.GetString(1), durum = (int)o.GetInt16(2),
                varyant = o.GetString(3), toplam = o.GetDecimal(4), indirim = o.GetDecimal(5),
                net = o.GetDecimal(6), hekim = o.GetString(7), tarih = o.GetDateTime(8),
                hastaOnayZamani = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                proformaNo = o.GetString(10),
                gecerlilikBitis = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                fiyatListesiId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12),
                yapilan = o.GetDecimal(13), tahsil = o.GetDecimal(14),
                satirSayisi = o.GetInt32(15), yapilanSayisi = o.GetInt32(16),
                odemePlaniId = o.IsDBNull(17) ? (int?)null : o.GetInt32(17),
                oncekiPlanNo = o.Metin("onceki_plan_no"),
            }, iptal);

            var satirlar = plan is null ? [] : await PlanSatirlariAsync(baglanti, plan.id, iptal);

            // TEDAVİ GEÇMİŞİ: seans işlemleri (yapılan + süren), en yeni üstte.
            var gecmis = await baglanti.ListeAsync("""
                select i.id, s.baslangic, coalesce(h.unvan, '') as hekim, i.dis_no, i.yuzeyler,
                       hz.ad as islem, i.seans_no,
                       coalesce(ps.seans_sayisi, 1) as seans_sayisi, i.tamamlandi,
                       coalesce(p.plan_no, '') as plan_no,
                       coalesce((select bs.tutar_kdvli from public.belge_satir bs where bs.id = i.belge_satir_id), 0) as ucret
                  from public.dis_seans_islem i
                  join public.dis_seans s on s.id = i.seans_id
                  join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf h on h.id = s.hekim_id
                  left join public.dis_tedavi_plani_satir ps on ps.id = i.plan_satir_id
                  left join public.dis_tedavi_plani p on p.id = ps.plan_id
                 where s.hasta_id = @p0
                 order by s.baslangic desc, i.id desc
                 limit 100
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), tarih = o.GetDateTime(1), hekim = o.GetString(2),
                disNo = (int)o.GetInt16(3), yuzeyler = o.GetString(4), islem = o.GetString(5),
                seansNo = (int)o.GetInt16(6), seansSayisi = (int)o.GetInt16(7),
                tamamlandi = o.GetInt16(8) == 1, planNo = o.GetString(9), ucret = o.GetDecimal(10),
            }, iptal);

            var labIsleri = await baglanti.ListeAsync("""
                select i.id, i.isemri_no, l.ad, i.dis_nolar, i.is_turu, i.malzeme, i.renk,
                       i.gonderim_tarihi, i.beklenen_tarih, i.asama, i.lab_fiyat
                  from public.dis_lab_isemri i join public.dis_lab l on l.id = i.lab_id
                 where i.hasta_id = @p0 order by i.id desc limit 50
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), isemriNo = o.GetString(1), lab = o.GetString(2),
                disNolar = o.GetString(3), isTuru = (int)o.GetInt16(4), malzeme = o.GetString(5),
                renk = o.GetString(6),
                gonderim = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                beklenen = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8),
                asama = (int)o.GetInt16(9), labFiyat = o.GetDecimal(10),
            }, iptal);

            // Periodontal: son kaydın özeti + diş başına en derin cep.
            var perio = await baglanti.TekAsync("""
                select p.id, p.tarih, p.plak_indeksi, p.bop_oran, p.cep5_sayisi, p.ort_cal, p.evre, p.derece
                  from public.dis_periodontal p where p.hasta_id = @p0 order by p.tarih desc, p.id desc limit 1
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), tarih = o.GetDateTime(1),
                plakIndeksi = o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                bopOran = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                cep5Sayisi = (int)o.GetInt16(4),
                ortCal = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                evre = (int)o.GetInt16(6), derece = o.GetString(7),
            }, iptal);
            var perioCep = perio is null ? [] : await baglanti.ListeAsync("""
                select o.dis_no, greatest(coalesce(o.cep_mv,0), coalesce(o.cep_v,0), coalesce(o.cep_dv,0),
                                          coalesce(o.cep_ml,0), coalesce(o.cep_l,0), coalesce(o.cep_dl,0)) as cep
                  from public.dis_periodontal_olcum o where o.periodontal_id = @p0
                """, null, [perio.id], o => new { disNo = (int)o.GetInt16(0), cep = o.GetInt32(1) }, iptal);

            // Diş muayenesi uzantısı (oklüzyon, TME, bruksizm) - varsa en yenisi.
            var disMuayene = await baglanti.TekAsync("""
                select dm.okluzyon_sinif, dm.tme_bulgu, dm.bruksizm, dm.sigara, dm.hijyen_durum,
                       dm.dmft_d, dm.dmft_m, dm.dmft_f, dm.dentisyon
                  from public.dis_muayene dm where dm.hasta_id = @p0 order by dm.id desc limit 1
                """, null, [hastaId], o => new
            {
                okluzyonSinif = (int)o.GetInt16(0), tmeBulgu = o.GetString(1),
                bruksizm = o.GetInt16(2) == 1, sigara = o.GetInt16(3) == 1, hijyenDurum = o.GetString(4),
                dmftD = (int)o.GetInt16(5), dmftM = (int)o.GetInt16(6), dmftF = (int)o.GetInt16(7),
                dentisyon = (int)o.GetInt16(8),
            }, iptal);

            return Results.Ok(new
            {
                hasta, odontogram, plan, satirlar, gecmis, labIsleri, perio, perioCep, disMuayene,
                fiyatListesi = await VarsayilanFiyatListesiAsync(baglanti, plan?.fiyatListesiId, iptal),
            });
        });

        // Diş işlemi arama (plan satırı eklerken): yalnız dis_islem = 1 hizmetler,
        //   fiyatı listeden. İstek metni SQL'e parametre olarak girer.
        grup.MapGet("/islemler", async (
            string? q, int? listeId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var liste = await VarsayilanFiyatListesiAsync(baglanti, listeId, iptal);
            var arama = "%" + (q ?? "").Trim() + "%";
            var satirlar = await baglanti.ListeAsync("""
                select h.id, h.kod, h.ad, coalesce(f.fiyat, 0) as fiyat, h.standart_seans, h.lab_gerekir,
                       h.ucret_kurali, h.dis_bazli, h.yuzey_bazli, h.dis_islem_grubu
                  from public.hizmet h
                  left join lateral public.fn_fiyat_listesi_fiyat(@p1, null, h.id) f on true
                 where h.dis_islem = 1 and h.baslik_mi = 0 and coalesce(h.durum, 1) = 1
                   and (h.ad ilike @p0 or h.kod ilike @p0)
                 order by h.ad limit 60
                """, null, [arama, liste], o => new
            {
                id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), fiyat = o.GetDecimal(3),
                standartSeans = (int)o.GetInt16(4), labGerekir = o.GetInt16(5) == 1,
                ucretKurali = (int)o.GetInt16(6), disBazli = o.GetInt16(7) == 1,
                yuzeyBazli = o.GetInt16(8) == 1, islemGrubu = (int)o.GetInt16(9),
            }, iptal);
            return Results.Ok(new { listeId = liste, satirlar });
        });
    }

    /// <summary>Plan satırları - kart ve "yapıldı" sonrası aynı biçim.</summary>
    private static async Task<List<object>> PlanSatirlariAsync(NpgsqlConnection baglanti, int planId,
        CancellationToken iptal)
    {
        var liste = await baglanti.ListeAsync("""
            select s.id, s.faz, s.sira, s.dis_no, s.dis_nolar, s.yuzeyler, s.hizmet_id, hz.ad as islem,
                   coalesce(h.unvan, '') as hekim, s.seans_sayisi, s.yapilan_seans,
                   s.liste_fiyat, s.iskonto, s.net, s.ucret_kurali, s.lab_gerekir, s.lab_isemri_id,
                   s.durum, s.tamamlanma, s.aciklama,
                   (select min(x.baslangic) from public.dis_seans_islem i join public.dis_seans x on x.id = i.seans_id
                     where i.plan_satir_id = s.id) as ilk_seans,
                   (select r.baslangic from public.randevu r where r.plan_satir_id = s.id and r.durum in (1, 2)
                     order by r.baslangic limit 1) as randevu
              from public.dis_tedavi_plani_satir s
              join public.hizmet hz on hz.id = s.hizmet_id
              left join public.taraf h on h.id = s.hekim_id
             where s.plan_id = @p0
             order by s.faz, s.sira, s.id
            """, null, [planId], o => (object)new
        {
            id = o.GetInt32(0), faz = (int)o.GetInt16(1), sira = (int)o.GetInt16(2),
            disNo = (int)o.GetInt16(3), disNolar = o.GetString(4), yuzeyler = o.GetString(5),
            hizmetId = o.GetInt32(6), islem = o.GetString(7), hekim = o.GetString(8),
            seansSayisi = (int)o.GetInt16(9), yapilanSeans = (int)o.GetInt16(10),
            listeFiyat = o.GetDecimal(11), iskonto = o.GetDecimal(12), net = o.GetDecimal(13),
            ucretKurali = (int)o.GetInt16(14), labGerekir = o.GetInt16(15) == 1,
            labIsemriId = o.IsDBNull(16) ? (int?)null : o.GetInt32(16),
            durum = (int)o.GetInt16(17),
            tamamlanma = o.IsDBNull(18) ? (DateTime?)null : o.GetDateTime(18),
            aciklama = o.GetString(19),
            ilkSeans = o.IsDBNull(20) ? (DateTime?)null : o.GetDateTime(20),
            randevu = o.IsDBNull(21) ? (DateTime?)null : o.GetDateTime(21),
        }, iptal);
        return liste;
    }

    /// <summary>Planın listesi, yoksa kurumun varsayılan fiyat listesi.</summary>
    private static async Task<int?> VarsayilanFiyatListesiAsync(NpgsqlConnection baglanti, int? listeId,
        CancellationToken iptal)
        => listeId ?? await baglanti.TekDegerAsync<int?>("""
            select id from public.fiyat_listesi where varsayilan = 1 and durum = 1 order by id limit 1
            """, null, [], iptal);
}
