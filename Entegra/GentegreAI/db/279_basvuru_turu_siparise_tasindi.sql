-- 279: BAŞVURU AYRI TÜR DEĞİL, SATIŞ SİPARİŞİDİR (kullanıcı: "türü neden 30'da
-- bırakmakta ısrar ediyorsun? normal satış siparişiyle aynı yap").
--
-- 276 yalnız DAVRANIŞI eşitlemişti; tür kodu (30) ayrı kalınca sipariş
-- listeleri, kalan/kapanma raporları ve dönüşüm zinciri başvuruları görmüyor,
-- aynı iş iki koda bölünüyordu. Başvuru artık tür 19'dur (Satış Siparişi);
-- "Başvuru" yalnızca GenoTIP (HBYS) modundaki EKRAN ADIDIR.
--
-- NUMARA ÇAKIŞMASI: iki tür ayrı numara dizisi kullanıyordu; taşınan
-- başvurular aynı seride var olan numaraların üstüne düşerdi (WEB/000000001
-- hem siparişte hem başvuruda). Çakışanlar o serideki en büyük numaradan
-- devam ettirilerek YENİDEN numaralanır; eski numara açıklamaya yazılır -
-- hasta "protokol numaram neydi" dediğinde iz kaybolmasın.

create table if not exists public.belge_tur30_yedek_279 as
select id, tur, belge_seri, belge_no, belge_tarihi, taraf_id, aciklama
  from public.belge where tur = 30;

do $$
declare
  r        record;
  v_yeni   text;
  v_sayac  integer := 0;
  v_tasima integer := 0;
begin
  -- 1) Çakışan numaraları yeniden üret (seri bazında, 19'un en büyüğünden sonra).
  for r in
      select b.id, b.belge_seri, b.belge_no
        from public.belge b
       where b.tur = 30 and b.belge_no <> ''
         and exists (select 1 from public.belge s
                      where s.tur = 19 and s.belge_seri = b.belge_seri
                        and s.belge_no = b.belge_no)
       order by b.id
  loop
      select lpad(((coalesce(max(nullif(regexp_replace(s.belge_no, '\D', '', 'g'), '')), '0')::bigint) + 1)::text,
                  greatest(length(r.belge_no), 9), '0')
        into v_yeni
        from public.belge s
       where s.tur in (19, 30) and s.belge_seri = r.belge_seri;

      update public.belge
         set belge_no = v_yeni,
             aciklama = case when aciklama = '' then '' else aciklama || ' · ' end
                        || 'Eski başvuru no: ' || r.belge_no
       where id = r.id;
      v_sayac := v_sayac + 1;
  end loop;

  -- 2) Türü taşı.
  update public.belge set tur = 19 where tur = 30;
  get diagnostics v_tasima = row_count;

  raise notice '279: % başvuru satış siparişine taşındı, %si yeniden numaralandı.',
               v_tasima, v_sayac;
end $$;

-- Bağlı kayıtlar da aynı türü göstermeli (mali hareket 276'da temizlendi ama
--   müşteri veritabanında kalmış olabilir).
update public.mali_hareket set tur = 19 where tur = 30;
update public.kasa_islem    set tur = 19 where tur = 30;

-- 3) Tür tanımı KALDIRILMAZ, pasife çekilir: eski kayıtların FK'leri (mali
--    hareket, muhasebe eşleştirme) kırılmasın, seçim listelerinde çıkmasın.
update public.kasa_islem_turu
   set aktif = 0,
       ad    = 'Başvuru (kullanılmıyor — Satış Siparişi)'
 where kod = 30;

-- Türe özel numara şablonu varsa 19'a devreder (aynı dizi).
delete from public.numara_sablonu where tur = 30;
