-- PostgreSQL Database Initialization Script

-- Note: This script runs after the database and user are created by Helm
-- Connect to testdb (it should already exist from Helm values)

-- Create users table with snake_case naming (matching EF Core snake_case convention)
CREATE TABLE IF NOT EXISTS public.users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_name ON public.users(first_name, last_name);
CREATE INDEX IF NOT EXISTS idx_users_active ON public.users(is_active);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant table permissions to appuser
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO appuser;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO appuser;

-- Insert sample data for testing (only if table is empty)
INSERT INTO public.users (email, first_name, last_name) 
SELECT 'john.doe@example.com', 'John', 'Doe'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'john.doe@example.com');

INSERT INTO public.users (email, first_name, last_name) 
SELECT 'jane.smith@example.com', 'Jane', 'Smith'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'jane.smith@example.com');

INSERT INTO public.users (email, first_name, last_name) 
SELECT 'admin@example.com', 'Admin', 'User'
WHERE NOT EXISTS (SELECT 1 FROM public.users WHERE email = 'admin@example.com');

-- Display table info
\echo 'Displaying users table structure:'
\d+ public.users

\echo 'Current user count:'
SELECT COUNT(*) as total_users FROM public.users;

\echo 'Database initialization completed successfully!';

