-- =====================================================================
--  658_basvuru_hasta_id.sql
--  DIŞ KURUM BAŞVURUSUNDA HASTA KAYBOLUYORDU.
--
--  Dış kurum numunesinde başvurunun carisi gönderen KURUMDUR (fatura ona
--  kesilir, hastanın ekstresine doğmayacak borç yazılmaz). Bunun bedeli:
--  belgede hastayı gösteren hiçbir alan kalmıyor - kullanıcı "başvuru
--  3990'da hasta adı yok" diyor ve haklı. Hasta yalnız `lab_istem`de
--  duruyordu; başvuruya bakan kişi numunenin kime ait olduğunu göremiyor.
--
--  ÇÖZÜM: `belge_basvuru.hasta_id`. Cari (ödeyen) ile HASTA ayrı sorular;
--  ikisini tek kolonda tutmaya çalışmak, ya faturayı yanlış kişiye kesmek
--  ya hastayı kaybetmek demekti.
--
--  NORMAL BAŞVURUDA DA DOLAR: orada cari zaten hastadır, alan aynı kişiyi
--  gösterir - "hasta kim" sorusunun cevabı her başvuruda AYNI yerden
--  okunur. Geriye dönük dolgu bu yüzden iki kaynaktan yapılır: lab istemi
--  olan başvuruda istemin hastası, ötekilerde belgenin kendi carisi
--  (hasta rolü varsa).
-- =====================================================================

alter table public.belge_basvuru
    add column if not exists hasta_id integer;

do $fk$
begin
    if not exists (select 1 from pg_constraint
                    where conname = 'fk_belge_basvuru_hasta') then
        alter table public.belge_basvuru
            add constraint fk_belge_basvuru_hasta
            foreign key (hasta_id) references public.taraf (id);
    end if;
end $fk$;

create index if not exists ix_belge_basvuru_hasta
    on public.belge_basvuru (hasta_id) where hasta_id is not null;

comment on column public.belge_basvuru.hasta_id is
    'Basvurunun HASTASI. Cari (belge.taraf_id) odeyen olabilir - dis kurum '
    'numunesinde kurumdur; hasta burada durur (658).';

-- ------------------------------------------------------------- dolgu
--  1) Lab isteminden gelen başvurular: istemin hastası.
update public.belge_basvuru bb
   set hasta_id = i.taraf_id
  from public.lab_istem i
 where i.belge_id = bb.id
   and bb.hasta_id is null;

--  2) Öteki başvurular: carinin kendisi, ama YALNIZ hasta rolü varsa -
--     kurumsal cariyi hasta diye yazmak yanlış bilgi üretirdi.
update public.belge_basvuru bb
   set hasta_id = b.taraf_id
  from public.belge b
  join public.taraf t on t.id = b.taraf_id and t.hasta = 1
 where b.id = bb.id
   and bb.hasta_id is null;

do $kontrol$
begin
    raise notice '658 tamam: hastasi yazili basvuru %, hastasiz %',
        (select count(*) from public.belge_basvuru where hasta_id is not null),
        (select count(*) from public.belge_basvuru where hasta_id is null);
end $kontrol$;
