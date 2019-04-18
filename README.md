# psql-partition-poc
Just a quick experiment to see how [PSQL partitioning](https://www.postgresql.org/docs/9.6/ddl-partitioning.html) works.

TL;DR: See `./results.txt` in the root of this repository.

## Prerequisites

1. `pv`, `gunzip`, `ruby` (including `gem` and `bundler`).
2. PostgreSQL DB that you can connect to by simply running `psql` (no credentials).

## Running

The project mostly follows [Scripts to Rule Them All](https://github.blog/2015-06-30-scripts-to-rule-them-all/), so the
basic instructions are as follows:

1. Call `./script/bootstrap` in order to generate the partition-creating SQL (in `/sql/run`) and data (in `/sql/data`).
2. Call `./script/main` in order to execute the code and create your partitioned and populated table in the `partitionpoc` database.
3. Call `./script/setup` if you want to clear everything out and do it again.

The results are written out to the screen, with the most interesting stuff also written to `results.txt` in the root directory.
I've checked that file in so that folks who are browsing can see how it works.

## Configuring

When you run `./script/bootstrap` or `./script/setup`, you can control the amount of data through environment variables.

- `FILE_COUNT` is the number of files of `INSERT` statements.
- `INSERTS_PER_FILE` is the number if `INSERT` statements in each file.
- `NOTICE_PERIOD` is how often a line is printed out reporting the status.
