-- =====================================================================
--  945_calisma_karti_kurallari.sql
--  ÇALIŞMA ŞABLONU ve İZİN & İSTİSNA KARTLARI (mockup
--  Ekranlar/Randevu/calisma_sablonu_karti.html, izin_istisna_karti.html;
--  kullanıcı: "kartları bugünkü mockuplara göre değiştir").
--
--  1. ŞABLON ÇAKIŞMASI ENGELLENİR. Aynı doktorun iki AKTİF şablonu aynı
--     günde, örtüşen saatlerde ve örtüşen geçerlilik aralığında olamaz
--     (mockup: "aynı gün ve saatte iki aktif şablon çakışırsa kayıt
--     engellenir"). Önceden ikisi de plana blok üretiyordu: takvim aynı
--     saate iki slot dizisi çiziyordu.
--     İKİ HAFTADA BİR + İKİ HAFTADA BİR, başlangıçları tam tek sayıda hafta
--     arayla ise ayrı haftalara düşer - çakışma sayılmaz (fn_hekim_calisma_
--     bloklari'nin tekrar hesabıyla aynı: ((gun - gecerli_bas) / 7) % 2).
--     Şube ve bölüm farkı çakışmayı KALDIRMAZ: doktor aynı saatte iki yerde
--     olamaz.
--
--  2. İSTİSNA ONAY İZİ: onaylayan / onay_tarihi. Kart altındaki "Onaylayan"
--     buradan okunur; durum 1'e (Onaylı) geçtiği anda tetikle yazılır -
--     istemci bu alanları yazmaz.
--
--  3. EK MESAİDE KANAL ZORUNLU (mockup: "Ek mesai yeni blok ekler, saat ve
--     kanal zorunlu"). Saat zaten ck_hci_saat ile zorunluydu.
--
--  4. Yeni istisna "Bekliyor" ile açılır (kart varsayılanı, KartKatalogu):
--     yalnız onaylı istisna planı kapatır. Bu dosya mevcut kayıtlara
--     dokunmaz.
--
--  Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------ 1. şablon ----
create or replace function public.tg_calisma_sablon_cakisma()
returns trigger
language plpgsql
as $$
declare
    v_ad   text;
    v_fark integer;
begin
    if coalesce(new.aktif, 0) <> 1 then return new; end if;

    select s.ad || ' (' || coalesce(d.ad, '') || ' · ' || s.bas1 || '–' || s.bit1
           || case when nullif(s.bas2, '') is not null then ' / ' || s.bas2 || '–' || s.bit2 else '' end || ')'
      into v_ad
      from public.hekim_calisma_sablon s
      left join public.departman d on d.id = s.departman_id
     where s.hekim_id = new.hekim_id
       and s.aktif = 1
       and s.id <> coalesce(new.id, -1)
       -- ortak gün
       and string_to_array(replace(s.gunler, ' ', ''), ',') && string_to_array(replace(new.gunler, ' ', ''), ',')
       -- örtüşen geçerlilik
       and daterange(s.gecerli_bas, coalesce(s.gecerli_bit, 'infinity'::date), '[]')
           && daterange(new.gecerli_bas, coalesce(new.gecerli_bit, 'infinity'::date), '[]')
       -- iki haftada bir, ayrı haftalar
       and not (s.tekrar = 2 and new.tekrar = 2
                and (new.gecerli_bas - s.gecerli_bas) % 7 = 0
                and abs((new.gecerli_bas - s.gecerli_bas) / 7) % 2 = 1)
       -- örtüşen saat bloğu (2 x 2 blok; 'HH:MM' metni sözlük sırasıyla doğru karşılaştırılır)
       and exists (
           select 1
             from (values (s.bas1, s.bit1), (nullif(s.bas2, ''), nullif(s.bit2, ''))) a(b, e),
                  (values (new.bas1, new.bit1), (nullif(new.bas2, ''), nullif(new.bit2, ''))) n(b, e)
            where a.b is not null and n.b is not null and a.b < n.e and n.b < a.e)
     order by s.id
     limit 1;

    if v_ad is null then return new; end if;

    raise exception 'Bu doktorun aktif "%" şablonu aynı gün ve saatlerde geçerli. '
                    'Saatleri ya da günleri ayırın, geçerlilik tarihlerini değiştirin '
                    'veya diğer şablonu pasife alın.', v_ad
        using errcode = 'GK422';
end $$;

drop trigger if exists tr_calisma_sablon_cakisma on public.hekim_calisma_sablon;
create trigger tr_calisma_sablon_cakisma
    before insert or update of hekim_id, gunler, bas1, bit1, bas2, bit2, tekrar, gecerli_bas, gecerli_bit, aktif
    on public.hekim_calisma_sablon
    for each row execute function public.tg_calisma_sablon_cakisma();

-- ------------------------------------------------------- 2. onay izi ------
alter table public.hekim_calisma_istisna add column if not exists onaylayan   integer not null default 0;
alter table public.hekim_calisma_istisna add column if not exists onay_tarihi timestamptz;

comment on column public.hekim_calisma_istisna.onaylayan is
  '945: istisnayi onaylayan kullanici (durum 1e gecis aninda tetikle yazilir).';

create or replace function public.tg_calisma_istisna_onay()
returns trigger
language plpgsql
as $$
begin
    -- 3. ek mesaide kanal zorunlu
    if new.tur = 4 and coalesce(nullif(replace(new.kanallar, ',', ''), ''), '') = '' then
        raise exception 'Ek mesai için en az bir randevu kanalı seçilmeli (banko, portal ya da çağrı merkezi).'
            using errcode = 'GK422';
    end if;

    if new.durum = 1 and (tg_op = 'INSERT' or coalesce(old.durum, -1) <> 1) then
        new.onaylayan   := case when tg_op = 'INSERT' then new.ekleyen
                                else coalesce(nullif(new.degistiren, 0), new.ekleyen) end;
        new.onay_tarihi := now();
    elsif new.durum <> 1 then
        new.onaylayan   := 0;
        new.onay_tarihi := null;
    end if;
    return new;
end $$;

drop trigger if exists tr_calisma_istisna_onay on public.hekim_calisma_istisna;
create trigger tr_calisma_istisna_onay
    before insert or update on public.hekim_calisma_istisna
    for each row execute function public.tg_calisma_istisna_onay();

-- ------------------------------------------------------------ sözlük ------
insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Çalışma Şablonu', 1, 'Work Template'),
    ('etiket', 'Haftalık Düzen', 1, 'Weekly Pattern'),
    ('etiket', 'Çalışma günleri', 1, 'Working days'),
    ('etiket', 'Çalışma blokları', 1, 'Working blocks'),
    ('etiket', 'Randevu aralığı (slot)', 1, 'Appointment interval (slot)'),
    ('etiket', 'Kanal & Kota', 1, 'Channel & Quota'),
    ('etiket', 'Geçerlilik', 1, 'Validity'),
    ('etiket', 'Bu şablonun etkisi', 1, 'Impact of this template'),
    ('etiket', 'Doktorun diğer şablonları', 1, 'Doctor''s other templates'),
    ('etiket', 'Haftalık slot', 1, 'Weekly slots'),
    ('etiket', 'Haftalık çalışma', 1, 'Weekly hours'),
    ('etiket', 'Önümüzdeki 2 hafta', 1, 'Next 2 weeks'),
    ('etiket', 'Doluluk', 1, 'Occupancy'),
    ('etiket', 'Pasife Al', 1, 'Deactivate'),
    ('etiket', 'Aktifleştir', 1, 'Activate'),
    ('etiket', 'Kopyala', 1, 'Copy'),
    ('etiket', 'İzin & İstisna', 1, 'Leave & Exception'),
    ('etiket', 'Ne oluyor?', 1, 'What happens?'),
    ('etiket', 'Plan bu haftayı nasıl görecek', 1, 'How the plan will see this week'),
    ('etiket', 'Etkilenen randevular', 1, 'Affected appointments'),
    ('etiket', 'Doktorun yakın istisnaları', 1, 'Doctor''s upcoming exceptions'),
    ('etiket', 'Başka doktora aktar…', 1, 'Move to another doctor…'),
    ('etiket', 'Sonraki boş güne kaydır', 1, 'Shift to next free day'),
    ('etiket', 'Hastaya SMS ile bildir', 1, 'Notify patient by SMS'),
    ('etiket', 'Onayla', 1, 'Approve'),
    ('etiket', 'Onaylayan', 1, 'Approved by')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin;

do $$
begin
    raise notice '945 tamam: sablon cakisma kurali, istisna onay izi, ek mesai kanal zorunlulugu.';
end $$;
