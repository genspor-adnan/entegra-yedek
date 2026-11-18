-- 1367 - Kasa / para incelemesi (18.11.2026) bulgu 5, 6, 8:
--   5) fn_kasa_islem_bacak_uret: ekstre dövizi işlem dövizinden ve yerel paradan farklıysa (TL tahsilat, USD ekstre)
--      cari bacağına çevrilmemiş tutar yabancı etiketle yazılıyordu - artık reddedilir (139: iki seçenek var).
--   6) fn_kasa_islem_duzelt_hazirla: gerçekleşmiş işlemin planına eklenen tutar geri alınmıyordu (düzeltmede plan
--      iki kez sayılıyordu); kapanmış plan (durum 4) taslağa düşüyordu - artık reddedilir.
--   8) tg_kasa_dagitim_kontrol: eşzamanlı iki tahsilat aynı satır payını iki kez kapatabiliyordu - satır kilidi.
--   Fonksiyonların geri kalanı kaynaklarıyla (393, 148, 660) birebir. Veri değiştirmez.
\set ON_ERROR_STOP on

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
                    -- 1367 UCUNCU DOVIZ YOK (para incelemesi 18.11.2026): yalniz ETIKET degisiyordu - 4800 TL
                    --   tahsilat USD ekstreli cariye 4800 USD alacak yaziliyordu (kur 1, tutar cevrilmeden).
                    --   139'un kurali: ekstre dovizi islem dovizi ya da yerel para; capraz kur bilinmez.
                    raise exception 'Ekstre dövizi (%) işlem dövizi (%) ya da yerel para olmalı.',
                        ki.ekstre_dovizi, coalesce(nullif(ki.doviz_cinsi, ''), 'TL') using errcode = 'GK422';
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

create or replace function public.fn_kasa_islem_duzelt_hazirla(p_id integer)
returns void
language plpgsql
as $$
declare ki record;
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;

    if ki.durum = 3 then
        raise exception 'İptal edilmiş işlem düzeltilemez - yeni işlem girin.'
            using errcode = 'GK422';
    end if;
    if ki.durum < 2 then return; end if;      -- taslak/plan: hazirlik gerekmez
    -- 1367 KAPANMIS PLAN (4) DUZELTILMEZ: taslaga cekilip bacaklari siliniyordu; gerceklesen_tutar duruyor,
    --   plan "taslak" olarak kaliyordu. Plan gerceklesmeleriyle kapanir; degisiklik gerceklesmenin iptaliyle.
    if ki.durum = 4 then
        raise exception 'Kapanmış plan değiştirilemez - gerçekleşmesini iptal edin.' using errcode = 'GK422';
    end if;

    -- Kapanmis donem: hem eski hem YENI tarih icin bakilir (cagiran tarihi
    --   degistirmis olabilir; kontrol yeni tarih uzerinden yeniden yapilir).
    perform public.fn_muhasebe_donem_kontrol(ki.islem_tarihi);

    -- Fis SATIRLARI silinir, baslik ve numara KALIR.
    delete from public.muhasebe_fis_satir
     where fis_id in (select id from public.muhasebe_fis
                       where kaynak_tur = 1 and kaynak_id = p_id and durum = 1);

    delete from public.mali_hareket where kasa_islem_id = p_id;

    -- 1367 PLAN GERCEKLESMESI GERI ALINIR (para incelemesi 18.11.2026): kesinlestir plana ki.tutar EKLER; duzeltme
    --   geri almiyordu - 400 -> 450 duzeltilen tahsilat plana 850 yaziyor, plan erken kapaniyordu. fn_kasa_islem_iptal
    --   ile ayni geri alma; yeniden kesinlestirme YENI tutari ekler.
    if ki.plan_islem_id is not null then
        update public.kasa_islem p
           set gerceklesen_tutar = greatest(p.gerceklesen_tutar - ki.tutar, 0),
               durum = case when p.durum = 4 then 1 else p.durum end
         where p.id = ki.plan_islem_id;
    end if;

    update public.kasa_islem set durum = 0 where id = p_id;
end $$;

create or replace function public.tg_kasa_dagitim_kontrol()
returns trigger language plpgsql as $$
declare
  v_pay_tutar numeric(19,4);
  v_dagitilan numeric(19,4);
  v_islem     numeric(19,4);
