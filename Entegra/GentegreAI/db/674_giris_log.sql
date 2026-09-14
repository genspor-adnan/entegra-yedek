-- ============================================================================
--  Gentegre AI — GİRİŞ KAYITLARI (login log) ekrana açılıyor
--  674_giris_log.sql
--
--  Kullanıcı: "login bilgileri de log da tutulsun."
--
--  Kayıt zaten tutuluyordu (`giris_denemesi`, KimlikServisi her denemede
--  yazıyor) ama hiçbir ekrandan okunamıyordu - tutulup bakılmayan kayıt,
--  tutulmamış kayıtla aynı şeydir. Bu betik tabloyu LİSTE EKRANINA hazırlar.
--
--  İki değişiklik:
--   1. `kod` 30 → 120: giriş artık ad soyad / e-posta / TCKN ile de
--      yapılabiliyor (667 esnek giriş); "Neslihan Arslan Yıldırım" 30 haneye
--      sığmıyordu ve log satırı kırpılmış bir metinle kalıyordu.
--   2. Tarihe göre inen sıralama indeksi: liste varsayılan olarak "son
--      denemeler" gösterir; her açılışta 1900+ satır sıralamak gereksiz.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.giris_denemesi
    alter column kod type varchar(120);

comment on column public.giris_denemesi.kod is
  'Girise YAZILAN kimlik: kullanici kodu, sicil, e-posta, cep, TCKN ya da ad soyad (674).';

create index if not exists ix_giris_denemesi_tarih
    on public.giris_denemesi (tarih desc);

do $$
begin
    raise notice '674 tamam: giris_denemesi.kod 120 hane + tarih indeksi.';
end $$;
