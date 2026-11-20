-- 1395: Rapor Gönderimi Ayarı - laboratuvar menüsünün ekran yetkisi (1394).
--
--   Ayar ekranı TEKTİR (radyoloji + laboratuvar aynı satırı düzenler; kullanıcı 20.11.2026: "tek rapor gönderim ayarı
--   olsa"). Menüde iki yerden açılır: Radyoloji › Ayarlar (radyoloji.rapor_gonderim, 1392) ve Laboratuvar › Ayarlar.
--   Her yetki kodu yalnız BİR menü ekranı açar (yetki matrisi = menü birebir) - laboratuvar girişi kendi kodunu alır:
--
--   lab.rapor_gonderim   EKRAN   Laboratuvar › Ayarlar › Rapor Gönderimi Ayarı. Uç iki koddan birini kabul eder.
--                                Genel Ayarlar'ı DEĞİŞTİRebilen rollere gör + değiştir.
-- İdempotent; var olan rol yetkisine dokunulmaz (on conflict do nothing).
\set ON_ERROR_STOP on

begin;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'lab.rapor_gonderim', 'Rapor Gönderimi ayarları (Laboratuvar)', ye.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye where ye.kod = 'lab.icmal'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, 1, 0, 1, 0, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'lab.rapor_gonderim'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'ayar' and coalesce(ry.degistir, 0) = 1
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'lab.rapor_gonderim');

commit;
