SELECT inputs.a, run.result
FROM   generate_series(1,101) AS inputs(a),
LATERAL (
WITH RECURSIVE
  "%loop%"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
    (SELECT 'jump' AS "%kind%",
            'entry' AS "%label%",
            CAST((inputs.a) AS double) AS "a",
            CAST(NULL AS int) AS "ip",
            CAST(NULL AS double) AS "n",
            CAST(NULL AS double) AS "x",
            CAST(NULL AS double) AS "y",
            CAST(NULL AS double) AS "z",
            CAST(NULL AS bool) AS "zero",
            CAST(NULL AS double) AS "%result%")
      UNION ALL -- recursive union!
    (WITH
      "entry"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT "a", "ip", "n", "x", "y", "z", "zero"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='entry'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((0) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((false) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'goto', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "loop_head"("%kind%", "%label%", "a", "ins", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT "a", "ip", "n", "x", "y", "z", "zero"
            FROM   "%loop%"
            WHERE  "%kind%"='jump'
            AND    "%label%"='loop_head'
              UNION ALL
            SELECT "a", "ip", "n", "x", "y", "z", "zero"
            FROM   "entry"
            WHERE  "%kind%"='goto'
            AND    "%label%"='loop_head'
          ),
          "%assign%"("a", "ins", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((SELECT p
                         FROM   program AS p
                         WHERE  p.loc = ("%inputs%"."ip")) AS instruction) AS "ins",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter2', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter2"("%kind%", "%label%", "a", "ins", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT "a", "ins", "ip", "n", "x", "y", "z", "zero"
            FROM   "loop_head"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter2'
          ),
          "%assign%"("a", "ins", "ip", "n", "x", "y", "z", "zero", "condition%0", "condition%1", "condition%2", "condition%3", "condition%4", "condition%5", "condition%6", "condition%7", "condition%8", "condition%9", "condition%10", "condition%11", "condition%12", "condition%13", "condition%14", "condition%15", "condition%16", "condition%17", "condition%18", "condition%19", "condition%20", "condition%21", "condition%22", "condition%23", "condition%24", "condition%25", "condition%26", "condition%27", "condition%28", "condition%29") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ins")) AS instruction) AS "ins",
                   CAST((("%inputs%"."ip") + 1) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero",
                   CAST((("%inputs%"."ins").opc = 'lda') AS bool) AS "condition%0",
                   CAST((("%inputs%"."ins").opc = 'ldx') AS bool) AS "condition%1",
                   CAST((("%inputs%"."ins").opc = 'ldy') AS bool) AS "condition%2",
                   CAST((("%inputs%"."ins").opc = 'ldz') AS bool) AS "condition%3",
                   CAST((("%inputs%"."ins").opc = 'tan') AS bool) AS "condition%4",
                   CAST((("%inputs%"."ins").opc = 'tax') AS bool) AS "condition%5",
                   CAST((("%inputs%"."ins").opc = 'tay') AS bool) AS "condition%6",
                   CAST((("%inputs%"."ins").opc = 'taz') AS bool) AS "condition%7",
                   CAST((("%inputs%"."ins").opc = 'tna') AS bool) AS "condition%8",
                   CAST((("%inputs%"."ins").opc = 'txa') AS bool) AS "condition%9",
                   CAST((("%inputs%"."ins").opc = 'tya') AS bool) AS "condition%10",
                   CAST((("%inputs%"."ins").opc = 'tza') AS bool) AS "condition%11",
                   CAST((("%inputs%"."ins").opc = 'txy') AS bool) AS "condition%12",
                   CAST((("%inputs%"."ins").opc = 'txz') AS bool) AS "condition%13",
                   CAST((("%inputs%"."ins").opc = 'tyx') AS bool) AS "condition%14",
                   CAST((("%inputs%"."ins").opc = 'tyz') AS bool) AS "condition%15",
                   CAST((("%inputs%"."ins").opc = 'tzx') AS bool) AS "condition%16",
                   CAST((("%inputs%"."ins").opc = 'tzy') AS bool) AS "condition%17",
                   CAST((("%inputs%"."ins").opc = 'inc') AS bool) AS "condition%18",
                   CAST((("%inputs%"."ins").opc = 'dec') AS bool) AS "condition%19",
                   CAST((("%inputs%"."ins").opc = 'add') AS bool) AS "condition%20",
                   CAST((("%inputs%"."ins").opc = 'sub') AS bool) AS "condition%21",
                   CAST((("%inputs%"."ins").opc = 'mul') AS bool) AS "condition%22",
                   CAST((("%inputs%"."ins").opc = 'div') AS bool) AS "condition%23",
                   CAST((("%inputs%"."ins").opc = 'mod') AS bool) AS "condition%24",
                   CAST((("%inputs%"."ins").opc = 'eq0') AS bool) AS "condition%25",
                   CAST((("%inputs%"."zero")) AS bool) AS "condition%26",
                   CAST((("%inputs%"."ins").opc = 'jmp') AS bool) AS "condition%27",
                   CAST((("%inputs%"."ins").opc = 'emt') AS bool) AS "condition%28",
                   CAST((("%inputs%"."ins").opc = 'hlt') AS bool) AS "condition%29"
            FROM "%inputs%"
          )

        SELECT 'goto', 'truthy0', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND "condition%0"
          UNION ALL
        SELECT 'goto', 'truthy1', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND "condition%1"
          UNION ALL
        SELECT 'goto', 'truthy10', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND "condition%10"
          UNION ALL
        SELECT 'goto', 'truthy11', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND "condition%11"
          UNION ALL
        SELECT 'goto', 'truthy12', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND "condition%12"
          UNION ALL
        SELECT 'goto', 'truthy13', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND "condition%13"
          UNION ALL
        SELECT 'goto', 'truthy14', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND "condition%14"
          UNION ALL
        SELECT 'goto', 'truthy15', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND "condition%15"
          UNION ALL
        SELECT 'goto', 'truthy16', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND "condition%16"
          UNION ALL
        SELECT 'goto', 'truthy17', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND "condition%17"
          UNION ALL
        SELECT 'goto', 'truthy18', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND "condition%18"
          UNION ALL
        SELECT 'goto', 'truthy19', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND "condition%19"
          UNION ALL
        SELECT 'goto', 'truthy2', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND "condition%2"
          UNION ALL
        SELECT 'goto', 'truthy20', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND "condition%20"
          UNION ALL
        SELECT 'goto', 'truthy21', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND "condition%21"
          UNION ALL
        SELECT 'goto', 'truthy22', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND "condition%22"
          UNION ALL
        SELECT 'goto', 'truthy23', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND "condition%23"
          UNION ALL
        SELECT 'goto', 'truthy24', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND NOT "condition%23" AND "condition%24"
          UNION ALL
        SELECT 'goto', 'truthy26', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND NOT "condition%23" AND NOT "condition%24" AND "condition%25" AND "condition%26"
          UNION ALL
        SELECT 'goto', 'truthy27', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND NOT "condition%23" AND NOT "condition%24" AND NOT "condition%25" AND "condition%27"
          UNION ALL
        SELECT 'goto', 'truthy28', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND NOT "condition%23" AND NOT "condition%24" AND NOT "condition%25" AND NOT "condition%27" AND "condition%28"
          UNION ALL
        SELECT 'goto', 'truthy3', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND "condition%3"
          UNION ALL
        SELECT 'goto', 'truthy4', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND "condition%4"
          UNION ALL
        SELECT 'goto', 'truthy5', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND "condition%5"
          UNION ALL
        SELECT 'goto', 'truthy6', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND "condition%6"
          UNION ALL
        SELECT 'goto', 'truthy7', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND "condition%7"
          UNION ALL
        SELECT 'goto', 'truthy8', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND "condition%8"
          UNION ALL
        SELECT 'goto', 'truthy9', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND "condition%9"
          UNION ALL
        SELECT 'jump', 'loop_head', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND NOT "condition%23" AND NOT "condition%24" AND "condition%25" AND NOT "condition%26"
          UNION ALL
        SELECT 'jump', 'loop_head', "a", "ins", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE AND NOT "condition%0" AND NOT "condition%1" AND NOT "condition%2" AND NOT "condition%3" AND NOT "condition%4" AND NOT "condition%5" AND NOT "condition%6" AND NOT "condition%7" AND NOT "condition%8" AND NOT "condition%9" AND NOT "condition%10" AND NOT "condition%11" AND NOT "condition%12" AND NOT "condition%13" AND NOT "condition%14" AND NOT "condition%15" AND NOT "condition%16" AND NOT "condition%17" AND NOT "condition%18" AND NOT "condition%19" AND NOT "condition%20" AND NOT "condition%21" AND NOT "condition%22" AND NOT "condition%23" AND NOT "condition%24" AND NOT "condition%25" AND NOT "condition%27" AND NOT "condition%28" AND NOT "condition%29"
      ),
      "truthy9"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("ip", "n", "x", "y", "z", "zero") AS (
            SELECT "ip", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy9'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."x")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy8"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("ip", "n", "x", "y", "z", "zero") AS (
            SELECT "ip", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy8'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."n")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy7"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "zero") AS (
            SELECT "a", "ip", "n", "x", "y", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy7'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."a")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy6"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "z", "zero") AS (
            SELECT "a", "ip", "n", "x", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy6'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."a")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy5"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "y", "z", "zero") AS (
            SELECT "a", "ip", "n", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy5'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."a")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy4"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "x", "y", "z", "zero") AS (
            SELECT "a", "ip", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy4'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."a")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy3"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "ip", "n", "x", "y", "zero") AS (
            SELECT "a", "ins", "ip", "n", "x", "y", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy3'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."ins").arg) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy28"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT "a", "ip", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy28'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
          UNION ALL
        SELECT 'emit', NULL, CAST(NULL AS double), CAST(NULL AS int), CAST(NULL AS double), CAST(NULL AS double), CAST(NULL AS double), CAST(NULL AS double), CAST(NULL AS bool),
               CAST((("%inputs%"."a")) AS double)
        FROM   "%inputs%"
      ),
      "truthy27"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "n", "x", "y", "z", "zero") AS (
            SELECT "a", "ins", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy27'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ins").arg) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy26"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "n", "x", "y", "z", "zero") AS (
            SELECT "a", "ins", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy26'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ins").arg) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy24"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy24'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a") % ("%inputs%"."x")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter34', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter34"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy24"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter34'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."a") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy23"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy23'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a") / ("%inputs%"."x")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter32', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter32"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy23"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter32'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."a") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy22"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy22'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a") * ("%inputs%"."x")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter30', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter30"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy22"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter30'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."a") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy21"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy21'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a") - ("%inputs%"."x")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter28', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter28"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy21"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter28'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."a") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy20"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy20'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a") + ("%inputs%"."x")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter26', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter26"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy20"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter26'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."a") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy2"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "ip", "n", "x", "z", "zero") AS (
            SELECT "a", "ins", "ip", "n", "x", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy2'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."ins").arg) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy19"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ins", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy19'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n") - ("%inputs%"."ins").arg) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter24', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter24"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy19"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter24'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."n") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy18"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ins", "ip", "n", "x", "y", "z"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy18'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n") + ("%inputs%"."ins").arg) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z"
            FROM "%inputs%"
          )

        SELECT 'goto', 'inter22', "a", "ip", "n", "x", "y", "z", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "inter22"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "z") AS (
            SELECT "a", "ip", "n", "x", "y", "z"
            FROM   "truthy18"
            WHERE  "%kind%"='goto'
            AND    "%label%"='inter22'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."n") = 0) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy17"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "z", "zero") AS (
            SELECT "a", "ip", "n", "x", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy17'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."z")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy16"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "y", "z", "zero") AS (
            SELECT "a", "ip", "n", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy16'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."z")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy15"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "zero") AS (
            SELECT "a", "ip", "n", "x", "y", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy15'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."y")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy14"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "y", "z", "zero") AS (
            SELECT "a", "ip", "n", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy14'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."y")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy13"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "y", "zero") AS (
            SELECT "a", "ip", "n", "x", "y", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy13'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."x")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy12"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ip", "n", "x", "z", "zero") AS (
            SELECT "a", "ip", "n", "x", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy12'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."x")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy11"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("ip", "n", "x", "y", "z", "zero") AS (
            SELECT "ip", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy11'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."z")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy10"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("ip", "n", "x", "y", "z", "zero") AS (
            SELECT "ip", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy10'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."y")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy1"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("a", "ins", "ip", "n", "y", "z", "zero") AS (
            SELECT "a", "ins", "ip", "n", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy1'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."a")) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."ins").arg) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      ),
      "truthy0"("%kind%", "%label%", "a", "ip", "n", "x", "y", "z", "zero", "%result%") AS (
        WITH
          "%inputs%"("ins", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT "ins", "ip", "n", "x", "y", "z", "zero"
            FROM   "inter2"
            WHERE  "%kind%"='goto'
            AND    "%label%"='truthy0'
          ),
          "%assign%"("a", "ip", "n", "x", "y", "z", "zero") AS (
            SELECT CAST((("%inputs%"."ins").arg) AS double) AS "a",
                   CAST((("%inputs%"."ip")) AS int) AS "ip",
                   CAST((("%inputs%"."n")) AS double) AS "n",
                   CAST((("%inputs%"."x")) AS double) AS "x",
                   CAST((("%inputs%"."y")) AS double) AS "y",
                   CAST((("%inputs%"."z")) AS double) AS "z",
                   CAST((("%inputs%"."zero")) AS bool) AS "zero"
            FROM "%inputs%"
          )

        SELECT 'jump', 'loop_head', "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
        FROM   "%assign%"
        WHERE  TRUE
      )

     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter2"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy0"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy1"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy2"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy3"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy4"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy5"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy6"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy7"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy8"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy9"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy10"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy11"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy12"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy13"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy14"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy15"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy16"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy17"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter22"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter24"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter26"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter28"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter30"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter32"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "inter34"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy26"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy27"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'jump', "%label%", "a", "ip", "n", "x", "y", "z", "zero", CAST(NULL AS double)
     FROM   "truthy28"
     WHERE  "%kind%"='jump'
       UNION ALL
     SELECT 'emit', NULL, CAST(NULL AS double), CAST(NULL AS int), CAST(NULL AS double), CAST(NULL AS double), CAST(NULL AS double), CAST(NULL AS double), CAST(NULL AS bool), "%result%"
     FROM   "truthy28"
     WHERE  "%kind%"='emit'
    )
  )

SELECT "%result%" FROM "%loop%" WHERE "%kind%"='emit';
) AS run(result);
