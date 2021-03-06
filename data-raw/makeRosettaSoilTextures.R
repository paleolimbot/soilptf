
avs <- read.delim('data-raw/rosettaav.txt', colClasses="character", header=F)[[1]]
avs <- matrix(avs, byrow = TRUE, ncol = 16)
avs <- as.data.frame(avs)
vals <- avs[c(1, 2, 3, 5, 7, 9, 11, 13, 15)]
errs <- avs[c(1, 2, 4, 6, 8, 10, 12, 16, 16)]
labels <- c("TextureClass", "N", "theta_r", "theta_s", "log_alpha", "log_n", "ln_Ks", "ln_K0", "L")
names(vals) <- labels
names(errs) <- labels

vals$N <- as.integer(as.character(vals$N))
errs$N <- as.integer(as.character(errs$N))
for(name in labels[3:length(labels)]) {
  vals[[name]] <- as.numeric(as.character(vals[[name]]))
  errs[[name]] <- as.numeric(gsub(x=as.character(errs[[name]]), pattern="[()]", replacement = ""))
}

rosettaSoilClass <- cbind(reshape2::melt(vals, id.vars=c("TextureClass", "N")),
                          reshape2::melt(errs, id.vars=c("TextureClass", "N"),
                                         value.name="stdev")[-1:-3])

rownames(rosettaSoilClass) <- NULL

# transform soil classes into more suitable abbreviations (uses texture.class from package)
rosettaSoilClass$TextureClass <- soilptf:::texture.class.factor(rosettaSoilClass$TextureClass)
rosettaSoilClass <- rosettaSoilClass[order(rosettaSoilClass$TextureClass, rosettaSoilClass$variable),]
devtools::use_data(rosettaSoilClass, overwrite = TRUE)

# generate wide version with ranges for internal use
rosettaSoilClass$min <- rosettaSoilClass$value - rosettaSoilClass$stdev
rosettaSoilClass$max <- rosettaSoilClass$value + rosettaSoilClass$stdev
rosettaSoilClass <- reshape2::melt(rosettaSoilClass, id.vars=c("TextureClass", "N", "variable"),
                                   variable.name="type", value.name="value")

rosettaSoilClassWide <- reshape2::dcast(rosettaSoilClass, TextureClass + N ~ variable + type)
devtools::use_data(rosettaSoilClassWide, internal = TRUE, overwrite=TRUE)
