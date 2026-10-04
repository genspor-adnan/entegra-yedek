import { createContext, useContext } from 'react';
import type { TaleplerimOzeti } from './useTaleplerimOzeti';

/** Kabukta bir kez okunan talep / bildirim / duyuru özeti (useTaleplerimOzeti). */
export const TaleplerimBaglami = createContext<TaleplerimOzeti | null>(null);
export const useTaleplerim = () => useContext(TaleplerimBaglami);
