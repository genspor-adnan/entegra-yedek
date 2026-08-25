-- ============================================================================
--  Gentegre AI — SATIR BAZLI TESLIM TARIHI (TERMIN)
--  140_belge_satir_teslim_tarihi.sql
--
--  Siparis satirinin "ne zaman teslim edilecek" sozu. BASLIKTA DEGIL SATIRDA:
--  ayni siparisin kalemleri farkli tarihlerde sevk edilebilir (stokta olan
--  hemen, uretilecek olan iki hafta sonra) - tek baslik tarihi bu gercegi
--  temsil edemiyordu.
--
--  `vade_gun` ile karistirilmamali: o ODEME vadesi (para ne zaman), bu TESLIM
--  tarihi (mal ne zaman). Ikisi bagimsizdir - pesin alinan mal ay sonunda
--  teslim edilebilir.
--
--  Bos (null) birakilabilir: termin verilmemis kalem "belirsiz"dir, tarih
--  uydurmak acik siparis raporunu yaniltirdi.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge_satir
    add column if not exists teslim_tarihi date;

comment on column public.belge_satir.teslim_tarihi is
  'Satirin teslim/termin tarihi (140). Bos = termin verilmemis. Odeme vadesi (vade_gun) ile ilgisi yok.';

-- Acik siparis / geciken termin raporlarinin sorgusu: yalniz DOLU olanlar
--   aranir, kismi indeks kucuk kalir.
create index if not exists ix_belge_satir_teslim
    on public.belge_satir (teslim_tarihi)
 where teslim_tarihi is not null;

do $$
declare v_var boolean;
begin
    select exists (select 1 from information_schema.columns
                    where table_schema = 'public' and table_name = 'belge_satir'
                      and column_name = 'teslim_tarihi') into v_var;
    raise notice '140 tamam: belge_satir.teslim_tarihi = %', v_var;
end $$;
