-- ============================================================================
--  Gentegre AI — ONAY HATIRLATMA İŞİ DEVREYE ALINIYOR
--  762_onay_hatirlatma_aktif.sql
--
--  Kullanıcı: "hatırlatma işini de aktif et."
--
--  746 `onay.hatirlatma` zamanlı işini kurmuş ama **`aktif = 0`** bırakmıştı:
--  o tarihte bildirim yolu uçtan uca denenmemişti ve her sabah kimseye
--  ulaşmayan bir iş koşturmak, kuyruğu hatalı satırla doldurmaktan başka işe
--  yaramazdı. 761 bildirimlerin neden kuyruğa düşmediğini çözdü; iş artık
--  gerçekten çalışıyor.
--
--  ============ NE YAPAR ===============================================
--  Her gün **09:00**'da `v_onay_kutusu`'ndaki `gecikme_gun > 0` basamakları
--  tarar ve sahiplerine `onay.hatirlatma` yazar. Sabah saati bilinçli:
--  gecikmiş imzayı gün başında hatırlatmak, akşam hatırlatıp ertesi güne
--  bırakmaktan iyidir.
--
--  GÜNDE BİR KEZ: aynı basamak için bugün hatırlatma yazıldıysa atlanır
--  (süzgeç ŞABLONA bakar, "herhangi bir onay bildirimi" demez - öyle olsaydı
--  sıra geldiğinde yazılan `onay.istek`, tam da gecikmenin başladığı gün
--  hatırlatmayı bastırırdı).
--
--  ============ DEVREYE ALMADAN ÖNCE DENENDİ ===========================
--  Elle tetiklendi: 3 gecikmiş basamak için 12 hatırlatma (4 alıcı) kuyruğa
--  alındı; aynı gün ikinci tetikte 0 yazdı - günde bir kez kuralı tuttu.
--
--  `sonraki` SIFIRLANIYOR: iş kapalıyken hesaplanmış bir zaman kalmış
--  olabilir; null bırakıp işçinin bir sonraki turda yeniden hesaplamasına
--  bırakmak, geçmişte kalmış bir `sonraki` yüzünden işin devreye girer
--  girmez koşmasından daha öngörülebilir.
-- ============================================================================
\set ON_ERROR_STOP on

update public.zamanli_is
   set aktif = 1,
       sonraki = null,
       aciklama = 'Gecikmis onay basamaklarini sahiplerine hatirlatir (746/762). '
                  || 'Gunde bir kez; alicisi bulunamayan basamak gunluge yazilir.',
       degistirme_tarihi = now()
 where kod = 'onay.hatirlatma';

do $$
declare r record;
begin
    select kod, aktif, periyot, saat, dakika, basarili, son_sonuc
      into r from public.zamanli_is where kod = 'onay.hatirlatma';

    if r.kod is null then
        raise exception 'onay.hatirlatma isi bulunamadi - once 746 uygulanmali.'
              using errcode = 'GK404';
    end if;

    raise notice '762 tamam: % aktif=% saat=%:% son sonuc: %',
                 r.kod, r.aktif, r.saat, lpad(r.dakika::text, 2, '0'), r.son_sonuc;
end $$;
