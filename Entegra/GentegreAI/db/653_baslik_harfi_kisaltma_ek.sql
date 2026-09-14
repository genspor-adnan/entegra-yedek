-- =====================================================================
--  653_baslik_harfi_kisaltma_ek.sql
--  BAŞLIK HARFİ - kalan kısaltmalar, birimler ve "Ve/Veya".
--
--  651/652 sonrası hizmet adları tarandı; küçültülmemesi gereken üç
--  öbek kaldı:
--
--  1) TIBBİ KISALTMALAR - sesli harfi olmayan, tamamı büyük gelen
--     parçalar: "Gnrh" (GnRH), "Fgfr" (FGFR), "Tcr" (TCR), "Bcl",
--     "Myc", "Rsv", "Sbt", "Cdc"… Bunlar gen, reseptör ve yöntem
--     adları; küçültülünce okunmaz hale geliyor.
--
--  2) BİRİM ve ÖZEL YAZIM - "PH" pH'tır, "CM" cm, "MG" mg. Başlık
--     kuralı bunları "Ph/Cm/Mg" yapıyordu; üçü de yanlış.
--     "DNASE" -> DNase, "RNASE" -> RNase aynı sebeple.
--
--  3) "VE/VEYA" - bağlaç kontrolü KELİMENİN TAMAMINA bakıyordu;
--     eğik çizgiyle bitişik yazılınca ("REKTOSKOPİ VE/VEYA
--     SİGMOİDOSKOPİ") bağlaç sayılmıyor ve "Ve/Veya" çıkıyordu.
--     Kontrol artık parça düzeyinde de yapılır.
--
--  Hizmet adları yine 651 yedeğinden (orijinal SKRS metni) yeniden
--  türetilir - dönüşüm üst üste binmez.
-- =====================================================================

create or replace function public.fn_baslik_parca(p_parca text, p_ilk boolean default true)
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
        'RBC','RF','SC','TSH','WBC',
        -- 653: gen / reseptör / yöntem kısaltmaları (hizmet adlarından).
        'BCL','BCR','CDB','CDC','CDCD','CDW','CRH','DRB','DRG','DSR',
        'FGFR','GC','GNRH','HBC','IMRT','IVF','LC','LGG','LGM','LHRH',
        'MS','MYC','NPT','NTRK','PPT','RSV','SBT','SM','TCR','TDT',
        'TFCC','TRH'];
    -- Kısaltma ama büyük yazılmaz: birimler ve enzim adları.
    k_ozel_anahtar constant text[] := array[
        'IGA','IGD','IGE','IGG','IGM','PH','CM','MG','ML','MM','DNASE','RNASE'];
    k_ozel_karsilik constant text[] := array[
        'IgA','IgD','IgE','IgG','IgM','pH','cm','mg','ml','mm','DNase','RNase'];
    -- Başta değilse küçük: "Ve/Veya", "İle".
    k_kucuk constant text[] := array['VE','İLE','VEYA','VB','VS'];
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
    if not p_ilk and cekirdek = any(k_kucuk) then
        return lower(p_parca);
    end if;
    return public.fn_baslik_kelime(p_parca);
end $function$;

comment on function public.fn_baslik_parca(text, boolean) is
    'Baslik harfi: tek parca donusumu; p_ilk=false ise baglac kucultulur (653).';

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
    kalan     text;
    sonuc     text := '';
    i         integer;
    p         integer;
    ilkmi     boolean;
begin
    if p_metin is null or p_metin = '' then
        return p_metin;
    end if;
    if p_metin <> upper(p_metin) then
        return p_metin;                             -- elle dokunulmuş
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
            -- PARÇA PARÇA: "HLA-B27" -> "HLA" + "-" + "B27",
            --   "VE/VEYA" -> "ve" + "/" + "veya".
            parcali := '';
            kalan   := kelime;
            ilkmi   := (i = 1);
            loop
                p := coalesce(nullif(strpos(kalan, '-'), 0), 0);
                if p = 0 or (strpos(kalan, '/') > 0 and strpos(kalan, '/') < p) then
                    p := coalesce(nullif(strpos(kalan, '/'), 0), 0);
                end if;
                exit when p = 0;
                parcali := parcali
                        || public.fn_baslik_parca(substr(kalan, 1, p - 1), ilkmi)
                        || substr(kalan, p, 1);
                kalan := substr(kalan, p + 1);
                ilkmi := false;                     -- ilk parçadan sonrası
            end loop;
            kelime := parcali || public.fn_baslik_parca(kalan, ilkmi);
        end if;
        sonuc := case when i = 1 then kelime else sonuc || ' ' || kelime end;
    end loop;
    return sonuc;
end $function$;

-- Tek argümanlı eski imza artık kullanılmıyor; kalırsa iki sürüm yan yana
--   durur ve hangisinin çağrıldığı çağrı yerine göre değişirdi.
drop function if exists public.fn_baslik_parca(text);

-- ------------------------------------------------------------- dönüşüm
update public.hizmet h
   set ad = public.fn_baslik_harf(y.ad), degistirme_tarihi = now()
  from public._yedek_hizmet_ad_651 y
 where y.id = h.id
   and h.ad is distinct from public.fn_baslik_harf(y.ad);

do $kontrol$
begin
    raise notice '653 tamam: "Ve/Veya" kalan %, pH/cm/mg hatali kalan %',
        (select count(*) from public.hizmet where ad like '%Ve/Veya%'),
        (select count(*) from public.hizmet where ad ~ '\m(Ph|Cm|Mg|Ml)\M');
end $kontrol$;
