-- 335: HASTA KİMLİK ALANLARININ TAMAMLANMASI + ORTAK YAKIN TABLOSU.
--
-- Kaynak: Ekranlar/Genotıp_TabloAlanGereksinimleri.xlsx "KIMLIK" sayfası.
-- Eksik olan alanlar hastaya özgüdür; bu yüzden `taraf`a değil 1:1 uzantı
-- olan `taraf_hasta`ya eklenir - cari/tedarikçi/personel kartı kirlenmesin.
--
-- SKRS KODLARI DOĞRUDAN KULLANILIR (kullanıcı kararı): ayrı bir "yerel kod ->
-- SKRS kodu" eşleme tablosu tutulmaz, kod listesinin DEĞERİ SKRS kodudur.
-- Böylece eNabız/MEDULA gönderiminde çeviri katmanı gerekmez. Aşağıdaki
-- listeler bilinen değerlerle kurulur; resmi SKRS listesi elde edilince
-- `kod_deger.deger` alanları onunla güncellenir (tablo yapısı değişmez).
--
-- YAKIN/ACİL KİŞİ TEK TABLODA (kullanıcı): personelin acil durumda aranacak
-- kişisi ile hastanın yakını aynı bilgidir (ad, yakınlık, telefon). Tablo
-- `personel_acil_kisi` adıyla yalnız personel için açılmıştı; adı
-- genelleştirilip iki kartta da kullanılır.

-- =========================================================== hasta alanları
alter table public.taraf_hasta
  add column if not exists pasaport_no          varchar(20),
  -- SKRS medeni hal kodu (kod listesi hasta.medeni_hal).
  add column if not exists medeni_hal           smallint,
  add column if not exists ana_adi              varchar(60),
  add column if not exists baba_adi             varchar(60),
  add column if not exists anne_tckn            varchar(11),
  add column if not exists baba_tckn            varchar(11),
  -- Vefat: bayrak + tarih. Bayrak ayrı duruyor çünkü tarih bilinmeden de
  --   "vefat etti" işaretlenebiliyor (dış kurumdan gelen bildirim).
  add column if not exists vefat                smallint not null default 0,
  add column if not exists vefat_tarihi         date,
  -- Kimliksiz hasta (acil, bilinci kapalı): TCKN olmadan kayıt açılır,
  --   kimlik sonradan eşleştirilir.
  add column if not exists kimliksiz            smallint not null default 0,
  -- SKRS yabancı hasta türü (kod listesi hasta.yabanci_turu).
  add column if not exists yabanci_hasta_turu   smallint,
  add column if not exists ulkeye_giris_tarihi  date,
  -- Mahremiyet notu: hasta dosyasına erişimde uyarı ("çalışan hastası",
  --   "korunma kararı var" gibi). Klinik nottan AYRI tutulur.
  add column if not exists mahremiyet_notu      varchar(500);

comment on column public.taraf_hasta.medeni_hal is
  'SKRS medeni hal kodu (335) - kod listesi hasta.medeni_hal.';
comment on column public.taraf_hasta.yabanci_hasta_turu is
  'SKRS yabanci hasta turu kodu (335) - kod listesi hasta.yabanci_turu.';
comment on column public.taraf_hasta.kimliksiz is
  'Kimligi belirsiz hasta (335): TCKN olmadan kayit; sonradan eslestirilir.';
comment on column public.taraf_hasta.mahremiyet_notu is
  'Dosya acilirken gosterilecek mahremiyet uyarisi (335).';

-- ---------------------------------------------------------- kod listeleri -
insert into public.kod_liste (kod, ad)
select v.kod, v.ad
  from (values ('hasta.medeni_hal', 'Medeni Hal (SKRS)'),
               ('hasta.yabanci_turu', 'Yabancı Hasta Türü (SKRS)')) v(kod, ad)
 where not exists (select 1 from public.kod_liste l where l.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad)
select kl.id, v.deger, v.ad
  from (values (1, 'Bekar'), (2, 'Evli'), (3, 'Boşanmış'), (4, 'Eşi Ölmüş')) v(deger, ad)
  join public.kod_liste kl on kl.kod = 'hasta.medeni_hal'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = kl.id and d.deger = v.deger);

-- Yabanci hasta turu: SKRS listesi gelene kadar calisilan ana turler.
insert into public.kod_deger (liste_id, deger, ad)
select kl.id, v.deger, v.ad
  from (values (1, 'Turist'), (2, 'Geçici Koruma'), (3, 'Uluslararası Koruma'),
               (4, 'İkamet İzinli'), (5, 'Çalışma İzinli'), (6, 'Öğrenci'),
               (9, 'Diğer')) v(deger, ad)
  join public.kod_liste kl on kl.kod = 'hasta.yabanci_turu'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = kl.id and d.deger = v.deger);

-- ================================================== ortak yakın / acil kişi
do $$
begin
    if exists (select 1 from information_schema.tables
                where table_schema = 'public' and table_name = 'personel_acil_kisi')
       and not exists (select 1 from information_schema.tables
                        where table_schema = 'public' and table_name = 'taraf_acil_kisi') then
        alter table public.personel_acil_kisi rename to taraf_acil_kisi;
    end if;
end $$;

alter table public.taraf_acil_kisi
  add column if not exists eposta varchar(120),
  -- Hasta yakininda "yakinlik" zorunlu gibi dursa da acil kayitta bos
  --   kalabiliyor; serbest metin olarak kaliyor (SKRS'de karsiligi yok).
  add column if not exists aciklama varchar(200);

comment on table public.taraf_acil_kisi is
  'Acil durumda aranacak kisi / hasta yakini (335): personel ve hasta ORTAK.';

-- Eski ad kirilmasin: gorunum tek tablodan select* oldugu icin PG bunu
--   guncellenebilir gorunum sayar (eski kod hala yazabilir).
create or replace view public.personel_acil_kisi as
    select * from public.taraf_acil_kisi;

comment on view public.personel_acil_kisi is
  'ESKI AD - taraf_acil_kisi ile ayni (335). Yeni kod taraf_acil_kisi kullanir.';
