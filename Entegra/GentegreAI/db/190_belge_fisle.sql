-- ============================================================================
--  Gentegre AI — BELGE FISLEME (fatura / fis)  [plan F7]
--  190_belge_fisle.sql
--
--  Muhasebe fisi simdiye kadar YALNIZ kasa isleminden doguyordu; faturalarin
--  fisi hic yoktu. Bu dosya ayni motora belge girisini ekler:
--
--    SATIS  (15/16/119/19...) : 120 BORC  / 600 ALACAK + 391 ALACAK
--    ALIS   (11/12/109...)    : 153-770 BORC / 191 BORC / 320 ALACAK
--    IADE   (tipi = 2)        : ayni hesaplar, BORC/ALACAK ters
--
--  KURALLAR
--    * Tek kaynak: tutarlar belgenin KENDI toplamlarindan gelir (matrah,
--      kdv_tutari, ek_vergi, genel_toplam). Satirlardan yeniden hesaplamak
--      dip toplamla kurus farki uretirdi.
--    * Kalem hesabi satirin turune gore cozulur (stok / hizmet / masraf);
--      kartta muhasebe hesabi yoksa esleme tablosundaki varsayilana duser.
--    * KDV oran BAZINDA ayrilir (391.20 gibi alt hesap YOK - tek hesap, ama
--      satir aciklamasinda oran yazar). Yuvarlama farki en buyuk KDV satirina
--      eklenir; fis KESINLIKLE dengeli kapanir.
--    * Idempotent: (kaynak_tur=2, kaynak_id=belge) icin tek kayitli fis.
--    * IRSALIYE FISLENMEZ: mali sonuc faturada dogar; irsaliye stok hareketidir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge
    add column if not exists muhasebe_fis_id integer;

alter table public.stok
    add column if not exists muh_hesap_id integer references public.hesap_plani(id);
alter table public.kategori
    add column if not exists muh_hesap_id integer references public.hesap_plani(id);

comment on column public.belge.muhasebe_fis_id is
  'Belgenin muhasebe fisi (190). fn_belge_fisle doldurur.';

create index if not exists ix_belge_fis on public.belge (muhasebe_fis_id)
    where muhasebe_fis_id is not null;

-- ---------------------------------------------------------------------------
--  ESLEME KURALLARI (kural_turu = 'belge')
--    rol: satis · alis · kdv_satis · kdv_alis · masraf · hizmet_satis ·
--         ek_vergi · tevkifat
--  hesap_turu kolonu burada BELGE YONU tasir: 'S' satis, 'A' alis.
-- ---------------------------------------------------------------------------
insert into public.muhasebe_eslestirme (kural_turu, hesap_turu, yon, rol, hesap_plani_id, oncelik, aktif)
select v.kural, v.yon_kod, 0, v.rol, hp.id, 50, 1
  from (values ('belge', 'S', 'satis',       '600'),
               ('belge', 'S', 'hizmet_satis','600'),
               ('belge', 'S', 'kdv_satis',   '391'),
               ('belge', 'S', 'masraf',      '649'),
               ('belge', 'A', 'alis',        '153'),
               ('belge', 'A', 'hizmet_alis', '770'),
               ('belge', 'A', 'kdv_alis',    '191'),
               ('belge', 'A', 'masraf',      '770'),
               ('belge', 'S', 'ek_vergi',    '360'),
               ('belge', 'A', 'ek_vergi',    '360'),
               ('belge', 'S', 'tevkifat',    '391'),
               ('belge', 'A', 'tevkifat',    '191'),
               -- Gocten gelen belgelerde matrah+KDV ile genel toplam birkac
               --   kurus tutmayabiliyor; fark bu hesaba yazilir ve fis dengeli
               --   kapanir (cari satiri EKSTRE ile ayni kalsin diye genel
               --   toplamdir, degistirilmez).
               ('belge', 'S', 'kurus_farki', '649'),
               ('belge', 'A', 'kurus_farki', '656')
       ) as v(kural, yon_kod, rol, kod)
  join public.hesap_plani hp on hp.kod = v.kod
 where not exists (select 1 from public.muhasebe_eslestirme e
                    where e.kural_turu = v.kural and e.hesap_turu = v.yon_kod
                      and e.rol = v.rol);

