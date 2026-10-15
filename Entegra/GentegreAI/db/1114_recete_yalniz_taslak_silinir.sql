-- ============================================================================
--  1114_recete_yalniz_taslak_silinir.sql
--  REÇETE SİLME YALNIZ TASLAKTA (kullanıcı 15.10.2026: "reçete listesinde yeni / düzenle / sil deseni").
--
--  Listeye 🗑 Sil geldi; genel kart silme ucu durum bakmıyordu - imzalı / Medula'ya gitmiş reçete
--  silinebilirdi. İmzalı reçete yasal belgedir: silinmez, Medula'dan iptal edilir. Taslak (durum 1)
--  silinir. Satırları (recete_satir) FK ile birlikte gider. Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.tg_recete_sil_taslak() returns trigger language plpgsql as $$
begin
    if old.durum <> 1 then
        raise exception 'İmzalanmış reçete silinemez; Medula''dan iptal edin.' using errcode = 'P0001';
    end if;
    return old;
end $$;

drop trigger if exists trg_recete_sil_taslak on public.recete;
create trigger trg_recete_sil_taslak before delete on public.recete
    for each row execute function public.tg_recete_sil_taslak();

-- SİLME HAKKI (1111 sevk / konsültasyon deseni): muayenede silme hakkı olan rol listede taslak reçeteyi
--   de silebilsin. Yalnız sil = 0 ve el değmemiş satırlar; kurumun bilerek kapattığı hak açılmaz.
--   Hakkı olmayan hekim kendi açtığı taslağı yine silebilir (kart silme ucu kuralı).
update public.rol_yetki ry
   set sil = 1
  from public.yetki y, public.rol_yetki m
  join public.yetki my on my.id = m.yetki_id and my.kod = 'muayene'
 where y.id = ry.yetki_id and y.kod = 'muayene.recete'
   and m.rol_id = ry.rol_id and m.sil = 1 and ry.sil = 0
   and ry.degistirme_tarihi is null;
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'muayene.recete');
