-- =====================================================================
-- 468 - KURUM SÖZLEŞMESİ 1:N + ALT KURUM
--
-- Kullanıcı: "alt kurum sözleşmeye bağlı; birden fazla sözleşme varsa hasta
-- (başvuru) seçer."
--
-- BUGÜN: sözleşme `taraf_kurum` üzerinde 1:1 duruyor - bir kurumla TEK
-- anlaşma. Oysa aynı sigorta şirketiyle ÖSS, TSS ve Karma poliçeler ayrı
-- şartlarla çalışılır (farklı tarife, farklı karşılama, farklı SUT listesi).
-- Tek satıra sığmadığı için kurum üç kez cari olarak açılıyordu.
--
-- YENİ: `kurum_sozlesme` (1:N). `taraf_kurum` yalnız ROL BAŞLIĞI olarak
-- kalır (tur); sözleşmeye ait ne varsa buraya taşınır - kampanya dahil
-- (kullanıcı: "kampanya sözleşmeye bağlansın").
--
-- ALT KURUM tek kod uzayında: deger = tur * 100 + kod.
--   201 ÖSS · 202 TSS · 203 Karma        (tur 2 = ÖSS kurumu)
--   301 SSK · 302 Bağkur · 303 Emekli Sandığı · 304 Yeşil Kart · 399 Diğer
--                                        (tur 3 = SGK; devredilen kurum)
-- Türle çarpılmış tek liste, "hangi tür hangi alt kurumu alır" sorusunu
-- kodun kendisinde cevaplıyor; iki ayrı liste tutmak eşlemeyi ayrı bir
-- tabloya yazmayı gerektirirdi.
--
-- EK KATKI FİYAT LİSTESİNDE (kullanıcı: "bunu fiyat listesine koysak daha
-- anlaşılır olur"): sözleşmede sayı tutulmaz, 291'deki katılım payı deseninin
-- aynısı - liste varsayılanı + satır istisnası.
--
-- 249'daki eski `kurum_sozlesme` GERİ GELMEZ: o tabloda kurumun kendi indirim
-- satırları vardı, 271'de kaldırıldı (indirim tek yerde: KAMPANYA). Yedeği
-- (`kurum_sozlesme_yedek_271`) bu göç DOKUNMAZ.
-- =====================================================================

-- ------------------------------------------------------------- kod listeleri --
insert into public.kod_liste (kod, ad)
select 'kurum.alt_kurum', 'Alt Kurum / Poliçe Türü'
 where not exists (select 1 from public.kod_liste where kod = 'kurum.alt_kurum');

insert into public.kod_liste (kod, ad)
select 'fiyat_listesi.ek_katki_tipi', 'Ek Katkı Hesaplama'
 where not exists (select 1 from public.kod_liste
                    where kod = 'fiyat_listesi.ek_katki_tipi');

do $$
declare v_liste integer;
begin
    select id into v_liste from public.kod_liste where kod = 'kurum.alt_kurum';
    insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
    select v_liste, v.deger, 0, v.ad, v.deger, 1
      from (values (201, 'ÖSS (Özel Sağlık Sigortası)'),
                   (202, 'TSS (Tamamlayıcı Sağlık Sigortası)'),
                   (203, 'Karma (SGK + Tamamlayıcı)'),
                   (301, 'SSK'), (302, 'Bağ-Kur'), (303, 'Emekli Sandığı'),
                   (304, 'Yeşil Kart'), (399, 'Diğer')) as v(deger, ad)
    on conflict (liste_id, deger, dil) do update
        set ad = excluded.ad, aktif = 1;

    select id into v_liste from public.kod_liste
     where kod = 'fiyat_listesi.ek_katki_tipi';
    insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
    select v_liste, v.deger, 0, v.ad, v.deger * 10, 1
      from (values (0, 'Yok'), (1, 'Sabit tutar'), (2, 'Yüzde (SUT üzerinden)'))
        as v(deger, ad)
    on conflict (liste_id, deger, dil) do update
        set ad = excluded.ad, aktif = 1;
end $$;

-- ---------------------------------------------------------- kurum_sozlesme --
create table if not exists public.kurum_sozlesme (
    id                   serial primary key,
    kurum_id             integer     not null references public.taraf(id),
    ad                   varchar(120) not null default '',
    -- 0 = alt kurum yok (Özel) ya da başvuruda seçilir (SGK).
    alt_kurum            smallint    not null default 0,
    sozlesme_no          varchar(60) not null default '',
    baslangic            date,
    bitis                date,
    durum                smallint    not null default 1,   -- 1 yürürlükte · 0 kapalı
    kampanya_id          integer     references public.kampanya(id),
    -- TARİFE listesi: TTB/HUV ya da kuruma özel liste. Hastanenin fiyatı.
    fiyat_listesi_id     integer     references public.fiyat_listesi(id),
    -- SUT listesi: SGK bedelleri + katılım payı + ek katkı kuralı.
    sgk_fiyat_listesi_id integer     references public.fiyat_listesi(id),
    -- SGK tahakkuku HANGİ cariye yazılır. TSS/Karma'da ödeyen kurum sigorta
    --   şirketidir ama SGK payı SGK'ya faturalanır - iki ayrı cari.
    sgk_kurum_id         integer     references public.taraf(id),
    faturalama_modu      smallint    not null default 1,
    varsayilan_karsilama numeric(9,4) not null default 0,
    aciklama             varchar(300) not null default '',
    sube_id              integer,
    ekleyen              integer     not null default 0,
    ekleme_tarihi        timestamp   not null default now(),
    degistiren           integer,
    degistirme_tarihi    timestamp
);

comment on table public.kurum_sozlesme is
  'Kurumla yapılan anlaşma (468). Bir kurumun 1..N sözleşmesi olur: ÖSS/TSS/Karma ayrı şartlar.';
comment on column public.kurum_sozlesme.alt_kurum is
  'kod_liste kurum.alt_kurum: tur*100+kod. ÖSS''de sözleşme sabitler, SGK''da başvuruda seçilir (0).';
comment on column public.kurum_sozlesme.sgk_fiyat_listesi_id is
  'SUT listesi (468): SGK bedeli, katılım payı ve ek katkı kuralı buradan okunur.';
comment on column public.kurum_sozlesme.sgk_kurum_id is
  'SGK payının faturalanacağı cari. TSS/Karma''da ödeyen kurumdan FARKLIDIR.';

create index if not exists ix_kurum_sozlesme_kurum
    on public.kurum_sozlesme (kurum_id, durum);
create index if not exists ix_kurum_sozlesme_alt
    on public.kurum_sozlesme (alt_kurum) where alt_kurum > 0;

-- Alt kurum TÜRE UYMALI: ÖSS sözleşmesine 302 (Bağ-Kur) yazmak, rotayı
--   sessizce yanlış kurardı. Tetik, kod uzayının anlamını zorunlu kılar.
create or replace function public.tg_kurum_sozlesme_kontrol()
returns trigger language plpgsql as $$
declare v_tur smallint;
begin
    select tur into v_tur from public.taraf_kurum where id = new.kurum_id;
    if v_tur is null then
        raise exception 'Sözleşme açılan taraf bir KURUM değil (taraf_kurum kaydı yok).';
    end if;

    if new.alt_kurum <> 0 and (new.alt_kurum / 100) <> v_tur then
        raise exception 'Alt kurum (%) bu kurumun türüne (%) uymuyor.',
              new.alt_kurum, v_tur;
    end if;

    -- ÖSS sözleşmesi alt kurumsuz olamaz: rota (ÖSS/TSS/Karma) buradan çıkar.
    if v_tur = 2 and new.alt_kurum = 0 then
        raise exception 'ÖSS sözleşmesinde poliçe türü (ÖSS/TSS/Karma) seçilmeli.';
    end if;

    -- SGK payı olan sözleşmede SGK carisi zorunlu; SGK kurumunda kendisidir.
    if new.sgk_kurum_id is null then
        if v_tur = 3 then new.sgk_kurum_id := new.kurum_id;
        elsif new.alt_kurum in (202, 203) then
            raise exception 'TSS/Karma sözleşmesinde SGK carisi seçilmeli.';
        end if;
    end if;

    if new.bitis is not null and new.baslangic is not null
       and new.bitis < new.baslangic then
        raise exception 'Sözleşme bitişi başlangıcından önce olamaz.';
    end if;
    return new;
end $$;

drop trigger if exists tg_kurum_sozlesme_kontrol on public.kurum_sozlesme;
create trigger tg_kurum_sozlesme_kontrol
    before insert or update on public.kurum_sozlesme
    for each row execute function public.tg_kurum_sozlesme_kontrol();

-- --------------------------------------------------- fiyat listesi ek katkı --
-- 291'deki katılım payı deseninin aynısı: liste varsayılanı + satır istisnası.
--   Hastane "bu SUT listesinde ek katkı %75" der, MR'da farklıysa satıra yazar.
alter table public.fiyat_listesi
  add column if not exists ek_katki_tipi  smallint not null default 0,
  add column if not exists ek_katki_deger numeric(19,4) not null default 0;

alter table public.fiyat_listesi_satir
  add column if not exists ek_katki_tipi  smallint not null default 0,
  add column if not exists ek_katki_deger numeric(19,4) not null default 0;

comment on column public.fiyat_listesi.ek_katki_tipi is
  'Listenin varsayılan ek katkı kuralı (468): 0 yok · 1 sabit tutar · 2 yüzde (taban SUT bedeli).';
comment on column public.fiyat_listesi_satir.ek_katki_tipi is
  'Satırın ek katkı kuralı (468). 0 ise listenin varsayılanı geçerli.';

-- Satır > liste > taban liste zinciri (fn_fiyat_listesi_katki, 291 deseni).
create or replace function public.fn_fiyat_listesi_ek_katki(
    p_liste_id  integer,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_taban     numeric default 0,
    p_derinlik  integer default 0)
returns numeric
language plpgsql stable as $$
declare
    v_tipi   smallint;
    v_deger  numeric;
    v_taban  integer;
begin
    if p_liste_id is null or p_derinlik > 5 then return 0; end if;

    -- 1) SATIR: kaleme özel istisna.
    select s.ek_katki_tipi, s.ek_katki_deger into v_tipi, v_deger
      from public.fiyat_listesi_satir s
     where s.liste_id = p_liste_id
       and (p_stok_id   is null or s.stok_id   = p_stok_id)
       and (p_hizmet_id is null or s.hizmet_id = p_hizmet_id)
       and (s.stok_id   = p_stok_id or s.hizmet_id = p_hizmet_id)
       and s.ek_katki_tipi <> 0
     limit 1;

    -- 2) LİSTE varsayılanı.
    if v_tipi is null or v_tipi = 0 then
        select l.ek_katki_tipi, l.ek_katki_deger, l.taban_liste_id
          into v_tipi, v_deger, v_taban
          from public.fiyat_listesi l where l.id = p_liste_id;

        -- 3) TABAN listeye in: türetilmiş listede kural tekrar yazılmasın.
        if coalesce(v_tipi, 0) = 0 and v_taban is not null then
            return public.fn_fiyat_listesi_ek_katki(v_taban, p_stok_id, p_hizmet_id,
                                                    p_taban, p_derinlik + 1);
        end if;
    end if;

    if coalesce(v_tipi, 0) = 1 then return round(coalesce(v_deger, 0), 2); end if;
    if coalesce(v_tipi, 0) = 2 then
        return round(coalesce(p_taban, 0) * coalesce(v_deger, 0) / 100, 2);
    end if;
    return 0;
