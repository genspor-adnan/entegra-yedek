-- ============================================================================
--  1198 — AI rehberi ekran kataloğu: liste adları menüyle eşitlenir
--
--  Kullanıcı 28.10.2026: "Doktor Çalışma Listesi rename her yerde Doktor
--  Bekleme Listesi". Menü / sekme adı web liste tanımından gelir; AI rehberi
--  (ai_rehber_ekran - bağlamsal yardım ve "hangi ekran" önerisi) ise kendi
--  kopyasını tutar ve eski adlarda kalmıştı. Aynı günlerde yeniden adlandırılan
--  öteki listeler de (radyoloji istem, laboratuvar istemi, Medula faturası)
--  burada eşitlenir.
--
--  YALNIZ ESKİ DEĞERİ TAŞIYAN satır değişir: başlığı başka bir değere
--  çekilmiş kayıt (kurulumda elle düzenlenmiş) korunur. Tekrar çalışması
--  güvenli (ikinci çalışmada eşleşen satır kalmaz).
-- ============================================================================
begin;

create temporary table _ad (rota varchar(120), eski varchar(200),
                            baslik varchar(200), menu_ad varchar(200), yol varchar(300),
                            anahtar_ek varchar(200)) on commit drop;
insert into _ad values
    ('/hekim-listesi', 'Hekim Çalışma Listesi',
     'Doktor Bekleme Listesi', 'Doktor Bekleme Listesi', 'Muayene › Doktor Bekleme Listesi',
     'doktor bekleme listesi hekim çalışma listesi'),
    ('/radyoloji', 'Radyoloji Çalışma Listesi',
     'Radyoloji İstem Listesi', 'Radyoloji İstem Listesi', 'Radyoloji › Radyoloji İstem Listesi',
     'radyoloji istem listesi çalışma listesi'),
    ('/lab-istem', 'Laboratuvar İstemleri',
     'Laboratuvar İstemi Listesi', 'Laboratuvar İstemi Listesi', 'Laboratuvar › Laboratuvar İstemi Listesi',
     'laboratuvar istemi listesi'),
    ('/medula-fatura', 'Medula Faturaları',
     'Medula Faturası Listesi', 'Medula Faturası Listesi', 'Medula › Medula Faturası Listesi',
     'medula faturası listesi');

-- Önce rapor: ne değişecek.
select e.rota, e.baslik as eski_baslik, a.baslik as yeni_baslik
  from public.ai_rehber_ekran e join _ad a on a.rota = e.rota and e.baslik = a.eski;

update public.ai_rehber_ekran e
   set baslik  = a.baslik,
       menu_ad = a.menu_ad,
       yol     = a.yol,
       -- Eski adla soran kullanıcı da ekranı bulsun: eski ad anahtarda kalır.
       anahtar = trim(coalesce(e.anahtar, '') || ' ' || a.anahtar_ek)
  from _ad a
 where a.rota = e.rota and e.baslik = a.eski;

commit;
