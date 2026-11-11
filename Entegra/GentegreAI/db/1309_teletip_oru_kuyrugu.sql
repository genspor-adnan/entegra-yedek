-- 1309 - Teletıp: kendi radyoloji raporlarımızın ORU^R01 gönderimi (rapor onayında kuyruğa)
--
-- Kullanıcı 11.11.2026: "kendi raporlarımızın ORU'sunu Teletıp'a bağla". Bugüne kadar ORU yalnız teleradyoloji teslim
-- akışında (gelen işe yazdığımız rapor, telerad_teslim) gidiyordu. Kendi hastanemizin istemine yazılan rapor da
-- Bakanlık'a gitmeli (kılavuz 3.43 § 3.1.3.5).
--
--   * Aynı kuyruk (teletip_gonderim, kanal 1 = HL7): emir 4 = ORU. Sıra kuralı (önceki satır sonuçlanmadan sonraki
--     gitmez) böylece ORU'yu istemin NW'sinden SONRAYA koyar - Bakanlık istemi bilmeden gelen raporu reddeder.
--   * Rapor onaylanınca (durum 3'e geçiş) kuyruğa girer; aynı rapor için bekleyen ORU varsa yenisi açılmaz. İstemin NW'si
--     hiç açılmamışsa (Teletıp istemden sonra açıldı) önce NW açılır. Ek rapor (ust_rapor_id) ayrı ORU - OBX-11 "C".
--   * Mesaj verisi: hasta / istem / kurum kısmı fn_teletip_orm_verisi (TEK kaynak), rapor kısmı fn_teletip_oru_verisi.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

alter table public.teletip_gonderim add column if not exists rapor_id integer
    references public.radyoloji_rapor(id) on delete set null;
alter table public.teletip_gonderim drop constraint if exists ck_teletip_gonderim_emir;
alter table public.teletip_gonderim add constraint ck_teletip_gonderim_emir check (emir between 1 and 4);
comment on column public.teletip_gonderim.emir is '1302/1309: 1 NW · 2 XO · 3 CA (ORM^O01) · 4 rapor (ORU^R01).';
create index if not exists ix_teletip_gonderim_rapor on public.teletip_gonderim (rapor_id) where rapor_id is not null;

-- ------------------------------------------------------------------ rapor verisi
-- Anahtarlar C# tarafında OruVerisi'ne taşınır (TeletipOrmServisi). Parçalar bakanlik_parca'ya göre (809):
-- 1 Teknik · 2 Karşılaştırma · 3 Bulgular · 4 Sonuç ve Öneriler - telerad teslim sorgusuyla aynı birleştirme.
create or replace function public.fn_teletip_oru_verisi(p_rapor_id integer)
returns jsonb language sql stable as $$
  select jsonb_build_object(
    'RaporId',            r.id,
    'IstemId',            r.istem_id,
    'Teknik',             coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 1), ''),
    'Karsilastirma',      coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 2), ''),
    'Bulgular',           coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 3), ''),
    'Sonuc',              coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 4), ''),
    'OnayZamani',         to_char(r.onay_tarihi at time zone public.fn_sube_zaman_dilimi(i.sube_id), 'YYYY-MM-DD"T"HH24:MI:SS'),
    'CekimZamani',        to_char(i.cekim_tarihi at time zone public.fn_sube_zaman_dilimi(i.sube_id), 'YYYY-MM-DD"T"HH24:MI:SS'),
    'IstemNedeniPuan',    coalesce(r.istem_nedeni_puan, 0),
    'CekimKalitePuan',    coalesce(r.cekim_kalite_puan, 0),
    'RadyologTckn',       case when coalesce(rd.vkno, '') ~ '^[1-9][0-9]{10}$' then rd.vkno else '' end,
    'RadyologSoyad',      upper(coalesce(rd.soyad, '')),
    'RadyologAd',         upper(coalesce(nullif(rd.ad, ''), rd.unvan, '')),
    'KontrastObx17',      coalesce(public.fn_rad_kontrast_obx17(i.id), ''),
    'Duzeltme',           r.ust_rapor_id is not null,
    'RaporEksik',         coalesce(public.fn_rad_bakanlik_eksik(r.id), '')
  )
    from public.radyoloji_rapor r
    join public.radyoloji_istem i on i.id = r.istem_id
    left join public.taraf rd on rd.id = coalesce(r.onaylayan_id, r.yazan_id)
   where r.id = p_rapor_id
