-- ============================================================================
--  1282_teklif_ic_onay.sql  (10.11.2026)
--  SATIŞ TEKLİFİ İÇ ONAYI (mockup Ekranlar/Teklif/teklif_ic_onay.html; kullanıcı: "teklife iç onayı aktar").
--  Dış (müşteri) onayı YOK. Hazırlayan onaylayanı seçer, "Onaya Sun" der; motorun `teklif.satis` akışı tek
--  basamak - sahip türü 5 "Hazırlayan seçer" (OnayMotoru.BaslatAsync secilenKullaniciId). Onaylayan Onayımdakiler'de
--  Onayla / Reddet / Düzeltme iste.
--   · yetki `belge.teklif_onay` (aksiyon, tur 1): karar verebilecek kullanıcılar; seçim listesi de bundan.
--   · onay_akis 'teklif.satis' (kaynak_tur 30 = belge) + 1 basamak.
--   · belge.teklif_durum yeni kodlar: 6 Onayda · 7 Onaylandı · 8 Düzeltme istendi · 9 Reddedildi (yalnız motor yazar).
--   · v_onay_kutusu: kaynak_tur 30 dalı (kayıt no = belge no, konu, talep eden = satış temsilcisi).
--  İdempotent.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, aktif)
select 'belge.teklif_onay', 'Teklif iç onayı (seçilen onaylayan)', 'Satış', 1, 1
 where not exists (select 1 from public.yetki where kod = 'belge.teklif_onay');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r cross join public.yetki y
 where r.kod in ('yonetici', 'ust_yonetim', 'erp_satis')
   and y.kod = 'belge.teklif_onay'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);

insert into public.onay_akis (kod, ad, kaynak_tur, olcu_adi, aktif, aciklama)
select 'teklif.satis', 'Satış Teklifi Onayı', 30, 'Tutar (TL)', 1,
       '1282: hazırlayan onaylayanı seçer (basamak sahibi türü 5); dış onay yok.'
 where not exists (select 1 from public.onay_akis where kod = 'teklif.satis');

insert into public.onay_akis_adim (akis_id, sira, ad, sahip_turu, rol, karar_turu, sure_gun, e_imza_zorunlu, aktif)
select a.id, 1, 'Seçilen onaylayan', 5, 0, 0, 2, 0, 1
  from public.onay_akis a
 where a.kod = 'teklif.satis'
   and not exists (select 1 from public.onay_akis_adim d where d.akis_id = a.id);

comment on column public.belge.teklif_durum is
  'Teklif akışı: 1 Hazırlanıyor · 2 Sunuldu · 3 Kabul · 4 Red · 5 İptal · 6 Onayda · 7 Onaylandı · 8 Düzeltme istendi · 9 Reddedildi (6-9 yalnız onay motoru yazar, 1282).';

