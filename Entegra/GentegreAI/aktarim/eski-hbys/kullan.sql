-- ============================================================================================
--  KULLAN → KURUM PERSONELİ (15.11.2026, kullanıcı: "KULLAN tablosundaki kullanıcıların personel olarak
--  aktarılmış olması gerekirdi.. personeli boşalt, KULLAN'dan yeniden aktar").
--
--  Önce: al.ps1 -Tablolar KULLAN  (eski.kullan; parola kolonları kopyalanmaz)
--  Sonra: docker exec -i gentegre-pg18 psql -U postgres -d KOSUYOLU -v ON_ERROR_STOP=1 -f - < kullan.sql
--
--  Ne yapar:
--   1) DOKTOR = KURUM İÇİ HEKİM, PERSONEL KALIR (kullanıcı 15.11.2026: "DOKTORLAR → dış doktor; KULLAN + DOKTOR →
--      personel"). DOKTOR.KULLANID ile bir KULLAN kullanıcısına bağlı hekimler (radyologlar) KULLAN kaydıyla
--      BİRLEŞTİRİLİR (tek personel kartı: hekim = 1, branş / diploma DOKTOR'dan; DOKTOR kaynaklı kopya silinir).
--      Bağsız hekimler DOKTOR kaynaklı kart olarak kalır; ad / soyad standart biçime, "Dr." öneki unvana alınır.
--      İlk sürümün (15.11.2026 sabah) sildiği DOKTOR kayıtları eski.yedek_taraf_doktor_20261115'ten geri yüklenir.
--      Dış hekimler (DOKTORLAR / GELISLER.DOKTOR, dis_hekim = 1) ve elle açılan kayıtlar (admin vb.) DOKUNULMAZ.
--   2) TEMSİLCİLER: ziyaret.sql'in KULLAN kodlarından açtığı TEM-ED / RC / BH / H8 / BG satırları (kullanıcı hesabı ve
--      ziyaret referansları taşır) silinmez; KULLAN satırına bağlanır (kod = KULLANICI, aktarim_id = KULLAN.ID), boş
--      alanları KULLAN'dan dolar.
--   3) KALAN KULLAN satırları kurum personeli olarak açılır: kod = KULLANICI, ad / soyad = KULLANICIADI (son kelime
--      soyad), pasif → durum 0, görev = GRUP, cep / e-posta / TCKN yalnız geçerli ve tekilse. Sistem kullanıcıları
--      (AKTARIM GX, GENOTIP GT) açılmaz. Kullanıcı HESABI açılmaz - yalnız personel kartı.
--  Tekrar çalıştırılabilir (ux_taraf_aktarim: KULLAN + id tekil).
-- ============================================================================================
\set ON_ERROR_STOP on
begin;

-- ---------------------------------------------------------------- 0. yardımcılar --
create temp table zz_k as
select k.id, btrim(k.kullanici) as kod, btrim(k.kullaniciadi) as tam_ad,
       case when btrim(k.kullaniciadi) ~ ' ' then left(regexp_replace(btrim(k.kullaniciadi), '\s+[^\s]+$', ''), 100)
            else left(btrim(k.kullaniciadi), 100) end as ad,
       case when btrim(k.kullaniciadi) ~ ' ' then left(substring(btrim(k.kullaniciadi) from '([^\s]+)$'), 60) else '' end as soyad,
       case when coalesce(k.pasif, 0) = 1 then 0 else 1 end as durum,
       left(coalesce(btrim(k.grup), ''), 60) as gorev,
       case when coalesce(k.vatandaslikno, '') ~ '^[1-9][0-9]{10}$' then k.vatandaslikno else '' end as vkno,
       case when length(regexp_replace(coalesce(k.ceptel, ''), '\D', '', 'g')) >= 10 then left(btrim(k.ceptel), 30) else '' end as cep,
       case when coalesce(k.eposta, '') ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then left(lower(btrim(k.eposta)), 100) else '' end as eposta,
       case when k.dahili is not null then k.dahili::text else '' end as dahili
  from eski.kullan k
 where coalesce(btrim(k.kullanici), '') <> '' and coalesce(btrim(k.kullaniciadi), '') <> ''
   and upper(btrim(k.kullanici)) not in ('GX', 'GT')                       -- AKTARIM / GENOTIP sistem kullanıcıları
   and upper(btrim(k.kullaniciadi)) not in ('AKTARIM', 'GENOTIP');