end $$;

comment on function public.fn_fiyat_listesi_ek_katki(integer, integer, integer, numeric, integer) is
  'Hastane ek katkısı (468): satır > liste > taban liste. Yüzde tipinde taban SUT bedelidir.';

-- ------------------------------------------------------------------ view'lar --
-- Alt kurum lookup'ı üst_id ile gelir: kart, kurumun TÜRÜNE göre süzer
--   (KodTablosu + BagliAlan deseni).
create or replace view public.v_alt_kurum_lookup as
select d.deger as id, d.ad, (d.deger / 100)::integer as ust_id, d.aktif
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'kurum.alt_kurum' and d.dil = 0;

comment on view public.v_alt_kurum_lookup is
  'Alt kurum seçenekleri (468). ust_id = kurum türü; kartlar buna göre süzer.';

create or replace view public.v_kurum_sozlesme_lookup as
select s.id,
       case when coalesce(nullif(s.ad, ''), '') <> '' then s.ad
            else coalesce((select d.ad from public.kod_deger d
                             join public.kod_liste l on l.id = d.liste_id
                            where l.kod = 'kurum.alt_kurum' and d.deger = s.alt_kurum),
                          'Sözleşme') end
         || case when s.sozlesme_no <> '' then ' · ' || s.sozlesme_no else '' end as ad,
       s.kurum_id as ust_id,
       case when s.durum = 1 then 1 else 0 end::smallint as aktif
  from public.kurum_sozlesme s;

