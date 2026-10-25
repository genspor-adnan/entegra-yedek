-- =============================================================================
--  1187  CARİYE ÖZEL e-BELGE DİPNOTU (taraf.efatura_dipnot / eirsaliye_dipnot)
--
--  Kullanıcı (25.10.2026): "müşteri kartında e-Belge Ayarları'na müşteriye özel e-Fatura Dipnotu ve e-İrsaliye
--  Dipnotu girişi ekle; fatura / irsaliye keserken burası doluysa burayı kullanacak, yoksa genel dipnotu" +
--  "dipnot girişi için modal açılsın".
--  Dolu ise e-Belge hazırlamada (EFaturaServisi.NotlarAsync) türün genel sabit not şablonunun
--  (efatura / earsiv / eirsaliye .sabit_notlar) YERİNE kullanılır; aynı {ALAN} yer tutucuları geçerli.
--  Fatura dipnotu e-Fatura ve e-Arşiv'de, irsaliye dipnotu e-İrsaliye'de. Vergi notları (istisna / tevkifat)
--  her durumda eklenir. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

alter table public.taraf add column if not exists efatura_dipnot   varchar(1000) not null default '';
alter table public.taraf add column if not exists eirsaliye_dipnot varchar(1000) not null default '';

comment on column public.taraf.efatura_dipnot is
  '1187: cariye ozel e-Fatura / e-Arsiv dipnot sablonu; bossa genel sabit notlar.';
comment on column public.taraf.eirsaliye_dipnot is
  '1187: cariye ozel e-Irsaliye dipnot sablonu; bossa genel sabit notlar.';

commit;
