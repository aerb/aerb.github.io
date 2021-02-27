---
title: "We deserve better than Gradle"
date: 2021-02-15
draft: true
---

While coding professionally I've used gradle, maven, and ant. I think gradle is my least favorite. 
  
A recent [criticism](https://www.bruceeckel.com/2021/01/02/the-problem-with-gradle/) that really connected with me, that partially inspired this post is: Gradle is an all-or-nothing abstraction.
> To do anything you have to know everything 

[Another](https://phauer.com/2018/moving-back-from-gradle-to-maven/) criticism is that gradle breaks [stackoverflow](https://stackoverflow.com/) and general googlability by constantly offering different ways to do the same thing, while also regularly [breaking compatibility](https://docs.gradle.org/current/userguide/upgrading_version_5.html#dependencies_should_no_longer_be_declared_using_the_compile_and_runtime_configurations).

These are two good critiques, but ones that have already been well documented. I want to focus on Gradle from the perspective of a large organization, and how it is a terrible build tool for maintaining numerous projects.

# Gradle at Scale
The company I work for uses gradle heavily now for our builds. We have been migrating to a microservice world for a while now, so have an ecosystem of, I wanna say, a couple hundred services and libraries. All of these services and libraries have at least one but usually two gradle builds, so the total number is roughly 2x that.

We also have one git repository per service, no monorepo, so naturally have some jobs that do care-taking. Bump dependencies, enforce format rules, perform small migrations, etc. Gradle is horrible for this type of automation. 

So how do we update our `build.gradle` with new dependencies?

# What is Old Becomes New Again
Ultimately we need to be able to understand groovy. We don't want to write a full-blown interpreter, so we support a subset of what we need to understand in the gradle dsl. In our case we enforce a convention where each project declares is dependencies in a `dependencies.gradle` file that is simple enough for dumb parsers to understand and modify. 

With this convention we have gone full circle! We didn't like declarative builds because they weren't flexible enough, so we moved to Gradle, which is really just Groovy. But now we can't understand what Gradle builds are doing, because the underlying language is too complex for dumb parsers, and in the end gradle is convention, but you can really do what ever you want, so gods know what is happening in those hundreds of Gradle files.

# Migrating an Organization
There's another thing we've been working on lately. Gradle now has a [Kotlin script](https://docs.gradle.org/current/userguide/kotlin_dsl.html) variation of it's DSL[^note-on-dsl]. Our company is heavily using Kotlin now, so [a developer](https://publicobject.com/) has been working on a script to migrate all ~200 of our repos to the `build.gradle.kts` format. I agree with this migration. We all use Kotlin, so switching the format will probably give use more comfort and ease in maintaining those builds. It's how this migration is happening that made my jaw drop. 

[^note-on-dsl]: The Kotlin DSL is pretty great, and definitely an improvement, but yet another example of Gradle throwing in yet another way to do things and further splintering the knowledge base.

In the end everything is just Groovy, and there are no great Groovy to Kotlin converters available, so the present migration is basically to run a bunch of regexes against the `build.gradle` to optimistically search and replace Groovy with Kotlin. **A human** then needs to come in and fix the final 10% of things that didn't convert properly.

This is insane. For any organization that is trying to build an automated system for updating and running migrations on a large number of builds, it is insane that our best option is use grep and cross our fingers. This is not the first migration we have done, and will not be our last, and the number of builds is only going to increase.

# We Deserve Better
We are a professional community that naturally values structured data and automation. Using Gradle effectively and ironically breaks both these things. We deserve better, and we need better. So what does that "better" look like?  

I actually think Maven got it 90% right. A coworker has a line I really like, that highlights some of what I believe Maven got right.
> Your builds are not special. 

100% this. 

This first thing I like about the Maven model is it discourages doing crazy things! Virtually all builds are just pointing at some source files, referencing some jars, and compiling. Maybe we push the end result somewhere when we're done. Why on earth are we using a general purpose programming language to declare what should almost always be copying and pasting from a template. 

Instead, lets discourage hacks and just use what's built in. If we *really* need something special, we have an accessible plugin framework where we can punch out of the stricter declarative world, and then we're just coding in Kotlin. Boom! Do all the crazy your heart desires.

The other thing Maven got right is then of course having a strict convention and format. This is really where the power lies for large organizations. It's a simple enough "language" that parsers are multiple and battle tested. How far do you have to reach in a given language to parse and understand XML? In any mainstream language you probably have multiple options. Not just regexes.

This is exactly why Maven tooling has always been so out-of-the-box functional. The structure is well-defined, and there are fewer unexpected things because one-off hacks are discouraged. Gradle tooling on the other hand has always been near non-existent. IntelliJ supports Gradle and does a decent job, but it was a long road to get here. The support was incredibly buggy in early days, and even now seems a little flaky. Meanwhile Maven tooling has just quietly worked this whole time.

Of course what Maven didn't get right was XML. Maven was written at the time we all had [collective insanity](https://en.wikipedia.org/wiki/SOAP) and thought everything should be XML. We're still kinda dealing with the hangover. XML has a lot of properties that are great for builds, but is a total eyesore. 

# My Dream Build Tool
I want something Maven like, but no XML. Right off the bat I don't think YAML is the right thing here, we want something simpiler and stricter. I'm honestly not sure if a format like this exists, but I'm shouting into the void and hoping a response comes back. If one doesn't exist maybe we need to [make one](https://xkcd.com/927/) [^sorry].

[^sorry]: I'm sorry for asking for yet another serialization [format](https://en.wikipedia.org/wiki/Comparison_of_data-serialization_formats#Syntax_comparison_of_human-readable_formats), but I think this is a critical enough use-case that it would justify the investment

For my build tool and language I want something that has these properties:
1) Strict and static. Wouldn't it be great if IntelliJ yelled at us if we forgot a mandatory field? Wouldn't it be great if IntelliJ told us a field we were using on a plugin is deprecated? Wouldn't it be great if we could do a "Find Usages" on a dependency or plugin?

2) Simple. Writing interpreters for this should be easy so automated tools can do their thing. Even better maybe the build tool itself provides an [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree).

3) An accessible and rich plugin and lifecycle API. Maybe one of the mistakes of Maven was it was too strict, and that led to Gradle. Let's try to meet in the middle.

3) Support rich documentation. This is where XML is especially brutal. What if we could click on the property of a plugin-in, and it would bring us to well-formatted documentation. 😍. 

4) No meaningful whitespace please. We should have learned this was a bad idea a long time ago.

5) First class fat-jars! No Kotlin or Java targeting build tool has this as a first class feature and literally every JVM developer I have worked with wants it [^kobalt].  The whole JVM world is just relying on some guys [side project](https://github.com/johnrengelman/shadow). 

[^kobalt]: Except this [one](https://beust.com/kobalt/home/index.html)! But I don't think it really took off.

  
