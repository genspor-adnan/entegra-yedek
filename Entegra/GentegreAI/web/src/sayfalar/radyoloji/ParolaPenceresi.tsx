import { useEffect, useRef, useState } from 'react';
import { Modal } from '../../bilesenler/Modal';
import { c } from '../../dil/ceviri';

/**
 * RADYOLOG ŞİFRESİ (kullanıcı 17.11.2026: "kullanıcı radyolog değilse radyolog seçimi sorar, sonra onayla basıldıysa
 * şifre"; onay iptalinde de onaylayan radyoloğun şifresi). Girilen şifre yalnız o istekte sunucuya gider; sunucu
 * girişteki kurallarla doğrular (yanlış deneme o hesabın hatalı giriş sayacını artırır).
 */
export function ParolaPenceresi({ kisi, amac, onTamam, onKapat }: {
  /** Şifresi istenen radyoloğun adı. */
  kisi: string;
  /** "raporu onaylamak" / "onayı iptal etmek" gibi - cümlede kullanılır. */
  amac: string;
  onTamam(parola: string): void;
  onKapat(): void;
}) {
  const [parola, setParola] = useState('');
  const kutu = useRef<HTMLInputElement>(null);
  useEffect(() => { kutu.current?.focus() }, []);
  const tamam = () => { if (parola) onTamam(parola) };
  return (
    <Modal baslik={`🔑 ${c('Radyolog Şifresi')}`} dar enUst onKapat={onKapat}
           alt={<>
             <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
             <button type="button" className="d bir" disabled={!parola} onClick={tamam} data-testid="parola-tamam">✔ {c('Onayla')}</button>
           </>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, padding: '4px 2px' }}>
        <div style={{ fontSize: 12 }}><b>{kisi}</b> {c('adına')} {amac} {c('için şifresini girin.')}</div>
        <input ref={kutu} type="password" autoComplete="off" value={parola} data-testid="parola-girdi"
               aria-label={c('Şifre')} onChange={e => setParola(e.target.value)}
               onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); tamam() } }} />
        <div className="sonuk kucuk">{c('Yanlış şifre o hesabın hatalı giriş sayacını artırır; birkaç yanlış denemede hesap kilitlenir.')}</div>
      </div>
    </Modal>
  );
}
