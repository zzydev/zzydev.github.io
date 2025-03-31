hugo --destination ./docs --buildDrafts --cleanDestinationDir
touch ./docs/CNAME && echo "zzydev.github.io" > ./docs/CNAME
git pull origin master
