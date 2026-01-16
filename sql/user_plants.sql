CREATE TABLE IF NOT EXISTS public.user_plants
(
    id integer NOT NULL DEFAULT nextval('user_plants_id_seq'::regclass),
    user_id integer,
    plant_id integer,
    scanned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_plants_pkey PRIMARY KEY (id),
    CONSTRAINT user_plants_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_plants_plant_id_fkey FOREIGN KEY (plant_id)
        REFERENCES public.plants (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_plants_unique UNIQUE (user_id, plant_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_plants
    OWNER to postgres;
