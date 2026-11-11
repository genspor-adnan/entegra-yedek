-- 1301 - Radyoloji Modality Worklist (MWL) - cihaz çalışma listesi
--
-- Kullanıcı 11.11.2026: "amacımız Sağlık Bakanlığı'nın istediği şekilde Teletıp'a verileri görüntülemek" ->
-- "MWL ile başla". Bakanlık (Teleradyoloji Entegrasyon Kılavuzu 3.43 § 5.2) görüntüyü isteme ancak
--   DICOM AccessionNumber == HL7 accession  VE  (DICOM PatientID / OtherPatientIDs == TCKN
--                                               ya da SKRS eşit ve PatientID == hasta dosya no)
-- ise bağlar. Cihaz bu etiketleri teknikerin elle yazdığından alırsa tutmaz; tek güvenilir yol cihazın
-- çalışma listesini bizden (MWL C-FIND) çekmesi. API içindeki MWL sunucusu (MwlSunucusu.cs) bu fonksiyonu
-- çağırır; kural (hangi istem listede, hangi cihaza) burada, C# yalnız DICOM'a çevirir.
--
-- Listeye giren istem: durum 1 (Bekliyor), mwl_istendi = 1, accession dolu (sevkli istemde accession_bekliyor
-- = 0), PACS çalışması henüz bağlanmamış (study_uid boş), hasta var. Cihaz AE başlığı radyoloji_cihaz.ae_title ile tanınır: modalitesi ve şubesi süzer,
-- istem başka cihaza atanmışsa o cihaza gitmez. Tanınmayan AE: p_ae boş geçilirse (ayar izin verirse) yalnız
-- modalite süzgeci.
--
-- study_uid ÖNCEDEN ÜRETİLMEZ: cihaz MWL'deki StudyInstanceUID'i kullanmayabilir; o zaman istemde yanlış UID
-- kalır ve "Görüntüle" boş açılır. Eşleşme accession ile (DicomKaynagi.AccessionIleStudyAsync) yapılır.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

-- Bizdeki modalite kodu (rad.modalite) -> DICOM Modality. Röntgen cihazı CR, DX ya da DR der; hepsi 4.
create or replace function public.fn_radyoloji_dicom_modalite(p_modalite smallint)
returns varchar language sql immutable as $$
  select case p_modalite when 1 then 'CT' when 2 then 'MR' when 3 then 'US' when 4 then 'CR'
                         when 5 then 'MG' when 6 then 'BMD' when 7 then 'XA' when 8 then 'RF' else 'OT' end
$$;
comment on function public.fn_radyoloji_dicom_modalite(smallint) is
  '1301: rad.modalite -> DICOM Modality (1 CT, 2 MR, 3 US, 4 CR, 5 MG, 6 BMD, 7 XA, 8 RF).';

create or replace function public.fn_radyoloji_modalite_dicomdan(p_dicom varchar)
returns smallint language sql immutable as $$
  select (case upper(trim(coalesce(p_dicom, '')))
           when 'CT' then 1 when 'MR' then 2 when 'US' then 3
           when 'CR' then 4 when 'DX' then 4 when 'DR' then 4
           when 'MG' then 5 when 'BMD' then 6 when 'DXA' then 6 when 'XA' then 7 when 'RF' then 8
           else null end)::smallint
$$;
comment on function public.fn_radyoloji_modalite_dicomdan(varchar) is
  '1301: DICOM Modality -> rad.modalite (CR/DX/DR = 4 Röntgen); bilinmeyen null.';

-- MWL satırları. Tarih aralığı şubenin yerel gününe göre (planlanan an = randevu, yoksa kabul, yoksa kayıt).
create or replace function public.fn_radyoloji_mwl(
    p_ae        varchar,             -- çağıran cihazın AE başlığı ('' = cihaz tanınmadan, yalnız modalite)
    p_modalite  varchar  default '', -- DICOM Modality süzgeci ('' = hepsi / cihazınki)
    p_bas       date     default null,
    p_bit       date     default null,
    p_accession varchar  default '',
    p_hasta_id  varchar  default '') -- DICOM PatientID (TCKN ya da dosya no)
returns table (
    istem_id integer, accession_no varchar, sube_id integer, modalite varchar,
    planlanan timestamptz, yerel_zaman timestamp,
    hasta_id integer, hasta_tckn varchar, hasta_dosya_no varchar, hasta_soyad varchar, hasta_ad varchar,
    dogum_tarihi date, cinsiyet varchar,
    hizmet_kod varchar, hizmet_ad varchar, sut_kodu varchar, loinc varchar,
    hekim_soyad varchar, hekim_ad varchar, hekim_unvan varchar,
    cihaz_id integer, cihaz_ae varchar, oncelik smallint, klinik_bilgi varchar, on_tani varchar)
