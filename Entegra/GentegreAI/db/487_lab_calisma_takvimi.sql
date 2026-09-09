-- =====================================================================
-- 487 - ÇALIŞMA TAKVİMİ ÖNİZLEMESİ
--
-- Kullanıcı: "takvimi ve özet kutuları da ekle."
--
-- Kart, çalışma düzenini girerken sonucun ne zaman çıkacağını GÖSTERMELİ -
-- ama kullanıcı henüz KAYDETMEDİ. 486'daki fonksiyon tetkik id'siyle çalışıyor,
-- yani yalnız kayıtlı değeri okuyabiliyordu: ekranda "Cuma 09:00" yazarken
-- önizleme hâlâ eski düzeni gösterirdi.
--
-- Kural PARAMETRELİ hâle getirildi. Tek gövde, iki kapı:
--   fn_lab_calisma_sonuc_zamani(...)  - verilen düzenle hesaplar (önizleme)
--   fn_lab_tetkik_sonuc_zamani(id...) - tetkiğin kayıtlı düzeniyle çağırır
-- Böylece ekrandaki önizleme ile kaydedilmiş gerçek AYNI kuraldan geçer;
-- iki ayrı hesap iki farklı saat söylerdi.
-- =====================================================================

create or replace function public.fn_lab_calisma_sonuc_zamani(
    p_duzen         smallint,
    p_gunler        smallint,
    p_saatler       varchar,
    p_kabul_son_dk  integer,
    p_tat_dk        integer,
    p_acil_tat_dk   integer,
    p_acil_beklemez smallint,
    p_kabul         timestamp default now()::timestamp,
    p_acil          smallint  default 0)
returns timestamp
language plpgsql immutable as $$
declare
    v_tat  integer;
    v_gun  date;
    v_bit  integer;
    v_aday timestamp;
    i      integer;
    s      text;
begin
    v_tat := case when p_acil = 1 and coalesce(p_acil_tat_dk, 0) > 0
                  then p_acil_tat_dk else coalesce(p_tat_dk, 0) end;

    -- ACİL düzeni atlar: numune gelir gelmez çalışılır.
    if p_acil = 1 and coalesce(p_acil_beklemez, 1) = 1 then
        return p_kabul + make_interval(mins => v_tat);
    end if;

    if coalesce(p_duzen, 0) = 0 then                  -- sürekli
        return p_kabul + make_interval(mins => v_tat);
    end if;

    if p_duzen = 1 then                               -- mesai içi (08:00-17:00)
        v_aday := p_kabul;
        if v_aday::time > time '17:00' then
            v_aday := (v_aday::date + 1) + time '08:00';
        elsif v_aday::time < time '08:00' then
            v_aday := v_aday::date + time '08:00';
        end if;
        return v_aday + make_interval(mins => v_tat);
    end if;

    -- SERİ: kabulden sonraki ilk (çalışma günü, çalışma saati). En çok 14 gün
    --   ileri bakılır - bulunamıyorsa tanım eksiktir ve null dönmek
    --   "bilmiyorum" demenin dürüst yoludur.
    for i in 0..13 loop
        v_gun := (p_kabul::date) + i;
        v_bit := (1 << (extract(isodow from v_gun)::int - 1));
        if (coalesce(p_gunler, 0) & v_bit) = 0 then continue; end if;

        foreach s in array string_to_array(coalesce(p_saatler, ''), ',') loop
            if btrim(s) = '' then continue; end if;
            v_aday := v_gun + btrim(s)::time;
            if v_aday - make_interval(mins => coalesce(p_kabul_son_dk, 0)) >= p_kabul then
                return v_aday + make_interval(mins => v_tat);
            end if;
        end loop;
    end loop;

    return null;
end $$;

comment on function public.fn_lab_calisma_sonuc_zamani(
    smallint, smallint, varchar, integer, integer, integer, smallint,
    timestamp, smallint) is
  'Verilen çalışma düzeniyle sonuç zamanı (487) - kart önizlemesi kaydetmeden bunu çağırır.';

-- Tetkiğin KAYITLI düzeniyle: gövde tek, kapı iki.
create or replace function public.fn_lab_tetkik_sonuc_zamani(
    p_tetkik_id integer,
    p_kabul     timestamp default now()::timestamp,
    p_acil      smallint  default 0)
returns timestamp
language sql stable as $$
    select public.fn_lab_calisma_sonuc_zamani(
               t.calisma_duzeni, t.calisma_gunleri, t.calisma_saatleri,
               t.kabul_son_dk, t.hedef_tat_dk, t.acil_tat_dk, t.acil_beklemez,
               p_kabul, p_acil)
      from public.lab_tetkik t where t.id = p_tetkik_id;
$$;

comment on function public.fn_lab_tetkik_sonuc_zamani(integer, timestamp, smallint) is
  'Tetkiğin sonucu ne zaman çıkar (487): kayıtlı düzenle fn_lab_calisma_sonuc_zamani.';

do $$
begin
    raise notice '487 tamam: calisma takvimi onizlemesi (parametreli kural)';
end $$;
