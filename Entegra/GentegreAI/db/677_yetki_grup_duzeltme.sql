-- ============================================================================
--  Gentegre AI — YETKİ GRUPLARI SON DÜZELTME
--  677_yetki_grup_duzeltme.sql
--
--  675'de adımlar sırayla çalışıyordu: aksiyonlar üst modüllerinin grubunu
--  DEVRALDIKTAN SONRA, menüde karşılığı olmayan modüller "Yönetim"e taşındı.
--  Sonuç: `kredi.taksit-ode` ve `kullanici.parola-sifirla` üstleri Yönetim'e
--  geçmeden önceki eski kısa gruplarıyla ("mali", "yonetim") kaldı ve matriste
--  kendi başlıklarını açtılar.
--
--  Burada devralma en son bir kez daha yapılır - üstü nerede duruyorsa aksiyon
--  da oradadır. Bir de menü grubu boş olan tek ekran (Demirbaş) kendi adıyla
--  başlık olur; boş grup ağaçta adsız bir kök çiziyordu.
-- ============================================================================
\set ON_ERROR_STOP on

update public.yetki a
   set grup = u.grup,
       modul = case when a.modul = '' then u.modul else a.modul end
  from public.yetki u
 where a.kod like '%.%'
   and u.tur = 0
   and u.kod = split_part(a.kod, '.', 1)
   and (a.grup <> u.grup or (a.modul = '' and u.modul <> ''));

update public.yetki set grup = 'Demirbaş' where kod = 'demirbas' and grup = '';

-- Grubu hâlâ boş kalan varsa (ileride menüsüz bir yetki eklenirse) Yönetim'e.
update public.yetki set grup = 'Yönetim' where grup = '' and aktif = 1;

do $$
begin
    raise notice '677 tamam: aksiyon gruplari ustleriyle hizalandi.';
end $$;
