-- Table: public.user_plant_views

-- DROP TABLE IF EXISTS public.user_plant_views;

CREATE TABLE IF NOT EXISTS public.user_plant_views
(
    id integer NOT NULL DEFAULT nextval('user_plant_views_id_seq'::regclass),
    user_id integer,
    plant_id integer,
    viewed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_plant_views_pkey PRIMARY KEY (id),
    CONSTRAINT user_plant_views_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_plant_views_plant_id_fkey FOREIGN KEY (plant_id)
        REFERENCES public.plants (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_plant_views
    OWNER to postgres;
