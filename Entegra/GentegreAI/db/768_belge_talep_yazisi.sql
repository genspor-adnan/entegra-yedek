-- ============================================================================
--  Gentegre AI — BELGE TALEBİNDE YAZININ KENDİSİNİ ÜRETME
--  768_belge_talep_yazisi.sql
--
--  Kullanıcı: "belge talebinde yazının kendisini üret" (kalan iş 3.8).
--
--  765 talebi ve hazırlık/teslim akışını izliyordu ama "hazırlandı" yalnız bir
--  İŞARETTİ: metni İK kendi bilgisayarında yazıyordu. Sonuç, sistemin
--  cevaplayamadığı iki soru: *"o yazıda ne yazıyordu"* ve *"kim neyi taahhüt
--  etti"*. Teslim edilmiş belgenin metni hiçbir yerde durmuyordu.
--
--  ============ ŞABLON + DONDURULMUŞ METİN =============================
--  İki ayrı şey saklanıyor ve karıştırılmamalı:
--
--    `belge_yazi_sablonu`              — kurumun DEĞİŞEBİLİR şablonu.
--    `personel_belge_talep.yazi_metin` — o talep için ÜRETİLMİŞ, dondurulmuş
--                                        metin.
--
--  Şablon sonradan değişince eski belgenin metni DEĞİŞMEZ. Yazıyı her
--  görüntülemede şablondan yeniden üretmek, iki yıl önce bankaya verilmiş
--  yazının bugünkü şablonla yeniden çizilmesi olurdu - teslim edilen kâğıtla
--  ekrandaki metin tutmazdı.
--
--  ============ MAAŞ: BORDRO YOK, ELLE GİRİLİR =========================
--  Bu üründe henüz bordro/puantaj modülü yok (kalan iş 3.3 de onu bekliyor).
--  Maaş yazısı maaşı YAZMAK ZORUNDA. Uydurmak yerine talebe iki alan eklendi:
--  `maas_tutar` + `maas_turu` (net/brüt). İK hazırlarken girer.
--
--  Şablonda `{maas}` geçiyor ve alan boşsa `fn_belge_talep_yazi` bunu EKSİK
--  olarak bildirir ve hazırlama reddedilir. Boş bırakıp "___ TL" yazan bir
--  belge üretmek, imzalanmış resmî yazıda boşluk bırakmak olurdu.
--
--  Bordro modülü gelince `{maas}` oradan beslenmeli; o zamana kadar tek doğru
--  davranış, sayıyı yazanın insan olduğunu kayıt altına almaktır (`islem_log`
--  alan bazında tutuyor).
--
--  ============ HTML DEĞİL DÜZ METİN ===================================
--  Şablon gövdesi DÜZ METİNDİR. Antet, başlık, imza bloğu ve sayfa düzeni
--  ekranın sabit HTML'i; DB'den HTML gelmiyor. İki sebep: (1) `dokuman`
--  içerik ucu HTML'i bilerek kabul etmiyor (XSS - beyaz listede yok),
--  (2) resmî Türkçe yazı zaten paragraflardan ibaret. Biçim gerekirse
--  şablonun değil ekranın işidir.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------- 1
--  TALEBE ÜRETİLEN YAZI VE MAAŞ ALANLARI
alter table public.personel_belge_talep
    add column if not exists maas_tutar     numeric(18,2),
    add column if not exists maas_turu      smallint     not null default 0,
    add column if not exists yazi_sablon_id integer,
    add column if not exists yazi_baslik    varchar(200) not null default '',
    add column if not exists yazi_metin     text         not null default '',
    add column if not exists yazi_tarihi    timestamptz;

comment on column public.personel_belge_talep.maas_tutar is
  '768: maas yazisinda yazilacak tutar. Bordro modulu YOK - IK elle girer.';
comment on column public.personel_belge_talep.maas_turu is
  '768: 0 belirtilmemis, 1 net, 2 brut.';
comment on column public.personel_belge_talep.yazi_metin is
  '768: URETILMIS ve DONDURULMUS metin. Sablon sonradan degisse de bu degismez.';

