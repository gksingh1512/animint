context("interactivity")

## Example: 2 plots, 2 selectors, but only interacting with 1 plot.
data(breakpoints)
only.error <- subset(breakpoints$error,type=="E")
only.segments <- subset(only.error, samples==samples[1])
signal.colors <- c(estimate="#0adb0a",
                   latent="#0098ef")
breakpointError <- 
  list(signal=ggplot()+
       geom_point(aes(position, signal, showSelected=samples),
                  data=breakpoints$signals)+
       geom_line(aes(position, signal), colour=signal.colors[["latent"]],
                 data=breakpoints$imprecision)+
       geom_segment(aes(first.base, mean, xend=last.base, yend=mean,
                        showSelected=segments,
                        showSelected2=samples),
                    colour=signal.colors[["estimate"]],
                    data=breakpoints$segments)+
       geom_vline(aes(xintercept=base,
                      showSelected=segments,
                      showSelected2=samples),
                  colour=signal.colors[["estimate"]],
                  linetype="dashed",
                  data=breakpoints$breaks),
       points=ggplot()+
       geom_point(aes(samples, error,
                      showSelected=segments,
                      id=samples,
                      clickSelects=samples),
                  data=only.error, stat="identity"),
       error=ggplot()+
       geom_vline(aes(xintercept=segments, clickSelects=segments,
                      id=segments),
                  data=only.segments, lwd=17, alpha=1/2)+
       geom_line(aes(segments, error, group=samples,
                     ##key=samples,
                     clickSelects=samples),
                 data=only.error, lwd=4),
       first=list(samples=150, segments=4),
       title="breakpointError (select one model size)")

##animint2dir(breakpointError, "breakpointError-single")
info <- animint2HTML(breakpointError)

test_that("default is single selection", {
  selector.types <- lapply(info$selectors, "[[", "type")
  expect_match(selector.types$samples, "single")
  expect_match(selector.types$segments, "single")
})

test_that("aes(key) geoms have ids", {
  nodes <- getNodeSet(info$html, '//*[@id][@class="geom"]')
  expect_equal(length(nodes), 24)
})

test_that("default is 150 <circle> elements", {
  nodes <- getNodeSet(info$html, '//g[@class="geom1_point_signal"]//circle')
  expect_equal(length(nodes), 150)
})

test_that("default is 4 <line> segments", {
  nodes <- getNodeSet(info$html, '//g[@class="geom3_segment_signal"]//line')
  expect_equal(length(nodes), 4)
})

clickHTML <- function(...){
  v <- c(...)
  stopifnot(length(v) == 1)
  e <- remDr$findElement(names(v), as.character(v))
  e$clickElement()
  Sys.sleep(1)
  XML::htmlParse(remDr$getPageSource(), asText = TRUE)
}  

test_that("clickSelects 300 makes 300 <circle> elements", {
    # randomly fails
  html <- clickHTML(id=300)
  nodes <- getNodeSet(html, '//g[@class="geom1_point_signal"]//circle')
  expect_equal(length(nodes), 300)
})

test_that("clickSelects 1 changes to 1 <line> element", {
  html <- clickHTML(id=1)
  nodes <- getNodeSet(html, '//g[@class="geom3_segment_signal"]//line')
  expect_equal(length(nodes), 1)
})

breakpointError$selector.types <-
  list(segments="multiple",
       samples="single")
breakpointError$title <-
  "breakpointError (select several model sizes)"
info <- animint2HTML(breakpointError)
##animint2dir(breakpointError, "breakpointError-multiple")

test_that("selector.types are converted to JSON", {
  selector.types <- lapply(info$selectors, "[[", "type")
  expect_match(selector.types$samples, "single")
  expect_match(selector.types$segments, "multiple")
})

test_that("default is 150 and 4 <circle> elements", {
  nodes <- getNodeSet(info$html, '//g[@class="geom1_point_signal"]//circle')
  expect_equal(length(nodes), 150)
  nodes <- getNodeSet(info$html, '//g[@class="geom5_point_points"]//circle')
  expect_equal(length(nodes), 4)
})

test_that("clickSelects 300 makes 300 <circle> elements", {
  html <- clickHTML(id=300)
  nodes <- getNodeSet(html, '//g[@class="geom1_point_signal"]//circle')
  expect_equal(length(nodes), 300)
})

