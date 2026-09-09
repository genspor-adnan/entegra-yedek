-- =====================================================================
--  490_kurum_kurulum_adimlari.sql
--  Kurum Profili > "7 · Özet & Kurulum" kurulum adimlari CANLI.
--
--  Ekrandaki tablo mockup'tan gelen SABIT sekiz satirdi: hangi adim
--  gercekten tamam, hangisi bekliyor soylemiyordu (kullanici: "kurulum
--  adimlari tablosunu da canliya bagla"). Kural SUNUCUDA: her adimin
--  "tamam" sarti bir sayim/varlik sorgusudur, istemci yalnizca sonucu
--  cizer.
--
--  Adim kumesi urun moduna ve ACIK MODULLERE gore degisir - ERP
--  kurulumunda SKRS/e-Nabiz/muayene sablonu adimi hic listelenmez, olmayan
--  bir isi "bekliyor" diye gostermek yanlis olurdu.
-- =====================================================================

create or replace function public.fn_kurum_kurulum_adimlari(p_sube integer default 0)
returns table (sira smallint, kod varchar, ad varchar, durum smallint,
               bilgi varchar, rota varchar, aksiyon varchar)
language plpgsql
stable
as $$
declare
    v_mod        smallint := public.fn_urun_modu(p_sube);
    v_saglik     boolean  := v_mod in (2, 3);
    v_sube       record;
    v_tesis      varchar;
    v_hekim      integer;
    v_tani       integer;
    v_ilac       integer;
    v_liste      integer;
    v_hizmet     integer;
    v_sms        integer;
    v_sablon     integer;
    v_rol        integer;
    v_kullanici  integer;
    v_enabiz_ok  integer;
    v_enabiz_hep integer;
begin
    -- 1) FIRMA / SUBE / TESIS KODU -------------------------------------
    select s.unvan, s.vkno, s.vd, s.adres, s.il into v_sube
      from public.sube s
     where s.id = case when coalesce(p_sube, 0) > 0 then p_sube else s.id end
     order by (s.id = p_sube) desc, s.varsayilan desc, s.id
     limit 1;

    select coalesce(p.tesis_kodu, '') into v_tesis
      from public.fn_kurum_profil(p_sube) p;

    sira := 1; kod := 'firma'; ad := 'Firma bilgileri, şube, tesis kodu';
    rota := '/sube'; aksiyon := 'Firma Bilgileri';
    if v_sube is null then
        durum := 0; bilgi := 'şube tanımlı değil';
    elsif coalesce(v_sube.unvan, '') = '' or coalesce(v_sube.vkno, '') = ''
       or coalesce(v_sube.adres, '') = '' then
        durum := 0;
        bilgi := 'eksik: ' || trim(both ', ' from
                   case when coalesce(v_sube.unvan, '') = '' then 'ünvan, ' else '' end
                || case when coalesce(v_sube.vkno,  '') = '' then 'VKN, '   else '' end
                || case when coalesce(v_sube.adres, '') = '' then 'adres, ' else '' end);
    elsif v_saglik and v_tesis = '' then
        durum := 0; bilgi := 'tesis kodu (ÇKYS) boş';
    else
        durum := 1; bilgi := v_sube.unvan;
    end if;
    return next;

    -- 2) HEKIM KARTLARI (yalniz saglik) --------------------------------
    if v_saglik then
        select count(*) into v_hekim
          from public.taraf_hekim h
         where h.dis_mi = 0 and coalesce(h.tescil_no, '') <> '';
        sira := 2; kod := 'hekim'; ad := 'Hekim kartları (tescil, ÇKYS, e-imza)';
        rota := '/personel'; aksiyon := 'Personel';
        durum := case when v_hekim > 0 then 1 else 0 end;
        bilgi := case when v_hekim > 0 then v_hekim || ' hekim (tescil no dolu)'
                      else 'tescil no dolu hekim yok' end;
        return next;
    end if;

    -- 3) SKRS LISTELERI (yalniz saglik) --------------------------------
    if v_saglik then
        select count(*) into v_tani from public.tani;
        select count(*) into v_ilac from public.ilac;
        sira := 3; kod := 'skrs'; ad := 'SKRS listeleri (ICD-10, ilaç, klinik) senkronu';
        rota := '/ilac'; aksiyon := 'İlaç Kataloğu';
        durum := case when v_tani > 0 and v_ilac > 0 then 1 else 0 end;
        bilgi := v_tani || ' tanı · ' || v_ilac || ' ilaç';
        return next;
    end if;

    -- 4) FIYAT LISTESI + HIZMET KATALOGU -------------------------------
    select count(*) into v_liste  from public.fiyat_listesi;
    select count(*) into v_hizmet from public.hizmet;
    sira := 4; kod := 'fiyat'; ad := 'Fiyat listesi + hizmet kataloğu';
    rota := '/fiyat-listesi'; aksiyon := 'Fiyat Listeleri';
    durum := case when v_liste > 0 and v_hizmet > 0 then 1 else 0 end;
    bilgi := v_liste || ' liste · ' || v_hizmet || ' hizmet';
    return next;

    -- 5) SMS SAGLAYICI --------------------------------------------------
    select count(*) into v_sms
      from public.entegrasyon_hesap e
     where e.aktif = 1 and upper(e.kod) in ('SMS', 'SMSAPI', 'NETGSM');
    sira := 5; kod := 'sms'; ad := 'SMS sağlayıcı hesabı';
    rota := '/genel-ayarlar'; aksiyon := 'Entegrasyon Hesapları';
    durum := case when v_sms > 0 then 1 else 0 end;
    bilgi := case when v_sms > 0 then 'tanımlı' else 'hesap yok (hatırlatma SMS''i gitmez)' end;
    return next;

    -- 6) MUAYENE SABLONU (yalniz saglik + muayene modulu) --------------
    if v_saglik and public.fn_kurum_modul_acik('muayene', p_sube) then
        select count(*) into v_sablon from public.muayene_sablon;
        sira := 6; kod := 'sablon'; ad := 'Muayene şablonu, sık tanı, reçete şablonları';
        rota := '/muayene-sablon'; aksiyon := 'Muayene Şablonları';
        durum := case when v_sablon > 0 then 1 else 0 end;
        bilgi := v_sablon || ' şablon';
        return next;
    end if;

    -- 7) ROLLER VE KULLANICILAR ----------------------------------------
    select count(*) into v_rol      from public.rol;
    select count(*) into v_kullanici from public.taraf_kullanici;
    sira := 7; kod := 'rol'; ad := 'Roller ve kullanıcılar';
    rota := '/rol'; aksiyon := 'Roller';
    durum := case when v_rol > 0 and v_kullanici > 1 then 1 else 0 end;
    bilgi := v_rol || ' rol · ' || v_kullanici || ' kullanıcı';
    return next;

    -- 8) e-NABIZ GONDERIMI (yalniz saglik + muayene modulu) ------------
    if v_saglik and public.fn_kurum_modul_acik('muayene', p_sube) then
        -- enabiz_gonderim.sonuc: 1 basarili · 2 hata (415).
        select count(*) filter (where g.sonuc = 1), count(*)
          into v_enabiz_ok, v_enabiz_hep
          from public.enabiz_gonderim g;
        sira := 8; kod := 'enabiz'; ad := 'e-Nabız test gönderimi';
        rota := '/enabiz-paket'; aksiyon := 'e-Nabız Kuyruğu';
        durum := case when coalesce(v_enabiz_ok, 0) > 0 then 1 else 0 end;
        bilgi := case when coalesce(v_enabiz_hep, 0) = 0 then 'hiç gönderim yok'
                      else coalesce(v_enabiz_ok, 0) || '/' || v_enabiz_hep || ' başarılı' end;
        return next;
    end if;
end $$;

comment on function public.fn_kurum_kurulum_adimlari(integer) is
  'Kurum Profili ozet sekmesindeki kurulum adimlari (490): her adimin '
  '"tamam" sarti sunucuda sorgulanir; saglik/modul disi adimlar hic donmez.';