-- ---------------------------------------------------------------------- 2
--  ŞABLON TABLOSU
--
--  Şablon ŞUBEYE BAĞLI (`sube_id = 0` tüm şubeler): çok şubeli kurumda her
--  şubenin unvanı ve imza yetkilisi farklıdır. Çözüm sırası: önce şubenin
--  kendi şablonu, yoksa 0'lı ortak şablon.
--
--  DİL ayrı kolon çünkü vize yazısı İngilizce istenir - aynı türün iki dilde
--  şablonu olur.
create table if not exists public.belge_yazi_sablonu (
    id                integer generated always as identity primary key,
    tur               smallint     not null,
    dil               varchar(5)   not null default 'tr',
    ad                varchar(120) not null,
    baslik            varchar(200) not null default '',
    govde             text         not null default '',
    alt_not           varchar(400) not null default '',
    imza_unvan        varchar(120) not null default '',
    sube_id           integer      not null default 0,
    durum             smallint     not null default 1,
    aciklama          varchar(400) not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz,
    constraint ck_belge_yazi_sablonu_tur check (tur between 1 and 9)
);

-- ETKİN ŞABLON TEKTİR: aynı (tür · dil · şube) için iki etkin satır olsaydı
--   hangisiyle yazıldığı rastgele olurdu. Pasif satır serbest - eski sürüm
--   saklanabilsin.
create unique index if not exists ux_belge_yazi_sablonu_etkin
    on public.belge_yazi_sablonu (tur, dil, sube_id) where durum = 1;

comment on table public.belge_yazi_sablonu is
  '768: belge talebi yazi sablonlari. Govde DUZ METIN + {yer_tutucu}. '
  'Sube 0 = tum subeler; sube ozel sablon onceliklidir.';

-- ---------------------------------------------------------------------- 3
--  VARSAYILAN ŞABLONLAR
--
--  Yer tutucular `{...}`. `fn_belge_talep_yazi` çözer; çözemediğini EKSİK
--  olarak bildirir. `{muhatap}` boşsa "İlgili Makama" olur - muhatapsız resmî
--  yazı diye bir şey yok, ama personel her zaman bilmez.
insert into public.belge_yazi_sablonu
       (tur, dil, ad, baslik, govde, alt_not, imza_unvan, aciklama)
