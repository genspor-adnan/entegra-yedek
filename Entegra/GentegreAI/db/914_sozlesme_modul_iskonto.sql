-- =====================================================================
--  914_sozlesme_modul_iskonto.sql
--  ANLAŞMALI KURUM SÖZLEŞMESİNE MODÜL İSKONTOSU — baz özel fiyat listesi
--  üstünden lab ve radyoloji için ayrı yüzde iskonto (kullanıcı: "lab için
--  %10, radyoloji için %15 iskonto; özel fiyat listesini baz al").
--
--  Sözleşme fiyat_listesi_id = baz liste (Özel/Ücretli); iskonto o listenin
--  fiyatına satır bazında uygulanır (belge_satir.iskonto). Modül, kalemin
--  hizmetinden çıkar: hizmet.modalite>0 = radyoloji, değilse laboratuvar/diğer.
-- =====================================================================
\set ON_ERROR_STOP on

alter table public.kurum_sozlesme
  add column if not exists lab_iskonto  smallint not null default 0,
  add column if not exists rad_iskonto  smallint not null default 0;

comment on column public.kurum_sozlesme.lab_iskonto is
  '914: laboratuvar kalemlerine sözleşme iskontosu (%). Baz = fiyat_listesi_id.';
comment on column public.kurum_sozlesme.rad_iskonto is
  '914: radyoloji kalemlerine sözleşme iskontosu (%). Baz = fiyat_listesi_id.';

do $$ begin raise notice '914 tamam: kurum_sozlesme lab_iskonto/rad_iskonto'; end $$;
