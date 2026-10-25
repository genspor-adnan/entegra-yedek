-- =============================================================================
--  1174  STOK İCMALLERİ (2) - Stok Hareket, Ölü Stok / Devir Hızı, Kritik Stok
--        + icmal ekranlarının asistan kataloğu
--
--  Kullanıcı (25.10.2026): "3 mockup'ı da web'e uygula, bu icmallerde neler
--  yapıldığı bilgisini yerel (ekran) yapay zekaya bildir, kullanıcı bu ekranda
--  ne yapabilirim dediğinde ekrana gelsin; önceki diğer tüm icmaller için de".
--  Mockup'lar Ekranlar/Stok/stok_hareket_icmali.html, stok_olu_stok_icmali.html,
--  stok_kritik_stok_icmali.html. Uçlar StokIcmalUclari.Ek.cs.
--
--  1) Ekran kodları (1003 ilkesi: bir kod bir menü ekranı) - hakları stok.liste'den
--     kopyalanır (1173 ile aynı: Stok Listesi'ni gören rol bu icmalleri de görür;
--     kimse yetki kazanmaz / kaybetmez). Var olan rol_yetki satırına dokunulmaz.
--     Kritik Stok'taki iki yazan işlem ayrı yetki ister: talep `satinalma.talep`
--     Ekle, min / max `stok` Değiştir (stok kartıyla aynı).
--  2) Asistan ekran kataloğu: üç yeni ekran + Hasta İcmali (kart rotası
--     /hasta-icmal/:id - satırı yoktu, asistan "ekranı tanımadım" diyordu).
--     Ekranın "ne yapılır" metni dokuman/yardim/icmal-*.md belgelerindedir;
--     buradaki aciklama ekran araması içindir.
--  3) 1173'ün stok icmal satırlarında yol, menüdeki "İcmaller" alt başlığına
--     uydurulur (yalnız eski metin hâlâ duruyorsa).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

-- ------------------------------------------------------------ ekran kodları --
create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40))
  on commit drop;
insert into _bolme values
  ('stok.hareket_icmali',      'stok.liste', 'Stok Hareket İcmali (Stok & Hizmet)',          'Stok & Hizmet'),
  ('stok.olu_stok_icmali',     'stok.liste', 'Ölü Stok / Devir Hızı İcmali (Stok & Hizmet)', 'Stok & Hizmet'),
  ('stok.kritik_stok_icmali',  'stok.liste', 'Kritik Stok İcmali (Stok & Hizmet)',           'Stok & Hizmet');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1174: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, 0, 0, 0, ry.deger, ry.kapsam, 0
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
select v.kaynak, v.rota, v.baslik, v.yol, v.grup, v.baslik, v.yetki_kodu, v.urun_modu, v.anahtar, v.aciklama, ''
  from (values
    ('stok-hareket-icmali', '/stok-hareket-icmali', 'Stok Hareket İcmali',
     'Stok & Hizmet › İcmaller › Stok Hareket İcmali', 'Stok & Hizmet', 'stok.hareket_icmali', 0::smallint,
     'stok hareket icmal devir giriş çıkış kalan dönem transfer depo akışı ekstre yürüyen bakiye sayım fazlası eksiği',
     'Dönem başı devir, hareket türüne göre giriş / çıkış (alış, satış, iade, sarf, sayım fişi), dönem sonu kalan; '
     || 'hafta / ay × tür tablosu, depo akışı ve transfer tablosu, tek stokun yürüyen bakiyeli ekstresi.'),
    ('stok-olu-stok-icmali', '/stok-olu-stok-icmali', 'Ölü Stok / Devir Hızı İcmali',
     'Stok & Hizmet › İcmaller › Ölü Stok / Devir Hızı İcmali', 'Stok & Hizmet', 'stok.olu_stok_icmali', 0::smallint,
     'ölü stok hareketsiz devir hızı stokta kalma abc pareto yavaş dönen tasfiye iade transfer kampanya',
     'Eşikten (90 / 180 / 365 gün) uzun süre çıkış görmemiş bakiyeli kalemler ve eritme önerileri (SKT, transfer, '
     || 'tedarikçiye iade, kampanya); devir hızı, ABC × hız tablosu, ay sonlarında ölü stok gelişimi.'),
    ('stok-kritik-stok-icmali', '/stok-kritik-stok-icmali', 'Kritik Stok İcmali',
     'Stok & Hizmet › İcmaller › Kritik Stok İcmali', 'Stok & Hizmet', 'stok.kritik_stok_icmali', 0::smallint,
     'kritik stok asgari minimum maksimum sipariş satınalma talebi tükenme yolda tedarik süresi emniyet stoğu',
     'Depo bazında asgari seviyenin altına düşen, stokta olmayan ve tedarik süresinden önce bitecek kalemler; '
     || 'yolda olan (açık talep / sipariş), önerilen sipariş, seçilenlerden satınalma talebi, tüketimden min / max önerisi, max üstü fazla.'),
    ('hasta-icmal', '/hasta-icmal', 'Hasta İcmali',
     'Kayıt Kabul › Hasta › Hesap İcmali', 'Kayıt Kabul', 'hasta', 2::smallint,
     'hasta icmal hesap özeti borç tahsilat hizmet kurum payı hasta payı',
     'Bir hastanın bütün başvurularındaki hizmet, kurum / hasta payı, tahsilat ve kalan borç özeti.'))
    as v(kaynak, rota, baslik, yol, grup, yetki_kodu, urun_modu, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

update public.ai_rehber_ekran e
   set yol = 'Stok & Hizmet › İcmaller › ' || e.baslik
 where e.kaynak in ('stok-deger-icmali', 'stok-skt-icmali', 'stok-sayim-fark-icmali')
   and e.yol = 'Stok & Hizmet › ' || e.baslik;

commit;
