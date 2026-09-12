-- =====================================================================
--  552_stok_ilac_kisa_ad_kullanim.sql
--  STOK ve İLAÇ için: kısa ad + kullanım puanı + otomatik pasife alma.
--
--  Kullanıcı: "aynılarını stok ve ilaç için de yap, kısa ad ve diğer
--  yaptıkların."
--
--  1) KISA AD — `stok.kisa_ad`. Hizmetteki (549) ile aynı: isteğe bağlı,
--     resmî adın yerine geçmez, aramada öncelikli.
--
--     İLAÇTA AYRI KOLON YOK. İlaç TİTCK kataloğudur (23.002 satır, dışarıdan
--     güncellenir) ve kartı yoktur - oraya yazılan bir kısa adın düzenleneceği
--     ekran da olmazdı. İlacın kısa adı, o ilaç için üretilen STOK KARTINDAN
--     gelir (`ilac.stok_id`): fatura satırı zaten stoka bağlanıyor, aynı ürünün
--     iki ayrı kısa adı olmasın.
--
--  2) KULLANIM PUANI — 550'deki sayaç stok'u da kapsayacak şekilde
--     GENELLEŞTİRİLDİ. `hizmet_kullanim` yerine `kalem_kullanim (tur, kayit_id,
--     bolum_id)`; tur 1 = stok, 2 = hizmet. Aynı mantığı iki tabloda iki kez
--     yazmak, ikisinin zamanla ayrışması demekti.
--
--     Eski tablodaki satırlar taşınır, `hizmet_kullanim` düşürülür (550 bu
--     hafta doğdu, yalnız geliştirme veritabanında var).
--
--  3) OTOMATİK PASİFE ALMA — stokta İKİ EMNİYET DAHA var, hizmette olmayan:
--       - stok bakiyesi (kalan/rezerve) sıfır değilse DOKUNULMAZ: depoda
--         duran malın kartını kapatmak sayımı ve maliyeti bozar,
--       - herhangi bir belge satırında geçmişse (tarih sınırı yok) kart
--         kapanmaz; kapanırsa eski belgeyi açan ekran boş kalem gösterir.
--     İlaç kataloğuna DOKUNULMAZ: dış kaynaklı liste, TİTCK güncellemesi
--     zaten aktifliği kendi yönetir.
-- =====================================================================

-- ------------------------------------------------------------------ kisa ad --
alter table public.stok
    add column if not exists kisa_ad varchar(60) not null default '';

comment on column public.stok.kisa_ad is
  'Kurumun gunluk dilde kullandigi kisa ad (552). Resmi ad `ad` kolonunda kalir.';

create index if not exists ix_stok_kisa_ad_trgm
    on public.stok using gin (public.fn_ara_metin(kisa_ad) gin_trgm_ops);

-- ------------------------------------------------------------ kalem sayaci --
create table if not exists public.kalem_kullanim (
    -- 1 stok · 2 hizmet
    tur        smallint  not null,
    kayit_id   integer   not null,
    -- 0 = bolumsuz (ERP satisi, kurum geneli)
    bolum_id   integer   not null default 0,
    say        integer   not null default 0,
    puan       numeric(14,4) not null default 0,
    ilk_tarih  timestamp not null default now()::timestamp,
    son_tarih  timestamp not null default now()::timestamp,
    primary key (tur, kayit_id, bolum_id)
);

comment on table public.kalem_kullanim is
  'Bolum bazli kalem kullanim sayaci ve zaman agirlikli puani (552; 550 hizmet tablosunun genellestirilmisi).';

create index if not exists ix_kalem_kullanim_puan
    on public.kalem_kullanim (tur, bolum_id, puan desc);

-- 550'nin verisi tasinir, tablo dusurulur.
do $$
begin
    if to_regclass('public.hizmet_kullanim') is not null then
        insert into public.kalem_kullanim (tur, kayit_id, bolum_id, say, puan, ilk_tarih, son_tarih)
        select 2, k.hizmet_id, k.bolum_id, k.say, k.puan, k.ilk_tarih, k.son_tarih
          from public.hizmet_kullanim k
        on conflict do nothing;
        drop table public.hizmet_kullanim;
    end if;
end $$;

-- ------------------------------------------------------------ puan yazimi ----
-- 550'deki `fn_hizmet_kullan`in tur parametreli hali.
create or replace function public.fn_kalem_kullan(
    p_tur smallint, p_kayit integer, p_bolum integer default 0, p_adet integer default 1)
returns void language plpgsql as $$
declare
    v_yarilanma numeric;
begin
    if p_kayit is null or p_tur is null then return; end if;

    select coalesce(nullif(deger, '')::numeric, 90) into v_yarilanma
      from public.referans where anahtar = 'hizmet.puan_yarilanma_gun';
    v_yarilanma := coalesce(v_yarilanma, 90);

    insert into public.kalem_kullanim (tur, kayit_id, bolum_id, say, puan)
    values (p_tur, p_kayit, coalesce(p_bolum, 0), p_adet, p_adet)
    on conflict (tur, kayit_id, bolum_id) do update
       set say = public.kalem_kullanim.say + excluded.say,
           puan = public.fn_hizmet_puan(public.kalem_kullanim.puan,
                                        public.kalem_kullanim.son_tarih, v_yarilanma)
                  + excluded.say,
           son_tarih = now()::timestamp;

    -- OTOMATIK KAPATILAN GERI ACILIR (527/551): yalniz profil_pasif isaretli
    --   olan; kullanicinin elle kapattigi kalem kapali kalir.
    if p_tur = 2 then
        update public.hizmet set durum = 1, profil_pasif = 0
         where id = p_kayit and profil_pasif = 1;
    else
        update public.stok set durum = 1, profil_pasif = 0
         where id = p_kayit and profil_pasif = 1;
    end if;