begin
    if new.tutar = 0 then
        raise exception 'Dağıtılan tutar sıfır olamaz.' using errcode = 'GK422';
    end if;

    -- 1367 SATIR KILIDI (para incelemesi 18.11.2026): toplam yalniz COMMIT edilmis dagitimlari goruyordu - ayni
    --   basvuruya ayni anda iki 500 TL tahsilat ikisi de "500 acik" gorup geciyor, 500'luk paya 1000 yaziliyordu.
    --   Satir kilitlenir; bekleyen islem kilidi alinca asagidaki sorgular (READ COMMITTED, ifade basina yeni
    --   anlik goruntu) digerinin commit ettigi dagitimi gorur ve fazlasini reddeder.
    perform 1 from public.belge_satir where id = new.belge_satir_id for update;

    select coalesce(k.tutar, 0) into v_islem
      from public.kasa_islem k where k.id = new.kasa_islem_id;

    if (v_islem > 0 and new.tutar < 0) or (v_islem < 0 and new.tutar > 0) then
        raise exception 'Dağıtım satırı işlemle aynı işarette olmalı (işlem %, satır %).',
            v_islem, new.tutar using errcode = 'GK422';
    end if;
    if new.pay not in (1, 2, 3, 4, 5) then
        raise exception 'Bilinmeyen ödeme payı: %.', new.pay using errcode = 'GK422';
    end if;

    -- KDV DAHİL kova sınırı (323, 471'den aynen): tahsilat gerçek ödemedir,
    --   matrahla sınırlanamaz. KATILIM PAYI istisnadır - KDV'siz emanettir.
    select case new.pay
             when 5 then coalesce(dg.sgk_katilim_payi, 0)
             else round(case new.pay
                          when 1 then coalesce(dg.hasta_provizyon, 0)
                          when 2 then coalesce(dg.sgk, 0)
                          when 3 then coalesce(dg.oss, 0)
                          else coalesce(dg.hasta_ek_katki, 0) end
                        * (1 + coalesce(s.kdv, 0) / 100.0), 2)
           end
      into v_pay_tutar
      from public.belge_satir s
      left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
     where s.id = new.belge_satir_id;

    -- Aynı satır/paya yazılmış DİĞER satırların neti (gerçekleşmiş, iptalsiz).
    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
      join public.kasa_islem k on k.id = d.kasa_islem_id
     where d.belge_satir_id = new.belge_satir_id and d.pay = new.pay
       and d.id is distinct from new.id
       and coalesce(k.durum, 0) = 2 and k.iptal_islem_id is null;

    if coalesce(v_pay_tutar, 0) > 0 and v_dagitilan + new.tutar > v_pay_tutar + 0.005 then
        raise exception 'Satıra payından fazla tahsilat dağıtılamaz (pay %, dağıtılan %, eklenen %).',
            v_pay_tutar, v_dagitilan, new.tutar using errcode = 'GK422';
    end if;

    -- İADE SINIRI: geri alınan, o satır/paydan tahsil edilenden fazla olamaz.
    --   Olsaydı satırın tahsil edileni eksiye düşer, kapanma ve prim hesabı
    --   anlamsızlaşırdı.
    if v_dagitilan + new.tutar < -0.005 then
        raise exception 'Satırdan tahsil edilenden fazlası iade edilemez (tahsil %, iade %).',
            v_dagitilan, -new.tutar using errcode = 'GK422';
    end if;

    -- İşlemden dağıtılan toplam, işlemin tutarını aşamaz (iki yönde de).
    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
     where d.kasa_islem_id = new.kasa_islem_id and d.id is distinct from new.id;

    if abs(v_dagitilan + new.tutar) > abs(v_islem) + 0.005 then
        raise exception 'Dağıtım toplamı işlem tutarını aşamaz (işlem %, dağıtılan %).',
            v_islem, v_dagitilan + new.tutar using errcode = 'GK422';
    end if;

    return new;
end $$;

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi from public.kasa_islem
     where coalesce(ekstre_dovizi, '') <> '' and ekstre_dovizi <> doviz_cinsi and ekstre_dovizi <> 'TL';
    raise notice '1367 tamam: üçüncü döviz ekstreli kasa işlemi (inceleme için) = %', v_sayi;
end $$;
