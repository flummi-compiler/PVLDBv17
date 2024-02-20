SELECT x, visible."?"
FROM   range(100) AS _(x),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS float) AS "angle",
            CAST(((x,0)) AS point) AS "here",
            CAST(NULL AS float) AS "hhere",
            CAST(NULL AS int) AS "i",
            CAST(NULL AS point) AS "loc",
            CAST(NULL AS float) AS "max_angle",
            CAST((256) AS int) AS "resolution",
            CAST(NULL AS point) AS "step",
            CAST(((x,99)) AS point) AS "there",
            CAST(NULL AS bool) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "loop_head"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "condition%0") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."loc")) AS point) AS "loc",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there",
                   CAST((("%inputs%"."i") > ("%inputs%"."resolution")) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "entry"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((SELECT SUM(s.z * (2-dist)^2) / SUM((2-dist)^2) AS hhere
                         FROM   surface AS s, LATERAL (SELECT (sqrt((s.x-("%inputs%"."here").x)^2 + (s.y-("%inputs%"."here").y)^2))) AS _(dist)
                         WHERE  dist < 2) AS float) AS "hhere",
                   CAST((1) AS int) AS "i",
                   CAST((("%inputs%"."here")) AS point) AS "loc",
                   CAST((NULL :: float) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((((("%inputs%"."there").x - ("%inputs%"."here").x) / ("%inputs%"."resolution"), (("%inputs%"."there").y - ("%inputs%"."here").y) / ("%inputs%"."resolution")) :: point) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter3', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter3"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter3'
          ),
          "%assign%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "condition%1") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."loc")) AS point) AS "loc",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there",
                   CAST((("%inputs%"."i") > ("%inputs%"."resolution")) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy0', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("angle", "max_angle") AS (
            SELECT "angle", "max_angle"
            FROM   "inter3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
              UNION ALL
            SELECT "angle", "max_angle"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."angle") = ("%inputs%"."max_angle")) AS bool)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "inter3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
              UNION ALL
            SELECT "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i") + 1) AS int) AS "i",
                   CAST(((("%inputs%"."loc").x + ("%inputs%"."step").x, ("%inputs%"."loc").y + ("%inputs%"."step").y) :: point) AS point) AS "loc",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter6', "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter6"("%kind%", "%label%", "here", "hhere", "hloc", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter6'
          ),
          "%assign%"("here", "hhere", "hloc", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((SELECT SUM(s.z * (2-dist)^2) / SUM((2-dist)^2) AS hhere
                         FROM   surface AS s, LATERAL (SELECT (sqrt((s.x-("%inputs%"."loc").x)^2 + (s.y-("%inputs%"."loc").y)^2))) AS _(dist)
                         WHERE  dist < 2) AS float) AS "hloc",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."loc")) AS point) AS "loc",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter7', "here", "hhere", "hloc", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter7"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("here", "hhere", "hloc", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "here", "hhere", "hloc", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "inter6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter7'
          ),
          "%assign%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT CAST((degrees(atan((("%inputs%"."hloc") - ("%inputs%"."hhere")) / sqrt((("%inputs%"."loc").x - ("%inputs%"."here").x) ** 2 + (("%inputs%"."loc").y - ("%inputs%"."here").y) ** 2)))) AS float) AS "angle",
                   CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."loc")) AS point) AS "loc",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter9', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter9"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there"
            FROM   "inter7"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter9'
          ),
          "%assign%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "condition%2") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."loc")) AS point) AS "loc",
                   CAST((("%inputs%"."max_angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there",
                   CAST((("%inputs%"."max_angle") IS NULL OR ("%inputs%"."angle") > ("%inputs%"."max_angle")) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'truthy1', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
          UNION ALL
        SELECT 'jump', 'loop_head', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
      ),
      "truthy1"("%kind%", "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", "%result%") AS (
        WITH
          "%inputs%"("angle", "here", "hhere", "i", "loc", "resolution", "step", "there") AS (
            SELECT "angle", "here", "hhere", "i", "loc", "resolution", "step", "there"
            FROM   "inter9"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there") AS (
            SELECT CAST((("%inputs%"."angle")) AS float) AS "angle",
                   CAST((("%inputs%"."here")) AS point) AS "here",
                   CAST((("%inputs%"."hhere")) AS float) AS "hhere",
                   CAST((("%inputs%"."i")) AS int) AS "i",
                   CAST((("%inputs%"."loc")) AS point) AS "loc",
                   CAST((("%inputs%"."angle")) AS float) AS "max_angle",
                   CAST((("%inputs%"."resolution")) AS int) AS "resolution",
                   CAST((("%inputs%"."step")) AS point) AS "step",
                   CAST((("%inputs%"."there")) AS point) AS "there"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
     FROM   "inter9"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "angle", "here", "hhere", "i", "loc", "max_angle", "resolution", "step", "there", CAST(NULL AS bool)
     FROM   "truthy1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS float), CAST(NULL AS point), CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS point), CAST(NULL AS float), CAST(NULL AS int), CAST(NULL AS point), CAST(NULL AS point), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS visible("?");
