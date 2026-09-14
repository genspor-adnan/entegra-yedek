-- ============================================================================
--  Gentegre AI — "İSKONTO ONAYLAYANLAR" ROLÜ
--  663_iskonto_onaylayanlar_rolu.sql
--
--  Kullanıcı: "özel bir Rol oluştur 'İskonto Onaylayanlar' diye, iskonto onayı
--  burada yer alan kişilere gitsin. İlk onaylayandan sonra diğerlerinin
--  zilinde çıkmasın."
--
--  ROL BIR ADRESTIR, ikinci bir yetki mekanizması değil: talebi kimin göreceği
--  zaten `basvuru.iskonto` yetkisi + tavanıyla belirleniyordu (661). Bu rol o
--  yetkiyi taşıyan HAZIR bir kutu - yönetim "şu kişi iskonto onaylasın" derken
--  yetki matrisinde tek tek kutucuk aramak yerine kişiyi bu role alır.
--
--  Ayrı bir "onaylayanlar tablosu" AÇMADIK: iki yerden beslenen bir yetki,
--  birinde açık öbüründe kapalı kaldığı gün sessizce yanlış davranır.
--
--  "İlk onaylayandan sonra ötekilerde görünmesin" için ek bir şey gerekmiyor:
--  zil listesi `durum = 0` (bekleyen) süzer, karar verilen talep durumu 1/2
--  olur ve herkesin listesinden aynı anda düşer. Karar `fn_iskonto_talep_karar`
--  içinde "zaten sonuçlanmış" kontrolüyle korunuyor - iki kişi aynı anda
--  basarsa ikincisi hata alır, sessizce üzerine yazamaz (662).
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) ROL
-- ---------------------------------------------------------------------------
insert into public.rol (kod, ad, sistem, aktif)
select 'iskonto_onay', 'İskonto Onaylayanlar', 0, 1
 where not exists (select 1 from public.rol where kod = 'iskonto_onay');

-- ---------------------------------------------------------------------------
--  2) ROLÜN YETKİSİ
--     Tavan %100: rol zaten "onaylayan" demek. Daha dar bir tavan isteyen
--     kurum Yetkiler ekranından Sınır sütununu düşürür (661).
--
--     (Başvuruda birim fiyat kutusu zaten tüm rollere kapalı - fiyat listeden
--     gelir, indirim yalnız İskonto satırından yapılır.)
-- ---------------------------------------------------------------------------
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 0, 0, 0, '100'
  from public.rol r
  cross join public.yetki y
 where r.kod = 'iskonto_onay'
   and y.kod = 'basvuru.iskonto'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- Rolün başvuru/belge ekranını açabilmesi için görme yetkisi: onaylayacağı
--   belgeyi göremeyen kişi, karar verdiği tutarı da doğrulayamaz.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r
  cross join public.yetki y
 where r.kod = 'iskonto_onay'
   and y.kod in ('belge', 'belge_satir')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

do $$
begin
    raise notice '663 tamam: rol % · yetki satiri %',
        (select count(*) from public.rol where kod = 'iskonto_onay'),
        (select count(*) from public.rol_yetki ry
           join public.rol r on r.id = ry.rol_id where r.kod = 'iskonto_onay');
end $$;
