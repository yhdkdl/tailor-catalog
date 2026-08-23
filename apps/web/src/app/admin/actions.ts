'use server';

import { revalidatePath } from 'next/cache';
import { createAdminClient } from '@/lib/supabase/admin';
import { TailorStatus } from '@tailor-catalog/shared';

/**
 * Update tailor status (approve, reject, pending)
 */
export async function updateTailorStatus(tailorId: string, status: TailorStatus) {
  try {
    const supabase = createAdminClient();

    const { data, error } = await supabase
      .from('tailors')
      .update({ status })
      .eq('id', tailorId)
      .select()
      .single();

    if (error) {
      console.error('Error updating tailor status:', error);
      return { success: false, error: error.message };
    }

    revalidatePath('/admin');
    revalidatePath('/admin/tailors');
    return { success: true, tailor: data };
  } catch (err: any) {
    console.error('Exception in updateTailorStatus:', err);
    return { success: false, error: err.message || 'Internal server error' };
  }
}

/**
 * Delete a design and its storage photos
 */
export async function deleteDesign(designId: string) {
  try {
    const supabase = createAdminClient();

    // 1. Fetch photo storage paths first
    const { data: photos, error: photoError } = await supabase
      .from('design_photos')
      .select('storage_path')
      .eq('design_id', designId);

    if (photoError) {
      console.error('Error fetching photos for deletion:', photoError);
    }

    // 2. Delete images from Supabase storage bucket if any exist
    if (photos && photos.length > 0) {
      const pathsToDelete = photos.map((p) => p.storage_path);
      const { error: storageError } = await supabase.storage
        .from('design-photos')
        .remove(pathsToDelete);

      if (storageError) {
        console.warn('Storage deletion warning:', storageError);
      }
    }

    // 3. Delete design row (cascade deletes design_photos records)
    const { error: deleteError } = await supabase
      .from('designs')
      .delete()
      .eq('id', designId);

    if (deleteError) {
      console.error('Error deleting design record:', deleteError);
      return { success: false, error: deleteError.message };
    }

    revalidatePath('/admin');
    revalidatePath('/admin/designs');
    return { success: true };
  } catch (err: any) {
    console.error('Exception in deleteDesign:', err);
    return { success: false, error: err.message || 'Internal server error' };
  }
}
