-- ============================================================================
--  428 - TAKILI KALAN KUYRUK SATIRLARININ KURTARILMASI (İTS + e-Nabız)
--
--  Kuyruktan alma satiri "gonderiliyor" (2) yapiyor; gonderim sirasinda islem
--  coker, konteyner yeniden baslar ya da aglar kopar ise satir O DURUMDA
--  KALIR ve bir daha HIC alinmaz - sessizce kaybolur. Testte tam bu oldu:
--  bir hata sonrasi bildirim 2'de asili kaldi, "gonderilecek bildirim yok"
--  denmeye basladi.
--
--  Cozum: belli bir sureden uzun suredir "gonderiliyor" olan satir yeniden
--  kuyruga alinir. Sure ONBEKLEME degil GUVENLIK PAYIDIR - normal bir
--  gonderim saniyeler surer; 15 dakika, en yavas servis cagrisindan bile
--  kat kat uzun.
-- ============================================================================

create or replace function public.fn_its_siradakiler(p_adet integer default 20)
returns setof public.its_bildirim language sql as $$
    update public.its_bildirim b
       set durum = 2, deneme = b.deneme + 1, son_deneme = now()
     where b.id in (
         select x.id from public.its_bildirim x
          where (x.durum in (1, 4)
                 -- TAKILI SATIR: gonderim yarida kaldi, geri al.
                 or (x.durum = 2 and x.son_deneme < now() - interval '15 minutes'))
            and x.planlanan <= now()
            and x.deneme < 5
          order by x.planlanan asc, x.id asc
          limit p_adet
          for update skip locked
     )
    returning b.*;
$$;

create or replace function public.fn_enabiz_siradakiler(p_adet integer default 20)
returns setof public.enabiz_paket language sql as $$
    update public.enabiz_paket p
       set durum = 2, deneme = p.deneme + 1, son_deneme = now()
     where p.id in (
         select x.id from public.enabiz_paket x
          join public.enabiz_paket_turu t on t.id = x.paket_turu_id
          where (x.durum in (1, 4)
                 or (x.durum = 2 and x.son_deneme < now() - interval '15 minutes'))
            and x.planlanan <= now()
            and t.aktif = 1 and t.oto_gonder = 1
            and x.deneme < 5
          order by x.planlanan asc, x.id asc
          limit p_adet
          for update skip locked
     )
    returning p.*;
$$;

comment on function public.fn_its_siradakiler(integer) is
    'ITS kuyrugu (427/428): atomik claim + 15 dk takili kalan satiri kurtarma.';