comment on view public.v_kurum_sozlesme_lookup is
  'Başvuru kartının sözleşme seçicisi (468). ust_id = ödeyen kurum.';

-- ------------------------------------------------------------- veri göçü --
-- Her mevcut kuruma BİR sözleşme: bugünkü değerler olduğu gibi taşınır.
--   467'de TSS işaretlenmiş kurumlar alt_kurum = 202 alır (bilgi orada
--   saklanmıştı); diğer ÖSS kurumları 201, SGK 0 (başvuruda seçilir).
insert into public.kurum_sozlesme
       (kurum_id, ad, alt_kurum, sozlesme_no, baslangic, bitis, durum,
        kampanya_id, fiyat_listesi_id, sgk_fiyat_listesi_id, sgk_kurum_id,
        faturalama_modu, varsayilan_karsilama, aciklama, ekleyen)
select k.id,
       case k.tur when 1 then 'Özel hasta'
                  when 3 then 'SGK'
                  else case when y.kayit_id is not null then 'TSS' else 'ÖSS' end end,
       case k.tur when 2 then case when y.kayit_id is not null then 202 else 201 end
                  else 0 end,
       coalesce(k.sozlesme_no, ''), k.baslangic, k.bitis, coalesce(k.durum, 1),
       k.kampanya_id,
       -- SGK kurumunda tek liste zaten SUT'tur: tarife tarafı boş kalır.
       case when k.tur = 3 then null else k.fiyat_listesi_id end,
       case when k.tur = 3 then k.fiyat_listesi_id else null end,
       case when k.tur = 3 then k.id else null end,
       coalesce(k.faturalama_modu, 1), coalesce(k.varsayilan_karsilama, 0),
       coalesce(k.aciklama, ''), 0
  from public.taraf_kurum k
  left join public._yedek_kurum_turu_467 y
         on y.tablo = 'taraf_kurum' and y.kayit_id = k.id
        and y.eski_tur = 3 and y.yeni_tur = 2
 where not exists (select 1 from public.kurum_sozlesme s where s.kurum_id = k.id);

