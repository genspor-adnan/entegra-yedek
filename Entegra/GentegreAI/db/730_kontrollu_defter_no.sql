-- =====================================================================
--  730_kontrollu_defter_no.sql
--  Kontrollü ilaç defterine SIRA NUMARASI: `defter_no` tetikle üretilir.
--
--  NE OLUYORDU. 722'de `defter_no` NOT NULL ve VARSAYILANSIZ açılmıştı;
--    numarayı kimin üreteceği söylenmemişti. Akış ucu satır yazmaya
--    çalışınca `defter_no` boş kaldı ve kayıt reddedildi - defter, satır
--    yazılamadığı için hiç işlemedi.
--
--  İKİ AYRI DEFTER, İKİ AYRI SERİ. Kırmızı (narkotik) ve yeşil (psikotrop)
--    reçeteli ilaçların defteri MEVZUATTA AYRIDIR; tek seri verseydik iki
--    defterin sayfaları iç içe numaralanır ve hiçbiri kendi içinde
--    "1'den n'e kadar" olmazdı. Seri (şube, reçete rengi) başına ilerler.
--
--  NUMARA TETİKTE, UÇTA DEĞİL. Kart ekranından girilen satır da numara
--    almalı; uçta üretseydik iki giriş yolundan biri numarasız kalırdı
--    (719'da ameliyat numarasında öğrenilen ders).
--
--  ELLE VERİLEN NUMARA KORUNUR: dışarıdan devralınan bir defterin kendi
--    numarasıyla girilmesi gerekebilir. Tetik yalnız BOŞ olanı doldurur.
--
--  BOŞLUK BIRAKMAZ ama GERİYE DE GİTMEZ: numara o seride yazılmış EN BÜYÜK
--    numaradan bir fazlasıdır. Satır silinemediği için (722 tetiği) seri
--    delinmez; düzeltme satırı da kendi numarasını alır ve hangi satırı
--    düzelttiği `duzeltilen_id`de durur.
-- =====================================================================

create or replace function public.fn_kontrollu_defter_no()
returns trigger language plpgsql as $tg$
declare
  v_seri text;
  v_sira bigint;
begin
    if coalesce(new.defter_no, '') <> '' then
        return new;
    end if;

    -- SERİ ÖNEKİ: K kırmızı · Y yeşil · D diğer (kontrollü sayılmayan ama
    --   deftere yazılan kalem; ör. sayım satırı).
    v_seri := case coalesce(new.recete_renk, 0)
                when 1 then 'K' when 2 then 'Y' else 'D' end;

    select coalesce(max(nullif(regexp_replace(f.defter_no, '^\D+-', ''), '')::bigint), 0) + 1
      into v_sira
      from public.kontrollu_defter f
     where f.sube_id = new.sube_id
       and coalesce(f.recete_renk, 0) = coalesce(new.recete_renk, 0)
       and f.defter_no ~ ('^' || v_seri || '-[0-9]+$');

    new.defter_no := v_seri || '-' || lpad(v_sira::text, 6, '0');
    return new;
end;
$tg$;

drop trigger if exists tg_kontrollu_defter_no on public.kontrollu_defter;
create trigger tg_kontrollu_defter_no
  before insert on public.kontrollu_defter
  for each row execute function public.fn_kontrollu_defter_no();

-- Numarasız satır kalmasın diye kolona da boş varsayılan: tetik zaten
--   dolduruyor, ama varsayılan olmadan tetikten ÖNCE çalışan bir NOT NULL
--   kontrolüne takılma ihtimali kalmasın.
alter table public.kontrollu_defter alter column defter_no set default '';

comment on column public.kontrollu_defter.defter_no is
  '730: seri numarası, (sube, recete_renk) başına ilerler. K- kırmızı, '
  'Y- yeşil, D- diğer. Elle verilen numara korunur.';
