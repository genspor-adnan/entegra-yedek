-- =============================================================================
--  1045  KALİTE / SKS İCMALİ - ekran kodu + bildirim hedef ayarları
--
--  Kullanıcı (12.10.2026): "icmalleri yap" (mockup
--  Ekranlar/İcmal/kalite_sks_icmali.html).
--
--  YENİ TABLO YOK: ISO kalite modülü (DÖF, olay takibi / kök neden analizi,
--  şikâyet, bileklik gözlemi) henüz yok; icmal mevcut kayıtlardan kurulur
--  (klinik_gosterge_donem, lab_panik_bildirim, radyoloji_kritik_bulgu,
--  form_istek: grs_olay / el_hijyeni / memnuniyet / itaki / braden, yatis,
--  ameliyat_kontrol). Kaynağı olmayan gösterge ekranda "kaynak yok" görünür.
--
--  BİLDİRİM HEDEFLERİ (mockup notunda "yeni ayar"):
--    kalite.panik_hedef_dk    lab panik değer: sonuç onayı → bildirim, dk (30)
--    kalite.kritik_hedef_dk   radyoloji kritik bulgu: rapor onayı → bildirim, dk (60)
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    kalite.icmal   Kalite › Kalite / SKS İcmali   ← klinik_kalite.donem
--  Klinik Kalite dönem sonuçlarını gören rol yeni ekranı AYNI haklarla görür. İdempotent.
-- =============================================================================

begin;

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, 'sayi', 'firma', v.aciklama
  from (values
    ('kalite.panik_hedef_dk', '30', 'Lab panik değer: sonuç onayından hekime bildirime hedef süre, dakika (1045, Kalite / SKS İcmali).'),
    ('kalite.kritik_hedef_dk', '60', 'Radyoloji kritik bulgu: rapor onayından hekime bildirime hedef süre, dakika (1045, Kalite / SKS İcmali).'))
    as v(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('kalite.icmal', 'klinik_kalite.donem', 'Kalite / SKS İcmali (Kalite)', 'Kalite');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1045: % satırın eski kodu yetki tablosunda yok', n; end if;
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
--  Asistan ekranı tarif edebilsin (yeni ekran = ai_rehber_ekran satırı).
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('kalite-icmal', '/kalite-icmal', 'Kalite / SKS İcmali', 'Kalite › Kalite / SKS İcmali',
     'Kalite', 'Kalite / SKS İcmali', 'kalite.icmal', 2,
     'kalite sks icmal gösterge hedef kritik panik bildirim süresi grs olay düşme bası yarası braden itaki el hijyeni memnuniyet anket güvenli cerrahi',
     'Dönemde SKS göstergeleri (kritik / panik bildirim süresi, düşme, bası yarası, el hijyeni, memnuniyet, güvenli cerrahi) ve Klinik Kalite '
     || 'dönem sonuçları hedefle; GRS olayları tür × zarar; servis bazında düşme / bası yarası; memnuniyet birim ve soru ortalamaları, A4. '
     || 'Bildirim hedefleri kalite.panik_hedef_dk / kalite.kritik_hedef_dk ayarından. DÖF, olay takibi ve şikâyet kaydı henüz yok.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
