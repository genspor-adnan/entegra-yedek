-- ============================================================================
--  394 - ESKI "Hızlı tahsilat" ACIKLAMALARI BELGEYE GORE DUZELTILIR
--
--  Belge kartindan yapilan tahsilatlar aciklamaya "Hızlı tahsilat · <hesap>"
--  yaziyordu: tahsilatin NASIL girildigini anlatan, ne oldugunu anlatmayan bir
--  metin. Yeni kayitlar artik belgenin cinsinden kuruluyor ("Fiş Tahsilatı" /
--  "Fatura Tahsilatı" / "Tahakkuk Tahsilatı"); bu betik GECMISI ayni bicime
--  cevirir (kullanici istegi).
--
--  Kisa ad tanimi istemcideki `belgeKisaAdi` ile BIREBIR ayni olsun diye
--  fonksiyonlastirildi - iki yerde ayri CASE zamanla birbirinden kayar.
--
--  Idempotent: yalniz "Hızlı tahsilat" ile baslayan ve belgesi olan satirlara
--  dokunur; ikinci calistirmada eslesen satir kalmaz.
-- ============================================================================

create or replace function public.fn_belge_kisa_adi(p_tur integer, p_tipi integer default 0)
returns varchar
language sql
immutable
as $$
    -- Sira onemli: basvuru (19 + tipi 30) siparisten, konsinye irsaliyeden
    --   once eslesmeli.
    select case
        when p_tur = 19 and p_tipi = 30 then 'Başvuru'
        when p_tur = 18                 then 'Teklif'
        when p_tur = 20                 then 'Transfer'
        when p_tur = 105                then 'Talep'
        when p_tur in (9, 19)           then 'Sipariş'
        when p_tur in (109, 119)        then 'Konsinye'
        when p_tur in (13, 17)          then 'Tahakkuk'
        when p_tur in (10, 14)          then 'İrsaliye'
        when p_tur in (3, 4, 12, 16)    then 'Fiş'
        when p_tur in (11, 15)          then 'Fatura'
        else 'Belge'
    end::varchar;
$$;

comment on function public.fn_belge_kisa_adi(integer, integer) is
  'Belgenin kisa adi - yon (Satis/Alis) YOK. Tahsilat aciklamasi bundan '
  'kurulur ("Fiş Tahsilatı"). Istemcideki belgeKisaAdi ile ayni tanim (394).';

update public.kasa_islem k
   set aciklama = public.fn_belge_kisa_adi(b.tur, b.tipi) || ' Tahsilatı'
  from public.belge b
 where b.id = k.belge_id
   and k.aciklama like 'Hızlı tahsilat%';

update public.mali_hareket m
   set aciklama = public.fn_belge_kisa_adi(b.tur, b.tipi) || ' Tahsilatı'
  from public.belge b
 where b.id = m.belge_id
   and m.aciklama like 'Hızlı tahsilat%';
