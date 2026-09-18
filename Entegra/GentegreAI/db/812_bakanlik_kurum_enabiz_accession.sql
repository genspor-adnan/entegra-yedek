-- ============================================================================
--  Gentegre AI — BAKANLIK PROFİLİ 4/4: KURUM ALANLARI · e-NABIZ BAĞI ·
--                ACCESSION ZORUNLULUĞU · GÖNDERİM ÖNCESİ KONTROL
--  812_bakanlik_kurum_enabiz_accession.sql
--
--  Kullanıcı: *"bunları yap"* (dokuman/14, bölüm 5.5 · madde 6, 7 ve 8).
--
--  ============ 1) KURUM ALANLARI (madde 7) ==========================
--  Kılavuz 3.46 mesajı yalnız içeriğe göre değil, KİMLİĞE göre de reddediyor:
--    MSH-3/4 : e-Nabız'da kayıtlı firma/tesis kodu (yanlışsa hata 0275)
--    MSH-18  : UTF8 ya da Windows1254 - Bakanlığa ÖNCEDEN bildirilen ile aynı
--    ORC-21  : kurumun SKRS kodu (tüm mesajlarda AYNI olmalı - hata 0054)
--  Bunlar kuruma göre değişir, ayara gömülemez: aynı kurulum birden çok
--  kuruma hizmet verebilir.
--
--  `tesis_kodu` (797) DURUYOR ve DEĞİŞMİYOR: o ÇKYS/Medula tesis kodudur.
--  SKRS kodu ayrı alan - ikisini tek kolona indirmek, birini bozmadan
--  ötekini düzeltmeyi imkânsız kılardı.
--
--  ============ 2) e-NABIZ BAĞI (madde 6) ============================
--  OBR-20 (Sys takip no), OBR-21 ve PV1-19 (hastane başvuru referans no)
--  e-Nabız tarafında DOĞRULANIYOR: uydurulan değer mesajı reddettirir.
--  İkisi de bizde zaten var - 605'te `enabiz_paket.sys_takip_no`, 606'da
--  101 paketinin `HASTANE_REFERANS_NUMARASI` alanı. Eksik olan BAĞ'dı.
--
--  ============ 3) ACCESSION (madde 8) ===============================
--  Kılavuz §5.2: görüntü ile istemi eşleştiren TEK anahtar accession'dır;
--  DICOM'daki değer HL7'dekinden farklıysa hiçbir suretle eşleşme olmaz.
--  Bizde `dis_erisim_no` bugün boş kalabiliyor. Bakanlığa bildirim yapan
--  kurumda ZORUNLU ve kurum içinde BENZERSİZ olmalı.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------- kurum alanları ----
alter table public.telerad_kurum
    add column if not exists bakanlik_gonderim smallint     not null default 0;
alter table public.telerad_kurum
    add column if not exists skrs_kodu         varchar(10)  not null default '';
alter table public.telerad_kurum
    add column if not exists msh_encoding      smallint     not null default 1;
alter table public.telerad_kurum
    add column if not exists msh_uygulama      varchar(30)  not null default '';
alter table public.telerad_kurum
    add column if not exists msh_tesis         varchar(30)  not null default '';
alter table public.telerad_kurum
    add column if not exists hl7_alici_uygulama varchar(30) not null default '';
alter table public.telerad_kurum
    add column if not exists hl7_alici_tesis    varchar(30) not null default '';
alter table public.telerad_kurum
    add column if not exists wado_adres         varchar(200) not null default '';

comment on column public.telerad_kurum.bakanlik_gonderim is
  '812: bu kurumun işleri Bakanlık Teleradyoloji Sistemi''ne de bildirilir mi.';
comment on column public.telerad_kurum.skrs_kodu is
  '812: kurumun SKRS kodu (ORC-21). tesis_kodu ÇKYS/Medula kodudur, ayrı alandır.';
comment on column public.telerad_kurum.msh_encoding is
  '812: MSH-18 - 1 UTF8 · 2 Windows1254. Bakanlığa önceden bildirilen ile aynı olmalı.';
comment on column public.telerad_kurum.msh_uygulama is
  '812: MSH-3 uygulama (firma) kodu - e-Nabız''da kayıtlı olduğu gibi (hata 0275).';
comment on column public.telerad_kurum.msh_tesis is
  '812: MSH-4 gönderen tesis.';
comment on column public.telerad_kurum.hl7_alici_uygulama is
  '812: MSH-5 alıcı uygulama (Bakanlık hedefinde TELETIP).';
comment on column public.telerad_kurum.hl7_alici_tesis is
  '812: MSH-6 alıcı tesis.';
comment on column public.telerad_kurum.wado_adres is
  '812: kurumun WADO temel adresi - görüntü buradan çekilir (kılavuz §4.2).';

