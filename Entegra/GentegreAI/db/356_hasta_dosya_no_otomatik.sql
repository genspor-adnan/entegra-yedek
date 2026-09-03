-- ============================================================================
--  356 - HASTA DOSYA NO OTOMATIK URETIMI (kullanici)
--
--  "hasta sekmesine dosya no ... otomatik üretilsin ayarı ekle" - Kayıt Kabul
--  Ayarları > Hasta sekmesindeki `hasta.dosya_no_otomatik` ayari.
--
--  Uretim DB TARAFINDA: hasta kaydi kart ekranindan da, API'den de, radyoloji
--  isteminden de acilabiliyor; kural tek yerde dursun.
--
--  Kural: yeni HASTA (taraf.grup = 101) satirinda kod BOS ise ve ayar 1 ise
--  siradan numara verilir. Ayar kapaliysa (varsayilan 0) davranis degismez -
--  kod zorunlu alan olarak elle girilir.
--
--  Numara bicimi: sifir dolgulu 8 hane ("00000001"). Sequence, mevcut TAMAMEN
--  SAYISAL kodlarin en buyugunden devam eder; harfli eski kodlar (H2026-002)
--  dikkate alinmaz - onlar elle verilmis dosya numaralaridir.
-- ============================================================================

create sequence if not exists public.hasta_dosya_no_seq as bigint start with 1;

-- Mevcut sayisal kodlarin uzerinden devam et (idempotent: her calistirmada
-- yalnizca ILERI alinir, geri alinmaz).
do $$
declare v_max bigint;
begin
    select coalesce(max(kod::bigint), 0) into v_max
      from public.taraf
     where grup = 101 and kod ~ '^[0-9]{1,15}$';
    if v_max >= coalesce((select last_value from public.hasta_dosya_no_seq), 0) then
        perform setval('public.hasta_dosya_no_seq', v_max + 1, false);
    end if;
end $$;

create or replace function public.fn_hasta_dosya_no()
returns character varying
language sql
as $$
    select lpad(nextval('public.hasta_dosya_no_seq')::text, 8, '0')::varchar;
$$;

comment on function public.fn_hasta_dosya_no() is
  'Siradaki hasta dosya numarasi (356): sifir dolgulu 8 hane.';

create or replace function public.tg_taraf_hasta_dosya_no()
returns trigger
language plpgsql
as $$
begin
    -- Yalniz HASTA (grup 101) ve kod bos birakilmissa.
    if coalesce(new.grup, 0) <> 101 or coalesce(btrim(new.kod), '') <> '' then
        return new;
    end if;
    -- Ayar: 1 = otomatik uret. Ayar satiri yoksa/0 ise dokunma (kod bos kalir,
    --   uygulamanin "zorunlu alan" kurali devreye girer).
    if coalesce((select r.deger from public.referans r
                  where r.anahtar = 'hasta.dosya_no_otomatik'), '0') <> '1' then
        return new;
    end if;
    new.kod := public.fn_hasta_dosya_no();
    return new;
end $$;

drop trigger if exists tr_taraf_hasta_dosya_no on public.taraf;
create trigger tr_taraf_hasta_dosya_no before insert on public.taraf
    for each row execute function public.tg_taraf_hasta_dosya_no();

-- Ayar satirlari (ekran beyaz listeden okur; burada aciklama ile yaratilir).
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, v.tip, 'firma', v.aciklama
  from (values
        ('hasta.dosya_no_otomatik', '0', 'sayi',
         'Hasta dosya numarasi bos birakilirsa otomatik uretilsin (0/1)'),
        ('basvuru.protokol_no_otomatik', '1', 'sayi',
         'Basvuru protokol numarasi kaydederken otomatik verilsin (0/1)')
       ) as v(anahtar, deger, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);
