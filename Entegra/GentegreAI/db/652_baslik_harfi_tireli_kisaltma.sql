-- =====================================================================
--  652_baslik_harfi_tireli_kisaltma.sql
--  TİRELİ/EĞİK ÇİZGİLİ BİLEŞİKTE KISALTMA KAÇIYORDU.
--
--  `fn_baslik_harf` kısaltmayı KELİMENİN TAMAMINA bakarak tanıyordu:
--  "HLA-B27" kelimesinin harf çekirdeği "HLAB" olur, listede yoktur ve
--  kelime küçültülür - "Hla-B27". Aynı şey "HCV-RNA", "T3/T4",
--  "IGG/IGM" gibi tetkik adlarında da oluyor; bunlar laboratuvar
--  adlarının büyük bölümü.
--
--  ÇÖZÜM: kelime önce '-' ve '/' ayraçlarından PARÇALARA ayrılır, her
--  parça kendi başına değerlendirilir (kısaltma mı, özel yazım mı,
--  sıradan kelime mi), sonra ayraçlarıyla geri birleştirilir.
--  Ayraçlar korunur; "By-Pass" gibi sıradan bileşikler aynı kalır.
--
--  HİZMET ADLARI YENİDEN TÜRETİLİR: 651 çalıştıktan sonra adlar artık
--  karışık yazılı ve fonksiyon (doğru olarak) karışık metne dokunmuyor.
--  Bu yüzden kaynak olarak 651'in YEDEĞİ kullanılır - dönüşüm hep
--  orijinal SKRS metninden yapılır, üst üste binmez.
-- =====================================================================

create or replace function public.fn_baslik_parca(p_parca text)
returns text
language plpgsql
stable
as $function$
declare
    k_kisaltma constant text[] := array[
        'AB','ADSL','AFAD','AMATEM','AŞ','BT','CHF','CNC','CRM','ÇEMATEM',
        'DDY','EEG','EKG','ERP','EUR','GBP','GN','GSS','İK','İNŞ','İŞL',
        'KDV','KGM','KVC','KWH','LTD','LTR','MHRS','MR','MTR','MÜH','ORG',
        'OSB','ÖSS','PC','POS','PVC','RH','SAN','SGK','SMS','SSK','SUT',
        'ŞTİ','TIR','TİC','TİKA','TL','TTB','TV','USD','USG','XL','XXL',
        'YRD',
        'ARGE','CD','CEO','DEXA','DVD','HUV','ICD','ICF','İV','SKT',
        'II','III','IV','VI','VII','VIII','IX','XI','XII',
        'BTA','EMG','ERCP','MRCP','MRG','NST','PET','SPECT','TEE','TTE','US',
        'PTCA','CABG','PAP','PPD','OGTT','RFT','ELISA','FISH','PCR',
        'ASD','VSD','PDA','BOS','IMA','TC',
        'CMV','EBV','HBV','HCV','HIV','HPV','TBC','TPHA','VDRL',
        'ACTH','AFP','APTT','ASO','AST','ANCA','CEA','CRP','DNA','RNA',
        'FSH','GGT','HB','HCG','HCT','HDL','HLA','LDL','LH','PSA','PT',
        'RBC','RF','SC','TSH','WBC'];
    k_ozel_anahtar  constant text[] := array['IGA','IGD','IGE','IGG','IGM'];
    k_ozel_karsilik constant text[] := array['IgA','IgD','IgE','IgG','IgM'];
    cekirdek text;
    j        integer;
begin
    cekirdek := regexp_replace(p_parca, '[^[:alpha:]]', '', 'g');
    if cekirdek = '' then
        return p_parca;                             -- sayı / noktalama
    end if;
    j := coalesce(array_position(k_ozel_anahtar, cekirdek), 0);
    if j > 0 then
        return replace(p_parca, cekirdek, k_ozel_karsilik[j]);
    end if;
    if cekirdek = any(k_kisaltma) then
        return p_parca;                             -- kısaltma
    end if;
    return public.fn_baslik_kelime(p_parca);
