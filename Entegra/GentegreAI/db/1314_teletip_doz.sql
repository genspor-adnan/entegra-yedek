-- 1314 - Teletıp doz verisi (RDSR, Mirth K3)
--
-- Kullanıcı 11.11.2026: "doz RDSR (K3) adımını yap". Teleradyoloji XDS Entegrasyon Kılavuzu 1.15 § 3 + Teleradyoloji
-- Entegrasyon Kılavuzu 3.43 § 4.3: X-Ray Radiation Dose SR (1.2.840.10008.5.1.4.1.1.88.67, TID 10001 / 10011) DICOM
-- C-STORE (TLS) ile dicom.teletip.saglik.gov.tr:443, Called AE TELETIP_MGA. Künye (Tablo 5) KOS ile aynı olmalı;
-- STM'de "doz alındı" görünmesi için o tetkikin KOS'u da gitmiş olmalı. Yanıt C-STORE-RSP (Tablo 6: 0000H başarılı,
-- 0110H + SR110..SR117 / metin hata).
--
--   * teletip_gonderim kanal 3 = DOZ (Mirth K3; emir 1). Kanal yorumu düzeltildi (1302'deki "3 ORU / 4 doz" taslağı:
--     ORU kanal 1 emir 4 olarak yapıldı).
--   * Tetik: KOS satırı (kanal 2) başarıya (durum 1) geçince, istemin modalitesi iyonlaştırıcıysa (CT, röntgen, MG,
--     XA, RF, BMD) aynı çalışma için doz satırı açılır. O çalışmanın dozu zaten gitmişse ya da bekleyen doz varsa açılmaz
--     (kılavuz: tekrar gönderimde Event UID değişmemeli - aynı RDSR'yi gereksiz yere yeniden göndermeyiz).
--   * fn_teletip_doz_verisi: hasta boyu / kilosu (BT doz verisinde zorunlu) - son 1 yıldaki muayene vital ölçümü.
--   * teletip.doz_adres: Mirth K3 HTTP dinleyicisi (ör. http://10.0.0.12:4104/doz/). Boşsa doz bekler.
--   * v_teletip_istem: doz_durum sütunu (sona).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

comment on column public.teletip_gonderim.kanal is
  '1 HL7 (Mirth K1: ORM NW/XO/CA emir 1-3, ORU emir 4) · 2 KOS / XDS (K2) · 3 DOZ / RDSR (K3, 1314).';

insert into public.referans (anahtar, deger, tip, kapsam, aciklama) values
  ('teletip.doz_adres', '', 'metin', 'firma',
   '1314: Teletıp doz (RDSR) hedefi - Mirth K3 (TELETIP_DOZ) HTTP dinleyicisi, ör. http://10.0.0.12:4104/doz/ (sonda /). Boşsa doz bekler.')
on conflict (anahtar) do nothing;

-- Doz'a özgü veri (künye kısmı fn_teletip_orm_verisi + fn_teletip_kos_verisi).
create or replace function public.fn_teletip_doz_verisi(p_istem_id integer)
returns jsonb language sql stable as $$
  select jsonb_build_object(
    'Modalite', public.fn_radyoloji_dicom_modalite(i.modalite),
    'BoyCm',  (select v.boy_cm  from public.muayene_vital v join public.muayene m on m.id = v.muayene_id
                where m.taraf_id = i.hasta_id and coalesce(v.boy_cm, 0) > 0
                  and v.zaman >= coalesce(i.kabul_tarihi, i.ekleme_tarihi) - interval '1 year'
                order by v.zaman desc limit 1),
    'KiloKg', (select v.kilo_kg from public.muayene_vital v join public.muayene m on m.id = v.muayene_id
                where m.taraf_id = i.hasta_id and coalesce(v.kilo_kg, 0) > 0
                  and v.zaman >= coalesce(i.kabul_tarihi, i.ekleme_tarihi) - interval '1 year'
                order by v.zaman desc limit 1))
    from public.radyoloji_istem i where i.id = p_istem_id
$$;
comment on function public.fn_teletip_doz_verisi(integer) is
  '1314: doz (RDSR) verisi - modalite + hastanın son 1 yıldaki boy / kilo ölçümü (BT dozunda Bakanlık zorunlu sayar).';

-- KOS başarıya geçince doz satırı.
create or replace function public.tg_teletip_gonderim_doz()
returns trigger language plpgsql as $$
declare v_modalite varchar;
begin
  if new.kanal <> 2 or new.durum <> 1 or old.durum = 1 or coalesce(new.study_uid, '') = '' or new.istem_id is null then
    return new;
  end if;
  select public.fn_radyoloji_dicom_modalite(i.modalite) into v_modalite from public.radyoloji_istem i where i.id = new.istem_id;
  if coalesce(v_modalite, '') not in ('CT', 'CR', 'MG', 'XA', 'RF', 'BMD') then return new; end if;
  if exists (select 1 from public.teletip_gonderim g
              where g.kanal = 3 and g.istem_id = new.istem_id and g.study_uid = new.study_uid and g.durum in (0, 1, 3, 5)) then
    return new;
  end if;
  insert into public.teletip_gonderim (istem_id, accession_no, kanal, emir, durum, sube_id, ekleyen, study_uid)
  values (new.istem_id, new.accession_no, 3, 1, 0, new.sube_id, new.ekleyen, new.study_uid);
  return new;
end $$;
drop trigger if exists tg_teletip_gonderim_doz on public.teletip_gonderim;
create trigger tg_teletip_gonderim_doz
  after update of durum on public.teletip_gonderim
  for each row execute function public.tg_teletip_gonderim_doz();

-- ------------------------------------------------------------------ liste görünümü: doz sütunu (sona eklenir)
create or replace view public.v_teletip_istem as
with g as (
  select t.istem_id,
         count(*)                                                      as mesaj_sayisi,
         count(*) filter (where t.durum in (0, 5))                      as bekleyen,
         count(*) filter (where t.durum in (2, 3))                      as sorunlu,
         max(t.son_deneme)                                              as son_deneme,
         max(t.ekleme_tarihi)                                           as son_kayit,
         (array_agg(t.durum order by t.id) filter (where t.emir = 1 and t.kanal = 1))[1] as nw_durum_ilk,
         (array_agg(t.durum order by t.id desc) filter (where t.emir = 1 and t.kanal = 1))[1] as nw_durum,
         (array_agg(t.emir order by t.id desc) filter (where t.kanal = 1))[1] as son_emir,
         (array_agg(t.durum order by t.id desc))[1]                     as son_durum,
         (array_agg(t.ack_kodu order by t.id desc))[1]                  as son_ack,
         (array_agg(nullif(t.hata_metni, '') order by t.id desc) filter (where t.durum in (2, 3, 5)))[1] as son_hata,
         (array_agg(t.durum order by t.id desc) filter (where t.emir = 4))[1] as oru_durum,
         (array_agg(t.durum order by t.id desc) filter (where t.kanal = 2))[1] as kos_durum,
         (array_agg(t.durum order by t.id desc) filter (where t.kanal = 3))[1] as doz_durum
    from public.teletip_gonderim t
   where t.istem_id is not null and t.kanal in (1, 2, 3)
   group by t.istem_id
)
select i.id,
       i.sube_id,
       coalesce(i.kabul_tarihi, i.ekleme_tarihi)                         as kabul,
       i.accession_no,
       i.modalite,
       i.durum                                                            as istem_durum,
       i.hasta_id,
       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as hasta_adi,
       case when coalesce(h.vkno, '') ~ '^[0-9]{11}$' then left(h.vkno, 1) || '•••••••' || right(h.vkno, 3) else '' end as tckn_maskeli,
       coalesce(hz.ad, '') || public.fn_radyoloji_yon_ek(i.yon)            as tetkik_adi,
       coalesce(public.fn_hizmet_sut_kodu(i.hizmet_id, i.yon, i.kontrast), '') as sut_kodu,
       coalesce(hz.loinc, '')                                             as loinc,
       g.mesaj_sayisi, g.bekleyen, g.sorunlu, g.son_deneme, g.son_kayit,
       coalesce(g.nw_durum, -1)::smallint                                 as nw_durum,
       g.son_emir::smallint                                               as son_emir,
       g.son_durum::smallint                                              as son_durum,
       coalesce(g.son_ack, '')                                            as son_ack,
       coalesce(g.son_hata, '')                                           as son_hata,
       (case when g.sorunlu > 0 then 3 when g.bekleyen > 0 then 2 when g.son_durum = 1 then 1 else 0 end)::smallint as genel_durum,
       coalesce(g.oru_durum, -1)::smallint                                as oru_durum,
       coalesce(g.kos_durum, -1)::smallint                                as kos_durum,
       coalesce(g.doz_durum, -1)::smallint                                as doz_durum
  from g
  join public.radyoloji_istem i on i.id = g.istem_id
  left join public.taraf h  on h.id  = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id;

commit;
