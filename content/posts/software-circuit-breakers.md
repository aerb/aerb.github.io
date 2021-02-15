---
title: "Software Circuit Breakers"
date: 2021-02-14
draft: false
---

One of the most common anti-patterns in software development is something that looks like this: 
```
val tribble = getTribble(id)
if (tribble == null)
  return
```
In some contexts this type of code is fine, but in most it is not. It is a silent failure, which is the worst type of failure!

# What is `null`?
First what is a `null` Tribble? While Kotlin certainly supports richer ways of communicating errors, it comes from the tradition of Java and C, so usually uses `null` to represent the absence of a thing. From the perspective of `getTribble()` this is an error, since its only purpose is to return a tribble. `tribble == null` is essentially short for `ERROR_NO_TRIBBLE_FOUND`. 

# Types of Errors
When thinking about error handling I find it useful to split errors into two categories: recoverable, and non-recoverable [^note-on-rust]. There’s “Hey something came up, but we kinda foresaw this, so here’s how we’re going to make it right”, and then there’s “The server got hit by lightning”. Where exactly to draw this line is debatable but for my purposes here, I consider non-recoverable means “There is no sensible way to proceed at this time” (non-recoverable does not mean non-retryable)

[^note-on-rust]: Rust makes this exact distinction in its [error handling](https://doc.rust-lang.org/book/ch09-00-error-handling.html)

Depending on context, if `ERROR_NO_TRIBBLE_FOUND` is considered recoverable then we might be ok here. The function returns `ERROR_NO_TRIBBLE_FOUND` and the caller says “Oh, ok. `makeNewTribble()`”. 

If the error is non-recoverable however the code above can be very insidious. Maybe a Tribble *has* to exist in this state, and its absence suggests something very unexpected. We may have arrived here because of programming error, maybe network error, or maybe the server was hit by lightning.

# The Worst Type of Bug
Now consider the example in this context:
```
fun assignTribbleToShip(id: String) {
  val tribble = getTribble(id)
  if (tribble == null)
    return
  findShip().tribbles += tribble
}
```

This is where things start to get ugly. We called `assignTribbleToShip`, but the error `ERROR_NO_TRIBBLE_FOUND`, has been ignored. We think the tribble was assigned to our ship, but that is not true. Let's add more context:

```
fun assignTribbleApi(id: String): HttpResponse {
  assignTribbleToShip(id)
  emitTribbleAssignedEvent(id)
  incrementGlobalTribbleCount()
  return OK
}
```

Now things are starting to get really ugly. Because we ignored the error, other parts of the system are starting to get into an incorrect state. Our global tribble count is off - we've also emitted a `TibbleAssignedEvent` which will potentially trigger other side effects. What has effectively happened is we’re now starting to corrupt the data in our system. It is no longer true, and the more this failure happens the more wrong our system will get. 

This is one of the worst bugs we can introduce as programmers. Worse than our server 500’ing, worse than our app crashing. We no longer know what is true, and neither does our customer. We can probably only recover from this via manual intervention.

# A Better Way
So a better approach? It’s actually pretty easy:
``` 
getTribble(id)!!
```
or better yet:
```
getTribble(id) ?: throw NotFound(“No tribble $id”)
``` 
Throw [^exceptions-note]. We fail immediately, at the first sign of trouble. We simply see `ERROR_NO_TRIBBLE_FOUND` error, and declare "This is unrecoverable!". Throw up our arms and say "I give up!". 

[^exceptions-note]: There's a lot of debate about whether exceptions are net good or bad. There are good points on both sides, but use-cases like this are when I find them very valuable.

I was first exposed to this idea in [The Art of Unix Programming](https://en.wikipedia.org/wiki/The_Art_of_Unix_Programming). It is a Rule in [Unix Philosophy](https://homepage.cs.uri.edu/~thenry/resources/unix_art/ch01s06.html) known as:

> Rule of Repair: When you must fail, fail noisily and as soon as possible.

The idea is basic: If something is fundamentally wrong, fail immediately and make a bunch of noise. You won't be silently corrupting your system, and hopefully a human notices something is wrong and comes to help. 

A good physical metaphor for this is a circuit breaker. If the amount of current entering the system is more than can be handled, immediately fail off. Is it annoying? Yes, but it stopped our system from continuing, possibly causing more damage. 

This is a concept that is also at the heart of the [Erlang Programming Language](https://www.erlang.org/), and the [Actor Model](https://en.wikipedia.org/wiki/Actor_model). Erlang has a pretty good track record for high availability, it runs a lot of the world's telecommunication networks! When was the last time you can remember phone lines being down?

# Eating your Cake too
The best part of this pattern is when combined with higher level "supervisor" functions you can still immediately fail, but potentially recover. Naturally, if your program is in a weird state and throws an error, the best strategy is to retry [^retry-note]. "Have you tried turning it off and on again?". Depending on the error sometimes this will work, sometimes not, but it gives the system a chance to self heal if it can. 

[^retry-note]: Everything should be [idempotent](https://stackoverflow.com/a/1077421) for this to work. Basically, retry safe. 

The supervisor mechanism is another page from Erlang and Actors, but it's an idea that has naturally taken root everywhere you look. Your server framework may have an unhandled exception handler that triggers retry, your clients may retry on 500, if your application process crashes there is probably a daemon manager that will retry the process. In the end if all those things don't work there's a good chance a human will come along and retry.

# Why we do the Wrong Thing, and How to Stop
I believe there are a couple reasons behind the "`if null return`" anti-pattern and all of them are very human. 

One reason is it can be embarrassing to cause a bunch of noisy errors in an application if you are working on a team. Worse yet, you might be causing an issue that blocks someone else on your team. Maybe they planned to perform testing on staging but now staging is unusable.

Another reason might be you don't know everything about your system. Maybe you’re not sure of the guarantees of `getTribble` because it’s legacy code and undocumented, and you *just* want to be sure you’re not going to cause problems in production. 

These are completely valid concerns. The good news is you can avoid them with ...  
# Feature Flags
Feature Flags are amazing. You can make your changes behind a flag, fail as pedantically / loudly as you want, and immediately revert if you are starting to see serious problems. This allows your application to be strict and error tolerant, but revertible if that strictness is causing blocking problems. 

I’ve used [LaunchDarkly](https://launchdarkly.com/) and have no complaints. If you don't have a budget, you can probably roll your own without much work. You basically just want a remote way to enable / disable code paths. [^clean-up-note]

[^clean-up-note]: *Please* cleanup old flags once you've verified there are no problems.

# Final Thoughts

Problems tend to beget more problems. Ignoring signs that something is wrong typically allows those problems to take root and become worse. In programming languages that support it, you should feel comfortable to `throw` and `throw` often. `Exception`s are your friend, they tell you when something is wrong before more serious problems start to manifest. 





