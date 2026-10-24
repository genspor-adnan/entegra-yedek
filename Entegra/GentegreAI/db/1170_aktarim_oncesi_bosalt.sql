-- =============================================================================
--  1170  AKTARIMDAN ÖNCE HEDEF VERİTABANINI BOŞALT
--
--  Kullanıcı (24.10.2026, UNIVERSE geçişinden sonra): "erp den aktarım yapıyorsak
--  eski stok ve hizmet kalemleri silinmelidir" -> "kural olarak da ekle.. önce tüm
--  data (DB) boşalsın sonra aktarım olsun" -> "hedef PG boşalsın yani kaynak değil".
--
--  Boş kurulum (kur.ps1 -SadeceSema) göçlerin tohumlarıyla gelir: HBYS lab testleri
--  ve panelleri (hizmet + lab_tetkik / lab_panel / referans aralıkları), demo hekimler
--  (taraf HEK-*, DH-*), döküman klasörleri, standart hesap planı. Delphi'den aktarımla
--  kurulan veritabanında bunlar Delphi kayıtlarıyla yan yana durup Stok / Hizmet
--  Ara'da "eski kalem" olarak görünüyordu (UNIVERSE'te 18 lab hizmeti elle silindi).
--
--  fn_aktarim_oncesi_bosalt(p_uygula):
--    HEDEF = aktarımın yazdığı tablolar (aktarim_kaynak kolonu olanlar: taraf, stok,
--    hizmet, belge, kasa_islem, hesap_plani, dokuman ...) + kategori ağacı + onlara FK ile bağlı
--    (silmeyi engelleyen ya da zincirle silen) satırlar.
--    KORUNAN: oturum açan kullanıcılar (taraf_kullanici - admin), kurulumun deposu, şube / rol / yetki /
--    kurum / ayar / kod listesi / aktarım ve göç defteri tabloları. Silme bunlardan
--    birine uzanırsa HİÇBİR ŞEY silinmez, tablo adıyla durur.
--    p_uygula = false (varsayılan): yalnız RAPOR (tablo, silinecek satır).
--    Aktarım BAŞLAMIŞSA (hedef tablolarda aktarim_kaynak dolu satır varsa) reddeder -
--    aktarılan ya da web'de girilen veri bu yolla silinemez.
--  MSSQL kaynağa dokunulmaz. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create or replace function public.fn_aktarim_oncesi_bosalt(p_uygula boolean default false)
returns table (tablo text, satir bigint)
language plpgsql as $$
declare
    r record;
    v_eklenen bigint;
    v_tur integer;
    v_kalan bigint;
    v_var boolean;
    v_hedef regclass[];
    v_korunan text[] := array[
        'taraf_kullanici', 'parola_gecmisi', 'sube', 'rol', 'rol_yetki', 'rol_sube', 'yetki',
        'kurum', 'kurum_tipi', 'ayar', 'kod_liste', 'kod_deger', 'goc_gecmisi'];
