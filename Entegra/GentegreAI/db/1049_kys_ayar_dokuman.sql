-- =============================================================================
--  1049  KURUMSAL KALİTE - AYARLAR + KALİTE DOKÜMANLARI
--
--  Kullanıcı (12.10.2026): "Dokümandan sonra Kalite menüsü aç ve oraya kalite
--  mockuplarını ekle.. yalnız doküman kartını yapma.. onu doküman modülünden
--  kullanalım". Mockuplar Ekranlar/Kalite/kalite_ayarlar.html,
--  kalite_dokuman_yonetimi.html. Temel: 1048.
--
--  KALİTE DOKÜMANLARI = mevcut doküman modülü (419/431/758). Ayrı tablo YOK:
--    "Kalite Dokümanları" üst kategorisi (kısaltma KY) + tür alt kategorileri
--    (PR prosedür · TL talimat · FR form · LS liste · PL plan · SÜ süreç kartı ·
--    GT görev tanımı · EK el kitabı · DD dış kaynaklı doküman). Kalite menüsündeki
--    liste doküman listesini bu kategori yoluna süzer; kart doküman kartıdır.
--    Var olan "Prosedür" ve "Talimat" kategorileri ÜST KATEGORİSİ BOŞSA bu
--    kökün altına alınır (yol tetiği "Kalite Dokümanları › Prosedür" yazar);
--    kurumun başka bir ağaca taşıdığı kategoriye dokunulmaz.
--    Kök kategori id'si referans 'kys.dokuman_kategori_id'de (ad değişse de bulunur).
--
--  AYARLAR: birim kalite sorumluları ve komiteler generic liste + kart
--    (görünümler aşağıda). kys.* referans ayarları 1048'deki gibi kalır.
--  İdempotent.
-- =============================================================================

begin;

-- ------------------------------------------------- kalite doküman kategorisi --
do $$
declare
  v_kok   integer;
  v_akis  integer;
begin
  select nullif(deger, '')::integer into v_kok from public.referans where anahtar = 'kys.dokuman_kategori_id';
  if v_kok is null or not exists (select 1 from public.dokuman_kategori where id = v_kok) then
    select id into v_kok from public.dokuman_kategori where ad = 'Kalite Dokümanları' and ust_id is null order by id limit 1;
  end if;
  if v_kok is null then
    insert into public.dokuman_kategori (ad, kisaltma, surumlu, gozden_gecirme_ay, gizlilik, aktif, sira)
    values ('Kalite Dokümanları', 'KY', 1, 24, 2, 1, 50) returning id into v_kok;
  end if;

  if exists (select 1 from public.referans where anahtar = 'kys.dokuman_kategori_id') then
    update public.referans set deger = v_kok::text where anahtar = 'kys.dokuman_kategori_id' and deger is distinct from v_kok::text;
  else
    insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
    values ('kys.dokuman_kategori_id', v_kok::text, 'sayi', 'firma',
            'Kalite Dokümanları kök doküman kategorisi (1049). Kalite menüsündeki doküman listesi bu ağaca süzülür.');
  end if;

  -- Onay akışı: var olan Prosedür kategorisinin akışı (kurum ayarladıysa onu izler).
  select akis_id into v_akis from public.dokuman_kategori where kisaltma = 'PR' and akis_id is not null order by id limit 1;

  -- Var olan Prosedür / Talimat: yalnız ÜST KATEGORİSİ BOŞSA köke alınır.
  update public.dokuman_kategori
     set ust_id = v_kok,
         sira = case kisaltma when 'PR' then 1 else 2 end,
         gozden_gecirme_ay = case when gozden_gecirme_ay = 0 then 24 else gozden_gecirme_ay end
   where ust_id is null and id <> v_kok and kisaltma in ('PR', 'TL') and ad in ('Prosedür', 'Talimat');

  insert into public.dokuman_kategori (ad, kisaltma, surumlu, akis_id, gozden_gecirme_ay, gizlilik, aktif, sira, ust_id)
  select v.ad, v.kisaltma, v.surumlu, case when v.akisli = 1 then v_akis end, v.ay, 2, 1, v.sira, v_kok
    from (values
      ('Prosedür',              'PR', 1::smallint, 1, 24::smallint, 1::smallint),
      ('Talimat',               'TL', 1::smallint, 1, 24::smallint, 2::smallint),
      ('Form',                  'FR', 1::smallint, 1, 36::smallint, 3::smallint),
      ('Liste',                 'LS', 1::smallint, 1, 12::smallint, 4::smallint),
      ('Plan',                  'PL', 1::smallint, 1, 12::smallint, 5::smallint),
      ('Süreç Kartı',           'SÜ', 1::smallint, 1, 24::smallint, 6::smallint),
      ('Görev Tanımı',          'GT', 1::smallint, 1, 24::smallint, 7::smallint),
      ('El Kitabı',             'EK', 1::smallint, 1, 24::smallint, 8::smallint),
      ('Dış Kaynaklı Doküman',  'DD', 0::smallint, 0,  0::smallint, 9::smallint))
      as v(ad, kisaltma, surumlu, akisli, ay, sira)
   where not exists (select 1 from public.dokuman_kategori k where k.ust_id = v_kok and k.kisaltma = v.kisaltma);
