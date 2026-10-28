import { htmlTemizle } from '../htmlGuvenlik';
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
 * ÇOKLU İŞLEMDE ORTAK CEVAPLAR: test ortamı türü ve e-Arşiv e-posta politikası
 * bir kez sorulur, her belgede yeniden sorulmaz.
 */
export type HazirlaCevaplari = { tur?: 'efatura' | 'earsiv'; epostaCaridan?: boolean };

/**
 * HAZIRLA - sunucunun sorularını Delphi'deki sırayla sorar (test ortamı türü,
 * çok posta kutusu, e-Arşiv e-postası, serinin ilk numarası). Sonuç mesajını
 * döner; vazgeçilirse null.
 */
export async function hazirla(belgeId: number, ikinciSeri = false, ortak?: HazirlaCevaplari): Promise<string | null> {
  const g: EFaturaHazirlaIstegi = { ikinciSeri, tur: ortak?.tur };
  for (let tur = 0; tur < 6; tur++) {
    const y = await api.efaturaHazirla(belgeId, g);
    if (!y.soru) return y.mesaj;
    if (y.soru === 'tur') {
      const c = await secimSor(y.mesaj, [
        { kod: 'efatura', ad: 'e-Fatura', sinif: 'bir' },
        { kod: 'earsiv', ad: 'e-Arşiv' },
        { kod: 'iptal', ad: 'Vazgeç' },
      ], 'iptal');
      if (c === 'iptal') return null;
      g.tur = c as 'efatura' | 'earsiv';
      if (ortak) ortak.tur = g.tur;
    } else if (y.soru === 'eposta') {
      if (ortak?.epostaCaridan) { g.eposta = y.varsayilan ?? ''; continue }
      const e = await metinSor(y.mesaj, y.varsayilan ?? '', 'Alıcı e-postası');
      if (e === null) return null;
      g.eposta = e.trim();
    } else if (y.soru === 'alias') {
      const s = y.secenekler ?? [];
      const a = await listeSor(y.mesaj, s.map(x => ({ kod: x, ad: x })), s[0] ?? '', 'Posta kutusu');
      if (a === null) return null;
      g.alias = a;
    } else if (y.soru === 'numara') {
      const n = await metinSor(y.mesaj, y.varsayilan ?? '1', 'Başlangıç no');
      if (n === null) return null;
      const sayi = Number(n.trim());
      if (!Number.isInteger(sayi) || sayi < 1) { mesaj('Geçerli bir sıra numarası girin.'); return null }
      g.baslangicNo = sayi;
    }
  }
  return null;
}