select x.tur, x.dil, x.ad, x.baslik, x.govde, x.alt_not, x.imza_unvan, x.aciklama
  from (values
  (1::smallint, 'tr'::varchar, 'Çalışma Belgesi'::varchar,
   'ÇALIŞMA BELGESİ'::varchar,
   E'{muhatap}\n\nAşağıda kimlik bilgileri yazılı {personel_ad}, {ise_giris} tarihinden itibaren kurumumuzda {gorev} görevinde {calisma_sekli} olarak çalışmaktadır.\n\nT.C. Kimlik No : {tc}\nSicil No       : {sicil}\nGörevi         : {gorev}\nİşe Giriş      : {ise_giris}\nSözleşme Türü  : {sozlesme_turu}\n\nİş bu belge, ilgilinin isteği üzerine {amac} için düzenlenmiş olup {tarih} tarihinde tarafına verilmiştir.',
   'Bu belge {kurum_unvan} tarafından düzenlenmiştir.'::varchar,
   'Yetkili İmza'::varchar, 'Varsayilan calisma belgesi (768)'::varchar),

  (2::smallint, 'tr', 'Maaş Yazısı', 'MAAŞ YAZISI',
   E'{muhatap}\n\n{personel_ad}, {ise_giris} tarihinden itibaren kurumumuzda {gorev} görevinde çalışmakta olup aylık {maas_turu} ücreti {maas} {para_birimi} tutarındadır.\n\nT.C. Kimlik No : {tc}\nSicil No       : {sicil}\nİşe Giriş      : {ise_giris}\n\nİş bu belge, ilgilinin isteği üzerine {amac} için düzenlenmiştir.',
   'Ücret bilgisi talep tarihi itibarıyladır.',
   'Yetkili İmza', 'Varsayilan maas yazisi (768) - {maas} zorunlu'),

  (3::smallint, 'tr', 'Vize Yazısı',
   'VİZE BAŞVURUSU İÇİN ÇALIŞMA VE İZİN YAZISI',
   E'{muhatap}\n\n{personel_ad} ({tc}), {ise_giris} tarihinden bu yana kurumumuzda {gorev} görevinde çalışmaktadır. Aylık {maas_turu} ücreti {maas} {para_birimi} tutarındadır.\n\nİlgilinin {amac} kapsamındaki seyahati tarafımızca uygun görülmüş olup, dönüşünde görevine devam edecektir.\n\nBilgilerinize arz ederiz.',
   'Bu yazı vize başvurusunda kullanılmak üzere düzenlenmiştir.',
   'Yetkili İmza', 'Varsayilan vize yazisi (768) - {maas} zorunlu'),

  (3::smallint, 'en', 'Visa Letter (EN)',
   'EMPLOYMENT AND LEAVE CONFIRMATION LETTER',
   E'{muhatap}\n\nThis is to certify that {personel_ad} (ID: {tc}) has been employed by our company as {gorev} since {ise_giris}. The monthly salary is {maas} {para_birimi}.\n\nThe employee has been granted leave for the purpose of {amac} and is expected to resume duties upon return. All travel expenses are borne by the employee.\n\nYours sincerely,',
   'Issued by {kurum_unvan} on {tarih}.',
   'Authorized Signature', 'Varsayilan ingilizce vize yazisi (768)'),

  (4::smallint, 'tr', 'SGK Hizmet Dökümü Üst Yazısı',
   'HİZMET DÖKÜMÜ ÜST YAZISI',
   E'{muhatap}\n\n{personel_ad} ({tc}) adına düzenlenen SGK hizmet dökümü ekte sunulmuştur. İlgili, {ise_giris} tarihinden itibaren {sgk_sicil} sicil numarasıyla işyerimizde {gorev} görevinde çalışmaktadır.\n\nBilgilerinize sunarız.',
   'Hizmet dökümünün kendisi SGK tarafından üretilir; bu yazı üst yazıdır.',
   'Yetkili İmza', 'Varsayilan SGK ust yazisi (768)'),

  (9::smallint, 'tr', 'Serbest Yazı', 'RESMÎ YAZI',
   E'{muhatap}\n\n{personel_ad} ({tc}) kurumumuzda {gorev} görevinde çalışmaktadır.\n\n{amac}\n\nBilgilerinize sunarız.',
   '', 'Yetkili İmza',
   'Serbest sablon (768): turu secilmemis/ozel talepler icin iskelet')
  ) as x(tur, dil, ad, baslik, govde, alt_not, imza_unvan, aciklama)
 where not exists (select 1 from public.belge_yazi_sablonu s
                    where s.tur = x.tur and s.dil = x.dil and s.sube_id = 0);

-- ---------------------------------------------------------------------- 4
--  YAZI ÜRETİCİSİ — TEK YAZAN
--
--  Metni üreten TEK yer burası. Uçta ikinci bir birleştirme yazılsaydı önizleme
--  ile dondurulan metin sessizce ayrışırdı.
--
--  Dönen `eksik`, şablonda geçen ama değeri BOŞ olan yer tutucuların listesi.
--  Uç bunu görünce hazırlamayı reddeder; ekran önizlemede uyarı basar. Boş bir
--  yer tutucuyu sessizce silmek, "Görevi :" satırı boş bir belge üretirdi -
--  kâğıda basılınca fark edilirdi, ekranda değil.
create or replace function public.fn_belge_talep_yazi(
        p_talep integer, p_sablon integer default null)
returns table (sablon_id integer, sablon_ad varchar, baslik text, govde text,
               alt_not text, imza_unvan varchar, eksik text[])
language plpgsql stable as $$
declare
    t          record;
    s          record;
    v_deger    jsonb;
    v_ham      text;
    v_eksik    text[] := '{}';
    v_anahtar  text;
    v_baslik   text;
    v_govde    text;
    v_alt      text;
    r          record;