language sql stable as $$
  with cihaz as (
      select c.id, c.modalite, c.sube_id, c.ae_title
        from public.radyoloji_cihaz c
       where coalesce(p_ae, '') <> '' and c.durum = 1 and upper(trim(c.ae_title)) = upper(trim(p_ae))
       order by c.id limit 1),
  aday as (
      select i.*, coalesce(r.baslangic, i.kabul_tarihi, i.ekleme_tarihi) as planlanan_an,
             public.fn_sube_zaman_dilimi(i.sube_id) as tz
        from public.radyoloji_istem i
        left join public.randevu r on r.id = i.randevu_id
       where i.durum = 1 and i.mwl_istendi = 1
         and coalesce(i.accession_no, '') <> '' and coalesce(i.accession_bekliyor, 0) = 0
         and coalesce(i.study_uid, '') = ''                  -- PACS'ta çalışması bağlı = çekilmiş, listeden düşer
         and (coalesce(p_accession, '') = '' or i.accession_no = p_accession))
  select a.id, a.accession_no::varchar, a.sube_id, public.fn_radyoloji_dicom_modalite(a.modalite),
         a.planlanan_an, (a.planlanan_an at time zone a.tz)::timestamp,
         h.id,
         (case when coalesce(h.vkno, '') ~ '^[1-9][0-9]{10}$' then h.vkno else '' end)::varchar,
         coalesce(h.kod, '')::varchar,
         coalesce(nullif(h.soyad, ''), h.unvan, '')::varchar, coalesce(h.ad, '')::varchar,
         th.dogum_tarihi::date,
         (case th.cinsiyet when 1 then 'M' when 2 then 'F' else 'O' end)::varchar,
         coalesce(s.kod, '')::varchar, (coalesce(s.ad, '') || public.fn_radyoloji_yon_ek(a.yon))::varchar,
         coalesce(s.sut_kodu, '')::varchar, coalesce(s.loinc, '')::varchar,
         coalesce(hk.soyad, '')::varchar, coalesce(hk.ad, '')::varchar, coalesce(hk.unvan, '')::varchar,
         a.cihaz_id, coalesce(nullif(ac.ae_title, ''), c.ae_title, '')::varchar, a.oncelik,   -- atanmış cihaz, yoksa soranın kayıtlı AE'si
         coalesce(a.klinik_bilgi, '')::varchar, coalesce(a.on_tani, '')::varchar
    from aday a
    join public.taraf h        on h.id = a.hasta_id
    left join public.taraf_hasta th on th.id = h.id
    left join public.hizmet s  on s.id = a.hizmet_id
    left join public.taraf hk  on hk.id = a.istek_hekim_id
    left join public.radyoloji_cihaz ac on ac.id = a.cihaz_id
    left join cihaz c on true
   where (coalesce(p_ae, '') = '' or c.id is not null)                    -- AE verildiyse tanınmalı
     and (c.id is null or a.modalite = c.modalite)
     and (c.id is null or coalesce(c.sube_id, 0) = 0 or a.sube_id = c.sube_id)
     and (c.id is null or a.cihaz_id is null or a.cihaz_id = c.id)       -- başka cihaza atanmışsa gitmez
     and (coalesce(p_modalite, '') = '' or a.modalite = public.fn_radyoloji_modalite_dicomdan(p_modalite))
     and (p_bas is null or (a.planlanan_an at time zone a.tz)::date >= p_bas)
     and (p_bit is null or (a.planlanan_an at time zone a.tz)::date <= p_bit)
     and (coalesce(p_hasta_id, '') = '' or p_hasta_id in (h.vkno, h.kod))
   order by a.oncelik desc, a.planlanan_an, a.id
   limit 500
$$;
comment on function public.fn_radyoloji_mwl(varchar, varchar, date, date, varchar, varchar) is
  '1301: Modality Worklist satırları (MwlSunucusu). Bekleyen + MWL istenmiş + accession dolu istemler; '
  'cihaz AE başlığıyla tanınır (modalite / şube / atanmış cihaz süzgeci). PatientID kuralı C# tarafında: '
  'TCKN geçerliyse TCKN, değilse dosya no (Bakanlık kılavuzu 3.43 § 5.2).';

-- İz: cihaz istemi listede ilk gördüğünde bir kez (cihazlar her dakika sorar; her sorgu iz olsa tablo şişer).
create unique index if not exists ux_rad_pacs_mwl_ilk
    on public.radyoloji_pacs_olay (istem_id, ae_title) where olay = 1 and yon = 1;

commit;
