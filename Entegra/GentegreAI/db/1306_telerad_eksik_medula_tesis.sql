-- 1306 - ORU (Bakanlık teleradyoloji teslimi) ön kontrolü MEDULA tesis kodunu ister
--
-- Kullanıcı 11.11.2026: "ORU kontrolüne de Medula tesis kodunu ekle". ORU'nun ORC-21'i (kılavuz 3.43 Tablo 20)
-- "Kurum^^SKRS\S\şube\S\MEDULA tesis" - son bileşen raporu gönderenin (bizim) MEDULA tesis kodu, teslim sorgusu
-- kurum_profil.tesis_kodu'ndan okur. ORM denetimiyle (OrmUretici.Denetle) aynı kural: boşsa eksik, 8 haneli sayı değilse
-- eksik. Fonksiyonun geri kalanı 812'deki gibi.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_telerad_bakanlik_eksik(p_istek_id integer)
returns text
language plpgsql stable as $$
declare
    r        record;
    v_liste  text[] := '{}';
    v_ref    record;
    v_rapor  text;
begin
    select i.id, i.dis_erisim_no, i.dis_hasta_kimlik, i.isteyen_hekim_tckn,
           i.modalite, i.rapor_id, i.radyoloji_istem_id, i.study_uid,
           coalesce(k.bakanlik_gonderim, 0) as bakanlik,
           coalesce(k.skrs_kodu, '')        as skrs,
           coalesce(k.msh_uygulama, '')     as msh3,
           -- 1306: ORC-21 son bileşeni - raporu gönderen BİZİM MEDULA tesis kodumuz (teslim sorgusuyla aynı kaynak).
           coalesce((select kp.tesis_kodu from public.kurum_profil kp
                      where kp.sube_id in (i.sube_id, 0) and coalesce(kp.tesis_kodu, '') <> ''
                      order by (kp.sube_id = i.sube_id) desc limit 1), '') as medula_tesis,
           ri.belge_id,
           rp.onaylayan_id, rp.istem_nedeni_puan, rp.cekim_kalite_puan,
           coalesce(t.vkno, '')             as radyolog_tckn
      into r
      from public.telerad_istek i
      join public.telerad_kurum k on k.id = i.kurum_id
      left join public.radyoloji_istem ri on ri.id = i.radyoloji_istem_id
      left join public.radyoloji_rapor rp on rp.id = i.rapor_id
      left join public.taraf t on t.id = rp.onaylayan_id
     where i.id = p_istek_id;

    if not found then return 'İstek bulunamadı.'; end if;
    if r.bakanlik <> 1 then return ''; end if;   -- hedef kapalı: kontrol yok

    if btrim(r.dis_erisim_no) = ''   then v_liste := array_append(v_liste, 'erişim (accession) numarası'); end if;
    if btrim(r.dis_hasta_kimlik) = '' then v_liste := array_append(v_liste, 'hasta TCKN (PID-4)'); end if;
    if btrim(r.isteyen_hekim_tckn) = '' then v_liste := array_append(v_liste, 'isteyen hekim TCKN (ORC-12)'); end if;
    if btrim(r.skrs) = ''            then v_liste := array_append(v_liste, 'kurum SKRS kodu (ORC-21)'); end if;
    if btrim(r.msh3) = ''            then v_liste := array_append(v_liste, 'firma kodu (MSH-3)'); end if;
    -- 1306 (kullanıcı 11.11.2026: "ORU kontrolüne de Medula tesis kodunu ekle"): ORM denetimiyle aynı kural.
    if btrim(r.medula_tesis) = '' then
        v_liste := array_append(v_liste, 'MEDULA tesis kodu (ORC-21) - kurum profilinde tesis kodu');
    elsif r.medula_tesis !~ '^[0-9]{8}$' then
        v_liste := array_append(v_liste, 'MEDULA tesis kodu 8 haneli sayı olmalı (ORC-21)');
    end if;
    if public.fn_rad_modalite_kod(r.modalite) = '' then
        v_liste := array_append(v_liste, 'modalite DICOM karşılığı (OBR-24)');
    end if;

    if r.rapor_id is null then
        v_liste := array_append(v_liste, 'onaylı rapor');
    else
        v_rapor := public.fn_rad_bakanlik_eksik(r.rapor_id);
        if v_rapor <> '' then v_liste := array_append(v_liste, v_rapor); end if;
        if btrim(coalesce(r.radyolog_tckn, '')) = '' then
            v_liste := array_append(v_liste, 'raporu onaylayan radyolog TCKN (OBX-16)');
        end if;
        if coalesce(r.istem_nedeni_puan, 0) = 0 or coalesce(r.cekim_kalite_puan, 0) = 0 then
            v_liste := array_append(v_liste, 'istem nedeni / çekim kalitesi puanı (OBX-13)');
        end if;
    end if;

    if r.belge_id is not null then
        select * into v_ref from public.fn_enabiz_basvuru_referans(r.belge_id);
        if coalesce(v_ref.sys_takip_no, '') = '' then
            v_liste := array_append(v_liste, 'e-Nabız SYSTakipNo (OBR-20)');
        end if;
        if coalesce(v_ref.hastane_referans, '') = '' then
            v_liste := array_append(v_liste, 'hastane başvuru referans numarası (OBR-21 / PV1-19)');
        end if;
    end if;

    return array_to_string(v_liste, ' · ');
end $$;

commit;
