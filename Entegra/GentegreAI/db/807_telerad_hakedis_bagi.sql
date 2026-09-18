-- =====================================================================
-- 807 - TELERADYOLOJI HAKEDIS BAGI: RAPORLAYAN PAYI
--
-- Kullanici: *"hakediş bağıyla devam et"*. Tasarim (797 adim 9): *"Onayli
-- rapor -> rol Raporlayan -> Prim modulu"*.
--
-- 803'te donem faturasi uretiliyordu ama satirlarina KIMSE yazilmiyordu:
-- `belge_satir_rol` bos kaldigi icin isi okuyan radyolog hicbir prim
-- kazanmiyordu. Radyolojide bu bag 326'da kurulmustu (istemden rol turetme);
-- teleradyolojide eksikti.
--
-- YENI PRIM MOTORU YAZILMIYOR: rol yazilir, gerisini mevcut hat yapar
-- (`fn_prim_uret_belge` - faturalama zamanli planlar, `fn_prim_uret` -
-- tahsilat zamanli). Teleradyolojiye ozel bir hakedis hesabi, ayni parayi iki
-- yerden hesaplamak demekti.
--
-- PAY DAGILIMI ADEDE GORE: bir fatura satiri ayni tetkikten ONLARCA isi
-- toplar (adet sutunu) ve bunlari FARKLI radyologlar okumus olabilir. Satiri
-- radyologa gore bolmek musteriye anlamsiz satirlar gosterirdi; bunun yerine
-- `belge_satir_rol.pay_yuzde` kullaniliyor - "iki cerrah %50/%50" kurali
-- zaten bunun icin var.
--
-- ATANMAMIS IS PAYI KIMSEYE YAZILMAZ: payda satirdaki TUM isler oldugu icin
-- radyologu bos kalan isin payi bosta kalir. Kalan payi okuyanlara dagitmak,
-- yapilmamis is icin prim odemek olurdu.
-- =====================================================================

-- ISTEK HANGI FATURA SATIRINDA: rol dagilimi bunu bilmeden hesaplanamaz.
--   Sadece `fatura_belge_id` varken hangi isin hangi satiri besledigi
--   tahminle (hizmet + ucret eslestirmesi) bulunurdu - tahmin para
--   dagitiminda kullanilacak bir sey degil.
alter table public.telerad_istek
    add column if not exists fatura_satir_id integer references public.belge_satir(id);

comment on column public.telerad_istek.fatura_satir_id is
  '807: istegin girdigi fatura SATIRI - raporlayan payi buradan dagitilir.';

create index if not exists ix_telerad_istek_fatura_satir
    on public.telerad_istek (fatura_satir_id) where fatura_satir_id is not null;

-- ------------------------------------------------- raporlayan payi ----
create or replace function public.fn_telerad_fatura_rol(p_belge_id integer)
returns integer
language plpgsql
as $function$
declare
    v_satir     record;
    v_pay       record;
    v_sayac     integer := 0;
    v_hedef     numeric(7,2);   -- satirda dagitilacak TOPLAM pay
    v_dagitilan numeric(7,2);
    v_yuzde     numeric(7,2);
begin
    for v_satir in
        select bs.id,
               count(*)                                                   as is_sayisi,
               -- "Okunan" = PAYI YAZILABILEN is: atanan var ve ic personel.
               count(*) filter (
                   where i.atanan_radyolog_id is not null
                     and not exists (select 1 from public.taraf_personel p
                                      where p.id = i.atanan_radyolog_id
                                        and coalesce(p.dis_hekim, 0) = 1))  as okunan,
               count(distinct i.atanan_radyolog_id) filter (
                   where not exists (select 1 from public.taraf_personel p
                                      where p.id = i.atanan_radyolog_id
                                        and coalesce(p.dis_hekim, 0) = 1))  as radyolog_sayisi
          from public.belge_satir bs
          join public.telerad_istek i on i.fatura_satir_id = bs.id
         where bs.belge_id = p_belge_id
         group by bs.id
    loop
        -- ELLE GIRILMIS ROL DOKUNULMAZ (326 deseni): kullanici bilerek
        --   duzeltmis olabilir. Turetilmis (kaynak 2) satirlar tazelenir.
        if exists (select 1 from public.belge_satir_rol e
                    where e.belge_satir_id = v_satir.id and e.rol = 5 and e.kaynak = 1)
        then
            continue;
        end if;

        delete from public.belge_satir_rol bsr
         where bsr.belge_satir_id = v_satir.id and bsr.rol = 5 and bsr.kaynak = 2;

        -- ATANMAMIS ISIN PAYI BOSTA KALIR: payda satirdaki TUM isler.
        --   Kalani okuyanlara dagitmak, yapilmamis is icin prim odemekti.
        v_hedef := round(100.0 * v_satir.okunan / nullif(v_satir.is_sayisi, 0), 2);
        v_dagitilan := 0;

        for v_pay in
            select i.atanan_radyolog_id as radyolog,
                   count(*)             as adet,
                   row_number() over (order by count(*) desc, i.atanan_radyolog_id) as sira
              from public.telerad_istek i
             where i.fatura_satir_id = v_satir.id
               and i.atanan_radyolog_id is not null
               -- DIS HEKIM YALNIZ "GONDEREN" ROLUNDE PRIM ALABILIR (361):
               --   kural o gun yazilirken dis hekim hasta GONDEREN taraftı;
               --   teleradyolojide ISI YAPAN da dis olabiliyor. Kurali burada
               --   delmek yerine dis radyolog ATLANIYOR ve fatura ucu bunu
               --   uyari olarak bildiriyor - sessizce baskasina yazmak ya da
               --   kurali tek modul icin esnetmek, parayi yanlis yere
               --   gondermenin iki ayri yolu olurdu.
               and not exists (select 1 from public.taraf_personel p
                                where p.id = i.atanan_radyolog_id
                                  and coalesce(p.dis_hekim, 0) = 1)
             group by i.atanan_radyolog_id
             order by count(*) desc, i.atanan_radyolog_id
        loop
            if v_pay.sira = v_satir.radyolog_sayisi then
                -- SON PAY ARTIGI ALIR: uc kisiye bolunen satirda
                --   33.33 x 3 = 99.99 kalirdi; kayip kurus birine yazilmali.
                v_yuzde := v_hedef - v_dagitilan;
            else
                v_yuzde := round(100.0 * v_pay.adet / nullif(v_satir.is_sayisi, 0), 2);
            end if;

            insert into public.belge_satir_rol
                   (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak)
            values (v_satir.id, 5, v_pay.radyolog, v_yuzde, 2)
            on conflict (belge_satir_id, rol, taraf_id)
            do update set pay_yuzde = excluded.pay_yuzde;

            v_dagitilan := v_dagitilan + v_yuzde;
            v_sayac := v_sayac + 1;
        end loop;

        -- ROL YAZILDI, PRIMI MEVCUT HAT URETIR: faturalama zamanli planlar
        --   icin belge yolu. Tahsilat zamanli planlar tahsilat dagitiminda
        --   (fn_prim_uret) zaten doguyor. Teleradyolojiye ozel bir hakedis
        --   hesabi, ayni parayi iki yerden hesaplamak olurdu.
        perform public.fn_prim_uret_belge(v_satir.id);
    end loop;

    return v_sayac;
end $function$;

comment on function public.fn_telerad_fatura_rol(integer) is
  '807: teleradyoloji donem faturasinin satirlarina RAPORLAYAN (rol 5) payini '
  'adede gore dagitir ve primi uretir. Elle yazilmis rolu ezmez.';
