-- =============================================================================
--  1083  DELPHI AKTARIMI - DİLİM 2b: ÜRETİM REÇETESİ -> ÜRÜN AĞACI (dokuman/18 §11)
--
--  Kullanıcı (13.10.2026): tanımların HEPSİ aktarılır ("reçete falan da hepsi");
--  hareketlerde yalnız bu yıl (belge dilimi, 1084).
--
--  Kaynak (Delphi, MSSQL Update_SQL_209 ile değişiklik izlemede):
--    URETIMRECETE       -> urun_agaci            (mamulün tarifi)
--    URETIMRECETEDETAY  -> urun_agaci_satir      (bileşen)
--    URETIMRECETEOPR    -> urun_agaci_operasyon  (rota)
--    LOKASYON (TUR 7/8) -> is_merkezi            (operasyonun KAYNAK'ı - makine)
--
--  Delphi reçete modeli (BILIM verisiyle doğrulandı, 13.10.2026):
--   * Mamulün kendisi detayda ANAURUN = 1, MIKTAR = +1 satırıdır (3.086 satır,
--     hepsi 1) - bileşen DEĞİL, çıktıdır. Bileşenler MIKTAR < 0 (6.603 satır);
--     web'de miktar pozitif yazılır. Diğer pozitif / sıfır satırlar (14) yan
--     çıktıdır - web ağacında karşılığı yok, sayılıp atlanır.
--   * Reçete 1 birim mamul içindir (UUretimWizard: MIKTAR * üretilen adet) ->
--     cikti_miktar 1.
--   * URETIMRECETE.TUR = 0 / NULL pasif reçetedir (UUretimRecete: "TUR > 0"
--     yalnız aktifler); DURUM kolonu hep NULL, kullanılmıyor.
--   * Bir mamulün birden çok reçetesi olabilir; Delphi ilk bulduğunu kullanır ->
--     web'de en küçük Delphi id'li aktif reçete VARSAYILAN (web'in kendi
--     varsayılanı varsa o kalır).
--   * Operasyon KAYNAK = LOKASYON.ID (makine; TUR 7 makine, 8 - ikisi reçetede
--     kullanılıyor). SURE bir saat (1899-12-30 hh:mm) -> dakika.
--
--  TOPLAM (aggregate): ajan bir reçete için URETIMRECETE satırını ve o reçetenin
--  BÜTÜN detay + operasyon satırlarını birlikte gönderir; pakette olmayan detay /
--  operasyon satırı web'de silinir (bu tablolara başka kayıt bağlanmıyor -
--  üretim emri satırları kopyalanır). D.URETIMRECETE = reçete pasif.
--
--  KOD: (kod, surum) benzersiz. Delphi'de aynı kodlu 3 reçete var; web'de kod
--  başka bir kayda aitse ya da pakette tekrar ediyorsa kod '-<DelphiID>' ekiyle
--  yazılır (reçete kaybolmasın) - 'kod_ekli' sayacı. Mamulü çözülemeyen reçete
--  (stok aktarılmamış) atlanır - 'mamulsuz'.
--  İdempotent; içeriği aynı satıra yazılmaz.
-- =============================================================================

begin;

-- ------------------------------------------------------------- stg şekilleri --
create schema if not exists stg;

create table if not exists stg.uretimrecete (
    id integer, kod varchar(50), ad varchar(150), turu smallint, durum smallint,
    ozelkod varchar(50), notlar varchar(1000), subeid integer, ekleyen integer,
    eklemetarihi timestamp, degistiren integer, degistirmetarihi timestamp,
    stokid integer, tur smallint, tavsiye_satis_orani numeric(19,4));

create table if not exists stg.uretimrecetedetay (
    id integer, uretimreceteid integer, tur smallint, urunid integer, aciklama varchar(500),
    adet numeric(18,6), birim smallint, miktar numeric(18,6), masrafid smallint,
    anaurun smallint, sira integer, eklemetarihi timestamp);

