# mkbkdwn
Nothing of interest. Just some personal tests with make, travis and bookdown. I need to understand how travis cache works.

Got it! With `git clone` the modifications time of the files are lost, see https://stackoverflow.com/questions/21735435/git-clone-changes-file-modification-time and https://stackoverflow.com/questions/1964470/whats-the-equivalent-of-use-commit-times-for-git

A reliable way to do that would be by using a checksum approach: https://community.apigee.com/answers/49901/view.html

I'm testing this approach.
