#NOTE: using -C for container context
#NOTE: using -v verbose
#NOTE: using -b bind to local folder
#NOTE: using -r reuse container
alpine:docker-start## 		run act in .github
	@export $(cat ~/GH_TOKEN.txt) && act -C $(PWD) -vb -W $(PWD)/.github/workflows/$@.yml
