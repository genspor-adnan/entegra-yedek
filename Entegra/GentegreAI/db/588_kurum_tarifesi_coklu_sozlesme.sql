-- =====================================================================
--  588_kurum_tarifesi_coklu_sozlesme.sql
--  Ödeyen kurumun TARİFESİ, poliçe seçilmemiş olsa da bulunur.
--
--  Kullanıcı: "başvuru 23, kurum ÖSS; ücret eklemede TTB/HUV ve varsa katkı
--  gelmeliydi ama özel fiyatı geldi."
--
--  Sebep: `fn_belge_varsayilan_liste` sözleşmenin fiyat listesini ancak
--  `fn_kurum_sozlesme_sec` bir sözleşme döndürürse okuyordu; o fonksiyon ise
--  kurumun TEK geçerli sözleşmesi varsa seçim yapar. Sigorta şirketinin
--  ÖSS + TSS + Karma poliçesi olduğu anda seçim boş dönüyor, adım atlanıyor
--  ve liste "carinin kendi listesi" kuralına düşüyordu - yani Özel tarife.
--  Hasta ÖSS'li ama fiyat hastanenin özel fiyatı: sessiz yanlış fatura.
--
--  İki düzeltme:
--    1) Belgede POLİÇE SEÇİLİYSE (p_sozlesme_id) o sözleşmenin listesi
--       kullanılır - zaten fonksiyonun parametresiydi, çağıran geçirmiyordu.
--    2) Poliçe seçilmemişse: kurumun geçerli sözleşmelerinin işaret ettiği
--       fiyat listesi TEK İSE o kullanılır. Hangi poliçe olduğu belirsiz
--       olabilir ama TARİFE belirsiz değildir - üç poliçe de aynı TTB/HUV
--       listesini gösteriyorsa fiyat da odur. Listeler farklıysa seçim
--       yapılmaz (eski davranış): yanlış tarifeyle fiyatlamaktansa carinin
--       listesine düşmek yeğdir, kullanıcı poliçeyi seçince düzelir.
-- =====================================================================

create or replace function public.fn_belge_varsayilan_liste(
    p_tur integer,
    p_taraf_id integer,
    p_tarih date default current_date,
    p_odeyen_kurum_id integer default null,
    p_sozlesme_id integer default null)
returns integer language sql stable as $$
    select coalesce(
        -- 1) KAMPANYA LİSTESİ: anlaşma hem baz listeyi hem indirimi tayin eder.
        (select fl.id
           from public.kampanya k
           join public.fiyat_listesi fl on fl.id = k.fiyat_listesi_id
          where k.id = public.fn_taraf_kampanya(
                           case when coalesce(p_odeyen_kurum_id, 0) > 0
                                then p_odeyen_kurum_id else p_taraf_id end,
                           p_tarih, p_sozlesme_id)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2) SÖZLEŞME TARİFE LİSTESİ (468): anlaşmada yazan liste.
        (select fl.id
           from public.kurum_sozlesme s
           join public.fiyat_listesi fl on fl.id = s.fiyat_listesi_id
          where s.id = coalesce(p_sozlesme_id,
                                public.fn_kurum_sozlesme_sec(p_odeyen_kurum_id, p_tarih))
            -- Poliçe ÖDEYEN KURUMUN olmalı (588): belgede kurum değişip
            --   sözleşme eski kalırsa başka kurumun tarifesiyle fiyatlanırdı.
            and (coalesce(p_odeyen_kurum_id, 0) = 0
                 or s.kurum_id = p_odeyen_kurum_id)
            and s.durum = 1
            and (s.baslangic is null or s.baslangic <= p_tarih)
            and (s.bitis is null or s.bitis >= p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2b) POLİÇE BELİRSİZ, TARİFE BELLİ (588): kurumun geçerli
        --     sözleşmelerinin gösterdiği liste TEK ise o kullanılır.
        (select min(fl.id)
           from public.kurum_sozlesme s
           join public.fiyat_listesi fl on fl.id = s.fiyat_listesi_id
          where coalesce(p_odeyen_kurum_id, 0) > 0
            and s.kurum_id = p_odeyen_kurum_id
            and s.durum = 1
            and (s.baslangic is null or s.baslangic <= p_tarih)
            and (s.bitis is null or s.bitis >= p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)
         having count(distinct fl.id) = 1),

        -- 3) Ödeyen kurum bir caridir: listesi cari kuralından.
        case when coalesce(p_odeyen_kurum_id, 0) > 0
             then public.fn_cari_fiyat_listesi(p_odeyen_kurum_id,
                                               public.fn_belge_yon(p_tur), p_tarih)
        end,

        -- 4) Carinin kendi listesi / yönün varsayılanı.
        public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih));
$$;
