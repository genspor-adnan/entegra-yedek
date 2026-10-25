-- =============================================================================
--  1190  ORTAK GİRİŞ PANELİ - TEK KULLANIMLIK GİRİŞ KODU
--
--  Kullanıcı (26.10.2026): "sunucuya panel adresi altında bir sayfa tasarlasak, tüm müşteriler girişlerini bu
--  sayfa üzerinden yapsa" → mockup Ekranlar/Ayarlar/ortak_giris_paneli.html, kararlar onaylandı → "kodla".
--  Panel (panel.gentegreai.com) firma kodunu kurulum adresine çevirir ve girişi firmanın KENDİ API'sine iletir:
--    POST /api/kimlik/giris-kodu        {kullaniciAdi, parola}  → normal giriş + {kod} (token PANELE VERİLMEZ)
--    POST /api/kimlik/giris-kodu/kullan {kod}                   → oturum (GirisYaniti), kod silinir
--  Kod 60 sn geçerli, tek kullanımlık; tabloda yalnız SHA-256 özeti tutulur. Yanıt (token) kodla birlikte en
--  fazla 60 sn durur, kullanılınca / süresi dolunca silinir.
--  Askı: referans 'genel.hesap_askida' = 1 → doğru parolada "Hesabınız askıda" (KimlikServisi).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create table if not exists public.giris_kodu (
  id         bigint generated always as identity primary key,
  kod_ozet   char(64)     not null unique,          -- sha256(kod) hex
  yanit      jsonb        not null,                 -- GirisYaniti (token) - kullanılınca silinir
  son_an     timestamptz  not null,
  ip         varchar(64)  not null default '',
  ekleme_an  timestamptz  not null default now()
);
create index if not exists ix_giris_kodu_son on public.giris_kodu (son_an);

comment on table public.giris_kodu is
  '1190: ortak giris paneli tek kullanimlik kod (60 sn) - kod_ozet sha256; kullanilinca / suresi dolunca silinir.';

commit;
