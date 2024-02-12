# SQL Engines Excel at the Execution of Imperative Programs

_Artifacts accompanying our PLVDBv17 paper of the same name._

> <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">SQL Engines Excel at the Execution of Imperative Programs</span> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://db.cs.uni-tuebingen.de/">Tim Fischer, Denis Hirn, Torsten Grust</a> is licensed under <a href="http://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nd.svg?ref=chooser-v1"></a></p>

## Structure

```
<root>/                   # - This repository
├╴ samples/               #   - Collection of samples presented in the paper
│  ├╴ <name>/             #     - Collection of all variants and presentations of a given sample
│  │  ├╴ cfg.pdf          #       - Rendering of the optimized CFG
│  │  ├╴ flummi.sql       #       - Calling query using Flummi-compiled function
│  │  ├╴ function.fl      #       - Equivalent imperative version
│  │  ├╴ lateral.sql      #       - Calling query using PL/SQL-to-SQL-compiled function (optional, see below)
│  │  ├╴ plsql.sql        #       - Equivalent PL/SQL version (optional, see below)
┊  ┊  └╴ umbrascript.sql  #       - Equivalent UmbraScript version (optional, see below)
```

## Samples

In our paper we do not present each of the samples in all possible implementations, this is reflected in this repository as well.
The following table shows which implementations—aside from `flummi.sql` and `function.fl`—this repository provides for which sample.

| Sample     | `lateral.sql` | `plsql.sql` | `umbrascript.sql` |
| :--------- | :-----------: | :---------: | :---------------: |
| `force`    |       ✘       |      ✘      |         ✘         |
| `giftwrap` |       ✔︎       |      ✔︎      |         ✔︎         |
| `late`     |       ✘       |      ✘      |         ✔︎         |
| `march`    |       ✘       |      ✘      |         ✘         |
| `margin`   |       ✘       |      ✘      |         ✔︎         |
| `oil`      |       ✔︎       |      ✔︎      |         ✘         |
| `packing`  |       ✔︎       |      ✔︎      |         ✔︎         |
| `ray`      |       ✘       |      ✘      |         ✘         |
| `savings`  |       ✘       |      ✘      |         ✘         |
| `sched`    |       ✘       |      ✘      |         ✘         |
| `ship`     |       ✔︎       |      ✔︎      |         ✘         |
| `supply`   |       ✘       |      ✘      |         ✔︎         |
| `visible`  |       ✘       |      ✘      |         ✔︎         |
| `vm`       |       ✘       |      ✘      |         ✘         |
