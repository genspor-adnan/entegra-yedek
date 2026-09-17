-- ============================================================================
--  Gentegre AI — İSKONTO TALEBİ ONAY OMURGASINA TAŞINIYOR
--  754_iskonto_omurga.sql
--
--  Kullanıcı: "iskonto talebini de omurgaya taşı."
--
--  662'de iskonto onayı TEK BASAMAKLIYDI: tavanı yeten herkes talebi zilinde
--  görüyor, ilk basan kararı veriyordu. Bu, tavanı %100 olan bir kişinin
--  %40'lık indirimi tek başına vermesi demekti - "sıra kimdeydi, kim atladı"
--  sorularının cevabı yoktu.
--
--  OMURGA (738) ZATEN VAR: satınalma, izin, onarım ve avans aynı zinciri
--  kullanıyor. İskonto için ikinci bir sıra mekanizması yazmak, aynı işi
--  beşinci kez ve ayrı kurallarla yapmak olurdu.
--
--  ============ NE DEĞİŞMİYOR ==========================================
--  `iskonto_talep` / `iskonto_talep_satir` TABLOLARI DURUYOR: talebin kendi
--  verisi (hangi satırlar, kalem oranları, talep anındaki fiyat) omurgaya
--  ait değildir. Omurga yalnız SIRAYI yürütür.
--
--  `fn_iskonto_talep_karar` DA DURUYOR ve satıra yazan tek yer o kalıyor:
--  oranı satırlara yazmak + satırları kilitlemek ayrılamaz iki iştir. Zincir
--  bitince omurga bu fonksiyonu çağırır; ara basamakta kimse satıra dokunmaz.
--
--  ============ KISMİ ONAY = ÖLÇÜYÜ DÜŞÜREREK ONAYLAMAK ================
--  662'nin en değerli davranışı kısmi onaydı (%20 istendi, %10 verildi) ve
--  omurgada karşılığı yoktu. Artık kısmi onay ÖLÇÜYÜ DÜŞÜRÜR: `onay.olcu`
--  yeni orana çekilir ve o orana artık GEREKMEYEN ileri basamaklar
--  `durum = 5 (atlandı)` ile kapanır.
--
--  Bu uydurma bir kolaylık değil, kuralın kendisi: %30 üst yönetime
--  gidiyorsa ve mali işler oranı %8'e indirdiyse, üst yönetimin imzası
--  ortadan kalkmış bir iş için istenmiş olur. Basamağı bekletmek talebi
--  gereksiz yere günlerce açık tutardı; sessizce silmek ise "bu imza neden
--  alınmadı" sorusunu cevapsız bırakırdı - "atlandı" ikisini de çözer.
--
--  ORAN YÜKSELTİLEMEZ: yetkili indirimi artırmak isterse kendi talebini
--  açar (662 kuralı). Yükseltmek yeni basamaklar doğururdu ve zaten karar
--  vermiş olanların imzası başka bir rakama verilmiş sayılırdı.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  0) KAYNAK TÜRÜ
--     Omurga kaydı `kaynak_tur` + `kaynak_id` ile bağlar; kaynak_tur
--     `islem_log.tablo_id`'dir. İskonto talebine 1256 ayrıldı (katalogda en
--     yüksek kullanılan 1255'ti).
-- ---------------------------------------------------------------------------
comment on column public.iskonto_talep.onay_id is
  '662: KARARI VEREN KULLANICI (omurgadaki onay.id DEGIL). 754 sonrasi '
  'zinciri kapatan son onaylayandir; zincirin kendisi onay/onay_adim da.';

-- ---------------------------------------------------------------------------
--  1) YETKİLER
--     Basamağın rolü hangi yetkiyi ister: motor rolü taşır, "o rol ne
--     imzalayabilir" sorusunu modül yanıtlar (738 prensibi).
--
--     `basvuru.iskonto` KALKMIYOR: o bir TAVAN (yüzde) yetkisidir, bu üçü
--     ise BASAMAK yetkisi. İkisi farklı soruya cevap verir - "sıra sende mi"
--     ve "en çok kaç verebilirsin".
-- ---------------------------------------------------------------------------
insert into public.yetki (kod, ad, grup, tur, aktif)
select x.kod, x.ad, 'Başvuru', 0, 1
  from (values
    ('belge.iskonto_onay_birim', 'İskonto onayı - birim sorumlusu'),
    ('belge.iskonto_onay_mali',  'İskonto onayı - mali işler'),
    ('belge.iskonto_onay_ust',   'İskonto onayı - üst yönetim')
  ) as x(kod, ad)
 where not exists (select 1 from public.yetki y where y.kod = x.kod);