-- ------------------------------------------------------------- fonksiyonlar --
-- Tek yürürlükteki sözleşme varsa başvuru onu KENDİLİĞİNDEN alır; birden
--   fazlaysa null döner ve kullanıcı seçer (469'daki tetik bunu zorunlu tutar).
create or replace function public.fn_kurum_sozlesme_sec(
    p_kurum_id integer,
    p_tarih    date default current_date)
returns integer
language sql stable as $$
    select case when count(*) = 1 then min(s.id) end
      from public.kurum_sozlesme s
     where s.kurum_id = p_kurum_id
       and s.durum = 1
       and (s.baslangic is null or s.baslangic <= p_tarih)
       and (s.bitis     is null or s.bitis     >= p_tarih);
$$;

comment on function public.fn_kurum_sozlesme_sec(integer, date) is
  'Kurumun o tarihte TEK yürürlükteki sözleşmesi (468); birden fazlaysa null - seçim kullanıcınındır.';

-- KAMPANYA artık sözleşmede (kullanıcı). Sözleşme verilirse onun kampanyası,
--   verilmezse tek sözleşmeninki; sonra cari, sonra genel.
create or replace function public.fn_taraf_kampanya(
    p_taraf_id    integer,
    p_tarih       date default current_date,
    p_sozlesme_id integer default null)
returns integer
language sql stable as $$
    with aday as (
        select k.id, 1 as oncelik
          from public.kurum_sozlesme s
          join public.kampanya k on k.id = s.kampanya_id
         where s.id = coalesce(p_sozlesme_id,
                               public.fn_kurum_sozlesme_sec(p_taraf_id, p_tarih))
           and s.durum = 1
           and (s.baslangic is null or s.baslangic <= p_tarih)
           and (s.bitis     is null or s.bitis     >= p_tarih)
           and k.durum = 1
           and (k.baslangic is null or k.baslangic <= p_tarih)
           and (k.bitis     is null or k.bitis     >= p_tarih)
        union all
        select k.id, 2
          from public.taraf t
          join public.kampanya k on k.id = t.kampanya_id
         where t.id = p_taraf_id
           and k.durum = 1
           and (k.baslangic is null or k.baslangic <= p_tarih)
           and (k.bitis     is null or k.bitis     >= p_tarih)
        union all
        select k.id, 3
          from public.kampanya k
         where k.genel = 1
           and k.durum = 1
           and (k.baslangic is null or k.baslangic <= p_tarih)
           and (k.bitis     is null or k.bitis     >= p_tarih)
    )
    select id from aday order by oncelik, id limit 1;
$$;

comment on function public.fn_taraf_kampanya(integer, date, integer) is
  'Geçerli kampanya (468): SÖZLEŞME > cari > genel. Kampanya artık sözleşmeye bağlı.';

-- 274'ün iki parametreli imzası korunur: eski çağrılar (fn_kurum_kampanya,
--   292/302 fonksiyonları) kırılmasın - sözleşme verilmemiş sayılır.
create or replace function public.fn_taraf_kampanya(
    p_taraf_id integer,
    p_tarih    date default current_date)
