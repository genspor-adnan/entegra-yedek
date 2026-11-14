-- 1343 - Rapor şablonunda BİÇİM (tek / parçalı) ve GİRİŞ (serbest / yapısal) açık ayar; rapor ekranı şablona uyar.
--
-- Kullanıcı 14.11.2026: "şablon seçildiğinde şablonun biçimi ve girişi nasılsa rapor ekranına o şekilde yansısın..
--   ekran biçim tek seçili ama seçtiğimiz şablon çok parçalı ise burası da çok parçalıya geçsin.. giriş de aynı
--   şekilde.. bütün şablonlarda biçim ve giriş belirli olmalı".
-- Bugüne kadar biçim bölüm sayısından, giriş yapisal_tur'dan HESAPLANIYORDU (1216) ve rapor ekranı hekimin son
--   tercihini (gorunum) kullanıyordu. Artık şablon kartında iki zorunlu alan:
--   bicim: 1 = Tek A4, 2 = Parçalı        giris: 1 = Serbest, 2 = Yapısal (form; yalnız yapisal_tur > 0 ile)
-- Geçiş: mevcut şablonlar eski hesaptan doldurulur (bölüm > 1 → parçalı; yapisal_tur > 0 → yapısal).
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_sablon
    add column if not exists bicim smallint not null default 1,
    add column if not exists giris smallint not null default 1;
comment on column public.radyoloji_sablon.bicim is '1343: rapor biçimi 1 = Tek A4, 2 = Parçalı - rapor ekranı şablon uygulanınca bu biçime geçer';
comment on column public.radyoloji_sablon.giris is '1343: rapor girişi 1 = Serbest, 2 = Yapısal (form; yapisal_tur > 0 gerekir) - rapor ekranı şablon uygulanınca bu girişe geçer';

-- Geçiş doldurması: yalnız bir kez (ilk kurulumda kolon yeni geldiği için hepsi 1'dir; tekrar çalışmada dokunulmaz).
do $$
begin
  if not exists (select 1 from public.referans where anahtar = 'radyoloji.sablon_bicim_giris_1343') then
    update public.radyoloji_sablon s
       set bicim = case when (select count(*) from public.radyoloji_sablon_bolum b where b.sablon_id = s.id) > 1 then 2 else 1 end,
           giris = case when coalesce(s.yapisal_tur, 0) > 0 then 2 else 1 end;
    insert into public.referans (anahtar, deger) values ('radyoloji.sablon_bicim_giris_1343', '1')
    on conflict (anahtar) do nothing;
  end if;
end $$;

-- Yapısal giriş yalnız formu olan şablonda.
alter table public.radyoloji_sablon drop constraint if exists ck_radyoloji_sablon_giris_form;
alter table public.radyoloji_sablon add constraint ck_radyoloji_sablon_giris_form
    check (bicim in (1, 2) and giris in (1, 2) and (giris <> 2 or coalesce(yapisal_tur, 0) > 0));

commit;
