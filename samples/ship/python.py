#!/bin/python3
import os, duckdb, functools


DUCKDB_DB_FILE = os.environ["DUCKDB_DB_FILE"]
DB = duckdb.connect(DUCKDB_DB_FILE, read_only=True)


@functools.lru_cache(maxsize=None)
def preferred_shipmode(custkey: int) -> tuple[int, str]:
  ground, air, mail = DB.execute(
    """
    SELECT COUNT(*) FILTER (l.l_shipmode IN ('RAIL', 'TRUCK')),
           COUNT(*) FILTER (l.l_shipmode IN ('AIR', 'AIR REG')),
           COUNT(*) FILTER (l.l_shipmode = 'MAIL')
    FROM   lineitem AS l, orders AS o
    WHERE  l.l_orderkey = o.o_orderkey
    AND    o.o_custkey = $1
    """,
    [custkey]
  ).fetchone()

  if ground >= air and ground >= mail:
    return custkey, "ground"
  elif air >= ground and air >= mail:
    return custkey, "air"
  elif mail >= ground and mail >= air:
    return custkey, "mail"
  else:
    return custkey, "¯\_(ツ)_/¯"


if __name__ == "__main__":
  from multiprocessing import Pool

  with Pool() as p:
    results = p.starmap(
      preferred_shipmode,
      DB.execute(
        """
        SELECT c.c_custkey
        FROM   customer AS c
        """
      ).fetchall()
    )

    for custkey, shipmode in results:
      print(custkey, shipmode)
