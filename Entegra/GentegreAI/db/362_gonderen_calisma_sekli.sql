-- ============================================================================
--  362 - DIS HEKIMDE "GONDEREN" ISARETI CALISMA SEKLINDE
--
--  Kullanici: "dış doktorlardan prim rolleri sekmesini kaldır.. onun yerine
--  çalışma şekli combosunu kullan ve oraya 'Gönderen' ekle. yarı/tam zamanlı
--  seçili ise hasta 'göndermiyor', ama 'Gönderen' seçili ise hasta gönderiyor
--  demektir."
--
--  Dis hekimin ZATEN tek bir prim rolu var (Gonderen, 361) - onun icin ayri bir
--  rol gridi ikinci bir yerde ayni bilgiyi sormaktan baska ise yaramiyordu.
--  Artik isaret `taraf_personel.calisma_sekli`:
--      1 Tam Zamanli · 2 Yari Zamanli -> hasta GONDERMIYOR (prim adayi degil)
--      3 Gonderen                     -> hasta GONDERIYOR (rol 1 adayi)
--
--  IC PERSONEL degismedi: onlarin rolleri kartlarindaki "Prim Rolleri"
--  gridinde (taraf_prim_rol) durur - bir kisi hem isteyen hem yapan hem
--  uygulayan olabilir.
-- ============================================================================

-- Dis hekimlerde ROL SATIRI ARTIK TUTULMAZ: kaynak calisma_sekli. Once
-- 361'de acilan satirlardan "Gonderen" olanlari calisma seklinde isaretle.
update public.taraf_personel p
   set calisma_sekli = 3
  from public.taraf_prim_rol r
 where r.taraf_id = p.id and r.rol = 1
   and p.dis_hekim = 1
   and coalesce(p.calisma_sekli, 0) <> 3;

delete from public.taraf_prim_rol r
 using public.taraf_personel p
 where p.id = r.taraf_id and p.dis_hekim = 1;

-- Kural sikilastirildi: dis hekime prim rol SATIRI girilemez (isaret calisma
-- seklinde). Ic personelde kural aynen kaldi.
create or replace function public.tg_taraf_prim_rol_dogrula()
returns trigger
language plpgsql
as $$
declare
    v_personel  smallint;
    v_dis       smallint;
begin
    select t.personel, coalesce(p.dis_hekim, 0)
      into v_personel, v_dis
      from public.taraf t
      left join public.taraf_personel p on p.id = t.id
     where t.id = new.taraf_id;

    if coalesce(v_personel, 0) <> 1 then
        raise exception 'Prim rolü yalnız personele / hekime verilir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    if v_dis = 1 then
        raise exception 'Dış hekimde prim rolü ayrı girilmez: kartındaki Çalışma Şekli "Gönderen" olmalıdır (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

