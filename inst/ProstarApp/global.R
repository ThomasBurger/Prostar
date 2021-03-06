
library(DAPAR)
library(DAPARdata)
library(shiny)
library(rhandsontable)
library(data.table)
library(shinyjs)
library(shinyAce)
library(highcharter)
library(tidyr)
library(dplyr)
library(rhandsontable)
library(data.table)
library(reshape2)
library(DT)
library(MSnbase)
library(openxlsx)
library(sm)
library(imp4p)
library(highcharter)
library(webshot)
library(htmlwidgets)


# Declaration of global variables


resolution <- 300
pngWidth <- 1200
pngHeight <- 1200
zoomWebshot <- 3

commandLogFile <- "cmdLog.R"
logfilename <- "log.txt"
gFileExtension <- list(txt = ".txt",
                       tsv = ".tsv",
                        msnset = ".MSnset",
                        excel = ".xlsx",
                        zip = ".zip")

gAgregateMethod <- list("none" = "none",
                        "sum overall" = "sum overall",
                        "mean" = "mean",
                        "sum on top n" = "sum on top n")



list_org_db <- data.frame(
                shortName = c("org.Ag.eg.db","org.At.tair.db","org.Bt.eg.db",
                 "org.Cf.eg.db","org.Gg.eg.db","org.Pt.eg.db",
                 "org.EcK12.eg.db","org.EcSakai.eg.db","org.Dm.eg.db",
                 "org.Hs.eg.db","org.Pf.plasmo.db","org.Mm.eg.db",
                 "org.Ss.eg.db","org.Rn.eg.db","org.Mmu.eg.db",
                 "org.Ce.eg.db","org.Xl.eg.db","org.Sc.sgd.db", "org.Dr.eg.db"),
                longName = c("Anopheles (org.Ag.eg.db)",
                             "Arabidopsis (org.At.tair.db)",
                             "Bovine (org.Bt.eg.db)",
                             "Canine (org.Cf.eg.db)",
                             "Chicken (org.Gg.eg.db)",
                             "Chimp (org.Pt.eg.db)",
                             "E coli strain K12 (org.EcK12.eg.db)",
                             "E coli strain Sakai (org.EcSakai.eg.db)",
                             "Fly (org.Dm.eg.db)",
                             "Human (org.Hs.eg.db)",
                            "Malaria (org.Pf.plasmo.db)",
                             "Mouse (org.Mm.eg.db)",
                             "Pig (org.Ss.eg.db)",
                             "Rat (org.Rn.eg.db)",
                             "Rhesus (org.Mmu.eg.db)",
                             "Worm (org.Ce.eg.db)",
                             "Xenopus (org.Xl.eg.db)",
                             "Yeast (org.Sc.sgd.db)",
                             "Zebrafish (org.Dr.eg.db)"),
                stringsAsFactors = FALSE
                 )
rownames(list_org_db) <- list_org_db$shortName


gFiltersList <- list()
gFiltersList[["None"]] <- "none"
gFiltersList[["Whole matrix"]] <- "wholeMatrix"
gFiltersList[["For every condition"]] <- "allCond"
gFiltersList[["At least one condition"]] <- "atLeastOneCond"

gDatasets <- list()
gDatasets[["NA"]] <- "none"

gFilterNone <- gFiltersList[["None"]]
gFilterWholeMat <- gFiltersList[["Whole matrix"]]
gFilterAllCond <- gFiltersList[["For every condition"]]
gFilterOneCond <- gFiltersList[["At least one condition"]]

# variables for filtering the data
gReplaceAllZeros <- "replaceAllZeros"
gLogTransform <- "Log2 tranformed data"
gFilterTextPrefix <- "Filtered with"

pData.complete.list <- list("Label" = "Label", 
                            "Bio.Rep" = "Bio. rep.",
                            "Tech.Rep" = "Tech. rep.", 
                            "Analyt.Rep" = "An. Rep.")


