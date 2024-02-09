SELECT clouds.c, giftwrap.hull
FROM   (VALUES (1), (2), (3)) AS clouds(c),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((clouds.c) AS int) AS "cloud",
            CAST(NULL AS int) AS "poh0_label",
            CAST(NULL AS int) AS "poh_label",
            CAST(NULL AS int) AS "poh_x",
            CAST(NULL AS int) AS "poh_y",
            CAST(NULL AS int) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "cloud", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("cloud", "poh0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((SELECT p
                         FROM   points AS p
                         WHERE  p.cloud = ("%inputs%"."cloud")
                         ORDER BY p.x
                         LIMIT 1) AS struct(cloud int, label int, x int, y int)) AS "poh0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "cloud", "poh0", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh0") AS (
            SELECT "cloud", "poh0"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("cloud", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh0").label) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh0").label) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh0").x) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh0").y) AS int) AS "poh_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter5"("%kind%", "%label%", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh", "poh0_label") AS (
            SELECT "cloud", "poh", "poh0_label"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter5'
          ),
          "%assign%"("cloud", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh").label) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh").x) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh").y) AS int) AS "poh_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter9', "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter9"("%kind%", "%label%", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter9'
          ),
          "%assign%"("cloud", "poh0_label", "poh_label", "poh_x", "poh_y", "condition%0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh_label")) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh_x")) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh_y")) AS int) AS "poh_y",
                   CAST((("%inputs%"."poh_label") = ("%inputs%"."poh0_label")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      ),
      "loop_head"("%kind%", "%label%", "cloud", "poh", "poh0_label", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("cloud", "poh0_label", "poh_label", "poh_x", "poh_y") AS MATERIALIZED (
            SELECT "cloud", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "cloud", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("cloud", "poh", "poh0_label") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((SELECT p1
                         FROM   points AS p1
                         WHERE  p1.cloud = ("%inputs%"."cloud")
                         AND    p1.label <> ("%inputs%"."poh_label")
                         AND    NOT EXISTS (SELECT 1
                                            FROM   points AS p2
                                            WHERE  left_of(p2.x, p2.y, ("%inputs%"."poh_x"), ("%inputs%"."poh_y"), p1.x, p1.y)
                                            AND    p2.cloud = ("%inputs%"."cloud"))) AS struct(cloud int, label int, x int, y int)) AS "poh",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter5', "cloud", "poh", "poh0_label", CAST(NULL AS int)
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS struct(cloud int, label int, x int, y int)), CAST(NULL AS int),
               CAST((("%inputs%"."poh_label")) AS int)
        FROM   "%inputs%"
      )

     SELECT 'jump', "%label%", "cloud", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS int)
     FROM   "inter9"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "loop_head"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS giftwrap(hull);
