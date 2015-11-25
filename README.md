# hibbingwall
Simple learning firewall.

## Example:
```
sudo sh hibbingwall.sh start
firefox that-site-you-want-your-kid-to-access
sudo sh hibbingwall.sh learn
# use the site for a while
^C
# now your kid can use that site
```

## Fancy stuff:
```
# Add a particular site or two
sudo sh hibbingwall.sh add www.wikipedia.org www.wikia.com
# Special case: adding google.com adds all its netblocks
sudo sh hibbingwall.sh add google.com
# See what addresses a hostname expands to
sh hibbingwall.sh expand www.wikia.com
```
