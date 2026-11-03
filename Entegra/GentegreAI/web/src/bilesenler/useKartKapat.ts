import { useCallback, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { EkranSekmesiBaglami } from './sekmeBaglami';

/**
 * KARTI KAPAT - KAYDET / SİL SONRASI DA (kullanıcı 03.11.2026 genel kural: "kaydet ve sil butonlarından sonra sekme
 * kapansın"): kart kendi ekran sekmesindeyse sekme kapanır (komşu sekmeye dönülür); sekmesiz ya da bir yerden
 * `geri` adresiyle gelinmişse o adrese, yoksa listeye gidilir. Kart sekmesi deseni (ListeKarti yeniSekmede) ile aynı kural.
 */
export function useKartKapat(listeYolu: string, geri?: string | null) {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  return useCallback(() => {
    if (ekranSekmesi && !geri) ekranSekmesi.kapat();
    else git(geri ?? listeYolu);
  }, [ekranSekmesi, git, geri, listeYolu]);
}
