'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';

export interface FavoriteDesign {
  id: string;
  cloudinary_url: string;
  cloudinary_public_id?: string;
  category: string;
  category_id?: string;
  tag?: string | null;
  shop_name: string;
  shop_slug: string;
  photos?: any[];
  is_grouped?: boolean;
  is_trending?: boolean;
  saved_at: string;
}

interface FavoritesContextType {
  favorites: FavoriteDesign[];
  isFavorite: (id: string) => boolean;
  toggleFavorite: (design: Omit<FavoriteDesign, 'saved_at'>) => void;
  removeFavorite: (id: string) => void;
  count: number;
}

const FavoritesContext = createContext<FavoritesContextType | null>(null);

const STORAGE_KEY = 'tailor_favorites';

export function FavoritesProvider({ children }: { children: React.ReactNode }) {
  const [favorites, setFavorites] = useState<FavoriteDesign[]>([]);
  const [initialized, setInitialized] = useState(false);

  // Load from localStorage on mount
  useEffect(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        if (Array.isArray(parsed)) {
          setFavorites(parsed);
        } else if (parsed && Array.isArray(parsed.tailor_favorites)) {
          setFavorites(parsed.tailor_favorites);
        }
      }
    } catch (e) {
      console.warn('Failed to parse favorites from localStorage:', e);
    } finally {
      setInitialized(true);
    }
  }, []);

  // Save to localStorage when changed
  useEffect(() => {
    if (!initialized) return;
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(favorites));
    } catch (e) {
      console.warn('Failed to write favorites to localStorage:', e);
    }
  }, [favorites, initialized]);

  const isFavorite = (id: string) => {
    return favorites.some((f) => f.id === id);
  };

  const toggleFavorite = (design: Omit<FavoriteDesign, 'saved_at'>) => {
    setFavorites((prev) => {
      const exists = prev.some((f) => f.id === design.id);
      if (exists) {
        return prev.filter((f) => f.id !== design.id);
      } else {
        const newFav: FavoriteDesign = {
          ...design,
          saved_at: new Date().toISOString(),
        };
        return [newFav, ...prev];
      }
    });
  };

  const removeFavorite = (id: string) => {
    setFavorites((prev) => prev.filter((f) => f.id !== id));
  };

  return (
    <FavoritesContext.Provider
      value={{
        favorites,
        isFavorite,
        toggleFavorite,
        removeFavorite,
        count: favorites.length,
      }}
    >
      {children}
    </FavoritesContext.Provider>
  );
}

export function useFavorites() {
  const context = useContext(FavoritesContext);
  if (!context) {
    throw new Error('useFavorites must be used within a FavoritesProvider');
  }
  return context;
}
