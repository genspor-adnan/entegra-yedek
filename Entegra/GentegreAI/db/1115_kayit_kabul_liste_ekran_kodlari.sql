-- =============================================================================
--  1115  KAYIT KABUL › HASTA LİSTESİ / BAŞVURU LİSTESİ - ekran kodları
--
--  Kullanıcı (16.10.2026): "uzman doktor rolü kayıt kabulü de göremesin.. grup olarak".
--  Hasta Listesi `hasta`, Başvuru Listesi `belge` koduyla açılıyordu - ama bu kodlar hekimin
--  muayenede okuduğu VERİYİ de açıyor (hasta bandı, hasta araması, başvuru / istem). Hekimden
--  `hasta` / `belge` alınamaz; menü ekranı ayrı koda bölünür (1003 / 1046 ilkesi, menü kodu =
--  yetki matrisi kodu):
--    hasta.liste    Kayıt Kabul › Hasta Listesi      ← hasta
--    basvuru.liste  Kayıt Kabul › Başvuru Listesi    ← belge
--  Eski kodu gören her rol yeni ekranı AYNI haklarla görür (kimse yetki kazanmaz / kaybetmez).
--  Veri eski kodlarda kalır. İdempotent.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('hasta.liste',   'hasta', 'Hasta Listesi (Kayıt Kabul)',   'Kayıt Kabul'),
  ('basvuru.liste', 'belge', 'Başvuru Listesi (Kayıt Kabul)', 'Kayıt Kabul');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1115: % satırın eski kodu yetki tablosunda yok', n; end if;
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

-- Yardım kataloğu: ekranların kodu yeni kod (asistan yetkiye göre süzer).
update public.ai_rehber_ekran set yetki_kodu = 'hasta.liste'   where kaynak = 'hasta' and rota = '/hasta'   and yetki_kodu = 'hasta';
update public.ai_rehber_ekran set yetki_kodu = 'basvuru.liste' where kaynak = 'belge' and rota = '/basvuru' and yetki_kodu = 'belge';

commit;
