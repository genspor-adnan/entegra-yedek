-- 1386: çek / senet hareketleri Delphi gibi (kullanıcı 20.11.2026: "çek/senet hareketleri aynı delphi erp deki
-- çek/senet hareketleri gibi olmalı" + "işlem buton ve altında menüyü de ekle").
--
-- * cek_senet_hareket.belge_no: Delphi CEKHAREKET.BELGENO - işlemin makbuz / bordro numarası. Kasa işlemi yazan
--   harekette (tahsil, ödeme, ciro...) numara kasa makbuzundan okunur; kasasız harekette (takas, teminat-banka,
--   karşılıksız) kullanıcı yazar.
-- * v_cek_senet_hareket: kartın Hareketler sekmesi - Delphi grid'inin kolonları (Tarih, Makbuz No, İşlem,
--   İşlem Yeri, Açıklama, Yerel Tutar). İşlem Yeri = cari ünvanı, yoksa hesap adı (Delphi ISLEMYERI).
-- * Yeni işlem kodu 140 "İcraya verildi" (Delphi 134). 1147 aktarımı Delphi 134'ü 134'e (karşılıksız) eşlemişti;
--   o satırlar olduğu gibi kalır (geçmiş veri, ayrımı kaynakta zaten yok sayıldı).

alter table public.cek_senet_hareket add column if not exists belge_no varchar(30) not null default '';

create or replace view public.v_cek_senet_hareket as
select h.id,
       h.cek_senet_id,
       h.tarih,
       coalesce(nullif(h.belge_no, ''), k.makbuz_no, '')::varchar(30)                    as belge_no,
       h.islem,
       h.eski_durum,
       h.yeni_durum,
       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad), hs.ad, '')::varchar(150)      as islem_yeri,
       h.aciklama,
       c.yerel_tutar,
       h.kasa_islem_id,
       h.taraf_id,
       h.hesap_id,
       h.ekleyen
  from public.cek_senet_hareket h
  join public.cek_senet c on c.id = h.cek_senet_id
  left join public.taraf t on t.id = h.taraf_id
  left join public.hesap hs on hs.id = h.hesap_id
  left join public.kasa_islem k on k.id = h.kasa_islem_id;

comment on view public.v_cek_senet_hareket is
  'Çek / senet kartı Hareketler sekmesi (1386) - Delphi CEKHAREKET grid''i: Tarih, Makbuz No, İşlem, İşlem Yeri, Açıklama, Yerel Tutar.';
