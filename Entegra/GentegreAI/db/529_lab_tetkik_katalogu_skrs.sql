-- =====================================================================
--  529_lab_tetkik_katalogu_skrs.sql
--  LAB TETKİK KATALOGU yeni (SKRS) hizmet listesinden yeniden kurulur.
--
--  521 hizmet katalogunu SKRS'den yeniden kurarken `lab_tetkik`,
--  `lab_panel` ve `lab_tetkik_besiyeri` de boşaldı: üçü de `hizmet`e bağlıydı
--  ve silme kapanışına düştü. Laboratuvar SATILAN kalemi hizmetten okur ama
--  ÇALIŞILAN testi `lab_tetkik`ten - o boşken istem açılamaz.
--
--  KAYNAK: "Tahlil İşlemleri" (SUT.8) ve "Kan İşlemleri" (SUT.10)
--  kategorisindeki aktif hizmetler. SUT bu iki grubu tek tip altında verir;
--  laboratuvarın bölüm ayrımını (biyokimya / hematoloji / mikrobiyoloji…)
--  SKRS'de taşıyan bir alan YOK.
--
--  BÖLÜM ve TÜR AD'DAN ÇIKARILIR - ve bu bir TAHMİNDİR: "…KÜLTÜRÜ" biten
--  tetkik mikrobiyolojidir, "İDRAR…" idrar bölümü, "MUTASYON/PCR/DİZİ
--  ANALİZİ" genetiktir. Kural açıkça yazılı ve kullanıcı kartla değiştirir;
--  amaç çalışma listelerinin ilk günden anlamlı gruplanması - yoksa 2.956
--  tetkiğin tamamı "Biyokimya" görünürdü. Eşleşmeyen tetkik biyokimyada
--  kalır (varsayılan), çünkü SUT tahlil listesinin ağırlığı odur.
--
--  LOINC BOŞ BIRAKILIR: SKRS'de SUT kodu ile LOINC arasında eşleme listesi
--  yok (91.395 LOINC ambarda duruyor ama bağ yok). Ad benzerliğiyle
--  eşleştirmek yanlış uluslararası kod yazmak olurdu; alan kartta elle ya da
--  ileride resmi eşleme geldiğinde doldurulur.
--
--  PANEL KURULMAZ: `lab_panel` içeriğini `hizmet_paket` besler, o da 521'de
--  boşaldı ve SKRS panel içeriği vermiyor ("HEMOGRAM" tek SUT kodudur, neyi
--  kapsadığı listede yazmaz). Paneller hizmet kartındaki Paket/Panel
--  sekmesinden kurulur.
-- =====================================================================

/**
 * Tetkiğin bölümü ve türü ADINDAN çıkarılır (yukarıdaki not).
 * Dönen: (bolum, tur) - 433'teki kodlar.
 *   bolum: 1 Biyokimya · 2 Hematoloji · 3 Hormon · 4 Mikrobiyoloji ·
 *          5 Seroloji · 6 Koagülasyon · 7 İdrar · 9 Diğer
 *          (kaynak: KartKatalogu.Lab.cs `LabTetkikBolumKodlari` - 433'teki
 *           yorum eskidir, GENETİK diye bir bölüm yoktur: genetik testler
 *           `tur = 5` ile ayrılır ve kendi menüsünden çalışılır.)
 *   tur  : 1 sayısal · 2 metin · 4 kültür · 5 genetik
 */
create or replace function public.fn_lab_tetkik_bolum(p_ad text)
returns table (bolum smallint, tur smallint)
language sql immutable as $$
    select case
        -- KÜLTÜR: mikrobiyoloji akışı (ekim → okuma → identifikasyon) bu
        --   türle açılır; sayısal sonuç kutusu gösterilmez.
        when p_ad ilike '%KÜLTÜR%' or p_ad ilike '%ANTİBİYOGRAM%'
          or p_ad ilike '%DİREKT BAKI%' or p_ad ilike '%GRAM BOYAMA%' then 4::smallint
        -- GENETİK bölüm değil TÜRDÜR: bölümü "Diğer", türü 5 - genetik
        --   vakalar kendi menüsünden (lab_genetik_vaka) çalışılır.
        when p_ad ilike '%MUTASYON%' or p_ad ilike '%DİZİ ANALİZ%'
          or p_ad ilike '%PCR%' or p_ad ilike '%GENOTİP%'
          or p_ad ilike '%KARYOTİP%' or p_ad ilike '%FISH%' then 9::smallint
        when p_ad ilike '%İDRAR%' then 7::smallint
        when p_ad ilike '%PROTROMBİN%' or p_ad ilike '%APTT%'
          or p_ad ilike '%INR%' or p_ad ilike '%FİBRİNOJEN%'
          or p_ad ilike '%D-DİMER%' or p_ad ilike '%PIHTILAŞMA%' then 6::smallint
        when p_ad ilike '%HEMOGRAM%' or p_ad ilike '%PERİFERİK YAYMA%'
          or p_ad ilike '%SEDİMANTASYON%' or p_ad ilike '%RETİKÜLOSİT%'
          or p_ad ilike '%KAN GRUBU%' or p_ad ilike '%COOMBS%' then 2::smallint
        -- SEROLOJİ: antikor/antijen aranan testler (ELISA, IgG/IgM).
        when p_ad ilike '%ANTİKOR%' or p_ad ilike '%ANTİJEN%'
          or p_ad ilike '%IGG%' or p_ad ilike '%IGM%'
          or p_ad ilike '%ELISA%' or p_ad ilike '%RPR%'
          or p_ad ilike '%VDRL%' then 5::smallint
        when p_ad ilike '%HORMON%' or p_ad ilike '%TSH%' or p_ad ilike '%FSH%'
          or p_ad ilike '%LH%' or p_ad ilike '%PROLAKTİN%'
          or p_ad ilike '%KORTİZOL%' or p_ad ilike '%ÖSTRADİOL%'
          or p_ad ilike '%TESTOSTERON%' or p_ad ilike '%PARATHORMON%' then 3::smallint
        else 1::smallint
      end,
      case
        when p_ad ilike '%KÜLTÜR%' or p_ad ilike '%ANTİBİYOGRAM%'
          or p_ad ilike '%DİREKT BAKI%' or p_ad ilike '%GRAM BOYAMA%' then 4::smallint
        when p_ad ilike '%MUTASYON%' or p_ad ilike '%DİZİ ANALİZ%'
          or p_ad ilike '%PCR%' or p_ad ilike '%GENOTİP%'
          or p_ad ilike '%KARYOTİP%' or p_ad ilike '%FISH%' then 5::smallint
        else 1::smallint
      end;