end $$;

-- ------------------------------------------------------------ ayar görünümü --
--  Birim sorumluları listesi: departman adı + kişiler.
create or replace view public.v_kalite_birim_sorumlu as
select s.id, s.departman_id, coalesce(d.ad, '') as departman_adi, coalesce(d.kod, '') as departman_kodu,
       s.sorumlu_id, coalesce(fn_taraf_ad(ts.unvan, ts.ad, ts.soyad), '') as sorumlu_adi,
       s.yedek_id, coalesce(fn_taraf_ad(ty.unvan, ty.ad, ty.soyad), '') as yedek_adi,
       s.kontrol_eden_id, coalesce(fn_taraf_ad(tk.unvan, tk.ad, tk.soyad), '') as kontrol_eden_adi,
       s.aciklama, s.aktif, case s.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi,
       s.sube_id, s.ekleme_tarihi
  from public.kalite_birim_sorumlu s
  left join public.departman d on d.id = s.departman_id
  left join public.taraf ts on ts.id = s.sorumlu_id
  left join public.taraf ty on ty.id = s.yedek_id
  left join public.taraf tk on tk.id = s.kontrol_eden_id;

create or replace view public.v_kalite_komite as
select k.id, k.kod, k.ad, k.baskan_id, coalesce(fn_taraf_ad(tb.unvan, tb.ad, tb.soyad), '') as baskan_adi,
       k.sekreter_id, coalesce(fn_taraf_ad(ts.unvan, ts.ad, ts.soyad), '') as sekreter_adi,
       k.gorev_alani, k.toplanti_periyot_ay, k.aktif, case k.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi,
       k.sira, k.sube_id,
       (select count(*) from public.kalite_komite_uye u where u.komite_id = k.id)::int as uye_sayisi
  from public.kalite_komite k
  left join public.taraf tb on tb.id = k.baskan_id
  left join public.taraf ts on ts.id = k.sekreter_id;

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('kys-dokuman', '/kys-dokuman', 'Kalite Dokümanları', 'Kalite › Kalite Dokümanları', 'Kalite', 'Kalite Dokümanları',
     'kys.dokuman', 0,
     'kalite doküman prosedür talimat form liste plan süreç görev tanımı el kitabı dış kaynaklı revizyon sürüm gözden geçirme onay yayın iso sks',
     'Kalite Dokümanları kategorisi altındaki dokümanlar (prosedür, talimat, form, liste, plan...). Doküman modülünün listesi ve kartı kullanılır: '
     || 'yükleme, sürüm, onaya gönderme, yayın ve paylaşım doküman kartından. Türler Doküman › Ayarlar › Kategoriler altında (Kalite Dokümanları dalı).',
     'dokuman-liste'))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
