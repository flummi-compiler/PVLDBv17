SELECT clouds.c, giftwrap.hull
FROM   (VALUES (1), (2), (3)) AS clouds(c),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((clouds.c) AS int) AS "cloud",
            CAST(NULL AS text) AS "hull",
            CAST(NULL AS int) AS "poh0_label",
            CAST(NULL AS int) AS "poh_label",
            CAST(NULL AS int) AS "poh_x",
            CAST(NULL AS int) AS "poh_y",
            CAST(NULL AS text) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "cloud", "poh0", "%result%") AS (
        WITH
          "%inputs%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("cloud", "poh0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((SELECT (p.label :: bigint << 32) | (p.x << 16) | p.y
                         FROM   points AS p
                         WHERE  p.cloud = ("%inputs%"."cloud")
                         ORDER BY p.x
                         LIMIT 1) AS bigint) AS "poh0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "cloud", "poh0", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "cloud", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh0") AS (
            SELECT "cloud", "poh0"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("cloud", "poh_label", "poh_x", "poh_y") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."poh0") >> 32) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh0") >> 16 & 65535) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh0")       & 65535) AS int) AS "poh_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter1', "cloud", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter1"("%kind%", "%label%", "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "poh_label", "poh_x", "poh_y"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter1'
          ),
          "%assign%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST(('p' || ("%inputs%"."poh_label") :: text) AS text) AS "hull",
                   CAST((("%inputs%"."poh_label")) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh_label")) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh_x")) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh_y")) AS int) AS "poh_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "cloud", "hull", "poh0_label", "poh1", "%result%") AS (
        WITH
          "%inputs%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "inter1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("cloud", "hull", "poh0_label", "poh1") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."hull")) AS text) AS "hull",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label",
                   CAST((SELECT (p1.label :: bigint << 32) | (p1.x << 16) | p1.y
                         FROM   points AS p1
                         WHERE  p1.label <> ("%inputs%"."poh_label")
                         AND    p1.cloud = ("%inputs%"."cloud")
                         AND    NOT EXISTS (SELECT 1
                                            FROM   points AS p2
                                            WHERE  (("%inputs%"."poh_x") - p2.x) * (p1.y - p2.y) -
                                                   (("%inputs%"."poh_y") - p2.y) * (p1.x - p2.x) > 0
                                            AND    p2.cloud = ("%inputs%"."cloud"))) AS bigint) AS "poh1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter6', "cloud", "hull", "poh0_label", "poh1", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter6"("%kind%", "%label%", "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "hull", "poh0_label", "poh1") AS (
            SELECT "cloud", "hull", "poh0_label", "poh1"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter6'
          ),
          "%assign%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."hull")) AS text) AS "hull",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh1") >> 32) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh1") >> 16 & 65535) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh1")       & 65535) AS int) AS "poh_y"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter8', "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter8"("%kind%", "%label%", "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "inter6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter8'
          ),
          "%assign%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", "condition%0") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."hull")) AS text) AS "hull",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh_label")) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh_x")) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh_y")) AS int) AS "poh_y",
                   CAST((("%inputs%"."poh_label") = ("%inputs%"."poh0_label")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("hull") AS (
            SELECT "hull"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."hull")) AS text)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", "%result%") AS (
        WITH
          "%inputs%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y") AS (
            SELECT CAST((("%inputs%"."cloud")) AS int) AS "cloud",
                   CAST((("%inputs%"."hull") || '|' || 'p' || ("%inputs%"."poh_label")) AS text) AS "hull",
                   CAST((("%inputs%"."poh0_label")) AS int) AS "poh0_label",
                   CAST((("%inputs%"."poh_label")) AS int) AS "poh_label",
                   CAST((("%inputs%"."poh_x")) AS int) AS "poh_x",
                   CAST((("%inputs%"."poh_y")) AS int) AS "poh_y"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "cloud", "hull", "poh0_label", "poh_label", "poh_x", "poh_y", CAST(NULL AS text)
     FROM   "falsey0"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS text), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS giftwrap(hull);
