import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://vsueyploeflyjvvrjhtl.supabase.co';
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzdWV5cGxvZWZseWp2dnJqaHRsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NzM4MDE2OCwiZXhwIjoyMTAyOTU2MTY4fQ.-CnmR0vZuHH97AitrEp2lFmwWmHJCnxwXtY2v_1O2UE';

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function runTest() {
  console.log('--- 1. Testing Admin Create Tailor ---');
  const testEmail = `gondar.heritage.${Date.now()}@example.com`;
  const shopName = 'Gondar Heritage Designs';
  const phone = '+251 95 567 8901';

  // Step 1: Create auth user with role tailor
  const { data: authData, error: authError } = await supabase.auth.admin.createUser({
    email: testEmail,
    email_confirm: true,
    user_metadata: {
      shop_name: shopName,
      phone,
      role: 'tailor',
    },
  });

  if (authError || !authData.user) {
    console.error('FAILED to create auth user:', authError);
    process.exit(1);
  }

  console.log('✓ Auth user created:', authData.user.id, authData.user.email);

  // Step 2: Check trigger created row in tailors table
  await new Promise((r) => setTimeout(r, 1000));
  const { data: tailorRow, error: tailorError } = await supabase
    .from('tailors')
    .select('*')
    .eq('auth_id', authData.user.id)
    .single();

  if (tailorError || !tailorRow) {
    console.error('FAILED to find tailor row:', tailorError);
    process.exit(1);
  }

  console.log('✓ Tailor row created by trigger:');
  console.log('  ID:', tailorRow.id);
  console.log('  Shop Name:', tailorRow.shop_name);
  console.log('  Shop Slug:', tailorRow.shop_slug);
  console.log('  Status:', tailorRow.status);
  console.log('  Email:', tailorRow.email);

  if (tailorRow.status !== 'pending') {
    console.error('Expected status pending, got:', tailorRow.status);
    process.exit(1);
  }

  console.log('\n--- 2. Testing Admin Delete Tailor ---');
  const { data: category } = await supabase.from('categories').select('id').limit(1).single();
  const { data: design } = await supabase
    .from('designs')
    .insert({
      tailor_id: tailorRow.id,
      category_id: category.id,
      price: 2500,
      tag: 'Test Deletion Tag',
    })
    .select()
    .single();

  console.log('✓ Test design created for tailor:', design.id);

  // Delete designs
  await supabase.from('designs').delete().eq('tailor_id', tailorRow.id);
  console.log('✓ Deleted tailor designs');

  // Delete tailor row
  await supabase.from('tailors').delete().eq('id', tailorRow.id);
  console.log('✓ Deleted tailor table row');

  // Delete auth user
  const { error: deleteAuthError } = await supabase.auth.admin.deleteUser(authData.user.id);
  if (deleteAuthError) {
    console.error('FAILED to delete auth user:', deleteAuthError);
    process.exit(1);
  }
  console.log('✓ Deleted auth user:', authData.user.id);

  // Verify auth user no longer exists
  const { data: userCheck } = await supabase.auth.admin.getUserById(authData.user.id);
  if (userCheck && userCheck.user) {
    console.error('Auth user still exists!');
    process.exit(1);
  }
  console.log('✓ Verified auth user is completely removed from auth.users');

  console.log('\n🎉 ALL VERIFICATIONS PASSED SUCCESSFULLY!');
}

runTest().catch((err) => {
  console.error(err);
  process.exit(1);
});