alter table public.telerad_kurum drop constraint if exists ck_telerad_kurum_encoding;
alter table public.telerad_kurum
    add constraint ck_telerad_kurum_encoding check (msh_encoding in (1, 2));

-- Bakanlık hedefi açıksa alıcı adları BOŞ BIRAKILMASIN: kılavuzda sabit.
update public.telerad_kurum
   set hl7_alici_uygulama = 'TELETIP', hl7_alici_tesis = 'TELETIP'
 where bakanlik_gonderim = 1
   and hl7_alici_uygulama = '' and hl7_alici_tesis = '';

-- ---------------------------------------------------------- e-Nabız bağı ----
-- TEK OKUYUCU: OBR-20/21 ve PV1-19 aynı yerden gelir. Paket bulunamazsa boş
--   döner - uydurulmuş numara mesajı reddettirir, boş değer ise eksiklik
--   olarak raporlanır.
create or replace function public.fn_enabiz_basvuru_referans(p_belge_id integer)
returns table (sys_takip_no varchar, hastane_referans varchar)
language sql stable as $$
  select coalesce(p.sys_takip_no, '')::varchar,
         coalesce((select a.deger from public.enabiz_paket_alan a
                    where a.paket_id = p.id
                      and a.uss_alan like '%HASTANE_REFERANS_NUMARASI'
                    order by a.sira limit 1), '')::varchar
    from public.enabiz_paket p
    join public.enabiz_paket_turu t on t.id = p.paket_turu_id
   where p.kaynak_tur = 1 and p.kaynak_id = p_belge_id
     and t.uss_paket_kodu = '101'
   order by p.id desc
   limit 1;
$$;

comment on function public.fn_enabiz_basvuru_referans(integer) is
  '812: başvurunun e-Nabız 101 paketinden SYSTakipNo (OBR-20) ve hastane '
  'referans numarası (OBR-21 / PV1-19).';

-- --------------------------------------------------- accession benzersiz ----
-- KURUM İÇİNDE benzersiz: iki kurum aynı numarayı kullanabilir (numarayı
--   onlar üretiyor), aynı kurumda iki kez kullanılamaz - kullanılırsa görüntü
--   hangi isteme ait bilinemez.
create unique index if not exists ux_telerad_istek_kurum_erisim
    on public.telerad_istek (kurum_id, dis_erisim_no)
 where dis_erisim_no <> '';

create or replace function public.tg_telerad_bakanlik_dogrula()
returns trigger
language plpgsql
as $$
declare v_bakanlik smallint;
begin
    select coalesce(k.bakanlik_gonderim, 0) into v_bakanlik
      from public.telerad_kurum k where k.id = new.kurum_id;

    if coalesce(v_bakanlik, 0) = 1
       and btrim(coalesce(new.dis_erisim_no, '')) = '' then
        raise exception
            'Bakanlık bildirimi açık kurumda erişim (accession) numarası zorunludur: '
            'görüntü ile istem yalnız bu numarayla eşleşir.'
            using errcode = 'GK422';
    end if;
    return new;
end $$;

-- ADI "tg_telerad_b_...": 804'teki portal tetiği tg_telerad_a_portal'dan
--   SONRA, 797'deki tg_telerad_istek'ten ÖNCE çalışsın (adlarına göre
--   sıralanır) - portal kurumu yazdıktan sonra kontrol edilmeli.
drop trigger if exists tg_telerad_b_bakanlik on public.telerad_istek;
create trigger tg_telerad_b_bakanlik
    before insert or update of kurum_id, dis_erisim_no on public.telerad_istek
    for each row execute function public.tg_telerad_bakanlik_dogrula();

-- ------------------------------------------- gönderim öncesi kontrol ----
-- RAPOR ONAYINI ENGELLEMEZ: buradaki eksikleri radyolog gideremez (accession
--   kurumdan gelir, TCKN kayıttan, SKRS kodu kurulumdan). Onayı bunlara
--   bağlamak, düzeltemeyeceği bir duvara radyoloğu çarptırmak olurdu.
--   Bunlar GÖNDERİM eksiğidir; operasyon ekranında listelenir.
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

comment on function public.fn_telerad_bakanlik_eksik(integer) is
  '812: Bakanlık ORU gönderimi için eksik alanlar (boş = gönderilebilir). '
  'Rapor onayını ENGELLEMEZ - bunlar gönderim eksiğidir.';

do $$
declare v_kurum integer;
begin
    select count(*) into v_kurum from public.telerad_kurum where bakanlik_gonderim = 1;
    raise notice '812 tamam: % kurumda Bakanlik bildirimi acik. Accession '
                 'benzersizligi kurum bazinda uygulandi.', v_kurum;
end $$;
