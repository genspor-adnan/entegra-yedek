-- 327: PRİM PLAN SATIRINDA HEDEF SEÇİLEBİLİR OLSUN (324/326 üzerine).
--
-- Kullanıcı: "hedef türünde hizmet grubu yerine KATEGORİ olsun ve sağdaki
-- hedefte seçebilelim; hedef türü hizmet olduğunda da hedefte seçebilelim."
--
-- Eski tasarımda hedef tek bir (hedef_tur, hedef_id) çiftiydi: hedef_id ham
-- sayı olarak elle yazılıyordu, çünkü hangi listeden seçileceği türe bağlıydı
-- ve tek kolona üç ayrı liste bağlanamıyordu (hizmet 5 ile kategori 5 aynı
-- id'dir - karışır).
--
-- Yeni tasarım: hedef ÜÇ AYRI KOLON. Her biri kendi listesinden seçilir
-- (hizmet arama penceresi, kategori ve modalite açılır liste), hangisi
-- doluysa hedef türü ondan TÜRETİLİR - iki alanı elle tutarlı tutma yükü
-- ortadan kalkar. En fazla biri dolu olabilir; ihlali iş kuralı hatasıdır.
--
-- Hedef türü kodu (prim.hedef_tur) aynı kalır: 0 Tümü, 1 Hizmet,
-- 2 Modalite, 3 Kategori. Yalnız 3'ün ADI düzeltildi - eşleştirme zaten
-- hizmet.kategori üzerinden yapılıyordu, "Hizmet grubu" yanlış isimdi.

update public.kod_deger d
   set ad = 'Kategori'
  from public.kod_liste l
 where l.id = d.liste_id and l.kod = 'prim.hedef_tur'
   and d.deger = '3' and d.ad <> 'Kategori';

-- ------------------------------------------------------- kolon geçişi ----
alter table public.prim_plani_satir
  add column if not exists hedef_hizmet_id   integer  references public.hizmet(id),
  add column if not exists hedef_kategori_id integer  references public.kategori(id),
  add column if not exists hedef_modalite    smallint;

do $$
begin
    -- Eski (hedef_tur, hedef_id) ciftini yeni kolonlara tasi ve DUSUR.
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'prim_plani_satir'
                  and column_name = 'hedef_id') then

        update public.prim_plani_satir
           set hedef_hizmet_id   = case when hedef_tur = 1 then nullif(hedef_id, 0) end,
               hedef_modalite    = case when hedef_tur = 2 then nullif(hedef_id, 0)::smallint end,
               hedef_kategori_id = case when hedef_tur = 3 then nullif(hedef_id, 0) end
         where coalesce(hedef_tur, 0) <> 0;

        alter table public.prim_plani_satir drop column hedef_id;
        alter table public.prim_plani_satir drop column hedef_tur;
    end if;

    -- Hedef turu artik TURETILIR: hangi hedef doluysa o. Elle secilen ikinci
    --   bir alan olmadigi icin "tur 1 yaziliydi ama hizmet bos" tutarsizligi
    --   imkansiz hale gelir.
    if not exists (select 1 from information_schema.columns
                    where table_schema = 'public' and table_name = 'prim_plani_satir'
                      and column_name = 'hedef_tur') then
        alter table public.prim_plani_satir
          add column hedef_tur smallint generated always as (
              case when hedef_hizmet_id   is not null then 1
                   when hedef_modalite    is not null then 2
                   when hedef_kategori_id is not null then 3
                   else 0 end) stored;
    end if;
end $$;

-- Kart detay yazicisi standart denetim kolonlarini bekliyor (ekleyen /
--   degistiren): 324'te satir tablosuna konmamisti, satir kaydedilirken
--   "column ekleyen does not exist" hatasi veriyordu.
alter table public.prim_plani_satir
  add column if not exists ekleyen           integer   not null default 0,
  add column if not exists ekleme_tarihi     timestamp not null default (now())::timestamp,
  add column if not exists degistiren        integer   not null default 0,
  add column if not exists degistirme_tarihi timestamp;

