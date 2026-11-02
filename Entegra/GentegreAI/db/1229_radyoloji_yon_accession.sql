-- =============================================================================
--  1229  RADYOLOJİ - TETKİK YÖNÜ VE ACCESSION NUMARASI
--
--  Kullanıcı 01.11.2026: "diz, kol, el mr gibi seçimde yön eklemek gerekiyor.. bir de accession no vermek
--  gerekiyor.. hasta dışardan geldiyse hazır onu girmek yoksa bakanlık standartında bizim vermemiz gerekiyor"
--  · "bu müşteri 6 şube.. ona göre ayarla".
--
--  YÖN: SUT tek taraflı tetkiki yön ayırmadan kodlar (Diz MR tek kod); sağ / sol bilgisi istemde tutulur.
--    0 yok · 1 sağ · 2 sol · 3 bilateral (eski HBYS PARA.YON ile aynı kodlar). Hizmet kartındaki
--    `yon_zorunlu` bayrağı kabul masasında yönü sordurur; tetkik adı her yerde yönle görünür
--    (çalışma listesi, istem kartı, rapor, çıktı) - fn_radyoloji_yon_ek.
--
--  ACCESSION: numara şube bazlı numara şablonundan (634, tür 903) gelir - önek ve hane şubeye göre
--    (eski HBYS: KGM + 13 hane = 16 karakter, DICOM AccessionNumber üst sınırı). Şablon ortak (şube 0)
--    olsa da sayaç şube başınadır: aynı önekle iki şubenin numarası çakışabilirdi - üretici çakışan
--    numarayı atlar (fn_radyoloji_accession_ver). Dışarıdan gelen hastanın kendi accession'ı girilirse
--    o kullanılır (`accession_dis` = 1).
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.hizmet add column if not exists yon_zorunlu smallint not null default 0;
comment on column public.hizmet.yon_zorunlu is
  '1229: radyoloji kabulünde tetkik yönü (sağ / sol / bilateral) sorulur ve boş geçilemez.';

alter table public.radyoloji_istem add column if not exists yon smallint not null default 0;
alter table public.radyoloji_istem add column if not exists accession_dis smallint not null default 0;
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'ck_radyoloji_istem_yon') then
    alter table public.radyoloji_istem add constraint ck_radyoloji_istem_yon check (yon between 0 and 3);
  end if;
end $$;
comment on column public.radyoloji_istem.yon is '1229: 0 yok · 1 sağ · 2 sol · 3 bilateral.';
comment on column public.radyoloji_istem.accession_dis is
  '1229: 1 = accession no dışarıdan (gönderen kurumun numarası) girildi, kurum şablonundan üretilmedi.';

-- Tetkik adının yön eki: "Diz MR (SAĞ)".
create or replace function public.fn_radyoloji_yon_ek(p_yon smallint)
returns text language sql immutable as $$
  select case p_yon when 1 then ' (SAĞ)' when 2 then ' (SOL)' when 3 then ' (BİLATERAL)' else '' end
$$;

-- Accession üretimi: şablon yoksa '' (çağıran ACC-YYMMDD-nnnn yedeğine düşer, 287); varsa kullanılmamış
--   ilk numara. Kayıtlı bir numaraya denk gelen sıra atlanır (ortak şablonlu çok şube, dışarıdan girilmiş
--   aynı biçimde numara) - aksi halde benzersiz indeks kabulü düşürürdü.
create or replace function public.fn_radyoloji_accession_ver(p_sube_id integer, p_tarih date default current_date)
returns varchar language plpgsql as $$
declare v varchar; i int := 0;
begin
  loop
    v := public.fn_numara_kimlik_uret(903, p_sube_id, 'radyoloji_istem', 'accession_no', coalesce(p_tarih, current_date));
    exit when coalesce(v, '') = ''
           or not exists (select 1 from public.radyoloji_istem where accession_no = v);
    i := i + 1;
    if i > 1000 then raise exception 'Accession numarası üretilemedi (şablon 903 çakışıyor).'; end if;
  end loop;
  return coalesce(v, '');
end $$;

-- Yön zorunlu hizmetler: ekstremite / eklem ve "tek taraf" adları; iki taraflı, bilateral, karşılaştırmalı
--   ve dansitometri hariç. Yalnız modalitesi olan (radyoloji) hizmetler; elle açılmış bayrağa dokunulmaz.
update public.hizmet h set yon_zorunlu = 1
 where coalesce(h.modalite, 0) > 0 and h.yon_zorunlu = 0
   and upper(h.ad) ~ '(\mD[İI]Z\M|\mOMUZ|\mAYAK|\mEL\M|\mEL B[İI]LE|\mD[İI]RSEK|\mKRUR[İI]S|\mHUMERUS|\mUYLUK|\mFEMUR|\mÖN KOL|\mKALÇA|EKSTREM[İI]TE|TEK\s*TA(RAF|\s*$)|\mB[İI]LEK)'
   and upper(h.ad) !~ '(İK[İI]\s+TARAF|HER\s+[İI]K[İI]|B[İI]LATERAL|KARŞILAŞTIRMALI|KIYASLAMALI|DANS[İI]TOM)';
