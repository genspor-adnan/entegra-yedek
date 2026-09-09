-- =====================================================================
--  492_prim_dagilim_kovalari.sql
--  fn_prim_uret_belge DAGILIM KOVALARINDAN okur.
--
--  Hata: 478 `belge_satir.hasta_tutar / kurum_tutar` kolonlarini dusurdu,
--  ama prim uretimi (332'den kalma fn_prim_uret_belge) hala onlari
--  okuyordu. Sonuc: dagilimi olan bir basvuru satirini FATURAYA /
--  TAHAKKUKA DONUSTURMEK "column bs.hasta_tutar does not exist" ile
--  patliyordu - yani anlasmali kurum sureci hic tamamlanamiyordu.
--
--  Cozum: paylar artik INCE KOVA kodlaridir (470): 1 hasta provizyon ·
--  2 SGK · 3 sigorta/anlasmali kurum · 4 hasta ek katkisi. 5 (SGK katilim
--  payi) prim URETMEZ - ciro disi emanettir. Zaten fn_prim_gelir_belgesi
--  ve fn_prim_plan_satiri bu ince kodlari fn_dagilim_pay_grubu ile kaba
--  gruba ceviriyor; tek eksik uretim tarafiydi.
--
--  Dagilim satiri OLMAYAN kalem (ERP satisi) eskisi gibi tek prim satiri
--  uretir (pay 0, matrah = satir tutari).
-- =====================================================================

create or replace function public.fn_prim_uret_belge(p_belge_satir_id integer)
returns integer
language plpgsql
as $function$
declare
  s          record;
  gb         record;
  r          record;
  kural      record;
  v_pay      smallint;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_sayac    integer := 0;
  v_paylar   smallint[];
begin
    select bs.id, bs.hizmet_id, bs.stok_id, bs.kdv, bs.tutar,
           -- DAGILIM KOVALARI (470/492): eski hasta_tutar/kurum_tutar
           --   kolonlari 478'de dustu.
           coalesce(d.hasta_provizyon, 0) as hasta_provizyon,
           coalesce(d.hasta_ek_katki, 0)  as hasta_ek_katki,
           coalesce(d.sgk, 0)             as sgk,
           coalesce(d.oss, 0)             as oss,
           d.belge_satir_id is not null   as dagilim_var,
           b.sube_id, b.durum as belge_durum, bb.odeyen_kurum_id
      into s
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
      left join public.belge_satir_dagilim d on d.belge_satir_id = bs.id
     where bs.id = p_belge_satir_id;

    if not found then return 0; end if;

    -- Yeniden uretilebilir FATURALAMA satirlarini temizle (onayli/odenmise
    --   dokunulmaz; tahsilat yolu satirlari dagitim_id ile ayrilir).
    delete from public.hakedis_satir
     where belge_satir_id = p_belge_satir_id and dagitim_id is null
       and durum in (1, 2);

    -- Dagilimli satirda HER DOLU KOVA ayri prim uretir; dagilim yoksa tek
    --   satir (pay 0). Katilim payi (5) listede YOK: ciro disi emanet.
    if s.dagilim_var then
        v_paylar := array[1, 2, 3, 4]::smallint[];
    else
        v_paylar := array[0]::smallint[];
    end if;

    foreach v_pay in array v_paylar
    loop
        v_matrah := case v_pay when 1 then s.hasta_provizyon
                               when 2 then s.sgk
                               when 3 then s.oss
                               when 4 then s.hasta_ek_katki
                               else coalesce(s.tutar, 0) end;
        if v_matrah <= 0 then continue; end if;

        select * into gb from public.fn_prim_gelir_belgesi(p_belge_satir_id, v_pay);
        -- Gelir belgesi YOKSA (kalem hala siparis/basvuru) faturalama primi
        --   dogmaz - "faturalandi" sayilmaz.
        if not found or public.fn_prim_taslak_mi(gb.tur) then continue; end if;

        for r in select br.rol, br.taraf_id, br.pay_yuzde
                   from public.belge_satir_rol br
                  where br.belge_satir_id = p_belge_satir_id
        loop
            select * into kural
              from public.fn_prim_plan_satiri(r.rol, r.taraf_id, s.hizmet_id, s.stok_id,
                                              gb.tur, v_pay, s.odeyen_kurum_id,
                                              s.sube_id, gb.tarih, 0::smallint);
            if not found then continue; end if;
            -- TAHSILAT zamanli plan faturadan prim uretmez (332).
            if coalesce(kural.prim_zamani, 1) <> 2 then continue; end if;

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

            insert into public.hakedis_satir
                   (taraf_id, rol, dagitim_id, belge_satir_id, plan_id, plan_satir_id,
                    tarih, belge_tur, pay, taban, oran_tipi, deger, pay_yuzde,
                    tutar, durum)
            values (r.taraf_id, r.rol, null, p_belge_satir_id,
                    kural.plan_id, kural.satir_id, gb.tarih, gb.tur, v_pay,
                    v_matrah, kural.oran_tipi, kural.deger,
                    coalesce(r.pay_yuzde, 100), v_tutar, 2)
            on conflict (belge_satir_id, taraf_id, rol, pay) where dagitim_id is null
            do update set tutar = excluded.tutar, taban = excluded.taban,
                          deger = excluded.deger, belge_tur = excluded.belge_tur,
                          tarih = excluded.tarih,
                          plan_id = excluded.plan_id,
                          plan_satir_id = excluded.plan_satir_id,
                          oran_tipi = excluded.oran_tipi,
                          pay_yuzde = excluded.pay_yuzde,
                          durum = 2;
            v_sayac := v_sayac + 1;
        end loop;
    end loop;

    return v_sayac;
end $function$;

comment on function public.fn_prim_uret_belge(integer) is
  'Faturalama primi (332/492): dagilim kovalari (1 hasta provizyon · 2 SGK · '
  '3 sigorta · 4 hasta ek katkisi) basina ayri hakedis satiri; katilim payi '
  'prim uretmez. Dagilimsiz satirda tek satir (pay 0).';
