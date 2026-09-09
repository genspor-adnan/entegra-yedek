-- =====================================================================
--  493_kurum_turu_kurumu_oder.sql
--  Kurum türü listesi (kullanıcı):
--      1 Özel (Ücretli) · 2 ÖSS (Özel Sağlık Sigortası)
--      3 SGK (Sosyal Güvenlik Kurumu) · 4 Kurumu Öder
--
--  "KURUMU ÖDER" anlaşmalı kurumdur (örn. Maltepe Nakliyat): hastadan
--  ücret ALINMAZ, hizmetin tamamı kuruma tahakkuk eder ve dönem sonunda
--  kuruma faturalanır. ÖSS'den farkı poliçe/provizyon olmaması: sözleşme
--  alt kurum (ÖSS/TSS/Karma) istemez, karşılama her zaman %100'dür.
--
--  Hastadan indirimli ücret alınıp faturası HASTAYA kesilen anlaşma
--  (örn. Zirve Sendikası) bu tür DEĞİLDİR: orada ödeyen hastadır, kurum
--  yalnız tarifeyi belirler - tür 1/2 + indirimli fiyat listesi.
--
--  Deger 4 daha önce TSS içindi ve 467'de pasife alınmıştı; tur = 4 olan
--  kayıt kalmadığı için (467 hepsini 3'e çekti) numara yeniden kullanılır.
-- =====================================================================

do $$
declare v_liste integer;
begin
    select id into v_liste from public.kod_liste where kod = 'taraf.kurum_turu';
    if v_liste is null then
        raise notice '493: taraf.kurum_turu kod listesi yok, atlandi.';
        return;
    end if;

    -- Eski TSS artigi kayit kalmis mi (467 temizlemis olmali).
    if exists (select 1 from public.taraf_kurum where tur = 4) then
        raise notice '493: tur = 4 kurum var - eski TSS artigi olabilir, kontrol edin.';
    end if;

    update public.kod_deger set ad = 'Özel (Ücretli)', aktif = 1
     where liste_id = v_liste and deger = 1;
    update public.kod_deger set ad = 'ÖSS (Özel Sağlık Sigortası)', aktif = 1
     where liste_id = v_liste and deger = 2;
    update public.kod_deger set ad = 'SGK (Sosyal Güvenlik Kurumu)', aktif = 1
     where liste_id = v_liste and deger = 3;

    if exists (select 1 from public.kod_deger where liste_id = v_liste and deger = 4) then
        update public.kod_deger set ad = 'Kurumu Öder', aktif = 1, sira = 4
         where liste_id = v_liste and deger = 4;
    else
        insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
        values (v_liste, 4, 'Kurumu Öder', 4, 1);
    end if;
end $$;

-- ROTA: "Kurumu Öder" ÖSS rotasını (2) kullanır - kova hesabı aynıdır,
--   kurum payı karşılama yüzdesinden çıkar ve o yüzde 100'dür. Yeni bir
--   rota açmak fn_belge_satir_dagit'ten kapanma/tahsilat/prim zincirine
--   kadar her yeri ikinci kez dallandırırdı; kazanç yok.
create or replace function public.fn_dagilim_rota(p_tur smallint,
                                                  p_alt_kurum smallint default 0,
                                                  p_sgk_kullan smallint default 1)
returns smallint
language sql
immutable
as $$
    select case
        when coalesce(p_tur, 1) = 1 then 1::smallint
        when p_tur = 3 then 5::smallint
        when p_tur = 4 then 2::smallint      -- Kurumu Öder: tamamı kurum payı
        when p_tur = 2 then case coalesce(p_alt_kurum, 201)
                                 when 202 then 3::smallint
                                 when 203 then case when coalesce(p_sgk_kullan, 1) = 1
                                                    then 4::smallint else 2::smallint end
                                 else 2::smallint end
        else 1::smallint end;
$$;

comment on function public.fn_dagilim_rota(smallint, smallint, smallint) is
  'Ödeme rotası (470/493): 1 Özel · 2 ÖSS/Kurumu Öder · 3 TSS · 4 Karma · 5 SGK.';

-- SÖZLEŞME KURALLARI: "Kurumu Öder" türünde alt kurum yok, karşılama %100.
create or replace function public.tg_kurum_sozlesme_kontrol()
returns trigger
language plpgsql
as $function$
declare v_tur smallint;
begin
    select tur into v_tur from public.taraf_kurum where id = new.kurum_id;
    if v_tur is null then
        raise exception 'Sözleşme açılan taraf bir KURUM değil (taraf_kurum kaydı yok).';
    end if;

    -- KURUMU ÖDER (493): poliçe türü yoktur, tamamını kurum karşılar.
    if v_tur = 4 then
        new.alt_kurum := 0;
        if coalesce(new.varsayilan_karsilama, 0) = 0 then
            new.varsayilan_karsilama := 100;
        end if;
    end if;

    if new.alt_kurum <> 0 and (new.alt_kurum / 100) <> v_tur then
        raise exception 'Alt kurum (%) bu kurumun türüne (%) uymuyor.',
              new.alt_kurum, v_tur;
    end if;

    -- ÖSS sözleşmesi alt kurumsuz olamaz: rota (ÖSS/TSS/Karma) buradan çıkar.
    if v_tur = 2 and new.alt_kurum = 0 then
        raise exception 'ÖSS sözleşmesinde poliçe türü (ÖSS/TSS/Karma) seçilmeli.';
    end if;

    -- SGK payı olan sözleşmede SGK carisi zorunlu; SGK kurumunda kendisidir.
    if new.sgk_kurum_id is null then
        if v_tur = 3 then new.sgk_kurum_id := new.kurum_id;
        elsif new.alt_kurum in (202, 203) then
            raise exception 'TSS/Karma sözleşmesinde SGK carisi seçilmeli.';
        end if;
    end if;

    if new.bitis is not null and new.baslangic is not null
       and new.bitis < new.baslangic then
        raise exception 'Sözleşme bitişi başlangıcından önce olamaz.';
    end if;
    return new;
end $function$;
