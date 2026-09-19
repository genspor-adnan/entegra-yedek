-- ============================================================================
--  Gentegre AI — KADRO HAREKETİNE ANA ROL
--  843_kadro_ana_rol.sql
--
--  Kullanıcı: *"hareketlere görevden sonra ana rolü de al"* + *"kart tarafını
--  da kilitle"*.
--
--  Ana rol `taraf_kullanici.rol_id`de durur ve kişinin YETKİSİNİ belirler -
--  bölüm/görevden daha ağır bir değişiklik. Terfi kadroya yazılıp yetki
--  sessizce başka yerden değişince defter yalan söylüyordu.
--
--  ============ BLOKE DEĞİL, KAYIT ====================================
--  `taraf_kullanici.rol_id`i güncelleyen altı ayrı yol var (kullanıcı kartı,
--  rol-kullanıcı ekranı, portal daveti, portal hesabı, bakım uçları).
--  Hepsini hata vererek kesmek portal davetini de kırardı - tetik bu yüzden
--  ENGELLEMEZ, deftere satır DÜŞER. Kilit kullanıcı kartında uygulanır:
--  personel hesaplarında Ana Rol alanı salt okunur olur.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.personel_hareket
  add column if not exists rol_id integer references public.rol(id);

comment on column public.personel_hareket.rol_id is
  'Ana rol (taraf_kullanici.rol_id) - o tarihteki yetki rolu.';

-- ------------------------------------------------------------- görünüm ----
-- Kolon SIRASI degisiyor (rol_id gorevden sonra) - create or replace bunu
--   kabul etmez, gorunum bu yuzden dusurulup yeniden kurulur. Baska nesne
--   bu gorunume bagli degil (yalniz API okur).
drop view if exists public.v_personel_hareket;
create view public.v_personel_hareket as
select h.id, h.taraf_id,
       coalesce(t.unvan, '')    as personel_ad,
       coalesce(p.sicil_no, '') as sicil_no,
       h.tur, coalesce(kd.ad, '') as tur_adi,
       h.yururluk, h.bitis,
       (case when h.bitis is not null then 1 else 0 end)::smallint as sureli,
       (case when h.yururluk <= current_date
              and (h.bitis is null or h.bitis >= current_date)
              and h.id = (select h2.id from public.personel_hareket h2
                           where h2.taraf_id = h.taraf_id
                             and h2.yururluk <= current_date
                             and (h2.bitis is null or h2.bitis >= current_date)
                           order by h2.yururluk desc, h2.id desc limit 1)
             then 1 else 0 end)::smallint as gecerli,
       (case when h.yururluk > current_date then 1 else 0 end)::smallint as ileri,
       h.gorev, h.gorev_id, coalesce(g.ad, '') as gorev_adi,
       h.departman_id, coalesce(d.ad, '') as departman_adi,
       h.rol_id, coalesce(r.ad, '') as rol_adi,
       h.yonetici_taraf_id, coalesce(y.unvan, '') as yonetici_ad,
       h.sube_id, coalesce(s.ad, '') as sube_adi,
       h.calisma_sekli, h.sozlesme_turu, h.unvan,
       h.karar_no, h.belge_no, h.gerekce, h.aciklama,
       h.kaynak, h.ekleyen, h.ekleme_tarihi
  from public.personel_hareket h
  left join public.taraf t          on t.id = h.taraf_id
  left join public.taraf_personel p on p.id = h.taraf_id
  left join public.taraf y          on y.id = h.yonetici_taraf_id
  left join public.personel_gorev g on g.id = h.gorev_id
  left join public.departman d      on d.id = h.departman_id
  left join public.rol r            on r.id = h.rol_id
  left join public.sube s           on s.id = h.sube_id
  left join public.kod_liste kl     on kl.kod = 'ik.hareket_tur'
  left join public.kod_deger kd     on kd.liste_id = kl.id and kd.deger = h.tur;

