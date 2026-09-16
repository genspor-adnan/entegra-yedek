-- =====================================================================
--  732_kritik_stok_talep.sql
--  KRİTİK STOK → OTOMATİK SATINALMA TALEBİ.
--
--  `fn_kritik_stok_talep` kritik seviyeye düşmüş stokları tarar ve DEPO
--  BAŞINA bir satınalma talebi (kaynak = 2) açar. Saatlik zamanlı iş
--  (`satinalma.kritik_stok`) çalıştırır.
--
--  ============================ NEDEN SATIR TETİĞİ DEĞİL =================
--  İlk akla gelen `stok_durum` üzerinde bir AFTER UPDATE tetiğiydi. Üç
--  sebeple öyle yapılmadı:
--
--  1) STOK HAREKETİ SATINALMA YÜZÜNDEN BAŞARISIZ OLAMAZ. Tetik belge kayıt
--     işleminin İÇİNDE çalışırdı; talep açılamadığı anda (departman
--     tanımsız, numara şablonu bozuk, yetki yok) hastaya verilen ilacın
--     çıkış fişi de kaydedilemezdi. Depo hareketi hiçbir koşulda satınalma
--     ayarına bağlı olmamalı.
--
--  2) HER HAREKETTE DEĞİL, BİR KEZ. Eşiğin altındaki bir kalemden gün
--     içinde on kez çıkış yapılır; satır tetiği on kez tetiklenir ve her
--     seferinde "açık talep var mı" diye sorması gerekir. Aynı işi periyodik
--     tarama zaten tek seferde yapıyor.
--
--  3) TALEP KALEM KALEM DEĞİL, TOPLU AÇILIR. Satır tetiği her kalem için
--     ayrı talep doğururdu; satınalma birimi otuz tane tek satırlık talep
--     yerine bir depo için tek talep ister - onay zinciri de bir kez işler.
--
--  Bedeli GECİKME: eşik saat 03:10'da aşılırsa talep 04:00'da açılır. Saatlik
--  periyot bunu kabul edilebilir kılıyor; acil ihtiyaç zaten elle talep
--  açılarak karşılanır (kritik stok, acil ihtiyacın kendisi değil UYARISIDIR).
--
--  ============================ VARSAYILAN KAPALI ========================
--  `satinalma.kritik_stok_aktif` açılmadan hiçbir şey yapmaz. Kurumun
--  istemediği halde kendiliğinden satınalma talebi açmak, para harcanan bir
--  süreci habersiz başlatmak olurdu. İş KAYITLI ve AKTİF gelir ama fonksiyon
--  kapalı olduğunu söyler - kapının nerede olduğu görünsün (`hizmet.oto_pasif`
--  deseninin aynısı).
-- =====================================================================