-- Eski metin kodundan (stok.muh_kodu) hesap planina baglama - bir kereye mahsus.
update public.stok s
   set muh_hesap_id = hp.id
  from public.hesap_plani hp
 where s.muh_hesap_id is null
   and coalesce(btrim(s.muh_kodu), '') <> ''
   and hp.kod = btrim(s.muh_kodu);

-- ---------------------------------------------------------------------------
--  Belge satirinin muhasebe hesabi.
--    1) Kartin kendi hesabi (stok/hizmet/masraf)
--    2) Stokta kategori hesabi
--    3) Esleme tablosundaki varsayilan (yone gore)
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_satir_hesap(p_satir_id integer, p_satis boolean)
returns integer language plpgsql stable as $$
declare
    s     record;
    v_hp  integer;
    v_rol varchar(30);
begin
    -- stok.kategori KOD tasir (smallint), kategori tablosuna id ile degil
    --   kod uzerinden baglanir.
    select bs.*, st.muh_hesap_id as stok_hp, st.kategori as kategori_kod,
           hz.muh_hesap_id as hizmet_hp, ms.muh_hesap_id as masraf_hp
      into s
      from public.belge_satir bs
      left join public.stok    st on st.id = bs.stok_id
      left join public.hizmet  hz on hz.id = bs.hizmet_id
      left join public.masraf  ms on ms.id = bs.masraf_id
     where bs.id = p_satir_id;

    if s.id is null then
        return null;
    end if;

    -- 1) Kartin kendi hesabi.
    v_hp := case s.tur when 1 then s.stok_hp when 2 then s.hizmet_hp else s.masraf_hp end;
    if v_hp is not null then return v_hp; end if;

    -- 2) Stokta kategori hesabi.
    if s.tur = 1 and coalesce(s.kategori_kod, 0) <> 0 then
        select k.muh_hesap_id into v_hp
          from public.kategori k where k.id = s.kategori_kod;
        if v_hp is not null then return v_hp; end if;
    end if;

    -- 3) Varsayilan esleme.
    v_rol := case s.tur
                  when 1 then case when p_satis then 'satis' else 'alis' end
                  when 2 then case when p_satis then 'hizmet_satis' else 'hizmet_alis' end
                  else 'masraf'
             end;
    select e.hesap_plani_id into v_hp
      from public.muhasebe_eslestirme e
     where e.kural_turu = 'belge' and e.aktif = 1 and e.rol = v_rol
       and e.hesap_turu = case when p_satis then 'S' else 'A' end
     order by e.oncelik limit 1;

    return v_hp;
end $$;

comment on function public.fn_belge_satir_hesap(integer, boolean) is
  'Belge satirinin muhasebe hesabi: kart > kategori > varsayilan esleme (190).';

-- ---------------------------------------------------------------------------
--  BELGEYI FISLE
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_fisle(p_belge_id integer,
                                                 p_kullanici integer default 0)
returns integer language plpgsql as $$
declare
    b         record;
    r         record;
    v_fis     integer;
    v_donem   integer;
    v_sira    smallint := 0;
    v_satis   boolean;
    v_iade    boolean;
    v_cari_hp integer;
    v_kdv_hp  integer;
    v_hp      integer;
    v_borc    numeric(19,4) := 0;
    v_alacak  numeric(19,4) := 0;
    v_kdv_top numeric(19,4) := 0;
    v_kalem   numeric(19,4) := 0;
    v_str_top numeric(19,4);
    v_kats    numeric(19,10) := 1;
    v_fark    numeric(19,4);
    v_enbuyuk integer;
    v_enkalem integer;
    v_isaret  smallint;           -- iade ise -1: borc/alacak yer degistirir
    v_proje   integer;            -- gocte var olmayan kayda isaret edebilir
    v_merkez  integer;
