-- ============================================================================
--  Gentegre AI — Numara sablonu: durum yonu duzeltmesi + tum turler icin seed
--  154_numara_sablonu_seed.sql
--
--  Kullanici: "default tum gridler dolu olsun; son sutun durum rozetli; alis
--  belgeleri pasif digerleri aktif olsun."
--
--  IKI DUZELTME + SEED
--
--  1) DURUM YONU. 152'de `durum` "0 aktif / 1 pasif" yazilmisti; projenin geri
--     kalani ve grid rozeti TERSINI kullaniyor (KartKatalogu.DurumKodlari:
--     1 = Aktif, 0 = Pasif; gridHucre.durumRozeti 1'i yesil yaziyor). Tek satir
--     bile veri yokken duzeltiliyor - yoksa "Aktif" yazan satir pasif davranirdi.
--
--  2) SEED. Her numaralanabilir tur icin bir satir; grid bos acilmasin.
--     ALIS BELGELERI PASIF: alis faturasinin numarasi TEDARIKCININ numarasidir
--     (dis numarali belge), bizim serimiz uygulanmaz - satir dursun ki kullanici
--     istisna istedigi gun aktife alsin.
--
--  BASLANGIC NUMARASI MEVCUT KAYITLARDAN: sistemde o turden belge/makbuz varsa
--     sayac en buyuk numaranin USTUNDEN devam eder. Sabit "000001" verilseydi
--     ilk yeni belge var olan bir numarayi tekrar alirdi. Hane de mevcut
--     numaranin uzunlugundan gelir (en az 6).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------- 1) durum yonu ------
alter table public.numara_sablonu alter column durum set default 1;
comment on column public.numara_sablonu.durum is
  '1 = Aktif (bu numaralama uygulanir), 0 = Pasif. Proje genelindeki yonle ayni (154).';

-- Veri CEVIRMESI YOK. 152 ile 154 arasinda bu tabloya kayit girmedi (ozellik
--   yeni; sunucuda da tablo bostu). Bir "durumu ters cevir" update'i yazilsaydi
--   migration TEKRAR calistiginda butun satirlari bozardi - idempotent olmazdi.
--   Elde kalmis deneme satiri varsa asagidaki seed onu atlar, kullanici duzeltir.

-- Sablon secimi de yeni yonu okumali.
create or replace function public.fn_numara_sablonu_bul(
        p_tur integer, p_sube_id integer, p_tarih date)
returns public.numara_sablonu
language sql stable as $$
    select s.*
      from public.numara_sablonu s
     where s.tur = p_tur
       and s.durum = 1                         -- 154: 1 = aktif
       and s.sube_id in (coalesce(p_sube_id, 0), 0)
       and s.baslama_tarihi <= coalesce(p_tarih, current_date)
     order by (s.sube_id = coalesce(p_sube_id, 0)) desc, s.baslama_tarihi desc
     limit 1
$$;

comment on function public.fn_numara_sablonu_bul(integer, integer, date) is
  'Verilen tur/sube/tarih icin YURURLUKTEKI (durum=1) numara sablonu; yoksa bos satir.';

-- ------------------------------------------------------------- 2) seed ------
do $$
declare
    r          record;
    v_son      bigint;
    v_hane     integer;
    v_eklenen  integer := 0;
begin
    for r in
        -- Numaralanabilir turler + gridi + varsayilan durumu.
        select kod, 1 as durum from public.kasa_islem_turu where kod in (13,14,15,16,19,119)
        union all
        select kod, 0 from public.kasa_islem_turu where kod in (8,9,10,11,12,17,109)   -- alis: PASIF
        union all
        select kod, 1 from public.kasa_islem_turu where kod in (21,22,23,24,25,26)
        union all
        select kod, 1 from public.kasa_islem_turu where kod in (31,32,33,34,35,36,87)
    loop
        -- Zaten tanimliysa dokunma (kullanici kendi satirini girmis olabilir).
        if exists (select 1 from public.numara_sablonu n where n.tur = r.kod) then
            continue;
        end if;

        -- Mevcut en buyuk numara: belge turleri belge'den, kasa turleri
        --   kasa_islem'den okunur. Harf/on ek temizlenir, yalniz rakam kalir.
        if r.kod between 1 and 199 and exists (select 1 from public.belge b where b.tur = r.kod) then
            select max(nullif(regexp_replace(b.belge_no, '\D', '', 'g'), '')::bigint),
                   max(length(nullif(regexp_replace(b.belge_no, '\D', '', 'g'), '')))
              into v_son, v_hane
              from public.belge b
             where b.tur = r.kod and b.belge_no <> '';
        else
            select max(nullif(regexp_replace(k.islem_no, '\D', '', 'g'), '')::bigint),
                   max(length(nullif(regexp_replace(k.islem_no, '\D', '', 'g'), '')))
              into v_son, v_hane
              from public.kasa_islem k
             where k.tur = r.kod and k.islem_no <> '';
        end if;

        v_son  := coalesce(v_son, 0) + 1;
        v_hane := greatest(coalesce(v_hane, 0), 6);

        insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no, durum, aciklama)
        values (r.kod, current_date, '', lpad(v_son::text, v_hane, '0'), r.durum,
                'Kurulum varsayılanı');
        v_eklenen := v_eklenen + 1;
    end loop;

    raise notice '154 tamam: % sablon satiri eklendi (alis belgeleri pasif).', v_eklenen;
end $$;

do $$
declare v_aktif integer; v_pasif integer;
begin
    select count(*) filter (where durum = 1), count(*) filter (where durum = 0)
      into v_aktif, v_pasif from public.numara_sablonu;
    raise notice '154 durum: % aktif, % pasif satir', v_aktif, v_pasif;
end $$;
