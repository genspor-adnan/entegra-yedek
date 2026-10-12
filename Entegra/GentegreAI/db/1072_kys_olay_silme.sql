-- =============================================================================
--  1072  KURUMSAL KALİTE - OLAY BİLDİRİMİ SİLİNEBİLİR (DÖF'e bağlı değilse)
--
--  Kullanıcı (12.10.2026): "kalite listelerinde ekleme butonu olan yerlerin
--  yanına düzenle ve sil de ekle". Olay kartı (1052) silinemezdi; yanlış
--  açılan bildirim artık silinir. DÖF açılmış (kaynak_tur 2, iptal değil)
--  olay silinmez - DÖF kaynağı boşa düşerdi. DÖF bağı FK değil (kaynak_tur +
--  kaynak_id), bu yüzden tetik. Mesaj P0001 -> kullanıcıya iş kuralı hatası.
--  İdempotent.
-- =============================================================================

begin;

create or replace function public.fn_kalite_olay_silme() returns trigger language plpgsql as $$
declare v_no varchar;
begin
  select f.no into v_no from public.kalite_dof f
   where f.kaynak_tur = 2 and f.kaynak_id = old.id and f.durum <> 9
   order by f.id limit 1;
  if v_no is not null then
    raise exception 'Bu bildirimden % açılmış; önce DÖF''ü iptal edin ya da bildirimi Kapandı yapın.', v_no;
  end if;
  return old;
end $$;
drop trigger if exists trg_kalite_olay_silme on public.kalite_olay;
create trigger trg_kalite_olay_silme before delete on public.kalite_olay
  for each row execute function public.fn_kalite_olay_silme();

commit;
