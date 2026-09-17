-- ============================================================================
--  Gentegre AI — MASRAF SATIR KİLİDİ KASKAD SİLMEYİ ENGELLEMESİN
--  766_masraf_satir_kilit_duzeltmesi.sql
--
--  764'teki `tg_masraf_toplam` iki iş yapıyor: toplamı yeniden hesaplamak ve
--  taslak olmayan beyanın satırlarını korumak. İkinci işi FAZLA GENİŞ
--  yapıyordu: beyanın KENDİSİ silindiğinde FK kaskadı satırları silmeye
--  çalışıyor, tetik onu da "satır değiştirme" sayıp engelliyordu.
--
--  Sonuç: onaylanmış bir masraf beyanı HİÇ SİLİNEMİYORDU ve kullanıcı
--  anlamsız bir hata alıyordu - *"Taslak olmayan masraf beyanının satırları
--  değiştirilemez"*. Oysa silmek istediği şey satır değil beyandı.
--
--  ============ AYRIM `pg_trigger_depth()` ============================
--  681'de `belge_satir` kilidinde aynı sorun çözülmüştü: doğrudan DELETE'te
--  tetik derinliği 1'dir, FK kaskadı içinden gelindiğinde daha derindir.
--  Koruma yalnız derinlik 1'de uygulanıyor.
--
--  BEYANI SİLMEYİ YASAKLAMIYORUZ: kayıt silmenin yerini iptal alır (uçta
--  öyle) ama silme hakkı yetkideyse teknik olarak mümkün olmalı - onu
--  tetikle değil yetkiyle sınırlamak doğru yerdir. Tetiğin işi satırın
--  beyandan BAĞIMSIZ değiştirilmesini engellemek.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_masraf_toplam()
returns trigger language plpgsql as $$
declare v_beyan int;
begin
    v_beyan := coalesce(new.beyan_id, old.beyan_id);

    -- KASKAD SİLME MUAF (766): beyan silindiğinde satırları da gider.
    --   Derinlik 1 = satır doğrudan değiştiriliyor; daha derin = kaskad.
    if pg_trigger_depth() = 1
       and exists (select 1 from public.personel_masraf
                    where id = v_beyan and durum <> 0) then
        raise exception 'Taslak olmayan masraf beyanının satırları değiştirilemez.'
              using errcode = 'GK422';
    end if;

    -- BEYAN SİLİNMİŞSE TOPLAM YAZILACAK SATIR DA YOK: kaskadda başlık
    --   zaten gidiyor, güncelleme sessizce sıfır satır etkiler.
    update public.personel_masraf m
       set toplam_tutar = coalesce((select sum(s.tutar)
                                      from public.personel_masraf_satir s
                                     where s.beyan_id = v_beyan), 0),
           degistirme_tarihi = now()
     where m.id = v_beyan;

    return null;
end $$;

comment on function public.tg_masraf_toplam is
  '764/766: masraf beyani toplamini satirlardan hesaplar ve taslak olmayan '
  'beyanin satirlarini korur. Kaskad silmede (pg_trigger_depth > 1) koruma '
  'uygulanmaz - yoksa onaylanmis beyan hic silinemezdi.';

do $$
begin
    raise notice '766 tamam: masraf satir kilidi kaskad silmeyi engellemiyor.';
end $$;
