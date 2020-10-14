suppressMessages(library(optparse))
suppressMessages(library(data.table))
suppressMessages(library(dplyr))
suppressMessages(library(tidyverse))
suppressMessages(library(ggplot2))
options(stringsAsFactors=F)

### 0. Set up the argument list
option_list = list(
  make_option("--gwas.top", action = "store", default = NA, type = "character",
              help="The GWAS input displayed at the top of the mirrored plot"),
  make_option("--gwas.bottom", action = "store", default = NA, type = "character",
              help="The GWAS input displayed at the bottom of the mirrored plot"),
  make_option("--chr.name", action = "store", default = "CHR", type = "character",
              help="The column name for chromosome"), 
  make_option("--pos.name", action = "store", default = "BP", type = "character",
              help="The column name for physical location"),
  make_option("--SNP.name", action = "store", default = "SNP", type = "character",
              help="The column name for SNP rsID"),
  make_option("--P.name", action = "store", default = "P", type = "character",
              help="The column name for p-value"),
  make_option("--main", action = "store", default = NA, type = "character",
              help="The caption for the mirrored plot"),
  make_option("--sig.threshold", action = "store", default = 5e-8,
              help="The significance threshold labelling in the plot"),
  make_option("--plot.out", action = "store", default = NA, type = "character",
              help="The output path of the mirrored GWAS plot")
  
)

opt = parse_args(OptionParser(option_list=option_list))
#FIXME
# opt$gwas.top = "./tables/GWAS.top.txt"
# opt$gwas.bottom = "./tables/GWAS.bottom.txt"
# opt$chr.name = "CHR"
# opt$pos.name = "BP"
# opt$SNP.name = "SNP"
# opt$P.name = "P"
# opt$sig.threshold = 5e-8
# opt$main = "testing"
# opt$plot.out = "../plots_testing_for_mirrored_GWAS/Mirrored_testing.GWAS.png"

### 1. Read in GWAS inputs
gwas.top = as.data.frame(fread(opt$gwas.top)) %>% 
  select(opt$chr.name, opt$pos.name, opt$SNP.name, opt$P.name) %>% # select CHR, POS, and P columns
  `colnames<-`(c("CHR", "BP", "SNP", "P")) %>% # change the column name for future processing
  mutate(P_transformed = -log10(P), label = SNP) %>% # transform the P-values to log scale
  mutate(col_group = ifelse(CHR %% 2 == 1, 1, 2)) %>% # assign the color group
  mutate(category = "top")
gwas.bottom = as.data.frame(fread(opt$gwas.bottom)) %>% 
  select(opt$chr.name, opt$pos.name, opt$SNP.name, opt$P.name) %>% 
  `colnames<-`(c("CHR", "BP", "SNP", "P")) %>% 
  mutate(P_transformed = log10(P), label = SNP) %>% 
  mutate(col_group = ifelse(CHR %% 2 == 1, 3, 4)) %>%
  mutate(category = "bottom")


### 2. Combine the top and bottom GWAS and plot out the mirrored GWAS plot
Data.combined = rbind(gwas.top, gwas.bottom) %>% 
  group_by(CHR) %>% 
  summarise(chr_len = max(BP)) %>% # Compute chromosome size
  mutate(tot = cumsum(chr_len) - chr_len) %>% # Calculate cumulative position of each chromosome
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(rbind(gwas.top, gwas.bottom), ., by = "CHR") %>%
  arrange(CHR, BP) %>% # Add a cumulative position of each SNP
  mutate(BPcum = BP + tot) %>% 
  mutate(is_annotate_top = ifelse((P < opt$sig.threshold) & (category == "top"), "yes", "no")) %>%
  mutate(is_annotate_bottom = ifelse((P < opt$sig.threshold) & (category == "bottom"), "yes", "no")) # Add highlight and annotation information

# Get chromosome center positions for x-axis
axisdf = Data.combined %>% 
  group_by(CHR) %>% 
  summarize(center = (max(BPcum) + min(BPcum))/2)


# Generate the mirrored GWAS plot
highlight = Data.combined %>% 
  filter(`is_annotate_top` == "yes" | `is_annotate_bottom` == "yes")
gg.combined = Data.combined %>% 
  filter(`P_transformed` > 0.02 | `P_transformed` < -0.02) %>% 
  ggplot(aes(x = BPcum, y = P_transformed)) +
  geom_point(aes(color=as.factor(col_group)), alpha = 0.8, size = 2.5) + # Show all points
  scale_color_manual(values = c("#3d4786", "#95cbf1", "#be214d", "#ffa59e")) +
  # Customize axes:
  scale_x_continuous(label = axisdf$CHR, breaks= axisdf$center) +
  scale_y_continuous(expand = c(0, 0), limits = c(-10.5,10.5)) + # expand=c(0,0)removes space between plot area and x axis 
  # add plot and axis titles
  ggtitle(opt$main) +
  labs(x = "Chromosome", y = expression(-log["10"](P))) +
  
  # Add genome-wide suggestive lines
  
  geom_hline(yintercept = -log10(opt$sig.threshold), linetype = 5, alpha = 0.7) +
  geom_hline(yintercept = log10(opt$sig.threshold), linetype = 5, alpha = 0.7) +
  geom_hline(yintercept = 0, size = 1.5, alpha = 0.7) +
  
  # Add highlighted points
  
  geom_point(data = highlight, 
             color = "#BD215B", size = 7, shape = 18) +
  
  # Optional: add label using ggrepel to avoid overlapping
  # geom_label_repel(data = highlight, aes(label = SNP), 
  #                  parse = TRUE, size = 10, segment.color = "darkblue",
  #                  force = 10, segment.colour = "black", box.padding = unit(0.35, "lines"),
  #                  point.padding = unit(0.5, "lines"),, segment.size = 0) +
  # Customize the theme:
  theme_bw(base_size = 30) +
  theme( #plot.title = element_text(hjust = 0.5),
         legend.position = "none",
         panel.border = element_blank(),
         panel.grid.major.x = element_blank(),
         panel.grid.minor.x = element_blank()
  )
ggsave(gg.combined, file = opt$plot.out, width=20, height=15)









