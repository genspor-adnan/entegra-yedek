-- =============================================================================
--  1158  EKSTRE - tek ekran (Cari · Kasa · Banka · POS · Kredi) - ekran kodu
--
--  Kullanıcı (23.10.2026): "müşteri/tedarikçi/kasa/banka/pos modülleri tek
--  ekstre listesi kullanabilir mi" → "tek ekstre ekranı için mockup hazırla"
--  → "genel ekstre mockup uygula" (mockup Ekranlar/ekstre_tek_ekran.html).
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    finans.ekstre               Finans › Ekstre               ← kasa.finans
--  Finans kasa ekranlarını (kasa.finans) gören rol yeni ekranı AYNI haklarla
--  görür. VERİ hakkı ayrıdır ve değişmez: cari hareketleri `mali_hareket`,
--  hesap hareketleri hesap türünün kendi kodu (hesap.tanim / .banka / .pos /
--  .kredi / .kredi_karti) - uç (EkstreUclari) seçilen türe göre bunları
--  ister; ekranın tür seçicisi yalnız yetkili türleri gösterir.
--  İdempotent: var olan rol_yetki satırına dokunmaz.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('finans.ekstre', 'kasa.finans', 'Ekstre (Finans)', 'Finans');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1158: % satırın eski kodu yetki tablosunda yok', n; end if;
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
    ('ekstre', '/ekstre', 'Ekstre', 'Finans › Ekstre',
     'Finans', 'Ekstre', 'finans.ekstre', 0,
     'ekstre hesap ekstresi cari ekstre kasa banka pos kredi hareket devir bakiye borç alacak giriş çıkış aylık vade',
     'Tek ekstre ekranı: cari (müşteri / tedarikçi), kasa, banka, POS, kredi hesaplarının hareketleri - '
     || 'dönem başı devir, yürüyen bakiye, para birimi grupları, aylık özet, belge kalemleri (cari), A4 çıktı. '
     || 'Liste ve kartlardaki "Ekstre" düğmesi bu ekranı ilgili hesapla açar.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
