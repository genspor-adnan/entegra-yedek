-- 339: BAŞVURU/SİPARİŞ KALEMİNDEN PRİM SATIRI ÜRETİLMEZ.
--
-- Kullanıcı: "başvuru ekranında belge tür = 19 ise bundan prim satırı
-- türemeyecek; ancak dönüşüm yapıp satış fatura/fiş/tahakkuk (15/16/17)
-- olursa prim oluşacak."
--
-- 330'da prim satırı tahsilat yapılır yapılmaz doğuyor, gelir belgesi henüz
-- kesilmediyse "Taslak" (durum 1) olarak duruyordu. Amaç izlenebilirlikti ama
-- sonuç yanıltıcı: hakediş listesi henüz HAK EDİLMEMİŞ primi gösteriyor,
-- toplamlar şişiyor ve satırın oranı da geçici (başvuru türüne göre eşleşen
-- kural, fatura kesilince değişebiliyor).
--
-- Yeni kural: prim yalnız GELİR BELGESİ varken doğar.
--   * tahsilat yolu (fn_prim_uret): kalemin gelir belgesi yoksa (tür 9/18/19/30
--     - sipariş/teklif/başvuru) satır ÜRETİLMEZ,
--   * dönüşüm olunca (satış tahakkuku 17 / fatura 15 / fiş 16 / irsaliye 14)
--     mevcut tetikler zaten fn_prim_uret'i yeniden çağırıyor - prim O AN doğar
--     ve doğrudan "Kesin" (durum 2) olur.
-- Faturalama zamanlı plan (332, fn_prim_uret_belge) zaten böyle çalışıyordu:
--   gelir belgesi yoksa üretmiyordu. İki yol artık aynı kuralda.
--
-- DURUM 1 (Taslak) ARTIK ÜRETİLMEZ ama kod değerleri KORUNUR (2 kesin,
--   3 onaylı, 4 ödendi): geçmiş kayıtların durum numaralarını kaydırmak
--   kapanmış hakedişlerin anlamını değiştirirdi.
\set ON_ERROR_STOP on

-- ------------------------------------------------------------ fn_prim_uret -
create or replace function public.fn_prim_uret(p_dagitim_id integer)
returns integer language plpgsql as $$
declare
  d          record;
  r          record;
  kural      record;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_belgetur smallint;
  v_kurum    integer;
  v_sube     integer;
  v_tarih    date;
  v_sayac    integer := 0;
