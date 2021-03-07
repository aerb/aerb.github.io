---
title: "Weirdware is Healthy"
date: 2021-03-07
draft: false
---

There's a word I've been hearing increasingly at work: weirdware. I can't find a formal definition anywhere, but it seems to roughly be a critique of in-house libraries and frameworks, where popular open-source variants exist. I think it's slightly related to "[Not Invented Here](https://en.wikipedia.org/wiki/Not_invented_here) (NIH) Syndrome", but less focused on the author's thought process during the creation of said weirdware. 

I partially agree with the weirdware and NIH critiques, but in net I believe they are bad for the industry and counter-productive.

# Does "Not Invented Here" Exist?
First, in the case of NIH, I don't actually know if it exists? NIH appears to make the assumption that there are developers in a meeting somewhere saying, "Yes, there are popular open-source solutions available, but those solutions aren't made at MegaCorp™, so we should make something internal". I don't know if this *actually* happens. There are lots of things that motivate making "weird" internal solutions, but I don't know if the motivation presented in NIH, is actually a common one [^motivations]. I'll talk about what I think these actual motivations are below.

[^motivations]: If that actually is something that has motivated you in the past, now would be a good time to do some self reflection.

# The Bad of Weirdware
That leaves us with "weirdware". The weirdware critique seems less concerned with the authors state of mind in the decision-making process, and more with the end result: a bunch of under documented, strange internal tooling. I can sympathize with this. 

I believe one of the benefits of not going straight to a [FAANG](https://en.wikipedia.org/wiki/Big_Tech#FAANG) company, right out of university, is it gives you different perspectives. I have worked at 4 vastly different companies in my career, and I've seen **a lot** of weirdware. What I think the weirdware critique does not account for, is why those decisions were made at the time. I also think the weirdware critique does not consider what behaviors are encouraged and discouraged when the term is used.  

# Weirdware is Often Temporal
One of my previous employers actually built an in-house package manager for sharing internal libraries. That's crazy right? Who on earth starts a company and thinks "pip is great and all, but let's invest resources in building our own thing!". Here's who: someone who started a company before the concept of package managers was popularized. On tech timescales this company was ancient, they were still maintaining a Delphi codebase when I worked there. So at the time, they had an internal need, it was a polyglot company, and there were no standard package managers at the time. They had a problem, and they built a very simple internal tool to solve that problem. 

This is my fundamental frustration with the weirdware critique. It fails to account for the state of the world when decisions were made. 

Does it look crazy in 2021 for a company to role its own package manager? Sure, but meanwhile that package manager solved the problem, while the rest of the industry was still trying to figure out how the general solution should look. [^gradle]

[^gradle]: Surprise! Turns out we're [still figuring it out](/posts/we-need-better-than-gradle/).

# The Implication of "Weirdware"
The second thing that really frustrates me with the weirdware critique is some underlying implications about *who* gets to build the "right" solutions, and who is building "weirdware". I also think these implications encourage a very bad behaviour in developers.

The implication is that only FAANG companies get to build the "right" solution. I hate this so much. Of all the brilliant things FAANG companies build, they also build a lot of real [flops](http://www.gwtproject.org/). They are bigger, and can make more bets, but I don't think their good-to-bad idea ratio is necessarily better. Additionally, FANNG companies build solutions for FANNG companies. Their problems are not always our problems, and it's a mistake to pretend otherwise. Should we set up a super distributed micro-service architecture to handle ultra-high [QPS](https://en.wikipedia.org/wiki/Queries_per_second), or should we stand up a small monolith to serve our current 100 customers?

Another thing with FAANG solutions is they tend to target more general use-cases. Sometimes we don't have general use-cases. I have seen terrible hacks trying to use the "right" solution in a niche way, that the authors of the "right" solution never intended.  In my opinion these hacks are often far more confusing and buggy than building something simple and internal.

# Behaviors Encouraged by "Weirdware"
Lastly, I think the behaviors encouraged, by implying only FAANG companies get to build the "right" solution, are very bad behaviors. As developers, we're primarily tool builders. We build tools for customers to more easily achieve their goals. We should be encouraging our team members to build tools to solve their own problems too. By discouraging "weirdware" we are also discouraging creative thinking, and the instinct to solve our own problems.

# Final Thoughts 
We should encourage developers to feel empowered, to build their own tools when the status quo is feeling frustrating or painful. Maybe you did write some weirdware, and the industry evolved, and now it seems like a strange solution. If that happens, I see no harm in migrating to the standard solution, *if it meets your needs*. 

I consider that a **far** smaller problem to have, than to wake up one day, and realize you're surrounded by developers that just want to wait for a FANNG company to solve all their problems.

My vote?
Let's get weird.