-- Tekil alanlar: aynı cep / e-posta / TCKN ikinci kişide boş kalır (ux_taraf_personel_*).
update zz_k z set cep = '' where cep <> '' and id <> (select min(id) from zz_k x where right(regexp_replace(x.cep, '\D', '', 'g'), 10) = right(regexp_replace(z.cep, '\D', '', 'g'), 10));
update zz_k z set eposta = '' where eposta <> '' and id <> (select min(id) from zz_k x where x.eposta = z.eposta);
update zz_k z set vkno = '' where vkno <> '' and id <> (select min(id) from zz_k x where x.vkno = z.vkno);

-- ---------------------------------------------------------------- 1. DOKTOR = kurum içi hekim --
-- 1a) İlk sürümün sildiği kayıtların geri yüklenmesi (yalnız yedek tablosu olan DB'de; tekrar çalışmada boş).
do $$
begin
  if to_regclass('eski.yedek_taraf_doktor_20261115') is not null then
    insert into public.taraf select y.* from eski.yedek_taraf_doktor_20261115 y
     where not exists (select 1 from public.taraf t where t.id = y.id)
       and not exists (select 1 from public.taraf t where t.personel = 1 and t.kod = y.kod and t.id <> y.id);
    -- kod çakışan (ör. AA: Admin KULLAN'da) geri yüklenen hekim '-DR' ekiyle
    insert into public.taraf (id, kod, unvan, ad, soyad, vkno, cep_tel, eposta, durum, sube_id, personel, hekim,
                              aktarim_kaynak, aktarim_tablo, aktarim_id)
    select y.id, left(y.kod || '-DR', 30), y.unvan, y.ad, y.soyad, y.vkno, y.cep_tel, y.eposta, y.durum, y.sube_id, 1, 1,
           y.aktarim_kaynak, y.aktarim_tablo, y.aktarim_id
      from eski.yedek_taraf_doktor_20261115 y
     where not exists (select 1 from public.taraf t where t.id = y.id);
    insert into public.taraf_personel select y.* from eski.yedek_taraf_personel_doktor_20261115 y
     where not exists (select 1 from public.taraf_personel p where p.id = y.id)
       and exists (select 1 from public.taraf t where t.id = y.id);
    -- ilk sürümün pasife çekip '-ESKI' eklediği referanslı kayıt
    update public.taraf t set kod = replace(t.kod, '-ESKI', ''), durum = coalesce(y.durum, 1)
      from eski.yedek_taraf_doktor_20261115 y
     where y.id = t.id and t.kod like '%-ESKI'
       and not exists (select 1 from public.taraf x where x.personel = 1 and x.kod = replace(t.kod, '-ESKI', '') and x.id <> t.id);
    update public.taraf t set kod = left(replace(t.kod, '-ESKI', '') || '-DR', 30), durum = coalesce(y.durum, 1)
      from eski.yedek_taraf_doktor_20261115 y
     where y.id = t.id and t.kod like '%-ESKI';
  end if;
end $$;

-- 1b) KULLAN'a bağlı hekim (DOKTOR.KULLANID): KULLAN kaydı hekim olur; branş / diploma DOKTOR'dan; DOKTOR kopyası
--     silinir (referansları KULLAN kaydına taşınarak). KULLAN kaydı daha sonra (3.) açılıyorsa burada yalnız
--     hazırlık tablosu kurulur, birleştirme 3c'de yapılır.
create temp table zz_dr_bag as
select d.id as doktor_id, d.kullanid as kullan_id, left(coalesce(d.diploma, ''), 30) as diploma,
       coalesce((select kd.deger::text from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                  where kl.kod = 'hekim.brans' and public.fn_ara_metin(kd.ad) = public.fn_ara_metin(d.uzmanlik) limit 1), '') as brans,
       d.uzmanlik
  from eski.doktor d
 where d.kullanid is not null and exists (select 1 from zz_k z where z.id = d.kullanid);

-- 1c) Bağsız DOKTOR hekimleri: "Dr." öneki unvana, ad / soyad ayrımı + standart biçim (bir kez; tekrar çalışmada değişmez).
update public.taraf t
   set unvan = case when t.ad ~ '^[Dd][Rr]\.?\s*' then 'Dr.' else t.unvan end,
       ad = initcap(lower(case when regexp_replace(t.ad, '^[Dd][Rr]\.?\s*', '') ~ ' '
                                then regexp_replace(regexp_replace(t.ad, '^[Dd][Rr]\.?\s*', ''), '\s+[^\s]+$', '')
                                else regexp_replace(t.ad, '^[Dd][Rr]\.?\s*', '') end)),
       soyad = initcap(lower(case when regexp_replace(t.ad, '^[Dd][Rr]\.?\s*', '') ~ ' '
                                   then substring(regexp_replace(t.ad, '^[Dd][Rr]\.?\s*', '') from '([^\s]+)$') else '' end))
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTOR' and t.personel = 1
   and coalesce(t.soyad, '') = '' and t.ad ~ ' ';
