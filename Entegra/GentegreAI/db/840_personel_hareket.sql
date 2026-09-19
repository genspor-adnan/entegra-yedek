-- ============================================================================
--  Gentegre AI — KADRO HAREKETİ: PERSONELİN POZİSYON GEÇMİŞİ
--  840_personel_hareket.sql
--
--  Kullanıcı: *"personelin pozisyon değişikliklerini kronolojik olarak nasıl
--  takip ederiz"* → *"yap.. onay zincirine gerek yok"*.
--
--  ============ BUGÜNE KADAR NEDEN TAKİP EDİLEMİYORDU ==================
--  `taraf_personel` TEK SATIR: görev, bölüm, yönetici, şube, çalışma şekli
--  yalnız BUGÜNKÜ hâli tutuyor; değiştirince eskisi kayboluyordu.
--  `islem_log` (tablo 73) alan-alan iz bırakıyor - ama o DENETİM izidir:
--  yürürlük tarihi yok (20 Aralık'ta girilen "1 Ocak'tan itibaren şef"
--  kaydı 20 Aralık görünür), o günkü tam pozisyon fotoğrafı yok, karar/belge
--  bağı yok.
--
--  ============ FOTOĞRAF, DELTA DEĞİL =================================
--  Her satır bir hareket ve o tarihte geçerli pozisyonun TAMAMI. "1 Mart'ta
--  ne idi" tek satırdan okunur. Yalnız değişen alanı yazsaydık her soru için
--  geçmişi baştan oynatmak gerekirdi.
--
--  ============ TEK YAZAN: HAREKET ====================================
--  `taraf_personel` bu defterden TÜRETİLİR: yürürlüğü gelmiş en son hareket
--  karta yazılır (`fn_personel_kadro_uygula`). Kart elle düzenlendiğinde de
--  hareket üretilir (`tg_personel_kadro_iz`) - iki kaynak çelişmesin.
--
--  İLERİ TARİHLİ HAREKET SERBEST: "1 Ocak'ta başlıyor" bugünden girilir, o
--  güne kadar kartta görünmez. Uygulamayı `fn_personel_kadro_gunluk()` yapar
--  (gün başında çağrılır; çağrılmazsa okuma tarafı yine doğru görünümü verir,
--  yalnız kart satırı geç güncellenir).
--
--  ONAY ZİNCİRİ YOK (kullanıcı kararı): hareket girildiği an geçerlidir.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- yetki ----
insert into public.yetki (kod, ad, grup, tur, sira, aktif, urun_modu)
select 'ik.kadro', 'Kadro Hareketleri (pozisyon geçmişi)', 'ik', 0, 12, 1, 0
 where not exists (select 1 from public.yetki y where y.kod = 'ik.kadro');

-- SISTEM YONETICISI YENI YETKIYI ALIR (839 deseni): yoksa ekran hicbir
--   kullanicida acilmaz - yetki eklendi ama kimsede yok.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'ik.kadro'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- IK SORUMLUSU ve IK PERSONELI de gorsun: defterin sahibi IK.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, case when r.kod = 'erp_ik' then 1 else 0 end,
       case when r.kod = 'erp_ik' then 1 else 0 end, 0, 0
  from public.rol r cross join public.yetki y
 where r.kod in ('erp_ik', 'ik_personel') and y.kod = 'ik.kadro'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

update public.rol set yetki_surumu = yetki_surumu + 1
 where kod in ('yonetici', 'erp_ik', 'ik_personel');

-- --------------------------------------------------------- kod listesi ----
insert into public.kod_liste (kod, ad, ekleyen)
select 'ik.hareket_tur', 'Kadro Hareketi Türü', 0
 where not exists (select 1 from public.kod_liste k where k.kod = 'ik.hareket_tur');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    (1, 'İşe giriş'), (2, 'Terfi / unvan'), (3, 'Birim değişikliği'),
    (4, 'Yönetici değişikliği'), (5, 'Şube nakli'),
    (6, 'Çalışma şekli / sözleşme'), (7, 'Vekâlet (süreli)'),
    (8, 'Ücretsiz izin / askı'), (9, 'İşten çıkış'), (10, 'İşe dönüş'),
    (99, 'Diğer')
  ) as v(deger, ad) on l.kod = 'ik.hareket_tur'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ------------------------------------------------------------- tablo ----
