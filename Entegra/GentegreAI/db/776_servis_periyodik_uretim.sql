-- ============================================================================
--  Gentegre AI — SÖZLEŞMEDEN PERİYODİK İŞ EMRİ ÜRETİMİ
--  776_servis_periyodik_uretim.sql
--
--  Kullanıcı: "periyodik iş emri üretimini de yap".
--
--  ============ HATIRLATMA DEĞİL İŞ EMRİ ===============================
--  Sözleşmedeki "3 ayda bir bakım" bir takvim notu değil, TAAHHÜTTÜR.
--  Hatırlatma olarak bırakmak, yapılmayan bakımın hiç iz bırakmaması
--  demekti - fatura kesilmeye devam ederken. İş emri olarak doğunca:
--    · planlanmazsa "gecikmiş" olur ve listede görünür,
--    · yapılırsa maliyeti ve süresi ölçülür (sözleşme kârlılığı),
--    · yapılmazsa sözleşme yükümlülüğünün ihlali KAYITTA kalır.
--
--  ============ İKİ KEZ ÜRETMEZ ========================================
--  İş günde bir çalışır ve her çalıştığında aynı dönem için satır yazmaya
--  çalışır. Benzersizlik `planlanan` tarihiyle kuruluyor: aynı sözleşme +
--  aynı planlanan gün için ikinci bir periyodik iş emri açılmaz. Sayaç
--  kolonu (son_uretim) tutmak, elle silinen bir iş emrinden sonra sıranın
--  kaymasına yol açardı - var olan iş emirleri TEK doğruluk kaynağı.
--
--  ============ UFUK: 30 GÜN ===========================================
--  İş emri, bakım tarihinden 30 gün ÖNCE doğar. Bugün doğsaydı planlamaya
--  vakit kalmazdı; üç ay önce doğsaydı liste, aylar sonrasının işleriyle
--  dolar ve "açık iş" sayısı anlamını yitirirdi.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------- 1
--  ÜRETİCİ
--
--  Dönen değer: (uretilen, atlanan) - iş günlüğüne ne olduğu yazılsın.
create or replace function public.fn_servis_periyodik_uret(
        p_ufuk_gun integer default 30)
returns table (uretilen integer, atlanan integer)
language plpgsql as $$
declare
    r          record;
    v_sonraki  date;
    v_uretilen int := 0;
    v_atlanan  int := 0;
begin
    for r in
        select s.id, s.taraf_id, s.sube_id, s.periyot_ay, s.baslangic, s.bitis,
               s.kapsam,
               -- SON PERİYODİK İŞ: sıra ondan devam eder. Hiç yoksa sözleşme
               --   başlangıcı taban alınır.
               (select max(e.planlanan)
                  from public.demirbas_is_emri e
                 where e.sozlesme_id = s.id and e.tur = 1
                   and e.planlanan is not null) as son_plan
          from public.servis_sozlesme s
         where s.durum = 1 and s.periyot_ay > 0
           and current_date between s.baslangic and s.bitis
    loop
        v_sonraki := coalesce(r.son_plan, r.baslangic)
                   + make_interval(months => r.periyot_ay);

        -- GEÇMİŞTE KALMIŞ DÖNEMLER TOPLU AÇILMAZ: sözleşme yeni bağlandığında
        --   ya da iş uzun süre çalışmadığında, geriye dönük on iş emri açmak
        --   yapılmamış bakımları yapılacakmış gibi gösterirdi. En fazla BİR
        --   dönem açılır; geçmiş dönemler zaten kaçırılmıştır ve o bilgi
        --   sözleşmenin SLA/bakım raporunda durur.
        if v_sonraki < current_date - interval '1 day' * p_ufuk_gun then
            v_sonraki := current_date;
        end if;

        if v_sonraki > current_date + interval '1 day' * p_ufuk_gun then
            v_atlanan := v_atlanan + 1;
            continue;
        end if;
        if v_sonraki > r.bitis then          -- sözleşme bitiyor
            v_atlanan := v_atlanan + 1;
            continue;
        end if;

        -- AYNI GÜN İÇİN İKİNCİ SATIR YOK.
        if exists (select 1 from public.demirbas_is_emri e
                    where e.sozlesme_id = r.id and e.tur = 1
                      and e.planlanan = v_sonraki) then
            v_atlanan := v_atlanan + 1;
            continue;
        end if;

        insert into public.demirbas_is_emri
               (sube_id, sahiplik, musteri_taraf_id, sozlesme_id, kapsam_tur,
                tur, oncelik, durum, planlanan, ariza_metni, aciklama, ekleyen,
                is_emri_no)
        values (r.sube_id, 2, r.taraf_id, r.id,
                -- KAPSAM SÖZLEŞME: periyodik bakım ücretlendirilmez, sözleşme
                --   kârlılığına yazılır. Tutar yine hesaplanır (773 kuralı).
                2, 1, 4, 0, v_sonraki,
                'Periyodik bakım (sözleşme · ' || r.periyot_ay || ' ayda bir)',
                'Sözleşmeden otomatik üretildi (776).', 0,
                public.fn_numara_kimlik_uret(914, r.sube_id,
                                             'demirbas_is_emri', 'is_emri_no'));
        v_uretilen := v_uretilen + 1;
    end loop;

    uretilen := v_uretilen;
    atlanan  := v_atlanan;
    return next;
end $$;

comment on function public.fn_servis_periyodik_uret is
  '776: yururlukteki sozlesmelerden periyodik bakim IS EMRI uretir (hatirlatma '
  'degil). Ayni sozlesme + ayni planlanan gun icin ikinci satir acilmaz; '
  'gecmis donemler toplu acilmaz - en fazla bir donem.';

-- ---------------------------------------------------------------------- 2
--  ZAMANLI İŞ
--
--  Günde bir, sabah 05:10. Onay hatırlatması 09:30'da çalışıyor; bakım
--  üretimi ondan ÖNCE olsun ki günün listesi açılmadan hazır olsun.
insert into public.zamanli_is (kod, ad, aktif, periyot, gun, saat, dakika)
select 'servis.periyodik', 'Sözleşmeden periyodik bakım iş emri', 1, 1, 1, 5, 10
 where not exists (select 1 from public.zamanli_is where kod = 'servis.periyodik');

do $$
declare v_sozlesme int;
begin
    select count(*) into v_sozlesme from public.servis_sozlesme
     where durum = 1 and periyot_ay > 0;
    raise notice '776 tamam: periyodik uretim kuruldu. Periyodu tanimli '
                 'yururlukteki sozlesme: %.', v_sozlesme;
end $$;
