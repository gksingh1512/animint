Animint Tutorial
========================================================

This tutorial is designed to demonstrate animint, a package that converts ggplot2 plots into d3 javascript graphics. Animint allows you to make interactive web-based graphics using familiar R methods. In addition, animint allows graphics to be animated and respond to user clicks.

Contents
---------------------------------------------------------
* [Introduction](index.html#intro)
* [Tornado Example](tornadoes.html#tornadoes) - see what animint can do, including explanations of clickSelects, showSelected, and animations. 
* [Climate Example](climate.html) - another demonstration of using animint with multiple linked plots and animation.
* [Examples of Geoms](geoms.html) - explanations of how to use statistics and certain geoms in animint, demonstrations of most geoms that animint supports. 
  * [Lines](#lines)
  * [Points](#points)
    * [Interactive Points](#interactive points) - short introduction to clickSelects and showSelected with familiar geoms.
  * [Other Geoms](#othergeoms) - abline, area, bar, contour, density,...  
This section also includes discussions of problem statistics and some unimplemented geoms and how to get around them.




<a name="lines"/>
Lines
---------------------------------------------------------

### Simple lines
This should work exactly as in ggplot2.

```r
#' Generate data
data <- data.frame(x=rep(1:10, times=5), group = rep(1:5, each=10))
data$lt <- c("even", "odd")[(data$group%%2+1)] # linetype
data$group <- as.factor(data$group)
data$y <- rnorm(length(data$x), data$x, .5) + rep(rnorm(5, 0, 2), each=10)

#' Simple line plot
p1 <- ggplot() + geom_line(data=data, aes(x=x, y=y, group=group)) + 
  ggtitle("geom_line")
p1
```

![plot of chunk linessimple](figure/linessimple1.png) 

```r


#' Simple line plot with colours...
p2 <- ggplot() + geom_line(data=data, aes(x=x, y=y, colour=group, group=group)) +
  ggtitle("geom_line + scale_colour_discrete")
p2
```

![plot of chunk linessimple](figure/linessimple2.png) 

```r

gg2animint(list(p1=p1, p2=p2), out.dir="geoms/linessimple")
```

[Animint plot](geoms/linessimple/index.html)

### Linetypes
ggplot2 has several methods of linetype specification, all of which are supported in animint. 

```r
#' Simple line plot with colours and linetype
p3 <- ggplot() + geom_line(data=data, aes(x=x, y=y, colour=group, group=group, linetype=lt)) +
  ggtitle("geom_line + scale_linetype_manual")
p3
```

![plot of chunk linetypes](figure/linetypes1.png) 

```r

#' Use automatic linetypes from ggplot with coerced factors
p4 <- ggplot() + geom_line(data=data, aes(x=x, y=y, colour=group, group=group, linetype=group)) +
  ggtitle("geom_line + scale_linetype automatic")
p4
```

![plot of chunk linetypes](figure/linetypes2.png) 

```r

#' Manually specify linetypes using <length, space, length, space...> notation
data$lt <- rep(c("2423", "2415", "331323", "F2F4", "solid"), each=10)
p5 <- ggplot() + geom_line(data=data, aes(x=x, y=y, colour=group, group=group, linetype=lt)) + 
  scale_linetype_identity("group", guide="legend", labels = c("1", "2", "3", "4", "5")) + 
  scale_colour_discrete("group") + 
  ggtitle("Manual Linetypes: dash-space length")
p5
```

![plot of chunk linetypes](figure/linetypes3.png) 

```r

#' All possible linetypes
lts <- scales::linetype_pal()(13)
lt1 <- data.frame(x=0, xend=.25, y=1:13, yend=1:13, lt=lts, lx = -.125)
p6 <- ggplot()+geom_segment(data=lt1, aes(x=x, xend=xend, y=y, yend=yend, linetype=lt)) + 
  scale_linetype_identity() + geom_text(data=lt1, aes(x=lx, y=y, label=lt), hjust=0) + 
  ggtitle("Scales package: all linetypes")

lts2 <- c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash")
lt2 <- data.frame(x=0, xend=.25, y=1:6, yend=1:6, lt=lts2, lx=-.125)
p7 <- ggplot() + geom_segment(data=lt2, aes(x=x, xend=xend, y=y, yend=yend, linetype=lt)) + 
  scale_linetype_identity() + geom_text(data=lt2, aes(x=lx, y=y, label=lt), hjust=0) +
  ggtitle("Named linetypes")

gg2animint(list(p3=p3, p4=p4, p5=p5, p6=p6, p7=p7), out.dir="geoms/linetypes")
```

[Animint Plot](geoms/linetypes/index.html)

### Alpha scales and lines

```r
#' Spaghetti Plot Data
n <- 500
pts <- 10
data2 <- data.frame(x=rep(1:pts, times=n), group = rep(1:n, each=pts))
data2$group <- as.factor(data2$group)
data2$y <- rnorm(length(data2$x), data2$x*rep(rnorm(n, 1, .25), each=pts), .25) + rep(rnorm(n, 0, 1), each=pts)
data2$lty <- "solid"
data2$lty[which(data2$group%in%subset(data2, x==10)$group[order(subset(data2, x==10)$y)][1:floor(n/10)])] <- "3133"
data2 <- ddply(data2, .(group), transform, maxy = max(y), miny=min(y))
data2$below0 <- factor(sign(data2$miny)<0)
  
qplot(data=data2, x=x, y=y, group=group, geom="line", alpha=I(.2))
```

![plot of chunk alphalines](figure/alphalines1.png) 

```r

#' scale_alpha
p8 <- ggplot() + geom_line(data=data2, aes(x=x, y=y, group=group), alpha=.1) +
  ggtitle("Constant alpha")
p8
```

![plot of chunk alphalines](figure/alphalines2.png) 

```r

p9 <- ggplot() + geom_line(data=subset(data2, as.numeric(group) < 50), 
                           aes(x=x, y=y, group=group, linetype=lty), alpha=.2) +
  scale_linetype_identity() + 
  ggtitle("Constant alpha, I(linetype)")
p9
```

![plot of chunk alphalines](figure/alphalines3.png) 

```r

p10 <- ggplot() + geom_line(data=subset(data2, as.numeric(group) < 50), 
                            aes(x=x, y=y, group=group, linetype=below0, alpha=maxy)) + 
  scale_alpha_continuous(range=c(.1, .5)) + 
  ggtitle("Continuous alpha")
p10
```

![plot of chunk alphalines](figure/alphalines4.png) 

```r

#' Size Scaling
p11 <- ggplot() + geom_line(data=subset(data2, as.numeric(group)%%50 ==1), 
                            aes(x=x, y=y, group=group, size=(floor(miny)+3)/3)) + 
  scale_size_continuous("Line Size", range=c(1,3)) +
  ggtitle("Continuous size")
p11
```

![plot of chunk alphalines](figure/alphalines5.png) 

```r

p12 <- ggplot() + geom_line(data=data2, aes(x=x, y=y, group=group, alpha=miny, colour=maxy)) + 
  scale_alpha_continuous(range=c(.1, .3)) + 
  ggtitle("Continuous Alpha and Colour")
p12
```

![plot of chunk alphalines](figure/alphalines6.png) 

```r
gg2animint(list(p8=p8, p9=p9, p10=p10, p11=p11, p12=p12), out.dir="geoms/alphalines")
```

[Animint plot](geoms/alphalines/index.html)

<a name="points"/>
Points
---------------------------------------------------------
In general, points are exactly the same in animint and ggplot2, with two exceptions:
* Shapes are not supported in animint at this time, because d3 only provides about 6 shapes total, and it is thus not possible to map shapes from R to d3 faithfully. 
* In R, most shapes do not have separate colour and fill attributes. In d3, points have both colour and fill attributes, so it is possible to get at least 2 shapes with animint: filled and open circles. 
  * If you specify colour but not fill, animint will attempt to set fill for you. If you want open circles, use fill=NA. 
  * Specifying colour and fill will work in animint, but may not show up on the ggplot2 plot, as ggplot2 does not typically use the fill aesthetic for points.
### **scale\_colour** and **geom\_point**

```r
# Randomly generate some data
scatterdata <- data.frame(x=rnorm(100, 50, 15))
scatterdata$y <- with(scatterdata, runif(100, x-5, x+5))
scatterdata$xnew <- round(scatterdata$x/20)*20
scatterdata$xnew <- as.factor(scatterdata$xnew)
scatterdata$class <- factor(round(scatterdata$x/10)%%2, labels=c("high", "low"))
scatterdata$class4 <- factor(rowSums(sapply(quantile(scatterdata$x)+c(0,0,0,0,.1), function(i) scatterdata$x<i)), levels=1:4, labels=c("high", "medhigh", "medlow", "low"), ordered=TRUE)

s1 <- ggplot() + geom_point(data=scatterdata, aes(x=x, y=y)) +
  xlab("very long x axis label") + 
  ylab("very long y axis label") +
  ggtitle("Titles are awesome")
s1
```

![plot of chunk pointssimple](figure/pointssimple1.png) 

```r

#' Colours, Demonstrates axis -- works with factor data
#' Specify colours using R colour names
s2 <- ggplot() + geom_point(data=scatterdata, aes(x=xnew, y=y), colour="blue") +
  ggtitle("Colours are cool")
s2
```

![plot of chunk pointssimple](figure/pointssimple2.png) 

```r

#' Specify colours manually using hex values
s3 <- ggplot() + 
  geom_point(data=scatterdata, aes(x=xnew, y=y, colour=class, fill=class)) + 
  scale_colour_manual(values=c("#FF0000", "#0000FF")) + 
  scale_fill_manual(values=c("#FF0000", "#0000FF")) +
  ggtitle("Manual colour/fill scales")
s3
```

![plot of chunk pointssimple](figure/pointssimple3.png) 

```r

#' Categorical colour scales 
s4 <- ggplot() + geom_point(data=scatterdata, aes(x=xnew, y=y, colour=xnew, fill=xnew)) +
  ggtitle("Categorical colour/fill scales")
s4
```

![plot of chunk pointssimple](figure/pointssimple4.png) 

```r

#' Color by x*y axis (no binning)
s6 <- ggplot() + geom_point(data=scatterdata, aes(x=x, y=y, color=x*y, fill=x*y)) +
  ggtitle("Continuous color scales")
s6
```

![plot of chunk pointssimple](figure/pointssimple5.png) 

```r

gg2animint(list(s1=s1, s2=s2, s3=s3, s4=s4, s6=s6), out.dir="geoms/simplepoints")
```

[Animint plot](geoms/simplepoints/index.html)

### **geom\_jitter**

```r
s5 <- ggplot() + geom_jitter(data=scatterdata, aes(x=xnew, y=y, colour=class4, fill=class4)) +
  ggtitle("geom_jitter")
s5
```

![plot of chunk jitterplots](figure/jitterplots.png) 

```r
gg2animint(list(s5=s5), out.dir="geoms/jitterpoints")
```

[Animint plot](geoms/jitterpoints/index.html)

<a name="pointinteractive"/>
### Interactive plots and scale\_size
With showSelected, it is sometimes useful to have two copies of a geom - one copy with low alpha that has no showSelected or clickSelects attributes, and another copy that is interactive. This allows the data to be visible all the time while still utilizing the interactivity of d3.

```r
library(plyr)
scatterdata2 <- data.frame(x=rnorm(1000, 0, .5), y=rnorm(1000, 0, .5))
scatterdata2$quad <- c(3, 4, 2, 1)[with(scatterdata2, (3+sign(x)+2*sign(y))/2+1)]
scatterdata2$quad <- factor(scatterdata2$quad, labels=c("Q1", "Q2", "Q3", "Q4"), ordered=TRUE)
scatterdata2 <- ddply(scatterdata2, .(quad), transform, str=sqrt(x^2+y^2)/4)
scatterdata2.summary <- ddply(scatterdata2, .(quad), summarise, xmin=min(x), xmax=max(x), ymin=min(y), ymax=max(y), xmean=mean(x), ymean=mean(y))
qplot(data=scatterdata2, x=x, y=y, geom="point", colour=quad)
```

![plot of chunk sizepoints](figure/sizepoints1.png) 

```r

#' Interactive plots...
s7 <- ggplot() + 
  geom_rect(data=scatterdata2.summary, aes(xmax=xmax, xmin=xmin, ymax=ymax, ymin=ymin, 
                                           colour=quad, fill=quad,
                                           clickSelects = quad), alpha=.3) +
  geom_point(data=scatterdata2.summary, aes(x=xmean, y=ymean, colour=quad, fill=quad, showSelected = quad), size=5) +
  geom_point(data=scatterdata2, aes(x=x, y=y), alpha=.15) + 
  scale_colour_discrete(guide="legend") + scale_fill_discrete(guide="legend") +
  scale_alpha_discrete(guide="none") +
  ggtitle("Selects & Means")
s7
```

![plot of chunk sizepoints](figure/sizepoints2.png) 

```r

#' Single alpha value
s8 <- ggplot() + 
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad),alpha=.2)+
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, 
                                    clickSelects=quad, showSelected=quad), alpha=.6) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)), 
         fill = guide_legend(override.aes = list(alpha = 1))) +
  ggtitle("Constant alpha")
s8
```

```
## Warning: Duplicated override.aes is ignored.
```

![plot of chunk sizepoints](figure/sizepoints3.png) 

```r

#' Continuous alpha
s9 <- ggplot() +
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad),alpha=.2)+
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, 
                                    alpha=str, clickSelects=quad, showSelected=quad)) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)), 
         fill = guide_legend(override.aes = list(alpha = 1))) +
  scale_alpha(range=c(.6, 1), guide="none") +
  ggtitle("Continuous alpha")
s9
```

```
## Warning: Duplicated override.aes is ignored.
```

![plot of chunk sizepoints](figure/sizepoints4.png) 

```r

#' Categorical alpha and scale_alpha_discrete()
#' Note, to get unselected points to show up, need to have two copies of geom_point: One for anything that isn't selected, one for only the selected points.
s10 <- ggplot() + 
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, alpha=quad))+
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, 
                                    alpha=quad, clickSelects=quad, showSelected=quad)) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)), 
         fill = guide_legend(override.aes = list(alpha = 1))) +
  scale_alpha_discrete(guide="none")+
  ggtitle("Discrete alpha")
s10
```

```
## Warning: Duplicated override.aes is ignored.
```

![plot of chunk sizepoints](figure/sizepoints5.png) 

```r


#' Point Size Scaling
#' Scale defaults to radius, but area is more easily interpreted by the brain (Tufte).
s11 <- ggplot() + 
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, size=str), alpha=.5) +
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, 
                                    size=str, clickSelects=quad, showSelected=quad), alpha=.3) +
  ggtitle("Scale Size")
s11
```

![plot of chunk sizepoints](figure/sizepoints6.png) 

```r


s12 <- ggplot() + 
  geom_point(data=scatterdata2, aes(x=x, y=y, colour=quad, fill=quad, size=str), alpha=.5) + 
  scale_size_area() +
  ggtitle("Scale Area")
s12
```

![plot of chunk sizepoints](figure/sizepoints7.png) 

```r

gg2animint(list(s7=s7, s8=s8, s9=s9, s10=s10, s11=s11, s12=s12), out.dir="geoms/interactivepoints")
```

```
## Warning: Duplicated override.aes is ignored. Warning: Duplicated
## override.aes is ignored. Warning: Duplicated override.aes is ignored.
```

[Animint plots](geoms/interactivepoints/index.html)

<a name="othergeoms"/>
Other geoms
---------------------------------------------------------


```r
library(ggplot2)
library(plyr)
library(animint)
```

### geom\_abline

```r
xydata <- data.frame(x=sort(runif(50, 0, 10)))
xydata$y <- 3+2*xydata$x + rnorm(50, 0, 1)
g1 <- ggplot() + geom_point(data=xydata, aes(x=x, y=y)) + 
  geom_abline(data=data.frame(intercept=c(3, 0), slope=c(2,1)), aes(intercept=intercept, slope=slope)) +
  ggtitle("geom_abline")
g1
```

![plot of chunk abline](figure/abline.png) 

```r
gg2animint(list(g1=g1), out.dir="geoms/abline")
```

[Animint plot](geoms/abline/index.html)

### geom\_ribbon

```r
ribbondata <- data.frame(x=seq(0, 1, .1), ymin=runif(11, 0, 1), ymax=runif(11, 1, 2))
ribbondata <- rbind(cbind(ribbondata, group="low"), cbind(ribbondata, group="high"))
ribbondata[12:22,2:3] <- ribbondata[12:22,2:3]+1
g2 <- ggplot() + 
  geom_ribbon(data=ribbondata, aes(x=x, ymin=ymin, ymax=ymax, group=group, fill=group), alpha=.5) + 
  ggtitle("geom_ribbon")
g2
```

![plot of chunk ribbon](figure/ribbon.png) 

```r
gg2animint(list(g2=g2), out.dir="geoms/ribbon")
```

[Animint plot](geoms/ribbon/index.html)

### geom\_tile

```r
tiledata <- data.frame(x=rnorm(1000, 0, 3))
tiledata$y <- rnorm(1000, tiledata$x, 3)
tiledata$rx <- round(tiledata$x)
tiledata$ry <- round(tiledata$y)
tiledata <- ddply(tiledata, .(rx,ry), summarise, n=length(rx))

g3 <- ggplot() + geom_tile(data=tiledata, aes(x=rx, y=ry, fill=n)) +
  scale_fill_gradient(low="#56B1F7", high="#132B43") + 
  xlab("x") + ylab("y") + ggtitle("geom_tile")
g3
```

![plot of chunk tile](figure/tile.png) 

```r
gg2animint(list(g3=g3), out.dir="geoms/tile")
```

[Animint plot](geoms/tile/index.html)

### geom\_path

```r
pathdata <- data.frame(x=rnorm(30, 0, .5), y=rnorm(30, 0, .5), z=1:30)
g4 <- ggplot() + geom_path(data=pathdata, aes(x=x, y=y), alpha=.5) +
  geom_text(data=pathdata, aes(x=x, y=y, label=z)) + 
  ggtitle("geom_path")
g4
```

![plot of chunk path](figure/path.png) 

```r
gg2animint(list(g4=g4), out.dir="geoms/path")
```

[Animint plot](geoms/path/index.html)

### geom\_polygon

```r
polydata <- rbind(
  data.frame(x=c(0, .5, 1, .5, 0), y=c(0, 0, 1, 1, 0), group="parallelogram", fill="blue", xc=.5, yc=.5),
  data.frame(x=c(.5, .75, 1, .5), y=c(.5, 0, .5, .5), group="triangle", fill="red", xc=.75, yc=.33)
  )
g5 <- ggplot() + 
  geom_polygon(data=polydata, aes(x=x, y=y, group=group, fill=fill, colour=fill), alpha=.5)+
  scale_colour_identity() + scale_fill_identity()+
  geom_text(data=polydata, aes(x=xc, y=yc, label=group)) +
  ggtitle("geom_polygon")
g5
```

![plot of chunk polygons](figure/polygons.png) 

```r
gg2animint(list(g5=g5), out.dir="geoms/polygon")
```

[Animint plot](geoms/polygon/index.html)

### geom\_linerange

```r
boxplotdata <- rbind(data.frame(x=1:50, y=sort(rnorm(50, 3, 1)), group="N(3,1)"),
                     data.frame(x=1:50, y=sort(rnorm(50, 0, 1)), group="N(0,1)"), 
                     data.frame(x=1:50, y=sort(rgamma(50, 2, 1/3)), group="Gamma(2,1/3)"))
boxplotdata <- ddply(boxplotdata, .(group), transform, ymax=max(y), ymin=min(y), med=median(y))

g6 <- ggplot() + 
  geom_linerange(data=boxplotdata, aes(x=factor(group), ymax=ymax, ymin=ymin, colour=factor(group))) +
  ggtitle("geom_linerange") + scale_colour_discrete("Distribution") + xlab("Distribution")
g6
```

![plot of chunk linerange](figure/linerange.png) 

```r
gg2animint(list(g6=g6), out.dir="geoms/linerange")
```

[Animint plot](geoms/linerange/index.html)

### geom\_histogram

```r
g7 <- ggplot() + 
  geom_histogram(data=subset(boxplotdata, group=="Gamma(2,1/3)"), aes(x=y, fill=..count..), binwidth=1) + 
  ggtitle("geom_histogram")
g7
```

![plot of chunk histogram](figure/histogram.png) 

```r
gg2animint(list(g7=g7), out.dir="geoms/histogram")
```

[Animint plot](geoms/histogram/index.html)

### geom\_violin

```r
g8 <- ggplot() + 
  geom_violin(data=boxplotdata, aes(x=group, y=y, fill=group, group=group)) +
  ggtitle("geom_violin")+ scale_fill_discrete("Distribution") + xlab("Distribution")
g8
```

![plot of chunk violin](figure/violin.png) 

```r
gg2animint(list(g8=g8), out.dir="geoms/violin")
```

[Animint plot](geoms/violin/index.html)


### geom\_step

```r
g9 <- ggplot() + geom_step(data=boxplotdata, aes(x=x, y=y, colour=factor(group), group=group)) +
  scale_colour_discrete("Distribution") +
  ggtitle("geom_step")
g9
```

![plot of chunk step](figure/step.png) 

```r
gg2animint(list(g9=g9), out.dir="geoms/step")
```

[Animint plot](geoms/step/index.html)


### geom\_contour

```r
library(reshape2) # for melt
contourdata <- melt(volcano)
names(contourdata) <- c("x", "y", "z")
g11 <- ggplot() + geom_contour(data=contourdata, aes(x=x, y=y, z=z), binwidth=4, size=0.5) + 
  geom_contour(data=contourdata, aes(x=x, y=y, z=z), binwidth=10, size=1) +
  ggtitle("geom_contour")
g11
```

![plot of chunk contour](figure/contour.png) 

```r

gg2animint(list(g11=g11), out.dir="geoms/contour")
```

[Animint plot](geoms/contour/index.html)


```r
contourdata2 <- floor(contourdata/3)*3 # to make fewer tiles

g12 <- ggplot() + 
  geom_tile(data=contourdata2, aes(x=x, y=y, fill=z, colour=z)) + 
  geom_contour(data=contourdata, aes(x=x, y=y, z=z), colour="black", size=.5) +
  scale_fill_continuous("height", low="#56B1F7", high="#132B43", guide="legend") +
  scale_colour_continuous("height", low="#56B1F7", high="#132B43", guide="legend") +
  ggtitle("geom_tile + geom_contour") 
g12
```

![plot of chunk contourtile](figure/contourtile.png) 

```r

gg2animint(list(g12=g12), out.dir="geoms/contour2")
```

[Animint plot](geoms/contour2/index.html). You may have to wait a moment to see the tiles - as each tile is a separate d3 object, it can take a few seconds to load all of the tiles. 

### scale\_y\_log10 and geom\_contour with stat\_density2d
While stat\_density2d does not always work reliably, we can still use the statistic within another geom, such as geom\_contour. 

```r
library("MASS")
data(geyser,package="MASS")
g13 <- ggplot() +  
  geom_point(data=geyser, aes(x = duration, y = waiting)) + 
  geom_contour(data=geyser, aes(x = duration, y = waiting), colour="blue", size=.5, stat="density2d") + 
  xlim(0.5, 6) + scale_y_log10(limits=c(40,110)) +
  ggtitle("geom_contour 2d density")
g13
```

![plot of chunk scaleycontour](figure/scaleycontour.png) 

```r

gg2animint(list(g13=g13), out.dir="geoms/contour3")
```

[Animint plot](geoms/contour3/index.html)

### geom\_polygon with stat=density2d contours

```r
g14 <- ggplot() +  
  geom_polygon(data=geyser,aes(x=duration, y=waiting, fill=..level.., 
                               group=..piece..), 
               stat="density2d", alpha=.5) +
  geom_point(data=geyser, aes(x = duration, y = waiting)) + 
  scale_fill_continuous("Density Level", low="#56B1F7", high="#132B43") + 
  guides(colour = guide_legend(override.aes = list(alpha = 1)), 
         fill = guide_legend(override.aes = list(alpha = 1))) + 
  scale_y_continuous(limits=c(40,110), trans="log10") +
  scale_x_continuous(limits=c(.5, 6)) +
  ggtitle("geom_density2d polygon")
g14
```

![plot of chunk densitypolygon](figure/densitypolygon.png) 

```r

gg2animint(list(g14=g14), out.dir="geoms/contour4")
```

[Animint plot](geoms/contour4/index.html)

### Tile plot filled by density 

```r
data(diamonds)
dsmall <- diamonds[sample(nrow(diamonds), 1000), ] # reduce dataset size
g15 <- ggplot() + 
  geom_tile(data=dsmall, aes(x=carat, y=price, fill=..density.., colour=..density..), stat="density2d", contour=FALSE, n=30) +
  scale_fill_gradient(limits=c(1e-5,8e-4), na.value="white") + 
  scale_colour_gradient(limits=c(1e-5,8e-4), na.value="white") +
  ggtitle("geom_density2d tile") + ylim(c(0, 19000))
g15
```

![plot of chunk tiledensity](figure/tiledensity.png) 

```r
gg2animint(list(g15=g15), out.dir="geoms/tiledensity")
```

[Animint plot](geoms/tiledensity/index.html)

### Density mapped to point size

```r
g16 <- ggplot() + 
  geom_point(data=dsmall, aes(x=carat, y=price, alpha=..density..), 
             stat="density2d", contour=FALSE, n=10, size=I(1)) +
  scale_alpha_continuous("Density") +
  ggtitle("geom_density2d points")
g16
```

![plot of chunk pointdensity](figure/pointdensity.png) 

```r
gg2animint(list(g16=g16), out.dir="geoms/pointdensity")
```

[Animint plot](geoms/pointdensity/index.html)

### Creating maps with animint
While geom\_map is not implemented in animint, it is possible to plot a map using geom\_polygon and merge. As map data frames can be rather large, it may be useful to use a point thinning algorithm, such as the **dp()** function in the **shapefiles** package [[link](http://cran.r-project.org/web/packages/shapefiles/shapefiles.pdf)] to reduce the number of points in each polygon. 


```r
library(reshape2) # for melt
library(maps)

# obtain data for US Arrests
crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
crimesm <- melt(crimes, id = 1)
# data frame should contain only counts of number of assaults
crimes.sub <- subset(crimesm, variable=="Assault") 

# load map for mainland US
states_map <- map_data("state")

# merge assault data with map data, so that each state 
# ("region" in the map dataframe) has a corresponding 
# entry for number of assaults.
assault.map <- merge(states_map, subset(crimesm, variable=="Assault"), by.x="region", by.y="state")
assault.map <- assault.map[order(assault.map$group, assault.map$order),]

g17 <- ggplot() + 
  geom_polygon(data=assault.map, aes(x=long, y=lat, group=group, fill=value, colour=value)) +
  expand_limits(x = states_map$long, y = states_map$lat) + 
  ggtitle("geom_polygon map") + ylim(c(12, 63)) + 
  geom_text(data=data.frame(x=-95.84, y=55, label="Arrests for Assault"), hjust=.5, aes(x=x, y=y, label=label))
g17  
```

![plot of chunk maptutorial](figure/maptutorial.png) 

```r
gg2animint(list(g17=g17), out.dir="geoms/assaultmap")
```

[Animint plot](geoms/assaultmap/index.html)



### Stacked bar chart
While **geom\_bar** does not work well with clickSelects, it does work when creating a static plot. If you need to use clickSelects to select a specific bar, you should use **make\_bar**, **stat\_summary**, or calculate the relevant dataframe yourself using **ddply**. This ensures that clickSelects does not conflict with the specification of individual plot elements in **ggplot2**. See the [tornadoes tutorial](tornadoes.html#makebar) for more information and examples of clickSelects with **geom\_bar**. 

```r
data(mtcars)
g18 <- ggplot() + geom_bar(data=mtcars, aes(x=factor(cyl), fill=factor(vs))) + ggtitle("geom_bar stacked")
g18
```

![plot of chunk stackedbar](figure/stackedbar.png) 

```r

gg2animint(list(g18=g18), out.dir="geoms/stackedbar")
```

[Animint plot](geoms/stackedbar/index.html)



### **geom\_area** with **stat\_density**

```r
data(diamonds)
g19 <- ggplot() + 
  geom_area(data=diamonds, aes(x=clarity, y=..count.., group=cut, colour=cut, fill=cut), stat="density") +
  ggtitle("geom_area")
g19
```

![plot of chunk areadensity](figure/areadensity.png) 

```r

gg2animint(list(g19=g19), out.dir="geoms/areaplot")
```

[Animint plot](geoms/areaplot/index.html)



### **geom\_freqpoly**

```r
g20 <- ggplot() + 
  geom_freqpoly(data=diamonds, aes(x=clarity, group=cut, colour=cut)) +
  ggtitle("geom_freqpoly")
g20
```

![plot of chunk freqpoly](figure/freqpoly.png) 

```r
gg2animint(list(g20=g20), out.dir="geoms/freqpoly")
```

[Animint plot](geoms/freqpoly/index.html)


### **geom\_hex**

```r
g21 <- ggplot() + 
  geom_hex(data=dsmall, aes(x=carat, y=price)) +
  scale_fill_gradient(low="#56B1F7", high="#132B43") + 
  xlab("x") + ylab("y") + ggtitle("geom_hex")
g21
```

![plot of chunk hex](figure/hex.png) 

```r
gg2animint(list(g21=g21), out.dir="geoms/hex")
```

[Animint plot](geoms/hex/index.html)

<sub>Tutorial created by Susan VanderPlas on 8/29/2013 using animint version 0.1.0 and ggplot2 0.9.3.1</sub>