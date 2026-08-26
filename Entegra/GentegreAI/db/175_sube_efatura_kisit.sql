-- ============================================================================
--  Gentegre AI — ck_sube_efatura kisiti kaldirildi
--  175_sube_efatura_kisit.sql
--
--  BULGU (kullanici): sube kaydederken "Deger kurala uymuyor (ck_sube_efatura)".
--
--  KISIT (022): efatura_mukellef = 1 ise `efatura_alias` VE `vkno` dolu olmali.
--
--  NEDEN ARTIK YANLIS:
--   1) 169'dan beri sube MERKEZIN KIMLIGIYLE gonderebiliyor. O subede kendi
--      alias'i ve VKN'si BOS olur - bilgiler merkezden gelir. Kisit boyle bir
--      subede mukellefiyet isaretlenmesini imkansiz kiliyordu.
--   2) Mukellefiyet artik "bu tur acik mi" anlamina da geliyor (172): kullanici
--      once turu isaretleyip alias'i entegratorden ogrendikten sonra girmek
--      istiyor. Kisit sirayi ters cevirip kaydetmeyi engelliyordu.
--
--  YERINE NE VAR: eksik bilgiyle GONDERIM zaten durur -
--    * v_ebelge_gonderici.ebelge_hazir (unvan/VKN/vergi dairesi/adres/il),
--    * fn_ebelge_gonderim_dogrula (gonderim on-kosullari),
--    * fn_ebelge_hazirla (seri/numara harcanmadan once).
--  Kayit anini engellemek yerine gonderim anini engellemek dogru yer: kart
--  yarim doldurulup birakilabilir, GIB'e giden belge yarim olamaz.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.sube drop constraint if exists ck_sube_efatura;

do $$
declare v_eksik integer;
begin
    select count(*) into v_eksik
      from public.v_ebelge_gonderici g
     where not g.ebelge_hazir;
    if v_eksik > 0 then
        raise notice '175: kisit kaldirildi. % subede gonderim bilgisi hala eksik - bu subelerden belge GONDERILEMEZ (kayit serbest).', v_eksik;
    else
        raise notice '175: kisit kaldirildi; tum subelerin gonderim bilgisi tam.';
    end if;
end $$;
