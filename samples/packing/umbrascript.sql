CREATE FUNCTION pack_order(orderkey int, capacity int) RETURNS text
AS
$$
  let mut packs      : text;
  let mut items      : int;   -- bit set
  let mut max_size   : int;
  let mut max_subset : int;   -- bit set
  let mut subset     : int;   -- bit set
  let mut pack       : text;

  packs = '|';

  -- # of lineitems in order
  SELECT COUNT(*) :: int AS n
  FROM   lineitem AS l
  WHERE  l.l_orderkey = orderkey;

  -- largest item in order?
  SELECT MAX(p.p_size) :: int AS largest_item
  FROM   lineitem AS l, part as p
  WHERE  l.l_orderkey = orderkey AND l.l_partkey = p.p_partkey;

  -- do we have any items to pack and will the container hold the largest item?
  if (n = 0 OR capacity < largest_item)
  {
    return NULL;
  }

  -- set of all n items
  items = (1 << n) - 1;

  -- pack a maximum of n boxes (each box will hold at least one item)
  SELECT i FROM generate_series(1, n) AS _(i) {
    -- as long as there still items to pack...
    if (items = 0) {
      break;
    }

    max_size   = 0;
    max_subset = 0;
    subset     = items & -items;

    -- iterate through all non-empty subsets of items
    -- (there are no more than 2ⁿ-1 of these susbets)
    SELECT j FROM generate_series(1, 2^n-1) AS __(j) {
      SELECT SUM(p.p_size) :: int AS size
      FROM   lineitem AS l, part AS p
      WHERE  l.l_orderkey = orderkey AND l.l_partkey = p.p_partkey
      AND    subset & (1 << l.l_linenumber - 1) <> 0;

      if (size <= capacity AND size > max_size)
      {
        max_size   = size;
        max_subset = subset;
      }

      -- exit if iterated through all lineitem subsets ...
      if (subset = items) {
        break;
      } else {
        -- ... else, consider next lineitem subset
        subset = items & (subset - items);
      }
    }

    -- convert bit set max_subset into set of linenumbers
    pack = '';
    SELECT linenumber FROM generate_series(1, n) AS ___(linenumber) {
      if (max_subset & (1 << linenumber - 1) <> 0) {
        pack = pack || '📦';
      } else {
        pack = pack || '.';
      }
    }
    -- emit pack
    packs = packs || pack || '|';

    -- we've selected lineitems in set max_subset,
    -- update items to remove these lineitems
    items = items & (-max_subset - 1);
  }

  return packs;
$$ LANGUAGE umbrascript;
