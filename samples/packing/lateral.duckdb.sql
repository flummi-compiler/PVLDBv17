SELECT o.o_orderkey, pack_order.pack
FROM   orders AS o, (SELECT 60) AS _(capacity),
LATERAL (
WITH RECURSIVE run("rec?",
                    "label",
                    "res",
                    "orderkey",
                    "n",
                    "items",
                    "size",
                    "subset",
                    "max_size",
                    "max_subset",
                    "pack",
                    "linenumber") AS MATERIALIZED
(
    (SELECT True,
            'while9_head',
            NULL :: text,
            o.o_orderkey,
            "n_1",
            (1 << "n_1") - 1 AS "items_3",
            NULL :: int4 AS "size_14",
            NULL :: int4 AS "subset_15",
            NULL :: int4 AS "max_size_14",
            NULL :: int4 AS "max_subset_14",
            NULL :: text AS "pack_18",
            NULL :: int4 AS "linenumber_15"
      FROM LATERAL
          (SELECT (SELECT (count(*)) :: int4 AS "count"
                      FROM lineitem AS "l"
                      WHERE "l"."l_orderkey" = o.o_orderkey) AS "n_1") AS "let36"("n_1"),
          LATERAL (SELECT "n_1" = 0 AS "q4_1") AS "let37"("q4_1"),
          LATERAL
          (SELECT capacity
                      <
                      ((SELECT max("p"."p_size") AS "max"
                      FROM lineitem AS "l", part AS "p"
                      WHERE ("l"."l_orderkey" = o.o_orderkey
                                AND
                                "l"."l_partkey" = "p"."p_partkey"))) AS "q8_2"
          ) AS "let39"("q8_2")
      WHERE "q8_2" IS DISTINCT FROM True
      AND   "q4_1" IS DISTINCT FROM True
      AND   proportion <= PROPORTION)
      UNION ALL
    (SELECT "result".*
      FROM run AS "run"("rec?",
                        "label",
                        "res",
                        "orderkey",
                        "n",
                        "items",
                        "size",
                        "subset",
                        "max_size",
                        "max_subset",
                        "pack",
                        "linenumber"),
          LATERAL
          ((SELECT "ifresult2".*
            FROM LATERAL
                  (SELECT "linenumber" <= "n" AS "pred22_10"
                  ) AS "let1"("pred22_10"),
                  LATERAL
                  ((SELECT "ifresult4".*
                    FROM LATERAL
                        (SELECT ("max_subset" & (1 << ("linenumber" - 1))) <> 0 AS "q26_11"
                        ) AS "let3"("q26_11"),
                        LATERAL
                        ((SELECT True,
                                  'ifmerge25',
                                  NULL :: text,
                                  "orderkey",
                                  "n",
                                  "items",
                                  "size",
                                  "subset",
                                  "max_size",
                                  "max_subset",
                                  "pack" || '#' AS "pack_16",
                                  "linenumber"
                          WHERE NOT "q26_11" IS DISTINCT FROM True)
                            UNION ALL
                          (SELECT True,
                                  'ifmerge25',
                                  NULL :: text,
                                  "orderkey",
                                  "n",
                                  "items",
                                  "size",
                                  "subset",
                                  "max_size",
                                  "max_subset",
                                  "pack" || '.' AS "pack_13",
                                  "linenumber"
                          WHERE "q26_11" IS DISTINCT FROM True)
                        ) AS "ifresult4"
                    WHERE NOT "pred22_10" IS DISTINCT FROM True)
                    UNION ALL
                  (SELECT "yield9".*
                    FROM LATERAL
                        ((SELECT False,
                                  NULL :: text,
                                  "pack" AS "result",
                                  "run"."orderkey",
                                  "run"."n",
                                  "run"."items",
                                  "run"."size",
                                  "run"."subset",
                                  "run"."max_size",
                                  "run"."max_subset",
                                  "run"."pack",
                                  "run"."linenumber")
                            UNION ALL
                          (SELECT True,
                                  'while9_head',
                                  NULL :: text,
                                  "orderkey",
                                  "n",
                                  "items" & (~ "max_subset") AS "items_16",
                                  "size",
                                  "subset",
                                  "max_size",
                                  "max_subset",
                                  "pack",
                                  "linenumber")
                        ) AS "yield9"
                    WHERE "pred22_10" IS DISTINCT FROM True)
                  ) AS "ifresult2"
            WHERE "run"."label" = 'fori20_head')
              UNION ALL
            ((SELECT "ifresult13".*
              FROM LATERAL
                  (SELECT "subset" = "items" AS "q19_7") AS "let12"("q19_7"),
                  LATERAL
                  ((SELECT True,
                            'fori20_head',
                            NULL :: text,
                            "orderkey",
                            "n",
                            "items",
                            "size",
                            "subset",
                            "max_size",
                            "max_subset",
                            '' AS "pack_9",
                            1 AS "linenumber_9"
                    WHERE NOT "q19_7" IS DISTINCT FROM True)
                      UNION ALL
                    (SELECT True,
                            'loop11_body',
                            NULL :: text,
                            "orderkey",
                            "n",
                            "items",
                            "size",
                            "items" & ("subset" - "items") AS "subset_9",
                            "max_size",
                            "max_subset",
                            "pack",
                            "linenumber"
                    WHERE "q19_7" IS DISTINCT FROM True)
                  ) AS "ifresult13"
              WHERE "run"."label" = 'ifmerge14')
              UNION ALL
            ((SELECT True,
                    'fori20_head',
                    NULL :: text,
                    "orderkey",
                    "n",
                    "items",
                    "size",
                    "subset",
                    "max_size",
                    "max_subset",
                    "pack",
                    "linenumber" + 1 AS "linenumber_14"
              WHERE "run"."label" = 'ifmerge25')
              UNION ALL
            ((SELECT "ifresult23".*
              FROM LATERAL
                  (SELECT (SELECT (sum("p"."p_size")) :: int4 AS "sum"
                                FROM lineitem AS "l", part AS "p"
                                WHERE ("l"."l_orderkey" = "orderkey"
                                    AND
                                    ("subset" & (1 << ("l"."l_linenumber" - 1))) <> 0
                                    AND
                                    "l"."l_partkey" = "p"."p_partkey")) AS "size_6") AS "let21"("size_6"),
                  LATERAL
                  (SELECT ("size_6" <= capacity AND "size_6" > "max_size") AS "q15_6"
                  ) AS "let22"("q15_6"),
                  LATERAL
                  ((SELECT True,
                            'ifmerge14',
                            NULL :: text,
                            "orderkey",
                            "n",
                            "items",
                            "size_6",
                            "subset",
                            "size_6" AS "max_size_17",
                            "subset" AS "max_subset_17",
                            "pack",
                            "linenumber"
                    WHERE NOT "q15_6" IS DISTINCT FROM True)
                      UNION ALL
                    (SELECT True,
                            'ifmerge14',
                            NULL :: text,
                            "orderkey",
                            "n",
                            "items",
                            "size_6",
                            "subset",
                            "max_size",
                            "max_subset",
                            "pack",
                            "linenumber"
                    WHERE "q15_6" IS DISTINCT FROM True)
                  ) AS "ifresult23"
              WHERE "run"."label" = 'loop11_body')
              UNION ALL
            (SELECT "ifresult44".*
            FROM LATERAL
                  (SELECT "items" <> 0 AS "pred10_4") AS "let43"("pred10_4"),
                  LATERAL
                  (SELECT True,
                          'loop11_body',
                          NULL :: text,
                          "orderkey",
                          "n",
                          "items",
                          "size",
                          "items" & (- "items") AS "subset_5",
                          0 AS "max_size_5",
                          0 AS "max_subset_5",
                          "pack",
                          "linenumber"
                  ) AS "ifresult44"
            WHERE (NOT "pred10_4" IS DISTINCT FROM True
                    AND
                    "run"."label" = 'while9_head')))))
          ) AS "result"("rec?",
                        "label",
                        "res",
                        "orderkey",
                        "n",
                        "items",
                        "size",
                        "subset",
                        "max_size",
                        "max_subset",
                        "pack",
                        "linenumber")
      WHERE "run"."rec?")
)
SELECT "run"."res" AS "res"
FROM run AS "run"
WHERE NOT "run"."rec?"
) AS pack_order(pack)
WHERE o.o_orderstatus = 'F';
