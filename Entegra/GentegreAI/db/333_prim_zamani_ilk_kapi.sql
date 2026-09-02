-- 333: PRİM ZAMANI "İLK KAPI" - planın geri kalanı bu karara göre okunur.
--
-- Kullanıcı: "tüm prim tanımlarında ilk kapı faturalama/tahsilat hangisinin
-- baz alınacağı olmalıdır."
--
-- Karar kartın en başında ve zorunlu (katalog tarafında). Veritabanı
-- tarafında da tutarlılık gerekiyor: FATURALAMA zamanlı planda "tahsilat
-- türü" kriteri ANLAMSIZDIR - prim doğduğunda para henüz gelmemiştir,
-- hangi araçla tahsil edileceği bilinmez. Böyle bir satır sessizce hiç
-- eşleşmez ve kullanıcı "oran neden uygulanmadı" diye arar.
--
-- Kriter sessizce TEMİZLENMEZ, iş kuralıyla ENGELLENİR: temizlemek, planı
-- yanlışlıkla faturalamaya çevirip geri alan kullanıcının "nakit %12 / POS
-- %10" satırlarını sessizce yok ederdi.

create or replace function public.tg_prim_satir_zaman()
returns trigger language plpgsql as $$
declare v_zaman smallint;
begin
    select coalesce(prim_zamani, 1) into v_zaman
      from public.prim_plani where id = new.plan_id;

    if v_zaman = 2 and coalesce(new.tahsilat_turu, 0) <> 0 then
        raise exception
            'Faturalama zamanlı planda tahsilat türü kriteri kullanılamaz: prim doğduğunda para henüz tahsil edilmemiştir.'
            using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tr_prim_satir_zaman on public.prim_plani_satir;
create trigger tr_prim_satir_zaman
  before insert or update on public.prim_plani_satir
  for each row execute function public.tg_prim_satir_zaman();

comment on function public.tg_prim_satir_zaman is
  'Faturalama zamanli planda tahsilat turu kriterini temizler (333).';

-- Plan zamanı sonradan değişirse: faturalamaya geçiş kriterli satır varken
--   ENGELLENİR; geçiş olduğunda da açık primler yeniden üretilir - üretim
--   yolu (tahsilat / faturalama) yer değiştirdi.
create or replace function public.tg_prim_plani_zaman()
returns trigger language plpgsql as $$
declare r record;
begin
    if new.prim_zamani is not distinct from old.prim_zamani then return null; end if;

    if new.prim_zamani = 2
       and exists (select 1 from public.prim_plani_satir
                    where plan_id = new.id and coalesce(tahsilat_turu, 0) <> 0) then
        raise exception
            'Bu planda tahsilat türüne bağlı satır var; faturalama zamanına geçmeden önce o kriterleri kaldırın.'
            using errcode = 'GK422';
    end if;

    -- Bu plandan dogmus ACIK primler yeniden hesaplanir: uretim yolu
    --   degisti, eski satirlar oteki yolda yeniden uretilecek.
    for r in select distinct hs.belge_satir_id
               from public.hakedis_satir hs
              where hs.plan_id = new.id and hs.durum in (1, 2)
    loop
        perform public.fn_prim_uret_belge(r.belge_satir_id);
        perform public.fn_prim_uret(d.id)
           from public.kasa_islem_dagitim d
          where d.belge_satir_id = r.belge_satir_id;
    end loop;
    return null;
end $$;

drop trigger if exists tr_prim_plani_zaman on public.prim_plani;
create trigger tr_prim_plani_zaman
  after update of prim_zamani on public.prim_plani
  for each row execute function public.tg_prim_plani_zaman();

-- Mevcut veri: bu ikisi bir arada olan plan varsa ZAMANI tahsilata cekilir
--   (kriter korunur; kullanici isterse kriterleri kaldirip zamani degistirir).
update public.prim_plani p
   set prim_zamani = 1
 where coalesce(p.prim_zamani, 1) = 2
   and exists (select 1 from public.prim_plani_satir s
                where s.plan_id = p.id and coalesce(s.tahsilat_turu, 0) <> 0);
