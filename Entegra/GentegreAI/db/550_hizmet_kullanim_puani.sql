-- =====================================================================
--  550_hizmet_kullanim_puani.sql
--  HİZMET KULLANIM PUANI: sistem kendi kendine öğrensin.
--
--  Kullanıcı: "kullanıcı sadece isterse kısa ad girsin. onun dışında sistem
--  polikliniğe göre seçilen işleri zamanla puanlayarak onları öne çıkarmalı,
--  diğerleri çok geride kalmalı. sistem kendiliğinden yürüsün. belki 1 sene
--  sonra hiç kullanılmamış hizmetler otomatik olarak pasife geçecek."
--
--  KATALOG 10.066 KALEM: kurumun gerçekte yaptığı iş bunun küçük bir alt
--  kümesi ama hangi alt küme olduğunu KİMSE elle işaretlemek istemiyor -
--  haklı olarak. Cevap: kullanımın kendisi veri.
--
--  ÜÇ PARÇA
--
--  1) SAYAÇ. Bir hizmet bir belgeye (başvuru/ücretleme) kalem olarak girdiğinde
--     `hizmet_kullanim` satırı güncellenir. Anahtar BÖLÜM + HİZMET: kardiyoloji
--     ile dahiliyenin listesi aynı olmamalı. Bölümü olmayan belgede (ERP satışı)
--     bölüm 0 - "kurum geneli" kovası.
--
--  2) ZAMAN AĞIRLIKLI PUAN. Her kullanımda puan şöyle güncellenir:
--
--         puan = puan * 0.5 ^ (geçen_gün / yarılanma) + 1
--
--     Yani eski kullanımlar kendiliğinden sönümlenir (yarılanma varsayılan
--     90 gün): geçen sene günde 20 kez istenen ama artık istenmeyen tetkik
--     birkaç ayda geri düşer, yeni yükselen öne çıkar. GECE ÇALIŞAN BİR İŞE
--     GEREK YOK - sönümleme okuma ve yazma anında hesaplanır (`fn_hizmet_puan`).
--
--  3) OTOMATİK PASİFE ALMA. `fn_hizmet_kullanilmayan_pasife(gün)`: verilen süre
--     boyunca HİÇ kullanılmamış hizmetleri `profil_pasif = 1` yapar (531: bu
--     bayrak listelerden ve ağaçtan gizler, kaydı SİLMEZ). Zamanlı iş haftalık
--     çağırır.
--
--     İKİ EMNİYET:
--       - İZLEME SÜRESİ: sayaç bugün başlıyor. Kurulumdan itibaren `gün` kadar
--         süre geçmeden hiçbir şey pasife alınmaz, yoksa ilk hafta bütün
--         katalog kapanırdı. Başlangıç `referans` tablosunda.
--       - GEÇMİŞE DE BAKAR: sayaç boş olsa bile o hizmet son `gün` içinde bir
--         belgede geçtiyse dokunulmaz.
--
--     GERİ DÖNÜŞÜ VAR: arama penceresinde "tüm katalog" seçilip kalem
--     kullanıldığında sayaç yeniden yazar ve `profil_pasif` düşer (tetik).
-- =====================================================================

-- ------------------------------------------------------------- sayac tablosu --
create table if not exists public.hizmet_kullanim (
    -- 0 = bolumsuz (ERP satisi, kurum geneli)
    bolum_id   integer   not null default 0,
    hizmet_id  integer   not null references public.hizmet(id) on delete cascade,
    say        integer   not null default 0,
    -- Zaman agirlikli puan: sonumlenmis gecmis + 1 (bkz. fn_hizmet_kullan).
    puan       numeric(14,4) not null default 0,
    ilk_tarih  timestamp not null default now()::timestamp,
    son_tarih  timestamp not null default now()::timestamp,
    primary key (bolum_id, hizmet_id)
);

comment on table public.hizmet_kullanim is
  'Bolum bazli hizmet kullanim sayaci ve zaman agirlikli puani (550).';

create index if not exists ix_hizmet_kullanim_puan
    on public.hizmet_kullanim (bolum_id, puan desc);
create index if not exists ix_hizmet_kullanim_hizmet
    on public.hizmet_kullanim (hizmet_id);

