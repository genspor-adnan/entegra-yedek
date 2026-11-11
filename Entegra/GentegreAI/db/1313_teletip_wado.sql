-- 1313 - Teletıp dışa açık WADO (RAD-55)
--
-- Kullanıcı 11.11.2026: "dışa açık WADO adımını yap". Teleradyoloji Entegrasyon Kılavuzu 3.43 § 4.2 + XDS Kılavuzu 1.15
-- § 2.3: Bakanlık web görüntüleyicisi KOS'ta referans verilen görüntüleri kurumun WADO-URI servisinden DICOM ve JPEG
-- olarak çeker (…/DCM/WADO?requestType=WADO&studyUID&seriesUID&objectUID&contentType). Servis API'de AYRI bir portta
-- (TeletipWado:Port) koşar ve YALNIZ KOS'u Bakanlık'a başarıyla gitmiş çalışmaları verir - PACS'ın tamamı açılmaz.
--
--   * teletip_gonderim.study_uid: KOS satırının gönderdiği çalışma (istem silinse / study_uid değişse de erişim kuralı
--     gönderilen KOS'a bağlı kalsın). Mevcut KOS satırları istemden doldurulur.
--   * teletip_wado_erisim: gün + IP + çalışma başına sayaç (her görüntü isteği bir satır DEĞİL - görüntüleyici bir
--     çalışmada yüzlerce nesne çeker). KVKK: kimin hangi çalışmaya ne zaman eriştiği izlenebilir.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

alter table public.teletip_gonderim add column if not exists study_uid varchar(64) not null default '';

update public.teletip_gonderim g
   set study_uid = i.study_uid
  from public.radyoloji_istem i
 where g.kanal = 2 and g.study_uid = '' and i.id = g.istem_id and coalesce(i.study_uid, '') <> '';

create index if not exists ix_teletip_gonderim_kos_study
    on public.teletip_gonderim (study_uid) where kanal = 2 and durum = 1;

create table if not exists public.teletip_wado_erisim (
    gun          date         not null,
    ip           varchar(45)  not null,
    study_uid    varchar(64)  not null,
    istek_sayisi integer      not null default 0,
    hata_sayisi  integer      not null default 0,
    bayt         bigint       not null default 0,
    ilk_erisim   timestamptz  not null default now(),
    son_erisim   timestamptz  not null default now(),
    son_hata     varchar(300) not null default '',
    primary key (gun, ip, study_uid)
);
comment on table public.teletip_wado_erisim is
  '1313: Teletıp dışa açık WADO erişim sayacı (gün + IP + çalışma). Reddedilen istekte study_uid istenen değerdir.';

commit;
