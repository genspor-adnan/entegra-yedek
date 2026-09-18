-- ============================================================================
--  Gentegre AI — PORTAL KAPSAMI: DIŞ DOKTOR · DIŞ KURUM · HASTA
--  794_portal_kapsami.sql
--
--  Kullanıcı: *"Dışardan hasta gönderen 'Dış Doktor' gönderdiği hastaların
--  sonuçlarını görecek, 'Dış Kurum' gönderdiği hastaların sonuçlarını
--  görecek, hasta rolü olan hastalar randevu alıp sonuçlarını görebilecek"*
--  ve *"kapsamla başla"*.
--
--  Plan: dokuman/13_PORTAL_ROLLERI_PLANI.md
--
--  ============ NEDEN ROL DEĞİL KAPSAM ================================
--  Bir role `lab.sonuc` yetkisi verildiği an o kişi BÜTÜN hastaların sonucunu
--  görür. Portal rolünü kapsamsız açmak, rol tanımı doğru görünürken veri
--  sızdırmaktır. Bu yüzden önce kapsam.
--
--  `kullanici_kapsam` (tur=1) bir KAYIT LİSTESİDİR: "şu taraf id'lerini
--  görebilir". Portal kullanıcısının göreceği kümeyi liste olarak tutmak
--  imkânsız - dış doktorun hastaları her yeni istemle değişir. Bu yüzden
--  portal kapsamı KURALDIR, liste değil: "bu satırın göndereni benim".
--
--  ============ ROLE DAMGA: portal_turu ===============================
--     0  iç kullanıcı (bugünkü davranış - kural yok)
--     1  dış doktor    -> gönderdiği hasta (belge_satir_rol, rol = 1 Gönderen)
--     2  dış kurum     -> gönderdiği istem (lab_istem.dis_kurum_id)
--     3  hasta         -> kendi kaydı (hasta_id / taraf_id)
--
--  Kural KAYNAK KATALOĞUNDA yazılır (SorguUretici `PortalKosulu`), burada
--  yalnız rolün türü saklanır: aynı damga hem listelerde hem ileride satır
--  düzeyi güvenlikte kullanılacak.
--
--  ============ KARIŞIK ROL YASAK =====================================
--  Portal rolüyle iç rolü aynı kullanıcıda birleştirmek kapsamı DELER: yetki
--  rollerin birleşimidir (665), iç rol kapsamsız geldiği için portal kuralı
--  anlamsızlaşır. Tetik bunu reddediyor - kural ekranın değil veritabanının.
--
--  Aynı sebeple iki FARKLI portal türü de birleşemez: "hem dış doktor hem
--  hasta" bir satırın hangi kurala göre süzüleceğini belirsiz bırakır.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.rol
    add column if not exists portal_turu smallint not null default 0;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ck_rol_portal_turu') then
        alter table public.rol
            add constraint ck_rol_portal_turu check (portal_turu between 0 and 3);
    end if;
end $$;

comment on column public.rol.portal_turu is
  '794: 0 ic kullanici · 1 dis doktor · 2 dis kurum · 3 hasta. Portal rolu '
  'yalniz KENDI kayitlarini gorur; kural kaynak katalogunda (PortalKosulu).';

-- --------------------------------------------- kullanicinin portal turu ----
create or replace function public.fn_kullanici_portal_turu(p_kullanici integer)
returns smallint
language sql
stable
as $function$
    -- ANA ROL + EK ROLLER birlikte. Karisik rol tetikle engellendigi icin
    --   burada en fazla TEK portal turu cikar; yine de max() ile aliniyor -
    --   eski veride karisik kalmis olabilir ve o durumda KISITLI olan
    --   (portal) kazanmali, serbest olan degil.
    select coalesce(max(r.portal_turu), 0)::smallint
      from public.rol r
     where r.id = (select k.rol_id from public.taraf_kullanici k where k.id = p_kullanici)
        or r.id in (select kr.rol_id from public.kullanici_rol kr
                     where kr.kullanici_id = p_kullanici);
