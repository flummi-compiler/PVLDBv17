SELECT starting_point.xs, force.total
FROM   generate_series(1,10) AS _(i),               -- ╭──────┬╴ /!\ force correlation...
LATERAL (SELECT point(1000 * random(), 1000 * random() + i - i)) AS starting_point(xy),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "G", "Q", "body", "force", "theta", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS float) AS "G",
            CAST(NULL AS barneshut[]) AS "Q",
            CAST(({pos: starting_point.xy, mass: 1.0}) AS struct(pos point, mass float)) AS "body",
            CAST(NULL AS point) AS "force",
            CAST((0.5) AS float) AS "theta",
            CAST(NULL AS point) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "G", "body", "force", "node", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "force", "theta") AS (
            SELECT "G", "Q", "body", "force", "theta"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("G", "body", "force", "node", "theta") AS (
            SELECT CAST((6.67e-11) AS float) AS "G",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((point(0,0)) AS point) AS "force",
                   CAST((SELECT b FROM barneshut AS b WHERE b.node = 0) AS barneshut) AS "node",
                   CAST((("%inputs%"."theta")) AS float) AS "theta"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "G", "body", "force", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "G", "Q", "body", "force", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "body", "force", "node", "theta") AS (
            SELECT "G", "body", "force", "node", "theta"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("G", "Q", "body", "force", "theta") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((array[("%inputs%"."node")]) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((("%inputs%"."theta")) AS float) AS "theta"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "G", "Q", "body", "force", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "G", "Q", "body", "force", "node", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "force", "theta") AS (
            SELECT "G", "Q", "body", "force", "theta"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "G", "Q", "body", "force", "theta"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("G", "Q", "body", "force", "node", "theta") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((("%inputs%"."Q")) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((("%inputs%"."Q")[1]) AS barneshut) AS "node",
                   CAST((("%inputs%"."theta")) AS float) AS "theta"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter4', "G", "Q", "body", "force", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter4"("%kind%", "%label%", "G", "Q", "body", "dir", "dist", "force", "node", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "force", "node", "theta") AS (
            SELECT "G", "Q", "body", "force", "node", "theta"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter4'
          ),
          "%assign%"("G", "Q", "body", "dir", "dist", "force", "node", "theta", "condition%0") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((("%inputs%"."Q")[2:]) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((point(("%inputs%"."node").center.x - ("%inputs%"."body").pos.x, ("%inputs%"."node").center.y - ("%inputs%"."body").pos.y)) AS point) AS "dir",
                   CAST((GREATEST(distance(("%inputs%"."node").center, ("%inputs%"."body").pos), 1e-10)) AS float) AS "dist",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((("%inputs%"."node")) AS barneshut) AS "node",
                   CAST((("%inputs%"."theta")) AS float) AS "theta",
                   CAST((NOT EXISTS (SELECT 1
                                     FROM   walls AS w
                                     WHERE  left_of(("%inputs%"."body").pos, w.wall) <> left_of(("%inputs%"."node").center, w.wall))) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "G", "Q", "body", "dir", "dist", "force", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy0', "G", "Q", "body", "dir", "dist", "force", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
      ),
      "truthy0"("%kind%", "%label%", "G", "Q", "body", "force", "grav", "node", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "dir", "dist", "force", "node", "theta") AS (
            SELECT "G", "Q", "body", "dir", "dist", "force", "node", "theta"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          ),
          "%assign%"("G", "Q", "body", "force", "grav", "node", "theta", "condition%1") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((("%inputs%"."Q")) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((point((("%inputs%"."G") * ("%inputs%"."body").mass * ("%inputs%"."node").mass / ("%inputs%"."dist")^2) * ("%inputs%"."dir").x,
                                                 (("%inputs%"."G") * ("%inputs%"."body").mass * ("%inputs%"."node").mass / ("%inputs%"."dist")^2) * ("%inputs%"."dir").y)) AS point) AS "grav",
                   CAST((("%inputs%"."node")) AS barneshut) AS "node",
                   CAST((("%inputs%"."theta")) AS float) AS "theta",
                   CAST((("%inputs%"."node").node IS NULL OR width(("%inputs%"."node").bbox) / ("%inputs%"."dist") < ("%inputs%"."theta")) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "G", "Q", "body", "force", "grav", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy1', "G", "Q", "body", "force", "grav", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%1"
      ),
      "falsey0"("%kind%", "%label%", "G", "Q", "body", "force", "grav", "node", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "dist", "force", "node", "theta") AS (
            SELECT "G", "Q", "body", "dist", "force", "node", "theta"
            FROM   "inter4"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("G", "Q", "body", "force", "grav", "node", "theta", "condition%2") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((("%inputs%"."Q")) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((point(0,0)) AS point) AS "grav",
                   CAST((("%inputs%"."node")) AS barneshut) AS "node",
                   CAST((("%inputs%"."theta")) AS float) AS "theta",
                   CAST((("%inputs%"."node").node IS NULL OR width(("%inputs%"."node").bbox) / ("%inputs%"."dist") < ("%inputs%"."theta")) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "G", "Q", "body", "force", "grav", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy1', "G", "Q", "body", "force", "grav", "node", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
      ),
      "truthy1"("%kind%", "%label%", "G", "Q", "body", "force", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "force", "grav", "theta") AS (
            SELECT "G", "Q", "body", "force", "grav", "theta"
            FROM   "truthy0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
              UNION ALL
            SELECT "G", "Q", "body", "force", "grav", "theta"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("G", "Q", "body", "force", "theta", "condition%3") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((("%inputs%"."Q")) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((point(("%inputs%"."force").x + ("%inputs%"."grav").x, ("%inputs%"."force").y + ("%inputs%"."grav").y)) AS point) AS "force",
                   CAST((("%inputs%"."theta")) AS float) AS "theta",
                   CAST((len(("%inputs%"."Q")) > 0) AS bool) AS "condition%3"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey2', "G", "Q", "body", "force", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%3"
          UNION ALL
        SELECT 'jump', 'loop_head', "G", "Q", "body", "force", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%3"
      ),
      "falsey1"("%kind%", "%label%", "G", "Q", "body", "force", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "force", "node", "theta") AS (
            SELECT "G", "Q", "body", "force", "node", "theta"
            FROM   "truthy0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
              UNION ALL
            SELECT "G", "Q", "body", "force", "node", "theta"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("G", "Q", "body", "force", "theta") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((SELECT ("%inputs%"."Q") || list(b)
                         FROM   barneshut AS b
                         WHERE  b.parent = ("%inputs%"."node").node) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((("%inputs%"."theta")) AS float) AS "theta"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter11', "G", "Q", "body", "force", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter11"("%kind%", "%label%", "G", "Q", "body", "force", "theta", "%result%") AS (
        WITH
          "%inputs%"("G", "Q", "body", "force", "theta") AS (
            SELECT "G", "Q", "body", "force", "theta"
            FROM   "falsey1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter11'
          ),
          "%assign%"("G", "Q", "body", "force", "theta", "condition%4") AS (
            SELECT CAST((("%inputs%"."G")) AS float) AS "G",
                   CAST((("%inputs%"."Q")) AS barneshut[]) AS "Q",
                   CAST((("%inputs%"."body")) AS struct(pos point, mass float)) AS "body",
                   CAST((("%inputs%"."force")) AS point) AS "force",
                   CAST((("%inputs%"."theta")) AS float) AS "theta",
                   CAST((len(("%inputs%"."Q")) > 0) AS bool) AS "condition%4"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey2', "G", "Q", "body", "force", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%4"
          UNION ALL
        SELECT 'jump', 'loop_head', "G", "Q", "body", "force", "theta", CAST(NULL AS point)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%4"
      ),
      "falsey2"("%kind%", "%label%", "%result%") AS (
        WITH
          "%inputs%"("force") AS (
            SELECT "force"
            FROM   "inter11"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey2'
              UNION ALL
            SELECT "force"
            FROM   "truthy1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey2'
          )
        SELECT 'emit', NULL,
               CAST((("%inputs%"."force")) AS point)
        FROM   "%inputs%"
      )

     SELECT 'jump', "%label%", "G", "Q", "body", "force", "theta", CAST(NULL AS point)
     FROM   "truthy1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "G", "Q", "body", "force", "theta", CAST(NULL AS point)
     FROM   "inter11"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS float), CAST(NULL AS barneshut[]), CAST(NULL AS struct(pos point, mass float)), CAST(NULL AS point), CAST(NULL AS float), "%result%"
     FROM   "falsey2"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS force(total);
