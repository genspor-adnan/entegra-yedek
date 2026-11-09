// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { GenSagTus } from '../bilesenler/Aksiyonlar';
import { GridMenu } from '../bilesenler/grid/GridMenu';
import type { AksiyonYaniti } from '../api/sozlesme';

// KAYDIRMA SAĞ TUŞ MENÜSÜNÜ KAPATMAZ (kullanıcı 09.11.2026): liste kaydırılınca (çubuktan ya da tekerlekle)
//   menü açık kalır; menü dışına tıklama ve Esc kapatır.
const aksiyon: AksiyonYaniti = {
  kod: 'sil', ad: 'Sil', grup: 'kayit', hedef: 'araccubugu,sagtus', kayitGerekir: true, aktif: true,
};

describe('GenSagTus kaydırma', () => {
  it('scroll menüyü kapatmaz, dışarı tıklama ve Esc kapatır', () => {
    const onKapat = vi.fn();
    render(<GenSagTus aksiyonlar={[aksiyon]} calistir={vi.fn()} konum={{ x: 10, y: 10 }} onKapat={onKapat} />);
    expect(screen.getByText('Sil')).toBeTruthy();

    fireEvent.scroll(document.body);
    fireEvent.scroll(window);
    expect(onKapat).not.toHaveBeenCalled();

    fireEvent.click(screen.getByText('Sil').closest('.sag-tus')!);      // menünün kendisi: kapanmaz
    expect(onKapat).not.toHaveBeenCalled();

    fireEvent.click(document.body);
    expect(onKapat).toHaveBeenCalledTimes(1);

    fireEvent.keyDown(window, { key: 'Escape' });
    expect(onKapat).toHaveBeenCalledTimes(2);
  });
});

describe('GridMenu kaydırma', () => {
  it('scroll menüyü kapatmaz, dışarı tıklama kapatır', () => {
    const onKapat = vi.fn();
    render(<GridMenu konum={{ x: 10, y: 10 }} onKapat={onKapat} ogeler={[{ ad: 'CSV', ik: '⬇', fn: vi.fn() }]} />);
    fireEvent.scroll(document.body);
    expect(onKapat).not.toHaveBeenCalled();
    fireEvent.click(document.body);
    expect(onKapat).toHaveBeenCalledTimes(1);
  });
});
