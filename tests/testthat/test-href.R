context("aes(href)")

color.df <-
  data.frame(x=c(1, 1, 2, 1, 2),
             university=c("Stanford",
               rep("UC Berkeley", 2),
               rep("Oregon State", 2)),
             color=c("red", "blue", "gold", "orange", "black"))
university.df <- as.data.frame(table(color.df$university))
names(university.df) <- c("university", "colors")

test_that("clickSelects and href is an error", {
  viz <-
    list(colors=ggplot()+
         geom_point(aes(x, university, color=color,
                        clickSelects=university, href=color),
                    data=color.df)+
         scale_color_identity())
  expect_error({
    animint2dir(viz, open.browser=FALSE)
  }, "aes(clickSelects) can not be used with aes(href)", fixed=TRUE)
})

test_that("aes(href) becomes <a href>", {
  viz <-
    list(universities=ggplot()+
         geom_bar(aes(university, colors,
                      clickSelects=university),
                  data=university.df, stat="identity"),
         colors=ggplot()+
         geom_point(aes(x, university, color=color,
                        showSelected=university,
                        href=paste0("http://en.wikipedia.org/wiki/", color)),
                    data=color.df, size=5)+
         scale_color_identity(),
         first=list(university="UC Berkeley"))
  info <- animint2HTML(viz)
  expect_links(info,
               c("http://en.wikipedia.org/wiki/blue",
                 "http://en.wikipedia.org/wiki/gold"))
})

## TODO: can we test clicking on the bars to see if they update the
## circles?