end $$;

comment on function public.fn_kalem_kullan(smallint, integer, integer, integer) is
  'Kalem kullanimini isler (tur 1 stok · 2 hizmet): sayac + sonumlenmis puan; profilin kapattigini acar (552).';

-- Geriye donuk sarmalayici: 550/551'deki ad calismaya devam etsin.
create or replace function public.fn_hizmet_kullan(
    p_hizmet integer, p_bolum integer default 0, p_adet integer default 1)
returns void language sql as $$
    select public.fn_kalem_kullan(2::smallint, p_hizmet, p_bolum, p_adet);
$$;

-- --------------------------------------------------------------- tetikler ----
-- Belge kalemi = kullanim. Stok ve hizmet AYNI tetikte: satirin hangi bagi
--   doluysa o tur islenir.
create or replace function public.fn_belge_satir_hizmet_kullanim()
returns trigger language plpgsql as $$
declare v_bolum integer;
begin
    if new.hizmet_id is null and new.stok_id is null then return new; end if;
    select coalesce(b.bolum_id, 0) into v_bolum
      from public.belge_basvuru b where b.id = new.belge_id;
    if new.hizmet_id is not null then
        perform public.fn_kalem_kullan(2::smallint, new.hizmet_id, coalesce(v_bolum, 0), 1);
    else
        perform public.fn_kalem_kullan(1::smallint, new.stok_id, coalesce(v_bolum, 0), 1);
    end if;
    return new;
end $$;

-- ------------------------------------------------- otomatik pasife alma ----
-- Hizmet: 551'deki kural, yeni tabloya bakar.
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
    if current_date - v_baslangic < v_gun then
        return query select 0,
            format('Izleme suresi dolmadi: %s gunun %s gunu gecti.',
                   v_gun, current_date - v_baslangic)::text;
        return;
    end if;

    create temporary table zz_pasif_aday on commit drop as
    select h.id
      from public.hizmet h
     where h.baslik_mi = 0 and h.durum = 1 and h.profil_pasif = 0
       and not exists (
             select 1 from public.kalem_kullanim k
              where k.tur = 2 and k.kayit_id = h.id
                and k.son_tarih >= now()::timestamp - make_interval(days => v_gun))
       and not exists (
             select 1 from public.belge_satir bs
               join public.belge b on b.id = bs.belge_id
              where bs.hizmet_id = h.id
                and b.belge_tarihi >= now()::timestamp - make_interval(days => v_gun));

    select count(*) into v_sayi from zz_pasif_aday;
    if not p_deneme then
        update public.hizmet h set durum = 0, profil_pasif = 1
          from zz_pasif_aday a where a.id = h.id;
    end if;

    return query select v_sayi,
        format('%s gun kullanilmayan %s hizmet %s.', v_gun, v_sayi,
               case when p_deneme then 'bulundu (deneme)' else 'pasife alindi' end)::text;
end $$;

-- STOK: iki emniyet daha - bakiye ve belge gecmisi.
create or replace function public.fn_stok_kullanilmayan_pasife(
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
    if current_date - v_baslangic < v_gun then
        return query select 0,
            format('Izleme suresi dolmadi: %s gunun %s gunu gecti.',
                   v_gun, current_date - v_baslangic)::text;
        return;
    end if;

    create temporary table zz_stok_pasif_aday on commit drop as
    select t.id
      from public.stok t
     where t.durum = 1 and t.profil_pasif = 0
       and not exists (
             select 1 from public.kalem_kullanim k
              where k.tur = 1 and k.kayit_id = t.id
                and k.son_tarih >= now()::timestamp - make_interval(days => v_gun))
       -- BAKIYESI OLAN KART KAPANMAZ: depoda duran mal sayimda ve maliyette
       --   gorunmeye devam etmeli.
       and not exists (
             select 1 from public.stok_durum d
              where d.stok_id = t.id
                and (coalesce(d.kalan, 0) <> 0 or coalesce(d.rezerve, 0) <> 0))
       -- HIC BELGEDE GECMEMIS olmali (tarih siniri YOK): eski belgeyi acan
       --   ekran kapatilmis kalemi bos gosterirdi.
       and not exists (select 1 from public.belge_satir bs where bs.stok_id = t.id)
       -- Ilac icin uretilmis stok karti da dokunulmaz: katalog bagi kopmasin.
       and not exists (select 1 from public.ilac i where i.stok_id = t.id);

    select count(*) into v_sayi from zz_stok_pasif_aday;
    if not p_deneme then
        update public.stok t set durum = 0, profil_pasif = 1
          from zz_stok_pasif_aday a where a.id = t.id;
    end if;

    return query select v_sayi,
        format('%s gun kullanilmayan %s stok %s.', v_gun, v_sayi,
               case when p_deneme then 'bulundu (deneme)' else 'pasife alindi' end)::text;
end $$;

comment on function public.fn_stok_kullanilmayan_pasife(integer, boolean) is
  'Kullanilmayan stok kartlarini pasife alir - bakiyesi/hareketi olan ve ilaca bagli kart haric (552).';