-- ------------------------------------------ hareketi karta uygula (v3) ----
create or replace function public.fn_personel_kadro_uygula(p_taraf_id integer)
returns integer language plpgsql as $$
declare
    h        public.personel_hareket;
    v_giris  date;
    v_cikis  date;
    v_sayi   integer := 0;
begin
    select * into h from public.fn_personel_kadro(p_taraf_id, current_date);

    select min(yururluk) into v_giris from public.personel_hareket
     where taraf_id = p_taraf_id and tur = 1;
    select max(yururluk) into v_cikis from public.personel_hareket
     where taraf_id = p_taraf_id and tur = 9;

    if h.id is null and v_giris is null and v_cikis is null then return 0; end if;

    perform set_config('gentegre.kadro_iz', 'kapali', true);

    if h.id is not null then
        update public.taraf_personel p
           set gorev             = case when h.gorev <> '' then h.gorev else p.gorev end,
               yonetici_taraf_id = coalesce(h.yonetici_taraf_id, p.yonetici_taraf_id),
               sube_id           = case when h.sube_id > 0 then h.sube_id else p.sube_id end,
               calisma_sekli     = case when h.calisma_sekli > 0 then h.calisma_sekli
                                        else p.calisma_sekli end,
               sozlesme_turu     = case when h.sozlesme_turu > 0 then h.sozlesme_turu
                                        else p.sozlesme_turu end,
               degistirme_tarihi = now()
         where p.id = p_taraf_id;
        get diagnostics v_sayi = row_count;

        update public.taraf t
           set departman = coalesce(h.departman_id, t.departman),
               gorev_id  = coalesce(h.gorev_id, t.gorev_id),
               degistirme_tarihi = now()
         where t.id = p_taraf_id
           and (h.departman_id is not null or h.gorev_id is not null);

        -- ANA ROL: hesabi olmayan personelde sessizce atlanir (tasoron,
        --   sistemi kullanmayan kadro) - hesap acilinca rol karttan verilir.
        update public.taraf_kullanici k
           set rol_id = h.rol_id, degistirme_tarihi = now()
         where k.id = p_taraf_id
           and h.rol_id is not null
           and k.rol_id is distinct from h.rol_id;
    end if;

    update public.taraf_personel p
       set ise_giris_tarihi   = coalesce(v_giris, p.ise_giris_tarihi),
           isten_cikis_tarihi = case when v_cikis is not null then v_cikis
                                     else p.isten_cikis_tarihi end,
           degistirme_tarihi  = now()
     where p.id = p_taraf_id
       and (v_giris is not null or v_cikis is not null);

    perform set_config('gentegre.kadro_iz', '', true);
    return v_sayi;
end $$;

-- --------------------------------------------- rol değişikliğinin izi ----
create or replace function public.tg_personel_rol_iz()
returns trigger language plpgsql as $$
declare v_var integer;
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;
    -- YALNIZ PERSONEL: portal hesabinin ve sistem kullanicisinin kadrosu yok.
    if not exists (select 1 from public.taraf_personel p where p.id = new.id) then
        return null;
    end if;

    -- Ayni gun ikinci kez degisirse yeni satir acma, mevcudu duzelt.
    select id into v_var from public.personel_hareket
     where taraf_id = new.id and yururluk = current_date and kaynak = 2
     order by id desc limit 1;

    if v_var is not null then
        update public.personel_hareket
           set rol_id = new.rol_id, degistirme_tarihi = now()
         where id = v_var;
    else
        insert into public.personel_hareket
               (taraf_id, tur, yururluk, rol_id, departman_id, gorev_id,
                gorev, yonetici_taraf_id, sube_id, calisma_sekli, sozlesme_turu,
                aciklama, kaynak, ekleyen)
        select new.id, 2, current_date, new.rol_id, t.departman, t.gorev_id,
               coalesce(p.gorev, ''), p.yonetici_taraf_id, coalesce(p.sube_id, 0),
               coalesce(p.calisma_sekli, 0), coalesce(p.sozlesme_turu, 0),
               'Ana rol degisikligi.', 2, new.degistiren
          from public.taraf_personel p
          join public.taraf t on t.id = p.id
         where p.id = new.id;
    end if;
    return null;
