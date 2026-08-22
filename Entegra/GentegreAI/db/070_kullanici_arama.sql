-- Eski Delphi KULLANICI_ARAMA (KULID+MODUL+KAYITID+SAY+DEGISTIRMETARIHI) karsiligi.
-- Kart her acilista (GET /api/kart/{kaynak}/{id}) ve her eklemede (POST /api/kart/{kaynak})
-- upsert edilir: say++ ve son_tarih=now(). Liste ekraninda "Son Aranan" (son_tarih desc)
-- ve "Sik Aranan" (say desc) gorunumlerini besler.

create table if not exists public.kullanici_arama (
    kullanici_id integer     not null references public.taraf_kullanici (id),
    kaynak       varchar(40) not null,
    kayit_id     bigint      not null,
    say          integer     not null default 1,
    son_tarih    timestamp   not null default now(),
    primary key (kullanici_id, kaynak, kayit_id)
);

create index if not exists ix_kullanici_arama_sik
    on public.kullanici_arama (kullanici_id, kaynak, say desc);

create index if not exists ix_kullanici_arama_son
    on public.kullanici_arama (kullanici_id, kaynak, son_tarih desc);

comment on table public.kullanici_arama is
    'Eski GENDEPO KULLANICI_ARAMA karsiligi: kart acilis/ekleme sıklığı - Son/Sik Aranan gorunumleri.';
