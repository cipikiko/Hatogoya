-- Table: public.plants

-- DROP TABLE IF EXISTS public.plants;

CREATE TABLE IF NOT EXISTS public.plants
(
    id integer NOT NULL DEFAULT nextval('plants_id_seq'::regclass),
    name text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    wiki_url text COLLATE pg_catalog."default",
    qr_token text COLLATE pg_catalog."default" UNIQUE NOT NULL,
    CONSTRAINT plants_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.plants
    OWNER to postgres;
