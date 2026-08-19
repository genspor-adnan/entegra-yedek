-- ============================================================================
--  Gentegre AI — belge hesap alanlari (F1-05 hazirligi)
--  023_sema_belge_hesap.sql
--
--  NEDEN: dip toplam formulu (Delphi SP_PRG_FaturaDipToplami / fn_Api_Belge_DipToplam)
--    satirda ISKONTO2, OTVMIKTAR ve KDVMUHAFIYETI alanlarini kullaniyor. Bunlar
--    012'de "Faz 2'de degerlendirilecek" diye atlanmisti; onlar olmadan toplamlar
--    olculdu: 415 belgenin yalniz 343'unde matrah tutuyor.
--
--  ISKONTO2 CARPIMSAL ikinci iskontodur (kademeli), toplamsal DEGIL:
--      tutar = round(adet * birim_fiyat) * (1 - isk1/100) * (1 - isk2/100)
--    Delphi karsiligi UFaturaWizard.TutarIslemler (satir 4366-4380).
--    Mevcut veride hic kullanilmamis (499.911 satirin hepsinde 0) ama formulun
--    parcasi - kolon olmadan port birebir olamaz.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge_satir add column if not exists iskonto2      numeric(9,4)  not null default 0;
alter table public.belge_satir add column if not exists otv_miktar    numeric(19,4) not null default 0;
alter table public.belge_satir add column if not exists kdv_muafiyeti smallint      not null default 0;

comment on column public.belge_satir.iskonto2      is 'Ikinci iskonto YUZDESI. Birinciyle CARPIMSAL uygulanir: (1-isk1/100)*(1-isk2/100). Iskonto bos, iskonto2 dolu olamaz (uygulama kontrolu).';
comment on column public.belge_satir.otv_miktar    is 'OTV: otv_yuzde = 0 ise birim basina TUTAR, aksi halde YUZDE (matrah uzerinden). Dip toplam formulu bu ayrimi yapar.';
comment on column public.belge_satir.kdv_muafiyeti is 'KDV muafiyet kodu (GIB). Dip toplamda KDV satiri bu koda gore ayrisir.';

-- ------------------------------------------------------------------- goc ----
do $$
declare v_guncel integer;
begin
    if to_regclass('stg.fatura') is null then
        raise notice '023: stg.fatura yok - hesap alanlari gocu atlandi (sadece-sema kurulumu).';
        return;
    end if;

    update public.belge_satir s
       set iskonto2      = coalesce(f.iskonto2, 0),
           otv_miktar    = coalesce(f.otvmiktar, 0),
           kdv_muafiyeti = coalesce(f.kdvmuhafiyeti, 0)
      from stg.fatura f
     where f.id = s.id
       and (coalesce(f.iskonto2, 0) <> 0 or coalesce(f.otvmiktar, 0) <> 0
            or coalesce(f.kdvmuhafiyeti, 0) <> 0);

    get diagnostics v_guncel = row_count;
    raise notice '023 tamam: % satirda iskonto2 / otv_miktar / kdv_muafiyeti dolduruldu.', v_guncel;
end $$;
