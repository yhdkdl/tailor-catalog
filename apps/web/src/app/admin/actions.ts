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
 * Register a new tailor by admin
 */
export async function createTailorByAdmin(data: {
  shopName: string;
  email: string;
  phone?: string;
}) {
  try {
    const supabase = createAdminClient();
    const email = data.email.trim().toLowerCase();
    const shopName = data.shopName.trim();
    const phone = data.phone?.trim() || null;

    if (!shopName) {
      return { success: false, error: 'Shop name is required.' };
    }
    if (!email) {
      return { success: false, error: 'Email address is required.' };
    }

    // Check if email already exists in tailors table
    const { data: existingTailor } = await supabase
      .from('tailors')
      .select('id, email')
      .eq('email', email)
      .maybeSingle();

    if (existingTailor) {
      return { success: false, error: `A tailor with email "${email}" already exists.` };
    }

    // Create auth user with service role
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email,
      email_confirm: true,
      user_metadata: {
        shop_name: shopName,
        phone,
        role: 'tailor',
      },
    });

    if (authError) {
      return { success: false, error: authError.message };
    }

    if (!authData.user) {
      return { success: false, error: 'Failed to create user account.' };
    }

    // Fetch the tailor row created by on_tailor_signup trigger
    const { data: tailorRow, error: tailorFetchError } = await supabase
      .from('tailors')
      .select('*')
      .eq('auth_id', authData.user.id)
      .maybeSingle();

    if (tailorFetchError || !tailorRow) {
      // Fallback search by email
      const { data: fallbackTailor } = await supabase
        .from('tailors')
        .select('*')
        .eq('email', email)
        .maybeSingle();

      if (fallbackTailor) {
        revalidatePath('/admin');
        revalidatePath('/admin/tailors');
        return { success: true, tailor: fallbackTailor };
      }

      return {
        success: false,
        error: 'User created but tailor profile was not found. Please verify database triggers.',
      };
    }

    revalidatePath('/admin');
    revalidatePath('/admin/tailors');
    return { success: true, tailor: tailorRow };
  } catch (err: any) {
    console.error('Exception in createTailorByAdmin:', err);
    return { success: false, error: err.message || 'Internal server error' };
  }
}

/**
 * Delete a tailor and all associated data in strict order:
 * 1. Delete all design_photos storage files from the design-photos bucket
 * 2. Delete all design_photos records
 * 3. Delete all designs records
 * 4. Delete the tailors table row
 * 5. Delete the auth user
 */
export async function deleteTailorByAdmin(tailorId: string) {
  try {
    const supabase = createAdminClient();

    // Fetch tailor to get auth_id and info
    const { data: tailor, error: tailorError } = await supabase
      .from('tailors')
      .select('id, auth_id, shop_name, shop_slug')
      .eq('id', tailorId)
      .single();

    if (tailorError || !tailor) {
      return { success: false, error: tailorError?.message || 'Tailor not found.' };
    }

    // Step 1: Query all designs and photo storage paths for this tailor
    const { data: designs, error: designsFetchError } = await supabase
      .from('designs')
      .select('id')
      .eq('tailor_id', tailorId);

    if (designsFetchError) {
      return {
        success: false,
        error: `Failed to fetch designs before deletion: ${designsFetchError.message}`,
      };
    }

    const designIds = (designs || []).map((d) => d.id);

    // Step 2: Delete all design_photos storage files from design-photos bucket
    if (designIds.length > 0) {
      const { data: photos, error: photosFetchError } = await supabase
        .from('design_photos')
        .select('storage_path')
        .in('design_id', designIds);

      if (photosFetchError) {
        return {
          success: false,
          error: `Failed to fetch photos before deletion: ${photosFetchError.message}`,
        };
      }

      if (photos && photos.length > 0) {
        const pathsToDelete = photos.map((p) => p.storage_path);
        const { error: storageError } = await supabase.storage
          .from('design-photos')
          .remove(pathsToDelete);

        if (storageError) {
          return {
            success: false,
            error: `Failed to delete storage photos: ${storageError.message}`,
          };
        }
      }

      // Step 3: Delete all design_photos records for this tailor
      const { error: photosDeleteError } = await supabase
        .from('design_photos')
        .delete()
        .in('design_id', designIds);

      if (photosDeleteError) {
        return {
          success: false,
          error: `Failed to delete design photo records: ${photosDeleteError.message}`,
        };
      }

      // Step 4: Delete all designs records for this tailor
      const { error: designsDeleteError } = await supabase
        .from('designs')
        .delete()
        .eq('tailor_id', tailorId);

      if (designsDeleteError) {
        return {
          success: false,
          error: `Failed to delete design records: ${designsDeleteError.message}`,
        };
      }
    }

    // Step 5: Delete the tailors table row
    const { error: tailorDeleteError } = await supabase
      .from('tailors')
      .delete()
      .eq('id', tailorId);

    if (tailorDeleteError) {
      return {
        success: false,
        error: `Failed to delete tailor profile: ${tailorDeleteError.message}`,
      };
    }

    // Step 6: Delete the auth user using supabase.auth.admin.deleteUser(auth_id)
    if (tailor.auth_id) {
      const { error: authDeleteError } = await supabase.auth.admin.deleteUser(tailor.auth_id);
      if (authDeleteError) {
        return {
          success: false,
          error: `Tailor profile deleted, but failed to delete auth user: ${authDeleteError.message}`,
        };
      }
    }

    revalidatePath('/admin');
    revalidatePath('/admin/tailors');
    revalidatePath('/admin/designs');
    return { success: true };
  } catch (err: any) {
    console.error('Exception in deleteTailorByAdmin:', err);
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
