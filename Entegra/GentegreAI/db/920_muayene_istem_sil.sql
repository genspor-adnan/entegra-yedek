-- 920 — Muayene istem silme (cascade). Hekim yanlış açtığı istemi grid'den
-- silebilsin (kullanıcı: "grid seçilebilir + kırmızı sil ikonu"). Güvence
-- (sonuçlanmış/raporlanmış istem silinmez) UÇ tarafında; buradaki fonksiyonlar
-- yalnız bağlı çocuk kayıtlarla birlikte SİLER.

-- LAB İSTEM: tüm çocuk kayıtlar + istem.
create or replace function public.fn_lab_istem_sil(p_id integer)
returns void language plpgsql as $$
begin
  delete from public.lab_sonuc
   where istem_satir_id in (select id from public.lab_istem_satir where istem_id = p_id)
      or numune_id in (select id from public.lab_numune where istem_id = p_id);
  delete from public.lab_sonuc_grafik
   where istem_satir_id in (select id from public.lab_istem_satir where istem_id = p_id);
  delete from public.lab_tekrar_istegi
   where istem_satir_id in (select id from public.lab_istem_satir where istem_id = p_id);
  delete from public.lab_kultur
   where istem_id = p_id
      or istem_satir_id in (select id from public.lab_istem_satir where istem_id = p_id)
      or numune_id in (select id from public.lab_numune where istem_id = p_id);
  delete from public.lab_dis_gonderim_satir
   where istem_satir_id in (select id from public.lab_istem_satir where istem_id = p_id)
      or numune_id in (select id from public.lab_numune where istem_id = p_id);
  delete from public.lab_genetik_vaka
   where istem_id = p_id
      or istem_satir_id in (select id from public.lab_istem_satir where istem_id = p_id)
      or numune_id in (select id from public.lab_numune where istem_id = p_id);
  delete from public.lab_numune_hareket
   where numune_id in (select id from public.lab_numune where istem_id = p_id);
  delete from public.lab_numune_arsiv
   where numune_id in (select id from public.lab_numune where istem_id = p_id);
  delete from public.lab_istem_satir where istem_id = p_id;
  delete from public.lab_numune where istem_id = p_id;
  delete from public.lab_istem_test where istem_id = p_id;
  delete from public.lab_istem where id = p_id;
end $$;

-- RADYOLOJİ İSTEM: çocuk kayıtlar + istem.
create or replace function public.fn_radyoloji_istem_sil(p_id integer)
returns void language plpgsql as $$
begin
  delete from public.radyoloji_konsultasyon where istem_id = p_id;
  delete from public.radyoloji_kontrol      where istem_id = p_id;
  delete from public.radyoloji_kritik_bulgu where istem_id = p_id;
  delete from public.radyoloji_pacs_olay    where istem_id = p_id;
  delete from public.radyoloji_rapor        where istem_id = p_id;
  delete from public.radyoloji_sarf         where istem_id = p_id;
  delete from public.radyoloji_teslim       where istem_id = p_id;
  delete from public.telerad_istek          where radyoloji_istem_id = p_id;
  delete from public.radyoloji_istem        where id = p_id;
end $$;
