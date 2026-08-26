-- ============================================================================
--  Gentegre AI — XSLT satirlarinda belge turu adinin onarimi
--  162_xslt_belge_turu_onarim.sql
--
--  BULGU (kullanici): "e-belge turu gelmedi satira" ve "e-belge turu sutununda
--  turkce karakterler bozulmus" - gridde bazi rozetler renksiz kaliyordu.
--
--  IKI SEBEP:
--   1) YUKLEMEDE YAZILMIYORDU. `dokuman` insert'i `belge_turu` kolonunu hic
--      doldurmuyordu (kart dokumaninda kullanici sonradan yaziyor). XSLT'de ise
--      tur, dosyanin kimligi - bos kalinca grid rozeti eslesmiyor.
--   2) AKTARIMDA BOZULMUSTU. `xslt_aktar.ps1` TSV'yi UTF-8 yaziyor ama psql
--      \copy istemci kodlamasini varsayilan (WIN1252) sayip "e-Arşiv" yerine
--      "e-ArÅŸiv" yaziyordu.
--
--  KOD TARAFI DUZELTILDI (DokumanDeposu: ekleme ve duzenlemede ad kod'dan
--  turetilir; betige `set client_encoding='UTF8'`). Burasi MEVCUT satirlari
--  onarir: ad her zaman kaynak_id'den yeniden yazilir - tek dogruluk kaynagi
--  tur KODU, metin yalnizca gosterim.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare v_satir integer;
begin
    update public.dokuman
       set belge_turu = case kaynak_id
                            when 1 then 'e-Fatura'
                            when 2 then 'e-Arşiv'
                            when 7 then 'e-İrsaliye'
                            when 8 then 'e-SMM'
                            else '' end
     where kaynak = 'ebelge-xslt'
       and belge_turu is distinct from case kaynak_id
                            when 1 then 'e-Fatura'
                            when 2 then 'e-Arşiv'
                            when 7 then 'e-İrsaliye'
                            when 8 then 'e-SMM'
                            else '' end;
    get diagnostics v_satir = row_count;
    raise notice '162: % XSLT satirinda belge turu adi yeniden yazildi.', v_satir;
end $$;

do $$
declare v_bos integer;
begin
    select count(*) into v_bos from public.dokuman
     where kaynak = 'ebelge-xslt' and coalesce(belge_turu, '') = '';
    if v_bos > 0 then
        raise notice '162 UYARI: % satirda tur adi bos - kaynak_id tanimsiz bir kod (%).',
            v_bos, (select string_agg(distinct kaynak_id::text, ', ')
                      from public.dokuman
                     where kaynak = 'ebelge-xslt' and coalesce(belge_turu, '') = '');
    end if;
    raise notice '162 tamam.';
end $$;