create or replace view public.v_onay_kutusu as
 SELECT v.adim_id AS id,
    v.onay_id,
    v.kaynak_tur,
    v.kaynak_id,
    v.sube_id,
    v.akis_kod,
    v.akis_ad,
    v.olcu,
    v.olcu_adi,
    v.sira,
    v.adim_ad,
    v.rol,
    v.atanan_kullanici_id,
    v.durum,
    v.gerekce,
    v.baslama,
    v.termin,
    v.gecikme_gun,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(NULLIF(t.talep_no::text, ''::text), '#'::text || v.kaynak_id::text)
            WHEN 904 THEN COALESCE(NULLIF(z.izin_no::text, ''::text), 'İzin #'::text || v.kaynak_id::text)
            WHEN 1224 THEN COALESCE(NULLIF(w.is_emri_no::text, ''::text), 'İş emri #'::text || v.kaynak_id::text)
            WHEN 1257 THEN COALESCE(NULLIF(av.avans_no::text, ''::text), 'Avans #'::text || v.kaynak_id::text)
            WHEN 1256 THEN COALESCE(NULLIF(ib.belge_no::text, ''::text), 'Başvuru #'::text || COALESCE(isk.belge_id, 0)::text)
            WHEN 976 THEN (COALESCE(NULLIF(dk.kod::text, ''::text), 'DOK-'::text || dk.id::text) || ' v'::text) || ds.surum_no::text
            WHEN 1312 THEN COALESCE(NULLIF(ms.beyan_no::text, ''::text), 'Masraf #'::text || v.kaynak_id::text)
            WHEN 1314 THEN COALESCE(NULLIF(bt.talep_no::text, ''::text), 'Belge #'::text || v.kaynak_id::text)
            WHEN 30 THEN COALESCE(NULLIF(b30.belge_no::text, ''::text), 'Teklif #'::text || v.kaynak_id::text)
            ELSE '#'::text || v.kaynak_id::text
        END AS kayit_no,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(NULLIF(t.gerekce::text, ''::text), 'Satınalma talebi'::text)
            WHEN 904 THEN (((
            CASE z.tur
                WHEN 1 THEN 'Yıllık izin'::text
                WHEN 2 THEN 'Mazeret izni'::text
                WHEN 3 THEN 'Rapor'::text
                WHEN 4 THEN 'Ücretsiz izin'::text
                ELSE 'İzin'::text
            END || ' · '::text) || to_char(z.baslangic_tarihi::timestamp with time zone, 'DD.MM'::text)) || '-'::text) || to_char(z.bitis_tarihi::timestamp with time zone, 'DD.MM.YYYY'::text)
            WHEN 1224 THEN (COALESCE(NULLIF(dm.ad::text, ''::text), 'Cihaz'::text) || ' · '::text) || COALESCE(NULLIF(w.ariza_metni::text, ''::text), 'onarım'::text)
            WHEN 1257 THEN ((COALESCE(NULLIF(av.gerekce::text, ''::text), 'Avans'::text) || ' · '::text) || av.taksit_sayisi::text) || ' taksit'::text
            WHEN 1256 THEN ((COALESCE(NULLIF(isk.gerekce::text, ''::text), 'İskonto talebi'::text) || ' · '::text) || (( SELECT count(*)::text AS count
               FROM iskonto_talep_satir ts
              WHERE ts.talep_id = isk.id))) || ' kalem'::text
            WHEN 976 THEN COALESCE(NULLIF(dk.ad::text, ''::text), 'Doküman'::text) || COALESCE(' · '::text || NULLIF(ds.degisiklik_notu::text, ''::text), ''::text)
            WHEN 1312 THEN ((COALESCE(NULLIF(ms.aciklama::text, ''::text), 'Masraf beyanı'::text) || ' · '::text) || (( SELECT count(*)::text AS count
               FROM personel_masraf_satir mss
              WHERE mss.beyan_id = ms.id))) || ' belge'::text
            WHEN 1314 THEN
            CASE bt.tur
                WHEN 1 THEN 'Çalışma Belgesi'::text
                WHEN 2 THEN 'Maaş Yazısı'::text
                WHEN 3 THEN 'Vize Yazısı'::text
                WHEN 4 THEN 'SGK Hizmet Dökümü'::text
                ELSE 'Belge'::text
            END || COALESCE(' · '::text || NULLIF(bt.amac::text, ''::text), ''::text)
            WHEN 30 THEN (COALESCE(NULLIF(b30.teklif_konusu::text, ''::text), 'Satış teklifi'::text) || ' · '::text) || COALESCE(b30.taraf_unvan::text, ''::text)
            ELSE ''::text
        END AS konu,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(d.ad, ''::character varying)
            WHEN 904 THEN COALESCE(NULLIF(zp.gorev::text, ''::text), ''::text)::character varying
            WHEN 1224 THEN COALESCE(wd.ad, ''::character varying)
            WHEN 1257 THEN COALESCE(NULLIF(ap.gorev::text, ''::text), ''::text)::character varying
            WHEN 1256 THEN COALESCE(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::character varying(120), ''::character varying)
            WHEN 976 THEN COALESCE(dkat.ad, ''::character varying)
            WHEN 1312 THEN COALESCE(NULLIF(mp.gorev::text, ''::text), ''::text)::character varying
            WHEN 1314 THEN COALESCE(NULLIF(bp.gorev::text, ''::text), ''::text)::character varying
            WHEN 30 THEN COALESCE(b30.taraf_unvan, ''::character varying)::character varying
            ELSE ''::character varying
        END AS birim,
        CASE v.kaynak_tur
            WHEN 1241 THEN COALESCE(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::character varying(120), ''::character varying)
            WHEN 904 THEN COALESCE(public.fn_taraf_ad(zt.unvan, zt.ad, zt.soyad)::character varying(120), ''::character varying)
            WHEN 1224 THEN COALESCE(public.fn_taraf_ad(wb.unvan, wb.ad, wb.soyad)::character varying(120), ''::character varying)
            WHEN 1257 THEN COALESCE(public.fn_taraf_ad(at.unvan, at.ad, at.soyad)::character varying(120), ''::character varying)
            WHEN 1256 THEN COALESCE(public.fn_taraf_ad(ii.unvan, ii.ad, ii.soyad)::character varying(120), ''::character varying)
            WHEN 976 THEN COALESCE(public.fn_taraf_ad(dy.unvan, dy.ad, dy.soyad)::character varying(120), ''::character varying)
            WHEN 1312 THEN COALESCE(public.fn_taraf_ad(mt.unvan, mt.ad, mt.soyad)::character varying(120), ''::character varying)
            WHEN 1314 THEN COALESCE(public.fn_taraf_ad(btt.unvan, btt.ad, btt.soyad)::character varying(120), ''::character varying)
            WHEN 30 THEN COALESCE(public.fn_taraf_ad(st30.unvan, st30.ad, st30.soyad)::character varying(120), ''::character varying)
            ELSE ''::character varying
        END AS talep_eden
   FROM v_onay_bekleyen v
     LEFT JOIN satinalma_talep t ON v.kaynak_tur = 1241 AND t.id = v.kaynak_id
     LEFT JOIN departman d ON d.id = t.departman_id
     LEFT JOIN taraf p ON p.id = t.isteyen_id
     LEFT JOIN personel_izin z ON v.kaynak_tur = 904 AND z.id = v.kaynak_id
     LEFT JOIN taraf zt ON zt.id = z.taraf_id
     LEFT JOIN taraf_personel zp ON zp.id = z.taraf_id
     LEFT JOIN demirbas_is_emri w ON v.kaynak_tur = 1224 AND w.id = v.kaynak_id
     LEFT JOIN demirbas dm ON dm.id = w.demirbas_id
     LEFT JOIN departman wd ON wd.id = w.departman_id
     LEFT JOIN taraf wb ON wb.id = w.bildiren_id
     LEFT JOIN personel_avans av ON v.kaynak_tur = 1257 AND av.id = v.kaynak_id
     LEFT JOIN taraf at ON at.id = av.taraf_id
     LEFT JOIN taraf_personel ap ON ap.id = av.taraf_id
     LEFT JOIN iskonto_talep isk ON v.kaynak_tur = 1256 AND isk.id = v.kaynak_id
     LEFT JOIN belge ib ON ib.id = isk.belge_id
     LEFT JOIN taraf ih ON ih.id = ib.taraf_id
     LEFT JOIN taraf ii ON ii.id = isk.isteyen_id
     LEFT JOIN dokuman_surum ds ON v.kaynak_tur = 976 AND ds.id = v.kaynak_id
     LEFT JOIN dokuman dk ON dk.id = ds.dokuman_id
     LEFT JOIN dokuman_kategori dkat ON dkat.id = dk.kategori_id
     LEFT JOIN taraf dy ON dy.id = ds.yukleyen_id
     LEFT JOIN personel_masraf ms ON v.kaynak_tur = 1312 AND ms.id = v.kaynak_id
     LEFT JOIN taraf mt ON mt.id = ms.taraf_id
     LEFT JOIN taraf_personel mp ON mp.id = ms.taraf_id
     LEFT JOIN personel_belge_talep bt ON v.kaynak_tur = 1314 AND bt.id = v.kaynak_id
     LEFT JOIN taraf btt ON btt.id = bt.taraf_id
     LEFT JOIN taraf_personel bp ON bp.id = bt.taraf_id
     LEFT JOIN belge b30 ON v.kaynak_tur = 30 AND b30.id = v.kaynak_id
     LEFT JOIN taraf st30 ON st30.id = b30.satici_id;

do $$ begin raise notice '1282 tamam: teklif.satis akışı, belge.teklif_onay yetkisi, v_onay_kutusu kaynak 30.'; end $$;
