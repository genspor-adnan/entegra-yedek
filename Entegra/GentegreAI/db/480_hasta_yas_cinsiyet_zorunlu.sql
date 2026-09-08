-- =====================================================================
-- 480 - HASTADA DOĞUM TARİHİ VE CİNSİYET ZORUNLU (kullanıcı)
--
-- İkisi de sonucun YORUMUNU değiştirir: laboratuvar referans aralığı yaşa ve
-- cinsiyete göre seçilir, kimi hizmet belli bir cinsiyete yapılamaz (doğum,
-- prostat), kimi tetkik belli yaşın altında istenmez. Boş bırakılan bir hasta
-- kaydı, sonradan yanlış referansla okunan bir sonuç demektir.
--
-- KART yeterli değil: kayıt kart dışından da açılıyor (göç, entegrasyon,
-- randevudan hızlı kayıt). Kural veritabanında olmalı ki hiçbir yol atlamasın.
--
-- KİMLİKSİZ HASTA İSTİSNADIR: acile bilinci kapalı gelen hastanın doğum
-- tarihi bilinmez. Kayıt durursa iş durur - `kimliksiz = 1` iken doğum tarihi
-- aranmaz. Cinsiyet o hastada da gözlemle yazılabildiği için istenir.
-- Kimliklendirme yapıldığında (kimliksiz 0'a çekilince) doğum tarihi zorunlu
-- hâle gelir.
--
-- MEVCUT KAYITLARA DOKUNULMAZ: kısıt `not valid` eklenir - eski satırlar
-- olduğu gibi kalır, YENİ ve DEĞİŞEN satırlar denetlenir. Eksik kayıtların
-- listesi aşağıda `notice` ile bildirilir; düzeltme kullanıcının işidir.
-- =====================================================================

do $$
declare v_dogum integer; v_cinsiyet integer;
begin
    select count(*) filter (where dogum_tarihi is null and coalesce(kimliksiz, 0) = 0),
           count(*) filter (where coalesce(cinsiyet, 0) not in (1, 2))
      into v_dogum, v_cinsiyet
      from public.taraf_hasta;
    raise notice '480: eksik doğum tarihi % hasta, eksik cinsiyet % hasta (mevcutlara dokunulmadı)',
        v_dogum, v_cinsiyet;
end $$;

alter table public.taraf_hasta
  drop constraint if exists ck_taraf_hasta_dogum_zorunlu;
alter table public.taraf_hasta
  add constraint ck_taraf_hasta_dogum_zorunlu
  check (dogum_tarihi is not null or coalesce(kimliksiz, 0) = 1) not valid;

alter table public.taraf_hasta
  drop constraint if exists ck_taraf_hasta_cinsiyet_zorunlu;
alter table public.taraf_hasta
  add constraint ck_taraf_hasta_cinsiyet_zorunlu
  check (coalesce(cinsiyet, 0) in (1, 2)) not valid;

-- Gelecekten doğum tarihi kabul edilmez; 130 yaş üstü de veri hatasıdır.
alter table public.taraf_hasta
  drop constraint if exists ck_taraf_hasta_dogum_akilli;
alter table public.taraf_hasta
  add constraint ck_taraf_hasta_dogum_akilli
  check (dogum_tarihi is null
         or (dogum_tarihi <= current_date and dogum_tarihi > current_date - interval '130 years'))
  not valid;

comment on column public.taraf_hasta.dogum_tarihi is
  'Zorunlu (480) - kimliksiz hasta dışında. Yaş, referans aralığı ve hizmet uygunluğunun girdisi.';
comment on column public.taraf_hasta.cinsiyet is
  'Zorunlu (480): 1 erkek · 2 kadın. Referans aralığı ve hizmet uygunluğu buna bakar.';

do $$
begin
    raise notice '480 tamam: dogum tarihi + cinsiyet kisitlari kuruldu (not valid - eskiler serbest)';
end $$;
