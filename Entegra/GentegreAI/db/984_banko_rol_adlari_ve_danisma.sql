-- =====================================================================
-- 984 - BANKO dili: rol adlari + yeni "Danisma" rolu
--
-- Kullanici 08.10.2026:
--   * "rollerde Kayit Kabul rename Banko Gorevlisi"
--   * "Roller'e Danisma ekle"
--   * "vezne yerine Banko kullan"
--
-- KODLAR DEGISMEZ (kayit_kabul, kayit_kabul_sorumlu, vezne): yetki
--   eslemeleri, kurum tipi gecerlilik haritasi (829), kadro agaci ve
--   personel gecmisi koda bagli - yalniz goruenen AD degisir.
--
-- Idempotent: ad guncellemeleri kosullu, rol/yetki eklemeleri
--   "where not exists". Musteri kendi adini yazdiysa KORUNUR (update
--   yalniz ESKI standart addan yenisine ceviriyor, blanket degil).
-- =====================================================================

-- ---------------------------------------------------------------- adlar
update public.rol set ad = 'Banko Görevlisi', degistirme_tarihi = now()
 where kod = 'kayit_kabul' and ad = 'Kayıt Kabul / Banko';

update public.rol set ad = 'Banko Sorumlusu', degistirme_tarihi = now()
 where kod = 'kayit_kabul_sorumlu' and ad = 'Kayıt Kabul Sorumlusu (Banko Şefi)';

update public.rol
   set ad = 'Banko Kasiyeri',
       amac = 'Tahsilat, makbuz, fatura kapatma; hasta kaydı açmaz.',
       degistirme_tarihi = now()
 where kod = 'vezne' and ad = 'Vezne';

-- ------------------------------------------------------- Danisma rolu
-- Karsilama bankosu: hastayi YONLENDIRIR, islem yapmaz. Para ve klinik
--   yetkisi yok; hasta/randevu SALT OKUMA - kayit acmak bankonun isi.
insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen, portal_turu)
select 'danisma', 'Danışma',
       'Karşılama ve yönlendirme: hasta/randevu sorgulama, hekim ve bölüm bilgisi; işlem ve tahsilat yok.',
       1, 1, 0, 0
 where not exists (select 1 from public.rol where kod = 'danisma');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 0, 0, 0, 0
  from public.rol r
  join public.yetki y
    on y.kod in ('hasta', 'randevu', 'belge', 'taraf', 'personel',
                 'kurum', 'hizmet', 'bildirim')
 where r.kod = 'danisma'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- Rol butun aktif subelerde gecerli (kur ucunun yaptiginin ayni).
insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
select r.id, s.id, s.varsayilan, 1, 0
  from public.rol r
  cross join public.sube s
 where r.kod = 'danisma' and s.aktif = 1
   and not exists (select 1 from public.rol_sube rs
                    where rs.rol_id = r.id and rs.sube_id = s.id);

update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'danisma';

do $$
declare n int;
begin
  select count(*) into n from public.rol_yetki ry
    join public.rol r on r.id = ry.rol_id where r.kod = 'danisma';
  raise notice '984: Banko rol adlari guncellendi; Danisma rolu % yetki ile hazir', n;
end $$;
