-- =====================================================================
--  737_mal_kabul_duzeltmeleri.sql
--  MAL KABUL EKRANININ UÇTAN UCA DENENMESİNDE ÇIKAN KUSURLAR (17.09.2026).
--
--  Üçü burada, kalanı kodda:
--    · İrsaliye / Sipariş alanları ham `belge_id` istiyordu  → lookup görünümü
--    · Okutulan kutunun miadı satırın miadıyla karşılaştırılıyordu; satırın
--      miadı boşsa hiç bakılmıyordu                          → kutular kendi
--                                                              aralarında da
--    · Tutanak silinince okutulmuş kutuların `kabul_id`si NULL'a düşüyordu
--                                                            → silme engeli
-- =====================================================================

-- ============================================ 1) BELGE SEÇİM GÖRÜNÜMLERİ
--
--  Kartın "İrsaliye" ve "Sipariş" alanları `sayi` tipindeydi: kullanıcıdan
--  belgenin İÇ NUMARASINI (`belge.id`) yazması bekleniyordu. Kimsenin
--  ezberinde olmayan bir sayıdır; yanlış yazılırsa muayene BAŞKA bir
--  sevkiyatla karşılaştırılır ve bu hata kendini hiç belli etmez.
--
--  SON BİR YIL: lookup bir açılır listedir, tarihi geçmiş yüz binlerce
--  belgeyi oraya dökmek seçimi imkânsız kılar. Muayene sevkiyat gelir gelmez
--  yapılır; bir yıl önceki irsaliyeye tutanak açmak istisnadır ve o zaman da
--  belge kendi ekranından açılır.
create or replace view public.v_kabul_irsaliye_lookup as
select b.id,
       coalesce(nullif(b.belge_no, ''), '#' || b.id)
         || ' · ' || to_char(b.belge_tarihi, 'DD.MM.YYYY')
         || ' · ' || coalesce(nullif(t.unvan, ''), '(tedarikçi yok)')
         || case when b.tur = 11 then ' · fatura' else '' end   as ad,
       -- AKTİF = SEÇİLEBİLİR: iptal belge (durum 2) muayene edilmez.
       case when coalesce(b.durum, 0) = 2 then 0 else 1 end::smallint as aktif,
       b.sube_id,
       b.belge_tarihi
  from public.belge b
  left join public.taraf t on t.id = b.taraf_id
 where b.tur in (10, 11)
   and b.belge_tarihi >= (current_date - interval '1 year');

comment on view public.v_kabul_irsaliye_lookup is
  '737: mal kabul kartinda irsaliye/fatura secimi (son 1 yil). Ham belge_id '
  'yazdirmak yanlis sevkiyatla karsilastirmaya yol aciyordu.';

create or replace view public.v_kabul_siparis_lookup as
select b.id,
       coalesce(nullif(b.belge_no, ''), '#' || b.id)
         || ' · ' || to_char(b.belge_tarihi, 'DD.MM.YYYY')
         || ' · ' || coalesce(nullif(t.unvan, ''), '(tedarikçi yok)')   as ad,
       case when coalesce(b.durum, 0) = 2 then 0 else 1 end::smallint as aktif,
       b.sube_id,
       b.belge_tarihi
  from public.belge b
  left join public.taraf t on t.id = b.taraf_id
 where b.tur = 9
   and b.belge_tarihi >= (current_date - interval '1 year');

comment on view public.v_kabul_siparis_lookup is
  '737: mal kabul kartinda alis siparisi secimi (son 1 yil).';

