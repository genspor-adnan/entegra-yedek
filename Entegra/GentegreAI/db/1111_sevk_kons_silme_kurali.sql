-- ============================================================================
--  1111_sevk_kons_silme_kurali.sql
--  SEVK / KONSÜLTASYON YALNIZ TASLAKKEN SİLİNİR (kullanıcı 15.10.2026: "sevk listesine yeni
--  düzenle sil deseni ekle"; konsültasyon listesi de aynı Yeni / Düzenle / Sil setini taşır).
--
--  Listelerdeki 🗑 Sil kartı siler. Gönderilmiş sevk muayeneye (çıkış şekli, sevk kolonları)
--  yazılmıştır; gönderilmiş / yanıtlanan konsültasyonun hareket ve yanıt muayenesi vardır.
--  Bunlar silinmez - iptal / ret ile kapanır. Taslak ise henüz hiçbir yere gitmemiştir.
--  Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.tg_sevk_silme() returns trigger language plpgsql as $$
begin
    if old.durum <> 1 then
        raise exception 'Yalnız taslak sevk silinir; gönderilmiş sevk iptal edilir.' using errcode = 'P0001';
    end if;
    return old;
end $$;

drop trigger if exists trg_sevk_silme on public.sevk;
create trigger trg_sevk_silme before delete on public.sevk
    for each row execute function public.tg_sevk_silme();

create or replace function public.tg_konsultasyon_silme() returns trigger language plpgsql as $$
begin
    if old.durum <> 6 then
        raise exception 'Yalnız taslak konsültasyon isteği silinir; gönderilmiş istek reddedilir / iptal edilir.' using errcode = 'P0001';
    end if;
    return old;
end $$;

drop trigger if exists trg_konsultasyon_silme on public.konsultasyon;
create trigger trg_konsultasyon_silme before delete on public.konsultasyon
    for each row execute function public.tg_konsultasyon_silme();

-- SİLME HAKKI: 1107 / 1110 yeni yetkileri rollere sil = 0 ile vermişti; liste 🗑 Sil hiç görünmüyordu.
--   Muayenede silme hakkı olan rol, kendi açtığı taslak sevk / konsültasyonu da silebilir
--   (silinebilecek olan yalnız taslak - yukarıdaki tetikler). Yalnız sil = 0 olan satırlar
--   ve muayenede sil = 1 olan roller; kurumun bilerek kapattığı hak yoksa açılmaz.
update public.rol_yetki ry
   set sil = 1
  from public.yetki y, public.rol_yetki m
  join public.yetki my on my.id = m.yetki_id and my.kod = 'muayene'
 where y.id = ry.yetki_id and y.kod in ('muayene.sevk', 'muayene.konsultasyon')
   and m.rol_id = ry.rol_id and m.sil = 1 and ry.sil = 0
   and ry.degistirme_tarihi is null;   -- migration'ın açtığı, sonra el değmemiş satır
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod in ('muayene.sevk', 'muayene.konsultasyon'));
