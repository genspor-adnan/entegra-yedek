-- 1329 - Modality Worklist sunucusu entegrasyon ekranından, şube başına (kod = MWL)
--
-- Kullanıcı 12.11.2026: "worklist sunucuyu nasıl açacağım.. onun da ayarları entegrasyonlar listesinde olabilir mi" →
-- mockup Ekranlar/Ayarlar/entegrasyon_mwl.html → "burası çok şubeli yer ayrı ayrı olabilir" → "uygula".
--
-- entegrasyon_hesap satırı (kod = 'MWL'): kullanici_adi = cihazların çağıracağı AE adı, uygulama_kodu = port,
-- ayarlar = karakterSeti · bilinmeyenAe · pencereGun. Şube başına satır; şubeler aynı portu paylaşıp AE adıyla
-- ayrılabilir. Dinleyici (MwlSunucusu) satırlar değişince yeniden kurulur - API yeniden başlatılmaz.
--
--   * fn_radyoloji_mwl: p_sube (dinleyicinin şubesi) - şube dinleyicisine bağlanan cihaz yalnız o şubenin istemini görür.
--   * Aynı (port, AE) iki aktif MWL satırında olamaz (gelen bağlantı çağrılan AE ile satıra yönlenir).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

drop function if exists public.fn_radyoloji_mwl(varchar, varchar, date, date, varchar, varchar);

-- MWL satırları. Tarih aralığı şubenin yerel gününe göre (planlanan an = randevu, yoksa kabul, yoksa kayıt).
create or replace function public.fn_radyoloji_mwl(
    p_ae        varchar,             -- çağıran cihazın AE başlığı ('' = cihaz tanınmadan, yalnız modalite)
    p_modalite  varchar  default '', -- DICOM Modality süzgeci ('' = hepsi / cihazınki)
    p_bas       date     default null,
    p_bit       date     default null,
    p_accession varchar  default '',
    p_hasta_id  varchar  default '', -- DICOM PatientID (TCKN ya da dosya no)
    p_sube      integer  default 0)  -- 1329: dinleyicinin şubesi (0 = kurum geneli, süzgeç yok)
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
     and (coalesce(p_sube, 0) = 0 or a.sube_id = p_sube)                  -- 1329: şube dinleyicisi yalnız kendi şubesini
   order by a.oncelik desc, a.planlanan_an, a.id
   limit 500
$$;
comment on function public.fn_radyoloji_mwl(varchar, varchar, date, date, varchar, varchar, integer) is
  '1301: Modality Worklist satırları (MwlSunucusu). Bekleyen + MWL istenmiş + accession dolu istemler; '
  'cihaz AE başlığıyla tanınır (modalite / şube / atanmış cihaz süzgeci). PatientID kuralı C# tarafında: '
  'TCKN geçerliyse TCKN, değilse dosya no (Bakanlık kılavuzu 3.43 § 5.2). 1329: p_sube = dinleyicinin şubesi.';


create unique index if not exists ux_entegrasyon_hesap_mwl_port_ae
    on public.entegrasyon_hesap (trim(uygulama_kodu), upper(trim(coalesce(kullanici_adi, ''))))
 where kod = 'MWL' and aktif = 1;

commit;
