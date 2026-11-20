-- 1392: radyoloji rapor gönderimi yetkileri (1389).
--
--   radyoloji.rapor_gonderim   EKRAN   Radyoloji › Ayarlar › Rapor Gönderimi (otomatik gönderim, zaman kuralları, borç
--                                      kuralı). Genel Ayarlar'ı DEĞİŞTİRebilen rollere gör + değiştir.
--   rad.rapor_gonder           AKSİYON Teslim listesi / rapor: Şimdi Gönder, Yeniden Gönder, Gönderimi İptal Et.
--                                      "Radyoloji sonucu teslim et" (rad.teslim) yetkisi olan rollere.
--   rad.rapor_borca_ragmen     AKSİYON Başvurunun borcu varken "Borca Rağmen Gönder" (bağlantı da açılır). Yalnız
--                                      Genel Ayarlar'ı DEĞİŞTİRebilen rollere - yetki matrisinden başkasına verilir.
-- İdempotent; var olan rol yetkisine dokunulmaz (on conflict do nothing).
\set ON_ERROR_STOP on

begin;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'radyoloji.rapor_gonderim', 'Rapor Gönderimi ayarları (Radyoloji)', 'Radyoloji', 0, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye where ye.kod = 'radyoloji.teslim'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur, aktif = 1;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select v.kod, v.ad, 'Radyoloji', 1, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye
 cross join (values ('rad.rapor_gonder',       'Radyoloji raporu gönder / gönderimi iptal et'),
                    ('rad.rapor_borca_ragmen', 'Radyoloji raporunu borca rağmen gönder')) v(kod, ad)
 where ye.kod = 'rad.teslim'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur, aktif = 1;

-- rad.rapor_gonder: rad.teslim yetkisi olan roller.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, 1, 0, 0, 0, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'rad.rapor_gonder'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'rad.teslim' and coalesce(ry.gor, 0) = 1
on conflict (rol_id, yetki_id) do nothing;

-- Ayar ekranı + borca rağmen: Genel Ayarlar'ı değiştirebilen roller.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, 1, 0, case when yn.tur = 0 then 1 else 0 end, 0, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod in ('radyoloji.rapor_gonderim', 'rad.rapor_borca_ragmen')
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'ayar' and coalesce(ry.degistir, 0) = 1
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod in ('radyoloji.rapor_gonderim', 'rad.rapor_gonder', 'rad.rapor_borca_ragmen'));

commit;
