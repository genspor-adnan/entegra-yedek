-- 311: KABUL SONRASI secenekleri (mockup radyoloji_kayit_kabul.html sag alt
-- kutusu: "Cihaz listesine gönder / Randevu SMS'i / Hazırlık talimatı / CD").
--
-- Kullanici: "kabul sonrası kutusunu da ekle".
--
-- NEDEN KAYIT: MWL (cihaz calisma listesi) ve SMS entegrasyonlari HENUZ YOK.
-- Secimi ekranda gosterip kaydetmemek, kabul masasinin "SMS istedim" dedigi
-- isin izini birakmaz; entegrasyon geldiginde de gecmise donup kimin ne
-- istedigi bilinemez. Bayraklar ISTEK'tir (niyet) - gerceklesme durumu
-- entegrasyon eklendiginde ayri kolonlarla (gonderim zamani, sonuc) tutulur.
--
-- Varsayilanlar mockup'takiyle ayni: MWL / SMS / hazirlik ISARETLI, CD degil.

alter table public.radyoloji_istem
  -- Cihazin DICOM calisma listesine dusecek mi (teknisyen hastayi elle yazmasin).
  add column if not exists mwl_istendi      smallint not null default 1,
  -- Randevu / hazirlik SMS'i istendi mi.
  add column if not exists sms_istendi      smallint not null default 1,
  -- Hazirlik talimati hastaya VERILDI mi (ac gelme, metal cikarma...).
  add column if not exists hazirlik_verildi smallint not null default 1,
  -- Sonuc CD'si hazirlanacak mi (film/CD teslimi 304 ile ayni is).
  add column if not exists cd_istendi       smallint not null default 0;

comment on column public.radyoloji_istem.mwl_istendi is
  'Kabul sonrasi (311): cihaz calisma listesine (MWL) gonderilsin mi - istek.';
comment on column public.radyoloji_istem.cd_istendi is
  'Kabul sonrasi (311): sonuc CD hazirlansin mi.';

-- ------------------------------------------- modalite bazli hazirlik metni --
-- Tetkikin KENDI protokolu (radyoloji_protokol.hazirlik_metni) varsa o gecerli;
-- yoksa MODALITE varsayilani kullanilir. Metni koda gomsek degistirmek surum
-- gerektirirdi - kod listesi kullanicinin duzenleyebilecegi yerdir.
insert into public.kod_liste (kod, ad)
select 'rad.hazirlik', 'Radyoloji Hazırlık Talimatı'
 where not exists (select 1 from public.kod_liste where kod = 'rad.hazirlik');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.deger, 1
  from public.kod_liste l
 cross join (values
    (1, 'Kontrastlı çekimde 4 saat aç gelin, böbrek değerleriniz (kreatinin) yanınızda olsun. Metal içeren giysi ve takıları çıkarın.'),
    (2, 'Tüm metal eşyaları (takı, saat, saç tokası, işitme cihazı) çıkarın. Kalp pili, koklear implant veya vücudunuzda metal varsa mutlaka bildirin. Çekim 20-40 dk sürer.'),
    (3, 'Batın ultrasonu için 6-8 saat aç gelin. Üriner sistem için 4-6 bardak su içip idrarınızı tutun.'),
    (4, 'Çekim bölgesindeki takı ve metal aksesuarları çıkarın. Gebelik ihtimaliniz varsa bildirin.'),
    (5, 'Çekim günü koltuk altına deodorant, pudra veya krem sürmeyin. Adet döneminin ilk haftası tercih edilir.'),
    (6, 'Son 5 gün içinde kontrastlı tetkik yaptırdıysanız bildirin. Metal içermeyen rahat kıyafet giyin.'),
    (7, '6 saat aç gelin. Kan sulandırıcı kullanıyorsanız hekiminize danışın; yanınızda refakatçi bulunsun.'),
    (8, 'İşleme göre aç gelmeniz istenebilir; randevu sırasında verilen talimata uyun. Gebelik ihtimalinizi bildirin.')
  ) as v(deger, ad)
 where l.kod = 'rad.hazirlik'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);


-- Ilk surumde metinler "MR: ..." gibi modalite onekiyle yazilmisti; ekranda
-- baslik zaten modalite adi oldugu icin onek TEKRAR ediyordu. Yalniz
-- DEGISMEMIS (kullanicinin duzenlemedigi) satirlar guncellenir.
update public.kod_deger d
   set ad = v.yeni
  from public.kod_liste l,
       (values
         ('BT: Kontrastlı çekimde 4 saat aç gelin, böbrek değerleriniz (kreatinin) yanınızda olsun. Metal içeren giysi ve takıları çıkarın.', 'Kontrastlı çekimde 4 saat aç gelin, böbrek değerleriniz (kreatinin) yanınızda olsun. Metal içeren giysi ve takıları çıkarın.'),
         ('MR: Tüm metal eşyaları (takı, saat, saç tokası, işitme cihazı) çıkarın. Kalp pili, koklear implant veya vücudunuzda metal varsa mutlaka bildirin. Çekim 20-40 dk sürer.', 'Tüm metal eşyaları (takı, saat, saç tokası, işitme cihazı) çıkarın. Kalp pili, koklear implant veya vücudunuzda metal varsa mutlaka bildirin. Çekim 20-40 dk sürer.'),
         ('USG: Batın ultrasonu için 6-8 saat aç gelin. Üriner sistem için 4-6 bardak su içip idrarınızı tutun.', 'Batın ultrasonu için 6-8 saat aç gelin. Üriner sistem için 4-6 bardak su içip idrarınızı tutun.'),
         ('Röntgen: Çekim bölgesindeki takı ve metal aksesuarları çıkarın. Gebelik ihtimaliniz varsa bildirin.', 'Çekim bölgesindeki takı ve metal aksesuarları çıkarın. Gebelik ihtimaliniz varsa bildirin.'),
         ('Mamografi: Çekim günü koltuk altına deodorant, pudra veya krem sürmeyin. Adet döneminin ilk haftası tercih edilir.', 'Çekim günü koltuk altına deodorant, pudra veya krem sürmeyin. Adet döneminin ilk haftası tercih edilir.'),
         ('DEXA (kemik yoğunluğu): Son 5 gün içinde kontrastlı tetkik yaptırdıysanız bildirin. Metal içermeyen rahat kıyafet giyin.', 'Son 5 gün içinde kontrastlı tetkik yaptırdıysanız bildirin. Metal içermeyen rahat kıyafet giyin.'),
         ('Anjiyo: 6 saat aç gelin. Kan sulandırıcı kullanıyorsanız hekiminize danışın; yanınızda refakatçi bulunsun.', '6 saat aç gelin. Kan sulandırıcı kullanıyorsanız hekiminize danışın; yanınızda refakatçi bulunsun.'),
         ('Skopi: İşleme göre aç gelmeniz istenebilir; randevu sırasında verilen talimata uyun. Gebelik ihtimalinizi bildirin.', 'İşleme göre aç gelmeniz istenebilir; randevu sırasında verilen talimata uyun. Gebelik ihtimalinizi bildirin.')
       ) as v(eski, yeni)
 where d.liste_id = l.id and l.kod = 'rad.hazirlik' and d.ad = v.eski;
