-- 1388: v_cek_senet_hareket İşlem Yeri düzeltmesi (1386).
--
-- fn_taraf_ad cari yokken NULL değil '' döner; 1386'daki coalesce(fn_taraf_ad(...), hesap.ad) bu yüzden hesaba hiç
-- geçmiyordu - takas, bankaya teminat ve tahsil satırlarında İşlem Yeri (banka / kasa adı) boş kalıyordu.

create or replace view public.v_cek_senet_hareket as
select h.id,
       h.cek_senet_id,
       h.tarih,
       coalesce(nullif(h.belge_no, ''), k.makbuz_no, '')::varchar(30)                                as belge_no,
       h.islem,
       h.eski_durum,
       h.yeni_durum,
       coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad), ''), hs.ad, '')::varchar(150)     as islem_yeri,
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
