-- =====================================================================
--  648_lab_satir_giris_damgasi.sql
--  SATIRIN "Giriş" KOLONU (lab_istem_satir.cihaz) - geçmişe dönük dolgu.
--
--  Kullanıcı: "sonucu elle değiştirdiğim / girdiğim bilgisi nerede" ·
--  "Cihaz (metin) boş". Bilgi `lab_sonuc`ta vardı (cihaz_id boş = elle,
--  ekleyen = kim) ama istem kartının gridi satırın kendi kolonundan
--  okuyor ve o kolon hiç yazılmıyordu.
--
--  Servis artık her sonuç yazımında damgalıyor ("Elle · <kullanıcı>" ya
--  da cihaz kodu). Burada ÖNCEDEN yazılmış sonuçların satırı doldurulur.
--
--  KAYNAK `lab_sonuc`: satırın SON geçerli sonucu. Kolon boş olanlara
--  dokunulur; kurum elle bir şey yazdıysa korunur.
-- =====================================================================

with son as (
    select distinct on (x.istem_satir_id) x.*
      from public.lab_sonuc x
     where x.durum <> 4
     order by x.istem_satir_id, x.id desc)
update public.lab_istem_satir s
   set cihaz = case
                 when ls.cihaz_id is null
                 then coalesce('Elle · ' || nullif(k.ad, ''), 'Elle giriş')
                 else coalesce(c.kod, c.ad, 'Cihaz') end
  from son ls
  left join public.v_kullanici_lookup k on k.id = ls.ekleyen
  left join public.cihaz c on c.id = ls.cihaz_id
 where ls.istem_satir_id = s.id
   and coalesce(s.cihaz, '') = '';

do $kontrol$
declare
    v_bos int;
begin
    select count(*) into v_bos
      from public.lab_istem_satir s
     where coalesce(s.cihaz, '') = ''
       and exists (select 1 from public.lab_sonuc x
                    where x.istem_satir_id = s.id and x.durum <> 4);
    raise notice '648 tamam: sonucu olup giris damgasi bos kalan % satir', v_bos;
end $kontrol$;