begin
    select * into b from public.belge where id = p_belge_id for update;
    if not found then
        raise exception 'Belge bulunamadı: %', p_belge_id using errcode = 'GK422';
    end if;
    if b.durum <> 0 then
        raise exception 'Yalnız kesin belge fişlenir (durum %).', b.durum using errcode = 'GK422';
    end if;

    -- IRSALIYE mali sonuc dogurmaz: fatura kesilince fislenir.
    if b.tur in (10, 14) then
        return null;
    end if;

    -- Otomatik fisleme kapaliysa kayit sirasinda uretilmez; toplu fislemede
    --   (fn_belge_fisle_toplu) yine calisir - o cagri zaten acik istektir.
    if coalesce((select deger from public.referans
                  where anahtar = 'muhasebe.otomatik_fis'), '1') = '0'
       and p_kullanici >= 0 and current_setting('gentegre.toplu_fis', true) is distinct from '1' then
        return null;
    end if;

    -- Idempotency: kayitli fis varsa aynisi doner.
    if b.muhasebe_fis_id is not null
       and exists (select 1 from public.muhasebe_fis where id = b.muhasebe_fis_id and durum = 1) then
        return b.muhasebe_fis_id;
    end if;
    select id into v_fis from public.muhasebe_fis
     where kaynak_tur = 2 and kaynak_id = p_belge_id and durum = 1;
    if v_fis is not null then
        update public.belge set muhasebe_fis_id = v_fis where id = p_belge_id;
        return v_fis;
    end if;

    if coalesce(b.genel_toplam, 0) = 0 then
        return null;                                   -- tutarsiz belge fislenmez
    end if;

    -- SATIS mi ALIS mi: belge turu kataloğundan (kasa_islem_turu.yon).
    v_satis := b.tur in (14, 15, 16, 19, 119);
    v_iade  := coalesce(b.tipi, 1) = 2;
    v_isaret := case when v_iade then -1 else 1 end;

    -- Gocten gelen belgede proje/merkez kaydi SILINMIS olabilir; fis satirinin
    --   yabanci anahtari bunu reddediyordu. Var olmayan referans bos birakilir.
    select p.id into v_proje from public.proje p where p.id = b.proje_id;
    select m.id into v_merkez from public.masraf_merkezi m where m.id = nullif(b.merkez_id, 0);

    perform public.fn_muhasebe_donem_kontrol(b.belge_tarihi);
    select id into v_donem from public.muhasebe_donem
     where yil = extract(year from b.belge_tarihi)::smallint
       and ay  = extract(month from b.belge_tarihi)::smallint;

    insert into public.muhasebe_fis
        (fis_no, fis_tarihi, tur, durum, kaynak_tur, kaynak_id, donem_id,
         aciklama, sube_id, ekleyen)
    values ('', b.belge_tarihi, 1, 1, 2, p_belge_id, v_donem,
            left(case when v_satis then 'Satış' else 'Alış' end ||
                 case when v_iade then ' iadesi' else ' faturası' end ||
                 ' ' || coalesce(nullif(b.belge_no, ''), '') ||
                 ' - ' || coalesce(b.taraf_unvan, ''), 200),
            b.sube_id, p_kullanici)
    returning id into v_fis;

    -- 1) CARI satiri (tek satir, genel toplam).
    select coalesce(t.muh_hesap_id,
                    (select e.hesap_plani_id from public.muhasebe_eslestirme e
                      where e.kural_turu = 'cari' and e.aktif = 1
                        and e.yon = case when v_satis then 1 else 2 end
                      order by e.oncelik limit 1))
      into v_cari_hp
      from public.taraf t where t.id = b.taraf_id;

    if v_cari_hp is null then
        raise exception 'Cari için muhasebe hesabı çözülemedi (% ).', b.taraf_unvan
              using errcode = 'GK422';
    end if;

    v_sira := v_sira + 1;
    insert into public.muhasebe_fis_satir
        (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi,
         doviz_borc, doviz_alacak, doviz_kuru, taraf_id, proje_id, merkez_id, aciklama)
    values (v_fis, v_sira, v_cari_hp,
            case when (v_satis and not v_iade) or (not v_satis and v_iade)
                 then b.genel_toplam else 0 end,
            case when (v_satis and not v_iade) or (not v_satis and v_iade)
                 then 0 else b.genel_toplam end,
            coalesce(nullif(b.belge_dovizi, ''), 'TL'),
            0, 0, coalesce(b.doviz_kuru, 1),
            b.taraf_id, v_proje, v_merkez,
            left(coalesce(b.taraf_unvan, ''), 200));

    v_borc   := v_borc   + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                then b.genel_toplam else 0 end;
    v_alacak := v_alacak + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                then 0 else b.genel_toplam end;

    -- SATIR TUTARI KDV DAHIL OLABILIR: gocten gelen eski belgelerde
    --   belge_satir.tutar KDV'li yazilmis (matrah 412,42 iken satir 494,90).
    --   Belgenin MATRAHI otoritedir; kalemler ona orantili olceklenir, aksi
    --   halde fis dengesiz kapaniyordu.
    select coalesce(sum(bs.tutar), 0) into v_str_top
      from public.belge_satir bs where bs.belge_id = p_belge_id;
    if v_str_top <> 0 and abs(v_str_top - coalesce(b.matrah, 0)) > 0.01 then
        v_kats := coalesce(b.matrah, 0) / v_str_top;
    end if;

    -- 2) KALEM satirlari: ayni hesaba dusenler TEK satirda toplanir.
    for r in
        select public.fn_belge_satir_hesap(bs.id, v_satis) as hp,
               round(sum(bs.tutar) * v_kats, 2) as tutar,
               string_agg(distinct nullif(btrim(bs.aciklama), ''), ', ') as aciklama
          from public.belge_satir bs
         where bs.belge_id = p_belge_id
         group by 1
         having round(sum(bs.tutar) * v_kats, 2) <> 0
         order by 2 desc
    loop
        if r.hp is null then
            raise exception 'Belge kaleminin muhasebe hesabı çözülemedi; Yönetim › Hesap Planı eşlemesini tamamlayın.'
                  using errcode = 'GK422';
        end if;
        v_sira := v_sira + 1;
        insert into public.muhasebe_fis_satir
            (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi,
             doviz_borc, doviz_alacak, doviz_kuru, taraf_id, proje_id, merkez_id, aciklama)
        values (v_fis, v_sira, r.hp,
                case when (v_satis and not v_iade) or (not v_satis and v_iade)
                     then 0 else r.tutar end,
                case when (v_satis and not v_iade) or (not v_satis and v_iade)
                     then r.tutar else 0 end,
                coalesce(nullif(b.belge_dovizi, ''), 'TL'), 0, 0, coalesce(b.doviz_kuru, 1),
                b.taraf_id, v_proje, v_merkez,
                left(coalesce(r.aciklama, ''), 200));

        if v_enkalem is null then v_enkalem := v_sira; end if;   -- en buyuk kalem
        v_kalem  := v_kalem + r.tutar;
        v_borc   := v_borc   + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                    then 0 else r.tutar end;
        v_alacak := v_alacak + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                    then r.tutar else 0 end;
    end loop;

    -- Olcekleme/yuvarlama farki en buyuk kalem satirina yazilir.
    v_fark := round(coalesce(b.matrah, 0), 2) - round(v_kalem, 2);
    if v_fark <> 0 and v_enkalem is not null then
        update public.muhasebe_fis_satir
           set borc   = case when borc   <> 0 then borc   + v_fark else borc   end,
               alacak = case when alacak <> 0 then alacak + v_fark else alacak end
         where fis_id = v_fis and sira = v_enkalem;
        if (v_satis and not v_iade) or (not v_satis and v_iade)
            then v_alacak := v_alacak + v_fark;
            else v_borc   := v_borc   + v_fark;
        end if;
    end if;

    -- 3) KDV satirlari: ORAN bazinda.
    select coalesce(e.hesap_plani_id, null) into v_kdv_hp
      from public.muhasebe_eslestirme e
     where e.kural_turu = 'belge' and e.aktif = 1
       and e.rol = case when v_satis then 'kdv_satis' else 'kdv_alis' end
       and e.hesap_turu = case when v_satis then 'S' else 'A' end
     order by e.oncelik limit 1;

    if coalesce(b.kdv_tutari, 0) <> 0 then
        if v_kdv_hp is null then
            raise exception 'KDV hesabı eşlemesi yok (Yönetim › Hesap Planı).' using errcode = 'GK422';
        end if;

        for r in
            select bs.kdv as oran,
                   round(sum(bs.tutar) * v_kats * bs.kdv / 100.0, 2) as kdv
              from public.belge_satir bs
             where bs.belge_id = p_belge_id and coalesce(bs.kdv, 0) > 0
             group by bs.kdv
             having round(sum(bs.tutar) * v_kats * bs.kdv / 100.0, 2) <> 0
             order by 2 desc
        loop
            v_sira := v_sira + 1;
            insert into public.muhasebe_fis_satir
                (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi,
                 doviz_borc, doviz_alacak, doviz_kuru, taraf_id, proje_id, merkez_id, aciklama)
            values (v_fis, v_sira, v_kdv_hp,
                    case when (v_satis and not v_iade) or (not v_satis and v_iade)
                         then 0 else r.kdv end,
                    case when (v_satis and not v_iade) or (not v_satis and v_iade)
                         then r.kdv else 0 end,
                    coalesce(nullif(b.belge_dovizi, ''), 'TL'), 0, 0, coalesce(b.doviz_kuru, 1),
                    b.taraf_id, v_proje, v_merkez,
                    ('KDV %' || r.oran)::varchar);

            if v_enbuyuk is null then v_enbuyuk := v_sira; end if;   -- en buyuk KDV satiri
            v_kdv_top := v_kdv_top + r.kdv;
            v_borc   := v_borc   + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                        then 0 else r.kdv end;
            v_alacak := v_alacak + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                        then r.kdv else 0 end;
        end loop;

        -- SATIRDA ORAN YOKSA (gocten gelen belgelerde kdv alani 0 ama belgenin
        --   KDV'si dolu): tek KDV satiri yazilir, oran matrahtan turetilir.
        if v_enbuyuk is null then
            v_sira := v_sira + 1;
            insert into public.muhasebe_fis_satir
                (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi,
                 doviz_borc, doviz_alacak, doviz_kuru, taraf_id, proje_id, merkez_id, aciklama)
            values (v_fis, v_sira, v_kdv_hp,
                    case when (v_satis and not v_iade) or (not v_satis and v_iade)
                         then 0 else b.kdv_tutari end,
                    case when (v_satis and not v_iade) or (not v_satis and v_iade)
                         then b.kdv_tutari else 0 end,
                    coalesce(nullif(b.belge_dovizi, ''), 'TL'), 0, 0, coalesce(b.doviz_kuru, 1),
                    b.taraf_id, v_proje, v_merkez,
                    ('KDV' || case when coalesce(b.matrah, 0) <> 0
                                   then ' %' || round(b.kdv_tutari / b.matrah * 100)
                                   else '' end)::varchar);
            v_enbuyuk := v_sira;
            v_kdv_top := b.kdv_tutari;
            v_borc   := v_borc   + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                        then 0 else b.kdv_tutari end;
            v_alacak := v_alacak + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                        then b.kdv_tutari else 0 end;
        end if;

        -- Satir bazli KDV toplami belgenin KDV'siyle birebir tutmayabilir
        --   (kurus yuvarlamasi). Fark EN BUYUK KDV satirina yazilir; belge
        --   toplami otoritedir.
        v_fark := round(coalesce(b.kdv_tutari, 0), 2) - round(v_kdv_top, 2);
        if v_fark <> 0 and v_enbuyuk is not null then
            update public.muhasebe_fis_satir
               set borc   = case when borc   <> 0 then borc   + v_fark else borc   end,
                   alacak = case when alacak <> 0 then alacak + v_fark else alacak end
             where fis_id = v_fis and sira = v_enbuyuk;
            if (v_satis and not v_iade) or (not v_satis and v_iade)
                then v_alacak := v_alacak + v_fark;
                else v_borc   := v_borc   + v_fark;
            end if;
        end if;
    end if;

    -- 4) EK VERGI (OTV vb.) tek satirda.
    if coalesce(b.ek_vergi, 0) <> 0 then
        select e.hesap_plani_id into v_hp
          from public.muhasebe_eslestirme e
         where e.kural_turu = 'belge' and e.aktif = 1 and e.rol = 'ek_vergi'
           and e.hesap_turu = case when v_satis then 'S' else 'A' end
         order by e.oncelik limit 1;

        if v_hp is not null then
            v_sira := v_sira + 1;
            insert into public.muhasebe_fis_satir
                (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi,
                 doviz_borc, doviz_alacak, doviz_kuru, taraf_id, aciklama)
            values (v_fis, v_sira, v_hp,
                    case when (v_satis and not v_iade) or (not v_satis and v_iade)
                         then 0 else b.ek_vergi end,
                    case when (v_satis and not v_iade) or (not v_satis and v_iade)
                         then b.ek_vergi else 0 end,
                    coalesce(nullif(b.belge_dovizi, ''), 'TL'), 0, 0, coalesce(b.doviz_kuru, 1),
                    b.taraf_id, 'Ek vergi');
            v_borc   := v_borc   + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                        then 0 else b.ek_vergi end;
            v_alacak := v_alacak + case when (v_satis and not v_iade) or (not v_satis and v_iade)
                                        then b.ek_vergi else 0 end;
        end if;
    end if;

    -- 5) KURUS FARKI: belgenin kendi toplamlari birkac kurus tutmuyorsa
    --    (goc verisi) fark ayri bir satira yazilir. Buyuk fark HATA olarak
    --    kalir - sessizce kapatmak bozuk belgeyi gizlerdi.
    v_fark := round(v_borc, 2) - round(v_alacak, 2);
    if v_fark <> 0 and abs(v_fark) <= 1.00 then
        select e.hesap_plani_id into v_hp
          from public.muhasebe_eslestirme e
         where e.kural_turu = 'belge' and e.aktif = 1 and e.rol = 'kurus_farki'
           and e.hesap_turu = case when v_fark > 0 then 'S' else 'A' end
         order by e.oncelik limit 1;

        if v_hp is not null then
            v_sira := v_sira + 1;
            insert into public.muhasebe_fis_satir
                (fis_id, sira, hesap_plani_id, borc, alacak, doviz_cinsi,
                 doviz_borc, doviz_alacak, doviz_kuru, taraf_id, aciklama)
            values (v_fis, v_sira, v_hp,
                    case when v_fark < 0 then -v_fark else 0 end,
                    case when v_fark > 0 then  v_fark else 0 end,
                    coalesce(nullif(b.belge_dovizi, ''), 'TL'), 0, 0, coalesce(b.doviz_kuru, 1),
                    b.taraf_id, 'Kuruş farkı');
            if v_fark > 0 then v_alacak := v_alacak + v_fark;
                          else v_borc   := v_borc   - v_fark; end if;
        end if;
    end if;

    if round(v_borc, 2) <> round(v_alacak, 2) then
        raise exception 'Belge fişi dengesiz: borç % / alacak % (belge %).',
              round(v_borc, 2), round(v_alacak, 2), p_belge_id using errcode = 'GK422';
    end if;

    update public.muhasebe_fis
       set toplam_borc = v_borc, toplam_alacak = v_alacak,
           fis_no = public.fn_muhasebe_fis_no_uret(extract(year from b.belge_tarihi)::integer)
     where id = v_fis;

    update public.belge set muhasebe_fis_id = v_fis where id = p_belge_id;
    return v_fis;