$$;
comment on function public.fn_teletip_oru_verisi(integer) is
  '1309: Teletıp ORU rapor kısmı (jsonb): 4 Bakanlık parçası, onaylayan radyolog, onay / çekim zamanı, OBX-13 puanları, '
  'OBX-17 kontrast, ek rapor bayrağı, fn_rad_bakanlik_eksik. Hasta / istem / kurum kısmı fn_teletip_orm_verisi.';

-- ------------------------------------------------------------------ rapor onayı -> ORU
create or replace function public.tg_radyoloji_rapor_teletip()
returns trigger language plpgsql as $$
declare
  i record;
begin
  if not public.fn_teletip_aktif() then return new; end if;
  if new.durum <> 3 or (tg_op = 'UPDATE' and old.durum = 3) then return new; end if;   -- yalnız onaya geçiş
  select * into i from public.radyoloji_istem where id = new.istem_id;
  if not found or i.durum = 0 or coalesce(i.accession_no, '') = '' then return new; end if;
  -- İstemin NW'si yoksa (Teletıp istemden sonra açıldı) önce NW.
  if not exists (select 1 from public.teletip_gonderim g where g.istem_id = i.id and g.kanal = 1 and g.emir = 1 and g.durum <> 4) then
    perform public.fn_teletip_orm_kuyrukla(i.id, i.accession_no, 1::smallint, i.sube_id, coalesce(new.onaylayan_id, new.degistiren, 0));
  end if;
  if not exists (select 1 from public.teletip_gonderim g where g.rapor_id = new.id and g.emir = 4 and g.durum in (0, 3, 5)) then
    insert into public.teletip_gonderim (istem_id, accession_no, kanal, emir, durum, rapor_id, sube_id, ekleyen)
    values (i.id, i.accession_no, 1, 4, 0, new.id, coalesce(i.sube_id, 0), coalesce(new.onaylayan_id, new.degistiren, 0));
  end if;
  return new;
end $$;

drop trigger if exists tg_radyoloji_rapor_teletip on public.radyoloji_rapor;
create trigger tg_radyoloji_rapor_teletip
  after insert or update of durum on public.radyoloji_rapor
  for each row execute function public.tg_radyoloji_rapor_teletip();

-- ------------------------------------------------------------------ liste görünümü: ORU sütunu (sona eklenir)
create or replace view public.v_teletip_istem as
with g as (
  select t.istem_id,
         count(*)                                                      as mesaj_sayisi,
         count(*) filter (where t.durum in (0, 5))                      as bekleyen,
         count(*) filter (where t.durum in (2, 3))                      as sorunlu,
         max(t.son_deneme)                                              as son_deneme,
         max(t.ekleme_tarihi)                                           as son_kayit,
         (array_agg(t.durum order by t.id) filter (where t.emir = 1))[1] as nw_durum_ilk,
         (array_agg(t.durum order by t.id desc) filter (where t.emir = 1))[1] as nw_durum,
         (array_agg(t.emir order by t.id desc))[1]                      as son_emir,
         (array_agg(t.durum order by t.id desc))[1]                     as son_durum,
         (array_agg(t.ack_kodu order by t.id desc))[1]                  as son_ack,
         (array_agg(nullif(t.hata_metni, '') order by t.id desc) filter (where t.durum in (2, 3, 5)))[1] as son_hata,
         (array_agg(t.durum order by t.id desc) filter (where t.emir = 4))[1] as oru_durum
    from public.teletip_gonderim t
   where t.istem_id is not null and t.kanal = 1
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
       coalesce(g.oru_durum, -1)::smallint                                as oru_durum
  from g
  join public.radyoloji_istem i on i.id = g.istem_id
  left join public.taraf h  on h.id  = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id;

commit;
