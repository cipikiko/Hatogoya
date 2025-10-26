CREATE TABLE IF NOT EXISTS public.user (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT DEFAULT 'visitor',
    created_at TIMESTAMPTZ DEFAULT now()
);