end $$;

comment on function public.fn_belge_fisle(integer, integer) is
  'Fatura/fis belgesinin muhasebe fisini uretir; idempotent (190).';

-- ---------------------------------------------------------------------------
--  FISI GERI AL: belge silinir/iptal edilirse fis de gecersiz olmali.
--    Donem kilitliyse silinmez - TERS FIS gerekir (F4 kapsaminda).
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_fis_geri_al(p_belge_id integer,
                                                       p_kullanici integer default 0)
returns void language plpgsql as $$
declare v_fis integer; v_tarih date;
begin
    select muhasebe_fis_id, belge_tarihi::date into v_fis, v_tarih
      from public.belge where id = p_belge_id;
    if v_fis is null then return; end if;

    perform public.fn_muhasebe_donem_kontrol(v_tarih);

    delete from public.muhasebe_fis_satir where fis_id = v_fis;
    delete from public.muhasebe_fis where id = v_fis;
    update public.belge set muhasebe_fis_id = null, degistiren = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where id = p_belge_id;
end $$;

-- ---------------------------------------------------------------------------
--  TOPLU FISLEME: mevcut kesin belgeler. Eslemesi eksik olan ATLANIR ve
--  sayilir - tek belge yuzunden gocun tamami durmasin.
-- ---------------------------------------------------------------------------
-- Donus tipi 190 icinde genisledi (hata listesi eklendi): create or replace
--   tip degisikligini kabul etmez, once dusurulur.
drop function if exists public.fn_belge_fisle_toplu(date, date, integer);