$$;

comment on function public.fn_lab_tetkik_bolum(text) is
    'Tetkiğin bölümü/türü adından çıkarılır (529) - SKRS bu ayrımı vermiyor; TAHMİNDİR, kartla değiştirilir.';


/**
 * NUMUNE ve TÜP tetkiğin adından çıkarılır (529). Varsayılan "Serum / Sarı
 * jelli tüp" tahlillerin çoğunda doğrudur ama İDRAR KÜLTÜRÜ'nü serum diye
 * göstermek numune kabulü yanlış yönlendirir - kabul ekranı bu koda göre
 * kap/tüp basar.
 *   numune: 1 Serum · 2 Plazma · 3 Tam Kan · 4 İdrar · 5 Gaita · 6 BOS ·
 *           7 Swab · 9 Diğer
 *   tup   : 1 Sarı · 2 Mor (EDTA) · 3 Mavi (Sitrat) · 4 Gri · 5 Yeşil ·
 *           6 İdrar Kabı · 9 Diğer
 */
create or replace function public.fn_lab_tetkik_numune(p_ad text)
returns table (numune smallint, tup smallint)
language sql immutable as $$
    select n.numune,
           case n.numune when 4 then 6::smallint      -- idrar kabı
                         when 3 then 2::smallint      -- tam kan -> mor (EDTA)
                         when 5 then 9::smallint      -- gaita kabı
                         when 6 then 9::smallint      -- BOS tüpü
                         when 7 then 9::smallint      -- swab (transport)
                         else 1::smallint end
      from (select case
              when p_ad ilike '%İDRAR%'                       then 4::smallint
              when p_ad ilike '%GAİTA%' or p_ad ilike '%DIŞKI%' then 5::smallint
              when p_ad ilike '%BOS%' or p_ad ilike '%OMURİLİK%' then 6::smallint
              when p_ad ilike '%BOĞAZ%' or p_ad ilike '%BURUN%'
                or p_ad ilike '%YARA%'  or p_ad ilike '%KULAK%'
                or p_ad ilike '%SÜRÜNTÜ%' or p_ad ilike '%KONJUNKTİVA%'
                or p_ad ilike '%VAGİNAL%' or p_ad ilike '%SERVİKAL%' then 7::smallint
              when p_ad ilike '%HEMOGRAM%' or p_ad ilike '%TAM KAN%'
                or p_ad ilike '%PERİFERİK YAYMA%' or p_ad ilike '%KAN GRUBU%'
                or p_ad ilike '%SEDİMANTASYON%' or p_ad ilike '%RETİKÜLOSİT%'
                or p_ad ilike '%KAN KÜLTÜR%'                  then 3::smallint
              when p_ad ilike '%PROTROMBİN%' or p_ad ilike '%APTT%'
                or p_ad ilike '%FİBRİNOJEN%' or p_ad ilike '%D-DİMER%' then 2::smallint
              when p_ad ilike '%BALGAM%' or p_ad ilike '%ASPİRAT%'
                or p_ad ilike '%DOKU%' or p_ad ilike '%BİYOPSİ%'  then 9::smallint
              -- KÜLTÜRDE VARSAYILAN SERUM DEĞİL "DİĞER": Helicobacter ya da
              --   Legionella kültürünün numunesi serum değildir; adından
              --   çıkarılamıyorsa boş bırakmak, yanlış tüp bastırmaktan iyidir.
              when p_ad ilike '%KÜLTÜR%'                          then 9::smallint
              else 1::smallint
            end as numune) n;
