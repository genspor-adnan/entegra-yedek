-- =====================================================================
-- 459 - RADYOLOJİ İSTEMİ: HİZMET RADYOLOJİ TETKİKİ OLMALI
--
-- Çalışma listesinde modalitesi ve tetkiki boş satırlar görüldü. Sebep
-- "hizmetsiz istem" değil (hizmet_id hepsinde dolu), **yanlış hizmet**:
--   * 2754 "17-KETOSTEROİD" bir LABORATUVAR tetkiki - radyoloji kuyruğuna
--     düşmüş, hiçbir cihazda çekilemez;
--   * 3150 "Alt Abdomen MR" gerçek radyoloji tetkiki ama hizmet kartında
--     MODALİTE seçilmemiş - MWL'e (cihaz iş listesi) hangi cihazla gideceği
--     belirsiz;
--   * 3281 adı boş bir hizmet kaydı.
--
-- Kart ekranında tetkik zaten `v_rad_tetkik_lookup` ile sınırlı; açık kapı
-- MUAYENEDEN açılan istemdi (hizmet id serbest geliyordu). Kural tek yerde,
-- VERİTABANINDA: üç giriş yolu (kart · muayene · toplu kabul) da aynı
-- kontrolden geçsin - biri unutulursa sessizce bozuk kayıt oluşuyordu.
--
-- ESKİ KAYITLARA DOKUNULMAZ: tetik yalnız INSERT'te ve hizmet DEĞİŞTİREN
-- UPDATE'te çalışır. Var olan üç satır durur (silinmez, düzeltilmez); hangi
-- olduklarını görebilmek için aşağıda listeleniyor - düzeltme kullanıcının
-- kararıdır (hizmet kartına modalite girmek ya da istemi iptal etmek).
-- =====================================================================

create or replace function public.tg_radyoloji_istem_hizmet()
returns trigger language plpgsql as $$
declare
    v_ad   varchar(200);
    v_mod  smallint;
begin
    select h.ad, coalesce(h.modalite, 0) into v_ad, v_mod
      from public.hizmet h where h.id = new.hizmet_id;

    if v_ad is null then
        raise exception 'Radyoloji istemi icin gecerli bir tetkik (hizmet) secilmeli.'
            using errcode = 'check_violation';
    end if;

    -- MODALİTE = tetkikin cihaz ailesi (röntgen, MR, BT...). Sıfırsa tetkik
    --   radyoloji tetkiki değildir ya da hizmet kartı eksiktir; her iki
    --   durumda da istem çalışma listesinde "hangi cihaz" sorusunu cevapsız
    --   bırakır ve MWL'e gönderilemez.
    if v_mod = 0 then
        raise exception
            'Bu tetkik radyoloji tetkiki degil ya da hizmet kartinda modalite secilmemis: %',
            coalesce(nullif(v_ad, ''), '#' || new.hizmet_id::text)
            using errcode = 'check_violation',
                  hint = 'Stok & Hizmet > Hizmet kartindan modalite secin ya da radyoloji tetkiki secin.';
    end if;

    -- Modalite isteme KOPYALANIR: muayeneden acilan istemde bu alan hic
    --   yazilmiyordu, liste "Mod." kolonunu bos gosteriyordu.
    if coalesce(new.modalite, 0) = 0 then
        new.modalite := v_mod;
    end if;
    return new;
end $$;

drop trigger if exists tg_radyoloji_istem_hizmet on public.radyoloji_istem;
create trigger tg_radyoloji_istem_hizmet
    before insert or update of hizmet_id on public.radyoloji_istem
    for each row execute function public.tg_radyoloji_istem_hizmet();

do $$
declare
    r record;
    n integer := 0;
begin
    for r in
        select i.id, i.accession_no, i.hizmet_id,
               coalesce(nullif(h.ad, ''), '(adsiz hizmet)') as ad
          from public.radyoloji_istem i
          left join public.hizmet h on h.id = i.hizmet_id
         where coalesce(h.modalite, 0) = 0
         order by i.id
    loop
        n := n + 1;
        raise notice 'ESKI AYKIRI ISTEM: #% % - hizmet % (%)',
            r.id, r.accession_no, r.hizmet_id, r.ad;
    end loop;
    raise notice '459 tamam: tetik kuruldu, % eski aykiri istem var (dokunulmadi)', n;
end $$;
