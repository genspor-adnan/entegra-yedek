-- ============================================================================
--  Gentegre AI — AVANS İADESİ
--  780_avans_iadesi.sql
--
--  Kullanıcı: *"avans iadesini de yap"* (779'un devamı).
--
--  ============ İADE AYRI BİR KAYIT, AVANSIN SİLİNMESİ DEĞİL ===========
--  Hasta kalan avansını geri istediğinde iki yol var: avans kaydını küçültmek
--  ya da parayı GERİ ÖDEME olarak yazmak. Birincisi kasayı yalan söyletir -
--  para bir gün girmiş, başka bir gün çıkmıştır; avansın tutarını sonradan
--  düşürmek o iki hareketi tek satıra ezer, gün sonu kasa sayımı tutmaz ve
--  "ne zaman iade ettik" sorusu cevapsız kalır.
--
--  Bu yüzden iade ÖDEME yönünde ayrı bir kasa işlemidir ve `avans_kaynak_id`
--  ile avansına bağlanır. Avans kaydı olduğu gibi durur; listede "İade
--  Edildi" görünür ve iade edilen tutar KALAN'dan düşer.
--
--  ============ NEDEN TETİK (uygulama kontrolü değil) ==================
--  "İade kalan avansı aşamaz" kuralı paranın kendisiyle ilgili: aşarsa kurum
--  hastaya almadığı parayı öder. Kural ekranda dursaydı, aynı avansa iki
--  pencereden (ya da API'den) iade yazıldığında ikisi de kendi anına göre
--  haklı çıkardı. Tetik tek yazıcıdır ve satırı kilitleyerek bakar.
--
--  ============ MAHSUP DA İADEYİ GÖRÜR ================================
--  322'nin `v_taraf_avans` görünümü "dağıtılmamış tahsilat" diyordu; iade
--  bir dağıtım olmadığı için iade edilmiş para orada hâlâ mahsup edilebilir
--  görünürdü - hastaya iade edilen 800 TL bir de başvurusuna sayılırdı.
--  Görünüm iadeyi de düşüyor: tek tanım, iki ekran (mahsup şeridi + avans
--  listesi) aynı rakamı konuşur.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------------- bağ ------
alter table public.kasa_islem
  add column if not exists avans_kaynak_id integer;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_kasa_islem_avans_kaynak') then
        alter table public.kasa_islem
          add constraint fk_kasa_islem_avans_kaynak
          foreign key (avans_kaynak_id) references public.kasa_islem (id);
    end if;
end $$;

comment on column public.kasa_islem.avans_kaynak_id is
  'Bu odeme HANGI avansin iadesi (780). Avans kaydi degismez, iade ayri satirdir.';

create index if not exists ix_kasa_islem_avans_kaynak
    on public.kasa_islem (avans_kaynak_id)
 where avans_kaynak_id is not null;

-- ---------------------------------------------------- iade edilen tutar ---
-- TEK TANIM: hem tetik hem iki gorunum bunu cagirir - "iptal edilen iade
--   sayilmaz" kurali uc yerde ayri yazilsaydi biri geride kalirdi.
create or replace function public.fn_avans_iade_toplam(p_avans_id integer,
                                                       p_haric_id integer default null)
returns numeric
language sql
stable
as $$
    select coalesce(sum(abs(i.tutar)), 0)
      from public.kasa_islem i
     where i.avans_kaynak_id = p_avans_id
       and i.durum <> 3                       -- iptal edilmis iade para degildir
       and i.iptal_islem_id is null
       and (p_haric_id is null or i.id <> p_haric_id);
$$;

comment on function public.fn_avans_iade_toplam(integer, integer) is
  'Avansin GECERLI iade toplami (780); p_haric_id ile kendi satirini disarida birakir.';

-- ------------------------------------------------------------- tetik -----
create or replace function public.tg_kasa_islem_avans_iade()
returns trigger
language plpgsql
as $$
declare
    v_kaynak  public.kasa_islem%rowtype;
    v_yon     smallint;
    v_kaynak_yon smallint;
    v_dagitilan numeric;
    v_iade    numeric;
    v_kalan   numeric;
begin
    if new.avans_kaynak_id is null then
        return new;
    end if;

    -- SATIR KILITLENIR: ayni avansa es zamanli iki iade, ikisi de "kalan var"
    --   gorup gecerdi.
    select * into v_kaynak from public.kasa_islem
     where id = new.avans_kaynak_id for update;
    if not found then
        raise exception 'İade edilecek avans bulunamadı (kasa işlemi %).',
              new.avans_kaynak_id using errcode = 'GK422';
    end if;

    select yon into v_kaynak_yon from public.kasa_islem_turu where kod = v_kaynak.tur;
    if coalesce(v_kaynak_yon, 1) <> 1 then
        raise exception 'İade yalnız TAHSİLATA bağlanır - kaynak işlem bir tahsilat değil.'
              using errcode = 'GK422';
    end if;
    if v_kaynak.durum = 3 or v_kaynak.iptal_islem_id is not null then
        raise exception 'İptal edilmiş avansın iadesi olmaz.' using errcode = 'GK422';
    end if;

    select yon into v_yon from public.kasa_islem_turu where kod = new.tur;
    if coalesce(v_yon, 0) <> -1 then
        raise exception 'Avans iadesi ÖDEME türünde olmalı (para kurumdan çıkar).'
              using errcode = 'GK422';
    end if;

    -- IADE AVANSIN SAHIBINE yapilir: baskasina odenen para iade degil,
    --   baska bir islemdir.
    if new.taraf_id is distinct from v_kaynak.taraf_id then
        raise exception 'Avans iadesi avansın sahibine yapılır (cari farklı).'
              using errcode = 'GK422';
    end if;

    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d where d.kasa_islem_id = v_kaynak.id;
    v_iade  := public.fn_avans_iade_toplam(v_kaynak.id, new.id);
    v_kalan := v_kaynak.tutar - v_dagitilan - v_iade;

    if abs(new.tutar) > v_kalan + 0.005 then
        -- HATA KODU GK422 (076 kurali): API bu mesaji kullaniciya AYNEN
        --   gosterir; kodsuz raise 500 "Beklenmeyen hata" olarak cikardi.
        raise exception 'İade tutarı kalan avansı aşamaz (kalan: %).',
              public.fn_para_tr(v_kalan) using errcode = 'GK422';
    end if;

    return new;
end $$;

comment on function public.tg_kasa_islem_avans_iade() is
  'Avans iadesinin yonunu, sahibini ve kalani denetler (780).';

drop trigger if exists tg_kasa_islem_avans_iade on public.kasa_islem;

create trigger tg_kasa_islem_avans_iade
    before insert or update of avans_kaynak_id, tutar, tur, taraf_id
    on public.kasa_islem
    for each row execute function public.tg_kasa_islem_avans_iade();

-- -------------------------------------------- 322 gorunumu: iade dusulur --
-- Kolon ADLARI ve SIRASI aynen korunuyor (create or replace sarti); degisen
--   yalniz "dagitilmamis"in tanimi: iade edilmis para artik mahsup edilebilir
--   gorunmez.
create or replace view public.v_taraf_avans as
select v.kasa_islem_id,
       v.taraf_id,
       v.belge_id,
       v.islem_tarihi,
       v.tutar,
       v.dagitilan,
       greatest(v.tutar - v.dagitilan
                - public.fn_avans_iade_toplam(v.kasa_islem_id), 0) as dagitilmamis,
       coalesce(t.ad, '')                     as islem_adi
  from public.v_kasa_islem_dagitim v
  left join public.kasa_islem_turu t on t.kod = v.tur
 where coalesce(v.durum, 0) = 2
   and v.iptal_islem_id is null
   and greatest(v.tutar - v.dagitilan
                - public.fn_avans_iade_toplam(v.kasa_islem_id), 0) > 0.005
   and coalesce(t.yon, 1) = 1;

comment on view public.v_taraf_avans is
  'Carinin mahsup edilebilir avansi (322/780): dagitilmamis VE iade edilmemis tutar.';

-- --------------------------------------------- hasta avans listesi (779) --
drop view if exists public.v_hasta_avans_bakiye;
drop view if exists public.v_hasta_avans;

create view public.v_hasta_avans as
select ki.id                                   as kasa_islem_id,
       ki.taraf_id,
       coalesce(t.unvan, ki.taraf_unvan, '')   as hasta_adi,
       coalesce(t.kod, '')                     as dosya_no,
       ki.sube_id,
       ki.islem_tarihi,
       coalesce(nullif(ki.makbuz_no, ''), ki.islem_no, '') as makbuz_no,
       ki.tur,
       coalesce(kt.ad, '')                     as islem_adi,
       coalesce(h.ad, '')                      as hesap_adi,
       ki.tutar                                as alinan,
       coalesce(d.dagitilan, 0)                as kullanilan,
       i.iade,
       greatest(ki.tutar - coalesce(d.dagitilan, 0) - i.iade, 0) as kalan,
       -- DURUM MERDIVENI: once "para duruyor mu", sonra "nereye gitti".
       --   Iade, kullanimdan once okunur: iade edilmis bir avansta memurun
       --   bilmesi gereken sey parayi geri verdigimizdir.
       case when greatest(ki.tutar - coalesce(d.dagitilan, 0) - i.iade, 0) > 0.005
                 then case when i.iade > 0.005 then 'Kısmen İade'
                           when coalesce(d.dagitilan, 0) > 0.005 then 'Kısmen Kullanıldı'
                           else 'Açık' end
            when i.iade > 0.005 then 'İade Edildi'
            else 'Kullanıldı' end              as durum_adi,
       i.iade_tarihi,
       ki.avans,
       ki.belge_id,
       coalesce(b.belge_no, '')                as belge_no,
       coalesce(ki.aciklama, '')               as aciklama,
       ki.ekleme_tarihi
  from public.kasa_islem ki
  join public.taraf t                 on t.id  = ki.taraf_id and t.grup = 101
  left join public.kasa_islem_turu kt on kt.kod = ki.tur
  left join public.hesap h            on h.id  = ki.hesap_id
  left join public.belge b            on b.id  = ki.belge_id
  left join lateral (
       select sum(x.tutar) as dagitilan
         from public.kasa_islem_dagitim x
        where x.kasa_islem_id = ki.id) d on true
  left join lateral (
       select coalesce(sum(abs(x.tutar)), 0) as iade,
              max(x.islem_tarihi)            as iade_tarihi
         from public.kasa_islem x
        where x.avans_kaynak_id = ki.id
          and x.durum <> 3 and x.iptal_islem_id is null) i on true
 where ki.durum = 2
   and ki.iptal_islem_id is null
   and coalesce(kt.yon, 1) = 1
   and (ki.avans = 1
        or greatest(ki.tutar - coalesce(d.dagitilan, 0) - i.iade, 0) > 0.005);

comment on view public.v_hasta_avans is
  'Hastadan alinan avanslar (779/780): alinan / kullanilan / iade / kalan ve durumu.';

create view public.v_hasta_avans_bakiye as
select a.taraf_id,
       sum(a.kalan)                            as acik_avans,
       count(*) filter (where a.kalan > 0.005) as acik_islem,
       max(a.islem_tarihi)                     as son_avans_tarihi
  from public.v_hasta_avans a
 group by a.taraf_id;

comment on view public.v_hasta_avans_bakiye is
  'Hastanin kullanilmamis ve iade edilmemis avans toplami (779/780).';

do $$
begin
    raise notice '780 tamam: avans iadesi (avans_kaynak_id + tetik) kuruldu; '
                 'mahsup ve avans listesi iadeyi dusuyor.';
end $$;