end $$;

drop trigger if exists tr_personel_rol_iz on public.taraf_kullanici;
create trigger tr_personel_rol_iz
  after update of rol_id on public.taraf_kullanici
  for each row when (old.rol_id is distinct from new.rol_id)
  execute function public.tg_personel_rol_iz();

-- ------------------------------ giriş/çıkış izi: ana rolü de yakala (v3) ---
create or replace function public.tg_personel_giris_cikis_iz()
returns trigger language plpgsql as $$
declare v_dep integer; v_gorev integer; v_rol integer;
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;

    select t.departman, t.gorev_id into v_dep, v_gorev
      from public.taraf t where t.id = new.id;
    select k.rol_id into v_rol
      from public.taraf_kullanici k where k.id = new.id;

    if new.ise_giris_tarihi is not null
       and new.ise_giris_tarihi is distinct from old.ise_giris_tarihi then
        if exists (select 1 from public.personel_hareket
                    where taraf_id = new.id and tur = 1) then
            update public.personel_hareket
               set yururluk = new.ise_giris_tarihi,
                   departman_id = coalesce(departman_id, v_dep),
                   gorev_id     = coalesce(gorev_id, v_gorev),
                   rol_id       = coalesce(rol_id, v_rol),
                   degistirme_tarihi = now()
             where taraf_id = new.id and tur = 1;
        else
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, gorev, departman_id, gorev_id, rol_id,
                    sube_id, aciklama, kaynak, ekleyen)
            values (new.id, 1, new.ise_giris_tarihi, coalesce(new.gorev, ''),
                    v_dep, v_gorev, v_rol, coalesce(new.sube_id, 0),
                    'İşe giriş (karttan).', 2, new.degistiren);
        end if;
    end if;

    if new.isten_cikis_tarihi is not null
       and new.isten_cikis_tarihi is distinct from old.isten_cikis_tarihi then
        if exists (select 1 from public.personel_hareket
                    where taraf_id = new.id and tur = 9) then
            update public.personel_hareket
               set yururluk = new.isten_cikis_tarihi,
                   departman_id = coalesce(departman_id, v_dep),
                   gorev_id     = coalesce(gorev_id, v_gorev),
                   rol_id       = coalesce(rol_id, v_rol),
                   degistirme_tarihi = now()
             where taraf_id = new.id and tur = 9;
        else
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, gorev, departman_id, gorev_id, rol_id,
                    sube_id, aciklama, kaynak, ekleyen)
            values (new.id, 9, new.isten_cikis_tarihi, coalesce(new.gorev, ''),
                    v_dep, v_gorev, v_rol, coalesce(new.sube_id, 0),
                    'İşten çıkış (karttan).', 2, new.degistiren);
        end if;
    end if;
    return null;
end $$;

-- --------------------------------------------------------- geri dolgu ----
-- 842'deki gerekcenin aynisi: bu satirlarda rol bilgisi HIC yok, kaybedilecek
--   gecmis de yok - tek bilinen gercek hesabin bugunku rolu.
create table if not exists public.personel_hareket_yedek_843 as
select id, rol_id from public.personel_hareket where rol_id is null;

update public.personel_hareket h
   set rol_id = k.rol_id, degistirme_tarihi = now()
  from public.taraf_kullanici k
 where k.id = h.taraf_id and h.rol_id is null;

do $$
declare v_dolu integer; v_bos integer;
begin
    select count(*) filter (where rol_id is not null),
           count(*) filter (where rol_id is null)
      into v_dolu, v_bos from public.personel_hareket;
    raise notice '843 tamam: % harekette ana rol dolu, % satir bos '
                 '(hesabi olmayan personel).', v_dolu, v_bos;
end $$;
