-- ============================================================================
--  1122_randevu_geri_al_kurali.sql
--  RANDEVU DURUMU GERİ ALMA (kullanıcı 17.10.2026: "kartı yanlışlıkla geldi/gelmedi/iptal
--  işaretlersem nasıl geri alırım" → kartta ve listede "↩ Geri Al" = Planlandı).
--
--  Geri almanın kuralı veritabanında (hangi uçtan gelinirse gelinsin):
--    * Başvuruya dönüşmüş (belge_id dolu) randevu Planlandı'ya dönemez - başvuru açık kalır,
--      takvim "bekliyor" derdi. Önce başvuru iptal edilir.
--    * Ertelenmiş (5) randevunun durumu değişmez - yerine açılan randevu ayrı kayıttır (1119).
--  Saat / çakışma / mesai / izin denetimi Planlandı'ya dönüşte mevcut tetiklerle yeniden yapılır.
--  Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.tg_randevu_durum_geri()
returns trigger language plpgsql as $$
begin
    if new.durum is not distinct from old.durum then return new; end if;
    if old.durum = 5 then
        raise exception 'Ertelenen randevunun durumu değişmez - ertelemeyle açılan yeni randevuyu kullanın.'
            using errcode = 'GK422';
    end if;
    if new.durum = 1 and old.belge_id is not null and new.belge_id is not null then
        raise exception 'Randevu başvuruya dönüşmüş - Planlandı''ya almak için önce başvuruyu iptal edin.'
            using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tr_randevu_durum_geri on public.randevu;
create trigger tr_randevu_durum_geri before update of durum on public.randevu
    for each row execute function public.tg_randevu_durum_geri();
