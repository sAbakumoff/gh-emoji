library("dplyr")
emoji<-read.csv(file="emoji.csv", h=TRUE)
top_lang<-emoji %>% 
  group_by(language) %>% summarize(count=n()) %>% top_n(n=20, wt=count) %>% 
  ungroup() %>% select(language)
stat<- emoji %>% merge(top_lang) %>%
  group_by(language, emoji) %>% summarize(count=n()) %>% ungroup() %>%
  arrange(desc(count)) %>% group_by(language) %>% slice(1:10) %>% ungroup() %>%
  group_by(language) %>% summarize(top_emojis=paste(emoji, collapse=" "))
write.csv(stat, row.names=FALSE, file="stat.csv")