create table if not exists public.personel_hareket (
    id                  serial primary key,
    taraf_id            integer      not null references public.taraf(id),
    tur                 smallint     not null default 99,      -- ik.hareket_tur
    -- YÜRÜRLÜK, KARAR TARİHİ DEĞİL: kayıt ne zaman girilirse girilsin
    --   pozisyon bu tarihte değişir.
    yururluk            date         not null,
    -- SÜRELİ HAREKET (vekâlet, askı): bitince önceki pozisyona dönülür.
    --   null = süresiz.
    bitis               date,
    -- O TARİHTEKİ TAM POZİSYON (fotoğraf).
    gorev               varchar(100) not null default '',
    gorev_id            integer,
    departman_id        integer,
    yonetici_taraf_id   integer      references public.taraf(id),
    sube_id             integer      not null default 0,
    calisma_sekli       smallint     not null default 0,
    sozlesme_turu       smallint     not null default 0,
    unvan               varchar(120) not null default '',
    -- Kâğıt tarafı.
    karar_no            varchar(50)  not null default '',
    belge_no            varchar(50)  not null default '',
    gerekce             varchar(300) not null default '',
    aciklama            varchar(500) not null default '',
    -- KAYNAK: 1 elle girilen · 2 karttan türetilen (tg_personel_kadro_iz)
    --   · 3 göç/dolgu. Elle girileni tetik EZMEZ.
    kaynak              smallint     not null default 1,
    ekleyen             integer,
    ekleme_tarihi       timestamp    not null default now(),
    degistiren          integer,
    degistirme_tarihi   timestamp
);

create index if not exists ix_personel_hareket_taraf
    on public.personel_hareket (taraf_id, yururluk desc, id desc);
create index if not exists ix_personel_hareket_yururluk
    on public.personel_hareket (yururluk desc);

comment on table public.personel_hareket is
  '840: personelin pozisyon gecmisi - her satir o tarihte gecerli TAM pozisyon.';
comment on column public.personel_hareket.yururluk is
  '840: pozisyonun gecerli oldugu tarih (karar/giris tarihi degil).';

-- ------------------------------------------------- o tarihteki pozisyon ----
-- Bir personelin VERİLEN TARİHTEKİ hareketi: yürürlüğü geçmiş en son satır.
--   Süreli hareket (bitis dolmuş) o tarihte geçerli SAYILMAZ.
create or replace function public.fn_personel_kadro(p_taraf_id integer,
                                                   p_tarih date default current_date)
returns public.personel_hareket
language sql stable as $$
    select h.* from public.personel_hareket h
     where h.taraf_id = p_taraf_id
       and h.yururluk <= p_tarih
       and (h.bitis is null or h.bitis >= p_tarih)
     order by h.yururluk desc, h.id desc
     limit 1;
$$;

comment on function public.fn_personel_kadro is
  '840: personelin verilen tarihteki pozisyonu (yururlugu gecmis son hareket).';

-- ------------------------------------------- hareketi karta uygula ----
-- Kart (taraf_personel) hareketten TÜRETİLİR. Tetik dönüşünü engellemek için
--   `kaynak = 2` iz bırakmayı kapatan oturum değişkeni kullanılır.
create or replace function public.fn_personel_kadro_uygula(p_taraf_id integer)
returns integer language plpgsql as $$
declare h public.personel_hareket; v_sayi integer := 0;
begin
    select * into h from public.fn_personel_kadro(p_taraf_id, current_date);
    if h.id is null then return 0; end if;

    perform set_config('gentegre.kadro_iz', 'kapali', true);
    update public.taraf_personel p
       set gorev             = case when h.gorev <> '' then h.gorev else p.gorev end,
           yonetici_taraf_id = coalesce(h.yonetici_taraf_id, p.yonetici_taraf_id),
           sube_id           = case when h.sube_id > 0 then h.sube_id else p.sube_id end,
           calisma_sekli     = case when h.calisma_sekli > 0 then h.calisma_sekli
                                    else p.calisma_sekli end,
           sozlesme_turu     = case when h.sozlesme_turu > 0 then h.sozlesme_turu
                                    else p.sozlesme_turu end,
           degistirme_tarihi = now()
     where p.id = p_taraf_id;
    get diagnostics v_sayi = row_count;
    perform set_config('gentegre.kadro_iz', '', true);
    return v_sayi;
