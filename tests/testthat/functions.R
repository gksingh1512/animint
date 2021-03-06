#### helper functions to be reused in testing #####

#' Apply `animint2dir` to a list ggplots and extract the (rendered) page source via RSelenium
#' 
#' @details This function assumes an object named 'context' exists -- this should be a 
#' character string as it will be used specify a directory which is bound to a testing context.
#' @author Carson Sievert
#' @param plotList A named list of ggplot2 objects
#' @param dir a name for a directory (this should be specific to a testing context)
#' @param subdir a name for a subdirectory (under dir) to place files
animint2HTML <- function(plotList) {
  ## When we do test_package("animint") it does
  ## setwd("animint/tests/testthat") so when we call this function
  ## inside of the tests, it will write the viz to
  ## animint/tests/testthat/htmltest, so we also need to start the
  ## servr in animint/tests/testthat.

  ##on.exit(unlink("htmltest", recursive=TRUE))
  res <- animint2dir(plotList, out.dir="htmltest", open.browser = FALSE)
  address <- "http://localhost:4848/htmltest/"
  remDr$navigate(address)
  ## find/get methods are kinda slow in RSelenium (here is an example)
  ## remDr$navigate(attr(info, "address"))
  ## t <- remDr$findElement(using = 'class name', value = 'title')
  ## t$getElementText()[[1]]

  ## I think parsing using XML::htmlParse() and XML::getNodeSet() is faster/easier
  res$html <- XML::htmlParse(remDr$getPageSource(), asText = TRUE)
  res
}

expect_transform <- function(actual, expected, context = "translate", tolerance = 5) {
  # supports multiple contexts
  nocontext <- gsub(paste(context, collapse = "||"), "", actual)
  # reduce to some 'vector' of numbers: (a, b, c, ...)
  vec <- gsub("\\)\\(", ",", nocontext)
  clean <- gsub("\\)", "", gsub("\\(", "", vec))
  nums <- as.numeric(strsplit(clean, split = "\\,")[[1]])
  expect_equal(nums, expected, tolerance, scale = 1)
}

expect_links <- function(html, urls){
  expect_attrs(html, "a", "href", urls)
}

expect_attrs <- function(html, element.name, attr.name, urls){
  stopifnot(is.character(urls))
  xpath <- paste0("//", element.name)
  pattern <- paste0(attr.name, "$")
  node.set <- getNodeSet(html, xpath)
  rendered.urls <- rep(NA, length(node.set))
  for(node.i in seq_along(node.set)){
    node <- node.set[[node.i]]
    node.attrs <- xmlAttrs(node)
    href.i <- grep(pattern, names(node.attrs))
    if(length(href.i)==1){
      rendered.urls[[node.i]] <- node.attrs[[href.i]]
    }
  }
  for(u in urls){
    expect_true(u %in% rendered.urls)
  }
}

expect_styles <- function(html, styles.expected){
  stopifnot(is.list(styles.expected))
  stopifnot(!is.null(names(styles.expected)))
  geom <- getNodeSet(html, '//*[@class="geom"]')
  style.strs <- as.character(sapply(geom, function(x) xmlAttrs(x)["style"]))
  pattern <-
    paste0("(?<name>\\S+?)",
           ": *",
           "(?<value>.+?)",
           ";")
  style.matrices <- str_match_all_perl(style.strs, pattern)
  for(style.name in names(styles.expected)){
    style.values <- sapply(style.matrices, function(m)m[style.name, "value"])
    for(expected.regexp in styles.expected[[style.name]]){
      ## Test that one of the observed styles matches the expected
      ## regexp.
      expect_match(style.values, expected.regexp, all=FALSE)
    }
  }
}

## Parse the first occurance of pattern from each of several strings
## using (named) capturing regular expressions, returning a matrix
## (with column names).
str_match_perl <- function(string,pattern){
  stopifnot(is.character(string))
  stopifnot(is.character(pattern))
  stopifnot(length(pattern)==1)
  parsed <- regexpr(pattern,string,perl=TRUE)
  captured.text <- substr(string,parsed,parsed+attr(parsed,"match.length")-1)
  captured.text[captured.text==""] <- NA
  captured.groups <- do.call(rbind,lapply(seq_along(string),function(i){
    st <- attr(parsed,"capture.start")[i,]
    if(is.na(parsed[i]) || parsed[i]==-1)return(rep(NA,length(st)))
    substring(string[i],st,st+attr(parsed,"capture.length")[i,]-1)
  }))
  result <- cbind(captured.text,captured.groups)
  colnames(result) <- c("",attr(parsed,"capture.names"))
  result
}

## Parse several occurances of pattern from each of several strings
## using (named) capturing regular expressions, returning a list of
## matrices (with column names).
str_match_all_perl <- function(string,pattern){
  stopifnot(is.character(string))
  stopifnot(is.character(pattern))
  stopifnot(length(pattern)==1)
  parsed <- gregexpr(pattern,string,perl=TRUE)
  lapply(seq_along(parsed),function(i){
    r <- parsed[[i]]
    starts <- attr(r,"capture.start")
    if(r[1]==-1)return(matrix(nrow=0,ncol=1+ncol(starts)))
    names <- attr(r,"capture.names")
    lengths <- attr(r,"capture.length")
    full <- substring(string[i],r,r+attr(r,"match.length")-1)
    subs <- substring(string[i],starts,starts+lengths-1)
    m <- matrix(c(full,subs),ncol=length(names)+1)
    colnames(m) <- c("",names)
    if("name" %in% names){
      rownames(m) <- m[, "name"]
    }
    m
  })
}

getTextValue <- function(tick)xmlValue(getNodeSet(tick, "text")[[1]])
getTransform <- function(tick)xmlAttrs(tick)[["transform"]]
# get difference between axis ticks in both pixels and on original data scale
# @param doc rendered HTML document
# @param ticks which ticks? (can use text label of the tick)
# @param axis which axis?
getTickDiff <- function(doc, ticks = c(1, 2), axis = "x"){
  g.ticks <- getNodeSet(doc, "g[@class='tick major']")
  tick.labs <- sapply(g.ticks, getTextValue)
  names(g.ticks) <- tick.labs
  g.ticks <- g.ticks[ticks]
  tick.transform <- sapply(g.ticks, getTransform)
  expr <- if (axis == "x") "translate[(](.*?),.*" else "translate[(][0-9]+?,(.*)[)]"
  txt <- sub(expr, "\\1", tick.transform)
  num <- as.numeric(txt)
  val <- abs(diff(num))
  attr(val, "label-diff") <- diff(as.numeric(names(tick.transform)))
  val
}
both.equal <- function(x, tolerance = 0.1){
  if(is.null(x) || !is.vector(x) || length(x) != 2){
    return(FALSE)
  }
  isTRUE(all.equal(x[[1]], x[[2]], tolerance))
}

# normalizes tick differences obtained by getTickDiff
normDiffs <- function(xdiff, ydiff, ratio = 1) {
  xlab <- attr(xdiff, "label-diff")
  ylab <- attr(ydiff, "label-diff")
  if (is.null(xlab) || is.null(ylab)) warning("label-diff attribute is missing")
  c(ratio * xdiff / xlab, ydiff / ylab)
}


