# mirrorGWAS
## Prerequisites

You will need the following R libraries for running the script.

* [optparse](https://cran.r-project.org/web/packages/optparse/index.html) (>=1.6.0)
* [data.table](https://cran.r-project.org/web/packages/data.table/index.html) (>=1.11.8)
* [dplyr](https://cran.r-project.org/web/packages/dplyr/index.html) (>=0.8.3)
* [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html) (>=1.2.1)
* [ggplot2](https://ggplot2.tidyverse.org) (>=3.3.2)


## Usage

The R script `./scripts/mirrorGWAS.R` takes two GWAS summary statistics with same format and plots out the mirrored GWAS plot. The GWAS files should at least contain columns of chromosome information, the physical location of the SNP, the IDs of the SNPs, and the P-values. The R script takes the user-specified column names as arguments.


The script takes the following input:

| Flag | Description |
|-----|------------------------------------------------------------------------|
| --gwas.top     | The GWAS input displayed at the top of the mirrored plot |
| --gwas.bottom | The GWAS input displayed at the bottom of the mirrored plot |
| --chr.name        | The column name for chromosome |             
| --pos.name        | The column name for physical location |             
| --SNP.name        | The column name for rsIDs |             
| --P.name        | The column name for p-values |             
| --main        | The caption for the mirrored plot |  
| --sig.threshold        | The significance threshold labelling in the plot, default is 5e-8 |           
| --plot.out       | The output path of the mirrored GWAS plot |             

Note that I removed the associations with negative log P-values < 0.02 for speeding up the script. 

The following command takes two GWAS summary statistics `./tables/GWAS.top.txt` and `./tables/GWAS.bottom.txt` as inputs. 

```bash
$ Rscript ./scripts/mirrorGWAS.R \
    --gwas.top ./tables/GWAS.top.txt \
    --gwas.bottom ./tables/GWAS.bottom.txt \
    --chr.name CHR \
    --pos.name BP \
    --SNP.name SNP \
    --P.name P \
    --sig.threshold 5e-8 \
    --main "The mirrored GWAS plot" \
    --plot.out "./plots/mirrorGWAS.png"
```

and plots out a mirrored GWAS at `./plots/mirrorGWAS.png`

![](./plots/mirrorGWAS.png)

The script was based on online resources, feel free to download and modify the code.

