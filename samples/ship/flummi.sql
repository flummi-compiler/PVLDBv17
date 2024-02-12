SELECT c.c_custkey, preferred_shipmode.mode
FROM   customer AS c,
LATERAL (
WITH
  "%loop%"("%kind%", "%label%", "custkey", "%result%") AS (
    SELECT 'jump' AS "%kind%",
           'entry' AS "%label%",
           CAST((c.c_custkey) AS int) AS "custkey",
           CAST(NULL AS text) AS "%result%"
   ),"entry"("%kind%", "%label%", "air", "ground", "mail", "%result%") AS (
     WITH
       "%inputs%"("custkey") AS (
         SELECT "custkey"
         FROM   "%loop%"
         WHERE  "%kind%"='jump'
         AND    "%label%"='entry'
       ),
       "%assign%"("air", "ground", "mail") AS (
         SELECT CAST((SELECT COUNT(*)
                      FROM   lineitem AS l, orders AS o
                      WHERE  l.l_orderkey = o.o_orderkey AND o.o_custkey = ("%inputs%"."custkey")
                      AND    l.l_shipmode IN ('AIR', 'AIR REG')) AS int) AS "air",
                CAST((SELECT COUNT(*)
                      FROM   lineitem AS l, orders AS o
                      WHERE  l.l_orderkey = o.o_orderkey AND o.o_custkey = ("%inputs%"."custkey")
                      AND    l.l_shipmode IN ('RAIL', 'TRUCK')) AS int) AS "ground",
                CAST((SELECT COUNT(*)
                      FROM   lineitem AS l, orders AS o
                      WHERE  l.l_orderkey = o.o_orderkey AND o.o_custkey = ("%inputs%"."custkey")
                      AND    l.l_shipmode = 'MAIL') AS int) AS "mail"
         FROM "%inputs%"
       )

     SELECT 'goto', 'inter1', "air", "ground", "mail", CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE
   ),
   "inter1"("%kind%", "%label%", "%result%") AS (
     WITH
       "%inputs%"("air", "ground", "mail") AS (
         SELECT "air", "ground", "mail"
         FROM   "entry"
         WHERE  "%kind%"='goto'
         AND    "%label%"='inter1'
       ),
       "%assign%"("condition%0", "condition%1", "condition%2") AS (
         SELECT CAST((("%inputs%"."ground") >= ("%inputs%"."air") AND ("%inputs%"."ground") >= ("%inputs%"."mail")) AS bool) AS "condition%0",
                CAST((("%inputs%"."air") >= ("%inputs%"."ground") AND ("%inputs%"."air") >= ("%inputs%"."mail")) AS bool) AS "condition%1",
                CAST((("%inputs%"."mail") >= ("%inputs%"."ground") AND ("%inputs%"."mail") >= ("%inputs%"."air")) AS bool) AS "condition%2"
         FROM "%inputs%"
       )

     SELECT 'goto', 'truthy0', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND "condition%0"
       UNION ALL
     SELECT 'goto', 'truthy1', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND NOT "condition%0" AND "condition%1"
       UNION ALL
     SELECT 'goto', 'truthy2', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND "condition%2"
   ),
   "truthy2"("%kind%", "%label%", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter1"
         WHERE  "%kind%"='goto'
         AND    "%label%"='truthy2'
       )
     SELECT 'emit', NULL,
            CAST(('mail') AS text)
     FROM   "%inputs%"
   ),
   "truthy1"("%kind%", "%label%", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter1"
         WHERE  "%kind%"='goto'
         AND    "%label%"='truthy1'
       )
     SELECT 'emit', NULL,
            CAST(('air') AS text)
     FROM   "%inputs%"
   ),
   "truthy0"("%kind%", "%label%", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter1"
         WHERE  "%kind%"='goto'
         AND    "%label%"='truthy0'
       )
     SELECT 'emit', NULL,
            CAST(('ground') AS text)
     FROM   "%inputs%"
   )

SELECT "%result%"
FROM   "truthy0"
WHERE  "%kind%"='emit'
  UNION ALL
SELECT "%result%"
FROM   "truthy1"
WHERE  "%kind%"='emit'
  UNION ALL
SELECT "%result%"
FROM   "truthy2"
WHERE  "%kind%"='emit'
) AS preferred_shipmode(mode);
