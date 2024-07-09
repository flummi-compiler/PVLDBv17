SELECT givenYear, channel
FROM   date_dim AS dd,
LATERAL (
WITH
  "%loop%"("%kind%", "%label%", "givenYear", "%result%") AS (
    SELECT 'jump' AS "%kind%",
           'entry' AS "%label%",
           CAST((dd.d_year) AS int) AS "givenYear",
           CAST(NULL AS text) AS "%result%"
   ),"entry"("%kind%", "%label%", "ratioCatalog", "ratioStore", "ratioWeb", "%result%") AS (
     WITH
       "%inputs%"("givenYear") AS (
         SELECT "givenYear"
         FROM   "%loop%"
         WHERE  "%kind%"='jump'
         AND    "%label%"='entry'
       ),
       "%assign%"("ratioCatalog", "ratioStore", "ratioWeb") AS (
         SELECT CAST((SELECT COALESCE(
                                      COUNT(*) FILTER (WHERE p_channel_email='Y'  OR p_channel_catalog='Y'  OR p_channel_dmail='Y') :: real /
                               NULLIF(COUNT(*) FILTER (WHERE p_channel_email='N' AND p_channel_catalog='N' AND p_channel_dmail='N') :: real,0),
                               '+Inf' :: real
                             )
                      FROM   tpcds.catalog_sales, tpcds.promotion, tpcds.date_dim
                      WHERE  cs_sold_date_sk = d_date_sk
                      AND    d_year = ("%inputs%"."givenYear")
                      AND    cs_promo_sk = p_promo_sk) AS real) AS "ratioCatalog",
                CAST((SELECT COALESCE(
                                      COUNT(*) FILTER (WHERE p_channel_email='Y'  OR p_channel_catalog='Y'  OR p_channel_dmail='Y') :: real /
                               NULLIF(COUNT(*) FILTER (WHERE p_channel_email='N' AND p_channel_catalog='N' AND p_channel_dmail='N') :: real,0),
                               '+Inf' :: real
                             )
                      FROM   tpcds.store_sales, tpcds.promotion, tpcds.date_dim
                      WHERE  ss_sold_date_sk = d_date_sk
                      AND    d_year = ("%inputs%"."givenYear")
                      AND    ss_promo_sk = p_promo_sk) AS real) AS "ratioStore",
                CAST((SELECT COALESCE(
                                      COUNT(*) FILTER (WHERE p_channel_email='Y'  OR p_channel_catalog='Y'  OR p_channel_dmail='Y') :: real /
                               NULLIF(COUNT(*) FILTER (WHERE p_channel_email='N' AND p_channel_catalog='N' AND p_channel_dmail='N') :: real,0),
                               '+Inf' :: real
                             )
                      FROM   tpcds.web_sales, tpcds.promotion, tpcds.date_dim
                      WHERE  ws_sold_date_sk = d_date_sk
                      AND    d_year = ("%inputs%"."givenYear")
                      AND    ws_promo_sk = p_promo_sk) AS real) AS "ratioWeb"
         FROM "%inputs%"
       )

     SELECT 'goto', 'inter0', "ratioCatalog", "ratioStore", "ratioWeb", CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE
   ),
   "inter0"("%kind%", "%label%", "%result%") AS (
     WITH
       "%inputs%"("ratioCatalog", "ratioStore", "ratioWeb") AS (
         SELECT "ratioCatalog", "ratioStore", "ratioWeb"
         FROM   "entry"
         WHERE  "%kind%"='goto'
         AND    "%label%"='inter0'
       ),
       "%assign%"("condition%0", "condition%1", "condition%2") AS (
         SELECT CAST((("%inputs%"."ratioWeb") >= ("%inputs%"."ratioCatalog") AND ("%inputs%"."ratioWeb") >= ("%inputs%"."ratioStore")) AS bool) AS "condition%0",
                CAST((("%inputs%"."ratioCatalog") >= ("%inputs%"."ratioWeb") AND ("%inputs%"."ratioCatalog") >= ("%inputs%"."ratioStore")) AS bool) AS "condition%1",
                CAST((("%inputs%"."ratioStore") >= ("%inputs%"."ratioCatalog") AND ("%inputs%"."ratioWeb") <= ("%inputs%"."ratioStore")) AS bool) AS "condition%2"
         FROM "%inputs%"
       )

     SELECT 'goto', 'falsey2', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2"
       UNION ALL
     SELECT 'goto', 'truthy0', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND "condition%0"
       UNION ALL
     SELECT 'goto', 'truthy1', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND NOT "condition%0" AND "condition%1"
       UNION ALL
     SELECT 'goto', 'truthy2', CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND "condition%2"
   ),
   "truthy2"("%kind%", "%label%", "maxRatio", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter0"
         WHERE  "%kind%"='goto'
         AND    "%label%"='truthy2'
       ),
       "%assign%"("maxRatio") AS (
         SELECT CAST(('Store') AS TEXT) AS "maxRatio"
         FROM "%inputs%"
       )

     SELECT 'goto', 'merge0', "maxRatio", CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE
   ),
   "truthy1"("%kind%", "%label%", "maxRatio", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter0"
         WHERE  "%kind%"='goto'
         AND    "%label%"='truthy1'
       ),
       "%assign%"("maxRatio") AS (
         SELECT CAST(('Catalog') AS TEXT) AS "maxRatio"
         FROM "%inputs%"
       )

     SELECT 'goto', 'merge0', "maxRatio", CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE
   ),
   "truthy0"("%kind%", "%label%", "maxRatio", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter0"
         WHERE  "%kind%"='goto'
         AND    "%label%"='truthy0'
       ),
       "%assign%"("maxRatio") AS (
         SELECT CAST(('Web') AS TEXT) AS "maxRatio"
         FROM "%inputs%"
       )

     SELECT 'goto', 'merge0', "maxRatio", CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE
   ),
   "falsey2"("%kind%", "%label%", "maxRatio", "%result%") AS (
     WITH
       "%inputs%"("%") AS (
         SELECT NULL
         FROM   "inter0"
         WHERE  "%kind%"='goto'
         AND    "%label%"='falsey2'
       ),
       "%assign%"("maxRatio") AS (
         SELECT CAST((NULL) AS TEXT) AS "maxRatio"
         FROM "%inputs%"
       )

     SELECT 'goto', 'merge0', "maxRatio", CAST(NULL AS text)
     FROM   "%assign%"
     WHERE  TRUE
   ),
   "merge0"("%kind%", "%label%", "%result%") AS (
     WITH
       "%inputs%"("maxRatio") AS (
         SELECT "maxRatio"
         FROM   "truthy2"
         WHERE  "%kind%"='goto'
         AND    "%label%"='merge0'
           UNION ALL
         SELECT "maxRatio"
         FROM   "falsey2"
         WHERE  "%kind%"='goto'
         AND    "%label%"='merge0'
           UNION ALL
         SELECT "maxRatio"
         FROM   "truthy0"
         WHERE  "%kind%"='goto'
         AND    "%label%"='merge0'
           UNION ALL
         SELECT "maxRatio"
         FROM   "truthy1"
         WHERE  "%kind%"='goto'
         AND    "%label%"='merge0'
       )
     SELECT 'emit', NULL,
            CAST((("%inputs%"."maxRatio")) AS text)
     FROM   "%inputs%"
   )

SELECT "%result%"
FROM   "merge0"
WHERE  "%kind%"='emit'
) AS _(channel);
