-- 1315 - Teletıp kuyruğu dış kurumun teleradyoloji işini almaz
--
-- Kullanıcı 12.11.2026: Radyoloji › Teleradyoloji menüsü incelenirken bulunan çakışma ("yap"). Teletıp tetikleri
-- (1302 istem → ORM, 1309 rapor → ORU, 1310 çalışma → KOS, 1314 KOS → doz) bütün radyoloji istemlerine bakıyordu.
-- Dış kurumun gönderip bizim radyologumuzun okuduğu iş (telerad_istek.yon = 1) de aynı radyoloji_istem /
-- radyoloji_rapor tablolarını kullanır. Teletıp açık kurumda böyle bir iş onaylanınca:
--   * istem ve rapor Bakanlık'a BİZİM kurum kodlarımızla gidebilirdi (hasta ve çekim karşı kurumun), ve
--   * rapor Bakanlık'a iki kez gidebilirdi: Teleradyoloji › Teslim Kuyruğu hedef 2 (Bakanlık, 814) + Teletıp ORU.
-- Kural: dış kurum işinin Bakanlık bildirimi YALNIZ Teslim Kuyruğu'ndan. Bizim istemimizi dışarıya okutmak
-- (yon = 2) bizim istemimizdir - Teletıp'a gitmeye devam eder.
--
--   * fn_teletip_dis_is(istem): istem dış kurumun işi mi - üç bağdan biri yeter (radyoloji_istem.telerad_istek_id,
--     telerad_istek.radyoloji_istem_id, telerad_istek.rapor_id → rapor.istem_id).
--   * tg_teletip_gonderim_dis_is (BEFORE INSERT): dış işin satırı hiç açılmaz - bütün tetikler tek yerden süzülür.
--   * Bağ sonradan kurulursa (iş okunurken istem / rapor bağlanır) o istemin bekleyen satırları (0, 3, 5) "atlandı" (4).
--     Gönderilmiş satır (1) geri alınamaz; dokunulmaz.
--   * İşçi (TeletipOrmServisi.DeneAsync) göndermeden hemen önce aynı kontrolü yapar.
--   * Mevcut bekleyen dış iş satırları da atlanır (raporlanır).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_teletip_dis_is(p_istem_id integer)
returns boolean language sql stable as $$
  select p_istem_id is not null and (
         exists (select 1 from public.radyoloji_istem i join public.telerad_istek t on t.id = i.telerad_istek_id
                  where i.id = p_istem_id and t.yon = 1)
      or exists (select 1 from public.telerad_istek t where t.radyoloji_istem_id = p_istem_id and t.yon = 1)
      or exists (select 1 from public.telerad_istek t join public.radyoloji_rapor r on r.id = t.rapor_id
                  where r.istem_id = p_istem_id and t.yon = 1))
$$;
comment on function public.fn_teletip_dis_is(integer) is
  '1315: istem dış kurumun teleradyoloji işi mi (telerad_istek.yon = 1) - Teletıp kuyruğu bu işi almaz; Bakanlık '
  'bildirimi Teleradyoloji Teslim Kuyruğu''ndan (hedef 2).';

create or replace function public.tg_teletip_gonderim_dis_is()
returns trigger language plpgsql as $$
begin
  if public.fn_teletip_dis_is(new.istem_id) then return null; end if;
  return new;
end $$;
drop trigger if exists tg_teletip_gonderim_dis_is on public.teletip_gonderim;
create trigger tg_teletip_gonderim_dis_is
  before insert on public.teletip_gonderim
  for each row execute function public.tg_teletip_gonderim_dis_is();

create or replace function public.fn_teletip_dis_is_atla(p_istem_id integer)
returns integer language sql as $$
  with u as (
    update public.teletip_gonderim
       set durum = 4,
           hata_metni = 'Dış kurumun teleradyoloji işi - Bakanlık bildirimi Teleradyoloji › Teslim Kuyruğu''ndan (1315).'
     where istem_id = p_istem_id and durum in (0, 3, 5)
    returning 1)
  select count(*)::int from u
$$;

-- Bağ telerad_istek tarafında kurulunca / değişince.
create or replace function public.tg_telerad_istek_teletip_atla()
returns trigger language plpgsql as $$
declare v_istem integer;
begin
  if new.yon <> 1 then return new; end if;
  if new.radyoloji_istem_id is not null then perform public.fn_teletip_dis_is_atla(new.radyoloji_istem_id); end if;
  if new.rapor_id is not null then
    select r.istem_id into v_istem from public.radyoloji_rapor r where r.id = new.rapor_id;
    if v_istem is not null then perform public.fn_teletip_dis_is_atla(v_istem); end if;
  end if;
  return new;
end $$;
drop trigger if exists tg_telerad_istek_teletip_atla on public.telerad_istek;
create trigger tg_telerad_istek_teletip_atla
  after insert or update of radyoloji_istem_id, rapor_id, yon on public.telerad_istek
  for each row execute function public.tg_telerad_istek_teletip_atla();

-- Bağ radyoloji_istem tarafında kurulunca.
create or replace function public.tg_radyoloji_istem_telerad_atla()
returns trigger language plpgsql as $$
begin
  if new.telerad_istek_id is not null and public.fn_teletip_dis_is(new.id) then
    perform public.fn_teletip_dis_is_atla(new.id);
  end if;
  return new;
end $$;
drop trigger if exists tg_radyoloji_istem_telerad_atla on public.radyoloji_istem;
create trigger tg_radyoloji_istem_telerad_atla
  after update of telerad_istek_id on public.radyoloji_istem
  for each row execute function public.tg_radyoloji_istem_telerad_atla();

-- Mevcut veride bekleyen dış iş satırları (gönderilmiş olanlar raporlanır, dokunulmaz).
do $$
declare v_atlanan int; v_gitmis int;
begin
  select count(*) into v_gitmis from public.teletip_gonderim g where g.durum = 1 and public.fn_teletip_dis_is(g.istem_id);
  with u as (
    update public.teletip_gonderim g
       set durum = 4,
           hata_metni = 'Dış kurumun teleradyoloji işi - Bakanlık bildirimi Teleradyoloji › Teslim Kuyruğu''ndan (1315).'
     where g.durum in (0, 3, 5) and public.fn_teletip_dis_is(g.istem_id)
    returning 1)
  select count(*) into v_atlanan from u;
  raise notice '1315: bekleyen dış iş satırı atlandı: %, daha önce GİTMİŞ dış iş satırı (dokunulmadı): %', v_atlanan, v_gitmis;
end $$;

commit;
