#!/usr/bin/env bash
# USAGE: ./crawl.sh URI depth (e.g. https://www.wikidata.org/wiki/Q12737077 1)

# Use -us if you are from the US of A. Just kiddin' :)
# see http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -eu
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "$SCRIPT_DIR"
if [ ! -f "$SCRIPT_DIR/../ldspider/target/ldspider-1.3-with-dependencies.jar" ]; then
  sh "$SCRIPT_DIR/build.sh"
fi
echo "$1" > seed.txt
domain=$(python -c "from six.moves.urllib.parse import urlparse
url = urlparse('$1')
print(url.netloc)")
echo "Limiting the crawl to the domain $domain"
java -jar "$SCRIPT_DIR/../ldspider/target/ldspider-1.3-with-dependencies.jar" \
  -a crawl.log                `# log each crawl request to crawl.log` \
  -any23                      `# use all the extractors any23 has` \
  -b ${2:-1000}               `# strict breadth-first with n levels of depth (1000 if not specified)` \
  -o "crawl-$(date +%s).nq"   `# output filename` \
  -df "frontier"              `# dump frontier after each round to frontier-xxx` \
  -t 64                       `# use 64 threads` \
  -s seed.txt                 `# use the first argument as a seed list - must serve valid RDF` \
  -e                          `# omit header triple in data` \
  -y "$domain"                `# crawl only the resources under the URL's domain'` \
  2>&1                        `# force error output into standard output` \
  | tee output.log            `# print the program log output on the screen and into the file` \
  | grep -i err -B 1          `# print only the lines containing the text 'err' and one line before on the screen`
  # -ctIgnore       `# ignore bad content-type headers and parse all data` \

