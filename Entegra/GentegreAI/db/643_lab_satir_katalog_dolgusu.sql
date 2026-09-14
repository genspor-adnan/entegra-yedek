-- =====================================================================
--  643_lab_satir_katalog_dolgusu.sql
--  İSTEM SATIRINDA BİRİM ve REFERANS ARALIĞI BOŞ KALMASIN.
--
--  Kullanıcı: "birim ve referans aralığı boş hâlâ". İstem satırı
--  açılırken yalnız kod/ad yazılıyordu; birim ve referans ancak SONUÇ
--  yazıldığında (642 sonrası ayna kolonlarıyla) doluyordu. Oysa teknisyen
--  değeri GİRERKEN neyle kıyaslayacağını görmek zorunda - sonuçtan sonra
--  dolan referans, işe yaramanın bir adım gerisinde kalıyor.
--
--  NEDEN TETİK, NEDEN SERVİS DEĞİL: istem satırı ÜÇ yoldan doğuyor -
--  `LabServisi.IstemAcAsync`, istem kartının "Tetkikler" detayı (jenerik
--  kart kaydı) ve göç/onarım betikleri. Dolguyu servise koymak, kartından
--  elle tetkik ekleyen kullanıcıyı yine boş kolonlarla bırakırdı.
--
--  YALNIZ BOŞ ALAN DOLDURULUR: kurum satıra kendi birimini/aralığını
--  yazdıysa (dış laboratuvar sonucu, özel yöntem) korunur.
--
--  REFERANS HASTAYA GÖRE ÇÖZÜLÜR: `fn_lab_referans` yaş/cinsiyet bandını
--  seçer (642 ile hemogram ve tam idrarda çocuk bantları da var). Hasta
--  belli değilse erişkin bandı döner.
-- =====================================================================

-- --------------------------------------------------------------- metin
--  Sayısal aralık "0,5 - 1,2"; tek taraflı sınır "> 0,5" / "< 1,2";
--  sayısal olmayan tetkikte referansın kendi metni ("Negatif", "Berrak").
create or replace function public.fn_lab_referans_metin(
        p_tetkik_id integer, p_hasta_id integer, p_tarih date default null)
returns varchar
language sql
stable
as $$
    select case
             when r.tetkik_id is null then ''::varchar
             when r.alt is null and r.ust is null then r.metin
             when r.alt is not null and r.ust is not null
                  then (trim(to_char(r.alt, 'FM999999990.999')) || ' - '
                     || trim(to_char(r.ust, 'FM999999990.999')))::varchar
             when r.alt is not null
                  then ('> ' || trim(to_char(r.alt, 'FM999999990.999')))::varchar
             else ('< ' || trim(to_char(r.ust, 'FM999999990.999')))::varchar
           end
      from public.fn_lab_referans(p_tetkik_id, p_hasta_id, p_tarih) r;
$$;

comment on function public.fn_lab_referans_metin(integer, integer, date) is
    'Tetkik referans araligini ekranda gosterilecek metne cevirir (643).';

-- --------------------------------------------------------------- tetik
create or replace function public.tg_lab_istem_satir_katalog()
returns trigger
language plpgsql
as $$
declare
    v_hasta integer;
begin
    if new.tetkik_id is null then
        return new;
    end if;

    select i.taraf_id into v_hasta
      from public.lab_istem i where i.id = new.istem_id;

    select coalesce(nullif(new.kod, ''), t.kod),
           coalesce(nullif(new.ad, ''), t.ad),
           coalesce(nullif(new.birim, ''), t.birim, ''),
           coalesce(nullif(new.referans, ''),
                    public.fn_lab_referans_metin(t.id, v_hasta, current_date), '')
      into new.kod, new.ad, new.birim, new.referans
      from public.lab_tetkik t
     where t.id = new.tetkik_id;

    return new;
end $$;

drop trigger if exists tg_lab_istem_satir_katalog on public.lab_istem_satir;
create trigger tg_lab_istem_satir_katalog
    before insert on public.lab_istem_satir
    for each row execute function public.tg_lab_istem_satir_katalog();

-- ------------------------------------------------------------- onarim
--  MEVCUT satirlar: yalniz BOS olan birim/referans doldurulur. Sonucu
--  yazilmis satirin referansi o gun damgalandigi icin (lab_sonuc) burada
--  degistirilmez - rapor gecmise donuk degismemeli.
update public.lab_istem_satir s
   set birim = case when coalesce(s.birim, '') = ''
                    then coalesce(t.birim, '') else s.birim end,
       referans = case when coalesce(s.referans, '') = ''
                       then coalesce(public.fn_lab_referans_metin(
                                t.id, i.taraf_id, current_date), '')
                       else s.referans end
  from public.lab_tetkik t, public.lab_istem i
 where t.id = s.tetkik_id
   and i.id = s.istem_id
   and (coalesce(s.birim, '') = '' or coalesce(s.referans, '') = '')
   and not exists (select 1 from public.lab_sonuc x
                    where x.istem_satir_id = s.id and x.durum <> 4);

do $kontrol$
declare
    v_bos int;
begin
    select count(*) into v_bos
      from public.lab_istem_satir s
      join public.lab_tetkik t on t.id = s.tetkik_id
     where coalesce(s.referans, '') = ''
       and exists (select 1 from public.lab_tetkik_referans r
                    where r.tetkik_id = t.id);
    raise notice '643 tamam: referansi olan ama satirda bos kalan % satir', v_bos;
end $kontrol$;
