Quorum Examples
This repository contains scripts for advanced deployment and connection to the Keyword Extraction.

Usage notice
This project is meant for advanced keyword extraction users (mainly NLP contributors) who are already familiar with Keywork extraction deployments and who are looking for some advanced configurations for their network.

If you have a limited experience with Quorum, or if you are looking to start a Keywork Extraction for some testing purposes then you should instead use our extraction-dev-quickstart.

We do not guarantee that all scripts in this project work out of the box, in particular some scripts may be out of date and will require some adjustments from users to properly work on latest Extraction versions.

**Options Parameters**
The second argument of the extract method is an Object of configuration/processing settings for the extraction.

**Parameter Name	Description	Permitted Values**
language	The stopwords list to use.	english, spanish, polish, german, french, italian, dutch, romanian, russian, portuguese, swedish,
remove_digits	Removes all digits from the results if set to true	true or false

return_changed_case	The case of the extracted keywords. 

Setting the value to true will return the results all lower-cased, if false the results will be in the original case.	true or false
return_chained_words	Instead of returning each word separately, join the words that were originally together. 

Setting the value to true will join the words, if false the results will be splitted on each array element.	true or false

remove_duplicates	Removes the duplicate keywords	true , false (defaults to false )

return_max_ngrams	Returns keywords that are ngrams with size 0-integer	integer , false (defaults to false )
