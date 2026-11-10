-- ============================================================================
--  1283_dokuman_onay_kuyrugu_kaldir.sql  (10.11.2026)
--  DOKÜMAN ONAY KUYRUĞU EKRANI KALDIRILIYOR (kullanıcı: "Doküman Onay Kuyruğu var.. buna artık gerek var mı?")
--
--  758 doküman onayını omurgaya taşıdığından beri "Doküman Onay Kuyruğu" (`dokuman-onay`) ile Onayımdakiler
--  (`v_onay_kutusu`) AYNI görünümü (`v_onay_bekleyen`, kaynak_tur 976) ve AYNI karar ucunu
--  (`/api/onay/kayit/976/{surumId}/karar`) kullanıyordu; kutu üst kümeydi (Bilgi İste, Sözlü onay, Zincir, Kayda Git).
--  İki ekran tutmak her yeni özelliği iki kez yazmak demekti. Kutuya "Doküman" çipi ve 976 için "Kayda Git" köprüsü
--  eklendi; ayrı ekran koddan kalktı. Bu dosya veri tarafını temizler:
--   · `dokuman.onayla` EKRAN yetkisi (tur 0) ve rol bağları düşer. KARAR yetkisi `dokuman.onay` (aksiyon, 831) KALIR.
--   · Yardım kataloğu satırı PASİF olur (1009 deseni: geçmiş yardım günlüğü atıfları çözülebilsin).
--   · Menü çevirisi silinir.
--  İdempotent.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
  v_roller int[]; v_rol int; v_yetki int;
begin
  select coalesce(array_agg(ry.rol_id), '{}') into v_roller
    from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
   where y.kod = 'dokuman.onayla' and y.tur = 0;

  delete from public.rol_yetki
   where yetki_id in (select id from public.yetki where kod = 'dokuman.onayla' and tur = 0);
  get diagnostics v_rol = row_count;

  -- Yetki sürümü: bağı düşen rollerin önbelleği yenilensin.
  update public.rol set yetki_surumu = yetki_surumu + 1 where id = any(v_roller);

  delete from public.yetki where kod = 'dokuman.onayla' and tur = 0;
  get diagnostics v_yetki = row_count;

  raise notice '1283: dokuman.onayla ekran yetkisi silindi (% rol bağı, % yetki).', v_rol, v_yetki;
end $$;

update public.ai_rehber_ekran set durum = 1
 where (kaynak = 'dokuman-onay' or rota = '/dokuman-onay') and durum = 0;

-- 'Onay Kuyruğu' anahtarı iskonto / lab / banko ekranlarında da geçer - yalnız tam ad silinir.
delete from public.ceviri
 where kapsam = 'menu' and anahtar = 'Doküman Onay Kuyruğu';

do $$ begin raise notice '1283 tamam: Doküman Onay Kuyruğu ekranı kalktı; doküman onayı Onayımdakiler (kaynak 976).'; end $$;
