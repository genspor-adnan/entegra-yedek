-- =============================================================================
--  1102  YETKİ - "Sol menüyü görür" (ana ekran v3, menüsüz çalışma)
--
--  Kullanıcı 14.10.2026: "menü görebilir/göremez diye rol yetkilere ekleme
--  yapacağız". Mockup Ekranlar/Ayarlar/ana_ekran_sekmeli_v3.html: menüyü
--  görmeyen rol ekranlara Ctrl+K araması, Başlangıç ve ekran sekmeleriyle ulaşır.
--
--  YALNIZ MENÜNÜN GÖRÜNÜMÜ: ekran yetkileri değişmez - menüsü kapalı kullanıcı
--  yetkisi olan ekranı aramadan yine açar, yetkisiz ekran yine açılmaz.
--
--  BUGÜNKÜ DAVRANIŞ KORUNUR: mevcut BÜTÜN rollere Gör verilir (rol menüyü
--  görmeye devam eder). Kurum, menüsüz çalışacak rolde kutuyu kaldırır.
--  İdempotent: var olan rol_yetki satırına dokunmaz.
-- =============================================================================

begin;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul, aktif)
select 'kabuk.menu', 'Sol menüyü görür', 'Sistem', 0, 9111, 0, '', 1
 where not exists (select 1 from public.yetki where kod = 'kabuk.menu');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekleyen)
select r.id, y.id, 1, 0
  from public.rol r
  join public.yetki y on y.kod = 'kabuk.menu'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where y.kod = 'kabuk.menu' and ry.rol_id = r.id);

commit;
