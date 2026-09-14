-- ============================================================================
--  Gentegre AI — ÇOK ROLLÜ KULLANICI
--  665_cok_rollu_kullanici.sql
--
--  Kullanıcı: "çok rollülük ekle"
--
--  NEDEN: bir kullanıcı tek role bağlıydı (taraf_kullanici.rol_id). Doktor
--  aynı anda "İskonto Onaylayanlar" olamıyordu; onay rolüne alınan hekim
--  hekimliğini kaybediyordu (664/663). Gerçek kurumda kişi bir işin yanında
--  bir de görev taşır - rol kutusunu tek seçimli bırakmak, yetkiyi tek tek
--  kopyalamaya ya da "her şeyi açık" bir süper rol uydurmaya zorluyordu.
--
--  MODEL: ANA ROL + EK ROLLER
--   · `taraf_kullanici.rol_id`  ANA ROL olarak KALIR - kişinin asıl işi
--     ("Doktor"). Token'daki rolId, ekranlardaki "rolü", loglar ve raporlar
--     bu alanı okumaya devam eder; NOT NULL olduğu için hiçbir çağıran
--     boş rol ihtimalini düşünmek zorunda kalmaz.
--   · `kullanici_rol`           EK ROLLER - kişinin ayrıca taşıdığı görevler
--     ("İskonto Onaylayanlar"). Sıfır ya da çok sayıda olabilir.
--
--  Ana rolü kaldırıp her şeyi tabloya taşımak daha "temiz" görünürdü ama
--  rol_id'yi okuyan onlarca sorgu (giriş, şube, prim, log) aynı anda
--  değişmek zorunda kalırdı; kırılma yüzeyi kazançtan büyüktü.
--
--  YETKİ BİRLEŞİMİ: rollerin BİRLEŞİMİ alınır, en geniş olan kazanır.
--   · gör/ekle/değiştir/sil : herhangi bir rolde 1 ise 1.
--   · sayısal sınır (deger) : EN YÜKSEK tavan (iskonto %10 + %25 = %25).
--     Kişiye iki rol veren yönetici, ikisinin toplamını vermiş sayılır -
--     "en dar olan kazansın" deseydik, ek rol vermek yetkiyi DÜŞÜREBİLİRDİ;
--     kimse rol eklemenin bir şeyi kısıtlamasını beklemez.
--   · alan yetkisi (rol_alan_yetki): satır YOKSA alan serbest (tablonun
--     kendi kuralı). Rollerden biri alanı hiç kısıtlamıyorsa alan serbest
--     kalır - kısıtlama ancak TÜM roller kısıtlıyorsa sürer, en yükseği
--     geçerli olur.
--
--  ÖNBELLEK: yetki seti bellekte tutulur ve `yetki_surumu` DEĞİŞİNCE
--  yenilenir (YetkiCozucu). Tek rolde bu rolün sürüm sayacıydı; artık
--  kullanıcının TÜM rol kümesinin parmak izi: rol eklenince/çıkınca ya da
--  rollerden birinin yetkisi değişince değer değişir. Sayaç değil HASH
--  kullanıldı - karşılaştırma zaten eşitlik testi (büyüklük değil), ve
--  "rol ekle + rol çıkar" gibi çift değişiklikte toplam sayaç aynı kalıp
--  yetkiyi eskimiş göstermesin.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) EK ROL TABLOSU
-- ---------------------------------------------------------------------------
create table if not exists public.kullanici_rol (
    kullanici_id      integer   not null,
    rol_id            integer   not null,
    ekleyen           integer   not null default 0,
    ekleme_tarihi     timestamp not null default now()::timestamp,
    constraint pk_kullanici_rol primary key (kullanici_id, rol_id),
    constraint fk_kullanici_rol_kul foreign key (kullanici_id)
        references public.taraf_kullanici (id) on delete cascade,
    constraint fk_kullanici_rol_rol foreign key (rol_id)
        references public.rol (id) on delete cascade
);

create index if not exists ix_kullanici_rol_rol on public.kullanici_rol (rol_id);

comment on table public.kullanici_rol is
  'Kullanicinin EK rolleri (665). Ana rol taraf_kullanici.rol_id''dedir; '
  'etkili yetki ikisinin BIRLESIMIDIR. Ayni rol iki yerde durmaz.';

