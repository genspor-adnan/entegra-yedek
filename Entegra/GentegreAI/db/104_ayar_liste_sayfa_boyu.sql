-- ============================================================================
--  Gentegre AI — Genel Ayarlar: liste sayfa boyu
--  104_ayar_liste_sayfa_boyu.sql
--
--  Listelerde bir sayfada kac kayit gosterilecegi arayuzde SABIT 50 idi.
--  Buyuk ekranda az, yavas baglantida cok geliyordu; ayara alindi.
--
--    liste.sayfa_boyu = 10..500 (sunucu ust siniri 500 - ListeIstegi.EnBuyukBoyut)
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('liste.sayfa_boyu', '50', 'sayi', 'firma',
        'Listelerde bir sayfada gösterilecek kayıt sayısı')
on conflict (anahtar) do nothing;

insert into public.help (anahtar, dil, baslik, metin) values
('ayar.liste.sayfa_boyu', 0, 'Sayfa boyu',
 'Liste ekranlarinda bir sayfada kaç kayıt gösterileceğini belirler.'
 || E'\n\n'
 || 'Küçük değer sayfaları hızlı açar ama daha çok sayfa çevirtir; büyük değer '
 || 'tek ekranda çok kayıt gösterir, yavaş bağlantıda listeyi bekletir.'
 || E'\n\n'
 || 'En az 10, en çok 500 olabilir (sunucu tek istekte 500 kayıttan fazlasını '
 || 'göndermez). Değişiklik açılan listelerde hemen geçerli olur.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;

do $$
declare v_d text;
begin
    select deger into v_d from public.referans where anahtar = 'liste.sayfa_boyu';
    raise notice '104 tamam: sayfa boyu = %', v_d;
end $$;
