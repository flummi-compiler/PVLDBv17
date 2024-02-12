CREATE FUNCTION savings(orderkey INT) RETURNS FLOAT
AS
$$
  let mut savings : FLOAT;

  savings = 0;

  SELECT 1
  FROM   orders AS o
  WHERE  o.o_orderkey = orderkey
  WHEN no_data_found {
    RETURN NULL :: FLOAT;
  }

  SELECT l.l_partkey AS partkey, l.l_suppkey AS suppkey, l.l_quantity :: INT AS quantity
  FROM   lineitem AS l
  WHERE  l.l_orderkey = orderkey
  {
    SELECT ps.ps_suppkey AS cur_suppkey, ps.ps_supplycost AS cur_supplycost
    FROM   partsupp AS ps
    WHERE  ps.ps_partkey = partkey
    AND    ps.ps_suppkey = suppkey
    {
      SELECT MIN(ps.ps_supplycost) AS min_supplycost
      FROM   partsupp AS ps
      WHERE  ps.ps_partkey = partkey
      AND    ps.ps_availqty >= quantity
      {
        IF (cur_supplycost > min_supplycost)
        {
          savings = savings + (cur_supplycost - min_supplycost) * quantity;
        }
      }
    }
  }

  RETURN savings;
$$ LANGUAGE umbrascript;
