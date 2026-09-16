-- =====================================================================
--  734_kabul_karekod.sql
--  MAL KABUL → KAREKOD / SERİ sekmesi.
--
--  Mockup: `Ekranlar/Eczane/eczane_mal_kabul.html` "Karekod / Seri"
--  (İlaç · GTIN · Lot · SKT · Okutulan · Beklenen · Sonuç).
--
--  ============= YENİ TABLO AÇILMADI ====================================
--  Okutulan kutuların gideceği yer ZATEN VAR: `its_bildirim` (tür 1 = mal
--  alım) ve `its_bildirim_satir` karekodu, GTIN'i, seriyi, partiyi ve son
--  kullanmayı tutuyor (427). Mal kabulde okutulan kodlar ile İTS'e
--  bildirilecek kodlar AYNI KODLARDIR - ikinci bir tablo açsaydık aynı
--  kutunun iki kaydı olur, biri diğerinden sapar ve "hangisi doğru" sorusu
--  ancak ihtilâf çıkınca sorulurdu.
--
--  EKLENEN TEK ŞEY: satırın hangi MUAYENEDE okutulduğu (`kabul_id`).
--    Bildirimin kendisi belgeye (irsaliyeye) bağlı; ama bir irsaliyenin
--    birden çok muayene tutanağı olabilir (kısmi teslimler) ve "bu kutuyu
--    kim, hangi muayenede okuttu" izlenebilirlik sorusudur. İTS tarafı için
--    de kayıptır değil kazançtır.
--
--  KUTU BENZERSİZLİĞİ ZATEN KORUNUYOR: `ux_its_karekod_tekil` (gtin, seri_no)
--    aynı kutunun ikinci kez okutulmasını reddediyor - serileştirmenin bütün
--    amacı bu. Mükerrer okutma ucta YAKALANIR ve kullanıcıya sebebiyle
--    söylenir, 23505 "beklenmeyen hata" olarak dönmez.
--
--  ============= BEKLENEN SAYI MUAYENE SATIRINDAN =======================
--  "Okutulan / Beklenen" karşılaştırmasının paydası SAYILAN miktardır,
--  irsaliyedeki değil: muayenede 85 saydıysak 85 kutu okutulmalı. İrsaliyeyi
--  payda alsaydık eksik gelen sevkiyatta ekran hep "eksik okutuldu" derdi ve
--  gerçek eksik okutma fark edilmezdi.
--
--  YALNIZ İLAÇ SAYILIR: karekod ilaç kutusunda olur. Sarf malzemesi ve
--    demirbaş için beklenen sayı 0'dır - hepsini paydaya katsaydık her
--    tutanak "karekod eksik" görünürdü.
-- =====================================================================

-- ======================================== muayene bağı (izlenebilirlik)
alter table public.its_bildirim_satir
  add column if not exists kabul_id bigint
      references public.satinalma_kabul(id) on delete set null;

comment on column public.its_bildirim_satir.kabul_id is
  '734: kutu hangi mal kabul muayenesinde okutuldu. Bildirim belgeye bagli, '
  'bu kolon MUAYENEYE - bir irsaliyenin birden cok tutanagi olabilir.';

create index if not exists ix_its_satir_kabul
  on public.its_bildirim_satir (kabul_id) where kabul_id is not null;

