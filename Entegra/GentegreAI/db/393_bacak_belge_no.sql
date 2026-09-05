-- ============================================================================
--  393 - TAHSILAT BACAKLARINA BELGE NO YAZILMIYORDU
--
--  Kasa isleminin mali hareketleri `belge_id`'yi tasiyor ama `belge_no` bos
--  kaliyordu (`''` sabiti). Cari/hesap ekstresinde tahsilat satirinin
--  "Belge No" hucresi bu yuzden bostu; numaralandirma ayari aciktı ve belge
--  numarasi VARDI - yalniz bacaga tasinmiyordu.
--
--  Uretici duzeltilir + gecmis satirlar doldurulur.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_kasa_islem_bacak_uret(p_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
    ki      record;
    tr      record;
    s       jsonb;
    v_rol   text;
    v_yon   text;
    v_tutar numeric(19,4);
    v_hid   integer;
    v_htur  varchar(1);
    v_tid   integer;
    v_mid   integer;
    v_zid   integer;
    v_doviz varchar(6);
    v_kur   numeric(19,6);
    v_yerel numeric(19,4);
    v_sira  smallint := 0;
    v_sayi  integer  := 0;
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa islemi bulunamadi: %', p_id using errcode = 'GK422';
    end if;
    if ki.durum >= 2 then
        raise exception 'Gerçekleşmiş işlemin bacakları yeniden üretilemez (%).', p_id
            using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;
    if not found then
        raise exception 'Bilinmeyen işlem türü: %', ki.tur using errcode = 'GK422';
    end if;

    delete from public.mali_hareket where kasa_islem_id = p_id;

    for s in select * from jsonb_array_elements(coalesce(tr.sablon, '[]'::jsonb))
    loop
        v_rol := s ->> 'rol';
        v_yon := coalesce(s ->> 'yon', 'B');

        v_tutar := case coalesce(s ->> 'tutar', '@tutar')
                       when '@tutar'        then ki.tutar
                       when '@masraf_tutar' then ki.masraf_tutar
                       when '@karsi_tutar'  then ki.karsi_tutar
                       else 0 end;
        if coalesce(v_tutar, 0) = 0 then continue; end if;   -- masraf yoksa o bacak yok

        v_hid := null; v_htur := '-'; v_tid := null; v_mid := null; v_zid := null;
        v_doviz := ki.doviz_cinsi; v_kur := ki.doviz_kuru;

        if v_rol = 'ana' then
            v_hid := ki.hesap_id;
        elsif v_rol = 'karsi' then
            v_hid := ki.karsi_hesap_id;
            if coalesce(s ->> 'tutar', '') = '@karsi_tutar' then
                v_doviz := nullif(ki.karsi_doviz_cinsi, '');
                v_kur   := nullif(ki.karsi_kur, 0);
            end if;
        elsif v_rol in ('cari', 'karsi_cari') then
            v_htur := 'C';
            v_tid  := case when v_rol = 'cari' then ki.taraf_id else ki.karsi_taraf_id end;
            -- EKSTRE DOVIZI (139): cari bacagi baska bir birimde tutulabilir.
            --   Yerel paraya cevrilirse tutar kurla carpilir, kur 1 olur -
            --   bacagin yerel karsiligi ayni kalir, denge bozulmaz.
            if coalesce(ki.ekstre_dovizi, '') <> ''
               and ki.ekstre_dovizi <> ki.doviz_cinsi then
                if ki.ekstre_dovizi = 'TL' then
                    v_tutar := round(v_tutar * coalesce(nullif(ki.doviz_kuru, 0), 1), 2);
                    v_doviz := 'TL';
                    v_kur   := 1;
                else
                    v_doviz := ki.ekstre_dovizi;
                end if;
            end if;
        elsif v_rol in ('masraf', 'kalem') then
            v_htur := 'M';
            v_mid  := ki.masraf_id;
            v_zid  := ki.hizmet_id;
        elsif v_rol = 'ceksenet' then
            -- Portfoy SANAL hesabi: hesap_id yok, cek/senet kaydinin kendisi tasir.
            v_htur := 'E';
            if ki.cek_senet_id is null then
                raise exception 'Çek/senet işlemi için çek/senet kaydı seçilmeli (işlem %).', p_id
                    using errcode = 'GK422';
            end if;
        elsif v_rol in ('kambiyo_kar', 'kambiyo_zarar', 'kurfarki') then
            -- Kur/kambiyo farki bacagi: hesapsiz, eslestirme tur+rol istisnasindan.
            v_htur := '-';
        else
            -- Sessizce '-' birakmak, muhasebede 500 SERMAYE'ye yazan yanlis fis
            --   demekti. Tanimsiz rol acik hata verir.
            raise exception 'İşlem türü %: tanımsız bacak rolü "%s".', ki.tur, coalesce(v_rol, '')
                using errcode = 'GK422';
        end if;

        if v_hid is not null then
            select h.tur, h.doviz_cinsi into v_htur, v_doviz from public.hesap h where h.id = v_hid;
            if v_doviz = ki.doviz_cinsi then v_kur := ki.doviz_kuru; end if;
        end if;

        v_doviz := coalesce(nullif(v_doviz, ''), 'TL');
        v_kur   := case when v_doviz = 'TL' then 1 else coalesce(nullif(v_kur, 0), ki.doviz_kuru, 1) end;
        v_yerel := round(v_tutar * v_kur, 2);
        v_sira  := v_sira + 1;

        insert into public.mali_hareket
            (kasa_islem_id, sira, rol, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no,
             islem_tarihi, plan_tarihi,
             borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru,
             durum, masraf_id, hizmet_id, proje_id, merkez_id, cek_senet_id,
             ekstrede_kullan, aciklama, sube_id, giris_kaynak, ekleyen)
        values (p_id, v_sira, coalesce(v_rol, ''), ki.tur, coalesce(v_htur, '-'), v_hid, v_tid,
                ki.belge_id,
                -- 393: BELGE NO da yazilir. Bos birakiliyordu; ekstrede tahsilat
                --   satirinin "Belge No" hucresi bos goruntuluyordu (kullanici:
                --   "ayarlarda aktif oldugu halde tahsilatlar icin belge no
                --   vermemis") - numara VERILMISTI, bacaga tasinmiyordu.
                coalesce((select b.belge_no from public.belge b
                           where b.id = ki.belge_id), ''),
                ki.islem_tarihi::timestamp, ki.plan_tarihi,
                case when v_yon = 'B' then v_tutar else 0 end,
                case when v_yon = 'A' then v_tutar else 0 end,
                case when v_yon = 'B' then v_yerel else 0 end,
                case when v_yon = 'A' then v_yerel else 0 end,
                v_doviz, v_kur,
                ki.durum, v_mid, v_zid, ki.proje_id, ki.merkez_id, ki.cek_senet_id,
                coalesce(tr.bakiye_dahil, 1), left(ki.aciklama, 100), ki.sube_id,
                coalesce(ki.giris_kaynak, 1), ki.ekleyen);

        v_sayi := v_sayi + 1;
    end loop;

    if v_sayi = 0 then
        raise exception 'İşlem türü % için bacak üretilemedi (şablon boş ya da tutarlar sıfır).', ki.tur
            using errcode = 'GK422';
    end if;

    return v_sayi;
end $function$;


-- Gecmisin onarimi: belgesi olan ama numarasi bos kalmis bacaklar.
update public.mali_hareket m
   set belge_no = b.belge_no
  from public.belge b
 where b.id = m.belge_id
   and m.kasa_islem_id is not null
   and coalesce(m.belge_no, '') = ''
   and coalesce(b.belge_no, '') <> '';