-- Puanin yarilanma suresi (gun). Ayar tablosunda: kurum isterse
--   "son 3 ay" yerine "son 1 ay" davranisi ister.
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'hizmet.puan_yarilanma_gun', '90', 'sayi', 'firma',
       'Hizmet kullanim puaninin yarilanma suresi (gun). Kucuk deger = daha cabuk unutur.'
 where not exists (select 1 from public.referans where anahtar = 'hizmet.puan_yarilanma_gun');

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'hizmet.oto_pasif_gun', '365', 'sayi', 'firma',
       'Bu kadar gun hic kullanilmayan hizmet otomatik pasife alinir (0 = kapali).'
 where not exists (select 1 from public.referans where anahtar = 'hizmet.oto_pasif_gun');

-- Sayacin BASLADIGI an: otomatik pasifleme bu tarihten itibaren sure dolmadan
--   calismaz. Elle degistirilebilir (goc yeniden kurulursa tarih tazelenir).
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'hizmet.kullanim_izleme_baslangic', to_char(now(), 'YYYY-MM-DD'), 'metin', 'firma',
       'Hizmet kullanim izlemesinin basladigi tarih - oto pasifleme bundan once calismaz.'
 where not exists (select 1 from public.referans
                    where anahtar = 'hizmet.kullanim_izleme_baslangic');

-- --------------------------------------------------------- puan fonksiyonlari --
-- OKUMA: puanin BUGUNKU degeri. Tabloda duran puan son kullanim anina aittir;
--   aradan gecen sure kadar sonumlenir. Siralama her zaman bunu kullanir.
create or replace function public.fn_hizmet_puan(
    p_puan numeric, p_son timestamp, p_yarilanma numeric default null)
returns numeric language sql immutable as $$
    select round(coalesce(p_puan, 0)
                 * power(0.5, greatest(extract(epoch from (now()::timestamp - p_son)) / 86400.0, 0)
                              / nullif(coalesce(p_yarilanma, 90), 0)), 4);
$$;

comment on function public.fn_hizmet_puan(numeric, timestamp, numeric) is
  'Kullanim puaninin bugunku (sonumlenmis) degeri - 550.';

-- YAZMA: bir kullanim isle. Bolum yoksa 0 kovasina yazilir.
create or replace function public.fn_hizmet_kullan(
    p_hizmet integer, p_bolum integer default 0, p_adet integer default 1)
returns void language plpgsql as $$
declare
    v_yarilanma numeric;
begin
    if p_hizmet is null then return; end if;

    select coalesce(nullif(deger, '')::numeric, 90) into v_yarilanma
      from public.referans where anahtar = 'hizmet.puan_yarilanma_gun';
    v_yarilanma := coalesce(v_yarilanma, 90);

    insert into public.hizmet_kullanim (bolum_id, hizmet_id, say, puan)
    values (coalesce(p_bolum, 0), p_hizmet, p_adet, p_adet)
    on conflict (bolum_id, hizmet_id) do update
       set say = public.hizmet_kullanim.say + excluded.say,
           -- Eski puan once SONUMLENIR, sonra yeni kullanim eklenir.
           puan = public.fn_hizmet_puan(public.hizmet_kullanim.puan,
                                        public.hizmet_kullanim.son_tarih, v_yarilanma)
                  + excluded.say,
           son_tarih = now()::timestamp;

    -- KULLANILAN HIZMET YENIDEN ACILIR: otomatik pasife alinmis bir kalem
    --   birisi tarafindan bilerek secildiyse, karar yanlismis demektir.
    update public.hizmet set profil_pasif = 0
     where id = p_hizmet and profil_pasif = 1;
end $$;

comment on function public.fn_hizmet_kullan(integer, integer, integer) is
  'Bir hizmet kullanimini isler: sayac + sonumlenmis puan; pasife alinmisi acar (550).';

-- ----------------------------------------------------------------- tetikler --
-- BELGE KALEMI = KULLANIM. Baslangic noktasi budur: basvuruda ucretlenen,
--   satista faturalanan hizmet "istenen hizmet"tir. Bolum belgenin basvuru
--   uzantisindan okunur (yoksa 0).
create or replace function public.fn_belge_satir_hizmet_kullanim()
returns trigger language plpgsql as $$
declare v_bolum integer;
begin
    if new.hizmet_id is null then return new; end if;
    select coalesce(b.bolum_id, 0) into v_bolum
      from public.belge_basvuru b where b.id = new.belge_id;
    perform public.fn_hizmet_kullan(new.hizmet_id, coalesce(v_bolum, 0), 1);
    return new;
end $$;

drop trigger if exists tg_belge_satir_hizmet_kullanim on public.belge_satir;
create trigger tg_belge_satir_hizmet_kullanim
    after insert on public.belge_satir
    for each row execute function public.fn_belge_satir_hizmet_kullanim();

