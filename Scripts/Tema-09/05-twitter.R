#Analisis de redes con Twitter

library(twitteR)
library(igraph)
library(dplyr)

api_key <- Sys.getenv("TWITTER_API_KEY")
api_secret <- Sys.getenv("TWITTER_API_SECRET")
access_token <- Sys.getenv("TWITTER_ACCESS_TOKEN")
access_token_secret <- Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")


setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

all_tweets <- searchTwitter("monetization", n = 2000)

all_tweets <- twListToDF(all_tweets)

#sample_tweets <- all_tweets[1:200,]

sample_tweets <- all_tweets

split_tweets <- split(sample_tweets, sample_tweets$isRetweet)

retweets <- mutate(split_tweets[['TRUE']],
                   sender = substr(text, 5, regexpr(":",text)-1))

edge_list <- as.data.frame(cbind(sender = tolower(retweets$sender),
                                 receiver = tolower(retweets$screenName)))

edge_list <- count(edge_list, sender, receiver)


tweets_graph <- graph_from_data_frame(d=edge_list, directed = T)
save(tweets_graph, file="../data/tema9/tweets-from-monetization.Rdata")


plot(tweets_graph, 
     layout=layout.fruchterman.reingold,
     vertex.color = "blue",
     vertex.size = degree(tweets_graph, mode = "in"),
     vertex.label = NA,
     edge.arrow.size = 0.5,
     edge.arrow.width = 0.5,
     edge.width = edge_attr(tweets_graph)$n,
     edge.color=hsv(h=.9, s=1, v=.7, alpha = 0.5),
     main="Tweets sobre Monetización")


library(devtools)
devtools::install_github("analyxcompany/ForceAtlas2")
library(ForceAtlas2)

force_layout <- layout.forceatlas2(tweets_graph,
                                   iterations = 200,
                                   plotstep = 20) 

plot(tweets_graph, 
     layout = force_layout,
     vertex.color = "blue",
     vertex.size = degree(tweets_graph, mode = "in"),
     vertex.label = NA,
     edge.arrow.size = 0.5,
     edge.arrow.width = 0.5,
     edge.width = edge_attr(tweets_graph)$n,
     edge.color=hsv(h=.9, s=1, v=.7, alpha = 0.5),
     main="Tweets sobre Monetización")



write.graph(tweets_graph,
            file="../data/tema9/tweets-from-monetization.graphml",
            format= "graphml")