$function$;

comment on function public.fn_kullanici_portal_turu is
  '794: kullanicinin portal turu (ana rol + ek roller). 0 = ic kullanici.';

-- ------------------------------------------------------ karisik rol yasak --
create or replace function public.fn_portal_rol_karisim_koru()
returns trigger
language plpgsql
as $function$
declare
    v_kullanici integer;
    v_turler    smallint[];
    v_ad        text;
begin
    -- TG_TABLE_NAME'e gore AYRI DAL: plpgsql `case` icinde bile OLMAYAN alana
    --   basvuru derleme aninda cozulur ("record new has no field ...") - iki
    --   tablo tek ifadede birlestirilemez.
    if tg_table_name = 'taraf_kullanici' then
        v_kullanici := new.id;
    else
        v_kullanici := new.kullanici_id;
    end if;

    -- DEGISEN ROL HARIC: `taraf_kullanici` uzerinde ANA ROL degistiriliyorsa
    --   satirin ESKI ana rolu sayilmamali - BEFORE UPDATE'te tabloda hala eski
    --   deger duruyor ve "ic rolden portal roluNE gecis" kendi kendini
    --   reddederdi.
    if tg_table_name = 'taraf_kullanici' then
        select array_agg(distinct r.portal_turu) into v_turler
          from public.rol r
         where r.id = new.rol_id
            or r.id in (select kr.rol_id from public.kullanici_rol kr
                         where kr.kullanici_id = v_kullanici);
    else
        select array_agg(distinct r.portal_turu) into v_turler
          from public.rol r
         where r.id = new.rol_id
            or r.id = (select k.rol_id from public.taraf_kullanici k where k.id = v_kullanici)
            or r.id in (select kr.rol_id from public.kullanici_rol kr
                         where kr.kullanici_id = v_kullanici and kr.rol_id <> new.rol_id);
    end if;

    if v_turler is null or array_length(v_turler, 1) = 1 then return new; end if;

    select string_agg(distinct r.ad, ' · ') into v_ad
      from public.rol r
     where r.portal_turu > 0
       and (r.id = new.rol_id
            or r.id in (select kr.rol_id from public.kullanici_rol kr
                         where kr.kullanici_id = v_kullanici));

    raise exception 'Portal rolü (%) başka bir rolle birleştirilemez: portal '
                    'kullanıcısı yalnız kendi kayıtlarını görür, ikinci rol bu '
                    'sınırı kaldırırdı.', coalesce(v_ad, 'dış kullanıcı')
          using errcode = 'GK422';
end $function$;

comment on function public.fn_portal_rol_karisim_koru() is
  '794: portal rolu ic rolle ya da baska bir portal turuyle birlesemez - '
  'yetki rollerin BIRLESIMI oldugu icin ikinci rol kapsami deler.';

drop trigger if exists tg_taraf_kullanici_portal_karisim on public.taraf_kullanici;
create trigger tg_taraf_kullanici_portal_karisim
    before insert or update of rol_id on public.taraf_kullanici
    for each row execute function public.fn_portal_rol_karisim_koru();

drop trigger if exists tg_kullanici_rol_portal_karisim on public.kullanici_rol;
create trigger tg_kullanici_rol_portal_karisim
    before insert or update of rol_id on public.kullanici_rol
    for each row execute function public.fn_portal_rol_karisim_koru();

do $$
declare v_portal int;
begin
    select count(*) into v_portal from public.rol where portal_turu > 0;
    raise notice '794 tamam: portal rolu %. Roller heniz isaretlenmedi - '
                 'damgayi tasiyan rol acilinca (dis doktor/dis kurum/hasta) '
                 'kaynak kataloglarindaki PortalKosulu devreye girer.', v_portal;
end $$;
