// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { DonusumMenusu } from '../bilesenler/belge/DonusumMenusu';

// BELGE DÖNÜŞTÜR ▾ (03.11.2026): irsaliye kartında düğme hedef menüsünü açar; seçilen hedef pencereyi ön seçili açar.
describe('DonusumMenusu', () => {
  it('satış irsaliyesinde fatura / fiş / tahakkuk listeler, seçimi bildirir', () => {
    const onSec = vi.fn();
    render(<DonusumMenusu kaynakTur={14} onSec={onSec} />);
    expect(screen.queryByRole('menu')).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: /Belge Dönüştür/ }));
    const maddeler = screen.getAllByRole('menuitem').map(b => b.textContent?.replace(/^\S+\s/, ''));
    expect(maddeler).toEqual(['Satış Faturası', 'Satış Fişi', 'Satış Tahakkuku']);
    fireEvent.click(screen.getByRole('menuitem', { name: /Satış Fişi/ }));
    expect(onSec).toHaveBeenCalledWith(16);
    expect(screen.queryByRole('menu')).toBeNull();
  });
  it('alış irsaliyesinde alış hedefleri', () => {
    render(<DonusumMenusu kaynakTur={10} onSec={() => {}} />);
    fireEvent.click(screen.getByRole('button', { name: /Belge Dönüştür/ }));
    expect(screen.getAllByRole('menuitem').map(b => b.textContent)).toEqual(['🧾 Alış Faturası', '🧮 Alış Fişi', '📑 Alış Tahakkuku']);
  });
  it('kaydedilmemiş belgede menü açılmaz', () => {
    render(<DonusumMenusu kaynakTur={14} devre devreSebep="Önce irsaliyeyi kaydedin." onSec={() => {}} />);
    fireEvent.click(screen.getByRole('button', { name: /Belge Dönüştür/ }));
    expect(screen.queryByRole('menu')).toBeNull();
  });
});