normMethods <- list("None" = "None",
                    "Global Alignment" = "Global Alignment",
                    "Quantile Centering" = "Quantile Centering",
                    "Mean Centering" = "Mean Centering" 
 )


imputationAlgorithms <- list("None" = "None",
                             "imp4p" = "imp4p",
                             "Basic methods" = "Basic methods")

basicMethodsImputationAlgos <- list(
                             #"dummy censored" = "dummy censored",
                                "KNN" = "KNN",
                            "MLE" = "MLE",
                            "detQuantile" = "detQuantile")


JSCSSTags <- function() 
{ 
list(
    tags$script(src="js/jquery.js",type="text/javascript"),
    tags$script(src="js/jquery.dataTables.js",type="text/javascript"),
    tags$link(href='css/jquery.dataTables.css', rel="stylesheet", 
            type="text/css"), 
    tags$link(href='css/dataTables.tableTools.css', rel="stylesheet", 
            type="text/css"), 
    tags$script(src='js/dataTables.tableTools.js'),
    tags$link(rel="stylesheet", type="text/css",href="css/style.css"),
    tags$script(type="text/javascript", src = "busy.js")
)
}

DT_pagelength <- 15



reactiveDataTable <- function(func, ...) 
{
    reactive(function() 
    {
    classNames <- 
        getOption("shiny.table.class", "table table-striped table-bordered")
        classID = getOption("shiny.table.id", "example")
    data <- func()
    if (is.null(data) || is.na(data)) 
        return("")
    return(paste(
        capture.output(
        print(xtable(data, ...), 
        type = "html", 
        html.table.attributes = 
            paste("class=\"", classNames, "\" id=\"", classID, "\"", sep = ""),
            ...)), collapse = "\n"))

})
}


# for layout
resizeComponents <- function(){
tags$head(
    tags$style(type="text/css", "textarea { max-width: 400px; }"),
    tags$style(type='text/css', 
            ".well { max-width: 300px; max-height=300px;}"),
    tags$style(type='text/css', ".span4 { max-width: 300px; }")
)
}


GetFilterText <- function(type, seuil){
return (
    paste(gFilterTextPrefix," ",type , " (threshold = ", seuil, " ).", sep=""))
}



gGraphicsFilenames <- list(
    #histoMVPerLines_DS = "histoMissvaluesPerLines_DS.png",
    #histoMVPerLinesConditions_DS = "histoMVPerLinesPerConditions_DS.png",
    #histoMV = "histoMV_DS.png",
    #histoMVPerLines = "histoMissvaluesPerLines.png",
    #histoMVPerLinesConditions = "histoMVPerLinesPerConditions.png",
    
    histoMV_Image_DS = "histoMV_Image_DS.png",
    histo_missvalues_per_lines_DS = "histo_missvalues_per_lines_DS.png",
    histo_missvalues_per_lines_per_conditions_DS = "histo_missvalues_per_lines_per_conditions_DS.png",
    
    histoMV_Image_DS_BeforeFiltering = "histoMV_Image_DSBeforeFiltering.png",
    histo_missvalues_per_lines_DS_BeforeFiltering = "histo_missvalues_per_lines_DSBeforeFiltering.png",
    histo_missvalues_per_lines_per_conditions_DS_BeforeFiltering = "histo_missvalues_per_lines_per_conditions_DSBeforeFiltering.png",
    
    
    corrMatrix = "corrMatrix.png",
    heatmap = "heatmap.png",
    boxplot = "boxplot.png",
    violinplot = "violinplot.png",
    varDist = "varDist.png",
    densityPlot = "densityPlot.png",
    densityPlotBeforeNorm = "densityPlotBeforeNorm.png",
    propContRev = "propContRev.png",
    boxplotBeforeNorm = "boxplotBeforeNorm.png",
    compareNorm = "compareNorm.png",
    MVtypePlot_BeforeImputation = "MVtypePlot_BeforeImputation.png",
    imageNA_BeforeImputation = "imageNA_BeforeImputation.png",
    MVtypePlot_AfterImputation = "MVtypePlot_AfterImputation.png",
    imageNA_AfterImputation = "imageNA_AfterImputation.png",
    AgregMatUniquePeptides = "AgregMatUniquePeptides.png",
    AgregMatSharedPeptides = "AgregMatSharedPeptides.png",
    volcanoPlot_1 = "volcanoPlot_1.png",
    volcanoPlot_3 = "volcanoPlot_3.png",
    calibrationPlot = "calibrationPlot.png",
    calibrationPlotAll = "calibrationPlotAll.png",
    GOEnrichDotplot = "GOEnrichDotplot.png",
    GOEnrichBarplot = "GOEnrichBarplot.png",
    GOClassification_level3 = "GOClassification_level2.png",
    GOClassification_level3 = "GOClassification_level3.png",
    GOClassification_level3 = "GOClassification_level4.png"
)

