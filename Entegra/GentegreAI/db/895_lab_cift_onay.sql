-- =====================================================================
--  895_lab_cift_onay.sql
--  İKİ SEVİYELİ ONAY GERÇEKTEN İKİ SEVİYE OLSUN
--  (KTS denetim maddesi L4: "En az 2 seviye onay (teknik + klinik)
--   uygulanıyor mu?")
--
--  BUGÜN NE VAR: iki aşama tanımlı (`asama 1` teknik → `durum 2`,
--  `asama 2` uzman → `durum 3`) ve yetkileri ayrı (`lab.sonuc` /
--  `lab.onay`). İş listesinde "var, iş yok" yazıyordu.
--
--  BAKINCA ÜÇ DELİK ÇIKTI:
--    1. TEKNİK ONAY ATLANABİLİYOR. Uzman doğrudan 2. aşamayı yapabiliyor;
--       `durum < 3` olması yetiyor. "İki seviye" dediğimiz şey, ikincisinin
--       birincisini beklemesiyle iki seviye olur.
--    2. AYNI KİŞİ İKİ AŞAMAYI DA ONAYLAYABİLİYOR. Dört göz kuralı yok;
--       teknik onayı veren uzman aynı sonucu kendisi yayınlayabiliyor.
--    3. OTO-ONAY İKİ AŞAMAYI BİRDEN ATLIYOR (`durum = 3`). Çift onay
--       zorunluysa bu kuralı sessizce delerdi.
--
--  DAVRANIŞ VARSAYILAN OLARAK DEĞİŞMEZ. Çift onay zorunluluğu ve dört göz
--  kuralı AYARDIR: kurulu laboratuvarların akışını bir güncellemeyle
--  durdurmak, denetimden çok daha büyük bir zarardır. Kurum açar; kapalıyken
--  bugünkü davranış birebir sürer.
--
--  TETKİK BAZLI İSTİSNA: bazı testlerde çift onay şart (patoloji, genetik,
--  kan grubu), bazılarında gereksizdir (idrar pH). `lab_tetkik.cift_onay`
--  0 kurum ayarını izle · 1 zorunlu · 2 muaf.
-- =====================================================================

alter table public.lab_tetkik
  add column if not exists cift_onay smallint not null default 0;

comment on column public.lab_tetkik.cift_onay is
  '895: 0 kurum ayarini izle · 1 teknik onay ZORUNLU · 2 muaf (tek asama). '
  'Kan grubu/patoloji gibi testlerde 1, idrar pH gibi testlerde 2.';

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, 1, 'lab', v.aciklama
  from (values
    ('lab.cift_onay_zorunlu', '0',
     'Uzman onayı öncesi TEKNİK onay zorunlu mu (SKS: en az iki seviye). '
     || 'Kapalıyken uzman tek başına yayınlayabilir.'),
    ('lab.onay_ayni_kisi', '1',
     'Teknik onayı veren kişi aynı sonucu YAYINLAYABİLİR mi (dört göz '
     || 'kuralı). 0 = veremez.')
  ) as v(anahtar, deger, aciklama)
 on conflict (anahtar) do nothing;

/**
 * ONAY KONTROLÜ - tek karar noktası.
 *
 * Dönüş: durum 0 uygun · 2 engel, mesaj. Uygulama kodu ve ileride eklenecek
 * toplu onay yolları aynı fonksiyonu sorar; iki yerde ayrı yazılsaydı toplu
 * onay tek tek onayın kuralını delerdi.
 *
 * <b>Çift onay zorunluluğu TETKİKTE ezilebilir:</b> kurum ayarı genel
 * kuraldır, tetkik "zorunlu" ya da "muaf" diyebilir - kan grubu ile idrar
 * pH aynı özeni gerektirmiyor.
 */
create or replace function public.fn_lab_onay_kontrol(p_sonuc_id  bigint,
                                                      p_asama     smallint,
                                                      p_kullanici integer)
returns table(durum smallint, mesaj varchar)
language plpgsql stable as $fn$
declare
    r            record;
    v_kurum      boolean := coalesce((select deger from public.referans
                                       where anahtar = 'lab.cift_onay_zorunlu'), '0') = '1';
    v_ayni_kisi  boolean := coalesce((select deger from public.referans
                                       where anahtar = 'lab.onay_ayni_kisi'), '1') = '1';
    v_zorunlu    boolean;
begin
    select s.id, s.durum, s.teknik_onay_id, s.teknik_onay_zamani, s.onay_id,
           t.cift_onay, t.ad as tetkik
      into r
      from public.lab_sonuc s
      join public.lab_tetkik t on t.id = s.tetkik_id
     where s.id = p_sonuc_id;

    if r.id is null then
        return query select 2::smallint, 'Sonuç bulunamadı.'::varchar;
        return;
    end if;

    -- TETKİK KURUM AYARINI EZER: 1 zorunlu, 2 muaf, 0 = kuruma bak.
    v_zorunlu := case r.cift_onay when 1 then true
                                  when 2 then false
                                  else v_kurum end;

    if p_asama = 1 then
        if r.teknik_onay_id is not null then
            return query select 2::smallint,
                   'Bu sonuç zaten teknik onaylı.'::varchar;
            return;
        end if;
        return query select 0::smallint, ''::varchar;
        return;
    end if;

    -- UZMAN ONAYI (asama 2).
    if v_zorunlu and r.teknik_onay_id is null then
        return query select 2::smallint,
               ('Önce TEKNİK onay gerekiyor - ' || r.tetkik
                || ' iki seviyeli onaya tabi.')::varchar;
        return;
    end if;

    -- DÖRT GÖZ: teknik onayı veren kişi aynı sonucu yayınlayamaz. Kural
    --   yalnız teknik onay VARSA anlamlıdır; yoksa karşılaştıracak kimse
    --   yok demektir.
    if not v_ayni_kisi and r.teknik_onay_id is not null
       and r.teknik_onay_id = p_kullanici then
        return query select 2::smallint,
               ('Teknik onayı siz verdiniz; yayın onayını başka bir '
                || 'kullanıcı vermeli (dört göz kuralı).')::varchar;
        return;
    end if;

    return query select 0::smallint, ''::varchar;
end $fn$;

comment on function public.fn_lab_onay_kontrol(bigint, smallint, integer) is
  '895: onay kurallari (KTS L4) - teknik onay zorunlulugu ve dort goz '
  'kurali. Tetkik ayari kurum ayarini ezer; ikisi de kapaliyken davranis '
  'degismez.';

-- ÇİFT ONAYA TABİ TETKİKLER: denetimde "hangi testlerde iki seviye"
--   sorusunun cevabı, kurumun kendi dökümü.
create or replace view public.v_lab_cift_onay as
select t.id as tetkik_id, t.kod, t.ad, t.bolum, t.cift_onay,
       case t.cift_onay when 1 then true when 2 then false
            else coalesce((select deger from public.referans
                            where anahtar = 'lab.cift_onay_zorunlu'), '0') = '1'
       end as zorunlu,
       t.oto_onay
  from public.lab_tetkik t
 where t.durum = 0;

comment on view public.v_lab_cift_onay is
  '895: tetkik basina iki seviyeli onay durumu (kurum ayari + tetkik '
  'istisnasi) ve oto-onay bayragi.';

do $$
begin
    raise notice '895 tamam: cift onay kurum ayari = %, dort goz = %',
        (select deger from public.referans where anahtar = 'lab.cift_onay_zorunlu'),
        (select case when deger = '0' then 'acik' else 'kapali' end
           from public.referans where anahtar = 'lab.onay_ayni_kisi');
end $$;