-- Ek rol ANA ROL ile ayni olamaz: ayni rol iki yerde durursa "cikardim ama
--   hala var" gorunur, kullanici hangisini kaldiracagini bilemez.
create or replace function public.fn_kullanici_rol_dogrula()
returns trigger language plpgsql as $$
declare v_ana integer;
begin
    select rol_id into v_ana from public.taraf_kullanici where id = new.kullanici_id;
    if v_ana = new.rol_id then
        raise exception 'Bu rol kullanıcının ana rolü - ek rol olarak eklenemez.'
              using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tg_kullanici_rol_dogrula on public.kullanici_rol;
create trigger tg_kullanici_rol_dogrula
    before insert or update on public.kullanici_rol
    for each row execute function public.fn_kullanici_rol_dogrula();

-- Ana rol DEGISINCE, yeni ana rol ek roller arasindaysa oradan dusulur -
--   aksi halde yukaridaki kural gecmise donuk ihlal edilmis olurdu.
create or replace function public.fn_kullanici_ana_rol_temizle()
returns trigger language plpgsql as $$
begin
    if new.rol_id is distinct from old.rol_id then
        delete from public.kullanici_rol
         where kullanici_id = new.id and rol_id = new.rol_id;
    end if;
    return new;
end $$;

drop trigger if exists tg_kullanici_ana_rol_temizle on public.taraf_kullanici;
create trigger tg_kullanici_ana_rol_temizle
    after update of rol_id on public.taraf_kullanici
    for each row execute function public.fn_kullanici_ana_rol_temizle();

-- ---------------------------------------------------------------------------
--  2) KULLANICININ ROLLERİ — tek kapı
-- ---------------------------------------------------------------------------
create or replace function public.fn_kullanici_rolleri(p_kullanici_id integer)
returns table (rol_id integer, ana smallint)
language sql stable as $$
    select k.rol_id, 1::smallint
      from public.taraf_kullanici k
     where k.id = p_kullanici_id and k.aktif = 1
    union all
    select kr.rol_id, 0::smallint
      from public.kullanici_rol kr
      join public.taraf_kullanici k on k.id = kr.kullanici_id and k.aktif = 1
     where kr.kullanici_id = p_kullanici_id
$$;

comment on function public.fn_kullanici_rolleri(integer) is
  'Kullanicinin etkili rolleri: ana rol (ana = 1) + ek roller (ana = 0) - 665.';

-- ---------------------------------------------------------------------------
--  3) YETKİ ÇÖZÜMÜ — rollerin birleşimi
--
--     İmza 661 ile aynı: kolonlar ve sıraları değişmedi, yalnız kaynak tek
--     rol yerine rol KÜMESİ oldu.
--
--     `deger` sayısal ise EN YÜKSEĞİ; hepsi metinse en büyük metin. İki rol
--     '10' ve '25' verdiyse sonuç '25' - trailing sıfır üretmemek için
--     normalize edilir ('25.0' değil '25').
-- ---------------------------------------------------------------------------
drop function if exists public.fn_kullanici_yetkileri(integer);

create function public.fn_kullanici_yetkileri(p_kullanici_id integer)
returns table (yetki_kod varchar, tur smallint, gor smallint, ekle smallint,
               degistir smallint, sil smallint, deger varchar)
language sql stable as $$
    select t.kod, t.tur, t.gor, t.ekle, t.degistir, t.sil,
           -- Tam sayi ise ondalik BASILMAZ: '100' beklenirken '100.0' donmesi,
           --   degeri metin olarak karsilastiran her yeri sessizce bozardi.
           coalesce(
             case when t.sayi is null            then null
                  when t.sayi = trunc(t.sayi)    then t.sayi::bigint::text
                  else t.sayi::text end,
             t.metin, '')::varchar as deger
      from (
        select y.kod, y.tur,
               max(ry.gor)::smallint      as gor,
               max(ry.ekle)::smallint     as ekle,
               max(ry.degistir)::smallint as degistir,
               max(ry.sil)::smallint      as sil,
               max(case when ry.deger ~ '^[0-9]+(\.[0-9]+)?$'
                        then ry.deger::numeric end) as sayi,
               max(nullif(ry.deger, ''))             as metin
          from public.fn_kullanici_rolleri(p_kullanici_id) kr
          join public.rol_yetki ry on ry.rol_id = kr.rol_id
          join public.yetki y      on y.id = ry.yetki_id and y.aktif = 1
         group by y.kod, y.tur
        having max(ry.gor) = 1 or max(ry.ekle) = 1
            or max(ry.degistir) = 1 or max(ry.sil) = 1
      ) t
$$;

