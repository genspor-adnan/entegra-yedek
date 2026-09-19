-- ============================================================================
--  Gentegre AI — KADRO HAREKETİNDE BÖLÜM / GÖREV BOŞ KALIYOR
--  842_kadro_bolum_gorev_dolgu.sql
--
--  Kullanıcı: *"kadro geçmişine bölüm ve görev gelmemiş"*.
--
--  ============ NEDEN BOŞTU ===========================================
--  841'de karttan deftere yazan iki tetik var:
--    · tg_personel_kadro_iz_taraf   → bölüm/görev DEĞİŞİNCE satır düşürür,
--    · tg_personel_giris_cikis_iz   → işe giriş/çıkış satırını düşürür.
--  İkincisi yalnız `taraf_personel` kolonlarını okuyordu (`gorev` serbest
--  metni, şube). Bölüm ve görev ise `taraf.departman` / `taraf.gorev_id`
--  kolonlarında durur - tetik onlara HİÇ bakmıyordu. Sonuç: giriş tarihi
--  atanan 104 personelin "İşe giriş" satırı bölümsüz/görevsiz doğdu
--  (`gorev` serbest metni de 104'te 1 doluydu, o kolon zaten terk edilmiş).
--
--  ============ DOLGUNUN SINIRI =======================================
--  841 "geçmiş satırı bugünkü bölümle doldurmak YANLIŞ olur" diyordu ve bu
--  genel olarak doğru. Burada dolduruluyor çünkü bu satırların hiçbiri
--  bölüm/görev TAŞIMIYOR - yani kaybedilecek bir geçmiş bilgi yok, tek
--  bilinen gerçek kartın bugünkü hâli. Dolgu yalnız **iki alanı da boş**
--  satırlara uygulanır; elle girilmiş bir bölüm asla ezilmez.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------ giriş/çıkış izi: bölüm/görev de ----
create or replace function public.tg_personel_giris_cikis_iz()
returns trigger language plpgsql as $$
declare v_dep integer; v_gorev integer;
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;

    -- POZİSYONUN TAMAMI: satır "o tarihteki tam pozisyon" demek; bölüm ve
    --   görev `taraf`ta durur, bu yüzden oradan okunur.
    select t.departman, t.gorev_id into v_dep, v_gorev
      from public.taraf t where t.id = new.id;

    if new.ise_giris_tarihi is not null
       and new.ise_giris_tarihi is distinct from old.ise_giris_tarihi then
        if exists (select 1 from public.personel_hareket
                    where taraf_id = new.id and tur = 1) then
            update public.personel_hareket
               set yururluk = new.ise_giris_tarihi,
                   departman_id = coalesce(departman_id, v_dep),
                   gorev_id     = coalesce(gorev_id, v_gorev),
                   degistirme_tarihi = now()
             where taraf_id = new.id and tur = 1;
        else
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, gorev, departman_id, gorev_id,
                    sube_id, aciklama, kaynak, ekleyen)
            values (new.id, 1, new.ise_giris_tarihi, coalesce(new.gorev, ''),
                    v_dep, v_gorev, coalesce(new.sube_id, 0),
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
                   degistirme_tarihi = now()
             where taraf_id = new.id and tur = 9;
        else
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, gorev, departman_id, gorev_id,
                    sube_id, aciklama, kaynak, ekleyen)
            values (new.id, 9, new.isten_cikis_tarihi, coalesce(new.gorev, ''),
                    v_dep, v_gorev, coalesce(new.sube_id, 0),
                    'İşten çıkış (karttan).', 2, new.degistiren);
        end if;
    end if;
    return null;
end $$;

-- --------------------------------------------------------- geri dolgu ----
-- YEDEK: dolgu yanlış giderse geri alınabilsin (müşteri veritabanında da
--   çalışacak betik - satır ezmeden önce kopya alınır).
create table if not exists public.personel_hareket_yedek_842 as
select id, departman_id, gorev_id from public.personel_hareket
 where departman_id is null and gorev_id is null;

update public.personel_hareket h
   set departman_id = t.departman,
       gorev_id     = t.gorev_id,
       degistirme_tarihi = now()
  from public.taraf t
 where t.id = h.taraf_id
   and h.departman_id is null
   and h.gorev_id is null
   and (t.departman is not null or t.gorev_id is not null);

do $$
declare v_kalan integer; v_dolu integer;
begin
    select count(*) filter (where departman_id is not null or gorev_id is not null),
           count(*) filter (where departman_id is null and gorev_id is null)
      into v_dolu, v_kalan from public.personel_hareket;
    raise notice '842 tamam: % harekette bolum/gorev dolu, % satir hala bos '
                 '(karti da bos olan personel).', v_dolu, v_kalan;
end $$;