-- =========================================================== ayarlar ==
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, v.tip, 'firma', v.aciklama from (values
    ('satinalma.kritik_stok_aktif', '0', 'mantik',
     'Kritik stok için otomatik satınalma talebi açılsın mı (0 kapalı · 1 açık)'),
    -- HEDEF KAT: max_stok tanımlı DEĞİLSE, minimumun kaç katına çıkılacağı.
    --   Sadece minimuma tamamlasaydık kalem teslim alındığı gün yine eşikte
    --   olur ve ilk çıkışta yeni talep doğardı - sipariş döngüsü anlamsızlaşırdı.
    ('satinalma.kritik_hedef_kat', '2', 'sayi',
     'Azami stok tanımsızsa hedef seviye = asgari stok × bu kat (varsayılan 2)'),
    -- TALEBİN BİRİMİ: satınalma talebinde departman zorunlu alandır. Deponun
    --   departmanı yok; hangi birim adına istendiği kurum ayarıdır.
    ('satinalma.kritik_departman', '', 'sayi',
     'Otomatik kritik stok talebinin açılacağı birim (boş = birimsiz taslak)'),
    ('satinalma.kritik_isteyen', '', 'sayi',
     'Otomatik talepte "isteyen" olarak yazılacak personel (boş = yazılmaz)')
  ) as v(anahtar, deger, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

-- ================================================== sayı biçimi ==
-- Miktarı insan okuyacak: 4.000 yerine 4, 2.500 yerine 2.5. `to_char`ın
--   FM kipi sondaki sıfırları atıyor ama ondalık NOKTAYI bırakıyor ("4.") -
--   açıklama satırında bu bir yazım hatası gibi duruyor.
create or replace function public.fn_sayi_sade(p_deger numeric)
returns text language sql immutable as $sade$
    select case when p_deger is null then ''
                else rtrim(rtrim(to_char(p_deger, 'FM999999999990.999'), '0'), '.')
           end;
$sade$;

comment on function public.fn_sayi_sade(numeric) is
  '732: miktari insan icin sadelestirir (4.000 -> 4, 2.500 -> 2.5).';

-- ========================================================== fonksiyon ==
create or replace function public.fn_kritik_stok_talep(
        p_sube_id integer default null,
        p_kuru    boolean default false)   -- true: yazmadan sadece say
returns table (talep_sayisi integer, satir_sayisi integer, aciklama text)
language plpgsql as $govde$
declare
    v_aktif      boolean;
    v_kat        numeric;
    v_departman  integer;
    v_isteyen    integer;
    v_talep      integer := 0;
    v_satir      integer := 0;
    v_maxsiz     integer := 0;
    v_depo       record;
    v_kalem      record;
    v_talep_id   bigint;
    v_sira       smallint;
begin
    select coalesce(nullif(btrim(deger), ''), '0') = '1' into v_aktif
      from public.referans where anahtar = 'satinalma.kritik_stok_aktif';

    if not coalesce(v_aktif, false) then
        return query select 0, 0,
            'Kritik stok talebi KAPALI (Genel Ayarlar > satinalma.kritik_stok_aktif).'::text;
        return;
    end if;

    select coalesce(nullif(regexp_replace(deger, '[^0-9.]', '', 'g'), '')::numeric, 2)
      into v_kat from public.referans where anahtar = 'satinalma.kritik_hedef_kat';
    v_kat := greatest(coalesce(v_kat, 2), 1);

    select nullif(regexp_replace(deger, '\D', '', 'g'), '')::integer
      into v_departman from public.referans where anahtar = 'satinalma.kritik_departman';
    select nullif(regexp_replace(deger, '\D', '', 'g'), '')::integer
      into v_isteyen from public.referans where anahtar = 'satinalma.kritik_isteyen';

    -- ------------------------------------------------- kritik kalemler
    -- ELDEKİ = kalan - rezerve. Rezerveyi düşmeseydik, tamamı başka bir işe
    --   ayrılmış bir stok "var" görünür ve talep hiç açılmazdı.
    --
    -- EŞİK: deponun kendi asgarisi, yoksa stok kartının asgarisi. İkisi de
    --   sıfırsa o kalem izlenmiyor demektir - sıfır eşiği "her zaman kritik"
    --   diye okusaydık bütün katalog talebe dönerdi.
    create temporary table if not exists gecici_kritik (
        depo_id integer, sube_id integer, stok_id integer,
        ad text, birim text, eldeki numeric, esik numeric,
        hedef numeric, miktar numeric, fiyat numeric, maxsiz boolean
    ) on commit drop;
    delete from gecici_kritik;

    insert into gecici_kritik
    select sd.depo_id, coalesce(d.sube_id, 0), sd.stok_id,
           coalesce(nullif(s.ad, ''), s.kod, '') as ad,
           coalesce((select kd.ad from public.kod_deger kd
                       join public.kod_liste kl on kl.id = kd.liste_id
                      where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim
                        and kd.dil = 0), '') as birim,
           (sd.kalan - coalesce(sd.rezerve, 0)) as eldeki,
           coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0)) as esik,
           coalesce(nullif(sd.max_stok, 0),
                    coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0)) * v_kat) as hedef,
           0, 0, nullif(sd.max_stok, 0) is null
      from public.stok_durum sd
      join public.stok s on s.id = sd.stok_id
      join public.depo d on d.id = sd.depo_id
     where coalesce(s.durum, 1) = 1
       and coalesce(d.durum, 1) = 1
       and (p_sube_id is null or coalesce(d.sube_id, 0) = p_sube_id)
       and coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0)) > 0
       and (sd.kalan - coalesce(sd.rezerve, 0))
           <= coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0))
       -- AÇIK TALEBİ OLANI TEKRAR İSTEME. Talep hâlâ süreçteyse (taslak,
       --   onayda, onaylandı, teklifte) ikincisini açmak onay zincirini
       --   ikiye böler ve satınalma aynı kalemi iki kez sipariş edebilir.
       and not exists (
            select 1 from public.satinalma_talep_satir ts
              join public.satinalma_talep t on t.id = ts.talep_id
             where ts.stok_id = sd.stok_id
               and t.sube_id = coalesce(d.sube_id, 0)
               and t.durum between 0 and 4)
       -- YOLDAKİ MALI TEKRAR İSTEME: açık alış siparişi (tür 9, takip 0/1)
       --   varsa kalem zaten sipariş edilmiş; gelmesini beklemek gerekir.
       and not exists (
            select 1 from public.belge_satir bs
              join public.belge b on b.id = bs.belge_id
              join public.belge_satinalma bsa on bsa.id = b.id
             where bs.stok_id = sd.stok_id and b.tur = 9
               and coalesce(bsa.takip_durum, 0) in (0, 1));

    -- MİKTAR: hedefe tamamlar. Küsuratlı sipariş verilmez - yukarı yuvarlanır.
    update gecici_kritik set miktar = ceil(greatest(hedef - eldeki, 0));
    delete from gecici_kritik where miktar <= 0;

    -- SON ALIŞ FİYATI tahmindir, taahhüt değil: onay zincirinin basamağını
    --   belirleyen tutar bundan çıkar. Fiyat bulunamazsa 0 kalır ve talep
    --   en kısa zincirle gider - bu yüzden bulunmayan fiyat açıklamaya yazılır.
    update gecici_kritik k
       set fiyat = coalesce((
            select bs.birim_fiyat
              from public.belge_satir bs
              join public.belge b on b.id = bs.belge_id
             where bs.stok_id = k.stok_id and b.tur = 11 and coalesce(b.durum, 1) <> 0
               and bs.birim_fiyat > 0
             order by b.belge_tarihi desc, b.id desc limit 1), 0);

    select count(*) filter (where maxsiz) into v_maxsiz from gecici_kritik;

    if p_kuru then
        select count(distinct depo_id), count(*) into v_talep, v_satir from gecici_kritik;
        return query select v_talep, v_satir,
            ('Kuru çalışma: ' || v_talep || ' depo, ' || v_satir || ' kalem kritik.')::text;
        return;
    end if;

    -- --------------------------------------------- depo başına bir talep
    for v_depo in
        select k.depo_id, k.sube_id, coalesce(nullif(d.ad, ''), '') as depo_ad,
               count(*) as kalem, sum(k.miktar * k.fiyat) as tutar
          from gecici_kritik k
          join public.depo d on d.id = k.depo_id
         group by k.depo_id, k.sube_id, d.ad
         order by k.depo_id
    loop
        insert into public.satinalma_talep
            (sube_id, tarih, kaynak, kaynak_tur, kaynak_id, isteyen_id, departman_id,
             oncelik, gerekce, hesap_notu, tahmini_tutar, durum, ekleyen)
        values (v_depo.sube_id, current_date,
                2,              -- kaynak: kritik stok (otomatik)
                918,            -- kaynak_tur: depo karti (islem_log tablo kodu)
                v_depo.depo_id,
                v_isteyen, v_departman,
                -- ÖNCELİK "YÜKSEK" (2), ACİL (1) DEĞİL: kritik seviye acil
                --   ihtiyacın kendisi değil UYARISIDIR. Hepsini acil açsaydık
                --   gerçek acil talep sıradan görünürdü.
                2,
                'Kritik stok seviyesi (otomatik) · ' || v_depo.depo_ad,
                'Asgari stoğun altına düşen ' || v_depo.kalem || ' kalem. '
                || 'Miktar = hedef seviye - (kalan - rezerve); hedef, azami stok '
                || 'ya da asgari × ' || v_kat || '.',
                round(coalesce(v_depo.tutar, 0), 2),
                0,              -- TASLAK: onaya insan gönderir (bkz. aşağıda)
                0)
        returning id into v_talep_id;

        v_sira := 0;
        for v_kalem in
            select * from gecici_kritik where depo_id = v_depo.depo_id order by ad
        loop
            v_sira := v_sira + 1;
            insert into public.satinalma_talep_satir
                (talep_id, sira, stok_id, ad, miktar, birim,
                 son_alis_fiyat, tahmini_tutar, aciklama)
            values (v_talep_id, v_sira, v_kalem.stok_id, v_kalem.ad,
                    v_kalem.miktar, v_kalem.birim,
                    v_kalem.fiyat, round(v_kalem.miktar * v_kalem.fiyat, 2),
                    -- SAYI BİÇİMİ: `FM...0.999` sondaki sıfırları atıyor ama
                    --   NOKTAYI bırakıyor ("4."). Satın alan bu satırı okuyor;
                    --   sondaki noktayı da kırpıyoruz.
                    'Eldeki ' || public.fn_sayi_sade(v_kalem.eldeki)
                    || ' / asgari ' || public.fn_sayi_sade(v_kalem.esik)
                    || case when v_kalem.maxsiz then ' · azami stok tanımsız' else '' end
                    || case when v_kalem.fiyat = 0 then ' · son alış fiyatı yok' else '' end);
            v_satir := v_satir + 1;
        end loop;

        v_talep := v_talep + 1;
    end loop;

    return query select v_talep, v_satir,
        (case when v_talep = 0 then 'Kritik stok yok.'
              else v_talep || ' talep açıldı, ' || v_satir || ' kalem'
                   || case when v_maxsiz > 0
                           then ' (' || v_maxsiz || ' kalemde azami stok tanımsız)'
                           else '' end || '.'
         end)::text;
end $govde$;

comment on function public.fn_kritik_stok_talep(integer, boolean) is
  '732: kritik seviyeye dusen stoklar icin DEPO BASINA satinalma talebi (kaynak 2). '
  'Acik talebi ya da acik siparisi olan kalem atlanir. Varsayilan KAPALI '
  '(referans satinalma.kritik_stok_aktif). p_kuru = true ise yazmaz, sayar.';

-- ======================================================= zamanlı iş ==
-- SAATLİK. Günlük olsaydı sabah tükenen kalem akşama kadar talepsiz kalırdı;
--   dakikalık olsaydı aynı işi boş yere altmış kez yapardı (eşiğin altındaki
--   kalem açık talebi olduğu sürece zaten atlanıyor).
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aktif, aciklama)
select 'satinalma.kritik_stok', 'Kritik stok → satınalma talebi', 1, 1, 0, 40, 1,
       'Asgari stoğun altına düşen kalemler için depo başına satınalma talebi açar. '
       || 'Genel Ayarlar''dan açılmadıkça çalışmaz.'
 where not exists (select 1 from public.zamanli_is z where z.kod = 'satinalma.kritik_stok');