returns integer
language sql stable as $$
    select public.fn_taraf_kampanya(p_taraf_id, p_tarih, null::integer);
$$;

-- Varsayılan liste artık SÖZLEŞMEDEN okunur (taraf_kurum'dan değil).
create or replace function public.fn_belge_varsayilan_liste(
    p_tur integer,
    p_taraf_id integer,
    p_tarih date default current_date,
    p_odeyen_kurum_id integer default null,
    p_sozlesme_id integer default null)
returns integer
language sql stable as $function$
    select coalesce(
        -- 1) KAMPANYA LİSTESİ: anlaşma hem baz listeyi hem indirimi tayin eder.
        (select fl.id
           from public.kampanya k
           join public.fiyat_listesi fl on fl.id = k.fiyat_listesi_id
          where k.id = public.fn_taraf_kampanya(
                           case when coalesce(p_odeyen_kurum_id, 0) > 0
                                then p_odeyen_kurum_id else p_taraf_id end,
                           p_tarih, p_sozlesme_id)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2) SÖZLEŞME TARİFE LİSTESİ (468): anlaşmada yazan liste.
        (select fl.id
           from public.kurum_sozlesme s
           join public.fiyat_listesi fl on fl.id = s.fiyat_listesi_id
          where s.id = coalesce(p_sozlesme_id,
                                public.fn_kurum_sozlesme_sec(p_odeyen_kurum_id, p_tarih))
            and s.durum = 1
            and (s.baslangic is null or s.baslangic <= p_tarih)
            and (s.bitis is null or s.bitis >= p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 3) Ödeyen kurum bir caridir: listesi cari kuralından.
        case when coalesce(p_odeyen_kurum_id, 0) > 0
             then public.fn_cari_fiyat_listesi(p_odeyen_kurum_id,
                                               public.fn_belge_yon(p_tur), p_tarih)
        end,

        -- 4) Carinin kendi listesi / yönün varsayılanı.
        public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih));
$function$;

do $$
begin
    raise notice '468 tamam: % sozlesme kaydi var (% kurum)',
        (select count(*) from public.kurum_sozlesme),
        (select count(*) from public.taraf_kurum);
end $$;