$$;

comment on function public.fn_lab_tetkik_numune(text) is
    'Tetkiğin numune/tüp tipi adından çıkarılır (529) - SKRS vermiyor; TAHMİNDİR, kartla değiştirilir.';

-- ======================================================= tetkik kurulumu ==
do $$
declare
    v_sube  integer;
    v_adet  integer;
begin
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;

    -- DURUM TERS: laboratuvar kartlarinda 0 = Aktif, 1 = Pasif
    --   (KartKatalogu.Lab.cs `LabKayitDurumKodlari`). Stok/hizmet
    --   kartlarindaki 1 = Aktif alışkanlığıyla yazmak, 2.956 tetkiğin
    --   tamamını PASİF kurup listeyi boş gösteriyordu.
    insert into public.lab_tetkik (hizmet_id, kod, ad, bolum, tur, durum, sube_id,
                                   numune_tipi, tup_tipi)
    select h.id, h.kod, left(h.ad, 200), b.bolum, b.tur, 0, coalesce(v_sube, 0),
           n.numune, n.tup
      from public.hizmet h
      join public.kategori k on k.id = h.kategori
      cross join lateral public.fn_lab_tetkik_bolum(h.ad) b
      cross join lateral public.fn_lab_tetkik_numune(h.ad) n
     where k.kod in ('SUT.8', 'SUT.10')
       and h.baslik_mi = 0
       and h.durum = 1
       -- Idempotent: aynı hizmete ikinci tetkik açılmaz.
       and not exists (select 1 from public.lab_tetkik t where t.hizmet_id = h.id);
    get diagnostics v_adet = row_count;
    raise notice '529: % lab tetkiği kuruldu.', v_adet;
end $$;

-- Bölüm/tür kuralı düzeltilirse KURULU satırlar da izler: göç tekrar
--   çalıştırılınca ilk koşudaki yanlış eşleme ekranda kalmasın. Yalnız bu
--   göçün kurduğu (hizmete bağlı, hiç değiştirilmemiş) satırlar güncellenir -
--   kullanıcının kartla düzelttiği tetkik ezilmez.
update public.lab_tetkik t
   set bolum = b.bolum, tur = b.tur, durum = 0,
       numune_tipi = n.numune, tup_tipi = n.tup
  from public.hizmet h
  cross join lateral public.fn_lab_tetkik_bolum(h.ad) b
  cross join lateral public.fn_lab_tetkik_numune(h.ad) n
 where t.hizmet_id = h.id
   and t.degistirme_tarihi is null
   and (t.bolum, t.tur, t.durum, t.numune_tipi, t.tup_tipi)
       is distinct from (b.bolum, b.tur, 0::smallint, n.numune, n.tup);

-- =========================================== kültür tetkiği - besiyeri seti ==
/**
 * Kültür tetkiğinin VARSAYILAN BESİYERİ SETİ: kültür açılırken teknisyen
 * her seferinde elle seçmesin. Eşleme numune adından - idrar CLED ile,
 * boğaz kanlı agarla, gaita MacConkey ile çalışılır. Yine bir başlangıçtır;
 * laboratuvar kendi düzenini tetkik kartından değiştirir.
 */
do $$
declare
    v_adet integer;
begin
    insert into public.lab_tetkik_besiyeri (tetkik_id, besiyeri_id, sira)
    select t.id, b.id, 0
      from public.lab_tetkik t
      join lateral (
            select kod from (values
                -- (aranan ad parçası, besiyeri kodu)
                ('İDRAR',      'CLED'),
                ('BOĞAZ',      'KANLI'),
                ('BURUN',      'KANLI'),
                ('YARA',       'KANLI'),
                ('KULAK',      'KANLI'),
                ('KONJUNKTİVA','KANLI'),
                ('BALGAM',     'CIKO'),
                ('GAİTA',      'MAC'),
                ('ANAEROB',    'ANA'),
                ('KAN KÜLTÜR', 'BACTEC'),
                ('MANTAR',     'SAB')
              ) as e(parca, kod)
             where t.ad ilike '%' || e.parca || '%'
      ) as es on true
      join public.lab_besiyeri b on upper(b.kod) = es.kod
     where t.tur = 4
       and not exists (select 1 from public.lab_tetkik_besiyeri x
                        where x.tetkik_id = t.id and x.besiyeri_id = b.id);
    get diagnostics v_adet = row_count;
    raise notice '529: % kültür-besiyeri eşlemesi kuruldu.', v_adet;
end $$;

-- ================================================================ özet ==
do $$
declare r record;
begin
    for r in
        select case bolum when 1 then 'Biyokimya' when 2 then 'Hematoloji'
                          when 3 then 'Hormon' when 4 then 'Mikrobiyoloji'
                          when 5 then 'Seroloji' when 6 then 'Koagülasyon'
                          when 7 then 'İdrar' when 9 then 'Diğer'
                          else bolum::text end as ad,
               count(*) as adet
          from public.lab_tetkik group by bolum order by 2 desc
    loop
        raise notice '  % : %', rpad(r.ad, 16), r.adet;
    end loop;
end $$;
