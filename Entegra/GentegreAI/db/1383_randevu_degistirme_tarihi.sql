-- 1383: randevu.degistirme_tarihi damgası (kullanıcı 19.11.2026: "değiştim ama sadece ekleyen görünüyor").
--
-- Randevu listesindeki "(HC-SK)" baş harfleri (Kayıt kolonu) değişimi degistirme_tarihi doluluğundan anlar. Genel
-- kart güncellemesi yalnız `degistiren`i yazıyor; 015'teki fn_degistirme_tarihi tetiği o gün var olan tablolara
-- kurulmuştu, randevu (243) sonradan geldiği için hiç damgalanmıyordu. Eklemede `degistiren` = ekleyen yazıldığından
-- değişim başka yoldan ayırt edilemiyor.
--
-- Standart tetik (her UPDATE damgalar) BURADA KULLANILMAZ: kayıttan hemen sonra RandevuHatirlatmasi bilgi SMS'inin
-- damgasını (sms_bilgi_baslangic, sms_metni) yazar - yeni randevu da "değişti" görünürdü. Yalnız iş alanları
-- değişince damgalanır. Geçmiş değişiklikler için tarih yok; onlar "(HC)" görünmeye devam eder.

create or replace function public.tg_randevu_degistirme_tarihi()
returns trigger language plpgsql as $$
begin
  if (to_jsonb(new) - array['sms_bilgi_baslangic', 'sms_metni', 'degistirme_tarihi', 'degistiren'])
     is distinct from
     (to_jsonb(old) - array['sms_bilgi_baslangic', 'sms_metni', 'degistirme_tarihi', 'degistiren']) then
    new.degistirme_tarihi := now();
  end if;
  return new;
end;
$$;

comment on function public.tg_randevu_degistirme_tarihi() is
  'BEFORE UPDATE (1383): iş alanı değişince degistirme_tarihi; SMS gönderim damgası tek başına değişim sayılmaz.';

drop trigger if exists tr_randevu_degistirme_tarihi on public.randevu;
create trigger tr_randevu_degistirme_tarihi
  before update on public.randevu
  for each row execute function public.tg_randevu_degistirme_tarihi();
