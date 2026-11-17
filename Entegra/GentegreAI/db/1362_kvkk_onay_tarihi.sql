-- 1362 - KVKK onayının ALINDIĞI tarih (kod inceleme 17.11.2026).
--   SORUN: "X gün sonra tekrar onay al" (1353) süresi, hastanın onay taşıyan SON başvurusunun tarihinden sayılıyordu.
--   Yeni başvuruya geçerli onay kopyalandığı (devir) için her gelişte süre yeniden başlıyor, düzenli gelen hastaya bir
--   daha hiç sorulmuyordu.
--   ÇÖZÜM: belge_basvuru.kvkk_onay_tarihi = onayın gerçekten alındığı gün. Tetik yazar:
--     * Hasta Reddetti (1) ya da SMS koduyla doğrulanan onay (kvkk_onay_kodu dolu)  -> bugün
--     * Kodsuz onay (3 ıslak imza / 4 SMS) -> hastanın önceki onaylı (3/4) başvurusundan DEVİR sayılır, onun tarihini
--       taşır; önceki yoksa bugün. (Kodsuz 4 yalnız devirle oluşur. Önceden onayı olan hastaya yeniden ıslak imza
--       alınırsa da eski tarih kalır - süre erken dolar, sorulur; ters yön, yani hiç dolmama, olmaz.)
--     * Onay değişmeden yapılan kayıt tarihi değiştirmez; onay boşalırsa tarih de boşalır.
--   Mevcut kayıtlar aynı kuralla, başvuru sırasıyla doldurulur. kvkk-durum ucu bu tarihi kullanır.
--   Tetik adı tr_belge_basvuru_kvkk_tarih: BEFORE tetikleri ada göre sıralanır, 1352'nin kod doğrulamasından
--   (tr_belge_basvuru_kvkk_kod -> onay 4) SONRA çalışır. Tekrar çalıştırılabilir.

alter table public.belge_basvuru add column if not exists kvkk_onay_tarihi date;
comment on column public.belge_basvuru.kvkk_onay_tarihi is
  '1362: KVKK onayının ALINDIĞI gün (devirde ilk onayın günü) - geçerlilik süresi bundan sayılır';

-- HASTA PARAMETREYLE: BEFORE INSERT tetiğinde başvurunun belge_basvuru satırı henüz tabloda yok.
create or replace function public.fn_kvkk_devir_tarihi(p_basvuru_id integer, p_hasta_id integer)
returns date language sql stable as $$
    -- Hastanın bu başvurudan önceki SON onaylı (3/4) başvurusunun onay günü; iptal sayılmaz.
    select coalesce(ob.kvkk_onay_tarihi, ol.belge_tarihi::date)
      from public.belge bl
      join public.belge ol on ol.tur = 19 and ol.durum <> 6 and ol.id <> bl.id
       and (ol.belge_tarihi < bl.belge_tarihi or (ol.belge_tarihi = bl.belge_tarihi and ol.id < bl.id))
      join public.belge_basvuru ob on ob.id = ol.id
       and coalesce(ob.hasta_id, ol.taraf_id) = coalesce(p_hasta_id, bl.taraf_id)
       and ob.kvkk_onay in (3, 4)
     where bl.id = p_basvuru_id
     order by ol.belge_tarihi desc, ol.id desc
     limit 1
$$;
drop function if exists public.fn_kvkk_devir_tarihi(integer);

create or replace function public.tg_belge_basvuru_kvkk_tarih()
returns trigger language plpgsql as $$
begin
  if new.kvkk_onay is null then
    new.kvkk_onay_tarihi := null;
    return new;
  end if;
  if tg_op = 'UPDATE' and new.kvkk_onay is not distinct from old.kvkk_onay
     and new.kvkk_onay_kodu is not distinct from old.kvkk_onay_kodu then
    new.kvkk_onay_tarihi := coalesce(old.kvkk_onay_tarihi, new.kvkk_onay_tarihi);
    return new;
  end if;
  if new.kvkk_onay = 1 or new.kvkk_onay_kodu is not null then
    new.kvkk_onay_tarihi := current_date;
  else
    -- Kodsuz onay = devir. INSERT'te başlık (belge) satırı zaten yazılmıştır (1:1 uzantı).
    new.kvkk_onay_tarihi := coalesce(public.fn_kvkk_devir_tarihi(new.id, new.hasta_id), current_date);
  end if;
  return new;
end $$;

drop trigger if exists tr_belge_basvuru_kvkk_tarih on public.belge_basvuru;
create trigger tr_belge_basvuru_kvkk_tarih
  before insert or update of kvkk_onay, kvkk_onay_kodu on public.belge_basvuru
  for each row execute function public.tg_belge_basvuru_kvkk_tarih();

-- ------------------------------------------------ mevcut kayıtlar ----
do $$
declare r record; v_say integer := 0;
begin
  for r in
    select bb.id, bb.hasta_id, bb.kvkk_onay, bb.kvkk_onay_kodu, bl.belge_tarihi::date as gun
      from public.belge_basvuru bb join public.belge bl on bl.id = bb.id
     where bb.kvkk_onay is not null and bb.kvkk_onay_tarihi is null
     order by bl.belge_tarihi, bl.id
  loop
    update public.belge_basvuru
       set kvkk_onay_tarihi = case when r.kvkk_onay = 1 or r.kvkk_onay_kodu is not null then r.gun
                                   else coalesce(public.fn_kvkk_devir_tarihi(r.id, r.hasta_id), r.gun) end
     where id = r.id;
    v_say := v_say + 1;
  end loop;
  raise notice '1362: % başvurunun KVKK onay günü dolduruldu', v_say;
end $$;
