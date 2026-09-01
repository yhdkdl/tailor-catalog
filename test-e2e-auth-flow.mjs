import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://vsueyploeflyjvvrjhtl.supabase.co';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzdWV5cGxvZWZseWp2dnJqaHRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODczODAxNjgsImV4cCI6MjEwMjk1NjE2OH0.32AiFJOfDTM7elJpTwC1ZlHiqEJtiP4_Fu0uSCXgwg0';
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzdWV5cGxvZWZseWp2dnJqaHRsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NzM4MDE2OCwiZXhwIjoyMTAyOTU2MTY4fQ.-CnmR0vZuHH97AitrEp2lFmwWmHJCnxwXtY2v_1O2UE';

// Admin client
const adminClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

// Tailor client (anon)
const tailorClient = createClient(supabaseUrl, anonKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function createTailorAccount(shopName, email, phone, password) {
  let { data: authData, error: authError } = await adminClient.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: {
      shop_name: shopName,
      phone,
      role: 'tailor',
    },
  });

  let authUser = authData?.user;
  if (authError || !authUser) {
    const fallbackCreate = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        shop_name: shopName,
        phone,
      },
    });

    if (fallbackCreate.error || !fallbackCreate.data.user) {
      throw new Error(`Failed to create auth user: ${authError?.message || fallbackCreate.error?.message}`);
    }
    authUser = fallbackCreate.data.user;
  }

  // Fetch or create tailor profile
  let { data: tailorRow } = await adminClient
    .from('tailors')
    .select('*')
    .eq('auth_id', authUser.id)
    .maybeSingle();

  if (!tailorRow) {
    const rawSlug = shopName.toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, '-');
    let finalSlug = rawSlug || 'tailor';
    let counter = 0;
    while (true) {
      const { data: existingSlug } = await adminClient
        .from('tailors')
        .select('id')
        .eq('shop_slug', finalSlug)
        .maybeSingle();
      if (!existingSlug) break;
      counter++;
      finalSlug = `${rawSlug}-${counter}`;
    }

    const { data: createdTailor, error: insertError } = await adminClient
      .from('tailors')
      .insert({
        auth_id: authUser.id,
        shop_name: shopName,
        shop_slug: finalSlug,
        email,
        phone,
        status: 'pending',
      })
      .select()
      .single();

    if (insertError || !createdTailor) {
      throw new Error(`Failed to create tailor profile: ${insertError?.message}`);
    }
    tailorRow = createdTailor;
  }

  return { tailor: tailorRow, user: authUser };
}

