-- =====================================================================
--  950_ik_izin_saatli_istisna_izinsiz.sql
--  İZİN TEK YERDEN: İK İZNİNE SAAT, ÇALIŞMA İSTİSNASINDAN "İZİN" TÜRÜ KALKAR
--  (kullanıcı: "izin türünü kaldır sadece istisna olsun, İK iznine saat ekle").
--
--  NEDEN: doktorun izni iki yere girilebiliyordu - İK › İzinler (bakiye,
--  bordro, onay) ve Randevu › İzin & İstisnalar'ın "İzin" türü (yalnız plan).
--  İkincisi bakiyeden düşmüyor, İK'ya da girilirse aynı izin iki kez
--  yazılıyordu. Artık izin YALNIZ İK'dan; istisna kongre / saat değişikliği /
--  ek mesai / kapalı içindir.
--
--  1) personel_izin: `saat_bas` / `saat_bit` (ikisi birden ya da hiç; saatli
--     izin TEK GÜNLÜKTÜR). `gun` numeric(5,1) oldu - yarım gün 0,5.
--     Bağlı görünümler (v_personel_izin, v_personel_izin_bakiye) tanımları
--     saklanıp düşürülür ve AYNEN geri kurulur.
--  2) GÜN TETİKTE (tg_personel_izin_gun): kart yolundan açılan izinde gün
--     hiç hesaplanmıyordu (gun = 0, bakiyeden düşmüyordu). Artık her yazımda
--     fn_izin_gun ile; saatli izinde süre <= 4,5 saat 0,5 gün, üstü 1 gün.
--     VERİ ONARIMI: gün 0 kalmış, tarihleri dolu, iptal / red olmayan izinler
--     yeniden hesaplanır (önce yedek_950_personel_izin'e alınır).
--  3) PLAN: saatli İK izni yalnız o saatleri kapatır (948'in kırpma kuralı).
--  4) RANDEVU TETİKLERİ: "izinli mi" artık SAATE bakar
--     (fn_hekim_izin_cakisan): sabah izinli doktora öğleden sonra randevu
--     verilebilir; mesai dışı kontrolü yalnız izinle ÇAKIŞAN randevuda izin
--     tetiğine bırakılır.
--  5) İSTİSNA "İZİN" TÜRÜ: kod değeri pasif; yeni kayıt / türü İzin'e
--     çevirme reddedilir. Eski İzin istisnaları silinmez, plana etkileri sürer.
--
--  Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------ 1) kolonlar
alter table public.personel_izin add column if not exists saat_bas varchar(5);
alter table public.personel_izin add column if not exists saat_bit varchar(5);

do $$
declare
    v_def1 text; v_def2 text;
begin
    if (select data_type from information_schema.columns
         where table_schema = 'public' and table_name = 'personel_izin' and column_name = 'gun') <> 'numeric' then
        v_def1 := pg_get_viewdef('public.v_personel_izin'::regclass, true);
        v_def2 := pg_get_viewdef('public.v_personel_izin_bakiye'::regclass, true);
        drop view public.v_personel_izin_bakiye;
        drop view public.v_personel_izin;
        alter table public.personel_izin alter column gun type numeric(5,1);
        execute 'create view public.v_personel_izin as ' || v_def1;
        execute 'create view public.v_personel_izin_bakiye as ' || v_def2;
        raise notice '950: personel_izin.gun numeric(5,1), görünümler geri kuruldu.';
    end if;
end $$;

alter table public.personel_izin drop constraint if exists ck_personel_izin_saat;
alter table public.personel_izin add constraint ck_personel_izin_saat check (
    (nullif(saat_bas, '') is null and nullif(saat_bit, '') is null)
    or (nullif(saat_bas, '') is not null and nullif(saat_bit, '') is not null and saat_bas < saat_bit
        and baslangic_tarihi = bitis_tarihi));

comment on column public.personel_izin.saat_bas is
  '950: saatli izin başlangıcı (HH:MM). Boşsa gün boyu; saatliyse izin tek günlüktür.';

-- --------------------------------------------------------- 2) gün tetiği
create or replace function public.tg_personel_izin_gun()
returns trigger
language plpgsql
as $$
declare
    v_dk integer;
begin
    if new.baslangic_tarihi is null or new.bitis_tarihi is null then return new; end if;
    if nullif(new.saat_bas, '') is not null and nullif(new.saat_bit, '') is not null then
        v_dk := (extract(epoch from (new.saat_bit::time - new.saat_bas::time)) / 60)::int;
        new.gun := case when v_dk <= 270 then 0.5 else 1 end;
    else
        new.gun := public.fn_izin_gun(new.baslangic_tarihi, new.bitis_tarihi,
                                      coalesce(new.is_gunu, 0)::smallint, new.sube_id);
    end if;
    return new;
end $$;

