-- =============================================================================
--  1128  LİSTE / KART YETKİ AYRIMI - PİLOT: RANDEVU + RADYOLOJİ
--
--  Kullanıcı (17.10.2026): "deseni diğer liste/kart özelliği olan menülere uygula" -> "önce pilot
--  grup". 1126'da Kayıt Kabul için kurulan desen:
--    <kod>.liste  menüdeki LİSTE ekranı   - yalnız GÖR (sunucu EkranKodlari.YalnizGorListe)
--    <kod>        o ekranın KARTI          - Gör / Ekle / Değiştir / Sil
--
--  Bu göç kartını kendi koduyla açan 12 listeye liste kodu açar:
--    1) yetki satırı (grup / sıra / ürün modu / modül kartın satırından),
--    2) kartta GÖR'ü olan her role listede GÖR (kimse menü kaybetmez; işlem hakları zaten kartta),
--    3) kart kodunun adı "... Kartı" olur (matriste listenin yanında bu adla durur),
--    4) yardım kataloğunda listenin kendi satırı liste koduna geçer.
--  Menü düzeni ekranları KAYNAK adıyla tutuyor (randevu, radyoloji-istem...): kurumun gizlediği
--  ekranlar etkilenmez. İdempotent.
-- =============================================================================

begin;

create temp table _lk (liste varchar(60), kart varchar(60), liste_ad varchar(120),
                       eski_kart_ad varchar(120), kart_ad varchar(120),
                       rehber_kaynak varchar(60), rehber_rota varchar(80)) on commit drop;

insert into _lk values
  ('randevu.liste',                'randevu',                'Randevu Listesi',
     'Randevular',                       'Randevu Kartı',                'randevu',          '/randevu'),
  ('randevu.plan.sablon.liste',    'randevu.plan.sablon',    'Çalışma Şablonları (Liste)',
     'Çalışma Şablonları (Randevu)',     'Çalışma Şablonu Kartı',        null, null),
  ('randevu.plan.istisna.liste',   'randevu.plan.istisna',   'Çalışma İstisnaları (Liste)',
     'Çalışma İstisnaları (Randevu)',    'Çalışma İstisnası Kartı',      null, null),
  ('radyoloji-istem.liste',        'radyoloji-istem',        'Radyoloji Çalışma Listesi',
     'Radyoloji İstem',                  'Radyoloji İstem Kartı',        null, null),
  ('radyoloji.sablon.liste',       'radyoloji.sablon',       'Rapor Şablonu Listesi',
     'Rapor Şablonları (Radyoloji)',     'Rapor Şablonu Kartı',          null, null),
  ('radyoloji.protokol.liste',     'radyoloji.protokol',     'Çekim Protokolü Listesi',
     'Çekim Protokolleri (Radyoloji)',   'Çekim Protokolü Kartı',        null, null),
  ('radyoloji.cihaz.liste',        'radyoloji.cihaz',        'Cihaz Listesi (Radyoloji)',
     'Cihazlar (Radyoloji)',             'Cihaz Kartı (Radyoloji)',      null, null),
  ('teleradyoloji.liste',          'teleradyoloji',          'Teleradyoloji Listesi',
     'Teleradyoloji çalışma listesi',    'Teleradyoloji İstek Kartı',    'telerad-istek',    '/teleradyoloji'),
  ('teleradyoloji.kurum.liste',    'teleradyoloji.kurum',    'Telerad Kurumu Listesi',
     'Teleradyoloji kurumları',          'Telerad Kurumu Kartı',         'telerad-kurum',    '/telerad-kurum'),
  ('teleradyoloji.nobet.liste',    'teleradyoloji.nobet',    'Nöbet Çizelgesi (Liste)',
     'Teleradyoloji nöbet çizelgesi',    'Nöbet Kartı (Teleradyoloji)',  'telerad-nobet',    '/telerad-nobet'),
  ('teleradyoloji.kural.liste',    'teleradyoloji.kural',    'Atama Kuralı Listesi',
     'Teleradyoloji atama kuralları',    'Atama Kuralı Kartı',           'telerad-kural',    '/telerad-kural'),
  ('teleradyoloji.sozlesme.liste', 'teleradyoloji.sozlesme', 'Telerad Sözleşmesi Listesi',
     'Teleradyoloji sözleşmeleri',       'Telerad Sözleşmesi Kartı',     'telerad-sozlesme', '/telerad-sozlesme');

-- Kart kodu kurulumda yoksa (modülü hiç kurulmamış) o satır atlanır - liste kodu da açılmaz.

-- 1) Liste yetkisi.
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select l.liste, l.liste_ad, k.grup, 0, k.sira, k.urun_modu, k.modul
  from _lk l
  join public.yetki k on k.kod = l.kart
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

-- 2) Kartı GÖREN her rol listeyi de görür (yalnız Gör).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yl.id, 1, 0, 0, 0, '', ry.kapsam, 0
  from _lk l
  join public.yetki yk     on yk.kod = l.kart
  join public.yetki yl     on yl.kod = l.liste
  join public.rol_yetki ry on ry.yetki_id = yk.id and ry.gor = 1
on conflict (rol_id, yetki_id) do nothing;

-- 3) Kart adı (kurum elle değiştirmişse dokunulmaz).
update public.yetki y
   set ad = l.kart_ad
  from _lk l
 where y.kod = l.kart and y.ad = l.eski_kart_ad;

-- 4) Yardım kataloğu: listenin kendi satırı liste koduna.
update public.ai_rehber_ekran r
   set yetki_kodu = l.liste
  from _lk l
 where l.rehber_kaynak is not null
   and r.kaynak = l.rehber_kaynak and r.rota = l.rehber_rota and r.yetki_kodu = l.kart;

-- Yetki önbelleği: liste satırı alan rollerin sürümü artar.
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _lk l on l.liste = y.kod
                where ry.rol_id = r.id and ry.ekleme_tarihi = now());   -- yalnız bu çalıştırmada eklenenler

commit;
