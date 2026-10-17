-- =============================================================================
--  1130  ESKİ AŞAMA 1 LİSTE KODLARI YALNIZ GÖR (liste / kart ayrımı - grup 1)
--
--  Kullanıcı (17.10.2026): "dışarıda kalanları grup grup yap". Bu grup aşama 1'de (1004) zaten
--  liste ekranı için bölünmüş ama tam yetki taşıyan üç kod:
--    muayene.liste        Muayene › Muayene Listesi   kart / veri: muayene
--    ftr.seans.liste      FTR › Seans Listesi          kart / veri: ftr.seans
--    medula.fatura.liste  Medula › Fatura Listesi      kart / veri: medula.fatura
--  1126 (Kayıt Kabul) ile aynı adımlar: liste satırındaki Ekle / Değiştir / Sil karta açılır (kimse
--  hak kaybetmez - bu roller o işlemleri liste kodu köprüsüyle zaten yapıyordu), listede sıfırlanır.
--
--  1129 DÜZELTMESİ: aday üretici bu üç kodu KART sanıp üstlerine `<kod>.liste.liste` açmış ve
--  adlarını "... Kartı" yapmıştı. Fazladan kodlar silinir (rol satırları FK ile gider; Gör'leri
--  liste kodunun kendi Gör'ünden üretilmişti, bilgi kaybı yok), adlar geri döner.
--
--  Dokunulan rol satırları önce public._yedek_rol_yetki_1130'a yazılır. İdempotent.
-- =============================================================================

begin;

create temp table _l (liste varchar(60), kart varchar(60), eski_ad varchar(120), yanlis_ad varchar(120))
  on commit drop;
insert into _l values
  ('muayene.liste',       'muayene',       'Muayeneler (Muayene)', 'Muayene Kartı'),
  ('ftr.seans.liste',     'ftr.seans',     'Seanslar (FTR)',       'Seans Uygulama Kartı'),
  ('medula.fatura.liste', 'medula.fatura', 'Faturalar (Medula)',   'Medula Faturası Kartı');

create table if not exists public._yedek_rol_yetki_1130 as
select ry.*, now() as yedek_tarihi from public.rol_yetki ry where false;

insert into public._yedek_rol_yetki_1130
select ry.*, now()
  from public.rol_yetki ry
  join public.yetki y on y.id = ry.yetki_id
 where (y.kod in (select liste from _l) and (ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1))
    or y.kod in (select liste || '.liste' from _l)
    or (y.kod in (select kart from _l)
        and exists (select 1 from public.rol_yetki rl
                      join public.yetki yl on yl.id = rl.yetki_id
                      join _l l on l.liste = yl.kod and l.kart = y.kod
                     where rl.rol_id = ry.rol_id
                       and (rl.ekle > ry.ekle or rl.degistir > ry.degistir or rl.sil > ry.sil)));

-- 1) Liste satırındaki işlem hakkı karta (yalnız AÇAR).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select rl.rol_id, yk.id, 1, rl.ekle, rl.degistir, rl.sil, 0
  from public.rol_yetki rl
  join public.yetki yl on yl.id = rl.yetki_id
  join _l l            on l.liste = yl.kod
  join public.yetki yk on yk.kod = l.kart
 where (rl.ekle = 1 or rl.degistir = 1 or rl.sil = 1)
on conflict (rol_id, yetki_id) do update
   set gor      = 1,
       ekle     = greatest(public.rol_yetki.ekle,     excluded.ekle),
       degistir = greatest(public.rol_yetki.degistir, excluded.degistir),
       sil      = greatest(public.rol_yetki.sil,      excluded.sil),
       degistirme_tarihi = now()
 where excluded.ekle > public.rol_yetki.ekle
    or excluded.degistir > public.rol_yetki.degistir
    or excluded.sil > public.rol_yetki.sil;

-- 2) Liste satırları yalnız Gör.
update public.rol_yetki ry
   set ekle = 0, degistir = 0, sil = 0, degistirme_tarihi = now()
  from public.yetki y
 where y.id = ry.yetki_id and y.kod in (select liste from _l)
   and (ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1);

-- 3) 1129'un fazladan açtığı `<liste>.liste` kodları.
update public.ai_rehber_ekran r set yetki_kodu = l.liste
  from _l l where r.yetki_kodu = l.liste || '.liste';
delete from public.yetki where kod in (select liste || '.liste' from _l);

-- 4) Adlar geri (kurum elle değiştirmişse dokunulmaz).
update public.yetki y set ad = l.eski_ad
  from _l l where y.kod = l.liste and y.ad = l.yanlis_ad;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public._yedek_rol_yetki_1130 b
                where b.rol_id = r.id and b.yedek_tarihi = now());

commit;
