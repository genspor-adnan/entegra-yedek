-- 1345 - ANA EKRAN MALİ ÖZET yetkisi (mali.ozet): mali / finansal bilgiler yalnız sorumlu kişilere.
--
-- Kullanıcı 15.11.2026: "ana ekrandaki mali/finansal bilgiler sadece muhasebe sorumlusu / mali işler müdürü vb
--   sorumlu kişilere görünsün.. admin görmesin". Yönetici rolünün ekran yetkileri bu bilgileri açıyordu; yeni
--   AKSİYON yetkisi mali.ozet (tur 1) olmadan sunucu şunları vermez:
--   * gösterge panelleri: "Finans Özeti" paneli; öteki panellerdeki aySatis / ayAlis / tahsilat / acikTahsilat
--     kutuları ve "Kurum & sözleşme (açık tahakkuk)" bloğu;
--   * başlangıç rol kutucuklarındaki aynı göstergeler;
--   * gündem (bekleyen işler) kartları: ödeme vadesi, tahsil edilecek, risk limiti, çek/senet, kredi taksiti, planlı
--     ödemeler, nakit durumu, banka hareketi, tahsil edilmemiş hasta payı.
--   Banko görevlisinin KENDİ oturum kartı (nakit / kart) kalır - kendi kasası.
-- Yetki yalnız "Muhasebe / Finans" rolüne verilir; Yönetici (admin) dahil ötekiler Güvenlik › Roller matrisinden alır.
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
values ('mali.ozet', 'Ana ekran mali özet (gösterge, gündem kartları)', 'Finans', 1,
        coalesce((select max(sira) from public.yetki where grup = 'Finans'), 500) + 1, 0, 'finans')
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 1, modul = excluded.modul, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 0, 0, 0, 0
  from public.rol r join public.yetki y on y.kod = 'mali.ozet'
 where r.kod = 'muhasebe'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1 where r.kod = 'muhasebe';

commit;
