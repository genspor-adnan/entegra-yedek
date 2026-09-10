-- =====================================================================
--  517_kurum_sozlesme_sgk_carisi.sql
--  TSS/Karma sözleşmesinde SGK carisi TEK ise kendiliğinden seçilir.
--
--  Kullanıcı yeni anlaşmalı kurum girerken "SUNUCU: Beklenmeyen bir hata
--  oluştu" alıyordu. Kök neden İKİ katmanlıydı:
--    1) Tetik kuralı doğru çalışıyordu ("TSS/Karma sözleşmesinde SGK carisi
--       seçilmeli") ama düz `raise exception` (P0001) fırlatıyor, API bunu
--       tanımadığı için 500'e çeviriyordu. Bu, API tarafında düzeltildi:
--       P0001 artık iş kuralı olarak 422 + mesaj döner.
--    2) Kural kullanıcıyı ÇIKIŞSIZ bırakıyordu: SGK carisi kurulumda zaten
--       TEK kayıttır (Sosyal Güvenlik Kurumu), ama kullanıcının onu her
--       sözleşmede elle bulup seçmesi bekleniyordu.
--
--  Bu göç ikinciyi çözer: SGK carisi verilmemişse ve kurulumda `taraf_kurum`
--  içinde tur = 3 (SGK) olan TEK kurum varsa o atanır. Birden fazlaysa (nadir;
--  devredilen kurum ayrı carilerle izleniyorsa) seçim yine kullanıcıdan
--  istenir - orada tahmin etmek yanlış cariye tahakkuk demektir.
--
--  Diğer kurallar (alt kurum uyumu, ÖSS'de poliçe türü, bitiş < başlangıç)
--  aynen korunur; hepsi artık GK422 ile fırlar - mesajın ekranda görünmesi
--  API'nin P0001 haritasına değil, tetiğin kendi etiketine bağlı olsun.
-- =====================================================================

create or replace function public.tg_kurum_sozlesme_kontrol() returns trigger
language plpgsql as $function$
declare
    v_tur      smallint;
    v_sgk      integer;
    v_sgk_adet integer;
begin
    select tur into v_tur from public.taraf_kurum where id = new.kurum_id;
    if v_tur is null then
        raise exception 'Sözleşme açılan taraf bir KURUM değil (taraf_kurum kaydı yok).'
              using errcode = 'GK422';
    end if;

    -- KURUMU ÖDER (4): alt kurum yok, karşılama %100 (493).
    if v_tur = 4 then
        new.alt_kurum := 0;
        if coalesce(new.varsayilan_karsilama, 0) = 0 then
            new.varsayilan_karsilama := 100;
        end if;
    end if;

    if new.alt_kurum <> 0 and (new.alt_kurum / 100) <> v_tur then
        raise exception 'Alt kurum (%) bu kurumun türüne (%) uymuyor.',
              new.alt_kurum, v_tur using errcode = 'GK422';
    end if;

    if v_tur = 2 and new.alt_kurum = 0 then
        raise exception 'ÖSS sözleşmesinde poliçe türü (ÖSS/TSS/Karma) seçilmeli.'
              using errcode = 'GK422';
    end if;

    -- SGK payı olan sözleşmede SGK carisi zorunlu; SGK kurumunda kendisidir.
    if new.sgk_kurum_id is null then
        if v_tur = 3 then
            new.sgk_kurum_id := new.kurum_id;
        elsif new.alt_kurum in (202, 203) then
            -- Kurulumda SGK carisi TEK ise onu kullan: kullanıcıyı her TSS/
            --   Karma sözleşmesinde aynı kaydı aramaya zorlamak, kuralı
            --   çıkışsız bir duvara çeviriyordu.
            select count(*), min(id) into v_sgk_adet, v_sgk
              from public.taraf_kurum where tur = 3;
            if v_sgk_adet = 1 then
                new.sgk_kurum_id := v_sgk;
            else
                raise exception 'TSS/Karma sözleşmesinde SGK carisi seçilmeli%.',
                      case when v_sgk_adet > 1 then ' (kurulumda birden çok SGK carisi var)'
                           else ' - önce SGK kurumunu tanımlayın' end
                      using errcode = 'GK422';
            end if;
        end if;
    end if;

    if new.bitis is not null and new.baslangic is not null
       and new.bitis < new.baslangic then
        raise exception 'Sözleşme bitişi başlangıcından önce olamaz.'
              using errcode = 'GK422';
    end if;
    return new;
end $function$;
