-- =====================================================================
--  736_kabul_its_bildirim.sql
--  MAL KABUL → İTS BİLDİRİMİ sekmesi.
--
--  Mockup: `Ekranlar/Eczane/eczane_mal_kabul.html` "İTS Bildirimi"
--  (Bildirim · İlaç · Lot · Adet · Gönderen GLN · Durum).
--
--  ============= BİLDİRİM BELGEYE, SATIR MUAYENEYE BAĞLI ================
--  734'te okutulan kutular `its_bildirim_satir.kabul_id` ile muayeneye
--  bağlandı; bildirimin KENDİSİ belgeye (irsaliyeye) bağlı kaldı - bir
--  irsaliyenin birden çok muayene tutanağı olabilir ama İTS'e giden bildirim
--  sevkiyat başına birdir. Bu yüzden tutanağın bildirimi SATIRLARINDAN
--  türetilir; `its_bildirim`e ikinci bir `kabul_id` koysaydık iki tutanaklı
--  bir irsaliyede o kolon hangi tutanağı göstereceğini bilemezdi.
--
--  ============= AÇIKLAMA KOLONU ========================================
--  `its_bildirim`de serbest metin alanı yoktu; tek metin `hata_mesaj`dı ve
--  oraya "neden iptal edildi" yazmak hata olmayan bir şeyi hata gibi
--  göstermek olurdu.
-- =====================================================================

alter table public.its_bildirim
  add column if not exists aciklama varchar(200) not null default '';

comment on column public.its_bildirim.aciklama is
  '736: serbest not (or. "reddedilen kalemlerin kutulari - bildirilmedi"). '
  'Hata mesaji DEGIL: hata_mesaj yalniz gonderim hatasi icindir.';

-- ================================================= tutanağın bildirimleri
create or replace view public.v_kabul_its_bildirim as
select b.id,
       s.kabul_id,
       b.tur,
       b.durum,
       b.test_mi,
       b.belge_id,
       b.karsi_gln,
       b.islem_tarihi,
       b.its_bildirim_no,
       b.deneme,
       b.son_deneme,
       b.hata_kodu,
       b.hata_mesaj,
       b.aciklama,
       b.ekleme_tarihi,
       count(*)                                    as kutu,
       count(distinct s.stok_id)                   as kalem,
       count(*) filter (where s.dogrulama = 2)     as beklenmeyen
  from public.its_bildirim b
  join public.its_bildirim_satir s on s.bildirim_id = b.id
 where s.kabul_id is not null
 group by b.id, s.kabul_id, b.tur, b.durum, b.test_mi, b.belge_id, b.karsi_gln,
          b.islem_tarihi, b.its_bildirim_no, b.deneme, b.son_deneme,
          b.hata_kodu, b.hata_mesaj, b.aciklama, b.ekleme_tarihi;

comment on view public.v_kabul_its_bildirim is
  '736: mal kabul tutanaginin ITS bildirimleri (kutu/kalem sayisiyla). '
  'Bildirim belgeye bagli, satir muayeneye - bag satirlardan turer.';

-- ============================================ liste: İTS durumu sütunu
-- Tutanak listesinde "bildirildi mi" görünsün: kutuları okutulmuş ama
--   bildirimi kuyruğa alınmamış tutanak, unutulmuş bir yasal yükümlülüktür.
create or replace view public.v_satinalma_kabul as
select k.*,
       (select count(*) from public.satinalma_kabul_satir s where s.kabul_id = k.id) as kalem,
       (select count(*) from public.satinalma_kabul_satir s
         where s.kabul_id = k.id and s.sonuc = 3) as ret_kalem,
       (select count(*) from public.satinalma_kabul_satir s
         where s.kabul_id = k.id and s.sayilan < s.irsaliye_miktar) as eksik_kalem,
       -- ASGARİ RAF ÖMRÜ SÖZLEŞMEDEN (733).
       (select count(*) from public.satinalma_kabul_satir s
          join public.belge b on b.id = k.siparis_belge_id
          join public.belge_satinalma bs on bs.id = b.id
          join public.tedarikci_sozlesme z on z.id = bs.sozlesme_id
         where s.kabul_id = k.id and s.skt is not null
           and coalesce(z.asgari_raf_omru_ay, 0) > 0
           and s.skt < (current_date + (z.asgari_raf_omru_ay || ' months')::interval)) as kisa_miad,
       -- REDDEDİLEN KALEM TUTARA GİRMEZ (733).
       (select coalesce(sum(s.sayilan * s.birim_fiyat) filter (where s.sonuc <> 3), 0)
          from public.satinalma_kabul_satir s where s.kabul_id = k.id) as kabul_tutar,
       -- KAREKOD (734).
       (select coalesce(sum(v.beklenen), 0) from public.v_kabul_karekod_satir v
         where v.kabul_id = k.id) as karekod_beklenen,
       (select count(*) from public.its_bildirim_satir b where b.kabul_id = k.id)
                                  as karekod_okutulan,
       -- İTS (736). EN İLERİ DURUM gösterilir: bir tutanağın birden çok
       --   bildirimi olabilir (iptal edilmiş + yeni). "Gönderildi" varsa
       --   tutanak bildirilmiştir; en son açılanı göstersek iptal edilmiş
       --   bir kaydı "durum" diye okuturduk.
       (select max(v.durum) from public.v_kabul_its_bildirim v
         where v.kabul_id = k.id and v.durum <> 5) as its_durum,
       (select count(*) from public.v_kabul_its_bildirim v
         where v.kabul_id = k.id and v.durum = 3) as its_gonderilen
  from public.satinalma_kabul k;

comment on view public.v_satinalma_kabul is
  '733/734/736: mal kabul listesi - kalem/eksik/ret, kisa miad, kabul tutari '
  '(ret haric), karekod beklenen/okutulan ve ITS bildirim durumu.';
