-- =============================================================================
--  1044  İSG / OSGB İCMALİ - ekran kodu + firma aylık hizmet bedeli
--
--  Kullanıcı (12.10.2026): "icmalleri yap" (mockup
--  Ekranlar/İcmal/isg_osgb_icmali.html).
--
--  AYLIK HİZMET BEDELİ: sözleşmenin aylık bedeli hiçbir yerde tutulmuyordu
--  (yalnız sözleşme dakikası vardı). Firma kartında girilir:
--    isg_firma.aylik_ucret   sözleşmedeki aylık bedel (TL, 0 = girilmemiş)
--  Faturalanan / tahsil / bakiye bundan DEĞİL, firmanın carisinden
--  (v_cari_ekstre) gelir; aylık bedel yalnız sözleşme bilgisidir.
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    isg.icmal   İşyeri Hekimliği › İSG / OSGB İcmali   ← isg.pano
--  Firma panosunu gören rol yeni ekranı AYNI haklarla görür. İdempotent.
-- =============================================================================

begin;

alter table public.isg_firma add column if not exists aylik_ucret numeric(19,2) not null default 0;
comment on column public.isg_firma.aylik_ucret is
  'Sözleşmedeki aylık hizmet bedeli, TL (1044, İSG / OSGB İcmali). 0 = girilmemiş.';

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('isg.icmal', 'isg.pano', 'İSG / OSGB İcmali (İşyeri Hekimliği)', 'İşyeri Hekimliği');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1044: % satırın eski kodu yetki tablosunda yok', n; end if;
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
    ('isg-icmal', '/isg-icmal', 'İSG / OSGB İcmali', 'İşyeri Hekimliği › İSG / OSGB İcmali',
     'İşyeri Hekimliği', 'İSG / OSGB İcmali', 'isg.icmal', 2,
     'isg osgb icmal işyeri hekimliği hizmet süresi dakika muayene periyodik geciken ziyaret defter imza iş kazası meslek hastalığı sgk bildirim hizmet bedeli sözleşme bakiye',
     'Dönemde firma başına plan / gerçekleşen hizmet dakikası (ziyaret + muayene), Ek-2 muayene türü ve kanaat, geciken periyodik muayeneler, '
     || 'ziyaretler ve defter imzası, iş kazası / meslek hastalığı / ramak kala ve SGK bildirim süresi, hizmet bedeli, fatura, tahsil ve sözleşme bitişi; A4. '
     || 'Aylık bedel firma kartında, fatura ve tahsil firmanın carisinden.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
