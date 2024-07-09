SELECT list, "is distinct?"
FROM   (VALUES ('1,2,2,3,4'),
               ('1,2,3,4,5')) AS _(list),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "delim", "list", "pos", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((',') AS char) AS "delim",
            CAST((_.list) AS text) AS "list",
            CAST(NULL AS int) AS "pos",
            CAST(NULL AS bool) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "delim", "list", "%result%") AS (
        WITH
          "%inputs%"("delim", "list", "pos") AS (
            SELECT "delim", "list", "pos"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("delim", "list") AS (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((trim(("%inputs%"."list")) || ("%inputs%"."delim")) AS text) AS "list"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "delim", "list", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "delim", "list", "pos", "%result%") AS (
        WITH
          "%inputs%"("delim", "list") AS (
            SELECT "delim", "list"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("delim", "list", "pos") AS (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((("%inputs%"."list")) AS text) AS "list",
                   CAST((strpos(("%inputs%"."list"), ("%inputs%"."delim"))) AS int) AS "pos"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "delim", "list", "pos", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "delim", "list", "pos", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("delim", "list", "pos") AS (
            SELECT "delim", "list", "pos"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "delim", "list", "pos"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("delim", "list", "pos", "condition%0") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((("%inputs%"."list")) AS text) AS "list",
                   CAST((("%inputs%"."pos")) AS int) AS "pos",
                   CAST((("%inputs%"."pos") <= 0) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "delim", "list", "pos", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "delim", "list", "pos", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("%") AS (
            SELECT NULL
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          )
        SELECT 'emit', NULL,
               CAST((TRUE) AS int)
        FROM   "%inputs%"
      ),
      "falsey0"("%kind%", "%label%", "delim", "list", "part", "pos", "%result%") AS (
        WITH
          "%inputs%"("delim", "list", "pos") AS (
            SELECT "delim", "list", "pos"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("delim", "list", "part", "pos") AS (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((("%inputs%"."list")) AS text) AS "list",
                   CAST((trim(left(("%inputs%"."list"), ("%inputs%"."pos")))) AS text) AS "part",
                   CAST((("%inputs%"."pos")) AS int) AS "pos"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge0', "delim", "list", "part", "pos", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "merge0"("%kind%", "%label%", "delim", "list", "part", "%result%") AS (
        WITH
          "%inputs%"("delim", "list", "part", "pos") AS (
            SELECT "delim", "list", "part", "pos"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge0'
          ),
          "%assign%"("delim", "list", "part") AS (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((substring(("%inputs%"."list"), ("%inputs%"."pos") + 1, len(("%inputs%"."list")))) AS text) AS "list",
                   CAST((("%inputs%"."part")) AS text) AS "part"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter5', "delim", "list", "part", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter5"("%kind%", "%label%", "delim", "list", "%result%") AS MATERIALIZED (
        WITH
          "%inputs%"("delim", "list", "part") AS (
            SELECT "delim", "list", "part"
            FROM   "merge0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter5'
          ),
          "%assign%"("delim", "list", "condition%1") AS MATERIALIZED (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((("%inputs%"."list")) AS text) AS "list",
                   CAST((strpos(("%inputs%"."list"), ("%inputs%"."part")) <> 0) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "delim", "list", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy1', "delim", "list", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
      ),
      "truthy1"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("%") AS (
            SELECT NULL
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          )
        SELECT 'emit', NULL,
               CAST((FALSE) AS int)
        FROM   "%inputs%"
      ),
      "falsey1"("%kind%", "%label%", "delim", "list", "pos", "%result%") AS (
        WITH
          "%inputs%"("delim", "list") AS (
            SELECT "delim", "list"
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("delim", "list", "pos") AS (
            SELECT CAST((("%inputs%"."delim")) AS char) AS "delim",
                   CAST((("%inputs%"."list")) AS text) AS "list",
                   CAST((strpos(("%inputs%"."list"), ("%inputs%"."delim"))) AS int) AS "pos"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "delim", "list", "pos", CAST(NULL AS bool)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "delim", "list", "pos", CAST(NULL AS bool)
     FROM   "falsey1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS char), CAST(NULL AS text), CAST(NULL AS int), "%result%"
     FROM   "truthy0"
     WHERE  "%kind%"='emit'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS char), CAST(NULL AS text), CAST(NULL AS int), "%result%"
     FROM   "truthy1"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS __("is distinct?");
