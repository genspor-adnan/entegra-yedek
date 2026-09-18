-- =====================================================================
-- 802 - ATAMA NEDENI: OTOMATIK MI, ELLE MI
--
-- 797 atama izi nedenini "ilk atama ise 2 (elle), degisiklikse 3 (yeniden
-- atama)" diye yaziyordu. 801'de otomatik dagitim gelince bu ELLE OLMAYAN
-- atamayi da "Elle" diye kaydeder oldu: kartin kod listesinde duran
-- "1 Otomatik (kural)" degerini yazan KIMSE YOKTU.
--
-- Ayni hata 799'da da vardi (salt okunur damgayi yazan yoktu). Ders ayni:
-- ekranin gosterdigi bir deger, onu yazan bir yol olmadan tanimlanmaz.
--
-- COZUM: neden ISLEM BOYUNCA gecerli bir ayardan okunur
-- (`set_config('telerad.atama_nedeni', '1', true)`). Ayar yoksa eski davranis
-- aynen surer - elle atama yapan ekranlarin degismesi gerekmez.
-- =====================================================================

create or replace function public.tg_telerad_atama_izi()
returns trigger
language plpgsql
as $function$
declare
    v_neden smallint;
begin
    if new.atanan_radyolog_id is distinct from old.atanan_radyolog_id then
        -- Onceki atamayi kapat.
        update public.telerad_atama
           set birakma_zamani = now()
         where istek_id = new.id and birakma_zamani is null;

        if new.atanan_radyolog_id is not null then
            -- ISLEM AYARI: otomatik dagitim kendini boyle bildirir. Ayar
            --   yoksa (elle atama) eski kural: ilk atama 2, sonraki 3.
            v_neden := nullif(current_setting('telerad.atama_nedeni', true), '')::smallint;
            if v_neden is null then
                v_neden := case when old.atanan_radyolog_id is null then 2 else 3 end;
            end if;

            insert into public.telerad_atama (istek_id, radyolog_id, atayan_id, neden)
            values (new.id, new.atanan_radyolog_id, nullif(new.degistiren, 0), v_neden);
        end if;
    end if;
    return new;
end $function$;

comment on function public.tg_telerad_atama_izi() is
  '797/802: atama degisince gecmis KENDILIGINDEN yazilir. Neden islem ayari '
  'telerad.atama_nedeni ile bildirilir (1 otomatik); ayar yoksa elle atama '
  'kabul edilir (2 ilk atama, 3 yeniden atama).';