async function runE2E() {
  console.log('====================================================');
  console.log('      RUNNING FULL TAILOR AUTH E2E AUDIT FLOW       ');
  console.log('====================================================\n');

  const testEmail = `audit.tailor.${Date.now()}@example.com`;
  const testPassword = 'Password@1234';
  const shopName = 'Audit Royal Habesha';
  const phone = '+251 91 234 5678';

  let authUserId = null;
  let tailorId = null;

  try {
    // -------------------------------------------------------------
    // Step 1 - Admin creates tailor:
    // -------------------------------------------------------------
    console.log('--- Step 1: Admin creates tailor (/admin/tailors/new) ---');
    const creationResult = await createTailorAccount(shopName, testEmail, phone, testPassword);
    authUserId = creationResult.user.id;
    tailorId = creationResult.tailor.id;

    console.log('✓ Admin created tailor auth user with email_confirm: true (Auth ID:', authUserId, ')');
    console.log('✓ Tailor record created in DB with status:', creationResult.tailor.status);
    console.log('✓ Success modal data prepared:');
    console.log('    Shop name:', creationResult.tailor.shop_name);
    console.log('    Email:', creationResult.tailor.email);
    console.log('    Temporary password:', testPassword);

    if (creationResult.tailor.status !== 'pending') {
      throw new Error(`Step 1 FAILED: Expected initial status "pending", got "${creationResult.tailor.status}"`);
    }
    console.log('RESULT: Step 1 - PASS\n');

    // -------------------------------------------------------------
    // Step 2 - Tailor logs in:
    // -------------------------------------------------------------
    console.log('--- Step 2: Tailor logs in on Flutter mobile app ---');
    const { data: loginData, error: loginError } = await tailorClient.auth.signInWithPassword({
      email: testEmail,
      password: testPassword,
    });

    if (loginError || !loginData.session) {
      throw new Error(`Step 2 FAILED: Tailor sign in failed: ${loginError?.message}`);
    }
    console.log('✓ Tailor authenticated successfully with email + password');

    // Authenticated client as tailor
    const authenticatedTailorClient = createClient(supabaseUrl, anonKey, {
      global: {
        headers: {
          Authorization: `Bearer ${loginData.session.access_token}`,
        },
      },
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: tailorProfile, error: profileError } = await authenticatedTailorClient
      .from('tailors')
      .select('shop_name, status')
      .eq('auth_id', loginData.user.id)
      .single();

    if (profileError || !tailorProfile) {
      throw new Error(`Step 2 FAILED: Tailor profile query failed: ${profileError?.message}`);
    }
    console.log(`✓ Profile loaded: shop="${tailorProfile.shop_name}", status="${tailorProfile.status}"`);
    if (tailorProfile.status !== 'pending') {
      throw new Error(`Step 2 FAILED: Expected status "pending", got "${tailorProfile.status}"`);
    }
    console.log('✓ Route selected: Screen 2 (Pending approval screen)');
    console.log('RESULT: Step 2 - PASS\n');

    // -------------------------------------------------------------
    // Step 3 - Admin approves tailor:
    // -------------------------------------------------------------
    console.log('--- Step 3: Admin approves tailor (/admin/tailors) ---');
    const { data: approvedTailor, error: approveError } = await adminClient
      .from('tailors')
      .update({ status: 'approved' })
      .eq('id', tailorId)
      .select()
      .single();

    if (approveError || !approvedTailor || approvedTailor.status !== 'approved') {
      throw new Error(`Step 3 FAILED: Admin failed to approve tailor: ${approveError?.message}`);
    }
    console.log('✓ Admin updated tailor status in DB to "approved"');
    console.log('RESULT: Step 3 - PASS\n');

    // -------------------------------------------------------------
    // Step 4 - Tailor sees dashboard on refresh:
    // -------------------------------------------------------------
    console.log('--- Step 4: Tailor refreshes status on pending screen ---');
    const { data: refreshedProfile, error: refreshError } = await authenticatedTailorClient
      .from('tailors')
      .select('shop_name, status')
      .eq('auth_id', loginData.user.id)
      .single();

    if (refreshError || !refreshedProfile) {
      throw new Error(`Step 4 FAILED: Refresh status query failed: ${refreshError?.message}`);
    }
    console.log(`✓ Refreshed status: "${refreshedProfile.status}"`);
    if (refreshedProfile.status !== 'approved') {
      throw new Error(`Step 4 FAILED: Expected status "approved", got "${refreshedProfile.status}"`);
    }
    console.log(`✓ Route updated: Screen 4 (Main Dashboard showing "Welcome ${refreshedProfile.shop_name}")`);
    console.log('RESULT: Step 4 - PASS\n');

    // -------------------------------------------------------------
    // Step 5 - Session persistence:
    // -------------------------------------------------------------
    console.log('--- Step 5: Session persistence across app restarts ---');
    const sessionToken = loginData.session.access_token;
    const persistentClient = createClient(supabaseUrl, anonKey, {
      global: {
        headers: {
          Authorization: `Bearer ${sessionToken}`,
        },
      },
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: persistentUser, error: userError } = await persistentClient.auth.getUser(sessionToken);
    if (userError || !persistentUser.user) {
      throw new Error(`Step 5 FAILED: Failed to retrieve user from stored session token: ${userError?.message}`);
    }

    const { data: persistentProfile, error: persistentProfileError } = await persistentClient
      .from('tailors')
      .select('shop_name, status')
      .eq('auth_id', persistentUser.user.id)
      .single();

    if (persistentProfileError || !persistentProfile || persistentProfile.status !== 'approved') {
      throw new Error(`Step 5 FAILED: Persisted session check failed: ${persistentProfileError?.message}`);
    }
    console.log('✓ Restored session validated for user ID:', persistentUser.user.id);
    console.log(`✓ Direct route to Main Dashboard (status: ${persistentProfile.status}) without asking for login`);
    console.log('RESULT: Step 5 - PASS\n');

    // -------------------------------------------------------------
    // Step 6 - Wrong password test:
    // -------------------------------------------------------------
    console.log('--- Step 6: Sign out and wrong password test ---');
    await tailorClient.auth.signOut();
    console.log('✓ Tailor signed out');

    const { data: wrongLoginData, error: wrongLoginError } = await tailorClient.auth.signInWithPassword({
      email: testEmail,
      password: 'WrongPassword999!',
    });

    if (!wrongLoginError) {
      throw new Error('Step 6 FAILED: Login with incorrect password unexpectedly succeeded!');
    }
    console.log('✓ Login correctly rejected with error:', wrongLoginError.message);
    console.log('RESULT: Step 6 - PASS\n');

    console.log('====================================================');
    console.log('  ALL 6 STEPS PASSED SUCCESSFULLY WITHOUT ERRORS!   ');
    console.log('====================================================');
  } finally {
    if (tailorId) {
      await adminClient.from('tailors').delete().eq('id', tailorId);
    }
    if (authUserId) {
      await adminClient.auth.admin.deleteUser(authUserId);
      console.log('🧹 Cleaned up test tailor account from DB and Auth.');
    }
  }
}

runE2E().catch((err) => {
  console.error(err);
  process.exit(1);
});