-- RADYOLOJI ISTEMI de kullanimdir: istem ucretlemeye her zaman ayni gun
--   dusmuyor, ama hekimin SECTIGI tetkik odur.
do $$
begin
    if exists (select 1 from information_schema.columns
                where table_name = 'radyoloji_istem' and column_name = 'hizmet_id') then
        execute $t$
            create or replace function public.fn_rad_istem_hizmet_kullanim()
            returns trigger language plpgsql as $f$
            declare v_bolum integer;
            begin
                if new.hizmet_id is null then return new; end if;
                select coalesce(b.bolum_id, 0) into v_bolum
                  from public.belge_basvuru b where b.id = new.belge_id;
                perform public.fn_hizmet_kullan(new.hizmet_id, coalesce(v_bolum, 0), 1);
                return new;
            end $f$;
        $t$;
        execute 'drop trigger if exists tg_rad_istem_hizmet_kullanim on public.radyoloji_istem';
        execute 'create trigger tg_rad_istem_hizmet_kullanim after insert on public.radyoloji_istem '
              || 'for each row execute function public.fn_rad_istem_hizmet_kullanim()';
    end if;
end $$;

-- ------------------------------------------------------ otomatik pasife alma --
create or replace function public.fn_hizmet_kullanilmayan_pasife(
    p_gun integer default null, p_deneme boolean default false)
returns table (pasife_alinan integer, aciklama text)
language plpgsql as $$
declare
    v_gun       integer;
    v_baslangic date;
    v_sayi      integer := 0;
begin
    select coalesce(nullif(deger, '')::integer, 365) into v_gun
      from public.referans where anahtar = 'hizmet.oto_pasif_gun';
    v_gun := coalesce(p_gun, v_gun, 365);
    if v_gun <= 0 then
        return query select 0, 'Otomatik pasife alma kapali (hizmet.oto_pasif_gun = 0).'::text;
        return;
    end if;

    select coalesce(nullif(deger, '')::date, current_date) into v_baslangic
      from public.referans where anahtar = 'hizmet.kullanim_izleme_baslangic';
    v_baslangic := coalesce(v_baslangic, current_date);

    -- IZLEME SURESI DOLMADI: sayac heniz o kadar veri gormedi, "hic
    --   kullanilmadi" demek yaniltici olurdu.
    if current_date - v_baslangic < v_gun then
        return query select 0,
            format('Izleme suresi dolmadi: %s gunun %s gunu gecti.',
                   v_gun, current_date - v_baslangic)::text;
        return;
    end if;

    create temporary table zz_pasif_aday on commit drop as
    select h.id
      from public.hizmet h
     where h.baslik_mi = 0
       and h.durum = 1
       and h.profil_pasif = 0
       -- Sayacta hic gorunmemis ya da son kullanimi eski
       and not exists (
             select 1 from public.hizmet_kullanim k
              where k.hizmet_id = h.id
                and k.son_tarih >= now()::timestamp - make_interval(days => v_gun))
       -- GECMISE DE BAKILIR: sayac bos olsa bile belgede gectiyse dokunma
       and not exists (
             select 1 from public.belge_satir bs
               join public.belge b on b.id = bs.belge_id
              where bs.hizmet_id = h.id
                and b.belge_tarihi >= now()::timestamp - make_interval(days => v_gun));

    select count(*) into v_sayi from zz_pasif_aday;

    if not p_deneme then
        update public.hizmet h set profil_pasif = 1
          from zz_pasif_aday a where a.id = h.id;
    end if;

    return query select v_sayi,
        format('%s gun kullanilmayan %s hizmet %s.', v_gun, v_sayi,
               case when p_deneme then 'bulundu (deneme)' else 'pasife alindi' end)::text;
end $$;

comment on function public.fn_hizmet_kullanilmayan_pasife(integer, boolean) is
  'Kullanilmayan hizmetleri profil_pasif yapar; deneme kipinde yalniz sayar (550).';

-- ------------------------------------------------------------- zamanli is ----
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aciklama)
select 'hizmet.oto_pasif', 'Kullanılmayan hizmetleri pasife al', 4, 1, 3, 30,
       'Haftalik: hizmet.oto_pasif_gun kadar sure kullanilmayan hizmetleri profil_pasif yapar.'
 where not exists (select 1 from public.zamanli_is where kod = 'hizmet.oto_pasif');
