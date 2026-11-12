-- 1320 - fn_teletip_hesap_ayar: hesap modeli yokken eski ayarlar "aktif" şartı aranmadan döner
--
-- 1317'de eski (teletip.*) yol yalnız teletip.aktif = 1 iken ayar döndürüyordu. Oysa eski davranışta "aktif" yalnız
-- KUYRUĞA ALIRKEN bakılıyordu (tetikler fn_teletip_aktif); kuyruktaki satır gönderimde aktif şartı aramadan gidiyordu.
-- Kapatılmadan önce kuyruğa girmiş satırlar takılı kalmasın - geri uyum birebir. Hesap modelinde değişiklik yok
-- (aktif hesap yoksa null = şubede kapalı).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;
create or replace function public.fn_teletip_hesap_ayar(p_sube integer)
returns jsonb language sql stable as $$
  select case
    when public.fn_teletip_hesap_modeli() then (
      select jsonb_build_object(
               'HesapId', e.id, 'HesapAd', e.ad, 'Test', e.test_mi = 1,
               'FirmaKodu', coalesce(e.uygulama_kodu, ''), 'Hl7Adres', coalesce(e.url, ''),
               'XdsAdres', coalesce(e.ayarlar->>'xdsAdres', ''), 'DozAdres', coalesce(e.ayarlar->>'dozAdres', ''),
               'Encoding', coalesce(nullif(e.ayarlar->>'encoding', ''), 'UTF8'),
               'SubeNo', coalesce(nullif(e.ayarlar->>'subeNo', ''), '1'),
               'XdsHastaOid', coalesce(nullif(e.ayarlar->>'xdsHastaOid', ''), '1.3.6.1.4.1.21367.13.20.3000'),
               'MirthHesapId', coalesce(e.ayarlar->>'mirthHesapId', ''))
        from public.entegrasyon_hesap e where e.id = public.fn_teletip_hesap(p_sube))
    else (
      select jsonb_build_object(
          'HesapId', 0, 'HesapAd', 'Teletıp Ayarları (eski)', 'Test', false,
          'FirmaKodu', coalesce(max(deger) filter (where anahtar = 'teletip.firma_kodu'), ''),
          'Hl7Adres', coalesce(max(deger) filter (where anahtar = 'teletip.hl7_adres'), ''),
          'XdsAdres', coalesce(max(deger) filter (where anahtar = 'teletip.xds_adres'), ''),
          'DozAdres', coalesce(max(deger) filter (where anahtar = 'teletip.doz_adres'), ''),
          'Encoding', coalesce(nullif(max(deger) filter (where anahtar = 'teletip.encoding'), ''), 'UTF8'),
          'SubeNo', coalesce(nullif(max(deger) filter (where anahtar = 'teletip.sube_no'), ''), '1'),
          'XdsHastaOid', coalesce(nullif(max(deger) filter (where anahtar = 'teletip.xds_hasta_oid'), ''), '1.3.6.1.4.1.21367.13.20.3000'),
          'MirthHesapId', '')
        from public.referans where anahtar like 'teletip.%')
  end
$$;
commit;
