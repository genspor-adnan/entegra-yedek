-- 1303 - Teletıp ORU kılavuz biçimi + ORM SUT çözümü ORU ile aynı
--
-- Kullanıcı 11.11.2026: "ORU'yu da kılavuz biçimine düzelt". ORU üreticisi (C#) Bakanlık profilinde artık kılavuz 3.43
-- Tablo 9-10 / 20-21 biçiminde (PID-2/3/4, PV1-19/20/50/51, ORC-1 SN, ORC-2/3, ORC-21 "Kurum^^SKRS\S\şube\S\MEDULA",
-- OBR-2/3). DB tarafında tek değişiklik: ORM veri fonksiyonu SUT kodunu ve adını ORU teslim sorgusuyla AYNI yoldan
-- çözer (fn_hizmet_sut_kodu + skrs_sut) - iki mesaj aynı tetkik için iki ayrı SUT kodu göndermesin. Modalite de ORU'nun
-- kullandığı fn_rad_modalite_kod (değerler aynı, tek kaynak).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_teletip_orm_verisi(p_istem_id integer)
returns jsonb language sql stable as $$
  with i as (
    select r.*, public.fn_sube_zaman_dilimi(r.sube_id) as tz
      from public.radyoloji_istem r where r.id = p_istem_id
  )
  select jsonb_build_object(
    'HbysAdi',          coalesce(nullif(sb.unvan, ''), sb.ad, ''),
    'Zaman',            to_char(now() at time zone i.tz, 'YYYY-MM-DD"T"HH24:MI:SS'),
    'HastaDosyaNo',     coalesce(h.kod, ''),
    'HastaTckn',        case when coalesce(h.vkno, '') ~ '^[1-9][0-9]{10}$' then h.vkno else '' end,
    'PasaportNo',       case when coalesce(h.vkno, '') ~ '^[1-9][0-9]{10}$' then '' else coalesce(th.pasaport_no, '') end,
    'UlkeKodu',         coalesce(u.skrs_kod::text, ''),
    'HastaSoyad',       upper(coalesce(nullif(h.soyad, ''), h.unvan, '')),
    'HastaAd',          upper(coalesce(h.ad, '')),
    'DogumTarihi',      to_char(th.dogum_tarihi, 'YYYY-MM-DD"T00:00:00"'),
    'Cinsiyet',         case th.cinsiyet when 1 then 'M' when 2 then 'F' else 'U' end,
    'EvTelefonu',       coalesce(nullif(h.cep_tel, ''), h.telefon, ''),
    'Eposta',           coalesce(h.eposta, ''),
    'AnneTckn',         coalesce(th.anne_tckn, ''),
    'DogumYeri',        coalesce(th.dogum_yeri::text, ''),
    'HastaSinifi',      case bb.basvuru_turu when 2 then 'E' when 3 then 'I' else 'O' end,
    'BirimId',          coalesce(bb.bolum_id::text, ''),
    'BirimAdi',         coalesce(dp.ad, ''),
    'BasvuruReferansi', coalesce(nullif(ref.hastane_referans, ''), ''),
    'Sgk',              coalesce(bp.sgk_takip_no, '') <> '',
    'MedulaTakipNo',    coalesce(bp.sgk_takip_no, ''),
    'KabulZamani',      to_char(coalesce(i.kabul_tarihi, i.ekleme_tarihi) at time zone i.tz, 'YYYY-MM-DD"T"HH24:MI:SS'),
    'AccessionNo',      i.accession_no,
    'IstemZamani',      to_char(i.ekleme_tarihi at time zone i.tz, 'YYYY-MM-DD"T"HH24:MI:SS'),
    'PlanlananZaman',   to_char(coalesce(rv.baslangic, i.kabul_tarihi, i.ekleme_tarihi) at time zone i.tz, 'YYYY-MM-DD"T"HH24:MI:SS'),
    'Giren',            jsonb_build_object('Kimlik', coalesce(i.ekleyen::text, ''), 'Soyad', upper(coalesce(gt.soyad, '')),
                                           'Ad', upper(coalesce(gt.ad, ''))),
    'IsteyenHekim',     jsonb_build_object(
                          'Kimlik', case when coalesce(hk.vkno, '') ~ '^[1-9][0-9]{10}$' then hk.vkno
                                         else coalesce(nullif(i.dis_hekim_tckn, ''), '') end,
                          'Soyad', upper(coalesce(nullif(hk.soyad, ''), split_part(coalesce(i.dis_hekim_ad, ''), ' ', 2))),
                          'Ad',    upper(coalesce(nullif(hk.ad, ''), split_part(coalesce(i.dis_hekim_ad, ''), ' ', 1))),
                          'Onek',  coalesce(hk.unvan, '')),
    'KurumAdi',         coalesce(nullif(sb.unvan, ''), sb.ad, ''),
    'KurumKisaAdi',     coalesce(sb.ad, ''),
    'KurumSkrs',        coalesce((select r.deger from public.referans r where r.anahtar = 'kurum.skrs_kodu'), ''),
    'SubeNo',           coalesce((select r.deger from public.referans r where r.anahtar = 'teletip.sube_no'), '1'),
    'MedulaTesisKodu',  coalesce(nullif((select kp.tesis_kodu from public.kurum_profil kp
                                          where kp.sube_id in (i.sube_id, 0) and coalesce(kp.tesis_kodu, '') <> ''
                                          order by (kp.sube_id = i.sube_id) desc limit 1), ''),
                                 bp.sgk_tesis_kodu, ''),
    -- 1303: ORU ile AYNI çözüm - yön / kontrast ailesinde kod istemin yönünden (fn_hizmet_sut_kodu, 1232),
    --   ad SKRS SUT listesinden (resmî), yoksa hizmet adı + yön eki.
    'SutKodu',          coalesce(public.fn_hizmet_sut_kodu(i.hizmet_id, i.yon, i.kontrast), ''),
    'SutAdi',           coalesce((select ss.ad from public.skrs_sut ss
                                   where s.standart = 3 and ss.kod = public.fn_hizmet_sut_kodu(i.hizmet_id, i.yon, i.kontrast)),
                                 coalesce(s.ad, '') || public.fn_radyoloji_yon_ek(i.yon)),
    'Loinc',            case when coalesce(s.loinc, '') = '' then '[]'::jsonb
                             else jsonb_build_array(jsonb_build_object('Kod', s.loinc, 'Ad', coalesce(nullif(s.kisa_ad, ''), s.ad, ''))) end,
    'KlinikBilgi',      coalesce(i.klinik_bilgi, ''),
    'SysTakipNo',       coalesce(nullif(ref.sys_takip_no, ''), bb.sys_takip_no, ''),
    'HastaneReferansi', coalesce(nullif(ref.hastane_referans, ''), ''),
    'Modalite',         public.fn_rad_modalite_kod(i.modalite),   -- 1303: ORU'nun kullandığı Bakanlık kodu (810)
    'Teknisyen',        case when i.tekniker_id is null then jsonb_build_object()
                             else jsonb_build_object('Kimlik', i.tekniker_id::text, 'Soyad', upper(coalesce(tk.soyad, '')),
                                                     'Ad', upper(coalesce(tk.ad, ''))) end,
    'Tanilar',          coalesce(tn.liste, '[]'::jsonb)
  )
    from i
    join public.taraf h on h.id = i.hasta_id
    left join public.taraf_hasta th on th.id = h.id
    left join public.ulke u on u.id = th.uyruk
    left join public.sube sb on sb.id = i.sube_id
    left join public.belge_basvuru bb on bb.id = i.belge_id
    left join public.departman dp on dp.id = bb.bolum_id
    left join public.belge_provizyon bp on bp.id = i.belge_id
    left join public.randevu rv on rv.id = i.randevu_id
    left join public.hizmet s on s.id = i.hizmet_id
    left join public.taraf hk on hk.id = i.istek_hekim_id
    left join public.taraf tk on tk.id = i.tekniker_id
    left join public.taraf gt on gt.id = i.ekleyen          -- kullanıcı = taraf (taraf_kullanici)
    left join lateral (select * from public.fn_enabiz_basvuru_referans(i.belge_id)) ref on i.belge_id is not null
    left join lateral (
      -- Başvurunun muayene tanıları (kesin = F, diğerleri A); yoksa istemin ön tanısındaki ICD kodu.
      select jsonb_agg(jsonb_build_object('Icd', x.icd, 'Ad', x.ad, 'Tur', x.tur) order by x.sira) as liste
        from (
          select t.icd_kod as icd, coalesce(ic.ad, '') as ad, case when t.kesinlik = 1 then 'F' else 'A' end as tur,
                 t.sira * 1000 + t.id as sira
            from public.muayene m
            join public.tani t on t.muayene_id = m.id
            left join public.icd ic on ic.kod = t.icd_kod
           where i.belge_id is not null and m.belge_id = i.belge_id
          union all
          select substring(i.on_tani from '^([A-Z][0-9]{2}(?:\.[0-9A-Z]{1,4})?)'), coalesce(ic.ad, ''), 'A', 1
            from (select 1) z
            left join public.icd ic on ic.kod = substring(i.on_tani from '^([A-Z][0-9]{2}(?:\.[0-9A-Z]{1,4})?)')
           where substring(coalesce(i.on_tani, '') from '^([A-Z][0-9]{2}(?:\.[0-9A-Z]{1,4})?)') is not null
             and not exists (select 1 from public.muayene m join public.tani t on t.muayene_id = m.id
                              where i.belge_id is not null and m.belge_id = i.belge_id)
        ) x
    ) tn on true
$$;
comment on function public.fn_teletip_orm_verisi(integer) is
  '1302/1303: Teletıp ORM mesaj verisi (jsonb, anahtarlar = C# OrmVerisi). SUT = fn_hizmet_sut_kodu + skrs_sut (ORU ile aynı).';

commit;
