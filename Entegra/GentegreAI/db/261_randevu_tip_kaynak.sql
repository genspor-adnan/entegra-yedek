-- 261: RANDEVU TİPİ VE KAYNAĞI (Ekranlar/randevu_karti.html mockup'ı:
-- "Randevu Tipi: Muayene", "Kaynak: Telefon").
--
-- Tip = randevunun işi (muayene / kontrol / tetkik...), kaynak = randevunun
-- nereden geldiği (telefon, web...). İkisi de kod listesi: kurumdan kuruma
-- değişir, kod tablosu bunun için var.

alter table public.randevu add column if not exists tip smallint not null default 1;
alter table public.randevu add column if not exists kaynak smallint not null default 1;
comment on column public.randevu.tip is 'Randevu tipi (261) - kod_liste randevu.tip.';
comment on column public.randevu.kaynak is 'Randevu kaynağı (261) - kod_liste randevu.kaynak.';

insert into public.kod_liste (kod, ad)
select 'randevu.tip', 'Randevu Tipi'
 where not exists (select 1 from public.kod_liste where kod = 'randevu.tip');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  cross join (values (1, 'Muayene'), (2, 'Kontrol'), (3, 'Tetkik'),
                     (4, 'Girişim / İşlem'), (5, 'Aşı'), (6, 'Rapor')) as v(deger, ad)
 where l.kod = 'randevu.tip'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id);

insert into public.kod_liste (kod, ad)
select 'randevu.kaynak', 'Randevu Kaynağı'
 where not exists (select 1 from public.kod_liste where kod = 'randevu.kaynak');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  cross join (values (1, 'Telefon'), (2, 'Yerinde'), (3, 'Web'),
                     (4, 'Çağrı Merkezi'), (5, 'Hekim Yönlendirmesi'),
                     (6, 'MHRS')) as v(deger, ad)
 where l.kod = 'randevu.kaynak'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id);
