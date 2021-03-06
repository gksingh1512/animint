context("rotate")

ss <- data.frame(State=paste("some long text", c("CA", "NY")),
                 Prop.Inv=c(0, 1),
                 Year=c(1984, 2015))

fg <- ggplot() +
  geom_point(aes(x=State, y=Prop.Inv, showSelected=Year), data=ss) +
  xlab("STATE SOME REALLY REALLY LONG TEXT THAT MAY OVERLAP TICKS")+
  theme_animint(width=600, height=400) 
sg <- ggplot() +
  stat_summary(data=ss, aes(Year, Year, clickSelects=Year),
               fun.y=length, geom="bar")

getTicks <- function(html, p.name){
  xp <- sprintf('//svg[@id="%s"]//g[@id="xaxis"]//text', p.name)
  nodes <- getNodeSet(html, xp)
  stopifnot(length(nodes) > 0)
  sapply(nodes, xmlAttrs)
}

expect_rotate_anchor <- function(info, rotate, anchor){
  not <- getTicks(info$html, 'not')
  expect_match(not["style", ], "text-anchor: middle", fixed=TRUE)
  expect_match(not["transform", ], "rotate(0", fixed=TRUE)
  rotated <- getTicks(info$html, 'rotated')
  expect_match(rotated["style", ], paste("text-anchor:", anchor), fixed=TRUE)
  expect_match(rotated["transform", ], paste0("rotate(", rotate), fixed=TRUE)

  e.axis <- remDr$findElement(using="css selector", "g#xaxis")
  e.text <- e.axis$findChildElement("css selector", "text")
  tick.loc <- e.text$getElementLocation()
  tick.size <- e.text$getElementSize()
  ## Subtract a magic number that lets the test pass for un-rotated
  ## labels in firefox.
  tick.bottom.y <- tick.loc$y + tick.size$height - 6
  e.title <- remDr$findElement("css selector", "text#xtitle")
  title.loc <- e.title$getElementLocation()
  expect_true(tick.bottom.y < title.loc$y)
}

test_that('no axis rotation is fine', {
  map <-
    list(rotated=fg,
         not=sg)
  info <- animint2HTML(map)
  expect_rotate_anchor(info, "0", "middle")
})

test_that('axis.text.x=element_text(angle=90) means transform="rotate(-90)"', {
  map <-
    list(rotated=fg+theme(axis.text.x=element_text(angle=90)),
         not=sg)
  info <- animint2HTML(map)
  expect_rotate_anchor(info, "-90", "end")
})

test_that('axis.text.x=element_text(angle=70) means transform="rotate(-70)"', {
  map <-
    list(rotated=fg+theme(axis.text.x=element_text(angle=70)),
         not=sg)
  info <- animint2HTML(map)
  expect_rotate_anchor(info, "-70", "end")
})

test_that('and hjust=1 means style="text-anchor: end;"', {
  map <-
    list(rotated=fg+theme(axis.text.x=element_text(angle=70, hjust=1)),
         not=sg)
  info <- animint2HTML(map)
  expect_rotate_anchor(info, "-70", "end")
})

test_that('and hjust=0 means style="text-anchor: start;"', {
  map <-
    list(rotated=fg+theme(axis.text.x=element_text(angle=70, hjust=0)),
         not=sg)
  info <- animint2HTML(map)
  expect_rotate_anchor(info, "-70", "start")
})

test_that('and hjust=0.5 means style="text-anchor: middle;"', {
  map <-
    list(rotated=fg+theme(axis.text.x=element_text(angle=70, hjust=0.5)),
         not=sg)
  info <- animint2HTML(map)
  expect_rotate_anchor(info, "-70", "middle")
})

test_that('hjust=0.75 is an error', {
  map <-
    list(rotated=fg+theme(axis.text.x=element_text(hjust=0.75)),
         not=sg)
  expect_error({
    info <- animint2HTML(map)
  }, "animint only supports hjust values 0, 0.5, 1")
})

## TODO: also test for y axis rotation.