-- ======================================== 2) MİAD ÇELİŞKİSİ SATIRSIZ DA
--
--  Çelişki sayacı okutulan kutunun miadını MUAYENE SATIRININ miadıyla
--  karşılaştırıyordu ve satırın miadı boşsa (`s.skt is not null` koşulu)
--  hiç bakmıyordu. Oysa satırın miadı çoğu zaman boştur - onu dolduran
--  şey zaten kutuların kendisidir. Sonuç: aynı lota iki farklı miatlı kutu
--  sessizce girebiliyordu (E2E'de LOT-A'ya hem 2027-06-30 hem 2028-01-01).
--
--  İKİ SORU AYRI AYRI SORULUR:
--    · satırın miadı yazılıysa: kutular ona uyuyor mu,
--    · yazılı değilse: kutular BİRBİRİNE uyuyor mu (aynı lotta tek miat olur).
--  İkincisini atlamak, "karşılaştıracak bir şey yok" demek değil - kutular
--  birbirinin tanığıdır.
create or replace view public.v_kabul_karekod_satir as
select s.id                              as kabul_satir_id,
       s.kabul_id,
       s.sira,
       s.stok_id,
       s.ad,
       s.sayilan,
       -- BEKLENEN: yalnız KAREKOD TAŞIYAN kalem için (734).
       case when exists (select 1 from public.ilac il
                          where il.stok_id = s.stok_id and coalesce(il.aktif, 1) = 1)
                or exists (select 1 from public.stok_barkod sb
                            where sb.stok_id = s.stok_id)
            then trunc(s.sayilan)::int else 0 end as beklenen,
       (select count(*) from public.its_bildirim_satir b
         where b.kabul_id = s.kabul_id and b.stok_id = s.stok_id) as okutulan,
       -- LOT/SKT ÇELİŞKİSİ (737: satırın miadı boşken de bakılır).
       (select count(*) from public.its_bildirim_satir b
         where b.kabul_id = s.kabul_id and b.stok_id = s.stok_id
           and b.son_kullanma is not null
           and (case
                  when s.skt is not null then b.son_kullanma <> s.skt
                  -- Satırın miadı boş: aynı (stok, parti) içinde EN ERKEN
                  --   miattan farklı olan her kutu çelişkidir. En erkeni
                  --   ölçüt almak keyfi değil - raf ömrü kontrolü zaten
                  --   en kötü hâle bakar.
                  else b.son_kullanma <> (
                         select min(b2.son_kullanma)
                           from public.its_bildirim_satir b2
                          where b2.kabul_id = s.kabul_id
                            and b2.stok_id = s.stok_id
                            and coalesce(b2.parti_no, '') = coalesce(b.parti_no, '')
                            and b2.son_kullanma is not null)
                end))                    as skt_celiskisi,
       (select count(*) from public.its_bildirim_satir b
         where b.kabul_id = s.kabul_id and b.stok_id = s.stok_id
           and b.son_kullanma is not null and b.son_kullanma < current_date)
                                          as miadi_gecmis
  from public.satinalma_kabul_satir s;

comment on view public.v_kabul_karekod_satir is
  '734/737: muayene satiri basina beklenen/okutulan kutu ve celiski sayaclari. '
  'Miat celiskisi satirin miadi boskan kutular arasinda aranir.';

-- ================================== 3) OKUTULMUŞ KUTU SAHİPSİZ KALMASIN
--
--  `its_bildirim_satir.kabul_id` yabancı anahtarı ON DELETE SET NULL'dı:
--  tutanak silinince okutulmuş kutular belgenin taslak bildiriminde SAHİPSİZ
--  kalıyordu. O kutular sonra başka bir tutanağın bildirimiyle birlikte
--  İTS'e gidebiliyordu (736 ucundaki hata bu yüzden ortaya çıktı).
--
--  ARTIK SİLİNEMEZ: kutu okutulduysa sayım yapılmıştır ve o sayım kanıttır.
--  Tutanağı gerçekten silmek isteyen önce kutularını siler (karekod silme
--  ucu, bildirilmemiş kutu için çalışır) - bu da bilinçli bir karardır.
alter table public.its_bildirim_satir
  drop constraint if exists its_bildirim_satir_kabul_id_fkey;

alter table public.its_bildirim_satir
  add constraint its_bildirim_satir_kabul_id_fkey
  foreign key (kabul_id) references public.satinalma_kabul (id);

comment on column public.its_bildirim_satir.kabul_id is
  '734/737: kutunun okutuldugu mal kabul tutanagi. Tutanak SILINEMEZ '
  '(NO ACTION): okutulmus kutu sayimin kanitidir, sahipsiz birakilamaz.';
