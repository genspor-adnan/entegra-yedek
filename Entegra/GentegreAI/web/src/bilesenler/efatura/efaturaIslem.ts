import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EFaturaHazirlaIstegi, EFaturaKodu } from '../../api/uclar/efatura';
import { dosyaIndir } from '../indir';
import { listeSor, mesaj, metinSor, onay, secimSor } from '../mesaj';

/**
 * e-FATURA MENÜ ADIMLARI - Delphi UFaturalar e-Fatura menüsünün (MenuOlusturClick,
 * MenuOnizleClick, MenuGonderClick, MenuPDFKaydet...) web karşılığı. Menü
 * bileşeni (Belgeye Dönüşüm, fatura kartı) ve fatura listesinin kombosu AYNI
 * fonksiyonu çağırır.
 *
 * Kurallar sunucuda (EFaturaKodlari.Engel); burası yalnız soruları sorar ve
 * çıktıyı gösterir.
 */
export type EFaturaBaglam = {
  /** Durum değiştiren adımdan sonra ekranı tazele. */
  tazele?(): void;
};

/** Mesaj geçmişi penceresi App kökünde (EFaturaMesajKatmani) - olayla açılır. */
export const MESAJ_OLAYI = 'efatura-mesajlar';
export function mesajlariAc(belgeId: number, baslik: string) {
  window.dispatchEvent(new CustomEvent(MESAJ_OLAYI, { detail: { belgeId, baslik } }));
}

/**
 * HAZIRLA - sunucunun sorularını Delphi'deki sırayla sorar (test ortamı türü,
 * çok posta kutusu, e-Arşiv e-postası, serinin ilk numarası). İptalde false.
 */
export async function hazirla(belgeId: number, ikinciSeri = false): Promise<boolean> {
  const g: EFaturaHazirlaIstegi = { ikinciSeri };
  for (let tur = 0; tur < 6; tur++) {
    const y = await api.efaturaHazirla(belgeId, g);
    if (!y.soru) { mesaj(y.mesaj); return true }
    if (y.soru === 'tur') {
      const c = await secimSor(y.mesaj, [
        { kod: 'efatura', ad: 'e-Fatura', sinif: 'bir' },
        { kod: 'earsiv', ad: 'e-Arşiv' },
        { kod: 'iptal', ad: 'Vazgeç' },
      ], 'iptal');
      if (c === 'iptal') return false;
      g.tur = c as 'efatura' | 'earsiv';
    } else if (y.soru === 'eposta') {
      const e = await metinSor(y.mesaj, y.varsayilan ?? '', 'Alıcı e-postası');
      if (e === null) return false;
      g.eposta = e.trim();
    } else if (y.soru === 'alias') {
      const s = y.secenekler ?? [];
      const a = await listeSor(y.mesaj, s.map(x => ({ kod: x, ad: x })), s[0] ?? '', 'Posta kutusu');
      if (a === null) return false;
      g.alias = a;
    } else if (y.soru === 'numara') {
      const n = await metinSor(y.mesaj, y.varsayilan ?? '1', 'Başlangıç no');
      if (n === null) return false;
      const sayi = Number(n.trim());
      if (!Number.isInteger(sayi) || sayi < 1) { mesaj('Geçerli bir sıra numarası girin.'); return false }
      g.baslangicNo = sayi;
    }
  }
  return false;
}

/** Yazdırma penceresi: PDF Kaydet tarayıcının "PDF olarak kaydet"iyle (başlık = dosya adı). */
function pencereAc(html: string, baslik: string, yazdir: boolean) {
  const p = window.open('', '_blank');
  if (!p) { mesaj('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.'); return }
  p.document.write(html);
  p.document.close();
  try { p.document.title = baslik } catch { /* farklı köken */ }
  if (yazdir) p.setTimeout(() => p.print(), 500);
}

