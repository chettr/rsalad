---
title: "spinMyR"
author: "Dean Attali"
date: "2015-01-11"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{spinMyR}
  %\VignetteEngine{knitr::rmarkdown}
  %\usepackage[utf8]{inputenc}
---



## `spinMyR()`: create markdown/HTML reports from R scripts with no hassle

`spinMyR()` is an improvement on `knitr::spin` that adds flexibility in several
ways. `spin` is great and easy when all you need to do is convert an R script to
markdown/HTML and everything lives in the same directory.  But if you've ever
tried using `spin` on an R script and got confused about working directories or
tried changing the output location, you will love `spinMyR`.  Since `spin`
assumes that the working directory is the directory where the script is, all the
paths in the script must change if you are running the script manually or using
spin.

I have battled with `spin` for too many hours, and the result is `spinMyR`.
`spinMyR` makes it easy to use spin on R scripts that require a certain working
directory that is not the script's directory, while allowing the script to still
function on its own.  `spinMyR` also lets you select where to output the
results, and adds several more features.

`spinMyR` can come in very handy when writing a script that can be used to
analyze a certain type of data, and you want to be able to easily run the script
on different datasets.

For example, assume we have an R script that reads a data file and produced a
short report while also generating a figure. Native `spin` works great on simple
directory structures like these:

```
- project
  |- subproject
     |- input.csv
     |- script.R
```

The resulting directory structure after spinning would be

```
- project
  |- subproject
     |- markdown-figs
        |- fig1.png
     |- input.csv
     |- script.R
     |- script.Rmd
     |- script.md
     |- script.HTML
```

But here is a more realistic initial directory tree:

```
- project
  |- subproject
     |- data
        |- input.csv
     |- R
        |- script.R
```

Now if we want `knitr::spin` to work, the path to the input would have to be
relative to the `R` directory. But if our working directory is `project`, then
the path to the input needs to be relative to `project`.  This means that
we can't use the exact same code to source the file vs `spin`-ing the file.
A similar problem happens if you want to create files from the script.  And
another problem arises if you want to put the resulting md/HTML in a different
directory - that is not possible with simple `spin` (as far as I know).

`spinMyR` fixes all these issues, and more. Assuming we are currently in the
`project` directory, we could use the following command to generate an
appropriate tree structure:

```
spinMyR(file = file.path("R", "script.R"), wd = "subproject",
        outDir = "reports", figDir = "myfigs")

- project
  |- subproject
     |- data
        |- input.csv
     |- R
        |- script.R
     |- reports
        |- myfigs
           |- fig1.png
        |- script.Rmd
        |- script.md
        |- script.HTML
```

One particular case when this kind of directory structure makes sense is when
you have many different datasets and want to store them separately from the
scripts or from the output.  You can imagine having "input-dean.csv" and
"input-john.csv" as two different datasets, with corresponding output in
"reports/dean/" and "reports/john/".

For more information including all features and parameters supported, see
`?rsalad::spinMyR`.