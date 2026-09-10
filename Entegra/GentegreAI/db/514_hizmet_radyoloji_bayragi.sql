-- =====================================================================
--  514_hizmet_radyoloji_bayragi.sql
--  `hizmet.radyoloji` bayrağı çalışır hâle geldi - "Panel / Paket" (502)
--  deseninin radyoloji karşılığı.
--
--  Kullanıcı: "hizmet kartında radyoloji protokolü sekmesi nedir?" → sekme
--  tetkikin NASIL çekileceğini tutuyor (süre, kontrast, sekans, hasta
--  hazırlığı, personel uyarısı) ve istem/çekim ekranını besliyor. Ama sekme
--  2.045 hizmetin HEPSİNDE açıktı: OGTT gibi bir laboratuvar tetkikinin
--  kartında da duruyor, doldurulmayı bekliyormuş gibi görünüyordu.
--  Kullanıcı: "paket gibi bayrak yap".
--
--  Kolon zaten vardı ama ölüydü: 2.051 hizmetin yalnız 2'sinde 1, oysa
--  323'ünün modalitesi tanımlı. Bayrak = NİYET ("bu bir görüntüleme
--  tetkikidir"), protokol satırı = AYRINTI. Bayrak açılınca sekme görünür.
--
--  Otomatik kalkma kuralları (502 ile aynı mantık):
--    * modalite girilirse ya da protokol satırı yazılırsa bayrak KENDİLİĞİNDEN
--      kalkar - elle işaretlemeyi beklemek sessiz hataya davetiye,
--    * protokolü olan hizmetin bayrağı elle indirilemez (ekranla davranış
--      ayrışır),
--    * protokol silinince bayrak DÜŞMEZ: kullanıcı yeniden yazıyor olabilir.
-- =====================================================================

comment on column public.hizmet.radyoloji is
    'Görüntüleme tetkiki mi (514) - "Radyoloji Protokolü" sekmesini açar.';

-- Modalitesi tanımlı ya da protokolü olan hizmetler işaretlenir.
update public.hizmet h
   set radyoloji = 1
 where h.radyoloji = 0
   and (coalesce(h.modalite, 0) > 0
     or exists (select 1 from public.radyoloji_protokol p where p.hizmet_id = h.id));

-- Protokol yazılınca bayrak kendiliğinden kalkar.
create or replace function public.tg_radyoloji_protokol_bayrak() returns trigger
language plpgsql as $$
begin
    update public.hizmet set radyoloji = 1
     where id = new.hizmet_id and radyoloji = 0;
    return null;
end $$;

drop trigger if exists tg_radyoloji_protokol_bayrak on public.radyoloji_protokol;
create trigger tg_radyoloji_protokol_bayrak
    after insert or update of hizmet_id on public.radyoloji_protokol
    for each row execute function public.tg_radyoloji_protokol_bayrak();

-- Modalite girilirse bayrak kalkar; protokolü olanın bayrağı inmez.
create or replace function public.tg_hizmet_radyoloji_bayrak() returns trigger
language plpgsql as $$
begin
    if coalesce(new.modalite, 0) > 0 and new.radyoloji = 0 then
        new.radyoloji := 1;
    end if;

    if new.radyoloji = 0 and coalesce(old.radyoloji, 0) = 1
       and exists (select 1 from public.radyoloji_protokol p where p.hizmet_id = new.id) then
        raise exception 'GK422: Bu hizmetin radyoloji protokolü var - önce protokolü silin.';
    end if;
    return new;
end $$;

drop trigger if exists tg_hizmet_radyoloji_bayrak on public.hizmet;
create trigger tg_hizmet_radyoloji_bayrak
    before insert or update of radyoloji, modalite on public.hizmet
    for each row execute function public.tg_hizmet_radyoloji_bayrak();

/** Bayrağı açık ama protokolü girilmemiş tetkikler (502'deki desenin eşi). */
create or replace view public.v_hizmet_radyoloji_eksik as
select h.id, h.kod, h.ad, h.modalite
  from public.hizmet h
 where h.radyoloji = 1
   and not exists (select 1 from public.radyoloji_protokol p where p.hizmet_id = h.id);

comment on view public.v_hizmet_radyoloji_eksik is
    'Radyoloji işaretli ama çekim protokolü girilmemiş tetkikler (514).';
