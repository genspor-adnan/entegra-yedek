-- ============================================================================
--  Gentegre AI — GÖNDEREN PRİMİ: KENDİ ADINA GÖNDERENE
--  825_gonderen_primi_kendi_adina.sql
--
--  Kullanıcı: *"kendi adına hasta gönderen doktor eğer tanımlıysa gönderen
--  primi alır"* · *"kurum adına hasta gönderen doktor prim almaz"*.
--
--  ============ AYRIM İSTEMİN KENDİSİNDE ==============================
--  Ölçüt kişinin kartı DEĞİL, istemin satırı: `istek_kurum_id` doluysa iş
--  KURUM adına gelmiştir. Kart ölçüt olsaydı, kuruma bağlı bir hekimin kendi
--  özel hastasını göndermesi de kurum işi sayılırdı - o hekim primi hak eder.
--
--  Yeni kural (tek "Gönderen" satırı, rol 1):
--    istek_kurum_id dolu          -> Gönderen = KURUM   (hekime prim yok)
--    istek_kurum_id boş + dış hekim-> Gönderen = HEKİM  (kendi adına)
--    iç personel                   -> İsteyen (rol 2), değişmedi
--
--  Eski davranış kurumu yalnız hekim BOŞKEN gönderen sayıyordu; hekim+kurum
--  birlikte geldiğinde prim hekime yazılıyordu - kullanıcının kuralının tersi.
--
--  ============ "TANIMLIYSA" ZATEN KAPI ===============================
--  Rol yazılması prim doğurmaz: `fn_prim_plan_satiri` eşleşen plan satırı
--  bulamazsa prim üretilmez. Yani "tanımlıysa alır" için ek koşul gerekmiyor;
--  tanımsız hekimde rol durur, prim doğmaz (hakedişte kimin gönderdiği yine
--  görünür).
-- ============================================================================
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
  'Radyoloji isteminden kalemin prim rollerini turetir (326/332/825): gonderen '
  'primi KENDI ADINA gonderen dis hekime, kurum adina gelen iste KURUMA yazilir; '
  'elle girilen rolu ezmez.';

-- --------------------------------------------------------------- dolgu ----
-- ESKI KURALLA YAZILMIS SATIRLAR: hekim + kurum birlikte gelen istemlerde
--   gonderen HEKIME yazilmisti. Yalniz OTOMATIK (kaynak = 2) satirlar
--   tazelenir; elle duzeltilmis rol yerinde kalir.
do $$
declare r record; v_sayi integer := 0;
begin
    for r in select i.id from public.radyoloji_istem i
              where i.istek_kurum_id is not null
                and i.istek_hekim_id is not null
                and coalesce(i.belge_satir_id, 0) <> 0
    loop
        perform public.fn_rad_rol_tazele(r.id);
        v_sayi := v_sayi + 1;
    end loop;
    raise notice '825 tamam: % istem yeniden rollendirildi (kurum adina gelen '
                 'iste gonderen primi KURUMA).', v_sayi;
end $$;
