-- ============================================================================
--  Gentegre AI — BELGE TALEBİ YAZISI PARA BİÇİMİNİ ORTAK YARDIMCIYA BAĞLIYOR
--  770_belge_talep_yazisi_para_bicimi.sql
--
--  Kullanıcı: "768'i de fn_para_tr'ye bağla".
--
--  769 Türkçe sayı biçimini `fn_para_tr`ye topladı ama 768'deki
--  `fn_belge_talep_yazi` kendi satır içi kopyasını taşımaya devam ediyordu.
--  İkisi de BUGÜN doğru sonuç veriyor; sorun sonrası: biçim bir daha
--  değişirse (ör. binlik ayıracı olmayan bir kurum isteği) biri güncellenir
--  öteki unutulur ve maaş yazısı ile e-Belge önizlemesi aynı tutarı farklı
--  yazar. Aynı olması gereken iki şeyin iki yerde tanımlı olması, farkın
--  ortaya çıkmasını zaman meselesine çevirir.
--
--  DAVRANIŞ DEĞİŞMİYOR: `fn_para_tr` NULL girdide BOŞ metin döndürür -
--  satır içi hâli de öyleydi ve `eksik` listesi boş `{maas}`ı yakalamaya
--  devam eder. Fonksiyonun geri kalanı 768'den AYNEN alındı; tek fark bu
--  tek ifade.
--
--  768 bir göçtür, düzenlenmez: yeniden tanımlama burada.
-- ============================================================================
\set ON_ERROR_STOP on

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
        -- PARA BİÇİMİ TEK YERDEN (770): `fn_para_tr`. 768'de aynı biçim
        --   burada satır içi yazılmıştı; bir biçimin iki kopyası, birinin
        --   sessizce sapması demektir. NULL zaten BOŞ metin döner ve eksik
        --   listesi onu yakalar - davranış aynı, yazan tek.
        --   "TL" şablonda yazılmaz; {para_birimi} kurum profilinden gelir.
        'maas',         public.fn_para_tr(t.maas_tutar),
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
  '768/770: belge talebi yazisini sablondan uretir. Metni ureten TEK yer. '
  'eksik[] = sablonda gecen ama degeri bos yer tutucular; uc bunlar varken '
  'hazirlamayi reddeder. Para bicimi fn_para_tr''den (769).';

do $$
declare v_ornek text;
begin
    -- Yardimciya baglandiktan sonra da ayni bicim: 68.500,00
    select public.fn_para_tr(68500) into v_ornek;
    raise notice '770 tamam: fn_belge_talep_yazi para bicimi fn_para_tr''de. '
                 'Ornek: %', v_ornek;
end $$;
