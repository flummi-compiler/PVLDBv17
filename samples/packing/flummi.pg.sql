SELECT o.o_orderkey, pack_order.pack
FROM   orders AS o,
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((60) AS int) AS "capacity",
            CAST(NULL AS int) AS "items",
            CAST(NULL AS int) AS "linenumber",
            CAST(NULL AS int) AS "max_size",
            CAST(NULL AS int) AS "max_subset",
            CAST(NULL AS int) AS "n",
            CAST((o.o_orderkey) AS int) AS "orderkey",
            CAST(NULL AS text) AS "pack",
            CAST(NULL AS int) AS "subset",
            CAST(NULL AS text) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "%loop%"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        SELECT * FROM "%loop%"
      ),
      "entry"("%kind%", "%label%", "capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((SELECT COUNT(*) :: int FROM lineitem AS l WHERE l.l_orderkey = ("%inputs%"."orderkey")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter0', "capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter0"("%kind%", "%label%", "capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter0'
          ),
          "%assign%"("capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "condition%0") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset",
                   CAST((("%inputs%"."n") = 0 OR capacity < (SELECT MAX(p.p_size) FROM lineitem AS l, part AS p WHERE l.l_orderkey = ("%inputs%"."orderkey") AND l.l_partkey = p.p_partkey)) AS bool) AS "condition%0"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey0', "capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0"
      ),
      "falsey0"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "inter0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey0'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST(((1 << ("%inputs%"."n")) - 1) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'goto', 'outer_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "outer_head"("%kind%", "%label%", "capacity", "items", "linenumber", "n", "orderkey", "pack", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='outer_head'
              UNION ALL
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "falsey0"
            WHERE  "%kind%"='goto'
            AND    "%label%"='outer_head'
          ),
          "%assign%"("capacity", "items", "linenumber", "n", "orderkey", "pack", "condition%1") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."items") = 0) AS bool) AS "condition%1"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey1', "capacity", "items", "linenumber", "n", "orderkey", "pack", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%1"
      ),
      "falsey1"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "n", "orderkey", "pack") AS (
            SELECT "capacity", "items", "linenumber", "n", "orderkey", "pack"
            FROM   "outer_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey1'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((0) AS int) AS "max_size",
                   CAST((0) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."items") & -("%inputs%"."items")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inner_1_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inner_1_head"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='inner_1_head'
              UNION ALL
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "falsey1"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inner_1_head'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((SELECT SUM(p.p_size) :: int FROM lineitem AS l, part AS p WHERE l.l_orderkey = ("%inputs%"."orderkey") AND ("%inputs%"."subset") & (1 << l.l_linenumber - 1) <> 0 AND l.l_partkey = p.p_partkey) AS int) AS "size",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter5', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter5"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset"
            FROM   "inner_1_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter5'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", "condition%2", "condition%3") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."size")) AS int) AS "size",
                   CAST((("%inputs%"."subset")) AS int) AS "subset",
                   CAST((("%inputs%"."size") <= ("%inputs%"."capacity") AND ("%inputs%"."size") > ("%inputs%"."max_size")) AS bool) AS "condition%2",
                   CAST((("%inputs%"."subset") = ("%inputs%"."items")) AS bool) AS "condition%3"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey3', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2" AND NOT "condition%3"
          UNION ALL
        SELECT 'goto', 'truthy2', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy3', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "size", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%2" AND "condition%3"
      ),
      "truthy2"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "n", "orderkey", "pack", "size", "subset") AS (
            SELECT "capacity", "items", "linenumber", "n", "orderkey", "pack", "size", "subset"
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy2'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "condition%4") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."size")) AS int) AS "max_size",
                   CAST((("%inputs%"."subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset",
                   CAST((("%inputs%"."subset") = ("%inputs%"."items")) AS bool) AS "condition%4"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey3', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%4"
          UNION ALL
        SELECT 'goto', 'truthy3', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%4"
      ),
      "truthy3"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "max_size", "max_subset", "n", "orderkey", "subset") AS (
            SELECT "capacity", "items", "max_size", "max_subset", "n", "orderkey", "subset"
            FROM   "truthy2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy3'
              UNION ALL
            SELECT "capacity", "items", "max_size", "max_subset", "n", "orderkey", "subset"
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy3'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((0) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST(('') AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inner_2_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inner_2_head"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='inner_2_head'
              UNION ALL
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "truthy3"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inner_2_head'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber") + 1) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter12', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter12"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "inner_2_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter12'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "condition%5", "condition%6") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset",
                   CAST((("%inputs%"."linenumber") > ("%inputs%"."n")) AS bool) AS "condition%5",
                   CAST((("%inputs%"."max_subset") & (1 << ("%inputs%"."linenumber") - 1) <> 0) AS bool) AS "condition%6"
            FROM "%inputs%"
          )

        SELECT 'goto', 'falsey5', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%5" AND NOT "condition%6"
          UNION ALL
        SELECT 'goto', 'truthy4', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%5"
          UNION ALL
        SELECT 'goto', 'truthy5', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%5" AND "condition%6"
      ),
      "truthy5"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "inter12"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy5'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack") || '#') AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'jump', 'inner_2_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy4"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "inter12"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy4'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items") & ~("%inputs%"."max_subset")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'jump', 'outer_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS text), CAST(NULL AS int),
               CAST((("%inputs%"."pack")) AS text)
        FROM   "%inputs%"
      ),
      "falsey5"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "inter12"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey5'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack") || '.') AS text) AS "pack",
                   CAST((("%inputs%"."subset")) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'jump', 'inner_2_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "falsey3"("%kind%", "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", "%result%") AS (
        WITH
          "%inputs%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "truthy2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey3'
              UNION ALL
            SELECT "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset"
            FROM   "inter5"
            WHERE  "%kind%"='goto'
            AND    "%label%"='falsey3'
          ),
          "%assign%"("capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset") AS (
            SELECT CAST((("%inputs%"."capacity")) AS int) AS "capacity",
                   CAST((("%inputs%"."items")) AS int) AS "items",
                   CAST((("%inputs%"."linenumber")) AS int) AS "linenumber",
                   CAST((("%inputs%"."max_size")) AS int) AS "max_size",
                   CAST((("%inputs%"."max_subset")) AS int) AS "max_subset",
                   CAST((("%inputs%"."n")) AS int) AS "n",
                   CAST((("%inputs%"."orderkey")) AS int) AS "orderkey",
                   CAST((("%inputs%"."pack")) AS text) AS "pack",
                   CAST((("%inputs%"."items") & (("%inputs%"."subset") - ("%inputs%"."items"))) AS int) AS "subset"
            FROM "%inputs%"
          )

        SELECT 'jump', 'inner_1_head', "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
     FROM   "falsey3"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
     FROM   "truthy4"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
     FROM   "truthy5"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "capacity", "items", "linenumber", "max_size", "max_subset", "n", "orderkey", "pack", "subset", CAST(NULL AS text)
     FROM   "falsey5"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS int), CAST(NULL AS text), CAST(NULL AS int), "%result%"
     FROM   "truthy4"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit'
) AS pack_order(pack)
WHERE o.o_orderstatus = 'F';
