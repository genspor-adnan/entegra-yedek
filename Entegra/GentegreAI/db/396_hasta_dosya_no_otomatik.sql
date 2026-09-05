-- ============================================================================
--  396 - HASTA DOSYA NO HER ZAMAN OTOMATIK
--
--  Karar (kullanici): "yeni hasta eklemede dosya no editini kaldir - otomatik
--  verilecek". Hasta kartinda numara alani artik HIC cizilmiyor (yeni kayitta
--  da yok), dolayisiyla "elle girilir" secenegi hastada ulasilamaz bir yol
--  haline geldi: 372'nin tetigi bos kod gorunce hata firlatiyor ve kullanici
--  numarayi yazacak bir alan bulamadigi icin hastayi HIC kaydedemiyordu.
--
--  Yeni kural: grup 101 (hasta) icin kod bossa numara daima uretilir. Disaridan
--  gelen (goc, entegrasyon) kod yazilmissa aynen korunur - o dal degismedi.
--  Sablon satiri yoksa fn_hasta_dosya_no zaten 8 haneli 1'den saymaya duser.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.tg_taraf_hasta_dosya_no()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    if coalesce(new.grup, 0) <> 101 then return new; end if;

    if coalesce(btrim(new.kod), '') <> '' then
        return new;                     -- disaridan numara gelmis, korunur
    end if;

    -- 396: elle_girilir ARTIK BAKILMIYOR. Hasta kartinda numara alani yok;
    --   "elle" moda dusmek kaydi imkansiz kilardi.
    new.kod := public.fn_hasta_dosya_no(coalesce(new.sube_id, 0));
    return new;
end $function$;


-- Ayar satirini da yeni davranisla ayni yere getir: hasta numarasi otomatik.
--   (Baska turlerin elle_girilir isareti korunur - yalniz tur 900.)
update public.numara_sablonu
   set elle_girilir = 0
 where tur = 900 and elle_girilir <> 0;
