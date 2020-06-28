
Sys.setlocale(category = "LC_TIME", locale = "pt_BR.UTF-8")
options(warn=1)
suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("rmarkdown"))
suppressPackageStartupMessages(library("knitr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("patchwork"))
knitr::opts_chunk$set(echo = FALSE, warning=FALSE, message=FALSE)
source("https://raw.githubusercontent.com/covid19br/covid19br.github.io/master/_src/fct/funcoes.R")

nome_titulos  <-  "Uberaba"

option_list <- list(
  make_option("--d", default = "t",
              help = ("Data para confecção do relatório. O padrão é t para hoje (today), com formato AAAA-MM-DD"),
              metavar = "Data"))

parser_object <- OptionParser(usage = "Rscript %prog\n",
                              option_list = option_list,
                              description = "Script para compilar reports personalizados")
opt <- parse_args(parser_object, args = commandArgs(trailingOnly = TRUE), positional_arguments=TRUE)

tempo <- opt$options$d

dados.br <- read.csv("./UberabaCov19.csv", as.is = TRUE)
dados.clean <- dados.br[, c("data", "casos.acumulados")]
dados.clean$data <- as.Date(dados.clean$data)
names(dados.clean) <- c("day", "confirmed.cases")

nconf <- dados.clean[!duplicated(dados.clean),]
nconf.zoo <- zoo(nconf[,-1], as.Date(nconf$day)) %>%
  diazero(limite = 1)
## Projecoes
exp.5d <- forecast.exponential(nconf.zoo, start = length(time(nconf.zoo))-4,days.forecast = 5)
data.final <- format(time(exp.5d)[5], format="%d de %B")

render(input = "./projecoes_observatorio_modelo.Rmd",
       output_file = paste0("./Reports/", "Uberaba_", ifelse(tempo == "t", format(Sys.time(), '%d-%m-%Y_%Hh%Mmin%Ss'), format(as.Date(tempo), "%d-%m-%Y")), ".pdf"),
       encoding = "utf8")