end $$;

-- Yürürlüğü BUGÜN gelen hareketleri karta yazar (gün başı işi).
create or replace function public.fn_personel_kadro_gunluk()
returns integer language plpgsql as $$
declare r record; v_sayi integer := 0;
begin
    for r in select distinct taraf_id from public.personel_hareket
              where yururluk <= current_date
    loop
        v_sayi := v_sayi + public.fn_personel_kadro_uygula(r.taraf_id);
    end loop;
    return v_sayi;
end $$;

-- Hareket eklenince/değişince kart hemen tazelenir.
create or replace function public.tg_personel_hareket_uygula()
returns trigger language plpgsql as $$
begin
    perform public.fn_personel_kadro_uygula(new.taraf_id);
    return null;
end $$;

drop trigger if exists tr_personel_hareket_uygula on public.personel_hareket;
create trigger tr_personel_hareket_uygula
  after insert or update on public.personel_hareket
  for each row execute function public.tg_personel_hareket_uygula();

-- --------------------------------------- karttan hareket izi (tek yazan) ----
-- Kart elle düzenlenirse hareket defteri boş kalmasın: pozisyon alanlarından
--   biri değişince BUGÜN yürürlüklü bir "türetilmiş" satır yazılır. Aynı gün
--   ikinci değişiklik yeni satır açmaz, o günkü satırı günceller - yoksa tek
--   düzenleme oturumu defteri şişirirdi.
create or replace function public.tg_personel_kadro_iz()
returns trigger language plpgsql as $$
declare v_var integer;
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;
    if new.gorev is not distinct from old.gorev
       and new.yonetici_taraf_id is not distinct from old.yonetici_taraf_id
       and new.sube_id is not distinct from old.sube_id
       and new.calisma_sekli is not distinct from old.calisma_sekli
       and new.sozlesme_turu is not distinct from old.sozlesme_turu then
        return null;
    end if;

    select id into v_var from public.personel_hareket
     where taraf_id = new.id and yururluk = current_date and kaynak = 2
     order by id desc limit 1;

    if v_var is not null then
        update public.personel_hareket
           set gorev = coalesce(new.gorev, ''), yonetici_taraf_id = new.yonetici_taraf_id,
               sube_id = coalesce(new.sube_id, 0),
               calisma_sekli = coalesce(new.calisma_sekli, 0),
               sozlesme_turu = coalesce(new.sozlesme_turu, 0),
               degistiren = new.degistiren, degistirme_tarihi = now()
         where id = v_var;
    else
        insert into public.personel_hareket
               (taraf_id, tur, yururluk, gorev, yonetici_taraf_id, sube_id,
                calisma_sekli, sozlesme_turu, aciklama, kaynak, ekleyen)
        values (new.id,
                case when new.gorev is distinct from old.gorev then 2
                     when new.yonetici_taraf_id is distinct from old.yonetici_taraf_id then 4
                     when new.sube_id is distinct from old.sube_id then 5
                     else 6 end,
                current_date, coalesce(new.gorev, ''), new.yonetici_taraf_id,
                coalesce(new.sube_id, 0), coalesce(new.calisma_sekli, 0),
                coalesce(new.sozlesme_turu, 0),
                'Personel kartından türetildi.', 2, new.degistiren);
    end if;
    return null;
end $$;

drop trigger if exists tr_personel_kadro_iz on public.taraf_personel;
create trigger tr_personel_kadro_iz
  after update of gorev, yonetici_taraf_id, sube_id, calisma_sekli, sozlesme_turu
  on public.taraf_personel
  for each row execute function public.tg_personel_kadro_iz();

