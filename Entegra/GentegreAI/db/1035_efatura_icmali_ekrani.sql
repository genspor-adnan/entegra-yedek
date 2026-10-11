-- =============================================================================
--  1035  FATURA / e-BELGE İCMALİ - ekran kodu
--
--  Kullanıcı (11.10.2026): "efatura icmalini mockup gibi yap" (mockup
--  Ekranlar/İcmal/fatura_ebelge_icmali.html).
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    efatura.icmal   Finans › Fatura / e-Belge İcmali   ← belge.satis.fatura
--  Satış faturalarını gören rol yeni ekranı AYNI haklarla görür. İdempotent.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('efatura.icmal', 'belge.satis.fatura', 'Fatura / e-Belge İcmali (Finans)', 'Finans');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1035: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('efatura-icmal', '/efatura-icmal', 'Fatura / e-Belge İcmali', 'Finans › Fatura / e-Belge İcmali',
     'Finans', 'Fatura / e-Belge İcmali', 'efatura.icmal', 0,
     'e-fatura e-arşiv e-irsaliye icmal gib gönderilmedi gönderim hatası 7 gün kuralı kdv özeti seri süreklilik iade iptal kurum faturası',
     'Dönemde kesilen e-belgelerin türe / seriye göre adet, matrah, KDV, iade ve iptali; GİB''e gitmeyen, hata alan, 7 günü aşan ve '
     || 'e-Belgesi hazırlanmamış faturalar (seçilip yeniden gönderilir); KDV oran özeti, alıcı grubu, kurum faturaları, seri sürekliliği, A4.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
