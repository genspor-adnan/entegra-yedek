-- ============================================================================
--  Gentegre AI — ŞUBE LOGOSU: TÜRÜ BOŞ YÜKLENEN RESİM DE LOGO SAYILIR
--  1166_sube_logo_turu_bos.sql
--
--  Kullanıcı (24.10.2026): "müşteri logosu görünmedi". UNIVERSE'te şube
--  kartına "unv-white.png" yüklenmiş, belge türü seçilmemiş. 772 kuralı türü
--  boş resmi yalnız adı "logo" ile başlıyorsa kabul ediyordu - dosya ne
--  başlangıç ekranında ne üst şeritte ne çıktıda göründü.
--
--  YENİ KURAL: önce "Logo" işaretli resim, sonra adı "logo" ile başlayan,
--  sonra TÜRÜ BOŞ resim (varsayılan işaretli olan önce, sonra en eski).
--  Kaşe / İmza türü verilmiş resim yine DIŞARIDA; türü boş olup adı kaşe /
--  imza diyen dosya da alınmaz. Görünümün kolonları değişmez (create or
--  replace yeter).
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_sube_antet as
select s.id                                   as sube_id,
       coalesce(nullif(s.unvan, ''), s.ad)    as unvan,
       s.ad                                   as sube_ad,
       s.adres,
       s.ilce,
       s.il,
       s.telefon,
       s.eposta,
       s.web,
       s.mersis_no,
       s.vkno,
       s.vd,
       (select d.id
          from public.dokuman d
         where d.kaynak = 'sube' and d.kaynak_id = s.id and d.durum = 1
           and d.content_type like 'image/%'
           and (d.belge_turu ilike 'logo%' or d.ad ilike 'logo%'
                or (coalesce(d.belge_turu, '') = ''
                    and d.ad not ilike 'ka_e%' and d.ad not ilike 'imza%'))
         order by (d.belge_turu ilike 'logo%') desc, (d.ad ilike 'logo%') desc,
                  d.varsayilan desc, d.id
         limit 1)                             as logo_dokuman_id
  from public.sube s;

comment on view public.v_sube_antet is
  '1166: cikti antedinin TEK kaynagi (unvan/adres/iletisim/vergi + logo '
  'dokuman id). Logo: sube kaynakli resim; once belge_turu Logo, sonra adi '
  'logo ile baslayan, sonra turu bos resim. Kase ve Imza disarida.';

do $$
declare v_sube int; v_logo int;
begin
    select count(*), count(logo_dokuman_id) into v_sube, v_logo
      from public.v_sube_antet;
    raise notice '1166 tamam: % sube, %''sinde logo var.', v_sube, v_logo;
end $$;
