`spinMyR()`: create markdown/HTML reports from R scripts with no hassle
-----------------------------------------------------------------------

`spinMyR()` is an improvement on `knitr::spin` that adds flexibility in
several ways. `spin` alone is great when all you need to do is convert a
one-off R script to markdown/HTML and everything lives in the same
directory. But if you've ever tried using `spin` on an R script and got
confused about working directories, tried changing the output location,
or wanted to run the same script multiple times but with slightly
different parameters/datasets without having to change all your code,
you will love `spinMyR`.

`spinMyR` is a recommended wrapper to `spin` when any of the following
are true:

-   **The R script requires a certain working directory that is *not*
    the directory in which the script lives** (`spin` assumes that the
    working directory for thec code in the script is the directory where
    the script is, which means that all that paths in the code must
    change if you are running the script manually vs using `spin`)  
-   **The results should be produced in a different directory** (with
    `spin`, the output will be produced in the directory that the user
    makes the call from)  
-   **The script has one or more parameters** (and you want to run an
    identical script multiple times with different parameters/datasets)

Many real-life data analysis scenarios will use all these features, as
illustrated with the examples below. There are several other features
that are documented in `?rsalad::spinMyR`.

### Example: basic use case and motivation

`spinMyR` can come in very handy when writing a script that can be used
to analyze a certain type of data, and you want to be able to easily run
the script on different datasets.

Assume we have an R script that reads a data file and produces a short
report while also generating a figure. Native `spin` works great if you
have a flat directory structure like this (assume the working directory
is inside `project`):

    - project
      |- subproject
         |- input.csv
         |- script.R

After running `spin`, the resulting directory structure would look like
this:

    spin("subproject/script.R")

    - project
       |- subproject
         |- markdown-figs
            |- fig1.png
         |- input.csv
         |- script.R
       |- script.Rmd
       |- script.md
       |- script.html

Notice that the outputs are produced in the directory where the function
called from, completely separated from where the input script is.

But in a real project, you rarely have everything just lying around in
the same folder. Here is an example of a more realistic initial
directory structure:

    - project
       |- subproject
         |- data
            |- input.csv
         |- R
            |- script.R

Now if we want `knitr::spin` to work, the path to `input.csv` would have
to be relative to the `R` directory. But if we want to `source` the file
or run it manually, the paths have to be relative to our working
directory (`project`). This means that we can't use the exact same code
to source the file vs `spin`-ing the file. A similar problem arrises if
you want to create files from the R script (`spin` will assume the
working directory of the code is where the code lives, rather than what
the project working directory is).  
Another problem with the flat directory structure is that you may want
to control where the resulting markdown/HTML reports get generated.
`spin` will create all the outputs in the working directory of the user
(as far as I know, you cannot control that behaviour).

`spinMyR` fixes all these issues, and more. Assuming we are currently in
the `project` directory, we could use the following command to generate
an appropriate tree structure:

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

This non-basic directory structure simply is not achievable with basic
`spin` unfortunately, which is why `spinMyR` was created.

### Example: using one script to analyze different datasets

One particular case when this kind of directory structure makes sense is
when you have different datasets and different analysis scripts, and you
want to be able to run each analysis on each dataset and keep the
results organized. I was involved in a few projects that required me to
adopt that kind of organization, and `spinMyR` was developed especially
for this use. Imagine having a project structured like this:

    - project
       |- data
          |- human.dat
          |- mouse.dat
       |- R
          |- explore.R
          |- analyze.R

We can easily use `spinMyR` to run any of the analysis scripts on any of
the datasets. Let's assume that each analysis script expects there to be
a variable named `DATASET_NAME` that tells the script what data to
operate on. The following `spinMyR` commands illustrate how they can be
used to achieve this structure.

    spinMyR(file = "R/explore.R", outDir = "reportS/human",
            params = list("DATASET_NAME" = "human.dat"))
    spinMyR(file = "R/explore.R", outDir = "reports/mouse",
            params = list("DATASET_NAME" = "mouse.dat"))
    spinMyR(file = "R/analyze.R", outDir = "reports/mouse",
            params = list("DATASET_NAME" = "mouse.dat"))

    - project
       |- data
          |- human.dat
          |- mouse.dat
       |- R
          |- explore.R
          |- analyze.R
       |- reports
          |- human
             |- explore.R
          |- mouse
             |- analyze.R
             |- explore.R

A few things to note:

-   With `spinMyR`, the working directory of the code in the script is
    by default set to be the working directory of the user, rather than
    the script's directory  
-   The output directory by default is the same as the input directory  
-   The figures directory is set to be relative to the output (trust me
    when I say that setting this automatically will save you hours of
    battling with directories)  
-   `spinMyR` accepts both relative and absolute file paths  
-   This example uses the `params = list()` argument, which lets you
    pass variables to the R script. In this case, I use it to tell the
    script what dataset to use, and the script assumes a `DATASET_NAME`
    variable exists. This of course means that the analysis script has
    an external dependency by having a variable that is not populated by
    the script. Some may argue that it's bad form, but I think this is a
    fairly clean solution. Moreover, you can always use a default value
    for variables in your script by having code such as  
    `DATASET_NAME <- ifelse(exists("DATASET_NAME"), DATASET_NAME, "default_data")`

### Live example

To try out the differences between `knitr::spin` and `rsalad::spinMyR`,
I have added a function to the `rsalad` package that will set up a
directory with an R script and a data file so that you can experiment
with both functions to see the differences. See
`?rsalad::setupSpinMyRtest` for more information and to see some simple
testing commands.

### `spin` vs `knit`

If you're asking why even bother with `spin` because you always create
`.Rmd` files, then read this section. Disclaimer: I may have a
simplistic and non-comprehensive view on `spin`, but this is why I use
it.

A common approach useRs can take to producing an R markdown document is
as follows:  
1. Write a bunch of interactive statements in an `.R` script  
2. Once all the R code is in place, polish the code to make sure it runs
smoothly when `source`d  
3. Copy the code to a new `.Rmd` file, add formatting and surround code
in code chunks  
4. You now have duplicated your whole analysis. If you want to change a
variable, you must change it in both the `.R` and the `.Rmd`.

Instead of steps 3 and 4, you can just add the formatting and code
chunks to the original R script (with `#'` and `#+`), so that you still
have all your code in one place. Having to manage only one R script as
opposed to an R script and an Rmarkdown makes my life much simpler. As a
bonus, I also find it much faster to convert R to Rmarkdown like this
because each code chunk only has to be defined in one place (`#+`)
rather than in two place (```` ```{r} ```` before and ```` ``` ````
after).

### More information

To use `spinMyR`, install `rsalad` using
`devtools::install_github("daattali/rsalad")` and run `spinMyR` with
`rsalad::spinMyR()`.

For more information including all features and parameters supported,
see `?rsalad::spinMyR`.
