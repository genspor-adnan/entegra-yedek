-- =====================================================================
--  927_muayene_sablon_bolum_doktor.sql
--  MUAYENE ŞABLONLARI: BÖLÜM ve DOKTORA GÖRE (kullanıcı; mockup
--  Ekranlar/Muayene/muayene_sablon_listesi.html · muayene_sablon_karti.html).
--
--  Şablon kapsamı zaten iki kolonla tutuluyordu (bolum_id, hekim_id):
--  doktor boş = bölüm ortak, dolu = doktora özel. İki şey eksikti:
--    * varsayilan       : bölümde muayene açılınca ÖNERİLEN şablon (⭐).
--                         Bölüm başına TEK aktif ortak varsayılan - kısmi
--                         benzersiz indeks; "varsayılan yap" ucu eskisini
--                         aynı işlemde kaldırır.
--    * kaynak_sablon_id : "Kopyala (bana)" ile doktora alınan şablonun
--                         geldiği ortak şablon (iz; ortak şablon silinirse
--                         bağ boşa düşer, kopya kalır).
--  Kullanım sayısı için yeni kolon YOK: muayene.sablon_id zaten hangi
--  şablonun uygulandığını tutuyor - sayı oradan sayılır.
-- =====================================================================
\set ON_ERROR_STOP on

alter table public.muayene_sablon
    add column if not exists varsayilan smallint not null default 0;

alter table public.muayene_sablon
    add column if not exists kaynak_sablon_id integer;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_muayene_sablon_kaynak') then
        alter table public.muayene_sablon
            add constraint fk_muayene_sablon_kaynak foreign key (kaynak_sablon_id)
            references public.muayene_sablon(id) on delete set null;
    end if;
end $$;

comment on column public.muayene_sablon.varsayilan is
    '927: bölümde muayene açılınca önerilen ortak şablon (bölüm başına tek).';
comment on column public.muayene_sablon.kaynak_sablon_id is
    '927: "Kopyala (bana)" ile alındığı şablon (iz).';

-- Bölüm başına tek aktif ORTAK varsayılan.
create unique index if not exists ux_muayene_sablon_varsayilan
    on public.muayene_sablon (bolum_id)
 where varsayilan = 1 and durum = 1 and hekim_id is null and bolum_id is not null;

-- Kullanım sayımı (liste ve kart "Kullanım" sekmesi).
create index if not exists ix_muayene_sablon_kullanim
    on public.muayene (sablon_id, muayene_tarihi desc) where sablon_id is not null;

do $$ begin raise notice '927 tamam: muayene_sablon varsayilan + kaynak_sablon_id'; end $$;
