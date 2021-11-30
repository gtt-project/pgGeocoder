-- DROP TYPE geores CASCADE;

CREATE TYPE geores AS (
   code        integer,
   x           double precision,
   y           double precision,
   address     character varying,
   todofuken   character varying,
   shikuchoson character varying,
   ooaza       character varying,
   chiban      character varying,  
   go          character varying
);
