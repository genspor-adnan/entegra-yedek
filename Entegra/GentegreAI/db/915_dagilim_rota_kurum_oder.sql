-- =====================================================================
--  915_dagilim_rota_kurum_oder.sql
--  "KURUMU ÖDER" (kurum türü 4) DAĞILIM ROTASI — kurum karşılama yüzdesi
--  kadar KURUM kovasına (oss), kalanı hastaya.
--
--  fn_dagilim_rota "Kurumu Öder" türünü (4) ele almıyordu: else dalına düşüp
--  rota 1 (hasta öder) veriyordu; sözleşmede %100 karşılama olsa bile tutarın
--  tamamı hastaya yazılıyordu. Anlaşmalı kurum (ör. dış lab/görüntüleme
--  gönderen hastane) "kurum ay sonu öder, hasta ödemez" istiyor.
--
--  ÇÖZÜM: tür 4 -> rota 2 (ÖSS/kurum kovasıyla aynı matematik: SGK payı ve
--  katılım YOK; oss = tutar * karşılama/100, hasta = kalan). fn_belge_satir_dagit
--  rota 2 dalı bu bölüşümü zaten yapıyor - yalnız rotanın üretilmesi eksikti.
-- =====================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_dagilim_rota(
    p_tur smallint, p_alt_kurum smallint default 0, p_sgk_kullan smallint default 1)
returns smallint language sql immutable as $function$
    select case
        when coalesce(p_tur, 1) = 1 then 1::smallint      -- Özel / hasta öder
        when p_tur = 3 then 5::smallint                   -- SGK
        when p_tur = 4 then 2::smallint                   -- Kurumu Öder -> kurum kovası (915)
        when p_tur = 2 then case coalesce(p_alt_kurum, 201)
                                 when 202 then case when coalesce(p_sgk_kullan, 1) = 1
                                                    then 3::smallint else 2::smallint end
                                 when 203 then case when coalesce(p_sgk_kullan, 1) = 1
                                                    then 4::smallint else 2::smallint end
                                 else 2::smallint end     -- ÖSS
        else 1::smallint end;
$function$;

do $$ begin raise notice '915 tamam: fn_dagilim_rota tur=4 (Kurumu Öder) -> rota 2'; end $$;