drop trigger if exists trg_personel_izin_gun on public.personel_izin;
create trigger trg_personel_izin_gun
    before insert or update of baslangic_tarihi, bitis_tarihi, is_gunu, saat_bas, saat_bit, sube_id
    on public.personel_izin
    for each row execute function public.tg_personel_izin_gun();

-- VERİ ONARIMI: yalnız gün 0 kalmış, tarihleri dolu, iptal / red olmayan satırlar.
create table if not exists public.yedek_950_personel_izin as
select i.*, now() as yedek_tarihi from public.personel_izin i where false;

with hedef as (
    select i.id from public.personel_izin i
     where coalesce(i.gun, 0) = 0 and i.baslangic_tarihi is not null and i.bitis_tarihi is not null
       and i.durum not in (3, 4)
       and not exists (select 1 from public.yedek_950_personel_izin y where y.id = i.id)
), yedek as (
    insert into public.yedek_950_personel_izin
    select i.*, now() from public.personel_izin i join hedef h on h.id = i.id
    returning id
)
update public.personel_izin i
   set gun = public.fn_izin_gun(i.baslangic_tarihi, i.bitis_tarihi, coalesce(i.is_gunu, 0)::smallint, i.sube_id)
  from hedef h where h.id = i.id;

-- ------------------------------------------------------------- 3) plan


-- -------------------------------------------- 4) saate bakan izin kontrolü
create or replace function public.fn_hekim_izin_cakisan(
    p_hekim integer, p_gun date, p_bas time, p_bit time)
returns table (izin_id integer, tur smallint, baslangic date, bitis date, saat_bas varchar, saat_bit varchar)
language sql stable as $$
    select i.id, i.tur, i.baslangic_tarihi, i.bitis_tarihi, nullif(i.saat_bas, '')::varchar, nullif(i.saat_bit, '')::varchar
      from public.personel_izin i
     where i.taraf_id = p_hekim
       and i.durum = 2
       and p_gun between i.baslangic_tarihi and i.bitis_tarihi
       and (nullif(i.saat_bas, '') is null
            or (p_bas < i.saat_bit::time and p_bit > i.saat_bas::time))
     order by i.id
     limit 1
$$;

comment on function public.fn_hekim_izin_cakisan(integer, date, time, time) is
  '950: randevu saatiyle ÇAKIŞAN onaylı İK izni (gün boyu izin her saatle çakışır).';

create or replace function public.tg_randevu_izin_kontrol()
returns trigger
language plpgsql
as $$
declare
  v_izin   record;
  v_ayar   text;
  v_hekim  text;
  v_yerel  timestamp;
  v_bas    time;
  v_bit    time;
begin
  if coalesce(new.durum, 1) in (3, 4) then return new; end if;
  if new.hekim_id is null then return new; end if;

  select new.baslangic at time zone coalesce(nullif(s.zaman_dilimi, ''), 'Europe/Istanbul') into v_yerel
    from public.sube s where s.id = new.sube_id;
  v_yerel := coalesce(v_yerel, new.baslangic at time zone 'Europe/Istanbul');
  v_bas := v_yerel::time;
  v_bit := v_bas + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1)::int);

  select * into v_izin from public.fn_hekim_izin_cakisan(new.hekim_id, v_yerel::date, v_bas, v_bit);
  if not found then return new; end if;

  select coalesce(nullif(deger, ''), '0') into v_ayar
    from public.referans where anahtar = 'randevu.izinli_hekim';
  if coalesce(v_ayar, '0') = '1' then
    raise warning 'Hekim % tarihinde izinli (izin #%).', v_yerel::date, v_izin.izin_id;
    return new;
  end if;

  select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Hekim') into v_hekim
    from public.taraf where id = new.hekim_id;

  if v_izin.saat_bas is not null then
    raise exception '% % tarihinde % - % arası izinli. İzinli saate randevu yazılamaz; başka saat ya da başka hekim seçin.',
      v_hekim, to_char(v_yerel::date, 'DD.MM.YYYY'), v_izin.saat_bas, v_izin.saat_bit
      using errcode = 'GK422';
  end if;
  raise exception '% % tarihinde izinli (% - %). İzinli hekime randevu yazılamaz; izni iptal edin ya da başka hekim seçin.',
    v_hekim, to_char(v_yerel::date, 'DD.MM.YYYY'),
    to_char(v_izin.baslangic, 'DD.MM.YYYY'), to_char(v_izin.bitis, 'DD.MM.YYYY')
    using errcode = 'GK422';
end $$;

create or replace function public.tg_randevu_mesai_kontrol()
returns trigger
language plpgsql
as $$
declare
    v_ayar  text;
    v_hekim text;
    v_dilim text;
    v_yerel timestamp;
    v_gun   date;
    v_bas   time;
    v_bit   time;