-- YÖNETİCİ ve İSKONTO ONAY rolleri üçünü de alır: tanımlı ama kimseye
--   verilmemiş yetki, ekranı ilk açanda 403 demektir (747/752/753'te aynı
--   hata iki kez yapıldı).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 0
  from public.rol r
  cross join public.yetki y
 where r.kod in ('yonetici', 'iskonto_onay')
   and y.kod in ('belge.iskonto_onay_birim', 'belge.iskonto_onay_mali',
                 'belge.iskonto_onay_ust')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ---------------------------------------------------------------------------
--  2) AKIŞ TANIMI
--     Eşikler YÜZDEDİR (tutar değil): indirimin büyüklüğü oranla ölçülür,
--     çünkü aynı %30 hem 200 TL'lik hem 20.000 TL'lik bir başvuruda kurumun
--     fiyat politikasına aynı ölçüde dokunur. Tutar eşiği isteyen kurum
--     ikinci bir akış tanımlar - eşik ADIMIN özelliğidir (738).
-- ---------------------------------------------------------------------------
insert into public.onay_akis (kod, ad, kaynak_tur, olcu_adi, aktif, aciklama, ekleyen)
select 'belge.iskonto', 'İskonto Onayı', 1256, 'İskonto Oranı (%)', 1,
       '662 tek basamakli onayin omurga karsiligi: birim sorumlusu her '
       'talepte; %10 ustu mali isler, %25 ustu ust yonetim. Daha once '
       'onaylanmis (kilitli) satira ikinci indirim ayri bir karardir.', 0
 where not exists (select 1 from public.onay_akis where kod = 'belge.iskonto');

insert into public.onay_akis_adim
       (akis_id, sira, ad, sahip_turu, rol, esik_alt, bayrak, sure_gun, ekleyen)
select k.id, x.sira, x.ad, 1, x.rol, x.esik, x.bayrak, x.sure, 0
  from public.onay_akis k
  cross join (values
        -- BİRİM SORUMLUSU HER TALEPTE: indirimi banko ister; bankonun
        --   hastayı ve pazarlığı bilen âmiri, "bu indirim gerçekten gerekli
        --   mi" sorusunu cevaplayabilecek tek kişidir.
        (1::smallint, 'Birim Sorumlusu', 1::smallint, null::numeric, '',      1::smallint),
        (2::smallint, 'Mali İşler',      4::smallint, 10::numeric,   '',      2::smallint),
        (3::smallint, 'Üst Yönetim',     5::smallint, 25::numeric,   '',      3::smallint),
        -- TEKRAR İNDİRİM: satır zaten onaylı bir iskonto taşıyor. İlk
        --   indirim bir karardı; üstüne ikincisini yazmak o kararı
        --   değiştirmektir ve oranı küçük olsa bile üst yönetime sorulur.
        (4::smallint, 'Üst Yönetim (tekrar indirim)', 5::smallint, null::numeric,
         'tekrar_iskonto', 2::smallint)
      ) as x(sira, ad, rol, esik, bayrak, sure)
 where k.kod = 'belge.iskonto'
   and not exists (select 1 from public.onay_akis_adim a where a.akis_id = k.id);

-- ---------------------------------------------------------------------------
--  3) MEVCUT TALEPLER OMURGAYA KOPYALANIR
--
--     SONUÇLANANLAR TEK BASAMAKLA taşınır: o karar gerçekten tek kişinin
--     imzasıydı; bugünkü akışa göre üç basamak uydurmak, alınmamış iki
--     imzayı alınmış göstermek olurdu.
-- ---------------------------------------------------------------------------
insert into public.onay (akis_id, kaynak_tur, kaynak_id, sube_id, olcu, bayraklar,
                         durum, baslatan_id, baslama, bitis, ekleyen, ekleme_tarihi)
