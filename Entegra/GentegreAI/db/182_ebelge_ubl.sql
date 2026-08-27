-- ============================================================================
--  Gentegre AI — UBL-XML URETECI
--  182_ebelge_ubl.sql
--
--  Kullanici: "ubl ekle".
--
--  NEDEN GEREKLI (gonderim icin degil, uc is icin):
--    1. XSLT GORUNUMU: XSLT bir XML'e uygulanir. UBL olmadan "Ön İzle / PDF /
--       HTML" hep bizim sade sablonumuz kalir, GIB'in gordugu goruntu olmaz.
--    2. "XML Kaydet" gercekten XML olsun (bugun JSON iniyordu).
--    3. UBL BEKLEYEN ENTEGRATORLER: katalogdaki 11 kaydin 10'u gonderim_bicimi=2
--       (Uyumsoft, EDM, Sovos, Veriban, e-Logo, NES, Turkcell...). Adaptorleri
--       bu fonksiyonu cagirarak yazilabilir.
--    4. ARSIV/DENETIM: e_belge.ubl_xml kolonu bostu - GIB'e gidenin bizdeki
--       kopyasi yoktu, uyusmazlikta entegratore bagimliydik.
--
--  KAYNAK: Delphi `UBLXMLUret` (UEBelgeOlusturucu.pas:2285+). Eleman adlari,
--  sira ve TR1.2 ozellestirmesi oradan birebir.
--
--  XMLELEMENT KULLANILIYOR, metin birlestirme DEGIL: PostgreSQL kacisi kendisi
--  yapar. Elle "&lt;" kacisi yazmak, cari unvaninda tek bir "&" ile gecersiz
--  XML uretir ve hata GIB reddinde ortaya cikardi.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------------- taraf -----
-- cac:Party - gonderici ve alici ayni kaliptan (JSON tarafindaki
--   fn_ebelge_taraf_json ile ayni ayrim).
create or replace function public.fn_ubl_taraf(
        p_unvan text, p_vkno text, p_vd text,
        p_adres text, p_ilce text, p_il text, p_posta_kodu text default '',
        p_ulke text default 'Türkiye', p_telefon text default '',
        p_eposta text default '', p_web text default '',
        p_mersis text default '', p_sicil text default '')
returns xml language sql immutable as $$
    select xmlelement(name "cac:Party",
        case when coalesce(btrim(p_web), '') <> ''
             then xmlelement(name "cbc:WebsiteURI", btrim(p_web)) end,
        -- VKN/TCKN: schemeID kimlik turunu soyler.
        xmlelement(name "cac:PartyIdentification",
            xmlelement(name "cbc:ID",
                xmlattributes(public.fn_ebelge_kimlik_semasi(p_vkno) as "schemeID"),
                regexp_replace(coalesce(p_vkno, ''), '\D', '', 'g'))),
        case when coalesce(btrim(p_mersis), '') <> ''
             then xmlelement(name "cac:PartyIdentification",
                    xmlelement(name "cbc:ID", xmlattributes('MERSISNO' as "schemeID"),
                               btrim(p_mersis))) end,
        case when coalesce(btrim(p_sicil), '') <> ''
             then xmlelement(name "cac:PartyIdentification",
                    xmlelement(name "cbc:ID", xmlattributes('TICARETSICILNO' as "schemeID"),
                               btrim(p_sicil))) end,
        -- Gercek kiside (TCKN) GIB PartyName yerine Person ister.
        case when public.fn_ebelge_kimlik_semasi(p_vkno) <> 'TCKN'
             then xmlelement(name "cac:PartyName",
                    xmlelement(name "cbc:Name", btrim(coalesce(p_unvan, '')))) end,
        xmlelement(name "cac:PostalAddress",
            case when coalesce(btrim(p_adres), '') <> ''
                 then xmlelement(name "cbc:StreetName", btrim(p_adres)) end,
            case when coalesce(btrim(p_ilce), '') <> ''
                 then xmlelement(name "cbc:CitySubdivisionName", btrim(p_ilce)) end,
            case when coalesce(btrim(p_il), '') <> ''
                 then xmlelement(name "cbc:CityName", btrim(p_il)) end,
            case when coalesce(btrim(p_posta_kodu), '') <> ''
                 then xmlelement(name "cbc:PostalZone", btrim(p_posta_kodu)) end,
            xmlelement(name "cac:Country",
                xmlelement(name "cbc:Name", coalesce(nullif(btrim(p_ulke), ''), 'Türkiye')))),
        -- Vergi dairesi UBL'de TaxScheme adidir.
        xmlelement(name "cac:PartyTaxScheme",
            xmlelement(name "cac:TaxScheme",
                xmlelement(name "cbc:Name", coalesce(nullif(btrim(p_vd), ''), '')))),
        case when public.fn_ebelge_kimlik_semasi(p_vkno) = 'TCKN'
             then (select xmlelement(name "cac:Person",
                       xmlelement(name "cbc:FirstName", a.ad),
                       xmlelement(name "cbc:FamilyName", a.soyad))
                     from public.fn_ad_soyad_ayir(p_unvan) a) end,
        case when coalesce(btrim(p_telefon), '') <> '' or coalesce(btrim(p_eposta), '') <> ''
             then xmlelement(name "cac:Contact",
                    case when coalesce(btrim(p_telefon), '') <> ''
                         then xmlelement(name "cbc:Telephone", btrim(p_telefon)) end,
                    case when coalesce(btrim(p_eposta), '') <> ''
                         then xmlelement(name "cbc:ElectronicMail", btrim(p_eposta)) end) end)