begin
    select d2.id, d2.belge_satir_id, d2.pay, d2.tutar,
           k.islem_tarihi::date as tarih, k.durum, k.iptal_islem_id,
           k.tur as tahsilat_turu,
           s.hizmet_id, s.stok_id, s.kdv, b.sube_id, bb.odeyen_kurum_id
      into d
      from public.kasa_islem_dagitim d2
      join public.kasa_islem k on k.id = d2.kasa_islem_id
      join public.belge_satir s on s.id = d2.belge_satir_id
      join public.belge b on b.id = s.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
     where d2.id = p_dagitim_id;

    if not found then return 0; end if;

    -- Yeniden üretilebilir satırlar silinir; onaylı (3) / ödenmiş (4) durur.
    delete from public.hakedis_satir
     where dagitim_id = p_dagitim_id and durum in (1, 2);

    if coalesce(d.durum, 0) <> 2 or d.iptal_islem_id is not null then
        return 0;
    end if;

    v_belgetur := public.fn_prim_belge_turu(d.belge_satir_id, d.pay);

    -- YENİ KURAL (339): gelir belgesi yoksa prim doğmaz. Tahsilat alınmış
    --   olabilir; dönüşüm tetiği (tg_prim_donusum / tg_prim_belge_tur) bu
    --   fonksiyonu yeniden çağırdığında satır o an üretilir.
    if public.fn_prim_taslak_mi(v_belgetur) then
        return 0;
    end if;

    v_matrah := round(d.tutar / (1 + coalesce(d.kdv, 0) / 100.0), 4);
    v_kurum := d.odeyen_kurum_id;
    v_sube := d.sube_id;
    v_tarih := d.tarih;

    for r in select br.rol, br.taraf_id, br.pay_yuzde
               from public.belge_satir_rol br
              where br.belge_satir_id = d.belge_satir_id
    loop
        select * into kural
          from public.fn_prim_plan_satiri(r.rol, r.taraf_id, d.hizmet_id, d.stok_id,
                                          v_belgetur, d.pay, v_kurum, v_sube, v_tarih,
                                          d.tahsilat_turu);
        if not found then continue; end if;
        -- FATURALAMA zamanli plan tahsilattan prim URETMEZ (332).
        if kural.prim_zamani = 2 then continue; end if;

        v_tutar := case when kural.oran_tipi = 2
                        then kural.deger
                        else round(v_matrah * kural.deger / 100.0, 2) end;
        v_tutar := round(v_tutar * coalesce(r.pay_yuzde, 100) / 100.0, 2);

        if kural.alt_sinir is not null and v_tutar < kural.alt_sinir then
            v_tutar := kural.alt_sinir;
        end if;
        if kural.ust_sinir is not null and v_tutar > kural.ust_sinir then
            v_tutar := kural.ust_sinir;
        end if;
        if v_tutar <= 0 then continue; end if;

        -- Durum her zaman 2 (Kesin): buraya gelen satırın gelir belgesi var.
        insert into public.hakedis_satir
               (taraf_id, rol, dagitim_id, belge_satir_id, plan_id, plan_satir_id,
                tarih, belge_tur, pay, taban, oran_tipi, deger, pay_yuzde, tutar, durum)
        values (r.taraf_id, r.rol, p_dagitim_id, d.belge_satir_id,
                kural.plan_id, kural.satir_id, v_tarih, v_belgetur, d.pay,
                v_matrah, kural.oran_tipi, kural.deger,
                coalesce(r.pay_yuzde, 100), v_tutar, 2)
        on conflict (dagitim_id, taraf_id, rol) where dagitim_id is not null
        do update set tutar = excluded.tutar, taban = excluded.taban,
                      deger = excluded.deger, belge_tur = excluded.belge_tur,
                      plan_id = excluded.plan_id, plan_satir_id = excluded.plan_satir_id,
                      durum = excluded.durum
        where hakedis_satir.durum in (1, 2);

        v_sayac := v_sayac + 1;
    end loop;

    return v_sayac;
end $$;

comment on function public.fn_prim_uret is
  'Tahsilat dagitimindan prim uretir (339): gelir belgesi YOKSA satir '
  'uretilmez, donusumde tetikle yeniden cagrilir ve prim o an dogar.';

-- ----------------------------------------------------- mevcut taslaklar ----
-- Bugüne kadar üretilmiş taslak satırlar hak edilmiş prim değildir; kalemleri
--   gelir belgesine dönüşünce zaten yeniden üretilecekler. Silinmeden önce
--   ne silindiği rapora yazılır (kapanmış/onaylı satıra dokunulmaz).
do $$
declare v_adet integer; v_tutar numeric(19,2);
begin
    select count(*), coalesce(sum(tutar), 0) into v_adet, v_tutar
      from public.hakedis_satir where durum = 1;

    if v_adet > 0 then
        raise notice '339: taslak (durum 1) % satir / % TL siliniyor - '
                     'kalem gelir belgesine donusunce yeniden uretilecek.',
                     v_adet, v_tutar;
        delete from public.hakedis_satir where durum = 1;
    else
        raise notice '339: silinecek taslak satir yok.';
    end if;
end $$;

comment on function public.fn_prim_taslak_mi is
  'Belge turu henuz gelir belgesi degil mi (330): siparis/teklif/basvuru. '
  '339''dan beri boyle bir kalemden prim satiri HIC uretilmez.';

do $$
declare r record;
begin
    for r in select durum, count(*) adet, coalesce(sum(tutar), 0) tutar
               from public.hakedis_satir group by durum order by durum loop
        raise notice '339: durum % -> % satir / % TL', r.durum, r.adet, r.tutar;
    end loop;
    raise notice '339 tamam: prim yalniz gelir belgesi (14/15/16/17...) varken dogar.';
end $$;
