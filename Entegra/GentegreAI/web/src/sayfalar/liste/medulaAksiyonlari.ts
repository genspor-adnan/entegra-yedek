import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { MEDULA_HATA_ONERI } from '../../api/uclar/medula';

/**
 * MEDULA LİSTE AKSİYONLARI (707). Kural sunucuda; ekran sonuç kodu + mesajı
 * gösterir, bilinen hata kodlarında öneri ekler.
 */
export interface MedulaAksiyonBaglam { tazele(): void; git(yol: string): void }

export function medulaSonucMetni(s: { kabul: boolean; bekliyor: boolean; kod: string; mesaj: string }): string {
  if (s.kabul) return `✔ ${s.mesaj}`;
  if (s.bekliyor) return `⏳ ${s.mesaj} — kuyrukta bekliyor, kapı açılınca otomatik gönderilir.`;
  const oneri = MEDULA_HATA_ONERI[s.kod];
  return `✖ ${s.kod} · ${s.mesaj}${oneri ? ` → ${oneri}` : ''}`;
}

export async function medulaAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                     b: MedulaAksiyonBaglam): Promise<boolean> {
  if (!kod.startsWith('medula.')) return false;
  const id = Number(satir?.id ?? 0);
  const belgeId = Number(satir?.belgeId ?? (satir?.takipNo !== undefined ? satir?.id : 0) ?? 0);

  if (kod === 'medula.kabul-ac') { if (!id) { mesaj('Önce bir başvuru seçin.'); return true } b.git(`/medula-kabul/${id}`); return true }
  if (kod === 'medula.hizmet-ac') { const bid = belgeId || id; if (!bid) { mesaj('Önce bir satır seçin.'); return true } b.git(`/medula-hizmet/${bid}`); return true }
  if (kod === 'medula.donem-ac') { b.git('/medula-fatura-donem'); return true }
  if (kod === 'medula.kuyruk-ac') { b.git('/medula-kuyruk-ayar'); return true }

  if (kod === 'medula.cikis') {
    if (!id) { mesaj('Önce bir takip seçin.'); return true }
    if (!await onay('Hasta çıkışı kaydedilsin mi? Takip kapanır; fatura bundan sonra kesilir.')) return true;
    await guvenli(async () => { mesaj(medulaSonucMetni(await api.medulaHastaCikis(id))); b.tazele(); });
    return true;
  }
  if (kod === 'medula.fatura-kaydet') {
    if (!id) { mesaj('Önce bir takip seçin.'); return true }
    await guvenli(async () => { mesaj(medulaSonucMetni(await api.medulaFaturaKaydet(id))); b.tazele(); });
    return true;
  }
  if (kod === 'medula.islem-iptal') {
    if (!id) { mesaj('Önce bir kayıt seçin.'); return true }
    await guvenli(async () => { const y = await api.medulaIslemIptal(id); mesaj(y.kabul ? `✔ ${y.mesaj}` : `✖ ${y.kod} · ${y.mesaj}`); b.tazele(); });
    return true;
  }
  if (kod === 'medula.islem-yerel') {
    if (!id) { mesaj('Önce bir kayıt seçin.'); return true }
    await guvenli(async () => { await api.medulaIslemYerel(id); mesaj('Satır hastaya ücretli bırakıldı; Medula\'ya gitmez.'); b.tazele(); });
    return true;
  }
  if (kod === 'medula.fatura-iptal') {
    if (!id) { mesaj('Önce bir fatura seçin.'); return true }
    await guvenli(async () => { const y = await api.medulaFaturaIptal(id); mesaj(y.kabul ? `✔ ${y.mesaj}` : `✖ ${y.kod} · ${y.mesaj}`); b.tazele(); });
    return true;
  }
  if (kod === 'medula.kesinti-ekle') {
    if (!id) { mesaj('Önce bir fatura seçin.'); return true }
    const tutar = await metinSor('Kesinti tutarı', '0'); if (tutar === null) return true;
    const kkod = await metinSor('Kesinti kodu (K-06 vb.)', ''); if (kkod === null) return true;
    const acik = await metinSor('Açıklama', ''); if (acik === null) return true;
    await guvenli(async () => {
      await api.medulaKesintiEkle({ medulaFaturaId: id, kesintiKodu: kkod, aciklama: acik, tutar: Number(String(tutar).replace(',', '.')) || 0 });
      mesaj('Kesinti yazıldı; fatura "incelendi", dönem "incelemede".'); b.tazele();
    });
    return true;
  }
  if (kod === 'medula.itiraz') {
    if (!id) { mesaj('Önce bir kesinti seçin.'); return true }
    const metin = await metinSor('İtiraz gerekçesi', ''); if (metin === null) return true;
    await guvenli(async () => { await api.medulaItiraz(id, metin); mesaj('İtiraz kaydedildi.'); b.tazele(); });
    return true;
  }
  if (kod === 'medula.itiraz-sonuc') {
    if (!id) { mesaj('Önce bir kesinti seçin.'); return true }
    const kabul = await onay('İtiraz KABUL mü edildi? (Hayır = red)');
    await guvenli(async () => { const y = await api.medulaItirazSonuc(id, kabul); mesaj(kabul ? `Kabul · iade ${y.iade.toLocaleString('tr-TR')}` : 'Red kaydedildi.'); b.tazele(); });
    return true;
  }
  if (kod === 'medula.rapor-gonder') {
    if (!id) { mesaj('Önce bir rapor seçin.'); return true }
    await guvenli(async () => { mesaj(medulaSonucMetni(await api.medulaRaporGonder(id))); b.tazele(); });
    return true;
  }
  if (kod === 'medula.recete-imzala') {
    if (!id) { mesaj('Önce bir reçete seçin.'); return true }
    await guvenli(async () => { const y = await api.medulaReceteImzala(id); mesaj(`Reçete imzalandı (${y.imzaHash.slice(0, 8)}…).`); b.tazele(); });
    return true;
  }
  if (kod === 'medula.recete-gonder') {
    if (!id) { mesaj('Önce bir reçete seçin.'); return true }
    await guvenli(async () => { mesaj(medulaSonucMetni(await api.medulaReceteGonder(id))); b.tazele(); });
    return true;
  }
  if (kod === 'medula.recete-sil') {
    if (!id) { mesaj('Önce bir reçete seçin.'); return true }
    await guvenli(async () => { mesaj(medulaSonucMetni(await api.medulaReceteSil(id))); b.tazele(); });
    return true;
  }
  if (kod === 'medula.kuyruk-gonder') {
    await guvenli(async () => { const y = await api.medulaKuyrukGonder(false); mesaj(y.aciklama); b.tazele(); });
    return true;
  }
  if (kod === 'medula.kuyruk-tekrar') {
    if (!id) { mesaj('Önce bir satır seçin.'); return true }
    await guvenli(async () => { mesaj(medulaSonucMetni(await api.medulaKuyrukTekrar(id))); b.tazele(); });
    return true;
  }
  if (kod === 'medula.kuyruk-iptal') {
    if (!id) { mesaj('Önce bir satır seçin.'); return true }
    await guvenli(async () => { await api.medulaKuyrukIptal(id); mesaj('Satır iptal edildi.'); b.tazele(); });
    return true;
  }
  return false;
}
