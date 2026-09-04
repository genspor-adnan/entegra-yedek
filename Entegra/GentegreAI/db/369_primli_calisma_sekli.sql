-- ============================================================================
--  369 - CALISMA SEKLI 3: "GONDEREN" -> "PRIMLI"
--
--  Kullanici: "personel kartinda calisma sekli combosunda Gönderen var onun
--  yerine Primli rename.. Bu secilirse personel kartinda Prim Rolleri sekmesi
--  gorunsun.. Dis doktorda ise bu secilince Gönderen olarak primden
--  yararlansin".
--
--  ISARETIN ANLAMI GENISLEDI. 362'de kod 3 yalnizca DIS HEKIM icin vardi ve
--  "hasta gonderiyor" demekti. Artik iki kartta da ayni soruyu soruyor:
--  BU KISI PRIM ALIYOR MU?
--      IC PERSONEL -> evet ise kartinda "Prim Rolleri" sekmesi acilir ve
--                     hangi rollerde prim aldigi orada isaretlenir (isteyen /
--                     yapan / uygulayan... bir kisi birkacini birden alabilir)
--      DIS HEKIM   -> evet ise tek rolu vardir: "Gönderen" (rol 1). Ona ayrica
--                     rol sorulmaz - 362'deki kural aynen surer.
--
--  IC PERSONELDE DE ISARET ARANIR HALE GELDI: rol satiri var ama kisi "Primli"
--  degilse artik aday sayilmaz. Yoksa isaret kaldirilinca satirlar goze
--  gorunmez olur (sekme kapanir) ama kisi prim almaya devam ederdi - sessiz ve
--  ancak hakedis ekraninda fark edilen bir hata.
--
--  VERI GOCU ZORUNLU: bugun rol satiri olan herkes ZATEN prim aliyor. Isaret
--  konmazsa (a) kartlarindaki sekme kaybolur, (b) aday listesinden duserler.
--  Bu yuzden rol satiri olan personel "Primli" olarak isaretlenir - tahmin
--  degil, kaydin kendi kanitiyla.
-- ============================================================================

-- ============================================================== veri gocu ==
-- YALNIZ rol satiri OLAN ic personel. Dis hekimlerde isaret 362'de zaten
-- konuldu ve onlarin rol satiri yok.
update public.taraf_personel p
   set calisma_sekli = 3
 where coalesce(p.dis_hekim, 0) = 0
   and coalesce(p.calisma_sekli, 0) <> 3
   and exists (select 1 from public.taraf_prim_rol r where r.taraf_id = p.id);

-- Rol satiri olup taraf_personel kaydi HIC OLMAYAN kisi kalmasin: satir 1:1
-- uzanti, yoksa isaret yazilacak yer de yok (kart acilinca olusur ama aday
-- listesi bugun bozulur).
insert into public.taraf_personel (id, sube_id, calisma_sekli)
select distinct r.taraf_id, coalesce(t.sube_id, 1), 3
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
 where not exists (select 1 from public.taraf_personel p where p.id = r.taraf_id);

-- ================================================================= kural ===
-- Dis hekime rol SATIRI girilemez (362) - mesajdaki combo adi guncellendi.
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
        raise exception 'Dış hekimde prim rolü ayrı girilmez: kartındaki Çalışma Şekli "Primli" olmalıdır - dış hekimin tek rolü "Gönderen"dir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

-- ================================================================ adaylar ==
-- Ic personel -> "Primli" isaretli VE taraf_prim_rol satiri olanlar
-- Dis hekim   -> "Primli" isaretli (tek rol: Gönderen)
create or replace view public.v_prim_rol_aday as
select r.taraf_id                as id,
       t.unvan                   as ad,
       r.rol,
       r.varsayilan,
       0::smallint               as dis_mi,
       coalesce(t.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  join public.taraf_personel p on p.id = r.taraf_id
 where coalesce(p.dis_hekim, 0) = 0
   and coalesce(p.calisma_sekli, 0) = 3
union all
select t.id                      as id,
       t.unvan                   as ad,
       1::smallint               as rol,          -- Gönderen
       1::smallint               as varsayilan,
       1::smallint               as dis_mi,
       coalesce(t.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where p.dis_hekim = 1 and coalesce(p.calisma_sekli, 0) = 3;

comment on view public.v_prim_rol_aday is
  'Prim rol adaylari (361/362/367/369): isaret her iki kartta da '
  'taraf_personel.calisma_sekli = 3 ("Primli"). Ic personelde ayrica '
  'taraf_prim_rol satiri hangi rollerde prim aldigini soyler; DIS HEKIMIN tek '
  'rolu "Gönderen"dir, ayrica sorulmaz. Bolum taraf.departman''dan gelir (251).';

-- Prim plani rol combosundaki aciklama metni de isaret adiyla uyumlu olsun.
comment on function public.fn_prim_rol_aday_sayisi(smallint) is
  'Bu rolde isaretli AKTIF kisi sayisi (362/369) - prim plani ekraninda uyari '
  'icin. Kisi "Primli" degilse sayilmaz.';
