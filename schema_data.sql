--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 12.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE taxa.event_types ALTER COLUMN event_type_id DROP DEFAULT;
DROP SEQUENCE taxa.event_types_event_type_id_seq;
DROP TABLE taxa.event_types;
DROP SCHEMA taxa;
--
-- Name: taxa; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA taxa;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event_types; Type: TABLE; Schema: taxa; Owner: -
--

CREATE TABLE taxa.event_types (
    event_type_id integer NOT NULL,
    event_type text,
    plate_appearance integer,
    at_bat integer,
    hit integer,
    total_bases integer
);


--
-- Name: event_types_event_type_id_seq; Type: SEQUENCE; Schema: taxa; Owner: -
--

CREATE SEQUENCE taxa.event_types_event_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_types_event_type_id_seq; Type: SEQUENCE OWNED BY; Schema: taxa; Owner: -
--

ALTER SEQUENCE taxa.event_types_event_type_id_seq OWNED BY taxa.event_types.event_type_id;


--
-- Name: event_types event_type_id; Type: DEFAULT; Schema: taxa; Owner: -
--

ALTER TABLE ONLY taxa.event_types ALTER COLUMN event_type_id SET DEFAULT nextval('taxa.event_types_event_type_id_seq'::regclass);


--
-- Data for Name: event_types; Type: TABLE DATA; Schema: taxa; Owner: -
--

COPY taxa.event_types (event_type_id, event_type, plate_appearance, at_bat, hit, total_bases) FROM stdin;
1	CAUGHT_STEALING	0	0	0	0
3	DOUBLE	1	1	1	2
4	FIELDERS_CHOICE	1	1	0	1
5	HOME_RUN	1	1	1	4
6	OUT	1	1	0	0
7	SINGLE	1	1	1	1
8	STOLEN_BASE	0	0	0	0
9	STRIKEOUT	1	1	0	0
10	TRIPLE	1	1	1	3
11	WALK	1	0	0	1
12	UNKNOWN	1	0	0	0
\.


--
-- Name: event_types_event_type_id_seq; Type: SEQUENCE SET; Schema: taxa; Owner: -
--

SELECT pg_catalog.setval('taxa.event_types_event_type_id_seq', 12, true);


--
-- PostgreSQL database dump complete
--

