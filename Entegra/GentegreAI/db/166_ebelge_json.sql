-- ============================================================================
--  Gentegre AI — e-BELGE GONDERIM GOVDESI: IZIBIZ ADAPTORU
--  166_ebelge_json.sql
--
--  Kullanici: "firma bilgilerini ekle, sonra json ureticiyi yaz." +
--             "sadece izibiz ile degil baska entegrator ile de calisabiliriz."
--
--  BU DOSYA TEK BIR ENTEGRATORUN (izibiz) GOVDESINI uretir. Entegrator SECIMI
--  ve dagitim 167'de: `fn_ebelge_gonderim_govdesi` secili entegratorun kendi
--  uretecini cagirir. Yeni entegrator = yeni `fn_ebelge_govde_<kod>` + katalog
--  satiri; buraya ya da dagiticiya DOKUNULMAZ.
--
--  ENTEGRATORDEN BAGIMSIZ OLAN (167'de ortak): gonderim on-dogrulamalari -
--  firma bilgisi, alici VKN'si, kalem/tutar, senaryo destegi. Bunlar GIB
--  kurali, entegrator kurali degil; her adaptorde tekrarlanmaz.
--
--  KAYNAK: Delphi `_IzibizJSONOlustur` (UEBelgeOlusturucu.pas:5088). Anahtar
--  adlari, sarma duzeni ve sayisal kurallar ORADAN birebir alindi - izibiz
--  yanlis anahtari sessizce yok sayar, sonra GIB sematronu reddeder. Bu yuzden
--  "daha temiz" isimlendirme YAPILMADI.
--
--  NEDEN SQL: uretilecek sey tamamen veriden turuyor (belge + satirlar + iki
--  taraf + XSLT). C#'ta yazmak ayni veriyi 5-6 sorguyla cekip elde birlestirmek
--  olurdu; burada tek cagri, tek islem, ve gonderim disinda ONIZLEME de ayni
--  fonksiyonu cagirir - iki farkli "gercek" olusmaz.
--
--  DELPHI'DE OLUP BURADA OLMAYAN (bizde veri karsiligi yok):
--    ihracat/gumruk, KAMU odeme hesabi, SGK donem/referanslari,
--    ilac-tibbi cihaz kimlikleri, sofor/tasiyici detaylari.
--  TEVKIFAT, KDV ISTISNASI ve IADE REFERANSI 176'da eklendi.
--  Bunlarin hepsi ILGILI SENARYODA devreye girer; senaryo secilirse fonksiyon
--  bugun sessizce eksik JSON uretmesin diye ACIK HATA verir (asagida).
--
--  PARA BIRIMI: JSON belge dovizinde uretilir (TL -> 'TRY'). Tutarlar
--  `belge_satir.doviz_tutari` degil `tutar` uzerinden gider; dovizli belgede
--  satir tutari zaten belge dovizindedir (fn_belge_diptoplam ile ayni kaynak).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------ yardimci: kimlik ----
-- 10 hane = VKN (tuzel), 11 hane = TCKN (gercek kisi). izibiz bunu uzunluktan
--   tahmin edebiliyor ama acik gondermek zorunlu (e-Irsaliyede tahmin etmiyor).
create or replace function public.fn_ebelge_kimlik_semasi(p_vkno text)
returns text language sql immutable as $$
    select case when length(regexp_replace(coalesce(p_vkno, ''), '\D', '', 'g')) = 11
                then 'TCKN' else 'VKN' end
$$;

-- Gercek kisi alicida ad/soyad ayrilir: SON kelime soyad, oncesi ad
--   ("Mehmet Ali Ay" -> "Mehmet Ali" + "Ay"), Delphi KisiAdSoyadAyir ile ayni.
create or replace function public.fn_ad_soyad_ayir(p_unvan text)
returns table (ad text, soyad text) language sql immutable as $$
    select case when position(' ' in btrim(coalesce(p_unvan, ''))) = 0
                then btrim(coalesce(p_unvan, ''))
                else btrim(regexp_replace(btrim(p_unvan), '\s+\S+$', '')) end,
           case when position(' ' in btrim(coalesce(p_unvan, ''))) = 0
                then ''
                else regexp_replace(btrim(p_unvan), '^.*\s+', '') end
$$;

-- Birim kodu -> UN/ECE Rec.20. Delphi'deki CASE (UEBelgeOlusturucu.pas:274) ile
--   birebir; tanimsiz birim C62 (adet) sayilir - GIB bos birim kabul etmez.
create or replace function public.fn_ebelge_birim_kodu(p_birim smallint)
returns text language sql immutable as $$
    select case p_birim
             when 10 then 'MIN' when 11 then 'HUR' when 12 then 'DAY'
             when 51 then 'C62' when 52 then 'MTR' when 53 then 'CS'
             when 54 then 'SET' when 55 then 'SET' when 56 then 'BX'
             when 57 then 'KGM' when 58 then 'MTK' when 59 then 'PF'
             else 'C62' end
$$;

-- Para birimi -> ISO 4217. Bizde yerel para "TL" saklanir, GIB "TRY" ister.
create or replace function public.fn_ebelge_para_kodu(p_doviz text)
returns text language sql immutable as $$
    select case upper(btrim(coalesce(p_doviz, '')))
             when '' then 'TRY' when 'TL' then 'TRY' when '₺' then 'TRY'
             when '$' then 'USD' when '€' then 'EUR' when '£' then 'GBP'
             else upper(btrim(p_doviz)) end
$$;

-- ------------------------------------------------------------- ana uretici --
drop function if exists public.fn_ebelge_json_uret(integer);
drop function if exists public.fn_ebelge_govde_izibiz(integer);

create function public.fn_ebelge_govde_izibiz(p_belge_id integer)
returns jsonb
language plpgsql stable as $$
declare
    b            record;
    g            record;   -- gonderici (v_ebelge_gonderici)
    v_tur        smallint; -- 1 e-Fatura · 2 e-Arsiv · 7 e-Irsaliye
    v_arsiv      boolean;
    v_irsaliye   boolean;
    v_profil     text;
    v_belge_tipi text;
    v_para       text;
    v_uuid       text;
    v_xslt       text;
    v_notlar     jsonb := '[]'::jsonb;
    v_ek_ref     jsonb := '[]'::jsonb;
    v_satirlar   jsonb;
    v_vergi      jsonb;
    v_toplam     jsonb;
    v_supplier   jsonb;
    v_customer   jsonb;
    v_content    jsonb;
    v_kok        jsonb;
    v_matrah     numeric := 0;   -- NET (iskonto sonrasi) toplam
    v_kdv        numeric := 0;
    v_iskonto    numeric := 0;
    v_tevkifat   numeric := 0;
    v_tevk_alt   jsonb;
    v_iade_ref   jsonb;
    v_mail       text;
    sv           record;   -- sevkiyat (177)
begin
    select bl.*, e.id as e_belge_id, e.belge_turu as e_tur, e.belge_no as e_no,
           e.uuid as e_uuid, e.alici_alias, e.gonderici_alias,
           t.eposta as taraf_eposta, t.telefon as taraf_telefon
      into b
      from public.belge bl
      join public.e_belge e on e.belge_id = bl.id
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id
     order by e.id desc
     limit 1;

    if not found then
        raise exception 'Belge için hazırlanmış e-Belge yok (%). Önce "e-Fatura Hazırla" çalıştırın.', p_belge_id;
    end if;

    v_tur      := b.e_tur;
    v_arsiv    := v_tur = 2;
    v_irsaliye := v_tur = 7;

    -- ORTAK on-dogrulama (167): firma bilgisi, alici kimligi, kalem/tutar,
    --   desteklenen senaryo. Entegratorden bagimsiz oldugu icin her adaptorde
    --   tekrarlanmaz; adaptor yalniz BICIMLENDIRIR.
    perform public.fn_ebelge_gonderim_dogrula(p_belge_id);

    select * into g from public.v_ebelge_gonderici
     where sube_id = coalesce(nullif(b.sube_id, 0), (select min(id) from public.sube));

    -- Sevkiyat bilgileri ayri tabloda (177); kaydi olmayan belgede gorunum bos
    --   deger dondurur, dolayisiyla ek kontrol gerekmiyor.
    select * into sv from public.v_belge_sevkiyat where belge_id = p_belge_id;

    v_para := public.fn_ebelge_para_kodu(coalesce(nullif(b.belge_dovizi, ''), b.doviz_cinsi));
    v_uuid := coalesce(nullif(btrim(b.e_uuid), ''), gen_random_uuid()::text);

    -- PROFIL ve BELGE TIPI (Delphi SenaryoProfilKodu / FaturaTipKodu).
    v_profil := case
                    when v_irsaliye then 'TEMELIRSALIYE'
                    when v_arsiv    then 'EARSIVFATURA'
                    when coalesce(b.senaryo, 0) = 2 then 'TICARIFATURA'
                    else 'TEMELFATURA' end;
    -- Delphi FaturaTipKodu ile ayni esleme; tevkifatli faturada belge tipi
    --   TEVKIFAT olmali, yoksa GIB "tevkifat var ama tip SATIS" der.
    v_belge_tipi := case
                        when v_irsaliye then 'SEVK'
                        when coalesce(b.tipi, 0) = 2 then 'IADE'
                        when coalesce(b.tipi, 0) = 22 then 'TEVKIFAT'
                        when coalesce(b.tipi, 0) = 24 then 'ISTISNA'
                        when coalesce(b.tipi, 0) = 9 then 'IHRACKAYITLI'
                        when coalesce(b.tipi, 0) = 25 then 'SGK'
                        else 'SATIS' end;

    -- ------------------------------------------------------------ satirlar --
    -- Satir tutari NET'tir (iskonto dusulmus); GIB satirda net ister, iskontoyu
    --   ayri `allowanceCharge` olarak gormek ister. Iskonto tutari brutten
    --   turetilir: brut = miktar * birim fiyat.
    with s as (
        select bs.*,
               round(bs.miktar * bs.birim_fiyat, 2)                       as brut,
               round(bs.miktar * bs.birim_fiyat, 2) - bs.tutar            as isk_tutar,
               round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)           as kdv_tutar,
               -- TEVKIFAT: KDV'nin bir kismi alicida kalir. Oran KODDAN gelir -
               --   elle girilen oran koda uymazsa GIB sematronu reddeder (176).
               coalesce(nullif(bs.tevkifat_orani, 0),
                        public.fn_tevkifat_orani(bs.tevkifat_kodu))          as tevk_oran,
               round(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)
                     * coalesce(nullif(bs.tevkifat_orani, 0),
                                public.fn_tevkifat_orani(bs.tevkifat_kodu)) / 100.0, 2)
                                                                             as tevk_tutar,
               btrim(coalesce(bs.tevkifat_kodu, ''))                         as tevk_kod,
               -- Satir NUMARASI burada uretilir: jsonb_agg icinde pencere
               --   fonksiyonu cagrilamiyor (toplama + pencere ayni ifadede yasak).
               row_number() over (order by bs.sira, bs.id)                 as satir_no
          from public.belge_satir bs
         where bs.belge_id = p_belge_id
         order by bs.sira, bs.id
    )
    select jsonb_agg(
             (jsonb_build_object(
                'id',                  s.satir_no,
                'quantity',            s.miktar,
                'unitCode',            public.fn_ebelge_birim_kodu(s.birim),
                'lineExtensionAmount', s.tutar,
                'itemName',            coalesce(nullif(btrim(s.aciklama), ''), 'Ürün'),
                'itemPrice',           s.birim_fiyat)
              -- Satir iskontosu: multiplierFactorNumeric KESIRDIR (0.15), yuzde
              --   degil - izibiz base * mfn = amount dogrulamasi yapiyor.
              || case when s.isk_tutar > 0.0001 and not v_irsaliye then
                     jsonb_build_object('allowanceCharge', jsonb_build_array(jsonb_build_object(
                         'chargeIndicator', false,
                         'reason', 'İskonto',
                         'multiplierFactorNumeric', round(s.isk_tutar / nullif(s.brut, 0), 6),
                         'amount', round(s.isk_tutar, 2),
                         'baseAmount', s.brut)))
                 else '{}'::jsonb end
              -- e-Irsaliyede vergi YOK; para birimi satirda tasinir.
              -- Satir tevkifati: izibiz SATIRDA 'withholdingTaxTotal' bekler
              --   (fatura duzeyinde 'withHoldingTax'). Matrah = KDV TUTARI,
              --   net degil - izibiz sematron kurali (Delphi'de dogrulanmis).
              || case when s.tevk_tutar > 0.0001 and not v_irsaliye then
                     jsonb_build_object('withholdingTaxTotal', jsonb_build_object(
                         'taxAmount', s.tevk_tutar,
                         'taxSubTotal', jsonb_build_array(jsonb_build_object(
                             'taxableAmount', s.kdv_tutar,
                             'taxAmount', s.tevk_tutar,
                             -- izibiz sematron 856: sira numarasi bos olamaz.
                             'calculationSequenceNumeric', 1,
                             -- TAM SAYI: izibiz "50.00" reddediyor, "50" kabul
                             --   ediyor (Delphi de Round ile gonderiyor).
                             'percent', round(s.tevk_oran)::int,
                             'taxScheme', jsonb_build_object(
                                 'name', 'KDV TEVKIFATI',
                                 'typeCode', s.tevk_kod)))))
                 else '{}'::jsonb end
              || case when v_irsaliye then jsonb_build_object('currencyId', v_para)
                 else jsonb_build_object('taxTotal', jsonb_build_object(
                        'taxAmount', s.kdv_tutar,
                        'taxSubTotal', jsonb_build_array(
                          jsonb_build_object(
                            'taxableAmount', s.tutar,
                            'taxAmount', s.kdv_tutar,
                            'calculationSequenceNumeric', 1,
                            'percent', coalesce(s.kdv, 0),
                            -- KDV 0 ise GIB muafiyet kodu+nedeni ZORUNLU tutar.
                            'taxScheme', jsonb_build_object('name', 'KDV', 'typeCode', '0015'))
                          || case when s.kdv_tutar < 0.001 then
                                 jsonb_build_object(
                                   'taxExemptionCode', coalesce(nullif(s.kdv_muafiyeti::text, '0'), '351'),
                                   'taxExemptionReason',
                                   -- kd.ad ACIK yazilir: CTE'nin kendi kolonlariyla
                                   --   ("s.ad" yok ama satir tipi ad tasiyor) cakisiyor.
                                   coalesce((select kd.ad from public.kod_deger kd
                                              join public.kod_liste kl on kl.id = kd.liste_id
                                             where kl.kod = 'belge.kdv_muafiyeti'
                                               and kd.deger = s.kdv_muafiyeti),
                                            'Diğerleri'))
                             else '{}'::jsonb end)))
                 end
             ) order by s.sira, s.id),
           coalesce(sum(s.tutar), 0),
           coalesce(sum(s.kdv_tutar), 0),
           coalesce(sum(greatest(s.isk_tutar, 0)), 0),
           coalesce(sum(s.tevk_tutar), 0)
      into v_satirlar, v_matrah, v_kdv, v_iskonto, v_tevkifat
      from s;

    if v_satirlar is null then
        raise exception 'Belgede kalem yok; gönderilecek bir şey üretilemedi.';
    end if;

    -- Dip toplam ile KURUS FARKI: satir bazli toplama, belgenin kendi KDV'sinden
    --   yuvarlama yuzunden 1-2 kurus sapabilir. Delphi'deki gibi 2 kurusa kadar
    --   olan farkta BELGENIN degeri esas alinir - GIB toplam uyusmazligini reddeder.
    if abs(v_kdv - coalesce(b.kdv_tutari, 0)) < 0.02 then
        v_kdv := coalesce(b.kdv_tutari, v_kdv);
    end if;

    -- ---------------------------------------------------------- vergi/toplam -
    if not v_irsaliye then
        -- KDV oranina gore gruplanmis ozet (GIB taxTotal.taxSubTotal).
        select jsonb_build_object(
                 'taxAmount', v_kdv,
                 'taxSubTotal', jsonb_agg(jsonb_build_object(
                     'calculationSequenceNumeric', 1,
                     'taxableAmount', x.matrah,
                     'percent', x.oran,
                     'taxAmount', x.vergi,
                     'taxScheme', jsonb_build_object('name', 'KDV', 'typeCode', '0015'))
                   || case when x.vergi < 0.001 then
                          jsonb_build_object('taxExemptionCode', '351',
                                             'taxExemptionReason', 'Diğerleri')
                      else '{}'::jsonb end
                   order by x.oran))
          into v_vergi
          from (select coalesce(bs.kdv, 0)::numeric              as oran,
                       sum(bs.tutar)                             as matrah,
                       sum(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)) as vergi
                  from public.belge_satir bs
                 where bs.belge_id = p_belge_id
                 group by coalesce(bs.kdv, 0)) x;

        -- FATURA DUZEYI TEVKIFAT: izibiz 'withHoldingTax' anahtarini bekler
        --   (satirdaki 'withholdingTaxTotal' ile karistirilmamali; yanlis anahtar
        --   "satirda tevkifat yok" sematron hatasi verir).
        if v_tevkifat > 0.0001 then
            select jsonb_build_object(
                     'taxAmount', round(v_tevkifat, 2),
                     'taxSubTotal', jsonb_agg(jsonb_build_object(
                         'taxableAmount', x.kdv,
                         'taxAmount', x.tevkifat,
                         'calculationSequenceNumeric', 1,
                         'percent', round(x.oran)::int,
                         'taxScheme', jsonb_build_object(
                             'name', 'KDV TEVKIFATI', 'typeCode', x.kod))
                       order by x.oran))
              into v_tevk_alt
              from (select coalesce(nullif(bs.tevkifat_orani, 0),
                                    public.fn_tevkifat_orani(bs.tevkifat_kodu)) as oran,
                           max(btrim(coalesce(bs.tevkifat_kodu, '')))           as kod,
                           sum(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)) as kdv,
                           sum(round(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)
                               * coalesce(nullif(bs.tevkifat_orani, 0),
                                          public.fn_tevkifat_orani(bs.tevkifat_kodu)) / 100.0, 2))
                                                                                as tevkifat
                      from public.belge_satir bs
                     where bs.belge_id = p_belge_id
                       and coalesce(nullif(bs.tevkifat_orani, 0),
                                    public.fn_tevkifat_orani(bs.tevkifat_kodu)) > 0
                     group by 1) x;
        end if;

        -- lineExtensionAmount = BRUT (iskonto oncesi), taxExclusive = NET.
        --   Delphi'deki ayrimin aynisi; GIB "Mal Hizmet Toplam Tutari"ni brut ister.
        v_toplam := jsonb_build_object(
            'lineExtensionAmount', round(v_matrah + v_iskonto, 2),
            'taxExclusiveAmount',  round(v_matrah, 2),
            'taxInclusiveAmount',  round(v_matrah + v_kdv, 2),
            -- Odenecek = matrah + KDV - TEVKIFAT (tevkifat kismini alici
            --   dogrudan devlete oder, satici tahsil etmez).
            'payableAmount',       round(v_matrah + v_kdv - v_tevkifat, 2))
            || case when v_iskonto > 0.0001
                    then jsonb_build_object('allowanceTotalAmount', round(v_iskonto, 2))
                    else '{}'::jsonb end;
    end if;

    -- --------------------------------------------------------------- taraflar
    v_supplier := jsonb_build_object(
        'name',       g.unvan,
        'identifier', g.vkno,
        'schemeId',   public.fn_ebelge_kimlik_semasi(g.vkno),
        'address',    jsonb_strip_nulls(jsonb_build_object(
            -- GIB ulke KODU ister ('TR'); sube kaydindaki "Türkiye" adi gitmez.
            'country',    'TR',
            'city',       nullif(g.il, ''),
            'subCity',    nullif(g.ilce, ''),
            'streetName', nullif(g.adres, ''),
            'postalCode', nullif(g.posta_kodu, ''),
            'email',      nullif(g.eposta, ''),
            'telephone',  nullif(g.telefon, ''),
            'webSite',    nullif(g.web, ''))))
        || case when g.vergi_dairesi <> '' then jsonb_build_object('taxOffice', g.vergi_dairesi) else '{}'::jsonb end;

    -- Sahis firmasi (TCKN) gondericide GIB ad/soyad ister - unvan yetmez.
    if public.fn_ebelge_kimlik_semasi(g.vkno) = 'TCKN' then
        v_supplier := v_supplier || (select jsonb_build_object('firstName', a.ad, 'lastName', a.soyad)
                                       from public.fn_ad_soyad_ayir(g.unvan) a);
    end if;

    -- Mersis / ticaret sicil: izibiz `identifications` dizisinde tasir; GIB
    --   ticari faturada bu iki numarayi arar.
    if g.mersis_no <> '' or g.ticaret_sicil_no <> '' then
        v_supplier := v_supplier || jsonb_build_object('identifications',
            (case when g.mersis_no <> ''
                  then jsonb_build_array(jsonb_build_object('scheme', 'MERSISNO', 'value', g.mersis_no))
                  else '[]'::jsonb end)
            ||
            (case when g.ticaret_sicil_no <> ''
                  then jsonb_build_array(jsonb_build_object('scheme', 'TICARETSICILNO', 'value', g.ticaret_sicil_no))
                  else '[]'::jsonb end));
    end if;

    v_customer := jsonb_build_object(
        'identifier', regexp_replace(b.taraf_vkno, '\D', '', 'g'),
        'schemeId',   public.fn_ebelge_kimlik_semasi(b.taraf_vkno),
        'address',    jsonb_strip_nulls(jsonb_build_object(
            'country',    'TR',
            'city',       nullif(btrim(coalesce(b.taraf_il, '')), ''),
            'subCity',    nullif(btrim(coalesce(b.taraf_ilce, '')), ''),
            'streetName', nullif(btrim(coalesce(b.taraf_adres, '')), ''))));

    -- Gercek kisi alicida GIB ad/soyad ister, unvan DEGIL.
    if public.fn_ebelge_kimlik_semasi(b.taraf_vkno) = 'TCKN' then
        v_customer := v_customer || (select jsonb_build_object('firstName', a.ad, 'lastName', a.soyad)
                                       from public.fn_ad_soyad_ayir(b.taraf_unvan) a);
    else
        v_customer := v_customer || jsonb_build_object('name', b.taraf_unvan);
    end if;
    if coalesce(btrim(b.taraf_vd), '') <> '' then
        v_customer := v_customer || jsonb_build_object('taxOffice', btrim(b.taraf_vd));
    end if;

    -- e-Arsivde belge alicinin E-POSTASIYLA iletilir: adres bloguna yazilir.
    v_mail := coalesce(nullif(btrim(b.alici_alias), ''), nullif(btrim(b.taraf_eposta), ''), '');
    if v_arsiv and v_mail <> '' then
        v_customer := jsonb_set(v_customer, '{address,email}', to_jsonb(v_mail));
        if coalesce(btrim(b.taraf_telefon), '') <> '' then
            v_customer := jsonb_set(v_customer, '{address,telephone}', to_jsonb(btrim(b.taraf_telefon)));
        end if;
    end if;

    -- ------------------------------------------------------------ notlar ----
    if coalesce(btrim(b.aciklama), '') <> '' then
        v_notlar := v_notlar || to_jsonb(btrim(b.aciklama));
    end if;

    -- ------------------------------------------------- ek referanslar / XSLT -
    -- e-Arsivde gonderim sekli: alici e-postasi varsa ELEKTRONIK, yoksa KAGIT.
    if v_arsiv then
        v_ek_ref := v_ek_ref || jsonb_build_array(jsonb_build_object(
            'documentTypeCode', 'SendingType',
            'documentType',     case when v_mail <> '' then 'ELEKTRONIK' else 'KAGIT' end,
            'id',               '1',
            'issueDate',        to_char(b.belge_tarihi, 'YYYY-MM-DD')));
    end if;

    -- GORUNTULEME SABLONU (XSLT) belgeye GOMULUR. Entegratordeki kayitli sablona
    --   (xsltName='DEFAULT') guvenmek Delphi'de "imza bilgisi bulunamadi" hatasi
    --   verdigi icin sablon her belgede gonderilir. Sablon: bu belge turu icin
    --   varsayilan isaretli dokuman.
    select convert_from(di.icerik, 'UTF8') into v_xslt
      from public.dokuman d
      join public.dokuman_icerik di on di.hash = d.hash
     where d.kaynak = 'ebelge-xslt' and d.kaynak_id = v_tur and d.durum = 1
     order by d.varsayilan desc, d.id
     limit 1;

    if coalesce(btrim(v_xslt), '') = '' then
        raise exception 'Bu belge türü için XSLT şablonu yok. Ayarlar › Satış Belgeleri › e-Belge › XSLT''den ekleyin.';
    end if;

    v_ek_ref := v_ek_ref || jsonb_build_array(jsonb_build_object(
        'id',           v_uuid,
        'documentType', 'XSLT',
        'issueDate',    to_char(b.belge_tarihi, 'YYYY-MM-DD'),
        'attachment',   jsonb_build_object(
            'characterSetCode', 'UTF-8',
            'encodingCode',     'Base64',
            'filename',         coalesce(nullif(btrim(b.e_no), ''), v_uuid) || '.xslt',
            'mimeCode',         'application/xml',
            -- encode(...,'base64') 76 karakterde satir kirar; izibiz tek satir ister.
            'content',          replace(encode(convert_to(v_xslt, 'UTF8'), 'base64'), E'\n', ''))));

    -- --------------------------------------------------------------- content -
    v_content := jsonb_build_object(
        'profile',          v_profil,
        'documentTypeCode', v_belge_tipi,
        'uuid',             v_uuid,
        'issueDate',        to_char(b.belge_tarihi, 'YYYY-MM-DD'),
        'issueTime',        to_char(b.belge_tarihi, 'HH24:MI:SS'),
        'notes',            v_notlar,
        'currencyCode',     v_para,
        'supplierParty',    v_supplier,
        'customerParty',    v_customer,
        'additionalReferences', v_ek_ref,
        'lines',            v_satirlar);

    if coalesce(btrim(b.e_no), '') <> '' then
        v_content := v_content || jsonb_build_object('documentNo', b.e_no);
    end if;
    if not v_irsaliye then
        v_content := v_content || jsonb_build_object('taxTotal', v_vergi,
                                                     'legalMonetaryTotal', v_toplam);
        if v_tevk_alt is not null then
            v_content := v_content || jsonb_build_object('withHoldingTax', v_tevk_alt);
        end if;

        -- IADE (tipi=2): iade edilen ORIJINAL belgenin referansi. GIB schematron
        --   10003 bunu 16 haneli numara + documentTypeCode=IADE ile ZORUNLU
        --   tutar; yoksa belge reddedilir (176 iade_belge_id).
        if coalesce(b.tipi, 0) = 2 then
            select jsonb_agg(jsonb_build_object(
                       'id', coalesce(nullif(btrim(o.belge_no), ''), ''),
                       'issueDate', to_char(o.belge_tarihi, 'YYYY-MM-DD'),
                       'documentTypeCode', 'IADE',
                       'documentType', 'İade Edilen Fatura'))
              into v_iade_ref
              from public.belge o
             where o.id = b.iade_belge_id;

            if v_iade_ref is null then
                raise exception 'İade faturasında hangi faturanın iade edildiği seçilmemiş; GİB referanssız iade belgesini reddeder.';
            end if;
            v_content := v_content || jsonb_build_object('billingReference', v_iade_ref);
        end if;
        -- Faturaya kaynaklik eden irsaliye referansi (GIB ister).
        if coalesce(btrim(b.irsaliye_no), '') <> '' then
            v_content := v_content || jsonb_build_object('despatchDocumentReference',
                jsonb_build_array(jsonb_build_object(
                    'id',        b.irsaliye_no,
                    'issueDate', to_char(coalesce(b.irsaliye_tarihi, b.belge_tarihi), 'YYYY-MM-DD'))));
        end if;
    else
        -- e-Irsaliye: sevkiyat blogu (177 tablosundan). GIB DriverPerson'da
        --   ad ve SOYAD ayri ister; tek alanda tutulan "sofor_ad" son kelimeden
        --   bolunur (aliciyla ayni kural, fn_ad_soyad_ayir).
        v_content := v_content || jsonb_build_object('shipment', jsonb_build_object(
            'id', 1,
            'goodsItems', jsonb_build_array(jsonb_build_object(
                'currencyId', v_para, 'valueAmount', round(v_matrah, 2))),
            'shipmentStages', jsonb_build_array(
                jsonb_strip_nulls(jsonb_build_object(
                    'licensePlateID', nullif(sv.arac_plaka, '')))
                || case when sv.sofor_ad <> '' then
                       (select jsonb_build_object('driverPerson', jsonb_strip_nulls(
                            jsonb_build_object(
                                'firstName', a.ad,
                                'familyName', nullif(a.soyad, ''),
                                'title', 'Sürücü',
                                -- GIB kimlik numarasini NationalityID'de tasir.
                                'nationalityID', nullif(sv.sofor_tckn, ''))))
                          from public.fn_ad_soyad_ayir(sv.sofor_ad) a)
                   else '{}'::jsonb end
                -- Nakliyeyi baska firma yapiyorsa carrierParty (kendi aracimizsa yok).
                || case when sv.tasiyici_id is not null then
                       (select jsonb_strip_nulls(jsonb_build_object('carrierParty',
                            jsonb_build_object(
                                'name', t.unvan,
                                'identifier', nullif(regexp_replace(coalesce(t.vkno, ''), '\D', '', 'g'), ''),
                                'schemeId', public.fn_ebelge_kimlik_semasi(t.vkno))))
                          from public.taraf t where t.id = sv.tasiyici_id)
                   else '{}'::jsonb end),
            'delivery', jsonb_build_object(
                'deliveryAddress', jsonb_strip_nulls(jsonb_build_object(
                    'country', 'TR',
                    'city', nullif(btrim(coalesce(b.taraf_il, '')), ''),
                    'subCity', nullif(btrim(coalesce(b.taraf_ilce, '')), ''),
                    'streetName', nullif(btrim(coalesce(b.taraf_adres, '')), ''),
                    'postalZone', '34000')),
                'despatch', jsonb_build_object(
                    'actualDespatchDate', to_char(b.belge_tarihi, 'YYYY-MM-DD'),
                    'actualDespatchTime', to_char(b.belge_tarihi, 'HH24:MI:SS')))));
    end if;

    -- ------------------------------------------------------------------ kok --
    -- assignNumber STRING gonderilir (izibiz Postman ornegi boyle): numarayi
    --   biz verdiysek 'false'. Bizde numara hazirlamada uretildigi icin daima false.
    v_kok := jsonb_build_object(
        'documentAction', 'SEND',
        'assignNumber',   case when coalesce(btrim(b.e_no), '') = '' then 'true' else 'false' end,
        'seriePrefix',    left(coalesce(btrim(b.e_no), ''), 3),
        'content',        v_content);

    if v_irsaliye then
        -- Irsaliye icerigi base64 olarak parse edilmesin.
        v_kok := v_kok || jsonb_build_object('compressed', 'false');
    end if;

    -- ALICI POSTA KUTUSU: alias gonderilmezse izibiz ilk buldugu etikete yollar;
    --   cok aliasli mukellefte YANLIS kutuya duser (izibiz teyidi).
    if not v_arsiv and coalesce(btrim(b.alici_alias), '') <> '' then
        v_kok := v_kok || jsonb_build_object('receiverAlias', btrim(b.alici_alias));
    end if;
    if coalesce(btrim(b.gonderici_alias), '') <> '' then
        v_kok := v_kok || jsonb_build_object('senderAlias', btrim(b.gonderici_alias));
    elsif g.gonderici_alias <> '' then
        v_kok := v_kok || jsonb_build_object('senderAlias', g.gonderici_alias);
    end if;

    -- e-Arsiv postasi: mailFlag + mailAdress ile TETIKLENIR (customerParty'deki
    --   e-posta tek basina gondermiyor - Delphi'de dogrulanmis).
    if v_arsiv and v_mail <> '' then
        v_kok := v_kok || jsonb_build_object(
            'mailFlag', true,
            'mailAdress', (select jsonb_agg(btrim(m))
                             from unnest(regexp_split_to_array(v_mail, '[;,\r\n]+')) m
                            where btrim(m) <> ''));
    end if;

    return v_kok;
end $$;

comment on function public.fn_ebelge_govde_izibiz(integer) is
  'IZIBIZ adaptoru: hazirlanmis e-Belge icin izibiz REST gonderim JSON''u (Delphi _IzibizJSONOlustur karsiligi, 166). Dogrudan cagrilmaz - fn_ebelge_gonderim_govdesi secer (167).';

do $$
begin
    raise notice '166 tamam: fn_ebelge_govde_izibiz + kimlik/birim/para yardimcilari.';
end $$;
