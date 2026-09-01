-- 312: Cekim kontrol tetigi (310) IS KURALI kodu ile hata firlatsin.
--
-- Sistemin sozlesmesi: DB tetikleri kullaniciya gosterilecek kurallari
-- SQLSTATE 'GK422' ile firlatir (VeriHatasi.Cevir); baska kodlar "beklenmeyen
-- hata" olarak siniflanir ve kullanici yalnizca izleme numarasi gorur.
--
-- 310'da errcode P0001 kullanilmisti: "Çekim öncesi kontrol listesi
-- tamamlanmadan..." mesaji ekrana ULASMIYORDU. Kural ayni, yalniz kod degisti.

create or replace function public.tg_radyoloji_cekim_kontrolu()
returns trigger language plpgsql as $$
declare
  v_eksik text;
begin
  if new.durum >= 2 and coalesce(old.durum, 0) < 2 then
    select string_agg(s.soru, ', ' order by s.sira)
      into v_eksik
      from public.radyoloji_kontrol_soru s
      left join public.radyoloji_kontrol k
             on k.soru_id = s.id and k.istem_id = new.id
     where s.aktif = 1 and s.zorunlu = 1
       and (s.modalite is null or s.modalite = new.modalite)
       and coalesce(btrim(k.yanit), '') = '';

    if v_eksik is not null then
      raise exception 'Çekim öncesi kontrol listesi tamamlanmadan "Çekildi" işaretlenemez. Eksik: %', v_eksik
        using errcode = 'GK422';
    end if;
  end if;
  return new;
end $$;

comment on function public.tg_radyoloji_cekim_kontrolu() is
  'Zorunlu kontrol sorulari yanitlanmadan istem cekildi isaretlenemez (310/312).';
