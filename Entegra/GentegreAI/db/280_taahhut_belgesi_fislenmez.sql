-- 280: TAAHHÜT BELGELERİ MUHASEBE FİŞİ ÜRETMEZ (kullanıcı: "fiş kesmesin").
--
-- `fn_belge_fisle` yalnız irsaliyeyi (10, 14) dışarıda bırakıyordu; sipariş,
-- teklif, talep, transfer ve konsinye de fişleniyordu. Sipariş bir TAAHHÜTTÜR:
-- mal/hizmet geçmemiş, alacak doğmamıştır - mahsup fişi mizanı şişirir ve
-- fatura kesilince aynı tutar İKİNCİ kez fişlenir.
--
-- Fişlenmeyen türler (mali sonuç faturada doğar):
--   9/19  Alış-Satış Siparişi · 18 Teklif · 105 Stok Talebi
--   10/14 İrsaliye (zaten hariçti) · 109/119 Konsinye · 20 Stok Transferi
-- Tahakkuk (13/17) HARİÇ DEĞİLDİR: gelir/gider tahakkuku gerçek bir mali
-- sonuçtur, fişi kalır.

-- Eski tek parametreli imza kaldirilir: yeni parametre DEFAULT'lu oldugu icin
-- tek argumanli cagri iki adaya birden uyup "is not unique" hatasi verirdi.
drop function if exists public.fn_belge_fis_uretilsin(integer);

create or replace function public.fn_belge_fis_uretilsin(
    p_sube_id integer,
    p_tur     integer default null)
returns boolean
language sql stable as $$
    select coalesce(p_tur, 0) not in (9, 10, 14, 18, 19, 20, 105, 109, 119)
       and coalesce((select ma.muhasebe_entegrasyon = 1 and ma.fis_uretim = 1
                       from public.fn_sube_mali(p_sube_id) ma), true)
       and coalesce((select deger from public.referans
                      where anahtar = 'muhasebe.otomatik_fis'), '1') <> '0'
$$;

comment on function public.fn_belge_fis_uretilsin(integer, integer) is
  'Belge kaydedilirken muhasebe fişi üretilsin mi (280): taahhüt belgeleri (sipariş/teklif/talep/irsaliye/konsinye/transfer) üretmez.';

-- fn_belge_fisle KENDİSİ de korunur: toplu fişleme ve elle "Fişle" aksiyonu
--   aynı kuralı geçmeli, yoksa kayıtta engellenen fiş oradan sızar.
create or replace function public.fn_belge_fis_turu_uygun(p_tur integer)
returns boolean
language sql immutable as $$
    select coalesce(p_tur, 0) not in (9, 10, 14, 18, 19, 20, 105, 109, 119);
$$;

comment on function public.fn_belge_fis_turu_uygun(integer) is
  'Tür muhasebe fişi üretir mi (280) - fn_belge_fisle ve toplu fişleme aynı listeyi kullanır.';

do $$
declare
  v_kaynak text;
begin
  select pg_get_functiondef(oid) into v_kaynak
    from pg_proc where proname = 'fn_belge_fisle';

  -- Mevcut gövdedeki irsaliye kontrolü tür listesine genişletilir; gövdenin
  --   kalanına dokunulmaz (fonksiyon 300+ satır muhasebe kuralı taşıyor).
  v_kaynak := replace(v_kaynak,
      'if b.tur in (10, 14) then',
      'if not public.fn_belge_fis_turu_uygun(b.tur) then');

  if v_kaynak like '%fn_belge_fis_turu_uygun%' then
    execute v_kaynak;
    raise notice '280: fn_belge_fisle tur suzmesi guncellendi.';
  else
    raise exception '280: fn_belge_fisle icinde beklenen irsaliye kontrolu bulunamadi.';
  end if;
end $$;

-- ------------------------------------------------- geçmişte kesilmiş fişler --
-- Taahhüt belgelerine kesilmiş fişler mizanda duruyor; yedeklenip silinir.
create table if not exists public.belge_fis_yedek_280 as
select b.id as belge_id, b.tur, b.belge_no, b.muhasebe_fis_id
  from public.belge b
 where coalesce(b.muhasebe_fis_id, 0) <> 0
   and not public.fn_belge_fis_turu_uygun(b.tur);

do $$
declare
  v_fis integer := 0;
begin
  create temporary table _fis_280 on commit drop as
  select distinct b.muhasebe_fis_id as id
    from public.belge b
   where coalesce(b.muhasebe_fis_id, 0) <> 0
     and not public.fn_belge_fis_turu_uygun(b.tur);

  update public.belge set muhasebe_fis_id = null
   where coalesce(muhasebe_fis_id, 0) <> 0
     and not public.fn_belge_fis_turu_uygun(tur);

  delete from public.muhasebe_fis_satir where fis_id in (select id from _fis_280);
  delete from public.muhasebe_fis      where id     in (select id from _fis_280);
  get diagnostics v_fis = row_count;

  raise notice '280: taahhut belgelerine kesilmis % fis silindi (yedek: belge_fis_yedek_280).', v_fis;
end $$;
