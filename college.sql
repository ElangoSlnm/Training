--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--

DROP DATABASE college;
DROP DATABASE tester;




--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md52a29a4f7eb0a98abca0992ca3fb555b6';






--
-- Databases
--

--
-- Database "template1" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.1 (Debian 12.1-1.pgdg100+1)

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

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- Name: template1; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE template1 OWNER TO postgres;

\connect template1

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

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

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

--
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- Database "college" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.1 (Debian 12.1-1.pgdg100+1)

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

--
-- Name: college; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE college WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE college OWNER TO postgres;

\connect college

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

--
-- Name: geinfo_to_json(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.geinfo_to_json(vname character varying, vyear integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
result text;
BEGIN
SELECT row_to_json(t) INTO result FROM (SELECT p.name, 2017 as year, (SELECT array_to_json(array_agg(row_to_json(d))) FROM (SELECT s.name AS sub_name, e.type AS exam_type, m.mark FROM marks m JOIN subject s ON m.sub_code = s.code JOIN exam e ON e.id = m.exam_type WHERE m.student_id = p.id 
AND m.year = 2017) d) AS details FROM person p WHERE p.name  = 'Elango') t;
RETURN result;
END;
$$;


ALTER FUNCTION public.geinfo_to_json(vname character varying, vyear integer) OWNER TO postgres;

--
-- Name: getdetails(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdetails(name text, year integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
row text;
BEGIN
SELECT dept_id, email INTO row FROM person WHERE name = `getDetails.name`;        
RETURN row
;
END;
$$;


ALTER FUNCTION public.getdetails(name text, year integer) OWNER TO postgres;

--
-- Name: getinfo(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getinfo(vname character varying, vyear integer) RETURNS TABLE(subject_name character varying, exam character varying, mark integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN query
SELECT s.name, e.type, m.mark FROM person p JOIN marks m ON p.id = m.student_id JOIN subject s ON m.sub_code = s.code JOIN exam e ON m.exam_type = e.id WHERE p.name = vname AND m.year = vyear;
END;
$$;


ALTER FUNCTION public.getinfo(vname character varying, vyear integer) OWNER TO postgres;

--
-- Name: getinfo_to_json(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getinfo_to_json(vname character varying, vyear integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
t_row json;
BEGIN
SELECT array_to_json(array_agg(row_to_json(t))) INTO t_row FROM (SELECT p.name AS student_name, s.name AS subject_name, e.type AS exam, m.mark FROM person p JOIN marks m ON p.id = m.student_id JOIN subject s ON m.sub_code = s.code JOIN exam e ON m.exam_type = e.id WHERE p.name = vname AND m.year = vyear LIMIT 10) t;
RETURN t_row;
END;
$$;


ALTER FUNCTION public.getinfo_to_json(vname character varying, vyear integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    id integer NOT NULL,
    name character varying(15) NOT NULL,
    email character varying(25) NOT NULL,
    dept_id integer NOT NULL,
    age integer NOT NULL,
    gender character(1),
    role integer
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: getpersons(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getpersons() RETURNS SETOF public.person
    LANGUAGE plpgsql
    AS $$
BEGIN 
RETURN query
SELECT * FROM person LIMIT 20;
END;
$$;


ALTER FUNCTION public.getpersons() OWNER TO postgres;

--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    id integer NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_id_seq OWNER TO postgres;

--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_id_seq OWNED BY public.department.id;


--
-- Name: exam; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exam (
    id integer NOT NULL,
    type character varying(10) NOT NULL
);


ALTER TABLE public.exam OWNER TO postgres;

--
-- Name: exam_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exam_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.exam_id_seq OWNER TO postgres;

--
-- Name: exam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exam_id_seq OWNED BY public.exam.id;


--
-- Name: marks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marks (
    sno integer NOT NULL,
    student_id integer NOT NULL,
    sub_code integer NOT NULL,
    mark integer NOT NULL,
    year integer NOT NULL,
    exam_type integer NOT NULL,
    part integer NOT NULL
);


ALTER TABLE public.marks OWNER TO postgres;

--
-- Name: marks_sno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.marks_sno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.marks_sno_seq OWNER TO postgres;

--
-- Name: marks_sno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marks_sno_seq OWNED BY public.marks.sno;


--
-- Name: pserson_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pserson_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pserson_id_seq OWNER TO postgres;

--
-- Name: pserson_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pserson_id_seq OWNED BY public.person.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(20) NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: subject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subject (
    code integer NOT NULL,
    name character varying(15) NOT NULL,
    staff_id integer NOT NULL
);


ALTER TABLE public.subject OWNER TO postgres;

--
-- Name: subject_code_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subject_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subject_code_seq OWNER TO postgres;

--
-- Name: subject_code_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subject_code_seq OWNED BY public.subject.code;


--
-- Name: department id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN id SET DEFAULT nextval('public.department_id_seq'::regclass);


--
-- Name: exam id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam ALTER COLUMN id SET DEFAULT nextval('public.exam_id_seq'::regclass);


--
-- Name: marks sno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marks ALTER COLUMN sno SET DEFAULT nextval('public.marks_sno_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.pserson_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Name: subject code; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject ALTER COLUMN code SET DEFAULT nextval('public.subject_code_seq'::regclass);


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (id, name) FROM stdin;
1	MCA
2	MSC
3	MECH
4	CSE
5	EEE
6	PTECH
\.


--
-- Data for Name: exam; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exam (id, type) FROM stdin;
1	internal
2	model
3	semester
\.


--
-- Data for Name: marks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marks (sno, student_id, sub_code, mark, year, exam_type, part) FROM stdin;
1	1	1	89	2016	1	1
2	2	1	67	2016	1	1
3	3	1	78	2016	1	1
4	4	1	35	2016	1	1
5	5	1	71	2016	1	1
6	1	2	81	2016	1	1
7	2	2	78	2016	1	1
8	3	2	62	2016	1	1
9	4	2	91	2016	1	1
10	5	2	45	2016	1	1
11	6	1	81	2016	1	1
12	7	1	60	2016	1	1
13	8	1	88	2016	1	1
14	9	1	78	2016	1	1
15	6	2	89	2016	1	1
16	7	2	71	2016	1	1
17	8	2	98	2016	1	1
18	9	2	69	2016	1	1
19	10	4	78	2016	1	1
20	11	4	67	2016	1	1
21	12	4	41	2016	1	1
22	13	4	83	2016	1	1
23	23	4	69	2016	1	1
24	10	5	85	2016	1	1
25	11	5	79	2016	1	1
26	12	5	77	2016	1	1
27	13	5	47	2016	1	1
28	23	5	86	2016	1	1
29	14	1	74	2016	1	1
30	15	1	87	2016	1	1
31	16	1	97	2016	1	1
32	17	1	68	2016	1	1
33	14	2	73	2016	1	1
34	15	2	89	2016	1	1
35	16	2	74	2016	1	1
36	17	2	46	2016	1	1
37	18	4	67	2016	1	1
38	19	4	69	2016	1	1
39	20	4	78	2016	1	1
40	21	4	56	2016	1	1
41	22	4	88	2016	1	1
42	18	6	79	2016	1	1
43	19	6	87	2016	1	1
44	20	6	91	2016	1	1
45	21	6	78	2016	1	1
46	22	6	44	2016	1	1
47	1	1	76	2016	2	1
48	2	1	56	2016	2	1
49	3	1	87	2016	2	1
50	4	1	59	2016	2	1
51	5	1	75	2016	2	1
52	1	2	93	2016	2	1
53	2	2	69	2016	2	1
54	3	2	82	2016	2	1
55	4	2	45	2016	2	1
56	5	2	76	2016	2	1
57	6	1	77	2016	2	1
58	7	1	86	2016	2	1
59	8	1	58	2016	2	1
60	9	1	81	2016	2	1
61	6	2	67	2016	2	1
62	7	2	85	2016	2	1
63	8	2	61	2016	2	1
64	9	2	65	2016	2	1
65	10	4	58	2016	2	1
66	11	4	85	2016	2	1
67	12	4	72	2016	2	1
68	13	4	68	2016	2	1
69	23	4	92	2016	2	1
70	10	5	76	2016	2	1
71	11	5	78	2016	2	1
72	12	5	54	2016	2	1
73	13	5	78	2016	2	1
74	23	5	81	2016	2	1
75	14	1	74	2016	2	1
76	15	1	67	2016	2	1
77	16	1	68	2016	2	1
78	17	1	76	2016	2	1
79	14	2	83	2016	2	1
80	15	2	67	2016	2	1
81	16	2	75	2016	2	1
82	17	2	46	2016	2	1
83	18	4	67	2016	2	1
84	19	4	88	2016	2	1
85	20	4	79	2016	2	1
86	21	4	69	2016	2	1
87	22	4	81	2016	2	1
88	18	6	76	2016	2	1
89	19	6	74	2016	2	1
90	20	6	76	2016	2	1
91	21	6	75	2016	2	1
92	22	6	74	2016	2	1
93	1	1	83	2016	3	1
94	2	1	69	2016	3	1
95	3	1	85	2016	3	1
96	4	1	79	2016	3	1
97	5	1	77	2016	3	1
98	1	2	47	2016	3	1
99	2	2	86	2016	3	1
100	3	2	74	2016	3	1
101	4	2	87	2016	3	1
102	5	2	97	2016	3	1
103	6	1	68	2016	3	1
104	7	1	73	2016	3	1
105	8	1	89	2016	3	1
106	9	1	74	2016	3	1
107	6	2	46	2016	3	1
108	7	2	67	2016	3	1
109	8	2	69	2016	3	1
110	9	2	78	2016	3	1
111	10	4	56	2016	3	1
112	11	4	88	2016	3	1
113	12	4	79	2016	3	1
114	13	4	87	2016	3	1
115	23	4	91	2016	3	1
116	10	5	78	2016	3	1
117	11	5	44	2016	3	1
118	12	5	76	2016	3	1
119	13	5	56	2016	3	1
120	23	5	87	2016	3	1
121	14	1	59	2016	3	1
122	15	1	75	2016	3	1
123	16	1	93	2016	3	1
125	14	2	82	2016	3	1
126	15	2	45	2016	3	1
127	16	2	76	2016	3	1
128	17	2	77	2016	3	1
129	18	4	86	2016	3	1
130	19	4	58	2016	3	1
131	20	4	81	2016	3	1
132	21	4	67	2016	3	1
133	22	4	85	2016	3	1
134	18	6	61	2016	3	1
135	19	6	65	2016	3	1
136	20	6	58	2016	3	1
137	21	6	85	2016	3	1
138	22	6	72	2016	3	1
139	1	1	46	2016	1	2
140	2	1	67	2016	1	2
141	3	1	69	2016	1	2
142	4	1	78	2016	1	2
143	5	1	56	2016	1	2
144	1	2	88	2016	1	2
145	2	2	79	2016	1	2
146	3	2	87	2016	1	2
147	4	2	91	2016	1	2
148	5	2	78	2016	1	2
149	6	1	44	2016	1	2
150	7	1	76	2016	1	2
151	8	1	56	2016	1	2
152	9	1	87	2016	1	2
153	6	2	59	2016	1	2
154	7	2	75	2016	1	2
155	8	2	93	2016	1	2
156	9	2	69	2016	1	2
157	10	4	82	2016	1	2
158	11	4	45	2016	1	2
159	12	4	76	2016	1	2
160	13	4	77	2016	1	2
161	23	4	86	2016	1	2
162	10	5	58	2016	1	2
163	11	5	81	2016	1	2
164	12	5	67	2016	1	2
165	13	5	85	2016	1	2
166	23	5	61	2016	1	2
167	14	1	65	2016	1	2
168	15	1	58	2016	1	2
169	16	1	85	2016	1	2
170	17	1	72	2016	1	2
171	14	2	79	2016	1	2
172	15	2	87	2016	1	2
173	16	2	91	2016	1	2
174	17	2	78	2016	1	2
175	18	4	44	2016	1	2
176	19	4	76	2016	1	2
177	20	4	56	2016	1	2
178	21	4	87	2016	1	2
179	22	4	59	2016	1	2
180	18	6	75	2016	1	2
181	19	6	93	2016	1	2
182	20	6	69	2016	1	2
183	21	6	82	2016	1	2
184	22	6	45	2016	1	2
185	1	1	76	2016	2	2
186	2	1	77	2016	2	2
187	3	1	86	2016	2	2
188	4	1	58	2016	2	2
189	5	1	81	2016	2	2
190	1	2	67	2016	2	2
191	2	2	85	2016	2	2
192	3	2	61	2016	2	2
193	4	2	65	2016	2	2
194	5	2	58	2016	2	2
195	6	1	85	2016	2	2
196	7	1	72	2016	2	2
197	8	1	68	2016	2	2
198	9	1	92	2016	2	2
199	6	2	76	2016	2	2
200	7	2	78	2016	2	2
201	8	2	54	2016	2	2
202	9	2	78	2016	2	2
203	10	4	97	2016	2	2
204	11	4	68	2016	2	2
205	12	4	73	2016	2	2
206	13	4	89	2016	2	2
207	23	4	74	2016	2	2
208	10	5	46	2016	2	2
209	11	5	67	2016	2	2
210	12	5	69	2016	2	2
211	13	5	78	2016	2	2
212	23	5	56	2016	2	2
213	14	1	88	2016	2	2
214	15	1	79	2016	2	2
215	16	1	87	2016	2	2
216	17	1	91	2016	2	2
217	14	2	78	2016	2	2
218	15	2	44	2016	2	2
219	16	2	76	2016	2	2
220	17	2	56	2016	2	2
221	18	4	87	2016	2	2
222	19	4	59	2016	2	2
223	20	4	75	2016	2	2
224	21	4	93	2016	2	2
225	22	4	69	2016	2	2
226	18	6	82	2016	2	2
227	19	6	45	2016	2	2
228	20	6	76	2016	2	2
229	21	6	77	2016	2	2
230	22	6	86	2016	2	2
231	1	1	58	2016	3	2
232	2	1	81	2016	3	2
233	3	1	67	2016	3	2
234	4	1	85	2016	3	2
235	5	1	61	2016	3	2
236	1	2	65	2016	3	2
237	2	2	58	2016	3	2
238	3	2	85	2016	3	2
239	4	2	72	2016	3	2
240	5	2	68	2016	3	2
241	6	1	92	2016	3	2
242	7	1	76	2016	3	2
243	8	1	78	2016	3	2
244	9	1	54	2016	3	2
245	6	2	78	2016	3	2
246	7	2	81	2016	3	2
247	8	2	74	2016	3	2
248	9	2	67	2016	3	2
249	10	4	68	2016	3	2
250	11	4	76	2016	3	2
251	12	4	83	2016	3	2
252	13	4	67	2016	3	2
253	23	4	75	2016	3	2
254	10	5	46	2016	3	2
255	11	5	67	2016	3	2
256	12	5	88	2016	3	2
257	13	5	79	2016	3	2
258	23	5	69	2016	3	2
259	14	1	81	2016	3	2
260	15	1	76	2016	3	2
261	16	1	74	2016	3	2
262	17	1	76	2016	3	2
263	14	2	75	2016	3	2
264	15	2	74	2016	3	2
265	16	2	83	2016	3	2
266	17	2	69	2016	3	2
267	18	4	85	2016	3	2
268	19	4	79	2016	3	2
269	20	4	77	2016	3	2
270	21	4	47	2016	3	2
271	22	4	86	2016	3	2
272	18	6	74	2016	3	2
273	19	6	87	2016	3	2
274	20	6	97	2016	3	2
275	21	6	68	2016	3	2
276	22	6	73	2016	3	2
277	1	3	73	2017	1	1
278	2	3	78	2017	1	1
279	3	3	64	2017	1	1
280	4	3	79	2017	1	1
281	5	3	88	2017	1	1
282	1	4	75	2017	1	1
283	2	4	59	2017	1	1
284	3	4	98	2017	1	1
285	4	4	69	2017	1	1
286	5	4	72	2017	1	1
287	6	3	89	2017	1	1
288	7	3	66	2017	1	1
289	8	3	78	2017	1	1
290	9	3	69	2017	1	1
291	6	4	73	2017	1	1
292	7	4	61	2017	1	1
293	8	4	69	2017	1	1
294	9	4	51	2017	1	1
295	10	10	78	2017	1	1
296	11	10	67	2017	1	1
297	12	10	62	2017	1	1
298	13	10	77	2017	1	1
299	11	14	59	2017	1	1
300	12	14	89	2017	1	1
301	13	14	71	2017	1	1
302	10	14	66	2017	1	1
303	14	3	72	2017	1	1
304	15	3	81	2017	1	1
305	16	3	66	2017	1	1
306	17	3	79	2017	1	1
307	14	4	56	2017	1	1
308	15	4	60	2017	1	1
309	16	4	81	2017	1	1
310	17	4	88	2017	1	1
311	18	2	71	2017	1	1
312	19	2	67	2017	1	1
313	20	2	57	2017	1	1
314	21	2	82	2017	1	1
315	22	2	78	2017	1	1
316	18	3	92	2017	1	1
317	19	3	71	2017	1	1
318	20	3	32	2017	1	1
319	21	3	84	2017	1	1
320	22	3	71	2017	1	1
321	23	10	68	2017	1	1
322	23	14	75	2017	1	1
323	1	3	76	2017	2	1
324	2	3	56	2017	2	1
325	3	3	87	2017	2	1
326	4	3	59	2017	2	1
327	5	3	75	2017	2	1
328	1	4	93	2017	2	1
329	2	4	69	2017	2	1
330	3	4	82	2017	2	1
331	4	4	45	2017	2	1
332	5	4	76	2017	2	1
333	6	3	77	2017	2	1
334	7	3	86	2017	2	1
335	8	3	58	2017	2	1
336	9	3	81	2017	2	1
337	6	4	67	2017	2	1
338	7	4	85	2017	2	1
339	8	4	61	2017	2	1
340	9	4	65	2017	2	1
341	10	10	58	2017	2	1
342	11	10	85	2017	2	1
343	12	10	72	2017	2	1
344	13	10	79	2017	2	1
345	11	14	87	2017	2	1
346	12	14	91	2017	2	1
347	13	14	78	2017	2	1
348	10	14	44	2017	2	1
349	14	3	76	2017	2	1
350	15	3	56	2017	2	1
351	16	3	87	2017	2	1
352	17	3	59	2017	2	1
353	14	4	75	2017	2	1
354	15	4	93	2017	2	1
355	16	4	69	2017	2	1
356	17	4	82	2017	2	1
357	18	2	45	2017	2	1
358	19	2	76	2017	2	1
359	20	2	77	2017	2	1
360	21	2	86	2017	2	1
361	22	2	58	2017	2	1
362	18	3	81	2017	2	1
363	19	3	67	2017	2	1
364	20	3	85	2017	2	1
365	21	3	61	2017	2	1
366	22	3	65	2017	2	1
367	23	10	58	2017	2	1
368	23	14	85	2017	2	1
369	1	3	61	2017	3	1
370	2	3	65	2017	3	1
371	3	3	58	2017	3	1
372	4	3	85	2017	3	1
373	5	3	72	2017	3	1
374	1	4	79	2017	3	1
375	2	4	87	2017	3	1
376	3	4	91	2017	3	1
377	4	4	78	2017	3	1
378	5	4	44	2017	3	1
379	6	3	76	2017	3	1
380	7	3	56	2017	3	1
381	8	3	87	2017	3	1
382	9	3	59	2017	3	1
383	6	4	75	2017	3	1
384	7	4	93	2017	3	1
385	8	4	81	2017	3	1
386	9	4	60	2017	3	1
387	10	10	88	2017	3	1
388	11	10	78	2017	3	1
389	12	10	89	2017	3	1
390	13	10	71	2017	3	1
391	11	14	98	2017	3	1
392	12	14	69	2017	3	1
393	13	14	78	2017	3	1
394	10	14	67	2017	3	1
395	14	3	41	2017	3	1
396	15	3	83	2017	3	1
397	16	3	69	2017	3	1
398	17	3	85	2017	3	1
399	14	4	79	2017	3	1
400	15	4	77	2017	3	1
401	16	4	47	2017	3	1
402	17	4	86	2017	3	1
403	18	2	74	2017	3	1
404	19	2	77	2017	3	1
405	20	2	86	2017	3	1
406	21	2	58	2017	3	1
407	22	2	81	2017	3	1
408	18	3	67	2017	3	1
409	19	3	85	2017	3	1
410	20	3	61	2017	3	1
411	21	3	65	2017	3	1
412	22	3	58	2017	3	1
413	23	10	85	2017	3	1
414	23	14	72	2017	3	1
415	1	3	89	2017	1	2
416	2	3	71	2017	1	2
417	3	3	98	2017	1	2
418	4	3	69	2017	1	2
419	5	3	78	2017	1	2
420	1	4	67	2017	1	2
421	2	4	41	2017	1	2
422	3	4	83	2017	1	2
423	4	4	69	2017	1	2
424	5	4	85	2017	1	2
425	6	3	79	2017	1	2
426	7	3	77	2017	1	2
427	8	3	47	2017	1	2
428	9	3	86	2017	1	2
429	6	4	74	2017	1	2
430	7	4	87	2017	1	2
431	8	4	97	2017	1	2
432	9	4	68	2017	1	2
433	10	10	73	2017	1	2
434	11	10	89	2017	1	2
435	12	10	74	2017	1	2
436	13	10	46	2017	1	2
437	11	14	67	2017	1	2
438	12	14	69	2017	1	2
439	13	14	78	2017	1	2
440	10	14	56	2017	1	2
441	14	3	88	2017	1	2
442	15	3	79	2017	1	2
443	16	3	87	2017	1	2
444	17	3	91	2017	1	2
445	14	4	78	2017	1	2
446	15	4	44	2017	1	2
447	16	4	76	2017	1	2
448	17	4	56	2017	1	2
449	18	2	87	2017	1	2
450	19	2	59	2017	1	2
451	20	2	75	2017	1	2
452	21	2	93	2017	1	2
453	22	2	69	2017	1	2
454	18	3	82	2017	1	2
455	19	3	45	2017	1	2
456	20	3	76	2017	1	2
457	21	3	77	2017	1	2
458	22	3	86	2017	1	2
459	23	10	58	2017	1	2
460	23	14	81	2017	1	2
461	1	3	67	2017	2	2
462	2	3	85	2017	2	2
463	3	3	61	2017	2	2
464	4	3	65	2017	2	2
465	5	3	58	2017	2	2
466	1	4	85	2017	2	2
467	2	4	72	2017	2	2
468	3	4	68	2017	2	2
469	4	4	92	2017	2	2
470	5	4	76	2017	2	2
471	6	3	78	2017	2	2
472	7	3	54	2017	2	2
473	8	3	78	2017	2	2
474	9	3	81	2017	2	2
475	6	4	74	2017	2	2
476	7	4	67	2017	2	2
477	8	4	68	2017	2	2
478	9	4	76	2017	2	2
479	10	10	98	2017	2	2
480	11	10	69	2017	2	2
481	12	10	72	2017	2	2
482	13	10	89	2017	2	2
483	11	14	66	2017	2	2
484	12	14	78	2017	2	2
485	13	14	69	2017	2	2
486	10	14	73	2017	2	2
487	14	3	61	2017	2	2
488	15	3	69	2017	2	2
489	16	3	51	2017	2	2
490	17	3	78	2017	2	2
491	14	4	67	2017	2	2
492	15	4	62	2017	2	2
493	16	4	77	2017	2	2
494	17	4	59	2017	2	2
495	18	2	89	2017	2	2
496	19	2	71	2017	2	2
497	20	2	66	2017	2	2
498	21	2	72	2017	2	2
499	22	2	81	2017	2	2
500	18	3	66	2017	2	2
501	19	3	79	2017	2	2
502	20	3	56	2017	2	2
503	21	3	60	2017	2	2
504	22	3	81	2017	2	2
505	23	10	88	2017	2	2
506	23	14	71	2017	2	2
507	1	3	67	2017	3	2
508	2	3	57	2017	3	2
509	3	3	82	2017	3	2
510	4	3	78	2017	3	2
511	5	3	92	2017	3	2
512	1	4	71	2017	3	2
513	2	4	32	2017	3	2
514	3	4	84	2017	3	2
515	4	4	71	2017	3	2
516	5	4	68	2017	3	2
517	6	3	75	2017	3	2
518	7	3	76	2017	3	2
519	8	3	56	2017	3	2
520	9	3	87	2017	3	2
521	6	4	59	2017	3	2
522	7	4	75	2017	3	2
523	8	4	93	2017	3	2
524	9	4	69	2017	3	2
525	10	10	82	2017	3	2
526	11	10	45	2017	3	2
527	12	10	76	2017	3	2
528	13	10	77	2017	3	2
529	11	14	86	2017	3	2
530	12	14	58	2017	3	2
531	13	14	81	2017	3	2
532	10	14	67	2017	3	2
533	14	3	85	2017	3	2
534	15	3	61	2017	3	2
535	16	3	65	2017	3	2
536	17	3	58	2017	3	2
537	14	4	85	2017	3	2
538	15	4	72	2017	3	2
539	16	4	79	2017	3	2
540	17	4	87	2017	3	2
541	18	2	91	2017	3	2
542	19	2	78	2017	3	2
543	20	2	44	2017	3	2
544	21	2	68	2017	3	2
545	22	2	76	2017	3	2
546	18	3	83	2017	3	2
547	19	3	67	2017	3	2
548	20	3	75	2017	3	2
549	21	3	46	2017	3	2
550	22	3	67	2017	3	2
551	23	10	88	2017	3	2
552	23	14	79	2017	3	2
124	17	1	93	2016	3	1
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (id, name, email, dept_id, age, gender, role) FROM stdin;
1	Elango	elango.slnm@gmail.com	1	24	m	1
2	Rosy	rosy@gmail.com	1	23	f	1
3	Praveen	praveen@gmail.com	1	23	m	1
4	Aravind	aravind@gmail.com	1	23	m	1
5	Vijay	vijay@gmail.com	1	23	m	1
6	Sangavi	sangavi@gmail.com	2	22	m	1
7	Kumar	kumar@gmail.com	2	22	m	1
8	Mani	mani@gmail.com	2	22	m	1
9	Raj Kumar	raj@gmail.com	2	22	m	1
10	Senthil	senthil@gmail.com	3	22	m	1
11	Sana	sana@gmail.com	3	22	f	1
12	Chitra	chitra@gmail.com	3	22	f	1
13	Surya	surya@gmail.com	3	22	m	1
14	Meganathan	meg@gmail.com	4	22	m	1
15	Sakthi	sakthi@gmail.com	4	22	m	1
16	Arun kumar	arun@gmail.com	4	22	m	1
17	Suba Ranjana	ranjana@gmail.com	4	21	f	1
18	Samruth	sam@gmail.com	5	23	m	1
19	Sri ka	srika@gmail.com	5	24	f	1
20	Priya	priya@gmail.com	5	23	m	1
21	Laxman	laxman@gmail.com	5	23	m	1
22	Maruthi	maruthi@gmail.com	5	24	m	1
23	Velmurugan	vel@gmail.com	3	24	m	1
24	Sapna	Sapna@gmail.com	1	32	f	2
25	Ashok Kuamr	Ashok@gmail.com	2	39	m	2
26	Shana	Shana@gmail.com	3	39	f	2
27	Santhosh	Santhosh@gmail.com	4	45	m	2
28	Prakash	Prakash@gmail.com	5	42	f	2
29	Ravi Kumar	Ravi@gmail.com	1	31	m	2
30	Shanthi	santhi@gmail.com	2	48	f	2
31	Vengobal	Venu@gmail.com	3	36	m	2
32	Indhu Mathi	Indhu@gmail.com	4	29	f	2
34	Raja	raja@gmail.com	3	35	m	2
35	Thiruna	thiru@gmail.com	5	67	m	2
33	Sarath Kumar	Sarath@gmail.com	2	32	m	2
36	Muralaitharan	murali@gmail.com	5	50	m	2
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (id, name) FROM stdin;
1	student
2	staff
\.


--
-- Data for Name: subject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subject (code, name, staff_id) FROM stdin;
1	java	24
2	python	25
3	Android	26
4	Maths	27
5	Statics	28
6	C++	29
7	dbms	30
8	Accounts	31
9	S\\W Testing	33
10	CAD	34
11	Electronics	35
14	Physics	36
\.


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_id_seq', 6, true);


--
-- Name: exam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exam_id_seq', 1, false);


--
-- Name: marks_sno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marks_sno_seq', 145, true);


--
-- Name: pserson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pserson_id_seq', 36, true);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_id_seq', 2, true);


--
-- Name: subject_code_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subject_code_seq', 14, true);


--
-- Name: department department_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_name_key UNIQUE (name);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: exam exam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam
    ADD CONSTRAINT exam_pkey PRIMARY KEY (id);


--
-- Name: marks mark_ck; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT mark_ck PRIMARY KEY (student_id, sub_code, year, exam_type, part);


--
-- Name: person pserson_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT pserson_email_key UNIQUE (email);


--
-- Name: person pserson_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT pserson_name_key UNIQUE (name);


--
-- Name: person pserson_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT pserson_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: role role_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_role_name_key UNIQUE (name);


--
-- Name: subject subject_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_name_key UNIQUE (name);


--
-- Name: subject subject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (code);


--
-- Name: person dept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT dept_id_fk FOREIGN KEY (dept_id) REFERENCES public.department(id);


--
-- Name: marks e_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT e_type_fk FOREIGN KEY (exam_type) REFERENCES public.exam(id);


--
-- Name: person role_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT role_fk FOREIGN KEY (role) REFERENCES public.role(id);


--
-- Name: subject staff_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT staff_id_fk FOREIGN KEY (staff_id) REFERENCES public.person(id);


--
-- Name: marks student_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT student_id_fk FOREIGN KEY (student_id) REFERENCES public.person(id);


--
-- Name: marks sub_code__fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT sub_code__fk FOREIGN KEY (sub_code) REFERENCES public.subject(code);


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.1 (Debian 12.1-1.pgdg100+1)

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

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

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

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: getinfo_to_json(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getinfo_to_json(vname character varying, vyear integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
result text;
BEGIN
SELECT row_to_json(t) INTO result FROM (SELECT p.name, vyear as year, (SELECT array_to_json(array_agg(row_to_json(d))) FROM (SELECT s.name AS sub_name, e.type AS exam_type, m.mark FROM marks m JOIN subject s ON m.sub_code = s.code JOIN exam e ON e.id = m.exam_type WHERE m.student_id = p.id 
AND m.year = vyear) d) AS details FROM person p WHERE p.name  = vname) t;
RETURN result;
END;
$$;


ALTER FUNCTION public.getinfo_to_json(vname character varying, vyear integer) OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

--
-- Database "tester" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.1 (Debian 12.1-1.pgdg100+1)

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

--
-- Name: tester; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE tester WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE tester OWNER TO postgres;

\connect tester

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: login; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login (
    user_id integer,
    username character(15),
    password character varying(15)
);


ALTER TABLE public.login OWNER TO postgres;

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    user_id integer,
    role character varying(15)
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character(15),
    isactive integer
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: login; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.login (user_id, username, password) FROM stdin;
1	elango         	12345
2	dinesh         	123456
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (user_id, role) FROM stdin;
1	manager
2	employee
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, isactive) FROM stdin;
1	Elango         	1
2	Dinesh         	1
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: login login_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login
    ADD CONSTRAINT login_username_key UNIQUE (username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: login user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login
    ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: role user_id_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT user_id_fk1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

