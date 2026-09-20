-- =====================================================================
--  886_lab_sonuc_gecmisi.sql
--  ONAYLARKEN ESKİ SONUÇLARA VE TEKRARLARA ERİŞİM
--  (KTS denetim maddesi L6 listesindeki L9: "Onaylama yaparken eski
--   sonuçlar ve tekrarlara sistem üzerinden kolayca erişilebiliyor mu?")
--
--  MOTOR ZATEN VARDI, ERİŞİM YOKTU. 433 sonucu yazarken delta kontrolü
--  yapıyor ve sonucun yanına ÖNCEKİ DEĞERİ, yüzde farkı ve uyarı
--  bayrağını yazıyor (`lab_sonuc.delta_onceki / delta_yuzde /
--  delta_uyari`). Ama onaylayan uzman, "bu hastanın bu tetkiki daha önce
--  kaçtı" sorusunu ancak başka bir ekrana gidip arayarak cevaplayabiliyordu
--  - denetimin sorduğu "kolayca erişim" tam olarak buydu.
--
--  ÜÇ ŞEY BİR ARADA DÖNER:
--   1. GEÇMİŞ: aynı hastanın aynı tetkikteki ONAYLI önceki sonuçları
--      (en yeniden eskiye). Onaysız sonuç geçmiş sayılmaz - uzmanın
--      kararını dayandıracağı değer, kurumun sahiplendiği değerdir.
--   2. TEKRARLAR: AYNI istemdeki aynı tetkikin öteki çalışmaları
--      (`tekrar_no`). Tekrar, geçmiş değildir: aynı numunenin ikinci
--      okumasıdır ve karşılaştırması ayrı yapılır.
--   3. DELTA: sonucun kendi satırında duran önceki değer / yüzde / uyarı.
--
--  HASTA EŞLEŞMESİ İSTEM ÜZERİNDEN: `lab_istem.taraf_id`. Sonuç satırı
--  hastayı taşımıyor; istemden okumak, aynı hastanın başka başvurularındaki
--  sonuçlarını da görmeyi sağlar - zaten istenen de bu (bir önceki
--  yatışındaki kreatinini görmek).
-- =====================================================================

create or replace function public.fn_lab_sonuc_gecmis(p_satir_id integer,
                                                      p_adet integer default 10)
returns table(
    kaynak        text,          -- 'gecmis' | 'tekrar'
    sonuc_id      bigint,
    istem_id      integer,
    istem_no      varchar,
    tarih         timestamptz,
    deger         text,
    birim         varchar,
    bayrak        varchar,
    panik         smallint,
    tekrar_no     smallint,
    cihaz         varchar,
    onay_durum    smallint
)
language sql stable as $$
    with hedef as (
        select s.id as satir_id, s.tetkik_id, i.taraf_id, i.id as istem_id
          from public.lab_istem_satir s
          join public.lab_istem i on i.id = s.istem_id
         where s.id = p_satir_id
    )
    -- 1) GECMIS: ayni hasta + ayni tetkik, BASKA istemlerden, ONAYLI.
    (select 'gecmis'::text, r.id, i2.id, i2.istem_no,
            coalesce(r.olcum_zamani, r.ekleme_tarihi),
            coalesce(nullif(r.deger_metin, ''),
                     trim(to_char(r.deger_sayisal, 'FM999999990.999999'))),
            r.birim, r.bayrak, r.panik, r.tekrar_no,
            coalesce(c.ad, ''), r.durum
       from hedef h
       join public.lab_istem_satir s2 on s2.tetkik_id = h.tetkik_id
       join public.lab_istem i2 on i2.id = s2.istem_id and i2.taraf_id = h.taraf_id
       join public.lab_sonuc r on r.istem_satir_id = s2.id
       left join public.cihaz c on c.id = r.cihaz_id
      where i2.id <> h.istem_id and r.durum >= 3
      order by coalesce(r.olcum_zamani, r.ekleme_tarihi) desc
      limit greatest(p_adet, 1))
    union all
    -- 2) TEKRARLAR: AYNI istemdeki ayni tetkikin oteki calismalari.
    --    Onayli olmayan da gelir: tekrarin amaci zaten "hangisi dogru"
    --    sorusunu uzmanin onune koymaktir.
    (select 'tekrar'::text, r.id, i2.id, i2.istem_no,
            coalesce(r.olcum_zamani, r.ekleme_tarihi),
            coalesce(nullif(r.deger_metin, ''),
                     trim(to_char(r.deger_sayisal, 'FM999999990.999999'))),
            r.birim, r.bayrak, r.panik, r.tekrar_no,
            coalesce(c.ad, ''), r.durum
       from hedef h
       join public.lab_istem_satir s2 on s2.istem_id = h.istem_id
                                     and s2.tetkik_id = h.tetkik_id
       join public.lab_istem i2 on i2.id = s2.istem_id
       join public.lab_sonuc r on r.istem_satir_id = s2.id
       left join public.cihaz c on c.id = r.cihaz_id
      where r.istem_satir_id <> h.satir_id or r.tekrar_no > 0
      order by r.tekrar_no, coalesce(r.olcum_zamani, r.ekleme_tarihi));
$$;

comment on function public.fn_lab_sonuc_gecmis(integer, integer) is
  '886: onay ekranindaki gecmis (KTS L9). kaynak = gecmis (ayni hastanin '
  'BASKA istemlerindeki ONAYLI sonuclari) | tekrar (ayni istemdeki oteki '
  'calismalar). Hasta eslesmesi lab_istem.taraf_id uzerinden.';

do $$
begin
    raise notice '886 tamam: fn_lab_sonuc_gecmis kurulu (% onayli sonuc var)',
        (select count(*) from public.lab_sonuc where durum >= 3);
end $$;
