-- ============================================================================
--  Gentegre AI — KİMLİK BİÇİMİ KURUM PROFİLİNDE
--  679_kimlik_bicimi.sql
--
--  Kullanıcı: "kimlik biçimini kurum profiline ayar olarak ekle."
--
--  678'de etiket genelleşti ("Kimlik No") ama DOĞRULAMA hâlâ T.C. kimlik
--  algoritmasıydı: 11 hane + kontrol hanesi. Türkiye dışındaki bir kurulumda
--  bu kural hastanın gerçek numarasını reddeder ve kaydı imkânsız kılar;
--  kuralı topluca kapatmak ise Türkiye'de yanlış TCKN'nin sessizce geçmesi
--  demektir - hata aylar sonra "MEDULA provizyonu alınamıyor" olarak döner.
--
--  ÇÖZÜM: biçim bir KURULUM AYARI. Dört değer:
--    otomatik - şubenin ülkesine bak: TR ise T.C. kuralı, değilse serbest
--               (varsayılan; bugünkü davranışın aynısı)
--    tc       - her zaman T.C. kimlik algoritması
--    serbest  - biçim kontrolü yok (uzunluk sınırı kalır)
--    desen    - `kimlik_deseni` düzenli ifadesi ile kontrol (ör. pasaport)
--
--  Ayar ŞUBE BAZLIDIR: kurum_profil zaten şubeye göre çözülüyor (364), yurt
--  dışı şubesi kendi kuralını taşıyabilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.kurum_profil
    add column if not exists kimlik_bicimi varchar(20) not null default 'otomatik',
    add column if not exists kimlik_deseni varchar(120) not null default '',
    -- Ekranda alanın yanında yazan açıklama; boşsa biçimin kendi metni.
    add column if not exists kimlik_aciklama varchar(120) not null default '';

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ck_kurum_profil_kimlik') then
        alter table public.kurum_profil
            add constraint ck_kurum_profil_kimlik
            check (kimlik_bicimi in ('otomatik', 'tc', 'serbest', 'desen'));
    end if;
end $$;

comment on column public.kurum_profil.kimlik_bicimi is
  'Kimlik no dogrulama bicimi (679): otomatik | tc | serbest | desen.';
comment on column public.kurum_profil.kimlik_deseni is
  'kimlik_bicimi = desen ise uygulanan duzenli ifade (POSIX).';

-- ---------------------------------------------------------------------------
--  ÇÖZÜMLEYİCİ: "otomatik" burada gerçek bir kurala indirgenir ki hem sunucu
--  hem istemci AYNI cevabı alsın - iki yerde "otomatik ne demekti" kararı
--  vermek, ekranın kabul edip sunucunun reddettiği bir numara demekti.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kimlik_kurali(p_sube integer default 0)
returns table (bicim varchar, desen varchar, aciklama varchar)
language sql stable as $$
    with p as (select * from public.fn_kurum_profil(p_sube)),
         s as (select coalesce(nullif(max(u.ulke_kod), ''), 'TR') as ulke
                 from public.sube u where u.id = nullif(p_sube, 0))
    select case when p.kimlik_bicimi <> 'otomatik' then p.kimlik_bicimi
                -- Şube seçilmemişse (s.ulke null) TR: kontrolün sessizce
                --   kapanması, gereksiz yere açık kalmasından kötüdür.
                when coalesce((select ulke from s), 'TR') = 'TR' then 'tc'
                else 'serbest' end::varchar as bicim,
           p.kimlik_deseni::varchar as desen,
           p.kimlik_aciklama::varchar as aciklama
      from p;
$$;

comment on function public.fn_kimlik_kurali is
  'Kimlik no dogrulama kurali (679): otomatik -> subenin ulkesine gore tc/serbest.';

do $$
begin
    raise notice '679 tamam: kimlik bicimi kurum profiline eklendi.';
end $$;
