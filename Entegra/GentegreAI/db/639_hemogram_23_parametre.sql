-- =====================================================================
--  639_hemogram_23_parametre.sql
--  HEMOGRAM PANELİ 23 PARAMETRE (kullanici: "23 parametre olsun demistim").
--
--  638'de panel üç parametreyle (WBC/HGB/PLT) kurulmuştu - eksik. Otomatik
--  kan sayımı cihazlarının standart raporu 23 parametredir: lökosit ve
--  formülü (mutlak + yüzde), eritrosit dizisi, trombosit dizisi.
--
--  PANEL İÇERİĞİ `hizmet_paket`TE DURUR - ve bu bir tercih değil, modelin
--  kuralı: `lab_panel_satir` bir GÖRÜNÜMDÜR (`hizmet_paket` üzerine), yazma
--  tetiği (`tg_lab_panel_satir_yaz`) hem panelin hem tetkiğin hizmet
--  karşılığını ZORUNLU tutuyor:
--      "GK422: Tetkikin hizmet karşılığı tanımlı değil"
--  Yani her parametre bir hizmete bağlanmak zorunda.
--
--  PARAMETRE HİZMETLERİ SUT KODU TAŞIMAZ (`LAB-*` kurum içi kodlar).
--  Hemogram SUT'ta TEK kalemdir (L107020); lökosit, MCV, PDW gibi
--  parametrelerin ayrı SUT kodu YOKTUR. Onlara SUT kodu uydurmak, olmayan
--  kalemleri faturalanabilir göstermek olurdu. Fatura panelden kesilir:
--  `hizmet.paket = 1` bunu söyler, içerik kalemlerinden ayrıca ücret
--  alınmaz.
--
--  LOINC kodları hemogram için standarttır; cihaz entegrasyonu ve sonuç
--  bildirimi bunlarla eşleşir.
-- =====================================================================

-- ------------------------------------------------ parametre hizmetleri (23)
--  Ön ek + tetkik kodunun sadeleştirilmiş hâli: '#' mutlak (A), '%' yüzde (P).
insert into public.hizmet (kod, ad, baslik_mi, ust_id, grubu, tur, kdv,
                           birim, durum, kategori, paket, sube_id)
select v.kod, v.ad || ' (hemogram parametresi)', 0, h.ust_id, 0, 0, h.kdv,
       h.birim, 1, h.kategori, 0, h.sube_id
  from (values
        ('LAB-WBC','Lökosit'), ('LAB-NEUA','Nötrofil (mutlak)'),
        ('LAB-LYMA','Lenfosit (mutlak)'), ('LAB-MONA','Monosit (mutlak)'),
        ('LAB-EOSA','Eozinofil (mutlak)'), ('LAB-BASA','Bazofil (mutlak)'),
        ('LAB-NEUP','Nötrofil (%)'), ('LAB-LYMP','Lenfosit (%)'),
        ('LAB-MONP','Monosit (%)'), ('LAB-EOSP','Eozinofil (%)'),
        ('LAB-BASP','Bazofil (%)'),
        ('LAB-RBC','Eritrosit'), ('LAB-HGB','Hemoglobin'),
        ('LAB-HCT','Hematokrit'), ('LAB-MCV','Ortalama eritrosit hacmi'),
        ('LAB-MCH','Ortalama eritrosit hemoglobini'),
        ('LAB-MCHC','Ortalama eritrosit Hb konsantrasyonu'),
        ('LAB-RDWCV','Eritrosit dağılım genişliği (CV)'),
        ('LAB-RDWSD','Eritrosit dağılım genişliği (SD)'),
        ('LAB-PLT','Trombosit'), ('LAB-MPV','Ortalama trombosit hacmi'),
        ('LAB-PDW','Trombosit dağılım genişliği'), ('LAB-PCT','Trombositkrit')
       ) v(kod, ad)
  join public.hizmet h on h.kod = 'L107020'
 where not exists (select 1 from public.hizmet x where x.kod = v.kod);

-- FATURA PANELDEN: içerik kalemlerinden ayrıca ücret alınmaz.
update public.hizmet set paket = 1 where kod = 'L107020' and paket <> 1;

-- ----------------------------------------------------- parametre tetkikleri
--  Var olan üçü (WBC, HGB, PLT) korunur - referans aralıkları ve panik
--  sınırları onlara daha önce girilmişti.
insert into public.lab_tetkik
       (kod, ad, kisa_ad, bolum, tur, numune_tipi, tup_tipi, birim, ondalik,
        loinc, hedef_tat_dk, acil_tat_dk, oto_onay, panik_alt, panik_ust,
        durum, sube_id)