$$;

comment on function public.fn_ubl_taraf(text, text, text, text, text, text, text,
                                        text, text, text, text, text, text) is
  'UBL cac:Party - gonderici/alici ortak kalibi (182).';

-- ---------------------------------------------------------------- belge -----
drop function if exists public.fn_ebelge_ubl(integer);

create function public.fn_ebelge_ubl(p_belge_id integer)
returns xml
language plpgsql stable as $$
declare
    b           record;
    g           record;
    sv          record;
    v_tur       smallint;
    v_irsaliye  boolean;
    v_profil    text;
    v_tip       text;
    v_para      text;
    v_uuid      text;
    v_matrah    numeric := 0;
    v_kdv       numeric := 0;
    v_iskonto   numeric := 0;
    v_tevkifat  numeric := 0;
    v_satirlar  xml;
    v_vergiler  xml;
    v_kok       xml;
begin
    select bl.*, e.belge_turu as e_tur, e.belge_no as e_no, e.uuid as e_uuid
      into b
      from public.belge bl
      left join lateral (select e2.* from public.e_belge e2
                          where e2.belge_id = bl.id order by e2.id desc limit 1) e on true
     where bl.id = p_belge_id;
    if not found then
        raise exception 'Belge bulunamadı (%).', p_belge_id;
    end if;

    v_tur      := coalesce(b.e_tur, case when b.tur = 14 then 7 else 1 end);
    v_irsaliye := v_tur = 7;
    v_para     := public.fn_ebelge_para_kodu(coalesce(nullif(b.belge_dovizi, ''), b.doviz_cinsi));
    v_uuid     := coalesce(nullif(btrim(b.e_uuid), ''), gen_random_uuid()::text);

    select * into g from public.v_ebelge_gonderici
     where sube_id = coalesce(nullif(b.sube_id, 0), (select min(id) from public.sube));
    select * into sv from public.v_belge_sevkiyat where belge_id = p_belge_id;

    v_profil := case when v_irsaliye then 'TEMELIRSALIYE'
                     when v_tur = 2   then 'EARSIVFATURA'
                     when coalesce(b.senaryo, 0) = 2 then 'TICARIFATURA'
                     else 'TEMELFATURA' end;
    v_tip := case when v_irsaliye then 'SEVK'
                  when coalesce(b.tipi, 0) = 2  then 'IADE'
                  when coalesce(b.tipi, 0) = 22 then 'TEVKIFAT'
                  when coalesce(b.tipi, 0) = 24 then 'ISTISNA'
                  when coalesce(b.tipi, 0) = 9  then 'IHRACKAYITLI'
                  else 'SATIS' end;

    -- ------------------------------------------------------------ satirlar --
    with s as (
        select bs.*,
               row_number() over (order by bs.sira, bs.id)              as no,
               round(bs.miktar * bs.birim_fiyat, 2)                     as brut,
               round(bs.miktar * bs.birim_fiyat, 2) - bs.tutar          as isk,
               round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)         as kdv_tutar,
               coalesce(nullif(bs.tevkifat_orani, 0),
                        public.fn_tevkifat_orani(bs.tevkifat_kodu))     as tevk_oran
          from public.belge_satir bs
         where bs.belge_id = p_belge_id
    )
    -- SATIR ELEMANI belge turune gore ayri: faturada cac:InvoiceLine /
    --   cbc:InvoicedQuantity, irsaliyede cac:DespatchLine / cbc:DeliveredQuantity.
    select xmlagg(
             xmlelement(name "SATIRELEMANI",
                 xmlelement(name "cbc:ID", s.no),
                 xmlelement(name "MIKTARELEMANI",
                     xmlattributes(public.fn_ebelge_birim_kodu(s.birim) as "unitCode"),
                     to_char(s.miktar, 'FM9999999990.0000')),
                 xmlelement(name "cbc:LineExtensionAmount",
                     xmlattributes(v_para as "currencyID"),
                     to_char(s.tutar, 'FM9999999990.00')),
                 -- Iskonto UBL'de AllowanceCharge; lineExtension NET kalir.
                 case when s.isk > 0.0001 then
                     xmlelement(name "cac:AllowanceCharge",
                         xmlelement(name "cbc:ChargeIndicator", 'false'),
                         xmlelement(name "cbc:MultiplierFactorNumeric",
                                    to_char(round(s.isk / nullif(s.brut, 0), 6), 'FM0.000000')),
                         xmlelement(name "cbc:Amount", xmlattributes(v_para as "currencyID"),
                                    to_char(round(s.isk, 2), 'FM9999999990.00')),
                         xmlelement(name "cbc:BaseAmount", xmlattributes(v_para as "currencyID"),
                                    to_char(s.brut, 'FM9999999990.00'))) end,
                 case when not v_irsaliye then
                     xmlelement(name "cac:TaxTotal",
                         xmlelement(name "cbc:TaxAmount", xmlattributes(v_para as "currencyID"),
                                    to_char(s.kdv_tutar, 'FM9999999990.00')),
                         xmlelement(name "cac:TaxSubtotal",
                             xmlelement(name "cbc:TaxableAmount",
                                 xmlattributes(v_para as "currencyID"),
                                 to_char(s.tutar, 'FM9999999990.00')),
                             xmlelement(name "cbc:TaxAmount",
                                 xmlattributes(v_para as "currencyID"),
                                 to_char(s.kdv_tutar, 'FM9999999990.00')),
                             xmlelement(name "cbc:Percent", coalesce(s.kdv, 0)),
                             xmlelement(name "cac:TaxCategory",
                                 case when s.kdv_tutar < 0.001 then
                                     xmlelement(name "cbc:TaxExemptionReasonCode",
                                         coalesce(nullif(s.kdv_muafiyeti::text, '0'), '351')) end,
                                 xmlelement(name "cac:TaxScheme",
                                     xmlelement(name "cbc:Name", 'KDV'),
                                     xmlelement(name "cbc:TaxTypeCode", '0015'))))) end,
                 xmlelement(name "cac:Item",
                     xmlelement(name "cbc:Name",
                                coalesce(nullif(btrim(s.aciklama), ''), 'Ürün'))),
                 xmlelement(name "cac:Price",
                     xmlelement(name "cbc:PriceAmount",
                         xmlattributes(v_para as "currencyID"),
                         to_char(s.birim_fiyat, 'FM9999999990.0000'))))
             order by s.no),
           coalesce(sum(s.tutar), 0), coalesce(sum(s.kdv_tutar), 0),
           coalesce(sum(greatest(s.isk, 0)), 0),
           coalesce(sum(round(s.kdv_tutar * s.tevk_oran / 100.0, 2)), 0)
      into v_satirlar, v_matrah, v_kdv, v_iskonto, v_tevkifat
      from s;

    if v_satirlar is null then
        raise exception 'Belgede kalem yok; UBL üretilemedi.';
    end if;

    -- KDV ORANINA GORE ozet (cac:TaxTotal - fatura duzeyi).
    if not v_irsaliye then
        select xmlelement(name "cac:TaxTotal",
                   xmlelement(name "cbc:TaxAmount", xmlattributes(v_para as "currencyID"),
                              to_char(v_kdv, 'FM9999999990.00')),
                   xmlagg(xmlelement(name "cac:TaxSubtotal",
                       xmlelement(name "cbc:TaxableAmount",
                           xmlattributes(v_para as "currencyID"),
                           to_char(x.matrah, 'FM9999999990.00')),
                       xmlelement(name "cbc:TaxAmount",
                           xmlattributes(v_para as "currencyID"),
                           to_char(x.vergi, 'FM9999999990.00')),
                       xmlelement(name "cbc:Percent", x.oran),
                       xmlelement(name "cac:TaxCategory",
                           xmlelement(name "cac:TaxScheme",
                               xmlelement(name "cbc:Name", 'KDV'),
                               xmlelement(name "cbc:TaxTypeCode", '0015'))))
                     order by x.oran))
          into v_vergiler
          from (select coalesce(bs.kdv, 0)::numeric as oran,
                       sum(bs.tutar) as matrah,
                       sum(round(bs.tutar * coalesce(bs.kdv, 0) / 100.0, 2)) as vergi
                  from public.belge_satir bs
                 where bs.belge_id = p_belge_id
                 group by coalesce(bs.kdv, 0)) x;
    end if;

    -- ---------------------------------------------------------------- kok ---
    v_kok := xmlelement(
        name "KOKELEMANI",
        xmlattributes(
            'urn:oasis:names:specification:ubl:schema:xsd:KOKELEMANI-2' as "xmlns",
            'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2' as "xmlns:cac",
            'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2' as "xmlns:cbc"),
        xmlelement(name "cbc:UBLVersionID", '2.1'),
        -- TR1.2: GIB'in UBL ozellestirmesi.
        xmlelement(name "cbc:CustomizationID", 'TR1.2'),
        xmlelement(name "cbc:ProfileID", v_profil),
        xmlelement(name "cbc:ID", coalesce(nullif(b.e_no, ''), coalesce(b.belge_no, ''))),
        xmlelement(name "cbc:CopyIndicator", 'false'),
        xmlelement(name "cbc:UUID", v_uuid),
        xmlelement(name "cbc:IssueDate", to_char(b.belge_tarihi, 'YYYY-MM-DD')),
        xmlelement(name "cbc:IssueTime", to_char(b.belge_tarihi, 'HH24:MI:SS')),
        case when v_irsaliye
             then xmlelement(name "cbc:DespatchAdviceTypeCode", 'SEVK')
             else xmlelement(name "cbc:InvoiceTypeCode", v_tip) end,
        case when coalesce(btrim(b.aciklama), '') <> ''
             then xmlelement(name "cbc:Note", btrim(b.aciklama)) end,
        xmlelement(name "cbc:DocumentCurrencyCode", v_para),
        xmlelement(name "cbc:LineCountNumeric",
                   (select count(*) from public.belge_satir where belge_id = p_belge_id)),
        -- IADE: orijinal belgenin referansi (GIB schematron 10003).
        case when coalesce(b.tipi, 0) = 2 and b.iade_belge_id is not null then
            (select xmlelement(name "cac:BillingReference",
                        xmlelement(name "cac:InvoiceDocumentReference",
                            xmlelement(name "cbc:ID", coalesce(o.belge_no, '')),
                            xmlelement(name "cbc:IssueDate",
                                       to_char(o.belge_tarihi, 'YYYY-MM-DD'))))
               from public.belge o where o.id = b.iade_belge_id) end,
        -- Faturaya kaynaklik eden irsaliye.
        case when not v_irsaliye and coalesce(btrim(b.irsaliye_no), '') <> '' then
            xmlelement(name "cac:DespatchDocumentReference",
                xmlelement(name "cbc:ID", btrim(b.irsaliye_no)),
                xmlelement(name "cbc:IssueDate",
                           to_char(coalesce(b.irsaliye_tarihi, b.belge_tarihi), 'YYYY-MM-DD'))) end,
        xmlelement(name "cac:AccountingSupplierParty",
            public.fn_ubl_taraf(g.unvan, g.vkno, g.vergi_dairesi, g.adres, g.ilce, g.il,
                                g.posta_kodu, g.ulke, g.telefon, g.eposta, g.web,
                                g.mersis_no, g.ticaret_sicil_no)),
        xmlelement(name "cac:AccountingCustomerParty",
            public.fn_ubl_taraf(b.taraf_unvan, b.taraf_vkno, b.taraf_vd,
                                b.taraf_adres, b.taraf_ilce, b.taraf_il)),
        -- e-Irsaliye: sevkiyat blogu (plaka + sofor).
        case when v_irsaliye and sv.belge_id is not null then
            xmlelement(name "cac:Shipment",
                xmlelement(name "cbc:ID", '1'),
                xmlelement(name "cac:ShipmentStage",
                    case when sv.arac_plaka <> '' then
                        xmlelement(name "cac:TransportMeans",
                            xmlelement(name "cac:RoadTransport",
                                xmlelement(name "cbc:LicensePlateID", sv.arac_plaka))) end,
                    case when sv.sofor_ad <> '' then
                        (select xmlelement(name "cac:DriverPerson",
                             xmlelement(name "cbc:FirstName", a.ad),
                             xmlelement(name "cbc:FamilyName", nullif(a.soyad, '')),
                             case when sv.sofor_tckn <> '' then
                                 xmlelement(name "cbc:NationalityID", sv.sofor_tckn) end)
                           from public.fn_ad_soyad_ayir(sv.sofor_ad) a) end),
                xmlelement(name "cac:Delivery",
                    xmlelement(name "cac:DeliveryAddress",
                        case when coalesce(btrim(b.taraf_adres), '') <> ''
                             then xmlelement(name "cbc:StreetName", btrim(b.taraf_adres)) end,
                        xmlelement(name "cbc:CitySubdivisionName",
                                   coalesce(nullif(btrim(b.taraf_ilce), ''), '')),
                        xmlelement(name "cbc:CityName",
                                   coalesce(nullif(btrim(b.taraf_il), ''), '')),
                        xmlelement(name "cac:Country",
                            xmlelement(name "cbc:Name", 'Türkiye'))))) end,
        v_vergiler,
        -- TEVKIFAT: UBL'de ayri bir WithholdingTaxTotal.
        case when v_tevkifat > 0.0001 then
            xmlelement(name "cac:WithholdingTaxTotal",
                xmlelement(name "cbc:TaxAmount", xmlattributes(v_para as "currencyID"),
                           to_char(v_tevkifat, 'FM9999999990.00'))) end,
        case when not v_irsaliye then
            xmlelement(name "cac:LegalMonetaryTotal",
                -- Mal/hizmet toplami BRUT (iskonto oncesi), vergi matrahi NET.
                xmlelement(name "cbc:LineExtensionAmount",
                    xmlattributes(v_para as "currencyID"),
                    to_char(v_matrah + v_iskonto, 'FM9999999990.00')),
                xmlelement(name "cbc:TaxExclusiveAmount",
                    xmlattributes(v_para as "currencyID"),
                    to_char(v_matrah, 'FM9999999990.00')),
                xmlelement(name "cbc:TaxInclusiveAmount",
                    xmlattributes(v_para as "currencyID"),
                    to_char(v_matrah + v_kdv, 'FM9999999990.00')),
                case when v_iskonto > 0.0001 then
                    xmlelement(name "cbc:AllowanceTotalAmount",
                        xmlattributes(v_para as "currencyID"),
                        to_char(v_iskonto, 'FM9999999990.00')) end,
                xmlelement(name "cbc:PayableAmount",
                    xmlattributes(v_para as "currencyID"),
                    to_char(v_matrah + v_kdv - v_tevkifat, 'FM9999999990.00'))) end,
        v_satirlar);

    -- xmlelement ADI degisken olamaz (PostgreSQL): eleman adlari yer
    --   tutucuyla uretilip burada belge turune gore yazilir. Degistirilenler
    --   BIZIM yazdigimiz sabit adlar, kullanici verisi degil - kacis riski yok.
    return xmlparse(document
        replace(replace(replace(replace(
            xmlserialize(document v_kok as text),
            'KOKELEMANI',    case when v_irsaliye then 'DespatchAdvice' else 'Invoice' end),
            'SATIRELEMANI',  case when v_irsaliye then 'cac:DespatchLine' else 'cac:InvoiceLine' end),
            'MIKTARELEMANI', case when v_irsaliye then 'cbc:DeliveredQuantity' else 'cbc:InvoicedQuantity' end),
            -- Irsaliyede tutar alani yok; fatura satirindaki adi korunur.
            'LineExtensionAmount', 'LineExtensionAmount'));
end $$;

comment on function public.fn_ebelge_ubl(integer) is
  'Belgenin UBL 2.1 (TR1.2) XML''i - Delphi UBLXMLUret karsiligi (182). XSLT goruntusu, "XML Kaydet" ve UBL bekleyen entegratorler bunu kullanir.';

do $$
begin
    raise notice '182 tamam: fn_ubl_taraf + fn_ebelge_ubl.';
end $$;