begin
    -- DEPO HARİÇ: kurulumun varsayılan deposu silinemez (fn_depo_kural_kontrol) ve aktarım
    --   onu Delphi deposuyla eşleyip devralır (UNIVERSE'te depo 1 böyle aktarımlı oldu).
    select array_agg(c.table_name::regclass) into v_hedef
      from information_schema.columns c
     where c.table_schema = 'public' and c.column_name = 'aktarim_kaynak'
       and c.table_name <> 'depo';

    -- AKTARIM BAŞLAMIŞ MI: tek satır bile aktarılmışsa boşaltma yok.
    for r in select unnest(v_hedef) as t loop
        execute format('select exists (select 1 from %s where aktarim_kaynak is not null)', r.t) into v_var;
        if v_var then
            raise exception 'Aktarım başlamış (% tablosunda aktarılmış satır var) - boşaltma yalnız aktarımdan önce yapılır.', r.t
                using errcode = 'P0001';
        end if;
    end loop;

    create temp table if not exists _bosalt (t regclass, id bigint, primary key (t, id)) on commit drop;
    truncate _bosalt;

    -- Tohum: hedef tabloların bütün satırları - oturum açan kullanıcı (admin) hariç.
    for r in select unnest(v_hedef) as t loop
        execute format('insert into _bosalt select %L::regclass, id from %s x where %s',
                       r.t, r.t,
                       case when r.t = 'public.taraf'::regclass
                            then 'not exists (select 1 from public.taraf_kullanici k where k.id = x.id)'
                            else 'true' end);
    end loop;

    -- KATEGORİ AĞACI da (aktarim_kaynak kolonu yok): 029'un sabit BILIM kategorileri + HBYS
    --   tohumları (lab / radyoloji hizmet ağacı). Delphi'nin ağacını aktar_ek (1171) aynı
    --   kimliklerle yazar - tohum kalırsa stoklar yanlış ada düşer (UNIVERSE).
    insert into _bosalt select 'public.kategori'::regclass, k.id from public.kategori k on conflict do nothing;

    -- Kapanış: silinecek satıra FK ile bağlı (NO ACTION / RESTRICT / CASCADE) satırlar da silinir.
    --   SET NULL / SET DEFAULT bağları veritabanı kendisi çözer.
    loop
        v_eklenen := 0;
        for r in
            select f.conrelid::regclass as cocuk, ca.attname as kolon, f.confrelid::regclass as ust
              from pg_constraint f
              join pg_attribute ca on ca.attrelid = f.conrelid and ca.attnum = f.conkey[1]
             where f.contype = 'f' and cardinality(f.conkey) = 1 and f.confdeltype in ('a', 'r', 'c')
               and f.confrelid in (select distinct b.t from _bosalt b)
               and exists (select 1 from pg_attribute i where i.attrelid = f.conrelid and i.attname = 'id' and not i.attisdropped)
        loop
            execute format('insert into _bosalt select %L::regclass, c.id from %s c
                             where c.%I in (select b.id from _bosalt b where b.t = %L::regclass)
                            on conflict do nothing', r.cocuk, r.cocuk, r.kolon, r.ust);
            get diagnostics v_tur = row_count;
            v_eklenen := v_eklenen + v_tur;
        end loop;
        exit when v_eklenen = 0;
    end loop;

    -- KORUNAN tabloya uzanıyorsa dur.
    for r in select b.t::text as ad, count(*) as n from _bosalt b
              where replace(b.t::text, 'public.', '') = any (v_korunan)
                 or replace(b.t::text, 'public.', '') like 'kullanici%'
                 or replace(b.t::text, 'public.', '') like 'aktarim%'
              group by b.t loop
        raise exception 'Boşaltma korunan tabloya uzanıyor: % (% satır) - hiçbir şey silinmedi.', r.ad, r.n
            using errcode = 'P0001';
    end loop;

    -- Rapor her iki kipte de: silinen (ya da silinecek) satırlar tablo tablo.
    return query select b.t::text, count(*) from _bosalt b group by b.t order by 1;

    if p_uygula then
        -- Bağımlılık sırası bilinmiyor: her geçişte silinebilenler silinir (FK engeli
        --   olan tablo sonraki geçişe kalır). İlerleme durursa bütün işlem geri alınır.
        for v_tur in 1..60 loop
            v_eklenen := 0;
            for r in select distinct b.t from _bosalt b loop
                begin
                    execute format('delete from %s where id in (select b.id from _bosalt b where b.t = %L::regclass)', r.t, r.t);
                    get diagnostics v_kalan = row_count;
                    v_eklenen := v_eklenen + v_kalan;
                    delete from _bosalt b where b.t = r.t;
                exception when foreign_key_violation then null;
                end;
            end loop;
            exit when not exists (select 1 from _bosalt);
            if v_eklenen = 0 then
                raise exception 'Boşaltma ilerlemiyor (kalan: %) - hiçbir şey silinmedi.',
                    (select string_agg(distinct b.t::text, ', ') from _bosalt b) using errcode = 'P0001';
            end if;
        end loop;
    end if;
end $$;

comment on function public.fn_aktarim_oncesi_bosalt(boolean) is
  '1170: Delphi aktarimindan ONCE hedef PG''yi bosaltir (tohum hizmet/lab/demo hekim/hesap plani...). '
  'false = rapor, true = sil. Aktarim baslamissa reddeder; admin ve sube/rol/yetki korunur.';

commit;
