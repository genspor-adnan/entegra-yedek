-- ============================================================================
--  361 - PRIM ROL ISARETLERI (kim hangi rolde prim alabilir)
--
--  Kullanici: "prim alacak personeli prim türüne göre işaretlemek istiyorum..
--  lab ve görüntüleme kurum tipi ise başvuruda poliklinik(bölüm) ve doktor adı
--  dış doktorlardan 'Gönderen' olarak işaretlediklerimiz listeye gelecek..
--  ancak Muayenehane, Dal Merkezi, Tıp Mrk., Hastane olursa personelden 'Yapan'
--  işaret ettiklerimiz olacak.. bir personel hem isteyen hem yapan hem de
--  uygulayan olabilir.. dış doktorlar sadece gönderen olabilir."
--
--  KARAR: rol isareti KISININ KARTINDA durur (taraf_prim_rol) - bir kisi
--  birden cok rol tasiyabilir. Rol adaylari her yerde (basvuru hekim combosu,
--  kalem prim rolleri) BU tablodan cozulur; boylece "kim hangi rolde
--  gorunecek" sorusunun tek kaynagi olur.
--
--  Kurum tipi (359) HANGI ROLUN VARSAYILAN oldugunu belirler:
--    lab / goruntuleme / goruntuleme_lab  -> 1 Gönderen (dis doktor)
--    digerleri (muayenehane, dal, tip merkezi, hastane) -> 4 Yapan (personel)
--
--  Roller prim.rol kod listesidir (324): 1 Gönderen · 2 İsteyen · 3 Uygulayan
--  4 Yapan · 5 Raporlayan · 6 Onaylayan · 7 Anestezi · 8 Asistan · 9 Teknisyen.
-- ============================================================================

create table if not exists public.taraf_prim_rol (
    taraf_id   integer  not null references public.taraf(id) on delete cascade,
    rol        smallint not null,
    -- Bu rolde ONERILEN kisi: basvuru comboları ve prim rol modali once
    --   varsayilanlari gosterir (uzun listede aranan kisi ustte olsun).
    varsayilan smallint not null default 0,
    aciklama   varchar(200) not null default '',
    ekleyen    integer  not null default 0,
    ekleme_tarihi timestamp not null default now()::timestamp,
    primary key (taraf_id, rol)
);

comment on table public.taraf_prim_rol is
  'Kisinin prim rolleri (361): bir kisi hem isteyen hem yapan hem uygulayan olabilir. '
  'Dis hekim YALNIZ Gonderen (1) olabilir - kurumda is yapmaz, hasta gonderir.';
comment on column public.taraf_prim_rol.rol is
  'prim.rol kod listesi (324): 1 Gonderen, 2 Isteyen, 3 Uygulayan, 4 Yapan, '
  '5 Raporlayan, 6 Onaylayan, 7 Anestezi, 8 Asistan, 9 Teknisyen.';

create index if not exists ix_taraf_prim_rol_rol on public.taraf_prim_rol (rol, taraf_id);

-- ============================================================ is kurallari ==
-- Rol yalniz PERSONELE verilir; DIS HEKIM ise yalnizca Gonderen olabilir.
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
    if v_dis = 1 and new.rol <> 1 then
        raise exception 'Dış hekim yalnız "Gönderen" rolünü alabilir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tr_taraf_prim_rol_dogrula on public.taraf_prim_rol;
create trigger tr_taraf_prim_rol_dogrula before insert or update on public.taraf_prim_rol
    for each row execute function public.tg_taraf_prim_rol_dogrula();

-- ================================================================ adaylar ==
-- Rol adaylari: kim hangi rolde secilebilir. `dis_mi` ekranda ayrimi gostermek
-- icin (dis hekim listede "dış" rozetiyle durur).
create or replace view public.v_prim_rol_aday as
select r.taraf_id                         as id,
       t.unvan                            as ad,
       r.rol,
       r.varsayilan,
       coalesce(p.dis_hekim, 0)::smallint as dis_mi,
       coalesce(p.departman, 0)           as bolum_id,
       coalesce(t.durum, 1)               as durum
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  left join public.taraf_personel p on p.id = r.taraf_id;

comment on view public.v_prim_rol_aday is
  'Prim rol adaylari (361): kisi x rol. Basvuru hekim combosu ve prim rol '
  'modali bu gorunumden beslenir.';

-- Kurum tipine gore BASVURUDA sorulan hekim rolu (359 profili).
--   lab / goruntuleme / goruntuleme_lab -> 1 Gonderen (dis doktor listesi)
--   digerleri -> 4 Yapan (kurum personeli)
create or replace function public.fn_basvuru_hekim_rolu()
returns smallint
language sql
stable
as $$
    select case when p.kurum_tipi in ('lab', 'goruntuleme', 'goruntuleme_lab')
                then 1::smallint else 4::smallint end
      from public.kurum_profil p
     where p.id = 1;
$$;

comment on function public.fn_basvuru_hekim_rolu() is
  'Basvuruda hangi rolun adaylari listelenecek (361): lab/goruntuleme kurumunda '
  'Gonderen (1), digerlerinde Yapan (4).';

-- ============================================================ ilk doldurma ==
-- MEVCUT KURULUM BOZULMASIN: bugune kadar randevu verilebilen personel zaten
-- basvuru combosunda cikiyordu - hepsi "Yapan" olarak isaretlenir. Dis hekimler
-- de "Gonderen" olur. Boylece ekranlar 361 sonrasi ayni listeyi gosterir;
-- kullanici gerekmeyenleri kartindan kaldirir.
insert into public.taraf_prim_rol (taraf_id, rol, varsayilan, aciklama)
select t.id, 4, 1, 'Otomatik (361): randevu verilebilir personel'
  from public.taraf t
  left join public.taraf_personel p on p.id = t.id
 where t.personel = 1 and coalesce(p.dis_hekim, 0) = 0
   and coalesce(t.randevu_verilebilir, 0) = 1
   and not exists (select 1 from public.taraf_prim_rol r
                    where r.taraf_id = t.id and r.rol = 4);

insert into public.taraf_prim_rol (taraf_id, rol, varsayilan, aciklama)
select t.id, 1, 1, 'Otomatik (361): dış hekim'
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where t.personel = 1 and p.dis_hekim = 1
   and not exists (select 1 from public.taraf_prim_rol r
                    where r.taraf_id = t.id and r.rol = 1);

-- ======================================================== kalem rol kurali ==
-- Kalem prim rolu (324, belge_satir_rol) de ayni kurala uyar: DIS HEKIM yalniz
-- "Gonderen" olabilir. Kural iki yerde de dursun - rol isareti kartta unutulsa
-- bile yanlis hakedis dogmasin.
create or replace function public.tg_belge_satir_rol_dogrula()
returns trigger
language plpgsql
as $$
declare v_dis smallint;
begin
    select coalesce(p.dis_hekim, 0) into v_dis
      from public.taraf_personel p where p.id = new.taraf_id;

    if coalesce(v_dis, 0) = 1 and new.rol <> 1 then
        raise exception 'Dış hekim yalnız "Gönderen" rolünde prim alabilir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tr_belge_satir_rol_dogrula on public.belge_satir_rol;
create trigger tr_belge_satir_rol_dogrula before insert or update on public.belge_satir_rol
    for each row execute function public.tg_belge_satir_rol_dogrula();