/** Yazdırma penceresi: PDF Kaydet tarayıcının "PDF olarak kaydet"iyle (başlık = dosya adı). */
function pencereAc(html: string, baslik: string, yazdir: boolean) {
  const p = window.open('', '_blank');
  if (!p) { mesaj('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.'); return }
  // TEMİZ (kod inceleme raporu 28.10.2026 B03): XSLT çıktısı - gelen faturanın şablonu karşı firmadan gelir;
  //   script / olay öznitelikleri aynı kökende çalışmasın.
  p.document.write(htmlTemizle(html));
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
        { const m = await hazirla(belgeId); if (m) { mesaj(m); b.tazele?.() } }
        return true;

      // ÖNİZLE: hazırlanmamışsa önce hazırlanır (Delphi MenuOnizle). Hazırlama numara
      //   tükettiği için sorulur.
      case 'ebelge.onizle': {
        if (d.efaturaDurum === 0) {
          if (!await onay(`${d.turAdi} henüz hazırlanmamış. Önizleme için önce hazırlansın mı?\n`
                        + `Belgeye seri ve ${d.turAdi} numarası verilir.`)) return true;
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
          if (!await onay(`${d.turAdi} ikinci uygun seriyle hazırlanacak. Devam edilsin mi?`)) return true;
          { const m = await hazirla(belgeId, true); if (m) { mesaj(m); b.tazele?.() } }
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

/** Çoklu seçimde çalışan maddeler; ötekiler (önizle / PDF / seri / mesajlar) tek belge ister. */
export const COKLU_KODLAR: EFaturaKodu[] = ['ebelge.hazirla', 'ebelge.gonder', 'ebelge.sifirla', 'ebelge.html', 'ebelge.xml'];

/**
 * ÇOKLU İŞLEM (kullanıcı 11.10.2026: "birden fazla seçili fatura üzerinde işlem
 * yapılabilir"): uygun olmayan belge ATLANIR (sebebiyle), ortak sorular bir kez
 * sorulur, sonuç tek mesajda. Gönderim numara sırasıyla (sıra kuralı).
 */
export async function efaturaCokluCalistir(kod: string, belgeIdler: number[], b: EFaturaBaglam = {}): Promise<void> {
  if (belgeIdler.length === 1) { await efaturaCalistir(kod, belgeIdler[0], b); return }
  const k = kod as EFaturaKodu;
  if (!COKLU_KODLAR.includes(k)) { mesaj('Bu işlem için tek bir belge seçin.'); return }
  try {
    const durumlar = await Promise.all(belgeIdler.map(id => api.efaturaDurum(id)));
    const uygun = durumlar.filter(d => !d.engeller[k]);
    const atlanan = durumlar.filter(d => d.engeller[k]).map(d => `– ${no(d)}: ${d.engeller[k]}`);
    if (uygun.length === 0) { mesaj('Seçilen belgelerin hiçbiri için uygun değil:\n' + atlanan.join('\n')); return }
    const sonuc: string[] = [];
    const sirali = [...uygun].sort((x, y) => no(x).localeCompare(no(y)));

    switch (k) {
      case 'ebelge.hazirla': {
        if (!await onay(`${uygun.length} belge e-Belge olarak hazırlanacak; her birine seri ve numara verilir.`
                      + (atlanan.length ? `\n${atlanan.length} belge atlanacak.` : ''))) return;
        const ortak: HazirlaCevaplari = {};
        const e = await secimSor('e-Arşiv olarak hazırlanacak belgelerde alıcı e-postası:', [
          { kod: 'cari', ad: 'Cari kartındaki adres', sinif: 'bir' },
          { kod: 'sor', ad: 'Her belge için sor' },
          { kod: 'iptal', ad: 'Vazgeç' },
        ], 'iptal');
        if (e === 'iptal') return;
        ortak.epostaCaridan = e === 'cari';
        for (const d of uygun) {
          try { const m = await hazirla(d.belgeId, false, ortak); sonuc.push(m ? `✓ ${m}` : `– #${d.belgeId}: vazgeçildi`) }
          catch (h) { sonuc.push(`✗ #${d.belgeId}: ${hataMetni(h)}`) }
        }
        break;
      }
      case 'ebelge.gonder': {
        const test = uygun.some(d => d.testMi);
        if (!await onay(`${uygun.length} belge GİB'e GÖNDERİLECEK${test ? ' (TEST ortamı)' : ''}.`
                      + (atlanan.length ? ` ${atlanan.length} belge atlanacak.` : '')
                      + '\n\nGönderilen belge geri alınamaz; düzeltme yalnız iade faturasıyla yapılır. Onaylıyor musunuz?', !test)) return;
        for (const d of sirali) {
          try { sonuc.push(`✓ ${(await api.efaturaGonder(d.belgeId)).mesaj}`) }
          catch (h) { sonuc.push(`✗ ${no(d)}: ${hataMetni(h)}`) }
        }
        break;
      }
      case 'ebelge.sifirla': {
        if (!await onay(`${uygun.length} belgenin hazırlığı geri alınacak; numaralar boşa düşer. Onaylıyor musunuz?`)) return;
        for (const d of sirali) {
          try { sonuc.push(`✓ ${(await api.efaturaSifirla(d.belgeId)).mesaj}`) }
          catch (h) { sonuc.push(`✗ ${no(d)}: ${hataMetni(h)}`) }
        }
        break;
      }
      case 'ebelge.html':
      case 'ebelge.xml':
        for (const d of sirali) {
          try {
            if (k === 'ebelge.html') { const h = await api.efaturaHtml(d.belgeId, true); dosyaIndir(h.html, `${h.dosyaAdi}.html`, 'text/html;charset=utf-8') }
            else { const x = await api.efaturaXml(d.belgeId); dosyaIndir(x.xml, `${x.dosyaAdi}.xml`, 'application/xml;charset=utf-8') }
            sonuc.push(`✓ ${no(d)}`);
          } catch (h) { sonuc.push(`✗ ${no(d)}: ${hataMetni(h)}`) }
        }
        break;
    }
    mesaj([...sonuc, ...(atlanan.length ? ['', 'Atlanan:', ...atlanan] : [])].join('\n'));
    if (k !== 'ebelge.html' && k !== 'ebelge.xml') b.tazele?.();
  } catch (h) {
    mesaj(hataMetni(h));
  }
}

const no = (d: { belgeNo: string; belgeId: number }) => (d.belgeNo && d.belgeNo !== '0' ? d.belgeNo : `#${d.belgeId}`);