select v.kod, v.ad, v.kod, 2, 1, 1, 2, v.birim, v.ondalik,
       v.loinc, 45, 20, 1, v.panik_alt, v.panik_ust, 0, 1
  from (values
        ('RBC',    'Eritrosit',                            '10^6/uL', 2::smallint, '789-8',   2.0, 8.0),
        ('HCT',    'Hematokrit',                           '%',       1,           '4544-3',  20.0, 60.0),
        ('MCV',    'Ortalama Eritrosit Hacmi',             'fL',      1,           '787-2',   null, null),
        ('MCH',    'Ortalama Eritrosit Hemoglobini',       'pg',      1,           '785-6',   null, null),
        ('MCHC',   'Ortalama Eritrosit Hb Konsantrasyonu', 'g/dL',    1,           '786-4',   null, null),
        ('RDW-CV', 'Eritrosit Dağılım Genişliği (CV)',     '%',       1,           '788-0',   null, null),
        ('RDW-SD', 'Eritrosit Dağılım Genişliği (SD)',     'fL',      1,           '21000-5', null, null),
        ('MPV',    'Ortalama Trombosit Hacmi',             'fL',      1,           '32623-1', null, null),
        ('PDW',    'Trombosit Dağılım Genişliği',          'fL',      1,           '32207-3', null, null),
        ('PCT',    'Trombositkrit',                        '%',       2,           '51637-7', null, null),
        ('NEU#',   'Nötrofil (mutlak)',                    '10^3/uL', 2,           '751-8',   0.5, null),
        ('LYM#',   'Lenfosit (mutlak)',                    '10^3/uL', 2,           '731-0',   null, null),
        ('MON#',   'Monosit (mutlak)',                     '10^3/uL', 2,           '742-7',   null, null),
        ('EOS#',   'Eozinofil (mutlak)',                   '10^3/uL', 2,           '711-2',   null, null),
        ('BAS#',   'Bazofil (mutlak)',                     '10^3/uL', 2,           '704-7',   null, null),
        ('NEU%',   'Nötrofil (%)',                         '%',       1,           '770-8',   null, null),
        ('LYM%',   'Lenfosit (%)',                         '%',       1,           '736-9',   null, null),
        ('MON%',   'Monosit (%)',                          '%',       1,           '5905-5',  null, null),
        ('EOS%',   'Eozinofil (%)',                        '%',       1,           '713-8',   null, null),
        ('BAS%',   'Bazofil (%)',                          '%',       1,           '706-2',   null, null)
       ) v(kod, ad, birim, ondalik, loinc, panik_alt, panik_ust)
 where not exists (select 1 from public.lab_tetkik x where x.kod = v.kod);

-- ------------------------------------------------- tetkik -> hizmet köprüsü
update public.lab_tetkik t
   set hizmet_id = h.id, degistirme_tarihi = now()
  from (values
        ('WBC','LAB-WBC'), ('NEU#','LAB-NEUA'), ('LYM#','LAB-LYMA'),
        ('MON#','LAB-MONA'), ('EOS#','LAB-EOSA'), ('BAS#','LAB-BASA'),
        ('NEU%','LAB-NEUP'), ('LYM%','LAB-LYMP'), ('MON%','LAB-MONP'),
        ('EOS%','LAB-EOSP'), ('BAS%','LAB-BASP'),
        ('RBC','LAB-RBC'), ('HGB','LAB-HGB'), ('HCT','LAB-HCT'),
        ('MCV','LAB-MCV'), ('MCH','LAB-MCH'), ('MCHC','LAB-MCHC'),
        ('RDW-CV','LAB-RDWCV'), ('RDW-SD','LAB-RDWSD'),
        ('PLT','LAB-PLT'), ('MPV','LAB-MPV'), ('PDW','LAB-PDW'),
        ('PCT','LAB-PCT')
       ) v(tetkik_kod, hizmet_kod)
  join public.hizmet h on h.kod = v.hizmet_kod
 where t.kod = v.tetkik_kod
   and coalesce(t.hizmet_id, 0) = 0;

