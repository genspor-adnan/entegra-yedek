-- =====================================================================
--  752_onarim_onayi.sql
--  MASRAFLI ONARIM ONAYI — iş emri onay omurgasına (738) bağlanır.
--
--  `demirbas_is_emri` akışı vardı (ata → müdahale → parça bekle → dış
--  servis → tamamla) ama PARAYA hiç bakmıyordu: teknisyen cihazı dış
--  servise gönderiyor, fatura gelince kimse "bunu kim onayladı" sorusunu
--  yanıtlayamıyordu. Satınalma talebi 50.000 TL'de mali işlere giderken,
--  aynı tutarlı bir onarım kimseye sorulmadan yapılıyordu.
--
--  ============= ONAY ONARIMDAN ÖNCE ===================================
--  Zincir, iş emri DIŞ SERVİSE gönderilmeden ya da tamamlanmadan önce
--  yürür. Sonradan onaylatmak "onay" değil, olan biteni kayda geçirmektir.
--  Uç, eşiği aşan iş emrinde bu iki adımı onay olmadan reddediyor.
--
--  ============= GARANTİ / SÖZLEŞME KAPSAMI EŞİĞİ DEĞİŞTİRİR ===========
--  Kapsam içindeki onarımın kuruma maliyeti yoktur; eşiği ona da
--  uygulamak, bedava işi imzaya boğmak olurdu. Kapsam dışı olduğunda
--  `kapsam_disi` bayrağı zincire teknik müdür basamağı ekler.
-- =====================================================================

-- ===================================================== AYAR (EŞİK)
insert into public.referans (anahtar, deger, aciklama)
select x.anahtar, x.deger, x.aciklama
  from (values
    ('demirbas.onarim_esik_teknik', '',
     'Teknik mudur onayi esigi (TL). Bos ise varsayilan 10.000.'),
    ('demirbas.onarim_esik_mali', '',
     'Mali isler onayi esigi (TL). Bos ise varsayilan 50.000.'),
    ('demirbas.onarim_esik_ust', '',
     'Ust yonetim onayi esigi (TL). Bos ise varsayilan 250.000.')
  ) as x(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = x.anahtar);