create or replace function public.fn_belge_fisle_toplu(p_bas date default null,
                                                       p_bit date default null,
                                                       p_kullanici integer default 0)
returns table (fislenen integer, atlanan integer, hata_ornegi text, hatalar text)
language plpgsql as $$
declare
    r      record;
    v_ok   integer := 0;
    v_hata integer := 0;
    v_ilk  text := '';
    v_liste text := '';
begin
    perform set_config('gentegre.toplu_fis', '1', true);   -- ayar kapali olsa da uret

    for r in select id from public.belge
              where durum = 0 and muhasebe_fis_id is null
                and tur not in (10, 14)
                and (p_bas is null or belge_tarihi::date >= p_bas)
                and (p_bit is null or belge_tarihi::date <= p_bit)
              order by belge_tarihi, id
    loop
        begin
            if public.fn_belge_fisle(r.id, p_kullanici) is not null then
                v_ok := v_ok + 1;
            end if;
        exception when others then
            v_hata := v_hata + 1;
            if v_ilk = '' then v_ilk := 'Belge ' || r.id || ': ' || SQLERRM; end if;
            -- Ilk 20 hata listelenir: kullanici hangi belgeleri duzeltecegini
            --   gorsun; hepsini biriktirmek mesaji okunmaz yapardi.
            if v_hata <= 20 then
                v_liste := v_liste || case when v_liste = '' then '' else E'
' end
                        || 'Belge ' || r.id || ': ' || SQLERRM;
            end if;
        end;
    end loop;

    return query select v_ok, v_hata, v_ilk, v_liste;
end $$;

do $$
begin
    raise notice '190 tamam: fn_belge_fisle / fn_belge_fis_geri_al / fn_belge_fisle_toplu.';
end $$;
