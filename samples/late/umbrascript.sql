CREATE FUNCTION late(suppkey INT, orderkey INT) RETURNS bool
AS
$$
  let mut multi : bool;
  let mut blame : bool;

  multi = false;
  blame = false;

  SELECT l.l_receiptdate, l.l_commitdate, l.l_suppkey
  FROM   lineitem AS l
  WHERE  l.l_orderkey = orderkey
  {
    -- is this an order with suppliers other than suppkey?
    multi = multi OR (l_suppkey <> suppkey);

    if (l_receiptdate > l_commitdate) {
      -- this lineitem has been received late ...
      if (l_suppkey <> suppkey) {
        -- ... but a supplier other than suppkey is to blame
        return false;
      } else {
        --- ... and suppkey is to blame
        blame = true;
      }
    }
  }

  return (multi AND blame);
$$ LANGUAGE 'umbrascript' STRICT IMMUTABLE;

