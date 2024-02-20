SELECT clouds.c, giftwrap.hull
FROM   (VALUES (1), (2), (3)) AS clouds(c),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "cloud", "poh", "poh0", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((clouds.c) AS int) AS "cloud",
            CAST(NULL AS points) AS "poh",
            CAST(NULL AS points) AS "poh0",
            CAST(NULL AS int) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "%loop%"("%kind%", "%label%", "cloud", "poh", "poh0", "%result%") AS (
        SELECT * FROM "%loop%"
      ),
      "entry"("%kind%", "%label%", "cloud", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh", "poh0") AS (
            SELECT "cloud", "poh", "poh0"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("cloud", "poh0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((SELECT p
                         FROM   points AS p
                         WHERE  p.cloud = ("%inputs%"."cloud")
                         ORDER BY p.loc[0]
                         LIMIT 1) AS points) AS "poh0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "cloud", "poh0", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "cloud", "poh", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh0") AS (
            SELECT "cloud", "poh0"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("cloud", "poh", "poh0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh0")) AS points) AS "poh",
                   CAST((("%inputs%"."poh0")) AS points) AS "poh0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "cloud", "poh", "poh0", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "cloud", "poh", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh", "poh0") AS (
            SELECT "cloud", "poh", "poh0"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "cloud", "poh", "poh0"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("cloud", "poh", "poh0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh")) AS points) AS "poh",
                   CAST((("%inputs%"."poh0")) AS points) AS "poh0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter2', "cloud", "poh", "poh0", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS points), CAST(NULL AS points),
               CAST(((("%inputs%"."poh")).label) AS int)
        FROM   "%inputs%"
      ),
      "inter2"("%kind%", "%label%", "cloud", "poh", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh", "poh0") AS (
            SELECT "cloud", "poh", "poh0"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter2'
          ),
          "%assign%"("cloud", "poh", "poh0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((SELECT p1
                         FROM   points AS p1
                         WHERE  p1.label <> (("%inputs%"."poh")).label
                         AND    p1.cloud = (("%inputs%"."poh")).cloud
                         AND    NOT EXISTS (SELECT 1
                                            FROM   points AS p2
                                            WHERE  left_of(p2.loc, (("%inputs%"."poh")).loc, p1.loc)
                                            AND    p2.cloud = (("%inputs%"."poh")).cloud)) AS points) AS "poh",
                   CAST((("%inputs%"."poh0")) AS points) AS "poh0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter3', "cloud", "poh", "poh0", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter3"("%kind%", "%label%", "cloud", "poh", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh", "poh0") AS (
            SELECT "cloud", "poh", "poh0"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter3'
          ),
          "%assign%"("cloud", "poh", "poh0", "condition%0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh")) AS points) AS "poh",
                   CAST((("%inputs%"."poh0")) AS points) AS "poh0",
                   CAST((("%inputs%"."poh") = ("%inputs%"."poh0")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "cloud", "poh", "poh0", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      )

     SELECT 'jump', "%label%", "cloud", "poh", "poh0", CAST(NULL AS int)
     FROM   "inter3"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS points), CAST(NULL AS points), "%result%"
     FROM   "loop_head"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS giftwrap(hull);
