---
layout: default
title: Motivation
nav_order: 2
has_children: false
---

## Design points
- Create an intuitive method of defining rules and automation
	- Rule language should "flow" in a way that you can read the rules out loud
- Abstract away complexities of OpenHAB (Timers, Item.state vs Item)
- Enable all the power of Ruby and OpenHAB
- Create a Frictionless experience for building automation
- The common, yet tricky tasks are abstracted and made easy. e.g. Running a rule between only certain hours of the day
- Tested
	- Designed and tested using [Behavior Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) with [Cucumber](https://cucumber.io/)
	- Current tests are [here](https://github.com/boc-tothefuture/openhab-jruby/tree/main/features)  Reviewing them is a great way to explore the language features
- Extensible
	- Anyone should be able to customize and add/remove core language features
- Easy access to the Ruby ecosystem in rules through ruby gems. 

## Why Ruby?
- Ruby is designed for programmer productivity with the idea that programming should be fun for programmers.
- Ruby emphasizes the necessity for software to be understood by humans first and computers second.
- For me, automation is a hobby, I want to enjoy writing automation not fight compilers and interpreters 
- Rich ecosystem of tools, including things like Rubocop to help developers create good code and cucumber to test the libraries
-  Ruby is really good at letting one express intent and creating a DSL within ruby to make that expression easier.
