-- ============================================================================
--  Gentegre AI — ÜNVAN LİSTESİNE "Uzm.Dt."
--  844_unvan_uzman_dis_hekimi.sql
--
--  Kullanıcı: *"personel kartında sicil no editini 2'ye böl, sağına Ünvan
--  combo ekle.. Dr. Uzm.Dr. Opr.Dr. Doç.Dr. Prof.Dr. Dt. Uzm.Dt. Dr.Dt
--  gibi"*.
--
--  `hekim.unvan` listesi zaten vardı (diş hekimi kartı kullanıyor) ve
--  istenen ünvanların yalnız biri eksikti: **Uzm.Dt.** Listedeki "Op.Dr."
--  ile istenen "Opr.Dr." aynı ünvan - ikinci bir satır açmak aynı kişiyi iki
--  farklı ünvanla yazdırırdı, o yüzden mevcut yazım korundu.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select kl.id, 8, 0, 'Uzm.Dt.', 8, 1
  from public.kod_liste kl
 where kl.kod = 'hekim.unvan'
   and not exists (select 1 from public.kod_deger kd
                    where kd.liste_id = kl.id and kd.ad = 'Uzm.Dt.')
on conflict (liste_id, deger, dil) do nothing;

do $$
declare v_liste text;
begin
    select string_agg(kd.ad, ' · ' order by kd.sira) into v_liste
      from public.kod_liste kl
      join public.kod_deger kd on kd.liste_id = kl.id
     where kl.kod = 'hekim.unvan' and kd.aktif = 1;
    raise notice '844 tamam: hekim.unvan = %', v_liste;
end $$;
