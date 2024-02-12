SELECT c.c_custkey, preferred_shipmode.mode
FROM   customer AS c,
LATERAL (
SELECT "ifresult7".*
FROM LATERAL
      (WITH "let3"("ground_1") AS MATERIALIZED
      (SELECT (SELECT count(*) AS "count"
                FROM lineitem AS "l", orders AS "o"
                WHERE ("l"."l_orderkey" = "o"."o_orderkey"
                      AND
                      "o"."o_custkey" = c."c_custkey"
                      AND
                      "l"."l_shipmode" = ANY (ARRAY['RAIL',
                                                    'TRUCK'] :: bpchar[]))))
      SELECT * FROM "let3"
      ) AS "let3"("ground_1"),
      LATERAL
      (WITH "let4"("air_1") AS MATERIALIZED
      (SELECT (SELECT count(*) AS "count"
                FROM lineitem AS "l", orders AS "o"
                WHERE ("l"."l_orderkey" = "o"."o_orderkey"
                      AND
                      "o"."o_custkey" = c."c_custkey"
                      AND
                      "l"."l_shipmode" = ANY (ARRAY['AIR',
                                                    'REG AIR'] :: bpchar[]))))
      SELECT * FROM "let4"
      ) AS "let4"("air_1"),
      LATERAL
      (WITH "let5"("mail_1") AS MATERIALIZED
      (SELECT (SELECT count(*) AS "count"
              FROM lineitem AS "l", orders AS "o"
              WHERE ("l"."l_orderkey" = "o"."o_orderkey"
                      AND
                      "o"."o_custkey" = c."c_custkey"
                      AND
                      "l"."l_shipmode" = 'MAIL')))
      SELECT * FROM "let5"
      ) AS "let5"("mail_1"),
      LATERAL
      (SELECT ("ground_1" >= "air_1" AND "ground_1" >= "mail_1") AS "q4_1"
      ) AS "let6"("q4_1"),
      LATERAL
      ((SELECT 'ground' AS "result"
        WHERE NOT "q4_1" IS DISTINCT FROM True)
        UNION ALL
      (SELECT "ifresult10".*
        FROM LATERAL
            (SELECT ("air_1" >= "ground_1" AND "air_1" >= "mail_1") AS "q9_2"
            ) AS "let9"("q9_2"),
            LATERAL
            ((SELECT 'air' AS "result"
              WHERE NOT "q9_2" IS DISTINCT FROM True)
                UNION ALL
              (SELECT "ifresult13".*
              FROM LATERAL
                    (SELECT ("mail_1" >= "ground_1" AND "mail_1" >= "air_1") AS "q14_3"
                    ) AS "let12"("q14_3"),
                    LATERAL
                    ((SELECT 'mail' AS "result"
                      WHERE NOT "q14_3" IS DISTINCT FROM True)
                      UNION ALL
                    (SELECT 'nothing' AS "result"
                      WHERE "q14_3" IS DISTINCT FROM True)
                    ) AS "ifresult13"
              WHERE "q9_2" IS DISTINCT FROM True)
            ) AS "ifresult10"
        WHERE "q4_1" IS DISTINCT FROM True)
      ) AS "ifresult7"
) AS preferred_shipmode(mode);