begin
    select b.id, b.tur, b.amac, b.muhatap, b.talep_no, b.sube_id,
           b.maas_tutar, b.maas_turu,
           tr.unvan as personel_ad, coalesce(tr.vkno, '') as tc,
           coalesce(p.sicil_no, '')     as sicil,
           coalesce(p.gorev, '')        as gorev,
           p.ise_giris_tarihi, p.calisma_sekli, p.sozlesme_turu,
           coalesce(p.sgk_sicil_no, '') as sgk_sicil,
           coalesce(su.unvan, '')       as kurum_unvan,
           coalesce(su.adres, '')       as kurum_adres,
           coalesce(su.il, '')          as kurum_il,
           coalesce(su.ilce, '')        as kurum_ilce,
           coalesce(su.vkno, '')        as kurum_vkno,
           coalesce(su.vd, '')          as kurum_vd,
           coalesce(su.telefon, '')     as kurum_telefon
      into t
      from public.personel_belge_talep b
      join public.taraf tr              on tr.id = b.taraf_id
      left join public.taraf_personel p on p.id  = b.taraf_id
      left join public.sube su          on su.id = b.sube_id
     where b.id = p_talep;

    if not found then
        raise exception 'Belge talebi bulunamadi: %', p_talep using errcode = 'GK404';
    end if;

    -- ŞABLON SEÇİMİ: elle verilen > şubenin kendi şablonu > ortak (0) >
    --   aynı türün başka dili. Bulunamazsa serbest şablona (9) düşer -
    --   olmasaydı şablonu silinmiş bir türde yazı HİÇ üretilemezdi.
    select * into s from public.belge_yazi_sablonu
     where (p_sablon is not null and id = p_sablon)
        or (p_sablon is null and durum = 1 and tur = t.tur
            and sube_id in (0, t.sube_id))
     order by case when sube_id = t.sube_id then 0 else 1 end,
              case when dil = 'tr' then 0 else 1 end
     limit 1;

    if s.id is null then
        select * into s from public.belge_yazi_sablonu
         where durum = 1 and tur = 9 order by sube_id limit 1;
    end if;

    if s.id is null then
        raise exception 'Bu tur icin yazi sablonu tanimli degil.'
              using errcode = 'GK422';
    end if;

    v_deger := jsonb_build_object(
        'muhatap',      coalesce(nullif(trim(t.muhatap), ''),
                                 case when s.dil = 'en' then 'To Whom It May Concern,'
                                      else 'İlgili Makama,' end),
        'personel_ad',  coalesce(t.personel_ad, ''),
        'tc',           t.tc,
        'sicil',        t.sicil,
        'gorev',        t.gorev,
        'amac',         coalesce(t.amac, ''),
        'talep_no',     coalesce(t.talep_no, ''),
        'sgk_sicil',    t.sgk_sicil,
        'ise_giris',    coalesce(to_char(t.ise_giris_tarihi, 'DD.MM.YYYY'), ''),
        'tarih',        to_char(current_date, 'DD.MM.YYYY'),
        'calisma_sekli', case t.calisma_sekli when 1 then 'tam zamanlı'
                                              when 2 then 'yarı zamanlı'
                                              when 3 then 'primli' else '' end,
        'sozlesme_turu', case t.sozlesme_turu when 1 then 'Belirsiz Süreli'
                                              when 2 then 'Belirli Süreli'
                                              when 3 then 'Deneme Süreli'
                                              when 4 then 'Stajyer/Çırak'
                                              when 5 then 'Mevsimlik' else '' end,
        -- PARA BİÇİMİ TÜRKÇE (12.500,00). `G`/`D` kullanılmadı: onlar
        --   sunucunun `lc_numeric`ine bakıyor ve bu kurulumda İngilizce
        --   biçim veriyordu (68,500.00). Resmî yazıda para birimi yanlış
        --   ayrılmış bir sayı, tutarı okunamaz hâle getirir - ayırıcı
        --   literal yazılıp çevriliyor.
        --   "TL" şablonda yazılmaz; {para_birimi} kurum profilinden gelir.
        'maas',         case when t.maas_tutar is null then ''
                             else translate(trim(to_char(t.maas_tutar,
                                            'FM999,999,999.00')), ',.', '.,') end,
        'maas_turu',    case t.maas_turu when 1 then 'net' when 2 then 'brüt'
                                         else '' end,
        'para_birimi',  coalesce((select para_birimi from public.kurum_profil
                                   where sube_id = t.sube_id), 'TL'),
        'kurum_unvan',   t.kurum_unvan,
        'kurum_adres',   t.kurum_adres,
        'kurum_il',      t.kurum_il,
        'kurum_ilce',    t.kurum_ilce,
        'kurum_vkno',    t.kurum_vkno,
        'kurum_vd',      t.kurum_vd,
        'kurum_telefon', t.kurum_telefon);

    v_ham := s.baslik || E'\n' || s.govde || E'\n' || s.alt_not;

    -- EKSİKLERİ TOPLA: şablonda geçen her yer tutucu için değer var mı?
    --   Tanınmayan yer tutucu da eksiktir - şablonu yazan yanlış ad yazmış
    --   olabilir ve bunu sessizce yutmak, kâğıda `{maaas}` basardı.
    for v_anahtar in
        select distinct m[1] from regexp_matches(v_ham, '\{([a-z_]+)\}', 'g') m
    loop
        if coalesce(v_deger ->> v_anahtar, '') = '' then
            v_eksik := v_eksik || v_anahtar;
        end if;
    end loop;

    -- DEĞİŞTİRME: yalnız tanınan anahtarlar. Tanınmayan `{...}` metinde
    --   OLDUĞU GİBİ kalır - eksik listesinde zaten görünüyor, sessizce
    --   silmek onu gizlerdi.
    v_baslik := s.baslik;
    v_govde  := s.govde;
    v_alt    := s.alt_not;

    for r in select key, value from jsonb_each_text(v_deger) loop
        v_baslik := replace(v_baslik, '{' || r.key || '}', r.value);
        v_govde  := replace(v_govde,  '{' || r.key || '}', r.value);
        v_alt    := replace(v_alt,    '{' || r.key || '}', r.value);
    end loop;

    sablon_id  := s.id;
    sablon_ad  := s.ad;
    baslik     := v_baslik;
    govde      := v_govde;
    alt_not    := v_alt;
    imza_unvan := s.imza_unvan;
    eksik      := v_eksik;
    return next;