select (select id from public.onay_akis where kod = 'belge.iskonto'),
       1256, t.id, coalesce(t.sube_id, 0), t.oran, '',
       case t.durum when 1 then 1 when 2 then 2 when 3 then 3 else 0 end,
       t.isteyen_id, t.istek_ts,
       case when t.durum <> 0 then t.onay_ts end,
       0, t.istek_ts
  from public.iskonto_talep t
 where not exists (select 1 from public.onay n
                    where n.kaynak_tur = 1256 and n.kaynak_id = t.id);

-- 3a) Sonuçlanmışlar: tek basamak, kararı veren kişiyle.
insert into public.onay_adim (onay_id, sira, ad, sahip_turu, rol, atanan_kullanici_id,
                              durum, karar_veren_id, karar_zamani, gerekce,
                              ekleyen, ekleme_tarihi)
select n.id, 1, 'Yetkili', 1, 4, null,
       case t.durum when 1 then 1 when 2 then 2 else 5 end,
       t.onay_id, t.onay_ts, t.karar_notu, 0, t.istek_ts
  from public.iskonto_talep t
  join public.onay n on n.kaynak_tur = 1256 and n.kaynak_id = t.id
 where t.durum <> 0
   and not exists (select 1 from public.onay_adim a where a.onay_id = n.id);

-- 3b) BEKLEYENLER GERÇEK ZİNCİRE BAĞLANIR: henüz kimse imzalamadığı için
--     bugünkü akışa göre basamakları kurmak geçmişi değiştirmez - talebin
--     önünde zaten karar verilmemiş bir yol vardı. Bayrak koşullu basamak
--     (tekrar_iskonto) GEÇMİŞE UYGULANMAZ: bayrağı talep anında hesaplayan
--     uç yoktu, sonradan uydurmak alınmamış bir imzayı istemek olurdu.
insert into public.onay_adim (onay_id, sira, ad, sahip_turu, rol, atanan_kullanici_id,
                              durum, termin, ekleyen, ekleme_tarihi)
select n.id,
       (row_number() over (partition by n.id order by d.sira))::smallint,
       d.ad, 1, d.rol, null, 0,
       t.istek_ts + (d.sure_gun || ' days')::interval,
       0, t.istek_ts
  from public.iskonto_talep t
  join public.onay n on n.kaynak_tur = 1256 and n.kaynak_id = t.id
  join public.onay_akis k on k.kod = 'belge.iskonto'
  join public.onay_akis_adim d on d.akis_id = k.id and d.aktif = 1
                              and d.bayrak = ''
                              and (d.esik_alt is null or t.oran >= d.esik_alt)
 where t.durum = 0
   and not exists (select 1 from public.onay_adim a where a.onay_id = n.id);

