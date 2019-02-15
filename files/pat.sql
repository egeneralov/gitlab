--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.11
-- Dumped by pg_dump version 9.6.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: gitlab
--

INSERT INTO public.personal_access_tokens VALUES (4, 1, NULL, 'terraform', false, NULL, '2019-02-15 19:08:30.639803', '2019-02-15 19:08:30.639803', '---
- api
- read_user
- sudo
- read_repository
- read_registry
', false, 'Y6QGb5hFzofUaw9VNdY+Z+OuSdluNs1fl/gK8s+qcFM=');


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gitlab
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--