create table if not exists stg.uretimreceteopr (
    id integer, uretimreceteid integer, konusu varchar(500), kaynak integer, sure timestamp,
    sira smallint, eklemetarihi timestamp, kalite smallint);

create table if not exists stg.lokasyon (
    id integer, kod varchar(50), aciklama varchar(500), durum smallint, tur smallint,
    subeid integer, ustkod varchar(50), eklemetarihi timestamp);

-- ---------------------------------------------------- kaynak kimliği (1080) --
do $$
declare t text;
begin
    foreach t in array array['urun_agaci', 'urun_agaci_satir', 'urun_agaci_operasyon', 'is_merkezi'] loop
        execute format('alter table public.%I add column if not exists aktarim_kaynak smallint', t);
        execute format('alter table public.%I add column if not exists aktarim_tablo varchar(30)', t);
        execute format('alter table public.%I add column if not exists aktarim_id bigint', t);
        execute format(
            'create unique index if not exists %I on public.%I (aktarim_kaynak, aktarim_tablo, aktarim_id) '
            'where aktarim_kaynak is not null', 'ux_' || t || '_aktarim', t);
    end loop;
end $$;

-- ================================================================ iş merkezi ===
create or replace function public.fn_aktar_is_merkezi(p jsonb)
returns jsonb language plpgsql as $$
declare v_n int := 0; v_c int := 0; v_sil int := 0;
begin
    create temp table if not exists _lk on commit drop as select * from stg.lokasyon with no data;
    truncate _lk;
    -- Yalnız makine türleri (7, 8): LOKASYON depo rafı / bölge de tutar.
    insert into _lk select * from jsonb_populate_recordset(null::stg.lokasyon, coalesce(p->'U'->'LOKASYON', '[]')) l
     where l.tur in (7, 8);

    -- kod başka (web ya da başka Delphi) kayda aitse atla
    select count(*) into v_c from _lk l
     where exists (select 1 from public.is_merkezi x
                    where x.kod = left(coalesce(nullif(btrim(l.kod), ''), 'L' || l.id), 25)
                      and not coalesce(x.aktarim_kaynak = 1 and x.aktarim_tablo = 'LOKASYON' and x.aktarim_id = l.id, false));

    insert into public.is_merkezi (kod, ad, sube_id, lokasyon, aciklama, durum, ekleme_tarihi,
                                   aktarim_kaynak, aktarim_tablo, aktarim_id)
    select left(coalesce(nullif(btrim(l.kod), ''), 'L' || l.id), 25),
           left(coalesce(nullif(btrim(l.aciklama), ''), l.kod, 'Lokasyon ' || l.id), 100),
           public.fn_aktarim_sube(l.subeid), left(coalesce(l.ustkod, ''), 100), '',
           case when coalesce(l.durum, 1) = 1 then 0 else 1 end,
           coalesce(public.fn_aktarim_zaman(l.eklemetarihi), now()), 1, 'LOKASYON', l.id
      from _lk l
     where not exists (select 1 from public.is_merkezi x
                        where x.kod = left(coalesce(nullif(btrim(l.kod), ''), 'L' || l.id), 25)
                          and not coalesce(x.aktarim_kaynak = 1 and x.aktarim_tablo = 'LOKASYON' and x.aktarim_id = l.id, false))
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, sube_id = excluded.sube_id,
                  lokasyon = excluded.lokasyon, durum = excluded.durum
     where (public.is_merkezi.kod, public.is_merkezi.ad, public.is_merkezi.sube_id,
            public.is_merkezi.lokasyon, public.is_merkezi.durum)
           is distinct from (excluded.kod, excluded.ad, excluded.sube_id, excluded.lokasyon, excluded.durum);
    get diagnostics v_n = row_count;

    update public.is_merkezi x set durum = 1
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'LOKASYON' and x.durum <> 1
       and x.aktarim_id in (select (e #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'LOKASYON', '[]')) e);
    get diagnostics v_sil = row_count;

    return jsonb_build_object('is_merkezi', v_n, 'cakisma', v_c, 'pasif', v_sil);
end $$;

-- ================================================================== reçete ===
create or replace function public.fn_aktar_recete(p jsonb)
returns jsonb language plpgsql as $$
declare v_a int := 0; v_mamulsuz int := 0; v_kodek int := 0; v_vars int := 0;
        v_s int := 0; v_ssil int := 0; v_bilesensiz int := 0; v_cikti int := 0;
        v_o int := 0; v_osil int := 0; v_alt int := 0; v_pasif int := 0;
begin
    create temp table if not exists _ur on commit drop as select * from stg.uretimrecete      with no data;
    create temp table if not exists _ud on commit drop as select * from stg.uretimrecetedetay with no data;
    create temp table if not exists _uo on commit drop as select * from stg.uretimreceteopr   with no data;
    truncate _ur, _ud, _uo;
    insert into _ur select * from jsonb_populate_recordset(null::stg.uretimrecete,      coalesce(p->'U'->'URETIMRECETE', '[]'));
    insert into _ud select * from jsonb_populate_recordset(null::stg.uretimrecetedetay, coalesce(p->'U'->'URETIMRECETEDETAY', '[]'));
    insert into _uo select * from jsonb_populate_recordset(null::stg.uretimreceteopr,   coalesce(p->'U'->'URETIMRECETEOPR', '[]'));

    -- 1) çözüm: mamul stok + kod
    create temp table if not exists _ura (delphi int primary key, stok int, kod varchar(25), ad varchar(150),
        birim int, durum int, notlar varchar(500), katsayi numeric, sube int, eklendi timestamptz) on commit drop;
    truncate _ura;
    insert into _ura
    select r.id, public.fn_aktarim_web_id('stok', 'STOKLAR', r.stokid),
           left(coalesce(nullif(btrim(r.kod), ''), 'R' || r.id), 25),
           left(coalesce(nullif(btrim(r.ad), ''), nullif(btrim(r.kod), ''), 'Reçete ' || r.id), 150),
           coalesce((select d.birim from _ud d
                      where d.uretimreceteid = r.id and coalesce(d.anaurun, 0) = 1 and d.urunid = r.stokid
                      order by d.id limit 1), 0),
           case when coalesce(r.tur, 0) > 0 then 0 else 1 end,
           left(coalesce(r.notlar, ''), 500), coalesce(r.tavsiye_satis_orani, 0),
           public.fn_aktarim_sube(r.subeid), coalesce(public.fn_aktarim_zaman(r.eklemetarihi), now())
      from _ur r;

    delete from _ura where stok is null;
    get diagnostics v_mamulsuz = row_count;

    -- Kod pakette tekrar ediyorsa (ilki hariç) ya da başka bir kayda aitse ekli.
    update _ura a set kod = left(a.kod, 24 - length(a.delphi::text)) || '-' || a.delphi
     where exists (select 1 from _ura b where b.kod = a.kod and b.delphi < a.delphi)
        or exists (select 1 from public.urun_agaci x
                    where x.kod = a.kod and x.surum = 1
                      and not coalesce(x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETE'
                                       and x.aktarim_id = a.delphi, false));
    get diagnostics v_kodek = row_count;

    -- 2) ağaç. Mamul değişirse varsayılan bayrağı düşer (yeni mamulde benzersizlik).
    insert into public.urun_agaci (kod, ad, stok_id, tur, cikti_miktar, birim, surum, varsayilan, durum,
                                   notlar, tavsiye_satis_katsayi, sube_id, ekleme_tarihi,
                                   aktarim_kaynak, aktarim_tablo, aktarim_id)
    select a.kod, a.ad, a.stok, 1, 1, a.birim, 1, 0, a.durum, a.notlar, a.katsayi, a.sube, a.eklendi,
           1, 'URETIMRECETE', a.delphi
      from _ura a
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, ad = excluded.ad, stok_id = excluded.stok_id, birim = excluded.birim,
                  durum = excluded.durum, notlar = excluded.notlar,
                  tavsiye_satis_katsayi = excluded.tavsiye_satis_katsayi, sube_id = excluded.sube_id,
                  varsayilan = case when public.urun_agaci.stok_id = excluded.stok_id and excluded.durum = 0
                                    then public.urun_agaci.varsayilan else 0 end
     where (public.urun_agaci.kod, public.urun_agaci.ad, public.urun_agaci.stok_id, public.urun_agaci.birim,
            public.urun_agaci.durum, public.urun_agaci.notlar, public.urun_agaci.tavsiye_satis_katsayi,
            public.urun_agaci.sube_id)
           is distinct from
           (excluded.kod, excluded.ad, excluded.stok_id, excluded.birim, excluded.durum, excluded.notlar,
            excluded.tavsiye_satis_katsayi, excluded.sube_id);
    get diagnostics v_a = row_count;

    create temp table if not exists _uag (delphi int primary key, web int) on commit drop;
    truncate _uag;
    insert into _uag select a.delphi, x.id from _ura a
      join public.urun_agaci x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETE' and x.aktarim_id = a.delphi;

    -- 3) bileşen satırları: yalnız MIKTAR < 0 olan, mamul satırı (ANAURUN) olmayan
    select count(*) into v_cikti from _ud d join _uag g on g.delphi = d.uretimreceteid
     where not (coalesce(d.miktar, 0) < 0 and coalesce(d.anaurun, 0) = 0);

    create temp table if not exists _uds (delphi int primary key, agac int, sira int, stok int,
        miktar numeric, birim int, aciklama varchar(300), eklendi timestamptz) on commit drop;
    truncate _uds;
    insert into _uds
    select d.id, g.web, coalesce(d.sira, 0), public.fn_aktarim_web_id('stok', 'STOKLAR', d.urunid),
           -d.miktar, coalesce(d.birim, 0), left(coalesce(d.aciklama, ''), 300),
           coalesce(public.fn_aktarim_zaman(d.eklemetarihi), now())
      from _ud d join _uag g on g.delphi = d.uretimreceteid
     where coalesce(d.miktar, 0) < 0 and coalesce(d.anaurun, 0) = 0;
    delete from _uds where stok is null;
    get diagnostics v_bilesensiz = row_count;

    insert into public.urun_agaci_satir (agac_id, sira, bilesen_stok_id, tur, miktar, birim, aciklama,
                                         ekleme_tarihi, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select s.agac, s.sira, s.stok, 1, s.miktar, s.birim, s.aciklama, s.eklendi, 1, 'URETIMRECETEDETAY', s.delphi
      from _uds s
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set agac_id = excluded.agac_id, sira = excluded.sira, bilesen_stok_id = excluded.bilesen_stok_id,
                  miktar = excluded.miktar, birim = excluded.birim, aciklama = excluded.aciklama
     where (public.urun_agaci_satir.agac_id, public.urun_agaci_satir.sira, public.urun_agaci_satir.bilesen_stok_id,
            public.urun_agaci_satir.miktar, public.urun_agaci_satir.birim, public.urun_agaci_satir.aciklama)
           is distinct from
           (excluded.agac_id, excluded.sira, excluded.bilesen_stok_id, excluded.miktar, excluded.birim,
            excluded.aciklama);
    get diagnostics v_s = row_count;

    -- pakette olmayan (silinmiş / artık bileşen sayılmayan) Delphi satırları
    delete from public.urun_agaci_satir x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETEDETAY'
       and x.agac_id in (select web from _uag)
       and not exists (select 1 from _uds s where s.delphi = x.aktarim_id);
    get diagnostics v_ssil = row_count;

    -- 4) operasyonlar
    insert into public.urun_agaci_operasyon (agac_id, sira, ad, is_merkezi_id, birim_sure_dk, kalite_kontrol,
                                             ekleme_tarihi, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select g.web, coalesce(o.sira, 0),
           left(coalesce(nullif(btrim(o.konusu), ''), 'Operasyon ' || coalesce(o.sira, 0)), 100),
           public.fn_aktarim_web_id('is_merkezi', 'LOKASYON', o.kaynak),
           coalesce(round((extract(epoch from (o.sure - timestamp '1899-12-30')) / 60)::numeric, 2), 0),
           coalesce(o.kalite, 0), coalesce(public.fn_aktarim_zaman(o.eklemetarihi), now()),
           1, 'URETIMRECETEOPR', o.id
      from _uo o join _uag g on g.delphi = o.uretimreceteid
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set agac_id = excluded.agac_id, sira = excluded.sira, ad = excluded.ad,
                  is_merkezi_id = excluded.is_merkezi_id, birim_sure_dk = excluded.birim_sure_dk,
                  kalite_kontrol = excluded.kalite_kontrol
     where (public.urun_agaci_operasyon.agac_id, public.urun_agaci_operasyon.sira, public.urun_agaci_operasyon.ad,
            public.urun_agaci_operasyon.is_merkezi_id, public.urun_agaci_operasyon.birim_sure_dk,
            public.urun_agaci_operasyon.kalite_kontrol)
           is distinct from
           (excluded.agac_id, excluded.sira, excluded.ad, excluded.is_merkezi_id, excluded.birim_sure_dk,
            excluded.kalite_kontrol);
    get diagnostics v_o = row_count;

    delete from public.urun_agaci_operasyon x
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETEOPR'
       and x.agac_id in (select web from _uag)
       and not exists (select 1 from _uo o where o.id = x.aktarim_id and o.uretimreceteid in (select delphi from _uag));
    get diagnostics v_osil = row_count;

    -- 5) silinen reçete -> pasif
    update public.urun_agaci x set durum = 1, varsayilan = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETE' and (x.durum <> 1 or x.varsayilan <> 0)
       and x.aktarim_id in (select (e #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'URETIMRECETE', '[]')) e);
    get diagnostics v_pasif = row_count;

    -- 6) varsayılan: aktif varsayılanı olmayan mamulde en küçük Delphi id'li aktif reçete.
    --    Ayrı adım: tek ifadede benzersiz indeks ara durumda çakışabilir.
    update public.urun_agaci x set varsayilan = 1
      from (select distinct on (a.stok_id) a.id
              from public.urun_agaci a
             where a.aktarim_kaynak = 1 and a.aktarim_tablo = 'URETIMRECETE' and a.durum = 0
               and a.stok_id in (select stok from _ura)
               and not exists (select 1 from public.urun_agaci v
                                where v.stok_id = a.stok_id and v.varsayilan = 1 and v.durum = 0)
             order by a.stok_id, a.aktarim_id) s
     where x.id = s.id;
    get diagnostics v_vars = row_count;

    -- 7) yarı mamul: bileşenin kendi aktif varsayılan ağacı varsa satır ona bağlanır
    --    (tur 4); yoksa hammadde (1). Bileşenin ağacı sonraki pakette gelebildiği için
    --    bütün Delphi satırları üzerinde - kendine bağlanma (döngü) hariç.
    with h as (
        select x.id, v.id as alt
          from public.urun_agaci_satir x
          left join public.urun_agaci v
                 on v.stok_id = x.bilesen_stok_id and v.varsayilan = 1 and v.durum = 0 and v.id <> x.agac_id
         where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETEDETAY')
    update public.urun_agaci_satir x
       set alt_agac_id = h.alt, tur = case when h.alt is null then 1 else 4 end
      from h
     where h.id = x.id and x.alt_agac_id is distinct from h.alt;
    get diagnostics v_alt = row_count;

    return jsonb_build_object('agac', v_a, 'mamulsuz', v_mamulsuz, 'kod_ekli', v_kodek, 'varsayilan', v_vars,
                              'satir', v_s, 'satir_silinen', v_ssil, 'bilesensiz', v_bilesensiz,
                              'cikti_satiri', v_cikti, 'operasyon', v_o, 'operasyon_silinen', v_osil,
                              'yari_mamul', v_alt, 'pasif', v_pasif);
end $$;

comment on function public.fn_aktar_recete(jsonb) is
    '1083: Delphi URETIMRECETE (+DETAY, +OPR) -> urun_agaci. Toplam olarak gelir; bkz. dosya başı.';

commit;
