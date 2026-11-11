-- 1310 - Teletıp KOS (K2): istemin PACS çalışması bağlanınca KOS manifesti XDS (RAD-68) ile Bakanlık'a
--
-- Kullanıcı 11.11.2026: "KOS gönderimini (K2) yap". Teleradyoloji XDS Entegrasyon Kılavuzu 1.15 § 2.1-2.2. KOS ve
-- ITI-41 MTOM zarfı Gentegre'de üretilir (TeletipKos.cs); Mirth K2 (TELETIP_KOS) yalnız taşır.
--
--   * teletip_gonderim kanal 2 = KOS (emir 1). Sıra: istemin NW'si gönderilmeden (AA) KOS gitmez - kılavuz 3.43 § 5.4
--     örnek 2: görüntü istemden önce gelirse eşleşme kaçar.
--   * Tetik: radyoloji_istem.study_uid boştan doluya geçince (PACS çalışması bağlandı - accession eşleşmesi ya da elle
--     bağlama) KOS kuyruğa girer; bekleyen KOS varken yenisi açılmaz. study_uid değişirse yeni KOS.
--   * Cihaz: DeviceSerialNumber = Teletıp STM "Cihaz Takip" ekranının verdiği seri no (radyoloji_cihaz.teletip_seri_no).
--     İstemin cihazı yoksa aynı şube + modalitede tek aktif cihaz varsa o.
--   * Ayarlar: teletip.xds_adres (Mirth K2 URL), teletip.xds_hasta_oid (XDS patientId atama otoritesi).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_cihaz add column if not exists teletip_seri_no varchar(64) not null default '';
comment on column public.radyoloji_cihaz.teletip_seri_no is
  '1310: Teletıp STM > Cihaz Takip ekranında tanımlanınca sistemin verdiği seri no - KOS DeviceSerialNumber (kılavuz XDS 1.15 Tablo 2).';

insert into public.referans (anahtar, deger, tip, kapsam, aciklama) values
  ('teletip.xds_adres', '', 'metin', 'firma',
   'Teletıp KOS (RAD-68) hedefi - Mirth K2 (TELETIP_KOS) HTTP dinleyicisi, ör. http://10.0.0.12:8082/kos. Boşsa KOS bekler.'),
  ('teletip.xds_hasta_oid', '2.16.792.1.2.1.1.5.2.1.1', 'metin', 'firma',
   'XDS patientId atama otoritesi OID''i (TCKN^^^&OID&ISO). Bakanlık KOS doğrulama servisiyle teyit edilmeli.')
on conflict (anahtar) do nothing;

-- KOS'a özgü veri: çalışma UID'si ve cihaz seri no (hasta / kurum kısmı fn_teletip_orm_verisi).
create or replace function public.fn_teletip_kos_verisi(p_istem_id integer)
returns jsonb language sql stable as $$
  select jsonb_build_object(
    'StudyUid',    coalesce(i.study_uid, ''),
    'CihazId',     coalesce(c.id, 0),
    'CihazAdi',    coalesce(c.ad, ''),
    'CihazSeriNo', coalesce(c.teletip_seri_no, '')
  )
    from public.radyoloji_istem i
    left join lateral (
      select rc.* from public.radyoloji_cihaz rc
       where (i.cihaz_id is not null and rc.id = i.cihaz_id)
          or (i.cihaz_id is null and rc.durum = 1 and rc.modalite = i.modalite and rc.sube_id in (i.sube_id, 0)
              and (select count(*) from public.radyoloji_cihaz x
                    where x.durum = 1 and x.modalite = i.modalite and x.sube_id in (i.sube_id, 0)) = 1)
       limit 1) c on true
   where i.id = p_istem_id
$$;
comment on function public.fn_teletip_kos_verisi(integer) is
  '1310: KOS verisi - study_uid ve cihaz (istemin cihazı; yoksa şube + modalitede tek aktif cihaz) Teletıp seri no.';

create or replace function public.tg_radyoloji_istem_teletip_kos()
returns trigger language plpgsql as $$
begin
  if not public.fn_teletip_aktif() then return new; end if;
  if coalesce(new.study_uid, '') = '' or coalesce(new.study_uid, '') = coalesce(old.study_uid, '') then return new; end if;
  if new.durum = 0 or coalesce(new.accession_no, '') = '' then return new; end if;
  if not exists (select 1 from public.teletip_gonderim g where g.istem_id = new.id and g.kanal = 2 and g.durum in (0, 3, 5)) then
    insert into public.teletip_gonderim (istem_id, accession_no, kanal, emir, durum, sube_id, ekleyen)
    values (new.id, new.accession_no, 2, 1, 0, coalesce(new.sube_id, 0), coalesce(new.degistiren, new.ekleyen, 0));
  end if;
  return new;
end $$;
drop trigger if exists tg_radyoloji_istem_teletip_kos on public.radyoloji_istem;
create trigger tg_radyoloji_istem_teletip_kos
  after update of study_uid on public.radyoloji_istem
  for each row execute function public.tg_radyoloji_istem_teletip_kos();

-- ------------------------------------------------------------------ liste görünümü: KOS sütunu (sona eklenir)
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
         (array_agg(t.durum order by t.id desc) filter (where t.kanal = 2))[1] as kos_durum
    from public.teletip_gonderim t
   where t.istem_id is not null and t.kanal in (1, 2)
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
       coalesce(g.kos_durum, -1)::smallint                                as kos_durum
  from g
  join public.radyoloji_istem i on i.id = g.istem_id
  left join public.taraf h  on h.id  = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id;

commit;
