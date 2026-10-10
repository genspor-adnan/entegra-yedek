-- =============================================================================
--  1027  GÖRÜNTÜLEME (RADYOLOJİ) İCMALİ - ekran kodu + rapor süresi hedefi
--
--  Kullanıcı (10.10.2026): "görüntüleme icmalini kodla" (mockup
--  Ekranlar/İcmal/goruntuleme_icmali.html).
--
--  RAPOR SÜRESİ HEDEFİ: iç raporlama için hedef tanımı yoktu (teleradyolojide
--  sözleşme SLA'sı var). Ayar olarak eklendi (referans, kurum değiştirebilir):
--    radyoloji.rapor_hedef_dk       rutin çekim → onaylı rapor, dk (1440 = 24 sa)
--    radyoloji.rapor_hedef_acil_dk  acil çekim → onaylı rapor, dk (60)
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi; bir kod en çok
--  bir menü ekranı açar):
--    radyoloji.icmal   Radyoloji › Görüntüleme İcmali   ← teleradyoloji.kurum.fatura
--  Ciro / kâr içerdiği için çalışma listesi (radyoloji) değil, dönem
--  faturasını (mali) gören roller esas alındı. Dönem faturasını gören rol yeni ekranı AYNI haklarla görür - kimse yetki kazanmaz ya da kaybetmez. İdempotent: var
--  olan rol_yetki satırına dokunmaz.
-- =============================================================================

begin;

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, 'sayi', 'firma', v.aciklama
  from (values
    ('radyoloji.rapor_hedef_dk', '1440', 'Rutin çekimde çekim → onaylı rapor hedef süresi, dakika (1027, Görüntüleme İcmali).'),
    ('radyoloji.rapor_hedef_acil_dk', '60', 'Acil çekimde çekim → onaylı rapor hedef süresi, dakika (1027, Görüntüleme İcmali).'))
    as v(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('radyoloji.icmal', 'teleradyoloji.kurum.fatura', 'Görüntüleme İcmali (Radyoloji)', 'Radyoloji');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1027: % satırın eski kodu yetki tablosunda yok', n; end if;
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
    ('goruntuleme-icmal', '/goruntuleme-icmal', 'Görüntüleme İcmali', 'Radyoloji › Görüntüleme İcmali',
     'Radyoloji', 'Görüntüleme İcmali', 'radyoloji.icmal', 2,
     'görüntüleme radyoloji icmal modalite mr bt usg röntgen çekim ciro kontrast sarf marj rapor süresi radyolog teleradyoloji cihaz doluluk',
     'Dönemde modalite ve tetkik başına çekim, ciro, kurum / hasta payı, kontrast / sarf maliyeti ve marj; '
     || 'raporlayanlar ve rapor süresi, cihaz doluluğu, teleradyoloji giden / gelen, A4. Rapor hedef süresi '
     || 'radyoloji.rapor_hedef_dk / radyoloji.rapor_hedef_acil_dk ayarlarından.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
