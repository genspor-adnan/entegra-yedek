-- 1342 - "Radyolog Değerlendirmesi" (eski ad: Bakanlık Değerlendirmesi) + onay kapısı: iki puan boşsa onay yok.
--
-- Kullanıcı 14.11.2026: "Bakanlık Değerlendirmesi rename Radyolog Değerlendirmesi.. sonra da onay ön kontrolüne puanlar
--   boş engeli ekle". Puanları raporu yazan radyolog verir (İstem Nedeni: klinisyenin istem nedeni raporu yazmaya yetti
--   mi; Çekim Kalitesi: görüntüler değerlendirilebilir mi); Teletıp ORU mesajında OBX-13 olarak gider. Bugüne kadar
--   0 ("—") ile onay geçiyordu; Bakanlık profili açıkken artık ikisi de 1-5 arası verilmeden onay / e-imza açılmaz.
--   Kapı fn_radyoloji_rapor_onaylanabilir'de (1206 gövdesi + bu koşul); yalnız onay yolları çağırır, Uzmana Gönder
--   etkilenmez. Kolon adları (istem_nedeni_puan, cekim_kalite_puan) değişmez.
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
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
  select rp.id, rp.durum, rp.kilit, rp.istem_id, i.kritik,
         coalesce(rp.istem_nedeni_puan, 0) as istem_nedeni_puan,
         coalesce(rp.cekim_kalite_puan, 0) as cekim_kalite_puan
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
    -- 1342: RADYOLOG DEĞERLENDİRMESİ - iki puan da (1-5) verilmeden onay yok (OBX-13 boş gidemez).
    if r.istem_nedeni_puan < 1 or r.cekim_kalite_puan < 1 then
      return 'Radyolog Değerlendirmesi eksik: İstem Nedeni ve Çekim Kalitesi puanlarını verin.';
    end if;
  end if;

  return '';                                   -- boş = onaylanabilir
end $function$;

comment on function public.fn_radyoloji_rapor_onaylanabilir(integer) is
  '284/809/1206/1342: rapor onay ön koşulu - kilit, zorunlu bölüm, kritik bulgu bildirimi, Bakanlık dört parça, Radyolog Değerlendirmesi puanları. Boş metin = onaylanabilir.';

-- Çeviri (850 deseni): yeni etiket.
insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Radyolog Değerlendirmesi', 1, 'Radiologist assessment')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin, degistirme_tarihi = now();

-- Yardım kataloğu anahtarı (1341): eski ad aramada kalsın, yeni ad eklensin.
update public.ai_rehber_ekran
   set anahtar = anahtar || ' radyolog değerlendirmesi'
 where kaynak = 'radyoloji-rapor' and anahtar not like '%radyolog değerlendirmesi%';

commit;