-- esle.sql unvana tam adı yazmıştı; personelde unvan yalnız önektir (Dr., Uzm.Dr., Prof.Dr. ...).
update public.taraf t set unvan = ''
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTOR' and t.personel = 1
   and coalesce(t.unvan, '') <> '' and t.unvan !~ '^(Dr|Uzm|Prof|Doç|Op|Dt|Yrd)\.';

-- ---------------------------------------------------------------- 1d. kod çakışması --
-- KULLAN kodu (ör. BG, AA) DOKTOR kaynaklı bir hekimde de varsa hekimin kodu '-DR' ekini alır: KULLAN kaydı düz kodla
--   kalır (yerelde 1a bunu geri yüklemede yapıyordu; sunucuda DOKTOR satırları silinmediği için burada gerekir).
update public.taraf t set kod = left(t.kod || '-DR', 30)
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTOR' and t.personel = 1
   and exists (select 1 from zz_k z where z.kod = t.kod)
   and not exists (select 1 from public.taraf x where x.personel = 1 and x.kod = left(t.kod || '-DR', 30));

-- ---------------------------------------------------------------- 2. temsilciler (TEM-*) --
update public.taraf t
   set kod = z.kod, aktarim_id = z.id,
       ad = case when coalesce(t.ad, '') = '' then z.ad else t.ad end,
       soyad = case when coalesce(t.soyad, '') = '' then z.soyad else t.soyad end,
       cep_tel = case when coalesce(t.cep_tel, '') = '' and z.cep <> '' then z.cep else t.cep_tel end,
       eposta = case when coalesce(t.eposta, '') = '' and z.eposta <> '' then z.eposta else t.eposta end,
       vkno = case when coalesce(t.vkno, '') = '' and z.vkno <> '' then z.vkno else t.vkno end,
       telefon = case when coalesce(t.telefon, '') = '' then z.dahili else t.telefon end
  from zz_k z
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.kod = 'TEM-' || z.kod;
update public.taraf_personel p set aktarim_id = t.aktarim_id, gorev = case when coalesce(p.gorev, '') = '' then z.gorev else p.gorev end
  from public.taraf t join zz_k z on z.id = t.aktarim_id
 where p.id = t.id and t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN';

-- ---------------------------------------------------------------- 3. kalan KULLAN satırları --
-- Kod çakışması (başka kaynaktan aynı kodlu aktif personel): KULLAN kodu '-K' ekiyle açılır.
insert into public.taraf (kod, unvan, ad, soyad, personel, durum, sube_id, vkno, cep_tel, eposta, telefon,
                          aktarim_kaynak, aktarim_tablo, aktarim_id)
select case when exists (select 1 from public.taraf x where x.personel = 1 and x.kod = z.kod) then left(z.kod || '-K', 30) else z.kod end,
       '', z.ad, z.soyad, 1, z.durum, 1,
       case when exists (select 1 from public.taraf x where x.personel = 1 and x.vkno = z.vkno) then '' else z.vkno end,
       case when z.cep <> '' and exists (select 1 from public.taraf x where x.personel = 1
                 and right(regexp_replace(coalesce(x.cep_tel, ''), '\D', '', 'g'), 10) = right(regexp_replace(z.cep, '\D', '', 'g'), 10)) then '' else z.cep end,
       case when z.eposta <> '' and exists (select 1 from public.taraf x where x.personel = 1 and lower(x.eposta) = z.eposta) then '' else z.eposta end,
       z.dahili, 2, 'KULLAN', z.id
  from zz_k z
 where not exists (select 1 from public.taraf t where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.aktarim_id = z.id);

insert into public.taraf_personel (id, sube_id, dis_hekim, gorev, aktarim_kaynak, aktarim_tablo, aktarim_id)
select t.id, 1, 0, z.gorev, 2, 'KULLAN', z.id
  from public.taraf t join zz_k z on z.id = t.aktarim_id
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN'
   and not exists (select 1 from public.taraf_personel p where p.id = t.id);

