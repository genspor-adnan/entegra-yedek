-- ============================================================================
--  Gentegre AI — ÇAĞRI MERKEZİ ROLLERİ (AJAN · SORUMLU)
--  791_cagri_merkezi_rolleri.sql
--
--  Kullanıcı: *"Çağrı Merkezi Ajanı ve Çağrı Merkezi Sorumlusu da ekle 2 tane"*.
--
--  ============ NE YAPARLAR ============================================
--  Telefonla randevu alan ekip. İkisi de bankonun ekranlarında DEĞİL kendi dar
--  alanlarında çalışır:
--
--    · AJAN     — randevu al/değiştir · hasta ve aday kaydı · hekim uygunluğu
--                 (çalışma planını görür) · anlaşmalı kurum ve hizmet sorgusu ·
--                 gönderilen hatırlatmaları görür.
--    · SORUMLU  — ajanın hepsi + randevu İPTALİ (sil) · hatırlatma şablonları ·
--                 bildirim kuyruğu · işlem günlüğü (kim neyi değiştirdi).
--
--  ============ PARA EKRANI YOK ========================================
--  Bilerek: `belge`, `kasa_islem`, `mali_hareket` yok. Telefonda borç/tahsilat
--  konuşmak bankonun işidir; çağrı merkezine hastanın hesabını açmak, en çok
--  personel devri olan masaya en hassas veriyi vermek olurdu.
--
--  Hasta kaydı AÇABİLİR (telefonda randevu için gerekir) ama SİLEMEZ.
--
--  ============ RANDEVU MODÜLÜNE BAĞLI =================================
--  Şablon-modül haritasında (`SablonModul`) `randevu` modülüne bağlılar:
--  randevu kapalıysa telefonla randevu alacak bir ekip de yoktur, rol
--  önerilmez.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_rol   integer;
    v_var   integer;
    r       record;
    -- (kod, ad, amac) ve yetki kaliplari asagida dizilerle veriliyor: iki rol
    --   ayni govdeyi paylassin, ikisi arasindaki FARK gorunur olsun.
begin
    for r in
        select * from (values
            ('cagri_ajani',   'Çağrı Merkezi Ajanı',
             'Telefonla randevu alma/değiştirme, hasta ve aday kaydı, hekim uygunluğu.'),
            ('cagri_sorumlu', 'Çağrı Merkezi Sorumlusu',
             'Ajanların işi + randevu iptali, hatırlatma şablonları, kuyruk ve günlük takibi.')
        ) as x(kod, ad, amac)
    loop
        select id into v_rol from public.rol where kod = r.kod;
        if v_rol is not null then
            raise notice '791: % rolu zaten var (id %) - dokunulmadi.', r.kod, v_rol;
            continue;
        end if;

        insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen)
        values (r.kod, r.ad, r.amac, 1, 1, 0)
        returning id into v_rol;

        -- ORTAK (her rolde): ana sayfa, mesaj, gorev, dokum, AI rehber, dokuman.
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_rol, y.id, 1,
               case when y.kod in ('mesaj', 'gorev', 'dokuman') then 1 else 0 end,
               case when y.kod in ('mesaj', 'gorev') then 1 else 0 end, 0, ''
          from public.yetki y
         where y.kod in ('panel', 'mesaj', 'gorev', 'dokum', 'ai', 'ai.rehber', 'dokuman')
           and y.aktif = 1;

        -- ISIN KENDISI. Sorumlu farki: randevu/aday SILEBILIR, bildirim
        --   sablonu yazar, islem gunlugunu gorur.
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_rol, y.id, 1,
               case when y.kod in ('randevu', 'hasta', 'aday', 'firsat', 'bildirim',
                                   'bildirim_sablon')
                         and (y.kod <> 'firsat'  or r.kod = 'cagri_sorumlu')
                         and (y.kod <> 'bildirim'        or r.kod = 'cagri_sorumlu')
                         and (y.kod <> 'bildirim_sablon' or r.kod = 'cagri_sorumlu')
                    then 1 else 0 end,
               case when y.kod in ('randevu', 'hasta', 'aday', 'firsat', 'bildirim',
                                   'bildirim_sablon')
                         and (y.kod <> 'firsat'  or r.kod = 'cagri_sorumlu')
                         and (y.kod <> 'bildirim'        or r.kod = 'cagri_sorumlu')
                         and (y.kod <> 'bildirim_sablon' or r.kod = 'cagri_sorumlu')
                    then 1 else 0 end,
               -- SILME yalniz sorumluda ve yalniz randevu/aday icin: hasta
               --   kaydini cagri merkezi silemez.
               case when r.kod = 'cagri_sorumlu' and y.kod in ('randevu', 'aday')
                    then 1 else 0 end,
               ''
          from public.yetki y
         where y.aktif = 1
           and (y.kod in ('randevu', 'randevu.plan', 'hasta', 'aday', 'kurum',
                          'hizmet', 'muayene')
                or (r.kod = 'cagri_sorumlu'
                    and y.kod in ('firsat', 'bildirim', 'bildirim_sablon', 'islem_log'))
                or (r.kod = 'cagri_ajani' and y.kod in ('firsat', 'bildirim')))
           and not exists (select 1 from public.rol_yetki ry
                            where ry.rol_id = v_rol and ry.yetki_id = y.id);

        insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
        select v_rol, s.id, s.varsayilan, 1, 0 from public.sube s where s.aktif = 1
        on conflict do nothing;

        select count(*) into v_var from public.rol_yetki where rol_id = v_rol;
        raise notice '791: "%" rolu kuruldu (id %, % yetki).', r.ad, v_rol, v_var;
    end loop;
end $$;

do $$
declare v_p int;
begin
    -- PARA EKRANI OLMAMALI: kural yukarida yazili, burada DOGRULANIYOR -
    --   sonradan biri sablona `belge` eklerse bu satir sessiz kalmasin.
    select count(*) into v_p
      from public.rol r
      join public.rol_yetki ry on ry.rol_id = r.id
      join public.yetki y on y.id = ry.yetki_id
     where r.kod in ('cagri_ajani', 'cagri_sorumlu')
       and y.kod in ('belge', 'belge_satir', 'kasa_islem', 'mali_hareket', 'hesap');
    if v_p > 0 then
        raise exception 'Cagri merkezi rollerinde para ekrani yetkisi var (% satir) - '
                        'telefonda borc konusmak bankonun isidir.', v_p
              using errcode = 'GK422';
    end if;
    raise notice '791 tamam: cagri merkezi rollerinde para ekrani yok.';
end $$;
