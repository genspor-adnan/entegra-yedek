-- =============================================================================
--  1275 - SATIŞ KONSİNYE LİSTESİ YETKİ KODU  (07.11.2026)
--
--  · Satış Konsinye Listesi (tur 119) yalnız HBYS'de ve menüde gizliydi, yetkisi geniş `belge.satis` idi; kullanıcı
--    ERP'de listeyi göremedi. Liste artık her iki kipte Satış grubunda; ekran bazlı kodu `belge.satis.konsinye`
--    (alış karşılığı `belge.alis.konsinye` 1004 ile açılmıştı). 1004 deseni: kod ana koddan türetilir, ana kodun
--    rol yetkileri kopyalanır, rol yetki sürümü artar. İdempotent.
-- =============================================================================
begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40)) on commit drop;
insert into _bolme values
  ('belge.satis.konsinye', 'belge.satis', 'Satış Konsinyeler (Satış)', 'Satış');

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, sira = excluded.sira,
       urun_modu = excluded.urun_modu, modul = excluded.modul, aktif = 1;

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1275: eski kod belge.satis yetki tablosunda yok'; end if;
end $$;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'belge.satis.konsinye');

do $$
declare n int;
begin
  select count(*) into n from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id where y.kod = 'belge.satis.konsinye';
  raise notice '1275 tamam: belge.satis.konsinye - % rol yetkisi', n;
end $$;

commit;
