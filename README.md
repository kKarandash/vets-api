# Roadrunner Rails
[![Build Status](https://travis-ci.org/department-of-veterans-affairs/roadrunner-rails.svg?branch=master)](https://travis-ci.org/department-of-veterans-affairs/roadrunner-rails)

Roadrunner Rails is a template for new Rails projects for the VA. It's pre-customized to work within the VA ecosystem.

```                               
      qWWWgaap                    
]W#########WW##Z##LaQbp           
   ]"?!??QW#ZZ#######m#b          
       )Wm####Z####Z###b          
                )????mm###a
                       ]####? p
                       y?Y?Y(   p
                       w####ZcL]T___$
                         ^<iQrcZZZr-'
                          :klf
p                          ]i                                    _
3p                         ]lp               _ __ ___   __ _  __| |_ __ _   _ _ __  _ __   ___ _ __
llLp                       ]If       ------ | '__/ _ \ / _` |/ _` | '__| | | | '_ \| '_ \ / _ \ '__|
zIl3q.                     ]If   __________ | | | (_) | (_| | (_| | |  | |_| | | | | | | |  __/ |
"gwzI3q                    kd          ____ |_|  \___/ \__,_|\__,_|_|   \__,_|_| |_|_| |_|\___|_|
   )?^y3qp               qJIf                                                     _ __ __ _(_) |___
      J4wwLagagagWWWWWhwilld                                     ______________  | '__/ _` | | / __|
         ?!4m#m####ZZ#Zmlllf               p           ------------------------  | | | (_| | | \__ \
      gKX@CiillTYXmDYYTlllmp         aggQ"4XXLga               ________________  |_|  \__,_|_|_|___/
    aGZF????????    )?4@illf   aggJQ"!'=jg#?':?"4#Lgga
  aAq"'.                "wuRXXXm!?     ]X#Xp      J!mX#XZZXUa
aAm?                     )!"!'.         !pXP           !XXZXXQ
r'                                                      )4XXWW
.
```

## Commands
- `rake lint` - Run the full suite of linters on the codebase.
- `bundle exec guard` - Runs the guard test server that reruns your tests after files are saved. Useful for TDD!

## Gems
Roadrunner Rails adds some additional gems for making Rails development better.

### Testing
- [RSpec](https://github.com/rspec/rspec) - Ruby testing framework for readable BDD tests.
- [RSpec Rails](https://github.com/rspec/rspec-rails) - Rails helpers for rSpec.
- [Guard](https://github.com/guard/guard) - Testing server for better TDD flow.

### Linting
- [Rubocop](https://github.com/bbatsov/rubocop) for Ruby style linting.
- [scss-lint](https://github.com/brigade/scss-lint) configured with [18F's CSS coding styleguide](https://pages.18f.gov/frontend/css-coding-styleguide/).
- [jshint](https://github.com/damian/jshint) for Javascript.