comment on function public.fn_kullanici_yetkileri(integer) is
  'Kullanicinin TUM rollerinden (ana + ek) cozulen yetkiler; bayraklar OR, '
  'deger = en yuksek sinir (665; 661 imzasi korundu).';

-- ---------------------------------------------------------------------------
--  4) ALAN YETKİLERİ — rollerin birleşimi
--
--     Kural: satır YOKSA alan serbest. Rollerden biri alanı hiç kısıtlamıyorsa
--     alan serbest kalır (satır DÖNMEZ); hepsi kısıtlıyorsa en geniş izin.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kullanici_alan_yetkileri(p_kullanici_id integer)
returns table (kaynak varchar, alan varchar, izin smallint)
language sql stable as $$
    with roller as (
        select kr.rol_id from public.fn_kullanici_rolleri(p_kullanici_id) kr
    )
    select ay.kaynak, ay.alan, max(ay.izin)::smallint
      from public.rol_alan_yetki ay
      join roller r on r.rol_id = ay.rol_id
     group by ay.kaynak, ay.alan
    -- Kisitlamayi TASIMAYAN bir rol varsa alan serbesttir.
    having count(*) = (select count(*) from roller)
$$;

comment on function public.fn_kullanici_alan_yetkileri(integer) is
  'Alan yetkilerinin rol birlesimi: kisitlamayi tasimayan tek bir rol bile '
  'alani serbest birakir, aksi halde en genis izin gecerlidir (665).';

-- ---------------------------------------------------------------------------
--  5) YETKİ SÜRÜMÜ — rol kümesinin parmak izi
--
--     Önbellek bunu EŞİTLİKLE karşılaştırır (YetkiCozucu). Değer değiştiyse
--     yetki yeniden çözülür. Kümeye rol girip çıkması da, bir rolün kendi
--     sürümünün artması da parmak izini değiştirir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kullanici_yetki_surumu(p_kullanici_id integer)
returns bigint language sql stable as $$
    select coalesce(
        hashtextextended(
            string_agg(kr.rol_id::text || ':' || r.yetki_surumu::text, ',' order by kr.rol_id),
            0),
        0)
      from public.fn_kullanici_rolleri(p_kullanici_id) kr
      join public.rol r on r.id = kr.rol_id
$$;

comment on function public.fn_kullanici_yetki_surumu(integer) is
  'Kullanicinin rol kumesinin (ana + ek) parmak izi; degisince yetki onbellegi '
  'tazelenir (665). Sayac degil HASH - buyukluk degil esitlik karsilastirilir.';

-- ---------------------------------------------------------------------------
--  6) KULLANICININ ŞUBELERİ — rollerin birleşimi
--
--     Şube yetkisi rolden gelir (234). Çok rolde şubeler birleşir; aynı şube
--     iki rolde varsa YAZMA hakkı geniş olan kazanır, varsayılan şube ANA
--     ROLden gelir (kişinin açılış şubesi işine göre belirlenir, ek görevine
--     göre değil).
-- ---------------------------------------------------------------------------
create or replace function public.fn_kullanici_subeleri(p_kullanici_id integer)
returns table (sube_id integer, ad varchar, varsayilan smallint, yazma smallint)
language sql stable as $$
    select s.id, s.ad,
           max(case when kr.ana = 1 then rs.varsayilan else 0 end)::smallint,
           max(rs.yazma)::smallint
      from public.fn_kullanici_rolleri(p_kullanici_id) kr
      join public.rol_sube rs on rs.rol_id = kr.rol_id
      join public.sube s      on s.id = rs.sube_id and s.aktif = 1
     group by s.id, s.ad
$$;

comment on function public.fn_kullanici_subeleri(integer) is
  'Kullanicinin subeleri: rollerin birlesimi, yazma hakki en genis olan, '
  'varsayilan sube ANA ROLden (665/234).';

-- ---------------------------------------------------------------------------
--  DOĞRULAMA
-- ---------------------------------------------------------------------------
do $$
declare v_kul integer; v_surum bigint;
begin
    select min(id) into v_kul from public.taraf_kullanici where aktif = 1;
    if v_kul is not null then
        select public.fn_kullanici_yetki_surumu(v_kul) into v_surum;
        raise notice '665 tamam: ornek kullanici % · rol sayisi % · yetki % · surum %',
            v_kul,
            (select count(*) from public.fn_kullanici_rolleri(v_kul)),
            (select count(*) from public.fn_kullanici_yetkileri(v_kul)),
            v_surum;
    end if;
end $$;