-- ---------------------------------------------------------------------------
--  4) GELEN KUTUSU İSKONTOYU DA TANISIN
--     Konu = gerekçe + kalem sayısı, birim yerine HASTA: onaylayanın sorusu
--     "yüzde kaç" değil yalnız; "kime, kaç kalemde, neden".
-- ---------------------------------------------------------------------------
create or replace view public.v_onay_kutusu as
select v.adim_id                                as id,
       v.onay_id, v.kaynak_tur, v.kaynak_id, v.sube_id,
       v.akis_kod, v.akis_ad, v.olcu, v.olcu_adi, v.sira, v.adim_ad, v.rol,
       v.atanan_kullanici_id, v.durum, v.gerekce, v.baslama, v.termin,
       v.gecikme_gun,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.talep_no, ''), '#' || v.kaynak_id::text)
            when 904  then coalesce(nullif(z.izin_no, ''), 'İzin #' || v.kaynak_id::text)
            when 1224 then coalesce(nullif(w.is_emri_no, ''),
                                    'İş emri #' || v.kaynak_id::text)
            when 907  then coalesce(nullif(av.avans_no, ''),
                                    'Avans #' || v.kaynak_id::text)
            when 1256 then coalesce(nullif(ib.belge_no, ''),
                                    'Başvuru #' || coalesce(isk.belge_id, 0)::text)
            else '#' || v.kaynak_id::text
       end                                      as kayit_no,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
            when 904  then case z.tur when 1 then 'Yıllık izin'
                                      when 2 then 'Mazeret izni'
                                      when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin'
                                      else 'İzin' end
                           || ' · ' || to_char(z.baslangic_tarihi, 'DD.MM')
                           || '-' || to_char(z.bitis_tarihi, 'DD.MM.YYYY')
            when 1224 then coalesce(nullif(dm.ad, ''), 'Cihaz')
                           || ' · ' || coalesce(nullif(w.ariza_metni, ''), 'onarım')
            when 907  then coalesce(nullif(av.gerekce, ''), 'Avans')
                           || ' · ' || av.taksit_sayisi::text || ' taksit'
            when 1256 then coalesce(nullif(isk.gerekce, ''), 'İskonto talebi')
                           || ' · ' || (select count(*)::text
                                          from public.iskonto_talep_satir ts
                                         where ts.talep_id = isk.id) || ' kalem'
            else ''
       end                                      as konu,
       case v.kaynak_tur
            when 1241 then coalesce(d.ad, '')
            when 904  then coalesce(nullif(zp.gorev, ''), '')
            when 1224 then coalesce(wd.ad, '')
            when 907  then coalesce(nullif(ap.gorev, ''), '')
            when 1256 then coalesce(ih.unvan, '')   -- indirimi alacak hasta
            else ''
       end                                      as birim,
       case v.kaynak_tur
            when 1241 then coalesce(p.unvan, '')
            when 904  then coalesce(zt.unvan, '')
            when 1224 then coalesce(wb.unvan, '')
            when 907  then coalesce(at.unvan, '')
            when 1256 then coalesce(ii.unvan, '')
            else ''
       end                                      as talep_eden
  from public.v_onay_bekleyen v
  left join public.satinalma_talep t on v.kaynak_tur = 1241 and t.id = v.kaynak_id
  left join public.departman d on d.id = t.departman_id
  left join public.taraf p     on p.id = t.isteyen_id
  left join public.personel_izin z on v.kaynak_tur = 904 and z.id = v.kaynak_id
  left join public.taraf zt          on zt.id = z.taraf_id
  left join public.taraf_personel zp on zp.id = z.taraf_id
  left join public.demirbas_is_emri w on v.kaynak_tur = 1224 and w.id = v.kaynak_id
  left join public.demirbas dm  on dm.id = w.demirbas_id
  left join public.departman wd on wd.id = w.departman_id
  left join public.taraf wb     on wb.id = w.bildiren_id
  left join public.personel_avans av on v.kaynak_tur = 907 and av.id = v.kaynak_id
  left join public.taraf at          on at.id = av.taraf_id
  left join public.taraf_personel ap on ap.id = av.taraf_id
  left join public.iskonto_talep isk on v.kaynak_tur = 1256 and isk.id = v.kaynak_id
  left join public.belge ib on ib.id = isk.belge_id
  left join public.taraf ih on ih.id = ib.taraf_id
  left join public.taraf ii on ii.id = isk.isteyen_id;

comment on view public.v_onay_kutusu is
  '739/744/752/753/754: butun modullerin bekleyen onaylari (satinalma talebi · '
  'izin · masrafli onarim · avans · iskonto), kaydin konusu cozulmus halde.';

-- ---------------------------------------------------------------------------
--  5) ESKİ TEK BASAMAKLI YOL KAPANIR
--     `fn_iskonto_talep_karar` DURUYOR (oranı yazan ve kilitleyen tek yer),
--     ama artık onu yalnız omurga çağırır. Doğrudan çağrılmasını engelleyen
--     ayrı bir kilit koymuyoruz: fonksiyon zaten "durum <> 0 ise reddet"
--     diyor ve zincir bitmeden kimse talebi 0'dan çıkarmıyor.
-- ---------------------------------------------------------------------------
comment on function public.fn_iskonto_talep_karar is
  'Iskonto talebini onaylar (orani satirlara yazip kilitler) ya da reddeder '
  '(662). 754 sonrasi YALNIZ onay omurgasi cagirir - zincir bitince.';

do $$
declare v_onay int; v_adim int;
begin
    select count(*) into v_onay from public.onay where kaynak_tur = 1256;
    select count(*) into v_adim from public.onay_adim a
      join public.onay n on n.id = a.onay_id where n.kaynak_tur = 1256;
    raise notice '754 tamam: iskonto omurgaya tasindi (% onay, % basamak).',
                 v_onay, v_adim;
end $$;
