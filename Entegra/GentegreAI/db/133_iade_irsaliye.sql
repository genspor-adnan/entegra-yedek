-- ============================================================================
--  Gentegre AI — IADE IRSALIYESI
--  133_iade_irsaliye.sql
--
--  Iade yalniz faturayla olmuyor: mal once IRSALIYE ile cikip iade de irsaliye
--  ile geri gelebilir (fatura sonra kesilir ya da hic kesilmez). 132'deki
--  gorunum yalniz fatura turlerini tasiyordu; irsaliye (10 alis / 14 satis) ve
--  konsinye irsaliyeleri de eklenir.
--
--  KAYNAK ESLESMESI ekranda ayrilir: iade FATURASINDA fatura satirlari, iade
--  IRSALIYESINDE irsaliye satirlari listelenir (uc "turler" suzgeci ile) -
--  yoksa ayni mal hem irsaliyeden hem faturadan iade edilip cift sayilirdi.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_iade_edilebilir_satir as
select s.id                                as satir_id,
       s.belge_id,
       b.tur                               as belge_tur,
       b.tipi                              as belge_tipi,
       b.belge_no,
       b.belge_tarihi,
       b.taraf_id,
       b.taraf_unvan,
       b.sube_id,
       s.sira,
       s.tur                               as satir_tur,
       s.stok_id,
       st.kod                              as stok_kodu,
       coalesce(st.ad, h.ad, s.aciklama)   as stok_adi,
       s.hizmet_id,
       s.aciklama,
       s.miktar,
       -- Bu satirdan simdiye kadar iade edilen miktar (iade belgeleri tipi = 2).
       coalesce((select sum(i.miktar)
                   from public.belge_satir i
                   join public.belge ib on ib.id = i.belge_id
                  where i.kaynak_tur = 30 and i.kaynak_id = s.id
                    and ib.tipi = 2 and ib.durum in (0, 1)), 0) as iade_miktar,
       s.birim,
       s.birim_fiyat,
       s.iskonto,
       s.kdv,
       s.doviz_cinsi,
       s.izleme,
       s.izleme_kodu
  from public.belge_satir s
  join public.belge b on b.id = s.belge_id
  left join public.stok   st on st.id = s.stok_id
  left join public.hizmet h  on h.id  = s.hizmet_id
 -- Kesin (durum 0) fatura VE irsaliye turleri; iadenin iadesi yok.
 where b.durum = 0
   and b.tur in (10, 11, 12, 14, 15, 16, 109, 119)
   and coalesce(b.tipi, 0) <> 2;

comment on view public.v_iade_edilebilir_satir is
  'Iade belgesinde secilebilecek gecmis fatura/irsaliye satirlari (132/133).';

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.v_iade_edilebilir_satir;
    raise notice '133 tamam: % iade edilebilir satir (fatura + irsaliye)', v_adet;
end $$;
