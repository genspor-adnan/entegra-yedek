-- =============================================================================
--  1270 - FATURA AYARLARI EKRANI: şube kartının e-Belge sekmesi Satış › Ayarlar › Fatura Ayarları'na
--
--  Kullanıcı (05.11.2026): "firma/şube bilgilerinde e-belge sekmesini satış ana menüsü altında ayarlar altına
--  'Fatura Ayarları' menüsü olarak taşı.. Baz Alınacak Şube combosu da ekle".
--
--  Şubenin e-Belge kimliği (baz alınacak şube, gönderici etiketi, varsayılan seri, mükellefiyet bayrakları) ile
--  seri kuralları / XSLT / tür ayarları şube kartından çıktı; yeni ekran üstte şube seçtirir, altında aynı kartın
--  yalnız e-Belge sekmesini çizer (veri yine `sube` satırında, yazma yetkisi yine `sube`). Menü kodu = yetki
--  matrisi kodu ilkesiyle (1003) kendi ekran kodu:
--
--    satis.fatura_ayar   Satış › Ayarlar › Fatura Ayarları   ← sube   (1262 uretim.ayar deseni)
--
--  Rolde `sube` varsa `satis.fatura_ayar` AYNI haklarla eklenir - kimse yetki kazanmaz ya da kaybetmez.
--  İdempotent: var olan rol_yetki / rehber satırına dokunmaz.
-- =============================================================================

begin;

do $$ begin
  if not exists (select 1 from public.yetki where kod = 'sube') then
    raise exception '1270: kaynak kod sube yetki tablosunda yok';
  end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'satis.fatura_ayar', 'Fatura Ayarları (Satış)', 'Satış', 0,
       coalesce((select max(sira) from public.yetki where grup = 'Satış'), ye.sira), 0, ye.modul
  from public.yetki ye
 where ye.kod = 'sube'
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'satis.fatura_ayar'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'sube'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'satis.fatura_ayar');

-- ---------------------------------------------------- rehber ekran kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, modul,
                                    anahtar, aciklama)
select 'fatura-ayarlar', '/fatura-ayarlar', 'Fatura Ayarları', 'Satış › Ayarlar › Fatura Ayarları', 'Satış',
       'Fatura Ayarları', 'satis.fatura_ayar', 0::smallint, '',
       'fatura ayarları e-belge e-fatura e-arşiv e-irsaliye e-smm mükellef gönderici etiketi alias seri xslt baz alınacak şube',
       'Şube seçilir; o şubenin e-Belge kimliği (baz alınacak şube, gönderici etiketi, varsayılan seri, mükellefiyet) '
       || 'ile seri kuralları, XSLT şablonları ve e-Fatura / e-Arşiv / e-İrsaliye / e-SMM ayarları burada düzenlenir. '
       || 'Eskiden Firma / Şubeler kartının e-Belge sekmesiydi.'
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'fatura-ayarlar');

update public.ai_rehber_ekran
   set aciklama = replace(aciklama, 'e-Belge sekmesi', 'e-Belge ayarları (Satış › Ayarlar › Fatura Ayarları)')
 where kaynak = 'sube' and aciklama like '%e-Belge sekmesi%';

update public.help
   set metin = replace(replace(metin, 'Yönetim › Firma / Şubeler → şubeyi açın → e-Belge', 'Satış › Ayarlar › Fatura Ayarları'),
                       'Firma / Şubeler › e-Belge', 'Satış › Ayarlar › Fatura Ayarları')
 where metin like '%Firma / Şubeler%e-Belge%';

do $$ begin
  raise notice '1270: satis.fatura_ayar ekran kodu, % role verildi',
    (select count(*) from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id where y.kod = 'satis.fatura_ayar');
end $$;

commit;
