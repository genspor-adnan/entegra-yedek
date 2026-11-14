-- 1340 - e-Nabız Bildirimi ve TeleRadyoloji Bildirimi bayrakları: anlaşmalı kurumda VARSAYILAN, başvuruda KARAR.
--
-- Kullanıcı 14.11.2026: "anlaşmalı kurumlara e-Nabız Bildirimi ve Teleradyoloji Bildirimi diye 2 check aç default false
--   olsun.. aynı check'lerden başvuruya da aç.. anlaşmalı kurumda açıksa başvuruda seçildiğinde başvuruda da aynısı
--   olur.. ama kullanıcı isterse değişebilir.. başvurudaki e-Nabız Bildirimi seçili ise hastanın e-Nabız bildirimi
--   gönderilir, Teleradyoloji Bildirimi seçili ise de Teleradyoloji Bildirimi gönderilir."
--
-- Akış: kurum kartı (anlaşmalıyken görünür) → başvuruda ödeyen kurum seçilince iki kutu kurumun değeriyle dolar,
--   kullanıcı değiştirebilir → kayıt belge_basvuru'ya yazılır →
--   * e-Nabız: EnabizPaketUretici başvurusu olan her paket için belge_basvuru.enabiz_bildirim = 0 ise paket üretmez
--     (başvurusuz paketler - ay/gün sonu - etkilenmez).
--   * Teletıp: teletip_gonderim BEFORE INSERT kapısı (tg_teletip_gonderim_dis_is, 1315/1324) başvurusu olan istemde
--     belge_basvuru.telerad_bildirim = 0 ise satırı yazmaz (ORM/ORU/KOS/doz hepsi aynı kapıdan geçer). Başvurusuz
--     istem (teleradyoloji gelen, eski aktarım) eskisi gibi.
-- Varsayılan 0: bugüne kadar açılmış başvurular bildirim göndermez; kurum kartından bayrak açılınca YENİ başvurular alır.
\set ON_ERROR_STOP on
begin;

alter table public.taraf_kurum
    add column if not exists enabiz_bildirim  smallint not null default 0,
    add column if not exists telerad_bildirim smallint not null default 0;
comment on column public.taraf_kurum.enabiz_bildirim  is '1340: bu kurumun hastaları için e-Nabız bildirimi varsayılanı (başvuruya kopyalanır)';
comment on column public.taraf_kurum.telerad_bildirim is '1340: bu kurumun hastaları için TeleRadyoloji (Teletıp) bildirimi varsayılanı (başvuruya kopyalanır)';

alter table public.belge_basvuru
    add column if not exists enabiz_bildirim  smallint not null default 0,
    add column if not exists telerad_bildirim smallint not null default 0;
comment on column public.belge_basvuru.enabiz_bildirim  is '1340: 1 = bu başvurunun e-Nabız paketleri üretilir (EnabizPaketUretici kapısı)';
comment on column public.belge_basvuru.telerad_bildirim is '1340: 1 = bu başvurunun radyoloji istemleri Teletıp kuyruğuna girer (tg_teletip_gonderim_dis_is kapısı)';

-- Teletıp kapısı (1324 tanımı + başvuru bayrağı).
create or replace function public.tg_teletip_gonderim_dis_is()
returns trigger language plpgsql as $$
begin
  if public.fn_teletip_dis_is(new.istem_id) then return null; end if;
  if public.fn_teletip_hesap(new.sube_id) is null then return null; end if;
  -- 1340: başvurusu olan istemde "TeleRadyoloji Bildirimi" kapalıysa kuyruğa girmez.
  if exists (select 1 from public.radyoloji_istem i
               join public.belge_basvuru bb on bb.id = i.belge_id
              where i.id = new.istem_id and coalesce(bb.telerad_bildirim, 0) = 0) then
    return null;
  end if;
  return new;
end $$;
comment on function public.tg_teletip_gonderim_dis_is() is
  '1315/1324/1340: Teletıp kuyruğu kapısı - dış kurum işi, hesap yok, başvuruda TeleRadyoloji Bildirimi kapalı → satır yazılmaz.';

commit;
