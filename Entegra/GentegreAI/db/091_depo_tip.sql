-- ============================================================================
--  Gentegre AI — Depo tipi
--  091_depo_tip.sql
--
--  Depo listesinde "Tipi" kolonu istendi: Merkez / Demirbaş / Konsinye Alış /
--  Konsinye Satış. Bugune kadar bu ayrim yalnizca DEPO ADINDA sakliydi
--  ("Konsinye Giriş" gibi) - yani rapor/kural yazilamayan bir bilgiydi.
--  Kod listesi olarak eklenir; konsinye depolarinin ayri tipte olmasi ileride
--  konsinye stogun kendi bakiyesinden ayrilmasini mumkun kilar.
--
--  Geriye donuk doldurma: SADECE adi birebir eslesen 3 depo isaretlenir
--  (Demirbaş / Konsinye Giriş / Konsinye Satış). Geri kalan her depo Merkez
--  varsayilir - ad tahminiyle toptan siniflandirma yapilmaz, kullanici karttan
--  degistirir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.depo add column if not exists tip smallint not null default 1;

comment on column public.depo.tip is
  '1 merkez / 2 demirbas / 3 konsinye alis / 4 konsinye satis. Kod listesi: depo.tip.';

insert into public.kod_liste (kod, ad) values ('depo.tip', 'Depo Tipi')
on conflict (kod) do update set ad = excluded.ad;

insert into public.kod_deger (liste_id, deger, ad, sira)
select l.id, v.deger, v.ad, v.sira
  from public.kod_liste l,
       (values (1, 'Merkez', 10),
               (2, 'Demirbaş', 20),
               (3, 'Konsinye Alış', 30),
               (4, 'Konsinye Satış', 40)
       ) as v(deger, ad, sira)
 where l.kod = 'depo.tip'
on conflict (liste_id, deger, dil) do update set ad = excluded.ad;

-- Ad esleşmesi kesin olan depolar (yalniz halen varsayilan 1 olanlar).
update public.depo set tip = 2 where tip = 1 and ad = 'Demirbaş';
update public.depo set tip = 3 where tip = 1 and ad = 'Konsinye Giriş';
update public.depo set tip = 4 where tip = 1 and ad = 'Konsinye Çıkış';

do $$
declare v_m integer; v_d integer; v_ka integer; v_ks integer;
begin
    select count(*) filter (where tip = 1), count(*) filter (where tip = 2),
           count(*) filter (where tip = 3), count(*) filter (where tip = 4)
      into v_m, v_d, v_ka, v_ks
      from public.depo;
    raise notice '091 tamam: merkez %, demirbas %, konsinye alis %, konsinye satis %',
                 v_m, v_d, v_ka, v_ks;
end $$;