-- 3c) KULLAN'a bağlı hekimlerin birleştirilmesi: KULLAN kaydı hekim = 1 + branş / diploma; DOKTOR kopyası
--     (varsa) referanslarıyla birlikte KULLAN kaydına taşınıp silinir.
update public.taraf t set hekim = 1
  from zz_dr_bag b where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.aktarim_id = b.kullan_id and coalesce(t.hekim, 0) <> 1;
update public.taraf_personel p
   set brans = case when coalesce(p.brans, '') = '' then b.brans else p.brans end,
       tescil_no = case when coalesce(p.tescil_no, '') = '' then b.diploma else p.tescil_no end
  from public.taraf t join zz_dr_bag b on b.kullan_id = t.aktarim_id
 where p.id = t.id and t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN';
create temp table zz_dr_kopya as
select dk.id as eski_id, kk.id as yeni_id
  from zz_dr_bag b
  join public.taraf dk on dk.aktarim_kaynak = 2 and dk.aktarim_tablo = 'DOKTOR' and dk.aktarim_id = b.doktor_id
  join public.taraf kk on kk.aktarim_kaynak = 2 and kk.aktarim_tablo = 'KULLAN' and kk.aktarim_id = b.kullan_id;
update public.belge_basvuru b set personel_id = m.yeni_id from zz_dr_kopya m where b.personel_id = m.eski_id;
update public.radyoloji_rapor r set yazan_id = m.yeni_id from zz_dr_kopya m where r.yazan_id = m.eski_id;
update public.radyoloji_rapor r set onaylayan_id = m.yeni_id from zz_dr_kopya m where r.onaylayan_id = m.eski_id;
update public.radyoloji_rapor r set onaylayacak_id = m.yeni_id from zz_dr_kopya m where r.onaylayacak_id = m.eski_id;
update public.radyoloji_istem i set istek_hekim_id = m.yeni_id from zz_dr_kopya m where i.istek_hekim_id = m.eski_id;
delete from public.personel_hareket where taraf_id in (select eski_id from zz_dr_kopya);
delete from public.taraf_personel  where id in (select eski_id from zz_dr_kopya);
delete from public.taraf           where id in (select eski_id from zz_dr_kopya);

-- ---------------------------------------------------------------- 3b. ad / soyad standart biçim --
-- Kullanıcı 15.11.2026: "ad soyadları standart biçime çevir". Kaynakta BÜYÜK / karışık ("AYŞE NUR SAYI", "Esra Deniz
--   KUŞÇU"); DB ICU tr-TR olduğundan lower / initcap Türkçe İ-ı doğru çalışır (ışık → Işık, İLKER → İlker).
update public.taraf t
   set ad = initcap(lower(btrim(t.ad))), soyad = initcap(lower(btrim(coalesce(t.soyad, ''))))
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.personel = 1
   and (t.ad <> initcap(lower(btrim(t.ad))) or coalesce(t.soyad, '') <> initcap(lower(btrim(coalesce(t.soyad, '')))));
-- Türkçe olmayan sabit adlar: ADMIN → "Admın" olmasın.
update public.taraf set ad = 'Admin' where aktarim_kaynak = 2 and aktarim_tablo = 'KULLAN' and ad = 'Admın';

-- ---------------------------------------------------------------- 4. rapor --
select 'KULLAN kaynak: ' || (select count(*) from zz_k) || ' kişi (sistem kullanıcıları hariç)' as rapor
union all select 'kurum personeli (dis_hekim 0, aktif): ' || count(*) from public.taraf t join public.taraf_personel p on p.id = t.id
  where t.personel = 1 and coalesce(p.dis_hekim, 0) = 0 and t.durum = 1
union all select 'KULLAN kaynaklı personel: ' || count(*) || ' (pasif ' || count(*) filter (where durum = 0) || ')' from public.taraf where aktarim_kaynak = 2 and aktarim_tablo = 'KULLAN'
union all select 'DOKTOR kaynaklı kurum hekimi: ' || count(*) || ' (hekim kartı; KULLAN''a bağlı olanlar birleştirildi)' from public.taraf where aktarim_kaynak = 2 and aktarim_tablo = 'DOKTOR'
union all select 'KULLAN kaydıyla birleştirilen hekim: ' || count(*) from zz_dr_bag;

commit;
