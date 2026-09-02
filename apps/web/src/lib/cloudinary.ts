import { cloudinaryPresets, cloudinaryUrl } from '@tailor-catalog/shared';

export interface PhotoData {
  id?: string;
  cloudinary_public_id?: string | null;
  cloudinary_url?: string | null;
  order_index?: number;
}

export function getThumbnailUrl(photo?: PhotoData | null): string {
  if (!photo) return '';

  if (photo.cloudinary_public_id) {
    const cloudName = process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME;
    if (cloudName) {
      return cloudinaryPresets.thumbnail(photo.cloudinary_public_id);
    }
  }

  if (photo.cloudinary_url) {
    // If it's a standard cloudinary URL, inject thumbnail transforms
    if (photo.cloudinary_url.includes('/image/upload/')) {
      return photo.cloudinary_url.replace(
        '/image/upload/',
        '/image/upload/w_400,h_400,c_limit,f_auto,q_auto/'
      );
    }
    return photo.cloudinary_url;
  }

  return '';
}

export function getFullPhotoUrl(photo?: PhotoData | null): string {
  if (!photo) return '';

  if (photo.cloudinary_public_id) {
    const cloudName = process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME;
    if (cloudName) {
      return cloudinaryPresets.catalog(photo.cloudinary_public_id);
    }
  }

  if (photo.cloudinary_url) {
    if (photo.cloudinary_url.includes('/image/upload/')) {
      return photo.cloudinary_url.replace(
        '/image/upload/',
        '/image/upload/w_800,f_auto,q_auto/'
      );
    }
    return photo.cloudinary_url;
  }

  return '';
}

/**
 * 360 Full Size Photo URL generator
 * Uses Cloudinary full size preset: f_auto,q_auto,w_1200
 */
export function getHighRes360PhotoUrl(photo?: PhotoData | null): string {
  if (!photo) return '';

  if (photo.cloudinary_public_id) {
    const cloudName = process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME;
    if (cloudName) {
      return cloudinaryUrl(photo.cloudinary_public_id, {
        width: 1200,
        quality: 'auto',
        format: 'auto',
      });
    }
  }

  if (photo.cloudinary_url) {
    if (photo.cloudinary_url.includes('/image/upload/')) {
      return photo.cloudinary_url.replace(
        '/image/upload/',
        '/image/upload/w_1200,f_auto,q_auto/'
      );
    }
    return photo.cloudinary_url;
  }

  return '';
}
