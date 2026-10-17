-- =============================================================================
--  1131  LİSTE / KART AYRIMI - GRUP 2: ORTAK KODLU LİSTELER
--
--  Kullanıcı (17.10.2026): "dışarıda kalanları grup grup yap". Bir kodu birden çok ekran paylaşıyor:
--    * liste + ayrı "(kart)" ekranı (FTR Tedavi Programı, İSG Çalışan, Çağrı Kaydı, Steril Döngü):
--      liste ekranı <kod>.liste, "(kart)" ekranı kartın kodunda kalır;
--    * aynı kodda birden çok liste (Kampanya, Fiyat Listeleri, İç Denetim, Kalite Hedefleri,
--      Toplantı & Kararlar, Eğitim): kodun BÜTÜN liste ekranları ortak <kod>.liste'ye geçer.
--  kys.ayar (Kalite › Ayarlar) bir ayar sayfası, liste / kart değil - dışarıda.
--  Adımlar 1128 ile aynı. İdempotent.
-- =============================================================================

begin;

create temp table _lk (liste varchar(60), kart varchar(60), liste_ad varchar(120),
                       eski_kart_ad varchar(120), kart_ad varchar(120),
                       rehber_kaynak varchar(60), rehber_rota varchar(80)) on commit drop;

insert into _lk values
  ('ftr.program.liste', 'ftr.program', 'Tedavi Programı Listesi',
     'Tedavi programı (kür)', 'Tedavi Programı Kartı', null, null),
  ('isg.calisan.liste', 'isg.calisan', 'Çalışan Listesi',
     'Çalışanlar', 'Çalışan Kartı', null, null),
  ('cagri.kayit.liste', 'cagri.kayit', 'Çağrı Kaydı Listesi',
     'Çağrı kayıtları (konu, sonuç, not)', 'Çağrı Kartı', null, null),
  ('cagri.kampanya.liste', 'cagri.kampanya', 'Kampanya Listesi',
     'Kampanyalar (hatırlatma, anket, tahsilat)', 'Kampanya Kartı', null, null),
  ('steril.dongu.liste', 'steril.dongu', 'Döngü Listesi',
     'Döngü kayıtları ve serbest bırakma', 'Döngü Kartı', null, null),
  ('kys.denetim.liste', 'kys.denetim', 'İç Denetim Listesi',
     'İç denetim', 'İç Denetim Kartı', null, null),
  ('kys.gosterge.liste', 'kys.gosterge', 'Politika & Hedefler (Liste)',
     'Hedefler ve göstergeler', 'Kalite Politikası & Hedef Kartı', null, null),
  ('kys.toplanti.liste', 'kys.toplanti', 'Toplantı & Kararlar (Liste)',
     'YGG ve komite toplantıları', 'Toplantı & Karar Kartı', null, null),
  ('kys.egitim.liste', 'kys.egitim', 'Eğitim (Liste)',
     'Eğitim ve yetkinlik kayıtları', 'Eğitim & Yetkinlik Kaydı Kartı', null, null),
  ('fiyat_listesi.liste', 'fiyat_listesi', 'Fiyat Listeleri',
     'Fiyat listesi', 'Fiyat Listesi Kartı', null, null);

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

-- 4) Yardım kataloğu: kodun BÜTÜN liste ekranları (kart ekranları kartta kalır).
update public.ai_rehber_ekran r
   set yetki_kodu = r.yetki_kodu || '.liste'
 where false
   or (r.kaynak = 'ftr-program' and r.rota = '/ftr-program' and r.yetki_kodu = 'ftr.program')
   or (r.kaynak = 'isg-calisan' and r.rota = '/isg-calisan' and r.yetki_kodu = 'isg.calisan')
   or (r.kaynak = 'cagri' and r.rota = '/cagri' and r.yetki_kodu = 'cagri.kayit')
   or (r.kaynak = 'cagri-kampanya' and r.rota = '/cagri-kampanya' and r.yetki_kodu = 'cagri.kampanya')
   or (r.kaynak = 'cagri-kampanya-kisi' and r.rota = '/cagri-kampanya-kisi' and r.yetki_kodu = 'cagri.kampanya')
   or (r.kaynak = 'steril-dongu' and r.rota = '/steril-dongu' and r.yetki_kodu = 'steril.dongu')
   or (r.kaynak = 'kys-denetim' and r.rota = '/kys-denetim' and r.yetki_kodu = 'kys.denetim')
   or (r.kaynak = 'kys-denetim-bulgu' and r.rota = '/kys-denetim-bulgu' and r.yetki_kodu = 'kys.denetim')
   or (r.kaynak = 'kys-hedefler' and r.rota = '/kys-hedefler' and r.yetki_kodu = 'kys.gosterge')
   or (r.kaynak = 'kys-gosterge' and r.rota = '/kys-gosterge' and r.yetki_kodu = 'kys.gosterge')
   or (r.kaynak = 'kys-toplantilar' and r.rota = '/kys-toplantilar' and r.yetki_kodu = 'kys.toplanti')
   or (r.kaynak = 'kys-toplanti' and r.rota = '/kys-toplanti' and r.yetki_kodu = 'kys.toplanti')
   or (r.kaynak = 'kys-karar' and r.rota = '/kys-karar' and r.yetki_kodu = 'kys.toplanti')
   or (r.kaynak = 'kys-egitimler' and r.rota = '/kys-egitimler' and r.yetki_kodu = 'kys.egitim')
   or (r.kaynak = 'kys-egitim' and r.rota = '/kys-egitim' and r.yetki_kodu = 'kys.egitim')
   or (r.kaynak = 'kys-egitim-eksik' and r.rota = '/kys-egitim-eksik' and r.yetki_kodu = 'kys.egitim')
   or (r.kaynak = 'kys-zorunlu-egitim' and r.rota = '/kys-zorunlu-egitim' and r.yetki_kodu = 'kys.egitim')
   or (r.kaynak = 'fiyat-listesi' and r.rota = '/fiyat-listesi' and r.yetki_kodu = 'fiyat_listesi')
   or (r.kaynak = 'fiyat-listesi-satir' and r.rota = '/fiyat-listesi-satir' and r.yetki_kodu = 'fiyat_listesi');

-- Yetki önbelleği: liste satırı alan rollerin sürümü artar.
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _lk l on l.liste = y.kod
                where ry.rol_id = r.id and ry.ekleme_tarihi = now());   -- yalnız bu çalıştırmada eklenenler

commit;
