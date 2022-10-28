# @title Contributing

# Contributing

Contributions, issues and pull requests are welcome.  Please visit the [GitHub home](https://github.com/ccutrer/openhab-jrubyscripting) for this project. 

# License
This code is under the [eclipse v2 license](https://www.eclipse.org/legal/epl-2.0/)

# Source
JRuby Scripting OpenHAB is GitHub repo is [here](https://github.com/ccutrer/openhab-jrubyscripting). 


# Development Environment Setup
The development process has been tested on MacOS, and Ubunut. Other operating systems may work. 

1. Install Ruby 2.6.8
2. Fork [the repo](https://github.com/ccutrer/openhab-jrubyscripting) and clone it
3. Install [bundler](https://bundler.io/)
4. Run `bundler install` from inside of the repo directory
5. To avoid conflicts, the OpenHAB development instance can use custom ports by defining these environment variables:
   * `OPENHAB_HTTP_PORT` 
   * `OPENHAB_HTTPS_PORT`
   * `OPENHAB_SSH_PORT`
   * `OPENHAB_LSP_PORT`
6. Run `bundle exec rake openhab:setup` from inside of the repo directory.  This will download a copy of OpenHAB local in your development environment, start it and prepare it for JRuby OpenHAB Scripting Development

# Code Documentation
Code documentation is written in [Yard](https://yardoc.org/) and the current documentation for this project is available [here](https://www.rubydoc.info/gems/openhab-jrubyscripting/).

# Development Process
1. Create a branch for your contribution.
2. Write your tests the project uses [Behavior Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) with [RSpec](https://rspec.info/). The spec directory has many examples.  Feel free ask in your PR if you need help.
3. Write your code.
4. Verify your tests now pass by running `bin/rspec spec/<your spec file>_spec.rb`
5. Update the documentation, run `bundle exec rake docs` to view the rendered documentation locally
6. Lint your code with `bundle exec rake lint` and ensure you have not created any [Rubocop](https://github.com/rubocop-hq/rubocop)  or [cuke lint](https://github.com/enkessler/cuke_linter) violations.
7. Submit your PR(s)!

If you get stuck or need help along the way, please open an issue.