comment on column public.prim_plani_satir.hedef_hizmet_id is
  'Hedef HIZMET (327) - tek bir tetkik/hizmet icin oran.';
comment on column public.prim_plani_satir.hedef_kategori_id is
  'Hedef KATEGORI (327) - hizmet.kategori ile eslesir.';
comment on column public.prim_plani_satir.hedef_modalite is
  'Hedef MODALITE (327) - hizmet.modalite ile eslesir (rad.modalite).';
comment on column public.prim_plani_satir.hedef_tur is
  'Hedef turu (327): dolu hedef kolonundan TURETILIR, elle yazilmaz.';

-- Tek hedef kurali: uc alandan en fazla biri dolu olabilir. Check yerine
--   tetik, cunku kullaniciya anlasilir mesaj (GK422) donmesi gerekiyor.
create or replace function public.tg_prim_hedef_tek()
returns trigger language plpgsql as $$
begin
    if (case when new.hedef_hizmet_id is not null then 1 else 0 end
      + case when new.hedef_kategori_id is not null then 1 else 0 end
      + case when new.hedef_modalite is not null then 1 else 0 end) > 1 then
        raise exception 'Bir prim satırında yalnız bir hedef seçilebilir: hizmet, kategori veya modalite.'
            using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tr_prim_hedef_tek on public.prim_plani_satir;
create trigger tr_prim_hedef_tek
  before insert or update on public.prim_plani_satir
  for each row execute function public.tg_prim_hedef_tek();

-- ------------------------------------------------- eslestirme fonksiyonu --
-- Hedef artik kolonlardan okunur; ozgulluk sirasi degismedi:
--   hizmet (3) > modalite (2) > kategori (1) > tumu (0).
create or replace function public.fn_prim_plan_satiri(
    p_rol        smallint,
    p_taraf_id   integer,
    p_hizmet_id  integer,
    p_modalite   smallint,
    p_belge_tur  smallint,
    p_pay        smallint,
    p_kurum_id   integer,
    p_sube_id    integer,
    p_tarih      date)
returns table (plan_id integer, satir_id integer, oran_tipi smallint,
               deger numeric, alt_sinir numeric, ust_sinir numeric, baz smallint)
language sql stable as $$
    select p.id, s.id, s.oran_tipi, s.deger, s.alt_sinir, s.ust_sinir, p.baz
      from public.prim_plani p
      join public.prim_plani_satir s on s.plan_id = p.id
     where coalesce(p.durum, 1) = 1
       and p.baslangic <= p_tarih
       and (p.bitis is null or p.bitis >= p_tarih)
       and s.rol = p_rol
       -- kapsam
       and (p.hekim_id is null or p.hekim_id = p_taraf_id)
       and (coalesce(p.odeyen_kurum_id, 0) = 0 or p.odeyen_kurum_id = p_kurum_id)
       and (coalesce(p.sube_id, 0) = 0 or p.sube_id = p_sube_id)
       -- hedef (bos = tumu)
       and (s.hedef_tur = 0
            or s.hedef_hizmet_id = p_hizmet_id
            or s.hedef_modalite = p_modalite
            or s.hedef_kategori_id =
                 (select h.kategori from public.hizmet h where h.id = p_hizmet_id))
       -- belge türü kriteri (bos = tumu)
       and (s.belge_turleri = ''
            or p_belge_tur is null
            or p_belge_tur::text = any(string_to_array(s.belge_turleri, ',')))
       -- pay kriteri
       and (s.pay = 0 or s.pay = p_pay)
     order by
       -- ozgulluk: dolu kriter sayisi
       (case when s.hedef_tur = 1 then 3 when s.hedef_tur = 2 then 2
             when s.hedef_tur = 3 then 1 else 0 end)
       + (case when s.belge_turleri <> '' then 1 else 0 end)
       + (case when s.pay <> 0 then 1 else 0 end)
       + (case when p.hekim_id is not null then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$$;

comment on function public.fn_prim_plan_satiri is
  'Kalem+rol icin EN DAR eslesen prim plan satiri (324, hedef kolonlari 327).';