-- ----------------------------------------------------------- görünüm ----
drop view if exists public.v_personel_hareket;
create view public.v_personel_hareket as
select h.id, h.taraf_id,
       coalesce(t.unvan, '')                              as personel_ad,
       coalesce(p.sicil_no, '')                           as sicil_no,
       h.tur,
       coalesce(kd.ad, '')                                as tur_adi,
       h.yururluk, h.bitis,
       -- SÜRELİ Mİ: vekâlet/askı satırının bitişi belli.
       case when h.bitis is not null then 1 else 0 end::smallint as sureli,
       -- BUGÜN GEÇERLİ Mİ: kartta görünen satır hangisi.
       case when h.yururluk <= current_date
             and (h.bitis is null or h.bitis >= current_date)
             and h.id = (select h2.id from public.personel_hareket h2
                          where h2.taraf_id = h.taraf_id
                            and h2.yururluk <= current_date
                            and (h2.bitis is null or h2.bitis >= current_date)
                          order by h2.yururluk desc, h2.id desc limit 1)
            then 1 else 0 end::smallint                    as gecerli,
       case when h.yururluk > current_date then 1 else 0 end::smallint as ileri,
       h.gorev, h.gorev_id,
       coalesce(g.ad, '')                                 as gorev_adi,
       h.departman_id, coalesce(d.ad, '')                 as departman_adi,
       h.yonetici_taraf_id, coalesce(y.unvan, '')         as yonetici_ad,
       h.sube_id, coalesce(s.ad, '')                      as sube_adi,
       h.calisma_sekli, h.sozlesme_turu, h.unvan,
       h.karar_no, h.belge_no, h.gerekce, h.aciklama, h.kaynak,
       h.ekleyen, h.ekleme_tarihi
  from public.personel_hareket h
  left join public.taraf t            on t.id = h.taraf_id
  left join public.taraf_personel p   on p.id = h.taraf_id
  left join public.taraf y            on y.id = h.yonetici_taraf_id
  left join public.personel_gorev g   on g.id = h.gorev_id
  left join public.departman d        on d.id = h.departman_id
  left join public.sube s             on s.id = h.sube_id
  left join public.kod_liste kl       on kl.kod = 'ik.hareket_tur'
  left join public.kod_deger kd       on kd.liste_id = kl.id and kd.deger = h.tur;

comment on view public.v_personel_hareket is
  '840: kadro hareketleri - gecerli/ileri tarihli/sureli isaretleriyle.';

-- ------------------------------------------------------------- dolgu ----
-- İŞE GİRİŞ HAREKETİ: elimizde KESİN olan tek tarih `ise_giris_tarihi`.
--   Sonraki değişiklikler `islem_log`'dan TAHMİN edilebilirdi ama orada
--   yürürlük tarihi yok - tahmini geçmişi gerçekmiş gibi yazmak, defteri
--   işe yaramaz kılardı. Yalnız giriş satırı yazılır.
insert into public.personel_hareket
       (taraf_id, tur, yururluk, gorev, yonetici_taraf_id, sube_id,
        calisma_sekli, sozlesme_turu, aciklama, kaynak, ekleyen)
select p.id, 1, p.ise_giris_tarihi, coalesce(p.gorev, ''), p.yonetici_taraf_id,
       coalesce(p.sube_id, 0), coalesce(p.calisma_sekli, 0),
       coalesce(p.sozlesme_turu, 0),
       'İşe giriş (kart verisinden dolduruldu).', 3, 0
  from public.taraf_personel p
 where p.ise_giris_tarihi is not null
   and not exists (select 1 from public.personel_hareket h
                    where h.taraf_id = p.id and h.tur = 1);

do $$
declare v_h integer; v_p integer;
begin
    select count(*) into v_h from public.personel_hareket;
    select count(*) into v_p from public.taraf_personel where ise_giris_tarihi is not null;
    raise notice '840 tamam: % kadro hareketi (% personelde ise giris tarihi vardi). '
                 'Kart artik hareketten turetiliyor; elle duzenleme de iz birakiyor.',
                 v_h, v_p;
end $$;
