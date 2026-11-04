-- =============================================================================
--  1262 - ÜRETİM AYARLARI EKRANI: Genel Ayarlar › Üretim sekmesi Üretim › Ayarlar › Üretim Ayarları'na
--
--  Kullanıcı (04.11.2026): "Genel Ayarlar altındaki Üretim sekmesini Üretim modülünde ayarlar altına
--  'Üretim Ayarları' olarak taşı".
--
--  Üretim seviyesi (basit / standart / denetimli) ve "Üretim emri kullan" ayarı 1253'te Genel Ayarlar'ın bir
--  sekmesiydi ve genel `ayar` yetkisine bağlıydı. Ekran artık Üretim menü grubunda kendi sayfası; menü kodu =
--  yetki matrisi kodu ilkesiyle (1003) kendi ekran kodunu alır:
--
--    uretim.ayar     Üretim › Ayarlar › Üretim Ayarları   ← ayar   (1007 demirbas.ayar deseni)
--
--  Rolde `ayar` varsa `uretim.ayar` AYNI haklarla eklenir - kimse yetki kazanmaz ya da kaybetmez; Üretim
--  Sorumlusu gibi rollere ayrıca matristen verilir. Sunucu kapısı: PUT /api/uretim/seviye `uretim.ayar`
--  ya da `ayar` Değiştir ister; `uretim.ayar` genel ayar kapısını AÇMAZ (EkranKodlari.KendiKapisi).
--  İdempotent: var olan rol_yetki / rehber satırına dokunmaz.
-- =============================================================================

begin;

-- ------------------------------------------------------------ ekran kodu --
do $$ begin
  if not exists (select 1 from public.yetki where kod = 'ayar') then
    raise exception '1262: eski kod ayar yetki tablosunda yok';
  end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'uretim.ayar', 'Üretim Ayarları (Üretim)', 'Üretim', 0,
       coalesce((select max(sira) from public.yetki where grup = 'Üretim'), ye.sira), 0, 'uretim'
  from public.yetki ye
 where ye.kod = 'ayar'
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, modul = excluded.modul, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'uretim.ayar'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'ayar'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'uretim.ayar');

-- ---------------------------------------------------- rehber ekran kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, modul,
                                    anahtar, aciklama)
select 'uretim-ayarlar', '/uretim-ayarlar', 'Üretim Ayarları', 'Üretim › Ayarlar › Üretim Ayarları', 'Üretim',
       'Üretim Ayarları', 'uretim.ayar', 1::smallint, 'uretim',
       'üretim ayarları üretim seviyesi basit standart denetimli üretim emri kullan kobi karantina kalite',
       'Üretim seviyesi (Basit · Standart · Denetimli) ve basit seviyede "Üretim emri kullan" seçimi; '
       || 'seviye yalnız görüneni ve zorunlulukları değiştirir, alta geçiş açık emir ya da karantinadaki fiş varken engellenir.'
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'uretim-ayarlar');

-- Yardım metni Genel Ayarlar'ı gösteriyordu.
update public.help
   set metin = replace(metin, 'Genel Ayarlar › Üretim', 'Üretim › Ayarlar › Üretim Ayarları')
 where anahtar in ('uretim.seviye', 'uretim.emir_kullan') and metin like '%Genel Ayarlar › Üretim%';

do $$ begin
  raise notice '1262: uretim.ayar ekran kodu, % role verildi',
    (select count(*) from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id where y.kod = 'uretim.ayar');
end $$;

commit;