begin
    if coalesce(new.durum, 1) in (3, 4) then return new; end if;
    if new.hekim_id is null then return new; end if;
    if tg_op = 'UPDATE'
       and new.hekim_id is not distinct from old.hekim_id
       and new.baslangic = old.baslangic
       and new.sure_dk = old.sure_dk
       and coalesce(old.durum, 1) not in (3, 4) then
        return new;
    end if;
    if public.fn_hekim_planli(new.hekim_id) <> 1 then return new; end if;

    select coalesce(nullif(s.zaman_dilimi, ''), 'Europe/Istanbul') into v_dilim
      from public.sube s where s.id = new.sube_id;
    v_yerel := new.baslangic at time zone coalesce(v_dilim, 'Europe/Istanbul');
    v_gun   := v_yerel::date;
    v_bas   := v_yerel::time;
    v_bit   := v_bas + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1)::int);

    -- İzinle ÇAKIŞAN randevu: kararı izin tetiği verir (kendi ayarıyla) - aynı
    --   randevuya iki mesaj çıkmasın. Saatli izinde çakışmayan saat normal denetlenir (950).
    if exists (select 1 from public.fn_hekim_izin_cakisan(new.hekim_id, v_gun, v_bas, v_bit)) then
        return new;
    end if;

    if exists (select 1
                 from public.fn_hekim_calisma_bloklari(new.sube_id, v_gun, v_gun, new.hekim_id) b
                where b.saat_bas is not null
                  and v_bas >= b.saat_bas and v_bit <= b.saat_bit
                  and v_bit > v_bas) then
        return new;
    end if;

    select coalesce(nullif(deger, ''), '0') into v_ayar
      from public.referans where anahtar = 'randevu.mesai_disi';
    if coalesce(v_ayar, '0') = '1' then
        raise warning 'Randevu % calisma plani disinda (hekim #%).',
            to_char(v_yerel, 'DD.MM.YYYY HH24:MI'), new.hekim_id;
        return new;
    end if;

    select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Doktor') into v_hekim
      from public.taraf where id = new.hekim_id;

    raise exception '% % saat % - %: çalışma planının dışında. Randevu doktorun çalışma saatleri içinde verilmeli; gerekirse Çalışma Planı''ndan saat değişikliği ya da ek mesai ekleyin.',
        v_hekim, to_char(v_gun, 'DD.MM.YYYY'),
        to_char(v_bas, 'HH24:MI'), to_char(v_bit, 'HH24:MI')
        using errcode = 'GK422';
end $$;

-- ------------------------------------------- 5) istisna "İzin" türü kalkar
update public.kod_deger d set aktif = 0
  from public.kod_liste l
 where l.id = d.liste_id and l.kod = 'calisma.istisna_tur' and d.deger = 1 and d.aktif <> 0;

create or replace function public.tg_calisma_istisna_onay()
returns trigger
language plpgsql
as $$
begin
    -- İZİN TÜRÜ YOK (950): izin İK'dan girilir (bakiye, bordro, onay). Eski
    --   İzin istisnaları durur; yeni kayıt ya da türü İzin'e çevirmek reddedilir.
    if new.tur = 1 and (tg_op = 'INSERT' or coalesce(old.tur, 0) <> 1) then
        raise exception 'İzin çalışma istisnası olarak girilmez - İK › İzinler''den (ya da Taleplerim''den) girilir, saatli izin de oradan. Burada kongre, saat değişikliği, ek mesai ve kapalı girilir.'
            using errcode = 'GK422';
    end if;
    -- ek mesaide kanal zorunlu (945)
    if new.tur = 4 and coalesce(nullif(replace(new.kanallar, ',', ''), ''), '') = '' then
        raise exception 'Ek mesai için en az bir randevu kanalı seçilmeli (banko, portal ya da çağrı merkezi).'
            using errcode = 'GK422';
    end if;
    if new.durum = 1 and (tg_op = 'INSERT' or coalesce(old.durum, -1) <> 1) then
        new.onaylayan   := case when tg_op = 'INSERT' then new.ekleyen
                                else coalesce(nullif(new.degistiren, 0), new.ekleyen) end;
        new.onay_tarihi := now();
    elsif new.durum <> 1 then
        new.onaylayan   := 0;
        new.onay_tarihi := null;
    end if;
    return new;
end $$;

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Çalışma İstisnaları', 1, 'Work Exceptions'),
    ('etiket', 'Çalışma İstisnası', 1, 'Work Exception'),
    ('etiket', 'İstisna', 1, 'Exception'),
    ('etiket', 'Saat (boşsa gün boyu)', 1, 'Time (empty = all day)')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin;

do $$
begin
    raise notice '950 tamam: İK iznine saat, gün tetiği (onarılan %), istisna İzin türü pasif.',
        (select count(*) from public.yedek_950_personel_izin);
end $$;
