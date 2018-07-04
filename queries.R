library(tidyverse)
library(data.world)

dwapi::configure(auth_token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50OnNvZnRjaXRlLXVzZXIiLCJpc3MiOiJhZ2VudDpzb2Z0Y2l0ZS11c2VyOjphNGExYmI1NS1lMGUwLTQ4YjQtYTE4YS1mOTU4OTcyNGI4YWIiLCJpYXQiOjE1MjgxNDkxNDgsInJvbGUiOlsidXNlcl9hcGlfcmVhZCIsInVzZXJfYXBpX3dyaXRlIl0sImdlbmVyYWwtcHVycG9zZSI6dHJ1ZX0.Dh4pCsfUaa9s_9sAtIIF-uPzue1BWkkH7Cuc5U7EjSvNcTtcO1lp-qKwdD6cSGOLnefXEc1tVz3idzvQAHpaZg')

# ------ Database address
softcite_ds = "https://data.world/jameshowison/software-citations/"

# ------ Queries
# ------ TO-DO - some of these queries could likely be combined
prefixes <- "
PREFIX bioj: <http://james.howison.name/ontologies/bio-journal-sample#>
PREFIX bioj-cited: <http://james.howison.name/ontologies/bio-journal-sample-citation#>
PREFIX ca: <http://floss.syr.edu/ontologies/2008/4/contentAnalysis.owl#>
PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>
PREFIX dc: <http://dublincore.org/documents/2012/06/14/dcmi-terms/>
PREFIX doap: <http://usefulinc.com/ns/doap#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX vivo: <http://vivoweb.org/ontology/core#>
PREFIX xml: <http://www.w3.org/XML/1998/namespace>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
"

softcite_ds = "https://data.world/jameshowison/software-citations/"
mention_query <- data.world::qry_sparql(paste(prefixes,
                                              "SELECT ?article ?coder ?selection ?full_quote ?on_pdf_page ?spans_pages
                                              WHERE { ?article citec:has_in_text_mention ?selection .
                                              ?selection ca:isTargetOf
                                              [ rdf:type ca:CodeApplication ;
                                              ca:hasCoder ?coder ;
                                              ca:appliesCode [ rdf:type citec:mention_type ]
                                              ] .
                                              ?selection citec:full_quote ?full_quote ;
                                              citec:on_pdf_page ?on_pdf_page ;
                                              citec:spans_pages ?spans_pages
                                              }"
))
no_selection_query <- data.world::qry_sparql(paste(prefixes,
                                                   "SELECT ?article ?coder
                                                   WHERE { ?article ca:isTargetOf
                                                   [ rdf:type ca:CodeApplication ;
                                                   ca:hasCoder ?coder ;
                                                   ca:appliesCode [ rdf:type citec:coded_no_in_text_mentions ;
                                                   citec:isPresent true ]
                                                   ]
                                                   }"
))
software_name_query <- data.world::qry_sparql(paste(prefixes,
                                                    "SELECT ?software_name
                                                    WHERE {
                                                    ?article citec:has_in_text_mention ?selection .
                                                    ?selection ca:isTargetOf
                                                    [ rdf:type ca:CodeApplication ;
                                                    ca:appliesCode [ rdf:type citec:software_name ;
                                                    rdfs:label ?software_name ;
                                                    citec:isPresent true ] ;
                                                    ca:hasCoder ?coder ]
                                                    }"
))
has_name_query <- data.world::qry_sparql(paste(prefixes,
                                               "SELECT ?has_software_name
                                               WHERE {
                                               ?article citec:has_in_text_mention ?selection .
                                               ?selection ca:isTargetOf
                                               [ rdf:type ca:CodeApplication ;
                                               ca:appliesCode [ rdf:type citec:software_name ;
                                               citec:isPresent ?has_software_name ] ;
                                               ca:hasCoder ?coder ]
                                               }"
))
has_version_query <- data.world::qry_sparql(paste(prefixes,
                                                  "SELECT ?has_version_num
                                                  WHERE {
                                                  ?article citec:has_in_text_mention ?selection .
                                                  ?selection ca:isTargetOf
                                                  [ rdf:type ca:CodeApplication ;
                                                  ca:appliesCode [ rdf:type citec:version_number ;
                                                  citec:isPresent ?has_version_num ] ;
                                                  ca:hasCoder ?coder ]
                                                  }"
))
has_url_query <- data.world::qry_sparql(paste(prefixes,
                                              "SELECT ?has_url
                                              WHERE {
                                              ?article citec:has_in_text_mention ?selection .
                                              ?selection ca:isTargetOf
                                              [ rdf:type ca:CodeApplication ;
                                              ca:appliesCode [ rdf:type citec:url ;
                                              citec:isPresent ?has_url ] ;
                                              ca:hasCoder ?coder ]
                                              }"
))
assign_qry <- data.world::qry_sql("SELECT * FROM softcite_assignments")


# ------ data.world queries
assignments <- data.world::query(assign_qry, dataset = softcite_ds)

mentions <- data.world::query(mention_query, softcite_ds) %>%
  as.tibble(mentions) %>%
  filter(str_detect(article, "PMC")) %>%
  mutate_at(vars(article, selection),
            funs(str_extract(.,"[#/]([^#/]+)$"))) %>%
  mutate_at(vars(article,selection), funs(str_sub(.,2)))

found_selections <- mentions %>%
  select(article, coder) %>%
  distinct()

no_selection_articles <- data.world::query(no_selection_query, softcite_ds) %>%
  mutate(article = str_extract(article, "[#/]([^#/]+)$"),
         article = str_sub(article,2),
         matched = 0,
         unmatched = 0) %>%
  select(article, coder) %>%
  collect()

all_coded_articles <- bind_rows(found_selections, no_selection_articles)

software_names <- data.world::query(software_name_query, softcite_ds) %>%
  as.tibble()

has_name <- data.world::query(has_name_query, softcite_ds) %>%
  table()

has_version <- data.world::query(has_version_query, softcite_ds) %>%
  table()

has_url <- data.world::query(has_url_query, softcite_ds) %>%
  table()

# ------ look at user stats
pmc_assignments <- assignments %>% 
  filter(str_detect(pub_id, "PMC*")) %>% 
  mutate(assigned_to = str_to_lower(assigned_to))


pmc_assignees <- pmc_assignments %>% 
  pull(assigned_to) %>% unique()

pmc_assignments %>% 
  group_by(assigned_to) %>% 
  tally() %>% 
  arrange(n)

# work assigned.
assigned <- pmc_assignments %>% 
  select(article = pub_id, coder = assigned_to) %>%
  distinct()

# work actually done and gathered.
completed <- all_coded_articles %>% 
  select(article, coder) %>%
  distinct()

# ------ Helper functions
#used to format percentages
asPercent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

# ------ Methods to access stats
#fraction of received mentions with software names
getFracNames <- function(){
  with_name <- has_name["true"]
  withjout_name <- has_name["false"]
  return(with_name/(with_name+withoutName))
}
#fraction of received mentions with version numbers
getFracVersions <- function(){
  with_version <- has_version["true"]
  without_version <- has_version["false"]
  return(with_version/(with_version+without_version))
}
#fraction of received mentions with URLs
getFracUrls <- function(){
  with_url <- has_url["true"]
  without_urld <- has_url["false"]
  return(with_url/(with_url+without_url))
}
getNumMentions <- function(){
  return(length(mentions$article))
}
#unique articles, does not count articles coded for a second time by a seperate coder
getNumArticles <- function(){
  return(length(unique(all_coded_articles$article)))
}
#total articles received from coder specified by param 'coderSelection', a github username passed as a string
getNumArticlesByCoder <- function(coderSelection){
  return(nrow(all_coded_articles[all_coded_articles$coder == coderSelection,]))
}
#all coders that have coded at least one received articles
getCoders <- function(){
  return(unique(all_coded_articles$coder))
}
#number of coders that have coded at least one received articles
getNumCoders <- function(){
  return(length(unique(all_coded_articles$coder)))
}
getSoftwareNames <- function(){
  return(software_names)
}
getMostCommonSoftware <- function(){
  return(sort(table(software_names),decreasing=TRUE)[1:10])
}

#verify this function, not sure if calculation is correct
getPctAssignedCoded <- function(){
  numAssigned <- pmc_assignments %>% 
    group_by(assigned)
  numAssigned = nrow(numAssigned)
  
  numReceived <- nrow(completed)
  
  return(asPercent(numReceived/(numAssigned)))
}
getAssignmentsByCoder <- function(){
  missingChart <- assigned %>% 
    group_by(coder) %>% 
    summarize(num_missing = n(),
              missing = str_c(article, collapse = "; ")) %>% 
    arrange(desc(num_missing))
  missingChart[3] <- NULL
  return(missingChart)
}
getArticlesMissingByCoder <- function(){
  # what was assigned but not completed? What is in pmc_assignments but not in match_counts.
  missing <- anti_join(assigned, completed)
  
  missingChart <- missing %>% 
    group_by(coder) %>% 
    summarize(num_missing = n(),
              missing = str_c(article, collapse = "; ")) %>% 
    arrange(desc(num_missing))
  missingChart[3] <- NULL
  return(missingChart)
}
