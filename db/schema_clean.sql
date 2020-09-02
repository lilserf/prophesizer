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

ALTER TABLE ONLY public.player_events DROP CONSTRAINT player_events_game_event_id_fkey;
ALTER TABLE ONLY public.game_event_base_runners DROP CONSTRAINT game_event_base_runners_game_event_id_fkey;
ALTER TABLE ONLY public.time_map DROP CONSTRAINT time_map_pkey;
ALTER TABLE ONLY public.teams DROP CONSTRAINT teams_pkey;
ALTER TABLE ONLY public.players DROP CONSTRAINT players_pkey;
ALTER TABLE ONLY public.player_events DROP CONSTRAINT player_events_pkey;
ALTER TABLE ONLY public.imported_logs DROP CONSTRAINT imported_logs_pkey;
ALTER TABLE ONLY public.games DROP CONSTRAINT game_pkey;
ALTER TABLE ONLY public.game_events DROP CONSTRAINT game_events_pkey;
ALTER TABLE ONLY public.game_event_base_runners DROP CONSTRAINT game_event_base_runners_pkey;
ALTER TABLE xref.team_positions ALTER COLUMN team_position_id DROP DEFAULT;
ALTER TABLE xref.team_division ALTER COLUMN team_division_id DROP DEFAULT;
ALTER TABLE xref.player_attributes ALTER COLUMN player_attributes_id DROP DEFAULT;
ALTER TABLE raw.all_teams ALTER COLUMN all_teams_raw_id DROP DEFAULT;
ALTER TABLE public.teams ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.players ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.player_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.imported_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.game_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.game_event_base_runners ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE xref.team_positions_team_position_id_seq;
DROP TABLE xref.team_positions;
DROP SEQUENCE xref.team_division_team_division_id_seq;
DROP TABLE xref.team_division;
DROP SEQUENCE xref.player_attributes_player_attributes_id_seq;
DROP TABLE xref.player_attributes;
DROP SEQUENCE raw.all_teams_raw_all_teams_raw_id_seq;
DROP TABLE raw.all_teams;
DROP TABLE public.time_map;
DROP SEQUENCE public.teams_id_seq;
DROP TABLE public.teams;
DROP SEQUENCE public.players_id_seq;
DROP TABLE public.players;
DROP SEQUENCE public.player_events_id_seq;
DROP TABLE public.player_events;
DROP SEQUENCE public.imported_logs_id_seq;
DROP TABLE public.imported_logs;
DROP TABLE public.games;
DROP SEQUENCE public.game_events_id_seq;
DROP TABLE public.game_events;
DROP SEQUENCE public.game_event_base_runners_id_seq;
DROP TABLE public.game_event_base_runners;
DROP FUNCTION public.round_half_even(val numeric, prec integer);
DROP FUNCTION public.rating_to_star(in_rating numeric);
DROP FUNCTION public.pitching_rating(in_player_id character varying, valid_until timestamp without time zone);
DROP FUNCTION public.get_player_star_ratings(in_player_id character varying, valid_until timestamp without time zone);
DROP FUNCTION public.defense_rating(in_player_id character varying, valid_until timestamp without time zone);
DROP FUNCTION public.batting_rating(in_player_id character varying, valid_until timestamp without time zone);
DROP FUNCTION public.baserunning_rating(in_player_id character varying, valid_until timestamp without time zone);
DROP SCHEMA xref;
DROP SCHEMA raw;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: raw; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw;


--
-- Name: xref; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA xref;


