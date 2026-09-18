-- ============================================================================
--  Gentegre AI — LAB İSTEMİNDE GÖNDEREN KURUM + "DIŞ HEKİM" KAPISI
--  827_lab_istem_kurumu.sql
--
--  826 radyolojide kurumu hekimin kartından (`taraf.bag_id`) türetti. Lab
--  tarafında aynı boşluk duruyordu: `lab_istem.dis_kurum_id` yalnız ekrandan
--  geliyor (146 istemin 4'ünde dolu). Kurum boş kalınca:
--    · kurumun portalı kendi hekiminin istemini görmüyor (kapsam
--      `i.dis_kurum_id = {kullanici}`),
--    · iş kuruma faturalanacakken hastaya/serbest kalıyor.
--
--  ============ AYNI KURAL, İKİ MODÜL =================================
--  INSERT'te kurum boşsa doldurulur; UPDATE'te yalnız HEKİM DEĞİŞTİĞİNDE ve
--  kurum elle seçilmemişse yeniden türetilir. Elle boşaltılan kurum geri
--  doldurulmaz - "hekim kendi adına gönderdi" demenin tek yolu odur.
--
--  ============ DIŞ HEKİM KAPISI (826'yı da kapsar) ===================
--  `taraf.bag_id` yalnız dış hekimin değil, KİŞİ/personel kartının da alanı
--  ("Bağlı Cari"). Bir gün iç personelin kartına bağlı cari yazılırsa 826'nın
--  radyoloji tetiği o kişinin istemine kurum yazar ve 825 gereği gönderen
--  primini oraya taşırdı. Bu veritabanında öyle bir satır yok (0/75) ama kapı
--  bedava: her iki tetik de artık `taraf_personel.dis_hekim = 1` arıyor.
--  Bu yüzden 826'daki `tg_rad_istem_kurumu` BURADA yeniden tanımlanır -
--  yürürlükteki tanım bu dosyadır (GUNCEL.md).
--
--  ============ LAB PRİMİ AYRI KARAR ==================================
--  Lab kalemine bugün HİÇBİR prim rolü yazılmıyor (rol yazan tek yer
--  radyoloji, muayene ve teleradyoloji). 825'in "gönderen primi" kuralını lab
--  kalemine de kurmak yeni prim doğurur; bu para kararıdır ve istenmeden
--  yapılmaz. Bu göç yalnız KURUM BAĞINI kurar.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------- ortak: bağlı kurum ----
-- Kişinin DIŞ HEKİM olarak bağlı olduğu kurum; değilse null.
create or replace function public.fn_dis_hekim_kurumu(p_taraf_id integer)
returns integer language sql stable as $$
    select t.bag_id
      from public.taraf t
      join public.taraf_personel p on p.id = t.id
     where t.id = p_taraf_id and coalesce(p.dis_hekim, 0) = 1;
$$;

comment on function public.fn_dis_hekim_kurumu is
  'Dis hekimin bagli oldugu kurum (taraf.bag_id); ic personelde null (827).';

-- ------------------------------------------------------- radyoloji (826) ----
create or replace function public.tg_rad_istem_kurumu()
returns trigger language plpgsql as $$
declare
  v_yeni_bag integer;
  v_eski_bag integer;
begin
    if new.istek_hekim_id is null then return new; end if;

    v_yeni_bag := public.fn_dis_hekim_kurumu(new.istek_hekim_id);

    if tg_op = 'INSERT' then
        if new.istek_kurum_id is null then
            new.istek_kurum_id := v_yeni_bag;
        end if;
        return new;
    end if;

    if new.istek_hekim_id is not distinct from old.istek_hekim_id then
        return new;
    end if;
    if new.istek_kurum_id is distinct from old.istek_kurum_id then
        return new;
    end if;

    v_eski_bag := public.fn_dis_hekim_kurumu(old.istek_hekim_id);
    if old.istek_kurum_id is null or old.istek_kurum_id = v_eski_bag then
        new.istek_kurum_id := v_yeni_bag;
    end if;
    return new;
end $$;

comment on function public.tg_rad_istem_kurumu is
  'Istem kurumu bos ise DIS HEKIMIN bagli kurumundan doldurulur (826/827); '
  'elle secilmis ya da bosaltilmis kuruma dokunmaz.';

-- ------------------------------------------------------------- lab ----
create or replace function public.tg_lab_istem_kurumu()
returns trigger language plpgsql as $$
declare
  v_yeni_bag integer;
  v_eski_bag integer;
begin
    if new.personel_id is null then return new; end if;

    v_yeni_bag := public.fn_dis_hekim_kurumu(new.personel_id);

    if tg_op = 'INSERT' then
        if new.dis_kurum_id is null then
            new.dis_kurum_id := v_yeni_bag;
        end if;
        return new;
    end if;

    -- Hekim degismediyse karisma; kurum bu islemde elle degistiyse o secim
    --   gecerlidir (bosaltma dahil).
    if new.personel_id is not distinct from old.personel_id then
        return new;
    end if;
    if new.dis_kurum_id is distinct from old.dis_kurum_id then
        return new;
    end if;

    v_eski_bag := public.fn_dis_hekim_kurumu(old.personel_id);
    if old.dis_kurum_id is null or old.dis_kurum_id = v_eski_bag then
        new.dis_kurum_id := v_yeni_bag;
    end if;
    return new;
end $$;

comment on function public.tg_lab_istem_kurumu is
  'Lab isteminin dis kurumu bos ise gonderen dis hekimin bagli kurumundan '
  'doldurulur (827); elle secilmis ya da bosaltilmis kuruma dokunmaz.';

drop trigger if exists tg_lab_istem_kurumu on public.lab_istem;
create trigger tg_lab_istem_kurumu
before insert or update of personel_id, dis_kurum_id on public.lab_istem
for each row execute function public.tg_lab_istem_kurumu();

-- GERİ DOLGU YOK: geçmiş istemin kurumunu sonradan yazmak faturasını ve
--   kurumun gördüğü listeyi geriye dönük değiştirir.
do $$
declare v_acik integer;
begin
    select count(*) into v_acik
      from public.lab_istem i
     where i.dis_kurum_id is null
       and public.fn_dis_hekim_kurumu(i.personel_id) is not null;
    raise notice '827 tamam: lab isteminde kurum dis hekimin bagli kurumundan doluyor. '
                 'GECMISTE kurumsuz kalan % istem BILEREK degistirilmedi.', v_acik;
end $$;
