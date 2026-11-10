-- =============================================================================
--  1288  RADYOLOJİ ROL TAZELEME TEMSİLCİ ROLÜNE DOKUNMAZ  (1287 tamamlayıcı)
--
--  fn_rad_rol_tazele (825) kalemin TÜM otomatik (kaynak 2) rollerini kendi hedef listesine göre siliyordu; 1287'nin
--  yazdığı rol 10 (Temsilci, belge.satici_id'den) istem kaydedilir kaydedilmez siliniyordu. Rol 10 bu fonksiyonun
--  sorumluluğu dışına alındı. Lab (828, yalnız rol 1) ve başvuru yapan (584, yalnız rol 4) zaten kendi rolünü siler.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_rad_rol_tazele(p_istem_id integer)
returns integer language plpgsql as $$
declare
  v_satir  integer;
  v_hedef  jsonb;
  v_sayac  integer := 0;
  r        record;
begin
    select i.belge_satir_id into v_satir
      from public.radyoloji_istem i where i.id = p_istem_id;

    -- Istem henuz ucretlendirilmemis (kalemi yok): prim bagi kurulamaz.
    if coalesce(v_satir, 0) = 0 then return 0; end if;

    select coalesce(jsonb_agg(jsonb_build_object('rol', h.rol, 'taraf', h.taraf_id)),
                    '[]'::jsonb)
      into v_hedef
      from (
        -- ISTEK HEKIMI:
        --   ic personel      -> Isteyen (2)
        --   dis hekim, KENDI ADINA (istek_kurum_id bos) -> Gonderen (1)
        --   dis hekim, KURUM ADINA -> hic rol yazilmaz (825): prim kuruma ait
        select 2 as rol, i.istek_hekim_id as taraf_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_hekim_id is not null
           and not exists (select 1 from public.taraf_personel p
                            where p.id = i.istek_hekim_id and p.dis_hekim = 1)
        union all
        select 1, i.istek_hekim_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_hekim_id is not null
           and i.istek_kurum_id is null
           and exists (select 1 from public.taraf_personel p
                        where p.id = i.istek_hekim_id and p.dis_hekim = 1)
        union all
        -- KURUM ADINA GELEN IS: gonderen kurumdur. Hekim de yazilsaydi ayni
        --   sevk icin iki gonderen primi dogardi.
        select 1, i.istek_kurum_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_kurum_id is not null
        union all
        select 9, i.tekniker_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.tekniker_id is not null
        union all
        select 5, rp.yazan_id
          from public.radyoloji_rapor rp
         where rp.istem_id = p_istem_id and rp.ust_rapor_id is null
           and rp.yazan_id is not null
        union all
        select 6, rp.onaylayan_id
          from public.radyoloji_rapor rp
         where rp.istem_id = p_istem_id and rp.ust_rapor_id is null
           and rp.onaylayan_id is not null
      ) h;

    -- ELLE girilmis rol DOKUNULMAZ (kaynak = 1).
    delete from public.belge_satir_rol bsr
     where bsr.belge_satir_id = v_satir
       and bsr.kaynak = 2
       -- TEMSİLCİ (rol 10) BU FONKSİYONUN DEĞİL (1288): belge.satici_id'den fn_temsilci_rolu_tazele yazar.
       and bsr.rol <> 10
       and not exists (select 1
                         from jsonb_to_recordset(v_hedef) as x(rol smallint, taraf integer)
                        where x.rol = bsr.rol and x.taraf = bsr.taraf_id)
       and not exists (select 1 from public.belge_satir_rol e
                        where e.belge_satir_id = v_satir and e.rol = bsr.rol
                          and e.kaynak = 1);

    insert into public.belge_satir_rol (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak)
    select v_satir, x.rol, x.taraf, 100, 2
      from jsonb_to_recordset(v_hedef) as x(rol smallint, taraf integer)
     where not exists (select 1 from public.belge_satir_rol e
                        where e.belge_satir_id = v_satir and e.rol = x.rol
                          and e.kaynak = 1)
    on conflict (belge_satir_id, rol, taraf_id) do nothing;

    get diagnostics v_sayac = row_count;

    for r in select d.id from public.kasa_islem_dagitim d
              where d.belge_satir_id = v_satir
    loop
        perform public.fn_prim_uret(r.id);
    end loop;
    perform public.fn_prim_uret_belge(v_satir);

    return v_sayac;
end $$;

comment on function public.fn_rad_rol_tazele is
  'Radyoloji isteminden kalemin prim rollerini turetir (326/332/825; 1288 rol 10 Temsilci haric): gonderen '
  'primi KENDI ADINA gonderen dis hekime, kurum adina gelen iste KURUMA yazilir; elle girilen rolu ezmez.';

do $$ begin raise notice '1288 tamam: fn_rad_rol_tazele rol 10 Temsilci satirlarina dokunmaz.'; end $$;