--
-- Name: baserunning_rating(character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.baserunning_rating(in_player_id character varying, valid_until timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
SELECT 
	power(p.laserlikeness,0.5) *
   	power(p.continuation * p.base_thirst * p.indulgence * p.ground_friction, 0.1)
FROM players p
WHERE 
--player_name = 'Jessica Telephone'
player_id = in_player_id
AND coalesce(valid_until::text,'') = '';
$$;


--
-- Name: batting_rating(character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.batting_rating(in_player_id character varying, valid_until timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
SELECT 
power((1 - p.tragicness),0.01) * 
	power((1 - p.patheticism),0.05) *
   power((p.thwackability * p.divinity),0.35) *
   power((p.moxie * p.musclitude),0.075) * 
	power(p.martyrdom,0.02)
FROM players p
WHERE 
--player_name = 'Jessica Telephone'
player_id = in_player_id
AND coalesce(valid_until::text,'') = '';
$$;


--
-- Name: defense_rating(character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.defense_rating(in_player_id character varying, valid_until timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
SELECT 
	power((p.omniscience * p.tenaciousness),0.2) *
   	power((p.watchfulness * p.anticapitalism * p.chasiness),0.1)
FROM players p
WHERE 
--player_name = 'Jessica Telephone'
player_id = in_player_id
AND coalesce(valid_until::text,'') = '';
$$;


--
-- Name: get_player_star_ratings(character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_player_star_ratings(in_player_id character varying, valid_until timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS TABLE(baserunning_rating numeric, batting_rating numeric, defense_rating numeric, pitching_rating numeric)
    LANGUAGE sql
    AS $$
SELECT 

0.5 * round_half_even(( 
(
	power(p.laserlikeness,0.5) *
   power(p.continuation * p.base_thirst * p.indulgence * p.ground_friction, 0.1)
) * 10),0) AS baserunner_rating,

0.5 * round_half_even((
( 
	power((1 - p.tragicness),0.01) * 
	power((1 - p.patheticism),0.05) *
   power((p.thwackability * p.divinity),0.35) *
   power((p.moxie * p.musclitude),0.075) * 
	power(p.martyrdom,0.02)
) * 10),0) AS batter_rating,

0.5 * round_half_even((
(
	power((p.omniscience * p.tenaciousness),0.2) *
   power((p.watchfulness * p.anticapitalism * p.chasiness),0.1)
) * 10),0) AS defense_rating,

0.5 * round_half_even((
(
	power(p.unthwackability,0.5) * 
	power(p.ruthlessness,0.4) *
   power(p.overpowerment,0.15) * 
	power(p.shakespearianism,0.1) * 
	power(p.coldness,0.025)
) * 10),0) AS pitching_rating

FROM players p
WHERE 
--player_name = 'Jessica Telephone'
player_id = in_player_id
AND coalesce(valid_until::text,'') = '';
$$;


--
-- Name: pitching_rating(character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pitching_rating(in_player_id character varying, valid_until timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
SELECT 
	power(p.unthwackability,0.5) * 
	power(p.ruthlessness,0.4) *
   	power(p.overpowerment,0.15) * 
	power(p.shakespearianism,0.1) * 
	power(p.coldness,0.025)
FROM players p
WHERE 
--player_name = 'Jessica Telephone'
player_id = in_player_id
AND coalesce(valid_until::text,'') = '';
$$;


--
-- Name: rating_to_star(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rating_to_star(in_rating numeric) RETURNS numeric
    LANGUAGE sql
    AS $$
SELECT 0.5 * round_half_even((
(in_rating)* 10),0);
$$;


--
-- Name: round_half_even(numeric, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.round_half_even(val numeric, prec integer) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
declare
    retval numeric;
    difference numeric;
    even boolean;
begin
    retval := round(val,prec);
    difference := retval-val;
    if abs(difference)*(10::numeric^prec) = 0.5::numeric then
        even := (retval * (10::numeric^prec)) % 2::numeric = 0::numeric;
        if not even then
            retval := round(val-difference,prec);
        end if;
    end if;
    return retval;
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: game_event_base_runners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.game_event_base_runners (
    id integer NOT NULL,
    game_event_id integer,
    runner_id character varying(36),
    responsible_pitcher_id character varying(36),
    base_before_play integer,
    base_after_play integer,
    was_base_stolen boolean,
    was_caught_stealing boolean,
    was_picked_off boolean
);


--
-- Name: game_event_base_runners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.game_event_base_runners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: game_event_base_runners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.game_event_base_runners_id_seq OWNED BY public.game_event_base_runners.id;


--
-- Name: game_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.game_events (
    id integer NOT NULL,
    perceived_at timestamp without time zone,
    game_id character varying(36),
    event_type text,
    event_index integer,
    inning smallint,
    top_of_inning boolean,
    outs_before_play smallint,
    batter_id character varying(36),
    batter_team_id character varying(36),
    pitcher_id character varying(36),
    pitcher_team_id character varying(36),
    home_score numeric,
    away_score numeric,
    home_strike_count smallint,
    away_strike_count smallint,
    batter_count integer,
    pitches character varying(1)[],
    total_strikes smallint,
    total_balls smallint,
    total_fouls smallint,
    is_leadoff boolean,
    is_pinch_hit boolean,
    lineup_position smallint,
    is_last_event_for_plate_appearance boolean,
    bases_hit smallint,
    runs_batted_in smallint,
    is_sacrifice_hit boolean,
    is_sacrifice_fly boolean,
    outs_on_play smallint,
    is_double_play boolean,
    is_triple_play boolean,
    is_wild_pitch boolean,
    batted_ball_type text,
    is_bunt boolean,
    errors_on_play smallint,
    batter_base_after_play smallint,
    is_last_game_event boolean,
    event_text text[],
    additional_context text,
    season integer,
    day integer,
    parsing_error boolean,
    parsing_error_list text[],
    fixed_error boolean,
    fixed_error_list text[]
);


--
-- Name: game_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.game_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: game_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.game_events_id_seq OWNED BY public.game_events.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games (
    game_id character varying(36) NOT NULL,
    day integer,
    season integer,
    last_game_event integer,
    home_odds numeric,
    away_odds numeric,
    weather integer,
    series_index integer,
    series_length integer,
    is_postseason boolean,
    home_team character varying(36),
    away_team character varying(36),
    home_score integer,
    away_score integer,
    number_of_innings integer,
    ended_on_top_of_inning boolean,
    ended_in_shame boolean,
    terminology_id character varying(36),
    rules_id character varying(36),
    statsheet_id character varying(36)
);


--
-- Name: imported_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imported_logs (
    id integer NOT NULL,
    key text,
    imported_at timestamp without time zone
);


--
-- Name: imported_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imported_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imported_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imported_logs_id_seq OWNED BY public.imported_logs.id;


--
-- Name: player_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.player_events (
    id integer NOT NULL,
    game_event_id integer,
    player_id character varying(36),
    event_type text
);


--
-- Name: player_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.player_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: player_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.player_events_id_seq OWNED BY public.player_events.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players (
    id integer NOT NULL,
    player_id character varying(36),
    valid_until timestamp without time zone,
    player_name character varying,
    deceased boolean,
    hash uuid,
    anticapitalism numeric,
    base_thirst numeric,
    buoyancy numeric,
    chasiness numeric,
    coldness numeric,
    continuation numeric,
    divinity numeric,
    ground_friction numeric,
    indulgence numeric,
    laserlikeness numeric,
    martyrdom numeric,
    moxie numeric,
    musclitude numeric,
    omniscience numeric,
    overpowerment numeric,
    patheticism numeric,
    ruthlessness numeric,
    shakespearianism numeric,
    suppression numeric,
    tenaciousness numeric,
    thwackability numeric,
    tragicness numeric,
    unthwackability numeric,
    watchfulness numeric,
    pressurization numeric,
    cinnamon numeric,
    total_fingers smallint,
    soul smallint,
    fate smallint,
    peanut_allergy boolean,
    armor text,
    bat text,
    ritual text,
    coffee smallint,
    blood smallint
);


--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    team_id character varying(36),
    location text,
    nickname text,
    full_name text,
    valid_until timestamp without time zone,
    hash uuid
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: time_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_map (
    season integer NOT NULL,
    day integer NOT NULL,
    first_time timestamp without time zone
);


--
-- Name: all_teams; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.all_teams (
    all_teams_raw_id integer NOT NULL,
    json_data json,
    download_time timestamp without time zone DEFAULT now()
);


--
-- Name: all_teams_raw_all_teams_raw_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

CREATE SEQUENCE raw.all_teams_raw_all_teams_raw_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: all_teams_raw_all_teams_raw_id_seq; Type: SEQUENCE OWNED BY; Schema: raw; Owner: -
--

ALTER SEQUENCE raw.all_teams_raw_all_teams_raw_id_seq OWNED BY raw.all_teams.all_teams_raw_id;


--
-- Name: player_attributes; Type: TABLE; Schema: xref; Owner: -
--

CREATE TABLE xref.player_attributes (
    player_attributes_id integer NOT NULL,
    player_id character varying,
    attribute_id integer,
    valid_until timestamp without time zone,
    attribute_value integer
);


--
-- Name: player_attributes_player_attributes_id_seq; Type: SEQUENCE; Schema: xref; Owner: -
--

CREATE SEQUENCE xref.player_attributes_player_attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: player_attributes_player_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: xref; Owner: -
--

ALTER SEQUENCE xref.player_attributes_player_attributes_id_seq OWNED BY xref.player_attributes.player_attributes_id;


--
-- Name: team_division; Type: TABLE; Schema: xref; Owner: -
--

CREATE TABLE xref.team_division (
    team_division_id integer NOT NULL,
    team_id character varying,
    division character varying,
    league character varying,
    valid_until timestamp without time zone
);


--
-- Name: team_division_team_division_id_seq; Type: SEQUENCE; Schema: xref; Owner: -
--

CREATE SEQUENCE xref.team_division_team_division_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_division_team_division_id_seq; Type: SEQUENCE OWNED BY; Schema: xref; Owner: -
--

ALTER SEQUENCE xref.team_division_team_division_id_seq OWNED BY xref.team_division.team_division_id;


--
-- Name: team_positions; Type: TABLE; Schema: xref; Owner: -
--

CREATE TABLE xref.team_positions (
    team_position_id integer NOT NULL,
    team_id character varying,
    position_id integer,
    valid_until timestamp without time zone,
    player_id character varying
);


--
-- Name: team_positions_team_position_id_seq; Type: SEQUENCE; Schema: xref; Owner: -
--

CREATE SEQUENCE xref.team_positions_team_position_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_positions_team_position_id_seq; Type: SEQUENCE OWNED BY; Schema: xref; Owner: -
--

ALTER SEQUENCE xref.team_positions_team_position_id_seq OWNED BY xref.team_positions.team_position_id;


--
-- Name: game_event_base_runners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_event_base_runners ALTER COLUMN id SET DEFAULT nextval('public.game_event_base_runners_id_seq'::regclass);


--
-- Name: game_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_events ALTER COLUMN id SET DEFAULT nextval('public.game_events_id_seq'::regclass);


--
-- Name: imported_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imported_logs ALTER COLUMN id SET DEFAULT nextval('public.imported_logs_id_seq'::regclass);


--
-- Name: player_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_events ALTER COLUMN id SET DEFAULT nextval('public.player_events_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: all_teams all_teams_raw_id; Type: DEFAULT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.all_teams ALTER COLUMN all_teams_raw_id SET DEFAULT nextval('raw.all_teams_raw_all_teams_raw_id_seq'::regclass);


--
-- Name: player_attributes player_attributes_id; Type: DEFAULT; Schema: xref; Owner: -
--

ALTER TABLE ONLY xref.player_attributes ALTER COLUMN player_attributes_id SET DEFAULT nextval('xref.player_attributes_player_attributes_id_seq'::regclass);


--
-- Name: team_division team_division_id; Type: DEFAULT; Schema: xref; Owner: -
--

ALTER TABLE ONLY xref.team_division ALTER COLUMN team_division_id SET DEFAULT nextval('xref.team_division_team_division_id_seq'::regclass);


--
-- Name: team_positions team_position_id; Type: DEFAULT; Schema: xref; Owner: -
--

ALTER TABLE ONLY xref.team_positions ALTER COLUMN team_position_id SET DEFAULT nextval('xref.team_positions_team_position_id_seq'::regclass);


--
-- Name: game_event_base_runners game_event_base_runners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_event_base_runners
    ADD CONSTRAINT game_event_base_runners_pkey PRIMARY KEY (id);


--
-- Name: game_events game_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT game_events_pkey PRIMARY KEY (id);


--
-- Name: games game_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT game_pkey PRIMARY KEY (game_id);


--
-- Name: imported_logs imported_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imported_logs
    ADD CONSTRAINT imported_logs_pkey PRIMARY KEY (id);


--
-- Name: player_events player_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_events
    ADD CONSTRAINT player_events_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: time_map time_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_map
    ADD CONSTRAINT time_map_pkey PRIMARY KEY (season, day);


--
-- Name: game_event_base_runners game_event_base_runners_game_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_event_base_runners
    ADD CONSTRAINT game_event_base_runners_game_event_id_fkey FOREIGN KEY (game_event_id) REFERENCES public.game_events(id) ON DELETE CASCADE;


--
-- Name: player_events player_events_game_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.player_events
    ADD CONSTRAINT player_events_game_event_id_fkey FOREIGN KEY (game_event_id) REFERENCES public.game_events(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

