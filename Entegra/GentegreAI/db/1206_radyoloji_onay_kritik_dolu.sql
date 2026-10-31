\set ON_ERROR_STOP on
-- ============================================================================
--  1206 — Radyoloji onay ön koşulu: kritik bulgu bildirimi DOLU olmalı
--
--  Kod inceleme 30.10.2026 K22: fn_radyoloji_rapor_onaylanabilir yalnız
--  radyoloji_kritik_bulgu satırı VAR mı diye bakıyordu; API boş bulgu / boş
--  bildirilen ad ile satır yazabildiği için (artık 400) boş kayıt onay kapısını
--  açıyordu. Sayım yalnız bulgu ve bildirilen_ad dolu satırları sayar.
--  Gövde 809'daki tanımın aynısı, tek fark bu koşul.
-- ============================================================================
begin;

CREATE OR REPLACE FUNCTION public.fn_radyoloji_rapor_onaylanabilir(p_rapor_id integer)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  r       record;
  v_adet  integer;
  v_eksik text;
begin
  select rp.id, rp.durum, rp.kilit, rp.istem_id, i.kritik
    into r
    from public.radyoloji_rapor rp
    join public.radyoloji_istem i on i.id = rp.istem_id
   where rp.id = p_rapor_id;
  if not found then return 'Rapor bulunamadı.'; end if;

  if r.kilit = 1 then
    return 'Rapor onaylanmış ve kilitli; düzeltme ek rapor (addendum) olarak yazılır.';
  end if;

  -- Şablonda ZORUNLU işaretli bölüm boş kalamaz.
  select count(*) into v_adet
    from public.radyoloji_rapor_bolum b
    join public.radyoloji_rapor rp on rp.id = b.rapor_id
    left join public.radyoloji_sablon_bolum sb
           on sb.sablon_id = rp.sablon_id and sb.baslik = b.baslik
   where b.rapor_id = p_rapor_id
     and coalesce(sb.zorunlu, 0) = 1
     and btrim(coalesce(b.metin, '')) = '';
  if v_adet > 0 then
    return 'Zorunlu bölümler boş: rapor onaya gönderilemez.';
  end if;

  -- KRİTİK BULGU: işaretliyse bildirim kaydı ŞART.
  if coalesce(r.kritik, 0) = 1 then
    select count(*) into v_adet
      from public.radyoloji_kritik_bulgu k
     where k.istem_id = r.istem_id
       -- 1206: boş bildirim (kime / ne) sayılmaz - kayıt var ama içi boşsa onay açılmaz.
       and coalesce(k.bulgu, '') <> '' and coalesce(k.bildirilen_ad, '') <> '';
    if v_adet = 0 then
      return 'Kritik bulgu bildirimi kaydedilmeden rapor onaylanamaz.';
    end if;
  end if;

  -- BAKANLIK PROFİLİ (809): yalnız ayar açıkken. Kapıyı onaya koymanın
  --   nedeni: reddedilen HL7 mesajını radyolog görmez, saatler sonra
  --   operasyon görür ve rapor kilitlenmiş olur.
  if coalesce((select r2.deger from public.referans r2
                where r2.anahtar = 'radyoloji.bakanlik_profili'), '0') = '1' then
    v_eksik := public.fn_rad_bakanlik_eksik(p_rapor_id);
    if v_eksik <> '' then return v_eksik; end if;
  end if;

  return '';                                   -- boş = onaylanabilir
end $function$;

commit;
