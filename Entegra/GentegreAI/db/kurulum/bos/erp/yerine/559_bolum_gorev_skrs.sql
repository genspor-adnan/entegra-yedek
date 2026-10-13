-- BOŞ ERP KURULUMU: 559'un yalnız ŞEMA kısmı. Bölüm / görev listelerini SKRS
-- klinik ve branş listelerinden kuran veri kısmı HBYS'e özgü dış veri (ERP
-- canlısında da yalnız bu şema uygulanmıştı, 'yapi_erp'). Sonraki göçler kolona dayanır.
alter table public.personel_gorev
    add column if not exists kod varchar(20) not null default '';
comment on column public.personel_gorev.kod is
  'SKRS personel brans kodu (559). Bos = kuruma ozel gorev.';
comment on column public.departman.kod is
  'SKRS klinik kodu (559). Bos = kuruma ozel bolum.';
