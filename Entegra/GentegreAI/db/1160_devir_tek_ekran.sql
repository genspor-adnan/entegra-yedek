-- =============================================================================
--  1160  DEVİR GİRİŞİ - tek ekran (Cari · Kasa · Banka · POS · Kredi · Kredi Kartı)
--
--  Kullanıcı (24.10.2026): "ekranlar dizinindeki jenerik devir girişi mockup'ı
--  kodla" (mockup Ekranlar/devir_girisi.html). Cari devri (1156, mali_hareket
--  tür 2) her hesap türüne genelleşti; karttaki hesap.acilis_bakiye alanını
--  hiçbir bakiye okumuyordu - bundan sonra devir satırına çevrilir (uç:
--  /api/devir/acilis-cevir), alan kartta gizlenir.
--
--  EKRAN KODU: finans.cari_devir → finans.devir (yeniden ad; haklar aynen
--  kalır, rol_yetki satırlarına dokunulmaz). Menü maddesi `cari-devir`
--  koduyla kalır (GenProfil menü düzeni kodla tutuyor), adı "Devir Girişi",
--  yolu /devir. Veri hakkı türün kendi kodu (Ekstre kuralı, 1158).
--  İdempotent.
-- =============================================================================

begin;

-- Yetki kodu yeniden ad (finans.devir zaten varsa eski kod silinir - haklar yeni kodda).
do $$
begin
  if exists (select 1 from public.yetki where kod = 'finans.cari_devir')
     and not exists (select 1 from public.yetki where kod = 'finans.devir') then
    update public.yetki set kod = 'finans.devir', ad = 'Devir Girişi (Finans)' where kod = 'finans.cari_devir';
  elsif exists (select 1 from public.yetki where kod = 'finans.cari_devir') then
    -- İkisi de var: eski kodun haklarını yeniye taşı, eskiyi kaldır.
    insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
    select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
      from public.rol_yetki ry
      join public.yetki ye on ye.id = ry.yetki_id and ye.kod = 'finans.cari_devir'
      join public.yetki yn on yn.kod = 'finans.devir'
    on conflict (rol_id, yetki_id) do nothing;
    delete from public.rol_yetki where yetki_id in (select id from public.yetki where kod = 'finans.cari_devir');
    delete from public.yetki where kod = 'finans.cari_devir';
  end if;
end $$;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'finans.devir');

-- Yardım kataloğu: cari-devir maddesi tek ekranı tarif eder.
update public.ai_rehber_ekran
   set rota = '/devir', baslik = 'Devir Girişi', yol = 'Finans › Devir Girişi', menu_ad = 'Devir Girişi',
       yetki_kodu = 'finans.devir',
       anahtar = 'devir açılış bakiyesi cari kasa banka pos kredi kredi kartı sisteme geçiş toplu excel',
       aciklama = 'Tek devir ekranı: cari (müşteri / tedarikçi), kasa, banka, POS, kredi ve kredi kartı hesaplarının '
               || 'sisteme geçiş açılış bakiyesi - tek hesap, toplu (Excel) ve karttaki eski açılış bakiyelerini '
               || 'devir satırına çevirme. Devir, hesabın "Devir" türünde hareketidir; ekstre ve bakiyeler buradan beslenir.'
 where kaynak = 'cari-devir';

commit;
