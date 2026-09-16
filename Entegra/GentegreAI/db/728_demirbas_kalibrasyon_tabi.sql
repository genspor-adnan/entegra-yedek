-- =====================================================================
--  728_demirbas_kalibrasyon_tabi.sql
--  `v_demirbas_durum`: "kalibrasyona tâbi mi" sorusunu PERİYOT AYARINA
--  bağlamaktan çıkar - kaydedilmiş bir geçerlilik tarihi de tâbi kılar.
--
--  DELİK NEYDİ. 723'te tâbilik ölçütü yalnız `kalibrasyon_periyot_ay > 0`
--    idi. Periyodu ayarlanmamış (0) ama kalibrasyon kaydı olan ve sertifikası
--    SÜRESİ DOLMUŞ bir cihaz, `hazir = true` görünüyordu: künye eksikliği
--    (periyot yazılmamış), cihazı kullanılabilir gösteriyordu. Oysa o cihaz
--    için birisi kalibrasyon kaydı açmış ve bir geçerlilik tarihi yazmış -
--    yani cihaz kalibrasyona tâbi, sadece periyodu tanımlanmamış.
--
--  TERSİ HÂLÂ GEÇERLİ: periyodu 0 **ve** hiç geçerlilik tarihi olmayan cihaz
--    (sandalye, monitör) kalibrasyona tâbi değildir ve hazır sayılır. Her
--    demirbaşı kalibrasyon bekler yapmak, listeyi anlamsız uyarıyla doldururdu.
--
--  Aynı düzeltme BAKIM için de: kaydedilmiş `sonraki_bakim` tarihi, periyot
--    yazılmamış olsa da cihazı bakıma tâbi kılar.
-- =====================================================================

create or replace view public.v_demirbas_durum as
select d.id, d.kod, d.ad, d.sube_id, d.departman_id, d.risk_sinifi,
       d.durum, d.yedek_havuz,
       d.kalibrasyon_gecerlilik, d.sonraki_bakim,
       -- TÂBİ: periyot ayarlı YA DA geçerlilik tarihi kayıtlı.
       ((d.kalibrasyon_periyot_ay > 0 or d.kalibrasyon_gecerlilik is not null)
        and (d.kalibrasyon_gecerlilik is null
             or d.kalibrasyon_gecerlilik < current_date)) as kalibrasyon_gecmis,
       ((d.bakim_periyot_ay > 0 or d.sonraki_bakim is not null)
        and (d.sonraki_bakim is null or d.sonraki_bakim < current_date)) as bakim_gecmis,
       exists (select 1 from public.demirbas_is_emri e
                where e.demirbas_id = d.id and e.tur = 2
                  and e.durum between 0 and 4) as arizali,
       (d.durum = 1
        and not exists (select 1 from public.demirbas_is_emri e
                         where e.demirbas_id = d.id and e.tur = 2
                           and e.durum between 0 and 4)
        and ((d.kalibrasyon_periyot_ay = 0 and d.kalibrasyon_gecerlilik is null)
             or (d.kalibrasyon_gecerlilik is not null
                 and d.kalibrasyon_gecerlilik >= current_date))) as hazir
  from public.demirbas d;

comment on view public.v_demirbas_durum is
  '723/728: "hazir" = arizasiz VE kalibrasyonu gecerli. Kalibrasyona tabi '
  'olmak periyot ayarina DEGIL, periyot ya da kayitli gecerlilik tarihine '
  'bagli - periyodu yazilmamis ama sertifikasi dolmus cihaz hazir sayilmaz.';
