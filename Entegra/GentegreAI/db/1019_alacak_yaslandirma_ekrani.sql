-- =============================================================================
--  1019  ALACAK YAŞLANDIRMA - ekran kodu
--
--  Kullanıcı (10.10.2026): "alacak yaşlandırmayı kodla" (mockup
--  Ekranlar/İcmal/alacak_yaslandirma.html).
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi; bir kod en çok
--  bir menü ekranı açar):
--    finans.alacak_yaslandirma   Finans › Alacak Yaşlandırma   ← kasa.finans
--  Finans kasa ekranlarını (kasa.finans) gören rol yeni ekranı AYNI
--  haklarla görür - kimse yetki kazanmaz ya da kaybetmez. İdempotent: var
--  olan rol_yetki satırına dokunmaz.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('finans.alacak_yaslandirma', 'kasa.finans', 'Alacak Yaşlandırma (Finans)', 'Finans');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1019: % satırın eski kodu yetki tablosunda yok', n; end if;
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
    ('alacak-yaslandirma', '/alacak-yaslandirma', 'Alacak Yaşlandırma', 'Finans › Alacak Yaşlandırma',
     'Finans', 'Alacak Yaşlandırma', 'finans.alacak_yaslandirma', 2,
     'alacak yaşlandırma vadesi geçmiş borç kurum hasta açık bakiye 30 60 90 gün tahsilat',
     'Hasta ve kurum açık bakiyeleri 0-30 / 31-60 / 61-90 / 90+ gün dilimlerinde; '
     || 'kurumda açık fatura + faturalanmamış kurum payı, hastada hasta payı - tahsilat.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
