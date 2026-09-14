-- =====================================================================
--  651_hizmet_adi_baslik_harfi.sql
--  HİZMET ADLARI BAŞLIK HARFİNE (kullanıcı: "hizmet listesini de ilk harf
--  büyük diğerleri küçük yap").
--
--  Katalog SKRS/SUT'tan geldiği için adlar TAMAMI BÜYÜK: "APSE VEYA
--  HEMATOM DRENAJI, YÜZEYEL". 630'da kod listeleri için yazılan
--  `fn_baslik_harf` burada da kullanılır - tek bir Türkçe başlık kuralı.
--
--  ÖNCE FONKSİYON GENİŞLETİLİR: kod listelerinde geçmeyen ama hizmet
--  adlarında sık geçen TIBBİ KISALTMALAR var. Genel kural onları da
--  küçültürdü: "IGE ANTİKORU" -> "Ige Antikoru", "BOS" (beyin omurilik
--  sıvısı) -> "Bos", "DNA" -> "Dna". Kısaltma listesi bu yüzden
--  büyütülür ve immünoglobulinler için ÖZEL YAZIM eklenir (IgE, IgG…) -
--  tıpta okunuşu budur, tamamı büyük yazmak da yanlıştır.
--
--  LİSTEYE GİRMEYENLER, bilerek: "ALT" (hem enzim hem "alt ekstremite"),
--  "ANA" (hem antinükleer antikor hem "ana arter"), "PO", "DA", "VAR",
--  "TEST" gibi sıradan kelimeyle çakışanlar. Kısaltmayı korumak için
--  sıradan metni bozmak kötü takas.
--
--  KARIŞIK YAZILMIŞ AD KORUNUR: `fn_baslik_harf` metinde küçük harf
--  görürse dokunmaz - kurumun elle düzelttiği ad geri bozulmasın.
--
--  YEDEK: `_yedek_hizmet_ad_651` (kod + eski ad). Dönüşüm beğenilmezse
--  tek update ile geri alınır.
-- =====================================================================

create or replace function public.fn_baslik_harf(p_metin text)
returns text
language plpgsql
stable
as $function$
declare
    -- OLDUĞU GİBİ KALIR. Listeye ancak veride GERÇEKTEN geçen ve gerçek
    --   Türkçe kelimeyle çakışmayan kısaltma girer: "ADET" (adet), "ARK"
    --   (ark) gibi sözcükler bilerek DIŞARIDA - onları korumak "1 ADET"
    --   gibi sıradan metni bozardı. "TIP"/"TIBBİ" de kısaltma değil.
    k_kisaltma constant text[] := array[
        'AB','ADSL','AFAD','AMATEM','AŞ','BT','CHF','CNC','CRM','ÇEMATEM',
        'DDY','EEG','EKG','ERP','EUR','GBP','GN','GSS','İK','İNŞ','İŞL',
        'KDV','KGM','KVC','KWH','LTD','LTR','MHRS','MR','MTR','MÜH','ORG',
        'OSB','ÖSS','PC','POS','PVC','RH','SAN','SGK','SMS','SSK','SUT',
        'ŞTİ','TIR','TİC','TİKA','TL','TTB','TV','USD','USG','XL','XXL',
        'YRD',
        -- Ölçüm/işlem kısaltmaları ve unvanlar
        'ARGE','CD','CEO','DEXA','DVD','HUV','ICD','ICF','İV','SKT',
        -- Roma rakamı: "EVRE III", "TİP II". Tek harfliler (I, V, X, C,
        --   L, D, M) alınmadı - kelime olma ihtimalleri var.
        'II','III','IV','VI','VII','VIII','IX','XI','XII',
        -- TIBBİ KISALTMALAR (651): hizmet/tetkik adlarında geçenler.
        --   Görüntüleme ve işlem
        'BTA','EMG','ERCP','MRCP','MRG','NST','PET','SPECT','TEE','TTE','US',
        'PTCA','CABG','PAP','PPD','OGTT','RFT','ELISA','FISH','PCR',
        --   Anatomi/patoloji kısaltmaları
        'ASD','VSD','PDA','BOS','IMA','TC',
        --   Viroloji / mikrobiyoloji
        'CMV','EBV','HBV','HCV','HIV','HPV','TBC','TPHA','VDRL',
        --   Biyokimya / hematoloji / immünoloji
        'ACTH','AFP','APTT','ASO','AST','ANCA','CEA','CRP','DNA','RNA',
        'FSH','GGT','HB','HCG','HCT','HDL','HLA','LDL','LH','PSA','PT',
        'RBC','RF','SC','TSH','WBC'];

    -- ÖZEL YAZIM: kısaltma ama TAMAMI BÜYÜK de değil. İmmünoglobulinler
    --   tıpta "IgE / IgG / IgM / IgA / IgD" yazılır; ne "IGE" ne "Ige"
    --   doğrudur.
    k_ozel_anahtar constant text[] := array['IGA','IGD','IGE','IGG','IGM'];
    k_ozel_karsilik constant text[] := array['IgA','IgD','IgE','IgG','IgM'];

    -- BAŞTA DEĞİLSE KÜÇÜK: Türkçe başlık yazımında bağlaç küçüktür -
    --   "Kadın Hastalıkları ve Doğum".
    k_kucuk constant text[] := array['VE','İLE','VEYA','VB','VS'];

    -- BAĞLAMA GÖRE OKUNAN KELİMELER. "DIŞ" kliniklerde DİŞ (ağızdaki),
    --   başka listede dış (haricî); "SINIR" beyin cerrahisinde SİNİR,
    --   meslek listesinde sınır (hudut). Kelime tek başına yetmiyor, o
    --   yüzden düzeltme İFADE düzeyinde - yalnız bu tamlamalarda.
    k_ifade_anahtar constant text[] := array[
        'AĞIZ, DIŞ VE ÇENE', 'DIŞ HEKIMLIĞI', 'GENEL DIŞ', 'DIŞ TEDAVISI',
        'VE SINIR CERRAHISI'];
    k_ifade_karsilik constant text[] := array[
        'AĞIZ, DİŞ VE ÇENE', 'DİŞ HEKIMLIĞI', 'GENEL DİŞ', 'DİŞ TEDAVISI',
        'VE SİNİR CERRAHISI'];

    kelimeler text[];
    kelime    text;
    cekirdek  text;
    sonuc     text := '';
    i         integer;
    j         integer;
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
        j := coalesce(array_position(k_ozel_anahtar, cekirdek), 0);
        if cekirdek = '' then
            null;                                   -- sayı / noktalama
        elsif j > 0 then
            -- Noktalama korunur: "(IGE)" -> "(IgE)".
            kelime := replace(kelime, cekirdek, k_ozel_karsilik[j]);
        elsif cekirdek = any(k_kisaltma) then
            null;                                   -- kısaltma
        elsif i > 1 and cekirdek = any(k_kucuk) then
            kelime := lower(kelime);
        else
            kelime := public.fn_baslik_kelime(kelime);
        end if;
        sonuc := case when i = 1 then kelime else sonuc || ' ' || kelime end;
    end loop;
    return sonuc;
end $function$;

-- ---------------------------------------------------------------- yedek
drop table if exists public._yedek_hizmet_ad_651;
create table public._yedek_hizmet_ad_651 as
select id, kod, ad from public.hizmet where ad = upper(ad);

-- -------------------------------------------------------------- dönüşüm
--  Yalnız TAMAMI BÜYÜK adlar. `fn_baslik_harf` de aynı kontrolü yapıyor;
--  burada da süzmek gereksiz satır güncellemesini (ve degistirme_tarihi
--  kirlenmesini) önler.
update public.hizmet h
   set ad = public.fn_baslik_harf(h.ad), degistirme_tarihi = now()
 where h.ad = upper(h.ad)
   and public.fn_baslik_harf(h.ad) is distinct from h.ad;

-- Kısa ad da aynı katalogdan geliyor.
update public.hizmet h
   set kisa_ad = public.fn_baslik_harf(h.kisa_ad), degistirme_tarihi = now()
 where coalesce(h.kisa_ad, '') <> ''
   and h.kisa_ad = upper(h.kisa_ad)
   and public.fn_baslik_harf(h.kisa_ad) is distinct from h.kisa_ad;

do $kontrol$
begin
    raise notice '651 tamam: donusen hizmet %, hala tamami buyuk %',
        (select count(*) from public._yedek_hizmet_ad_651 y
           join public.hizmet h on h.id = y.id and h.ad <> y.ad),
        (select count(*) from public.hizmet where ad = upper(ad));
end $kontrol$;
