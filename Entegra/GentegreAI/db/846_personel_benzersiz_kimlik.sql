-- ============================================================================
--  Gentegre AI — PERSONELDE SİCİL NO / KİMLİK NO / E-POSTA / TELEFON BENZERSİZ
--  846_personel_benzersiz_kimlik.sql
--
--  Kullanıcı: *"personelde de sicilno ve kimlikno kontrolü yap aynısı tekrar
--  girilemez"* + *"mail adresi ve telefon kontrolü de"*.
--
--  Kural VERİTABANINDA: aynı sicil iki kez ekrandan da, içeri aktarımdan da,
--  API'den de girilebiliyordu. Tek kapı olan yer tablo kısıtıdır; API hata
--  kodunu (23505) kullanıcıya okunur mesaja çeviriyor (VeriHatasi).
--
--  ============ KAPSAM: YALNIZ PERSONEL ===============================
--  `taraf` tablosu hasta/cari/kişi için de kullanılıyor. Kısıt bu yüzden
--  **kısmi**: `personel = 1` satırları. Hastada aynı telefon aile bireyleri
--  arasında paylaşılabiliyor, cari kodu ayrı bir düzen - onları bu betik
--  bağlamaz.
--
--  BOŞ DEĞER KISITA GİRMEZ: kimlik numarası olmayan (yabancı uyruklu, henüz
--  girilmemiş) personel birden çok olabilir - boş dizeyi tekrar saymak yeni
--  kaydı engellerdi.
--
--  TELEFON SON 10 HANESİYLE KARŞILAŞTIRILIR: "+90 500 998 16 76",
--  "0500 998 16 76" ve "500 998 16 76" aynı numaradır - yalnız rakamları
--  almak yetmiyordu, ülke kodu/baştaki sıfır iki kaydı farklı gösteriyordu
--  (tarayıcıda görüldü: mükerrer cep kabul edildi).
--
--  Uygulamadan önce mevcut veri tarandı: personelde hiçbir alanda mükerrer
--  yok (102 kayıt), yani kısıtlar veri düzeltmesi gerektirmiyor.
-- ============================================================================
\set ON_ERROR_STOP on

-- Mükerrer varsa betik BURADA durur ve hangi değerin çakıştığını söyler -
--   index yaratma hatası ("could not create unique index") hangi kaydın
--   sorunlu olduğunu göstermiyor.
do $$
declare r record; v_sayi integer := 0;
begin
    for r in
        select 'Sicil No' alan, kod deger, count(*) adet
          from public.taraf where personel = 1 and coalesce(kod, '') <> ''
         group by kod having count(*) > 1
        union all
        select 'Kimlik No', vkno, count(*)
          from public.taraf where personel = 1 and coalesce(vkno, '') <> ''
         group by vkno having count(*) > 1
        union all
        select 'E-posta', lower(eposta), count(*)
          from public.taraf where personel = 1 and coalesce(eposta, '') <> ''
         group by lower(eposta) having count(*) > 1
        union all
        select 'Cep', right(regexp_replace(cep_tel, '\D', '', 'g'), 10), count(*)
          from public.taraf where personel = 1
           and length(regexp_replace(coalesce(cep_tel, ''), '\D', '', 'g')) >= 10
         group by 2 having count(*) > 1
    loop
        raise warning 'MUKERRER %: "%" (% kayit)', r.alan, r.deger, r.adet;
        v_sayi := v_sayi + 1;
    end loop;
    if v_sayi > 0 then
        raise exception 'Personelde % mukerrer deger var - once onlari duzeltin.', v_sayi;
    end if;
end $$;

create unique index if not exists ux_taraf_personel_kod
    on public.taraf (kod)
 where personel = 1 and coalesce(kod, '') <> '';

create unique index if not exists ux_taraf_personel_vkno
    on public.taraf (vkno)
 where personel = 1 and coalesce(vkno, '') <> '';

-- E-POSTA BUYUK/KUCUK HARF AYIRMAZ: "Ali@x.com" ile "ali@x.com" ayni kutudur.
create unique index if not exists ux_taraf_personel_eposta
    on public.taraf (lower(eposta))
 where personel = 1 and coalesce(eposta, '') <> '';

-- SON 10 HANE: ulke kodu ve bastaki sifir biçim farkidir, numara degil.
--   10 haneden kisa girisler (eksik/hatali) kisita girmez - yoksa iki eksik
--   kayit birbirini engellerdi.
drop index if exists public.ux_taraf_personel_cep;
create unique index if not exists ux_taraf_personel_cep
    on public.taraf ((right(regexp_replace(cep_tel, '\D', '', 'g'), 10)))
 where personel = 1
   and length(regexp_replace(coalesce(cep_tel, ''), '\D', '', 'g')) >= 10;

do $$
begin
    raise notice '846 tamam: personelde sicil no / kimlik no / e-posta / cep '
                 'benzersiz (bos deger haric).';
end $$;
