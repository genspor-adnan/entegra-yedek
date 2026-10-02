-- =====================================================================
--  924_not_valid_kisit_dogrula.sql
--  KOŞULLU KISIT DOĞRULAMA (denetim 28.09.2026 — veri kalitesi)
--
--  `not valid` kısıt yeni/değişen satırı denetler ama eski satırların
--  kurala uyduğunu GARANTİ ETMEZ. Aşağıdaki dört kısıt eklenirken eski
--  veri riski yüzünden `not valid` bırakılmıştı (143, 482, 486); geliştirme
--  veritabanında aykırı satır SAYISI SIFIR ölçüldü.
--
--  NE YAPAR: her kısıt için ÖNCE aykırı satırı sayar. Sıfırsa
--  `validate constraint` ile kısıt geçerli hale gelir; değilse DOKUNMAZ ve
--  sayıyı bildirir. Müşteri verisi DEĞİŞTİRİLMEZ, uydurulmaz: aykırı satır
--  gerçek bilgiyle düzeltilene kadar kısıt `not valid` kalır.
--
--  KAPSAM DIŞI (bilinçli): taraf_hasta doğum tarihi / cinsiyet kısıtları
--  (480). Eski hasta kayıtlarını korumak için `not valid` bırakıldı; aykırı
--  kayıtlar ancak GERÇEK doğum tarihi/cinsiyetle tamamlanabilir.
--
--  Tekrar çalıştırılabilir: geçerli kısıt atlanır.
-- =====================================================================
do $$
declare
    r record;
    v_aykiri bigint;
begin
    for r in
        select * from (values
            ('public.stok_birim', 'ck_stok_birim_durum',
             'select count(*) from public.stok_birim where not (durum in (0, 1))'),
            ('public.hizmet', 'ck_hizmet_yas_araligi',
             'select count(*) from public.hizmet where not (yas_alt is null or yas_ust is null or yas_alt <= yas_ust)'),
            ('public.lab_tetkik', 'ck_lab_tetkik_calisma_duzeni',
             'select count(*) from public.lab_tetkik where not (calisma_duzeni between 0 and 2)'),
            ('public.lab_tetkik', 'ck_lab_tetkik_seri_tanimli',
             'select count(*) from public.lab_tetkik where not (calisma_duzeni <> 2 or (calisma_gunleri > 0 and calisma_saatleri <> ''''))')
        ) as k(tablo, kisit, sayim)
    loop
        if not exists (select 1 from pg_constraint
                        where conname = r.kisit and conrelid = to_regclass(r.tablo)
                          and not convalidated) then
            continue;   -- yok ya da zaten geçerli
        end if;

        execute r.sayim into v_aykiri;
        if v_aykiri = 0 then
            execute format('alter table %s validate constraint %I', r.tablo, r.kisit);
            raise notice '924: % gecerli yapildi', r.kisit;
        else
            raise notice '924: % DOGRULANMADI - % aykiri satir var (veri duzeltilmeden kisit acilmaz)',
                r.kisit, v_aykiri;
        end if;
    end loop;
end $$;