-- ================================================================ adaylar ==
-- Ic personel  -> taraf_prim_rol satirlari
-- Dis hekim    -> calisma_sekli = 3 ("Gönderen") ise rol 1 adayi
create or replace view public.v_prim_rol_aday as
select r.taraf_id                as id,
       t.unvan                   as ad,
       r.rol,
       r.varsayilan,
       0::smallint               as dis_mi,
       coalesce(p.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  left join public.taraf_personel p on p.id = r.taraf_id
 where coalesce(p.dis_hekim, 0) = 0
union all
select t.id                      as id,
       t.unvan                   as ad,
       1::smallint               as rol,          -- Gönderen
       1::smallint               as varsayilan,
       1::smallint               as dis_mi,
       coalesce(p.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where p.dis_hekim = 1 and coalesce(p.calisma_sekli, 0) = 3;

comment on view public.v_prim_rol_aday is
  'Prim rol adaylari (361/362): ic personel taraf_prim_rol''den, DIS HEKIM ise '
  'calisma_sekli = 3 ("Gönderen") isaretinden gelir - tam/yari zamanli dis hekim '
  'hasta gondermiyor sayilir ve listeye girmez.';

-- ========================================== plan satiri icin aday sayaci ===
-- Prim plani ekrani "bu rolde kac kisi isaretli" bilgisini gostersin: rol
-- secilip kimse isaretlenmediyse plan satiri hic hakedis uretmez ve bu ancak
-- ay sonunda fark edilirdi.
create or replace function public.fn_prim_rol_aday_sayisi(p_rol smallint)
returns integer
language sql
stable
as $$
    select count(*)::integer
      from public.v_prim_rol_aday a
     where a.rol = p_rol and a.durum = 1;
$$;

comment on function public.fn_prim_rol_aday_sayisi(smallint) is
  'Bu rolde isaretli kisi sayisi (362) - prim plani ekraninda uyari icin.';

-- ================================================ prim plani rol lookup ====
-- Prim plani satirindaki ROL combosu artik ISARETLERLE uyumlu: her rolun
-- yaninda o rolde kac kisi isaretli oldugu yazar. Rol secilip kimse
-- isaretlenmediyse plan satiri hic hakedis uretmez ve bu ancak ay sonunda fark
-- edilirdi - kullanici combodan gorsun.
--
-- Kurum tipine (359) gore ONE CIKAN rol en ustte durur: lab/goruntuleme
-- merkezinde "Gönderen", digerlerinde "Yapan".
create or replace view public.v_prim_rol_lookup as
with roller(id, ad, sira) as (
    values (1::smallint, 'Gönderen'::varchar, 1), (2, 'İsteyen', 2),
           (3, 'Uygulayan', 3), (4, 'Yapan', 4), (5, 'Raporlayan', 5),
           (6, 'Onaylayan', 6), (7, 'Anestezi', 7), (8, 'Asistan', 8),
           (9, 'Teknisyen', 9)
)
select r.id,
       (r.ad || case when public.fn_prim_rol_aday_sayisi(r.id::smallint) = 0
                     then ' — kişi işaretlenmemiş'
                     else ' (' || public.fn_prim_rol_aday_sayisi(r.id::smallint)::text || ' kişi)'
                end)::varchar as ad,
       1::smallint as aktif,
       -- Kurum tipinin varsayilan rolu once, sonra kisi isaretlenmis roller.
       (case when r.id::smallint = public.fn_basvuru_hekim_rolu() then 0 else 1 end) * 100
         + case when public.fn_prim_rol_aday_sayisi(r.id::smallint) > 0 then 0 else 50 end
         + r.sira as sira
  from roller r;

comment on view public.v_prim_rol_lookup is
  'Prim plani rol combosu (362): rol adinin yaninda o rolde isaretli kisi '
  'sayisi; kurum tipinin varsayilan rolu ustte.';

-- Combo metni netlestirildi (363 bulgusu): sayac YALNIZ AKTIF kisileri sayar
-- (pasif personel combolarda cikmamali). "kişi işaretlenmemiş" yazisi, isaret
-- VAR ama kisi PASIF oldugunda yaniltiyordu.
create or replace view public.v_prim_rol_lookup as
with roller(id, ad, sira) as (
    values (1::smallint, 'Gönderen'::varchar, 1), (2, 'İsteyen', 2),
           (3, 'Uygulayan', 3), (4, 'Yapan', 4), (5, 'Raporlayan', 5),
           (6, 'Onaylayan', 6), (7, 'Anestezi', 7), (8, 'Asistan', 8),
           (9, 'Teknisyen', 9)
)
select r.id,
       (r.ad || case when public.fn_prim_rol_aday_sayisi(r.id::smallint) = 0
                     then ' — aktif kişi işaretlenmemiş'
                     else ' (' || public.fn_prim_rol_aday_sayisi(r.id::smallint)::text
                          || ' kişi)'
                end)::varchar as ad,
       1::smallint as aktif,
       (case when r.id::smallint = public.fn_basvuru_hekim_rolu() then 0 else 1 end) * 100
         + case when public.fn_prim_rol_aday_sayisi(r.id::smallint) > 0 then 0 else 50 end
         + r.sira as sira
  from roller r;