-- ===================================================== YETKİLER
insert into public.yetki (kod, ad, grup, tur, modul, aktif, sira)
select x.kod, x.ad, 'Demirbaş', 1, 'demirbas', 1, x.sira
  from (values
        ('demirbas.onarim_onay_teknik', 'Onarım onayı - teknik müdür', 30::smallint),
        ('demirbas.onarim_onay_mali',   'Onarım onayı - mali işler',   31::smallint),
        ('demirbas.onarim_onay_ust',    'Onarım onayı - üst yönetim',  32::smallint)
       ) as x(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = x.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and y.kod in ('demirbas.onarim_onay_teknik', 'demirbas.onarim_onay_mali',
                 'demirbas.onarim_onay_ust')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ============================================ İŞ EMRİ ONAY ALANLARI
alter table public.demirbas_is_emri
  -- ONAYLANAN TUTAR AYRI TUTULUR: `maliyet` gerçekleşendir ve iş bitince
  --   değişir. Onay hangi tutara verildiyse o kalmalı - yoksa "50.000'e
  --   onay verdim, 90.000 geldi" sorusu sorulamaz.
  add column if not exists onayli_tutar numeric(18,2),
  add column if not exists onay_durum   smallint not null default 0;

comment on column public.demirbas_is_emri.onay_durum is
  '752: 0 gerekmiyor/alinmadi · 1 onayda · 2 onaylandi · 3 reddedildi.';
comment on column public.demirbas_is_emri.onayli_tutar is
  '752: onayin verildigi tutar. `maliyet` gerceklesen - ikisi ayri, yoksa '
  '"50.000e onay verdim 90.000 geldi" sorusu sorulamaz.';

-- ======================================== ONAY AKIŞI (738 omurgası)
insert into public.onay_akis (kod, ad, kaynak_tur, olcu_adi, aktif, aciklama, ekleyen)
select 'demirbas.onarim', 'Masraflı Onarım Onayı', 1224, 'Maliyet (TL)', 1,
       'Teknik mudur -> (50.000 ustu) mali isler -> (250.000 ustu) ust '
       'yonetim. Kapsam disi onarim ek basamak ekler.', 0
 where not exists (select 1 from public.onay_akis where kod = 'demirbas.onarim');

insert into public.onay_akis_adim
       (akis_id, sira, ad, sahip_turu, rol, esik_alt, bayrak, sure_gun, ekleyen)
select k.id, x.sira, x.ad, 1, x.rol, x.esik, x.bayrak, x.sure, 0
  from public.onay_akis k
  cross join (values
        -- TEKNİK MÜDÜR HER ONARIMDA (eşik üstü): onarımın gerekliliğini
        --   ve teklifin makullüğünü değerlendiren tek kişi.
        (1::smallint, 'Teknik Müdür', 6::smallint, null::numeric, '',            2::smallint),
        (2::smallint, 'Mali İşler',   4::smallint, 50000::numeric, '',           3::smallint),
        (3::smallint, 'Üst Yönetim',  5::smallint, 250000::numeric, '',          5::smallint),
        -- KAPSAM DIŞI: garanti/sözleşme kapsamında olmayan onarım kurumun
        --   cebinden çıkar; ayrıca sorulur.
        (4::smallint, 'Teknik Müdür (kapsam dışı)', 6::smallint, null::numeric,
         'kapsam_disi', 2::smallint)
      ) as x(sira, ad, rol, esik, bayrak, sure)
 where k.kod = 'demirbas.onarim'
   and not exists (select 1 from public.onay_akis_adim a where a.akis_id = k.id);

-- ================================== GELEN KUTUSU ONARIMI DA TANISIN
create or replace view public.v_onay_kutusu as
select v.adim_id                                as id,
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
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.talep_no, ''), '#' || v.kaynak_id::text)
            when 904  then coalesce(nullif(z.izin_no, ''),
                                    'İzin #' || v.kaynak_id::text)
            when 1224 then coalesce(nullif(w.is_emri_no, ''),
                                    'İş emri #' || v.kaynak_id::text)
            else '#' || v.kaynak_id::text
       end                                      as kayit_no,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
            when 904  then case z.tur when 1 then 'Yıllık izin'
                                      when 2 then 'Mazeret izni'
                                      when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin'
                                      else 'İzin' end
                           || ' · ' || to_char(z.baslangic_tarihi, 'DD.MM')
                           || '-' || to_char(z.bitis_tarihi, 'DD.MM.YYYY')
            -- ONARIMDA KONU = CİHAZ + ARIZA. Onaylayanın sorusu "ne kadar"
            --   değil yalnız; "hangi cihaz, neden bozuk".
            when 1224 then coalesce(nullif(dm.ad, ''), 'Cihaz')
                           || ' · ' || coalesce(nullif(w.ariza_metni, ''), 'onarım')
            else ''
       end                                      as konu,
       case v.kaynak_tur
            when 1241 then coalesce(d.ad, '')
            when 904  then coalesce(nullif(zp.gorev, ''), '')
            when 1224 then coalesce(wd.ad, '')
            else ''
       end                                      as birim,
       case v.kaynak_tur
            when 1241 then coalesce(p.unvan, '')
            when 904  then coalesce(zt.unvan, '')
            when 1224 then coalesce(wb.unvan, '')
            else ''
       end                                      as talep_eden
  from public.v_onay_bekleyen v
  left join public.satinalma_talep t
         on v.kaynak_tur = 1241 and t.id = v.kaynak_id
  left join public.departman d on d.id = t.departman_id
  left join public.taraf p     on p.id = t.isteyen_id
  left join public.personel_izin z
         on v.kaynak_tur = 904 and z.id = v.kaynak_id
  left join public.taraf zt          on zt.id = z.taraf_id
  left join public.taraf_personel zp on zp.id = z.taraf_id
  left join public.demirbas_is_emri w
         on v.kaynak_tur = 1224 and w.id = v.kaynak_id
  left join public.demirbas dm  on dm.id = w.demirbas_id
  left join public.departman wd on wd.id = w.departman_id
  left join public.taraf wb     on wb.id = w.bildiren_id;

comment on view public.v_onay_kutusu is
  '739/744/752: butun modullerin bekleyen onaylari, kaydin konusu cozulmus '
  'halde (satinalma talebi · izin · masrafli onarim).';

-- ================================================= İŞ EMRİ LİSTE ALANI
-- Liste "bu onarım onaylı mı" sorusunu yanıtlamalı: eşiği aşan ama onaya
--   gönderilmemiş iş emri, faturası gelene kadar kimsenin dikkatini
--   çekmez.
create or replace view public.v_demirbas_is_emri_onay as
select w.id                                     as is_emri_id,
       w.onay_durum,
       w.onayli_tutar,
       w.maliyet,
       (select v.adim_ad from public.v_onay_bekleyen v
         where v.kaynak_tur = 1224 and v.kaynak_id = w.id
         order by v.sira limit 1)                as bekleyen_basamak,
       coalesce((select max(v.gecikme_gun) from public.v_onay_bekleyen v
                  where v.kaynak_tur = 1224 and v.kaynak_id = w.id), 0)
                                                as onay_gecikme_gun
  from public.demirbas_is_emri w;

comment on view public.v_demirbas_is_emri_onay is
  '752: is emrinin onay durumu ve bekleyen basamagi.';
