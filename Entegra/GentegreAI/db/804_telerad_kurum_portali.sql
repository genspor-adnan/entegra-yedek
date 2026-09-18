-- =====================================================================
-- 804 - KURUM PORTALI: DIS KURUM KENDI ISTEGINI ACAR
--
-- Kullanici: *"kurum portalı istek ekranıyla devam et"*.
--
-- 794/795'te portal KAPSAMI yazilmisti (dis kurum yalniz kendi isteklerini
-- gorur) ama rolde `teleradyoloji` YETKISI YOKTU: ekran portalda hic
-- gorunmuyordu. Yetki bilerek verilmemisti - karsiligi olmayan yetki "bos ama
-- acik kapi" olurdu. Artik karsiligi var.
--
-- OKUMA KAPSAMI ZATEN KAPALI (794/795): kaynak ve kart `PortalKosullari` ile
-- `kurum_taraf_id = {kullanici}` suzuyor. EKSIK OLAN YAZMA TARAFI:
--
--   * Portal kullanicisi kurum_id'yi ELLE secebilirdi - baskasinin adina istek
--     acmak demekti.
--   * Durum, atama, ucret, SLA ve teslim alanlari ekranda gorunuyor; portal
--     kullanicisi bunlari degistirebilseydi kendi isini "onayli" yapip
--     faturalatabilirdi.
--
-- KURAL VERITABANINDA: ayni istek portal ekranindan da, API'den de, ileride
-- DICOM alimindan da acilabilir. Yetki katmani "kim" sorusunu cevapliyor;
-- "ne yazabilir" sorusunun cevabi tek yerde olmali.
-- =====================================================================

-- ------------------------------------------------ portal kullanicisi kurumu ----
-- Portal kullanicisi kurumun CARI kaydidir (795): bag `telerad_kurum.taraf_id`
--   uzerinden kurulur, ayri bir "kurum kullanicisi" tablosu YOK.
create or replace function public.fn_telerad_portal_kurum(p_kullanici integer)
returns integer
language sql
stable
as $function$
    select k.id
      from public.telerad_kurum k
     where k.taraf_id = p_kullanici and k.aktif = 1
     order by k.id
     limit 1;
$function$;

comment on function public.fn_telerad_portal_kurum(integer) is
  '804: portal kullanicisinin (kurumun cari kaydi) teleradyoloji kurumu.';

-- ------------------------------------------------------- yazma korumasi ----
create or replace function public.tg_telerad_istek_portal()
returns trigger
language plpgsql
as $function$
declare
    v_kullanici integer;
    v_portal    smallint;
    v_kurum     integer;