defaultGradientRate <- 0.9




# variables for different extensions files format
gFileFormatExport <- list(msnset = "MSnset",excel = "Excel")

# Not used yet 
GetLogFilename <- function(){
return(paste("loG__",Sys.getpid(), ".txt", sep=""))
}

#---------------------------------------------------------
GetChoices <- function(){

choix <- list.dirs(path=dir, recursive=FALSE)
names <- c()
for (i in 1:length(choix)){
    names[i] <-
    unlist(strsplit(choix[i], '/'))[length(unlist(strsplit(choix[i], '/')))]
}
return(setNames(names, names))
}


#--------------------------------------------------------
DeleteFileExtension <- function(name){
return(strsplit(name,'.', fixed=T)[[1]][1])}

#--------------------------------------------------------
GetExtension <- function(name){
    temp <- unlist(strsplit(name,'.', fixed=T))
    return(last(temp))
    }



#' busyIndicator
busyIndicator <- function(text = "Calculation in progress..",
                        img = "images/ajax-loader.gif", wait=1000) {
tagList(
    singleton(tags$head(
    tags$link(rel="stylesheet", 
            type="text/css",href="busyIndicator/busyIndicator.css")
    ))
    ,div(class="busy-indicator",p(text),img(src=img))
    ,tags$script(sprintf(
    "	setInterval(function(){
    if ($('html').hasClass('shiny-busy')) {
    setTimeout(function() {
    if ($('html').hasClass('shiny-busy')) {
    $('div.busy-indicator').show()
    }
    }, %d)
    } else {
    $('div.busy-indicator').hide()
    }
},100)
    ",wait)
    )
)	
}

########################################################
# FROM :http://stackoverflow.com/questions/35271661/update-shiny-r-custom-progressbar/39265225#39265225
progressBar2 <- function(inputId=NULL, value=0, label=FALSE, color="info", 
                         size=NULL,
                         striped=FALSE, active=FALSE, vertical=FALSE) {
    stopifnot(is.numeric(value))
    if (value < 0 || value > 100)
        stop("'value' should be in the range from 0 to 100", call. = FALSE)
    #if (!(color %in% shinydashboard:::validColors || color %in% shinydashboard:::validStatuses))
    #    stop("'color' should be a valid status or color.", call. = FALSE)
    if (!is.null(size))
        size <- match.arg(size, c("sm", "xs", "xxs"))
    text_value <- paste0(value, "%")
    if (vertical)
        style <- htmltools::css(height = text_value, `min-height` = "2em")
    else
        style <- htmltools::css(width = text_value, `min-width` = "2em")
    htmltools::tags$div(
        class = "progress",
        class = if (!is.null(size)) paste0("progress-", size),
        class = if (vertical) "vertical",
        class = if (active) "active",
        htmltools::tags$div(
            class = "progress-bar",
            class = paste0("progress-bar-", color),
            class = if (striped) "progress-bar-striped",
            id = paste0(inputId),
            role = "progressbar",
            style = style,
            `aria-valuemax` = 100,
            `aria-valuemin` = 0,
            `aria-valuenow` = value,
            htmltools::tags$span(
                id = "text_value",
                class = if (!label) "sr-only", 
                text_value)
        )
    )
}


