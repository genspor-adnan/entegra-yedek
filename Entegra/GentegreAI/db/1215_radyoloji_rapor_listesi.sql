-- =============================================================================
--  1215  RADYOLOJİ RAPOR LİSTESİ - ekran yetkisi
--
--  Kullanıcı (31.10.2026): "raporlara kolay erişim için Radyoloji Rapor Listesi.. istemden üretilir"
--  (mockup Ekranlar/Radyoloji/radyoloji_rapor_listesi.html). Yeni tablo yok: liste radyoloji_rapor +
--  radyoloji_istem üzerinde (sunucu kaynağı `radyoloji-rapor`).
--
--  Kod `radyoloji.rapor.liste` yalnız GÖR (EkranKodlari.YalnizGorListe -> `radyoloji`): rapor ekranı ve
--  rapor çıktısı zaten `radyoloji` ister - Kritik Bulgu / Konsültasyon / Sonuç Teslim listeleriyle
--  (1132) aynı desen. `radyoloji`'yi GÖREN her rol listeyi de görür (rapor ekranını açabilen herkes).
--  Kurulumda `radyoloji` kodu yoksa (modül kurulmamış) hiçbir satır eklenmez. İdempotent.
-- =============================================================================

begin;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'radyoloji.rapor.liste', 'Rapor Listesi (Radyoloji)', k.grup, 0, k.sira, k.urun_modu, k.modul
  from public.yetki k
 where k.kod = 'radyoloji'
on conflict (kod) do update
   set grup = excluded.grup, tur = 0, aktif = 1;

with eklenen as (
  insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
  select ry.rol_id, yl.id, 1, 0, 0, 0, '', ry.kapsam, 0
    from public.yetki yk
    join public.yetki yl     on yl.kod = 'radyoloji.rapor.liste'
    join public.rol_yetki ry on ry.yetki_id = yk.id and ry.gor = 1
   where yk.kod = 'radyoloji'
  on conflict (rol_id, yetki_id) do nothing
  returning rol_id)
update public.rol r set yetki_surumu = yetki_surumu + 1
 where r.id in (select rol_id from eklenen);

commit;
