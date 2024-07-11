#!/bin/python3
from decimal import Decimal
import os, functools

import duckdb


DUCKDB_DB_FILE = os.environ["DUCKDB_DB_FILE"]
DB = duckdb.connect(DUCKDB_DB_FILE, read_only=True)


@functools.lru_cache(maxsize=None)
def savings(orderkey: int) -> tuple[int, Decimal]:
  saved = Decimal("0.0")

  for partkey, suppkey, quantity in DB.execute(
    """
    SELECT l.l_partkey, l.l_suppkey, l.l_quantity
    FROM   lineitem AS l
    WHERE  l.l_orderkey = $1
    """,
    [orderkey]
  ).fetchall():
    cur_supplycost, min_supplycost = DB.execute(
      """
      SELECT ANY_VALUE(ps.ps_supplycost) FILTER (ps.ps_suppkey = $2),
             MIN(ps.ps_supplycost) FILTER (ps_availqty >= $3)
      FROM   partsupp AS ps
      WHERE  ps.ps_partkey = $1
      """,
      [partkey, suppkey, quantity]
    ).fetchone()

    if cur_supplycost > min_supplycost:
      saved += (cur_supplycost - min_supplycost) * quantity

  return orderkey, saved


if __name__ == "__main__":
  from multiprocessing import Pool

  with Pool() as p:
    results = p.starmap(
      savings,
      DB.execute(
        """
        SELECT o.o_orderkey
        FROM   orders AS o
        """,
      ).fetchall()
    )

    for orderkey, saved in results:
      print(orderkey, saved)
