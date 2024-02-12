CREATE OR REPLACE FUNCTION pack_order(orderkey int, capacity int) RETURNS SETOF text AS
$$
  DECLARE
    n          int;    -- # of lineitems in order
    items      int;    -- set of lineitems still to pack
    size       int;    -- current pack size
    subset     int;    -- current subset of lineitems considered for a pack
    max_size   int;    -- maximum pack size found so far
    max_subset int;    -- pack subset of maximum size found so far
    pack       text;   -- current pack
  BEGIN
    -- # of lineitems in order
    n := (SELECT COUNT(*) :: int4
          FROM   lineitem AS l
          WHERE  l.l_orderkey = orderkey);
    -- order key not found?
    IF n = 0 THEN
      RETURN;
    END IF;

    -- container capacity sufficient to hold largest part?
    IF capacity < (SELECT MAX(p.p_size)
                   FROM   lineitem AS l, part AS p
                   WHERE  l.l_orderkey = orderkey
                   AND    l.l_partkey = p.p_partkey) THEN
      RETURN;
    END IF;

    -- create full set of linenumbers {1,2,...,n}
    items := (1 << n) - 1;

    -- as long as there are still lineitems to pack...
    WHILE items <> 0 LOOP
      max_size   := 0;
      max_subset := 0;  -- ∅
      -- iterate through all non-empty subsets of items
      subset := items & -items;
      LOOP
         -- find size of current lineitem subset o
         size := (SELECT SUM(p.p_size) :: int4
                  FROM   lineitem AS l, part AS p
                  WHERE  l.l_orderkey = orderkey
                  AND    subset & (1 << l.l_linenumber - 1) <> 0
                  AND    l.l_partkey = p.p_partkey);

         if size <= capacity AND size > max_size THEN
           max_size   := size;
           max_subset := subset;
         END IF;
         -- exit if iterated through all lineitem subsets ...
         IF subset = items THEN
           EXIT;
         ELSE
           -- ... else, consider next lineitem subset
           subset := items & (subset - items);
         END IF;
      END LOOP;

      -- convert bit set max_subset into set of linenumbers
      pack := '';
      FOR linenumber IN 1..n LOOP
        IF max_subset & (1 << linenumber - 1) <> 0 THEN
          pack := pack || '#';
        ELSE
          pack := pack || '.';
        END IF;
      END LOOP;
      -- emit pack
      RETURN NEXT pack;

      -- we've selected lineitems in set max_subset,
      -- update items to remove these lineitems
      items := items & ~max_subset;
    END LOOP;
  END;
$$
LANGUAGE PLPGSQL;

-- Q:

SELECT pack(0,0);
