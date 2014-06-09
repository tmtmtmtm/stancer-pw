# Stancer

## Summary

Show how UK MPs and Parties voted on Issues.

## Background

Knowing how politicians voted on individual motions generally isn't
particularly useful. What most people really want to know is how a
person, or political grouping, voted on **all** motions relating to a
particular issue.

``Stancer`` is a tool that lets you store lists of individual motions
making up an Issue, along with how strongly they should contribute to
it, and then see clearly how any person, party, or any kind of grouping
voted on that issue.

## Stancer-UK

An example of this can be seen at http://ukvotes.discomposer.com/

We take voting data and Policy positions from [Public Whip](http://www.publicwhip.org.uk/) 
and [TheyWorkForYou](http://theyworkforyou.com/), transform the underlying
motion data into [Popolo vote format](http://popoloproject.com/specs/motion.html), 
and access that via the [VoteIt API](https://github.com/tmtmtmtm/voteit-api)

We then display this using Github Pages — the code for which you can see
in the [gh-pages branch](https://github.com/tmtmtmtm/stancer-uk/tree/gh-pages) — by 
generating a few JSON files that can be dropped into the 
[data directory](https://github.com/tmtmtmtm/stancer-uk/tree/gh-pages/_data/).

## DIY

If you want to do your own version of this, feel free to dig into
everything here and see how far you get, but you'll probably be better
contacting me — at least until I write up a lot more of how all the
parts hang together. VoteIt and Popolo should cope well with lots of
very different voting scenarios, but Stancer is currently very UK
specific. Splitting out a more generic component is a high priority.

