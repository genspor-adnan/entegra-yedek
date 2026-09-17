-- ============================================================================
--  Gentegre AI — 905 / 906 ÇAKIŞMALARI AYIKLANIYOR
--  756_log_tablo_id_905_906.sql
--
--  Kullanıcı: "905 ve 906'yı da temizle."
--
--  755'te avansın 907/908'i düzeltildi. Aynı sıkışıklık 905 ve 906'da da
--  vardı: numaraların KANONİK sahibi `KaynakKatalogu.Log.cs` içindeki
--  `TabloAdiIfade` case'idir ve orada
--
--      905 = Eğitim/Sertifika (personel_egitim)
--      906 = Acil Durum Kişi  (taraf_acil_kisi)
--
--  yazıyor. Oysa katalogda üçer kart aynı numarayı taşıyordu:
--
--      905 -> personel_egitim (kanonik) · randevu · personel_izin_hak
--      906 -> taraf_acil_kisi (kanonik) · "Hekim Bilgisi" · resmi_tatil
--
--  ============ NEDEN ÖNEMLİ ===========================================
--  `islem_log.tablo_id` denetim izinin "neyin kaydı" sorusuna verdiği tek
--  cevaptır ve `kayit_id` ancak onunla birlikte bir anlam taşır. İki tablo
--  aynı numarayı paylaşınca satırın hangi kayda ait olduğu ARTIK KAYITTAN
--  OKUNAMAZ - bu dosyanın geçmişi taşırken `ust_tablo_id`ye ve anahtarın
--  şekline dayanmak zorunda kalması bunun kanıtı.
--
--  Bugün ekranda tablo_id'nin kendisi ada çevrilmiyor (yalnız `ust_tablo_id`
--  çevriliyor), yani görünen bir yanlış etiket YOK. Zarar iki yerde:
--  numaraya bakarak kaydı çözen her yol (908'in `kasa_islem`e join'i gibi -
--  755'te avans kesintisi tam bunun yüzünden kasa işlemiyle eşleşiyordu)
--  yanlış tabloya gider, ve alt satır olarak yazılan kayıtlarda
--  `ust_tablo_id` doğrudan yanlış adı gösterir.
--
--  ============ HANGİSİ TAŞINIR ========================================
--  Kanonik sahipler yerinde kalır; sonradan aynı numaraya oturanlar
--  taşınır. Yeni numaralar 755'in devamı (en yüksek kullanılan 1258):
--
--      1259 = Randevu
--      1260 = İzin Hakedişi   (personel_izin_hak)
--      1261 = Hekim Bilgisi   (taraf_personel üzerindeki hekim sekmesi)
--      1262 = Resmî Tatil
--
--  ============ GEÇMİŞ LOG SATIRLARI BURADA TAŞINABİLİYOR ==============
--  755'te avans satırları taşınamamıştı, çünkü avans ile hasta kaydını
--  ayırt edecek bir işaret yoktu. Burada VAR: `ust_tablo_id`. Kanonik
--  sahiplerin ikisi de bir KART DETAYIDIR ve satırları personel kartının
--  altında (`ust_tablo_id = 73`) yazılır; randevu, izin hakedişi ve resmî
--  tatil ise kendi başlarına kayıttır (`ust_tablo_id = 0`).
--
--  Ayrım yine de yalnız buna bırakılmadı: her güncelleme ikinci bir işaret
--  daha arıyor (anahtarın şekli, ya da kanonik tabloda BULUNMAMA). Bir satır
--  iki tarafa birden uyuyorsa dokunulmuyor - şüpheli satırı yanlış yere
--  taşımak, izi onarmak için ikinci kez bozmak olurdu.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) RANDEVU: 905 -> 1259
--     `ust_tablo_id = 0` olan 905 satırları randevu ya da izin hakedişi
--     olabilir; ikisini ayırmak için hakedişte OLMAMA koşulu aranıyor.
-- ---------------------------------------------------------------------------
update public.islem_log l
   set tablo_id = 1259
 where l.tablo_id = 905
   and coalesce(l.ust_tablo_id, 0) = 0
   and not exists (select 1 from public.personel_izin_hak h where h.id = l.kayit_id);

-- ---------------------------------------------------------------------------
--  2) İZİN HAKEDİŞİ: 905 -> 1260
--     Yukarıdaki adımdan ARTAKALAN 905/ust=0 satırları: hepsi hakediş.
-- ---------------------------------------------------------------------------
update public.islem_log l
   set tablo_id = 1260
 where l.tablo_id = 905
   and coalesce(l.ust_tablo_id, 0) = 0;

-- ---------------------------------------------------------------------------
--  3) HEKİM BİLGİSİ: 906 -> 1261
--     Personel kartı altındaki (`ust_tablo_id = 73`) 906 satırları hem acil
--     durum kişisi hem hekim sekmesi olabilir.
--
--     AYRIM `kayit_id = ust_kayit_id`: hekim sekmesi 1:1 bir detaydır ve
--     anahtarı kartın kendi id'sidir (`taraf_personel.id = taraf.id`), yani
--     satır kendi kartıyla aynı numarayı taşır. Acil kişi ayrı bir tabloda
--     kendi id'siyle durur ve karta `taraf_id` ile bağlanır.
--
--     Tabloda VARLIĞA bakmıyoruz: kaydı sonradan silinmiş bir personelin
--     log satırı da taşınmalı - denetim izinin değeri zaten silinmiş kaydı
--     anlatabilmesinde.
-- ---------------------------------------------------------------------------
update public.islem_log l
   set tablo_id = 1261
 where l.tablo_id = 906
   and l.ust_tablo_id = 73
   and l.kayit_id = l.ust_kayit_id
   and not exists (select 1 from public.taraf_acil_kisi a where a.id = l.kayit_id);

-- ---------------------------------------------------------------------------
--  4) RESMÎ TATİL: 906 -> 1262
--     Resmî tatil bir kart detayı değil, kendi başına kayıttır: üst tablosu
--     yok. Acil durum kişisi ise her zaman bir kartın altındadır.
-- ---------------------------------------------------------------------------
update public.islem_log l
   set tablo_id = 1262
 where l.tablo_id = 906
   and coalesce(l.ust_tablo_id, 0) = 0;

do $$
declare r record;
begin
    raise notice '756 tamam - log satirlari:';
    for r in
        select tablo_id, coalesce(ust_tablo_id, 0) as ust, count(*) as adet
          from public.islem_log
         where tablo_id in (905, 906, 1259, 1260, 1261, 1262)
         group by 1, 2 order by 1, 2
    loop
        raise notice '   tablo_id=% ust=% adet=%', r.tablo_id, r.ust, r.adet;
    end loop;
end $$;
