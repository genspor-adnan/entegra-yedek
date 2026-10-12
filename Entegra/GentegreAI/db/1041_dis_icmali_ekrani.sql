-- =============================================================================
--  1041  DİŞ İCMALİ - ekran kodu + yardım kataloğu
--
--  Kullanıcı (12.10.2026): "icmalleri yap" (mockup Ekranlar/İcmal/dis_icmali.html).
--  Şema değişikliği yok: hesap dis_seans / dis_seans_islem / dis_seans_sarf /
--  dis_tedavi_plani(_satir) / dis_lab_isemri / dis_unit / dis_odeme_* üzerinden.
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    dis.icmal   Diş › Diş İcmali   ← dis.odeme (Ödeme planı & borçlu hastalar)
--  Ciro / kâr içerdiği için finansal diş ekranının haklarını alır. İdempotent.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('dis.icmal', 'dis.odeme', 'Diş İcmali', 'Diş');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1041: % satırın eski kodu yetki tablosunda yok', n; end if;
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

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('dis-icmal', '/dis-icmal', 'Diş İcmali', 'Diş › Diş İcmali',
     'Diş', 'Diş İcmali', 'dis.icmal', 2,
     'diş icmal hekim seans işlem ciro sarf laboratuvar brüt kâr marj tedavi planı kabul tamamlanma yarım kalan plan ünite doluluk',
     'Dönemde hekim başına seans, hasta, işlem, ciro, sarf, lab ve brüt kâr; tedavi planı hunisi (sunulan / kabul / tamamlandı); '
     || 'son seanstan 45+ gün geçmiş yarım kalan planlar; işlem türleri; laboratuvar bedelleri ve gecikmeler; ünite doluluğu, A4.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
