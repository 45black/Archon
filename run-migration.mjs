import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';

const supabaseUrl = 'https://jfjkaiupbmonavuwiyjr.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmamthaXVwYm1vbmF2dXdpeWpyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODA3NTU2MiwiZXhwIjoyMDgzNjUxNTYyfQ.q9cEhQl_5ap76EK0MkzmnNVkd-PU2DYynTSKgk64Xu4';

const supabase = createClient(supabaseUrl, supabaseKey);

// The Supabase JS client doesn't support raw SQL execution
// We need to use the Management API or pg client directly
// Let's check if there's a way via RPC

async function testConnection() {
  const { data, error } = await supabase
    .from('archon_settings')
    .select('count')
    .limit(1);

  if (error && error.code === '42P01') {
    console.log('Table does not exist yet - migration needed');
    console.log('Please run the migration SQL manually in the Supabase SQL Editor:');
    console.log('https://supabase.com/dashboard/project/jfjkaiupbmonavuwiyjr/sql');
    console.log('\nFile to run: migration/complete_setup.sql');
  } else if (error) {
    console.error('Error:', error);
  } else {
    console.log('Connection successful! Tables already exist.');
    console.log('Data:', data);
  }
}

testConnection();
