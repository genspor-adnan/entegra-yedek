-- ============================================================================
--  Gentegre AI — Genel Ayarlar: belgede geriye donuk gun siniri
--  102_ayar_belge_geri_gun.sql
--
--  "Belge tarihi 7 gunden eski olamaz" kurali (2bb5475) KODA GOMULUYDU.
--  Musteriye gore degisir: kimi gunu gunune calisir, kimi ay sonu toplu girer.
--  Artik ayardan okunur.
--
--    belge.geri_gun_siniri = geriye dogru kac GUN girise izin verilir
--                            0 = SINIR YOK (istenirse kural kapatilabilir)
--  Ileri tarih yasagi ayar DEGILDIR: e-Belge'de GIB zaten reddeder.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('belge.geri_gun_siniri', '7', 'sayi', 'firma',
        'Belgeler geriye dönük kaç güne kadar girilebilir (0 = sınırsız)')
on conflict (anahtar) do nothing;

-- ------------------------------------------------------------- yetki ----
-- Genel ayarlari GORME/DEGISTIRME hakki ayri bir kod: kod listeleriyle ayni
--   grupta ama farkli bir sey (kod_liste veri, ayar davranis degistirir).
insert into public.yetki (kod, ad, grup, tur, deger_alir, kapsam_alir, sira, aktif)
values ('ayar', 'Genel ayarlar', 'yonetim', 0, 0, 0, 70, 1)
on conflict (kod) do nothing;

-- Yonetici tam, salt okuyucu yalniz gorur (078'deki desen).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id,
       1,
       case when r.id = 1 then 1 else 0 end,
       case when r.id = 1 then 1 else 0 end,
       case when r.id = 1 then 1 else 0 end
  from public.rol r
  join public.yetki y on y.kod = 'ayar'
 where r.id in (1, 2)
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

do $$
declare v_deger text; v_yetki integer;
begin
    select deger into v_deger from public.referans where anahtar = 'belge.geri_gun_siniri';
    select count(*) into v_yetki from public.rol_yetki ry
      join public.yetki y on y.id = ry.yetki_id where y.kod = 'ayar';
    raise notice '102 tamam: geri gun siniri = %, ayar yetkisi % rolde', v_deger, v_yetki;
end $$;
