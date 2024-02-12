SELECT o.o_orderkey, schedule.item
FROM   orders AS o
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST(NULL AS struct(start date, finish date)[]) AS "busy",
            CAST(NULL AS struct(items int, last_shipdate date)) AS "details",
            CAST(NULL AS date) AS "item_end",
            CAST(NULL AS date) AS "item_start",
            CAST(NULL AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST(NULL AS int) AS "priority",
            CAST(NULL AS date) AS "schedule_end",
            CAST(NULL AS date) AS "schedule_start",
            CAST(NULL AS struct(item int, start date)) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "outer_loop_head"("%kind%", "%label%", "busy", "details", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='outer_loop_head'
          ),
          "%assign%"("busy", "details", "orderkey", "priority", "schedule_end", "schedule_start", "condition%0") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start",
                   CAST((("%inputs%"."priority") > ("%inputs%"."details").items) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "busy", "details", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      ),
      "entry"("%kind%", "%label%", "orderkey", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("orderkey", "schedule_start") AS (
            SELECT CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((SELECT o.o_orderdate
                         FROM   orders AS o
                         WHERE  o.o_orderkey = ("%inputs%"."orderkey")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "orderkey", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "orderkey", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("orderkey", "schedule_start") AS (
            SELECT "orderkey", "schedule_start"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("orderkey", "schedule_start", "condition%1") AS (
            SELECT CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start",
                   CAST((("%inputs%"."schedule_start") IS NULL) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "orderkey", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
      ),
      "falsey0"("%kind%", "%label%", "busy", "details", "orderkey", "priority", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("orderkey", "schedule_start") AS (
            SELECT "orderkey", "schedule_start"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("busy", "details", "orderkey", "priority", "schedule_start") AS (
            SELECT CAST((ARRAY[] :: struct(start date, finish date)[]) AS struct(start date, finish date)[]) AS "busy",
                   CAST((SELECT {items: COUNT(*), last_shipdate: MAX(l.l_shipdate)}
                         FROM   lineitem AS l
                         WHERE  l.l_orderkey = ("%inputs%"."orderkey")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((1) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter1', "busy", "details", "orderkey", "priority", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter1"("%kind%", "%label%", "busy", "details", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "orderkey", "priority", "schedule_start") AS (
            SELECT "busy", "details", "orderkey", "priority", "schedule_start"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter1'
          ),
          "%assign%"("busy", "details", "orderkey", "priority", "schedule_end", "schedule_start", "condition%2") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."details").last_shipdate) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start",
                   CAST((("%inputs%"."priority") > ("%inputs%"."details").items) AS bool) AS "condition%2"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "busy", "details", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2"
      ),
      "falsey1"("%kind%", "%label%", "busy", "details", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inter1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
              UNION ALL
            SELECT "busy", "details", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "outer_loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("busy", "details", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((SELECT l.lineitem
                         FROM   (SELECT ROW_NUMBER() OVER (ORDER BY p.p_retailprice),
                                        {l_linenumber: l.l_linenumber,
                                         l_shipdate:   l.l_shipdate,
                                         l_quantity:   l.l_quantity}
                                 FROM   lineitem AS l, part AS p
                                 WHERE  l.l_orderkey = ("%inputs%"."orderkey")
                                 AND    l.l_partkey = p.p_partkey) AS l(priority, lineitem)
                         WHERE   l.priority = ("%inputs%"."priority")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter5', "busy", "details", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter5"("%kind%", "%label%", "busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "falsey1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter5'
          ),
          "%assign%"("busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((LEAST(("%inputs%"."lineitem").l_shipdate, ("%inputs%"."schedule_end"))) AS date) AS "item_end",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter6', "busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter6"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter6'
          ),
          "%assign%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."item_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."item_end") - ("%inputs%"."lineitem").l_quantity :: int) AS date) AS "item_start",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inner_loop_head', "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inner_loop_head"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='inner_loop_head'
              UNION ALL
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inter6"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inner_loop_head'
          ),
          "%assign%"("busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."item_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."item_start")) AS date) AS "item_start",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((SELECT slot.start
                         FROM   unnest(("%inputs%"."busy")) AS _(slot)
                         WHERE  slot.start < ("%inputs%"."item_end")
                         AND    ("%inputs%"."item_start") < slot.finish
                         ORDER BY (slot.start, slot.finish)
                         LIMIT  1) AS date) AS "new_end",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter8', "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter8"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inner_loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter8'
          ),
          "%assign%"("busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", "condition%3", "condition%4") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."item_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."item_start")) AS date) AS "item_start",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."new_end")) AS date) AS "new_end",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start",
                   CAST((("%inputs%"."item_start") >= ("%inputs%"."schedule_start") AND ("%inputs%"."new_end") IS NOT NULL) AS bool) AS "condition%3",
                   CAST((("%inputs%"."item_start") >= ("%inputs%"."schedule_start")) AS bool) AS "condition%4"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge3', "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%3" AND NOT "condition%4"
          UNION ALL
        SELECT 'goto', 'truthy2', "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE AND "condition%3"
          UNION ALL
        SELECT 'goto', 'truthy3', "busy", "details", "item_end", "item_start", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%3" AND "condition%4"
      ),
      "truthy3"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy3'
          ),
          "%assign%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((list_append(("%inputs%"."busy"), (("%inputs%"."item_start"), ("%inputs%"."item_end")))) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."item_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."item_start")) AS date) AS "item_start",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'merge3', "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS struct(start date, finish date)[]), CAST(NULL AS struct(items int, last_shipdate date)), CAST(NULL AS date), CAST(NULL AS date), CAST(NULL AS struct(l_linenumber int, l_shipdate date, l_quantity double)), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS date), CAST(NULL AS date),
               CAST(((("%inputs%"."lineitem").l_linenumber, ("%inputs%"."item_start"))) AS struct(item int, start date))
        FROM   "%inputs%"
      ),
      "merge3"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "truthy3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge3'
              UNION ALL
            SELECT "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='merge3'
          ),
          "%assign%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."item_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."item_start")) AS date) AS "item_start",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority") + 1) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'jump', 'outer_loop_head', "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy2"("%kind%", "%label%", "busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "lineitem", "new_end", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "inter8"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy2'
          ),
          "%assign%"("busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."new_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter9', "busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter9"("%kind%", "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", "%result%") AS (
        WITH
          "%inputs%"("busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT "busy", "details", "item_end", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start"
            FROM   "truthy2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter9'
          ),
          "%assign%"("busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start") AS (
            SELECT CAST((("%inputs%"."busy")) AS struct(start date, finish date)[]) AS "busy",
                   CAST((("%inputs%"."details")) AS struct(items int, last_shipdate date)) AS "details",
                   CAST((("%inputs%"."item_end")) AS date) AS "item_end",
                   CAST((("%inputs%"."item_end") - ("%inputs%"."lineitem").l_quantity :: int) AS date) AS "item_start",
                   CAST((("%inputs%"."lineitem")) AS struct(l_linenumber int, l_shipdate date, l_quantity double)) AS "lineitem",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."priority")) AS int) AS "priority",
                   CAST((("%inputs%"."schedule_end")) AS date) AS "schedule_end",
                   CAST((("%inputs%"."schedule_start")) AS date) AS "schedule_start"
            FROM "%inputs%"
          )

        SELECT 'jump', 'inner_loop_head', "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
     FROM   "inter9"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "busy", "details", "item_end", "item_start", "lineitem", "orderkey", "priority", "schedule_end", "schedule_start", CAST(NULL AS struct(item int, start date))
     FROM   "merge3"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS struct(start date, finish date)[]), CAST(NULL AS struct(items int, last_shipdate date)), CAST(NULL AS date), CAST(NULL AS date), CAST(NULL AS struct(l_linenumber int, l_shipdate date, l_quantity double)), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS date), CAST(NULL AS date), "%result%"
     FROM   "truthy3"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS schedule(item)
WHERE  o.o_orderstatus = 'O';