-- ================================================ satır bazında karşılaştırma
-- Muayene satırı ile okutulan kutular yan yana. Eşleşme STOK üzerinden
--   kurulur: karekodun GTIN'i ilaç kataloğunda bir stok kartına bakar
--   (`ilac.stok_id`), muayene satırı da aynı stoğu gösterir.
create or replace view public.v_kabul_karekod_satir as
select s.id                              as kabul_satir_id,
       s.kabul_id,
       s.sira,
       s.stok_id,
       s.ad,
       s.sayilan,
       -- BEKLENEN: yalnız KAREKOD TAŞIYAN kalem için. Kalemin karekodu
       --   olup olmadığı iki yerden bilinir - ilaç kataloğunun bağı
       --   (`ilac.stok_id`) ya da kurumun kendi barkod listesi
       --   (`stok_barkod`). Yalnız kataloğa baksaydık, stok kartlarını TİTCK
       --   kataloğuna bağlamamış bir kurumda payda hep 0 çıkar ve "okutulan /
       --   beklenen" hiçbir zaman eksik görünmezdi.
       case when exists (select 1 from public.ilac il
                          where il.stok_id = s.stok_id and coalesce(il.aktif, 1) = 1)
                or exists (select 1 from public.stok_barkod sb
                            where sb.stok_id = s.stok_id)
            -- KUTU SAYISI TAM SAYIDIR: `sayilan` numeric(18,3) ve ekranda
            --   "0 / 3.000" diye görünüyordu. Kesirli kısım kutu değil ölçü
            --   birimi artığıdır (karekodlu kalem kutuyla sayılır).
            then trunc(s.sayilan)::int else 0 end as beklenen,
       (select count(*) from public.its_bildirim_satir b
         where b.kabul_id = s.kabul_id and b.stok_id = s.stok_id) as okutulan,
       -- LOT/SKT ÇELİŞKİSİ: okutulan kutunun miadı muayene satırında yazan
       --   miaddan farklıysa, ikisinden biri yanlıştır. Sessizce geçseydik
       --   raf ömrü kontrolü yanlış tarihe bakardı.
       (select count(*) from public.its_bildirim_satir b
         where b.kabul_id = s.kabul_id and b.stok_id = s.stok_id
           and s.skt is not null and b.son_kullanma is not null
           and b.son_kullanma <> s.skt)   as skt_celiskisi,
       (select count(*) from public.its_bildirim_satir b
         where b.kabul_id = s.kabul_id and b.stok_id = s.stok_id
           and b.son_kullanma is not null and b.son_kullanma < current_date)
                                          as miadi_gecmis
  from public.satinalma_kabul_satir s;

comment on view public.v_kabul_karekod_satir is
  '734: muayene satiri basina beklenen/okutulan kutu sayisi ve celiski '
  'sayaclari. Payda SAYILAN miktardir (irsaliye degil).';

-- ================================================= tutanak özeti tazelenir
-- `v_satinalma_kabul` (733) karekod sayaçlarını da versin: liste "karekod
--   eksik" tutanağı satır açmadan gösterebilsin.
create or replace view public.v_satinalma_kabul as
select k.*,
       (select count(*) from public.satinalma_kabul_satir s where s.kabul_id = k.id) as kalem,
       (select count(*) from public.satinalma_kabul_satir s
         where s.kabul_id = k.id and s.sonuc = 3) as ret_kalem,
       (select count(*) from public.satinalma_kabul_satir s
         where s.kabul_id = k.id and s.sayilan < s.irsaliye_miktar) as eksik_kalem,
       -- ASGARİ RAF ÖMRÜ SÖZLEŞMEDEN: miadına üç ay kalmış ilaç teslim
       --   edilirse hastane imhayı da satın almış olur. Sözleşme yoksa
       --   kıyas yapılmaz (0 döner) - uydurulmuş bir eşik kimseyi korumaz.
       (select count(*) from public.satinalma_kabul_satir s
          join public.belge b on b.id = k.siparis_belge_id
          join public.belge_satinalma bs on bs.id = b.id
          join public.tedarikci_sozlesme z on z.id = bs.sozlesme_id
         where s.kabul_id = k.id and s.skt is not null
           and coalesce(z.asgari_raf_omru_ay, 0) > 0
           and s.skt < (current_date + (z.asgari_raf_omru_ay || ' months')::interval)) as kisa_miad,
       -- REDDEDİLEN KALEM TUTARA GİRMEZ: "kabul tutarı" ödenecek olandır.
       (select coalesce(sum(s.sayilan * s.birim_fiyat) filter (where s.sonuc <> 3), 0)
          from public.satinalma_kabul_satir s where s.kabul_id = k.id) as kabul_tutar,
       -- KAREKOD (734). Beklenen yalnız ilaç kalemleri için sayılır.
       (select coalesce(sum(v.beklenen), 0) from public.v_kabul_karekod_satir v
         where v.kabul_id = k.id) as karekod_beklenen,
       (select count(*) from public.its_bildirim_satir b where b.kabul_id = k.id)
                                  as karekod_okutulan
  from public.satinalma_kabul k;

comment on view public.v_satinalma_kabul is
  '733/734: mal kabul listesi - kalem/eksik/ret, kisa miadli kalem, kabul '
  'tutari (ret haric) ve karekod beklenen/okutulan.';
