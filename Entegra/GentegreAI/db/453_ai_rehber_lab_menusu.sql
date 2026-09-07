-- 453 - REHBER KATALOGU: Laboratuvar menusu uc dala ayrildi
--
-- Laboratuvar menusu Biyokimya / Mikrobiyoloji / Genetik alt basliklarina
-- ayrildi; ortak akis (istem, numune kabul, sonuclar, tetkik/panel katalogu,
-- dis lab) grubun kokunde kaldi - uc dal da ayni ekrandan yurur, dalin
-- altina saklanmamali.
--
-- ROTALAR DEGISMEDI: yalniz menu yolu/adi guncelleniyor. Rehber ekrani
-- menudeki yeriyle tarif eder; katalog eski yolu soylerse asistan artik
-- var olmayan bir menuye gonderir.

update public.ai_rehber_ekran set yol = 'Laboratuvar › İstemler', menu_ad = 'İstemler', menu_grup = 'Laboratuvar' where rota = '/lab-istem';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Numune Kabul', menu_ad = 'Numune Kabul', menu_grup = 'Laboratuvar' where rota = '/lab-numune';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Sonuçlar', menu_ad = 'Sonuçlar', menu_grup = 'Laboratuvar' where rota = '/lab-sonuc';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Tetkik Kataloğu', menu_ad = 'Tetkik Kataloğu', menu_grup = 'Laboratuvar' where rota = '/lab-tetkik';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Paneller', menu_ad = 'Paneller', menu_grup = 'Laboratuvar' where rota = '/lab-panel';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Dış Lab Gönderimleri', menu_ad = 'Dış Lab Gönderimleri', menu_grup = 'Laboratuvar' where rota = '/lab-dis-gonderim';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Dış Laboratuvarlar', menu_ad = 'Dış Laboratuvarlar', menu_grup = 'Laboratuvar' where rota = '/lab-dis-lab';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Serum İndeksi', menu_ad = 'Serum İndeksi', menu_grup = 'Biyokimya' where rota = '/lab-indeks-esik';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Kalite Kontrol', menu_ad = 'Kalite Kontrol', menu_grup = 'Biyokimya' where rota = '/lab-kk-olcum';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Kontrol Lotları', menu_ad = 'Kontrol Lotları', menu_grup = 'Biyokimya' where rota = '/lab-kk-lot';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Westgard Kuralları', menu_ad = 'Westgard Kuralları', menu_grup = 'Biyokimya' where rota = '/lab-kk-kural';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Dış Kalite', menu_ad = 'Dış Kalite', menu_grup = 'Biyokimya' where rota = '/lab-dkk';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Cihazlar', menu_ad = 'Cihazlar', menu_grup = 'Biyokimya' where rota = '/cihaz';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Cihaz Eşleme', menu_ad = 'Cihaz Eşleme', menu_grup = 'Biyokimya' where rota = '/lab-cihaz-esleme';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Cihaz Mesajları', menu_ad = 'Cihaz Mesajları', menu_grup = 'Biyokimya' where rota = '/cihaz-mesaj';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Biyokimya › Cihaz Olayları', menu_ad = 'Cihaz Olayları', menu_grup = 'Biyokimya' where rota = '/lab-cihaz-olay';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Mikrobiyoloji › Kültür Çalışma Listesi', menu_ad = 'Kültür Çalışma Listesi', menu_grup = 'Mikrobiyoloji' where rota = '/lab-kultur';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Mikrobiyoloji › Organizmalar', menu_ad = 'Organizmalar', menu_grup = 'Mikrobiyoloji' where rota = '/lab-organizma';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Mikrobiyoloji › Antibiyotikler', menu_ad = 'Antibiyotikler', menu_grup = 'Mikrobiyoloji' where rota = '/lab-antibiyotik';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Mikrobiyoloji › Besiyerleri', menu_ad = 'Besiyerleri', menu_grup = 'Mikrobiyoloji' where rota = '/lab-besiyeri';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Genetik › Vakalar', menu_ad = 'Vakalar', menu_grup = 'Genetik' where rota = '/lab-genetik-vaka';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Genetik › Varyantlar', menu_ad = 'Varyantlar', menu_grup = 'Genetik' where rota = '/lab-varyant';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Genetik › Dizileme Runları', menu_ad = 'Dizileme Runları', menu_grup = 'Genetik' where rota = '/lab-genetik-run';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Genetik › Genler', menu_ad = 'Genler', menu_grup = 'Genetik' where rota = '/lab-gen';
update public.ai_rehber_ekran set yol = 'Laboratuvar › Genetik › Panel Kataloğu', menu_ad = 'Panel Kataloğu', menu_grup = 'Genetik' where rota = '/lab-genetik-panel';

do $$
begin
    raise notice '453 tamam: laboratuvar ekranlarinin menu yolu guncellendi (%)',
        (select count(*) from public.ai_rehber_ekran where yol like 'Laboratuvar%');
end $$;
