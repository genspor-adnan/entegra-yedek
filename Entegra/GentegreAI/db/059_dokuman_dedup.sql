-- ============================================================================
--  Gentegre AI — Doküman içerik dedup (hash-bazlı paylaşımlı içerik tablosu)
--  059_dokuman_dedup.sql
--
--  Kullanici: "dokuman icin eskiden 3 lu zincir vardi (dokuman,imaj,dosya)..
--  simdi?" -> "dedup mantigi neden yok?" -> "simdi dedup yap". Eski GENDEPO.DOSYA
--  (FILESTREAM, hash-dedup) desenini bytea icin uyguluyor: icerik artik
--  public.dokuman'da DEGIL, ayri public.dokuman_icerik'te (hash PK), dokuman.hash
--  ile referans veriyor. Ayni icerik 2. kez yuklenince ikinci bytea kopyasi
--  YAZILMAZ, sadece referans_sayisi artar.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.dokuman_icerik (
    hash                character varying(64) primary key,
    icerik              bytea not null,
    content_type        character varying(100) not null,
    boyut               integer not null,
    referans_sayisi     integer not null default 0,
    ekleme_tarihi       timestamp not null default now()::timestamp
);

-- Mevcut satirlari hash'e gore grupla, tek kopya icerik + dogru referans_sayisi ile tasi.
insert into public.dokuman_icerik (hash, icerik, content_type, boyut, referans_sayisi)
select d.hash, (array_agg(d.icerik))[1], (array_agg(d.content_type))[1], (array_agg(d.boyut))[1], count(*)
  from public.dokuman d
 where d.hash <> ''
 group by d.hash
on conflict (hash) do nothing;

alter table public.dokuman
    add constraint fk_dokuman_hash foreign key (hash) references public.dokuman_icerik(hash);

alter table public.dokuman drop column icerik;

comment on table public.dokuman_icerik is
  'Doküman/resim ham içeriği - hash (SHA256) PK, public.dokuman satırları hash ile paylaşımlı referans verir. referans_sayisi 0''a düşünce satır silinir (bkz. DokumanDeposu.SilAsync).';
