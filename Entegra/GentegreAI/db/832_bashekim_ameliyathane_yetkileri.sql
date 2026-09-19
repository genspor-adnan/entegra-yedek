-- ============================================================================
--  Gentegre AI — BAŞHEKİM / BAŞHEMŞİRE: EKSİK AMELİYATHANE YETKİLERİ
--  832_bashekim_ameliyathane_yetkileri.sql
--
--  Roller kurulduktan sonra tarayıcıda denendi: "Ameliyat Talepleri" ekranı
--  başhekimde açılmadı - şablonda `ameliyathane.talep` ve
--  `ameliyathane.salon` yoktu. Şablon düzeltildi; kurulu roller EZİLMEDİĞİ
--  için (712 kuralı) eksik yetkiler burada eklenir.
--
--  831 ile aynı desen: yalnız EKLER, hiçbir şey silmez, rol yoksa atlar.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_esleme text[][] := array[
        -- Başhekim: talebi görür/açar, salonu görür, ameliyatı iptal edebilir.
        ['bashekim', 'ameliyathane.talep', 'Y'],
        ['bashekim', 'ameliyathane.salon', 'T'],
        ['bashekim', 'ameliyathane.iptal', 'A'],
        ['bashekim_yardimcisi', 'ameliyathane.talep', 'Y'],
        ['bashekim_yardimcisi', 'ameliyathane.salon', 'T'],
        -- Başhemşire: salon çizelgesi hemşireliğin işi; talebi görür.
        ['bashemsire', 'ameliyathane.salon', 'Y'],
        ['bashemsire', 'ameliyathane.talep', 'T']
    ];
    v_satir text[];
    v_eklenen integer := 0;
    v_sayi integer;
begin
    foreach v_satir slice 1 in array v_esleme loop
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
        select r.id, y.id, 1,
               case when v_satir[3] = 'Y' then 1 else 0 end,
               case when v_satir[3] = 'Y' then 1 else 0 end,
               0
          from public.rol r
          join public.yetki y on y.kod = v_satir[2]
         where r.kod = v_satir[1]
           and not exists (select 1 from public.rol_yetki x
                            where x.rol_id = r.id and x.yetki_id = y.id);
        get diagnostics v_sayi = row_count;
        v_eklenen := v_eklenen + v_sayi;
    end loop;
    raise notice '832 tamam: % ameliyathane yetkisi eklendi.', v_eklenen;
end $$;
