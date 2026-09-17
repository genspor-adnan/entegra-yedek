-- ============================================================================
--  Gentegre AI — İŞ EMRİ NUMARASI (914) ŞABLONU
--  777_is_emri_numara_sablonu.sql
--
--  Kullanıcı: "914 numara şablonunu da tanımla".
--
--  731 tür kodunu tanımlamıştı ("İş Emri No", tedarik grubunda) ama ŞABLON
--  satırı yazmamıştı: ayarsız tür boş numara üretir, iş emri listede `#id`
--  görünür. 773/776'da açılan servis iş emirleri de numarasız doğuyordu.
--
--  ============ TEK DİZİ, TEK ÖN EK ====================================
--  `demirbas_is_emri` HEM kurumun kendi cihazının iş emrini (biyomedikal)
--  HEM müşteri cihazının servis iş emrini tutuyor (773 kararı: tek iş emri,
--  iki sahiplik). Bu yüzden numara da TEKTİR.
--
--  Mockup iç işte `IE-`, dış işte `SE-` gösteriyordu; iki ön ek iki sayaç
--  demek olurdu ve aynı tabloda iki numara dizisi, "IE-84 ile SE-84 aynı
--  kayıt mı" sorusunu doğururdu. Ayrımı `sahiplik` kolonu zaten taşıyor ve
--  listede "Tür" sütununda yazıyor. Ön ek nötr: **IE-**.
--
--  ============ GEÇMİŞ KAYITLARA NUMARA VERİLMİYOR =====================
--  767'deki kararla aynı: numara kaydın RESMÎLEŞTİĞİ anda kesilir. Var olan
--  numarasız iş emirlerine toplu numara dağıtmak, hiç kesilmemiş numarayı
--  sonradan uydurmak olurdu - iki kurulumda aynı iş emri farklı numara alır.
--  (Dev'de numarasız kayıt yok; gerçek kurulumda eskiler `#id` görünmeye
--  devam eder.)
--
--  Ön ek yıl İÇERMİYOR: sayaç sürekli artar, "geçen yılki 84 numaralı iş
--  emri" cümlesi ömür boyu tek kaydı gösterir. Yıllı isteyen kurum Genel
--  Ayarlar › Belge No › Tedarik Belgeleri'nden değiştirir.
--
--  ============ ÖTEKİ TEDARİK TÜRLERİ AYARSIZ KALIYOR ==================
--  910 eczane hazırlama · 911 ilaç imha · 912 demirbaş · 913 kalibrasyon ·
--  915 satınalma talep · 916 teklif · 917 mal kabul hâlâ şablonsuz. Onları
--  da doldurmak, kurumun kullanmadığı belgelere numara dizisi açmak olurdu;
--  istendiğinde ekrandan tanımlanır.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no,
                                   sube_id, durum, elle_girilir, aciklama)
select 914, current_date, 'IE-', '000001', 0, 1, 0,
       'Is emri numarasi (777) - ic ve dis is emri TEK diziden'
 where not exists (select 1 from public.numara_sablonu where tur = 914);

do $$
declare v_numarasiz int;
begin
    select count(*) into v_numarasiz from public.demirbas_is_emri
     where coalesce(is_emri_no, '') = '';
    raise notice '777 tamam: 914 sablonu (IE-) kuruldu. Numarasiz mevcut is '
                 'emri: % (bilerek dokunulmadi).', v_numarasiz;
end $$;