-- ------------------------------------------ panel yazma tetiği onarılır
--  `lab_panel_satir` görünümüne yazmak HER ZAMAN düşüyordu:
--
--    ERROR: there is no unique or exclusion constraint matching the
--           ON CONFLICT specification
--
--  Tetik (501) `on conflict (paket_hizmet_id, icerik_hizmet_id)` diyor ama
--  o benzersiz indeks KISMİ: `where icerik_hizmet_id is not null` (paket
--  içeriği hizmet YA DA stok olabilir, ikisi ayrı indeks). Kısmi indekse
--  çıkarım yapabilmek için ON CONFLICT'in de aynı koşulu taşıması gerekir.
--
--  Yani panel kartından tetkik eklemek hiç çalışmıyordu; içerik ancak
--  `hizmet_paket`e elle yazılarak kuruluyordu.
create or replace function public.tg_lab_panel_satir_yaz() returns trigger
language plpgsql as $tetik$
declare
    v_paket  integer;
    v_icerik integer;
begin
    if tg_op = 'DELETE' then
        delete from public.hizmet_paket where id = old.id;
        return old;
    end if;

    select hizmet_id into v_paket  from public.lab_panel  where id = new.panel_id;
    select hizmet_id into v_icerik from public.lab_tetkik where id = new.tetkik_id;

    -- Köprü kurulmamışsa sessizce yazmak İÇERİĞİ KAYBETTİRİR: panel kartı
    --   satırı kaydedilmiş görünür ama hiçbir yere düşmez.
    if v_paket is null then
        raise exception 'GK422: Panelin hizmet karşılığı tanımlı değil - panel kartında "Hizmet (paket fiyat)" alanını doldurun.';
    end if;
    if v_icerik is null then
        raise exception 'GK422: Tetkikin hizmet karşılığı tanımlı değil - tetkik kartında hizmet bağını kurun.';
    end if;

    if tg_op = 'INSERT' then
        insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira,
                                         ekleyen, degistiren)
        values (v_paket, v_icerik, coalesce(new.sira, 0),
                coalesce(new.ekleyen, 0), coalesce(new.degistiren, 0))
        -- 639: KISMİ indeksin koşulu da yazılır, yoksa çıkarım tutmuyor.
        on conflict (paket_hizmet_id, icerik_hizmet_id)
            where icerik_hizmet_id is not null
            do update set sira = excluded.sira
        returning id into new.id;
        return new;
    end if;

    update public.hizmet_paket
       set paket_hizmet_id   = v_paket,
           icerik_hizmet_id  = v_icerik,
           sira              = coalesce(new.sira, 0),
           degistiren        = coalesce(new.degistiren, 0),
           degistirme_tarihi = now()::timestamp
     where id = old.id;
    return new;
end $tetik$;

-- ------------------------------------------------- panel içeriği (23 satır)
--  `lab_panel_satir` görünümüne yazılır; tetik `hizmet_paket`e aktarır.
--  Sıra cihaz raporunun sırasıdır: lökosit ve formülü, eritrosit dizisi,
--  trombosit dizisi.
insert into public.lab_panel_satir (panel_id, tetkik_id, sira)
select p.id, t.id, v.sira
  from (values
        ('WBC', 10::smallint), ('NEU#', 20), ('LYM#', 30), ('MON#', 40),
        ('EOS#', 50), ('BAS#', 60), ('NEU%', 70), ('LYM%', 80), ('MON%', 90),
        ('EOS%', 100), ('BAS%', 110),
        ('RBC', 120), ('HGB', 130), ('HCT', 140), ('MCV', 150), ('MCH', 160),
        ('MCHC', 170), ('RDW-CV', 180), ('RDW-SD', 190),
        ('PLT', 200), ('MPV', 210), ('PDW', 220), ('PCT', 230)
       ) v(kod, sira)
  join public.lab_tetkik t on t.kod = v.kod
  join public.lab_panel p on p.kod = 'HEMOGRAM'
 where not exists (select 1 from public.lab_panel_satir s
                    where s.panel_id = p.id and s.tetkik_id = t.id);

do $kontrol$
declare
    v_par integer;
    v_bagsiz integer;
begin
    select count(*) into v_par
      from public.lab_panel_satir s
      join public.lab_panel p on p.id = s.panel_id and p.kod = 'HEMOGRAM';
    select count(*) into v_bagsiz
      from public.lab_tetkik where coalesce(hizmet_id, 0) = 0;
    raise notice '639 tamam: hemogram paneli % parametre, hizmete baglanmamis tetkik %',
        v_par, v_bagsiz;
end $kontrol$;