end $$;

comment on function public.fn_belge_talep_yazi is
  '768: belge talebi yazisini sablondan uretir. Metni ureten TEK yer. '
  'eksik[] = sablonda gecen ama degeri bos yer tutucular; uc bunlar varken '
  'hazirlamayi reddeder.';

-- ---------------------------------------------------------------------- 5
--  AYARLAR GRİDİNİN KAYNAĞI
create or replace view public.v_belge_yazi_sablonu as
select s.id,
       s.tur,
       case s.tur when 1 then 'Çalışma Belgesi'
                  when 2 then 'Maaş Yazısı'
                  when 3 then 'Vize Yazısı'
                  when 4 then 'SGK Hizmet Dökümü'
                  else 'Diğer' end        as tur_adi,
       s.dil,
       s.ad,
       s.baslik,
       s.sube_id,
       coalesce(su.ad, 'Tüm şubeler')     as sube_ad,
       s.durum,
       -- ŞABLONUN KULLANDIĞI YER TUTUCULAR: ayar ekranında satıra bakıp
       --   "bu şablon maaş istiyor mu" sorusu cevaplanabilsin.
       (select string_agg(distinct m[1], ', ')
          from regexp_matches(s.baslik || ' ' || s.govde || ' ' || s.alt_not,
                              '\{([a-z_]+)\}', 'g') m) as yer_tutucular,
       s.aciklama,
       s.ekleme_tarihi,
       s.degistirme_tarihi
  from public.belge_yazi_sablonu s
  left join public.sube su on su.id = s.sube_id and s.sube_id <> 0;

comment on view public.v_belge_yazi_sablonu is
  '768: Genel Ayarlar > Belge Yazilari gridi.';

-- ---------------------------------------------------------------------- 6
do $$
declare v_sablon int; v_talep int;
begin
    select count(*) into v_sablon from public.belge_yazi_sablonu;
    select count(*) into v_talep  from public.personel_belge_talep
     where durum in (4, 5) and coalesce(yazi_metin, '') = '';
    raise notice '768 tamam: % sablon. Metinsiz hazirlanmis/teslim talep: % '
                 '(gecmise donuk metin URETILMEDI - o kagitta ne yazdigini '
                 'bilmiyoruz).', v_sablon, v_talep;
end $$;
