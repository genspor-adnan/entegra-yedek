-- =============================================================================
--  1151  DELPHI AKTARIMI - DEMİRBAŞ: DELPHI'DE MÜKERRER DEMİRBAŞ NO
--
--  1148 kodu yalnız web'deki BAŞKA kayıtla çakışıyorsa boş bırakıyordu. BILIM'de
--  Delphi'nin kendisinde aynı DEMIRBASNO iki kez geçiyor (837 satır, 830 numara:
--  KM02, PC16, MOB057...) - ikisi birden aynı kodla gelince ux_demirbas_kod
--  bütün modülü düşürüyordu. Aynı numaralı Delphi satırlarından yalnız EN KÜÇÜK
--  id'li olan numarayı alır, diğerleri kodsuz gelir (adı ve seri no'su yerinde;
--  kod kartta verilir). Tekrar çalıştırmak güvenli (aynı satır aynı kodu alır).
-- =============================================================================

begin;

create or replace function public.fn_aktar_ek_demirbas()
returns jsonb language plpgsql as $$
declare v_e int := 0; v_g int := 0; v_kodsuz int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);
    create temp table if not exists _dmb on commit drop as select d.* from public.demirbas d with no data;
    truncate _dmb;
    insert into _dmb (aktarim_id, kod, ad, kategori, durum, seri_no, barkod, zimmet_taraf_id, sube_id, aciklama,
                      ekleme_tarihi)
    select s.id,
           case when coalesce(btrim(s.demirbasno), '') <> ''
                 -- Delphi'de aynı numaralı satırlardan yalnız ilki (en küçük id).
                 and s.id = min(s.id) over (partition by left(btrim(s.demirbasno), 40))
                 and not exists (select 1 from public.demirbas x where x.kod = left(btrim(s.demirbasno), 40)
                                   and not (x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DEMIRBAS' and x.aktarim_id = s.id))
                then left(btrim(s.demirbasno), 40) else '' end,
           left(coalesce(nullif(btrim(s.demirbasadi), ''), nullif(btrim(s.stokkodu), ''), 'Demirbaş ' || s.id), 200),
           4, 1, left(coalesce(s.serino, ''), 60), left(coalesce(s.barkod, ''), 40),
           public.fn_aktarim_kisi_id(s.rehberid), coalesce(public.fn_aktarim_sube(s.subeid), 1),
           left(coalesce(s.notlar, ''), 400),
           coalesce(s.eklemetarihi, timestamp '1901-01-01')
      from stg.demirbas s;
    select count(*) into v_kodsuz from _dmb d
      join stg.demirbas s on s.id = d.aktarim_id
     where d.kod = '' and coalesce(btrim(s.demirbasno), '') <> '';
    select eklenen, guncellenen into v_e, v_g from public.fn_aktarim_esitle('demirbas', 'DEMIRBAS', '_dmb',
        array['kod', 'ad', 'kategori', 'durum', 'seri_no', 'barkod', 'zimmet_taraf_id', 'sube_id', 'aciklama',
              'ekleme_tarihi']);
    return jsonb_build_object('eklenen', v_e, 'guncellenen', v_g, 'mukerrer_kodsuz', v_kodsuz);
end $$;

comment on function public.fn_aktar_ek_demirbas() is
    '1151: Delphi DEMIRBAS (stg) -> demirbas (kategori 4). Delphi''de mükerrer DEMIRBASNO: yalnız en küçük id kodu alır. İdempotent.';

commit;
