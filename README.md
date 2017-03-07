# Emoji Analysis of Github Commit Messages

language     | Most common emojis                                                                                                      | 
|----------------|--------------------------------------------------------------------------------------------------------------------| 
| c            | :octocat: :tada: :circus_tent: :memo: :confetti_ball: :space_invader: :lipstick: :lollipop: :neckbeard: :bug:    | 
| c#           | :octocat: :neckbeard: :lollipop: :confetti_ball: :space_invader: :tada: :circus_tent: :art: :construction: :bug: | 
| c++          | :memo: :tada: :bug: :space_invader: :octocat: :neckbeard: :lipstick: :lollipop: :circus_tent: :confetti_ball:    | 
| clojure      | :yum: :wrench: :unamused: :scream_cat: :bug: :arrow_up: :honey_pot: :memo: :shower: :art:                        | 
| coffeescript | :arrow_up: :memo: :art: :bug: :lipstick: :fire: :new: :white_check_mark: :gift: :green_heart:                    | 
| css          | :memo: :tada: :dancer: :bug: :basketball: :art: :sparkles: :octocat: :circus_tent: :space_invader:               | 
| go           | :arrow_up: :bug: :art: :memo: :lipstick: :tada: :fire: :rocket: :sparkles: :construction:                        | 
| html         | :art: :octocat: :space_invader: :tada: :boom: :neckbeard: :see_no_evil: :rocket: :circus_tent: :lollipop:        | 
| java         | :bug: :octocat: :tada: :space_invader: :confetti_ball: :circus_tent: :zap: :lipstick: :neckbeard: :lollipop:     | 
| javascript   | :arrow_up: :bug: :art: :memo: :tada: :new: :wrench: :sparkles: :lipstick: :fire:                                 | 
| makefile     | :gun: :pencil: :lipstick: :neckbeard: :tada: :book: :bug: :circus_tent: :put_litter_in_its_place: :balloon:      | 
| objective-c  | :art: :fire: :fish: :memo: :o: :shipit: :tada: :tropical_fish: :bug: :trollface:                                 | 
| perl         | :art: :smile: :wrench: :frog: :cake: :rainbow: :ant: :bug: :poop: :seedling:                                     | 
| php          | :bug: :tada: :memo: :octocat: :space_invader: :neckbeard: :up: :confetti_ball: :circus_tent: :lollipop:          | 
| python       | :arrow_up: :tada: :lipstick: :bug: :space_invader: :construction: :octocat: :confetti_ball: :new: :muscle:       | 
| ruby         | :gem: :fire: :bug: :lipstick: :memo: :tada: :heart: :nodoc: :sparkles: :scissors:                                | 
| shell        | :arrow_up: :memo: :wrench: :sparkles: :tada: :bug: :art: :lipstick: :fire: :package:                             | 
| swift        | :art: :heavy_plus_sign: :fire: :memo: :bug: :blush: :tada: :arrow_up: :pencil: :lipstick:                        | 
| typescript   | :rose: :memo: :sparkles: :lipstick: :bug: :arrow_up: :wrench: :fire: :heart: :green_heart:                       | 
| viml         | :memo: :sparkles: :art: :bug: :fire: :beer: :zap: :wink: :boom: :racehorse:                                      | 

# Steps to reproduce
## Find commit messages that include emojis
Run the following [query](https://bigquery.cloud.google.com:443/savedquery/940809849830:e32668930ccf4b15b940394cab644da5) by using BigQuery
```sql
SELECT
  LANGUAGE,
  repo,
  commit,
  message,
  REGEXP_EXTRACT_ALL(REPLACE(message, ' ', '  '), r'(?:\s|^)(\:[A-Za-z_]+\:)(?:\s|$)') emoji
FROM
  `bigquery-public-data.github_repos.commits` a
JOIN
  `fh-bigquery.github_extracts.ght_project_languages` b
ON
  a.repo_name[OFFSET(0)] = b.repo
WHERE
  REGEXP_CONTAINS(message, r'(?:\s|^)(\:[A-Za-z_]+\:)(?:\s|$)')
  AND b.percent > 0.5
```
the resulting data table is available [here](https://bigquery.cloud.google.com/table/in-full-gear:Dataset1.commits_with_emojis)

## Select language and emoji columns for further analysis
```sql
SELECT
  LANGUAGE,
  emoji
FROM
  `in-full-gear.Dataset1.commits_with_emojis`,
  UNNEST(emoji) AS emoji
```
The result is available in (emoji.csv)

## Run R script to obtain the summary information
```R
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
```