end $function$;

comment on function public.fn_baslik_parca(text) is
    'Baslik harfi: tek parca (tire/egik cizgi arasi) donusumu (652).';

create or replace function public.fn_baslik_harf(p_metin text)
returns text
language plpgsql
stable
as $function$
declare
    k_kucuk constant text[] := array['VE','İLE','VEYA','VB','VS'];
    k_ifade_anahtar constant text[] := array[
        'AĞIZ, DIŞ VE ÇENE', 'DIŞ HEKIMLIĞI', 'GENEL DIŞ', 'DIŞ TEDAVISI',
        'VE SINIR CERRAHISI'];
    k_ifade_karsilik constant text[] := array[
        'AĞIZ, DİŞ VE ÇENE', 'DİŞ HEKIMLIĞI', 'GENEL DİŞ', 'DİŞ TEDAVISI',
        'VE SİNİR CERRAHISI'];
    kelimeler text[];
    kelime    text;
    cekirdek  text;
    parcali   text;
    parca     text;
    ayrac     text;
    kalan     text;
    sonuc     text := '';
    i         integer;
    p         integer;
begin
    if p_metin is null or p_metin = '' then
        return p_metin;
    end if;
    -- Küçük harf varsa metne elle dokunulmuş demektir; olduğu gibi kalır.
    if p_metin <> upper(p_metin) then
        return p_metin;
    end if;

    for i in 1 .. coalesce(array_length(k_ifade_anahtar, 1), 0) loop
        p_metin := replace(p_metin, k_ifade_anahtar[i], k_ifade_karsilik[i]);
    end loop;

    kelimeler := regexp_split_to_array(p_metin, ' ');
    for i in 1 .. coalesce(array_length(kelimeler, 1), 0) loop
        kelime   := kelimeler[i];
        cekirdek := regexp_replace(kelime, '[^[:alpha:]]', '', 'g');

        if cekirdek = '' then
            null;                                   -- sayı / noktalama
        elsif i > 1 and cekirdek = any(k_kucuk) then
            kelime := lower(kelime);
        else
            -- PARÇA PARÇA: "HLA-B27" -> "HLA" + "-" + "B27". Ayraç
            --   korunur, her parça kendi kuralıyla dönüşür.
            parcali := '';
            kalan   := kelime;
            loop
                p := coalesce(nullif(strpos(kalan, '-'), 0), 0);
                if p = 0 or (strpos(kalan, '/') > 0 and strpos(kalan, '/') < p) then
                    p := coalesce(nullif(strpos(kalan, '/'), 0), 0);
                end if;
                exit when p = 0;
                parca   := substr(kalan, 1, p - 1);
                ayrac   := substr(kalan, p, 1);
                parcali := parcali || public.fn_baslik_parca(parca) || ayrac;
                kalan   := substr(kalan, p + 1);
            end loop;
            kelime := parcali || public.fn_baslik_parca(kalan);
        end if;
        sonuc := case when i = 1 then kelime else sonuc || ' ' || kelime end;
    end loop;
    return sonuc;
end $function$;

-- ------------------------------------------------------------- dönüşüm
--  Kaynak 651'in yedeği: orijinal (tamamı büyük) SKRS metni. Adı elle
--  düzeltilmiş hizmet zaten yedekte tamamı büyük değildir - dolayısıyla
--  kullanıcının düzeltmesi geri gelmez.
update public.hizmet h
   set ad = public.fn_baslik_harf(y.ad), degistirme_tarihi = now()
  from public._yedek_hizmet_ad_651 y
 where y.id = h.id
   and h.ad is distinct from public.fn_baslik_harf(y.ad);

do $kontrol$
begin
    raise notice '652 tamam: tireli/egik cizgili duzeltilen %',
        (select count(*) from public.hizmet
          where ad ~ '(Hla|Hcv|Hbv|Igg|Ige|Igm|Dna|Rna|Bos)-');
end $kontrol$;
