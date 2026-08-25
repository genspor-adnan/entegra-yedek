-- ============================================================================
--  Gentegre AI — IADE EDILEBILIR SATIRLAR
--  132_iade_satirlari.sql
--
--  Iade faturasi kesilirken kullanici stok arayip miktar/fiyat yazmamali:
--  "satir eklerken onceki alinanlar gelmeli" (kullanici). Iade, mustеriye
--  DAHA ONCE satilmis (ya da tedarikciden alinmis) bir kalemin geri donusudur;
--  fiyat, iskonto ve KDV o belgeden gelir - elle girilen fiyat cari bakiyeyi ve
--  KDV'yi tutarsiz birakirdi.
--
--  IADE MIKTARI kolon degil, HESAP: iade satiri kaynak satira baglanir
--  (belge_satir.kaynak_tur = 30, kaynak_id = kaynak satir). Boylece bir kalem
--  parca parca iade edilebilir ve kalan her zaman turetilebilir.
--
--  kapatilan_miktar'a DOKUNULMAZ: o siparis -> irsaliye -> fatura zincirinin
--  sayaci (F8). Iade ayri bir eksen; ikisini ayni kolona yigmak "acik siparis"
--  raporunu bozardi.
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
 -- Yalniz KESIN (durum 0) fatura/fis turleri iade edilebilir; iadenin iadesi yok.
 where b.durum = 0
   and b.tur in (11, 12, 15, 16, 109, 119)
   and coalesce(b.tipi, 0) <> 2;

comment on view public.v_iade_edilebilir_satir is
  'Iade faturasinda secilebilecek gecmis fatura satirlari (132): miktar, iade edilen ve fiyat/KDV kaynaktan.';

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.v_iade_edilebilir_satir;
    raise notice '132 tamam: % iade edilebilir satir', v_adet;
end $$;
