hugo --destination ./docs --buildDrafts --cleanDestinationDir
touch ./docs/CNAME && echo "zzydev.top" > ./docs/CNAME
git pull origin master