begin
    -- Yazan kim: ekleme `ekleyen`, guncelleme `degistiren` kolonundan.
    v_kullanici := case when tg_op = 'INSERT' then nullif(new.ekleyen, 0)
                        else nullif(new.degistiren, 0) end;
    if v_kullanici is null then return new; end if;

    v_portal := public.fn_kullanici_portal_turu(v_kullanici);
    -- IC KULLANICI (0) DOKUNULMAZ: kural yalniz portal rolleri icin.
    if coalesce(v_portal, 0) = 0 then return new; end if;

    -- HASTA VE DIS DOKTOR BU TABLOYA YAZMAZ: hasta portali istek acmaz,
    --   dis doktorun teleradyoloji istegi acmasi tanimli bir is degil.
    if v_portal <> 2 then
        raise exception
          'Bu portal rolu teleradyoloji istegi yazamaz.'
          using errcode = '42501';
    end if;

    v_kurum := public.fn_telerad_portal_kurum(v_kullanici);
    if v_kurum is null then
        raise exception
          'Portal kullanicisinin teleradyoloji kurumu tanimli degil.'
          using errcode = '42501';
    end if;

    if tg_op = 'INSERT' then
        -- KURUM SUNUCUDA YAZILIR: istemciden gelen degere guvenilmez -
        --   baskasinin adina istek acmak boyle engellenir.
        if new.kurum_id is distinct from v_kurum then
            raise exception
              'Portal kullanicisi yalnizca kendi kurumu adina istek acabilir.'
              using errcode = '42501';
        end if;

        -- ISIN AKISI BIZDE BASLAR: portal istegi "goruntu bekleniyor"
        --   dogar; atama, ucret ve teslim merkezin isidir.
        new.durum              := 1;
        new.atanan_radyolog_id := null;
        new.ucret              := 0;
        new.sla_asildi         := 0;
        new.okuma_bas          := null;
        new.onay_zamani        := null;
        new.teslim_zamani      := null;
        new.teslim_durum       := 0;
        new.rapor_id           := null;
        new.fatura_belge_id    := null;

    else
        -- GUNCELLEMEDE MERKEZIN ALANLARI DEGISTIRILEMEZ: portal kullanicisi
        --   klinik bilgiyi duzeltebilir, onami isaretleyebilir, goruntu
        --   bilgisini guncelleyebilir - ama kendi isini "onayli" yapip
        --   faturalatamaz.
        --
        -- SESSIZCE ESKI DEGERE DONDURMEK YERINE HATA: kullanicinin ekranda
        --   yaptigi degisikligi yutup "kaydedildi" demek, ona yanlis bir
        --   dunya gosterirdi. Degistirmedigi alan zaten ayni geliyor -
        --   gonderdigi kartin tamami kontrol edilse de hata cikmaz.
        if new.kurum_id is distinct from old.kurum_id then
            raise exception 'Portal kullanicisi istegin kurumunu degistiremez.'
              using errcode = '42501';
        end if;

        if new.durum              is distinct from old.durum
        or new.atanan_radyolog_id is distinct from old.atanan_radyolog_id
        or new.ucret              is distinct from old.ucret
        or new.sla_dk             is distinct from old.sla_dk
        or new.sla_bitis          is distinct from old.sla_bitis
        or new.sla_asildi         is distinct from old.sla_asildi
        or new.okuma_bas          is distinct from old.okuma_bas
        or new.onay_zamani        is distinct from old.onay_zamani
        or new.teslim_zamani      is distinct from old.teslim_zamani
        or new.teslim_durum       is distinct from old.teslim_durum
        or new.teslim_hata        is distinct from old.teslim_hata
        or new.rapor_id           is distinct from old.rapor_id
        or new.radyoloji_istem_id is distinct from old.radyoloji_istem_id
        or new.fatura_belge_id    is distinct from old.fatura_belge_id
        or new.sozlesme_id        is distinct from old.sozlesme_id then
            raise exception
              'Bu alanlar raporlama merkezinin isidir: durum, atama, SLA, '
              'ucret, teslim ve rapor baglari portaldan degistirilemez.'
              using errcode = '42501';
        end if;
    end if;

    return new;
end $function$;

comment on function public.tg_telerad_istek_portal() is
  '804: portal (dis kurum) kullanicisinin yazabilecegi alanlar. Kurum '
  'sunucuda zorlanir; durum/atama/ucret/SLA/teslim alanlari merkezin isidir.';

-- SIRA ONEMLI: bu tetik `tg_telerad_istek`ten ONCE calismali ki numara/SLA
--   hesabi portal kurallariyla duzeltilmis satir uzerinde yapilsin. PG
--   tetikleri ADA GORE alfabetik calisir - "tg_telerad_a_portal" adi bunu
--   saglar (tg_telerad_istek'ten once gelir).
drop trigger if exists tg_telerad_a_portal on public.telerad_istek;
create trigger tg_telerad_a_portal
    before insert or update on public.telerad_istek
    for each row execute function public.tg_telerad_istek_portal();

-- ---------------------------------------------------------- yetki verme ----
-- DIS KURUM ROLU ARTIK TELERADYOLOJI GORUR VE ISTEK ACAR. Silme YOK: acilmis
--   istegi geri cekmek merkezin isidir (iptal durumu).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 1, 1, 0, ''
  from public.rol r
  cross join public.yetki y
 where r.kod = 'dis_istem_kurumu' and y.kod = 'teleradyoloji'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

do $$
declare v_rol integer; v_sayi integer;
begin
    select id into v_rol from public.rol where kod = 'dis_istem_kurumu';
    select count(*) into v_sayi
      from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
     where ry.rol_id = v_rol;
    raise notice '804: dis kurum rolunde artik % yetki var.', v_sayi;
end $$;
