-- 232: Yetkiler urun moduna gore suzulur (kullanici: "bu roller de moda gore
-- erp/hbys sekil alacak, liste ona gore cikacak").
--
-- urun_modu: 0 = her iki urunde de var (varsayilan), 1 = yalniz Gentegre AI
-- (ERP), 2 = yalniz GenoTIP AI (HBYS). Aktif mod referans 'genel.urun_modu'
-- ile belirlenir; rol karti > Yetki Matrisi yalniz uyan yetkileri gosterir.

alter table public.yetki
  add column if not exists urun_modu smallint not null default 0;

comment on column public.yetki.urun_modu is
  '0 her mod, 1 ERP (Gentegre AI), 2 HBYS (GenoTIP AI) - referans genel.urun_modu ile eslesir';

create index if not exists ix_yetki_urun_modu on public.yetki (urun_modu)
  where urun_modu <> 0;

-- Kayit Kabul / hasta tarafi HBYS'e ozgu: su an ayri yetki kodu yok
-- (Hasta Listesi 'personel' yetkisini kullaniyor), klinik yetkileri
-- eklendikce urun_modu = 2 ile isaretlenecek.