test_that("clickSelects 1 adds 1 <line> and 4 <circle>", {
  html <- clickHTML(id=1)
  nodes <- getNodeSet(html, '//g[@class="geom3_segment_signal"]//line')
  expect_equal(length(nodes), 5)
  nodes <- getNodeSet(html, '//g[@class="geom5_point_points"]//circle')
  expect_equal(length(nodes), 8)
})

test_that("clickSelects 4 removes 4 <line> elements and 4 <circle>", {
  html <- clickHTML(id=4)
  nodes <- getNodeSet(html, '//g[@class="geom3_segment_signal"]//line')
  expect_equal(length(nodes), 1)
  nodes <- getNodeSet(html, '//g[@class="geom5_point_points"]//circle')
  expect_equal(length(nodes), 4)
})

test_that("clickSelects 1 removes all <line> elements and all <circle>", {
  html <- clickHTML(id=1)
  nodes <- getNodeSet(html, '//g[@class="geom3_segment_signal"]//line')
  expect_equal(length(nodes), 0)
  nodes <- getNodeSet(html, '//g[@class="geom5_point_points"]//circle')
  expect_equal(length(nodes), 0)
})

## Tornado multiple selection.
data(UStornadoes)
stateOrder <- data.frame(state = unique(UStornadoes$state)[order(unique(UStornadoes$TornadoesSqMile), decreasing=T)], rank = 1:49) # order states by tornadoes per square mile
UStornadoes$state <- factor(UStornadoes$state, levels=stateOrder$state, ordered=TRUE)
UStornadoes$weight <- 1/UStornadoes$LandArea
USpolygons <- map_data("state")
USpolygons$state = state.abb[match(USpolygons$region, tolower(state.name))]
library(plyr)
UStornadoCounts <-
  ddply(UStornadoes, .(state, year), summarize, count=length(state))
seg.color <- "#55B1F7"
tornado.lines <-
  list(map=ggplot()+
       make_text(UStornadoCounts, -100, 50, "year", "Tornadoes in %d")+
       geom_polygon(aes(x=long, y=lat, group=group,
                        id=state,
                        clickSelects=state),
                    data=USpolygons, fill="black", colour="grey") +
       geom_segment(aes(x=startLong, y=startLat, xend=endLong, yend=endLat,
                        showSelected=year),
                    colour=seg.color, data=UStornadoes)+
       scale_fill_manual(values=c(end=seg.color))+
       theme_animint(width=750, height=500)+
       geom_point(aes(endLong, endLat, fill=place, showSelected=year),
                    colour=seg.color,
                  data=data.frame(UStornadoes,place="end")),
       ts=ggplot()+
       geom_text(aes(year, count, showSelected=state, label=state),
                 hjust=0,
                 data=subset(UStornadoCounts, year==max(year)))+
       make_tallrect(UStornadoCounts, "year")+
       geom_line(aes(year, count,
                     showSelected=state,
                     group=state),
                data=UStornadoCounts),
       selector.types=list(state="multiple"),
       first=list(state=c("CA", "NY"), year=1950))
##animint2dir(tornado.lines, "tornado-lines")
info <- animint2HTML(tornado.lines)

test_that("default is 2 <path> and <text> elements", {
  nodes <- getNodeSet(info$html, '//g[@class="geom7_line_ts"]//path')
  expect_equal(length(nodes), 2)
  nodes <- getNodeSet(info$html, '//g[@class="geom5_text_ts"]//text')
  expect_equal(length(nodes), 2)
})

test_that("clickSelects CO adds 1 <path> and 1 <text>", {
  html <- clickHTML(id="CO")
  nodes <- getNodeSet(html, '//g[@class="geom7_line_ts"]//path')
  expect_equal(length(nodes), 3)
  nodes <- getNodeSet(html, '//g[@class="geom5_text_ts"]//text')
  expect_equal(length(nodes), 3)
})

test_that("clickSelects CA removes 1 <path> and 1 <text>", {
  html <- clickHTML(id="CA")
  nodes <- getNodeSet(html, '//g[@class="geom7_line_ts"]//path')
  expect_equal(length(nodes), 2)
  nodes <- getNodeSet(html, '//g[@class="geom5_text_ts"]//text')
  expect_equal(length(nodes), 2)
})

