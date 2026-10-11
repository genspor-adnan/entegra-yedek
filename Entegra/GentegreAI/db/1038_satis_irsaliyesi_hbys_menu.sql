-- =============================================================================
--  1038  SATIŞ İRSALİYELERİ - HBYS menü kodu
--
--  Kullanıcı (11.10.2026): "Satış Faturası menüsünün altına Satış İrsaliyesi,
--  Alış faturası altına da Alış İrsaliyesi olsun". HBYS'de Satış grubu (erp_satis)
--  kapalı; satış irsaliyesi Kurumlar & Sigorta › Satış Faturaları'nın altına
--  ikiz ekranla gelir (satış faturası ikizi belge.kurum_fatura deseni, 1003).
--    belge.kurum_irsaliye  ← belge.satis.irsaliye (haklar kopyalanır). İdempotent.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('belge.kurum_irsaliye', 'belge.satis.irsaliye', 'Satış irsaliyeleri (Kurumlar & Sigorta › Satış İrsaliyeleri)', 'Kurumlar & Sigorta');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1038: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

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
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

commit;
