-- =====================================================================
-- 989 - GUN SONU: odeme turu bazli ozet (mockup tablosu)
--
-- Mockup banko_gun_sonu_kasa_teslimi.html: Tur | Adet | Tahsilat | Iade |
--   Net | Kasada durur? | Teslim / Eslesme.
--
-- NEDEN TUR BAZLI DOKUM: tek "nakit/POS" toplami "hangi turden ne kadar
--   girdi" sorusunu yanitlamiyor. Gun sonunda kasiyer ile sorumlu bu
--   tabloya bakarak mutabik kalir; POS gun sonu ve banka ekstresi
--   eslesmesi de tur satirina baglanir.
--
-- KASADA DURUR MU, TURUN KENDI OZELLIGINDEN gelir (`ana_hesap_turu`):
--   K = nakit, kasada sayilir. P/B = POS/havale, kasaya para olarak
--   girmez. ceksenet = fiziken kasada ama SAYIMA GIRMEZ (portfoye alinir).
--   Kupon/indirim = nakit akisi yok.
-- =====================================================================

create or replace view public.v_banko_oturum_tur_ozeti as
select k.oturum_id,
       t.kod                                   as tur,
       t.ad                                    as tur_adi,
       t.grup                                  as tur_grup,
       coalesce(t.ana_hesap_turu, '')          as hesap_turu,
       -- 1 = kasada sayilir, 2 = kasaya girmez, 3 = fiziken var sayima
       -- girmez (cek/senet), 4 = nakit akisi yok (kupon/indirim)
       case when t.ana_hesap_turu = 'K'        then 1
            when t.grup = 'ceksenet'           then 3
            when t.ana_hesap_turu in ('P','B') then 2
            when t.grup = 'kupon'              then 4
            else 2 end                         as kasa_durumu,
       count(*)                                           as adet,
       sum(case when t.yon > 0 then k.yerel_tutar else 0 end)::numeric(18,2) as tahsilat,
       sum(case when t.yon < 0 then k.yerel_tutar else 0 end)::numeric(18,2) as iade,
       (sum(case when t.yon > 0 then k.yerel_tutar else 0 end)
        - sum(case when t.yon < 0 then k.yerel_tutar else 0 end))::numeric(18,2) as net
  from public.kasa_islem k
  join public.kasa_islem_turu t on t.kod = k.tur
 where k.oturum_id is not null and k.durum <> 9
   -- Fark fisi (kaynak_tur 1385) dokume girmez: tahsilat degil duzeltme.
   and k.kaynak_tur is distinct from 1385
 group by k.oturum_id, t.kod, t.ad, t.grup, t.ana_hesap_turu, t.yon;

do $$
begin
  raise notice '989: v_banko_oturum_tur_ozeti hazir';
end $$;