updatePB <- function(session,inputId=NULL,value=NULL,label=NULL,color=NULL,text_value = NULL,size=NULL,striped=NULL,active=NULL,vertical=NULL) {
    data <- dropNulls(list(id=inputId,value=value,label=label,color=color,text_value=text_value,size=size,striped=striped,active=active,vertical=vertical))
    
    session$sendCustomMessage("updateprogress",data)
}

dropNulls <-function(x) {
    x[!vapply(x,is.null,FUN.VALUE=logical(1))]
}




########################################################

# Author: https://jackolney.github.io/2016/shiny/
progressGroup <- function(text, value, min = 0, max = value, color = "aqua") {
    stopifnot(is.character(text))
    stopifnot(is.numeric(value))
    if (value < min || value > max)
        stop(sprintf("'value' should be in the range from %d to %d.", min, max), call. = FALSE)
    tags$div(
        class = "progress-group",
        tags$span(class = "progress-text", text),
        tags$span(class = "progress-number", sprintf("%d / %d", value, max)),
        prgoressBar(round(value / max * 100), color = color, size = "sm")
    )
}


findSequences <- function(v){
    diff <- v[2:length(v)] - v[1:(length(v)-1)]
    
    if (!all(diff != 1)){
        s <- rle(diff == 1)
        begin <- c(0, cumsum(s$lengths))[which(s$values)] + 1
        end <- cumsum(s$lengths)[which(s$values)] +1

        seq <- "c("
        temp <- NULL
        i <- 1
    
        while(i < begin[1] && i < length(v))
        {
            seq <- paste(seq, v[i], ",", sep="")
            i <- i + 1
        }
    
        for (i in 1:length(begin)){
         seq <- paste(seq, v[begin[i]], ":", v[end[i]], sep="")
            if (i < length(begin)) {seq <- paste(seq, ",", sep="")}
            if (i < length(begin) && ((begin[i+1] - end[i]) > 1)){
                for(j in c((end[i]+1):(begin[i+1]-1))) {
                    seq <- paste(seq, v[j], ",", sep="")
                }
            }
        }
    
        i <- last(end) +1
        if (i <= length(v)) {seq <- paste(seq, ",", sep="")}
        while(i <= length(v))
        {
            seq <- paste(seq, v[i])
            if (i < length(v)) {seq <- paste(seq, ",", sep="")}
            i <- i +1
        }
    
    
        seq <- paste(seq, ")", sep="")
    
        }
    else 
        {
        seq <- paste("c(", paste(diff, collapse=","),")", sep="")
        }
    return(seq)
}



typeProtein <- "protein"
typePeptide <- "peptide"

calibMethod_Choices <- c("st.boot", "st.spline", 
                         "langaas","jiang", "histo", 
                         "pounds", "abh","slim", 
                         "Benjamini-Hochberg", 
                         "numeric value")

anaDiffMethod_Choices <- c("Limma", "Welch")


G_noneStr <- "None"
G_emptyStr <- ""
G_heatmapDistance_Choices <- list(euclidean ="euclidean",
                                  manhattan="manhattan")

G_heatmapLinkage_Choices <- list(average="average",
                                 ward.D="ward.D")


G_logFC_Column <- "logFC"


G_sourceOfProtID_Choices <- c("Select a column in dataset" = "colInDataset",
  "Choose a file" = "extFile")

G_ontology_Choices <- c("Molecular Function (MF)"="MF" , 
                        "Biological Process (BP)" = "BP", 
                        "Cellular Component (CC)" = "CC")

G_universe_Choices <- c("Entire organism" = "Entire organism",
  "Entire dataset" = "Entire dataset",
  "Custom" = "Custom")

G_pAdjustMethod_Choices <- c("BH", "fdr", "None")

G_imp4PDistributionType_Choices <- c("uniform" = "unif", "beta" = "beta")

G_ConvertDataID_Choices <- c("Auto ID" = "Auto ID", "User ID" = "user ID")
G_exportFileFormat_Choices <- c( "MSnset","Excel")