/** Menü maddesini çalıştırır. Kod bilinmiyorsa false (çağıran kendi işine devam etsin). */
export async function efaturaCalistir(kod: string, belgeId: number, b: EFaturaBaglam = {}): Promise<boolean> {
  if (!kod.startsWith('ebelge.')) return false;
  try {
    const d = await api.efaturaDurum(belgeId);
    const engel = d.engeller[kod as EFaturaKodu];
    if (engel) { mesaj(engel); return true }
    const no = d.belgeNo && d.belgeNo !== '0' ? d.belgeNo : `#${belgeId}`;

    switch (kod as EFaturaKodu) {
      case 'ebelge.hazirla':
        if (await hazirla(belgeId)) b.tazele?.();
        return true;

      // ÖNİZLE: hazırlanmamışsa önce hazırlanır (Delphi MenuOnizle). Hazırlama numara
      //   tükettiği için sorulur.
      case 'ebelge.onizle': {
        if (d.efaturaDurum === 0) {
          if (!await onay('e-Fatura henüz hazırlanmamış. Önizleme için önce hazırlansın mı?\n'
                        + 'Belgeye seri ve e-Fatura numarası verilir.')) return true;
          if (!await hazirla(belgeId)) return true;
          b.tazele?.();
        }
        const h = await api.efaturaHtml(belgeId, false);
        pencereAc(h.html, h.dosyaAdi, false);
        return true;
      }

      case 'ebelge.gonder': {
        if (!await onay(`${d.turAdi} ${no} GİB'e GÖNDERİLECEK${d.testMi ? ' (TEST ortamı)' : ''}.\n\n`
                      + 'Gönderilen belge geri alınamaz; düzeltme yalnız iade faturasıyla yapılır. Onaylıyor musunuz?',
                        !d.testMi)) return true;
        try { mesaj((await api.efaturaGonder(belgeId)).mesaj) }
        finally { b.tazele?.() }               // hata da durumu değiştirir (efatura_sonuc 3)
        return true;
      }

      case 'ebelge.pdf': {
        const h = await api.efaturaHtml(belgeId, true);
        pencereAc(h.html, h.dosyaAdi, true);
        return true;
      }
      case 'ebelge.html': {
        const h = await api.efaturaHtml(belgeId, true);
        dosyaIndir(h.html, `${h.dosyaAdi}.html`, 'text/html;charset=utf-8');
        return true;
      }
      case 'ebelge.xml': {
        const x = await api.efaturaXml(belgeId);
        dosyaIndir(x.xml, `${x.dosyaAdi}.xml`, 'application/xml;charset=utf-8');
        return true;
      }

      // SERİ DEĞİŞTİR (Delphi MenuSeriDegistir): hazırlanmamışta İKİNCİ seriyle hazırlar,
      //   hazırda seri seçtirip yeni numara verir (ETTN değişmez).
      case 'ebelge.seri': {
        if (d.efaturaDurum === 0) {
          if (!await onay('e-Fatura ikinci uygun seriyle hazırlanacak. Devam edilsin mi?')) return true;
          if (await hazirla(belgeId, true)) b.tazele?.();
          return true;
        }
        const s = await api.efaturaSeriler(belgeId);
        if (s.seriler.length === 0) { mesaj(`Başka uygun seri yok (şimdiki: ${s.simdiki}).`); return true }
        const yeni = await listeSor(`${no} için yeni seri (şimdiki ${s.simdiki}):`,
                                    s.seriler.map(x => ({ kod: x, ad: x })), s.seriler[0], 'Seri');
        if (yeni === null) return true;
        mesaj((await api.efaturaSeriDegistir(belgeId, yeni)).mesaj);
        b.tazele?.();
        return true;
      }

      case 'ebelge.sifirla': {
        if (!await onay(`${d.turAdi} ${no} hazırlığı geri alınacak; numara boşa düşer ve belge yeniden `
                      + 'hazırlanabilir. Onaylıyor musunuz?')) return true;
        mesaj((await api.efaturaSifirla(belgeId)).mesaj);
        b.tazele?.();
        return true;
      }

      case 'ebelge.mesajlar':
        mesajlariAc(belgeId, no);
        return true;
    }
  } catch (h) {
    mesaj(hataMetni(h));
    return true;
  }
  return false;
}
